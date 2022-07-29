indexing
	description:	"Describes chess squares that the Pawn can move to"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

--
-- This class covers the pawn forward movement behavior.
-- Pawns move in one direction, based on piece color. Also
-- pawns may move 2 squares when starting out on their original
-- rank. THis class handles these kinds of moves.
--
class CHESS_PATH_PAWN
inherit
	CHESS_PATH_COMPLEX

creation
	make

feature -- Initialization
	make(square: INTEGER; color: INTEGER) is
	require
		valid_square(square);
		valid_piece_color(color);
	local
		s, file, rank: INTEGER;
		rank_start: INTEGER;
		direction: INTEGER;
	do
		file := get_file(square);
		rank := get_rank(square);

		if color = Chess_color_white then
			rank_start := Rank_2;
			direction := 1;
		else
			rank_start := Rank_7;
			direction := -1;
		end

		if rank = rank_start then
			-- pawn is on starting square
			-- double move path's allowed
			ar_make(1, 2);
			s := get_square(file, rank + direction);
			put(s, 1);
			s := get_square(file, rank + 2*direction);
			put(s, 2);

		elseif rank >= Rank_2 and rank <= Rank_7 then
			-- single straight moves
			ar_make(1, 1);
			s := get_square(file, rank + direction);
			put(s, 1);
		else
			-- illegal rank for pawn to be on
			ar_make(0, 1);
		end
	end

feature -- Status Report
	generate_moves(cp: CHESS_POSITION; square, piece: INTEGER;
				mq, cq: CHESS_MOVE_QUEUE) is
	local
		done: BOOLEAN;
		p, idx, to_square: INTEGER;
	do
		if mq /= Void then
			from
				done := False;
				idx := lower;
			until
				(idx > upper) or else (done)
			loop
				to_square := item(idx);
				p := cp.get_piece(to_square);
				if p = Piece_none then
					if idx = 2 then
						mq.put(Move_pawn_double, piece, square, to_square);
					else
						mq.put(Move_pawn, piece, square, to_square);
					end
				else
					done := True;
				end

				idx := idx + 1;
			end
		end
	end
end
