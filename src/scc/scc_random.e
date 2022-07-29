indexing
	description:	"A random number generator"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

class SCC_RANDOM

creation
	make, make_default

feature -- Initialization
	make_default is
	do
		make(Default_seed);
	end

	make(a_seed: INTEGER) is
	do
		!!state.make(1, DEG4);
		set_seed(a_seed);
	end

	set_seed(a_seed: INTEGER) is
	do
		seed := a_seed;
		init_state;
	end

feature -- Access
	seed:		INTEGER;	-- current seed
	item:		INTEGER;	-- current random number

feature -- Element Change
	next is
		-- advance to the next random number in sequence
	do
		random;
	end

feature -- Access
	item_range(min, max: INTEGER): INTEGER is
		-- return a random value in the range [min ... max]
	require
		min <= max
	local
		v: INTEGER;
	do
		v := item.abs;
		Result := min + (v \\ (max-min+1));
	ensure
		Result >= min and Result <= max
	end

feature {NONE} -- Implementation

	state: ARRAY[INTEGER];

	good_rand(x: INTEGER): INTEGER is
		-- a simple rnd functions
		-- Compute x = (7^5 * x) mod (2^31 - 1)
		-- wihout overflowing 31 bits:
		--      (2^31 - 1) = 127773 * (7^5) + 2836
		-- From "Random number generators: good ones are hard to find",
		-- Park and Miller, Communications of the ACM, vol. 31, no. 10,
		-- October 1988, p. 1195.
	local
		high, low: INTEGER;
	do
		high := x // 127773;
		low := x \\ 127773;
		Result := (16807 * low) - 2836 * high;
		if Result <= 0 then
			Result := Result + Mod31Bits;
		end
	end

	init_state is
		-- Initialize the random number generator based on the given seed.
		-- Initializes state[] based on the given "seed" via a linear congruential
		-- generator.  Then, the indexes are set to known locations that are exactly
		-- SEP4 places apart.  Lastly, it cycles the state information a given
		-- number of times to get rid of any initial dependencies
		-- introduced by the L.C.R.N.G.
	local
		i: INTEGER;
		val: INTEGER;
	do

		from
			state.put(seed, 1);
			i := 2;
		until
			i > Deg4
		loop
			val := good_rand( state.item(i-1) );
			state.put(val, i);

			i := i + 1;
		end

		rear := 1;
		front := rear + Sep4;

		from
			i := 1
		until
			i > 10 * Deg4
		loop
			random;

			i := i + 1;
		end
	end

	random is
		-- The basic operation is to add the number at the rear index
		-- into the one at the front index.  Then both indexes are advanced to
		-- the next location cyclically in the table.  The value returned is the sum
		-- generated, reduced to 31 bits by throwing away the "least random" low bit.
		--
		-- Note: the code takes advantage of the fact that both the front and
		-- rear indexes can't wrap on the same call by not testing the rear
		-- index if the front one has wrapped. (Not anymore - KJS)
		--
		-- Returns a 31-bit random number.
	local
		front_value, rear_value: INTEGER;
	do
		rear_value := state.item(rear);
		front_value := state.item(front);
		state.put(front_value + rear_value, front);

		item := (state.item(front) // 2) \\ Mod31Bits;

		front := front + 1;
		if front > Deg4 then
			front := 1;
		end

		rear := rear + 1;
		if rear > Deg4 then
			rear := 1;
		end
	end

	front: INTEGER;
	rear: INTEGER;

	Deg4: INTEGER is 63
	Sep4: INTEGER is 1;

	Mod31Bits: INTEGER is 2147483647; -- 0x7fffffff
	Default_seed: INTEGER is 666;
end
