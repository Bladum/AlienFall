# Slider Widget

Draggable slider for numeric value selection.

## Purpose

Slider provides visual control for selecting numeric values within a range. Used for volume, brightness, difficulty, and continuous values.

## Constructor

```lua
local Slider = require("widgets.input.slider")
local slider = Slider.new(x, y, width, height, min, max, value)
```

### Parameters

- **x** (number): X position (multiple of 24)
- **y** (number): Y position (multiple of 24)
- **width** (number): Slider width (multiple of 24)
- **height** (number): Slider height (typically 24)
- **min** (number): Minimum value
- **max** (number): Maximum value
- **value** (number, optional): Initial value

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `value` | number | min | Current value |
| `min` | number | 0 | Minimum value |
| `max` | number | 100 | Maximum value |
| `step` | number | 1 | Value increment |
| `showValue` | boolean | true | Display value text |
| `onChange` | function | nil | Value change callback |

## Methods

### setValue(value)
Set slider value.

### getValue()
Get current value.

### setRange(min, max)
Change min/max range.

### setStep(step)
Set increment step.

## Example

```lua
-- Volume slider
local volume = Slider.new(24, 24, 240, 24, 0, 100, 75)
volume:setOnChange(function(value)
    love.audio.setVolume(value / 100)
end)

-- Difficulty slider
local difficulty = Slider.new(24, 72, 240, 24, 1, 10, 5)
difficulty:setStep(1)
difficulty:setOnChange(function(value)
    game.difficulty = value
end)
```
