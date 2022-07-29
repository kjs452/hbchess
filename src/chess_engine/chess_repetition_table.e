indexing
	description:	"a table of chess position keys, for detection%
			% of repeated moves"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

--
-- This is a simple hash table structure that
-- remembers hash lock keys (which represent chess positions).
--
-- We use this table to record when we encounter a position during
-- the chess search, and if we encounter the same position, we
-- can return a draw score (value=0) so that our chess
-- engine will ignore this position the 2nd, 3rd, 4th, time around, etc..
--
-- This structure has about 2,000 elements. The chess search algorthm
-- will never search beyond 100 moves in a single recursive search.
-- (actually the number is closer to 5 to 20)
--
-- This means this table will be mostly empty slots with a value of '0'.
-- (no more than 100 entries). We use this fact to resolve hash
-- collisions. We scan ahead one slot at a time for an empty slot..
--
-- Set algorithm:
-- 1. We hash the chess position and find the slot into this table.
-- 2. If a non-zero entry exists, we look at the next slot index.
-- 3. If that slot is also non-zero, we keep going until we
--    find an empty slot.
--    (Since this table will never get filled, we are sure to find an empty slot.)
-- 4. Store the hash_lock_key in this slot.
--
-- Clear algorithm:
-- Hash the chess position, and search for the hash_lock_key.
-- (it must already exist in the table).
--
-- This data structure must be called in a FILO (first in, last out)
-- manner. If you call set in this order:
--	set(A)
--	set(B)
--	set(C)
--
-- Then you must call clear in this order:
--	clear(C)
--	clear(B)
--	clear(A)
--
-- The reason FILO ordering is crucial is because
-- when 'clear' is called it must be applied to the same table
-- layout that existed when 'set' was called, otherwise we
-- may not find the entry.
--
-- NOTE: It is acceptable to insert the same position twice, for example:
--
--	set(A)
--	set(B)
--	set(A)
--	...
--	clear(A)
--	clear(B)
--	clear(A)
--
--

class CHESS_REPETITION_TABLE
inherit
	ARRAY[ INTEGER ]
	rename
		make as ar_make,
		has as ar_has,
		full as ar_full,
		is_empty as ar_is_empty
	export
		{NONE} all
	undefine
		copy, is_equal
	redefine
		clear_all
	end

	CHESS_GENERAL_CONSTANTS

creation
	make

feature -- Initialization
	make is
	do
		ar_make(1, Repetition_size);
		clear_all;
	end

feature -- Access
feature -- Status Report
	has(cp: CHESS_POSITION): BOOLEAN is
		-- does the table contain the hash lock for 'cp'????
	require
		cp /= Void;
	local
		i: INTEGER;
		done: BOOLEAN;
	do
		from
			Result := False;
			i := table_index(cp.hash_key);
			done := False;
		until
			done
		loop
			if item(i) = cp.hash_lock_key then
				Result := True;
				done := True;
			elseif item(i) = 0 then
				done := True;
			else
				i := i + 1;
				if i > upper then
					i := lower;
				end

				check
					-- did we wrap to beginning of the search?
					-- If yes, then table is full, and it
					-- shouldn't be.
					i /= table_index(cp.hash_key);
				end
			end
		end
	end

	is_empty: BOOLEAN is
	do
		Result := (slots_in_use = 0);
	end

	full: BOOLEAN is
	do
		Result := (slots_in_use = count);
	end

feature -- Status Setting
feature -- Element Change
	set(cp: CHESS_POSITION) is
		-- insert the hash lock value for 'cp' into
		-- the repetition table.
	require
		cp /= Void;
		not full;
	do
		store(cp.hash_key, cp.hash_lock_key, True);
	end

feature -- Removal
	clear(cp: CHESS_POSITION) is
		-- remove the hash lock value for 'cp' from
		-- the repetition table.
	require
		cp /= Void;
		not is_empty;
		has(cp);
	do
		store(cp.hash_key, cp.hash_lock_key, False);
	ensure
		not full;
	end

	clear_all is
		-- clear the entire table, this should 
		-- be called before each search operation.
	local
		i: INTEGER;
	do
		from
			i := lower;
		until
			i > upper
		loop
			put(0, i);
			i := i + 1;
		end
		slots_in_use := 0;
	end

feature {NONE} -- Implementation (routines)
	table_index(h: INTEGER): INTEGER is
	do
		Result := (h \\ upper) + 1;
	ensure
		(Result >= lower) and (Result <= upper);
	end

	store(hash_key, value: INTEGER; inserting: BOOLEAN) is
		-- find an empty slot and store 'value' at that location
		--
		-- If 'inserting' is set, we want to
		-- find the next non-empty slot and
		-- store 'value'.
		--
		-- If 'inserting' is false, we want to
		-- delete the 'value' from the table.
		--
	require
		hash_key /= 0;
		value /= 0;
		not inserting implies not is_empty;
		inserting implies not full;
	local
		i: INTEGER;
		done: BOOLEAN;
		seek_val, store_val: INTEGER;
	do
		if inserting then
			seek_val := 0;
			store_val := value;
		else
			seek_val := value;
			store_val := 0;
		end

		from
			done := False;
			i := table_index(hash_key);
		until
			done
		loop
			if item(i) = seek_val then
				put(store_val, i);
				done := True;
			else
				i := i + 1;
				if i > upper then
					i := lower;
				end
			end
		end

		if inserting then
			slots_in_use := slots_in_use + 1;
		else
			slots_in_use := slots_in_use - 1;
		end
	end

feature {NONE} -- Implementation (attributes)
	slots_in_use: INTEGER;

end
