indexing
	description:	"list of LINK data and their locations in%
			% CHESS_GUI_CHAT_OUTPUT"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

class CHESS_GUI_CHAT_LINKDB
inherit
	LINKED_LIST[ CHESS_GUI_CHAT_LINKDB_ITEM ]
	export
		{ANY} make, wipe_out
		{NONE} all
	end

creation
	make

feature -- Access
	link_data: CHESS_GUI_CHAT_LINK;

feature -- Status Report
	contains(position: INTEGER): BOOLEAN is
		-- does the LINKDB contiain a link for 'position'?
		-- If it does, then link_data will be set.
	local
		done: BOOLEAN;
	do
		from
			Result := False;
			done := False;
			start;
		until
			off or done
		loop
			if position >= item.start_position and
					position <= item.end_position
			then
				done := True;
				link_data := item.link_data;
				Result := True;
			elseif position > item.end_position then
				done := True;
			end

			forth;
		end

	ensure
		(Result) implies link_data /= Void;
	end

feature -- Element Change
	add(start_pos, end_pos: INTEGER; a_link_data: CHESS_GUI_CHAT_LINK) is
	require
		a_link_data /= Void;
	local
		link_item: CHESS_GUI_CHAT_LINKDB_ITEM;
	do
		!! link_item.make(start_pos, end_pos, a_link_data);
		put_front(link_item);
	end

end

