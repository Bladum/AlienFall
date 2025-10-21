---DeploymentScene - Scene manager for mission deployment planning
---
---Manages the deployment planning phase where players:
---  1. View the mission map with landing zones
---  2. Select and assign units to landing zones
---  3. Confirm deployment and transition to battlescape
---
---State machine:
---  - SETUP: Initialize deployment data
---  - LZ_PREVIEW: Show map and landing zones  
---  - UNIT_ASSIGNMENT: Allow unit-to-LZ assignment
---  - REVIEW: Summary before starting
---  - DEPLOYING: Transition to battlescape
---
---@module battlescape.scenes.deployment_scene
---@author AlienFall Development Team

local DeploymentConfig = require("battlescape.logic.deployment_config")
local LandingZoneSelector = require("battlescape.logic.landing_zone_selector")
local MapBlockMetadata = require("battlescape.map.mapblock_metadata")
local LandingZonePreviewUI = require("battlescape.ui.landing_zone_preview_ui")
local UnitDeploymentUI = require("battlescape.ui.unit_deployment_ui")

local DeploymentScene = {}

-- Scene states
DeploymentScene.STATES = {
    SETUP = "setup",
    LZ_PREVIEW = "lz_preview",
    UNIT_ASSIGNMENT = "unit_assignment",
    REVIEW = "review",
    DEPLOYING = "deploying",
    CANCELLED = "cancelled"
}

-- Default configuration
local DEFAULT_CONFIG = {
    showMapPreview = true,
    allowUnitReassignment = true,
    confirmationRequired = true,
    spawnPointCount = 3,  -- Per landing zone
}

---Initialize deployment scene with mission data
---@param missionData table Mission data {missionId, mapSize, units, objectives}
---@param config table Optional config options
---@return table DeploymentScene instance
function DeploymentScene.create(missionData, config)
    config = config or {}
    
    local self = setmetatable({}, {__index = DeploymentScene})
    
    self.state = DeploymentScene.STATES.SETUP
    self.missionData = missionData
    self.config = setmetatable(config, {__index = DEFAULT_CONFIG})
    
    -- Deployment configuration
    self.deploymentConfig = DeploymentConfig.new({
        missionId = missionData.missionId,
        mapSize = missionData.mapSize,
        mapBlockGrid = self:_getGridSize(missionData.mapSize),
        availableUnits = missionData.units or {},
    })
    
    -- Callbacks
    self.onDeploymentComplete = nil
    self.onDeploymentCancelled = nil
    
    print(string.format(
        "[DeploymentScene] Created for mission %s (map: %s, units: %d)",
        missionData.missionId,
        missionData.mapSize,
        #missionData.units
    ))
    
    return self
end

---Get grid size from map size string
---@param mapSize string Map size ("small", "medium", "large", "huge")
---@return number Grid dimensions (4-7)
function DeploymentScene:_getGridSize(mapSize)
    local sizeMap = {
        small = 4,
        medium = 5,
        large = 6,
        huge = 7
    }
    return sizeMap[mapSize] or 5
end

---Start the deployment scene
---Shows landing zone preview first
---@return boolean success
function DeploymentScene:start()
    print("[DeploymentScene] Starting deployment planning...")
    
    -- Initialize deployment data
    if not self:_initializeDeployment() then
        print("[ERROR] Failed to initialize deployment")
        return false
    end
    
    -- Show map preview if configured
    if self.config.showMapPreview then
        self:_showLZPreview()
    else
        self:_showUnitAssignment()
    end
    
    return true
end

---Initialize deployment: select landing zones and create objectives
---@return boolean success
function DeploymentScene:_initializeDeployment()
    local gridSize = self.deploymentConfig.mapBlockGrid
    local numLZs = self.deploymentConfig.mapBlockGrid - 2  -- Simple formula: 4->1, 5->2, etc
    
    print(string.format(
        "[DeploymentScene] Initializing: grid=%dx%d, landing_zones=%d",
        gridSize, gridSize, numLZs
    ))
    
    -- Create map grid data
    local mapGrid = {
        width = gridSize,
        height = gridSize,
        totalBlocks = gridSize * gridSize
    }
    
    -- Mock objective indices (could come from mission data)
    local objectiveIndices = {}
    
    -- Select landing zones using algorithm
    local landingZones = LandingZoneSelector.selectZones(gridSize, self.missionData.mapSize)
    
    if not landingZones or #landingZones == 0 then
        print("[ERROR] No landing zones selected!")
        return false
    end
    
    -- Add spawn points to each landing zone
    for i, lz in ipairs(landingZones) do
        for spawnIdx = 1, self.config.spawnPointCount do
            local spawnX = (spawnIdx - 1) * 4
            local spawnY = (i - 1) * 4
            LandingZone.addUnit(lz, {x = spawnX, y = spawnY})
        end
        
        DeploymentConfig.addLandingZone(self.deploymentConfig, lz)
    end
    
    print(string.format(
        "[DeploymentScene] Initialized: %d landing zones, %d objective blocks",
        #landingZones, #objectiveIndices
    ))
    
    self.deploymentConfig.landingZones = landingZones
    return true
end

---Show landing zone preview UI
function DeploymentScene:_showLZPreview()
    print("[DeploymentScene] Showing landing zone preview...")
    
    self.state = DeploymentScene.STATES.LZ_PREVIEW
    
    local mapData = {
        size = self.missionData.mapSize,
        grid = self.deploymentConfig.mapBlockGrid,
        landingZones = self.deploymentConfig.landingZones,
        objectiveBlocks = self.deploymentConfig.objectiveBlocks,
        biome = self.missionData.biome or "FOREST"
    }
    
    LandingZonePreviewUI.show(mapData, 
        function(selectedLZs)
            self:_onLZPreviewConfirmed(selectedLZs)
        end,
        function()
            self:_onDeploymentCancelled()
        end
    )
end

---Handle landing zone preview confirmation
---@param selectedLZs table Selected landing zones
function DeploymentScene:_onLZPreviewConfirmed(selectedLZs)
    print("[DeploymentScene] LZ preview confirmed, moving to unit assignment...")
    self:_showUnitAssignment()
end

---Show unit assignment UI
function DeploymentScene:_showUnitAssignment()
    print("[DeploymentScene] Showing unit assignment...")
    
    self.state = DeploymentScene.STATES.UNIT_ASSIGNMENT
    
    -- Extract unit data
    local unitData = {}
    for i, unit in ipairs(self.deploymentConfig.availableUnits) do
        table.insert(unitData, {
            id = unit.id or ("unit_" .. i),
            name = unit.name or ("Soldier " .. i),
            rank = unit.rank or "Rookie",
            class = unit.class or "Assault"
        })
    end
    
    -- Extract landing zone data
    local lzData = {}
    for i, lz in ipairs(self.deploymentConfig.landingZones) do
        table.insert(lzData, {
            id = lz.id,
            name = lz.name or ("LZ-" .. i),
            capacity = 3,
            units = {}
        })
    end
    
    UnitDeploymentUI.show(unitData, lzData,
        function(assignments)
            self:_onUnitAssignmentConfirmed(assignments)
        end,
        function()
            if self.config.showMapPreview and self.config.allowUnitReassignment then
                self:_showLZPreview()
            else
                self:_onDeploymentCancelled()
            end
        end
    )
end

---Handle unit assignment confirmation
---@param assignments table Unit-to-LZ assignments {unitId -> lzId}
function DeploymentScene:_onUnitAssignmentConfirmed(assignments)
    print("[DeploymentScene] Units assigned, validating deployment...")
    
    -- Validate assignment
    for unitId, lzId in pairs(assignments) do
        local success = DeploymentConfig.assignUnitToZone(
            self.deploymentConfig, unitId, lzId
        )
        
        if not success then
            print("[WARNING] Failed to assign unit " .. unitId .. " to LZ " .. lzId)
        end
    end
    
    -- Check if deployment is complete
    local isValid = DeploymentConfig.isValid(self.deploymentConfig)
    
    if isValid then
        self:_showReview()
    else
        print("[ERROR] Deployment validation failed!")
        self:_showUnitAssignment()  -- Show again for correction
    end
end

---Show deployment review/summary screen
function DeploymentScene:_showReview()
    print("[DeploymentScene] Showing deployment review...")
    
    self.state = DeploymentScene.STATES.REVIEW
    
    -- Print summary for now (would show UI in full implementation)
    DeploymentConfig.printSummary(self.deploymentConfig)
    
    if self.config.confirmationRequired then
        -- In UI version, would show confirmation dialog
        -- For now, auto-proceed
        self:_completeDeployment()
    else
        self:_completeDeployment()
    end
end

---Complete deployment and transition to battlescape
function DeploymentScene:_completeDeployment()
    print("[DeploymentScene] Deployment complete! Transitioning to battlescape...")
    
    self.state = DeploymentScene.STATES.DEPLOYING
    
    if self.onDeploymentComplete then
        self.onDeploymentComplete(self.deploymentConfig)
    end
end

---Cancel deployment and return to mission select
function DeploymentScene:_onDeploymentCancelled()
    print("[DeploymentScene] Deployment cancelled.")
    
    self.state = DeploymentScene.STATES.CANCELLED
    
    if self.onDeploymentCancelled then
        self.onDeploymentCancelled()
    end
end

---Update scene
---@param dt number Delta time
function DeploymentScene:update(dt)
    if self.state == DeploymentScene.STATES.LZ_PREVIEW then
        LandingZonePreviewUI.update(dt)
    elseif self.state == DeploymentScene.STATES.UNIT_ASSIGNMENT then
        UnitDeploymentUI.update(dt)
    end
end

---Draw scene
function DeploymentScene:draw()
    if self.state == DeploymentScene.STATES.LZ_PREVIEW then
        LandingZonePreviewUI.draw()
    elseif self.state == DeploymentScene.STATES.UNIT_ASSIGNMENT then
        UnitDeploymentUI.draw()
    end
end

---Handle mouse press
---@param x number Mouse X
---@param y number Mouse Y
---@param button number Mouse button
function DeploymentScene:mousepressed(x, y, button)
    if self.state == DeploymentScene.STATES.LZ_PREVIEW then
        LandingZonePreviewUI.mousepressed(x, y, button)
    elseif self.state == DeploymentScene.STATES.UNIT_ASSIGNMENT then
        UnitDeploymentUI.mousepressed(x, y, button)
    end
end

---Handle key press
---@param key string Key name
function DeploymentScene:keypressed(key)
    if key == "escape" then
        self:_onDeploymentCancelled()
    elseif self.state == DeploymentScene.STATES.LZ_PREVIEW then
        LandingZonePreviewUI.keypressed(key)
    elseif self.state == DeploymentScene.STATES.UNIT_ASSIGNMENT then
        UnitDeploymentUI.keypressed(key)
    end
end

---Get deployment configuration (read-only)
---@return table deploymentConfig Current deployment state
function DeploymentScene:getConfig()
    return self.deploymentConfig
end

---Get current state
---@return string state Current scene state
function DeploymentScene:getState()
    return self.state
end

return DeploymentScene



