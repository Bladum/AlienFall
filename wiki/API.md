# API Documentation

## Core Game Systems

### Viewport (`utils/viewport.lua`)

Manages separate coordinate systems for GUI and battlefield areas, supporting dynamic resolution.

#### Overview

The Viewport system provides:
- **Fixed GUI**: Always 240×720 pixels (10×30 tiles)
- **Dynamic Battlefield**: Fills remaining screen space
- **Coordinate Conversion**: Screen ↔ Tile ↔ Battlefield coordinates
- **Boundary Detection**: GUI vs Battlefield area checks

#### Constants

```lua
Viewport.GUI_WIDTH = 240        -- 10 tiles × 24px
Viewport.GUI_HEIGHT = 720       -- 30 tiles × 24px
Viewport.TILE_SIZE = 24         -- Grid cell size
Viewport.SECTION_HEIGHT = 240   -- Each GUI section height
```

#### Core Functions

**`Viewport.getBattlefieldViewport()`**
- Returns battlefield viewport dimensions
- **Returns:** 
  - `x` (number): Starting X position (always GUI_WIDTH = 240)
  - `y` (number): Starting Y position (always 0)
  - `width` (number): Available width for battlefield
  - `height` (number): Available height for battlefield
- **Example:**
```lua
local viewX, viewY, viewWidth, viewHeight = Viewport.getBattlefieldViewport()
love.graphics.setScissor(viewX, viewY, viewWidth, viewHeight)
```

**`Viewport.isInGUI(x, y)`**
- Checks if screen coordinates are in GUI area
- **Parameters:** `x, y` (numbers): Screen coordinates
- **Returns:** `boolean`: True if in GUI area (x < 240)
- **Example:**
```lua
if Viewport.isInGUI(mouseX, mouseY) then
    -- Handle GUI interaction
end
```

**`Viewport.isInBattlefield(x, y)`**
- Checks if screen coordinates are in battlefield area
- **Parameters:** `x, y` (numbers): Screen coordinates
- **Returns:** `boolean`: True if in battlefield area (x >= 240)

**`Viewport.screenToTile(screenX, screenY, camera, tileSize)`**
- Converts screen coordinates to tile coordinates
- **Parameters:**
  - `screenX, screenY` (numbers): Physical screen coordinates
  - `camera` (table): Camera object with `x, y, zoom` properties
  - `tileSize` (number): Tile size in pixels (default 24)
- **Returns:** `tileX, tileY` (numbers): Tile coordinates (1-based)
- **Example:**
```lua
local tileX, tileY = Viewport.screenToTile(mouseX, mouseY, self.camera, TILE_SIZE)
local tile = battlefield:getTile(tileX, tileY)
```

**`Viewport.tileToScreen(tileX, tileY, camera, tileSize)`**
- Converts tile coordinates to screen coordinates
- **Parameters:**
  - `tileX, tileY` (numbers): Tile coordinates (1-based)
  - `camera` (table): Camera object with `x, y, zoom` properties
  - `tileSize` (number): Tile size in pixels (default 24)
- **Returns:** `screenX, screenY` (numbers): Physical screen coordinates
- **Example:**
```lua
local screenX, screenY = Viewport.tileToScreen(unitX, unitY, self.camera, TILE_SIZE)
love.graphics.draw(unitImage, screenX, screenY)
```

**`Viewport.screenToBattlefield(screenX, screenY)`**
- Converts screen coordinates to battlefield-relative coordinates
- **Parameters:** `screenX, screenY` (numbers): Screen coordinates
- **Returns:** `bfX, bfY` (numbers): Battlefield coordinates (removes GUI offset)

**`Viewport.battlefieldToScreen(bfX, bfY)`**
- Converts battlefield coordinates to screen coordinates
- **Parameters:** `bfX, bfY` (numbers): Battlefield coordinates
- **Returns:** `screenX, screenY` (numbers): Screen coordinates (adds GUI offset)

**`Viewport.getVisibleTileBounds(camera, mapWidth, mapHeight)`**
- Gets visible tile range for culling
- **Parameters:**
  - `camera` (table): Camera object
  - `mapWidth, mapHeight` (numbers): Map dimensions in tiles
- **Returns:** `minTileX, minTileY, maxTileX, maxTileY` (numbers): Tile bounds
- **Example:**
```lua
local minX, minY, maxX, maxY = Viewport.getVisibleTileBounds(camera, 90, 90)
for y = minY, maxY do
    for x = minX, maxX do
        -- Only render visible tiles
    end
end
```

**`Viewport.getGUISection(section)`**
- Gets position and size of GUI section
- **Parameters:** `section` (number): Section index (1=top, 2=middle, 3=bottom)
- **Returns:** `x, y, width, height` (numbers): Section bounds
- **Example:**
```lua
local x, y, w, h = Viewport.getGUISection(1)  -- Top section (minimap)
```

**`Viewport.printInfo()`**
- Prints viewport debug information to console
- **Example output:**
```
[Viewport] Window: 1920×1080
[Viewport] GUI: 240×720
[Viewport] Battlefield: 1680×1080 at (240, 0)
[Viewport] Approx visible tiles: 70×45
```

#### Coordinate System Flow

```
Screen Space (Window)
  ↓ isInGUI() / isInBattlefield()
  ├─→ GUI Space (0-240, 0-720)
  │   └─→ Physical pixels, direct widget rendering
  └─→ Battlefield Space (240+, 0+)
      ↓ screenToBattlefield()
      Battlefield-Relative (0+, 0+)
      ↓ screenToTile(camera)
      Tile Space (1-based, logical)
```

---

### StateManager (`systems/state_manager.lua`)

Handles switching between game states (menu, geoscape, battlescape, basescape).

#### Functions

**`StateManager.register(name, state)`**
- Registers a new game state
- **Parameters:**
  - `name` (string): Name identifier for the state
  - `state` (table): State module with enter/exit/update/draw functions
- **Returns:** None
- **Example:**
```lua
StateManager.register("menu", Menu)
```

**`StateManager.switch(name, ...)`**
- Switches to a different game state
- **Parameters:**
  - `name` (string): Name of state to switch to
  - `...`: Additional arguments passed to state's enter function
- **Returns:** None
- **Example:**
```lua
StateManager.switch("battlescape", missionData)
```

**`StateManager.update(dt)`**
- Updates current active state
- **Parameters:**
  - `dt` (number): Delta time since last frame
- **Returns:** None

**`StateManager.draw()`**
- Renders current active state
- **Returns:** None

---

## Battle System (Hexagonal Grid + ECS)

Complete hexagonal battle system with ECS architecture, AP-based movement, and directional vision.

### Overview

The battle system uses:
- **Hexagonal Grid:** Even-Q vertical offset layout (60×60 hexes, 24px tiles)
- **ECS Architecture:** Components (data), Systems (logic), Entities (composition)
- **Movement:** Action Point system (2 AP/hex, 1 AP/rotation)
- **Vision:** 120° directional cones with line-of-sight
- **Pathfinding:** A* algorithm with obstacle avoidance

### Debug Controls

| Key | Function | Default |
|-----|----------|---------|
| **F8** | Toggle Fog of War | ON |
| **F9** | Toggle Hex Grid Overlay | OFF |
| **F10** | Toggle Debug Mode | OFF |

### HexMath (`systems/battle/utils/hex_math.lua`)

Hexagonal coordinate mathematics and utilities.

#### Coordinate Systems

**`HexMath.offsetToAxial(col, row)`**
- Converts offset coordinates to axial (q,r)
- **Parameters:** `col` (number), `row` (number)
- **Returns:** `q` (number), `r` (number)

**`HexMath.axialToOffset(q, r)`**
- Converts axial coordinates to offset (col,row)
- **Parameters:** `q` (number), `r` (number)
- **Returns:** `col` (number), `row` (number)

**`HexMath.axialToCube(q, r)`**
- Converts axial to cube coordinates (x,y,z)
- **Parameters:** `q` (number), `r` (number)
- **Returns:** `x` (number), `y` (number), `z` (number)

#### Distance & Neighbors

**`HexMath.distance(q1, r1, q2, r2)`**
- Calculates hex distance between two points
- **Parameters:** `q1,r1,q2,r2` (numbers)
- **Returns:** Distance in hexes (number)

**`HexMath.getNeighbors(q, r)`**
- Gets all 6 neighboring hexes
- **Parameters:** `q` (number), `r` (number)
- **Returns:** Array of {q,r} coordinate pairs

**`HexMath.getNeighborsInRange(q, r, range)`**
- Gets all hexes within range
- **Parameters:** `q,r` (numbers), `range` (number)
- **Returns:** Array of {q,r} coordinates

#### Direction & Movement

**`HexMath.getDirection(fromQ, fromR, toQ, toR)`**
- Gets direction index (0-5) from one hex to another
- **Parameters:** `fromQ,fromR,toQ,toR` (numbers)
- **Returns:** Direction (0=E, 1=NE, 2=NW, 3=W, 4=SW, 5=SE)

**`HexMath.getHexInDirection(q, r, direction, distance)`**
- Gets hex coordinates in specified direction
- **Parameters:** `q,r,direction,distance` (numbers)
- **Returns:** `newQ` (number), `newR` (number)

#### Vision & Arc

**`HexMath.getFrontArc(centerQ, centerR, facing, arcAngle)`**
- Gets hexes in directional arc (default 120°)
- **Parameters:** `centerQ,centerR,facing` (numbers), `arcAngle` (optional, default 120)
- **Returns:** Array of {q,r} coordinates in arc

**`HexMath.hexLine(q1, r1, q2, r2)`**
- Gets all hexes in line between two points (Bresenham)
- **Parameters:** `q1,r1,q2,r2` (numbers)
- **Returns:** Array of {q,r} coordinates along line

#### Rendering

**`HexMath.hexToPixel(q, r, hexSize)`**
- Converts hex coordinates to pixel position
- **Parameters:** `q,r` (numbers), `hexSize` (optional, default 24)
- **Returns:** `x` (number), `y` (number)

**`HexMath.pixelToHex(x, y, hexSize)`**
- Converts pixel position to hex coordinates
- **Parameters:** `x,y` (numbers), `hexSize` (optional, default 24)
- **Returns:** `q` (number), `r` (number)

### HexSystem (`systems/battle/systems/hex_system.lua`)

Manages the hexagonal grid, tile storage, and unit tracking.

#### Creation & Management

**`HexSystem.new(width, height, hexSize)`**
- Creates new hex grid system
- **Parameters:** `width,height` (numbers), `hexSize` (optional, default 24)
- **Returns:** HexSystem instance

**`HexSystem:getTile(q, r)`**
- Gets tile data at hex coordinates
- **Parameters:** `q,r` (numbers)
- **Returns:** Tile data table or nil

**`HexSystem:setTile(q, r, tileData)`**
- Sets tile data at hex coordinates
- **Parameters:** `q,r` (numbers), `tileData` (table)
- **Returns:** None

#### Unit Management

**`HexSystem:addUnit(unit, q, r)`**
- Adds unit to hex grid at position
- **Parameters:** `unit` (UnitEntity), `q,r` (numbers)
- **Returns:** Success (boolean)

**`HexSystem:removeUnit(unit)`**
- Removes unit from hex grid
- **Parameters:** `unit` (UnitEntity)
- **Returns:** Success (boolean)

**`HexSystem:moveUnit(unit, newQ, newR)`**
- Moves unit to new hex position
- **Parameters:** `unit` (UnitEntity), `newQ,newR` (numbers)
- **Returns:** Success (boolean)

**`HexSystem:getUnitsAt(q, r)`**
- Gets all units at hex position
- **Parameters:** `q,r` (numbers)
- **Returns:** Array of UnitEntity objects

#### Validation & Queries

**`HexSystem:isValidHex(q, r)`**
- Checks if hex coordinates are valid
- **Parameters:** `q,r` (numbers)
- **Returns:** Valid (boolean)

**`HexSystem:isOccupied(q, r)`**
- Checks if hex is occupied by units
- **Parameters:** `q,r` (numbers)
- **Returns:** Occupied (boolean)

#### Rendering

**`HexSystem:drawHexGrid(camera)`**
- Renders hex grid overlay
- **Parameters:** `camera` (optional camera object)
- **Returns:** None

### MovementSystem (`systems/battle/systems/movement_system.lua`)

Handles unit movement, AP costs, and pathfinding.

#### Movement Operations

**`MovementSystem.tryMove(unit, hexSystem, targetQ, targetR)`**
- Attempts to move unit to target hex
- **Parameters:** `unit` (UnitEntity), `hexSystem` (HexSystem), `targetQ,targetR` (numbers)
- **Returns:** Success (boolean)

**`MovementSystem.tryRotate(unit, targetFacing)`**
- Attempts to rotate unit to face direction
- **Parameters:** `unit` (UnitEntity), `targetFacing` (0-5)
- **Returns:** Success (boolean)

#### AP Management

**`MovementSystem.resetAP(unit)`**
- Resets unit's AP to maximum
- **Parameters:** `unit` (UnitEntity)
- **Returns:** None

**`MovementSystem.canAfford(unit, cost)`**
- Checks if unit has enough AP
- **Parameters:** `unit` (UnitEntity), `cost` (number)
- **Returns:** Can afford (boolean)

**`MovementSystem.spendAP(unit, cost)`**
- Spends AP from unit
- **Parameters:** `unit` (UnitEntity), `cost` (number)
- **Returns:** Success (boolean)

#### Pathfinding

**`MovementSystem.findPath(hexSystem, startQ, startR, endQ, endR)`**
- Finds A* path between hexes
- **Parameters:** `hexSystem` (HexSystem), `startQ,startR,endQ,endR` (numbers)
- **Returns:** Array of {q,r} waypoints or nil if no path

**`MovementSystem.getPathCost(path)`**
- Calculates AP cost of path
- **Parameters:** `path` (array of {q,r} coordinates)
- **Returns:** Total AP cost (number)

### VisionSystem (`systems/battle/systems/vision_system.lua`)

Handles line-of-sight, vision cones, and team visibility.

#### Vision Updates

**`VisionSystem.updateUnitVision(unit, hexSystem)`**
- Updates vision for single unit
- **Parameters:** `unit` (UnitEntity), `hexSystem` (HexSystem)
- **Returns:** None

**`VisionSystem.updateTeamVision(teamId, hexSystem)`**
- Updates vision for entire team
- **Parameters:** `teamId` (number), `hexSystem` (HexSystem)
- **Returns:** None

#### Line of Sight

**`VisionSystem.hasLineOfSight(hexSystem, fromQ, fromR, toQ, toR)`**
- Checks LOS between two hexes
- **Parameters:** `hexSystem` (HexSystem), `fromQ,fromR,toQ,toR` (numbers)
- **Returns:** Has LOS (boolean)

**`VisionSystem.canSeeUnit(viewer, target, hexSystem)`**
- Checks if viewer can see target unit
- **Parameters:** `viewer,target` (UnitEntity), `hexSystem` (HexSystem)
- **Returns:** Can see (boolean)

#### Vision Queries

**`VisionSystem.getVisibleHexes(unit, hexSystem)`**
- Gets all hexes visible to unit
- **Parameters:** `unit` (UnitEntity), `hexSystem` (HexSystem)
- **Returns:** Array of {q,r} coordinates

**`VisionSystem.getVisibleUnits(unit, hexSystem)`**
- Gets all units visible to unit
- **Parameters:** `unit` (UnitEntity), `hexSystem` (HexSystem)
- **Returns:** Array of UnitEntity objects

#### Rendering

**`VisionSystem.drawVisionCones(hexSystem, camera)`**
- Renders vision cones for all units
- **Parameters:** `hexSystem` (HexSystem), `camera` (optional)
- **Returns:** None

### UnitEntity (`systems/battle/entities/unit_entity.lua`)

Entity composition pattern for units with multiple components.

#### Creation

**`UnitEntity.new(config)`**
- Creates new unit with components
- **Parameters:** `config` (table with component data)
- **Returns:** UnitEntity instance

**Example:**
```lua
local unit = UnitEntity.new({
    q = 10, r = 10,        -- Position
    facing = 0,            -- East
    teamId = 1,            -- Player team
    maxHP = 100,
    armor = 10,
    maxAP = 10,
    visionRange = 8,
    name = "Soldier Alpha"
})
```

#### Component Access

**`UnitEntity:getComponent(name)`**
- Gets component by name
- **Parameters:** `name` (string)
- **Returns:** Component table or nil

**`UnitEntity:hasComponent(name)`**
- Checks if unit has component
- **Parameters:** `name` (string)
- **Returns:** Has component (boolean)

#### Serialization

**`UnitEntity:serialize()`**
- Serializes unit to table
- **Returns:** Serialized data (table)

**`UnitEntity.deserialize(data)`**
- Creates unit from serialized data
- **Parameters:** `data` (table)
- **Returns:** UnitEntity instance

### Debug System (`systems/battle/utils/debug.lua`)

Debug utilities and visualization tools.

#### Toggle Functions

**`Debug.toggleFOW()`**
- Toggles fog of war display
- **Returns:** None

**`Debug.toggleHexGrid()`**
- Toggles hex grid overlay
- **Returns:** None

**`Debug.toggle()`**
- Toggles debug mode
- **Returns:** None

#### State Queries

**`Debug.isFOWEnabled()`**
- Checks if FOW is enabled
- **Returns:** Enabled (boolean)

**`Debug.isHexGridEnabled()`**
- Checks if hex grid is enabled
- **Returns:** Enabled (boolean)

**`Debug.isDebugEnabled()`**
- Checks if debug mode is enabled
- **Returns:** Enabled (boolean)

#### Logging

**`Debug.log(message, level)`**
- Logs debug message
- **Parameters:** `message` (string), `level` (optional, default "INFO")
- **Returns:** None

**`Debug.perfStart(label)`**
- Starts performance timer
- **Parameters:** `label` (string)
- **Returns:** None

**`Debug.perfEnd(label)`**
- Ends performance timer and logs
- **Parameters:** `label` (string)
- **Returns:** None

---

## UI System (`systems/ui.lua`)

Simple UI widget library for buttons, labels, and panels.

#### UI.Button

**`UI.Button(x, y, width, height, text, callback)`**
- Creates a clickable button widget
- **Parameters:**
  - `x` (number): X position
  - `y` (number): Y position
  - `width` (number): Button width
  - `height` (number): Button height
  - `text` (string): Button label text
  - `callback` (function): Function called when clicked
- **Returns:** Button object
- **Example:**
```lua
local startButton = UI.Button(100, 100, 200, 50, "Start Game", function()
    StateManager.switch("geoscape")
end)
```

**Button Methods:**
- `button:update(dt, mouseX, mouseY, clicked)` - Update button state
- `button:draw()` - Render button
- `button:isHovered()` - Check if mouse is over button
- `button:setEnabled(enabled)` - Enable/disable button
- `button:setText(text)` - Change button text

---

## Game Modules

### Menu (`modules/menu.lua`)
Main menu state with game options.

### Geoscape (`modules/geoscape.lua`)
Global strategy layer - world map, base management, missions.

### Battlescape (`modules/battlescape.lua`)
Tactical combat layer - turn-based squad combat.

### Basescape (`modules/basescape.lua`)
Base management interface - facilities, units, research, manufacturing.

---

## Love2D Configuration

### conf.lua Settings

```lua
t.console = true                    -- Enable console for debugging
t.window.width = 1024              -- Window width
t.window.height = 768              -- Window height
t.window.vsync = true              -- Vertical sync
```

---

## Utilities

### Data Loading (`utils/data_loader.lua`)
Functions for loading game data from JSON/Lua files.

### Save System (`utils/save_system.lua`)
Functions for saving and loading game state.

---

## Debugging

### Console Output
Love2D console is enabled by default. Use `print()` for debug output:
```lua
print("[ModuleName] Debug message")
```

### On-Screen Debug
Draw debug info on screen:
```lua
love.graphics.print("Debug: " .. value, 10, 10)
```

### Error Handling
Use `pcall` for safe function calls:
```lua
local success, result = pcall(riskyFunction, arg1, arg2)
if not success then
    print("[Error] " .. result)
end
```

---

## File Structure

```
engine/
├── main.lua              -- Entry point
├── conf.lua             -- Love2D configuration
├── systems/             -- Core systems
│   ├── state_manager.lua
│   └── ui.lua
├── modules/             -- Game modules/states
│   ├── menu.lua
│   ├── geoscape.lua
│   ├── battlescape.lua
│   └── basescape.lua
├── utils/               -- Utility functions
├── data/                -- Game data (JSON/Lua)
└── assets/              -- Images, sounds, fonts
```

---

## Environmental Systems

### FireSystem (`systems/battle/fire_system.lua`)

Manages fire spreading, unit damage, and smoke production in tactical combat.

#### Overview

The FireSystem handles environmental fire effects:
- **Binary Fire State**: Tiles are either burning or not
- **Terrain Flammability**: 0.0-1.0 scale affects spread chance
- **Unit Damage**: 5 HP per turn for units in fire
- **Smoke Production**: Each fire tile produces smoke
- **Movement Blocking**: Fire tiles have 0 movement cost (impassable)
- **LOS Penalties**: Fire adds +3 sight cost

#### Constructor

**`FireSystem.new()`**
- Creates new fire system instance
- **Returns:** `FireSystem` instance
- **Example:**
```lua
local fireSystem = FireSystem.new()
```

#### Core Methods

**`FireSystem:startFire(x, y)`**
- Ignites a tile at specified coordinates
- **Parameters:** `x, y` (numbers): Tile coordinates (1-based)
- **Returns:** `boolean`: True if fire started successfully
- **Example:**
```lua
fireSystem:startFire(45, 45)  -- Start fire at tile (45, 45)
```

**`FireSystem:spreadFire()`**
- Spreads fire to adjacent flammable tiles
- **Spread Chance:** 30% base chance × terrain flammability
- **Called:** Automatically each turn end
- **Example:**
```lua
fireSystem:spreadFire()  -- Process fire spreading
```

**`FireSystem:damageUnitsInFire(units)`**
- Applies 5 HP damage to units standing in fire
- **Parameters:** `units` (table): Array of unit objects
- **Called:** Automatically each turn end
- **Example:**
```lua
fireSystem:damageUnitsInFire(self.units)
```

**`FireSystem:produceSmoke()`**
- Generates smoke from all fire tiles
- **Amount:** 1 smoke level per fire tile per turn
- **Called:** Automatically each turn end
- **Example:**
```lua
fireSystem:produceSmoke()  -- Generate smoke from fires
```

**`FireSystem:update(units)`**
- Main update function called each turn
- **Parameters:** `units` (table): Array of unit objects
- **Calls:** `spreadFire()`, `damageUnitsInFire()`, `produceSmoke()`
- **Example:**
```lua
fireSystem:update(self.units)  -- Full fire system update
```

#### Utility Methods

**`FireSystem:setBattlefield(battlefield)`**
- Sets battlefield reference for tile access
- **Parameters:** `battlefield` (Battlefield): Battlefield instance
- **Example:**
```lua
fireSystem:setBattlefield(self.battlefield)
```

**`FireSystem:setSmokeSystem(smokeSystem)`**
- Links smoke system for smoke production
- **Parameters:** `smokeSystem` (SmokeSystem): Smoke system instance
- **Example:**
```lua
fireSystem:setSmokeSystem(self.smokeSystem)
```

### SmokeSystem (`systems/battle/smoke_system.lua`)

Manages smoke dissipation, spreading, and visibility effects.

#### Overview

The SmokeSystem handles environmental smoke effects:
- **Three Levels**: Light (1), Medium (2), Heavy (3)
- **Sight Cost**: +2 per level (+2/+4/+6)
- **Dissipation**: 33% chance per turn to reduce level
- **Spreading**: Heavy smoke spreads to adjacent tiles
- **Visual Effects**: Translucent gray overlays
- **LOS Integration**: Accumulates with other sight costs

#### Constructor

**`SmokeSystem.new()`**
- Creates new smoke system instance
- **Returns:** `SmokeSystem` instance
- **Example:**
```lua
local smokeSystem = SmokeSystem.new()
```

#### Core Methods

**`SmokeSystem:addSmoke(x, y, amount)`**
- Adds smoke to a tile
- **Parameters:**
  - `x, y` (numbers): Tile coordinates (1-based)
  - `amount` (number): Smoke level to add (1-3, optional, default 1)
- **Returns:** `boolean`: True if smoke added successfully
- **Example:**
```lua
smokeSystem:addSmoke(50, 50, 3)  -- Heavy smoke
smokeSystem:addSmoke(45, 45, 1)  -- Light smoke
```

**`SmokeSystem:getSmokeLevel(x, y)`**
- Gets current smoke level at tile
- **Parameters:** `x, y` (numbers): Tile coordinates (1-based)
- **Returns:** `number`: Smoke level (0-3)
- **Example:**
```lua
local level = smokeSystem:getSmokeLevel(45, 45)
if level >= 2 then
    print("Medium or heavy smoke")
end
```

**`SmokeSystem:spreadSmoke()`**
- Spreads heavy smoke (level 3) to adjacent tiles
- **Spread Chance:** 20% per adjacent tile
- **Result:** Creates light smoke (level 1) in neighbors
- **Called:** Automatically each turn end
- **Example:**
```lua
smokeSystem:spreadSmoke()  -- Process smoke spreading
```

**`SmokeSystem:dissipateSmoke()`**
- Reduces smoke levels randomly
- **Dissipation Chance:** 33% per smoke tile per turn
- **Effect:** Level decreases by 1 (3→2→1→0)
- **Called:** Automatically each turn end
- **Example:**
```lua
smokeSystem:dissipateSmoke()  -- Process smoke dissipation
```

**`SmokeSystem:update()`**
- Main update function called each turn
- **Calls:** `dissipateSmoke()`, `spreadSmoke()`
- **Example:**
```lua
smokeSystem:update()  -- Full smoke system update
```

#### Utility Methods

**`SmokeSystem:setBattlefield(battlefield)`**
- Sets battlefield reference for tile access
- **Parameters:** `battlefield` (Battlefield): Battlefield instance
- **Example:**
```lua
smokeSystem:setBattlefield(self.battlefield)
```

## Map Generation Systems

### MapBlock (`systems/battle/map_block.lua`)

Represents a 15×15 tile template for procedural map generation.

#### Overview

MapBlock provides:
- **15×15 Tile Grid**: Fixed-size terrain templates
- **TOML Serialization**: Load/save from configuration files
- **Metadata**: ID, biome, difficulty, author, tags
- **Coordinate Systems**: 0-indexed for TOML, 1-indexed internally
- **Terrain Storage**: Sparse storage (only non-grass tiles)

#### Constructor

**`MapBlock.new(id, width, height)`**
- Creates new MapBlock instance
- **Parameters:**
  - `id` (string): Unique block identifier
  - `width, height` (numbers): Block dimensions (usually 15×15)
- **Returns:** `MapBlock` instance
- **Example:**
```lua
local block = MapBlock.new("urban_block_01", 15, 15)
```

#### Tile Management

**`MapBlock:getTile(x, y)`**
- Gets terrain ID at coordinates
- **Parameters:** `x, y` (numbers): Tile coordinates (1-based)
- **Returns:** `string`: Terrain ID (e.g., "wall", "tree", "grass")
- **Example:**
```lua
local terrain = block:getTile(5, 5)
if terrain == "wall" then
    -- Handle wall tile
end
```

**`MapBlock:setTile(x, y, terrainId)`**
- Sets terrain at coordinates
- **Parameters:**
  - `x, y` (numbers): Tile coordinates (1-based)
  - `terrainId` (string): Terrain identifier
- **Example:**
```lua
block:setTile(5, 5, "wall")
block:setTile(6, 5, "door")
```

#### Serialization

**`MapBlock.loadFromTOML(filepath)`**
- Loads MapBlock from TOML file
- **Parameters:** `filepath` (string): Path to TOML file
- **Returns:** `MapBlock` instance or `nil, error`
- **Example:**
```lua
local block, err = MapBlock.loadFromTOML("mods/core/mapblocks/urban_block_01.toml")
if not block then
    print("Failed to load block: " .. err)
end
```

**`MapBlock.loadAll(directory)`**
- Loads all MapBlock files from directory
- **Parameters:** `directory` (string): Directory path
- **Returns:** `table`: Array of MapBlock instances
- **Example:**
```lua
local blocks = MapBlock.loadAll("mods/core/mapblocks")
print("Loaded " .. #blocks .. " MapBlocks")
```

**`MapBlock:saveToTOML(filepath)`**
- Saves MapBlock to TOML file
- **Parameters:** `filepath` (string): Output file path
- **Returns:** `boolean, error`: Success status and error message
- **Example:**
```lua
local success, err = block:saveToTOML("mods/core/mapblocks/my_block.toml")
if not success then
    print("Failed to save: " .. err)
end
```

#### Utility Methods

**`MapBlock:toASCII()`**
- Generates ASCII representation of block
- **Returns:** `string`: Multi-line ASCII art
- **Example:**
```lua
local ascii = block:toASCII()
print(ascii)
```

**`MapBlock:validate()`**
- Validates block data integrity
- **Returns:** `boolean, errors`: Validation status and error array
- **Example:**
```lua
local valid, errors = block:validate()
if not valid then
    for _, err in ipairs(errors) do
        print("Validation error: " .. err)
    end
end
```

**`MapBlock.createDefaults()`**
- Creates default MapBlock instances for testing
- **Returns:** `table`: Array of default MapBlock instances
- **Example:**
```lua
local defaults = MapBlock.createDefaults()
-- Returns 3 basic blocks: open, urban, forest
```

### GridMap (`systems/battle/grid_map.lua`)

Assembles MapBlocks into complete battlefields using grid-based layout.

#### Overview

GridMap provides:
- **Variable Grid Size**: 4×4 to 7×7 blocks (60-105 tiles)
- **Coordinate Conversion**: World ↔ Grid ↔ Local coordinates
- **Generation Modes**: Random and themed placement
- **Battlefield Conversion**: Creates playable Battlefield instances
- **Biome Preferences**: Weighted selection by terrain type
- **Statistics**: Block placement and biome distribution tracking

#### Constructor

**`GridMap.new(gridWidth, gridHeight)`**
- Creates new GridMap instance
- **Parameters:** `gridWidth, gridHeight` (numbers): Grid dimensions (4-7)
- **Returns:** `GridMap` instance
- **Properties:**
  - `worldWidth`: `gridWidth * 15` (total tiles)
  - `worldHeight`: `gridHeight * 15` (total tiles)
- **Example:**
```lua
local gridMap = GridMap.new(5, 5)  -- 75×75 tile battlefield
```

#### Block Management

**`GridMap:setBlock(gridX, gridY, mapBlock)`**
- Places MapBlock at grid coordinates
- **Parameters:**
  - `gridX, gridY` (numbers): Grid position (0-based)
  - `mapBlock` (MapBlock): Block to place
- **Example:**
```lua
gridMap:setBlock(2, 3, urbanBlock)
```

**`GridMap:getBlock(gridX, gridY)`**
- Gets MapBlock at grid coordinates
- **Parameters:** `gridX, gridY` (numbers): Grid position (0-based)
- **Returns:** `MapBlock` or `nil`
- **Example:**
```lua
local block = gridMap:getBlock(2, 3)
if block then
    print("Block biome: " .. block.metadata.biome)
end
```

#### Coordinate Conversion

**`GridMap:worldToBlock(worldX, worldY)`**
- Converts world coordinates to grid coordinates
- **Parameters:** `worldX, worldY` (numbers): World tile coordinates (1-based)
- **Returns:** `gridX, gridY` (numbers): Grid coordinates (0-based)
- **Example:**
```lua
local gx, gy = gridMap:worldToBlock(45, 67)
```

**`GridMap:blockToWorld(gridX, gridY)`**
- Converts grid coordinates to world coordinates
- **Parameters:** `gridX, gridY` (numbers): Grid coordinates (0-based)
- **Returns:** `worldX, worldY` (numbers): World coordinates (1-based)
- **Example:**
```lua
local wx, wy = gridMap:blockToWorld(2, 3)
```

**`GridMap:worldToLocal(worldX, worldY)`**
- Converts world coordinates to local block coordinates
- **Parameters:** `worldX, worldY` (numbers): World coordinates (1-based)
- **Returns:** `localX, localY` (numbers): Local coordinates (1-based)
- **Example:**
```lua
local lx, ly = gridMap:worldToLocal(45, 67)
-- Gets coordinates within the specific block
```

#### Tile Access

**`GridMap:getTileAt(worldX, worldY)`**
- Gets terrain ID at world coordinates
- **Parameters:** `worldX, worldY` (numbers): World coordinates (1-based)
- **Returns:** `string`: Terrain ID
- **Example:**
```lua
local terrain = gridMap:getTileAt(45, 67)
if terrain == "wall" then
    -- Handle wall
end
```

#### Generation

**`GridMap:generateRandom(blockPool, seed)`**
- Fills grid with random blocks from pool
- **Parameters:**
  - `blockPool` (table): Array of MapBlock instances
  - `seed` (number, optional): Random seed for reproducibility
- **Example:**
```lua
gridMap:generateRandom(blockPool, 12345)
```

**`GridMap:generateThemed(blockPool, biomePreferences)`**
- Fills grid with biome-weighted selection
- **Parameters:**
  - `blockPool` (table): Array of MapBlock instances
  - `biomePreferences` (table): Biome weights (0.0-1.0)
- **Biome Preferences Example:**
```lua
gridMap:generateThemed(blockPool, {
    urban = 0.3,      -- 30% urban blocks
    forest = 0.25,    -- 25% forest blocks
    industrial = 0.2, -- 20% industrial blocks
    water = 0.1,      -- 10% water blocks
    rural = 0.1,      -- 10% rural blocks
    mixed = 0.05      -- 5% mixed blocks
})
```

#### Conversion

**`GridMap:toBattlefield()`**
- Converts GridMap to playable Battlefield instance
- **Returns:** `Battlefield`: Complete battlefield with all tiles
- **Example:**
```lua
local battlefield = gridMap:toBattlefield()
-- battlefield is now ready for gameplay
```

#### Analysis

**`GridMap:getStats()`**
- Gets generation statistics
- **Returns:** `table` with statistics:
  - `blocksPlaced`: Number of blocks placed
  - `totalSlots`: Total grid slots
  - `emptySlots`: Number of empty slots
  - `biomes`: Table of biome counts
- **Example:**
```lua
local stats = gridMap:getStats()
print(string.format("Placed %d/%d blocks", stats.blocksPlaced, stats.totalSlots))
for biome, count in pairs(stats.biomes) do
    print(biome .. ": " .. count)
end
```

**`GridMap:toASCII()`**
- Generates ASCII visualization of entire grid
- **Returns:** `string`: Multi-line ASCII representation
- **Example:**
```lua
local ascii = gridMap:toASCII()
print(ascii)
```

---

## Adding New Systems

1. Create new file in appropriate directory
2. Follow Lua best practices (local variables, camelCase)
3. Add module documentation header
4. Export module: `return ModuleName`
5. Update this API.md file
6. Add tests if applicable

---

## Performance Tips

- Reuse objects instead of creating new ones each frame
- Use `local` for all variables
- Use `ipairs` for indexed arrays, `pairs` for hash tables
- Batch draw calls when possible
- Profile with Love2D's built-in profiler

---

## Common Patterns

### Module Structure
```lua
-- ModuleName
-- Description of module

local ModuleName = {}

function ModuleName:enter()
    -- Initialize state
end

function ModuleName:update(dt)
    -- Update logic
end

function ModuleName:draw()
    -- Render graphics
end

function ModuleName:exit()
    -- Cleanup
end

return ModuleName
```

### Event Handling
```lua
function love.keypressed(key)
    if key == "escape" then
        -- Handle escape key
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then -- Left click
        -- Handle click
    end
end
```

---

## Geoscape System (Strategic Layer)

### Overview

The Geoscape is the strategic world management system featuring:
- **Hex Grid**: 80×40 world map using axial coordinates
- **Province Graph**: Node-based strategic locations with pathfinding
- **Calendar System**: Turn-based time (1 turn = 1 day, 360 days/year)
- **Day/Night Cycle**: Visual overlay moving 4 tiles per day
- **Craft Travel**: Fuel-based travel system with operational range
- **World Rendering**: Camera controls, zoom, pan, and province visualization

### HexGrid (`geoscape/systems/hex_grid.lua`)

Provides hex coordinate system and utilities for 80×40 world map.

#### Key Functions

**`HexGrid.new(width, height, hexSize)`**
- Creates a new hex grid system
- **Parameters:**
  - `width` (number): Grid width in tiles (default 80)
  - `height` (number): Grid height in tiles (default 40)
  - `hexSize` (number): Hex radius in pixels (default 12)
- **Returns:** HexGrid instance

**`HexGrid.distance(q1, r1, q2, r2)`**
- Calculate distance between two hexes
- **Parameters:** Axial coordinates (q, r) for both hexes
- **Returns:** (number) Distance in hex tiles
- **Example:**
```lua
local dist = HexGrid.distance(0, 0, 5, 3)  -- Returns 8
```

**`HexGrid.neighbors(q, r)`**
- Get all 6 adjacent hexes
- **Returns:** Array of `{q, r}` coordinate pairs

**`HexGrid:toPixel(q, r)`**
- Convert hex coordinates to pixel position (center of hex)
- **Returns:** `x, y` (numbers) Pixel coordinates

**`HexGrid:toHex(x, y)`**
- Convert pixel position to hex coordinates
- **Returns:** `q, r` (numbers) Hex coordinates (rounded)

**`HexGrid.ring(q, r, radius)`**
- Get all hexes in a ring at exact distance
- **Returns:** Array of `{q, r}` coordinate pairs

**`HexGrid.area(q, r, radius)`**
- Get all hexes within radius (inclusive)
- **Returns:** Array of `{q, r}` coordinate pairs

### Calendar (`geoscape/systems/calendar.lua`)

Turn-based time management system.

#### Structure

- **1 turn** = 1 day
- **6 days** = 1 week
- **30 days** = 1 month (5 weeks)
- **90 days** = 1 quarter (3 months)
- **360 days** = 1 year (4 quarters)

#### Key Functions

**`Calendar.new(startYear, startMonth, startDay)`**
- Create calendar at specified date
- **Returns:** Calendar instance

**`calendar:advanceTurn()`**
- Advance time by one day
- Processes scheduled events
- **Returns:** self (for chaining)

**`calendar:getFullDate()`**
- Get formatted date string
- **Returns:** "Monday, March 15, Year 1, Q1"

**`calendar:scheduleEvent(daysFromNow, callback, data)`**
- Schedule an event for future turn
- **Parameters:**
  - `daysFromNow` (number): Days in future
  - `callback` (function): Function to call
  - `data` (table): Optional data for callback

### Province (`geoscape/logic/province.lua`)

Strategic location on world map (node in province graph).

#### Structure

```lua
Province = {
    id = "p1",
    name = "Central Europe",
    q = 40, r = 20,           -- Hex position
    biomeId = "temperate_forest",
    regionId = "europe",
    countryId = "germany",
    isLand = true,
    connections = {},         -- Adjacent provinces
    economy = {population, gdp, wealth},
    playerBase = nil,         -- Base object or nil
    crafts = {},              -- List of craft IDs (max 4)
    missions = {},            -- Active missions
    detected = false,         -- Player discovered?
    radarCoverage = false     -- Under radar?
}
```

#### Key Functions

**`Province.new(data)`**
- Create new province
- **Returns:** Province instance

**`province:addConnection(provinceId, cost)`**
- Add connection to another province
- **Parameters:**
  - `provinceId` (string): ID of connected province
  - `cost` (number): Travel cost (default 1)

**`province:addCraft(craftId)`**
- Add craft to this province (max 4)
- **Returns:** (boolean) Success

**`province:hasMissions()`**
- Check if province has active missions
- **Returns:** (boolean)

### ProvinceGraph (`geoscape/logic/province_graph.lua`)

Manages province network and pathfinding.

#### Key Functions

**`ProvinceGraph.new()`**
- Create empty province graph
- **Returns:** ProvinceGraph instance

**`graph:addProvince(province)`**
- Add province to graph

**`graph:addConnection(provinceId1, provinceId2, cost)`**
- Add bidirectional connection between provinces

**`graph:findPath(fromId, toId)`**
- Find path using A* algorithm
- **Returns:** 
  - `path` (table): Array of province IDs, or nil
  - `cost` (number): Total travel cost, or nil
- **Example:**
```lua
local path, cost = graph:findPath("p1", "p5")
if path then
    print("Path length:", #path, "Cost:", cost)
end
```

**`graph:getRange(fromId, maxCost)`**
- Get all provinces within range
- **Returns:** Map of `provinceId -> {cost, path}`
- **Example:**
```lua
local reachable = graph:getRange("p1", 10)
for id, data in pairs(reachable) do
    print(id, "cost:", data.cost)
end
```

### World (`geoscape/logic/world.lua`)

Planetary body with hex grid, provinces, and calendar.

#### Key Functions

**`World.new(data)`**
- Create new world
- **Parameters:**
  - `data.width` (number): Hex width (default 80)
  - `data.height` (number): Hex height (default 40)
  - `data.scale` (number): km per tile (default 500)
  - `data.dayNightSpeed` (number): Tiles per day (default 4)
- **Returns:** World instance

**`world:addProvince(province)`**
- Add province to world and update tile data

**`world:advanceDay()`**
- Advance calendar and day/night cycle by one day

**`world:getLightLevel(q, r)`**
- Get light level at hex (0.0 = night, 1.0 = day)
- **Returns:** (number) Light level

**`world:getProvinceAtHex(q, r)`**
- Get province at hex coordinates
- **Returns:** Province object or nil

### Craft (`geoscape/logic/craft.lua`)

Player craft for travel and missions.

#### Structure

```lua
Craft = {
    id = "craft1",
    name = "Skyranger-1",
    type = "interceptor",
    provinceId = "p1",        -- Current location
    baseId = "base1",         -- Home base
    speed = 1,                -- Provinces per day
    range = 10,               -- Max travel distance
    fuelCapacity = 100,
    currentFuel = 100,
    fuelConsumption = 1,      -- Per province
    soldiers = {},
    items = {}
}
```

#### Key Functions

**`Craft.new(data)`**
- Create new craft

**`craft:deploy(path)`**
- Deploy craft along path
- **Parameters:** `path` (table): Array of province IDs
- **Returns:** (boolean) Success

**`craft:getOperationalRange(provinceGraph)`**
- Get all provinces within fuel range
- **Returns:** Map of reachable provinces

**`craft:canReach(provinceGraph, targetProvinceId)`**
- Check if craft can reach target
- **Returns:**
  - `canReach` (boolean)
  - `fuelRequired` (number)

### DayNightCycle (`geoscape/systems/daynight_cycle.lua`)

Visual day/night overlay moving across world.

#### Key Functions

**`DayNightCycle.new(worldWidth, speed, coverage)`**
- Create day/night cycle
- **Parameters:**
  - `worldWidth` (number): World width in tiles
  - `speed` (number): Tiles per day (default 4)
  - `coverage` (number): Day coverage 0-1 (default 0.5)

**`cycle:advanceDay()`**
- Advance cycle by one day

**`cycle:isDay(q, hexWidth)`**
- Check if hex is in daylight
- **Returns:**
  - `isDay` (boolean)
  - `lightLevel` (number): 0.0 to 1.0

**`DayNightCycle.getDarknessColor(lightLevel)`**
- Get RGBA color for night overlay
- **Returns:** `r, g, b, a` (numbers)

### GeoscapeRenderer (`geoscape/rendering/world_renderer.lua`)

Renders hex world map with camera controls.

#### Key Functions

**`GeoscapeRenderer.new(world)`**
- Create renderer for world

**`renderer:setCameraPosition(x, y)`**
- Set camera world position

**`renderer:setCameraZoom(zoom)`**
- Set camera zoom (0.3 to 3.0)

**`renderer:panCamera(dx, dy)`**
- Pan camera by delta

**`renderer:screenToWorld(screenX, screenY)`**
- Convert screen to world coordinates
- **Returns:** `worldX, worldY` (numbers)

**`renderer:update(dt)`**
- Update renderer (hover detection)

**`renderer:draw()`**
- Draw world, provinces, day/night, UI

#### Controls

- **Mouse Drag**: Pan camera
- **Mouse Wheel**: Zoom in/out
- **Click**: Select province
- **G**: Toggle grid
- **N**: Toggle day/night
- **L**: Toggle labels

### Usage Example

```lua
local World = require("geoscape.logic.world")
local Province = require("geoscape.logic.province")
local GeoscapeRenderer = require("geoscape.rendering.world_renderer")

-- Create world
local world = World.new({
    width = 80,
    height = 40,
    scale = 500
})

-- Create provinces
local p1 = Province.new({
    id = "p1",
    name = "Central Plains",
    q = 40, r = 20,
    biomeId = "plains",
    color = {r = 0.4, g = 0.7, b = 0.4}
})
world:addProvince(p1)

-- Create renderer
local renderer = GeoscapeRenderer.new(world)

-- In love.update
function love.update(dt)
    renderer:update(dt)
end

-- In love.draw
function love.draw()
    renderer:draw()
end

-- Advance time
world:advanceDay()  -- Next day
print(world:getDate())  -- "March 15, Year 1"
```

### Mission (`geoscape/logic/mission.lua`)

Represents a mission on the Geoscape with cover mechanics for detection.

#### Mission Types

- **"site"**: Alien site (land-based, 14 days, orange icon)
- **"ufo"**: UFO (air/land, 7 days, red icon)
- **"base"**: Alien base (underground/underwater, 30 days, purple icon)

#### Mission States

- **"hidden"**: Not yet detected (cover > 0)
- **"detected"**: Detected by radar (cover <= 0, visible on map)
- **"active"**: Player has engaged/intercepted
- **"completed"**: Player successfully completed
- **"expired"**: Mission expired without player action

#### Cover Mechanics

Missions spawn with **cover value** (0-100). Cover regenerates daily and must be reduced to 0 for detection.

- **Cover Reduction**: `cover = cover - radarPower`
- **Daily Regeneration**: `cover = min(coverMax, cover + coverRegen)`
- **Detection**: When `cover <= 0`, mission becomes visible

#### Key Functions

**`Mission:new(config)`**
- Create new mission instance
- **Parameters:**
  - `config.type` (string): Mission type ("site", "ufo", "base")
  - `config.faction` (string): Controlling faction
  - `config.difficulty` (number): Mission difficulty (1+)
  - `config.power` (number): Mission strength
  - `config.coverValue` (number): Initial cover (default 100)
  - `config.coverRegen` (number): Daily cover regeneration
  - `config.duration` (number): Days until expiration
- **Returns:** Mission instance

**`mission:update(daysPassed)`**
- Update mission state for elapsed days
- Regenerates cover if hidden, expires if duration exceeded

**`mission:reduceCover(radarPower)`**
- Reduce mission cover by radar scanning
- **Parameters:** `radarPower` (number): Scanning power
- Automatically detects mission when cover reaches 0

**`mission:getIcon()`**
- Get appropriate icon name for rendering
- **Returns:** (string) Icon type ("ufo_air", "ufo_landed", "alien_site", etc.)

**`mission:getInfo()`**
- Get mission display information
- **Returns:** (table) Info with type, name, difficulty, power, state, etc.

#### Example

```lua
local Mission = require("geoscape.logic.mission")

-- Create alien site mission
local mission = Mission:new({
    type = "site",
    faction = "aliens",
    difficulty = 2,
    power = 150,
    coverValue = 100,
    coverRegen = 5,
    duration = 14
})

-- Daily update
mission:update(1)  -- Cover regenerates to 105

-- Radar scan
mission:reduceCover(50)  -- Cover reduced to 55
mission:reduceCover(60)  -- Cover reduced to 0, mission detected!

print(mission.state)  -- "detected"
print(mission:getIcon())  -- "alien_site"
```

### CampaignManager (`geoscape/systems/campaign_manager.lua`)

Manages the core campaign game loop: time progression, mission generation, and mission lifecycle.

#### Time System

- **1 turn = 1 day**
- **1 week = 7 days** (Monday = day 1, 8, 15, ...)
- **1 month = 30 days**
- **1 year = 365 days**

#### Mission Generation

- **Weekly Schedule**: Missions spawn every Monday (`day % 7 == 0`)
- **Mission Count**: 2-4 missions per week (configurable)
- **Mission Types**: 50% sites, 35% UFOs, 15% bases
- **Difficulty Scaling**: Increases every 4 weeks (+1 difficulty)

#### Key Functions

**`CampaignManager:init()`**
- Initialize campaign with starting conditions
- Sets day 1, creates empty mission lists

**`campaignManager:advanceDay()`**
- Advance game time by one day
- Updates all missions, generates weekly missions, cleans up expired
- **Returns:** (table) Events that occurred

**`campaignManager:generateWeeklyMissions()`**
- Generate 2-4 missions for current week
- Called automatically on Mondays

**`campaignManager:getDetectedMissions()`**
- Get missions visible on Geoscape map
- **Returns:** (table) Array of detected mission objects

**`campaignManager:getActiveMissions()`**
- Get all active missions (hidden + detected + engaged)
- **Returns:** (table) Array of active mission objects

**`campaignManager:getStatistics()`**
- Get campaign statistics
- **Returns:** (table) Stats with day, week, mission counts, etc.

#### Example

```lua
local CampaignManager = require("geoscape.systems.campaign_manager")

-- Initialize campaign
CampaignManager:init()

-- Advance time
CampaignManager:advanceDay()  -- Day 2
CampaignManager:advanceDay()  -- Day 3
-- ... advance to Day 8 (Monday)
CampaignManager:advanceDay()  -- Generates weekly missions

-- Check for detected missions
local detected = CampaignManager:getDetectedMissions()
for _, mission in ipairs(detected) do
    print("Detected:", mission.name, mission.type)
end

-- Get campaign stats
local stats = CampaignManager:getStatistics()
print(string.format("Day %d, %d active missions",
    stats.currentDay, stats.activeMissions))
```

### DetectionManager (`geoscape/systems/detection_manager.lua`)

Handles radar scanning for mission detection from bases and crafts.

#### Radar System

- **Base Radar**: Facilities provide power (20-100) and range (5-20 provinces)
- **Craft Radar**: Equipment provides power (10-25) and range (3-7 provinces)
- **Cover Reduction**: `reduction = radarPower × (1 - distance/maxRange)`
- **Detection**: Mission becomes visible when `cover <= 0`

#### Key Functions

**`DetectionManager:init()`**
- Initialize detection system

**`detectionManager:performDailyScans(campaignManager)`**
- Scan for missions from all bases and crafts
- **Parameters:** `campaignManager` (CampaignManager): Active campaign
- **Returns:** (table) Scan results with detections

**`detectionManager:getBaseRadarPower(base)`**
- Calculate total radar power from base facilities
- **Returns:** (number) Total power

**`detectionManager:getBaseRadarRange(base)`**
- Get maximum radar range from base facilities
- **Returns:** (number) Max range in provinces

**`detectionManager:calculateCoverReduction(radarPower, distance, maxRange)`**
- Calculate cover reduction based on distance falloff
- **Returns:** (number) Cover reduction amount

#### Radar Facilities

| Facility | Power | Range | Cost |
|----------|-------|-------|------|
| Radar Small | 20 | 5 | Low |
| Radar Large | 50 | 10 | Medium |
| Radar Hyperwave | 100 | 20 | High |

#### Example

```lua
local DetectionManager = require("geoscape.systems.detection_manager")
local CampaignManager = require("geoscape.systems.campaign_manager")

-- Initialize systems
DetectionManager:init()
CampaignManager:init()

-- Mock base with radar
local base = {
    facilities = {
        {type = "radar_small"},
        {type = "radar_large"}
    }
}

-- Calculate radar capabilities
local power = DetectionManager:getBaseRadarPower(base)  -- 70
local range = DetectionManager:getBaseRadarRange(base)  -- 10

-- Perform daily scans
local results = DetectionManager:performDailyScans(CampaignManager)
print(string.format("Scans: %d, Detections: %d",
    results.scansPerformed, #results.newDetections))
```

### Mission Detection Integration

#### Geoscape Integration

```lua
-- In geoscape/init.lua
local CampaignManager = require("geoscape.systems.campaign_manager")
local DetectionManager = require("geoscape.systems.detection_manager")

function Geoscape:enter()
    CampaignManager:init()
    DetectionManager:init()
    -- ... other initialization
end

function advanceDay()
    CampaignManager:advanceDay()
    DetectionManager:performDailyScans(CampaignManager)
end
```

#### Mission Rendering

```lua
-- In world_renderer.lua
function GeoscapeRenderer:drawMissions()
    local detectedMissions = self.campaignManager:getDetectedMissions()
    
    for _, mission in ipairs(detectedMissions) do
        self:drawMissionIcon(mission)
    end
end

function GeoscapeRenderer:drawMissionIcon(mission)
    local iconType = mission:getIcon()
    self:drawMissionIconGraphic(iconType, mission.position.x, mission.position.y, mission)
end
```

#### Gameplay Flow

1. **Day 1**: Campaign starts, no missions
2. **Monday (Day 8)**: 2-4 missions spawn with cover=100
3. **Daily**: Radar scans reduce mission cover
4. **Detection**: When cover=0, mission appears on map
5. **Expiration**: Missions expire after duration if not intercepted
6. **Repeat**: New missions spawn every Monday

#### Performance

- **Mission Generation**: O(1) - constant time
- **Radar Scanning**: O(m × s) where m=missions, s=scanners
- **Typical Performance**: <5ms for 10 missions, 5 scanners
- **Memory**: ~1KB per mission

