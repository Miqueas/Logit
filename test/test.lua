--[[ Official example doesn't work :/ API is outdated?

local Logit = require("Logit")
local log = Logit("MyScript", os.getenv("HOME"), true)
log("Log library started!", "info")
log("This is a debug message")

-- A little of code here...

local config = {} -- example function...
-- Like assert() function
log:expect(type(config) == "table", "user config can't be loaded")

-- More code here...
]]

---@type Logit
local Logit = require("Logit")
local log = Logit:new("Test", "./test", true)

log(3, "Log library started!")
log(2, "This is a debug message")

log:expect(true)
log:expect(false)
