---@meta

---Environmental Hazards System
---Handles environmental damage: fire, smoke, water, fall damage, terrain damage
---@module environmental_hazards

local EnvironmentalHazards = {}

-- Configuration
EnvironmentalHazards.CONFIG = {
    -- Fire damage
    FIRE_DAMAGE_MIN = 1,
    FIRE_DAMAGE_MAX = 3,
    FIRE_CHANCE_TO_SPREAD = 0.15, -- 15% per turn
    
    -- Smoke effects
    SMOKE_VISION_BLOCK = true,
    SMOKE_ACCURACY_PENALTY = 30, -- -30% accuracy
    
    -- Water effects
    WATER_MOVEMENT_COST_MULT = 2.0, -- 2x AP cost
    WATER_ACCURACY_PENALTY = 10, -- -10% accuracy
    
    -- Fall damage
    FALL_DAMAGE_PER_LEVEL = 3, -- 3 HP per level fallen
    FALL_HEIGHT_SAFE = 1, -- No damage for 1 level
    
    -- Terrain damage
    TERRAIN_DAMAGE_TYPES = {
        SPIKES = 2,
        ACID = 3,
        LAVA = 5,
        ELECTRIFIED = 4,
    },
}

---Check if tile has fire
---@param map table Map object
---@param q number Hex Q coordinate
---@param r number Hex R coordinate
---@return boolean hasFire
---@return number intensity Fire intensity (0-10)
function EnvironmentalHazards.checkFire(map, q, r)
    if not map or not map.fire then return false, 0 end
    
    local key = q .. "," .. r
    local fireData = map.fire[key]
    
    if fireData and fireData.intensity > 0 then
        return true, fireData.intensity
    end
    
    return false, 0
end

---Apply fire damage to unit
---@param unit table Unit object
---@param intensity number Fire intensity (1-10)
---@return number damageDealt
function EnvironmentalHazards.applyFireDamage(unit, intensity)
    local cfg = EnvironmentalHazards.CONFIG
    
    -- Calculate damage based on intensity
    local baseDamage = cfg.FIRE_DAMAGE_MIN + (intensity / 10) * (cfg.FIRE_DAMAGE_MAX - cfg.FIRE_DAMAGE_MIN)
    local damage = math.floor(baseDamage)
    
    -- Apply damage
    unit.hp = (unit.hp or 10) - damage
    
    print(string.format("[EnvHazards] %s takes %d fire damage (intensity %d)", 
        unit.id or "unknown", damage, intensity))
    
    return damage
end

---Check if tile has smoke
---@param map table Map object
---@param q number Hex Q coordinate
---@param r number Hex R coordinate
---@return boolean hasSmoke
---@return number density Smoke density (0-10)
function EnvironmentalHazards.checkSmoke(map, q, r)
    if not map or not map.smoke then return false, 0 end
    
    local key = q .. "," .. r
    local smokeData = map.smoke[key]
    
    if smokeData and smokeData.density > 0 then
        return true, smokeData.density
    end
    
    return false, 0
end

---Calculate smoke penalties
---@param density number Smoke density (1-10)
---@return number accuracyPenalty, boolean visionBlocked
function EnvironmentalHazards.getSmokeEffects(density)
    local cfg = EnvironmentalHazards.CONFIG
    
    local accuracyPenalty = (density / 10) * cfg.SMOKE_ACCURACY_PENALTY
    local visionBlocked = density >= 5 -- Heavy smoke blocks vision
    
    return accuracyPenalty, visionBlocked
end

---Check if tile has water
---@param map table Map object
---@param q number Hex Q coordinate
---@param r number Hex R coordinate
---@return boolean hasWater
---@return number depth Water depth (1=shallow, 2=deep)
function EnvironmentalHazards.checkWater(map, q, r)
    if not map or not map.getTile then return false, 0 end
    
    local tile = map:getTile(q, r)
    if not tile then return false, 0 end
    
    -- Check terrain type
    if tile.terrain == "water_shallow" then
        return true, 1
    elseif tile.terrain == "water_deep" then
        return true, 2
    end
    
    return false, 0
end

---Calculate water movement cost multiplier
---@param depth number Water depth
---@return number movementMultiplier
function EnvironmentalHazards.getWaterMovementCost(depth)
    local cfg = EnvironmentalHazards.CONFIG
    
    if depth == 0 then return 1.0 end
    if depth == 1 then return cfg.WATER_MOVEMENT_COST_MULT end
    if depth >= 2 then return cfg.WATER_MOVEMENT_COST_MULT * 1.5 end -- Deep water is even slower
    
    return 1.0
end

---Calculate water accuracy penalty
---@param depth number Water depth
---@return number accuracyPenalty
function EnvironmentalHazards.getWaterAccuracyPenalty(depth)
    local cfg = EnvironmentalHazards.CONFIG
    
    if depth == 0 then return 0 end
    return (depth / 2) * cfg.WATER_ACCURACY_PENALTY
end

---Calculate fall damage
---@param heightFallen number Number of levels fallen
---@return number damage
function EnvironmentalHazards.calculateFallDamage(heightFallen)
    local cfg = EnvironmentalHazards.CONFIG
    
    if heightFallen <= cfg.FALL_HEIGHT_SAFE then
        return 0
    end
    
    local excessHeight = heightFallen - cfg.FALL_HEIGHT_SAFE
    local damage = excessHeight * cfg.FALL_DAMAGE_PER_LEVEL
    
    return damage
end

---Apply fall damage to unit
---@param unit table Unit object
---@param heightFallen number Levels fallen
---@return number damageDealt
function EnvironmentalHazards.applyFallDamage(unit, heightFallen)
    local damage = EnvironmentalHazards.calculateFallDamage(heightFallen)
    
    if damage > 0 then
        unit.hp = (unit.hp or 10) - damage
        print(string.format("[EnvHazards] %s takes %d fall damage (fell %d levels)", 
            unit.id or "unknown", damage, heightFallen))
    end
    
    return damage
end

---Check for hazardous terrain
---@param map table Map object
---@param q number Hex Q coordinate
---@param r number Hex R coordinate
---@return string|nil hazardType Type of hazard (SPIKES, ACID, LAVA, ELECTRIFIED)
function EnvironmentalHazards.checkHazardousTerrain(map, q, r)
    if not map or not map.getTile then return nil end
    
    local tile = map:getTile(q, r)
    if not tile then return nil end
    
    -- Check for hazardous terrain types
    local terrainHazards = {
        spikes = "SPIKES",
        acid_pool = "ACID",
        lava = "LAVA",
        electrified_floor = "ELECTRIFIED",
    }
    
    return terrainHazards[tile.terrain]
end

---Apply terrain hazard damage
---@param unit table Unit object
---@param hazardType string Hazard type
---@return number damageDealt
function EnvironmentalHazards.applyTerrainDamage(unit, hazardType)
    local cfg = EnvironmentalHazards.CONFIG
    
    local damage = cfg.TERRAIN_DAMAGE_TYPES[hazardType] or 0
    
    if damage > 0 then
        unit.hp = (unit.hp or 10) - damage
        print(string.format("[EnvHazards] %s takes %d damage from %s terrain", 
            unit.id or "unknown", damage, hazardType))
    end
    
    return damage
end

---Process all environmental hazards for a unit on a tile
---@param unit table Unit object
---@param map table Map object
---@param q number Hex Q coordinate
---@param r number Hex R coordinate
---@return table damageLog {fire=n, terrain=n, total=n}
function EnvironmentalHazards.processHazards(unit, map, q, r)
    local damageLog = {fire = 0, terrain = 0, total = 0}
    
    -- Check fire
    local hasFire, fireIntensity = EnvironmentalHazards.checkFire(map, q, r)
    if hasFire then
        local fireDamage = EnvironmentalHazards.applyFireDamage(unit, fireIntensity)
        damageLog.fire = fireDamage
        damageLog.total = damageLog.total + fireDamage
    end
    
    -- Check hazardous terrain
    local hazardType = EnvironmentalHazards.checkHazardousTerrain(map, q, r)
    if hazardType then
        local terrainDamage = EnvironmentalHazards.applyTerrainDamage(unit, hazardType)
        damageLog.terrain = terrainDamage
        damageLog.total = damageLog.total + terrainDamage
    end
    
    return damageLog
end

---Get movement cost for tile considering environmental factors
---@param map table Map object
---@param q number Hex Q coordinate
---@param r number Hex R coordinate
---@return number movementCostMultiplier
function EnvironmentalHazards.getMovementCost(map, q, r)
    local mult = 1.0
    
    -- Water penalty
    local hasWater, waterDepth = EnvironmentalHazards.checkWater(map, q, r)
    if hasWater then
        mult = mult * EnvironmentalHazards.getWaterMovementCost(waterDepth)
    end
    
    -- Fire penalty (avoid fire)
    local hasFire, fireIntensity = EnvironmentalHazards.checkFire(map, q, r)
    if hasFire then
        mult = mult * (1.0 + fireIntensity / 10) -- 1.1x to 2.0x cost
    end
    
    return mult
end

---Get accuracy modifier for shooting considering environment
---@param map table Map object
---@param shooterQ number Shooter Q coordinate
---@param shooterR number Shooter R coordinate
---@param targetQ number Target Q coordinate
---@param targetR number Target R coordinate
---@return number accuracyModifier Total accuracy modifier
function EnvironmentalHazards.getAccuracyModifier(map, shooterQ, shooterR, targetQ, targetR)
    local totalMod = 0
    
    -- Shooter in water
    local shooterInWater, shooterDepth = EnvironmentalHazards.checkWater(map, shooterQ, shooterR)
    if shooterInWater then
        totalMod = totalMod - EnvironmentalHazards.getWaterAccuracyPenalty(shooterDepth)
    end
    
    -- Shooter in smoke
    local shooterInSmoke, shooterSmoke = EnvironmentalHazards.checkSmoke(map, shooterQ, shooterR)
    if shooterInSmoke then
        local smokePenalty, _ = EnvironmentalHazards.getSmokeEffects(shooterSmoke)
        totalMod = totalMod - smokePenalty
    end
    
    -- Target in smoke (makes them harder to hit)
    local targetInSmoke, targetSmoke = EnvironmentalHazards.checkSmoke(map, targetQ, targetR)
    if targetInSmoke then
        local smokePenalty, _ = EnvironmentalHazards.getSmokeEffects(targetSmoke)
        totalMod = totalMod - (smokePenalty * 0.5) -- Half penalty for target in smoke
    end
    
    return totalMod
end

---Configure environmental hazard parameters
---@param config table Configuration overrides
function EnvironmentalHazards.configure(config)
    for k, v in pairs(config) do
        if EnvironmentalHazards.CONFIG[k] ~= nil then
            EnvironmentalHazards.CONFIG[k] = v
            print(string.format("[EnvHazards] Config: %s = %s", k, tostring(v)))
        end
    end
end

return EnvironmentalHazards






















