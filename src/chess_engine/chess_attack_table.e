indexing
	description:	"A table indexed by square (1..64) and color (1..2) that gives%
			% all the possible squares that can attack the indexed square"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

--
-- Each array element, is a CHESS_PATH_LIST. A path list is 1 or more "rays"
-- or set of squares that can attack the indexed square.
--
-- For example, if we index the array with the values ("h4", "white")
-- We get a path list with the following paths:
--
-- bishop/queen paths
--	DIAGONAL_NW:	G5, F6, E7, D8
--	DIAGONAL_SW:	G3, F2, E1
--
-- rook/queen paths
--	STRAIGHT_N:	H5, H6, H7, H8
--	STRAIGHT_W:	G4, F4, E4, D4, C4, B4, A4
--	STRAIGHT_S:	H3, H2, H1
--
-- knight path:
--	KNIGHT:		G6, F5, F3, G2
--
--	PAWN_CAPTURE:	G3	(white pawn attacks H4 from this square)
--
-- HOW TO USE:
-- We examine each square along the "ray" to look for attacking pieces
-- on that square. This structure contains paths for black and white
-- attacking pieces, the only difference is the PAWN_CAPTURE path, since
-- pawns only move in one direction
--
-- In the example above ("h4", "white"). If we have a white piece on
-- the square H4, then we must examine all the paths shown above.
--
-- In searching a path we are checking each square to make sure it is not
-- a certain kind of piece.
--
-- For example, if we find a queen/biship along one of these paths:
--	DIAGONAL_NW:	G5, F6, E7, D8
--	DIAGONAL_SW:	G3, F2, E1
--
-- We know that we are under attack. But if we encounter one of our own
-- pieces first, we know we are not under attack (along this path).
--
-- KNIGHT path's have slightly different logic, which you can
-- read about in CHESS_PATH_KNIGHT
--
--

class CHESS_ATTACK_TABLE
inherit
	ARRAY2[ CHESS_PATH_LIST ]
	rename
		make as ar_make
	export
		{NONE} all
	undefine
		copy, is_equal
	end

	CHESS_GENERAL_CONSTANTS
	CHESS_SQUARE_CONSTANTS
	CHESS_PIECE_CONSTANTS

creation
	make

feature -- Initialization
	make is
	local
		square: INTEGER;
		white_plist, black_plist: CHESS_PATH_LIST;
	do
		ar_make(Max_square, Chess_color_count);

		from
			square := Min_square;
		until
			square > Max_square
		loop
			!! white_plist.make;
			!! black_plist.make;

			add_diagonal_attack(white_plist, black_plist, square);
			add_straight_attack(white_plist, black_plist, square);
			add_knight_attack(white_plist, black_plist, square);
			add_pawn_attack(white_plist, black_plist, square);

			put(white_plist, square, Chess_color_white);
			put(black_plist, square, Chess_color_black);

			square := square + 1;
		end
	end

feature -- Access
	path_list(square, side: INTEGER): CHESS_PATH_LIST is
		-- a list of paths that pieces of color 'side' may
		-- attack 'square'
	require
		valid_square(square);
		valid_piece_color(side);
	do
		Result := item(square, side);
	ensure
		Result /= Void;
	end

feature -- Status Report
feature -- Status Setting
feature -- Element Change
feature -- Removal

feature {NONE} -- Implementation
	add_diagonal_attack(wlist, blist: CHESS_PATH_LIST; square: INTEGER) is
		-- generate all diagonal paths that originate at 'square'
		-- add those paths to wlist and blist
	require
		wlist /= Void;
		blist /= Void;
		valid_square(square);
	local
		nw: CHESS_PATH_DIAGONAL_NW;
		ne: CHESS_PATH_DIAGONAL_NE;
		sw: CHESS_PATH_DIAGONAL_SW;
		se: CHESS_PATH_DIAGONAL_SE;
	do
		!! nw.make(square);
		!! ne.make(square);
		!! sw.make(square);
		!! se.make(square);

		if nw.length /= 0 then
			wlist.extend(nw);
			blist.extend(nw);
		end

		if ne.length /= 0 then
			wlist.extend(ne);
			blist.extend(ne);
		end

		if sw.length /= 0 then
			wlist.extend(sw);
			blist.extend(sw);
		end

		if se.length /= 0 then
			wlist.extend(se);
			blist.extend(se);
		end
	end

	add_straight_attack(wlist, blist: CHESS_PATH_LIST; square: INTEGER) is
		-- add a straight attack paths originating at 'square' to
		-- wlist and blist.
	require
		wlist /= Void;
		blist /= Void;
		valid_square(square);
	local
		north: CHESS_PATH_STRAIGHT_N;
		south: CHESS_PATH_STRAIGHT_S;
		east: CHESS_PATH_STRAIGHT_E;
		west: CHESS_PATH_STRAIGHT_W;
	do
		!! north.make(square);
		!! south.make(square);
		!! east.make(square);
		!! west.make(square);

		if north.length /= 0 then
			wlist.extend(north);
			blist.extend(north);
		end

		if south.length /= 0 then
			wlist.extend(south);
			blist.extend(south);
		end

		if east.length /= 0 then
			wlist.extend(east);
			blist.extend(east);
		end

		if west.length /= 0 then
			wlist.extend(west);
			blist.extend(west);
		end
	end

	add_knight_attack(wlist, blist: CHESS_PATH_LIST; square: INTEGER) is
	require
		wlist /= Void;
		blist /= Void;
		valid_square(square);
	local
		knight: CHESS_PATH_KNIGHT;
	do
		!! knight.make(square);
		wlist.extend(knight);
		blist.extend(knight);
	end

	add_pawn_attack(wlist, blist: CHESS_PATH_LIST; square: INTEGER) is
		-- create the attack paths for pawns
		-- (NOTE: We don't handle e.p. capture detection, because
		-- the attack table is only concerned with things that
		-- can attack the KING, and e.p. capture cannot capture
		-- a king)
	require
		wlist /= Void;
		blist /= Void;
		valid_square(square);
	local
		pawn: CHESS_PATH_PAWN_CAPTURE;
	do
		!! pawn.make_attack(square, Chess_color_white);
		if pawn.length /= 0 then
			wlist.extend(pawn);
		end

		!! pawn.make_attack(square, Chess_color_black);
		if pawn.length /= 0 then
			blist.extend(pawn);
		end
		
	end

end
