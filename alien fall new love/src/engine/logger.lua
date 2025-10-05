local Logger = {}
Logger.__index = Logger

-- Load inspect for better table printing
local inspect = require('lib.inspect')

local LEVELS = {
    trace = 10,
    debug = 20,
    info = 30,
    warn = 40,
    error = 50
}

function Logger.new(opts)
    local self = setmetatable({}, Logger)
    self.level = LEVELS[(opts and opts.level) or "info"] or LEVELS.info
    self.telemetry = opts and opts.telemetry or nil
    return self
end

function Logger:setLevel(level)
    self.level = LEVELS[level] or self.level
end

local function formatMessage(level, message, context)
    local prefix = string.format("[%s]", level:upper())
    if context then
        return string.format("%s %s | %s", prefix, context, message)
    end
    return string.format("%s %s", prefix, message)
end

function Logger:log(level, message, context)
    local severity = LEVELS[level] or LEVELS.info
    if severity < self.level then
        return
    end

    local line = formatMessage(level, message, context)
    print(line)
    if self.telemetry then
        self.telemetry:recordEvent({
            type = "log",
            level = level,
            message = message,
            context = context
        })
    end
end

function Logger:trace(message, context)
    self:log("trace", message, context)
end

function Logger:debug(message, context)
    self:log("debug", message, context)
end

function Logger:info(message, context)
    self:log("info", message, context)
end

function Logger:warn(message, context)
    self:log("warn", message, context)
end

function Logger:error(message, context)
    self:log("error", message, context)
end

--- Print table contents using inspect for debugging
--- @param tbl table The table to print
--- @param label string Optional label for the output
function Logger:printTable(tbl, label)
    if type(tbl) ~= "table" then
        self:warn("printTable called with non-table value: " .. type(tbl))
        return
    end
    
    local output = inspect(tbl)
    if label then
        self:debug(label .. ":\n" .. output)
    else
        self:debug("Table:\n" .. output)
    end
end

--- Dump any value with inspect (tables, functions, etc.)
--- @param value any The value to dump
--- @param label string Optional label for the output
function Logger:dump(value, label)
    local output = inspect(value)
    if label then
        self:debug(label .. ": " .. output)
    else
        self:debug("Value: " .. output)
    end
end

--- Shutdown logger and cleanup resources
function Logger:shutdown()
    -- Log final message
    self:info("Logger shutting down")
    -- Clear telemetry reference
    self.telemetry = nil
end

return Logger
