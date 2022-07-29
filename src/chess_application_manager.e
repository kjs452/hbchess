indexing
	description:	"manages the entire game interaction between user and computer"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

--
-- This class drives the overall game play. It communicates
-- with an abstract class: 'CHESS_APPLICATION_USER_INTERFACE' to
-- update the graphical interface.
--
-- This class keeps track of the chess game, and the hotbabe
-- database.
--
-- When the user interacts with the main window, then
-- the CHESS_APPLICATION_USER_INTERFACE will call features
-- of this class whenever.
--
-- For example if the user moves a piece on the chess board, the
-- CHESS_APPLICATION_USER_INTERFACE will call:
--	move_piece
--
-- This class doesn't know anything about the graphical display, all it
-- can do is call high level features of the CHESS_APPLICATION_USER_INTERFACE.
--
--

class CHESS_APPLICATION_MANAGER
inherit
	CHESS_APP_STATE_CONSTANTS

	CHESS_GENERAL_CONSTANTS
	CHESS_SQUARE_CONSTANTS
	CHESS_PIECE_CONSTANTS
	export
		{ANY} Piece_none
	end

	CHESS_MOVE_CONSTANTS

	CHESS_SHORTCUT_CONSTANTS

creation
	make

feature -- Initialization
	make(a_ui: CHESS_APPLICATION_USER_INTERFACE) is
	require
		a_ui /= Void;
	do
		failed := False;

		ui := a_ui;

		!! install_dir.make;
		if install_dir.failed then
			ui.show_message_box(install_dir.error_message);
			failed := True;
		end

		if not failed then
			!! hotbabe.make(install_dir.item + "\hotbabe_chess.dat");
			if hotbabe.failed then
				ui.show_message_box(hotbabe.error_message);
				failed := True;
			end
		end

		if not failed then
			initialize_video_file;
		end

		if not failed then
			!! file_name.make(10);
			!! game_options.make;
			!! game.make;
			!! txtutil.make(hotbabe);

			!CHESS_SEARCH_NO_THREAD! search.make;

			--
			-- Multi-threaded mode (not recommended)
			-- See CHESS_SEARCH_THREAD source code
			-- for instructions on how to
			-- enable this
			--
			-- !CHESS_SEARCH_THREAD! search.make;

			initialize_app;
		end
	end

	failed: BOOLEAN;
		-- Set to true is we are unable to initialize the
		-- the application.

feature -- Commands
	counter: INTEGER;

	timer is
		-- timer signal from main window
		-- this timer is triggered about once per
		-- second.
		--
		-- If we are "thinking" we will periodically
		-- check to see if the search for the best
		-- move is complete.
		--
		-- If the webcam is off, then we will periodically
		-- call HOTBABE to get text to display in the
		-- chat window.
	local
		txt: HOTBABE_TEXT;
		lst: LINKED_LIST[ CHESS_GUI_CHAT_SENTENCE ];
	do
		if not cam_on then
			counter := counter + 1;
			if counter >= Timer_counter_limit then
				counter := 0;
				hotbabe.forth;
				txt := hotbabe.text_message;
				if txt /= Void then
					lst := txtutil.convert_to_hotbabe(txt);
					ui.add_chat_sentence_list(lst);
				end
			end
		end

		if state = App_state_thinking then
			if not search.searching then
				hotbabe_finish_move;
			end
		elseif state = App_state_hint then
			if not search.searching then
				hint_finish;
			end
		end
	end

	move_piece(src_square, dst_square, promote_piece: INTEGER) is
		-- the user moved a piece on the chess board. If
		-- this move was a promotion, then 'promote_piece'
		-- will be his choice.
	require
		valid_square(src_square);
		valid_square(dst_square);
		valid_piece(promote_piece) or (promote_piece = Piece_none);
	local
		mov: CHESS_MOVE;
	do
		mov := game.find_move(src_square, dst_square, promote_piece);
		player_finish_move(mov, False);
	end

	disable_cam is
		-- the user turned the webcam OFF
	require
		cam_on;
	local
		e: HOTBABE_EVENT_WEBCAM_CHANGED;
	do
		cam_on := False;

		ui.video_stop;

		!! e.make(False);
		hotbabe.add_event(e);
	end

	enable_cam is
		-- the user turned the webcam ON
	require
		not cam_on;
	local
		e: HOTBABE_EVENT_WEBCAM_CHANGED;
	do
		cam_on := True;

		webcam_event;

		!! e.make(True);
		hotbabe.add_event(e);

	end

	chat_link(link_data: CHESS_GUI_CHAT_LINK) is
		-- The user clicked on a link in the
		-- chat window. We can take action
		-- based on the link they clicked on.
	require
		link_data /= Void;
	local
		link: CHESS_LINK_DATA;
		e: HOTBABE_EVENT_EASTER_EGG;
	do
		link ?= link_data;

		check
			-- because the link must be
			-- of type CHESS_LINK_DATA
			link /= Void;
		end

		if link.identifier = Void then
			show_bad_link("[try using your web browser]");

		elseif link.identifier.is_equal("START_MENU") then
			--
			-- show menu, or show the new game dialog...
			--
			if (state = App_state_nogame) or (state = App_state_gameover)
			then
				--ui.show_menu;
				new_game_command;
			else
				show_bad_link("[game already in progress]");
			end

		elseif link.identifier.is_equal("HINT_MOVE") then
			hint_clicked(link.url);

		elseif link.identifier.is_equal("EE") then
			!! e.make;
			hotbabe.add_event(e);
			show_bad_link("[easter egg]");

		elseif link.identifier.is_equal("RESIGN_GAME") then
			if state /= App_state_nogame
				and state /= App_state_gameover
			then
				game_over_player_resigns;
			else
				show_bad_link("[No game in progress]");
			end

		elseif link.identifier.is_equal("MAIL_TO") then
			show_bad_link("[um, this is just a game, not an e-mail application]");

		elseif is_help_topic(link.identifier) then
			help_clicked(link.identifier);

		else
			show_bad_link("[invalid link " + link.identifier + "]");
		end
	end

	webcam_event is
		--
		-- a video clip has finished playing. Usually
		-- we grab the next video clip from the hotbabe object.
		-- If the web cam if OFF, then we don't do anything..
		--
	local
		clip: HOTBABE_CLIP;
		txt: HOTBABE_TEXT;
		lst: LINKED_LIST[ CHESS_GUI_CHAT_SENTENCE ];
	do
		if cam_on then
			hotbabe.forth;

			clip := hotbabe.video_clip;
			ui.video_play_clip(clip.start_frame, clip.end_frame);

			txt := hotbabe.text_message;
			if txt /= Void then
				lst := txtutil.convert_to_hotbabe(txt);
				ui.add_chat_sentence_list(lst);
			end
		end
	end

	shortcut_command(shortcut: INTEGER) is
		-- the user selected a menu item from
		-- the command menu.
	require
		valid_shortcut(shortcut);
	do
		if shortcut = Shortcut_new_game then
			new_game_command;

		elseif shortcut = Shortcut_load_game then
			load_game_command;

		elseif shortcut = Shortcut_save_game then
			save_game_command;

		elseif shortcut = Shortcut_resign then
			resign_command;

		elseif shortcut = Shortcut_hint then
			hint_command;

		elseif shortcut = Shortcut_undo_move then
			undo_command;

		elseif shortcut = Shortcut_change_nickname then
			change_nickname_command;

		elseif shortcut = Shortcut_game_properties then
			game_properties_command;

		elseif shortcut = Shortcut_about then
			about_command;

		elseif shortcut = Shortcut_help then
			help_command;
		end
	end

	rotate_board is
		-- The user clicked on the 'rotate' button
		-- We want to rotate all the GUI elements
	local
		e: HOTBABE_EVENT_FLIP_BOARD;
	do
		bottom_side := get_opposite_color(bottom_side);
		ui.set_bottom_color(bottom_side);

		if state /= App_state_nogame then
			ui.set_nickname(player_color, player_nick);
			ui.set_nickname(hotbabe_color, hotbabe_nick);
			refresh_game_status;

			ui.set_turn(side_to_move);
		end

		!! e.make;
		hotbabe.add_event(e);
	end

	shutdown: BOOLEAN is
		-- shutdown the application
		-- Return True, if we want to exit.
	local
		f: CHESS_GAME_FILE;
		fn: STRING;
	do
		--
		-- Save the current game, and other
		-- state information. This will be automatically
		-- loaded next time the application is run.
		--

		fn := install_dir.item + "\" + Last_game_filename;
		!! f.make(fn);
		f.save(game, game_options, player_nick, resigned);

		--
		-- we don't check for errors, if it
		-- works it works, otherwise its no big deal
		--

		Result := True;
	end

	browse_ply(ply: INTEGER) is
		-- The user has scrolled the horizontal
		-- scroll bar. 'ply' is a move in the
		-- game history.
		-- We will update the display to show
		-- the chess board.
	do
		if state /= App_state_nogame then
			current_ply := ply;

			redraw_board;

			if current_ply < game.total_plies then
				ui.history_mark(current_ply);
			else
				ui.history_clear_mark;
			end
		end
	end

feature -- Access
	cam_on: BOOLEAN;

feature -- Status Report
feature -- Status Setting
feature -- Element Change
feature -- Removal
feature {NONE} -- short cut commands
	new_game_command is
		-- begin a new game
	local
		opts: CHESS_GAME_OPTIONS;
		g: CHESS_GAME;
		s: CHESS_GUI_CHAT_SENTENCE;
	do
		opts := ui.new_game_properties(game_options);
		if opts /= Void then
			!! s.make_system;
			s.append_normal("[NEW GAME: ");
			if opts.player_color = Chess_color_white then
				s.append_bold(player_nick);
				s.append_normal(" vs. ");
				s.append_bold(hotbabe_nick);
			else
				s.append_bold(hotbabe_nick);
				s.append_normal(" vs. ");
				s.append_bold(player_nick);
			end
			s.append_normal("]");

			ui.add_chat_newline;
			ui.add_chat_sentence(s);
			ui.add_chat_newline;

			!! g.make;
			new_game(g, opts, False);
		end
	end

	load_game_command is
		-- load game from file, prompt file filename first.
	require
		state = App_state_nogame
			or state = App_state_gameover;
	local
		f: CHESS_GAME_FILE;
		fn: STRING;
		lst: LINKED_LIST[ CHESS_GUI_CHAT_SENTENCE ];
	do
		fn := ui.select_file_for_load(file_name);
		if fn /= Void then
			!! f.make(fn);
			f.load;
			if f.failed then
				lst := txtutil.file_load_error(f.error_message);
				ui.add_chat_newline;
				ui.add_chat_sentence_list(lst);
				ui.add_chat_newline;
				ui.bad_beep;
			else
				lst := txtutil.file_load_message(fn);
				ui.add_chat_newline;
				ui.add_chat_sentence_list(lst);
				ui.add_chat_newline;

				file_name := fn;

				change_nickname(f.nickname);
				new_game(f.game, f.options, f.resigned);
			end
		end
	end

	save_game_command is
		-- save current game
	local
		f: CHESS_GAME_FILE;
		fn: STRING;
		lst: LINKED_LIST[ CHESS_GUI_CHAT_SENTENCE ];
	do
		fn := ui.select_file_for_save(file_name);
		if fn /= Void then
			!! f.make(fn);
			f.save(game, game_options, player_nick, resigned);
			if f.failed then
				lst := txtutil.file_save_error(f.error_message);
				ui.add_chat_newline;
				ui.add_chat_sentence_list(lst);
				ui.add_chat_newline;
				ui.bad_beep;
			else
				lst := txtutil.file_save_message(fn);
				ui.add_chat_newline;
				ui.add_chat_sentence_list(lst);
				ui.add_chat_newline;
				file_name := fn;
			end
		end
	end

	resign_command is
	local
		lst: LINKED_LIST[ CHESS_GUI_CHAT_SENTENCE ];
		e: HOTBABE_EVENT_RESIGN_TAUNT;
	do
		lst := txtutil.resign_confirm_message;
		ui.add_chat_newline;
		ui.add_chat_sentence_list(lst);
		ui.add_chat_newline;

		!! e.make;
		hotbabe.add_event(e);
	end

	hint_command is
	local
		lst: LINKED_LIST[ CHESS_GUI_CHAT_SENTENCE ];
		e: HOTBABE_EVENT_THINKING;
	do
		set_state(App_state_hint);

		lst := txtutil.hint_before_message;
		ui.add_chat_sentence_list(lst);

		ui.disable_chess_board;

		ui.thinking_on;
		search.begin_search(game.board, game.history);

		!! e.make;
		hotbabe.add_event(e);
	end

	hint_finish is
		-- display the hint results
	local
		lst: LINKED_LIST[ CHESS_GUI_CHAT_SENTENCE ];
	do
		set_state(App_state_idle);

		last_hint := search.item;
		last_hint_string := game.algebraic_notation(last_hint);

		lst := txtutil.hint_after_message(last_hint_string);
		ui.add_chat_sentence_list(lst);
		ui.enable_chess_board;

		ui.thinking_off;
	end

	hint_clicked(movstr: STRING) is
		-- user clicked on the hint link
		-- 'movstr' is the link text
		-- we verify movstr matches.
	require
		movstr /= Void;
	do
		if state = App_state_nogame or state = App_state_gameover then
			show_bad_link("[No game in progress]");

		elseif last_hint_string = Void then
			show_bad_link("[Hint " + movstr + " expired]");

		elseif not last_hint_string.is_equal(movstr) then
			show_bad_link("[Hint " + movstr + " expired]");

		else
			make_view_current;
			player_finish_move(last_hint, True);
		end
	end

	undo_command is
		-- undo the last move. This logic is actually pretty
		-- tricky, because if the game has ended we need to
		-- figure out how many moves to undo.
		--
		-- For example, if hotbabe moves and check-mates the
		-- player, then UNDO must undo hotbabe's move and ours.
		-- But if we check-mate hotbabe, then undo would only
		-- want to take back a single move.
	do
		if player_undo_available then
			--
			-- hint is not longer valid
			-- (in all other cases, we can invalidate
			-- the last hint, inside of set_state, but
			-- this is the one place where that won't work)
			--
			last_hint_string := Void;
			last_hint := Void;

			if resigned then
				resigned := False;
				player_start_move;
				undo_moves(0, False);

			elseif game.game_over then
				player_start_move;

				if game.side_to_move = player_color then
					undo_moves(2, False);
				else
					undo_moves(1, False);
				end

			else
				-- undo hotbabes move and
				-- undo players move
				undo_moves(2, True);
			end
		end
	end

	undo_moves(num_moves: INTEGER; taunt: BOOLEAN) is
		-- undo 'num_moves' moves (currently only allow 0, 1 or 2 moves)
		-- if 'taunt' set, then add an event to the hotbabe queue,
		-- that makes fun of the user for undo a move.
	require
		num_moves >= 0 and num_moves <= 2;
	local
		i: INTEGER;
		e: HOTBABE_EVENT_UNDO_TAUNT;
		mov: CHESS_MOVE;
	do
		make_view_current;

		from
			i := 1;
		until
			i > num_moves
		loop
			mov := game.get_move(game.total_plies);
			ui.animate_piece(mov.dst, mov.src);

			game.undo;

			ui.remove_last_history_move;
			current_ply := game.total_plies;
			ui.set_num_plies(current_ply);
			redraw_board;

			i := i + 1;
		end

		update_undo_shortcut;

		set_hotbabe_score;

		if taunt then
			!! e.make;
			hotbabe.add_event(e);
		end

		set_status_from_game(game);
	end

	change_nickname_command is
	local
		lst: LINKED_LIST[ CHESS_GUI_CHAT_SENTENCE ];
		e: HOTBABE_EVENT_NICKNAME_TAUNT;
		new_nickname: STRING;
	do
		new_nickname := ui.change_nickname(player_nick);

		if not player_nick.is_equal(new_nickname) then
			lst := txtutil.change_nickname_message(
					player_nick,
					new_nickname);

			ui.add_chat_newline;
			ui.add_chat_sentence_list(lst);
			ui.add_chat_newline;

			!! e.make;
			hotbabe.add_event(e);
		end

		change_nickname( new_nickname );
	end

	game_properties_command is
		-- display statistics about
		-- how the game engine is working
	local
		lst: LINKED_LIST[ CHESS_GUI_CHAT_SENTENCE ];
	do
		if state /= App_state_nogame then
			lst := txtutil.statistics_message(search.statistics,
						game_options.out );
			ui.add_chat_newline;
			ui.add_chat_sentence_list(lst);
			ui.add_chat_newline;
		end
	end

	about_command is
	local
		lst: LINKED_LIST[ CHESS_GUI_CHAT_SENTENCE ];
		e, ecredits: HOTBABE_EVENT;
	do
		lst := txtutil.about_text_message;
		ui.add_chat_newline;
		ui.add_chat_sentence_list(lst);
		ui.add_chat_newline;

		!HOTBABE_EVENT_CREDITS! ecredits.make;

		if not hotbabe.has(ecredits) then
			if hotbabe.showing then
				hotbabe.add_event(ecredits);
			else
				!HOTBABE_EVENT_SITDOWN! e.make;
				hotbabe.add_event(e);

				hotbabe.add_event(ecredits);

				!HOTBABE_EVENT_STANDUP! e.make;
				hotbabe.add_event(e);
			end
		end

	end

	help_command is
		-- display top-level help text in the
		-- chat window.
	local
		xany: ANY;
		event_lst: LINKED_LIST[ HOTBABE_EVENT ];
	do
		help_clicked("HELP");

		--
		-- Special debug handling
		--
		if hotbabe.debug_mode then
			xany := ui.show_debug_screen;
			if xany /= Void then
				event_lst ?= xany;
				check
					event_lst /= Void;
				end
				debug_add_events(event_lst);
			end
		end
	end

	is_help_topic(s: STRING): BOOLEAN is
		-- does the string 's' begin with the
		-- letters: H E L P
	require
		 s /= Void;
	local
		str: STRING;
	do
		str := s.substring(1, 4);
		Result := str.is_equal("HELP");
	end

	help_clicked(topic: STRING) is
		-- user clicked on a help topic link
	require
		topic /= Void;
		is_help_topic(topic);
	local
		lst: LINKED_LIST[ CHESS_GUI_CHAT_SENTENCE ];
		str: STRING;
		key: INTEGER;
	do
		if topic.count = 4 then
			key := 0;
		else
			str := topic.substring(5, topic.count);
			if str.is_integer then
				key := str.to_integer;
			else
				show_bad_link("invalid help topic");
			end
		end

		lst := txtutil.help_message(key);
		ui.add_chat_newline;
		ui.add_chat_sentence_list(lst);
		ui.add_chat_newline;
	end


feature {NONE} -- Implementation
	redraw_board is
	local
		bi: CHESS_GUI_BOARD_INFO;
	do
		!! bi.make(game, current_ply);
		ui.set_board_info(bi);
	end

	update_undo_shortcut is
		-- enable/disable undo command
		-- if undo is available
	do
		if state /= App_state_thinking 
				and state /= App_state_hint
		then
			if player_undo_available then
				ui.enable_shortcut(Shortcut_undo_move);
			else
				ui.disable_shortcut(Shortcut_undo_move);
			end
		else
			ui.disable_shortcut(Shortcut_undo_move);
		end
	end

	player_undo_available: BOOLEAN is
		-- determies if we can allow the player
		-- to undo his last move. It depends on
		-- which side moved first. If hotbabe went
		-- first, then we cannot undo THAT move.
		--
	do
		if player_color = Chess_color_white then
			Result := game.undo_available;
		else
			Result := game.undo_available and (game.total_plies > 2);
		end
	end

	make_view_current is
		-- if user is browsing a different ply in the move history
		-- this routine will set our view to the current and
		-- redraw the board
	do
		if current_ply < game.total_plies then
			ui.history_clear_mark;
			current_ply := game.total_plies;
			redraw_board;
		end
	ensure
		current_ply = game.total_plies;
	end

feature {NONE} -- Initialization
	initialize_video_file is
		-- initialize the video filename, and then
		-- check to make sure it exists and is readable.
		--
		-- if an error happens when trying to find the
		-- video file, then we will disable the webcam, but
		-- allow the program to run (except the
		-- webcam will be disabled).
	local
		f: RAW_FILE;
		str: STRING;
	do
		video_file_available := True;

		video_file := install_dir.item + "\hotbabe_chess.avi";
		!! f.make(video_file);
		if not f.exists then
			ui.show_message_box("Webcam disabled." +
					" (no such file: " + video_file + ")" );
			video_file_available := False;
		elseif not f.is_readable then
			ui.show_message_box("File not readable: " + video_file);
			video_file_available := False;
		else
			str := ui.set_video_file(video_file);
			if str /= Void then
				video_file_available := False;
				ui.show_message_box(str);
			end
		end
	end

	initialize_app is
		-- called to initialize the game
		-- to its initial state.
	local
		bi: CHESS_GUI_BOARD_INFO;
	do
		resigned := False;
		player_color := Chess_color_white;
		hotbabe_color := Chess_color_black;

		!! player_nick.make_from_string(Default_player_nickname);
		!! hotbabe_nick.make_from_string(hotbabe.nickname);

		set_game_status("no game", "no game");

		--
		-- these variables are always available for text substitutions
		--
		txtutil.set_variable("player", player_nick);

		current_ply := 0;
		bottom_side := Chess_color_white;
		ui.set_bottom_color(bottom_side);
		ui.clear_history;
		ui.set_nickname(player_color, No_player);
		ui.set_nickname(hotbabe_color, No_player);
		ui.set_webcam_nickname(hotbabe_nick);

		ui.set_title(Default_title);

		ui.clear_turn;

		--
		-- The webcam is ON when the application starts
		--
		if video_file_available then
			cam_on := True;
			webcam_event;
		else
			-- the video file could not be read, so we
			-- disable the webcam and run the application
			-- (user won't see hotbabe in this mode, but
			-- everything else will work)
			cam_on := False;
			ui.disable_webcam;
		end

		--
		-- Draw empty chess board, and make it inactive
		--
		ui.disable_chess_board;
		!! bi.make_empty;
		ui.set_board_info(bi);

		set_state(App_state_nogame);

		show_start_message;

		load_last_game;
	end

	show_start_message is
		-- this shows a message when the program
		-- first starts up
	local
		lst: LINKED_LIST[ CHESS_GUI_CHAT_SENTENCE ];
	do
		lst := txtutil.start_message;
		ui.add_chat_newline;
		ui.add_chat_newline;
		ui.add_chat_newline;
		ui.add_chat_sentence_list(lst);
		ui.add_chat_newline;
	end

	load_last_game is
		-- try to load the lastgame.txt file and
		-- configure the application.
	local
		fn: STRING;
		f: CHESS_GAME_FILE;
	do
		fn := install_dir.item + "\" + Last_game_filename;
		!! f.make(fn);
		f.load;
		if not f.failed then
			change_nickname(f.nickname);

			if f.game.total_plies > 0
				and not f.game.game_over
				and not f.resigned
			then
				new_game(f.game, f.options, f.resigned);
			else
				game_options := f.options;
				search.initialize(
					game_options.max_ply,
					game_options.max_time,
					game_options.qsearch);
			end
		end
	end

	set_side_to_move(side: INTEGER) is
		-- whenever a move is made, call
		-- this to switch the side moving
	require
		valid_piece_color(side);
	do
		side_to_move := side;
		ui.set_turn(side_to_move);
	end

	set_state(s: INTEGER) is
		-- update the state of the game
		-- update the command menu, depending on the
		-- state we are in.
	require
		valid_app_state(s);
	local
		old_state: INTEGER;
		hotbabe_was_showing: BOOLEAN;
		e: HOTBABE_EVENT;
	do
		old_state := state;
		state := s;

		--
		-- current state of hotbabe (is she showing or away?)
		--
		hotbabe_was_showing := hotbabe.showing;

		inspect state
		when App_state_nogame then
			ui.enable_shortcut(Shortcut_new_game);
			ui.enable_shortcut(Shortcut_load_game);
			ui.disable_shortcut(Shortcut_save_game);
			ui.disable_shortcut(Shortcut_resign);
			ui.disable_shortcut(Shortcut_hint);
			ui.enable_shortcut(Shortcut_change_nickname);
			ui.disable_shortcut(Shortcut_game_properties);
			ui.enable_shortcut(Shortcut_about);
			ui.enable_shortcut(Shortcut_help);

			hotbabe.set_showing(False);

		when App_state_idle then
			ui.disable_shortcut(Shortcut_new_game);
			ui.disable_shortcut(Shortcut_load_game);
			ui.enable_shortcut(Shortcut_save_game);
			ui.enable_shortcut(Shortcut_resign);
			ui.enable_shortcut(Shortcut_hint);
			ui.enable_shortcut(Shortcut_change_nickname);
			ui.enable_shortcut(Shortcut_game_properties);
			ui.enable_shortcut(Shortcut_about);
			ui.enable_shortcut(Shortcut_help);

			hotbabe.set_showing(True);

		when App_state_thinking then
			ui.disable_shortcut(Shortcut_new_game);
			ui.disable_shortcut(Shortcut_load_game);
			ui.disable_shortcut(Shortcut_save_game);
			ui.disable_shortcut(Shortcut_resign);
			ui.disable_shortcut(Shortcut_hint);
			ui.disable_shortcut(Shortcut_change_nickname);
			ui.disable_shortcut(Shortcut_game_properties);
			ui.disable_shortcut(Shortcut_about);
			ui.disable_shortcut(Shortcut_help);

			hotbabe.set_showing(True);

		when App_state_hint then
			ui.disable_shortcut(Shortcut_new_game);
			ui.disable_shortcut(Shortcut_load_game);
			ui.disable_shortcut(Shortcut_save_game);
			ui.disable_shortcut(Shortcut_resign);
			ui.disable_shortcut(Shortcut_hint);
			ui.disable_shortcut(Shortcut_change_nickname);
			ui.disable_shortcut(Shortcut_game_properties);
			ui.disable_shortcut(Shortcut_about);
			ui.disable_shortcut(Shortcut_help);

			hotbabe.set_showing(True);

		when App_state_gameover then
			ui.enable_shortcut(Shortcut_new_game);
			ui.enable_shortcut(Shortcut_load_game);
			ui.enable_shortcut(Shortcut_save_game);
			ui.disable_shortcut(Shortcut_resign);
			ui.disable_shortcut(Shortcut_hint);
			ui.enable_shortcut(Shortcut_change_nickname);
			ui.enable_shortcut(Shortcut_game_properties);
			ui.enable_shortcut(Shortcut_about);
			ui.enable_shortcut(Shortcut_help);

			hotbabe.set_showing(False);
		end

		update_undo_shortcut;

		--------------------------------
		-- make hotbabe standup or sitdown, if
		-- her state has changed
		--

		--
		-- if hotbabe was not previously showing, and
		-- now she is, then have her sitdown.
		--
		if not hotbabe_was_showing and hotbabe.showing then
			!HOTBABE_EVENT_SITDOWN! e.make;
			hotbabe.add_event(e);

			--
			-- if game is brand new, we want her to say something
			-- about starting a new game.
			--
			if game.total_plies = 0 then
				!HOTBABE_EVENT_GAME_START! e.make;
				hotbabe.add_event(e);
			else
				!HOTBABE_EVENT_GAME_CONTINUE! e.make;
				hotbabe.add_event(e);
			end
		end

		--
		-- if hotbabe was previosly showing, and
		-- not she is not, then have her standup and leave
		--
		if hotbabe_was_showing and not hotbabe.showing then
			!HOTBABE_EVENT_GAME_END! e.make;
			hotbabe.add_event(e);

			!HOTBABE_EVENT_STANDUP! e.make;
			hotbabe.add_event(e);
		end

		--
		-- The last hint is not available whenever
		-- the state changed
		--
		last_hint_string := Void;
		last_hint := Void;
	end

	player_start_move is
		-- player's turn to move, enable chess board.
	do
		set_state(App_state_idle);
		set_side_to_move(player_color);
		ui.enable_chess_board;
	end

	player_finish_move(mov: CHESS_MOVE; animate: BOOLEAN) is
		-- called to make the players move
		-- set 'animate' is we want to animate the move (this
		-- is used by the HINT feature)
	require
		mov /= Void;
	local
		s: STRING;
		capture_piece: INTEGER;
	do
		if mov.is_capture(game.board) then
			capture_piece := mov.captured_piece(game.board);
		else
			capture_piece := Piece_type_none;
		end

		s := game.algebraic_notation(mov);
		ui.add_history_move(s);

		game.make_move(mov);

		set_hotbabe_score;

		current_ply := game.total_plies;
		ui.set_num_plies(game.total_plies);

		if animate then
			ui.animate_piece(mov.src, mov.dst);
		end
		redraw_board;

		--
		-- special DEBUG handling
		--
		if hotbabe.debug_mode then
			debug_save_current_game;
		end

		if game.check_mate then
			game_over_player_mates;
		elseif game.stale_mate then
			game_over_stale_mate;
		elseif game.draw then
			game_over_draw;
		else
			add_move_event(False, mov.type, capture_piece);
			hotbabe_start_move;
		end
	end

	hotbabe_start_move is
		-- actions to perform when hotbabe
		-- is going to make a move
	do
		set_side_to_move(hotbabe_color);
		set_state(App_state_thinking);

		ui.disable_chess_board;

		ui.thinking_on;
		search.begin_search(game.board, game.history);
	end

	hotbabe_finish_move is
		-- what to do when hotbabe has finished thinking
		-- about her move, this will play her move.
	local
		s: STRING;
		best_move: CHESS_MOVE;
		capture_piece: INTEGER;
	do
		best_move := search.item;

		if best_move.is_capture(game.board) then
			capture_piece := best_move.captured_piece(game.board);
		else
			capture_piece := Piece_type_none;
		end

		s := game.algebraic_notation(best_move);
		ui.add_history_move(s);

		game.make_move(best_move);

		set_hotbabe_score;

		current_ply := game.total_plies;
		ui.set_num_plies(game.total_plies);

		ui.animate_piece(best_move.src, best_move.dst);

		redraw_board;

		-- check to see if game over
		if game.check_mate then
			game_over_hotbabe_mates;
		elseif game.stale_mate then
			game_over_stale_mate;
		elseif game.draw then
			game_over_draw;
		else
			add_move_event(True, best_move.type, capture_piece);
			player_start_move;
		end

		ui.thinking_off;
	end

feature {NONE} -- Implementation game-over actions
	game_over_hotbabe_mates is
	local
		s: CHESS_GUI_CHAT_SENTENCE;
		e: HOTBABE_EVENT_HOTBABE_WINS;
	do
		!! s.make_system;
		s.append_normal("[CHECK-MATE ");
		s.append_bold(hotbabe_nick);
		s.append_normal(" WINS]");

		ui.add_chat_newline;
		ui.add_chat_sentence(s);
		ui.add_chat_newline;

		ui.disable_chess_board;
		ui.bad_beep;

		!! e.make;
		hotbabe.add_event(e);

		set_status_from_game(game);
		set_state(App_state_gameover);
	end

	game_over_player_mates is
	local
		s: CHESS_GUI_CHAT_SENTENCE;
		e: HOTBABE_EVENT_PLAYER_WINS;
	do
		!! s.make_system;
		s.append_normal("[CHECK-MATE ");
		s.append_bold(player_nick);
		s.append_normal(" WINS]");

		ui.add_chat_newline;
		ui.add_chat_sentence(s);
		ui.add_chat_newline;

		ui.disable_chess_board;
		ui.good_beep;

		!! e.make;
		hotbabe.add_event(e);

		set_status_from_game(game);
		set_state(App_state_gameover);
	end

	game_over_player_resigns is
	local
		s: CHESS_GUI_CHAT_SENTENCE;
		e: HOTBABE_EVENT_PLAYER_RESIGNS;
	do
		!! s.make_system;
		s.append_normal("[");
		s.append_bold(player_nick);
		s.append_normal(" RESIGNS]");

		ui.add_chat_newline;
		ui.add_chat_sentence(s);
		ui.add_chat_newline;

		resigned := True;

		ui.disable_chess_board;
		ui.bad_beep;

		!! e.make;
		hotbabe.add_event(e);

		set_status_from_game(game);
		set_state(App_state_gameover);
	end

	game_over_stale_mate is
	local
		s: CHESS_GUI_CHAT_SENTENCE;
		e: HOTBABE_EVENT_STALE_MATE;
	do
		!! s.make_system;
		s.append_normal("[STALE-MATE]");

		ui.add_chat_newline;
		ui.add_chat_sentence(s);
		ui.add_chat_newline;

		ui.disable_chess_board;
		ui.bad_beep;

		!! e.make;
		hotbabe.add_event(e);

		set_status_from_game(game);
		set_state(App_state_gameover);
	end

	game_over_draw is
	local
		s: CHESS_GUI_CHAT_SENTENCE;
		e: HOTBABE_EVENT_DRAW;
	do
		!! s.make_system;
		s.append_normal("[DRAW]");

		ui.add_chat_newline;
		ui.add_chat_sentence(s);
		ui.add_chat_newline;

		ui.disable_chess_board;
		ui.bad_beep;

		!! e.make;
		hotbabe.add_event(e);

		set_status_from_game(game);
		set_state(App_state_gameover);
	end

	change_nickname(new_nick: STRING) is
		-- whenever we change the nickname
		-- call this function
	require
		new_nick /= Void;
	local
		old_nickname: STRING;
	do
		!! old_nickname.make_from_string(player_nick);
		player_nick := new_nick;

		if state /= App_state_nogame then
			ui.set_nickname(player_color, player_nick);
		end

		txtutil.set_variable("player", player_nick);
	end

	new_game(g: CHESS_GAME; opts: CHESS_GAME_OPTIONS; res: BOOLEAN) is
		-- prepare a new game, configure chess search
		-- setup the GUI board, and move history
		--
		-- 'res' - resigned flag
	require
		g /= Void;
		opts /= Void;
		state = App_state_nogame
			or state = App_state_gameover;
	local
		ply: INTEGER;
		str: STRING;
	do
		game := g;
		game_options := opts;
		resigned := res;

		search.initialize(
			game_options.max_ply,
			game_options.max_time,
			game_options.qsearch);

		if game_options.player_color = Chess_color_white then
			bottom_side := Chess_color_white;
			player_color := Chess_color_white;
			hotbabe_color := Chess_color_black
		else
			bottom_side := Chess_color_black;
			player_color := Chess_color_black;
			hotbabe_color := Chess_color_white
		end

		ui.set_bottom_color(bottom_side);
		ui.set_nickname(player_color, player_nick);
		ui.set_nickname(hotbabe_color, hotbabe_nick);

		ui.clear_history;
		from
			ply := 1;
		until
			ply > game.total_plies
		loop
			str := game.move_out(ply);
			ui.add_history_move(str);
			ply := ply + 1;
		end

		current_ply := game.total_plies;
		ui.set_num_plies(current_ply);

		redraw_board;

		set_status_from_game(game);

		set_hotbabe_score;

		if resigned then
			set_state(App_state_gameover);
			set_side_to_move( game.side_to_move );
			ui.disable_chess_board;

		elseif game.game_over then
			set_state(App_state_gameover);
			set_side_to_move( get_opposite_color(game.side_to_move) );
			ui.disable_chess_board;

		else
			set_state(App_state_idle);
			set_side_to_move(game.side_to_move);
			if game.side_to_move = game_options.player_color then
				player_start_move;
			else
				hotbabe_start_move;
			end
		end
	end

	set_status_from_game(g: CHESS_GAME) is
		--
		-- given a CHESS_GAME, set the status fields
		--
	require
		g /= Void;
	do
		if resigned then
			if g.side_to_move = player_color then
				set_game_status("", "Resigns");
			else
				set_game_status("Resigns", "");
			end

		elseif g.check_mate then
			if g.side_to_move = player_color then
				set_game_status("Winner!", "");
			else
				set_game_status("", "Winner!");
			end

		elseif g.stale_mate then
			set_game_status("Stale-mate", "Stale-mate");

		elseif g.draw then
			set_game_status("Draw", "Draw");

		else
			set_game_status("", "");
		end
	end

	set_game_status(hstatus, pstatus: STRING) is
		-- set hotbabe_status and player_status
		-- and update the user interface
		--
		-- 'hstatus' the new hotbabe_status text
		-- 'pstatus' the new player_status text
	require
		hstatus /= Void;
		pstatus /= Void;
	do
		!! hotbabe_status.make_from_string(hstatus);
		!! player_status.make_from_string(pstatus);

		refresh_game_status;
	end

	refresh_game_status is
		-- update the display with the player and hotbabe
		-- status text
	do
		ui.set_status(player_color, player_status);
		ui.set_status(hotbabe_color, hotbabe_status);
	end

	debug_add_events(lst: LINKED_LIST[ HOTBABE_EVENT ]) is
		-- add all events in 'lst' to the HOTBABE object.
	require
		hotbabe.debug_mode;
		lst /= Void;
	do
		from
			lst.start;
		until
			lst.off
		loop
			hotbabe.add_event(lst.item);
			lst.forth;
		end
	end

	debug_save_current_game is
		--
		-- save current game into "Install_dir/debug_game.txt"
		--
		-- THis happens every time the player makes a move,
		-- only when DEBUG is enabled.
		--
	local
		f: CHESS_GAME_FILE;
		fn: STRING;
	do
		fn := install_dir.item + "\" + "debug_game.txt";
		!! f.make(fn);
		f.save(game, game_options, player_nick, resigned);
	end

	set_hotbabe_score is
		-- whenever moves are applies (or undone) from the
		-- game, we want to update the score.
		-- This score is relative to hotbabe.
	do
		if hotbabe_color = Chess_color_white then
			hotbabe.set_score( game.board.score );
		else
			hotbabe.set_score( -game.board.score );
		end
	end

	add_move_event(is_hotbabe: BOOLEAN; mov_type, capture_piece: INTEGER) is
		-- add an event to the hotbabe queue
		-- 'is_hotbabe' indicates if this move is
		-- for hotbabe or not.
		--
		-- If hotbabe (or player) is in check, then
		-- add the CHECKS event, instead of the move.
		--
		-- This routine is called just after hotbabe (or player)
		-- has made its move.
		--
		-- This routine is not intended to be called if the
		-- game is over.
		--
		-- 
		--
	require
		valid_move_type(mov_type);
		valid_piece_type(capture_piece) or (capture_piece = Piece_type_none);
	local
		color: INTEGER;
		e: HOTBABE_EVENT;
	do
		if is_hotbabe then
			color := hotbabe_color;
		else
			color := player_color;
		end

		if game.board.is_in_check( get_opposite_color(color) ) then
			!HOTBABE_EVENT_CHECKS! e.make(is_hotbabe);
			hotbabe.add_event(e);
		else

			inspect mov_type
			when Move_pawn_ep then
				!HOTBABE_EVENT_EP_CAPTURES! e.make(is_hotbabe);

			when Move_pawn_promote_q, Move_pawn_promote_r,
				Move_pawn_promote_n, Move_pawn_promote_b
			   then
				!HOTBABE_EVENT_PROMOTES! e.make(is_hotbabe);

			when Move_castle_kingside, Move_castle_queenside
			   then
				!HOTBABE_EVENT_CASTLES! e.make(is_hotbabe);

			else
				inspect capture_piece
				when Piece_type_queen then
					!HOTBABE_EVENT_CAPTURES_QUEEN! e.make(is_hotbabe);

				when Piece_type_rook then
					!HOTBABE_EVENT_CAPTURES_ROOK! e.make(is_hotbabe);

				when Piece_type_bishop then
					!HOTBABE_EVENT_CAPTURES_BISHOP! e.make(is_hotbabe);

				when Piece_type_knight then
					!HOTBABE_EVENT_CAPTURES_KNIGHT! e.make(is_hotbabe);

				when Piece_type_pawn then
					!HOTBABE_EVENT_CAPTURES_PAWN! e.make(is_hotbabe);

				else
					!HOTBABE_EVENT_NORMAL! e.make(is_hotbabe);
				end
			end
			hotbabe.add_event(e);
		end
	end

	show_bad_link(error_message: STRING) is
	require
		error_message /= Void;
	local
		sentence: CHESS_GUI_CHAT_SENTENCE;
	do
		ui.bad_beep;
		!! sentence.make_system;
		sentence.append_normal(error_message);

		ui.add_chat_newline;
		ui.add_chat_sentence(sentence);
		ui.add_chat_newline;
	end

feature {NONE} -- Implementation
	ui: CHESS_APPLICATION_USER_INTERFACE;
	state: INTEGER;
	game: CHESS_GAME;
	game_options: CHESS_GAME_OPTIONS;
	search: CHESS_SEARCH;
	hotbabe: HOTBABE;
	install_dir: CHESS_APPLICATION_INSTALL_DIR;
	txtutil: CHAT_TEXT_UTILITIES;

	player_color: INTEGER;
	hotbabe_color: INTEGER;
	side_to_move: INTEGER;

	player_nick: STRING;
	hotbabe_nick: STRING;

	player_status: STRING;
	hotbabe_status: STRING;

	bottom_side: INTEGER;
	current_ply: INTEGER;

	resigned: BOOLEAN;

	file_name: STRING;
	video_file: STRING;
	video_file_available: BOOLEAN;

	last_hint_string: STRING;
	last_hint: CHESS_MOVE;

	--
	-- defaults
	--
	Default_player_nickname: STRING is "player";
	Default_title: STRING is "Hotbabe Chess v1.2";
	No_player: STRING is "";
	Timer_counter_limit: INTEGER is 7;
	Last_game_filename: STRING is "lastgame.txt";
end

