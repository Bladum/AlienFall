# TextInput Widget

Single-line text input field with cursor, selection, and clipboard support.

## Constructor

```lua
TextInput.new(x, y, width, height, placeholder)
```

### Parameters

- `x` (number): X position in pixels (auto-snapped to 24px grid)
- `y` (number): Y position in pixels (auto-snapped to 24px grid)
- `width` (number): Width in pixels (auto-snapped to 24px grid)
- `height` (number): Height in pixels (auto-snapped to 24px grid)
- `placeholder` (string, optional): Placeholder text when empty

## Properties

### Public Properties

- `text` (string): Current input text (mutable)
- `placeholder` (string): Grayed text shown when empty
- `maxLength` (number): Maximum character count (default: nil/unlimited)
- `enabled` (boolean): Whether field accepts input (default: true)
- `visible` (boolean): Whether field is rendered (default: true)
- `focused` (boolean): Read-only, true when field has keyboard focus
- `cursorPosition` (number): Current cursor position (0 to #text)
- `password` (boolean): If true, displays *** instead of text (default: false)

## Events

### onTextChanged(newText)

Called whenever text changes (typing, paste, delete).

```lua
textInput.onTextChanged = function(text)
    print("New text: " .. text)
end
```

### onSubmit(text)

Called when Enter key pressed.

```lua
textInput.onSubmit = function(text)
    print("Submitted: " .. text)
    processInput(text)
end
```

### onFocus()

Called when input gains keyboard focus.

```lua
textInput.onFocus = function()
    print("Input focused")
end
```

### onBlur()

Called when input loses keyboard focus.

```lua
textInput.onBlur = function()
    print("Input unfocused")
    validateInput(textInput:getText())
end
```

## Methods

### setText(text)

Sets the input text programmatically.

```lua
textInput:setText("New value")
```

### getText()

Returns current input text.

```lua
local value = textInput:getText()
```

### clear()

Clears all text.

```lua
textInput:clear()
```

### setPlaceholder(text)

Updates placeholder text.

```lua
textInput:setPlaceholder("Enter username...")
```

### setMaxLength(length)

Sets maximum character count.

```lua
textInput:setMaxLength(20) -- Max 20 characters
textInput:setMaxLength(nil) -- Unlimited
```

### setPassword(enabled)

Toggles password mode (displays *** instead of text).

```lua
textInput:setPassword(true) -- Hide text
textInput:setPassword(false) -- Show text
```

### focus()

Gives keyboard focus to this input.

```lua
textInput:focus()
```

### blur()

Removes keyboard focus.

```lua
textInput:blur()
```

### draw()

Renders the text input. Called automatically.

## Complete Example

```lua
local widgets = require("widgets")
widgets.init()

-- Username input
local usernameInput = widgets.TextInput.new(200, 200, 300, 32, "Enter username...")
usernameInput:setMaxLength(15)
usernameInput.onTextChanged = function(text)
    -- Validate as user types
    if #text < 3 then
        usernameInput.borderColor = {r = 255, g = 0, b = 0, a = 255} -- Red
    else
        usernameInput.borderColor = {r = 0, g = 255, b = 0, a = 255} -- Green
    end
end

-- Password input
local passwordInput = widgets.TextInput.new(200, 250, 300, 32, "Enter password...")
passwordInput:setPassword(true)
passwordInput:setMaxLength(32)

-- Submit button
local submitButton = widgets.Button.new(200, 300, 300, 48, "Login")
submitButton.onClick = function()
    local username = usernameInput:getText()
    local password = passwordInput:getText()
    
    if #username >= 3 and #password >= 6 then
        attemptLogin(username, password)
    else
        showError("Invalid credentials")
    end
end

function love.draw()
    usernameInput:draw()
    passwordInput:draw()
    submitButton:draw()
end

function love.textinput(text)
    usernameInput:textinput(text)
    passwordInput:textinput(text)
end

function love.keypressed(key)
    usernameInput:keypressed(key)
    passwordInput:keypressed(key)
    
    -- Enter to submit
    if key == "return" then
        submitButton.onClick()
    end
end

function love.mousepressed(x, y, button)
    usernameInput:mousepressed(x, y, button)
    passwordInput:mousepressed(x, y, button)
    submitButton:mousepressed(x, y, button)
end
```

## Keyboard Shortcuts

When focused, TextInput supports:

- **Typing**: Inserts characters at cursor
- **Backspace**: Delete character before cursor
- **Delete**: Delete character at cursor
- **Left/Right Arrow**: Move cursor
- **Home**: Move cursor to start
- **End**: Move cursor to end
- **Ctrl+A**: Select all text
- **Ctrl+C**: Copy selected text
- **Ctrl+V**: Paste from clipboard
- **Ctrl+X**: Cut selected text
- **Enter**: Trigger onSubmit event
- **Escape**: Blur input (lose focus)

## Common Use Cases

### Search Bar

```lua
local searchInput = TextInput.new(10, 10, 400, 32, "Search...")
searchInput.onTextChanged = function(query)
    -- Real-time search
    filterResults(query)
end
```

### Form Field with Validation

```lua
local emailInput = TextInput.new(100, 150, 400, 32, "email@example.com")

emailInput.onBlur = function()
    local email = emailInput:getText()
    if not isValidEmail(email) then
        emailInput.borderColor = {r = 255, g = 0, b = 0, a = 255}
        showError("Invalid email address")
    else
        emailInput.borderColor = {r = 0, g = 255, b = 0, a = 255}
    end
end
```

### Chat Input

```lua
local chatInput = TextInput.new(10, 680, 740, 32, "Type message...")
chatInput:setMaxLength(200)

chatInput.onSubmit = function(message)
    if #message > 0 then
        sendChatMessage(message)
        chatInput:clear()
    end
end
```

### Number Input (Custom Validation)

```lua
local numberInput = TextInput.new(200, 200, 200, 32, "Enter number...")

numberInput.onTextChanged = function(text)
    -- Only allow digits
    local cleaned = text:gsub("[^0-9]", "")
    if cleaned ~= text then
        numberInput:setText(cleaned)
    end
end

function getNumber()
    local text = numberInput:getText()
    return tonumber(text) or 0
end
```

## Styling

```lua
-- Border color
textInput.borderColor = {r = 100, g = 100, b = 100, a = 255}

-- Background color
textInput.backgroundColor = {r = 40, g = 40, b = 40, a = 255}

-- Text color
textInput.textColor = {r = 255, g = 255, b = 255, a = 255}

-- Placeholder color
textInput.placeholderColor = {r = 150, g = 150, b = 150, a = 255}

-- Cursor color
textInput.cursorColor = {r = 255, g = 255, b = 255, a = 255}

-- Selection color
textInput.selectionColor = {r = 100, g = 150, b = 200, a = 128}
```

## Performance Note

TextInput handles text rendering efficiently. Multiple inputs on screen are fine.

## See Also

- [TextArea](textarea.md) - Multi-line text input
- [Label](../display/label.md) - Read-only text display
- [Button](button.md) - Submit buttons
- [Form Validation Example](../../examples/form_validation.lua)
