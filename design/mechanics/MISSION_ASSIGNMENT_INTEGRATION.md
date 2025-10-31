# Mission Assignment Integration Specification

> **Status**: Implementation Specification
> **Last Updated**: 2025-10-31
> **Related Systems**: CRAFT_CAPACITY_MODEL.md, SquadSystem.lua, MISSION_LAUNCH_UI_MOCKUPS.md
> **Purpose**: Integration points for mission assignment and capacity validation

## Overview

This specification defines how the craft capacity model integrates with the mission assignment system. It outlines the connection points between strategic mission selection and tactical deployment validation.

**Integration Points**:
1. Mission requirements calculation
2. Squad composition validation
3. Pilot/craft assignment checking
4. Launch preparation and validation
5. Error handling and user feedback

---

## 1. Mission Requirements Calculation

### Input: Mission Data

When a mission is selected, the system calculates deployment requirements:

```lua
function MissionSystem:calculateRequirements(missionData)
    local requirements = {
        soldiers = {
            min = 4,
            max = 8,
            recommended = 6
        },
        transports = {
            min = 1,
            max = 2,
            required = math.ceil(missionData.enemyCount / 8)
        },
        pilots = {
            total = 0,  -- Calculated based on craft assignments
            reserve = 1  -- Always need 1 backup pilot
        }
    }

    -- Adjust based on mission type
    if missionData.type == "terror" then
        requirements.soldiers.recommended = requirements.soldiers.recommended + 1
    elseif missionData.type == "base_assault" then
        requirements.soldiers.max = 8
        requirements.transports.max = 2
    end

    return requirements
end
```

### Output: UI Display

Requirements are displayed in the mission selection screen:

```
Mission: Terror Site Cleanup
Requirements:
- Soldiers: 4-8 (recommended: 6)
- Transports: 1-2 crafts
- Pilots: Calculated from craft assignments + 1 reserve
```

---

## 2. Squad Composition Integration

### Pre-Launch Validation

Before allowing mission launch, validate squad composition:

```lua
-- In MissionLaunchState
function MissionLaunchState:validateSquadComposition()
    local squadSystem = require("engine.battlescape.squad")
    local squad = self:getSelectedSquad()
    local craftAssignments = self:getCraftAssignments()

    local canLaunch, errors = squadSystem:validateMissionLaunch(squad, craftAssignments)

    if not canLaunch then
        self:showValidationErrors(errors)
        return false
    end

    return true
end
```

### Real-Time Feedback

As players modify squad composition, provide immediate feedback:

```lua
function SquadSelectionScreen:onSquadChanged()
    local squad = self:getCurrentSquad()
    local isValid, errorMessage = self.squadSystem:validateSquadComposition(squad)

    if isValid then
        self:setStatus("valid", "Squad composition meets requirements")
        self:enableNextButton()
    else
        self:setStatus("error", errorMessage)
        self:disableNextButton()
    end
end
```

---

## 3. Pilot/Craft Assignment Integration

### Assignment Validation

When pilots are assigned to crafts, validate immediately:

```lua
function PilotAssignmentScreen:onPilotAssigned(craftId, pilotId, position)
    local craft = self:getCraftById(craftId)
    local assignedPilots = self:getAssignedPilotsForCraft(craftId)

    local isValid, errorMessage = self.squadSystem:validatePilotAssignment(craft.type, assignedPilots)

    if not isValid then
        self:showError(craftId, errorMessage)
        -- Prevent assignment or show warning
    else
        self:updateCraftStatus(craftId, "valid")
        self:recalculateCapacity()
    end
end
```

### Capacity Recalculation

After any assignment change, recalculate total capacity:

```lua
function PilotAssignmentScreen:recalculateCapacity()
    local squad = self:getSelectedSquad()
    local craftAssignments = self:getAllCraftAssignments()

    local hasCapacity, errors = self.squadSystem:validateCapacity(squad, craftAssignments)

    self:updateCapacityDisplay(squad, craftAssignments)

    if not hasCapacity then
        self:showCapacityErrors(errors)
    end
end
```

---

## 4. Launch Preparation Integration

### Final Validation Sequence

Before mission launch, run complete validation:

```lua
function MissionLaunchState:prepareLaunch()
    -- Step 1: Validate squad composition
    if not self:validateSquadComposition() then
        return false
    end

    -- Step 2: Validate pilot assignments
    if not self:validatePilotAssignments() then
        return false
    end

    -- Step 3: Validate capacity and equipment
    if not self:validateCapacityAndEquipment() then
        return false
    end

    -- Step 4: Check base resources
    if not self:validateBaseResources() then
        return false
    end

    -- Step 5: Prepare deployment data
    self:prepareDeploymentData()

    return true
end
```

### Deployment Data Structure

Create deployment package for battlescape:

```lua
function MissionLaunchState:prepareDeploymentData()
    local deployment = {
        missionId = self.missionData.id,
        squad = self.selectedSquad,
        craftAssignments = self.craftAssignments,
        pilotAssignments = self.pilotAssignments,
        equipmentLoadout = self.equipmentLoadout,
        capacityValidation = {
            totalCapacity = self:calculateTotalCapacity(),
            usedCapacity = #self.selectedSquad,
            pilotCount = self:countAssignedPilots(),
            weightValidation = self:validateAllWeights()
        },
        launchTime = os.time(),
        estimatedDuration = self:calculateMissionDuration()
    }

    -- Store for battlescape transition
    StateManager.global_data.deployment = deployment

    return deployment
end
```

---

## 5. Error Handling Integration

### Error Classification

Different error types require different handling:

```lua
local ERROR_TYPES = {
    SQUAD_COMPOSITION = "squad",     -- Cannot proceed, must fix
    PILOT_ASSIGNMENT = "pilot",      -- Cannot proceed, must fix
    CAPACITY_EXCEEDED = "capacity",  -- Cannot proceed, must fix
    EQUIPMENT_OVERLOAD = "weight",   -- Cannot proceed, must fix
    PILOT_STRESS = "warning",        -- Can proceed, show warning
    SUBOPTIMAL_LOAD = "info"         -- Can proceed, show suggestion
}
```

### Error Display System

Centralized error display with appropriate UI treatment:

```lua
function ValidationDisplay:showErrors(errors)
    for _, error in ipairs(errors) do
        if error.type == ERROR_TYPES.SQUAD_COMPOSITION then
            self:showBlockingError(error.message)
        elseif error.type == ERROR_TYPES.PILOT_STRESS then
            self:showWarning(error.message, "Accept Penalty")
        elseif error.type == ERROR_TYPES.SUBOPTIMAL_LOAD then
            self:showInfo(error.message, "Optimize")
        end
    end
end
```

### Recovery Suggestions

Provide actionable fixes for common errors:

```lua
function ValidationSystem:suggestFixes(error)
    if error.type == "capacity" then
        return {
            "Add another transport craft",
            "Remove " .. error.overload .. " soldiers from squad",
            "Split into multiple smaller missions"
        }
    elseif error.type == "weight" then
        return {
            "Remove heavy equipment from " .. error.unitName,
            "Switch to lighter armor",
            "Reduce ammunition carried"
        }
    elseif error.type == "pilot" then
        return {
            "Assign rested pilot to replace " .. error.pilotName,
            "Wait for pilot recovery",
            "Use pilot with lower fatigue"
        }
    end
end
```

---

## 6. Base Resource Integration

### Fuel and Supply Checks

Validate base has sufficient resources for mission:

```lua
function MissionLaunchState:validateBaseResources()
    local baseId = self.missionData.baseId
    local requirements = self:calculateResourceRequirements()

    -- Check fuel
    local availableFuel = BaseSystem:getFuel(baseId)
    if availableFuel < requirements.fuel then
        self:showError("Insufficient fuel. Need " .. requirements.fuel .. "L, have " .. availableFuel .. "L")
        return false
    end

    -- Check pilot availability
    local availablePilots = BaseSystem:getAvailablePilots(baseId)
    if #availablePilots < requirements.pilots then
        self:showError("Insufficient pilots. Need " .. requirements.pilots .. ", have " .. #availablePilots)
        return false
    end

    -- Check craft availability
    local availableCrafts = BaseSystem:getAvailableCrafts(baseId)
    if #availableCrafts < requirements.crafts then
        self:showError("Insufficient craft. Need " .. requirements.crafts .. ", have " .. #availableCrafts)
        return false
    end

    return true
end
```

### Resource Consumption

Deduct resources upon successful launch:

```lua
function MissionLaunchState:consumeResources()
    local requirements = self:calculateResourceRequirements()

    BaseSystem:consumeFuel(self.missionData.baseId, requirements.fuel)
    BaseSystem:assignPilots(self.assignedPilots)
    BaseSystem:assignCrafts(self.assignedCrafts)

    -- Mark pilots as fatigued
    for _, pilotId in ipairs(self.assignedPilots) do
        PilotSystem:addFatigue(pilotId, 10)  -- Base mission fatigue
    end
end
```

---

## 7. State Management Integration

### Mission Launch State

New state in StateManager for mission preparation:

```lua
-- In main.lua or state_manager.lua
StateManager.register("mission_launch", MissionLaunchState)

-- Transition from geoscape
function GeoscapeState:launchMission(missionData)
    StateManager.switch("mission_launch", {
        missionData = missionData,
        availableUnits = self:getAvailableUnits(),
        availablePilots = self:getAvailablePilots(),
        availableCrafts = self:getAvailableCrafts()
    })
end
```

### State Flow

```
Geoscape → Mission Launch → Battlescape
    ↓            ↓              ↓
Select     Squad Setup →     Deploy
Mission    Pilot Assign →    Mission
         Equipment Check →  Complete
```

### Data Persistence

Save partial progress to allow resuming:

```lua
function MissionLaunchState:saveProgress()
    local saveData = {
        missionId = self.missionData.id,
        selectedSquad = self.selectedSquad,
        craftAssignments = self.craftAssignments,
        pilotAssignments = self.pilotAssignments,
        currentStep = self.currentStep
    }

    SaveSystem:saveMissionLaunchProgress(saveData)
end
```

---

## 8. Testing Integration Points

### Unit Tests

Test integration between systems:

```lua
function testMissionLaunchIntegration()
    -- Setup test data
    local missionData = {type = "terror", enemyCount = 15}
    local squad = {"soldier1", "soldier2", "soldier3", "soldier4"}
    local craftAssignments = {
        ["craft1"] = {"pilot1", "pilot2"}
    }

    -- Test validation
    local squadSystem = require("engine.battlescape.squad")
    local canLaunch, errors = squadSystem:validateMissionLaunch(squad, craftAssignments)

    assert(canLaunch, "Valid mission should launch")
    assert(#errors == 0, "Valid mission should have no errors")
end
```

### Integration Tests

Test full mission launch flow:

```lua
function testFullMissionLaunch()
    -- Mock all systems
    local missionSystem = mock(MissionSystem)
    local squadSystem = mock(SquadSystem)
    local baseSystem = mock(BaseSystem)

    -- Test complete flow
    local launcher = MissionLaunchState:new(missionData)
    launcher.squadSystem = squadSystem
    launcher.baseSystem = baseSystem

    -- Should validate and launch
    local success = launcher:launchMission()
    assert(success, "Mission should launch successfully")

    -- Verify resource consumption
    assert(baseSystem.consumeFuel.called, "Fuel should be consumed")
    assert(baseSystem.assignPilots.called, "Pilots should be assigned")
end
```

---

## 9. Performance Considerations

### Validation Optimization

Cache validation results to avoid redundant calculations:

```lua
function SquadSystem:getValidationCache()
    if not self.validationCache then
        self.validationCache = {}
    end
    return self.validationCache
end

function SquadSystem:invalidateCache()
    self.validationCache = {}
end
```

### Lazy Loading

Load unit/pilot data only when needed:

```lua
function MissionLaunchState:getUnitData(unitId)
    if not self.unitCache[unitId] then
        self.unitCache[unitId] = UnitSystem:getUnit(unitId)
    end
    return self.unitCache[unitId]
end
```

---

## 10. Error Recovery

### Graceful Degradation

Handle system failures without crashing:

```lua
function MissionLaunchState:handleValidationError(error)
    -- Log error
    Logger:error("Mission launch validation failed: " .. error.message)

    -- Show user-friendly message
    self:showError("Unable to validate mission launch. Please try again.")

    -- Reset to safe state
    self:resetToLastValidState()
end
```

### Auto-Recovery

Attempt to fix common issues automatically:

```lua
function MissionLaunchState:attemptAutoFix(error)
    if error.type == "pilot_stress" then
        -- Try to find replacement pilot
        local replacement = self:findAvailablePilot()
        if replacement then
            self:replacePilot(error.pilotId, replacement)
            return true
        end
    elseif error.type == "weight_overload" then
        -- Try to remove non-essential equipment
        local removed = self:removeExcessEquipment(error.unitId)
        if removed then
            return true
        end
    end

    return false  -- Could not auto-fix
end
```

---

## Implementation Checklist

- [ ] Create MissionLaunchState in StateManager
- [ ] Integrate SquadSystem validation calls
- [ ] Implement UI validation feedback
- [ ] Add resource consumption on launch
- [ ] Create error handling and recovery
- [ ] Add progress saving/loading
- [ ] Implement auto-fix suggestions
- [ ] Add performance optimizations
- [ ] Create comprehensive tests
- [ ] Update existing mission selection code</content>
<parameter name="filePath">c:\Users\tombl\Documents\Projects\design\mechanics\MISSION_ASSIGNMENT_INTEGRATION.md
