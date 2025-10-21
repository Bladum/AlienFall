# Container Widget

Layout container with automatic child positioning.

## Purpose

Container automatically arranges child widgets in rows or columns with spacing. Simplifies complex UI layouts by handling positioning logic automatically.

## Constructor

```lua
local Container = require("widgets.containers.container")
local container = Container.new(x, y, width, height, layout)
```

### Parameters

- **x** (number): X position (multiple of 24)
- **y** (number): Y position (multiple of 24)
- **width** (number): Container width (multiple of 24)
- **height** (number): Container height (multiple of 24)
- **layout** (string, optional): "vertical" or "horizontal" (default: "vertical")

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `layout` | string | "vertical" | "vertical" or "horizontal" |
| `spacing` | number | 8 | Spacing between children (pixels) |
| `padding` | number | 8 | Internal padding (pixels) |
| `children` | table | {} | Array of child widgets |

## Methods

### addChild(widget)
Add child widget with automatic positioning.

### setLayout(layout)
Change layout mode ("vertical" or "horizontal").

### setSpacing(spacing)
Set spacing between children.

### setPadding(padding)
Set internal padding.

## Example

```lua
local container = Container.new(24, 24, 240, 400, "vertical")
container:setSpacing(12)
container:addChild(Label.new(0, 0, 240, 24, "Title"))
container:addChild(Button.new(0, 0, 96, 48, "OK"))
container:addChild(Button.new(0, 0, 96, 48, "Cancel"))
```
