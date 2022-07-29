indexing
	description:	"defines a skill level"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

class NEW_GAME_SKILL_LEVEL

creation
	make

feature -- Initialization
	make(desc: STRING; bmid: INTEGER; a_ply, a_time: INTEGER; a_qsearch: BOOLEAN) is
	require
		desc /= Void;
		a_ply >= 0 and a_ply <= 100;
		a_time >= 1;
	do
		description := desc;
		ply := a_ply;
		search_time := a_time;
		want_qsearch := a_qsearch;

		!! bitmap.make_by_id(bmid);
	end

feature -- Access
	description: STRING;
	bitmap: WEL_BITMAP;
	ply: INTEGER;
	search_time: INTEGER;
	want_qsearch: BOOLEAN;

feature -- Status Report
	matches(opts: CHESS_GAME_OPTIONS): BOOLEAN is
		-- perform a match between this class and
		-- the 'opts' class.
		--
		-- If the opts.ply is less than 5, then
		-- we assume a fixed-ply setup. But if
		-- it is more than 5, we assume a variable
		-- ply, and thus compare against 0.
		--
		-- When fixed ply is used, then we
		-- usually set search_time to 60 seconds.
		--
	require
		opts /= Void;
	do
		if want_qsearch /= opts.qsearch then
			Result := False;

		elseif search_time /= opts.max_time then
			Result := False;

		elseif ply /= opts.max_ply then
			Result := False;

		else
			Result := True;
		end
	end

end
