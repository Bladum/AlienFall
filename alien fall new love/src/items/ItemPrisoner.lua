--- ItemPrisoner.lua
-- Prisoner items for Alien Fall
-- Captured units, interrogation equipment, and containment systems

-- GROK: ItemPrisoner handles captured aliens, interrogation tools, and containment systems
-- GROK: Used by organization_system for prisoner management and interrogation mechanics
-- GROK: Key methods: calculateInterrogationSuccess(), calculateEscapeRisk(), meetsFacilityRequirements()
-- GROK: Manages prisoner stats, equipment effectiveness, and interrogation probabilities

local class = require 'lib.Middleclass'
local Item = require 'items.Item'

ItemPrisoner = class('ItemPrisoner', Item)

--- Initialize a new prisoner item
-- @param data The TOML data for this item
function ItemPrisoner:initialize(data)
    -- Initialize parent class
    Item.initialize(self, data)

    -- Set category
    self.category = Item.CATEGORY_PRISONER

    -- Prisoner-specific properties
    self.prisoner_type = data.prisoner_type or "unknown"
    self.intelligence_value = data.intelligence_value or 0
    self.escape_risk = data.escape_risk or 0
    self.cooperation_potential = data.cooperation_potential or 0
    self.interrogation_difficulty = data.interrogation_difficulty or "medium"

    -- Equipment properties (for interrogation/containment equipment)
    self.effectiveness = data.effectiveness or 0
    self.duration = data.duration or 0
    self.uses_remaining = data.uses_remaining or data.uses or 0

    -- Requirements
    self.facility_requirements = data.facility_requirements or {}
    self.research_requirements = data.research_requirements or {}

    -- Validate data
    self:_validate()
end

--- Validate the prisoner item data
function ItemPrisoner:_validate()
    -- Parent validation is handled by Item.initialize()
    assert(self.prisoner_type, "Prisoner item must have a prisoner_type")
end

--- Get a specific stat value
-- @param stat The stat name
-- @return The stat value or nil if not defined
function ItemPrisoner:getStat(stat)
    return self.stats[stat]
end

--- Get all stats
-- @return Table of all stats
function ItemPrisoner:getStats()
    return self.stats
end

--- Get the facility requirements for this item
-- @return Array of required facility IDs
function ItemPrisoner:getFacilityRequirements()
    return self.facility_requirements
end

--- Get the research requirements for this item
-- @return Array of required research IDs
function ItemPrisoner:getResearchRequirements()
    return self.research_requirements
end

--- Check if the player has the required facilities for this item
-- @param availableFacilities Table of available facilities {facility_id = true}
-- @return true if requirements are met
function ItemPrisoner:meetsFacilityRequirements(availableFacilities)
    local required = self:getFacilityRequirements()
    for _, facilityId in ipairs(required) do
        if not availableFacilities[facilityId] then
            return false
        end
    end
    return true
end

--- Check if the player has the required research for this item
-- @param availableResearch Table of completed research {research_id = true}
-- @return true if requirements are met
function ItemPrisoner:meetsResearchRequirements(availableResearch)
    local required = self:getResearchRequirements()
    for _, researchId in ipairs(required) do
        if not availableResearch[researchId] then
            return false
        end
    end
    return true
end

--- Get the short description
-- @return Short description string
function ItemPrisoner:getShortDescription()
    return self.description.short or self.name
end

--- Get the long description
-- @return Long description string
function ItemPrisoner:getLongDescription()
    return self.description.long or self:getShortDescription()
end

--- Check if this is a prisoner (captured unit)
-- @return true if this item is a prisoner
function ItemPrisoner:isPrisoner()
    return self.prisoner_type == "prisoner"
end

--- Check if this is interrogation equipment
-- @return true if this item is interrogation equipment
function ItemPrisoner:isInterrogationEquipment()
    return self.prisoner_type == "interrogation_equipment"
end

--- Check if this is containment equipment
-- @return true if this item is containment equipment
function ItemPrisoner:isContainmentEquipment()
    return self.prisoner_type == "containment_equipment"
end

--- Check if this is a capture consumable
-- @return true if this item is a capture consumable
function ItemPrisoner:isCaptureConsumable()
    return self.prisoner_type == "capture_consumable"
end

--- Get the interrogation difficulty (for prisoners)
-- @return Difficulty level or nil if not applicable
function ItemPrisoner:getInterrogationDifficulty()
    return self.interrogation_difficulty
end

--- Get the intelligence value (for prisoners)
-- @return Intelligence value or 0 if not applicable
function ItemPrisoner:getIntelligenceValue()
    return self.intelligence_value
end

--- Get the escape risk (for prisoners)
-- @return Escape risk percentage or 0 if not applicable
function ItemPrisoner:getEscapeRisk()
    return self.escape_risk
end

--- Get the cooperation potential (for prisoners)
-- @return Cooperation potential percentage or 0 if not applicable
function ItemPrisoner:getCooperationPotential()
    return self.cooperation_potential
end

--- Get the effectiveness value (for equipment)
-- @return Effectiveness percentage or 0 if not applicable
function ItemPrisoner:getEffectiveness()
    return self.effectiveness
end

--- Get the duration (for equipment/consumables)
-- @return Duration in hours or 0 if not applicable
function ItemPrisoner:getDuration()
    return self.duration
end

--- Get the stun duration (for capture consumables)
-- @return Stun duration in turns or 0 if not applicable
function ItemPrisoner:getStunDuration()
    return self.stats.stun_duration or 0
end

--- Get the number of uses remaining (for consumables)
-- @return Number of uses or 0 if not applicable
function ItemPrisoner:getUsesRemaining()
    return self.uses_remaining
end

--- Calculate interrogation success chance
-- @param interrogatorSkill The interrogator's skill level
-- @param equipmentBonus Bonus from interrogation equipment
-- @return Success chance as percentage
function ItemPrisoner:calculateInterrogationSuccess(interrogatorSkill, equipmentBonus)
    if not self:isPrisoner() then return 0 end

    local difficulty = self:getInterrogationDifficulty()
    local difficultyModifier = 0

    if difficulty == "easy" then
        difficultyModifier = 20
    elseif difficulty == "medium" then
        difficultyModifier = 0
    elseif difficulty == "hard" then
        difficultyModifier = -20
    elseif difficulty == "extreme" then
        difficultyModifier = -40
    end

    local baseChance = 50 + interrogatorSkill + equipmentBonus + difficultyModifier
    return math.max(5, math.min(95, baseChance))  -- Clamp between 5% and 95%
end

--- Calculate escape risk
-- @param containmentLevel Quality of containment facilities
-- @param guardEfficiency Effectiveness of guards
-- @return Escape chance as percentage
function ItemPrisoner:calculateEscapeRisk(containmentLevel, guardEfficiency)
    if not self:isPrisoner() then return 0 end

    local baseRisk = self:getEscapeRisk()
    local riskModifier = containmentLevel + guardEfficiency
    return math.max(0, baseRisk - riskModifier)
end

--- Get a formatted display string for UI
-- @return String for display in prisoner management screens
function ItemPrisoner:getDisplayString()
    local display = string.format("%s (%s)", self.name, self.category)

    if self:isPrisoner() then
        local intel = self:getIntelligenceValue()
        if intel > 0 then
            display = display .. string.format(" - Intel: %d", intel)
        end
    elseif self:isInterrogationEquipment() then
        local effectiveness = self:getEffectiveness()
        if effectiveness > 0 then
            display = display .. string.format(" - +%d%% effectiveness", effectiveness)
        end
    end

    return display
end

--- Convert to string representation
-- @return String representation
function ItemPrisoner:__tostring()
    return string.format("ItemPrisoner{id='%s', name='%s', prisoner_type='%s'}",
                        self.id, self.name, self.prisoner_type)
end

--- Get item data for serialization (override parent)
-- @return table Item data
function ItemPrisoner:getData()
    local data = Item.getData(self)

    -- Add prisoner-specific data
    data.prisoner_type = self.prisoner_type
    data.intelligence_value = self.intelligence_value
    data.escape_risk = self.escape_risk
    data.cooperation_potential = self.cooperation_potential
    data.interrogation_difficulty = self.interrogation_difficulty
    data.effectiveness = self.effectiveness
    data.duration = self.duration
    data.uses_remaining = self.uses_remaining
    data.facility_requirements = self.facility_requirements
    data.research_requirements = self.research_requirements

    return data
end

return ItemPrisoner
