indexing
	description:	"abstract description of the chess application from%
			% the perspective of the user interface"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

--
-- This is an abstract class that the main window must
-- implement. It defines a set of features that the
-- class 'CHESS_APPLICATION_MANAGER' expects to use
-- to manipulate the main window.
--
-- All the basic operations are available here, so that
-- the CHESS_APPLICATION_MANAGER doesn't need to know any
-- of the details about the user interface.
--
--
deferred class CHESS_APPLICATION_USER_INTERFACE
inherit
	CHESS_GENERAL_CONSTANTS
	CHESS_SQUARE_CONSTANTS
	CHESS_PIECE_CONSTANTS
	CHESS_SHORTCUT_CONSTANTS

feature -- Initialization
feature -- Commands
	add_chat_sentence(s: CHESS_GUI_CHAT_SENTENCE) is
		-- add sentence 's' to the chat output window
	require
		s /= Void;
	deferred
	end

	add_chat_sentence_list(lst: LINKED_LIST[ CHESS_GUI_CHAT_SENTENCE]) is
		-- add a list of sentences to the chat output window
	require
		lst /= Void;
	do
		from
			lst.start;
		until
			lst.off
		loop
			add_chat_sentence(lst.item);
			lst.forth;
		end
	end

	add_chat_newline is
		-- append newlines to chat output
	deferred
	end

	set_bottom_color(color: INTEGER) is
		-- tell the GUI what color pieces should be showing on the
		-- bottom of the screen.
	require
		valid_piece_color(color);
	deferred
	end

	clear_history is
		-- clear the move history
	deferred
	end

	add_history_move(s: STRING) is
		-- add a new move to the move history
	require
		s /= Void;
	deferred
	end

	remove_last_history_move is
		-- remove the last move in the history
	deferred
	end

	history_mark(ply: INTEGER) is
		-- highlight one of the moves in the history list
	require
		ply >= 0;
	deferred
	end

	history_clear_mark is
		-- don't highlight anything in the history list.
	deferred
	end

	disable_shortcut(shortcut: INTEGER) is
		-- make this shortcut command unavailable to the user
	require
		valid_shortcut(shortcut);
	deferred
	end

	enable_shortcut(shortcut: INTEGER) is
		-- make this shortcut available to the user
	require
		valid_shortcut(shortcut);
	deferred
	end

	set_turn(side: INTEGER) is
		-- update the display, to reflect the fact that
		-- it is 'side' turn to move.
	require
		valid_piece_color(side);
	deferred
	end

	clear_turn is
		-- update the display so that no "turn" indicator
		-- is showing.
	deferred
	end

	set_nickname(side: INTEGER; name: STRING) is
		-- set nickname for 'side'
	require
		valid_piece_color(side);
		name /= Void;
	deferred
	end

	set_status(side: INTEGER; str: STRING) is
		-- set status string for white or black 'side'
		-- This text is used to display such things as:
		-- 	"Resigned", "Winner!", "Draw", "Stale-mate"
	require
		valid_piece_color(side);
		str /= Void;
	deferred
	end

	set_video_file(fn: STRING): STRING is
		-- tell the GUI what the video file to play is
		-- return Void on, success or an error message.
	require
		fn /= Void;
	deferred
	end

	video_play is
	deferred
	end

	video_play_clip(start_frame, end_frame: INTEGER) is
	require
		start_frame >= 0;
		start_frame < end_frame;
	deferred
	end

	video_stop is
	deferred
	end

	set_webcam_nickname(name: STRING) is
		-- set the nickname that appears above the
		-- webcam
	require
		name /= Void;
	deferred
	end

	thinking: BOOLEAN;

	thinking_on is
		-- computer is thinking, show busy cursor
	require
		not thinking;
	deferred
	ensure
		thinking;
	end

	thinking_off is
		-- computer is idle, show normal cursor
	require
		thinking
	deferred
	ensure
		not thinking;
	end

	set_board_info(board: CHESS_GUI_BOARD_INFO) is
		-- tell the GUI what the chess board looks like
		-- and history information
	require
		board /= Void;
	deferred
	end

	animate_piece(from_square, to_square: INTEGER) is
	require
		valid_square(from_square);
		valid_square(to_square);
	deferred
	end

	enable_chess_board is
		-- allow user to interact with the chess
		-- board control
	deferred
	end

	disable_chess_board is
		-- prevent user from interacting with the chess
		-- board control
	deferred
	end

	disable_webcam is
		-- turn webcam off, and don't allow user
		-- to turn it back on
	deferred
	end

	set_num_plies(plies: INTEGER) is
	deferred
	end

	good_beep is
		-- generate a pleasant beep for the user to hear
	deferred
	end

	bad_beep is
		-- generate an unpleasant beep for the user to hear
	deferred
	end

	set_title(string: STRING) is
		-- set title of main window
	require
		string /= Void;
	deferred
	end

	show_menu is
		-- activate the command menu
	deferred
	end

	show_message_box(str: STRING) is
		-- display a message in a simple
		-- message box, used for
		-- intialization errors
	require
		str /= Void;
	deferred
	end

	change_nickname(old_nick: STRING): STRING is
		-- Prompt user to change his nickname
		-- return the new nickname.
	require
		old_nick /= Void;
	deferred
	ensure
		Result /= Void;
	end

	new_game_properties(old_opts: CHESS_GAME_OPTIONS): CHESS_GAME_OPTIONS is
	require
		old_opts /= Void;
	deferred
	end

	select_file_for_save(fn: STRING): STRING is
	require
		fn /= Void;
	deferred
	end

	select_file_for_load(fn: STRING): STRING is
	require
		fn /= Void;
	deferred
	end

	show_debug_screen: ANY is
	deferred
	end

feature -- Access
feature -- Status Report
feature -- Status Setting
feature -- Element Change
feature -- Removal
feature {NONE} -- Implementation

end
