indexing
	description:	"message for when user changes his nickname"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

class HOTBABE_EVENT_CHANGE_NICKNAME
inherit
	HOTBABE_EVENT

creation
	make

feature -- Initialization
	make is
	do
	end

feature -- Access
feature -- Processing
	think is
	do
		text_message := find_text(Hg_change_nickname);
	end

end
