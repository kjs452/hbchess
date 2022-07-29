indexing
	description:	"(Parent class for several children)%
			% Describes a 'ray' or path of chess board squares%
			% from one point to another"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

--
-- A chess_path is an array of squares (integers in the range 1..64).
-- This being the parent class, has subclasses for straight paths, diagonal
-- paths, knight paths, etc...
--
-- The purpose of these paths is to decompose the movements of chess pieces
-- for quickly doing these 2 things:
--	1. Move generation:
--		a. Generate CHESS_MOVE's for a given path.
--		b. Detect squares along path that are blocked by our pieces.
--		c. Detect squares along path that contain enemy pieces (and
--		   can be captured)
--		   
--	2. Attack detection: the main purpose of this is to quickly determine if
--	   the king is under attack. It helps answer the fundamental chess
--	   question, "Are we in check?")
--
-- Chess paths are bundled into CHESS_PATH_LIST's and then they ultimately
-- are attached to the CHESS_MOVE_TABLE and CHESS_ATTACK_TABLE.
--
-->>>	CHESS_PATH*	<<<
--		CHESS_PATH_LIST
--		CHESS_PATH_SLIDE*
--			CHESS_PATH_DIAGONAL*
--				describes queen, bishop moves
--				CHESS_PATH_DIAGONAL_NE (north-east)
--				CHESS_PATH_DIAGONAL_SE (south-east)
--				CHESS_PATH_DIAGONAL_SW (south-west)
--				CHESS_PATH_DIAGONAL_NW (north-west)
--			CHESS_PATH_STRAIGHT*
--				describes queen, rook moves
--				CHESS_PATH_STRAIGHT_N (north)
--				CHESS_PATH_STRAIGHT_S (south)
--				CHESS_PATH_STRAIGHT_E (east)
--				CHESS_PATH_STRAIGHT_W (west)
--		CHESS_PATH_COMPLEX*
--			CHESS_PATH_KING
--				CHESS_PATH_CASTLE
--			CHESS_PATH_KNIGHT
--				describes knight moves
--			CHESS_PATH_PAWN
--				CHESS_PATH_PAWN_CAPTURE
--					CHESS_PATH_PAWN_EP
--
-- Classes with '*' next to them are abstract.
--
-- NOTE: A very cool and elegant use of multiple inheritance is
-- expressed by the fact that CHESS_PATH_LIST inherits from CHESS_PATH
--
--

deferred class CHESS_PATH
inherit
	CHESS_GENERAL_CONSTANTS
	CHESS_SQUARE_CONSTANTS
	CHESS_PIECE_CONSTANTS
	CHESS_MOVE_CONSTANTS

feature -- Access
	--
	-- Number of squares involved in the path
	-- Path is empty of length is 0.
	--
	length: INTEGER is
	deferred
	end

feature -- Status Report

	generate_moves(cp: CHESS_POSITION; square, piece: INTEGER;
				mq, cq: CHESS_MOVE_QUEUE) is
		--
		-- Generate all moves along path.
		--
		-- generate all moves from 'square' for 'piece'.
		--
		-- Fill queues with the moves:
		--	cq (capture queue), contains captures, promotions and castlings
		--	mq (move queue), contains all regular moves
		--
		-- If a queue is Void, then don't generate those kinds of moves.
	require
		cp /= Void;
		cp.occupied(square);
		valid_square(square);
		valid_piece(piece);
		cp.get_piece(square) = piece;
	deferred
	end

	under_attack(cp: CHESS_POSITION; side: INTEGER): BOOLEAN is
		-- Follow this path from beginning to end and
		-- locate a piece of color 'side' that
		-- is able to attack along this path.
		--
		-- For diagonal paths: bishops, kings, and queens
		-- can attack
		--
		-- For straight paths: rooks, queens and kings can attack.
		--
		-- For knight paths: look for knights of 'side' color.
		--
		-- For pawn_capture paths: look for pawns of 'side' color.
	require
		cp /= Void;
		valid_piece_color(side);
	do
		--
		-- Only CHESS_PATH_LIST, CHESS_PATH_SLIDE
		-- and CHESS_PATH_KNIGHT implement this feature.
		--
		check
			False;
		end
	end

	attacking_squares(cp: CHESS_POSITION; side: INTEGER): LINKED_LIST[INTEGER] is
		--
		-- Returns a list of squares (containing enemy pieces)
		-- that is attacking this square.
		--
		-- (Limitation: Does not detect if square is under attack
		-- due to an e.p. capture.)
		--
		-- This limitation doesn't effect our chess engine, since attack
		-- detection is used for determining if the king is in check, and
		-- the e.p. capture can only threaten pawns, not kings.
		--
	require
		cp /= Void;
		valid_piece_color(side);
	do

		check
		--
		-- Because only some CHESS_PATH's are
		-- employed in attack square detection.
		-- The only CHESS_PATH's that are used
		-- for attack detection are the following:
		-- 	PATH_LIST, PATH_SLIDE and PATH_KNIGHT
		--
			False;
		end
	ensure
		Result /= Void;
	end

feature -- Status Setting
feature -- Element Change
feature -- Removal
feature {NONE} -- Implementation

end
