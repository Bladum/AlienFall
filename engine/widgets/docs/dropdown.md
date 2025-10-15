# Dropdown Widget

Collapsible selection menu for choosing from a list of options.

## Purpose

Dropdown provides a space-efficient way to select from multiple options. Shows only the selected item when collapsed, expands to show all options when clicked. Used for settings, filters, sorting, and any single-choice selection.

## Constructor

```lua
local Dropdown = require("widgets.navigation.dropdown")
local dropdown = Dropdown.new(x, y, width, height)
```

### Parameters

- **x** (number): X position in pixels (multiple of 24)
- **y** (number): Y position in pixels (multiple of 24)
- **width** (number): Dropdown width in pixels (multiple of 24)
- **height** (number): Item height in pixels (multiple of 24, typically 24)

### Returns

- **Dropdown**: New dropdown instance

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `options` | table | {} | Array of option strings |
| `selectedIndex` | number | 0 | Index of selected option (0 = none) |
| `expanded` | boolean | false | Whether dropdown is open |
| `maxVisibleItems` | number | 8 | Max items before scrolling |
| `itemHeight` | number | 24 | Height of each option (pixels) |
| `onChange` | function | nil | Callback when selection changes |
| `backgroundColor` | string | "background" | Theme color for dropdown |
| `selectedColor` | string | "primary" | Theme color for selected item |
| `hoverColor` | string | "backgroundLight" | Theme color for hover |

## Methods

### setOptions(options)

Set the list of selectable options.

```lua
dropdown:setOptions({"Easy", "Normal", "Hard", "Legendary"})
```

**Parameters:**
- options (table): Array of option strings

### getSelectedOption()

Get currently selected option text.

```lua
local difficulty = dropdown:getSelectedOption()  -- Returns "Normal"
```

**Returns:**
- string|nil: Selected option text, or nil if none selected

### getSelectedIndex()

Get index of selected option.

```lua
local index = dropdown:getSelectedIndex()  -- Returns 2 for "Normal"
```

**Returns:**
- number: Selected index (0 if none selected)

### setSelectedIndex(index)

Set selection by index.

```lua
dropdown:setSelectedIndex(2)  -- Select second option
```

**Parameters:**
- index (number): Option index (1-based)

### setSelectedOption(text)

Set selection by option text.

```lua
dropdown:setSelectedOption("Hard")
```

**Parameters:**
- text (string): Option text to select

### setOnChange(callback)

Set callback for selection changes.

```lua
dropdown:setOnChange(function(option, index)
    print("Selected:", option, "at index", index)
end)
```

**Parameters:**
- callback (function): Function called with (option, index)

### expand()

Open dropdown to show all options.

```lua
dropdown:expand()
```

### collapse()

Close dropdown.

```lua
dropdown:collapse()
```

### toggle()

Toggle expanded/collapsed state.

```lua
dropdown:toggle()
```

### mousepressed(x, y, button)

Handle mouse click events.

```lua
dropdown:mousepressed(x, y, 1)
```

**Parameters:**
- x (number): Mouse X coordinate
- y (number): Mouse Y coordinate
- button (number): Mouse button (1=left)

### keypressed(key)

Handle keyboard navigation.

```lua
dropdown:keypressed("down")  -- Move to next option
```

**Parameters:**
- key (string): Key name ("up", "down", "return", "escape")

### draw()

Render dropdown (collapsed or expanded).

```lua
dropdown:draw()
```

## Events

### onChange(option, index)

Triggered when selection changes.

```lua
dropdown:setOnChange(function(option, index)
    applyDifficulty(option)
    saveSettings()
end)
```

**Parameters:**
- option (string): Selected option text
- index (number): Selected option index (1-based)

## Complete Example

```lua
local Dropdown = require("widgets.navigation.dropdown")

-- Difficulty dropdown
local ddDifficulty = Dropdown.new(24, 24, 192, 24)
ddDifficulty:setOptions({"Easy", "Normal", "Hard", "Legendary"})
ddDifficulty:setSelectedIndex(2)  -- Default to Normal

-- Resolution dropdown
local ddResolution = Dropdown.new(24, 72, 192, 24)
ddResolution:setOptions({"800x600", "1024x768", "1280x720", "1920x1080"})
ddResolution:setSelectedIndex(3)

-- Unit class dropdown
local ddClass = Dropdown.new(24, 120, 192, 24)
ddClass:setOptions({"Assault", "Sniper", "Heavy", "Medic", "Scout"})

-- Setup callbacks
ddDifficulty:setOnChange(function(option, index)
    game.difficulty = option
    print("Difficulty set to:", option)
end)

ddResolution:setOnChange(function(option, index)
    local w, h = option:match("(%d+)x(%d+)")
    love.window.setMode(tonumber(w), tonumber(h))
end)

-- In love.mousepressed(x, y, button)
function love.mousepressed(x, y, button)
    ddDifficulty:mousepressed(x, y, button)
    ddResolution:mousepressed(x, y, button)
    ddClass:mousepressed(x, y, button)
end

-- In love.keypressed(key)
function love.keypressed(key)
    if ddDifficulty.expanded then
        ddDifficulty:keypressed(key)
    end
end

-- In love.draw()
function love.draw()
    ddDifficulty:draw()
    ddResolution:draw()
    ddClass:draw()
end
```

## Grid Examples

```lua
-- Standard dropdown (8×1 cells = 192×24 pixels)
local dd1 = Dropdown.new(24, 24, 192, 24)

-- Wide dropdown (12×1 cells = 288×24 pixels)
local dd2 = Dropdown.new(24, 72, 288, 24)

-- Narrow dropdown (6×1 cells = 144×24 pixels)
local dd3 = Dropdown.new(24, 120, 144, 24)

-- When expanded, height = numOptions * itemHeight
-- 5 options × 24px = 120px tall when open
```

## Dynamic Options

```lua
local ddMaps = Dropdown.new(24, 24, 288, 24)

function refreshMapList()
    local maps = {}
    local items = love.filesystem.getDirectoryItems("maps")
    for _, filename in ipairs(items) do
        if filename:match("%.map$") then
            table.insert(maps, filename:gsub("%.map$", ""))
        end
    end
    ddMaps:setOptions(maps)
end

refreshMapList()
```

## Cascading Dropdowns

```lua
-- Country dropdown affects region dropdown
local ddCountry = Dropdown.new(24, 24, 192, 24)
local ddRegion = Dropdown.new(24, 72, 192, 24)

ddCountry:setOptions({"USA", "UK", "Japan", "Germany"})

ddCountry:setOnChange(function(country)
    local regions = {
        USA = {"West", "East", "Midwest", "South"},
        UK = {"England", "Scotland", "Wales", "N.Ireland"},
        Japan = {"Honshu", "Hokkaido", "Kyushu", "Shikoku"},
        Germany = {"Bavaria", "Berlin", "Hamburg", "Saxony"}
    }
    ddRegion:setOptions(regions[country] or {})
    ddRegion:setSelectedIndex(1)
end)

ddCountry:setSelectedIndex(1)  -- Trigger initial regions
```

## Searchable Dropdown

```lua
local searchText = ""
local allOptions = {"Alpha", "Beta", "Gamma", "Delta", "Epsilon"}
local ddSearch = Dropdown.new(24, 24, 192, 24)

function updateSearchResults(text)
    local filtered = {}
    for _, option in ipairs(allOptions) do
        if option:lower():find(text:lower(), 1, true) then
            table.insert(filtered, option)
        end
    end
    ddSearch:setOptions(filtered)
end

function love.textinput(text)
    if ddSearch.expanded then
        searchText = searchText .. text
        updateSearchResults(searchText)
    end
end
```

## Grouped Options

```lua
local ddWeapon = Dropdown.new(24, 24, 240, 24)

-- Add separator lines between groups
local options = {
    "--- Rifles ---",
    "Assault Rifle",
    "Sniper Rifle",
    "--- Pistols ---",
    "Handgun",
    "Magnum",
    "--- Heavy ---",
    "Rocket Launcher",
    "Machine Gun"
}

ddWeapon:setOptions(options)

-- Skip separator selections
ddWeapon:setOnChange(function(option)
    if not option:match("^%-%-%-") then
        equipWeapon(option)
    end
end)
```

## Validation Example

```lua
local ddRequired = Dropdown.new(24, 24, 192, 24)
ddRequired:setOptions({"Option 1", "Option 2", "Option 3"})

local btnSubmit = Button.new(24, 72, 192, 48, "Submit")
btnSubmit:setEnabled(false)

ddRequired:setOnChange(function(option)
    -- Enable submit when valid selection made
    btnSubmit:setEnabled(option ~= nil)
end)
```

## See Also

- [ListBox](listbox.md) - Always-visible list selection
- [ComboBox](combobox.md) - Dropdown with text input
- [ContextMenu](contextmenu.md) - Right-click menu
- [Button](button.md) - Click button
