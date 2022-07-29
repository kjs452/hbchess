indexing
	description:	"this is a WEL_COMMAND we attach to the track bar"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

--
-- The track bar that is on the new game dialog, needs to update
-- some information when the track bar is moved. This command
-- is added to the track bar control, and will
-- allow us to update the dialog..
--
class NEW_GAME_MOVED_COMMAND
inherit
	WEL_COMMAND

creation
	make

feature
	make is
	do
	end

	execute(a_parent: NEW_GAME_DIALOG) is
	do
		a_parent.update_details;
	end

end
