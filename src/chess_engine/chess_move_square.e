indexing
	description:	"Describes a square on the board. One of these objects%
			% exists for each square and piece 64x12"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

--
-- This object gives us information about a chess square
-- AND the kind of piece that may be on this square. The
-- kinds of info we store is:
--
--	HASH VALUES:	For producing unique keys for a chess position
--	SCORE:		What is the relative value of having a white pawn on F7?
--	SCORE_ENDGAME:	What is the relative value of having a white pawn on F7?
--	MOVE PATHS:	What are the possible moves from this square for a knight?
--
-- Many algorithms use this information:
--
--	1. Move generation: Generate all valid moves and captures for this square
--		and this piece
--	2. Transposition table: Use hash values to produce a hash key (and hash lock)
--	3. Evaluation: Use the 'score' attribute to compute a score for this
--		square and the piece that is on this square.
--
class CHESS_MOVE_SQUARE
inherit
	CHESS_SQUARE_CONSTANTS

creation
	make

feature -- Initialization
	make(square, hash1, hash2: INTEGER) is
	require
		valid_square(square);
	do
		hash_val := hash1;
		hash_lock_val := hash2;
		!! paths.make;
	end

feature -- Access
	hash_val: INTEGER;
	hash_lock_val: INTEGER;

	score: INTEGER;
	score_endgame: INTEGER;
	paths: CHESS_PATH_LIST;

feature -- Status Report
feature -- Status Setting

feature -- Element Change
	set_score(a_score, a_score_endgame: INTEGER) is
	do
		score := a_score;
		score_endgame := a_score_endgame;
	end

feature -- Removal
feature {NONE} -- Implementation

end
