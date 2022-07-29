indexing
	description:	"stores a link and its location in CHESS_GUI_CHAT_OUTPUT"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

class CHESS_GUI_CHAT_LINKDB_ITEM

creation
	make

feature -- Initialization
	make(spos, epos: INTEGER; a_link_data: CHESS_GUI_CHAT_LINK) is
	require
		a_link_data /= Void;
	do
		start_position := spos;
		end_position := epos;
		link_data := a_link_data;
	end

feature -- Access
	start_position: INTEGER;
	end_position: INTEGER;
	link_data: CHESS_GUI_CHAT_LINK;

end
