-- Event Chain Manager System
-- Manages campaign events and event chains/triggers

local ContentDatabase = require("engine.content.content_database")

local EventChainManager = {}

-- Event queue and state
local eventQueue = {}
local activeEvents = {}
local eventHistory = {}
local chainState = {}

---Register event trigger chains
function EventChainManager.registerChain(triggerId, chainDefinition)
    -- Chain definition: {
    --   trigger_event = "event_id",
    --   conditions = {...},
    --   chain_events = {"event_id1", "event_id2", ...}
    -- }

    chainState[triggerId] = chainDefinition
    print("[EventChain] Registered chain: " .. triggerId)
end

---Trigger an event
function EventChainManager.triggerEvent(eventId, context)
    context = context or {}

    local event = ContentDatabase.getEvent(eventId)
    if not event then
        print("[EventChain] Warning: Event not found: " .. eventId)
        return false
    end

    -- Create event instance
    local eventInstance = {
        id = eventId,
        instance_id = eventId .. "_" .. math.random(10000, 99999),
        name = event.name,
        description = event.description,
        type = event.type,
        effects = event.effects or {},
        triggered_at = os.time(),
        duration_turns = event.duration_turns or 0,
        context = context,
        active = true
    }

    -- Add to active events
    table.insert(activeEvents, eventInstance)
    table.insert(eventHistory, eventInstance)

    print("[EventChain] Event triggered: " .. event.name .. " (" .. eventId .. ")")

    -- Apply effects
    EventChainManager.applyEventEffects(eventInstance)

    -- Check for chain triggers
    EventChainManager.checkChainTriggers(eventId, context)

    return true
end

---Check if any chains are triggered
function EventChainManager.checkChainTriggers(eventId, context)
    for chainId, chain in pairs(chainState) do
        if chain.trigger_event == eventId then
            -- Check conditions
            if EventChainManager.checkConditions(chain.conditions or {}, context) then
                print("[EventChain] Chain triggered: " .. chainId)

                -- Queue chain events
                if chain.chain_events then
                    for _, nextEventId in ipairs(chain.chain_events) do
                        table.insert(eventQueue, {
                            event_id = nextEventId,
                            context = context,
                            delay_turns = chain.delay_turns or 0
                        })
                    end
                end
            end
        end
    end
end

---Check event conditions
function EventChainManager.checkConditions(conditions, context)
    for _, condition in ipairs(conditions) do
        if not EventChainManager.checkCondition(condition, context) then
            return false
        end
    end
    return true
end

---Check single condition
function EventChainManager.checkCondition(condition, context)
    -- Simple condition checking
    -- Examples:
    -- {type = "research_level", min = 5}
    -- {type = "faction_relation", faction = "sectoid", min = 50}
    -- {type = "base_count", min = 2}

    if condition.type == "always_true" then
        return true
    elseif condition.type == "random" then
        return math.random() < (condition.probability or 0.5)
    elseif condition.type == "research_level" then
        local current = context.research_level or 0
        return current >= (condition.min or 0)
    elseif condition.type == "faction_relation" then
        local relation = context.faction_relations and context.faction_relations[condition.faction] or 0
        return relation >= (condition.min or -100)
    elseif condition.type == "base_count" then
        local count = context.base_count or 0
        return count >= (condition.min or 1)
    else
        return true
    end
end

---Apply event effects
function EventChainManager.applyEventEffects(eventInstance)
    if not eventInstance.effects then
        return
    end

    for _, effect in ipairs(eventInstance.effects) do
        EventChainManager.applyEffect(effect, eventInstance)
    end
end

---Apply single effect
function EventChainManager.applyEffect(effect, eventInstance)
    -- Effect types:
    -- - tech_unlock: {type = "tech_unlock", tech_id = "..."}
    -- - morale_boost: {type = "morale_boost", amount = 10}
    -- - money: {type = "money", amount = 1000}
    -- - resources: {type = "resources", resource = "elerium", amount = 50}

    if effect.type == "tech_unlock" then
        print("[EventChain] Effect: Unlocking tech: " .. effect.tech_id)
        -- Would call tech system to unlock
    elseif effect.type == "morale_boost" then
        print("[EventChain] Effect: Morale boost: " .. effect.amount)
        -- Would apply to game state
    elseif effect.type == "money" then
        print("[EventChain] Effect: Money: " .. effect.amount)
        -- Would add to treasury
    elseif effect.type == "resources" then
        print("[EventChain] Effect: Resources: " .. effect.resource .. " x" .. effect.amount)
        -- Would add to resource storage
    else
        print("[EventChain] Unknown effect: " .. effect.type)
    end
end

---Process event queue (called each turn)
function EventChainManager.processTurn()
    local processed = {}

    for i, queuedEvent in ipairs(eventQueue) do
        if queuedEvent.delay_turns and queuedEvent.delay_turns > 0 then
            queuedEvent.delay_turns = queuedEvent.delay_turns - 1
        else
            -- Trigger this event
            EventChainManager.triggerEvent(queuedEvent.event_id, queuedEvent.context)
            table.insert(processed, i)
        end
    end

    -- Remove processed events from queue
    for i = #processed, 1, -1 do
        table.remove(eventQueue, processed[i])
    end

    -- Update active events
    local stillActive = {}
    for _, event in ipairs(activeEvents) do
        event.duration_turns = event.duration_turns - 1
        if event.duration_turns > 0 then
            table.insert(stillActive, event)
        else
            print("[EventChain] Event expired: " .. event.name)
        end
    end
    activeEvents = stillActive
end

---Get random event of type
function EventChainManager.getRandomEventOfType(eventType)
    return ContentDatabase.getRandomEvent(eventType)
end

---Get active events
function EventChainManager.getActiveEvents()
    return activeEvents
end

---Get event history
function EventChainManager.getEventHistory(limit)
    limit = limit or 10

    local result = {}
    local startIdx = math.max(1, #eventHistory - limit + 1)

    for i = startIdx, #eventHistory do
        table.insert(result, eventHistory[i])
    end

    return result
end

---Get event queue
function EventChainManager.getEventQueue()
    return eventQueue
end

---Clear all events
function EventChainManager.clearAll()
    eventQueue = {}
    activeEvents = {}
    eventHistory = {}
    chainState = {}
end

---Get event statistics
function EventChainManager.getStats()
    return {
        queued_events = #eventQueue,
        active_events = #activeEvents,
        event_history_count = #eventHistory,
        chain_count = table.countKeys(chainState)
    }
end

---Print event status
function EventChainManager.printStatus()
    local stats = EventChainManager.getStats()

    print("\n" .. string.rep("=", 60))
    print("EVENT CHAIN STATUS")
    print(string.rep("=", 60))
    print("Queued Events: " .. stats.queued_events)
    print("Active Events: " .. stats.active_events)
    print("Event History: " .. stats.event_history_count .. " total")
    print("Registered Chains: " .. stats.chain_count)

    if #activeEvents > 0 then
        print("\nActive Events:")
        for i, event in ipairs(activeEvents) do
            print("  " .. i .. ". " .. event.name .. " (" .. event.type .. ")")
        end
    end

    if #eventQueue > 0 then
        print("\nQueued Events:")
        for i, queuedEvent in ipairs(eventQueue) do
            print("  " .. i .. ". " .. queuedEvent.event_id)
        end
    end

    print(string.rep("=", 60) .. "\n")
end

-- Helper function
function table.countKeys(tbl)
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    return count
end

return EventChainManager
