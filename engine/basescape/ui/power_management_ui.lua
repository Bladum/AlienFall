---@class PowerManagementUI
---@field base table Reference to base data
---@field facilityGridUI table Reference to facility grid UI for power data
---@field uiOffsetX number X offset for UI positioning (grid-aligned)
---@field uiOffsetY number Y offset for UI positioning (grid-aligned)
---@field uiWidth number Width of the power management interface
---@field uiHeight number Height of the power management interface
---@field powerSources table List of power-generating facilities
---@field powerConsumers table List of power-consuming facilities
---@field totalGeneration number Total power generation capacity
---@field totalConsumption number Total power consumption
---@field powerEfficiency number Overall power efficiency (0-1)
---@field powerShortage boolean Whether there's a power shortage
---@field selectedFacility table Currently selected facility for power details
local PowerManagementUI = {}
PowerManagementUI.__index = PowerManagementUI

-- ============================================================================
-- CONSTANTS
-- ============================================================================

local POWER_CONSUMPTION = {
    command = 10,
    quarters = 5,
    hangar = 8,
    laboratory = 12,
    workshop = 15,
    storage = 3,
    radar = 6,
    medical = 9,
    prison = 7
}

local POWER_GENERATION = {
    power = 25  -- Base power generation per power plant
}

local EFFICIENCY_THRESHOLDS = {
    excellent = 0.9,  -- 90%+ efficiency
    good = 0.75,      -- 75-89% efficiency
    fair = 0.6,       -- 60-74% efficiency
    poor = 0.4        -- 40-59% efficiency
}

-- ============================================================================
-- INITIALIZATION
-- ============================================================================

---@param base table Base data structure
---@param facilityGridUI table Reference to facility grid UI
---@return table New PowerManagementUI instance
function PowerManagementUI:new(base, facilityGridUI)
    local self = setmetatable({}, PowerManagementUI)

    self.base = base or {}
    self.facilityGridUI = facilityGridUI

    -- Position UI in the info panel area (grid-aligned)
    local windowWidth = love.graphics.getWidth()
    self.uiOffsetX = math.floor((windowWidth - 360) / 24) * 24  -- Same as info panel
    self.uiOffsetY = 72 + 504 + 10  -- Below info panel
    self.uiWidth = 360
    self.uiHeight = 120

    self.powerSources = {}
    self.powerConsumers = {}
    self.totalGeneration = 0
    self.totalConsumption = 0
    self.powerEfficiency = 1.0
    self.powerShortage = false
    self.selectedFacility = nil

    -- Calculate initial power data
    self:calculatePowerData()

    return self
end

---@param base table Update the base reference
---@param facilityGridUI table Update the facility grid UI reference
function PowerManagementUI:setBase(base, facilityGridUI)
    self.base = base or {}
    self.facilityGridUI = facilityGridUI
    self:calculatePowerData()
end

-- ============================================================================
-- POWER CALCULATIONS
-- ============================================================================

--- Calculate power generation, consumption, and efficiency
function PowerManagementUI:calculatePowerData()
    self.powerSources = {}
    self.powerConsumers = {}
    self.totalGeneration = 0
    self.totalConsumption = 0

    -- Scan all facilities for power data
    if self.base.facilities then
        for y = 1, #self.base.facilities do
            for x = 1, #self.base.facilities[y] do
                local facility = self.base.facilities[y][x]
                if facility and facility.type ~= "empty" then
                    self:analyzeFacilityPower(facility, x, y)
                end
            end
        end
    end

    -- Calculate efficiency and shortage status
    self:calculateEfficiency()
    self.powerShortage = self.totalConsumption > self.totalGeneration
end

--- Analyze power data for a specific facility
---@param facility table Facility data
---@param x number Grid X coordinate
---@param y number Grid Y coordinate
function PowerManagementUI:analyzeFacilityPower(facility, x, y)
    local facilityType = facility.type

    -- Power generation
    if POWER_GENERATION[facilityType] then
        local generation = POWER_GENERATION[facilityType]

        -- Apply adjacency bonuses
        if self.facilityGridUI then
            local bonuses = self.facilityGridUI:getAdjacencyBonuses(x, y)
            for _, bonus in ipairs(bonuses) do
                if bonus.type == "power" then
                    generation = generation * (1 + bonus.value / 100)
                end
            end
        end

        table.insert(self.powerSources, {
            type = facilityType,
            x = x,
            y = y,
            generation = generation,
            efficiency = facility.condition and facility.condition / 100 or 1.0
        })

        self.totalGeneration = self.totalGeneration + generation
    end

    -- Power consumption
    if POWER_CONSUMPTION[facilityType] then
        local consumption = POWER_CONSUMPTION[facilityType]

        -- Facilities under construction consume less power
        if not facility.built then
            consumption = consumption * 0.5
        end

        -- Damaged facilities consume more power
        if facility.condition and facility.condition < 100 then
            consumption = consumption * (1 + (100 - facility.condition) / 200)
        end

        table.insert(self.powerConsumers, {
            type = facilityType,
            x = x,
            y = y,
            consumption = consumption,
            built = facility.built,
            condition = facility.condition or 100
        })

        self.totalConsumption = self.totalConsumption + consumption
    end
end

--- Calculate overall power efficiency
function PowerManagementUI:calculateEfficiency()
    if self.totalGeneration == 0 then
        self.powerEfficiency = 0
        return
    end

    -- Base efficiency
    local baseEfficiency = math.min(1.0, self.totalGeneration / self.totalConsumption)

    -- Apply penalties for power plants at low condition
    local plantPenalty = 0
    for _, source in ipairs(self.powerSources) do
        if source.efficiency < 0.8 then
            plantPenalty = plantPenalty + (0.8 - source.efficiency) * 0.1
        end
    end

    self.powerEfficiency = math.max(0, baseEfficiency - plantPenalty)
end

--- Get power status description
---@return string Status description
function PowerManagementUI:getPowerStatus()
    if self.powerShortage then
        return "CRITICAL: Power Shortage"
    elseif self.powerEfficiency >= EFFICIENCY_THRESHOLDS.excellent then
        return "Excellent"
    elseif self.powerEfficiency >= EFFICIENCY_THRESHOLDS.good then
        return "Good"
    elseif self.powerEfficiency >= EFFICIENCY_THRESHOLDS.fair then
        return "Fair"
    elseif self.powerEfficiency >= EFFICIENCY_THRESHOLDS.poor then
        return "Poor"
    else
        return "Critical"
    end
end

--- Get power status color
---@return number, number, number RGB color values
function PowerManagementUI:getPowerStatusColor()
    if self.powerShortage then
        return 0.8, 0.2, 0.2  -- Red
    elseif self.powerEfficiency >= EFFICIENCY_THRESHOLDS.excellent then
        return 0.2, 0.8, 0.2  -- Green
    elseif self.powerEfficiency >= EFFICIENCY_THRESHOLDS.good then
        return 0.6, 0.8, 0.2  -- Yellow-Green
    elseif self.powerEfficiency >= EFFICIENCY_THRESHOLDS.fair then
        return 0.8, 0.6, 0.2  -- Yellow
    elseif self.powerEfficiency >= EFFICIENCY_THRESHOLDS.poor then
        return 0.8, 0.4, 0.2  -- Orange
    else
        return 0.8, 0.2, 0.2  -- Red
    end
end

--- Get power surplus/deficit
---@return number Power surplus (positive) or deficit (negative)
function PowerManagementUI:getPowerBalance()
    return self.totalGeneration - self.totalConsumption
end

-- ============================================================================
-- RENDERING
-- ============================================================================

--- Render the power management interface
function PowerManagementUI:draw()
    -- Draw background panel
    self:drawBackground()

    -- Draw power status header
    self:drawPowerHeader()

    -- Draw power bars
    self:drawPowerBars()

    -- Draw power sources and consumers
    self:drawPowerDetails()

    -- Draw warnings if needed
    self:drawWarnings()
end

--- Draw the background panel
function PowerManagementUI:drawBackground()
    -- Main panel background
    love.graphics.setColor(0.1, 0.1, 0.15, 0.9)
    love.graphics.rectangle("fill", self.uiOffsetX, self.uiOffsetY, self.uiWidth, self.uiHeight)

    -- Border
    love.graphics.setColor(0.3, 0.3, 0.4, 0.8)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", self.uiOffsetX, self.uiOffsetY, self.uiWidth, self.uiHeight)
end

--- Draw the power status header
function PowerManagementUI:drawPowerHeader()
    local headerY = self.uiOffsetY + 5

    -- Title
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.print("Power Management", self.uiOffsetX + 10, headerY)

    -- Status
    local status = self:getPowerStatus()
    local r, g, b = self:getPowerStatusColor()
    love.graphics.setColor(r, g, b)
    love.graphics.print(status, self.uiOffsetX + self.uiWidth - 60, headerY)
end

--- Draw power generation and consumption bars
function PowerManagementUI:drawPowerBars()
    local barY = self.uiOffsetY + 25
    local barWidth = self.uiWidth - 20
    local barHeight = 12
    local barX = self.uiOffsetX + 10

    -- Generation bar
    love.graphics.setColor(0.2, 0.2, 0.3)
    love.graphics.rectangle("fill", barX, barY, barWidth, barHeight)

    local genRatio = math.min(1.0, self.totalGeneration / math.max(self.totalGeneration, self.totalConsumption))
    love.graphics.setColor(0.2, 0.8, 0.2)
    love.graphics.rectangle("fill", barX, barY, barWidth * genRatio, barHeight)

    -- Consumption bar
    love.graphics.setColor(0.3, 0.2, 0.2)
    love.graphics.rectangle("fill", barX, barY + barHeight + 2, barWidth, barHeight)

    local consRatio = math.min(1.0, self.totalConsumption / math.max(self.totalGeneration, self.totalConsumption))
    love.graphics.setColor(0.8, 0.4, 0.2)
    love.graphics.rectangle("fill", barX, barY + barHeight + 2, barWidth * consRatio, barHeight)

    -- Labels
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(8))
    love.graphics.print(string.format("Generation: %.1f MW", self.totalGeneration), barX, barY - 12)
    love.graphics.print(string.format("Consumption: %.1f MW", self.totalConsumption), barX, barY + barHeight + 2 - 12)

    -- Balance
    local balance = self:getPowerBalance()
    if balance >= 0 then
        love.graphics.setColor(0.2, 0.8, 0.2)
        love.graphics.print(string.format("Surplus: +%.1f MW", balance), barX + barWidth - 80, barY + barHeight * 2 + 5)
    else
        love.graphics.setColor(0.8, 0.2, 0.2)
        love.graphics.print(string.format("Deficit: %.1f MW", balance), barX + barWidth - 80, barY + barHeight * 2 + 5)
    end
end

--- Draw detailed power information
function PowerManagementUI:drawPowerDetails()
    local detailsY = self.uiOffsetY + 70
    local leftX = self.uiOffsetX + 10
    local rightX = self.uiOffsetX + self.uiWidth / 2 + 10

    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.setFont(love.graphics.newFont(8))

    -- Sources count
    love.graphics.print(string.format("Sources: %d", #self.powerSources), leftX, detailsY)

    -- Consumers count
    love.graphics.print(string.format("Consumers: %d", #self.powerConsumers), rightX, detailsY)

    -- Efficiency
    local efficiencyText = string.format("Efficiency: %.1f%%", self.powerEfficiency * 100)
    love.graphics.print(efficiencyText, leftX, detailsY + 12)

    -- Most efficient source
    if #self.powerSources > 0 then
        local bestSource = self:getBestPowerSource()
        love.graphics.print(string.format("Best: %s (%.1f)", bestSource.type, bestSource.generation), rightX, detailsY + 12)
    end
end

--- Draw power-related warnings
function PowerManagementUI:drawWarnings()
    if not self.powerShortage and self.powerEfficiency > EFFICIENCY_THRESHOLDS.fair then
        return -- No warnings needed
    end

    local warningY = self.uiOffsetY + self.uiHeight - 20

    love.graphics.setColor(0.9, 0.7, 0.2)
    love.graphics.setFont(love.graphics.newFont(8))

    if self.powerShortage then
        love.graphics.print("⚠ CRITICAL: Build more power plants!", self.uiOffsetX + 10, warningY)
    elseif self.powerEfficiency < EFFICIENCY_THRESHOLDS.fair then
        love.graphics.print("⚠ WARNING: Low power efficiency", self.uiOffsetX + 10, warningY)
    end
end

--- Get the best performing power source
---@return table Best power source data
function PowerManagementUI:getBestPowerSource()
    local best = self.powerSources[1]
    for _, source in ipairs(self.powerSources) do
        if source.generation > best.generation then
            best = source
        end
    end
    return best
end

-- ============================================================================
-- INPUT HANDLING
-- ============================================================================

--- Handle mouse press
---@param x number Mouse X coordinate
---@param y number Mouse Y coordinate
---@param button number Mouse button
function PowerManagementUI:mousepressed(x, y, button)
    -- Check if click is within power bars area
    if button == 1 and self:isMouseOverBars(x, y) then
        -- Could implement clicking on bars for detailed view
        print("[PowerManagementUI] Power bars clicked")
    end
end

--- Check if mouse is over the power bars
---@param x number Mouse X coordinate
---@param y number Mouse Y coordinate
---@return boolean Whether mouse is over bars
function PowerManagementUI:isMouseOverBars(x, y)
    local barY = self.uiOffsetY + 25
    local barHeight = 12 * 2 + 2  -- Two bars plus gap
    local barX = self.uiOffsetX + 10
    local barWidth = self.uiWidth - 20

    return x >= barX and x <= barX + barWidth and y >= barY and y <= barY + barHeight
end

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================

--- Get detailed power information for display
---@return table Power information
function PowerManagementUI:getPowerInfo()
    return {
        status = self:getPowerStatus(),
        generation = self.totalGeneration,
        consumption = self.totalConsumption,
        balance = self:getPowerBalance(),
        efficiency = self.powerEfficiency,
        sources = #self.powerSources,
        consumers = #self.powerConsumers,
        shortage = self.powerShortage,
        statusColor = {self:getPowerStatusColor()}
    }
end

--- Check if base has sufficient power for a new facility
---@param facilityType string Type of facility to check
---@return boolean Whether there's enough power
function PowerManagementUI:hasPowerForFacility(facilityType)
    local consumption = POWER_CONSUMPTION[facilityType] or 0
    return (self.totalGeneration - self.totalConsumption) >= consumption
end

--- Get power consumption for a facility type
---@param facilityType string Type of facility
---@return number Power consumption
function PowerManagementUI:getFacilityConsumption(facilityType)
    return POWER_CONSUMPTION[facilityType] or 0
end

--- Get power generation for a facility type
---@param facilityType string Type of facility
---@return number Power generation
function PowerManagementUI:getFacilityGeneration(facilityType)
    return POWER_GENERATION[facilityType] or 0
end

return PowerManagementUI
