indexing
	description:	"a database of video clips and text messages"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

--
-- This class maintains a database of text messages, and video clips.
-- We read the "hotbabe_chess.dat" file to obtain this information
--
-- The documentation below describes the file format, and some notes
-- about the internal data structures used, as well as the search
-- algorithm(s).
--
-- FILE FORMAT:
-- ===========
-- We parse a file usually named, "hotbabe_chess.dat". This
-- data file contains all the video clip records, and text
-- messages that HOTBABE will use to simulate her behavior.
--
-- A video clip record is simply a start-frame/end-frame specification
-- A text message is a multi-line text string with some embedded
-- items to allow text to be randomly modified.
--
-- GENERAL FORMAT:
-- ==============
--	* blank lines are ignored
--	* A line the begins with white space followed by a semi-colon ';' is
--	  a comment line and is ignored
--	* The file is organized into groups, a group definition looks like:
--		[SOME_GROUP]
--
--	* There are 8 record types in this file:
--		"M" - magic number record
--		"D" - debug on/off
--		"N" - nickname record
--		"R" - rating (mature audience, general audience)
--		"V" - video clip defintion (general audience)
--		"v" - video clip defintion (mature content)
--		"T" - text message (general audience)
--		"t" - text message (mature content)
--		"G" - group reference

--
-- "M" record MAGIC NUMBER:
-- =======================
--	This number encodes the checksum for the rest of the file.
--	If this number doesn't match the file, then it is formatted wrong,
--	or somebody has changed the content, and the file cannot be read.
--	Examples,
--
--	Example,
--	M 97022538
--
--	The purpose of the magic number is to prevent users
--	from modifying this file. While we parse the file
--	we compute a simple check-sum of the characters in the
--	file. We use modulos to keep this number in a small range.
--	(The range will be: 0 - 9999)
--
--	Let's say this computation yeilds the following value: 5370
--
--	The magic number would be something like:
--		x70xx53x
--
--	The 'x' can be ANY digit and can be used to confuse hackers. So
--	the following are acceptable magic numbers for: 5370
--
--	M 97022538
--	M 87012534
--	M 77039539
--
--	When the magic number is wrong, we display the following error
--	message:
--		"invalid magic number 0xFF15370"
--
--	This allows the developer to go back and make the magic number
--	correct. The error message is intended to be obscure and the
--	"0xff" stuff has nothing to do with hexidecimal. It should
--	provide minimal protection against hackers, but the developer
--	will know how to read this number and insert the correct magic
--	number into the file.
--
--	By reading this doc., you are now able to modify the
--	magic number and modify the data file... Oh well,
--	script kiddies don't know how to read source code..
--
-- "D" record:
-- ==========
--	D 0	<- normal mode
--	D 1	<- debug mode
--
-- Turns on debug mode. Allows us to test the hotbabe_chess.dat. When
-- enabled, the main program will check for debug mode and allow
-- the developer to insert events directly into the HOTBABE event
-- queue.
--
-- "N" record:
-- ==========
--	Example,
--		N hotbabe
--
--	This record must appear before of any group, it defines the nickname
--	of the character for this program, this will most likely
--	be "hotbabe". Only one "N" record is allowed.
--
-- "R" record:
-- ==========
--	Examples,
--		R M	<- allow mature content
--		R G	<- general audience, don't allow mature content
--
--	This line can be modified after the program is installed to modify
--	hotbabe's behavior. Certain text messages, and video clips can
--	be flagged as "mature". If RATING is "G" then we
--	will ignore all text and video clips that have been flagged as
--	mature.
--
--	This record must exist outside of any group. Only one "R" record
--	is allowed in the file
--
--	This game is not intended to by very explicit anyway, but
--	you may not want your kids to see hotbabe taking bong hits. Thus
--	A GENERAL rating is what you will want.
--
-- "T" and "t" record:
-- ==================
--	Defines a text message. Example,
--	T hello how are you today?
--	t want to see my tits?
--
--	The first example is a general audience text message, the second may
--	be considered "mature" content. The second text message will be
--	ignored if the Rating is set to GENERAL.
--
--	Text records may span multiple lines:
--
--	T This is a very long message, that spans
--	+ multiple lines. When displayed in the chat window, it will
--	+ be shown across multiple lines in the chat window.
--
--	The "+" character allows us to continue the same text message
--	on another line. This helps us format certain long text messages
--	easier. Remember blank lines and comment lines are allowed anywhere,
--	that includes here too.
--
--	Text messages can contain sub-group references. In order
--	to make hotbabe's chatter appear more random we can
--	use sub-groups to replace words/phrases in a text messages. For
--	examples:
--
--	T Hello, want to play [A_REALLY_COOL] game of chess?
--
--	[REALLY_COOL]
--	T a really cool
--	T a fun
--	T an awsome
--	T an outrageous
--
--	In this example, we replace the sub-group reference [REALLY_COOL] with
--	one of the phrases in that group. (randomly selected)
--
--	Sub-group references must refer to group names that have already been
--	defined earlier in the file (thus avoiding cycles and the hassle of
--	performing cycle detection).
--
--	Also sub-group references inside of text messages, must refer to a
--	group that contains at least 1 text message.
--
--	The HOTBABE cluster of classes, check for additional formatting in
--	text strings: EMBEDDED LINKS, EMBEDDED VARIABLES and EMBEDDED BOLD
--
-- "V" and "v" record:
-- ==================
--	These records simply define a video clip. A video clip specifies
--	a start-frame and end-frame. Examples,
--
--	V 1234  4400
--	v 1000  1501
--
--	Alternative format:
--	V hh:mm:ss.ff hh:mm:ss.ff
--
--	A video clip must make sure that the start-frame is less than the end-frame.
--
--	When "v" is used, the video clip is considered "mature" content and will
--	be ignored when Rating is set to GENERAL (see R-record)
--
-- "G" record:
-- ==========
--	A subgroup allows us to reuse other groups, and avoid duplication.
--
--	Example,
--
--	[GENERAL_CLIPS]
--	V 1230 4000
--	V 4001 9020
--	V 9021 10450
--	G THINKING_CLIPS
--	G TYPING_CLIPS
--	G LOOKING_CLIPS
--
--	The group GENERAL_CLIPS defines a bunch of video clips, the first
--	three are actual video clips. The next three are sub-group references.
--
--	A sub-group reference must be defined before it can be used. During
--	search operations we will recursively follow subgroups to obtain
--	a video clip
--
-- GROUPS:
-- ======
--	Groups are how we organize the file into sections that organize
--	the video and text that hotbabe is capable of using.
--
--	Groups must contain at least 1 record. Groups can only contain
--	"T", "t", "V", "v", and "G" records.
--
--	A group is an identifier surrounded by square brackets. Eg.
--
--	[GROUP]
--	[BLAH]
--	[DRINKING_CLIPS]
--	[@HOTBABE_CAPTURES_PAWN]	<- pre-defined group
--
--	Pre-defined groups, are indicated by a leading '@' sign. This
--	just a naming convention, not strictly enforced by the parser.
--
--	(however, we do check that all predefined groups appear
--	in the file and have the correct types of data in them)
--
--
-- PRE-DEFINED GROUPS:
-- ================
-- By convention pre-defined groups are those that begin with an '@' sign.
-- This is just a special naming convention. It means that the
-- hotbabe_chess.exe program will refer to these groups inside of the program.
--
-- Examples,
--	[@PLAYER_CAPTURES_QUEEN]
--	G SADNESS_CLIPS
--	T Damn! I lost my queen
--	T Ouch, that hurts
--	T Opps, I didn't see that comming... Bummer
--
-- In this example, we use pre-defined groups to access special video/text
-- for when certain events happen during gameplay. For example, if the
-- player captures Hotbabe's queen, we will want to have her
--
--	1. Show sadness in the webcam.
--	2. Possibly say something, about her regret in losing the aqueen.
--		"Damn!!!! You captured my queen. I'm screwed now.. LOL"
--
-- We do a special check to make sure  that every pre-defined group is present
-- inside of the data file. (See the class HOTBABE_GROUP_CONSTANTS)
--
-- DATA STRUCTURE:
-- ==============
-- The internal data structure for this file is a hash table
-- that is indexed using the group name. Each element in the
-- hash table is a HOTBABE_DB_GROUP.
--
-- The key is the group name, internally we convert all group
-- names to uppercase, so that in the file, case distinctions are not
-- important.
--
-- A HOTBABE_DB_GROUP, is a structure that contains
-- lists for all the text, video and sub-groups. There is
-- also a pointer to the database, so we can resolve sub-group references.
--
-- NOTES ON THE SEARCH ALGORITHM:
-- =============================
-- When the client wants a text message (or random video clip) we
-- are passed a "group_name".
--
-- * First we probe the hash table and look-up the group based
--	on the "group_name"
--
-- * If the group does not have any text data, we return Void
--
-- * If we are looking for a random text message, we
--	pick a random number that will cause us to either select
--	a "T" message, or will cause us to select a "G" record.
--
-- * If we have another group reference, then we recursively
--	perform the search with the sub-group.
--
-- * Eventually we will reach and actual text message, which is returned.
--
-- * The search_path will be a list of sub-groups needed to reach the
--	text message.
--
-- * Before returning a text message, we will also replace any subgroup
--	references in the string. e.g.
--
--	T Hello, want to play [A_REALLY_COOL] game of chess?
--
--	(In this example, [A_REALLY_COOL] will cause us to perform
--	another search operation)
--
--	This can cause many recursive calls depending on the complexity
--	of the group nesting
--
-- * Searching for a video clip follows the same exact procedure.
--
-- * The search_path is very important to us. This comes in
--	handy when we want a random video clip. When the clip is obtained
--	we usually want a text message that relates somehow to the video
--	clip.
--
--	For example, if we show a video clip of hotbabe drinking a beer
--	we may want her to type something like,
--
--		"Mmmmmm. Beer makes me think better"
--
--	The search_path, allows us to fetch a text message
--	that comes from the same sub-group as the video clip.
--
--	If a sub-group has no text messages, then we look at the next
--	higher up group to find a message. We continue this process until
--	we reach a sub-group with text messages.
--
--	If no text message is found, then we say nothing.
--
--

class HOTBABE_DB
inherit
	HASH_TABLE[HOTBABE_DB_GROUP, STRING ]
	rename
		make as hash_make,
		found as hash_found
	export
		{NONE} all
		{ANY}  has
	end

	SCC_SYSTEM_TIME
	undefine
		is_equal, copy
	end

creation
	make

feature -- Initialization
	make(a_filename: STRING) is
		-- read/parse the data file
		-- if an error occurs 'failed' will be
		-- set to True, and 'error_message' will
		-- be set to a printable message.
	require
		a_filename /= Void;
	local
		f: PLAIN_TEXT_FILE;
	do
		failed := False;
		error_message := Void;

		hash_make(Hash_size);

		filename := a_filename;

		!! f.make(filename);

		if not f.exists then
			failed := True;
			error_message := "File not found: " + filename ;
		elseif not f.is_readable then
			failed := True;
			error_message := "Cannot read: " + filename ;
		else
			f.open_read;
			parse_file(f);
			f.close;

			!! rnd.make(seed);
			!! last_search_path.make;
		end
	end

	failed: BOOLEAN;
		-- set to TRUE when the database cannot be read, or
		-- has parse errors in it.

	error_message: STRING;
		-- A message (including line number), that indicates the
		-- nature of the failure.

feature {HOTBABE, HOTBABE_DB_GROUP, HOTBABE_EVENT, HOTBABE_TEXT} -- Access
	nickname: STRING;
		-- Value specified by the "N" record

	mature: BOOLEAN;
		-- for a mature or general audience?

	debug_mode: BOOLEAN;

	find_text(group_name: STRING): HOTBABE_TEXT is
		-- choose a random message from within the group
	require
		group_name /= Void;
		has(group_name);
	local
		grp: HOTBABE_DB_GROUP;
	do
		last_search_path.wipe_out;
		grp := find_group(group_name);
		Result := grp.random_text;

	ensure
		Result /= Void;
	end

	find_clip(group_name: STRING): HOTBABE_CLIP is
		-- choose a random video clip within 'group'
		-- return Void is this group has no video clips
	require
		group_name /= Void;
		has(group_name);
	local
		grp: HOTBABE_DB_GROUP;
	do
		last_search_path.wipe_out;
		grp := find_group(group_name);
		Result := grp.random_clip;
	ensure
		Result /= Void;
	end

	find_text_using_last_path: HOTBABE_TEXT is
		-- choose a random message, except we use the search path
		-- to find a text message that is located along 'path'.
	require
		last_search_path.count > 0;
	local
		path: HOTBABE_DB_SEARCH_PATH;
		txt: HOTBABE_TEXT;
		found: BOOLEAN;
		grp: HOTBABE_DB_GROUP;
	do
		--
		-- need a private copy of last_search_path
		--
		path := last_search_path;
		!! last_search_path.make;
		
		from
			found := False;
			path.finish;
		until
			path.off or found
		loop
			grp := find_group(path.item);
			if grp.has_text then
				found := True;
				txt := grp.random_text;
			end

			path.back;
		end

		--
		-- restore last_search_path to its orginal
		--
		last_search_path := path;

		if found then
			Result := txt;
		else
			Result := Void;
		end
	end

	last_search_path: HOTBABE_DB_SEARCH_PATH;
		-- find_text and find_clip will set this. Find_text
		-- may not set this when there was no text message found.
		-- find_clip must ALWAYS, ALWAYS find a video clip

feature -- Status Report
feature -- Status Setting

feature -- Element Change
	set_search_path(path: HOTBABE_DB_SEARCH_PATH) is
		-- set 'last_search_path'
	require
		path /= Void;
	do
		last_search_path := path;
	end

feature -- Removal
feature {NONE} -- Implementation
	filename: STRING;
	lineno: INTEGER;
	checksum: INTEGER;
	has_rating, has_debug: BOOLEAN;
	magic_number: STRING;

	parse_file(f: PLAIN_TEXT_FILE) is
		-- read and parse the 'hotbabe_chess.dat' file
		--
		-- 'f' is already opened and is readable
		--
		-- This is a fairly large routine. Basically, it
		-- consists of a loop that fetches each line of
		-- the data file.
		--
		-- The "if..then..elseif.." compares the each line
		-- in the file against certain types of patterns
		-- it then parses the individual lines and builds
		-- the internal database of text and video clips.
		--
		-- The loop exits if any parse error happens or
		-- end-of-file is reached.
		--
	require
		f /= Void;
	local
		str: STRING;
		current_group: HOTBABE_DB_GROUP;
		clip: HOTBABE_CLIP;
		text: HOTBABE_TEXT;
		sub_group: HOTBABE_DB_GROUP;
		current_text: HOTBABE_TEXT;
		checksum_line: INTEGER;
		checksum_lineno: INTEGER;
		use_checksum: BOOLEAN;
	do
		from
			current_group := Void;
			has_rating := False;
			has_debug := False;
			debug_mode := False;
			nickname := Void;
			magic_number := Void;
			checksum_lineno := 0;
			checksum := 0;
			lineno := 0;
			failed := False;
			f.start;
		until
			failed or f.end_of_file
		loop
			f.read_line;
			str := f.last_string;
			str := strip_spaces(str);
			lineno := lineno + 1;

			checksum_line := calculate_checksum(str);
			use_checksum := False;

			if is_blank(str) then
				-- ignore blank lines

			elseif is_comment(str) then
				-- ignore comments

			elseif is_record_type(str, 'M') then

				if magic_number /= Void then
					parse_error(filename, lineno,
						"M-record already exists");
				elseif current_group /= Void then
					parse_error(filename, lineno,
						"M-record not allowed in group");
				else
					magic_number := parse_m_record(str);
				end

			elseif is_record_type(str, 'D') then
				use_checksum := True;

				if has_debug then
					parse_error(filename, lineno,
							"D-record already exists");
				elseif current_group /= Void then
					parse_error(filename, lineno,
						"D-record not allowed in group");
				else
					has_debug := True;
					debug_mode := parse_d_record(str);
				end

			elseif is_record_type(str, 'N') then
				use_checksum := True;

				if nickname /= Void then
					parse_error(filename, lineno,
						"N-record already exists");
				elseif current_group /= Void then
					parse_error(filename, lineno,
						"N-record not allowed in group");
				else
					nickname := parse_n_record(str);
				end

			elseif is_record_type(str, 'R') then
				if has_rating then
					parse_error(filename, lineno,
						"R-record already exists");
				elseif current_group /= Void then
					parse_error(filename, lineno,
						"R-record not allowed in group");
				else
					has_rating := True;
					mature := parse_r_record(str);
				end

			elseif is_group_definition(str) then
				use_checksum := True;

				current_text := Void;

				if current_group /= Void then
					if current_group.is_empty then
						parse_error(filename, lineno,
							"empty group '"
							+ current_group.name
							+ "' not allowed");
					else
						insert_group(current_group);
					end
				end

				if not failed then
					current_group := parse_group(str);
				end

			elseif is_record_type(str, 'T')
					or is_record_type(str, 't') then
				use_checksum := True;

				if current_group = Void then
					parse_error(filename, lineno,
						"T-record must appear in a group");
				else
					text := parse_t_record(str);
					if text /= Void then
						if suitable(text.mature) then
							current_group.add_text(text);
						end
						current_text := text;
					end
				end

			elseif is_record_type(str, '+') then
				use_checksum := True;

				if current_group = Void then
					parse_error(filename, lineno,
						"'+' record must appear in a group");
				elseif current_text = Void then
					parse_error(filename, lineno,
						"'+' record must follow a T-record");
				else
					parse_plus_record(current_text, str);
				end

			elseif is_record_type(str, 'V')
					or is_record_type(str, 'v') then
				use_checksum := True;

				current_text := Void;

				if current_group = Void then
					parse_error(filename, lineno,
						"V-record must appear in a group");
				else
					clip := parse_v_record(str);
					if clip /= Void then
						if suitable(clip.mature) then
							current_group.add_clip(clip);
						end
					end
				end

			elseif is_record_type(str, 'G') then
				use_checksum := True;
				current_text := Void;

				if current_group = Void then
					parse_error(filename, lineno,
						"G-record must appear in a group");
				else
					sub_group := parse_g_record(str);
					if sub_group /= Void then
						current_group.add_subgroup(sub_group);
					end
				end

			else
				parse_error(filename, lineno, "syntax error");
			end

			if not failed and use_checksum then
				checksum_lineno := checksum_lineno + 1;
				checksum := checksum + (checksum_line * checksum_lineno);
				checksum := checksum \\ Checksum_modulo;
			end

		end

		if not failed then
			--
			-- insert the last group
			--
			if current_group /= Void then
				if current_group.is_empty then
					parse_error(filename, lineno,
						"empty group '"
						+ current_group.name
						+ "' not allowed");
				else
					insert_group(current_group);
					current_group := Void;
				end
			end
		end

		if not failed then
			final_error_checking;
		end

	ensure
		failed or f.end_of_file;
	end

	final_error_checking is
		-- This routine checks a couple of errors
		-- that we have not checked before.
		--
		-- End-of-Parse errors checking:
		--	M record exists
		--	N record exists
		--	R record exists
		--	magic number correctness
		--
	do
		if not has_rating then
			parse_error(filename, lineno, "No R-record found in file");
		elseif nickname = Void then
			parse_error(filename, lineno, "No N-record found in file");
		elseif magic_number = Void then
			parse_error(filename, lineno, "No M-record found in file");
		end

		if not failed then
			verify_checksum(checksum, magic_number);
		end
	end

	parse_error(fn: STRING; ln: INTEGER; msg: STRING) is
		-- create an error message string, and
		-- set the 'failed' flag to True.
	require
		fn /= Void;
		ln >= 1;
		msg /= Void;
	do
		failed := True;
		error_message := fn + ", line " + ln.out + ": " + msg;
	end


feature {NONE} -- line matchning routines

	is_blank(str: STRING): BOOLEAN is
		-- a blank line is a string consisting of
		-- only spaces and tabs.
		-- (because we strip the whitespace from the start
		-- and end of the string before hand, this routine
		-- must check only that the length of the string is 0)
	require
		str /= Void;
	do
		Result := (str.count = 0);
	end

	is_comment(str: STRING): BOOLEAN is
		-- A line beginning with a semi-colon ';'
	require
		str /= Void;
	do
		if str.count >= 1 then
			Result := (str.item(1) = ';') ;
		else
			Result := False;
		end
	end

	is_record_type(str: STRING; rectype: CHARACTER): BOOLEAN is
		-- does this line match a record type 'rectype'?
		--
		-- A line matches a record type if the first character
		-- equals 'rectype' followed by a single space.
		-- 
		-- A valid record must be atleast 3 characters long
		--
	require
		str /= Void;
	do
		if str.count >= 3 then
			Result := (str.item(1) = rectype) and (str.item(2) = ' ');
		else
			Result := False;
		end
	end

	is_group_definition(str: STRING): BOOLEAN is
		-- A group definition is an identifier
		-- surrounded by square brackets on a
		-- line by itself
		--
	require
		str /= Void;
	local
		ident: STRING;
	do
		if str.count >= 3 then
			-- check for square brackets
			if str.item(1) = '[' and str.item(str.count) = ']' then
				-- check for valid identifier
				ident := str.substring(2, str.count-1);
				Result := is_valid_identifier(ident);
			else
				Result := False;
			end
		else
			Result := False;
		end
	end

	is_valid_identifier(str: STRING): BOOLEAN is
		-- an identifier consists of a sequence
		-- of characters. The first character may
		-- by a letter, underscore, '@' at-sign.
		-- 
		-- The subsequence characters in the identifier
		-- may also include digits.
	require
		str /= Void;
	local	
		i: INTEGER;
	do
		if str.count = 0 then
			Result := False;
		else
			from
				Result := True;
				i := 1;
			until
				(i > str.count) or (not Result)
			loop
				if str.item(i).is_digit then
					if i = 1 then
						Result := False;
					end

				elseif not str.item(i).is_alpha
					and not (str.item(i) = '_')
					and not (str.item(i) = '@')
				then
					Result := False;
				end

				i := i + 1;
			end
		end
	end

feature {NONE} -- string processing routines
	calculate_checksum(str: STRING): INTEGER is
		-- return a value between (0 - 9,999) the
		-- value equals a sum of all character
		-- ascii values times its position
	require
		str /= Void;
	local
		i: INTEGER;
	do
		from
			Result := 0;
			i := 1;
		until
			i > str.count
		loop
			Result := Result + str.item(i).code * i;
			i := i + 1;
		end

		Result := Result \\ 10_000;
	ensure
		Result >= 0 and Result <= 9_999;
	end

	strip_spaces(str: STRING): STRING is
		-- remove leading and trailing white space from 'str'
	require
		str /= Void;
	do
		!! Result.make_from_string(str);
		Result.left_adjust;
		Result.right_adjust;

	ensure
		Result /= Void;
	end

	valid_embedded_groups(str: STRING): BOOLEAN is
		--
		-- Scan string 'str' and look for embedded
		-- group names. Eg,
		-- "Hello, you are [COOL_WORD], nice to [MEET_WORD] you"
		--
		-- Verify that the groups COOL_WORD, and MEET_WORD exists.
		-- Verify that brackets are matched
		--
		-- Verify that the groups contain some text records
		--
	require
		str /= Void;
		not failed;
	local
		i, lb, rb: INTEGER;
		group_name: STRING;
		grp: HOTBABE_DB_GROUP;
	do
		lb := str.occurrences('[');
		rb := str.occurrences(']');

		if lb /= rb then
			parse_error(filename, lineno, "mis-matched '[ ]' in text");
			Result := False;

		elseif lb = 0 then
			-- no brackets in string
			Result := True;
		else
			-- scan list and check each group reference
			from
				Result := True;
				i := 1;
			until
				failed or i > str.count
			loop
				lb := str.index_of('[', i);
				rb := str.index_of(']', i);

				if lb = 0 then
					-- no more, terminate loop
					i := str.count + 1;

				elseif rb - lb = 1 then
					parse_error(filename, lineno,
						"empty group reference in text");
					Result := False;

				elseif rb - lb < 0 then
					parse_error(filename, lineno,
						"syntax error in text '] ['");
					Result := False;

				elseif rb - lb > 1 then
					group_name := str.substring(lb+1, rb-1);
					group_name.to_upper;
					grp := find_group(group_name);
					if grp = Void then
						parse_error(filename, lineno,
							"unknown group name '["
							+ group_name
							+ "]'");
						Result := False;
					elseif not grp.has_text then
						parse_error(filename, lineno,
							"group name '["
							+ group_name
							+ "]' has no text records");
						Result := False;
					end
				
					i := rb+1;
				else
					i := i + 1;
				end
			end
		end

	ensure
		Result implies not failed;
		not Result implies failed;
	end

	valid_embedded_variables(str: STRING): BOOLEAN is
		--
		-- scan string, looking for $name patterns
		--
		-- Verify that these '$' variables are
		-- properly formed
		--
	require
		str /= Void;
		not failed;
	local
		i, j: INTEGER;
		c: CHARACTER;
		substr: STRING;
		done: BOOLEAN;
	do
		from
			Result := True;
			i := 1;
		until
			(i > str.count) or (not Result)
		loop
			c := str.item(i);

			if c = '$' then
				from
					!! substr.make_empty;
					done := False;
					j := i+1;
				until
					j > str.count or done
				loop
					c := str.item(j);
					if c.is_digit or c.is_alpha or c = '_'
					then
						substr.append_character(c);
					else
						done := True;
					end
					j := j + 1;
				end

				Result := valid_var_string(substr);
			end
			i := i + 1;
		end

	ensure
		Result implies not failed;
		not Result implies failed;
	end

	valid_var_string(str: STRING): BOOLEAN is
		-- Is 'str' a valid variable string
		-- Rules:
		--	* $foobar is a valid identifier
	require
		str /= Void;
	do
		Result := True;
		if str.count = 0 then
			parse_error(filename, lineno, "Empty '$' variable");
			Result := False;
		elseif not is_valid_identifier(str) then
			parse_error(filename, lineno,
				"Invalid $ variable identifier");
			Result := False;
		end
	end

	valid_embedded_links(str: STRING): BOOLEAN is
		--
		-- scan string, looking for:
		--	"check out my profile at <http://www.blah.com|PROFILE>"
		--	"Click <here> for help"
		--	"Click <here|HELP_RESIGN> for help on resign"
		--
		-- Verify the angled brackets are matched
		-- verify that the identifier is formed properly
		-- verify that no '*' characters exist.
	require
		str /= Void;
		not failed;
	local
		lb, rb, i: INTEGER;
		previ, starti, endi: INTEGER;
		substr: STRING;
	do
		lb := str.occurrences('<');
		rb := str.occurrences('>');

		if lb /= rb then
			parse_error(filename, lineno, "mis-matched '< >' in text");
			Result := False;
		elseif lb = 0 then
			-- no embedded links
			Result := True;
		else
			from
				Result := True;
				previ := 1;
				i := 1;
			until
				(i > lb) or (not Result)
			loop
				starti := str.index_of('<', previ);
				endi := str.index_of('>', starti+1);

				if starti > endi then
					parse_error(filename, lineno,
						"reversed brackets '>' '<'");
					Result := False;
				else
					substr := str.substring(starti+1, endi-1);
					if not valid_link(substr) then
						Result := False;
					end
				end

				previ := endi+1;
				i := i + 1;
			end
		end

	ensure
		Result implies not failed;
		not Result implies failed;
	end

	valid_link(str: STRING): BOOLEAN is
		-- is this is a valid link string?
	require
		str /= Void;
	local
		num, i: INTEGER;
		substr: STRING;
	do
		Result := True;

		str.right_adjust;

		if str.count = 0 then
			parse_error(filename, lineno, "Empty embedded link <>");
			Result := False;
		else
			num := str.occurrences('|');
			if num > 1 then
				parse_error(filename, lineno,
						"Too many '|' in embedded link");
				Result := False;
			elseif num = 1 then
				i := str.index_of('|', 1);
				substr := str.substring(i+1, str.count);

				if i = 1 then
					parse_error(filename, lineno,
						"link text is empty");
					Result := False;

				elseif not is_valid_identifier(substr) then
					parse_error(filename, lineno,
						"invalid link identifier after '|'");
					Result := False;
				end
			end

			if Result and then str.occurrences('*') > 0 then
				parse_error(filename, lineno,
					"embedded link < > cannot contains asterisks '*'");
				Result := False;
			end

		end
	end

	valid_embedded_bold(str: STRING): BOOLEAN is
		-- Bold is indicated by surrounding text with
		-- the asterisk '*'..
		-- Verify that at the '*' is matched
		-- Verify that the * * encloses at least 1 non-blank character
		-- Verify that no link appears inside of *'s
	require
		str /= Void;
		not failed;
	local
		num, i: INTEGER;
		starti, endi, previ: INTEGER;
		substr: STRING;
	do
		num := str.occurrences('*');
		if num = 0 then
			-- no '*' character
			Result := True;

		elseif (num \\ 2) = 1 then
			-- odd number of '*'
			parse_error(filename, lineno, "mis-matched '*' (BOLD) in text");
			Result := False;

		else
			-- verify '*' encloses 1 non-blank character
			from
				i := 1;
				num := num // 2;
				previ := 1;
				Result := True;
			until
				(i > num) or (not Result)
			loop
				starti := str.index_of('*', previ);
				endi := str.index_of('*', starti+1);

				substr := str.substring(starti+1, endi-1);
				substr.right_adjust;

				if substr.count = 0 then
					-- '*' encloses nothing but whitespace
					parse_error(filename, lineno,
						"bold '*' pattern is empty");
					Result := False;
				elseif substr.occurrences('<') > 0
						or substr.occurrences('>') > 0
				then
					-- '*' encloses a link
					parse_error(filename, lineno,
						"bold '*' pattern contains link");
					Result := False;
				end

				previ := endi+1;
				i := i + 1;
			end
		end

	ensure
		Result implies not failed;
		not Result implies failed;
	end

	valid_text_string(str: STRING): BOOLEAN is
		-- check the text string for all sorts
		-- of possible errors.
		--
		-- This routine scans a line of text for
		-- many special embedded characters.
		--
		-- EMBEDDED GROUPS:
		--	An embedded group reference looks like this:
		--		"You are so [COOL_ADJ] [COOL]"
		--
		--	We check for syntax, and that the
		--	groups actually exist.
		--
		--	When fetching text data, we automatically
		--	replace these groups with random text from
		--	the referenced groups.
		--
		-- EMBEDDED VARIABLES:
		--	$ variables can be numeric, in which
		--	case only $1 $2 and $3 are allowed.
		--
		--	We also support named $ variables, in which
		--	case the stuff following the '$' can be
		--	any valid identifier.
		--
		-- EMBEDDED LINKS:
		--	An embedded link is something like:
		--	"click <here> for help"
		--
		--
		-- EMBEDDED BOLD:
		--	If we want to show a word or phrase
		--	in bold, we surround the text with asterisks '*'
		--
		--	We check to make sure that there are matching '*'
		--	and also that the enclosing text is non-blank/not
		--	empty
		--
	require
		str /= Void;
		not failed;
	do
		if not valid_embedded_groups(str) then
			Result := False;
		elseif not valid_embedded_variables(str) then
			Result := False;
		elseif not valid_embedded_links(str) then
			Result := False;
		elseif not valid_embedded_bold(str) then
			Result := False;
		else
			Result := True;
		end
	ensure
		not Result implies failed;
		Result implies not failed; 
	end

	verify_checksum(ccs: INTEGER; magic_str: STRING) is
		-- examine the computed checksum 'ccs' for this file,
		-- and verify it matches th magic_number that was
		-- specified in the "M" record
		--
		-- If the checksum does not match the magic_number, then
		-- set 'failed' and produce an error message.
	require
		ccs >= 0;
		magic_str /= Void;
		magic_str.count = 8;
		magic_str.is_integer;
	local
		code: INTEGER;
		mstr: STRING;
		mval: INTEGER;
	do
		code := ccs \\ 10_000;

		!! mstr.make(4);
		mstr.append_character(magic_str.item(6));
		mstr.append_character(magic_str.item(7));
		mstr.append_character(magic_str.item(2));
		mstr.append_character(magic_str.item(3));
		mval := mstr.to_integer;

		if (mval < Checksum_lower or mval > Checksum_upper) and (mval /= code)
		then
			failed := True;
			parse_error(filename, lineno, "0xffc"
					+ (code + 10_000).out
					+ ": Invalid magic number");
		end
		
	end

	suitable(mature_rating: BOOLEAN): BOOLEAN is
		--
		-- Is this record suitable for the rating specified in
		-- the R-record?
		--
		-- 'mature_rating' is the rating for a T-record or
		-- a V-record. If this file is configured for
		-- general audience, then only non-mature rated records
		-- are suitable.
	do
		Result := mature or (not mature_rating);
	end

feature {NONE} -- parse individual line types

	parse_group(str: STRING): HOTBABE_DB_GROUP is
		-- extract group name
		-- this begins a new group definition
	require
		str /= Void;
		is_group_definition(str);
		not failed;
	local
		ident: STRING;
		grp: HOTBABE_DB_GROUP;
	do
		ident := str.substring(2, str.count-1);
		ident.to_upper;

		grp := find_group(ident);
		if grp /= Void then
			parse_error(filename, lineno,
				"group: '" + ident + "' is already defined");
			Result := Void;
		else
			!! Result.make(Current, ident);
		end

	ensure
		failed implies (Result = Void);
		not failed implies (Result /= Void);
	end

	parse_g_record(str: STRING): HOTBABE_DB_GROUP is
		-- parse a group reference
	require
		str /= Void;
		is_record_type(str, 'G');
		not failed;
	local
		ident: STRING;
	do
		ident := strip_spaces( str.substring(3, str.count) );
		ident.to_upper;

		Result := find_group(ident);
		if Result = Void then
			parse_error(filename, lineno,
				"undefined group: '" + ident + "' in G-record");
		end
	ensure
		failed implies (Result = Void);
		not failed implies (Result /= Void);
	end

	parse_v_record(str: STRING): HOTBABE_CLIP is
		-- parse a video clip record
	require
		str /= Void;
		is_record_type(str, 'v') or
			is_record_type(str, 'V');
		not failed;
	local
		data: STRING;
		start_frame, end_frame: INTEGER;
		start_str, end_str: STRING;
		m: BOOLEAN;
		i: INTEGER;
	do
		-- figure out the rating for this record
		if str.item(1) = 'v' then
			m := True;
		else
			m := False;
		end

		data := strip_spaces( str.substring(3, str.count) );

		--
		-- convert all tabs to spaces
		--
		data.replace_substring_all("%T", " ");

		i := data.index_of(' ', 1);
		if i = 0 then
			parse_error(filename, lineno, "syntax error in V-record");
		else
			start_str := strip_spaces( data.substring(1, i) );
			end_str := strip_spaces( data.substring(i, data.count) );

			if start_str.is_integer then
				start_frame := start_str.to_integer;

			elseif is_hhmmssff_format(start_str) then
				start_frame := parse_hhmmssff_format(start_str, True);
			else
				parse_error(filename, lineno,
					"start frame not a valid format");
			end

			if not failed then
				if end_str.is_integer then
					end_frame := end_str.to_integer;

				elseif is_hhmmssff_format(end_str) then
					end_frame := parse_hhmmssff_format(end_str, False);
				else
					parse_error(filename, lineno,
						"end frame not a valid format");
				end
			end

			if not failed then
				if (start_frame < 0) then
					parse_error(filename, lineno,
						"start frame must be >= 0");
				end
			end

			if not failed then
				if (end_frame <= start_frame) then
					parse_error(filename, lineno,
						"end frame must be <= start frame");
				end
			end

			if not failed then
				!! Result.make(start_frame, end_frame, m);
			end
		end

	ensure
		failed implies (Result = Void);
		not failed implies (Result /= Void);
	end

	parse_t_record(str: STRING): HOTBABE_TEXT is
		-- parse a text message record
	require
		str /= Void;
		is_record_type(str, 't') or
			is_record_type(str, 'T');
		not failed;
	local
		data: STRING;
		m: BOOLEAN;
	do
		-- figure out the rating for this record
		if str.item(1) = 't' then
			m := True;
		else
			m := False;
		end

		--
		-- handle the '~' character, which
		-- is considered a blank line, when it
		-- appears by itself in a T-record
		--
		data := str.substring(3, str.count);
		if data.count = 1 and data.item(1) = '~' then
			!! data.make_empty;
		end

		if valid_text_string(data) then
			!! Result.make(data, m);
		end

	ensure
		failed implies (Result = Void);
		not failed implies (Result /= Void);
	end

	parse_plus_record(base: HOTBABE_TEXT; str: STRING) is
		-- parse a text continuation record ('+' record)
		-- (append's a new line of text to 'base')
	require
		base /= Void;
		str /= Void;
		is_record_type(str, '+');
		not failed;
	local
		data: STRING;
	do
		--
		-- handle the '~' character, which
		-- is considered a blank line, when it
		-- appears by itself in a T-record
		--
		data := str.substring(3, str.count);
		if data.count = 1 and data.item(1) = '~' then
			!! data.make_empty;
		end

		if valid_text_string(data) then
			base.add_text(data);
		end
	end

	parse_m_record(str: STRING): STRING is
		-- parse a magic number record, return the
		-- string.
	require
		str /= Void;
		is_record_type(str, 'M');
		not failed;
	local
		data: STRING;
	do
		data := strip_spaces( str.substring(3, str.count) );
		if not data.is_integer then
			parse_error(filename, lineno, "M-record not an integer");

		elseif data.count /= 8 then
			parse_error(filename, lineno, "magic number not 8 digits");

		else
			Result := data;
		end

	ensure
		failed implies (Result = Void);
		not failed implies (Result /= Void);
	end

	parse_n_record(str: STRING): STRING is
		-- parse a nick name record
	require
		str /= Void;
		is_record_type(str, 'N');
		not failed;
	local
		data: STRING;
	do
		data := strip_spaces( str.substring(3, str.count) );
		data.replace_substring_all("%T", " ");

		if data.index_of(' ', 1) /= 0 then
			parse_error(filename, lineno, "nickname cannot have spaces");
		elseif data.count >= 10 then
			parse_error(filename, lineno,
				"nickname length exceeds 10 characters");
		else
			Result := data;
		end
	ensure
		failed implies (Result = Void);
		not failed implies (Result /= Void);
	end

	parse_r_record(str: STRING): BOOLEAN is
		-- parse rating record
		-- return True if the rating is Mature, False
		-- for a general audience
	require
		str /= Void;
		is_record_type(str, 'R');
		not failed;
	local
		data: STRING;
	do
		data := strip_spaces( str.substring(3, str.count) );

		if data.count /= 1 then
			parse_error(filename, lineno,
				"syntax error in R-record, length exceeds 1");
		elseif data.item(1) = 'G' then
			Result := False;
		elseif data.item(1) = 'M' then
			Result := True;
		else
			parse_error(filename, lineno,
				"R-record, should be 'G' or 'M'");
		end
	end

	parse_d_record(str: STRING): BOOLEAN is
		-- parse D-record (debug) record
		-- return True if the rating is Debug is ON, False
		-- for for normal mode.
	require
		str /= Void;
		is_record_type(str, 'D');
		not failed;
	local
		data: STRING;
	do
		data := strip_spaces( str.substring(3, str.count) );

		if data.count /= 1 then
			parse_error(filename, lineno,
				"syntax error in D-record, length exceeds 1");
		elseif data.item(1) = '0' then
			Result := False;
		elseif data.item(1) = '1' then
			Result := True;
		else
			parse_error(filename, lineno,
				"D-record, should be '0' or '1'");
		end
	end

	is_hhmmssff_format(str: STRING): BOOLEAN is
		-- verify string is in this format:
		--	HH:MM:SS.FF
		--
		-- 'HH' is 2 digits 00 - 59
		-- 'MM' is 2 digits 00 - 59
		-- 'SS' is 2 digits 00 - 59
		-- 'F' is 2 digits 00 - 29
		--
	require
		str /= Void;
	do
		if str.count /= 11 then
			Result := False;

		elseif str.item(3) /= ':' then
			Result := False;

		elseif str.item(6) /= ':' then
			Result := False;

		elseif str.item(9) /= '.' then
			Result := False;

		else
			Result := True;
		end
	end

	parse_hhmmssff_format(str: STRING; start_frame: BOOLEAN): INTEGER is
		-- verify string is in this format:
		--	HH:MM:SS.FF
		--
		-- 'HH' is 2 digits 00 - 59
		-- 'MM' is 2 digits 00 - 59
		-- 'SS' is 2 digits 00 - 59
		-- 'FF' is 2 digits 00 - 29
		--
		-- Formula:
		-- (hh * 3600 * 5) + (mm*60*5) + (ss*5) + (ff/29.97)*5
		--
		-- If this is the start_frame (as indicated by the
		-- 'start_frame' argument) we ceiling the result and add 1.
		--
		-- If this is the end frame, we floor the result and
		-- add 1.
		--
		-- This ensures we only get frame values for the clip
		-- we want to play, and not frames from the previous or
		-- next clip.
		--
	require
		str /= Void;
		is_hhmmssff_format(str);
		not failed;
	local
		hour_str, minute_str, second_str, frame_str: STRING;
		hour, minute, second, frame: INTEGER;
		ff: DOUBLE;
		fi: INTEGER;
	do
		hour_str := str.substring(1, 2);
		minute_str := str.substring(4, 5);
		second_str := str.substring(7, 8);
		frame_str := str.substring(10, 11);

		if hour_str.is_integer then
			hour := hour_str.to_integer;
		else
			parse_error(filename, lineno,
				"invalid HH:MM:SS.FF format (hour field)");
		end

		if not failed then
			if minute_str.is_integer then
				minute := minute_str.to_integer;
			else
				parse_error(filename, lineno,
					"invalid HH:MM:SS.FF format (minute field)");
			end
		end

		if not failed then
			if second_str.is_integer then
				second := second_str.to_integer;
			else
				parse_error(filename, lineno,
					"invalid HH:MM:SS.FF format (second field)");
			end
		end

		if not failed then
			if frame_str.is_integer then
				frame := frame_str.to_integer;
			else
				parse_error(filename, lineno,
					"invalid HH:MM:SS.FF format (frame field)");
			end
		end

		if not failed then
			if (hour>59) or (minute>59) or (second>59) or (frame>30) then
				parse_error(filename, lineno,
					"range error in HH:MM:SS.FF");
			end
		end

		if not failed then
			ff := (frame / Standard_frames_per_second) * Frames_per_second;
			if start_frame then
				fi := ff.ceiling + 1;
			else
				fi := ff.floor - 1;
			end

			Result := (hour * 60 * 60 * Frames_per_second)
				+ (minute * 60 * Frames_per_second)
				+ (second * Frames_per_second)
				+ fi;
		end
	end

feature {HOTBABE_DB_GROUP, HOTBABE_GROUP_INFO, HOTBABE_EVENT}
	find_group(group_name: STRING): HOTBABE_DB_GROUP is
		-- look in hash table for a group by
		-- the name of 'group_name'
	require
		group_name /= Void;
	do
		if has(group_name) then
			Result := item(group_name);
		else
			Result := Void;
		end
	end

	insert_group(grp: HOTBABE_DB_GROUP) is
		-- insert a new group into the hash table
	require
		grp /= Void;
		find_group(grp.name) = Void;
	do
		extend(grp, grp.name);
	end

	rnd: SCC_RANDOM;
		-- random # generator needed to pick
		-- random elements from the database

	seed: INTEGER is
		-- return a seed value based on the current
		-- time.
	do
		Result := tick_count;
	end

feature {NONE}
	Hash_size: INTEGER is 2377;

	Frames_per_second: INTEGER is 5;
		-- our AVI file must be in 5 frames/second

	Standard_frames_per_second: DOUBLE is 29.97;
		-- this is the value assumed by the HH:MM:SS:FF format

	Checksum_lower: INTEGER is 8860;
	Checksum_upper: INTEGER is 8860;

	Checksum_modulo: INTEGER is 900_000_000;
		-- used to prevent the checksum from overflowing a 32-bit
		-- signed integer;

end
