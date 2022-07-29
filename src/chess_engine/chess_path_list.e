indexing
	description:	"A list of CHESS_PATH's"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

--
-- This is a list of CHESS_PATH's, implemented as a
-- arrayed list of CHESS_PATH's. This implementation
-- allows the array to be dynamically extended as we insert
-- paths during initialization time.
--

class CHESS_PATH_LIST
inherit
	CHESS_PATH
	redefine
		under_attack, attacking_squares
	end

	ARRAYED_LIST[ CHESS_PATH ]
	rename
		make as al_make
	export
		{ANY} extend, item, upper, lower, go_i_th
		{NONE} all
	undefine
		copy, is_equal
	end

creation
	make

feature -- Initialization
	make is
	do
		al_make(0);
	end

feature -- Access
	length: INTEGER is
	do
		Result := count;
	end

feature -- Status Report
	generate_moves(cp: CHESS_POSITION; square, piece: INTEGER;
				mq, cq: CHESS_MOVE_QUEUE) is
	do
		from
			start;
		until
			off
		loop
			item.generate_moves(cp, square, piece, mq, cq);
			forth;
		end
	end

	under_attack(cp: CHESS_POSITION; side: INTEGER): BOOLEAN is
		-- Does any of the paths in this path list contain
		-- a piece of color 'side' that can attack?
	do
		from
			Result := False;
			start;
		until
			off or Result
		loop
			if item.under_attack(cp, side) then
				Result := True;
			end
			forth;
		end
	end

	attacking_squares(cp: CHESS_POSITION; side: INTEGER): LINKED_LIST[INTEGER] is
		-- list of squares that contain pieces of color 'side' that
		-- can attack along a path in the path list.
	local
		lst: LINKED_LIST[ INTEGER ];
	do
		!! Result.make;
		from
			start;
		until
			off
		loop
			lst := item.attacking_squares(cp, side);

			--
			-- Append items to end of our list
			--
			Result.merge_right(lst);
			Result.finish;

			forth;
		end
	end

feature -- Status Setting
feature -- Element Change
feature -- Removal
feature {NONE} -- Implementation

end
