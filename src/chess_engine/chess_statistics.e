indexing
	description:	"structure containing various statitics about the chess engine"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

class CHESS_STATISTICS

creation
	make

feature -- Initialization
	make is
	do
	end

feature -- Access
	nodes_per_second: INTEGER;
		-- overal nodes-per-seconds performance

	last_nps: INTEGER;
		-- nodes-per-second from last search operation

	last_node_count: INTEGER;
		-- number of nodes searched from last search operation

	total_hash_slots: INTEGER;
	hash_slots_used: INTEGER;

	total_hash_collisions: INTEGER;
	total_hash_lookups: INTEGER;

	best_sequence: STRING;

feature -- Element Change
	set_nodes_per_second(val: INTEGER) is
	do
		nodes_per_second := val;
	end

	set_total_hash_slots(val: INTEGER) is
	do
		total_hash_slots := val;
	end

	set_hash_slots_used(val: INTEGER) is
	do
		hash_slots_used := val;
	end

	set_total_hash_collisions(val: INTEGER) is
	do
		total_hash_collisions := val;
	end

	set_total_hash_lookups(val: INTEGER) is
	do
		total_hash_lookups := val;
	end

	set_last_nps(val: INTEGER) is
	do
		last_nps := val;
	end

	set_last_node_count(val: INTEGER) is
	do
		last_node_count := val;
	end

	set_best_sequence(val: STRING) is
	require
		val /= Void;
	do
		best_sequence := val;
	end

end
