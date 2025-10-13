# Task: Explosion Area Damage System

**Status:** TODO  
**Priority:** High  
**Created:** October 13, 2025  
**Completed:** N/A  
**Assigned To:** AI Agent

---

## Overview

Implement area damage system for explosions. Grenade lands on tile, creates explosion at epicenter with initial power, then propagates outward to adjacent hexes with decreasing power. Each hex propagates to up to 3 neighbors (except epicenter which hits all 6). Terrain and units reduce propagation power. System handles chain explosions, creates fire/smoke, and animates expansion with per-ring delays.

---

## Purpose

Grenades, rockets, and explosive barrels need area-of-effect damage. The system must:
1. Damage epicenter tile at full power
2. Propagate damage to adjacent tiles with power dropoff
3. Obstacles (walls, units) absorb damage and reduce propagation
4. Handle overlapping waves (highest power wins)
5. Create secondary explosions from explosive terrain
6. Generate smoke and fire effects
7. Animate explosion visually ring-by-ring

---

## Requirements

### Functional Requirements
- [ ] Explosion starts at impact point (epicenter) with full power
- [ ] Damage propagates to 6 adjacent hexes from epicenter
- [ ] Power reduces by dropoff value per ring (e.g., power=10, drop=2: rings are 10,8,6,4,2)
- [ ] Each non-epicenter tile propagates to max 3 neighbors
- [ ] Units reduce propagation power by their armor value
- [ ] Walls/terrain reduce propagation power by their armor value
- [ ] If multiple damage waves reach same tile, use highest power
- [ ] Explosions destroy fragile floor terrain
- [ ] Explosive terrain triggers chain reactions (process after initial explosion)
- [ ] Create smoke on tiles based on terrain smokeable property
- [ ] Create fire on tiles based on terrain flammable property
- [ ] Animate explosion ring-by-ring with 50-60ms delays

### Technical Requirements
- [ ] Create ExplosionSystem module in `engine/battle/systems/`
- [ ] Flood-fill algorithm for damage propagation
- [ ] Track visited tiles and power values
- [ ] Integrate with DamageSystem for unit damage
- [ ] Integrate with FireSystem for fire creation
- [ ] Integrate with SmokeSystem for smoke creation
- [ ] Queue chain explosions for sequential processing
- [ ] Animation system for visual explosion rings

### Acceptance Criteria
- [ ] Grenade explosion damages all tiles within range
- [ ] Example: power=10, drop=2
  - Ring 0 (epicenter): power=10
  - Ring 1 (adjacent): power=8
  - Ring 2: power=6
  - Ring 3: power=4
  - Ring 4: power=2
  - Stops at ring 5 (power=0)
- [ ] Unit with armor=5 stops propagation completely (absorbs damage)
- [ ] Wall with armor=3 reduces propagation by 3 (8-3=5 continues)
- [ ] Multiple waves merge correctly (highest power used)
- [ ] Chain explosions trigger after main explosion completes
- [ ] Smoke/fire created on appropriate terrain
- [ ] Visual animation shows expanding rings
- [ ] System works with Love2D console enabled (`lovec "engine"`)

---

## Plan

### Step 1: Create Explosion Data Structure
**Description:** Define explosion properties and ring tracking  
**Files to modify/create:**
- `engine/battle/systems/explosion_system.lua` - Core explosion module
- `engine/mods/new/rules/item/weapons.toml` - Add explosion properties

**Estimated time:** 2 hours

### Step 2: Implement Damage Propagation Algorithm
**Description:** Flood-fill algorithm for expanding damage rings  
**Files to modify/create:**
- `engine/battle/systems/explosion_system.lua` - Propagation logic
- `engine/battle/utils/hex_math.lua` - Hex neighbor utilities

**Estimated time:** 4 hours

### Step 3: Integrate Obstacle Absorption
**Description:** Units and terrain reduce propagation power  
**Files to modify/create:**
- `engine/battle/systems/explosion_system.lua` - Add absorption logic
- `engine/battle/battlefield.lua` - Query terrain armor values

**Estimated time:** 3 hours

### Step 4: Apply Damage to Units
**Description:** Use DamageSystem to damage units in explosion  
**Files to modify/create:**
- `engine/battle/systems/explosion_system.lua` - Call DamageSystem
- `engine/battle/systems/damage_system.lua` - Support area damage calls

**Estimated time:** 2 hours

### Step 5: Implement Chain Explosions
**Description:** Queue secondary explosions from explosive terrain  
**Files to modify/create:**
- `engine/battle/systems/explosion_system.lua` - Chain explosion queue
- `engine/data/terrain.lua` - Add explosive property to terrain

**Estimated time:** 2 hours

### Step 6: Integrate Fire and Smoke Creation
**Description:** Create environmental effects in explosion area  
**Files to modify/create:**
- `engine/battle/systems/explosion_system.lua` - Call fire/smoke systems
- `engine/battle/fire_system.lua` - Public API for starting fires
- `engine/battle/smoke_system.lua` - Public API for creating smoke

**Estimated time:** 2 hours

### Step 7: Add Visual Animation
**Description:** Animate explosion rings with delays  
**Files to modify/create:**
- `engine/battle/systems/explosion_system.lua` - Ring animation timing
- `engine/battle/animation_system.lua` - Explosion animation effects
- `engine/battle/renderer.lua` - Render explosion sprites

**Estimated time:** 3 hours

### Step 8: Testing
**Description:** Verify explosion mechanics and propagation  
**Test cases:**
- Simple explosion in open area
- Explosion blocked by walls
- Explosion absorbed by unit armor
- Multiple overlapping explosions
- Chain explosion triggers
- Fire and smoke creation
- Visual animation timing

**Estimated time:** 3 hours

---

## Implementation Details

### Architecture

**Explosion Propagation Algorithm (Flood-Fill):**
```
1. Start at epicenter (x, y) with full power
2. Create empty visited map and power map
3. Create ring 0 = [epicenter]
4. For each ring:
   a. For each tile in ring:
      - Apply damage to units/terrain at this tile
      - Calculate neighbors to propagate to
        (epicenter → 6 neighbors, others → 3 neighbors)
      - For each neighbor:
        * Calculate remaining power after absorption
        * If power > 0 and (not visited OR new power > existing):
          - Add to next ring
          - Update power map
   b. Animate this ring (50-60ms delay)
   c. Process next ring
5. Check for chain explosions
6. Create smoke/fire effects
```

**Explosion Properties (in weapons.toml):**
```toml
[weapons.grenade]
id = "grenade"
name = "Fragmentation Grenade"
type = "grenade"
damage = 10
damageType = "explosive"
explosionPower = 10  # Power at epicenter
explosionDrop = 2    # Power reduction per ring
healthRatio = 1.0    # 100% health damage
stunRatio = 0.0      # 0% stun
criticalChance = 0.0 # No crits from explosions
```

**Explosion Processing Structure:**
```lua
{
    epicenter = {x = 10, y = 15},
    power = 10,
    dropoff = 2,
    damageType = "explosive",
    healthRatio = 1.0,
    stunRatio = 0.0,
    
    -- Propagation tracking
    powerMap = {}, -- [y][x] = power value
    visited = {},  -- [y][x] = true
    rings = {},    -- Array of rings for animation
    
    -- Visual
    animationTime = 0,
    currentRing = 0,
    ringDelay = 0.055 -- 55ms between rings
}
```

**Neighbor Calculation:**
```lua
-- Epicenter: propagate to all 6 neighbors
if isEpicenter then
    neighbors = HexMath.getAdjacentHexes(x, y)
else
    -- Non-epicenter: propagate to 3 neighbors
    -- (away from source direction)
    neighbors = HexMath.getForwardNeighbors(x, y, sourceDirection)
end
```

**Power Absorption:**
```lua
function calculatePropagation(currentPower, tile)
    local remainingPower = currentPower - dropoff
    
    -- Check terrain armor
    if tile.terrain and tile.terrain.armor then
        remainingPower = remainingPower - tile.terrain.armor
        if remainingPower < 0 then
            -- Terrain absorbs all damage, no propagation
            return 0
        end
    end
    
    -- Check units
    local unit = battlefield:getUnitAt(tile.x, tile.y)
    if unit then
        local unitArmor = unit.stats.armour or 0
        remainingPower = remainingPower - unitArmor
        if remainingPower < 0 then
            -- Unit absorbs all damage, no propagation
            return 0
        end
    end
    
    return math.max(0, remainingPower)
end
```

**Overlapping Waves:**
```lua
-- If tile already has power value, use higher one
if powerMap[y] and powerMap[y][x] then
    powerMap[y][x] = math.max(powerMap[y][x], newPower)
else
    if not powerMap[y] then powerMap[y] = {} end
    powerMap[y][x] = newPower
end
```

### Key Components

- **ExplosionSystem:** Main explosion manager
  - `createExplosion(x, y, power, dropoff, damageType)` - Start explosion
  - `propagateExplosion(explosion)` - Flood-fill propagation
  - `applyExplosionDamage(explosion)` - Damage all affected tiles
  - `checkChainExplosions(explosion)` - Find explosive terrain
  - `animateExplosion(explosion, dt)` - Visual ring animation
  - `createEnvironmentalEffects(explosion)` - Fire/smoke

- **Ring Processing:**
  - Track tiles grouped by distance from epicenter
  - Process ring-by-ring for animation
  - Each ring has 50-60ms delay for visual effect

- **Chain Explosion Queue:**
  - After explosion completes, check for explosive terrain
  - Queue new explosions at those locations
  - Process sequentially (don't overlap)

### Dependencies
- `battle.systems.damage_system` - Apply damage to units
- `battle.fire_system` - Create fires
- `battle.smoke_system` - Create smoke
- `battle.animation_system` - Visual effects
- `battle.utils.hex_math` - Hex grid utilities
- `battle.battlefield` - Query terrain and units
- `systems.weapon_system` - Explosion properties

---

## Testing Strategy

### Unit Tests
Create `engine/battle/tests/test_explosion_system.lua`:
- **Test 1:** Explosion power at each ring (10, 8, 6, 4, 2, 0)
- **Test 2:** Terrain absorption reduces propagation
- **Test 3:** Unit armor reduces propagation
- **Test 4:** Epicenter propagates to 6 neighbors
- **Test 5:** Non-epicenter propagates to 3 neighbors
- **Test 6:** Overlapping waves use highest power
- **Test 7:** Chain explosion queues correctly
- **Test 8:** Fire/smoke created on appropriate tiles

### Integration Tests
- **Test 1:** Throw grenade → explosion → damage units in area
- **Test 2:** Explosion stopped by wall
- **Test 3:** Explosion reduced by unit armor
- **Test 4:** Explosive barrel triggers chain explosion
- **Test 5:** Smoke created on grass terrain
- **Test 6:** Fire created on wooden terrain
- **Test 7:** Visual animation shows expanding rings

### Manual Testing Steps
1. Run game with `lovec "engine"` (console enabled)
2. Enter battlescape with test units
3. Throw grenade at group of units
4. Check console for propagation messages:
   ```
   [ExplosionSystem] Explosion at (10,15), power=10, drop=2
   [ExplosionSystem] Ring 0: 1 tiles at power 10
   [ExplosionSystem] Ring 1: 6 tiles at power 8
   [ExplosionSystem] Ring 2: 12 tiles at power 6
   [ExplosionSystem] Tile (11,15) absorbed by wall (armor=5), no propagation
   [ExplosionSystem] Applied 8 damage to Soldier at (10,16)
   ```
5. Verify all units in range took damage
6. Verify walls blocked propagation
7. Verify visual explosion animation
8. Test chain explosion with explosive barrel
9. Verify smoke/fire effects appear

### Expected Results
- Console shows ring-by-ring propagation
- Power values decrease correctly per ring
- Obstacles block or reduce propagation
- Units in blast radius take appropriate damage
- Chain explosions trigger sequentially
- Smoke and fire appear on correct tiles
- Visual animation shows expanding rings with delays
- No crashes or errors in Love2D console

---

## How to Run/Debug

### Running the Game
```bash
lovec "engine"
```

### Debug Console Output Example
```
[ProjectileSystem] Grenade impact at (10, 15)
[ExplosionSystem] Creating explosion: epicenter=(10,15), power=10, drop=2
[ExplosionSystem] Ring 0 (epicenter): 1 tiles
[ExplosionSystem]   Tile (10,15): power=10
[ExplosionSystem]   Applied 10 damage to terrain
[ExplosionSystem] Ring 1: 6 tiles
[ExplosionSystem]   Tile (11,15): power=8
[ExplosionSystem]   Unit present: Soldier (armor=2)
[ExplosionSystem]   Applied 8 damage to Soldier
[ExplosionSystem]   Propagation: 8 - 2 (dropoff) - 2 (armor) = 4
[ExplosionSystem]   Tile (10,16): power=8
[ExplosionSystem]   Wall present (armor=5)
[ExplosionSystem]   Propagation blocked: 8 - 2 - 5 = 1 (stopped)
[ExplosionSystem] Ring 2: 4 tiles (2 blocked)
[ExplosionSystem]   Tile (12,15): power=6
[ExplosionSystem] Ring 3: 3 tiles
[ExplosionSystem]   Tile (13,15): power=4
[ExplosionSystem] Ring 4: 2 tiles
[ExplosionSystem]   Tile (14,15): power=2
[ExplosionSystem] Ring 5: power=0, stopping
[ExplosionSystem] Checking chain explosions...
[ExplosionSystem] Explosive terrain at (11,16), queueing explosion
[ExplosionSystem] Creating smoke/fire effects...
[FireSystem] Fire started at (10,15)
[SmokeSystem] Smoke created at (11,15)
```

### Debugging Checklist
- [ ] Explosion creation message shows epicenter and power
- [ ] Ring messages show tile count and power level
- [ ] Absorption calculations logged correctly
- [ ] Damage application messages for each unit
- [ ] Chain explosion detection and queueing logged
- [ ] Fire/smoke creation messages appear
- [ ] No division by zero or nil tile errors
- [ ] No infinite propagation loops

---

## Documentation Updates

### Files to Update
- `wiki/API.md` - Add ExplosionSystem API
- `wiki/FIRE_SMOKE_MECHANICS.md` - Update with explosion mechanics
- `wiki/faq.md` - Add explosion damage FAQ
- `engine/battle/systems/explosion_system.lua` - Full LuaDoc comments

### Documentation Content
- Explosion propagation algorithm explanation
- Power dropoff calculation with examples
- How obstacles absorb and block damage
- Ring-by-ring animation timing
- Chain explosion mechanics
- Integration with fire/smoke systems
- How to configure explosive weapons

---

## Notes

**Design Decisions:**
- Use flood-fill instead of fixed radius (allows obstacles to block)
- Epicenter → 6 neighbors, others → 3 neighbors (realistic propagation)
- Highest power wins for overlapping waves
- Terrain and unit armor **both** reduce propagation
- Chain explosions process sequentially (not simultaneously)
- Animation delay 50-60ms per ring (fast enough to feel explosive, slow enough to see)
- Explosions destroy fragile floors (simulate force)

**Real Example:**
```
Grenade: power=10, drop=2
Terrain: grass (armor=0), stone wall (armor=5)
Units: Soldier (armor=2), Alien (armor=3)

Epicenter (10,15): power=10, damages terrain and any unit there

Ring 1 (6 tiles):
  (11,15) - open grass: 10-2=8 power, continues at 8-2=6
  (10,16) - stone wall: 10-2=8 power, 8-5=3, continues at 3-2=1
  (9,15) - Soldier: 10-2=8 power, damages soldier, 8-2-2=4, continues at 4-2=2
  (10,14) - open: 10-2=8, continues at 6
  (11,14) - open: 10-2=8, continues at 6
  (9,16) - open: 10-2=8, continues at 6

Ring 2 (propagates from ring 1):
  From (11,15) at power 6: neighbors get 6-2=4
  From (10,16) at power 1: 1-2=-1, stops
  From (9,15) at power 2: neighbors get 2-2=0, stops
  etc...
```

**Future Enhancements:**
- Different explosion shapes (cone, line)
- Debris and shrapnel effects
- Shock wave that stuns nearby units
- Explosive compression (extra damage in enclosed spaces)

---

## Blockers

**Dependencies:**
- TASK-013: Projectile System (triggers explosions)
- TASK-014: Damage Resolution System (applies damage to units)

**External Blockers:**
- None

---

## Review Checklist

Before marking complete:
- [ ] All acceptance criteria met
- [ ] Unit tests written and passing
- [ ] Integration tests successful
- [ ] Manual testing completed with Love2D console
- [ ] Console shows detailed propagation logs
- [ ] Propagation algorithm verified with hand calculations
- [ ] Chain explosions work correctly
- [ ] Fire/smoke integration working
- [ ] Visual animation timing correct
- [ ] No console errors or warnings
- [ ] Code follows Lua best practices
- [ ] LuaDoc comments complete
- [ ] API documentation updated
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
- TASK-017: Terrain Destruction System
- TASK-018: Explosion Visual Effects
- TASK-019: Chain Reaction Balancing
