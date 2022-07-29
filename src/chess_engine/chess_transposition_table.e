indexing
	description:	"Caches the results from previous searches"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

--
-- This is a hash table of Transposition_hash_size elements.
-- We pre-allocate a TRANSPOSITION object for every slot.
-- We set the hash_lock_value to 0, so that the empty
-- slots don't match any possible position.
--
--
-- The data_table array stores several fields packed into a single
-- INTEGER. This stores move information for a chess position.
--
-- We want to remember:
--	1. hash_lock - to verify this is the valid entry and not a hash collision.
--	2. the calculated score
--	3. what depth level this score was obtained
--	4. A type associated with the calculated score:
--		Trans_type_exact:	An exact score
--		Trans_type_alpha:	A alpha score
--		Trans_type_beta:	A beta score
--
-- We pack several fields into a single INTEGER (assumed to be
-- 32-bits).
--
--         <---------    bits     ---------->
--         33222222222211111111 11000000 00 0
--         10987654321098765432 10987654 32 1
--
--	   vvvvvvvvvvvvvvvvvvvv dddddddd tt s
--
-- Fields:
--	'vvvvvvv'    = score (20-bits)   0 .. 100,000 (max value is about 1,000,000)
--	'dddddddd'   = depth (8-bits)   0..255
--	'tt'         = type (2-bits)    0, 1, 2
--	's'          = sign (1-bit)     +/-
--
-- Encoding/decoding formulas:
--	To get score:		score = data DIV (2*4*256)
--	To get depth:		depth = (data DIV (2*4)) MOD 256
--	To get type:		type  = (data DIV 2) MOD 4
--	To get sign:		sign  = data MOD 2
--
--	To set data:		data = ABS(score) * 256*4*2
--					+ depth * 4*2
--					+ type * 2
--					+ sign
--
-- (NOTE: sign will be '1' when score is negative, and 0 else.)
--
--

class CHESS_TRANSPOSITION_TABLE
inherit
	CHESS_GENERAL_CONSTANTS
	CHESS_PIECE_CONSTANTS

creation
	make

feature -- Initialization
	make is
	do
		!! lock_table.make(1, Transposition_size);
		!! data_table.make(1, Transposition_size);
		clear;
	end

	set_position(a_cp: CHESS_POSITION) is
	require
		a_cp /= Void;
	do
		cp := a_cp;

		-- BUG!!! some wierd crashes are encountered during
		-- end-game if we DO NOT clear after each search. But
		-- I cannot reproduce. It seems to work right now, but
		-- I am leaving the following line disabled, to see if
		-- I can cause this bug to occur.

		-- In theory the transposition table can be preserved
		-- between calls to "CHESS_SEARCH.find_best_move"

		-- this mysterious crashing has not been detected for
		-- a while, and the bug, if it still exists, may
		-- not be related to this.

		-- clear;
	end

feature -- Access
	last_score: INTEGER;

	probe(a_depth, alpha, beta: INTEGER) is
		-- find a matching transposition entry, and compute
		-- a proper score based on alpha and beta
		-- If 'found' is set, then we have a found
		-- a matching item, and 'last_score' is set to
		-- the computed score.
	local
		h: INTEGER;
	do
		found := False;
		h := table_index(cp.hash_key);

		if lock_table.item(h) = cp.hash_lock_key then

			decode_data( data_table.item(h) );

			if depth >= a_depth then
				if (ttype = Trans_type_exact) then
					last_score := score;
					found := True;

				elseif (ttype = Trans_type_alpha)
						and then (score <= alpha)
				then
					last_score := alpha;
					found := True;

				elseif (ttype = Trans_type_beta)
						and then (score >= beta)
				then
					last_score := beta;
					found := True;

				end

				if found then
					num_lookups := num_lookups + 1;
				end
			end

		elseif lock_table.item(h) /= 0 then
			num_collisions := num_collisions + 1;
		end
	end

feature -- Element Change
	record(a_depth, a_score, a_ttype: INTEGER) is
		-- store an entry into the hash table
		-- overwrite any previous entry.
	require
		valid_trans_type(a_ttype);
	local
		h, data: INTEGER;
	do
		h := table_index(cp.hash_key);

		if lock_table.item(h) = 0 then
			slots_used := slots_used + 1;
		end

		lock_table.put(cp.hash_lock_key, h);

		data := encode_data(a_depth, a_score, a_ttype);
		data_table.put(data, h);
	end

feature -- Removal
	clear is
		-- clear all slots in the hash table
	local
		i: INTEGER;
	do
		from
			 i := lock_table.lower;
		until
			i > lock_table.upper
		loop
			lock_table.put(0, i);
			data_table.put(0, i);
			i := i + 1;
		end

		slots_used := 0;
		num_collisions := 0;
		num_lookups := 0;
	end

feature -- Status Report
	found: BOOLEAN;

	total_slots: INTEGER is
	once
		Result := Transposition_size;
	end

	slots_used: INTEGER;
	num_collisions: INTEGER;

	num_lookups: INTEGER;
		-- number of lookup that succeeded

feature -- Status Setting
feature {NONE} -- Implementation (routines)
	table_index(h: INTEGER): INTEGER is
	do
		Result := (h \\ Transposition_size) + 1;
	ensure
		(Result >= 1) and (Result <= Transposition_size);
	end

	decode_data(data: INTEGER) is
		-- decode the stuff packed into 'data' and
		-- set the fields:
		--	score
		--	depth
		--	ttype
	local
		sign_bit: INTEGER;
		abs_score: INTEGER;
	do
		sign_bit := (data \\ 2);
		abs_score := data // (256 * 4 * 2);

		if sign_bit = 0 then
			score := abs_score;
		else
			score := -abs_score;
		end

		depth := (data // (4 * 2)) \\ 256;

		ttype := (data // 2) \\ 4;
	end

	encode_data(a_depth, a_score, a_ttype: INTEGER): INTEGER is
		-- encode the fields:
		--	a_score
		--	a_depth
		--	a_ttype
		--
		-- Into a single INTEGER and return the result.
		--
	require
		valid_score(a_score);
		a_depth >= 0 and a_depth <= 255;
		valid_trans_type(a_ttype);
	local
		abs_score: INTEGER;
		sign_bit: INTEGER;
	do
		if a_score >= 0 then
			abs_score := a_score;
			sign_bit := 0;
		else
			abs_score := -a_score;
			sign_bit := 1;
		end

		Result := abs_score * 256 * 4 * 2
			+ a_depth * 4 * 2
			+ a_ttype * 2
			+ sign_bit;
	end

feature {NONE} -- Implementation (attributes)
	cp: CHESS_POSITION;
	lock_table: ARRAY[ INTEGER ];
	data_table: ARRAY[ INTEGER ];

	--
	-- decode_data will set these
	--
	score: INTEGER;
	ttype: INTEGER;
	depth: INTEGER;

end
