indexing
	description:	"Describes straight or diagonal movement for a chess square"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

deferred class CHESS_PATH_SLIDE
inherit
	CHESS_PATH
	redefine
		under_attack, attacking_squares
	end

	ARRAY[ INTEGER ]
	rename
		make as ar_make
	export
		{NONE} all
	undefine
		copy, is_equal
	end

feature -- Initialization
	make(square: INTEGER) is
		-- normal make procedure.
		-- Set move_type to Move_normal.
	require
		valid_square(square);
	do
		make_with_type(square, Move_normal);
	end

	make_with_type(square: INTEGER; type: INTEGER) is
	require
		valid_square(square);
		valid_move_type(type);
	local
		s: INTEGER;
		len, i: INTEGER;
	do
		move_type := type;

		--
		-- Find out how many squares in this path
		--
		from
			s := next_square(square);
			len := 0;
		until
			not valid_square(s)
		loop
			len := len + 1;
			s  := next_square(s);
		end

		ar_make(1, len);

		--
		-- Fill array with squares
		--
		from
			s := next_square(square);
			i := lower;
		until
			not valid_square(s)
		loop
			put(s, i);
			i := i + 1;
			s  := next_square(s);
		end
	end

feature -- Access
	length: INTEGER is
	do
		Result := count;
	end

feature -- Status Report
	--
	-- produce all moves for sliding pieces:
	-- Generates moves for: QUEEN, BISHOP, and ROOK
	--
	-- 'move_type' will usually be Move_normal. But
	-- Rooks moving from initial squares will have
	-- special move types:
	--	Move_qrook (rook moving from queen-side starting position)
	--	Move_krook (rook moving from king-side starting position)
	--
	-- Captures will go into 'cq'
	-- Non-capture moves will go into 'mq'
	--
	generate_moves(cp: CHESS_POSITION; square, piece: INTEGER;
				mq, cq: CHESS_MOVE_QUEUE) is
	local
		done: BOOLEAN;
		i, p, to_square: INTEGER;
	do
		from
			done := False;
			i := lower;
		until
			i > upper or done
		loop
			to_square := item(i);
			p := cp.get_piece(to_square);

			if p /= Piece_none then
				done := True;
				if enemy_pieces(piece, p) then
					-- CAPTURE!
					if cq /= Void then
						cq.put(move_type, piece, square, to_square);
					end
				end
			else
				if mq /= Void then
					-- non-capture move
					mq.put(move_type, piece, square, to_square);
				end
			end

			i := i + 1;
		end
	end

	under_attack(cp: CHESS_POSITION; side: INTEGER): BOOLEAN is
		-- is there a piece of color 'side' that can attack
		-- along this path?
	local
		i, square, piece: INTEGER;
		done: BOOLEAN;
		attacking_queen, attacking_king, attacking_piece: INTEGER;
	do
		Result := False;

		attacking_queen := get_colored_piece(Piece_type_queen, side);
		attacking_king := get_colored_piece(Piece_type_king, side);
		attacking_piece := get_colored_piece(attacking_piece_type, side);

		from
			i := lower;
		until
			i > upper or done
		loop
			square := item(i);
			piece := cp.get_piece(square);
			if piece /= Piece_none then
				done := True;
				if (piece = attacking_queen)
					or else (piece = attacking_piece)
					or else (piece = attacking_king and i = lower)
				then
					Result := True;
				end
			end

			i := i + 1;
		end
	end

	attacking_squares(cp: CHESS_POSITION; side: INTEGER): LINKED_LIST[INTEGER] is
		-- list of squares that contain pieces of color 'side' that
		-- can attack along this path.
	local
		i, square, piece: INTEGER;
		done: BOOLEAN;
		attacking_queen, attacking_king, attacking_piece: INTEGER;
	do
		!! Result.make;

		attacking_queen := get_colored_piece(Piece_type_queen, side);
		attacking_king := get_colored_piece(Piece_type_king, side);
		attacking_piece := get_colored_piece(attacking_piece_type, side);

		from
			i := lower
		until
			i > upper or done
		loop
			square := item(i);
			piece := cp.get_piece(square);
			if piece /= Piece_none then
				done := True;
				if (piece = attacking_queen)
					or else (piece = attacking_piece)
					or else (piece = attacking_king and i = lower)
				then
					Result.extend(square);
				end
			end

			i := i + 1;
		end
	end

feature {NONE} -- Implementation
	attacking_piece_type: INTEGER is
		-- aside from queen, this is the piece type of either
		-- a rook (STRAIGHT_PATH) or bishop (DIAGONAL_PATH)
	deferred
	end

	next_square(s: INTEGER): INTEGER is
		-- Displace the input square 's' by rank-offset and
		-- file-offset. Return the new square.
		-- If we exceed the board bounds, return No_square_specified
	require
		valid_square(s);
	local
		file, rank: INTEGER;
	do
		file := get_file(s) + file_offset;
		rank := get_rank(s) + rank_offset;
		if valid_file(file) and valid_rank(rank) then
			Result := get_square(file, rank);
		else
			Result := No_square_specified;
		end
	ensure
		valid_square(Result) or Result = No_square_specified
	end

	rank_offset: INTEGER is
	deferred
	end

	file_offset: INTEGER is
	deferred
	end

	move_type: INTEGER;
		-- What move type to use for move generated
		-- from this square?
		--
		-- Only rook movement will produce something
		-- other than Move_normal. (See CHESS_PATH_STRAIGHT).
		--

end
