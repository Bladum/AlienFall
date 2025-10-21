---Fame System - Public Recognition and Media Coverage
---
---Tracks organization's public recognition and media coverage on a scale from 0
---(Unknown) to 100 (Legendary). Fame affects recruitment quality, funding levels,
---supplier access, special missions, and global support.
---
---Fame Levels:
---  - Unknown (0-24): No public awareness, basic resources
---  - Known (25-59): Local recognition, improved recruitment
---  - Famous (60-89): Global recognition, premium suppliers
---  - Legendary (90-100): Maximum reputation, elite resources
---
---Fame Sources:
---  - Mission success (especially high-profile missions)
---  - Enemy kills (major threats increase fame more)
---  - Objectives completed (save civilians, prevent disasters)
---  - Media coverage (interviews, public statements)
---  - Technology breakthroughs (public releases)
---
---Fame Effects:
---  - Recruitment: Higher fame attracts better soldiers
---  - Funding: Countries provide more resources
---  - Suppliers: Access to exclusive equipment
---  - Missions: Special high-profile operations
---
---Key Exports:
---  - FameSystem.new(): Creates fame tracking instance
---  - modifyFame(amount, reason): Changes fame value
---  - getFameLevel(): Returns current fame tier
---  - getRecruitmentBonus(): Calculates soldier quality bonus
---  - getFundingMultiplier(): Returns resource income modifier
---
---Dependencies:
---  - geoscape.world.world_state: Global funding calculations
---  - shared.units.units: Recruitment system
---  - economy.marketplace: Supplier access control
---
---@module politics.fame.fame_system
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local FameSystem = require("politics.fame.fame_system")
---  local fame = FameSystem.new()
---  fame:modifyFame(10, "Mission success")
---  print(fame:getFameLevel())  -- "Known"
---
---@see politics.karma For karma system
---@see politics.relations For relationship tracking

local FameSystem = {}
FameSystem.__index = FameSystem

--- Fame level thresholds
local FAME_THRESHOLDS = {
    {min = 0,  max = 24, level = "Unknown",    color = {r=0.5, g=0.5, b=0.5}},
    {min = 25, max = 59, level = "Known",      color = {r=0.0, g=0.8, b=0.0}},
    {min = 60, max = 89, level = "Famous",     color = {r=0.0, g=0.5, b=1.0}},
    {min = 90, max = 100, level = "Legendary", color = {r=1.0, g=0.8, b=0.0}},
}

--- Create new fame system
function FameSystem.new()
    local self = setmetatable({}, FameSystem)
    
    -- Current fame (0-100)
    self.fame = 50  -- Start as "Known"
    
    -- Fame history (for tracking changes)
    self.history = {}
    
    -- Fame effects
    self.effects = {
        recruitment = {
            Unknown = 0.5,    -- 50% recruit quality/availability
            Known = 1.0,      -- 100% normal
            Famous = 1.5,     -- 150% better recruits
            Legendary = 2.0,  -- 200% elite recruits
        },
        funding = {
            Unknown = 0.8,    -- 80% funding
            Known = 1.0,      -- 100% normal
            Famous = 1.2,     -- 120% funding bonus
            Legendary = 1.5,  -- 150% funding bonus
        },
        supplierAccess = {
            Unknown = 0.7,    -- Limited item selection
            Known = 1.0,      -- Normal selection
            Famous = 1.2,     -- More items available
            Legendary = 1.5,  -- All items + special access
        },
    }
    
    print("[FameSystem] Initialized at fame " .. self.fame .. " (" .. self:getLevel() .. ")")
    return self
end

--- Get current fame level name
---@return string Level name
function FameSystem:getLevel()
    for _, threshold in ipairs(FAME_THRESHOLDS) do
        if self.fame >= threshold.min and self.fame <= threshold.max then
            return threshold.level
        end
    end
    return "Unknown"
end

--- Get fame level data
---@param fame number Optional fame value (defaults to current)
---@return table Level data {min, max, level, color}
function FameSystem:getLevelData(fame)
    fame = fame or self.fame
    
    for _, threshold in ipairs(FAME_THRESHOLDS) do
        if fame >= threshold.min and fame <= threshold.max then
            return threshold
        end
    end
    
    return FAME_THRESHOLDS[1]
end

--- Modify fame
---@param delta number Fame change (-100 to +100)
---@param reason string Reason for change
function FameSystem:modifyFame(delta, reason)
    local oldFame = self.fame
    local oldLevel = self:getLevel()
    
    -- Apply change
    self.fame = math.max(0, math.min(100, self.fame + delta))
    
    local newLevel = self:getLevel()
    
    -- Record history
    table.insert(self.history, {
        delta = delta,
        reason = reason,
        oldFame = oldFame,
        newFame = self.fame,
        timestamp = os.time(),
    })
    
    print(string.format("[FameSystem] %+d fame: %s (%.0f → %.0f, %s → %s)", 
          delta, reason, oldFame, self.fame, oldLevel, newLevel))
    
    -- Check for level change
    if oldLevel ~= newLevel then
        self:onLevelChanged(oldLevel, newLevel)
    end
end

--- Handle fame level change
---@param oldLevel string Old level
---@param newLevel string New level
function FameSystem:onLevelChanged(oldLevel, newLevel)
    print("[FameSystem] LEVEL CHANGED: " .. oldLevel .. " → " .. newLevel)
    
    -- Trigger events (could integrate with event system)
    -- e.g., "Your organization is now Famous!" notification
end

--- Get fame effects multiplier
---@param effectType string Effect type ("recruitment", "funding", "supplierAccess")
---@return number Multiplier
function FameSystem:getEffectMultiplier(effectType)
    local level = self:getLevel()
    local effects = self.effects[effectType]
    
    if effects then
        return effects[level] or 1.0
    end
    
    return 1.0
end

--- Get current fame value
---@return number Fame (0-100)
function FameSystem:getFame()
    return self.fame
end

--- Set fame directly (for cheats/testing)
---@param value number Fame value (0-100)
function FameSystem:setFame(value)
    local oldFame = self.fame
    self.fame = math.max(0, math.min(100, value))
    
    print(string.format("[FameSystem] Fame set: %.0f → %.0f", oldFame, self.fame))
end

--- Get recent fame changes
---@param count number Number of recent entries (default 10)
---@return table Array of history entries
function FameSystem:getRecentHistory(count)
    count = count or 10
    local start = math.max(1, #self.history - count + 1)
    local recent = {}
    
    for i = start, #self.history do
        table.insert(recent, self.history[i])
    end
    
    return recent
end

--- Save state
---@return table State
function FameSystem:saveState()
    return {
        fame = self.fame,
        history = self.history,
    }
end

--- Load state
---@param state table Saved state
function FameSystem:loadState(state)
    self.fame = state.fame or 50
    self.history = state.history or {}
    
    print("[FameSystem] State loaded: Fame = " .. self.fame .. " (" .. self:getLevel() .. ")")
end

return FameSystem

























