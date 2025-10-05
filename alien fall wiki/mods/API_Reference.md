# API Reference

> **Purpose:** Complete reference documentation for the sandboxed Lua API available to Alien Fall mods.

---

## Overview

Alien Fall mods execute in a **sandboxed Lua environment** that provides controlled access to game systems while maintaining security and stability. This document details all available APIs, functions, and services.

---

## Sandbox Environment

### Security Model

Mods run in isolated environments with:
- ✅ **Allowed:** Math, string, table operations, coroutines
- ✅ **Allowed:** Whitelisted Love2D functions
- ✅ **Allowed:** Game API via `modAPI` table
- ❌ **Restricted:** File system access (use modAPI)
- ❌ **Restricted:** Network operations
- ❌ **Restricted:** System calls
- ❌ **Restricted:** Direct game internals access

### Global Context

```lua
-- Available global tables
_G.modAPI        -- Primary mod API interface
_G.love          -- Whitelisted Love2D functions
_G.math          -- Standard Lua math library
_G.string        -- Standard Lua string library
_G.table         -- Standard Lua table library
_G.coroutine     -- Coroutine support
```

---

## Core API: modAPI

### Initialization & Lifecycle

#### modAPI:init(config)
Initialize mod with configuration.

```lua
modAPI:init({
    id = "my_mod",
    version = "1.0.0",
    debug = false
})
```

**Parameters:**
- `config` (table) - Configuration options

**Returns:** `boolean` - Success status

---

#### modAPI:shutdown()
Clean up mod resources before unload.

```lua
function onModShutdown()
    modAPI:shutdown()
end
```

**Returns:** `nil`

---

### Logging

#### modAPI:log(message, level)
Write message to game console.

```lua
modAPI:log("Weapon loaded successfully")
modAPI:log("Error loading data", "error")
modAPI:log("Debug info", "debug")
```

**Parameters:**
- `message` (string) - Log message
- `level` (string, optional) - "info", "warn", "error", "debug" (default: "info")

**Returns:** `nil`

---

#### modAPI:debug(message)
Shorthand for debug logging (only shows when debug mode enabled).

```lua
modAPI:debug("Detailed debug information")
```

---

### Service Access

#### modAPI:getService(serviceName)
Access game services.

```lua
local economy = modAPI:getService("economy")
local units = modAPI:getService("units")
local missions = modAPI:getService("missions")
```

**Parameters:**
- `serviceName` (string) - Service identifier

**Returns:** `table` - Service interface or `nil`

**Available Services:**
- `"economy"` - Economy and manufacturing
- `"units"` - Unit management
- `"missions"` - Mission system
- `"research"` - Research tree
- `"geoscape"` - Strategic layer
- `"battlescape"` - Tactical combat
- `"items"` - Item database
- `"crafts"` - Craft management

---

### Event System

#### modAPI:subscribe(eventName, handler, options)
Subscribe to game events.

```lua
local token = modAPI:subscribe("battlescape:mission_start", function(payload)
    modAPI:log("Mission started: " .. payload.mission_id)
end)
```

**Parameters:**
- `eventName` (string) - Event identifier
- `handler` (function) - Callback function
- `options` (table, optional) - Subscription options

**Returns:** `string` - Subscription token for unsubscribe

**Options:**
```lua
{
    priority = 50,      -- Execution priority (0-100)
    once = false        -- Unsubscribe after first call
}
```

---

#### modAPI:unsubscribe(token)
Remove event subscription.

```lua
modAPI:unsubscribe(subscriptionToken)
```

**Parameters:**
- `token` (string) - Subscription token from subscribe

**Returns:** `boolean` - Success status

---

#### modAPI:publish(eventName, payload)
Publish custom event.

```lua
modAPI:publish("mymod:custom_event", {
    data = "example",
    timestamp = os.time()
})
```

**Parameters:**
- `eventName` (string) - Event identifier (use mod prefix)
- `payload` (table) - Event data

**Returns:** `nil`

---

### Data Access

#### modAPI:getData(path)
Read game data by path.

```lua
-- Get all weapons
local weapons = modAPI:getData("items/weapons")

-- Get specific weapon
local rifle = modAPI:getData("items/weapons/rifle_assault")

-- Get mod data
local myData = modAPI:getData("mymod/custom_units")
```

**Parameters:**
- `path` (string) - Data path (slash-separated)

**Returns:** `table` - Data table or `nil`

---

#### modAPI:registerData(path, data)
Register mod data.

```lua
modAPI:registerData("mymod/weapons/plasma_rifle", {
    id = "mymod_plasma_rifle",
    damage = 50,
    accuracy = 85
})
```

**Parameters:**
- `path` (string) - Data path (must start with mod id)
- `data` (table) - Data to register

**Returns:** `boolean` - Success status

---

#### modAPI:overrideData(path, data)
Override existing game data.

```lua
-- Modify existing weapon
modAPI:overrideData("items/weapons/rifle_assault", {
    damage = 40  -- Increased from 35
})
```

**Parameters:**
- `path` (string) - Data path to override
- `data` (table) - Override values (merged with existing)

**Returns:** `boolean` - Success status

---

### Asset Loading

#### modAPI:loadSprite(path)
Load sprite image.

```lua
local sprite = modAPI:loadSprite("mymod/assets/sprites/rifle.png")
```

**Parameters:**
- `path` (string) - Asset path relative to mod directory

**Returns:** `Image` - Love2D image object or `nil`

---

#### modAPI:loadSound(path)
Load audio file.

```lua
local sound = modAPI:loadSound("mymod/assets/audio/fire.ogg")
```

**Parameters:**
- `path` (string) - Asset path relative to mod directory

**Returns:** `Source` - Love2D audio source or `nil`

---

#### modAPI:loadFont(path, size)
Load font file.

```lua
local font = modAPI:loadFont("mymod/assets/fonts/custom.ttf", 12)
```

**Parameters:**
- `path` (string) - Font path relative to mod directory
- `size` (number) - Font size in pixels

**Returns:** `Font` - Love2D font object or `nil`

---

### RNG (Random Number Generation)

#### modAPI:getRNG(scope)
Get seeded random number generator.

```lua
local rng = modAPI:getRNG("mymod:combat_events")
local roll = rng:random(1, 100)
```

**Parameters:**
- `scope` (string) - RNG scope identifier (use mod prefix)

**Returns:** `RNG` - Seeded RNG instance

**RNG Methods:**
```lua
rng:random()           -- Returns 0.0-1.0
rng:random(max)        -- Returns 1-max
rng:random(min, max)   -- Returns min-max
rng:randomChoice(tbl)  -- Pick random element
rng:shuffle(tbl)       -- Shuffle table in-place
rng:getSeed()          -- Get current seed
rng:setSeed(seed)      -- Set seed
```

---

### Translation

#### modAPI:translate(key, params)
Get translated string.

```lua
local name = modAPI:translate("weapons.mymod_rifle_name")
local desc = modAPI:translate("weapons.mymod_rifle_desc", {
    damage = 50
})
```

**Parameters:**
- `key` (string) - Translation key (dot-separated)
- `params` (table, optional) - Substitution parameters

**Returns:** `string` - Translated text or key if not found

---

### Widget Registration

#### modAPI:registerWidget(widgetId, widgetFactory)
Register custom UI widget.

```lua
modAPI:registerWidget("mymod_custom_panel", function(props)
    return {
        draw = function(self)
            -- Drawing code
        end,
        update = function(self, dt)
            -- Update code
        end
    }
end)
```

**Parameters:**
- `widgetId` (string) - Unique widget identifier
- `widgetFactory` (function) - Factory function returning widget

**Returns:** `boolean` - Success status

---

### Validation

#### modAPI:validateData(schema, data)
Validate data against schema.

```lua
local valid, errors = modAPI:validateData("weapon", {
    id = "mymod_rifle",
    damage = 50
})
```

**Parameters:**
- `schema` (string) - Schema name
- `data` (table) - Data to validate

**Returns:** `boolean, table` - Valid status and error list

---

### Debugging

#### modAPI:inspectGameState()
Dump current game state to console (debug mode only).

```lua
modAPI:inspectGameState()
```

---

#### modAPI:dumpModData(modId)
Dump mod data to console (debug mode only).

```lua
modAPI:dumpModData("mymod")
```

---

## Service APIs

### Economy Service

```lua
local economy = modAPI:getService("economy")
```

#### economy:getBalance()
Get current credits.

```lua
local credits = economy:getBalance()
```

---

#### economy:addCredits(amount, reason)
Add credits to economy.

```lua
economy:addCredits(1000, "Mission reward")
```

---

#### economy:startManufacturing(projectId, quantity)
Start manufacturing project.

```lua
economy:startManufacturing("mymod_plasma_rifle", 5)
```

---

#### economy:getResearchStatus(researchId)
Get research project status.

```lua
local status = economy:getResearchStatus("plasma_weapons")
-- Returns: "locked", "available", "in_progress", "complete"
```

---

### Units Service

```lua
local units = modAPI:getService("units")
```

#### units:getUnit(unitId)
Get unit by ID.

```lua
local soldier = units:getUnit("soldier_01")
```

---

#### units:getAllUnits()
Get all active units.

```lua
local allUnits = units:getAllUnits()
```

---

#### units:createUnit(template)
Create new unit from template.

```lua
local newUnit = units:createUnit({
    class = "soldier",
    name = "John Doe",
    stats = { health = 100 }
})
```

---

#### units:modifyStats(unitId, statChanges)
Modify unit statistics.

```lua
units:modifyStats("soldier_01", {
    health = 10,      -- Add 10 HP
    accuracy = 5      -- Add 5 accuracy
})
```

---

### Missions Service

```lua
local missions = modAPI:getService("missions")
```

#### missions:getMission(missionId)
Get mission data.

```lua
local mission = missions:getMission("extraction_01")
```

---

#### missions:createMission(template)
Create custom mission.

```lua
local mission = missions:createMission({
    type = "assault",
    difficulty = 3,
    map = "urban_small"
})
```

---

#### missions:getCurrentMission()
Get active mission (during battlescape).

```lua
local current = missions:getCurrentMission()
```

---

### Items Service

```lua
local items = modAPI:getService("items")
```

#### items:getItem(itemId)
Get item data.

```lua
local rifle = items:getItem("rifle_assault")
```

---

#### items:createItem(template)
Create item instance.

```lua
local newWeapon = items:createItem({
    template = "mymod_plasma_rifle",
    quality = "excellent"
})
```

---

#### items:equipItem(unitId, itemId, slot)
Equip item to unit.

```lua
items:equipItem("soldier_01", "plasma_rifle_01", "primary_weapon")
```

---

## Event Reference

### Core Events

#### game:loaded
Fired when game finishes loading.

```lua
modAPI:subscribe("game:loaded", function()
    modAPI:log("Game loaded")
end)
```

---

#### game:saving
Fired before saving game.

```lua
modAPI:subscribe("game:saving", function(payload)
    -- Save mod data
    return { custom_data = myModData }
end)
```

---

#### game:loading
Fired when loading save.

```lua
modAPI:subscribe("game:loading", function(payload)
    -- Restore mod data
    myModData = payload.mod_data.mymod
end)
```

---

### Geoscape Events

#### geoscape:mission_spawned
New mission appeared on geoscape.

```lua
modAPI:subscribe("geoscape:mission_spawned", function(payload)
    -- payload.mission_id
    -- payload.location
    -- payload.type
end)
```

---

#### geoscape:mission_expired
Mission expired without engagement.

```lua
modAPI:subscribe("geoscape:mission_expired", function(payload)
    -- payload.mission_id
end)
```

---

#### geoscape:time_tick
Time progressed on geoscape.

```lua
modAPI:subscribe("geoscape:time_tick", function(payload)
    -- payload.current_time
    -- payload.delta
end)
```

---

### Battlescape Events

#### battlescape:mission_start
Tactical mission started.

```lua
modAPI:subscribe("battlescape:mission_start", function(payload)
    -- payload.mission_id
    -- payload.map_seed
    -- payload.squad
end)
```

---

#### battlescape:mission_end
Tactical mission completed.

```lua
modAPI:subscribe("battlescape:mission_end", function(payload)
    -- payload.result ("victory", "defeat", "abort")
    -- payload.casualties
    -- payload.salvage
end)
```

---

#### battlescape:turn_start
New turn started.

```lua
modAPI:subscribe("battlescape:turn_start", function(payload)
    -- payload.turn_number
    -- payload.active_faction
end)
```

---

#### battlescape:unit_damaged
Unit took damage.

```lua
modAPI:subscribe("battlescape:unit_damaged", function(payload)
    -- payload.unit_id
    -- payload.damage
    -- payload.damage_type
    -- payload.attacker_id
end)
```

---

#### battlescape:unit_killed
Unit was killed.

```lua
modAPI:subscribe("battlescape:unit_killed", function(payload)
    -- payload.unit_id
    -- payload.killer_id
end)
```

---

### Economy Events

#### economy:research_started
Research project started.

```lua
modAPI:subscribe("economy:research_started", function(payload)
    -- payload.research_id
    -- payload.estimated_time
end)
```

---

#### economy:research_completed
Research project completed.

```lua
modAPI:subscribe("economy:research_completed", function(payload)
    -- payload.research_id
    -- payload.unlocks
end)
```

---

#### economy:manufacturing_completed
Manufacturing project completed.

```lua
modAPI:subscribe("economy:manufacturing_completed", function(payload)
    -- payload.item_id
    -- payload.quantity
end)
```

---

## Constants

### Grid Constants

```lua
modAPI.GRID_SIZE = 20          -- Logical grid unit size
modAPI.VIEWPORT_WIDTH = 800    -- Internal resolution width
modAPI.VIEWPORT_HEIGHT = 600   -- Internal resolution height
modAPI.GRID_WIDTH = 40         -- Grid units horizontally
modAPI.GRID_HEIGHT = 30        -- Grid units vertically
```

---

### Damage Types

```lua
modAPI.DAMAGE_KINETIC = "kinetic"
modAPI.DAMAGE_ENERGY = "energy"
modAPI.DAMAGE_PLASMA = "plasma"
modAPI.DAMAGE_EXPLOSIVE = "explosive"
modAPI.DAMAGE_CHEMICAL = "chemical"
modAPI.DAMAGE_PSIONIC = "psionic"
```

---

### Unit Stats

```lua
modAPI.STAT_HEALTH = "health"
modAPI.STAT_STAMINA = "stamina"
modAPI.STAT_ACCURACY = "accuracy"
modAPI.STAT_REFLEXES = "reflexes"
modAPI.STAT_STRENGTH = "strength"
modAPI.STAT_MIND = "mind"
modAPI.STAT_MORALE = "morale"
```

---

## Example: Complete Mod

```lua
-- scripts/init.lua
local MyMod = {}

-- Initialize mod
function MyMod:init()
    modAPI:log("[MyMod] Initializing...")
    
    -- Get RNG instance
    self.rng = modAPI:getRNG("mymod:events")
    
    -- Register custom data
    self:registerWeapons()
    
    -- Subscribe to events
    self:setupEventHandlers()
    
    modAPI:log("[MyMod] Initialization complete")
end

-- Register custom weapons
function MyMod:registerWeapons()
    local weaponData = {
        id = "mymod_plasma_rifle",
        name = modAPI:translate("weapons.mymod_rifle_name"),
        damage = 50,
        accuracy = 85,
        ap_cost = 3
    }
    
    modAPI:registerData("mymod/weapons/plasma_rifle", weaponData)
end

-- Setup event handlers
function MyMod:setupEventHandlers()
    -- Mission start event
    modAPI:subscribe("battlescape:mission_start", function(payload)
        self:onMissionStart(payload)
    end)
    
    -- Unit damaged event
    modAPI:subscribe("battlescape:unit_damaged", function(payload)
        self:onUnitDamaged(payload)
    end)
end

-- Handle mission start
function MyMod:onMissionStart(payload)
    modAPI:log("Mission started: " .. payload.mission_id)
    
    -- Add bonus credits
    local economy = modAPI:getService("economy")
    economy:addCredits(500, "Mission start bonus")
end

-- Handle unit damage
function MyMod:onUnitDamaged(payload)
    -- Special effect for plasma weapons
    if payload.damage_type == modAPI.DAMAGE_PLASMA then
        modAPI:publish("mymod:plasma_damage", {
            unit_id = payload.unit_id,
            damage = payload.damage
        })
    end
end

-- Initialize on load
MyMod:init()

return MyMod
```

---

## Best Practices

### Performance

1. **Cache service references**
```lua
-- GOOD: Cache once
local economy = modAPI:getService("economy")

-- BAD: Get every time
for i = 1, 100 do
    modAPI:getService("economy"):addCredits(1)
end
```

2. **Use local variables**
```lua
-- GOOD
local function calculate()
    local result = 0
    for i = 1, 100 do
        result = result + i
    end
    return result
end

-- BAD (slower global access)
function calculate()
    result = 0
    for i = 1, 100 do
        result = result + i
    end
    return result
end
```

3. **Unsubscribe unused event handlers**
```lua
local token = modAPI:subscribe("event", handler)
-- Later...
modAPI:unsubscribe(token)
```

---

### Error Handling

```lua
-- Always use pcall for risky operations
local success, result = pcall(function()
    return modAPI:getData("might/not/exist")
end)

if success then
    -- Use result
else
    modAPI:log("Error: " .. tostring(result), "error")
end
```

---

### Determinism

```lua
-- CORRECT: Use seeded RNG
local rng = modAPI:getRNG("mymod:events")
local value = rng:random(1, 100)

-- WRONG: Breaks determinism
local value = math.random(1, 100)  -- DON'T DO THIS
```

---

## Additional Resources

- **[Modding Hub](README.md)** - Main modding documentation
- **[Getting Started](Getting_Started.md)** - Tutorial for beginners
- **[Data Formats](Data_Formats.md)** - TOML schema reference
- **[Content Override System](Content_Override_System.md)** - Override mechanics

---

## Tags
`#api` `#reference` `#lua` `#modding` `#scripting`
