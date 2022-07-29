indexing
	description:	"history list of a chess game"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

--
-- Game history contains all the moves for each side, including
-- the complete state of the chess board BEFORE each move
--
-- This list allows us to display a list of moves in the game,
-- and undo/redo moves.
--

class CHESS_GAME_HISTORY
inherit
	LINKED_LIST[ CHESS_GAME_HISTORY_ITEM ]
	rename
		make as lst_make,
		extend as lst_extend
	export
		{ANY} last, count, start, forth, item, off, wipe_out, i_th
		{NONE} all
	undefine
		is_equal, copy
	end

	CHESS_GENERAL_CONSTANTS
	CHESS_PIECE_CONSTANTS
	CHESS_SQUARE_CONSTANTS

creation
	make

feature -- Initialization
	make is
	do
		lst_make;
	end

feature -- Access

feature -- Status Report
	captures(side: INTEGER; ply: INTEGER): LINKED_LIST[ INTEGER ] is
		-- Return a list of captured pieces for 'side'
		-- upto (but not including) 'ply'
	require
		valid_piece_color(side);
		ply >= 1 and ply <= count;
	local
		ptype: INTEGER;
		p: INTEGER;
	do
		!! Result.make;

		from
			p := 1;
			start;
		until
			off or (p > ply)
		loop
			if item.move.side = side then
				if item.move.is_capture(item.board) then
					ptype := item.move.captured_piece(item.board);
					Result.extend(ptype);
				end
			end

			p := p + 1;
			forth;
		end

	ensure
		Result /= Void;
		-- each element of Result is a valid_piece_type
	end

feature -- Status Setting
feature -- Cursor Movement

feature -- Element Change
	record_move(board: CHESS_POSITION; mov: CHESS_MOVE) is
		-- create a history item and add it to end of history list
		-- (a copy of 'board' is generated)
	require
		board /= Void;
		mov /= Void;
		-- (last /= Void and then last.move.side /= mov.side)
	local
		hist_item: CHESS_GAME_HISTORY_ITEM;
		new_board: CHESS_POSITION;
	do
		new_board := deep_clone(board);
		!! hist_item.make(new_board, mov);
		lst_extend(hist_item);
	end

	extend(hi: CHESS_GAME_HISTORY_ITEM) is
		-- add a new history element to end of list
	do
		lst_extend(hi);
	end

feature -- Removal
	remove_last is
		-- remove last history item.
	require
		count > 0;
	do
		finish;
		remove;
	end

feature {NONE} -- Implementation
end
