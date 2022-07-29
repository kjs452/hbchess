indexing
	description:	"a hotbabe text message"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

--
-- This is a text message that hotbabe may
-- utter in the chat window of the game.
--
-- A text message may span multiple lines. Each
-- string in the list is a seperate line of text to
-- be displayed as seperate lines in the chat window.
--
--
class HOTBABE_TEXT
inherit
	LINKED_LIST[ STRING ]
	rename
		make as list_make,
		is_empty as list_is_empty
	export
		{NONE} all
		{ANY} start, forth, off, item, isfirst
	end

creation
	make

feature -- Initialization
	make(first_string: STRING; m: BOOLEAN) is
		-- 'first_string' is the first string to
		-- add to the list.
		-- 'm' is the rating, True means this is a mature audience
		-- text message.
	require
		first_string /= Void;
	do
		mature := m;
		list_make;
		add_text(first_string);
	end

feature -- Access
	mature: BOOLEAN;

	expanded_text(db: HOTBABE_DB): HOTBABE_TEXT is
		-- a version of Current in which all
		-- embedded groups have been removed
		--
		-- We don't want the 'db.last_search_path'
		-- to be changed during this operation, so
		-- we make a copy and restore it afterward.
		--
	require
		db /= Void;
	local
		str: STRING;
		saved_path: HOTBABE_DB_SEARCH_PATH;
	do
		saved_path := deep_clone(db.last_search_path);

		from
			start;
		until
			off
		loop
			str := replace_embedded_string(db, item);

			if isfirst then
				!! Result.make(str, mature);
			else
				Result.add_text(str);
			end
			forth;
		end

		db.set_search_path(saved_path);

	ensure
		Result /= Void;
	end

	to_string: STRING is
		-- combine multi-line strings into a single line
		-- multiple lines are combined, and seperated by a ' ' space.
	do
		from
			!! Result.make(100);
			start;
		until
			off
		loop
			if not isfirst then
				Result.append_character(' ');
			end

			Result.append(item);
			forth;
		end

	ensure
		Result /= Void;
	end

feature -- Status Report
	is_empty: BOOLEAN is
		-- a hotbabe_text is empty if ALL the lines of
		-- text are empty (or if there are no lines)
	local
		save_pos: CURSOR;
	do
		save_pos := cursor;

		from
			Result := True;
			start;
		until
			off or not Result
		loop
			if item.count > 0 then
				Result := False;
			end
			forth;
		end

		go_to(save_pos);
	end

feature -- Status Setting
feature -- Element Change
	add_text(s: STRING) is
	require
		s /= Void;
	do
		extend(s);
	end

feature -- Removal
feature {NONE} -- Implementation
	replace_embedded_string(db: HOTBABE_DB; str: STRING): STRING is
		-- scan string 'str' and look for embedded group
		-- references and substitute them with random text
	require
		db /= Void;
		str /= Void;
	local
		num, i: INTEGER;
		start_index, end_index: INTEGER;
		group_name: STRING;
		txt: HOTBABE_TEXT;
	do
		!! Result.make_from_string(str);

		num := str.occurrences('[');

		from
			i := 1;
		until
			i > num
		loop
			start_index := Result.index_of('[', 1);
			end_index := Result.index_of(']', 1);

			group_name := Result.substring(start_index+1, end_index-1);

			group_name.to_upper;
			txt := db.find_text(group_name);

			Result.replace_substring(txt.to_string, start_index, end_index);

			i := i + 1;
		end
	ensure
		Result /= Void;
	end

end
