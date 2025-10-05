--- Medal.lua
-- Unit medal system for Alien Fall
-- Defines achievements and decorations that units can earn

-- GROK: Medal represents achievement awards with requirements, bonuses, and unlocks
-- GROK: Used by unit_system for soldier progression and achievement tracking
-- GROK: Key methods: meetsRequirements(), awardToUnit(), getStatBonuses()
-- GROK: Handles medal categories, rarities, and unit stat modifications

local class = require 'lib.Middleclass'

Medal = class('Medal')

--- Initialize a new medal
-- @param data The TOML data for this medal
function Medal:initialize(data)
    self.id = data.id
    self.name = data.name
    self.description = data.description or ""

    -- Medal category
    self.category = data.category or "achievement"

    -- Rarity level
    self.rarity = data.rarity or "common"

    -- Visual appearance
    self.icon = data.icon or "default_medal"
    self.color = data.color or {255, 215, 0}  -- Gold by default

    -- Requirements
    self.requirements = data.requirements or {}

    -- Effects
    self.effects = data.effects or {}

    -- Unlocks
    self.unlocks = data.unlocks or {}

    -- Validate data
    self:_validate()
end

--- Validate the medal data
function Medal:_validate()
    assert(self.id, "Medal must have an id")
    assert(self.name, "Medal must have a name")

    -- Validate category
    local validCategories = {
        achievement = true, combat = true, service = true, special = true,
        campaign = true, valor = true, merit = true, distinguished = true
    }
    assert(validCategories[self.category], "Invalid medal category: " .. tostring(self.category))

    -- Validate rarity
    local validRarities = {
        common = true, uncommon = true, rare = true, epic = true, legendary = true
    }
    assert(validRarities[self.rarity], "Invalid medal rarity: " .. tostring(self.rarity))
end

--- Get the medal category
-- @return Category string
function Medal:getCategory()
    return self.category
end

--- Get the medal rarity
-- @return Rarity string
function Medal:getRarity()
    return self.rarity
end

--- Check if this is a combat medal
-- @return true if combat medal
function Medal:isCombatMedal()
    return self.category == "combat" or self.category == "valor"
end

--- Check if this is an achievement medal
-- @return true if achievement medal
function Medal:isAchievementMedal()
    return self.category == "achievement" or self.category == "merit"
end

--- Check if this is a service medal
-- @return true if service medal
function Medal:isServiceMedal()
    return self.category == "service" or self.category == "distinguished"
end

--- Get the medal icon
-- @return Icon filename or identifier
function Medal:getIcon()
    return self.icon
end

--- Get the medal color (RGB)
-- @return RGB color table {r, g, b}
function Medal:getColor()
    return self.color
end

--- Get requirements
-- @return Table of requirements {requirement_type = value}
function Medal:getRequirements()
    return self.requirements
end

--- Get kill requirements
-- @return Required number of kills
function Medal:getKillRequirement()
    return self.requirements.kills or 0
end

--- Get mission requirements
-- @return Required number of missions
function Medal:getMissionRequirement()
    return self.requirements.missions or 0
end

--- Get accuracy requirements
-- @return Required accuracy percentage
function Medal:getAccuracyRequirement()
    return self.requirements.accuracy_percentage or 0
end

--- Get survival requirements
-- @return Required number of missions survived
function Medal:getSurvivalRequirement()
    return self.requirements.survived_missions or 0
end

--- Get rank requirements
-- @return Required rank
function Medal:getRankRequirement()
    return self.requirements.rank or ""
end

--- Get effects
-- @return Table of effects {effect_type = value}
function Medal:getEffects()
    return self.effects
end

--- Get stat bonuses
-- @return Table of stat bonuses {stat_name = bonus_value}
function Medal:getStatBonuses()
    return self.effects.stat_bonuses or {}
end

--- Get ability unlocks
-- @return Array of unlocked ability IDs
function Medal:getAbilityUnlocks()
    return self.effects.ability_unlocks or {}
end

--- Get unlocks
-- @return Table of unlocks {unlock_type = value}
function Medal:getUnlocks()
    return self.unlocks
end

--- Get equipment unlocks
-- @return Array of unlocked equipment IDs
function Medal:getEquipmentUnlocks()
    return self.unlocks.equipment or {}
end

--- Get facility unlocks
-- @return Array of unlocked facility IDs
function Medal:getFacilityUnlocks()
    return self.unlocks.facilities or {}
end

--- Check if a unit meets the requirements for this medal
-- @param unitStats Table of unit statistics
-- @return true if requirements met
function Medal:meetsRequirements(unitStats)
    -- Check kill requirement
    local requiredKills = self:getKillRequirement()
    if requiredKills > 0 and (unitStats.kills or 0) < requiredKills then
        return false
    end

    -- Check mission requirement
    local requiredMissions = self:getMissionRequirement()
    if requiredMissions > 0 and (unitStats.missions_completed or 0) < requiredMissions then
        return false
    end

    -- Check accuracy requirement
    local requiredAccuracy = self:getAccuracyRequirement()
    if requiredAccuracy > 0 and (unitStats.accuracy_percentage or 0) < requiredAccuracy then
        return false
    end

    -- Check survival requirement
    local requiredSurvival = self:getSurvivalRequirement()
    if requiredSurvival > 0 and (unitStats.missions_survived or 0) < requiredSurvival then
        return false
    end

    -- Check rank requirement
    local requiredRank = self:getRankRequirement()
    if requiredRank ~= "" and unitStats.rank ~= requiredRank then
        return false
    end

    -- Check other requirements
    for reqType, reqValue in pairs(self.requirements) do
        if reqType ~= "kills" and reqType ~= "missions" and reqType ~= "accuracy_percentage"
           and reqType ~= "survived_missions" and reqType ~= "rank" then
            local unitValue = unitStats[reqType] or 0
            if type(reqValue) == "number" and unitValue < reqValue then
                return false
            elseif type(reqValue) == "string" and unitValue ~= reqValue then
                return false
            end
        end
    end

    return true
end

--- Award this medal to a unit
-- @param unit The unit receiving the medal
function Medal:awardToUnit(unit)
    -- Add medal to unit's collection
    unit.medals = unit.medals or {}
    table.insert(unit.medals, {
        id = self.id,
        awarded_date = os.date("%Y-%m-%d"),
        category = self.category,
        rarity = self.rarity
    })

    -- Apply stat bonuses
    local bonuses = self:getStatBonuses()
    for stat, bonus in pairs(bonuses) do
        unit[stat] = (unit[stat] or 0) + bonus
    end

    -- Unlock abilities
    local abilities = self:getAbilityUnlocks()
    for _, abilityId in ipairs(abilities) do
        unit:addAbility(abilityId)
    end

    -- Record in unit history
    unit.achievements = unit.achievements or {}
    table.insert(unit.achievements, {
        type = "medal_awarded",
        medal_id = self.id,
        date = os.date("%Y-%m-%d")
    })
end

--- Check if a unit has this medal
-- @param unit The unit to check
-- @return true if unit has this medal
function Medal:unitHasMedal(unit)
    if not unit.medals then return false end

    for _, medal in ipairs(unit.medals) do
        if medal.id == self.id then
            return true
        end
    end
    return false
end

--- Get the medal value (for scoring/ranking)
-- @return Numerical value based on rarity and category
function Medal:getValue()
    local rarityValues = {
        common = 1,
        uncommon = 2,
        rare = 5,
        epic = 10,
        legendary = 25
    }

    local categoryMultipliers = {
        achievement = 1.0,
        combat = 1.5,
        service = 1.2,
        special = 2.0,
        campaign = 1.8,
        valor = 2.5,
        merit = 1.3,
        distinguished = 2.2
    }

    return rarityValues[self.rarity] * categoryMultipliers[self.category]
end

--- Get a human-readable description of the medal
-- @return String description
function Medal:getDescription()
    local desc = self.name
    if self.description and self.description ~= "" then
        desc = desc .. " - " .. self.description
    end

    desc = desc .. string.format(" (%s %s)", self.rarity, self.category)

    local bonuses = self:getStatBonuses()
    local bonusStrings = {}
    for stat, bonus in pairs(bonuses) do
        table.insert(bonusStrings, string.format("%s %+d", stat, bonus))
    end

    if #bonusStrings > 0 then
        desc = desc .. " - Bonuses: " .. table.concat(bonusStrings, ", ")
    end

    return desc
end

--- Convert to string representation
-- @return String representation
function Medal:__tostring()
    return string.format("Medal{id='%s', name='%s', rarity='%s', category='%s'}",
                        self.id, self.name, self.rarity, self.category)
end

return Medal
