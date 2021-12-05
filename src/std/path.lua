local path = {}
path.__index = path

local ffi = require("ffi")
local OS = ffi.os
local C = ffi.C

local EPERM = 1
local EACCES = 13
local EEXIST = 17
local ERANGE = 34

local function strerror(err)
    return ffi.string(C.strerror(err))
end

local SEP = OS == "Windows" and "\\" or "/"
local MAXPATH = OS == 'Linux' and 4096 or 1024

ffi.cdef [[
    char* strerror(int errnum);
    char *getcwd(char *buf, size_t size);
    int chdir(const char *path);
    int rmdir(const char *pathname);
    typedef unsigned int mode_t;
    int mkdir(const char *pathname, mode_t mode);
]]

local function join(one, other)
    return path(tostring(one), tostring(other))
end

function path:__tostring()
    return table.concat(self, SEP)
end

local FILE_EXISTS = 17
local PERMISSION_DENIED = 13

function path.pwd()
    local size = MAXPATH
    while true do
        local buf = ffi.new("char[?]", size)
        if C.getcwd(buf, size) ~= nil then
            return path(ffi.string(buf)), nil
        end
        local err = ffi.errno()
        if err ~= ERANGE then
            return nil, strerror(err)
        end
        size = size * 2
    end
end

function path:mkdir(mode)
    for i = 1, #self do
        local p = table.concat(self, SEP, 1, i)
        ok = C.mkdir(p, mode or 509)
        if ok ~= 0 and ok ~= -1 then
            return error(ok .. "could not create " .. tostring(self), 2)
        end
    end
end

function path:chdir()
    if C.chdir(tostring(self)) == 0 then
        return true
    end
    return nil, strerror(ffi.errno())
end

function path:rmdir()
    if C.rmdir(tostring(self)) == 0 then
        return true
    end
    return nil, strerror(ffi.errno())
end

path.__div = join
function path:_new(...)
    local o = {}

    for i = 1, select("#", ...) do
        table.insert(o, tostring(select(i, ...)))
    end

    return setmetatable(o, path)
end

return setmetatable(path, {
    __call = path._new
})
