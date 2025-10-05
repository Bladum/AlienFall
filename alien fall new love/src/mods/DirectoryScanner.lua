--- Directory Scanner for Mod System
-- Recursively scans mod directories for TOML files
--
-- @module systems.mod_system.directory_scanner

local DirectoryScanner = {}
DirectoryScanner.__index = DirectoryScanner

--- Create a new directory scanner
-- @param opts table: Options (logger, etc.)
-- @return table: DirectoryScanner instance
function DirectoryScanner.new(opts)
    local self = setmetatable({}, DirectoryScanner)
    self.logger = opts and opts.logger or nil
    return self
end

--- Scan a directory recursively for TOML files
-- @param rootPath string: Root directory to scan
-- @param excludePatterns table: Array of patterns to exclude (optional)
-- @return table: Array of file paths relative to rootPath
function DirectoryScanner:scanForTomlFiles(rootPath, excludePatterns)
    local files = {}

    if not love or not love.filesystem then
        if self.logger then
            self.logger:warn("Love2D filesystem not available, cannot scan directories")
        end
        return files
    end

    if not love.filesystem.getInfo(rootPath, "directory") then
        if self.logger then
            self.logger:warn("Directory does not exist: " .. rootPath)
        end
        return files
    end

    self:scanDirectoryRecursive(rootPath, "", files, excludePatterns or {})

    return files
end

--- Recursively scan a directory
-- @param rootPath string: Original root path
-- @param currentPath string: Current relative path from root
-- @param files table: Output array to collect file paths
-- @param excludePatterns table: Patterns to exclude
function DirectoryScanner:scanDirectoryRecursive(rootPath, currentPath, files, excludePatterns)
    local fullPath = rootPath
    if currentPath ~= "" then
        fullPath = rootPath .. "/" .. currentPath
    end

    local items = love.filesystem.getDirectoryItems(fullPath)

    for _, item in ipairs(items) do
        local itemPath = currentPath == "" and item or currentPath .. "/" .. item
        local fullItemPath = rootPath .. "/" .. itemPath

        -- Check if item should be excluded
        if not self:shouldExclude(itemPath, excludePatterns) then
            local info = love.filesystem.getInfo(fullItemPath)

            if info then
                if info.type == "directory" then
                    -- Recurse into subdirectories
                    self:scanDirectoryRecursive(rootPath, itemPath, files, excludePatterns)
                elseif info.type == "file" and item:match("%.toml$") then
                    -- Found a TOML file
                    table.insert(files, itemPath)
                end
            end
        end
    end
end

--- Check if a path should be excluded based on patterns
-- @param path string: Path to check
-- @param excludePatterns table: Array of exclusion patterns
-- @return boolean: True if path should be excluded
function DirectoryScanner:shouldExclude(path, excludePatterns)
    -- Always exclude certain directories
    local alwaysExclude = {
        "^%.",  -- Hidden files/directories
        "^__MACOSX$",  -- macOS metadata
        "^%.DS_Store$",  -- macOS file
    }

    for _, pattern in ipairs(alwaysExclude) do
        if path:match(pattern) then
            return true
        end
    end

    -- Check user-provided patterns
    for _, pattern in ipairs(excludePatterns) do
        if path:match(pattern) then
            return true
        end
    end

    return false
end

--- Filter files by content type (requires content detector)
-- @param files table: Array of file paths
-- @param rootPath string: Root path for full file paths
-- @param contentDetector table: ContentDetector instance
-- @return table: Map of content_type -> array of file paths
function DirectoryScanner:filterByContentType(files, rootPath, contentDetector)
    local categorized = {}

    for _, filePath in ipairs(files) do
        local fullPath = rootPath .. "/" .. filePath
        local data, err = self:loadTomlFile(fullPath)

        if data then
            local contentType, confidence = contentDetector:detect(data, filePath)
            if contentType then
                if not categorized[contentType] then
                    categorized[contentType] = {}
                end
                table.insert(categorized[contentType], filePath)

                if self.logger then
                    self.logger:debug(string.format("Detected %s in %s (confidence: %d)",
                        contentType, filePath, confidence))
                end
            else
                if self.logger then
                    self.logger:warn("Could not detect content type for: " .. filePath)
                end
            end
        else
            if self.logger then
                self.logger:error(string.format("Failed to load TOML file %s: %s", fullPath, err))
            end
        end
    end

    return categorized
end

--- Load a TOML file
-- @param filePath string: Path to the TOML file
-- @return table|nil: Parsed data, or nil on error
-- @return string: Error message if loading failed
function DirectoryScanner:loadTomlFile(filePath)
    local TomlLoader = require "core.util.toml_loader"
    return TomlLoader.load(filePath)
end

return DirectoryScanner
