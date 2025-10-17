---ManufacturingEntry - Manufacturing type definitions (blueprints)
---
---Defines producible items/units/crafts with:
---  - Cost in man-days with random variance (75%-125%)
---  - Input resources (consumed at start)
---  - Output items/units
---  - Research prerequisites
---  - Regional dependencies
---
---@module basescape.logic.manufacturing_entry
---@author AlienFall Development Team

local ManufacturingEntry = {}

---Create a new manufacturing entry
---@param data table Manufacturing data
---@return table ManufacturingEntry instance
function ManufacturingEntry.new(data)
    return {
        id = data.id or "unknown_mfg",
        name = data.name or "Unknown Item",
        description = data.description or "",
        
        -- Cost
        baselineManDays = data.baselineManDays or 50,
        credits = data.credits or 0,
        
        -- Inputs (consumed at start)
        inputItems = data.inputItems or {},
        
        -- Outputs (produced at completion)
        outputs = data.outputs or {},
        outputQuantity = data.outputQuantity or 1,
        
        -- Production type
        productionType = data.productionType or "item",  -- item, unit, craft
        
        -- Prerequisites
        requiredResearch = data.requiredResearch or {},
        requiredFacilities = data.requiredFacilities or {},
        requiredServices = data.requiredServices or {},
        requiredRegions = data.requiredRegions or {},
        
        -- Metadata
        category = data.category or "general",
        icon = data.icon or nil,
        autoSellPrice = data.autoSellPrice or nil,
    }
end

---Calculate actual man-days for this run (random 75%-125%)
---@param entry table The manufacturing entry
---@return number manDays Randomized man-days for this project
function ManufacturingEntry.getRandomizedManDays(entry)
    local variance = math.random(75, 125) / 100.0
    return math.floor(entry.baselineManDays * variance)
end

---Check if manufacturing is possible
---@param entry table The manufacturing entry
---@param completedResearch table Map of research_id -> true
---@param hasItems table Map of item_id -> count
---@param hasServices table Map of service_name -> count
---@param baseRegion string Current base region
---@return boolean canManufacture True if can manufacture
---@return string? reason Reason if cannot manufacture
function ManufacturingEntry.canManufacture(entry, completedResearch, hasItems, hasServices, baseRegion)
    -- Check research requirements
    for _, resId in ipairs(entry.requiredResearch) do
        if not completedResearch[resId] then
            return false, "Missing required research: " .. resId
        end
    end
    
    -- Check input items
    for _, itemReq in ipairs(entry.inputItems) do
        if not hasItems[itemReq.id] or hasItems[itemReq.id] < itemReq.quantity then
            return false, "Missing input item: " .. itemReq.id
        end
    end
    
    -- Check services
    for _, service in ipairs(entry.requiredServices) do
        if not hasServices[service] or hasServices[service] < 1 then
            return false, "Missing required service: " .. service
        end
    end
    
    -- Check regional requirements
    if #entry.requiredRegions > 0 then
        local regionOk = false
        for _, region in ipairs(entry.requiredRegions) do
            if region == baseRegion then
                regionOk = true
                break
            end
        end
        if not regionOk then
            return false, "Cannot manufacture in this region"
        end
    end
    
    return true, nil
end

---Calculate sell price from input costs
---@param entry table The manufacturing entry
---@param itemPrices table Map of item_id -> sell_price
---@return number price Calculated sell price
function ManufacturingEntry.calculateSellPrice(entry, itemPrices)
    if entry.autoSellPrice then
        return entry.autoSellPrice
    end
    
    -- Calculate from inputs + labor
    local inputCost = 0
    for _, itemReq in ipairs(entry.inputItems) do
        inputCost = inputCost + ((itemPrices[itemReq.id] or 0) * itemReq.quantity)
    end
    
    -- Add labor cost (base 100 credits per man-day)
    local laborCost = entry.baselineManDays * 100
    
    -- Add 50% markup for profit
    return math.floor((inputCost + laborCost) * 1.5)
end

return ManufacturingEntry
