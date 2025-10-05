--- Environment System
-- Manages environmental effects like smoke, fire, lighting, and terrain damage
--
-- @classmod battlescape.EnvironmentSystem

-- GROK: EnvironmentSystem handles dynamic environmental effects with deterministic propagation
-- GROK: Manages smoke/fire spread, lighting changes, terrain damage, and environmental hazards
-- GROK: Key methods: updateEnvironment(), applyEffect(), propagateEffects()
-- GROK: Integrates with map system for tile metadata updates and visual effects

local class = require 'lib.Middleclass'

--- EnvironmentSystem class
-- @type EnvironmentSystem
EnvironmentSystem = class('EnvironmentSystem')

--- Environmental effect types
-- @field SMOKE Smoke effect
-- @field FIRE Fire effect
-- @field LIGHTING Lighting effect
-- @field TERRAIN_DAMAGE Terrain damage effect
EnvironmentSystem.static.EFFECT_TYPES = {
    SMOKE = "smoke",
    FIRE = "fire",
    LIGHTING = "lighting",
    TERRAIN_DAMAGE = "terrain_damage"
}

--- Create a new EnvironmentSystem instance
-- @param battleState Reference to the current battle state
-- @return EnvironmentSystem instance
function EnvironmentSystem:initialize(battleState)
    self.battleState = battleState
    self.activeEffects = {} -- Active environmental effects by tile
    self.effectHistory = {} -- Track effect changes for debugging
    self.timeOfDay = "day" -- Current time of day
    self.weather = "clear" -- Current weather conditions
end

--- Update environment for a new turn
function EnvironmentSystem:updateEnvironment()
    self:propagateEffects()
    self:updateLighting()
    self:processEnvironmentalHazards()

    -- Trigger environment tick event
    self.battleState:triggerEvent('battlescape:environment_tick', {
        timeOfDay = self.timeOfDay,
        weather = self.weather,
        activeEffects = self:getActiveEffectsCount()
    })
end

--- Apply an environmental effect to a tile
-- @param x Tile X coordinate
-- @param y Tile Y coordinate
-- @param effectType Type of effect (smoke, fire, etc.)
-- @param intensity Effect intensity (1-10)
-- @param duration Effect duration in turns
-- @param source Source of the effect
-- @return boolean Success
function EnvironmentSystem:applyEffect(x, y, effectType, intensity, duration, source)
    local tileKey = self:getTileKey(x, y)

    if not self.activeEffects[tileKey] then
        self.activeEffects[tileKey] = {}
    end

    local existingEffect = self.activeEffects[tileKey][effectType]

    if existingEffect then
        -- Intensify existing effect
        existingEffect.intensity = math.min(10, existingEffect.intensity + intensity)
        existingEffect.duration = math.max(existingEffect.duration, duration)
    else
        -- Create new effect
        self.activeEffects[tileKey][effectType] = {
            type = effectType,
            intensity = intensity,
            duration = duration,
            source = source,
            startTurn = self.battleState:getCurrentTurn()
        }
    end

    -- Update tile metadata
    self:updateTileMetadata(x, y)

    -- Record in history
    table.insert(self.effectHistory, {
        x = x,
        y = y,
        effectType = effectType,
        intensity = intensity,
        duration = duration,
        source = source,
        turn = self.battleState:getCurrentTurn()
    })

    -- Trigger event
    self.battleState:triggerEvent('battlescape:environment_effect_applied', {
        x = x,
        y = y,
        effectType = effectType,
        intensity = intensity,
        duration = duration,
        source = source
    })

    return true
end

--- Remove an environmental effect from a tile
-- @param x Tile X coordinate
-- @param y Tile Y coordinate
-- @param effectType Type of effect to remove
-- @return boolean Success
function EnvironmentSystem:removeEffect(x, y, effectType)
    local tileKey = self:getTileKey(x, y)

    if self.activeEffects[tileKey] and self.activeEffects[tileKey][effectType] then
        self.activeEffects[tileKey][effectType] = nil

        -- Clean up empty effect containers
        if not next(self.activeEffects[tileKey]) then
            self.activeEffects[tileKey] = nil
        end

        -- Update tile metadata
        self:updateTileMetadata(x, y)

        -- Trigger event
        self.battleState:triggerEvent('battlescape:environment_effect_removed', {
            x = x,
            y = y,
            effectType = effectType
        })

        return true
    end

    return false
end

--- Propagate environmental effects to adjacent tiles
function EnvironmentSystem:propagateEffects()
    local newEffects = {}

    for tileKey, effects in pairs(self.activeEffects) do
        local x, y = self:parseTileKey(tileKey)

        for effectType, effect in pairs(effects) do
            -- Decrease duration
            effect.duration = effect.duration - 1

            -- Remove expired effects
            if effect.duration <= 0 then
                self:removeEffect(x, y, effectType)
            else
                -- Propagate effect to adjacent tiles
                self:propagateEffect(x, y, effectType, effect, newEffects)
            end
        end
    end

    -- Apply new propagated effects
    for _, newEffect in ipairs(newEffects) do
        self:applyEffect(newEffect.x, newEffect.y, newEffect.type,
                        newEffect.intensity, newEffect.duration, "propagation")
    end
end

--- Propagate a specific effect to adjacent tiles
-- @param x Source tile X
-- @param y Source tile Y
-- @param effectType Type of effect
-- @param effect Effect data
-- @param newEffects Table to collect new effects
function EnvironmentSystem:propagateEffect(x, y, effectType, effect, newEffects)
    if effectType == self.EFFECT_TYPES.FIRE then
        self:propagateFire(x, y, effect, newEffects)
    elseif effectType == self.EFFECT_TYPES.SMOKE then
        self:propagateSmoke(x, y, effect, newEffects)
    end
end

--- Propagate fire to adjacent tiles
-- @param x Source tile X
-- @param y Source tile Y
-- @param effect Fire effect data
-- @param newEffects Table to collect new effects
function EnvironmentSystem:propagateFire(x, y, effect, newEffects)
    local adjacentTiles = self:getAdjacentTiles(x, y)

    for _, tile in ipairs(adjacentTiles) do
        -- Check if tile is flammable
        if self:isTileFlammable(tile.x, tile.y) then
            -- Chance to spread based on intensity and distance
            local spreadChance = (effect.intensity * 10) -- 10-100% chance

            if math.random(1, 100) <= spreadChance then
                table.insert(newEffects, {
                    x = tile.x,
                    y = tile.y,
                    type = self.EFFECT_TYPES.FIRE,
                    intensity = math.max(1, effect.intensity - 1),
                    duration = effect.duration
                })
            end
        end
    end
end

--- Propagate smoke to adjacent tiles
-- @param x Source tile X
-- @param y Source tile Y
-- @param effect Smoke effect data
-- @param newEffects Table to collect new effects
function EnvironmentSystem:propagateSmoke(x, y, effect, newEffects)
    local adjacentTiles = self:getAdjacentTiles(x, y)

    for _, tile in ipairs(adjacentTiles) do
        -- Smoke spreads more easily than fire
        local spreadChance = math.min(80, effect.intensity * 15) -- Up to 80% chance

        if math.random(1, 100) <= spreadChance then
            table.insert(newEffects, {
                x = tile.x,
                y = tile.y,
                type = self.EFFECT_TYPES.SMOKE,
                intensity = math.max(1, effect.intensity - 1),
                duration = effect.duration + 1 -- Smoke lingers longer
            })
        end
    end
end

--- Get adjacent tiles
-- @param x Center tile X
-- @param y Center tile Y
-- @return table List of adjacent tiles
function EnvironmentSystem:getAdjacentTiles(x, y)
    local adjacent = {}

    for dx = -1, 1 do
        for dy = -1, 1 do
            if dx ~= 0 or dy ~= 0 then
                local nx, ny = x + dx, y + dy
                if self.battleState:getMap():isValidTile(nx, ny) then
                    table.insert(adjacent, {x = nx, y = ny})
                end
            end
        end
    end

    return adjacent
end

--- Check if a tile is flammable
-- @param x Tile X coordinate
-- @param y Tile Y coordinate
-- @return boolean Whether tile is flammable
function EnvironmentSystem:isTileFlammable(x, y)
    local tile = self.battleState:getMap():getTile(x, y)
    if not tile then return false end

    -- Check tile material
    local flammableMaterials = {
        "wood",
        "grass",
        "crops",
        "furniture",
        "cloth"
    }

    for _, material in ipairs(flammableMaterials) do
        if tile.material == material then
            return true
        end
    end

    return false
end

--- Update lighting based on time of day and weather
function EnvironmentSystem:updateLighting()
    -- Update vision radii and lighting effects
    local lightingData = self:getLightingData()

    -- Apply lighting to all units
    for _, unit in ipairs(self.battleState:getAllUnits()) do
        local visionRadius = self:calculateVisionRadius(unit, lightingData)
        unit:setVisionRadius(visionRadius)
    end
end

--- Get current lighting data
-- @return table Lighting configuration
function EnvironmentSystem:getLightingData()
    local lightingConfigs = {
        day = {
            clear = { brightness = 1.0, visionModifier = 1.0 },
            cloudy = { brightness = 0.8, visionModifier = 0.9 },
            rainy = { brightness = 0.6, visionModifier = 0.8 }
        },
        dusk = {
            clear = { brightness = 0.7, visionModifier = 0.8 },
            cloudy = { brightness = 0.5, visionModifier = 0.7 },
            rainy = { brightness = 0.4, visionModifier = 0.6 }
        },
        night = {
            clear = { brightness = 0.3, visionModifier = 0.5 },
            cloudy = { brightness = 0.2, visionModifier = 0.4 },
            rainy = { brightness = 0.1, visionModifier = 0.3 }
        }
    }

    return lightingConfigs[self.timeOfDay][self.weather]
end

--- Calculate vision radius for a unit
-- @param unit The unit
-- @param lightingData Current lighting data
-- @return number Vision radius
function EnvironmentSystem:calculateVisionRadius(unit, lightingData)
    local baseRadius = unit:getBaseVisionRadius()
    local modifier = lightingData.visionModifier

    -- Apply unit-specific modifiers
    if unit:getTrait("night_vision") then
        modifier = modifier * 1.5
    end

    -- Apply equipment modifiers
    if unit:hasEquipment("night_vision_goggles") then
        modifier = modifier * 1.3
    end

    -- Apply status effects
    if unit:hasStatusEffect("blinded") then
        modifier = modifier * 0.3
    end

    return math.floor(baseRadius * modifier)
end

--- Process environmental hazards (damage from fire, etc.)
function EnvironmentSystem:processEnvironmentalHazards()
    for tileKey, effects in pairs(self.activeEffects) do
        local x, y = self:parseTileKey(tileKey)

        -- Check for units in hazardous tiles
        local unit = self.battleState:getUnitAt(x, y)
        if unit then
            self:applyHazardEffects(unit, effects)
        end

        -- Apply terrain damage
        if effects[self.EFFECT_TYPES.FIRE] then
            self:applyTerrainDamage(x, y, effects[self.EFFECT_TYPES.FIRE])
        end
    end
end

--- Apply hazard effects to a unit
-- @param unit The unit in hazard
-- @param effects Active effects on the tile
function EnvironmentSystem:applyHazardEffects(unit, effects)
    if effects[self.EFFECT_TYPES.FIRE] then
        -- Fire damage
        local damage = effects[self.EFFECT_TYPES.FIRE].intensity
        unit:takeDamage(damage, "fire")

        -- Morale effect
        self.battleState:getMoraleSystem():applyMoraleDamage(unit, damage, "fire_damage")
    end

    if effects[self.EFFECT_TYPES.SMOKE] then
        -- Smoke effects: reduced accuracy, coughing
        unit:setStatusEffect("smoke_exposure", true)

        -- Accuracy penalty
        local accuracyPenalty = effects[self.EFFECT_TYPES.SMOKE].intensity * 10
        unit:setAccuracyModifier(-accuracyPenalty)
    end
end

--- Apply terrain damage
-- @param x Tile X coordinate
-- @param y Tile Y coordinate
-- @param fireEffect Fire effect data
function EnvironmentSystem:applyTerrainDamage(x, y, fireEffect)
    local tile = self.battleState:getMap():getTile(x, y)
    if not tile then return end

    -- Accumulate fire damage
    tile.fireDamage = (tile.fireDamage or 0) + fireEffect.intensity

    -- Check for destruction threshold
    if tile.fireDamage >= 50 then
        self:destroyTile(x, y)
    elseif tile.fireDamage >= 30 then
        -- Heavy damage
        tile.walkable = false
        tile.cover = math.max(0, tile.cover - 2)
    elseif tile.fireDamage >= 10 then
        -- Light damage
        tile.cover = math.max(0, tile.cover - 1)
    end
end

--- Destroy a tile (collapse, burn down, etc.)
-- @param x Tile X coordinate
-- @param y Tile Y coordinate
function EnvironmentSystem:destroyTile(x, y)
    local tile = self.battleState:getMap():getTile(x, y)
    if not tile then return end

    tile.destroyed = true
    tile.walkable = false
    tile.cover = 0
    tile.material = "rubble"

    -- Remove all effects from destroyed tile
    local tileKey = self:getTileKey(x, y)
    self.activeEffects[tileKey] = nil

    -- Trigger event
    self.battleState:triggerEvent('battlescape:tile_destroyed', {
        x = x,
        y = y,
        oldMaterial = tile.material
    })
end

--- Update tile metadata based on active effects
-- @param x Tile X coordinate
-- @param y Tile Y coordinate
function EnvironmentSystem:updateTileMetadata(x, y)
    local tile = self.battleState:getMap():getTile(x, y)
    if not tile then return end

    local tileKey = self:getTileKey(x, y)
    local effects = self.activeEffects[tileKey] or {}

    -- Reset effect-based metadata
    tile.onFire = false
    tile.smoky = false
    tile.visibilityModifier = 1.0

    -- Apply effect metadata
    if effects[self.EFFECT_TYPES.FIRE] then
        tile.onFire = true
        tile.visibilityModifier = tile.visibilityModifier * 0.7
    end

    if effects[self.EFFECT_TYPES.SMOKE] then
        tile.smoky = true
        tile.visibilityModifier = tile.visibilityModifier * (1.0 - effects[self.EFFECT_TYPES.SMOKE].intensity * 0.1)
    end
end

--- Set time of day
-- @param timeOfDay New time of day (day, dusk, night)
function EnvironmentSystem:setTimeOfDay(timeOfDay)
    self.timeOfDay = timeOfDay
    self:updateLighting()
end

--- Set weather conditions
-- @param weather New weather (clear, cloudy, rainy)
function EnvironmentSystem:setWeather(weather)
    self.weather = weather
    self:updateLighting()
end

--- Get tile key for indexing
-- @param x Tile X coordinate
-- @param y Tile Y coordinate
-- @return string Tile key
function EnvironmentSystem:getTileKey(x, y)
    return string.format("%d,%d", x, y)
end

--- Parse tile key
-- @param tileKey Tile key string
-- @return number x, number y
function EnvironmentSystem:parseTileKey(tileKey)
    local x, y = tileKey:match("(%d+),(%d+)")
    return tonumber(x), tonumber(y)
end

--- Get active effects count
-- @return table Effect counts by type
function EnvironmentSystem:getActiveEffectsCount()
    local counts = {}

    for _, effects in pairs(self.activeEffects) do
        for effectType, _ in pairs(effects) do
            counts[effectType] = (counts[effectType] or 0) + 1
        end
    end

    return counts
end

--- Get effects at a specific tile
-- @param x Tile X coordinate
-- @param y Tile Y coordinate
-- @return table Active effects at tile
function EnvironmentSystem:getEffectsAt(x, y)
    local tileKey = self:getTileKey(x, y)
    return self.activeEffects[tileKey] or {}
end

--- Clear all environmental effects (for new battle)
function EnvironmentSystem:clearEffects()
    self.activeEffects = {}
    self.effectHistory = {}
end

--- Get effect history
-- @return table Effect application history
function EnvironmentSystem:getEffectHistory()
    return self.effectHistory
end

return EnvironmentSystem
