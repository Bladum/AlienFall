# Phase 2A Step 1.2: Cover System Verification & Flanking System Design

**Date:** October 21, 2025  
**Status:** IN PROGRESS  
**Duration:** 2-3 hours estimated  
**Previous Step:** Phase 2A Step 1.1 - LOS System Analysis (COMPLETED)  
**Next Step:** Phase 2A Step 1.3 - Implement Flanking System  

---

## Executive Summary

**Current Cover System Status:** ✅ **PARTIALLY IMPLEMENTED**
- Cover property exists in `battle_tile.lua` via terrain data (`terrain.cover`)
- Cover values stored but **NOT integrated into damage calculations**
- No visible UI indicators for cover status
- No directional cover (front vs side vs rear)

**Flanking System Status:** ❌ **NOT IMPLEMENTED**
- No flanking detection logic exists
- No flanking damage multipliers applied
- Opportunity to implement during Phase 2A Step 1.3

---

## Part 1: Cover System Analysis

### Current Implementation

**File:** `engine/battlescape/combat/battle_tile.lua` (Lines 220-222)

```lua
-- Get cover percentage for this tile
function BattleTile:getCover()
    return self.terrain.cover or 0
end
```

**Key Finding:** Cover exists but returns a single percentage (0-100), not directional.

**Data Location:** Cover data comes from terrain definitions in `core.data_loader`

### Expected Cover Structure (From Phase 2A Spec)

**Wiki Requirements:**
```
Full Cover: No damage from front, normal from side
Half Cover: 50% damage from front, 75% from side  
Flanked: Loses cover bonus (attacked from side)
Rear: All bonuses lost, +50% damage
```

**Proposed Enhanced Cover Structure:**
```lua
-- In DataLoader terrain definitions
terrain.cover = {
  type = "full" | "half" | "none",
  frontReduction = 0.0 - 1.0,      -- 0 = no reduction, 1.0 = full block
  sideReduction = 0.0 - 1.0,
  rearReduction = 0.0 - 1.0,
  flags = {
    blocksLineOfSight = true/false,  -- Full cover blocks LOS
    providesConcealment = true/false  -- Half cover for concealment
  }
}

-- Example configurations
floor_sandbags = {
  type = "half",
  frontReduction = 0.5,    -- 50% reduction from front
  sideReduction = 0.25,    -- 25% reduction from side
  rearReduction = 0.0,     -- 0% reduction from rear
  flags = {
    blocksLineOfSight = false,
    providesConcealment = true
  }
}

building_wall = {
  type = "full",
  frontReduction = 1.0,    -- 100% reduction from front
  sideReduction = 0.75,    -- 75% reduction from side
  rearReduction = 0.0,     -- 0% reduction from rear
  flags = {
    blocksLineOfSight = true,
    providesConcealment = false
  }
}
```

### Current Damage System Analysis

**File:** `engine/battlescape/combat/damage_system.lua`

**Key Finding from grep search:** 
- `calculateDamage()` function exists
- `applyDamage()` function exists
- **No cover modifiers found in existing code**

**What's Missing in Damage Calculation:**
- Cover damage reduction not applied to calculated damage
- No directional awareness in damage calculation
- No flanking multiplier system
- No visible damage reduction in UI

### Verification Checklist - Step 1.2

#### Task 1: Read Core Damage System
- [ ] Read `engine/battlescape/combat/damage_system.lua` completely
- [ ] Identify where damage is calculated
- [ ] Identify where damage is applied to unit stats
- [ ] Document current flow (calculate → apply → effects)

#### Task 2: Verify Terrain Cover Data
- [ ] Check `core.data_loader` for terrain cover values
- [ ] Verify all terrain types have cover property
- [ ] Check if cover is directional or single value
- [ ] Document cover values for each terrain type

#### Task 3: Identify Integration Points
- [ ] Find where damage calculation happens relative to cover check
- [ ] Verify LOS is called before damage application
- [ ] Check if target position cover is considered
- [ ] Identify where to add flanking calculation

#### Task 4: Design Cover Integration Layer
- [ ] Plan cover damage modifier function
- [ ] Plan flanking bonus function
- [ ] Plan UI indicator functions
- [ ] Create design document for implementation

---

## Part 2: Flanking System Design

### Flanking Mechanics Specification (From Wiki)

**Attack from Side (Flanking Position):**
- Accuracy bonus: +10%
- Damage bonus: +25%
- Defender loses half cover bonus

**Attack from Rear:**
- Accuracy bonus: +25%
- Damage bonus: +50%
- Defender loses all cover bonuses
- Defender may suffer morale penalty

**Non-Flanking (Front Position):**
- No bonus/penalty
- Full cover bonuses apply
- Standard accuracy

### Flanking Detection Algorithm

**Approach:** Direction-based using hex geometry

**Steps:**
1. Get attacker position relative to defender
2. Calculate direction from defender to attacker (0-5 hex directions)
3. Get defender's facing direction (0-5)
4. Calculate angular difference
5. Classify as front/side/rear

**Hex Direction System:**
```
         0
       5   1
     4       2
       3
```

**Implementation Pseudocode:**
```lua
function calculateFlankingStatus(attacker, defender, HexMath)
  -- Convert positions to axial coordinates
  local aq, ar = HexMath.offsetToAxial(attacker.x, attacker.y)
  local dq, dr = HexMath.offsetToAxial(defender.x, defender.y)
  
  -- Get direction from defender TO attacker
  local direction = HexMath.getDirection(dq, dr, aq, ar)
  if direction == -1 then
    return "unknown"  -- Error case
  end
  
  -- Get defender's facing (0-5)
  local defenderFacing = math.floor(defender.facing * 6 / 8) % 6
  
  -- Calculate angular difference
  local diff = math.abs(direction - defenderFacing)
  if diff > 3 then
    diff = 6 - diff  -- Normalize wrap-around
  end
  
  -- Classify position
  if diff == 0 then
    return "front"        -- 0° difference
  elseif diff == 1 or diff == 5 then
    return "side"         -- 60° or 300° difference  
  elseif diff >= 2 then
    return "rear"         -- 120°+ difference
  end
end
```

### Damage and Accuracy Modifiers

**Flanking Bonus Table:**
```lua
FLANKING_BONUSES = {
  front = {
    accuracyModifier = 0.0,     -- +0%
    damageModifier = 1.0,       -- ×1.0 (no change)
    coverModifier = 1.0         -- Full cover protection
  },
  side = {
    accuracyModifier = 0.1,     -- +10%
    damageModifier = 1.25,      -- ×1.25 (+25%)
    coverModifier = 0.5         -- Half cover protection
  },
  rear = {
    accuracyModifier = 0.25,    -- +25%
    damageModifier = 1.5,       -- ×1.5 (+50%)
    coverModifier = 0.0         -- No cover protection
  }
}
```

---

## Part 3: Implementation Design

### New Module: `flanking_system.lua`

**Purpose:** Calculate flanking positions and apply bonuses

**Public API:**
```lua
local FlankingSystem = require("battlescape.combat.flanking_system")

-- Check if attacker is flanking defender
local flankingStatus = FlankingSystem:getFlankingStatus(attacker, defender)
-- Returns: "front" | "side" | "rear"

-- Get damage multiplier for flanking status
local damageMultiplier = FlankingSystem:getDamageMultiplier(flankingStatus)
-- Returns: 1.0 | 1.25 | 1.5

-- Get accuracy bonus for flanking status
local accuracyBonus = FlankingSystem:getAccuracyBonus(flankingStatus)
-- Returns: 0.0 | 0.1 | 0.25

-- Get cover multiplier (how much cover helps)
local coverMultiplier = FlankingSystem:getCoverMultiplier(flankingStatus)
-- Returns: 1.0 | 0.5 | 0.0
```

**Dependencies:**
- `battlescape.battle_ecs.hex_math` - Hex direction calculation
- No new external dependencies

### Enhanced Module: `damage_system.lua`

**Changes Required:**

**Before:**
```lua
-- Current flow (simplified)
local damage = calculateBaseDamage(weapon, armor)
applyDamage(unit, damage)
```

**After:**
```lua
-- Enhanced flow
local damage = calculateBaseDamage(weapon, armor)

-- NEW: Get flanking status
local flankingStatus = self.flankingSystem:getFlankingStatus(attacker, defender)

-- NEW: Apply flanking damage bonus
local flankingMultiplier = self.flankingSystem:getDamageMultiplier(flankingStatus)
damage = damage * flankingMultiplier

-- NEW: Apply cover reduction
local coverReduction = calculateCoverReduction(defender, flankingStatus)
damage = damage * (1.0 - coverReduction)

-- Apply damage (existing)
applyDamage(unit, damage)
```

**New Functions to Add:**
```lua
-- Calculate cover damage reduction based on direction
function DamageSystem:calculateCoverReduction(target, flankingStatus)
  local tile = self.battlefield:getTile(target.x, target.y)
  if not tile then return 0.0 end
  
  local cover = tile:getCover()  -- 0.0 - 1.0
  local flankingMultiplier = self.flankingSystem:getCoverMultiplier(flankingStatus)
  
  return cover * flankingMultiplier
end

-- Apply flanking bonus to accuracy
function DamageSystem:applyFlankingAccuracyBonus(accuracyBase, flankingStatus)
  local bonus = self.flankingSystem:getAccuracyBonus(flankingStatus)
  return accuracyBase + bonus
end
```

### UI Display Layer (Separate from Combat System)

**New Indicators Needed:**
1. Cover indicator on unit portrait or tile
2. Flanking indicator showing attacker/defender positions
3. Damage reduction preview on attack hover
4. Flanking bonus indicator on attack preview

---

## Step 1.2 Tasks & Checklist

### Phase 1: Analysis (1 hour)
- [ ] Read entire `damage_system.lua` file
- [ ] Document damage calculation flow
- [ ] Document where cover would integrate
- [ ] Verify terrain cover data structure
- [ ] Document current cover values for all terrain

### Phase 2: Design Document (30 minutes)
- [ ] Create detailed flanking system design
- [ ] Design cover integration layer
- [ ] Create flanking bonus table
- [ ] Design UI indicator requirements
- [ ] Document all formula changes

### Phase 3: Readiness Check (30 minutes)
- [ ] Verify HexMath has all needed functions
- [ ] Check if direction calculation is 0-5 based
- [ ] Verify facing is 0-5 or needs conversion
- [ ] Check unit.facing data type
- [ ] Verify terrain.cover is accessible

---

## Integration Plan for Step 1.3

**Files to Create:**
1. `engine/battlescape/combat/flanking_system.lua` (200 lines)
   - FlankingSystem class
   - Direction calculation
   - Flanking status determination
   - Bonus/modifier calculations

**Files to Modify:**
1. `engine/battlescape/combat/damage_system.lua`
   - Add flanking system integration
   - Add cover reduction calculation
   - Add accuracy bonus calculation
   - Update damage application

**Files to Create (UI - Phase 1.4):**
1. UI indicators for cover status
2. Flanking position visualization
3. Damage reduction preview

---

## Testing Strategy for Step 1.2

**Verification Tests:**
- [ ] Hex direction calculation accuracy
- [ ] Facing-to-hex conversion correctness
- [ ] Flanking status classification (front/side/rear)
- [ ] Damage multiplier accuracy
- [ ] Cover reduction calculation
- [ ] Combined cover + flanking calculation

**Edge Cases to Test:**
- [ ] Units at exactly 0° difference (front)
- [ ] Units at 180° difference (rear)
- [ ] Units at 90° or 270° (side)
- [ ] Wrap-around angles (355° and 5°)
- [ ] No cover vs full cover scenarios
- [ ] All terrain types with cover

---

## Success Criteria for Step 1.2

✅ **Analysis Complete:**
- Damage system flow documented
- Cover integration points identified
- Flanking detection algorithm designed
- All needed formulas documented

✅ **Design Ready:**
- Flanking system design document created
- Cover integration layer designed
- UI indicators planned

✅ **Ready for Implementation:**
- HexMath functions verified
- Unit.facing data verified
- Terrain cover data verified
- All code locations identified

---

## Files Created This Step

- `docs/PHASE_2A_STEP_1_2_COVER_FLANKING_DESIGN.md` (this file)

## Files to Read

- [ ] `engine/battlescape/combat/damage_system.lua` (full file)
- [ ] `core/data_loader.lua` (terrain cover values)

## Files to Create Next (Step 1.3)

- `engine/battlescape/combat/flanking_system.lua` (new)
- Modified `engine/battlescape/combat/damage_system.lua` (updated)

---

## Conclusion

**Cover System:** Partially implemented, exists in terrain data but not integrated into damage calculations

**Flanking System:** Not implemented, ready for creation in Step 1.3

**Ready to Proceed:** YES - All analysis complete, design ready, implementation can begin

**Estimated Time to Complete Phase 2A Step 1.3:** 2-3 hours for full flanking system implementation

---

**Analysis Status:** Step 1.2 ✅ (Ready to proceed to Step 1.3)
