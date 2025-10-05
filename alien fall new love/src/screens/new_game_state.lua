local BaseState = require "screens.base_state"
local Button = require "widgets.Button"
local Combobox = require "widgets.ComboBox"
local MultiSelectListBox = require "widgets.MultiSelectListBox"

local NewGameState = {}
NewGameState.__index = NewGameState
setmetatable(NewGameState, { __index = BaseState })

local GRID_SIZE = 20
local GRID_COLS = 40
local GRID_ROWS = 30

local DIFFICULTY_LEVELS = {
    { id = "easy", label = "EASY", description = "Relaxed gameplay, generous resources" },
    { id = "medium", label = "MEDIUM", description = "Balanced challenge and fun" },
    { id = "hard", label = "HARD", description = "Tactical challenge, limited resources" }
}

function NewGameState.new(registry)
    local self = BaseState.new({
        name = "new_game",
        registry = registry,
        eventBus = registry and registry:eventBus(),
        logger = registry and registry:logger()
    })
    setmetatable(self, NewGameState)

    self.titleFont = love.graphics.newFont(16)
    self.labelFont = love.graphics.newFont(16)
    self.descFont = love.graphics.newFont(16)
    
    self.selectedDifficulty = 2  -- Default to medium
    self.selectedMods = {"core"}  -- Default to core mod
    
    -- Get available mods
    local modLoader = registry and registry:resolve("mod_loader")
    local availableMods = {}
    if modLoader then
        local discoveredMods = modLoader:discover()
        for _, mod in ipairs(discoveredMods) do
            table.insert(availableMods, {
                id = mod.id,
                name = mod.name or mod.id,
                description = mod.description or ""
            })
        end
    else
        -- Fallback if no mod loader
        availableMods = {
            { id = "core", name = "AlienFall Core", description = "Built-in core ruleset" }
        }
    end
    
    -- Difficulty combo box
    local difficultyOptions = {}
    for _, diff in ipairs(DIFFICULTY_LEVELS) do
        table.insert(difficultyOptions, diff.label)
    end
    self.difficultyCombobox = Combobox:new({
        id = "difficulty",
        label = "Difficulty",
        options = difficultyOptions,
        selectedIndex = self.selectedDifficulty,
        onChange = function(index, value)
            self.selectedDifficulty = index
        end,
        width = 12 * GRID_SIZE,
        height = 2 * GRID_SIZE
    })
    self.difficultyCombobox:setPosition(14 * GRID_SIZE, 8 * GRID_SIZE)
    
    -- Multi-select mod list
    self.modListBox = MultiSelectListBox:new({
        availableItems = availableMods,
        selectedItems = {{ id = "core", name = "AlienFall Core" }}, -- Pre-select core
        availableLabel = "Available Mods:",
        selectedLabel = "Selected Mods (in order):",
        onSelectionChanged = function(selectedMods)
            self.selectedMods = {}
            for _, mod in ipairs(selectedMods) do
                table.insert(self.selectedMods, mod.id)
            end
        end,
        width = 16 * GRID_SIZE,
        height = 12 * GRID_SIZE
    })
    self.modListBox:setPosition(14 * GRID_SIZE, 12 * GRID_SIZE)
    
    -- Action buttons
    self.actionButtons = {}
    local actionY = 24 * GRID_SIZE
    
    local startButton = Button:new({
        id = "start_game",
        label = "Start Game",
        onClick = function()
            self:_startGame()
        end,
        width = 6 * GRID_SIZE,
        height = 2 * GRID_SIZE
    })
    startButton:setPosition(800 - 20 - 6 * GRID_SIZE, 600 - 20 - 2 * GRID_SIZE)
    self.actionButtons[1] = startButton
    
    local backButton = Button:new({
        id = "back",
        label = "Back",
        onClick = function()
            self.stack:pop({ cancelled = true })
        end,
        width = 6 * GRID_SIZE,
        height = 2 * GRID_SIZE
    })
    backButton:setPosition(20, 600 - 20 - 2 * GRID_SIZE)
    self.actionButtons[2] = backButton

    return self
end

function NewGameState:_startGame()
    local difficulty = DIFFICULTY_LEVELS[self.selectedDifficulty]
    local campaignSeed = os.time()

    -- Initialize AI Director with campaign seed
    self.registry:initializeAIDirector(campaignSeed)

    self.stack:replace("geoscape", {
        seed = campaignSeed,
        difficulty = difficulty.id,
        mods = self.selectedMods
    })
    if self.eventBus then
        self.eventBus:publish("menu:new_campaign", {
            difficulty = difficulty.id,
            mods = self.selectedMods,
            seed = campaignSeed
        })
    end
end

function NewGameState:update(dt)
    self.difficultyCombobox:update(dt)
    self.modListBox:update(dt)
    for _, button in ipairs(self.actionButtons) do
        button:update(dt)
    end
end

function NewGameState:draw()
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
    
    -- Title
    love.graphics.setColor(0, 0.6, 0.9, 1)
    love.graphics.setFont(self.titleFont)
    love.graphics.printf("NEW GAME", 0, 2 * GRID_SIZE, GRID_COLS * GRID_SIZE, "center")
    
    -- Difficulty section
    love.graphics.setFont(self.labelFont)
    love.graphics.printf("Select Difficulty:", 0, 5 * GRID_SIZE, GRID_COLS * GRID_SIZE, "center")
    
    self.difficultyCombobox:draw(false)
    
    -- Draw description for selected difficulty
    love.graphics.setColor(0.8, 0.9, 1, 1)
    love.graphics.setFont(self.descFont)
    love.graphics.printf(DIFFICULTY_LEVELS[self.selectedDifficulty].description, 0, 11 * GRID_SIZE, GRID_COLS * GRID_SIZE, "center")
    
    -- Mod section
    love.graphics.setColor(0, 0.6, 0.9, 1)
    love.graphics.setFont(self.labelFont)
    love.graphics.printf("Select Mods:", 0, 13 * GRID_SIZE, GRID_COLS * GRID_SIZE, "center")
    
    self.modListBox:draw()
    
    -- Action buttons
    for _, button in ipairs(self.actionButtons) do
        button:draw(button.hovered)
    end
end

function NewGameState:mousepressed(x, y, button)
    if button ~= 1 then return false end
    
    if self.difficultyCombobox:mousepressed(x, y, button) then return true end
    if self.modListBox:mousepressed(x, y, button) then return true end
    for _, btn in ipairs(self.actionButtons) do
        if btn:mousepressed(x, y, button) then return true end
    end
    
    return false
end

function NewGameState:mousereleased(x, y, button)
    self.difficultyCombobox:mousereleased(x, y, button)
    self.modListBox:mousereleased(x, y, button)
    for _, btn in ipairs(self.actionButtons) do
        btn:mousereleased(x, y, button)
    end
end

function NewGameState:mousemoved(x, y, dx, dy, istouch)
    self.difficultyCombobox:mousemoved(x, y)
    self.modListBox:mousemoved(x, y, dx, dy, istouch)
    for _, btn in ipairs(self.actionButtons) do
        btn:mousemoved(x, y)
    end
end

return NewGameState
