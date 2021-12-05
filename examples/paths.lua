local path = require "path"

local p = path.pwd() / "hello" / "world"
print(p)
p:mkdir()

path.rmdir(path.pwd() / "hello" / "world")
path.rmdir(path.pwd() / "hello")
