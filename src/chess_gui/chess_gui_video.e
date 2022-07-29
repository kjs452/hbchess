indexing
	description:	"simulates a web cam, displays video images"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

class CHESS_GUI_VIDEO
inherit
	WEL_CONTROL_WINDOW
	rename
		make as wel_make,
		make_with_coordinates as wel_make_with_coordinates
	export {NONE}
		wel_make,
		wel_make_with_coordinates
	redefine
		on_paint,
		on_query_new_palette,
		default_process_message,
		set_text
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

	WEL_SYSTEM_METRICS
	export
		{NONE} all
	end

	WEX_MMCI_CONSTANTS
	export
		{NONE} all
	end

	WEX_MCI_SEEK_CONSTANTS
	export
		{NONE} all
	end

	WEX_MCI_CONSTANTS
	export
		{NONE} all
	end

	CHESS_GUI_CONTROL

creation
	make

feature -- Initialization
	make(a_parent: CHESS_GUI_WINDOW; px, py: INTEGER; bitmap_id: INTEGER) is
	do
		wel_make(a_parent, "");
		set_chess_window(a_parent);

		!! videobg_bitmap.make_by_id(bitmap_id);

		move_and_resize(px, py, 
				videobg_bitmap.width, videobg_bitmap.height, False);

		!! video_window.make(Current, "");
		video_window.hide;

		!! text_rect.make(0, 0, videobg_bitmap.width, 16);

		failed := False;
		error_message := Void;
	end

	failed: BOOLEAN;
	error_message: STRING;

feature -- Access
	on_paint(paint_dc: WEL_PAINT_DC; invalid_rect: WEL_RECT) is
	do
		paint_dc.draw_bitmap(videobg_bitmap, 0, 0,
			videobg_bitmap.width, videobg_bitmap.height);

		draw_edge(paint_dc, client_rect, Edge_raised, Bf_rect);
		paint_dc.set_background_transparent;
		paint_dc.set_text_color(White);
		paint_dc.draw_centered_text(text, text_rect);
	end

feature -- Basic operations
	set_text(a_text: STRING) is
		-- Set the text above the webcam to 'a_text'
	do
		Precursor(a_text);
		invalidate;
	end

	set_video(a_file_name: STRING) is
		--
		-- set video file, if file is invalid, or
		-- there is an error, then set 'failed' and 'error_message'
		--
	require
		a_file_name_not_void: a_file_name /= Void
		a_file_name_meaningful: not a_file_name.is_empty
	local
		rect: WEL_RECT
	do
		failed := False;

		stop_and_close_video_device;
		video_device.open(a_file_name);
		if video_device.opened then
			rect := video_device.source_rectangle;
			video_window.move_and_resize(8, 16, rect.width, rect.height, True);
			video_device.set_window(video_window);

			stop;

			if not video_device.frames_format then
				error_message := a_file_name
					+ ": invalid format (should be frames based)";
				failed := True;
			end
		else
			error_message := a_file_name + ": unable to open video file";
			failed := True;
		end
	ensure
		failed implies (error_message /= Void);
	end

	play is
		-- play the whole video
	do
		playing_clip := True;
		video_device.enable_notify;
		video_window.show;
		video_device.play;
	end

	play_clip(start_frame, end_frame: INTEGER) is
		--
		-- play a clip beginning at 'start_frame' and
		-- ending at 'end_frame'. When the clip completes
		-- then a message 'send_video_notify' is sent
		-- to the CHESS_APPLICATION_MAIN_WINDOW
		--
	require
		start_frame >= 0;
		start_frame < end_frame;
	local
		play_parms: WEX_MCI_PLAY_PARMS;
	do
		playing_clip := True;
		video_window.show;

		!! play_parms.make(Current, start_frame, end_frame);

		video_device.enable_notify;
		video_device.play_device(play_parms, Mci_from + Mci_to);
	end

	stop is
		--
		-- stop the video
		--
	do
		playing_clip := False;
		video_device.disable_notify;
		video_window.hide;
		stop_video_device;
	end

feature -- Status Report
feature -- Status Setting
feature -- Element Change
feature -- Removal

feature {NONE} -- Behavior
	default_process_message(a_msg, wparam, lparam: INTEGER) is
	do
		if a_msg = Mm_mcinotify then
			if playing_clip then
				playing_clip := False;
				send_video_notify(a_msg, wparam, lparam);
			end
		end
	end

feature {NONE} -- Implementation
	stop_video_device is
	do
		if video_device.opened then
			if video_device.playing then
				video_device.stop
			end
		end
	end

	stop_and_close_video_device is
	do
		if video_device.opened then
			if video_device.playing then
				video_device.stop;
			end
			video_device.close;
		end
	end

	on_query_new_palette is
		-- Adjust the palette on the video if palette
		-- is changing.
	do
		video_device.realize_palette_as_background;
	end

	video_window: WEL_CONTROL_WINDOW;

	video_device: CHESS_GUI_VIDEO_DEVICE is
		-- device to play an AVI
	once
		!! Result.make(Current);
		Result.set_strict(True);
	end

	text_rect: WEL_RECT;
	videobg_bitmap: WEL_BITMAP;
	playing_clip: BOOLEAN;

end

