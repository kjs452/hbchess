indexing
	description:	"obtains the installation directory from the registry"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

--
-- This class encapsulates the logic for fetching the "InstallPath"
-- from the registry.
--
-- Hotbabe chess looks for the following registry entry:
--
--	HKEY_CURRENT_USER\Software\Scc\HotBabeChess\InstallPath
--
-- The value is a string that points to the directory where
-- the program has been installed.
--
-- NOTE: The installation program automatically configures
-- this registry entry, thus allowing us to
-- obtain the correct information.
--
-- To use this class, create it and then check to see
-- if 'failed' is set to TRUE, in which case 'error_message'
-- will indicate the type of error.
--
-- If failed is false, then we successfully obtained
-- the installation directory.
--
class CHESS_APPLICATION_INSTALL_DIR
inherit
	WEL_REGISTRY
	export
		{NONE} all
	end

creation
	make

feature -- Initialization
	make is
	local
		p: POINTER;
		keyval: WEL_REGISTRY_KEY_VALUE;
	do
		failed := False;

		p := open_key(Hkey_current_user, Subkey, Key_query_value);
		if p /= default_pointer then
			keyval := key_value(p, Value_name);
			if keyval /= Void then
				item := keyval.string_value;
			else
				set_failed("Missing value name: HKEY_CURRENT_USER\"
					+ Subkey + "\" + Value_name );
			end

			close_key(p);

			check_directory;
		else
			set_failed("Unable to open the registry key:%
					% HKEY_CURRENT_USER\"
					+ Subkey );
		end
	end

feature -- Access
	failed: BOOLEAN;
		-- did 'make' succeed?

	error_message: STRING;
		-- the error message associated with
		-- the failure during create.

	item: STRING;
		-- installation directory

feature {NONE} -- Implmentation
	Subkey: STRING is "Software\Scc\HotBabeChess";
	Value_name: STRING is "InstallPath";

	set_failed(msg: STRING) is
	do
		failed := True;
		error_message := "Installation Error: " + msg;
	end

	check_directory is
		-- check to see that install_directory 'item' exists.
	local
		dir: DIRECTORY;
	do
		!! dir.make(item);

		if not dir.exists then
			set_failed("The directory "
				+ "HKEY_CURRENT_USER\"
				+ Subkey
				+ "\"	
				+ Value_name
				+ " = "
				+ item
				+ " does not exist");
		end
	end

end
