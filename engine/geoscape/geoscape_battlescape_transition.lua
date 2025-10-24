--- Geoscape to Battlescape Transition System
-- Manages state transfer between geoscape and battlescape
-- Passes mission data, squad, craft, and handles return/outcomes
--
-- @module geoscape_battlescape_transition
-- @author AlienFall Team
-- @license MIT

local GeoscapeBattlescapeTransition = {}

--- Initialize transition system
-- @param deployment_integration DeploymentIntegration instance
-- @param campaign_integration CampaignGeoscapeIntegration instance
function GeoscapeBattlescapeTransition:initialize(deployment_integration, campaign_integration)
    print("[GeoscapeBattlescapeTransition] Initializing...")

    self.deployment_integration = deployment_integration or error("deployment_integration required")
    self.campaign_integration = campaign_integration or error("campaign_integration required")

    self.active_mission = nil
    self.deployment_timestamp = nil

    print("[GeoscapeBattlescapeTransition] Initialized")
    return self
end

--- Prepare transition to battlescape
-- @return boolean success, table battlescape_config or string error
function GeoscapeBattlescapeTransition:prepareTransition()
    print("[GeoscapeBattlescapeTransition] Preparing transition to battlescape...")

    -- Get deployment config
    local config = self.deployment_integration:prepareDeploymentConfig()

    if not config then
        print("[GeoscapeBattlescapeTransition] Failed to prepare deployment config")
        return false, "Deployment validation failed"
    end

    -- Store active mission for return
    self.active_mission = config
    self.deployment_timestamp = os.time()

    print("[GeoscapeBattlescapeTransition] Transition prepared successfully")
    return true, config
end

--- Get transition config for battlescape
-- @return table battlescape configuration with all mission/squad/craft data
function GeoscapeBattlescapeTransition:getTransitionConfig()
    if not self.active_mission then return nil end

    return self.active_mission
end

--- Transition to battlescape
-- @param state_manager main state manager instance
-- @param battlescape_screen battlescape screen instance
-- @return boolean success
function GeoscapeBattlescapeTransition:transitionToBattlescape(state_manager, battlescape_screen)
    print("[GeoscapeBattlescapeTransition] Transitioning to battlescape...")

    local success, config = self:prepareTransition()

    if not success then
        print("[GeoscapeBattlescapeTransition] Failed to prepare transition")
        return false
    end

    -- Pass config to battlescape screen
    if battlescape_screen and battlescape_screen.setMissionConfig then
        battlescape_screen:setMissionConfig(config)
    end

    -- Request state change (to be handled by state manager)
    if state_manager and state_manager.requestStateChange then
        state_manager:requestStateChange("battlescape", config)
    end

    print("[GeoscapeBattlescapeTransition] Transition initiated")
    return true
end

--- Return from battlescape mission
-- @param outcome string "VICTORY", "DEFEAT", or "RETREAT"
-- @param mission_results table with combat results
-- @return boolean success
function GeoscapeBattlescapeTransition:returnFromBattlescape(outcome, mission_results)
    print("[GeoscapeBattlescapeTransition] Returning from battlescape with outcome: " .. outcome)

    if not self.active_mission then
        print("[GeoscapeBattlescapeTransition] No active mission to return from")
        return false
    end

    local mission_id = self.active_mission.mission and self.active_mission.mission.id or nil

    if not mission_id then
        print("[GeoscapeBattlescapeTransition] Mission ID not found")
        return false
    end

    -- Record outcome with campaign integration
    local success = self.campaign_integration:recordMissionOutcome(mission_id, outcome, mission_results)

    if success then
        print("[GeoscapeBattlescapeTransition] Mission outcome recorded")

        -- Process results
        self:_processMissionResults(outcome, mission_results)

        -- Clear active mission
        self.active_mission = nil
        self.deployment_timestamp = nil

        return true
    else
        print("[GeoscapeBattlescapeTransition] Failed to record mission outcome")
        return false
    end
end

--- Process mission results and apply to campaign
-- @param outcome string mission outcome
-- @param results table combat results
function GeoscapeBattlescapeTransition:_processMissionResults(outcome, results)
    print("[GeoscapeBattlescapeTransition] Processing mission results...")

    results = results or {}

    -- Extract data
    local player_kills = results.player_kills or 0
    local player_losses = results.player_losses or 0
    local enemy_kills = results.enemy_kills or 0
    local salvage = results.salvage or {}
    local mission_score = results.mission_score or 0

    print("[GeoscapeBattlescapeTransition] Mission results: " ..
          "Kills=" .. player_kills ..
          ", Losses=" .. player_losses ..
          ", Score=" .. mission_score)

    -- Results will be handled by campaign manager when outcome is recorded
    -- This includes updating base, units, inventory, etc.
end

--- Get active mission ID
-- @return string mission ID or nil
function GeoscapeBattlescapeTransition:getActiveMissionId()
    if not self.active_mission or not self.active_mission.mission then
        return nil
    end

    return self.active_mission.mission.id
end

--- Get mission deployment time
-- @return number unix timestamp of deployment
function GeoscapeBattlescapeTransition:getDeploymentTime()
    return self.deployment_timestamp
end

--- Check if mission is active
-- @return boolean true if in battlescape
function GeoscapeBattlescapeTransition:isMissionActive()
    return self.active_mission ~= nil
end

--- Get squad for current mission
-- @return table squad configuration
function GeoscapeBattlescapeTransition:getActiveSquad()
    if not self.active_mission or not self.active_mission.squad then
        return {}
    end

    return self.active_mission.squad
end

--- Get craft for current mission
-- @return string craft ID
function GeoscapeBattlescapeTransition:getActiveCraft()
    if not self.active_mission then
        return nil
    end

    return self.active_mission.craft
end

--- Get mission briefing data
-- @return table mission briefing with objectives, enemies, rewards
function GeoscapeBattlescapeTransition:getMissionBriefing()
    if not self.active_mission or not self.active_mission.mission then
        return nil
    end

    local mission = self.active_mission.mission

    return {
        name = mission.name or "Unknown Mission",
        description = mission.description or "No description",
        objectives = mission.objectives or {},
        enemy_intel = mission.enemies or {},
        threat_level = mission.threat_level or 5,
        reward = mission.reward or 0,
        location = mission.location or "Unknown",
        mission_type = mission.mission_type or "STANDARD",
    }
end

--- Validate transition readiness
-- @return boolean is_ready, string error_message
function GeoscapeBattlescapeTransition:validateTransitionReadiness()
    print("[GeoscapeBattlescapeTransition] Validating transition readiness...")

    if not self.deployment_integration then
        return false, "Deployment integration not initialized"
    end

    local is_valid, error_msg = self.deployment_integration:validateDeployment()

    if not is_valid then
        return false, error_msg
    end

    print("[GeoscapeBattlescapeTransition] Validation passed")
    return true
end

--- Abort transition and return to geoscape
-- @return boolean success
function GeoscapeBattlescapeTransition:abortTransition()
    print("[GeoscapeBattlescapeTransition] Aborting transition...")

    -- Clear pending transition
    self.active_mission = nil
    self.deployment_timestamp = nil

    print("[GeoscapeBattlescapeTransition] Transition aborted")
    return true
end

--- Get transition status
-- @return table status information
function GeoscapeBattlescapeTransition:getStatus()
    return {
        is_mission_active = self.active_mission ~= nil,
        mission_id = self:getActiveMissionId(),
        deployment_time = self.deployment_timestamp,
        squad_size = #(self.active_mission and self.active_mission.squad or {}),
        craft = self:getActiveCraft(),
    }
end

--- Serialize transition state
-- @return table serialized state
function GeoscapeBattlescapeTransition:serialize()
    return {
        active_mission = self.active_mission,
        deployment_timestamp = self.deployment_timestamp,
    }
end

--- Deserialize transition state
-- @param data table serialized state
function GeoscapeBattlescapeTransition:deserialize(data)
    if not data then return end

    self.active_mission = data.active_mission
    self.deployment_timestamp = data.deployment_timestamp

    print("[GeoscapeBattlescapeTransition] State restored")
end

return GeoscapeBattlescapeTransition
