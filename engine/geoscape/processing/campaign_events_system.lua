--[[
    Campaign Events System

    Generates and manages dynamic campaign events that create story beats and
    strategic complications. Events are generated based on threat level, player
    performance, and campaign progression. Events can trigger special missions,
    modify campaign state, or present strategic choices.

    The system tracks:
    - Event generation based on threat and circumstances
    - Event effects on campaign state
    - Mission complications and special objectives
    - Cascading event effects
    - Strategic decision points
]]

local CampaignEventsSystem = {}
CampaignEventsSystem.__index = CampaignEventsSystem

---
-- Initialize campaign events system
-- @param campaign_data: Campaign data table
-- @return: New CampaignEventsSystem instance
function CampaignEventsSystem.new(campaign_data)
    local self = setmetatable({}, CampaignEventsSystem)
    self.campaignData = campaign_data
    self.threatLevel = 0
    self.active_events = {}
    self.event_history = {}
    self.event_log = {}
    return self
end

---
-- Define all possible events in the game
-- @return: Event template library
function CampaignEventsSystem:_getEventTemplates()
    return {
        -- Low threat events (0-25)
        civilian_panic = {
            name = "Civilian Panic",
            threat_min = 0,
            threat_max = 25,
            probability = 0.3,
            tier = 1,
            effects = {
                funding_modifier = -0.1,
                pressure_increase = 5,
                panic_level = 1
            },
            description = "Civilian populations fear the unknown threat",
            complications = { }
        },

        research_breakthrough = {
            name = "Research Breakthrough",
            threat_min = 5,
            threat_max = 30,
            probability = 0.4,
            tier = 1,
            effects = {
                research_points = 100,
                tech_unlock = "basic_plasma"
            },
            description = "Scientists make important discoveries about alien technology",
            complications = {}
        },

        -- Mid-threat events (25-50)
        alien_activity_spike = {
            name = "Alien Activity Spike",
            threat_min = 20,
            threat_max = 50,
            probability = 0.5,
            tier = 2,
            effects = {
                mission_frequency = 1.5,
                threat_increase = 10,
                ufo_activity = 1.5
            },
            description = "Aliens increase offensive operations",
            complications = { "increased_casualties", "shorter_turnaround" }
        },

        base_security_breach = {
            name = "Base Security Breach",
            threat_min = 25,
            threat_max = 60,
            probability = 0.35,
            tier = 2,
            effects = {
                defense_penalty = -0.2,
                threat_increase = 15,
                security_compromise = true
            },
            description = "Alien agents infiltrate base security systems",
            complications = { "increased_breach_risk", "stolen_tech" }
        },

        -- High threat events (50-75)
        council_demands_intervention = {
            name = "Council Demands Intervention",
            threat_min = 40,
            threat_max = 75,
            probability = 0.4,
            tier = 3,
            effects = {
                council_pressure = 30,
                mandatory_missions = 1,
                funding_surge = 500
            },
            description = "Global council demands immediate military action",
            complications = { "time_pressure", "limited_resources" }
        },

        alien_leadership_emergence = {
            name = "Alien Leadership Emergence",
            threat_min = 55,
            threat_max = 85,
            probability = 0.3,
            tier = 3,
            effects = {
                threat_increase = 20,
                leader_spotted = true,
                elite_units_deployed = true
            },
            description = "Evidence emerges of a coordinated alien command structure",
            complications = { "elite_enemies", "higher_losses", "research_urgency" }
        },

        -- High threat events (60-85)
        global_meltdown_risk = {
            name = "Global Meltdown Risk",
            threat_min = 60,
            threat_max = 100,
            probability = 0.25,
            tier = 4,
            effects = {
                pressure_increase = 50,
                faction_pressure = true,
                time_limit = 30  -- Days
            },
            description = "International conflict threatens global stability amid alien threat",
            complications = { "diplomatic_crisis", "resource_competition", "factional_conflict" }
        },

        dimensional_gateway_detected = {
            name = "Dimensional Gateway Detected",
            threat_min = 75,
            threat_max = 100,
            probability = 0.15,
            tier = 4,
            effects = {
                threat_increase = 30,
                gateway_active = true,
                reinforcement_wave_incoming = true
            },
            description = "Aliens open a portal for mass troop reinforcement",
            complications = { "reinforcements", "time_critical", "final_push" }
        }
    }
end

---
-- Generate events for current campaign state
-- @param threat_level: Current threat level
-- @param days_passed: Days since last event generation
-- @return: Table of triggered events
function CampaignEventsSystem:generateEvents(threat_level, days_passed)
    if not threat_level then
        print("[CampaignEventsSystem] Invalid threat level for event generation")
        return {}
    end

    self.threatLevel = threat_level
    days_passed = days_passed or 1

    local triggered_events = {}
    local templates = self:_getEventTemplates()

    for event_id, template in pairs(templates) do
        if template then
            -- Check if event is in valid threat range
            if threat_level >= template.threat_min and threat_level <= template.threat_max then
                -- Scale probability with threat level
                local threat_factor = (threat_level - template.threat_min) /
                                    (template.threat_max - template.threat_min)
                local adjusted_probability = template.probability * (1 + threat_factor * 0.5)

                -- Generate event based on probability and days passed
                if math.random() < (adjusted_probability * days_passed / 30) then
                    table.insert(triggered_events, {
                        event_id = event_id,
                        name = template.name,
                        tier = template.tier,
                        effects = self:_processEventEffects(template.effects),
                        complications = template.complications,
                        triggered_at_threat = threat_level,
                        timestamp = os.time(),
                        resolved = false
                    })
                end
            end
        end
    end

    -- Add to active events and history
    for _, event in pairs(triggered_events) do
        table.insert(self.active_events, event)
        table.insert(self.event_history, event)
        table.insert(self.event_log, string.format("[%s] Event triggered: %s (threat: %.1f)",
            os.date("%Y-%m-%d"), event.name, event.triggered_at_threat))
    end

    return triggered_events
end

---
-- Process event effects on campaign state
-- @param effects: Table of effects from event template
-- @return: Processed effects table
function CampaignEventsSystem:_processEventEffects(effects)
    if not effects then return {} end

    local processed = {}

    for effect_type, value in pairs(effects) do
        if effect_type == "funding_modifier" then
            processed.funding_adjustment = math.floor(1000 * value)
        elseif effect_type == "research_points" then
            processed.research_gained = value
        elseif effect_type == "mission_frequency" then
            processed.frequency_multiplier = value
        else
            processed[effect_type] = value
        end
    end

    return processed
end

---
-- Get active events and their current effects
-- @return: Table of active events
function CampaignEventsSystem:getActiveEvents()
    local active = {}

    for i, event in pairs(self.active_events) do
        if event and not event.resolved then
            table.insert(active, {
                event_id = i,
                name = event.name,
                tier = event.tier,
                description = self:_getEventDescription(event),
                complications = event.complications,
                time_active = os.time() - (event.timestamp or 0)
            })
        end
    end

    return active
end

---
-- Get description for an event
-- @param event: Event table
-- @return: Event description string
function CampaignEventsSystem:_getEventDescription(event)
    local descriptions = {
        civilian_panic = "Populations are panicking. Public confidence is shaking.",
        research_breakthrough = "Scientists have made important discoveries!",
        alien_activity_spike = "UFO activity has increased dramatically.",
        base_security_breach = "Security systems have been compromised!",
        council_demands_intervention = "The council is demanding immediate action.",
        alien_leadership_emergence = "Evidence suggests coordinated alien command.",
        global_meltdown_risk = "Global stability is crumbling under the pressure.",
        dimensional_gateway_detected = "The aliens are opening a massive portal!"
    }

    return descriptions[event.name] or "Campaign event has triggered"
end

---
-- Apply mission complication to upcoming mission
-- @param complication_type: Type of complication
-- @param mission_data: Mission data table to modify
function CampaignEventsSystem:applyMissionComplication(complication_type, mission_data)
    if not mission_data then return end

    if complication_type == "time_pressure" then
        mission_data.time_limit_turns = mission_data.time_limit_turns or 100
        mission_data.time_limit_turns = mission_data.time_limit_turns * 0.75
    elseif complication_type == "increased_casualties" then
        mission_data.casualty_penalty = (mission_data.casualty_penalty or 0) + 0.5
    elseif complication_type == "elite_enemies" then
        mission_data.enemy_tier = math.min(5, (mission_data.enemy_tier or 1) + 2)
    elseif complication_type == "reinforcements" then
        mission_data.enemy_reinforcements = true
        mission_data.reinforcement_count = mission_data.reinforcement_count or 4
    elseif complication_type == "limited_resources" then
        mission_data.supply_limit = 0.5
    elseif complication_type == "diplomatic_crisis" then
        mission_data.diplomatic_weight = 2.0
    end
end

---
-- Resolve an event
-- @param event_id: ID of event to resolve
-- @param resolution_type: How the event was resolved ("success", "failure", "neutral")
function CampaignEventsSystem:resolveEvent(event_id, resolution_type)
    if not event_id or not self.active_events[event_id] then
        print("[CampaignEventsSystem] Invalid event ID for resolution")
        return
    end

    local event = self.active_events[event_id]
    event.resolved = true
    event.resolution = resolution_type
    event.resolved_at = os.time()

    table.insert(self.event_log, string.format("[%s] Event resolved: %s (%s)",
        os.date("%Y-%m-%d"), event.name, resolution_type))
end

---
-- Check for cascading events
-- @param resolved_event: Event that was just resolved
-- @return: Table of cascading events triggered
function CampaignEventsSystem:checkCascadingEvents(resolved_event)
    local cascading = {}

    if resolved_event.name == "alien_leadership_emergence" then
        table.insert(cascading, {
            name = "Elite Squad Deployment",
            effect = "elite_units_deployed"
        })
    elseif resolved_event.name == "base_security_breach" then
        table.insert(cascading, {
            name = "Security Investigation",
            effect = "counter_intelligence_operations"
        })
    elseif resolved_event.name == "global_meltdown_risk" then
        table.insert(cascading, {
            name = "International Cooperation",
            effect = "increased_funding"
        })
    end

    return cascading
end

---
-- Get event statistics
-- @return: Stats table
function CampaignEventsSystem:getEventStatistics()
    return {
        total_events_triggered = #self.event_history,
        active_events = #self.active_events,
        resolved_events = self:_countResolvedEvents(),
        critical_events = self:_countEventTier(4),
        high_priority_events = self:_countEventTier(3),
        event_log = self.event_log
    }
end

---
-- Count resolved events
-- @return: Count
function CampaignEventsSystem:_countResolvedEvents()
    local count = 0
    for _, event in pairs(self.active_events) do
        if event and event.resolved then
            count = count + 1
        end
    end
    return count
end

---
-- Count events by tier
-- @param tier: Tier level
-- @return: Count
function CampaignEventsSystem:_countEventTier(tier)
    local count = 0
    for _, event in pairs(self.event_history) do
        if event and event.tier == tier then
            count = count + 1
        end
    end
    return count
end

---
-- Serialize events for save game
-- @return: Serializable table
function CampaignEventsSystem:serialize()
    return {
        threatLevel = self.threatLevel,
        active_events = self.active_events,
        event_history = self.event_history,
        event_log = self.event_log
    }
end

---
-- Deserialize events from save game
-- @param data: Serialized data table
function CampaignEventsSystem:deserialize(data)
    if not data then return end

    self.threatLevel = data.threatLevel or 0
    self.active_events = data.active_events or {}
    self.event_history = data.event_history or {}
    self.event_log = data.event_log or {}
end

return CampaignEventsSystem

