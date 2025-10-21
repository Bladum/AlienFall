# Advanced Widgets

Complex UI components for advanced interactions.

## Overview

Advanced widgets provide sophisticated UI functionality for dialogs, tooltips, context menus, and other complex interface elements.

## Files

### dialog.lua
Modal dialog windows with title bars, content areas, and action buttons.

### tooltip.lua
Hover tooltips with rich text and positioning logic.

### context_menu.lua
Right-click context menus with hierarchical options.

### dropdown.lua
Dropdown selection widgets with list navigation.

### slider.lua
Value sliders for numeric input and settings.

## Usage

```lua
local Dialog = require("widgets.advanced.dialog")

local confirmDialog = Dialog:new({
    title = "Confirm Deployment",
    message = "Send interceptor to this province?",
    buttons = {
        {text = "Yes", action = function() deploy() end},
        {text = "No", action = function() end}
    }
})

confirmDialog:show()
```

## Features

- **Modal Dialogs**: Block input until dismissed
- **Rich Tooltips**: Formatted text with icons
- **Context Menus**: Hierarchical menu systems
- **Dropdown Lists**: Keyboard and mouse navigation
- **Value Sliders**: Precise numeric input

## Dependencies

- **Base Widget**: Inherits from BaseWidget class
- **Theme System**: Consistent styling
- **Input System**: Mouse and keyboard handling
- **Font System**: Text rendering