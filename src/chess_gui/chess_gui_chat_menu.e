indexing
	description:	"chat command menu"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

class CHESS_GUI_CHAT_MENU
inherit
	WEL_MENU
	rename
		make as wel_make
	export
		{NONE} make_track, make_by_name, make_by_id, wel_make
	end

	CHESS_SHORTCUT_CONSTANTS

creation
	make

feature -- Initialization
	make is
	do
		make_track;
		build_menu_items;
	end

feature -- Access
feature -- Status Report
feature -- Status Setting
feature -- Element Change
feature -- Removal

feature {NONE} -- Implementation
	build_menu_items is
	do
		Current.append_string("New game", Shortcut_new_game);
		Current.append_string("Load game", Shortcut_load_game);
		Current.append_string("Save game", Shortcut_save_game);
		Current.append_separator;

		Current.append_string("Hint", Shortcut_hint);
		Current.append_string("Undo move", Shortcut_undo_move);
		Current.append_string("Resign", Shortcut_resign);
		Current.append_separator;

		Current.append_string("Change nickname", Shortcut_change_nickname);
		Current.append_string("Game statistics", Shortcut_game_properties);
		Current.append_separator;

		Current.append_string("About", Shortcut_about);
		Current.append_string("Help", Shortcut_help);
	end
end
