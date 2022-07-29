indexing
	description:	"A chess position. Contains everything needed%
			% to describe a chess position and all associated%
			% chess states"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

--
-- This class contains the current state of a chess board.
--
-- The primary structure of this class is an array[1..64]. Each element
-- of this array corresponds to a chess square. The value of
-- the array element is a peice/color combination (1..12)
--
-- There is also an attached CHESS_STATE object, that can be copied and restored
-- externally, so we can quickly make moves, and undo moves.
--
-- The primary operations for this class is add_piece() and remove_piece()
-- All CHESS_MOVE's translate into a series of add_piece() and remove_piece()
-- commands.
--
-- We keep track of the two kings (for fast in-check detection).
-- We keep track of material and positional score
-- we keep a current hash and hash_lock value for this position
-- we keep track of the side-to-move
--
-- SCORING:
-- Most chess programs have an Eval() function that returns a
-- numerical score for any chess position. This score tells us
-- which side is winning. Eval() cannot know for sure who is winning for
-- sure. But is can apply lots of hueristics to get a rough idea of
-- how good a chess position is. Our scoring is the sum of the
-- following factors:
--
--	* Material balance (See CHESS_PIECE_CONSTANTS)
--	* Positional scoring (See CHESS_MOVE_SQUARE)
--	* castling
--
-- Positional scoring is divided into normal and end-game positions.
-- When the number of pieces is low, we assume we are in end-game and
-- use a seperate algorithm to compute the positional score.
--
-- Most chess programs calculate the score on demand. We have
-- taken a different approach, we keep a running score whenever
-- pieces are added/removed from the chess board.
--
-- HASHING
-- We calculate a hash value for this position. We also calculate
-- a second value 'hash_lock', these two values are used in the transposition
-- table so we can quickly obtain results from past searches.
--
-- MISC.
-- We also keep track of the KING for each side. This allows
-- us to quickly determine if a player is "in check" without having
-- to scan the whole board to find the king.
--

class CHESS_POSITION
inherit
	ARRAY[INTEGER]
	rename
		make as ar_make
	export
		{NONE} all
	undefine
		copy, is_equal
	end

	CHESS_GENERAL_CONSTANTS
	CHESS_PIECE_CONSTANTS
	CHESS_SQUARE_CONSTANTS
	CHESS_BOARD_TABLES

creation
	make

feature -- Initialization
	make is
	do
		ar_make(Min_square, Max_square);
		clear_board;
	end

feature -- Access
	state: CHESS_STATE;

	side_to_move: INTEGER;

	--
	-- square(s) containing white & black kings
	-- (or No_square_specified)
	--
	white_king: INTEGER;
	black_king: INTEGER;

	--
	-- We maintain material & positional scores
	--
	material_white: INTEGER;
	material_black: INTEGER;
	position_score: INTEGER;
	position_endgame_score: INTEGER;

	--
	-- hash keys for this chess position
	--
	hash_key: INTEGER is
	do
		Result := hkey + hash_adjustment;
	end

	hash_lock_key: INTEGER is
	do
		Result := hlock_key + hash_lock_adjustment;
	end

feature -- Status Report
	get_piece(square: INTEGER): INTEGER is
		-- the piece located on 'square'
	require
		valid_square(square);
	do
		Result:= item(square);
	ensure
		valid_piece(Result) or Result = Piece_none;
	end

	get_color(square: INTEGER): INTEGER is
		-- the color of the piece on 'square'
	require
		valid_square(square) and occupied(square);
	do
		Result := get_piece_color( item(square) );
	ensure
		valid_piece_color(Result);
	end

	get_piecetype(square: INTEGER): INTEGER is
		-- the piece_type of the piece on 'square'
	require
		valid_square(square) and occupied(square);
	do
		Result := get_piece_type( item(square) );
	ensure
		valid_piece_type(Result);
	end

	occupied(square: INTEGER): BOOLEAN is
		-- does this square contain anything?
	require
		valid_square(square);
	do
		Result := item(square) /= Piece_none;
	end

	score: INTEGER is
		-- The score of this position.
		--
		-- This is the "Evaluate()" function in
		-- most chess programs.
		--
		-- A negative score implies an advantage to Black
		-- A positive score implies an advantage to White
		-- A zero score implies a equal
		--
	do
		if in_end_game then
			Result := (material_white - material_black)
				+ position_endgame_score;
		else
			Result := (material_white - material_black)
				+ position_score;
		end
	end

	under_attack(square, side: INTEGER): BOOLEAN is
		-- Is 'square' attackable by a piece of color 'side'
	require
		valid_square(square);
		valid_piece_color(side);
	local
		plist: CHESS_PATH_LIST;
	do
		plist := attack_table.path_list(square, side);
		Result := plist.under_attack(Current, side);
	end

	attacking_squares(square, side: INTEGER): LINKED_LIST[ INTEGER ] is
		-- list of squares containing pieces of color 'side'
		-- that are able to attack 'square'
	require
		valid_square(square);
		valid_piece_color(side);
	local
		plist: CHESS_PATH_LIST;
	do
		plist := attack_table.path_list(square, side);
		Result := plist.attacking_squares(Current, side);
	ensure
		Result /= Void;
	end

	is_in_check(side: INTEGER): BOOLEAN is
		-- is king of color 'side' under attack?
	require
		valid_piece_color(side);
	do
		if side = Chess_color_white then
			Result := under_attack(white_king, Chess_color_black);
		else
			Result := under_attack(black_king, Chess_color_white);
		end
	end

	in_end_game: BOOLEAN is
		-- have we reached the end-game portion of the game?
		-- When the combined material values of both pieces is
		-- less than 3000, we have endgame.
	do
		Result := (material_white + material_black) < 3000;
	end

feature -- Status Setting

feature {CHESS_MOVE} -- Status Setting
	toggle_side is
		-- flip the side-to-move. generally this is only done
		-- only after making a move.
	do
		side_to_move := get_opposite_color(side_to_move);
	ensure
		old side_to_move /= side_to_move;
		valid_piece_color(side_to_move);
	end

feature -- Element Change
	add_piece(square, piece: INTEGER) is
		-- Add a 'piece' to the board at 'square'
	require
		valid_square(square);
		valid_piece(piece);
		not occupied(square);
	local
		move_square: CHESS_MOVE_SQUARE;
	do
		put(piece, square);

		move_square := move_table.item(square, piece);

		change_hash_keys(move_square.hash_val, move_square.hash_lock_val);
		increase_score(piece, move_square);

		if piece = Piece_white_king then
			white_king := square;
		elseif piece = Piece_black_king then
			black_king := square;
		end
	end

	remove_piece(square: INTEGER) is
		-- remove a piece from the board on 'square'
	require
		valid_square(square);
		occupied(square);
	local
		piece: INTEGER;
		move_square: CHESS_MOVE_SQUARE;
	do
		piece := item(square);

		move_square := move_table.item(square, piece);

		put(Piece_none, square);

		change_hash_keys(- move_square.hash_val, - move_square.hash_lock_val);

		decrease_score(piece, move_square);

		if square = white_king then
			white_king := No_square_specified;
		elseif square = black_king then
			black_king := No_square_specified;
		end
	end

	clear_board is
		-- Make an empty board, side-to-move is set to white.
	local
		i: INTEGER;
	do
		from
			i := lower
		until
			i > upper
		loop
			put(Piece_none, i);
			i := i + 1;
		end

		!! state.make;

		side_to_move := Chess_color_white;

		hkey := 0;
		hlock_key := 0;

		white_king := No_square_specified;
		black_king := No_square_specified;

		material_white := 0;
		material_black := 0;
		position_score := 0;
		position_endgame_score := 0;
	end

feature -- Chess State set/modify
	set_state(other: CHESS_STATE) is
		-- set our CHESS_STATE to 'other'
	require
		other /= Void;
	do
		state.copy(other);
	end

feature {NONE} -- Implementation
	hkey, hlock_key: INTEGER;

	change_hash_keys(val, lock_val: INTEGER) is
		-- update hash values
	do
		hkey		:= hkey + val;
		hlock_key	:= hlock_key + lock_val;
	end

	increase_score(piece: INTEGER; ms: CHESS_MOVE_SQUARE) is
		-- increase score, when adding a piece to the chess board
		-- (black pieces lower the score, white pieces
		-- increase the score)
	require
		valid_piece(piece);
		ms /= Void;
	local
		color, piece_type: INTEGER;
		piece_value: INTEGER;
	do
		color := get_piece_color(piece);
		piece_type := get_piece_type(piece);
		piece_value := get_piece_value(piece_type);

		if color = Chess_color_white then
			material_white := material_white + piece_value;
			position_score := position_score + ms.score;
			position_endgame_score := position_endgame_score
							+ ms.score_endgame;
		else
			material_black := material_black + piece_value;
			position_score := position_score - ms.score;
			position_endgame_score := position_endgame_score
							- ms.score_endgame;
		end
	end

	decrease_score(piece: INTEGER; ms: CHESS_MOVE_SQUARE) is
		-- decrease score, when removing a piece from the chess board
	require
		valid_piece(piece);
		ms /= Void;
	local
		color, piece_type: INTEGER;
		piece_value: INTEGER;
	do
		color := get_piece_color(piece);
		piece_type := get_piece_type(piece);
		piece_value := get_piece_value(piece_type);

		if color = Chess_color_white then
			material_white := material_white - piece_value;
			position_score := position_score - ms.score;
			position_endgame_score := position_endgame_score - ms.score_endgame;
		else
			material_black := material_black - piece_value;
			position_score := position_score + ms.score;
			position_endgame_score := position_endgame_score + ms.score_endgame;
		end
	end

	hash_adjustment: INTEGER is
		-- Add additional state information, and side_to_move
		-- info, so that hash keys reflect the COMPLETE state
		-- of the game.
	do
		if side_to_move = Chess_color_white then
			Result := 234_196_800;
		else
			Result := 0;
		end

		Result := Result + state.hash_value;
	end

	hash_lock_adjustment: INTEGER is
		-- Add additional state information, and side_to_move
		-- info, so that hash keys reflect the state of the
		-- game.
	do
		if side_to_move = Chess_color_white then
			Result := 0;
		else
			Result := 135_999_901;
		end

		Result := Result + state.hash_value;
	end
end
