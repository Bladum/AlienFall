# 💥 Damage Types System
## Canonical Reference for Weapons, Armor & Resistance

**Version**: 1.0
**Status**: Complete specification
**Canonical Source**: YES (all weapon/armor files reference this document)

## Table of Contents

- [Overview](#overview)
- [Damage Types](#damage-types)
- [Armor Resistance Reference](#armor-resistance-reference)
- [Design Principles](#design-principles)
- [Integration with Combat](#integration-with-combat)

---

## OVERVIEW

AlienFall uses a unified damage type system with 8 core types, each with specific armor resistances.

---

## DAMAGE TYPES

### 1. KINETIC
- **Source**: Firearms, ballistic weapons, melee impact
- **Description**: Physical projectile or impact damage
- **Armor Resistance**:
  - Light Armor: 50% reduction
  - Medium Armor: 30% reduction
  - Heavy Armor: 10% reduction
  - Energy Shield: 0% reduction
- **Weapon Examples**: Rifles, pistols, shotguns, melee weapons

---

### 2. EXPLOSIVE
- **Source**: Grenades, explosives, mines, blast radius
- **Description**: Concussive blast and shrapnel damage
- **Base Armor Resistance** (applies to units):
  - Light Armor: 40% reduction
  - Medium Armor: 20% reduction
  - Heavy Armor: 5% reduction
  - Energy Shield: 50% reduction
- **Weapon Examples**: Grenades, mines, rocket launchers, proximity explosives
- **Wave Mechanics**: Blast creates separate damage waves in each direction (see Explosion Wave Mechanics below)

#### EXPLOSION ARMOR MECHANICS (Detailed)

**Different Treatment for Walls vs. Units**:

**Walls & Obstacles**:
- **Damage Blocked**: 100% (walls completely block explosion waves)
- **Wave Propagation**: Blast waves stop at wall (do not penetrate or reduce)
- **Adjacent Hexes**: Hexes on opposite side of wall receive NO damage
- **Design Intent**: Walls provide complete protection from explosion (tactical positioning matters)

**Units** (with armor):
- **Damage Blocked**: 50% (armor reduces explosion damage)
- **Resistance Calculation**: Unit armor blocks 50% base, then additional armor-type resistance applies
- **Wave Propagation**: Unit does not stop wave (wave continues to hexes beyond unit)
- **Adjacent Units**: Units behind first unit still take damage from blast wave

**Wave Propagation Mechanics**:
```
Explosion at epicenter with radius 4 hexes

Direction 1 (toward wall):
  Hex 1: Clear → Takes 100% damage
  Hex 2: Clear → Takes 80% damage (distance penalty)
  Hex 3: Wall → BLOCKED (0% damage to hexes beyond)

Direction 2 (open field):
  Hex 1: Unit (light armor) → Takes 40% damage (50% blocked + 40% armor resistance)
  Hex 2: Clear → Takes 80% damage (distance penalty)
  Hex 3: Unit (heavy armor) → Takes 30% damage (50% blocked + 5% armor resistance)
  Hex 4: Clear → Takes 60% damage (distance penalty)

Direction 3 (through multiple units):
  Hex 1: Unit (armor) → Takes 40% damage (wave continues)
  Hex 2: Unit (armor) → Takes 35% damage (cumulative distance + prior unit presence)
  Hex 3: Clear → Takes 70% damage (distance penalty)
```

**Key Design Points**:
- Walls completely stop explosions (binary: full block or no block)
- Units reduce but don't stop explosions (wave continues beyond units)
- Multiple waves propagate independently in each cardinal direction
- Each direction has separate line-of-sight checks and distance calculations
- Distance penalties apply within each direction separately

**Example Scenario** (Grenade with Force 10, Radius 4):
```
Base Damage: 10
Distance Scaling: 100% at hex 1, 80% hex 2, 60% hex 3, 40% hex 4

Direction 1 (North - open field):
  Hex 1: Unit with light armor (40% resistance)
    - Base: 10 damage
    - Armor blocks: 50%
    - Light armor: 40% additional resistance
    - Taken: 10 × 0.5 × 0.6 = 3 damage
  Hex 2: Clear
    - Base: 10 × 0.8 = 8 damage
  Hex 3: Unit with heavy armor (5% resistance)
    - Base: 10 × 0.6 = 6 damage
    - Armor blocks: 50%
    - Heavy armor: 5% additional
    - Taken: 6 × 0.5 × 0.95 = 2.85 ≈ 3 damage

Direction 2 (East - toward wall):
  Hex 1: Clear
    - Base: 10 damage
  Hex 2: Clear
    - Base: 10 × 0.8 = 8 damage
  Hex 3: Stone wall
    - BLOCKED (0% damage to hexes beyond wall)

Direction 3 (South - open field):
  Hex 1: Clear
    - Base: 10 damage
  Hex 2: Clear
    - Base: 10 × 0.8 = 8 damage
  Hex 3: Clear
    - Base: 10 × 0.6 = 6 damage
  Hex 4: Clear
    - Base: 10 × 0.4 = 4 damage

Direction 4 (West - open field):
  [Similar to Direction 3]
```

---

### 3. ENERGY
- **Source**: Plasma weapons, directed energy beams
- **Description**: High-temperature energy discharge
- **Armor Resistance**:
  - Light Armor: 20% reduction
  - Medium Armor: 40% reduction
  - Heavy Armor: 60% reduction
  - Energy Shield: 90% reduction
- **Weapon Examples**: Plasma rifles, energy cannons, particle beams

---

### 4. PSI (Psychic)
- **Source**: Alien psi weapons, mind-based attacks
- **Description**: Psychological/neurological damage
- **Armor Resistance**:
  - Light Armor: 0% reduction
  - Medium Armor: 0% reduction
  - Heavy Armor: 0% reduction
  - Energy Shield: 0% reduction
  - Psi Shield: 80% reduction (special)
- **Weapon Examples**: Alien psi blasts, mind control beams, neurological weapons
- **Note**: Armor does NOT protect against psi damage (bypasses physical protection)

---

### 5. STUN
- **Source**: Shock weapons, electrostatic discharge, concussive weapons
- **Description**: Non-lethal incapacitation damage
- **Armor Resistance**:
  - Light Armor: 70% reduction
  - Medium Armor: 50% reduction
  - Heavy Armor: 30% reduction
  - Energy Shield: 40% reduction
  - Insulated Armor (special): 95% reduction
- **Weapon Examples**: Stun batons, electro-shock rifles, shock grenades
- **Mechanics**: Applies Stun status (accumulates, -1/turn decay, triggers at threshold)

---

### 6. ACID
- **Source**: Alien acid attacks, chemical weapons
- **Description**: Corrosive chemical damage
- **Armor Resistance**:
  - Light Armor: 30% reduction
  - Medium Armor: 50% reduction
  - Heavy Armor: 70% reduction
  - Energy Shield: 0% reduction
  - Acid-Resistant Armor (special): 85% reduction
- **Weapon Examples**: Acid sprayers, corrosive grenades, alien acid attacks
- **Mechanics**: Deals damage + applies Corrosion status (reduces armor effectiveness on subsequent hits)

---

### 7. FIRE
- **Source**: Flame weapons, incendiary grenades, burning attacks
- **Description**: Thermal/burning damage
- **Armor Resistance**:
  - Light Armor: 40% reduction
  - Medium Armor: 50% reduction
  - Heavy Armor: 60% reduction
  - Energy Shield: 30% reduction
  - Fire-Resistant Armor (special): 80% reduction
- **Weapon Examples**: Flamethrowers, incendiary grenades, thermal weapons
- **Mechanics**: Deals damage + applies Burning status (damage over time, -1 HP/turn for 3 turns)

---

### 8. FROST
- **Source**: Cryo weapons, freeze attacks
- **Description**: Extreme cold damage and movement impairment
- **Armor Resistance**:
  - Light Armor: 50% reduction
  - Medium Armor: 40% reduction
  - Heavy Armor: 20% reduction
  - Energy Shield: 60% reduction
  - Thermal Armor (special): 75% reduction
- **Weapon Examples**: Cryo cannons, freeze grenades, cold-based weapons
- **Mechanics**: Deals damage + applies Frozen status (reduces movement speed 50%, lasts 2 turns)

---

## ARMOR MATERIALS & RESISTANCES

| Armor Type | Kinetic | Explosive | Energy | Psi | Stun | Acid | Fire | Frost |
|------------|---------|-----------|--------|-----|------|------|------|-------|
| **Light** | 50% | 40% | 20% | 0% | 70% | 30% | 40% | 50% |
| **Medium** | 30% | 20% | 40% | 0% | 50% | 50% | 50% | 40% |
| **Heavy** | 10% | 5% | 60% | 0% | 30% | 70% | 60% | 20% |
| **Reinforced** | 25% | 30% | 50% | 0% | 40% | 45% | 55% | 35% |
| **Alien Tech** | 15% | 35% | 70% | 20% | 20% | 40% | 50% | 45% |

**Key Notes**:
- Psi damage ignores all standard armor (0% reduction for all)
- Special armor types (Psi Shield, Insulated, Acid-Resistant, etc.) provide specific bonuses
- Modders can define custom armor combinations
- Armor effectiveness = Base Damage × (1 - Resistance%)

---

## SHIELD MECHANICS

Energy shields layer on top of armor:

| Shield Type | Kinetic | Explosive | Energy | Psi | Stun | Acid | Fire | Frost |
|-------------|---------|-----------|--------|-----|------|------|------|-------|
| **Standard** | 40% | 50% | 80% | 0% | 40% | 0% | 30% | 50% |
| **Advanced** | 50% | 60% | 90% | 30% | 50% | 20% | 40% | 60% |
| **Alien** | 60% | 70% | 95% | 60% | 60% | 40% | 50% | 70% |

**Shield Priority**: Shields absorb damage first, then remaining damage hits health/armor

---

## WEAPON ASSIGNMENT

### Faction Weapons by Damage Type

**Human**:
- Kinetic: Rifles, pistols (primary)
- Explosive: Grenades, mines
- Stun: Shock weapons (special training)
- Fire: Flamethrowers (support)

**Alien** (varies by species):
- Energy: Plasma weapons (common)
- Psi: Mind-based attacks (strong aliens)
- Acid: Acid sprayers (melee aliens)
- Stun: Paralysis (specialized aliens)

---

## ACCURACY IMPACT

Damage type does NOT affect accuracy directly. Accuracy calculation based on:
- Unit stat (Aim)
- Weapon bonus
- Cover modifier
- Range modifier
- Visibility

All damage types use same accuracy formula.

---

## FIRE MODES & DAMAGE SCALING

| Fire Mode | Damage | Spread | Accuracy Impact |
|-----------|--------|--------|-----------------|
| Single Shot | 1.0× | 0 | +20% accuracy |
| Burst | 0.8× per round | 5° spread | Normal accuracy |
| Full Auto | 0.6× per round | 10° spread | -15% accuracy |
| Charged (Energy) | 1.5× | 0 | -10% accuracy (charging time) |

---

## CRITICAL NOTES

### For Implementers
- Damage calculation: BaseDamage × (1 - ArmorResistance%) = FinalDamage
- Multiple armor types: Use best single armor resistance (not cumulative)
- Shields then armor: Shields reduce first, remaining damage reduced by armor
- Special ammo types can modify damage (e.g., "Incendiary Rounds" = Fire damage boost)

### For Modders
- Custom damage types: Engine supports adding custom types beyond these 8
- Custom armor types: Define via armor definitions with resistance percentages
- Resistance tables: Fully configurable per mod
- Balancing: Consider that Psi bypasses armor (design accordingly)

### For Designers
- Weapon variety: Mix damage types to require diverse armor strategies
- Difficulty scaling: Stronger enemies use more varied damage types
- Late-game progression: Introduce special armor types to counter specific threats

---

## FILE REFERENCES

**Canonical Source**: This file (DamageTypes.md)

**Reference from**:
- Battlescape.md § Damage Mechanics (damage calculation)
- Items.md § Weapons (weapon damage types)
- Units.md § Armor System (unit armor resistances)
- Crafts.md § Interception Armor (craft armor types)
- Glossary.md § Damage Type Abbreviations

**Do not duplicate**: All references to damage types should link to this document.

---

**Last Updated**: 2025-10-30
**Version**: 1.0 (Complete)
