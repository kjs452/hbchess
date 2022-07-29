indexing
	description:	"Describes chess squares that the King can castle"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

--
-- A KING at its initial square can castle to the queen-side or king-side
-- (Assuming the king and appropriate rook hasn't moved, etc...)
--
-- This class will generate up to 2 castling moves, if the right conditions
-- are true.
--
class CHESS_PATH_CASTLE
inherit
	CHESS_PATH_KING
	redefine
		make, generate_moves
	end

creation
	make

feature -- Initialization
	make(square: INTEGER) is
	local
		rank: INTEGER;
		s: INTEGER;
	do
		if square /= Square_E1 and square /= Square_E8 then
			--
			-- Invalid king starting position, so
			-- castling is not a valid move for this
			-- square.
			--
			ar_make(1, 0);
		else
			rank := get_rank(square);
			ar_make(1, 2);

			--
			-- Kingside castle
			--
			s := get_square(File_g, rank);
			put(s, 1);

			--
			-- Queenside castle
			--
			s := get_square(File_c, rank);
			put(s, 2);
		end
	end

feature -- Status Report

	--
	-- Castle moves rules:
	--	KING-SIDE CASTLE RULES:
	--		1. Castling rights exist
	--		2. File_f and file_g are un-occupied
	--		3. File_h contains a rook
	--		4. 'from_square' and File_f square is not being attacked
	--
	--	QUEEN-SIDE CASTLE RULES:
	--		1. Castling rights exist
	--		2. File_b, File_c and File_d are un-occupied
	--		3. File_a contains a rook
	--		4. 'from_square' and File_d square is not being attacked
	--
	-- We don't verify to see if the king (after the castle move) is in check.
	-- This verification will occur later during in the search algorithm.
	--
	-- This feature will add up to 2 moves to the 'cq' (capture queue)
	--
	generate_moves(cp: CHESS_POSITION; square, piece: INTEGER;
				mq, cq: CHESS_MOVE_QUEUE) is
	do
		if cq /= Void then
			gen_moves(cp, square, piece, cq);
		end
	end

feature {NONE} -- Implementation

	gen_moves(cp: CHESS_POSITION; square, piece: INTEGER; cq: CHESS_MOVE_QUEUE) is
	require
		cp /= Void;
		valid_square(square);
		valid_piece(piece);
		cq /= Void;
	local
		side: INTEGER;
	do
		side := get_piece_color(piece);

		if cp.state.can_kcastle(side) then
			gen_kingside_castle(cq, cp, piece, square, item(1));
		end

		if cp.state.can_qcastle(side) then
			gen_queenside_castle(cq, cp, piece, square, item(2));
		end
	end

	gen_castle(queue: CHESS_MOVE_QUEUE; cp: CHESS_POSITION;
				type, piece, src, dst, thru: INTEGER) is

		-- add a castle move to queue if 'src' and
		-- 'thru' are not under attack.
	require
		queue /= Void;
		cp /= Void;
		valid_piece(piece);
		valid_square(src);
		valid_square(dst);
		valid_square(thru);
	local
		enemy_color: INTEGER;
	do
		enemy_color := get_opposite_color( get_piece_color(piece) );

		if not cp.under_attack(src, enemy_color)
			and then not cp.under_attack(thru, enemy_color)
		then
			queue.put(type, piece, src, dst);
		end
	end

	gen_kingside_castle(queue: CHESS_MOVE_QUEUE;
				cp: CHESS_POSITION; piece, src, dst: INTEGER) is
		-- If File_f and file_g are un-occupied then call gen_castle().
	require
		queue /= Void;
		cp /= Void;
		valid_piece(piece);
		valid_square(src);
		valid_square(dst);
	local
		f_square, g_square: INTEGER;
		rank: INTEGER;
	do
		rank := get_rank(src);
		f_square := get_square(File_f, rank);
		g_square := get_square(File_g, rank);

		if (not cp.occupied(f_square)) and then (not cp.occupied(g_square)) then
			gen_castle(queue, cp,
				Move_castle_kingside, piece, src, dst, f_square);
		end
	end

	gen_queenside_castle(queue: CHESS_MOVE_QUEUE;
				cp: CHESS_POSITION; piece, src, dst: INTEGER) is
		-- If File_b, File_c and file_d squares are un-occupied then
		-- call gen_castle().
	require
		queue /= Void;
		cp /= Void;
		valid_piece(piece);
		valid_square(src);
		valid_square(dst);
	local
		b_square, c_square, d_square: INTEGER;
		rank: INTEGER;
	do
		rank := get_rank(src);
		b_square := get_square(File_b, rank);
		c_square := get_square(File_c, rank);
		d_square := get_square(File_d, rank);

		if (not cp.occupied(b_square)) and then (not cp.occupied(c_square))
			and then (not cp.occupied(d_square))
		then
			gen_castle(queue, cp,
				Move_castle_queenside, piece, src, dst, d_square);
		end
	end


end
