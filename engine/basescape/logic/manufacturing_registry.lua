---ManufacturingRegistry - Central manufacturing type registry
---
---Maintains all manufacturing entry definitions.
---
---@module basescape.logic.manufacturing_registry
---@author AlienFall Development Team

local ManufacturingEntry = require("basescape.logic.manufacturing_entry")

local ManufacturingRegistry = {}

-- Singleton instance
ManufacturingRegistry.instance = nil

---Initialize the manufacturing registry
---@param modManager table Mod manager instance
---@return table registry Registry instance
function ManufacturingRegistry.initialize(modManager)
    if ManufacturingRegistry.instance then
        return ManufacturingRegistry.instance
    end
    
    local registry = {
        entries = {},  -- Map: manufacturing_id -> ManufacturingEntry
        entriesByCategory = {},  -- Map: category -> array of entry IDs
        entriesByType = {},  -- Map: type -> array of entry IDs
        modManager = modManager,
    }
    
    -- Load default manufacturing entries
    ManufacturingRegistry._loadDefaultEntries(registry)
    
    ManufacturingRegistry.instance = registry
    print("[ManufacturingRegistry] Initialized")
    return registry
end

---Load default manufacturing entries
---@param registry table The registry
function ManufacturingRegistry._loadDefaultEntries(registry)
    local entries = {
        -- Weapons
        {
            id = "laser_rifle",
            name = "Laser Rifle",
            description = "Advanced energy weapon",
            productionType = "item",
            baselineManDays = 50,
            credits = 5000,
            inputItems = {
                {id = "alien_alloys", quantity = 2},
                {id = "power_cell", quantity = 1},
            },
            outputs = {{id = "laser_rifle", quantity = 1}},
            category = "weapons",
            requiredResearch = {"plasma_weapons"},
            requiredFacilities = {"workshop"},
            requiredServices = {"power", "workshop"},
        },
        
        {
            id = "plasma_rifle",
            name = "Plasma Rifle",
            description = "Experimental plasma weapon",
            productionType = "item",
            baselineManDays = 80,
            credits = 12000,
            inputItems = {
                {id = "alien_alloys", quantity = 3},
                {id = "power_cell", quantity = 2},
                {id = "elerium", quantity = 1},
            },
            outputs = {{id = "plasma_rifle", quantity = 1}},
            category = "weapons",
            requiredResearch = {"plasma_weapons"},
            requiredFacilities = {"workshop"},
            requiredServices = {"power", "workshop"},
        },
        
        -- Armor
        {
            id = "combat_suit",
            name = "Combat Suit",
            description = "Basic protective armor",
            productionType = "item",
            baselineManDays = 40,
            credits = 3000,
            inputItems = {
                {id = "alien_alloys", quantity = 1},
            },
            outputs = {{id = "combat_suit", quantity = 1}},
            category = "armor",
            requiredResearch = {"advanced_armor"},
            requiredFacilities = {"workshop"},
            requiredServices = {"power"},
        },
        
        {
            id = "plasma_armor",
            name = "Plasma Armor",
            description = "Advanced alien armor",
            productionType = "item",
            baselineManDays = 60,
            credits = 8000,
            inputItems = {
                {id = "alien_alloys", quantity = 3},
                {id = "elerium", quantity = 1},
            },
            outputs = {{id = "plasma_armor", quantity = 1}},
            category = "armor",
            requiredResearch = {"advanced_armor"},
            requiredFacilities = {"workshop"},
            requiredServices = {"power", "workshop"},
        },
        
        -- Equipment
        {
            id = "medkit",
            name = "Medkit",
            description = "Field medical equipment",
            productionType = "item",
            baselineManDays = 10,
            credits = 500,
            inputItems = {},
            outputs = {{id = "medkit", quantity = 1}},
            category = "equipment",
            requiredFacilities = {"workshop"},
            requiredServices = {"power"},
        },
        
        {
            id = "alloy_cannon",
            name = "Alloy Cannon",
            description = "Heavy weapon mount",
            productionType = "item",
            baselineManDays = 100,
            credits = 20000,
            inputItems = {
                {id = "alien_alloys", quantity = 5},
                {id = "power_cell", quantity = 3},
            },
            outputs = {{id = "alloy_cannon", quantity = 1}},
            category = "weapons",
            requiredResearch = {"plasma_weapons", "advanced_armor"},
            requiredFacilities = {"workshop"},
            requiredServices = {"power", "workshop"},
        },
    }
    
    for _, data in ipairs(entries) do
        local entry = ManufacturingEntry.new(data)
        ManufacturingRegistry._registerEntry(registry, entry)
    end
    
    print("[ManufacturingRegistry] Loaded " .. #entries .. " manufacturing entries")
end

---Register a manufacturing entry
---@param registry table The registry
---@param entry table ManufacturingEntry instance
function ManufacturingRegistry._registerEntry(registry, entry)
    registry.entries[entry.id] = entry
    
    if not registry.entriesByCategory[entry.category] then
        registry.entriesByCategory[entry.category] = {}
    end
    table.insert(registry.entriesByCategory[entry.category], entry.id)
    
    if not registry.entriesByType[entry.productionType] then
        registry.entriesByType[entry.productionType] = {}
    end
    table.insert(registry.entriesByType[entry.productionType], entry.id)
end

---Get singleton instance
---@return table registry The registry instance
function ManufacturingRegistry.getInstance()
    if not ManufacturingRegistry.instance then
        error("[ManufacturingRegistry] Not initialized! Call initialize() first")
    end
    return ManufacturingRegistry.instance
end

---Get manufacturing entry by ID
---@param entryId string Manufacturing entry ID
---@return table? entry The entry or nil
function ManufacturingRegistry.getEntry(entryId)
    local registry = ManufacturingRegistry.getInstance()
    return registry.entries[entryId]
end

---Get all entries by category
---@param category string Category name
---@return table entryIds Array of entry IDs
function ManufacturingRegistry.getByCategory(category)
    local registry = ManufacturingRegistry.getInstance()
    return registry.entriesByCategory[category] or {}
end

---Get all entries by type
---@param productionType string Production type (item, unit, craft)
---@return table entryIds Array of entry IDs
function ManufacturingRegistry.getByType(productionType)
    local registry = ManufacturingRegistry.getInstance()
    return registry.entriesByType[productionType] or {}
end

---Print all entries
function ManufacturingRegistry.printEntries()
    local registry = ManufacturingRegistry.getInstance()
    print("\n[ManufacturingRegistry] Manufacturing Entries")
    print("=============================================")
    
    for entryId, entry in pairs(registry.entries) do
        print(string.format("  %s: %s (%d man-days)", entryId, entry.name, entry.baselineManDays))
    end
    
    print("=============================================\n")
end

return ManufacturingRegistry
