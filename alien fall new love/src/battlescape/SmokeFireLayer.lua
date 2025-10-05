--- SmokeFireLayer.lua
-- Implements tile hazard system for smoke and fire effects
-- Handles propagation, dissipation, visibility occlusion, and unit effects
-- Deterministic with seeded RNG for reproducible environmental cascades

local Class = require("util.Class")
local RNG = require("services.rng")

---@class SmokeFireLayer
---@field private _missionSeed number Mission seed for deterministic RNG
---@field private _map table Reference to battle map
---@field private _hazards table Map of tile hazards {x,y -> hazardData}
---@field private _turnCounter number Current turn for aging calculations
local SmokeFireLayer = Class()

---Initialize SmokeFireLayer system
---@param missionSeed number Mission seed for deterministic RNG
---@param map table Battle map reference
function SmokeFireLayer:init(missionSeed, map)
    self._missionSeed = missionSeed
    self._map = map
    self._hazards = {}
    self._turnCounter = 0
end

---Create hazard data structure
---@param hazardType string "smoke" or "fire"
---@param intensity number Initial intensity (0-100)
---@param fuelType string Optional fuel type for propagation
---@return table hazardData
function SmokeFireLayer:createHazard(hazardType, intensity, fuelType)
    return {
        type = hazardType,
        intensity = intensity,
        maxIntensity = intensity,
        fuelType = fuelType or "standard",
        age = 0,
        extinguishAttempts = 0,
        createdTurn = self._turnCounter
    }
end

---Add hazard to a tile
---@param x number Tile X coordinate
---@param y number Tile Y coordinate
---@param hazardType string "smoke" or "fire"
---@param intensity number Initial intensity (0-100)
---@param fuelType string Optional fuel type
function SmokeFireLayer:addHazard(x, y, hazardType, intensity, fuelType)
    local key = x .. "," .. y
    self._hazards[key] = self:createHazard(hazardType, intensity, fuelType)
end

---Remove hazard from a tile
---@param x number Tile X coordinate
---@param y number Tile Y coordinate
function SmokeFireLayer:removeHazard(x, y)
    local key = x .. "," .. y
    self._hazards[key] = nil
end

---Get hazard at tile
---@param x number Tile X coordinate
---@param y number Tile Y coordinate
---@return table|nil hazardData
function SmokeFireLayer:getHazard(x, y)
    local key = x .. "," .. y
    return self._hazards[key]
end

---Check if tile has hazard
---@param x number Tile X coordinate
---@param y number Tile Y coordinate
---@return boolean hasHazard
function SmokeFireLayer:hasHazard(x, y)
    return self:getHazard(x, y) ~= nil
end

---Get visibility occlusion for a tile
---@param x number Tile X coordinate
---@param y number Tile Y coordinate
---@return number occlusionCost
function SmokeFireLayer:getVisibilityOcclusion(x, y)
    local hazard = self:getHazard(x, y)
    if not hazard then return 0 end

    local intensityFactor = hazard.intensity / 100

    if hazard.type == "smoke" then
        return 4 * intensityFactor -- Base smoke occlusion
    elseif hazard.type == "fire" then
        return 3 * intensityFactor -- Fire also blocks visibility
    end

    return 0
end

---Apply per-turn effects to units in hazards
---@param units table List of units to check
function SmokeFireLayer:applyUnitEffects(units)
    for _, unit in ipairs(units) do
        local hazard = self:getHazard(unit.x, unit.y)
        if hazard then
            local intensityFactor = hazard.intensity / 100

            if hazard.type == "smoke" then
                -- Apply STUN accumulation
                local stunAmount = math.floor(1 * intensityFactor)
                if stunAmount > 0 then
                    unit.stun = (unit.stun or 0) + stunAmount
                end
            elseif hazard.type == "fire" then
                -- Apply damage and burning status
                local damage = math.floor(5 * intensityFactor)
                if damage > 0 then
                    unit.health = unit.health - damage
                    unit.burning = true
                    unit.burningDuration = unit.burningDuration or 3
                end
            end
        end
    end
end

---Process burning status for units
---@param units table List of units to check
function SmokeFireLayer:processBurningUnits(units)
    for _, unit in ipairs(units) do
        if unit.burning then
            -- Tick down burning duration
            unit.burningDuration = unit.burningDuration - 1

            if unit.burningDuration <= 0 then
                unit.burning = false
                -- Chance for self-extinguish
                local rng = RNG:createSeededRNG(self._missionSeed + unit.id + self._turnCounter)
                if rng:random() < 0.3 then -- 30% chance to extinguish
                    unit.burning = false
                else
                    unit.burningDuration = 1 -- Reset for another turn
                end
            end
        end
    end
end

---Propagate hazards to adjacent tiles
function SmokeFireLayer:propagateHazards()
    local newHazards = {}
    local rng = RNG:createSeededRNG(self._missionSeed + self._turnCounter)

    for key, hazard in pairs(self._hazards) do
        if hazard.intensity > 10 then -- Only propagate if intense enough
            local x, y = key:match("(%d+),(%d+)")
            x, y = tonumber(x), tonumber(y)

            -- Check adjacent tiles
            local directions = {
                {0, 1}, {1, 0}, {0, -1}, {-1, 0},
                {1, 1}, {1, -1}, {-1, 1}, {-1, -1}
            }

            for _, dir in ipairs(directions) do
                local nx, ny = x + dir[1], y + dir[2]
                local nkey = nx .. "," .. ny

                if self._map:isValidTile(nx, ny) and not self._hazards[nkey] then
                    local tile = self._map:getTile(nx, ny)

                    -- Calculate propagation chance
                    local baseChance = 0.3 -- Base propagation chance
                    local intensityFactor = hazard.intensity / 100
                    local fuelMultiplier = self:getFuelMultiplier(hazard.fuelType)
                    local terrainFactor = self:getTerrainFlammability(tile)

                    local propagationChance = baseChance * intensityFactor * fuelMultiplier * terrainFactor

                    if rng:random() < propagationChance then
                        -- Create new hazard with reduced intensity
                        local newIntensity = math.floor(hazard.intensity * 0.6)
                        if newIntensity > 5 then
                            newHazards[nkey] = self:createHazard(hazard.type, newIntensity, hazard.fuelType)
                        end
                    end
                end
            end
        end
    end

    -- Add new hazards
    for key, hazard in pairs(newHazards) do
        self._hazards[key] = hazard
    end
end

---Get fuel propagation multiplier
---@param fuelType string Fuel type
---@return number multiplier
function SmokeFireLayer:getFuelMultiplier(fuelType)
    local multipliers = {
        wood = 1.2,
        gasoline = 2.0,
        dry_grass = 1.5,
        standard = 1.0
    }

    return multipliers[fuelType] or 1.0
end

---Get terrain flammability factor
---@param tile table Tile data
---@return number factor
function SmokeFireLayer:getTerrainFlammability(tile)
    local flammability = {
        stone = 0.5,
        metal = 0.3,
        water = 0.1,
        wood = 1.5,
        grass = 1.2,
        standard = 1.0
    }

    return flammability[tile.terrainType] or 1.0
end

---Apply dissipation and aging to hazards
---@param weather string Current weather conditions
function SmokeFireLayer:dissipateHazards(weather)
    local decayRate = 1.0 -- Base decay

    -- Apply weather modifiers
    if weather == "rain" then
        decayRate = decayRate * 2.0
    elseif weather == "wind" then
        decayRate = decayRate * 1.2
    end

    local toRemove = {}

    for key, hazard in pairs(self._hazards) do
        -- Age the hazard
        hazard.age = hazard.age + 1

        -- Apply intensity decay
        local ageDecay = math.floor(hazard.age * 0.5)
        local intensityDecay = math.floor(decayRate * 2)
        hazard.intensity = math.max(0, hazard.intensity - ageDecay - intensityDecay)

        -- Remove if intensity reaches zero
        if hazard.intensity <= 0 then
            table.insert(toRemove, key)
        end
    end

    -- Remove expired hazards
    for _, key in ipairs(toRemove) do
        self._hazards[key] = nil
    end
end

---Attempt to extinguish hazard
---@param x number Tile X coordinate
---@param y number Tile Y coordinate
---@param method string Extinguish method ("water", "extinguisher", "foam")
---@param skill number Skill level (0-100)
---@return boolean success
function SmokeFireLayer:extinguishHazard(x, y, method, skill)
    local hazard = self:getHazard(x, y)
    if not hazard then return false end

    local rng = RNG:createSeededRNG(self._missionSeed + x + y + self._turnCounter)

    -- Method modifiers
    local methodModifiers = {
        water = 1.2,
        extinguisher = 1.5,
        foam = 1.8
    }

    local modifier = methodModifiers[method] or 1.0
    local skillFactor = skill / 100
    local baseChance = 0.4

    local extinguishChance = baseChance * modifier * (1 + skillFactor)

    -- Failed attempts reduce chance
    extinguishChance = extinguishChance / (1 + hazard.extinguishAttempts * 0.2)

    hazard.extinguishAttempts = hazard.extinguishAttempts + 1

    if rng:random() < extinguishChance then
        hazard.intensity = math.floor(hazard.intensity * 0.3) -- Reduce intensity
        if hazard.intensity <= 5 then
            self:removeHazard(x, y)
        end
        return true
    end

    return false
end

---Process end-of-turn updates
---@param weather string Current weather
---@param units table List of units for effect application
function SmokeFireLayer:processTurn(weather, units)
    self._turnCounter = self._turnCounter + 1

    -- Apply unit effects
    self:applyUnitEffects(units)

    -- Process burning units
    self:processBurningUnits(units)

    -- Propagate hazards
    self:propagateHazards()

    -- Dissipate hazards
    self:dissipateHazards(weather)
end

---Get all hazard tiles for rendering
---@return table hazards Map of hazards for rendering
function SmokeFireLayer:getHazardTiles()
    return self._hazards
end

return SmokeFireLayer
