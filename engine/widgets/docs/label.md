# Label Widget

Text display widget with alignment and styling options.

## Constructor

```lua
Label.new(x, y, width, height, text, alignment)
```

### Parameters

- `x` (number): X position in pixels (auto-snapped to 24px grid)
- `y` (number): Y position in pixels (auto-snapped to 24px grid)
- `width` (number): Width in pixels (auto-snapped to 24px grid)
- `height` (number): Height in pixels (for centering, auto-snapped)
- `text` (string): Label text content
- `alignment` (string, optional): "left", "center", or "right" (default: "left")

## Properties

### Public Properties

- `text` (string): Label content (mutable)
- `alignment` (string): Text alignment - "left", "center", "right"
- `visible` (boolean): Whether label is rendered (default: true)
- `color` (table): Text color {r, g, b, a} (default: from theme)
- `font` (Font): Love2D font object (default: from theme)

### Inherited from BaseWidget

- `x`, `y` (number): Position in pixels
- `width`, `height` (number): Size in pixels

## Methods

### setText(text)

Updates the label text.

```lua
label:setText("New text")
```

### setAlignment(alignment)

Changes text alignment.

```lua
label:setAlignment("center")
label:setAlignment("left")
label:setAlignment("right")
```

### setColor(r, g, b, a)

Sets text color.

```lua
label:setColor(255, 0, 0, 255) -- Red text
```

### draw()

Renders the label. Called automatically by widget system.

## Complete Example

```lua
local widgets = require("widgets")
widgets.init()

-- Title label (centered)
local titleLabel = widgets.Label.new(0, 24, 960, 48, "AlienFall", "center")
titleLabel.font = love.graphics.newFont(32)
titleLabel:setColor(255, 255, 255, 255)

-- Status label (left-aligned)
local statusLabel = widgets.Label.new(10, 680, 400, 24, "Ready", "left")

-- Score label (right-aligned)
local scoreLabel = widgets.Label.new(560, 10, 390, 24, "Score: 0", "right")

-- Update score
function updateScore(points)
    scoreLabel:setText("Score: " .. points)
end

function love.draw()
    titleLabel:draw()
    statusLabel:draw()
    scoreLabel:draw()
end
```

## Grid Position Helper

```lua
local function gridPos(col, row)
    return col * 24, row * 24
end

-- Label at grid (5, 2) spanning 10 columns
local x, y = gridPos(5, 2)
local w, h = 10 * 24, 24
local label = widgets.Label.new(x, y, w, h, "Health: 100/100", "left")
```

## Styling

### Font Sizes

```lua
label.font = love.graphics.newFont(12) -- Small
label.font = love.graphics.newFont(16) -- Default
label.font = love.graphics.newFont(24) -- Large
label.font = love.graphics.newFont(32) -- Title
```

### Colors

```lua
-- White text
label:setColor(255, 255, 255, 255)

-- Red warning
label:setColor(255, 0, 0, 255)

-- Green success
label:setColor(0, 255, 0, 255)

-- Semi-transparent
label:setColor(255, 255, 255, 128)
```

## Common Use Cases

### HUD Elements

```lua
-- Health display
local healthLabel = Label.new(10, 10, 200, 24, "HP: 100/100", "left")
healthLabel:setColor(0, 255, 0, 255)

function updateHealth(current, max)
    healthLabel:setText("HP: " .. current .. "/" .. max)
    
    -- Color based on health percentage
    local percent = current / max
    if percent > 0.5 then
        healthLabel:setColor(0, 255, 0, 255) -- Green
    elseif percent > 0.25 then
        healthLabel:setColor(255, 255, 0, 255) -- Yellow
    else
        healthLabel:setColor(255, 0, 0, 255) -- Red
    end
end
```

### Dynamic Text

```lua
local messageLabel = Label.new(200, 300, 560, 48, "", "center")

function showMessage(text, duration)
    messageLabel:setText(text)
    messageLabel.visible = true
    
    timer = duration
end

function love.update(dt)
    if timer and timer > 0 then
        timer = timer - dt
        if timer <= 0 then
            messageLabel.visible = false
        end
    end
end
```

### Form Labels

```lua
-- Label next to text input
local nameLabel = Label.new(100, 200, 150, 24, "Player Name:", "right")
local nameInput = TextInput.new(260, 200, 300, 24, "Enter name...")

-- Label above list
local itemsLabel = Label.new(100, 250, 300, 24, "Inventory Items:", "left")
local itemsList = ListBox.new(100, 280, 300, 200)
```

### Multi-line Text (Workaround)

Labels are single-line. For multi-line, use multiple labels:

```lua
local lines = {
    "Welcome to AlienFall!",
    "Defend Earth from alien invasion.",
    "Good luck, Commander."
}

local labels = {}
local startY = 200
for i, line in ipairs(lines) do
    local y = startY + (i - 1) * 30
    labels[i] = Label.new(200, y, 560, 24, line, "center")
end

function love.draw()
    for _, label in ipairs(labels) do
        label:draw()
    end
end
```

Or use TextArea widget for true multi-line text.

## Performance Note

Labels are very lightweight. You can have hundreds on screen with no performance impact.

## See Also

- [TextInput](../input/textinput.md) - Editable text field
- [TextArea](../input/textarea.md) - Multi-line text editing
- [Panel](../containers/panel.md) - Background for labels
- [Theme System](../core/theme.md) - Font and color management
