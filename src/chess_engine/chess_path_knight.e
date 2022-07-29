indexing
	description:	"Describes chess squares that the Knight can move to"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

--
-- A KNIGHT path consists of upto 8 squares that a knight can jump to.
-- For some starting squares the number of valid reachable squares can be
-- as low as 2 (such as when the knight is on a corner).
--
-- Our attack logic must check all squares in the list, because the
-- knight can jump.
--

class CHESS_PATH_KNIGHT
inherit
	CHESS_PATH_COMPLEX
	redefine
		under_attack, attacking_squares
	end

creation
	make

feature -- Initialization
	make(square: INTEGER) is
	require
		valid_square(square);
	local
		slst: LINKED_LIST[ INTEGER ];
		i: INTEGER;
		s: INTEGER;
	do
		!! slst.make;

		s := knight_jump(square, 2, 1);
		if valid_square(s) then
			slst.extend(s);
		end

		s := knight_jump(square, 2, -1);
		if valid_square(s) then
			slst.extend(s);
		end

		s := knight_jump(square, -2, 1);
		if valid_square(s) then
			slst.extend(s);
		end

		s := knight_jump(square, -2, -1);
		if valid_square(s) then
			slst.extend(s);
		end

		s := knight_jump(square, 1, 2);
		if valid_square(s) then
			slst.extend(s);
		end

		s := knight_jump(square, 1, -2);
		if valid_square(s) then
			slst.extend(s);
		end

		s := knight_jump(square, -1, 2);
		if valid_square(s) then
			slst.extend(s);
		end

		s := knight_jump(square, -1, -2);
		if valid_square(s) then
			slst.extend(s);
		end

		ar_make(1, slst.count);

		--
		-- Fill the array with the squares
		--
		from
			i := 1;
			slst.start;
		until
			slst.off
		loop
			put(slst.item, i);
			i := i + 1;
			slst.forth;
		end
	ensure
		length >= 2 and length <= 8
	end

feature -- Status Report
	generate_moves(cp: CHESS_POSITION; square: INTEGER; piece: INTEGER;
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
					mq.put(Move_normal, piece, square, to_square);
				end

			elseif enemy_pieces(piece, p) then
				if cq /= Void then
					cq.put(Move_normal, piece, square, to_square);
				end
			end

			i := i + 1;
		end
	end

	under_attack(cp: CHESS_POSITION; side: INTEGER): BOOLEAN is
		-- Returns TRUE if one of the squares in path contains
		-- a knight of color 'side'.
	local
		i, square: INTEGER;
		enemy_knight: INTEGER;
	do
		enemy_knight := get_colored_piece(Piece_type_knight, side);

		from
			Result := False;
			i := lower;
		until
			i > upper or Result
		loop
			square := item(i);
			if cp.get_piece(square) = enemy_knight then
				Result := True;
			end

			i := i + 1;
		end
	end

	attacking_squares(cp: CHESS_POSITION; side: INTEGER): LINKED_LIST[INTEGER] is
		-- Returns a list of squares in which a knight of color 'side'
		-- exists.
	local
		i, square: INTEGER;
		enemy_knight: INTEGER;
	do
		!! Result.make;

		enemy_knight := get_colored_piece(Piece_type_knight, side);

		from
			i := lower;
		until
			i > upper
		loop
			square := item(i);
			if cp.get_piece(square) = enemy_knight then
				Result.extend(square);
			end

			i := i + 1;
		end
	end

feature {NONE} -- Implementation

	--
	-- Verify that a rank or file offset for a knight
	-- jump is valid.
	--
	valid_knight_offset(off: INTEGER): BOOLEAN is
	do
		Result := (off.abs = 1) or (off.abs = 2);
	end

	--
	-- Compute a square that is reachable by a knight jump starting
	-- from square 'square'
	--
	knight_jump(square, rank_offset, file_offset: INTEGER): INTEGER is
	require
		valid_square(square);
		valid_knight_offset(rank_offset);
		valid_knight_offset(file_offset);
		(rank_offset.abs + file_offset.abs) = 3
	local
		rank, file: INTEGER;
	do
		rank := get_rank(square) + rank_offset;
		file := get_file(square) + file_offset;

		if valid_rank(rank) and valid_file(file) then
			Result := get_square(file, rank);
		else
			Result := No_square_specified;
		end

	ensure
		valid_square(Result) or Result = No_square_specified;
	end

end
