indexing
	description:	"behavior when user undo's a move"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

--
-- This event will trigger hotbabe to say/do something
-- special when the user undo's a move..
--
class HOTBABE_EVENT_UNDO_TAUNT
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
		Result := 4;
	end

feature -- Status Report
feature -- Status Setting
feature -- Element Change
feature -- Removal

feature -- Processing
	think is
	do
		video_clip := find_clip(Hg_undo_taunt);
		text_message := find_text_using_last_path;
	end

feature {NONE} -- Implementation

end
