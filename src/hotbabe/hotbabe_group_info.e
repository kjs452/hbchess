indexing
	description:	"information about a predefined group"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

class HOTBABE_GROUP_INFO
inherit
	HOTBABE_GROUP_CONSTANTS

creation
	make

feature -- Initialization
	make(id: INTEGER; name: STRING; text, clips: BOOLEAN) is
		-- create a new group_info structure.
	require
		valid_hotbabe_group_id(id);
		name /= Void;
		name.count > 0;
		name.item(1) /= '@';
		text or clips;
	do
		group_id := id;

		--
		-- append '@' sign, and uppercase
		--
		!! group_name.make_from_string(name)
		group_name.to_upper;
		group_name.prepend_character('@');

		requires_text := text;
		requires_clips := clips;
	end

feature -- Access
	group_id: INTEGER;
	group_name: STRING;

	requires_text: BOOLEAN;
		-- this group must have some text records

	requires_clips: BOOLEAN;
		-- this group must have some video clip records

feature -- Status Report
	exists(db: HOTBABE_DB): BOOLEAN is
		-- Does this predefined group exist in the
		-- database?
	require
		db /= Void;
	local
		grp: HOTBABE_DB_GROUP;
	do
		grp := db.find_group(group_name);
		Result := (grp /= Void);
	end

	has_required_text(db: HOTBABE_DB): BOOLEAN is
		-- Does the pre-defined group contain text messages?
		-- (assuming we require them)
	require
		db /= Void;
		exists(db);
	local
		grp: HOTBABE_DB_GROUP;
	do
		Result := True;

		if requires_text then
			grp := db.find_group(group_name);
			if not grp.has_text then
				Result := False;
			end
		end
	end

	has_required_clips(db: HOTBABE_DB): BOOLEAN is
		-- Does the pre-defined group contain video clips?
		-- (assuming we require them)
	require
		db /= Void;
		exists(db);
	local
		grp: HOTBABE_DB_GROUP;
	do
		Result := True;
		if requires_clips then
			grp := db.find_group(group_name);
			if not grp.has_clips then
				Result := False;
			end
		end
	end

end
