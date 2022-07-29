indexing
	description:	"a group of related hotbabe data records"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

--
-- This class represents a group of records from
-- the hotbabe_chess.dat file.
--
-- We divide the data for a group into text data and
-- clip data. The subgroups are split into subgroups containing
-- text and video clips. If a sub-group has both, then it
-- will be added to both 'text_groups' and 'clip_groups'
--
-- FIND ALGORITHM:
--	For finding a text/clip datum, we use a random algorithm
--	If there are 10 text records and 5 sub-groups containing
--	text, then we do the following:
--
--	1. Pick a random number between 1 and 15.
--	2. If random number is between 1 and 10, then we
--	   choose that text record from the list 'text_records'
--	3. If the random number is between 11 and 15, then
--	   recursively follow the subgroup found in the list
--	   'text_groups'.
--
--	This algorithm continues recursively until a HOTBABE_TEXT
--	object is obtained.
--
--	This algorithm gives equal probability for following a sub-group
--	or picking a data record.
--
-- The algorithm for video clips is the same.
--
-- For text records, we do one additional step, we scan the
-- the text record for embedded group references and replace them.
-- For example,
--	"Would you like to play an [AWSOME] game of chess?"
--
-- In this case AWSOME is a sub-group that contains text, so
-- we use a similar algorithm to fetch some random text from
-- this subgroup.
--
-- (We already know that such embedded groups will have text)
--
-- We also maintain the 'last_search_path', so that when we
-- do eventually get a data record, we have a list of groups
-- and sub-groups that were used to reach the data.
--

class HOTBABE_DB_GROUP
inherit
	ANY
	redefine
		is_equal
	end

creation
	make

feature -- Initialization
	make(a_db: HOTBABE_DB; a_name: STRING) is
	require
		a_db /= Void;
		a_name /= Void;
	do
		db := a_db;
		name := a_name;

		!! text_records.make;
		!! clip_records.make;
		!! text_groups.make;
		!! clip_groups.make;
	end

feature -- Access
	name: STRING;

	random_text: HOTBABE_TEXT is
		-- retrieve a random text from this group
		--
		-- Algorithm:
		-- * Append group name to 'last_search_path'
		-- * Pick random item
		-- * If group, follow that group for random text
		-- * If text item, return it, but first replace
		--   embedded groups
		--
		-- This routine may not fetch any text.
		--
	require
		has_text
	local
		rval: INTEGER;
		sg: HOTBABE_DB_GROUP;
		txt: HOTBABE_TEXT;
	do
		Result := Void;

		db.last_search_path.extend(name);

		db.rnd.next;
		rval := db.rnd.item_range(1, text_count);

		if rval <= text_records.count then
			text_records.go_i_th(rval);
			txt := text_records.item;
			Result := txt.expanded_text(db);
		else
			rval := rval - text_records.count;
			text_groups.go_i_th(rval);
			sg := text_groups.item;
			Result := sg.random_text;
		end
	ensure
		Result /= Void;
	end

	random_clip: HOTBABE_CLIP is
		-- retrieve a random video clip from this group
		--
		-- Algorithm:
		-- * Append group name to 'last_search_path'
		-- * Pick random number
		-- * If clip, return it.
		-- * If group, follow that group for random clip
		--
	require
		has_clips
	local
		rval: INTEGER;
		sg: HOTBABE_DB_GROUP;
	do
		db.last_search_path.extend(name);

		db.rnd.next;
		rval := db.rnd.item_range(1, clip_count);

		if rval <= clip_records.count then
			clip_records.go_i_th(rval);
			Result := clip_records.item;
		else
			rval := rval - clip_records.count;
			clip_groups.go_i_th(rval);
			sg := clip_groups.item;

			Result := sg.random_clip;
		end
	ensure
		Result /= Void;
	end

feature -- Status Report
	is_equal(other: HOTBABE_DB_GROUP): BOOLEAN is
		-- compare two groups for equality. Only
		-- the names matter
	do
		Result := name.is_equal(other.name);
	end

	has_text: BOOLEAN is
		-- this group contains text messages
	do
		Result := text_records.count > 0
			or text_groups.count > 0;
	end

	has_clips: BOOLEAN is
		-- this group contains video clips
	do
		Result := clip_records.count > 0
			or clip_groups.count > 0;
	end

	has_both: BOOLEAN is
		-- this group contains both text and video records
	do
		Result := has_text and has_clips;
	end

	is_empty: BOOLEAN is
		-- group contains no data
	do
		Result := not has_text and not has_clips;
	end

	text_count: INTEGER is
		-- number of items in this group that has text
	do
		Result := text_records.count + text_groups.count;
	end

	clip_count: INTEGER is
		-- number of items in this group that has clips
	do
		Result := clip_records.count + clip_groups.count;
	end

feature -- Status Setting

feature -- Element Change
	add_text(text: HOTBABE_TEXT) is
	require
		text /= Void;
	do
		text_records.extend(text);
	end

	add_clip(clip: HOTBABE_CLIP) is
	require
		clip /= Void;
	do
		clip_records.extend(clip);
	end

	add_subgroup(sg: HOTBABE_DB_GROUP) is
		-- attach the sub-group (as specified in
		-- the 'G' record from the file)
		-- to the current group.
		--
		-- NOTE: We allow the same group to
		-- be added multiple times, this allows
		-- us to control the probability
		-- of certain video/text.
		-- For example,
		--
		-- [MY_GROUP]
		-- G HELLO
		-- G HELLO
		-- G HELLO
		-- G GOODBYE
		--
		-- In this example, we will randomly fetch
		-- a video clip from "HELLO" or "GOODBYE" subgroups
		-- but "HELLO"  is three times more likely to happen.
		-- 
	require
		sg /= Void;
	do
		if sg.has_text then
			text_groups.extend(sg);
		end

		if sg.has_clips then
			clip_groups.extend(sg);
		end
	end

feature -- Removal

feature {NONE} -- Implementation
	db: HOTBABE_DB;
		-- access to the whole database, for performing
		-- subgroup checks and access.

	text_records: LINKED_LIST[ HOTBABE_TEXT ];

	clip_records: LINKED_LIST[ HOTBABE_CLIP ];

	text_groups: LINKED_LIST[ HOTBABE_DB_GROUP ];
		-- subroups containing text records

	clip_groups: LINKED_LIST[ HOTBABE_DB_GROUP ];
		-- subgroups containing video clip records
end
