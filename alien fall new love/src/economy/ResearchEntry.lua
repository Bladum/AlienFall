--- ResearchEntry.lua
-- Research entry system for Alien Fall technology progression
-- Defines individual research projects with costs and prerequisites

-- GROK: ResearchEntry represents individual research projects in the technology tree
-- GROK: Manages prerequisites, costs, unlocks, and completion effects
-- GROK: Key methods: meetsPrerequisites(), calculateCost(), getUnlocks(), applyEffects()
-- GROK: Integrates with ResearchTree for dependency management and progression

local class = require 'lib.Middleclass'

ResearchEntry = class('ResearchEntry')

--- Initialize a new research entry
-- @param data The research entry data
function ResearchEntry:initialize(data)
    -- Basic research information
    self.id = data.id
    self.name = data.name or self.id
    self.description = data.description or ""

    -- Research properties
    self.category = data.category or "general"
    self.cost = data.cost or 100  -- Science points required
    self.baseTime = data.baseTime or 5  -- Days to complete (base estimate)

    -- Prerequisites and unlocks
    self.prerequisites = data.prerequisites or {}  -- Array of research IDs that must be completed first
    self.unlocks = data.unlocks or {}  -- Array of things this research unlocks

    -- Effects when completed
    self.effects = data.effects or {}

    -- Metadata
    self.isCompleted = data.isCompleted or false
    self.isStarted = data.isStarted or false
    self.progress = data.progress or 0  -- 0-100 percentage
    self.startTime = data.startTime  -- When research began
    self.completionTime = data.completionTime  -- When research completed

    -- Validation and requirements
    self.isValidated = data.isValidated or false

    -- Event integration
    self.eventBus = self:_getEventBus()

    -- Validate data
    self:_validate()
end

--- Get the event bus for integration
function ResearchEntry:_getEventBus()
    local registry = require 'services.registry'
    return registry:getService('eventBus')
end

--- Validate the research entry data
function ResearchEntry:_validate()
    assert(self.id, "Research entry must have an id")
    assert(self.name, "Research entry must have a name")
    assert(type(self.cost) == "number" and self.cost > 0, "Cost must be a positive number")
    assert(type(self.baseTime) == "number" and self.baseTime > 0, "Base time must be a positive number")

    -- Validate prerequisites
    assert(type(self.prerequisites) == "table", "Prerequisites must be a table")
    for i, prereq in ipairs(self.prerequisites) do
        assert(type(prereq) == "string", "Prerequisite " .. i .. " must be a string")
    end

    -- Validate unlocks
    assert(type(self.unlocks) == "table", "Unlocks must be a table")
    for i, unlock in ipairs(self.unlocks) do
        assert(type(unlock) == "table" and unlock.type, "Unlock " .. i .. " must be a table with a type")
    end
end

--- Check if this research entry meets all prerequisites
-- @param completedResearch A set/table of completed research IDs
function ResearchEntry:meetsPrerequisites(completedResearch)
    completedResearch = completedResearch or {}

    for _, prereqId in ipairs(self.prerequisites) do
        if not completedResearch[prereqId] then
            return false
        end
    end

    return true
end

--- Calculate the actual cost of this research
-- @param modifiers Cost modifiers (difficulty, organization bonuses, etc.)
function ResearchEntry:calculateCost(modifiers)
    modifiers = modifiers or {}

    local cost = self.cost

    -- Apply global modifiers
    if modifiers.globalMultiplier then
        cost = cost * modifiers.globalMultiplier
    end

    -- Apply category-specific modifiers
    if modifiers.categoryMultipliers and modifiers.categoryMultipliers[self.category] then
        cost = cost * modifiers.categoryMultipliers[self.category]
    end

    -- Apply difficulty modifiers
    if modifiers.difficultyMultiplier then
        cost = cost * modifiers.difficultyMultiplier
    end

    return math.floor(cost)
end

--- Calculate the time to complete this research
-- @param scientistCount Number of scientists assigned
-- @param labCount Number of labs available
-- @param modifiers Time modifiers
function ResearchEntry:calculateTime(scientistCount, labCount, modifiers)
    modifiers = modifiers or {}
    scientistCount = scientistCount or 1
    labCount = labCount or 1

    -- Base time calculation: cost / (scientists * lab efficiency)
    local labEfficiency = math.min(labCount, 3) * 0.8 + 0.4  -- Diminishing returns for labs
    local researchRate = scientistCount * labEfficiency

    local timeDays = self.cost / researchRate

    -- Apply modifiers
    if modifiers.timeMultiplier then
        timeDays = timeDays * modifiers.timeMultiplier
    end

    -- Apply category modifiers
    if modifiers.categoryTimeMultipliers and modifiers.categoryTimeMultipliers[self.category] then
        timeDays = timeDays * modifiers.categoryTimeMultipliers[self.category]
    end

    return math.max(1, math.floor(timeDays))
end

--- Get all unlocks provided by this research
function ResearchEntry:getUnlocks()
    return self.unlocks
end

--- Get unlocks of a specific type
-- @param unlockType The type of unlocks to filter (e.g., "technology", "item", "facility")
function ResearchEntry:getUnlocksByType(unlockType)
    local filtered = {}

    for _, unlock in ipairs(self.unlocks) do
        if unlock.type == unlockType then
            table.insert(filtered, unlock)
        end
    end

    return filtered
end

--- Apply the effects of completing this research
-- @param gameState The current game state
function ResearchEntry:applyEffects(gameState)
    if self.isCompleted then return end

    -- Mark as completed
    self.isCompleted = true
    self.completionTime = self:_getCurrentTime()
    self.progress = 100

    -- Apply effects
    for _, effect in ipairs(self.effects) do
        self:_applyEffect(effect, gameState)
    end

    -- Emit completion event
    self:_emitCompletionEvent()
end

--- Apply a single effect
-- @param effect The effect to apply
-- @param gameState The current game state
function ResearchEntry:_applyEffect(effect, gameState)
    local effectType = effect.type

    if effectType == "unlock_technology" then
        -- Unlock a technology for use
        self:_unlockTechnology(effect.technologyId, gameState)

    elseif effectType == "unlock_item" then
        -- Unlock an item for purchase/manufacture
        self:_unlockItem(effect.itemId, gameState)

    elseif effectType == "unlock_facility" then
        -- Unlock a facility for construction
        self:_unlockFacility(effect.facilityId, gameState)

    elseif effectType == "unlock_craft" then
        -- Unlock a craft type
        self:_unlockCraft(effect.craftId, gameState)

    elseif effectType == "unlock_unit" then
        -- Unlock a unit type
        self:_unlockUnit(effect.unitId, gameState)

    elseif effectType == "modify_stat" then
        -- Modify a global stat
        self:_modifyStat(effect.stat, effect.value, gameState)

    elseif effectType == "grant_knowledge" then
        -- Grant pedia knowledge
        self:_grantKnowledge(effect.knowledgeId, gameState)

    elseif effectType == "trigger_event" then
        -- Trigger a narrative event
        self:_triggerEvent(effect.eventId, gameState)

    elseif effectType == "modify_reputation" then
        -- Modify organization reputation
        self:_modifyReputation(effect.reputationType, effect.value, gameState)

    end
end

--- Unlock a technology
function ResearchEntry:_unlockTechnology(technologyId, gameState)
    -- This would integrate with the technology system
    if gameState.technologies then
        gameState.technologies[technologyId] = true
    end
end

--- Unlock an item
function ResearchEntry:_unlockItem(itemId, gameState)
    -- This would integrate with the item system
    if gameState.unlockedItems then
        gameState.unlockedItems[itemId] = true
    end
end

--- Unlock a facility
function ResearchEntry:_unlockFacility(facilityId, gameState)
    -- This would integrate with the facility system
    if gameState.unlockedFacilities then
        gameState.unlockedFacilities[facilityId] = true
    end
end

--- Unlock a craft
function ResearchEntry:_unlockCraft(craftId, gameState)
    -- This would integrate with the craft system
    if gameState.unlockedCrafts then
        gameState.unlockedCrafts[craftId] = true
    end
end

--- Unlock a unit
function ResearchEntry:_unlockUnit(unitId, gameState)
    -- This would integrate with the unit system
    if gameState.unlockedUnits then
        gameState.unlockedUnits[unitId] = true
    end
end

--- Modify a global stat
function ResearchEntry:_modifyStat(stat, value, gameState)
    -- This would integrate with the stats system
    if gameState.stats then
        gameState.stats[stat] = (gameState.stats[stat] or 0) + value
    end
end

--- Grant pedia knowledge
function ResearchEntry:_grantKnowledge(knowledgeId, gameState)
    -- This would integrate with the pedia system
    if gameState.pedia then
        gameState.pedia:unlockEntry(knowledgeId)
    end
end

--- Trigger a narrative event
function ResearchEntry:_triggerEvent(eventId, gameState)
    -- This would integrate with the event system
    if gameState.eventSystem then
        gameState.eventSystem:triggerEvent(eventId)
    end
end

--- Modify organization reputation
function ResearchEntry:_modifyReputation(reputationType, value, gameState)
    -- This would integrate with the organization system
    if gameState.organization then
        if reputationType == "fame" then
            gameState.organization:modifyFame(value)
        elseif reputationType == "karma" then
            gameState.organization:modifyKarma(value)
        elseif reputationType == "score" then
            gameState.organization:modifyScore(value)
        end
    end
end

--- Start this research project
-- @param startTime The time when research started
function ResearchEntry:startResearch(startTime)
    if self.isStarted then return false end

    self.isStarted = true
    self.startTime = startTime or self:_getCurrentTime()
    self.progress = 0

    -- Emit research started event
    self:_emitStartEvent()

    return true
end

--- Update research progress
-- @param currentTime The current time
-- @param scientistCount Number of scientists assigned
-- @param labCount Number of labs available
function ResearchEntry:updateProgress(currentTime, scientistCount, labCount)
    if not self.isStarted or self.isCompleted then return end

    local elapsed = currentTime - self.startTime
    local totalTime = self:calculateTime(scientistCount, labCount)

    self.progress = math.min(100, math.floor((elapsed / totalTime) * 100))

    -- Check if completed
    if self.progress >= 100 then
        self:completeResearch()
    end
end

--- Complete this research project
function ResearchEntry:completeResearch()
    if self.isCompleted then return end

    self.isCompleted = true
    self.completionTime = self:_getCurrentTime()
    self.progress = 100

    -- Apply effects
    self:applyEffects({})  -- Empty gameState for now

    -- Emit completion event (already done in applyEffects)
end

--- Cancel this research project
function ResearchEntry:cancelResearch()
    if not self.isStarted or self.isCompleted then return false end

    self.isStarted = false
    self.progress = 0
    self.startTime = nil

    -- Emit cancellation event
    self:_emitCancellationEvent()

    return true
end

--- Get current time (days elapsed)
function ResearchEntry:_getCurrentTime()
    local timeSystem = self:_getTimeSystem()
    return timeSystem and timeSystem:getDaysElapsed() or 0
end

--- Get the time system
function ResearchEntry:_getTimeSystem()
    local registry = require 'services.registry'
    return registry:getService('timeSystem')
end

--- Emit research started event
function ResearchEntry:_emitStartEvent()
    if self.eventBus then
        self.eventBus:emit("research:started", {
            researchId = self.id,
            researchName = self.name,
            category = self.category,
            cost = self.cost
        })
    end
end

--- Emit research completion event
function ResearchEntry:_emitCompletionEvent()
    if self.eventBus then
        self.eventBus:emit("research:completed", {
            researchId = self.id,
            researchName = self.name,
            category = self.category,
            unlocks = self.unlocks,
            effects = self.effects
        })
    end
end

--- Emit research cancellation event
function ResearchEntry:_emitCancellationEvent()
    if self.eventBus then
        self.eventBus:emit("research:cancelled", {
            researchId = self.id,
            researchName = self.name,
            progress = self.progress
        })
    end
end

--- Get research status summary
function ResearchEntry:getStatusSummary()
    return {
        id = self.id,
        name = self.name,
        category = self.category,
        isCompleted = self.isCompleted,
        isStarted = self.isStarted,
        progress = self.progress,
        cost = self.cost,
        baseTime = self.baseTime,
        prerequisites = self.prerequisites,
        unlocks = self.unlocks
    }
end

--- Check if this research is available (prerequisites met)
-- @param completedResearch Set of completed research IDs
function ResearchEntry:isAvailable(completedResearch)
    return not self.isCompleted and self:meetsPrerequisites(completedResearch)
end

--- Get the research category
function ResearchEntry:getCategory()
    return self.category
end

--- Get the research cost
function ResearchEntry:getCost()
    return self.cost
end

--- Get the base time
function ResearchEntry:getBaseTime()
    return self.baseTime
end

--- Get prerequisites
function ResearchEntry:getPrerequisites()
    return self.prerequisites
end

--- Check if completed
function ResearchEntry:isResearchCompleted()
    return self.isCompleted
end

return ResearchEntry
