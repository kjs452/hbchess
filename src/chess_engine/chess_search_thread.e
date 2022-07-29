indexing
	description:	"chess search (threaded version)"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

--
-- A threaded version of the CHESS_SEARCH parent class.
--
-- To compile with this version:
--	1. Edit CHESS_APPLICATION_MANAGER and change the line,
--		!CHESS_SEARCH_NO_THREAD! search.make;
--	to
--		!CHESS_SEARCH_THREAD! search.make;
--
--	2. Shutdown Eiffel Studio.
--
--	3. Remove EIFGEN directory and remove the file "chess_application.epr"
--
--	4. Add this line to the "ace.ace":
--		multithreaded(yes)
--
--	5. Run EiffelStudio 5.3 and select the ace file.
--	(uncheck the "recompile" checkbox)
--
--	6. Project Settings: Edit clusters, and add the "thread" cluster
--
--	7. Project Settings: Select the precompiled library "wel-mt"
--
--	8. Project Settings: Go to externals and add change
--	   the following Object file:
--		$(ISE_EIFFEL)\library\wel\spec\$(ISE_C_COMPILER)\lib\wel.lib
--	to
--		$(ISE_EIFFEL)\library\wel\spec\$(ISE_C_COMPILER)\lib\mtwel.lib
--
--	9. Recompile application
--
-- My experiments shows that multi-threading is much slower than
-- using CHESS_SEARCH_NO_THREAD....
-- For example on my 2.5 Ghz pentium I observe the following:
--	Non-threaded version:	250,000 nodes/second
--	Threaded version:	150,000 nodes/second
--
-- It was a fun experiment, but in the end I didn't use any of
-- this code for the final version.
--
--
class CHESS_SEARCH_THREAD
inherit
	CHESS_SEARCH

	THREAD
	rename
		terminated as thread_terminated
	export
		{NONE} all
	end

creation
	make

feature -- Initialization
	make is
	local
		attr: THREAD_ATTRIBUTES;
	do
		make_search;

		!! attr.make;
		attr.set_priority(attr.Max_priority);
		attr.set_policy(attr.Round_robin);

		!! mutex;
		!! cond.make;
		!! data;

		set_searching(False);
		set_terminated(False);

		launch_with_attributes(attr);
	end

feature -- Commands
	initialize(maxp, maxt: INTEGER; wantq: BOOLEAN) is
	do
		parm_maxp := maxp;
		parm_maxt := maxt;
		parm_wantq := wantq;

		set_searching(True);

		cmd := Cmd_init;
		cond.signal;

		from
		until
			not searching
		loop
			-- wait until not searching
		end
	end

	begin_search(cp: CHESS_POSITION; hist: CHESS_POSITION) is
	do
		set_searching(True);

		board := deep_clone(cp);
		saved_history := deep_clone(hist);

		cmd := Cmd_begin_search;
		cond.signal;
	end

	terminate is
	do
		set_searching(True);

		cmd := Cmd_terminate;
		cond.signal;
	end

feature -- Access
	item: CHESS_MOVE is
	do
		data.lock;
		Result := mt_item;
		data.unlock;
	end

	best_sequence: STRING is
	do
		data.lock;
		Result := mt_best_sequence;
		data.unlock;
	end

feature -- Status Report
	searching: BOOLEAN is
	do
		data.lock;
		Result := mt_searching;
		data.unlock;
	end

	terminated: BOOLEAN is
	do
		data.lock;
		Result := mt_terminated;
		data.unlock;
	end

	check_mate: BOOLEAN is
	do
		data.lock;
		Result := mt_check_mate;
		data.unlock;
	end

	stale_mate: BOOLEAN is
	do
		data.lock;
		Result := mt_stale_mate;
		data.unlock;
	end

	draw: BOOLEAN is
	do
		data.lock;
		Result := mt_draw;
		data.unlock;
	end

	statistics: CHESS_STATISTICS is
	do
		data.lock;
		Result := mt_statistics;
		data.unlock;
	end

feature {NONE} -- Implementation
	set_item(val: CHESS_MOVE) is
	do
		data.lock;
		mt_item := val;
		data.unlock;
	end

	set_check_mate(val: BOOLEAN) is
	do
		data.lock;
		mt_check_mate := val;
		data.unlock;
	end

	set_stale_mate(val: BOOLEAN) is
	do
		data.lock;
		mt_stale_mate := val;
		data.unlock;
	end

	set_draw(val: BOOLEAN) is
	do
		data.lock;
		mt_draw := val;
		data.unlock;
	end

	set_best_sequence(val: STRING) is
	do
		data.lock;
		mt_best_sequence := val;
		data.unlock;
	end

	set_statistics(val: CHESS_STATISTICS) is
	do
		data.lock;
		mt_statistics := val;
		data.unlock;
	end

	set_searching(val: BOOLEAN) is
	do
		data.lock;
		mt_searching := val;
		data.unlock;
	end

	set_terminated(val: BOOLEAN) is
	do
		data.lock;
		mt_terminated := val;
		data.unlock;
	end

	monitor_action is
	do
	end

feature {NONE} -- Implementation (routines)
	execute is
		-- called when thread is 'launched'
		-- this routine sits in a loop and waits on 'cond'
		-- when a signal occurs, wait completed.
		--
		-- Then we begin the search process, and
		-- when it completes we loop back and wait on 'cond' again.
	do
		from
			call_count := 0;
		until
			terminated
		loop
			-- wait to be activated
			mutex.lock;
			cond.wait(mutex);

			inspect cmd
			when Cmd_init then
				init(parm_maxp, parm_maxt, parm_wantq);

			when Cmd_begin_search then
				find_best_move(saved_history);

			when Cmd_terminate then
				set_terminated(True);
			end
	
			set_searching(False);
			mutex.unlock;

			call_count := call_count + 1;
		end
	end

feature {NONE} -- Implementation (attributes)
	--
	-- MT objects
	--
	data: MUTEX;
	mutex: MUTEX;
	cond: CONDITION_VARIABLE

	call_count: INTEGER;

	--
	-- These data items are protected by
	-- the 'data' mutex
	--
	mt_item: CHESS_MOVE;
	mt_best_sequence: STRING;
	mt_searching: BOOLEAN;
	mt_terminated: BOOLEAN;
	mt_check_mate: BOOLEAN;
	mt_stale_mate: BOOLEAN;
	mt_draw: BOOLEAN;
	mt_statistics: CHESS_STATISTICS;

	saved_history: CHESS_GAME_HISTORY;

	parm_maxp: INTEGER;
	parm_maxt: INTEGER;
	parm_wantq: BOOLEAN;

	cmd: INTEGER;
	Cmd_init: INTEGER is unique;
	Cmd_begin_search: INTEGER is unique;
	Cmd_terminate: INTEGER is unique;

end
