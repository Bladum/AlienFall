# Widgets Directory - Reusable UI Components

## Overview

The `widgets/` directory contains reusable UI components that can be used across different scenes and game modes. These widgets provide consistent interaction patterns and styling, following the 20x20 pixel grid system for pixel-perfect alignment.

## Core Widget Classes

### Basic Widgets

#### `Button.lua`

**Purpose**: Clickable button component

- Text or image display
- Click and hover states
- Callback functions
- Keyboard navigation support

**GROK**: Basic interactive button - handles clicks and provides feedback

#### `Button_old.lua`

**Purpose**: Legacy button implementation

- Deprecated button class
- Maintained for compatibility
- Should migrate to Button.lua

**GROK**: Legacy button - replace with Button.lua in new code

### Selection Widgets

#### `ComboBox.lua`

**Purpose**: Dropdown selection component

- Option list display
- Selection callbacks
- Keyboard navigation
- Expandable interface

**GROK**: Dropdown selector - allows choosing from multiple options

#### `RadioBox.lua`

**Purpose**: Radio button group component

- Multiple choice selection
- Mutual exclusion
- Group management
- Visual state indication

**GROK**: Radio button group - single selection from multiple options

### Display Widgets

#### `ScrollableListBox.lua`

**Purpose**: Scrollable list display

- Item list rendering
- Scrollbar functionality
- Selection handling
- Dynamic content support

**GROK**: Scrollable list - displays large datasets with scrolling

#### `Tooltip.lua`

**Purpose**: Contextual help display

- Mouse hover activation
- Rich text content
- Positioning logic
- Auto-hide functionality

**GROK**: Help tooltip - shows contextual information on hover

### Layout Widgets

#### `TopPanel.lua`

**Purpose**: Top status bar component

- Game status display
- Global information
- Persistent UI elements
- Screen header

**GROK**: Status bar - shows persistent game information

### Management Widgets

#### `SceneManager.lua`

**Purpose**: Scene management system

- Scene switching logic
- State preservation
- Scene stack management
- Transition handling

**GROK**: Scene controller - manages UI screen transitions

## Widget Architecture

### Base Widget Class

All widgets inherit from a base widget class:

```lua
Widget = class()

function Widget:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.visible = true
    self.enabled = true
end

function Widget:update(dt)
    -- Update widget state
end

function Widget:draw()
    if not self.visible then return end
    -- Draw widget
end

function Widget:containsPoint(x, y)
    return x >= self.x and x <= self.x + self.width and
           y >= self.y and y <= self.y + self.height
end
```

### Event Handling

Widgets handle user input events:

```lua
function Button:mousepressed(x, y, button)
    if self.enabled and self:containsPoint(x, y) then
        self.pressed = true
        return true  -- Event consumed
    end
    return false
end

function Button:mousereleased(x, y, button)
    if self.pressed and self:containsPoint(x, y) then
        self.pressed = false
        if self.onClick then
            self.onClick()
        end
        return true
    end
    self.pressed = false
    return false
end
```

### State Management

Widgets maintain visual and interaction states:

```lua
function Button:update(dt)
    local mouseX, mouseY = love.mouse.getPosition()
    self.hovered = self:containsPoint(mouseX, mouseY)

    if self.hovered and not self.wasHovered then
        if self.onHover then self.onHover() end
    end
    self.wasHovered = self.hovered
end
```

## Grid-Based Positioning

### Grid Constants

Widgets use grid-based positioning:

```lua
local GRID_SIZE = 20

function Widget:setGridPosition(gridX, gridY)
    self.x = gridX * GRID_SIZE
    self.y = gridY * GRID_SIZE
end

function Widget:setGridSize(gridWidth, gridHeight)
    self.width = gridWidth * GRID_SIZE
    self.height = gridHeight * GRID_SIZE
end
```

### Alignment Helpers

Widgets provide alignment utilities:

```lua
function Widget:centerHorizontally(containerWidth)
    self.x = (containerWidth - self.width) / 2
end

function Widget:centerVertically(containerHeight)
    self.y = (containerHeight - self.height) / 2
end
```

## Styling System

### Theme Integration

Widgets use a global theme system:

```lua
GUITheme = {
    colors = {
        normal = {0.8, 0.8, 0.8},
        hover = {1.0, 1.0, 1.0},
        pressed = {0.6, 0.6, 0.6},
        disabled = {0.4, 0.4, 0.4}
    },
    fonts = {
        default = love.graphics.newFont(16),
        small = love.graphics.newFont(12)
    }
}

function Button:getCurrentColor()
    if not self.enabled then
        return GUITheme.colors.disabled
    elseif self.pressed then
        return GUITheme.colors.pressed
    elseif self.hovered then
        return GUITheme.colors.hover
    else
        return GUITheme.colors.normal
    end
end
```

### Custom Styling

Widgets support custom styling:

```lua
function Button:setStyle(style)
    self.normalColor = style.normalColor or GUITheme.colors.normal
    self.hoverColor = style.hoverColor or GUITheme.colors.hover
    self.font = style.font or GUITheme.fonts.default
end
```

## Callback System

### Event Callbacks

Widgets support various callback functions:

```lua
button.onClick = function()
    print("Button clicked!")
end

button.onHover = function()
    tooltip:show("Click to continue")
end

comboBox.onSelectionChanged = function(selectedItem)
    print("Selected:", selectedItem)
end
```

### Callback Management

Widgets manage callback registration:

```lua
function Widget:setCallback(event, callback)
    self.callbacks = self.callbacks or {}
    self.callbacks[event] = callback
end

function Widget:triggerCallback(event, ...)
    if self.callbacks and self.callbacks[event] then
        self.callbacks[event](...)
    end
end
```

## Focus Management

### Keyboard Focus

Widgets handle keyboard focus:

```lua
function Widget:setFocus(focused)
    self.focused = focused
    if focused and self.onFocus then
        self.onFocus()
    elseif not focused and self.onBlur then
        self.onBlur()
    end
end

function Button:keypressed(key)
    if self.focused and key == "return" then
        self:triggerCallback("onClick")
        return true
    end
    return false
end
```

### Tab Navigation

Widgets support tab-based navigation:

```lua
function Container:getFocusableWidgets()
    local focusable = {}
    for _, child in ipairs(self.children) do
        if child.focusable then
            table.insert(focusable, child)
        end
    end
    return focusable
end

function Container:tabToNext()
    local focusable = self:getFocusableWidgets()
    local currentIndex = 1
    for i, widget in ipairs(focusable) do
        if widget.focused then
            currentIndex = i
            break
        end
    end

    local nextIndex = currentIndex % #focusable + 1
    focusable[currentIndex]:setFocus(false)
    focusable[nextIndex]:setFocus(true)
end
```

## Testing Strategy

### Widget Testing

Each widget tested for functionality:

- Rendering correctness
- Input handling
- State transitions
- Callback execution

### Integration Testing

Widgets tested in scene contexts:

- Scene integration
- Layout behavior
- Focus management
- Theme application

## Development Guidelines

### Creating New Widgets

1. **GROK**: Define widget purpose and interface
2. **GROK**: Inherit from base Widget class
3. **GROK**: Implement required methods (init, draw, update)
4. **GROK**: Add input handling methods
5. **GROK**: Use grid-based positioning
6. **GROK**: Support theming and callbacks

### Widget Design Principles

- **GROK**: Keep widgets focused and reusable
- **GROK**: Follow consistent naming conventions
- **GROK**: Provide clear visual feedback
- **GROK**: Handle edge cases gracefully
- **GROK**: Document callback parameters

### Performance Guidelines

- **GROK**: Minimize object creation in update/draw
- **GROK**: Cache expensive calculations
- **GROK**: Use object pooling for dynamic widgets
- **GROK**: Profile widget performance