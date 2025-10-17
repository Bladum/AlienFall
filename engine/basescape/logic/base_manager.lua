---BaseManager - Global base management system
---
---Manages all player bases:
---  - Create/delete bases
---  - Track all bases
---  - Global finance management
---  - Facility transfers between bases
---  - Daily update all bases
---
---@module basescape.logic.base_manager
---@author AlienFall Development Team

local Base = require("basescape.logic.base")

local BaseManager = {}

-- Singleton instance
BaseManager.instance = nil

---Initialize the base manager
---@return table manager Manager instance
function BaseManager.initialize()
    if BaseManager.instance then
        return BaseManager.instance
    end
    
    local manager = {
        bases = {},  -- Map: base_id -> Base instance
        basesArray = {},  -- Array for ordered access
        globalCredits = 5000000,
        globalMaintenance = 0,
    }
    
    BaseManager.instance = manager
    print("[BaseManager] Initialized")
    return manager
end

---Get singleton instance
---@return table manager The manager instance
function BaseManager.getInstance()
    if not BaseManager.instance then
        error("[BaseManager] Not initialized! Call initialize() first")
    end
    return BaseManager.instance
end

---Create a new base
---@param name string Base name
---@param region string Region location
---@param credits number Starting credits (optional)
---@return table base The new base instance
function BaseManager.createBase(name, region, credits)
    local manager = BaseManager.getInstance()
    
    local base = Base.new({
        name = name,
        region = region,
        credits = credits or 500000,
    })
    
    manager.bases[base.id] = base
    table.insert(manager.basesArray, base.id)
    
    print(string.format("[BaseManager] Created base: %s at %s", name, region))
    
    return base
end

---Get base by ID
---@param baseId string Base ID
---@return table? base The base instance or nil
function BaseManager.getBase(baseId)
    local manager = BaseManager.getInstance()
    return manager.bases[baseId]
end

---Get all bases
---@return table bases Array of base IDs
function BaseManager.getAllBases()
    local manager = BaseManager.getInstance()
    return manager.basesArray
end

---Delete a base (if conditions met)
---@param baseId string Base ID
---@return boolean success True if deleted
function BaseManager.deleteBase(baseId)
    local manager = BaseManager.getInstance()
    local base = manager.bases[baseId]
    
    if not base then
        return false
    end
    
    -- Cannot delete last base
    if #manager.basesArray == 1 then
        return false
    end
    
    -- Cannot delete base with active construction
    if #base.facilityQueue > 0 then
        return false
    end
    
    manager.bases[baseId] = nil
    for i, bid in ipairs(manager.basesArray) do
        if bid == baseId then
            table.remove(manager.basesArray, i)
            break
        end
    end
    
    print(string.format("[BaseManager] Deleted base: %s", baseId))
    return true
end

---Transfer item/facility between bases
---@param fromBaseId string Source base ID
---@param toBaseId string Destination base ID
---@param itemId string Item ID
---@param quantity number Quantity
---@return boolean success True if transferred
---@return number? daysRequired Days for transfer to complete
function BaseManager.transferItem(fromBaseId, toBaseId, itemId, quantity)
    local manager = BaseManager.getInstance()
    
    local fromBase = manager.bases[fromBaseId]
    local toBase = manager.bases[toBaseId]
    
    if not fromBase or not toBase then
        return false, nil
    end
    
    -- Calculate transfer time based on distance and quantity
    -- Simplified: use region distance
    local daysRequired = 3 + (quantity * 0.1)  -- Base 3 days + 0.1 per item
    
    print(string.format("[BaseManager] Transfer queued: %s items from %s to %s (%d days)",
        quantity, fromBase.name, toBase.name, daysRequired))
    
    return true, daysRequired
end

---Update all bases daily
---@param daysElapsed number Days to advance (default 1)
function BaseManager.updateAllBases(daysElapsed)
    local manager = BaseManager.getInstance()
    
    daysElapsed = daysElapsed or 1
    
    for _, baseId in ipairs(manager.basesArray) do
        local base = manager.bases[baseId]
        if base then
            Base.update(base, daysElapsed)
        end
    end
end

---Get total global maintenance costs
---@return number total Total monthly maintenance
function BaseManager.getGlobalMaintenance()
    local manager = BaseManager.getInstance()
    local total = 0
    
    for _, baseId in ipairs(manager.basesArray) do
        local base = manager.bases[baseId]
        if base then
            total = total + base.monthlyMaintenance
        end
    end
    
    return total
end

---Get total credits across all bases
---@return number total Total credits
function BaseManager.getTotalCredits()
    local manager = BaseManager.getInstance()
    local total = 0
    
    for _, baseId in ipairs(manager.basesArray) do
        local base = manager.bases[baseId]
        if base then
            total = total + base.credits
        end
    end
    
    return total
end

---Print all bases summary
function BaseManager.printAllBases()
    local manager = BaseManager.getInstance()
    
    print("\n[BaseManager] All Bases Summary")
    print("=====================================================")
    
    for _, baseId in ipairs(manager.basesArray) do
        local base = manager.bases[baseId]
        if base then
            print(string.format("  %s (ID: %s)", base.name, baseId))
            print(string.format("    Region: %s", base.region))
            print(string.format("    Credits: %d", base.credits))
            local facCount = 0
            for _, _ in pairs(base.facilities) do
                facCount = facCount + 1
            end
            print(string.format("    Facilities: %d", facCount))
            print(string.format("    Maintenance: %d cr/month", base.monthlyMaintenance))
        end
    end
    
    print("=====================================================")
    print(string.format("Total Credits: %d", BaseManager.getTotalCredits()))
    print(string.format("Global Maintenance: %d cr/month\n", BaseManager.getGlobalMaintenance()))
end

return BaseManager
