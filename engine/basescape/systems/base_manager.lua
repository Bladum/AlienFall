---BaseManager - Base Management System
---
---Central manager for all player bases. Handles base creation, queries,
---and global operations like maintenance deduction.
---
---@module basescape.systems.base_manager
---@author AlienFall Development Team

local Base = require("basescape.logic.base")
local FacilityRegistry = require("basescape.logic.facility_registry")

local BaseManager = {}

-- Singleton instance
BaseManager.instance = nil

-- All bases
BaseManager.bases = {}  -- Map of baseId -> Base

---Initialize the base manager
---@return BaseManager instance Manager instance
function BaseManager.initialize()
    if BaseManager.instance then
        return BaseManager.instance
    end
    
    print("[BaseManager] Initializing...")
    
    -- Load facility registry defaults
    FacilityRegistry.loadDefaults()
    
    BaseManager.instance = {
        bases = {},
    }
    
    print("[BaseManager] Initialized")
    return BaseManager.instance
end

---Get singleton instance
---@return BaseManager instance Manager instance
function BaseManager.getInstance()
    if not BaseManager.instance then
        return BaseManager.initialize()
    end
    return BaseManager.instance
end

---Create new base
---@param config table Base configuration
---@return Base base Created base
function BaseManager.createBase(config)
    local instance = BaseManager.getInstance()
    
    print(string.format("[BaseManager] Creating base: %s", config.id))
    
    local base = Base.new(config)
    base:buildHQ()
    
    instance.bases[config.id] = base
    
    return base
end

---Get base by ID
---@param baseId string Base ID
---@return Base|nil base Base or nil
function BaseManager.getBase(baseId)
    local instance = BaseManager.getInstance()
    return instance.bases[baseId]
end

---Get all bases
---@return table bases Array of bases
function BaseManager.getAllBases()
    local instance = BaseManager.getInstance()
    local result = {}
    for _, base in pairs(instance.bases) do
        table.insert(result, base)
    end
    return result
end

---Get base count
---@return number count Total bases
function BaseManager.getBaseCount()
    local instance = BaseManager.getInstance()
    local count = 0
    for _ in pairs(instance.bases) do
        count = count + 1
    end
    return count
end

---Deduct monthly maintenance for all bases
function BaseManager.deductMonthlyMaintenance()
    local instance = BaseManager.getInstance()
    
    print("[BaseManager] Deducting monthly maintenance...")
    
    for _, base in pairs(instance.bases) do
        base:deductMonthlyMaintenance()
    end
end

---Progress construction for all bases (called by calendar)
function BaseManager.progressConstructionDay()
    local instance = BaseManager.getInstance()
    
    for _, base in pairs(instance.bases) do
        base:progressConstructionDay()
    end
end

---Print all bases debug info
function BaseManager.printDebug()
    local instance = BaseManager.getInstance()
    
    print("\n================================")
    print("BASESCAPE - All Bases")
    print("================================")
    
    for _, base in pairs(instance.bases) do
        base:printDebug()
    end
end

return BaseManager
