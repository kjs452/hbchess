indexing
	description:	"a windows that can contain CHESS_GUI_XXXX controls"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

class CHESS_GUI_WINDOW
inherit
	WEL_FRAME_WINDOW

	CHESS_GENERAL_CONSTANTS
	CHESS_SQUARE_CONSTANTS
	CHESS_PIECE_CONSTANTS
	export
		{ANY} Piece_none
	end

feature {CHESS_GUI_CONTROL} -- Event handlers

	on_move_chess_piece(ctrl: CHESS_GUI_CONTROL;
				src_square, dst_square, promote_piece: INTEGER) is
		-- a chess piece has been moved from src_square to dst_square
		-- if this move causes a promotion, then promote_piece will
		-- be set, otherwise it is set to Piece_none.
	require
		ctrl /= Void;
		valid_square(src_square);
		valid_square(dst_square);
		valid_piece(promote_piece) or (promote_piece = Piece_none);
	do
	end

	on_chess_scroll(ctrl: CHESS_GUI_CONTROL; pos: INTEGER) is
		-- event generated whenever the CHESS_GUI_HISTORY_SCROLL is
		-- moved. 'pos' is the 0-based ply that the scroll bar
		-- has been moved to.
	require
		ctrl /= Void;
		pos >= 0;
	do
	end

	on_chess_button_click(ctrl: CHESS_GUI_CONTROL; new_state: BOOLEAN) is
		-- event generated whenever the CHESS_GUI_IMAGE_BUTTON is
		-- depressed.
	require
		ctrl /= Void;
	do
	end

	on_chat_link_selected(ctrl: CHESS_GUI_CONTROL; link_data: CHESS_GUI_CHAT_LINK) is
		-- event generated when user clicks on a link phrase inside of
		-- the CHAT_OUTPUT control.
	require
		ctrl /= Void;
		link_data /= Void;
	do
	end

	on_video_notify(ctrl: CHESS_GUI_CONTROL; a_msg, wparam, lparam: INTEGER) is
		-- the video control has recieved a Mci_notify message
	require
		ctrl /= Void;
	do
	end

end
