# ProgressBar Widget

Visual progress indicator with fill level and optional label.

## Purpose

ProgressBar displays progress from 0-100% with colored fill bar. Used for health, experience, loading progress, resource levels, and time remaining. Supports horizontal/vertical orientation and custom colors.

## Constructor

```lua
local ProgressBar = require("widgets.display.progressbar")
local bar = ProgressBar.new(x, y, width, height, value, maxValue)
```

### Parameters

- **x** (number): X position in pixels (multiple of 24)
- **y** (number): Y position in pixels (multiple of 24)
- **width** (number): Bar width in pixels (multiple of 24)
- **height** (number): Bar height in pixels (multiple of 24)
- **value** (number, optional): Current value (default: 0)
- **maxValue** (number, optional): Maximum value (default: 100)

### Returns

- **ProgressBar**: New progress bar instance

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `value` | number | 0 | Current progress value |
| `maxValue` | number | 100 | Maximum value for 100% |
| `fillColor` | string | "primary" | Theme color for filled portion |
| `backgroundColor` | string | "backgroundDark" | Theme color for empty portion |
| `borderColor` | string | "border" | Theme color for border |
| `showBorder` | boolean | true | Whether to draw border |
| `showLabel` | boolean | true | Whether to show percentage text |
| `orientation` | string | "horizontal" | "horizontal" or "vertical" |
| `labelFormat` | string | "%.0f%%" | Printf format for label |

## Methods

### setValue(value)

Set current progress value.

```lua
bar:setValue(75)  -- 75%
```

**Parameters:**
- value (number): New progress value (0 to maxValue)

### setMaxValue(maxValue)

Change maximum value.

```lua
bar:setMaxValue(200)  -- Now 0-200 range
```

**Parameters:**
- maxValue (number): New maximum value

### getPercent()

Get progress as percentage (0-100).

```lua
local percent = bar:getPercent()  -- Returns 75 for 75/100
```

**Returns:**
- number: Percentage value (0-100)

### setFillColor(colorName)

Set fill bar color using theme.

```lua
bar:setFillColor("success")  -- Green
bar:setFillColor("danger")   -- Red
bar:setFillColor("warning")  -- Yellow
```

**Parameters:**
- colorName (string): Theme color name

### setOrientation(orientation)

Set bar orientation.

```lua
bar:setOrientation("vertical")
bar:setOrientation("horizontal")
```

**Parameters:**
- orientation (string): "horizontal" or "vertical"

### draw()

Render progress bar.

```lua
bar:draw()
```

## Events

No direct events. Use value changes to trigger logic.

## Complete Example

```lua
local ProgressBar = require("widgets.display.progressbar")

-- Health bar (red, horizontal)
local healthBar = ProgressBar.new(24, 24, 192, 24, 80, 100)
healthBar:setFillColor("danger")
healthBar.labelFormat = "%d/%d HP"

-- Experience bar (blue, horizontal)
local expBar = ProgressBar.new(24, 72, 192, 12, 450, 1000)
expBar:setFillColor("primary")
expBar.showLabel = false

-- Loading bar (green, centered)
local loadBar = ProgressBar.new(288, 360, 384, 24, 0, 100)
loadBar:setFillColor("success")
loadBar.labelFormat = "Loading... %.0f%%"

-- Ammo counter (vertical, yellow)
local ammoBar = ProgressBar.new(912, 100, 24, 200, 15, 30)
ammoBar:setOrientation("vertical")
ammoBar:setFillColor("warning")

-- In love.update(dt)
function love.update(dt)
    -- Animate loading
    local current = loadBar.value + (dt * 20)
    if current > 100 then current = 0 end
    loadBar:setValue(current)
end

-- In love.draw()
function love.draw()
    healthBar:draw()
    expBar:draw()
    loadBar:draw()
    ammoBar:draw()
end
```

## Grid Examples

```lua
-- Standard health bar (8×1 cells = 192×24 pixels)
local hp = ProgressBar.new(24, 24, 192, 24)

-- Wide loading bar (16×1 cells = 384×24 pixels)
local loading = ProgressBar.new(288, 360, 384, 24)

-- Thin XP bar (8×0.5 cells = 192×12 pixels)
local xp = ProgressBar.new(24, 72, 192, 12)

-- Vertical ammo (1×8 cells = 24×192 pixels)
local ammo = ProgressBar.new(912, 100, 24, 192)
ammo:setOrientation("vertical")
```

## Color-Coded Health

```lua
function updateHealthBar(unit)
    local percent = unit.hp / unit.maxHp * 100
    
    if percent > 66 then
        healthBar:setFillColor("success")  -- Green
    elseif percent > 33 then
        healthBar:setFillColor("warning")  -- Yellow
    else
        healthBar:setFillColor("danger")   -- Red
    end
    
    healthBar:setValue(unit.hp)
    healthBar:setMaxValue(unit.maxHp)
end
```

## Custom Formatting

```lua
-- Percentage
bar.labelFormat = "%.0f%%"  -- "75%"

-- Fraction
bar.labelFormat = "%d/%d"   -- "75/100"

-- No decimals
bar.labelFormat = "%.0f"    -- "75"

-- With text
bar.labelFormat = "HP: %d"  -- "HP: 75"

-- No label
bar.showLabel = false
```

## Animation Example

```lua
local bar = ProgressBar.new(24, 24, 192, 24, 100, 100)
local targetValue = 100
local currentValue = 100

function updateHealth(newValue)
    targetValue = newValue
end

function love.update(dt)
    -- Smooth transition
    if currentValue ~= targetValue then
        local diff = targetValue - currentValue
        local change = diff * dt * 5  -- Speed factor
        currentValue = currentValue + change
        
        if math.abs(diff) < 1 then
            currentValue = targetValue
        end
        
        bar:setValue(currentValue)
    end
end
```

## Resource Bars

```lua
-- Time remaining
local timer = ProgressBar.new(24, 24, 192, 24, 60, 60)
timer:setFillColor("warning")
timer.labelFormat = "%.1fs"

-- Shield charge
local shield = ProgressBar.new(24, 72, 192, 12, 50, 100)
shield:setFillColor("primary")
shield.showLabel = false

-- Energy reserves
local energy = ProgressBar.new(24, 96, 192, 24, 80, 100)
energy:setFillColor("info")
energy.labelFormat = "Energy: %.0f%%"
```

## See Also

- [HealthBar](healthbar.md) - Specialized health bar widget
- [StatBar](stat_bar.md) - Stat display with icon
- [Label](label.md) - Text display
- [Panel](panel.md) - Background container
