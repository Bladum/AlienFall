-- Logger System - Centralized logging for debugging, analytics, and AI agents
-- Part of the Logging & Analytics System (Pattern 9)

local Logger = {}
Logger.__index = Logger

-- Singleton instance
local instance = nil

-- Log levels
Logger.LEVELS = {
    DEBUG = "DEBUG",
    INFO = "INFO",
    WARN = "WARN",
    ERROR = "ERROR",
    FATAL = "FATAL"
}

-- Log categories (determines which subfolder in logs/)
Logger.CATEGORIES = {
    GAME = "game",
    TEST = "tests",
    MOD = "mods",
    SYSTEM = "system",
    ANALYTICS = "analytics"
}

-- Initialize logger
function Logger:init(category)
    category = category or Logger.CATEGORIES.GAME

    -- Create instance if not exists
    if not instance then
        instance = setmetatable({}, Logger)
        instance.files = {}
        instance.enabled = true
        instance.console_output = true
    end

    -- Open log file for this category if not already open
    if not instance.files[category] then
        local timestamp = os.date("%Y-%m-%d_%H-%M-%S")
        local filename = string.format("logs/%s/%s_%s.log", category, category, timestamp)

        -- Ensure directory exists (Love2D will create it)
        local file, err = io.open(filename, "w")
        if file then
            instance.files[category] = {
                handle = file,
                filename = filename
            }
            -- Write header
            file:write(string.format("=== Log started: %s ===\n", os.date("%Y-%m-%d %H:%M:%S")))
            file:flush()
        else
            print(string.format("[LOGGER] ERROR: Could not open log file: %s (Error: %s)", filename, err or "unknown"))
        end
    end

    return instance
end

-- Get singleton instance
function Logger:getInstance()
    if not instance then
        Logger:init()
    end
    return instance
end

-- Log a message
function Logger:log(level, component, message, category)
    if not self.enabled then return end

    category = category or Logger.CATEGORIES.GAME
    level = level or Logger.LEVELS.INFO
    component = component or "UNKNOWN"

    local timestamp = os.date("%Y-%m-%d %H:%M:%S")
    local line = string.format("[%s] [%s] [%s] %s", timestamp, level, component, message)

    -- Write to file
    if self.files[category] and self.files[category].handle then
        self.files[category].handle:write(line .. "\n")
        self.files[category].handle:flush()  -- Immediate write for crash recovery
    end

    -- Also output to console if enabled
    if self.console_output then
        print(line)
    end
end

-- Convenience methods for different log levels
function Logger:debug(component, message, category)
    self:log(Logger.LEVELS.DEBUG, component, message, category)
end

function Logger:info(component, message, category)
    self:log(Logger.LEVELS.INFO, component, message, category)
end

function Logger:warn(component, message, category)
    self:log(Logger.LEVELS.WARN, component, message, category)
end

function Logger:error(component, message, category)
    self:log(Logger.LEVELS.ERROR, component, message, category)
end

function Logger:fatal(component, message, category)
    self:log(Logger.LEVELS.FATAL, component, message, category)
end

-- Log with automatic component detection (uses calling file name)
function Logger:auto(level, message, category)
    -- Try to determine component from call stack
    local info = debug.getinfo(2, "S")
    local component = "UNKNOWN"

    if info and info.source then
        -- Extract filename from source
        local source = info.source:match("@?(.+)$")
        if source then
            -- Get just the filename without path
            component = source:match("([^/\\]+)$") or source
            -- Remove .lua extension
            component = component:gsub("%.lua$", "")
            -- Uppercase for consistency
            component = component:upper()
        end
    end

    self:log(level, component, message, category)
end

-- Close all log files
function Logger:close()
    if not instance then return end

    for category, file_info in pairs(instance.files) do
        if file_info.handle then
            file_info.handle:write(string.format("=== Log ended: %s ===\n", os.date("%Y-%m-%d %H:%M:%S")))
            file_info.handle:close()
        end
    end
    instance.files = {}
end

-- Enable/disable logging
function Logger:setEnabled(enabled)
    self.enabled = enabled
end

-- Enable/disable console output
function Logger:setConsoleOutput(enabled)
    self.console_output = enabled
end

-- Get log file path for a category
function Logger:getLogFile(category)
    category = category or Logger.CATEGORIES.GAME
    if self.files[category] then
        return self.files[category].filename
    end
    return nil
end

-- Flush all log files
function Logger:flush()
    for category, file_info in pairs(self.files) do
        if file_info.handle then
            file_info.handle:flush()
        end
    end
end

return Logger

