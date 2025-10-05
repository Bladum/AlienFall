local BaseState = require "screens.base_state"
local Button = require "widgets.Button"
local LoadState = {}
LoadState.__index = LoadState
setmetatable(LoadState, { __index = BaseState })

local GRID_SIZE = 20
local GRID_COLS = 40
local GRID_ROWS = 30

function LoadState.new(registry)
    local self = BaseState.new({
        name = "load",
        registry = registry,
        eventBus = registry and registry:eventBus(),
        logger = registry and registry:logger()
    })
    setmetatable(self, LoadState)

    self.saveService = registry and registry:resolve("save") or nil
    self.slots = {}
    self.titleFont = love.graphics.newFont(16)
    self.labelFont = love.graphics.newFont(16)
    
    -- Save slot buttons
    self.slotButtons = {}
    
    -- Back button
    self.backButton = Button:new({
        id = "back",
        label = "Back",
        onClick = function()
            self.stack:pop({ cancelled = true })
        end,
        width = 6 * GRID_SIZE,
        height = 2 * GRID_SIZE
    })
    self.backButton:setPosition(20, 600 - 20 - 2 * GRID_SIZE)
    
    return self
end

function LoadState:enter(payload)
    BaseState.enter(self, payload)
    local saveService = self.saveService
    if saveService and saveService.listSlots then
        self.slots = saveService:listSlots()
    else
        self.slots = { "No save service" }
    end
    
    -- Create buttons for each slot
    self.slotButtons = {}
    local startY = 8 * GRID_SIZE
    for index, slot in ipairs(self.slots) do
        local button = Button:new({
            id = "slot_" .. index,
            label = string.format("Slot %d: %s", index, slot),
            onClick = function()
                self:_loadSlot(index)
            end,
            width = 24 * GRID_SIZE,
            height = 2 * GRID_SIZE
        })
        button:setPosition(8 * GRID_SIZE, startY + (index - 1) * 3 * GRID_SIZE)
        self.slotButtons[index] = button
    end
end

function LoadState:_loadSlot(slotIndex)
    local slot = self.slots[slotIndex]
    if not slot then return end
    
    local data, err
    local saveService = self.saveService
    if saveService and saveService.load then
        data, err = saveService:load(slot)
    end
    if data then
        if self.eventBus then
            self.eventBus:publish("menu:load_campaign", { slot = slot })
        end
        self.stack:replace("geoscape", data)
    else
        if self.logger then
            self.logger:warn("Failed to load save: " .. tostring(err))
        end
    end
end

function LoadState:update(dt)
    for _, button in ipairs(self.slotButtons) do
        button:update(dt)
    end
    self.backButton:update(dt)
end

function LoadState:draw()
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
    love.graphics.printf("LOAD CAMPAIGN", 0, 2 * GRID_SIZE, GRID_COLS * GRID_SIZE, "center")
    
    -- Draw save slot buttons
    for _, button in ipairs(self.slotButtons) do
        button:draw(button.hovered)
    end
    
    -- Draw back button
    self.backButton:draw(self.backButton.hovered)
end

function LoadState:mousepressed(x, y, button)
    if button ~= 1 then return false end
    
    for _, btn in ipairs(self.slotButtons) do
        if btn:mousepressed(x, y, button) then return true end
    end
    if self.backButton:mousepressed(x, y, button) then return true end
    
    return false
end

function LoadState:mousereleased(x, y, button)
    for _, btn in ipairs(self.slotButtons) do
        btn:mousereleased(x, y, button)
    end
    self.backButton:mousereleased(x, y, button)
end

return LoadState
