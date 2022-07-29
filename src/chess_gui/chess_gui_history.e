indexing
	description:	"Displays the move history for a chess game as a%
			% multi-column list view"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

--
-- This control displays the chess moves in 2 columns
-- The first column is the moves by the White pieces
-- and the 2nd column are the moved by teh Black pieces.
--
-- This control allows us to "mark" a move, which
-- is used when the user scrolls thru the move history.
--
class CHESS_GUI_HISTORY
inherit
	WEL_LIST_VIEW
		rename
			make as make_listview
		end

	CHESS_GUI_CONTROL

	WEL_VK_CONSTANTS
	export
		{NONE} all
	end

	WEL_TVIF_CONSTANTS
	export
		{NONE} all
	end

	WEL_WM_CONSTANTS
	export
		{NONE} all
	end

	WEL_WS_CONSTANTS
	export
		{NONE} all
	end

creation
	make

feature -- Initialization
	make(a_parent: CHESS_GUI_WINDOW; a_left, a_top, a_height: INTEGER) is
	require
		a_parent /= Void;
		a_height >= Height_minimum;
	do
		make_listview(a_parent, a_left, a_top, Total_width, a_height, -1);
		set_chess_window(a_parent);
		initialize;
	end

feature -- Access
	current_ply: INTEGER;

feature -- Status Report
feature -- Status Setting
feature -- Element Change
	clear is
	do
		reset_content;
		set_item_count(0);
		current_ply := 0;
		has_mark := False;
	end

	append_move(move_string: STRING) is
	require
		move_string /= Void;
	local
		litem: WEL_LIST_VIEW_ITEM;
		fint: FORMAT_INTEGER;
		move_idx: INTEGER;
	do
		move_idx := ply_to_row(current_ply);

		if ply_to_column(current_ply) = 1 then
			!! fint.make(3);
			fint.right_justify;
			!! litem.make;
			litem.set_text( fint.formatted( move_idx+1 ) + "." );
			litem.set_iitem(move_idx);
			insert_item(litem);

			set_cell_text(1, move_idx, move_string);
		else
			set_cell_text(2, move_idx, move_string);
		end

		ensure_visible(move_idx);

		current_ply := current_ply + 1;
	end

	remove_last_move is
	require
		current_ply > 0;
	local
		move_idx: INTEGER;
	do
		current_ply := current_ply - 1;

		move_idx := ply_to_row(current_ply);

		if ply_to_column(current_ply) = 1 then
			delete_item(move_idx);
		else
			set_cell_text(2, move_idx, "");
		end

		if has_mark and marked_ply = current_ply then
			has_mark := False;
		end
	end

	mark(ply: INTEGER) is
		-- mark a move in the history list.
	require
		ply >= 0;
		ply < current_ply;
	local
		move_idx: INTEGER;
	do
		if not has_mark or marked_ply /= ply then
			clear_mark;

			move_idx := ply_to_row(ply);

			if ply_to_column(ply) = 1 then
				marked_txt := get_cell_text(1, move_idx);
				set_cell_text(1, move_idx, "> " + marked_txt);
			else
				marked_txt := get_cell_text(2, move_idx);
				set_cell_text(2, move_idx, "> " + marked_txt);
			end

			ensure_visible(move_idx);

			has_mark := True;
			marked_ply := ply;
		end
	end

	clear_mark is
		-- clear a mark if it is set
	local
		move_idx: INTEGER;
	do
		if has_mark then
			move_idx := ply_to_row(marked_ply);

			if ply_to_column(marked_ply) = 1 then
				set_cell_text(1, move_idx, marked_txt);
			else
				set_cell_text(2, move_idx, marked_txt);
			end

			has_mark := False;
		end
	end

feature -- Removal
feature {ANY} -- Constants
	Height_minimum: INTEGER is 50;

feature {NONE} -- Implementation Constants
	Column1_title: STRING is "";
	Column2_title: STRING is "White";
	Column3_title: STRING is "Black";

	Column1_width: INTEGER is 26;
	Column2_width: INTEGER is 68;
	Column3_width: INTEGER is 68;

	Scroll_bar_width: INTEGER is 20;

	Total_width: INTEGER is 
	do
		Result := Column1_width + Column2_width + Column3_width
					+ Scroll_bar_width;
	end

	Bg_color: WEL_COLOR_REF is
	once
		--!! Result.make_rgb(0, 0, 0);
		!! Result.make_rgb(60, 60, 60);
	end

	Fg_color: WEL_COLOR_REF is
	once
		--!! Result.make_rgb(255, 0, 128);
		!! Result.make_rgb(255, 255, 255);
	end


feature {NONE} -- Implementation
	initialize is
	local
		column: WEL_LIST_VIEW_COLUMN;
	do
		set_style(style + Lvs_singlesel);

		set_background_color(Bg_color);
		set_text_background_color(Bg_color);
		set_text_foreground_color(Fg_color);

		clear;

		!! column.make;
		column.set_width(Column1_width);
		column.set_alignment(Lvcfmt_right);
		column.set_text(Column1_title);
		append_column(column);

		!! column.make;
		column.set_width(Column2_width);
		column.set_alignment(Lvcfmt_left);
		column.set_text(Column2_title);
		append_column(column);

		!! column.make;
		column.set_width(Column3_width);
		column.set_alignment(Lvcfmt_left);
		column.set_text(Column3_title);
		append_column(column);

		-- disable;
	end

	ply_to_row(ply: INTEGER): INTEGER is
	require
		ply >= 0;
	do
		Result := (ply // 2);
	ensure
		Result >= 0;
	end

	ply_to_column(ply: INTEGER): INTEGER is
	require
		ply >= 0;
	do
		Result := (ply \\ 2) + 1;
	ensure
		(Result = 1) or (Result = 2);
	end

feature {NONE} -- implementation attributes
	has_mark: BOOLEAN;
	marked_ply: INTEGER;
	marked_txt: STRING;

end
