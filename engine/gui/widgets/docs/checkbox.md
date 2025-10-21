# Checkbox Widget

Toggle input control with checkmark indicator and label.

## Purpose

Checkbox provides binary on/off state selection with visual checkmark. Used for settings, filters, multi-selection, feature toggles, and boolean options. Triggers callback on state change.

## Constructor

```lua
local Checkbox = require("widgets.input.checkbox")
local checkbox = Checkbox.new(x, y, label, checked)
```

### Parameters

- **x** (number): X position in pixels (multiple of 24)
- **y** (number): Y position in pixels (multiple of 24)
- **label** (string, optional): Text label displayed next to checkbox (default: "")
- **checked** (boolean, optional): Initial checked state (default: false)

### Returns

- **Checkbox**: New checkbox instance

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `checked` | boolean | false | Current check state |
| `label` | string | "" | Text displayed beside checkbox |
| `boxSize` | number | 24 | Size of checkbox square (pixels) |
| `enabled` | boolean | true | Whether checkbox is interactive |
| `boxColor` | string | "background" | Theme color for checkbox box |
| `checkColor` | string | "primary" | Theme color for checkmark |
| `labelColor` | string | "text" | Theme color for label text |
| `onChange` | function | nil | Callback when state changes |

## Methods

### setChecked(checked)

Set checkbox state programmatically.

```lua
checkbox:setChecked(true)   -- Check
checkbox:setChecked(false)  -- Uncheck
```

**Parameters:**
- checked (boolean): New checked state

### toggle()

Toggle between checked/unchecked.

```lua
checkbox:toggle()  -- Flip current state
```

### setLabel(label)

Change label text.

```lua
checkbox:setLabel("Enable Sound")
```

**Parameters:**
- label (string): New label text

### setEnabled(enabled)

Enable or disable checkbox interaction.

```lua
checkbox:setEnabled(false)  -- Grayed out, no interaction
```

**Parameters:**
- enabled (boolean): Interaction state

### setOnChange(callback)

Set callback function for state changes.

```lua
checkbox:setOnChange(function(checked)
    print("Checkbox is now: " .. tostring(checked))
end)
```

**Parameters:**
- callback (function): Function called with checked state

### mousepressed(x, y, button)

Handle mouse click events.

```lua
checkbox:mousepressed(x, y, 1)
```

**Parameters:**
- x (number): Mouse X coordinate
- y (number): Mouse Y coordinate
- button (number): Mouse button (1=left)

### draw()

Render checkbox and label.

```lua
checkbox:draw()
```

## Events

### onChange(checked)

Triggered when checkbox state changes.

```lua
checkbox:setOnChange(function(checked)
    if checked then
        enableFeature()
    else
        disableFeature()
    end
end)
```

**Parameters:**
- checked (boolean): New state (true/false)

## Complete Example

```lua
local Checkbox = require("widgets.input.checkbox")

-- Settings checkboxes
local cbSound = Checkbox.new(24, 24, "Enable Sound", true)
local cbMusic = Checkbox.new(24, 72, "Enable Music", true)
local cbFullscreen = Checkbox.new(24, 120, "Fullscreen", false)
local cbVsync = Checkbox.new(24, 168, "V-Sync", true)

-- Setup callbacks
cbSound:setOnChange(function(checked)
    love.audio.setVolume(checked and 1.0 or 0.0)
end)

cbFullscreen:setOnChange(function(checked)
    love.window.setFullscreen(checked, "desktop")
end)

-- In love.mousepressed(x, y, button)
function love.mousepressed(x, y, button)
    cbSound:mousepressed(x, y, button)
    cbMusic:mousepressed(x, y, button)
    cbFullscreen:mousepressed(x, y, button)
    cbVsync:mousepressed(x, y, button)
end

-- In love.draw()
function love.draw()
    cbSound:draw()
    cbMusic:draw()
    cbFullscreen:draw()
    cbVsync:draw()
end
```

## Grid Examples

```lua
-- Standard checkbox (24×24 box + label)
local cb1 = Checkbox.new(24, 24, "Option 1")

-- Vertical list (every 48 pixels = 2 grid cells)
local cb1 = Checkbox.new(24, 24, "Option 1")
local cb2 = Checkbox.new(24, 72, "Option 2")
local cb3 = Checkbox.new(24, 120, "Option 3")

-- Horizontal list (every 192 pixels = 8 grid cells)
local cb1 = Checkbox.new(24, 24, "Easy")
local cb2 = Checkbox.new(216, 24, "Medium")
local cb3 = Checkbox.new(408, 24, "Hard")
```

## Multi-Selection Example

```lua
local checkboxes = {}
local units = {"Assault", "Sniper", "Heavy", "Medic", "Scout"}

for i, unitType in ipairs(units) do
    local cb = Checkbox.new(24, i * 48, unitType, false)
    cb:setOnChange(function(checked)
        if checked then
            selectedUnits[unitType] = true
        else
            selectedUnits[unitType] = nil
        end
        updateSelectionCount()
    end)
    table.insert(checkboxes, cb)
end

-- Select All button
local btnSelectAll = Button.new(24, 288, 192, 48, "Select All")
btnSelectAll:setOnClick(function()
    for _, cb in ipairs(checkboxes) do
        cb:setChecked(true)
    end
end)
```

## Filter System

```lua
-- Filter checkboxes
local filters = {
    showInfantry = Checkbox.new(24, 24, "Infantry", true),
    showVehicles = Checkbox.new(24, 72, "Vehicles", true),
    showAir = Checkbox.new(24, 120, "Aircraft", true),
}

-- Apply filters when any changes
for name, checkbox in pairs(filters) do
    checkbox:setOnChange(function()
        refreshUnitList()
    end)
end

function refreshUnitList()
    local filtered = {}
    for _, unit in ipairs(allUnits) do
        if filters.showInfantry.checked and unit.type == "infantry" then
            table.insert(filtered, unit)
        end
        if filters.showVehicles.checked and unit.type == "vehicle" then
            table.insert(filtered, unit)
        end
        if filters.showAir.checked and unit.type == "aircraft" then
            table.insert(filtered, unit)
        end
    end
    updateDisplay(filtered)
end
```

## Form Validation

```lua
local cbAgree = Checkbox.new(24, 400, "I agree to the terms", false)
local btnSubmit = Button.new(24, 448, 192, 48, "Submit")
btnSubmit:setEnabled(false)

cbAgree:setOnChange(function(checked)
    btnSubmit:setEnabled(checked)
end)
```

## State Persistence

```lua
-- Save checkbox states
function saveSettings()
    local settings = {
        sound = cbSound.checked,
        music = cbMusic.checked,
        fullscreen = cbFullscreen.checked,
        vsync = cbVsync.checked,
    }
    love.filesystem.write("settings.json", json.encode(settings))
end

-- Load checkbox states
function loadSettings()
    local content = love.filesystem.read("settings.json")
    if content then
        local settings = json.decode(content)
        cbSound:setChecked(settings.sound)
        cbMusic:setChecked(settings.music)
        cbFullscreen:setChecked(settings.fullscreen)
        cbVsync:setChecked(settings.vsync)
    end
end
```

## Grouped Checkboxes

```lua
-- Difficulty settings (only one can be checked)
local difficulties = {}
local difficulty Names = {"Easy", "Normal", "Hard", "Legendary"}

for i, name in ipairs(difficultyNames) do
    local cb = Checkbox.new(24, i * 48, name, i == 2)  -- Normal default
    cb:setOnChange(function(checked)
        if checked then
            -- Uncheck others
            for _, other in ipairs(difficulties) do
                if other ~= cb then
                    other:setChecked(false)
                end
            end
        end
    end)
    table.insert(difficulties, cb)
end
```

## See Also

- [RadioButton](radiobutton.md) - Mutually exclusive selection
- [Button](button.md) - Click button
- [Toggle](toggle.md) - Switch-style toggle
- [TextInput](textinput.md) - Text entry field
