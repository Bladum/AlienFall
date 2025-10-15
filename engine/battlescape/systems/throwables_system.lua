---@meta

---Grenade & Throwables System
---Handles thrown explosives, arc trajectories, bounce physics, detonation
---@module throwables_system

local ThrowablesSystem = {}

---@class Throwable
---@field id string Unique throwable instance ID
---@field type string Grenade type (frag, smoke, incendiary, flashbang, emp)
---@field thrower string Unit ID who threw it
---@field startQ number Start hex Q
---@field startR number Start hex R
---@field targetQ number Target hex Q
---@field targetR number Target hex R
---@field fuseTime number Turns until detonation (-1 for impact)
---@field currentQ number Current position Q
---@field currentR number Current position R
---@field bounces number Remaining bounces before rest
---@field state string State: "flying", "bouncing", "resting", "detonated"

-- Grenade type definitions
ThrowablesSystem.GRENADE_TYPES = {
    FRAG = {
        name = "Fragmentation Grenade",
        damage = 30,
        radius = 3,
        fuseTime = 2, -- 2 turns
        bounces = 1,
        effects = {"explosion", "shrapnel"},
    },
    SMOKE = {
        name = "Smoke Grenade",
        damage = 0,
        radius = 4,
        fuseTime = 1,
        bounces = 0,
        effects = {"smoke"},
        smokeDuration = 5, -- 5 turns
        smokeDensity = 8,
    },
    INCENDIARY = {
        name = "Incendiary Grenade",
        damage = 15,
        radius = 2,
        fuseTime = 1,
        bounces = 0,
        effects = {"fire"},
        fireDuration = 4,
        fireIntensity = 6,
    },
    FLASHBANG = {
        name = "Flashbang",
        damage = 0,
        radius = 5,
        fuseTime = -1, -- Impact detonation
        bounces = 0,
        effects = {"stun", "blind"},
        stunDuration = 2,
    },
    EMP = {
        name = "EMP Grenade",
        damage = 0,
        radius = 3,
        fuseTime = 1,
        bounces = 0,
        effects = {"emp"},
        empDuration = 3,
    },
}

-- Active throwables
local activeThrowables = {}
local nextId = 1

---Throw a grenade
---@param throwerUnit table Unit throwing
---@param grenadeType string Type (FRAG, SMOKE, etc.)
---@param targetQ number Target hex Q
---@param targetR number Target hex R
---@return string|nil throwableId Throwable ID or nil on failure
function ThrowablesSystem.throwGrenade(throwerUnit, grenadeType, targetQ, targetR)
    local grenadeDef = ThrowablesSystem.GRENADE_TYPES[grenadeType]
    if not grenadeDef then
        print("[Throwables] Unknown grenade type: " .. grenadeType)
        return nil
    end
    
    -- Create throwable
    local throwable = {
        id = "throwable_" .. nextId,
        type = grenadeType,
        thrower = throwerUnit.id,
        startQ = throwerUnit.q,
        startR = throwerUnit.r,
        targetQ = targetQ,
        targetR = targetR,
        fuseTime = grenadeDef.fuseTime,
        currentQ = targetQ,
        currentR = targetR,
        bounces = grenadeDef.bounces,
        state = "flying",
    }
    
    nextId = nextId + 1
    table.insert(activeThrowables, throwable)
    
    print(string.format("[Throwables] %s threw %s to (%d,%d)", 
        throwerUnit.id, grenadeType, targetQ, targetR))
    
    return throwable.id
end

---Calculate throw distance
---@param startQ number Start Q
---@param startR number Start R
---@param endQ number End Q
---@param endR number End R
---@return number distance Hex distance
function ThrowablesSystem.calculateDistance(startQ, startR, endQ, endR)
    local dq = math.abs(endQ - startQ)
    local dr = math.abs(endR - startR)
    local ds = math.abs((-startQ - startR) - (-endQ - endR))
    return math.floor((dq + dr + ds) / 2)
end

---Check if throw is valid (range, obstacles)
---@param unit table Throwing unit
---@param targetQ number Target Q
---@param targetR number Target R
---@param maxRange number|nil Maximum throw range (default 8)
---@return boolean valid, string|nil reason
function ThrowablesSystem.canThrow(unit, targetQ, targetR, maxRange)
    maxRange = maxRange or 8
    
    local distance = ThrowablesSystem.calculateDistance(unit.q, unit.r, targetQ, targetR)
    
    if distance > maxRange then
        return false, "Out of range"
    end
    
    if distance == 0 then
        return false, "Cannot throw at self"
    end
    
    -- TODO: Check for obstacles/ceiling in arc path
    
    return true
end

---Process throwable bouncing
---@param throwable Throwable
---@param map table Map object
function ThrowablesSystem.processBounce(throwable, map)
    if throwable.bounces <= 0 then
        throwable.state = "resting"
        print(string.format("[Throwables] %s came to rest at (%d,%d)", 
            throwable.id, throwable.currentQ, throwable.currentR))
        return
    end
    
    -- Bounce to random adjacent hex
    local neighbors = {
        {1, 0}, {1, -1}, {0, -1}, {-1, 0}, {-1, 1}, {0, 1}
    }
    local bounce = neighbors[math.random(1, 6)]
    throwable.currentQ = throwable.currentQ + bounce[1]
    throwable.currentR = throwable.currentR + bounce[2]
    throwable.bounces = throwable.bounces - 1
    
    print(string.format("[Throwables] %s bounced to (%d,%d)", 
        throwable.id, throwable.currentQ, throwable.currentR))
    
    if throwable.bounces <= 0 then
        throwable.state = "resting"
    end
end

---Detonate a throwable
---@param throwable Throwable
---@param map table Map object
---@param units table List of all units
function ThrowablesSystem.detonate(throwable, map, units)
    local grenadeDef = ThrowablesSystem.GRENADE_TYPES[throwable.type]
    if not grenadeDef then return end
    
    local q, r = throwable.currentQ, throwable.currentR
    
    print(string.format("[Throwables] %s detonated at (%d,%d)", throwable.id, q, r))
    
    -- Get affected tiles in radius
    local affectedTiles = ThrowablesSystem.getHexesInRadius(q, r, grenadeDef.radius)
    
    -- Apply effects
    for _, effect in ipairs(grenadeDef.effects) do
        if effect == "explosion" then
            ThrowablesSystem.applyExplosionDamage(throwable, affectedTiles, units, grenadeDef)
        elseif effect == "smoke" then
            ThrowablesSystem.createSmoke(affectedTiles, map, grenadeDef)
        elseif effect == "fire" then
            ThrowablesSystem.createFire(affectedTiles, map, grenadeDef)
        elseif effect == "stun" then
            ThrowablesSystem.applyStun(affectedTiles, units, grenadeDef)
        elseif effect == "emp" then
            ThrowablesSystem.applyEMP(affectedTiles, units, grenadeDef)
        end
    end
    
    throwable.state = "detonated"
end

---Apply explosion damage
---@param throwable Throwable
---@param tiles table List of {q, r, distance}
---@param units table List of units
---@param grenadeDef table Grenade definition
function ThrowablesSystem.applyExplosionDamage(throwable, tiles, units, grenadeDef)
    for _, tile in ipairs(tiles) do
        -- Distance falloff
        local falloff = 1.0 - (tile.distance / grenadeDef.radius)
        local damage = math.floor(grenadeDef.damage * falloff)
        
        -- Find units on this tile
        for _, unit in ipairs(units) do
            if unit.q == tile.q and unit.r == tile.r then
                unit.hp = (unit.hp or 10) - damage
                print(string.format("[Throwables] %s takes %d explosion damage", unit.id, damage))
            end
        end
    end
end

---Create smoke cloud
---@param tiles table List of {q, r, distance}
---@param map table Map object
---@param grenadeDef table Grenade definition
function ThrowablesSystem.createSmoke(tiles, map, grenadeDef)
    if not map.smoke then map.smoke = {} end
    
    for _, tile in ipairs(tiles) do
        local key = tile.q .. "," .. tile.r
        map.smoke[key] = {
            density = grenadeDef.smokeDensity,
            duration = grenadeDef.smokeDuration,
        }
    end
    
    print(string.format("[Throwables] Created smoke cloud at %d tiles", #tiles))
end

---Create fire
---@param tiles table List of {q, r, distance}
---@param map table Map object
---@param grenadeDef table Grenade definition
function ThrowablesSystem.createFire(tiles, map, grenadeDef)
    if not map.fire then map.fire = {} end
    
    for _, tile in ipairs(tiles) do
        local key = tile.q .. "," .. tile.r
        map.fire[key] = {
            intensity = grenadeDef.fireIntensity,
            duration = grenadeDef.fireDuration,
        }
    end
    
    print(string.format("[Throwables] Created fire at %d tiles", #tiles))
end

---Apply stun effect
---@param tiles table List of {q, r, distance}
---@param units table List of units
---@param grenadeDef table Grenade definition
function ThrowablesSystem.applyStun(tiles, units, grenadeDef)
    -- Requires status effects system integration
    print(string.format("[Throwables] Stun effect on %d tiles (duration %d)", 
        #tiles, grenadeDef.stunDuration or 2))
    
    -- TODO: Apply STUNNED status effect to units in affected tiles
end

---Apply EMP effect
---@param tiles table List of {q, r, distance}
---@param units table List of units
---@param grenadeDef table Grenade definition
function ThrowablesSystem.applyEMP(tiles, units, grenadeDef)
    print(string.format("[Throwables] EMP effect on %d tiles (duration %d)", 
        #tiles, grenadeDef.empDuration or 3))
    
    -- TODO: Disable robotic units, electronics
end

---Get all hexes within radius
---@param centerQ number Center Q
---@param centerR number Center R
---@param radius number Radius
---@return table hexes List of {q, r, distance}
function ThrowablesSystem.getHexesInRadius(centerQ, centerR, radius)
    local hexes = {}
    
    for q = centerQ - radius, centerQ + radius do
        for r = centerR - radius, centerR + radius do
            local distance = ThrowablesSystem.calculateDistance(centerQ, centerR, q, r)
            if distance <= radius then
                table.insert(hexes, {q = q, r = r, distance = distance})
            end
        end
    end
    
    return hexes
end

---Process turn end for all throwables
---@param map table Map object
---@param units table List of units
function ThrowablesSystem.processTurnEnd(map, units)
    for i = #activeThrowables, 1, -1 do
        local throwable = activeThrowables[i]
        
        if throwable.state == "flying" then
            -- Land immediately (simplified - no multi-turn flight)
            if throwable.bounces > 0 then
                throwable.state = "bouncing"
                ThrowablesSystem.processBounce(throwable, map)
            else
                throwable.state = "resting"
            end
        elseif throwable.state == "bouncing" then
            ThrowablesSystem.processBounce(throwable, map)
        elseif throwable.state == "resting" then
            -- Decrement fuse
            if throwable.fuseTime > 0 then
                throwable.fuseTime = throwable.fuseTime - 1
                if throwable.fuseTime == 0 then
                    ThrowablesSystem.detonate(throwable, map, units)
                end
            end
        end
        
        -- Remove detonated throwables
        if throwable.state == "detonated" then
            table.remove(activeThrowables, i)
        end
    end
end

---Get all active throwables
---@return table throwables
function ThrowablesSystem.getActive()
    return activeThrowables
end

---Clear all throwables
function ThrowablesSystem.reset()
    activeThrowables = {}
    nextId = 1
    print("[Throwables] System reset")
end

return ThrowablesSystem






















