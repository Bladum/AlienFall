---Lore Manager - Campaign Narrative and Faction Content
---
---Manages faction lore, technology catalogs, research discoveries, and narrative
---events. Provides lore content discovered through research, interrogations,
---missions, and diplomacy. Unlocks content as campaign progresses.
---
---Supported Content:
---  - Factions: Lore, motivations, resolution paths, technology
---  - Technology: Phase-based progression, research trees, costs
---  - Discoveries: Research findings, interrogation results
---  - Narrative Events: Story triggers, mission briefings, endings
---  - Materials: Salvageable items, alien artifacts, research subjects
---
---Faction Categories:
---  - Supernatural Entities (Shadow War)
---  - Terrestrial Aliens (Sky War)
---  - Reticulan Cabal (Sky War - Deep War)
---  - Aquatic Species (Deep War)
---  - Dimensional Species (Dimensional War)
---
---Key Exports:
---  - LoreManager.init(): Load all lore content
---  - LoreManager.getFaction(id): Get faction data
---  - LoreManager.getTechnology(id): Get technology data
---  - LoreManager.getDiscovery(id): Get research discovery
---  - LoreManager.getNarrativeEvent(id): Get story event
---  - LoreManager.unlockContent(type, id): Unlock discovered content
---  - LoreManager.isUnlocked(type, id): Check if content discovered
---
---Dependencies:
---  - mods.mod_manager: Load lore TOML files
---  - geoscape.campaign_manager: Check current phase
---
---@module lore.lore_manager
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local LoreManager = require("lore.lore_manager")
---  LoreManager.init()
---  
---  -- Get faction information
---  local faction = LoreManager.getFaction("reticulan_cabal")
---  print(faction.name .. ": " .. faction.backstory)
---  
---  -- Unlock research discovery
---  LoreManager.unlockContent("discovery", "alien_physiology")
---  
---  -- Check if technology is available
---  if LoreManager.isUnlocked("technology", "plasma_rifle") then
---      -- Show in research menu
---  end
---
---@see geoscape.campaign_manager For phase checks
---@see core.event_system For narrative event triggers

local LoreManager = {}

-- Lore content storage
LoreManager.factions = {}       -- Faction data: id -> {name, backstory, phase, etc}
LoreManager.technologies = {}   -- Technology data: id -> {name, cost, phase, etc}
LoreManager.discoveries = {}    -- Research discoveries: id -> {title, description, phase}
LoreManager.narrativeEvents = {} -- Story events: id -> {title, text, phase, trigger}
LoreManager.materials = {}      -- Salvageable materials: id -> {name, description, value}

-- Unlock tracking
LoreManager.unlockedContent = {
    factions = {},      -- Set of unlocked faction IDs
    technologies = {},  -- Set of unlocked tech IDs
    discoveries = {},   -- Set of discovered research IDs
    narrativeEvents = {} -- Set of triggered narrative events
}

---Initialize lore system
---Loads all lore content from mod configuration files
function LoreManager.init()
    print("[LoreManager] Initializing lore system")
    
    local ModManager = require("mods.mod_manager")
    
    -- Load faction data
    LoreManager.factions = ModManager:loadContent("lore/factions") or {}
    print(string.format("[LoreManager] Loaded %d factions", 
        LoreManager._countTable(LoreManager.factions)))
    
    -- Load technology catalogs
    LoreManager.technologies = ModManager:loadContent("technology/catalog") or {}
    print(string.format("[LoreManager] Loaded %d technologies",
        LoreManager._countTable(LoreManager.technologies)))
    
    -- Load discovery entries
    LoreManager.discoveries = ModManager:loadContent("lore/discoveries") or {}
    print(string.format("[LoreManager] Loaded %d discoveries",
        LoreManager._countTable(LoreManager.discoveries)))
    
    -- Load narrative events
    LoreManager.narrativeEvents = ModManager:loadContent("lore/narrative_events") or {}
    print(string.format("[LoreManager] Loaded %d narrative events",
        LoreManager._countTable(LoreManager.narrativeEvents)))
    
    -- Load salvageable materials
    LoreManager.materials = ModManager:loadContent("lore/materials") or {}
    print(string.format("[LoreManager] Loaded %d materials",
        LoreManager._countTable(LoreManager.materials)))
    
    -- Initialize unlocked content based on current phase
    LoreManager:_initPhaseContent()
end

---Get faction data by ID
---@param factionId string Faction identifier
---@return table Faction data or nil
function LoreManager.getFaction(factionId)
    return LoreManager.factions[factionId]
end

---Get all factions of a specific phase
---@param phase number Campaign phase (0-3)
---@return table Array of faction data
function LoreManager.getFactionsByPhase(phase)
    local result = {}
    for id, faction in pairs(LoreManager.factions) do
        if faction.phase == phase then
            table.insert(result, faction)
        end
    end
    return result
end

---Get technology data by ID
---@param techId string Technology identifier
---@return table Technology data or nil
function LoreManager.getTechnology(techId)
    return LoreManager.technologies[techId]
end

---Get technologies available in a phase
---@param phase number Campaign phase (0-3)
---@return table Array of technology data
function LoreManager.getTechnologiesByPhase(phase)
    local result = {}
    for id, tech in pairs(LoreManager.technologies) do
        if tech.phase == phase and LoreManager.isUnlocked("technology", id) then
            table.insert(result, tech)
        end
    end
    return result
end

---Get research discovery by ID
---@param discoveryId string Discovery identifier
---@return table Discovery data or nil
function LoreManager.getDiscovery(discoveryId)
    return LoreManager.discoveries[discoveryId]
end

---Get narrative event by ID
---@param eventId string Event identifier
---@return table Event data or nil
function LoreManager.getNarrativeEvent(eventId)
    return LoreManager.narrativeEvents[eventId]
end

---Get salvageable material by ID
---@param materialId string Material identifier
---@return table Material data or nil
function LoreManager.getMaterial(materialId)
    return LoreManager.materials[materialId]
end

---Unlock content (discovery, technology, etc)
---@param contentType string Type of content: "technology", "discovery", "narrative", "faction"
---@param contentId string Content identifier
function LoreManager.unlockContent(contentType, contentId)
    if contentType == "technology" then
        LoreManager.unlockedContent.technologies[contentId] = true
        print(string.format("[LoreManager] Unlocked technology: %s", contentId))
    elseif contentType == "discovery" then
        LoreManager.unlockedContent.discoveries[contentId] = true
        print(string.format("[LoreManager] New discovery: %s", contentId))
    elseif contentType == "narrative" then
        LoreManager.unlockedContent.narrativeEvents[contentId] = true
        print(string.format("[LoreManager] Narrative event triggered: %s", contentId))
    elseif contentType == "faction" then
        LoreManager.unlockedContent.factions[contentId] = true
        print(string.format("[LoreManager] Faction encountered: %s", contentId))
    end
end

---Check if content has been unlocked/discovered
---@param contentType string Type of content
---@param contentId string Content identifier
---@return boolean True if unlocked
function LoreManager.isUnlocked(contentType, contentId)
    if contentType == "technology" then
        return LoreManager.unlockedContent.technologies[contentId] or false
    elseif contentType == "discovery" then
        return LoreManager.unlockedContent.discoveries[contentId] or false
    elseif contentType == "narrative" then
        return LoreManager.unlockedContent.narrativeEvents[contentId] or false
    elseif contentType == "faction" then
        return LoreManager.unlockedContent.factions[contentId] or false
    end
    return false
end

---Get all unlocked technologies (for research menu)
---@return table Array of available technologies
function LoreManager.getAvailableTechnologies()
    local result = {}
    for id, tech in pairs(LoreManager.technologies) do
        if LoreManager.isUnlocked("technology", id) then
            table.insert(result, tech)
        end
    end
    return result
end

---Save lore state for persistence
---@return table Unlock state data
function LoreManager.save()
    return {
        unlockedContent = LoreManager.unlockedContent
    }
end

---Load lore state from saved data
---@param data table Unlock state data
function LoreManager.load(data)
    if not data then return end
    
    LoreManager.unlockedContent = data.unlockedContent or {
        factions = {},
        technologies = {},
        discoveries = {},
        narrativeEvents = {}
    }
    
    print("[LoreManager] Lore state loaded")
end

---Internal: Initialize content unlocks based on current phase
function LoreManager:_initPhaseContent()
    local CampaignManager = require("geoscape.campaign_manager")
    local currentPhase = CampaignManager.getCurrentPhase()
    
    -- Unlock factions and tech available in current phase
    for id, faction in pairs(self.factions) do
        if faction.phase and faction.phase <= currentPhase then
            self.unlockedContent.factions[id] = true
        end
    end
    
    for id, tech in pairs(self.technologies) do
        if tech.phase and tech.phase <= currentPhase and tech.startUnlocked then
            self.unlockedContent.technologies[id] = true
        end
    end
end

---Internal: Count entries in a table
---@param tbl table Table to count
---@return number Number of entries
function LoreManager._countTable(tbl)
    local count = 0
    for _ in pairs(tbl) do count = count + 1 end
    return count
end

return LoreManager




