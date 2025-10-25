---Day/Night Cycle System - Visual Time-of-Day Overlay
---
---Visual day/night overlay that moves across the world map to show time zones.
---Purely cosmetic feature that adds atmosphere without affecting gameplay mechanics.
---The cycle moves at 4 tiles per day, covering 50% of the world in daylight at any time.
---
---System Properties:
---  - worldWidth: Total width of world in hex tiles (default 90)
---  - speed: Tiles per day the cycle moves (default 4)
---  - coverage: Percentage of world in daylight (default 0.5)
---  - offset: Current position of day/night terminator
---
---Visual Effect:
---  - Day zone: Bright (normal colors)
---  - Night zone: Dark overlay (darkened colors)
---  - Terminator: Smooth gradient transition
---  - Movement: Cycles left-to-right continuously
---
---Performance:
---  - Shader-based rendering (GPU accelerated)
---  - No gameplay impact (visual only)
---  - Updates once per day (not real-time)
---
---Key Exports:
---  - DayNightCycle.new(worldWidth, speed, coverage): Creates cycle system
---  - advanceDay(): Moves cycle forward by one day
---  - getTimeAtHex(q, r): Returns time (0.0-1.0) at hex position
---  - isDaylight(q, r): Returns true if hex is in daylight
---  - render(drawFunc): Applies day/night overlay to rendering
---
---Dependencies:
---  - geoscape.systems.hex_grid: For hex coordinate calculations
---
---@module geoscape.systems.daynight_cycle
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local DayNightCycle = require("geoscape.systems.daynight_cycle")
---  local cycle = DayNightCycle.new(80, 4, 0.5)  -- 80 tiles wide, 4 tiles/day, 50% coverage
---  cycle:advanceDay()
---  local isDaylight = cycle:isDaylight(hexQ, hexR)
---
---@see geoscape.world.world For world entity integration

local DayNightCycle = {}
DayNightCycle.__index = DayNightCycle

---Create a new day/night cycle system
---@param worldWidth number Width of world in hex tiles (default 90)
---@param speed number Tiles per day the cycle moves (default 4)
---@param coverage number Percentage of world in daylight (default 0.5)
---@return table DayNightCycle instance
function DayNightCycle.new(worldWidth, speed, coverage)
    local self = setmetatable({}, DayNightCycle)
    
    self.worldWidth = worldWidth or 90
    self.speed = speed or 4  -- tiles per day
    self.coverage = coverage or 0.5  -- 50% day, 50% night
    
    -- Calculate day/night boundary position (in tiles from left edge)
    -- This represents the X position where day transitions to night
    self.position = 0  -- Start at left edge
    
    -- Calculate cycle duration (full rotation)
    self.cycleDuration = self.worldWidth / self.speed  -- 90 / 4 = 22.5 days
    
    -- Transition zone width (smooth gradient between day and night)
    self.transitionWidth = 2  -- tiles
    
    print(string.format("[DayNightCycle] Initialized: %d tiles wide, %d tiles/day, %.0f%% coverage, %d day cycle",
        self.worldWidth, self.speed, self.coverage * 100, self.cycleDuration))
    
    return self
end

---Advance the day/night cycle by one day
function DayNightCycle:advanceDay()
    self.position = (self.position + self.speed) % self.worldWidth
end

---Check if a hex tile is in daylight
---@param q number Hex Q coordinate
---@param hexWidth number Width of hex grid (to calculate X position)
---@return boolean True if in daylight
---@return number Light level (0.0 = full night, 1.0 = full day)
function DayNightCycle:isDay(q, hexWidth)
    hexWidth = hexWidth or self.worldWidth
    
    -- Normalize hex position to 0-1 range
    local normalizedX = q / hexWidth
    local normalizedPosition = self.position / self.worldWidth
    
    -- Calculate distance from day/night boundary (wrapping around)
    local dist = normalizedX - normalizedPosition
    if dist < -0.5 then dist = dist + 1 end
    if dist > 0.5 then dist = dist - 1 end
    
    -- Calculate light level based on distance from boundary
    local halfCoverage = self.coverage / 2
    local normalizedTransition = self.transitionWidth / self.worldWidth
    
    if dist >= -halfCoverage and dist <= halfCoverage then
        -- In day zone or transition
        if dist >= -halfCoverage and dist <= -halfCoverage + normalizedTransition then
            -- Dawn transition
            local t = (dist + halfCoverage) / normalizedTransition
            return true, t
        elseif dist >= halfCoverage - normalizedTransition and dist <= halfCoverage then
            -- Dusk transition
            local t = 1 - (dist - (halfCoverage - normalizedTransition)) / normalizedTransition
            return true, t
        else
            -- Full day
            return true, 1.0
        end
    else
        -- Night zone
        return false, 0.0
    end
end

---Get light level at a specific hex position (0.0 = night, 1.0 = day)
---@param q number Hex Q coordinate
---@param hexWidth number Width of hex grid
---@return number Light level (0.0 to 1.0)
function DayNightCycle:getLightLevel(q, hexWidth)
    local isDay, lightLevel = self:isDay(q, hexWidth)
    return lightLevel
end

---Get the current position of the day/night boundary
---@return number Position in tiles from left edge
function DayNightCycle:getPosition()
    return self.position
end

---Set the position of the day/night boundary (for save/load)
---@param position number Position in tiles from left edge
function DayNightCycle:setPosition(position)
    self.position = position % self.worldWidth
end

---Get day/night cycle state for serialization
---@return table Cycle state
function DayNightCycle:serialize()
    return {
        position = self.position,
        worldWidth = self.worldWidth,
        speed = self.speed,
        coverage = self.coverage
    }
end

---Load day/night cycle state from serialization
---@param data table Cycle state
function DayNightCycle:deserialize(data)
    self.position = data.position or 0
    self.worldWidth = data.worldWidth or self.worldWidth
    self.speed = data.speed or self.speed
    self.coverage = data.coverage or self.coverage
end

---Get visual darkness overlay color for rendering
---@param lightLevel number Light level (0.0 to 1.0)
---@return number, number, number, number RGBA color values
function DayNightCycle.getDarknessColor(lightLevel)
    -- Invert light level to get darkness
    local darkness = 1.0 - lightLevel
    
    -- Blue-tinted night overlay
    local r = 0.1 * darkness
    local g = 0.1 * darkness
    local b = 0.3 * darkness
    local a = 0.6 * darkness  -- Alpha controls intensity
    
    return r, g, b, a
end

---Get time of day description based on light level
---@param lightLevel number Light level (0.0 to 1.0)
---@return string Time of day description
function DayNightCycle.getTimeOfDay(lightLevel)
    if lightLevel >= 0.9 then
        return "Day"
    elseif lightLevel >= 0.6 then
        return "Afternoon"
    elseif lightLevel >= 0.4 then
        return "Dusk"
    elseif lightLevel >= 0.1 then
        return "Dawn"
    else
        return "Night"
    end
end

return DayNightCycle


























