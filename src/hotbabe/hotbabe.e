indexing
	description:	"logic for HOTBABE video and chat messages"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"


--
-- This is the top level class for the HOTBABE cluster.
--
-- This class is responsible for all the behavior of the "hotbabe"
-- character. She will perform video actions and type text messages
-- all obtained thru this class.
--
-- Our clients interface with this class in order
-- to simulate the HOTBABE behavior. This class is responsible for:
--
--	- picking random video clips to play
--	- picking random chat messages to display
--	- responding to special HOTBABE_EVENT's to customize
--	  the video/chatter according to events that happen during
--	  the chess game
--
--	- reads the hotbabe_chess.dat file and store the data into
--	   a large internal data structure.
--
-- This class manages the hotbabe chat/video clip behavior.
-- This class reads the "hotbabe_chess.dat" file to build
-- a database of chat messages and video clips.
--
-- These chat messages and video clips are organized into groups.
--
-- This class maintain a queue of HOTBABE_EVENT's that
-- the client can add to (see feature 'add_event')
--
-- When the previous video clip has finished, we request a
-- new video clip (see feature 'next_video_clip'). We also
-- request a new chat messages (see feature 'next_chat_message').
--
-- Internally we dequeue the next HOTBABE_EVENT and select an appropriate
-- video clip to play (we get to chose a random clip from a set of
-- similar related video clips).
--
-- If the queue is empty we select a general non-specific video clip
-- and text message.
--
-- Occasionally the client will want a chat message without having to
-- submit a HOTBABE_EVENT into the event queue. To obtain a direct
-- chat message we use the feature 'direct_message'
--
-- We will also know if we are currently losing or winning, and we
-- will also know what part of the game we are in (middle-game, end-game, beginning)
--
-- This class has no concept of time, it assumes that we are called
-- every 5-10 seconds. Most video clips will fall into this duration, so
-- the client will call us whenever a new video clip is needed.
--
-- When the webcam is turned off, we do not give the client any
-- video clip, but we will still produce chat messages.
--
-- When the webcam is off, the client must use a timer to call us
-- every 5-10 seconds, in order to continue to produce chat messages.
--
-- EVENT QUEUE:
-- The event queue is critical to making hotbabe respond to
-- events that happen in the game. Examples of events are:
--	player captures a piece
--	player moves a piece
--	hotbabe beats player
--	stale-mate occurs, game over
--	new game, hotbabe sits down and introduces herself
--	etc...
--
-- These events go into the queue, and when we request the next
-- video clip and chat message, we remove the next element from the
-- queue and give a appropriate video clip/message to the client.
--
-- When the queue is empty, that means there are no special events
-- pending, so we just pick a random clip that doesn't relate to
-- any event. These clips are just general and allow us to always
-- have hotbabe doing/saying something.
--
-- DIRECT MESSAGES
-- In some situations the client will want a specific type of
-- chat message without using the queue. This happens:
--	* When user asks for a HINT
--	* User chooses to resign.
--	* Game properties
--	* Help
--	* About
--
-- STRING SUBSTITUTION's
-- Some strings have $ variable in them, the
-- client will have to handle these themselves
--
-- FAKE WEB URL's:
-- Our chat window allows "fake" URL's to be displayed.
-- By convention any text surrounded by angled brackets will
-- be converted into a fake URL. For example:
--
-- "Hey! Check out my profile: <http://www.hotbabe_profile.com|PROFILE>"
-- "See me and my friends at, <http://www.sexy_hotbabe_and_her_posse.com|FRIENDS>"
--
-- In the chat window this will be displayed in blue-underline. The
-- vertical bar character seperates the URL from the access string.
--
-- The access string can be anything, it allows our program to
-- do something special.
--
-- This class ignores all URL's, it is up to the client to
-- interpret and handle this format.
--
-- NOTE: This program doesn't do anything on the internet, including
-- displaying web pages. These are fake URL's, used to make
-- the game look more realistic.
--
--

class HOTBABE
inherit
	LINKED_QUEUE[ HOTBABE_EVENT ]
	rename
		make as make_queue,
		forth as forth_queue
	export
		{NONE} all
		{ANY} has
	undefine
		is_equal, copy
	end

	HOTBABE_GROUP_CONSTANTS

creation
	make

feature -- Initialization
	make(filename: STRING) is
		-- read configuration file and
		-- setup hotbabe behavior
	require
		filename /= Void;
	do
		make_queue;
		compare_objects;
		current_event := Void;

		!! db.make(filename);
		if db.failed then
			failed := True;
			error_message := db.error_message;
		end

		if not failed then
			check_predefined_groups;
		end
	end

	failed: BOOLEAN;
		-- will be set to True in the event that
		-- we cannot parse/read the config file, or
		-- some other error happens during
		-- initialization.

	error_message: STRING;
		-- If we cannot read the configuration file, or some
		-- other error happens during initialization, then
		-- this will be set to an error message, otherwise
		-- this will be set Void.

feature -- Access
	video_clip: HOTBABE_CLIP;
		-- after calling 'forth' this will be set
		-- to a new video clip.
		--
		-- return a new random video clip,
		-- if an event is on the queue, then
		-- return a video clip that is approprite
		-- for that type of event.

	text_message: HOTBABE_TEXT;
		-- return a random text message. If there
		-- is an event in the queue, then return
		-- a message that is appropriate for that
		-- type of event.
		--
		-- Sometimes we don't generate any message.
		-- About 1 out of 5 calls produce a messages.
		-- certain events ALWAYS produce a message.
		-- (The message rate we are trying to achieve is:
		--		2 messages per minute)
		--
		-- If there are variables in the message
		-- they will be substituted.
		--
		-- If there are positional variable in
		-- the message, then the substitutions
		-- will be obtained from the event data.
		--

feature -- Status Report
	nickname: STRING is
		-- Hotbabe's nickname (obtained from .dat file)
		-- Will most likely be 'hotbabe'
	do
		Result := db.nickname;
	ensure
		nickname /= Void;
	end

	debug_mode: BOOLEAN is
		--
		-- Was debug mode specified
		-- in the hotbabe_chess.dat file?
		--
	do
		Result := db.debug_mode;
	end

	showing: BOOLEAN;
	score: INTEGER;

feature -- Status Setting
	set_showing(yes: BOOLEAN) is
		-- Is hotbabe visible or not?
		-- Establish if game is in progress or
		-- not. If no game is running, then hotbabe
		-- will not be visible in the webcam, instead
		-- the user will just see an empty scene.
		-- Only when the game begins will hotbabe
		-- appear.
	do
		showing := yes;
	end

	set_score(a_score: INTEGER) is
		-- Score is a computation of the current chess game
		-- A negative number implies hotbabe is losing.
		-- A positive number implies hotbabe is winning
		-- 0 implies the game is equal
		-- Allows hotbabe to customize messages if she
		-- is winning or losing the game
	do
		score := a_score;
	end

feature -- Element Change
	direct_message(event: HOTBABE_EVENT) is
		-- evaluate event without using the queue
		-- used to obtain direct, immediate messages
	do
		event.set_hotbabe_showing(showing);
		event.set_score(score);
		event.set_db(db);
		event.think;
		video_clip := event.video_clip;
		text_message := event.text_message;
	end

	add_event(event: HOTBABE_EVENT) is
		-- add 'event' to the event queue
	require
		event /= Void;
	do
		if can_add_event(event) then
			prune_lower_priority_events(event.priority);
			--
			-- set the current context into the
			-- event structure
			--
			event.set_hotbabe_showing(showing);
			event.set_score(score);
			event.set_db(db);
			put(event);
		end
	end

feature -- Removal
	forth is
		-- process the next event, or perform
		-- the default actions
		-- select the next random video clip and text message
		-- if queue has an event, use that to control
		-- what clip to play.
	local
		e: HOTBABE_EVENT;
	do
		-- if queue is empty, add a "default" event to
		-- be processed.
		if count = 0 then
			!HOTBABE_EVENT_DEFAULT! e.make;
			add_event(e);
		end

		current_event := item;
		remove;

		--
		-- process 'event'
		--
		current_event.think;
		video_clip := current_event.video_clip;
		text_message := current_event.text_message;
	end

feature {NONE} -- Implementation (routines)

	can_add_event(e: HOTBABE_EVENT): BOOLEAN is
		-- this implements the repeatable algorithm.
		-- Check to see if the event 'e' is in the queue
		-- or currently being played.
		--
		-- Events flagged as 'repeatable' will always be added
		-- to the queue.
	do
		if e.repeatable then
			--
			-- we always add events that are 'repeatable'
			--
			Result := True;
		else
			if has(e) then
				--
				-- queue already has event same type as 'e'
				-- (don't add)
				--
				Result := False;

			elseif current_event /= Void
					and then e.is_equal(current_event) then
				--
				-- The current event is the same type as 'e'
				-- (don't add)
				--
				Result := False;

			else
				--
				-- No event with same type as 'e' was found
				-- (we can add this event)
				--
				Result := True;

			end
		end
	end

	prune_lower_priority_events(priority: INTEGER) is
		-- go thru queue, removing any events
		-- that have a lower priority than 'priority'
		-- (NOTE: 1=highest priority)
		--
	require
		priority >= 1;
	do
		from
			start;
		until
			off
		loop
			if ll_item.priority > priority then
				ll_remove;
			end
			if not off then
				forth_queue;
			end
		end
	end

	check_predefined_groups is
		-- verify all predefined groups exist
		-- Set 'error_message' to indicate the problem
	require
		not failed;
	local
		gi: HOTBABE_GROUP_INFO;
	do
		from
			group_list.start;
		until
			group_list.off or failed
		loop
			gi := group_list.item;

			if not gi.exists(db) then
				failed := True;
				error_message := "Pre-defined group '"
					+ gi.group_name
					+ "' does not exist";

			elseif not gi.has_required_text(db) then
				failed := True;
				error_message := "Pre-defined group '"
					+ gi.group_name
					+ "' missing required text";

			elseif not gi.has_required_clips(db) then
				failed := True;
				error_message := "Pre-defined group '"
					+ gi.group_name
					+ "' missing required clips";

			end

			group_list.forth;
		end

	ensure
		failed implies error_message /= Void;
	end

feature {NONE} -- Implementation (attributes)
	db: HOTBABE_DB;
	current_event: HOTBABE_EVENT;

end
