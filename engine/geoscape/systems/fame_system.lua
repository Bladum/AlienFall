---Fame System - Public Recognition and Media Coverage
---
---Tracks how well-known the player's organization is, affecting funding, recruitment,
---and supplier access. Fame increases from mission success and decreases from failure.
---High fame provides benefits but also attracts media scrutiny and increases black
---market discovery risk.
---
---Fame Values:
---  - Range: 0 (unknown) to 100 (legendary)
---  - Levels: Unknown (0-24), Known (25-59), Famous (60-89), Legendary (90-100)
---
---Fame Effects:
---  - Funding: +0% to +100% multiplier
---  - Recruitment: Better recruit availability at high fame
---  - Supplier Access: Some suppliers require minimum fame
---  - Black Market Risk: Higher fame = higher discovery chance
---  - Panic Reduction: Famous organization helps with panic
---
---Fame Sources:
---  - Mission success: +5 fame
---  - Mission failure: -3 fame
---  - UFO destroyed: +2 fame
---  - Base raided: -10 fame
---  - Research breakthrough: +3 fame
---  - Civilian casualties: -5 fame
---  - Major victory: +15 fame
---  - Black market discovery: -20 fame
---
---Key Exports:
---  - FameSystem.new(): Create system
---  - modifyFame(delta, reason): Change fame
---  - getFame(): Get current fame level
---  - getLevel(fame): Get descriptive level
---  - getFameModifier(): Get funding multiplier
---
---@module geoscape.systems.fame_system
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local FameSystem = require("geoscape.systems.fame_system")
---  local fame = FameSystem.new()
---  fame:modifyFame(5, "Mission success")
---  print("Level: " .. fame:getLevel(fame:getFame()))

local FameSystem = {}
FameSystem.__index = FameSystem

--- Create new fame system
---@return table New fame system instance
function FameSystem.new()
    local self = setmetatable({}, FameSystem)
    
    -- Core state
    self.fame = 50  -- Start at "Known" level
    self.history = {}  -- Change history
    self.trend = "stable"  -- "improving", "declining", "stable"
    
    -- Level thresholds
    self.levels = {
        {min = 90,  max = 100, label = "Legendary", modifier = 1.5},
        {min = 60,  max = 89,  label = "Famous",    modifier = 1.25},
        {min = 25,  max = 59,  label = "Known",     modifier = 1.0},
        {min = 0,   max = 24,  label = "Unknown",   modifier = 0.5}
    }
    
    -- Configuration
    self.config = {
        maxFame = 100,
        minFame = 0,
        maxHistorySize = 20,
        decayPerMonth = -2,  -- Fame decays 2 points per month of inactivity
    }
    
    print("[FameSystem] Initialized with fame = 50 (Known)")
    
    return self
end

---Modify fame by delta
---@param delta number Amount to change (-50 to +50 typical)
---@param reason string Reason for change
---@return number New fame level
function FameSystem:modifyFame(delta, reason)
    local oldFame = self.fame
    self.fame = math.max(self.config.minFame, math.min(self.config.maxFame, self.fame + delta))
    
    -- Record change
    self:recordChange(delta, reason)
    
    -- Check for level changes
    local oldLevel = self:getLevel(oldFame)
    local newLevel = self:getLevel(self.fame)
    
    if oldLevel ~= newLevel then
        print(string.format("[FameSystem] LEVEL UP: %s → %s (Fame: %d → %d)",
              oldLevel, newLevel, oldFame, self.fame))
    else
        print(string.format("[FameSystem] Fame: %d %c %d = %d (%s)",
              oldFame, delta >= 0 and '+' or ' ', delta, self.fame, reason))
    end
    
    -- Update trend
    self:updateTrend()
    
    return self.fame
end

---Record fame change in history
---@param delta number Change amount
---@param reason string Reason for change
function FameSystem:recordChange(delta, reason)
    table.insert(self.history, 1, {
        delta = delta,
        reason = reason,
        timestamp = os.time()
    })
    
    -- Keep only recent history
    if #self.history > self.config.maxHistorySize then
        table.remove(self.history, self.config.maxHistorySize + 1)
    end
end

---Update trend (improving/declining/stable)
function FameSystem:updateTrend()
    if #self.history == 0 then
        self.trend = "stable"
        return
    end
    
    -- Calculate average delta from recent changes
    local recentCount = math.min(5, #self.history)
    local totalDelta = 0
    
    for i = 1, recentCount do
        totalDelta = totalDelta + self.history[i].delta
    end
    
    local avgDelta = totalDelta / recentCount
    
    if avgDelta > 1 then
        self.trend = "improving"
    elseif avgDelta < -1 then
        self.trend = "declining"
    else
        self.trend = "stable"
    end
end

---Get current fame level
---@return number Fame level (0-100)
function FameSystem:getFame()
    return self.fame
end

---Set fame to exact value
---@param value number Target fame (0-100)
---@param reason string Reason for setting
function FameSystem:setFame(value, reason)
    value = math.max(self.config.minFame, math.min(self.config.maxFame, value))
    local delta = value - self.fame
    self:modifyFame(delta, reason or "Direct set")
end

---Get descriptive level for fame value
---@param value number Fame value
---@return string Level name
function FameSystem:getLevel(value)
    for _, level in ipairs(self.levels) do
        if value >= level.min and value <= level.max then
            return level.label
        end
    end
    return "Unknown"
end

---Get funding modifier for current fame
---@return number Multiplier (0.5 to 1.5)
function FameSystem:getFameModifier()
    local level = self:getLevel(self.fame)
    
    for _, levelDef in ipairs(self.levels) do
        if levelDef.label == level then
            return levelDef.modifier
        end
    end
    
    return 1.0  -- Default
end

---Get color for fame level (for UI)
---@return table RGB color {r, g, b}
function FameSystem:getFameColor()
    local level = self:getLevel(self.fame)
    
    if level == "Legendary" then
        return {255, 215, 0}      -- Gold
    elseif level == "Famous" then
        return {200, 200, 0}      -- Yellow
    elseif level == "Known" then
        return {100, 150, 255}    -- Blue
    else
        return {150, 150, 150}    -- Gray
    end
end

---Get fame description for UI display
---@return string Formatted description
function FameSystem:getDescription()
    local level = self:getLevel(self.fame)
    local modifier = string.format("%.0f%%", (self:getFameModifier() - 0.5) * 100)
    local trendText = self.trend == "improving" and "↑" or (self.trend == "declining" and "↓" or "→")
    
    return string.format("%s (%d) %s | Funding: %s", level, self.fame, trendText, modifier)
end

---Get recent history entries
---@param maxEntries number Maximum entries to return (default 10)
---@return table Array of {delta, reason, timestamp}
function FameSystem:getHistory(maxEntries)
    maxEntries = maxEntries or 10
    local result = {}
    
    for i = 1, math.min(maxEntries, #self.history) do
        table.insert(result, self.history[i])
    end
    
    return result
end

---Process monthly decay
function FameSystem:processMonthlyDecay()
    if self.fame > 50 then
        -- High fame decays if no new missions
        self:modifyFame(self.config.decayPerMonth, "Monthly decay (inactivity)")
    end
end

---Apply mission result
---@param success boolean Mission success status
---@param difficulty number Mission difficulty (1-5)
---@param civilian_casualties number Civilians killed (0+)
---@param mission_type string Type of mission (site, crash, terror, base, etc.)
function FameSystem:applyMissionResult(success, difficulty, civilian_casualties, mission_type)
    local delta = 0
    local reason = ""
    
    if success then
        -- Success gives fame based on difficulty
        delta = 3 + difficulty  -- 3-8 fame for success
        reason = "Mission success (difficulty: " .. difficulty .. ")"
        
        -- Bonus for major mission types
        if mission_type == "base" then
            delta = delta + 5
            reason = reason .. " - MAJOR VICTORY"
        elseif mission_type == "crash" then
            delta = delta + 2
        end
    else
        -- Failure reduces fame
        delta = -3 - math.floor(difficulty / 2)
        reason = "Mission failure"
    end
    
    -- Civilian casualties heavily reduce fame
    if civilian_casualties and civilian_casualties > 0 then
        delta = delta - (civilian_casualties * 2)
        reason = reason .. " (civilians killed: " .. civilian_casualties .. ")"
    end
    
    self:modifyFame(delta, reason)
end

---Apply UFO destroyed
---@param ufo_type string Type of UFO
function FameSystem:applyUFODestroyed(ufo_type)
    local delta = 2
    
    if ufo_type == "battleship" then
        delta = 10
    elseif ufo_type == "carrier" then
        delta = 8
    elseif ufo_type == "destroyer" then
        delta = 5
    end
    
    self:modifyFame(delta, "UFO destroyed: " .. ufo_type)
end

---Apply base raid consequences
function FameSystem:applyBaseRaided()
    self:modifyFame(-10, "Base raided - major defensive failure")
end

---Apply research breakthrough
---@param research_name string Research name
function FameSystem:applyResearchBreakthrough(research_name)
    self:modifyFame(3, "Research breakthrough: " .. research_name)
end

---Apply black market discovery
function FameSystem:applyBlackMarketDiscovery()
    self:modifyFame(-20, "Black market operations discovered")
end

---Get status summary
---@return table Status including fame, level, modifier, trend
function FameSystem:getStatus()
    return {
        fame = self.fame,
        level = self:getLevel(self.fame),
        modifier = self:getFameModifier(),
        trend = self.trend,
        description = self:getDescription(),
        color = self:getFameColor()
    }
end

---Serialize for save/load
---@return table Serialized state
function FameSystem:serialize()
    return {
        fame = self.fame,
        history = self.history,
        trend = self.trend
    }
end

---Deserialize from save/load
---@param data table Serialized state
function FameSystem:deserialize(data)
    if not data then return end
    
    self.fame = data.fame or 50
    self.history = data.history or {}
    self.trend = data.trend or "stable"
    
    print(string.format("[FameSystem] Deserialized: fame=%d, level=%s", 
          self.fame, self:getLevel(self.fame)))
end

return FameSystem
