indexing
	description:	"behavior when user flips chess board"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

class HOTBABE_EVENT_FLIP_BOARD
inherit
	HOTBABE_EVENT
	redefine
		repeatable, priority
	end

creation
	make

feature -- Initialization
	make is
	do
	end

feature -- Access
	repeatable: BOOLEAN is
	once
		Result := False;
	end

	priority: INTEGER is
	once
		Result := 5;
	end

feature -- Status Report
feature -- Status Setting
feature -- Element Change
feature -- Removal

feature -- Processing
	think is
	do
		if hotbabe_showing then
			video_clip := find_clip(Hg_flip_board);
			text_message := find_text_using_last_path;
		else
			video_clip := find_clip(Hg_nogame);
			text_message := Void;
		end
	end

feature {NONE} -- Implementation

end
