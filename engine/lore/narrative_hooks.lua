--- Narrative Hooks System
--- Delivers dynamic storytelling through research discoveries, interrogations, and events
---
--- Narrative hooks are triggered by game events and deliver story beats, lore entries,
--- and strategic information to the player. They drive the campaign narrative forward.
---
--- Hook Types:
--- - research_complete: Triggered when research finishes
--- - interrogation_complete: Triggered by successful alien interrogation
--- - mission_success: Triggered by mission completion
--- - mission_failure: Triggered by mission failure
--- - phase_transition: Triggered when entering new campaign phase
--- - diplomatic_event: Triggered by country/faction events
---
--- @class NarrativeHooks
local NarrativeHooks = {}

--- Initialize narrative hooks system
function NarrativeHooks:new()
    local self = setmetatable({}, { __index = NarrativeHooks })
    
    self.narrativeEvents = {}  -- id -> event definition
    self.triggeredHooks = {}   -- track which hooks have fired
    self.encyclopedia = {}     -- id -> lore entry
    self.activeNarrative = {}  -- current narrative threads
    
    print("[NarrativeHooks] Initialized")
    return self
end

--- Load narrative event from mod configuration
--- @param eventId string Unique event identifier
--- @param eventData table Event configuration from TOML
function NarrativeHooks:loadEvent(eventId, eventData)
    if not eventData then
        print("[NarrativeHooks] Warning: No data for event " .. eventId)
        return nil
    end
    
    local event = {
        id = eventId,
        title = eventData.title or "Unknown Event",
        trigger_type = eventData.trigger_type or "manual",
        trigger_id = eventData.trigger_id or "",
        description = eventData.description or "",
        lore_entry = eventData.lore_entry or "",
        unlocks = eventData.unlocks or {},
        effects = eventData.effects or {},
        encyclopedia_category = eventData.encyclopedia_category or "general",
        priority = eventData.priority or 50,
    }
    
    self.narrativeEvents[eventId] = event
    print("[NarrativeHooks] Loaded narrative event: " .. eventId)
    return event
end

--- Trigger narrative hook for research completion
--- @param researchId string Completed research ID
--- @param gameState table Current game state
function NarrativeHooks:onResearchComplete(researchId, gameState)
    print("[NarrativeHooks] Research completed: " .. researchId)
    
    -- Find narrative events tied to this research
    for _, event in pairs(self.narrativeEvents) do
        if event.trigger_type == "research_complete" and event.trigger_id == researchId then
            self:triggerEvent(event, gameState)
        end
    end
end

--- Trigger narrative hook for alien interrogation
--- @param alienType string Type of alien interrogated
--- @param intel string Information revealed
--- @param gameState table Current game state
function NarrativeHooks:onInterrogation(alienType, intel, gameState)
    print("[NarrativeHooks] Interrogation: " .. alienType)
    
    -- Find narrative events tied to this alien type
    for _, event in pairs(self.narrativeEvents) do
        if event.trigger_type == "interrogation_complete" and event.trigger_id == alienType then
            self:triggerEvent(event, gameState)
        end
    end
end

--- Trigger narrative hook for mission outcome
--- @param missionId string Mission completed
--- @param outcome string "success" or "failure"
--- @param gameState table Current game state
function NarrativeHooks:onMissionComplete(missionId, outcome, gameState)
    print("[NarrativeHooks] Mission " .. outcome .. ": " .. missionId)
    
    -- Find narrative events tied to this mission
    for _, event in pairs(self.narrativeEvents) do
        local triggerMatch = (outcome == "success" and event.trigger_type == "mission_success") or
                             (outcome == "failure" and event.trigger_type == "mission_failure")
        
        if triggerMatch and event.trigger_id == missionId then
            self:triggerEvent(event, gameState)
        end
    end
end

--- Trigger narrative hook for phase transition
--- @param newPhase number New campaign phase (1-4)
--- @param gameState table Current game state
function NarrativeHooks:onPhaseTransition(newPhase, gameState)
    print("[NarrativeHooks] Phase transition to: " .. newPhase)
    
    -- Find phase-specific narrative beats
    for _, event in pairs(self.narrativeEvents) do
        if event.trigger_type == "phase_transition" and event.trigger_id == "phase_" .. newPhase then
            self:triggerEvent(event, gameState)
        end
    end
end

--- Trigger narrative hook for diplomatic event
--- @param countryId string Country involved
--- @param eventType string Type of diplomatic event
--- @param gameState table Current game state
function NarrativeHooks:onDiplomaticEvent(countryId, eventType, gameState)
    print("[NarrativeHooks] Diplomatic event: " .. countryId .. " - " .. eventType)
    
    -- Find narrative events tied to this diplomatic situation
    for _, event in pairs(self.narrativeEvents) do
        if event.trigger_type == "diplomatic_event" and event.trigger_id == (countryId .. "_" .. eventType) then
            self:triggerEvent(event, gameState)
        end
    end
end

--- Execute narrative event effects
--- @param event table Event to trigger
--- @param gameState table Current game state
function NarrativeHooks:triggerEvent(event, gameState)
    if self.triggeredHooks[event.id] then
        print("[NarrativeHooks] Event already triggered: " .. event.id)
        return
    end
    
    -- Mark as triggered
    self.triggeredHooks[event.id] = true
    
    -- Add to encyclopedia
    self:addEncyclopediaEntry(event.id, event)
    
    -- Unlock related narrative threads
    for _, unlockId in ipairs(event.unlocks) do
        table.insert(self.activeNarrative, unlockId)
    end
    
    -- Apply effects
    self:applyEventEffects(event, gameState)
    
    print("[NarrativeHooks] Triggered event: " .. event.title)
end

--- Add entry to in-game encyclopedia
--- @param entryId string Entry identifier
--- @param event table Event containing lore
function NarrativeHooks:addEncyclopediaEntry(entryId, event)
    local entry = {
        id = entryId,
        title = event.title,
        category = event.encyclopedia_category,
        content = event.lore_entry,
        date_discovered = os.date("%Y-%m-%d"),
    }
    
    self.encyclopedia[entryId] = entry
    print("[NarrativeHooks] Added encyclopedia entry: " .. event.title)
end

--- Apply event effects (unlock research, change relations, etc)
--- @param event table Event with effects
--- @param gameState table Current game state
function NarrativeHooks:applyEventEffects(event, gameState)
    if not event.effects then return end
    
    -- Research unlocks
    if event.effects.unlock_research then
        for _, researchId in ipairs(event.effects.unlock_research) do
            print("[NarrativeHooks] Unlocked research: " .. researchId)
        end
    end
    
    -- Funding changes
    if event.effects.funding_change then
        print("[NarrativeHooks] Funding change: " .. event.effects.funding_change)
    end
    
    -- Panic changes
    if event.effects.panic_change then
        print("[NarrativeHooks] Panic change: " .. event.effects.panic_change)
    end
    
    -- Strategic information
    if event.effects.strategic_intel then
        print("[NarrativeHooks] Strategic intel revealed: " .. event.effects.strategic_intel)
    end
end

--- Get encyclopedia entries by category
--- @param category string Encyclopedia category
--- @return table Array of entries
function NarrativeHooks:getEncyclopediaEntries(category)
    local entries = {}
    for _, entry in pairs(self.encyclopedia) do
        if category == nil or entry.category == category then
            table.insert(entries, entry)
        end
    end
    return entries
end

--- Check if narrative thread is active
--- @param threadId string Narrative thread identifier
--- @return boolean
function NarrativeHooks:isNarrativeActive(threadId)
    for _, id in ipairs(self.activeNarrative) do
        if id == threadId then return true end
    end
    return false
end

--- Get current active narrative threads
--- @return table Active narrative thread IDs
function NarrativeHooks:getActiveNarrative()
    return self.activeNarrative
end

--- Check if event has been triggered
--- @param eventId string Event identifier
--- @return boolean
function NarrativeHooks:hasTriggered(eventId)
    return self.triggeredHooks[eventId] ~= nil
end

--- Get total number of narrative events discovered
--- @return number Count
function NarrativeHooks:getDiscoveredCount()
    local count = 0
    for _ in pairs(self.triggeredHooks) do
        count = count + 1
    end
    return count
end

--- Load narrative state from save
--- @param data table Save data
function NarrativeHooks:load(data)
    if data.triggered_hooks then
        self.triggeredHooks = data.triggered_hooks
    end
    if data.active_narrative then
        self.activeNarrative = data.active_narrative
    end
    if data.encyclopedia then
        self.encyclopedia = data.encyclopedia
    end
end

--- Get narrative state for saving
--- @return table Save data
function NarrativeHooks:getSaveData()
    return {
        triggered_hooks = self.triggeredHooks,
        active_narrative = self.activeNarrative,
        encyclopedia = self.encyclopedia,
    }
end

return NarrativeHooks



