# Button Widget

Standard clickable button with text label and event handling.

## Constructor

```lua
Button.new(x, y, width, height, text)
```

### Parameters

- `x` (number): X position in pixels (auto-snapped to 24px grid)
- `y` (number): Y position in pixels (auto-snapped to 24px grid)
- `width` (number): Width in pixels (auto-snapped to 24px grid)
- `height` (number): Height in pixels (auto-snapped to 24px grid)
- `text` (string): Button label text

### Grid Coordinates

You can also think in grid cells (24×24 pixels):
- Grid position (5, 3) = Pixel position (120, 72)
- Grid size (4, 2) = Pixel size (96, 48)

## Properties

### Public Properties

- `text` (string): Button label (mutable)
- `enabled` (boolean): Whether button accepts input (default: true)
- `visible` (boolean): Whether button is rendered (default: true)
- `hovered` (boolean): Read-only, true when mouse over button
- `pressed` (boolean): Read-only, true while mouse button held down

### Inherited from BaseWidget

- `x`, `y` (number): Position in pixels
- `width`, `height` (number): Size in pixels
- `backgroundColor` (table): Normal state color from theme
- `hoverColor` (table): Hover state color from theme
- `activeColor` (table): Pressed state color from theme
- `disabledColor` (table): Disabled state color from theme

## Events

### onClick()

Called when button is clicked (mouse button released over button).

```lua
button.onClick = function()
    print("Button clicked!")
end
```

### onHover()

Called when mouse enters button area.

```lua
button.onHover = function()
    print("Mouse entered button")
end
```

### onLeave()

Called when mouse exits button area.

```lua
button.onLeave = function()
    print("Mouse left button")
end
```

## Methods

### setText(text)

Updates the button label.

```lua
button:setText("New Label")
```

### setCallback(func)

Sets the onClick callback (alternative to assigning onClick directly).

```lua
button:setCallback(function()
    print("Clicked!")
end)
```

### setEnabled(enabled)

Enables or disables the button.

```lua
button:setEnabled(false) -- Disable button
button:setEnabled(true)  -- Enable button
```

### draw()

Renders the button. Called automatically by widget system.

```lua
button:draw()
```

### mousepressed(x, y, mouseButton)

Handles mouse press events. Called automatically by widget system.

### mousereleased(x, y, mouseButton)

Handles mouse release events (triggers onClick). Called automatically.

### mousemoved(x, y, dx, dy)

Handles mouse movement for hover detection. Called automatically.

## Complete Example

```lua
local widgets = require("widgets")
widgets.init()

-- Create button at grid position (5, 3) with size (4, 2) grid cells
-- Pixel position: (120, 72), size: (96, 48)
local saveButton = widgets.Button.new(120, 72, 96, 48, "Save Game")

-- Set click handler
saveButton.onClick = function()
    print("Saving game...")
    saveGame()
    print("Game saved!")
end

-- Hover effects
saveButton.onHover = function()
    playSound("ui_hover")
end

-- Conditional enabling
function love.update(dt)
    saveButton:setEnabled(canSaveGame())
end

function love.draw()
    saveButton:draw()
end

function love.mousepressed(x, y, button)
    saveButton:mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
    saveButton:mousereleased(x, y, button)
end

function love.mousemoved(x, y, dx, dy)
    saveButton:mousemoved(x, y, dx, dy)
end
```

## Grid Position Helper

Use grid coordinates instead of pixels for easier layout:

```lua
-- Helper function to convert grid to pixels
local function gridPos(col, row)
    return col * 24, row * 24
end

local function gridSize(cols, rows)
    return cols * 24, rows * 24
end

-- Create button at grid (10, 5) with size (6, 2)
local x, y = gridPos(10, 5)
local w, h = gridSize(6, 2)
local button = widgets.Button.new(x, y, w, h, "Click Me")
```

## Styling

Buttons use the theme system. To customize colors:

```lua
local theme = require("widgets.core.theme")

-- Modify theme colors globally
theme.colors.primary = {r = 100, g = 150, b = 200, a = 255}
theme.colors.primaryHover = {r = 120, g = 170, b = 220, a = 255}

-- Or modify individual button colors
button.backgroundColor = {r = 50, g = 100, b = 150, a = 255}
button.hoverColor = {r = 70, g = 120, b = 170, a = 255}
```

## Common Use Cases

### Menu Buttons

```lua
local x, y = 360, 300 -- Center of screen
local spacing = 60

local startButton = Button.new(x, y, 240, 48, "Start Game")
startButton.onClick = function() StateManager.switch("game") end

local optionsButton = Button.new(x, y + spacing, 240, 48, "Options")
optionsButton.onClick = function() StateManager.switch("options") end

local quitButton = Button.new(x, y + spacing * 2, 240, 48, "Quit")
quitButton.onClick = function() love.event.quit() end
```

### Confirmation Dialog

```lua
local okButton = Button.new(300, 400, 120, 48, "OK")
okButton.onClick = function()
    dialog:close()
    confirmAction()
end

local cancelButton = Button.new(450, 400, 120, 48, "Cancel")
cancelButton.onClick = function()
    dialog:close()
end
```

### Toggle-Style Button

```lua
local muteButton = Button.new(10, 10, 96, 48, "Mute")
local isMuted = false

muteButton.onClick = function()
    isMuted = not isMuted
    if isMuted then
        muteButton:setText("Unmute")
        audio.muteAll()
    else
        muteButton:setText("Mute")
        audio.unmuteAll()
    end
end
```

## See Also

- [ImageButton](imagebutton.md) - Button with icon instead of text
- [ToggleButton](togglebutton.md) - Button that stays pressed (checkbox style)
- [Panel](../containers/panel.md) - Background container for buttons
- [Theme System](../core/theme.md) - Styling and colors
