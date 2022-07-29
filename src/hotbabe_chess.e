indexing
	description:	"root class for hotbabe_chess application"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

--
-- This is the root class for hotbabe chess but not much happens here...
-- (all WEL applications need a WEL_APPLICATION class to get things started)
--
-- This is a WEL application and consists of a main window CHESS_MAIN_WINDOW
-- and a couple of modal dialogs.
--
-- But CHESS_MAIN_WINDOW doesn't have much functionality, all
-- of the gameplay logic is in CHESS_APPLICATION_MANAGER, this is
-- really the ROOT class for the whole hotbabe chess application.
--
-- Clusters:
--	ROOT CLUSTER	- classes supporting the application
--		Most important classes:	CHESS_APPLICATION_MANAGER
--
--	SCC		- general source code utility classes
--		Most important classes: N/A
--
--	CHESS_ENGINE	- the chess playing algorithms
--		Most important classes: CHESS_SEARCH, CHESS_GAME, CHESS_MOVE_TABLE
--
--	CHESS_GUI	- all graphical controls and associated classes
--		Most important classes: All of them
--
--	HOTBABE		- hotbabe artificial intellgence (text and video clip database)
--		Most important classes: HOTBABE, HOTBABE_DB
--			
--
-- CHESS_MAIN_WINDOW implements the deferred features
-- of CHESS_APPLICATION_USER_INTERFACE.
--
-- Most of the windows interactions happen between these classes:
--
--	CHESS_APPLICATION_MANAGER    <--->  CHESS_APPLICATION_USER_INTERFACE
--						(CHESS_MAIN_WINDOW)
--
-- All of the graphical objects (text boxes, list boxes, rich text, buttons, etc..)
-- are implementations of a CHESS_GUI_CONTROL
--
-- The resource file is "hotbabe_chess.rc", you can edit this with Microsoft
-- Visual C/C++ 6.0.
--
-- The h2e program (offered by Eiffel Studio) will take the resource.h file
-- and produce the class CHESS_APP_CONSTANTS, which includes
-- all the resource ID's.
--
-- You will also find many bitmaps/icons in this directory. These are
-- referenced by the resource file and contain all the graphics for
-- drawing the chess board, pieces, button graphics, etc...
--
-- There is also the "ace.ace" file, which is designed to run
-- using Eiffel Studio 5.3
--
-- COMPILING INSTRUCTIONS:
--	1. If CHESS_APP_CONSTANTS (chess_app_con.e) class does not exist,
--	   then run the "h2e" utility:
--		Header/Resource file:	resource.h
--		Eiffel file:		chess_app_con.e
--		Class name:		CHESS_APP_CONSTANTS
--
--	2. Run eiffel studio 5.3
--	3. Browse for the ace specification file: "ace.ace"
--	4. Compile application
--	5. Will produce an executable called "hotbabe_chess.exe"
--
-- The ace file assumes the "wel" and "base" clusters have been precompiled
--
-- WEX WEX WEX WEX WEX WEX WEX WEX WEX WEX:
--
-- The ace file uses the environment variable "WEX_VC_LIB".
-- It is used in the ACE file for specifying the location of window MM library
-- (MM library is a standard windows multi-media library, needed by WEX)
--
--		"$(wex_vc_lib)\winmm.lib"
--
-- On my computer, I use this setting for $(wex_vc_lib):
--	WEX_VC_LIB=C:\Program Files\Microsoft Visual Studio\VC98\lib
--
-- WEX is provided in the 'free_add_ons' directory of the Eiffel Studio distribution.
--
-- WEX appears to be already compiled for you automatically.
--
-- The most important thing about using WEX is to make sure that this
-- library is compiled:
--	Eiffel53\free_add_ons\wex\library\clib\cwex.lib
--
-- Running "make_msc.bat" should create the library for you.
-- (if it doesn't already exist)
--
-- The ace.ace file refers to the location of WEX in the 'include_path' and
-- several wex clusters.
--
-- If your version of WEX is in another directory, you will need to change
-- the project settings.
--
-- RUNNING THE APPLICATION:
--	This application needs to find its support files. A windows registry
-- entry is used to locate the support files.
--
--	HKEY_CURRENT_USER\Software\Scc\HotBabeChess\InstallPath
--
-- The easiest thing to do, is to run the installation program "setup.exe"
--
-- This will create the registry string and copy the support files
-- into this directory.
--
-- The executable can reside anywhere, so you can compile in eiffel studio
-- and run the application and it will find the support files.
--
--

class HOTBABE_CHESS

inherit
	WEL_APPLICATION
	redefine
		init_application
	end

creation
	make

feature

	main_window: CHESS_MAIN_WINDOW is
		-- Create the application's main window
	once
		!! Result.make(Current);
	end

	init_application is
		-- Load the common controls dll and the rich edit dll.
	do
		!! common_controls_dll.make
		!! rich_edit_dll.make
		disable_idle_action;
	end

	common_controls_dll: WEL_COMMON_CONTROLS_DLL
	rich_edit_dll: WEL_RICH_EDIT_DLL
end
