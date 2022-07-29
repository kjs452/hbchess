indexing
	description:	"error message to display when user loads a game"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

class HOTBABE_EVENT_LOAD_ERROR
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
		text_message := find_text(Hg_load_error);
	end

end
