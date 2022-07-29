indexing
	description:	"scroll through the moves of a history"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

class CHESS_GUI_HISTORY_SCROLL
inherit
	WEL_SCROLL_BAR
	redefine
		make_vertical, make_horizontal, on_scroll
	end

	WEL_WS_CONSTANTS
	export
		{NONE} all
	end

	CHESS_GUI_CONTROL

creation
	make_vertical, make_horizontal

feature -- Initialization
	make_vertical(a_parent: CHESS_GUI_WINDOW;
			a_x, a_y, a_width, a_height, an_id: INTEGER) is
	do
		Precursor(a_parent, a_x, a_y, a_width, a_height, an_id);
		set_chess_window(a_parent);
		initialize;
	end

	make_horizontal(a_parent: CHESS_GUI_WINDOW;
			a_x, a_y, a_width, a_height, an_id: INTEGER) is
	do
		Precursor(a_parent, a_x, a_y, a_width, a_height, an_id);
		set_chess_window(a_parent);
		initialize;
	end



feature -- Access
feature -- Status Report

feature -- Status Setting
	set_num_plies(nply: INTEGER) is
	do
		num_plies := nply;
		set_range(0, num_plies);
		set_position(num_plies);
	end

feature -- Events
	on_scroll(scroll_code, pos: INTEGER) is
		-- do normal processing, then send message to CHESS_GUI_WINDOW
	do
		Precursor(scroll_code, pos);
		send_chess_scroll(position);
	end

feature -- Element Change
feature -- Removal
feature {NONE} -- Implementation
	num_plies: INTEGER;

	initialize is
	do
		num_plies := 0;
		set_style(style - Ws_tabstop);
		set_line(1);
		set_page(1);
	end

end
