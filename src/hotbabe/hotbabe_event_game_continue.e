indexing
	description:	"behavior for hotbabe when restarting an existing game"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

class HOTBABE_EVENT_GAME_CONTINUE
inherit
	HOTBABE_EVENT

creation
	make

feature -- Initialization
	make is
	do
	end

feature -- Access
feature -- Status Report
feature -- Status Setting
feature -- Element Change
feature -- Removal

feature -- Processing
	think is
	do
		video_clip := find_clip(Hg_game_continue);
		text_message := find_text_using_last_path;
	end

feature {NONE} -- Implementation

end
