local termios = require "termios"
local byte = string.byte
local stdin, stdout, stderr = io.stdin, io.stdout, io.stderr

local M = {}

M.enable_raw_mode = termios.enable_raw_mode

function M.read_key()
    local c = stdin:read(1)
    while c == nil do
        c = stdin:read(1)
    end
    return c
end

function M.move_left(s)
    s = s or 999
    stdout:write('\x1b[' .. s .. "D")
end

function M.move_right(s)
    s = s or 999
    stdout:write('\x1b[' .. s .. "C")
end

function M.move_up(s)
    s = s or 999
    stdout:write('\x1b[' .. s .. "A")
end

function M.move_down(s)
    s = s or 999
    stdout:write('\x1b[' .. s .. "B")
end

function M.clear_line(arg)
    if arg == nil or arg == 'r' then
        stdout:write "\x1b[0K"
    elseif arg == 'l' then
        stdout:write "\x1b[1K"
    elseif arg == 'a' then
        stdout:write "\x1b[2K"
    end
end

return M
