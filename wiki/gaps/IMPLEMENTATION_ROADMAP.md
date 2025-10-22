# Phase 2 Implementation Roadmap

**Date:** October 22, 2025  
**Status:** Planning Phase  
**Objective:** Implement gap analysis specifications into codebase

---

## Executive Summary

Based on the completed gap analysis, this document outlines the implementation strategy for 4 critical systems that have been designed but require code implementation or verification:

1. **Concealment Detection System** (Battlescape)
2. **Item Durability System** (Assets/Items)
3. **Thermal/Heat Mechanics** (Interception)
4. **Fame/Karma Systems** (Politics)

---

## Current Code Status

### ✅ Systems That Already Exist
- **Line of Sight System** (`engine/battlescape/systems/line_of_sight.lua`) - Partial concealment support exists
- **Fame System** (`engine/politics/fame/`) - Folder exists, needs verification
- **Karma System** (`engine/politics/karma/`) - Folder exists, needs verification
- **Cover System** (`engine/battlescape/systems/cover_system.lua`) - Related to concealment
- **Combat Mechanics** (`engine/battlescape/systems/combat_mechanics.lua`) - Hit chance handling

### ⚠️ Systems Needing Implementation
- **Concealment Detection Formula** - Needs full formula implementation in LOS system
- **Item Durability Tracking** - New module needed or extension to existing items
- **Thermal/Heat System** (`engine/interception/`) - Needs new thermal_system.lua
- **Fame Effects Integration** - Need to verify functions exist and wire to other systems
- **Karma Effects Integration** - Need to verify functions exist and wire to other systems

---

## Implementation Priority & Effort Matrix

| System | Priority | Effort | Status | Dependencies |
|--------|----------|--------|--------|--------------|
| Concealment Detection | HIGH | MEDIUM | Not Started | LOS System exists |
| Item Durability | MEDIUM | MEDIUM | Not Started | Item system needs review |
| Thermal Mechanics | HIGH | MEDIUM | Not Started | Combat mechanics exist |
| Fame/Karma Integration | MEDIUM | LOW | Needs Verification | Systems exist |

---

## Phase 2: Detailed Implementation Plan

### 1. CONCEALMENT DETECTION SYSTEM
**Location:** `engine/battlescape/systems/concealment_detection.lua` (new file)  
**Based On:** Battlescape gap analysis specifications

#### Specification Reference
```
Detection Formula:
detection_chance = base_detection_rate × distance_modifier × (1 - concealment_level) × 
                   light_modifier × unit_size_modifier × noise_modifier

Detection Ranges:
- Day: 25 hexes
- Dusk: 15 hexes
- Night: 8 hexes
- Stealth: 3 hexes

Concealment Sources:
- Terrain: +0.2
- Combat Cover: +0.3
- Stealth Ability: +0.4-0.5
- Smoke: +0.4-0.8

Sight Point Costs:
- Move: 1-3 points
- Fire: 5-10 points
- Ability: 3-5 points
- Throw: 2-3 points
```

#### Implementation Steps
1. Create `concealment_detection.lua` module
2. Define detection formula function with all weighted components
3. Implement concealment tracking per unit (current level, regain timer)
4. Add concealment break conditions (movement, firing, etc.)
5. Integrate with existing LOS system
6. Add sight point cost calculations
7. Document all functions with LuaDoc comments

#### Functions to Implement
```lua
ConcealmentDetection.new(battle_system)
ConcealmentDetection:calculateDetectionChance(observer, target)
ConcealmentDetection:getConcealmentLevel(unit)
ConcealmentDetection:addConcealmentBreak(unit, duration)
ConcealmentDetection:applySightPointCost(observer, action_type)
ConcealmentDetection:getDetectionRange(visibility_type)
ConcealmentDetection:getEnvironmentalModifier(position)
```

#### Integration Points
- **LOS System:** Add concealment check to hasLineOfSight()
- **Combat Mechanics:** Apply sight point costs on actions
- **Unit Movement:** Break concealment on movement
- **Environmental System:** Light/time of day modifiers
- **Cover System:** Combine concealment with cover

#### Testing Requirements
- Unit concealment persists across turns
- Detection formula produces 5-95% range (clamped correctly)
- Sight point costs deducted from unit AP when firing
- Concealment breaks and regains on proper conditions
- Environmental factors (day/night) apply correctly

---

### 2. ITEM DURABILITY SYSTEM
**Location:** `engine/assets/durability_system.lua` (new file) or extend existing items  
**Based On:** Items gap analysis specifications

#### Specification Reference
```
Durability Scale: 0-100

Condition Stages:
- Pristine (100-75%): Full effectiveness
- Worn (74-50%): No penalty
- Damaged (49-25%): -10% effectiveness
- Critical (24-1%): -30% effectiveness
- Destroyed (0%): Non-functional

Degradation Rates:
- Weapons: -5 per mission
- Armor: -3 per hit taken
- Equipment: -2 per mission

Repair Mechanics:
- Cost: 1% of base item cost per point
- Time: 1 day per 10 points at base
- Requirements: Base workshop or marketplace
```

#### Implementation Steps
1. Create `durability_system.lua` module
2. Define ItemDurability class/table
3. Implement condition calculation from durability value
4. Add degradation functions for different item types
5. Implement repair cost and time calculation
6. Create effectiveness penalty modifier
7. Integrate with combat system (armor takes damage on hits)
8. Integrate with mission system (weapons degrade per mission)

#### Functions to Implement
```lua
DurabilitySystem.new()
DurabilitySystem:addItem(item_id, item_definition)
DurabilitySystem:getDurability(item_id)
DurabilitySystem:getCondition(item_id)  -- returns "pristine", "worn", etc.
DurabilitySystem:applyDamage(item_id, damage_amount)
DurabilitySystem:repairItem(item_id, repair_amount)
DurabilitySystem:getEffectivenessPenalty(item_id)  -- returns 0.0 to -0.30
DurabilitySystem:processPostMissionDegradation(item_id, item_type)
```

#### Integration Points
- **Combat System:** Apply durability loss to armor on hits
- **Inventory System:** Track durability in item stacks
- **Mission System:** Apply weapon degradation post-mission
- **UI System:** Display condition status
- **Workshop System:** Calculate repair costs

#### Testing Requirements
- Durability decreases correctly per mission/hit
- Condition stages calculate properly from durability value
- Repair costs calculated (% of base cost)
- Effectiveness penalties apply (-10% at 25-49%, -30% at 1-24%)
- Items destroyed at 0 durability (unusable)
- No errors when repairing items

---

### 3. THERMAL/HEAT MECHANICS (INTERCEPTION)
**Location:** `engine/interception/logic/thermal_system.lua` (new file)  
**Based On:** Interception gap analysis specifications

#### Specification Reference
```
Heat System:
- Heat Generation: +5 to +20 per action
- Heat Dissipation: -5 to -15 per turn (unit-dependent)
- Jam Threshold: 100+ heat causes jam
- Accuracy Penalty: -10% at 50+ heat
- Overheat Threshold: 150+ = forced cooldown

Heat Sources:
- Weapon Fire: +10-20 per action
- Engine Boost: +15 per turn
- Shields Active: +5 per turn
- Sustained Beam: +5 per turn continuous

Heat Dissipation:
- Passive (idle): -5 to -10 per turn
- Active Radiators: -15 per turn
- Cooldown Mode: -20 per turn (can't attack)
```

#### Implementation Steps
1. Create `thermal_system.lua` module
2. Define thermal/heat state tracking per craft
3. Implement heat generation function with sources
4. Implement heat dissipation rates
5. Calculate jam state and accuracy penalties
6. Implement overheat detection and forced cooldown
7. Add thermal effects to combat resolution
8. Create thermal state UI updates

#### Functions to Implement
```lua
ThermalSystem.new(interception_system)
ThermalSystem:addHeat(craft_id, amount, source)
ThermalSystem:dissipateHeat(craft_id, rate)
ThermalSystem:getHeatLevel(craft_id)
ThermalSystem:isJammed(craft_id)
ThermalSystem:getAccuracyModifier(craft_id)  -- returns penalty -0.10 to 0
ThermalSystem:getHeatPercent(craft_id)  -- returns 0.0 to 1.0
ThermalSystem:processHeatPhase(craft_id)  -- called each turn
ThermalSystem:canAttack(craft_id)  -- false if jammed
```

#### Integration Points
- **Combat Resolution:** Add heat effects to accuracy/jam
- **Action System:** Add heat generation to weapon actions
- **Turn System:** Process heat dissipation each turn
- **UI System:** Display thermal status and heat bar
- **Craft System:** Reference heat specs in craft data

#### Testing Requirements
- Heat accumulates correctly (+5 to +20 per action)
- Heat dissipates each turn (-5 to -15 baseline)
- Jam occurs at 100+ heat
- Accuracy penalty applies at 50+ heat
- Cooldown mode clears heat faster (-20/turn)
- UI updates show thermal status correctly

---

### 4. FAME/KARMA SYSTEMS VERIFICATION
**Location:** `engine/politics/fame/` and `engine/politics/karma/`  
**Based On:** Politics gap analysis specifications

#### Current Status
- **Fame System:** `engine/politics/fame/fame_system.lua` exists
- **Karma System:** `engine/politics/karma/karma_system.lua` exists
- **Need:** Verify they match API/Systems specifications

#### Verification Checklist
```
FAME SYSTEM:
  ✓ Properties: current_fame (0-100), fame_tier, decay
  ✓ Functions: getFame(), getFameTier(), addFame()
  ✓ Effects: Mission gen bonus, recruitment bonus, funding multiplier
  ✓ Sources: Mission success, UFO destroyed, black market discovery, etc.
  ? Mission Generation Bonus: 0-30% implemented?
  ? Recruitment Bonus: 0-45% implemented?
  ? Funding Multiplier: 1.0-1.50× implemented?
  ? Monthly decay: -1 to -2 per month working?

KARMA SYSTEM:
  ✓ Properties: current_karma (-100 to +100), alignment, hidden
  ✓ Functions: getKarma(), getAlignment(), recordAction()
  ✓ Effects: Access gating, supplier preferences, story branches
  ✓ Sources: Civilian casualty, prisoner handling, black market, etc.
  ? Alignment calculation: Evil/Ruthless/etc. determined correctly?
  ? Access gating: Black market blocked at karma > -40?
  ? Humanitarian access: Blocked at karma < +10?
  ? Story branching: Multiple endings accessible?
  ? Hidden mechanic: Not visible to player?
```

#### Implementation Steps (If Needed)
1. Read existing fame_system.lua and verify against specs
2. Read existing karma_system.lua and verify against specs
3. Identify missing functions or properties
4. Add missing implementations
5. Wire effects into other systems (missions, recruitment, suppliers)
6. Test all access gates and effects
7. Verify hidden status of karma

#### Functions to Verify
```lua
-- FAME
Fame.getFame() → number (0-100)
Fame.getFameTier() → string
Fame.addFame(delta, reason) → void
Fame.getMissionGenerationBonus() → number (0.0-0.30)
Fame.getRecruitmentQualityBonus() → number (0.0-0.45)
Fame.getFundingMultiplier() → number (1.0-1.50)
Fame.processMonthlyDecay() → void

-- KARMA
Karma.getKarma() → number (-100 to +100)
Karma.getAlignment() → string
Karma.recordAction(action_type, context) → void
Karma.canAccessBlackMarket() → boolean
Karma.canAccessHumanitarianMissions() → boolean
Karma.getStoryBranchPath() → string
```

#### Testing Requirements
- Fame ranges 0-100 correctly
- Karma ranges -100 to +100 correctly
- Tier effects apply (mission gen, recruitment, funding)
- Alignment alignment calculated from karma value
- Access gates work (black market at karma < -40, etc.)
- Story branching accessible based on karma
- Karma never visible to player in UI

---

## Implementation Sequence

### Week 1-2: Foundation
1. **Concealment Detection** (Priority: HIGH)
   - Implement formula and basic detection
   - Integrate with LOS system
   - Test formula produces correct ranges

2. **Thermal Mechanics** (Priority: HIGH)
   - Implement heat generation/dissipation
   - Integrate with combat resolution
   - Test heat accumulation and jam mechanic

### Week 3: Secondary Systems
3. **Item Durability** (Priority: MEDIUM)
   - Implement durability tracking
   - Wire to combat system (armor damage)
   - Test degradation and repair

4. **Fame/Karma Verification** (Priority: MEDIUM)
   - Review existing implementations
   - Add missing functions
   - Wire effects into systems

### Week 4: Integration & Testing
5. **System Integration** (Priority: HIGH)
   - Ensure all systems interact correctly
   - Fix any conflicts or issues
   - Run comprehensive tests

6. **Love2D Console Testing** (Priority: HIGH)
   - Run `lovec "engine"` with all systems active
   - Check for errors/warnings
   - Verify proper initialization

---

## Development Standards

### Code Quality
- ✅ All functions must have LuaDoc comments
- ✅ Module must have header documentation
- ✅ Error handling with meaningful messages
- ✅ Print debug statements for initialization

### Testing
- ✅ Test each function individually
- ✅ Test integration with related systems
- ✅ Run full game with Love2D console
- ✅ Check for errors and warnings

### Documentation
- ✅ Update wiki/systems/ with implementation notes
- ✅ Update wiki/api/ with actual function signatures
- ✅ Document integration points clearly
- ✅ Add examples for complex functions

---

## Success Criteria

### Concealment Detection
- ✅ Detection formula implemented and tested
- ✅ Sight point costs apply correctly
- ✅ Concealment regain works properly
- ✅ Environmental factors apply correctly
- ✅ No console errors

### Thermal Mechanics
- ✅ Heat generation and dissipation working
- ✅ Jam mechanic triggers at correct threshold
- ✅ Accuracy penalties apply correctly
- ✅ Cooldown mode functions properly
- ✅ UI shows thermal status

### Item Durability
- ✅ Durability tracks correctly
- ✅ Condition stages calculate properly
- ✅ Repair costs calculated correctly
- ✅ Effectiveness penalties apply
- ✅ Items degrade post-mission

### Fame/Karma
- ✅ All functions implemented and working
- ✅ Effects wire to other systems
- ✅ Access gates work correctly
- ✅ Alignment calculation accurate
- ✅ Karma remains hidden from UI

---

## Timeline

| Phase | Task | Duration | Status |
|-------|------|----------|--------|
| Planning | Analyze code structure | 1 day | ✅ DONE |
| Implementation | Concealment Detection | 3 days | Not Started |
| Implementation | Thermal Mechanics | 3 days | Not Started |
| Implementation | Item Durability | 3 days | Not Started |
| Verification | Fame/Karma Check | 2 days | Not Started |
| Integration | System Integration | 2 days | Not Started |
| Testing | Full Testing & Debug | 2 days | Not Started |
| **TOTAL** | | **16 days** | **In Progress** |

---

## Next Steps

1. **Start with Concealment Detection** (highest priority, medium complexity)
2. **Read existing LOS system** to understand integration points
3. **Implement detection formula** with all weighted components
4. **Test with Love2D console** to verify no errors
5. **Document progress** in implementation notes

Ready to begin? Let's start with **Concealment Detection System implementation**.

---

**Document Version:** 1.0  
**Last Updated:** October 22, 2025  
**Status:** READY FOR IMPLEMENTATION
