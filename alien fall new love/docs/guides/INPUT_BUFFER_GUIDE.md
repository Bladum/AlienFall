# Input Buffer System

## Table of Contents

1. [Overview](#overview)
2. [Features](#features)
3. [Basic Usage](#basic-usage)
4. [Integration with Love2D Callbacks](#integration-with-love2d-callbacks)
5. [Screen/Handler Implementation](#screenhandler-implementation)
6. [Priority System](#priority-system)
7. [Advanced Configuration](#advanced-configuration)
8. [Performance Monitoring](#performance-monitoring)
9. [Best Practices](#best-practices)
10. [Common Patterns](#common-patterns)
11. [Troubleshooting](#troubleshooting)

---

## Overview

The Input Buffer System prevents missed inputs during lag spikes or frame drops by buffering input events and processing them during the update loop. This ensures that player inputs are never lost, even during temporary performance issues.

## Features

- **Separate Buffers**: Keyboard and mouse inputs buffered separately
- **Priority System**: High, normal, and low priority inputs with smart dropping
- **Age Tracking**: Stale inputs automatically expire (default: 1 second)
- **Configurable**: Buffer size and expiration time can be customized
- **Statistics**: Track buffered, processed, and dropped inputs

## Basic Usage

### Initialization

```lua
local InputBuffer = require('core.input_buffer')

-- Create with default settings
local inputBuffer = InputBuffer:new()

-- Create with custom configuration
local inputBuffer = InputBuffer:new({
    maxBufferSize = 200,      -- Maximum buffer size (default: 100)
    maxInputAge = 0.5         -- Max age in seconds (default: 1.0)
})
```

### Integration with Love2D Callbacks

#### In main.lua

```lua
local InputBuffer = require('core.input_buffer')
local inputBuffer

function love.load()
    inputBuffer = InputBuffer:new()
end

-- Buffer keyboard events
function love.keypressed(key, scancode, isrepeat)
    local priorities = InputBuffer.getPriorities()
    
    -- ESC is high priority
    local priority = (key == "escape") and priorities.HIGH or priorities.NORMAL
    inputBuffer:bufferKeyboard("keypressed", key, scancode, isrepeat, priority)
end

function love.keyreleased(key, scancode)
    inputBuffer:bufferKeyboard("keyreleased", key, scancode)
end

function love.textinput(text)
    inputBuffer:bufferKeyboard("textinput", text)
end

-- Buffer mouse events
function love.mousepressed(x, y, button, istouch)
    inputBuffer:bufferMouse("mousepressed", x, y, button, istouch)
end

function love.mousereleased(x, y, button, istouch)
    inputBuffer:bufferMouse("mousereleased", x, y, button, istouch)
end

function love.mousemoved(x, y, dx, dy, istouch)
    local priorities = InputBuffer.getPriorities()
    -- Mouse moves are low priority (can be dropped if buffer full)
    inputBuffer:bufferMouse("mousemoved", x, y, nil, istouch, dx, dy, priorities.LOW)
end

function love.wheelmoved(x, y)
    inputBuffer:bufferMouse("wheelmoved", 0, 0, nil, false, x, y)
end

-- Process buffered inputs in update loop
function love.update(dt)
    -- Pass current screen or input handler
    local currentScreen = screenManager:getCurrentScreen()
    if currentScreen then
        inputBuffer:process(dt, currentScreen)
    end
end
```

### Screen/Handler Implementation

Your screens need to implement the appropriate input callback methods:

```lua
local GameScreen = class('GameScreen')

function GameScreen:keypressed(key, scancode, isrepeat)
    if key == "escape" then
        self:showPauseMenu()
    elseif key == "space" then
        self:endTurn()
    end
end

function GameScreen:keyreleased(key, scancode)
    -- Handle key release
end

function GameScreen:mousepressed(x, y, button, istouch)
    if button == 1 then
        self:handleClick(x, y)
    elseif button == 2 then
        self:handleRightClick(x, y)
    end
end

function GameScreen:mousereleased(x, y, button, istouch)
    -- Handle mouse release
end

function GameScreen:mousemoved(x, y, dx, dy, istouch)
    -- Handle mouse movement (e.g., cursor updates)
    self.mouseX = x
    self.mouseY = y
end

function GameScreen:wheelmoved(dx, dy)
    -- Handle mouse wheel (e.g., zoom, scroll)
    self:scrollView(dy * 20)
end
```

## Input Priority System

The buffer uses a three-tier priority system:

### High Priority (INPUT_PRIORITY.HIGH = 1)
- Never dropped from buffer
- Processed first
- Examples: ESC key, critical UI inputs

### Normal Priority (INPUT_PRIORITY.NORMAL = 2)
- Default priority level
- Dropped only if no low priority inputs available
- Examples: Most keyboard and mouse button inputs

### Low Priority (INPUT_PRIORITY.LOW = 3)
- Dropped first when buffer fills
- Good for frequent/redundant inputs
- Examples: Mouse move events, hover updates

### Priority Assignment Example

```lua
local priorities = InputBuffer.getPriorities()

-- High priority: critical inputs
inputBuffer:bufferKeyboard("keypressed", "escape", nil, false, priorities.HIGH)

-- Normal priority: regular gameplay inputs
inputBuffer:bufferKeyboard("keypressed", "space", nil, false, priorities.NORMAL)

-- Low priority: mouse movement (can be dropped)
inputBuffer:bufferMouse("mousemoved", x, y, nil, false, dx, dy, priorities.LOW)
```

## Buffer Management

### Clearing Buffers

```lua
-- Clear all buffers
inputBuffer:clear()

-- Clear keyboard buffer only
inputBuffer:clearKeyboard()

-- Clear mouse buffer only
inputBuffer:clearMouse()
```

### When to Clear Buffers

- **Scene transitions**: Clear buffers when switching screens
- **Modal dialogs**: Clear buffers when opening dialogs
- **Game pause/unpause**: Prevent buffered inputs from "leaking"
- **Combat phase changes**: Clear between player/enemy turns

```lua
function ScreenManager:setScreen(newScreen)
    -- Clear input buffer on screen change
    inputBuffer:clear()
    
    self.currentScreen = newScreen
    if newScreen.onEnter then
        newScreen:onEnter()
    end
end
```

## Performance Monitoring

### Getting Statistics

```lua
local stats = inputBuffer:getStatistics()

print("Total Buffered:", stats.totalBuffered)
print("Total Processed:", stats.totalProcessed)
print("Total Dropped:", stats.totalDropped)
print("Current Buffer Size:", stats.currentBufferSize)
print("Keyboard Buffer:", stats.keyboardBufferSize)
print("Mouse Buffer:", stats.mouseBufferSize)
print("Drop Rate:", stats.dropRate * 100, "%")
```

### Print Statistics to Console

```lua
-- Convenient formatted output
inputBuffer:printStatistics()

-- Output:
-- === Input Buffer Statistics ===
-- Total Buffered: 1523
-- Total Processed: 1498
-- Total Dropped: 25
-- Current Buffer: 12 (Keyboard: 3, Mouse: 9)
-- Drop Rate: 1.6%
-- ================================
```

### Monitoring Drop Rate

A high drop rate (>5%) indicates potential issues:

1. **Buffer too small**: Increase `maxBufferSize`
2. **Performance problems**: Optimize game loop
3. **Too many low priority inputs**: Reduce mouse move buffering frequency

## Advanced Usage

### Custom Input Handler

You can create a dedicated input handler instead of using screens directly:

```lua
local InputHandler = class('InputHandler')

function InputHandler:initialize(game)
    self.game = game
end

function InputHandler:keypressed(key, scancode, isrepeat)
    -- Route to appropriate system
    if self.game.ui:handleKey(key, scancode) then
        return
    end
    
    if self.game.combat:handleKey(key, scancode) then
        return
    end
    
    -- Fallback to global commands
    self:handleGlobalKey(key)
end

function InputHandler:mousepressed(x, y, button, istouch)
    -- Check UI first
    if self.game.ui:handleClick(x, y, button) then
        return
    end
    
    -- Then game world
    self.game.combat:handleClick(x, y, button)
end

-- In update loop
inputBuffer:process(dt, self.inputHandler)
```

### Conditional Buffering

Buffer inputs only during certain conditions:

```lua
function love.keypressed(key, scancode, isrepeat)
    -- Only buffer during gameplay
    if gameState == "PLAYING" then
        inputBuffer:bufferKeyboard("keypressed", key, scancode, isrepeat)
    else
        -- Process immediately for menus
        currentScreen:keypressed(key, scancode, isrepeat)
    end
end
```

### Throttling Mouse Movement

Reduce mouse move events to prevent buffer overflow:

```lua
local lastMouseMoveTime = 0
local MOUSE_MOVE_THROTTLE = 0.016 -- ~60 Hz

function love.mousemoved(x, y, dx, dy, istouch)
    local currentTime = love.timer.getTime()
    
    -- Only buffer mouse moves at 60 Hz max
    if (currentTime - lastMouseMoveTime) >= MOUSE_MOVE_THROTTLE then
        local priorities = InputBuffer.getPriorities()
        inputBuffer:bufferMouse("mousemoved", x, y, nil, istouch, dx, dy, priorities.LOW)
        lastMouseMoveTime = currentTime
    end
end
```

## Integration with Event System

Combine input buffer with EventBus for clean separation:

```lua
function InputHandler:keypressed(key, scancode, isrepeat)
    -- Emit events instead of direct calls
    if key == "escape" then
        EventBus:emit("game:pause")
    elseif key == "space" then
        EventBus:emit("combat:endTurn")
    end
end

-- Systems listen for events
EventBus:on("combat:endTurn", function()
    combatSystem:endPlayerTurn()
end)
```

## Testing

See `test/core/test_input_buffer.lua` for comprehensive test examples.

## Best Practices

1. **Use Priority Wisely**: Reserve HIGH priority for critical inputs only
2. **Clear on Transitions**: Always clear buffers when changing game states
3. **Monitor Drop Rate**: Check statistics during development
4. **Throttle Frequent Events**: Limit mouse movement buffering frequency
5. **Handle Missing Methods**: Check if handler implements callback before processing
6. **Age Appropriately**: Set max age based on game responsiveness needs
7. **Size Buffer Correctly**: Balance memory usage vs. lag tolerance

## Configuration Recommendations

### Fast-Paced Action Game
```lua
local inputBuffer = InputBuffer:new({
    maxBufferSize = 50,       -- Smaller buffer
    maxInputAge = 0.3         -- Shorter timeout
})
```

### Turn-Based Strategy Game
```lua
local inputBuffer = InputBuffer:new({
    maxBufferSize = 200,      -- Larger buffer
    maxInputAge = 2.0         -- Longer timeout OK
})
```

### Text Input / UI-Heavy Game
```lua
local inputBuffer = InputBuffer:new({
    maxBufferSize = 500,      -- Very large buffer
    maxInputAge = 1.5         -- Moderate timeout
})
```

## Troubleshooting

### Problem: Inputs feel delayed
**Solution**: Reduce `maxInputAge` or process buffer more frequently

### Problem: Inputs dropped frequently
**Solution**: Increase `maxBufferSize` or reduce low priority input volume

### Problem: Stale inputs after lag spike
**Solution**: Clear buffer when detecting performance issues

### Problem: Mouse movement jerky
**Solution**: Don't buffer mouse moves, or buffer with LOW priority and throttling

## Related Systems

- **EventBus** (`src/core/event_bus.lua`) - Event-driven input routing
- **ScreenManager** (`src/screens/screen_manager.lua`) - Screen transition management
- **Logger** (`src/utils/logger.lua`) - Debug logging for input issues

## References

- Love2D Input Callbacks: https://love2d.org/wiki/love.keyboard
- Love2D Mouse Input: https://love2d.org/wiki/love.mouse
- INPUT_PRIORITY constants available via `InputBuffer.getPriorities()`
