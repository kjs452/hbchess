indexing
	description:	"a move that captures a knight"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

class HOTBABE_EVENT_CAPTURES_KNIGHT
inherit
	HOTBABE_EVENT_MOVE
	redefine
		priority
	end

creation
	make

feature -- Access
	priority: INTEGER is
	once
		Result := 70;
	end

feature {NONE} -- Implementation
	hotbabe_group_id: INTEGER is
	once
		Result := Hg_hotbabe_captures_knight;
	end

	player_group_id: INTEGER is
	once
		Result := Hg_player_captures_knight;
	end
end
