--- Base Management System - Base operations and facility coordination
---
--- Manages XCOM base(s) including grid layout, facilities, personnel,
--- research, manufacturing, and resource management. Supports multiple
--- bases with centralized coordination.
---
--- Base Grid: 5×5 (25 positions, HQ fixed at center)
--- Facilities: Barracks, Laboratory, Workshop, Storage, Radar, etc.
--- Resources: Credits, materials, research points
--- Personnel: Scientists, engineers, soldiers assigned to facilities
---
--- Usage:
---   local BaseManager = require("engine.basescape.base_manager")
---   local manager = BaseManager:new()
---   local base = manager:createBase({name = "Main Base"})
---   manager:buildFacility("base_1", 1, 0, "barracks")
---   manager:assignPersonnel("base_1", "unit_1", "barracks")
---
--- @module engine.basescape.base_manager
--- @author AlienFall Development Team

local BaseManager = {}
BaseManager.__index = BaseManager

-- Grid constants
local GRID_SIZE = 5
local HQ_X = 2
local HQ_Y = 2

-- Facility types
local FACILITY_TYPES = {
    headquarters = {cost = 0, buildTime = 0, capacity = 10},
    barracks = {cost = 75000, buildTime = 5, capacity = 12},
    laboratory = {cost = 100000, buildTime = 7, capacity = 20},
    workshop = {cost = 80000, buildTime = 6, capacity = 15},
    storage = {cost = 50000, buildTime = 3, capacity = 50},
    radar = {cost = 120000, buildTime = 8, capacity = 1},
    medical_bay = {cost = 90000, buildTime = 6, capacity = 8},
    training_center = {cost = 85000, buildTime = 5, capacity = 10}
}

--- Initialize Base Manager
---@return table BaseManager instance
function BaseManager:new()
    local self = setmetatable({}, BaseManager)
    
    self.bases = {}  -- {id = Base}
    self.nextId = 1
    self.primaryBase = nil
    
    print("[BaseManager] Initialized")
    
    return self
end

--- Create new base
---@param baseData table Base data
---@return table Base instance
function BaseManager:createBase(baseData)
    local base = {
        id = "base_" .. self.nextId,
        name = baseData.name or ("Base " .. self.nextId),
        province = baseData.province,
        
        -- Grid (5x5 = 25 positions)
        grid = self:initializeGrid(),
        
        -- Resources
        credits = baseData.credits or 100000,
        materials = baseData.materials or 500,
        supplies = baseData.supplies or 200,
        
        -- Personnel
        scientists = {},
        engineers = {},
        soldiers = {},
        staff = {},
        
        -- Status
        health = 100,  -- During base defense
        power = 100,
        morale = 75,
        securityLevel = 50,
        
        -- Economic
        monthlyIncome = 0,
        monthlyExpenses = 0,
        
        -- Tracking
        facilities = {},  -- {x_y = Facility}
        buildQueue = {},
        createdDate = os.time(),
        operationalDate = nil,
        
        -- Events
        onFacilityBuilt = nil,
        onPersonnelAssigned = nil
    }
    
    self.nextId = self.nextId + 1
    self.bases[base.id] = base
    
    if not self.primaryBase then
        self.primaryBase = base.id
    end
    
    -- Build headquarters
    base.grid[HQ_Y + 1][HQ_X + 1] = "headquarters"
    base.facilities[HQ_X .. "_" .. HQ_Y] = {
        type = "headquarters",
        health = 100,
        personnel = 0,
        status = "operational"
    }
    
    print(string.format("[BaseManager] Created base: %s - ID: %s",
        base.name, base.id))
    
    return base
end

--- Initialize 5x5 grid
---@return table Grid
function BaseManager:initializeGrid()
    local grid = {}
    for y = 0, GRID_SIZE - 1 do
        grid[y + 1] = {}
        for x = 0, GRID_SIZE - 1 do
            grid[y + 1][x + 1] = nil  -- Empty
        end
    end
    return grid
end

--- Get base by ID
---@param baseId string Base ID
---@return table? Base or nil
function BaseManager:getBase(baseId)
    return self.bases[baseId]
end

--- Build facility at grid position
---@param baseId string Base ID
---@param x number Grid X (0-4)
---@param y number Grid Y (0-4)
---@param facilityType string Facility type
---@return boolean Success
function BaseManager:buildFacility(baseId, x, y, facilityType)
    local base = self:getBase(baseId)
    if not base then
        return false
    end
    
    -- Validate position
    if x < 0 or x >= GRID_SIZE or y < 0 or y >= GRID_SIZE then
        print("[BaseManager] ERROR: Invalid grid position")
        return false
    end
    
    -- Check if position is empty
    if base.grid[y + 1][x + 1] ~= nil then
        print("[BaseManager] ERROR: Grid position occupied")
        return false
    end
    
    -- Check facility type
    if not FACILITY_TYPES[facilityType] then
        print("[BaseManager] ERROR: Unknown facility type: " .. facilityType)
        return false
    end
    
    local facilityDef = FACILITY_TYPES[facilityType]
    
    -- Check resources
    if base.credits < facilityDef.cost then
        print("[BaseManager] ERROR: Insufficient credits")
        return false
    end
    
    -- Deduct cost and add to build queue
    base.credits = base.credits - facilityDef.cost
    
    local facility = {
        type = facilityType,
        x = x,
        y = y,
        health = 100,
        maxHealth = 100,
        personnel = 0,
        maxPersonnel = facilityDef.capacity,
        buildTimeRemaining = facilityDef.buildTime,
        status = "constructing",
        workers = {},
        assignedPersonnel = {}
    }
    
    table.insert(base.buildQueue, {
        facility = facility,
        startDate = os.time(),
        buildTimeRemaining = facilityDef.buildTime
    })
    
    print(string.format("[BaseManager] Started construction: %s at (%d,%d)",
        facilityType, x, y))
    
    return true
end

--- Complete facility construction
---@param baseId string Base ID
---@param gridKey string Grid key (x_y)
---@return boolean Success
function BaseManager:completeFacility(baseId, gridKey)
    local base = self:getBase(baseId)
    if not base then
        return false
    end
    
    local parts = {}
    for part in gridKey:gmatch("[^_]+") do
        table.insert(parts, tonumber(part))
    end
    
    if #parts ~= 2 then
        return false
    end
    
    local x, y = parts[1], parts[2]
    
    -- Mark grid position
    base.grid[y + 1][x + 1] = "facility"
    
    local facility = {
        type = "unknown",
        x = x,
        y = y,
        health = 100,
        maxHealth = 100,
        personnel = 0,
        maxPersonnel = 10,
        status = "operational",
        workers = {},
        assignedPersonnel = {}
    }
    
    base.facilities[gridKey] = facility
    
    print(string.format("[BaseManager] Facility completed at (%d,%d)", x, y))
    
    return true
end

--- Assign personnel to facility
---@param baseId string Base ID
---@param unitId string Unit ID
---@param facilityType string Facility type
---@return boolean Success
function BaseManager:assignPersonnel(baseId, unitId, facilityType)
    local base = self:getBase(baseId)
    if not base then
        return false
    end
    
    -- Find facility of this type with space
    local targetFacility = nil
    for key, facility in pairs(base.facilities) do
        if facility.type == facilityType and facility.personnel < facility.maxPersonnel then
            targetFacility = facility
            break
        end
    end
    
    if not targetFacility then
        print("[BaseManager] ERROR: No available " .. facilityType)
        return false
    end
    
    table.insert(targetFacility.assignedPersonnel, unitId)
    targetFacility.personnel = targetFacility.personnel + 1
    
    print(string.format("[BaseManager] Assigned unit %s to %s",
        unitId, facilityType))
    
    return true
end

--- Remove personnel from facility
---@param baseId string Base ID
---@param unitId string Unit ID
---@param facilityType string Facility type
---@return boolean Success
function BaseManager:removePersonnel(baseId, unitId, facilityType)
    local base = self:getBase(baseId)
    if not base then
        return false
    end
    
    -- Find facility and remove unit
    for key, facility in pairs(base.facilities) do
        if facility.type == facilityType then
            for i, id in ipairs(facility.assignedPersonnel) do
                if id == unitId then
                    table.remove(facility.assignedPersonnel, i)
                    facility.personnel = math.max(0, facility.personnel - 1)
                    
                    print(string.format("[BaseManager] Removed unit %s from %s",
                        unitId, facilityType))
                    
                    return true
                end
            end
        end
    end
    
    return false
end

--- Get facility at grid position
---@param baseId string Base ID
---@param x number Grid X
---@param y number Grid Y
---@return table? Facility or nil
function BaseManager:getFacilityAt(baseId, x, y)
    local base = self:getBase(baseId)
    if not base then
        return nil
    end
    
    local key = x .. "_" .. y
    return base.facilities[key]
end

--- Get all facilities
---@param baseId string Base ID
---@return table List of facilities
function BaseManager:getAllFacilities(baseId)
    local base = self:getBase(baseId)
    if not base then
        return {}
    end
    
    local facilities = {}
    for key, facility in pairs(base.facilities) do
        table.insert(facilities, facility)
    end
    return facilities
end

--- Add resources to base
---@param baseId string Base ID
---@param credits number Credits
---@param materials number Materials
---@param supplies number Supplies
---@return boolean Success
function BaseManager:addResources(baseId, credits, materials, supplies)
    local base = self:getBase(baseId)
    if not base then
        return false
    end
    
    base.credits = base.credits + (credits or 0)
    base.materials = base.materials + (materials or 0)
    base.supplies = base.supplies + (supplies or 0)
    
    print(string.format("[BaseManager] Added resources: $%d + %d materials + %d supplies",
        credits or 0, materials or 0, supplies or 0))
    
    return true
end

--- Consume resources from base
---@param baseId string Base ID
---@param credits number Credits
---@param materials number Materials
---@param supplies number Supplies
---@return boolean Success
function BaseManager:consumeResources(baseId, credits, materials, supplies)
    local base = self:getBase(baseId)
    if not base then
        return false
    end
    
    if base.credits < credits or base.materials < materials or base.supplies < supplies then
        print("[BaseManager] ERROR: Insufficient resources")
        return false
    end
    
    base.credits = base.credits - credits
    base.materials = base.materials - materials
    base.supplies = base.supplies - supplies
    
    return true
end

--- Get base status
---@param baseId string Base ID
---@return table Status
function BaseManager:getBaseStatus(baseId)
    local base = self:getBase(baseId)
    if not base then
        return {status = "not_found"}
    end
    
    return {
        id = base.id,
        name = base.name,
        province = base.province,
        credits = base.credits,
        materials = base.materials,
        supplies = base.supplies,
        facilitiesCount = self:countFacilities(baseId),
        personnelCount = #base.scientists + #base.engineers + #base.soldiers + #base.staff,
        health = base.health,
        morale = base.morale
    }
end

--- Count facilities
---@param baseId string Base ID
---@return number Count
function BaseManager:countFacilities(baseId)
    local base = self:getBase(baseId)
    if not base then
        return 0
    end
    
    local count = 0
    for _ in pairs(base.facilities) do
        count = count + 1
    end
    return count
end

--- Get base summary
---@param baseId string Base ID
---@return string Summary
function BaseManager:getStatus(baseId)
    baseId = baseId or self.primaryBase
    local base = self:getBase(baseId)
    if not base then
        return "Base not found"
    end
    
    return string.format(
        "Base: %s\n" ..
        "  Facilities: %d | Personnel: %d\n" ..
        "  Credits: $%d | Materials: %d | Supplies: %d\n" ..
        "  Health: %d%% | Morale: %d%%",
        base.name,
        self:countFacilities(baseId),
        #base.scientists + #base.engineers + #base.soldiers + #base.staff,
        base.credits,
        base.materials,
        base.supplies,
        base.health,
        base.morale
    )
end

--- Serialize for save/load
---@return table Serialized data
function BaseManager:serialize()
    return {
        bases = self.bases,
        nextId = self.nextId,
        primaryBase = self.primaryBase
    }
end

--- Deserialize from save/load
---@param data table Serialized data
function BaseManager:deserialize(data)
    self.bases = data.bases
    self.nextId = data.nextId
    self.primaryBase = data.primaryBase
    print("[BaseManager] Deserialized from save")
end

return BaseManager



