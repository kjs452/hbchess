indexing
	description:	"A Chess move. Describes a piece move in chess%
			% includes the squares involved and piece(s) involved%
			% and special move types"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

--
-- This is a fundamental class for a chess playing program.
-- When the computer is seeking the best move to make, it
-- is dealing with lots and lots of CHESS_MOVE objects. A
-- typical search operation might explore 1 million moves
-- to find the best move to make.
--
-- A chess move stores the squares/pieces involved, plus
-- any addition details needed for the more complex
-- chess moves (e.p. square, castling, promoted piece)
--
-- A chess move also stores one of these types (see CHESS_MOVE_CONSTANTS):
--
--	Move_normal		- all moves not covered below
--	Move_king
--	Move_krook		- kingside rook is moving
--	Move_qrook		- queenside rook is moving
--	Move_pawn
--	Move_pawn_ep		- en passant capture
--	Move_pawn_double
--	Move_pawn_promote_q	- pawn promotion to queen
--	Move_pawn_promote_r	- to rook
--	Move_pawn_promote_b	- to bishop
--	Move_pawn_promote_n	- to knight
--	Move_castle_kingside
--	Move_castle_queenside
--
-- An earlier version of this chess engine used a class inheritance hierarchy,
-- which was elegant and easy to maintain. However to avoid dynamic creation of
-- these objects during the search phase (millions of CHESS_MOVE objects), it
-- was decided to use a single class to encapsulate ALL types of chess moves, and
-- this enabled a fixed number of CHESS_MOVE's to be created, without the need
-- to create millions of objects, thus speeding up the engine.
--
-- This class contains two fundamental operations that any chess playing
-- program needs: MOVE and TAKE_BACK.
--
-- MOVE algorithm:
--	Move takes a chess board (a CHESS_POSITION) and applies the
-- move to the board. When this operation completes, CHESS_POSITION has
-- been changed to reflect the state of the game that results when
-- the move has been played.
--
-- The 'move' function must handle tons of rules and logic like:
--	* revoking castling rights
--	* remembering a pawn double move, so that E.P. capture is
--	  allowed in the next move.
--	* Castling
--	* Increment or clear the draw-by-fifty repetion counter
--	* switch the side-to-move
--
-- TAKE_BACK algorithm:
-- Why does a chess playing program need a take back? Because
-- we are searching millions of moves and we apply moves to
-- the chess board, and then we check to see if it was a good move.
-- Before we try another move, we TAKE_BACK the previous move.
--
-- Question:
-- Why not just remember the CHESS_POSITION and do a copy to restore it?
--
-- Answer:
-- Because it is slower to copy/restore a 64-integer sized object than
-- it is to undo a move. (It really is, because I tried both ways)
--
-- Applying MOVE and TAKE_BACK will ensure that the CHESS_POSITION
-- is left unchanged. ex.
--
--	m.move(board);
--	m.take_back(board);
--
--	'board' has not been changed
--
-- This class also lets us:
--	* convert a move into pretty algebraic notation.
--	* compare two moves according to MVV/LVA criteria
--	* and much, much more
--
--
class CHESS_MOVE
inherit
	CHESS_GENERAL_CONSTANTS
	CHESS_SQUARE_CONSTANTS
	CHESS_PIECE_CONSTANTS
	CHESS_MOVE_CONSTANTS

creation
	make, make_from_other, make_empty

feature -- Initialization
	make(a_type, a_piece, a_src, a_dst: INTEGER) is
	require
		valid_move_type(a_type);
		valid_piece(a_piece);
		valid_square(a_src);
		valid_square(a_dst);
	do
		type := a_type;
		piece := a_piece;
		src := a_src;
		dst := a_dst;
	end

	make_from_other(other: CHESS_MOVE) is
	require
		other /= Void;
	do
		make(other.type, other.piece, other.src, other.dst);
	end

	make_empty is
	do
		type := Move_not_specified;
		piece := 0;
		src := 0;
		dst := 0;
	end

feature -- Actions
	move(cp: CHESS_POSITION) is
		-- apply move to a chess position
	require
		cp /= Void;
		cp.occupied(src);
		cp.get_piece(src) = piece;
	local
		captured: INTEGER;
		dbl_square, p: INTEGER;
		rook_src, rook_dst: INTEGER;
	do
		cp.state.clear_double_move(side);

		--
		-- move piece from 'src' to 'dst'
		--
		cp.remove_piece(src);

		captured := cp.get_piece(dst);

		if captured /= Piece_none then
			cp.remove_piece(dst);
			cp.state.set_capture(dst, captured);
			cp.state.reset_fifty_counter;

			-- if rook captured, revoke castling rights
			-- for that side.
			cp.state.revoke_castle_on_capture(dst, captured);
		else
			cp.state.clear_capture;
			cp.state.increment_fifty_counter;
		end

		cp.add_piece(dst, piece);

		--
		-- Specializarition for the various types of moves...
		--
		inspect type
		when Move_normal then
			-- do nothing

		when Move_king then
			cp.state.revoke_both(side);

		when Move_qrook then
			cp.state.revoke_qcastle(side);

		when Move_krook then
			cp.state.revoke_kcastle(side);

		when Move_pawn then
			cp.state.reset_fifty_counter;

		when Move_pawn_ep then
			cp.state.reset_fifty_counter;
			dbl_square := cp.state.double_move(opponent);
			p := cp.get_piece(dbl_square);
			cp.remove_piece(dbl_square);
			cp.state.set_capture(dbl_square,
					get_colored_piece(Piece_type_pawn, opponent) );

		when Move_pawn_double then
			cp.state.reset_fifty_counter;
			cp.state.set_double_move(side, dst);

		when Move_pawn_promote_q then
			cp.state.reset_fifty_counter;
			cp.remove_piece(dst);
			cp.add_piece(dst, get_colored_piece(Piece_type_queen, side) );

		when Move_pawn_promote_r then
			cp.state.reset_fifty_counter;
			cp.remove_piece(dst);
			cp.add_piece(dst, get_colored_piece(Piece_type_rook, side) );

		when Move_pawn_promote_b then
			cp.state.reset_fifty_counter;
			cp.remove_piece(dst);
			cp.add_piece(dst, get_colored_piece(Piece_type_bishop, side) );

		when Move_pawn_promote_n then
			cp.state.reset_fifty_counter;
			cp.remove_piece(dst);
			cp.add_piece(dst, get_colored_piece(Piece_type_knight, side) );

		when Move_castle_kingside then
			if side = Chess_color_white then
				rook_src := Square_H1;
				rook_dst := Square_F1;
			else
				rook_src := Square_H8;
				rook_dst := Square_F8;
			end
			cp.remove_piece(rook_src);
			cp.add_piece(rook_dst, get_colored_piece(Piece_type_rook, side) );

		when Move_castle_queenside then
			if side = Chess_color_white then
				rook_src := Square_A1;
				rook_dst := Square_D1;
			else
				rook_src := Square_A8;
				rook_dst := Square_D8;
			end
			cp.remove_piece(rook_src);
			cp.add_piece(rook_dst, get_colored_piece(Piece_type_rook, side) );
		end

		cp.toggle_side;
	end

	take_back(cp: CHESS_POSITION) is
		-- undo a move
	require
		cp /= Void;
		cp.occupied(dst);
		not cp.occupied(src);
	local
		rook_src, rook_dst: INTEGER;
	do
		--
		-- restore moved piece to original square
		--
		cp.toggle_side;
		cp.remove_piece(dst);
		cp.add_piece(src, piece);

		--
		-- restore any captured piece
		--
		if cp.state.capture_piece /= Piece_none then
			cp.add_piece(cp.state.capture_square, cp.state.capture_piece);
		end

		--
		-- Restore rook, for castling moves
		--
		if type = Move_castle_kingside then
			if side = Chess_color_white then
				rook_src := Square_H1;
				rook_dst := Square_F1;
			else
				rook_src := Square_H8;
				rook_dst := Square_F8;
			end
			cp.remove_piece(rook_dst);
			cp.add_piece(rook_src, get_colored_piece(Piece_type_rook, side));

		elseif type = Move_castle_queenside then
			if side = Chess_color_white then
				rook_src := Square_A1;
				rook_dst := Square_D1;
			else
				rook_src := Square_A8;
				rook_dst := Square_D8;
			end
			cp.remove_piece(rook_dst);
			cp.add_piece(rook_src, get_colored_piece(Piece_type_rook, side));
		end
	end

feature -- Access
	piece: INTEGER;
	src: INTEGER;
	dst: INTEGER;
	type: INTEGER;

feature -- Status Report
	side: INTEGER is
		-- this move is on behalf of 'side' (black or white)
	do
		Result := get_piece_color(piece);
	ensure
		valid_piece_color(Result);
	end

	opponent: INTEGER is
		-- opposite of 'side'. (the opponent color)
	do
		Result := get_opposite_color( get_piece_color(piece) );
	ensure
		valid_piece_color(Result);
	end

	valid(cp: CHESS_POSITION): BOOLEAN is
		-- Is this move valid for 'cp'
		-- This does some basic checking:
		--	* Is the piece to move actually on the board?
		--	* Is the attacked piece of the opposite color?
	require
		cp /= Void;
	local
		p1, p2: INTEGER;
	do
		Result := True;

		p1 := cp.get_piece(src);
		p2 := cp.get_piece(dst);

		-- Does 'src' piece not equal to the piece to move?
		if piece /= p1 then
			Result := False;
		else
			if p2 /= Piece_none then
				-- is attacked piece same color?
				if get_piece_color(p2) = get_piece_color(piece) then
					Result := False;
				end
			end
			
		end
		
	end

	standard_notation(cp: CHESS_POSITION): STRING is
		-- This is the more "elite" chess notation
		-- it uses the minimum of characters, but
		-- is somewhat more cryptics to non-chess types.
		--
		-- 'cp' is the state of the chess board, BEFORE
		-- this move is applied to the chess position
		--
		-- This notation uses the following characters
		-- to describe the pieces: N - knight, K-king,
		-- Q-queen, B-bishop, R-rook, notion-pawn
		--
		-- Other symbols used:
		--	"x"	- Captures
		--	"+"	- opponent placed in check by move
		--	"e.p."	- en passant capture
		--	"=Q"	- pawn promotion to queen
		--
		-- Generate algebraic notation for a chess move
		-- Examples:
		--	o-o		King side castle
		--	o-o-o		Queen side castle
		--	Nf3		kNight to f3
		--	Nxf3		kNight to capture piece on f3
		--	Nce4		night on 'c' file to e4
		--	N3e4		night on '3' rank to e4
		--	Kd1		King to d1
		--	Kxd1		king to capture piece on d1
		--	h4		pawn to h3
		--	gxh3 e.p.	pawn on g file capture piece on square h3
		--	g8=Q		pawn moves to g8, promoted to queen
		--
	require
		cp /= Void;
	do
		-- TODO: implement
		check
			not_implemented: false;
		end
	end

	algebraic_notation(cp: CHESS_POSITION): STRING is
		-- 'cp' is the state of the chess board, BEFORE
		-- this move is applied to the chess position
		--
		-- Generate algebraic notation for a chess move
		-- Examples:
		--	o-o		King side castle
		--	o-o-o		Queen side castle
		--	f1-e1		Normal move
		--	f3xg4		capture move
		--	a1-d1+		move with opponent in check
		--	d1xd5+		capture with opponent in check
		--	g2-g1 =Q	Pawn move & promotion
		--	g2xf1 =N	Pawn capture & promotion
		--	g2xf1+ =N	Pawn capture & promotion & opponent in check
		--	g4xh3 e.p.	Pawn e.p. capture
		--	g4xh3+ e.p.	Pawn e.p. capture
		--
	require
		cp /= Void;
		not is_king_capture(cp);
	local
		saved_state: CHESS_STATE;
		enemy_in_check, in_check: BOOLEAN;
	do
		!! Result.make(10);

		if type = Move_castle_kingside then
			Result.append("o-o");

		elseif type = Move_castle_queenside then
			Result.append("o-o-o");

		else
			Result.append( square_to_string(src) );
			if is_capture(cp) then
				Result.append("x");
			else
				Result.append("-");
			end
			Result.append( square_to_string(dst) );
		end

		-- Will this move put either myself, or opponent
		-- in check?

		!! saved_state.make;
		saved_state.copy(cp.state);
		move(cp);

		in_check := cp.is_in_check(side);
		enemy_in_check := cp.is_in_check(opponent);

		take_back(cp);
		cp.set_state(saved_state);

		if enemy_in_check then
			Result.append("+");
		end

		if in_check then
			-- this is something that shouldn't happen
			Result.prepend("(InCheck) ");
		end

		inspect type
		when Move_pawn_ep then
			Result.append(" e.p.");
		when Move_pawn_promote_q then
			Result.append(" =Q");
		when Move_pawn_promote_r then
			Result.append(" =R");
		when Move_pawn_promote_n then
			Result.append(" =N");
		when Move_pawn_promote_b then
			Result.append(" =B");
		else
			-- do nothing
		end
	end

	is_king_capture(cp: CHESS_POSITION): BOOLEAN is
		-- is this move a capture of a king?
		-- these moves are removed early on inside the
		-- CHESS_MOVGEN (move generator).
	require
		cp /= Void;
	do
		Result := (dst = cp.white_king) or (dst = cp.black_king);
	end

	more_valuable(cp: CHESS_POSITION; other: CHESS_MOVE): BOOLEAN is
		--
		-- Is 'Current' move more valuable than 'other' move?
		--
		-- Uses MVV/LVA (Most Valuable Victim, Least Valuable Attacker)
		-- criteria. A smaller MVV_LVA makes this move better.
	require
		cp /= Void;
		other /= Void;
	do
		Result := mvv_lva(cp) < other.mvv_lva(cp);
	end

	is_capture(cp: CHESS_POSITION): BOOLEAN is
		-- does this move capture a piece?
	require
		cp /= Void;
	do
		if type = Move_pawn_ep then
			Result := True;
		else
			Result := (cp.get_piece(dst) /= Piece_none);
		end
	end

	is_pawn_promotion: BOOLEAN is
		-- this move is a pawn promotion
	do
		Result := (type = Move_pawn_promote_q)
			or (type = Move_pawn_promote_r)
			or (type = Move_pawn_promote_b)
			or (type = Move_pawn_promote_n);
	end

	promoted_piece: INTEGER is
		-- what piece are we promoting to?
	require
		is_pawn_promotion;
	do
		inspect type
		when Move_pawn_promote_q then
			Result := get_colored_piece(Piece_type_queen, side);
		when Move_pawn_promote_r then
			Result := get_colored_piece(Piece_type_rook, side);
		when Move_pawn_promote_b then
			Result := get_colored_piece(Piece_type_bishop, side);
		when Move_pawn_promote_n then
			Result := get_colored_piece(Piece_type_knight, side);
		end
	ensure
		valid_piece(Result);
	end

	captured_piece(cp: CHESS_POSITION): INTEGER is
		-- the piece that this moves would capture
	require
		cp /= Void;
		is_capture(cp);
	local
		dbl_square: INTEGER;
	do
		if type = Move_pawn_ep then
			dbl_square := cp.state.double_move(opponent);
			Result := get_piece_type(cp.get_piece(dbl_square));
		else
			Result := cp.get_piecetype(dst);
		end

	ensure
		valid_piece_type(Result);
	end

feature {NONE} -- Implementation

feature {CHESS_MOVE} -- Implementation
	mvv_lva(cp: CHESS_POSITION): INTEGER is
		-- MVV/LVA (Most Valuable Victim, Least Valuable Attacker)
		-- If this move is a capture, then compute a value based
		-- on the two pieces involved (attacker and victim)
		--
		-- less than zero:
		--	attacker is less valuable than victim
		--	(E.g. Pawn takes Queen: 100 - 900 = -800)
		--
		-- equal to zero:
		--	pieces are equal, or this move is not a capture
		--	(E.g. Rook takes Rook, or a non-capture move. 500 - 500 = 0)
		--
		-- greater than zero:
		--	attacker is more valuable than victim
		--	(E.g. Queen takes pawn: 900 - 100 = 800)
		--
		-- Moves in involving the King are sorted as:
		--	King takes Queen	= 100 - 900 = -800
		--	Queen takes King	= 2000
		--	King takes Queen	= 0 - 900 = -900
		--	King takes Pawn		= 0 - 100 = -100
		--
		-- This means captures involving the king, will be sorted
		-- before all other captures.
		--
		-- (NOTE: doesn't detect e.p. captures, but "pawn takes pawn" has
		-- a value of 0 anyway.)
		--
		-- The smaller the value the "better" this capture is.
		--
	require
		cp /= Void;
	local
		capture_piece: INTEGER;
		attacker, victim: INTEGER;
		victim_type: INTEGER;
	do
		capture_piece := cp.get_piece(dst);

		if capture_piece /= Piece_none then
			victim_type := get_piece_type(capture_piece);

			if victim_type = Piece_type_king then
				-- force king captures to sort last
				Result := 2000;
			else
				attacker := get_piece_value( get_piece_type(piece) );
				victim := get_piece_value( victim_type );
				Result := attacker - victim;
			end

		elseif type = Move_pawn_promote_q then
			Result := -1003;
		elseif type = Move_pawn_promote_r then
			Result := -1002;
		elseif type = Move_pawn_promote_b then
			Result := -1001;
		elseif type = Move_pawn_promote_n then
			Result := -1000;

		else
			-- not a capture, return neutral score
			Result := 0;
		end
	end

end
