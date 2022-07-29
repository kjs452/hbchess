indexing
	description:	"Stores a chess game and history of moves"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

--
-- This class encapsulates a CHESS_POSITION and
-- allows for moves to be made, and undone, etc...
-- This class lets us query the chess game for a list
-- of valid moves. We can also check to see if
-- the game is over (check-mate, etc..)...
--
-- This class keeps a history of all moves in the game. Many of
-- the features of this class accept a 'ply' argument. This
-- allows us to query the current board (ply=total_plies) or
-- any past board.
--
-- For example, to obtain a list of captures for White after the
-- 4th move we can call:
--
--	lst := game.captures(Chess_color_white, 8);
--
-- To get a list of all pieces captures by Black so far in the game, call:
--
--	lst := game.captures(Chess_color_black, game.total_plies);
--
--
class CHESS_GAME
inherit
	CHESS_GENERAL_CONSTANTS
	CHESS_SQUARE_CONSTANTS
	CHESS_PIECE_CONSTANTS
	export
		{ANY} Piece_none
	end

creation
	make

feature -- Initialization
	make is
	do
		new_game;
	end

	new_game is
		-- create the chess board and add all the
		-- pieces for a new game.
	local
		square, i: INTEGER;
	do
		!! board.make;
		!! history.make;

		--
		-- ADD WHITE PIECES
		--
		square := get_square(File_a, Rank_1);
		board.add_piece(square, Piece_white_rook);

		square := get_square(File_b, Rank_1);
		board.add_piece(square, Piece_white_knight);

		square := get_square(File_c, Rank_1);
		board.add_piece(square, Piece_white_bishop);

		square := get_square(File_d, Rank_1);
		board.add_piece(square, Piece_white_queen);

		square := get_square(File_e, Rank_1);
		board.add_piece(square, Piece_white_king);

		square := get_square(File_f, Rank_1);
		board.add_piece(square, Piece_white_bishop);

		square := get_square(File_g, Rank_1);
		board.add_piece(square, Piece_white_knight);

		square := get_square(File_h, Rank_1);
		board.add_piece(square, Piece_white_rook);

		--
		-- ADD BLACK PIECES
		--
		square := get_square(File_a, Rank_8);
		board.add_piece(square, Piece_black_rook);

		square := get_square(File_b, Rank_8);
		board.add_piece(square, Piece_black_knight);

		square := get_square(File_c, Rank_8);
		board.add_piece(square, Piece_black_bishop);

		square := get_square(File_d, Rank_8);
		board.add_piece(square, Piece_black_queen);

		square := get_square(File_e, Rank_8);
		board.add_piece(square, Piece_black_king);

		square := get_square(File_f, Rank_8);
		board.add_piece(square, Piece_black_bishop);

		square := get_square(File_g, Rank_8);
		board.add_piece(square, Piece_black_knight);

		square := get_square(File_h, Rank_8);
		board.add_piece(square, Piece_black_rook);

		--
		-- Add pawns (both black & white pieces)
		--
		from
			i := Min_file
		until
			i > Max_file
		loop
			square := get_square(i, Rank_2);
			board.add_piece(square, Piece_white_pawn);

			square := get_square(i, Rank_7);
			board.add_piece(square, Piece_black_pawn);
			i := i + 1;
		end

		--
		-- clear end-of-game-flags
		--
		check_mate := False;
		stale_mate := False;
		draw := False;
	end

feature -- Access
	check_mate: BOOLEAN;
	stale_mate: BOOLEAN;
	draw: BOOLEAN;

	game_over: BOOLEAN is
		-- is the chess board in an end-of-game state?
	do
		Result := check_mate or stale_mate or draw;
	end

	board: CHESS_POSITION;
	history: CHESS_GAME_HISTORY;

feature -- Status Report
	side_to_move: INTEGER is
	do
		Result := board.side_to_move;
	ensure
		valid_piece_color(Result);
	end

	valid_moves: LINKED_LIST[ CHESS_MOVE ] is
		-- list of valid moves for whatever side is moving.
	local
		movgen: CHESS_MOVGEN;
		mov: CHESS_MOVE;
	do
		!! movgen.make;
		!! Result.make;

		from
			movgen.start(board);
		until
			movgen.off
		loop
			mov := movgen.item;

			movgen.move;

			if not board.is_in_check(mov.side) then
				Result.extend(mov);
			end

			movgen.take_back;

			movgen.forth;
		end
	ensure
		Result /= Void;
	end

	find_move(src_square, dst_square, promoted_piece: INTEGER): CHESS_MOVE is
		--
		-- get the move that is from 'src_square' to 'dst_square'
		-- (for pawn promotion's, 'promote_piece' is used
		-- to distinquish the possible moves).
		--
	require
		valid_square(src_square);
		valid_square(dst_square);
		valid_piece(promoted_piece) or (promoted_piece = Piece_none);
	local
		movgen: CHESS_MOVGEN;
		mov: CHESS_MOVE;
	do
		!! movgen.make;

		from
			Result := Void;
			movgen.start(board);
		until
			movgen.off or (Result /= Void)
		loop
			mov := movgen.item;

			movgen.move;

			if not board.is_in_check(mov.side) then
				if (mov.src = src_square)
					and (mov.dst = dst_square) then

					if mov.is_pawn_promotion then
						if mov.promoted_piece = promoted_piece
						then
							Result := mov
						end
					else
						Result := mov;
					end
				end
			end

			movgen.take_back;

			movgen.forth;
		end
	ensure
		Result /= Void;
	end

	query_board(file, rank, ply: INTEGER): INTEGER is
		-- piece located on square identified by 'file' 'rank'
		-- If square is empty, return 'Piece_none'
		--
		-- 'ply' indicates which ply in the game history to query
		--
		-- ply=0		initial chess board
		-- ply=1		state of board after white's 1st move
		-- ply=1		state of board after black's 1st move
		--   ...
		-- ply=total_plies	current state of the board
		--
	require
		valid_file(file);
		valid_rank(rank);
		ply >= 0 and ply <= total_plies;
	local
		square: INTEGER;
		a_board: CHESS_POSITION;
	do
		square := get_square(file, rank);

		if ply < total_plies then
			a_board := history.i_th(ply+1).board;
		else
			a_board := board;
		end

		Result := a_board.get_piece(square);
	ensure
		valid_piece(Result) or Result = Piece_none;
	end

	algebraic_notation(mov: CHESS_MOVE): STRING is
	require
		mov /= Void;
	do
		Result := mov.algebraic_notation(board);
	end

	captures(side: INTEGER; ply: INTEGER): LINKED_LIST[ INTEGER ] is
		-- get list of captures for the game up to and including 'ply'
		-- for 'side'.
	require
		valid_piece_color(side);
		ply >= 0 and ply <= total_plies;
	do
		if ply = 0 then
			!! Result.make;
		else
			Result := history.captures(side, ply);
		end
	ensure
		Result /= Void;
	end

	undo_available: BOOLEAN is
		-- can we undo a move?
	do
		Result := history.count > 0;
	end

	total_plies: INTEGER is
		-- number of half moves in the game.
		--
		-- When the game starts, and before white has moved,
		-- total_plies=0.
		--
		-- After white has made his first move, total_plies=1
		--
		-- And so on...
	do
		Result := history.count;
	end

	total_moves: INTEGER is
		-- total number of moves in the game
		-- (partial moves are included. This mean if
		-- white has moved, but black has not, this still
		-- counts as a move)
	do
		Result := total_plies // 2 + (total_plies \\ 2);
	end

	move_out(ply: INTEGER): STRING is
		-- return a move (in algebraic format) for an arbitry ply
	require
		ply >= 1 and ply <= total_plies;
	local
		hitem: CHESS_GAME_HISTORY_ITEM;
	do
		hitem := history.i_th(ply);
		Result := hitem.move.algebraic_notation(hitem.board);
	ensure
		Result /= Void;
	end

	get_move(ply: INTEGER): CHESS_MOVE is
		-- return a move (in CHESS_MOVE) for an arbitry ply
	require
		ply >= 1 and ply <= total_plies;
	local
		hitem: CHESS_GAME_HISTORY_ITEM;
	do
		hitem := history.i_th(ply);
		Result := hitem.move;
	ensure
		Result /= Void;
	end


feature -- Status Setting

feature -- Element Change
	make_move(mov: CHESS_MOVE) is
		-- apply a chess move to the chess board.
		-- (NOTE: we should add an precondition that this move
		-- must be valid)
	require
		mov /= Void;
		not game_over;
	do
		--
		-- remember this move in history
		--
		history.record_move(board, mov);

		--
		-- make the move
		--
		mov.move(board);

		detect_end_of_game;
	end

	undo is
		-- take back the last move
	require
		undo_available;
	local
		hitem: CHESS_GAME_HISTORY_ITEM;
	do
		hitem := history.last;
		history.remove_last;
		restore_game(hitem);
	end


feature -- Removal

feature {NONE} -- Implementation
	restore_game(hitem: CHESS_GAME_HISTORY_ITEM) is
		-- restore game state, based on a history object 'hitem'
		-- (this is used when we undo moves)
	require
		hitem /= Void;
	do
		board.deep_copy(hitem.board);
		detect_end_of_game;
	end

	detect_end_of_game is
		-- examine the current state of the game
		-- and detect end-of-game situations:
		--	check_mate
		--	stale_mate
		--	draw
	local
		lst: LINKED_LIST[ CHESS_MOVE ];
	do
		--
		-- detect end-of-game
		-- conditions
		--
		check_mate := False;
		stale_mate := False;
		draw := False;

		lst := valid_moves;
		if board.is_in_check(side_to_move) then
			if lst.count = 0 then
				check_mate := True;
			end

		elseif lst.count = 0 then
			stale_mate := True;

		elseif board.state.fifty_counter > 100 then
			draw := True;
		end
	end

end
