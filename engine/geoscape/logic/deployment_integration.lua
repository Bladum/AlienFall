--- Deployment Screen Integration for Geoscape
-- Connects deployment screen to campaign/mission data
-- Loads squad from base, manages unit selection, equipment, crafts
-- Transitions to battlescape with complete mission config
--
-- @module deployment_integration
-- @author AlienFall Team
-- @license MIT

local DeploymentIntegration = {}

--- Initialize deployment integration
-- @param campaign_manager CampaignManager instance
-- @param integration CampaignGeoscapeIntegration instance
function DeploymentIntegration:initialize(campaign_manager, integration)
    print("[DeploymentIntegration] Initializing...")

    self.campaign_manager = campaign_manager or error("campaign_manager required")
    self.integration = integration or error("integration required")

    self.current_mission = nil
    self.selected_squad = {}
    self.selected_craft = nil
    self.loadouts = {}  -- Per-unit equipment

    print("[DeploymentIntegration] Initialized")
    return self
end

--- Load mission data for deployment
-- @param mission_id string mission identifier
-- @return table mission configuration with all details
function DeploymentIntegration:loadMissionForDeployment(mission_id)
    print("[DeploymentIntegration] Loading mission for deployment: " .. tostring(mission_id))

    local config = self.integration:prepareMissionDeployment(mission_id)

    if config then
        self.current_mission = config
        print("[DeploymentIntegration] Mission loaded successfully")
    else
        print("[DeploymentIntegration] Failed to load mission")
    end

    return config
end

--- Get available units from base
-- @return table of unit data (id, name, rank, class, hp, status)
function DeploymentIntegration:getAvailableUnits()
    print("[DeploymentIntegration] Fetching available units...")

    if not self.campaign_manager then return {} end

    local units = {}

    -- Get player bases
    local bases = self.campaign_manager:getPlayerBases() or {}

    for _, base in ipairs(bases) do
        if base.units then
            for _, unit in ipairs(base.units) do
                -- Only include units that are ready to deploy
                if unit.status == "READY" or unit.status == "HEALTHY" then
                    table.insert(units, {
                        id = unit.id,
                        name = unit.name or "Unknown",
                        rank = unit.rank or "Rookie",
                        class = unit.class or "SOLDIER",
                        hp = unit.hp or 100,
                        max_hp = unit.max_hp or 100,
                        status = unit.status or "READY",
                        xp = unit.xp or 0,
                        base_id = base.id,
                    })
                end
            end
        end
    end

    print("[DeploymentIntegration] Found " .. #units .. " available units")
    return units
end

--- Get available crafts from bases
-- @return table of craft data (id, name, type, capacity, status, fuel, range)
function DeploymentIntegration:getAvailableCrafts()
    print("[DeploymentIntegration] Fetching available crafts...")

    if not self.campaign_manager then return {} end

    local crafts = {}

    local bases = self.campaign_manager:getPlayerBases() or {}

    for _, base in ipairs(bases) do
        if base.crafts then
            for _, craft in ipairs(base.crafts) do
                -- Only include operational crafts
                if craft.status == "READY" or craft.status == "OPERATIONAL" then
                    local range = self:_calculateCraftRange(craft)

                    table.insert(crafts, {
                        id = craft.id,
                        name = craft.name or "Unknown Craft",
                        type = craft.type or "GENERIC",
                        capacity = craft.capacity or 12,
                        status = craft.status or "READY",
                        fuel = craft.fuel or 100,
                        max_fuel = craft.max_fuel or 100,
                        range = range,
                        armor = craft.armor or 50,
                        weapons = craft.weapons or {},
                    })
                end
            end
        end
    end

    print("[DeploymentIntegration] Found " .. #crafts .. " available crafts")
    return crafts
end

--- Calculate craft range based on fuel
-- @param craft table craft data
-- @return number range in tiles
function DeploymentIntegration:_calculateCraftRange(craft)
    local fuel_ratio = (craft.fuel or 100) / (craft.max_fuel or 100)
    local base_range = craft.type == "SKYRANGER" and 50 or
                       craft.type == "LIGHTNING" and 100 or
                       craft.type == "AVENGER" and 80 or 60

    return math.floor(base_range * fuel_ratio)
end

--- Select unit for squad
-- @param unit_id string unit identifier
-- @return boolean success
function DeploymentIntegration:selectUnit(unit_id)
    print("[DeploymentIntegration] Selecting unit: " .. tostring(unit_id))

    -- Check squad capacity
    if #self.selected_squad >= 12 then
        print("[DeploymentIntegration] Squad is full")
        return false
    end

    -- Prevent duplicates
    for _, uid in ipairs(self.selected_squad) do
        if uid == unit_id then
            print("[DeploymentIntegration] Unit already selected")
            return false
        end
    end

    table.insert(self.selected_squad, unit_id)
    self.loadouts[unit_id] = {}  -- Initialize loadout for unit

    print("[DeploymentIntegration] Unit selected, squad size: " .. #self.selected_squad)
    return true
end

--- Remove unit from squad
-- @param unit_id string unit identifier
-- @return boolean success
function DeploymentIntegration:removeUnit(unit_id)
    print("[DeploymentIntegration] Removing unit: " .. tostring(unit_id))

    for i, uid in ipairs(self.selected_squad) do
        if uid == unit_id then
            table.remove(self.selected_squad, i)
            self.loadouts[unit_id] = nil
            print("[DeploymentIntegration] Unit removed, squad size: " .. #self.selected_squad)
            return true
        end
    end

    return false
end

--- Select craft for mission
-- @param craft_id string craft identifier
-- @return boolean success
function DeploymentIntegration:selectCraft(craft_id)
    print("[DeploymentIntegration] Selecting craft: " .. tostring(craft_id))

    self.selected_craft = craft_id
    print("[DeploymentIntegration] Craft selected")
    return true
end

--- Get selected squad
-- @return table of unit IDs
function DeploymentIntegration:getSelectedSquad()
    return self.selected_squad
end

--- Get selected craft ID
-- @return string craft ID or nil
function DeploymentIntegration:getSelectedCraft()
    return self.selected_craft
end

--- Get squad capacity status
-- @return table {current = number, max = number}
function DeploymentIntegration:getSquadCapacity()
    return {
        current = #self.selected_squad,
        max = 12,
    }
end

--- Set unit loadout (equipment)
-- @param unit_id string unit identifier
-- @param equipment table equipment configuration
function DeploymentIntegration:setUnitLoadout(unit_id, equipment)
    if not self.loadouts[unit_id] then
        self.loadouts[unit_id] = {}
    end

    self.loadouts[unit_id] = equipment or {}
    print("[DeploymentIntegration] Loadout set for unit: " .. tostring(unit_id))
end

--- Get unit loadout
-- @param unit_id string unit identifier
-- @return table equipment configuration
function DeploymentIntegration:getUnitLoadout(unit_id)
    return self.loadouts[unit_id] or {}
end

--- Validate deployment (check squad size, craft, equipment)
-- @return boolean is_valid, string error_message
function DeploymentIntegration:validateDeployment()
    print("[DeploymentIntegration] Validating deployment...")

    -- Check squad size
    if #self.selected_squad == 0 then
        return false, "Squad is empty"
    end

    if #self.selected_squad > 12 then
        return false, "Squad exceeds maximum capacity"
    end

    -- Check craft
    if not self.selected_craft then
        return false, "No craft selected"
    end

    -- Check mission
    if not self.current_mission then
        return false, "No mission loaded"
    end

    print("[DeploymentIntegration] Validation passed")
    return true
end

--- Prepare deployment config for battlescape
-- @return table complete deployment configuration
function DeploymentIntegration:prepareDeploymentConfig()
    print("[DeploymentIntegration] Preparing deployment config...")

    local is_valid, error_msg = self:validateDeployment()
    if not is_valid then
        print("[DeploymentIntegration] Validation failed: " .. error_msg)
        return nil
    end

    -- Build config
    local config = {
        mission = self.current_mission,
        squad = {},
        craft = self.selected_craft,
        timestamp = os.time(),
    }

    -- Add squad with loadouts
    for _, unit_id in ipairs(self.selected_squad) do
        table.insert(config.squad, {
            unit_id = unit_id,
            loadout = self.loadouts[unit_id] or {},
        })
    end

    print("[DeploymentIntegration] Deployment config prepared with " .. #config.squad .. " units")
    return config
end

--- Get deployment summary for display
-- @return table summary with counts and details
function DeploymentIntegration:getDeploymentSummary()
    return {
        squad_size = #self.selected_squad,
        squad_max = 12,
        craft_selected = self.selected_craft ~= nil,
        mission_loaded = self.current_mission ~= nil,
        total_weight = self:_calculateTotalWeight(),
        estimated_threat = self.current_mission and self.current_mission.threat_level or 0,
    }
end

--- Calculate total squad weight
-- @return number total weight in kg
function DeploymentIntegration:_calculateTotalWeight()
    local total = 0

    for _, unit_id in ipairs(self.selected_squad) do
        local loadout = self.loadouts[unit_id] or {}
        total = total + (loadout.weight or 0)
    end

    return total
end

--- Get deployment timeline (turns until mission expires)
-- @return number turns remaining, or nil if no mission
function DeploymentIntegration:getDeploymentTimeline()
    if not self.current_mission then return nil end
    return self.current_mission.turns_remaining or 0
end

--- Start deployment (transition to battlescape)
-- @return boolean success, string error_message
function DeploymentIntegration:startDeployment()
    print("[DeploymentIntegration] Starting deployment...")

    local config = self:prepareDeploymentConfig()

    if not config then
        print("[DeploymentIntegration] Failed to prepare deployment config")
        return false, "Deployment validation failed"
    end

    print("[DeploymentIntegration] Deployment config ready, transitioning to battlescape...")

    -- TODO: Trigger transition to battlescape with config
    -- This would be handled by the main state manager

    return true
end

--- Serialize deployment state
-- @return table serialized state
function DeploymentIntegration:serialize()
    return {
        current_mission = self.current_mission,
        selected_squad = self.selected_squad,
        selected_craft = self.selected_craft,
        loadouts = self.loadouts,
    }
end

--- Deserialize deployment state
-- @param data table serialized state
function DeploymentIntegration:deserialize(data)
    if not data then return end

    self.current_mission = data.current_mission
    self.selected_squad = data.selected_squad or {}
    self.selected_craft = data.selected_craft
    self.loadouts = data.loadouts or {}

    print("[DeploymentIntegration] State restored")
end

return DeploymentIntegration

