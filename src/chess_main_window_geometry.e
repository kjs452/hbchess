indexing
	description:	"layout of CHESS_MAIN_WINDOW"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

--
-- These constants define the screen coordinates for
-- well the GUI control elements (buttons, chess board, etc...)
--
--

class CHESS_MAIN_WINDOW_GEOMETRY

feature -- Access
	Top_border: INTEGER is 22;
	Left_border: INTEGER is 4;

	Total_width: INTEGER is 688;
	Total_height: INTEGER is 600;

	--------------------------------
	-- margin spacing around the main window
	--
	Left_margin: INTEGER is
	once
		Result := 18 - Left_border;
	end

	Top_margin: INTEGER is
	once
		Result := 28 - Top_border;
	end

	Right_margin: INTEGER is
	once
		Result := 664 - Left_border;
	end

	Bottom_margin: INTEGER is
	once
		Result := 578 - Top_border;
	end

	Info_left: INTEGER is
	once
		Result := 486 - Left_border;
	end

	--------------------------------
	--
	-- Chess Board control
	--
	Board_left: INTEGER is
	once
		Result := Left_margin;
	end

	Board_top: INTEGER is
	once
		Result := Top_margin;
	end

	Board_center: INTEGER is
	once
		Result := 220 - Top_border;
	end

	Board_bottom: INTEGER is
	once
		Result := 411 - Top_border;
	end

	Board_right: INTEGER is
	once
		Result := 447 - Left_border;
	end

	--------------------------------
	--
	-- Video control
	-- (this control displays the webcam video)
	--
	Video_width: INTEGER is 176;
		-- this value comes from the bitmap size in the resource file

	Video_height: INTEGER is 144;
		-- this value comes from the bitmap size in the resource file

	Video_left: INTEGER is
	once
		Result := Right_margin - Video_width;
	end

	Video_top: INTEGER is
	once
		Result := Bottom_margin - Video_height;
	end

	--------------------------------
	--
	-- Video switch
	-- (switch for turning the webcam on/off)
	--
	Video_switch_width: INTEGER is 29;
	Video_switch_height: INTEGER is 22;

	Video_switch_left: INTEGER is
	once
		Result := Right_margin - Video_switch_width;
	end

	Video_switch_top: INTEGER is
	once
		Result := Video_top - Video_switch_height - 2;
	end

	--------------------------------
	--
	-- History list control
	-- (list box that displays the chess move history)
	--
	Hist_height: INTEGER is
	once
		Result := 244;
	end

	Hist_left: INTEGER is
	once
		Result := Info_left;
	end

	Hist_top: INTEGER is
	once
		Result := Board_center - (Hist_height // 2) - 10;
	end

	Hist_right: INTEGER is
	once
		Result := Right_margin;
	end

	Hist_bottom: INTEGER is
	once
		Result := Hist_top + Hist_height;
	end

	--------------------------------
	--
	-- History scroll control
	-- (allows player to scroll thru past chess moves)
	--
	Scroll_height: INTEGER is
	once
		Result := 15;
	end

	Scroll_left: INTEGER is
	once
		Result := Info_left;
	end

	Scroll_top: INTEGER is
	once
		Result := Hist_bottom + 4;
	end

	Scroll_right: INTEGER is
	once
		Result := Right_margin;
	end

	Scroll_bottom: INTEGER is
	once
		Result := Scroll_top + Scroll_height;
	end

	-------------------------
	--
	-- Arrow controls
	-- (This is a arrow bitmap that points to the player's name
	-- that is ready to move)
	-- 
	--
	Arrow_width: INTEGER is 22;
	Arrow_height: INTEGER is 23;

	Arrow_left: INTEGER is
	once
		Result := 464 - Left_border;
	end

	Upper_arrow_top: INTEGER is
	once
		Result := Top_margin + 12;
	end

	Lower_arrow_top: INTEGER is
	once
		Result := Board_bottom - Arrow_height - 12;
	end

	--------------------------------
	-- player text controls
	-- (displays the player's name)
	--
	Player_left: INTEGER is
	once
		Result := Info_left;
	end

	Player_right: INTEGER is
	once
		Result := 578 - Left_border;
	end

	Player_height: INTEGER is 22;

	Upper_player_top: INTEGER is
	once
		Result := Top_margin + 12;
	end

	Lower_player_top: INTEGER is
	once
		Result := Board_bottom - Player_height - 12;
	end

	--------------------------------
	--
	-- Game Status text controls
	--
	--
	Status_left: INTEGER is
	once
		Result := Player_right + 5;
	end

	Status_right: INTEGER is
	once
		Result := Right_margin;
	end

	Status_height: INTEGER is 22;

	Upper_status_top: INTEGER is
	once
		Result := Upper_player_top;
	end

	Lower_status_top: INTEGER is
	once
		Result := Lower_player_top;
	end

	--------------------------------
	--
	-- Rotate button control
	-- (this button allows the user to flip the chess board)
	--
	Rotate_width: INTEGER is 23;
	Rotate_height: INTEGER is 42;

	Rotate_left: INTEGER is
	once
		Result := Board_right + 8;
	end

	Rotate_top: INTEGER is
	once
		Result := Board_center - Rotate_height // 2;
	end

	--------------------------------
	--
	-- Chat icon control
	-- (this button activates the command menu)
	--
	Chat_icon_width: INTEGER is 26;
	Chat_icon_height: INTEGER is 102;

	Chat_icon_left: INTEGER is
	once
		Result := Chat_output_right + 9;
	end

	Chat_icon_top: INTEGER is
	once
		Result := Chat_output_top + (Chat_output_height//2)
				- Chat_icon_height//2;
	end

	--------------------------------
	-- Chat output control
	-- (output window that displays hotbabe's text messages)
	--
	Chat_output_left: INTEGER is
	once
		Result := Left_margin;
	end

	Chat_output_top: INTEGER is
	once
		Result := Video_top;
	end

	Chat_output_right: INTEGER is
	once
		Result := Board_right;
	end

	Chat_output_bottom: INTEGER is
	once
		Result := Bottom_margin;
	end

feature -- derived constants
	Hist_width: INTEGER is
	once
		Result := Hist_right - Hist_left + 1;
	end

	Scroll_width: INTEGER is
	once
		Result := Scroll_right - Scroll_left + 1;
	end

	Player_width: INTEGER is
	once
		Result := Player_right - Info_left + 1;
	end

	Status_width: INTEGER is
	once
		Result := Status_right - Status_left;
	end

	Chat_output_width: INTEGER is
	once
		Result := Chat_output_right - Chat_output_left + 1;
	end

	Chat_output_height: INTEGER is
	once
		Result := Chat_output_bottom - Chat_output_top + 1;
	end

end
