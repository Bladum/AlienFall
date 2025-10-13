# Task: 3D Battlescape - Core Rendering System (Phase 1 of 3)

**Status:** TODO  
**Priority:** High  
**Created:** October 13, 2025  
**Completed:** N/A  
**Assigned To:** AI Agent

---

## Overview

Implement the foundational 3D first-person rendering system for battlescape that runs in parallel with the existing 2D tactical view. This phase focuses on core rendering infrastructure, hex-based raycasting, camera management, and basic tile/wall rendering using existing 24×24 pixel assets.

---

## Purpose

Enable players to view the tactical battlefield from a first-person perspective similar to classic games like Eye of the Beholder, Ishar, and Wolfenstein 3D, while maintaining full compatibility with the existing turn-based 2D battlescape logic. This provides immersive tactical gameplay and allows players to see the battlefield from their unit's actual viewpoint.

---

## Requirements

### Functional Requirements
- [ ] Toggle between 2D and 3D view with SPACE key
- [ ] First-person perspective rendering from active unit's position
- [ ] Hex-based raycasting with 6 wall faces per tile (not 4 like square grids)
- [ ] Render floor tiles as textured ground planes
- [ ] Render wall tiles as vertical textured planes (all 6 hex faces)
- [ ] Render ceiling/sky based on day/night and tile ceiling data
- [ ] Distance-based darkening (fog effect)
- [ ] Use existing 24×24 pixel terrain assets without anti-aliasing
- [ ] Maintain 960×720 resolution in both views
- [ ] Grid snapping to 24×24 pixel grid system (even in 3D UI overlays)

### Technical Requirements
- [ ] Integrate g3d library (or similar 3D rendering for Love2D 12.0+)
- [ ] Create hex raycasting system (6 directions, not 4)
- [ ] Implement first-person camera with hex-aware positioning
- [ ] Create texture scaling system (24×24 to 3D polygons)
- [ ] Implement depth-based brightness calculation
- [ ] Share battlefield data with existing 2D battlescape
- [ ] Maintain turn-based logic - no real-time rendering changes to game state
- [ ] Zero impact on 2D mode performance

### Acceptance Criteria
- [ ] Can toggle between 2D and 3D views seamlessly
- [ ] 3D view correctly renders floor, walls, and ceiling from active unit's position
- [ ] Hex tiles correctly show 6 potential wall faces
- [ ] Textures are crisp 24×24 pixel art (no filtering/smoothing)
- [ ] Distance fog darkens tiles progressively
- [ ] Day/night affects sky rendering (bright day sky vs dark night sky)
- [ ] No crashes or performance degradation
- [ ] All temporary files use system TEMP directory
- [ ] Console shows debug info for 3D mode

---

## Plan

### Step 1: 3D Library Integration and Setup
**Description:** Integrate g3d or equivalent 3D rendering library into engine, configure for Love2D 12.0+, and set up basic rendering pipeline

**Files to create:**
- `engine/battlescape/rendering/renderer_3d.lua` - Main 3D renderer
- `engine/battlescape/rendering/camera_3d.lua` - First-person camera controller
- `engine/battlescape/rendering/hex_raycaster.lua` - Hex-based raycasting system
- `engine/libs/g3d/` - Copy g3d library from 3d_maze_demo

**Files to modify:**
- `engine/battlescape/init.lua` - Add 3D mode toggle and initialization
- `engine/conf.lua` - Ensure 3D rendering modules enabled

**Key implementation:**
```lua
-- In battlescape/init.lua
self.viewMode = "2D"  -- "2D" or "3D"
self.renderer3D = nil  -- Created when switching to 3D

function Battlescape:toggleViewMode()
    if self.viewMode == "2D" then
        self.viewMode = "3D"
        if not self.renderer3D then
            local Renderer3D = require("battlescape.rendering.renderer_3d")
            self.renderer3D = Renderer3D.new(self)
        end
        self.renderer3D:initialize()
    else
        self.viewMode = "2D"
    end
end
```

**Estimated time:** 4 hours

---

### Step 2: Hex Raycasting System
**Description:** Implement raycasting for hexagonal grid with 6 wall faces per tile, not 4. Handle hex geometry for proper wall intersection detection.

**Files to create:**
- `engine/battlescape/rendering/hex_geometry.lua` - Hex geometry utilities

**Files to modify:**
- `engine/battlescape/rendering/hex_raycaster.lua` - Core raycasting logic

**Key algorithms:**
- Hex tile has 6 wall faces at 60° intervals (0°, 60°, 120°, 180°, 240°, 300°)
- Player facing is one of 6 directions (not 8)
- Ray intersection must check all 6 potential walls per hex tile
- Distance calculation uses hex distance, not Euclidean

**Hex wall face positions (for flat-top hex):**
```lua
-- For hex at (q, r) in axial coordinates
HEX_WALLS = {
    {angle = 0,   direction = "E"},   -- East wall
    {angle = 60,  direction = "NE"},  -- Northeast wall
    {angle = 120, direction = "NW"},  -- Northwest wall
    {angle = 180, direction = "W"},   -- West wall
    {angle = 240, direction = "SW"},  -- Southwest wall
    {angle = 300, direction = "SE"}   -- Southeast wall
}
```

**Estimated time:** 6 hours

---

### Step 3: Basic Floor and Wall Rendering
**Description:** Render floor and wall tiles using existing 24×24 terrain assets, with proper texture mapping and no filtering

**Files to modify:**
- `engine/battlescape/rendering/renderer_3d.lua` - Add floor/wall rendering
- `engine/battlescape/rendering/camera_3d.lua` - Position camera at unit eye level

**Key rendering features:**
- Floor: Horizontal plane at Y=0 with terrain texture
- Walls: Vertical planes from Y=0 to Y=1 with wall texture
- Height: Camera at Y=0.5 (eye level)
- Texture filtering: Nearest-neighbor (no smoothing)
- Hex wall rendering: Each of 6 faces uses neighbor tile data

**Texture loading:**
```lua
-- Disable texture filtering for pixel art
local texture = love.graphics.newImage("path/to/tile.png")
texture:setFilter("nearest", "nearest")
```

**Estimated time:** 5 hours

---

### Step 4: Ceiling and Sky Rendering
**Description:** Implement ceiling rendering for indoor tiles and sky rendering for outdoor tiles, with day/night cycle support

**Files to modify:**
- `engine/battlescape/rendering/renderer_3d.lua` - Add ceiling/sky rendering

**Rendering logic:**
```lua
function Renderer3D:renderCeiling(tile, isNight)
    if tile.hasCeiling then
        -- Render ceiling texture at Y=1
        self:drawCeilingPlane(tile.ceilingTexture)
    else
        -- Render sky
        if isNight then
            self:drawSky({r=0.05, g=0.05, b=0.2})  -- Dark blue night
        else
            self:drawSky({r=0.5, g=0.7, b=1.0})    -- Bright day sky
        end
    end
end
```

**Estimated time:** 3 hours

---

### Step 5: Distance-Based Darkening (Fog)
**Description:** Implement progressive darkening of tiles based on distance from camera to create depth perception

**Files to modify:**
- `engine/battlescape/rendering/renderer_3d.lua` - Add fog calculation

**Fog algorithm:**
```lua
function Renderer3D:calculateBrightness(distance, maxVisibility)
    -- Linear falloff based on unit's visibility range
    local brightness = 1.0 - (distance / maxVisibility)
    brightness = math.max(0.1, math.min(1.0, brightness))
    return brightness
end
```

**Estimated time:** 2 hours

---

### Step 6: Integration and Testing
**Description:** Integrate 3D renderer with existing battlescape, add keyboard toggle, test with various map configurations

**Files to modify:**
- `engine/battlescape/init.lua` - Add love.draw() conditional rendering
- `engine/battlescape/init.lua` - Add love.keypressed() for SPACE toggle

**Integration code:**
```lua
function Battlescape:draw()
    if self.viewMode == "2D" then
        -- Existing 2D rendering
        self.renderer:draw(...)
    else
        -- New 3D rendering
        self.renderer3D:draw(...)
    end
    
    -- UI panels remain the same in both modes
    self:drawGUI()
end

function Battlescape:keypressed(key)
    if key == "space" then
        self:toggleViewMode()
    end
    -- ... existing keypressed code
end
```

**Estimated time:** 4 hours

**Total estimated time:** 24 hours (3 days)

---

## Implementation Details

### Architecture

**Parallel Rendering System:**
- 2D renderer (`BattlefieldRenderer`) - Existing top-down view
- 3D renderer (`Renderer3D`) - New first-person view
- Both share same `Battlefield` data structure
- Toggle switches between renderers, not data

**Hex-Based Raycasting:**
Unlike square grids (4 walls), hex grids have 6 potential wall faces per tile. Raycasting must:
1. Check all 6 neighbor tiles for walls
2. Calculate 6 plane intersections (not 4)
3. Use hex distance for fog calculation
4. Handle 60° rotations (not 90°)

**Camera System:**
- Position: Active unit's (x, y) tile coordinates
- Height: Y=0.5 (eye level, where Y=0 is floor, Y=1 is ceiling)
- Facing: One of 6 hex directions (0°, 60°, 120°, 180°, 240°, 300°)
- No freelook - camera locked to unit's facing

**Texture System:**
- Reuse existing Assets system (`core/assets.lua`)
- Load all terrain textures as before
- Apply nearest-neighbor filter
- Scale 24×24 textures to 3D geometry

### Key Components

**Renderer3D:**
- Main 3D rendering coordinator
- Manages g3d integration
- Handles draw loop for 3D view
- Switches between floor/wall/ceiling rendering

**Camera3D:**
- First-person camera at unit position
- Locked to hex grid (no sub-tile movement)
- Facing locked to 6 hex directions
- Eye-level height (Y=0.5)

**HexRaycaster:**
- Raycasting for hex grid geometry
- 6-wall intersection per tile
- Distance-based visibility
- Mouse picking support (for Phase 2)

**HexGeometry:**
- Hex tile math utilities
- Wall face position calculation
- Neighbor tile lookup
- Direction to angle conversion

### Dependencies

- **g3d library** - 3D rendering for Love2D (copy from 3d_maze_demo)
- **Existing battlescape systems:**
  - `battlefield.lua` - Tile data
  - `camera.lua` - 2D camera (reference for viewport)
  - `unit.lua` - Active unit position
  - `los_optimized.lua` - Visibility data (for Phase 2)
- **Existing assets:**
  - `core/assets.lua` - Texture loading
  - All terrain images in `assets/images/`
- **Hex math:**
  - `battle/utils/hex_math.lua` - Hex grid utilities

### Data Flow

```
[Battlescape State] <-- Shared Data
       |
       +-- [2D Mode: BattlefieldRenderer]
       |          |
       |          +-> Render top-down tiles
       |          +-> Render units as sprites
       |
       +-- [3D Mode: Renderer3D]
                  |
                  +-> Get active unit position
                  +-> HexRaycaster: Find visible tiles
                  +-> Render floor planes
                  +-> Render wall planes (6 per tile)
                  +-> Render ceiling/sky
                  +-> Apply distance fog
```

### Memory Management

- **Texture caching:** All textures loaded once, shared between 2D and 3D
- **3D models:** Simple quads for walls/floors - minimal memory
- **State switching:** 3D renderer created on-demand, persists after first use
- **Temporary files:** Use `os.getenv("TEMP")` for any debug output

---

## Testing Strategy

### Unit Tests

**Test 1: Hex Raycaster - Wall Intersection**
```lua
-- Test that raycasting finds all 6 potential walls
local raycaster = HexRaycaster.new()
local walls = raycaster:findWalls(x, y, facing, battlefield)
assert(#walls <= 6, "Should never find more than 6 walls per tile")
```

**Test 2: Camera Position - Hex Grid Locking**
```lua
-- Test that camera locks to hex grid positions
local camera = Camera3D.new(unit)
assert(camera.x == unit.x, "Camera X must match unit X")
assert(camera.y == 0.5, "Camera height at eye level")
assert(camera.z == unit.y, "Camera Z must match unit Y")
```

**Test 3: Texture Filtering**
```lua
-- Test that textures use nearest-neighbor filtering
local texture = Assets.get("terrain", "stone wall")
local minFilter, magFilter = texture:getFilter()
assert(minFilter == "nearest", "Must use nearest-neighbor min filter")
assert(magFilter == "nearest", "Must use nearest-neighbor mag filter")
```

### Integration Tests

**Test 1: Mode Toggle**
- Load battlescape
- Press SPACE
- Verify mode switches to "3D"
- Press SPACE again
- Verify mode switches back to "2D"
- No crashes, no errors

**Test 2: Shared Data**
- Load battlescape in 2D mode
- Move unit to position (10, 15)
- Switch to 3D mode
- Verify camera is at position (10, 15)
- Verify visible tiles match unit's LOS

**Test 3: Rendering Different Terrains**
- Create test map with floor, walls, doors, trees
- Switch to 3D mode
- Verify each terrain type renders correctly
- Verify textures match 2D asset names

### Manual Testing Steps

1. **Launch game with Love2D console enabled:**
   ```bash
   lovec "engine"
   ```

2. **Start battlescape:**
   - From main menu, select "Battlescape"
   - Wait for map generation

3. **Test 2D mode (baseline):**
   - Verify units visible
   - Verify terrain renders correctly
   - Note active unit position

4. **Toggle to 3D mode:**
   - Press SPACE
   - Check console for "[3D] Mode activated" message
   - Verify smooth transition

5. **Verify 3D rendering:**
   - Floor tiles should be visible
   - Walls should block view
   - Sky/ceiling visible above
   - Distance fog darkens far tiles

6. **Test rotation (Phase 2 feature - not yet implemented):**
   - A key should rotate left 60° (future)
   - D key should rotate right 60° (future)

7. **Toggle back to 2D:**
   - Press SPACE
   - Verify return to 2D view
   - No errors in console

8. **Test day/night:**
   - Set `Battlescape.isNight = true` in console
   - Switch to 3D mode
   - Verify darker sky
   - Verify darker fog

### Expected Results

**Console Output:**
```
[Battlescape] Entering battlescape state
[3D] Initializing 3D renderer
[3D] g3d library loaded
[3D] Hex raycaster initialized
[3D] Camera3D created at unit position (10, 15)
[3D] Mode activated - rendering first-person view
[3D] Rendering 24 visible tiles
[3D] Distance fog: max distance = 8 tiles
```

**Visual Results:**
- 3D view shows textured floor extending forward
- Walls block view with 24×24 pixel textures
- Sky visible above (bright blue day, dark blue night)
- Distant tiles progressively darker
- No texture filtering artifacts
- Crisp pixel art appearance

**Performance:**
- Stable 60 FPS in 3D mode
- No frame drops when toggling
- Memory usage < 200MB

---

## How to Run/Debug

### Running the Game
```bash
lovec "engine"
```
or use VS Code task: "Run XCOM Simple Game" (Ctrl+Shift+P > Run Task)

### Debugging 3D Rendering

**Enable verbose 3D logging:**
```lua
-- In battlescape/rendering/renderer_3d.lua
local DEBUG_3D = true

function Renderer3D:draw()
    if DEBUG_3D then
        print(string.format("[3D] Camera pos: (%.2f, %.2f, %.2f)", 
              self.camera.x, self.camera.y, self.camera.z))
        print(string.format("[3D] Camera facing: %d degrees", 
              math.deg(self.camera.facing)))
    end
    -- ... rendering code
end
```

**On-screen debug overlay:**
```lua
-- In Battlescape:draw() when in 3D mode
love.graphics.setColor(1, 1, 0)
love.graphics.print(string.format("3D Mode - Pos: (%d, %d) Facing: %d", 
    self.activeUnit.x, self.activeUnit.y, self.activeUnit.facing), 10, 10)
love.graphics.print(string.format("Visible tiles: %d", #visibleTiles), 10, 30)
```

**Common issues:**

1. **Black screen in 3D mode:**
   - Check console for g3d loading errors
   - Verify camera position is valid
   - Check that unit has valid position

2. **Textures appear blurry:**
   - Verify texture filter is "nearest"
   - Check texture loading in Assets

3. **Wrong wall faces showing:**
   - Debug hex raycaster wall detection
   - Verify hex neighbor calculation
   - Check HexMath.neighbor() calls

4. **Performance issues:**
   - Reduce max render distance
   - Check for texture reload on each frame (should cache)
   - Profile with love.timer.getTime()

### Temporary Files
- All temporary files MUST be created in: `os.getenv("TEMP")`
- Example: `os.getenv("TEMP") .. "\\battlescape_3d_debug.log"`
- Never create temp files in project directories

---

## Documentation Updates

### Files to Update

- [x] **`wiki/API.md`** - Add 3D rendering API section:
  ```markdown
  ## Battlescape 3D Rendering API
  
  ### Renderer3D
  Main 3D renderer for first-person view.
  
  #### Renderer3D.new(battlescape)
  Create new 3D renderer instance.
  
  #### renderer3D:draw()
  Render 3D first-person view of battlefield.
  
  ### Camera3D
  First-person camera controller.
  
  #### Camera3D.new(unit)
  Create camera at unit's position.
  
  ### HexRaycaster
  Raycasting system for hex grids.
  
  #### raycaster:castRay(origin, direction, maxDistance)
  Cast ray and return intersections.
  ```

- [x] **`wiki/FAQ.md`** - Add 3D mode FAQ:
  ```markdown
  ## Q: How do I switch to 3D first-person view?
  A: Press SPACE key to toggle between 2D and 3D views.
  
  ## Q: Why do walls have 6 faces instead of 4?
  A: The battlefield uses a hexagonal grid, so each tile has 6 neighbors.
  
  ## Q: Can I freelook in 3D mode?
  A: No, the camera is locked to your unit's facing direction (6 hex directions).
  ```

- [x] **`wiki/DEVELOPMENT.md`** - Add 3D development notes:
  ```markdown
  ## 3D Battlescape Development
  
  ### Hex Raycasting
  Unlike square grids, hex grids require checking 6 wall faces per tile.
  
  ### Camera System
  Camera is always positioned at active unit's location, facing one of 6 hex directions.
  
  ### Texture Management
  All textures use nearest-neighbor filtering for crisp pixel art.
  ```

- [ ] **Code comments** - Add inline documentation to all new files

---

## Notes

- **Hex grid complexity:** Rendering hex grids in 3D is more complex than square grids due to 6-sided geometry. The raycasting must handle 60° angles instead of 90°.

- **Performance consideration:** The 3D renderer should only render visible tiles (those within LOS and render distance). Use existing LOS data from 2D mode.

- **g3d library:** The g3d library from 3d_maze_demo provides basic 3D rendering. It may need modifications for hex geometry.

- **Texture scaling:** 24×24 pixel textures will be scaled to 3D polygons. Ensure nearest-neighbor filtering to maintain pixel art style.

- **No unit rendering yet:** Phase 1 focuses only on terrain. Unit sprites will be added in Phase 2.

---

## Blockers

- None - all dependencies exist in current codebase

---

## Review Checklist

- [ ] Code follows Lua/Love2D best practices
- [ ] No global variables (all use `local`)
- [ ] Proper error handling with `pcall` where needed
- [ ] Performance optimized (object reuse, efficient loops)
- [ ] All temporary files use TEMP folder (`os.getenv("TEMP")`)
- [ ] Console debugging statements added
- [ ] Tests written and passing
- [ ] Documentation updated
- [ ] Code reviewed
- [ ] No warnings in Love2D console
- [ ] Textures use nearest-neighbor filtering
- [ ] Hex geometry correctly handles 6 wall faces
- [ ] Mode toggle works smoothly (no lag)
- [ ] Both 2D and 3D modes render correctly

---

## Post-Completion

### What Worked Well
- (To be filled after completion)

### What Could Be Improved
- (To be filled after completion)

### Lessons Learned
- (To be filled after completion)
