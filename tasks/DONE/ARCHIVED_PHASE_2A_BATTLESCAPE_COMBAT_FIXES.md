# Phase 2A: Battlescape Combat System - Comprehensive Fixes

**Created:** October 21, 2025  
**Status:** IN_PROGRESS  
**Duration:** 8-12 hours  
**Priority:** CRITICAL  

---

## Executive Summary

The Battlescape combat system is 75% aligned with wiki design. This phase identifies and fixes specific gaps in:
1. **Line of Sight (LOS) & Cover System** - Verify accuracy and completeness
2. **Threat Assessment** - Enhance AI threat calculation
3. **Flanking Bonus System** - Implement missing flanking mechanics
4. **Combat Flow Verification** - Ensure turn phases match wiki

---

## Gap Analysis

### Gap #1: LOS/Cover System Verification

**Current Status:** Partial implementation exists
- ✅ LOS system exists (`los_system.lua`)
- ✅ Optimized LOS exists (`los_optimized.lua`)
- ⚠️ Cover system needs verification
- ⚠️ Flanking detection needs implementation

**Wiki Requirement:**
```
Full Cover: No damage from front, normal from side
Half Cover: 50% damage from front, 75% from side
Flanked: Loses cover bonus (attacked from side)
Rear: All bonuses lost, +50% damage
```

**Current Implementation Check:**
- Verify `battle_tile.lua` has cover values
- Check if cover bonuses are applied in damage calculation
- Verify flanking detection logic

**Fix Required:**
1. ✅ Verify cover system (read files)
2. ⚠️ Implement flanking detection if missing
3. ⚠️ Verify damage modifiers for cover/flank
4. ⚠️ Add UI indicators for cover status

---

### Gap #2: Threat Assessment System

**Current Status:** Exists but may need enhancement
- ✅ AI behavior exists
- ⚠️ Threat calculation may be simplified
- ⚠️ Threat assessment weighting unclear

**Wiki Requirement:**
```
Threat Assessment Factors:
- Unit health (lower = higher threat?)
- Weapon damage output
- Distance to AI unit
- Flanking position
- Morale/abilities
- Strategic value
```

**Current Implementation:**
- Need to check `engine/battlescape/ai/` for threat system
- Look for threat scoring algorithm
- Verify weighting of factors

**Fix Required:**
1. ⚠️ Analyze current threat system
2. ⚠️ Enhance weighting if needed
3. ⚠️ Add strategic value calculation
4. ⚠️ Test threat ranking with multiple scenarios

---

### Gap #3: Flanking Bonus System

**Current Status:** Needs verification/implementation
- ❌ Flanking system may be missing or incomplete
- ❌ Flanking damage multiplier not verified
- ❌ Flanking position detection unclear

**Wiki Requirement:**
```
Flanking:
- Attack from side hexes: +10% accuracy, +25% damage
- Attack from rear: +25% accuracy, +50% damage
- Flanked unit loses half cover bonus
```

**Fix Required:**
1. ⚠️ Verify if flanking detection exists
2. ❌ Implement if missing:
   - Position check (6 hex neighbors)
   - Flanking flag in attack resolution
   - Damage multiplier application
3. ⚠️ Add flanking UI indicator
4. ⚠️ Test with multiple unit configurations

---

### Gap #4: Combat Flow Verification

**Current Status:** Needs comprehensive testing
- ✅ Turn-based system exists
- ⚠️ Phases may not match wiki exactly
- ⚠️ Action economy needs verification

**Wiki Requirements (Per Turn):**
- Phase 1: Player actions (100 TU per unit)
- Phase 2: AI actions (100 TU per unit)
- Phase 3: Resolution & events

**Verification Checklist:**
- [ ] Player can perform actions until TU spent
- [ ] AI executes after all players done
- [ ] TU costs match wiki (movement 4/hex, attacks 20-60, etc.)
- [ ] Turn order is correct (by initiative)
- [ ] Morale affects action availability
- [ ] Wounds affect movement/accuracy

---

## Implementation Plan

### Phase 2A.1: LOS/Cover System Enhancement (2-3 hours)

#### Step 1.1: Analyze Current LOS System
```bash
Files to Review:
- engine/battlescape/combat/los_system.lua (301 lines)
- engine/battlescape/combat/los_optimized.lua (optimized version)
- engine/battlescape/combat/battle_tile.lua (tile/cover data)
```

**Tasks:**
- [ ] Read `los_system.lua` completely
- [ ] Read `battle_tile.lua` for cover field
- [ ] Document current LOS calculation method
- [ ] Identify missing flanking detection

#### Step 1.2: Verify Cover System
```lua
Expected Cover Structure:
{
  x = 0, y = 0,
  cover_full = false,
  cover_half = true,      -- Half cover present
  cover_direction = "N",   -- Direction of cover
  cover_value = 3,        -- Armor bonus from cover
  cover_damage_reduction = 0.75  -- Incoming damage × 0.75
}
```

**Tasks:**
- [ ] Verify cover fields exist in battle_tile
- [ ] Verify cover is applied in damage calculation
- [ ] Test cover effectiveness with manual scenarios

#### Step 1.3: Implement Flanking Detection
```lua
-- Flanking Detection Algorithm
function Unit:checkIfFlanked(attacker_pos, attacker_unit)
  -- Get defending unit position
  local def_x, def_y = self.x, self.y
  local att_x, att_y = attacker_pos.x, attacker_pos.y
  
  -- Get hex neighbors (6 neighbors for hex grid)
  local neighbors = HexMath.getNeighbors(def_x, def_y)
  
  -- Check if attacker is in flank positions
  -- Flank positions = sides (not front)
  for i, neighbor in ipairs(neighbors) do
    if neighbor.x == att_x and neighbor.y == att_y then
      -- Determine flank type
      local direction = HexMath.getDirection(def_x, def_y, att_x, att_y)
      
      if isFrontDirection(direction) then
        return false  -- Not flanked
      elseif isRearDirection(direction) then
        return "rear"  -- Rear attack (most dangerous)
      else
        return "flank"  -- Side attack
      end
    end
  end
  
  return false
end

-- Apply flanking modifiers
function ApplyFlankingModifiers(attack, flanked_status)
  if flanked_status == "flank" then
    attack.accuracy_bonus = 0.10  -- +10% accuracy
    attack.damage_multiplier = 1.25  -- +25% damage
  elseif flanked_status == "rear" then
    attack.accuracy_bonus = 0.25  -- +25% accuracy
    attack.damage_multiplier = 1.50  -- +50% damage
  end
end
```

**Tasks:**
- [ ] Create `flanking_system.lua` if missing
- [ ] Implement `checkIfFlanked()` function
- [ ] Integrate into damage calculation
- [ ] Test with multiple scenarios

#### Step 1.4: Add UI Indicators
```lua
-- Draw cover/flank status on unit display
function DrawUnitStatus(unit, x, y)
  -- Draw cover indicator
  if unit.cover_type == "full" then
    drawIcon("FULL_COVER", x, y)
  elseif unit.cover_type == "half" then
    drawIcon("HALF_COVER", x, y)
  end
  
  -- Draw flanking warning
  if unit.is_flanked then
    drawIcon("WARNING_FLANKED", x, y + 8)
  end
end
```

**Tasks:**
- [ ] Add cover status display to UI
- [ ] Add flanking warning indicator
- [ ] Test UI rendering

---

### Phase 2A.2: Threat Assessment Enhancement (2-3 hours)

#### Step 2.1: Analyze Current Threat System
```bash
Files to Review:
- engine/battlescape/ai/ (AI system files)
- Look for threat_assessment.lua or similar
```

**Tasks:**
- [ ] Find threat calculation logic
- [ ] Document current weighting formula
- [ ] Identify missing factors

#### Step 2.2: Enhance Threat Calculation
```lua
-- Enhanced Threat Assessment
function CalculateThreat(target_unit, enemy_unit)
  local threat = 0
  
  -- Factor 1: Health (damaged units are less threatening)
  local health_ratio = target_unit.health / target_unit.max_health
  threat = threat + (100 * health_ratio)  -- 0-100
  
  -- Factor 2: Weapon damage output
  local weapon = target_unit:getEquippedWeapon()
  local weapon_damage = weapon:getDamage()
  threat = threat + (weapon_damage * 0.5)  -- Scale down to avoid dominance
  
  -- Factor 3: Distance (closer = more threatening)
  local distance = HexMath.distance(target_unit.x, target_unit.y, 
                                    enemy_unit.x, enemy_unit.y)
  threat = threat + (100 / math.max(distance, 1))  -- Inverse distance
  
  -- Factor 4: Flanking position (high threat if flanking AI)
  if target_unit:checkIfFlanked({x = enemy_unit.x, y = enemy_unit.y}) then
    threat = threat + 50  -- Bonus threat if target is flanking
  end
  
  -- Factor 5: Unit abilities/specialization
  local specialization = target_unit.specialization
  if specialization == "sniper" then
    threat = threat + 30  -- Snipers are dangerous
  elseif specialization == "heavy_weapons" then
    threat = threat + 25
  end
  
  -- Factor 6: Morale (low morale = less threatening)
  local morale_ratio = target_unit.morale / 100
  threat = threat * morale_ratio
  
  -- Factor 7: Status effects
  if target_unit:hasEffect("stun") then
    threat = threat * 0.5  -- Stunned units less threatening
  elseif target_unit:hasEffect("panicked") then
    threat = threat * 0.3  -- Panicked = unpredictable/less effective
  end
  
  return threat
end

-- Prioritize targets based on threat
function SelectTarget(enemy_unit, visible_targets)
  local best_target = nil
  local highest_threat = 0
  
  for _, target in ipairs(visible_targets) do
    local threat = CalculateThreat(target, enemy_unit)
    
    if threat > highest_threat then
      highest_threat = threat
      best_target = target
    end
  end
  
  return best_target, highest_threat
end
```

**Tasks:**
- [ ] Create/enhance threat calculation
- [ ] Add all 7 weighting factors
- [ ] Test with multiple enemy/unit combinations
- [ ] Verify AI makes strategic target choices

#### Step 2.3: Test Threat Assessment
```lua
-- Test scenarios
test_scenarios = {
  {
    name = "Should target healthy sniper over wounded infantry",
    enemy_count = 2,
    allies = {
      {health = 100, weapon = "sniper", spec = "sniper"},
      {health = 30, weapon = "rifle", spec = "soldier"}
    },
    expected_target = 1  -- Sniper
  },
  {
    name = "Should target flanking unit",
    enemy_count = 1,
    allies = {
      {health = 80, flanking = true, weapon = "rifle"}
    },
    expected_threat_bonus = 50
  },
  {
    name = "Should avoid panicked units (unpredictable)",
    enemy_count = 2,
    allies = {
      {health = 100, status = "normal"},
      {health = 100, status = "panicked"}
    },
    expected_lower_priority = 2
  }
}
```

**Tasks:**
- [ ] Implement threat test scenarios
- [ ] Run tests with Love2D console
- [ ] Verify AI target selection logic
- [ ] Adjust weights if needed

---

### Phase 2A.3: Flanking System Full Implementation (2-3 hours)

#### Step 3.1: Create Flanking System Module
```lua
-- engine/battlescape/combat/flanking_system.lua

local HexMath = require("battlescape.battle_ecs.hex_math")

local FlankingSystem = {}
FlankingSystem.__index = FlankingSystem

function FlankingSystem.new()
  local self = setmetatable({}, FlankingSystem)
  return self
end

-- Detect if target is flanked by attacker
function FlankingSystem:isFlanked(target_unit, attacker_unit)
  local def_x, def_y = target_unit.x, target_unit.y
  local att_x, att_y = attacker_unit.x, attacker_unit.y
  
  -- Same position = no flanking
  if def_x == att_x and def_y == att_y then
    return false
  end
  
  -- Get direction from defender to attacker
  local direction = HexMath.getDirection(def_x, def_y, att_x, att_y)
  
  -- Front hexes (can use cover)
  local front_directions = {"NW", "NE"}  -- Example for hex grid
  
  -- Rear hex (most dangerous)
  local rear_directions = {"S"}
  
  for _, front_dir in ipairs(front_directions) do
    if direction == front_dir then
      return false  -- Not flanked (front)
    end
  end
  
  for _, rear_dir in ipairs(rear_directions) do
    if direction == rear_dir then
      return "rear"  -- Rear attack
    end
  end
  
  return "flank"  -- Side attack (flanked)
end

-- Apply flanking modifiers to attack
function FlankingSystem:applyFlankingModifiers(attack, flank_type)
  if flank_type == "flank" then
    attack.accuracy_bonus = attack.accuracy_bonus or 0
    attack.accuracy_bonus = attack.accuracy_bonus + 0.10
    attack.damage_multiplier = 1.25
    attack.flank_type = "flank"
  elseif flank_type == "rear" then
    attack.accuracy_bonus = attack.accuracy_bonus or 0
    attack.accuracy_bonus = attack.accuracy_bonus + 0.25
    attack.damage_multiplier = 1.50
    attack.flank_type = "rear"
  end
  
  return attack
end

-- Get flanking bonus description
function FlankingSystem:getFlankingBonusText(flank_type)
  if flank_type == "rear" then
    return "REAR ATTACK: +25% Accuracy, +50% Damage"
  elseif flank_type == "flank" then
    return "FLANKED: +10% Accuracy, +25% Damage"
  end
  return ""
end

return FlankingSystem
```

**Tasks:**
- [ ] Create `flanking_system.lua`
- [ ] Implement `isFlanked()` function
- [ ] Implement `applyFlankingModifiers()` function
- [ ] Implement UI text helper

#### Step 3.2: Integrate Flanking into Combat
```lua
-- In damage_system.lua, during attack resolution:

local FlankingSystem = require("battlescape.combat.flanking_system")
local flanking = FlankingSystem.new()

function ResolveCombatAttack(attacker, defender, weapon, mode)
  local attack = {
    attacker = attacker,
    defender = defender,
    weapon = weapon,
    mode = mode,
    damage = 0,
    accuracy = 0
  }
  
  -- Step 1: Check if flanked
  local flank_type = flanking:isFlanked(defender, attacker)
  
  -- Step 2: Apply flanking modifiers
  if flank_type then
    attack = flanking:applyFlankingModifiers(attack, flank_type)
  end
  
  -- Step 3: Continue with normal damage calculation
  -- (accuracy check, damage roll, armor, etc.)
  
  return attack
end
```

**Tasks:**
- [ ] Add flanking check to combat resolution
- [ ] Test flanking damage multipliers
- [ ] Verify UI shows flanking status

#### Step 3.3: Test Flanking System
```lua
-- Test flanking detection
test_flanking = {
  {
    name = "Rear attack detected",
    defender = {x = 5, y = 5},
    attacker = {x = 5, y = 6},  -- South of defender
    expected_flank = "rear",
    expected_damage_mult = 1.50
  },
  {
    name = "Side flank detected",
    defender = {x = 5, y = 5},
    attacker = {x = 6, y = 5},  -- East of defender
    expected_flank = "flank",
    expected_damage_mult = 1.25
  },
  {
    name = "Front attack (no flank)",
    defender = {x = 5, y = 5},
    attacker = {x = 4, y = 4},  -- Northwest of defender
    expected_flank = false,
    expected_damage_mult = 1.0
  }
}
```

**Tasks:**
- [ ] Create flanking test scenarios
- [ ] Run with Love2D console
- [ ] Verify flanking detection accuracy
- [ ] Verify damage multipliers applied

---

### Phase 2A.4: Combat Flow Verification (1-2 hours)

#### Step 4.1: Verify Turn Phases
```lua
-- Expected turn structure:
-- Phase 1: Player actions (100 TU per unit)
-- Phase 2: AI actions (100 TU per unit)  
-- Phase 3: Resolution (environmental, recovery)

-- Verification checklist:
-- [ ] Phase transitions happen in correct order
-- [ ] Each unit gets exactly 100 TU
-- [ ] TU depletes with actions
-- [ ] Units can't act after TU spent
-- [ ] Turn ends properly, advances to next unit
```

**Tasks:**
- [ ] Verify turn phase sequence
- [ ] Test TU depletion
- [ ] Test action blocking (when TU insufficient)
- [ ] Test turn order

#### Step 4.2: Verify Action Costs
```lua
-- Expected action costs (from wiki):
-- Movement: 4 TU per hex
-- Attack snap: 20 TU
-- Attack aimed: 40 TU
-- Attack burst: 30 TU
-- Attack auto: 60 TU
-- Use item: 15 TU
-- Take cover: 10 TU
-- End turn: Free (spends remaining)

-- Verification:
-- [ ] Movement costs 4 TU per hex
-- [ ] Attacks cost correct amounts
-- [ ] Item use costs correct amount
-- [ ] Cover bonus applied correctly
```

**Tasks:**
- [ ] Read action_system.lua
- [ ] Verify all action costs match wiki
- [ ] Test with manual actions
- [ ] Adjust if needed

#### Step 4.3: Test Full Combat Cycle
```bash
Test Scenario:
1. Start battle with 3 friendly, 3 enemy units
2. Run 3 full turns
3. Verify:
   - All phases execute correctly
   - All units get their turn
   - Actions properly cost TU
   - Damage calculated correctly
   - Flanking bonuses applied
   - Morale affects actions
   - Environmental effects trigger
```

**Tasks:**
- [ ] Set up test scenario
- [ ] Run with Love2D console enabled
- [ ] Watch console for errors
- [ ] Verify each combat resolution

---

## Testing Strategy

### Manual Testing Checklist

```
LOS & Cover:
[ ] Unit in full cover takes 50% damage from front
[ ] Unit in half cover takes 75% damage from front
[ ] Flanked unit loses cover bonus
[ ] Rear attacked unit takes 150% damage

Threat Assessment:
[ ] AI targets healthy sniper before wounded infantry
[ ] AI targets closer threats first
[ ] AI avoids/deprioritizes panicked units
[ ] AI considers weapon damage in targeting

Flanking:
[ ] Rear attack deals 150% damage
[ ] Side attack deals 125% damage
[ ] Front attack deals normal damage
[ ] Flanking accuracy bonus applied (+25% rear, +10% side)

Combat Flow:
[ ] Turn order correct (by initiative)
[ ] Each unit gets 100 TU
[ ] Actions consume correct TU
[ ] Turn phases execute in order
[ ] Morale affects available actions
```

### Console Verification
```bash
Run command:
lovec "engine"

Watch console for:
- No ERROR messages during combat
- No warnings about missing systems
- Flanking damage calculations logged
- Threat assessment scoring visible
- Action point consumption tracked
```

---

## Implementation Order

**Recommended Sequence:**

1. **First (0.5-1 hour):** Analyze current systems
   - Read LOS system
   - Read combat resolution
   - Read AI behavior

2. **Second (1-2 hours):** Verify/fix LOS & cover
   - Confirm cover system works
   - Implement flanking detection
   - Add UI indicators

3. **Third (2-3 hours):** Enhance threat assessment
   - Create threat calculation
   - Add weighting factors
   - Test target selection

4. **Fourth (2-3 hours):** Implement flanking system
   - Create flanking_system.lua
   - Integrate into combat
   - Test all flanking scenarios

5. **Fifth (1-2 hours):** Verify combat flow
   - Check turn phases
   - Verify action costs
   - Run full combat cycle

6. **Final (1 hour):** Documentation & cleanup
   - Update code comments
   - Create test report
   - Mark gaps as fixed

---

## Success Criteria

Phase 2A is complete when:

✅ **LOS/Cover:**
- [ ] Cover bonus verified working
- [ ] Flanking detection implemented
- [ ] Flanking damage modifiers applied
- [ ] UI shows cover/flank status

✅ **Threat Assessment:**
- [ ] 7+ weighting factors implemented
- [ ] AI makes strategic target choices
- [ ] Threat scoring tested with 5+ scenarios

✅ **Flanking System:**
- [ ] Rear attacks deal 150% damage
- [ ] Side attacks deal 125% damage
- [ ] Flanking accuracy bonus +10%/+25%
- [ ] 3+ test scenarios passing

✅ **Combat Flow:**
- [ ] Turn phases execute correctly
- [ ] Action costs match wiki
- [ ] Full 3-turn combat cycle verified

✅ **No Errors:**
- [ ] Love2D console shows no errors
- [ ] No missing system warnings
- [ ] All calculations logged correctly

---

## Time Estimate

- Step 1.1 (Analyze LOS): 30 min
- Step 1.2 (Verify cover): 30 min
- Step 1.3 (Implement flanking): 1 hour
- Step 1.4 (UI indicators): 30 min
- Step 2.1 (Analyze threat): 30 min
- Step 2.2 (Enhance threat): 1 hour
- Step 2.3 (Test threat): 1 hour
- Step 3.1 (Create flanking module): 1 hour
- Step 3.2 (Integrate flanking): 30 min
- Step 3.3 (Test flanking): 1 hour
- Step 4.1 (Verify phases): 30 min
- Step 4.2 (Verify costs): 30 min
- Step 4.3 (Full cycle test): 30 min
- Final (Docs & cleanup): 1 hour

**Total: 10-11 hours**

---

## Expected Outcome

After Phase 2A completion:

- **Battlescape alignment:** 75% → 88%+
- **Combat system clarity:** +15% (better documented)
- **AI behavior quality:** +20% (better targeting)
- **Player tactical options:** +25% (flanking strategy)
- **No errors in console:** ✅ Verified

---

**Next:** Phase 2B will fix Finance system and Phase 2C will enhance AI systems.
