indexing
	description:	"a modal dialog allowing the users %
			% nickname to be changed"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

--
-- This simple dialog allows the user to edit his
-- current nickname.
--
--
class NICKNAME_DIALOG
inherit
	WEL_MODAL_DIALOG
	redefine
		on_ok, on_show, on_cancel
	end

	CHESS_APP_CONSTANTS

creation
	make

feature -- Initialization
	make(a_parent: CHESS_MAIN_WINDOW) is
	do
		make_by_id(a_parent, Dlg_change_nickname);

		!! nickname_edit.make_by_id(Current, Cnn_nickname_edit);
	end

feature -- Access
	form_data: STRING;

feature -- Element Change
	set_form_data(n: STRING) is
	require
		n /= Void;
	do
		form_data := n;
	end

feature {NONE} -- Event processing
	on_show is
	do
		nickname_edit.set_text( form_data );
		nickname_edit.set_focus;
		nickname_edit.select_all;
	end

	on_cancel is
	do
		terminate(idcancel);
	end

	on_ok is
	do
		form_data := clean_nickname( nickname_edit.text );
		terminate(idok);
	end

feature {NONE} -- controls
	nickname_edit: WEL_SINGLE_LINE_EDIT;

	Default_nickname: STRING is "player";
	Max_nickname_length: INTEGER is 8;

	clean_nickname(str: STRING): STRING is
		-- Remove all character except:
		--	letters
		--	numbers
		--	underscore
		-- truncate to 16 characters
		-- empty string will be converted
		-- to 'player'
	require
		str /= Void;
	local
		i: INTEGER;
		c: CHARACTER;
	do
		!! Result.make(10);

		-- copy 'str' to 'Result', but ignore
		-- all invalid characters
		from
			i := 1;
		until
			i > str.count
		loop
			c := str.item(i);
			if c.is_alpha or c.is_digit or c = '_' then
				Result.append_character(c);
			end

			i := i + 1;
		end

		if Result.count = 0 then
			Result.append_string(Default_nickname);
		else
			Result.keep_head(Max_nickname_length);
		end
	ensure
		Result /= Void;
	end

end
