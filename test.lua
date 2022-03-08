local logit = require("logit")
local logger = logit:new("./", "TEST", nil, true)

logger(logit.OTHER, "O")
logger(logit.OTHER)
logger(logit.TRACE, "T")
logger(logit.TRACE)
logger(logit.DEBUG, "D")
logger(logit.DEBUG)
logger(logit.INFO, "I")
logger(logit.INFO)
logger(logit.WARN, "W")
logger(logit.WARN)

logger:header("hello there, this is a header :p")
logger:expect(2 < 4, "2 isn't minor than 4!!!!!!!!")

--logger(logit.ERROR, "E")
-- Never runs
--logger(logit.ERROR)
logger(logit.FATAL, "F")
logger(logit.FATAL)