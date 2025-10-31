---@class FacilityGridUI
---@field base table Reference to base data
---@field gridSize number Size of the facility grid (typically 6x6)
---@field cellSize number Size of each grid cell in pixels (should be multiple of 24)
---@field gridOffsetX number X offset for grid positioning (grid-aligned)
---@field gridOffsetY number Y offset for grid positioning (grid-aligned)
---@field selectedCell table Currently selected cell {x, y}
---@field hoveredCell table Currently hovered cell {x, y}
---@field facilities table 2D array of facility data
---@field adjacencyBonuses table Calculated adjacency bonuses
---@field powerGrid table Power distribution data
---@field constructionMode boolean Whether construction mode is active
---@field availableFacilities table List of facilities that can be built
---@field onFacilitySelected function Callback when facility is selected
---@field onCellClicked function Callback when cell is clicked
local FacilityGridUI = {}
FacilityGridUI.__index = FacilityGridUI

-- ============================================================================
-- CONSTANTS
-- ============================================================================

local GRID_CELL_SIZE = 72  -- 3 grid cells (24*3) for better visibility
local FACILITY_COLORS = {
    empty = {0.15, 0.15, 0.2, 1.0},
    command = {0.3, 0.5, 0.7, 1.0},
    quarters = {0.4, 0.6, 0.3, 1.0},
    hangar = {0.6, 0.5, 0.3, 1.0},
    laboratory = {0.5, 0.3, 0.7, 1.0},
    workshop = {0.7, 0.4, 0.3, 1.0},
    storage = {0.4, 0.4, 0.6, 1.0},
    power = {0.8, 0.6, 0.2, 1.0},
    radar = {0.3, 0.7, 0.5, 1.0},
    medical = {0.7, 0.3, 0.4, 1.0},
    prison = {0.5, 0.5, 0.3, 1.0}
}

local ADJACENCY_BONUSES = {
    -- Laboratory bonuses
    laboratory_laboratory = {type = "research", value = 25, description = "+25% research speed"},
    laboratory_quarters = {type = "recruitment", value = 15, description = "+15% scientist recruitment"},

    -- Workshop bonuses
    workshop_workshop = {type = "manufacturing", value = 20, description = "+20% manufacturing speed"},
    workshop_storage = {type = "capacity", value = 30, description = "+30% storage capacity"},

    -- Hangar bonuses
    hangar_hangar = {type = "maintenance", value = 15, description = "-15% craft maintenance"},
    hangar_radar = {type = "detection", value = 20, description = "+20% radar range"},

    -- Power bonuses
    power_any = {type = "power", value = 10, description = "+10% power efficiency"}
}

-- ============================================================================
-- INITIALIZATION
-- ============================================================================

---@param base table Base data structure
---@param gridSize number Size of the grid (default 6)
---@return table New FacilityGridUI instance
function FacilityGridUI:new(base, gridSize)
    local self = setmetatable({}, FacilityGridUI)

    self.base = base or {}
    self.gridSize = gridSize or 6
    self.cellSize = GRID_CELL_SIZE

    -- Position grid to be grid-aligned (24px grid system)
    self.gridOffsetX = 8 * 24  -- 192px (8 grid cells from left)
    self.gridOffsetY = 4 * 24  -- 96px (4 grid cells from top)

    self.selectedCell = nil
    self.hoveredCell = nil
    self.facilities = self.base.facilities or {}
    self.constructionMode = false
    self.availableFacilities = {}

    -- Initialize empty grid if needed
    self:initializeGrid()

    -- Calculate adjacency bonuses
    self:calculateAdjacencyBonuses()

    -- Calculate power distribution
    self:calculatePowerGrid()

    return self
end

---@param base table Update the base reference
function FacilityGridUI:setBase(base)
    self.base = base or {}
    self.facilities = self.base.facilities or {}
    self:initializeGrid()
    self:calculateAdjacencyBonuses()
    self:calculatePowerGrid()
end

-- ============================================================================
-- GRID MANAGEMENT
-- ============================================================================

--- Initialize the facility grid with empty cells
function FacilityGridUI:initializeGrid()
    if not self.facilities or #self.facilities == 0 then
        self.facilities = {}
        for y = 1, self.gridSize do
            self.facilities[y] = {}
            for x = 1, self.gridSize do
                self.facilities[y][x] = {
                    type = "empty",
                    built = true,
                    level = 0,
                    condition = 100
                }
            end
        end
    end
end

--- Get facility at grid position
---@param x number Grid X coordinate (1-based)
---@param y number Grid Y coordinate (1-based)
---@return table|nil Facility data or nil if out of bounds
function FacilityGridUI:getFacility(x, y)
    if x < 1 or x > self.gridSize or y < 1 or y > self.gridSize then
        return nil
    end
    return self.facilities[y] and self.facilities[y][x]
end

--- Set facility at grid position
---@param x number Grid X coordinate
---@param y number Grid Y coordinate
---@param facility table Facility data
function FacilityGridUI:setFacility(x, y, facility)
    if x >= 1 and x <= self.gridSize and y >= 1 and y <= self.gridSize then
        self.facilities[y][x] = facility or {type = "empty", built = true}
        self:calculateAdjacencyBonuses()
        self:calculatePowerGrid()
    end
end

--- Check if a position is valid for construction
---@param x number Grid X coordinate
---@param y number Grid Y coordinate
---@return boolean Whether construction is allowed
function FacilityGridUI:canBuildAt(x, y)
    local facility = self:getFacility(x, y)
    return facility and facility.type == "empty" or false
end

--- Get screen coordinates for grid position
---@param x number Grid X coordinate
---@param y number Grid Y coordinate
---@return number, number Screen X, Y coordinates
function FacilityGridUI:gridToScreen(x, y)
    local screenX = self.gridOffsetX + (x - 1) * self.cellSize
    local screenY = self.gridOffsetY + (y - 1) * self.cellSize
    return screenX, screenY
end

--- Convert screen coordinates to grid position
---@param screenX number Screen X coordinate
---@param screenY number Screen Y coordinate
---@return number|nil, number|nil Grid X, Y coordinates (1-based), or nil if outside grid
function FacilityGridUI:screenToGrid(screenX, screenY)
    local gridX = math.floor((screenX - self.gridOffsetX) / self.cellSize) + 1
    local gridY = math.floor((screenY - self.gridOffsetY) / self.cellSize) + 1

    if gridX >= 1 and gridX <= self.gridSize and gridY >= 1 and gridY <= self.gridSize then
        return gridX, gridY
    end

    return nil, nil
end

-- ============================================================================
-- ADJACENCY BONUSES
-- ============================================================================

--- Calculate adjacency bonuses for all facilities
function FacilityGridUI:calculateAdjacencyBonuses()
    self.adjacencyBonuses = {}

    for y = 1, self.gridSize do
        for x = 1, self.gridSize do
            local facility = self:getFacility(x, y)
            if facility and facility.type ~= "empty" then
                self.adjacencyBonuses[y] = self.adjacencyBonuses[y] or {}
                self.adjacencyBonuses[y][x] = self:calculateCellAdjacencyBonus(x, y, facility.type)
            end
        end
    end
end

--- Calculate adjacency bonus for a specific cell
---@param x number Grid X coordinate
---@param y number Grid Y coordinate
---@param facilityType string Type of facility
---@return table List of adjacency bonuses
function FacilityGridUI:calculateCellAdjacencyBonus(x, y, facilityType)
    local bonuses = {}

    -- Check adjacent cells (4-directional)
    local directions = {
        {dx = 0, dy = -1}, -- North
        {dx = 1, dy = 0},  -- East
        {dx = 0, dy = 1},  -- South
        {dx = -1, dy = 0}  -- West
    }

    for _, dir in ipairs(directions) do
        local adjX, adjY = x + dir.dx, y + dir.dy
        local adjacent = self:getFacility(adjX, adjY)

        if adjacent and adjacent.type ~= "empty" then
            -- Check for specific adjacency bonuses
            local bonusKey = facilityType .. "_" .. adjacent.type
            local bonus = ADJACENCY_BONUSES[bonusKey]

            if bonus then
                table.insert(bonuses, {
                    type = bonus.type,
                    value = bonus.value,
                    description = bonus.description,
                    adjacentType = adjacent.type,
                    direction = dir
                })
            end

            -- Check for reverse bonus
            bonusKey = adjacent.type .. "_" .. facilityType
            bonus = ADJACENCY_BONUSES[bonusKey]

            if bonus then
                table.insert(bonuses, {
                    type = bonus.type,
                    value = bonus.value,
                    description = bonus.description,
                    adjacentType = adjacent.type,
                    direction = dir
                })
            end

            -- Check for "any" bonuses (like power)
            bonusKey = facilityType .. "_any"
            bonus = ADJACENCY_BONUSES[bonusKey]

            if bonus then
                table.insert(bonuses, {
                    type = bonus.type,
                    value = bonus.value,
                    description = bonus.description,
                    adjacentType = adjacent.type,
                    direction = dir
                })
            end
        end
    end

    return bonuses
end

--- Get adjacency bonuses for a cell
---@param x number Grid X coordinate
---@param y number Grid Y coordinate
---@return table List of bonuses
function FacilityGridUI:getAdjacencyBonuses(x, y)
    return (self.adjacencyBonuses[y] and self.adjacencyBonuses[y][x]) or {}
end

-- ============================================================================
-- POWER MANAGEMENT
-- ============================================================================

--- Calculate power distribution across the base
function FacilityGridUI:calculatePowerGrid()
    self.powerGrid = {}

    -- Find all power facilities
    local powerSources = {}
    for y = 1, self.gridSize do
        for x = 1, self.gridSize do
            local facility = self:getFacility(x, y)
            if facility and facility.type == "power" then
                table.insert(powerSources, {x = x, y = y, facility = facility})
            end
        end
    end

    -- Calculate power coverage for each cell
    for y = 1, self.gridSize do
        self.powerGrid[y] = {}
        for x = 1, self.gridSize do
            self.powerGrid[y][x] = self:calculateCellPower(x, y, powerSources)
        end
    end
end

--- Calculate power level for a specific cell
---@param x number Grid X coordinate
---@param y number Grid Y coordinate
---@param powerSources table List of power source positions
---@return table Power data {level, sources, status}
function FacilityGridUI:calculateCellPower(x, y, powerSources)
    local totalPower = 0
    local sources = {}

    for _, source in ipairs(powerSources) do
        local distance = math.abs(x - source.x) + math.abs(y - source.y)
        local powerLevel = math.max(0, 5 - distance)  -- Power decreases with distance

        if powerLevel > 0 then
            totalPower = totalPower + powerLevel
            table.insert(sources, {
                x = source.x,
                y = source.y,
                distance = distance,
                contribution = powerLevel
            })
        end
    end

    local status = "no_power"
    if totalPower >= 3 then
        status = "full_power"
    elseif totalPower >= 1 then
        status = "low_power"
    end

    return {
        level = totalPower,
        sources = sources,
        status = status
    }
end

--- Get power data for a cell
---@param x number Grid X coordinate
---@param y number Grid Y coordinate
---@return table Power data
function FacilityGridUI:getPowerData(x, y)
    return (self.powerGrid[y] and self.powerGrid[y][x]) or {level = 0, sources = {}, status = "no_power"}
end

-- ============================================================================
-- CONSTRUCTION MANAGEMENT
-- ============================================================================

--- Enable/disable construction mode
---@param enabled boolean Whether to enable construction mode
function FacilityGridUI:setConstructionMode(enabled)
    self.constructionMode = enabled
    if not enabled then
        self.selectedFacilityType = nil
    end
end

--- Set available facilities for construction
---@param facilities table List of available facility types
function FacilityGridUI:setAvailableFacilities(facilities)
    self.availableFacilities = facilities or {}
end

--- Check if a facility type can be built
---@param facilityType string Type of facility
---@return boolean Whether it can be built
function FacilityGridUI:canBuildFacility(facilityType)
    for _, available in ipairs(self.availableFacilities) do
        if available.type == facilityType then
            return true
        end
    end
    return false
end

--- Get construction cost for a facility type
---@param facilityType string Type of facility
---@return number Cost in credits
function FacilityGridUI:getConstructionCost(facilityType)
    local costs = {
        quarters = 50000,
        laboratory = 75000,
        workshop = 60000,
        storage = 30000,
        power = 80000,
        radar = 90000,
        medical = 70000,
        prison = 40000
    }
    return costs[facilityType] or 0
end

--- Get construction time for a facility type
---@param facilityType string Type of facility
---@return number Time in days
function FacilityGridUI:getConstructionTime(facilityType)
    local times = {
        quarters = 7,
        laboratory = 14,
        workshop = 10,
        storage = 5,
        power = 12,
        radar = 15,
        medical = 10,
        prison = 8
    }
    return times[facilityType] or 0
end

-- ============================================================================
-- RENDERING
-- ============================================================================

--- Update the UI state
---@param dt number Delta time
function FacilityGridUI:update(dt)
    -- Update hover state
    local mx, my = love.mouse.getPosition()
    self.hoveredCell = {self:screenToGrid(mx, my)}
end

--- Render the facility grid
function FacilityGridUI:draw()
    self:drawGridBackground()
    self:drawFacilities()
    self:drawAdjacencyIndicators()
    self:drawPowerOverlay()
    self:drawSelectionHighlight()
    self:drawHoverHighlight()
    self:drawConstructionPreview()
    self:drawGridLabels()
end

--- Draw the grid background
function FacilityGridUI:drawGridBackground()
    love.graphics.setColor(0.1, 0.1, 0.15, 0.5)
    love.graphics.rectangle("fill",
        self.gridOffsetX - 4,
        self.gridOffsetY - 4,
        self.gridSize * self.cellSize + 8,
        self.gridSize * self.cellSize + 8
    )

    -- Draw grid lines
    love.graphics.setColor(0.3, 0.3, 0.4, 0.8)
    love.graphics.setLineWidth(1)

    -- Vertical lines
    for x = 0, self.gridSize do
        local screenX = self.gridOffsetX + x * self.cellSize
        love.graphics.line(screenX, self.gridOffsetY, screenX, self.gridOffsetY + self.gridSize * self.cellSize)
    end

    -- Horizontal lines
    for y = 0, self.gridSize do
        local screenY = self.gridOffsetY + y * self.cellSize
        love.graphics.line(self.gridOffsetX, screenY, self.gridOffsetX + self.gridSize * self.cellSize, screenY)
    end
end

--- Draw all facilities
function FacilityGridUI:drawFacilities()
    for y = 1, self.gridSize do
        for x = 1, self.gridSize do
            self:drawFacilityCell(x, y)
        end
    end
end

--- Draw a single facility cell
---@param x number Grid X coordinate
---@param y number Grid Y coordinate
function FacilityGridUI:drawFacilityCell(x, y)
    local facility = self:getFacility(x, y)
    if not facility then return end

    local screenX, screenY = self:gridToScreen(x, y)
    local color = FACILITY_COLORS[facility.type] or FACILITY_COLORS.empty

    -- Draw facility background
    love.graphics.setColor(color)
    love.graphics.rectangle("fill", screenX + 2, screenY + 2, self.cellSize - 4, self.cellSize - 4)

    -- Draw facility border
    love.graphics.setColor(0.6, 0.6, 0.7, 0.8)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", screenX + 2, screenY + 2, self.cellSize - 4, self.cellSize - 4)

    -- Draw facility icon/text
    if facility.type ~= "empty" then
        love.graphics.setColor(1, 1, 1, 0.9)
        love.graphics.setFont(love.graphics.newFont(10))

        local name = self:getFacilityDisplayName(facility.type)
        local textWidth = love.graphics.getFont():getWidth(name)
        local textX = screenX + (self.cellSize - textWidth) / 2
        local textY = screenY + self.cellSize / 2 - 5

        love.graphics.print(name, textX, textY)

        -- Draw condition indicator if damaged
        if facility.condition and facility.condition < 100 then
            love.graphics.setColor(0.8, 0.2, 0.2, 0.8)
            love.graphics.setFont(love.graphics.newFont(8))
            love.graphics.print(facility.condition .. "%", screenX + 4, screenY + 4)
        end
    end
end

--- Draw adjacency bonus indicators
function FacilityGridUI:drawAdjacencyIndicators()
    if not self.constructionMode then return end

    for y = 1, self.gridSize do
        for x = 1, self.gridSize do
            local bonuses = self:getAdjacencyBonuses(x, y)
            if #bonuses > 0 then
                local screenX, screenY = self:gridToScreen(x, y)

                -- Draw bonus indicator
                love.graphics.setColor(0.2, 0.8, 0.2, 0.7)
                love.graphics.circle("fill", screenX + self.cellSize - 8, screenY + 8, 4)

                -- Draw bonus count
                love.graphics.setColor(1, 1, 1, 0.9)
                love.graphics.setFont(love.graphics.newFont(8))
                love.graphics.print(#bonuses, screenX + self.cellSize - 12, screenY + 4)
            end
        end
    end
end

--- Draw power overlay
function FacilityGridUI:drawPowerOverlay()
    if not self.constructionMode then return end

    for y = 1, self.gridSize do
        for x = 1, self.gridSize do
            local powerData = self:getPowerData(x, y)
            if powerData.status ~= "no_power" then
                local screenX, screenY = self:gridToScreen(x, y)

                -- Power status color
                local powerColor
                if powerData.status == "full_power" then
                    powerColor = {0.2, 0.8, 0.2, 0.3}  -- Green
                elseif powerData.status == "low_power" then
                    powerColor = {0.8, 0.6, 0.2, 0.3}  -- Yellow
                end

                if powerColor then
                    love.graphics.setColor(powerColor)
                    love.graphics.rectangle("fill", screenX + 2, screenY + 2, self.cellSize - 4, self.cellSize - 4)
                end
            end
        end
    end
end

--- Draw selection highlight
function FacilityGridUI:drawSelectionHighlight()
    if not self.selectedCell then return end

    local screenX, screenY = self:gridToScreen(self.selectedCell.x, self.selectedCell.y)

    love.graphics.setColor(1, 0.8, 0, 0.8)
    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", screenX + 1, screenY + 1, self.cellSize - 2, self.cellSize - 2)
end

--- Draw hover highlight
function FacilityGridUI:drawHoverHighlight()
    if not self.hoveredCell then return end

    local screenX, screenY = self:gridToScreen(self.hoveredCell.x, self.hoveredCell.y)

    love.graphics.setColor(0.8, 0.8, 1, 0.5)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", screenX + 1, screenY + 1, self.cellSize - 2, self.cellSize - 2)
end

--- Draw construction preview
function FacilityGridUI:drawConstructionPreview()
    if not self.constructionMode or not self.selectedFacilityType or not self.hoveredCell then return end

    local screenX, screenY = self:gridToScreen(self.hoveredCell.x, self.hoveredCell.y)
    local canBuild = self:canBuildAt(self.hoveredCell.x, self.hoveredCell.y)

    -- Preview color based on validity
    local previewColor = canBuild and {0.2, 0.8, 0.2, 0.5} or {0.8, 0.2, 0.2, 0.5}
    love.graphics.setColor(previewColor)
    love.graphics.rectangle("fill", screenX + 2, screenY + 2, self.cellSize - 4, self.cellSize - 4)

    -- Draw facility name
    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.setFont(love.graphics.newFont(10))
    local name = self:getFacilityDisplayName(self.selectedFacilityType)
    local textWidth = love.graphics.getFont():getWidth(name)
    local textX = screenX + (self.cellSize - textWidth) / 2
    local textY = screenY + self.cellSize / 2 - 5
    love.graphics.print(name, textX, textY)
end

--- Draw grid coordinate labels
function FacilityGridUI:drawGridLabels()
    love.graphics.setColor(0.7, 0.7, 0.8, 0.6)
    love.graphics.setFont(love.graphics.newFont(10))

    -- Column labels (A, B, C, etc.)
    for x = 1, self.gridSize do
        local screenX = self.gridOffsetX + (x - 1) * self.cellSize + self.cellSize / 2
        local label = string.char(64 + x)  -- A, B, C...
        local textWidth = love.graphics.getFont():getWidth(label)
        love.graphics.print(label, screenX - textWidth / 2, self.gridOffsetY - 20)
    end

    -- Row labels (1, 2, 3, etc.)
    for y = 1, self.gridSize do
        local screenY = self.gridOffsetY + (y - 1) * self.cellSize + self.cellSize / 2
        love.graphics.print(tostring(y), self.gridOffsetX - 20, screenY - 5)
    end
end

-- ============================================================================
-- INPUT HANDLING
-- ============================================================================

--- Handle mouse press
---@param x number Mouse X coordinate
---@param y number Mouse Y coordinate
---@param button number Mouse button
function FacilityGridUI:mousepressed(x, y, button)
    if button == 1 then  -- Left click
        local gridX, gridY = self:screenToGrid(x, y)

        if gridX and gridY then
            if self.constructionMode and self.selectedFacilityType then
                -- Construction placement
                if self:canBuildAt(gridX, gridY) then
                    self:placeFacility(gridX, gridY, self.selectedFacilityType)
                end
            else
                -- Normal selection
                self.selectedCell = {x = gridX, y = gridY}
                if self.onCellClicked then
                    self.onCellClicked(gridX, gridY)
                end
                if self.onFacilitySelected then
                    local facility = self:getFacility(gridX, gridY)
                    self.onFacilitySelected(facility, gridX, gridY)
                end
            end
        end
    end
end

--- Handle mouse release
---@param x number Mouse X coordinate
---@param y number Mouse Y coordinate
---@param button number Mouse button
function FacilityGridUI:mousereleased(x, y, button)
    -- Handle any release logic if needed
end

--- Place a facility at the specified location
---@param x number Grid X coordinate
---@param y number Grid Y coordinate
---@param facilityType string Type of facility to place
function FacilityGridUI:placeFacility(x, y, facilityType)
    local facility = {
        type = facilityType,
        built = false,  -- Construction in progress
        level = 1,
        condition = 100,
        constructionDays = self:getConstructionTime(facilityType),
        constructionCost = self:getConstructionCost(facilityType)
    }

    self:setFacility(x, y, facility)
    print(string.format("[FacilityGridUI] Placed %s at %d,%d", facilityType, x, y))
end

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================

--- Get display name for facility type
---@param facilityType string Facility type
---@return string Display name
function FacilityGridUI:getFacilityDisplayName(facilityType)
    local names = {
        command = "CMD",
        quarters = "QUARTERS",
        hangar = "HANGAR",
        laboratory = "LAB",
        workshop = "WORKSHOP",
        storage = "STORAGE",
        power = "POWER",
        radar = "RADAR",
        medical = "MEDICAL",
        prison = "PRISON"
    }
    return names[facilityType] or facilityType:upper()
end

--- Get detailed facility information
---@param x number Grid X coordinate
---@param y number Grid Y coordinate
---@return table Facility information for display
function FacilityGridUI:getFacilityInfo(x, y)
    local facility = self:getFacility(x, y)
    if not facility or facility.type == "empty" then
        return {
            name = "Empty Slot",
            type = "empty",
            description = "Available for construction",
            canBuild = true
        }
    end

    local info = {
        name = self:getFacilityDisplayName(facility.type),
        type = facility.type,
        level = facility.level or 1,
        condition = facility.condition or 100,
        adjacencyBonuses = self:getAdjacencyBonuses(x, y),
        powerData = self:getPowerData(x, y)
    }

    -- Add construction info if under construction
    if not facility.built then
        info.constructionDays = facility.constructionDays or 0
        info.constructionCost = facility.constructionCost or 0
        info.description = string.format("Under construction (%d days remaining)", info.constructionDays)
    else
        info.description = self:getFacilityDescription(facility.type)
    end

    return info
end

--- Get facility description
---@param facilityType string Type of facility
---@return string Description
function FacilityGridUI:getFacilityDescription(facilityType)
    local descriptions = {
        command = "Base command center. Required for base operation.",
        quarters = "Living quarters for personnel. Increases recruitment capacity.",
        hangar = "Aircraft maintenance and storage facility.",
        laboratory = "Research facility. Accelerates technological development.",
        workshop = "Manufacturing facility. Produces equipment and weapons.",
        storage = "Storage facility. Increases resource capacity.",
        power = "Power generation facility. Provides electricity to other buildings.",
        radar = "Radar facility. Extends detection range.",
        medical = "Medical facility. Heals wounded soldiers faster.",
        prison = "Containment facility. Holds alien prisoners for interrogation."
    }
    return descriptions[facilityType] or "Facility"
end

return FacilityGridUI
