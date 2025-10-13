# 3D Battlescape - Technical Architecture Reference

**Created:** October 13, 2025  
**Purpose:** Technical reference for 3D battlescape implementation

---

## System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        BATTLESCAPE STATE                         │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  Shared Game Data (Single Source of Truth)                 │ │
│  │  • Battlefield (tiles, terrain, objects)                   │ │
│  │  • Units (position, stats, inventory, AP)                  │ │
│  │  • Teams (players, AI, turn order)                         │ │
│  │  • Fire/Smoke Systems (effect positions)                   │ │
│  │  • LOS System (visibility data)                            │ │
│  │  • Turn Manager (active team, phase)                       │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                   │
│  ┌─────────────────────┐          ┌─────────────────────┐        │
│  │   2D RENDERER       │          │   3D RENDERER       │        │
│  │  (Existing)         │          │   (New)             │        │
│  ├─────────────────────┤          ├─────────────────────┤        │
│  │ • Top-down view     │          │ • First-person view │        │
│  │ • Sprite rendering  │          │ • Hex raycasting    │        │
│  │ • Grid overlay      │          │ • Billboard sprites │        │
│  │ • FOW tiles         │   [SPACE]│ • Distance fog      │        │
│  │ • Unit sprites      │  <─────> │ • 3D effects        │        │
│  │ • Effect overlays   │  TOGGLE  │ • Sky rendering     │        │
│  └─────────────────────┘          └─────────────────────┘        │
│                                                                   │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  Common UI (Same in Both Modes)                            │ │
│  │  • Right Panel: Unit Info, Actions, Inventory             │ │
│  │  • Bottom Panel: Squad List, Selected Unit Details        │ │
│  │  • Minimap: Tactical Overview + Position Indicator        │ │
│  └────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

---

## 3D Rendering Pipeline

```
┌─────────────────────────────────────────────────────────────────┐
│                    RENDERER3D:DRAW()                             │
└─────────────────────────────────────────────────────────────────┘
                              |
                              v
┌─────────────────────────────────────────────────────────────────┐
│  STEP 1: Prepare Camera                                          │
│  • Set position at active unit (x, y, z)                        │
│  • Set height at eye level (Y = 0.5)                            │
│  • Set facing direction (one of 6 hex directions)               │
│  • Calculate view matrix                                         │
└─────────────────────────────────────────────────────────────────┘
                              |
                              v
┌─────────────────────────────────────────────────────────────────┐
│  STEP 2: Hex Raycasting                                          │
│  • Cast rays in view frustum                                    │
│  • Check intersections with 6 wall faces per hex tile          │
│  • Check floor plane (Y = 0)                                    │
│  • Check ceiling plane (Y = 1) or sky                           │
│  • Build list of visible tiles with distances                  │
└─────────────────────────────────────────────────────────────────┘
                              |
                              v
┌─────────────────────────────────────────────────────────────────┐
│  STEP 3: LOS Filtering                                           │
│  • Query LOS system for visible tiles                           │
│  • Remove tiles outside unit's vision range                     │
│  • Apply day/night visibility limits                            │
│  • Mark explored vs visible tiles                               │
└─────────────────────────────────────────────────────────────────┘
                              |
                              v
┌─────────────────────────────────────────────────────────────────┐
│  STEP 4: Render Terrain                                          │
│  • Render floor tiles (textured quads at Y=0)                  │
│  • Render wall tiles (6 vertical quads per blocking tile)      │
│  • Render ceiling tiles (textured quads at Y=1) or sky         │
│  • Apply distance-based darkening (fog)                        │
│  • Apply day/night brightness                                  │
└─────────────────────────────────────────────────────────────────┘
                              |
                              v
┌─────────────────────────────────────────────────────────────────┐
│  STEP 5: Collect Billboards                                      │
│  • Collect all billboard objects in view:                       │
│    - Units (always face camera)                                │
│    - Objects (trees, tables - face camera)                     │
│    - Ground items (5 slots per tile)                           │
│    - Effects (fire, smoke, explosions)                         │
│  • Calculate distance from camera for each                      │
└─────────────────────────────────────────────────────────────────┘
                              |
                              v
┌─────────────────────────────────────────────────────────────────┐
│  STEP 6: Z-Sort Billboards                                       │
│  • Sort all billboards by distance (far to near)               │
│  • This ensures proper alpha blending                           │
│  • Furthest objects render first                                │
└─────────────────────────────────────────────────────────────────┘
                              |
                              v
┌─────────────────────────────────────────────────────────────────┐
│  STEP 7: Render Billboards                                       │
│  • For each billboard (in sorted order):                        │
│    - Calculate rotation to face camera                          │
│    - Apply texture with nearest-neighbor filter                │
│    - Apply transparency (alpha channel)                        │
│    - Apply distance fog                                         │
│  • Render objects, units, items, effects                        │
└─────────────────────────────────────────────────────────────────┘
                              |
                              v
┌─────────────────────────────────────────────────────────────────┐
│  STEP 8: Render UI Overlays                                      │
│  • Draw mouse picking highlight                                 │
│  • Draw targeting reticle                                       │
│  • Draw minimap                                                 │
│  • Draw GUI panels (same as 2D)                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Hex Grid 3D Geometry

### Hex Tile Wall Faces (6 per tile)

```
           Top View                    3D Side View
                                      
     NW (2)      NE (1)                    +---+
        \        /                        /  5  \
         +------+                        +-------+
   W (3) |      | E (0)                 /|       |\
         +------+                      / |   0   | \
        /        \                    /  |       |  \
     SW (4)      SE (5)              /   +-------+   \
                                    / 4 /|       |\ 1 \
                                   +---+ |   3   | +---+
                                    \ 3  \|       |/  2 /
                                     \    +-------+    /
                                      \       2       /
                                       +-------------+

Each hex tile has 6 vertical wall faces at 60° intervals
Wall face normal vectors point outward from tile center
```

### Hex Neighbor Calculation

```lua
-- Hex directions (axial coordinates)
HEX_DIRECTIONS = {
    {q = 1, r = 0},   -- E  (0)
    {q = 1, r = -1},  -- NE (1)
    {q = 0, r = -1},  -- NW (2)
    {q = -1, r = 0},  -- W  (3)
    {q = -1, r = 1},  -- SW (4)
    {q = 0, r = 1}    -- SE (5)
}

-- Get neighbor tile in direction
function getHexNeighbor(q, r, direction)
    local dir = HEX_DIRECTIONS[direction + 1]
    return q + dir.q, r + dir.r
end
```

---

## Movement System Architecture

### WASD Hex Movement

```
┌─────────────────────────────────────────────────────────────────┐
│  W Key Pressed (Move Forward)                                    │
└─────────────────────────────────────────────────────────────────┘
                              |
                              v
┌─────────────────────────────────────────────────────────────────┐
│  Movement3D:moveForward(unit, battlefield)                       │
│  1. Get unit's current facing (0-5)                             │
│  2. Calculate target hex using HexMath.neighbor()               │
│  3. Check if target tile exists and is walkable                 │
│  4. Check if unit has action points                             │
│  5. If valid, start animation                                   │
└─────────────────────────────────────────────────────────────────┘
                              |
                              v
┌─────────────────────────────────────────────────────────────────┐
│  Animation System                                                │
│  • Store start position and target position                     │
│  • Store start time                                             │
│  • Duration: 200ms (configurable)                               │
│  • Block new movement during animation                          │
└─────────────────────────────────────────────────────────────────┘
                              |
                              v (update every frame)
┌─────────────────────────────────────────────────────────────────┐
│  Movement3D:update(dt)                                           │
│  • Calculate elapsed time since animation start                 │
│  • Calculate progress (0.0 to 1.0)                              │
│  • Interpolate position (ease-in-out)                           │
│  • Update camera position for rendering                         │
└─────────────────────────────────────────────────────────────────┘
                              |
                              v (when progress >= 1.0)
┌─────────────────────────────────────────────────────────────────┐
│  Animation Complete                                              │
│  • Update unit's actual position                                │
│  • Deduct 1 action point                                        │
│  • Update visibility (LOS recalculation)                        │
│  • Clear animation state                                        │
│  • Allow new input                                              │
└─────────────────────────────────────────────────────────────────┘
```

### Rotation System (A/D Keys)

```
A Key: Rotate Left 60°
  facing = (facing - 1) % 6

D Key: Rotate Right 60°
  facing = (facing + 1) % 6

Animation:
  • Interpolate angle over 200ms
  • Update camera rotation
  • No AP cost for rotation
```

---

## Billboard Rendering System

### Billboard Orientation

```lua
-- Calculate billboard rotation to face camera
function Billboard:calculateFacing(objectPos, cameraPos)
    local dx = cameraPos.x - objectPos.x
    local dz = cameraPos.z - objectPos.z
    
    -- Angle from object to camera
    local angle = math.atan2(dx, dz)
    
    return angle
end

-- Render billboard quad
function Billboard:render(position, sprite, camera)
    local angle = self:calculateFacing(position, camera.position)
    
    -- Create quad facing camera
    local vertices = self:createQuad(
        position.x, position.y, position.z,
        sprite.width, sprite.height,
        angle
    )
    
    -- Apply texture
    love.graphics.setShader(billboardShader)
    love.graphics.draw(sprite, vertices)
    love.graphics.setShader()
end
```

### Billboard Types

```
┌─────────────────────────────────────────────────────────────────┐
│  UNIT BILLBOARDS                                                 │
│  • Height: Y=0 to Y=1 (ground to head)                          │
│  • Always face camera                                           │
│  • Use unit sprite (soldier, alien, etc.)                       │
│  • Apply transparency from PNG alpha                            │
│  • Show health bar above sprite                                 │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  OBJECT BILLBOARDS (Trees, Tables, Fences)                       │
│  • Variable height (0.4 to 1.5)                                 │
│  • Always face camera                                           │
│  • Positioned at tile center                                    │
│  • Transparent (allow vision through)                           │
│  • Block movement but not sight                                 │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  ITEM BILLBOARDS (Ground Items)                                  │
│  • Height: Y=0.05 (just above floor)                           │
│  • Positioned in 5 slots per tile:                             │
│    - 4 corners: (±0.3, ±0.3)                                   │
│    - Center: (0, 0)                                            │
│  • Scaled to 50% of normal size                                │
│  • Horizontal orientation (lie flat)                            │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  EFFECT BILLBOARDS (Fire, Smoke, Explosions)                     │
│  • Animated (multiple frames)                                   │
│  • Variable height based on effect type                         │
│  • Fire: Emissive (glows in dark)                              │
│  • Smoke: Semi-transparent (alpha 0.6)                          │
│  • Explosions: Temporary (500ms duration)                       │
└─────────────────────────────────────────────────────────────────┘
```

---

## Mouse Picking System

### Screen to World Ray

```
┌─────────────────────────────────────────────────────────────────┐
│  Mouse Position (screenX, screenY)                               │
└─────────────────────────────────────────────────────────────────┘
                              |
                              v
┌─────────────────────────────────────────────────────────────────┐
│  Calculate Ray Direction                                         │
│  • Normalize screen coordinates (-1 to 1)                       │
│  • Apply FOV and aspect ratio                                   │
│  • Rotate by camera orientation                                 │
│  • Result: ray origin + direction vector                        │
└─────────────────────────────────────────────────────────────────┘
                              |
                              v
┌─────────────────────────────────────────────────────────────────┐
│  Intersection Tests (in order)                                   │
│  1. Units: Check bounding boxes (closest first)                │
│  2. Walls: Check 6 wall planes per hex tile                    │
│  3. Items: Check ground quads in 5 slots                       │
│  4. Floor: Check Y=0 plane                                     │
└─────────────────────────────────────────────────────────────────┘
                              |
                              v
┌─────────────────────────────────────────────────────────────────┐
│  Return Closest Hit                                              │
│  • Type: "unit", "wall", "item", "floor"                        │
│  • Position: (x, y, z)                                          │
│  • Distance: from camera                                        │
│  • Object reference: unit, item, etc.                           │
└─────────────────────────────────────────────────────────────────┘
```

---

## Combat System Integration

### Shooting Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│  Right-Click on Enemy Unit                                       │
└─────────────────────────────────────────────────────────────────┘
                              |
                              v
┌─────────────────────────────────────────────────────────────────┐
│  Combat3D:shoot(shooter, target)                                 │
│  • Validate target in LOS                                       │
│  • Check ammo and AP                                            │
│  • Call ActionSystem:executeAttack()                            │
└─────────────────────────────────────────────────────────────────┘
                              |
                              v
┌─────────────────────────────────────────────────────────────────┐
│  ActionSystem:executeAttack(shooter, target, losSystem)          │
│  • Calculate hit chance (accuracy, distance, cover)             │
│  • Roll for hit/miss                                            │
│  • Calculate damage if hit                                      │
│  • Return result {hit, damage, apCost}                          │
└─────────────────────────────────────────────────────────────────┘
                              |
                              v
┌─────────────────────────────────────────────────────────────────┐
│  Visual Feedback                                                 │
│  • Play muzzle flash at shooter position (100ms)                │
│  • Play bullet tracer from shooter to target (50ms)             │
│  • If HIT: Play hit spark, show damage number                  │
│  • If MISS: Play miss spark at ground near target              │
│  • Update unit health bar                                       │
└─────────────────────────────────────────────────────────────────┘
                              |
                              v
┌─────────────────────────────────────────────────────────────────┐
│  State Update                                                    │
│  • Deduct ammo from shooter                                     │
│  • Deduct AP from shooter                                       │
│  • Update target health if hit                                  │
│  • Check if target killed                                       │
│  • Update UI panels                                             │
└─────────────────────────────────────────────────────────────────┘
```

---

## Performance Optimization

### Rendering Optimizations

```
┌─────────────────────────────────────────────────────────────────┐
│  1. Frustum Culling                                              │
│  • Only process tiles in camera view frustum                    │
│  • Skip tiles behind camera                                     │
│  • Skip tiles beyond max render distance                        │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  2. LOS-Based Culling                                            │
│  • Only render tiles visible to active unit                     │
│  • Use existing shadow-casting LOS system                       │
│  • Skip hidden and unexplored tiles                             │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  3. Texture Caching                                              │
│  • Load all textures once at initialization                     │
│  • Share textures between 2D and 3D renderers                   │
│  • Use texture atlases where possible                           │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  4. Z-Sorting Optimization                                       │
│  • Only sort billboards once per frame                          │
│  • Use stable sort algorithm                                    │
│  • Consider spatial hashing for large unit counts               │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  5. Effect Pooling                                               │
│  • Reuse effect objects instead of creating new ones           │
│  • Limit max active effects (e.g., 20 fires max)                │
│  • Remove old effects when limit reached                        │
└─────────────────────────────────────────────────────────────────┘
```

---

## File Structure

```
engine/
├── battlescape/
│   ├── init.lua                    (MODIFIED: Add 3D mode toggle)
│   │
│   ├── rendering/
│   │   ├── renderer.lua            (Existing 2D renderer)
│   │   ├── renderer_3d.lua         (NEW: Main 3D renderer)
│   │   ├── camera_3d.lua           (NEW: First-person camera)
│   │   ├── hex_raycaster.lua       (NEW: Hex raycasting)
│   │   ├── hex_geometry.lua        (NEW: Hex math utilities)
│   │   ├── billboard.lua           (NEW: Billboard sprite system)
│   │   ├── effects_3d.lua          (NEW: 3D effects renderer)
│   │   ├── object_renderer_3d.lua  (NEW: Object renderer)
│   │   └── item_renderer_3d.lua    (NEW: Ground item renderer)
│   │
│   ├── systems/
│   │   ├── movement_3d.lua         (NEW: 3D movement controller)
│   │   └── mouse_picking_3d.lua    (NEW: Mouse raycasting)
│   │
│   └── combat/
│       └── combat_3d.lua           (NEW: 3D combat handler)
│
└── libs/
    └── g3d/                        (NEW: Copy from 3d_maze_demo)
        ├── g3d.lua
        ├── matrices.lua
        └── ...
```

---

## Configuration and Constants

```lua
-- 3D Rendering Configuration
CONFIG_3D = {
    -- Camera
    FOV = 60,                    -- Field of view in degrees
    NEAR_PLANE = 0.1,            -- Near clipping plane
    FAR_PLANE = 50.0,            -- Far clipping plane
    EYE_HEIGHT = 0.5,            -- Camera height (Y coordinate)
    
    -- Movement
    MOVE_DURATION = 0.2,         -- Seconds per tile movement
    ROTATE_DURATION = 0.2,       -- Seconds per 60° rotation
    
    -- Rendering
    MAX_RENDER_DISTANCE = 15,    -- Max tiles to render
    FOG_START = 5,               -- Distance where fog starts
    FOG_END = 15,                -- Distance where fully fogged
    
    -- Performance
    MAX_BILLBOARDS = 100,        -- Max billboards per frame
    MAX_FIRE_EFFECTS = 20,       -- Max simultaneous fires
    MAX_SMOKE_EFFECTS = 10,      -- Max simultaneous smoke
    
    -- Visual
    TEXTURE_FILTER = "nearest",  -- No anti-aliasing
    NIGHT_BRIGHTNESS = 0.3,      -- Brightness multiplier at night
    SKY_COLOR_DAY = {0.5, 0.7, 1.0},    -- RGB
    SKY_COLOR_NIGHT = {0.05, 0.05, 0.2}  -- RGB
}
```

---

## Debug and Testing Tools

### Debug Overlays

```lua
-- F1: Toggle 3D debug overlay
if DEBUG_3D then
    love.graphics.print("3D Mode Debug", 10, 10)
    love.graphics.print(string.format("Camera: (%.2f, %.2f, %.2f)", 
        camera.x, camera.y, camera.z), 10, 30)
    love.graphics.print(string.format("Facing: %d (%d°)", 
        camera.facing, camera.facing * 60), 10, 50)
    love.graphics.print(string.format("Visible Tiles: %d", 
        #visibleTiles), 10, 70)
    love.graphics.print(string.format("Billboards: %d", 
        #billboards), 10, 90)
    love.graphics.print(string.format("FPS: %d", 
        love.timer.getFPS()), 10, 110)
end
```

### Console Commands

```lua
-- Debug console commands (when running with lovec)
commands = {
    "/tp x y" = "Teleport active unit to (x, y)",
    "/face dir" = "Set facing to direction (0-5)",
    "/fog on/off" = "Toggle distance fog",
    "/los on/off" = "Toggle LOS enforcement",
    "/night on/off" = "Toggle night mode",
    "/billboard on/off" = "Toggle billboard rendering"
}
```

---

## Known Limitations and Future Work

### Current Limitations
- No dynamic lighting (fire glow is faked)
- No shadows cast by objects
- No reflections or water effects
- Billboard sprites don't animate (walking, etc.)
- No weapon recoil or advanced animations
- Limited to single-level maps (no multi-story)

### Future Enhancements
- Advanced lighting with shadow mapping
- Animated unit sprites (walk cycles, shooting)
- Weather effects (rain, snow, fog)
- Destructible walls and objects
- VR support (major undertaking)
- Replay camera system

---

This technical architecture document provides a comprehensive reference for implementing the 3D battlescape system. All three task documents (TASK-026, TASK-027, TASK-028) follow this architecture.
