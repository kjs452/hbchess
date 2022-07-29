indexing
	description:	"Contains the static tables that describe movements,%
			% and attack squares on a chess board"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"


--
-- Any class wanting access to these static tables, can inherit from
-- this class. (These tables are 'once' feautures)
--
-- The move table is indexed by square and piece (64x12)
-- The attack table is indexed by square only (1..64)
--
-- MOVE TABLES:
--	Given a square (1..64) and a piece (e.g. Piece_white_bishop)
--	we can obtain a CHESS_MOVE_SQUARE. This class gives us
--	all kinds of information, most importantly it gives us a list
--	of move path's (e.g. rays). These rays encode the range of
--	movements this piece is able to perform on that square.
--
--	This table also allows us to compute hash keys for chess positions,
--	and positional scoring for different pieces.
--
-- ATTACK TABLES:
--	Given a square (and a side-to-move), we can determine what opponent
--	pieces may be able to attack us. Indexing the attack table gives us
--	a list of MOVE_PATH's, which we can follow to see if an attacking
--	piece is present.
--
-- These tables are "once" and hence only created once per system.
--

class CHESS_BOARD_TABLES

feature {NONE} -- Access
	move_table: CHESS_MOVE_TABLE is
	once
		!! Result.make;
	end

	attack_table: CHESS_ATTACK_TABLE is
	once
		!! Result.make;
	end
end
