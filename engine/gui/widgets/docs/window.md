# Window Widget

Draggable window with title bar and close button.

## Purpose

Window provides a draggable panel with title bar, used for dialogs, tool windows, and floating panels.

## Constructor

```lua
local Window = require("widgets.containers.window")
local window = Window.new(x, y, width, height, title)
```

### Parameters

- **x** (number): X position (multiple of 24)
- **y** (number): Y position (multiple of 24)
- **width** (number): Window width (multiple of 24)
- **height** (number): Window height (multiple of 24)
- **title** (string): Window title text

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `title` | string | "" | Title bar text |
| `draggable` | boolean | true | Can be dragged |
| `closeable` | boolean | true | Shows close button |
| `isDragging` | boolean | false | Currently being dragged |
| `onClose` | function | nil | Close callback |

## Methods

### setTitle(title)
Change window title.

### close()
Close the window (calls onClose).

### setDraggable(draggable)
Enable/disable dragging.

### setCloseable(closeable)
Show/hide close button.

## Example

```lua
local window = Window.new(240, 120, 480, 360, "Settings")
window:setOnClose(function()
    print("Window closed")
end)
window:addChild(panel)
```
