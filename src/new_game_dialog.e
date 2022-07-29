indexing
	description:	"new game dialog"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

--
-- This dialog allows the user to
-- setup the new game. It lets the
-- user select what color the player
-- will be.
--
-- The user also selects from 20 different
-- skill levels
--
-- This class has a static table that contains
-- all the 20 skill levels and what the actual
-- game parameters are.
--

class NEW_GAME_DIALOG
inherit
	WEL_MODAL_DIALOG
	redefine
		on_ok, on_show, on_cancel, on_paint
	end

	CHESS_APP_CONSTANTS

	CHESS_PIECE_CONSTANTS

creation
	make

feature -- Initialization
	make(a_parent: CHESS_MAIN_WINDOW) is
	do
		make_by_id(a_parent, Dlg_new_game);

		!! skill_slider.make_by_id(Current, Ngp_skill_slider);

		!! white_radio.make_by_id(Current, Ngp_white_radio);
		!! black_radio.make_by_id(Current, Ngp_black_radio);

		!! level_txt.make_by_id(Current, Ngp_level_txt);
		!! difficulty_txt.make_by_id(Current, Ngp_difficulty_txt);
		!! ply_txt.make_by_id(Current, Ngp_ply_txt);
		!! search_time_txt.make_by_id(Current, Ngp_search_time_txt);
		!! qsearch_txt.make_by_id(Current, Ngp_qsearch_txt);

		-- track paint command
		!! moved_cmd.make;
	end

feature {NONE} -- event processing
	on_paint(paint_dc: WEL_PAINT_DC; invalid_rect: WEL_RECT) is
	local
		pos: INTEGER;
		level: NEW_GAME_SKILL_LEVEL;
		bm: WEL_BITMAP;
	do
		-- draw a bitmap
		pos := skill_slider.position;
		level := skill_level.item(pos);
		bm := level.bitmap;
		paint_dc.draw_bitmap(bm,
				skill_icon_rect.left, skill_icon_rect.top,
				bm.width, bm.height);
	end

	on_show is
	local
		pos: INTEGER;
	do
		-- configure track bar
		skill_slider.set_range(Skill_min, Skill_max);
		skill_slider.set_page(Skill_page);
		skill_slider.enable_commands;

		skill_slider.put_command(moved_cmd, Wm_paint, Current);

		-- load data into dialog
		if form_data.player_color = Chess_color_white then
			white_radio.set_checked;
		else
			black_radio.set_checked;
		end

		pos := find_skill_level(form_data);
		skill_slider.set_position(pos);
	end

	on_cancel is
	do
		terminate(idcancel);
	end

	on_ok is
	local
		pos: INTEGER;
		level: NEW_GAME_SKILL_LEVEL;
	do
		if white_radio.checked then
			form_data.set_player_color(Chess_color_white);
		else
			form_data.set_player_color(Chess_color_black);
		end

		pos := skill_slider.position;
		level := skill_level.item(pos);

		form_data.set_qsearch(level.want_qsearch);
		form_data.set_max_ply(level.ply);
		form_data.set_max_time(level.search_time);

		terminate(idok);
	end

feature -- Access
	form_data: CHESS_GAME_OPTIONS;

feature -- Status Report
feature -- Status Setting
feature -- Element Change
	set_form_data(opts: CHESS_GAME_OPTIONS) is
	require
		opts /= Void;
	do
		form_data := opts;
	end

	update_details is
		-- called when the slider changed position
		-- this will update the "difficulty" section
		-- and let the user know what the search
		-- engine is configured for
	local
		level: NEW_GAME_SKILL_LEVEL;
		pos: INTEGER;
	do
		pos := skill_slider.position;

		level := skill_level.item(pos);

		level_txt.set_text(
			"Level: " + pos.out);

		difficulty_txt.set_text( level.description );

		if level.ply < Variable_ply_limit then
			ply_txt.set_text(
				"Search Depth: " + level.ply.out + "-ply");

			search_time_txt.set_text("Search Time: N/A");
		else
			ply_txt.set_text("Search Depth: Variable ply")
			search_time_txt.set_text(
				"Search Time: " + level.search_time.out + " seconds");
		end

		if level.want_qsearch then
			qsearch_txt.set_text("Quiescent Search: ON");
		else
			qsearch_txt.set_text("Quiescent Search: OFF");
		end

		invalidate_rect(skill_icon_rect, True);
	end

feature -- Removal

feature {NONE} -- Skill level table (routines)

	skill_level: ARRAY[ NEW_GAME_SKILL_LEVEL ] is
		-- This table contains all the skill levels
		-- that we support. THis ranges from
		-- easiest (skill level 1) all the
		-- way to hardest (skill level 20)
	local
		level: NEW_GAME_SKILL_LEVEL;
	once
		!! Result.make(Skill_min, Skill_max);

		!! level.make("newbie", Idb_skill_1, 2, 60, False);
		Result.put(level, 1);

		!! level.make("beginner", Idb_skill_2, 3, 60, False);
		Result.put(level, 2);

		!! level.make("script kiddie", Idb_skill_3, 2, 60, True);
		Result.put(level, 3);

		!! level.make("wannabe", Idb_skill_4, 3, 60, True);
		Result.put(level, 4);

		!! level.make("spammer", Idb_skill_5, 40, 4, True);
		Result.put(level, 5);

		!! level.make("scuba steve", Idb_skill_6, 40, 5, True);
		Result.put(level, 6);

		!! level.make("devry grad", Idb_skill_7, 40, 6, True);
		Result.put(level, 7);

		!! level.make("trekkie", Idb_skill_8, 40, 7, True);
		Result.put(level, 8);

		!! level.make("apu nahasapeemapetilon", Idb_skill_9, 40, 8, True);
		Result.put(level, 9);

		!! level.make("geek", Idb_skill_10, 40, 9, True);
		Result.put(level, 10);

		!! level.make("vax 11/780", Idb_skill_11, 40, 10, True);
		Result.put(level, 11);

		!! level.make("ritalin kid", Idb_skill_12, 40, 15, True);
		Result.put(level, 12);

		!! level.make("lap dancer", Idb_skill_13, 40, 20, True);
		Result.put(level, 13);

		!! level.make("soccer mom", Idb_skill_14, 40, 25, True);
		Result.put(level, 14);

		!! level.make("blonde", Idb_skill_15, 40, 30, True);
		Result.put(level, 15);

		!! level.make("brunette", Idb_skill_16, 40, 35, True);
		Result.put(level, 16);

		!! level.make("redhead", Idb_skill_17, 40, 40, True);
		Result.put(level, 17);

		!! level.make("hacker", Idb_skill_18, 40, 50, True);
		Result.put(level, 18);

		!! level.make("mensa", Idb_skill_19, 40, 60, True);
		Result.put(level, 19);

		!! level.make("genius", Idb_skill_20, 40, 120, True);
		Result.put(level, 20);
	end

	find_skill_level(opts: CHESS_GAME_OPTIONS): INTEGER is
		-- search skill_level table for a matching
		-- skill level, if not found, then
		-- return default skill level
	require
		opts /= Void;
	local
		level: NEW_GAME_SKILL_LEVEL;
		found: BOOLEAN;
		i: INTEGER;
	do
		from
			found := False;
			i := Skill_min;
		until
			i > Skill_max or found
		loop
			level := skill_level.item(i);

			if level.matches(opts) then
				found := True;
			else
				i := i + 1;
			end
		end

		if i > Skill_max then
			Result := Default_skill_level;
		else
			Result := i;
		end

	ensure
		Result >= Skill_min and Result <= Skill_max;
	end

feature {NONE} -- Implementation (attributes)

	Skill_min: INTEGER is 1;
	Skill_max: INTEGER is 20;
	Skill_page: INTEGER is 1;
	Default_skill_level: INTEGER is 6;
	Variable_ply_limit: INTEGER is 40;

	-- controls
	moved_cmd: NEW_GAME_MOVED_COMMAND;
	skill_slider: WEL_TRACK_BAR;
	white_radio: WEL_RADIO_BUTTON;
	black_radio: WEL_RADIO_BUTTON;
	level_txt: WEL_STATIC;
	difficulty_txt: WEL_STATIC;
	ply_txt: WEL_STATIC;
	search_time_txt: WEL_STATIC;
	qsearch_txt: WEL_STATIC;

	skill_icon_rect: WEL_RECT is
	local
		skx, sky, skwidth, skheight: INTEGER;
	once
		skx := 272;
		sky := 157;
		skwidth := 60;
		skheight := 60;

		!! Result.make(skx - skwidth, sky, skx, sky + skheight);
	end

	bm1: WEL_BITMAP;
	bm2: WEL_BITMAP;

end
