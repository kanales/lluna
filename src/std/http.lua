local http = {}

local json = require "json"
local ffi = require "ffi"

ffi.cdef [[
void *curl_easy_init();
typedef unsigned int CURLcode;
typedef unsigned int CURLoption;
typedef unsigned int CURLINFO;
typedef void CURL;

typedef size_t (*curl_write_callback)(char *ptr, size_t size, size_t nmemb, void *userdata);
CURLcode curl_easy_setopt(CURL *curl, CURLoption option, ...);
int curl_easy_perform(void *curl);
void curl_easy_cleanup(void *curl);
CURLcode curl_easy_getinfo(CURL *curl, CURLINFO info, ... );
const char *curl_easy_strerror(int errornum);

struct curl_slist *curl_slist_append(struct curl_slist *list, const char *string);
void curl_slist_free_all(struct curl_slist *);
]]

ffi.cdef [[
int printf(const char *fmt, ...);
]]

local C = ffi.C
local libcurl = ffi.load "curl"

local CURLOPT_URL = 10000 + 2
local CURLOPT_HTTPGET = 80
local CURLOPT_HTTPPOST = 10000 + 24
local CURLOPT_WRITEFUNCTION = 20000 + 11
local CURLOPT_POSTFIELDS = 10000 + 15
local CURLOPT_HTTPHEADER = 10000 + 23
local CURLINFO_RESPONSE_CODE = 0x200000 + 2

local function strerror(err)
    return ffi.string(libcurl.curl_easy_strerror(err))
end

-- response
local response = {}
response.__index = response

function response:json()
    return json.decode(self.body)
end

function response.new(body, code)
    local self = {}
    self.body = body
    self.code = code
    return setmetatable(self, response)
end

-- headers
local headers = {}
headers.__index = headers

function headers.new(t)
    local self = {}
    self.slist = nil
    setmetatable(self, headers)

    if type(t) == "table" then
        for i, v in ipairs(t) do
            self:push(v)
        end
    end

    return self
end

function headers:push(h)
    self.slist = libcurl.curl_slist_append(self.slist, ffi.cast("const char *", h))
    return self
end

function headers:free()
    libcurl.curl_slist_free_all(self.slist);
end

local curl = {}
curl.__index = curl

function curl.new()
    local obj = {}
    obj.handle = libcurl.curl_easy_init()
    obj.result = ""

    local cb = ffi.cast("curl_write_callback", function(cbuffer, cs, cnitems, cout)
        local rsize = tonumber(cs * cnitems)

        obj.result = obj.result .. ffi.string(cbuffer):sub(1, rsize)
        return rsize
    end)

    libcurl.curl_easy_setopt(obj.handle, CURLOPT_WRITEFUNCTION, cb)

    return setmetatable(obj, curl)
end

function curl:_perform()
    if self.headers then
        libcurl.curl_easy_setopt(self.handle, CURLOPT_HTTPHEADER, self.headers.slist);
    end

    local res = libcurl.curl_easy_perform(self.handle)
    if res ~= 0 then
        local s = strerror(res)
        self.headers:free()
        libcurl.curl_easy_cleanup(self.handle)
        return nil, s
    end
    if self.headers then
        self.headers:free()
    end
    local code = ffi.new("long[1]", {})
    libcurl.curl_easy_getinfo(self.handle, CURLINFO_RESPONSE_CODE, code)
    libcurl.curl_easy_cleanup(self.handle)
    local res = response.new(self.result, tonumber(code[0]))
    return res, nil
end

function curl:get(url, hs)
    libcurl.curl_easy_setopt(self.handle, CURLOPT_URL, ffi.cast("const char *", url))
    libcurl.curl_easy_setopt(self.handle, CURLOPT_HTTPGET, 1)

    self.headers = type(hs) == "table" and headers.new(hs) or nil

    return self:_perform()
end

function curl:post(url, data, hs)
    libcurl.curl_easy_setopt(self.handle, CURLOPT_URL, ffi.cast("const char *", url))
    libcurl.curl_easy_setopt(self.handle, CURLOPT_HTTPPOST, 1)
    self.headers = type(hs) == "table" and headers.new(hs) or headers.new()

    if type(data) == "table" then
        data = json.encode(data)
        self.headers:push("Accept: application/json")
        self.headers:push("Content-Type: application/json")
    end

    libcurl.curl_easy_setopt(self.handle, CURLOPT_POSTFIELDS, data);

    return self:_perform()
end

function http.get(...)
    return curl.new():get(...)
end

function http.post(...)
    return curl.new():post(...)
end

function http.test()
    local res = http.post("https://httpbin.org/post", {
        data = "test",
        owo = "whats this"
    })

    for k, v in pairs(res:json().json) do
        print(k, "=", v)
    end
    --[[
        data    =   test
        owo     =   whats this
    ]]

end

return http
