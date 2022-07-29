indexing
	description:	"describes the sequence of groups and sub-groups%
		% that was used to locate a record in the database"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

--
-- When searching for a video clip, we want to know
-- in which group the video clip was found so that we
-- may go back to that group and obtain a related text message
--
-- If no text message exists, we will repeat the search higher up in
-- the sequence, until we find a text message.
--
-- This allows us to select text messages that makes the
-- most sense for the video clip we are playing.
--

class HOTBABE_DB_SEARCH_PATH
inherit
	LINKED_LIST[ STRING ]
	rename
		make as list_make
	end

creation
	make

feature -- Initialization
	make is
	do
		list_make;
	end

feature -- Access
feature -- Status Report
feature -- Status Setting
feature -- Element Change
feature -- Removal
feature {NONE} -- Implementation

end
