indexing
	description:	"display a help message"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

--
-- The 'key' used in the creation procedure tells us
-- which pre-defined help group to fetch text for.
--
--
class HOTBABE_EVENT_HELP
inherit
	HOTBABE_EVENT

creation
	make

feature -- Initialization
	make(key: INTEGER) is
	require
		key >= 0;
	do
		inspect key
		when 0 then
			help_group_id := Hg_help;
		when 1 then
			help_group_id := Hg_help1;
		when 2 then
			help_group_id := Hg_help2;
		when 3 then
			help_group_id := Hg_help3;
		when 4 then
			help_group_id := Hg_help4;
		when 5 then
			help_group_id := Hg_help5;
		when 6 then
			help_group_id := Hg_help6;
		when 7 then
			help_group_id := Hg_help7;
		when 8 then
			help_group_id := Hg_help8;
		when 9 then
			help_group_id := Hg_help9;
		when 10 then
			help_group_id := Hg_help10;
		when 11 then
			help_group_id := Hg_help11;
		when 12 then
			help_group_id := Hg_help12;
		when 13 then
			help_group_id := Hg_help13;
		when 14 then
			help_group_id := Hg_help14;
		when 15 then
			help_group_id := Hg_help15;
		when 16 then
			help_group_id := Hg_help16;
		when 17 then
			help_group_id := Hg_help17;
		when 18 then
			help_group_id := Hg_help18;
		when 19 then
			help_group_id := Hg_help19;
		when 20 then
			help_group_id := Hg_help20;
		when 21 then
			help_group_id := Hg_help21;
		when 22 then
			help_group_id := Hg_help22;
		when 23 then
			help_group_id := Hg_help23;
		when 24 then
			help_group_id := Hg_help24;
		when 25 then
			help_group_id := Hg_help25;
		else
			--
			-- use top-level help message, if
			-- for some reason the key is bogus.
			--
			help_group_id := Hg_help;
		end
	end

feature -- Access
feature -- Processing
	think is
	do
		text_message := find_text(help_group_id);
	end

	help_group_id: INTEGER;

end
