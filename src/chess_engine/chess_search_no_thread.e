indexing
	description:	"chess search (non-threaded version)"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

--
-- A non-thread version of the CHESS_SEARCH parent class.
-- Check out the feature 'monitor_action', which allows
-- use to handle windows events during the search phase
--
-- For my needs I don't need a fully multi-threaded search engine,
-- it is sufficient to occasionally check the windows event queue
-- and process messages. Therefore CHESS_SEARCH_NO_THREAD is
-- a perfectly fine implmentation
--
-- I attempted a threaded version (See CHESS_SEARCH_THREAD) and
-- it was much SLOWER. So I recommend using this class
-- over the other implementation.
--
--
class CHESS_SEARCH_NO_THREAD
inherit
	CHESS_SEARCH

creation
	make

feature -- Initialization
	make is
	do
		!! msg.make;
		make_search;
		set_searching(False);
		set_terminated(False);
	end

feature -- Commands
	initialize(maxp, maxt: INTEGER; wantq: BOOLEAN) is
	do
		set_searching(True);
		init(maxp, maxt, wantq);
		set_searching(False);
	end

	begin_search(cp: CHESS_POSITION; hist: CHESS_GAME_HISTORY) is
	do
		set_searching(True);
		board := cp;
		find_best_move(hist);
		set_searching(False);
	end

	terminate is
	do
		set_terminated(True);
	end

feature -- Access
	item: CHESS_MOVE;
	best_sequence: STRING;

feature -- Status Report
	searching: BOOLEAN;
	terminated: BOOLEAN;

	check_mate: BOOLEAN;
	stale_mate: BOOLEAN;
	draw: BOOLEAN;
	statistics: CHESS_STATISTICS;

feature {NONE} -- Implementation
	set_item(val: CHESS_MOVE) is
	do
		item := val;
	end

	set_check_mate(val: BOOLEAN) is
	do
		check_mate := val;
	end

	set_stale_mate(val: BOOLEAN) is
	do
		stale_mate := val;
	end

	set_draw(val: BOOLEAN) is
	do
		draw := val;
	end

	set_best_sequence(val: STRING) is
	do
		best_sequence := val;
	end

	set_statistics(val: CHESS_STATISTICS) is
	do
		statistics := val;
	end

	set_searching(val: BOOLEAN) is
	do
		searching := val;
	end

	set_terminated(val: BOOLEAN) is
	do
		terminated := val;
	end

	msg: WEL_MSG;

	monitor_action is
	do
		msg.peek_all;
		if msg.last_boolean_result then
			msg.translate;
			msg.dispatch;
		end
	end

end
