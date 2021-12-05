local Point2D = record("Point", {"x", "y"})
local a = Point2D(2, 3)
local b = Point2D(1, 1)
local c = Point2D(2, 3)

print(tostring(a))
-- Point(x = 2, y = 3)
print(a ~= b)
-- true
print(a == c)
-- true
