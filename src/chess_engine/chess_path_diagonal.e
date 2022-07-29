indexing
	description:	"Describes a series of chess squares along a diagonal"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

deferred class CHESS_PATH_DIAGONAL
inherit
	CHESS_PATH_SLIDE

feature {NONE} -- Implementation

	attacking_piece_type: INTEGER is
		-- Aside from queen this is the other major piece
		-- that can attack along a diagonal.
	do
		Result := Piece_type_bishop;
	end

end
