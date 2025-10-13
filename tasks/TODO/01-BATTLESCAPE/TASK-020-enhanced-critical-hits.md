# Task: Enhanced Critical Hit System

**Status:** TODO  
**Priority:** Medium  
**Created:** October 13, 2025  
**Completed:** N/A  
**Assigned To:** AI Agent

---

## Overview

Enhance critical hit system with weapon-specific crit chance + unit class crit bonus. Critical hits inflict wounds that cause 1 HP bleeding per turn, which is significant for units with 6-12 HP. This creates high-risk damage over time that can kill units even with low initial damage.

---

## Purpose

**Current System:**
- Fixed 10% crit chance for all attacks
- Crits deal +50% damage and apply 1 wound
- No weapon or class differentiation

**Enhanced System:**
- Base 5% crit chance
- Weapons add crit chance (e.g., sniper rifle +15%)
- Unit classes add crit bonus (e.g., assassin +10%)
- Total = base + weapon + class
- Wounds still cause 1 HP/turn bleeding
- Multiple wounds stack (3 wounds = 3 HP/turn)

**Impact:**
- With 10 HP unit, 3 wounds = death in ~3 turns
- Encourages critical-focused builds
- Makes precision weapons valuable
- Rewards skilled unit classes

---

## Requirements

### Functional Requirements
- [ ] Base crit chance: 5%
- [ ] Weapons specify `critChance` field (0.0 to 0.5)
- [ ] Units specify `critBonus` field (0.0 to 0.2)
- [ ] Total crit = base + weapon + class
- [ ] Critical hits still apply wounds
- [ ] Wounds stack (tracked per unit)
- [ ] 1 wound = 1 HP bleed per turn
- [ ] Display wound count in UI
- [ ] Visual indicator for high wound count

### Technical Requirements
- [x] Update `DamageSystem:rollCriticalHit()` ✅ DONE
- [ ] Add weapon data: `critChance` field
- [ ] Add unit class data: `critBonus` field
- [ ] Track wound count per unit
- [ ] Apply bleeding at turn start
- [ ] Death from bleeding properly logged

### Acceptance Criteria
- [ ] Unarmed attack: 5% crit (base only)
- [ ] Sniper rifle (+15% crit): 20% total crit
- [ ] Assassin class (+10% crit) with sniper: 30% total crit
- [ ] FINESSE mode (+15% crit): 35% with assassin + sniper
- [ ] Unit with 3 wounds loses 3 HP per turn
- [ ] 10 HP unit with 3 wounds dies in ~3 turns

---

## Implementation Status

**Core Logic:** ✅ COMPLETE
- File: `engine/battlescape/combat/damage_system.lua`
- Function: `rollCriticalHit(weapon, attacker)` ✅
- Calculates base + weapon + class bonus
- Proper debug logging

**Remaining:** ⏳ TODO
- Weapon data updates
- Unit class data
- UI display
- Testing

---

## Example Calculations

### Standard Attack
```
Rifle (no crit bonus) + Soldier (no crit bonus)
= 5% base crit chance
```

### Precision Weapon
```
Sniper Rifle (+15% crit) + Soldier (no bonus)
= 5% + 15% = 20% crit chance
```

### Skilled Combatant
```
Rifle (no bonus) + Assassin (+10% crit)
= 5% + 10% = 15% crit chance
```

### Precision Build
```
Sniper Rifle (+15%) + Assassin (+10%)
= 5% + 15% + 10% = 30% crit chance
```

### Ultimate Precision
```
Sniper Rifle (+15%) + Assassin (+10%) + FINESSE mode (+15%)
= 5% + 15% + 10% + 15% = 45% crit chance
```

---

## Wound Lethality Examples

### 10 HP Unit
- **1 wound:** 10 turns to death
- **2 wounds:** 5 turns to death
- **3 wounds:** 3.3 turns to death ⚠️
- **4 wounds:** 2.5 turns to death ☠️

### 12 HP Unit (Tougher)
- **1 wound:** 12 turns to death
- **2 wounds:** 6 turns to death
- **3 wounds:** 4 turns to death ⚠️
- **4 wounds:** 3 turns to death ☠️

### 6 HP Unit (Weak)
- **1 wound:** 6 turns to death
- **2 wounds:** 3 turns to death ⚠️
- **3 wounds:** 2 turns to death ☠️

**Key Insight:** Multiple wounds are devastating. 3+ wounds is effectively a death sentence unless medically treated.

---

## Plan

### Step 1: Update Weapon Data ✅ (Core done, data TODO)
**Files:**
- `engine/mods/core/rules/item/weapons.toml`

**Weapon crit values:**
```toml
# Precision weapons
[weapon.sniper_rifle]
critChance = 0.15  # +15%

[weapon.pistol]
critChance = 0.08  # +8%

# Standard weapons
[weapon.assault_rifle]
critChance = 0.05  # +5%

# Spray weapons
[weapon.shotgun]
critChance = 0.02  # +2%

# Melee weapons
[weapon.knife]
critChance = 0.12  # +12% (stabbing weak points)
```

**Estimated time:** 2 hours

### Step 2: Add Unit Class Crit Bonuses
**Files:**
- `engine/mods/core/rules/unit/classes.toml` (NEW)

**Class crit values:**
```toml
[class.soldier]
critBonus = 0.00  # No bonus

[class.assassin]
critBonus = 0.10  # +10%

[class.marksman]
critBonus = 0.08  # +8%

[class.heavy]
critBonus = 0.02  # +2%
```

**Estimated time:** 2 hours

### Step 3: Enhanced Wound Tracking
**Files:**
- `engine/battlescape/combat/damage_system.lua`

**Add:**
- `unit.wounds` array with source tracking
- `getWoundCount()` function
- `getBleedingDamage()` function

**Estimated time:** 2 hours

### Step 4: Wound Display UI
**Files:**
- `engine/battlescape/ui/unit_status_panel.lua`

**Display:**
- Wound count icon + number
- Bleed rate per turn
- Visual warning at 3+ wounds
- Color coding (1-2 yellow, 3+ red)

**Estimated time:** 3 hours

### Step 5: Bleeding Combat Log
**Files:**
- `engine/battlescape/logic/combat_log.lua`

**Messages:**
- "Unit X bleeds for Y damage (Z wounds)"
- "Unit X died from bleeding"
- Critical hit notifications with wound info

**Estimated time:** 2 hours

### Step 6: Medical Treatment (Optional)
**Files:**
- `engine/battlescape/items/medkit.lua`

**Add ability to:**
- Stabilize wounds (stop bleeding)
- Reduce wound count
- Requires medkit item + AP

**Estimated time:** 4 hours (optional)

### Step 7: Testing
- Test crit calculations with various combos
- Verify wound stacking
- Test bleeding damage over turns
- Verify death from bleeding
- Test extreme crit chance (45%+)

**Estimated time:** 2 hours

---

## Weapon Archetype Design

### Precision Weapons (High Crit)
- Sniper Rifle: 15% crit, long range, high damage
- Pistol: 8% crit, medium range, low damage
- Knife: 12% crit, melee, medium damage
- **Strategy:** Critical-focused builds, assassinations

### Standard Weapons (Medium Crit)
- Assault Rifle: 5% crit, medium range, medium damage
- Shotgun: 2% crit, short range, high damage
- SMG: 3% crit, short range, rapid fire
- **Strategy:** Balanced damage output

### Heavy Weapons (Low Crit)
- Rocket Launcher: 0% crit, long range, explosive
- Machine Gun: 1% crit, medium range, suppression
- Flamethrower: 0% crit, short range, area effect
- **Strategy:** Raw damage, crowd control

---

## Unit Class Archetypes

### Assassin (High Crit)
- +10% crit bonus
- High accuracy
- Bonus with precision weapons
- **Role:** Single-target elimination

### Marksman (Medium Crit)
- +8% crit bonus
- Very high accuracy
- Range bonuses
- **Role:** Long-range precision

### Soldier (No Crit)
- 0% crit bonus
- Balanced stats
- Reliable damage
- **Role:** Versatile combatant

### Heavy (Low Crit)
- +2% crit bonus
- High HP
- Weapon handling bonuses
- **Role:** Tank/support

---

## Documentation Updates

- Update damage system API with crit mechanics
- Add wound system guide to FAQ.md
- Create critical hit build guide
- Document weapon crit values
- Add class crit bonus reference

---

**Total Estimated Time:** 17 hours (13h without medical treatment)  
**Core Logic:** ✅ COMPLETE  
**Remaining Work:** ⏳ 13-17 hours  
**Priority:** Medium (enhances combat depth)  
**Dependencies:** Damage system, weapon data, unit classes
