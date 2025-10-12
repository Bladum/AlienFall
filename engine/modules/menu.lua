-- Menu State
-- Main menu with options to start game, load, settings, and quit

local StateManager = require("systems.state_manager")
local Widgets = require("widgets.init")

local Menu = {}

function Menu:enter()
    print("[Menu] Entering menu state")
    
    -- Window dimensions
    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()
    
    -- Title
    self.title = "XCOM SIMPLE"
    self.subtitle = "A Tactical Strategy Game"
    
    -- Create buttons (grid-aligned: 12x2 cells for buttons, positioned at grid coordinates)
    local buttonWidth = 12 * 24  -- 12 grid cells = 288 pixels
    local buttonHeight = 2 * 24  -- 2 grid cells = 48 pixels
    local buttonX = 14 * 24      -- Center horizontally: (40 - 12) / 2 * 24 = 14 * 24 = 336
    local startY = 13 * 24       -- Center vertically: 360 - 48 = 312, 312/24 = 13
    local spacing = 3 * 24       -- 3 grid cells = 72 pixels
    
    self.buttons = {}
    
    -- Geoscape button
    table.insert(self.buttons, Widgets.Button.new(
        buttonX,
        startY,
        buttonWidth,
        buttonHeight,
        "GEOSCAPE"
    ))
    self.buttons[#self.buttons].onClick = function()
        StateManager.switch("geoscape")
    end
    
    -- Battlescape button
    table.insert(self.buttons, Widgets.Button.new(
        buttonX,
        startY + spacing,
        buttonWidth,
        buttonHeight,
        "BATTLESCAPE DEMO"
    ))
    self.buttons[#self.buttons].onClick = function()
        StateManager.switch("battlescape")
    end
    
    -- Basescape button
    table.insert(self.buttons, Widgets.Button.new(
        buttonX,
        startY + spacing * 2,
        buttonWidth,
        buttonHeight,
        "BASESCAPE"
    ))
    self.buttons[#self.buttons].onClick = function()
        StateManager.switch("basescape")
    end
    
    -- Tests button
    table.insert(self.buttons, Widgets.Button.new(
        buttonX,
        startY + spacing * 3,
        buttonWidth,
        buttonHeight,
        "TESTS"
    ))
    self.buttons[#self.buttons].onClick = function()
        StateManager.switch("tests_menu")
    end
    
    -- Map Editor button
    table.insert(self.buttons, Widgets.Button.new(
        buttonX,
        startY + spacing * 4,
        buttonWidth,
        buttonHeight,
        "MAP EDITOR"
    ))
    self.buttons[#self.buttons].onClick = function()
        StateManager.switch("map_editor")
    end
    
    -- Quit button
    table.insert(self.buttons, Widgets.Button.new(
        buttonX,
        startY + spacing * 5,
        buttonWidth,
        buttonHeight,
        "QUIT"
    ))
    self.buttons[#self.buttons].onClick = function()
        love.event.quit()
    end
    
    -- Version label (positioned at bottom-right, grid-aligned)
    self.versionLabel = Widgets.Label.new(
        36 * 24,  -- 36 grid cells = 864 pixels (leave some margin)
        28 * 24,  -- 28 grid cells = 672 pixels
        4 * 24,   -- 4 grid cells = 96 pixels width
        1 * 24,   -- 1 grid cell = 24 pixels height
        "v0.1.0"
    )
    self.versionLabel:setAlign("right")
    self.versionLabel:setVerticalAlign("bottom")
end

function Menu:exit()
    print("[Menu] Exiting menu state")
end

function Menu:update(dt)
    -- Update all buttons
    for _, button in ipairs(self.buttons) do
        button:update(dt)
    end
    
    -- Update version label
    self.versionLabel:update(dt)
end

function Menu:draw()
    -- Clear background
    love.graphics.clear(0.05, 0.05, 0.1)
    
    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()
    
    -- Draw title
    love.graphics.setColor(0.2, 0.6, 0.9)
    local titleFont = love.graphics.newFont(48)
    love.graphics.setFont(titleFont)
    local titleWidth = titleFont:getWidth(self.title)
    love.graphics.print(self.title, (windowWidth - titleWidth) / 2, 100)
    
    -- Draw subtitle
    love.graphics.setColor(0.7, 0.7, 0.8)
    local subtitleFont = love.graphics.newFont(20)
    love.graphics.setFont(subtitleFont)
    local subtitleWidth = subtitleFont:getWidth(self.subtitle)
    love.graphics.print(self.subtitle, (windowWidth - subtitleWidth) / 2, 160)
    
    -- Reset to default font for buttons
    love.graphics.setFont(love.graphics.newFont(18))
    
    -- Draw all buttons
    for _, button in ipairs(self.buttons) do
        button:draw()
    end
    
    -- Draw version label
    self.versionLabel:draw()
    
    -- Draw instructions
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.setFont(love.graphics.newFont(14))
    love.graphics.print("Use mouse to click buttons | ESC to return to menu", 10, windowHeight - 30)
end

function Menu:keypressed(key, scancode, isrepeat)
    if key == "b" then
        print("[Menu] Switching to battlescape via keypress")
        StateManager.switch("battlescape")
    elseif key == "g" then
        print("[Menu] Switching to geoscape via keypress")
        StateManager.switch("geoscape")
    elseif key == "s" then
        print("[Menu] Switching to basescape via keypress")
        StateManager.switch("basescape")
    elseif key == "escape" then
        love.event.quit()
    end
end

function Menu:mousepressed(x, y, button, istouch, presses)
    -- Forward to all buttons
    for _, btn in ipairs(self.buttons) do
        if btn:mousepressed(x, y, button) then
            return true
        end
    end
    return false
end

function Menu:mousereleased(x, y, button, istouch, presses)
    -- Forward to all buttons
    for _, btn in ipairs(self.buttons) do
        if btn:mousereleased(x, y, button) then
            return true
        end
    end
    return false
end

return Menu
