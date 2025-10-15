---Karma System - Moral Alignment Tracking
---
---Tracks player's ethical and moral decisions on a scale from -100 (Evil) to
---+100 (Saint). Karma affects black market access, special missions, content
---unlocks, and NPC reactions. Core system for morality-based gameplay.
---
---Karma Levels:
---  - Evil (-100 to -75): Ruthless war crimes, maximum black market access
---  - Ruthless (-74 to -40): Pragmatic violence, good black market access
---  - Pragmatic (-39 to -10): Morally flexible, some black market access
---  - Neutral (-9 to +9): Balanced approach, standard gameplay
---  - Principled (+10 to +39): Ethical choices, bonus missions
---  - Heroic (+40 to +74): Highly ethical, special content unlocks
---  - Saint (+75 to +100): Maximum morality, unique missions
---
---Karma Sources:
---  - Mission actions (civilian casualties, surrender treatment)
---  - Black market purchases (illegal items lower karma)
---  - Research choices (ethical vs unethical experiments)
---  - Diplomacy decisions (betrayals, alliances)
---
---Key Exports:
---  - KarmaSystem.new(): Creates karma tracking instance
---  - modifyKarma(amount, reason): Changes karma value
---  - getKarmaLevel(): Returns current karma tier
---  - canAccessBlackMarket(itemId): Checks item availability
---  - getKarmaEffects(): Returns active karma modifiers
---
---Dependencies:
---  - economy.marketplace.black_market_system: Item access control
---  - lore.missions: Mission generation based on karma
---  - politics.relations: Country opinions affected by karma
---
---@module politics.karma.karma_system
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local KarmaSystem = require("politics.karma.karma_system")
---  local karma = KarmaSystem.new()
---  karma:modifyKarma(-15, "Civilian casualties")
---  print(karma:getKarmaLevel())  -- "Pragmatic"
---
---@see economy.marketplace.black_market_system For karma-based trading
---@see politics.fame For fame system

local KarmaSystem = {}
KarmaSystem.__index = KarmaSystem

--- Karma level thresholds
local KARMA_THRESHOLDS = {
    {min = -100, max = -75, level = "Evil",       color = {r=0.5, g=0.0, b=0.0}},
    {min = -74,  max = -40, level = "Ruthless",   color = {r=0.8, g=0.3, b=0.0}},
    {min = -39,  max = -10, level = "Pragmatic",  color = {r=0.9, g=0.7, b=0.0}},
    {min = -9,   max = 9,   level = "Neutral",    color = {r=0.7, g=0.7, b=0.7}},
    {min = 10,   max = 39,  level = "Principled", color = {r=0.5, g=0.8, b=0.5}},
    {min = 40,   max = 74,  level = "Heroic",     color = {r=0.0, g=0.7, b=1.0}},
    {min = 75,   max = 100, level = "Saintly",    color = {r=1.0, g=1.0, b=0.5}},
}

--- Create new karma system
function KarmaSystem.new()
    local self = setmetatable({}, KarmaSystem)
    
    -- Current karma (-100 to +100)
    self.karma = 0  -- Start neutral
    
    -- Karma history
    self.history = {}
    
    -- Karma effects (what unlocks at each level)
    self.effects = {
        blackMarketAccess = {
            threshold = -20,  -- Unlocks at Pragmatic or below
            description = "Access to black market",
        },
        humanitarianMissions = {
            threshold = 40,   -- Unlocks at Heroic or above
            description = "Special humanitarian missions",
        },
        ruthlessTactics = {
            threshold = -40,  -- Unlocks at Ruthless or below
            description = "Ruthless combat tactics available",
        },
        moralSupport = {
            threshold = 10,   -- Unlocks at Principled or above
            description = "Morale bonuses for good deeds",
        },
    }
    
    print("[KarmaSystem] Initialized at karma " .. self.karma .. " (" .. self:getLevel() .. ")")
    return self
end

--- Get current karma level name
---@return string Level name
function KarmaSystem:getLevel()
    for _, threshold in ipairs(KARMA_THRESHOLDS) do
        if self.karma >= threshold.min and self.karma <= threshold.max then
            return threshold.level
        end
    end
    return "Neutral"
end

--- Get karma level data
---@param karma number Optional karma value (defaults to current)
---@return table Level data {min, max, level, color}
function KarmaSystem:getLevelData(karma)
    karma = karma or self.karma
    
    for _, threshold in ipairs(KARMA_THRESHOLDS) do
        if karma >= threshold.min and karma <= threshold.max then
            return threshold
        end
    end
    
    return KARMA_THRESHOLDS[4]  -- Neutral
end

--- Modify karma
---@param delta number Karma change
---@param reason string Reason for change
function KarmaSystem:modifyKarma(delta, reason)
    local oldKarma = self.karma
    local oldLevel = self:getLevel()
    
    -- Apply change
    self.karma = math.max(-100, math.min(100, self.karma + delta))
    
    local newLevel = self:getLevel()
    
    -- Record history
    table.insert(self.history, {
        delta = delta,
        reason = reason,
        oldKarma = oldKarma,
        newKarma = self.karma,
        timestamp = os.time(),
    })
    
    print(string.format("[KarmaSystem] %+d karma: %s (%.0f → %.0f, %s → %s)", 
          delta, reason, oldKarma, self.karma, oldLevel, newLevel))
    
    -- Check for level change
    if oldLevel ~= newLevel then
        self:onLevelChanged(oldLevel, newLevel)
    end
end

--- Handle karma level change
---@param oldLevel string Old level
---@param newLevel string New level
function KarmaSystem:onLevelChanged(oldLevel, newLevel)
    print("[KarmaSystem] LEVEL CHANGED: " .. oldLevel .. " → " .. newLevel)
    
    -- Check for unlocked/locked features
    self:checkFeatureUnlocks()
end

--- Check if feature is unlocked by karma
---@param featureName string Feature name
---@return boolean Unlocked
function KarmaSystem:isFeatureUnlocked(featureName)
    local effect = self.effects[featureName]
    
    if not effect then
        return false
    end
    
    if effect.threshold < 0 then
        -- Negative karma requirement (e.g., black market)
        return self.karma <= effect.threshold
    else
        -- Positive karma requirement (e.g., humanitarian)
        return self.karma >= effect.threshold
    end
end

--- Check all feature unlocks
function KarmaSystem:checkFeatureUnlocks()
    for featureName, effect in pairs(self.effects) do
        local unlocked = self:isFeatureUnlocked(featureName)
        print("[KarmaSystem] " .. featureName .. ": " .. tostring(unlocked))
    end
end

--- Get current karma value
---@return number Karma (-100 to +100)
function KarmaSystem:getKarma()
    return self.karma
end

--- Set karma directly (for cheats/testing)
---@param value number Karma value (-100 to +100)
function KarmaSystem:setKarma(value)
    local oldKarma = self.karma
    self.karma = math.max(-100, math.min(100, value))
    
    print(string.format("[KarmaSystem] Karma set: %.0f → %.0f", oldKarma, self.karma))
end

--- Common karma events
function KarmaSystem:civilianKilled()
    self:modifyKarma(-10, "Civilian killed")
end

function KarmaSystem:civilianSaved()
    self:modifyKarma(5, "Civilian saved")
end

function KarmaSystem:prisonerExecuted()
    self:modifyKarma(-20, "Prisoner executed")
end

function KarmaSystem:prisonerSpared()
    self:modifyKarma(10, "Prisoner spared")
end

function KarmaSystem:humanitarianMissionCompleted()
    self:modifyKarma(15, "Humanitarian mission")
end

function KarmaSystem:excessiveForceUsed()
    self:modifyKarma(-5, "Excessive force")
end

--- Get recent karma changes
---@param count number Number of recent entries (default 10)
---@return table Array of history entries
function KarmaSystem:getRecentHistory(count)
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
function KarmaSystem:saveState()
    return {
        karma = self.karma,
        history = self.history,
    }
end

--- Load state
---@param state table Saved state
function KarmaSystem:loadState(state)
    self.karma = state.karma or 0
    self.history = state.history or {}
    
    print("[KarmaSystem] State loaded: Karma = " .. self.karma .. " (" .. self:getLevel() .. ")")
end

return KarmaSystem






















