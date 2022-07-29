indexing
	description:	"transforms screen coordinates to chess square%
			% and visa versa"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

--
-- This class is aware of a screen region defined by:
--	(bounds_x1, bounds_y1, bounds_x2, bounds_y2)
-- that defines the area within a window that the CHESS_GUI_CONTROL
-- occupies.
--
-- 'screen' refers to the absolute window coordinates.
--
-- For drawing we use a simplified virtual coordinate space.
-- This is defined as a rectangle (0, 0, width, height). All drawing
-- into this region will eventually be mapped to the actual coordinates.
--
-- If a transformation routine includes the word 'screen' that means it
-- will be expecting/returning values in screen space.
--
-- if a transformation routine includes the word 'virtual' that means it
-- will expect/return values in the virtual drawing rectangle.
--
-- Virtual drawing area:
--          (0, 0)
--              +-----------------------+
--              |                       |
--              |                       |
--              |                       |
--              |                       |
--              |                       |
--              |                       |
--              |                       |
--              +-----------------------+
--                              (width, height)
--
-- Screen drawing area:
--   (bounds_x1, bounds_y1)
--              +-----------------------+
--              |                       |
--              |                       |
--              |                       |
--              |                       |
--              |                       |
--              |                       |
--              |                       |
--              +-----------------------+
--                              (bounds_x2, bounds_y2)
--
-- The transform is aware of the following sub-components of the chess control:
--
--      +-----------------------------------------------+---------------+
--      |\_____b_o_r_d_e_r_____________________________/| [ 1]  [ 9]    |  
--      ||                                             || [ 2]  [10]    |  
--      ||                                             || [ 3]  [11]    |     Black's
--      |b                                             || [ 4]  [12]    |     Capture
--      |o      C                                      b| [ 5]  [13]    |  C  Area
--      |r        H                                    o| [ 6]  [14]    |  A
--      |d          E                                  r| [ 7]  [15]    |  P
--      |e            S                                d| [ 8]  [16]    |  T
--      |r               S                             e|               |  U
--      ||                                             r+---------------+  R
--      ||                   B                         ||               |  E
--      ||                     O                       ||               |
--      ||                       A                     || [ 8]  [17]    |  A  White's
--      ||                         R                   || [ 7]  [16]    |  R  Capture Area
--      ||                           D                 || [ 6]  [15]    |  E
--      ||                                             || [ 5]  [13]    |  A
--      ||                                             || [ 4]  [12]    |
--      ||                                             || [ 3]  [11]    |
--      ||                                             || [ 2]  [10]    |
--      |/--------b-o-r-d-e-r--------------------------\| [ 1]  [ 9]    |
--      +-----------------------------------------------+---------------+
--
-- The layout for the CHESS_GUI_CONTROL involves the following regions:
--	Chess board - This is the inner region with a border around it
--
--	Border - defined as a certain width and height, this
--		 surrounds the board (defined by border_width, border_height)
--
--	Capture area - this is to the left of the (board+border). This is
--		where we place captured pieces.
--
--	White capture area - this is where white's captured pieces go
--
--	Black capture area - this is where white's captured pieces go
--
--	Capture Slots: Each capture area for white/black contains 16 regions
--		for holding the (upto) 16 captured pieces.
--
-- NOTE: The reference to black/white is relative to the current rotation.
-- When the rotation is changed, we flip black and white areas.
--
-- These transformations set the following return attributes:
--	piece_x, piece_y:
--		top, left coordinate for drawing a chess piece.
--		this may be in screen or virtual coordinates.
--
--	x, y:
--		the top, left coordinates for the entity we transformed to.
--		(could be virtual or screen coordinates)
--
--	width, height:
--		depending on the context this is the total size of the
--		entity we transformed into
--
--	slot:
--		what capture slot did the coordinates map to?
--
--	side:
--		whose capture area? Whose capture slot?
--
--	square:
--		what square did the coordinates map to?
--
--

class CHESS_GUI_TRANSFORM
inherit
	CHESS_SQUARE_CONSTANTS
	CHESS_PIECE_CONSTANTS

creation
	make

feature -- Initialization
	make(x1, y1, x2, y2: INTEGER) is
	require
		x1 >= 0;
		y1 >= 0;
		x2 >= x1;
		y2 >= y1;
	do
		bounds_x1 := x1;
		bounds_y1 := y1;

		bounds_x2 := x2;
		bounds_y2 := y2;
	end

	set_board_size(a_width, a_height: INTEGER) is
		-- this includes the surrounding border
	require
		a_width > 0;
		a_height > 0;
	do
		board_width := a_width;
		board_height := a_height;
	end

	set_border_size(a_width, a_height: INTEGER) is
	require
		a_width >= 0;
		a_height >= 0;
	do
		border_width := a_width;
		border_height := a_height;
	end

	set_piece_size(a_width, a_height: INTEGER) is
	require
		a_width > 0;
		a_height > 0;
	do
		piece_width := a_width;
		piece_height := a_height;
	end

	set_capture_piece_size(a_width, a_height: INTEGER) is
	require
		a_width > 0;
		a_height > 0;
	do
		capture_width := a_width;
		capture_height := a_height;
	end

	set_capture_area_size(a_width, a_height: INTEGER) is
	require
		a_width > 0;
		a_height > 0;
	do
		capture_area_width := a_width;
		capture_area_height := a_height;
	end

feature -- Access
	piece_x, piece_y: INTEGER;
	x, y: INTEGER;
	width, height: INTEGER;
	square: INTEGER;
	slot, side: INTEGER;

feature -- Transformations
	screen_in_bounds(sx, sy: INTEGER): BOOLEAN is
		-- is the screen coordinate (x,y) inside of the overall bounds area?
	do
		if sx < bounds_x1 or sx > bounds_x2 then
			Result := False;
		elseif sy < bounds_y1 or sy > bounds_y2 then
			Result := False;
		else
			Result := True;
		end
	end

	screen_in_board(sx, sy: INTEGER): BOOLEAN is
		-- is the screen coordinate (x,y) inside of the board area?
	do
		if sx < (bounds_x1 + border_width) then
			Result := False;
		elseif sx >= (bounds_x1 + board_width - border_width) then
			Result := False;
		elseif sy < (bounds_y1 + border_height) then 
			Result := False;
		elseif sy >= (bounds_y1 + board_height - border_height) then
			Result := False;
		else
			Result := True;
		end
	end

	screen_in_capture(sx, sy: INTEGER): BOOLEAN is
		-- is the screen coordinate (x,y) inside of the capture area?
	do
	end

	screen_to_virtual(sx, sy: INTEGER) is
	do
		x := sx - bounds_x1;
		y := sy - bounds_y1;
	end

	virtual_to_screen(vx, vy: INTEGER) is
	do
		x := bounds_x1 + vx;
		y := bounds_y1 + vy;
	end

	clamp_screen_to_board(sx, sy: INTEGER) is
		-- transform screen coordinates to nearest
		-- point on the board.
	do
		if sx < (bounds_x1 + border_width) then
			x := (bounds_x1 + border_width);
		elseif sx >= (bounds_x1 + board_width - border_width) then
			x := (bounds_x1 + board_width - border_width)-1;
		else
			x := sx;
		end

		if sy < (bounds_y1 + border_height) then 
			y := (bounds_y1 + border_height);
		elseif sy >= (bounds_y1 + board_height - border_height) then
			y := (bounds_y1 + board_height - border_height)-1;
		else
			y := sy;
		end
	end

	screen_to_square(sx, sy: INTEGER) is
		-- what square does the screen coordinates (sx,sy)
		-- point to?
	require
		screen_in_board(sx, sy);
	local
		tx, ty: INTEGER;
		file, rank: INTEGER;
	do
		tx := sx - (bounds_x1 + border_width);
		ty := sy - (bounds_y1 + border_height);

		file := (tx // square_width) + 1;
		rank := 8 - (ty // square_height);

		file := translate_file(file);
		rank := translate_rank(rank);

		square := get_square(file, rank);
	end

	screen_to_capture(sx, sy: INTEGER) is
	do
		-- what capture slot does the (x,y) coordinate
		-- map to?
	end

	square_color(a_square: INTEGER): INTEGER is
		-- what color is this square?
		-- (A1 is a black square, A2 is white, etc....)
	require
		valid_square(a_square);
	local
		rank, file: INTEGER;
	do
		file := get_file(a_square);
		rank := get_rank(a_square);

		if (file \\ 2) = 1 then
			if (rank \\ 2) = 1 then
				-- odd file, odd rank
				Result := Chess_color_black;
			else
				-- odd file, even rank
				Result := Chess_color_white;
			end
		else
			if (rank \\ 2) = 1 then
				-- even file, odd rank
				Result := Chess_color_white;
			else
				-- even file, even rank
				Result := Chess_color_black;
			end
		end

	ensure
		valid_piece_color(Result);
	end

	promotion_rect is
		-- compute bounds of promotion rectangle
		-- in virtual coordinates.
	local
		s1, s2: INTEGER;
		x1, y1, x2, y2: INTEGER;
	do
		if side_facing_bottom = Chess_color_white then
			s1 := get_square(File_c, Rank_5);
			s2 := get_square(File_h, Rank_3);
		else
			s1 := get_square(File_f, Rank_4);
			s2 := get_square(File_a, Rank_6);
		end

		square_to_virtual(s1);
		x1 := x + square_width//2;
		y1 := y + square_height//3;

		square_to_virtual(s2);
		x2 := x - square_width//2;
		y2 := y - square_height//4;

		x := x1;
		y := y1;
		width := (x2 - x1);
		height := (y2 - y1);
	end

	promotion_slot(a_slot: INTEGER) is
		-- compute coordinates of a pawn promotion slot,
		-- in virtual coordinates.
	require
		a_slot >= 1 and a_slot <= 4;
	local
		px, py: INTEGER;
		xmargin, ymargin: INTEGER;
	do
		promotion_rect;

		xmargin := (width - ((piece_width+5) * 4))//2;
		ymargin := (height - piece_height) - 6;

		px := x + xmargin + (a_slot-1) * (piece_width + 5);
		py := y + ymargin;

		x := px;
		y := py;
		width := piece_width;
		height := piece_height;
	end

	screen_to_promotion_slot(sx, sy: INTEGER) is
		-- is sx, sy inside of a pawn promotion slot?
		-- set 'slot' to the slot that it is in, if result
		-- is True.
	local
		vx, vy: INTEGER;
		ps: INTEGER;
	do
		screen_to_virtual(sx, sy);
		vx := x;
		vy := y;

		from
			slot := 0;
			ps := 1;
		until
			ps > 4 or (slot > 0)
		loop
			promotion_slot(ps);
			if is_inside(vx, vy, x, y, width, height) then
				slot := ps;
			end

			ps := ps + 1;
		end
	end

	square_to_virtual(a_square: INTEGER) is
		-- compute the virtual coordinates for 'a_square'
		-- (left, top, piece_x, piece_y, width, height)
	require
		valid_square(a_square);
	local
		rank, file: INTEGER;
	do
		file := translate_file( get_file(a_square) ) - 1;
		rank := 8 - translate_rank( get_rank(a_square) );

		x := border_width + (file * square_width);
		y := border_height + (rank * square_height);
		width := square_width;
		height := square_height;

		piece_x := x + (square_width - piece_width)//2;
		piece_y := y + (square_height - piece_height)//2;

	end

	square_to_screen(a_square: INTEGER) is
		-- translate a square to screen coordinates
	require
		valid_square(a_square);
	do
		square_to_virtual(a_square);
		virtual_to_screen(x, y);
		virtual_to_screen(piece_x, piece_y);
	end

	capture_to_virtual(a_side, a_slot: INTEGER) is
		-- each side has 16 slots for holding captured pieces
		-- this routine will get the virtual coordinates for
		-- the capture slot.
	require
		valid_piece_color(a_side);
		a_slot >= 1 and a_slot <= 16;
	local
		tside: INTEGER;
		col, row: INTEGER;
		xoffset, yoffset: INTEGER;
		xmargin, ymargin: INTEGER;
	do
		tside := translate_side(a_side);

		xmargin := (capture_area_width - (2*capture_width)) // 2;
		ymargin := (capture_area_height - (16*capture_height)) // 16;

		col := slot_column(a_slot);
		row := slot_row(a_slot);

		xoffset := (col-1) * capture_width + xmargin;

		if tside = Chess_color_white then
			yoffset := capture_area_height
				- row * (capture_height + ymargin);
		else
			yoffset := (row-1) * (capture_height + ymargin);
		end

		piece_x := board_width + xoffset;
		piece_y := yoffset;

		width := capture_width;
		height := capture_height;
	end

feature -- Status Report
	square_width: INTEGER is
	do
		Result := (board_width - (2 * border_width)) // 8;
	end

	square_height: INTEGER is
	do
		Result := (board_height - (2 * border_height)) // 8;
	end

feature -- Status Setting
	set_rotation(a_side: INTEGER) is	
		-- rotate board so that 'a_side' is at the bottom
	require
		valid_piece_color(a_side);
	do
		side_facing_bottom := a_side;
	end

feature -- Element Change

feature -- Removal
feature {NONE} -- Implementation
	side_facing_bottom: INTEGER;

	bounds_x1, bounds_y1: INTEGER;
	bounds_x2, bounds_y2: INTEGER;

	board_width, board_height: INTEGER;
	border_width, border_height: INTEGER;
	piece_width, piece_height: INTEGER;
	capture_width, capture_height: INTEGER;
	capture_area_width, capture_area_height: INTEGER;

	slot_column(a_slot: INTEGER): INTEGER is
	require
		a_slot >= 1 and a_slot <= 16
	do
		if a_slot <= 8 then
			Result := 1;
		else
			Result := 2;
		end
	end

	slot_row(a_slot: INTEGER): INTEGER is
	require
		a_slot >= 1 and a_slot <= 16
	do
		if a_slot > 8 then
			Result := a_slot - 8;
		else
			Result := a_slot;
		end
	end

	translate_side(a_side: INTEGER): INTEGER is
		-- reverse side, if black is facing bottom
	require
		valid_piece_color(a_side);
	do
		if side_facing_bottom = Chess_color_white then
			Result := a_side;
		else
			Result := get_opposite_color(a_side);
		end
	end

	translate_rank(a_rank: INTEGER): INTEGER is
	require
		valid_rank(a_rank);
	do
		if side_facing_bottom = Chess_color_white then
			Result := a_rank;
		else
			Result := 9 - a_rank;
		end
	end

	translate_file(a_file: INTEGER): INTEGER is
	require
		valid_file(a_file);
	do
		-- this works because a chess board
		-- has the same number of rank's as file's
		Result := translate_rank(a_file);
	end

	is_inside(tx, ty, left, top, a_width, a_height: INTEGER): BOOLEAN is
	do
		Result := False;
		if tx >= left and tx <= (left+a_width) then
			if ty >= top and ty <= (top+a_height) then
				Result := True;
			end
		end
	end

end
