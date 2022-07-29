indexing
	description:	"a WEL control that does fancy static text, and bitmaps"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

class CHESS_GUI_STATIC
inherit
	WEL_CONTROL_WINDOW
	rename
		make as control_make
	export
		{NONE} control_make, make_with_coordinates
	redefine
		on_paint, set_text
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

	WEL_PS_CONSTANTS
	export
		{NONE} all
	end

	CHESS_GUI_CONTROL

creation
	make, make_status

feature -- Initialization
	make(a_parent: CHESS_GUI_WINDOW; a_text: STRING;
					a_left, a_top, a_width, a_height: INTEGER) is
	do
		make_with_coordinates(a_parent, a_text, a_left, a_top, a_width, a_height);
		set_chess_window(a_parent);
		status_mode := False;
	end

	make_status(a_parent: CHESS_GUI_WINDOW; a_text: STRING;
					a_left, a_top, a_width, a_height: INTEGER) is
		--
		-- Useful for drawing status information, like "Winner!", "DRAW", etc..
		--
	do
		make_with_coordinates(a_parent, a_text, a_left, a_top, a_width, a_height);
		set_chess_window(a_parent);
		status_mode := True;
	end

feature -- Access
	set_text(a_text: STRING) is
	do
		Precursor(a_text);
		invalidate;
	end

	on_paint(paint_dc: WEL_PAINT_DC; invalid_rect: WEL_RECT) is
	do
		if status_mode then
			paint_dc.set_text_color(Red);
			paint_dc.set_background_color(bgcolor_status);
			paint_dc.select_brush(bgbrush_status);
			paint_dc.select_pen(pen_status);
			paint_dc.rectangle(client_rect.left, client_rect.top, 
				client_rect.right, client_rect.bottom);
			paint_dc.unselect_pen;
			paint_dc.unselect_brush;
		else
			paint_dc.set_text_color(Black);
			paint_dc.set_background_color(bgcolor);
			paint_dc.select_brush(bgbrush);
			paint_dc.rectangle(client_rect.left, client_rect.top, 
				client_rect.right, client_rect.bottom);
			paint_dc.unselect_brush;

			draw_edge(paint_dc, client_rect, Edge_bump, Bf_rect);
		end

		paint_dc.draw_centered_text(text, client_rect);
	end

feature -- Status Report
feature -- Status Setting
feature -- Element Change
feature -- Removal
feature {NONE} -- Implementation
	status_mode: BOOLEAN;

	bgbrush: WEL_BRUSH is
	do
		!! Result.make_solid(bgcolor);
	end

	bgcolor: WEL_COLOR_REF is
	once
		!! Result.make_rgb(178, 206, 195);
	end

	bgbrush_status: WEL_BRUSH is
	do
		!! Result.make_solid(bgcolor_status);
	end

	bgcolor_status: WEL_COLOR_REF is
	once
		!! Result.make_rgb(150, 182, 170);
	end

	pen_status: WEL_PEN is
	once
		!! Result.make_solid(1, bgcolor_status);
	end

end
