# Task: Comprehensive Psionics System

**Status:** TODO  
**Priority:** High  
**Created:** October 13, 2025  
**Completed:** N/A  
**Assigned To:** AI Agent

---

## Overview

Implement complete psionics system with 11+ mental abilities including damage infliction, terrain manipulation, mind control, unit buffs/debuffs, and environmental effects. Psionics provide tactical alternatives to conventional combat with unique strategic possibilities.

---

## Purpose

Add depth and variety to tactical combat through mental powers. Psionics allow units to:
- Attack without weapons or line of sight
- Manipulate terrain and environment
- Control enemy units
- Support allies with buffs
- Create tactical advantages through smoke/fire

---

## Key Features (✅ = Implemented)

✅ **11 Psionic Abilities:**

**Damage Abilities:**
- PSI DAMAGE: Direct mental attack (stun/hurt/morale/energy selectable)
- PSI CRITICAL: Next attack guaranteed crit (+25% damage)

**Terrain Manipulation:**
- DAMAGE TERRAIN: Destroy obstacles (50 power, 2 hex radius)
- UNCOVER TERRAIN: Reveal fog of war (5 hex radius, 3 turns)
- MOVE TERRAIN: Telekinesis on terrain tiles (up to 3 tiles movement)

**Environmental Effects:**
- CREATE FIRE: Pyrokinesis (intensity 3, spreads 30% chance)
- CREATE SMOKE: Generate obscuring smoke (3 hex radius, 4 turns)

**Object Manipulation:**
- MOVE OBJECT: Telekinesis on objects (50kg max, throw as weapon)

**Unit Control:**
- MIND CONTROL: Dominate enemy (3 turns, resistible, breaks on damage)
- SLOW UNIT: Reduce AP by 2 (2 turns, resistible)
- HASTE UNIT: Increase AP by 2 (2 turns, ally only)

✅ **System Features:**
- Psi skill requirements per ability
- Psi amp equipment requirement
- AP, EP, and psi energy costs
- Range and LOS requirements
- Resistance checks for hostile abilities
- Duration tracking for buffs/debuffs

---

## Requirements

### Completed ✅
- [x] Create `psionics_system.lua` module
- [x] Define all 11+ abilities with properties
- [x] Implement `canUseAbility()` validation
- [x] Implement `useAbility()` framework
- [x] Create ability execution stubs

### Remaining TODO
- [ ] Implement full ability execution logic
- [ ] Create psi energy resource system
- [ ] Add psi skill progression system
- [ ] Implement resistance checks
- [ ] Add visual effects for each ability
- [ ] Create psi amp equipment
- [ ] Add psi ability UI
- [ ] Implement mind control mechanics
- [ ] Add buff/debuff tracking system
- [ ] Test all abilities

---

## Implementation Status

**Core Module:** ✅ COMPLETE (Framework)
- File: `engine/battlescape/combat/psionics_system.lua` (594 lines)
- All 11 abilities defined
- Cost and range system complete
- Validation framework done
- Execution stubs in place

**Full Implementation:** ⏳ TODO (~60% done)
- Ability framework complete
- Individual ability logic needed
- Integration with game systems needed
- Visual feedback needed

---

## Ability Details

### Psi Damage (6 AP, 10 EP, 15 Psi)
- Range: 0-15 tiles, no LOS required
- Power: 20 base damage
- Can choose model: stun, hurt, morale, or energy
- 80% hit chance
- Requires: 30 psi skill, psi amp

### Mind Control (12 AP, 20 EP, 40 Psi)
- Range: 0-10 tiles, no LOS required
- Duration: 3 turns
- Target can resist with Will stat
- Breaks if caster takes damage
- Requires: 70 psi skill, psi amp
- **Most powerful and expensive ability**

### Haste/Slow (5-6 AP, 7-10 EP, 10-15 Psi)
- Range: 0-10/12 tiles, no LOS required
- ±2 AP per turn modifier
- Duration: 2 turns
- Slow can be resisted
- Requires: 35-40 psi skill, psi amp
- **Tactical modifiers**

### Create Fire/Smoke (4-5 AP, 5-8 EP, 8-12 Psi)
- Range: 0-10/12 tiles, LOS required
- Creates 3 hex radius effect
- Fire: intensity 3, 30% spread, 5+ turns
- Smoke: density 2, 4 turns
- Requires: 20-35 psi skill, psi amp
- **Environmental control**

---

## Plan

### Step 1: Implement Psi Energy System
**Files:**
- `engine/battlescape/systems/psi_energy_system.lua` (NEW)
- Add psi energy stat to units
- Regeneration 5 points per turn
- Max capacity based on psi skill

**Estimated time:** 4 hours

### Step 2: Complete Ability Execution Logic
**Files:**
- `engine/battlescape/combat/psionics_system.lua`
- Implement all 11 `execute*()` functions
- Integrate with damage, terrain, fire, smoke systems
- Add mind control tracking

**Estimated time:** 12 hours

### Step 3: Implement Resistance System
**Files:**
- `engine/battlescape/combat/psi_resistance.lua` (NEW)
- Will stat vs psi skill checks
- Resistance roll mechanics
- Feedback messages

**Estimated time:** 4 hours

### Step 4: Add Buff/Debuff System
**Files:**
- `engine/battlescape/systems/status_effects_system.lua` (NEW)
- Track active buffs/debuffs
- Apply modifiers to unit stats
- Handle duration and expiration
- Clean up on unit death

**Estimated time:** 6 hours

### Step 5: Create Psi Amp Equipment
**Files:**
- `engine/mods/core/rules/item/psi_amps.toml`
- Various psi amp types (basic, advanced, master)
- Amp provides: psi skill bonus, psi energy bonus, range bonus

**Estimated time:** 3 hours

### Step 6: Psi Ability UI
**Files:**
- `engine/battlescape/ui/psi_ability_panel.lua` (NEW)
- Display available abilities
- Show costs and requirements
- Target selection for abilities
- Ability activation

**Estimated time:** 8 hours

### Step 7: Visual Effects
**Files:**
- Create particle effects for each ability
- Mind control visual indicator
- Buff/debuff status icons
- Psi energy bar visualization

**Estimated time:** 6 hours

### Step 8: Psi Skill Progression
**Files:**
- `engine/battlescape/systems/psi_progression.lua` (NEW)
- Psi skill XP system
- Unlock abilities at thresholds
- Practice improves skill

**Estimated time:** 4 hours

### Step 9: Testing
- Test all 11 abilities
- Verify costs and ranges
- Test resistance checks
- Verify buff/debuff stacking
- Test mind control edge cases

**Estimated time:** 5 hours

---

## Tactical Usage Examples

### Offensive Psionics
```
Scenario: High-armor enemy
1. Use PSI DAMAGE (morale) to panic enemy
2. While panicked, use conventional weapons
3. If not panicked, use PSI CRITICAL → HEAVY shot combo
```

### Support Psionics
```
Scenario: Friendly unit pinned down
1. CREATE SMOKE to obscure enemy vision
2. HASTE ally to give +2 AP for retreat
3. UNCOVER TERRAIN to reveal enemy positions
```

### Environmental Control
```
Scenario: Chokepoint defense
1. CREATE FIRE at chokepoint entrance
2. DAMAGE TERRAIN to block path
3. CREATE SMOKE to deny enemy vision
```

### Mind Control
```
Scenario: Elite enemy unit
1. MIND CONTROL enemy (costs 40 psi energy)
2. Use controlled unit to attack their allies
3. Position controlled unit dangerously before control expires
```

---

## Balance Considerations

- **Psi Energy as Limiting Resource:** Prevents spam
- **High AP/EP Costs:** Competes with conventional actions
- **Skill Requirements:** Progression gate
- **Psi Amp Requirement:** Equipment investment
- **Resistance Checks:** Counterplay for enemies
- **Duration Limits:** Prevents permanent control
- **Range Limits:** Positioning still matters

---

## Documentation Updates

- Add psionics system to API.md
- Create psionic abilities guide in FAQ.md
- Add psi progression guide
- Document resistance mechanics
- Create tactical psionics tutorial

---

**Total Estimated Time:** 52 hours  
**Core Module:** ✅ 40% COMPLETE  
**Remaining Work:** ⏳ 52 hours  
**Priority:** High (adds major gameplay dimension)  
**Dependencies:** Damage system, terrain system, fire/smoke systems, UI system
