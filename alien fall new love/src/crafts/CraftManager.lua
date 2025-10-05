--- CraftManager.lua
-- Manages collections of crafts, base assignments, and craft operations
-- Handles craft creation, assignment, maintenance, and fleet management

-- GROK: CraftManager handles craft collections and base assignments across all bases
-- GROK: Manages craft creation, transfer between bases, maintenance scheduling
-- GROK: Key methods: createCraft(), assignToBase(), getAvailableCrafts(), transferCraft()
-- GROK: Coordinates with CraftService for individual craft operations and BaseManager for facilities

local class = require 'lib.Middleclass'
local Craft = require 'crafts.Craft'

--- CraftManager class for managing craft collections and operations
-- @type CraftManager
CraftManager = class('CraftManager')

--- Create a new CraftManager instance
-- @param config Configuration options
-- @return CraftManager instance
function CraftManager:initialize(config)
    self.config = config or {}
    self.crafts = {} -- craft_id -> Craft instance
    self.baseAssignments = {} -- base_id -> {craft_id -> true}
    self.craftAssignments = {} -- craft_id -> base_id

    -- Statistics
    self.stats = {
        totalCrafts = 0,
        operationalCrafts = 0,
        damagedCrafts = 0,
        destroyedCrafts = 0
    }

    -- Initialize from config
    self:_loadConfig()
end

--- Load configuration settings
function CraftManager:_loadConfig()
    self.maxCraftsPerBase = self.config.maxCraftsPerBase or 20
    self.maintenanceInterval = self.config.maintenanceInterval or 24 -- hours
    self.repairRate = self.config.repairRate or 10 -- condition points per hour
    self.fuelConsumptionRate = self.config.fuelConsumptionRate or 1.0
end

--- Create a new craft
-- @param craftData Craft initialization data
-- @param craftClass The craft class template
-- @param baseId The base to assign the craft to
-- @param registry Service registry
-- @return Craft instance or nil on failure
function CraftManager:createCraft(craftData, craftClass, baseId, registry)
    -- Validate base capacity
    if not self:_canAssignToBase(baseId) then
        return nil, "Base at maximum craft capacity"
    end

    -- Create craft instance
    local craft = Craft:new(craftData, craftClass, registry)

    -- Add to collections
    self.crafts[craft.id] = craft
    self:assignToBase(craft.id, baseId)

    -- Update statistics
    self:_updateStats()

    return craft
end

--- Destroy a craft
-- @param craftId The craft ID to destroy
-- @return true if destroyed successfully
function CraftManager:destroyCraft(craftId)
    local craft = self.crafts[craftId]
    if not craft then
        return false
    end

    -- Remove from base assignment
    local baseId = self.craftAssignments[craftId]
    if baseId then
        self.baseAssignments[baseId][craftId] = nil
        self.craftAssignments[craftId] = nil
    end

    -- Remove from collection
    self.crafts[craftId] = nil

    -- Update statistics
    self:_updateStats()

    return true
end

--- Assign craft to a base
-- @param craftId The craft ID
-- @param baseId The base ID
-- @return true if assigned successfully
function CraftManager:assignToBase(craftId, baseId)
    -- Validate craft exists
    if not self.crafts[craftId] then
        return false, "Craft not found"
    end

    -- Check base capacity
    if not self:_canAssignToBase(baseId) then
        return false, "Base at maximum capacity"
    end

    -- Remove from current base
    local currentBase = self.craftAssignments[craftId]
    if currentBase then
        self.baseAssignments[currentBase][craftId] = nil
    end

    -- Assign to new base
    if not self.baseAssignments[baseId] then
        self.baseAssignments[baseId] = {}
    end
    self.baseAssignments[baseId][craftId] = true
    self.craftAssignments[craftId] = baseId

    -- Update craft base assignment
    self.crafts[craftId].baseId = baseId

    return true
end

--- Transfer craft between bases
-- @param craftId The craft ID
-- @param targetBaseId The destination base ID
-- @param transferTime Time required for transfer (in hours)
-- @return true if transfer initiated
function CraftManager:transferCraft(craftId, targetBaseId, transferTime)
    local craft = self.crafts[craftId]
    if not craft then
        return false, "Craft not found"
    end

    -- Check if craft is operational
    if not craft:isOperational() then
        return false, "Craft is not operational"
    end

    -- Check target base capacity
    if not self:_canAssignToBase(targetBaseId) then
        return false, "Target base at maximum capacity"
    end

    -- Set craft status to transferring
    craft.status = "transferring"
    craft.transferDestination = targetBaseId
    craft.transferETA = transferTime

    return true
end

--- Complete craft transfer
-- @param craftId The craft ID
-- @return true if transfer completed
function CraftManager:completeTransfer(craftId)
    local craft = self.crafts[craftId]
    if not craft or craft.status ~= "transferring" then
        return false
    end

    -- Assign to destination base
    local success = self:assignToBase(craftId, craft.transferDestination)

    if success then
        -- Reset transfer state
        craft.status = "hangar"
        craft.transferDestination = nil
        craft.transferETA = nil
        craft:returnToBase()
    end

    return success
end

--- Check if a base can accept more crafts
-- @param baseId The base ID
-- @return true if base can accept more crafts
function CraftManager:_canAssignToBase(baseId)
    local assigned = self.baseAssignments[baseId] or {}
    local count = 0
    for _ in pairs(assigned) do
        count = count + 1
    end
    return count < self.maxCraftsPerBase
end

--- Get all crafts assigned to a base
-- @param baseId The base ID
-- @return Array of craft instances
function CraftManager:getCraftsAtBase(baseId)
    local crafts = {}
    local assigned = self.baseAssignments[baseId] or {}

    for craftId in pairs(assigned) do
        local craft = self.crafts[craftId]
        if craft then
            table.insert(crafts, craft)
        end
    end

    return crafts
end

--- Get all operational crafts at a base
-- @param baseId The base ID
-- @return Array of operational craft instances
function CraftManager:getOperationalCraftsAtBase(baseId)
    local crafts = self:getCraftsAtBase(baseId)
    local operational = {}

    for _, craft in ipairs(crafts) do
        if craft:isOperational() then
            table.insert(operational, craft)
        end
    end

    return operational
end

--- Get craft by ID
-- @param craftId The craft ID
-- @return Craft instance or nil
function CraftManager:getCraft(craftId)
    return self.crafts[craftId]
end

--- Get all crafts
-- @return Table of all craft instances (craft_id -> craft)
function CraftManager:getAllCrafts()
    return self.crafts
end

--- Get crafts by status
-- @param status The status to filter by
-- @return Array of craft instances
function CraftManager:getCraftsByStatus(status)
    local crafts = {}
    for _, craft in pairs(self.crafts) do
        if craft.status == status then
            table.insert(crafts, craft)
        end
    end
    return crafts
end

--- Get crafts by craft class
-- @param classId The craft class ID
-- @return Array of craft instances
function CraftManager:getCraftsByClass(classId)
    local crafts = {}
    for _, craft in pairs(self.crafts) do
        if craft.craftClass.id == classId then
            table.insert(crafts, craft)
        end
    end
    return crafts
end

--- Update craft maintenance and status
-- @param hoursElapsed Hours since last update
function CraftManager:updateMaintenance(hoursElapsed)
    for _, craft in pairs(self.crafts) do
        -- Auto-repair damaged crafts
        if craft.condition < 100 and craft.status == "hangar" then
            local repairAmount = self.repairRate * hoursElapsed
            craft:repair(repairAmount)
        end

        -- Update transferring crafts
        if craft.status == "transferring" and craft.transferETA then
            craft.transferETA = craft.transferETA - hoursElapsed
            if craft.transferETA <= 0 then
                self:completeTransfer(craft.id)
            end
        end
    end

    -- Update statistics
    self:_updateStats()
end

--- Update manager statistics
function CraftManager:_updateStats()
    self.stats.totalCrafts = 0
    self.stats.operationalCrafts = 0
    self.stats.damagedCrafts = 0
    self.stats.destroyedCrafts = 0

    for _, craft in pairs(self.crafts) do
        self.stats.totalCrafts = self.stats.totalCrafts + 1

        if craft.status == "destroyed" then
            self.stats.destroyedCrafts = self.stats.destroyedCrafts + 1
        elseif craft.condition < 100 then
            self.stats.damagedCrafts = self.stats.damagedCrafts + 1
        elseif craft:isOperational() then
            self.stats.operationalCrafts = self.stats.operationalCrafts + 1
        end
    end
end

--- Get manager statistics
-- @return Statistics table
function CraftManager:getStats()
    return {
        totalCrafts = self.stats.totalCrafts,
        operationalCrafts = self.stats.operationalCrafts,
        damagedCrafts = self.stats.damagedCrafts,
        destroyedCrafts = self.stats.destroyedCrafts,
        utilizationRate = self.stats.totalCrafts > 0 and
                         (self.stats.operationalCrafts / self.stats.totalCrafts) or 0
    }
end

--- Get crafts available for mission assignment at a base
-- @param baseId The base ID
-- @param missionType The mission type (optional filter)
-- @return Array of available craft instances
function CraftManager:getAvailableCraftsForMission(baseId, missionType)
    local crafts = self:getOperationalCraftsAtBase(baseId)
    local available = {}

    for _, craft in ipairs(crafts) do
        -- Check if craft is available (not on mission, not transferring)
        if craft.status == "hangar" then
            -- Check mission type compatibility if specified
            if not missionType or self:_isCompatibleWithMission(craft, missionType) then
                table.insert(available, craft)
            end
        end
    end

    return available
end

--- Check if craft is compatible with mission type
-- @param craft The craft instance
-- @param missionType The mission type
-- @return true if compatible
function CraftManager:_isCompatibleWithMission(craft, missionType)
    -- This would check craft capabilities against mission requirements
    -- For now, basic compatibility check
    local capabilities = craft.craftClass.capabilities or {}

    if missionType == "interception" then
        return capabilities.air_to_air or capabilities.interceptor
    elseif missionType == "ground_attack" then
        return capabilities.air_to_ground or capabilities.bomber
    elseif missionType == "transport" then
        return capabilities.unit_capacity and capabilities.unit_capacity > 0
    end

    return true -- Default to compatible
end

--- Save craft manager state
-- @return Serializable state data
function CraftManager:saveState()
    local state = {
        crafts = {},
        baseAssignments = self.baseAssignments,
        craftAssignments = self.craftAssignments,
        config = self.config
    }

    -- Save craft data
    for craftId, craft in pairs(self.crafts) do
        state.crafts[craftId] = {
            id = craft.id,
            name = craft.name,
            baseId = craft.baseId,
            status = craft.status,
            condition = craft.condition,
            experience = craft.experience,
            level = craft.level,
            missions_completed = craft.missions_completed,
            successful_missions = craft.successful_missions,
            damage_repairs = craft.damage_repairs,
            equipment = craft.equipment,
            fuel = craft.fuel,
            currentMission = craft.currentMission,
            destination = craft.destination,
            eta = craft.eta,
            position = craft.position,
            heading = craft.heading,
            speed = craft.speed
        }
    end

    return state
end

--- Load craft manager state
-- @param state Saved state data
-- @param registry Service registry
function CraftManager:loadState(state, registry)
    self.baseAssignments = state.baseAssignments or {}
    self.craftAssignments = state.craftAssignments or {}
    self.config = state.config or {}

    -- Recreate crafts
    self.crafts = {}
    for craftId, craftData in pairs(state.crafts or {}) do
        -- Get craft class (this would need to be resolved from registry)
        local craftClass = self:_resolveCraftClass(craftData, registry)
        if craftClass then
            local craft = Craft:new(craftData, craftClass, registry)
            self.crafts[craftId] = craft
        end
    end

    self:_loadConfig()
    self:_updateStats()
end

--- Resolve craft class from saved data
-- @param craftData The saved craft data
-- @param registry Service registry
-- @return CraftClass instance or nil
function CraftManager:_resolveCraftClass(craftData, registry)
    if not registry then return nil end

    local craftService = registry:getService('craftService')
    if craftService then
        return craftService:getCraftClass(craftData.craftClassId)
    end

    return nil
end

--- Convert to string representation
-- @return String representation
function CraftManager:__tostring()
    return string.format("CraftManager{crafts=%d, bases=%d}",
                        self.stats.totalCrafts,
                        #self.baseAssignments)
end

return CraftManager
