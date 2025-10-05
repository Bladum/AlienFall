# Lua Style Guide - Alien Fall Project

**Version:** 2.0  
**Last Updated:** September 30, 2025  
**Status:** Official Project Standard

---

## Table of Contents

1. [Overview](#overview)
2. [Naming Conventions](#naming-conventions)
3. [Object-Oriented Programming](#object-oriented-programming)
4. [Love2D-Specific Patterns](#love2d-specific-patterns)
5. [Game Architecture Patterns](#game-architecture-patterns)
6. [Error Handling](#error-handling)
7. [File Organization](#file-organization)
8. [Code Formatting](#code-formatting)
9. [Documentation Standards](#documentation-standards)
10. [Anti-Patterns](#anti-patterns)
11. [Examples](#examples)

---

## Overview

This style guide defines the coding standards for the Alien Fall project, an XCOM-inspired turn-based strategy game built with Love2D and Lua. All code contributions must follow these guidelines to maintain consistency, readability, and maintainability.

### Core Principles

- **Consistency**: Follow established patterns throughout the codebase
- **Readability**: Write code that is easy to understand
- **Maintainability**: Structure code for long-term sustainability
- **Performance**: Optimize hot paths (turn processing, rendering) without sacrificing clarity
- **Safety**: Use defensive programming and proper error handling
- **Determinism**: Ensure reproducible gameplay through proper RNG scoping

---

## Naming Conventions

### Methods (Class Member Functions)

**Use `camelCase` for all class methods**

```lua
local class = require("lib.middleclass")
local MyClass = class('MyClass')

function MyClass:initialize(opts)
    -- Constructor
end

function MyClass:getHealth()
    return self.health
end

function MyClass:setPosition(x, y)
    self.x = x
    self.y = y
end

function MyClass:calculateDamage(target)
    -- Complex calculation
end
```

**Private/Internal Methods**: Prefix with underscore `_`

```lua
function MyClass:_validateInput(value)
    -- Internal validation method
end

function MyClass:_updateInternalState()
    -- Private helper method
end
```

### Module Functions (Non-Class Utilities)

**Use `snake_case` for module-level functions**

```lua
-- src/utils/math_helpers.lua
local math_helpers = {}

function math_helpers.calculate_distance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

function math_helpers.clamp_value(value, min, max)
    return math.max(min, math.min(max, value))
end

return math_helpers
```

### Constants

**Use `UPPER_CASE` with underscores for constants**

```lua
local GRID_SIZE = 20
local MAX_HEALTH = 100
local TILE_WIDTH = 32
local DEFAULT_FONT_SIZE = 14

-- Class-level constants
MyClass.static.MAX_UNITS = 50
MyClass.static.DEFAULT_SPEED = 5

-- Enum-style constants
local SEVERITY = {
    INFO = "info",
    WARNING = "warning",
    ERROR = "error",
    CRITICAL = "critical"
}
```

### Variables

**Use `camelCase` for local variables and instance fields**

```lua
local playerHealth = 100
local currentPosition = {x = 0, y = 0}
local isGameActive = true

function MyClass:initialize(opts)
    self.unitName = opts.name
    self.currentHealth = opts.health or 100
    self.isAlive = true
end
```

**Use `snake_case` for temporary/loop variables (optional style)**

```lua
for unit_id, unit_data in pairs(units) do
    -- Process unit
end

local file_path = "data/config.toml"
```

### Classes and Modules

**Use `PascalCase` for class names**

```lua
local class = require("lib.middleclass")

local UnitEntity = class('UnitEntity')
local MissionSystem = class('MissionSystem')
local InterceptionService = class('InterceptionService')
```

**Module file names use lowercase with underscores**

```
src/utils/safe_io.lua
src/systems/mission_system.lua
src/core/event_bus.lua
```

**Class file names use PascalCase**

```
src/units/UnitEntity.lua
src/systems/MissionSystem.lua
src/services/InterceptionService.lua
```

---

## Object-Oriented Programming

### Use Middleclass for All Classes

**Always use Middleclass for class definitions**

```lua
local class = require("lib.middleclass")

local MyClass = class('MyClass')

function MyClass:initialize(opts)
    opts = opts or {}
    self.value = opts.value or 0
end

function MyClass:getValue()
    return self.value
end

return MyClass
```

**❌ Don't use plain table-based OOP**

```lua
-- BAD: Plain table pattern
local MyClass = {}
MyClass.__index = MyClass

function MyClass.new(opts)
    local self = setmetatable({}, MyClass)
    -- ...
    return self
end
```

### Inheritance

**Use Middleclass inheritance syntax**

```lua
local class = require("lib.middleclass")
local BaseEntity = require("entities.BaseEntity")

local PlayerEntity = class('PlayerEntity', BaseEntity)

function PlayerEntity:initialize(opts)
    BaseEntity.initialize(self, opts)
    self.playerSpecificData = opts.playerData
end

function PlayerEntity:update(dt)
    BaseEntity.update(self, dt)
    -- Additional player-specific logic
end

return PlayerEntity
```

### Static Members

**Use `static` for class-level data**

```lua
local MyClass = class('MyClass')

-- Static constants
MyClass.static.MAX_INSTANCES = 100
MyClass.static.VERSION = "1.0.0"

-- Static methods
function MyClass.static:createDefault()
    return MyClass:new({value = 0})
end
```

---

## Love2D-Specific Patterns

### Callback Structure

**Organize Love2D callbacks consistently across game states**

```lua
local class = require("lib.middleclass")
local BaseState = class('BaseState')

function BaseState:initialize()
    -- State initialization
end

-- Standard Love2D callbacks
function BaseState:enter(previous_state, ...)
    -- Called when entering this state
end

function BaseState:update(dt)
    -- Update logic
end

function BaseState:draw()
    -- Rendering logic
end

function BaseState:keypressed(key, scancode, isrepeat)
    -- Handle keyboard input
end

function BaseState:mousepressed(x, y, button, istouch, presses)
    -- Handle mouse input
end

function BaseState:leave()
    -- Cleanup when leaving state
end

return BaseState
```

### Asset Management

**Load assets once during initialization, cache for performance**

```lua
local Assets = {}
Assets.__index = Assets

function Assets.new()
    local self = setmetatable({}, Assets)
    self.images = {}
    self.fonts = {}
    self.sounds = {}
    return self
end

-- Good: Lazy loading with caching
function Assets:getImage(path)
    if not self.images[path] then
        self.images[path] = love.graphics.newImage(path)
        -- Set filtering for pixel art
        self.images[path]:setFilter("nearest", "nearest")
    end
    return self.images[path]
end

-- Good: Preload critical assets
function Assets:preloadCritical()
    self:getImage("assets/ui/button.png")
    self:getImage("assets/sprites/soldier.png")
    self:getFont("assets/fonts/main.ttf", 14)
end

function Assets:getFont(path, size)
    local key = path .. "_" .. size
    if not self.fonts[key] then
        self.fonts[key] = love.graphics.newFont(path, size)
    end
    return self.fonts[key]
end

return Assets
```

### Canvas and Render Targets

**Use canvases for fixed-resolution rendering (800x600 pixel art)**

```lua
local Renderer = {}

function Renderer.new()
    local self = setmetatable({}, {__index = Renderer})
    
    -- Create canvas at game's native resolution
    self.gameCanvas = love.graphics.newCanvas(800, 600)
    self.gameCanvas:setFilter("nearest", "nearest")
    
    return self
end

function Renderer:calculateScale()
    local window_width, window_height = love.graphics.getDimensions()
    local scale_x = window_width / 800
    local scale_y = window_height / 600
    -- Use minimum scale to maintain aspect ratio
    return math.min(scale_x, scale_y)
end

function Renderer:beginGameRender()
    love.graphics.setCanvas(self.gameCanvas)
    love.graphics.clear()
end

function Renderer:endGameRender()
    love.graphics.setCanvas()
    
    -- Draw scaled canvas to screen
    local scale = self:calculateScale()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(
        self.gameCanvas,
        (love.graphics.getWidth() - 800 * scale) / 2,
        (love.graphics.getHeight() - 600 * scale) / 2,
        0,
        scale,
        scale
    )
end

return Renderer
```

### Pixel-Perfect Rendering

**Disable antialiasing and use nearest-neighbor filtering**

```lua
-- In conf.lua
function love.conf(t)
    t.window.width = 800
    t.window.height = 600
    t.window.resizable = true
    t.window.msaa = 0  -- Disable antialiasing for pixel art
end

-- When loading images
local sprite = love.graphics.newImage("assets/sprite.png")
sprite:setFilter("nearest", "nearest")  -- Pixel-perfect scaling

-- When creating fonts
local font = love.graphics.newFont("assets/font.ttf", 14)
font:setFilter("nearest", "nearest")
```

### Delta Time Handling

**Always use delta time for frame-independent game logic**

```lua
function Unit:update(dt)
    -- Good: Movement speed independent of framerate
    self.x = self.x + self.velocity_x * dt
    self.y = self.y + self.velocity_y * dt
    
    -- Good: Timer countdown
    self.cooldown_timer = math.max(0, self.cooldown_timer - dt)
    
    -- Good: Animation timing
    self.animation_timer = self.animation_timer + dt
    if self.animation_timer >= self.animation_frame_time then
        self.animation_timer = self.animation_timer - self.animation_frame_time
        self:nextFrame()
    end
end
```

### Coordinate System Conversion

**Convert between window and game coordinates for UI interactions**

```lua
local INPUT_SCALE_X = 800 / love.graphics.getWidth()
local INPUT_SCALE_Y = 600 / love.graphics.getHeight()

function convertToGameCoords(window_x, window_y)
    -- Adjust for letterboxing/pillarboxing
    local scale = math.min(
        love.graphics.getWidth() / 800,
        love.graphics.getHeight() / 600
    )
    
    local offset_x = (love.graphics.getWidth() - 800 * scale) / 2
    local offset_y = (love.graphics.getHeight() - 600 * scale) / 2
    
    local game_x = (window_x - offset_x) / scale
    local game_y = (window_y - offset_y) / scale
    
    return game_x, game_y
end

function Button:mousepressed(x, y, button)
    local game_x, game_y = convertToGameCoords(x, y)
    
    if game_x >= self.x and game_x <= self.x + self.width and
       game_y >= self.y and game_y <= self.y + self.height then
        self:onClick()
    end
end
```

---

## Game Architecture Patterns

### Entity Component System (ECS)

**Separate data (components) from behavior (systems)**

```lua
-- Component: Pure data
local HealthComponent = {}
function HealthComponent.new(current, maximum)
    return {
        current = current,
        maximum = maximum
    }
end

-- Component: Pure data
local PositionComponent = {}
function PositionComponent.new(x, y)
    return {x = x, y = y}
end

-- System: Operates on entities with specific components
local DamageSystem = {}

function DamageSystem:processDamage(entities, damage_events, dt)
    for _, event in ipairs(damage_events) do
        local entity = entities[event.target_id]
        if entity and entity.health then
            entity.health.current = math.max(0, entity.health.current - event.amount)
            
            if entity.health.current == 0 then
                self:handleDeath(entity)
            end
        end
    end
end

return DamageSystem
```

### State Machine Pattern

**Use state machines for game screens and AI behaviors**

```lua
local class = require("lib.middleclass")
local StateMachine = class('StateMachine')

function StateMachine:initialize()
    self.current_state = nil
    self.states = {}
end

function StateMachine:addState(name, state)
    self.states[name] = state
end

function StateMachine:changeState(name, ...)
    if self.current_state and self.current_state.exit then
        self.current_state:exit()
    end
    
    self.current_state = self.states[name]
    
    if self.current_state and self.current_state.enter then
        self.current_state:enter(...)
    end
end

function StateMachine:update(dt)
    if self.current_state and self.current_state.update then
        self.current_state:update(dt)
    end
end

function StateMachine:draw()
    if self.current_state and self.current_state.draw then
        self.current_state:draw()
    end
end

-- Usage
local game_states = StateMachine:new()
game_states:addState("main_menu", MainMenuState:new())
game_states:addState("geoscape", GeoscapeState:new())
game_states:addState("battlescape", BattlescapeState:new())
game_states:changeState("main_menu")
```

### Deterministic RNG

**Use seeded random number generators for reproducible gameplay**

```lua
local RNGService = {}

function RNGService.new(seed)
    local self = setmetatable({}, {__index = RNGService})
    self.rng = love.math.newRandomGenerator(seed)
    self.seed = seed
    return self
end

function RNGService:random(min, max)
    if min and max then
        return self.rng:random(min, max)
    elseif min then
        return self.rng:random(min)
    else
        return self.rng:random()
    end
end

function RNGService:getSeed()
    return self.seed
end

-- Scoped RNG for different game systems
local geoscape_rng = RNGService.new(123456)
local battlescape_rng = RNGService.new(789012)
local ai_rng = RNGService.new(345678)

-- Now hit chances, mission spawns, and AI decisions are deterministic
local hit_chance = battlescape_rng:random(1, 100)
```

### Event Bus Pattern

**Decouple systems using publish/subscribe messaging**

```lua
local EventBus = {}
EventBus.__index = EventBus

function EventBus.new()
    local self = setmetatable({}, EventBus)
    self.subscribers = {}
    return self
end

function EventBus:subscribe(event_name, callback)
    if not self.subscribers[event_name] then
        self.subscribers[event_name] = {}
    end
    table.insert(self.subscribers[event_name], callback)
end

function EventBus:publish(event_name, data)
    if self.subscribers[event_name] then
        for _, callback in ipairs(self.subscribers[event_name]) do
            callback(data)
        end
    end
end

-- Usage
local event_bus = EventBus.new()

event_bus:subscribe("unit_killed", function(data)
    print("Unit " .. data.unit_id .. " was killed")
end)

event_bus:subscribe("unit_killed", function(data)
    statistics:recordKill(data.unit_id)
end)

event_bus:publish("unit_killed", {unit_id = "soldier_01", killer_id = "alien_03"})
```

### Turn-Based Game Loop

**Separate update logic from turn processing**

```lua
local TurnManager = {}

function TurnManager.new()
    local self = setmetatable({}, {__index = TurnManager})
    self.current_turn = 1
    self.active_faction = "player"
    self.turn_in_progress = false
    return self
end

function TurnManager:startTurn()
    self.turn_in_progress = true
    print("Turn " .. self.current_turn .. ": " .. self.active_faction)
    
    -- Refresh action points for active faction units
    for _, unit in ipairs(self:getActiveFactionUnits()) do
        unit:refreshActionPoints()
    end
end

function TurnManager:endTurn()
    self.turn_in_progress = false
    
    -- Switch to next faction
    if self.active_faction == "player" then
        self.active_faction = "alien"
    else
        self.active_faction = "player"
        self.current_turn = self.current_turn + 1
    end
    
    self:startTurn()
end

function TurnManager:canPerformAction(unit)
    return self.turn_in_progress and 
           unit.faction == self.active_faction and
           unit:hasActionPoints()
end

return TurnManager
```

---

## Error Handling
```

### Static Members

**Use `static` for class-level data**

```lua
local MyClass = class('MyClass')

-- Static constants
MyClass.static.MAX_INSTANCES = 100
MyClass.static.VERSION = "1.0.0"

-- Static methods
function MyClass.static:createDefault()
    return MyClass:new({default = true})
end
```

---

## Error Handling

### Always Use Safe I/O Wrappers

**Use `SafeIO` module for all file operations**

```lua
local SafeIO = require("utils.safe_io")

-- Safe module loading
local config = SafeIO.safe_require("config.game_config", {})

-- Safe TOML loading
local data = SafeIO.safe_load_toml("data/units.toml", {units = {}})

-- Safe image loading
local texture = SafeIO.safe_load_image("assets/player.png")
```

### Use pcall for Risky Operations

**Wrap potentially failing operations in pcall**

```lua
function MyClass:parseUserData(jsonString)
    local success, result = pcall(json.decode, jsonString)
    if not success then
        logger:error("Failed to parse JSON: " .. tostring(result))
        return nil
    end
    return result
end
```

### Validate Input Parameters

**Always validate function inputs**

```lua
function MyClass:setHealth(value)
    assert(type(value) == "number", "Health must be a number")
    assert(value >= 0, "Health cannot be negative")
    
    self.health = math.min(value, self.maxHealth)
end

function MyClass:initialize(opts)
    opts = opts or {}
    
    if opts.name and type(opts.name) ~= "string" then
        error("name must be a string")
    end
    
    self.name = opts.name or "Unnamed"
end
```

### Return Meaningful Error Values

**Use nil + error message pattern**

```lua
function MyClass:loadData(filename)
    if not filename then
        return nil, "filename is required"
    end
    
    local data = SafeIO.safe_load_toml(filename)
    if not data then
        return nil, "failed to load file: " .. filename
    end
    
    return data
end

-- Usage
local data, err = myInstance:loadData("config.toml")
if not data then
    logger:error("Load failed: " .. err)
    return
end
```

---

## File Organization

### File Structure Template

```lua
--- Brief description of module/class
--- @module module.name or @class ClassName

-- Dependencies (sorted alphabetically)
local class = require("lib.middleclass")
local DependencyA = require("path.to.DependencyA")
local DependencyB = require("path.to.DependencyB")

-- Constants (at top of file)
local GRID_SIZE = 20
local MAX_UNITS = 100

-- Class definition
local MyClass = class('MyClass')

-- Static members
MyClass.static.VERSION = "1.0.0"

-- Constructor
function MyClass:initialize(opts)
    -- Implementation
end

-- Public methods (alphabetically or by logical grouping)
function MyClass:publicMethod()
    -- Implementation
end

-- Private methods (prefixed with _)
function MyClass:_privateHelper()
    -- Implementation
end

-- Return the class/module
return MyClass
```

### Directory Structure

```
src/
├── core/           # Core engine systems
│   ├── event_bus.lua
│   ├── service_registry.lua
│   └── config/
├── engine/         # Game engine components
│   ├── asset_cache.lua
│   ├── save.lua
│   └── scene_manager.lua
├── systems/        # Game systems (ECS)
│   ├── MissionSystem.lua
│   ├── UnitSystem.lua
│   └── CombatSystem.lua
├── entities/       # Entity definitions
│   ├── BaseEntity.lua
│   ├── UnitEntity.lua
│   └── CraftEntity.lua
├── utils/          # Utility functions
│   ├── safe_io.lua
│   ├── math_helpers.lua
│   └── table_utils.lua
├── widgets/        # UI widgets
│   ├── Button.lua
│   ├── Table.lua
│   └── Tooltip.lua
└── screens/        # Game screens/states
    ├── main_menu_state.lua
    ├── geoscape_state.lua
    └── battlescape_state.lua
```

---

## Code Formatting

### Indentation

- **Use 4 spaces** for indentation (no tabs)
- Consistent indentation improves readability

```lua
function MyClass:complexMethod()
    if condition then
        for i = 1, 10 do
            if nestedCondition then
                doSomething()
            end
        end
    end
end
```

### Line Length

- **Limit lines to 100 characters** when practical
- Break long lines at logical points

```lua
-- Good
local result = myModule.calculate_complex_value(
    param1,
    param2,
    param3
)

-- Acceptable for readability
local veryLongVariableName = someFunction(arg1, arg2, arg3, arg4)
```

### Spacing

**Use spaces around operators**

```lua
-- Good
local sum = a + b
local result = (value * 2) + offset

-- Bad
local sum=a+b
```

**Blank lines between logical sections**

```lua
function MyClass:initialize(opts)
    -- Input validation
    opts = opts or {}
    
    -- Initialize state
    self.health = opts.health or 100
    self.position = {x = 0, y = 0}
    
    -- Setup callbacks
    self.onDeath = opts.onDeath
end
```

### Table Formatting

**Multi-line tables with trailing commas**

```lua
local config = {
    width = 800,
    height = 600,
    fullscreen = false,
    vsync = true,
}

local colors = {
    red = {1, 0, 0},
    green = {0, 1, 0},
    blue = {0, 0, 1},
}
```

### String Formatting

**Use double quotes for strings by default**

```lua
local name = "Player"
local message = "Hello, world!"
```

**Use single quotes for internal strings or when containing quotes**

```lua
local luaCode = 'local x = "test"'
local tooltip = 'Click "OK" to continue'
```

---

## Documentation Standards

### Module/Class Documentation

**Use LDoc-style comments for modules and classes**

```lua
--- A comprehensive unit management system
--- @class UnitSystem
--- @description Handles unit creation, updates, and lifecycle management.
--- Integrates with the mission system and combat resolution.
local class = require("lib.middleclass")

local UnitSystem = class('UnitSystem')
```

### Function Documentation

**Document all public functions**

```lua
--- Calculate damage dealt from attacker to target
--- @param attacker table The attacking unit entity
--- @param target table The target unit entity
--- @param weaponType string Type of weapon used
--- @return number damage The calculated damage value
--- @return boolean critical Whether this was a critical hit
function CombatSystem:calculateDamage(attacker, target, weaponType)
    -- Implementation
end
```

### Inline Comments

**Explain complex logic, not obvious code**

```lua
-- Good: Explains WHY
-- Use bidirectional pathfinding to optimize performance
local path = self:findOptimalPath(start, goal)

-- Bad: States WHAT (obvious)
-- Set x to 10
local x = 10
```

---

## Anti-Patterns

### ❌ Don't Use Global Variables

```lua
-- BAD
globalConfig = {width = 800, height = 600}

-- GOOD
local config = {width = 800, height = 600}
return config
```

### ❌ Don't Use Magic Numbers

```lua
-- BAD
if health < 20 then
    showWarning()
end

-- GOOD
local CRITICAL_HEALTH_THRESHOLD = 20
if health < CRITICAL_HEALTH_THRESHOLD then
    showWarning()
end
```

### ❌ Don't Ignore Error Returns

```lua
-- BAD
local data = loadFile("config.toml")

-- GOOD
local data, err = loadFile("config.toml")
if not data then
    logger:error("Failed to load config: " .. err)
    data = getDefaultConfig()
end
```

### ❌ Don't Use `require()` Inside Functions

```lua
-- BAD
function processData()
    local json = require("json")  -- Loads every call
    return json.decode(data)
end

-- GOOD
local json = require("json")  -- Load once at module level

function processData()
    return json.decode(data)
end
```

### ❌ Don't Modify Tables While Iterating

```lua
-- BAD
for i, item in ipairs(items) do
    if item.dead then
        table.remove(items, i)  -- Skips elements
    end
end

-- GOOD
for i = #items, 1, -1 do
    if items[i].dead then
        table.remove(items, i)
    end
end

-- BETTER: Collect indices first
local toRemove = {}
for i, item in ipairs(items) do
    if item.dead then
        table.insert(toRemove, i)
    end
end
for i = #toRemove, 1, -1 do
    table.remove(items, toRemove[i])
end
```

---

## Examples

### Complete Class Example

```lua
--- Manages unit entities in the game
--- @class UnitManager
--- @description Handles creation, updates, and lifecycle management of units

local class = require("lib.middleclass")
local UnitEntity = require("entities.UnitEntity")

-- Constants
local MAX_UNITS = 100
local UPDATE_INTERVAL = 0.1

local UnitManager = class('UnitManager')

-- Static members
UnitManager.static.VERSION = "1.0.0"

--- Initialize the unit manager
--- @param opts table Configuration options
--- @param opts.maxUnits number Maximum units to manage (default: 100)
function UnitManager:initialize(opts)
    opts = opts or {}
    
    self.maxUnits = opts.maxUnits or MAX_UNITS
    self.units = {}
    self.updateTimer = 0
end

--- Create a new unit
--- @param unitData table Unit configuration data
--- @return UnitEntity|nil unit The created unit, or nil on failure
--- @return string|nil error Error message if creation failed
function UnitManager:createUnit(unitData)
    if #self.units >= self.maxUnits then
        return nil, "Maximum unit limit reached"
    end
    
    if not unitData or not unitData.type then
        return nil, "Invalid unit data"
    end
    
    local unit = UnitEntity:new(unitData)
    table.insert(self.units, unit)
    
    return unit
end

--- Update all managed units
--- @param dt number Delta time since last update
function UnitManager:update(dt)
    self.updateTimer = self.updateTimer + dt
    
    if self.updateTimer >= UPDATE_INTERVAL then
        self:_updateAllUnits(self.updateTimer)
        self.updateTimer = 0
    end
end

--- Get unit by ID
--- @param unitId string The unique unit identifier
--- @return UnitEntity|nil unit The unit, or nil if not found
function UnitManager:getUnit(unitId)
    for _, unit in ipairs(self.units) do
        if unit.id == unitId then
            return unit
        end
    end
    return nil
end

--- Internal method to update all units
--- @param dt number Delta time
function UnitManager:_updateAllUnits(dt)
    for i = #self.units, 1, -1 do
        local unit = self.units[i]
        unit:update(dt)
        
        -- Remove dead units
        if not unit:isAlive() then
            table.remove(self.units, i)
        end
    end
end

return UnitManager
```

### Utility Module Example

```lua
--- Mathematical utility functions
--- @module utils.math_helpers

local math_helpers = {}

local EPSILON = 0.0001

--- Calculate Euclidean distance between two points
--- @param x1 number First point X coordinate
--- @param y1 number First point Y coordinate
--- @param x2 number Second point X coordinate
--- @param y2 number Second point Y coordinate
--- @return number distance The calculated distance
function math_helpers.calculate_distance(x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    return math.sqrt(dx * dx + dy * dy)
end

--- Clamp a value between minimum and maximum bounds
--- @param value number The value to clamp
--- @param min number Minimum bound
--- @param max number Maximum bound
--- @return number clamped The clamped value
function math_helpers.clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

--- Check if two floating point numbers are approximately equal
--- @param a number First number
--- @param b number Second number
--- @param epsilon number Tolerance (default: 0.0001)
--- @return boolean equal True if numbers are approximately equal
function math_helpers.approximately_equal(a, b, epsilon)
    epsilon = epsilon or EPSILON
    return math.abs(a - b) < epsilon
end

return math_helpers
```

---

## Summary Checklist

When writing code, ensure:

- [ ] Class methods use `camelCase`
- [ ] Module functions use `snake_case`
- [ ] Constants use `UPPER_CASE`
- [ ] All classes use Middleclass
- [ ] File I/O uses SafeIO wrappers
- [ ] Input parameters are validated
- [ ] Errors are handled with pcall or nil+error pattern
- [ ] Public functions have LDoc documentation
- [ ] No global variables are created
- [ ] No magic numbers (use named constants)
- [ ] Code follows 4-space indentation
- [ ] Lines are under 100 characters when practical

---

## References

- [Lua 5.1 Reference Manual](https://www.lua.org/manual/5.1/)
- [Love2D API Documentation](https://love2d.org/wiki/Main_Page)
- [Middleclass Documentation](https://github.com/kikito/middleclass)
- [LDoc Documentation Generator](https://stevedonovan.github.io/ldoc/)

---

**Document History:**
- v1.0.0 (2025-09-30): Initial release
