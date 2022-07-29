indexing
	description:	"a modal dialog allowing the developer %
			% to manipulate the HOTBABE event queue %
			% and debug the video clips, and text %
			% messages that are in the hotbabe_chess.dat file"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

--
-- This dialog is launched from the HELP menu item, only
-- when DEBUG mode is enabled in the hotbabe_chess.dat file.
--
-- This dialog lets the developer construct a list of
-- HOTBABE_EVENT's and manipulate thier order. When
-- the developer hits the 'OK' button, the
-- list of events will be inserted into the
-- hotbabe queue.
--
-- (NOTE: The user will never see this dialog)
--
-- The feature 'make_all_lists' builds the
-- event list and the events name list. Make
-- sure you keep this list updated.
--
--
class DEBUG_DIALOG
inherit
	WEL_MODAL_DIALOG
	redefine
		on_ok, on_show, on_cancel, notify
	end

	CHESS_APP_CONSTANTS

creation
	make

feature -- Initialization
	make(a_parent: CHESS_MAIN_WINDOW) is
	do
		make_by_id(a_parent, Dlg_debug);

		!! queue_lst.make_by_id(Current, Dbg_queue_lst);
		!! all_lst.make_by_id(Current, Dbg_all_lst);
		!! add_but.make_by_id(Current, Dbg_add_but);
		!! remove_but.make_by_id(Current, Dbg_remove_but);
		!! up_but.make_by_id(Current, Dbg_up_but);
		!! down_but.make_by_id(Current, Dbg_down_but);

		make_all_lists;

		form_data := Void;
		saved_copy := Void;
	end

feature -- Access
	form_data: LINKED_LIST[ HOTBABE_EVENT ];

feature -- Element Change
feature {NONE} -- Event processing
	on_show is
	do
		fill_dialog;
	end

	on_cancel is
	do
		form_data := Void;
		terminate(idcancel);
	end

	on_ok is
	do
		form_data := read_queue_list;
		saved_copy := form_data;
		terminate(idok);
	end

feature {NONE} -- implementation (routines)
	notify(control: WEL_CONTROL; notify_code: INTEGER) is
	local
		idx: INTEGER;
		str: STRING;
	do
		if control = add_but then
			-- add all_list selection to queue_list
			if all_lst.selected then
				if queue_lst.selected then
					idx := queue_lst.selected_item;

					queue_lst.insert_string_at(
						all_lst.selected_string, idx+1);
					queue_lst.select_item( idx+1 );

				else
					queue_lst.insert_string_at(
						all_lst.selected_string,
						queue_lst.count); 

					queue_lst.select_item( queue_lst.count-1 );
				end
			end

		elseif control = remove_but then
			if queue_lst.selected then
				idx := queue_lst.selected_item;
				queue_lst.delete_string( queue_lst.selected_item );

				if idx >= 0 and idx < queue_lst.count then
					queue_lst.select_item(idx);
				elseif queue_lst.count > 0 then
					queue_lst.select_item(queue_lst.count-1);
				end
			end

		elseif control = up_but then
			if queue_lst.selected then
				idx := queue_lst.selected_item;
				if idx > 0 then
					str := queue_lst.selected_string;
					queue_lst.delete_string( idx );
					queue_lst.insert_string_at(str, idx-1);
					queue_lst.select_item(idx-1);
				end
			end

		elseif control = down_but then
			if queue_lst.selected then
				idx := queue_lst.selected_item;
				if idx < queue_lst.count-1 then
					str := queue_lst.selected_string;
					queue_lst.delete_string( idx );
					queue_lst.insert_string_at(str, idx+1);
					queue_lst.select_item(idx+1);
				end
			end

		end
	end

	-----------------------------------------------------
	--
	-- ADD NEW EVENTS HERE
	--
	-----------------------------------------------------
	make_all_lists is
		-- build the lists 'all_events' and 'all_names'
	local
		e: HOTBABE_EVENT;
	do
		!! all_events.make;
		!! all_names.make;

		!HOTBABE_EVENT_DEFAULT! e.make;
		extend_lists(e, "DEFAULT");

		!HOTBABE_EVENT_SITDOWN! e.make;
		extend_lists(e, "SITDOWN");

		!HOTBABE_EVENT_STANDUP! e.make;
		extend_lists(e, "STANDUP");

		!HOTBABE_EVENT_GAME_START! e.make;
		extend_lists(e, "GAME_START");

		!HOTBABE_EVENT_GAME_END! e.make;
		extend_lists(e, "GAME_END");

		!HOTBABE_EVENT_CREDITS! e.make;
		extend_lists(e, "CREDITS");

		!HOTBABE_EVENT_THINKING! e.make;
		extend_lists(e, "THINKING");

		!HOTBABE_EVENT_WEBCAM_CHANGED! e.make(False);
		extend_lists(e, "WEBCAM (off)");

		!HOTBABE_EVENT_WEBCAM_CHANGED! e.make(True);
		extend_lists(e, "WEBCAM (on)");

		!HOTBABE_EVENT_NICKNAME_TAUNT! e.make;
		extend_lists(e, "NICKNAME_TAUNT");

		!HOTBABE_EVENT_FLIP_BOARD! e.make;
		extend_lists(e, "FLIP_BOARD");

		!HOTBABE_EVENT_RESIGN_TAUNT! e.make;
		extend_lists(e, "RESIGN_TAUNT");

		!HOTBABE_EVENT_UNDO_TAUNT! e.make;
		extend_lists(e, "UNDO_TAUNT");

		!HOTBABE_EVENT_PLAYER_WINS! e.make;
		extend_lists(e, "PLAYER_WINS");

		!HOTBABE_EVENT_DRAW! e.make;
		extend_lists(e, "DRAW");

		!HOTBABE_EVENT_HOTBABE_WINS! e.make;
		extend_lists(e, "HOTBABE_WINS");

		!HOTBABE_EVENT_PLAYER_RESIGNS! e.make;
		extend_lists(e, "PLAYER_RESIGNS");

		!HOTBABE_EVENT_STALE_MATE! e.make;
		extend_lists(e, "STALE_MATE");

		!HOTBABE_EVENT_CHECKS! e.make(True);
		extend_lists(e, "hCHECKS");

		!HOTBABE_EVENT_CASTLES! e.make(True);
		extend_lists(e, "hCASTLES");

		!HOTBABE_EVENT_EP_CAPTURES! e.make(True);
		extend_lists(e, "hEP_CAPTURES");

		!HOTBABE_EVENT_PROMOTES! e.make(True);
		extend_lists(e, "hPROMOTES");

		!HOTBABE_EVENT_CAPTURES_QUEEN! e.make(True);
		extend_lists(e, "hCAPTURES_QUEEN");

		!HOTBABE_EVENT_CAPTURES_ROOK! e.make(True);
		extend_lists(e, "hCAPTURES_ROOK");

		!HOTBABE_EVENT_CAPTURES_BISHOP! e.make(True);
		extend_lists(e, "hCAPTURES_BISHOP");

		!HOTBABE_EVENT_CAPTURES_KNIGHT! e.make(True);
		extend_lists(e, "hCAPTURES_KNIGHT");

		!HOTBABE_EVENT_CAPTURES_PAWN! e.make(True);
		extend_lists(e, "hCAPTURES_PAWN");

		!HOTBABE_EVENT_NORMAL! e.make(True);
		extend_lists(e, "hNORMAL");

		!HOTBABE_EVENT_CHECKS! e.make(False);
		extend_lists(e, "pCHECKS");

		!HOTBABE_EVENT_CASTLES! e.make(False);
		extend_lists(e, "pCASTLES");

		!HOTBABE_EVENT_EP_CAPTURES! e.make(False);
		extend_lists(e, "pEP_CAPTURES");

		!HOTBABE_EVENT_PROMOTES! e.make(False);
		extend_lists(e, "pPROMOTES");

		!HOTBABE_EVENT_CAPTURES_QUEEN! e.make(False);
		extend_lists(e, "pCAPTURES_QUEEN");

		!HOTBABE_EVENT_CAPTURES_ROOK! e.make(False);
		extend_lists(e, "pCAPTURES_ROOK");

		!HOTBABE_EVENT_CAPTURES_BISHOP! e.make(False);
		extend_lists(e, "pCAPTURES_BISHOP");

		!HOTBABE_EVENT_CAPTURES_KNIGHT! e.make(False);
		extend_lists(e, "pCAPTURES_KNIGHT");

		!HOTBABE_EVENT_CAPTURES_PAWN! e.make(False);
		extend_lists(e, "pCAPTURES_PAWN");

		!HOTBABE_EVENT_NORMAL! e.make(False);
		extend_lists(e, "pNORMAL");

	ensure
		all_events.count = all_names.count;
	end

	extend_lists(event: HOTBABE_EVENT; name: STRING) is
	require
		event /= Void;
		name /= Void;
	do
		--
		-- Make sure not duplicate event STRING's
		--
		from
			all_names.start;
		until
			all_names.off
		loop
			if name.is_equal(all_names.item) then
				check
					-- because duplicates are not allowed
					False;
				end
			end

			all_names.forth;
		end

		all_events.extend(event);
		all_names.extend(name);
	end

	fill_dialog is
	local
		idx: INTEGER;
		str: STRING;
	do
		queue_lst.reset_content;
		all_lst.reset_content;

		from
			all_names.start;
		until
			all_names.off
		loop
			all_lst.add_string( all_names.item );
			all_names.forth;
		end

		if saved_copy /= Void then
			from
				idx := 0;
				saved_copy.start;
			until
				saved_copy.off
			loop
				str := find_name_from_event( saved_copy.item );
				queue_lst.insert_string_at(str, idx);

				idx := idx + 1;
				saved_copy.forth;
			end
		end
	end

	read_queue_list: LINKED_LIST[ HOTBABE_EVENT ] is
		-- read the queue list control, and fill form_data
	local
		i: INTEGER;
		str: STRING;
		e: HOTBABE_EVENT;
	do
		!! Result.make;

		from
			i := 0;
		until
			i >= queue_lst.count
		loop
			str := queue_lst.i_th_text(i);

			e := find_event_from_name(str);

			Result.extend(e);

			i := i + 1;
		end
	ensure
		Result /= Void;
		Result.count = queue_lst.count;
	end

	find_event_from_name(str: STRING): HOTBABE_EVENT is
	require
		str /= Void;
	local
		found: BOOLEAN;
	do
		from
			all_events.start;
			all_names.start;
		until
			all_names.off or found
		loop
			if all_names.item.is_equal(str) then
				found := True;
				Result := all_events.item;
			end
			all_names.forth;
			all_events.forth;
		end
	ensure
		Result /= Void;
	end

	find_name_from_event(event: HOTBABE_EVENT): STRING is
	require
		event /= Void;
	local
		found: BOOLEAN;
	do
		from
			all_events.start;
			all_names.start;
		until
			all_names.off or found
		loop
			if all_events.item.same_type(event) then
				found := True;
				Result := all_names.item;
			end
			all_names.forth;
			all_events.forth;
		end

	ensure
		Result /= Void;
	end

feature {NONE} -- implementation (controls/attributes)
	queue_lst: WEL_SINGLE_SELECTION_LIST_BOX;
	all_lst: WEL_SINGLE_SELECTION_LIST_BOX;
	add_but: WEL_PUSH_BUTTON;
	remove_but: WEL_PUSH_BUTTON;
	up_but: WEL_PUSH_BUTTON;
	down_but: WEL_PUSH_BUTTON;

	all_events: LINKED_LIST[ HOTBABE_EVENT ];
		-- list of all possible events

	all_names: LINKED_LIST[ STRING ];
		-- A name for each event, must correspond to 'all_events' ordering

	saved_copy: LINKED_LIST[ HOTBABE_EVENT ];
		-- list of queue events from last time this dialog was
		-- used.

end
