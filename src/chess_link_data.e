indexing
	description:	"link data that stores an identifier"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

--
-- The chat window lets the user click on pretend links. Each pretend
-- link has a CHESS_GUI_CHAT_LINK object associated with it. The
-- version of that class has the identifier and a URL.
--
-- T Click <here|START_MENU> to begin hotbabe chess.
--
-- The above TEXT record (in the .dat file) has
-- an embedded link, the CHESS_LINK_DATA object would be
-- set as follows:
--
--	url = "here"
--	identifier = "START_MENU"
--
class CHESS_LINK_DATA
inherit
	CHESS_GUI_CHAT_LINK

creation
	make, make_no_ident

feature -- Initialization
	make(ident: STRING; a_url: STRING) is
	require
		ident /= Void;
		a_url /= Void;
	do
		identifier := ident;
		url := a_url;
	end

	make_no_ident(a_url: STRING) is
	require
		a_url /= Void;
	do
		identifier := Void;
		url := a_url;
	end

feature -- Access
	identifier: STRING;
	url: STRING;

end
