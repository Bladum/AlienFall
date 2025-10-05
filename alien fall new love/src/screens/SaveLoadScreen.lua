--- Save/Load Screen
-- Allows players to save and load game states
--
-- @classmod screens.SaveLoadScreen

-- GROK: SaveLoadScreen provides save game management with grid-aligned UI
-- GROK: Grid-aligned UI at 800x600 resolution using 20px grid system
-- GROK: Key methods: draw(), update(), save(), load(), deleteSave()
-- GROK: Integrates with save system, state serialization, and file I/O

local class = require 'lib.Middleclass'
local Button = require 'widgets.Button'
local Panel = require 'widgets.Panel'

--- SaveLoadScreen class
-- @type SaveLoadScreen
local SaveLoadScreen = class('SaveLoadScreen')

-- Constants
local GRID_SIZE = 20
local SCREEN_WIDTH = 800
local SCREEN_HEIGHT = 600

--- Create a new SaveLoadScreen
-- @param registry Service registry
-- @param mode Mode: 'save' or 'load'
-- @return SaveLoadScreen instance
function SaveLoadScreen:initialize(registry, mode)
    self.registry = registry
    self.logger = registry and registry:logger() or nil
    self.mode = mode or 'save' -- 'save' or 'load'
    
    -- UI state
    self.selectedSlot = 1
    self.saves = {}
    self.scrollOffset = 0
    self.inputActive = false
    self.inputText = ""
    
    -- Create UI widgets
    self:_createWidgets()
end

--- Create UI widgets
function SaveLoadScreen:_createWidgets()
    self.widgets = {}
    
    -- Title
    local titleText = self.mode == 'save' and "SAVE GAME" or "LOAD GAME"
    self.widgets.titlePanel = Panel:new(
        0, 0,
        SCREEN_WIDTH,
        2 * GRID_SIZE,
        {title = titleText, bordered = true}
    )
    
    -- Save slot list panel
    self.widgets.listPanel = Panel:new(
        1 * GRID_SIZE, 3 * GRID_SIZE,
        38 * GRID_SIZE, 22 * GRID_SIZE,
        {title = "SAVE SLOTS", bordered = true}
    )
    
    -- Action buttons
    local btnY = 26 * GRID_SIZE
    
    self.widgets.btnBack = Button:new(
        1 * GRID_SIZE, btnY,
        8 * GRID_SIZE, 2 * GRID_SIZE,
        "BACK",
        function() self:goBack() end
    )
    
    if self.mode == 'save' then
        self.widgets.btnSave = Button:new(
            12 * GRID_SIZE, btnY,
            10 * GRID_SIZE, 2 * GRID_SIZE,
            "SAVE GAME",
            function() self:saveGame() end
        )
        
        self.widgets.btnQuickSave = Button:new(
            23 * GRID_SIZE, btnY,
            10 * GRID_SIZE, 2 * GRID_SIZE,
            "QUICK SAVE",
            function() self:quickSave() end
        )
    else
        self.widgets.btnLoad = Button:new(
            12 * GRID_SIZE, btnY,
            10 * GRID_SIZE, 2 * GRID_SIZE,
            "LOAD GAME",
            function() self:loadGame() end
        )
        
        self.widgets.btnDelete = Button:new(
            23 * GRID_SIZE, btnY,
            10 * GRID_SIZE, 2 * GRID_SIZE,
            "DELETE",
            function() self:deleteSave() end
        )
    end
end

--- Enter the screen
function SaveLoadScreen:enter()
    self:_loadSaveList()
    self.selectedSlot = 1
    self.scrollOffset = 0
end

--- Load list of save files
function SaveLoadScreen:_loadSaveList()
    -- Get save directory
    local saveDir = love.filesystem.getSaveDirectory()
    local savePath = "saves"
    
    -- Ensure save directory exists
    love.filesystem.createDirectory(savePath)
    
    -- Get all save files
    local files = love.filesystem.getDirectoryItems(savePath)
    
    self.saves = {}
    for _, filename in ipairs(files) do
        if filename:match("%.sav$") then
            local fullPath = savePath .. "/" .. filename
            local info = love.filesystem.getInfo(fullPath)
            
            if info then
                -- Load save metadata
                local saveData = self:_loadSaveMetadata(fullPath)
                
                table.insert(self.saves, {
                    filename = filename,
                    path = fullPath,
                    name = saveData.name or filename:gsub("%.sav$", ""),
                    date = os.date("%Y-%m-%d %H:%M", info.modtime),
                    timestamp = info.modtime,
                    day = saveData.day or 0,
                    credits = saveData.credits or 0,
                    bases = saveData.bases or 0
                })
            end
        end
    end
    
    -- Sort by timestamp (newest first)
    table.sort(self.saves, function(a, b)
        return a.timestamp > b.timestamp
    end)
    
    -- Add empty slots for new saves (in save mode)
    if self.mode == 'save' then
        for i = #self.saves + 1, 10 do
            table.insert(self.saves, {
                filename = string.format("save_%02d.sav", i),
                path = savePath .. "/" .. string.format("save_%02d.sav", i),
                name = "--- Empty Slot ---",
                empty = true
            })
        end
    end
end

--- Load save metadata without loading full game state
-- @param filepath Path to save file
-- @return table Metadata
function SaveLoadScreen:_loadSaveMetadata(filepath)
    local contents = love.filesystem.read(filepath)
    if not contents then return {} end
    
    -- Try to parse save file header
    -- Expecting JSON format with metadata at start
    local success, data = pcall(function()
        return require('lib.json'):decode(contents)
    end)
    
    if success and data and data.metadata then
        return data.metadata
    end
    
    return {}
end

--- Go back to previous screen
function SaveLoadScreen:goBack()
    local screenManager = self.registry and self.registry:resolve('screen_manager')
    if screenManager then
        screenManager:popScreen()
    end
end

--- Save current game to selected slot
function SaveLoadScreen:saveGame()
    if not self.saves[self.selectedSlot] then return end
    
    local slot = self.saves[self.selectedSlot]
    
    -- Get save name
    local saveName = slot.empty and ("Save " .. self.selectedSlot) or slot.name
    
    -- Perform save
    local saveSystem = self.registry and self.registry:resolve('save_system')
    if saveSystem and saveSystem.saveGame then
        local success, err = saveSystem:saveGame(slot.path, saveName)
        if success then
            if self.logger then
                self.logger:info("Game saved to " .. slot.path)
            end
            self:_loadSaveList() -- Refresh list
        else
            if self.logger then
                self.logger:error("Save failed: " .. tostring(err))
            end
        end
    else
        -- Fallback: manual save
        self:_performManualSave(slot.path, saveName)
    end
end

--- Perform manual save (fallback)
-- @param filepath Path to save file
-- @param saveName Name of save
function SaveLoadScreen:_performManualSave(filepath, saveName)
    -- Gather game state
    local timeService = self.registry and self.registry:getService('timeService')
    local financeService = self.registry and self.registry:getService('financeService')
    
    local saveData = {
        metadata = {
            name = saveName,
            day = timeService and timeService:getCurrentTime().day or 0,
            credits = financeService and financeService:getBalance() or 0,
            bases = 1, -- TODO: Get actual base count
            version = "0.1.0"
        },
        gameState = {
            -- TODO: Serialize full game state
        }
    }
    
    -- Serialize to JSON
    local json = require('lib.json')
    local serialized = json:encode(saveData)
    
    -- Write to file
    local success, err = love.filesystem.write(filepath, serialized)
    if success then
        if self.logger then
            self.logger:info("Manual save succeeded")
        end
        self:_loadSaveList()
    else
        if self.logger then
            self.logger:error("Manual save failed: " .. tostring(err))
        end
    end
end

--- Quick save to auto-save slot
function SaveLoadScreen:quickSave()
    local autoSavePath = "saves/autosave.sav"
    
    local saveSystem = self.registry and self.registry:resolve('save_system')
    if saveSystem and saveSystem.saveGame then
        saveSystem:saveGame(autoSavePath, "Auto Save")
    else
        self:_performManualSave(autoSavePath, "Auto Save")
    end
    
    if self.logger then
        self.logger:info("Quick save completed")
    end
end

--- Load game from selected slot
function SaveLoadScreen:loadGame()
    if not self.saves[self.selectedSlot] then return end
    
    local slot = self.saves[self.selectedSlot]
    if slot.empty then return end
    
    local saveSystem = self.registry and self.registry:resolve('save_system')
    if saveSystem and saveSystem.loadGame then
        local success, err = saveSystem:loadGame(slot.path)
        if success then
            if self.logger then
                self.logger:info("Game loaded from " .. slot.path)
            end
            -- Return to main game
            self:goBack()
        else
            if self.logger then
                self.logger:error("Load failed: " .. tostring(err))
            end
        end
    end
end

--- Delete selected save
function SaveLoadScreen:deleteSave()
    if not self.saves[self.selectedSlot] then return end
    
    local slot = self.saves[self.selectedSlot]
    if slot.empty then return end
    
    -- Confirm deletion (TODO: use dialog widget)
    local success = love.filesystem.remove(slot.path)
    if success then
        if self.logger then
            self.logger:info("Save deleted: " .. slot.path)
        end
        self:_loadSaveList()
        if self.selectedSlot > #self.saves then
            self.selectedSlot = math.max(1, #self.saves)
        end
    end
end

--- Update screen
-- @param dt Delta time
function SaveLoadScreen:update(dt)
    for _, widget in pairs(self.widgets) do
        if widget.update then
            widget:update(dt)
        end
    end
end

--- Draw screen
function SaveLoadScreen:draw()
    -- Clear background
    love.graphics.setColor(0.05, 0.05, 0.1)
    love.graphics.rectangle('fill', 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
    
    -- Draw panels
    self.widgets.titlePanel:draw()
    self.widgets.listPanel:draw()
    
    -- Draw save slots
    self:_drawSaveSlots()
    
    -- Draw buttons
    self.widgets.btnBack:draw()
    if self.mode == 'save' then
        self.widgets.btnSave:draw()
        self.widgets.btnQuickSave:draw()
    else
        self.widgets.btnLoad:draw()
        self.widgets.btnDelete:draw()
    end
end

--- Draw save slot list
function SaveLoadScreen:_drawSaveSlots()
    local listX = 2 * GRID_SIZE
    local listY = 5 * GRID_SIZE
    local listWidth = 36 * GRID_SIZE
    local listHeight = 19 * GRID_SIZE
    local rowHeight = 3 * GRID_SIZE
    
    love.graphics.setScissor(listX, listY, listWidth, listHeight)
    
    local maxVisible = math.floor(listHeight / rowHeight)
    local startIndex = self.scrollOffset + 1
    local endIndex = math.min(startIndex + maxVisible - 1, #self.saves)
    
    for i = startIndex, endIndex do
        local save = self.saves[i]
        local yPos = listY + (i - startIndex) * rowHeight
        
        -- Highlight selected
        if i == self.selectedSlot then
            love.graphics.setColor(0.2, 0.3, 0.5)
            love.graphics.rectangle('fill', listX, yPos, listWidth, rowHeight)
        end
        
        -- Draw save info
        if save.empty then
            love.graphics.setColor(0.5, 0.5, 0.5)
            love.graphics.print(save.name, listX + 10, yPos + GRID_SIZE)
        else
            love.graphics.setColor(1, 1, 1)
            love.graphics.print(save.name, listX + 10, yPos + 8)
            love.graphics.setColor(0.7, 0.7, 0.7)
            love.graphics.print(save.date or "Unknown", listX + 10, yPos + 28)
            love.graphics.print(string.format("Day %d | $%d", save.day or 0, save.credits or 0), listX + 240, yPos + 28)
        end
        
        -- Separator
        love.graphics.setColor(0.3, 0.3, 0.3)
        love.graphics.line(listX, yPos + rowHeight, listX + listWidth, yPos + rowHeight)
    end
    
    love.graphics.setScissor()
end

--- Handle mouse press
-- @param x Mouse X
-- @param y Mouse Y
-- @param button Mouse button
function SaveLoadScreen:mousepressed(x, y, button)
    if button ~= 1 then return end
    
    -- Check widgets
    for _, widget in pairs(self.widgets) do
        if widget.mousepressed and widget:mousepressed(x, y, button) then
            return
        end
    end
    
    -- Check save slot clicks
    local listX = 2 * GRID_SIZE
    local listY = 5 * GRID_SIZE
    local listWidth = 36 * GRID_SIZE
    local listHeight = 19 * GRID_SIZE
    local rowHeight = 3 * GRID_SIZE
    
    if x >= listX and x < listX + listWidth and y >= listY and y < listY + listHeight then
        local clickedRow = math.floor((y - listY) / rowHeight)
        local slotIndex = self.scrollOffset + clickedRow + 1
        
        if slotIndex <= #self.saves then
            self.selectedSlot = slotIndex
        end
    end
end

--- Handle key press
-- @param key Key name
function SaveLoadScreen:keypressed(key)
    if key == 'escape' then
        self:goBack()
    elseif key == 'up' then
        if self.selectedSlot > 1 then
            self.selectedSlot = self.selectedSlot - 1
            self:_ensureVisible(self.selectedSlot)
        end
    elseif key == 'down' then
        if self.selectedSlot < #self.saves then
            self.selectedSlot = self.selectedSlot + 1
            self:_ensureVisible(self.selectedSlot)
        end
    elseif key == 'return' then
        if self.mode == 'save' then
            self:saveGame()
        else
            self:loadGame()
        end
    elseif key == 'f5' and self.mode == 'save' then
        self:quickSave()
    elseif key == 'delete' and self.mode == 'load' then
        self:deleteSave()
    end
end

--- Ensure selected slot is visible
-- @param index Slot index
function SaveLoadScreen:_ensureVisible(index)
    local listHeight = 19 * GRID_SIZE
    local rowHeight = 3 * GRID_SIZE
    local maxVisible = math.floor(listHeight / rowHeight)
    
    if index < self.scrollOffset + 1 then
        self.scrollOffset = index - 1
    elseif index > self.scrollOffset + maxVisible then
        self.scrollOffset = index - maxVisible
    end
    
    self.scrollOffset = math.max(0, math.min(self.scrollOffset, #self.saves - maxVisible))
end

--- Handle mouse wheel
-- @param x Wheel X
-- @param y Wheel Y
function SaveLoadScreen:wheelmoved(x, y)
    local listHeight = 19 * GRID_SIZE
    local rowHeight = 3 * GRID_SIZE
    local maxVisible = math.floor(listHeight / rowHeight)
    local maxScroll = math.max(0, #self.saves - maxVisible)
    
    self.scrollOffset = self.scrollOffset - y
    self.scrollOffset = math.max(0, math.min(self.scrollOffset, maxScroll))
end

return SaveLoadScreen
