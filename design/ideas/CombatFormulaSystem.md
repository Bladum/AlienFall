# Combat Formula Documentation & Balance System

> **Status**: Design Proposal
> **Last Updated**: 2025-10-28
> **Priority**: HIGH
> **Related Systems**: Battlescape.md, Units.md, Items.md, AI.md

## Table of Contents

- [Overview](#overview)
- [Damage Calculation System](#damage-calculation-system)
- [Accuracy Formula](#accuracy-formula)
- [Status Effect System](#status-effect-system)
- [Critical Hit System](#critical-hit-system)
- [Cover & Positioning](#cover--positioning)
- [Action Point Economics](#action-point-economics)
- [Balance Verification Tools](#balance-verification-tools)
- [Technical Implementation](#technical-implementation)

---

## Overview

### System Purpose

Addresses **combat formula documentation gaps** by explicitly defining all damage, accuracy, status effect, and combat calculations with complete formulas and examples.

**Core Goals**:
- Document every combat formula (no ambiguity)
- Define damage reduction mechanics (armor vs. damage types)
- Specify accuracy calculations (distance, cover, modifiers)
- Detail status effect durations (turns, conditions, removal)
- Provide balance verification tools (prevent broken combinations)

---

## Damage Calculation System

### Base Damage Formula

```yaml
Final Damage = Base_Weapon_Damage - Effective_Armor + Random_Variance

Where:
  Base_Weapon_Damage = Weapon stat from Items.md
  Effective_Armor = Armor_Value × Damage_Type_Modifier
  Random_Variance = ±10% of Base_Weapon_Damage

Minimum Damage = 1 (always deal at least 1 damage if hit)
Maximum Damage = Base_Weapon_Damage × 1.10 (with variance)
```

### Damage Type Modifiers

```yaml
Armor Effectiveness vs. Damage Types:

Kinetic Damage (Rifles, Pistols, Melee):
  - Armor Effectiveness: 100%
  - Formula: Effective_Armor = Armor_Value × 1.00
  - Example: 10 armor reduces kinetic damage by 10

Energy Damage (Lasers, Plasma):
  - Armor Effectiveness: 50%
  - Formula: Effective_Armor = Armor_Value × 0.50
  - Example: 10 armor reduces energy damage by 5

Explosive Damage (Grenades, Rockets):
  - Armor Effectiveness: 25%
  - Formula: Effective_Armor = Armor_Value × 0.25
  - Example: 10 armor reduces explosive damage by 2.5 (rounds to 3)

Psionic Damage (Mind Attacks):
  - Armor Effectiveness: 0%
  - Formula: Effective_Armor = 0 (armor ignored completely)
  - Example: 10 armor reduces psionic damage by 0

Hazard Damage (Fire, Acid, Poison):
  - Armor Effectiveness: 75%
  - Formula: Effective_Armor = Armor_Value × 0.75
  - Example: 10 armor reduces hazard damage by 7.5 (rounds to 8)
```

### Damage Calculation Examples

**Example 1: Rifle vs. Light Armor**
```
Weapon: Assault Rifle (25 base damage, kinetic)
Target: Soldier with 5 armor
Damage Type Modifier: 100% (kinetic vs. armor)

Calculation:
  Effective_Armor = 5 × 1.00 = 5
  Base_Damage = 25
  Random_Variance = ±2.5 (10% of 25)

  Roll = 0 (neutral variance)
  Final_Damage = 25 - 5 + 0 = 20 damage

Result: Target takes 20 damage
```

**Example 2: Plasma Rifle vs. Heavy Armor**
```
Weapon: Plasma Rifle (35 base damage, energy)
Target: Heavy Trooper with 15 armor
Damage Type Modifier: 50% (energy vs. armor)

Calculation:
  Effective_Armor = 15 × 0.50 = 7.5 (rounds to 8)
  Base_Damage = 35
  Random_Variance = ±3.5 (10% of 35)

  Roll = +2 (positive variance)
  Final_Damage = 35 - 8 + 2 = 29 damage

Result: Target takes 29 damage
```

**Example 3: Grenade vs. Heavy Armor**
```
Weapon: Frag Grenade (40 base damage, explosive)
Target: Heavy Trooper with 15 armor
Damage Type Modifier: 25% (explosive vs. armor)

Calculation:
  Effective_Armor = 15 × 0.25 = 3.75 (rounds to 4)
  Base_Damage = 40
  Random_Variance = ±4 (10% of 40)

  Roll = -3 (negative variance)
  Final_Damage = 40 - 4 - 3 = 33 damage

Result: Target takes 33 damage
```

**Example 4: Minimum Damage Edge Case**
```
Weapon: Pistol (12 base damage, kinetic)
Target: Tank with 20 armor
Damage Type Modifier: 100% (kinetic vs. armor)

Calculation:
  Effective_Armor = 20 × 1.00 = 20
  Base_Damage = 12
  Random_Variance = ±1.2 (10% of 12)

  Roll = -1 (negative variance)
  Calculated_Damage = 12 - 20 - 1 = -9

  Minimum_Damage_Rule = max(1, Calculated_Damage)
  Final_Damage = 1 damage (floor)

Result: Target takes 1 damage (armor too strong, but always min 1)
```

---

## Accuracy Formula

### Base Hit Chance Calculation

```yaml
Final_Hit_Chance = Base_Accuracy + Aim_Bonus + Equipment_Bonus -
                   Distance_Penalty - Cover_Penalty - Movement_Penalty +
                   Height_Advantage + Flanking_Bonus + Status_Modifiers

Clamped to: min(5%, max(Final_Hit_Chance, 95%))

Where:
  Base_Accuracy = Weapon accuracy stat (50-85% typical)
  Aim_Bonus = (Unit_Aim_Stat - 6) × 5% (6-12 stat range = 0-30%)
  Equipment_Bonus = Scope/attachments (+0-15%)
  Distance_Penalty = (Current_Range - Optimal_Range) × 2% per hex
  Cover_Penalty = Half cover -20%, Full cover -40%
  Movement_Penalty = Moved this turn -30%, Dashed -50%
  Height_Advantage = +10% if attacking from higher elevation
  Flanking_Bonus = +20% if target has no cover from your angle
  Status_Modifiers = Sum of all status effects (±5-30%)
```

### Detailed Accuracy Components

**Aim Bonus Calculation**:
```yaml
Unit Aim Stat Range: 6-12 (base stats)

Aim Stat → Bonus:
  6: +0%  (baseline, no training)
  7: +5%
  8: +10%
  9: +15%
  10: +20%
  11: +25%
  12: +30% (elite marksman)

Formula: (Aim_Stat - 6) × 5%
```

**Distance Penalty Calculation**:
```yaml
Optimal Range (weapon-dependent):
  - Shotgun: 4 hexes
  - Pistol: 8 hexes
  - Rifle: 15 hexes
  - Sniper Rifle: 25 hexes

Penalty Formula:
  If Current_Range <= Optimal_Range:
    Distance_Penalty = 0% (no penalty)

  If Current_Range > Optimal_Range:
    Distance_Penalty = (Current_Range - Optimal_Range) × 2% per hex

Example:
  Sniper Rifle (optimal 25 hexes) at 30 hexes
  Penalty = (30 - 25) × 2% = 10% penalty

  Shotgun (optimal 4 hexes) at 10 hexes
  Penalty = (10 - 4) × 2% = 12% penalty
```

**Cover Penalties**:
```yaml
No Cover:
  - Penalty: 0%
  - Unit fully exposed

Half Cover (low wall, sandbags):
  - Penalty: -20% hit chance
  - Target partially obscured

Full Cover (building, vehicle):
  - Penalty: -40% hit chance
  - Target mostly hidden

Flank Shot (no cover from attack angle):
  - Bonus: +20% hit chance
  - Cover ignored from this angle
```

### Accuracy Examples

**Example 1: Easy Shot**
```
Weapon: Rifle (70% base accuracy, 15 hex optimal)
Shooter: Unit with Aim 10 (+20%)
Target: 10 hexes away, no cover, standing still
Conditions: Normal (no modifiers)

Calculation:
  Base_Accuracy = 70%
  Aim_Bonus = +20%
  Equipment = 0%
  Distance = 0% (within optimal)
  Cover = 0% (none)
  Movement = 0% (standing)
  Height = 0% (level ground)
  Flanking = 0% (no cover to flank)
  Status = 0%

  Final = 70 + 20 = 90%
  Clamped = 90% (within 5-95% range)

Result: 90% chance to hit
```

**Example 2: Difficult Shot**
```
Weapon: Sniper Rifle (85% base, 25 hex optimal)
Shooter: Unit with Aim 8 (+10%), moved this turn
Target: 30 hexes away, full cover, higher elevation
Conditions: Shooter at disadvantage

Calculation:
  Base_Accuracy = 85%
  Aim_Bonus = +10%
  Equipment = +10% (scope)
  Distance = -10% (30-25 = 5 hexes over optimal × 2%)
  Cover = -40% (full cover)
  Movement = -30% (moved)
  Height = -10% (target higher, shooter disadvantaged)
  Flanking = 0%
  Status = 0%

  Final = 85 + 10 + 10 - 10 - 40 - 30 - 10 = 15%
  Clamped = 15% (within 5-95% range)

Result: 15% chance to hit (very difficult)
```

**Example 3: Flanking Shot**
```
Weapon: Rifle (70% base, 15 hex optimal)
Shooter: Unit with Aim 12 (+30%), flanking position
Target: 12 hexes away, full cover (but flanked), stationary
Conditions: Flanking negates cover

Calculation:
  Base_Accuracy = 70%
  Aim_Bonus = +30%
  Equipment = 0%
  Distance = 0% (within optimal)
  Cover = 0% (ignored due to flanking)
  Movement = 0%
  Height = +10% (shooter on high ground)
  Flanking = +20%
  Status = 0%

  Final = 70 + 30 + 10 + 20 = 130%
  Clamped = 95% (capped at maximum)

Result: 95% chance to hit (nearly guaranteed)
```

---

## Status Effect System

### Status Effect Definitions

```yaml
Status Effects (Complete List):

Stunned:
  Duration: 1-3 turns (damage-based)
  Effect: -2 AP (lose entire turn)
  Removal: Time expires OR Medikit stimulant
  Stacking: Refreshes duration (doesn't stack)

  Duration Calculation:
    Stun_Turns = floor(Stun_Damage / Unit_Max_HP × 3)
    Min = 1 turn, Max = 3 turns

  Example:
    Unit with 50 HP takes 25 stun damage
    Duration = floor(25/50 × 3) = floor(1.5) = 1 turn

Panicked:
  Duration: Until morale restored
  Effect: -1 AP, unit may flee or shoot randomly
  Removal: Leadership ability OR mission success
  Stacking: No (binary state)

  Panic Trigger:
    - Morale drops to 0
    - Ally killed nearby (15% chance)
    - Surrounded by enemies (30% chance)

Burning:
  Duration: 3 turns
  Effect: 5 damage per turn (DoT)
  Removal: Water hex OR Medikit foam OR 3 turns expire
  Stacking: Yes (multiple fire sources add duration)

  Example:
    Turn 1: Take 5 damage (burning)
    Turn 2: Hit by second incendiary (duration refreshes to 3)
    Turn 3: Take 5 damage (burning)
    Turn 4: Take 5 damage (burning)
    Turn 5: Take 5 damage (burning, last turn)
    Turn 6: Effect ends

Poisoned:
  Duration: 5 turns
  Effect: 3 damage per turn (DoT), -10% accuracy
  Removal: Antidote OR 5 turns expire
  Stacking: No (refreshes duration)

Bleeding:
  Duration: Permanent until healed
  Effect: 2 damage per turn (DoT)
  Removal: Medikit heal OR end of mission
  Stacking: No (binary state)

  Critical: If unit reaches 0 HP while bleeding, dies instantly

Suppressed:
  Duration: 1 turn (until shooter's next turn)
  Effect: -30% accuracy, -1 AP
  Removal: Time expires OR move to new position
  Stacking: Multiple sources = -30% per source (stacks)

Disoriented:
  Duration: 2 turns
  Effect: -20% accuracy, -10% dodge
  Removal: Time expires OR Leadership ability
  Stacking: Refreshes duration

Hunkered:
  Duration: Until unit moves
  Effect: +40% defense, cannot attack
  Removal: Unit takes any action
  Stacking: No (intentional defensive stance)
```

### Status Effect Interactions

```yaml
Status Effect Combinations:

Burning + Bleeding:
  - Both damage types apply (5 + 2 = 7 per turn)
  - Heal bleeding first (more dangerous long-term)

Stunned + Any:
  - Stun overrides other AP costs
  - Unit cannot act regardless of other effects

Panicked + Suppressed:
  - Cumulative accuracy penalties (-30% suppressed + random panic fire)
  - May flee even under suppression

Poisoned + Bleeding + Burning (Triple DoT):
  - Total: 10 damage per turn (lethal combo)
  - Priority: Stop burning (remove immediately)
  - Then: Heal bleeding (permanent threat)
  - Finally: Antidote for poison (temporary)
```

### Status Effect Examples

**Example 1: Stun Duration**
```
Unit: 60 HP max
Hit by: Stun Grenade dealing 40 stun damage

Calculation:
  Stun_Turns = floor(40 / 60 × 3)
  Stun_Turns = floor(2.0) = 2 turns

Result: Unit stunned for 2 turns (loses 2 full actions)
```

**Example 2: Fire Spread**
```
Turn 1: Unit walks through fire hex (catch fire, 3 turn duration)
Turn 2: Unit takes 5 damage (burning), duration = 2 turns left
Turn 3: Unit hit by incendiary grenade (duration refreshes to 3 turns)
Turn 4: Unit takes 5 damage (burning), duration = 2 turns left
Turn 5: Unit uses medikit foam (fire extinguished immediately)

Total Damage: 10 (5 + 5, stopped early with foam)
```

---

## Critical Hit System

### Critical Hit Mechanics

```yaml
Critical Hit Chance:
  Base: 0% (no crits by default)
  Sources:
    - Weapon Mastery: +5-25% (based on mastery level)
    - Flanking: +10%
    - Height Advantage: +5%
    - Target Stunned: +20%
    - Sniper Aimed Shot: +15%

  Maximum: 95% crit chance (same cap as hit chance)

Critical Hit Effect:
  Damage Multiplier: 1.5× (50% more damage)
  Armor Penetration: +50% (ignores half of armor)

  Formula:
    Crit_Damage = Base_Weapon_Damage × 1.5
    Effective_Armor_vs_Crit = Effective_Armor × 0.50

    Final_Crit_Damage = Crit_Damage - Effective_Armor_vs_Crit

Example:
  Weapon: Sniper Rifle (50 damage)
  Target: 10 armor
  Normal Hit: 50 - 10 = 40 damage
  Critical Hit: (50 × 1.5) - (10 × 0.5) = 75 - 5 = 70 damage
```

### Headshot System (Snipers Only)

```yaml
Headshot (Special Critical):
  Requirement: Sniper rifle + Aimed shot + Crit roll success
  Chance: Standard crit chance (as above)
  Effect: Instant kill on non-boss enemies

  Boss Enemies (cannot instant-kill):
    - Deal 3× damage instead of instant kill
    - Armor ignored completely

  Example:
    Sniper with Master sniper mastery (+20% crit)
    Aimed shot on stunned target (+15% aim + 20% crit)
    Total crit chance: 55%

    Success: Instant kill (if not boss)
    Boss: 50 × 3 = 150 damage (massive damage)
```

---

## Cover & Positioning

### Cover Types & Mechanics

```yaml
Cover Destruction:
  - Explosive damage can destroy cover
  - Explosive Damage > Cover_HP: Cover destroyed
  - Cover_HP typical: 20-50 depending on material

  Examples:
    Wood Crate: 20 HP (easily destroyed)
    Sandbags: 30 HP (moderate)
    Concrete Wall: 50 HP (durable)
    Vehicle: 80 HP (very durable)

Flanking Detection:
  - Check angle between attacker and target
  - If angle > 90° from cover direction: Flanking
  - Cover bonus negated, flanking bonus applied

  Example:
    Target behind north wall (facing north)
    Attacker from east (90° angle)
    Result: Flanking (+20% hit chance, cover ignored)

Height Advantage:
  - Elevation difference > 2 meters: Height advantage
  - Attacker higher: +10% hit, +5% crit
  - Attacker lower: -10% hit
  - Calculated per hex: 1 hex = 2 meters elevation
```

---

## Action Point Economics

### AP Cost Breakdown

```yaml
Action Point Costs (Per Action):

Movement:
  - 1 hex normal terrain: 1 AP
  - 1 hex difficult terrain: 2 AP
  - Dash (double movement, -50% accuracy): 2 AP
  - Climb (up elevation): 2 AP per hex

Combat:
  - Snap Shot: 1 AP (-20% accuracy)
  - Standard Shot: 2 AP (base accuracy)
  - Aimed Shot: 3 AP (+20% accuracy, stationary only)
  - Burst Fire: 3 AP (3-5 shots, -10% accuracy)
  - Auto Fire: 4 AP (10+ shots, -20% accuracy)

Items:
  - Use Medikit: 1 AP
  - Throw Grenade: 1 AP
  - Reload Weapon: 1 AP
  - Switch Weapon: 0 AP (free action)
  - Use Item: 1 AP (general)

Abilities:
  - Overwatch: 1 AP (reserve fire)
  - Hunker Down: 1 AP (defensive stance)
  - Psionic Ability: 2-3 AP (based on power)
  - Special Ability: Varies (1-4 AP)

AP Regeneration:
  - Start of turn: Full AP restore
  - Base AP: 4 per turn (all units)
  - Modified by: Health, morale, status effects
  - Minimum AP: 1 (even if heavily wounded)
```

### AP Optimization Strategies

```yaml
Optimal Turn Structure:

Aggressive Build (4 AP):
  - Move 1 hex (1 AP)
  - Aimed Shot (3 AP)
  - Total: 4 AP (maximize damage)

Balanced Build (4 AP):
  - Move 2 hexes (2 AP)
  - Standard Shot (2 AP)
  - Total: 4 AP (mobility + damage)

Mobile Build (4 AP):
  - Dash 4 hexes (2 AP)
  - Snap Shot (1 AP)
  - Throw Grenade (1 AP)
  - Total: 4 AP (maximum positioning)

Defensive Build (4 AP):
  - Move to cover (1-2 AP)
  - Hunker Down (1 AP)
  - Overwatch (1 AP)
  - Total: 3-4 AP (survival focus)
```

---

## Balance Verification Tools

### Damage Balance Calculator

```lua
-- Verify weapon balance across all scenarios
function verifyWeaponBalance(weapon, armor_range)
  local results = {}

  for armor = 0, armor_range, 5 do
    local avg_damage = calculateAverageDamage(weapon, armor)
    local ttk = calculateTimeToKill(weapon, armor, 50) -- 50 HP target

    table.insert(results, {
      armor = armor,
      avg_damage = avg_damage,
      time_to_kill = ttk
    })
  end

  return results
end

-- Example output:
-- Rifle (25 damage, kinetic):
--   Armor 0: 25 avg, 2 turns to kill
--   Armor 5: 20 avg, 3 turns to kill
--   Armor 10: 15 avg, 4 turns to kill
--   Armor 15: 10 avg, 5 turns to kill
--   Armor 20: 5 avg, 10 turns to kill
```

### Accuracy Balance Verifier

```lua
-- Verify hit chances across all scenarios
function verifyAccuracyBalance(weapon, unit_aim)
  local scenarios = {
    {name = "Point Blank", distance = 0, cover = 0},
    {name = "Optimal Range", distance = weapon.optimal_range, cover = 0},
    {name = "Long Range", distance = weapon.optimal_range * 1.5, cover = 0},
    {name = "Cover (Half)", distance = weapon.optimal_range, cover = -20},
    {name = "Cover (Full)", distance = weapon.optimal_range, cover = -40}
  }

  for _, scenario in ipairs(scenarios) do
    local hit_chance = calculateHitChance(weapon, unit_aim, scenario)
    print(string.format("%s: %d%%", scenario.name, hit_chance))
  end
end
```

---

## Technical Implementation

```lua
-- engine/battlescape/combat_calculator.lua

CombatCalculator = {}

function CombatCalculator:calculateDamage(weapon, target, hit_type)
  local base_damage = weapon.base_damage
  local damage_type = weapon.damage_type

  -- Armor effectiveness based on damage type
  local armor_multiplier = self:getDamageTypeMultiplier(damage_type)
  local effective_armor = target.armor * armor_multiplier

  -- Random variance
  local variance = math.random(-10, 10) / 100 * base_damage

  -- Critical hit
  local crit_multiplier = 1.0
  if hit_type == "CRITICAL" then
    crit_multiplier = 1.5
    effective_armor = effective_armor * 0.5 -- Crits ignore 50% armor
  end

  -- Calculate final damage
  local damage = (base_damage * crit_multiplier) - effective_armor + variance

  -- Enforce minimum damage
  damage = math.max(1, damage)

  return math.floor(damage)
end

function CombatCalculator:calculateHitChance(weapon, shooter, target, conditions)
  local base_accuracy = weapon.base_accuracy

  -- Aim bonus
  local aim_bonus = (shooter.aim_stat - 6) * 5

  -- Equipment
  local equipment_bonus = shooter.scope_bonus or 0

  -- Distance penalty
  local distance = conditions.distance
  local optimal_range = weapon.optimal_range
  local distance_penalty = 0

  if distance > optimal_range then
    distance_penalty = (distance - optimal_range) * 2
  end

  -- Cover
  local cover_penalty = conditions.cover_value or 0

  -- Movement
  local movement_penalty = 0
  if conditions.shooter_moved then
    movement_penalty = 30
  elseif conditions.shooter_dashed then
    movement_penalty = 50
  end

  -- Height
  local height_bonus = 0
  if conditions.height_advantage > 0 then
    height_bonus = 10
  elseif conditions.height_advantage < 0 then
    height_bonus = -10
  end

  -- Flanking
  local flanking_bonus = 0
  if conditions.flanking then
    flanking_bonus = 20
    cover_penalty = 0 -- Flanking negates cover
  end

  -- Calculate total
  local hit_chance = base_accuracy + aim_bonus + equipment_bonus -
                     distance_penalty - cover_penalty - movement_penalty +
                     height_bonus + flanking_bonus

  -- Clamp to 5-95%
  hit_chance = math.max(5, math.min(95, hit_chance))

  return hit_chance
end

function CombatCalculator:applyStatusEffect(unit, effect_type, duration, source)
  -- Check if effect already exists
  local existing = unit.status_effects[effect_type]

  if existing then
    -- Refresh duration if stacking allowed
    if self:canStack(effect_type) then
      existing.duration = existing.duration + duration
    else
      existing.duration = math.max(existing.duration, duration)
    end
  else
    -- Add new effect
    unit.status_effects[effect_type] = {
      type = effect_type,
      duration = duration,
      source = source,
      start_turn = GameState.current_turn
    }
  end

  -- Apply immediate effects
  self:applyStatusEffectModifiers(unit, effect_type)
end
```

---

## Conclusion

The Combat Formula Documentation & Balance System provides complete transparency into all combat calculations. By explicitly defining every formula, damage type interaction, and status effect, implementation becomes straightforward and balance verification becomes systematic.

**Key Success Metrics**:
- 100% formula coverage (no ambiguous mechanics)
- Balance verification tools implemented (automated testing)
- Damage curves verified across armor ranges (TTK consistency)
- Status effects documented with examples (clear player understanding)

**Implementation Priority**: HIGH (Tier 1)
**Estimated Development Time**: 3-5 days (documentation + verification)
**Dependencies**: Battlescape.md, Units.md, Items.md
**Risk Level**: Low (documentation task, no gameplay changes)

---

**Document Status**: Design Proposal - Ready for Implementation
**Next Steps**: Review formulas, implement verification tools, validate balance
**Author**: Senior Game Designer
**Review Date**: 2025-10-28
