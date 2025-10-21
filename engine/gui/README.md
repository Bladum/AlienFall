# GUI Folder - Global User Interface System

This folder contains the **global UI framework** used across all game screens. It provides widgets, scenes, and layout systems for rendering the game interface. This is separate from **system-specific UI** (e.g., `battlescape/ui/`, `geoscape/ui/`) which handle specialized rendering for those game layers.

## Folder Structure

```
gui/
├── scenes/           # Global screen definitions
├── widgets/          # UI component library
└── README.md         # This file
```

## Overview

### scenes/ (8 screen types)
- **Purpose**: Define top-level game screens and transitions
- **Contains**: Main menu, game mode selectors, screen routing
- **Screens**:
  - `main_menu.lua` - Game start screen
  - `geoscape_screen.lua` - Strategic world map
  - `battlescape_screen.lua` - Tactical combat
  - `basescape_screen.lua` - Base management
  - `interception_screen.lua` - Craft interception layer
  - `deployment_screen.lua` - Pre-mission unit deployment
  - `tests_menu.lua` - Testing and debug menu
  - `widget_showcase.lua` - Widget library demo
- **Usage**: `local MenuScene = require("gui.scenes.main_menu")`

### widgets/ (60+ UI components)
- **Purpose**: Reusable UI widgets following 24×24 pixel grid
- **Categories**:
  - **Core**: Grid system, Theme, BaseWidget class
  - **Buttons**: Button, ImageButton, ActionButton, ToggleButton
  - **Containers**: Panel, Window, Dialog, FrameBox, ScrollBox
  - **Display**: Label, ProgressBar, HealthBar, Tooltip, ActionPanel
  - **Input**: TextInput, TextArea, Checkbox, RadioButton, ComboBox
  - **Navigation**: ListBox, Dropdown, TabWidget, Table, ContextMenu
  - **Advanced**: UnitCard, ResearchTree, Minimap, InventorySlot
  - **Combat**: UnitInfoPanel, SkillSelection, TurnIndicator, WeaponModeSelector
- **Usage**: `local Widgets = require("gui.widgets.init")`

## Grid System

All UI snaps to a **24×24 pixel grid** within a **960×720 window** (40×30 grid cells):

```lua
-- Grid functions
Widgets.Grid.snap(x, y)              -- Snap to grid
Widgets.Grid.toScreen(gridX, gridY)  -- Convert to pixels
Widgets.Grid.toGrid(x, y)            -- Convert to grid
Widgets.Grid.drawOverlay()           -- Debug overlay (F9)
```

## Theme System

Consistent theming across all UI via `Widgets.Theme`:

```lua
-- Colors
Theme.colors = {
    primary = {0.2, 0.6, 1.0},
    secondary = {0.5, 0.5, 0.5},
    background = {0.1, 0.1, 0.1},
    text = {1, 1, 1},
    success = {0, 1, 0},
    warning = {1, 1, 0},
    danger = {1, 0, 0}
}

-- Fonts
Theme.fonts = {
    default = smallFont,
    title = largeFont,
    small = tinyFont
}

-- Spacing
Theme.padding = 8
Theme.borderWidth = 2
```

## Creating UI Screens

```lua
local StateManager = require("core.state_manager")
local Widgets = require("gui.widgets.init")

local MyScreen = {}

function MyScreen:enter()
    -- Initialize widgets
    self.button = Widgets.Button.new(24, 24, 96, 48, "Click Me")
    self.button.onClick = function()
        print("Clicked!")
    end
end

function MyScreen:update(dt)
    -- Update logic
end

function MyScreen:draw()
    Widgets.Theme.setColor("background")
    love.graphics.clear()
    self.button:draw()
end

function MyScreen:mousepressed(x, y, button)
    self.button:mousepressed(x, y, button)
end

return MyScreen
```

## System-Specific UI

Note: This folder contains **global** UI. System-specific UI is located in:
- `engine/battlescape/ui/` - Tactical combat UI
- `engine/geoscape/ui/` - Strategic layer UI
- `engine/basescape/ui/` - (if needed) Base management UI

## See Also

- `wiki/API.md` - Complete widget API reference
- `tests/widgets/` - Widget test suite
- `tools/` - Additional UI tools
