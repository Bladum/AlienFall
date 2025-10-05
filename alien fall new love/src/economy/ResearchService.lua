--- Research Service
-- Manages research trees, prerequisite checking, and technological progression
--
-- @classmod economy.ResearchService

-- GROK: ResearchService manages technological progression through research trees and prerequisites
-- GROK: Handles research project lifecycle, completion tracking, and unlock effects
-- GROK: Key methods: startResearch(), completeResearch(), getAvailableResearch(), checkPrerequisites()
-- GROK: Integrates with manufacturing unlocks, unit upgrades, and campaign progression

local class = require 'lib.Middleclass'
local ResearchTree = require 'economy.ResearchTree'

--- ResearchService class
-- @type ResearchService
ResearchService = class('ResearchService')

--- Create a new ResearchService instance
-- @param registry Service registry for accessing other systems
-- @return ResearchService instance
function ResearchService:initialize(registry)
    self.registry = registry
    self.logger = registry and registry:logger() or nil
    self.eventBus = registry and registry:getService('eventBus') or nil

    -- Research state
    self.activeResearch = {} -- baseId -> {researchId, startTime, assignedScientists}
    self.completedResearch = {} -- Set of completed research IDs
    self.researchProgress = {} -- researchId -> progress (0-100)

    -- Load research data and build tree
    self:_loadResearchData()

    -- Register with service registry
    if registry then
        registry:registerService('researchService', self)
    end
end

--- Load research data from data registry
function ResearchService:_loadResearchData()
    local dataRegistry = self.registry and self.registry:resolve("data_registry")
    if not dataRegistry then
        if self.logger then
            self.logger:warn("Data registry not available for loading research data")
        end
        return
    end

    -- Load research entries from mod system
    local researchData = dataRegistry:get("research_entry")
    if researchData then
        self.researchTree = ResearchTree:new(researchData)
    else
        -- Fallback empty tree
        self.researchTree = ResearchTree:new({})
    end
end

--- Get all available research projects
-- @return table Array of available research IDs
function ResearchService:getAvailableResearch()
    return self.researchTree:get_available_research()
end

--- Get all completed research projects
-- @return table Array of completed research IDs
function ResearchService:getCompletedResearch()
    return self.researchTree:get_completed_research()
end

--- Check if research prerequisites are met
-- @param researchId The research ID to check
-- @return boolean Whether prerequisites are satisfied
function ResearchService:checkPrerequisites(researchId)
    return self.researchTree:is_research_available(researchId)
end

--- Start research on a project
-- @param researchId The research ID to start
-- @param baseId The base where research should happen
-- @param assignedScientists Number of scientists to assign
-- @return boolean Success status
-- @return string Error message if failed
function ResearchService:startResearch(researchId, baseId, assignedScientists)
    -- Check if research is available
    if not self:checkPrerequisites(researchId) then
        return false, "Prerequisites not met"
    end

    -- Check if already researching at this base
    if self.activeResearch[baseId] then
        return false, "Base already has active research"
    end

    -- Check if research is already completed
    if self.completedResearch[researchId] then
        return false, "Research already completed"
    end

    -- Start the research
    local success = self.researchTree:start_research(researchId)
    if not success then
        return false, "Failed to start research"
    end

    -- Record active research
    self.activeResearch[baseId] = {
        researchId = researchId,
        startTime = self:_getCurrentTime(),
        assignedScientists = assignedScientists,
        progress = 0
    }

    -- Initialize progress tracking
    self.researchProgress[researchId] = 0

    -- Emit research started event
    if self.eventBus then
        self.eventBus:emit('research:started', {
            researchId = researchId,
            baseId = baseId,
            assignedScientists = assignedScientists
        })
    end

    return true, "Research started successfully"
end

--- Cancel research on a project
-- @param baseId The base where research is happening
-- @return boolean Success status
-- @return string Error message if failed
function ResearchService:cancelResearch(baseId)
    local active = self.activeResearch[baseId]
    if not active then
        return false, "No active research at base"
    end

    -- Cancel in research tree
    self.researchTree:cancel_research(active.researchId)

    -- Clear active research
    self.activeResearch[baseId] = nil

    -- Emit research cancelled event
    if self.eventBus then
        self.eventBus:emit('research:cancelled', {
            researchId = active.researchId,
            baseId = baseId
        })
    end

    return true, "Research cancelled successfully"
end

--- Update research progress (called each game hour)
function ResearchService:updateResearch()
    for baseId, active in pairs(self.activeResearch) do
        local progressIncrease = self:_calculateProgressIncrease(active.assignedScientists)
        active.progress = active.progress + progressIncrease

        -- Update global progress tracking
        self.researchProgress[active.researchId] = active.progress

        -- Check for completion
        if active.progress >= 100 then
            self:_completeResearch(baseId)
        end
    end
end

--- Calculate progress increase based on assigned scientists
-- @param assignedScientists Number of scientists assigned
-- @return number Progress increase (0-100)
function ResearchService:_calculateProgressIncrease(assignedScientists)
    -- Base progress per hour per scientist
    local baseProgress = 0.5 -- 0.5% per scientist per hour

    -- Apply scientist efficiency
    local efficiency = 1.0 -- Could be modified by facilities, etc.

    return assignedScientists * baseProgress * efficiency
end

--- Complete research project
-- @param baseId The base where research was completed
-- @param researchId Optional explicit research ID (for updateProgress compatibility)
function ResearchService:completeResearch(baseId, researchId)
    local active = self.activeResearch[baseId]
    if not active and not researchId then return end

    -- Use explicit ID if provided, otherwise get from active research
    local targetResearchId = researchId or (active and active.researchId)
    if not targetResearchId then return end

    -- Mark as completed in tree
    self.researchTree:complete_research(targetResearchId)

    -- Add to completed set
    self.completedResearch[targetResearchId] = true

    -- Apply unlock effects
    self:_applyResearchUnlocks(targetResearchId)

    -- Clear active research if base provided
    if baseId then
        self.activeResearch[baseId] = nil
    end
    self.researchProgress[targetResearchId] = nil

    -- Emit research completed event
    if self.eventBus then
        self.eventBus:emit('research:completed', {
            researchId = targetResearchId,
            baseId = baseId
        })
    end
end

--- Apply unlock effects when research is completed
-- @param researchId The completed research ID
function ResearchService:_applyResearchUnlocks(researchId)
    local dataRegistry = self.registry and self.registry:resolve("data_registry")
    if not dataRegistry then return end

    local researchData = dataRegistry:get("research_entry", researchId)
    if not researchData or not researchData.unlocks then return end

    -- Process each unlock
    for _, unlock in ipairs(researchData.unlocks) do
        self:_processUnlock(unlock, researchId)
    end
end

--- Process a single research unlock
-- @param unlock The unlock definition
-- @param researchId The research that unlocked it
function ResearchService:_processUnlock(unlock, researchId)
    if not unlock or not unlock.type then return end

    -- Emit unlock event for other systems to handle
    if self.eventBus then
        self.eventBus:emit('research:unlocked', {
            unlockType = unlock.type,
            unlockId = unlock.id,
            researchId = researchId,
            unlockData = unlock
        })
    end

    -- Handle specific unlock types
    if unlock.type == "manufacturing" then
        self:_unlockManufacturing(unlock.id)
    elseif unlock.type == "unit" then
        self:_unlockUnit(unlock.id)
    elseif unlock.type == "facility" then
        self:_unlockFacility(unlock.id)
    elseif unlock.type == "item" then
        self:_unlockItem(unlock.id)
    end
end

--- Unlock manufacturing recipe
function ResearchService:_unlockManufacturing(recipeId)
    local manufactureService = self.registry and self.registry:getService('manufactureService')
    if manufactureService and manufactureService.unlockRecipe then
        manufactureService:unlockRecipe(recipeId)
    end
end

--- Unlock unit type
function ResearchService:_unlockUnit(unitId)
    -- Unit unlocks are typically handled by checking completed research
    if self.logger then
        self.logger:info("Unit unlocked: " .. unitId)
    end
end

--- Unlock facility type
function ResearchService:_unlockFacility(facilityId)
    -- Facility unlocks are typically handled by checking completed research
    if self.logger then
        self.logger:info("Facility unlocked: " .. facilityId)
    end
end

--- Unlock item type
function ResearchService:_unlockItem(itemId)
    -- Item unlocks are typically handled by checking completed research
    if self.logger then
        self.logger:info("Item unlocked: " .. itemId)
    end
end

--- Check if specific unlock is available
-- @param unlockType Type of unlock (manufacturing, unit, facility, item)
-- @param unlockId ID of the thing to unlock
-- @return boolean Whether unlocked
function ResearchService:isUnlocked(unlockType, unlockId)
    -- Check all completed research for this unlock
    for researchId, _ in pairs(self.completedResearch) do
        local dataRegistry = self.registry and self.registry:resolve("data_registry")
        if dataRegistry then
            local researchData = dataRegistry:get("research_entry", researchId)
            if researchData and researchData.unlocks then
                for _, unlock in ipairs(researchData.unlocks) do
                    if unlock.type == unlockType and unlock.id == unlockId then
                        return true
                    end
                end
            end
        end
    end
    return false
end

--- Get research progress for a project
-- @param researchId The research ID to check
-- @return number Progress percentage (0-100)
function ResearchService:getResearchProgress(researchId)
    return self.researchProgress[researchId] or 0
end

--- Get active research for a base
-- @param baseId The base ID to check
-- @return table|nil Active research data or nil if none
function ResearchService:getActiveResearch(baseId)
    return self.activeResearch[baseId]
end

--- Check if research is completed
-- @param researchId The research ID to check
-- @return boolean Whether the research is completed
function ResearchService:isResearchCompleted(researchId)
    return self.completedResearch[researchId] == true
end

--- Get research projects by category
-- @param category The category to filter by
-- @return table Array of research IDs in the category
function ResearchService:getResearchByCategory(category)
    return self.researchTree:get_research_by_category(category)
end

--- Get research projects by tier
-- @param tier The tier to filter by
-- @return table Array of research IDs in the tier
function ResearchService:getResearchByTier(tier)
    return self.researchTree:get_research_by_tier(tier)
end

--- Get prerequisites for a research project
-- @param researchId The research ID to check
-- @return table Array of prerequisite research IDs
function ResearchService:getPrerequisites(researchId)
    return self.researchTree:get_prerequisites(researchId)
end

--- Get current game time (integrated with time system)
function ResearchService:_getCurrentTime()
    -- Get time service from registry
    local timeService = self.registry and self.registry:getService('timeService')
    if timeService then
        local timeData = timeService:getCurrentTime()
        -- Convert to timestamp-like value for consistency
        return timeData.day * 24  -- Convert days to hours
    end
    -- Fallback to system time if time service not available
    return os.time()
end

--- Update research progress (called by time system)
-- @param deltaTime Time elapsed in game hours
-- @return number: Number of research projects completed
function ResearchService:updateProgress(deltaTime)
    local completedCount = 0
    
    -- Update all active research projects
    for baseId, researchData in pairs(self.activeResearch) do
        if researchData and researchData.researchId then
            local researchId = researchData.researchId
            local scientists = researchData.assignedScientists or 1
            
            -- Calculate progress (simplified: 1% per hour per scientist)
            local progressGain = (deltaTime * scientists) / 100
            
            -- Update progress
            local currentProgress = self.researchProgress[researchId] or 0
            currentProgress = currentProgress + progressGain
            self.researchProgress[researchId] = currentProgress
            
            -- Check if completed
            if currentProgress >= 100 then
                self:completeResearch(baseId, researchId)
                completedCount = completedCount + 1
                
                if self.logger then
                    self.logger:info("Research completed: " .. researchId)
                end
            end
        end
    end
    
    return completedCount
end

--- Get research state summary
-- @return table: Research state
function ResearchService:getState()
    local activeCount = 0
    for _ in pairs(self.activeResearch) do
        activeCount = activeCount + 1
    end
    
    local completedCount = 0
    for _ in pairs(self.completedResearch) do
        completedCount = completedCount + 1
    end
    
    local availableCount = #self:getAvailableResearch()
    
    return {
        active = activeCount,
        completed = completedCount,
        available = availableCount,
        progress = self.researchProgress
    }
end

return ResearchService
