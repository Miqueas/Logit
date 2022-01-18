-- lua-language-server API
-- https://github.com/sumneko/lua-language-server
-- luacheck: no unused

---@class Logit
---@field Path string
---@field Namespace string
---@field Console boolean
---@field Suffix string
---@field OTHER integer 0
---@field TRACE integer 1
---@field DEBUG integer 2
---@field INFO integer 3
---@field WARN integer 4
---@field ERROR integer 5
---@field FATAL integer 6
local Logit = {}

---@param name? string
---@param dir? string
---@param console? boolean
---@param suffix? string
---@param header? string
---@param ...? any
---@return Logit
function Logit:new(name, dir, console, suffix, header, ...) end

---@param lvl number
---@param msg string
---@param ...? any
function Logit:log(lvl, msg, ...) end

---The equivalent of `assert()`
---@param exp any A Lua expression.
---@param msg? string The message you want to log.
---@param ...? any
---@return any
function Logit:expect(exp, msg, ...) end

---Write a log "header". Can be useful if you want to separate some logs
---or create "breakpoints", etc...
---@param msg string The message you want to log.
---@param ... any
function Logit:header(msg, ...) end

---Changes the suffix used in the log file names.
---@param str string
function Logit:set_suffix(str) end

return Logit
