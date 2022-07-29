indexing
	description:	"chess file load dialog"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

class CHESS_LOAD_DIALOG
inherit
	WEL_OPEN_FILE_DIALOG
	rename
		make as make_dlg
	end

creation
	make

feature -- Initialization
	make is
	do
		make_dlg;
		set_title("Load Chess Game");
		set_filter(
			<<"Chess Game (*.txt)", "All files">>,
			<<"*.txt", "*.*">>
		);
		set_default_extension("txt");
	end

feature -- Access
feature -- Status Report
feature -- Status Setting
feature -- Element Change
feature -- Removal
feature {NONE} -- Implementation

end
