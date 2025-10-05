-- Top Panel widget - Contains screen navigation, base/world selector, and action buttons
--- @class TopPanel
--- @description A top panel widget that provides navigation between game screens,
--- base/world selection, and action buttons (TURN/MENU). Implements a radio-button
--- style interface for screen selection with visual feedback.
--- @field x number The x-coordinate position of the panel
--- @field y number The y-coordinate position of the panel
--- @field width number The width of the panel in pixels
--- @field height number The height of the panel in pixels
--- @field sceneManager SceneManager Reference to the scene manager for navigation
--- @field screenButtons table Array of screen navigation buttons
--- @field selectedScreenIndex number Index of currently selected screen (1-10)
--- @field baseSelector GameComboBox Combo box for base/world selection
--- @field dateLabel string Current game date display string
--- @field moneyLabel string Current money display string
--- @field labelFont love.Font Font used for date/money labels
--- @field turnButton GameButton Button to advance game turn
--- @field menuButton GameButton Button to return to main menu
--- @field backgroundColor table Background color {r,g,b,a}
--- @field borderColor table Border color {r,g,b,a}
--- @field enabled boolean Whether the panel responds to input
--- @field visible boolean Whether the panel is drawn

local class = require("lib.middleclass")
local GameButton = require "widgets.GameButton"
local GameComboBox = require "widgets.GameComboBox"

local TopPanel = class('TopPanel')

--- Creates a new TopPanel instance
--- @param sceneManager SceneManager The scene manager for navigation and tooltips
--- @return TopPanel A new TopPanel instance
function TopPanel:initialize(sceneManager)
    -- Constants - using 20x20 pixel grid system
    local GRID_SIZE = 20
    local PANEL_HEIGHT = 2 * GRID_SIZE  -- 2 units high
    local PANEL_WIDTH = 40 * GRID_SIZE  -- Full screen width (800 pixels)

    -- Position (top of screen)
    self.x = 0
    self.y = 0
    self.width = PANEL_WIDTH
    self.height = PANEL_HEIGHT

    -- Scene manager reference for navigation and tooltips
    self.sceneManager = sceneManager

    -- Screen navigation buttons (10 buttons, 2x2 each = 20 units total)
    -- Maps screen names to their display names and functionality
    self.screenButtons = {}
    local screenNames = {"GEOSCAPE", "BASE", "RESEARCH", "MANUFACTURE", "PURCHASE", "SELL", "HIRE", "TRANSFER", "OPTIONS", "STATS"}
    local screenIcons = {
        "src/gfx/gui/icon_geoscape.png",
        "src/gfx/gui/icon_base.png",
        "src/gfx/gui/icon_research.png",
        "src/gfx/gui/icon_manufacture.png",
        "src/gfx/gui/icon_purchase.png",
        "src/gfx/gui/icon_sell.png",
        "src/gfx/gui/icon_hire.png",
        "src/gfx/gui/icon_transfer.png",
        "src/gfx/gui/icon_options.png",
        "src/gfx/gui/icon_stats.png"
    }
    local screenTooltips = {
        "Geoscape - World view and interception management",
        "Base - Manage your XCOM base facilities",
        "Research - Research new technologies",
        "Manufacture - Produce equipment and aircraft",
        "Purchase - Buy supplies and equipment",
        "Sell - Sell captured alien technology",
        "Hire - Recruit new personnel",
        "Transfer - Move personnel between bases",
        "Options - Game settings and preferences",
        "Stats - View game statistics"
    }
    self.selectedScreenIndex = 1

    -- Create screen navigation buttons with radio-button styling
    for i = 1, 10 do
        local buttonX = (i - 1) * 2 * GRID_SIZE
        local button = GameButton:new(
            buttonX, 0,
            2 * GRID_SIZE, 2 * GRID_SIZE,
            screenNames[i],
            function()
                self:setSelectedScreen(i)
                -- TODO: Switch to appropriate scene based on screenNames[i]
                print("Switching to screen: " .. screenNames[i])
            end,
            screenIcons[i]
        )

        -- Register tooltip for button
        if self.sceneManager and self.sceneManager.registerTooltip then
            self.sceneManager:registerTooltip(button, screenTooltips[i])
        end

        -- Style as radio buttons - selected button has blue theme
        if i == self.selectedScreenIndex then
            button:setColors({0.2, 0.6, 0.8, 1}, {0.3, 0.7, 0.9, 1}, {0.4, 0.8, 1.0, 1})
        else
            button:setColors({0.3, 0.3, 0.3, 1}, {0.5, 0.5, 0.5, 1}, {0.7, 0.7, 0.7, 1})
        end

        self.screenButtons[i] = button
    end

    -- Base/World selector combo box (8x2 units, positioned after screen buttons)
    local comboX = 20 * GRID_SIZE  -- After 10 buttons × 2 units each
    self.baseSelector = GameComboBox:new(
        comboX, 0,
        8 * GRID_SIZE, 2 * GRID_SIZE,
        {"XCOM HQ", "Base 1", "Base 2", "Base 3", "Base 4", "Base 5", "Base 6", "Base 7", "Base 8"},
        1,
        function(selectedIndex)
            print("Selected base: " .. self.baseSelector.options[selectedIndex])
        end
    )

    -- Money/Date label (positioned after combo box)
    local labelX = comboX + 8 * GRID_SIZE + GRID_SIZE  -- After combo box + 1 unit spacing
    self.dateLabel = "12 Sep 2025"
    self.moneyLabel = "23.232.1212 $"
    self.labelFont = love.graphics.newFont(14)

    -- TURN and MENU buttons (2x2 each, positioned at the far right)
    local turnButtonX = PANEL_WIDTH - 4 * GRID_SIZE  -- 2 buttons × 2 units each from right edge
    local menuButtonX = PANEL_WIDTH - 2 * GRID_SIZE

    -- TURN button - advances game turn (green theme)
    self.turnButton = GameButton:new(
        turnButtonX, 0,
        2 * GRID_SIZE, 2 * GRID_SIZE,
        "TURN",
        function()
            print("TURN button pressed")
            -- TODO: Advance game turn
        end,
        "src/gfx/gui/icon_turn.png"
    )
    self.turnButton:setColors({0.2, 0.8, 0.2, 1}, {0.3, 0.9, 0.3, 1}, {0.4, 1.0, 0.4, 1})

    -- Register tooltip for TURN button
    if self.sceneManager and self.sceneManager.registerTooltip then
        self.sceneManager:registerTooltip(self.turnButton, "Advance to next game turn")
    end

    -- MENU button - returns to main menu (red theme)
    self.menuButton = GameButton:new(
        menuButtonX, 0,
        2 * GRID_SIZE, 2 * GRID_SIZE,
        "MENU",
        function()
            print("MENU button pressed")
            -- TODO: Show main menu
        end,
        "src/gfx/gui/icon_menu.png"
    )
    self.menuButton:setColors({0.8, 0.2, 0.2, 1}, {0.9, 0.3, 0.3, 1}, {1.0, 0.4, 0.4, 1})

    -- Register tooltip for MENU button
    if self.sceneManager and self.sceneManager.registerTooltip then
        self.sceneManager:registerTooltip(self.menuButton, "Return to main menu")
    end

    -- Panel styling
    self.backgroundColor = {0.1, 0.1, 0.15, 1}
    self.borderColor = {0.3, 0.3, 0.3, 1}

    -- State flags
    self.enabled = true
    self.visible = true
end

--- Sets the selected screen and updates button visual states
--- @param index number The screen index to select (1-10)
function TopPanel:setSelectedScreen(index)
    -- Update radio button selection
    self.selectedScreenIndex = index

    -- Update button colors to show selection
    for i, button in ipairs(self.screenButtons) do
        if i == index then
            button:setColors({0.2, 0.6, 0.8, 1}, {0.3, 0.7, 0.9, 1}, {0.4, 0.8, 1.0, 1})
        else
            button:setColors({0.3, 0.3, 0.3, 1}, {0.5, 0.5, 0.5, 1}, {0.7, 0.7, 0.7, 1})
        end
    end
end

--- Updates the panel and all its child widgets
--- @param dt number Delta time since last update
function TopPanel:update(dt)
    if not self.enabled or not self.visible then return end

    -- Update all buttons
    for _, button in ipairs(self.screenButtons) do
        button:update(dt)
    end

    -- Update combo box
    self.baseSelector:update(dt)

    -- Update action buttons
    self.turnButton:update(dt)
    self.menuButton:update(dt)
end

--- Draws the panel and all its child widgets
function TopPanel:draw()
    if not self.visible then return end

    -- Draw panel background
    love.graphics.setColor(self.backgroundColor)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

    -- Draw panel border
    love.graphics.setColor(self.borderColor)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)

    -- Draw all screen buttons
    for _, button in ipairs(self.screenButtons) do
        button:draw()
    end

    -- Draw combo box
    self.baseSelector:draw()

    -- Draw money/date label
    love.graphics.setColor(1, 1, 0, 1)  -- Yellow text
    love.graphics.setFont(self.labelFont)
    local labelX = 20 * 20 + 8 * 20 + 20 + 10  -- After combo box + spacing
    local labelY = self.y + (self.height - self.labelFont:getHeight()) / 2
    love.graphics.print(self.moneyLabel .. " | " .. self.dateLabel, labelX, labelY)

    -- Draw action buttons
    self.turnButton:draw()
    self.menuButton:draw()
end

--- Handles mouse press events
--- @param x number Mouse x coordinate
--- @param y number Mouse y coordinate
--- @param button number Mouse button number
--- @return boolean True if the event was handled
function TopPanel:mousepressed(x, y, button)
    if not self.enabled or not self.visible or button ~= 1 then return false end

    -- Check screen buttons
    for _, btn in ipairs(self.screenButtons) do
        if btn:mousepressed(x, y, button) then
            return true
        end
    end

    -- Check combo box
    if self.baseSelector:mousepressed(x, y, button) then
        return true
    end

    -- Check action buttons
    if self.turnButton:mousepressed(x, y, button) then
        return true
    end
    if self.menuButton:mousepressed(x, y, button) then
        return true
    end

    return false
end

--- Handles mouse release events
--- @param x number Mouse x coordinate
--- @param y number Mouse y coordinate
--- @param button number Mouse button number
--- @return boolean True if the event was handled
function TopPanel:mousereleased(x, y, button)
    if not self.enabled or not self.visible or button ~= 1 then return false end

    -- Check screen buttons
    for _, btn in ipairs(self.screenButtons) do
        if btn:mousereleased(x, y, button) then
            return true
        end
    end

    -- Check combo box
    if self.baseSelector:mousereleased(x, y, button) then
        return true
    end

    -- Check action buttons
    if self.turnButton:mousereleased(x, y, button) then
        return true
    end
    if self.menuButton:mousereleased(x, y, button) then
        return true
    end

    return false
end

--- Handles mouse movement events
--- @param x number Mouse x coordinate
--- @param y number Mouse y coordinate
--- @param dx number Mouse delta x
--- @param dy number Mouse delta y
--- @return boolean True if the event was handled
function TopPanel:mousemoved(x, y, dx, dy)
    if not self.enabled or not self.visible then return false end

    -- Check combo box (for dropdown interaction)
    if self.baseSelector:mousemoved(x, y, dx, dy) then
        return true
    end

    return false
end

--- Handles mouse wheel events
--- @param x number Mouse wheel x delta
--- @param y number Mouse wheel y delta
--- @return boolean True if the event was handled
function TopPanel:wheelmoved(x, y)
    if not self.enabled or not self.visible then return false end

    -- Check combo box (for scrolling in dropdown)
    if self.baseSelector:wheelmoved(x, y) then
        return true
    end

    return false
end

--- Sets the displayed money amount
--- @param amount number The money amount to display
function TopPanel:setMoney(amount)
    self.moneyLabel = string.format("$%s", self:formatNumber(amount))
end

--- Sets the displayed game date
--- @param year number The year
--- @param month number The month (1-12)
--- @param day number The day
function TopPanel:setDate(year, month, day)
    local monthNames = {"JAN", "FEB", "MAR", "APR", "MAY", "JUN",
                       "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"}
    self.dateLabel = string.format("%d %s %02d", year, monthNames[month], day)
end

--- Formats a number with comma separators
--- @param num number The number to format
--- @return string The formatted number string
function TopPanel:formatNumber(num)
    -- Format number with commas: 1234567 -> 1,234,567
    local formatted = tostring(num)
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

return TopPanel
