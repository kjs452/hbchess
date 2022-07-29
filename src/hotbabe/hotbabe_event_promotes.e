indexing
	description:	"pawn promotion"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

class HOTBABE_EVENT_PROMOTES
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
		Result := 10;
	end

feature {NONE} -- Implementation
	hotbabe_group_id: INTEGER is
	once
		Result := Hg_hotbabe_promotes;
	end

	player_group_id: INTEGER is
	once
		Result := Hg_player_promotes;
	end
end
