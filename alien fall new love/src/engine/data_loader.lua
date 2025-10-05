--- Data Loader Service
--
-- Central service for loading and managing game data from TOML configuration files.
-- Provides schema-aware loading, validation, error reporting, and mod directory resolution.
--
-- GROK: This is the main entry point for all data loading in the game.
-- It coordinates between the TOML parser, mod system, and data catalog.
--
-- @module engine.data_loader
-- @usage local DataLoader = require "engine.data_loader"
--        local loader = DataLoader.new({ telemetry = telemetry, logger = logger })
--        local data = loader:loadFile("mods/example_mod/data/units/units.toml")

local toml_loader = require "core.util.toml_loader"
local schema_validator = require "engine.schema_validator"

local DataLoader = {}
DataLoader.__index = DataLoader

--- Creates a new DataLoader instance
-- @param config table Configuration options
-- @param config.telemetry Telemetry Telemetry service for metrics
-- @param config.logger Logger Logger service for debugging
-- @param config.modLoader ModLoader Mod loader service for path resolution
-- @return DataLoader New data loader instance
function DataLoader.new(config)
    local self = setmetatable({}, DataLoader)
    config = config or {}
    
    self.telemetry = config.telemetry
    self.logger = config.logger
    self.modLoader = config.modLoader
    self.cache = {} -- Cache loaded files
    self.searchPaths = { "mods/", "data/" } -- Default search paths
    
    if self.logger then
        self.logger:info("DataLoader initialized")
    end
    
    return self
end

--- Load and parse a TOML file from the given path
-- Automatically resolves mod paths and caches results
-- @param filePath string Path to the TOML file (can be relative or absolute)
-- @param options table Optional loading options
-- @param options.cache boolean Whether to cache the result (default: true)
-- @param options.validate boolean Whether to validate the data (default: false)
-- @param options.schema string Schema name for validation
-- @return table Parsed TOML data as Lua table, or nil if loading fails
-- @return string Error message if loading fails
function DataLoader:loadFile(filePath, options)
    options = options or {}
    local useCache = options.cache ~= false
    
    -- Check cache first
    if useCache and self.cache[filePath] then
        if self.logger then
            self.logger:debug("DataLoader: Loading from cache: " .. filePath)
        end
        return self.cache[filePath]
    end
    
    -- Record telemetry
    if self.telemetry then
        self.telemetry:increment("data_loader.file_loads")
    end
    
    -- Resolve the file path
    local resolvedPath = self:resolvePath(filePath)
    if not resolvedPath then
        local err = "Failed to resolve path: " .. filePath
        if self.logger then
            self.logger:error("DataLoader: " .. err)
        end
        return nil, err
    end
    
    -- Load and parse the file
    local data, err = toml_loader.load(resolvedPath)
    if not data then
        if self.logger then
            self.logger:error("DataLoader: Failed to load " .. resolvedPath .. ": " .. (err or "unknown error"))
        end
        return nil, err
    end
    
    -- Validate if requested
    if options.validate and options.schema then
        local valid, validationErr = self:validate(data, options.schema)
        if not valid then
            if self.logger then
                self.logger:error("DataLoader: Validation failed for " .. resolvedPath .. ": " .. validationErr)
            end
            return nil, validationErr
        end
    end
    
    -- Cache the result
    if useCache then
        self.cache[filePath] = data
    end
    
    if self.logger then
        self.logger:debug("DataLoader: Successfully loaded " .. resolvedPath)
    end
    
    return data
end

--- Parse TOML content directly from a string
-- Useful for testing or dynamic content
-- @param content string TOML content as string
-- @param options table Optional parsing options
-- @param options.validate boolean Whether to validate the data
-- @param options.schema string Schema name for validation
-- @return table Parsed TOML data, or nil if parsing fails
-- @return string Error message if parsing fails
function DataLoader:parseString(content, options)
    options = options or {}
    
    if self.telemetry then
        self.telemetry:increment("data_loader.string_parses")
    end
    
    local data, err = toml_loader.parse(content)
    if not data then
        if self.logger then
            self.logger:error("DataLoader: Failed to parse TOML string: " .. (err or "unknown error"))
        end
        return nil, err
    end
    
    -- Validate if requested
    if options.validate and options.schema then
        local valid, validationErr = self:validate(data, options.schema)
        if not valid then
            return nil, validationErr
        end
    end
    
    return data
end

--- Resolve a file path by searching in configured search paths
-- Tries multiple locations and checks file existence
-- @param filePath string File path to resolve
-- @return string Resolved absolute path, or nil if not found
function DataLoader:resolvePath(filePath)
    -- If it's already an absolute path that exists, return it
    if love.filesystem.getInfo(filePath) then
        return filePath
    end
    
    -- Search in configured search paths
    for _, searchPath in ipairs(self.searchPaths) do
        local fullPath = searchPath .. filePath
        if love.filesystem.getInfo(fullPath) then
            return fullPath
        end
    end
    
    -- If mod loader is available, try to resolve through it
    if self.modLoader then
        -- Try to extract mod name and relative path
        local modName, relativePath = filePath:match("^([^/]+)/(.+)$")
        if modName then
            local modPath = "mods/" .. modName .. "/" .. relativePath
            if love.filesystem.getInfo(modPath) then
                return modPath
            end
        end
    end
    
    return nil
end

--- Add a search path for file resolution
-- @param path string Path to add to search paths
function DataLoader:addSearchPath(path)
    -- Ensure path ends with /
    if not path:match("/$") then
        path = path .. "/"
    end
    
    table.insert(self.searchPaths, path)
    
    if self.logger then
        self.logger:debug("DataLoader: Added search path: " .. path)
    end
end

--- Clear the file cache
-- Useful for development/hot-reloading
function DataLoader:clearCache()
    self.cache = {}
    
    if self.logger then
        self.logger:info("DataLoader: Cache cleared")
    end
    
    if self.telemetry then
        self.telemetry:increment("data_loader.cache_clears")
    end
end

--- Validate data against a schema
-- Uses schema_validator for comprehensive validation
-- @param data table Data to validate
-- @param schemaName string Name of the schema to validate against
-- @return boolean True if valid
-- @return string Error message if invalid
function DataLoader:validate(data, schemaName)
    -- Use schema_validator for validation
    local valid, err = schema_validator.validate(data, schemaName)
    
    if self.logger and not valid then
        self.logger:warn(string.format("DataLoader: Validation failed for schema '%s': %s", schemaName, err))
    end
    
    return valid, err
end

--- Load all TOML files from a directory
-- Recursively scans directory and loads all .toml files
-- @param dirPath string Directory path to scan
-- @param options table Optional loading options (passed to loadFile)
-- @return table Map of filename -> parsed data
-- @return table Map of filename -> error message for failed loads
function DataLoader:loadDirectory(dirPath, options)
    local results = {}
    local errors = {}
    
    if self.telemetry then
        self.telemetry:increment("data_loader.directory_loads")
    end
    
    -- Resolve directory path
    local resolvedDir = self:resolvePath(dirPath)
    if not resolvedDir then
        resolvedDir = dirPath
    end
    
    -- Get directory contents
    local items = love.filesystem.getDirectoryItems(resolvedDir)
    
    for _, item in ipairs(items) do
        local fullPath = resolvedDir .. "/" .. item
        local info = love.filesystem.getInfo(fullPath)
        
        if info then
            if info.type == "file" and item:match("%.toml$") then
                -- Load TOML file
                local data, err = self:loadFile(fullPath, options)
                if data then
                    results[item] = data
                else
                    errors[item] = err
                end
            elseif info.type == "directory" then
                -- Recursively load subdirectory
                local subResults, subErrors = self:loadDirectory(fullPath, options)
                for subItem, subData in pairs(subResults) do
                    results[item .. "/" .. subItem] = subData
                end
                for subItem, subErr in pairs(subErrors) do
                    errors[item .. "/" .. subItem] = subErr
                end
            end
        end
    end
    
    if self.logger then
        self.logger:debug(string.format("DataLoader: Loaded %d files from %s (%d errors)", 
            table.getn(results), resolvedDir, table.getn(errors)))
    end
    
    return results, errors
end

--- Get cache statistics
-- @return table Cache statistics
function DataLoader:getCacheStats()
    local count = 0
    for _ in pairs(self.cache) do
        count = count + 1
    end
    
    return {
        cached_files = count,
        search_paths = #self.searchPaths
    }
end

return DataLoader
