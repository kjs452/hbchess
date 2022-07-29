indexing
	description:	"behavior when user turns webcam on/off"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

class HOTBABE_EVENT_WEBCAM_CHANGED
inherit
	HOTBABE_EVENT
	redefine
		repeatable, priority
	end

creation
	make

feature -- Initialization
	make(webcam_on: BOOLEAN) is
	do
		is_webcam_on := webcam_on;
	end

feature -- Access
	repeatable: BOOLEAN is
	once
		Result := False;
	end

	priority: INTEGER is
	once
		Result := 5;
	end

feature -- Status Report
feature -- Status Setting
feature -- Element Change
feature -- Removal

feature -- Processing
	think is
	do
		if hotbabe_showing then
			webcam_changed_behavior;
		else
			video_clip := find_clip(Hg_nogame);
			text_message := Void;
		end
	end

feature {NONE} -- Implementation
	is_webcam_on: BOOLEAN;

	webcam_changed_behavior is
	do
		if is_webcam_on then
			video_clip := find_clip(Hg_webcam_on);
		else
			video_clip := find_clip(Hg_webcam_off);
		end

		text_message := find_text_using_last_path;
	end

end
