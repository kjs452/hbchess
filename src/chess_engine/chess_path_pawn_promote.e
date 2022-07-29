indexing
	description:	"Describes pawn promotion squares"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

--
-- This class covers the pawn promotion (non-capture).
--
-- A white pawn on Rank_7, can promote when moved forward.
-- A black pawn on Rank_2 can promote when moved to Rank_1.
--
--
class CHESS_PATH_PAWN_PROMOTE
inherit
	CHESS_PATH_PAWN
	redefine
		make, generate_moves
	end

creation
	make

feature -- Initialization
	make(square: INTEGER; color: INTEGER) is
	local
		rank: INTEGER;
	do
		rank := get_rank(square);

		if (color = Chess_color_white) and (rank = Rank_7) then
			Precursor(square, color);
		elseif (color = Chess_color_black) and (rank = Rank_2) then
			Precursor(square, color);
		else
			-- invalid rank for pawn promotion to occur
			ar_make(0, 1);
		end
	end

feature -- Status Report
	generate_moves(cp: CHESS_POSITION; square, piece: INTEGER;
				mq, cq: CHESS_MOVE_QUEUE) is
	local
		p, to_square: INTEGER;
	do
		to_square := item(lower);
		p := cp.get_piece(to_square);
		if p = Piece_none then
			if cq /= Void then
				cq.put(Move_pawn_promote_q, piece, square, to_square);
				cq.put(Move_pawn_promote_n, piece, square, to_square);
				cq.put(Move_pawn_promote_b, piece, square, to_square);
				cq.put(Move_pawn_promote_r, piece, square, to_square);
			end
		end

	end

end
