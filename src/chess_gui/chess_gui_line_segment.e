indexing
	description:	"defines a line segment for 2-d points"
	copyright: "Copyright (c) 2003 Ken Stauffer"
	license: "Eiffel Forum License v2 (see readme.txt)"
	author: "Ken Stauffer"

--
-- This class allows us to iterate over the (x,y) points in
-- a line segment. This class is used to animate the
-- chess pieces in a straight line given two screen coordinates.
--
--
class CHESS_GUI_LINE_SEGMENT

creation
	make

feature -- Initialization
	make(ax1, ay1, ax2, ay2, a_step: INTEGER) is
		-- create a line segment from the (ax1, ay1) - (ax2, ay2)
		-- 'a_step' specifies the step amount for iterating
		-- over the points in the line.
	require
		a_step > 0;
	do
		x1 := ax1;
		y1 := ay1;

		x2 := ax2;
		y2 := ay2;

		rise := (y2 - y1);
		run := (x2 - x1);

		if run = 0.0 then
			if rise < 0.0 then
				step := - a_step;
			else
				step := a_step;
			end

		elseif rise.abs <= run.abs then
			m := rise / run;
			b := y1 - m * x1;

			if run < 0.0 then
				step := - a_step;
			else
				step := a_step;
			end

		else -- rise.abs > run.abs
			m := rise / run;
			b := y1 - m * x1;

			if rise < 0.0 then
				step := - a_step;
			else
				step := a_step;
			end
		end
	end

feature -- Access
	x: INTEGER;
	y: INTEGER;

feature -- Status Report
feature -- Status Setting
	off: BOOLEAN is
	do
		if run = 0.0 then
			if step > 0 then
				Result := (y > y2);
			else
				Result := (y < y2);
			end

		elseif rise.abs <= run.abs then
			if step > 0 then
				Result := (x > x2);
			else
				Result := (x < x2);
			end

		else -- rise.abs > run.abs
			if step > 0 then
				Result := (y > y2);
			else
				Result := (y < y2);
			end
		end
	end

feature -- Element Change
	start is
	do
		x := x1;
		y := y1;
	end

	forth is
	require
		not off;
	do
		if run = 0.0 then
			-- vertical lines
			y := y + step;
			x := x1;

		elseif rise.abs <= run.abs then
			-- flat lines
			x := x + step;
			y := (m*x + b).rounded;

		else -- rise.abs > run.abs
			-- steep lines
			y := y + step;
			x := ((y-b) / m).rounded;
		end

	end

feature {NONE} -- Implementation (attributes)
	x1, y1, x2, y2: INTEGER;
	step: INTEGER;
	rise, run, m, b: DOUBLE;
end
