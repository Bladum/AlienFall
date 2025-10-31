---@class TechnologyTreeUI
---@field base table Reference to base data
---@field researchSystem table Reference to research system
---@field uiOffsetX number X offset for UI positioning (grid-aligned)
---@field uiOffsetY number Y offset for UI positioning (grid-aligned)
---@field uiWidth number Width of the technology tree interface
---@field uiHeight number Height of the technology tree interface
---@field technologies table List of all technologies
---@field selectedTech table Currently selected technology for detailed view
---@field zoomLevel number Current zoom level (0.5 to 2.0)
---@field panX number Current pan X offset
---@field panY number Current pan Y offset
---@field nodeSize number Size of technology nodes
---@field connectionLines table Cached connection lines between technologies
---@field onTechSelected function Callback when technology is selected
local TechnologyTreeUI = {}
TechnologyTreeUI.__index = TechnologyTreeUI

-- ============================================================================
-- CONSTANTS
-- ============================================================================

local NODE_SIZE = 80  -- Size of technology nodes
local NODE_SPACING_X = 120  -- Horizontal spacing between nodes
local NODE_SPACING_Y = 100  -- Vertical spacing between nodes
local CONNECTION_THICKNESS = 2  -- Thickness of prerequisite connection lines
local MIN_ZOOM = 0.5
local MAX_ZOOM = 2.0
local ZOOM_SPEED = 0.1

-- Technology categories and their colors
local CATEGORY_COLORS = {
    weapons = {0.8, 0.3, 0.3},      -- Red
    armor = {0.3, 0.8, 0.3},        -- Green
    alien_tech = {0.8, 0.3, 0.8},   -- Purple
    facilities = {0.3, 0.6, 0.8},   -- Blue
    foundation = {0.8, 0.6, 0.3},   -- Orange
    support = {0.6, 0.6, 0.6}       -- Gray
}

-- ============================================================================
-- INITIALIZATION
-- ============================================================================

---@param base table Base data structure
---@return table New TechnologyTreeUI instance
function TechnologyTreeUI:new(base)
    local self = setmetatable({}, TechnologyTreeUI)

    self.base = base or {}
    self.researchSystem = nil

    -- Position UI to fill most of the screen (grid-aligned)
    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()
    self.uiOffsetX = 24  -- Left margin
    self.uiOffsetY = 120  -- Below buttons
    self.uiWidth = windowWidth - 48
    self.uiHeight = windowHeight - 144

    self.technologies = {}
    self.selectedTech = nil
    self.zoomLevel = 1.0
    self.panX = 0
    self.panY = 0
    self.nodeSize = NODE_SIZE
    self.connectionLines = {}

    -- Initialize data
    self:updateTechnologies()
    self:layoutTechnologies()
    self:cacheConnectionLines()

    return self
end

---@param base table Update the base reference
function TechnologyTreeUI:setBase(base)
    self.base = base or {}
    self:updateTechnologies()
    self:layoutTechnologies()
    self:cacheConnectionLines()
end

---@param researchSystem table Set the research system reference
function TechnologyTreeUI:setResearchSystem(researchSystem)
    self.researchSystem = researchSystem
    self:updateTechnologies()
    self:layoutTechnologies()
    self:cacheConnectionLines()
end

-- ============================================================================
-- DATA MANAGEMENT
-- ============================================================================

--- Update the list of technologies
function TechnologyTreeUI:updateTechnologies()
    self.technologies = {}

    if not self.researchSystem then
        -- Fallback: create sample technologies
        self.technologies = {
            {
                id = "basic_construction",
                name = "Basic Construction",
                category = "foundation",
                tier = 1,
                description = "Foundational construction techniques",
                research_points_required = 100,
                requires_tech = {},
                is_researched = true,
                is_available = true,
                unlocks_techs = {"advanced_construction", "base_fortification"}
            },
            {
                id = "advanced_construction",
                name = "Advanced Construction",
                category = "foundation",
                tier = 2,
                description = "Advanced building techniques",
                research_points_required = 200,
                requires_tech = {"basic_construction"},
                is_researched = false,
                is_available = true,
                unlocks_techs = {"laser_weapons"}
            },
            {
                id = "laser_weapons",
                name = "Laser Weapons",
                category = "weapons",
                tier = 2,
                description = "Advanced energy weapons technology",
                research_points_required = 300,
                requires_tech = {"advanced_construction"},
                is_researched = false,
                is_available = false,
                unlocks_techs = {"plasma_weapons"}
            },
            {
                id = "plasma_weapons",
                name = "Plasma Weapons",
                category = "weapons",
                tier = 3,
                description = "High-energy plasma-based weaponry",
                research_points_required = 500,
                requires_tech = {"laser_weapons"},
                is_researched = false,
                is_available = false,
                unlocks_techs = {}
            },
            {
                id = "personal_armor",
                name = "Personal Armor",
                category = "armor",
                tier = 2,
                description = "Advanced protective suits",
                research_points_required = 250,
                requires_tech = {"basic_construction"},
                is_researched = false,
                is_available = true,
                unlocks_techs = {"power_armor"}
            },
            {
                id = "power_armor",
                name = "Power Armor",
                category = "armor",
                tier = 3,
                description = "Mechanically enhanced armor",
                research_points_required = 400,
                requires_tech = {"personal_armor"},
                is_researched = false,
                is_available = false,
                unlocks_techs = {}
            }
        }
        return
    end

    -- Get technologies from research system
    local techs = self.researchSystem:getAllTechnologies()
    for _, tech in ipairs(techs) do
        table.insert(self.technologies, {
            id = tech.id,
            name = tech.name,
            category = tech.category,
            tier = tech.tier or 1,
            description = tech.description,
            research_points_required = tech.research_points_required or 100,
            requires_tech = tech.requires_tech or {},
            is_researched = tech.is_researched or false,
            is_available = tech.is_available or false,
            unlocks_techs = tech.unlocks_techs or {}
        })
    end
end

--- Layout technologies in a tree structure
function TechnologyTreeUI:layoutTechnologies()
    -- Group technologies by tier
    local tiers = {}
    for _, tech in ipairs(self.technologies) do
        local tier = tech.tier or 1
        if not tiers[tier] then
            tiers[tier] = {}
        end
        table.insert(tiers[tier], tech)
    end

    -- Calculate positions for each technology
    local maxTier = 0
    for tier, _ in pairs(tiers) do
        maxTier = math.max(maxTier, tier)
    end

    for tier = 1, maxTier do
        local tierTechs = tiers[tier] or {}
        local tierWidth = #tierTechs * NODE_SPACING_X
        local startX = -tierWidth / 2

        for i, tech in ipairs(tierTechs) do
            tech.x = startX + (i - 1) * NODE_SPACING_X
            tech.y = (tier - 1) * NODE_SPACING_Y
        end
    end
end

--- Cache connection lines between technologies
function TechnologyTreeUI:cacheConnectionLines()
    self.connectionLines = {}

    for _, tech in ipairs(self.technologies) do
        if tech.requires_tech and #tech.requires_tech > 0 then
            for _, prereqId in ipairs(tech.requires_tech) do
                local prereqTech = self:getTechById(prereqId)
                if prereqTech then
                    table.insert(self.connectionLines, {
                        fromX = prereqTech.x + self.nodeSize / 2,
                        fromY = prereqTech.y + self.nodeSize / 2,
                        toX = tech.x + self.nodeSize / 2,
                        toY = tech.y + self.nodeSize / 2,
                        fromTech = prereqTech,
                        toTech = tech
                    })
                end
            end
        end
    end
end

--- Get technology by ID
---@param techId string Technology identifier
---@return table|nil Technology data or nil if not found
function TechnologyTreeUI:getTechById(techId)
    for _, tech in ipairs(self.technologies) do
        if tech.id == techId then
            return tech
        end
    end
    return nil
end

--- Get technologies that can be researched next
---@return table List of available technologies
function TechnologyTreeUI:getAvailableTechs()
    local available = {}
    for _, tech in ipairs(self.technologies) do
        if not tech.is_researched and tech.is_available then
            table.insert(available, tech)
        end
    end
    return available
end

--- Check if a technology can be selected
---@param tech table Technology data
---@return boolean Whether the technology can be selected
function TechnologyTreeUI:canSelectTech(tech)
    return tech ~= nil
end

--- Select a technology
---@param tech table Technology data
function TechnologyTreeUI:selectTech(tech)
    if self:canSelectTech(tech) then
        self.selectedTech = tech
        if self.onTechSelected then
            self.onTechSelected(tech.id)
        end
    end
end

-- ============================================================================
-- RENDERING
-- ============================================================================

--- Render the technology tree interface
function TechnologyTreeUI:draw()
    -- Apply zoom and pan transformations
    love.graphics.push()
    love.graphics.translate(self.uiOffsetX + self.uiWidth / 2 + self.panX,
                           self.uiOffsetY + self.uiHeight / 2 + self.panY)
    love.graphics.scale(self.zoomLevel, self.zoomLevel)

    -- Draw connection lines first (behind nodes)
    self:drawConnectionLines()

    -- Draw technology nodes
    self:drawTechnologyNodes()

    love.graphics.pop()

    -- Draw UI overlay (zoom controls, etc.)
    self:drawUIOverlay()

    -- Draw technology details if selected
    self:drawTechDetails()
end

--- Draw connection lines between technologies
function TechnologyTreeUI:drawConnectionLines()
    love.graphics.setLineWidth(CONNECTION_THICKNESS / self.zoomLevel)

    for _, connection in ipairs(self.connectionLines) do
        -- Determine line color based on research status
        local fromResearched = connection.fromTech.is_researched
        local toResearched = connection.toTech.is_researched
        local toAvailable = connection.toTech.is_available

        if fromResearched and toResearched then
            love.graphics.setColor(0.2, 0.8, 0.2, 0.8)  -- Green: completed path
        elseif fromResearched and toAvailable then
            love.graphics.setColor(0.8, 0.8, 0.2, 0.8)  -- Yellow: available path
        elseif fromResearched then
            love.graphics.setColor(0.8, 0.6, 0.2, 0.6)  -- Orange: partial path
        else
            love.graphics.setColor(0.4, 0.4, 0.4, 0.4)  -- Gray: unavailable path
        end

        love.graphics.line(connection.fromX, connection.fromY, connection.toX, connection.toY)
    end
end

--- Draw technology nodes
function TechnologyTreeUI:drawTechnologyNodes()
    for _, tech in ipairs(self.technologies) do
        self:drawTechnologyNode(tech)
    end
end

--- Draw a single technology node
---@param tech table Technology data
function TechnologyTreeUI:drawTechnologyNode(tech)
    local x, y = tech.x, tech.y
    local size = self.nodeSize
    local isSelected = self.selectedTech and self.selectedTech.id == tech.id
    local isHovered = self:isNodeHovered(tech)

    -- Node background color based on status
    local bgColor
    if tech.is_researched then
        bgColor = {0.2, 0.6, 0.2, 0.9}  -- Green: researched
    elseif tech.is_available then
        bgColor = {0.6, 0.6, 0.2, 0.9}  -- Yellow: available
    else
        bgColor = {0.4, 0.4, 0.4, 0.7}  -- Gray: locked
    end

    -- Highlight if selected or hovered
    if isSelected then
        bgColor = {0.4, 0.7, 0.9, 0.95}  -- Blue: selected
    elseif isHovered then
        -- Brighten the color when hovered
        bgColor[4] = math.min(1.0, bgColor[4] + 0.2)
    end

    -- Draw node background
    love.graphics.setColor(bgColor)
    love.graphics.rectangle("fill", x, y, size, size, 8, 8)

    -- Draw category-colored border
    local borderColor = CATEGORY_COLORS[tech.category] or {0.6, 0.6, 0.6}
    love.graphics.setColor(borderColor)
    love.graphics.setLineWidth(2 / self.zoomLevel)
    love.graphics.rectangle("line", x, y, size, size, 8, 8)

    -- Draw technology name
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(math.max(8, 12 / self.zoomLevel)))
    local name = tech.name
    if love.graphics.getFont():getWidth(name) > size - 8 then
        name = name:sub(1, 8) .. "..."
    end
    local textY = y + size / 2 - love.graphics.getFont():getHeight() / 2
    love.graphics.printf(name, x + 4, textY, size - 8, "center")

    -- Draw research status icon
    if tech.is_researched then
        love.graphics.setColor(0.2, 0.8, 0.2)
        love.graphics.printf("✓", x + size - 16, y + 4, 12, "center")
    elseif tech.is_available then
        love.graphics.setColor(0.8, 0.8, 0.2)
        love.graphics.printf("○", x + size - 16, y + 4, 12, "center")
    else
        love.graphics.setColor(0.6, 0.6, 0.6)
        love.graphics.printf("🔒", x + size - 16, y + 4, 12, "center")
    end

    -- Draw tier indicator
    love.graphics.setColor(0.9, 0.9, 0.9)
    love.graphics.setFont(love.graphics.newFont(math.max(6, 8 / self.zoomLevel)))
    love.graphics.printf("T" .. (tech.tier or 1), x + 4, y + 4, 20, "left")
end

--- Draw UI overlay (zoom controls, legend, etc.)
function TechnologyTreeUI:drawUIOverlay()
    -- Zoom controls
    local controlsY = self.uiOffsetY - 40
    love.graphics.setColor(0.1, 0.1, 0.15, 0.9)
    love.graphics.rectangle("fill", self.uiOffsetX, controlsY, 200, 30)

    love.graphics.setColor(0.5, 0.5, 0.6)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", self.uiOffsetX, controlsY, 200, 30)

    -- Zoom buttons
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(10))
    love.graphics.print("Zoom: " .. string.format("%.1f", self.zoomLevel), self.uiOffsetX + 10, controlsY + 8)

    -- Zoom in button
    local zoomInX = self.uiOffsetX + 120
    self:drawZoomButton("+", zoomInX, controlsY + 2, 20, 26)

    -- Zoom out button
    local zoomOutX = zoomInX + 25
    self:drawZoomButton("-", zoomOutX, controlsY + 2, 20, 26)

    -- Legend
    local legendX = self.uiOffsetX + self.uiWidth - 250
    self:drawLegend(legendX, controlsY)
end

--- Draw a zoom control button
---@param label string Button label (+ or -)
---@param x number Button X position
---@param y number Button Y position
---@param width number Button width
---@param height number Button height
function TechnologyTreeUI:drawZoomButton(label, x, y, width, height)
    local isHovered = self:isButtonHovered(x, y, width, height)

    if isHovered then
        love.graphics.setColor(0.3, 0.5, 0.7, 0.8)
    else
        love.graphics.setColor(0.2, 0.3, 0.4, 0.7)
    end

    love.graphics.rectangle("fill", x, y, width, height)

    love.graphics.setColor(0.6, 0.7, 0.8)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", x, y, width, height)

    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(12))
    local textWidth = love.graphics.getFont():getWidth(label)
    love.graphics.print(label, x + (width - textWidth) / 2, y + 4)
end

--- Draw the legend
---@param x number Legend X position
---@param y number Legend Y position
function TechnologyTreeUI:drawLegend(x, y)
    love.graphics.setColor(0.1, 0.1, 0.15, 0.9)
    love.graphics.rectangle("fill", x, y, 240, 30)

    love.graphics.setColor(0.5, 0.5, 0.6)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", x, y, 240, 30)

    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(9))

    -- Status indicators
    local legendY = y + 6
    love.graphics.setColor(0.2, 0.8, 0.2)
    love.graphics.print("●", x + 10, legendY)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Researched", x + 25, legendY)

    love.graphics.setColor(0.8, 0.8, 0.2)
    love.graphics.print("●", x + 100, legendY)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Available", x + 115, legendY)

    love.graphics.setColor(0.6, 0.6, 0.6)
    love.graphics.print("●", x + 180, legendY)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Locked", x + 195, legendY)
end

--- Draw technology details panel
function TechnologyTreeUI:drawTechDetails()
    if not self.selectedTech then return end

    local panelX = self.uiOffsetX + self.uiWidth - 320
    local panelY = self.uiOffsetY + 40
    local panelWidth = 300
    local panelHeight = 400

    -- Panel background
    love.graphics.setColor(0.1, 0.1, 0.15, 0.95)
    love.graphics.rectangle("fill", panelX, panelY, panelWidth, panelHeight)

    -- Panel border
    love.graphics.setColor(0.3, 0.3, 0.4, 0.8)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", panelX, panelY, panelWidth, panelHeight)

    -- Technology details
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(14))
    love.graphics.print(self.selectedTech.name, panelX + 10, panelY + 10)

    love.graphics.setFont(love.graphics.newFont(10))
    love.graphics.setColor(0.8, 0.8, 0.8)

    -- Category and tier
    local categoryColor = CATEGORY_COLORS[self.selectedTech.category] or {0.6, 0.6, 0.6}
    love.graphics.setColor(categoryColor)
    love.graphics.print("Category: " .. (self.selectedTech.category or "unknown"):gsub("^%l", string.upper), panelX + 10, panelY + 35)

    love.graphics.setColor(0.9, 0.9, 0.9)
    love.graphics.print("Tier: " .. (self.selectedTech.tier or 1), panelX + 10, panelY + 50)

    -- Research points
    love.graphics.print("Research Points: " .. (self.selectedTech.research_points_required or 100), panelX + 10, panelY + 70)

    -- Status
    local statusY = panelY + 90
    if self.selectedTech.is_researched then
        love.graphics.setColor(0.2, 0.8, 0.2)
        love.graphics.print("Status: ✓ RESEARCHED", panelX + 10, statusY)
    elseif self.selectedTech.is_available then
        love.graphics.setColor(0.8, 0.8, 0.2)
        love.graphics.print("Status: ○ AVAILABLE", panelX + 10, statusY)
    else
        love.graphics.setColor(0.8, 0.2, 0.2)
        love.graphics.print("Status: 🔒 LOCKED", panelX + 10, statusY)
    end

    -- Description
    love.graphics.setColor(0.9, 0.9, 0.9)
    love.graphics.setFont(love.graphics.newFont(9))
    local descY = panelY + 110
    local words = {}
    for word in self.selectedTech.description:gmatch("%S+") do
        table.insert(words, word)
    end

    local line = ""
    local lineY = descY
    for _, word in ipairs(words) do
        local testLine = line .. (line == "" and "" or " ") .. word
        if love.graphics.getFont():getWidth(testLine) > panelWidth - 20 then
            love.graphics.print(line, panelX + 10, lineY)
            line = word
            lineY = lineY + 12
        else
            line = testLine
        end
    end
    if line ~= "" then
        love.graphics.print(line, panelX + 10, lineY)
    end

    -- Prerequisites
    if self.selectedTech.requires_tech and #self.selectedTech.requires_tech > 0 then
        love.graphics.setColor(0.9, 0.9, 0.2)
        love.graphics.print("Prerequisites:", panelX + 10, lineY + 20)
        love.graphics.setColor(0.8, 0.8, 0.8)
        for i, prereqId in ipairs(self.selectedTech.requires_tech) do
            local prereqTech = self:getTechById(prereqId)
            local prereqName = prereqTech and prereqTech.name or prereqId:gsub("_", " "):gsub("^%l", string.upper)
            local status = prereqTech and prereqTech.is_researched and "✓" or "○"
            love.graphics.print(status .. " " .. prereqName, panelX + 20, lineY + 32 + (i-1) * 12)
        end
    end

    -- Unlocks
    if self.selectedTech.unlocks_techs and #self.selectedTech.unlocks_techs > 0 then
        local unlocksY = lineY + (#(self.selectedTech.requires_tech or {}) * 12) + 50
        love.graphics.setColor(0.2, 0.9, 0.2)
        love.graphics.print("Unlocks:", panelX + 10, unlocksY)
        love.graphics.setColor(0.8, 0.8, 0.8)
        for i, unlockId in ipairs(self.selectedTech.unlocks_techs) do
            local unlockTech = self:getTechById(unlockId)
            local unlockName = unlockTech and unlockTech.name or unlockId:gsub("_", " "):gsub("^%l", string.upper)
            love.graphics.print("• " .. unlockName, panelX + 20, unlocksY + 12 + (i-1) * 12)
        end
    end
end

-- ============================================================================
-- INPUT HANDLING
-- ============================================================================

--- Update the UI state
---@param dt number Delta time
function TechnologyTreeUI:update(dt)
    -- Update any animations or timers if needed
end

--- Handle mouse press
---@param x number Mouse X coordinate
---@param y number Mouse Y coordinate
---@param button number Mouse button
function TechnologyTreeUI:mousepressed(x, y, button)
    if button == 1 then  -- Left click
        -- Check zoom buttons
        local controlsY = self.uiOffsetY - 40
        local zoomInX = self.uiOffsetX + 120
        local zoomOutX = zoomInX + 25

        if self:isButtonHovered(zoomInX, controlsY + 2, 20, 26) then
            self:setZoom(self.zoomLevel + ZOOM_SPEED)
            return
        elseif self:isButtonHovered(zoomOutX, controlsY + 2, 20, 26) then
            self:setZoom(self.zoomLevel - ZOOM_SPEED)
            return
        end

        -- Check technology nodes (transformed coordinates)
        local localX = (x - self.uiOffsetX - self.uiWidth / 2 - self.panX) / self.zoomLevel
        local localY = (y - self.uiOffsetY - self.uiHeight / 2 - self.panY) / self.zoomLevel

        for _, tech in ipairs(self.technologies) do
            if localX >= tech.x and localX <= tech.x + self.nodeSize
               and localY >= tech.y and localY <= tech.y + self.nodeSize then
                self:selectTech(tech)
                return
            end
        end

        -- Clear selection if clicking empty space
        self.selectedTech = nil
    elseif button == 3 then  -- Right click
        -- Start panning
        self.isPanning = true
        self.lastPanX = x
        self.lastPanY = y
    end
end

--- Handle mouse release
---@param x number Mouse X coordinate
---@param y number Mouse Y coordinate
---@param button number Mouse button
function TechnologyTreeUI:mousereleased(x, y, button)
    if button == 3 then  -- Right click
        self.isPanning = false
    end
end

--- Handle mouse movement
---@param x number Mouse X coordinate
---@param y number Mouse Y coordinate
---@param dx number Delta X
---@param dy number Delta Y
function TechnologyTreeUI:mousemoved(x, y, dx, dy)
    if self.isPanning then
        self.panX = self.panX + dx
        self.panY = self.panY + dy
        self.lastPanX = x
        self.lastPanY = y
    end
end

--- Handle mouse wheel for zooming
---@param x number Mouse X coordinate
---@param y number Mouse Y coordinate
function TechnologyTreeUI:mousewheel(x, y)
    local zoomDelta = y * ZOOM_SPEED
    self:setZoom(self.zoomLevel + zoomDelta)
end

--- Set zoom level with bounds checking
---@param zoom number New zoom level
function TechnologyTreeUI:setZoom(zoom)
    self.zoomLevel = math.max(MIN_ZOOM, math.min(MAX_ZOOM, zoom))
    self.nodeSize = NODE_SIZE * self.zoomLevel
end

--- Check if a button is hovered
---@param x number Button X position
---@param y number Button Y position
---@param width number Button width
---@param height number Button height
---@return boolean Whether the button is hovered
function TechnologyTreeUI:isButtonHovered(x, y, width, height)
    local mx, my = love.mouse.getPosition()
    return mx >= x and mx <= x + width and my >= y and my <= y + height
end

--- Check if a technology node is hovered
---@param tech table Technology data
---@return boolean Whether the node is hovered
function TechnologyTreeUI:isNodeHovered(tech)
    local mx, my = love.mouse.getPosition()
    local localX = (mx - self.uiOffsetX - self.uiWidth / 2 - self.panX) / self.zoomLevel
    local localY = (my - self.uiOffsetY - self.uiHeight / 2 - self.panY) / self.zoomLevel

    return localX >= tech.x and localX <= tech.x + self.nodeSize
       and localY >= tech.y and localY <= tech.y + self.nodeSize
end

return TechnologyTreeUI
