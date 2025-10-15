# Panel Widget

Simple rectangular background panel for grouping widgets.

## Purpose

Panel provides a colored background container for organizing UI elements. It's the most basic container widget, offering background color, optional border, and child widget support. All positions snap to the 24×24 pixel grid.

## Constructor

```lua
local Panel = require("widgets.containers.panel")
local panel = Panel.new(x, y, width, height)
```

### Parameters

- **x** (number): X position in pixels (must be multiple of 24)
- **y** (number): Y position in pixels (must be multiple of 24)
- **width** (number): Panel width in pixels (must be multiple of 24)
- **height** (number): Panel height in pixels (must be multiple of 24)

### Returns

- **Panel**: New panel instance

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `backgroundColor` | string | "backgroundLight" | Theme color name for background |
| `borderColor` | string | "border" | Theme color name for border |
| `showBorder` | boolean | true | Whether to draw border |
| `visible` | boolean | true | Whether panel is rendered |
| `x` | number | - | Grid-aligned X position |
| `y` | number | - | Grid-aligned Y position |
| `width` | number | - | Grid-aligned width |
| `height` | number | - | Grid-aligned height |

## Methods

### setBackgroundColor(colorName)

Set background color using theme name.

```lua
panel:setBackgroundColor("background")
```

**Parameters:**
- colorName (string): Theme color identifier

### setBorderColor(colorName)

Set border color using theme name.

```lua
panel:setBorderColor("primary")
```

**Parameters:**
- colorName (string): Theme color identifier

### addChild(widget)

Add child widget to panel (inherits from BaseWidget).

```lua
local button = Button.new(10, 10, 96, 48, "OK")
panel:addChild(button)
```

**Parameters:**
- widget (Widget): Child widget instance

### draw()

Render panel and all children.

```lua
panel:draw()
```

## Events

Panel inherits events from BaseWidget but doesn't trigger its own events. Use for:
- Background decoration
- Visual grouping
- Container for interactive widgets

## Complete Example

```lua
local Panel = require("widgets.containers.panel")
local Button = require("widgets.buttons.button")
local Label = require("widgets.display.label")

-- Create main panel (10×10 grid cells = 240×240 pixels)
local panel = Panel.new(0, 0, 240, 240)
panel:setBackgroundColor("background")
panel:setBorderColor("primary")

-- Add title label
local title = Label.new(24, 24, 192, 24, "Settings")
panel:addChild(title)

-- Add buttons
local btnOK = Button.new(48, 192, 96, 48, "OK")
local btnCancel = Button.new(168, 192, 96, 48, "Cancel")
panel:addChild(btnOK)
panel:addChild(btnCancel)

-- In love.draw()
function love.draw()
    panel:draw()
end
```

## Grid Examples

```lua
-- Small info panel (4×3 cells = 96×72 pixels)
local infoPanel = Panel.new(0, 0, 96, 72)

-- Sidebar panel (8×30 cells = 192×720 pixels)
local sidebar = Panel.new(0, 0, 192, 720)

-- Full screen panel (40×30 cells = 960×720 pixels)
local fullscreen = Panel.new(0, 0, 960, 720)

-- Dialog background (16×12 cells = 384×288 pixels)
local dialog = Panel.new(288, 216, 384, 288)  -- Centered
```

## Theme Integration

```lua
-- Use theme colors
local panel = Panel.new(0, 0, 240, 240)

-- Dark theme
panel:setBackgroundColor("backgroundDark")
panel:setBorderColor("border")

-- Light theme
panel:setBackgroundColor("backgroundLight")
panel:setBorderColor("text")

-- Transparent overlay
panel.backgroundColor = {r=0, g=0, b=0, a=0.5}
```

## Common Use Cases

### Dialog Background
```lua
local dialogBg = Panel.new(240, 120, 480, 480)
dialogBg:setBackgroundColor("background")
dialogBg.showBorder = true
```

### Status Bar
```lua
local statusBar = Panel.new(0, 696, 960, 24)
statusBar:setBackgroundColor("backgroundDark")
statusBar.showBorder = false
```

### Inventory Slot
```lua
local slot = Panel.new(0, 0, 48, 48)
slot:setBackgroundColor("backgroundLight")
slot:setBorderColor("border")
```

## See Also

- [Window](window.md) - Draggable panel with title bar
- [Container](container.md) - Panel with automatic layout
- [Dialog](dialog.md) - Modal dialog with buttons
- [BaseWidget](../core/README.md) - Base widget class
