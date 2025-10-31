---@class ConstructionInterfaceUI
---@field base table Reference to base data
---@field availableFacilities table List of facilities available for construction
---@field selectedFacilityType string Currently selected facility type for construction
---@field constructionQueue table Queue of facilities being constructed
---@field uiOffsetX number X offset for UI positioning (grid-aligned)
---@field uiOffsetY number Y offset for UI positioning (grid-aligned)
---@field uiWidth number Width of the construction interface
---@field uiHeight number Height of the construction interface
---@field scrollOffset number Current scroll position for facility list
---@field onFacilitySelected function Callback when facility is selected
---@field onConstructionQueued function Callback when construction is queued
local ConstructionInterfaceUI = {}
ConstructionInterfaceUI.__index = ConstructionInterfaceUI

-- ============================================================================
-- CONSTANTS
-- ============================================================================

local FACILITY_INFO = {
    quarters = {
        name = "Living Quarters",
        description = "Provides housing for personnel. Increases recruitment capacity.",
        cost = 50000,
        time = 7,
        requirements = "Basic construction",
        icon = "quarters"
    },
    laboratory = {
        name = "Laboratory",
        description = "Research facility that accelerates technological development.",
        cost = 75000,
        time = 14,
        requirements = "Scientists available",
        icon = "laboratory"
    },
    workshop = {
        name = "Workshop",
        description = "Manufacturing facility for producing equipment and weapons.",
        cost = 60000,
        time = 10,
        requirements = "Engineers available",
        icon = "workshop"
    },
    storage = {
        name = "Storage Facility",
        description = "Increases resource storage capacity.",
        cost = 30000,
        time = 5,
        requirements = "Basic construction",
        icon = "storage"
    },
    power = {
        name = "Power Plant",
        description = "Generates electricity for base facilities.",
        cost = 80000,
        time = 12,
        requirements = "Advanced construction",
        icon = "power"
    },
    radar = {
        name = "Radar Station",
        description = "Extends detection range for UFOs and alien activity.",
        cost = 90000,
        time = 15,
        requirements = "Electronics research",
        icon = "radar"
    },
    medical = {
        name = "Medical Bay",
        description = "Advanced medical facility for treating wounded soldiers.",
        cost = 70000,
        time = 10,
        requirements = "Medical research",
        icon = "medical"
    },
    prison = {
        name = "Alien Containment",
        description = "Secure facility for holding and interrogating alien prisoners.",
        cost = 40000,
        time = 8,
        requirements = "Security research",
        icon = "prison"
    }
}

local ITEM_HEIGHT = 80  -- Height of each facility item in the list
local VISIBLE_ITEMS = 4  -- Number of items visible at once
local SCROLLBAR_WIDTH = 16

-- ============================================================================
-- INITIALIZATION
-- ============================================================================

---@param base table Base data structure
---@return table New ConstructionInterfaceUI instance
function ConstructionInterfaceUI:new(base)
    local self = setmetatable({}, ConstructionInterfaceUI)

    self.base = base or {}
    self.availableFacilities = {}
    self.selectedFacilityType = nil
    self.constructionQueue = {}
    self.scrollOffset = 0

    -- Position UI to the right side of the screen (grid-aligned)
    local windowWidth = love.graphics.getWidth()
    self.uiOffsetX = math.floor((windowWidth - 400) / 24) * 24  -- 400px width, grid-aligned
    self.uiOffsetY = 72  -- Below the view buttons
    self.uiWidth = 400
    self.uiHeight = 480

    -- Initialize available facilities based on research and base capabilities
    self:updateAvailableFacilities()

    return self
end

---@param base table Update the base reference
function ConstructionInterfaceUI:setBase(base)
    self.base = base or {}
    self:updateAvailableFacilities()
end

-- ============================================================================
-- FACILITY MANAGEMENT
-- ============================================================================

--- Update the list of available facilities based on current research and base state
function ConstructionInterfaceUI:updateAvailableFacilities()
    self.availableFacilities = {}

    -- Basic facilities always available
    table.insert(self.availableFacilities, "quarters")
    table.insert(self.availableFacilities, "storage")

    -- Research-dependent facilities
    if self:hasResearch("basic_electronics") then
        table.insert(self.availableFacilities, "radar")
    end

    if self:hasResearch("advanced_construction") then
        table.insert(self.availableFacilities, "power")
        table.insert(self.availableFacilities, "workshop")
    end

    if self:hasResearch("alien_materials") then
        table.insert(self.availableFacilities, "laboratory")
    end

    if self:hasResearch("medical_tech") then
        table.insert(self.availableFacilities, "medical")
    end

    if self:hasResearch("containment_fields") then
        table.insert(self.availableFacilities, "prison")
    end
end

--- Check if the base has completed specific research
---@param researchId string Research identifier
---@return boolean Whether the research is completed
function ConstructionInterfaceUI:hasResearch(researchId)
    -- TODO: Integrate with actual research system
    -- For now, make some facilities available by default
    local alwaysAvailable = {
        "basic_electronics",
        "advanced_construction",
        "alien_materials"
    }

    for _, research in ipairs(alwaysAvailable) do
        if research == researchId then
            return true
        end
    end

    return false
end

--- Check if a facility can be built (cost, requirements, etc.)
---@param facilityType string Type of facility
---@return boolean, string Whether it can be built and reason if not
function ConstructionInterfaceUI:canBuildFacility(facilityType)
    local info = FACILITY_INFO[facilityType]
    if not info then
        return false, "Unknown facility type"
    end

    -- Check funds
    if self.base.funds and self.base.funds < info.cost then
        return false, "Insufficient funds"
    end

    -- Check research requirements
    if facilityType == "radar" and not self:hasResearch("basic_electronics") then
        return false, "Requires electronics research"
    elseif facilityType == "power" and not self:hasResearch("advanced_construction") then
        return false, "Requires advanced construction"
    elseif facilityType == "laboratory" and not self:hasResearch("alien_materials") then
        return false, "Requires alien materials research"
    elseif facilityType == "medical" and not self:hasResearch("medical_tech") then
        return false, "Requires medical technology"
    elseif facilityType == "prison" and not self:hasResearch("containment_fields") then
        return false, "Requires containment field research"
    end

    -- Check if facility is already in construction queue
    for _, queued in ipairs(self.constructionQueue) do
        if queued.type == facilityType then
            return false, "Already in construction queue"
        end
    end

    return true, ""
end

--- Get construction cost for a facility
---@param facilityType string Type of facility
---@return number Cost in credits
function ConstructionInterfaceUI:getConstructionCost(facilityType)
    local info = FACILITY_INFO[facilityType]
    return info and info.cost or 0
end

--- Get construction time for a facility
---@param facilityType string Type of facility
---@return number Time in days
function ConstructionInterfaceUI:getConstructionTime(facilityType)
    local info = FACILITY_INFO[facilityType]
    return info and info.time or 0
end

--- Add facility to construction queue
---@param facilityType string Type of facility to queue
---@return boolean Success
function ConstructionInterfaceUI:queueConstruction(facilityType)
    local canBuild, reason = self:canBuildFacility(facilityType)
    if not canBuild then
        print("[ConstructionInterfaceUI] Cannot build " .. facilityType .. ": " .. reason)
        return false
    end

    local construction = {
        type = facilityType,
        name = FACILITY_INFO[facilityType].name,
        cost = self:getConstructionCost(facilityType),
        timeRemaining = self:getConstructionTime(facilityType),
        totalTime = self:getConstructionTime(facilityType),
        progress = 0
    }

    table.insert(self.constructionQueue, construction)

    -- Deduct cost immediately
    if self.base.funds then
        self.base.funds = self.base.funds - construction.cost
    end

    print(string.format("[ConstructionInterfaceUI] Queued %s for construction", facilityType))
    return true
end

--- Update construction progress
---@param dt number Delta time in seconds
function ConstructionInterfaceUI:updateConstruction(dt)
    -- Process construction queue (simplified - in real game this would be time-based)
    -- For demo purposes, we'll advance construction slowly
    if #self.constructionQueue > 0 then
        local construction = self.constructionQueue[1]
        construction.timeRemaining = construction.timeRemaining - dt * 0.1  -- Slow progress for demo

        if construction.timeRemaining <= 0 then
            -- Construction complete
            table.remove(self.constructionQueue, 1)
            print(string.format("[ConstructionInterfaceUI] Construction complete: %s", construction.name))

            if self.onConstructionComplete then
                self.onConstructionComplete(construction.type)
            end
        else
            construction.progress = 1 - (construction.timeRemaining / construction.totalTime)
        end
    end
end

-- ============================================================================
-- RENDERING
-- ============================================================================

--- Render the construction interface
function ConstructionInterfaceUI:draw()
    -- Draw background panel
    self:drawBackground()

    -- Draw header
    self:drawHeader()

    -- Draw facility list
    self:drawFacilityList()

    -- Draw construction queue
    self:drawConstructionQueue()

    -- Draw scrollbar if needed
    if #self.availableFacilities > VISIBLE_ITEMS then
        self:drawScrollbar()
    end
end

--- Draw the background panel
function ConstructionInterfaceUI:drawBackground()
    -- Main panel background
    love.graphics.setColor(0.1, 0.1, 0.15, 0.95)
    love.graphics.rectangle("fill", self.uiOffsetX, self.uiOffsetY, self.uiWidth, self.uiHeight)

    -- Border
    love.graphics.setColor(0.3, 0.3, 0.4, 0.8)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", self.uiOffsetX, self.uiOffsetY, self.uiWidth, self.uiHeight)
end

--- Draw the header
function ConstructionInterfaceUI:drawHeader()
    local headerY = self.uiOffsetY + 10

    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(16))
    love.graphics.print("Construction", self.uiOffsetX + 10, headerY)

    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.setColor(0.7, 0.7, 0.8)
    love.graphics.print("Available Facilities", self.uiOffsetX + 10, headerY + 25)
end

--- Draw the scrollable facility list
function ConstructionInterfaceUI:drawFacilityList()
    local listStartY = self.uiOffsetY + 50
    local listHeight = ITEM_HEIGHT * VISIBLE_ITEMS

    -- Draw list background
    love.graphics.setColor(0.05, 0.05, 0.1, 0.8)
    love.graphics.rectangle("fill", self.uiOffsetX + 5, listStartY, self.uiWidth - 10 - SCROLLBAR_WIDTH, listHeight)

    -- Draw visible facilities
    local startIndex = math.floor(self.scrollOffset / ITEM_HEIGHT) + 1
    local endIndex = math.min(startIndex + VISIBLE_ITEMS - 1, #self.availableFacilities)

    for i = startIndex, endIndex do
        local facilityType = self.availableFacilities[i]
        local itemY = listStartY + (i - startIndex) * ITEM_HEIGHT
        self:drawFacilityItem(facilityType, self.uiOffsetX + 5, itemY, self.uiWidth - 10 - SCROLLBAR_WIDTH, ITEM_HEIGHT)
    end
end

--- Draw a single facility item
---@param facilityType string Type of facility
---@param x number X position
---@param y number Y position
---@param width number Item width
---@param height number Item height
function ConstructionInterfaceUI:drawFacilityItem(facilityType, x, y, width, height)
    local info = FACILITY_INFO[facilityType]
    if not info then return end

    local canBuild, reason = self:canBuildFacility(facilityType)
    local isSelected = self.selectedFacilityType == facilityType
    local isHovered = self:isItemHovered(x, y, width, height)

    -- Background color based on state
    if isSelected then
        love.graphics.setColor(0.3, 0.5, 0.7, 0.8)  -- Selected
    elseif not canBuild then
        love.graphics.setColor(0.2, 0.1, 0.1, 0.6)  -- Cannot build
    elseif isHovered then
        love.graphics.setColor(0.2, 0.2, 0.3, 0.7)  -- Hovered
    else
        love.graphics.setColor(0.15, 0.15, 0.2, 0.6)  -- Normal
    end

    love.graphics.rectangle("fill", x, y, width, height)

    -- Border
    love.graphics.setColor(0.4, 0.4, 0.5, 0.8)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", x, y, width, height)

    -- Facility name
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.print(info.name, x + 10, y + 5)

    -- Cost and time
    love.graphics.setFont(love.graphics.newFont(10))
    love.graphics.setColor(0.9, 0.9, 0.2)
    love.graphics.print("$" .. self:formatNumber(info.cost), x + 10, y + 25)

    love.graphics.setColor(0.7, 0.8, 0.9)
    love.graphics.print(info.time .. " days", x + 100, y + 25)

    -- Description (truncated)
    love.graphics.setColor(0.8, 0.8, 0.8)
    local desc = info.description
    if #desc > 35 then
        desc = desc:sub(1, 32) .. "..."
    end
    love.graphics.print(desc, x + 10, y + 45)

    -- Cannot build indicator
    if not canBuild then
        love.graphics.setColor(0.8, 0.2, 0.2)
        love.graphics.print(reason, x + 10, y + 60)
    end
end

--- Draw the construction queue
function ConstructionInterfaceUI:drawConstructionQueue()
    local queueStartY = self.uiOffsetY + 50 + ITEM_HEIGHT * VISIBLE_ITEMS + 20

    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.print("Construction Queue", self.uiOffsetX + 10, queueStartY)

    if #self.constructionQueue == 0 then
        love.graphics.setColor(0.6, 0.6, 0.6)
        love.graphics.setFont(love.graphics.newFont(10))
        love.graphics.print("No facilities in queue", self.uiOffsetX + 10, queueStartY + 20)
    else
        for i, construction in ipairs(self.constructionQueue) do
            local itemY = queueStartY + 15 + (i - 1) * 25
            self:drawConstructionItem(construction, self.uiOffsetX + 10, itemY, self.uiWidth - 20)
        end
    end
end

--- Draw a construction queue item
---@param construction table Construction data
---@param x number X position
---@param y number Y position
---@param width number Item width
function ConstructionInterfaceUI:drawConstructionItem(construction, x, y, width)
    -- Background
    love.graphics.setColor(0.2, 0.3, 0.4, 0.6)
    love.graphics.rectangle("fill", x, y, width, 20)

    -- Progress bar background
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.rectangle("fill", x, y + 18, width, 4)

    -- Progress bar fill
    love.graphics.setColor(0.2, 0.8, 0.2)
    love.graphics.rectangle("fill", x, y + 18, width * construction.progress, 4)

    -- Text
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(10))
    love.graphics.print(construction.name, x + 5, y + 2)

    local timeText = string.format("%.1f/%d days", construction.totalTime - construction.timeRemaining, construction.totalTime)
    love.graphics.print(timeText, x + width - 80, y + 2)
end

--- Draw scrollbar for facility list
function ConstructionInterfaceUI:drawScrollbar()
    local scrollbarX = self.uiOffsetX + self.uiWidth - SCROLLBAR_WIDTH - 5
    local scrollbarY = self.uiOffsetY + 50
    local scrollbarHeight = ITEM_HEIGHT * VISIBLE_ITEMS

    -- Scrollbar background
    love.graphics.setColor(0.2, 0.2, 0.2, 0.8)
    love.graphics.rectangle("fill", scrollbarX, scrollbarY, SCROLLBAR_WIDTH, scrollbarHeight)

    -- Scrollbar handle
    local handleHeight = math.max(20, scrollbarHeight * (VISIBLE_ITEMS / #self.availableFacilities))
    local handleY = scrollbarY + (self.scrollOffset / ((#self.availableFacilities - VISIBLE_ITEMS) * ITEM_HEIGHT)) * (scrollbarHeight - handleHeight)

    love.graphics.setColor(0.5, 0.5, 0.6, 0.8)
    love.graphics.rectangle("fill", scrollbarX, handleY, SCROLLBAR_WIDTH, handleHeight)
end

-- ============================================================================
-- INPUT HANDLING
-- ============================================================================

--- Update the UI state
---@param dt number Delta time
function ConstructionInterfaceUI:update(dt)
    self:updateConstruction(dt)
end

--- Handle mouse press
---@param x number Mouse X coordinate
---@param y number Mouse Y coordinate
---@param button number Mouse button
function ConstructionInterfaceUI:mousepressed(x, y, button)
    if button == 1 then  -- Left click
        -- Check facility list clicks
        local listStartY = self.uiOffsetY + 50
        local listEndY = listStartY + ITEM_HEIGHT * VISIBLE_ITEMS

        if x >= self.uiOffsetX + 5 and x <= self.uiOffsetX + self.uiWidth - 5 - SCROLLBAR_WIDTH
           and y >= listStartY and y <= listEndY then

            local itemIndex = math.floor((y - listStartY) / ITEM_HEIGHT) + 1
            local actualIndex = math.floor(self.scrollOffset / ITEM_HEIGHT) + itemIndex

            if actualIndex >= 1 and actualIndex <= #self.availableFacilities then
                local facilityType = self.availableFacilities[actualIndex]
                self.selectedFacilityType = facilityType

                if self.onFacilitySelected then
                    self.onFacilitySelected(facilityType)
                end

                -- If double-click or shift-click, queue construction
                if love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") then
                    self:queueConstruction(facilityType)
                end
            end
        end
    end
end

--- Handle mouse wheel for scrolling
---@param x number Mouse X coordinate
---@param y number Mouse Y coordinate
function ConstructionInterfaceUI:mousewheel(x, y)
    if self:isMouseOverList() then
        local maxScroll = math.max(0, (#self.availableFacilities - VISIBLE_ITEMS) * ITEM_HEIGHT)
        self.scrollOffset = math.max(0, math.min(maxScroll, self.scrollOffset - y * ITEM_HEIGHT))
    end
end

--- Check if mouse is over the facility list
---@return boolean Whether mouse is over the list
function ConstructionInterfaceUI:isMouseOverList()
    local mx, my = love.mouse.getPosition()
    local listStartY = self.uiOffsetY + 50
    local listEndY = listStartY + ITEM_HEIGHT * VISIBLE_ITEMS

    return mx >= self.uiOffsetX + 5 and mx <= self.uiOffsetX + self.uiWidth - 5 - SCROLLBAR_WIDTH
           and my >= listStartY and my <= listEndY
end

--- Check if a specific item is hovered
---@param x number Item X position
---@param y number Item Y position
---@param width number Item width
---@param height number Item height
---@return boolean Whether the item is hovered
function ConstructionInterfaceUI:isItemHovered(x, y, width, height)
    local mx, my = love.mouse.getPosition()
    return mx >= x and mx <= x + width and my >= y and my <= y + height
end

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================

--- Format large numbers with commas
---@param num number Number to format
---@return string Formatted number
function ConstructionInterfaceUI:formatNumber(num)
    local formatted = tostring(num)
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then
            break
        end
    end
    return formatted
end

--- Get detailed information about a facility
---@param facilityType string Type of facility
---@return table Facility information
function ConstructionInterfaceUI:getFacilityInfo(facilityType)
    local info = FACILITY_INFO[facilityType]
    if not info then return {} end

    local canBuild, reason = self:canBuildFacility(facilityType)

    return {
        name = info.name,
        description = info.description,
        cost = info.cost,
        time = info.time,
        requirements = info.requirements,
        canBuild = canBuild,
        cannotBuildReason = reason,
        icon = info.icon
    }
end

return ConstructionInterfaceUI
