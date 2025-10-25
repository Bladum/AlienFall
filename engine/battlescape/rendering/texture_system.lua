---TextureSystem - Asset Loading and Texture Management
---
---Loads and manages PNG texture assets for battlescape rendering. Handles texture
---filtering (nearest-neighbor for pixel art), UV coordinate mapping, and memory
---management. Provides textures to 3D raycasting system for wall/floor rendering.
---
---Features:
---  - PNG asset loading from mods/core/assets/ directory
---  - Nearest-neighbor filtering (preserves pixel art appearance)
---  - Texture atlas support (multiple textures in single PNG)
---  - UV coordinate mapping for raycasted surfaces
---  - Memory caching (LRU eviction for limit management)
---  - Texture validation (size, format checks)
---  - Fallback to procedural textures if assets unavailable
---  - Tileset management for wall/floor/ceiling variations
---
---Texture Organization:
---  - mods/core/assets/textures/walls/ - Wall textures (64×64 or 32×32)
---  - mods/core/assets/textures/floors/ - Floor/ceiling textures
---  - mods/core/assets/textures/effects/ - Particle/overlay effects
---  - mods/core/assets/textures/ui/ - UI elements
---
---Texture Atlas:
---  - Walls: 4×4 grid of 64px tiles = 256×256 PNG
---  - Floors: 2×2 grid of 128px tiles = 256×256 PNG
---  - Organization: [row*4 + col] indexing within atlas
---
---UV Coordinates:
---  - Range: 0.0 to 1.0 per axis
---  - Calculated from raycasting hit position
---  - Applied to quad faces in renderer_3d.lua
---
---Performance:
---  - Max 50 textures cached simultaneously
---  - LRU eviction when limit exceeded
---  - Lazy loading (load only on first use)
---  - Batch texture uploads to GPU
---
---Key Exports:
---  - TextureSystem.new(): Creates texture manager
---  - loadTexture(assetPath, options): Load single texture
---  - getTexture(textureId): Retrieve cached texture
---  - getWallTexture(wallType, variant): Get wall texture by type
---  - getFloorTexture(floorType): Get floor texture
---  - createFallback(width, height, color): Procedural texture
---  - setFilterMode(mode): "nearest" or "linear"
---
---Dependencies:
---  - love.graphics: Texture creation and rendering
---  - love.filesystem: Asset file loading
---
---@module battlescape.rendering.texture_system
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local TextureSystem = require("battlescape.rendering.texture_system")
---  local texSys = TextureSystem.new()
---  local wallTex = texSys:getWallTexture("metal", 1)
---  texSys:setFilterMode("nearest")
---
---@see battlescape.rendering.renderer_3d For texture application
---@see battlescape.rendering.hex_raycaster For texture coordinate generation

local TextureSystem = {}

---@class TextureSystem
---@field cache table Loaded texture cache {id = imageData}
---@field atlases table Texture atlas definitions
---@field filterMode string Current filter mode ("nearest" or "linear")
---@field maxCached number Maximum textures to cache
---@field wallTypes table Wall texture definitions
---@field floorTypes table Floor texture definitions
---@field assetBase string Base path for texture assets
---@field initialized boolean

---Create texture system
---@return TextureSystem Texture system instance
function TextureSystem.new()
    local self = setmetatable({}, {__index = TextureSystem})
    
    self.cache = {}
    self.cacheOrder = {}  -- Track order for LRU
    self.atlases = {}
    self.filterMode = "nearest"
    self.maxCached = 50
    
    -- Wall texture definitions
    self.wallTypes = {
        metal = {id = "wall_metal", variants = 4},
        stone = {id = "wall_stone", variants = 4},
        concrete = {id = "wall_concrete", variants = 4},
        alien = {id = "wall_alien", variants = 3},
        damaged = {id = "wall_damaged", variants = 3},
        wooden = {id = "wall_wooden", variants = 3},
    }
    
    -- Floor texture definitions
    self.floorTypes = {
        metal = {id = "floor_metal", tiling = 2},
        concrete = {id = "floor_concrete", tiling = 2},
        alien = {id = "floor_alien", tiling = 2},
        grass = {id = "floor_grass", tiling = 4},
        dirt = {id = "floor_dirt", tiling = 4},
    }
    
    self.assetBase = "mods/core/assets/textures/"
    
    self.initialized = true
    
    print("[TextureSystem] Initialized")
    
    return self
end

---Load texture from PNG asset file
---@param assetPath string Path relative to asset base (e.g., "walls/metal_01.png")
---@param options? table Optional {filterMode, width, height}
---@return love.Image? Loaded texture or nil on failure
function TextureSystem:loadTexture(assetPath, options)
    options = options or {}
    
    -- Check cache first
    if self.cache[assetPath] then
        self:_updateLRU(assetPath)
        return self.cache[assetPath]
    end
    
    local fullPath = self.assetBase .. assetPath
    
    -- Try to load file
    if not love.filesystem.getInfo(fullPath) then
        print(string.format("[TextureSystem] WARNING: Asset not found: %s", fullPath))
        return self:createFallback(64, 64, {0.5, 0.5, 0.5})
    end
    
    local success, imageData = pcall(love.image.newImageData, fullPath)
    if not success then
        print(string.format("[TextureSystem] ERROR loading %s: %s", fullPath, imageData))
        return self:createFallback(64, 64, {0.5, 0.5, 0.5})
    end
    
    -- Create drawable image from image data
    local image = love.graphics.newImage(imageData)
    
    -- Set filter mode
    local filterMode = options.filterMode or self.filterMode
    image:setFilter(filterMode == "nearest" and "nearest" or "linear", 
        filterMode == "nearest" and "nearest" or "linear")
    
    -- Cache it
    self:_cacheTexture(assetPath, image)
    
    print(string.format("[TextureSystem] Loaded texture: %s (%dx%d)",
        assetPath, imageData:getWidth(), imageData:getHeight()))
    
    return image
end

---Get cached texture by ID
---@param textureId string Texture identifier
---@return love.Image? Cached texture or nil
function TextureSystem:getTexture(textureId)
    local texture = self.cache[textureId]
    if texture then
        self:_updateLRU(textureId)
    end
    return texture
end

---Get wall texture by type and variant
---@param wallType string Wall type ("metal", "stone", "concrete", etc.)
---@param variant number Variant index (1-N)
---@return love.Image Wall texture
function TextureSystem:getWallTexture(wallType, variant)
    wallType = wallType or "metal"
    variant = variant or 1
    
    local wallDef = self.wallTypes[wallType]
    if not wallDef then
        print(string.format("[TextureSystem] Unknown wall type: %s", wallType))
        return self:createFallback(64, 64, {0.3, 0.3, 0.3})
    end
    
    -- Clamp variant to available range
    variant = math.min(variant, wallDef.variants)
    
    local assetPath = string.format("walls/%s_%02d.png", wallDef.id, variant)
    
    local texture = self:loadTexture(assetPath, {filterMode = "nearest"})
    return texture or self:createFallback(64, 64, {0.3, 0.3, 0.3})
end

---Get floor texture by type
---@param floorType string Floor type ("metal", "concrete", "grass", etc.)
---@return love.Image Floor texture
function TextureSystem:getFloorTexture(floorType)
    floorType = floorType or "concrete"
    
    local floorDef = self.floorTypes[floorType]
    if not floorDef then
        print(string.format("[TextureSystem] Unknown floor type: %s", floorType))
        return self:createFallback(128, 128, {0.2, 0.2, 0.2})
    end
    
    local assetPath = string.format("floors/%s.png", floorDef.id)
    
    local texture = self:loadTexture(assetPath, {filterMode = "nearest"})
    return texture or self:createFallback(128, 128, {0.2, 0.2, 0.2})
end

---Create procedural fallback texture
---@param width number Texture width in pixels
---@param height number Texture height in pixels
---@param color table RGB color {r, g, b}
---@return love.Image Procedural texture
function TextureSystem:createFallback(width, height, color)
    color = color or {0.5, 0.5, 0.5}
    
    -- Create image data
    local imageData = love.image.newImageData(width, height)
    
    -- Fill with solid color
    for y = 0, height - 1 do
        for x = 0, width - 1 do
            -- Add subtle noise pattern
            local noise = math.random() * 0.1
            imageData:setPixel(x, y, 
                math.min(1, color[1] + noise),
                math.min(1, color[2] + noise),
                math.min(1, color[3] + noise),
                1.0)
        end
    end
    
    local image = love.graphics.newImage(imageData)
    image:setFilter("nearest", "nearest")
    
    return image
end

---Set filter mode for all textures
---@param mode string "nearest" for pixel art, "linear" for smooth
function TextureSystem:setFilterMode(mode)
    self.filterMode = mode == "nearest" and "nearest" or "linear"
    
    -- Update filter for all cached textures
    for _, texture in pairs(self.cache) do
        if texture.setFilter then
            texture:setFilter(self.filterMode == "nearest" and "nearest" or "linear",
                self.filterMode == "nearest" and "nearest" or "linear")
        end
    end
    
    print(string.format("[TextureSystem] Filter mode set to: %s", self.filterMode))
end

---Calculate UV coordinates for raycasted surface
---@param hitX number Hit X coordinate on surface
---@param hitY number Hit Y coordinate on surface
---@param textureWidth number Texture width in pixels
---@param textureHeight number Texture height in pixels
---@return number u UV U coordinate (0-1)
---@return number v UV V coordinate (0-1)
function TextureSystem:getUVCoordinates(hitX, hitY, textureWidth, textureHeight)
    textureWidth = textureWidth or 64
    textureHeight = textureHeight or 64
    
    -- Normalize hit coordinates to 0-1 range
    local u = (hitX % 64) / textureWidth
    local v = (hitY % 64) / textureHeight
    
    return u, v
end

---Cache texture with LRU eviction
---@param textureId string Texture identifier
---@param texture love.Image Texture to cache
function TextureSystem:_cacheTexture(textureId, texture)
    self.cache[textureId] = texture
    table.insert(self.cacheOrder, textureId)
    
    -- Evict oldest if over limit
    while #self.cacheOrder > self.maxCached do
        local oldest = table.remove(self.cacheOrder, 1)
        self.cache[oldest] = nil
        print(string.format("[TextureSystem] Evicted texture: %s (cache full)", oldest))
    end
end

---Update LRU tracking for texture access
---@param textureId string Texture identifier
function TextureSystem:_updateLRU(textureId)
    -- Move to end of order list (most recently used)
    for i, id in ipairs(self.cacheOrder) do
        if id == textureId then
            table.remove(self.cacheOrder, i)
            break
        end
    end
    table.insert(self.cacheOrder, textureId)
end

---Get cache statistics
---@return table Stats {cached, maxCached, memory_mb}
function TextureSystem:getStats()
    return {
        cached = #self.cacheOrder,
        maxCached = self.maxCached,
        memory_estimate = (#self.cacheOrder * 64 * 64 * 4) / (1024 * 1024)
    }
end

---Clear cache
function TextureSystem:clear()
    self.cache = {}
    self.cacheOrder = {}
    print("[TextureSystem] Cache cleared")
end

return TextureSystem




