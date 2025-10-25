---ResearchEntry - Research type definitions
---
---Defines researchable technologies with:
---  - Cost in man-days with random variance (75%-125%)
---  - Prerequisites and tech tree dependencies
---  - Unlocks (research, facilities, manufacturing)
---  - Item analysis and prisoner interrogation
---
---@module basescape.research.research_entry
---@author AlienFall Development Team

local ResearchEntry = {}

---Create a new research entry
---@param data table Research data
---@return table ResearchEntry instance
function ResearchEntry.new(data)
    return {
        id = data.id or "unknown_research",
        name = data.name or "Unknown Research",
        description = data.description or "",
        
        -- Cost
        baselineManDays = data.baselineManDays or 100,
        
        -- Type
        type = data.type or "technology",  -- technology, item_analysis, prisoner_interrogation
        repeatable = data.repeatable or false,
        
        -- Prerequisites
        requiredTech = data.requiredTech or {},
        requiredItems = data.requiredItems or {},
        requiredPrisoners = data.requiredPrisoners or {},
        requiredServices = data.requiredServices or {},
        
        -- Dependencies
        dependsOn = data.dependsOn or {},
        givesFree = data.givesFree or {},
        blocks = data.blocks or {},
        
        -- Unlocks
        unlocksResearch = data.unlocksResearch or {},
        unlocksManufacturing = data.unlocksManufacturing or {},
        unlocksFacilities = data.unlocksFacilities or {},
        unlocksItems = data.unlocksItems or {},
        
        -- Special (interrogations)
        interrogationChance = data.interrogationChance or 0.3,
        maxInterrogations = data.maxInterrogations or 5,
        
        -- Metadata
        category = data.category or "general",
        icon = data.icon or nil,
        loreText = data.loreText or "",
    }
end

---Calculate actual man-days for this run (random 75%-125%)
---@param entry table The research entry
---@return number manDays Randomized man-days for this research project
function ResearchEntry.getRandomizedManDays(entry)
    local variance = math.random(75, 125) / 100.0
    return math.floor(entry.baselineManDays * variance)
end

---Check if prerequisites are met
---@param entry table The research entry
---@param completedResearch table Map of research_id -> true for completed research
---@param hasItems table Map of item_id -> count for available items
---@param prisoners table List of imprisoned alien types
---@return boolean canResearch True if can start research
---@return string? reason Reason if cannot research
function ResearchEntry.canResearch(entry, completedResearch, hasItems, prisoners)
    -- Check tech prerequisites
    for _, techId in ipairs(entry.requiredTech) do
        if not completedResearch[techId] then
            return false, "Missing prerequisite: " .. techId
        end
    end
    
    -- Check item requirements
    for _, itemReq in ipairs(entry.requiredItems) do
        if not hasItems[itemReq.id] or hasItems[itemReq.id] < itemReq.quantity then
            return false, "Missing item: " .. itemReq.id
        end
    end
    
    -- Check prisoner requirements
    for _, prisonerType in ipairs(entry.requiredPrisoners) do
        local hasPrisoner = false
        for _, prisoner in ipairs(prisoners) do
            if prisoner.type == prisonerType then
                hasPrisoner = true
                break
            end
        end
        if not hasPrisoner then
            return false, "No prisoner of type: " .. prisonerType
        end
    end
    
    return true, nil
end

---Check if research blocks another
---@param entry table The research entry
---@param researchId string Research ID to check
---@return boolean blocks True if this research blocks the other
function ResearchEntry.blocksResearch(entry, researchId)
    for _, blockedId in ipairs(entry.blocks) do
        if blockedId == researchId then
            return true
        end
    end
    return false
end

---Get all unlocked research from this entry
---@param entry table The research entry
---@return table unlockedIds Array of unlocked research IDs
function ResearchEntry.getUnlockedResearch(entry)
    local unlocked = {}
    
    -- Add direct unlocks
    for _, resId in ipairs(entry.unlocksResearch) do
        table.insert(unlocked, resId)
    end
    
    -- Add free research
    for _, resId in ipairs(entry.givesFree) do
        table.insert(unlocked, resId)
    end
    
    return unlocked
end

return ResearchEntry




