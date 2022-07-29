indexing
	description:	"Describes a series of chess squares alone a file"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

class CHESS_PATH_STRAIGHT_S
inherit CHESS_PATH_STRAIGHT

creation
	make, make_with_type

feature {NONE} -- Implementation
	rank_offset: INTEGER is -1;
	file_offset: INTEGER is 0;
end
