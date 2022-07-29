indexing
	description:	"history item of a chess game"

--
-- Game history contains all the moves for each side, including
-- the complete state of the chess board BEFORE each move
--

class CHESS_GAME_HISTORY_ITEM
inherit
	CHESS_GENERAL_CONSTANTS
	CHESS_PIECE_CONSTANTS
	CHESS_SQUARE_CONSTANTS

creation
	make

feature -- Initialization
	make(a_board: CHESS_POSITION; a_move: CHESS_MOVE) is
		-- 'board' and 'clock' before making 'move'
	require
		a_board /= Void;
		a_move /= Void;
	do
		board := a_board;
		move := a_move;
	end

feature -- Access
	board: CHESS_POSITION;
	move: CHESS_MOVE;

feature -- Status Report
feature -- Status Setting
feature -- Element Change
feature -- Removal
feature {NONE} -- Implementation

end
