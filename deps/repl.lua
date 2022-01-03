local repl = repl

local baseprint = print
print = function(...)
	baseprint(..., "\r")
end

local reserved = {
	["and"] = true,
	["break"] = true,
	["do"] = true,
	["else"] = true,
	["elseif"] = true,
	["end"] = true,
	["false"] = true,
	["for"] = true,
	["function"] = true,
	["if"] = true,
	["in"] = true,
	["local"] = true,
	["nil"] = true,
	["not"] = true,
	["or"] = true,
	["repeat"] = true,
	["return"] = true,
	["then"] = true,
	["true"] = true,
	["until"] = true,
	["while"] = true,
}

local function strip_ansi(s)
	return s:gsub("\x1b[[]%d*m", "")
end

local function handle_word(w)
	if reserved[w] then
		return "\x1b[35m" .. w .. "\x1b[39m"
	end
	if _G[w] ~= nil then
		return "\x1b[36m" .. w .. "\x1b[39m"
	end
	return w
end

local function handle_string(w)
	return "\x1b[33m" .. strip_ansi(w) .. "\x1b[39m"
end

local function handle_number(n)
	return "\x1b[32m" .. n .. "\x1b[39m"
end

function repl.before_print(s)
	local out = s
		:gsub("(%d+)", handle_number)
		:gsub("(%w+)", handle_word)
		:gsub('(".+")', handle_string)
		:gsub("('.+')", handle_string)

	return out
end

local STMTS = {
	"^do ",
	"^while ",
	"^repeat ",
	"^if ",
	"^for ",
	"^function ",
	"^local ",
}
local function prepare(s)
	s = s:gsub("^%s+", "")
	for _, v in ipairs(STMTS) do
		if s:match(v) then
			return s
		end
	end
	if s:match("^%a+%s*=") then
		return s
	end
	return "return " .. s
end

function repl.execute(s)
	s = prepare(s)
	local f, err = loadstring(s)
	if not f then
		return err
	end
	local res = f()
	if res == nil then
		return ""
	end
	return tostring(res)
end

function repl.complete(w)
	return w
end
