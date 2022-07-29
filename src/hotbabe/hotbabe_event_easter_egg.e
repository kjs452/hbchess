indexing
	description:	"play easter-egg video"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

class HOTBABE_EVENT_EASTER_EGG
inherit
	HOTBABE_EVENT
	redefine
		repeatable
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

feature -- Status Report
feature -- Status Setting
feature -- Element Change
feature -- Removal

feature -- Processing
	think is
	do
		video_clip := find_clip(Hg_easter_egg);
		text_message := find_text_using_last_path;
	end
end
