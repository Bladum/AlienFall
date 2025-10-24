# TASK-025 Geoscape - API Contracts & Data Structures

**Phase 1 Planning Document**
**Purpose:** Define all public APIs and data structures for Phase 2-6 implementation

---

## Core System APIs

### Geoscape Coordinator (Main Interface)

```lua
---@class Geoscape
---@field world World
---@field time TimeSystem
---@field factions FactionSystem
---@field regions RegionSystem
---@field renderer MapRenderer
---@field input InputHandler
local Geoscape = {}

---Initialize Geoscape system
---@param seed number Procedural generation seed
---@param difficulty string "easy", "normal", "hard", "ironman"
---@param width number Map width (default: 80)
---@param height number Map height (default: 40)
---@return Geoscape
function Geoscape.new(seed, difficulty, width, height) end

---Update geoscape state (called each frame)
---@param dt number Delta time in seconds
function Geoscape:update(dt) end

---Advance one game turn (called by player action)
function Geoscape:endTurn() end

---Get current game world
---@return World
function Geoscape:getWorld() end

---Get province at coordinates
---@param x number Province X coordinate (0-79)
---@param y number Province Y coordinate (0-39)
---@return Province
function Geoscape:getProvince(x, y) end

---Get all regions
---@return Region[]
function Geoscape:getRegions() end

---Get game time state
---@return GameTime
function Geoscape:getGameTime() end

---Get faction system
---@return FactionSystem
function Geoscape:getFactions() end

---Start mission at province
---@param province Province Province to generate mission in
---@param difficulty string Mission difficulty
---@return Mission Mission data for Battlescape
function Geoscape:startMission(province, difficulty) end

---Resolve mission result
---@param result MissionResult Results from Battlescape
function Geoscape:resolveMission(result) end

---Enter base management
---@param base_id number Base to manage
---@return Basescape
function Geoscape:enterBase(base_id) end

---Exit base management, apply changes
---@param base_state table Updated base state
function Geoscape:exitBase(base_state) end

---Render geoscape (called once per frame)
---@param render_target love.graphics Canvas or nil
function Geoscape:render(render_target) end

---Handle player input
---@param action string "pan", "zoom", "click", "key"
---@param x number X coordinate (screen or world)
---@param y number Y coordinate (screen or world)
---@param param any Additional parameter (zoom amount, key, etc)
function Geoscape:handleInput(action, x, y, param) end

---Get render state for HUD/display
---@return table State data for rendering
function Geoscape:getRenderState() end

---Save game state
---@param filename string Save file path
---@return boolean Success
function Geoscape:save(filename) end

---Load game state
---@param filename string Save file path
---@return boolean Success
function Geoscape:load(filename) end
```

---

## World System

### World (Map/Province Manager)

```lua
---@class World
---@field width number Width in provinces
---@field height number Height in provinces
---@field provinces Province[]
---@field biomes Biome[]
local World = {}

---Create new world
---@param width number Default: 80
---@param height number Default: 40
---@param seed number Generation seed
---@return World
function World.new(width, height, seed) end

---Generate world provinces
---@param config table Generation config (biome distribution, etc)
function World:generate(config) end

---Get province at coordinates
---@param x number X (0-79)
---@param y number Y (0-39)
---@return Province
function World:getProvince(x, y) end

---Set province at coordinates
---@param x number
---@param y number
---@param province Province
function World:setProvince(x, y, province) end

---Get neighboring provinces
---@param x number
---@param y number
---@param distance number Search radius (default: 1)
---@return Province[]
function World:getNeighbors(x, y, distance) end

---Get distance between provinces
---@param from table {x, y}
---@param to table {x, y}
---@return number Manhattan distance
function World:getDistance(from, to) end

---Find provinces by biome
---@param biome string Biome type
---@return Province[]
function World:getProvincesByBiome(biome) end

---Find provinces by control
---@param control string "player", "alien", "neutral"
---@return Province[]
function World:getProvincesByControl(control) end

---Get all provinces
---@return Province[]
function World:getAllProvinces() end
```

### Province (Individual Map Tile)

```lua
---@class Province
---@field x number X coordinate (0-79)
---@field y number Y coordinate (0-39)
---@field biome string "urban", "desert", "forest", "arctic", "water"
---@field elevation number 0-1 (height)
---@field population number Total population
---@field region_id number Which region/country controls this
---@field control string "player", "alien", "neutral", "contested"
---@field has_city boolean Has major city?
---@field cities City[]
---@field infrastructure number 0-1 development level
---@field resources table Resource deposits
---@field military table Military units
---@field economy table Economic info
local Province = {}

---Create new province
---@param x number
---@param y number
---@param biome string
---@param elevation number
---@return Province
function Province.new(x, y, biome, elevation) end

---Add city to province
---@param city City
function Province:addCity(city) end

---Get strategic value (for targeting)
---@return number 0-100 value score
function Province:getStrategicValue() end

---Apply damage/effects from mission
---@param damage_type string "bombardment", "terror_attack", "alien_infestation"
---@param severity number 0-1 intensity
function Province:applyDamage(damage_type, severity) end

---Get recovery rate (per turn)
---@return number Population/infrastructure recovery
function Province:getRecoveryRate() end

---Serialize province data
---@return string JSON
function Province:serialize() end

---Deserialize province data
---@param data string JSON
---@return Province
function Province.deserialize(data) end
```

### City (Location within Province)

```lua
---@class City
---@field name string City name
---@field population number
---@field x number Province X
---@field y number Province Y
---@field is_capital boolean Capital of region?
---@field is_base boolean Has player base?
---@field base_id number If has base, which one
local City = {}

---Create new city
---@param name string
---@param population number
---@param x number Province X
---@param y number Province Y
---@return City
function City.new(name, population, x, y) end
```

### Biome System

```lua
---@class BiomeSystem
local BiomeSystem = {}

---Create biome system
---@return BiomeSystem
function BiomeSystem.new() end

---Get biome type at coordinates
---@param x number
---@param y number
---@param seed number Generation seed
---@return string Biome type
function BiomeSystem:getBiomeAt(x, y, seed) end

---Generate biome distribution
---@param width number
---@param height number
---@param seed number
---@return string[][] 2D biome array
function BiomeSystem:generateMap(width, height, seed) end

---Get biome properties
---@param biome string
---@return table {color, difficulty_mod, resource_mod, ...}
function BiomeSystem:getProperties(biome) end
```

---

## Regions & Control System

### Region (Country/Faction Territory)

```lua
---@class Region
---@field id number Unique ID
---@field name string Region/country name
---@field provinces Province[]
---@field capital Province Capital city
---@field faction string "player", "alien", or faction name
---@field relations table Diplomatic relations with other regions
---@field resources table Economic resources
---@field military table Military strength
---@field politics table Political stability, morale
local Region = {}

---Create new region
---@param id number
---@param name string
---@param faction string
---@return Region
function Region.new(id, name, faction) end

---Add province to region
---@param province Province
function Region:addProvince(province) end

---Get all provinces in region
---@return Province[]
function Region:getProvinces() end

---Get region economic power
---@return number 0-100 score
function Region:getEconomicPower() end

---Get region military strength
---@return number 0-100 score
function Region:getMilitaryStrength() end

---Get political stability
---@return number 0-100 score
function Region:getStability() end

---Update region (per turn)
---@param turn number Current turn
function Region:update(turn) end
```

### Control Tracker (Province Ownership)

```lua
---@class ControlTracker
local ControlTracker = {}

---Create control tracker
---@return ControlTracker
function ControlTracker.new() end

---Set province control
---@param province Province
---@param control string "player", "alien", "neutral"
---@param reason string Why changed
function ControlTracker:setControl(province, control, reason) end

---Get province control
---@param province Province
---@return string Current control
function ControlTracker:getControl(province) end

---Get control history
---@param province Province
---@param turns number How many turns back
---@return table[] Control changes
function ControlTracker:getHistory(province, turns) end

---Update control (per turn - faction aggression, etc)
function ControlTracker:update() end
```

---

## Faction & Mission System

### Faction System (Alien & Player Activity)

```lua
---@class FactionSystem
---@field aliens AlienFaction
---@field player PlayerFaction
local FactionSystem = {}

---Create faction system
---@param world World
---@param difficulty string Game difficulty
---@return FactionSystem
function FactionSystem.new(world, difficulty) end

---Update faction activities (per turn)
---@param turn number Current turn
function FactionSystem:update(turn) end

---Generate mission
---@param province Province Mission location
---@param difficulty string Mission difficulty
---@return Mission
function FactionSystem:generateMission(province, difficulty) end

---Get alien activity level
---@return number 0-1 activity level
function FactionSystem:getAlienActivity() end

---Get UFO count
---@return number Active UFOs
function FactionSystem:getUFOCount() end

---Get terror attack schedule
---@return table[] Scheduled terror attacks
function FactionSystem:getTerrorSchedule() end

---Record player victory
---@param province Province Mission location
---@param result MissionResult Battle result
function FactionSystem:recordVictory(province, result) end

---Record alien victory
---@param province Province
function FactionSystem:recordAlienVictory(province) end
```

### Mission (Battlescape Integration)

```lua
---@class Mission
---@field id number Unique mission ID
---@field type string "terror", "recovery", "interception", "assault"
---@field province Province Target location
---@field difficulty string "easy", "normal", "hard", "insane"
---@field map_seed number Procedural map seed
---@field enemy_forces Enemy[]
---@field objectives Objective[]
---@field rewards table Completion rewards
---@field time_limit number Turns available (or -1 for unlimited)
local Mission = {}

---Create new mission
---@param type string
---@param province Province
---@param difficulty string
---@return Mission
function Mission.new(type, province, difficulty) end

---Generate enemy forces
---@param difficulty string
function Mission:generateEnemies(difficulty) end

---Get map seed for Battlescape
---@return number
function Mission:getMapSeed() end

---Get mission description
---@return string
function Mission:getDescription() end
```

### Mission Result (From Battlescape)

```lua
---@class MissionResult
---@field mission_id number
---@field success boolean Did player win?
---@field enemies_eliminated number
---@field player_casualties number
---@field turns_used number
---@field rewards table Credits, research, items
---@field province_effects table Changes to province
local MissionResult = {}
```

---

## Time & Event System

### Time System (Calendar & Turns)

```lua
---@class TimeSystem
---@field turn number Current turn counter
---@field year number
---@field month number 1-12
---@field day number 1-31
---@field hour number 0-23
local TimeSystem = {}

---Create time system
---@param start_year number Starting year
---@return TimeSystem
function TimeSystem.new(start_year) end

---Advance by one game turn
function TimeSystem:advanceTurn() end

---Advance by N days
---@param days number
function TimeSystem:advanceDays(days) end

---Advance by N months
---@param months number
function TimeSystem:advanceMonths(months) end

---Get current date as string
---@return string "Month Day, Year"
function TimeSystem:getDateString() end

---Get current time
---@return table {year, month, day, hour}
function TimeSystem:getTime() end

---Get total days elapsed
---@return number Days since start
function TimeSystem:getDaysElapsed() end

---Get current turn
---@return number Turn counter
function TimeSystem:getTurn() end

---Get season
---@return string "spring", "summer", "autumn", "winter"
function TimeSystem:getSeason() end

---Schedule event
---@param event_type string Event type
---@param turn number When to trigger
---@param data table Event-specific data
function TimeSystem:scheduleEvent(event_type, turn, data) end

---Get scheduled events
---@return table[] Events
function TimeSystem:getScheduledEvents() end
```

### Event Scheduler

```lua
---@class EventScheduler
local EventScheduler = {}

---Create event scheduler
---@return EventScheduler
function EventScheduler.new() end

---Schedule event
---@param turn number When to trigger
---@param event Event
function EventScheduler:schedule(turn, event) end

---Get events for turn
---@param turn number
---@return Event[] Events to process
function EventScheduler:getEventsForTurn(turn) end

---Remove event
---@param event_id number
function EventScheduler:removeEvent(event_id) end

---Get all scheduled events
---@return Event[]
function EventScheduler:getAllEvents() end
```

---

## Rendering System

### Map Renderer

```lua
---@class MapRenderer
local MapRenderer = {}

---Create renderer
---@param world World
---@param width number Screen width
---@param height number Screen height
---@return MapRenderer
function MapRenderer.new(world, width, height) end

---Update camera position
---@param x number World X
---@param y number World Y
---@param zoom number 0.5-3.0
function MapRenderer:setCamera(x, y, zoom) end

---Pan camera
---@param dx number
---@param dy number
function MapRenderer:pan(dx, dy) end

---Zoom camera
---@param zoom_delta number +/- to multiply current zoom
---@param center_x number Center X for zoom (screen coords)
---@param center_y number Center Y for zoom
function MapRenderer:zoom(zoom_delta, center_x, center_y) end

---Render to screen
---@param target love.graphics Canvas or nil for screen
function MapRenderer:render(target) end

---Get screen coordinates from world coordinates
---@param world_x number
---@param world_y number
---@return number screen_x, number screen_y
function MapRenderer:worldToScreen(world_x, world_y) end

---Get world coordinates from screen coordinates
---@param screen_x number
---@param screen_y number
---@return number world_x, number world_y
function MapRenderer:screenToWorld(screen_x, screen_y) end

---Get visible provinces (for culling)
---@return Province[]
function MapRenderer:getVisibleProvinces() end
```

### UI Renderer

```lua
---@class UIRenderer
local UIRenderer = {}

---Create UI renderer
---@return UIRenderer
function UIRenderer.new() end

---Render UI overlays
---@param geoscape Geoscape
function UIRenderer:render(geoscape) end

---Get clickable regions
---@return table[] Interactive areas
function UIRenderer:getClickableRegions() end

---Show tooltip
---@param x number Screen X
---@param y number Screen Y
---@param text string Tooltip text
function UIRenderer:showTooltip(x, y, text) end

---Hide tooltip
function UIRenderer:hideTooltip() end

---Show dialog
---@param title string
---@param message string
---@param options string[] Button labels
---@return number Clicked button index
function UIRenderer:showDialog(title, message, options) end
```

---

## Input System

### Input Handler

```lua
---@class InputHandler
local InputHandler = {}

---Create input handler
---@param geoscape Geoscape
---@return InputHandler
function InputHandler.new(geoscape) end

---Handle key press
---@param key string Key code
function InputHandler:keypressed(key) end

---Handle key release
---@param key string
function InputHandler:keyreleased(key) end

---Handle mouse click
---@param x number Screen X
---@param y number Screen Y
---@param button number Mouse button (1-3)
function InputHandler:mousepressed(x, y, button) end

---Handle mouse movement
---@param x number Screen X
---@param y number Screen Y
function InputHandler:mousemoved(x, y) end

---Handle mouse wheel
---@param dx number
---@param dy number
function InputHandler:wheelmoved(dx, dy) end

---Get current input state
---@return table Pressed keys, mouse position, etc
function InputHandler:getState() end
```

---

## Data Structures

### GameTime (State Snapshot)

```lua
GameTime = {
    turn = 42,
    year = 2026,
    month = 3,
    day = 15,
    hour = 14,
    days_elapsed = 75,
    season = "spring"
}
```

### ProvinceSummary (For UI)

```lua
ProvinceSummary = {
    name = "New York",
    biome = "urban",
    population = 5000000,
    control = "player",
    infrastructure = 0.8,
    military_strength = 50,
    economic_value = 8000,
    threat_level = 0.2
}
```

### RegionSummary

```lua
RegionSummary = {
    id = 1,
    name = "North America",
    faction = "player",
    province_count = 50,
    economic_power = 85,
    military_strength = 75,
    stability = 0.7,
    relations = {
        [2] = 0.5,  -- Neutral with region 2
        [3] = -0.8  -- Enemy with region 3
    }
}
```

---

## Performance Targets

| Component | Target |
|-----------|--------|
| World generation | <1 second |
| Render frame time | <16.7ms (60 FPS) |
| Turn calculation | <100ms |
| Memory usage | <100 MB |
| Load/save time | <5 seconds |

---

## Error Handling

All functions should return:
- **Success:** Result data (table, boolean, number, string)
- **Failure:** nil, error message
- **Invalid:** nil, "Invalid parameters"

```lua
function World:getProvince(x, y)
    if not x or not y then return nil, "Invalid coordinates" end
    if x < 0 or x >= self.width then return nil, "X out of bounds" end
    if y < 0 or y >= self.height then return nil, "Y out of bounds" end
    return self.provinces[y * self.width + x]
end
```

---

**End of API Contracts Document**

**Next Step:** Implement Phase 2 (World Generation) using these APIs
