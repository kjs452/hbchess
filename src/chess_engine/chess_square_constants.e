indexing
	description:	"Constants/functions for squares on a chess board"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

--
-- This class defined the numbering for chess squares.
--
-- Rather than use a row/col approach to identifying a chess square,
-- we simply number the squares from 1 thru 64.
--
-- This class also defines functions for converting from
-- square number to file/rank numbers.
--
-- This class also defines some function for converting
-- square numbers into string, etc...
--
-- In chess square A1 is the lower-left for the white side, and
-- we assign as value of 1 to this square.
--
-- The square H8 is the lower-left for the black side, it
-- is assigned a value of 64.
--
--
class CHESS_SQUARE_CONSTANTS

feature {NONE} -- Access
	Min_square: INTEGER is 1
	Max_square: INTEGER is 64
	Square_count: INTEGER is 64

	No_square_specified: INTEGER is 0;

	Min_file: INTEGER is 1
	Max_file: INTEGER is 8

	File_a: INTEGER is 1
	File_b: INTEGER is 2
	File_c: INTEGER is 3
	File_d: INTEGER is 4
	File_e: INTEGER is 5
	File_f: INTEGER is 6
	File_g: INTEGER is 7
	File_h: INTEGER is 8
	File_count: INTEGER is 8

	Min_rank: INTEGER is 1
	Max_rank: INTEGER is 8

	Rank_1: INTEGER is 1
	Rank_2: INTEGER is 2
	Rank_3: INTEGER is 3
	Rank_4: INTEGER is 4
	Rank_5: INTEGER is 5
	Rank_6: INTEGER is 6
	Rank_7: INTEGER is 7
	Rank_8: INTEGER is 8
	Rank_count: INTEGER is 8

	--
	-- Misc. squares definitions
	--

	-- Rook starting locations
	Square_A1: INTEGER is 1;
	Square_H1: INTEGER is 8;
	Square_A8: INTEGER is 57;
	Square_H8: INTEGER is 64;

	-- Rook castling locations
	Square_D1: INTEGER is 4;
	Square_D8: INTEGER is 60;
	Square_F1: INTEGER is 6;
	Square_F8: INTEGER is 62;

	-- King starting locations
	Square_E1: INTEGER is 5;
	Square_E8: INTEGER is 61;

feature -- Status Report

	valid_square(s: INTEGER): BOOLEAN is
	do
		Result := (s >= Min_square) and (s <= Max_square)
	end

	valid_rank(r: INTEGER): BOOLEAN is
	do
		Result := (r >= Min_rank) and (r <= Max_rank)
	end

	valid_file(f: INTEGER): BOOLEAN is
	do
		Result := (f >= Min_file) and (f <= Max_file)
	end

	get_rank(s: INTEGER): INTEGER is
	require
		valid_square(s)
	do
		Result := ((s-1) // Max_rank) + 1;
	ensure
		valid_rank(Result)
	end

	get_file(s: INTEGER): INTEGER is
	require
		valid_square(s)
	do
		Result := ((s-1) \\ Max_file)+1;
	ensure
		valid_file(Result)
	end

	get_square(file, rank: INTEGER): INTEGER is
	require
		valid_file(file) and valid_rank(rank)
	do
		Result := ((rank-1) * Rank_count) + file;
	ensure
		valid_square(Result)
	end

	square_to_string(square: INTEGER): STRING is
		-- Convert square to string, e.g. "h8", "d4", "a1"
	require
		valid_square(square)
	do
		Result := file_to_string( get_file(square) )
				+ rank_to_string( get_rank(square) );
		
	ensure
		Result /= Void and then Result.count = 2
	end

	rank_to_string(rank: INTEGER): STRING is
		-- Convert rank constant to string, e.g. "1", "2", ... "8"
	require
		valid_rank(rank)
	do
		Result := rank.out;
	ensure
		Result /= Void and then Result.count = 1
	end

	file_to_string(file: INTEGER): STRING is
		-- Convert file constant to string, e.g. "a", "b", ... "h"
	require
		valid_file(file)
	do
		inspect file
		when File_a then
			!! Result.make_from_string("a");
		when File_b then
			!! Result.make_from_string("b");
		when File_c then
			!! Result.make_from_string("c");
		when File_d then
			!! Result.make_from_string("d");
		when File_e then
			!! Result.make_from_string("e");
		when File_f then
			!! Result.make_from_string("f");
		when File_g then
			!! Result.make_from_string("g");
		when File_h then
			!! Result.make_from_string("h");
		end
	ensure
		Result /= Void and then Result.count = 1
	end

end
