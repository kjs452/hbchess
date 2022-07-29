indexing
	description:	"represents the many states the chess application can%
			% be in at any given time."
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

class CHESS_APP_STATE_CONSTANTS

feature {NONE} -- States
	App_state_nogame:	INTEGER is unique;
	App_state_idle:		INTEGER is unique;
	App_state_thinking:	INTEGER is unique;
	App_state_hint:		INTEGER is unique;
	App_state_gameover:	INTEGER is unique;

feature -- Status Report
	valid_app_state(s: INTEGER): BOOLEAN is
	do
		Result := (s >= App_state_nogame) and (s <= App_state_gameover);
	end

end
