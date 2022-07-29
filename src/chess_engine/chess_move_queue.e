indexing
	description:	"A queue for producing/consuming chess moves"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

--
-- The move generator produces moves and inserts them into this queue.
-- Then, the search algorithm removes chess moves one at a time from
-- such a queue.
--
-- The move generation is semi-incremental, when the consumer
-- needs a move, we check the queue(s) for available moves. If
-- The queue(s) are empty, we continue our move generation
-- to obtain more chess moves. This way we don't have to generate
-- all moves up front.
--
-- We can also sort moves by "capture" "promotion" or "normal moves"
--
-- This move generator can also generate captures-only, and
-- other options.
--
-- This queue is implemented as an ARRAY, we want to avoid
-- allocating objects dynamicaly during the chess search (for
-- performance reasons). This class will pre-allocate all the
-- slots in the queue with CHESS_MOVE's.
--
-- When we insert, we just copy the MOVE into that slot (rather
-- than dynamically allocate an object)
--
--

class CHESS_MOVE_QUEUE
inherit
	ARRAY[ CHESS_MOVE ]
	rename
		make as ar_make,
		item as ar_item,
		put as ar_put,
		count as ar_count,
		empty as ar_empty,
		wipe_out as ar_wipe_out
	export
		{NONE} all
	undefine
		copy, is_equal
	end

	CHESS_GENERAL_CONSTANTS
	CHESS_SQUARE_CONSTANTS
	CHESS_PIECE_CONSTANTS
	CHESS_MOVE_CONSTANTS

creation
	make

feature -- Initialization
	make(n: INTEGER) is
	require
		n >= 0;
	do
		ar_make(1, n);
		fill_void_slots;

		in_index := lower;
		out_index := lower;
	ensure
		empty;
	end

feature -- Measurement
	count: INTEGER is
		-- Number of items.
	do
		Result := (in_index - out_index);
	end

feature -- Status Report
	empty: BOOLEAN is
		-- No more items in queue.
	do
		Result := (in_index = out_index);
	end

feature -- Access
	item: CHESS_MOVE is
		-- Oldest item.
	require
		not empty;
	do
		Result := ar_item(out_index);
	ensure
		Result /= Void;
	end

feature -- Status Setting

feature -- Element Change
	put(type, piece, src, dst: INTEGER) is
		-- add CHESS_MOVE defined by type, piece, src, dst
		-- as newest element.
		--
		-- No dynamic allocation occurs here.
		-- We simply modify the CHESS_MOVE that is already
		-- referenced by the array.
	require
		valid_move_type(type);
		valid_piece(piece);
		valid_square(src);
		valid_square(dst);
	local
		mov: CHESS_MOVE;
	do
		mov := ar_item(in_index);
		mov.make(type, piece, src, dst);

		in_index := in_index + 1;
		if in_index > upper then
			resize(lower, upper + Grow_amount);
			fill_void_slots;
		end
	end

	sort(cp: CHESS_POSITION) is
		-- sort move's in the queue, based on MVV/LVA sort criteria
		-- (See: CHESS_MOVE.less_valuable)
		-- Uses a 'selection sort'
	require
		cp /= Void;
	do
		if count >= 2 then
			sel_sort(cp);
		end
	end

	bring_best_to_front(mhist: CHESS_MOVE_HISTORY) is
		-- find the move with the highest count
		-- from the move history table 'mhist'.
		--
		-- Put this move at the beginnig of the queue.
	require
		mhist /= Void;
	local
		i, best_index: INTEGER;
		best_value, value: INTEGER;
		m: CHESS_MOVE;
	do
		if count >= 2 then
			from
				best_value := 0;
				best_index := 0;
				i := out_index;
			until
				i >= in_index
			loop
				m := ar_item(i);

				value := mhist.item(m);
				if value > best_value then
					best_value := value;
					best_index := i;
				end

				i := i + 1;
			end

			if best_index /= 0 then
				swap(out_index, best_index);
			end
		end
	end

	bring_move_to_front(mov: CHESS_MOVE): BOOLEAN is
		-- scan the queue, and if 'mov' is found
		-- in the queue, then move it to the front of
		-- the queue, by swapping it with the first
		-- item in the queue.
		--
		-- Returns TRUE is 'mov' exists in the queue
		-- and it was moved to the front.
	require
		mov /= Void;
	local
		i: INTEGER;
		m: CHESS_MOVE;
	do
		if count >= 2 then
			from
				Result := False;
				i := out_index;
			until
				i >= in_index or else Result
			loop
				m := ar_item(i);

				if m.is_equal(mov) then
					Result := True;
					swap(out_index, i);
				end
				i := i + 1;
			end
		end
	end

feature -- Removal
	remove is
		-- Remove oldest item
	require
		not empty;
	do
		out_index := out_index + 1;
	end

	wipe_out is
		-- remove all items
	do
		in_index := lower;
		out_index := lower;
	end

feature {NONE} -- Implementation
	Grow_amount: INTEGER is 10;
	in_index: INTEGER;
	out_index: INTEGER;

feature {NONE} -- Implementation
	sel_sort(cp: CHESS_POSITION) is
		-- sort move's in the queue, based on MVV/LVA sort criteria
		-- (See: CHESS_MOVE.less_valuable)
		--
		-- Uses a 'selection sort'
	require
		cp /= Void;
		count >= 2;
	local
		i, j, min_idx: INTEGER;
		mov_min, mov_j: CHESS_MOVE;
	do
		from
			i := out_index;
		until
			(i + 1) = in_index
		loop
			from
				min_idx := i;
				j := i + 1;
			until
				j = in_index
			loop
				mov_j := ar_item(j);
				mov_min := ar_item(min_idx);

				if mov_j.more_valuable(cp, mov_min) then
					min_idx := j;
				end

				j := j + 1;
			end

			swap(i, min_idx);

			i := i + 1;
		end
	end

	swap(i, j: INTEGER) is
		-- swap queue elements 'i' and 'j'
	local
		tmp: CHESS_MOVE;
	do
		tmp := ar_item(i);
		ar_put(ar_item(j), i);
		ar_put(tmp, j);
	end

	fill_void_slots is
		-- Create CHESS_MOVE objects to fill all the void entries in
		-- the array.
	local
		mov: CHESS_MOVE;
		i: INTEGER;
	do
		from
			i := lower;
		until
			i > upper
		loop
			if ar_item(i) = Void then
				!! mov.make_empty;
				ar_put(mov, i);
			end

			i := i + 1;
		end
	end

end
