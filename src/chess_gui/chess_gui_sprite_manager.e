indexing
	description:	"manages a collection of chess graphical sprites"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

--
-- 1. Obtains the bitmaps from the windows resource file
-- 2. Creates the bitmap masks for the pieces
-- 3. Changes the piece bitmaps so the background is black
-- 4. Stores the empty square graphics
-- 5. stores the board bitmap, and rotated board bitmap
--
class CHESS_GUI_SPRITE_MANAGER
inherit
	CHESS_PIECE_CONSTANTS

creation
	make

feature -- Initialization
	make is
	do
		!! piece_sprites.make(Min_piece, Max_piece);
		!! mask_sprites.make(Min_piece, Max_piece);

		!! capture_sprites.make(Min_piece, Max_piece);
		!! capture_mask_sprites.make(Min_piece, Max_piece);
	end

feature -- Access
	piece(p: INTEGER): CHESS_GUI_SPRITE is
	require
		valid_piece(p);
	do
		Result := piece_sprites.item(p);
	end

	mask(p: INTEGER): CHESS_GUI_SPRITE is
	require
		valid_piece(p);
	do
		Result := mask_sprites.item(p);
	end

	capture_piece(p: INTEGER): CHESS_GUI_SPRITE is
	require
		valid_piece(p);
	do
		Result := capture_sprites.item(p);
	end

	capture_mask(p: INTEGER): CHESS_GUI_SPRITE is
	require
		valid_piece(p);
	do
		Result := capture_mask_sprites.item(p);
	end

	board(side_facing_bottom: INTEGER): CHESS_GUI_SPRITE is
	require
		valid_piece_color(side_facing_bottom);
	do
		if side_facing_bottom = Chess_color_white then
			Result := board_sprite;
		else
			Result := rotated_sprite;
		end
	end

	empty_square(color: INTEGER): CHESS_GUI_SPRITE is
	require
		valid_piece_color(color);
	do
		if color = Chess_color_white then
			Result := white_square;
		else
			Result := black_square;
		end
	end

	capture_area: CHESS_GUI_SPRITE;

feature -- Status Report
	exists: BOOLEAN is
		-- Does the sprite manager have all its sprites defined?
	do
		Result :=	has_all_pieces
			and	board_sprite /= Void
			and	rotated_sprite /= Void
			and	black_square /= Void
			and	white_square /= Void
			and	border /= Void;
	end

	border_width: INTEGER is
		-- width is the border surrounding the chess board sprite
	do
		Result := border.width;
	end

	border_height: INTEGER is
		-- height of the border surrounding the chess board sprite
	do
		Result := border.height;
	end

feature -- Status Setting

feature -- Element Change (load sprites by resource ID)
	set_piece_by_id(p, id, id_small: INTEGER) is
	require
		valid_piece(p);
	local
		base, s, sm: CHESS_GUI_SPRITE;
	do
		--
		-- make normal sized image
		--
		!! base.make_by_id(id);
		s := base.invert;
		piece_sprites.put(s, p);

		sm := base.mask;
		mask_sprites.put(sm, p);

		--
		-- make small sized image
		--
		!! base.make_by_id(id_small);
		s := base.invert;
		capture_sprites.put(s, p);

		sm := base.mask;
		capture_mask_sprites.put(sm, p);
	end

	set_board_by_id(id, id_rotated: INTEGER) is
	do
		!! board_sprite.make_by_id(id);
		!! rotated_sprite.make_by_id(id_rotated);
	end

	set_empty_square_by_id(id_white, id_black: INTEGER) is
	do
		!! white_square.make_by_id(id_white);
		!! black_square.make_by_id(id_black);
	end

	set_capture_area_by_id(id: INTEGER) is
	do
		!! capture_area.make_by_id(id);
	end

	set_border_dim_by_id(id: INTEGER) is
	do
		!! border.make_by_id(id);
	end

feature -- Element Change (load sprites by Filenames)
	set_piece_by_filename(p: INTEGER; fn, fn_small: STRING) is
	require
		valid_piece(p);
		fn /= Void;
		fn_small /= Void;
	local
		base, s, sm: CHESS_GUI_SPRITE;
	do
		--
		-- make normal sized image
		--
		!! base.make_by_filename(fn);
		s := base.invert;
		piece_sprites.put(s, p);

		sm := base.mask;
		mask_sprites.put(sm, p);

		--
		-- make small sized image
		--
		!! base.make_by_filename(fn_small);
		s := base.invert;
		capture_sprites.put(s, p);

		sm := base.mask;
		capture_mask_sprites.put(sm, p);
	end

	set_board_by_filename(fn, fn_rotated: STRING) is
	require
		fn /= Void;
		fn_rotated /= Void;
	do
		!! board_sprite.make_by_filename(fn);
		!! rotated_sprite.make_by_filename(fn_rotated);
	end

	set_empty_square_by_filename(fn_white, fn_black: STRING) is
	require
		fn_white /= Void;
		fn_black /= Void;
	do
		!! white_square.make_by_filename(fn_white);
		!! black_square.make_by_filename(fn_black);
	end

	set_capture_area_by_filename(fn: STRING) is
	require
		fn /= Void;
	do
		!! capture_area.make_by_filename(fn);
	end

	set_border_dim_by_filename(fn: STRING) is
	require
		fn /= Void;
	do
		!! border.make_by_filename(fn);
	end

feature -- Removal

feature {NONE} -- Implementation Attributes
	piece_sprites: ARRAY[ CHESS_GUI_SPRITE ];
	mask_sprites: ARRAY[ CHESS_GUI_SPRITE ];

	capture_sprites: ARRAY[ CHESS_GUI_SPRITE ];
	capture_mask_sprites: ARRAY[ CHESS_GUI_SPRITE ];

	board_sprite: CHESS_GUI_SPRITE;
	rotated_sprite: CHESS_GUI_SPRITE;

	black_square: CHESS_GUI_SPRITE;
	white_square: CHESS_GUI_SPRITE;

	border: CHESS_GUI_SPRITE;

feature {NONE} -- Implementation routines
	has_all_pieces: BOOLEAN is
		-- Are all the piece sprites loaded?
	local
		p: INTEGER;
	do
		from
			Result := True;
			p := Min_piece
		until
			p >= Max_piece or (Result = False)
		loop
			if piece(p) = Void then
				Result := False;
			elseif mask(p) = Void then
				Result := False;
			elseif capture_piece(p) = Void then
				Result := False;
			elseif capture_mask(p) = Void then
				Result := False;
			end
			p := p + 1;
		end
	end

invariant
	-- all piece & mask, square sprites are the same size
	-- board and rotated are same size
	-- all capture and capture_mask sprites are same size
end
