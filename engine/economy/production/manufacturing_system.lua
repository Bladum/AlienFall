---Manufacturing System
---
---Manages production queue, resource costs, workshop capacity, and item manufacturing.
---Handles engineer allocation, production time calculation, material requirements,
---and item delivery. Core economic system for equipment production.
---
---Manufacturing Features:
---  - Production queue with priorities
---  - Engineer allocation to projects
---  - Workshop capacity limits
---  - Resource and material costs
---  - Production time calculation
---  - Batch production support
---  - Pause/resume production
---
---Production Status:
---  - QUEUED: Waiting in production queue
---  - IN_PROGRESS: Currently being manufactured
---  - COMPLETE: Production finished, ready for delivery
---  - PAUSED: Temporarily halted
---
---Key Exports:
---  - ManufacturingSystem.new(): Creates manufacturing system
---  - startProduction(itemId, quantity, engineers): Begins manufacturing
---  - updateProgress(hours): Advances production by time
---  - completeProduction(itemId): Finishes and delivers items
---  - pauseProduction(itemId): Temporarily stops production
---  - getProductionQueue(): Returns queued items
---
---Dependencies:
---  - basescape.facilities: Workshop buildings
---  - shared.units.units: Engineer management
---  - shared.items: Item definitions
---  - economy.research: Technology unlocks
---
---@module economy.production.manufacturing_system
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local ManufacturingSystem = require("economy.production.manufacturing_system")
---  local production = ManufacturingSystem.new()
---  production:startProduction("laser_rifle", 10, 8)  -- 10 rifles, 8 engineers
---  production:updateProgress(24)  -- Advance 24 hours
---
---@see economy.research For research system
---@see scenes.basescape_screen For base management

local ManufacturingSystem = {}
ManufacturingSystem.__index = ManufacturingSystem

--- Production status
ManufacturingSystem.STATUS = {
    QUEUED = "queued",           -- In production queue
    IN_PROGRESS = "in_progress", -- Currently being manufactured
    COMPLETE = "complete",       -- Finished production
    PAUSED = "paused"            -- Temporarily stopped
}

--- Create new manufacturing system
-- @return table New ManufacturingSystem instance
function ManufacturingSystem.new()
    local self = setmetatable({}, ManufacturingSystem)
    
    self.productionQueue = {}    -- Items in production
    self.projects = {}           -- Manufacturing project definitions
    self.completedItems = {}     -- Finished items waiting for storage
    self.engineers = 0           -- Available engineers
    self.workshopCapacity = 0    -- Total workshop space
    
    print("[ManufacturingSystem] Initialized manufacturing system")
    
    return self
end

--- Define manufacturing project
-- @param projectId string Unique project identifier
-- @param definition table Project definition
function ManufacturingSystem:defineProject(projectId, definition)
    self.projects[projectId] = {
        id = projectId,
        name = definition.name or projectId,
        description = definition.description or "",
        manufactureCost = definition.manufactureCost or 100, -- Engineer-hours needed
        materialCost = definition.materialCost or {},         -- {material = amount}
        produceAmount = definition.produceAmount or 1,        -- Items produced per project
        requiredResearch = definition.requiredResearch or nil -- Research prerequisite
    }
    
    print(string.format("[ManufacturingSystem] Defined project '%s' (cost: %d hrs)",
          definition.name, definition.manufactureCost))
end

--- Start manufacturing item
-- @param projectId string Project to manufacture
-- @param quantity number Number of items to produce
-- @param engineers number Engineers assigned
-- @return boolean True if started successfully
function ManufacturingSystem:startManufacturing(projectId, quantity, engineers)
    local project = self.projects[projectId]
    
    if not project then
        print("[ManufacturingSystem] ERROR: Project not found: " .. projectId)
        return false
    end
    
    -- Check if research prerequisite met
    if project.requiredResearch and not self:isResearchComplete(project.requiredResearch) then
        print("[ManufacturingSystem] ERROR: Research required: " .. project.requiredResearch)
        return false
    end
    
    -- Check if materials available
    if not self:checkMaterialsAvailable(projectId, quantity) then
        print("[ManufacturingSystem] ERROR: Insufficient materials")
        return false
    end
    
    -- Consume materials
    self:consumeMaterials(projectId, quantity)
    
    -- Create production order
    local order = {
        id = self:generateOrderId(),
        projectId = projectId,
        projectName = project.name,
        quantity = quantity,
        produced = 0,
        progress = 0,
        totalCost = project.manufactureCost * quantity,
        engineers = engineers,
        status = ManufacturingSystem.STATUS.IN_PROGRESS
    }
    
    table.insert(self.productionQueue, order)
    
    print(string.format("[ManufacturingSystem] Started manufacturing '%s' x%d with %d engineers",
          project.name, quantity, engineers))
    
    return true
end

--- Generate unique order ID
-- @return string Unique order identifier
function ManufacturingSystem:generateOrderId()
    return "ORDER_" .. os.time() .. "_" .. math.random(1000, 9999)
end

--- Check if materials are available
-- @param projectId string Project identifier
-- @param quantity number Number to produce
-- @return boolean True if materials available
function ManufacturingSystem:checkMaterialsAvailable(projectId, quantity)
    local project = self.projects[projectId]
    
    if not project or not project.materialCost then
        return true
    end
    
    -- Check each material requirement
    for material, cost in pairs(project.materialCost) do
        local required = cost * quantity
        local available = self:getMaterialStock(material)
        
        if available < required then
            print(string.format("[ManufacturingSystem] Insufficient %s: need %d, have %d",
                  material, required, available))
            return false
        end
    end
    
    return true
end

--- Consume materials for manufacturing
-- @param projectId string Project identifier
-- @param quantity number Number being produced
function ManufacturingSystem:consumeMaterials(projectId, quantity)
    local project = self.projects[projectId]
    
    if not project or not project.materialCost then
        return
    end
    
    for material, cost in pairs(project.materialCost) do
        local amount = cost * quantity
        self:removeMaterial(material, amount)
        print(string.format("[ManufacturingSystem] Consumed %d %s", amount, material))
    end
end

--- Get material stock (placeholder - integrate with inventory)
-- @param material string Material name
-- @return number Available amount
function ManufacturingSystem:getMaterialStock(material)
    -- TODO: Integrate with actual inventory system
    return 1000 -- Placeholder
end

--- Remove material from stock (placeholder)
-- @param material string Material name
-- @param amount number Amount to remove
function ManufacturingSystem:removeMaterial(material, amount)
    -- TODO: Integrate with actual inventory system
end

--- Check if research is complete (placeholder)
-- @param researchId string Research project ID
-- @return boolean True if research complete
function ManufacturingSystem:isResearchComplete(researchId)
    -- TODO: Integrate with research system
    return true -- Placeholder
end

--- Process daily manufacturing progress
-- @param engineers number Available engineers
function ManufacturingSystem:processDailyProgress(engineers)
    if #self.productionQueue == 0 then
        return
    end
    
    print(string.format("[ManufacturingSystem] Processing manufacturing with %d engineers", engineers))
    
    for i = #self.productionQueue, 1, -1 do
        local order = self.productionQueue[i]
        
        if order.status == ManufacturingSystem.STATUS.IN_PROGRESS then
            -- Calculate progress (engineer-hours per day)
            local dailyProgress = order.engineers * 24 -- 24 hours per day
            order.progress = order.progress + dailyProgress
            
            print(string.format("[ManufacturingSystem] '%s' progress: %d/%d (+%d)",
                  order.projectName, order.progress, order.totalCost, dailyProgress))
            
            -- Check for item completion
            local project = self.projects[order.projectId]
            local itemCost = project.manufactureCost
            
            while order.progress >= itemCost and order.produced < order.quantity do
                order.progress = order.progress - itemCost
                order.produced = order.produced + 1
                
                -- Add to completed items
                self:completeItem(order.projectId, project.produceAmount)
                
                print(string.format("[ManufacturingSystem] Completed '%s' (%d/%d)",
                      order.projectName, order.produced, order.quantity))
            end
            
            -- Remove order if fully complete
            if order.produced >= order.quantity then
                order.status = ManufacturingSystem.STATUS.COMPLETE
                table.remove(self.productionQueue, i)
                print(string.format("[ManufacturingSystem] ORDER COMPLETE: %s x%d",
                      order.projectName, order.quantity))
            end
        end
    end
end

--- Complete manufactured item
-- @param projectId string Project identifier
-- @param amount number Items produced
function ManufacturingSystem:completeItem(projectId, amount)
    if not self.completedItems[projectId] then
        self.completedItems[projectId] = 0
    end
    
    self.completedItems[projectId] = self.completedItems[projectId] + amount
end

--- Get completed items ready for collection
-- @return table Table of {projectId = amount}
function ManufacturingSystem:getCompletedItems()
    return self.completedItems
end

--- Collect completed items (move to storage)
-- @param projectId string Project identifier
-- @return number Amount collected
function ManufacturingSystem:collectItems(projectId)
    local amount = self.completedItems[projectId] or 0
    self.completedItems[projectId] = 0
    
    print(string.format("[ManufacturingSystem] Collected %d x %s", amount, projectId))
    
    return amount
end

--- Cancel manufacturing order
-- @param orderId string Order identifier
-- @return boolean True if cancelled
function ManufacturingSystem:cancelOrder(orderId)
    for i, order in ipairs(self.productionQueue) do
        if order.id == orderId then
            -- Refund partial materials if desired
            -- TODO: Implement material refund logic
            
            table.remove(self.productionQueue, i)
            print(string.format("[ManufacturingSystem] Cancelled order: %s", order.projectName))
            return true
        end
    end
    
    return false
end

--- Pause/resume manufacturing order
-- @param orderId string Order identifier
-- @param paused boolean True to pause, false to resume
-- @return boolean True if changed
function ManufacturingSystem:setPaused(orderId, paused)
    for _, order in ipairs(self.productionQueue) do
        if order.id == orderId then
            order.status = paused and ManufacturingSystem.STATUS.PAUSED 
                                  or ManufacturingSystem.STATUS.IN_PROGRESS
            
            print(string.format("[ManufacturingSystem] %s order: %s",
                  paused and "Paused" or "Resumed", order.projectName))
            return true
        end
    end
    
    return false
end

--- Get current production queue
-- @return table Array of active orders
function ManufacturingSystem:getProductionQueue()
    return self.productionQueue
end

--- Get manufacturing progress percentage
-- @param orderId string Order identifier
-- @return number Progress percentage (0-100)
function ManufacturingSystem:getProgress(orderId)
    for _, order in ipairs(self.productionQueue) do
        if order.id == orderId then
            return math.floor((order.progress / order.totalCost) * 100)
        end
    end
    
    return 0
end

--- Initialize default manufacturing projects
function ManufacturingSystem:initializeDefaultProjects()
    -- Basic weapons
    self:defineProject("laser_pistol", {
        name = "Laser Pistol",
        description = "Manufacture laser pistol",
        manufactureCost = 100,
        materialCost = {["alloys"] = 5, ["electronics"] = 3},
        produceAmount = 1,
        requiredResearch = "laser_weapons"
    })
    
    self:defineProject("laser_rifle", {
        name = "Laser Rifle",
        description = "Manufacture laser rifle",
        manufactureCost = 200,
        materialCost = {["alloys"] = 10, ["electronics"] = 5},
        produceAmount = 1,
        requiredResearch = "laser_weapons"
    })
    
    -- Armor
    self:defineProject("medium_armour", {
        name = "Medium Armor",
        description = "Manufacture medium armor",
        manufactureCost = 150,
        materialCost = {["alloys"] = 8, ["fiber"] = 6},
        produceAmount = 1,
        requiredResearch = "advanced_armor"
    })
    
    -- Ammunition
    self:defineProject("rifle_ammo", {
        name = "Rifle Ammunition",
        description = "Manufacture rifle ammo clips",
        manufactureCost = 20,
        materialCost = {["materials"] = 2},
        produceAmount = 5 -- Produce 5 clips per project
    })
    
    self:defineProject("grenade", {
        name = "Grenade",
        description = "Manufacture grenades",
        manufactureCost = 30,
        materialCost = {["explosives"] = 3, ["materials"] = 1},
        produceAmount = 3 -- Produce 3 grenades per project
    })
    
    print("[ManufacturingSystem] Initialized 5 default manufacturing projects")
end

return ManufacturingSystem

























