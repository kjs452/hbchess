indexing
	description:	"ancestor to all CHESS_GUI_XXXX controls"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

class CHESS_GUI_CONTROL
inherit
	CHESS_GENERAL_CONSTANTS
	CHESS_SQUARE_CONSTANTS
	CHESS_PIECE_CONSTANTS

feature -- Access

feature {NONE} -- Implementation
	chess_window: CHESS_GUI_WINDOW;

	set_chess_window(a_chess_window: CHESS_GUI_WINDOW) is
	require
		a_chess_window /= Void;
	do
		chess_window := a_chess_window;
	end

feature {NONE} --  send message to chess window
	send_move_chess_piece(src_square, dst_square, promote_piece: INTEGER) is
	require
		valid_square(src_square);
		valid_square(dst_square);
		valid_piece(promote_piece) or (promote_piece = Piece_none);
	do
		chess_window.on_move_chess_piece(Current, src_square,
						dst_square, promote_piece);
	end

	send_chess_scroll(pos: INTEGER) is
	require
		pos >= 0;
	do
		chess_window.on_chess_scroll(Current, pos);
	end

	send_chess_button_click(new_state: BOOLEAN) is
	do
		chess_window.on_chess_button_click(Current, new_state);
	end

	send_chat_link_selected(link_data: CHESS_GUI_CHAT_LINK) is
	require
		link_data /= Void;
	do
		chess_window.on_chat_link_selected(Current, link_data);
	end

	send_video_notify(a_msg, wparam, lparam: INTEGER) is
	do
		chess_window.on_video_notify(Current, a_msg, wparam, lparam);
	end

end
