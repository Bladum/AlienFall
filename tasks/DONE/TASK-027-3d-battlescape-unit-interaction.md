# Task: 3D Battlescape - Unit Interaction & Controls (Phase 2 of 3)

**Status:** TODO  
**Priority:** High  
**Created:** October 13, 2025  
**Completed:** N/A  
**Assigned To:** AI Agent  
**Depends On:** TASK-026 (3D Core Rendering)

---

## Overview

Implement unit rendering, movement, rotation, and interaction systems for the 3D first-person battlescape. This includes billboard sprite rendering for units, WASD hex-based movement controls, mouse picking, item rendering, and minimap integration. All game logic remains turn-based - movement is animated but consumes action points.

---

## Purpose

Complete the interactive 3D experience by adding unit sprites, player movement controls, and tactical interaction features. Players can navigate the hex battlefield in first-person view, see enemy units as billboards, interact with items on the ground, and use the same tactical UI as 2D mode.

---

## Requirements

### Functional Requirements
- [ ] Render units as billboard sprites (always face camera)
- [ ] Billboard sprites use transparent backgrounds (no solid rectangles)
- [ ] WASD hex movement: W=forward, S=backward, A=rotate left 60°, D=rotate right 60°
- [ ] Movement is animated (200ms per tile) but turn-based (consumes AP)
- [ ] Rotation is animated (200ms per 60° turn)
- [ ] Mouse picking to select tiles, walls, and units
- [ ] Display minimap (same as 2D mode) in bottom-right corner
- [ ] Items on ground rendered as small sprites in 5 positions (4 corners + center)
- [ ] Items can be picked up and dropped (Eye of the Beholder style)
- [ ] Unit switching with TAB key
- [ ] Same GUI panels as 2D mode (unit info, actions, etc.)

### Technical Requirements
- [ ] Billboard shader/technique for unit sprites
- [ ] Hex-aware movement system (6 directions, not 8)
- [ ] Smooth interpolation for movement/rotation animations
- [ ] Raycasting for mouse picking (floor, wall, unit, item)
- [ ] Item positioning system (5 slots per tile)
- [ ] Minimap rendering shared with 2D mode
- [ ] Action point deduction integrated with existing combat system
- [ ] Turn-based constraint enforcement (no movement during animation)

### Acceptance Criteria
- [ ] Units visible as billboard sprites in 3D view
- [ ] Player can move with WASD (hex grid movement)
- [ ] Movement consumes action points correctly
- [ ] Rotation works smoothly (A/D keys)
- [ ] Mouse hover highlights tiles, walls, and units
- [ ] Can click to target for actions
- [ ] Items visible on ground (up to 5 per tile)
- [ ] Can pick up and drop items
- [ ] Minimap shows current position and orientation
- [ ] TAB switches between friendly units
- [ ] No desync between 3D and 2D data

---

## Plan

### Step 1: Billboard Sprite System
**Description:** Implement billboard rendering for units - sprites that always face the camera, with transparent backgrounds

**Files to create:**
- `engine/battlescape/rendering/billboard.lua` - Billboard sprite renderer

**Files to modify:**
- `engine/battlescape/rendering/renderer_3d.lua` - Add unit rendering
- `engine/core/assets.lua` - Ensure unit sprites loaded with transparency

**Billboard technique:**
```lua
-- Billboard always faces camera
function Billboard:render(unit, camera)
    local dx = camera.x - unit.x
    local dz = camera.z - unit.z
    local angle = math.atan2(dx, dz)
    
    -- Create quad at unit position, rotated to face camera
    local sprite = Assets.get("unit", unit.spriteName)
    
    -- Render at tile center, Y=0 to Y=1 (ground to head height)
    self:drawQuad(unit.x, 0.5, unit.y, sprite, angle)
end
```

**Transparency handling:**
```lua
-- When loading unit sprites
local sprite = love.graphics.newImage("soldier.png")
sprite:setFilter("nearest", "nearest")  -- Crisp pixels
-- PNG alpha channel provides transparency automatically
```

**Estimated time:** 5 hours

---

### Step 2: WASD Hex Movement System
**Description:** Implement keyboard controls for hex-based movement and rotation. Movement is smooth but turn-based (deducts AP).

**Files to create:**
- `engine/battlescape/systems/movement_3d.lua` - 3D movement controller

**Files to modify:**
- `engine/battlescape/init.lua` - Add keypressed handling for WASD
- `engine/battlescape/rendering/camera_3d.lua` - Add movement/rotation animation

**Hex movement logic:**
```lua
-- W: Move forward in current facing direction
function Movement3D:moveForward(unit, battlefield)
    local direction = unit.facing  -- 0-5 (hex directions)
    local targetQ, targetR = HexMath.neighbor(unit.q, unit.r, direction)
    local targetX, targetY = HexMath.axialToOffset(targetQ, targetR)
    
    -- Check if tile is walkable
    local tile = battlefield:getTile(targetX, targetY)
    if not tile or not tile:isWalkable() then
        print("[3D Movement] Tile blocked")
        return false
    end
    
    -- Check action points
    if unit.actionPointsLeft < 1 then
        print("[3D Movement] Not enough AP")
        return false
    end
    
    -- Start movement animation
    self:animateMovement(unit, targetX, targetY, 0.2)  -- 200ms
    return true
end

-- S: Move backward
function Movement3D:moveBackward(unit, battlefield)
    -- Same as forward but opposite direction
    local direction = (unit.facing + 3) % 6  -- Opposite hex face
    -- ... rest same as moveForward
end

-- A: Rotate left 60°
function Movement3D:rotateLeft(unit)
    local newFacing = (unit.facing - 1) % 6
    self:animateRotation(unit, newFacing, 0.2)  -- 200ms
end

-- D: Rotate right 60°
function Movement3D:rotateRight(unit)
    local newFacing = (unit.facing + 1) % 6
    self:animateRotation(unit, newFacing, 0.2)  -- 200ms
end
```

**Animation system:**
```lua
function Movement3D:animateMovement(unit, targetX, targetY, duration)
    local startX, startY = unit.x, unit.y
    local startTime = love.timer.getTime()
    
    self.animation = {
        type = "movement",
        unit = unit,
        startX = startX,
        startY = startY,
        targetX = targetX,
        targetY = targetY,
        startTime = startTime,
        duration = duration,
        onComplete = function()
            unit.x = targetX
            unit.y = targetY
            unit.actionPointsLeft = unit.actionPointsLeft - 1
            self.animation = nil
        end
    }
end

function Movement3D:update(dt)
    if self.animation then
        local elapsed = love.timer.getTime() - self.animation.startTime
        local progress = math.min(elapsed / self.animation.duration, 1.0)
        
        -- Smooth interpolation
        local t = self:easeInOut(progress)
        
        -- Update unit position for rendering (visual only)
        self.animation.unit.renderX = self.animation.startX + 
            (self.animation.targetX - self.animation.startX) * t
        self.animation.unit.renderY = self.animation.startY + 
            (self.animation.targetY - self.animation.startY) * t
        
        if progress >= 1.0 then
            self.animation.onComplete()
        end
    end
end
```

**Estimated time:** 6 hours

---

### Step 3: Mouse Picking and Targeting
**Description:** Implement mouse raycasting to select tiles, walls, units, and items. Highlight hovered objects and enable click-to-target.

**Files to create:**
- `engine/battlescape/systems/mouse_picking_3d.lua` - Mouse picking system

**Files to modify:**
- `engine/battlescape/rendering/hex_raycaster.lua` - Add unit intersection
- `engine/battlescape/init.lua` - Add mousemoved and mousepressed handlers

**Mouse picking flow:**
```lua
function MousePicking3D:update(mouseX, mouseY, camera, battlefield, units)
    -- Cast ray from camera through mouse position
    local ray = self:screenToWorldRay(mouseX, mouseY, camera)
    
    -- Check intersections in order: units > walls > items > floor
    local unitHit = self:rayIntersectUnits(ray, units)
    if unitHit then
        self.hoveredObject = {type = "unit", unit = unitHit.unit}
        return
    end
    
    local wallHit = self:rayIntersectWalls(ray, battlefield)
    if wallHit then
        self.hoveredObject = {type = "wall", x = wallHit.x, y = wallHit.y}
        return
    end
    
    local itemHit = self:rayIntersectItems(ray, battlefield)
    if itemHit then
        self.hoveredObject = {type = "item", item = itemHit.item}
        return
    end
    
    local floorHit = self:rayIntersectFloor(ray)
    if floorHit then
        self.hoveredObject = {type = "floor", x = floorHit.x, y = floorHit.y}
        return
    end
    
    self.hoveredObject = nil
end

function MousePicking3D:onClick(button)
    if not self.hoveredObject then return end
    
    if button == 1 then  -- Left click
        self:onLeftClick(self.hoveredObject)
    elseif button == 2 then  -- Right click
        self:onRightClick(self.hoveredObject)
    end
end
```

**Visual feedback:**
```lua
-- Highlight hovered object
function Renderer3D:drawHighlight(hoveredObject)
    if hoveredObject.type == "unit" then
        -- Draw outline around unit billboard
        self:drawUnitOutline(hoveredObject.unit, {r=1, g=1, b=0})
    elseif hoveredObject.type == "floor" then
        -- Draw highlighted floor tile
        self:drawFloorHighlight(hoveredObject.x, hoveredObject.y, {r=0, g=1, b=0})
    end
end
```

**Estimated time:** 7 hours

---

### Step 4: Ground Item Rendering
**Description:** Render items on ground as small sprites in 5 positions (4 corners + center), scaled to 50%. Support pickup/drop interaction.

**Files to create:**
- `engine/battlescape/rendering/item_renderer_3d.lua` - Ground item renderer

**Files to modify:**
- `engine/battlescape/rendering/renderer_3d.lua` - Add item rendering pass

**Item positioning (5 slots per tile):**
```lua
ITEM_SLOTS = {
    {x = -0.3, z = -0.3},  -- Top-left corner
    {x = 0.3,  z = -0.3},  -- Top-right corner
    {x = 0.0,  z = 0.0},   -- Center
    {x = -0.3, z = 0.3},   -- Bottom-left corner
    {x = 0.3,  z = 0.3}    -- Bottom-right corner
}

function ItemRenderer3D:renderGroundItems(tile)
    local items = tile:getItems()
    
    for i, item in ipairs(items) do
        if i > 5 then break end  -- Max 5 items per tile
        
        local slot = ITEM_SLOTS[i]
        local worldX = tile.x + slot.x
        local worldZ = tile.y + slot.z
        
        -- Render as small horizontal quad on ground
        local sprite = Assets.get("item", item.spriteName)
        self:drawGroundQuad(worldX, 0.05, worldZ, sprite, 0.5)  -- 50% scale
    end
end
```

**Pickup/drop interaction:**
```lua
-- E key to pick up item under cursor
function Battlescape:keypressed(key)
    if key == "e" and self.viewMode == "3D" then
        local hovered = self.mousePicking:getHoveredObject()
        if hovered and hovered.type == "item" then
            self:pickupItem(hovered.item)
        end
    end
end

-- Q key to drop item from inventory
function Battlescape:keypressed(key)
    if key == "q" and self.viewMode == "3D" then
        -- Open inventory UI to select item to drop
        self:openInventoryDrop()
    end
end
```

**Estimated time:** 4 hours

---

### Step 5: Minimap Integration
**Description:** Display minimap in 3D mode using same system as 2D mode, showing position, orientation, and tactical overview.

**Files to modify:**
- `engine/battlescape/init.lua` - Render minimap in 3D mode
- `engine/battlescape/ui/minimap.lua` - Add 3D camera orientation indicator

**Minimap rendering:**
```lua
-- In Battlescape:draw() when viewMode == "3D"
function Battlescape:draw()
    -- Render 3D view
    self.renderer3D:draw(...)
    
    -- Draw GUI panels (same as 2D)
    self:drawGUI()
    
    -- Draw minimap in bottom-right
    local minimapX = 720  -- Right edge of game view
    local minimapY = 480  -- Bottom area
    local minimapSize = 240
    
    self.minimap:draw(minimapX, minimapY, minimapSize, self.camera3D)
end

-- Minimap shows camera orientation as arrow
function Minimap:draw(x, y, size, camera3D)
    -- ... existing minimap rendering
    
    -- Add orientation arrow for 3D camera
    if camera3D then
        local angle = camera3D.facing * 60  -- Hex direction to degrees
        self:drawOrientationArrow(camera3D.unit.x, camera3D.unit.y, angle)
    end
end
```

**Estimated time:** 3 hours

---

### Step 6: Unit Switching and GUI Integration
**Description:** Enable TAB key to switch between friendly units in 3D mode, with same GUI as 2D mode.

**Files to modify:**
- `engine/battlescape/init.lua` - Add TAB key handler
- `engine/battlescape/rendering/camera_3d.lua` - Update camera to new unit

**Unit switching:**
```lua
function Battlescape:keypressed(key)
    if key == "tab" and self.viewMode == "3D" then
        self:selectNextUnit()
        
        -- Update 3D camera to new unit
        if self.selection.selectedUnit then
            self.camera3D:setUnit(self.selection.selectedUnit)
            print(string.format("[3D] Switched to unit: %s at (%d, %d)", 
                  self.selection.selectedUnit.name,
                  self.selection.selectedUnit.x,
                  self.selection.selectedUnit.y))
        end
    end
end

-- Camera3D follows unit
function Camera3D:setUnit(unit)
    self.unit = unit
    self.x = unit.x
    self.z = unit.y
    self.y = 0.5  -- Eye level
    self.facing = unit.facing or 0
    self:updateMatrices()
end
```

**GUI consistency:**
```lua
-- Both 2D and 3D use same UI panels
function Battlescape:drawGUI()
    -- Right panel (unit info, actions)
    self.unitInfoPanel:draw()
    self.actionPanel:draw()
    
    -- Bottom panel (items, squad)
    self.itemPanel:draw()
    
    -- These work identically in 2D and 3D modes
end
```

**Estimated time:** 3 hours

**Total estimated time:** 28 hours (3-4 days)

---

## Implementation Details

### Architecture

**Billboard Rendering:**
- Units rendered as textured quads
- Quads always rotate to face camera
- Texture coordinates maintain proper orientation
- Alpha channel provides transparency

**Turn-Based Movement:**
- Movement triggered by WASD keys
- Movement animated over 200ms
- Movement blocked during animation
- Action points deducted on completion
- No real-time gameplay - still turn-based

**Mouse Picking Pipeline:**
```
Mouse (x,y) 
  -> Screen to world ray
  -> Check unit bounding boxes (closest first)
  -> Check wall planes
  -> Check item quads
  -> Check floor plane
  -> Return closest intersection
```

**Item Slot System:**
- Each tile has 5 item slots
- Slots positioned at corners and center
- Items rendered as small quads flat on ground
- Max 5 items visible per tile

### Key Components

**Billboard:**
- Renders sprites that face camera
- Handles transparency
- Supports different unit types
- Handles unit animations (future)

**Movement3D:**
- Manages WASD input
- Validates hex movement
- Animates movement/rotation
- Deducts action points
- Enforces turn-based rules

**MousePicking3D:**
- Raycasting from screen to world
- Intersection tests for all object types
- Hover highlighting
- Click event handling
- Cursor changes

**ItemRenderer3D:**
- Ground item rendering
- 5-slot positioning
- Scale to 50%
- Pickup/drop interaction

### Dependencies

**From Phase 1:**
- `Renderer3D` - Main 3D renderer
- `Camera3D` - First-person camera
- `HexRaycaster` - Hex raycasting system

**Existing Systems:**
- `Unit` - Unit data structure
- `ActionSystem` - Turn-based action handling
- `Pathfinding` - Path validation
- `Assets` - Sprite loading
- `Minimap` - Tactical overview

**New Libraries:**
- None - uses existing g3d from Phase 1

### Data Flow

```
[WASD Input]
    |
    v
[Movement3D] -> Validate hex tile
    |            Check AP
    |            Start animation
    v
[Camera3D] -> Interpolate position
    |         Update matrices
    v
[Renderer3D] -> Render scene from new viewpoint
    |           Draw billboard units
    |           Draw ground items
    v
[Animation Complete] -> Deduct AP
                       Update unit position
                       Update visibility
```

---

## Testing Strategy

### Unit Tests

**Test 1: Billboard Facing**
```lua
-- Test that billboard always faces camera
local billboard = Billboard.new()
local unit = {x = 5, y = 5}
local camera = {x = 3, y = 3}

billboard:update(unit, camera)
local angle = billboard:getRotation()

-- Angle should point from unit to camera
local expected = math.atan2(camera.x - unit.x, camera.y - unit.y)
assert(math.abs(angle - expected) < 0.01, "Billboard must face camera")
```

**Test 2: Hex Movement Validation**
```lua
-- Test hex movement in 6 directions
local movement = Movement3D.new()
local unit = {x = 10, y = 10, facing = 0, actionPointsLeft = 10}

for direction = 0, 5 do
    unit.facing = direction
    local targetX, targetY = movement:getForwardTile(unit)
    local distance = HexMath.distance(unit.x, unit.y, targetX, targetY)
    assert(distance == 1, "Forward movement must be exactly 1 hex")
end
```

**Test 3: Item Slot Positioning**
```lua
-- Test that items positioned in 5 valid slots
local renderer = ItemRenderer3D.new()
local slots = renderer:getItemSlots()

assert(#slots == 5, "Must have exactly 5 slots")
for i, slot in ipairs(slots) do
    assert(slot.x >= -0.5 and slot.x <= 0.5, "Slot X in tile bounds")
    assert(slot.z >= -0.5 and slot.z <= 0.5, "Slot Z in tile bounds")
end
```

### Integration Tests

**Test 1: WASD Movement Cycle**
- Start in 3D mode at position (10, 10) facing east (0°)
- Press W (move forward)
- Verify movement to (11, 10)
- Verify 1 AP deducted
- Press A (rotate left)
- Verify facing changes to northeast (5)
- Press W again
- Verify movement to new hex in northeast direction

**Test 2: Mouse Picking Accuracy**
- Load map with units, walls, items
- Move mouse over unit
- Verify unit highlighted
- Move mouse over floor
- Verify floor tile highlighted
- Click on unit
- Verify unit selected

**Test 3: Unit Switching**
- Create 3 friendly units
- Press TAB
- Verify camera moves to unit 2
- Press TAB again
- Verify camera moves to unit 3
- Press TAB again
- Verify camera cycles back to unit 1

### Manual Testing Steps

1. **Launch and enter 3D mode:**
   ```bash
   lovec "engine"
   ```
   - Start battlescape
   - Press SPACE to enter 3D mode

2. **Test movement:**
   - Press W - unit moves forward, see animation
   - Check console: "AP: 9/10" or similar
   - Press S - unit moves backward
   - Press A - unit rotates left (smooth animation)
   - Press D - unit rotates right

3. **Test mouse picking:**
   - Move mouse around screen
   - Verify cursor changes over different objects
   - See highlights on hovered objects
   - Click on floor tile - see selection
   - Click on enemy unit - initiate targeting

4. **Test item interaction:**
   - Find tile with items
   - Move mouse over item
   - See item highlighted
   - Press E to pick up
   - Verify item in inventory
   - Press Q to drop
   - See item return to ground

5. **Test minimap:**
   - Check bottom-right corner
   - See minimap showing tactical view
   - See arrow showing unit facing
   - Rotate with A/D
   - Verify arrow rotates

6. **Test unit switching:**
   - Press TAB
   - See camera jump to next unit
   - Check minimap shows new position
   - Press TAB multiple times
   - Verify cycles through all friendly units

7. **Test turn system:**
   - Use all AP for current unit
   - Press TAB - can control other units
   - End turn
   - Verify enemy units move
   - Verify view switches to enemy perspective (or stays if not their turn)

### Expected Results

**Console Output:**
```
[3D Movement] Unit moving from (10,10) to (11,10)
[3D Movement] AP remaining: 9/10
[3D Movement] Animation complete
[3D Mouse] Hovered: unit [Soldier 1]
[3D Mouse] Clicked: floor tile (12, 15)
[3D] Switched to unit: Soldier 2 at (8, 12)
[3D Items] Picked up: Medkit
[3D Items] Dropped: Grenade at (10, 10) slot 3
```

**Visual Results:**
- Units visible as billboards, facing camera
- Smooth movement animation (200ms)
- Smooth rotation animation (200ms)
- Mouse highlights correct objects
- Items visible on ground (up to 5)
- Minimap shows position and orientation
- GUI panels work same as 2D

**Performance:**
- 60 FPS maintained
- No lag during movement
- Smooth animations

---

## How to Run/Debug

### Running the Game
```bash
lovec "engine"
```

### Debugging Movement

**Enable movement logging:**
```lua
-- In Movement3D
local DEBUG_MOVEMENT = true

function Movement3D:moveForward(unit, battlefield)
    if DEBUG_MOVEMENT then
        print(string.format("[3D Movement] Unit at (%d,%d) facing %d", 
              unit.x, unit.y, unit.facing))
        print(string.format("[3D Movement] Target tile: (%d,%d)", 
              targetX, targetY))
        print(string.format("[3D Movement] AP: %d/%d", 
              unit.actionPointsLeft, unit.actionPointsMax))
    end
    -- ... movement logic
end
```

**Visualize hex directions:**
```lua
-- On-screen debug overlay
function Battlescape:draw()
    -- ... 3D rendering
    
    if DEBUG_MOVEMENT then
        love.graphics.setColor(1, 1, 0)
        love.graphics.print(string.format("Facing: %d (%d°)", 
            self.activeUnit.facing, self.activeUnit.facing * 60), 10, 50)
        love.graphics.print(string.format("Position: (%d, %d)", 
            self.activeUnit.x, self.activeUnit.y), 10, 70)
    end
end
```

### Debugging Mouse Picking

**Visual ray debug:**
```lua
function MousePicking3D:debug(ray)
    -- Draw ray in world space (if possible with g3d)
    local rayEnd = {
        ray.origin[1] + ray.direction[1] * 10,
        ray.origin[2] + ray.direction[2] * 10,
        ray.origin[3] + ray.direction[3] * 10
    }
    
    -- Draw line from camera to ray end
    love.graphics.setColor(1, 0, 0)
    love.graphics.line(ray.origin[1], ray.origin[3], rayEnd[1], rayEnd[3])
end
```

**Console logging:**
```lua
function MousePicking3D:update(mouseX, mouseY, camera, battlefield, units)
    local hit = self:raycast(...)
    
    if hit then
        print(string.format("[3D Picking] Mouse (%d,%d) -> %s at (%.2f, %.2f, %.2f)",
              mouseX, mouseY, hit.type, hit.x, hit.y, hit.z))
    end
end
```

### Common Issues

1. **Units not visible:**
   - Check unit sprite loading
   - Verify billboard rotation calculation
   - Check camera position and facing

2. **Movement not working:**
   - Verify hex neighbor calculation
   - Check tile walkability
   - Ensure AP available

3. **Mouse picking inaccurate:**
   - Debug ray direction calculation
   - Verify screen-to-world transformation
   - Check intersection math

4. **Animation stuttering:**
   - Check dt (delta time) usage
   - Verify animation timer
   - Profile update loop

### Temporary Files
All temporary files MUST use: `os.getenv("TEMP")`

---

## Documentation Updates

### Files to Update

- [x] **`wiki/API.md`** - Add Phase 2 APIs:
  ```markdown
  ## Billboard Rendering
  
  ### Billboard.new()
  Create billboard sprite renderer.
  
  ### billboard:render(unit, camera)
  Render unit as billboard facing camera.
  
  ## 3D Movement
  
  ### Movement3D.new()
  Create 3D movement controller.
  
  ### movement3D:moveForward(unit, battlefield)
  Move unit forward one hex tile.
  
  ### movement3D:rotateLeft(unit)
  Rotate unit 60° left (hex grid).
  ```

- [x] **`wiki/FAQ.md`** - Add movement FAQs:
  ```markdown
  ## Q: How do I move in 3D mode?
  A: W=forward, S=backward, A=rotate left 60°, D=rotate right 60°
  
  ## Q: Why can't I move in 3D mode?
  A: Check action points. Movement consumes AP like in 2D mode.
  
  ## Q: How do I pick up items?
  A: Hover mouse over item, press E key.
  ```

- [ ] **Code comments** - Full inline documentation

---

## Notes

- **Billboard technique:** Sprites must always face camera for proper 3D illusion, like classic Doom/Wolfenstein sprites.
- **Hex movement:** 6 directions (not 8) - ensure WASD maps to hex geometry correctly.
- **Turn-based preservation:** All movement is still turn-based. Animations are visual only.

---

## Blockers

- Requires completion of TASK-026 (Phase 1: Core Rendering)

---

## Review Checklist

- [ ] Code follows Lua/Love2D best practices
- [ ] No global variables
- [ ] Proper error handling
- [ ] Performance optimized
- [ ] Temp files use TEMP folder
- [ ] Console debugging
- [ ] Tests written and passing
- [ ] Documentation updated
- [ ] Code reviewed
- [ ] No warnings
- [ ] Billboards face camera correctly
- [ ] Movement respects hex grid (6 directions)
- [ ] AP system integrated
- [ ] Animations smooth (200ms timing)

---

## Post-Completion

### What Worked Well
- (To be filled)

### What Could Be Improved
- (To be filled)

### Lessons Learned
- (To be filled)
