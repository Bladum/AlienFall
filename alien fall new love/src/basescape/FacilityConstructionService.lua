--- Facility Construction Service
-- Manages base facility construction, build queues, and placement validation
--
-- @classmod basescape.FacilityConstructionService

-- GROK: FacilityConstructionService manages base facility construction lifecycle
-- GROK: Handles build queue, placement validation, prerequisite checking, construction progress
-- GROK: Key methods: queueConstruction(), validatePlacement(), updateConstruction(), completeConstruction()
-- GROK: Integrates with research unlocks, resource consumption, and time progression

local class = require 'lib.Middleclass'

--- FacilityConstructionService class
-- @type FacilityConstructionService
local FacilityConstructionService = class('FacilityConstructionService')

--- Create a new FacilityConstructionService instance
-- @param registry Service registry for accessing other systems
-- @return FacilityConstructionService instance
function FacilityConstructionService:initialize(registry)
    self.registry = registry
    self.logger = registry and registry:logger() or nil
    self.eventBus = registry and registry:getService('eventBus') or nil
    
    -- Construction state per base
    self.buildQueues = {} -- baseId -> array of {facilityId, x, y, startDay, progress, cost}
    self.completedFacilities = {} -- baseId -> array of {facilityId, x, y, completionDay}
    
    -- Register with service registry
    if registry then
        registry:registerService('facilityConstructionService', self)
    end
end

--- Queue a facility for construction
-- @param baseId The base where construction will occur
-- @param facilityId The facility type to construct
-- @param x Grid X coordinate (0-based)
-- @param y Grid Y coordinate (0-based)
-- @return boolean Success status
-- @return string Error message if failed
function FacilityConstructionService:queueConstruction(baseId, facilityId, x, y)
    -- Validate placement
    local valid, error = self:validatePlacement(baseId, facilityId, x, y)
    if not valid then
        return false, error
    end
    
    -- Check prerequisites
    if not self:checkPrerequisites(facilityId) then
        return false, "Prerequisites not met (research required)"
    end
    
    -- Get facility data
    local facilityData = self:_getFacilityData(facilityId)
    if not facilityData then
        return false, "Facility type not found: " .. facilityId
    end
    
    -- Check resources
    local hasResources, resourceError = self:checkResources(facilityData.cost)
    if not hasResources then
        return false, resourceError
    end
    
    -- Consume resources
    self:_consumeResources(facilityData.cost)
    
    -- Add to build queue
    if not self.buildQueues[baseId] then
        self.buildQueues[baseId] = {}
    end
    
    local timeService = self.registry and self.registry:getService('timeService')
    local currentDay = timeService and timeService:getCurrentTime().day or 0
    
    table.insert(self.buildQueues[baseId], {
        facilityId = facilityId,
        x = x,
        y = y,
        startDay = currentDay,
        progress = 0,
        buildTime = facilityData.buildTime or 30, -- days
        cost = facilityData.cost
    })
    
    -- Emit construction queued event
    if self.eventBus then
        self.eventBus:emit('facility:queued', {
            baseId = baseId,
            facilityId = facilityId,
            position = {x = x, y = y}
        })
    end
    
    return true, "Construction queued successfully"
end

--- Validate facility placement
-- @param baseId The base where placement is attempted
-- @param facilityId The facility type to place
-- @param x Grid X coordinate
-- @param y Grid Y coordinate
-- @return boolean Valid placement
-- @return string Error message if invalid
function FacilityConstructionService:validatePlacement(baseId, facilityId, x, y)
    -- Get facility data
    local facilityData = self:_getFacilityData(facilityId)
    if not facilityData then
        return false, "Facility type not found"
    end
    
    local width = facilityData.width or 1
    local height = facilityData.height or 1
    
    -- Check base grid bounds (assuming 6x6 base grid)
    local gridSize = 6
    if x < 0 or y < 0 or x + width > gridSize or y + height > gridSize then
        return false, "Placement out of base grid bounds"
    end
    
    -- Check for overlapping facilities
    if self:_checkOverlap(baseId, x, y, width, height) then
        return false, "Placement overlaps existing facility"
    end
    
    -- Check adjacency requirements
    if facilityData.requiresAdjacent then
        if not self:_checkAdjacency(baseId, x, y, width, height, facilityData.requiresAdjacent) then
            return false, "Facility requires adjacent: " .. facilityData.requiresAdjacent
        end
    end
    
    return true, "Valid placement"
end

--- Check if placement overlaps existing facilities
-- @param baseId Base ID
-- @param x Placement X
-- @param y Placement Y
-- @param width Facility width
-- @param height Facility height
-- @return boolean True if overlaps
function FacilityConstructionService:_checkOverlap(baseId, x, y, width, height)
    -- Check completed facilities
    local completed = self.completedFacilities[baseId] or {}
    for _, facility in ipairs(completed) do
        local data = self:_getFacilityData(facility.facilityId)
        if data then
            local fWidth = data.width or 1
            local fHeight = data.height or 1
            
            -- Check rectangle overlap
            if not (x + width <= facility.x or x >= facility.x + fWidth or
                    y + height <= facility.y or y >= facility.y + fHeight) then
                return true -- Overlaps
            end
        end
    end
    
    -- Check build queue
    local queue = self.buildQueues[baseId] or {}
    for _, construction in ipairs(queue) do
        local data = self:_getFacilityData(construction.facilityId)
        if data then
            local fWidth = data.width or 1
            local fHeight = data.height or 1
            
            if not (x + width <= construction.x or x >= construction.x + fWidth or
                    y + height <= construction.y or y >= construction.y + fHeight) then
                return true -- Overlaps
            end
        end
    end
    
    return false
end

--- Check adjacency requirements
-- @param baseId Base ID
-- @param x Placement X
-- @param y Placement Y
-- @param width Facility width
-- @param height Facility height
-- @param requiredType Required adjacent facility type
-- @return boolean True if adjacency satisfied
function FacilityConstructionService:_checkAdjacency(baseId, x, y, width, height, requiredType)
    local completed = self.completedFacilities[baseId] or {}
    
    for _, facility in ipairs(completed) do
        if facility.facilityId == requiredType then
            local data = self:_getFacilityData(facility.facilityId)
            if data then
                local fWidth = data.width or 1
                local fHeight = data.height or 1
                
                -- Check if adjacent (touching edges)
                local adjacent = false
                
                -- Right edge touches left edge
                if x + width == facility.x and not (y + height <= facility.y or y >= facility.y + fHeight) then
                    adjacent = true
                end
                
                -- Left edge touches right edge
                if x == facility.x + fWidth and not (y + height <= facility.y or y >= facility.y + fHeight) then
                    adjacent = true
                end
                
                -- Bottom edge touches top edge
                if y + height == facility.y and not (x + width <= facility.x or x >= facility.x + fWidth) then
                    adjacent = true
                end
                
                -- Top edge touches bottom edge
                if y == facility.y + fHeight and not (x + width <= facility.x or x >= facility.x + fWidth) then
                    adjacent = true
                end
                
                if adjacent then
                    return true
                end
            end
        end
    end
    
    return false
end

--- Check if facility prerequisites are met
-- @param facilityId The facility type
-- @return boolean Prerequisites met
function FacilityConstructionService:checkPrerequisites(facilityId)
    local facilityData = self:_getFacilityData(facilityId)
    if not facilityData or not facilityData.prerequisiteResearch then
        return true -- No prerequisites
    end
    
    local researchService = self.registry and self.registry:getService('researchService')
    if not researchService then
        return true -- Can't check, allow
    end
    
    -- Check all prerequisite research
    for _, researchId in ipairs(facilityData.prerequisiteResearch) do
        if not researchService:isResearchCompleted(researchId) then
            return false
        end
    end
    
    return true
end

--- Check if resources are available for construction
-- @param cost Cost table {credits, alloys, etc}
-- @return boolean Resources available
-- @return string Error message if unavailable
function FacilityConstructionService:checkResources(cost)
    if not cost then return true end
    
    local financeService = self.registry and self.registry:getService('financeService')
    if not financeService then
        return true, "Finance service unavailable"
    end
    
    -- Check credits
    if cost.credits then
        local balance = financeService:getBalance()
        if balance < cost.credits then
            return false, "Insufficient credits"
        end
    end
    
    -- Check other resources (alloys, elerium, etc)
    -- TODO: Integrate with inventory system when available
    
    return true
end

--- Consume resources for construction
-- @param cost Cost table
function FacilityConstructionService:_consumeResources(cost)
    if not cost then return end
    
    local financeService = self.registry and self.registry:getService('financeService')
    if financeService and cost.credits then
        financeService:deductFunds(cost.credits, "facility_construction")
    end
    
    -- TODO: Consume materials from inventory when available
end

--- Update construction progress (called by time system)
-- @param deltaTime Time elapsed in game days
function FacilityConstructionService:updateConstruction(deltaTime)
    for baseId, queue in pairs(self.buildQueues) do
        local completedIndices = {}
        
        for i, construction in ipairs(queue) do
            -- Update progress
            construction.progress = construction.progress + deltaTime
            
            -- Check completion
            if construction.progress >= construction.buildTime then
                self:_completeConstruction(baseId, construction)
                table.insert(completedIndices, i)
            end
        end
        
        -- Remove completed constructions (reverse order to maintain indices)
        for i = #completedIndices, 1, -1 do
            table.remove(queue, completedIndices[i])
        end
    end
end

--- Complete a facility construction
-- @param baseId Base where construction completed
-- @param construction Construction data
function FacilityConstructionService:_completeConstruction(baseId, construction)
    -- Add to completed facilities
    if not self.completedFacilities[baseId] then
        self.completedFacilities[baseId] = {}
    end
    
    local timeService = self.registry and self.registry:getService('timeService')
    local currentDay = timeService and timeService:getCurrentTime().day or 0
    
    table.insert(self.completedFacilities[baseId], {
        facilityId = construction.facilityId,
        x = construction.x,
        y = construction.y,
        completionDay = currentDay
    })
    
    -- Emit completion event
    if self.eventBus then
        self.eventBus:emit('facility:completed', {
            baseId = baseId,
            facilityId = construction.facilityId,
            position = {x = construction.x, y = construction.y}
        })
    end
    
    if self.logger then
        self.logger:info("Facility construction completed: " .. construction.facilityId .. " at base " .. baseId)
    end
end

--- Cancel a queued construction
-- @param baseId Base ID
-- @param index Queue index (1-based)
-- @return boolean Success
function FacilityConstructionService:cancelConstruction(baseId, index)
    local queue = self.buildQueues[baseId]
    if not queue or not queue[index] then
        return false
    end
    
    local construction = queue[index]
    
    -- Refund partial resources (50% of cost)
    if construction.cost and construction.cost.credits then
        local financeService = self.registry and self.registry:getService('financeService')
        if financeService then
            local refund = math.floor(construction.cost.credits * 0.5)
            financeService:addFunds(refund, "construction_cancelled")
        end
    end
    
    table.remove(queue, index)
    
    -- Emit cancellation event
    if self.eventBus then
        self.eventBus:emit('facility:cancelled', {
            baseId = baseId,
            facilityId = construction.facilityId
        })
    end
    
    return true
end

--- Get build queue for a base
-- @param baseId Base ID
-- @return table Array of queued constructions
function FacilityConstructionService:getBuildQueue(baseId)
    return self.buildQueues[baseId] or {}
end

--- Get completed facilities for a base
-- @param baseId Base ID
-- @return table Array of completed facilities
function FacilityConstructionService:getCompletedFacilities(baseId)
    return self.completedFacilities[baseId] or {}
end

--- Get facility data from data registry
-- @param facilityId Facility type ID
-- @return table|nil Facility data or nil
function FacilityConstructionService:_getFacilityData(facilityId)
    local dataRegistry = self.registry and self.registry:resolve("data_registry")
    if not dataRegistry then return nil end
    
    return dataRegistry:get("facility", facilityId)
end

--- Get construction progress summary
-- @param baseId Base ID
-- @return table Summary data
function FacilityConstructionService:getConstructionSummary(baseId)
    local queue = self.buildQueues[baseId] or {}
    local completed = self.completedFacilities[baseId] or {}
    
    return {
        inProgress = #queue,
        completed = #completed,
        queue = queue
    }
end

return FacilityConstructionService
