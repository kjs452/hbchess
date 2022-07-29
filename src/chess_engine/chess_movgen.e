indexing
	description:	"Move generation iterator"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

--
-- The move generation class.
-- Moves are generated into two queues. A Capture queue and a Move queue.
-- The capture queue contains any moves that are captures (or promotions
-- or castling's). The move queue contains everything else.
--
-- If 'make_captures' is used, then we ONLY produce captures
--
-- If 'make_with_move_history' is used, then we will fetch the
-- first 4 moves that have the highest history count
-- from the CHESS_MOVE_HISTORY table.
--
-- In all cases we sort the capture moves according to
-- Most Valuable Victim/Least Valuable Attacker.
--
-- This class builds 2 queues:
--	moves:		- regular chess moves
--	captures:	- captures, promotions, castling
--
-- To use this class you would:
--	movgen.make	or	movgen.make_captures
--
--	movgen.start(board)	<- keep to first move
--	movgen.off		<- check if we are done
--	movgen.item		<- the CHESS_MOVE
--	movgen.forth		<- go to next move
--
-- You can also call,
--	movgen.move		<- apply the current move to 'board'
--	movgen.take_back	<- undo the current move
--
-- This move generator ignores King captures.
--
-- Before calling 'start' you can call,
--	set_best(m: CHESS_MOVE)
--
-- This will cause us to return this move before any other. This
-- allows us to preload the movgen object with a best_move that was
-- obtained from a previous search operation.
--
-- The 'best_move' will then be ignored when it shows up later.
--
-- Killer move:
-- During the search you can call:
--	set_killer(m: CHESS_MOVE)
--
-- This will store a killer move. Next time we iterate over
-- the moves, if the killer move exists in the list of
-- valid moves, it will be fetched first.
--
-- (NOTE: If a best_move has been set, it will be fetched first,
-- followed by the killer move.
--
-- The 'best_move' mechanism is used to transfer the results
-- of the principle variation obtained from the previous
-- search at a smaller depth (inside of the iterative deepening algorithm).
-- We only handle this 'best_move' the first time.
--
-- The 'killer_move' mechanism can be updated dynamically during the
-- search (whenever a cutoff occurs). The next time we are
-- searching at this ply depth, we can attempt to use the killer
-- move (if it exists in the list of valid moves).
--
--

class CHESS_MOVGEN
inherit
	CHESS_BOARD_TABLES
	CHESS_GENERAL_CONSTANTS
	CHESS_SQUARE_CONSTANTS
	CHESS_PIECE_CONSTANTS

creation
	make, make_captures, make_with_move_history

feature -- Initialization
	make is
		--
		-- Retrieve ALL moves for this chess position
		-- Captures, Promotions and Castling moves are
		-- returned before other moves (sorted using MVV/LVA)
		--
	do
		!! captures.make(Capture_queue_size);
		!! moves.make(Move_queue_size);
		!! saved_state.make;

		in_move := False;
		want_captures_only := False;
		move_history := Void;

		!! killer_move.make_empty;
		has_killer := False;
	end

	make_captures is
		-- retrieve capture moves only
		-- The moves will be sorted using MVV/LVA
	do
		!! captures.make(Capture_queue_size);
		moves := Void;
		!! saved_state.make;

		in_move := False;
		want_captures_only := True;
		move_history := Void;

		!! killer_move.make_empty;
		has_killer := False;
	end

	make_with_move_history(mhist: CHESS_MOVE_HISTORY) is
		-- retrieve ALL moves for a chess position.
		-- Captures, Promotions, Castling moves are
		-- returned first (sorted by MVV/LVA)
		--
		-- Non-capture moves are sorted using the move
		-- history table 'mhist'.
		--
	require
		mhist /= Void;
	do
		make;
		move_history := mhist;
	end

feature -- Access
	in_move: BOOLEAN;

feature -- Status Report
	off: BOOLEAN is
	do
		Result := (not has_item) and (not has_move_data);
	end

feature -- Status Setting
	set_best(mov: CHESS_MOVE) is
		-- 'mov' will be retireved before getting any other moves
	require
		mov /= Void;
	do
		best_move := mov;
	end

	clear_best is
		-- clear the 'best_move'
	do
		best_move := Void;
	end

	set_killer(mov: CHESS_MOVE) is
		-- If 'mov' is found in our move queues, it will be
		-- returned before other moves (the best_move will
		-- always be returned first).
	require
		mov /= Void;
	do
		killer_move.copy(mov);
		has_killer := True;
	end

	clear_killer is
		-- clear the 'killer_move'
	do
		has_killer := False;
	end

	start(a_cp: CHESS_POSITION) is
		-- find first move
	require
		a_cp /= Void;
	local
		found: BOOLEAN;
	do
		cp := a_cp;
		side := cp.side_to_move;

		if captures /= Void then
			captures.wipe_out;
		end

		if moves /= Void then
			moves.wipe_out;
		end

		item := Void;
		has_item := False;
		in_move := False;
		move_history_counter := 4;

		if best_move /= Void then
			item := best_move;
			has_item := True;
			ignore_move := best_move;
			best_move := Void;
		end

		get_all_moves;

		captures.sort(cp);

		if has_killer then
			--
			-- The killer move was found in the capture queue,
			-- so we don't need to try to look for it
			-- later.
			--
			found := captures.bring_move_to_front(killer_move);
			try_killer := not found;
		else
			try_killer := False;
		end

		if (not has_item) and (has_move_data) then
			forth;
		end
	end

	item: CHESS_MOVE;
		-- this is the next move, set after calling 'forth'

	move is
		-- Apply the current move to 'cp'
		-- (You must 'take_back' a move, before making
		-- another move)
	require
		item /= Void;
		not in_move;
	do
		in_move := True;
		saved_state.copy(cp.state);
		item.move(cp);

	ensure
		in_move;
	end

	take_back is
		-- undo the current move to 'cp'
		-- (must call this routine before calling 'move' again)
	require
		item /= Void;
		in_move;
	do
		in_move := False;
		item.take_back(cp);
		cp.set_state(saved_state);

	ensure
		not in_move;
	end

	forth is
		-- get an another move out of the move queue(s).
		-- Look in 'capture' queue first, then when that
		-- queue is empty, look in the 'move' queue
	require
		not off;
	do
		from
			has_item := False;
		until
			(has_item) or else (off)
		loop
			if captures.count > 0 then
				if matches(captures.item) then
					item := captures.item;
					has_item := True;
				end
				captures.remove;
			elseif (moves /= Void) and then moves.count > 0 then
				bring_best_to_front(moves);
				if matches(moves.item) then
					item := moves.item;
					has_item := True;
				end
				moves.remove;
			end
		end
	ensure
		has_item or off
	end

feature {NONE} -- Implementation (routines)

	matches(mov: CHESS_MOVE): BOOLEAN is
		-- Do we want this move?
		-- This implementation only returns moves that are NOT
		-- king captures are removed from this list..
		--
		-- When we are retrieving sorted captures, then
		-- we only allow capture moves.
	require
		mov /= Void;
	do
		Result := True;

		if want_captures_only and then not mov.is_capture(cp) then
			Result := False;

		elseif ignore_move /= Void and then ignore_move.is_equal(mov) then
			--
			-- we only ignore this move the first time it occurs
			--
			ignore_move := Void;
			Result := False;

		elseif mov.is_king_capture(cp) then
			Result := False;

		end
	end

	has_move_data: BOOLEAN is
		-- do we have moves in the queue
	do
		Result := (captures.count > 0)
				or (moves /= Void and then moves.count > 0);
	end

	get_all_moves is
		-- run through the chess board and generate all
		-- possible moves for 'board'
		--
		-- This will fill the 'move' and 'capture' queues.
		--
	local
		square, piece: INTEGER;
		ms: CHESS_MOVE_SQUARE;
		plist: CHESS_PATH_LIST;
	do
		--
		-- MOVE ORDERING:
		-- Since we must scan the board, we can scan the board
		-- in different orders. In this case we scan for pieces
		-- deep within the side to move's territory.
		--
		-- OPTIMIZATIONS:
		-- This loop must go thru 64 squares, so we try to be
		-- as efficient as possible in this loop.
		--	1. We have a seperate loops for white and black pieces
		--
		if side = Chess_color_white then
			from
				square := Min_square;
			until
				square > Max_square
			loop
				piece := cp.get_piece(square);
				if (piece >= Piece_white_pawn) and then (piece <= Piece_white_king)
				then
					ms := move_table.item(square, piece);
					plist := ms.paths;
					plist.generate_moves(cp, square, piece, moves, captures);
				end
				square := square + 1;
			end

		else
			from
				square := Max_square;
			until
				square < Min_square
			loop
				piece := cp.get_piece(square);
				if (piece >= Piece_black_pawn) then
					ms := move_table.item(square, piece);
					plist := ms.paths;
					plist.generate_moves(cp, square, piece, moves, captures);
				end
				square := square - 1;
			end
		end

	end

	bring_best_to_front(q: CHESS_MOVE_QUEUE) is
		--
		-- This routine tries to order moves in
		-- an advantageous way.
		--
		-- First if we are trying killer moves, then
		-- we try to bring this move to the front of the
		-- queue.
		--
		-- Secondly, if we couldn't do the killer move,
		-- we try to bring the best move from the move
		-- history to the front of the queue.
		--
		-- if move_history is enabled, locate the
		-- move with the highest move history count and
		-- place it in the front of the queue.
		--
		-- (only do this 'move_history_counter' times)
		
	require
		q /= Void;
	local
		got_killer: BOOLEAN;
	do
		if try_killer then
			try_killer := False;

			--
			-- scan queue 'q' and look for the
			-- killer move, if found bring it to the
			-- front.
			--
			got_killer := q.bring_move_to_front(killer_move);
		end

		if not got_killer then
			if (move_history /= Void) and then (move_history_counter > 0)
			then
				move_history_counter := move_history_counter - 1;
				q.bring_best_to_front(move_history);
			end
		end
	end

feature {NONE} -- Implementation (attributes)
	cp: CHESS_POSITION;
	saved_state: CHESS_STATE;
	side: INTEGER;

	want_captures_only: BOOLEAN;

	--
	-- Storage for new moves
	--
	moves: CHESS_MOVE_QUEUE;
	captures: CHESS_MOVE_QUEUE;

	has_item: BOOLEAN;

	--
	-- We can insert a "best_move" to be retrieved
	-- before any others.
	--
	best_move: CHESS_MOVE;

	--
	-- We will try to return this move before all others.
	--
	killer_move: CHESS_MOVE;
	has_killer: BOOLEAN;
	try_killer: BOOLEAN;

	move_history: CHESS_MOVE_HISTORY;
	move_history_counter: INTEGER;

	--
	-- If this move shows up, we ignore it
	--
	ignore_move: CHESS_MOVE;

	Capture_queue_size: INTEGER is 10;
	Move_queue_size: INTEGER is 40;

end
