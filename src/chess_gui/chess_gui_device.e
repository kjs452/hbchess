indexing
	description:	"device handle for drawing chess objects to screen"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

--
-- This object handles the bitmap drawing tasks
--
-- It maintains several memory bitmaps that we draw into, and
-- then we copy to the screen when we are aready.
--
-- All drawing is done on a virtual_dc, whose coordinate system
-- is defined as:
--
--           (0,0)
--              +---------------+
--              |               |
--              | virtual DC    |
--              |               |
--              |               |
--              +---------------+
--                      (client.width, client.height)
--
-- When we're done drawing into virtual_dc, we bit_blt the
-- results back to the window_dc. The coordinates system for
-- window_dc is:
--
--(client.left, client.top)
--              +---------------+
--              |               |
--              | window DC     |
--              |               |
--              |               |
--              +---------------+
--                      (client.width, client.height)
--
--
class CHESS_GUI_DEVICE
inherit
	WEL_RASTER_OPERATIONS_CONSTANTS
	export
		{NONE} all
	end

	WEL_PS_CONSTANTS
	export
		{NONE} all
	end

	WEL_DRAWING_ROUTINES
	export
		{NONE} all
	end

	WEL_DRAWING_ROUTINES_CONSTANTS
	export
		{NONE} all
	end

	WEL_STANDARD_COLORS
	export
		{NONE} all
	end

	CHESS_PIECE_CONSTANTS

creation
	make

feature -- Initialization
	make(a_parent: WEL_WINDOW; a_client: WEL_RECT) is
		-- a_client is the region on the parent window
		-- we want to manage.
	require
		a_parent /= Void;
		a_parent.exists
		a_client /= Void;
	do
		parent := a_parent;
		client := a_client;

		!! clip_region.make_rect(client.left, client.top, client.right, client.bottom);

		!! window_dc.make(parent);
		window_dc.get;

		!! virtual_dc.make;
		!! virtual_bitmap.make_compatible(window_dc,
					client.width, client.height);
		virtual_dc.select_bitmap(virtual_bitmap);

		!! draw_dc.make;

		!! double_dc.make;
		!! double_bitmap.make_compatible(window_dc, Max_bm_width, Max_bm_height);
		double_dc.select_bitmap(double_bitmap);
	end

feature -- Access
feature -- Drawing
	draw(x, y: INTEGER; sprite: CHESS_GUI_SPRITE) is
		-- draw a sprite at x, y to virtual_dc ONLY
	do
		virtual_dc.draw_bitmap(sprite.bitmap, x, y, sprite.width, sprite.height);
	end

	draw_win(x, y: INTEGER; sprite: CHESS_GUI_SPRITE) is
		-- draw a sprite at x, y on window_dc ONLY
	local
		wx, wy: INTEGER;
	do
		wx := client.x + x;
		wy := client.y + y;
		window_dc.draw_bitmap(sprite.bitmap, wx, wy, sprite.width, sprite.height);
	end

	draw_transparent(x, y: INTEGER; sprite, mask: CHESS_GUI_SPRITE) is
		-- draw sprite transparently to virtual_dc ONLY
	require
		sprite /= Void;
		mask /= Void;
	do
		draw_dc.select_bitmap(mask.bitmap);
		virtual_dc.bit_blt(x, y, mask.width, mask.height, draw_dc, 0, 0, Srcand);

		draw_dc.unselect_bitmap;

		draw_dc.select_bitmap(sprite.bitmap);
		virtual_dc.bit_blt(x, y, sprite.width, sprite.height,
						draw_dc, 0, 0, Srcpaint);
		draw_dc.unselect_bitmap;
	end

	draw_transparent_win(x, y: INTEGER; sprite, mask: CHESS_GUI_SPRITE) is
		-- draw transparent sprite, to window_dc.
		-- (virtual_dc not affected)
	require
		sprite /= Void;
		mask /= Void;
	local
		wx, wy: INTEGER;
	do
		wx := client.x + x;
		wy := client.y + y;

		double_dc.bit_blt(0, 0, sprite.width, sprite.height, window_dc, wx, wy, Srccopy);

		draw_dc.select_bitmap(mask.bitmap);
		double_dc.bit_blt(0, 0, mask.width, mask.height, draw_dc, 0, 0, Srcand);
		draw_dc.unselect_bitmap;

		draw_dc.select_bitmap(sprite.bitmap);
		double_dc.bit_blt(0, 0, sprite.width, sprite.height, draw_dc, 0, 0, Srcpaint);
		draw_dc.unselect_bitmap;

		window_dc.select_region(clip_region);
		window_dc.bit_blt(wx, wy, sprite.width, sprite.height, double_dc, 0, 0, Srccopy);
		window_dc.unselect_region;
	end

	draw_promotion_rect(x1, y1, x2, y2: INTEGER) is
		-- draw a raised filled rectangle to virtual_dc ONLY
	local
		rect: WEL_RECT;
	do
		!! rect.make(x1, y1, x2, y2);

		virtual_dc.select_pen(Promotion_pen);
		virtual_dc.select_brush(Promotion_brush);
		virtual_dc.rectangle(x1, y1, x2, y2);
		draw_edge(virtual_dc, rect, Edge_raised, Bf_rect);
		virtual_dc.unselect_pen;
		virtual_dc.unselect_brush;
	end

	draw_promotion_text(x1, y1, x2, y2: INTEGER; txt: STRING) is
		-- draw text at x,y to virtual_dc ONLY
	local
		text_rect: WEL_RECT;
	do
		!! text_rect.make(x1, y1, x2, y2);

		virtual_dc.set_background_transparent;
		virtual_dc.set_text_color(Black);
		virtual_dc.draw_centered_text(txt, text_rect);
	end

	erase_cursor(sprite: CHESS_GUI_SPRITE; x, y, width, height: INTEGER) is
		-- erase cursor on window_dc and virtual_dc
		-- 'sprite' is used to determine what color to draw
	require
		sprite /= Void;
	local
		pen: WEL_PEN;
	do
		!! pen.make(Ps_insideframe, 2, sprite.color);
		draw_rect_both(pen, x, y, width, height);
	end

	draw_cursor(x, y, width, height: INTEGER) is
		-- draw rectangle to window_dc
	do
		draw_rect_both(Yellow_pen, x, y, width, height);
	end

	save_area(x, y, width, height: INTEGER) is
		-- save an area of the window_dc into the virtual_dc
	local
		wx, wy: INTEGER;
	do
		wx := client.x + x;
		wy := client.y + y;
		virtual_dc.bit_blt(x, y, width, height, window_dc, wx, wy, Srccopy);
	end

	restore_area(x, y, width, height: INTEGER) is
		-- restore an area from virtual_dc to window_dc
	local
		wx, wy: INTEGER;
	do
		wx := client.x + x;
		wy := client.y + y;
		window_dc.bit_blt(wx, wy, width, height, virtual_dc, x, y, Srccopy);
	end

	save_window is
		-- save all the window_dc pixels to the virtual_dc
	do
		save_area(0, 0, client.width, client.height);
	end

	restore_window is
		-- copy all virtual_dc pixels back to window_dc
	do
		restore_area(0, 0, client.width, client.height);
	end

	virtual_to_dc(paint_dc: WEL_PAINT_DC; invalid_rect: WEL_RECT) is
		-- copy virtual to paint dc
	do
		paint_dc.copy_dc(virtual_dc, invalid_rect);
	end

feature -- Status Report
	Max_bm_width: INTEGER is 100;
	Max_bm_height: INTEGER is 100;
		-- defines the largest bitmap we can draw transparently

feature -- Status Setting
feature -- Element Change
feature -- Removal
	delete is
		-- dispose of the DC's when done with this object
	do
		window_dc.unselect_all;
		virtual_dc.unselect_all;
		draw_dc.unselect_all;
		double_dc.unselect_all;

		window_dc.delete;
		virtual_dc.delete;
		draw_dc.delete;
		double_dc.delete;
	end

feature {NONE} -- Implementation
	parent: WEL_WINDOW;
	window_dc: WEL_CLIENT_DC;
	virtual_dc: WEL_MEMORY_DC;
	draw_dc: WEL_MEMORY_DC;
	client: WEL_RECT;
	clip_region: WEL_REGION;
	virtual_bitmap: WEL_BITMAP;

	double_bitmap: WEL_BITMAP;
	double_dc: WEL_MEMORY_DC;

	draw_rect_both(pen: WEL_PEN; x, y, width, height: INTEGER) is
		-- draw rect using 'pen' to both virtual_dc and window_dc
	require
		pen /= Void;
	local
		wx, wy: INTEGER;
	do
		wx := client.x + x;
		wy := client.y + y;

		window_dc.select_pen(pen);
		window_dc.select_brush(Hollow_brush);

		window_dc.rectangle(wx, wy, wx + width, wy + height);

		window_dc.unselect_pen;
		window_dc.unselect_brush;

		virtual_dc.select_pen(pen);
		virtual_dc.select_brush(Hollow_brush);

		virtual_dc.rectangle(x, y, x + width, y + height);

		virtual_dc.unselect_pen;
		virtual_dc.unselect_brush;
	end

	Hollow_brush: WEL_HOLLOW_BRUSH is
	once
		!! Result.make;
	end

	Yellow_pen: WEL_PEN is
		-- pen used for drawing cursor on chess board
	once
		!! Result.make(Ps_insideframe, 2, Yellow);
	end

	Promotion_pen: WEL_PEN is
	local
		c: WEL_COLOR_REF;
	once
		!! c.make_rgb(206, 206, 148);
		!! Result.make_solid(1, c);
	end

	Promotion_brush: WEL_BRUSH is
	local
		c: WEL_COLOR_REF;
	once
		!! c.make_rgb(206, 206, 148);
		!! Result.make_solid(c);
	end

end
