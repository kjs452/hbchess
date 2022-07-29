indexing
	description:	"defines a video clip"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

--
-- A video clip is simply the start and end frame. It
-- defines a region of the AVI file that can be played on request.
-- These objects are constructed from reading
-- the data file "hotbabe_chess.dat".
--

class HOTBABE_CLIP

creation
	make

feature -- Initialization
	make(sf, ef: INTEGER; m: BOOLEAN) is
		-- create a video clip.
		-- Start frame 'sf' must be non-negative and
		-- End frame 'ef' must be greater than start frame.
		-- Rating (mature, general audience) for this clip
		-- is specified by 'm'.
	require
		sf >= 0;
		ef > sf;
	do
		start_frame := sf;
		end_frame := ef;
		mature := m;
	end

feature -- Access
	mature: BOOLEAN;
	start_frame: INTEGER;
	end_frame: INTEGER;
end
