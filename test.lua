local logit = require("logit")
local logger = logit:new("./", "TEST", nil, true)

logger(logit.OTHER, "O")
logger(logit.TRACE, "T")
logger(logit.DEBUG, "D")
logger(logit.INFO, "I")
logger(logit.WARN, "W")

logger:header("hello there, this is a header :p")
logger:expect(2 < 4, "2 isn't minor than 4!!!!!!!!")

logger(logit.ERROR, "E")
-- Never runs
logger(logit.FATAL, "F")