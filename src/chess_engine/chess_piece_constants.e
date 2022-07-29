indexing
	description:	"Describes a chess piece including its color"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

--
-- This class defined several constants:
--	Piece colors		1..2
--	Piece values
--	Piece types		1..6
--	Piece/color types 	1..12
--
-- Our chess engine stores a piece/color constant in
-- the CHESS_BOARD object. This is an accurate representation
-- of all the pieces and which color they are.
--
--
class CHESS_PIECE_CONSTANTS

feature {NONE} -- Access
	--
	-- Piece colors
	--
	Chess_color_white: INTEGER is 1;
	Chess_color_black: INTEGER is 2;
	Chess_color_count: INTEGER is 2;

	--
	-- Chess Piece valuations
	--
	Piece_value_pawn: INTEGER is 100
	Piece_value_bishop: INTEGER is 325
	Piece_value_knight: INTEGER is 300
	Piece_value_rook: INTEGER is 500
	Piece_value_queen: INTEGER is 900
	Piece_value_king: INTEGER is 0

	--
	-- Chess Piece types
	--
	Piece_type_none: INTEGER is 0

	Piece_type_pawn: INTEGER is 1
	Piece_type_bishop: INTEGER is 2
	Piece_type_knight: INTEGER is 3
	Piece_type_rook: INTEGER is 4
	Piece_type_queen: INTEGER is 5
	Piece_type_king: INTEGER is 6

	Piece_type_count: INTEGER is 6 -- number of piece types

	--
	-- Piece AND color index values
	--
	Min_piece: INTEGER is 1
	Max_piece: INTEGER is 12
	Piece_none: INTEGER is 0

	Piece_white_pawn: INTEGER is 1
	Piece_white_bishop: INTEGER is 2
	Piece_white_knight: INTEGER is 3
	Piece_white_rook: INTEGER is 4
	Piece_white_queen: INTEGER is 5
	Piece_white_king: INTEGER is 6

	Piece_black_pawn: INTEGER is 7
	Piece_black_bishop: INTEGER is 8
	Piece_black_knight: INTEGER is 9
	Piece_black_rook: INTEGER is 10
	Piece_black_queen: INTEGER is 11
	Piece_black_king: INTEGER is 12

	Piece_count: INTEGER is 12

feature -- Status Report
	valid_piece_color(c: INTEGER): BOOLEAN is
	do
		Result := (c = Chess_color_white) or (c = Chess_color_black);
	end

	get_opposite_color(c: INTEGER): INTEGER is
		-- white becomes black, and black becomes white
		-- (see Michael Jackson for details)
	require
		valid_piece_color(c)
	do
		if c = Chess_color_white then
			Result := Chess_color_black;
		else
			Result := Chess_color_white;
		end
	ensure
		valid_piece_color(Result)
	end

	valid_piece_type(p: INTEGER): BOOLEAN is
	do
		Result := (p >= Piece_type_pawn) and (p <= Piece_type_king);
	end

	get_piece_value(p: INTEGER): INTEGER is
		-- a material value assigned to piece 'p'
		-- queen is 900, pawn is 100, etc...
	require
		valid_piece_type(p);
	do
		inspect p
		when Piece_type_pawn then
			Result := Piece_value_pawn;
		when Piece_type_bishop then
			Result := Piece_value_bishop;
		when Piece_type_knight then
			Result := Piece_value_knight;
		when Piece_type_rook then
			Result := Piece_value_rook;
		when Piece_type_queen then
			Result := Piece_value_queen;
		when Piece_type_king then
			Result := Piece_value_king;
		end
	end

	valid_piece(piece: INTEGER): BOOLEAN is
	do
		Result := (piece >= Piece_white_pawn) and
				(piece <= Piece_black_king);
	end

	get_colored_piece(piece_type, color: INTEGER): INTEGER is
	require
		valid_piece_type(piece_type);
		valid_piece_color(color);
	do
		Result := ((color-1) * Piece_type_count) + piece_type;
	ensure
		valid_piece(Result);
	end

	get_piece_color(piece: INTEGER): INTEGER is
	do
		if piece > Piece_type_count then
			Result := Chess_color_black;
		else
			Result := Chess_color_white;
		end
	ensure
		valid_piece_color(Result);
	end

	get_piece_type(piece: INTEGER): INTEGER is
	do
		if piece > Piece_type_count then
			Result := piece - Piece_type_count;
		else
			Result := piece;
		end
	ensure
		valid_piece(Result);
	end

	enemy_pieces(p1, p2: INTEGER): BOOLEAN is
		-- do pieces 'p1' and 'p2' have opposite colors
	require
		valid_piece(p1);
		valid_piece(p2);
	do
		Result := get_piece_color(p1) /= get_piece_color(p2);
	end

	piece_color_to_string(color: INTEGER): STRING is
	require
		valid_piece_color(color);
	do
		if color = Chess_color_white then
			Result := "White";
		else
			Result := "Black";
		end
	end

	piece_to_string(piece: INTEGER): STRING is
	require
		valid_piece(piece);
	local
	do
		Result := piece_type_to_string( get_piece_type(piece) );
		if get_piece_color(piece) = Chess_color_black then
			Result.to_lower;
		end
	ensure
		Result /= Void;
	end

	piece_type_to_string(piece_type: INTEGER): STRING is
		-- Convert piece_type to string, e.g. "N", "P", "Q"
	require
		valid_piece_type(piece_type)
	do
		inspect piece_type
		when Piece_type_pawn then
			Result := "P";
		when Piece_type_bishop then
			Result := "B";
		when Piece_type_knight then
			Result := "N";
		when Piece_type_rook then
			Result := "R";
		when Piece_type_queen then
			Result := "Q";
		when Piece_type_king then
			Result := "K";
		end
	ensure
		Result /= Void and then Result.count = 1
	end

end
