---@class AchievementSystem
---@field traitSystem TraitSystem
---@field achievements table<string, AchievementDefinition>
---@field unitAchievements table<string, table> Unit ID -> achievement progress
local AchievementSystem = {}

--- Achievement definition structure
---@class AchievementDefinition
---@field id string Unique identifier
---@field name string Display name
---@field description string Achievement description
---@field requirements table Requirements to unlock
---@field reward_trait string|nil Trait ID to unlock
---@field reward_xp number|nil XP reward
---@field category string Achievement category
---@field hidden boolean Whether achievement is hidden until unlocked

-- Initialize achievement system
function AchievementSystem:init(traitSystem)
    self.traitSystem = traitSystem
    self.achievements = {}
    self.unitAchievements = {}
    self:loadAchievementDefinitions()
end

-- Load all achievement definitions
function AchievementSystem:loadAchievementDefinitions()
    -- Combat Achievements
    self:addAchievement({
        id = "rifle_kills_20",
        name = "Rifleman",
        description = "Kill 20 enemies with rifle",
        requirements = {rifle_kills = 20},
        reward_trait = "marksman",
        category = "combat",
        hidden = false
    })

    self:addAchievement({
        id = "melee_kills_15",
        name = "Close Combat Specialist",
        description = "Kill 15 enemies in melee combat",
        requirements = {melee_kills = 15},
        reward_trait = "close_combat_expert",
        category = "combat",
        hidden = false
    })

    self:addAchievement({
        id = "headshots_5",
        name = "Sharpshooter",
        description = "Get 5 headshot kills",
        requirements = {headshot_kills = 5},
        reward_trait = "deadly_aim",
        category = "combat",
        hidden = false
    })

    -- Physical Achievements
    self:addAchievement({
        id = "missions_50_no_injury",
        name = "Unscarred",
        description = "Complete 50 missions without being injured",
        requirements = {missions_completed = 50, times_injured = 0},
        reward_trait = "unscarred",
        category = "survival",
        hidden = false
    })

    self:addAchievement({
        id = "climbing_expert",
        name = "Climbing Expert",
        description = "Successfully climb 10 difficult terrain features",
        requirements = {difficult_climbs = 10},
        reward_trait = "gymnast",
        category = "physical",
        hidden = false
    })

    -- Mental Achievements
    self:addAchievement({
        id = "missions_50_suppression",
        name = "Battle Hardened",
        description = "Complete 50 missions",
        requirements = {missions_completed = 50},
        reward_trait = "battle_hardened",
        category = "mental",
        hidden = false
    })

    self:addAchievement({
        id = "missions_5_no_casualties",
        name = "Unbreakable Bond",
        description = "Complete 5 missions without any squad casualties",
        requirements = {missions_no_casualties = 5},
        reward_trait = "unbreakable_bond",
        category = "leadership",
        hidden = false
    })

    -- Support Achievements
    self:addAchievement({
        id = "healing_100",
        name = "Field Surgeon",
        description = "Heal 100 total damage over career",
        requirements = {damage_healed = 100},
        reward_trait = "healer",
        category = "medical",
        hidden = false
    })

    self:addAchievement({
        id = "repairs_10",
        name = "Field Engineer",
        description = "Repair 10 pieces of equipment in the field",
        requirements = {equipment_repairs = 10},
        reward_trait = "field_engineer",
        category = "technical",
        hidden = false
    })

    -- Legendary Achievements
    self:addAchievement({
        id = "total_kills_1000",
        name = "War Hero",
        description = "Achieve 1000 total kills",
        requirements = {total_kills = 1000},
        reward_trait = "war_hero",
        category = "legendary",
        hidden = true
    })

    self:addAchievement({
        id = "missions_200_no_injury",
        name = "Living Legend",
        description = "Complete 200 missions without ever being injured",
        requirements = {missions_completed = 200, times_injured = 0},
        reward_trait = "living_legend",
        category = "legendary",
        hidden = true
    })
end

-- Add an achievement definition
function AchievementSystem:addAchievement(achievementDef)
    self.achievements[achievementDef.id] = achievementDef
end

-- Get achievement by ID
function AchievementSystem:getAchievement(achievementId)
    return self.achievements[achievementId]
end

-- Get all achievements
function AchievementSystem:getAllAchievements()
    return self.achievements
end

-- Get achievements by category
function AchievementSystem:getAchievementsByCategory(category)
    local categoryAchievements = {}
    for id, achievement in pairs(self.achievements) do
        if achievement.category == category then
            table.insert(categoryAchievements, achievement)
        end
    end
    return categoryAchievements
end

-- Initialize achievement tracking for a unit
function AchievementSystem:initUnitAchievements(unitId)
    if not self.unitAchievements[unitId] then
        self.unitAchievements[unitId] = {
            progress = {},
            unlocked = {},
            completed = {}
        }
    end
end

-- Update achievement progress for a unit
function AchievementSystem:updateProgress(unitId, statName, newValue, oldValue)
    self:initUnitAchievements(unitId)

    local unitAchievements = self.unitAchievements[unitId]

    -- Update progress for all achievements that track this stat
    for achievementId, achievement in pairs(self.achievements) do
        if achievement.requirements[statName] then
            local required = achievement.requirements[statName]
            local current = unitAchievements.progress[achievementId] or {}
            current[statName] = newValue

            -- Check if all requirements are met
            if self:checkAchievementRequirements(achievement, current) then
                self:unlockAchievement(unitId, achievementId)
            end
        end
    end
end

-- Check if achievement requirements are met
function AchievementSystem:checkAchievementRequirements(achievement, progress)
    for statName, requiredValue in pairs(achievement.requirements) do
        local currentValue = progress[statName] or 0
        if currentValue < requiredValue then
            return false
        end
    end
    return true
end

-- Unlock an achievement for a unit
function AchievementSystem:unlockAchievement(unitId, achievementId)
    self:initUnitAchievements(unitId)

    local unitAchievements = self.unitAchievements[unitId]
    local achievement = self:getAchievement(achievementId)

    if not achievement then
        return false, "Achievement not found"
    end

    -- Check if already unlocked
    if unitAchievements.unlocked[achievementId] then
        return false, "Achievement already unlocked"
    end

    -- Mark as unlocked
    unitAchievements.unlocked[achievementId] = true
    unitAchievements.completed[achievementId] = os.time()

    -- Grant rewards
    if achievement.reward_trait then
        return self:grantTraitReward(unitId, achievement.reward_trait)
    end

    if achievement.reward_xp then
        return self:grantXpReward(unitId, achievement.reward_xp)
    end

    return true
end

-- Grant trait reward to unit
function AchievementSystem:grantTraitReward(unitId, traitId)
    -- This would integrate with the unit system to add the trait
    -- For now, we'll just return success - actual implementation
    -- would call UnitCreationSystem:addTraitToUnit()

    print(string.format("[AchievementSystem] Granting trait %s to unit %s", traitId, unitId))
    return true, traitId
end

-- Grant XP reward to unit
function AchievementSystem:grantXpReward(unitId, xpAmount)
    -- This would integrate with the unit system to add XP
    print(string.format("[AchievementSystem] Granting %d XP to unit %s", xpAmount, unitId))
    return true, xpAmount
end

-- Get achievement progress for a unit
function AchievementSystem:getUnitProgress(unitId, achievementId)
    self:initUnitAchievements(unitId)

    local unitAchievements = self.unitAchievements[unitId]
    return unitAchievements.progress[achievementId] or {}
end

-- Get all unlocked achievements for a unit
function AchievementSystem:getUnitAchievements(unitId)
    self:initUnitAchievements(unitId)

    local unlocked = {}
    for achievementId, _ in pairs(self.unitAchievements[unitId].unlocked) do
        local achievement = self:getAchievement(achievementId)
        if achievement then
            table.insert(unlocked, achievement)
        end
    end

    return unlocked
end

-- Check if unit has unlocked an achievement
function AchievementSystem:hasAchievement(unitId, achievementId)
    self:initUnitAchievements(unitId)
    return self.unitAchievements[unitId].unlocked[achievementId] or false
end

-- Get available achievements for a unit (not yet unlocked)
function AchievementSystem:getAvailableAchievements(unitId)
    self:initUnitAchievements(unitId)

    local available = {}
    local unitAchievements = self.unitAchievements[unitId]

    for achievementId, achievement in pairs(self.achievements) do
        if not unitAchievements.unlocked[achievementId] and not achievement.hidden then
            -- Check if unit has made progress toward this achievement
            local progress = unitAchievements.progress[achievementId] or {}
            local hasProgress = false

            for statName, requiredValue in pairs(achievement.requirements) do
                if (progress[statName] or 0) > 0 then
                    hasProgress = true
                    break
                end
            end

            if hasProgress then
                table.insert(available, achievement)
            end
        end
    end

    return available
end

-- Get achievement completion percentage
function AchievementSystem:getCompletionPercentage(unitId, achievementId)
    local achievement = self:getAchievement(achievementId)
    if not achievement then return 0 end

    local progress = self:getUnitProgress(unitId, achievementId)

    local totalRequired = 0
    local totalProgress = 0

    for statName, requiredValue in pairs(achievement.requirements) do
        totalRequired = totalRequired + requiredValue
        totalProgress = totalProgress + math.min(progress[statName] or 0, requiredValue)
    end

    if totalRequired == 0 then return 100 end
    return math.floor((totalProgress / totalRequired) * 100)
end

-- Save achievement data
function AchievementSystem:saveData()
    -- This would serialize self.unitAchievements to save file
    return {
        unitAchievements = self.unitAchievements,
        version = "1.0"
    }
end

-- Load achievement data
function AchievementSystem:loadData(data)
    if data and data.unitAchievements then
        self.unitAchievements = data.unitAchievements
    end
end

-- Reset all achievements for a unit (for testing/debugging)
function AchievementSystem:resetUnitAchievements(unitId)
    self.unitAchievements[unitId] = {
        progress = {},
        unlocked = {},
        completed = {}
    }
end

-- Get achievement statistics
function AchievementSystem:getStats()
    local stats = {
        total_achievements = 0,
        total_unlocked = 0,
        achievements_by_category = {}
    }

    for _, achievement in pairs(self.achievements) do
        stats.total_achievements = stats.total_achievements + 1

        if not stats.achievements_by_category[achievement.category] then
            stats.achievements_by_category[achievement.category] = 0
        end
        stats.achievements_by_category[achievement.category] =
            stats.achievements_by_category[achievement.category] + 1
    end

    -- Count unlocked achievements across all units
    for _, unitData in pairs(self.unitAchievements) do
        for _ in pairs(unitData.unlocked) do
            stats.total_unlocked = stats.total_unlocked + 1
        end
    end

    return stats
end

return AchievementSystem
