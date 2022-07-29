indexing
	description:	"event for default actions"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

--
-- This event is triggered when the HOTBABE event queue is
-- empty and the client requests video/text.
--
-- If the queue is empty, then we shove one of these
-- events into the queue.
--

class HOTBABE_EVENT_DEFAULT
inherit
	HOTBABE_EVENT

creation
	make

feature -- Initialization
	make is
	do
	end

feature -- Access
feature -- Status Report
feature -- Status Setting
feature -- Element Change
feature -- Removal

feature -- Processing
	think is
	do
		if hotbabe_showing then
			general_behavior;
		else
			video_clip := find_clip(Hg_nogame);
			text_message := Void;
		end
	end

feature {NONE} -- Implementation
	general_behavior is
		-- behavior based on how well hotbabe is playing
		-- the game. There are 4 levels:
		--	hotbabe_winning2:
		--		hotbabe is up a queen
		--
		--	hotbabe_winning1:
		--		hotbabe up a rook
		--
		--	player_winning1:
		--		player is up a rook
		--
		--	player_winning2:
		--		player is up a queen
		--
	do
		if score >= Queen_value then
			video_clip := find_clip(Hg_hotbabe_winning2);
			text_message := find_text_using_last_path;

		elseif score >= Rook_value then
			video_clip := find_clip(Hg_hotbabe_winning1);
			text_message := find_text_using_last_path;

		elseif score <= -Queen_value then
			video_clip := find_clip(Hg_player_winning2);
			text_message := find_text_using_last_path;

		elseif score <= -Rook_value then
			video_clip := find_clip(Hg_player_winning1);
			text_message := find_text_using_last_path;

		else
			video_clip := find_clip(Hg_general_behavior);
			text_message := find_text_using_last_path;
		end
	end

	Queen_value: INTEGER is 900;
	Rook_value: INTEGER is 500;
end
