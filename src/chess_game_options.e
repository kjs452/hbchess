indexing
	description:	"misc. options for controlling the chess engine"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

--
-- Skill level for the chess engine is controlled
-- by this class. There are 2 basic ways to control
-- the chess engine "skill".
-- (1) Fixed-ply: This is the number of moves the
--	computer searches into the game tree before computing
--	the "best" move
--
-- (2) Max-time: A fixed number of seconds is allocated
--	to the search. When that number of seconds has elapsed
--	the search engine returns a result
--
-- Max-time and Fixed-ply work together, when
-- the maxium time has elapsed the search always completes, even
-- if the number of fixed-ply's has not been reached.
--

class CHESS_GAME_OPTIONS
inherit
	CHESS_PIECE_CONSTANTS
	redefine
		out
	end

creation
	make

feature -- Initialization
	make is
	do
		set_max_time(60);
		set_max_ply(2);
		set_qsearch(False);
		set_player_color(Chess_color_white);
	end

feature -- Access
	max_ply: INTEGER;
	max_time: INTEGER;
	qsearch: BOOLEAN;
	player_color: INTEGER;

	out: STRING is
	do
		Result := "ply=" + max_ply.out
			+ ", time=" + max_time.out
			+ ", qsearch=" + qsearch.out
			+ ", player=" + piece_color_to_string(player_color);
	end

feature -- Status Report
feature -- Status Setting

feature -- Element Change
	set_max_ply(val: INTEGER) is
		-- maximum number of plys to search.
	require
		val >= 2;
	do
		max_ply := val;
	end

	set_max_time(val: INTEGER) is
		-- time in seconds. THe chess engine
		-- will think for at most this many
		-- seconds before making a move
	require
		val >= 1;
	do
		max_time := val;
	end

	set_qsearch(enabled: BOOLEAN) is
		-- perform Qsearch (quiescent search?)
	do
		qsearch := enabled;
	end

	set_player_color(side: INTEGER) is
	require
		valid_piece_color(side);
	do
		player_color := side;
	end
end
