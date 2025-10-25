---Load Game Screen
---
---Browse and load saved campaign files. Displays save file metadata including
---campaign name, date, progress (campaign day), threat level, and unit status.
---Allows filtering, sorting, and deleting saves.
---
---Key Exports:
---  - LoadGameScreen:enter(): Initialize save browser
---  - LoadGameScreen:draw(): Render save file list
---  - LoadGameScreen:mousepressed(x, y, button): Handle mouse clicks
---  - LoadGameScreen:keypressed(key): Handle keyboard input
---
---Features:
---  - List view of saved campaigns
---  - Save metadata display (date, day, threat, units)
---  - Filter by status (In Progress, Won, Lost)
---  - Sort by date/day/threat
---  - Delete/Overwrite on right-click
---
---@module scenes.load_game_screen
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source

local StateManager = require("core.state_manager")
local SaveGameManager = require("engine.geoscape.state.save_game_manager")

local LoadGameScreen = {}

--- Initialize load game screen
function LoadGameScreen:enter()
    print("[LoadGameScreen] Entering load game screen")

    -- Save file list
    self.saves = {}
    self:_loadSaveFiles()

    -- Selection and scrolling
    self.selected_index = 1
    self.scroll_offset = 0
    self.visible_count = 8

    -- UI state
    self.buttons = {}
    self:_createButtons()

    -- Context menu
    self.context_menu_visible = false
    self.context_menu_x = 0
    self.context_menu_y = 0
    self.context_menu_target = nil

    -- Filter and sort
    self.filter_status = "ALL"
    self.sort_by = "date"  -- "date", "day", "threat"
end

--- Load save files from disk
function LoadGameScreen:_loadSaveFiles()
    print("[LoadGameScreen] Loading save files...")

    local save_dir = love.filesystem.getSaveDirectory()
    if not save_dir then
        print("[LoadGameScreen] No save directory")
        return
    end

    -- Get save files
    local files = love.filesystem.getDirectoryItems("saves") or {}

    for _, file in ipairs(files) do
        if file:match("%.json$") then
            local ok, data = pcall(function()
                local content = love.filesystem.read("saves/" .. file)
                return content and require("dkjson").decode(content) or nil
            end)

            if ok and data then
                table.insert(self.saves, {
                    filename = file,
                    name = data.campaign_name or file:gsub("%.json$", ""),
                    date = data.save_date or os.date("%Y-%m-%d %H:%M"),
                    campaign_day = data.campaign_day or 0,
                    threat_level = data.threat_level or 1,
                    units_alive = data.units_alive or 0,
                    total_units = data.total_units or 12,
                    status = data.status or "IN_PROGRESS",
                })
            end
        end
    end

    -- Sort by date (newest first)
    table.sort(self.saves, function(a, b)
        return a.date > b.date
    end)

    print("[LoadGameScreen] Loaded " .. #self.saves .. " save files")
end

--- Create UI buttons
function LoadGameScreen:_createButtons()
    self.buttons = {}

    local button_width = 8 * 24
    local button_height = 2 * 24
    local button_x = 16 * 24
    local start_y = 26 * 24
    local spacing = 3 * 24

    -- Load button
    table.insert(self.buttons, {
        x = button_x,
        y = start_y,
        width = button_width / 2 - 12,
        height = button_height,
        label = "LOAD",
        onClick = function() self:_loadSelectedSave() end
    })

    -- Back button
    table.insert(self.buttons, {
        x = button_x + button_width / 2 + 12,
        y = start_y,
        width = button_width / 2 - 12,
        height = button_height,
        label = "BACK",
        onClick = function() StateManager.switch("menu") end
    })
end

--- Load selected save file
function LoadGameScreen:_loadSelectedSave()
    local save = self.saves[self.selected_index + self.scroll_offset]

    if not save then
        print("[LoadGameScreen] No save selected")
        return
    end

    print("[LoadGameScreen] Loading save: " .. save.filename)

    local ok, err = pcall(function()
        local content = love.filesystem.read("saves/" .. save.filename)
        local data = require("dkjson").decode(content)

        if data then
            -- Store campaign data in state manager
            if StateManager.setGlobalData then
                StateManager:setGlobalData("campaign_data", data)
            end

            -- Transition to geoscape
            StateManager.switch("geoscape")
        end
    end)

    if not ok then
        print("[LoadGameScreen] Failed to load save: " .. tostring(err))
    end
end

--- Update screen
function LoadGameScreen:update(dt)
    -- No continuous updates
end

--- Draw load game screen
function LoadGameScreen:draw()
    love.graphics.clear(0.05, 0.05, 0.1)

    -- Title
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(love.graphics.getFont())
    love.graphics.printf("LOAD CAMPAIGN", 0, 2 * 24, 40 * 24, "center")

    -- Save count
    love.graphics.setColor(0.7, 0.7, 0.7, 1)
    love.graphics.printf(
        #self.saves .. " save file(s) found",
        0, 4 * 24, 40 * 24, "center"
    )

    -- Draw save list
    self:_drawSaveList()

    -- Draw buttons
    self:_drawButtons()

    -- Draw context menu if visible
    if self.context_menu_visible then
        self:_drawContextMenu()
    end
end

--- Draw save file list
function LoadGameScreen:_drawSaveList()
    love.graphics.setColor(0.15, 0.15, 0.2, 1)
    love.graphics.rectangle("fill", 2 * 24, 6 * 24, 36 * 24, 18 * 24)

    love.graphics.setColor(0.4, 0.4, 0.45, 1)
    love.graphics.rectangle("line", 2 * 24, 6 * 24, 36 * 24, 18 * 24)

    local start_y = 6 * 24 + 12
    local item_height = 2 * 24
    local max_items = self.visible_count

    for i = 1, max_items do
        local save_index = i + self.scroll_offset
        local save = self.saves[save_index]

        if not save then break end

        local is_selected = save_index == self.selected_index
        local y = start_y + (i - 1) * item_height

        -- Highlight selected item
        if is_selected then
            love.graphics.setColor(0, 0.5, 0, 0.3)
            love.graphics.rectangle("fill", 2 * 24, y - 6, 36 * 24, item_height)
        end

        -- Save name and metadata
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf(
            save.name,
            2 * 24 + 12, y, 25 * 24, "left"
        )

        -- Metadata
        love.graphics.setColor(0.7, 0.7, 0.7, 1)
        local metadata = string.format(
            "Day %d | Threat %d | Units %d/%d",
            save.campaign_day,
            save.threat_level,
            save.units_alive,
            save.total_units
        )
        love.graphics.printf(
            metadata,
            28 * 24, y, 9 * 24, "right"
        )

        love.graphics.setColor(0.5, 0.5, 0.5, 1)
        love.graphics.printf(
            save.date,
            2 * 24 + 12, y + 12, 25 * 24, "left"
        )
    end

    -- Draw scrollbar if needed
    if #self.saves > max_items then
        self:_drawScrollbar()
    end
end

--- Draw scrollbar
function LoadGameScreen:_drawScrollbar()
    local scrollbar_x = 38 * 24
    local scrollbar_y = 6 * 24
    local scrollbar_height = 18 * 24
    local scrollbar_width = 12

    love.graphics.setColor(0.3, 0.3, 0.35, 1)
    love.graphics.rectangle("fill", scrollbar_x, scrollbar_y, scrollbar_width, scrollbar_height)

    local total = #self.saves
    local visible = self.visible_count
    local scroll_ratio = self.scroll_offset / math.max(1, total - visible)
    local thumb_height = (visible / total) * scrollbar_height
    local thumb_y = scrollbar_y + scroll_ratio * (scrollbar_height - thumb_height)

    love.graphics.setColor(0.6, 0.6, 0.6, 1)
    love.graphics.rectangle("fill", scrollbar_x, thumb_y, scrollbar_width, thumb_height)
end

--- Draw buttons
function LoadGameScreen:_drawButtons()
    for _, button in ipairs(self.buttons) do
        love.graphics.setColor(0.3, 0.3, 0.35, 1)
        love.graphics.rectangle("fill", button.x, button.y, button.width, button.height)

        love.graphics.setColor(0.6, 0.6, 0.6, 1)
        love.graphics.rectangle("line", button.x, button.y, button.width, button.height)

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf(button.label, button.x, button.y + 6, button.width, "center")
    end
end

--- Draw context menu
function LoadGameScreen:_drawContextMenu()
    local menu_width = 6 * 24
    local menu_height = 2 * 24

    love.graphics.setColor(0.2, 0.2, 0.25, 0.95)
    love.graphics.rectangle("fill", self.context_menu_x, self.context_menu_y, menu_width, menu_height)

    love.graphics.setColor(0.5, 0.5, 0.5, 1)
    love.graphics.rectangle("line", self.context_menu_x, self.context_menu_y, menu_width, menu_height)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf("DELETE", self.context_menu_x, self.context_menu_y + 6, menu_width, "center")
end

--- Handle keyboard input
function LoadGameScreen:keypressed(key, scancode, isrepeat)
    if key == "escape" then
        StateManager.switch("menu")
    elseif key == "up" then
        self.selected_index = math.max(1, self.selected_index - 1)
        if self.selected_index <= self.scroll_offset then
            self.scroll_offset = math.max(0, self.selected_index - 1)
        end
    elseif key == "down" then
        self.selected_index = math.min(#self.saves, self.selected_index + 1)
        if self.selected_index > self.scroll_offset + self.visible_count then
            self.scroll_offset = self.selected_index - self.visible_count
        end
    elseif key == "return" then
        self:_loadSelectedSave()
    elseif key == "delete" then
        self:_deleteSelectedSave()
    end
end

--- Delete selected save
function LoadGameScreen:_deleteSelectedSave()
    local save = self.saves[self.selected_index]

    if not save then return end

    print("[LoadGameScreen] Deleting save: " .. save.filename)

    local ok = pcall(function()
        love.filesystem.remove("saves/" .. save.filename)
    end)

    if ok then
        table.remove(self.saves, self.selected_index)
        self.selected_index = math.min(self.selected_index, #self.saves)
        print("[LoadGameScreen] Save deleted")
    end
end

--- Handle mouse press
function LoadGameScreen:mousepressed(x, y, button, istouch, presses)
    if button == 1 then
        -- Check button clicks
        for _, btn in ipairs(self.buttons) do
            if x >= btn.x and x < btn.x + btn.width and
               y >= btn.y and y < btn.y + btn.height then
                btn:onClick()
            end
        end

        -- Check save list clicks
        local start_y = 6 * 24 + 12
        local item_height = 2 * 24

        for i = 1, self.visible_count do
            local save_index = i + self.scroll_offset
            if save_index > #self.saves then break end

            local y_pos = start_y + (i - 1) * item_height
            if x >= 2 * 24 and x < 38 * 24 and y >= y_pos - 6 and y < y_pos + item_height - 6 then
                self.selected_index = save_index
            end
        end

        -- Hide context menu
        self.context_menu_visible = false

    elseif button == 2 then
        -- Right click for context menu
        local start_y = 6 * 24 + 12
        local item_height = 2 * 24

        for i = 1, self.visible_count do
            local save_index = i + self.scroll_offset
            if save_index > #self.saves then break end

            local y_pos = start_y + (i - 1) * item_height
            if x >= 2 * 24 and x < 38 * 24 and y >= y_pos - 6 and y < y_pos + item_height - 6 then
                self.selected_index = save_index
                self.context_menu_visible = true
                self.context_menu_x = x
                self.context_menu_y = y
                self.context_menu_target = save_index
            end
        end
    end
end

--- Handle scroll wheel
function LoadGameScreen:wheelmoved(x, y)
    if y < 0 then
        -- Scroll down
        self.scroll_offset = math.min(
            #self.saves - self.visible_count,
            self.scroll_offset + 1
        )
    elseif y > 0 then
        -- Scroll up
        self.scroll_offset = math.max(0, self.scroll_offset - 1)
    end
end

return LoadGameScreen

