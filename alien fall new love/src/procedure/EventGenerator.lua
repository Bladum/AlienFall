--- Event Generator
-- Generates procedural events and encounters during missions
--
-- @module procedure.EventGenerator

local class = require 'lib.Middleclass'

--- Event Generator
-- @type EventGenerator
EventGenerator = class('EventGenerator')

--- Event templates
EventGenerator.EVENT_TEMPLATES = {
    enemy_reinforcements = {
        name = 'Enemy Reinforcements',
        description = 'Additional enemy forces have arrived on the battlefield.',
        type = 'combat',
        triggers = { 'turn', 'objective_complete' },
        effects = { 'spawn_units' }
    },
    environmental_hazard = {
        name = 'Environmental Hazard',
        description = 'A dangerous environmental effect threatens the area.',
        type = 'environmental',
        triggers = { 'turn', 'random' },
        effects = { 'damage_area', 'create_hazard' }
    },
    enemy_ambush = {
        name = 'Enemy Ambush',
        description = 'Enemy forces were waiting in ambush!',
        type = 'combat',
        triggers = { 'movement', 'random' },
        effects = { 'spawn_units', 'surprise_attack' }
    },
    boss_encounter = {
        name = 'Boss Encounter',
        description = 'A powerful enemy commander has entered the battlefield.',
        type = 'combat',
        triggers = { 'objective_progress', 'turn' },
        effects = { 'spawn_boss', 'increase_difficulty' }
    },
    scientific_discovery = {
        name = 'Scientific Discovery',
        description = 'Valuable research data has been uncovered.',
        type = 'exploration',
        triggers = { 'area_scan', 'objective_complete' },
        effects = { 'grant_research', 'spawn_bonus' }
    },
    civilian_rescue = {
        name = 'Civilian Rescue',
        description = 'Surviving civilians need immediate evacuation.',
        type = 'rescue',
        triggers = { 'area_clear', 'random' },
        effects = { 'spawn_civilians', 'time_bonus' }
    },
    equipment_cache = {
        name = 'Equipment Cache',
        description = 'An abandoned equipment cache has been discovered.',
        type = 'exploration',
        triggers = { 'area_search', 'random' },
        effects = { 'spawn_items', 'grant_supplies' }
    },
    alien_technology = {
        name = 'Alien Technology',
        description = 'Advanced alien technology has been detected.',
        type = 'exploration',
        triggers = { 'scan_complete', 'random' },
        effects = { 'spawn_artifact', 'research_bonus' }
    }
}

--- Initialize event generator
-- @param rng Random number generator
function EventGenerator:initialize(rng)
    self.rng = rng
    self.activeEvents = {}
end

--- Generate events for a mission
-- @param triggers Array of event trigger strings
-- @return Array of generated events
function EventGenerator:generateEvents(triggers)
    local events = {}

    for _, trigger in ipairs(triggers) do
        if self.rng:random() < self:getTriggerChance(trigger) then
            local event = self:generateEvent(trigger)
            if event then
                table.insert(events, event)
            end
        end
    end

    return events
end

--- Generate encounter events
-- @param context Encounter context
-- @return Array of encounter events
function EventGenerator:generateEncounterEvents(context)
    local events = {}
    local numEvents = self.rng:random(0, 2)

    for i = 1, numEvents do
        local eventType = self:selectRandomEventType()
        local event = self:generateEvent(eventType)
        if event then
            table.insert(events, event)
        end
    end

    return events
end

--- Generate a single event
-- @param triggerOrType Event trigger or type
-- @return Generated event data
function EventGenerator:generateEvent(triggerOrType)
    local eventType

    if self.EVENT_TEMPLATES[triggerOrType] then
        eventType = triggerOrType
    else
        -- Find event types that can be triggered by this trigger
        local possibleTypes = {}
        for typeName, template in pairs(self.EVENT_TEMPLATES) do
            if self:tableContains(template.triggers, triggerOrType) then
                table.insert(possibleTypes, typeName)
            end
        end

        if #possibleTypes > 0 then
            eventType = possibleTypes[self.rng:random(#possibleTypes)]
        else
            return nil -- No suitable event type found
        end
    end

    local template = self.EVENT_TEMPLATES[eventType]
    local event = {
        id = self:generateEventId(),
        type = eventType,
        name = template.name,
        description = template.description,
        trigger = triggerOrType,
        effects = self:generateEventEffects(template.effects),
        conditions = self:generateEventConditions(eventType),
        duration = self:generateEventDuration(eventType)
    }

    return event
end

--- Generate event effects
-- @param effectTypes Array of effect type strings
-- @return Array of effect data
function EventGenerator:generateEventEffects(effectTypes)
    local effects = {}

    for _, effectType in ipairs(effectTypes) do
        local effect = self:generateEffect(effectType)
        if effect then
            table.insert(effects, effect)
        end
    end

    return effects
end

--- Generate a single effect
-- @param effectType Type of effect
-- @return Effect data
function EventGenerator:generateEffect(effectType)
    if effectType == 'spawn_units' then
        return {
            type = 'spawn_units',
            count = self.rng:random(2, 5),
            unitTypes = { 'sectoid', 'muton', 'floater' },
            location = 'random_edge'
        }
    elseif effectType == 'spawn_boss' then
        return {
            type = 'spawn_boss',
            unitType = 'ethereal',
            location = 'center'
        }
    elseif effectType == 'damage_area' then
        return {
            type = 'damage_area',
            radius = self.rng:random(3, 6),
            damage = self.rng:random(10, 30),
            location = 'random'
        }
    elseif effectType == 'create_hazard' then
        local hazardTypes = { 'fire', 'toxic', 'radiation' }
        return {
            type = 'create_hazard',
            hazardType = hazardTypes[self.rng:random(#hazardTypes)],
            radius = self.rng:random(2, 4),
            duration = self.rng:random(3, 8),
            location = 'random'
        }
    elseif effectType == 'surprise_attack' then
        return {
            type = 'surprise_attack',
            damageMultiplier = 1.5,
            accuracyBonus = 20
        }
    elseif effectType == 'grant_research' then
        return {
            type = 'grant_research',
            points = self.rng:random(50, 150)
        }
    elseif effectType == 'spawn_civilians' then
        return {
            type = 'spawn_civilians',
            count = self.rng:random(1, 3),
            location = 'random'
        }
    elseif effectType == 'time_bonus' then
        return {
            type = 'time_bonus',
            turns = self.rng:random(2, 5)
        }
    elseif effectType == 'spawn_items' then
        return {
            type = 'spawn_items',
            count = self.rng:random(1, 3),
            itemTypes = { 'weapon', 'armor', 'grenade' },
            location = 'random'
        }
    elseif effectType == 'grant_supplies' then
        return {
            type = 'grant_supplies',
            supplies = self.rng:random(20, 50)
        }
    elseif effectType == 'spawn_artifact' then
        return {
            type = 'spawn_artifact',
            tier = self.rng:random(2, 4),
            location = 'random'
        }
    elseif effectType == 'research_bonus' then
        return {
            type = 'research_bonus',
            multiplier = 1.25,
            duration = self.rng:random(5, 10)
        }
    elseif effectType == 'increase_difficulty' then
        return {
            type = 'increase_difficulty',
            enemyStrengthBonus = 0.2,
            enemyCountBonus = 2
        }
    end

    return nil
end

--- Generate event conditions
-- @param eventType Type of event
-- @return Array of condition data
function EventGenerator:generateEventConditions(eventType)
    local conditions = {}

    -- Add random conditions based on event type
    if eventType == 'enemy_reinforcements' then
        table.insert(conditions, {
            type = 'turn_threshold',
            value = self.rng:random(5, 15)
        })
    elseif eventType == 'boss_encounter' then
        table.insert(conditions, {
            type = 'objective_progress',
            value = 0.5 + self.rng:random() * 0.3
        })
    elseif eventType == 'scientific_discovery' then
        table.insert(conditions, {
            type = 'area_scanned',
            value = true
        })
    end

    return conditions
end

--- Generate event duration
-- @param eventType Type of event
-- @return Duration in turns (0 = instant)
function EventGenerator:generateEventDuration(eventType)
    local durationRanges = {
        environmental_hazard = { 3, 8 },
        equipment_cache = { 0, 0 }, -- instant
        alien_technology = { 0, 0 }, -- instant
        default = { 1, 5 }
    }

    local range = durationRanges[eventType] or durationRanges.default
    return self.rng:random(range[1], range[2])
end

--- Get trigger chance
-- @param trigger Trigger type
-- @return Chance (0-1)
function EventGenerator:getTriggerChance(trigger)
    local chances = {
        enemy_reinforcements = 0.3,
        environmental_hazard = 0.2,
        enemy_ambush = 0.25,
        boss_encounter = 0.15,
        scientific_discovery = 0.4,
        civilian_rescue = 0.2,
        equipment_cache = 0.3,
        alien_technology = 0.1
    }

    return chances[trigger] or 0.2
end

--- Select random event type
-- @return Random event type
function EventGenerator:selectRandomEventType()
    local types = {}
    for typeName in pairs(self.EVENT_TEMPLATES) do
        table.insert(types, typeName)
    end
    return types[self.rng:random(#types)]
end

--- Generate unique event ID
-- @return Event ID string
function EventGenerator:generateEventId()
    return string.format("event_%d_%d", self.rng:random(10000, 99999), os.time())
end

--- Check if event can trigger
-- @param event Event data
-- @param context Current game context
-- @return Boolean indicating if event can trigger
function EventGenerator:canTriggerEvent(event, context)
    for _, condition in ipairs(event.conditions) do
        if not self:checkCondition(condition, context) then
            return false
        end
    end
    return true
end

--- Check if condition is met
-- @param condition Condition data
-- @param context Current game context
-- @return Boolean indicating if condition is met
function EventGenerator:checkCondition(condition, context)
    if condition.type == 'turn_threshold' then
        return (context.turn or 0) >= condition.value
    elseif condition.type == 'objective_progress' then
        return (context.objectiveProgress or 0) >= condition.value
    elseif condition.type == 'area_scanned' then
        return context.areaScanned or false
    end

    return true -- Default to true for unknown conditions
end

--- Execute event effects
-- @param event Event data
-- @param context Current game context
function EventGenerator:executeEvent(event, context)
    for _, effect in ipairs(event.effects) do
        self:executeEffect(effect, context)
    end
end

--- Execute a single effect
-- @param effect Effect data
-- @param context Current game context
function EventGenerator:executeEffect(effect, context)
    -- This would integrate with the game systems to actually apply effects
    -- For now, just log the effect
    print(string.format("Executing event effect: %s", effect.type))

    if effect.type == 'spawn_units' then
        -- Would spawn units in the game world
        print(string.format("Spawning %d units of types: %s", effect.count,
            table.concat(effect.unitTypes, ', ')))
    elseif effect.type == 'damage_area' then
        -- Would damage units in the area
        print(string.format("Damaging area with radius %d for %d damage", effect.radius, effect.damage))
    elseif effect.type == 'grant_research' then
        -- Would add research points
        print(string.format("Granting %d research points", effect.points))
    end
end

--- Utility function to check if table contains value
-- @param table Table to search
-- @param value Value to find
-- @return Boolean indicating if found
function EventGenerator:tableContains(table, value)
    for _, v in ipairs(table) do
        if v == value then
            return true
        end
    end
    return false
end

return EventGenerator