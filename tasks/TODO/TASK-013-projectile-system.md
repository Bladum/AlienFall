# Task: Projectile System - Movement and Impact

**Status:** TODO  
**Priority:** High  
**Created:** October 13, 2025  
**Completed:** N/A  
**Assigned To:** AI Agent

---

## Overview

Implement a unified projectile system where all weapons (guns, lasers, grenades, thrown items) create projectiles that travel from point A to point B. Projectiles handle collision detection, impact determination, and triggering damage calculation.

---

## Purpose

Create a consistent framework for all ranged attacks. Whether shooting bullets, lasers, or throwing grenades, everything uses the same projectile entity system. This simplifies animation, hit detection, and enables features like missed shots hitting walls.

---

## Requirements

### Functional Requirements
- [ ] All ranged weapons create projectile entities
- [ ] Projectiles travel from shooter position to target position
- [ ] Projectiles can hit units or terrain
- [ ] Projectiles can miss and continue to walls/obstacles
- [ ] Projectile speed is configurable per weapon type
- [ ] Projectile visuals match weapon type (bullet, laser beam, grenade arc)
- [ ] Support for both point damage (single tile) and area damage (explosion radius)
- [ ] Projectiles trigger appropriate damage system on impact

### Technical Requirements
- [ ] Create ProjectileSystem module in `engine/battle/systems/`
- [ ] Projectile entity structure with position, velocity, damage properties
- [ ] Collision detection with units and terrain
- [ ] Animation system integration for visual feedback
- [ ] Support for trajectory calculation (straight line, arc for grenades)
- [ ] Impact callback system to trigger damage resolution

### Acceptance Criteria
- [ ] Firing weapon creates visible projectile
- [ ] Projectile travels at appropriate speed for weapon type
- [ ] Projectile correctly detects when it reaches target tile
- [ ] Projectile can detect early impact with obstacles
- [ ] Point damage projectiles trigger single-tile damage
- [ ] Area damage projectiles trigger explosion system
- [ ] System works with Love2D console debugging enabled (`lovec "engine"`)

---

## Plan

### Step 1: Create Projectile Entity Structure
**Description:** Define projectile data structure and basic properties  
**Files to modify/create:**
- `engine/battle/entities/projectile.lua` - Projectile entity class
- `engine/battle/init.lua` - Register projectile entity type

**Estimated time:** 2 hours

### Step 2: Implement ProjectileSystem Module
**Description:** Create system to manage projectile lifecycle  
**Files to modify/create:**
- `engine/battle/systems/projectile_system.lua` - Projectile management
- `engine/battle/battlefield.lua` - Integrate projectile tracking

**Estimated time:** 3 hours

### Step 3: Add Trajectory Calculation
**Description:** Implement different trajectory types (straight, arc, etc.)  
**Files to modify/create:**
- `engine/battle/utils/trajectory.lua` - Trajectory math utilities
- `engine/battle/systems/projectile_system.lua` - Use trajectory calculations

**Estimated time:** 2 hours

### Step 4: Implement Collision Detection
**Description:** Detect when projectile hits unit or terrain  
**Files to modify/create:**
- `engine/battle/systems/projectile_system.lua` - Add collision checks
- `engine/battle/battlefield.lua` - Provide collision query methods

**Estimated time:** 3 hours

### Step 5: Integrate with Weapon System
**Description:** Make weapons create projectiles when fired  
**Files to modify/create:**
- `engine/battle/systems/shooting_system.lua` - Create projectiles on shoot
- `engine/systems/weapon_system.lua` - Add projectile properties to weapons
- `engine/mods/new/rules/item/weapons.toml` - Add projectile definitions

**Estimated time:** 2 hours

### Step 6: Add Visual Rendering
**Description:** Draw projectiles during flight  
**Files to modify/create:**
- `engine/battle/renderer.lua` - Render projectile sprites/effects
- `engine/battle/systems/projectile_system.lua` - Provide render data

**Estimated time:** 2 hours

### Step 7: Testing
**Description:** Verify projectile system functionality  
**Test cases:**
- Create projectile from weapon fire
- Projectile travels to target
- Projectile hits unit correctly
- Projectile hits wall when missed
- Area damage creates explosion
- Visual rendering works correctly

**Estimated time:** 2 hours

---

## Implementation Details

### Architecture

**Projectile Entity Structure:**
```lua
{
    type = "projectile",
    x = 10,           -- Current grid X position
    y = 15,           -- Current grid Y position
    animX = 10.5,     -- Interpolated X for smooth animation
    animY = 15.3,     -- Interpolated Y for smooth animation
    startX = 8,       -- Starting position
    startY = 12,
    targetX = 15,     -- Target position
    targetY = 20,
    velocity = 500,   -- Pixels per second
    travelled = 0,    -- Distance travelled
    maxDistance = 0,  -- Total distance to travel
    active = true,    -- Is projectile in flight
    
    -- Damage properties
    damageType = "point" | "area",
    power = 10,       -- Base damage
    dropoff = 2,      -- For area damage
    damageClass = "kinetic", -- Damage type for resistance
    stunRatio = 0.25, -- 25% stun, 75% health
    healthRatio = 0.75,
    
    -- Visual
    sprite = nil,     -- Projectile sprite/effect
    trailEffect = nil -- Visual trail
}
```

**ProjectileSystem Methods:**
- `createProjectile(weapon, shooter, target)` - Create projectile from weapon fire
- `updateProjectiles(dt)` - Update all active projectiles
- `checkCollision(projectile)` - Check if projectile hit something
- `onImpact(projectile, x, y)` - Handle projectile impact
- `renderProjectiles()` - Render all active projectiles

### Key Components

- **Projectile Entity:** Data structure for in-flight projectile
- **ProjectileSystem:** Manages active projectiles, updates positions, checks collisions
- **Trajectory Module:** Calculates path for different projectile types
- **Collision Detection:** Determines when projectile reaches target or hits obstacle
- **Impact Handler:** Triggers appropriate damage system (point or area)

### Dependencies
- `battle.battlefield` - Query units and terrain
- `battle.systems.damage_system` - Trigger damage on impact (to be implemented)
- `battle.animation_system` - Visual effects for projectile flight
- `systems.weapon_system` - Weapon projectile properties
- `battle.utils.hex_math` - Distance and direction calculations

---

## Testing Strategy

### Unit Tests
Create `engine/battle/tests/test_projectile_system.lua`:
- **Test 1:** Create projectile with valid parameters
- **Test 2:** Projectile position updates over time
- **Test 3:** Collision detection with unit at target tile
- **Test 4:** Collision detection with wall obstacle
- **Test 5:** Projectile reaches target position correctly
- **Test 6:** Area damage projectile properties set correctly

### Integration Tests
- **Test 1:** Fire weapon → projectile created → travels → hits target
- **Test 2:** Missed shot → projectile continues past target → hits wall
- **Test 3:** Grenade thrown → arcs to target → triggers explosion
- **Test 4:** Multiple projectiles in flight simultaneously

### Manual Testing Steps
1. Run game with `lovec "engine"` (console enabled)
2. Enter battlescape with test units
3. Fire weapon at target
4. Observe projectile travel animation
5. Verify impact triggers damage
6. Fire at wall, verify projectile stops
7. Throw grenade, verify arc trajectory
8. Check console for debug messages

### Expected Results
- Console shows: `[ProjectileSystem] Created projectile: type=point, power=10`
- Console shows: `[ProjectileSystem] Projectile impact at (15, 20)`
- Projectile sprite visible moving across screen
- Projectile reaches target in ~0.5-1 second
- Impact triggers damage system call
- No crashes or errors in Love2D console

---

## How to Run/Debug

### Running the Game
```bash
lovec "engine"
```

### Debug Commands
Add to projectile_system.lua:
```lua
print(string.format("[ProjectileSystem] Created projectile at (%d,%d) -> (%d,%d)", 
    startX, startY, targetX, targetY))
print(string.format("[ProjectileSystem] Update: pos=(%.2f,%.2f), travelled=%.1f/%.1f", 
    projectile.animX, projectile.animY, projectile.travelled, projectile.maxDistance))
print(string.format("[ProjectileSystem] Impact at (%d,%d), type=%s", 
    x, y, projectile.damageType))
```

### Debugging Checklist
- [ ] Projectile creation messages appear in console
- [ ] Position updates show smooth progression
- [ ] Collision detection messages show correct tile
- [ ] Impact messages show damage type and location
- [ ] No errors about nil projectile properties

---

## Documentation Updates

### Files to Update
- `wiki/API.md` - Add ProjectileSystem API documentation
- `wiki/DEVELOPMENT.md` - Add projectile system workflow
- `engine/battle/systems/projectile_system.lua` - Full LuaDoc comments
- `engine/battle/entities/projectile.lua` - Document entity structure

### Documentation Content
- ProjectileSystem.createProjectile() parameters and return values
- Projectile entity field descriptions
- How to add new projectile types
- Trajectory calculation options
- Collision detection behavior
- Integration with damage system

---

## Notes

**Design Decisions:**
- All ranged attacks use projectiles for consistency
- Projectiles are entities managed by ProjectileSystem, not battlefield units
- Position tracked both as grid coords (x,y) and interpolated (animX,animY) for smooth animation
- Damage properties stored in projectile, applied on impact
- Area damage handled by explosion system (separate task)

**Future Enhancements:**
- Projectile deflection/ricochet
- Multi-stage projectiles (rocket that explodes mid-flight)
- Homing projectiles
- Projectile penetration through multiple targets

---

## Blockers

**Dependencies:**
- None - can implement independently

**External Blockers:**
- None

---

## Review Checklist

Before marking complete:
- [ ] All acceptance criteria met
- [ ] Unit tests written and passing
- [ ] Integration tests successful
- [ ] Manual testing completed with Love2D console
- [ ] No console errors or warnings
- [ ] Code follows Lua best practices
- [ ] LuaDoc comments complete
- [ ] API documentation updated
- [ ] Grid snapping used where applicable (24x24 grid)
- [ ] Task moved to DONE folder
- [ ] tasks.md updated with completion date

---

## Post-Completion

### What Worked Well
[To be filled after completion]

### Challenges Encountered
[To be filled after completion]

### Lessons Learned
[To be filled after completion]

### Follow-up Tasks
- TASK-014: Damage Resolution System
- TASK-015: Explosion Area Damage System
- TASK-016: Projectile Animation and Effects
