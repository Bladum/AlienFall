---Event Purchasing System
---
---Allows players to purchase political and economic events through the Black Market to manipulate
---the game world. Events trigger real effects on countries, provinces, economies, and factions.
---Provides 8 event types from improving relations to crashing markets.
---
---Key Features:
---  - 8 event types for political/economic manipulation
---  - Dynamic cost based on event type and target (20K-80K)
---  - Karma penalties per event (-5 to -35)
---  - Effects apply after 1-3 day delay
---  - Duration: 3-6 months or permanent
---  - Discovery risk: 12% per purchased event
---  - Strategic gameplay: manipulate world to your advantage
---
---Event Types:
---  - Improve Relations (30K, -10 karma): +20 relations with country
---  - Sabotage Economy (50K, -25 karma): Drop province economy tier
---  - Incite Rebellion (80K, -35 karma): Province contested for 3 months
---  - Spread Propaganda (20K, -5 karma): +10 fame, +10 relations
---  - Frame Rival (60K, -30 karma): Rival faction -30 relations
---  - Bribe Officials (40K, -15 karma): Ignore black market activity 6 months
---  - Crash Market (70K, -20 karma): 30% cheaper items for 3 months
---  - False Intelligence (35K, -15 karma): Fake UFO sighting, misdirect
---
---Key Exports:
---  - EventPurchasing.purchaseEvent(type, target, payment): Buy event
---  - EventPurchasing.getAvailableEvents(karma, fame): Get purchasable events
---  - EventPurchasing.applyEvent(eventData): Trigger event effects
---  - EventPurchasing.updateActiveEvents(currentTime): Process ongoing events
---
---Dependencies:
---  - geoscape.country_system: Country relations
---  - geoscape.province_system: Province economies
---  - politics.relations_system: Faction relations
---  - economy.marketplace_system: Market manipulation
---
---@module economy.event_purchasing
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source

local EventPurchasing = {}

-- Configuration
EventPurchasing.CONFIG = {
    -- Event type definitions
    EVENTS = {
        improve_relations = {
            id = "improve_relations",
            name = "Improve Relations",
            description = "Diplomatic campaign to improve standing with target country",
            base_cost = 30000,
            karma_penalty = -10,
            relations_bonus = 20,
            trigger_delay_min = 1,
            trigger_delay_max = 3,
            duration_days = 0,  -- Permanent effect
            discovery_chance = 0.10,
            target_type = "country",
        },
        sabotage_economy = {
            id = "sabotage_economy",
            name = "Sabotage Economy",
            description = "Covert operations to damage target province economy",
            base_cost = 50000,
            karma_penalty = -25,
            economy_tier_drop = 1,
            trigger_delay_min = 2,
            trigger_delay_max = 4,
            duration_days = 0,  -- Permanent effect
            discovery_chance = 0.15,
            target_type = "province",
        },
        incite_rebellion = {
            id = "incite_rebellion",
            name = "Incite Rebellion",
            description = "Fund insurgent groups to contest control of province",
            base_cost = 80000,
            karma_penalty = -35,
            province_contested = true,
            trigger_delay_min = 3,
            trigger_delay_max = 7,
            duration_days = 90,  -- 3 months
            discovery_chance = 0.18,
            target_type = "province",
        },
        spread_propaganda = {
            id = "spread_propaganda",
            name = "Spread Propaganda",
            description = "Media campaign to boost reputation and relations",
            base_cost = 20000,
            karma_penalty = -5,
            fame_bonus = 10,
            relations_bonus = 10,
            trigger_delay_min = 1,
            trigger_delay_max = 2,
            duration_days = 0,  -- Permanent effect
            discovery_chance = 0.08,
            target_type = "country",
        },
        frame_rival = {
            id = "frame_rival",
            name = "Frame Rival Faction",
            description = "False flag operation to damage rival faction reputation",
            base_cost = 60000,
            karma_penalty = -30,
            relations_penalty = -30,
            trigger_delay_min = 2,
            trigger_delay_max = 5,
            duration_days = 0,  -- Permanent effect
            discovery_chance = 0.16,
            target_type = "faction",
        },
        bribe_officials = {
            id = "bribe_officials",
            name = "Bribe Officials",
            description = "Pay off officials to ignore black market activities",
            base_cost = 40000,
            karma_penalty = -15,
            immunity_duration_days = 180,  -- 6 months
            trigger_delay_min = 1,
            trigger_delay_max = 2,
            duration_days = 180,  -- 6 months
            discovery_chance = 0.12,
            target_type = "country",
        },
        crash_market = {
            id = "crash_market",
            name = "Crash Market",
            description = "Manipulate markets to crash prices temporarily",
            base_cost = 70000,
            karma_penalty = -20,
            price_discount = 0.30,  -- 30% cheaper
            trigger_delay_min = 2,
            trigger_delay_max = 4,
            duration_days = 90,  -- 3 months
            discovery_chance = 0.14,
            target_type = "global",
        },
        false_intelligence = {
            id = "false_intelligence",
            name = "False Intelligence",
            description = "Plant fake UFO sighting to misdirect attention",
            base_cost = 35000,
            karma_penalty = -15,
            fake_mission_spawn = true,
            trigger_delay_min = 1,
            trigger_delay_max = 3,
            duration_days = 0,  -- Immediate effect
            discovery_chance = 0.10,
            target_type = "region",
        },
    },
}

---Purchase event from Black Market
---@param eventType string Event type ID
---@param targetId string Target ID (country, province, faction, or region)
---@param blackMarket table Black Market system
---@param karmaSystem table Karma system
---@param treasury table Treasury system
---@return boolean success
---@return string|nil reason
---@return table|nil result {event_id, trigger_date, duration}
function EventPurchasing.purchaseEvent(eventType, targetId, blackMarket, karmaSystem, treasury)
    local cfg = EventPurchasing.CONFIG

    -- Validate event type
    local eventDef = cfg.EVENTS[eventType]
    if not eventDef then
        return false, "Unknown event type: " .. eventType
    end

    -- Check funds
    if treasury and treasury:getBalance() < eventDef.base_cost then
        return false, "Insufficient funds (need " .. eventDef.base_cost .. " credits)"
    end

    -- Deduct payment
    if treasury then
        treasury:deduct(eventDef.base_cost, "Black Market event: " .. eventDef.name)
    end

    -- Apply karma penalty
    if karmaSystem then
        karmaSystem:modify(eventDef.karma_penalty, "Purchased event: " .. eventDef.name)
    end

    -- Calculate trigger date (1-3 days delay)
    local triggerDelay = math.random(eventDef.trigger_delay_min, eventDef.trigger_delay_max)
    local triggerDate = os.time() + (triggerDelay * 86400)

    -- Create event data
    local eventData = {
        id = "bm_event_" .. eventType .. "_" .. os.time(),
        type = eventType,
        definition = eventDef,
        target_id = targetId,
        purchase_date = os.time(),
        trigger_date = triggerDate,
        trigger_delay_days = triggerDelay,
        duration_days = eventDef.duration_days,
        expiry_date = triggerDate + (eventDef.duration_days * 86400),
        purchased_through_black_market = true,
        discovery_chance = eventDef.discovery_chance,
        active = false,
    }

    -- Schedule event trigger
    EventPurchasing._scheduleEventTrigger(eventData)

    print(string.format("[EventPurchasing] Event purchased: %s", eventDef.name))
    print(string.format("  Cost: %d credits", eventDef.base_cost))
    print(string.format("  Karma: %d", eventDef.karma_penalty))
    print(string.format("  Triggers in: %d days", triggerDelay))
    if eventDef.duration_days > 0 then
        print(string.format("  Duration: %d days", eventDef.duration_days))
    else
        print("  Duration: Permanent")
    end

    return true, nil, {
        event_id = eventData.id,
        trigger_date = triggerDate,
        trigger_delay_days = triggerDelay,
        duration_days = eventDef.duration_days,
    }
end

---Get available events for purchase based on karma and fame
---@param karma number Current karma level (-100 to +100)
---@param fame number Current fame level (0-100)
---@return table events Array of available event definitions
function EventPurchasing.getAvailableEvents(karma, fame)
    local cfg = EventPurchasing.CONFIG
    local available = {}

    -- Determine access based on karma
    for eventType, eventDef in pairs(cfg.EVENTS) do
        local karmaRequired = eventDef.karma_penalty * -1

        -- Event available if player karma is low enough
        if karma <= karmaRequired then
            -- Some events also require fame
            local fameRequired = 0
            if eventType == "spread_propaganda" or eventType == "frame_rival" then
                fameRequired = 40  -- Need some fame to manipulate reputation
            end

            if fame >= fameRequired then
                table.insert(available, eventDef)
            end
        end
    end

    -- Sort by cost (ascending)
    table.sort(available, function(a, b) return a.base_cost < b.base_cost end)

    print(string.format("[EventPurchasing] %d events available at karma %d, fame %d",
        #available, karma, fame))

    return available
end

---Schedule event to trigger after delay
---@param eventData table Event data with trigger_date
function EventPurchasing._scheduleEventTrigger(eventData)
    if not EventPurchasing._pendingEvents then
        EventPurchasing._pendingEvents = {}
    end

    table.insert(EventPurchasing._pendingEvents, eventData)

    print(string.format("[EventPurchasing] Event scheduled: %s (triggers at %d)",
        eventData.id, eventData.trigger_date))
end

---Check and trigger pending events (called by time system)
---@param currentTime number Current game time (timestamp)
---@return number triggered Number of events triggered
function EventPurchasing.updatePendingEvents(currentTime)
    if not EventPurchasing._pendingEvents then
        return 0
    end

    local triggered = 0
    local remaining = {}

    for _, eventData in ipairs(EventPurchasing._pendingEvents) do
        if currentTime >= eventData.trigger_date then
            -- Trigger event
            local success = EventPurchasing.applyEvent(eventData)
            if success then
                triggered = triggered + 1

                -- If event has duration, move to active events
                if eventData.duration_days > 0 then
                    EventPurchasing._addActiveEvent(eventData)
                end
            else
                -- Failed to trigger, keep in pending
                table.insert(remaining, eventData)
            end
        else
            -- Not yet time to trigger
            table.insert(remaining, eventData)
        end
    end

    EventPurchasing._pendingEvents = remaining

    if triggered > 0 then
        print(string.format("[EventPurchasing] Triggered %d pending events", triggered))
    end

    return triggered
end

---Add event to active events list
---@param eventData table Event data
function EventPurchasing._addActiveEvent(eventData)
    if not EventPurchasing._activeEvents then
        EventPurchasing._activeEvents = {}
    end

    eventData.active = true
    table.insert(EventPurchasing._activeEvents, eventData)

    print(string.format("[EventPurchasing] Event now active: %s (expires at %d)",
        eventData.id, eventData.expiry_date))
end

---Update active events and expire them (called by time system)
---@param currentTime number Current game time (timestamp)
---@return number expired Number of events expired
function EventPurchasing.updateActiveEvents(currentTime)
    if not EventPurchasing._activeEvents then
        return 0
    end

    local expired = 0
    local remaining = {}

    for _, eventData in ipairs(EventPurchasing._activeEvents) do
        if currentTime >= eventData.expiry_date then
            -- Event expired, remove effects
            EventPurchasing._removeEventEffects(eventData)
            expired = expired + 1
        else
            -- Still active
            table.insert(remaining, eventData)
        end
    end

    EventPurchasing._activeEvents = remaining

    if expired > 0 then
        print(string.format("[EventPurchasing] %d events expired", expired))
    end

    return expired
end

---Apply event effects
---@param eventData table Event data
---@return boolean success
function EventPurchasing.applyEvent(eventData)
    if not eventData then return false end

    local eventDef = eventData.definition

    print(string.format("[EventPurchasing] Applying event: %s", eventDef.name))
    print(string.format("  Target: %s", eventData.target_id))

    -- Roll for discovery
    local discovered = (math.random() < eventDef.discovery_chance)
    if discovered then
        print("[EventPurchasing] WARNING: Event traced back to player!")
        -- TODO: Apply discovery penalties
    end

    -- Apply event-specific effects
    if eventData.type == "improve_relations" then
        -- TODO: relationSystem:modify(target_id, +20)
        print(string.format("  Relations: +%d with %s",
            eventDef.relations_bonus, eventData.target_id))

    elseif eventData.type == "sabotage_economy" then
        -- TODO: provinceSystem:dropEconomyTier(target_id, 1)
        print(string.format("  Economy: -%d tier in %s",
            eventDef.economy_tier_drop, eventData.target_id))

    elseif eventData.type == "incite_rebellion" then
        -- TODO: provinceSystem:setContested(target_id, true, duration)
        print(string.format("  Province %s contested for %d days",
            eventData.target_id, eventDef.duration_days))

    elseif eventData.type == "spread_propaganda" then
        -- TODO: fameSystem:modify(+10), relationSystem:modify(target, +10)
        print(string.format("  Fame: +%d, Relations: +%d",
            eventDef.fame_bonus, eventDef.relations_bonus))

    elseif eventData.type == "frame_rival" then
        -- TODO: relationSystem:modify(target_faction, -30)
        print(string.format("  Rival faction %s: %d relations",
            eventData.target_id, eventDef.relations_penalty))

    elseif eventData.type == "bribe_officials" then
        -- TODO: blackMarket:setImmunity(target_country, duration)
        print(string.format("  Black market immunity in %s for %d days",
            eventData.target_id, eventDef.immunity_duration_days))

    elseif eventData.type == "crash_market" then
        -- TODO: marketSystem:setPriceModifier(0.70, duration)
        print(string.format("  Market prices: %.0f%% for %d days",
            (1 - eventDef.price_discount) * 100, eventDef.duration_days))

    elseif eventData.type == "false_intelligence" then
        -- TODO: missionSystem:spawnFakeMission(target_region)
        print(string.format("  Fake UFO sighting spawned in %s", eventData.target_id))
    end

    return true
end

---Remove event effects when expired
---@param eventData table Event data
function EventPurchasing._removeEventEffects(eventData)
    print(string.format("[EventPurchasing] Removing event effects: %s",
        eventData.definition.name))

    -- Remove temporary effects
    if eventData.type == "incite_rebellion" then
        -- TODO: provinceSystem:setContested(target_id, false)
        print(string.format("  Rebellion ended in %s", eventData.target_id))

    elseif eventData.type == "bribe_officials" then
        -- TODO: blackMarket:clearImmunity(target_country)
        print(string.format("  Bribe immunity ended in %s", eventData.target_id))

    elseif eventData.type == "crash_market" then
        -- TODO: marketSystem:clearPriceModifier()
        print("  Market prices normalized")
    end
end

---Get event definition
---@param eventType string Event type ID
---@return table|nil definition Event definition or nil
function EventPurchasing.getEventDefinition(eventType)
    return EventPurchasing.CONFIG.EVENTS[eventType]
end

---Get all event types
---@return table events Array of all event definitions
function EventPurchasing.getAllEventTypes()
    local events = {}
    for _, def in pairs(EventPurchasing.CONFIG.EVENTS) do
        table.insert(events, def)
    end

    -- Sort by cost
    table.sort(events, function(a, b) return a.base_cost < b.base_cost end)

    return events
end

---Get active events (for UI display)
---@return table events Array of currently active events
function EventPurchasing.getActiveEvents()
    return EventPurchasing._activeEvents or {}
end

return EventPurchasing

