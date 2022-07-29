indexing
	description:	"a substring of a CHAT_SENTENCE to be displayed%
			% in the CHAT_OUTPUT window"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

class CHESS_GUI_CHAT_PHRASE

creation
	make_normal, make_bold, make_link

feature -- Initialization
	make_normal(txt: STRING) is
		-- this text is displayed in using a normal font
	require
		txt /= Void;
	do
		is_normal := True;
		!! text.make_from_string(txt);
		link_data := Void;
	end

	make_bold(txt: STRING) is
		-- this text is displayed in using a bold font
	require
		txt /= Void;
	do
		is_bold := True;
		!! text.make_from_string(txt);
		link_data := Void;
	end

	make_link(txt: STRING; a_link_data: CHESS_GUI_CHAT_LINK) is
		-- a link phrase appears like a click-able URL link in
		-- the chat output window. When the user clicks on a link
		-- we will return link_data to the application for
		-- further processing.
	require
		txt /= Void;
		a_link_data /= Void;
	do
		is_link := True;
		!! text.make_from_string(txt);
		link_data := a_link_data;
	end

feature -- Access
	text: STRING;
	link_data: CHESS_GUI_CHAT_LINK;

feature -- Status Report
	is_normal: BOOLEAN;
	is_bold: BOOLEAN;
	is_link: BOOLEAN;

invariant
	(is_normal) or (is_bold) or (is_link);
	(is_link) implies (link_data /= Void);
end
