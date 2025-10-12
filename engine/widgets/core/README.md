# Core Widgets

Fundamental UI building blocks.

## Overview

Core widgets provide the basic components that other widgets build upon, including text display, images, and input fields.

## Files

### label.lua
Text display widget with font and color options.

### image.lua
Image display widget with scaling and positioning.

### textbox.lua
Single-line text input field.

### textarea.lua
Multi-line text input area.

### progressbar.lua
Visual progress indicator.

## Usage

```lua
local Label = require("widgets.core.label")

local titleLabel = Label:new({
    x = 24, y = 24,
    text = "XCOM Command",
    font = "title",
    color = theme.colors.primary
})

-- Progress bar for mission completion
local ProgressBar = require("widgets.core.progressbar")
local progress = ProgressBar:new({
    x = 24, y = 72,
    width = 192, height = 24,
    value = 0.75,  -- 75% complete
    showText = true
})
```

## Features

- **Text Rendering**: Multiple fonts and colors
- **Image Display**: Scaling, rotation, and effects
- **Text Input**: Keyboard input with validation
- **Progress Display**: Visual feedback for operations
- **Accessibility**: Screen reader support

## Text System

- **Fonts**: Predefined font sets (title, body, small)
- **Colors**: Theme-based color palette
- **Alignment**: Left, center, right justification
- **Wrapping**: Automatic text wrapping

## Dependencies

- **BaseWidget**: Grid positioning and event handling
- **Theme System**: Colors and fonts
- **Asset System**: Font and image loading