---HexCombatAdvanced - Advanced Tactical Combat Systems
---
---Implements advanced tactical mechanics for hex-based combat: line of sight,
---line of fire, raycasting, cover calculation, and area damage. Enhances basic
---combat with tactical depth and positioning importance.
---
---Features:
---  - Line of sight (LOS) calculation with blocking
---  - Line of fire (LOF) for shooting
---  - Raycasting through hex grid
---  - Cover calculation (half/full cover)
---  - Area damage (explosions, grenades)
---  - Flanking detection
---  - Height advantage calculation
---
---Line of Sight:
---  - Raycasts from source to target
---  - Checks terrain blocking at each step
---  - Considers elevation and obstacles
---  - Returns true if clear LOS
---
---Cover System:
---  - No cover: 0% protection
---  - Half cover: 25% hit penalty for attacker
---  - Full cover: 50% hit penalty for attacker
---  - Directional (depends on shooter angle)
---
---Area Damage:
---  - Circular blast radius
---  - Damage falloff by distance
---  - Affects all units in radius
---  - Terrain destruction
---
---Key Exports:
---  - hasLineOfSight(hexSystem, sourceQ, sourceR, targetQ, targetR): Returns true if LOS
---  - hasLineOfFire(hexSystem, sourceQ, sourceR, targetQ, targetR): Returns true if LOF
---  - getCover(hexSystem, shooterQ, shooterR, targetQ, targetR): Returns cover value
---  - getAreaDamage(hexSystem, centerQ, centerR, radius, damage): Returns damage map
---  - isFlanked(hexSystem, targetQ, targetR, attackerQ, attackerR): Returns true if flanking
---
---Dependencies:
---  - battlescape.battle_ecs.hex_math: Hex utilities
---
---@module battlescape.battle_ecs.hex_combat_advanced
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local HexCombatAdvanced = require("battlescape.battle_ecs.hex_combat_advanced")
---  local canSee = HexCombatAdvanced.hasLineOfSight(hexSystem, 10, 10, 15, 12)
---  local cover = HexCombatAdvanced.getCover(hexSystem, 10, 10, 15, 12)
---
---@see battlescape.battle_ecs.vision_system For basic vision
---@see battlescape.combat.los_system For LOS implementation

-- Advanced Hex Combat Systems
-- Implements line of sight, line of fire, raycasting, cover, and area damage
-- Enhances existing hex combat with tactical depth

local HexMath = require("battlescape.battle_ecs.hex_math")

local HexCombatAdvanced = {}

--- Line of Sight Calculation
-- Checks if target is visible from source considering terrain blocking
-- @param hexSystem HexSystem Grid system
-- @param sourceQ number Source q coordinate
-- @param sourceR number Source r coordinate
-- @param targetQ number Target q coordinate
-- @param targetR number Target r coordinate
-- @param sourceHeight number Source height level (default 0)
-- @param targetHeight number Target height level (default 0)
-- @return boolean True if line of sight exists
-- @return table|nil Array of blocking hexes if blocked
function HexCombatAdvanced.lineOfSight(hexSystem, sourceQ, sourceR, targetQ, targetR, sourceHeight, targetHeight)
    sourceHeight = sourceHeight or 0
    targetHeight = targetHeight or 0
    
    -- Get hex line between source and target
    local hexes = HexMath.hexLine(sourceQ, sourceR, targetQ, targetR)
    
    -- Check each hex along the line (skip source and target)
    local blockingHexes = {}
    for i = 2, #hexes - 1 do
        local hex = hexes[i]
        local tile = hexSystem:getTile(hex.q, hex.r)
        
        if tile and tile.blocking then
            -- Check if terrain height blocks LOS
            local terrainHeight = tile.height or 0
            
            -- Simple height blocking: terrain blocks if higher than both source and target
            if terrainHeight > sourceHeight and terrainHeight > targetHeight then
                table.insert(blockingHexes, hex)
            end
        end
    end
    
    if #blockingHexes > 0 then
        return false, blockingHexes
    end
    
    return true, nil
end

--- Line of Fire Calculation
-- Checks if target can be fired upon, considering cover and obstacles
-- @param hexSystem HexSystem Grid system
-- @param sourceQ number Source q coordinate
-- @param sourceR number Source r coordinate
-- @param targetQ number Target q coordinate
-- @param targetR number Target r coordinate
-- @return boolean True if line of fire exists
-- @return number Cover value (0=none, 1=partial, 2=full)
function HexCombatAdvanced.lineOfFire(hexSystem, sourceQ, sourceR, targetQ, targetR)
    -- Check basic LOS first
    local hasLOS, blockingHexes = HexCombatAdvanced.lineOfSight(hexSystem, sourceQ, sourceR, targetQ, targetR)
    
    if not hasLOS then
        return false, 2 -- Full cover (completely blocked)
    end
    
    -- Calculate cover from adjacent terrain
    local coverValue = HexCombatAdvanced.calculateCover(hexSystem, targetQ, targetR, sourceQ, sourceR)
    
    return true, coverValue
end

--- Calculate Cover Value
-- Determines cover bonus for target based on nearby terrain
-- @param hexSystem HexSystem Grid system
-- @param targetQ number Target q coordinate
-- @param targetR number Target r coordinate
-- @param sourceQ number Attacker q coordinate
-- @param sourceR number Attacker r coordinate
-- @return number Cover value (0=none, 1=partial, 2=full)
function HexCombatAdvanced.calculateCover(hexSystem, targetQ, targetR, sourceQ, sourceR)
    -- Get direction from source to target
    local direction = HexMath.getDirection(sourceQ, sourceR, targetQ, targetR)
    
    if direction == -1 then
        return 0 -- Not adjacent, no cover mechanics
    end
    
    -- Check hexes adjacent to target that are between source and target
    local neighbors = HexMath.getNeighbors(targetQ, targetR)
    local maxCover = 0
    
    for _, neighbor in ipairs(neighbors) do
        local tile = hexSystem:getTile(neighbor.q, neighbor.r)
        
        if tile and tile.blocking then
            -- Check if this obstacle is between source and target
            local distToSource = HexMath.distance(neighbor.q, neighbor.r, sourceQ, sourceR)
            local distTargetToSource = HexMath.distance(targetQ, targetR, sourceQ, sourceR)
            
            if distToSource < distTargetToSource then
                -- Obstacle is between attacker and target
                local coverValue = tile.coverValue or 1
                maxCover = math.max(maxCover, coverValue)
            end
        end
    end
    
    return maxCover
end

--- Raycast for Instant Hit
-- Fast line intersection for laser/bullet weapons
-- @param hexSystem HexSystem Grid system
-- @param sourceQ number Source q coordinate
-- @param sourceR number Source r coordinate
-- @param targetQ number Target q coordinate
-- @param targetR number Target r coordinate
-- @return table Hit result {hit=bool, hitQ, hitR, distance, penetrations}
function HexCombatAdvanced.raycast(hexSystem, sourceQ, sourceR, targetQ, targetR)
    local hexes = HexMath.hexLine(sourceQ, sourceR, targetQ, targetR)
    local penetrations = 0
    
    for i = 2, #hexes do -- Skip source hex
        local hex = hexes[i]
        local tile = hexSystem:getTile(hex.q, hex.r)
        
        if tile then
            -- Check for blocking
            if tile.blocking then
                -- Check if penetrable
                if tile.penetrable then
                    penetrations = penetrations + 1
                else
                    -- Hit solid obstacle
                    return {
                        hit = true,
                        hitQ = hex.q,
                        hitR = hex.r,
                        distance = i - 1,
                        penetrations = penetrations,
                        hitType = "obstacle"
                    }
                end
            end
            
            -- Check for unit in hex
            if tile.unitId then
                return {
                    hit = true,
                    hitQ = hex.q,
                    hitR = hex.r,
                    unitId = tile.unitId,
                    distance = i - 1,
                    penetrations = penetrations,
                    hitType = "unit"
                }
            end
        end
    end
    
    -- Missed entirely
    return {
        hit = false,
        distance = #hexes - 1,
        penetrations = penetrations
    }
end

--- Calculate Explosion Damage
-- Determines damage at each hex from explosion epicenter
-- @param hexSystem HexSystem Grid system
-- @param epicenterQ number Explosion center q
-- @param epicenterR number Explosion center r
-- @param power number Explosion power
-- @param radius number Max explosion radius
-- @return table Damage map {hex_key = damage_value}
function HexCombatAdvanced.calculateExplosionDamage(hexSystem, epicenterQ, epicenterR, power, radius)
    local damageMap = {}
    local hexes = HexMath.hexesInRange(epicenterQ, epicenterR, radius)
    
    for _, hex in ipairs(hexes) do
        local distance = HexMath.distance(epicenterQ, epicenterR, hex.q, hex.r)
        
        -- Damage falls off with distance: power * (1 - distance/radius)
        local falloff = 1 - (distance / (radius + 1))
        local damage = math.floor(power * falloff)
        
        if damage > 0 then
            local key = hex.q .. "_" .. hex.r
            damageMap[key] = damage
        end
    end
    
    return damageMap
end

--- Generate Shrapnel Projectiles
-- Creates multiple projectiles from explosion
-- @param hexSystem HexSystem Grid system
-- @param epicenterQ number Explosion center q
-- @param epicenterR number Explosion center r
-- @param count number Number of shrapnel pieces
-- @param range number Max shrapnel range
-- @return table Array of shrapnel hits
function HexCombatAdvanced.generateShrapnel(hexSystem, epicenterQ, epicenterR, count, range)
    local hits = {}
    
    for i = 1, count do
        -- Random direction
        local angle = math.random() * 2 * math.pi
        local distance = math.random(1, range)
        
        -- Calculate target hex (approximate using pixel conversion)
        local x = math.cos(angle) * distance * 24
        local y = math.sin(angle) * distance * 24
        local targetQ, targetR = HexMath.pixelToHex(x, y, 24)
        
        -- Raycast from epicenter to target
        local result = HexCombatAdvanced.raycast(hexSystem, epicenterQ, epicenterR, targetQ, targetR)
        
        if result.hit then
            table.insert(hits, result)
        end
    end
    
    return hits
end

--- Calculate Smoke Propagation
-- Spreads smoke to adjacent hexes
-- @param hexSystem HexSystem Grid system
-- @param smokeMap table Current smoke levels {hex_key = intensity}
-- @return table Updated smoke map
function HexCombatAdvanced.propagateSmoke(hexSystem, smokeMap)
    local newSmokeMap = {}
    
    -- Copy existing smoke with decay
    for key, intensity in pairs(smokeMap) do
        if intensity > 0 then
            newSmokeMap[key] = intensity - 1 -- Decay by 1
        end
    end
    
    -- Spread to neighbors
    for key, intensity in pairs(smokeMap) do
        if intensity > 2 then -- Only spread if intensity > 2
            local q, r = key:match("(-?%d+)_(-?%d+)")
            q, r = tonumber(q), tonumber(r)
            
            local neighbors = HexMath.getNeighbors(q, r)
            for _, neighbor in ipairs(neighbors) do
                local nKey = neighbor.q .. "_" .. neighbor.r
                local spreadAmount = math.floor(intensity / 3)
                
                newSmokeMap[nKey] = (newSmokeMap[nKey] or 0) + spreadAmount
            end
        end
    end
    
    return newSmokeMap
end

--- Calculate Fire Spread
-- Spreads fire to adjacent flammable hexes
-- @param hexSystem HexSystem Grid system
-- @param fireMap table Current fire levels {hex_key = intensity}
-- @return table Updated fire map
function HexCombatAdvanced.spreadFire(hexSystem, fireMap)
    local newFireMap = {}
    
    -- Copy existing fires with decay
    for key, intensity in pairs(fireMap) do
        if intensity > 0 then
            newFireMap[key] = intensity - 1 -- Decay by 1
        end
    end
    
    -- Spread to neighbors
    for key, intensity in pairs(fireMap) do
        if intensity > 1 then
            local q, r = key:match("(-?%d+)_(-?%d+)")
            q, r = tonumber(q), tonumber(r)
            
            local neighbors = HexMath.getNeighbors(q, r)
            for _, neighbor in ipairs(neighbors) do
                local tile = hexSystem:getTile(neighbor.q, neighbor.r)
                
                if tile and tile.flammable then
                    -- Chance to ignite based on intensity
                    local igniteChance = intensity * 0.2
                    
                    if math.random() < igniteChance then
                        local nKey = neighbor.q .. "_" .. neighbor.r
                        newFireMap[nKey] = (newFireMap[nKey] or 0) + 3 -- New fire starts at intensity 3
                    end
                end
            end
        end
    end
    
    return newFireMap
end

--- Calculate Grenade Trajectory
-- Determines arc path and landing hex for thrown grenade
-- @param hexSystem HexSystem Grid system
-- @param sourceQ number Source q coordinate
-- @param sourceR number Source r coordinate  
-- @param targetQ number Target q coordinate
-- @param targetR number Target r coordinate
-- @param throwPower number Throw strength (affects accuracy)
-- @return table Result {landQ, landR, flightPath, scatterDistance}
function HexCombatAdvanced.calculateThrowTrajectory(hexSystem, sourceQ, sourceR, targetQ, targetR, throwPower)
    local distance = HexMath.distance(sourceQ, sourceR, targetQ, targetR)
    
    -- Calculate scatter based on distance and throw power
    local baseAccuracy = throwPower / 100
    local accuracyModifier = 1 - (distance * 0.1) -- Harder to aim at distance
    local finalAccuracy = baseAccuracy * accuracyModifier
    
    -- Scatter distance (0-2 hexes typically)
    local scatterDistance = 0
    if math.random() > finalAccuracy then
        scatterDistance = math.random(1, 2)
    end
    
    -- Apply scatter
    local landQ, landR = targetQ, targetR
    if scatterDistance > 0 then
        local scatterDirection = math.random(0, 5)
        for i = 1, scatterDistance do
            landQ, landR = HexMath.neighbor(landQ, landR, scatterDirection)
        end
    end
    
    -- Generate flight path
    local flightPath = HexMath.hexLine(sourceQ, sourceR, landQ, landR)
    
    return {
        landQ = landQ,
        landR = landR,
        flightPath = flightPath,
        scatterDistance = scatterDistance
    }
end

--- Check Reaction Fire Trigger
-- Determines if moving unit triggers reaction fire
-- @param hexSystem HexSystem Grid system
-- @param movingUnitId string Moving unit ID
-- @param fromQ number Starting q coordinate
-- @param fromR number Starting r coordinate
-- @param toQ number Ending q coordinate
-- @param toR number Ending r coordinate
-- @param watchingUnits table Array of units that can react
-- @return table Array of triggered reactions {unitId, reactionType}
function HexCombatAdvanced.checkReactionFire(hexSystem, movingUnitId, fromQ, fromR, toQ, toR, watchingUnits)
    local reactions = {}
    
    for _, watcher in ipairs(watchingUnits) do
        -- Check if watcher has LOS to path
        local pathHexes = HexMath.hexLine(fromQ, fromR, toQ, toR)
        
        for _, pathHex in ipairs(pathHexes) do
            local hasLOS = HexCombatAdvanced.lineOfSight(
                hexSystem,
                watcher.q, watcher.r,
                pathHex.q, pathHex.r
            )
            
            if hasLOS then
                -- Check if watcher has reaction fire available
                if watcher.reactionFireAvailable and watcher.reactionFireTU > 0 then
                    table.insert(reactions, {
                        unitId = watcher.id,
                        reactionType = "shot",
                        triggerQ = pathHex.q,
                        triggerR = pathHex.r
                    })
                    break -- One reaction per watcher per movement
                end
            end
        end
    end
    
    return reactions
end

return HexCombatAdvanced






















