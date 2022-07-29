indexing
	description:	"chat menu ID constants"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

class CHESS_SHORTCUT_CONSTANTS

feature {NONE} -- Access
	Shortcut_new_game: INTEGER is unique;
	Shortcut_save_game: INTEGER is unique;
	Shortcut_load_game: INTEGER is unique;
	Shortcut_resign: INTEGER is unique;

	Shortcut_hint: INTEGER is unique;
	Shortcut_undo_move: INTEGER is unique;

	Shortcut_change_nickname: INTEGER is unique;
	Shortcut_game_properties: INTEGER is unique;

	Shortcut_about: INTEGER is unique;
	Shortcut_help: INTEGER is unique;

feature -- Status Report
	valid_shortcut(s: INTEGER): BOOLEAN is
	do
		Result := (s >= Shortcut_new_game) and (s <= Shortcut_help);
	end

end
