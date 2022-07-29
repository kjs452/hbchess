indexing
	description:	"Describes chess squares involving Pawn e.p. captures"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

--
-- This class covers the pawn e.p. capture behavior.
-- A black pawn on rank 4 (or white pawn on rank 5) may
-- capture using the en passant rule. This is a diagonal capture,
-- only if an enemy pawn has moved two squares forward during
-- the previous move. We check CHESS_STATE.opponents_last_double_move to see
-- if an e.p. capture is possible.
--
class CHESS_PATH_PAWN_EP
inherit
	CHESS_PATH_PAWN_CAPTURE
	redefine
		generate_moves, pawn_capture_rank
	end

creation
	make

feature -- Status Report
	--
	-- Only 1 move is possible for e.p. capture. This
	-- will be placed in the 'cq' (capture queue).
	--
	generate_moves(cp: CHESS_POSITION; square, piece: INTEGER;
				mq, cq: CHESS_MOVE_QUEUE) is
	do
		if cq /= Void then
			gen_moves(cp, square, piece, cq);
		end
	end


feature {NONE} -- Implementation
	gen_moves(cp: CHESS_POSITION; square, piece: INTEGER; queue: CHESS_MOVE_QUEUE) is
	require
		cp /= Void;
		queue /= Void;
		valid_square(square);
		valid_piece(piece);
	local
		dbl_square, ep_square, dst: INTEGER;
		oc: INTEGER;
		rank, file: INTEGER;
		idx, direction: INTEGER;
	do
		oc := get_opposite_color( get_piece_color(piece) );

		dbl_square := cp.state.double_move(oc);

		if dbl_square /= No_square_specified then

			if get_piece_color(piece) = Chess_color_white then
				direction := 1;
			else
				direction := -1;
			end

			from
				idx := lower;
			until
				idx > upper
			loop
				dst := item(idx);
				rank := get_rank(dst);
				file := get_file(dst);

				ep_square := get_square(file, rank - direction);

				if ep_square = dbl_square then
					queue.put(Move_pawn_ep, piece, square, dst);
				end

				idx := idx + 1;
			end
		end
	end

	--
	-- e.p. capture can happen only on rank_5 (for white) and
	-- rank_4 (for black).
	--
	pawn_capture_rank(rank: INTEGER; color: INTEGER): BOOLEAN is
	do
		if color = Chess_color_white then
			Result := (rank = Rank_5);
		else
			Result := (rank = Rank_4);
		end
	end


end
