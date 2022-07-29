indexing
	description:	"move history heuristic table"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

--
-- This class implements the move history table. For
-- every CHESS_MOVE with a 'src' square and 'to' square
-- this table has a counter.
--
-- As we traverse the search space, we increment these counters
-- whenever a move causes an alpha-beta cutoff.
--
-- When iterating over the moves, we use the counters in
-- this class to order the moves, by the move with the highest
-- counter.
--
--
-- (see the paper, "History heuristic and other alpha-beta search
-- enhancements in practice" by J. Schaeffer).
--
--

class CHESS_MOVE_HISTORY
inherit
	ARRAY[ INTEGER ]
	rename
		make as ar_make,
		item as ar_item
	export
		{NONE} all
	undefine
		copy, is_equal
	end

	CHESS_SQUARE_CONSTANTS

creation
	make

feature -- Initialization
	make is
	do
		ar_make(1, Max_square * Max_square);
		clear_counters;
	end

feature -- Access
	item(m: CHESS_MOVE): INTEGER is
	require
		m /= Void;
		valid_square(m.src);
		valid_square(m.dst);
	do
		Result := ar_item( (m.src - 1) * Max_square + m.dst );
	end

feature -- Status Report
feature -- Status Setting

feature -- Element Change
	increment(m: CHESS_MOVE; depth: INTEGER) is
	require
		m /= Void;
		valid_square(m.src);
		valid_square(m.dst);
		depth > 0;
	local
		i, amount: INTEGER;
	do
		i := (m.src - 1) * Max_square + m.dst;

		amount := depth*depth;

		put( ar_item(i) + amount, i);
	end

feature -- Removal
	clear_counters is
		-- set all the counters to 0.
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
	end

	shrink_counters is
		-- reduce the counters by dividing by a constant amount
	local
		i: INTEGER;
	do
		from
			i := lower;
		until
			i > upper
		loop
			put(ar_item(i) // 256, i);
			i := i + 1;
		end
	end


feature {NONE} -- Implementation

end
