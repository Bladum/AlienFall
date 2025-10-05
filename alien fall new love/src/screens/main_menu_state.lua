local BaseState = require "screens.base_state"
local Button = require "widgets.Button"

local MainMenuState = {}
MainMenuState.__index = MainMenuState
setmetatable(MainMenuState, { __index = BaseState })

local GRID_SIZE = 20
local GRID_COLS = 40
local GRID_ROWS = 30

local MENU_ENTRIES = {
    { id = "new_game", label = "New Game", target = "new_game" },
    { id = "load_game", label = "Load Game", target = "load" },
    { id = "options", label = "Options", target = "options" },
    { id = "credits", label = "Credits", target = "credits" },
    { id = "test", label = "Test Widgets", target = "test" },
    { id = "exit", label = "Exit", target = "exit" }
}

function MainMenuState.new(registry)
    local self = BaseState.new({
        name = "main_menu",
        registry = registry,
        eventBus = registry and registry:eventBus(),
        logger = registry and registry:logger()
    })
    setmetatable(self, MainMenuState)

    self.titleFont = love.graphics.newFont(48)  -- Larger for game title
    self.menuFont = love.graphics.newFont(16)  -- Same size for all menu text
    self.buttons = {}
    self.focusIndex = 1
    self.buttonWidth = 6 * GRID_SIZE
    self.buttonHeight = 2 * GRID_SIZE
    self.buttonSpacing = 3 * GRID_SIZE

    local centerX = ((GRID_COLS - 6) / 2) * GRID_SIZE
    -- Center buttons vertically: screen height 600, title at 120, buttons should start around 200-250
    local startRow = 12  -- Start lower for better vertical centering
    local buttonYs = {
        startRow * GRID_SIZE,
        (startRow + 3) * GRID_SIZE,
        (startRow + 6) * GRID_SIZE,
        (startRow + 9) * GRID_SIZE,
        (startRow + 12) * GRID_SIZE,
        (startRow + 15) * GRID_SIZE,
        (startRow + 18) * GRID_SIZE
    }

    self.buttonOriginX = centerX

    -- Create main menu buttons
    for i, entry in ipairs(MENU_ENTRIES) do
        local button = Button:new({
            id = entry.id,
            label = entry.label,
            onClick = function()
                self:_activate(entry)
            end,
            width = self.buttonWidth,
            height = self.buttonHeight
        })
        button:setPosition(self.buttonOriginX, buttonYs[i])
        self.buttons[i] = button
    end

    return self
end

function MainMenuState:enter(payload)
    BaseState.enter(self, payload)
    if self.eventBus then
        self.eventBus:publish("menu:entered", { scene = "main_menu" })
    end
end

function MainMenuState:_activate(entry)
    if entry.target == "exit" then
        love.event.quit()
        return
    end

    if entry.target == "new_game" then
        self.stack:push("new_game", {})
    elseif entry.target == "load" then
        self.stack:push("load", {})
    elseif entry.target == "options" then
        self.stack:push("options", {})
    elseif entry.target == "credits" then
        self.stack:push("credits", {})
    elseif entry.target == "test" then
        self.stack:push("test", {})
    end
end

function MainMenuState:update(dt)
    for _, button in ipairs(self.buttons) do
        button:update(dt)
    end
end

function MainMenuState:draw()
    love.graphics.clear(0.07, 0.07, 0.1, 1)
    
    -- Draw subtle grid background
    love.graphics.setColor(0.1, 0.1, 0.15, 0.3)
    for x = 0, GRID_COLS - 1 do
        for y = 0, GRID_ROWS - 1 do
            if (x + y) % 2 == 0 then
                love.graphics.rectangle("fill", x * GRID_SIZE, y * GRID_SIZE, GRID_SIZE, GRID_SIZE)
            end
        end
    end
    
    love.graphics.setColor(0, 0.6, 0.9, 1)
    love.graphics.setFont(self.titleFont)
    local title = "AlienFall"
    love.graphics.printf(title, 0, 6 * GRID_SIZE, GRID_COLS * GRID_SIZE, "center")

    love.graphics.setFont(self.menuFont)
    for index, button in ipairs(self.buttons) do
        local focused = index == self.focusIndex
        button:draw(focused)
    end
end

function MainMenuState:mousepressed(x, y, button)
    if button ~= 1 then
        return false
    end
    for index, widget in ipairs(self.buttons) do
        if widget:mousepressed(x, y, button) then
            self.focusIndex = index
            return true
        end
    end
    return false
end

function MainMenuState:mousereleased(x, y, button)
    -- Buttons trigger on press, not release
end

function MainMenuState:keypressed(key, scancode, isrepeat)
    -- Handle other keys for menu navigation
    if key == "up" then
        self.focusIndex = math.max(1, self.focusIndex - 1)
        return true
    elseif key == "down" then
        self.focusIndex = math.min(#self.buttons, self.focusIndex + 1)
        return true
    elseif key == "return" or key == "kpenter" then
        local entry = MENU_ENTRIES[self.focusIndex]
        if entry then
            self:_activate(entry)
        end
        return true
    elseif key == "escape" then
        love.event.quit()
        return true
    end

    return false
end

return MainMenuState
