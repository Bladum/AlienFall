--- Map Tileset
-- Manages tile graphics, properties, and rendering data
--
-- @classmod battlescape.MapTileset

-- GROK: MapTileset manages tile sprites, animations, and rendering properties for battle maps
-- GROK: Provides tile graphics lookup, animation frames, and visual effects
-- GROK: Key methods: getTileSprite(), getTileAnimation(), getTileColor()
-- GROK: Supports seasonal variations, damage states, and environmental overlays

local class = require 'lib.Middleclass'

--- MapTileset class
-- @type MapTileset
MapTileset = class('MapTileset')

--- Create a new MapTileset instance
-- @param tilesetData Tileset configuration data
-- @return MapTileset instance
function MapTileset:initialize(tilesetData)
    self.name = tilesetData.name or "default"
    self.tileSize = tilesetData.tileSize or 20
    self.spriteSheet = tilesetData.spriteSheet
    self.tileDefinitions = tilesetData.tileDefinitions or {}
    self.animations = tilesetData.animations or {}
    self.seasonalVariants = tilesetData.seasonalVariants or {}
    self.damageStates = tilesetData.damageStates or {}

    -- Load tile definitions
    self:loadTileDefinitions()
end

--- Load tile definitions from data
function MapTileset:loadTileDefinitions()
    -- Default tile definitions for common materials
    self.defaultDefinitions = {
        grass = {
            sprite = "grass",
            color = {0.2, 0.8, 0.2},
            variants = 4,
            animation = nil
        },
        dirt = {
            sprite = "dirt",
            color = {0.6, 0.4, 0.2},
            variants = 2,
            animation = nil
        },
        concrete = {
            sprite = "concrete",
            color = {0.7, 0.7, 0.7},
            variants = 1,
            animation = nil
        },
        wood = {
            sprite = "wood",
            color = {0.5, 0.3, 0.1},
            variants = 3,
            animation = nil
        },
        metal = {
            sprite = "metal",
            color = {0.6, 0.6, 0.7},
            variants = 2,
            animation = nil
        },
        water = {
            sprite = "water",
            color = {0.1, 0.3, 0.8},
            variants = 1,
            animation = "water_flow"
        },
        stone = {
            sprite = "stone",
            color = {0.5, 0.5, 0.5},
            variants = 3,
            animation = nil
        },
        sand = {
            sprite = "sand",
            color = {0.9, 0.8, 0.6},
            variants = 2,
            animation = nil
        },
        rubble = {
            sprite = "rubble",
            color = {0.4, 0.4, 0.4},
            variants = 1,
            animation = nil
        }
    }

    -- Merge with loaded definitions
    for material, definition in pairs(self.defaultDefinitions) do
        if not self.tileDefinitions[material] then
            self.tileDefinitions[material] = definition
        end
    end
end

--- Get tile sprite information
-- @param material Tile material
-- @param variant Variant number (optional)
-- @return table Sprite information
function MapTileset:getTileSprite(material, variant)
    local definition = self.tileDefinitions[material]
    if not definition then
        return nil
    end

    variant = variant or 1
    if variant > definition.variants then
        variant = 1
    end

    return {
        sprite = definition.sprite,
        variant = variant,
        quad = self:getSpriteQuad(definition.sprite, variant)
    }
end

--- Get sprite quad for Love2D rendering
-- @param spriteName Sprite name
-- @param variant Variant number
-- @return Quad Love2D quad object
function MapTileset:getSpriteQuad(spriteName, variant)
    -- This would create actual Love2D quad objects
    -- For now, return placeholder data
    return {
        spriteName = spriteName,
        variant = variant,
        x = (variant - 1) * self.tileSize,
        y = 0,
        width = self.tileSize,
        height = self.tileSize
    }
end

--- Get tile color
-- @param material Tile material
-- @param damageState Damage state (optional)
-- @param environmentalEffects Environmental effects (optional)
-- @return table RGB color values
function MapTileset:getTileColor(material, damageState, environmentalEffects)
    local definition = self.tileDefinitions[material]
    if not definition then
        return {0.5, 0.5, 0.5} -- Default gray
    end

    local color = {unpack(definition.color)}

    -- Apply damage state
    if damageState and self.damageStates[damageState] then
        local damageColor = self.damageStates[damageState]
        color[1] = color[1] * damageColor.r
        color[2] = color[2] * damageColor.g
        color[3] = color[3] * damageColor.b
    end

    -- Apply environmental effects
    if environmentalEffects then
        if environmentalEffects.fire then
            color[1] = math.min(1.0, color[1] + 0.3) -- Red tint
            color[2] = color[2] * 0.7 -- Reduce green
            color[3] = color[3] * 0.7 -- Reduce blue
        end

        if environmentalEffects.smoke then
            -- Darken color for smoke
            local darken = environmentalEffects.smoke * 0.1
            color[1] = color[1] * (1.0 - darken)
            color[2] = color[2] * (1.0 - darken)
            color[3] = color[3] * (1.0 - darken)
        end
    end

    return color
end

--- Get tile animation
-- @param material Tile material
-- @return table Animation data or nil
function MapTileset:getTileAnimation(material)
    local definition = self.tileDefinitions[material]
    if not definition or not definition.animation then
        return nil
    end

    return self.animations[definition.animation]
end

--- Get seasonal variant
-- @param material Tile material
-- @param season Season name
-- @return table Seasonal variant data or nil
function MapTileset:getSeasonalVariant(material, season)
    if not self.seasonalVariants[season] then
        return nil
    end

    return self.seasonalVariants[season][material]
end

--- Get damage state overlay
-- @param damageState Damage state name
-- @return table Overlay sprite data or nil
function MapTileset:getDamageOverlay(damageState)
    return self.damageStates[damageState]
end

--- Get environmental effect overlay
-- @param effectType Effect type
-- @param intensity Effect intensity
-- @return table Overlay sprite data or nil
function MapTileset:getEnvironmentalOverlay(effectType, intensity)
    -- Environmental overlays (fire, smoke, etc.)
    local overlays = {
        fire = {
            sprite = "fire_overlay",
            color = {1.0, 0.3, 0.0, intensity * 0.5},
            animation = "fire_flicker"
        },
        smoke = {
            sprite = "smoke_overlay",
            color = {0.3, 0.3, 0.3, intensity * 0.3},
            animation = "smoke_drift"
        },
        destruction = {
            sprite = "destruction_overlay",
            color = {0.1, 0.1, 0.1, 0.8},
            animation = nil
        }
    }

    return overlays[effectType]
end

--- Get tile rendering data
-- @param tile BattleTile instance
-- @param timeOfDay Current time of day
-- @param weather Current weather
-- @return table Rendering data
function MapTileset:getTileRenderData(tile, timeOfDay, weather)
    local material = tile:getMaterial()
    local definition = self.tileDefinitions[material]

    if not definition then
        return {
            sprite = nil,
            color = {0.5, 0.5, 0.5},
            overlays = {}
        }
    end

    -- Base sprite
    local variant = self:getTileVariant(tile)
    local spriteData = self:getTileSprite(material, variant)

    -- Base color
    local color = self:getTileColor(material)

    -- Apply time of day
    color = self:applyTimeOfDayColor(color, timeOfDay)

    -- Apply weather
    color = self:applyWeatherColor(color, weather)

    -- Environmental overlays
    local overlays = {}

    if tile:isOnFire() then
        table.insert(overlays, self:getEnvironmentalOverlay("fire", 1.0))
    end

    if tile:isSmoky() then
        table.insert(overlays, self:getEnvironmentalOverlay("smoke", 0.5))
    end

    if tile:isDestroyed() then
        table.insert(overlays, self:getEnvironmentalOverlay("destruction", 1.0))
    end

    -- Damage overlay
    if tile:getFireDamage() > 0 then
        local damageState = self:getDamageState(tile:getFireDamage())
        local damageOverlay = self:getDamageOverlay(damageState)
        if damageOverlay then
            table.insert(overlays, damageOverlay)
        end
    end

    return {
        sprite = spriteData,
        color = color,
        overlays = overlays,
        animation = self:getTileAnimation(material)
    }
end

--- Get tile variant based on position (for visual variety)
-- @param tile BattleTile instance
-- @return number Variant number
function MapTileset:getTileVariant(tile)
    -- Simple pseudo-random variant based on position
    local seed = tile.x * 31 + tile.y * 17
    math.randomseed(seed)

    local definition = self.tileDefinitions[tile:getMaterial()]
    if not definition then
        return 1
    end

    return math.random(1, definition.variants)
end

--- Apply time of day color modification
-- @param color Base color
-- @param timeOfDay Time of day
-- @return table Modified color
function MapTileset:applyTimeOfDayColor(color, timeOfDay)
    local modifiers = {
        day = {1.0, 1.0, 1.0},
        dusk = {0.9, 0.8, 1.0},
        night = {0.3, 0.4, 0.8}
    }

    local modifier = modifiers[timeOfDay] or modifiers.day

    return {
        color[1] * modifier[1],
        color[2] * modifier[2],
        color[3] * modifier[3]
    }
end

--- Apply weather color modification
-- @param color Base color
-- @param weather Weather condition
-- @return table Modified color
function MapTileset:applyWeatherColor(color, weather)
    local modifiers = {
        clear = {1.0, 1.0, 1.0},
        cloudy = {0.8, 0.8, 0.9},
        rainy = {0.6, 0.7, 0.9},
        foggy = {0.7, 0.7, 0.8}
    }

    local modifier = modifiers[weather] or modifiers.clear

    return {
        color[1] * modifier[1],
        color[2] * modifier[2],
        color[3] * modifier[3]
    }
end

--- Get damage state based on damage amount
-- @param damage Damage amount
-- @return string Damage state
function MapTileset:getDamageState(damage)
    if damage >= 50 then
        return "destroyed"
    elseif damage >= 30 then
        return "heavy_damage"
    elseif damage >= 10 then
        return "light_damage"
    else
        return "normal"
    end
end

--- Get tileset name
-- @return string Tileset name
function MapTileset:getName()
    return self.name
end

--- Get tile size
-- @return number Tile size in pixels
function MapTileset:getTileSize()
    return self.tileSize
end

--- Check if tileset has material
-- @param material Material name
-- @return boolean Whether tileset has material
function MapTileset:hasMaterial(material)
    return self.tileDefinitions[material] ~= nil
end

--- Get all available materials
-- @return table List of material names
function MapTileset:getAvailableMaterials()
    local materials = {}
    for material, _ in pairs(self.tileDefinitions) do
        table.insert(materials, material)
    end
    return materials
end

--- Get tileset data for serialization
-- @return table Tileset data
function MapTileset:getData()
    return {
        name = self.name,
        tileSize = self.tileSize,
        tileDefinitions = self.tileDefinitions,
        animations = self.animations,
        seasonalVariants = self.seasonalVariants,
        damageStates = self.damageStates
    }
end

return MapTileset
