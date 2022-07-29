indexing
	description:	"Describes a series of chess squares along a diagonal"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

class CHESS_PATH_DIAGONAL_NE
inherit CHESS_PATH_DIAGONAL

creation
	make

feature {NONE} -- Implementation
	rank_offset: INTEGER is 1;
	file_offset: INTEGER is 1;
end
