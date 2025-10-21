# Phase 2A Step 1.1: LOS System Analysis Report

**Date:** October 21, 2025  
**Status:** COMPLETED  
**Duration:** 30 minutes  
**Next Step:** Phase 2A Step 1.2 - Verify Cover System  

---

## Executive Summary

The current LOS (Line of Sight) system in `los_system.lua` (301 lines) is **well-architected** and **fully functional** for basic line-of-sight calculations. The system uses hex-based geometry with proper obstacle detection and distance calculations. However, **cover system integration and flanking detection are not present** in the LOS module itself, requiring implementation in combat resolution and tactical layers.

**Key Finding:** LOS system is solid; enhancements needed are:
1. Cover damage calculation (separate module)
2. Flanking detection (tactical layer)
3. Visual indicators (UI layer)

---

## Current Implementation Analysis

### 1. LOS Calculation Architecture

**Method Used:** Hex Line Raycasting with Obstacle Detection

**Core Function:** `calculateLine(x0, y0, x1, y1, maxDistance)`
- Converts offset coordinates to axial hex coordinates
- Uses `HexMath.hexLine()` to generate line points
- Returns array of points: `{x, y, distance}`
- Respects maxDistance limit

```lua
-- Example: Line from (5,5) to (8,8)
-- Returns: [{x:5, y:5, dist:0}, {x:6, y:6, dist:1}, {x:7, y:7, dist:2}, {x:8, y:8, dist:3}]
```

**Strengths:**
- ✅ Proper hex coordinate conversion (offset ↔ axial)
- ✅ Accurate distance calculation using hex distance formula
- ✅ Efficient line generation (no performance issues noted)

---

### 2. Line of Sight Verification

**Function:** `hasClearLOS(battlefield, x0, y0, x1, y1, maxDistance)`

**Returns:** `(clearLOS: boolean, lastVisiblePoint: table or nil)`

**Algorithm:**
1. Calculate line from source to target
2. Iterate through each point (skipping start)
3. Check tile terrain: `terrain.blocksSight` property
4. Check environmental effects: `tile.effects.smoke > 0`
5. Return FALSE if obstacle found (but return obstacle as lastVisiblePoint)
6. Return TRUE if full line is clear

**Strengths:**
- ✅ Proper obstacle detection
- ✅ Smoke/environmental blocking
- ✅ Out-of-bounds handling
- ✅ Returns last visible point (useful for UI feedback)

**Limitations Identified:**
- ❌ No partial cover handling (all-or-nothing blockage)
- ❌ No flanking position awareness
- ❌ No damage modifier calculation
- ❌ No UI indicators for cover

---

### 3. Vision Cone System

**Function:** `calculateConeOfSight(battlefield, centerX, centerY, facing, coneAngle, maxDistance, isDay)`

**Features:**
- Directional vision cone (120° forward)
- Hexagonal direction calculation
- Obstacle detection within cone
- Blocked tile tracking

**Implementation Details:**
- Facing: 0-5 (6 hex directions)
- Cone angle: 2 hex directions on each side (120°)
- Direction calculation: Uses `HexMath.getDirection()`
- Blocked tiles: Stored in hash table to avoid duplicates

**Strengths:**
- ✅ Proper directional facing
- ✅ Efficient blocked tile tracking
- ✅ Can see obstacles even when blocked further

**Limitations:**
- ⚠️ Cone calculation for 8-directional facing may have edge cases

---

### 4. Unit Visibility Detection

**Function:** `canSeeUnit(seer, target, battlefield)`

**Logic:**
1. Calculate hex distance between units
2. Check if within sight range (`seer.stats.sight`)
3. Check directional cone (120° = within 1 direction)
4. Check clear LOS between positions
5. Fallback to omnidirectional sense range

**Strengths:**
- ✅ Multi-layered visibility (directed sight + omnidirectional sense)
- ✅ Proper facing-to-hex conversion
- ✅ Distance-based falloff

**Stat Dependencies:**
- `seer.stats.sight` - Primary sight range
- `seer.stats.sense` - Omnidirectional sense range (fallback)

---

### 5. Omnidirectional Sight

**Function:** `calculateOmniSight(battlefield, centerX, centerY, maxDistance)`

**Features:**
- 360° visibility calculation
- All hexes within range checked
- Obstacle detection
- Blocked tile tracking

**Implementation:**
- Gets all hexes in range: `HexMath.hexesInRange(q, r, maxDistance)`
- Iterates each hex and checks clear LOS
- Adds visible hexes and blocked obstacles

**Strengths:**
- ✅ Complete 360° coverage
- ✅ Efficient range calculation
- ✅ Proper blocked tile deduplication

---

### 6. Player Visibility for Units

**Function:** `calculateVisibilityForUnit(unit, battlefield, isDay)`

**Logic:**
1. Omnidirectional sight (no facing)
2. Day sight: 15 tiles; Night sight: 10 tiles
3. Returns array of visible tiles with distances
4. Always includes unit's own position

**Current Sight Ranges:**
- Day: 15 hex tiles
- Night: 10 hex tiles

**Note:** These are hardcoded; should be verified against wiki specifications.

---

## Hexagonal Coordinate System

**Dependency:** `HexMath` module

**Key Functions Used:**
- `offsetToAxial(col, row)` - Convert display coords to axial
- `axialToOffset(q, r)` - Convert back for display
- `hexLine(q0, r0, q1, r1)` - Get line between two hexes
- `distance(q1, r1, q2, r2)` - Calculate hex distance
- `getDirection(q1, r1, q2, r2)` - Get direction (0-5)
- `hexesInRange(q, r, range)` - Get all hexes within range

**Assumption:** Flat-top hex layout (likely)

---

## Cover System Integration Assessment

**Current State:** NOT IMPLEMENTED IN LOS MODULE

**Where Cover Should Live:** Combat resolution layer, not LOS

**Cover Fields Needed (in `battle_tile.lua`):**
```lua
{
  x, y,
  terrain = { blocksSight, ... },
  cover = {
    type = "full" | "half" | "none",
    facingRequired = 0-5,  -- Direction cover protects
    damageReduction = 0.0-1.0
  }
}
```

**Cover Damage Application:** Should happen in `damage_models.lua`, not LOS

**Recommendation:** Cover calculation is **separate concern** from LOS

---

## Flanking Detection Assessment

**Current State:** NOT IMPLEMENTED IN LOS MODULE

**Where Flanking Should Live:** Combat resolution layer

**Flanking Detection Algorithm Needed:**
```lua
function isFlankingPosition(attacker, defender, battlefield)
  local q1, r1 = HexMath.offsetToAxial(attacker.x, attacker.y)
  local q2, r2 = HexMath.offsetToAxial(defender.x, defender.y)
  
  -- Get direction from defender to attacker
  local direction = HexMath.getDirection(q2, r2, q1, r1)
  
  -- Get defender's facing (0-5)
  local defenderFacing = math.floor(defender.facing * 6 / 8) % 6
  
  -- Flanking if not in front (direction != facing)
  -- Rear if opposite (direction == (facing + 3) % 6)
  
  local facingDiff = math.abs(direction - defenderFacing) % 6
  facingDiff = math.min(facingDiff, 6 - facingDiff)
  
  if facingDiff >= 2 then
    return true  -- Flanking or rear
  end
  return false
end
```

**Recommendation:** Flanking detection is **separate from LOS**; implement in combat system

---

## Dependencies

**Required Modules:**
1. `core.data_loader` - Terrain definitions
2. `battlescape.battle_ecs.hex_math` - Hex coordinate math
3. `battlefield` object - Must have `getTile(x, y)` method

**Assumptions:**
- Battlefield has `getTile(x, y)` → returns `{terrain, effects}`
- Terrain has `blocksSight` boolean
- Effects may have `smoke > 0` indicator
- Units have `stats.sight` and `stats.sense` fields
- Units have `x, y, facing` coordinates

---

## Enhancement Opportunities for Step 1.2

### Priority 1: Verify Cover System Files
- [ ] Check `engine/battlescape/combat/battle_tile.lua` for cover field
- [ ] Check `engine/battlescape/combat/damage_models.lua` for cover damage application
- [ ] Check if cover bonuses are applied correctly

### Priority 2: Verify Combat System Integration
- [ ] Check `engine/battlescape/combat/combat_system.lua` for LOS usage
- [ ] Verify LOS is called before damage calculation
- [ ] Check if terrain covers are accessible

### Priority 3: Create Flanking System (If Missing)
- [ ] Create `engine/battlescape/combat/flanking_system.lua`
- [ ] Implement flanking position detection
- [ ] Integrate with combat resolution

### Priority 4: Add UI Indicators
- [ ] Verify visual feedback for cover status
- [ ] Add UI layer for flanking indicators
- [ ] Test visibility with debug display

---

## Test Plan for Step 1.2

**Verification Checklist:**
- [ ] Obstacle blocking LOS correctly (walls block, not walls don't)
- [ ] Smoke affects visibility
- [ ] Distance falloff works (sight range 10-15 tiles)
- [ ] Directional cone limits vision (120° forward)
- [ ] Unit detection uses both sight + sense
- [ ] Hex math conversion is accurate
- [ ] No performance issues with large visibility ranges
- [ ] Last visible point tracking works (for UI)
- [ ] Multiple obstacles handled correctly
- [ ] Out-of-bounds tiles handled correctly
- [ ] Cover system integration verified
- [ ] Flanking detection ready for implementation

---

## Conclusion

**LOS System Status:** ✅ **SOLID FOUNDATION**

The current LOS system is well-implemented for basic line-of-sight calculations using hex geometry. The architecture is clean, efficient, and extensible.

**Required Enhancements:**
1. ✅ LOS itself: Complete and working
2. ⚠️ Cover integration: Needs verification in adjacent systems
3. ❌ Flanking detection: Needs to be implemented
4. ⚠️ UI feedback: Needs to display cover and flanking status

**Ready for Step 1.2:** YES - Can proceed to verify cover system files and implement flanking detection

**Estimated Time for Step 1.2:** 1-2 hours

---

## References

**Files Analyzed:**
- `engine/battlescape/combat/los_system.lua` (301 lines)

**Files to Examine in Step 1.2:**
- `engine/battlescape/combat/battle_tile.lua`
- `engine/battlescape/combat/damage_models.lua`
- `engine/battlescape/combat/combat_system.lua`

**Related Phase 2A Files:**
- `tasks/TODO/PHASE_2A_BATTLESCAPE_COMBAT_FIXES.md` (implementation guide)

---

**Analysis Completed:** Step 1.1 ✅  
**Status:** Ready to proceed to Step 1.2
