# Task: Damage Models System Integration

**Status:** TODO  
**Priority:** Critical  
**Created:** October 13, 2025  
**Completed:** N/A  
**Assigned To:** AI Agent

---

## Overview

Implement complete damage model system that defines how damage is distributed to unit stats AFTER armor calculation. Four models: STUN (temporary damage), HURT (permanent health), MORALE (psychological), ENERGY (stamina drain). This replaces the old ratio-based system with a proper model-based approach.

---

## Purpose

**Current Issue:**
- Damage distribution uses hardcoded ratios (75% health, 25% stun)
- No distinction between lethal and non-lethal damage
- No recovery mechanics for different damage types
- Terminology confusion: "damageType" used for both method (point/area) and type (kinetic/laser)

**Solution:**
- Rename "damageType" → "damageMethod" (POINT or AREA)
- Keep "damageType" for armor resistance (kinetic, plasma, laser, etc)
- Add "damageModel" for distribution (stun, hurt, morale, energy)
- Each model has unique distribution and recovery mechanics

---

## Requirements

### Functional Requirements
- [ ] Four damage models: stun, hurt, morale, energy
- [ ] Each model defines distribution to health/stun/morale/energy pools
- [ ] Stun model: 100% stun, recovers 2/turn, non-lethal
- [ ] Hurt model: 75% health, 25% stun, can kill
- [ ] Morale model: 100% morale, recovers 5/turn, causes panic
- [ ] Energy model: 80% energy, 20% stun, recovers 3/turn
- [ ] Models define if they can kill units
- [ ] Models define morale impact severity
- [ ] Recovery rates applied per turn

### Technical Requirements
- [ ] Create `damage_models.lua` module ✅ (DONE)
- [ ] Update terminology in projectile.lua ✅ (DONE)
- [ ] Integrate with damage_system.lua ✅ (DONE)
- [ ] Update projectile_system.lua to pass damageModel
- [ ] Add recovery system in turn manager
- [ ] Update all weapon definitions to specify model

### Acceptance Criteria
- [ ] Stun weapon (100 damage) → 100 stun, 0 health, 10 morale
- [ ] Rifle (100 damage) → 75 health, 25 stun, morale loss
- [ ] Fear gas (100 damage) → 100 morale, 0 health/stun
- [ ] Energy drain (100 damage) → 80 energy, 20 stun
- [ ] Stun recovers 2 points per turn automatically
- [ ] Morale recovers 5 points per turn automatically
- [ ] Energy recovers 3 points per turn automatically
- [ ] Health does NOT recover automatically

---

## Plan

### Step 1: Update Projectile System Terminology ✅ DONE
**Files:**
- `engine/battlescape/entities/projectile.lua` ✅
- `engine/battlescape/combat/projectile_system.lua`

### Step 2: Create Damage Models Module ✅ DONE
**File:**
- `engine/battlescape/combat/damage_models.lua` ✅

### Step 3: Integrate with Damage System ✅ DONE
**File:**
- `engine/battlescape/combat/damage_system.lua` ✅

### Step 4: Implement Recovery System
**Files:**
- `engine/battlescape/logic/turn_manager.lua`
- Add `processRecovery()` function
- Call at start of each unit's turn

**Estimated time:** 3 hours

### Step 5: Update Weapon Definitions
**Files:**
- `engine/mods/core/rules/item/weapons.toml`
- Add `damageModel` field to all weapons
- Add `damageMethod` field (POINT/AREA)
- Keep `damageType` for armor resistance

**Estimated time:** 2 hours

### Step 6: Update UI Display
**Files:**
- Weapon info panels
- Damage indicators
- Unit status display

**Estimated time:** 2 hours

### Step 7: Testing
- Test all four damage models
- Verify recovery rates
- Test model combinations
- Verify lethality flags

**Estimated time:** 2 hours

---

## Implementation Details

### Damage Model Distribution

```lua
STUN = {
    health: 0%,
    stun: 100%,
    morale: 10%,
    energy: 0%
    -- Can't kill, causes unconsciousness, recovers 2/turn
}

HURT = {
    health: 75%,
    stun: 25%,
    morale: 0%,
    energy: 0%
    -- Can kill, no recovery
}

MORALE = {
    health: 0%,
    stun: 0%,
    morale: 100%,
    energy: 0%
    -- Can't kill, causes panic, recovers 5/turn
}

ENERGY = {
    health: 0%,
    stun: 20%,
    morale: 0%,
    energy: 80%
    -- Can't kill, causes exhaustion, recovers 3/turn
}
```

### Example Weapons

```toml
# Stun Rod (non-lethal)
[[weapon]]
name = "Stun Rod"
damage = 50
damageType = "stun"      # Armor resistance type
damageModel = "stun"     # Distribution model
damageMethod = "point"   # Point vs area

# Assault Rifle (lethal)
[[weapon]]
name = "Assault Rifle"
damage = 20
damageType = "kinetic"
damageModel = "hurt"
damageMethod = "point"

# Fear Gas Grenade
[[weapon]]
name = "Fear Gas"
damage = 30
damageType = "bio"
damageModel = "morale"
damageMethod = "area"
dropoff = 3

# Exhaustion Ray
[[weapon]]
name = "Exhaustion Ray"
damage = 40
damageType = "energy"
damageModel = "energy"
damageMethod = "point"
```

---

## Testing Strategy

1. Create test units with known stats
2. Apply each damage model
3. Verify correct distribution
4. Test recovery over multiple turns
5. Verify lethality flags
6. Test model combinations

---

## Documentation Updates

- Update API.md with damage model system
- Update FAQ.md with damage model explanations
- Add examples to weapon creation guide

---

**Total Estimated Time:** 15 hours  
**Priority:** Critical (blocks weapon balancing)  
**Dependencies:** Damage system, projectile system

**Status:** Partially implemented (core modules done, integration pending)
