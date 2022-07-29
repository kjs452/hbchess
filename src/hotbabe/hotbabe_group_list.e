indexing
	description:	"a list of group_info objects"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

--
-- This list is implemented as an array, so we can quickly
-- map a group_id into a string, so we can fetch the appropriate data
-- from the data base.
--
class HOTBABE_GROUP_LIST
inherit
	ARRAY[ HOTBABE_GROUP_INFO ]
	rename
		make as array_make,
		item as array_item,
		put as array_put
	export
		{NONE} all
	undefine
		is_equal, copy
	end

	HOTBABE_GROUP_CONSTANTS

creation
	make

feature -- Initialization
	make is
	do
		array_make(Hg_lower+1, Hg_upper-1);
		cursor := lower;
	end

feature -- Access
	item: HOTBABE_GROUP_INFO is
		-- item located at cursor position
	require
		not off;
	do
		Result := array_item(cursor);
	end

	name(group_id: INTEGER): STRING is
		-- given a group_id, return the group_name..
	require
		valid_hotbabe_group_id(group_id);
	do
		Result := array_item(group_id).group_name;
	ensure
		Result /= Void;
	end

feature -- cursor movement
	start is
		-- set cursor to beginning of array
	do
		cursor := lower;
	end

	forth is
		-- go to the next item in the array
	require
		not off;
	do
		cursor := cursor + 1;
	end

feature -- Status Report
	off: BOOLEAN is
		-- is cursor outside of array bounds?
	do
		Result := (cursor > upper);
	end

	is_filled: BOOLEAN is
		-- are all elements of array set?
	do
		from
			Result := True;
			start;
		until
			off or not Result
		loop
			if item = Void then
				Result := False;
			end
			forth;
		end
	end

feature -- Status Setting

feature -- Element Change
	put(group_id: INTEGER; group_name: STRING;
			requires_text, requires_clips: BOOLEAN) is
	require
		valid_hotbabe_group_id(group_id);
		group_name /= Void;
	local
		gi: HOTBABE_GROUP_INFO;
	do
		!! gi.make(group_id, group_name, requires_text, requires_clips);

		array_put(gi, group_id);
	end

feature -- Removal

feature {NONE} -- Implementation
	cursor: INTEGER;

end

