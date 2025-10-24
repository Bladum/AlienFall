---New Campaign Wizard
---
---Multi-step wizard for creating a new campaign with difficulty and faction selection.
---Guides players through campaign name, difficulty preset, starting faction, and game speed.
---
---Key Exports:
---  - NewCampaignWizard:enter(): Initialize wizard
---  - NewCampaignWizard:draw(): Render current step
---  - NewCampaignWizard:keypressed(key): Handle input
---  - NewCampaignWizard:mousepressed(x, y, button): Handle mouse clicks
---
---Wizard Steps:
---  1. Campaign name input
---  2. Difficulty selection (Easy/Normal/Hard/Ironman)
---  3. Starting faction choice
---  4. Game speed selection
---  5. Confirmation review
---
---@module scenes.new_campaign_wizard
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source

local StateManager = require("core.state_manager")
local Widgets = require("gui.widgets.init")
local CampaignOrchestrator = require("engine.geoscape.campaign_orchestrator")

local NewCampaignWizard = {}

--- Initialize wizard
function NewCampaignWizard:enter()
    print("[NewCampaignWizard] Entering new campaign wizard")

    -- Wizard state
    self.current_step = 1
    self.total_steps = 5
    self.campaign_data = {
        name = "Operation Sunlight",
        difficulty = "NORMAL",
        difficulty_multiplier = 1.0,
        faction = "SECTOID_EMPIRE",
        game_speed = 1.0,
    }

    -- Input field
    self.name_input = "Operation Sunlight"
    self.input_active = true

    -- Difficulty options
    self.difficulties = {
        {name = "EASY", multiplier = 0.5, description = "+50% Resources, 0.5x Enemy Damage"},
        {name = "NORMAL", multiplier = 1.0, description = "Baseline difficulty"},
        {name = "HARD", multiplier = 1.5, description = "-50% Resources, 1.5x Enemy Damage"},
        {name = "IRONMAN", multiplier = 2.0, description = "Hard + Permadeath"},
    }
    self.selected_difficulty = 2 -- NORMAL

    -- Faction options
    self.factions = {
        {id = "SECTOID_EMPIRE", name = "Sectoid Empire", description = "Standard difficulty. Tactical foes."},
        {id = "MUTON_COALITION", name = "Muton Coalition", description = "Aggressive species. Physical strength."},
        {id = "ETHEREAL_COLLECTIVE", name = "Ethereal Collective", description = "Unpredictable. Advanced tech."},
        {id = "HYBRID_INVASION", name = "Hybrid Invasion", description = "Mixed species. Varied tactics."},
    }
    self.selected_faction = 1 -- Sectoid Empire

    -- Speed options
    self.speeds = {
        {speed = 1.0, name = "1x (Normal)"},
        {speed = 2.0, name = "2x (Fast)"},
        {speed = 4.0, name = "4x (Very Fast)"},
    }
    self.selected_speed = 1 -- 1x

    -- Buttons
    self.buttons = {}
    self:_createButtons()
end

--- Create buttons for current step
function NewCampaignWizard:_createButtons()
    self.buttons = {}

    local button_width = 8 * 24
    local button_height = 2 * 24
    local button_x = 16 * 24
    local start_y = 22 * 24
    local spacing = 3 * 24

    -- Back button
    if self.current_step > 1 then
        table.insert(self.buttons, {
            x = button_x,
            y = start_y + spacing * 2,
            width = 4 * 24,
            height = button_height,
            label = "BACK",
            onClick = function() self:previousStep() end
        })
    end

    -- Next/Confirm button
    local next_label = self.current_step == self.total_steps and "CREATE CAMPAIGN" or "NEXT"
    table.insert(self.buttons, {
        x = button_x + (button_width / 2),
        y = start_y + spacing * 2,
        width = 4 * 24,
        height = button_height,
        label = next_label,
        onClick = function() self:nextStep() end
    })

    -- Cancel button
    table.insert(self.buttons, {
        x = button_x,
        y = start_y + spacing * 3,
        width = button_width,
        height = button_height,
        label = "CANCEL",
        onClick = function() self:cancel() end
    })
end

--- Move to next wizard step
function NewCampaignWizard:nextStep()
    if self.current_step < self.total_steps then
        self.current_step = self.current_step + 1
        self:_createButtons()
        print("[NewCampaignWizard] Advanced to step " .. self.current_step)
    elseif self.current_step == self.total_steps then
        -- Create campaign
        self:_createCampaign()
    end
end

--- Move to previous wizard step
function NewCampaignWizard:previousStep()
    if self.current_step > 1 then
        self.current_step = self.current_step - 1
        self:_createButtons()
        print("[NewCampaignWizard] Returned to step " .. self.current_step)
    end
end

--- Cancel wizard and return to menu
function NewCampaignWizard:cancel()
    print("[NewCampaignWizard] Wizard cancelled")
    StateManager.switch("menu")
end

--- Create campaign with current settings
function NewCampaignWizard:_createCampaign()
    print("[NewCampaignWizard] Creating campaign: " .. self.campaign_data.name)

    -- Apply difficulty multiplier
    local difficulty = self.difficulties[self.selected_difficulty]
    self.campaign_data.difficulty = difficulty.name
    self.campaign_data.difficulty_multiplier = difficulty.multiplier

    -- Apply faction
    local faction = self.factions[self.selected_faction]
    self.campaign_data.faction = faction.id

    -- Apply speed
    local speed = self.speeds[self.selected_speed]
    self.campaign_data.game_speed = speed.speed

    print("[NewCampaignWizard] Campaign data: " .. table.concat({
        "name=" .. self.campaign_data.name,
        "difficulty=" .. self.campaign_data.difficulty,
        "faction=" .. self.campaign_data.faction,
        "speed=" .. self.campaign_data.game_speed
    }, ", "))

    -- Initialize campaign orchestrator
    local orchestrator = CampaignOrchestrator.new(self.campaign_data)
    orchestrator:initializeAllSystems()

    -- Store in global state (or pass via StateManager)
    if StateManager.setGlobalData then
        StateManager:setGlobalData("campaign_orchestrator", orchestrator)
    end

    -- Transition to geoscape
    StateManager.switch("geoscape")
end

--- Update wizard
function NewCampaignWizard:update(dt)
    -- No continuous updates needed
end

--- Draw wizard screen
function NewCampaignWizard:draw()
    love.graphics.clear(0.05, 0.05, 0.1)

    -- Title
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(love.graphics.getFont())
    love.graphics.printf("NEW CAMPAIGN", 0, 2 * 24, 40 * 24, "center")

    -- Step indicator
    love.graphics.setColor(0.7, 0.7, 0.7, 1)
    love.graphics.printf(
        "Step " .. self.current_step .. " of " .. self.total_steps,
        0, 4 * 24, 40 * 24, "center"
    )

    love.graphics.setColor(1, 1, 1, 1)

    -- Draw current step
    if self.current_step == 1 then
        self:_drawStepName()
    elseif self.current_step == 2 then
        self:_drawStepDifficulty()
    elseif self.current_step == 3 then
        self:_drawStepFaction()
    elseif self.current_step == 4 then
        self:_drawStepSpeed()
    elseif self.current_step == 5 then
        self:_drawStepConfirmation()
    end

    -- Draw buttons
    self:_drawButtons()
end

--- Draw step 1: Campaign name input
function NewCampaignWizard:_drawStepName()
    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.printf("Enter Campaign Name:", 4 * 24, 7 * 24, 32 * 24, "left")

    -- Input box
    love.graphics.setColor(0.2, 0.2, 0.25, 1)
    love.graphics.rectangle("fill", 4 * 24, 9 * 24, 32 * 24, 2 * 24)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", 4 * 24, 9 * 24, 32 * 24, 2 * 24)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf(self.name_input, 4 * 24 + 12, 9 * 24 + 6, 30 * 24, "left")
end

--- Draw step 2: Difficulty selection
function NewCampaignWizard:_drawStepDifficulty()
    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.printf("Select Difficulty:", 4 * 24, 7 * 24, 32 * 24, "left")

    local start_y = 9 * 24
    for i, diff in ipairs(self.difficulties) do
        local is_selected = i == self.selected_difficulty
        local color = is_selected and {0, 1, 0, 0.8} or {0.5, 0.5, 0.5, 0.8}

        love.graphics.setColor(unpack(color))
        love.graphics.rectangle("line", 4 * 24, start_y + (i - 1) * 2.5 * 24, 32 * 24, 2 * 24)

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf(
            diff.name .. " - " .. diff.description,
            4 * 24 + 12, start_y + (i - 1) * 2.5 * 24 + 6, 30 * 24, "left"
        )
    end
end

--- Draw step 3: Faction selection
function NewCampaignWizard:_drawStepFaction()
    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.printf("Select Starting Faction:", 4 * 24, 7 * 24, 32 * 24, "left")

    local start_y = 9 * 24
    for i, faction in ipairs(self.factions) do
        local is_selected = i == self.selected_faction
        local color = is_selected and {0, 1, 0, 0.8} or {0.5, 0.5, 0.5, 0.8}

        love.graphics.setColor(unpack(color))
        love.graphics.rectangle("line", 4 * 24, start_y + (i - 1) * 2.5 * 24, 32 * 24, 2 * 24)

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf(
            faction.name .. " - " .. faction.description,
            4 * 24 + 12, start_y + (i - 1) * 2.5 * 24 + 6, 30 * 24, "left"
        )
    end
end

--- Draw step 4: Game speed selection
function NewCampaignWizard:_drawStepSpeed()
    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.printf("Select Game Speed:", 4 * 24, 7 * 24, 32 * 24, "left")

    local start_y = 9 * 24
    for i, speed_opt in ipairs(self.speeds) do
        local is_selected = i == self.selected_speed
        local color = is_selected and {0, 1, 0, 0.8} or {0.5, 0.5, 0.5, 0.8}

        love.graphics.setColor(unpack(color))
        love.graphics.rectangle("line", 4 * 24, start_y + (i - 1) * 3 * 24, 32 * 24, 2 * 24)

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf(
            speed_opt.name,
            4 * 24 + 12, start_y + (i - 1) * 3 * 24 + 6, 30 * 24, "left"
        )
    end
end

--- Draw step 5: Confirmation review
function NewCampaignWizard:_drawStepConfirmation()
    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.printf("Review Campaign Settings:", 4 * 24, 7 * 24, 32 * 24, "left")

    local diff = self.difficulties[self.selected_difficulty]
    local faction = self.factions[self.selected_faction]
    local speed = self.speeds[self.selected_speed]

    local text = string.format(
        "Name: %s\nDifficulty: %s\nFaction: %s\nSpeed: %s\n\nClick CREATE CAMPAIGN to start!",
        self.name_input,
        diff.name,
        faction.name,
        speed.name
    )

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf(text, 4 * 24, 9 * 24, 32 * 24, "left")
end

--- Draw buttons
function NewCampaignWizard:_drawButtons()
    for _, button in ipairs(self.buttons) do
        love.graphics.setColor(0.3, 0.3, 0.35, 1)
        love.graphics.rectangle("fill", button.x, button.y, button.width, button.height)

        love.graphics.setColor(0.6, 0.6, 0.6, 1)
        love.graphics.rectangle("line", button.x, button.y, button.width, button.height)

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf(button.label, button.x, button.y + 6, button.width, "center")
    end
end

--- Handle keyboard input
function NewCampaignWizard:keypressed(key, scancode, isrepeat)
    if key == "escape" then
        self:cancel()
    elseif self.current_step == 1 then
        -- Name input handling
        if key == "backspace" then
            self.name_input = string.sub(self.name_input, 1, -2)
        elseif key == "return" then
            self:nextStep()
        end
    elseif self.current_step == 2 then
        -- Difficulty selection
        if key == "up" then
            self.selected_difficulty = math.max(1, self.selected_difficulty - 1)
        elseif key == "down" then
            self.selected_difficulty = math.min(#self.difficulties, self.selected_difficulty + 1)
        elseif key == "return" then
            self:nextStep()
        end
    elseif self.current_step == 3 then
        -- Faction selection
        if key == "up" then
            self.selected_faction = math.max(1, self.selected_faction - 1)
        elseif key == "down" then
            self.selected_faction = math.min(#self.factions, self.selected_faction + 1)
        elseif key == "return" then
            self:nextStep()
        end
    elseif self.current_step == 4 then
        -- Speed selection
        if key == "up" then
            self.selected_speed = math.max(1, self.selected_speed - 1)
        elseif key == "down" then
            self.selected_speed = math.min(#self.speeds, self.selected_speed + 1)
        elseif key == "return" then
            self:nextStep()
        end
    elseif self.current_step == 5 then
        -- Confirmation
        if key == "return" then
            self:_createCampaign()
        end
    end
end

--- Handle text input
function NewCampaignWizard:textinput(t)
    if self.current_step == 1 then
        self.name_input = self.name_input .. t
    end
end

--- Handle mouse press
function NewCampaignWizard:mousepressed(x, y, button, istouch, presses)
    if button == 1 then
        for _, btn in ipairs(self.buttons) do
            if x >= btn.x and x < btn.x + btn.width and
               y >= btn.y and y < btn.y + btn.height then
                btn:onClick()
            end
        end

        -- Selection clicks for steps 2-4
        if self.current_step == 2 then
            for i = 1, #self.difficulties do
                local y_pos = 9 * 24 + (i - 1) * 2.5 * 24
                if y >= y_pos and y < y_pos + 2 * 24 then
                    self.selected_difficulty = i
                end
            end
        elseif self.current_step == 3 then
            for i = 1, #self.factions do
                local y_pos = 9 * 24 + (i - 1) * 2.5 * 24
                if y >= y_pos and y < y_pos + 2 * 24 then
                    self.selected_faction = i
                end
            end
        elseif self.current_step == 4 then
            for i = 1, #self.speeds do
                local y_pos = 9 * 24 + (i - 1) * 3 * 24
                if y >= y_pos and y < y_pos + 2 * 24 then
                    self.selected_speed = i
                end
            end
        end
    end
end

return NewCampaignWizard
