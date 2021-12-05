local term = require "term"
local byte = string.byte
local stdin, stdout, stderr = io.stdin, io.stdout, io.stderr

do
    term.enable_raw_mode()
    stdout:write "Using raw input to make"
    stdout:write "an interactive menu:\r\n"
    stdout:write " - press 'q' to quit.\r\n"
    stdout:write " - press 'Enter' to toggle.\r\n"

    local idx = 1
    local args = {"Option 1", "Option 2", "Option 3"}
    local selected = {false, false, false}

    local N = #args

    local function process_key()
        local c = term.read_key()

        if c == '\x1b' then
            -- escape code
            local a, b = term.read_key(), term.read_key()
            if a == '[' then
                if b == 'A' then
                    -- up
                    idx = math.max(1, idx - 1)
                elseif b == 'B' then
                    -- down
                    idx = math.min(N, idx + 1)

                elseif b == 'C' then
                    -- right
                elseif b == 'D' then
                    -- left
                end
            end
        elseif byte(c) == 10 or byte(c) == 13 then
            selected[idx] = not selected[idx]
        elseif c == 'q' then
            os.exit(0)
        else
        end
    end

    while true do
        for i, v in ipairs(args) do
            term.clear_line "a"
            stdout:write(idx == i and "> " or "  ")
            stdout:write(selected[i] and "🔘 " or "⚪ ")
            stdout:write(v)
            stdout:write "\r\n"
        end

        while process_key() do
        end
        term.move_up(3)
    end
end

