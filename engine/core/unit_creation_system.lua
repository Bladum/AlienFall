---@class UnitCreationSystem
---@field traitSystem TraitSystem
---@field traitValidator TraitValidator
local UnitCreationSystem = {}

--- Unit class definitions with base stats
local UNIT_CLASSES = {
    soldier = {
        name = "Soldier",
        baseStats = {
            aim = 65,
            melee = 60,
            reaction = 55,
            speed = 50,
            bravery = 60,
            sanity = 50,
            strength = 45,
            health = 100
        },
        description = "Versatile frontline combat unit"
    },
    heavy = {
        name = "Heavy",
        baseStats = {
            aim = 55,
            melee = 50,
            reaction = 45,
            speed = 35,
            bravery = 70,
            sanity = 55,
            strength = 70,
            health = 120
        },
        description = "High strength, heavy weapons specialist"
    },
    sniper = {
        name = "Sniper",
        baseStats = {
            aim = 85,
            melee = 40,
            reaction = 60,
            speed = 45,
            bravery = 50,
            sanity = 45,
            strength = 40,
            health = 90
        },
        description = "Precision ranged combat specialist"
    },
    scout = {
        name = "Scout",
        baseStats = {
            aim = 60,
            melee = 45,
            reaction = 70,
            speed = 65,
            bravery = 55,
            sanity = 60,
            strength = 35,
            health = 85
        },
        description = "Fast reconnaissance and stealth specialist"
    },
    engineer = {
        name = "Engineer",
        baseStats = {
            aim = 50,
            melee = 35,
            reaction = 50,
            speed = 50,
            bravery = 65,
            sanity = 70,
            strength = 50,
            health = 95
        },
        description = "Technical and repair specialist"
    },
    medic = {
        name = "Medic",
        baseStats = {
            aim = 45,
            melee = 30,
            reaction = 55,
            speed = 55,
            bravery = 75,
            sanity = 75,
            strength = 35,
            health = 90
        },
        description = "Medical and support specialist"
    }
}

--- Initialize unit creation system
function UnitCreationSystem:init()
    self.traitSystem = require("utils.traits")
    self.traitValidator = require("utils.trait_validator")

    self.traitSystem:init()
    self.traitValidator:init(self.traitSystem)
end

--- Create a new unit with birth traits
---@param options table Creation options
---@return table|nil unit The created unit or nil on failure
---@return string|nil error Error message if creation failed
function UnitCreationSystem:createUnit(options)
    options = options or {}

    -- Validate required options
    if not options.class then
        return nil, "Unit class is required"
    end

    if not UNIT_CLASSES[options.class] then
        return nil, "Invalid unit class: " .. tostring(options.class)
    end

    -- Set defaults
    local unitId = options.id or self:generateUnitId()
    local unitName = options.name or self:generateUnitName(options.class)
    local unitClass = options.class
    local unitRank = options.rank or 0  -- Recruit rank

    -- Get base stats for class
    local baseStats = self:copyStats(UNIT_CLASSES[unitClass].baseStats)

    -- Create base unit structure
    local unit = {
        id = unitId,
        name = unitName,
        class = unitClass,
        rank = unitRank,
        xp = options.xp or 0,
        health = baseStats.health,
        maxHealth = baseStats.health,
        stats = baseStats,
        traits = {},
        trait_bonuses = {},
        synergy_bonuses = {},
        inventory = {},
        skills = {},
        armor = nil,
        weapon = nil,
        status = "active",
        created_at = os.time()
    }

    -- Generate birth traits
    local birthTraits = self:generateBirthTraits(unit)
    if not birthTraits then
        return nil, "Failed to generate birth traits"
    end

    -- Assign traits to unit
    unit.traits = birthTraits

    -- Apply trait effects
    for _, trait in ipairs(birthTraits) do
        self.traitSystem:applyTraitEffects(unit, trait.id)
    end

    -- Calculate synergies
    self.traitSystem:applySynergyBonuses(unit)

    -- Validate final unit
    local valid, error = self.traitValidator:validateUnitTraits(unit)
    if not valid then
        return nil, "Unit validation failed: " .. error
    end

    return unit
end

--- Generate birth traits for a unit
---@param unit table The unit being created
---@return table|nil traits Array of trait objects or nil on failure
function UnitCreationSystem:generateBirthTraits(unit)
    local maxAttempts = 10
    local attempt = 1

    while attempt <= maxAttempts do
        local traits = {}

        -- Determine number of trait slots (always 2 for recruits)
        local traitSlots = 2

        -- Generate traits for each slot
        for slot = 1, traitSlots do
            local trait = self:generateSingleBirthTrait(unit.class)
            if trait then
                table.insert(traits, trait)
            end
        end

        -- Validate trait combination
        local valid, error = self.traitValidator:validateBirthTraits(traits, unit.class)
        if valid then
            return traits
        end

        attempt = attempt + 1
    end

    return nil, "Failed to generate valid birth traits after " .. maxAttempts .. " attempts"
end

--- Generate a single birth trait
---@param unitClass string The unit's class
---@return table|nil trait Trait object or nil
function UnitCreationSystem:generateSingleBirthTrait(unitClass)
    -- Roll for trait type
    local roll = math.random(1, 100)

    local traitType
    if roll <= 30 then
        traitType = "positive"
    elseif roll <= 50 then
        traitType = "negative"
    else
        return nil  -- No trait in this slot
    end

    -- Get available traits of this type
    local availableTraits = self.traitSystem:getTraitsByType(traitType)

    -- Filter by acquisition method (birth only)
    local birthTraits = {}
    for id, trait in pairs(availableTraits) do
        if trait.acquisition == "birth" then
            table.insert(birthTraits, trait)
        end
    end

    if #birthTraits == 0 then
        return nil
    end

    -- Select random trait
    local selectedTrait = birthTraits[math.random(1, #birthTraits)]

    return {
        id = selectedTrait.id,
        acquired_at = "birth",
        slot = 0  -- Will be set when assigned to unit
    }
end

--- Generate a unique unit ID
---@return string unitId
function UnitCreationSystem:generateUnitId()
    return string.format("unit_%d_%s", os.time(), tostring(math.random(1000, 9999)))
end

--- Generate a unit name
---@param unitClass string The unit's class
---@return string unitName
function UnitCreationSystem:generateUnitName(unitClass)
    local firstNames = {
        "John", "Sarah", "Mike", "Emma", "David", "Lisa", "Chris", "Anna",
        "James", "Maria", "Robert", "Jennifer", "William", "Linda", "Richard", "Patricia",
        "Charles", "Barbara", "Daniel", "Elizabeth", "Matthew", "Susan", "Anthony", "Margaret"
    }

    local lastNames = {
        "Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis",
        "Rodriguez", "Martinez", "Hernandez", "Lopez", "Gonzalez", "Wilson", "Anderson", "Thomas",
        "Taylor", "Moore", "Jackson", "Martin", "Lee", "Perez", "Thompson", "White"
    }

    local firstName = firstNames[math.random(1, #firstNames)]
    local lastName = lastNames[math.random(1, #lastNames)]

    return string.format("%s %s", firstName, lastName)
end

--- Copy stats table
---@param stats table The stats to copy
---@return table copiedStats
function UnitCreationSystem:copyStats(stats)
    local copied = {}
    for k, v in pairs(stats) do
        copied[k] = v
    end
    return copied
end

--- Get unit class definition
---@param classId string The class ID
---@return table|nil classDef Class definition or nil
function UnitCreationSystem:getUnitClass(classId)
    return UNIT_CLASSES[classId]
end

--- Get all unit classes
---@return table classes Map of classId -> classDef
function UnitCreationSystem:getAllUnitClasses()
    return UNIT_CLASSES
end

--- Validate unit data integrity
---@param unit table The unit to validate
---@return boolean isValid
---@return string|nil error Error message if invalid
function UnitCreationSystem:validateUnit(unit)
    if not unit.id then return false, "Unit missing ID" end
    if not unit.name then return false, "Unit missing name" end
    if not unit.class then return false, "Unit missing class" end
    if not UNIT_CLASSES[unit.class] then return false, "Invalid unit class" end
    if not unit.stats then return false, "Unit missing stats" end
    if not unit.traits then unit.traits = {} end

    -- Validate traits
    local traitResult = self.traitValidator:validateUnitTraits(unit)
    return traitResult.valid, traitResult.error
end

--- Apply trait effects to existing unit (for trait changes)
---@param unit table The unit to update
function UnitCreationSystem:applyTraitEffects(unit)
    -- Reset trait bonuses
    unit.trait_bonuses = {}
    unit.synergy_bonuses = {}

    -- Apply each trait
    for _, trait in ipairs(unit.traits or {}) do
        self.traitSystem:applyTraitEffects(unit, trait.id)
    end

    -- Apply synergies
    self.traitSystem:applySynergyBonuses(unit)
end

--- Add trait to unit (achievement/perk)
---@param unit table The unit to modify
---@param traitId string The trait to add
---@return boolean success
---@return string|nil error Error message if failed
function UnitCreationSystem:addTraitToUnit(unit, traitId)
    -- Validate addition
    local result = self.traitValidator:validateTraitAddition(unit, traitId)
    if not result.valid then
        return false, result.error
    end

    -- Check if unit already has this trait
    if self.traitSystem:hasTrait(unit, traitId) then
        return false, "Unit already has this trait"
    end

    -- Add trait
    table.insert(unit.traits, {
        id = traitId,
        acquired_at = "achievement",  -- Could be "perk" for perks
        slot = #unit.traits + 1
    })

    -- Apply effects
    self.traitSystem:applyTraitEffects(unit, traitId)
    self.traitSystem:applySynergyBonuses(unit)

    return true
end

--- Remove trait from unit (respec)
---@param unit table The unit to modify
---@param traitId string The trait to remove
---@return boolean success
---@return string|nil error Error message if failed
function UnitCreationSystem:removeTraitFromUnit(unit, traitId)
    -- Validate removal
    local result = self.traitValidator:validateTraitRemoval(unit, traitId)
    if not result.valid then
        return false, result.error
    end

    -- Find and remove trait
    for i, trait in ipairs(unit.traits) do
        if trait.id == traitId then
            table.remove(unit.traits, i)

            -- Reapply all trait effects
            self:applyTraitEffects(unit)

            return true
        end
    end

    return false, "Trait not found on unit"
end

return UnitCreationSystem
