# Widget System for AlienFall

A complete, grid-based UI widget system for Love2D games.

## Overview

This widget system provides 23 production-ready widgets with:
- **24×24 pixel grid snapping** for precise layouts
- **Theme system** for centralized styling
- **Debug tools** (F9 grid overlay, F12 fullscreen)
- **Complete documentation** for each widget
- **Test suite** for validation
- **Demo application** showcasing all features

## Features

### Grid System
- Resolution: 960×720 pixels (40 columns × 30 rows)
- Grid cell size: 24×24 pixels
- All positions and sizes snap to grid
- Debug overlay shows grid lines (toggle with F9)

### Theme System
- Centralized color definitions
- Font management
- Consistent spacing and borders
- Easy theme customization

### 23 Widgets

**Phase 1: Basic**
- Button - Clickable button with text
- Label - Text display with alignment
- Panel - Background panel
- Container - Layout container (vertical/horizontal)

**Phase 2: Input**
- TextInput - Single-line text input
- Checkbox - Checkbox with label
- Dropdown - Dropdown selection menu
- ListBox - Scrollable selection list

**Phase 3: Display**
- ProgressBar - Progress indicator (0-100%)
- HealthBar - Health display with color gradient
- ScrollBox - Scrollable content area
- Tooltip - Hover tooltip

**Phase 4: Complex**
- FrameBox - Labeled group box
- TabWidget - Multi-tab interface
- Dialog - Modal dialog window
- Window - Draggable window

**Phase 5: Extended**
- ImageButton - Button with image
- ComboBox - Editable dropdown
- RadioButton - Radio button for groups
- Spinner - Numeric up/down control
- Autocomplete - Text input with suggestions
- Table - Data table with sorting
- TextArea - Multi-line text editor

## Quick Start

### Installation

```lua
-- In your main.lua
local widgets = require("widgets.init")

function love.load()
    widgets.init()
end

function love.draw()
    -- Your drawing code
    
    -- Draw grid overlay (if enabled with F9)
    widgets.drawDebug()
end

function love.keypressed(key)
    -- Handle widget system hotkeys (F9, F12)
    widgets.keypressed(key)
end
```

### Creating Widgets

```lua
-- All positions and sizes are automatically grid-snapped
local button = widgets.Button.new(
    5 * 24,   -- X: column 5 (120 pixels)
    3 * 24,   -- Y: row 3 (72 pixels)
    4 * 24,   -- Width: 4 cells (96 pixels)
    2 * 24    -- Height: 2 cells (48 pixels)
)

button.onClick = function(self, x, y)
    print("Button clicked!")
end

function love.draw()
    button:draw()
end

function love.update(dt)
    button:update(dt)
end

function love.mousepressed(x, y, button_num)
    button:mousepressed(x, y, button_num)
end
```

## Debug Tools

### F9 - Grid Overlay
Toggles visual grid overlay showing:
- 40×30 green grid lines
- Mouse position (grid and pixel coordinates)
- Grid information

### F12 - Fullscreen
Toggles fullscreen mode with proper widget scaling.

## Grid Coordinate System

```
Grid Position (0, 0)   → Pixel Position (0, 0)      [Top-Left]
Grid Position (1, 1)   → Pixel Position (24, 24)
Grid Position (10, 5)  → Pixel Position (240, 120)
Grid Position (39, 29) → Pixel Position (936, 696)  [Bottom-Right]
```

### Common Widget Sizes

| Widget | Grid Size | Pixel Size |
|--------|-----------|------------|
| Button | 4×2 | 96×48 |
| Text Input | 6-12×1 | 144-288×24 |
| List Box | 8×10 | 192×240 |
| Dialog | 12-20×8-12 | 288-480×192-288 |
| Label | Variable×1 | ?×24 |

## Example Usage

### Button with Click Handler

```lua
local button = widgets.Button.new(24, 24, 96, 48, "Click Me")
button.onClick = function(self)
    print("Button clicked!")
end

function love.draw()
    button:draw()
end

function love.mousepressed(x, y, btn)
    button:mousepressed(x, y, btn)
end

function love.mousereleased(x, y, btn)
    button:mousereleased(x, y, btn)
end
```

### TextInput with Change Handler

```lua
local input = widgets.TextInput.new(24, 96, 200, 24, "Type here...")
input.onChange = function(self, text)
    print("Text changed:", text)
end

function love.update(dt)
    input:update(dt)
end

function love.draw()
    input:draw()
end

function love.textinput(text)
    input:textinput(text)
end

function love.keypressed(key)
    input:keypressed(key)
end

function love.mousepressed(x, y, btn)
    input:mousepressed(x, y, btn)
end
```

### Container with Layout

```lua
local container = widgets.Container.new(24, 24, 200, 300)
container:setLayout("vertical")
container:setSpacing(24)

local btn1 = widgets.Button.new(0, 0, 96, 48, "Button 1")
local btn2 = widgets.Button.new(0, 0, 96, 48, "Button 2")
local btn3 = widgets.Button.new(0, 0, 96, 48, "Button 3")

container:addChild(btn1)
container:addChild(btn2)
container:addChild(btn3)

function love.draw()
    container:draw()  -- Draws all children automatically
end
```

## Theme Customization

```lua
local theme = require("widgets.theme")

-- Modify colors
theme.colors.primary = {r = 0.5, g = 0.5, b = 1.0, a = 1}
theme.colors.background = {r = 0.1, g = 0.1, b = 0.2, a = 1}

-- Modify spacing
theme.spacing = 24
theme.padding = 4
theme.borderWidth = 2
```

## Mock Data Generator

```lua
local mockData = require("widgets.mock_data")

-- Generate test data
local names = mockData.generateNames(10)
local items = mockData.generateItems(20)
local tableData = mockData.generateTableData(15, 5)
local units = mockData.generateUnits(8)
```

## Documentation

- **Widget Docs:** `engine/widgets/docs/` - API documentation for each widget
- **Tests:** `engine/widgets/tests/` - Unit tests for each widget
- **Demo:** `engine/widgets/demo/` - Standalone demo application

## Running the Demo

```bash
# From project root
lovec "engine/widgets/demo"

# Or use the batch file
engine\widgets\demo\run_demo.bat
```

## File Structure

```
engine/widgets/
├── init.lua              -- Widget system loader
├── base.lua              -- BaseWidget class
├── theme.lua             -- Theme system
├── grid.lua              -- Grid system & debug overlay
├── mock_data.lua         -- Test data generator
├── button.lua            -- Button widget
├── label.lua             -- Label widget
├── ... (23 widgets total)
├── docs/                 -- Widget documentation
│   ├── button.md
│   ├── label.md
│   └── ...
├── tests/                -- Widget tests
│   ├── test_button.lua
│   └── ...
└── demo/                 -- Demo application
    ├── main.lua
    ├── conf.lua
    └── run_demo.bat
```

## Best Practices

1. **Always use grid snapping:**
   ```lua
   local x, y = widgets.snapToGrid(rawX, rawY)
   local w, h = widgets.snapSize(rawWidth, rawHeight)
   ```

2. **Use theme for all styling:**
   ```lua
   theme.setColor("primary")
   theme.setFont("default")
   ```

3. **Handle events properly:**
   ```lua
   widget.onClick = function(self) end
   widget.onChange = function(self, value) end
   widget.onHover = function(self, isHovered) end
   ```

4. **Update widgets each frame:**
   ```lua
   function love.update(dt)
       widget:update(dt)
   end
   ```

## Development Guidelines

- All widget positions MUST be multiples of 24
- All widget sizes MUST be multiples of 24
- Use theme system for all colors and fonts
- Never hardcode visual properties
- Document all public methods
- Write test cases for new widgets
- Use mock data for testing

## Version

- **Version:** 1.0.0
- **Love2D:** 12.0+
- **Lua:** 5.1+
- **Resolution:** 960×720 (24×24 grid)

## License

Part of the AlienFall (XCOM Simple) project.

## Support

- **Documentation:** `engine/widgets/docs/`
- **Examples:** `engine/widgets/demo/`
- **Tests:** `engine/widgets/tests/`
