# Task: Damage Resolution System

**Status:** TODO  
**Priority:** High  
**Created:** October 13, 2025  
**Completed:** N/A  
**Assigned To:** AI Agent

---

## Overview

Implement the damage resolution system that calculates actual damage from weapon power, applies armor resistance by damage type, subtracts armor value, distributes damage across health/stun/morale/energy pools, and handles secondary effects like wounds and morale loss.

---

## Purpose

This is the core damage calculation engine. When a projectile hits, we need to:
1. Calculate effective weapon power (resistance modifier)
2. Subtract armor value
3. Distribute damage to appropriate pools (health, stun, morale, energy)
4. Apply secondary effects (morale loss from wounds, critical hits)
5. Check for unit death/unconsciousness

---

## Requirements

### Functional Requirements
- [ ] Calculate damage type resistance from armor
- [ ] Apply resistance as percentage modifier to weapon power
- [ ] Subtract armor value from modified power
- [ ] Distribute final damage to health/stun/morale/energy based on weapon ratios
- [ ] Track wounds from critical hits (causes bleeding 1HP per turn)
- [ ] Morale loss from taking damage
- [ ] Morale loss from witnessing deaths
- [ ] Bravery/Will checks to avoid morale loss
- [ ] Unit death when health reaches 0
- [ ] Unit unconsciousness when morale/stun reaches threshold

### Technical Requirements
- [ ] Create DamageSystem module in `engine/battlescape/combat/`
- [ ] Damage type enumeration (kinetic, explosive, laser, melee, bio, acid, stun, fire, psi)
- [ ] Armor resistance table per damage type
- [ ] Damage distribution ratios (health %, stun %, morale %, energy %)
- [ ] Critical hit system with wound tracking
- [ ] Morale system integration
- [ ] Bleeding effect tracking (wounds cause HP loss per turn)

### Acceptance Criteria
- [ ] Weapon power correctly modified by armor resistance
- [ ] Armor value properly subtracted from damage
- [ ] Damage distributed to correct pools based on weapon ratios
- [ ] Example: Pistol (power=5, kinetic) vs Medium Armor (resistance=50%, armor=2)
  - Effective power = 5 / 0.5 = 10
  - After armor = 10 - 2 = 8 damage
  - If 75% health, 25% stun: 6 HP damage, 2 stun damage
- [ ] Critical hits apply wound effect
- [ ] Morale checks occur on damage
- [ ] Console shows detailed damage breakdown for debugging
- [ ] System works with Love2D console enabled (`lovec "engine"`)

---

## Plan

### Step 1: Create Damage Type System
**Description:** Define damage types and resistance mappings  
**Files to modify/create:**
- `engine/battlescape/combat/damage_types.lua` - Damage type constants
- `engine/mods/new/rules/item/armours.toml` - Add resistance values
- `engine/mods/new/rules/item/weapons.toml` - Add damage type field

**Estimated time:** 2 hours

### Step 2: Implement Core Damage Calculation
**Description:** Calculate effective damage from power, resistance, and armor  
**Files to modify/create:**
- `engine/battlescape/combat/damage_system.lua` - Core damage calculation
- `engine/systems/unit.lua` - Update takeDamage() method

**Estimated time:** 3 hours

### Step 3: Add Damage Distribution
**Description:** Split damage across health/stun/morale/energy pools  
**Files to modify/create:**
- `engine/battlescape/combat/damage_system.lua` - Add distribution logic
- `engine/systems/unit.lua` - Add stun, morale damage methods

**Estimated time:** 2 hours

### Step 4: Implement Critical Hit and Wounds
**Description:** Critical hits cause wounds (bleeding effect)  
**Files to modify/create:**
- `engine/battlescape/combat/damage_system.lua` - Critical hit calculation
- `engine/systems/unit.lua` - Add wound tracking, bleeding damage
- `engine/battlescape/logic/turn_manager.lua` - Apply bleeding at turn start

**Estimated time:** 3 hours

### Step 5: Implement Morale System
**Description:** Morale loss from damage and witnessing deaths  
**Files to modify/create:**
- `engine/battlescape/combat/morale_system.lua` - Morale calculations
- `engine/systems/unit.lua` - Add morale stat, bravery checks
- `engine/battlescape/combat/damage_system.lua` - Trigger morale checks

**Estimated time:** 3 hours

### Step 6: Integrate with Projectile System
**Description:** Connect damage resolution to projectile impacts  
**Files to modify/create:**
- `engine/battlescape/combat/projectile_system.lua` - Call damage system on impact
- `engine/battlescape/combat/damage_system.lua` - Provide public API

**Estimated time:** 2 hours

### Step 7: Testing
**Description:** Verify damage calculations with all modifiers  
**Test cases:**
- Basic damage vs no armor
- Damage with armor resistance
- Damage with armor value
- Damage distribution to multiple pools
- Critical hit causes wound
- Morale loss from damage
- Morale loss from witnessing death
- Unit death at 0 HP
- Bleeding damage over time

**Estimated time:** 3 hours

---

## Implementation Details

### Architecture

**Damage Calculation Flow:**
```
1. Projectile hits → DamageSystem.resolveDamage(projectile, target)
2. Get weapon power and damage type
3. Get target armor resistance for that damage type
4. Calculate: effectivePower = power / resistance
   Example: power=5, resistance=0.5 (50%) → effectivePower=10
5. Subtract armor value: finalDamage = effectivePower - armorValue
   Example: effectivePower=10, armor=2 → finalDamage=8
6. Distribute to pools using weapon ratios:
   healthDamage = finalDamage * healthRatio
   stunDamage = finalDamage * stunRatio
7. Roll for critical hit → apply wound if successful
8. Apply damages to unit
9. Trigger morale checks
10. Check for death/unconsciousness
```

**Damage Types Enum:**
```lua
DamageTypes = {
    KINETIC = "kinetic",     -- Bullets, physical projectiles
    EXPLOSIVE = "explosive", -- Grenades, rockets
    LASER = "laser",         -- Energy weapons
    FIRE = "fire",           -- Incendiary
    MELEE = "melee",         -- Close combat
    BIO = "bio",             -- Biological agents
    ACID = "acid",           -- Corrosive
    STUN = "stun",           -- Non-lethal
    PSI = "psi"              -- Psychic attacks
}
```

**Armor Resistance Structure (in armours.toml):**
```toml
[armours.medium_armour]
id = "medium_armour"
name = "Medium Armour"
armourValue = 2
resistances = { kinetic = 0.5, explosive = 0.6, laser = 0.8, fire = 0.7 }
```

**Weapon Damage Properties (in weapons.toml):**
```toml
[weapons.pistol]
id = "pistol"
damage = 5
damageType = "kinetic"
healthRatio = 0.75  # 75% of damage goes to health
stunRatio = 0.25    # 25% goes to stun
criticalChance = 0.05  # 5% critical hit chance
```

**Unit Wound Tracking:**
```lua
unit.wounds = 0  -- Number of wounds (each bleeds 1 HP/turn)
unit.morale = unit.maxMorale  -- Current morale
unit.stun = 0  -- Stun damage accumulated
```

### Key Components

- **DamageSystem:** Core damage calculation engine
  - `resolveDamage(projectile, target)` - Main damage resolution
  - `calculateEffectivePower(power, damageType, armor)` - Apply resistance
  - `distributeD damage(finalDamage, ratios, target)` - Split to pools
  - `rollCriticalHit(weapon, attacker)` - Critical hit check
  - `applyWound(unit)` - Add wound effect

- **MoraleSystem:** Morale loss and checks
  - `checkMoraleLoss(unit, damageAmount)` - Morale loss from damage
  - `witnessDeathMorale(unit, deadUnit)` - Morale loss from seeing death
  - `rollBraveryCheck(unit)` - Will/Bravery check to avoid morale loss
  - `checkPanic(unit)` - Check for panic at low morale

- **Unit Extensions:**
  - `takeDamage(amount, damageType)` - Refactor to use DamageSystem
  - `takeStunDamage(amount)` - Apply stun
  - `takeMoraleDamage(amount)` - Apply morale loss
  - `applyBleeding()` - Lose 1 HP per wound

### Dependencies
- `battle.systems.projectile_system` - Provides damage on impact
- `systems.unit` - Unit stats, health, morale
- `systems.weapon_system` - Weapon damage properties
- `systems.data_loader` - Load armor resistances
- `battle.turn_manager` - Trigger bleeding at turn start

---

## Testing Strategy

### Unit Tests
Create `engine/battlescape/tests/test_damage_system.lua`:
- **Test 1:** Basic damage with no armor (5 power = 5 damage)
- **Test 2:** Damage with resistance (5 power, 50% resist = 10 effective)
- **Test 3:** Damage with armor value (10 effective - 2 armor = 8 final)
- **Test 4:** Damage distribution (8 damage, 75% health = 6 HP, 25% stun = 2 stun)
- **Test 5:** Critical hit applies wound
- **Test 6:** Morale loss from damage
- **Test 7:** Unit death at 0 HP
- **Test 8:** Bleeding damage per turn

### Integration Tests
- **Test 1:** Fire weapon → projectile → damage resolution → unit takes damage
- **Test 2:** Grenade explosion → multiple units take area damage
- **Test 3:** Critical hit → wound → bleeding over multiple turns
- **Test 4:** Unit death → nearby units lose morale
- **Test 5:** High stun → unit unconscious

### Manual Testing Steps
1. Run game with `lovec "engine"` (console enabled)
2. Enter battlescape with test units wearing different armor
3. Fire weapon at target, check console for damage breakdown:
   ```
   [DamageSystem] Weapon power: 5, type: kinetic
   [DamageSystem] Armor resistance: 50%, effective power: 10
   [DamageSystem] Armor value: 2, final damage: 8
   [DamageSystem] Distribution: 6 health, 2 stun
   [Unit] Soldier took 6 HP damage (45/50), 2 stun (2/100)
   ```
4. Verify unit health decreased correctly
5. Kill unit, verify nearby units show morale loss
6. Get critical hit, verify wound applied
7. End turn, verify bleeding damage applied

### Expected Results
- Console shows detailed damage calculation steps
- Damage correctly modified by armor resistance
- Armor value properly subtracted
- Health and stun pools updated correctly
- Critical hits add wounds
- Wounds cause 1 HP loss per turn
- Morale decreases on damage and death
- Units die at 0 HP
- No crashes or errors in Love2D console

---

## How to Run/Debug

### Running the Game
```bash
lovec "engine"
```

### Debug Console Output Example
```
[ProjectileSystem] Projectile impact at (15, 20)
[DamageSystem] Resolving damage: weapon=pistol, target=Soldier
[DamageSystem] Base power: 5, damage type: kinetic
[DamageSystem] Target armor: medium_armour
[DamageSystem] Resistance to kinetic: 50%
[DamageSystem] Effective power: 5 / 0.5 = 10
[DamageSystem] Armor value: 2
[DamageSystem] Final damage: 10 - 2 = 8
[DamageSystem] Damage distribution: health=75%, stun=25%
[DamageSystem] Health damage: 8 * 0.75 = 6
[DamageSystem] Stun damage: 8 * 0.25 = 2
[DamageSystem] Critical hit roll: 23 vs 5 (miss)
[Unit] Soldier took 6 HP damage (44/50 HP), 2 stun (2/100)
[MoraleSystem] Morale check for Soldier: will=50, damage=6
[MoraleSystem] Morale loss: 3 points (67/70 morale)
```

### Debugging Checklist
- [ ] Damage calculation messages show all steps
- [ ] Resistance percentages applied correctly
- [ ] Armor subtraction math correct
- [ ] Distribution ratios add to 100%
- [ ] Health/stun values updated in unit
- [ ] Critical hits logged when they occur
- [ ] Morale loss messages appear
- [ ] No division by zero or nil errors

---

## Documentation Updates

### Files to Update
- `wiki/API.md` - Add DamageSystem and MoraleSystem API
- `wiki/FIRE_SMOKE_MECHANICS.md` - Add damage mechanics section
- `wiki/faq.md` - Add damage calculation FAQ
- `engine/battlescape/combat/damage_system.lua` - Full LuaDoc comments
- `engine/battlescape/combat/morale_system.lua` - Full LuaDoc comments

### Documentation Content
- Damage calculation formula with examples
- Damage type vs armor resistance table
- How armor value reduces damage
- Damage distribution ratios explanation
- Critical hit mechanics
- Wound and bleeding system
- Morale system mechanics
- How to add new damage types

---

## Notes

**Design Decisions:**
- Armor resistance is **divisor** not multiplier (50% resistance = divide by 0.5 = double effective power)
  - This simulates armor being less effective against certain damage types
  - Example: Laser (80% resistance) → weapon is more effective against that armor
- Armor value subtracted **after** resistance modifier
- Damage can be distributed to multiple pools (health + stun + morale)
- Critical hits are separate from damage calculation (add wound, don't multiply damage)
- Wounds cause bleeding (1 HP per wound per turn, no recovery without medic)
- Morale loss happens **every** time damage taken unless bravery check passes

**Real Example:**
```
Pistol (power=5, kinetic, 75% health / 25% stun, 5% crit) 
  VS 
Medium Armor (resistance={kinetic=0.5}, armor=2)

Step 1: Effective power = 5 / 0.5 = 10
Step 2: Final damage = 10 - 2 = 8
Step 3: Health damage = 8 * 0.75 = 6
        Stun damage = 8 * 0.25 = 2
Step 4: Roll critical = 23 > 5, no wound
Step 5: Apply 6 HP, 2 stun to unit
Step 6: Morale check, lose 3 morale on fail
```

**Future Enhancements:**
- Damage randomization (80%-120% of base)
- Over-penetration (excess damage ignores armor)
- Damage falloff with range
- Damage type vulnerabilities (negative resistance = more damage)
- Armor degradation over time

---

## Blockers

**Dependencies:**
- TASK-013: Projectile System (needed for damage trigger)

**External Blockers:**
- None

---

## Review Checklist

Before marking complete:
- [ ] All acceptance criteria met
- [ ] Unit tests written and passing
- [ ] Integration tests successful
- [ ] Manual testing completed with Love2D console
- [ ] Console shows detailed damage breakdown
- [ ] All calculations verified with examples
- [ ] No console errors or warnings
- [ ] Code follows Lua best practices
- [ ] LuaDoc comments complete
- [ ] API documentation updated
- [ ] Damage calculation documented with examples
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
- TASK-015: Explosion Area Damage System
- TASK-016: Morale and Panic System
- TASK-017: Bleeding and Status Effects
