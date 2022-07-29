indexing
	description:	"a WEL control for a clickable image button that can be turned on/off"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

class CHESS_GUI_IMAGE_BUTTON
inherit
	WEL_CONTROL_WINDOW
	rename
		make as control_make
	export
		{NONE} control_make, make_with_coordinates
	redefine
		on_paint, on_left_button_down, on_set_focus, on_kill_focus,
		on_mouse_move
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

	CHESS_GUI_CONTROL

creation
	make

feature -- Initialization
	make(a_parent: CHESS_GUI_WINDOW; a_left, a_top, on_id, off_id: INTEGER) is
	do
		!! on_bitmap.make_by_id(on_id);
		!! off_bitmap.make_by_id(off_id);

		make_with_coordinates(a_parent, "", a_left, a_top,
						on_bitmap.width, on_bitmap.height);
		set_chess_window(a_parent);

		turn_on;
	end

feature -- Access
	on_paint(paint_dc: WEL_PAINT_DC; invalid_rect: WEL_RECT) is
	do
		paint_dc.draw_bitmap(current_bitmap, 0, 0,
				current_bitmap.width, current_bitmap.height);

		if has_focus then
			draw_edge(paint_dc, client_rect, Edge_raised, Bf_rect);
		end
	end

	on_mouse_move(keys, x_pos, y_pos: INTEGER) is
	do
		if not has_focus then
			set_focus;
		end
	end

	on_set_focus is
	do
		invalidate;
	end

	on_kill_focus is
	do
		invalidate;
	end

feature -- Status Report
	is_on: BOOLEAN;

feature -- Status Setting
	turn_on is
	do
		if not is_on then
			is_on := True;
			current_bitmap := on_bitmap;
			invalidate;
		end
	end

	turn_off is
	do
		if is_on then
			is_on := False;
			current_bitmap := off_bitmap;
			invalidate;
		end
	end

	toggle is
	do
		if is_on then
			turn_off;
		else
			turn_on;
		end
	end

feature -- Element Change
feature -- Removal
feature {NONE} -- Implementation
	current_bitmap: WEL_BITMAP;
	on_bitmap: WEL_BITMAP;
	off_bitmap: WEL_BITMAP;

	on_left_button_down(keys, x_pos, y_pos: INTEGER) is
	do
		toggle;
		send_chess_button_click(is_on);
	end

end
