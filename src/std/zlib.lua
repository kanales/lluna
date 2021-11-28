local zlib = {}

local ffi = require("ffi")
ffi.cdef [[
unsigned long compressBound(unsigned long sourceLen);
int compress2(uint8_t *dest, unsigned long *destLen,
	      const uint8_t *source, unsigned long sourceLen, int level);
int uncompress(uint8_t *dest, unsigned long *destLen,
	       const uint8_t *source, unsigned long sourceLen);
]]
local z = ffi.load "z"

function zlib.compress(txt, level)
    local level = level == nil and 9 or level
    local n = z.compressBound(#txt)
    local buf = ffi.new("uint8_t[?]", n)
    local buflen = ffi.new("unsigned long[1]", n)
    local res = z.compress2(buf, buflen, txt, #txt, level)
    assert(res == 0)
    return ffi.string(buf, buflen[0])
end

function zlib.uncompress(comp, n)
    local buf = ffi.new("uint8_t[?]", n)
    local buflen = ffi.new("unsigned long[1]", n)
    local res = z.uncompress(buf, buflen, comp, #comp)
    assert(res == 0, res)

    return ffi.string(buf, buflen[0])
end

return zlib
