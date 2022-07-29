indexing
	description:	"describes information about the chess board"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

--
-- describes the pieces on the chess board, and the available moves
-- and the number and type of captured pieces
--

class CHESS_GUI_BOARD_INFO
inherit
	CHESS_SQUARE_CONSTANTS
	CHESS_PIECE_CONSTANTS

creation
	make, make_empty

feature -- Initialization
	make(game: CHESS_GAME; ply: INTEGER) is
	require
		game /= Void;
	do
		!! board.make(Min_square, Max_square);
		!! move_squares.make(Max_square, Max_square);
		!! promotion_squares.make(Max_square, Max_square);

		build_board(game, ply);
		build_captures(game, ply);
		build_move_squares(game, ply);
	end

	make_empty is
	do
		!! board.make(Min_square, Max_square);
		clear_board;

		!! move_squares.make(Max_square, Max_square);
		clear(move_squares);

		!! promotion_squares.make(Max_square, Max_square);
		clear(promotion_squares);

		!! black_captures.make;
		!! white_captures.make;
	end

feature -- Query valid moves
	can_move(src: INTEGER): BOOLEAN is
		-- can the piece at 'src' make a move?
	require
		valid_square(src);
	local
		i: INTEGER;
	do
		from
			Result := False;
			i := Min_square;
		until
			i > Max_square or Result
		loop
			if move_squares.item(src, i) then
				Result := True;
			end
			i := i + 1;
		end
	end

	valid_move(src, dst: INTEGER): BOOLEAN is
		-- is it valid to move a piece from 'src' to 'dst'
	require
		valid_square(src);
		valid_square(dst);
	do
		Result := move_squares.item(src, dst);
	end

	is_pawn_promotion(src, dst: INTEGER): BOOLEAN is
		-- moving a piece from 'src' to 'dst' is a pawn promotion
	require
		valid_square(src);
		valid_square(dst);
	do
		Result := promotion_squares.item(src, dst);
	end

feature -- Query squares and pieces
	occupied(square: INTEGER): BOOLEAN is
		-- does 'square' contain a piece?
	require
		valid_square(square);
	do
		if board.item(square) /= Piece_none then
			Result := True;
		else
			Result := False;
		end
	end

	piece_at(square: INTEGER): INTEGER is
		-- what is the piece at 'square'?
	require
		valid_square(square);
		occupied(square);
	do
		Result := board.item(square);
	ensure
		valid_piece(Result);
	end

feature -- Query captures
	num_captures(side: INTEGER): INTEGER is
		-- how many pieces has 'side' captured?
	require
		valid_piece_color(side);
	do
		if side = Chess_color_white then
			Result := white_captures.count;
		else
			Result := black_captures.count;
		end
	ensure
		Result >= 0 and Result <= 16;
	end

	capture(side, n: INTEGER): INTEGER is
		-- the n'th captured piece for 'side'
	require
		valid_piece_color(side);
		n >= 1 and n <= num_captures(side);
	do
		if side = Chess_color_white then
			Result := white_captures.i_th(n);
		else
			Result := black_captures.i_th(n);
		end

		Result := get_colored_piece(Result, get_opposite_color(side) );
	ensure
		valid_piece(Result)
	end

feature {NONE} -- Implementation
	board: ARRAY[ INTEGER ];
	white_captures: LINKED_LIST[ INTEGER ];
	black_captures: LINKED_LIST[ INTEGER ];
	move_squares: ARRAY2[ BOOLEAN ];
	promotion_squares: ARRAY2[ BOOLEAN ];

	build_board(game: CHESS_GAME; ply: INTEGER) is
	require
		game /= Void;
	local
		rank, file: INTEGER;
		piece, square: INTEGER;
	do
		from
			file := Min_file;
		until
			file > Max_file
		loop
			from
				rank := Min_rank;
			until
				rank > Max_rank
			loop
				piece := game.query_board(file, rank, ply);
				square := get_square(file, rank);

				board.put(piece, square);

				rank := rank + 1;
			end

			file := file + 1;
		end
	end

	build_captures(game: CHESS_GAME; ply: INTEGER) is
	require
		game /= Void;
	do
		white_captures := game.captures(Chess_color_white, ply);
		black_captures := game.captures(Chess_color_black, ply);
	end

	build_move_squares(game: CHESS_GAME; ply: INTEGER) is
	require
		game /= Void;
	local
		moves: LINKED_LIST[ CHESS_MOVE ];
		mov: CHESS_MOVE;
	do
		clear(move_squares);
		clear(promotion_squares);

		if ply = game.total_plies then
			moves := game.valid_moves;

			from
				moves.start;
			until
				moves.off
			loop
				mov := moves.item;
				move_squares.put(True, mov.src, mov.dst);

				if mov.is_pawn_promotion then
					promotion_squares.put(True, mov.src, mov.dst);
				end

				moves.forth;
			end
		end
	end

	clear(arr: ARRAY2[ BOOLEAN ]) is
	local
		src, dst: INTEGER;
	do
		-- ?? just call wipe_out???
		from
			src := Min_square;
		until
			src > Max_square
		loop
			from
				dst := Min_square;
			until
				dst > Max_square
			loop
				arr.put(False, src, dst);
				dst := dst + 1;
			end

			src := src + 1;
		end
	end

	clear_board is
	local
		square: INTEGER;
	do
		from
			square := Min_square;
		until
			square > Max_square
		loop
			board.put(Piece_none, square);
			square := square + 1;
		end
	end
end
