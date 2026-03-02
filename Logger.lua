
local local_logger = {}

local function log (level, message)
    print( level, message)
end

local_logger.log = log

return local_logger
