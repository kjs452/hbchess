indexing
	description:	"utilities for converting HOTBABE_TEXT into%
				% CHESS_GUI_CHAT_SENTENCES"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

--
-- this class does all the conversion from
-- HOTBABE_TEXT into a chat message.
--
-- It also has simple routines for the direct messages
-- that our program needs
--
-- This class lets us setup variables for substitution
--
-- To fetch a message, we create an event and
-- then send it to the front of the hotbabe queue and
-- request the string.
--
-- It is an DBC violation if no string is found
--
-- This class only handles the DIRECT messages that
-- we want from the hotbabe database. Messages
-- generated from hotbabe are not part of this
-- mechanism.
--
-- LINK'S:
--	Some of the text messages will have embedded links, we
--	will generate a CHESS_LINK_DATA, which
--	contains a simple identifier.
--
--	For example,
--		"click <here|RESIGN_YES> if you wish to resign."
--
--	The CHESS_LINK_DATA object will contain
--	the string "RESIGN_YES".
--
--
class CHAT_TEXT_UTILITIES

creation
	make

feature -- Initialization
	make(hb: HOTBABE) is
	require
		hb /= Void;
	do
		hotbabe := hb;

		!! symbols.make(Hash_size);
		symbols.compare_objects;
	end

feature -- Access
	about_text_message: LINKED_LIST[ CHESS_GUI_CHAT_SENTENCE ] is
	local
		e: HOTBABE_EVENT_ABOUT;
		txt: HOTBABE_TEXT;
	do
		!! e.make;
		txt := get_hotbabe_text(e);
		Result := convert_to_system(txt);
	ensure
		Result /= Void;
	end

	file_save_message(filename: STRING): LINKED_LIST[ CHESS_GUI_CHAT_SENTENCE ] is
		-- message to show when user saves a game
	require
		filename /= Void;
	local
		e: HOTBABE_EVENT_SAVE;
		txt: HOTBABE_TEXT;
	do
		!! e.make;
		txt := get_hotbabe_text(e);

		set_variable("filename", filename);

		Result := convert_to_system(txt);

		delete_variable("filename");
	end

	file_save_error(msg: STRING): LINKED_LIST[ CHESS_GUI_CHAT_SENTENCE ] is
		-- message to show when user saves a game, and there is an
		-- error in saving.
	require
		msg /= Void;
	local
		e: HOTBABE_EVENT_SAVE_ERROR;
		txt: HOTBABE_TEXT;
	do
		!! e.make;
		txt := get_hotbabe_text(e);

		set_variable("msg", msg);

		Result := convert_to_system(txt);

		delete_variable("msg");
	end

	file_load_message(filename: STRING): LINKED_LIST[ CHESS_GUI_CHAT_SENTENCE ] is
		-- message to show when user loads a game
	require
		filename /= Void;
	local
		e: HOTBABE_EVENT_LOAD;
		txt: HOTBABE_TEXT;
	do
		!! e.make;
		txt := get_hotbabe_text(e);

		set_variable("filename", filename);

		Result := convert_to_system(txt);

		delete_variable("filename");
	end

	file_load_error(msg: STRING): LINKED_LIST[ CHESS_GUI_CHAT_SENTENCE ] is
		-- message to show when user loads a game, and it fails
	require
		msg /= Void;
	local
		e: HOTBABE_EVENT_LOAD_ERROR;
		txt: HOTBABE_TEXT;
	do
		!! e.make;
		txt := get_hotbabe_text(e);

		set_variable("msg", msg);

		Result := convert_to_system(txt);

		delete_variable("msg");
	end

	resign_confirm_message: LINKED_LIST[ CHESS_GUI_CHAT_SENTENCE ] is
		-- this message appears when the user wants to
		-- resign, we actually don't resign the game
		-- immediatly, we fetch this message
		-- which asks the user if they want to
		-- quit.
		-- This message is really a confirmation message.
		--
	local
		e: HOTBABE_EVENT_RESIGN_CONFIRM;
		txt: HOTBABE_TEXT;
	do
		!! e.make;
		txt := get_hotbabe_text(e);
		Result := convert_to_hotbabe(txt);
	ensure
		Result /= Void;
	end

	hint_before_message: LINKED_LIST[ CHESS_GUI_CHAT_SENTENCE ] is
		-- a message displayed before HOTBABE thinks about
		-- your hint
	local
		e: HOTBABE_EVENT_HINT_BEFORE;
		txt: HOTBABE_TEXT;
	do
		!! e.make;
		txt := get_hotbabe_text(e);
		Result := convert_to_hotbabe(txt);
	ensure
		Result /= Void;
	end

	hint_after_message(hint: STRING): LINKED_LIST[ CHESS_GUI_CHAT_SENTENCE ] is
		-- When hotbabe figures out a hint, this message is
		-- displayed. A link will exist that lets the
		-- user lick on the HINT and have that move
		-- automatically made.
		--
	require
		hint /= Void;
	local
		e: HOTBABE_EVENT_HINT_AFTER;
		txt: HOTBABE_TEXT;
	do
		!! e.make;
		txt := get_hotbabe_text(e);

		set_variable("hint", hint);
		Result := convert_to_hotbabe(txt);
		delete_variable("hint");

	ensure
		Result /= Void;
	end

	statistics_message(stats: CHESS_STATISTICS; skill: STRING):
					LINKED_LIST[ CHESS_GUI_CHAT_SENTENCE ] is
		-- 'stats' will be used to fill the variables
	require
		stats /= Void;
		skill /= Void;
	local
		e: HOTBABE_EVENT_STATISTICS;
		txt: HOTBABE_TEXT;
	do
		!! e.make;
		txt := get_hotbabe_text(e);

		set_variable("nps", stats.nodes_per_second.out);
		set_variable("last_nps", stats.last_nps.out);
		set_variable("last_nc", stats.last_node_count.out);
		set_variable("tslots", stats.total_hash_slots.out);
		set_variable("slots", stats.hash_slots_used.out);
		set_variable("collision", stats.total_hash_collisions.out);
		set_variable("lookup", stats.total_hash_lookups.out);
		set_variable("bs", stats.best_sequence);
		set_variable("skill", skill);

		Result := convert_to_system(txt);

		delete_variable("nps");
		delete_variable("last_nps");
		delete_variable("last_nc");
		delete_variable("tslots");
		delete_variable("slots");
		delete_variable("collision");
		delete_variable("lookup");
		delete_variable("bs");
		delete_variable("skill");
	ensure
		Result /= Void;
	end

	change_nickname_message(old_nick, new_nick: STRING):
				LINKED_LIST[ CHESS_GUI_CHAT_SENTENCE ] is
		-- displays a message saying that the
		-- user has changed thier nickname.
	require
		old_nick /= Void;
		new_nick /= Void;
	local
		e: HOTBABE_EVENT_CHANGE_NICKNAME;
		txt: HOTBABE_TEXT;
	do
		!! e.make;
		txt := get_hotbabe_text(e);

		set_variable("old", old_nick);
		set_variable("new", new_nick);

		Result := convert_to_system(txt);

		delete_variable("old");
		delete_variable("new");
	ensure
		Result /= Void;
	end

	start_message: LINKED_LIST[ CHESS_GUI_CHAT_SENTENCE ] is
		--
		-- A message that tell the user what to do when
		-- the program first starts
		--
	local
		e: HOTBABE_EVENT_START;
		txt: HOTBABE_TEXT;
	do
		!! e.make;
		txt := get_hotbabe_text(e);
		Result := convert_to_hotbabe(txt);
	ensure
		Result /= Void;
	end

	help_message(key: INTEGER): LINKED_LIST[ CHESS_GUI_CHAT_SENTENCE ] is
		-- the help message. Lists all the topics
	require
		key >= 0;
	local
		e: HOTBABE_EVENT_HELP;
		txt: HOTBABE_TEXT;
	do
		!! e.make(key);
		txt := get_hotbabe_text(e);
		Result := convert_to_system(txt);
	ensure
		Result /= Void;
	end

feature -- Conversion
	convert_to_hotbabe(txt: HOTBABE_TEXT): LINKED_LIST[ CHESS_GUI_CHAT_SENTENCE ] is
		--
		-- convert a HOTBABE_TEXT into a list of CHAT_SENTENCE's
		-- in the format of HOTBABE text.
		--
	require
		txt /= Void;
	do
		Result := convert(txt, False);
	ensure
		Result /= Void;
	end

	convert_to_system(txt: HOTBABE_TEXT): LINKED_LIST[ CHESS_GUI_CHAT_SENTENCE ] is
		--
		-- convert a HOTBABE_TEXT into a list of CHAT_SENTENCE's
		-- in the format of SYSTEM text.
		--
	require
		txt /= Void;
	do
		Result := convert(txt, True);
	ensure
		Result /= Void;
	end

feature -- Status Report
	exists(var: STRING): BOOLEAN is
		-- does the variable 'var' exists in the symbol table?
	require
		var /= Void;
	local
		varname: STRING;
	do
		!! varname.make_from_string(var);
		varname.to_upper;
		
		Result := symbols.has(varname);
	end

feature -- Status Setting
feature -- Element Change
	set_variable(var, value: STRING) is
		-- set variable, if variable already exists,
		-- then we replace its current value
		-- with 'value'
	require
		var /= Void;
		value /= Void;
	local
		varname: STRING;
	do
		!! varname.make_from_string(var);
		varname.to_upper;

		symbols.force(value, varname);
	ensure
		exists(var);
	end

feature -- Removal
	delete_variable(var: STRING) is
		-- delete the variable 'var'
	require
		var /= Void;
	local
		varname: STRING;
	do
		!! varname.make_from_string(var);
		varname.to_upper;

		symbols.remove(varname);
	ensure
		not exists(var);
	end

feature {NONE} -- Implementation (routines/functions)

	get_hotbabe_text(event: HOTBABE_EVENT): HOTBABE_TEXT is
		-- fetch a direct message from the HOTBABE database
	require
		event /= Void;
	do
		hotbabe.direct_message(event);
		Result := hotbabe.text_message;
	ensure
		Result /= Void;
	end

	convert(txt: HOTBABE_TEXT; as_system: BOOLEAN):
				LINKED_LIST[ CHESS_GUI_CHAT_SENTENCE ] is
		--
		-- convert 'txt' to CHESS_GUI_CHAT_SENTENCE's
		-- 'as_system' indicated the type of chat message to create:
		--	as_system=False		<- hotbabe chatter
		--	as_system=True		<- system message
		--
	require
		txt /= Void;
	local
		sentence: CHESS_GUI_CHAT_SENTENCE;
	do
		!! Result.make;

		from
			txt.start;
		until
			txt.off
		loop
			if as_system then
				!! sentence.make_system;
			else
				!! sentence.make_hotbabe;
				if txt.isfirst then
					sentence.append_bold(hotbabe.nickname + ": ");
				end
			end

			convert_line(txt.item, sentence);

			Result.extend(sentence);

			txt.forth;
		end

	ensure
		Result /= Void;
	end

	convert_line(a_line: STRING; sentence: CHESS_GUI_CHAT_SENTENCE) is
		-- this routine will parse 'line' and extract the
		-- individual phrases like BOLD text and LINK text and
		-- substitute the variables.
	require
		a_line /= Void;
		sentence /= Void;
	local
		line: STRING;
		i: INTEGER;
		c: CHARACTER;
		phrase: STRING;
		in_bold: BOOLEAN;
	do
		line := expand_variables(a_line);

		from
			in_bold := False;
			!! phrase.make(10);
			i := 1;
		until
			i > line.count
		loop
			c := line.item(i);

			if c = '*' and not in_bold then
				if phrase.count > 0 then
					sentence.append_normal(phrase);
					phrase.wipe_out;
				end
				in_bold := True;

			elseif c = '*' and in_bold then
				sentence.append_bold(phrase);
				in_bold := False;
				phrase.wipe_out;

			elseif c = '<' then
				if phrase.count > 0 then
					sentence.append_normal(phrase);
					phrase.wipe_out;
				end

			elseif c = '>' then
				convert_link(phrase, sentence);
				phrase.wipe_out;

			else
				phrase.append_character(c);
			end

			i := i + 1;
		end

		if phrase.count > 0 then
			sentence.append_normal(phrase);
		end
	end

	convert_link(link_string: STRING; sentence: CHESS_GUI_CHAT_SENTENCE) is
		-- 'link_string' is a link string (minus the angled brackets <>)
		-- We parse this and append a link to 'sentence'
	require
		link_string /= Void;
		sentence /= Void;
	local
		i: INTEGER;
		link_data: CHESS_LINK_DATA;
		ident, url: STRING;
	do
		i := link_string.index_of('|', 1);
		if i > 0 then
			url := link_string.substring(1, i-1);
			ident := link_string.substring(i+1, link_string.count);

			!! link_data.make(ident, url);
		else
			url := link_string;
			!! link_data.make_no_ident(url);
		end

		sentence.append_link(url, link_data);
	end

	expand_variables(line: STRING): STRING is
		-- expand variables. If a variable
		-- is found, but is not defined in
		-- the symbol table, then leave the
		-- variable reference alone (to aid debugging)
	require
		line /= Void;
	local
		c: CHARACTER;
		num, i, starti, endi: INTEGER;
		varname, value: STRING;
		done: BOOLEAN;
	do
		!! Result.make_from_string(line);
		num := line.occurrences('$');
		from
			i := 1;
		until
			i > num
		loop
			starti := Result.index_of('$', 1);

			from
				done := False;
				endi := starti + 1;
			until
				(endi > Result.count) or done
			loop
				c := Result.item(endi);
				if not c.is_digit
						and not c.is_alpha and c /= '_'
				then
					done := True;
				else
					endi := endi + 1;
				end
			end

			endi := endi-1;

			varname := Result.substring(starti+1, endi);
			value := get_variable(varname);

			Result.replace_substring(value, starti, endi);

			i := i + 1;
		end

	ensure
		Result /= Void;
	end

	get_variable(a_varname: STRING): STRING is
		-- lookup variable name.
		-- if variable is not found, then
		-- return (VARNAME)
		--
		-- If the variable value contains a '$' we silently
		-- strip it out, so that it doesn't screw up my "expand_variables"
		-- function.
	require
		a_varname /= Void
	local
		varname: STRING;
	do
		!! varname.make_from_string(a_varname);
		varname.to_upper;
		
		if symbols.has(varname) then
			Result := symbols.item(varname);
			Result.replace_substring_all("$", "");
		else
			Result := "(" + varname + ")";
		end

	ensure
		Result /= Void;
		Result.occurrences('$') = 0;
	end

feature {NONE} -- Implementation (attributes)
	hotbabe: HOTBABE;
	symbols: HASH_TABLE[STRING, STRING];

	Hash_size: INTEGER is 100;

end
