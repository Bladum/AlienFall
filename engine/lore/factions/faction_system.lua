---Faction System - Enemy Groups and Organizations
---
---Manages enemy factions with unique lore, units, research trees, and campaigns.
---Each faction represents a distinct threat with its own identity, goals, and
---progression path. Core system for strategic variety and narrative.
---
---Faction Properties:
---  - Identity: Name, lore, description, visual theme
---  - Units: Faction-specific unit types and variants
---  - Items: Unique weapons, armor, and equipment
---  - Research: Technology unlock tree
---  - Campaigns: Mission generation scripts
---  - Relations: Starting diplomatic stance
---
---Example Factions:
---  - Aliens: Classic X-COM enemies (Sectoids, Mutons, Chryssalids)
---  - Cult: Human collaborators with alien tech
---  - MegaCorp: Corporate mercenaries with advanced equipment
---  - Resistance: Anti-alien guerrillas
---
---Key Exports:
---  - FactionSystem.new(): Creates faction system instance
---  - registerFaction(faction): Adds faction to game
---  - getFaction(factionId): Returns faction data
---  - getUnits(factionId): Returns faction unit types
---  - getResearchTree(factionId): Returns tech tree
---  - getCampaigns(factionId): Returns active campaigns
---
---Dependencies:
---  - shared.units.units: Unit definitions
---  - shared.items: Item definitions
---  - economy.research: Research tree system
---  - lore.campaign: Campaign system
---
---@module lore.factions.faction_system
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local FactionSystem = require("lore.factions.faction_system")
---  local factions = FactionSystem.new()
---  local aliens = factions:getFaction("faction_aliens")
---  print(aliens.name)  -- "Sectoid Empire"
---
---@see lore.campaign For faction campaigns
---@see shared.units For unit definitions

local FactionSystem = {}
FactionSystem.__index = FactionSystem

---@class Faction
---@field id string Faction ID
---@field name string Display name
---@field description string Lore description
---@field units table Array of unit IDs
---@field items table Array of item IDs
---@field researchTree table Research unlock tree
---@field campaigns table Array of campaign IDs
---@field relations number Starting relations (-2 to +2)
---@field isActive boolean Is faction active
---@field campaignsDisabled boolean Campaigns disabled by research
---@field isHostile boolean Faction is hostile

--- Create new faction system
function FactionSystem.new()
    local self = setmetatable({}, FactionSystem)
    
    -- All factions
    self.factions = {}
    
    -- Faction research progress (tracks player's research into each faction)
    self.researchProgress = {}
    
    print("[FactionSystem] Initialized")
    return self
end

--- Add faction
---@param faction Faction Faction data
function FactionSystem:addFaction(faction)
    -- Validate faction
    if not faction.id or not faction.name then
        print("[FactionSystem] Invalid faction data")
        return false
    end
    
    -- Set defaults
    faction.units = faction.units or {}
    faction.items = faction.items or {}
    faction.researchTree = faction.researchTree or {}
    faction.campaigns = faction.campaigns or {}
    faction.relations = faction.relations or 0
    faction.isActive = faction.isActive ~= false  -- Default true
    
    self.factions[faction.id] = faction
    self.researchProgress[faction.id] = 0  -- 0-100%
    
    print("[FactionSystem] Added faction: " .. faction.name)
    return true
end

--- Get faction
---@param factionId string Faction ID
---@return Faction|nil Faction
function FactionSystem:getFaction(factionId)
    return self.factions[factionId]
end

--- Get all active factions
---@return table Array of factions
function FactionSystem:getActiveFactions()
    local active = {}
    
    for _, faction in pairs(self.factions) do
        if faction.isActive then
            table.insert(active, faction)
        end
    end
    
    return active
end

--- Update research progress for faction
---@param factionId string Faction ID
---@param progress number Progress (0-100)
function FactionSystem:setResearchProgress(factionId, progress)
    self.researchProgress[factionId] = math.max(0, math.min(100, progress))
    
    -- Check if faction is researched completely
    if progress >= 100 then
        self:onFactionResearchComplete(factionId)
    end
end

--- Get research progress for faction
---@param factionId string Faction ID
---@return number Progress (0-100)
function FactionSystem:getResearchProgress(factionId)
    return self.researchProgress[factionId] or 0
end

--- Handle faction research completion
---@param factionId string Faction ID
function FactionSystem:onFactionResearchComplete(factionId)
    local faction = self:getFaction(factionId)
    if not faction then return end
    
    print("[FactionSystem] FACTION RESEARCH COMPLETE: " .. faction.name)
    print("[FactionSystem] Disabling faction campaigns...")
    
    -- This would disable faction's campaigns
    faction.campaignsDisabled = true
end

--- Get faction by unit type
---@param unitType string Unit type ID
---@return Faction|nil Faction
function FactionSystem:getFactionByUnit(unitType)
    for _, faction in pairs(self.factions) do
        for _, unitId in ipairs(faction.units) do
            if unitId == unitType then
                return faction
            end
        end
    end
    return nil
end

--- Modify faction relations
---@param factionId string Faction ID
---@param delta number Relations change (-2 to +2)
---@param reason string Reason
function FactionSystem:modifyRelations(factionId, delta, reason)
    local faction = self:getFaction(factionId)
    if not faction then return end
    
    local oldRelations = faction.relations
    faction.relations = math.max(-2, math.min(2, faction.relations + delta))
    
    print(string.format("[FactionSystem] %s relations: %+.1f (%s) → %.1f → %.1f", 
          faction.name, delta, reason, oldRelations, faction.relations))
    
    -- Check for hostile threshold
    if faction.relations <= -2 and oldRelations > -2 then
        self:onFactionHostile(factionId)
    end
end

--- Handle faction becoming hostile
---@param factionId string Faction ID
function FactionSystem:onFactionHostile(factionId)
    local faction = self:getFaction(factionId)
    if not faction then return end
    
    print("[FactionSystem] FACTION NOW HOSTILE: " .. faction.name)
    print("[FactionSystem] Triggering base assault missions...")
    
    -- This would trigger special missions (e.g., base assault)
    faction.isHostile = true
end

--- Check if faction is hostile
---@param factionId string Faction ID
---@return boolean Is hostile
function FactionSystem:isHostile(factionId)
    local faction = self:getFaction(factionId)
    if not faction then return false end
    return faction.isHostile == true
end

--- Check if faction campaigns are disabled
---@param factionId string Faction ID
---@return boolean Disabled
function FactionSystem:areCampaignsDisabled(factionId)
    local faction = self:getFaction(factionId)
    if not faction then return false end
    return faction.campaignsDisabled == true
end

--- Save state
---@return table State
function FactionSystem:saveState()
    return {
        factions = self.factions,
        researchProgress = self.researchProgress,
    }
end

--- Load state
---@param state table Saved state
function FactionSystem:loadState(state)
    self.factions = state.factions or {}
    self.researchProgress = state.researchProgress or {}
    
    print("[FactionSystem] State loaded: " .. self:countFactions() .. " factions")
end

--- Count total factions
---@return number Count
function FactionSystem:countFactions()
    local count = 0
    for _ in pairs(self.factions) do
        count = count + 1
    end
    return count
end

--- Print faction report
function FactionSystem:printReport()
    print("[FactionSystem] === FACTION REPORT ===")
    
    for _, faction in pairs(self.factions) do
        local status = faction.isActive and "ACTIVE" or "INACTIVE"
        local research = self.researchProgress[faction.id] or 0
        local relations = faction.relations or 0
        
        print(string.format("  %s [%s]", faction.name, status))
        print(string.format("    Research: %.0f%%", research))
        print(string.format("    Relations: %.1f", relations))
        print(string.format("    Units: %d types", #faction.units))
        print(string.format("    Campaigns: %d", #faction.campaigns))
    end
    
    print("=====================================")
end

return FactionSystem


























