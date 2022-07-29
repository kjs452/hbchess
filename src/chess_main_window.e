indexing
	description:	"The main application window"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

--
-- This class is a CHESS_GUI_WINDOW (see the cluster CHESS_GUI) that
-- contains all the controls for the main application window.
--
-- This window contains the following types of controls:
--	Chess board			CHESS_GUI_BOARD
--	Flip chess board button		CHESS_GUI_IMAGE_BUTTON
--	Web cam on/off button		CHESS_GUI_IMAGE_BUTTON
--	Menu button			CHESS_GUI_IMAGE_BUTTON
--	Webcam display control		CHESS_GUI_VIDEO
--	chat output control		CHESS_GUI_CHAT_OUTPUT
--	player name controls		CHESS_GUI_STATIC
--	Browse chess moves		CHESS_GUI_HISTORY
--	browse scroll bar		CHESS_GUI_HISTORY_SCROLL
--
-- These controls can be found in the CHESS_GUI cluster. These controls
-- all inherit from WEL_CONTROL_WINDOW..
--
-- The interaction between this main window, and the individual controls
-- is accomplished by the CHESS_GUI_WINDOW class.
--
-- CHESS_GUI_WINDOW is a class that contains many callback routines that
-- the individual CHESS_GUI_XXXX controls communicate.
--
-- For example, when the user moves a chess piece, he is interacting
-- with the CHESS_GUI_BOARD control, and when a valid move is made, we
-- call the feature 'on_move_chess_piece'. The main window can then
-- do the appropriate thing with the chess move.
--
-- This class is just the user interface for the hotbabe chess program.
-- All the gameplay logic resides in the class CHESS_APPLICATION_MANAGER.
--
-- This class communicates with CHESS_APPLICATION_MANAGER, and visa-versa.
--
-- CHESS_APPLICATION_MANAGER only knows us thru the abstract interface:
--	CHESS_APPLICATION_USER_INTERFACE, which contains callback routines
-- to modify the display
--
--
--
class CHESS_MAIN_WINDOW
inherit
	CHESS_GUI_WINDOW
	redefine
		on_get_min_max_info,
		on_horizontal_scroll_control,
		on_destroy,
		on_mouse_move,
		on_menu_command,
		on_move_chess_piece,
		on_chess_scroll,
		on_chess_button_click,
		on_chat_link_selected,
		on_video_notify,
		on_set_focus,
		on_timer,
		class_icon,
		background_brush,
		closeable
	end

	CHESS_APPLICATION_USER_INTERFACE

	CHESS_APP_CONSTANTS
	export
		{NONE} all
	end

	CHESS_SHORTCUT_CONSTANTS

	WEL_SS_CONSTANTS
	export
		{NONE} all
	end

	WEL_WS_CONSTANTS
	export
		{NONE} all
	end

	WEL_BS_CONSTANTS
	export
		{NONE} all
	end

	WEL_ES_CONSTANTS
	export
		{NONE} all
	end

	WEL_TTF_CONSTANTS
	export
		{NONE} all
	end

	WEL_TPM_CONSTANTS
	export
		{NONE} all
	end

	WEL_WINDOWS_ROUTINES
	export
		{NONE} all
	end

creation
	make

feature -- Initialization
	make(app: HOTBABE_CHESS) is
		-- create the main window...
	do
		application := app;
		make_chess_window;

		!! mgr.make(Current);

		if mgr.failed then
			failed_to_initialize := True;
		else
			failed_to_initialize := False;
		end

		if not failed_to_initialize then
			set_timer(Some_timer_id, Some_timer_value);
		end
	end

	failed_to_initialize: BOOLEAN;

feature -- CHESS_APPLICATION_USER_INTERFACE Implementation
	add_chat_sentence(s: CHESS_GUI_CHAT_SENTENCE) is
	do
		chat_output.append_sentence(s);
	end

	add_chat_newline is
	do
		chat_output.append_newline;
	end

	set_bottom_color(color: INTEGER) is
	do
		if bottom_side /= color then
			bottom_side := color;
			chess_ctrl.rotate(bottom_side);
		end

		if bottom_side = Chess_color_white then
			rotate_switch.turn_on;
		else
			rotate_switch.turn_off;
		end
	end

	clear_history is
	do
		hist_list.clear;
	end

	add_history_move(s: STRING) is
	do
		hist_list.append_move(s);
	end

	remove_last_history_move is
	do
		hist_list.remove_last_move;
	end

	history_mark(ply: INTEGER) is
	do
		hist_list.mark(ply);
	end

	history_clear_mark is
	do
		hist_list.clear_mark;
	end

	disable_shortcut(shortcut: INTEGER) is
	do
		chat_menu.disable_item(shortcut);
	end

	enable_shortcut(shortcut: INTEGER) is
	do
		chat_menu.enable_item(shortcut);
	end

	set_turn(side: INTEGER) is
	do
		if side = bottom_side then
			lower_arrow.turn_on;
			upper_arrow.turn_off;
		else
			lower_arrow.turn_off;
			upper_arrow.turn_on;
		end
	end

	clear_turn is
	do
		lower_arrow.turn_off;
		upper_arrow.turn_off;
	end

	set_nickname(side: INTEGER; name: STRING) is
	do
		if side = bottom_side then
			lower_player_txt.set_text(name);
		else
			upper_player_txt.set_text(name);
		end
	end

	set_status(side: INTEGER; str: STRING) is
	do
		if side = bottom_side then
			lower_status_txt.set_text(str);
		else
			upper_status_txt.set_text(str);
		end
	end

	set_video_file(fn: STRING): STRING is
	do
		chat_video.set_video(fn);
		if chat_video.failed then
			Result := chat_video.error_message;
		else
			Result := Void;
		end
	end

	video_play is
	do
		chat_video.play;
	end

	video_play_clip(start_frame, end_frame: INTEGER) is
	do
		chat_video.play_clip(start_frame, end_frame);
	end

	video_stop is
	do
		chat_video.stop;
	end

	set_webcam_nickname(name: STRING) is
	do
		chat_video.set_text(name);
	end

	thinking_on is
	do
		hourglass.set;

		if not has_capture then
			set_capture;
		end

		thinking := True;
	end

	thinking_off is
	do
		hourglass.restore_previous;

		-- capture doesn't prevent us from switching to
		-- a new window, and then making this window active
		-- again (which removes capture). So we need to
		-- protect ourselves
		if has_capture then
			release_capture;
		end

		thinking := False;
	end

	set_board_info(board: CHESS_GUI_BOARD_INFO) is
	do
		chess_ctrl.set_board_info(board);
		chess_ctrl.redraw;
	end

	animate_piece(from_square, to_square: INTEGER) is
	do
		chess_ctrl.animate(from_square, to_square);
	end

	enable_chess_board is
	do
		chess_ctrl.enable;
	end

	disable_chess_board is
	do
		chess_ctrl.disable;
	end

	disable_webcam is
	do
		chat_video_switch.turn_off;
		chat_video_switch.disable;
	end

	set_num_plies(plies: INTEGER) is	
	do
		hist_scroll.set_num_plies(plies);
	end

	good_beep is
	do
		message_beep_asterisk;
		-- message_beep_hand;
		-- message_beep_exclamation;
		-- message_beep_question;
	end

	bad_beep is
	do
		message_beep_ok;
	end

	set_title(string: STRING) is
	do
		set_text(string);
	end

	show_menu is
	local
		pux, puy: INTEGER;
	do
		pux := chat_icon.window_rect.left;
		puy := chat_icon.window_rect.top
				+ chat_icon.window_rect.height//2;

		chat_menu.show_track_with_option(pux, puy, Current,
				Tpm_rightalign, Void);
	end

	show_message_box(str: STRING) is
	do
		msgbox.error_message_box(Current, str, "Initialization Error");
	end

	change_nickname(old_nick: STRING): STRING is
	do
		nickname_dialog.set_form_data(old_nick);
		nickname_dialog.activate;
		Result := nickname_dialog.form_data;
	end

	new_game_properties(old_opt: CHESS_GAME_OPTIONS): CHESS_GAME_OPTIONS is
	do
		new_game_dialog.set_form_data(old_opt);
		new_game_dialog.activate;
		if new_game_dialog.result_id = Idok then
			Result := new_game_dialog.form_data;
		else
			Result := Void;
		end
	end

	select_file_for_save(fn: STRING): STRING is
	do
		save_file.set_file_name(fn);
		save_file.activate(Current);
		if save_file.selected then
			Result := save_file.file_name;
		else
			Result := Void;
		end
	end

	select_file_for_load(fn: STRING): STRING is
	do
		load_file.set_file_name(fn);
		load_file.activate(Current);
		if load_file.selected then
			Result := load_file.file_name;
		else
			Result := Void;
		end
	end

	show_debug_screen: ANY is
	do
		debug_dialog.activate;
		Result := debug_dialog.form_data;
	end

feature {NONE} -- Initialization
	make_chess_window is
	do
		make_top(Title);
		initialize_window_size;

		!! tooltip.make(Current, -1);

		make_static_text;
		make_chess_controls;
		make_chat_controls;
		make_tooltips;

		-- create message box
		!! msgbox.make;

		-- create hourglass cursor
		!! hourglass.make_by_predefined_id(Idc_wait);

		-- chess game stuff
		bottom_side := Chess_color_white;

		-- create dialogs
		!! nickname_dialog.make(Current);
		!! new_game_dialog.make(Current);
		!! debug_dialog.make(Current);

		show
		chat_video.show;
	end

	initialize_window_size is
	do
		set_width(geo.Total_width);
		set_height(geo.Total_height);
	end

	make_static_text is
	do
		!! upper_player_txt.make(Current, "",
				geo.Player_left, geo.Upper_player_top,
				geo.Player_width, geo.Player_height);

		!! lower_player_txt.make(Current, "",
				geo.Player_left, geo.Lower_player_top,
				geo.Player_width, geo.Player_height);

		!! upper_status_txt.make_status(Current, "",
				geo.Status_left, geo.Upper_status_top,
				geo.Status_width, geo.Status_height);

		!! lower_status_txt.make_status(Current, "",
				geo.Status_left, geo.Lower_status_top,
				geo.Status_width, geo.Status_height);
	end

	make_chess_controls is
	local
		sprite_mgr: CHESS_GUI_SPRITE_MANAGER;
	do
		sprite_mgr := load_sprites;
		!! chess_ctrl.make(Current, geo.Board_left, geo.Board_top, sprite_mgr);

		!! hist_list.make(Current, geo.Hist_left, geo.Hist_top, geo.Hist_height);


		!! hist_scroll.make_horizontal(Current,
				geo.Scroll_left, geo.Scroll_top,
				geo.Scroll_width, geo.Scroll_height, -1);

		!! rotate_switch.make(Current,
				geo.Rotate_left, geo.Rotate_top,
				Idb_rotate_white, Idb_rotate_black);

		!! upper_arrow.make(Current,
				geo.Arrow_left, geo.Upper_arrow_top,
				Idb_arrow_on, Idb_arrow_off);

		!! lower_arrow.make(Current,
				geo.Arrow_left, geo.Lower_arrow_top,
				Idb_arrow_on, Idb_arrow_off);

		upper_arrow.disable;
		lower_arrow.disable;
	end

	load_sprites: CHESS_GUI_SPRITE_MANAGER is
		-- Load all the chess sprites
	do
		!! Result.make;

		Result.set_piece_by_id(Piece_white_pawn, Idb_wpawn, Idb_wpawn_small);
		Result.set_piece_by_id(Piece_white_bishop, Idb_wbishop, Idb_wbishop_small);
		Result.set_piece_by_id(Piece_white_knight, Idb_wknight, Idb_wknight_small);
		Result.set_piece_by_id(Piece_white_rook, Idb_wrook, Idb_wrook_small);
		Result.set_piece_by_id(Piece_white_queen, Idb_wqueen, Idb_wqueen_small);
		Result.set_piece_by_id(Piece_white_king, Idb_wking, Idb_wking_small);

		Result.set_piece_by_id(Piece_black_pawn, Idb_bpawn, Idb_bpawn_small);
		Result.set_piece_by_id(Piece_black_bishop, Idb_bbishop, Idb_bbishop_small);
		Result.set_piece_by_id(Piece_black_knight, Idb_bknight, Idb_bknight_small);
		Result.set_piece_by_id(Piece_black_rook, Idb_brook, Idb_brook_small);
		Result.set_piece_by_id(Piece_black_queen, Idb_bqueen, Idb_bqueen_small);
		Result.set_piece_by_id(Piece_black_king, Idb_bking, Idb_bking_small);

		Result.set_board_by_id(Idb_board, Idb_board_reversed);
		Result.set_empty_square_by_id(Idb_wempty, Idb_bempty);
		Result.set_capture_area_by_id(Idb_capture);
		Result.set_border_dim_by_id(Idb_border);
	ensure
		Result /= Void;
		Result.exists;
	end

	make_chat_controls is
	do
		!! chat_output.make(Current,
				geo.Chat_output_left, geo.Chat_output_top,
				geo.Chat_output_width, geo.Chat_output_height);

		!! chat_video.make(Current, geo.Video_left, geo.Video_top, Idb_videobg);
		chat_video.set_text("");

		!! chat_video_switch.make(Current,
				geo.Video_switch_left, geo.Video_switch_top,
				Idb_cam_on, Idb_cam_off);

		!! chat_icon.make(Current,
				geo.Chat_icon_left, geo.Chat_icon_top,
				Idb_menu, Idb_menu);

		!! chat_menu.make;
	end

	make_tooltips is
	local
		tool: WEL_TOOL_INFO;
	do
		!! tool.make;
		tool.set_window(rotate_switch);
		tool.set_flags(Ttf_subclass);
		tool.set_rect(rotate_switch.client_rect);
		tool.set_text_id(Str_tt_rotate);
		tooltip.add_tool(tool);

		!! tool.make;
		tool.set_window(chat_video_switch);
		tool.set_flags(Ttf_subclass);
		tool.set_rect(chat_video_switch.client_rect);
		tool.set_text_id(Str_tt_video_switch);
		tooltip.add_tool(tool);

		!! tool.make;
		tool.set_window(chat_icon);
		tool.set_flags(Ttf_subclass);
		tool.set_rect(chat_icon.client_rect);
		tool.set_text_id(Str_tt_chat_icon);
		tooltip.add_tool(tool);
	end

feature {NONE} -- Event handlers
	closeable: BOOLEAN is
		-- this function handles the close logic for the
		-- main application window.
	do
		Result := mgr.shutdown;
	end

	on_destroy is
	do
		kill_timer(Some_timer_id);
	end

	on_mouse_move(keys, x_pos, y_pos: INTEGER) is
	do
		if failed_to_initialize then
			-- this allows our main window
			-- to close down cleanly, in the
			-- event we could not initialize
			-- the application

			destroy;
		else
			if not has_focus then
				set_focus;
			end
		end
	end

	on_menu_command(menu_id: INTEGER) is
	do
		mgr.shortcut_command(menu_id);
	end

	on_get_min_max_info(min_max_info: WEL_MIN_MAX_INFO) is
	local
		p: WEL_POINT;
	do
		!! p.make(geo.Total_width, geo.Total_height);
		min_max_info.set_max_track_size(p);
		min_max_info.set_min_track_size(p);
	end

	on_horizontal_scroll_control(scroll_code: INTEGER; position: INTEGER;
				bar: WEL_BAR) is
	do
		if bar = hist_scroll then
			hist_scroll.on_scroll(scroll_code, position);
		end
	end

	on_set_focus is
		-- this turns capture and hourglass back on, when
		-- we lose focus to another windows program, and
		-- then the user returns to the this program
	do
		if thinking and not has_capture then
			hourglass.set;

			if not has_capture then
				set_capture;
			end
		end
	end

	on_timer(timer_id: INTEGER) is
	do
		mgr.timer;
	end

	on_move_chess_piece(ctrl: CHESS_GUI_CONTROL;
				src_square, dst_square, promote_piece: INTEGER) is
	do
		mgr.move_piece(src_square, dst_square, promote_piece);
	end

	on_chess_scroll(ctrl: CHESS_GUI_CONTROL; pos: INTEGER) is
	do
		mgr.browse_ply(pos);
	end

	on_chess_button_click(ctrl: CHESS_GUI_CONTROL; new_state: BOOLEAN) is
	do
		if ctrl = rotate_switch then
			mgr.rotate_board;

		elseif ctrl = chat_video_switch then
			if new_state then
				mgr.enable_cam;
			else
				mgr.disable_cam;
			end

		elseif ctrl = chat_icon then
			show_menu;
		end

	end

	on_chat_link_selected(ctrl: CHESS_GUI_CONTROL; link_data: CHESS_GUI_CHAT_LINK) is
	do
		mgr.chat_link(link_data);
	end

	on_video_notify(ctrl: CHESS_GUI_CONTROL; a_msg, wparam, lparam: INTEGER) is
	do
		mgr.webcam_event;
	end

feature {NONE} -- controls
	-- static text
	upper_player_txt: CHESS_GUI_STATIC;
	lower_player_txt: CHESS_GUI_STATIC;

	upper_status_txt: CHESS_GUI_STATIC;
	lower_status_txt: CHESS_GUI_STATIC;

	-- chess controls
	chess_ctrl: CHESS_GUI_BOARD;
	hist_list: CHESS_GUI_HISTORY;
	hist_scroll: CHESS_GUI_HISTORY_SCROLL;
	rotate_switch: CHESS_GUI_IMAGE_BUTTON;
	upper_arrow: CHESS_GUI_IMAGE_BUTTON;
	lower_arrow: CHESS_GUI_IMAGE_BUTTON;

	-- chat controls
	chat_output: CHESS_GUI_CHAT_OUTPUT;
	chat_video: CHESS_GUI_VIDEO;
	chat_video_switch: CHESS_GUI_IMAGE_BUTTON;
	chat_icon: CHESS_GUI_IMAGE_BUTTON;
	chat_menu: CHESS_GUI_CHAT_MENU;

	-- layout of main window
	geo: CHESS_MAIN_WINDOW_GEOMETRY is
	once
		!! Result;
	end

	-- chess stuff
	bottom_side: INTEGER;

feature {NONE} -- dialogs and GUI constants
	nickname_dialog: NICKNAME_DIALOG;
	new_game_dialog: NEW_GAME_DIALOG;
	debug_dialog: DEBUG_DIALOG;

	load_file: CHESS_LOAD_DIALOG is
	once
		!! Result.make;
	end

	save_file: CHESS_SAVE_DIALOG is
	once
		!! Result.make;
	end

	-- GUI constants
	class_icon: WEL_ICON is
	once
		create Result.make_by_id(Idi_icon1);
	end

	hourglass: WEL_CURSOR;
	msgbox: WEL_MSG_BOX;

	Title: STRING is "Hotbabe Chess";

	background_brush: WEL_BRUSH is
		-- Dialog boxes background color is the same than
		-- button color.
	local
		c: WEL_COLOR_REF;
	do
		!! c.make_rgb(150, 182, 170);
		!! Result.make_solid(c);
	end

feature {NONE} -- Chess application manager
	mgr: CHESS_APPLICATION_MANAGER;
	Some_timer_id: INTEGER is 1;
	Some_timer_value: INTEGER is 1000;	-- 1000 milliseconds = 1 second

feature -- public stuff
	application: HOTBABE_CHESS;
	tooltip: WEL_TOOLTIP;

end
