local function elem(x, t)
    for i, v in ipairs(t) do
        if v == x then
            return true
        end
    end
    return false
end

return function(name, fields)
    local super = {}
    super.name = tostring(name)
    assert(type(fields) == 'table', "expected table fround " .. tostring(fields))
    super.fields = {}

    for i, f in ipairs(fields) do
        super.fields[i] = tostring(f)
    end

    super.mt = {
        __tostring = function(self)
            local pairs = {}
            for i, v in ipairs(super.fields) do
                pairs[i] = string.format("%s = %s", fields[i], self[fields[i]])
            end
            local fields = table.concat(pairs, ", ")
            return string.format("%s(%s)", super.name, fields)
        end,
        __eq = function(self, other)
            if getmetatable(self) ~= getmetatable(other) then
                return false
            end

            for i, f in ipairs(super.fields) do
                if self[f] ~= other[f] then
                    return false
                end
            end
            return true
        end,
        __ne = function(self, other)
            return not (self == other)
        end,
        __le = function(self, other)
            if getmetatable(self) ~= getmetatable(other) then
                return error("not comparable")
            end
            for i, f in ipairs(super.fields) do
                if self[f] < other[f] then
                    return false
                end
            end
            return true
        end,
        __ge = function(self, other)
            if getmetatable(self) ~= getmetatable(other) then
                return error("not comparable")
            end
            for i, f in ipairs(super.fields) do
                if self[f] > other[f] then
                    return false
                end
            end
            return true
        end,
        __lt = function(self, other)
            if getmetatable(self) ~= getmetatable(other) then
                return error("not comparable")
            end
            for i, f in ipairs(super.fields) do
                if self[f] >= other[f] then
                    return false
                end
            end
            return true
        end,
        __gt = function(self, other)
            if getmetatable(self) ~= getmetatable(other) then
                return error("not comparable")
            end
            for i, f in ipairs(super.fields) do
                if self[f] <= other[f] then
                    return false
                end
            end
            return true
        end
    }
    return setmetatable(super, {
        __call = function(self, ...)
            local other = {}
            local len = select("#", ...)
            assert(#self.fields == len)
            for i = 1, len do
                other[self.fields[i]] = select(i, ...)
            end

            return setmetatable(other, super.mt)
        end
    })
end
