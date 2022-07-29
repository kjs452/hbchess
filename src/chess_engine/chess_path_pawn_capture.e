indexing
	description:	"Describes chess squares involving Pawn captures"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

--
-- This class covers the pawn capture behavior. Pawns
-- may capture the two immediate diagonal squares in the direction
-- of pawn movement. Direction is determined based on piece color.
-- (e.p. captures are handled by a child class)
--
class CHESS_PATH_PAWN_CAPTURE
inherit
	CHESS_PATH_PAWN
	redefine
		make, generate_moves, under_attack, attacking_squares
	end

creation
	make, make_attack

feature -- Initialization
	make(square: INTEGER; color: INTEGER) is
	local
		new_file, file, rank: INTEGER;
		s1, s2, idx, direction: INTEGER;
	do
		file := get_file(square);
		rank := get_rank(square);

		if color = Chess_color_white then
			direction := 1;
		else
			direction := -1;
		end

		if pawn_capture_rank(rank, color) then
			idx := 0;
			new_file := file - 1;
			if valid_file(new_file) then
				s1 := get_square(new_file, rank + direction);
				idx := idx + 1;
			end

			new_file := file + 1;
			if valid_file(new_file) then
				s2 := get_square(new_file, rank + direction);
				idx := idx + 1;
			end

			ar_make(1, idx);
			idx := 1;
			if valid_square(s1) then
				put(s1, idx);
				idx := idx + 1;
			end

			if valid_square(s2) then
				put(s2, idx);
			end

		else
			-- illegal rank for pawn to be on.
			ar_make(1, 0);
		end
	end

	make_attack(square: INTEGER; color: INTEGER) is
		-- Generate a path for the two squares that can
		-- attack 'square' with a pawn of color 'color'
	local
		new_file, file, rank: INTEGER;
		s1, s2, idx, direction: INTEGER;
		minr, maxr: INTEGER;
	do
		file := get_file(square);
		rank := get_rank(square);

		if color = Chess_color_white then
			direction := -1;
			minr := Rank_3;
			maxr := Rank_8;
		else
			direction := 1;
			minr := Rank_1;
			maxr := Rank_6;
		end

		if (rank >= minr) and (rank <= maxr) then
			idx := 0;
			new_file := file - 1;
			if valid_file(new_file) then
				s1 := get_square(new_file, rank + direction);
				idx := idx + 1;
			end

			new_file := file + 1;
			if valid_file(new_file) then
				s2 := get_square(new_file, rank + direction);
				idx := idx + 1;
			end

			ar_make(1, idx);
			idx := 1;
			if valid_square(s1) then
				put(s1, idx);
				idx := idx + 1;
			end

			if valid_square(s2) then
				put(s2, idx);
			end

		else
			-- illegal rank for pawn to be on.
			ar_make(1, 0);
		end
	end

feature -- Status Report

	generate_moves(cp: CHESS_POSITION; square, piece: INTEGER;
				mq, cq: CHESS_MOVE_QUEUE) is
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
					cq.put(Move_pawn, piece, square, dst);
				end
			end

			idx := idx + 1;
		end
	end

	under_attack(cp: CHESS_POSITION; side: INTEGER): BOOLEAN is
		-- is there a piece of color 'side' that can attack
		-- along this path?
	local
		i, square, piece: INTEGER;
		attacking_pawn: INTEGER;
	do
		Result := False;
		attacking_pawn := get_colored_piece(Piece_type_pawn, side);

		from
			i := lower;
		until
			i > upper or Result
		loop
			square := item(i);
			piece := cp.get_piece(square);
			if piece = attacking_pawn then
				Result := True;
			end

			i := i + 1;
		end

	end

	attacking_squares(cp: CHESS_POSITION; side: INTEGER): LINKED_LIST[INTEGER] is
		-- list of squares that contain pieces of color 'side' that
		-- can attack along this path.
	local
		i, square, piece: INTEGER;
		attacking_pawn: INTEGER;
	do
		!! Result.make;
		attacking_pawn := get_colored_piece(Piece_type_pawn, side);

		from
			i := lower;
		until
			i > upper
		loop
			square := item(i);
			piece := cp.get_piece(square);
			if piece = attacking_pawn then
				Result.extend(square);
			end

			i := i + 1;
		end
	end


feature {NONE} -- Implementation
	pawn_capture_rank(rank: INTEGER; color: INTEGER): BOOLEAN is
		--
		-- Valid ranks for pawns are: ranks 2 thru 7.
		--
	require
		valid_rank(rank);
		valid_piece_color(color);
	do
		Result := (rank >= Rank_2) and (rank <= Rank_7);
	end

end
