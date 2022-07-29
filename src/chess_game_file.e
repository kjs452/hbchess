indexing
	description:	"class for saving/loading a chess game"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

--
-- THis class takes a filename and lets us LOAD or SAVE
-- a game.
--
-- LOADING A SAVED GAME:
-- This class returns an object CHESS_GAME that includes
-- the entire history of the game, plus the current
-- state of the board.
--
-- This class also returns the appropritate skill level in
-- a CHESS_GAME_OPTINONS class.
--
-- The original nickname of the player is also returned.
--
-- SAVING GAME:
-- We take a CHESS_GAME, CHESS_GAME_OPTIONS and player
-- nickname and write the whole sequence of moves and other
-- information to the file.
--
-- If an error happens during a save/load, then we
-- set the 'failed' attribute, and the 'error_message'
-- string will be set.
--
-- FILE FORMAT:
--	* Blank lines are ignored
--
--	* The first non-blank line is the player nickname
--	* The second non-blank line is the game options
--	* The remaining non-blank lines are a sequence of chess moves
--
-- NICKNAME FORMAT:
--	Nickname  joe
--
-- GAME OPTIONS FORMAT:
--	Options  60:5:y:B
--	Options  3:60:n:W
--
-- The first line means max_ply is 60, max_time is 5 seconds,
-- 'y' means we want to do a queiscent search, and the player
-- has selected 'black-pieces'.
--
-- The seocond line means max_ply=3, max_time=60 seconds, and the player
-- was first to move by playing white pieces 
--
-- CHESS MOVE FORMAT:
--	1) d2-d3,       e7-e6
--	2) b2-b3,       a7-a6
--	etc...
--	Resigned
--
-- The chess move's are shown in simplified algebraic notation.
-- Each line is a move number like "1)", "2)",  "3)", etc...
--
-- The last move in the history may contain only 1 move.
--
-- The list of moves must be consistent with the color of pieces that the
-- player has selected in the "options" line.
--
-- For example, if the player is black-pieces, then the next move to
-- make in the file MUST be black. And if the player is white-pieces, then
-- the next move to make must for white.
--
-- Parsing moves:
--	Moves are formatted thusly,
--
--	o-o		King side castle
--	o-o-o		Queen side castle
--	f1-e1		Normal move
--	f3xg4		capture move
--	a1-d1+		move with opponent in check
--	d1xd5+		capture with opponent in check
--	g2-g1 =Q	Pawn move & promotion
--	g2xf1 =N	Pawn capture & promotion
--	g2xf1+ =N	Pawn capture & promotion & opponent in check
--	g4xh3 e.p.	Pawn e.p. capture
--	g4xh3+ e.p.	Pawn e.p. capture
-- 
-- This is the same format used to display moves on the main window.
--
--

class CHESS_GAME_FILE
inherit
	CHESS_PIECE_CONSTANTS

creation
	make

feature -- Initialization
	make(a_filename: STRING) is
		-- create for saving/loading a chess game
		-- to 'a_filename'
	require
		a_filename /= Void;
	do
		filename := a_filename;
		failed := False;
		error_message := Void;
	end

	failed: BOOLEAN;
	error_message: STRING;

feature -- Access
	nickname: STRING;
	options: CHESS_GAME_OPTIONS;
	game: CHESS_GAME;
	resigned: BOOLEAN;

feature -- Basic operations
	load is
		-- Load a chess game from filename specified with 'make'
		-- When successful 'nickname', 'options' and 'game'
		-- will be set to the state of the game.
	local
		f: PLAIN_TEXT_FILE;
	do
		!! f.make(filename);
		if not f.exists then
			failed := True;
			error_message := "No such file: " + filename;
		elseif not f.is_readable then
			failed := True;
			error_message := "File is not readable: " + filename;
		else
			nickname := Void;
			options := Void;
			game := Void;
			f.open_read;
			parse_file(f);
			f.close;
		end
	ensure
		failed implies (error_message /= Void);
		not failed implies nickname /= Void;
		not failed implies options /= Void;
		not failed implies game /= Void;
	end

	save(g: CHESS_GAME; opts: CHESS_GAME_OPTIONS; nick: STRING; res: BOOLEAN) is
		-- save a game to the filename specified by 'make'
	require
		g /= Void;
		opts /= Void;
		nick /= Void;
	local
		f: PLAIN_TEXT_FILE;
	do
		-- shit cannot do much error checking here, just
		-- hopes it works

		-- KJS TODO: checking to do:
		-- 	1. Examine path leading up to filename and
		--	   check it exists
		--	2. Check if the file exists, then check to
		--	   see if it is writeable
		--	3. Check if directory is writeable.

		!! f.make(filename);
		if f.exists and then not f.is_writable then
			failed := True;
			error_message := "file is not writeable: " + filename;
		else
			f.open_write;

			write_header(f);
			write_nickname(f, nick);
			write_options(f, opts);
			write_game(f, g, res);
			write_trailer(f);

			f.close;
		end

	ensure
		failed implies (error_message /= Void);
	end

feature {NONE} -- Load game routines
	lineno: INTEGER;

	parse_file(f: PLAIN_TEXT_FILE) is
		-- read and parse the file.
	require
		f /= Void;
	local
		str: STRING;
		move_number: INTEGER;
	do
		resigned := False;
		!! game.make;

		from
			f.start;
			move_number := 0;
			lineno := 0;
		until
			failed or f.end_of_file
		loop
			f.read_line;
			str := f.last_string;
			str.left_adjust;
			str.right_adjust;
			 -- convert tabs to spaces
			str.replace_substring_all("%T", " ");

			lineno := lineno + 1;

			if str.count = 0 then
				-- blank line, ignore
			elseif is_options(str) then
				if options /= Void then
					parse_error("duplicate options");
				else
					parse_options(str);
				end

			elseif is_nickname(str) then
				if nickname /= Void then
					parse_error("duplicate nickname");
				else
					parse_nickname(str);
				end

			elseif is_move(str) then
				move_number := move_number + 1;
				parse_move(move_number, str);

			elseif is_resign(str) then
				resigned := True;

			else
				parse_error("syntax error");
			end

		end

		if not failed then
			if nickname = Void then
				parse_error("missing nickname");
			elseif options = Void then
				parse_error("missing options");
			elseif game = Void then
				--
				-- this is okay, an empty game can be saved
				-- we just create a blank game object
				--
			end
		else
			nickname := Void;
			options := Void;
			game := Void;
		end
	end

	parse_error(s: STRING) is
	require
		s /= Void;
	do
		failed := True;
		error_message := filename
			+ ", Line: "
			+ lineno.out
			+ ", "
			+ s;
	ensure
		failed;
		error_message /= Void;
	end

	is_options(str: STRING): BOOLEAN is
	require
		str /= Void;
	local
		ss: STRING;
		num_colon: INTEGER;
	do
		num_colon := str.occurrences(':');
		ss := str.substring(1, Options_keyword.count);
		ss.to_upper;
		Result := ss.is_equal(Options_keyword) and (num_colon = 3);
	end

	is_nickname(str: STRING): BOOLEAN is
		-- does the string 'str' begin with
		-- the letters "nickname"
	require
		str /= Void;
	local
		ss: STRING;
	do
		ss := str.substring(1, Nickname_keyword.count);
		ss.to_upper;
		Result := ss.is_equal(Nickname_keyword);
	end

	is_resign(str: STRING): BOOLEAN is
		-- does the string 'str' equal "Resigned"
	require
		str /= Void;
	local
		ss: STRING;
	do
		!! ss.make_from_string(str);
		ss.to_upper;
		Result := ss.is_equal(Resigned_keyword);
	end

	is_move(str: STRING): BOOLEAN is
	require
		str /= Void;
	local
		num_paren, num_comma: INTEGER;
	do
		num_paren := str.occurrences( ')' );
		num_comma := str.occurrences( ',' );

		Result := (num_paren = 1) and (num_comma = 1);
	end

	parse_nickname(str: STRING) is
	require
		str /= Void;
		is_nickname(str);
	local
		idx: INTEGER;
	do
		idx := str.index_of(' ', 1);
		if idx = 0 then
			parse_error("nickname syntax error");
		else
			nickname := str.substring(idx, str.count);
			nickname.left_adjust;
			nickname.right_adjust;
		end

	ensure
		not failed implies (nickname /= Void);
	end

	parse_options(str: STRING) is
	require
		str /= Void;
		is_options(str);
	local
		lst: LIST[ STRING ];
		idx: INTEGER;
		arg_string: STRING;
		opts: CHESS_GAME_OPTIONS;
		val: INTEGER;
	do
		!! opts.make

		idx := str.index_of(' ', 1);
		if idx = 0 then
			parse_error("syntax error in options");
		else
			arg_string := str.substring(idx+1, str.count);
			arg_string.left_adjust;
			arg_string.right_adjust;

			lst := arg_string.split(':');

			if lst.count /= 4 then
				parse_error("missing values in options");

			elseif not lst.i_th(1).is_integer then
				parse_error("1st arg, max_ply is not an integer");

			elseif not lst.i_th(2).is_integer then
				parse_error("2nd arg, max_time is not an integer");

			elseif lst.i_th(3).count /= 1 then
				parse_error("3rd arg, invalid wantq_search value");

			elseif lst.i_th(4).count /= 1 then
				parse_error("4th arg, invalid side-color value");
			end

			if not failed then
				val := lst.i_th(1).to_integer;
				if val >= 2 then
					opts.set_max_ply(val);
				else
					parse_error("max_ply too small (<= 1)");
				end
			end

			if not failed then
				val := lst.i_th(2).to_integer;
				if val >= 1 then
					opts.set_max_time(val);
				else
					parse_error("max_time too small (<= 0)");
				end
			end

			if not failed then
				if lst.i_th(3).is_equal("y") then
					opts.set_qsearch(True);
				elseif lst.i_th(3).is_equal("n") then
					opts.set_qsearch(False);
				else
					parse_error("want_qsearch must be 'y' or 'n'");
				end
				
			end

			if not failed then
				if lst.i_th(4).is_equal("W") then
					opts.set_player_color(Chess_color_white);
				elseif lst.i_th(4).is_equal("B") then
					opts.set_player_color(Chess_color_black);
				else
					parse_error("side-color must be 'B' or 'W'");
				end
			end

			if not failed then
				options := opts;
			end
		end

	ensure
		not failed implies options /= Void;
	end

	parse_move(move_number: INTEGER; str: STRING) is
	require
		move_number >= 1;
		str /= Void;
		is_move(str);
	local
		paren_idx: INTEGER;
		comma_idx: INTEGER;
		num_str: STRING;
		white_str: STRING;
		black_str: STRING;
	do
		paren_idx := str.index_of(')', 1);
		comma_idx := str.index_of(',', 1);

		num_str := str.substring(1, paren_idx-1);
		if not num_str.is_integer then
			parse_error("invalid move number");
		elseif num_str.to_integer /= move_number then
			parse_error("move number is out of sequence");
		end

		if not failed then
			white_str := str.substring(paren_idx + 1, comma_idx-1);
			white_str.left_adjust;
			white_str.right_adjust;

			insert_move(white_str);
		end

		if not failed then
			if comma_idx = str.count then
				-- no black move, so we ignore
				-- this better be the last move in the file!
			else
				black_str := str.substring(comma_idx+1, str.count);
				black_str.left_adjust;
				black_str.right_adjust;

				insert_move(black_str);
			end
		end
		
	end

	insert_move(str: STRING) is
		-- this function checks to see if
		-- this 'str' is one of the valid moves
		-- to make.
		--
		-- If it is, then we apply that move to
		-- the 'game'
		--
	require
		str /= Void;
	local
		lst: LINKED_LIST[ CHESS_MOVE ];
		mov: CHESS_MOVE;
		mov_str: STRING;
		found: BOOLEAN;
	do
		from
			found := False;
			lst := game.valid_moves;
			lst.start;
		until
			lst.off or found
		loop
			mov := lst.item;

			mov_str := game.algebraic_notation(mov);

			if str.is_equal(mov_str) then
				found := True;
			end

			lst.forth;
		end

		if found then
			game.make_move(mov);
		else
			parse_error("Invalid move '" + str + "'");
		end
	end

feature {NONE} -- Save game routines
	write_header(f: PLAIN_TEXT_FILE) is
	require
		f /= Void;
	do
		f.put_new_line;
		f.put_new_line;
	end

	write_trailer(f: PLAIN_TEXT_FILE) is
	require
		f /= Void;
	do
		f.put_new_line;
		f.put_new_line;
	end

	write_nickname(f: PLAIN_TEXT_FILE; nick: STRING) is
	require
		f /= Void;
		nick /= Void;
	do
		f.put_string("Nickname " + nick);
		f.put_new_line;
		f.put_new_line;
	end

	write_options(f: PLAIN_TEXT_FILE; opts: CHESS_GAME_OPTIONS) is
	require
		f /= Void;
		opts /= Void;
	local
		color, qsearch: CHARACTER;
	do
		if opts.qsearch then
			qsearch := 'y';
		else
			qsearch := 'n';
		end

		if opts.player_color = Chess_color_white then
			color := 'W';
		else
			color := 'B';
		end

		f.put_string("Options "
				+ opts.max_ply.out
				+ ":" + opts.max_time.out
				+ ":" + qsearch.out
				+ ":" + color.out);

		f.put_new_line;
		f.put_new_line;
	end

	write_game(f: PLAIN_TEXT_FILE; g: CHESS_GAME; res: BOOLEAN) is
	require
		f /= Void;
		g /= Void;
	local
		total_plies: INTEGER;
		i, move, side: INTEGER;
		str: STRING;
	do
		from
			total_plies := g.total_plies;
			i := 1;
			side := Chess_color_white;
			move := 1;
		until
			i > total_plies
		loop
			str := g.move_out(i);

			if side = Chess_color_white then
				f.put_string(move.out + ") " + str + ",");
			else
				f.put_string("     " + str);
				f.put_new_line;
				move := move + 1;
			end

			side := get_opposite_color(side);

			i := i + 1;
		end

		f.put_new_line;

		if res then
			f.put_string("Resigned");
		end

	end

feature {NONE} -- Implementation
	filename: STRING;

	Nickname_keyword: STRING is "NICKNAME";
	Options_keyword: STRING is "OPTIONS";
	Resigned_keyword: STRING is "RESIGNED";


end
