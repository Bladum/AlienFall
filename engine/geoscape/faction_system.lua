--- Faction System
--- Manages alien factions, their research, lore arcs, and faction-specific gameplay
---
--- Factions are the primary enemy forces in AlienFall. Each faction has:
--- - Research trees defining technology progression
--- - Lore arcs providing narrative progression
--- - Campaign resolution affecting world state
--- - Mission generation patterns
--- - Strategic behavior and target priorities
---
--- @class FactionSystem
local FactionSystem = {}

--- Initialize faction system
--- Loads faction data from mods and initializes faction state tracking
function FactionSystem:new()
    local self = setmetatable({}, { __index = FactionSystem })
    
    self.factions = {}  -- id -> faction state
    self.activeFactions = {}  -- list of currently active faction ids
    self.research = {}  -- faction_id -> {tech_id -> progress}
    self.campaigns = {}  -- faction_id -> campaign state
    
    print("[FactionSystem] Initialized")
    return self
end

--- Load faction data from mod configuration
--- @param factionId string Unique faction identifier
--- @param factionData table Faction configuration from TOML
function FactionSystem:loadFaction(factionId, factionData)
    if not factionData then
        print("[FactionSystem] Warning: No data for faction " .. factionId)
        return nil
    end
    
    local faction = {
        id = factionId,
        name = factionData.name or "Unknown Faction",
        description = factionData.description or "",
        baseSpecies = factionData.base_species or "unknown",
        researchTree = factionData.research_tree or {},
        loreArcs = factionData.lore_arcs or {},
        missions = factionData.missions or {},
        active = false,
        researchProgress = {},
        loreUnlocked = {},
        campaignPhase = 0,
    }
    
    -- Initialize research progress
    for techId, _ in pairs(faction.researchTree) do
        faction.researchProgress[techId] = 0
    end
    
    self.factions[factionId] = faction
    print("[FactionSystem] Loaded faction: " .. factionId)
    return faction
end

--- Activate a faction for gameplay
--- @param factionId string Faction to activate
function FactionSystem:activateFaction(factionId)
    if not self.factions[factionId] then
        print("[FactionSystem] Error: Faction not found: " .. factionId)
        return false
    end
    
    local faction = self.factions[factionId]
    faction.active = true
    table.insert(self.activeFactions, factionId)
    print("[FactionSystem] Activated faction: " .. factionId)
    return true
end

--- Get faction by ID
--- @param factionId string
--- @return table|nil Faction data or nil if not found
function FactionSystem:getFaction(factionId)
    return self.factions[factionId]
end

--- Advance faction research
--- @param factionId string
--- @param techId string Technology to research
--- @param amount number Research points to add
function FactionSystem:advanceResearch(factionId, techId, amount)
    local faction = self.factions[factionId]
    if not faction then return false end
    
    if not faction.researchProgress[techId] then
        faction.researchProgress[techId] = 0
    end
    
    faction.researchProgress[techId] = faction.researchProgress[techId] + amount
    
    -- Check for research completion
    local techData = faction.researchTree[techId]
    if techData and faction.researchProgress[techId] >= (techData.cost or 100) then
        self:completeResearch(factionId, techId)
    end
    
    return true
end

--- Complete faction research, unlocking new content and lore
--- @param factionId string
--- @param techId string
function FactionSystem:completeResearch(factionId, techId)
    local faction = self.factions[factionId]
    if not faction then return end
    
    local techData = faction.researchTree[techId]
    if not techData then return end
    
    faction.researchProgress[techId] = (techData.cost or 100)
    
    -- Unlock related lore
    if techData.unlocks_lore then
        for _, loreId in ipairs(techData.unlocks_lore) do
            table.insert(faction.loreUnlocked, loreId)
        end
    end
    
    -- Trigger narrative hook for research discovery
    if techData.narrative_hook then
        self:triggerNarrativeHook(factionId, techData.narrative_hook)
    end
    
    print("[FactionSystem] Faction " .. factionId .. " completed research: " .. techId)
end

--- Trigger narrative event for faction research
--- @param factionId string
--- @param narrativeHookId string
function FactionSystem:triggerNarrativeHook(factionId, narrativeHookId)
    -- Would integrate with narrative hooks system
    print("[FactionSystem] Narrative hook triggered: " .. narrativeHookId .. " for faction: " .. factionId)
end

--- Get all active factions
--- @return table Array of active faction IDs
function FactionSystem:getActiveFactions()
    return self.activeFactions
end

--- Get faction campaign phase
--- @param factionId string
--- @return number Campaign phase (0-3)
function FactionSystem:getCampaignPhase(factionId)
    local faction = self.factions[factionId]
    return faction and faction.campaignPhase or 0
end

--- Advance faction campaign phase
--- @param factionId string
--- @param newPhase number New campaign phase
function FactionSystem:advanceCampaignPhase(factionId, newPhase)
    local faction = self.factions[factionId]
    if faction then
        faction.campaignPhase = newPhase
        print("[FactionSystem] Faction " .. factionId .. " advanced to campaign phase " .. newPhase)
    end
end

return FactionSystem



