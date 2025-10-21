# Dialog Widget

Modal dialog with title, message, and buttons.

## Purpose

Dialog displays modal messages with OK/Cancel buttons. Blocks interaction with background until dismissed.

## Constructor

```lua
local Dialog = require("widgets.containers.dialog")
local dialog = Dialog.new(title, message, buttons)
```

### Parameters

- **title** (string): Dialog title
- **message** (string): Dialog message text
- **buttons** (table): Array of button configs {text, callback}

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `title` | string | "" | Dialog title |
| `message` | string | "" | Message text |
| `modal` | boolean | true | Blocks background interaction |
| `overlay` | boolean | true | Shows dark overlay |

## Methods

### show()
Display the dialog.

### close()
Hide the dialog.

### setMessage(message)
Update message text.

## Example

```lua
local dialog = Dialog.new(
    "Confirm Delete",
    "Are you sure you want to delete this file?",
    {
        {text = "Delete", callback = function() deleteFile() end},
        {text = "Cancel", callback = function() dialog:close() end}
    }
)
dialog:show()
```
