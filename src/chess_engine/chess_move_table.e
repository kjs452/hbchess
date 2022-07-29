indexing
	description:	"A table to describe every possible move 'path'%
			% from any board square by any piece"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

--
-- This table is indexed by (square, piece). Indexing this array
-- with (H4, White_pawn) yields a CHESS_MOVE_SQUARE, that
-- includes a list of paths that this piece, on this square can move to.
--
-- CHESS_MOVE_SQUARE also includes other information, like hash_random values,
-- and positional score values.
--
-- This table is the primary data structure for generating valid chess moves.
-- All of the initalization that occurs inside of 'make' is intended to occur
-- only once for the whole system. This is accomplished by CHESS_BOARD_TABLES which
-- uses this class as a "once" client.
--
-- Hash keys:
--	We generate 2 32-bit random values for each piece/square combination.
--	The hash_key is used to index CHESS_TRANSPOSITION_TABLE for fast access
--	to previous search results. The hash_key_lock is a secondary hash key
--	that is used to verify that we retrieved the correct item.
--
-- Scores:
--	We assign a score and score_endgame to each piece/square combination
--	These values are added to our evaluation of a chess position. These
--	scores are relative to the color of the piece. positive values are good
--	for that piece on that square, and negative values are bad.
--
-- PURPOSE:
-- The purpose of this class is to be as *FAST* as possible. We use this
-- table to answer the question: "What moves can I make?"
--
-- Once we index this table by (square, piece) we immediatly have
-- a list of all squares that can contain enemy pieces. All we have
-- to do is follow the CHESS_PATH's looking for an enemy piece. If
-- we encounter one of our own, we are safe.
--
--

class CHESS_MOVE_TABLE
inherit
	ARRAY2[ CHESS_MOVE_SQUARE ]
	rename
		make as ar2_make
	export
		{ANY} item
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
	make is
	local
		square, piece: INTEGER;
		move_square: CHESS_MOVE_SQUARE;
		rnd: SCC_RANDOM;
		hash1, hash2: INTEGER;
	do
		!! rnd.make(Hash_seed);

		ar2_make(Square_count, Piece_count);

		from
			square := Min_square
		until
			square > Max_square
		loop
			--
			-- Add MOVE_SQUARE object to each row for
			-- each kind of chess piece.
			-- 
			from
				piece := Min_piece;
			until
				piece > Max_piece
			loop
				rnd.next;
				hash1 := rnd.item_range(Hash_min_value, Hash_max_value);
				rnd.next;
				hash2 := rnd.item_range(Hash_min_value, Hash_max_value);
				!! move_square.make(square, hash1, hash2);
				put(move_square, square, piece);
				piece := piece + 1;
			end

			add_diagonal_paths(square);
			add_straight_paths(square);
			add_knight_paths(square);
			add_king_paths(square);
			add_pawn_paths(square);

			square := square + 1;
		end

		-- setup scoring values
		set_pawn_scoring;
		set_knight_scoring;
		set_bishop_scoring;
		set_king_scoring;
	end

feature -- Access
feature -- Status Report
feature -- Status Setting
feature -- Element Change
feature -- Removal

feature {NONE} -- Implementation
	add_path(path: CHESS_PATH; square, piece: INTEGER) is
	require
		path /= Void and then path.length /= 0;
		valid_square(square);
		valid_piece(piece);
	local
		move_square: CHESS_MOVE_SQUARE;
	do
		move_square := item(square, piece);
		move_square.paths.extend(path);
	end

	add_diagonal_paths(square: INTEGER) is
	require
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

		--
		-- Add paths for WHITE pieces:
		-- (add north paths first, because white
		-- advances north to attack)
		--
		if nw.length /= 0 then
			add_path(nw, square, Piece_white_queen);
			add_path(nw, square, Piece_white_bishop);
		end

		if ne.length /= 0 then
			add_path(ne, square, Piece_white_queen);
			add_path(ne, square, Piece_white_bishop);
		end

		if sw.length /= 0 then
			add_path(sw, square, Piece_white_queen);
			add_path(sw, square, Piece_white_bishop);
		end

		if se.length /= 0 then
			add_path(se, square, Piece_white_queen);
			add_path(se, square, Piece_white_bishop);
		end

		--
		-- Add paths for BLACK pieces:
		-- reverse direction from above, so advancement
		-- paths are listed first (a slight move ordering
		-- optimization)
		--
		if sw.length /= 0 then
			add_path(sw, square, Piece_black_queen);
			add_path(sw, square, Piece_black_bishop);
		end

		if se.length /= 0 then
			add_path(se, square, Piece_black_queen);
			add_path(se, square, Piece_black_bishop);
		end

		if nw.length /= 0 then
			add_path(nw, square, Piece_black_queen);
			add_path(nw, square, Piece_black_bishop);
		end

		if ne.length /= 0 then
			add_path(ne, square, Piece_black_queen);
			add_path(ne, square, Piece_black_bishop);
		end
	end

	add_straight_paths(square: INTEGER) is
		-- queen's and rook's move alone a straight
		-- path. If 'square' is a starting
		-- square for a rook, then
		-- generate a special path, using
		-- special move types:
		--	Move_krook	- king side rook being moved
		--	Move_qrook	- queen side rook being moved
		--
	require
		valid_square(square);
	local
		north: CHESS_PATH_STRAIGHT_N;
		south: CHESS_PATH_STRAIGHT_S;
		east: CHESS_PATH_STRAIGHT_E;
		west: CHESS_PATH_STRAIGHT_W;

		rook_north: CHESS_PATH_STRAIGHT_N;
		rook_south: CHESS_PATH_STRAIGHT_S;
		rook_east: CHESS_PATH_STRAIGHT_E;
		rook_west: CHESS_PATH_STRAIGHT_W;
	do
		!! north.make(square);
		!! south.make(square);
		!! east.make(square);
		!! west.make(square);

		if (square = Square_A1) or (square = Square_A8) then
			--
			-- starting squares for queen-side rook
			--
			!! rook_north.make_with_type(square, Move_qrook);
			!! rook_south.make_with_type(square, Move_qrook);
			!! rook_east.make_with_type(square, Move_qrook);
			!! rook_west.make_with_type(square, Move_qrook);

		elseif (square = Square_H1) or (square = Square_H8) then
			--
			-- starting squares for king-side rook
			--
			!! rook_north.make_with_type(square, Move_krook);
			!! rook_south.make_with_type(square, Move_krook);
			!! rook_east.make_with_type(square, Move_krook);
			!! rook_west.make_with_type(square, Move_krook);

		else
			--
			-- in all other cases queen and rook pieces
			-- can share the same paths.
			--
			rook_north := north;
			rook_south := south;
			rook_east := east;
			rook_west := west;
		end

		check
			--
			-- straight paths for rook's and queens
			-- will always be the same length.
			--
			rook_north.length = north.length;
			rook_south.length = south.length;
			rook_east.length = east.length;
			rook_west.length = west.length;
		end

		--
		-- Add paths for WHITE pieces:
		-- (add north paths first, because white
		-- advances north to attack. South path last
		-- because that is a retreat.
		--
		if north.length /= 0 then
			add_path(north, square, Piece_white_queen);
			add_path(rook_north, square, Piece_white_rook);
		end

		if east.length /= 0 then
			add_path(east, square, Piece_white_queen);
			add_path(rook_east, square, Piece_white_rook);
		end

		if west.length /= 0 then
			add_path(west, square, Piece_white_queen);
			add_path(rook_west, square, Piece_white_rook);
		end

		if south.length /= 0 then
			add_path(south, square, Piece_white_queen);
			add_path(rook_south, square, Piece_white_rook);
		end

		--
		-- Add paths for BLACK pieces:
		-- reverse direction from above, so advancement
		-- paths are listed first.
		--
		if south.length /= 0 then
			add_path(south, square, Piece_black_queen);
			add_path(rook_south, square, Piece_black_rook);
		end

		if east.length /= 0 then
			add_path(east, square, Piece_black_queen);
			add_path(rook_east, square, Piece_black_rook);
		end

		if west.length /= 0 then
			add_path(west, square, Piece_black_queen);
			add_path(rook_west, square, Piece_black_rook);
		end

		if north.length /= 0 then
			add_path(north, square, Piece_black_queen);
			add_path(rook_north, square, Piece_black_rook);
		end
	end

	add_knight_paths(square: INTEGER) is
	require
		valid_square(square);
	local
		knight: CHESS_PATH_KNIGHT;
	do
		!! knight.make(square);

		if knight.length /= 0 then
			add_path(knight, square, Piece_white_knight);
			add_path(knight, square, Piece_black_knight);
		end
	end

	add_king_paths(square: INTEGER) is
	require
		valid_square(square);
	local
		king: CHESS_PATH_KING;
		castle: CHESS_PATH_CASTLE;
		rank: INTEGER;
	do
		!! king.make(square);
		!! castle.make(square);

		if king.length /= 0 then
			add_path(king, square, Piece_white_king);
			add_path(king, square, Piece_black_king);
		end

		--
		-- Castle path's only exist for the two initial positions
		-- for the black/white king's.
		--
		if castle.length /= 0 then
			rank := get_rank(square);
			if rank = Rank_1 then
				add_path(castle, square, Piece_white_king);
			else
				add_path(castle, square, Piece_black_king);
			end
		end
	end

	--
	-- On squares on rank_5, there will be an ep_capture
	-- path for white pawns
	--
	-- On square on rank_4, the black_pawn has an ep_capture
	-- path.
	--
	-- squares on Rank_7, involve promotion for white pawns.
	--
	-- squares on Rank_2, involve promotion for black pawns.
	--
	add_pawn_paths(square: INTEGER) is
	require
		valid_square(square);
	local
		rank: INTEGER;
	do
		rank := get_rank(square);

		if rank = Rank_7 then
			add_pawn_promotion_paths(square, Chess_color_white);
		else
			add_pawn_normal_paths(square, Chess_color_white);
		end

		if rank = Rank_2 then
			add_pawn_promotion_paths(square, Chess_color_black);
		else
			add_pawn_normal_paths(square, Chess_color_black);
		end

		add_pawn_ep_paths(square, Chess_color_white);
		add_pawn_ep_paths(square, Chess_color_black);
	end

	add_pawn_promotion_paths(square, color: INTEGER) is
		-- add a path for squares on rank_7 and rank_2
		-- that apply to pawns that will be promoted.
	require
		valid_square(square);
		valid_piece_color(color);
		(get_rank(square) = Rank_7)
				or (get_rank(square) = Rank_2);
	local
		pawn_promote: CHESS_PATH_PAWN_PROMOTE;
		pawn_capture_promote: CHESS_PATH_PAWN_CAPTURE_AND_PROMOTE;

		piece: INTEGER;
	do
		piece := get_colored_piece(Piece_type_pawn, color);

		!! pawn_promote.make(square, color);
		!! pawn_capture_promote.make(square, color);

		if pawn_promote.length /= 0 then
			add_path(pawn_promote, square, piece);
		end

		if pawn_capture_promote.length /= 0 then
			add_path(pawn_capture_promote, square, piece);
		end
	end

	add_pawn_normal_paths(square, color: INTEGER) is
	require
		valid_square(square);
		valid_piece_color(color);
	local
		pawn: CHESS_PATH_PAWN;
		pawn_capture: CHESS_PATH_PAWN_CAPTURE;

		piece: INTEGER;
	do
		piece := get_colored_piece(Piece_type_pawn, color);

		!! pawn.make(square, color);
		!! pawn_capture.make(square, color);

		if pawn.length /= 0 then
			add_path(pawn, square, piece);
		end

		if pawn_capture.length /= 0 then
			add_path(pawn_capture, square, piece);
		end
	end

	add_pawn_ep_paths(square, color: INTEGER) is
	require
		valid_square(square);
		valid_piece_color(color);
	local
		pawn_ep: CHESS_PATH_PAWN_EP;
		piece: INTEGER;
	do
		piece := get_colored_piece(Piece_type_pawn, color);

		!! pawn_ep.make(square, color);

		if pawn_ep.length /= 0 then
			add_path(pawn_ep, square, piece);
		end
	end

	flip_square(square: INTEGER): INTEGER is
		-- flip square for obtaining the correct
		-- index for white pieces into the scoring arrays.
	require
		valid_square(square);
	local
		rank, file: INTEGER;
	do
		--
		-- file stays the same
		--
		file := get_file(square);

		--
		-- rank gets flipped:
		--	1 becomes 8,
		--	2 becomes 7,
		--	etc...
		--
		rank := get_rank(square);
		rank := (Max_rank - rank) + 1;

		Result := get_square(file, rank);
	ensure
		valid_square(Result);
	end

	--
	-- Assigns scores for both black and white pieces of 'piece_type
	-- (We use the 'flip_square' operation to transform white squares)
	--
	add_scoring(scores, scores_endgame: ARRAY[ INTEGER ]; piece_type: INTEGER) is
	require
		scores /= Void;
		scores_endgame /= Void;
		valid_piece_type(piece_type);
	local
		square, flipped: INTEGER;
		black_piece, white_piece: INTEGER;
		move_square: CHESS_MOVE_SQUARE;
	do
		white_piece := get_colored_piece(piece_type, Chess_color_white);
		black_piece := get_colored_piece(piece_type, Chess_color_black);

		from
			square := Min_square;
		until
			square > Max_square
		loop
			flipped := flip_square(square);

			move_square := item(square, white_piece);
			move_square.set_score(
					scores.item(flipped),
					scores_endgame.item(flipped) );

			move_square := item(square, black_piece);
			move_square.set_score(
					scores.item(square),
					scores_endgame.item(square) );

			square := square + 1;
		end
	end

	--
	-- SCORING TABLES:
	-- (Copied from Tom Kerrigan's Simple Chess Program (TSCP))
	--
	-- These tables are relative to BLACK piece placement, but
	-- these score values are symmetrical. To obtain the white score
	-- flip the rank of the square and assign to the flipped square.
	--
	-- During endgame we use the values in the 'y' table.
	--
	set_pawn_scoring is
	local
		x, y: ARRAY[ INTEGER ];
	do
		     --
		     -- A    B    C    D    E    F    G    H
		     --
		x := <<	0,   0,   0,   0,   0,   0,   0,   0,	  -- rank 1
			5,  10,  15,  20,  20,  15,  10,   5,	  -- rank 2
			4,   8,  12,  16,  16,  12,   8,   4,	  -- rank 3
			3,   6,   9,  12,  12,   9,   6,   3,	  -- rank 4
			2,   4,   6,   8,   8,   6,   4,   2,	  -- rank 5
			1,   2,   3, -10, -10,   3,   2,   1,	  -- rank 6
			0,   0,   0, -40, -40,   0,   0,   0,	  -- rank 7
			0,   0,   0,   0,   0,   0,   0,   0 >>;  -- rank 8

			-- end game table
		y := <<	0,   0,   0,   0,   0,   0,   0,   0,
			15, 15,  15,  20,  20,  15,  15,  15,
			12, 12,  12,  16,  16,  12,  12,  12,
			10, 10,  10,  12,  12,  10,  10,  10,
			6,   6,   6,   8,   8,   6,   6,   6,
			5,   5,   5, -10, -10,   5,   5,   5,
			5,   5,   5, -40, -40,   5,   5,   5,
			0,   0,   0,   0,   0,   0,   0,   0 >>;

		add_scoring(x, y, Piece_type_pawn);
	end

	set_knight_scoring is
	local
		x, y: ARRAY[ INTEGER ];
	do
		x := <<	-10, -10, -10, -10, -10, -10, -10, -10,
			-10,   0,   0,   0,   0,   0,   0, -10,
			-10,   0,   5,   5,   5,   5,   0, -10,
			-10,   0,   5,  10,  10,   5,   0, -10,
			-10,   0,   5,  10,  10,   5,   0, -10,
			-10,   0,   5,   5,   5,   5,   0, -10,
			-10,   0,   0,   0,   0,   0,   0, -10,
			-10, -30, -10, -10, -10, -10, -30, -10	>>;

		y := <<	0,   0,   0,   0,   0,   0,   0,   0,
			0,   0,   0,   0,   0,   0,   0,   0,
			0,   0,   0,   0,   0,   0,   0,   0,
			0,   0,   0,   0,   0,   0,   0,   0,
			0,   0,   0,   0,   0,   0,   0,   0,
			0,   0,   0,   0,   0,   0,   0,   0,
			0,   0,   0,   0,   0,   0,   0,   0,
			0,   0,   0,   0,   0,   0,   0,   0  >>;

		add_scoring(x, y, Piece_type_knight);
	end

	set_bishop_scoring is
	local
		x, y: ARRAY[ INTEGER ];
	do
		x := <<	-10, -10, -10, -10, -10, -10, -10, -10,
			-10,   0,   0,   0,   0,   0,   0, -10,
			-10,   0,   5,   5,   5,   5,   0, -10,
			-10,   0,   5,  10,  10,   5,   0, -10,
			-10,   0,   5,  10,  10,   5,   0, -10,
			-10,   0,   5,   5,   5,   5,   0, -10,
			-10,   0,   0,   0,   0,   0,   0, -10,
			-10, -10, -20, -10, -10, -20, -10, -10	>>;

		y := <<	0,   0,   0,   0,   0,   0,   0,   0,
			0,   0,   0,   0,   0,   0,   0,   0,
			0,   0,   0,   0,   0,   0,   0,   0,
			0,   0,   0,   0,   0,   0,   0,   0,
			0,   0,   0,   0,   0,   0,   0,   0,
			0,   0,   0,   0,   0,   0,   0,   0,
			0,   0,   0,   0,   0,   0,   0,   0,
			0,   0,   0,   0,   0,   0,   0,   0  >>;

		add_scoring(x, y, Piece_type_bishop);
	end

	set_king_scoring is
	local
		x, y: ARRAY[ INTEGER ];
	do
		x := <<	-40, -40, -40, -40, -40, -40, -40, -40,
			-40, -40, -40, -40, -40, -40, -40, -40,
			-40, -40, -40, -40, -40, -40, -40, -40,
			-40, -40, -40, -40, -40, -40, -40, -40,
			-40, -40, -40, -40, -40, -40, -40, -40,
			-40, -40, -40, -40, -40, -40, -40, -40,
			-20, -20, -20, -20, -20, -20, -20, -20,
			  0,  20,  40, -20,   0, -20,  40,  20	>>;

		y := <<	 0,  10,  20,  30,  30,  20,  10,   0,
			10,  20,  30,  40,  40,  30,  20,  10,
			20,  30,  40,  50,  50,  40,  30,  20,
			30,  40,  50,  60,  60,  50,  40,  30,
			30,  40,  50,  60,  60,  50,  40,  30,
			20,  30,  40,  50,  50,  40,  30,  20,
			10,  20,  30,  40,  40,  30,  20,  10,
			 0,  10,  20,  30,  30,  20,  10,   0	>>;

		add_scoring(x, y, Piece_type_king);
	end

end
