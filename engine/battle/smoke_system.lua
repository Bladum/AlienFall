-- Smoke System
-- Manages 3-level smoke dissipation and spreading
-- Smoke: Level 1 (light), 2 (medium), 3 (heavy)
-- Each level adds +2 sight cost

local HexMath = require("battle.utils.hex_math")

--- @class SmokeSystem
--- Manages smoke propagation, dissipation, and sight penalties in tactical combat.
--- Smoke spreads to adjacent tiles and naturally dissipates over time.
--- Higher smoke levels provide greater sight obstruction (+2 per level).
---
--- @field activeSmoke table[] Array of active smoke objects with {x, y, level, age} fields
--- @field smokeGrid table[][] 2D grid for O(1) smoke level lookup [y][x] = level
local SmokeSystem = {}
SmokeSystem.__index = SmokeSystem

---
--- Configuration
---

local CONFIG = {
    smokeSpreadRate = 0.7,      -- 70% chance to spread per turn
    smokeDissipationRate = 0.2, -- 20% chance to dissipate (reduce level) per turn
    maxSmokeLevel = 3,          -- Maximum smoke level
}

---
--- Constructor
---

function SmokeSystem.new()
    local self = setmetatable({}, SmokeSystem)
    self.activeSmoke = {}  -- Array of {x, y, level, age}
    self.smokeGrid = {}    -- [y][x] = level for O(1) lookup
    return self
end

---
--- Smoke Management
---

-- Add smoke at position (or increase level)
function SmokeSystem:addSmoke(battlefield, x, y, level)
    if not battlefield or not battlefield:isValidTile(x, y) then
        return false
    end
    
    local tile = battlefield:getTile(x, y)
    if not tile or not tile.terrain then
        return false
    end
    
    -- Smoke only on non-blocking tiles (not walls)
    if tile.terrain.blocksSight then
        return false
    end
    
    -- Initialize effects table if needed
    if not tile.effects then
        tile.effects = {}
    end
    
    -- Get current smoke level
    local currentLevel = tile.effects.smoke or 0
    local newLevel = math.min(currentLevel + level, CONFIG.maxSmokeLevel)
    
    if newLevel > currentLevel then
        tile.effects.smoke = newLevel
        tile.effects.smokeAge = 0
        
        -- Update smoke grid
        if not self.smokeGrid[y] then
            self.smokeGrid[y] = {}
        end
        self.smokeGrid[y][x] = newLevel
        
        -- Add to active smoke if not already present
        local found = false
        for _, smoke in ipairs(self.activeSmoke) do
            if smoke.x == x and smoke.y == y then
                smoke.level = newLevel
                smoke.age = 0
                found = true
                break
            end
        end
        
        if not found then
            table.insert(self.activeSmoke, {x = x, y = y, level = newLevel, age = 0})
        end
        
        return true
    end
    
    return false
end

-- Remove smoke at position
function SmokeSystem:removeSmoke(battlefield, x, y)
    local tile = battlefield:getTile(x, y)
    if tile and tile.effects and tile.effects.smoke then
        tile.effects.smoke = 0
        tile.effects.smokeAge = nil
        
        -- Remove from grid
        if self.smokeGrid[y] then
            self.smokeGrid[y][x] = nil
        end
        
        -- Remove from active smoke list
        for i = #self.activeSmoke, 1, -1 do
            local smoke = self.activeSmoke[i]
            if smoke.x == x and smoke.y == y then
                table.remove(self.activeSmoke, i)
                break
            end
        end
    end
end

-- Get smoke level at position
function SmokeSystem:getSmokeLevel(x, y)
    return (self.smokeGrid[y] and self.smokeGrid[y][x]) or 0
end

---
--- Smoke Spreading
---

-- Spread smoke to adjacent tiles (reduces level by 1 when spreading)
function SmokeSystem:spreadSmoke(battlefield, x, y, level)
    if level <= 0 then return end
    
    local tile = battlefield:getTile(x, y)
    if not tile then return end
    
    -- Get hex neighbors
    local q, r = HexMath.offsetToAxial(x, y)
    local neighbors = HexMath.getNeighbors(q, r)
    
    for _, neighbor in ipairs(neighbors) do
        local nx, ny = HexMath.axialToOffset(neighbor.q, neighbor.r)
        
        if battlefield:isValidTile(nx, ny) then
            local neighborTile = battlefield:getTile(nx, ny)
            
            -- Spread smoke if random chance succeeds
            if neighborTile and math.random() < CONFIG.smokeSpreadRate then
                -- Smoke doesn't spread to blocking terrain (walls)
                if not neighborTile.terrain.blocksSight then
                    -- Spread at same level (doesn't reduce when spreading nearby)
                    self:addSmoke(battlefield, nx, ny, 1)
                end
            end
        end
    end
end

---
--- Smoke Dissipation
---

-- Naturally dissipate smoke (reduce level)
function SmokeSystem:dissipateSmoke(battlefield)
    local dissipatedCount = 0
    
    -- Iterate backwards to safely remove elements
    for i = #self.activeSmoke, 1, -1 do
        local smoke = self.activeSmoke[i]
        local tile = battlefield:getTile(smoke.x, smoke.y)
        
        if tile and tile.effects and tile.effects.smoke then
            -- Increment age
            smoke.age = smoke.age + 1
            tile.effects.smokeAge = smoke.age
            
            -- Roll for dissipation
            if math.random() < CONFIG.smokeDissipationRate then
                local newLevel = smoke.level - 1
                
                if newLevel <= 0 then
                    -- Remove smoke completely
                    self:removeSmoke(battlefield, smoke.x, smoke.y)
                    dissipatedCount = dissipatedCount + 1
                else
                    -- Reduce level
                    smoke.level = newLevel
                    tile.effects.smoke = newLevel
                    
                    -- Update grid
                    if self.smokeGrid[smoke.y] then
                        self.smokeGrid[smoke.y][smoke.x] = newLevel
                    end
                end
            end
        else
            -- Tile no longer has smoke, remove from list
            table.remove(self.activeSmoke, i)
        end
    end
    
    return dissipatedCount
end

---
--- Turn Update
---

-- Update all smoke (spread, dissipate)
function SmokeSystem:update(battlefield)
    local updateStartTime = love and love.timer and love.timer.getTime() or 0
    
    print(string.format("[SmokeSystem] Update: %d smoke tiles", #self.activeSmoke))
    
    -- Spread smoke (do this before dissipation)
    local smokesToSpread = {}
    for _, smoke in ipairs(self.activeSmoke) do
        table.insert(smokesToSpread, {x = smoke.x, y = smoke.y, level = smoke.level})
    end
    
    for _, smoke in ipairs(smokesToSpread) do
        self:spreadSmoke(battlefield, smoke.x, smoke.y, smoke.level)
    end
    
    -- Dissipate smoke
    local dissipatedCount = self:dissipateSmoke(battlefield)
    if dissipatedCount > 0 then
        print(string.format("[SmokeSystem] Dissipated %d smoke tiles", dissipatedCount))
    end
    
    if love and love.timer then
        local updateTime = (love.timer.getTime() - updateStartTime) * 1000
        print(string.format("[SmokeSystem] Update complete in %.3f ms", updateTime))
    end
end

---
--- Statistics
---

function SmokeSystem:getSmokeCount()
    return #self.activeSmoke
end

function SmokeSystem:clearAllSmoke(battlefield)
    for i = #self.activeSmoke, 1, -1 do
        local smoke = self.activeSmoke[i]
        self:removeSmoke(battlefield, smoke.x, smoke.y)
    end
    print("[SmokeSystem] All smoke cleared")
end

-- Get total sight cost modifier for smoke at position
function SmokeSystem:getSmokeSightCost(x, y)
    local level = self:getSmokeLevel(x, y)
    return level * 2  -- +2 sight cost per smoke level
end

return SmokeSystem
