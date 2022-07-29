indexing
	description:	"a normal move"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

--
-- Hotbabe move has a priority of 100
-- Player move has a priority of 99.
--
class HOTBABE_EVENT_NORMAL
inherit
	HOTBABE_EVENT_MOVE
	redefine
		make, priority, repeatable
	end

creation
	make

feature -- Initialization
	make(is_hb_move: BOOLEAN) is
	do
		Precursor(is_hb_move);
		if is_hb_move then
			priority := 100;
		else
			priority := 99;
		end
	end

feature -- Access
	repeatable: BOOLEAN is
	once
		Result := True;
	end

	priority: INTEGER;

feature {NONE} -- Implementation
	hotbabe_group_id: INTEGER is
	once
		Result := Hg_hotbabe_moves;
	end

	player_group_id: INTEGER is
	once
		Result := Hg_player_moves;
	end
end
