# Task: Cover and Line of Sight System

**Status:** TODO  
**Priority:** High  
**Created:** October 13, 2025  
**Completed:** N/A  
**Assigned To:** AI Agent

---

## Overview

Implement raycast-based line of sight (LOS) with cover system. Each object on the path between shooter and target has a cover value. Cover reduces accuracy by 5% per point. Objects with cover ≥20 block shots entirely. Objects with sight_cost=99 block line of sight completely (e.g., walls).

---

## Purpose

Create tactical depth through cover mechanics. Smoke, windows, fences, and terrain provide partial cover. Walls and solid objects block shots. Makes positioning and target selection critical tactical decisions.

---

## Requirements

### Functional Requirements
- [ ] Raycast from shooter to target along hex grid
- [ ] Check each tile/object on the path for cover value
- [ ] Cover reduces accuracy by 5% per point
- [ ] Objects with cover ≥20 completely block shots
- [ ] Objects with sight_cost=99 block line of sight (target not visible)
- [ ] Smoke has sight_cost=3, cover=1 (harder to see and shoot through)
- [ ] Windows have low cover (bullets can pass through)
- [ ] Multiple cover sources stack (obstacles + effects like smoke)
- [ ] Invisible targets suffer -50% accuracy penalty
- [ ] Cover from solid objects tracked separately from effects

### Technical Requirements
- [ ] Implement hex grid raycasting algorithm
- [ ] Tile/object cover property system
- [ ] Effect cover system (smoke, fire, etc.)
- [ ] LOS calculation returns: visible, cover_obstacles, cover_effects
- [ ] Integrate with existing LOS system in `engine/systems/los_system.lua`
- [ ] Efficient raycast (stop early if blocked)
- [ ] Handle edge cases (shooter/target on same tile, zero range)

### Acceptance Criteria
- [ ] Raycast correctly traverses hex grid from A to B
- [ ] Cover reduces accuracy by 5% per point
- [ ] High cover (≥20) blocks shots completely
- [ ] Sight blockers (sight_cost=99) make target invisible
- [ ] Invisible targets have -50% accuracy
- [ ] Smoke (cover=1) reduces accuracy by 5%
- [ ] Multiple smoke clouds stack (3 smoke = -15% accuracy)
- [ ] UI shows cover status and effective accuracy
- [ ] Console logs LOS calculations for debugging

---

## Plan

### Step 1: Hex Raycast Algorithm
**Description:** Implement Bresenham-like raycast for hex grids  
**Files to modify/create:**
- `engine/battle/utils/hex_raycast.lua` - Hex raycast implementation
- `engine/systems/los_system.lua` - Integrate raycast with existing LOS

**Estimated time:** 4 hours

### Step 2: Cover Property System
**Description:** Add cover and sight_cost to tiles and objects  
**Files to modify/create:**
- `engine/battle/map_block.lua` - Add cover and sight_cost properties
- `engine/data/tiles.lua` - Define cover values for tile types
- `engine/data/objects.lua` - Define cover values for objects

**Estimated time:** 3 hours

### Step 3: Effect Cover System
**Description:** Track cover from dynamic effects (smoke, fire)  
**Files to modify/create:**
- `engine/battle/smoke_system.lua` - Add cover property to smoke
- `engine/battle/fire_system.lua` - Add cover property to fire
- `engine/battle/systems/effect_cover_system.lua` - Track effect cover

**Estimated time:** 2 hours

### Step 4: Cover-Based Accuracy Calculation
**Description:** Calculate accuracy reduction from cover  
**Files to modify/create:**
- `engine/battle/systems/accuracy_system.lua` - Add cover modifier
- `engine/battle/systems/shooting_system.lua` - Integrate cover checks

**Estimated time:** 3 hours

### Step 5: LOS Blocking and Visibility
**Description:** Handle sight blockers and invisible targets  
**Files to modify/create:**
- `engine/systems/los_system.lua` - Add sight blocking logic
- `engine/battle/systems/visibility_system.lua` - Track target visibility

**Estimated time:** 2 hours

### Step 6: UI Integration
**Description:** Display cover and visibility in UI  
**Files to modify/create:**
- `engine/modules/battlescape.lua` - Show cover info
- `engine/widgets/targeting_ui.lua` - Display LOS and cover status

**Estimated time:** 2 hours

### Step 7: Testing
**Description:** Verify LOS and cover systems work correctly  
**Test cases:**
- Raycast follows correct path
- Cover reduces accuracy correctly
- High cover blocks shots
- Sight blockers make targets invisible
- Smoke stacks correctly
- UI displays correct information

**Estimated time:** 3 hours

---

## Implementation Details

### Architecture
Extend existing LOS system with cover checking. Raycast returns list of tiles/objects traversed with their cover values. Accuracy system applies cover penalty. Shooting system validates LOS before allowing shots.

### Key Components

**HexRaycast:**
```lua
--- Cast ray from source to target on hex grid
-- @param startPos table Starting hex position {q, r, s}
-- @param endPos table Ending hex position {q, r, s}
-- @param battlefield table Battlefield for tile/object lookup
-- @return table Array of tiles traversed (excluding start, including end)
function HexRaycast.castRay(startPos, endPos, battlefield)
    -- Bresenham-like algorithm for hex grid
    -- Returns: {
    --   {pos = {q, r, s}, tile = tile_data, objects = {...}}
    -- }
end
```

**LOSResult:**
```lua
{
    visible = true,              -- Can shooter see target?
    blocked = false,             -- Is shot completely blocked?
    cover_obstacles = 3,         -- Cover from terrain/objects
    cover_effects = 1,           -- Cover from smoke/fire/etc
    blocking_object = nil,       -- Object that blocked LOS (if any)
    path = {tile1, tile2, ...}  -- Tiles traversed
}
```

**CoverSystem:**
```lua
--- Calculate total cover along LOS path
-- @param losResult table Result from LOS raycast
-- @return number Total obstacle cover (0-20+)
-- @return number Total effect cover (0-20+)
-- @return boolean Whether shot is blocked
function CoverSystem.calculateCover(losResult)
    local obstacleCover = 0
    local effectCover = 0
    
    for _, tile in ipairs(losResult.path) do
        -- Check tile cover
        obstacleCover = obstacleCover + (tile.cover or 0)
        
        -- Check objects on tile
        for _, obj in ipairs(tile.objects) do
            if obj.sight_cost >= 99 then
                return 0, 0, true -- Sight blocked
            end
            obstacleCover = obstacleCover + (obj.cover or 0)
        end
        
        -- Check effects on tile
        for _, effect in ipairs(tile.effects) do
            effectCover = effectCover + (effect.cover or 0)
        end
        
        -- Check if blocked by high cover
        if obstacleCover >= 20 then
            return obstacleCover, effectCover, true
        end
    end
    
    return obstacleCover, effectCover, false
end
```

**AccuracySystem Integration:**
```lua
--- Calculate cover modifier to accuracy
-- @param obstacleCover number Cover from obstacles (0-20)
-- @param effectCover number Cover from effects (0-20)
-- @return number Multiplier (0.0 to 1.0)
function AccuracySystem.getCoverMultiplier(obstacleCover, effectCover)
    -- Each point of cover reduces accuracy by 5%
    local totalCover = obstacleCover + effectCover
    local penalty = totalCover * 0.05 -- 5% per point
    return math.max(0.0, 1.0 - penalty)
end

--- Calculate visibility modifier
-- @param visible boolean Is target visible?
-- @return number Multiplier (0.5 if not visible, 1.0 if visible)
function AccuracySystem.getVisibilityMultiplier(visible)
    return visible and 1.0 or 0.5
end
```

### Cover Values Reference

**Tiles:**
- Open ground: cover = 0
- Low wall/fence: cover = 5
- Window: cover = 2, sight_cost = 0
- High wall: cover = 99, sight_cost = 99 (blocks)
- Door (closed): cover = 20, sight_cost = 99
- Door (open): cover = 0, sight_cost = 0

**Objects:**
- Small crate: cover = 3
- Large crate: cover = 8
- Tree: cover = 5, sight_cost = 2
- Vehicle: cover = 15
- Building wall: cover = 99, sight_cost = 99

**Effects:**
- Smoke (1 tile): cover = 1, sight_cost = 3
- Fire: cover = 0, sight_cost = 1
- Darkness: cover = 0, sight_cost = 5

### Example Calculation

**Scenario:** Unit shooting through 2 smoke tiles and a fence at a target

1. Raycast from shooter to target
2. Path hits: smoke tile 1, smoke tile 2, fence tile
3. Cover calculation:
   - Obstacle cover: fence = 5
   - Effect cover: smoke × 2 = 2
   - Total cover: 7 points
4. Accuracy penalty: 7 × 5% = 35%
5. Cover multiplier: 1.0 - 0.35 = 0.65

**Base accuracy:** 60%  
**After cover:** 60% × 0.65 = 39%

### Dependencies
- `engine/systems/los_system.lua` - Existing LOS system
- `engine/battle/smoke_system.lua` - Smoke effects
- `engine/battle/fire_system.lua` - Fire effects
- `engine/battle/systems/accuracy_system.lua` - Accuracy calculations
- TASK-009 Range and Accuracy System

---

## Testing Strategy

### Unit Tests
- Test 1: `test_hex_raycast.lua` - Verify raycast traverses correct tiles
- Test 2: `test_cover_calculation.lua` - Test cover reduction formula
- Test 3: `test_sight_blocking.lua` - Test sight_cost=99 blocks LOS
- Test 4: `test_high_cover_blocking.lua` - Test cover≥20 blocks shots
- Test 5: `test_smoke_stacking.lua` - Multiple smoke clouds stack
- Test 6: `test_visibility_penalty.lua` - Invisible targets -50% accuracy

### Integration Tests
- Test 1: `test_los_cover_integration.lua` - Full LOS + cover system
- Test 2: `test_shooting_through_cover.lua` - Shooting mechanics with cover

### Manual Testing Steps
1. Run game with `lovec "engine"`
2. Enter battlescape with various terrain and smoke
3. Select unit and target enemy behind cover
4. Verify UI shows:
   - LOS status (visible/blocked)
   - Cover amount from obstacles
   - Cover amount from effects
   - Effective accuracy with all modifiers
5. Test shooting through:
   - Open ground (no penalty)
   - Single smoke cloud (-5% accuracy)
   - Multiple smoke clouds (stacking)
   - Fence (partial cover)
   - Wall (blocked)
   - Window (shootable with small penalty)
6. Verify console shows raycast path and cover calculations
7. Test edge cases (adjacent targets, zero range)

### Expected Results
- Raycast correctly traverses hex grid
- Cover reduces accuracy as specified
- High cover blocks shots
- Sight blockers make targets invisible (-50%)
- Smoke stacks correctly
- UI clearly shows all modifiers
- Console logs detailed calculations
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
- Add debug prints:
```lua
print("[HexRaycast] Path length: " .. #path .. " tiles")
print("[CoverSystem] Obstacle cover: " .. obstacleCover)
print("[CoverSystem] Effect cover: " .. effectCover)
print("[CoverSystem] Total cover: " .. (obstacleCover + effectCover))
print("[CoverSystem] Shot blocked: " .. tostring(blocked))
print("[AccuracySystem] Cover multiplier: " .. multiplier)
print("[LOSSystem] Target visible: " .. tostring(visible))
```
- Use debug visualization to show raycast path
- Draw cover values on tiles for testing
- Use F9 grid overlay to verify tile positions

### Debug Visualization
```lua
-- Draw raycast path
for _, tile in ipairs(losResult.path) do
    love.graphics.circle("line", tile.x, tile.y, 10)
end

-- Draw cover values
love.graphics.print("Cover: " .. cover, tile.x, tile.y)
```

### Temporary Files
- All temporary files MUST be created in: `os.getenv("TEMP")`
- Never create temp files in project directories

---

## Documentation Updates

### Files to Update
- [ ] `wiki/API.md` - Add HexRaycast, CoverSystem, VisibilitySystem APIs
- [ ] `wiki/FAQ.md` - Add section on cover mechanics and LOS
- [ ] `wiki/ECS_BATTLE_SYSTEM_API.md` - Document cover components
- [ ] `engine/battle/utils/hex_raycast.lua` - Full docstrings
- [ ] `engine/battle/systems/cover_system.lua` - Full docstrings
- [ ] Create `wiki/COVER_SYSTEM.md` - Detailed cover mechanics guide

---

## Notes

- Cover system adds significant tactical depth
- Smoke becomes useful for advancing under fire
- Windows are shootable but provide some protection
- High cover (walls) completely blocks shots
- Sniper rifles with high base accuracy can overcome cover better
- Future: destructible cover (reduces cover value when damaged)
- Future: prone stance for additional cover
- Future: cover direction (only protects from certain angles)

**Why 120% accuracy isn't wasted:**
Even with 95% max accuracy, high accuracy helps:
1. Shoot further effectively (range penalty)
2. Shoot through more cover (5% per point)
3. Shoot through smoke/effects
Example: 120% base accuracy with 5 cover = 95% final (120% - 25% = 95%)

---

## Blockers

**Depends on:**
- TASK-008-weapon-equipment-system (weapon properties)
- TASK-009-range-accuracy-system (accuracy calculations)

**Requires:**
- Existing LOS system in `engine/systems/los_system.lua`
- Smoke system in `engine/battle/smoke_system.lua`

---

## Review Checklist

- [ ] Code follows Lua/Love2D best practices
- [ ] No global variables (all use `local`)
- [ ] Proper error handling with `pcall` where needed
- [ ] Performance optimized (early exit on sight block)
- [ ] All temporary files use TEMP folder
- [ ] Console debugging statements added
- [ ] Tests written and passing
- [ ] Documentation updated
- [ ] Code reviewed
- [ ] No warnings in Love2D console
- [ ] Raycast algorithm correct for hex grid
- [ ] Cover values balanced for gameplay
- [ ] Edge cases handled (same tile, zero range)
- [ ] UI clearly communicates cover status

---

## Post-Completion

### What Worked Well
- (To be filled after completion)

### What Could Be Improved
- (To be filled after completion)

### Lessons Learned
- (To be filled after completion)
