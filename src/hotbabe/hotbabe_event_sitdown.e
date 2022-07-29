indexing
	description:	"event to cause hotbabe to sitdown"

class HOTBABE_EVENT_SITDOWN
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
		video_clip := find_clip(Hg_sitdown);
		text_message := find_text_using_last_path;
	end

feature {NONE} -- Implementation

end
