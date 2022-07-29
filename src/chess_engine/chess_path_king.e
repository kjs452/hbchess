indexing
	description:	"Describes chess squares that the King can move to"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

--
-- A KING path consists of all the adjacent squares it can move to.
-- The number of such valid squares can be from 8 to 3.
--
class CHESS_PATH_KING
inherit
	CHESS_PATH_COMPLEX

creation
	make

feature -- Initialization
	make(square: INTEGER) is
	require
		valid_square(square);
	local
		slst: LINKED_LIST[ INTEGER ];
		rank_offset, file_offset: INTEGER;
		rank, file: INTEGER;
		s: INTEGER;
		i: INTEGER;
	do
		!! slst.make;

		--
		-- Generate the 8 squares surrounding the king
		-- as possible moves.
		--
		from
			rank_offset := -1;
		until
			rank_offset > 1
		loop
			from
				file_offset := -1;
			until
				file_offset > 1
			loop
				if file_offset /= 0 or rank_offset /= 0 then
					rank := get_rank(square) + rank_offset;
					file := get_file(square) + file_offset;
					if valid_rank(rank) and valid_file(file) then
						s := get_square(file, rank);
						slst.extend(s);
					end
				end

				file_offset := file_offset + 1;
			end

			rank_offset := rank_offset + 1;
		end

		ar_make(1, slst.count);

		--
		-- Fill the array with the squares
		--
		from
			i := lower;
			slst.start;
		until
			slst.off
		loop
			put(slst.item, i);
			i := i + 1;
			slst.forth;
		end
	end

feature -- Status Report
	--
	-- Generate the (up to) 8 possible moves for a king.
	--
	generate_moves(cp: CHESS_POSITION; square, piece: INTEGER;
				mq, cq: CHESS_MOVE_QUEUE) is
	local
		i: INTEGER;
		p, to_square: INTEGER;
	do
		from
			i := lower;
		until
			i > upper
		loop
			to_square := item(i);

			p := cp.get_piece(to_square);
			if p = Piece_none then
				if mq /= Void then
					mq.put(Move_king, piece, square, to_square);
				end
			elseif enemy_pieces(piece, p) then
				if cq /= Void then
					cq.put(Move_king, piece, square, to_square);
				end
			end

			i := i + 1;
		end
	end

feature {NONE} -- Implementation

end
