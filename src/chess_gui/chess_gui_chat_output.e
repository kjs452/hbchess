indexing
	description:	"this control display the chat output"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

class CHESS_GUI_CHAT_OUTPUT
inherit
	WEL_RICH_EDIT
	rename
		make as wel_make
	export
		{NONE} wel_make
	redefine
		default_style, on_mouse_move, on_left_button_down
	end

	WEL_IDC_CONSTANTS
	export
		{NONE} all
	end

	CHESS_GUI_CONTROL

creation
	make

feature -- Initialization
	make(a_parent: CHESS_GUI_WINDOW; a_x, a_y, a_width, a_height: INTEGER) is
	do
		wel_make(a_parent, "", a_x, a_y, a_width, a_height, -1);
		set_chess_window(a_parent);
		set_read_only;
		disable_scroll_caret_at_selection;
		!! linkdb.make;
		!! temp_point.make(0,0);
	end

feature -- Access
feature -- Status Report
feature -- Status Setting

feature -- Element Change
	append_sentence(sentence: CHESS_GUI_CHAT_SENTENCE) is
		-- append a sentence to the rich_edit control
		-- format text using color/font as indicated inside
		-- of 'sentence'
	require
		sentence /= Void;
	local
		phrase: CHESS_GUI_CHAT_PHRASE;
		fmt: WEL_CHARACTER_FORMAT;
		start_pos, end_pos: INTEGER;
	do
		set_caret_position(text_length);
		insert_text("%N");

		from
			sentence.start;
		until
			sentence.off
		loop
			phrase := sentence.item;
			fmt := phrase_format(sentence, phrase);
			if has_selection then
				unselect;
			end

			set_character_format_selection(fmt);

			if phrase.is_link then
				start_pos := text_length;
			end

			insert_text(phrase.text);

			if phrase.is_link then
				end_pos := text_length;
				linkdb.add(start_pos, end_pos, phrase.link_data);
			end

			sentence.forth;
		end
		move_to_selection;
		set_caret_position(text_length);
	end

	append_newline is
	do
		set_caret_position(text_length);
		insert_text("%N");
		set_caret_position(text_length);
	end

feature -- Removal
feature {NONE} -- Implementation
	default_style: INTEGER is
	once
		Result := Ws_visible + Ws_child + Ws_border +
				Ws_vscroll + Es_savesel +
				Es_disablenoscroll + Es_multiline
	end

	phrase_format(sentence: CHESS_GUI_CHAT_SENTENCE;
			phrase: CHESS_GUI_CHAT_PHRASE): WEL_CHARACTER_FORMAT is
	require
		sentence /= Void;
		phrase /= Void;
	do
		if sentence.is_system then
			Result := system_format;
		elseif sentence.is_hotbabe then
			Result := hotbabe_format;
		end

		if phrase.is_normal then
			Result.unset_bold;
			Result.unset_underline;
		elseif phrase.is_bold then
			Result.set_bold;
			Result.unset_underline;
		elseif phrase.is_link then
			Result := link_format;
			Result.unset_bold;
		end
	ensure
		Result /= Void;
	end

	system_format: WEL_CHARACTER_FORMAT is
		-- what does text generated by the "system" look like?
	local
		f: WEL_ANSI_VARIABLE_FONT;
		c: WEL_COLOR_REF;
	once
		!! f.make;
		!! c.make_rgb(0, 0, 0);
		
		!! Result.make;
		Result.set_text_color(c);
		set_format_font(Result, f.log_font);
		Result.set_text_color(c);
	end

	hotbabe_format: WEL_CHARACTER_FORMAT is
		-- what does text generated by hotbabe look like?
	local
		f: WEL_ANSI_VARIABLE_FONT;
		c: WEL_COLOR_REF;
	once
		!! f.make;
		!! c.make_rgb(255, 0, 128);

		!! Result.make;
		set_format_font(Result, f.log_font);
		Result.set_text_color(c);
	end

	link_format: WEL_CHARACTER_FORMAT is
		-- how do we format fake URL's into the chat window?
	local
		f: WEL_ANSI_VARIABLE_FONT;
		c: WEL_COLOR_REF;
	once
		!! f.make;
		!! c.make_rgb(0, 0, 255);

		!! Result.make;
		set_format_font(Result, f.log_font);
		Result.set_text_color(c);
		Result.set_underline;
	end

	set_format_font(fmt: WEL_CHARACTER_FORMAT; lf: WEL_LOG_FONT) is
		-- setup 'fmt' with the font characteristics in 'lf'
	require
		fmt /= Void;
		lf /= Void;
	do
		fmt.set_char_set(lf.char_set);
		fmt.set_face_name(lf.face_name);
		fmt.set_height(lf.height_in_points);
		fmt.set_pitch_and_family(lf.pitch_and_family);
	end

	on_mouse_move(keys, x_pos, y_pos: INTEGER) is
	local
		pos: INTEGER;
	do
		temp_point.set_x_y(x_pos, y_pos);
		if client_rect.point_in(temp_point) then
			pos := character_index_from_position(x_pos, y_pos);
			if linkdb.contains(pos) then
				if link_cursor.previous_cursor /= link_cursor then
					link_cursor.set;
				end
			end
		end
	end

	on_left_button_down(keys, x_pos, y_pos: INTEGER) is
	local
		pos: INTEGER;
	do
		temp_point.set_x_y(x_pos, y_pos);
		if client_rect.point_in(temp_point) then
			pos := character_index_from_position(x_pos, y_pos);
			if linkdb.contains(pos) then
				send_chat_link_selected(linkdb.link_data);
			end
		end
	end

	link_cursor: WEL_CURSOR is
	once
		!! Result.make_by_predefined_id(Idc_arrow);
	end

	linkdb: CHESS_GUI_CHAT_LINKDB;
	temp_point: WEL_POINT;

end
