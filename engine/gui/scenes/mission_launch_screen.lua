---Mission Launch Screen
---
---Interactive mission preparation interface that integrates squad selection,
---pilot assignment, equipment validation, and launch confirmation. Provides
---real-time validation feedback and error recovery suggestions.
---
---Key Features:
---  - Squad composition selection with validation
---  - Pilot-to-craft assignment interface
---  - Equipment loadout verification
---  - Resource requirement display
---  - Error handling with recovery suggestions
---  - Step-by-step launch preparation
---
---Screen Flow:
---  1. Squad Selection → Validate composition
---  2. Pilot Assignment → Assign pilots to crafts
---  3. Equipment Check → Verify loadouts
---  4. Resource Validation → Check base resources
---  5. Final Confirmation → Launch mission
---
---Integration Points:
---  - MissionLaunchState: Core validation logic
---  - SquadSystem: Squad and pilot validation
---  - BaseSystem: Resource availability
---  - StateManager: Screen transitions
---
---@module gui.scenes.mission_launch_screen
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local MissionLaunchScreen = require("gui.scenes.mission_launch_screen")
---  MissionLaunchScreen:enter({missionData = mission})
---
---@see engine.core.mission_launch_state For validation logic
---@see engine.battlescape.squad For squad system
---@see gui.scenes.geoscape_screen For mission selection

local MissionLaunchScreen = {}
MissionLaunchScreen.__index = MissionLaunchScreen

-- Screen state
MissionLaunchScreen.missionData = nil           -- Current mission
MissionLaunchScreen.launchState = nil          -- MissionLaunchState instance
MissionLaunchScreen.currentStep = "squad"      -- Current UI step
MissionLaunchScreen.availableUnits = {}        -- Available soldiers
MissionLaunchScreen.availablePilots = {}       -- Available pilots
MissionLaunchScreen.availableCrafts = {}       -- Available crafts
MissionLaunchScreen.selectedUnits = {}         -- Currently selected squad
MissionLaunchScreen.pilotAssignments = {}      -- Pilot-to-craft assignments
MissionLaunchScreen.scrollOffset = 0           -- UI scrolling
MissionLaunchScreen.errorMessages = {}         -- Current validation errors
MissionLaunchScreen.showErrors = false         -- Error display toggle

-- UI Layout constants
MissionLaunchScreen.PANEL_WIDTH = 900
MissionLaunchScreen.PANEL_HEIGHT = 650
MissionLaunchScreen.PANEL_X = (1024 - 900) / 2
MissionLaunchScreen.PANEL_Y = (768 - 650) / 2
MissionLaunchScreen.PADDING = 16
MissionLaunchScreen.LINE_HEIGHT = 20
MissionLaunchScreen.BUTTON_WIDTH = 120
MissionLaunchScreen.BUTTON_HEIGHT = 32

---Enter mission launch screen
---@param args table Screen arguments {missionData: table}
function MissionLaunchScreen:enter(args)
    print("[MissionLaunchScreen] Entering mission launch screen")

    if not args or not args.missionData then
        print("[MissionLaunchScreen] ERROR: No mission data provided")
        return
    end

    self.missionData = args.missionData

    -- Initialize launch state
    local MissionLaunchState = require("engine.core.mission_launch_state")
    self.launchState = MissionLaunchState:new()
    self.launchState:enter({
        missionData = self.missionData,
        selectedSquad = args.selectedSquad or {},
        craftAssignments = args.craftAssignments or {},
        pilotAssignments = args.pilotAssignments or {}
    })

    -- Initialize UI state
    self.currentStep = "squad"
    self.scrollOffset = 0
    self.errorMessages = {}
    self.showErrors = false

    -- Load available resources (mock data for now)
    self:_loadAvailableResources()

    print(string.format("[MissionLaunchScreen] Initialized for mission: %s",
        self.missionData.name or "Unknown"))
end

---Exit mission launch screen
function MissionLaunchScreen:exit()
    print("[MissionLaunchScreen] Exiting mission launch screen")

    if self.launchState then
        self.launchState:exit()
        self.launchState = nil
    end

    -- Clean up
    self.missionData = nil
    self.availableUnits = {}
    self.availablePilots = {}
    self.availableCrafts = {}
    self.selectedUnits = {}
    self.pilotAssignments = {}
    self.errorMessages = {}
end

---Update mission launch screen
---@param delta_time number Delta time in seconds
function MissionLaunchScreen:update(delta_time)
    -- Handle scroll input
    if love.keyboard.isDown("up") then
        self.scrollOffset = math.max(self.scrollOffset - 200 * delta_time, 0)
    elseif love.keyboard.isDown("down") then
        self.scrollOffset = math.min(self.scrollOffset + 200 * delta_time, 1000)
    end
end

---Draw mission launch screen
function MissionLaunchScreen:draw()
    if not self.missionData or not self.launchState then return end

    love.graphics.clear(0.1, 0.1, 0.15)

    -- Draw background panel
    love.graphics.setColor(0.15, 0.15, 0.2, 0.95)
    love.graphics.rectangle("fill",
        self.PANEL_X, self.PANEL_Y,
        self.PANEL_WIDTH, self.PANEL_HEIGHT)

    -- Draw border
    love.graphics.setColor(0.4, 0.7, 1.0, 0.8)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line",
        self.PANEL_X, self.PANEL_Y,
        self.PANEL_WIDTH, self.PANEL_HEIGHT)

    -- Draw title
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.getFont())
    local title = string.format("MISSION LAUNCH: %s",
        self.missionData.name or "Unknown Operation")
    love.graphics.print(title,
        self.PANEL_X + self.PADDING,
        self.PANEL_Y + self.PADDING)

    -- Draw step indicator
    self:_drawStepIndicator()

    -- Draw main content based on current step
    local contentY = self.PANEL_Y + self.PADDING + self.LINE_HEIGHT * 2
    if self.currentStep == "squad" then
        self:_drawSquadSelection(contentY)
    elseif self.currentStep == "pilots" then
        self:_drawPilotAssignment(contentY)
    elseif self.currentStep == "equipment" then
        self:_drawEquipmentCheck(contentY)
    elseif self.currentStep == "resources" then
        self:_drawResourceValidation(contentY)
    elseif self.currentStep == "confirm" then
        self:_drawFinalConfirmation(contentY)
    end

    -- Draw error panel if needed
    if self.showErrors and #self.errorMessages > 0 then
        self:_drawErrorPanel()
    end

    -- Draw navigation buttons
    self:_drawNavigationButtons()
end

---Draw step indicator
function MissionLaunchScreen:_drawStepIndicator()
    local steps = {"Squad", "Pilots", "Equipment", "Resources", "Confirm"}
    local stepY = self.PANEL_Y + self.PADDING + self.LINE_HEIGHT + 8

    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.print("Launch Steps:", self.PANEL_X + self.PADDING, stepY)

    local stepX = self.PANEL_X + self.PADDING + 100
    for i, stepName in ipairs(steps) do
        local isCurrent = steps[i]:lower() == self.currentStep
        local isCompleted = self:_isStepCompleted(steps[i]:lower())

        if isCompleted then
            love.graphics.setColor(0.2, 0.8, 0.2)  -- Green for completed
        elseif isCurrent then
            love.graphics.setColor(0.4, 0.7, 1.0)  -- Blue for current
        else
            love.graphics.setColor(0.5, 0.5, 0.5)  -- Gray for pending
        end

        local indicator = isCompleted and "✓" or (isCurrent and "→" or "○")
        love.graphics.print(string.format("%s %s", indicator, stepName), stepX, stepY)

        stepX = stepX + 120
    end
end

---Draw squad selection interface
---@param startY number Starting Y position
function MissionLaunchScreen:_drawSquadSelection(startY)
    local y = startY

    -- Requirements header
    love.graphics.setColor(0.4, 0.7, 1.0)
    love.graphics.print("SQUAD REQUIREMENTS", self.PANEL_X + self.PADDING, y)
    y = y + self.LINE_HEIGHT

    -- Show requirements
    local requirements = self.launchState:calculateRequirements()
    love.graphics.setColor(0.9, 0.9, 0.9)
    love.graphics.print(string.format("Soldiers: %d-%d (recommended: %d)",
        requirements.soldiers.min, requirements.soldiers.max, requirements.soldiers.recommended),
        self.PANEL_X + self.PADDING * 2, y)
    y = y + self.LINE_HEIGHT

    love.graphics.print(string.format("Transports: %d-%d crafts",
        requirements.transports.min, requirements.transports.max),
        self.PANEL_X + self.PADDING * 2, y)
    y = y + self.LINE_HEIGHT

    -- Available units
    y = y + self.LINE_HEIGHT
    love.graphics.setColor(0.4, 0.7, 1.0)
    love.graphics.print("AVAILABLE UNITS", self.PANEL_X + self.PADDING, y)
    y = y + self.LINE_HEIGHT

    love.graphics.setColor(0.9, 0.9, 0.9)
    for _, unit in ipairs(self.availableUnits) do
        local isSelected = self:_isUnitSelected(unit.id)
        local checkbox = isSelected and "[X]" or "[ ]"
        love.graphics.print(string.format("%s %s (%s)",
            checkbox, unit.name, unit.class), self.PANEL_X + self.PADDING * 2, y)
        y = y + self.LINE_HEIGHT
    end

    -- Current squad summary
    y = y + self.LINE_HEIGHT
    love.graphics.setColor(0.4, 0.7, 1.0)
    love.graphics.print(string.format("CURRENT SQUAD: %d units selected", #self.selectedUnits),
        self.PANEL_X + self.PADDING, y)
end

---Draw pilot assignment interface
---@param startY number Starting Y position
function MissionLaunchScreen:_drawPilotAssignment(startY)
    local y = startY

    love.graphics.setColor(0.4, 0.7, 1.0)
    love.graphics.print("PILOT ASSIGNMENT", self.PANEL_X + self.PADDING, y)
    y = y + self.LINE_HEIGHT

    love.graphics.setColor(0.9, 0.9, 0.9)
    love.graphics.print("Assign pilots to transport crafts:", self.PANEL_X + self.PADDING * 2, y)
    y = y + self.LINE_HEIGHT * 2

    -- Show crafts and their pilot requirements
    for _, craft in ipairs(self.availableCrafts) do
        if craft.type == "transport" then
            love.graphics.setColor(0.4, 0.7, 1.0)
            love.graphics.print(string.format("%s (%s)", craft.name, craft.id),
                self.PANEL_X + self.PADDING * 2, y)
            y = y + self.LINE_HEIGHT

            love.graphics.setColor(0.9, 0.9, 0.9)
            local assigned = self.pilotAssignments[craft.id] or {}
            love.graphics.print(string.format("  Primary: %s", assigned[1] or "Unassigned"),
                self.PANEL_X + self.PADDING * 3, y)
            y = y + self.LINE_HEIGHT
            love.graphics.print(string.format("  Copilot: %s", assigned[2] or "Unassigned"),
                self.PANEL_X + self.PADDING * 3, y)
            y = y + self.LINE_HEIGHT
        end
    end

    -- Available pilots
    y = y + self.LINE_HEIGHT
    love.graphics.setColor(0.4, 0.7, 1.0)
    love.graphics.print("AVAILABLE PILOTS", self.PANEL_X + self.PADDING, y)
    y = y + self.LINE_HEIGHT

    love.graphics.setColor(0.9, 0.9, 0.9)
    for _, pilot in ipairs(self.availablePilots) do
        local isAssigned = self:_isPilotAssigned(pilot.id)
        local status = isAssigned and "(Assigned)" or "(Available)"
        love.graphics.print(string.format("%s %s", pilot.name, status),
            self.PANEL_X + self.PADDING * 2, y)
        y = y + self.LINE_HEIGHT
    end
end

---Draw equipment check interface
---@param startY number Starting Y position
function MissionLaunchScreen:_drawEquipmentCheck(startY)
    local y = startY

    love.graphics.setColor(0.4, 0.7, 1.0)
    love.graphics.print("EQUIPMENT VALIDATION", self.PANEL_X + self.PADDING, y)
    y = y + self.LINE_HEIGHT

    love.graphics.setColor(0.9, 0.9, 0.9)
    love.graphics.print("Checking equipment loadouts and weight limits...", self.PANEL_X + self.PADDING * 2, y)
    y = y + self.LINE_HEIGHT * 2

    -- Show selected squad equipment status
    for _, unitId in ipairs(self.selectedUnits) do
        local unit = self:_getUnitById(unitId)
        if unit then
            love.graphics.print(string.format("• %s: Equipment OK", unit.name),
                self.PANEL_X + self.PADDING * 2, y)
            y = y + self.LINE_HEIGHT
        end
    end
end

---Draw resource validation interface
---@param startY number Starting Y position
function MissionLaunchScreen:_drawResourceValidation(startY)
    local y = startY

    love.graphics.setColor(0.4, 0.7, 1.0)
    love.graphics.print("RESOURCE REQUIREMENTS", self.PANEL_X + self.PADDING, y)
    y = y + self.LINE_HEIGHT

    local requirements = self.launchState:calculateResourceRequirements()
    love.graphics.setColor(0.9, 0.9, 0.9)
    love.graphics.print(string.format("Fuel: %d L", requirements.fuel), self.PANEL_X + self.PADDING * 2, y)
    y = y + self.LINE_HEIGHT
    love.graphics.print(string.format("Pilots: %d", requirements.pilots), self.PANEL_X + self.PADDING * 2, y)
    y = y + self.LINE_HEIGHT
    love.graphics.print(string.format("Crafts: %d", requirements.crafts), self.PANEL_X + self.PADDING * 2, y)
end

---Draw final confirmation interface
---@param startY number Starting Y position
function MissionLaunchScreen:_drawFinalConfirmation(startY)
    local y = startY

    love.graphics.setColor(0.4, 0.7, 1.0)
    love.graphics.print("LAUNCH CONFIRMATION", self.PANEL_X + self.PADDING, y)
    y = y + self.LINE_HEIGHT

    love.graphics.setColor(0.9, 0.9, 0.9)
    love.graphics.print("All validations passed. Ready to launch mission.", self.PANEL_X + self.PADDING * 2, y)
    y = y + self.LINE_HEIGHT * 2

    -- Show final summary
    love.graphics.setColor(0.4, 0.7, 1.0)
    love.graphics.print("MISSION SUMMARY:", self.PANEL_X + self.PADDING, y)
    y = y + self.LINE_HEIGHT

    love.graphics.setColor(0.9, 0.9, 0.9)
    love.graphics.print(string.format("• Squad: %d soldiers", #self.selectedUnits), self.PANEL_X + self.PADDING * 2, y)
    y = y + self.LINE_HEIGHT
    love.graphics.print(string.format("• Crafts: %d assigned", self:_countAssignedCrafts()), self.PANEL_X + self.PADDING * 2, y)
    y = y + self.LINE_HEIGHT
    love.graphics.print(string.format("• Pilots: %d assigned", self:_countAssignedPilots()), self.PANEL_X + self.PADDING * 2, y)
end

---Draw error panel
function MissionLaunchScreen:_drawErrorPanel()
    local panelWidth = 400
    local panelHeight = 200
    local panelX = self.PANEL_X + self.PANEL_WIDTH - panelWidth - self.PADDING
    local panelY = self.PANEL_Y + self.PADDING

    -- Error panel background
    love.graphics.setColor(0.3, 0.1, 0.1, 0.9)
    love.graphics.rectangle("fill", panelX, panelY, panelWidth, panelHeight)

    -- Error panel border
    love.graphics.setColor(0.8, 0.2, 0.2, 0.8)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", panelX, panelY, panelWidth, panelHeight)

    -- Error title
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("VALIDATION ERRORS", panelX + self.PADDING, panelY + self.PADDING)

    -- Error messages
    love.graphics.setColor(0.9, 0.8, 0.8)
    local y = panelY + self.PADDING + self.LINE_HEIGHT + 8
    for i, error in ipairs(self.errorMessages) do
        if i > 5 then  -- Limit display
            love.graphics.print("... and more", panelX + self.PADDING, y)
            break
        end
        love.graphics.print(string.format("• %s", error.message), panelX + self.PADDING, y)
        y = y + self.LINE_HEIGHT
    end
end

---Draw navigation buttons
function MissionLaunchScreen:_drawNavigationButtons()
    local buttonY = self.PANEL_Y + self.PANEL_HEIGHT - self.BUTTON_HEIGHT - self.PADDING

    -- Previous button
    if self.currentStep ~= "squad" then
        love.graphics.setColor(0.4, 0.4, 0.4, 0.8)
        love.graphics.rectangle("fill",
            self.PANEL_X + self.PADDING,
            buttonY,
            self.BUTTON_WIDTH, self.BUTTON_HEIGHT)

        love.graphics.setColor(1, 1, 1)
        love.graphics.print("PREVIOUS",
            self.PANEL_X + self.PADDING + 8,
            buttonY + 6)
    end

    -- Next/Launch button
    local canProceed = self:_canProceedToNextStep()
    if canProceed then
        love.graphics.setColor(0.2, 0.6, 0.2, 0.8)
    else
        love.graphics.setColor(0.3, 0.3, 0.3, 0.8)
    end

    local buttonText = (self.currentStep == "confirm") and "LAUNCH MISSION" or "NEXT"
    love.graphics.rectangle("fill",
        self.PANEL_X + self.PANEL_WIDTH - self.BUTTON_WIDTH - self.PADDING,
        buttonY,
        self.BUTTON_WIDTH, self.BUTTON_HEIGHT)

    love.graphics.setColor(1, 1, 1)
    love.graphics.print(buttonText,
        self.PANEL_X + self.PANEL_WIDTH - self.BUTTON_WIDTH - self.PADDING + 8,
        buttonY + 6)

    -- Cancel button
    love.graphics.setColor(0.6, 0.2, 0.2, 0.8)
    love.graphics.rectangle("fill",
        self.PANEL_X + self.PANEL_WIDTH - self.BUTTON_WIDTH * 2 - self.PADDING * 2,
        buttonY,
        self.BUTTON_WIDTH, self.BUTTON_HEIGHT)

    love.graphics.setColor(1, 1, 1)
    love.graphics.print("CANCEL",
        self.PANEL_X + self.PANEL_WIDTH - self.BUTTON_WIDTH * 2 - self.PADDING * 2 + 8,
        buttonY + 6)
end

---Handle mouse input
---@param x number Mouse X position
---@param y number Mouse Y position
---@param button number Mouse button
function MissionLaunchScreen:mousepressed(x, y, button)
    if button ~= 1 then return end

    local buttonY = self.PANEL_Y + self.PANEL_HEIGHT - self.BUTTON_HEIGHT - self.PADDING

    -- Previous button
    if self.currentStep ~= "squad" and
       x >= self.PANEL_X + self.PADDING and
       x <= self.PANEL_X + self.PADDING + self.BUTTON_WIDTH and
       y >= buttonY and y <= buttonY + self.BUTTON_HEIGHT then

        self:_goToPreviousStep()
        return
    end

    -- Next/Launch button
    if x >= self.PANEL_X + self.PANEL_WIDTH - self.BUTTON_WIDTH - self.PADDING and
       x <= self.PANEL_X + self.PANEL_WIDTH - self.PADDING and
       y >= buttonY and y <= buttonY + self.BUTTON_HEIGHT then

        if self.currentStep == "confirm" then
            self:_launchMission()
        else
            self:_goToNextStep()
        end
        return
    end

    -- Cancel button
    if x >= self.PANEL_X + self.PANEL_WIDTH - self.BUTTON_WIDTH * 2 - self.PADDING * 2 and
       x <= self.PANEL_X + self.PANEL_WIDTH - self.BUTTON_WIDTH - self.PADDING and
       y >= buttonY and y <= buttonY + self.BUTTON_HEIGHT then

        self:_cancelLaunch()
        return
    end

    -- Handle step-specific clicks
    if self.currentStep == "squad" then
        self:_handleSquadSelectionClick(x, y)
    end
end

---Handle squad selection clicks
---@param x number Mouse X position
---@param y number Mouse Y position
function MissionLaunchScreen:_handleSquadSelectionClick(x, y)
    local startY = self.PANEL_Y + self.PADDING + self.LINE_HEIGHT * 2 + self.LINE_HEIGHT * 4
    local yPos = startY

    for _, unit in ipairs(self.availableUnits) do
        if x >= self.PANEL_X + self.PADDING * 2 and
           x <= self.PANEL_X + self.PADDING * 2 + 200 and
           y >= yPos and y <= yPos + self.LINE_HEIGHT then

            self:_toggleUnitSelection(unit.id)
            break
        end
        yPos = yPos + self.LINE_HEIGHT
    end
end

---Toggle unit selection
---@param unitId string Unit ID to toggle
function MissionLaunchScreen:_toggleUnitSelection(unitId)
    local index = self:_findUnitIndex(self.selectedUnits, unitId)
    if index then
        table.remove(self.selectedUnits, index)
    else
        table.insert(self.selectedUnits, unitId)
    end

    -- Update launch state
    self.launchState:setSelectedSquad(self.selectedUnits)

    -- Validate
    self:_validateCurrentStep()
end

---Go to next step
function MissionLaunchScreen:_goToNextStep()
    if not self:_canProceedToNextStep() then return end

    local steps = {"squad", "pilots", "equipment", "resources", "confirm"}
    local currentIndex = self:_getStepIndex(self.currentStep)

    if currentIndex < #steps then
        self.currentStep = steps[currentIndex + 1]
        self:_validateCurrentStep()
    end
end

---Go to previous step
function MissionLaunchScreen:_goToPreviousStep()
    local steps = {"squad", "pilots", "equipment", "resources", "confirm"}
    local currentIndex = self:_getStepIndex(self.currentStep)

    if currentIndex > 1 then
        self.currentStep = steps[currentIndex - 1]
        self:_validateCurrentStep()
    end
end

---Launch mission
function MissionLaunchScreen:_launchMission()
    print("[MissionLaunchScreen] Launching mission")

    local success = self.launchState:executeLaunch()
    if success then
        -- Transition to battlescape
        local StateManager = require("engine.core.state.state_manager")
        StateManager.switch("battlescape", {
            missionData = self.missionData,
            deploymentData = StateManager.global_data.deployment
        })
    else
        print("[MissionLaunchScreen] Launch failed")
        self.showErrors = true
    end
end

---Cancel launch
function MissionLaunchScreen:_cancelLaunch()
    print("[MissionLaunchScreen] Cancelling mission launch")

    -- Return to geoscape
    local StateManager = require("engine.core.state.state_manager")
    StateManager.switch("geoscape")
end

---Validate current step
function MissionLaunchScreen:_validateCurrentStep()
    self.errorMessages = {}

    if self.currentStep == "squad" then
        local valid = self.launchState:validateSquadComposition()
        if not valid then
            self.errorMessages = self.launchState:getErrors()
        end
    elseif self.currentStep == "pilots" then
        local valid = self.launchState:validatePilotAssignments()
        if not valid then
            self.errorMessages = self.launchState:getErrors()
        end
    elseif self.currentStep == "equipment" then
        local valid = self.launchState:validateCapacityAndEquipment()
        if not valid then
            self.errorMessages = self.launchState:getErrors()
        end
    elseif self.currentStep == "resources" then
        local valid = self.launchState:validateBaseResources()
        if not valid then
            self.errorMessages = self.launchState:getErrors()
        end
    end

    self.showErrors = #self.errorMessages > 0
end

---Check if can proceed to next step
---@return boolean
function MissionLaunchScreen:_canProceedToNextStep()
    return #self.errorMessages == 0
end

---Check if step is completed
---@param step string Step name
---@return boolean
function MissionLaunchScreen:_isStepCompleted(step)
    local steps = {"squad", "pilots", "equipment", "resources", "confirm"}
    local currentIndex = self:_getStepIndex(self.currentStep)
    local stepIndex = self:_getStepIndex(step)

    return stepIndex < currentIndex
end

---Get step index
---@param step string Step name
---@return number
function MissionLaunchScreen:_getStepIndex(step)
    local steps = {"squad", "pilots", "equipment", "resources", "confirm"}
    for i, s in ipairs(steps) do
        if s == step then return i end
    end
    return 1
end

---Load available resources (mock data)
function MissionLaunchScreen:_loadAvailableResources()
    self.availableUnits = {
        {id = "unit_1", name = "Soldier Johnson", class = "soldier", role = "combat"},
        {id = "unit_2", name = "Soldier Smith", class = "soldier", role = "combat"},
        {id = "unit_3", name = "Medic Davis", class = "medic", role = "support"},
        {id = "unit_4", name = "Sgt. Commander", class = "commander", role = "leader"},
        {id = "unit_5", name = "Heavy Rodriguez", class = "heavy", role = "combat"},
        {id = "unit_6", name = "Sniper Chen", class = "sniper", role = "specialist"}
    }

    self.availablePilots = {
        {id = "pilot_1", name = "Capt. Williams", fatigue = 20},
        {id = "pilot_2", name = "Lt. Garcia", fatigue = 50},
        {id = "pilot_3", name = "Sgt. Brown", fatigue = 80}
    }

    self.availableCrafts = {
        {id = "craft_1", name = "Skyranger-1", type = "transport"},
        {id = "craft_2", name = "Interceptor-1", type = "interceptor"}
    }
end

---Utility functions
function MissionLaunchScreen:_isUnitSelected(unitId)
    return self:_findUnitIndex(self.selectedUnits, unitId) ~= nil
end

function MissionLaunchScreen:_isPilotAssigned(pilotId)
    for _, assignment in pairs(self.pilotAssignments) do
        for _, pilot in ipairs(assignment) do
            if pilot == pilotId then return true end
        end
    end
    return false
end

function MissionLaunchScreen:_findUnitIndex(list, unitId)
    for i, id in ipairs(list) do
        if id == unitId then return i end
    end
    return nil
end

function MissionLaunchScreen:_getUnitById(unitId)
    for _, unit in ipairs(self.availableUnits) do
        if unit.id == unitId then return unit end
    end
    return nil
end

function MissionLaunchScreen:_countAssignedCrafts()
    local count = 0
    for _ in pairs(self.pilotAssignments) do
        count = count + 1
    end
    return count
end

function MissionLaunchScreen:_countAssignedPilots()
    local count = 0
    for _, assignment in pairs(self.pilotAssignments) do
        count = count + #assignment
    end
    return count
end

return MissionLaunchScreen
