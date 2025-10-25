---Organization System - Player Organization Level and Progression
---
---Tracks organization level, XP, capabilities, and unlocked features based on
---mission success, research progress, and reputation. Organization level affects
---available facilities, personnel quality, funding, and strategic capabilities.
---
---Organization Levels:
---  - Rookie (0-500 XP): Basic operations with limited resources
---  - Established (501-1500 XP): Growing organization with expanded capabilities
---  - Veteran (1501-3500 XP): Experienced command with advanced options
---  - Elite (3501-6500 XP): High-level operations with strategic influence
---  - Legendary (6501+ XP): Maximum organization with global impact
---
---XP Sources:
---  - Mission success (base 100 XP + objectives completed * 50)
---  - Research completion (current tech level * 100)
---  - Facility construction (facility tier * 200)
---  - Diplomat agreements (50 XP per agreement)
---  - Special achievements (50-500 XP)
---
---Organization Effects:
---  - Personnel: Higher level attracts better quality soldiers
---  - Facilities: Unlock advanced facility types at higher levels
---  - Funding: Better government support at higher levels
---  - Advisors: Can hire more advisors at higher levels
---  - Research: Accelerated research development
---
---Key Exports:
---  - OrganizationSystem.new(): Creates organization tracking instance
---  - addXP(amount, reason): Grants experience points
---  - getLevel(): Returns current organization level tier
---  - getLevelProgress(): Returns XP progress to next level
---  - canUnlock(featureName): Checks if feature is available
---  - getUnlockedFeatures(): Lists all available features
---  - getOrganizationBonus(bonusType): Returns active bonus value
---
---Dependencies:
---  - politics.fame: Organization reputation
---  - economy.finance: Funding calculations
---  - basescape.facilities: Facility unlocking
---
---@module politics.organization.organization
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local Organization = require("politics.organization.organization")
---  local org = Organization.new()
---  org:addXP(100, "Mission success")
---  print(org:getLevel())  -- "Established"
---
---@see politics.fame For organization fame/reputation
---@see economy.finance For funding calculations
---@see basescape.facilities For facility unlocking

local Organization = {}
Organization.__index = Organization

--- Organization level thresholds and properties
local LEVEL_DATA = {
    {level = 1, name = "Rookie", minXP = 0, maxXP = 500, color = {r=0.5, g=0.5, b=0.5}},
    {level = 2, name = "Established", minXP = 501, maxXP = 1500, color = {r=0.0, g=0.8, b=0.0}},
    {level = 3, name = "Veteran", minXP = 1501, maxXP = 3500, color = {r=0.0, g=0.5, b=1.0}},
    {level = 4, name = "Elite", minXP = 3501, maxXP = 6500, color = {r=1.0, g=0.5, b=0.0}},
    {level = 5, name = "Legendary", minXP = 6501, maxXP = math.huge, color = {r=1.0, g=1.0, b=0.0}},
}

--- Feature unlocks by organization level
local FEATURE_UNLOCKS = {
    -- Rookie (Level 1)
    ["basic_facilities"] = {level = 1, description = "Build basic facilities"},
    ["small_squad"] = {level = 1, description = "Deploy small squads (4-6 units)"},
    ["basic_equipment"] = {level = 1, description = "Access to basic weapons and armor"},
    ["single_craft"] = {level = 1, description = "Operate single craft"},
    
    -- Established (Level 2)
    ["advanced_facilities"] = {level = 2, description = "Build advanced facility types"},
    ["medium_squad"] = {level = 2, description = "Deploy medium squads (6-10 units)"},
    ["advanced_equipment"] = {level = 2, description = "Access to advanced weapons"},
    ["two_crafts"] = {level = 2, description = "Operate two crafts simultaneously"},
    ["first_advisor"] = {level = 2, description = "Hire first advisor"},
    ["armor_customization"] = {level = 2, description = "Customize soldier equipment"},
    
    -- Veteran (Level 3)
    ["elite_facilities"] = {level = 3, description = "Build elite facility types"},
    ["large_squad"] = {level = 3, description = "Deploy large squads (10-16 units)"},
    ["elite_equipment"] = {level = 3, description = "Access to elite weapons"},
    ["three_crafts"] = {level = 3, description = "Operate three crafts simultaneously"},
    ["three_advisors"] = {level = 3, description = "Hire up to three advisors"},
    ["research_acceleration"] = {level = 3, description = "Research points accelerated by 25%"},
    ["special_missions"] = {level = 3, description = "Access to special operations"},
    
    -- Elite (Level 4)
    ["legendary_facilities"] = {level = 4, description = "Build legendary facility types"},
    ["full_squad"] = {level = 4, description = "Deploy full squads (16-20 units)"},
    ["legendary_equipment"] = {level = 4, description = "Access to legendary weapons"},
    ["four_crafts"] = {level = 4, description = "Operate four crafts simultaneously"},
    ["four_advisors"] = {level = 4, description = "Hire up to four advisors"},
    ["research_acceleration_50"] = {level = 4, description = "Research points accelerated by 50%"},
    ["diplomatic_immunity"] = {level = 4, description = "Minor diplomatic immunity to incidents"},
    ["funding_bonus_25"] = {level = 4, description = "Funding increased by 25%"},
    
    -- Legendary (Level 5)
    ["ultimate_facilities"] = {level = 5, description = "Build ultimate facility types"},
    ["mega_squad"] = {level = 5, description = "Deploy mega squads (20+ units)"},
    ["ultimate_equipment"] = {level = 5, description = "Access to ultimate weapons"},
    ["five_crafts"] = {level = 5, description = "Operate five or more crafts"},
    ["five_advisors"] = {level = 5, description = "Hire up to five advisors"},
    ["research_acceleration_100"] = {level = 5, description = "Research points accelerated by 100%"},
    ["full_diplomatic_immunity"] = {level = 5, description = "Significant diplomatic immunity"},
    ["funding_bonus_50"] = {level = 5, description = "Funding increased by 50%"},
    ["instant_build_discount"] = {level = 5, description = "Construction time reduced by 50%"},
}

--- Organization bonuses by level
local BONUSES = {
    recruitment = {
        [1] = 1.0,    -- Rookie: 100% normal recruitment
        [2] = 1.2,    -- Established: 120%
        [3] = 1.5,    -- Veteran: 150%
        [4] = 1.8,    -- Elite: 180%
        [5] = 2.2,    -- Legendary: 220%
    },
    funding = {
        [1] = 1.0,    -- Rookie: 100% normal funding
        [2] = 1.1,    -- Established: 110%
        [3] = 1.25,   -- Veteran: 125%
        [4] = 1.4,    -- Elite: 140%
        [5] = 1.6,    -- Legendary: 160%
    },
    research = {
        [1] = 1.0,    -- Rookie: 100% normal research
        [2] = 1.1,    -- Established: 110%
        [3] = 1.25,   -- Veteran: 125%
        [4] = 1.4,    -- Elite: 140%
        [5] = 1.6,    -- Legendary: 160%
    },
    manufacturing = {
        [1] = 1.0,    -- Rookie: 100% normal manufacturing
        [2] = 1.05,   -- Established: 105%
        [3] = 1.15,   -- Veteran: 115%
        [4] = 1.25,   -- Elite: 125%
        [5] = 1.4,    -- Legendary: 140%
    },
    advisor_slots = {
        [1] = 0,      -- Rookie: No advisors
        [2] = 1,      -- Established: 1 advisor
        [3] = 3,      -- Veteran: 3 advisors
        [4] = 4,      -- Elite: 4 advisors
        [5] = 5,      -- Legendary: 5 advisors
    },
}

--- Create new organization system
function Organization.new()
    local self = setmetatable({}, Organization)
    
    -- Current experience points
    self.xp = 0
    
    -- Organization data
    self.name = "XCOM"
    self.founded_date = 0  -- Game turn
    
    -- History tracking
    self.history = {}
    self.level_ups = {}
    
    -- Current level (calculated from XP)
    self._currentLevel = nil
    
    return self
end

--- Get current organization level from XP
---@return number Current level (1-5)
function Organization:getLevel()
    for i = #LEVEL_DATA, 1, -1 do
        if self.xp >= LEVEL_DATA[i].minXP then
            self._currentLevel = LEVEL_DATA[i].level
            return LEVEL_DATA[i].level
        end
    end
    return 1
end

--- Get level name for current XP
---@return string Level name (e.g., "Rookie", "Established")
function Organization:getLevelName()
    local level = self:getLevel()
    for _, levelData in ipairs(LEVEL_DATA) do
        if levelData.level == level then
            return levelData.name
        end
    end
    return "Unknown"
end

--- Get level data for current level
---@return table Level data with name, xp range, color
function Organization:getLevelData()
    local level = self:getLevel()
    for _, levelData in ipairs(LEVEL_DATA) do
        if levelData.level == level then
            return levelData
        end
    end
    return LEVEL_DATA[1]
end

--- Get progress toward next level
---@return number, number, number Current XP, XP needed for next level, Progress percentage (0-100)
function Organization:getLevelProgress()
    local currentLevel = self:getLevel()
    local currentLevelData = self:getLevelData()
    
    -- If at max level
    if currentLevel >= 5 then
        return self.xp, 0, 100
    end
    
    -- Get next level data
    local nextLevelData
    for _, levelData in ipairs(LEVEL_DATA) do
        if levelData.level == currentLevel + 1 then
            nextLevelData = levelData
            break
        end
    end
    
    if not nextLevelData then
        return self.xp, 0, 100
    end
    
    local xpInCurrentLevel = self.xp - currentLevelData.minXP
    local xpNeededForNextLevel = nextLevelData.minXP - currentLevelData.minXP
    local progress = math.floor((xpInCurrentLevel / xpNeededForNextLevel) * 100)
    
    return xpInCurrentLevel, xpNeededForNextLevel, math.min(progress, 100)
end

--- Add XP to organization
---@param amount number XP amount to add
---@param reason string Reason for XP gain (logged in history)
function Organization:addXP(amount, reason)
    assert(amount and amount > 0, "XP amount must be positive number")
    
    local oldLevel = self:getLevel()
    local oldXP = self.xp
    
    self.xp = self.xp + amount
    
    -- Log to history
    table.insert(self.history, {
        turn = 0,  -- Would come from game state
        xp_gained = amount,
        total_xp = self.xp,
        reason = reason or "Unknown",
    })
    
    local newLevel = self:getLevel()
    
    -- Check for level up
    if newLevel > oldLevel then
        table.insert(self.level_ups, {
            level = newLevel,
            level_name = self:getLevelName(),
            xp = self.xp,
            turn = 0,  -- Would come from game state
        })
        
        print(string.format("[Organization] LEVEL UP! Now %s (Level %d) - XP: %d",
            self:getLevelName(), newLevel, self.xp))
    end
end

--- Check if a feature is unlocked at current level
---@param featureName string Feature name to check
---@return boolean True if feature is unlocked
function Organization:canUnlock(featureName)
    assert(featureName, "Feature name required")
    
    local feature = FEATURE_UNLOCKS[featureName]
    if not feature then
        return false
    end
    
    return self:getLevel() >= feature.level
end

--- Get all unlocked features for current level
---@return table Array of unlocked feature names
function Organization:getUnlockedFeatures()
    local currentLevel = self:getLevel()
    local unlocked = {}
    
    for featureName, feature in pairs(FEATURE_UNLOCKS) do
        if feature.level <= currentLevel then
            table.insert(unlocked, {
                name = featureName,
                level = feature.level,
                description = feature.description,
            })
        end
    end
    
    -- Sort by level unlocked
    table.sort(unlocked, function(a, b)
        return a.level < b.level
    end)
    
    return unlocked
end

--- Get organization bonus multiplier for a bonus type
---@param bonusType string Bonus type (recruitment, funding, research, manufacturing, advisor_slots)
---@return number Bonus multiplier or count
function Organization:getOrganizationBonus(bonusType)
    assert(bonusType, "Bonus type required")
    
    local level = self:getLevel()
    local bonusTable = BONUSES[bonusType]
    
    if not bonusTable then
        print(string.format("[WARNING] Unknown bonus type: %s", bonusType))
        return 1.0
    end
    
    return bonusTable[level] or 1.0
end

--- Get total bonus for all bonus types
---@return table Table with all bonuses for current level
function Organization:getAllBonuses()
    local level = self:getLevel()
    local allBonuses = {}
    
    for bonusType, bonusTable in pairs(BONUSES) do
        allBonuses[bonusType] = bonusTable[level] or 1.0
    end
    
    return allBonuses
end

--- Get organization statistics
---@return table Statistics including level, xp, features, bonuses
function Organization:getStats()
    return {
        name = self.name,
        level = self:getLevel(),
        level_name = self:getLevelName(),
        total_xp = self.xp,
        xp_progress = {
            current = select(1, self:getLevelProgress()),
            needed = select(2, self:getLevelProgress()),
            percent = select(3, self:getLevelProgress()),
        },
        unlocked_features = #self:getUnlockedFeatures(),
        level_ups = #self.level_ups,
        bonuses = self:getAllBonuses(),
    }
end

--- Save organization state
---@return table Serialized organization data
function Organization:save()
    return {
        xp = self.xp,
        name = self.name,
        founded_date = self.founded_date,
        history = self.history,
        level_ups = self.level_ups,
    }
end

--- Load organization state
---@param data table Serialized organization data
function Organization:load(data)
    self.xp = data.xp or 0
    self.name = data.name or "XCOM"
    self.founded_date = data.founded_date or 0
    self.history = data.history or {}
    self.level_ups = data.level_ups or {}
end

return Organization




