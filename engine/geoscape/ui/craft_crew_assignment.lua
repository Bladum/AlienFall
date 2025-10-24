--- Craft Crew Assignment UI
---
--- Manages pilot and crew assignment to craft slots with validation.
--- Validates pilot requirements, levels, and capacity.
---
--- @module engine.geoscape.ui.craft_crew_assignment
--- @author AlienFall Development Team

local CapacitySystem = require("content.crafts.capacity_system")
local CraftManager = require("content.crafts.craft_manager")

local CrewAssignmentUI = {}
CrewAssignmentUI.__index = CrewAssignmentUI

--- Initialize assignment UI
---@return table UI instance
function CrewAssignmentUI:new()
    local self = setmetatable({}, CrewAssignmentUI)
    
    self.visible = false
    self.selectedCraft = nil
    self.assignments = {}  -- {slot_idx = unit_id, ...}
    
    return self
end

--- Show assignment UI for craft
---@param craft table Craft entity
---@return boolean Success
function CrewAssignmentUI:show(craft)
    if not craft then
        return false
    end
    
    self.visible = true
    self.selectedCraft = craft
    self.assignments = {}
    
    return true
end

--- Hide assignment UI
---@return boolean Success
function CrewAssignmentUI:hide()
    self.visible = false
    self.selectedCraft = nil
    self.assignments = {}
    return true
end

--- Assign unit to slot
---@param slotIdx number Slot index (1-based)
---@param unitId string Unit ID
---@return boolean Success, string reason
function CrewAssignmentUI:assignToSlot(slotIdx, unitId)
    if not self.selectedCraft then
        return false, "No craft selected"
    end
    
    if not unitId then
        return false, "Invalid unit"
    end
    
    -- Check slot validity
    local craft = self.selectedCraft
    if not craft.capacity then
        return false, "Craft has no capacity info"
    end
    
    if slotIdx < 1 or slotIdx > craft.capacity.max.pilot then
        return false, string.format("Invalid slot: %d", slotIdx)
    end
    
    self.assignments[slotIdx] = unitId
    
    return true, "Assigned"
end

--- Remove unit from slot
---@param slotIdx number Slot index
---@return boolean Success
function CrewAssignmentUI:removeFromSlot(slotIdx)
    if not self.selectedCraft then
        return false
    end
    
    self.assignments[slotIdx] = nil
    return true
end

--- Get available slots
---@return number Available count
function CrewAssignmentUI:getAvailableSlots()
    if not self.selectedCraft or not self.selectedCraft.capacity then
        return 0
    end
    
    local used = 0
    for _ in pairs(self.assignments) do
        used = used + 1
    end
    
    return self.selectedCraft.capacity.max.pilot - used
end

--- Validate current assignments
---@return boolean Valid, string reason
function CrewAssignmentUI:validateAssignments()
    if not self.selectedCraft then
        return false, "No craft selected"
    end
    
    local craft = self.selectedCraft
    local craftMgr = CraftManager:new()
    
    -- Get pilots from assignments
    local pilots = {}
    for _, unitId in pairs(self.assignments) do
        if unitId then
            table.insert(pilots, unitId)
        end
    end
    
    -- Validate against craft requirements
    local valid, reason = craftMgr:validatePilots(craft.id, pilots)
    if not valid then
        return false, reason
    end
    
    return true, "Valid"
end

--- Apply assignments to craft
---@return boolean Success, string reason
function CrewAssignmentUI:applyAssignments()
    local valid, reason = self:validateAssignments()
    if not valid then
        return false, reason
    end
    
    if not self.selectedCraft then
        return false, "No craft selected"
    end
    
    local craft = self.selectedCraft
    
    -- Clear existing pilots
    if craft.pilots then
        craft.pilots = {}
    else
        craft.pilots = {}
    end
    
    -- Assign new pilots
    for _, unitId in pairs(self.assignments) do
        if unitId then
            table.insert(craft.pilots, unitId)
        end
    end
    
    print(string.format("[CrewAssignmentUI] Assigned %d pilots to %s",
        #craft.pilots, craft.name or "Unknown"))
    
    return true, "Applied"
end

--- Get assignment info for display
---@return table Slot info {slot: pilot_name, ...}
function CrewAssignmentUI:getAssignmentInfo()
    if not self.selectedCraft then
        return {}
    end
    
    local info = {}
    local maxSlots = self.selectedCraft.capacity and self.selectedCraft.capacity.max.pilot or 0
    
    for i = 1, maxSlots do
        local unitId = self.assignments[i]
        if unitId then
            info[i] = unitId
        else
            info[i] = "EMPTY"
        end
    end
    
    return info
end

--- Get slot status for display
---@param slotIdx number Slot index
---@return string Status
function CrewAssignmentUI:getSlotStatus(slotIdx)
    local unitId = self.assignments[slotIdx]
    
    if not unitId then
        return "EMPTY"
    end
    
    return unitId
end

--- Format assignment summary
---@return string Summary
function CrewAssignmentUI:formatSummary()
    if not self.selectedCraft then
        return "No craft selected"
    end
    
    local craft = self.selectedCraft
    local assigned = 0
    for _ in pairs(self.assignments) do
        assigned = assigned + 1
    end
    
    local required = craft.capacity and craft.capacity.max.pilot or 1
    
    return string.format("Assigned: %d/%d | %s",
        assigned, required, craft.name or "Unknown Craft")
end

return CrewAssignmentUI
