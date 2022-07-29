indexing
	description:	"Describes a Pawn capture and promotion"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

--
-- This class covers the pawn movement from Rank_7
-- and Rank_2, when a capture AND a promotion occurs.
--
-- Pawns may capture the two immediate diagonal squares in the direction
-- of pawn movement. Direction is determined based on piece color.
--
class CHESS_PATH_PAWN_CAPTURE_AND_PROMOTE
inherit
	CHESS_PATH_PAWN_CAPTURE
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

		if (color = Chess_color_white) and then (rank = Rank_7) then
			Precursor(square, color);
		elseif (color = Chess_color_black) and then (rank = Rank_2) then
			Precursor(square, color);
		else
			-- pawn capture & promote cannot happen on this square
			ar_make(0, 1);
		end
	end

feature -- Status Report
	generate_moves(cp: CHESS_POSITION; square, piece: INTEGER;
				mq, cq: CHESS_MOVE_QUEUE) is
		--
		-- generate pawn capture (and promotion) moves.
		--
	local
		p, idx, dst: INTEGER;
	do
		from
			idx := lower;
		until
			idx > upper
		loop
			dst := item(idx);
			p := cp.get_piece(dst);
			if p /= Piece_none and then enemy_pieces(piece, p) then
				if cq /= Void then
					cq.put(Move_pawn_promote_q, piece, square, dst);
					cq.put(Move_pawn_promote_n, piece, square, dst);
					cq.put(Move_pawn_promote_b, piece, square, dst);
					cq.put(Move_pawn_promote_r, piece, square, dst);
				end
			end

			idx := idx + 1;
		end
	end

end
