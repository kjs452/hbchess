indexing
	description:	"behavior when user changes nickname"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

class HOTBABE_EVENT_NICKNAME_CHANGED
inherit
	HOTBABE_EVENT

creation
	make

feature -- Initialization
	make is
	do
	end

feature -- Access
	repeatable: BOOLEAN is False;

feature -- Status Report
feature -- Status Setting
feature -- Element Change
feature -- Removal

feature -- Processing
	think is
	do
		video_clip := find_clip(Hg_change_nickname);
		text_message := find_text_using_last_path;
	end

feature {NONE} -- Implementation

end
