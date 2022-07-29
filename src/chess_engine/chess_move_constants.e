indexing
	description:	"Describes types of moves"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

--
-- These set of constants are associated
-- with every CHESS_MOVE object. Each of these constants
-- allows us to quickly figure out what kind of move we are
-- dealing with.
--
-- Move_qrook, Move_krook, Move_king allows us
-- to quickly determine if castling rights have been affected
--
--
class CHESS_MOVE_CONSTANTS

feature {NONE} -- Access
	Move_not_specified: INTEGER is 0;

	Move_normal: INTEGER is 1;
	Move_king: INTEGER is 2;
	Move_qrook: INTEGER is 3;
	Move_krook: INTEGER is 4;
	Move_pawn: INTEGER is 5;
	Move_pawn_ep: INTEGER is 6;
	Move_pawn_double: INTEGER is 7;
	Move_pawn_promote_q: INTEGER is 8;
	Move_pawn_promote_r: INTEGER is 9;
	Move_pawn_promote_b: INTEGER is 10;
	Move_pawn_promote_n: INTEGER is 11;
	Move_castle_kingside: INTEGER is 12;
	Move_castle_queenside: INTEGER is 13;

feature -- Status Report
	valid_move_type(t: INTEGER): BOOLEAN is
	do
		Result := (t >= Move_normal) and (t <= Move_castle_queenside);
	end
end
