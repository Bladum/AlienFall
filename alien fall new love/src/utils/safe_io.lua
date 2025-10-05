--- Safe I/O Utilities for Error Handling
-- Provides safe wrappers for file operations with error recovery
-- All functions use pcall to prevent crashes from missing files
--
-- @module utils.safe_io

local SafeIO = {}

--- Get logger instance (lazy load to avoid circular dependencies)
local function getLogger()
    -- Try to get logger from service registry
    local ok, registry = pcall(require, "core.services.registry")
    if ok and registry and registry.resolve then
        local logger = registry:resolve("logger")
        if logger then
            return logger
        end
    end
    
    -- Fallback to print if logger not available
    return {
        error = function(_, msg) print("[ERROR] " .. msg) end,
        warn = function(_, msg) print("[WARN] " .. msg) end,
        info = function(_, msg) print("[INFO] " .. msg) end
    }
end

--- Safely require a Lua module with fallback
-- @param module_path string: Path to the module (e.g., "core.logger")
-- @param fallback any: Value to return if require fails (default: nil)
-- @return any: Module if successful, fallback value if failed
function SafeIO.safe_require(module_path, fallback)
    assert(type(module_path) == "string", "module_path must be a string")
    
    local ok, result = pcall(require, module_path)
    if not ok then
        local logger = getLogger()
        logger:error(string.format(
            "Failed to require module '%s': %s",
            module_path,
            tostring(result)
        ))
        return fallback
    end
    
    return result
end

--- Safely load a TOML file with fallback
-- @param filepath string: Path to TOML file
-- @param fallback table: Value to return if load fails (default: {})
-- @return table: Parsed TOML data if successful, fallback if failed
function SafeIO.safe_load_toml(filepath, fallback)
    assert(type(filepath) == "string", "filepath must be a string")
    
    fallback = fallback or {}
    
    -- Try to load TOML loader
    local toml = SafeIO.safe_require("lib.toml")
    if not toml or not toml.load then
        local logger = getLogger()
        logger:error(string.format(
            "TOML loader not available, cannot load '%s'",
            filepath
        ))
        return fallback
    end
    
    -- Try to load file
    local ok, data = pcall(toml.load, filepath)
    if not ok then
        local logger = getLogger()
        logger:error(string.format(
            "Failed to load TOML file '%s': %s",
            filepath,
            tostring(data)
        ))
        return fallback
    end
    
    return data
end

--- Safely load an image with fallback
-- @param filepath string: Path to image file
-- @param fallback_color table: RGB color for fallback texture {r, g, b} (default: pink)
-- @return Image: Love2D image object if successful, fallback texture if failed
function SafeIO.safe_load_image(filepath, fallback_color)
    assert(type(filepath) == "string", "filepath must be a string")
    assert(love and love.graphics and love.graphics.newImage, 
        "love.graphics.newImage is required")
    
    fallback_color = fallback_color or {1, 0, 1}  -- Pink for missing textures
    
    -- Try to load image
    local ok, image = pcall(love.graphics.newImage, filepath)
    if not ok then
        local logger = getLogger()
        logger:error(string.format(
            "Failed to load image '%s': %s",
            filepath,
            tostring(image)
        ))
        
        -- Create fallback texture (32x32 colored square)
        local imageData = love.image.newImageData(32, 32)
        for x = 0, 31 do
            for y = 0, 31 do
                imageData:setPixel(x, y, 
                    fallback_color[1], 
                    fallback_color[2], 
                    fallback_color[3], 
                    1.0)
            end
        end
        return love.graphics.newImage(imageData)
    end
    
    return image
end

--- Safely load a font with fallback
-- @param filepath string: Path to font file (optional, nil uses default font)
-- @param size number: Font size in points (default: 12)
-- @return Font: Love2D font object if successful, default font if failed
function SafeIO.safe_load_font(filepath, size)
    assert(love and love.graphics and love.graphics.newFont,
        "love.graphics.newFont is required")
    
    size = size or 12
    
    -- If no filepath, use default font
    if not filepath then
        return love.graphics.newFont(size)
    end
    
    assert(type(filepath) == "string", "filepath must be a string")
    
    -- Try to load custom font
    local ok, font = pcall(love.graphics.newFont, filepath, size)
    if not ok then
        local logger = getLogger()
        logger:error(string.format(
            "Failed to load font '%s' (size %d): %s - using default font",
            filepath,
            size,
            tostring(font)
        ))
        
        -- Fallback to default font
        return love.graphics.newFont(size)
    end
    
    return font
end

--- Safely read a file using love.filesystem
-- @param filepath string: Path to file (relative to save directory or source)
-- @param fallback string: Value to return if read fails (default: "")
-- @return string: File contents if successful, fallback if failed
function SafeIO.safe_read_file(filepath, fallback)
    assert(type(filepath) == "string", "filepath must be a string")
    assert(love and love.filesystem and love.filesystem.read,
        "love.filesystem.read is required")
    
    fallback = fallback or ""
    
    local ok, contents = pcall(love.filesystem.read, filepath)
    if not ok then
        local logger = getLogger()
        logger:error(string.format(
            "Failed to read file '%s': %s",
            filepath,
            tostring(contents)
        ))
        return fallback
    end
    
    return contents
end

--- Safely write a file using love.filesystem
-- @param filepath string: Path to file (relative to save directory)
-- @param contents string: Data to write
-- @return boolean: True if successful, false if failed
function SafeIO.safe_write_file(filepath, contents)
    assert(type(filepath) == "string", "filepath must be a string")
    assert(type(contents) == "string", "contents must be a string")
    assert(love and love.filesystem and love.filesystem.write,
        "love.filesystem.write is required")
    
    local ok, err = pcall(love.filesystem.write, filepath, contents)
    if not ok then
        local logger = getLogger()
        logger:error(string.format(
            "Failed to write file '%s': %s",
            filepath,
            tostring(err)
        ))
        return false
    end
    
    return true
end

--- Check if a file exists
-- @param filepath string: Path to file
-- @return boolean: True if file exists, false otherwise
function SafeIO.file_exists(filepath)
    assert(type(filepath) == "string", "filepath must be a string")
    
    if love and love.filesystem and love.filesystem.getInfo then
        local info = love.filesystem.getInfo(filepath)
        return info ~= nil and info.type == "file"
    end
    
    return false
end

--- Create a directory if it doesn't exist
-- @param path string: Directory path
-- @return boolean: True if directory exists or was created, false if failed
function SafeIO.ensure_directory(path)
    assert(type(path) == "string", "path must be a string")
    assert(love and love.filesystem and love.filesystem.createDirectory,
        "love.filesystem.createDirectory is required")
    
    -- Check if already exists
    if love.filesystem.getInfo(path, "directory") then
        return true
    end
    
    -- Try to create
    local ok, err = pcall(love.filesystem.createDirectory, path)
    if not ok then
        local logger = getLogger()
        logger:error(string.format(
            "Failed to create directory '%s': %s",
            path,
            tostring(err)
        ))
        return false
    end
    
    return true
end

return SafeIO
