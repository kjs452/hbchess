indexing
	description:	"Describes the complex movements for a chess square"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

--
-- King's, Pawns, and Knights have movements that are more complex
-- than the sliding pieces. So this class is used to organize
-- the complex pieces.
--
deferred class CHESS_PATH_COMPLEX
inherit
	CHESS_PATH

	ARRAY[ INTEGER ]
	rename
		make as ar_make
	export
		{NONE} all
	undefine
		copy, is_equal
	end

feature -- Access
	length: INTEGER is
	do
		Result := count;
	end

end
