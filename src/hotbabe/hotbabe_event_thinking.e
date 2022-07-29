indexing
	description:	"show hotbabe thinking"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

class HOTBABE_EVENT_THINKING
inherit
	HOTBABE_EVENT
	redefine
		priority
	end

creation
	make

feature -- Initialization
	make is
	do
	end

feature -- Access
	priority: INTEGER is
	once
		Result := 101;
	end

feature -- Status Report
feature -- Status Setting
feature -- Element Change
feature -- Removal

feature -- Processing
	think is
	do
		video_clip := find_clip(Hg_hotbabe_thinking);
		text_message := find_text_using_last_path;
	end
end
