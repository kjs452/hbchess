indexing
	description:	"a graphical element for a chess game"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

class CHESS_GUI_SPRITE
inherit
	WEL_RASTER_OPERATIONS_CONSTANTS
	export
		{NONE} all
	end

	WEL_DIB_COLORS_CONSTANTS
	export
		{NONE} all
	end

	WEL_STRETCH_MODE_CONSTANTS
	export
		{NONE} all
	end

	CHESS_PIECE_CONSTANTS

creation
	make_by_id, make_by_filename, make_by_bitmap

feature -- Initialization
	make_by_id(id: INTEGER) is
	do
		!! bitmap.make_by_id(id);
		set_color;
	end

	make_by_filename(fn: STRING) is
	require
		fn /= Void;
	local
		rawf: RAW_FILE;
		dib: WEL_DIB;
		screen_dc: WEL_SCREEN_DC;
	do
		--
		-- check if file exists...
		--
		!! screen_dc;

		!! rawf.make_open_read(fn);
		!! dib.make_by_file(rawf);
		!! bitmap.make_by_dib(screen_dc, dib, Dib_rgb_colors);
		set_color;
	end

feature {NONE} -- Initialization
	make_by_bitmap(b: WEL_BITMAP) is
	require
		b /= Void; 
	do
		bitmap := b;
		set_color;
	end

feature -- Access
	width: INTEGER is
	do
		Result := bitmap.width;
	end

	height: INTEGER is
	do
		Result := bitmap.height;
	end

feature -- Status Report
feature -- Status Setting

feature -- Conversion
	invert: CHESS_GUI_SPRITE is
		-- an inverted version of Current.
		-- (in this case inverted means that all background areas
		--  are changed to the color BLACK)
	local
		logbm: WEL_LOG_BITMAP;
		new_bitmap: WEL_BITMAP;
		dc1, dc2, mono_dc: WEL_MEMORY_DC;
		mono_sprite: CHESS_GUI_SPRITE;
		mono: WEL_BITMAP;
	do
		--
		-- Get monochrome mask for Current
		--
		mono_sprite := mask;
		mono := mono_sprite.bitmap;

		--
		-- Put monochrome mask bitmap into a DC
		--
		!! mono_dc.make;
		mono_dc.select_bitmap(mono);

		--
		-- Create a new bitmap like Current
		--
		!! logbm.make_by_bitmap(bitmap);
		!! new_bitmap.make_indirect(logbm);

		--
		-- Put new bitmap into a DC
		--
		!! dc2.make;
		dc2.select_bitmap(new_bitmap);
		dc2.set_background_color(transparent_color);

		--
		-- Put Current bitmap into a DC
		--
		!! dc1.make;
		dc1.select_bitmap(bitmap);
		dc1.set_background_color(transparent_color);

		dc2.bit_blt(0, 0, width, height, dc1, 0, 0, Srccopy);
		dc2.bit_blt(0, 0, width, height, mono_dc, 0, 0, Srcinvert);

		mono_dc.unselect_all;
		dc1.unselect_all;
		dc2.unselect_all;
		mono_dc.delete;
		dc1.delete;
		dc2.delete;

		--
		-- Create a SPRITE based on the monochrome bitmap
		--
		!! Result.make_by_bitmap(new_bitmap);
	end

	mask: CHESS_GUI_SPRITE is
		-- a mask version of Current
		-- (Mask means that all background areas are changed
		-- to color WHITE, and all the other pixed are changed
		-- to black)
		-- See CHESS_GUI_DEVICE to see what is defined as the Background
		-- color.
	local
		logbm: WEL_LOG_BITMAP;
		mono: WEL_BITMAP;
		dc, mono_dc: WEL_MEMORY_DC;
	do
		--
		-- Create monochrome bitmap of same size as Current
		--
		-- !! logbm.make(width, height, 2, 1, 1, Void);
		!! logbm.make_by_bitmap(bitmap);
		logbm.set_bits_pixel(1);
		logbm.set_planes(1);
		!! mono.make_indirect(logbm);

		--
		-- Put monochrome bitmap in a DC
		--
		!! mono_dc.make;
		mono_dc.select_bitmap(mono);

		--
		-- Put Current bitmap into another DC
		--
		!! dc.make;
		dc.select_bitmap(bitmap);
		dc.set_background_color(transparent_color);

		--
		-- Copy bits from color DC to monochrome DC
		-- (All pixels that are 'transparent_color' will be white,
		--  and everything else will be black)
		--
		mono_dc.bit_blt(0, 0, width, height, dc, 0, 0, Srccopy);

		--
		-- Free up resources in the DC's
		--
		dc.unselect_all;
		mono_dc.unselect_all;
		dc.delete;
		mono_dc.delete;

		--
		-- Create a SPRITE based on monochrome bitmap
		--
		!! Result.make_by_bitmap(mono);
	end

feature -- Removal

feature {CHESS_GUI_DEVICE, CHESS_GUI_SPRITE}
			-- Device implementation

	transparent_color: WEL_COLOR_REF is
		-- this is the background color that
		-- we want transparent in the sprite.
		-- (bright yellow)
	once
		!! Result.make_rgb(255, 255, 0);
	end

	color: WEL_COLOR_REF;

	bitmap: WEL_BITMAP;

feature {NONE} -- Implementation
	set_color is
		-- get color of pixel (0,0)
		-- the color is used when we want to erase the
		-- yellow cursor from the chess board.
	local
		dc: WEL_MEMORY_DC;
	do
		!! dc.make;
		dc.select_bitmap(bitmap);

		color := dc.pixel_color(0, 0);

		dc.unselect_bitmap;
		dc.delete;
	end

invariant
	color /= Void;
	bitmap /= Void;
end
