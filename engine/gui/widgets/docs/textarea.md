# TextArea Widget

Multi-line text input with scrolling.

## Purpose

TextArea provides multi-line text editing with word wrap and scrolling. Used for notes, descriptions, and large text content.

## Constructor

```lua
local TextArea = require("widgets.input.textarea")
local textarea = TextArea.new(x, y, width, height)
```

### Parameters

- **x** (number): X position (multiple of 24)
- **y** (number): Y position (multiple of 24)
- **width** (number): Width (multiple of 24)
- **height** (number): Height (multiple of 24)

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `text` | string | "" | Current text content |
| `maxLength` | number | 1000 | Max character limit |
| `wordWrap` | boolean | true | Wrap long lines |
| `scrollOffset` | number | 0 | Vertical scroll position |
| `onChange` | function | nil | Text change callback |

## Methods

### setText(text)
Set text content.

### getText()
Get current text.

### append(text)
Add text to end.

### clear()
Clear all text.

## Example

```lua
local notes = TextArea.new(24, 24, 480, 360)
notes:setText("Enter your notes here...")
notes:setOnChange(function(text)
    saveNotes(text)
end)
```
