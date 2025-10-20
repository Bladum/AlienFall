# AlienFall Core Module API

**Audience**: Developers | **Status**: Active | **Last Updated**: October 2025

Reference documentation for the core AlienFall engine systems and lifecycles.

---

## Table of Contents

- [Overview](#overview)
- [Main Entry Point](#main-entry-point)
- [Core Module Structure](#core-module-structure)
- [State Manager](#state-manager)
- [Asset Manager](#asset-manager)
- [Audio System](#audio-system)
- [Common Patterns](#common-patterns)
- [Examples](#examples)
- [Troubleshooting](#troubleshooting)

---

## Overview

The Core system manages:
- **Game lifecycle** (initialization, update, rendering)
- **State management** (scene transitions, game states)
- **Asset loading** (images, sounds, data files)
- **Audio playback** and sound effects
- **Event systems** for cross-module communication

**Key Files**:
- `engine/main.lua` - Entry point and main loop
- `engine/conf.lua` - Love2D configuration
- `engine/core/state_manager.lua` - State management
- `engine/core/assets.lua` - Asset management
- `engine/core/audio_system.lua` - Audio management

---

## Main Entry Point

### Love2D Lifecycle Callbacks

AlienFall uses standard Love2D callbacks:

#### `love.load()`

Called once when game starts. **Responsibilities**:
- Initialize all core systems
- Load initial assets
- Set up initial game state
- Configure window settings

**Location**: `engine/main.lua`

```lua
function love.load()
    -- Initialize core systems
    StateManager.init()
    AssetManager.init()
    AudioSystem.init()
    
    -- Load initial state
    StateManager.switchTo("main_menu")
    
    print("[Core] Engine loaded successfully")
end
```

#### `love.update(dt)`

Called every frame (dt = delta time in seconds). **Responsibilities**:
- Update game logic
- Process input
- Update current state
- Handle timing

**Parameters**:
- `dt` (number): Time elapsed since last update in seconds

```lua
function love.update(dt)
    -- Update current state
    if StateManager.currentState() then
        StateManager.currentState():update(dt)
    end
    
    -- Global input processing
    handleGlobalInput(dt)
end
```

#### `love.draw()`

Called every frame to render. **Responsibilities**:
- Clear screen
- Draw current state
- Draw UI overlay
- Draw debug info if enabled

```lua
function love.draw()
    -- Clear screen
    love.graphics.clear(0.1, 0.1, 0.1)  -- Dark gray background
    
    -- Draw current state
    if StateManager.currentState() then
        StateManager.currentState():draw()
    end
    
    -- Draw UI overlay
    UISystem.draw()
    
    -- Debug drawing
    if DEBUG_MODE then
        drawDebugInfo()
    end
end
```

#### `love.keypressed(key)`

Called when key pressed.

```lua
function love.keypressed(key)
    if key == "escape" then
        -- Handle escape key (pause/menu)
        StateManager.switchTo("pause_menu")
    end
    
    -- Pass to current state
    if StateManager.currentState() then
        StateManager.currentState():keypressed(key)
    end
end
```

#### `love.mousepressed(x, y, button)`

Called when mouse clicked.

```lua
function love.mousepressed(x, y, button)
    if button == 1 then  -- Left click
        -- Pass to current state
        if StateManager.currentState() then
            StateManager.currentState():mousepressed(x, y, button)
        end
    end
end
```

#### `love.quit()`

Called when game closes.

```lua
function love.quit()
    -- Save game state
    StateManager.saveState()
    
    -- Clean up resources
    AssetManager.cleanup()
    AudioSystem.cleanup()
    
    print("[Core] Engine shutting down...")
    return false  -- Return false to allow quit
end
```

---

## Core Module Structure

### Module Pattern

AlienFall core modules follow a consistent pattern:

```lua
-- modules/my_module.lua
local MyModule = {}

-- Private variables
local privateVar = 0

-- Public initialization
function MyModule.init()
    print("[MyModule] Initializing...")
    privateVar = 0
end

-- Public methods
function MyModule.publicMethod(param)
    return processData(param)
end

-- Private methods (not in public interface)
local function privateHelper()
    return "private"
end

-- Cleanup/shutdown
function MyModule.cleanup()
    print("[MyModule] Cleaning up...")
end

return MyModule
```

### Module Loading

Modules loaded in `main.lua`:

```lua
-- Load core systems
StateManager = require("core.state_manager")
AssetManager = require("core.assets")
AudioSystem = require("core.audio_system")

-- Load subsystems
Geoscape = require("geoscape.manager")
Basescape = require("basescape.manager")
Battlescape = require("battlescape.manager")
```

---

## State Manager

Manages game states and transitions.

### State Interface

Every state must implement:

```lua
local MyState = {}

function MyState.init()
    -- Initialize state
end

function MyState.enter()
    -- Called when entering this state
    print("[MyState] Entering state")
end

function MyState.exit()
    -- Called when leaving this state
    print("[MyState] Exiting state")
end

function MyState.update(dt)
    -- Update game logic for this state
end

function MyState.draw()
    -- Render state visuals
end

function MyState.keypressed(key)
    -- Handle keyboard input
end

function MyState.mousepressed(x, y, button)
    -- Handle mouse input
end

return MyState
```

### StateManager API

```lua
-- Switch to a new state
StateManager.switchTo("new_state_name")

-- Get current state
local state = StateManager.currentState()

-- Check current state
if StateManager.is("main_menu") then
    -- In main menu
end

-- Push state (save current, switch new, can return)
StateManager.push("pause_menu")

-- Pop state (return to previous state)
StateManager.pop()

-- Stack of states (for menus)
StateManager.getStack()

-- Save/load game state
StateManager.saveState()
StateManager.loadState()
```

### Example: Creating a New State

```lua
-- Create new file: engine/scenes/my_scene.lua
local MyScene = {}

function MyScene.init()
    print("[MyScene] Initialized")
end

function MyScene.enter()
    -- Load resources specific to this scene
    print("[MyScene] Entered")
end

function MyScene.exit()
    -- Clean up scene resources
    print("[MyScene] Exited")
end

function MyScene.update(dt)
    -- Update scene logic
end

function MyScene.draw()
    -- Draw scene
    love.graphics.print("My Scene", 100, 100)
end

function MyScene.keypressed(key)
    if key == "escape" then
        StateManager.pop()  -- Exit scene
    end
end

return MyScene
```

---

## Asset Manager

Manages loading and caching of game resources.

### Supported Asset Types

| Type | Extension | Function |
|------|-----------|----------|
| **Image** | .png, .jpg | `AssetManager.image(path)` |
| **Sound** | .ogg, .wav | `AssetManager.sound(path)` |
| **Font** | .ttf | `AssetManager.font(path, size)` |
| **Data** | .lua, .json | `AssetManager.data(path)` |

### AssetManager API

```lua
-- Load and cache image
local texture = AssetManager.image("assets/images/unit.png")
love.graphics.draw(texture, x, y)

-- Load and cache sound
local sfx = AssetManager.sound("assets/sounds/gunfire.ogg")
sfx:play()

-- Load and cache font
local font = AssetManager.font("assets/fonts/default.ttf", 24)
love.graphics.setFont(font)

-- Load data file (Lua)
local unitData = AssetManager.data("assets/data/units.lua")
print(unitData.soldier.hp)

-- Check if asset loaded
if AssetManager.hasImage("assets/images/unit.png") then
    local tex = AssetManager.getImage("assets/images/unit.png")
end

-- Get all loaded assets
local assets = AssetManager.getAll()

-- Clear cache (not recommended during gameplay)
AssetManager.clearCache()

-- Unload specific asset
AssetManager.unload("assets/images/unit.png")
```

### Asset Paths

All asset paths are relative to `engine/assets/`:

```lua
-- Example paths
"images/units/soldier.png"
"images/units/alien_snakeman.png"
"sounds/weapons/laser_rifle.ogg"
"data/units.lua"
"fonts/default.ttf"
```

### Asset Loading Pattern

```lua
-- In a state or module
function MyModule.init()
    -- Load assets once
    self.unitImage = AssetManager.image("images/units/soldier.png")
    self.fireSound = AssetManager.sound("sounds/weapons/gunfire.ogg")
    self.unitFont = AssetManager.font("fonts/default.ttf", 16)
end

function MyModule.draw()
    -- Use cached assets
    love.graphics.draw(self.unitImage, 100, 100)
    love.graphics.setFont(self.unitFont)
    love.graphics.print("Soldier", 100, 130)
end

function MyModule.fireWeapon()
    self.fireSound:play()
end
```

---

## Audio System

Manages sound playback and music.

### AudioSystem API

```lua
-- Play sound effect (one-shot)
AudioSystem.playSound("sounds/weapons/gunfire.ogg")

-- Play sound with parameters
AudioSystem.playSound("sounds/weapons/laser.ogg", {
    volume = 0.8,
    pitch = 1.0,
    loop = false
})

-- Play background music (loops)
AudioSystem.playMusic("sounds/music/battlescape.ogg")

-- Stop current music
AudioSystem.stopMusic()

-- Set music volume (0.0 to 1.0)
AudioSystem.setMusicVolume(0.5)

-- Set sound effects volume (0.0 to 1.0)
AudioSystem.setSoundVolume(0.7)

-- Pause/resume music
AudioSystem.pauseMusic()
AudioSystem.resumeMusic()

-- Check if music playing
if AudioSystem.isMusicPlaying() then
    -- Music is playing
end

-- Mute/unmute
AudioSystem.setMuted(true)
```

### Audio Configuration

**Sound effects**: Should be short, repeatable (gunfire, impacts)
**Music**: Longer, looping background tracks

---

## Common Patterns

### Error Handling

Use `pcall` for risky operations:

```lua
-- Safe function call
local success, result = pcall(riskyFunction, arg1, arg2)

if success then
    print("Result: " .. tostring(result))
else
    print("[ERROR] " .. result)  -- result is error message
end
```

### Timing and Delays

Track delays for scheduled events:

```lua
-- Simple delay counter
function MyModule.init()
    self.delayTimer = 0
    self.delayDuration = 1.0  -- 1 second
end

function MyModule.update(dt)
    if self.delayTimer > 0 then
        self.delayTimer = self.delayTimer - dt
        
        if self.delayTimer <= 0 then
            -- Delay finished
            print("Delay complete!")
        end
    end
end

-- Start a delay
function MyModule.startDelay()
    self.delayTimer = self.delayDuration
end
```

### Resource Management

Initialize and cleanup resources properly:

```lua
function MyModule.init()
    self.resources = {}
    self.resources.image = AssetManager.image("image.png")
    self.resources.sound = AssetManager.sound("sound.ogg")
end

function MyModule.cleanup()
    -- Release resources
    self.resources = nil
end
```

---

## Examples

### Example 1: Simple State

```lua
-- Create a simple main menu state
local MainMenu = {}

function MainMenu.init()
    MainMenu.buttons = {
        {x = 400, y = 200, w = 200, h = 50, label = "New Game"},
        {x = 400, y = 300, w = 200, h = 50, label = "Load Game"},
        {x = 400, y = 400, w = 200, h = 50, label = "Settings"},
        {x = 400, y = 500, w = 200, h = 50, label = "Quit"},
    }
end

function MainMenu.draw()
    love.graphics.setColor(1, 1, 1)
    
    for _, btn in ipairs(MainMenu.buttons) do
        love.graphics.rectangle("line", btn.x, btn.y, btn.w, btn.h)
        love.graphics.print(btn.label, btn.x + 10, btn.y + 15)
    end
end

function MainMenu.mousepressed(x, y, button)
    if button ~= 1 then return end
    
    for i, btn in ipairs(MainMenu.buttons) do
        if x >= btn.x and x <= btn.x + btn.w and
           y >= btn.y and y <= btn.y + btn.h then
            
            if i == 1 then
                StateManager.switchTo("geoscape")
            elseif i == 4 then
                love.event.quit()
            end
        end
    end
end

return MainMenu
```

### Example 2: Module with Initialization

```lua
-- Module with proper initialization pattern
local BattleSystem = {}

local activeUnits = {}
local battleState = "setup"

function BattleSystem.init()
    print("[BattleSystem] Initializing...")
    activeUnits = {}
    battleState = "setup"
end

function BattleSystem.startBattle(units)
    print("[BattleSystem] Starting battle with " .. #units .. " units")
    activeUnits = units
    battleState = "active"
end

function BattleSystem.update(dt)
    -- Update battle logic
    for _, unit in ipairs(activeUnits) do
        unit:update(dt)
    end
end

function BattleSystem.isActive()
    return battleState == "active"
end

function BattleSystem.endBattle()
    battleState = "complete"
    activeUnits = {}
end

function BattleSystem.cleanup()
    print("[BattleSystem] Cleaning up...")
    activeUnits = nil
end

return BattleSystem
```

---

## Troubleshooting

### "Module not found" Error

**Problem**: `require("module_name")` fails

**Causes**:
- File doesn't exist at path
- Path uses forward slashes but file uses backslashes
- Module isn't being initialized

**Solution**:
```lua
-- Check file exists
print(love.filesystem.getInfo("core/my_module.lua"))

-- Use consistent paths (forward slashes)
MyModule = require("core.my_module")

-- Verify in console output during load
```

### State Transition Not Working

**Problem**: `StateManager.switchTo()` called but state doesn't change

**Debug**:
```lua
-- Print current state
print("[Debug] Current state: " .. (StateManager.currentState() or "nil"))

-- Verify state is registered
StateManager.switchTo("valid_state_name")
```

### Assets Not Loading

**Problem**: Images/sounds don't appear or play

**Debug**:
```lua
-- Verify asset exists
print(love.filesystem.getInfo("assets/images/unit.png"))

-- Check asset loaded
if AssetManager.hasImage("images/unit.png") then
    print("Image loaded")
else
    print("Image NOT loaded")
end
```

---

## Related Documentation

- **[State Manager Architecture](../architecture/ADR-003-MODULES.md)** - Design decisions
- **[Code Standards](../CODE_STANDARDS.md)** - Coding style
- **[Debugging Guide](DEBUGGING.md)** - Debugging techniques
- **[Love2D Documentation](https://love2d.org/wiki/Main_Page)** - Framework reference

---

**Last Updated**: October 2025 | **Status**: Active | **Difficulty**: Intermediate

