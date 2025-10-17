---Faction Coordinator - Multi-Faction Activity Management
---
---Coordinates activities of multiple alien factions based on threat level.
---Higher threat causes more factions to activate, more UFO waves, coordinated
---attacks, and joint operations. Manages faction resource allocation, mission
---planning, and strategic decisions.
---
---Features:
---  - Multi-faction activation based on threat
---  - Resource allocation to active factions
---  - Joint operation planning (coordinated attacks)
---  - Faction preference system (primary vs secondary threats)
---  - UFO composition and wave planning
---  - Mission type selection (patrol, terror, infiltration)
---
---Key Exports:
---  - FactionCoordinator.init(): Initialize faction system
---  - FactionCoordinator.getActiveFactions(threat): Factions active at threat level
---  - FactionCoordinator.allocateResources(threat): Resource distribution
---  - FactionCoordinator.planOperations(threat): Monthly operation planning
---  - FactionCoordinator.getMissionType(faction, threat): Next mission type
---  - FactionCoordinator.getUFOComposition(): Unit composition for UFO
---
---Dependencies:
---  - lore.lore_manager: Faction data
---  - ai.strategic.threat_manager: Current threat level
---
---@module ai.strategic.faction_coordinator
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local FactionCoordinator = require("ai.strategic.faction_coordinator")
---  FactionCoordinator.init()
---  
---  local threat = ThreatManager.getThreatLevel()
---  local activeFactions = FactionCoordinator.getActiveFactions(threat)
---  local operations = FactionCoordinator.planOperations(threat)
---
---@see lore.lore_manager For faction data
---@see ai.strategic.threat_manager For threat level

local FactionCoordinator = {}

-- Faction state
FactionCoordinator.activeFactions = {}  -- Active factions: id -> {name, resources, missions}
FactionCoordinator.factionResources = {}  -- Resources allocated: id -> {ufos, bases, troops}
FactionCoordinator.operationSchedule = {}  -- Scheduled operations
FactionCoordinator.lastOperationUpdate = 0  -- Time of last operation planning

-- Faction resource multipliers by threat
FactionCoordinator.THREAT_THRESHOLDS = {
    {threat = 0.0, factions = 0, multiplier = 0},      -- Minimal activity
    {threat = 0.1, factions = 1, multiplier = 0.5},    -- Single faction
    {threat = 0.3, factions = 1, multiplier = 1.0},    -- Full activity
    {threat = 0.5, factions = 2, multiplier = 1.5},    -- Two factions active
    {threat = 0.7, factions = 2, multiplier = 2.0},    -- Coordinated attacks
    {threat = 0.85, factions = 3, multiplier = 2.5},   -- Multiple factions
    {threat = 1.0, factions = 4, multiplier = 3.0}     -- Maximum pressure
}

-- Operation types by threat level
FactionCoordinator.OPERATION_TYPES = {
    low = {"patrol", "infiltration", "survey"},
    medium = {"patrol", "terror", "supply_run", "base_assault"},
    high = {"terror", "base_assault", "coordinated_attack", "infiltration"},
    critical = {"terror", "base_assault", "coordinated_attack", "dimensional_rift"}
}

---Initialize faction coordinator
---Loads faction configurations and sets up coordination system
function FactionCoordinator.init()
    print("[FactionCoordinator] Initializing faction coordination system")
    
    local LoreManager = require("lore.lore_manager")
    local CampaignManager = require("geoscape.campaign_manager")
    
    -- Get factions for current phase
    local phase = CampaignManager.getCurrentPhase()
    local phaseFactions = LoreManager.getFactionsByPhase(phase)
    
    print(string.format("[FactionCoordinator] Phase %d factions: %d", phase, #phaseFactions))
    
    -- Initialize faction tracking
    for _, faction in ipairs(phaseFactions) do
        FactionCoordinator.activeFactions[faction.id] = {
            name = faction.name,
            phase = phase,
            resources = 0,
            missions_planned = 0,
            ufos_active = 0
        }
    end
end

---Get active factions at given threat level
---@param threat number Threat level (0.0-1.0)
---@return table Array of active faction IDs
function FactionCoordinator.getActiveFactions(threat)
    local factionCount = FactionCoordinator:_getActiveFactionCount(threat)
    local result = {}
    
    local factions = {}
    for id, faction in pairs(FactionCoordinator.activeFactions) do
        table.insert(factions, {id = id, data = faction})
    end
    
    -- Sort by threat priority (primary factions first)
    table.sort(factions, function(a, b)
        return (a.data.phase or 0) > (b.data.phase or 0)
    end)
    
    -- Return top N factions
    for i = 1, math.min(factionCount, #factions) do
        table.insert(result, factions[i].id)
    end
    
    return result
end

---Allocate resources to factions based on threat
---@param threat number Current threat level
---@return table Resource allocation by faction
function FactionCoordinator.allocateResources(threat)
    local resourceMultiplier = FactionCoordinator:_getResourceMultiplier(threat)
    local activeFactions = FactionCoordinator.getActiveFactions(threat)
    
    local allocation = {}
    
    for _, factionId in ipairs(activeFactions) do
        local baseResources = {
            ufos = math.floor(2 + (threat * 3)),
            bases = math.floor(1 + (threat * 2)),
            troops = math.floor(10 + (threat * 20))
        }
        
        allocation[factionId] = {
            ufos = math.floor(baseResources.ufos * resourceMultiplier),
            bases = math.floor(baseResources.bases * resourceMultiplier),
            troops = math.floor(baseResources.troops * resourceMultiplier)
        }
        
        FactionCoordinator.factionResources[factionId] = allocation[factionId]
    end
    
    return allocation
end

---Plan monthly operations for all active factions
---@param threat number Current threat level
---@return table Planned operations schedule
function FactionCoordinator.planOperations(threat)
    local activeFactions = FactionCoordinator.getActiveFactions(threat)
    local operations = {}
    
    -- Determine operation intensity
    local operationType = "low"
    if threat > 0.7 then operationType = "critical"
    elseif threat > 0.5 then operationType = "high"
    elseif threat > 0.3 then operationType = "medium"
    end
    
    -- Plan operations for each faction
    for _, factionId in ipairs(activeFactions) do
        local opCount = math.floor(2 + (threat * 4))  -- 2-6 operations
        
        operations[factionId] = {}
        
        for i = 1, opCount do
            local typeList = FactionCoordinator.OPERATION_TYPES[operationType]
            local opType = typeList[math.random(1, #typeList)]
            
            table.insert(operations[factionId], {
                type = opType,
                priority = math.random(1, 3),  -- 1=high, 3=low
                intensity = 0.5 + (threat * 0.5),
                daysUntilStart = math.random(1, 30)
            })
        end
    end
    
    FactionCoordinator.operationSchedule = operations
    FactionCoordinator.lastOperationUpdate = os.time()
    
    return operations
end

---Get next mission type for a faction
---@param factionId string Faction identifier
---@param threat number Current threat level
---@return string Mission type
function FactionCoordinator.getMissionType(factionId, threat)
    local operationType = "low"
    if threat > 0.7 then operationType = "critical"
    elseif threat > 0.5 then operationType = "high"
    elseif threat > 0.3 then operationType = "medium"
    end
    
    local typeList = FactionCoordinator.OPERATION_TYPES[operationType]
    return typeList[math.random(1, #typeList)]
end

---Get UFO composition for mission
---@param factionId string Faction identifier
---@param threat number Current threat level
---@return table Unit composition {type, count}
function FactionCoordinator.getUFOComposition(factionId, threat)
    local composition = {}
    
    -- Scout UFOs (always possible)
    table.insert(composition, {type = "scout_ufo", count = 1})
    
    -- Add escorts based on threat
    if threat > 0.3 then
        table.insert(composition, {type = "fighter_escort", count = 1 + math.floor(threat * 2)})
    end
    
    -- Add warships at high threat
    if threat > 0.6 then
        table.insert(composition, {type = "warship", count = 1 + math.floor((threat - 0.6) * 5)})
    end
    
    -- Occasionally add command ships
    if threat > 0.8 and math.random() < 0.3 then
        table.insert(composition, {type = "command_ship", count = 1})
    end
    
    return composition
end

---Internal: Get number of active factions at threat level
---@param threat number Threat level
---@return number Faction count
function FactionCoordinator:_getActiveFactionCount(threat)
    for i = #FactionCoordinator.THREAT_THRESHOLDS, 1, -1 do
        if threat >= FactionCoordinator.THREAT_THRESHOLDS[i].threat then
            return FactionCoordinator.THREAT_THRESHOLDS[i].factions
        end
    end
    return 0
end

---Internal: Get resource multiplier at threat level
---@param threat number Threat level
---@return number Multiplier (0.5-3.0)
function FactionCoordinator:_getResourceMultiplier(threat)
    for i = #FactionCoordinator.THREAT_THRESHOLDS, 1, -1 do
        if threat >= FactionCoordinator.THREAT_THRESHOLDS[i].threat then
            return FactionCoordinator.THREAT_THRESHOLDS[i].multiplier
        end
    end
    return 0
end

---Get debug info
---@return table Debug information
function FactionCoordinator.getDebugInfo()
    return {
        activeFactions = FactionCoordinator.activeFactions,
        resources = FactionCoordinator.factionResources,
        operationSchedule = FactionCoordinator.operationSchedule
    }
end

return FactionCoordinator
