---Perk System Module
---
---Manages unit perks - boolean trait flags that affect unit behavior and capabilities.
---Perks are organized into categories and can be enabled/disabled per unit.
---
---Key Features:
---  - Perk registration and management
---  - Per-unit perk tracking
---  - Category-based organization
---  - TOML loading support
---  - Runtime enable/disable
---
---Key Exports:
---  - PerkSystem.register() - Register a new perk definition
---  - PerkSystem.hasPerk() - Check if unit has a perk
---  - PerkSystem.enablePerk() - Enable a perk for a unit
---  - PerkSystem.disablePerk() - Disable a perk for a unit
---  - PerkSystem.togglePerk() - Toggle perk on/off
---  - PerkSystem.getActivePerks() - Get all active perks for unit
---  - PerkSystem.loadFromTOML() - Load perks from TOML data
---
---Dependencies:
---  - None (standalone system)
---
---@module PerkSystem
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source

local PerkSystem = {}

---Global perk registry - maps perk ID to perk definition
---@type table<string, table>
PerkSystem.registry = {}

---Per-unit perk state - maps unit_id to table of {perk_id -> boolean}
---@type table<number, table<string, boolean>>
PerkSystem.unitPerks = {}

---Perk categories for organization
---@type table<string, string>
PerkSystem.categories = {
    basic = "Basic Abilities",
    movement = "Movement",
    combat = "Combat",
    senses = "Senses",
    defense = "Defense",
    survival = "Survival",
    social = "Social",
    special = "Special",
    flight = "Flight",
}

---Register a new perk definition
---@param id string - Unique perk identifier (e.g., "can_move")
---@param name string - Display name (e.g., "Can Move")
---@param description string - Detailed description
---@param category string - Category key (basic, movement, combat, etc.)
---@param enabled boolean - Whether enabled by default (optional, default false)
---@return boolean - Success indicator
function PerkSystem.register(id, name, description, category, enabled)
    if not id or not name or not category then
        print("[PerkSystem] ERROR: Missing required parameters for perk registration")
        return false
    end
    
    PerkSystem.registry[id] = {
        id = id,
        name = name,
        description = description,
        category = category,
        enabled_by_default = enabled or false,
        created_at = os.time(),
    }
    
    print(string.format("[PerkSystem] Registered perk: %s (%s)", id, name))
    return true
end

---Check if a unit has a specific perk
---@param unitId number - Unit ID
---@param perkId string - Perk ID to check
---@return boolean - True if unit has the perk enabled
function PerkSystem.hasPerk(unitId, perkId)
    if not unitId or not perkId then
        return false
    end
    
    if not PerkSystem.unitPerks[unitId] then
        return false
    end
    
    local has = PerkSystem.unitPerks[unitId][perkId] or false
    return has
end

---Enable a perk for a unit
---@param unitId number - Unit ID
---@param perkId string - Perk ID to enable
---@return boolean - Success indicator
function PerkSystem.enablePerk(unitId, perkId)
    if not unitId or not perkId then
        return false
    end
    
    -- Verify perk exists in registry
    if not PerkSystem.registry[perkId] then
        print(string.format("[PerkSystem] WARNING: Perk '%s' not found in registry", perkId))
        return false
    end
    
    -- Initialize unit perks table if needed
    if not PerkSystem.unitPerks[unitId] then
        PerkSystem.unitPerks[unitId] = {}
    end
    
    -- Enable the perk
    PerkSystem.unitPerks[unitId][perkId] = true
    print(string.format("[PerkSystem] Enabled perk '%s' for unit %d", perkId, unitId))
    
    return true
end

---Disable a perk for a unit
---@param unitId number - Unit ID
---@param perkId string - Perk ID to disable
function PerkSystem.disablePerk(unitId, perkId)
    if not unitId or not perkId then
        return
    end
    
    if not PerkSystem.unitPerks[unitId] then
        return
    end
    
    PerkSystem.unitPerks[unitId][perkId] = false
    print(string.format("[PerkSystem] Disabled perk '%s' for unit %d", perkId, unitId))
end

---Toggle a perk for a unit (on if off, off if on)
---@param unitId number - Unit ID
---@param perkId string - Perk ID to toggle
---@return boolean - New perk state (true = enabled, false = disabled)
function PerkSystem.togglePerk(unitId, perkId)
    if not unitId or not perkId then
        return false
    end
    
    local current = PerkSystem.hasPerk(unitId, perkId)
    
    if current then
        PerkSystem.disablePerk(unitId, perkId)
        return false
    else
        PerkSystem.enablePerk(unitId, perkId)
        return true
    end
end

---Get all active perks for a unit
---@param unitId number - Unit ID
---@return table - Table of active perk IDs (or empty table)
function PerkSystem.getActivePerks(unitId)
    if not unitId or not PerkSystem.unitPerks[unitId] then
        return {}
    end
    
    local active = {}
    for perkId, enabled in pairs(PerkSystem.unitPerks[unitId]) do
        if enabled then
            table.insert(active, perkId)
        end
    end
    
    return active
end

---Get perk definition by ID
---@param perkId string - Perk ID
---@return table|nil - Perk definition or nil if not found
function PerkSystem.getPerk(perkId)
    return PerkSystem.registry[perkId]
end

---Get all perks in a specific category
---@param category string - Category key
---@return table - Array of perk IDs in that category
function PerkSystem.getByCategory(category)
    local results = {}
    
    for perkId, definition in pairs(PerkSystem.registry) do
        if definition.category == category then
            table.insert(results, perkId)
        end
    end
    
    return results
end

---Initialize unit perks from class defaults
---@param unitId number - Unit ID
---@param defaultPerks table - Array of perk IDs to initialize
function PerkSystem.initializeUnitPerks(unitId, defaultPerks)
    if not unitId then
        return
    end
    
    if not PerkSystem.unitPerks[unitId] then
        PerkSystem.unitPerks[unitId] = {}
    end
    
    if defaultPerks and type(defaultPerks) == "table" then
        for _, perkId in ipairs(defaultPerks) do
            PerkSystem.enablePerk(unitId, perkId)
        end
    end
end

---Load perks from TOML configuration data
---@param tomlData table - TOML table containing perk definitions
---@return number - Count of perks loaded
function PerkSystem.loadFromTOML(tomlData)
    if not tomlData or not tomlData.perks then
        print("[PerkSystem] WARNING: No perks found in TOML data")
        return 0
    end
    
    local count = 0
    for _, perkDef in ipairs(tomlData.perks) do
        if perkDef.id and perkDef.name and perkDef.category then
            PerkSystem.register(
                perkDef.id,
                perkDef.name,
                perkDef.description or "",
                perkDef.category,
                perkDef.enabled_by_default or false
            )
            count = count + 1
        end
    end
    
    print(string.format("[PerkSystem] Loaded %d perks from TOML", count))
    return count
end

---Get system statistics
---@return table - Statistics about registered and active perks
function PerkSystem.getStats()
    local registeredCount = 0
    for _ in pairs(PerkSystem.registry) do
        registeredCount = registeredCount + 1
    end
    
    local unitsWithPerks = 0
    local totalPerksAssigned = 0
    for unitId, perks in pairs(PerkSystem.unitPerks) do
        unitsWithPerks = unitsWithPerks + 1
        for _, enabled in pairs(perks) do
            if enabled then
                totalPerksAssigned = totalPerksAssigned + 1
            end
        end
    end
    
    return {
        registered_perks = registeredCount,
        units_with_perks = unitsWithPerks,
        total_perks_assigned = totalPerksAssigned,
    }
end

---Reset all perk data (for testing/debugging)
function PerkSystem.reset()
    PerkSystem.registry = {}
    PerkSystem.unitPerks = {}
    print("[PerkSystem] All perk data reset")
end

return PerkSystem
