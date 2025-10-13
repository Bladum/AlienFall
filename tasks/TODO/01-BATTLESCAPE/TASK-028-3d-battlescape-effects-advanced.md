# Task: 3D Battlescape - Effects & Advanced Features (Phase 3 of 3)

**Status:** TODO  
**Priority:** Medium  
**Created:** October 13, 2025  
**Completed:** N/A  
**Assigned To:** AI Agent  
**Depends On:** TASK-027 (3D Unit Interaction)

---

## Overview

Implement advanced visual effects and features for 3D battlescape: fire/smoke rendering, object rendering (tables, trees, fences), visibility system integration, shooting mechanics, and full feature parity with 2D mode. This completes the 3D first-person battlescape implementation.

---

## Purpose

Provide a complete and polished 3D tactical experience with all visual effects, interactive objects, proper visibility rules, and combat mechanics. Players should have identical tactical capabilities in 3D mode as in 2D mode, with enhanced immersion from the first-person perspective.

---

## Requirements

### Functional Requirements
- [ ] Render fire effects as animated billboard sprites
- [ ] Render smoke effects as semi-transparent animated sprites
- [ ] Render objects (tables, fences, trees) as billboards with transparency
- [ ] Objects block movement but allow visibility (see-through)
- [ ] Visibility system: day/night affects view distance in 3D
- [ ] LOS (Line of Sight) enforced: only render visible tiles/units
- [ ] Shooting: click on visible target to fire weapon
- [ ] Shooting uses same combat system as 2D (accuracy, damage, etc.)
- [ ] Explosion effects (grenades, explosions) as animated sprites
- [ ] All effects use 24×24 pixel sprites (no AA)
- [ ] Effects respect fog of war (hidden tiles show no effects)

### Technical Requirements
- [ ] Fire/smoke use existing FireSystem and SmokeSystem
- [ ] Billboard rendering for all effects and objects
- [ ] Z-sorting for proper sprite layering
- [ ] Integration with existing LOS system
- [ ] Integration with existing ActionSystem for combat
- [ ] Animation system for effects (fire flicker, smoke drift)
- [ ] Transparency blending for smoke and effects
- [ ] Performance: maintain 60 FPS with multiple effects

### Acceptance Criteria
- [ ] Fire visible as animated flames (day and night)
- [ ] Smoke visible as semi-transparent clouds
- [ ] Objects (trees, tables) render correctly with transparency
- [ ] Can see through objects but not through walls
- [ ] Day/night affects visibility range (same as 2D rules)
- [ ] Can only see units/effects within LOS
- [ ] Can shoot visible targets by clicking
- [ ] Hit/miss determined by existing combat system
- [ ] Explosion effects play on impact
- [ ] No performance issues with many effects
- [ ] All effects use existing 24×24 sprites

---

## Plan

### Step 1: Fire Effect Rendering
**Description:** Integrate existing FireSystem with 3D renderer, render fire as animated billboard sprites

**Files to create:**
- `engine/battlescape/rendering/effects_3d.lua` - 3D effects renderer

**Files to modify:**
- `engine/battlescape/rendering/renderer_3d.lua` - Add effects rendering pass
- `engine/battlescape/effects/fire_system.lua` - Ensure 3D compatibility

**Fire rendering:**
```lua
function Effects3D:renderFire(fireSystem, camera)
    local fires = fireSystem:getAllFires()
    
    for _, fire in ipairs(fires) do
        -- Get fire animation frame
        local frame = self:getFireFrame(fire, love.timer.getTime())
        
        -- Render as billboard at tile position
        local sprite = Assets.get("effects", "fire" .. frame)
        
        -- Fire rises from ground (Y=0) to above ground (Y=1.2)
        self:drawBillboard(fire.x, 0.6, fire.y, sprite, camera, {
            width = 1.0,
            height = 1.2,
            emissive = true  -- Fire glows in the dark
        })
        
        -- Add flickering light effect
        if self.settings.dynamicLighting then
            self:addPointLight(fire.x, 0.6, fire.y, {
                color = {1.0, 0.6, 0.2},
                intensity = 0.8 + math.random() * 0.2,
                radius = 3.0
            })
        end
    end
end

function Effects3D:getFireFrame(fire, time)
    -- Animate fire: 4 frames at 10 FPS
    local fps = 10
    local frameCount = 4
    local frame = math.floor(time * fps) % frameCount + 1
    return frame
end
```

**Fire intensity:**
```lua
-- Fire brightness unaffected by fog
function Renderer3D:renderFirePass()
    love.graphics.setBlendMode("add")  -- Additive blending for fire
    self.effects3D:renderFire(self.fireSystem, self.camera)
    love.graphics.setBlendMode("alpha")  -- Restore normal blending
end
```

**Estimated time:** 5 hours

---

### Step 2: Smoke Effect Rendering
**Description:** Integrate SmokeSystem with 3D renderer, render smoke as semi-transparent animated billboards

**Files to modify:**
- `engine/battlescape/rendering/effects_3d.lua` - Add smoke rendering
- `engine/battlescape/effects/smoke_system.lua` - Ensure 3D compatibility

**Smoke rendering:**
```lua
function Effects3D:renderSmoke(smokeSystem, camera)
    local smokeClouds = smokeSystem:getAllSmoke()
    
    for _, smoke in ipairs(smokeClouds) do
        -- Get smoke animation frame (slower than fire)
        local frame = self:getSmokeFrame(smoke, love.timer.getTime())
        
        -- Render as semi-transparent billboard
        local sprite = Assets.get("effects", "smoke" .. frame)
        
        -- Smoke rises: Y increases over time
        local age = love.timer.getTime() - smoke.startTime
        local yOffset = age * 0.5  -- Rises slowly
        local alpha = math.max(0.1, 1.0 - (age / smoke.duration))
        
        self:drawBillboard(smoke.x, 0.5 + yOffset, smoke.y, sprite, camera, {
            width = 1.5,  -- Smoke larger than tile
            height = 1.5,
            alpha = alpha * 0.6  -- Semi-transparent
        })
    end
end

function Effects3D:getSmokeFrame(smoke, time)
    -- Animate smoke: 3 frames at 5 FPS
    local fps = 5
    local frameCount = 3
    local frame = math.floor(time * fps) % frameCount + 1
    return frame
end
```

**Smoke obscures vision:**
```lua
-- Smoke tiles reduce visibility (optional enhancement)
function Renderer3D:applySmokeFog(distance, tile)
    local baseFog = self:calculateFog(distance)
    
    if tile.hasSmoke then
        -- Smoke adds extra fog effect
        baseFog = baseFog * 0.5  -- Darker through smoke
    end
    
    return baseFog
end
```

**Estimated time:** 4 hours

---

### Step 3: Object Rendering (Tables, Trees, Fences)
**Description:** Render non-wall objects as billboards with transparency, block movement but allow visibility through them

**Files to create:**
- `engine/battlescape/rendering/object_renderer_3d.lua` - Object renderer

**Files to modify:**
- `engine/battlescape/rendering/renderer_3d.lua` - Add object rendering pass

**Object types:**
```lua
OBJECT_TYPES = {
    -- Blocks movement, allows vision
    {id = "table", sprite = "table", height = 0.8, transparent = true},
    {id = "fence", sprite = "wood fence", height = 1.0, transparent = true},
    {id = "tree", sprite = "tree", height = 1.5, transparent = true},
    {id = "bush", sprite = "plant small 01", height = 0.6, transparent = true},
    
    -- Low objects (don't fully block vision)
    {id = "rock", sprite = "rock", height = 0.4, transparent = true},
    {id = "crate", sprite = "crate", height = 0.8, transparent = false}
}

function ObjectRenderer3D:renderObjects(battlefield, camera)
    -- Get all tiles with objects
    for y = 1, battlefield.height do
        for x = 1, battlefield.width do
            local tile = battlefield:getTile(x, y)
            if tile and tile.object then
                self:renderObject(tile, camera)
            end
        end
    end
end

function ObjectRenderer3D:renderObject(tile, camera)
    local obj = tile.object
    local objType = self:getObjectType(obj.id)
    
    -- Render as billboard at tile center
    local sprite = Assets.get("objects", objType.sprite)
    
    self:drawBillboard(tile.x, objType.height / 2, tile.y, sprite, camera, {
        width = 1.0,
        height = objType.height,
        alpha = objType.transparent and 0.9 or 1.0
    })
end
```

**Vision through objects:**
```lua
-- Objects don't block LOS rays (walls do)
function HexRaycaster:castRay(origin, direction, battlefield)
    -- ... raycasting logic
    
    local tile = battlefield:getTile(x, y)
    if tile.terrain.blocksVision then
        -- Wall blocks ray
        return hit
    elseif tile.object and not tile.object.allowsVision then
        -- Some objects block vision (rare)
        return hit
    end
    
    -- Continue ray through transparent objects
end
```

**Estimated time:** 5 hours

---

### Step 4: Visibility and LOS Integration
**Description:** Integrate existing LOS system with 3D renderer, enforce day/night visibility rules, fog of war rendering

**Files to modify:**
- `engine/battlescape/rendering/renderer_3d.lua` - Add LOS checks
- `engine/battlescape/combat/los_optimized.lua` - Ensure 3D compatibility

**LOS enforcement:**
```lua
function Renderer3D:draw(battlefield, camera, losSystem, isNight)
    -- Only render tiles within unit's LOS
    local visibleTiles = losSystem:getVisibleTiles(camera.unit)
    
    for _, tile in ipairs(visibleTiles) do
        local distance = HexMath.distance(camera.unit.x, camera.unit.y, tile.x, tile.y)
        
        -- Apply day/night visibility limits
        local maxVisibility = isNight and camera.unit.nightVision or camera.unit.vision
        
        if distance <= maxVisibility then
            self:renderTile(tile, distance, maxVisibility)
        end
    end
    
    -- Only render units in LOS
    local visibleUnits = losSystem:getVisibleUnits(camera.unit)
    for _, unit in ipairs(visibleUnits) do
        self:renderUnit(unit, camera)
    end
    
    -- Only render effects in LOS
    self:renderEffects(visibleTiles, camera)
end
```

**Fog of war (FOW) rendering:**
```lua
-- Hidden tiles render as black
-- Explored tiles render dimmed
-- Visible tiles render normally

function Renderer3D:getTileVisibility(tile, team)
    local fow = tile:getFOW(team.id)
    
    if fow == "visible" then
        return "visible"
    elseif fow == "explored" then
        return "explored"  -- Render dimmed, no units/effects
    else
        return "hidden"  -- Render black
    end
end
```

**Estimated time:** 6 hours

---

### Step 5: Shooting Mechanics and Combat Integration
**Description:** Implement weapon firing from 3D view, integrate with existing ActionSystem, show hit/miss feedback

**Files to create:**
- `engine/battlescape/combat/combat_3d.lua` - 3D combat handler

**Files to modify:**
- `engine/battlescape/init.lua` - Add right-click shooting
- `engine/battlescape/combat/action_system.lua` - Ensure 3D compatibility

**Shooting workflow:**
```lua
-- Right-click on visible enemy to shoot
function Battlescape:mousepressed(x, y, button)
    if self.viewMode ~= "3D" then return end
    
    if button == 2 then  -- Right click
        local hovered = self.mousePicking:getHoveredObject()
        
        if hovered and hovered.type == "unit" then
            local target = hovered.unit
            
            -- Check if target is enemy and visible
            if target.team ~= self.activeUnit.team then
                self:shootAtTarget(self.activeUnit, target)
            end
        elseif hovered and hovered.type == "floor" then
            -- Shoot at ground (e.g., grenade)
            self:shootAtPosition(self.activeUnit, hovered.x, hovered.y)
        end
    end
end

function Battlescape:shootAtTarget(shooter, target)
    -- Use existing ActionSystem
    local result = self.actionSystem:executeAttack(shooter, target, self.losSystem)
    
    if result.hit then
        print(string.format("[3D Combat] %s hit %s for %d damage", 
              shooter.name, target.name, result.damage))
        
        -- Show hit effect
        self.effects3D:playHitEffect(target.x, target.y)
        
        -- Show damage number (future enhancement)
        self:showDamageNumber(target, result.damage)
    else
        print(string.format("[3D Combat] %s missed %s", 
              shooter.name, target.name))
        
        -- Show miss effect
        self.effects3D:playMissEffect(target.x, target.y)
    end
    
    -- Deduct ammo and AP
    shooter.ammo = shooter.ammo - 1
    shooter.actionPointsLeft = shooter.actionPointsLeft - result.apCost
end
```

**Muzzle flash effect:**
```lua
function Effects3D:playMuzzleFlash(shooter, camera)
    -- Brief flash at shooter's weapon position
    local flash = {
        x = shooter.x,
        y = shooter.y,
        startTime = love.timer.getTime(),
        duration = 0.1  -- 100ms flash
    }
    
    table.insert(self.muzzleFlashes, flash)
end

function Effects3D:renderMuzzleFlashes(camera)
    local time = love.timer.getTime()
    
    for i = #self.muzzleFlashes, 1, -1 do
        local flash = self.muzzleFlashes[i]
        local age = time - flash.startTime
        
        if age < flash.duration then
            local alpha = 1.0 - (age / flash.duration)
            local sprite = Assets.get("effects", "muzzle_flash")
            
            self:drawBillboard(flash.x, 0.7, flash.y, sprite, camera, {
                alpha = alpha,
                emissive = true
            })
        else
            table.remove(self.muzzleFlashes, i)
        end
    end
end
```

**Estimated time:** 7 hours

---

### Step 6: Explosion Effects and Polish
**Description:** Add explosion animations (grenades, explosions), bullet tracers, hit sparks, and final polish

**Files to modify:**
- `engine/battlescape/rendering/effects_3d.lua` - Add explosion rendering

**Explosion effect:**
```lua
function Effects3D:playExplosion(x, y, radius)
    local explosion = {
        x = x,
        y = y,
        radius = radius,
        startTime = love.timer.getTime(),
        duration = 0.5,  -- 500ms explosion
        frameCount = 8   -- 8-frame animation
    }
    
    table.insert(self.explosions, explosion)
end

function Effects3D:renderExplosions(camera)
    local time = love.timer.getTime()
    
    for i = #self.explosions, 1, -1 do
        local exp = self.explosions[i]
        local age = time - exp.startTime
        
        if age < exp.duration then
            local frame = math.floor((age / exp.duration) * exp.frameCount) + 1
            local sprite = Assets.get("effects", "explosion" .. frame)
            
            -- Scale based on radius
            local scale = exp.radius / 2.0
            
            self:drawBillboard(exp.x, 0.5, exp.y, sprite, camera, {
                width = scale,
                height = scale,
                emissive = true
            })
        else
            table.remove(self.explosions, i)
        end
    end
end
```

**Bullet tracer:**
```lua
-- Draw line from shooter to target (very brief)
function Effects3D:playBulletTracer(shooter, target)
    local tracer = {
        startX = shooter.x,
        startY = shooter.y,
        endX = target.x,
        endY = target.y,
        startTime = love.timer.getTime(),
        duration = 0.05  -- 50ms tracer
    }
    
    table.insert(self.tracers, tracer)
end

function Effects3D:renderTracers(camera)
    -- Render as thin line in 3D space
    -- (Simplified: may need g3d line drawing support)
end
```

**Polish items:**
- [ ] Smooth camera transitions when switching units
- [ ] Footstep sounds when moving
- [ ] Ambient sounds (wind, fire crackling)
- [ ] UI cursor changes based on context
- [ ] Weapon reload animations (future)
- [ ] Death animations for units (future)

**Estimated time:** 6 hours

**Total estimated time:** 33 hours (4-5 days)

---

## Implementation Details

### Architecture

**Effect Rendering Pipeline:**
```
[Terrain Pass] Floor, walls, ceiling
    |
    v
[Object Pass] Trees, tables, fences (z-sorted)
    |
    v
[Unit Pass] Living units (z-sorted)
    |
    v
[Effects Pass] Fire, smoke, explosions (z-sorted, additive)
    |
    v
[UI Pass] Minimap, panels, cursor
```

**Z-Sorting:**
```lua
-- Sort all billboards by distance from camera (back to front)
function Renderer3D:sortBillboards(billboards, camera)
    table.sort(billboards, function(a, b)
        local distA = self:getDistance(a, camera)
        local distB = self:getDistance(b, camera)
        return distA > distB  -- Render furthest first
    end)
end
```

**LOS Integration:**
```lua
-- Use existing shadow-casting LOS system
function Renderer3D:prepareVisibleObjects(unit, battlefield, losSystem)
    local visibleTiles = losSystem:calculateVisibleTiles(unit, battlefield)
    
    -- Build render lists
    local renderList = {
        tiles = {},
        units = {},
        objects = {},
        effects = {}
    }
    
    for _, tile in ipairs(visibleTiles) do
        table.insert(renderList.tiles, tile)
        
        if tile.unit then
            table.insert(renderList.units, tile.unit)
        end
        
        if tile.object then
            table.insert(renderList.objects, tile.object)
        end
        
        -- Get effects on this tile
        local fire = self.fireSystem:getFireAt(tile.x, tile.y)
        if fire then
            table.insert(renderList.effects, {type="fire", data=fire})
        end
        
        local smoke = self.smokeSystem:getSmokeAt(tile.x, tile.y)
        if smoke then
            table.insert(renderList.effects, {type="smoke", data=smoke})
        end
    end
    
    return renderList
end
```

### Key Components

**Effects3D:**
- Fire rendering (animated billboards)
- Smoke rendering (transparent billboards)
- Explosion rendering (animated effects)
- Muzzle flash, tracers, hit sparks
- Z-sorting and blending

**ObjectRenderer3D:**
- Static object rendering (trees, tables)
- Billboard orientation
- Transparency handling
- Movement blocking but vision allowing

**Combat3D:**
- Shooting mechanics
- Target selection
- Hit/miss feedback
- Integration with ActionSystem
- Effect triggering

### Dependencies

**From Phase 1 & 2:**
- `Renderer3D` - Main 3D renderer
- `Billboard` - Billboard rendering
- `MousePicking3D` - Target selection

**Existing Systems:**
- `FireSystem` - Fire state management
- `SmokeSystem` - Smoke state management
- `LOS` - Line of sight calculation
- `ActionSystem` - Combat resolution
- `AnimationSystem` - Effect timing

### Data Flow

```
[Combat Action]
    |
    v
[ActionSystem] -> Calculate hit/miss
    |              Damage
    |              Effects
    v
[Combat3D] -> Trigger visual effects
    |         Play sounds
    |         Update UI
    v
[Effects3D] -> Render muzzle flash
               Render bullet tracer
               Render hit/explosion
               Render damage numbers
```

---

## Testing Strategy

### Unit Tests

**Test 1: Fire Animation Timing**
```lua
local effects = Effects3D.new()
local fire = {x = 10, y = 10}
local time1 = 0.0
local time2 = 0.1

local frame1 = effects:getFireFrame(fire, time1)
local frame2 = effects:getFireFrame(fire, time2)

-- Should cycle through frames at 10 FPS
assert(frame1 ~= frame2, "Fire should animate")
```

**Test 2: LOS Filtering**
```lua
local renderer = Renderer3D.new()
local unit = {x = 10, y = 10, team = "player", vision = 8}
local battlefield = createTestBattlefield()

local renderList = renderer:prepareVisibleObjects(unit, battlefield, losSystem)

-- All rendered objects must be within vision range
for _, obj in ipairs(renderList.units) do
    local dist = HexMath.distance(unit.x, unit.y, obj.x, obj.y)
    assert(dist <= unit.vision, "Object outside LOS should not render")
end
```

**Test 3: Z-Sorting**
```lua
local billboards = {
    {x = 5, y = 5},   -- Close
    {x = 10, y = 10}, -- Medium
    {x = 15, y = 15}  -- Far
}
local camera = {x = 0, y = 0}

renderer:sortBillboards(billboards, camera)

-- Should be sorted far to near
assert(billboards[1].x == 15, "Furthest should be first")
assert(billboards[3].x == 5, "Nearest should be last")
```

### Integration Tests

**Test 1: Fire/Smoke Rendering**
- Create fire on tile (10, 10)
- Create smoke on tile (12, 12)
- Switch to 3D mode
- Verify fire visible as animated sprite
- Verify smoke visible as semi-transparent cloud
- Verify both animate independently

**Test 2: Object Visibility**
- Place tree on tile (10, 10)
- Place wall on tile (10, 11)
- Position unit at (10, 8)
- Switch to 3D mode
- Verify can see through tree
- Verify cannot see through wall

**Test 3: Combat Flow**
- Position friendly unit at (10, 10)
- Position enemy unit at (10, 15)
- Switch to 3D mode
- Right-click on enemy
- Verify shot fired
- Verify muzzle flash shows
- Verify tracer shows (if visible)
- Verify hit/miss effect
- Verify AP deducted

### Manual Testing Steps

1. **Launch and enter 3D mode:**
   ```bash
   lovec "engine"
   ```
   - Start battlescape
   - Press SPACE for 3D mode

2. **Test fire effects:**
   - Create fire with debug command or find fire on map
   - Move near fire in 3D view
   - Verify animated flames
   - Verify fire glows (emissive)
   - Verify fire visible at night

3. **Test smoke effects:**
   - Create smoke (grenade, fire spread)
   - View in 3D mode
   - Verify semi-transparent
   - Verify animation (drifting)
   - Verify smoke rises over time

4. **Test objects:**
   - Find tile with tree, table, or fence
   - View from different angles
   - Verify object visible
   - Verify can see units behind object
   - Try to move through object - should be blocked

5. **Test visibility:**
   - Wait for night (or force night mode)
   - Switch to 3D mode
   - Verify reduced visibility range
   - Move to different positions
   - Verify FOW updates correctly
   - Verify only visible enemies shown

6. **Test combat:**
   - Find enemy in range
   - Right-click to shoot
   - Watch for muzzle flash
   - Watch for bullet tracer
   - See hit/miss effect
   - Check console for combat log
   - Verify AP and ammo deducted

7. **Test explosions:**
   - Throw grenade (if implemented)
   - Watch explosion animation
   - Verify area effect
   - Check damage to nearby units
   - Verify explosion visible from distance

### Expected Results

**Console Output:**
```
[3D Effects] Fire at (10,10) - frame 3/4
[3D Effects] Smoke at (12,12) - alpha 0.6
[3D Combat] Soldier 1 shoots at Enemy 1
[3D Combat] Roll: 75 vs 60 - HIT
[3D Combat] Damage: 15
[3D Effects] Playing hit effect at (10,15)
[3D Effects] Playing muzzle flash
```

**Visual Results:**
- Fire animates smoothly (4 frames, 10 FPS)
- Smoke drifts upward, fades over time
- Objects (trees, tables) render with transparency
- Units only visible within LOS
- Shooting shows muzzle flash, tracer, hit spark
- Explosions play full animation
- All effects properly z-sorted

**Performance:**
- 60 FPS with 10+ fires
- 60 FPS with 5+ smoke clouds
- 60 FPS with 20+ units visible
- Smooth animations throughout

---

## How to Run/Debug

### Running the Game
```bash
lovec "engine"
```

### Debugging Effects

**Enable effect logging:**
```lua
-- In Effects3D
local DEBUG_EFFECTS = true

function Effects3D:renderFire(fireSystem, camera)
    if DEBUG_EFFECTS then
        print(string.format("[3D Effects] Rendering %d fires", #fires))
    end
    -- ... rendering code
end
```

**On-screen effect stats:**
```lua
function Battlescape:draw()
    -- ... 3D rendering
    
    if DEBUG_EFFECTS then
        love.graphics.setColor(1, 1, 0)
        love.graphics.print(string.format("Fires: %d", #self.fireSystem.fires), 10, 90)
        love.graphics.print(string.format("Smoke: %d", #self.smokeSystem.smoke), 10, 110)
        love.graphics.print(string.format("Explosions: %d", #self.effects3D.explosions), 10, 130)
    end
end
```

### Debugging Combat

**Combat log:**
```lua
function Combat3D:shoot(shooter, target)
    print(string.format("[3D Combat] === SHOT START ==="))
    print(string.format("[3D Combat] Shooter: %s (%d AP, %d ammo)", 
          shooter.name, shooter.actionPointsLeft, shooter.ammo))
    print(string.format("[3D Combat] Target: %s (HP: %d/%d)", 
          target.name, target.health, target.maxHealth))
    
    local result = self.actionSystem:executeAttack(shooter, target)
    
    print(string.format("[3D Combat] Hit roll: %d vs %d - %s", 
          result.roll, result.threshold, result.hit and "HIT" or "MISS"))
    
    if result.hit then
        print(string.format("[3D Combat] Damage: %d", result.damage))
        print(string.format("[3D Combat] Target HP: %d/%d", 
              target.health, target.maxHealth))
    end
    
    print(string.format("[3D Combat] === SHOT END ==="))
end
```

### Debugging LOS

**Visualize LOS in 3D:**
```lua
-- Draw wireframe boxes around visible tiles
function Renderer3D:debugLOS(visibleTiles, camera)
    love.graphics.setColor(0, 1, 0, 0.3)
    
    for _, tile in ipairs(visibleTiles) do
        -- Draw box outline at tile position
        local screenX, screenY = self:worldToScreen(tile.x, tile.y, camera)
        love.graphics.rectangle("line", screenX, screenY, 24, 24)
    end
end
```

### Common Issues

1. **Fire/smoke not visible:**
   - Check effect sprite loading
   - Verify billboard rendering
   - Check z-sorting

2. **Objects block vision:**
   - Verify object.allowsVision flag
   - Check raycasting logic
   - Ensure objects != walls

3. **Combat not working:**
   - Verify ActionSystem integration
   - Check AP and ammo availability
   - Ensure target in LOS

4. **Performance drops:**
   - Profile effect rendering
   - Check z-sorting efficiency
   - Reduce max effect count

### Temporary Files
All temporary files MUST use: `os.getenv("TEMP")`

---

## Documentation Updates

### Files to Update

- [x] **`wiki/API.md`** - Add Phase 3 APIs:
  ```markdown
  ## 3D Effects System
  
  ### Effects3D.new()
  Create 3D effects renderer.
  
  ### effects3D:playFire(x, y)
  Play fire effect at position.
  
  ### effects3D:playSmoke(x, y)
  Play smoke effect at position.
  
  ### effects3D:playExplosion(x, y, radius)
  Play explosion effect.
  
  ## 3D Combat
  
  ### Combat3D.new(actionSystem)
  Create 3D combat handler.
  
  ### combat3D:shoot(shooter, target)
  Execute shooting action.
  ```

- [x] **`wiki/FAQ.md`** - Add effects FAQs:
  ```markdown
  ## Q: How do I shoot in 3D mode?
  A: Right-click on visible enemy unit.
  
  ## Q: Why can't I see that enemy?
  A: Check LOS and visibility range. Night reduces vision.
  
  ## Q: How do effects work in 3D mode?
  A: Same as 2D - fire spreads, smoke obscures, explosions damage area.
  ```

- [ ] **Code comments** - Full documentation

---

## Notes

- **Effect performance:** Multiple animated effects can impact performance. Consider effect pooling and LOD (level of detail).
- **Billboard ordering:** Proper z-sorting critical for correct visual layering.
- **LOS integration:** 3D renderer must respect same LOS rules as 2D mode for fairness.

---

## Blockers

- Requires completion of TASK-027 (Phase 2: Unit Interaction)

---

## Review Checklist

- [ ] Code follows best practices
- [ ] No global variables
- [ ] Error handling
- [ ] Performance optimized
- [ ] Temp files in TEMP folder
- [ ] Console debugging
- [ ] Tests passing
- [ ] Documentation updated
- [ ] Code reviewed
- [ ] No warnings
- [ ] Effects animate smoothly
- [ ] Z-sorting correct
- [ ] LOS enforced properly
- [ ] Combat integrated
- [ ] 60 FPS maintained

---

## Post-Completion

### What Worked Well
- (To be filled)

### What Could Be Improved
- (To be filled)

### Lessons Learned
- (To be filled)

---

## Final Integration Checklist

Upon completion of all 3 phases, verify:

- [ ] Can toggle between 2D and 3D seamlessly
- [ ] Both modes have identical tactical gameplay
- [ ] All UI elements work in both modes
- [ ] Performance is acceptable (60 FPS target)
- [ ] No data desync between modes
- [ ] All effects visible in 3D
- [ ] Combat works identically in both modes
- [ ] Turn-based rules enforced in 3D
- [ ] Hex grid movement correct (6 directions)
- [ ] Minimap works in 3D mode
- [ ] Can complete full mission in 3D mode
- [ ] All temporary files use TEMP directory
- [ ] Console shows no errors or warnings
- [ ] Full documentation completed
