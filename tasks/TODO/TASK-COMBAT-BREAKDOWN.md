# Combat System Tasks - Breakdown and Implementation Plan

**Status:** Reference Document  
**Total Hours:** 76 hours  
**Related Documentation:** `docs/battlescape/COMBAT_SYSTEMS_COMPLETE.md`

---

## Overview

This document breaks down the Combat Systems work (damage models, weapon modes, critical hits, psionics, wounds) into 5 implementable tasks. Each task is fully self-contained but integrates with the others through the turn manager and combat system API.

---

## Task 1: Weapon Modes and Firing System (20 hours)

**Purpose:** Implement 6 universal firing modes for all weapons with tactical tradeoffs.

### Deliverables
- `engine/battlescape/weapon_modes.lua` - Mode definitions and calculations
- `engine/battlescape/shooting_system.lua` - Update to support modes
- `engine/utils/weapon_utils.lua` - Mode validation functions
- Test file: `tests/battlescape/test_weapon_modes.lua`

### Implementation Details

**File: weapon_modes.lua**
- Define 6 modes as table constants: SNAP, AIM, LONG, AUTO, HEAVY, FINESSE
- Each mode data includes:
  - `name`: String identifier
  - `accuracyModifier`: -0.15 to +0.20 (relative to base)
  - `apCost`: 1-4 AP
  - `epCost`: 0-2 EP
  - `damageModifier`: 0.8-1.2 multiplier
  - `critChanceBonus`: -0.1 to +0.1
  - `specialEffect`: Function reference or nil
  - `maxRange`: Optional range modifier

**Mode Descriptions:**
- SNAP: -15% accuracy, 1 AP, instant (low precision)
- AIM: Standard accuracy, 2 AP, standard (reliable)
- LONG: +20% accuracy, 3 AP, +50% range (sniper)
- AUTO: -5% per bullet, 3 AP, fires 5 bullets (spread)
- HEAVY: +1.2x damage, 2 AP, 1 EP, penetration (power)
- FINESSE: +10% crit chance, 2 AP, precision (high risk/reward)

**File: shooting_system.lua (updates)**
- Add `selectMode(unitId, mode)` function
- Add `getAvailableModes(weaponId)` function to filter by weapon
- Add `validateMode(weaponId, mode)` function
- Update fire logic to apply mode modifiers before hit calculation
- Validate AP/EP costs before allowing shot
- Log mode selection to combat log

**File: weapon_utils.lua (new)**
- `getWeaponCapableOfMode(weaponId, mode)` - Check if weapon supports mode
- `getModeSpecificStats(weaponId, mode)` - Return mode-modified stats
- `validateModeForWeapon(weaponId, mode)` - Return true/false with reason

### Testing
- Unit test each mode's calculations
- Integration test: Select each mode, verify modifiers apply
- Integration test: Verify AP/EP cost validation
- Integration test: AUTO mode fires 5 bullets with separate hit rolls

---

## Task 2: Damage Model Distribution and Recovery (16 hours)

**Purpose:** Implement 4 damage models that distribute damage across HP/stun/morale/energy and provide automatic recovery.

### Deliverables
- `engine/battlescape/damage_system.lua` - Damage distribution logic
- `engine/battlescape/turn_manager.lua` - Recovery system
- Data files updated: `engine/assets/data/weapons.toml`, `engine/assets/data/classes.toml`
- Test file: `tests/battlescape/test_damage_models.lua`

### Implementation Details

**File: damage_system.lua (new)**
- Implement damage distribution function:
  ```lua
  function DamageSystem.applyDamage(unit, damage, model, weaponId, source)
    -- Split damage based on model
    -- Apply to appropriate stat
    -- Return actual damage dealt
  end
  ```

**Damage Models:**

1. **Hurt Model** (lethal weapons: rifles, sniper, grenades)
   - 75% to HP, 25% to stun
   - Recovery: Stun -2/turn

2. **Stun Model** (non-lethal: stun grenades, shock rounds)
   - 100% to stun (cannot kill)
   - Recovery: Stun -2/turn

3. **Morale Model** (suppression: rockets, explosions)
   - 100% to morale (panic)
   - Recovery: Morale +5/turn

4. **Energy Model** (plasma, psionic drain)
   - 80% to energy (stamina), 20% to stun
   - Recovery: Energy +3/turn

**File: turn_manager.lua (updates)**
- Add recovery phase at turn start/end
- For each unit with damage:
  - Apply stun recovery: `unit.stun = math.max(0, unit.stun - 2)`
  - Apply morale recovery: `unit.morale = math.min(100, unit.morale + 5)`
  - Apply energy recovery: `unit.energy = math.min(maxEnergy, unit.energy + 3)`

**Data Files:**
- Add `damageModel` field to each weapon (hurt/stun/morale/energy)
- Add `damageValue` field (separate from armor damage)
- Add `recoveryRates` to unit stats (default: stun 2, morale 5, energy 3)

### Testing
- Unit test each damage model distribution
- Integration test: Verify recovery rates per turn
- Integration test: Multiple damage types on same unit
- Balance test: Verify damage progression (low/mid/high weapons)

---

## Task 3: Critical Hit System (12 hours)

**Purpose:** Implement critical hit mechanics with weapon precision and class expertise bonuses.

### Deliverables
- `engine/battlescape/critical_hit_system.lua` - Critical hit calculation
- `engine/battlescape/shooting_system.lua` - Integration with hit system
- Test file: `tests/battlescape/test_critical_hits.lua`
- Data files: Weapon crit data in `weapons.toml`, Class crit bonuses in `classes.toml`

### Implementation Details

**File: critical_hit_system.lua (new)**
- Implement critical hit chance calculation:
  ```lua
  function CriticalHitSystem.calculateCritChance(weapon, unit, targetArmor)
    local baseChance = weapon.critChance or 0
    local classBonus = unit.class:getCritBonus() or 0
    local aimBonus = unit.aim / 10  -- Aim stat contribution
    local totalChance = baseChance + classBonus + aimBonus
    return math.max(0, math.min(1, totalChance))  -- Clamp 0-100%
  end
  ```

- Implement critical hit roll:
  ```lua
  function CriticalHitSystem.rollCritical(chance)
    local roll = love.math.random(1, 100)
    return roll <= (chance * 100)
  end
  ```

- On critical hit:
  - Multiply damage by 2.0
  - Apply bleeding wound (see Wound Tracking task)
  - Log "CRITICAL HIT!" to combat log
  - Add visual effect (temporary - TODO by effects task)

**File: shooting_system.lua (updates)**
- After hit calculation success, check for critical hit
- If critical, apply 2x damage modifier
- Call wound tracking system with bleeding source

### Testing
- Unit test: Crit chance calculation formula
- Unit test: Crit roll probability distribution
- Integration test: Critical hit with different weapons
- Integration test: Critical hit with different classes
- Balance test: Crit chance scales with aim stat

---

## Task 4: Wound Tracking and Bleeding System (14 hours)

**Purpose:** Implement individual wound tracking with full source attribution and automatic bleeding damage.

### Deliverables
- `engine/battlescape/wound_system.lua` - Wound tracking logic
- `engine/battlescape/turn_manager.lua` - Bleeding damage application
- `engine/utils/wound_utils.lua` - Wound query functions
- Test file: `tests/battlescape/test_wounds.lua`

### Implementation Details

**File: wound_system.lua (new)**
- Unit data structure enhancement:
  ```lua
  unit.wounds = {
    {
      id = "wound_001",
      turn = currentTurn,
      weaponId = "rifle_m1",
      attackerId = "attacker_id",
      damageType = "hurt",  -- hurt/stun/morale/energy
      bleedRate = 1,         -- HP/turn
      stabilized = false,
      severity = "light"     -- light/moderate/severe
    }
  }
  ```

- Implement add wound function:
  ```lua
  function WoundSystem.addWound(unit, attackerId, weaponId, damageType)
    local wound = {
      id = generateWoundId(),
      turn = getCurrentTurn(),
      weaponId = weaponId,
      attackerId = attackerId,
      damageType = damageType,
      bleedRate = getBleedRate(damageType),
      stabilized = false
    }
    table.insert(unit.wounds, wound)
  end
  ```

- Implement wound stabilization:
  ```lua
  function WoundSystem.stabilizeWound(unit, woundId)
    for _, wound in ipairs(unit.wounds) do
      if wound.id == woundId then
        wound.stabilized = true
        return true
      end
    end
    return false
  end
  ```

**File: turn_manager.lua (updates)**
- Add bleeding damage phase (after recovery):
  ```lua
  function calculateTotalBleedingDamage(unit)
    local total = 0
    for _, wound in ipairs(unit.wounds) do
      if not wound.stabilized then
        total = total + wound.bleedRate
      end
    end
    return total
  end
  ```

**File: wound_utils.lua (new)**
- `getWoundCount(unit)` - Total wounds
- `getActiveWoundCount(unit)` - Non-stabilized wounds
- `getWoundsFromAttacker(unit, attackerId)` - Attribution
- `getWoundsFromWeapon(unit, weaponId)` - Weapon type
- `getTotalBleedingRate(unit)` - Active bleeding damage

### Testing
- Unit test: Wound creation and tracking
- Unit test: Wound stabilization system
- Unit test: Bleeding damage calculation
- Integration test: Bleeding damage applied per turn
- Integration test: Wound source attribution
- Balance test: Bleeding rates per damage type

---

## Task 5: Psionic Abilities System (14 hours)

**Purpose:** Implement 11 psionic mental abilities with resistance system and area effects.

### Deliverables
- `engine/battlescape/psionics_system.lua` - Psionic mechanics and calculation
- `engine/battlescape/psionic_abilities.lua` - 11 ability definitions
- `engine/utils/psionic_utils.lua` - Resistance and effect calculations
- Test file: `tests/battlescape/test_psionics.lua`
- Data files: Psionic abilities in `engine/assets/data/psionics.toml`, Unit psi data in save files

### Implementation Details

**File: psionic_abilities.lua (new)**
Define 11 abilities:

**Damage Abilities (3):**
1. PSI_DAMAGE (10-20 damage, will check required)
2. PSI_CRITICAL (guarantee next crit)
3. DAMAGE_TERRAIN (3 hex radius destruction)

**Environmental Abilities (4):**
4. UNCOVER_TERRAIN (reveal 5 hex radius, 3 turns)
5. MOVE_TERRAIN (telekinesis, 3 hex max range)
6. CREATE_FIRE (spawn fire intensity 3, spreads)
7. CREATE_SMOKE (spawn smoke 3 radius, density 5)

**Control Abilities (4):**
8. MOVE_OBJECT (50kg telekinesis, throw as weapon)
9. MIND_CONTROL (switch team, 3 turns)
10. SLOW_UNIT (AP -2, 2 turns)
11. HASTE_UNIT (AP +2, 2 turns)

**File: psionics_system.lua (new)**
- Core resistance formula:
  ```lua
  function PsionicsSystem.calculateResistance(attacker, target, abilityType)
    local attackPower = attacker.psiPower or 50
    local targetResistance = target.willpower or 50
    local resistance = targetResistance - attackPower
    -- Ability-specific modifiers
    -- Return final resistance value (lower = easier to resist)
  end
  ```

- Ability execution:
  ```lua
  function PsionicsSystem.executeAbility(attacker, abilityId, target, location)
    local ability = PSIONIC_ABILITIES[abilityId]
    if not ability then return false end
    
    local resistanceCheck = calculateResistance(attacker, target, ability.type)
    if resistanceCheck and shouldResist(resistanceCheck) then
      -- Ability resisted
      return false
    end
    
    ability.effect(attacker, target, location)
    return true
  end
  ```

**File: psionic_utils.lua (new)**
- `isUnitPsionic(unit)` - Check if unit has psi abilities
- `getAvailablePsionicAbilities(unit)` - List abilities with costs
- `calculatePsiEnergyCost(abilityId)` - Resource cost
- `getEffectiveRange(abilityId)` - Ability range
- `getAffectedArea(abilityId, centerLocation)` - Area effect targets

**Data File: psionics.toml**
```toml
[PSI_DAMAGE]
type = "damage"
energyCost = 4
range = 12
damageMin = 10
damageMax = 20
resistanceType = "will"

[SLOW_UNIT]
type = "debuff"
energyCost = 2
range = 10
duration = 2
apReduction = 2
```

### Testing
- Unit test: Resistance calculation formula
- Unit test: Each ability effect logic
- Integration test: Ability execution with resistance check
- Integration test: Area effects (smoke, fire, slowness)
- Integration test: Team switching (mind control)
- Balance test: Psi energy costs scale appropriately
- Balance test: Resistance formula prevents dominance

---

## Integration Points

### Shooting System
- Weapon modes feed into hit calculation
- Critical hit triggers wound creation
- Damage model applied from weapon data
- Combat log updated with all events

### Turn Manager
- Recovery phase for stun/morale/energy
- Bleeding damage calculation and application
- Status effect duration decrease
- Psionic abilities triggered by AI

### Unit Data Structure
- `unit.wounds` - Wound tracking array
- `unit.damageModel` - Damage distribution preference
- `unit.psiPower` - Psionic attack strength
- `unit.psiEnergy` - Psionic resource pool

### Combat Log
- "CRITICAL HIT!" messages
- Wound applications with source
- Bleeding damage application
- Status effect application/expiration
- Psionic ability success/resistance

---

## Testing Strategy

### Unit Tests
- Each system tested independently with mocks
- Edge cases (zero damage, max values, simultaneous effects)
- Formula verification (crit chance, resistance, recovery)

### Integration Tests
- Full combat turn with all systems active
- Multiple units with multiple wounds/effects
- Verify combat log accuracy
- Verify stat consistency across turn phases

### Balance Tests
- Verify damage progression (rifles > pistols)
- Verify crit chance scales reasonably
- Verify psionic abilities aren't overpowered
- Verify healing keeps up with bleeding

### Manual Tests (in game)
- Run with `lovec "engine"`
- Start new battle
- Test each weapon mode
- Test each psionic ability
- Verify wound display (when UI implemented)
- Verify recovery rates work

---

## Related Files

**Implementation References:**
- `engine/battlescape/turn_manager.lua` - Turn phase orchestration
- `engine/battlescape/shooting_system.lua` - Hit calculation
- `engine/battlescape/unit_manager.lua` - Unit state
- `engine/assets/data/weapons.toml` - Weapon balance data
- `engine/assets/data/classes.toml` - Class abilities/bonuses

**Tests to Create:**
- `tests/battlescape/test_weapon_modes.lua`
- `tests/battlescape/test_damage_models.lua`
- `tests/battlescape/test_critical_hits.lua`
- `tests/battlescape/test_wounds.lua`
- `tests/battlescape/test_psionics.lua`

**Integration Test:**
- `tests/battlescape/test_combat_system_integration.lua` - All 5 systems together

---

## Success Criteria

✅ All 6 weapon modes functional with correct modifiers  
✅ Damage distribution per model works correctly  
✅ Recovery rates apply appropriately  
✅ Critical hit system with proper formula  
✅ Wound tracking with source attribution  
✅ Bleeding damage calculated and applied  
✅ 11 psionic abilities all functional  
✅ Resistance formula prevents abuse  
✅ All systems integrate without conflicts  
✅ Combat log accurate and complete  
✅ No console errors when running game  
✅ All unit tests pass  
✅ All integration tests pass  

---

## Notes for Future Developer

- This breakdown assumes all 5 tasks will be implemented sequentially
- Tasks can be parallelized if multiple developers available
- Each task is ~12-20 hours, total ~76 hours
- See `docs/battlescape/COMBAT_SYSTEMS_COMPLETE.md` for status on existing implementations
- Many systems already ~70-95% complete; this document describes remaining work
- Run tests frequently with `lovec "engine"` to verify each feature
- Keep combat log updated for debugging
