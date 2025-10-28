--- Campaign-Geoscape System Integration
-- Bridges CampaignManager and geoscape rendering systems
-- Loads mission data, craft data, threat levels into geoscape UI components
-- Synchronizes turn advancement between campaign and geoscape
--
-- @module campaign_geoscape_integration
-- @author AlienFall Team
-- @license MIT

local CampaignGeoscapeIntegration = {}

--- Initialize integration with all system references
-- @param campaign_manager CampaignManager instance
-- @param geoscape_state GeoscapeState instance
-- @param calendar Calendar instance (from geoscape)
-- @param turn_advancer TurnAdvancer instance
function CampaignGeoscapeIntegration:initialize(campaign_manager, geoscape_state, calendar, turn_advancer)
    print("[CampaignGeoscapeIntegration] Initializing integration...")

    self.campaign_manager = campaign_manager or error("campaign_manager required")
    self.geoscape_state = geoscape_state or error("geoscape_state required")
    self.calendar = calendar or error("calendar required")
    self.turn_advancer = turn_advancer or error("turn_advancer required")

    self.current_mission = nil
    self.selected_mission_id = nil

    -- Register callbacks for synchronization
    self:_registerCallbacks()

    print("[CampaignGeoscapeIntegration] Integration initialized successfully")
    return self
end

--- Register callbacks to sync systems
function CampaignGeoscapeIntegration:_registerCallbacks()
    print("[CampaignGeoscapeIntegration] Registering callbacks...")

    -- When campaign advances turn, update geoscape
    if self.turn_advancer then
        self.turn_advancer:registerPostTurnCallback(function()
            self:_syncCampaignToGeoscape()
        end)
    end
end

--- Load missions from campaign into geoscape mission panel
-- @return table of mission_data for MissionFactionPanel
function CampaignGeoscapeIntegration:loadActiveMissions()
    print("[CampaignGeoscapeIntegration] Loading active missions...")

    if not self.campaign_manager then return {} end

    local missions = {}

    -- Get active missions from campaign
    local campaign_missions = self.campaign_manager:getActiveMissions() or {}

    for i, mission in ipairs(campaign_missions) do
        if i > 10 then break end  -- Max 10 visible missions

        table.insert(missions, {
            id = mission.id,
            name = mission.name or ("Mission " .. mission.id),
            description = mission.description or "Unknown mission",
            threat_level = mission.threat_level or 1,
            location = mission.location or "Unknown",
            turns_remaining = mission.turns_remaining or 0,
            faction = mission.faction or "Unknown",
            mission_type = mission.mission_type or "UNKNOWN",
            reward = mission.reward or 0,
        })
    end

    print("[CampaignGeoscapeIntegration] Loaded " .. #missions .. " active missions")
    return missions
end

--- Load crafts from base into geoscape craft indicators
-- @return table of craft_data for CraftIndicators
function CampaignGeoscapeIntegration:loadPlayerCrafts()
    print("[CampaignGeoscapeIntegration] Loading player crafts...")

    if not self.campaign_manager then return {} end

    local crafts = {}

    -- Get player bases
    local bases = self.campaign_manager:getPlayerBases() or {}

    for _, base in ipairs(bases) do
        if base.crafts then
            for _, craft in ipairs(base.crafts) do
                table.insert(crafts, {
                    id = craft.id,
                    name = craft.name or "Unknown Craft",
                    type = craft.type or "GENERIC",
                    position = craft.position or {x = 0, y = 0},
                    hp = craft.hp or 100,
                    max_hp = craft.max_hp or 100,
                    status = craft.status or "READY",
                    team = "PLAYER",
                })
            end
        end
    end

    print("[CampaignGeoscapeIntegration] Loaded " .. #crafts .. " player crafts")
    return crafts
end

--- Load detected UFOs into geoscape craft indicators
-- @return table of ufo_data for CraftIndicators
function CampaignGeoscapeIntegration:loadDetectedUFOs()
    print("[CampaignGeoscapeIntegration] Loading detected UFOs...")

    if not self.campaign_manager then return {} end

    local ufos = {}

    -- Get detected UFOs from radar/sensor system
    local detected = self.campaign_manager:getDetectedUFOs() or {}

    for _, ufo in ipairs(detected) do
        table.insert(ufos, {
            id = ufo.id,
            name = ufo.name or "UFO Contact",
            type = ufo.type or "SCOUT",
            position = ufo.position or {x = 0, y = 0},
            hp = ufo.hp or 50,
            max_hp = ufo.max_hp or 50,
            status = ufo.status or "ACTIVE",
            team = "ENEMY",
        })
    end

    print("[CampaignGeoscapeIntegration] Loaded " .. #ufos .. " detected UFOs")
    return ufos
end

--- Load base locations into geoscape craft indicators
-- @return table of base_data for CraftIndicators
function CampaignGeoscapeIntegration:loadPlayerBases()
    print("[CampaignGeoscapeIntegration] Loading player bases...")

    if not self.campaign_manager then return {} end

    local bases = {}

    -- Get player bases with full stats
    local player_bases = self.campaign_manager:getPlayerBases() or {}

    for _, base in ipairs(player_bases) do
        table.insert(bases, {
            id = base.id,
            name = base.name or "Base",
            type = "BASE",
            position = base.position or {x = 0, y = 0},
            hp = 100,  -- Bases are fixed
            max_hp = 100,
            status = base.status or "OPERATIONAL",
            team = "PLAYER",
            facility_count = base.facility_count or 5,
        })
    end

    print("[CampaignGeoscapeIntegration] Loaded " .. #bases .. " player bases")
    return bases
end

--- Update geoscape UI with current campaign data
function CampaignGeoscapeIntegration:_syncCampaignToGeoscape()
    print("[CampaignGeoscapeIntegration] Syncing campaign data to geoscape...")

    if not self.geoscape_state then return end

    -- Update missions
    local missions = self:loadActiveMissions()
    if self.geoscape_state.mission_panel then
        self.geoscape_state.mission_panel:setMissions(missions)
    end

    -- Update craft indicators (player crafts)
    local crafts = self:loadPlayerCrafts()
    if self.geoscape_state.craft_indicators then
        self.geoscape_state.craft_indicators:setPlayerCrafts(crafts)
    end

    -- Update UFO indicators
    local ufos = self:loadDetectedUFOs()
    if self.geoscape_state.craft_indicators then
        self.geoscape_state.craft_indicators:setEnemyUnits(ufos)
    end

    -- Update base indicators
    local bases = self:loadPlayerBases()
    if self.geoscape_state.craft_indicators then
        self.geoscape_state.craft_indicators:setBases(bases)
    end

    print("[CampaignGeoscapeIntegration] Sync complete")
end

--- Get threat level from campaign
-- @return number threat level (0-10)
function CampaignGeoscapeIntegration:getThreatLevel()
    if not self.campaign_manager then return 5 end
    return self.campaign_manager:getThreatLevel() or 5
end

--- Get current campaign day/turn
-- @return number current_day
function CampaignGeoscapeIntegration:getCurrentDay()
    if not self.calendar then return 1 end
    return self.calendar:getTurnNumber() or 1
end

--- Accept a mission (change its status in campaign)
-- @param mission_id string unique mission identifier
-- @return boolean success
function CampaignGeoscapeIntegration:acceptMission(mission_id)
    print("[CampaignGeoscapeIntegration] Accepting mission: " .. tostring(mission_id))

    if not self.campaign_manager then return false end

    self.selected_mission_id = mission_id
    local success = self.campaign_manager:startMission(mission_id)

    if success then
        print("[CampaignGeoscapeIntegration] Mission accepted successfully")
    else
        print("[CampaignGeoscapeIntegration] Failed to accept mission")
    end

    return success
end

--- Get currently selected mission details
-- @return table mission data with all details
function CampaignGeoscapeIntegration:getSelectedMissionDetails()
    if not self.selected_mission_id or not self.campaign_manager then
        return nil
    end

    return self.campaign_manager:getMission(self.selected_mission_id)
end

--- Decline a mission (remove from active list)
-- @param mission_id string unique mission identifier
-- @return boolean success
function CampaignGeoscapeIntegration:declineMission(mission_id)
    print("[CampaignGeoscapeIntegration] Declining mission: " .. tostring(mission_id))

    if not self.campaign_manager then return false end

    local success = self.campaign_manager:declineMission(mission_id)

    if success then
        print("[CampaignGeoscapeIntegration] Mission declined")
    end

    return success
end

--- Delay a mission (keep active, mark for later)
-- @param mission_id string unique mission identifier
-- @param delay_days number days to delay
-- @return boolean success
function CampaignGeoscapeIntegration:delayMission(mission_id, delay_days)
    print("[CampaignGeoscapeIntegration] Delaying mission: " .. tostring(mission_id) .. " by " .. delay_days .. " days")

    if not self.campaign_manager then return false end

    delay_days = delay_days or 3
    local success = self.campaign_manager:delayMission(mission_id, delay_days)

    if success then
        print("[CampaignGeoscapeIntegration] Mission delayed")
    end

    return success
end

--- Prepare mission for deployment (generate battlescape data)
-- @param mission_id string unique mission identifier
-- @return table battlescape_config with all mission details
function CampaignGeoscapeIntegration:prepareMissionDeployment(mission_id)
    print("[CampaignGeoscapeIntegration] Preparing mission deployment: " .. tostring(mission_id))

    if not self.campaign_manager then return nil end

    local mission = self.campaign_manager:getMission(mission_id)
    if not mission then
        print("[CampaignGeoscapeIntegration] Mission not found")
        return nil
    end

    -- Create battlescape configuration
    local config = {
        mission_id = mission_id,
        mission_name = mission.name or "Unknown Mission",
        mission_type = mission.mission_type or "STANDARD",
        location = mission.location or "Unknown",
        biome = mission.biome or "PLAINS",
        map_size = mission.map_size or "MEDIUM",
        threat_level = mission.threat_level or 1,

        -- Deployment info
        landing_zones = mission.landing_zones or {{x = 0, y = 0}},
        objectives = mission.objectives or {
            {type = "KILL_ALL", description = "Eliminate all alien forces"}
        },

        -- Enemy data
        enemies = mission.enemies or {},
        enemy_reinforcements = mission.enemy_reinforcements or {},

        -- Rewards
        reward = mission.reward or 0,
        intel_reward = mission.intel_reward or 0,

        -- Campaign context
        difficulty = mission.difficulty or 1,
        modifiers = mission.modifiers or {},
    }

    print("[CampaignGeoscapeIntegration] Mission deployment config prepared")
    return config
end

--- Record mission outcome back to campaign
-- @param mission_id string mission identifier
-- @param outcome string "VICTORY", "DEFEAT", or "RETREAT"
-- @param data table with mission results (kills, losses, salvage, etc)
-- @return boolean success
function CampaignGeoscapeIntegration:recordMissionOutcome(mission_id, outcome, data)
    print("[CampaignGeoscapeIntegration] Recording mission outcome: " .. outcome)

    if not self.campaign_manager then return false end

    data = data or {}

    local success = self.campaign_manager:completeMission(mission_id, outcome, data)

    if success then
        print("[CampaignGeoscapeIntegration] Mission outcome recorded")
        -- Trigger sync to update geoscape
        self:_syncCampaignToGeoscape()
    end

    return success
end

--- Advance campaign by one turn (day)
-- @return boolean success
function CampaignGeoscapeIntegration:advanceCampaignDay()
    print("[CampaignGeoscapeIntegration] Advancing campaign day...")

    if not self.campaign_manager then return false end

    local success = self.campaign_manager:advanceTurn()

    if success then
        print("[CampaignGeoscapeIntegration] Campaign day advanced")
    end

    return success
end

--- Get campaign statistics
-- @return table stats (days_elapsed, missions_completed, aliens_killed, etc)
function CampaignGeoscapeIntegration:getCampaignStats()
    if not self.campaign_manager then return {} end
    return self.campaign_manager:getStats() or {}
end

--- Serialize integration state
-- @return table serialized state
function CampaignGeoscapeIntegration:serialize()
    return {
        selected_mission_id = self.selected_mission_id,
        current_mission = self.current_mission,
    }
end

--- Deserialize integration state
-- @param data table serialized state
function CampaignGeoscapeIntegration:deserialize(data)
    if not data then return end

    self.selected_mission_id = data.selected_mission_id
    self.current_mission = data.current_mission

    print("[CampaignGeoscapeIntegration] Integration state restored")
end

return CampaignGeoscapeIntegration

