# Engine Folder - Core Game Implementation

**Purpose:** Store executable game code implementing all systems  
**Audience:** Developers, engineers, technical team  
**Format:** Lua source files (.lua)

---

## What Goes in engine/

### Structure
```
engine/
├── main.lua                     Game entry point
├── conf.lua                     Love2D configuration
│
├── core/                        Core systems
│   ├── state_manager.lua       Global state management
│   ├── event_bus.lua           Event system
│   ├── entity_factory.lua      Create entities from data
│   └── save_load.lua           Save/load system
│
├── mods/                        Mod loading system
│   ├── mod_loader.lua          Discover and load mods
│   ├── content_registry.lua    Store loaded content
│   └── mod_validator.lua       Validate mod files
│
├── geoscape/                    World map layer
│   ├── world.lua               World state
│   ├── base.lua                Base management
│   ├── craft.lua               Aircraft
│   └── mission_generator.lua   Mission creation
│
├── battlescape/                 Tactical combat layer
│   ├── battle.lua              Combat state
│   ├── units/                  Unit systems
│   ├── combat/                 Combat resolution
│   └── ai/                     AI behavior
│
├── basescape/                   Base management
│   ├── base_view.lua           Base screen
│   ├── facilities.lua          Facility management
│   └── personnel.lua           Soldier/staff management
│
├── economy/                     Economic systems
│   ├── market.lua              Buy/sell
│   ├── manufacturing.lua       Item production
│   └── research.lua            Tech progression
│
├── gui/                         UI components
│   ├── widgets/                Reusable UI elements
│   ├── screens/                Game screens
│   └── theme.lua               UI styling
│
├── ai/                          AI systems
│   ├── tactical_ai.lua         Combat AI
│   ├── strategic_ai.lua        Campaign AI
│   └── behavior_tree.lua       AI framework
│
├── utils/                       Utility functions
│   ├── math_utils.lua          Math helpers
│   ├── table_utils.lua         Table operations
│   └── string_utils.lua        String manipulation
│
└── libs/                        External libraries
    ├── toml.lua                TOML parser
    ├── json.lua                JSON parser
    └── ...                     Other dependencies
```

---

## Core Principle: Implementation of Contracts

**Engine implements what API defines:**

```
API Contract (api/UNITS.md):
  function gainExperience(amount: integer) → void
  
Engine Implementation (engine/battlescape/units/unit.lua):
  function Unit:gainExperience(amount)
      -- Validates per API contract
      assert(type(amount) == "number", "Amount must be integer")
      assert(amount >= 0, "Cannot be negative")
      
      -- Implements design spec logic
      self.experience = self.experience + amount
      
      -- Check promotion threshold (from design)
      if self.experience >= self.xp_threshold then
          self.can_promote = true
      end
  end
```

**Key Rules:**
- Implements ALL API contracts
- Follows architecture structure
- No hardcoded content (uses mods/)
- Comprehensive error handling
- Performance-conscious

---

## Content Guidelines

### What Belongs Here
- ✅ Game logic implementation
- ✅ System behavior code
- ✅ Algorithms and calculations
- ✅ State management
- ✅ Event handling
- ✅ Performance-critical code
- ✅ Framework integration (Love2D)

### What Does NOT Belong Here
- ❌ Game content (units, items, levels) - goes in mods/
- ❌ Design rationale - goes in design/
- ❌ API contracts - goes in api/
- ❌ Architecture diagrams - goes in architecture/
- ❌ Configuration values - goes in mods/
- ❌ Test code - goes in tests2/

---

## Code Structure Patterns

### Pattern 1: Class Definition

```lua
-- engine/battlescape/units/unit.lua

local Unit = {}
Unit.__index = Unit

-- Constructor
function Unit.new(id, name, rank)
    local self = setmetatable({}, Unit)
    
    -- Initialize from parameters
    self.id = id
    self.name = name
    self.rank = rank
    
    -- Initialize to defaults
    self.experience = 0
    self.can_promote = false
    self.health_current = 100
    self.health_max = 100
    
    return self
end

-- Methods
function Unit:gainExperience(amount)
    -- Implementation
end

function Unit:promote()
    -- Implementation
end

function Unit:takeDamage(damage)
    -- Implementation
end

return Unit
```

---

### Pattern 2: Module Organization

```lua
-- engine/battlescape/battle.lua

local Battle = {}

-- Dependencies
local Unit = require("engine.battlescape.units.unit")
local HexGrid = require("engine.battlescape.hex_grid")
local EventBus = require("engine.core.event_bus")

-- Private functions
local function validateTurn(battle)
    -- Helper function
end

-- Public API
function Battle.new(map_id)
    local self = {
        map_id = map_id,
        units = {},
        turn = 1,
        state = "setup"
    }
    return setmetatable(self, { __index = Battle })
end

function Battle:update(dt)
    -- Game loop update
end

function Battle:draw()
    -- Rendering
end

return Battle
```

---

### Pattern 3: Data-Driven Loading

```lua
-- engine/core/entity_factory.lua

local EntityFactory = {}

function EntityFactory:createUnit(unit_id)
    -- Get definition from content registry
    local ContentRegistry = require("engine.mods.content_registry")
    local def = ContentRegistry:get("unit", unit_id)
    
    if not def then
        error("Unit not found: " .. unit_id)
    end
    
    -- Create instance from data
    local Unit = require("engine.battlescape.units.unit")
    local unit = Unit.new(def.id, def.name, 1)
    
    -- Apply properties from TOML
    unit.strength = def.strength
    unit.dexterity = def.dexterity or 7
    unit.constitution = def.constitution or 9
    unit.health_max = def.health
    unit.health_current = def.health
    
    -- Load sprite
    local AssetLoader = require("engine.assets.asset_loader")
    unit.sprite = AssetLoader:getSprite(def.sprite)
    
    return unit
end

return EntityFactory
```

---

### Pattern 4: Event-Driven Architecture

```lua
-- engine/core/event_bus.lua

local EventBus = {
    listeners = {}
}

function EventBus:subscribe(event_name, callback)
    if not self.listeners[event_name] then
        self.listeners[event_name] = {}
    end
    table.insert(self.listeners[event_name], callback)
end

function EventBus:emit(event_name, data)
    local listeners = self.listeners[event_name]
    if listeners then
        for _, callback in ipairs(listeners) do
            callback(data)
        end
    end
end

-- Usage:
-- EventBus:subscribe("unit_killed", function(data)
--     print("Unit killed: " .. data.unit_id)
-- end)
-- 
-- EventBus:emit("unit_killed", { unit_id = "rookie_1" })

return EventBus
```

---

## Integration with Other Folders

### design/ → engine/
Design specs guide implementation:
- **Design:** "Units gain 5 XP per kill"
- **Engine:** Implements exactly as specified

### api/ → engine/
API contracts must be implemented:
- **API:** Defines `gainExperience(amount: integer)`
- **Engine:** Implements function with exact signature

### architecture/ → engine/
Code structure follows diagrams:
- **Architecture:** Shows Battle → UnitManager → Unit
- **Engine:** Implements this exact structure

### engine/ → mods/
Engine loads content, never hardcodes:
- **Engine:** Calls `ContentRegistry:get("unit", "rookie")`
- **Mods:** Provides unit data in TOML

### engine/ → tests2/
All public functions tested:
- **Engine:** `function Unit:gainExperience(amount)`
- **Tests:** `tests2/battlescape/unit_test.lua`

---

## Love2D Framework Integration

### Main Entry Point

```lua
-- engine/main.lua

-- Require core systems
local StateManager = require("engine.core.state_manager")
local ModLoader = require("engine.mods.mod_loader")

function love.load()
    -- Initialize
    print("AlienFall starting...")
    
    -- Load mods (content)
    ModLoader:loadAllMods("mods/")
    
    -- Initialize game state
    StateManager:setState("main_menu")
    
    print("Game loaded successfully")
end

function love.update(dt)
    -- Update current state
    StateManager:update(dt)
end

function love.draw()
    -- Render current state
    StateManager:draw()
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
    StateManager:keypressed(key)
end
```

### Configuration

```lua
-- engine/conf.lua

function love.conf(t)
    t.title = "AlienFall"
    t.version = "11.4"
    t.window.width = 1280
    t.window.height = 720
    t.window.resizable = true
    t.window.vsync = 1
    
    t.modules.joystick = false
    t.modules.physics = false
    
    t.console = true  -- Enable console for debugging
end
```

---

## Error Handling Patterns

### Pattern 1: Defensive Programming

```lua
function Unit:gainExperience(amount)
    -- Validate inputs
    if type(amount) ~= "number" then
        error("gainExperience: amount must be number, got " .. type(amount))
    end
    
    if amount < 0 then
        error("gainExperience: amount cannot be negative: " .. amount)
    end
    
    -- Safe execution
    self.experience = self.experience + amount
    
    -- Check for overflow (optional safety)
    if self.experience > 999999 then
        self.experience = 999999
    end
end
```

### Pattern 2: pcall for Risky Operations

```lua
function ModLoader:loadMod(mod_path)
    local ok, result = pcall(function()
        local toml_content = love.filesystem.read(mod_path .. "/mod.toml")
        return TOML.parse(toml_content)
    end)
    
    if not ok then
        print("[ERROR] Failed to load mod: " .. mod_path)
        print("[ERROR] " .. result)
        return nil
    end
    
    return result
end
```

---

## Performance Best Practices

### 1. Avoid Creating Garbage

```lua
-- BAD: Creates new table every frame
function Battle:update(dt)
    local active_units = {}  -- New table allocation!
    for _, unit in ipairs(self.units) do
        if unit.active then
            table.insert(active_units, unit)
        end
    end
end

-- GOOD: Reuse table
function Battle:update(dt)
    -- Clear existing table instead of allocating new
    for i = #self.active_units_cache, 1, -1 do
        self.active_units_cache[i] = nil
    end
    
    for _, unit in ipairs(self.units) do
        if unit.active then
            table.insert(self.active_units_cache, unit)
        end
    end
end
```

### 2. Cache Lookups

```lua
-- BAD: Repeated table lookups
for i = 1, 100 do
    if self.units[i].health > self.units[i].health_max * 0.5 then
        self.units[i].state = "healthy"
    end
end

-- GOOD: Cache in local variable
for i = 1, 100 do
    local unit = self.units[i]  -- Single lookup
    if unit.health > unit.health_max * 0.5 then
        unit.state = "healthy"
    end
end
```

### 3. Use Local Functions

```lua
-- GOOD: Local function (faster lookup)
local function calculateDamage(attacker, defender)
    return math.max(0, attacker.strength - defender.defense)
end

function Battle:resolveCombat(attacker, defender)
    local damage = calculateDamage(attacker, defender)
    defender:takeDamage(damage)
end
```

---

## Validation

### Engine Quality Checklist

- [ ] All API contracts implemented
- [ ] Follows architecture structure
- [ ] No hardcoded content
- [ ] Error handling present
- [ ] Performance conscious (no garbage in hot paths)
- [ ] Code documented (comments explain WHY, not WHAT)
- [ ] Tests written and passing (>75% coverage)
- [ ] No globals (use local and require)
- [ ] Consistent code style
- [ ] Love2D callbacks properly used

---

## Tools

### Engine Structure Analyzer
```bash
lua tools/generators/analyze_engine_structure.lua

# Outputs:
# - Module dependency graph
# - Circular dependency detection
# - Untested modules list
# - Dead code detection
```

### Import Scanner
```bash
lua tools/validators/import_scanner.lua engine/

# Validates:
# - All require() statements resolve
# - No missing files
# - No circular dependencies
```

### Performance Profiler
```bash
# In-game profiling
lua engine/utils/profiler.lua enable
# Play game
lua engine/utils/profiler.lua report

# Shows:
# - Function call counts
# - Time spent per function
# - Memory allocations
# - Hot paths
```

---

## Best Practices

### 1. Follow Love2D Callbacks
Structure around Love2D's callback system:
- `love.load()` - Initialize
- `love.update(dt)` - Logic updates
- `love.draw()` - Rendering
- `love.keypressed(key)` - Input handling

### 2. Separate Logic and Rendering
```lua
-- Update game state
function Unit:update(dt)
    self.animation_timer = self.animation_timer + dt
    -- Logic only, no drawing
end

-- Render current state
function Unit:draw()
    love.graphics.draw(self.sprite, self.x, self.y)
    -- Rendering only, no logic
end
```

### 3. Use require() Correctly
```lua
-- Cache requires (module loaded once)
local Unit = require("engine.battlescape.units.unit")

-- Not inside functions (slow repeated loading)
function createUnit()
    local Unit = require("engine.battlescape.units.unit")  -- BAD!
    return Unit.new()
end
```

### 4. Document Complex Logic
```lua
-- GOOD: Explain WHY, not WHAT
function calculateHitChance(attacker, defender)
    -- We use square root to soften the advantage curve
    -- so that high-skilled units don't become unstoppable
    local base_chance = 50
    local skill_diff = attacker.skill - defender.skill
    local modifier = math.sqrt(math.abs(skill_diff)) * 5
    
    if skill_diff > 0 then
        return base_chance + modifier
    else
        return base_chance - modifier
    end
end
```

### 5. Handle Edge Cases
```lua
function Unit:takeDamage(damage)
    -- Handle negative damage (healing)
    if damage < 0 then
        self:heal(math.abs(damage))
        return
    end
    
    -- Apply damage
    self.health_current = self.health_current - damage
    
    -- Handle death
    if self.health_current <= 0 then
        self.health_current = 0
        self:die()
    end
end
```

### 6. Use Constants
```lua
-- Define at module level
local TILE_SIZE = 24
local MAX_UNITS = 20
local XP_PER_KILL = 5

function Battle:spawnUnit(x, y)
    local pixel_x = x * TILE_SIZE
    local pixel_y = y * TILE_SIZE
    -- Use constants, not magic numbers
end
```

---

## Maintenance

**On API Change:**
- Update engine implementation to match new contract
- Update tests
- Verify architecture still matches

**Monthly:**
- Run import scanner (detect dead code)
- Run performance profiler (find slow functions)
- Review for code quality improvements

**Per Release:**
- Full test suite run
- Performance benchmarks
- Code review for new features

---

**See:** engine/README.md for complete development guide

**Related:**
- [modules/02_API_FOLDER.md](02_API_FOLDER.md) - APIs engine implements
- [modules/03_ARCHITECTURE_FOLDER.md](03_ARCHITECTURE_FOLDER.md) - Structure engine follows
- [modules/05_MODS_FOLDER.md](05_MODS_FOLDER.md) - Content engine loads
- [modules/06_TESTS2_FOLDER.md](06_TESTS2_FOLDER.md) - Tests validating engine

