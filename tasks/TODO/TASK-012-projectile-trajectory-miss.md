# Task: Projectile Trajectory and Miss System

**Status:** TODO  
**Priority:** High  
**Created:** October 13, 2025  
**Completed:** N/A  
**Assigned To:** AI Agent

---

## Overview

Implement projectile trajectory system with hit/miss resolution. On hit, projectile travels directly to target center, passing through terrain with cover-based stop chance. On miss, projectile deviates by up to 30° based on accuracy, landing on nearby hex tile. Handles terrain collision and realistic bullet physics.

---

## Purpose

Create satisfying and realistic shooting resolution. Bullets physically travel through the battlefield, can be stopped by cover, and miss in believable ways based on accuracy. Provides visual feedback and tactical depth (stray bullets hitting other targets).

---

## Requirements

### Functional Requirements
- [ ] Roll to-hit using calculated accuracy percentage
- [ ] On HIT (roll ≤ accuracy):
  - Projectile travels directly to target center
  - Each terrain/object on path has chance to stop bullet based on cover
  - Max deviation from hit point: 30°
  - Shooting through windows is possible (low cover = low stop chance)
- [ ] On MISS (roll > accuracy):
  - Deviation angle = 30° × (1 - accuracy / 100)
  - Higher accuracy = smaller miss deviation
  - Roll random direction (one of 6 hex directions)
  - Roll random distance (1 to max based on deviation + range)
  - Max miss radius = distance × tan(deviation_angle) × random(0.5-1.5)
  - Projectile lands on adjacent hex (not target hex)
- [ ] Projectile can hit unintended targets on path
- [ ] Projectile collision with terrain stops flight
- [ ] Visual projectile animation

### Technical Requirements
- [ ] Random number generation for hit/miss roll
- [ ] Trajectory calculation (straight line)
- [ ] Cover-based collision probability
- [ ] Deviation angle calculation
- [ ] Hex direction selection (6 directions)
- [ ] Miss landing position calculation
- [ ] Collision detection along projectile path
- [ ] Unintended target hit detection
- [ ] Projectile animation system

### Acceptance Criteria
- [ ] To-hit roll matches displayed accuracy
- [ ] Hit projectiles travel to target center
- [ ] Terrain can stop projectiles based on cover value
- [ ] Miss projectiles deviate believably
- [ ] High accuracy misses land close to target
- [ ] Low accuracy misses land far from target
- [ ] Misses never land on target hex
- [ ] Projectiles can hit unintended targets
- [ ] Visual feedback shows projectile path
- [ ] Console logs hit/miss and trajectory

---

## Plan

### Step 1: To-Hit Roll System
**Description:** Implement random roll against accuracy  
**Files to modify/create:**
- `engine/battle/systems/to_hit_system.lua` - Hit/miss determination
- `engine/utils/random.lua` - RNG utilities

**Estimated time:** 2 hours

### Step 2: Hit Trajectory and Collision
**Description:** Implement direct hit trajectory with terrain collision  
**Files to modify/create:**
- `engine/battle/systems/projectile_system.lua` - Projectile physics
- `engine/battle/systems/collision_system.lua` - Terrain collision

**Estimated time:** 4 hours

### Step 3: Miss Deviation System
**Description:** Calculate miss landing position  
**Files to modify/create:**
- `engine/battle/systems/miss_system.lua` - Miss deviation calculation
- `engine/battle/utils/hex_geometry.lua` - Hex direction math

**Estimated time:** 3 hours

### Step 4: Unintended Target Detection
**Description:** Detect if projectile hits other units  
**Files to modify/create:**
- `engine/battle/systems/projectile_system.lua` - Target detection along path
- `engine/battle/systems/collision_system.lua` - Unit collision

**Estimated time:** 2 hours

### Step 5: Projectile Animation
**Description:** Visual projectile movement  
**Files to modify/create:**
- `engine/battle/animation_system.lua` - Projectile animation
- `engine/battle/renderer.lua` - Draw projectiles

**Estimated time:** 3 hours

### Step 6: Testing
**Description:** Verify trajectory and collision systems  
**Test cases:**
- To-hit roll matches probability
- Hits travel correct path
- Cover stops projectiles correctly
- Misses land in correct area
- Unintended targets can be hit
- Visual feedback works

**Estimated time:** 3 hours

---

## Implementation Details

### Architecture
Create projectile entities with physics. ToHitSystem determines hit/miss. ProjectileSystem moves projectile frame-by-frame. CollisionSystem checks terrain and units. MissSystem calculates deviation for misses.

### Key Components

**ToHitSystem:**
```lua
--- Roll to hit against accuracy
-- @param accuracy number Accuracy percentage (5-95)
-- @return boolean True if hit, false if miss
function ToHitSystem.rollToHit(accuracy)
    local roll = math.random(1, 100)
    local hit = roll <= accuracy
    
    print("[ToHitSystem] Accuracy: " .. accuracy .. "%, Roll: " .. roll .. ", Result: " .. (hit and "HIT" or "MISS"))
    
    return hit
end
```

**ProjectileSystem - Hit Trajectory:**
```lua
--- Create projectile for successful hit
-- @param shooter table Source position
-- @param target table Target position
-- @param weapon table Weapon data
-- @return table Projectile entity
function ProjectileSystem.createHitProjectile(shooter, target, weapon)
    return {
        type = "projectile",
        start_pos = {x = shooter.x, y = shooter.y},
        end_pos = {x = target.x, y = target.y},
        current_pos = {x = shooter.x, y = shooter.y},
        velocity = 500, -- pixels per second
        damage = weapon.damage,
        penetration = weapon.penetration or 0,
        active = true,
        is_hit = true,
        target_entity = target
    }
end

--- Update projectile position
-- @param projectile table Projectile entity
-- @param dt number Delta time
-- @return boolean True if reached destination
function ProjectileSystem.updateProjectile(projectile, dt)
    -- Calculate direction vector
    local dx = projectile.end_pos.x - projectile.current_pos.x
    local dy = projectile.end_pos.y - projectile.current_pos.y
    local distance = math.sqrt(dx * dx + dy * dy)
    
    if distance < 1 then
        projectile.active = false
        return true
    end
    
    -- Move projectile
    local speed = projectile.velocity * dt
    local ratio = speed / distance
    projectile.current_pos.x = projectile.current_pos.x + dx * ratio
    projectile.current_pos.y = projectile.current_pos.y + dy * ratio
    
    return false
end
```

**CollisionSystem - Terrain Collision:**
```lua
--- Check if projectile is stopped by terrain
-- @param projectile table Projectile entity
-- @param battlefield table Battlefield
-- @return boolean True if stopped
function CollisionSystem.checkTerrainCollision(projectile, battlefield)
    local tile = battlefield:getTileAt(projectile.current_pos)
    if not tile then return false end
    
    local cover = tile.cover or 0
    
    -- Each point of cover = 5% chance to stop
    local stopChance = cover * 0.05
    
    if math.random() < stopChance then
        print("[CollisionSystem] Projectile stopped by terrain (cover: " .. cover .. ")")
        projectile.active = false
        return true
    end
    
    return false
end

--- Check if projectile hits a unit
-- @param projectile table Projectile entity
-- @param units table Array of unit entities
-- @return table|nil Unit hit, or nil
function CollisionSystem.checkUnitCollision(projectile, units)
    for _, unit in ipairs(units) do
        local dx = unit.x - projectile.current_pos.x
        local dy = unit.y - projectile.current_pos.y
        local distance = math.sqrt(dx * dx + dy * dy)
        
        -- Hit radius = half a tile
        if distance < 12 then
            print("[CollisionSystem] Projectile hit unit at (" .. unit.x .. ", " .. unit.y .. ")")
            return unit
        end
    end
    
    return nil
end
```

**MissSystem:**
```lua
--- Calculate miss deviation angle
-- @param accuracy number Accuracy that was rolled against (0-100)
-- @return number Deviation angle in degrees (0-30)
function MissSystem.calculateDeviationAngle(accuracy)
    local deviation = 30 * (1 - accuracy / 100)
    return deviation
end

--- Calculate miss landing position
-- @param shooterPos table Shooter hex position
-- @param targetPos table Target hex position
-- @param accuracy number Accuracy rolled against
-- @param battlefield table Battlefield for hex conversion
-- @return table Landing hex position
function MissSystem.calculateMissPosition(shooterPos, targetPos, accuracy, battlefield)
    -- Calculate deviation angle
    local deviationAngle = MissSystem.calculateDeviationAngle(accuracy)
    
    -- Calculate distance to target
    local distance = HexMath.distance(shooterPos, targetPos)
    
    -- Calculate max miss radius (trigonometry)
    -- radius = distance × tan(deviation_angle)
    local deviationRad = math.rad(deviationAngle)
    local maxRadius = distance * math.tan(deviationRad)
    
    -- Apply random multiplier (0.5 to 1.5)
    local radiusMultiplier = 0.5 + math.random() * 1.0
    local missRadius = maxRadius * radiusMultiplier
    
    -- Choose random hex direction (0-5 for 6 hex directions)
    local direction = math.random(0, 5)
    local angle = direction * 60 -- Hex directions are 60° apart
    
    -- Calculate landing position in pixel space first
    local targetPixel = battlefield:hexToPixel(targetPos)
    local angleRad = math.rad(angle)
    local missX = targetPixel.x + missRadius * math.cos(angleRad)
    local missY = targetPixel.y + missRadius * math.sin(angleRad)
    
    -- Convert back to hex coordinates
    local missHex = battlefield:pixelToHex({x = missX, y = missY})
    
    -- Ensure not on target hex
    if HexMath.equal(missHex, targetPos) then
        -- Move to adjacent hex in chosen direction
        missHex = HexMath.neighbor(targetPos, direction)
    end
    
    print("[MissSystem] Deviation: " .. string.format("%.1f", deviationAngle) .. "°")
    print("[MissSystem] Max radius: " .. string.format("%.1f", maxRadius) .. " tiles")
    print("[MissSystem] Miss landed " .. HexMath.distance(missHex, targetPos) .. " tiles from target")
    
    return missHex
end
```

### Mathematical Formulas

**Deviation Angle:**
```
deviation = 30° × (1 - accuracy / 100)

Examples:
accuracy = 90% → deviation = 30° × 0.1 = 3°
accuracy = 50% → deviation = 30° × 0.5 = 15°
accuracy = 10% → deviation = 30° × 0.9 = 27°
```

**Miss Radius:**
```
max_radius = distance × tan(deviation_angle)
actual_radius = max_radius × random(0.5, 1.5)

Example (distance = 10 tiles, accuracy = 50%):
deviation = 15°
max_radius = 10 × tan(15°) = 10 × 0.268 = 2.68 tiles
actual_radius = 2.68 × random(0.5, 1.5) = 1.34 to 4.02 tiles
```

**Hex Directions (60° apart):**
```
Direction 0: 0° (East)
Direction 1: 60° (Northeast)
Direction 2: 120° (Northwest)
Direction 3: 180° (West)
Direction 4: 240° (Southwest)
Direction 5: 300° (Southeast)
```

### Example Scenarios

**Scenario 1: High Accuracy Hit**
- Accuracy: 85%
- Roll: 42
- Result: HIT
- Projectile: Travels directly to target
- Path: Through 1 fence (cover 5)
- Stop chance: 5 × 5% = 25%
- Outcome: 75% chance to hit target

**Scenario 2: Low Accuracy Miss**
- Accuracy: 25%
- Roll: 78
- Result: MISS
- Deviation: 30° × 0.75 = 22.5°
- Distance: 8 tiles
- Max radius: 8 × tan(22.5°) = 3.3 tiles
- Actual radius: 3.3 × 1.2 = 4.0 tiles
- Direction: 2 (120°, Northwest)
- Lands: 4 tiles northwest of target

**Scenario 3: Medium Accuracy Miss**
- Accuracy: 60%
- Roll: 75
- Result: MISS
- Deviation: 30° × 0.4 = 12°
- Distance: 12 tiles
- Max radius: 12 × tan(12°) = 2.5 tiles
- Actual radius: 2.5 × 0.8 = 2.0 tiles
- Direction: 5 (300°, Southeast)
- Lands: 2 tiles southeast of target

### Dependencies
- TASK-011: Final Accuracy and Fire Modes System
- `engine/battle/systems/accuracy_system.lua`
- `engine/battle/animation_system.lua`
- `engine/utils/random.lua`
- `engine/battle/utils/hex_math.lua`

---

## Testing Strategy

### Unit Tests
- Test 1: `test_to_hit_roll.lua` - Verify probability matches roll
- Test 2: `test_hit_trajectory.lua` - Test direct hit path
- Test 3: `test_terrain_collision.lua` - Test cover stops bullets
- Test 4: `test_miss_deviation.lua` - Test deviation calculation
- Test 5: `test_miss_position.lua` - Test landing position calculation
- Test 6: `test_unintended_hits.lua` - Test stray bullets hitting others

### Integration Tests
- Test 1: `test_complete_shooting.lua` - Full shooting sequence
- Test 2: `test_projectile_animation.lua` - Visual projectile system

### Manual Testing Steps
1. Run game with `lovec "engine"`
2. Enter battlescape with units and terrain
3. Test hits:
   - High accuracy shot that hits
   - Verify projectile travels to target
   - Place terrain between shooter and target
   - Verify terrain can stop projectile
   - Calculate stop probability matches
4. Test misses:
   - Low accuracy shot that misses
   - Verify miss lands near target
   - High accuracy miss lands very close
   - Low accuracy miss lands far away
   - Verify misses don't land on target hex
5. Test unintended hits:
   - Place unit between shooter and target
   - Verify stray bullets can hit unit
6. Verify visual feedback:
   - Projectile animation smooth
   - Hit/miss clearly shown
   - Console logs detailed information
7. Test edge cases:
   - Point blank range
   - Maximum range
   - Multiple cover obstacles
   - Shooting through windows

### Expected Results
- To-hit rolls match probability
- Hits travel correct path
- Cover stops projectiles appropriately
- Misses land in realistic positions
- High accuracy = close misses
- Low accuracy = wide misses
- Unintended hits can occur
- Smooth projectile animation
- Clear visual feedback
- Detailed console logs
- No errors or warnings

---

## How to Run/Debug

### Running the Game
```bash
lovec "engine"
```
or use the VS Code task: "Run XCOM Simple Game"

### Debugging
- Love2D console is enabled in `conf.lua` (t.console = true)
- Add comprehensive debug prints:
```lua
print("[Shooting] === Shot Resolution ===")
print("[ToHitSystem] Accuracy: " .. accuracy .. "%")
print("[ToHitSystem] Roll: " .. roll)
print("[ToHitSystem] Result: " .. (hit and "HIT" or "MISS"))

if hit then
    print("[ProjectileSystem] Direct hit trajectory")
    print("[ProjectileSystem] Target: " .. target.x .. ", " .. target.y)
else
    print("[MissSystem] Deviation angle: " .. deviation .. "°")
    print("[MissSystem] Max miss radius: " .. maxRadius .. " tiles")
    print("[MissSystem] Landing position: " .. missHex.q .. ", " .. missHex.r)
end

print("[CollisionSystem] Cover check: " .. cover .. " (stop chance: " .. (cover*5) .. "%)")
```
- Draw debug visualization:
```lua
-- Draw projectile path
love.graphics.setColor(1, 1, 0)
love.graphics.line(startX, startY, endX, endY)

-- Draw miss area cone
love.graphics.setColor(1, 0, 0, 0.3)
-- Draw cone based on deviation angle

-- Draw collision points
love.graphics.setColor(1, 0, 0)
love.graphics.circle("fill", collisionX, collisionY, 5)
```

### Debug Visualization
```lua
-- Show trajectory
if debug_mode then
    love.graphics.setColor(0, 1, 0)
    love.graphics.line(
        projectile.start_pos.x, projectile.start_pos.y,
        projectile.current_pos.x, projectile.current_pos.y
    )
    
    -- Show miss cone for misses
    if not projectile.is_hit then
        love.graphics.setColor(1, 0, 0, 0.2)
        -- Draw cone showing possible landing area
    end
end
```

### Temporary Files
- All temporary files MUST be created in: `os.getenv("TEMP")`
- Never create temp files in project directories

---

## Documentation Updates

### Files to Update
- [ ] `wiki/API.md` - Add ToHitSystem, ProjectileSystem, MissSystem APIs
- [ ] `wiki/FAQ.md` - Add section on shooting mechanics
- [ ] `wiki/ECS_BATTLE_SYSTEM_API.md` - Document projectile components
- [ ] Create `wiki/SHOOTING_MECHANICS.md` - Complete shooting guide
- [ ] `engine/battle/systems/projectile_system.lua` - Full docstrings
- [ ] `engine/battle/systems/miss_system.lua` - Full docstrings

---

## Notes

- Projectile system provides satisfying visual feedback
- Cover-based collision creates tactical depth
- Miss system creates realistic bullet spread
- Unintended hits add risk/reward to tight formations
- High accuracy valuable for consistent hits
- Future: Penetration system for multiple targets
- Future: Explosive projectiles with area effects
- Future: Tracer rounds and visual effects
- Future: Ricochet mechanics

**Design Philosophy:**
- Shooting should feel impactful and physical
- Misses should be close to target if accuracy is high
- Stray bullets create tactical considerations
- Visual feedback is critical for player understanding

---

## Blockers

**Depends on:**
- TASK-011: Final Accuracy and Fire Modes System
- TASK-010: Cover and LOS System

**Requires:**
- `engine/battle/animation_system.lua` - Animation framework
- `engine/battle/utils/hex_math.lua` - Hex geometry

---

## Review Checklist

- [ ] Code follows Lua/Love2D best practices
- [ ] No global variables (all use `local`)
- [ ] Proper error handling with `pcall` where needed
- [ ] Performance optimized (efficient collision checks)
- [ ] All temporary files use TEMP folder
- [ ] Console debugging statements added
- [ ] Tests written and passing
- [ ] Documentation updated
- [ ] Code reviewed
- [ ] No warnings in Love2D console
- [ ] Mathematical formulas verified
- [ ] Trigonometry correct (angles in radians vs degrees)
- [ ] Edge cases handled (zero distance, same position)
- [ ] Visual feedback clear and satisfying

---

## Post-Completion

### What Worked Well
- (To be filled after completion)

### What Could Be Improved
- (To be filled after completion)

### Lessons Learned
- (To be filled after completion)
