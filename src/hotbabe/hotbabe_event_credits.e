indexing
	description:	"show credits for program"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

--
-- this event isn't repeatable, which means
-- the user cannot overload the queue with about requests.
--
class HOTBABE_EVENT_CREDITS
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
		video_clip := find_clip(Hg_credits);
		text_message := find_text_using_last_path;
	end

feature {NONE} -- Implementation

end
