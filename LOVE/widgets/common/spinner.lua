--[[
widgets/spinner.lua
Spinner widget (numeric input control with increment/decrement buttons)


Numeric spinner widget providing precise value input with increment/decrement controls
for tactical strategy game interfaces. Essential for numeric settings, quantities, and
configuration values requiring exact input in OpenXCOM-style game configuration screens.

PURPOSE:
- Provide precise numeric input with visual increment/decrement controls
- Enable bounded numeric input with configurable min/max values
- Support keyboard navigation for accessibility
- Facilitate numeric parameter adjustment in game settings
- Core component for configuration and quantity selection in strategy games

KEY FEATURES:
- Numeric value input with configurable bounds and step sizes
- Up/down arrow buttons for increment/decrement operations
- Keyboard navigation support (arrow keys, enter, escape)
- Visual feedback for hover, focus, and interaction states
- Callback system for value change notifications
- Theme integration for consistent visual styling
- Precise control suitable for small numeric adjustments

@see widgets.common.core.Base
@see widgets.common.slider
@see widgets.common.validation

-- Basic numeric spinner
local volumeSpinner = Spinner:new(100, 100, 80, 24, 50, 0, 100, 5, {
    onValueChange = function(newValue)
        setMasterVolume(newValue)
        print("Volume set to:", newValue)
    end
})

-- Spinner for game settings
local difficultySpinner = Spinner:new(200, 100, 60, 24, 3, 1, 10, 1, {
    onValueChange = function(value)
        gameSettings.difficulty = value
        updateDifficultyDisplay()
    end
})

-- Spinner with different step sizes
local precisionSpinner = Spinner:new(100, 150, 100, 24, 1.5, 0.0, 10.0, 0.1, {
    onValueChange = function(value)
        setPrecision(value)
    end
})

-- Large range spinner
local quantitySpinner = Spinner:new(100, 200, 80, 24, 100, 1, 1000, 10, {
    onValueChange = function(value)
        orderQuantity = value
        updateTotalPrice()
    end
})

-- Integration with forms
local settingsForm = {
    volumeLabel = Label:new(50, 50, "Master Volume:"),
    volumeSpinner = Spinner:new(150, 50, 60, 24, 75, 0, 100, 5),

    sfxLabel = Label:new(50, 80, "SFX Volume:"),
    sfxSpinner = Spinner:new(150, 80, 60, 24, 80, 0, 100, 5),

    musicLabel = Label:new(50, 110, "Music Volume:"),
    musicSpinner = Spinner:new(150, 110, 60, 24, 70, 0, 100, 5)
}

-- Apply settings when changed
settingsForm.volumeSpinner.onValueChange = function(value)
    audio.setMasterVolume(value / 100)
end
settingsForm.sfxSpinner.onValueChange = function(value)
    audio.setSFXVolume(value / 100)
end
settingsForm.musicSpinner.onValueChange = function(value)
    audio.setMusicVolume(value / 100)
end

-- Game configuration spinners
local gameConfig = {
    -- Player count
    playerCount = Spinner:new(200, 100, 50, 24, 4, 1, 8, 1, {
        onValueChange = function(count)
            resizePlayerSlots(count)
        end
    }),

    -- Turn time limit (minutes)
    turnTime = Spinner:new(200, 130, 60, 24, 5, 1, 30, 1, {
        onValueChange = function(minutes)
            gameRules.turnTimeLimit = minutes * 60 -- Convert to seconds
        end
    }),

    -- Starting resources
    startResources = Spinner:new(200, 160, 80, 24, 1000, 500, 5000, 100, {
        onValueChange = function(amount)
            gameRules.startingResources = amount
        end
    })
}

-- Scientific notation for large numbers
local largeNumberSpinner = Spinner:new(100, 100, 100, 24, 1000000, 1000, 10000000, 100000, {
    onValueChange = function(value)
        -- Format for display
        displayValue = string.format("%.1fM", value / 1000000)
    end
})

-- Time duration spinner
local timeSpinner = Spinner:new(100, 100, 70, 24, 30, 5, 120, 5, {
    onValueChange = function(seconds)
        local minutes = math.floor(seconds / 60)
        local remainingSeconds = seconds % 60
        timeDisplay = string.format("%d:%02d", minutes, remainingSeconds)
    end
})

-- Percentage spinner
local percentageSpinner = Spinner:new(100, 100, 60, 24, 75, 0, 100, 1, {
    onValueChange = function(value)
        percentageDisplay = value .. "%"
        applyPercentage(value / 100)
    end
})

-- Keyboard integration
function love.keypressed(key)
    if volumeSpinner.focused then
        volumeSpinner:keypressed(key)
    end
end

function love.mousepressed(x, y, button)
    if volumeSpinner:mousepressed(x, y, button) then
        -- Spinner handled the click
        return
    end
    -- Handle other mouse events
end

-- Focus management
function setFocus(widget)
    -- Remove focus from other spinners
    volumeSpinner.focused = false
    difficultySpinner.focused = false

    -- Set focus to target widget
    if widget == volumeSpinner then
        volumeSpinner.focused = true
    elseif widget == difficultySpinner then
        difficultySpinner.focused = true
    end
end

-- Dynamic spinner creation
function createResourceSpinner(resourceType, initialValue)
    local maxValues = {
        gold = 10000,
        wood = 5000,
        stone = 3000,
        food = 2000
    }

    return Spinner:new(100, 100, 80, 24, initialValue, 0, maxValues[resourceType], 100, {
        onValueChange = function(value)
            resources[resourceType] = value
            updateResourceDisplay()
        end
    })
end

local goldSpinner = createResourceSpinner("gold", 1000)
local woodSpinner = createResourceSpinner("wood", 500)

@see Slider
@see TextInput
-- Comparison with other input controls
-- Use Spinner when:
-- - You need precise numeric input
-- - Values have specific min/max bounds
-- - Users need to make small adjustments frequently
-- - Space is limited but precision is important

-- Use Slider when:
-- - Relative values are more important than exact numbers
-- - You want visual feedback of the value range
-- - Users need to see all possible values at once
-- - Quick approximate adjustments are sufficient

-- Use TextInput when:
-- - Users might want to type exact values
-- - Values don't have strict bounds
-- - Copy/paste functionality is needed
-- - Very large or very small numbers are expected

-- Advanced validation and formatting
local validatedSpinner = Spinner:new(100, 100, 80, 24, 50, 0, 100, 1, {
    onValueChange = function(value)
        -- Custom validation
        if value < 25 then
            print("Warning: Value is quite low")
        elseif value > 75 then
            print("Warning: Value is quite high")
        end

        -- Apply with formatting
        applyValue(string.format("%.1f", value))
    end
})

-- Spinner arrays for bulk operations
local parameterSpinners = {}
local parameters = {"speed", "damage", "range", "cooldown"}
local defaultValues = {10, 25, 100, 5}

for i, param in ipairs(parameters) do
    parameterSpinners[param] = Spinner:new(
        200, 100 + (i-1) * 30,
        60, 24,
        defaultValues[i],
        1, 100, 1, {
            onValueChange = function(value)
                unitStats[param] = value
                updateUnitPreview()
            end
        }
]]

local core = require("widgets.core")
local Spinner = {}
Spinner.__index = Spinner

function Spinner:new(x, y, w, h, value, min, max, step, options)
    local obj = {
        x = x,
        y = y,
        w = w,
        h = h,
        value = value or 0,
        min = min or 0,
        max = max or 100,
        step = step or 1,
        hovered = false,
        focused = false,
        onValueChange = options and options.onValueChange or nil
    }
    setmetatable(obj, self)
    return obj
end

function Spinner:draw()
    -- Background
    if self.focused then
        love.graphics.setColor(unpack(core.theme.accent))
    elseif self.hovered then
        love.graphics.setColor(unpack(core.theme.primaryHover))
    else
        love.graphics.setColor(unpack(core.theme.secondary))
    end
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)

    -- Border
    love.graphics.setColor(unpack(core.theme.border))
    love.graphics.rectangle("line", self.x, self.y, self.w, self.h)

    -- Value text
    love.graphics.setColor(unpack(core.theme.text))
    love.graphics.printf(tostring(self.value), self.x + 6, self.y + self.h / 2 - 8, self.w - 40, "left")

    -- Up/Down arrows
    local arrowY = self.y + 4
    love.graphics.setColor(unpack(core.theme.text))
    love.graphics.polygon("fill", self.x + self.w - 15, arrowY, self.x + self.w - 10, arrowY + 5, self.x + self.w - 20,
        arrowY + 5)
    local arrowY2 = self.y + self.h - 9
    love.graphics.polygon("fill", self.x + self.w - 15, arrowY2, self.x + self.w - 10, arrowY2 - 5, self.x + self.w - 20,
        arrowY2 - 5)
end

function Spinner:keypressed(key)
    if not self.focused then return end
    if key == "up" then
        self.value = math.min(self.max, self.value + self.step)
        if self.onValueChange then self.onValueChange(self.value) end
    elseif key == "down" then
        self.value = math.max(self.min, self.value - self.step)
        if self.onValueChange then self.onValueChange(self.value) end
    end
end

function Spinner:mousepressed(x, y, button)
    if button ~= 1 then return false end
    if core.isInside(x, y, self.x, self.y, self.w, self.h) then
        local half = self.w / 2
        if x < self.x + half then
            self.value = math.max(self.min, self.value - self.step)
        else
            self.value = math.min(
                self.max, self.value + self.step)
        end
        return true
    end
    return false
end

return Spinner
