indexing
	description:	"an event that controls hotbabe's behavior"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

--
-- This is the parent class for all the possible HOTBABE events.
--
-- These events are sent to the HOTBABE class so that we can
-- generate appropriate video clips, and chat messages.
--
-- Events all have a 'thinking' routine which uses
-- some algorithm to fetch a video clip and chat message.
--
-- Most events simply fetch a video clip based on a predefined
-- group_id. Other events have a slightly more complicated
-- logic.
--
-- Class heirarchy:
-- HOTBABE_EVENT*		priority=1, repeatable=True
-- 	--
-- 	-- direct messages
-- 	--
-- 	HOTBABE_EVENT_ABOUT			priority=1
-- 	HOTBABE_EVENT_CHANGE_NICKNAME		priority=1
-- 	HOTBABE_EVENT_HINT_AFTER		priority=1
-- 	HOTBABE_EVENT_HINT_BEFORE		priority=1
-- 	HOTBABE_EVENT_LOAD			priority=1
-- 	HOTBABE_EVENT_LOAD_ERROR		priority=1
-- 	HOTBABE_EVENT_RESIGN_CONFIRM		priority=1
-- 	HOTBABE_EVENT_SAVE			priority=1
-- 	HOTBABE_EVENT_SAVE_ERROR		priority=1
-- 	HOTBABE_EVENT_START			priority=1
-- 	HOTBABE_EVENT_STATISTICS		priority=1
-- 	HOTBABE_EVENT_HELP			priority=1
-- 
-- 	--
-- 	-- misc. events
-- 	--
-- 	HOTBABE_EVENT_CREDITS			priority=1, repeatable=false
-- 	HOTBABE_EVENT_EASTER_EGG		priority=1 repeatable=false
--
-- 	HOTBABE_EVENT_RESIGN_TAUNT		priority=4, repeatable=false
-- 	HOTBABE_EVENT_UNDO_TAUNT		priority=4, repeatable=false
-- 	HOTBABE_EVENT_NICKNAME_TAUNT		priority=4, repeatable=false
-- 	HOTBABE_EVENT_WEBCAM_CHANGED		priority=5, repeatable=false
-- 	HOTBABE_EVENT_FLIP_BOARD		priority=5, repeatable=false
-- 
-- 	--
-- 	-- game begin/end events
-- 	--
-- 	HOTBABE_EVENT_SITDOWN			priority=1
-- 	HOTBABE_EVENT_GAME_START		priority=1
-- 	HOTBABE_EVENT_GAME_END			priority=1
-- 	HOTBABE_EVENT_STANDUP			priority=1
-- 
-- 	--
-- 	-- game over events
-- 	--
-- 	HOTBABE_EVENT_PLAYER_RESIGNS		priority=1
-- 	HOTBABE_EVENT_HOTBABE_WINS		priority=1
-- 	HOTBABE_EVENT_PLAYER_WINS		priority=1
-- 	HOTBABE_EVENT_STALE_MATE		priority=1
-- 	HOTBABE_EVENT_DRAW			priority=1
-- 
-- 	HOTBABE_EVENT_MOVE*			repeatable=false
-- 		HOTBABE_EVENT_PROMOTES		priority=10
-- 		HOTBABE_EVENT_CAPTURES_QUEEN	priority=20
-- 		HOTBABE_EVENT_CAPTURES_ROOK	priority=30
-- 		HOTBABE_EVENT_EP_CAPTURES	priority=40
-- 		HOTBABE_EVENT_CAPTURES_BISHOP	priority=60
-- 		HOTBABE_EVENT_CAPTURES_KNIGHT	priority=70
-- 		HOTBABE_EVENT_CASTLES		priority=80
-- 		HOTBABE_EVENT_CAPTURES_PAWN	priority=90
-- 		HOTBABE_EVENT_IN_CHECK		priority=95
-- 		HOTBABE_EVENT_NORMAL		priority=99/100, repeatable=true
--						(hotbabe=100, player=99)
-- 
-- 	HOTBABE_EVENT_THINKING			priority=101
--						(when thinking a hint)
-- 
-- 	HOTBABE_EVENT_DEFAULT			priority=1
-- 						(only runs when queue is empty)
-- 
--
-- When an event is removed from the queue, we
-- examine the message:
--	1. obtain a video clip (always done) to play
--	2. retrieve a random message (depending on probability)
--
-- PRIORITY ALGORITHM:
-- Every event has a 'priority' attribute. When we add
-- an event to the queue, all pending events with a priority
-- less than the event being added to the queue, will be pruned.
--
-- REPEATABLE ALGORITHM:
-- Events that we don't want to repeat (like CREDITS, etc...)
-- will have their 'repeatable' attribute set to False.
--
-- Before adding such events, we check to see that
-- this event is not already in the queue (or currently
-- being played). If we detect a similar event, then
-- we don't add it again.
--
--

deferred class HOTBABE_EVENT
inherit
	ANY
	redefine
		is_equal
	end

	HOTBABE_GROUP_CONSTANTS
	undefine
		is_equal
	end

feature -- Initialization

feature -- Access
	repeatable: BOOLEAN is
		-- can this event be added multiple times to the queue?
	once
		Result := True;
	end

	priority: INTEGER is
		-- when adding an event to the queue, we
		-- will prune all pending events in the queue that
		-- have a priority LESS than this value
		-- (The maximum priority is 1)
	once
		Result := 1;
	ensure
		Result >= 1;
	end

	text_message: HOTBABE_TEXT;
		-- after "thinking" this will be set, if
		-- a text message is to be displayed in chat window

	video_clip: HOTBABE_CLIP;
		-- after "thinking" this will be set to a
		-- video clip to play. Not all event types
		-- have a video clip associated with them.

feature -- Status Report
	is_equal(other: HOTBABE_EVENT): BOOLEAN is
		-- For our purposes inside of the queue, we
		-- want to define equality as events that
		-- have the same_type. This is used when
		-- we try to implement the 'repeatable' logic
	do
		Result := same_type(other);
	end

feature -- Status Setting
	set_hotbabe_showing(yes: BOOLEAN) is
	do
		hotbabe_showing := yes;
	end

	set_score(a_score: INTEGER) is
	do
		score := a_score;
	end

	set_db(a_db: HOTBABE_DB) is
	require
		a_db /= Void;
	do
		db := a_db;
	end

feature -- Element Change
feature -- Removal

feature -- Processing
	think is
		-- process this event-type and produce
		-- a random video clip and random text
		-- message
	deferred
	end

feature {NONE} -- Implementation
	db: HOTBABE_DB;
	hotbabe_showing: BOOLEAN;
	score: INTEGER;

	find_text(group_id: INTEGER): HOTBABE_TEXT is
		-- find text using group id, a valid
		-- text message must be returned
		--
		-- The client needs to make sure the
		-- 'group_id' has text data.
		--
	require
		valid_hotbabe_group_id(group_id);
	local
		group_name: STRING;
	do
		group_name := group_list.name(group_id);
		Result := db.find_text(group_name);
	ensure
		Result /= Void;
	end

	find_text_using_last_path: HOTBABE_TEXT is
		-- find text using the last search path
		-- This may fail to find a text message, so
		-- we return Void in that case.
		--
		-- If the text message is_empty, then
		-- we return Void.
		--
		-- Empty can be encoded in the .dat file
		-- by using this construct:
		--
		--	[SAY_NOTHING]
		--	T ~
		--
		-- This is a text record, that is empty.
		--
	do
		Result := db.find_text_using_last_path;
		if Result /= Void and then Result.is_empty then
			Result := Void;
		end
	end

	find_clip(group_id: INTEGER): HOTBABE_CLIP is
		-- find a clip using the group_id
		-- a valid result must be found
		--
		-- The client needs to make sure that
		-- the 'group_id' contains video clips.
		--
	require
		valid_hotbabe_group_id(group_id);
	local
		group_name: STRING;
	do
		group_name := group_list.name(group_id);
		Result := db.find_clip(group_name);
	ensure
		Result /= Void;
	end

end
