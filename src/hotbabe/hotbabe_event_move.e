indexing
	description:	"event for when somebody moves a piece"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

--
-- Types of moves we care about:
--
--	HOTBABE MOVING:
--	regular move (non-capture)
--		if opponent_in_check, alway use the PLAYER_IN_CHECK group
--
--	capture queen
--		group, HOTBABE_CAPTURES_QUEEN
--
--	capture rook
--	capture bishop
--	capture knight
--	capture pawn
--	capture pawn (ep)
--	castling
--	pawn promotion
--
--	PLAYER MOVING:
--	regular move (non-capture)
--	capture queen
--	capture rook
--	capture bishop
--	capture knight
--	capture pawn
--	capture pawn (ep)
--	castling
--	pawn promotion
--
--
--	We also care about being in check or not
--
--
deferred class HOTBABE_EVENT_MOVE
inherit
	HOTBABE_EVENT
	redefine
		repeatable
	end

feature -- Initialization
	make(is_hb_move: BOOLEAN) is
	do
		is_hotbabe_move := is_hb_move;
	end

feature -- Access
	repeatable: BOOLEAN is
	once
		Result := False;
	end

feature -- Status Report
feature -- Status Setting
feature -- Element Change
feature -- Removal

feature -- Processing
	think is
	do
		check
			-- because we are only making
			-- moves when a game is in progress
			hotbabe_showing;
		end

		if is_hotbabe_move then
			video_clip := find_clip(hotbabe_group_id);
		else
			video_clip := find_clip(player_group_id);
		end

		text_message := find_text_using_last_path;
	end

feature {NONE} -- Implementation
	is_hotbabe_move: BOOLEAN;

	hotbabe_group_id: INTEGER is
	deferred
	ensure
		valid_hotbabe_group_id(Result);
	end

	player_group_id: INTEGER is
	deferred
	ensure
		valid_hotbabe_group_id(Result);
	end

end
