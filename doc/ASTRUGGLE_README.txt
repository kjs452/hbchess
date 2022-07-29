Hotbabe Chess v1.0
October 30, 2003

Dear Judges,
This package is a chess game written in Eiffel
for the Eiffel Struggle 2003 programming contest.

See the requirements below to learn what compiler/platform
is needed to build this application.

This file is just a short roadmap that will get you started, more
documentation is availble in the 'doc' directory.

Sincerely,
	Anonymous

---------------------------------------
  TABLE OF CONTENTS
	1. Files
	2. Installation
	3. Uninstall
	4. Requirements (to compile)
	5. User Documentation
	6. Programmer Documentation
	7. Innovation
	8. Inno Setup
---------------------------------------

1. FILES:

hotbabe_chess ---+
                 |
                 +---- setup.exe
                 |             (installs the application)
                 |
                 +---- autorun.inf
                 |
                 +---- ASTRUGGLE_README.txt
                 |                   (this file)
                 |
                 +---- hotbabe_chess.iss
                 |                   (script to build the setup.exe file)
                 |
                 +---- src ----+
                 |             +---- ace.ace
                 |             +---- chess_engine
                 |             +---- chess_gui
                 |             +---- hotbabe
                 |             +---- scc
                 |
                 |             (contains all eiffel source code)
                 |
                 +---- doc ----+
                               +---- index.html

                               (contains programmer documentation)




2. INSTALLATION:

To install this application, run "setup.exe".

"setup.exe" will extract the following files into
the user selected installation directory:

        readme.txt              <- end-user information and licensing info
        hotbabe_chess.exe       <- executable
        hotbabe_chess.avi       <- hotbabe video clips
        hotbabe_chess.dat       <- database of video clips/text messages
        uninstall.exe           <- script to unintall the program

"setup.exe" will add this entry to the windows registry:

        HKEY_CURRENT_USER\Software\Scc\HotBabeChess\InstallPath

"setup.exe" will create a shortcut on the desktop, and also
add an item to the Windows Start Menu.

This program will run on any Windows 95/XP/NT computer.
The video file is quite large and requires about 80 MB of disk space.

The video file is 160x120 at 5 frames per second,
uses the IR32 compression format. (If you need this codec, use
the internet to obtain the Indeo 3.2 "IR32" codec)




3. UNINSTALL:

This program can be uninstalled using "Add/Remove Programs", or
you can select "uninstall" from the hotbabe chess directory.

The uninstall process will remove all hotbabe chess files, shortcuts,
and the registry entry.





4. REQUIREMENTS (TO COMPILE):

(NOTE: Detailed instructions on compiling HOTBABE CHESS is
available in the 'doc' subdirectory.)

To compile this application you will need:

	- a windows XP/NT computer.
	- Eiffel Studio 5.3
	- Microsoft Visual C/C++ 6.0 or higher.
	- WEX package installed


NOTES:	1. It may also work with the borland C compiler, but I haven't tried this.
	2. The free edition was used to develop this application, but the
	   commercial version should also work.
	3. Inno setup is needed to create the "setup.exe" file

In addition to Eiffel Studio 5.3, you will also need to configure
the WEX package, which is included in the 'free_add_ons' directory
for eiffel studio (detailed instructions on how to do this is included
in the programmer documentation).

If you wish to compile and run this program, first install hotbabe chess
(setup.exe), so that when your compiled version runs, it will find the
required support files.



5. USER DOCUMENTATION:

All documentation for using this application is available
from within the Hotbabe Chess application. (Select HELP from
the menu)





6. PROGRAMMER DOCUMENTATION:

The source code contains extensive internal documentation, but
there is additional information in the 'doc' subdirectory.

Such as,
	- detailed instructins on how to compile the application
	- detailed instructions on how to compile WEX
	- how the clusters are related
	- how the classes are organized
	- how to build the "setup.exe" program

Open "index.html" with your web browser to view
the table of contents.





7. INNOVATION:

The open source world contains many examples of chess programs. Some
programs focus on the chess engine, and use WinBoard or XBoard
as the graphical user interface. Other programs focus on the user interface,
and will use GNU chess as the engine. There are also internet servers for
people to compete with other chess engines.

Hotbabe Chess is unique for several reasons:
	1. Written in Eiffel (no other eiffel chess games exists!)
	2. Is BOTH a chess engine and a chess graphical interface
	3. Has a fun "hotbabe" character, that simulates an online chat room.
	4. Demonstrates that performance critical tasks (chess searching) can
	   indeed be accomplished using Eiffel.

Other open source chess games include:
	- Gnu Chess
	- WinBoard/XBoard
	- eboard (http://eboard.sourceforge.net)

Hotbabe chess is not designed to be the fastest engine, instead it is designed
to be as user friendly as possible. It's a fun game to play for beginners.

The performance of this engine is 240,000 nodes per second on a 2.66 Ghz Pentium
and 140,000 nodes per second on a 1.5 Ghz Pentium.





8. INNO SETUP:

A 3rd party program was used to create the "setup.exe" file.

To build the 'setup.exe' file, you will need INNO setup, which
compiles the 'hotbabe_chess.iss' configuration file.

(See their website: http://www.jrsoftware.org/isinfo.php)


