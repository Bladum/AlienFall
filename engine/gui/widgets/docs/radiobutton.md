# RadioButton Widget

Mutually exclusive selection buttons in a group.

## Purpose

RadioButton provides single-choice selection from multiple options. Only one button in group can be selected at a time.

## Constructor

```lua
local RadioButton = require("widgets.input.radiobutton")
local radio = RadioButton.new(x, y, label, groupName)
```

### Parameters

- **x** (number): X position (multiple of 24)
- **y** (number): Y position (multiple of 24)
- **label** (string): Button label text
- **groupName** (string): Group identifier (buttons with same group are mutually exclusive)

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `selected` | boolean | false | Selection state |
| `label` | string | "" | Label text |
| `groupName` | string | "" | Group identifier |
| `onChange` | function | nil | Selection callback |

## Methods

### setSelected(selected)
Set selection state (deselects others in group).

### setOnChange(callback)
Set selection callback.

## Example

```lua
-- Difficulty selection
local easy = RadioButton.new(24, 24, "Easy", "difficulty")
local normal = RadioButton.new(24, 72, "Normal", "difficulty")
local hard = RadioButton.new(24, 120, "Hard", "difficulty")

normal:setSelected(true)  -- Default

easy:setOnChange(function()
    game.difficulty = "easy"
end)
```
