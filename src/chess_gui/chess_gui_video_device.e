indexing
	description:	"subtype of WEX_MCI_DIGITAL_VIDEO"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

class CHESS_GUI_VIDEO_DEVICE
inherit
	WEX_MCI_DIGITAL_VIDEO
	export
		{ANY} play_device
	end

creation
	make

feature -- Initialization
feature -- Access
feature -- Status Report
feature -- Status Setting
feature -- Element Change
feature -- Removal
feature {NONE} -- Implementation

end
