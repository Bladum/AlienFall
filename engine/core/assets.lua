---Asset Loading System
---
---Loads and manages all game assets (images, sounds, fonts) from the active mod's
---assets directory. Organizes assets by folder and provides dictionary-based access.
---Assets are loaded once at startup and cached for the entire game session.
---
---Asset Structure:
---  - assets.images[folder][filename] = Love2D Image object
---  - Example: assets.images["units"]["soldier.png"]
---  - Organized by mod folder structure
---
---Key Exports:
---  - Assets.load(): Loads all assets from active mod
---  - Assets.images: Dictionary of loaded images by folder
---  - Assets.get(folder, filename): Helper to retrieve specific asset
---
---Dependencies:
---  - mods.mod_manager: Provides active mod path
---  - love.graphics.newImage: Creates image objects from files
---  - love.filesystem: File system access for asset loading
---
---@module core.assets
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local Assets = require("core.assets")
---  Assets.load()
---  local soldierImage = Assets.images["units"]["soldier.png"]
---  love.graphics.draw(soldierImage, x, y)
---
---@see mods.mod_manager For mod path resolution
---@see core.data_loader For loading data files (TOML)

local ModManager = require("mods.mod_manager")

local Assets = {}

--- Load all assets from the active mod.
---
--- Scans the active mod's assets folder and loads all PNG images.
--- Organizes images by subfolder (units, terrain, ui, etc).
--- Automatically splits large images (>24×24) into 24×24 tile quads.
--- Should be called once during game initialization.
---
--- @return nil
--- @error Prints error if assets path cannot be resolved
--- @usage
---   Assets.load()
---   -- Assets now available in Assets.images table
function Assets.load()
    Assets.images = {}
    
    -- Get assets path from active mod
    local imagesPath = ModManager.getContentPath("assets")
    if not imagesPath then
        print("[Assets] ERROR: Could not get assets path from mod")
        return
    end
    
    local items = love.filesystem.getDirectoryItems(imagesPath)
    
    for _, folder in ipairs(items) do
        local folderPath = imagesPath .. "/" .. folder
        local info = love.filesystem.getInfo(folderPath)
        if info and info.type == "directory" then
            Assets.images[folder] = {}
            
            -- Get all files in folder
            local files = love.filesystem.getDirectoryItems(folderPath)
            for _, file in ipairs(files) do
                -- Check if it's a png file
                if file:match("%.png$") then
                    local imageName = file:gsub("%.png$", "") -- Remove extension
                    local imagePath = folderPath .. "/" .. file
                    local success, image = pcall(love.graphics.newImage, imagePath)
                    if success then
                        -- Check if image is larger than 24x24 (tile variations)
                        local width, height = image:getDimensions()
                        if width > 24 or height > 24 then
                            -- Split into 24x24 tiles
                            local tiles = {}
                            local tilesX = math.floor(width / 24)
                            local tilesY = math.floor(height / 24)
                            
                            for y = 0, tilesY - 1 do
                                for x = 0, tilesX - 1 do
                                    local quad = love.graphics.newQuad(x * 24, y * 24, 24, 24, width, height)
                                    table.insert(tiles, quad)
                                end
                            end
                            
                            Assets.images[folder][imageName] = {
                                image = image,
                                quads = tiles,
                                isTileVariation = true
                            }
                            print("[Assets] Loaded tile variations: " .. folder .. "/" .. imageName .. " (" .. #tiles .. " tiles)")
                        else
                            -- Single tile
                            Assets.images[folder][imageName] = {
                                image = image,
                                quads = nil,
                                isTileVariation = false
                            }
                            print("[Assets] Loaded " .. folder .. "/" .. imageName)
                        end
                    else
                        print("[Assets] Failed to load " .. imagePath .. ": " .. image)
                    end
                end
            end
        end
    end
    
    print("[Assets] Loaded " .. Assets.count() .. " images")
end

--- Get an asset by folder and name.
---
--- Retrieves an image from the loaded assets cache.
--- Returns image object and first quad if tile variation.
---
--- @param folder string Asset subfolder name (e.g., "units", "terrain")
--- @param name string Asset filename without extension (e.g., "soldier")
--- @return Image|nil Love2D Image object, or nil if not found
--- @return Quad|nil First quad if tile variation, nil otherwise
--- @return boolean True if asset has multiple tile quads
--- @usage
---   local image, quad, isTiled = Assets.get("units", "soldier")
---   if image then
---       love.graphics.draw(image, quad, x, y)
---   end
function Assets.get(folder, name)
    if Assets.images[folder] and Assets.images[folder][name] then
        local asset = Assets.images[folder][name]
        return asset.image, asset.quads and asset.quads[1] or nil, asset.isTileVariation
    end
    return nil
end

--- Get a specific quad from a tile variation asset.
---
--- For assets with multiple 24×24 tiles, retrieves specific quad by index.
--- Used for tile animations or variations.
---
--- @param folder string Asset subfolder name
--- @param name string Asset filename without extension
--- @param quadIndex number 1-based index of quad to retrieve
--- @return Image|nil Love2D Image object
--- @return Quad|nil Specific quad at index
--- @usage
---   -- Get 3rd tile variation
---   local image, quad = Assets.getQuad("terrain", "grass", 3)
function Assets.getQuad(folder, name, quadIndex)
    if Assets.images[folder] and Assets.images[folder][name] then
        local asset = Assets.images[folder][name]
        if asset.isTileVariation and asset.quads and quadIndex and quadIndex <= #asset.quads then
            return asset.image, asset.quads[quadIndex]
        end
    end
    return nil
end

--- Count total number of loaded assets.
---
--- Iterates through all folders and counts individual assets.
--- Used for loading statistics and debugging.
---
--- @return number Total asset count
function Assets.count()
    local count = 0
    for _, folder in pairs(Assets.images) do
        for _ in pairs(folder) do
            count = count + 1
        end
    end
    return count
end

--- Get a placeholder image for missing assets.
---
--- Returns a magenta 24×24 placeholder image used when requested
--- asset cannot be found. Placeholder is created once and cached.
--- Magenta color makes missing assets visually obvious.
---
--- @return Image Love2D Image object (24×24 magenta square)
--- @usage
---   local image = Assets.get("units", "missing") or Assets.getPlaceholder()
function Assets.getPlaceholder()
    -- Create a simple colored rectangle as placeholder
    if not Assets.placeholder then
        local placeholderData = love.image.newImageData(24, 24)
        -- Fill with a magenta color to indicate missing asset
        for y = 0, 23 do
            for x = 0, 23 do
                placeholderData:setPixel(x, y, 1, 0, 1, 1) -- Magenta
            end
        end
        Assets.placeholder = love.graphics.newImage(placeholderData)
    end
    return Assets.placeholder
end

--- Check if an asset exists in the cache.
---
--- Verifies that an asset has been loaded without actually
--- retrieving it. Useful for validation and fallback logic.
---
--- @param folder string Asset subfolder name
--- @param name string Asset filename without extension
--- @return boolean True if asset exists, false otherwise
--- @usage
---   if Assets.exists("units", "alien") then
---       drawAlien()
---   end
function Assets.exists(folder, name)
    return Assets.images[folder] and Assets.images[folder][name] ~= nil
end

return Assets
























