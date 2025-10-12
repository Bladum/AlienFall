# Widget System Quick Reference

## Grid System

**Resolution:** 960×720 pixels  
**Grid:** 40 columns × 30 rows  
**Cell Size:** 24×24 pixels  

### Position Formula
```
pixelX = gridColumn × 24
pixelY = gridRow × 24
```

### Size Formula
```
pixelWidth = gridWidth × 24
pixelHeight = gridHeight × 24
```

## Debug Hotkeys

| Key | Action |
|-----|--------|
| F9  | Toggle grid overlay (40×30 green grid lines) |
| F12 | Toggle fullscreen mode |

## Widget Sizes (Grid Units)

| Widget Type | Typical Size | Pixels |
|-------------|--------------|--------|
| Button | 4×2 | 96×48 |
| Label | Variable×1 | ?×24 |
| Text Input | 6-12×1 | 144-288×24 |
| List Box | 8×10 | 192×240 |
| Dialog | 12-20×8-12 | 288-480×192-288 |
| Panel | Multiple of 24 | - |

## Code Templates

### Create Widget on Grid
```lua
local button = Button.new(
    5 * 24,   -- X: column 5
    3 * 24,   -- Y: row 3
    4 * 24,   -- Width: 4 cells
    2 * 24    -- Height: 2 cells
)
```

### Use Grid Helper
```lua
local widgets = require("widgets")
local x, y = widgets.snapToGrid(rawX, rawY)
local w, h = widgets.snapSize(rawWidth, rawHeight)
```

### Access Theme
```lua
local theme = require("widgets.theme")
love.graphics.setColor(
    theme.colors.primary.r,
    theme.colors.primary.g,
    theme.colors.primary.b
)
```

## Files to Create

### Core System (4 files)
- `engine/widgets/init.lua`
- `engine/widgets/base.lua`
- `engine/widgets/theme.lua`
- `engine/widgets/grid.lua`
- `engine/widgets/mock_data.lua`

### Widgets (23 files)
1. `button.lua`
2. `imagebutton.lua`
3. `combobox.lua`
4. `checkbox.lua`
5. `listbox.lua`
6. `scrollbox.lua`
7. `progressbar.lua`
8. `healthbar.lua`
9. `radiobutton.lua`
10. `tooltip.lua`
11. `framebox.lua`
12. `textinput.lua`
13. `textarea.lua`
14. `dropdown.lua`
15. `panel.lua`
16. `container.lua`
17. `spinner.lua`
18. `tabwidget.lua`
19. `dialog.lua`
20. `autocomplete.lua`
21. `table.lua`
22. `label.lua`
23. `window.lua`

## Directory Structure

```
engine/widgets/
├── init.lua
├── base.lua
├── theme.lua
├── grid.lua
├── mock_data.lua
├── [23 widget files]
├── README.md
├── THEME_GUIDE.md
├── docs/
│   └── [23 widget docs]
├── tests/
│   ├── run_tests.lua
│   └── [23 widget tests]
└── demo/
    ├── main.lua
    ├── conf.lua
    ├── run_demo.bat
    ├── screens/
    └── assets/
```

## Run Commands

```bash
# Run main game
lovec "engine"

# Run widget demo
lovec "engine/widgets/demo"

# Run widget tests
lovec "engine/widgets/tests"
```

## Validation Checklist

Before committing any widget:
- [ ] Position is multiple of 24
- [ ] Size is multiple of 24
- [ ] Uses theme for all colors
- [ ] Has documentation file
- [ ] Has test file
- [ ] Runs without console errors
- [ ] Responds to F9 grid overlay

## Common Grid Coordinates

| Location | Grid | Pixels |
|----------|------|--------|
| Top-Left | (0, 0) | (0, 0) |
| Top-Right | (39, 0) | (936, 0) |
| Bottom-Left | (0, 29) | (0, 696) |
| Bottom-Right | (39, 29) | (936, 696) |
| Center | (20, 15) | (480, 360) |
| Quarter Width | (10, 15) | (240, 360) |
| Three-Quarter Width | (30, 15) | (720, 360) |

## Widget Inheritance

All widgets inherit from `BaseWidget`:
```lua
local MyWidget = setmetatable({}, {__index = BaseWidget})

function MyWidget.new(x, y, width, height)
    local self = BaseWidget.new(x, y, width, height)
    setmetatable(self, {__index = MyWidget})
    -- Widget-specific initialization
    return self
end
```

## Theme Structure

```lua
theme = {
    colors = {
        primary = {r, g, b, a},
        background = {r, g, b, a},
        text = {r, g, b, a},
        border = {r, g, b, a},
        hover = {r, g, b, a},
        active = {r, g, b, a},
        disabled = {r, g, b, a},
    },
    fonts = {
        default = love.graphics.newFont(12),
        small = love.graphics.newFont(10),
        large = love.graphics.newFont(16),
    },
    spacing = 24,      -- Grid size
    border_width = 2,
    padding = 4,
}
```

## Mock Data Functions

```lua
local mockData = require("widgets.mock_data")

local names = mockData.generateNames(10)
local items = mockData.generateItems(20)
local tableData = mockData.generateTableData(15, 5)
local healthBars = mockData.generateHealthBars(8)
local tooltips = mockData.generateTooltips(12)
```

---

**See full task:** `tasks/TODO/TASK-001-grid-based-widget-system.md`  
**See summary:** `tasks/TODO/TASK-001-SUMMARY.md`
