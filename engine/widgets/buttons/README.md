# Button Widgets

Interactive button components for user input.

## Overview

Button widgets provide various clickable interface elements with different visual styles and behaviors.

## Files

### button.lua
Standard text button with hover and click states.

### imagebutton.lua
Button with background image and optional text overlay.

### togglebutton.lua
Two-state toggle button (on/off) with visual feedback.

### radiobutton.lua
Radio button for mutually exclusive selections.

### checkbox.lua
Checkbox for independent boolean selections.

## Usage

```lua
local Button = require("widgets.buttons.button")

local deployBtn = Button:new({
    x = 120, y = 72,
    width = 96, height = 48,
    text = "Deploy",
    onClick = function()
        print("Deploying mission...")
    end
})

-- Toggle button example
local ToggleButton = require("widgets.buttons.togglebutton")
local autoBtn = ToggleButton:new({
    x = 120, y = 144,
    width = 96, height = 48,
    text = "Auto",
    isToggled = false,
    onToggle = function(toggled)
        enableAutoMode(toggled)
    end
})
```

## Features

- **State Management**: Normal, hover, pressed, disabled states
- **Event Handling**: Click, hover, focus events
- **Visual Feedback**: Color changes and animations
- **Accessibility**: Keyboard navigation support
- **Theming**: Consistent styling across all buttons

## Dependencies

- **BaseWidget**: Grid positioning and event handling
- **Theme System**: Colors, fonts, and spacing
- **Input System**: Mouse and keyboard input