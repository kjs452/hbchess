indexing
	description:	"search chess moves to find a good move"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

--
-- This class is parent of the following class heirarchy:
--	CHESS_SEARCH*
--		CHESS_SEARCH_THREAD
--		CHESS_SEARCH_NO_THREAD
--
-- This class is abstract, so one of the two versions above
-- must be used. The different classes are for
-- threaded and non-threaded version.
--
-- ALGORITHM:
-- THIS is the core of any computerized chess playing program.
-- It answers the following question: "What is the best
-- move to make?"
--
-- When it is the computers turn to play, it will determine
-- what move to make. When the user requests a hint, it
-- will use the same algorithm to tell it what it thinks
-- the user should play.
--
-- Algorithms used:
--	iterative deepening		iterative_deepening()
--	Alphabeta			search()
--	Quiescent search		qsearch()
--	transposition hash tables	(CHESS_TRANSPOSITION_TABLE)
--	principle continuation array	(CHESS_PRINCIPLE_CONTINUATION)
--
-- Measured Performance:
-- Current Speed: 60,00 - 80,000 nodes per second
--  (1.0 Ghz, Pentium, 512MB RAM)
--
-- On a 2.6 Ghz, Pentium, 1GB RAM, this search algorithm
-- searches about 260,000 nodes per second.
--
--

deferred class CHESS_SEARCH
inherit
	CHESS_GENERAL_CONSTANTS
	CHESS_SQUARE_CONSTANTS
	CHESS_PIECE_CONSTANTS

	MEMORY
	EXCEPTIONS

	SCC_SYSTEM_TIME

feature {NONE} -- creation
	make_search is
	do
		!! trans.make;
		!! repetition.make;
		!! move_history.make;
	end

feature -- Commands
	initialize(maxp, maxt: INTEGER; wantq: BOOLEAN) is
		-- initialize the chess search module. Call this before
		-- a new game starts. This will setup the
		-- search parameters, and clear the transposition table
		-- 'maxp' is max_ply
		-- 'maxt' is max_timer
		-- 'wantq' is want_qsearch
		--
	require
		maxp >= 2;
		maxt >= 1;
		not searching;
		not terminated;
	deferred
	end

	begin_search(cp: CHESS_POSITION; hist: CHESS_GAME_HISTORY) is
		-- start a search for the "best move" to make
		-- for 'cp'. side-to-move is determined by attributes
		-- of 'cp'.
		--
		-- When the search completed the 'searching' flag
		-- will be set to False.
		--
		-- 'hist' is a list of previous game positions, that
		-- is used to load the repetition table.
		--
		-- Results:
		--	'item' will be the best move to make
		--	If item is Void, then stale-mate, check-mate or
		--	draw flags will be set.
		--
		--	best_sequence is a string representing the best
		--	sequence of moves found by the chess engine.
		--
		--	'statistics' will be updated.
	require
		cp /= Void;
		hist /= Void;
		not searching;
		not terminated;
	deferred
	end

	terminate is
		-- terminiate this class. Cannot be restarted. No
		-- further commands can be issued.
	require
		not searching;
		not terminated;
	deferred
	end

feature -- Access
	item: CHESS_MOVE is
		-- this is the chess move obtained from the
		-- last search operation
	deferred
	end

	best_sequence: STRING is
	deferred
	end

feature -- Status Report
	searching: BOOLEAN is
		-- True while the search is progress
	deferred
	end

	terminated: BOOLEAN is
		-- True if this class has been terminiated
		-- by a call to the command 'terminate'
	deferred
	end

	check_mate: BOOLEAN is
		-- true if the last search operation could not find
		-- a move, because the side-to-move was in check
	deferred
	end

	stale_mate: BOOLEAN is
		-- true if the last search operation could not
		-- find a move, because the side-to-move is stale-mated
	deferred
	end

	draw: BOOLEAN is
		-- true if the last search operation could not
		-- find a move, because a draw was detected
	deferred
	end

	statistics: CHESS_STATISTICS is
		-- statistics about the chess search engine performance
		-- this is updated after each search operation.
	deferred
	end

feature {NONE} -- Deferred implementation routines
	set_item(val: CHESS_MOVE) is
	deferred
	end

	set_check_mate(val: BOOLEAN) is
	deferred
	end

	set_stale_mate(val: BOOLEAN) is
	deferred
	end

	set_draw(val: BOOLEAN) is
	deferred
	end

	set_best_sequence(val: STRING) is
	deferred
	end

	set_statistics(val: CHESS_STATISTICS) is
	require
		val /= Void;
	deferred
	end

	set_searching(val: BOOLEAN) is
	deferred
	end

	set_terminated(val: BOOLEAN) is
	deferred
	end

	monitor_action is
		-- called after every Search_action_interval nodes
		-- have been visited (usually several times per second)
		-- this can be used to dispatch windows events to
		-- keep the display updated
	deferred
	end

feature {NONE} -- Implementation
	init(maxp, maxt: INTEGER; wantq: BOOLEAN) is
		-- initialize the search parameters
		-- and rebuild search data structures.
	local
		i: INTEGER;
		mg: CHESS_MOVGEN;
	do
		max_ply := maxp;
		max_time := maxt;
		want_qsearch := wantq;

		--
		-- Clear transposition table
		--
		trans.clear;

		--
		-- clear the repetition detection table
		--
		repetition.clear_all;

		--
		-- Clear the move history
		--
		move_history.clear_counters;

		--
		-- Principle Continuation:
		--  The list of moves considered "best" in the search tree
		--
		pc := Void;
		last_pc := Void;

		search_time_begin := tick_count;
		search_time_end := tick_count;

		--
		-- reset statistics
		--
		total_nodes_searched := 0;
		total_search_duration := 0.0;
		node_count := 0;

		--
		-- Clear outputs
		--
		set_stale_mate(False);
		set_check_mate(False);
		set_draw(False);
		set_item(Void);
		set_best_sequence(Void);
		set_statistics( compute_statistics );;

		--
		-- build array of move generators for normal search
		-- this is large enough to handle the maximum
		-- depth our normal search will reach.
		--
		!! movgen_stack.make(0, max_ply);
		from
			i := movgen_stack.lower;
		until
			i > movgen_stack.upper
		loop
			!! mg.make_with_move_history(move_history);
			movgen_stack.put(mg, i);

			i := i + 1;
		end

		--
		-- build array of move generators for qsearch
		--
		!! quiescent_stack.make(0, Quiescent_stack_size);
		from
			i := quiescent_stack.lower;
		until
			i > quiescent_stack.upper
		loop
			!! mg.make_captures;
			quiescent_stack.put(mg, i);
			i := i + 1;
		end
	end

feature {NONE} -- Search implementation
	find_best_move(hist: CHESS_GAME_HISTORY) is
		-- Perform a search thru the chess game tree and
		-- find the best move for 'board.side_to_move'
		-- could make.
		--
		-- This routine will search 'max_ply' depth, or
		-- until 'max_time' seconds has elapsed, whichever
		-- comes first
		--
		-- 'hist' is a list of past moves and board positions
		-- that have been played in the game so far.
		--
	local
		times_up: BOOLEAN;
		saved_board: CHESS_POSITION;
	do
		if not times_up then
			--
			-- very little memory allocation happens
			-- in the search algorithm, but this
			-- just ensures that any reference manipulation
			-- will not trigger a GC collection cycle
			-- (doesn't seem to matter performance wise)
			--
			collection_off;

			set_stale_mate(False);
			set_check_mate(False);
			set_draw(False);
			set_item(Void);
			last_pc := Void;

			trans.set_position(board);

			move_history.shrink_counters;

			clear_killer_moves;

			!! saved_board.make;
			saved_board.deep_copy(board);

			node_count := 0;

			search_time_begin := tick_count;
			search_time_end := tick_count + max_time * 1000;

			iterative_deepening(hist);
		else
			--
			-- restore chess board and all associated
			-- state.
			--
			board.deep_copy(saved_board);
		end

		if stale_mate or check_mate or draw then
			set_item(Void);
		else
			set_item(last_pc.best);
		end

		search_time_end := tick_count;

		set_best_sequence( last_pc.best_line_out(board) );
		set_statistics( compute_statistics );

		-- enable garbage collection
		collection_on;
		full_coalesce;

	ensure
		(item /= Void) or stale_mate or check_mate or draw
	rescue
		if is_developer_exception_of_name(Time_limit_expired)
			or else is_developer_exception_of_name(Terminate_search)
		then
			times_up := True;
			retry;
		end
	end

feature {NONE} -- search algorithm(s)

	iterative_deepening(hist: CHESS_GAME_HISTORY) is
		--
		-- This algorithm loops thru the plies 1, 2, 3, 4
		-- and repeats the search operation. This allows
		-- us to find a "good" move quickly and then
		-- we can go deeper. When our time expires
		-- we will at least have a decent move to return.
		--
		-- Using a transposition table makes this
		-- type of algorithm, reasonable fast.
		--
		-- We also pre-load the move generators
		-- with the best move from the last Principle
		-- Continuation. This means
		-- we search the best move from the previous iteration
		-- first.
		--
	do
		from
			searching_depth := 2;
		until
			searching_depth > max_ply
		loop
			store_last_pc(searching_depth);

			!! pc.make(searching_depth);

			load_repetitions(hist);

			root_search(searching_depth, -Infinity, Infinity);

			last_pc := pc;

			searching_depth := searching_depth + 1;
		end
	end

	root_search(depth, a_alpha, beta: INTEGER) is
		-- called to search to the top-level of the chess search
		-- tree
	require
		depth = searching_depth;
		depth > 1;
	local
		movgen: CHESS_MOVGEN;
		mov: CHESS_MOVE;
		val, alpha: INTEGER;
		ttyp: INTEGER;
		has_value, cutoff: BOOLEAN;
		num_children: INTEGER;
	do
		movgen := movgen_stack.item(depth);

		alpha := a_alpha;

		pc.set_length(depth);

		repetition.set(board);

		from
			ttyp := Trans_type_alpha;
			movgen.start(board);
		until
			cutoff or else movgen.off
		loop
			mov := movgen.item
			movgen.move;

			if not board.is_in_check(mov.side) then
				val := -search(depth-1, -beta, -alpha);
				num_children := num_children + 1;
				has_value := True;
			else
				has_value := False;
			end

			movgen.take_back;

			if has_value and then (val >= beta) then
				cutoff := True;
				trans.record(depth, beta, Trans_type_beta);
				move_history.increment(mov, depth);
				movgen.set_killer(mov);

			elseif has_value and then (val > alpha) then
				alpha := val;
				pc.set_best_move(depth, mov);
				ttyp := Trans_type_exact;
			end

			movgen.forth;
		end

		repetition.clear(board);

		if cutoff then
			-- at the root node: so, if a cutoff occured
			-- we need to set a best move.
			if pc.get(depth) = Void then
				pc.set_best_move(depth, mov);
			end

		elseif num_children = 0 then
			if board.is_in_check(board.side_to_move) then
				--
				-- check mate: every move puts us into check
				-- and we are currently in check.
				--
				set_check_mate(True);
			else
				--
				-- stale mate: every move puts us into check
				-- but we aren't in check.
				--
				set_stale_mate(True);
			end

		elseif board.state.fifty_counter > 100 then
			-- each side moved 50 times without capturing
			-- a piece or moving a pawn
			set_draw(True);

		else
			trans.record(depth, alpha, ttyp);
		end
	end

	search(depth, a_alpha, beta: INTEGER): INTEGER is
		-- alpha beta search.
		-- Search internal nodes: less than root, and greater than
		-- leaves.
	require
		depth >= 0 and depth < searching_depth;
	local
		movgen: CHESS_MOVGEN;
		mov: CHESS_MOVE;
		val, alpha: INTEGER;
		ttyp: INTEGER;
		has_value, cutoff: BOOLEAN;
		num_children: INTEGER;
	do
		movgen := movgen_stack.item(depth);

		alpha := a_alpha;

		pc.set_length(depth);

		new_node;

		--
		-- We can get a value early, if there
		-- is a repeated move, or if this
		-- position is in the transposition table.
		--
		if repetition.has(board) then
			has_value := True;
			Result := 0;
		else
			trans.probe(depth, alpha, beta);
			if trans.found then
				has_value := True;
				Result := trans.last_score;
			end
		end

		if has_value then
			-- do nothing, result has already been set above.

		elseif depth = 0 then
			if want_qsearch then
				Result := qsearch(0, alpha, beta);
			else
				Result := leaf_search;
			end
			trans.record(depth, Result, Trans_type_exact);

		else
			repetition.set(board);
			from
				ttyp := Trans_type_alpha;
				movgen.start(board);
			until
				cutoff or else movgen.off
			loop
				mov := movgen.item;

				movgen.move;

				if not board.is_in_check(mov.side) then
					val := -search(depth-1, -beta, -alpha);
					has_value := True;
					num_children := num_children + 1;
				else
					has_value := False;
				end

				movgen.take_back;

				if has_value and then (val >= beta) then
					Result := beta;
					cutoff := True;
					trans.record(depth, beta, Trans_type_beta);
					move_history.increment(mov, depth);
					movgen.set_killer(mov);

				elseif has_value and then (val > alpha) then
					alpha := val;
					pc.set_best_move(depth, mov);
					ttyp := Trans_type_exact;
				end

				movgen.forth;
			end
			repetition.clear(board);

			if (num_children = 0) then
				if board.is_in_check(board.side_to_move) then
					-- check-mate: we had no moves AND we are
					-- in check
					Result := -Infinity + real_depth(depth);
				else
					-- Stalemate: we had no moves AND we're not
					-- in check. So we return a neutral score.
					Result := 0;
				end

			elseif board.state.fifty_counter > 100 then
				Result := 0;

			elseif not cutoff then
				trans.record(depth, alpha, ttyp);
				Result := alpha;
			end
		end
	end

	qsearch(depth, a_alpha, beta: INTEGER): INTEGER is
		-- Quiesient search, called after normal 'search' to
		-- look for capture sequences that could lead to
		-- peril
		--
		-- This search recursively calls itself with depth+1,
		-- so the depth argument is increasing the deeper
		-- we search (this differs from the normal
		-- search algorithm above)
	require
		depth <= quiescent_stack.upper;
		depth >= quiescent_stack.lower;
	local
		movgen: CHESS_MOVGEN;
		val, alpha: INTEGER;
		cutoff: BOOLEAN;
	do
		movgen := quiescent_stack.item(depth);

		alpha := a_alpha;

		new_node;

		val := leaf_search;
		if val >= beta then
			Result := beta;
		else
			if val > alpha then
				alpha := val;
			end

			from
				movgen.start(board);
			until
				movgen.off or cutoff
			loop
				movgen.move;

				val := -qsearch(depth+1, -beta, -alpha);

				movgen.take_back;

				if val >= beta then
					Result := beta;
					cutoff := True;
				elseif val > alpha then
					alpha := val;
				end

				movgen.forth;
			end
			if not cutoff then
				Result := alpha;
			end
		end
	end

	leaf_search: INTEGER is
		-- Called at the leaf nodes of the chess search tree:
		-- (must return a value relative to the "side-to-move")
		-- A positive value returned means the side-to-move
		-- has a benefit in the position.
		-- 
		-- A negative value returned implies a bad position
		-- for side-to-move
	do
		if board.side_to_move = Chess_color_white then
			Result := board.score;
		else
			Result := - board.score;
		end
	end

feature {NONE} -- Implementation

	load_repetitions(hist: CHESS_GAME_HISTORY) is
		-- store the game history chess positions
		-- into the repetition_table.
		-- (store only unique positions)
	require
		hist /= Void;
	local
		cp: CHESS_POSITION;
	do
		repetition.clear_all;

		from
			hist.start;
		until
			hist.off
		loop
			cp := hist.item.board;

			if not repetition.has(cp) then
				repetition.set(cp);
			end

			hist.forth;
		end
	end

	compute_statistics: CHESS_STATISTICS is
		-- call this at the end of the search to build the
		-- statistics class.
	local
		sec: DOUBLE;
		d: DOUBLE;
	do
		total_nodes_searched := total_nodes_searched + node_count;

		sec := (search_time_end - search_time_begin) / 1000.0;

		total_search_duration := total_search_duration + sec;

		if sec /= 0 then
			nps := (node_count / sec).rounded;
		else
			nps := 0;
		end

		-- create result
		!! Result.make;

		if total_search_duration /= 0 then
			d := total_nodes_searched / total_search_duration;
		else
			d := 0.0;
		end

		Result.set_nodes_per_second(d.rounded);
		Result.set_last_nps(nps);
		Result.set_last_node_count(node_count);

		--
		-- hash statistics
		--
		Result.set_total_hash_slots(trans.total_slots);
		Result.set_hash_slots_used(trans.slots_used);
		Result.set_total_hash_collisions(trans.num_collisions);
		Result.set_total_hash_lookups(trans.num_lookups);

		--
		-- best sequence (if exists)
		--
		if best_sequence /= Void then
			Result.set_best_sequence( best_sequence );
		else
			Result.set_best_sequence("N/A");
		end
	end

	store_last_pc(new_depth: INTEGER) is
		-- adds the best move from the principle continuation
		-- into the mov generators.
	require
		new_depth >= 1
	local
		best_list: LINKED_LIST[ CHESS_MOVE ];
		i, depth: INTEGER;
		movgen: CHESS_MOVGEN;
	do
		--
		-- clear the best move from ALL movgen's
		--
		from
			i := movgen_stack.lower;
		until
			i > movgen_stack.upper
		loop
			movgen_stack.item(i).clear_best;
			i := i + 1;
		end

		--
		-- Now store the best principle continuation
		-- with each mov generator
		--
		if last_pc /= Void then
			best_list := last_pc.best_line;
			from
				best_list.start;
				depth := new_depth;
			until
				best_list.off or (depth = 0)
			loop
				movgen := movgen_stack.item(depth);

				movgen.set_best(best_list.item);

				best_list.forth;
				depth := depth - 1;
			end
		end
	end

	clear_killer_moves is
		-- go thru all the move generators for
		-- each ply, and clear the killer move. This is
		-- done at the beginning of each search.
	local
		i: INTEGER;
		movgen: CHESS_MOVGEN;
	do
		from
			i := movgen_stack.lower;
		until
			i > movgen_stack.upper
		loop
			movgen := movgen_stack.item(i);
			movgen.clear_killer;
			i := i + 1;
		end
	end

	new_node is
		-- called for every new node in the search tree
	do
		node_count := node_count + 1;
		if (node_count \\ Search_interval) = 0 then
			check_time_expired;
		end

		if (node_count \\ Search_action_interval ) = 0 then
			monitor_action;
		end
	end

	check_time_expired is
		-- called every Search_interval nodes
		-- checks if time expired
	do
		if tick_count > search_time_end then
			raise(Time_limit_expired);
		end
	end

	real_depth(depth: INTEGER): INTEGER is
		-- This is the "real" depth of the current search
		-- In other words, the "real depth" is LARGER when we
		-- are deeper in the search tree. Ex.
		--
		--	depth	Result
		--	4	1
		--	3	2
		--	2	3
		--	1	4
		--	0	5
	require
		depth >= 0 and depth <= searching_depth;
	do
		Result := (searching_depth - depth) + 1;
	end

feature {NONE} -- Implementation CONSTANTS
	-- try to set this value so it is called at least once per second
	Search_interval:	INTEGER is 50_000;
	Search_action_interval:	INTEGER is 5_000;

	Time_limit_expired:	STRING is "Search Time Expired";
	Terminate_search:	STRING is "Search Terminated";

	Quiescent_stack_size:	INTEGER is 30;

feature {NONE} -- Implementation
	board: CHESS_POSITION;

	max_ply: INTEGER;
		-- maximum depth to search during 'normal' search

	max_time: INTEGER;
		-- maximum time (in seconds) to spend searching

	want_qsearch: BOOLEAN;
		-- perform quescent search?

	pc: CHESS_PRINCIPLE_CONTINUATION;
	last_pc: CHESS_PRINCIPLE_CONTINUATION;

	trans: CHESS_TRANSPOSITION_TABLE;
	repetition: CHESS_REPETITION_TABLE;
	move_history: CHESS_MOVE_HISTORY;

	movgen_stack: ARRAY[ CHESS_MOVGEN ];
	quiescent_stack: ARRAY[ CHESS_MOVGEN ];

	search_time_begin: INTEGER;
	search_time_end: INTEGER;

	searching_depth: INTEGER;
		-- how deep we are currently searching

	node_count: INTEGER;
		-- total number of nodes searched from last call to 'find_best_move'

	nps: INTEGER;
		-- nodes per second from last call to 'find_best_move'

	total_nodes_searched: INTEGER;
		-- total number of nodes searched, since creation

	total_search_duration: DOUBLE;
		-- total time spent searching nodes (in fine seconds), since creation

end
