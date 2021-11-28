local bit = require "bit"

local tobit = bit.tobit
local bnot = bit.bnot
local band = bit.band
local bor = bit.bor
local bxor = bit.bxor
local lshift = bit.lshift
local rshift = bit.rshift
local arshift = bit.arshift
local rol = bit.rol
local ror = bit.ror
local bswap = bit.bswap

local sha1 = {}
sha1.__index = sha1

function sha1.new()
    local self = setmetatable({}, sha1)

    self.h = {0, 0x67452301, 0xEFCDAB89, 0x98BADCFE, 0x10325476, 0xC3D2E1F0}
    self.w = {}
    self.buffer = ''
    self.length = 0
    return self
end

local function encode64(a)
    --[[Encode number as 8 bytes]]
    local acc = ""
    for i = 1, 8 do
        local n = a % 256
        a = (a - n) / 256
        acc = string.char(n) .. acc
    end
    return acc
end

local function encode32(a)
    --[[Encode number as 8 bytes]]
    local acc = ""
    for i = 1, 4 do
        local n = a % 256
        a = (a - n) / 256
        acc = string.char(n) .. acc
    end
    return acc
end

local function to_u32(a, b, c, d)
    return a * 0x1000000 + b * 0x10000 + c * 0x100 + d
end

local function ternary(a, b, c)
    return bxor(c, band(a, bxor(b, c)))
end

local function choice(a, b, c)
    -- c ~ (a & (b ~ c)) has less bitwise operations than (a & b) | (~a & c).
    return bxor(c, band(a, bxor(b, c)))
end

local function majority(a, b, c)
    -- (a & (b | c)) | (b & c) has less bitwise operations than (a & b) | (a & c) | (b & c).
    return bor(band(a, bor(b, c)), band(b, c))
end

local function prepare(str, length)
    local len = #str
    -- Next, append some zero bytes to make the length of the final message a multiple of 64.
    -- Eight more bytes will be added next.
    local rem = -(len + 1 + 8) % 64
    local pad = string.rep('\0', rem)

    -- Finally, append the length of the original message in bits as a 64-bit number.
    -- Assume that it fits into the lower 32 bits.

    return str .. '\x80' .. pad .. encode64(length * 8)
end

local byte, sub = string.byte, string.sub

function sha1:update(str)
    self.length = self.length + #str

    -- recover buffer 
    str = self.buffer .. str

    local len = #str
    local n = len - (len % 64)

    -- store overflowing bytes
    self.buffer = string.sub(str, n + 1)
    str = string.sub(str, 1, n)

    -- process largest consecutive 64byte chunks from input
    self:_process(str)
    return self
end

function sha1:_process(str)
    --[[Process list of chunks of 64 bytes]]

    local w = self.w
    local h = self.h
    for chunk = 1, #str, 64 do
        for i = 1, 16 do
            local start = chunk + i * 4 - 4
            w[i] = to_u32(byte(str, start, start + 3))
        end

        for i = 17, 80 do
            w[i] = rol(bxor(w[i - 3], w[i - 8], w[i - 14], w[i - 16]), 1)
        end

        local a, b, c, d, e = self.h[1], self.h[2], self.h[3], self.h[4], self.h[5]
        for i = 1, 80 do
            local f
            local k

            if i <= 20 then
                f = choice(b, c, d)
                k = 0x5A827999
            elseif i <= 40 then
                f = bxor(b, c, d)
                k = 0x6ED9EBA1
            elseif i <= 60 then
                f = majority(b, c, d)
                k = 0x8F1BBCDC
            else
                f = bxor(b, c, d)
                k = 0xCA62C1D6
            end

            local temp = (rol(a, 5) + f + e + k + w[i]) % 4294967296
            e = d
            d = c
            c = rol(b, 30)
            b = a
            a = temp

        end

        h[1] = (h[1] + a) % 4294967296
        h[2] = (h[2] + b) % 4294967296
        h[3] = (h[3] + c) % 4294967296
        h[4] = (h[4] + d) % 4294967296
        h[5] = (h[5] + e) % 4294967296
    end
    return self
end

function sha1:hexdigest()
    local str = prepare(self.buffer, self.length)
    self:_process(str)

    return string.format("%08x%08x%08x%08x%08x", self.h[1], self.h[2], self.h[3], self.h[4], self.h[5])
end

function sha1:digest()
    local str = prepare(self.buffer, self.length)
    self:_process(str)

    local bs = {self.h[1], self.h[2], self.h[3], self.h[4], self.h[5]}
    return table.concat(bs, '')
end

-- SHA256
local sha256 = {}
sha256.__index = sha256

local SHA2_CONST = {0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
                    0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
                    0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
                    0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
                    0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
                    0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
                    0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
                    0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2}

function sha256.new()
    local self = setmetatable({}, sha256)

    self.h = {0, 0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a, 0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19}
    self.w = {}
    self.buffer = ''
    self.length = 0
    return self
end

function sha256:update(str)
    self.length = self.length + #str

    -- recover buffer 
    str = self.buffer .. str

    local len = #str
    local n = len - (len % 64)

    -- store overflowing bytes
    self.buffer = string.sub(str, n + 1)
    str = string.sub(str, 1, n)

    -- process largest consecutive 64byte chunks from input
    self:_process(str)
    return self
end

function sha256:_process(str)
    --[[Process list of chunks of 64 bytes]]

    local w = self.w
    local hs = self.h
    for chunk = 1, #str, 64 do
        for i = 1, 16 do
            local start = chunk + i * 4 - 4
            w[i] = to_u32(byte(str, start, start + 3))
        end

        for i = 17, 64 do
            local s0 = bxor(ror(w[i - 15], 7), ror(w[i - 15], 18), rshift(w[i - 15], 3))
            local s1 = bxor(ror(w[i - 2], 17), ror(w[i - 2], 19), rshift(w[i - 2], 10))
            w[i] = (w[i - 16] + s0 + w[i - 7] + s1) % 4294967296
        end

        local a, b, c, d, e, f, g, h = hs[1], hs[2], hs[3], hs[4], hs[5], hs[6], hs[7], hs[8]
        for i = 1, 64 do
            local s1 = bxor(ror(e, 6), ror(e, 11), ror(e, 25))
            local ch = choice(e, f, g)
            local t1 = (h + s1 + ch + SHA2_CONST[i] + w[i]) % 4294967296
            local s0 = bxor(ror(a, 2), ror(a, 13), ror(a, 22))
            local maj = majority(a, b, c)
            local t2 = (s0 + maj)
            h = g
            g = f
            f = e
            e = d + t1
            d = c
            c = b
            b = a
            a = t1 + t2
        end

        hs[1] = (hs[1] + a) % 4294967296
        hs[2] = (hs[2] + b) % 4294967296
        hs[3] = (hs[3] + c) % 4294967296
        hs[4] = (hs[4] + d) % 4294967296
        hs[5] = (hs[5] + e) % 4294967296
        hs[6] = (hs[6] + f) % 4294967296
        hs[7] = (hs[7] + g) % 4294967296
        hs[8] = (hs[8] + h) % 4294967296
    end
    return self
end

function sha256:hexdigest()
    local str = prepare(self.buffer, self.length)
    self:_process(str)

    return string.format("%08x%08x%08x%08x%08x%08x%08x%08x", self.h[1], self.h[2], self.h[3], self.h[4], self.h[5],
        self.h[6], self.h[7], self.h[8])
end

function sha256:digest()
    local str = prepare(self.buffer, self.length)
    self:_process(str)

    local bs = {self.h[1], self.h[2], self.h[3], self.h[4], self.h[5], self.h[6], self.h[7], self.h[8]}

    return table.concat(bs, '')
end

local sha224 = {}
sha224.__index = sha224

function sha224.new()
    local self = setmetatable({}, sha224)

    self.h = {0, 0xc1059ed8, 0x367cd507, 0x3070dd17, 0xf70e5939, 0xffc00b31, 0x68581511, 0x64f98fa7, 0xbefa4fa4}
    self.w = {}
    self.buffer = ''
    self.length = 0
    return self
end

function sha224:update(str)
    self.length = self.length + #str

    -- recover buffer 
    str = self.buffer .. str

    local len = #str
    local n = len - (len % 64)

    -- store overflowing bytes
    self.buffer = string.sub(str, n + 1)
    str = string.sub(str, 1, n)

    -- process largest consecutive 64byte chunks from input
    self:_process(str)
    return self
end

function sha224:_process(str)
    --[[Process list of chunks of 64 bytes]]

    local w = self.w
    local hs = self.h
    for chunk = 1, #str, 64 do
        for i = 1, 16 do
            local start = chunk + i * 4 - 4
            w[i] = to_u32(byte(str, start, start + 3))
        end

        for i = 17, 64 do
            local s0 = bxor(ror(w[i - 15], 7), ror(w[i - 15], 18), rshift(w[i - 15], 3))
            local s1 = bxor(ror(w[i - 2], 17), ror(w[i - 2], 19), rshift(w[i - 2], 10))
            w[i] = (w[i - 16] + s0 + w[i - 7] + s1) % 4294967296
        end

        local a, b, c, d, e, f, g, h = hs[1], hs[2], hs[3], hs[4], hs[5], hs[6], hs[7], hs[8]
        for i = 1, 64 do
            local s1 = bxor(ror(e, 6), ror(e, 11), ror(e, 25))
            local ch = choice(e, f, g)
            local t1 = (h + s1 + ch + SHA2_CONST[i] + w[i]) % 4294967296
            local s0 = bxor(ror(a, 2), ror(a, 13), ror(a, 22))
            local maj = majority(a, b, c)
            local t2 = (s0 + maj)
            h = g
            g = f
            f = e
            e = d + t1
            d = c
            c = b
            b = a
            a = t1 + t2
        end

        hs[1] = (hs[1] + a) % 4294967296
        hs[2] = (hs[2] + b) % 4294967296
        hs[3] = (hs[3] + c) % 4294967296
        hs[4] = (hs[4] + d) % 4294967296
        hs[5] = (hs[5] + e) % 4294967296
        hs[6] = (hs[6] + f) % 4294967296
        hs[7] = (hs[7] + g) % 4294967296
        hs[8] = (hs[8] + h) % 4294967296
    end
    return self
end

function sha224:hexdigest()
    local str = prepare(self.buffer, self.length)
    self:_process(str)

    return string.format("%08x%08x%08x%08x%08x%08x%08x", self.h[1], self.h[2], self.h[3], self.h[4], self.h[5],
        self.h[6], self.h[7])
end

function sha224:digest()
    local str = prepare(self.buffer, self.length)
    self:_process(str)

    local bs = {encode32(self.h[1]), encode32(self.h[2]), encode32(self.h[3]), encode32(self.h[4]), encode32(self.h[5]),
                encode32(self.h[6]), encode32(self.h[7])}
    return table.concat(bs, '')
end

local hmac = {}
hmac.__index = hmac
-- TODO support other blocksizes 
function hmac.new(hash_factory, key)
    --[[ hash should implement new/update/digest ]]
    local self = setmetatable({}, hmac)
    self.hash_factory = hash_factory
    self.hash = hash_factory.new()
    self.key = key
    self.blocksize = 64 -- bytes

    if #key > self.blocksize then
        self.key = hash_factory.new():update(key):digest()
    end
    local len = #self.key
    if len < self.blocksize then
        local rem = self.blocksize - len
        self.key = self.key .. string.rep('\0', rem)
    end

    self.opad = ''
    self.ipad = ''

    for i = 1, self.blocksize do
        local ch = byte(self.key, i, i)
        self.opad = self.opad .. bxor(ch, 0x5c)
        self.ipad = self.ipad .. bxor(ch, 0x36)
    end
    self.hash:update(self.ipad)

    return self
end

function hmac:update(msg)

    self.hash:update(msg)
    return self
end

function hmac:digest()
    local str = self.hash:digest()
    local h = self.hash_factory.new()
    h:update(opad)
    h:update(str)
    return h:digest()
end

function hmac:hexdigest()
    local str = self.hash:digest()
    local h = self.hash_factory.new()
    h:update(self.opad)
    h:update(str)
    return h:hexdigest()
end

return {
    sha1 = sha1,
    sha256 = sha256,
    sha224 = sha224,
    hmac = hmac
}
