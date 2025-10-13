# Task: Weapon Modes System

**Status:** TODO  
**Priority:** High  
**Created:** October 13, 2025  
**Completed:** N/A  
**Assigned To:** AI Agent

---

## Overview

Implement weapon firing modes that modify weapon behavior: SNAP, AIM, LONG, AUTO, HEAVY, FINESSE. Each mode applies common modifiers to AP cost, EP cost, damage, accuracy, range, and bullets fired. All weapons have base stats plus a list of available modes.

---

## Purpose

Unlike X-COM UFO where each weapon has unique shot types with custom values, this system uses **common modifiers** that apply consistently across all weapons. This makes balancing easier and allows for interesting tactical choices without excessive data entry.

---

## Key Features (✅ = Implemented)

✅ **Six Weapon Modes:**
- SNAP: Quick shot (50% AP, 70% accuracy, 50% EP)
- AIM: Aimed shot (100% AP, 130% accuracy, 100% EP) 
- LONG: Long range (150% AP, 150% accuracy, 150% range, 120% EP)
- AUTO: Burst fire (200% AP, 60% accuracy per bullet, 5 bullets, 250% EP)
- HEAVY: Maximum damage (250% AP, 150% damage, 300% EP, +10% crit)
- FINESSE: Precision (120% AP, 70% damage, 180% accuracy, +15% crit, 80% EP)

✅ **Mode System:**
- All modifiers defined in `weapon_modes.lua`
- Weapons specify which modes they support
- Modes modify base weapon stats with multipliers
- Range, AP, EP, ammo requirements enforced

---

## Requirements

### Completed ✅
- [x] Create `weapon_modes.lua` module
- [x] Define all 6 modes with modifiers
- [x] Implement `applyMode()` function
- [x] Implement `canUseMode()` validation
- [x] Mode requirement checking

### Remaining TODO
- [ ] Integrate with shooting system
- [ ] Add mode selection UI
- [ ] Update weapon data files with available modes
- [ ] Add recoil accumulation system
- [ ] Create mode icons and visual feedback
- [ ] Test all modes with various weapons

---

## Implementation Status

**Core Module:** ✅ COMPLETE
- File: `engine/battlescape/combat/weapon_modes.lua` (369 lines)
- All 6 modes defined
- Validation system complete
- Apply modifiers function done

**Integration:** ⏳ PENDING
- Shooting system needs mode parameter
- UI needs mode selection buttons
- Weapon data needs mode availability
- Visual feedback needed

---

## Example Usage

```lua
local rifle = {
    name = "Assault Rifle",
    apCost = 6,
    epCost = 3,
    damage = 15,
    accuracy = 60,
    range = 12,
    currentAmmo = 30,
    availableModes = {snap = true, aim = true, auto = true}
}

-- SNAP: 3 AP, 2 EP, 15 damage, 42 accuracy
local snapStats = WeaponModes.applyMode(rifle, "snap")

-- AIM: 6 AP, 3 EP, 15 damage, 78 accuracy  
local aimStats = WeaponModes.applyMode(rifle, "aim")

-- AUTO: 12 AP, 8 EP, 12 damage/bullet, 36 accuracy, 5 bullets
local autoStats = WeaponModes.applyMode(rifle, "auto")
```

---

## Plan

### Step 1: Integrate with Shooting System
**Files to modify:**
- `engine/battlescape/combat/shooting_system.lua`
- Add mode parameter to `shoot()` function
- Apply mode modifiers before creating projectile
- Check mode requirements

**Estimated time:** 4 hours

### Step 2: Create Mode Selection UI
**Files:**
- `engine/battlescape/ui/weapon_mode_selector.lua` (NEW)
- Display available modes for selected weapon
- Show mode stats comparison
- Handle mode selection

**Estimated time:** 6 hours

### Step 3: Update Weapon Data
**Files:**
- `engine/mods/core/rules/item/weapons.toml`
- Add `availableModes` field to all weapons
- Example: `availableModes = ["snap", "aim", "auto"]`

**Estimated time:** 2 hours

### Step 4: Add Recoil System
**Files:**
- `engine/battlescape/combat/recoil_system.lua` (NEW)
- Track recoil accumulation per unit
- Apply accuracy penalty based on recoil
- Recoil decays over time

**Estimated time:** 4 hours

### Step 5: Visual Feedback
**Files:**
- Mode icons/sprites
- Firing animations per mode
- UI indicators for active mode

**Estimated time:** 3 hours

### Step 6: Testing
- Test each mode with various weapons
- Verify AP/EP costs
- Test accuracy modifiers
- Test burst fire (5 bullets)
- Verify range restrictions

**Estimated time:** 3 hours

---

## Tactical Implications

- **SNAP:** Reaction fire, multiple shots per turn
- **AIM:** Reliable damage, balanced choice
- **LONG:** Sniper shots, extended engagement range
- **AUTO:** Suppression, high damage output, ammo intensive
- **HEAVY:** Anti-armor, boss killing, resource intensive
- **FINESSE:** Weak point targeting, critical fishing

---

## Documentation Updates

- Add weapon modes section to API.md
- Explain mode system in FAQ.md
- Create mode selection tutorial
- Update weapon design guidelines

---

**Total Estimated Time:** 22 hours  
**Core Module:** ✅ COMPLETE  
**Integration:** ⏳ TODO (22 hours remaining)  
**Priority:** High (affects all combat)  
**Dependencies:** Shooting system, UI system, weapon data
