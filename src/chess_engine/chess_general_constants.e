indexing
	description: "general chess constants"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

class CHESS_GENERAL_CONSTANTS

feature {NONE} -- Access
	-- Hash Random Seeds
	-- we initalize the random number generator with this value
	Hash_seed: INTEGER is 4321;

	--
	-- Each square is assigned 12 random values
	-- to represent the 12 chess piece types.
	-- That's 64 x 12 (768) random values.
	--
	-- A hash key for a board position is
	-- calculated by adding up all these
	-- random values.
	-- Typical case is (Hash_max/2) * (32 pieces)
	-- which should result in an integer small
	-- enough to fit into an 32-bit INTEGER.
	--
	Hash_min_value: INTEGER is  1_000_000;
	Hash_max_value: INTEGER is 50_000_000;

	--
	-- Transposition Table size (try to make this a prime #)
	-- (1,000,000 hash entries requires about 8MB of memory)
	--
	--Transposition_size: INTEGER is 131_077;
	--Transposition_size: INTEGER is 431_077;
	--Transposition_size: INTEGER is 711_973;
	Transposition_size: INTEGER is 1_000_777;

	--
	-- the repetition hash table size
	--
	Repetition_size: INTEGER is 2_137;

	--
	-- Types of transposition record values
	--
	Trans_type_exact: INTEGER is 0;
	Trans_type_alpha: INTEGER is 1;
	Trans_type_beta: INTEGER is 2;

	--
	-- Used to setup the search range for the alphabeta algorithm.
	--
	Infinity: INTEGER is 100_000;

feature -- Status Report
	valid_trans_type(typ: INTEGER): BOOLEAN is
	do
		Result :=	(typ = Trans_type_exact)
			or	(typ = Trans_type_alpha)
			or	(typ = Trans_type_beta);
	end

	valid_score(a_score: INTEGER): BOOLEAN is
	do
		Result := a_score >= -Infinity and a_score <= Infinity;
	end

end
