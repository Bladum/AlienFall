--[[
    UI Integration Layer

    Bridges all campaign systems to user interface. Provides real-time data for:
    - Alien research progress display
    - Base expansion and facility status
    - Faction standing panels
    - Campaign events notifications
    - Difficulty indicators and morale effects

    Handles: data transformation for UI, overlay management, status updates
]]

local UIIntegrationLayer = {}
UIIntegrationLayer.__index = UIIntegrationLayer

---
-- Initialize UI integration layer
-- @param screen_width: Screen width in pixels
-- @param screen_height: Screen height in pixels
-- @return: New UIIntegrationLayer instance
function UIIntegrationLayer.new(screen_width, screen_height)
    local self = setmetatable({}, UIIntegrationLayer)

    self.screen_width = screen_width or 1024
    self.screen_height = screen_height or 768
    self.visible_panels = {}
    self.ui_elements = {}
    self.overlay_stack = {}
    self.notifications = {}

    return self
end

---
-- Update UI with current campaign state
-- @param orchestrator: Campaign orchestrator instance
function UIIntegrationLayer:updateCampaignUI(orchestrator)
    if not orchestrator then return end

    local status = orchestrator:getCampaignStatus()

    self:_updateTopBar(status)
    self:_updateThreatIndicator(status.threat_level)
    self:_updateResourcePanel(status)
    self:_updateAlertPanel(orchestrator)
end

---
-- Internal: Update top status bar
-- @param status: Campaign status table
function UIIntegrationLayer:_updateTopBar(status)
    self.ui_elements.top_bar = {
        days = status.days_elapsed,
        threat = status.threat_level,
        phase = status.campaign_phase,
        funding = status.funding,
        win_rate = status.win_rate,
        layout = "horizontal",
        position = { x = 0, y = 0 }
    }
end

---
-- Internal: Update threat level indicator
-- @param threat: Threat level (0-100)
function UIIntegrationLayer:_updateThreatIndicator(threat)
    local color = "green"
    local description = "Low Threat"

    if threat < 25 then
        color = "green"
        description = "Low Threat"
    elseif threat < 50 then
        color = "yellow"
        description = "Moderate Threat"
    elseif threat < 75 then
        color = "orange"
        description = "High Threat"
    else
        color = "red"
        description = "Critical Threat"
    end

    self.ui_elements.threat_indicator = {
        level = threat,
        color = color,
        description = description,
        bar_width = (threat / 100) * 200
    }
end

---
-- Internal: Update resource display panel
-- @param status: Campaign status table
function UIIntegrationLayer:_updateResourcePanel(status)
    self.ui_elements.resources = {
        soldiers = {
            current = status.soldiers_active,
            total = status.soldiers_total,
            label = "Soldiers"
        },
        crafts = {
            current = status.crafts_operational,
            total = #(status.crafts or {}),
            label = "Craft"
        },
        funding = {
            amount = status.funding,
            label = "Monthly Funding"
        },
        missions = {
            completed = status.missions_completed,
            won = status.missions_won,
            lost = status.missions_lost,
            label = "Missions"
        }
    }
end

---
-- Internal: Update alert/notification panel
-- @param orchestrator: Campaign orchestrator
function UIIntegrationLayer:_updateAlertPanel(orchestrator)
    self.notifications = {}

    if not orchestrator.systems then return end

    -- Check for active campaign events
    if orchestrator.systems.campaign_events then
        local events = orchestrator.systems.campaign_events:getActiveEvents()
        for _, event in ipairs(events) do
            if event then
                table.insert(self.notifications, {
                    type = "event",
                    title = event.name,
                    icon = "event",
                    priority = event.tier,
                    time_active = event.time_active
                })
            end
        end
    end

    -- Check for faction at-risk warnings
    if orchestrator.systems.faction_dynamics then
        local stability = orchestrator.systems.faction_dynamics:checkFactionStability()
        for _, at_risk in ipairs(stability.at_risk) do
            table.insert(self.notifications, {
                type = "faction_warning",
                title = "Faction at Risk: " .. at_risk.name,
                icon = "warning",
                priority = 2,
                standing = at_risk.standing
            })
        end
        for _, abandoned in ipairs(stability.abandonments) do
            table.insert(self.notifications, {
                type = "faction_lost",
                title = "Lost Support: " .. abandoned.name,
                icon = "alert",
                priority = 3,
                funding_loss = abandoned.funding_loss
            })
        end
    end

    -- Check for alien leader emergence
    if orchestrator.systems.difficulty_refinements then
        local leader = orchestrator.systems.difficulty_refinements:getAlienLeaderStatus()
        if leader then
            table.insert(self.notifications, {
                type = "leader",
                title = "Alien Leader Detected: " .. leader.name,
                icon = "alert",
                priority = 3,
                health = leader.health
            })
        end
    end
end

---
-- Display alien research progress panel
-- @param research_system: AlienResearchSystem instance
-- @param x, y: Panel position
function UIIntegrationLayer:displayAlienResearchPanel(research_system, x, y)
    if not research_system then return end

    x = x or 10
    y = y or 100

    local progress = research_system:getResearchProgress()

    local panel = {
        title = "Alien Research Progress",
        position = { x = x, y = y },
        width = 300,
        height = 400,
        techs = {}
    }

    for tech_id, tech_data in pairs(progress) do
        if tech_data then
            table.insert(panel.techs, {
                name = tech_data.name,
                completion = tech_data.completion,
                tier = tech_data.tier,
                available = tech_data.available,
                bar_width = (tech_data.completion / 100) * 250
            })
        end
    end

    self.visible_panels.alien_research = panel
    return panel
end

---
-- Display base status panel
-- @param expansion_system: BaseExpansionSystem instance
-- @param x, y: Panel position
function UIIntegrationLayer:displayBaseStatusPanel(expansion_system, x, y)
    if not expansion_system then return end

    x = x or 320
    y = y or 100

    local status = expansion_system:getBaseStatus()

    local panel = {
        title = "Base Status",
        position = { x = x, y = y },
        width = 250,
        height = 350,
        metrics = {
            {
                label = "Grid Size",
                value = status.grid_size .. "x",
                display = "Size " .. (10 + (status.grid_size - 1) * 5) .. "x" ..
                                      (10 + (status.grid_size - 1) * 5)
            },
            {
                label = "Hangar Slots",
                value = status.hangar_slots,
                capacity = true
            },
            {
                label = "Barracks",
                value = status.barracks_capacity,
                capacity = true
            },
            {
                label = "Workshop",
                value = status.workshop_capacity,
                capacity = true
            },
            {
                label = "Laboratory",
                value = status.laboratory_capacity,
                capacity = true
            },
            {
                label = "Defense",
                value = string.format("%.1f×", status.defense_rating),
                bar = true,
                bar_value = math.min(status.defense_rating, 3.0)
            },
            {
                label = "Vulnerability",
                value = string.format("%.1f%%", status.supply_vulnerability * 100),
                bar = true,
                bar_value = status.supply_vulnerability,
                color = "red"
            }
        }
    }

    self.visible_panels.base_status = panel
    return panel
end

---
-- Display faction standings panel
-- @param faction_system: FactionDynamicsSystem instance
-- @param x, y: Panel position
function UIIntegrationLayer:displayFactionsPanel(faction_system, x, y)
    if not faction_system then return end

    x = x or 630
    y = y or 100

    local standings = faction_system:getFactionStandings()
    local demands = faction_system.faction_demands or {}

    local panel = {
        title = "International Relations",
        position = { x = x, y = y },
        width = 280,
        height = 400,
        council_pressure = faction_system.council_pressure or 0,
        factions = {}
    }

    for faction_id, faction_data in pairs(standings) do
        if faction_data then
            local color = "green"
            if faction_data.standing < -40 then
                color = "red"
            elseif faction_data.standing < 0 then
                color = "orange"
            elseif faction_data.standing < 50 then
                color = "yellow"
            end

            table.insert(panel.factions, {
                name = faction_data.name,
                standing = faction_data.standing,
                status = faction_data.status,
                color = color,
                bar_value = (faction_data.standing + 100) / 200,
                influence = faction_data.influence
            })
        end
    end

    panel.council_demands = demands

    self.visible_panels.factions = panel
    return panel
end

---
-- Display campaign events panel
-- @param events_system: CampaignEventsSystem instance
-- @param x, y: Panel position
function UIIntegrationLayer:displayEventsPanel(events_system, x, y)
    if not events_system then return end

    x = x or 10
    y = y or 520

    local active_events = events_system:getActiveEvents()
    local stats = events_system:getEventStatistics()

    local panel = {
        title = "Campaign Events",
        position = { x = x, y = y },
        width = 900,
        height = 240,
        active_events = {},
        stats = {
            total_triggered = stats.total_events_triggered,
            active = stats.active_events,
            resolved = stats.resolved_events
        }
    }

    for i, event in ipairs(active_events) do
        if i <= 8 then  -- Display max 8 events
            table.insert(panel.active_events, {
                name = event.name,
                tier = event.tier,
                description = event.description,
                time_active = event.time_active,
                complications = event.complications
            })
        end
    end

    self.visible_panels.events = panel
    return panel
end

---
-- Display difficulty/morale panel
-- @param difficulty_system: DifficultyRefinementsSystem instance
-- @param x, y: Panel position
function UIIntegrationLayer:displayDifficultyPanel(difficulty_system, x, y)
    if not difficulty_system then return end

    x = x or 10
    y = y or 50

    local morale = difficulty_system:getMoraleEffects()
    local leader = difficulty_system:getAlienLeaderStatus()

    local panel = {
        title = "Combat Difficulty",
        position = { x = x, y = y },
        width = 280,
        height = 380,
        tactical_depth = difficulty_system.tactical_depth,
        psychological_pressure = difficulty_system.psychological_pressure,
        morale_effects = {
            accuracy_penalty = string.format("%.0f%%", morale.accuracy_penalty * 100),
            damage_penalty = string.format("%.0f%%", morale.damage_penalty * 100),
            armor_penalty = string.format("%.0f%%", morale.armor_penalty * 100),
            panic_chance = string.format("%.0f%%", morale.panic_chance * 100)
        },
        alien_leader = leader,
        difficulty_modifier = string.format("%.2f×", difficulty_system:getTacticalDifficultyModifier())
    }

    self.visible_panels.difficulty = panel
    return panel
end

---
-- Show notification popup
-- @param title: Notification title
-- @param message: Notification message
-- @param notification_type: "info", "warning", "alert", "success"
-- @param duration: Display duration in seconds
function UIIntegrationLayer:showNotification(title, message, notification_type, duration)
    notification_type = notification_type or "info"
    duration = duration or 5

    local notification = {
        title = title,
        message = message,
        type = notification_type,
        created_at = os.time(),
        duration = duration,
        visible = true
    }

    table.insert(self.notifications, notification)
    return notification
end

---
-- Update notification display states
function UIIntegrationLayer:updateNotifications()
    local current_time = os.time()

    for i = #self.notifications, 1, -1 do
        local notif = self.notifications[i]
        if notif then
            local elapsed = current_time - (notif.created_at or current_time)
            if elapsed > (notif.duration or 5) then
                table.remove(self.notifications, i)
            end
        end
    end
end

---
-- Get all visible UI panels
-- @return: Table of visible panels
function UIIntegrationLayer:getVisiblePanels()
    return self.visible_panels
end

---
-- Get current notifications
-- @return: Table of notifications
function UIIntegrationLayer:getNotifications()
    return self.notifications
end

---
-- Clear all UI overlays
function UIIntegrationLayer:clearOverlays()
    self.visible_panels = {}
    self.overlay_stack = {}
end

---
-- Serialize UI state for save game
-- @return: Serializable UI data
function UIIntegrationLayer:serialize()
    return {
        visible_panels = self.visible_panels,
        notifications = self.notifications
    }
end

---
-- Deserialize UI state from save game
-- @param data: Serialized UI data
function UIIntegrationLayer:deserialize(data)
    if not data then return end

    self.visible_panels = data.visible_panels or {}
    self.notifications = data.notifications or {}
end

return UIIntegrationLayer
