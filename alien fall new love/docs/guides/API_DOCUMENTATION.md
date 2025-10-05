# Alien Fall API Documentation

**Version:** 1.0  
**Last Updated:** September 30, 2025  
**Target Audience:** Modders, Developers, Contributors

---

## Table of Contents

1. [Core Systems](#core-systems)
2. [Engine Services](#engine-services)
3. [Geoscape Systems](#geoscape-systems)
4. [Battlescape Systems](#battlescape-systems)
5. [UI Widgets](#ui-widgets)
6. [Utility Functions](#utility-functions)
7. [Modding API](#modding-api)

---

## Core Systems

### Service Registry

**Location:** `src/core/services/registry.lua`

The Service Registry provides centralized access to game services.

#### Functions

##### `ServiceRegistry.initialize(config)`
Initialize the service registry with configuration.

**Parameters:**
- `config` (table): Configuration options
  - `event_bus` (EventBus): Event bus instance
  - `logger` (Logger): Logger instance
  - `telemetry` (Telemetry): Telemetry instance

**Returns:** None

**Example:**
```lua
local ServiceRegistry = require("core.services.registry")
ServiceRegistry.initialize({
    event_bus = eventBus,
    logger = logger,
    telemetry = telemetry
})
```

##### `ServiceRegistry.get(serviceName)`
Retrieve a registered service by name.

**Parameters:**
- `serviceName` (string): Name of the service to retrieve

**Returns:** Service instance or nil if not found

**Example:**
```lua
local rngService = ServiceRegistry.get("rng")
```

##### `ServiceRegistry.register(serviceName, serviceInstance)`
Register a new service in the registry.

**Parameters:**
- `serviceName` (string): Unique service identifier
- `serviceInstance` (any): Service instance to register

**Returns:** None

**Example:**
```lua
ServiceRegistry.register("custom_service", MyService:new())
```

---

### Event Bus

**Location:** `src/engine/event_bus.lua`

The Event Bus provides pub/sub messaging between game systems.

#### Class: `EventBus`

##### `EventBus:new()`
Create a new EventBus instance.

**Returns:** EventBus instance

##### `EventBus:publish(event, data)`
Publish an event to all subscribers.

**Parameters:**
- `event` (string): Event name
- `data` (table): Event payload (optional)

**Returns:** None

**Example:**
```lua
eventBus:publish("unit:damaged", {
    unitId = 123,
    damage = 10,
    source = "alien_plasma"
})
```

##### `EventBus:subscribe(event, callback, owner)`
Subscribe to an event.

**Parameters:**
- `event` (string): Event name to subscribe to
- `callback` (function): Function to call when event fires
- `owner` (any): Owner reference for cleanup (optional)

**Returns:** Subscription ID (number)

**Example:**
```lua
local subId = eventBus:subscribe("turn:ended", function(data)
    print("Turn ended: " .. data.turnNumber)
end, self)
```

##### `EventBus:unsubscribe(subscriptionId)`
Unsubscribe from an event.

**Parameters:**
- `subscriptionId` (number): Subscription ID returned from subscribe()

**Returns:** boolean (true if unsubscribed successfully)

##### `EventBus:unsubscribeAll(owner)`
Unsubscribe all events for an owner.

**Parameters:**
- `owner` (any): Owner reference used in subscribe()

**Returns:** number (count of unsubscribed events)

**Example:**
```lua
-- Cleanup all subscriptions when screen closes
eventBus:unsubscribeAll(self)
```

---

### Logger

**Location:** `src/engine/logger.lua`

The Logger provides structured logging with multiple levels.

#### Class: `Logger`

##### `Logger:new(config)`
Create a new Logger instance.

**Parameters:**
- `config` (table): Logger configuration
  - `level` (string): Minimum log level ("DEBUG", "INFO", "WARN", "ERROR")
  - `output` (string): Output destination ("console", "file", "both")

**Returns:** Logger instance

##### `Logger:debug(message, context)`
Log debug message.

**Parameters:**
- `message` (string): Debug message
- `context` (string): Context identifier (optional)

##### `Logger:info(message, context)`
Log informational message.

**Parameters:**
- `message` (string): Info message
- `context` (string): Context identifier (optional)

##### `Logger:warn(message, context)`
Log warning message.

**Parameters:**
- `message` (string): Warning message
- `context` (string): Context identifier (optional)

##### `Logger:error(message, context)`
Log error message.

**Parameters:**
- `message` (string): Error message
- `context` (string): Context identifier (optional)

**Example:**
```lua
logger:debug("Pathfinding calculation started", "AI")
logger:info("Mission detected: UFO in Province A")
logger:warn("Low ammunition in squad 1", "Combat")
logger:error("Failed to load save file: corrupted data", "SaveLoad")
```

---

### RNG (Random Number Generator)

**Location:** `src/services/rng.lua`

The RNG service provides deterministic random number generation with scopes.

#### Class: `RNGService`

##### `RNGService:new(config)`
Create a new RNG service.

**Parameters:**
- `config` (table): RNG configuration
  - `master_seed` (number): Master seed for determinism

**Returns:** RNGService instance

##### `RNGService:createScope(scopeName, seed)`
Create a new random number scope.

**Parameters:**
- `scopeName` (string): Unique scope identifier
- `seed` (number): Seed for this scope (optional, uses master seed if omitted)

**Returns:** RNG scope object

**Example:**
```lua
local combatRNG = rngService:createScope("combat", 12345)
local damageRoll = combatRNG:random(1, 20)
```

##### `RNGService:getScope(scopeName)`
Retrieve an existing RNG scope.

**Parameters:**
- `scopeName` (string): Scope identifier

**Returns:** RNG scope or nil

##### `RNGService:resetScope(scopeName)`
Reset a scope to its initial seed.

**Parameters:**
- `scopeName` (string): Scope identifier

**Returns:** boolean (success)

---

### Safe I/O Utilities

**Location:** `src/utils/safe_io.lua`

Safe I/O functions that handle errors gracefully.

#### Functions

##### `SafeIO.safe_require(modulePath, fallback)`
Safely require a module with fallback.

**Parameters:**
- `modulePath` (string): Path to module
- `fallback` (any): Fallback value if require fails

**Returns:** Module or fallback value

**Example:**
```lua
local config = SafeIO.safe_require("config.game", {default=true})
```

##### `SafeIO.safe_load_toml(filepath, fallback)`
Safely load a TOML file with fallback.

**Parameters:**
- `filepath` (string): Path to TOML file
- `fallback` (table): Fallback data if load fails

**Returns:** Parsed TOML data or fallback

**Example:**
```lua
local modData = SafeIO.safe_load_toml("mods/my_mod/manifest.toml", {})
```

##### `SafeIO.safe_load_image(filepath, fallback)`
Safely load an image with fallback.

**Parameters:**
- `filepath` (string): Path to image file
- `fallback` (Image): Fallback image if load fails

**Returns:** Image or fallback

##### `SafeIO.safe_load_font(filepath, size, fallback)`
Safely load a font with fallback.

**Parameters:**
- `filepath` (string): Path to font file
- `size` (number): Font size
- `fallback` (Font): Fallback font if load fails

**Returns:** Font or fallback

---

## Engine Services

### Asset Cache

**Location:** `src/engine/asset_cache.lua`

The Asset Cache manages loading and caching of game assets with LRU eviction.

#### Class: `AssetCache`

##### `AssetCache:new(maxSize)`
Create a new asset cache.

**Parameters:**
- `maxSize` (number): Maximum cache size in entries (default: 1000)

**Returns:** AssetCache instance

##### `AssetCache:loadImage(path)`
Load and cache an image.

**Parameters:**
- `path` (string): Path to image file

**Returns:** Love2D Image object

**Example:**
```lua
local sprite = assetCache:loadImage("assets/units/soldier.png")
```

##### `AssetCache:loadFont(path, size)`
Load and cache a font.

**Parameters:**
- `path` (string): Path to font file
- `size` (number): Font size in pixels

**Returns:** Love2D Font object

##### `AssetCache:loadSound(path)`
Load and cache a sound effect.

**Parameters:**
- `path` (string): Path to sound file

**Returns:** Love2D Source object

##### `AssetCache:clear()`
Clear all cached assets.

**Returns:** None

---

### Performance Cache

**Location:** `src/utils/performance_cache.lua`

The Performance Cache provides LRU caching for expensive calculations.

#### Class: `PerformanceCache`

##### `PerformanceCache:new(maxSize)`
Create a new performance cache.

**Parameters:**
- `maxSize` (number): Maximum cache entries (default: 1000)

**Returns:** PerformanceCache instance

##### `PerformanceCache:cachePath(startX, startY, goalX, goalY, unitId, path, currentTurn)`
Cache a pathfinding result.

**Parameters:**
- `startX, startY` (number): Start coordinates
- `goalX, goalY` (number): Goal coordinates
- `unitId` (number): Unit identifier
- `path` (table): Calculated path
- `currentTurn` (number): Current game turn

**Returns:** None

##### `PerformanceCache:getPath(startX, startY, goalX, goalY, unitId, currentTurn)`
Retrieve a cached path.

**Parameters:**
- `startX, startY` (number): Start coordinates
- `goalX, goalY` (number): Goal coordinates
- `unitId` (number): Unit identifier
- `currentTurn` (number): Current game turn

**Returns:** Cached path or nil

##### `PerformanceCache:cacheLOS(unitId, unitX, unitY, isNight, visibleTiles, currentTurn)`
Cache line-of-sight calculation.

**Parameters:**
- `unitId` (number): Unit identifier
- `unitX, unitY` (number): Unit coordinates
- `isNight` (boolean): Night flag
- `visibleTiles` (table): List of visible tiles
- `currentTurn` (number): Current game turn

**Returns:** None

##### `PerformanceCache:getLOS(unitId, unitX, unitY, isNight, currentTurn)`
Retrieve cached line-of-sight.

**Parameters:**
- `unitId` (number): Unit identifier
- `unitX, unitY` (number): Unit coordinates
- `isNight` (boolean): Night flag
- `currentTurn` (number): Current game turn

**Returns:** Cached visibility or nil

##### `PerformanceCache:getStatistics()`
Get cache performance statistics.

**Returns:** Table with hit rates, sizes, and eviction counts

**Example:**
```lua
local stats = cache:getStatistics()
print(string.format("Path cache hit rate: %.1f%%", stats.path.hitRate * 100))
```

---

## Geoscape Systems

### World

**Location:** `src/geoscape/World.lua`

The World manages the geoscape game state.

#### Class: `World`

##### `World:new(config)`
Create a new World instance.

**Parameters:**
- `config` (table): World configuration

**Returns:** World instance

##### `World:addProvince(province)`
Add a province to the world.

**Parameters:**
- `province` (Province): Province instance

**Returns:** None

##### `World:getProvince(provinceId)`
Get a province by ID.

**Parameters:**
- `provinceId` (string): Province identifier

**Returns:** Province instance or nil

##### `World:addCountry(country)`
Add a country to the world.

**Parameters:**
- `country` (Country): Country instance

**Returns:** None

##### `World:update(dt)`
Update world state (time passage, illumination, etc.).

**Parameters:**
- `dt` (number): Delta time in seconds

**Returns:** None

---

### Province

**Location:** `src/geoscape/Province.lua`

Represents a geographic province in the game world.

#### Class: `Province`

##### `Province:new(data)`
Create a new Province.

**Parameters:**
- `data` (table): Province data
  - `id` (string): Unique identifier
  - `name` (string): Display name
  - `position` (table): {x, y} coordinates
  - `biome` (string): Biome type

**Returns:** Province instance

##### `Province:addMission(mission)`
Add a mission to this province.

**Parameters:**
- `mission` (Mission): Mission instance

**Returns:** None

##### `Province:getMissions()`
Get all active missions in this province.

**Returns:** Table of Mission instances

##### `Province:setOccupied(occupied)`
Set province occupation status.

**Parameters:**
- `occupied` (boolean): Occupation flag

**Returns:** None

---

## Battlescape Systems

### Pathfinding

**Location:** `src/battlescape/Pathfinding.lua`

A* pathfinding implementation for tactical movement.

#### Class: `Pathfinding`

##### `Pathfinding:new(map, cache)`
Create a new Pathfinding system.

**Parameters:**
- `map` (BattleMap): Battle map reference
- `cache` (PerformanceCache): Optional performance cache

**Returns:** Pathfinding instance

##### `Pathfinding:findPath(startX, startY, goalX, goalY, unit, maxDistance)`
Find a path between two points.

**Parameters:**
- `startX, startY` (number): Start coordinates
- `goalX, goalY` (number): Goal coordinates
- `unit` (Unit): Unit for movement costs
- `maxDistance` (number): Maximum path length (optional)

**Returns:** Table of {x, y} coordinates or nil

**Example:**
```lua
local path = pathfinding:findPath(1, 1, 10, 10, unit, 50)
if path then
    for i, node in ipairs(path) do
        print(string.format("Step %d: (%d, %d)", i, node.x, node.y))
    end
end
```

##### `Pathfinding:getMovementRange(startX, startY, unit, maxAP)`
Calculate reachable tiles for a unit.

**Parameters:**
- `startX, startY` (number): Start coordinates
- `unit` (Unit): Unit data
- `maxAP` (number): Maximum action points

**Returns:** Table of reachable tiles with costs

##### `Pathfinding:setCurrentTurn(turn)`
Update current turn for cache TTL.

**Parameters:**
- `turn` (number): Current game turn

**Returns:** None

##### `Pathfinding:invalidateCache()`
Invalidate pathfinding cache (call when map changes).

**Returns:** None

---

### Line of Sight

**Location:** `src/battlescape/LineOfSight.lua`

Visibility and fog-of-war calculations.

#### Class: `LineOfSight`

##### `LineOfSight:new(missionSeed, map, cache)`
Create a new LineOfSight system.

**Parameters:**
- `missionSeed` (number): Mission seed for determinism
- `map` (BattleMap): Battle map reference
- `cache` (PerformanceCache): Optional performance cache

**Returns:** LineOfSight instance

##### `LineOfSight:calculateUnitVisibility(unit, maxRange, isNight, environmentalEffects)`
Calculate visible tiles for a unit.

**Parameters:**
- `unit` (Unit): Unit entity
- `maxRange` (number): Maximum sight range
- `isNight` (boolean): Night flag
- `environmentalEffects` (table): Environmental effects

**Returns:** Table of visible tiles with distances

##### `LineOfSight:isTileVisibleToTeam(x, y)`
Check if tile is visible to player team.

**Parameters:**
- `x, y` (number): Tile coordinates

**Returns:** boolean

##### `LineOfSight:getTileFogState(x, y)`
Get fog-of-war state for a tile.

**Parameters:**
- `x, y` (number): Tile coordinates

**Returns:** String ("unexplored", "explored_dark", "visible")

---

## UI Widgets

### Button

**Location:** `src/widgets/Button.lua`

Interactive button widget.

#### Class: `Button`

##### `Button:new(x, y, width, height, text, callback)`
Create a new button.

**Parameters:**
- `x, y` (number): Position (in grid units)
- `width, height` (number): Size (in grid units)
- `text` (string): Button label
- `callback` (function): Click callback

**Returns:** Button instance

**Example:**
```lua
local button = Button:new(10, 20, 6, 2, "Start Mission", function()
    print("Mission started!")
    gameState:switchToState("battlescape")
end)
```

##### `Button:update(dt, mx, my)`
Update button state (hover, etc.).

**Parameters:**
- `dt` (number): Delta time
- `mx, my` (number): Mouse coordinates

**Returns:** None

##### `Button:draw()`
Draw the button.

**Returns:** None

##### `Button:mousepressed(mx, my, button)`
Handle mouse press events.

**Parameters:**
- `mx, my` (number): Mouse coordinates
- `button` (number): Mouse button (1=left, 2=right, 3=middle)

**Returns:** boolean (true if button handled the click)

---

### Table

**Location:** `src/widgets/Table.lua`

Data table widget with sorting and scrolling.

#### Class: `Table`

##### `Table:new(x, y, width, height, columns)`
Create a new table widget.

**Parameters:**
- `x, y` (number): Position (in grid units)
- `width, height` (number): Size (in grid units)
- `columns` (table): Column definitions
  - `header` (string): Column header text
  - `width` (number): Column width ratio
  - `key` (string): Data key for this column

**Returns:** Table instance

**Example:**
```lua
local unitTable = Table:new(2, 5, 36, 20, {
    {header="Name", width=0.3, key="name"},
    {header="HP", width=0.2, key="health"},
    {header="Rank", width=0.2, key="rank"},
    {header="Status", width=0.3, key="status"}
})
```

##### `Table:setData(data)`
Set table data.

**Parameters:**
- `data` (table): Array of row data

**Returns:** None

##### `Table:setSortColumn(columnIndex)`
Set the sort column.

**Parameters:**
- `columnIndex` (number): Column index (1-based)

**Returns:** None

---

## Modding API

### Mod Loader

**Location:** `src/mods/Loader.lua`

The Mod Loader handles mod discovery, validation, and loading.

#### Functions

##### `ModLoader.loadMods(modsDirectory)`
Load all mods from a directory.

**Parameters:**
- `modsDirectory` (string): Path to mods directory

**Returns:** Table of loaded mod instances

**Example:**
```lua
local mods = ModLoader.loadMods("mods/")
for _, mod in ipairs(mods) do
    print("Loaded mod: " .. mod.manifest.name)
end
```

##### `ModLoader.validateMod(modPath)`
Validate a mod structure.

**Parameters:**
- `modPath` (string): Path to mod directory

**Returns:** boolean, error message

##### `ModLoader.resolveDependencies(mods)`
Resolve mod dependencies and determine load order.

**Parameters:**
- `mods` (table): Array of mod instances

**Returns:** Ordered array of mods

---

### Mod Hooks

**Location:** Various system files

Mod hooks allow mods to inject custom behavior.

#### Available Hooks

##### `mod_hook:unit_created(unit)`
Called when a unit is created.

**Parameters:**
- `unit` (Unit): Newly created unit

**Returns:** Modified unit or nil

##### `mod_hook:damage_calculated(damage, attacker, defender)`
Called when damage is calculated.

**Parameters:**
- `damage` (number): Calculated damage
- `attacker` (Unit): Attacking unit
- `defender` (Unit): Defending unit

**Returns:** Modified damage value

##### `mod_hook:mission_generated(mission)`
Called when a mission is generated.

**Parameters:**
- `mission` (Mission): Generated mission

**Returns:** Modified mission or nil

**Example:**
```lua
-- In mod file
function mod_hook:damage_calculated(damage, attacker, defender)
    -- Double damage for special unit type
    if attacker.unitType == "heavy_weapon" then
        return damage * 2
    end
    return damage
end
```

---

## Utility Functions

### Grid Utilities

**Location:** `src/utils/grid.lua`

Helper functions for grid-based calculations.

#### Functions

##### `GridUtils.pixelsToGrid(x, y)`
Convert pixel coordinates to grid coordinates.

**Parameters:**
- `x, y` (number): Pixel coordinates

**Returns:** gridX, gridY (numbers)

##### `GridUtils.gridToPixels(gridX, gridY)`
Convert grid coordinates to pixel coordinates.

**Parameters:**
- `gridX, gridY` (number): Grid coordinates

**Returns:** x, y (numbers)

##### `GridUtils.distance(x1, y1, x2, y2)`
Calculate grid distance between two points.

**Parameters:**
- `x1, y1` (number): First point
- `x2, y2` (number): Second point

**Returns:** distance (number)

---

## Constants

### Grid System

- `GRID_SIZE` = 20 pixels
- `SCREEN_WIDTH` = 800 pixels (40 grid units)
- `SCREEN_HEIGHT` = 600 pixels (30 grid units)

### Colors

```lua
COLORS = {
    WHITE = {1, 1, 1, 1},
    BLACK = {0, 0, 0, 1},
    RED = {1, 0, 0, 1},
    GREEN = {0, 1, 0, 1},
    BLUE = {0, 0, 1, 1},
    YELLOW = {1, 1, 0, 1},
    CYAN = {0, 1, 1, 1},
    MAGENTA = {1, 0, 1, 1},
    GRAY = {0.5, 0.5, 0.5, 1}
}
```

---

## Best Practices

### Error Handling

Always use Safe I/O functions for file operations:
```lua
-- Good
local data = SafeIO.safe_load_toml("config.toml", {})

-- Avoid
local data = toml.load("config.toml")  -- Can crash!
```

### Event Bus Usage

Always unsubscribe when done:
```lua
function Screen:enter()
    self.subscription = eventBus:subscribe("event", callback, self)
end

function Screen:leave()
    eventBus:unsubscribeAll(self)  -- Clean up!
end
```

### Performance Caching

Use performance cache for expensive calculations:
```lua
local cache = PerformanceCache:new()
local pathfinding = Pathfinding:new(map, cache)

-- Update turn for TTL
pathfinding:setCurrentTurn(currentTurn)

-- Pathfinding automatically uses cache
local path = pathfinding:findPath(...)

-- Invalidate when map changes
pathfinding:invalidateCache()
```

---

## Further Reading

- [Modding Tutorial](MODDING_TUTORIAL.md)
- [Architecture Documentation](architecture/)
- [Performance Optimization](PERFORMANCE_OPTIMIZATION.md)
- [Lua Style Guide](LUA_STYLE_GUIDE.md)
- [Love2D API Reference](https://love2d.org/wiki/Main_Page)

---

**Document Version:** 1.0  
**Last Updated:** September 30, 2025  
**Maintainers:** Alien Fall Development Team
