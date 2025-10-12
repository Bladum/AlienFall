-- Fire System
-- Manages fire spreading, unit damage, and smoke production
-- Fire is binary (on/off), spreads based on terrain flammability

local HexMath = require("systems.battle.utils.hex_math")

local FireSystem = {}
FireSystem.__index = FireSystem

---
--- Configuration
---

local CONFIG = {
    fireSpreadChance = 0.3,  -- 30% chance to spread per turn
    fireDamagePerTurn = 5,    -- HP damage to units in fire
    smokeProductionChance = 0.7,  -- 70% chance to produce smoke per turn
    fireStartChance = 0.05,    -- 5% random fire start chance (if enabled)
}

---
--- Constructor
---

function FireSystem.new()
    local self = setmetatable({}, FireSystem)
    self.activeFires = {}  -- Array of {x, y, duration}
    self.fireGrid = {}     -- [y][x] = true for O(1) lookup
    return self
end

---
--- Fire Management
---

-- Start fire at position
function FireSystem:startFire(battlefield, x, y)
    if not battlefield or not battlefield:isValidTile(x, y) then
        return false
    end
    
    local tile = battlefield:getTile(x, y)
    if not tile or not tile.terrain then
        return false
    end
    
    -- Check if tile is flammable
    local flammability = tile.terrain.flammability or 0
    if flammability <= 0 then
        print(string.format("[FireSystem] Tile (%d, %d) is not flammable (terrain: %s)", 
            x, y, tile.terrain.id))
        return false
    end
    
    -- Check if already on fire
    if tile.effects and tile.effects.fire then
        return false
    end
    
    -- Initialize effects table if needed
    if not tile.effects then
        tile.effects = {}
    end
    
    -- Start fire
    tile.effects.fire = true
    tile.effects.fireDuration = 0
    
    -- Add to active fires list
    table.insert(self.activeFires, {x = x, y = y, duration = 0})
    
    -- Add to fire grid for O(1) lookup
    if not self.fireGrid[y] then
        self.fireGrid[y] = {}
    end
    self.fireGrid[y][x] = true
    
    print(string.format("[FireSystem] Fire started at (%d, %d)", x, y))
    return true
end

-- Stop fire at position
function FireSystem:stopFire(battlefield, x, y)
    local tile = battlefield:getTile(x, y)
    if tile and tile.effects and tile.effects.fire then
        tile.effects.fire = false
        tile.effects.fireDuration = nil
        
        -- Remove from grid
        if self.fireGrid[y] then
            self.fireGrid[y][x] = nil
        end
        
        -- Remove from active fires list
        for i = #self.activeFires, 1, -1 do
            local fire = self.activeFires[i]
            if fire.x == x and fire.y == y then
                table.remove(self.activeFires, i)
                break
            end
        end
        
        print(string.format("[FireSystem] Fire extinguished at (%d, %d)", x, y))
    end
end

-- Check if tile has fire
function FireSystem:hasFire(x, y)
    return self.fireGrid[y] and self.fireGrid[y][x] == true
end

---
--- Fire Spreading
---

-- Spread fire to adjacent flammable tiles
function FireSystem:spreadFire(battlefield, x, y)
    local tile = battlefield:getTile(x, y)
    if not tile or not tile.effects or not tile.effects.fire then
        return
    end
    
    -- Get hex neighbors
    local q, r = HexMath.offsetToAxial(x, y)
    local neighbors = HexMath.getNeighbors(q, r)
    
    local spreadCount = 0
    for _, neighbor in ipairs(neighbors) do
        local nx, ny = HexMath.axialToOffset(neighbor.q, neighbor.r)
        
        -- Check if neighbor is valid and not already on fire
        if battlefield:isValidTile(nx, ny) then
            local neighborTile = battlefield:getTile(nx, ny)
            
            if neighborTile and not (neighborTile.effects and neighborTile.effects.fire) then
                local flammability = neighborTile.terrain.flammability or 0
                
                -- Roll for spread
                if flammability > 0 and math.random() < (CONFIG.fireSpreadChance * flammability) then
                    self:startFire(battlefield, nx, ny)
                    spreadCount = spreadCount + 1
                end
            end
        end
    end
    
    if spreadCount > 0 then
        print(string.format("[FireSystem] Fire at (%d, %d) spread to %d tiles", x, y, spreadCount))
    end
end

---
--- Smoke Production
---

-- Produce smoke in adjacent empty tiles
function FireSystem:produceSmoke(battlefield, x, y, smokeSystem)
    if not smokeSystem then return end
    
    local tile = battlefield:getTile(x, y)
    if not tile or not tile.effects or not tile.effects.fire then
        return
    end
    
    -- Get hex neighbors
    local q, r = HexMath.offsetToAxial(x, y)
    local neighbors = HexMath.getNeighbors(q, r)
    
    for _, neighbor in ipairs(neighbors) do
        local nx, ny = HexMath.axialToOffset(neighbor.q, neighbor.r)
        
        if battlefield:isValidTile(nx, ny) then
            local neighborTile = battlefield:getTile(nx, ny)
            
            -- Produce smoke if random chance succeeds
            if neighborTile and math.random() < CONFIG.smokeProductionChance then
                -- Smoke only on empty tiles (not walls)
                if not neighborTile.terrain.blocksSight then
                    smokeSystem:addSmoke(battlefield, nx, ny, 1)
                end
            end
        end
    end
end

---
--- Unit Damage
---

-- Damage units standing in fire
function FireSystem:damageUnitsInFire(units)
    local damagedCount = 0
    
    for _, unit in pairs(units) do
        if unit and unit.alive and self:hasFire(unit.x, unit.y) then
            unit.health = unit.health - CONFIG.fireDamagePerTurn
            
            if unit.health <= 0 then
                unit.health = 0
                unit.alive = false
                print(string.format("[FireSystem] %s killed by fire at (%d, %d)", 
                    unit.name, unit.x, unit.y))
            else
                print(string.format("[FireSystem] %s took %d fire damage at (%d, %d) (HP: %d/%d)", 
                    unit.name, CONFIG.fireDamagePerTurn, unit.x, unit.y, unit.health, unit.maxHealth))
            end
            
            damagedCount = damagedCount + 1
        end
    end
    
    return damagedCount
end

---
--- Turn Update
---

-- Update all fires (spread, produce smoke, damage units)
function FireSystem:update(battlefield, units, smokeSystem)
    local updateStartTime = love and love.timer and love.timer.getTime() or 0
    
    print(string.format("[FireSystem] Update: %d active fires", #self.activeFires))
    
    -- Update fire duration and spread
    local firesToSpread = {}
    for i, fire in ipairs(self.activeFires) do
        local tile = battlefield:getTile(fire.x, fire.y)
        if tile and tile.effects and tile.effects.fire then
            -- Increment duration
            fire.duration = fire.duration + 1
            tile.effects.fireDuration = fire.duration
            
            -- Mark for spreading
            table.insert(firesToSpread, {x = fire.x, y = fire.y})
        end
    end
    
    -- Spread fires (do this after iteration to avoid modifying during iteration)
    for _, fire in ipairs(firesToSpread) do
        self:spreadFire(battlefield, fire.x, fire.y)
        
        -- Produce smoke
        if smokeSystem then
            self:produceSmoke(battlefield, fire.x, fire.y, smokeSystem)
        end
    end
    
    -- Damage units in fire
    local damagedCount = self:damageUnitsInFire(units)
    if damagedCount > 0 then
        print(string.format("[FireSystem] Damaged %d units in fire", damagedCount))
    end
    
    if love and love.timer then
        local updateTime = (love.timer.getTime() - updateStartTime) * 1000
        print(string.format("[FireSystem] Update complete in %.3f ms", updateTime))
    end
end

---
--- Statistics
---

function FireSystem:getFireCount()
    return #self.activeFires
end

function FireSystem:clearAllFires(battlefield)
    for i = #self.activeFires, 1, -1 do
        local fire = self.activeFires[i]
        self:stopFire(battlefield, fire.x, fire.y)
    end
    print("[FireSystem] All fires cleared")
end

return FireSystem
