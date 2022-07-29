indexing
	description:	"list of predefined group-id's and their names"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

--
-- This class consists of all the predefined group-id's.
-- There is also a linked_list of group-id's and group_name's, that
-- we use to verify that the hotbabe_chess.dat file contains
-- all the predefined groups.
--
-- This error checking is important because we don't want our
-- program to crash when hotbabe attempts to show and clip
-- and discovers the pre-defined group doesn't exist, or
-- doesn't have any video clips in it.
--
-- This ensures the data file will always have proper data
-- to our program, and means we don't have to do extensive
-- testing to verify the data file is correct.
--
-- To add a new predefined group:
--	1. add a new constant
--	(make sure it appears after Hg_lower and after Hg_upper)
--
--	2. Add new group to 'group_id_list'
--
-- Once this has been done, the data file must contain
-- such a group.
--
--
class HOTBABE_GROUP_CONSTANTS

feature {NONE} -- Access
	Hg_lower			: INTEGER is unique -- must be first

	--
	-- general behavior
	--
	Hg_nogame			: INTEGER is unique
	Hg_sitdown			: INTEGER is unique
	Hg_standup			: INTEGER is unique
	Hg_game_start			: INTEGER is unique
	Hg_game_continue		: INTEGER is unique
	Hg_game_end			: INTEGER is unique

	Hg_general_behavior		: INTEGER is unique
	Hg_player_winning1		: INTEGER is unique
	Hg_player_winning2		: INTEGER is unique
	Hg_hotbabe_winning1		: INTEGER is unique
	Hg_hotbabe_winning2		: INTEGER is unique
	Hg_hotbabe_thinking		: INTEGER is unique

	--
	-- misc. behavior for when player does something
	--
	Hg_nickname_taunt		: INTEGER is unique
	Hg_resign_taunt			: INTEGER is unique
	Hg_webcam_off			: INTEGER is unique
	Hg_webcam_on			: INTEGER is unique
	Hg_undo_taunt			: INTEGER is unique
	Hg_flip_board			: INTEGER is unique
	Hg_credits			: INTEGER is unique

	--
	-- game over groups
	--
	Hg_draw				: INTEGER is unique
	Hg_stalemate			: INTEGER is unique
	Hg_player_resigns		: INTEGER is unique
	Hg_player_wins			: INTEGER is unique
	Hg_hotbabe_wins			: INTEGER is unique

	--
	-- Behavior when player moves
	--
	Hg_player_checks		: INTEGER is unique
	Hg_player_captures_queen	: INTEGER is unique
	Hg_player_captures_rook		: INTEGER is unique
	Hg_player_captures_bishop	: INTEGER is unique
	Hg_player_captures_knight	: INTEGER is unique
	Hg_player_captures_pawn		: INTEGER is unique
	Hg_player_castles		: INTEGER is unique
	Hg_player_promotes		: INTEGER is unique
	Hg_player_ep_captures		: INTEGER is unique
	Hg_player_moves			: INTEGER is unique

	--
	-- Behavior when hotbabe moves
	--
	Hg_hotbabe_checks		: INTEGER is unique
	Hg_hotbabe_captures_queen	: INTEGER is unique
	Hg_hotbabe_captures_rook	: INTEGER is unique
	Hg_hotbabe_captures_bishop	: INTEGER is unique
	Hg_hotbabe_captures_knight	: INTEGER is unique
	Hg_hotbabe_captures_pawn	: INTEGER is unique
	Hg_hotbabe_castles		: INTEGER is unique
	Hg_hotbabe_promotes		: INTEGER is unique
	Hg_hotbabe_ep_captures		: INTEGER is unique
	Hg_hotbabe_moves		: INTEGER is unique

	--
	-- predefined text messages
	--
	Hg_start_help			: INTEGER is unique
	Hg_save_game			: INTEGER is unique
	Hg_save_error			: INTEGER is unique
	Hg_load_game			: INTEGER is unique
	Hg_load_error			: INTEGER is unique
	Hg_resign_confirmation		: INTEGER is unique
	Hg_statistics			: INTEGER is unique
	Hg_change_nickname		: INTEGER is unique
	Hg_request_hint			: INTEGER is unique
	Hg_issue_hint			: INTEGER is unique
	Hg_about			: INTEGER is unique

	Hg_help				: INTEGER is unique
	Hg_help1			: INTEGER is unique
	Hg_help2			: INTEGER is unique
	Hg_help3			: INTEGER is unique
	Hg_help4			: INTEGER is unique
	Hg_help5			: INTEGER is unique
	Hg_help6			: INTEGER is unique
	Hg_help7			: INTEGER is unique
	Hg_help8			: INTEGER is unique
	Hg_help9			: INTEGER is unique
	Hg_help10			: INTEGER is unique
	Hg_help11			: INTEGER is unique
	Hg_help12			: INTEGER is unique
	Hg_help13			: INTEGER is unique
	Hg_help14			: INTEGER is unique
	Hg_help15			: INTEGER is unique
	Hg_help16			: INTEGER is unique
	Hg_help17			: INTEGER is unique
	Hg_help18			: INTEGER is unique
	Hg_help19			: INTEGER is unique
	Hg_help20			: INTEGER is unique
	Hg_help21			: INTEGER is unique
	Hg_help22			: INTEGER is unique
	Hg_help23			: INTEGER is unique
	Hg_help24			: INTEGER is unique
	Hg_help25			: INTEGER is unique
	Hg_easter_egg			: INTEGER is unique

	Hg_upper			: INTEGER is unique; -- must be last

	group_list: HOTBABE_GROUP_LIST is
		-- a complete list of all group_id's and the
		-- corresponding strings
		--
		-- This list also indicates if the group
		-- requires text/clips data
		--
		-- These strings are converted to group names and used
		-- to search the .dat file.
		--
	local
		lst: HOTBABE_GROUP_LIST;
	once
		!! lst.make;
		Result := lst;

		--
		-- general behavior
		--
		lst.put(Hg_nogame, "nogame", False, True);
		lst.put(Hg_sitdown, "sitdown", False, True);
		lst.put(Hg_standup, "standup", False, True);
		lst.put(Hg_game_start, "game_start", False, True);
		lst.put(Hg_game_continue, "game_continue", False, True);
		lst.put(Hg_game_end, "game_end", False, True);

		lst.put(Hg_general_behavior, "general_behavior", False, True);
		lst.put(Hg_player_winning1, "player_winning1", False, True);
		lst.put(Hg_player_winning2, "player_winning2", False, True);
		lst.put(Hg_hotbabe_winning1, "hotbabe_winning1", False, True);
		lst.put(Hg_hotbabe_winning2, "hotbabe_winning2", False, True);
		lst.put(Hg_hotbabe_thinking, "hotbabe_thinking", False, True);

		--
		-- misc. behavior for when player does something
		--
		lst.put(Hg_nickname_taunt, "nickname_taunt", False, True);
		lst.put(Hg_resign_taunt, "resign_taunt", False, True);
		lst.put(Hg_webcam_off, "webcam_off", False, True);
		lst.put(Hg_webcam_on, "webcam_on", False, True);
		lst.put(Hg_undo_taunt, "undo_taunt", False, True);
		lst.put(Hg_flip_board, "flip_board", False, True);
		lst.put(Hg_credits, "credits", False, True);

		--
		-- game over groups
		--
		lst.put(Hg_draw, "draw", False, True);
		lst.put(Hg_stalemate, "stalemate", False, True);
		lst.put(Hg_player_resigns, "player_resigns", False, True);
		lst.put(Hg_player_wins, "player_wins", False, True);
		lst.put(Hg_hotbabe_wins, "hotbabe_wins", False, True);

		--
		-- Behavior when player moves
		--
		lst.put(Hg_player_checks, "player_checks", False, True);
		lst.put(Hg_player_captures_queen, "player_captures_queen", False, True);
		lst.put(Hg_player_captures_rook, "player_captures_rook", False, True);
		lst.put(Hg_player_captures_bishop, "player_captures_bishop", False, True);
		lst.put(Hg_player_captures_knight, "player_captures_knight", False, True);
		lst.put(Hg_player_captures_pawn, "player_captures_pawn", False, True);
		lst.put(Hg_player_castles, "player_castles", False, True);
		lst.put(Hg_player_promotes, "player_promotes", False, True);
		lst.put(Hg_player_ep_captures, "player_ep_captures", False, True);
		lst.put(Hg_player_moves, "player_moves", False, True);

		--
		-- Behavior when hotbabe moves
		--
		lst.put(Hg_hotbabe_checks, "hotbabe_checks", False, True);
		lst.put(Hg_hotbabe_captures_queen, "hotbabe_captures_queen", False, True);
		lst.put(Hg_hotbabe_captures_rook, "hotbabe_captures_rook", False, True);
		lst.put(Hg_hotbabe_captures_bishop, "hotbabe_captures_bishop", False, True);
		lst.put(Hg_hotbabe_captures_knight, "hotbabe_captures_knight", False, True);
		lst.put(Hg_hotbabe_captures_pawn, "hotbabe_captures_pawn", False, True);
		lst.put(Hg_hotbabe_castles, "hotbabe_castles", False, True);
		lst.put(Hg_hotbabe_promotes, "hotbabe_promotes", False, True);
		lst.put(Hg_hotbabe_ep_captures, "hotbabe_ep_captures", False, True);
		lst.put(Hg_hotbabe_moves, "hotbabe_moves", False, True);

		--
		-- predefined text messages
		--
		lst.put(Hg_start_help, "start_help", True, False);
		lst.put(Hg_save_game, "save_game", True, False);
		lst.put(Hg_save_error, "save_error", True, False);
		lst.put(Hg_load_game, "load_game", True, False);
		lst.put(Hg_load_error, "load_error", True, False);
		lst.put(Hg_resign_confirmation, "resign_confirmation", True, False);
		lst.put(Hg_statistics, "statistics", True, False);
		lst.put(Hg_change_nickname, "change_nickname", True, False);
		lst.put(Hg_request_hint, "request_hint", True, False);
		lst.put(Hg_issue_hint, "issue_hint", True, False);
		lst.put(Hg_about, "about", True, False);
		lst.put(Hg_help, "help", True, False);

		lst.put(Hg_help1, "help1", True, False);
		lst.put(Hg_help2, "help2", True, False);
		lst.put(Hg_help3, "help3", True, False);
		lst.put(Hg_help4, "help4", True, False);
		lst.put(Hg_help5, "help5", True, False);
		lst.put(Hg_help6, "help6", True, False);
		lst.put(Hg_help7, "help7", True, False);
		lst.put(Hg_help8, "help8", True, False);
		lst.put(Hg_help9, "help9", True, False);
		lst.put(Hg_help10, "help10", True, False);
		lst.put(Hg_help11, "help11", True, False);
		lst.put(Hg_help12, "help12", True, False);
		lst.put(Hg_help13, "help13", True, False);
		lst.put(Hg_help14, "help14", True, False);
		lst.put(Hg_help15, "help15", True, False);
		lst.put(Hg_help16, "help16", True, False);
		lst.put(Hg_help17, "help17", True, False);
		lst.put(Hg_help18, "help18", True, False);
		lst.put(Hg_help19, "help19", True, False);
		lst.put(Hg_help20, "help20", True, False);
		lst.put(Hg_help21, "help21", True, False);
		lst.put(Hg_help22, "help22", True, False);
		lst.put(Hg_help23, "help23", True, False);
		lst.put(Hg_help24, "help24", True, False);
		lst.put(Hg_help25, "help25", True, False);

		lst.put(Hg_easter_egg, "ee", False, True);

	ensure
		-- list must be completely filled
		Result.is_filled;
	end

feature -- Status Report
	valid_hotbabe_group_id(group_id: INTEGER): BOOLEAN is
	do
		Result := (group_id > Hg_lower) and (group_id < Hg_upper);
	end

end
