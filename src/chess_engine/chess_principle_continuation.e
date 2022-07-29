indexing
	description:	"contains the best sequence of moves found during a search"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

--
-- Internal represenation is a 2-d array of move's:
--
-- max depth = 4
--
--                  depth
--                1   2   3   4
--              +---+---+---+---+
--         1    | E | I | F |   |       length[1] = 3
--   D          +---+---+---+---+
--   E     2    |   | I | F |   |       length[2] = 2
--   P          +---+---+---+---+
--   T     3    |   |   | F | L |       length[3] = 2
--   H          +---+---+---+---+
--         4    |   |   |   | L |       length[4] = 1
--              +---+---+---+---+
--
--
-- As we traverse the search tree, this data structure is loaded
-- with the best move at each level. When a new best move is
-- added we also copy the best moves from the deeper ply's
--
-- In this example the best sequence of moves is indicated by the top row
-- of the array: "E"  "I"   "F" 
--

class CHESS_PRINCIPLE_CONTINUATION
inherit
	ARRAY2[ CHESS_MOVE ]
	rename
		make as ar_make,
		put as ar_put
	export
		{NONE} all
	end

creation
	make

feature -- Initialization
	make(maxd: INTEGER) is
	require
		maxd >= 0;
	local
		mov: CHESS_MOVE;
		i, j: INTEGER;
	do
		max_depth := maxd;
		ar_make(maxd+1, maxd+1);
		!! pclength.make(1, maxd+1);

		--
		-- fill array with CHESS_MOVE's
		-- (just the diagonal portion of the array)
		--
		from
			i := 1;
		until
			i > max_depth
		loop
			from
				j := i;
			until
				j > max_depth
			loop
				!! mov.make_empty;
				ar_put(mov, i, j);
				j := j + 1;
			end
			i := i + 1;
		end
	end

feature -- Access
	max_depth: INTEGER;

	best: CHESS_MOVE is
		-- the best move in PC
		-- will be valid at the end of the tree search
	do
		!! Result.make_from_other( item(1, 1) );
	end

	get(depth: INTEGER): CHESS_MOVE is
		-- get a move from index (depth, depth)
	require
		depth >= 0 and depth <= max_depth;
	local
		ply: INTEGER;
	do
		ply := get_ply(depth);
		!! Result.make_from_other( item(ply, ply) );
	end

feature -- Status Report
	best_line: LINKED_LIST[ CHESS_MOVE ] is
		-- this is the 'pc' as a list of moves
	local
		j: INTEGER;
		mov: CHESS_MOVE;
	do
		!! Result.make;

		from
			j := 1;
		until
			j > length(max_depth)
		loop
			!! mov.make_from_other( item(1, j) );
			Result.extend( mov );
			j := j + 1;
		end
	end

	best_line_out(cp: CHESS_POSITION): STRING is
		-- display best sequence of moves in algebraic notation
	require
		cp /= Void;
	do
		Result := best_out(cp, 1);

		if Result = Void then
			!! Result.make(10);
			Result.append("nothing");
		end
	ensure
		Result /= Void;
	end

	length(depth: INTEGER): INTEGER is
		-- length of the principle continuation for 'depth'
	require
		depth >= 0 and depth <= max_depth;
	local
		ply: INTEGER;
	do
		ply := get_ply(depth);
		Result := pclength.item(ply) - 1;
	end

feature -- Status Setting
	set_length(depth: INTEGER) is
		-- set the length for 'depth' to 'depth'
	require
		depth >= 0 and depth <= max_depth;
	local
		ply: INTEGER;
	do
		ply := get_ply(depth);
		pclength.put(ply, ply);
	end

feature -- Element Change
	--
        -- Depth = 2, mov = C
        -- Before:
        --        1   2   3   4
        --      +---+---+---+---+
        --   1  |   |   |   |   |
        --      +---+---+---+---+
        --   2  |   | J | W | X |
        --      +---+---+---+---+
        --   3  |   |   | B | A |
        --      +---+---+---+---+
        --   4  |   |   |   | A |
        --      +---+---+---+---+
        --
        -- After:
        --        1   2   3   4
        --      +---+---+---+---+
        --   1  |   |   |   |   |
        --      +---+---+---+---+
        --   2  |   | C | B | A |
        --      +---+---+---+---+
        --   3  |   |   | B | A |
        --      +---+---+---+---+
        --   4  |   |   |   | A |
        --      +---+---+---+---+
	--
	set_best_move(depth: INTEGER; mov: CHESS_MOVE) is
		-- set best move for 'depth' and copy best
		-- moves from the deeper depths.
	require
		mov /= Void;
		depth >= 0 and depth <= max_depth;
	local
		ply, j, len: INTEGER;
		m: CHESS_MOVE;
	do
		ply := get_ply(depth);

		put(mov, ply, ply);

		from
			len := pclength.item(ply+1);
			j := ply+1;
		until
			j >= len
		loop
			m := item(ply+1, j);
			put(m, ply, j);

			j := j + 1;
		end

		pclength.put(len, ply);
	end

feature -- Removal

feature {NONE} -- Implementation
	put(v: CHESS_MOVE; row, column: INTEGER) is
		-- copy 'v' object to the object located in (row, column)
		-- (ar_put copies this reference, this routine copies the object)
	local
		mov: CHESS_MOVE;
	do
		mov := item(row, column);
		mov.copy(v);
	end

	--
	-- Indexed by ply. Contains the length of the PC at this level
	--
	pclength: ARRAY[ INTEGER ];

	--   DEPTH	PLY
	--   5		1
	--   4		2
	--   3		3
	--   2		4
	--   1		5
	--   0		6
	--
	get_ply(d: INTEGER): INTEGER is
		-- translates a depth 'd' into a proper index for the array.
	require
		d >= 0 and d <= max_depth;
	do
		Result := (max_depth - d) + 1;
	end

	best_out(cp: CHESS_POSITION; j: INTEGER): STRING is
	require
		cp /= Void;
	local
		saved_state: CHESS_STATE;
		tail_str, s: STRING;
		mov: CHESS_MOVE;
	do
		if j > length(max_depth) then
			Result := Void;
		else
			mov := item(1, j);
			if mov.valid(cp) then
				!! saved_state.make;
				saved_state.copy(cp.state);
				mov.move(cp);

				tail_str := best_out(cp, j+1);

				mov.take_back(cp);
				cp.set_state(saved_state);

				s := mov.algebraic_notation(cp);
			else
				tail_str := best_out(cp, j+1);
				!! s.make(10);
				s.append("INV");
			end

			if tail_str /= Void then
				Result := s + ", " + tail_str;
			else
				Result := s;
			end
		end

	end

end
