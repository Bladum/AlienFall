---@class MissionLaunchState
---@field missionData table Current mission being launched
---@field selectedSquad table List of selected unit IDs
---@field craftAssignments table Map of craft IDs to pilot assignments
---@field pilotAssignments table Map of pilot IDs to craft assignments
---@field equipmentLoadout table Equipment assignments for units
---@field validationCache table Cached validation results
---@field currentStep string Current step in launch process
---@field errorMessages table Current validation errors
---@field recoverySuggestions table Suggested fixes for errors
---@field squadSystem table Reference to squad system
---@field missionSystem table Reference to mission system
local MissionLaunchState = {}
MissionLaunchState.__index = MissionLaunchState

-- ============================================================================
-- CONSTANTS
-- ============================================================================

local LAUNCH_STEPS = {
    SQUAD_SELECTION = "squad_selection",
    PILOT_ASSIGNMENT = "pilot_assignment",
    EQUIPMENT_CHECK = "equipment_check",
    RESOURCE_VALIDATION = "resource_validation",
    FINAL_CONFIRMATION = "final_confirmation"
}

local ERROR_TYPES = {
    SQUAD_COMPOSITION = "squad_composition",
    PILOT_ASSIGNMENT = "pilot_assignment",
    CAPACITY_EXCEEDED = "capacity_exceeded",
    EQUIPMENT_OVERLOAD = "equipment_overload",
    PILOT_STRESS = "pilot_stress",
    SUBOPTIMAL_LOAD = "suboptimal_load",
    FUEL_INSUFFICIENT = "fuel_insufficient",
    PILOT_UNAVAILABLE = "pilot_unavailable",
    CRAFT_UNAVAILABLE = "craft_unavailable"
}

local ERROR_SEVERITY = {
    BLOCKING = "blocking",     -- Cannot proceed
    WARNING = "warning",       -- Can proceed with penalty
    INFO = "info"             -- Suggestion only
}

-- ============================================================================
-- INITIALIZATION
-- ============================================================================

function MissionLaunchState:new()
    local self = setmetatable({}, MissionLaunchState)

    self.missionData = nil
    self.selectedSquad = {}
    self.craftAssignments = {}
    self.pilotAssignments = {}
    self.equipmentLoadout = {}
    self.validationCache = {}
    self.currentStep = LAUNCH_STEPS.SQUAD_SELECTION
    self.errorMessages = {}
    self.recoverySuggestions = {}

    -- Initialize systems
    self.squadSystem = require("engine.battlescape.squad")
    self.missionSystem = require("engine.geoscape.systems.missions.mission_generator")

    return self
end

-- ============================================================================
-- STATE MANAGEMENT
-- ============================================================================

function MissionLaunchState:enter(params)
    print("[MissionLaunchState] Entering mission launch state")

    if not params or not params.missionData then
        error("MissionLaunchState requires missionData parameter")
    end

    self.missionData = params.missionData
    self.selectedSquad = params.selectedSquad or {}
    self.craftAssignments = params.craftAssignments or {}
    self.pilotAssignments = params.pilotAssignments or {}

    -- Try to load saved progress for this mission
    local loadedProgress = self:_loadLaunchProgress(self.missionData.id)
    if not loadedProgress then
        -- No saved progress, use provided params or defaults
        self.selectedSquad = params.selectedSquad or {}
        self.craftAssignments = params.craftAssignments or {}
        self.pilotAssignments = params.pilotAssignments or {}
        self.currentStep = LAUNCH_STEPS.SQUAD_SELECTION
    end

    -- Update available resources
    self:_updateAvailableResources()

    -- Reset validation state
    self.errorMessages = {}
    self.recoverySuggestions = {}

    print(string.format("[MissionLaunchState] Initialized for mission: %s",
        self.missionData.name or "Unknown"))
end

function MissionLaunchState:exit()
    print("[MissionLaunchState] Exiting mission launch state")

    -- Save progress for potential resume (unless mission was launched)
    self:_saveLaunchProgress()

    -- Clean up
    self.missionData = nil
    self.selectedSquad = {}
    self.craftAssignments = {}
    self.pilotAssignments = {}
    self.equipmentLoadout = {}
    self.validationCache = {}
    self.errorMessages = {}
    self.recoverySuggestions = {}
end

-- ============================================================================
-- MISSION REQUIREMENTS CALCULATION
-- ============================================================================

function MissionLaunchState:calculateRequirements()
    local requirements = {
        soldiers = {
            min = 4,
            max = 8,
            recommended = 6
        },
        transports = {
            min = 1,
            max = 2,
            required = math.ceil((self.missionData.enemies and #self.missionData.enemies or 6) / 8)
        },
        pilots = {
            total = 0,  -- Calculated based on craft assignments
            reserve = 1  -- Always need 1 backup pilot
        }
    }

    -- Adjust based on mission type
    local missionType = self.missionData.type or "research"
    if missionType == "terror" then
        requirements.soldiers.recommended = requirements.soldiers.recommended + 1
    elseif missionType == "base_assault" then
        requirements.soldiers.max = 8
        requirements.transports.max = 2
    end

    -- Calculate pilot requirements based on assigned crafts
    requirements.pilots.total = self:_calculatePilotRequirements()

    return requirements
end

function MissionLaunchState:_calculatePilotRequirements()
    local totalPilots = 0

    for craftId, pilots in pairs(self.craftAssignments) do
        local craft = self.squadSystem:getCraftById(craftId)
        if craft then
            local required = craft.type == "transport" and 2 or 1
            totalPilots = totalPilots + required
        end
    end

    return totalPilots
end

-- ============================================================================
-- SQUAD COMPOSITION VALIDATION
-- ============================================================================

function MissionLaunchState:validateSquadComposition()
    print("[MissionLaunchState] Validating squad composition")

    local isValid, errorMessage = self.squadSystem:validateSquadComposition(self.selectedSquad)

    if not isValid then
        self:_addError(ERROR_TYPES.SQUAD_COMPOSITION, errorMessage, ERROR_SEVERITY.BLOCKING)
        self:_generateRecoverySuggestions(ERROR_TYPES.SQUAD_COMPOSITION)
        return false
    end

    -- Clear any previous squad errors
    self:_clearErrorType(ERROR_TYPES.SQUAD_COMPOSITION)
    return true
end

function MissionLaunchState:setSelectedSquad(squad)
    self.selectedSquad = squad or {}
    self:_invalidateCache()
    self:_validateCurrentStep()
    self:_saveLaunchProgress()  -- Save progress when squad changes
end

-- ============================================================================
-- PILOT ASSIGNMENT VALIDATION
-- ============================================================================

function MissionLaunchState:validatePilotAssignments()
    print("[MissionLaunchState] Validating pilot assignments")

    local allValid = true

    for craftId, pilots in pairs(self.craftAssignments) do
        local craft = self.squadSystem:getCraftById(craftId)
        if not craft then
            self:_addError(ERROR_TYPES.CRAFT_UNAVAILABLE,
                string.format("Craft %s not found", craftId), ERROR_SEVERITY.BLOCKING)
            allValid = false
        else
            local isValid, errorMessage = self.squadSystem:validatePilotAssignment(craft.type, pilots)
            if not isValid then
                self:_addError(ERROR_TYPES.PILOT_ASSIGNMENT, errorMessage, ERROR_SEVERITY.BLOCKING)
                allValid = false
            end
        end
    end

    -- Check pilot availability
    local assignedPilots = {}
    for _, pilots in pairs(self.craftAssignments) do
        for _, pilotId in ipairs(pilots) do
            if assignedPilots[pilotId] then
                self:_addError(ERROR_TYPES.PILOT_ASSIGNMENT,
                    string.format("Pilot %s assigned to multiple crafts", pilotId), ERROR_SEVERITY.BLOCKING)
                allValid = false
            end
            assignedPilots[pilotId] = true

            local pilot = self.squadSystem:getPilotById(pilotId)
            if not pilot then
                self:_addError(ERROR_TYPES.PILOT_UNAVAILABLE,
                    string.format("Pilot %s not available", pilotId), ERROR_SEVERITY.BLOCKING)
                allValid = false
            elseif pilot.fatigue and pilot.fatigue >= 100 then
                self:_addError(ERROR_TYPES.PILOT_STRESS,
                    string.format("Pilot %s has maximum fatigue", pilot.name), ERROR_SEVERITY.WARNING)
            end
        end
    end

    if allValid then
        self:_clearErrorType(ERROR_TYPES.PILOT_ASSIGNMENT)
        self:_clearErrorType(ERROR_TYPES.CRAFT_UNAVAILABLE)
        self:_clearErrorType(ERROR_TYPES.PILOT_UNAVAILABLE)
    end

    return allValid
end

function MissionLaunchState:assignPilotToCraft(craftId, pilotId, position)
    if not self.craftAssignments[craftId] then
        self.craftAssignments[craftId] = {}
    end

    -- Remove pilot from any existing assignment
    for cId, pilots in pairs(self.craftAssignments) do
        for i, pId in ipairs(pilots) do
            if pId == pilotId then
                table.remove(pilots, i)
                break
            end
        end
    end

    -- Assign to new position
    self.craftAssignments[craftId][position] = pilotId
    self.pilotAssignments[pilotId] = craftId

    self:_invalidateCache()
    self:_validateCurrentStep()
    self:_saveLaunchProgress()  -- Save progress when assignments change
end

-- ============================================================================
-- CAPACITY AND EQUIPMENT VALIDATION
-- ============================================================================

function MissionLaunchState:validateCapacityAndEquipment()
    print("[MissionLaunchState] Validating capacity and equipment")

    local canLaunch, errors = self.squadSystem:validateMissionLaunch(
        self.selectedSquad, self.craftAssignments)

    if not canLaunch then
        for _, error in ipairs(errors) do
            local errorType = self:_mapValidationErrorToType(error.type)
            self:_addError(errorType, error.message, ERROR_SEVERITY.BLOCKING)
        end
        return false
    end

    -- Clear capacity-related errors
    self:_clearErrorType(ERROR_TYPES.CAPACITY_EXCEEDED)
    self:_clearErrorType(ERROR_TYPES.EQUIPMENT_OVERLOAD)

    return true
end

function MissionLaunchState:_mapValidationErrorToType(validationType)
    local typeMap = {
        capacity = ERROR_TYPES.CAPACITY_EXCEEDED,
        weight = ERROR_TYPES.EQUIPMENT_OVERLOAD,
        pilot = ERROR_TYPES.PILOT_ASSIGNMENT
    }
    return typeMap[validationType] or ERROR_TYPES.SQUAD_COMPOSITION
end

-- ============================================================================
-- RESOURCE VALIDATION
-- ============================================================================

function MissionLaunchState:validateBaseResources()
    print("[MissionLaunchState] Validating base resources")

    -- This would integrate with the base/facility system
    -- For now, assume resources are available
    -- TODO: Implement actual resource checking

    local requirements = self:calculateResourceRequirements()

    -- Mock validation - replace with actual base system calls
    local availableFuel = 1000  -- Mock: get from base system
    if availableFuel < requirements.fuel then
        self:_addError(ERROR_TYPES.FUEL_INSUFFICIENT,
            string.format("Insufficient fuel. Need %dL, have %dL", requirements.fuel, availableFuel),
            ERROR_SEVERITY.BLOCKING)
        return false
    end

    -- Clear resource errors if validation passes
    self:_clearErrorType(ERROR_TYPES.FUEL_INSUFFICIENT)
    return true
end

function MissionLaunchState:calculateResourceRequirements()
    local requirements = {
        fuel = 100,  -- Base fuel per mission
        pilots = self:_calculatePilotRequirements(),
        crafts = 0
    }

    -- Add fuel based on mission distance/type
    local missionType = self.missionData.type or "research"
    if missionType == "terror" then
        requirements.fuel = requirements.fuel + 50
    elseif missionType == "base_assault" then
        requirements.fuel = requirements.fuel + 100
    end

    -- Count crafts
    for _ in pairs(self.craftAssignments) do
        requirements.crafts = requirements.crafts + 1
    end

    return requirements
end

-- ============================================================================
-- LAUNCH PREPARATION AND EXECUTION
-- ============================================================================

function MissionLaunchState:prepareLaunch()
    print("[MissionLaunchState] Preparing mission launch")

    -- Step 1: Validate squad composition
    if not self:validateSquadComposition() then
        print("[MissionLaunchState] Squad validation failed")
        return false
    end

    -- Step 2: Validate pilot assignments
    if not self:validatePilotAssignments() then
        print("[MissionLaunchState] Pilot validation failed")
        return false
    end

    -- Step 3: Validate capacity and equipment
    if not self:validateCapacityAndEquipment() then
        print("[MissionLaunchState] Capacity validation failed")
        return false
    end

    -- Step 4: Check base resources
    if not self:validateBaseResources() then
        print("[MissionLaunchState] Resource validation failed")
        return false
    end

    -- Step 5: Prepare deployment data
    local deploymentData = self:prepareDeploymentData()

    print("[MissionLaunchState] Launch preparation complete")
    return true, deploymentData
end

function MissionLaunchState:executeLaunch()
    print("[MissionLaunchState] Executing mission launch")

    local success, deploymentData = self:prepareLaunch()
    if not success then
        return false
    end

    -- Consume resources
    self:consumeResources()

    -- Mark pilots as fatigued
    self:_applyPilotFatigue()

    -- Clear saved progress since mission launched successfully
    self:_clearLaunchProgress()

    -- Store deployment data for battlescape
    local StateManager = require("engine.core.state.state_manager")
    StateManager.global_data.deployment = deploymentData

    print("[MissionLaunchState] Mission launched successfully")
    return true
end

function MissionLaunchState:prepareDeploymentData()
    return {
        missionId = self.missionData.id,
        squad = self.selectedSquad,
        craftAssignments = self.craftAssignments,
        pilotAssignments = self.pilotAssignments,
        equipmentLoadout = self.equipmentLoadout,
        capacityValidation = {
            totalCapacity = self:_calculateTotalCapacity(),
            usedCapacity = #self.selectedSquad,
            pilotCount = self:_countAssignedPilots(),
            weightValidation = self:_validateAllWeights()
        },
        launchTime = os.time(),
        estimatedDuration = self:_calculateMissionDuration()
    }
end

function MissionLaunchState:consumeResources()
    local requirements = self:calculateResourceRequirements()

    -- TODO: Integrate with actual base/facility system
    print(string.format("[MissionLaunchState] Consuming resources: %d fuel, %d pilots, %d crafts",
        requirements.fuel, requirements.pilots, requirements.crafts))

    -- Mark pilots as assigned (would update pilot status in actual system)
    for pilotId in pairs(self.pilotAssignments) do
        print(string.format("[MissionLaunchState] Pilot %s assigned to mission", pilotId))
    end
end

-- ============================================================================
-- ERROR HANDLING
-- ============================================================================

function MissionLaunchState:_addError(errorType, message, severity)
    -- Remove any existing error of this type
    self:_clearErrorType(errorType)

    table.insert(self.errorMessages, {
        type = errorType,
        message = message,
        severity = severity,
        timestamp = os.time()
    })

    -- Generate recovery suggestions
    self:_generateRecoverySuggestions(errorType)
end

function MissionLaunchState:_clearErrorType(errorType)
    for i = #self.errorMessages, 1, -1 do
        if self.errorMessages[i].type == errorType then
            table.remove(self.errorMessages, i)
        end
    end
end

function MissionLaunchState:getErrors()
    return self.errorMessages
end

function MissionLaunchState:hasBlockingErrors()
    for _, error in ipairs(self.errorMessages) do
        if error.severity == ERROR_SEVERITY.BLOCKING then
            return true
        end
    end
    return false
end

function MissionLaunchState:_generateRecoverySuggestions(errorType)
    self.recoverySuggestions[errorType] = {}

    if errorType == ERROR_TYPES.SQUAD_COMPOSITION then
        table.insert(self.recoverySuggestions[errorType], "Add more soldiers to meet minimum requirements")
        table.insert(self.recoverySuggestions[errorType], "Remove excess soldiers to meet maximum limits")
        table.insert(self.recoverySuggestions[errorType], "Ensure squad has exactly one leader")
    elseif errorType == ERROR_TYPES.CAPACITY_EXCEEDED then
        table.insert(self.recoverySuggestions[errorType], "Add another transport craft")
        table.insert(self.recoverySuggestions[errorType], "Remove soldiers from squad")
        table.insert(self.recoverySuggestions[errorType], "Split into multiple smaller missions")
    elseif errorType == ERROR_TYPES.EQUIPMENT_OVERLOAD then
        table.insert(self.recoverySuggestions[errorType], "Remove heavy equipment from overloaded units")
        table.insert(self.recoverySuggestions[errorType], "Switch to lighter armor")
        table.insert(self.recoverySuggestions[errorType], "Reduce ammunition carried")
    elseif errorType == ERROR_TYPES.PILOT_ASSIGNMENT then
        table.insert(self.recoverySuggestions[errorType], "Assign rested pilot to replace fatigued pilot")
        table.insert(self.recoverySuggestions[errorType], "Wait for pilot recovery")
        table.insert(self.recoverySuggestions[errorType], "Use pilot with lower fatigue")
    elseif errorType == ERROR_TYPES.FUEL_INSUFFICIENT then
        table.insert(self.recoverySuggestions[errorType], "Wait for fuel production")
        table.insert(self.recoverySuggestions[errorType], "Reduce mission scope")
        table.insert(self.recoverySuggestions[errorType], "Use more efficient craft")
    end
end

function MissionLaunchState:getRecoverySuggestions(errorType)
    return self.recoverySuggestions[errorType] or {}
end

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================

function MissionLaunchState:_updateAvailableResources()
    -- TODO: Get actual available resources from game state
    -- For now, use mock data
    local mockUnits = {
        ["unit_1"] = {id = "unit_1", name = "Soldier 1", class = "soldier", role = "combat"},
        ["unit_2"] = {id = "unit_2", name = "Soldier 2", class = "soldier", role = "combat"},
        ["unit_3"] = {id = "unit_3", name = "Medic", class = "medic", role = "support"},
        ["unit_4"] = {id = "unit_4", name = "Leader", class = "commander", role = "leader"}
    }

    local mockPilots = {
        ["pilot_1"] = {id = "pilot_1", name = "Pilot 1", fatigue = 20},
        ["pilot_2"] = {id = "pilot_2", name = "Pilot 2", fatigue = 50}
    }

    local mockCrafts = {
        ["craft_1"] = {id = "craft_1", type = "transport"},
        ["craft_2"] = {id = "craft_2", type = "interceptor"}
    }

    self.squadSystem:updateAvailableResources(mockUnits, mockPilots, mockCrafts)
end

function MissionLaunchState:_invalidateCache()
    self.validationCache = {}
end

function MissionLaunchState:_validateCurrentStep()
    -- Could implement step-by-step validation here
    -- For now, just ensure we're in a valid state
end

function MissionLaunchState:_saveLaunchProgress()
    -- Save current mission launch progress for potential resume
    local SaveSystem = require("core.systems.save_system")
    local saveSystem = SaveSystem.new()

    local progressData = {
        missionId = self.missionData.id,
        selectedSquad = self.selectedSquad,
        craftAssignments = self.craftAssignments,
        pilotAssignments = self.pilotAssignments,
        equipmentLoadout = self.equipmentLoadout,
        currentStep = self.currentStep,
        timestamp = os.time(),
        version = "1.0.0"
    }

    -- Use a special filename for mission launch progress
    local filename = "mission_launch_progress.tmp"
    local success = love.filesystem.write(filename, self:_serializeProgress(progressData))

    if success then
        print("[MissionLaunchState] Mission launch progress saved")
    else
        print("[MissionLaunchState] Failed to save mission launch progress")
    end
end

function MissionLaunchState:_loadLaunchProgress(missionId)
    -- Load saved mission launch progress if it exists
    local filename = "mission_launch_progress.tmp"

    if not love.filesystem.getInfo(filename) then
        print("[MissionLaunchState] No saved progress found")
        return false
    end

    local contents = love.filesystem.read(filename)
    if not contents then
        print("[MissionLaunchState] Failed to read progress file")
        return false
    end

    local progressData = self:_deserializeProgress(contents)
    if not progressData then
        print("[MissionLaunchState] Failed to deserialize progress data")
        return false
    end

    -- Validate that progress is for the current mission
    if progressData.missionId ~= missionId then
        print("[MissionLaunchState] Progress is for different mission, ignoring")
        return false
    end

    -- Restore progress
    self.selectedSquad = progressData.selectedSquad or {}
    self.craftAssignments = progressData.craftAssignments or {}
    self.pilotAssignments = progressData.pilotAssignments or {}
    self.equipmentLoadout = progressData.equipmentLoadout or {}
    self.currentStep = progressData.currentStep or LAUNCH_STEPS.SQUAD_SELECTION

    print("[MissionLaunchState] Mission launch progress loaded")
    return true
end

function MissionLaunchState:_serializeProgress(data)
    -- Simple serialization using JSON-like format
    -- In production, would use proper JSON library
    local json = require("libs.json")
    return json.encode(data)
end

function MissionLaunchState:_clearLaunchProgress()
    -- Clear saved progress file after successful launch
    local filename = "mission_launch_progress.tmp"
    if love.filesystem.getInfo(filename) then
        local success = love.filesystem.remove(filename)
        if success then
            print("[MissionLaunchState] Cleared saved launch progress")
        else
            print("[MissionLaunchState] Failed to clear launch progress")
        end
    end
end

function MissionLaunchState:_calculateTotalCapacity()
    local totalCapacity = 0
    for craftId in pairs(self.craftAssignments) do
        local craft = self.squadSystem:getCraftById(craftId)
        if craft and craft.type == "transport" then
            totalCapacity = totalCapacity + 8  -- Mock capacity
        end
    end
    return totalCapacity
end

function MissionLaunchState:_countAssignedPilots()
    local count = 0
    for _ in pairs(self.pilotAssignments) do
        count = count + 1
    end
    return count
end

function MissionLaunchState:_validateAllWeights()
    -- TODO: Implement weight validation
    return true
end

function MissionLaunchState:_calculateMissionDuration()
    -- Mock duration calculation
    return 3600  -- 1 hour in seconds
end

function MissionLaunchState:_applyPilotFatigue()
    for pilotId in pairs(self.pilotAssignments) do
        print(string.format("[MissionLaunchState] Applying fatigue to pilot %s", pilotId))
        -- TODO: Integrate with actual pilot system
    end
end

return MissionLaunchState
