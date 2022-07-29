indexing
	description:	"Additional information associated with a CHESS_POSITION"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

--
-- This class contains all the state information associated with
-- a chess position. Contains: Castling rights, fifty move counter,
-- e.p. capture square and last captured piece
--
-- When we apply a chess move to a CHESS_POSITION, we want to
-- keep a copy of this state information, so that we easily undo
-- a move.
--

class CHESS_STATE
inherit
	CHESS_GENERAL_CONSTANTS
	CHESS_PIECE_CONSTANTS
	CHESS_SQUARE_CONSTANTS
	CHESS_BOARD_TABLES

creation
	make

feature -- Initialization
	make is
	do
		double_move_white := No_square_specified;
		double_move_black := No_square_specified;

		white_kingside := True;
		white_queenside := True;
		black_kingside := True;
		black_queenside := True;

		clear_capture;
		reset_fifty_counter;
	end

feature -- Access
	--
	-- Set to the square the last pawn moved 2 squares forward to.
	--
	double_move_white: INTEGER;
	double_move_black: INTEGER;

	--
	-- Stores the castling rights for each side.
	--
	white_kingside: BOOLEAN;
	white_queenside: BOOLEAN;

	black_kingside: BOOLEAN;
	black_queenside: BOOLEAN;

	--
	-- After a move, this is set to the square & piece that was
	-- captured (if any). For moves that are not a capture, this
	-- is set to: No_square_specified/Piece_none.
	--
	capture_square: INTEGER;
	capture_piece: INTEGER;

	--
	-- Every move increments this counter. But captures, and
	-- pawn moves will reset this counter. When 50 is reached
	-- either side may call a draw to the game.
	--
	fifty_counter: INTEGER;

	hash_value: INTEGER is
		-- A wierd value that is added to the CHESS_POSITION hash
		-- values.
		-- (Our hash values need to include the Castling rights
		-- and e.p. square values.)
	do
		if double_move_white /= No_square_specified then
			Result := Result + double_move_white * 1_234_555;
		end

		if double_move_black /= No_square_specified then
			Result := Result + double_move_black * 2_234_555;
		end

		if white_kingside then
			Result := Result + 1_434_222;
		end

		if white_queenside then
			Result := Result + 2_934_555;
		end

		if black_kingside then
			Result := Result + 234_111;
		end

		if black_queenside then
			Result := Result + 334_000;
		end
	end


feature -- Status Report

	can_castle_any(side: INTEGER): BOOLEAN is
		-- can 'side' perform any castling?
	require
		valid_piece_color(side);
	do
		if side = Chess_color_white then
			Result := (white_queenside or white_kingside);
		else
			Result := (black_queenside or black_kingside);
		end
	end

	can_kcastle(side: INTEGER): BOOLEAN is
		-- is 'side' allowed to perform a king-side castle?
	require
		valid_piece_color(side);
	do
		if side = Chess_color_white then
			Result := white_kingside;
		else
			Result := black_kingside;
		end
	end

	can_qcastle(side: INTEGER): BOOLEAN is
		-- is 'side' allowed to perform a queen-side castle?
	require
		valid_piece_color(side);
	do
		if side = Chess_color_white then
			Result := white_queenside;
		else
			Result := black_queenside;
		end
	end

feature -- Status Setting
	reset_fifty_counter is
	do
		fifty_counter := 0;
	end

	increment_fifty_counter is
	do
		fifty_counter := fifty_counter + 1;
	end

	set_capture(square, piece: INTEGER) is
	require
		valid_square(square);
		valid_piece(piece);
	do
		capture_square := square;
		capture_piece := piece;
	end

	clear_capture is
	do
		capture_square := No_square_specified;
		capture_piece := Piece_none;
	end

	set_double_move(side, square: INTEGER) is
		-- remember square that a pawn double-moved to.
	require
		valid_piece_color(side);
		valid_square(square);
	do
		if side = Chess_color_white then
			double_move_white := square;
		else
			double_move_black := square;
		end
	end

	clear_double_move(side: INTEGER) is
		-- Clear square that a pawn double-moved to.
	require
		valid_piece_color(side);
	do
		if side = Chess_color_white then
			double_move_white := No_square_specified;
		else
			double_move_black := No_square_specified;
		end
	end

	double_move(side: INTEGER): INTEGER is
		-- double move square for 'side'
	require
		valid_piece_color(side);
	do
		if side = Chess_color_white then
			Result := double_move_white;
		else
			Result := double_move_black;
		end
	ensure
		valid_square(Result) or Result = No_square_specified;
	end

	revoke_qcastle(side: INTEGER) is
		-- remove queen-side castling rights for 'side'
	require
		valid_piece_color(side);
	do
		if side = Chess_color_white then
			white_queenside := False;
		else
			black_queenside := False;
		end
	end

	revoke_kcastle(side: INTEGER) is
		-- remove king-side castling rights for 'side'
	require
		valid_piece_color(side);
	do
		if side = Chess_color_white then
			white_kingside := False;
		else
			black_kingside := False;
		end
	end

	revoke_both(side: INTEGER) is
		-- remove all castling rights for 'side'
	require
		valid_piece_color(side);
	do
		if side = Chess_color_white then
			white_kingside := False;
			white_queenside := False;
		else
			black_kingside := False;
			black_queenside := False;
		end
	end

	revoke_castle_on_capture(dst_square, captured_piece: INTEGER) is
		-- revoke castling rights that may be lost when a
		-- rook on squares A1, H1, A8, or H8 are captured
	require
		valid_square(dst_square);
		valid_piece(captured_piece);
	do
		if captured_piece = Piece_white_rook then
			--
			-- was the white rook on a starting square?
			--
			if dst_square = Square_A1 then
				white_queenside := False;
			elseif dst_square = Square_H1 then
				white_kingside := False;
			end

		elseif captured_piece = Piece_black_rook then
			--
			-- was the black rook on a starting square?
			--
			if dst_square = Square_A8 then
				black_queenside := False;
			elseif dst_square = Square_H8 then
				black_kingside := False;
			end
		end
	end

feature -- Element Change

end

