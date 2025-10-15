# ImageButton Widget

Button with image icon instead of text.

## Purpose

ImageButton displays clickable image, used for icons, toolbar buttons, and visual commands.

## Constructor

```lua
local ImageButton = require("widgets.buttons.imagebutton")
local button = ImageButton.new(x, y, width, height, imagePath)
```

### Parameters

- **x** (number): X position (multiple of 24)
- **y** (number): Y position (multiple of 24)
- **width** (number): Button width (multiple of 24)
- **height** (number): Button height (multiple of 24)
- **imagePath** (string): Path to image asset

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `image` | Image | nil | Love2D image object |
| `imageScale` | number | 1.0 | Image scale factor |
| `tooltip` | string | nil | Hover tooltip text |
| `onClick` | function | nil | Click callback |

## Methods

### setImage(imagePath)
Change button image.

### setTooltip(text)
Set hover tooltip.

### setOnClick(callback)
Set click handler.

## Example

```lua
local btnSave = ImageButton.new(24, 24, 48, 48, "icons/save.png")
btnSave:setTooltip("Save File")
btnSave:setOnClick(function() saveFile() end)
```
