indexing
	description:	"graphical representation of a chess board"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

--
-- This is a major component of the chess program. It displays
-- a graphical chess board and handles mouse events to allow
-- the user to move chess pieces.
--
-- This class uses the following classes:
-- CHESS_GUI_SPRITE_MANAGER
--	This class stores all the bitmaps that we draw on the screen
--
-- CHESS_GUI_TRANSFORM
--	This class converts screen coordinates to chess squares etc...
--
-- CHESS_GUI_DEVICE
--	All windows device context stuff is handled by this class
--
-- CHESS_GUI_BOARD_INFO
--	The main application passes a BOARD_INFO object to us, and
--	this object tells us what pieces are on the board and what
--	valid moves are available.
--
-- Public operations:
--	Redraw - this is the most common operation. It simply redraw
--	the chess board control (based on the CHESS_GUI_BOARD_INFO)
--
--	rotate - this flips the board and internally we remember what
--	the rotation setting is.
--
--	animate - will animate a piece from one square to another
--
-- Events
--	left_button_down - begins a drag operation
--
--	left_button_up - finishes a drag operation
--
--	mouse_move - drags a bitmap transparently
--
-- Pawn promotion: This class will also handle pawn promotion, by displaying
-- a small raised window that lets the user select a promotion piece.
--
--

class CHESS_GUI_BOARD
inherit
	WEL_CONTROL_WINDOW
	rename
		make as control_make
	redefine
		on_paint,
		on_left_button_down,
		on_left_button_up,
		on_mouse_move,
		enable,
		disable
	end

	WEL_WINDOWS_ROUTINES
	export
		{NONE} all
	end

	CHESS_GUI_CONTROL

	WEL_MK_CONSTANTS
	export
		{NONE} all
	end

	SCC_SYSTEM_TIME

creation
	make

feature -- Initialization
	make(a_parent: CHESS_GUI_WINDOW; px, py: INTEGER;
					sprite_mgr: CHESS_GUI_SPRITE_MANAGER) is
	require
		a_parent /= Void;
		px >= 0 and py >= 0;
		sprite_mgr /= Void;
		sprite_mgr.exists;
	local
		s: CHESS_GUI_SPRITE;
		w, h: INTEGER;
	do
		control_make(a_parent, "");
		set_chess_window(a_parent);
		sprites := sprite_mgr;

		!! board_info.make_empty;

		!! intersection.make(0,0,0,0);
		side_facing_bottom := Chess_color_white;

		--
		-- Setup client_rect for this control
		--
		s := sprites.board(side_facing_bottom);
		w := s.width;
		h := s.height;

		s := sprites.capture_area;
		w := w + s.width;

		check
			-- because capture area must have
			-- same height as the board
			s.height = h;
		end

		move_and_resize(px, py, w, h, False);

		--
		-- Setup the transform
		--
		!! tf.make(client_rect.left, client_rect.top,
				client_rect.right, client_rect.bottom);
		tf.set_border_size(sprites.border_width, sprites.border_height);

		s := sprites.board(side_facing_bottom);
		tf.set_board_size(s.width, s.height);

		s := sprites.capture_area;
		tf.set_capture_area_size(s.width, s.height);

		s := sprites.piece(Piece_white_pawn);
		tf.set_piece_size(s.width, s.height);

		s := sprites.capture_piece(Piece_white_pawn);
		tf.set_capture_piece_size(s.width, s.height);

		tf.set_rotation(side_facing_bottom);

		!! cdev.make(Current, client_rect);

		animating := False;
		enable;
	end

	set_board_info(a_board_info: CHESS_GUI_BOARD_INFO) is
	require
		a_board_info /= Void;
	do
		board_info := a_board_info;
	end

	disable is
	do
		Precursor;
		mode := Disabled_mode;
	end

	enable is
	do
		Precursor;
		mode := Enabled_mode;
	end

feature -- Drawing
	redraw is
	require
		exists: exists;
	local
		board: CHESS_GUI_SPRITE;
	do
		cdev.save_window;
		board := sprites.board(side_facing_bottom);
		cdev.draw(0, 0, board);

		cdev.draw(board.width, 0, sprites.capture_area);

		redraw_pieces;
		redraw_captures(Chess_color_white);
		redraw_captures(Chess_color_black);

		if mode = Promoting_mode then
			redraw_promotion;
		end

		cdev.restore_window;
	end

	animate(from_square, to_square: INTEGER) is
		-- animate the piece located at 'from_square' and
		-- move it to 'to_square'
		--
		-- This routine can be used to move a piece backwards
		-- (during UNDO operations)
		--
		-- The 'animating' flag is set so that the
		-- board_drag_begin routine will not
		-- check if the move is valid.
		--
	require
		valid_square(from_square);
		valid_square(to_square);
	local
		seg: CHESS_GUI_LINE_SEGMENT;
		x1, y1, x2, y2: INTEGER;
	do
		check
			-- from_square must be occupied
			-- make sure there exists a piece
			board_info.occupied(from_square);
		end

		animating := True;

		tf.square_to_screen(from_square);
		x1 := tf.piece_x;
		y1 := tf.piece_y;

		tf.square_to_screen(to_square);
		x2 := tf.piece_x;
		y2 := tf.piece_y;

		!! seg.make(x1, y1, x2, y2, 5);

		board_drag_begin(x1, y1);

		from
			seg.start;
		until
			seg.off
		loop
			board_drag_to(seg.x, seg.y);

			delay(10);

			seg.forth;
		end

		animating := False;
		enable;
	end


feature -- Access
	side_facing_bottom: INTEGER;

feature -- Messages
	on_paint(paint_dc: WEL_PAINT_DC; invalid_rect: WEL_RECT) is
	do
		cdev.virtual_to_dc(paint_dc, invalid_rect);
	end

	on_left_button_down(keys, x_pos, y_pos: INTEGER) is
		-- Wm_lbuttondown message
		-- See class WEL_MK_CONSTANTS for `keys' value
	do
		if mode = Enabled_mode then
			if tf.screen_in_bounds(x_pos, y_pos) then
				capture_mouse;
				if tf.screen_in_board(x_pos, y_pos) then
					board_drag_begin(x_pos, y_pos);
				end
				if mode = Enabled_mode then
					release_mouse;
				end
			end
		end
	end

	on_left_button_up(keys, x_pos, y_pos: INTEGER) is
		-- Wm_lbuttonup message
		-- See class WEL_MK_CONSTANTS for `keys' value
	do
		if mode = Dragging_mode then
			tf.clamp_screen_to_board(x_pos, y_pos);
			board_drag_end(tf.x, tf.y);
			if mode = Enabled_mode then
				release_mouse;
			end
		elseif mode = Promoting_mode then
			tf.clamp_screen_to_board(x_pos, y_pos);
			promotion_select(tf.x, tf.y);
			if mode = Enabled_mode then
				release_mouse;
			end
		end
	end

	on_mouse_move(keys, x_pos, y_pos: INTEGER) is
		-- Wm_mousemove message
		-- See class WEL_MK_CONSTANTS for `keys' value
	do
		if mode = Dragging_mode then
			tf.clamp_screen_to_board(x_pos, y_pos);
			board_drag_to(tf.x, tf.y);
		elseif mode = Promoting_mode then
			tf.clamp_screen_to_board(x_pos, y_pos);
			promotion_move_to(tf.x, tf.y);
		end
	end

feature -- Status Report

feature -- Status Setting
	rotate(side: INTEGER) is
		-- rotate board so that 'side' pieces are
		-- at the bottom of the screen.
	require
		valid_piece_color(side);
	do
		side_facing_bottom := side;
		tf.set_rotation(side);
		redraw;
	end

feature -- Element Change
feature -- Removal

feature {NONE} -- Implementation
	board_info: CHESS_GUI_BOARD_INFO;

	cdev: CHESS_GUI_DEVICE;
	sprites: CHESS_GUI_SPRITE_MANAGER;
	tf: CHESS_GUI_TRANSFORM;

	intersection: WEL_RECT;

feature {NONE} -- Implementation Routines

	redraw_pieces is
	local
		square: INTEGER;
		sprite, mask: CHESS_GUI_SPRITE;
		piece: INTEGER;
	do
		from
			square := Min_square;
		until
			square > Max_square
		loop
			if board_info.occupied(square) then
				piece := board_info.piece_at(square);
				sprite := sprites.piece(piece);
				mask := sprites.mask(piece);
				tf.square_to_virtual(square);

				cdev.draw_transparent(tf.piece_x, tf.piece_y, sprite, mask);
			end
			square := square + 1;
		end
	end

	redraw_captures(side: INTEGER) is
		-- redraw all the pieces that 'side' has captured.
	require
		valid_piece_color(side);
	local
		num_captures, n: INTEGER;
		piece: INTEGER;
		sprite, mask: CHESS_GUI_SPRITE;
	do
		--
		-- redraw capture area
		--
		from
			n := 1;
			num_captures := board_info.num_captures(side);
		until
			n > num_captures
		loop
			piece := board_info.capture(side, n);

			sprite := sprites.capture_piece(piece);
			mask := sprites.capture_mask(piece);

			tf.capture_to_virtual(side, n);

			cdev.draw_transparent(tf.piece_x, tf.piece_y, sprite, mask);

			n := n + 1;
		end
	end

	redraw_promotion is
		-- draw a promotion selection screen in the center of the board
	local
		square_color, piece_color: INTEGER;
		piece: INTEGER;
		sprite, mask: CHESS_GUI_SPRITE;
		empty: CHESS_GUI_SPRITE;
	do
		--
		-- 1. erase piece at src_square and dst_square
		-- 2. draw piece at dst_square
		-- 3. draw filled raised rectangle in center of board
		-- 4. draw queen, rook, bishop, knight pieces
		-- 5. draw text "Promote pawn to?"
		--
		square_color := tf.square_color(src_square);
		empty := sprites.empty_square(square_color);
		tf.square_to_virtual(src_square);
		cdev.draw(tf.piece_x, tf.piece_y, empty);

		square_color := tf.square_color(dst_square);
		empty := sprites.empty_square(square_color);
		tf.square_to_virtual(dst_square);
		cdev.draw(tf.piece_x, tf.piece_y, empty);

		piece := board_info.piece_at(src_square);
		piece_color := get_piece_color(piece);
		sprite := sprites.piece(piece);
		mask := sprites.mask(piece);
		tf.square_to_virtual(dst_square);
		cdev.draw_transparent(tf.piece_x, tf.piece_y, sprite, mask);

		-- draw rect
		tf.promotion_rect;
		cdev.draw_promotion_rect(tf.x, tf.y, tf.x + tf.width, tf.y + tf.height);

		-- draw text
		cdev.draw_promotion_text(tf.x, tf.y+3,
				tf.x + tf.width,
				tf.y + tf.height//4,
				"Promote Pawn to?");

		-- draw pieces
		piece := get_colored_piece(Piece_type_queen, piece_color);
		sprite := sprites.piece(piece);
		mask := sprites.mask(piece);

		tf.promotion_slot(1);
		cdev.draw_transparent(tf.x, tf.y, sprite, mask);

		piece := get_colored_piece(Piece_type_rook, piece_color);
		sprite := sprites.piece(piece);
		mask := sprites.mask(piece);

		tf.promotion_slot(2);
		cdev.draw_transparent(tf.x, tf.y, sprite, mask);

		piece := get_colored_piece(Piece_type_bishop, piece_color);
		sprite := sprites.piece(piece);
		mask := sprites.mask(piece);

		tf.promotion_slot(3);
		cdev.draw_transparent(tf.x, tf.y, sprite, mask);

		piece := get_colored_piece(Piece_type_knight, piece_color);
		sprite := sprites.piece(piece);
		mask := sprites.mask(piece);

		tf.promotion_slot(4);
		cdev.draw_transparent(tf.x, tf.y, sprite, mask);

	end

feature {NONE} -- mouse events handling
	Disabled_mode: INTEGER is unique;
	Enabled_mode: INTEGER is unique;
	Dragging_mode: INTEGER is unique;
	Promoting_mode: INTEGER is unique;

	mode: INTEGER;

	animating: BOOLEAN;

	src_square: INTEGER;
	dst_square: INTEGER;
	old_x, old_y: INTEGER;
	drag_piece: INTEGER;
	rel_x, rel_y: INTEGER;
	highlighted_square: INTEGER;
	old_pslot: INTEGER;

	board_drag_begin(x_pos, y_pos: INTEGER) is
	local
		square, piece, color: INTEGER;
		empty: CHESS_GUI_SPRITE;
		s, sm: CHESS_GUI_SPRITE;
	do
		mode := Enabled_mode;

		tf.screen_to_square(x_pos, y_pos);
		square := tf.square;
		if board_info.occupied(square) then
			if board_info.can_move(square) or animating then
				piece := board_info.piece_at(square);
				color := get_piece_color(piece);
				mode := Dragging_mode;
			end
		end

		if mode = Dragging_mode then
			drag_piece := piece;
			src_square := square;
			dst_square := No_square_specified;
			highlighted_square := No_square_specified;

			--
			-- Compute relative difference from
			-- mouse coordinates and the top/left of
			-- the src_square. We use this offset througout
			-- the drag operation, to keep the relative position
			-- of the mouse pointer and the piece being moved constant.
			--
			tf.square_to_screen(square);
			rel_x := x_pos - tf.x;
			rel_y := y_pos - tf.y;

			--
			-- erase piece that we are to begin moving
			--
			tf.square_to_virtual(src_square);
			color := tf.square_color(src_square);
			empty := sprites.empty_square(color);
			cdev.draw_win(tf.piece_x, tf.piece_y, empty);

			--
			-- highlight source square
			--
			tf.square_to_virtual(src_square);
			cdev.draw_cursor(tf.x, tf.y, tf.width, tf.height);

			cdev.save_window;

			--
			-- draw sprite
			--
			s := sprites.piece(drag_piece);
			sm := sprites.mask(drag_piece);
			tf.square_to_virtual(src_square);
			cdev.draw_transparent_win(tf.piece_x, tf.piece_y, s, sm);

			old_x := x_pos - rel_x;
			old_y := y_pos - rel_y;
		end
	end

	board_drag_to(x_pos, y_pos: INTEGER) is
	local
		wx, wy: INTEGER;
		color: INTEGER;
		s, sm: CHESS_GUI_SPRITE;
		empty: CHESS_GUI_SPRITE;
	do
		s := sprites.piece(drag_piece);
		sm := sprites.mask(drag_piece);

		--
		-- shift mouse coordinates (relative to the piece bitmap)
		-- 
		wx := x_pos - rel_x;
		wy := y_pos - rel_y;

		--
		-- figure out the current square
		--
		tf.clamp_screen_to_board(wx + s.width//2, wy + s.height//2);
		tf.screen_to_square(tf.x, tf.y);
		dst_square := tf.square;

		--
		-- restore area underneath old piece
		--
		tf.screen_to_virtual(old_x, old_y);
		cdev.restore_area(tf.x, tf.y, s.width, s.height);

		--
		-- erase old cursor (if changed)
		--
		if dst_square /= highlighted_square
			and highlighted_square /= No_square_specified
		then
			color := tf.square_color(highlighted_square);
			empty := sprites.empty_square(color);

			tf.square_to_virtual(highlighted_square);
			cdev.erase_cursor(empty, tf.x, tf.y, tf.width, tf.height);
			highlighted_square := No_square_specified;
		end

		--
		-- Draw new cursor (if changed)
		--
		if dst_square /= highlighted_square and then
				board_info.valid_move(src_square, dst_square)
		then
			tf.square_to_virtual(dst_square);
			cdev.draw_cursor(tf.x, tf.y, tf.width, tf.height);
			highlighted_square := dst_square;
		end

		--
		-- draw piece being moved
		--
		tf.screen_to_virtual(wx, wy);
		cdev.draw_transparent_win(tf.x, tf.y, s, sm);

		old_x := wx;
		old_y := wy;
	end

	board_drag_end(x_pos, y_pos: INTEGER) is
	local
		color: INTEGER;
		s, sm: CHESS_GUI_SPRITE;
		empty: CHESS_GUI_SPRITE;
	do
		mode := Enabled_mode;

		s := sprites.piece(drag_piece);
		sm := sprites.mask(drag_piece);

		--
		-- erase the piece that was being dragged
		--
		tf.screen_to_virtual(old_x, old_y);
		cdev.restore_area(tf.x, tf.y, s.width, s.height);

		if dst_square /= No_square_specified
				and then board_info.valid_move(src_square, dst_square)
		then
			--
			-- VALID MOVE: So erase piece (if any) at
			-- destination square, and then draw the moved
			-- piece there.
			--
			color := tf.square_color(dst_square);
			tf.square_to_virtual(dst_square);
			empty := sprites.empty_square(color);
			cdev.draw_win(tf.piece_x, tf.piece_y, empty);
			cdev.draw_transparent_win(tf.piece_x, tf.piece_y, s, sm);
			cdev.erase_cursor(empty, tf.x, tf.y, tf.width, tf.height);

			if board_info.is_pawn_promotion(src_square, dst_square) then
				mode := Promoting_mode;
				old_pslot := 0;
				redraw;
			else
				mode := Enabled_mode;
				send_move_chess_piece(src_square, dst_square, Piece_none);
			end
		else
			--
			-- INVALID MOVE:
			-- restore piece to original square and erase the
			-- src_square highlight
			--
			color := tf.square_color(src_square);
			tf.square_to_virtual(src_square);
			empty := sprites.empty_square(color);
			cdev.draw_win(tf.x, tf.y, empty);
			cdev.erase_cursor(empty, tf.x, tf.y, tf.width, tf.height);

			tf.square_to_virtual(src_square);
			cdev.draw_transparent_win(tf.piece_x, tf.piece_y, s, sm);
			mode := Enabled_mode;
		end

		cdev.save_window;
	end

	promotion_move_to(x_pos, y_pos: INTEGER) is
	require
		mode = Promoting_mode;
	local
		empty: CHESS_GUI_SPRITE;
	do
		if old_pslot /= 0 then
			empty := sprites.empty_square(Chess_color_white);
			tf.promotion_slot(old_pslot);
			cdev.erase_cursor(empty,
					tf.x-3, tf.y-3, tf.width+6, tf.height+6);
			old_pslot := 0;
		end

		tf.screen_to_promotion_slot(x_pos, y_pos);
		if tf.slot /= 0 then
			tf.promotion_slot(tf.slot);
			cdev.draw_cursor(tf.x-3, tf.y-3, tf.width+6, tf.height+6);
			old_pslot := tf.slot;
		end
	end

	promotion_select(x_pos, y_pos: INTEGER) is
	require
		mode = Promoting_mode;
	local
		piece, piece_color: INTEGER;
	do
		tf.screen_to_promotion_slot(x_pos, y_pos);
		if tf.slot /= 0 then
			mode := Enabled_mode;
			--redraw;

			piece := board_info.piece_at(src_square);
			piece_color := get_piece_color(piece);

			inspect tf.slot
			when 1 then
				piece := get_colored_piece(Piece_type_queen, piece_color);
			when 2 then
				piece := get_colored_piece(Piece_type_rook, piece_color);
			when 3 then
				piece := get_colored_piece(Piece_type_bishop, piece_color);
			when 4 then
				piece := get_colored_piece(Piece_type_knight, piece_color);
			end

			send_move_chess_piece(src_square, dst_square, piece);
		else
			message_beep_ok;
		end
	end

	capture_mouse is
	do
		set_capture;
	end

	release_mouse is
	do
		if has_capture then
			release_capture;
		end
	end

	delay(ms: INTEGER) is
		-- wait 'ms' milliseconds
	require
		ms >= 0;
	local
		ending_tick_count: INTEGER;
	do
		from
			ending_tick_count := tick_count + ms;
		until
			tick_count >= ending_tick_count
		loop
			-- do nothing
		end
	end

end

