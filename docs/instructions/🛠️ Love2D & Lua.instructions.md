# 🛠️ Love2D & Lua Best Practices for AlienFall

**Domain**: Game Development with Love2D 12.0+ and Lua  
**Focus**: Coding standards, architecture, documentation, ECS patterns  
**Version**: 1.0  
**Last Updated**: October 16, 2025

---

## Table of Contents

1. [Lua Language Standards](#lua-language-standards)
2. [Code Organization & Structure](#code-organization--structure)
3. [Love2D Architecture](#love2d-architecture)
4. [Entity-Component-System (ECS) Pattern](#entity-component-system-ecs-pattern)
5. [Documentation & Docstrings](#documentation--docstrings)
6. [Error Handling](#error-handling)
7. [Performance Optimization](#performance-optimization)
8. [Testing & Debugging](#testing--debugging)
9. [Resource Management](#resource-management)
10. [Build & Deployment](#build--deployment)
11. [README Best Practices](#readme-best-practices)
12. [Common Mistakes & Solutions](#common-mistakes--solutions)

---

## Lua Language Standards

### ✅ DO: Use Local Variables

Minimize global scope pollution.

**Good Example:**

```lua
-- Correct: Local scope
local function calculateDamage(weapon, target)
    local baseDamage = weapon.baseDamage
    local armor = target.armor
    local finalDamage = baseDamage - armor
    return math.max(0, finalDamage)
end

-- Player object
local player = {
    health = 100,
    weapon = { baseDamage = 15 }
}
```

**Why**: 
- Prevents accidental variable collision
- Faster lookup (local scope is faster than global)
- Safer in multi-module projects
- Clearer variable lifetime

### ✅ DO: Use Proper Naming Conventions

Consistent naming prevents confusion.

**Naming Convention Standards:**

```lua
-- Constants: UPPER_CASE
local MAX_HEALTH = 100
local GAME_VERSION = "1.0.0"
local SCREEN_WIDTH = 960

-- Variables & Functions: camelCase
local playerHealth = 50
local function calculateDamage()
end

-- Local underscore for unused parameters
local function handleInput(_dt, _inputType)
    -- dt and inputType not used, but required by interface
end

-- Private functions: prefix with underscore (convention only)
local function _internalHelper()
end

-- Class/Table: PascalCase (when used as constructor)
local Unit = {}
function Unit:new(name)
    local self = setmetatable({}, { __index = Unit })
    self.name = name
    return self
end

-- Module file: lowercase with underscores
-- File: unit_manager.lua
-- Usage: local UnitManager = require("unit_manager")
```

### ✅ DO: Handle Nil Explicitly

Lua treats nil as falsey, handle intentionally.

**Good Example:**

```lua
-- Explicit nil check
local function isHealthy(unit)
    if unit and unit.health and unit.health > 50 then
        return true
    end
    return false
end

-- Default values
local function setPlayerName(name)
    self.name = name or "Unknown Player"  -- Fallback value
end

-- Distinguish between "no value" and "false"
local config = {
    debugMode = false,  -- Intentionally disabled
    optionalFeature = nil  -- Not set yet
}
```

### ✅ DO: Use Tables for Organized Data

Tables are Lua's primary data structure.

**Table Usage:**

```lua
-- Array-like table (indexed)
local inventory = {
    "sword",
    "shield",
    "potion"
}

-- Dict-like table (key-value)
local playerStats = {
    health = 100,
    armor = 25,
    speed = 5.0
}

-- Mixed table
local character = {
    name = "Commander",
    inventory = { "rifle", "medkit" },
    stats = {
        health = 100,
        mana = 50
    },
    skills = {
        "leadership",
        "tactics",
        "weapon_mastery"
    }
}

-- Accessing
print(character.name)              -- "Commander"
print(character.inventory[1])      -- "rifle"
print(character.stats.health)      -- 100
print(character.skills[2])         -- "tactics"
```

### ✅ DO: Avoid Global Functions

Keep functions scoped appropriately.

**Good Structure:**

```lua
-- game/units/soldier.lua
local Soldier = {}

function Soldier:new(name)
    local self = setmetatable({}, { __index = Soldier })
    self.name = name
    self.health = 100
    return self
end

function Soldier:takeDamage(amount)
    self.health = self.health - amount
end

function Soldier:isAlive()
    return self.health > 0
end

return Soldier  -- Module exports one thing

-- Usage in main.lua
local Soldier = require("game.units.soldier")
local unit = Soldier:new("John")
unit:takeDamage(10)
```

### ❌ DON'T: Create Global Functions

Avoid polluting global namespace.

**Bad Example:**

```lua
-- DON'T: In multiple files
function TakeDamage(unit, amount)  -- Global function, all caps incorrect
    unit.health = unit.health - amount
end

-- Problem: Name collisions, hard to find where function is defined
-- Invisible dependencies
```

---

## Code Organization & Structure

### ✅ DO: Organize by Vertical Slicing

Structure around game systems, not layers.

**Good Project Structure:**

```
engine/
├── core/
│   ├── init.lua                 -- Core initialization
│   ├── state_manager.lua        -- Game state machine
│   └── event_bus.lua            -- Event system
│
├── graphics/
│   ├── renderer.lua             -- Main rendering system
│   ├── camera.lua               -- Camera management
│   └── ui/
│       ├── panel.lua            -- UI panels
│       ├── button.lua           -- UI buttons
│       └── theme.lua            -- UI theming
│
├── entities/
│   ├── entity.lua               -- Base entity class
│   ├── unit.lua                 -- Unit entity type
│   ├── terrain.lua              -- Terrain entity type
│   └── environment.lua          -- Environmental elements
│
├── components/
│   ├── position.lua             -- Position component
│   ├── health.lua               -- Health component
│   ├── inventory.lua            -- Inventory component
│   ├── sprite.lua               -- Sprite component
│   └── ai.lua                   -- AI component
│
├── systems/
│   ├── movement_system.lua      -- Movement logic
│   ├── combat_system.lua        -- Combat logic
│   ├── animation_system.lua     -- Animation logic
│   └── ai_system.lua            -- AI processing
│
├── battlescape/
│   ├── mission.lua              -- Mission management
│   ├── map_generator.lua        -- Procedural generation
│   ├── unit_spawner.lua         -- Unit spawning
│   └── turn_manager.lua         -- Turn system
│
├── geoscape/
│   ├── world.lua                -- World map
│   ├── region.lua               -- Regional management
│   └── facility.lua             -- Base facilities
│
├── utils/
│   ├── math.lua                 -- Math utilities
│   ├── table_utils.lua          -- Table helpers
│   ├── debug.lua                -- Debug tools
│   └── profiler.lua             -- Performance profiling
│
└── assets/
    ├── sprites/                 -- Image files
    ├── sounds/                  -- Audio files
    ├── data/                    -- Data files (TOML, JSON)
    └── fonts/                   -- Font files
```

### ✅ DO: Use Module Pattern

Encapsulate code in modules.

**Good Module Example:**

```lua
-- game/combat/damage_calculator.lua
local DamageCalculator = {}

-- Private function
local function _applyArmor(damage, armor)
    local reduction = armor * 0.5
    return math.max(1, damage - reduction)
end

-- Public method
function DamageCalculator.calculate(attacker, defender, weapon)
    if not attacker or not defender or not weapon then
        error("Missing required parameters for damage calculation")
    end
    
    local baseDamage = weapon.damage or 0
    local attackerBonus = attacker.damageBonus or 0
    local totalDamage = baseDamage + attackerBonus
    
    local finalDamage = _applyArmor(totalDamage, defender.armor or 0)
    return finalDamage
end

-- Metadata
function DamageCalculator.getInfo()
    return {
        version = "1.0",
        author = "Game Architect",
        purpose = "Calculate combat damage"
    }
end

return DamageCalculator

-- Usage
local DamageCalculator = require("game.combat.damage_calculator")
local damage = DamageCalculator.calculate(attacker, defender, weapon)
```

### ✅ DO: Separate Concerns

Each module has one responsibility.

**Good Separation:**

```lua
-- game/units/unit.lua - Unit data & behavior
local Unit = {}
function Unit:takeDamage(amount)
    self.health = self.health - amount
end
return Unit

-- game/rendering/unit_renderer.lua - Rendering only
local UnitRenderer = {}
function UnitRenderer.draw(unit, camera)
    love.graphics.draw(unit.sprite, unit.x, unit.y)
end
return UnitRenderer

-- game/input/unit_input.lua - Input handling only
local UnitInput = {}
function UnitInput.handleClick(unit, x, y)
    -- Move unit to clicked location
end
return UnitInput

-- game/ui/unit_panel.lua - UI display
local UnitPanel = {}
function UnitPanel.show(unit)
    -- Display unit stats in UI
end
return UnitPanel
```

### ❌ DON'T: Create God Objects

Avoid one class doing everything.

**Bad Example (GOD OBJECT):**

```lua
-- unit.lua - DON'T DO THIS
local Unit = {}

function Unit:new()
    -- 500+ lines of initialization
    -- Handles data, rendering, input, AI, pathfinding, combat...
end

function Unit:update(dt)
    -- 1000+ lines trying to update everything
end

function Unit:draw()
    -- Everything rendered here
end

-- This is unmaintainable!
```

---

## Love2D Architecture

### ✅ DO: Structure Love2D Callbacks Properly

Organize callbacks with clear responsibilities.

**Good Love2D Structure:**

```lua
-- conf.lua - Configuration
function love.conf(t)
    t.window.width = 960
    t.window.height = 720
    t.window.title = "AlienFall"
    t.version = "12.0"
    t.console = true
    
    t.window.resizable = false
    t.window.vsync = 1
    
    t.graphics.msaa = 0  -- No anti-aliasing for pixel art
end

-- main.lua - Entry point
function love.load()
    _G.GameState = require("engine.core.state_manager"):new()
    _G.EventBus = require("engine.core.event_bus"):new()
    _G.Renderer = require("engine.graphics.renderer"):new()
    
    GameState:changeState("mainMenu")
end

function love.update(dt)
    -- Cap delta time for consistency
    dt = math.min(dt, 0.016)  -- Max 16ms per frame
    
    GameState:update(dt)
    Renderer:update(dt)
end

function love.draw()
    love.graphics.clear(0, 0, 0)
    Renderer:draw()
end

function love.mousepressed(x, y, button)
    GameState:handleInput("mouse", button, x, y)
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
    GameState:handleInput("keyboard", key)
end

function love.quit()
    -- Cleanup
    return false  -- Don't prevent quit
end
```

### ✅ DO: Implement State Manager

Manage distinct game states cleanly.

**State Manager Pattern:**

```lua
-- engine/core/state_manager.lua
local StateManager = {}

function StateManager:new()
    local self = setmetatable({}, { __index = StateManager })
    self.states = {}
    self.currentState = nil
    return self
end

function StateManager:registerState(name, stateClass)
    self.states[name] = stateClass
end

function StateManager:changeState(stateName, ...)
    if self.currentState and self.currentState.exit then
        self.currentState:exit()
    end
    
    local StateClass = self.states[stateName]
    if not StateClass then
        error("State not found: " .. stateName)
    end
    
    self.currentState = StateClass:new(...)
    if self.currentState.enter then
        self.currentState:enter()
    end
end

function StateManager:update(dt)
    if self.currentState and self.currentState.update then
        self.currentState:update(dt)
    end
end

function StateManager:handleInput(...)
    if self.currentState and self.currentState.handleInput then
        self.currentState:handleInput(...)
    end
end

return StateManager

-- Usage in states
-- game/states/main_menu.lua
local MainMenuState = {}

function MainMenuState:new()
    return setmetatable({}, { __index = MainMenuState })
end

function MainMenuState:enter()
    print("Entering Main Menu")
    self.selectedOption = 1
end

function MainMenuState:update(dt)
    -- Update menu logic
end

function MainMenuState:handleInput(inputType, key)
    if inputType == "keyboard" and key == "return" then
        _G.GameState:changeState("battlescape")
    end
end

function MainMenuState:exit()
    print("Exiting Main Menu")
end

return MainMenuState
```

### ✅ DO: Use Event Bus for Communication

Decouple systems with events.

**Event Bus Pattern:**

```lua
-- engine/core/event_bus.lua
local EventBus = {}

function EventBus:new()
    local self = setmetatable({}, { __index = EventBus })
    self.listeners = {}
    return self
end

function EventBus:subscribe(eventName, callback)
    if not self.listeners[eventName] then
        self.listeners[eventName] = {}
    end
    table.insert(self.listeners[eventName], callback)
end

function EventBus:emit(eventName, ...)
    if self.listeners[eventName] then
        for _, callback in ipairs(self.listeners[eventName]) do
            callback(...)
        end
    end
end

return EventBus

-- Usage Example
-- In combat_system.lua
local function onUnitAttack(attacker, target, damage)
    target:takeDamage(damage)
    EventBus:emit("unit_damaged", target, damage)
    EventBus:emit("combat_log", attacker.name .. " attacks " .. target.name)
end

-- In ui_system.lua
EventBus:subscribe("unit_damaged", function(unit, damage)
    -- Update UI to show damage
    FloatingText.show(unit.x, unit.y, "-" .. damage)
end)

EventBus:subscribe("combat_log", function(message)
    -- Add message to combat log
    CombatLog.addMessage(message)
end)
```

---

## Entity-Component-System (ECS) Pattern

### ✅ DO: Implement ECS for Flexible Entities

Separate data from behavior.

**ECS Architecture:**

```lua
-- engine/ecs/entity.lua
local Entity = {}

function Entity:new(id)
    local self = setmetatable({}, { __index = Entity })
    self.id = id
    self.components = {}
    self.active = true
    return self
end

function Entity:addComponent(componentType, componentData)
    self.components[componentType] = componentData
    return self
end

function Entity:getComponent(componentType)
    return self.components[componentType]
end

function Entity:hasComponent(componentType)
    return self.components[componentType] ~= nil
end

function Entity:removeComponent(componentType)
    self.components[componentType] = nil
end

return Entity

-- engine/ecs/component.lua - Component examples
local Components = {}

-- Position Component
Components.Position = {
    x = 0,
    y = 0,
    z = 0
}

-- Health Component
Components.Health = {
    currentHealth = 100,
    maxHealth = 100
}

-- Sprite Component
Components.Sprite = {
    image = nil,
    animationFrame = 1,
    animationSpeed = 0.1
}

-- AI Component
Components.AI = {
    behavior = "idle",
    targetUnit = nil,
    detectionRange = 100
}

-- Inventory Component
Components.Inventory = {
    items = {},
    capacity = 10
}

return Components

-- engine/ecs/system.lua - Base System
local System = {}

function System:new()
    return setmetatable({}, { __index = System })
end

-- Override in subclasses
function System:update(dt, entities)
    -- Process entities with required components
end

return System

-- game/systems/movement_system.lua
local System = require("engine.ecs.system")
local MovementSystem = setmetatable({}, { __index = System })

function MovementSystem:update(dt, entities)
    for _, entity in ipairs(entities) do
        if entity:hasComponent("Position") and 
           entity:hasComponent("AI") then
            local pos = entity:getComponent("Position")
            local ai = entity:getComponent("AI")
            
            if ai.behavior == "moving" then
                pos.x = pos.x + (ai.speed or 0) * dt
                pos.y = pos.y + (ai.speed or 0) * dt
            end
        end
    end
end

return MovementSystem

-- Usage in battlescape
local function setupBattle()
    local entities = {}
    
    -- Create unit
    local unit = Entity:new(1)
    unit:addComponent("Position", { x = 100, y = 100 })
    unit:addComponent("Health", { currentHealth = 100, maxHealth = 100 })
    unit:addComponent("Sprite", { image = soldierImage })
    unit:addComponent("AI", { behavior = "idle" })
    
    table.insert(entities, unit)
    
    local systems = {
        movement = MovementSystem:new(),
        combat = CombatSystem:new(),
        rendering = RenderingSystem:new()
    }
    
    return entities, systems
end

local function updateBattle(dt, entities, systems)
    systems.movement:update(dt, entities)
    systems.combat:update(dt, entities)
end

local function drawBattle(entities, systems)
    systems.rendering:update(nil, entities)
end
```

---

## Documentation & Docstrings

### ✅ DO: Use LuaDoc Format

Document all public functions.

**LuaDoc Format:**

```lua
--- Calculates combat damage between two units.
-- 
-- This function applies various modifiers including weapon bonuses,
-- armor reduction, and difficulty scaling.
--
-- @param attacker (Unit) The attacking unit, must have damageBonus
-- @param defender (Unit) The defending unit, must have armor
-- @param weapon (Weapon) The weapon being used for attack
-- @param difficulty (number) Optional difficulty modifier (default: 1.0)
--
-- @return (number) Calculated final damage (minimum 1)
-- @return (table) Damage breakdown { base, bonus, armor, modifier }
--
-- @example
--   local damage, breakdown = DamageCalculator.calculate(attacker, defender, sword, 1.5)
--   if damage > 0 then
--       defender:takeDamage(damage)
--   end
--
-- @see Unit:takeDamage
-- @since 1.0
local function calculateDamage(attacker, defender, weapon, difficulty)
    difficulty = difficulty or 1.0
    
    local baseDamage = weapon.damage or 0
    local bonus = attacker.damageBonus or 0
    local armor = defender.armor or 0
    
    local totalDamage = (baseDamage + bonus) * difficulty
    local armorReduction = armor * 0.5
    local finalDamage = math.max(1, totalDamage - armorReduction)
    
    local breakdown = {
        base = baseDamage,
        bonus = bonus,
        armor = armorReduction,
        modifier = difficulty
    }
    
    return finalDamage, breakdown
end
```

### ✅ DO: Document Complex Logic

Explain "why", not just "what".

**Good Inline Documentation:**

```lua
local function calculateThreatLevel(unit, target)
    -- Threat = Damage potential + Proximity penalty
    -- Closer enemies are more threatening
    
    local damagePotential = target.maxHealth * 0.5  -- They can deal ~50% of health in one hit
    local distance = math.sqrt((unit.x - target.x)^2 + (unit.y - target.y)^2)
    
    -- Exponential proximity modifier: closer = more threat
    -- At distance=10: modifier=1.0 (full threat)
    -- At distance=100: modifier=0.1 (less threat)
    local proximityModifier = 1.0 / (distance / 10 + 1)
    
    return damagePotential * proximityModifier
end
```

### ❌ DON'T: Over-Comment Obvious Code

Comments should explain "why", not "what".

**Bad Comments:**

```lua
-- DON'T DO THIS
local health = health - 10  -- Subtract 10 from health
local x = x + speed * dt    -- Move x by speed * dt
if health <= 0 then         -- If health is 0 or less
    isAlive = false         -- Set isAlive to false
end
```

**Good Comments:**

```lua
-- Difficulty scaling: reduce damage at lower difficulties
local health = health - (baseDamage * difficultyModifier)

-- Update position with frame-rate independent movement
local x = x + speed * dt

-- Check if unit died
if health <= 0 then
    isAlive = false
end
```

### ✅ DO: Create Module Documentation

Document each module's purpose and usage.

**Module Header:**

```lua
--- CombatSystem - Handles all combat mechanics and turn resolution
-- 
-- This module manages:
-- - Attack resolution and damage calculation
-- - Hit chance calculation
-- - Critical hit mechanics
-- - Status effects application
-- - Experience/advancement
--
-- @module CombatSystem
-- @usage
--   local CombatSystem = require("game.systems.combat_system")
--   local damage = CombatSystem.calculateDamage(attacker, defender, weapon)
--   CombatSystem.resolveTurn(units)
--
-- @author Game Architect
-- @copyright 2025
-- @license MIT
--
-- Dependencies:
-- - game.units.unit
-- - game.items.weapon
-- - engine.utils.math_utils

local CombatSystem = {}

-- ... rest of module ...

return CombatSystem
```

---

## Error Handling

### ✅ DO: Use Pcall for Risky Operations

Protect against runtime errors.

**Good Error Handling:**

```lua
local function safelyLoadModule(moduleName)
    local success, module = pcall(require, moduleName)
    
    if success then
        print("[SUCCESS] Loaded module: " .. moduleName)
        return module
    else
        print("[ERROR] Failed to load module: " .. moduleName)
        print("[DETAIL] " .. module)  -- module contains error message when success=false
        return nil
    end
end

local function safelyExecuteAI(unit)
    local success, result = pcall(function()
        return unit.ai:makeDecision()
    end)
    
    if not success then
        print("[ERROR] AI failed for unit " .. unit.id)
        print("[STACK] " .. result)
        unit:takeDamageAction("default")  -- Fallback action
    else
        unit:executeAction(result)
    end
end
```

### ✅ DO: Validate Input Parameters

Check inputs before using.

**Good Validation:**

```lua
local function takeDamage(unit, amount)
    -- Validate inputs
    if not unit then
        error("takeDamage: unit is nil")
    end
    
    if type(amount) ~= "number" then
        error("takeDamage: amount must be a number, got " .. type(amount))
    end
    
    if amount < 0 then
        print("[WARNING] takeDamage: amount is negative, using 0")
        amount = 0
    end
    
    if amount > unit.maxHealth then
        print("[WARNING] takeDamage: damage exceeds max health")
        amount = unit.maxHealth
    end
    
    -- Safe to use inputs now
    unit.health = unit.health - amount
    unit.health = math.max(0, unit.health)
end
```

### ❌ DON'T: Ignore Errors Silently

Let errors bubble up or handle explicitly.

**Bad Error Handling:**

```lua
-- DON'T DO THIS
local x, y = pcall(calculatePosition, unit)  -- If pcall fails, x gets false, y gets error
local newX = x + 10  -- Tries to add 10 to false - ERROR!

-- Better:
local success, result = pcall(calculatePosition, unit)
if success then
    local x, y = result.x, result.y
else
    print("[ERROR] " .. result)
end
```

---

## Performance Optimization

### ✅ DO: Profile Before Optimizing

Measure where time is actually spent.

**Profiling Pattern:**

```lua
-- engine/utils/profiler.lua
local Profiler = {}
local timers = {}

function Profiler.start(timerName)
    timers[timerName] = love.timer.getTime()
end

function Profiler.stop(timerName)
    if not timers[timerName] then
        print("[WARNING] Timer not started: " .. timerName)
        return 0
    end
    
    local elapsed = love.timer.getTime() - timers[timerName]
    timers[timerName] = nil
    return elapsed
end

function Profiler.report(timerName, expectedMax)
    local start = love.timer.getTime()
    
    return function()
        local elapsed = love.timer.getTime() - start
        expectedMax = expectedMax or 0.016  -- 60 FPS default
        
        if elapsed > expectedMax then
            print(string.format("[PERF] %s took %.3fms (expected <%.3fms)",
                timerName, elapsed * 1000, expectedMax * 1000))
        end
    end
end

return Profiler

-- Usage
local Profiler = require("engine.utils.profiler")

function love.update(dt)
    Profiler.start("ai_update")
    AISystem:update(dt, entities)
    local aiTime = Profiler.stop("ai_update")
    
    if aiTime > 0.005 then
        print("[WARNING] AI taking too long: " .. (aiTime * 1000) .. "ms")
    end
end
```

### ✅ DO: Cache Expensive Computations

Reuse results when possible.

**Caching Pattern:**

```lua
local UnitManager = {}
local unitCache = {}
local cacheValid = false

function UnitManager.getAllUnits()
    -- Return cached list if still valid
    if cacheValid then
        return unitCache
    end
    
    -- Rebuild cache
    unitCache = {}
    for id, unit in pairs(self.units) do
        if unit.active then
            table.insert(unitCache, unit)
        end
    end
    
    cacheValid = true
    return unitCache
end

function UnitManager.addUnit(unit)
    self.units[unit.id] = unit
    cacheValid = false  -- Invalidate cache
end

function UnitManager.removeUnit(unitId)
    self.units[unitId] = nil
    cacheValid = false  -- Invalidate cache
end

return UnitManager
```

### ✅ DO: Avoid Creating Tables in Loops

Pre-allocate or reuse containers.

**Good Pattern:**

```lua
-- BAD: Creates new vector table every iteration
local function updatePositionsBad(units, dt)
    for _, unit in ipairs(units) do
        local vector = { x = unit.vx * dt, y = unit.vy * dt }  -- NEW TABLE
        unit:move(vector)
    end
end

-- GOOD: Reuse table
local function updatePositionsGood(units, dt)
    local vector = { x = 0, y = 0 }  -- Pre-allocated
    for _, unit in ipairs(units) do
        vector.x = unit.vx * dt
        vector.y = unit.vy * dt
        unit:move(vector)
    end
end

-- BEST: Direct calculation
local function updatePositionsBest(units, dt)
    for _, unit in ipairs(units) do
        unit.x = unit.x + (unit.vx * dt)
        unit.y = unit.y + (unit.vy * dt)
    end
end
```

### ✅ DO: Use Spatial Partitioning

Reduce collision checks.

**Quadtree Pattern Concept:**

```lua
-- Simplified quadtree example
local Quadtree = {}

function Quadtree:new(x, y, width, height, maxDepth)
    return {
        x = x, y = y, width = width, height = height,
        maxDepth = maxDepth or 4,
        depth = 0,
        children = nil,
        objects = {}
    }
end

function Quadtree:getNearby(x, y, range)
    -- Return only objects within range
    -- Much faster than checking all objects
    local nearby = {}
    
    -- Check this node
    for _, obj in ipairs(self.objects) do
        local dist = math.sqrt((obj.x - x)^2 + (obj.y - y)^2)
        if dist < range then
            table.insert(nearby, obj)
        end
    end
    
    return nearby
end

-- Usage: Only check collisions with nearby objects
local nearby = quadtree:getNearby(unit.x, unit.y, 100)
for _, other in ipairs(nearby) do
    if checkCollision(unit, other) then
        -- Handle collision
    end
end
```

---

## Testing & Debugging

### ✅ DO: Create Unit Tests

Test individual functions in isolation.

**Unit Test Pattern:**

```lua
-- tests/unit/combat_test.lua
local CombatSystem = require("game.systems.combat_system")

local TestCombat = {}
local testsRun = 0
local testsPassed = 0

function TestCombat:assertEqual(expected, actual, testName)
    testsRun = testsRun + 1
    if expected == actual then
        testsPassed = testsPassed + 1
        print("[PASS] " .. testName)
    else
        print("[FAIL] " .. testName)
        print("  Expected: " .. tostring(expected))
        print("  Actual: " .. tostring(actual))
    end
end

function TestCombat:testDamageCalculation()
    local attacker = { damageBonus = 10 }
    local defender = { armor = 5 }
    local weapon = { damage = 20 }
    
    local damage = CombatSystem.calculateDamage(attacker, defender, weapon)
    
    -- Should be: 20 + 10 - (5 * 0.5) = 27.5, floored to 27
    self:assertEqual(27, damage, "Basic damage calculation")
end

function TestCombat:testArmorReduction()
    local attacker = { damageBonus = 0 }
    local defender = { armor = 50 }
    local weapon = { damage = 30 }
    
    local damage = CombatSystem.calculateDamage(attacker, defender, weapon)
    
    -- Should be: 30 - (50 * 0.5) = 5
    self:assertEqual(5, damage, "Armor reduction calculation")
end

function TestCombat:runAll()
    print("Running Combat Tests...")
    self:testDamageCalculation()
    self:testArmorReduction()
    print(string.format("Tests: %d/%d passed", testsPassed, testsRun))
    return testsPassed == testsRun
end

return TestCombat

-- Usage in main
if DEBUG_MODE then
    local TestCombat = require("tests.unit.combat_test")
    TestCombat:runAll()
end
```

### ✅ DO: Use Debug Print Functions

Create standardized debug output.

**Debug Utilities:**

```lua
-- engine/utils/debug.lua
local Debug = {}

function Debug.log(module, message, data)
    local timestamp = os.date("%H:%M:%S")
    local dataStr = data and " | " .. tostring(data) or ""
    print(string.format("[%s] [%s] %s%s", timestamp, module, message, dataStr))
end

function Debug.warn(module, message, data)
    Debug.log("WARN", module .. ": " .. message, data)
end

function Debug.error(module, message, data)
    Debug.log("ERROR", module .. ": " .. message, data)
end

function Debug.assert(condition, module, message)
    if not condition then
        Debug.error(module, "Assertion failed: " .. message)
        error(message)
    end
end

return Debug

-- Usage
local Debug = require("engine.utils.debug")

function Unit:takeDamage(amount)
    Debug.log("Combat", "Unit taking damage", { unit = self.id, amount = amount })
    self.health = self.health - amount
    if self.health <= 0 then
        Debug.warn("Combat", "Unit defeated", { unit = self.id })
    end
end
```

---

## Resource Management

### ✅ DO: Load Resources in love.load()

Don't load during gameplay.

**Good Resource Loading:**

```lua
function love.load()
    -- Load all resources upfront
    _G.Assets = {
        images = {},
        sounds = {},
        fonts = {},
        data = {}
    }
    
    -- Images
    Assets.images.spriteSheet = love.graphics.newImage("assets/sprites/units.png")
    Assets.images.ui = love.graphics.newImage("assets/ui/panels.png")
    
    -- Sounds
    Assets.sounds.attack = love.audio.newSource("assets/sounds/attack.wav", "static")
    Assets.sounds.hit = love.audio.newSource("assets/sounds/hit.wav", "static")
    
    -- Fonts
    Assets.fonts.default = love.graphics.newFont("assets/fonts/default.ttf", 12)
    Assets.fonts.small = love.graphics.newFont("assets/fonts/default.ttf", 8)
    
    -- Data
    Assets.data.gameConfig = loadConfigFile("assets/data/config.lua")
    
    print("[LOAD] All assets loaded successfully")
end
```

### ✅ DO: Clean Up in love.quit()

Prevent memory leaks.

**Good Cleanup:**

```lua
function love.quit()
    print("Shutting down...")
    
    -- Clear entities
    if _G.GameState and _G.GameState.entities then
        for _, entity in ipairs(_G.GameState.entities) do
            entity:destroy()
        end
    end
    
    -- Unload sounds
    for name, sound in pairs(Assets.sounds or {}) do
        sound:release()
    end
    
    -- Save game state if needed
    if shouldAutoSave then
        saveGame("autosave.dat")
    end
    
    print("Shutdown complete")
    return false  -- Don't prevent quit
end
```

---

## Build & Deployment

### ✅ DO: Use Version Constants

Centralize version information.

**Version Management:**

```lua
-- engine/version.lua
local Version = {
    MAJOR = 1,
    MINOR = 0,
    PATCH = 0,
    BUILD = "dev"
}

function Version.getString()
    return string.format("%d.%d.%d-%s", Version.MAJOR, Version.MINOR, Version.PATCH, Version.BUILD)
end

function Version.getReleaseName()
    return "AlienFall " .. Version.getString()
end

return Version

-- Usage in conf.lua
local Version = require("engine.version")

function love.conf(t)
    t.window.title = Version.getReleaseName()
    -- ...
end

-- Usage in UI
UI:showVersionInfo(Version.getString())
```

### ✅ DO: Implement Command Line Arguments

Allow configuration at runtime.

**Command Line Arguments:**

```lua
function love.load(args)
    -- Parse command line arguments
    local config = {
        debug = false,
        fullscreen = false,
        resolution = "960x720"
    }
    
    for i, arg in ipairs(args) do
        if arg == "--debug" then
            config.debug = true
        elseif arg == "--fullscreen" then
            config.fullscreen = true
        elseif arg:match("--resolution=") then
            config.resolution = arg:match("--resolution=(.+)")
        end
    end
    
    _G.Config = config
    
    if config.debug then
        print("[DEBUG] Debug mode enabled")
    end
end

-- Launch with: love . --debug --resolution=1920x1080
```

---

## README Best Practices

### ✅ DO: Create Clear README Structure

Follow standard README format.

**README.md Template:**

```markdown
# AlienFall - Game Name

[One-line description]

## Table of Contents

- [Features](#features)
- [Getting Started](#getting-started)
- [Project Structure](#project-structure)
- [Development](#development)
- [Building & Running](#building--running)
- [Contributing](#contributing)
- [License](#license)

## Features

- [x] Turn-based combat
- [x] Procedural generation
- [x] Base management
- [ ] Multiplayer (planned)

## Getting Started

### Prerequisites
- Love2D 12.0 or higher
- Lua 5.1+

### Installation

\`\`\`bash
git clone https://github.com/user/AlienFall.git
cd AlienFall
lovec engine
\`\`\`

## Project Structure

\`\`\`
engine/
├── main.lua          # Entry point
├── core/             # Core systems
├── entities/         # Game entities
├── systems/          # Game systems (ECS)
└── utils/            # Utility functions
\`\`\`

[See docs/PROJECT_STRUCTURE.md for details](docs/PROJECT_STRUCTURE.md)

## Development

### Code Style

- Use local variables by default
- camelCase for functions/variables
- UPPER_CASE for constants
- Use module pattern for organization

[See docs/best-practices/LUA_BEST_PRACTICES.md](docs/best-practices/LUA_BEST_PRACTICES.md)

### Running Tests

\`\`\`bash
lovec engine --test
\`\`\`

## Building & Running

### Development

\`\`\`bash
lovec engine
\`\`\`

### Release Build

\`\`\`bash
love-build-release.sh
\`\`\`

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

MIT License - See LICENSE file for details
```

---

## Common Mistakes & Solutions

### ❌ Mistake: Lua 5.1 vs 5.2+ Compatibility Issues

**Problem:**
```lua
-- Lua 5.1 vs 5.2 difference
-- In Lua 5.1: unpack(table)
-- In Lua 5.2+: table.unpack(table)

local args = {1, 2, 3}
local result = unpack(args)  -- Works in 5.1, fails in 5.2+
```

**Solution:**
```lua
-- Use compatibility layer
local unpack = table.unpack or _G.unpack

local args = {1, 2, 3}
local result = unpack(args)  -- Works in both
```

### ❌ Mistake: Delta Time Not Capped

**Problem:**
```lua
function love.update(dt)
    position = position + velocity * dt
end

-- If frame drops, dt might be 0.1 (100ms)
-- Entity teleports 10x further than expected
```

**Solution:**
```lua
function love.update(dt)
    dt = math.min(dt, 0.016)  -- Max 16ms per frame (60 FPS)
    position = position + velocity * dt
end
```

### ❌ Mistake: Table Iteration Order Not Guaranteed

**Problem:**
```lua
local config = {
    setting1 = "value1",
    setting2 = "value2",
    setting3 = "value3"
}

for key, value in pairs(config) do
    print(key, value)  -- Order not guaranteed!
end
```

**Solution:**
```lua
-- Use array for ordered data
local config = {
    { key = "setting1", value = "value1" },
    { key = "setting2", value = "value2" },
    { key = "setting3", value = "value3" }
}

for i, setting in ipairs(config) do
    print(setting.key, setting.value)  -- Order guaranteed
end
```

---

**Version**: 1.0  
**Last Updated**: October 16, 2025  
**Status**: Active Best Practice Guide

*See also: TESTING_BEST_PRACTICES.md for comprehensive testing guidance*
