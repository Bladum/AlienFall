--- Organization Progression System
--- Manages player organization level, upgrades, and associated bonuses
---
--- The organization progresses from small company to military force.
--- Each level unlocks new capabilities and applies bonuses to operations.
---
--- Progression Levels:
--- - Level 1: Small Company (startup, limited resources)
--- - Level 2: Corporation (established presence, moderate capacity)
--- - Level 3: Military Organization (recognized force, expanded operations)
--- - Level 4: Elite Force (experienced, superior capabilities)
--- - Level 5: Global Authority (world-class organization)
---
--- @class ProgressionManager
local ProgressionManager = {}

--- Initialize progression manager
function ProgressionManager:new()
    local self = setmetatable({}, { __index = ProgressionManager })
    
    self.currentLevel = 1
    self.experiencePoints = 0
    self.levelThresholds = {
        1000,   -- Level 2 at 1000 XP
        3000,   -- Level 3 at 3000 XP
        6000,   -- Level 4 at 6000 XP
        10000,  -- Level 5 at 10000 XP
    }
    
    self.levelBonuses = {
        [1] = {
            base_capacity = 1,
            craft_slots = 1,
            funding_multiplier = 1.0,
            research_speed = 1.0,
            manufacturing_speed = 1.0,
        },
        [2] = {
            base_capacity = 2,
            craft_slots = 2,
            funding_multiplier = 1.2,
            research_speed = 1.1,
            manufacturing_speed = 1.1,
        },
        [3] = {
            base_capacity = 3,
            craft_slots = 3,
            funding_multiplier = 1.5,
            research_speed = 1.2,
            manufacturing_speed = 1.2,
        },
        [4] = {
            base_capacity = 4,
            craft_slots = 4,
            funding_multiplier = 1.8,
            research_speed = 1.3,
            manufacturing_speed = 1.3,
        },
        [5] = {
            base_capacity = 5,
            craft_slots = 5,
            funding_multiplier = 2.0,
            research_speed = 1.5,
            manufacturing_speed = 1.5,
        },
    }
    
    print("[ProgressionManager] Initialized at level " .. self.currentLevel)
    return self
end

--- Add experience points to organization
--- @param amount number XP to add
function ProgressionManager:addExperience(amount)
    self.experiencePoints = self.experiencePoints + amount
    
    -- Check for level up
    while self.currentLevel < 5 and self.experiencePoints >= self.levelThresholds[self.currentLevel] do
        self:levelUp()
    end
end

--- Level up the organization
function ProgressionManager:levelUp()
    local oldLevel = self.currentLevel
    self.currentLevel = self.currentLevel + 1
    
    print("[ProgressionManager] Organization leveled up to: " .. self.currentLevel)
    
    -- Trigger any callbacks or events
    if self.onLevelUp then
        self:onLevelUp(oldLevel, self.currentLevel)
    end
end

--- Get current organization level
--- @return number Current level (1-5)
function ProgressionManager:getLevel()
    return self.currentLevel
end

--- Get bonus for current level
--- @param bonusType string Bonus identifier (e.g., "base_capacity", "funding_multiplier")
--- @return number Bonus value
function ProgressionManager:getBonus(bonusType)
    local bonus = self.levelBonuses[self.currentLevel][bonusType]
    if not bonus then
        print("[ProgressionManager] Warning: Unknown bonus type: " .. bonusType)
        return 1
    end
    return bonus
end

--- Get all bonuses for current level
--- @return table Bonus table
function ProgressionManager:getAllBonuses()
    return self.levelBonuses[self.currentLevel] or {}
end

--- Get experience towards next level
--- @return number Current XP in this level
--- @return number Required XP for next level
function ProgressionManager:getExperienceProgress()
    local currentThreshold = self.currentLevel > 1 and self.levelThresholds[self.currentLevel - 1] or 0
    local nextThreshold = self.levelThresholds[self.currentLevel] or math.huge
    
    local currentXP = self.experiencePoints - currentThreshold
    local requiredXP = nextThreshold - currentThreshold
    
    return math.max(0, currentXP), math.max(0, requiredXP)
end

--- Get progress percentage (0-100)
--- @return number Progress as percentage
function ProgressionManager:getProgressPercentage()
    local current, required = self:getExperienceProgress()
    if required <= 0 then return 100 end
    return math.min(100, (current / required) * 100)
end

--- Check if organization can perform action at current level
--- @param actionId string Action identifier
--- @return boolean Whether action is available
function ProgressionManager:canPerformAction(actionId)
    -- Action availability based on level
    local actions = {
        ["second_base"] = 2,
        ["third_base"] = 3,
        ["satellite_launch"] = 2,
        ["psionic_training"] = 3,
        ["advanced_manufacturing"] = 3,
        ["global_operations"] = 4,
    }
    
    local requiredLevel = actions[actionId] or 1
    return self.currentLevel >= requiredLevel
end

--- Set callback for level up event
--- @param callback function Function called with (oldLevel, newLevel)
function ProgressionManager:setOnLevelUp(callback)
    self.onLevelUp = callback
end

--- Load progression state from save data
--- @param data table Save data
function ProgressionManager:load(data)
    if data.level then self.currentLevel = data.level end
    if data.experience then self.experiencePoints = data.experience end
end

--- Get progression state for saving
--- @return table Save data
function ProgressionManager:getSaveData()
    return {
        level = self.currentLevel,
        experience = self.experiencePoints,
    }
end

return ProgressionManager



