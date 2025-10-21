# Tooltip Widget

Hover popup with information text.

## Purpose

Tooltip displays helpful text when hovering over widgets. Provides context and instructions without cluttering UI.

## Constructor

```lua
local Tooltip = require("widgets.display.tooltip")
local tooltip = Tooltip.new(text)
```

### Parameters

- **text** (string): Tooltip text content

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `text` | string | "" | Tooltip content |
| `delay` | number | 0.5 | Seconds before showing |
| `maxWidth` | number | 240 | Max width in pixels |
| `backgroundColor` | string | "backgroundDark" | Theme color |

## Methods

### show(x, y)
Display tooltip at position.

### hide()
Hide tooltip.

### setText(text)
Update tooltip content.

## Example

```lua
local tooltip = Tooltip.new("Click to save your progress")

function button:mousemoved(x, y)
    if self:containsPoint(x, y) then
        tooltip:show(x + 10, y + 10)
    else
        tooltip:hide()
    end
end
```
