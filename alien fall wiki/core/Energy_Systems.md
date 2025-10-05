# Energy Systems

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Tactical Energy Framework](#tactical-energy-framework)
  - [Operational Energy Framework](#operational-energy-framework)
  - [Energy Cost Structure](#energy-cost-structure)
  - [Regeneration Systems](#regeneration-systems)
  - [Equipment Integration](#equipment-integration)
  - [Energy Sources and Sinks](#energy-sources-and-sinks)
  - [Special States and Effects](#special-states-and-effects)
  - [Deterministic Processing](#deterministic-processing)
- [Examples](#examples)
  - [Tactical Energy Management](#tactical-energy-management)
  - [Operational Energy Management](#operational-energy-management)
  - [Ability Activation Scenarios](#ability-activation-scenarios)
  - [Equipment Energy Systems](#equipment-energy-systems)
  - [Regeneration Calculations](#regeneration-calculations)
  - [Cross-System Comparisons](#cross-system-comparisons)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

Energy Systems provide resource pool mechanics enabling special abilities and advanced capabilities beyond basic operational actions across tactical and operational gameplay contexts. Tactical Energy governs individual unit power reserves (typically 0-100) for abilities, heavy equipment operation, and enhanced movement modes during battlescape missions, while Operational Energy manages per-craft resources (typically 0-150) for weapon systems, tactical maneuvers, and defensive capabilities during interception combat. Both systems share fundamental principles—resource pool management, automatic regeneration, and strategic allocation decisions—while operating at different scales and temporal contexts.

The energy framework functions as a strategic constraint preventing ability spam while rewarding planning and resource management. Units and crafts maintain maximum energy capacity modified by equipment and status effects, with automatic end-of-turn or end-of-round regeneration creating sustainable combat rhythms. Energy costs scale with capability power, requiring players to balance burst damage potential against sustained operational effectiveness. Zero energy prevents special actions but maintains basic functionality, distinguishing energy depletion from complete incapacitation. Equipment integration enables energy storage expansion, regeneration acceleration, and emergency restoration creating meaningful upgrade paths and tactical variety.

## Mechanics

### Tactical Energy (Unit Energy)
- **Context:** Battlescape combat, individual unit actions
- **Scale:** Per-unit resource (typically 0-100)
- **Granularity:** Turn-based regeneration
- **Primary Use:** Special abilities, heavy equipment, movement modes
- **Reference:** [Units/Energy.md](../units/Energy.md)

### Operational Energy (Craft Energy)
- **Context:** Interception combat, craft systems
- **Scale:** Per-craft resource (typically 0-100)
- **Granularity:** Round-based regeneration
- **Primary Use:** Weapon systems, tactical maneuvers, special systems
- **Reference:** [Crafts/Energy.md](../crafts/Energy.md)

---

## Tactical Energy (Units)

### Core Mechanics

**Definition:** Per-unit resource pool that enables special abilities, heavy equipment usage, and advanced movement modes during battlescape missions.

**Key Properties:**
- **Base Pool:** Defined per unit type (typically 50-100 points)
- **Maximum Capacity:** Can be modified by equipment, traits, and temporary effects
- **Starting Value:** Units begin missions at full energy (configurable per mission type)
- **Regeneration:** Automatic recovery at the end of each unit's turn

### Energy Costs

**Ability Activation:**
```
Energy Cost = Ability Base Cost × Equipment Multiplier
```

**Heavy Equipment:**
- Heavy weapons may require energy to fire
- Powered armor consumes energy for protection/mobility
- Energy cost defined per item in data tables

**Movement Modes:**
- **Running:** Costs energy per tile moved (faster than walking)
- **Flying:** Costs energy per tile (if unit has flight capability)
- **Teleporting:** High energy cost for instant repositioning

### Regeneration

**End-of-Turn Restore:**
```
Restored Energy = Base Regeneration + Equipment Bonus - Wound Penalty
```

**Typical Values:**
- Base Regeneration: 20 energy per turn
- Equipment Bonus: 0-15 (powered armor, energy packs)
- Wound Penalty: -5 per wound level

**Special Cases:**
- Stunned units: No regeneration
- Panicked units: 50% regeneration
- Meditative states: 150% regeneration (special abilities)

### Energy and Equipment

**Energy Sources:**
- **Energy Clips:** One-time use items that restore energy
- **Power Generators:** Backpack items providing regeneration bonus
- **Charging Stations:** Map objects for mid-mission recharge

**Energy Sinks:**
- Plasma weapons (high damage, high energy cost)
- Psi abilities (proportional to effect power)
- Shield generators (continuous drain)

### Tactical Considerations

**Energy Management:**
- Players must balance burst damage (high energy abilities) vs. sustained combat
- Running out of energy doesn't incapacitate, but limits tactical options
- Some missions may feature energy drains (environmental hazards)

**Design Intent:**
- Prevents "spam" of powerful abilities
- Creates tactical decision points (save energy vs. use now)
- Rewards planning and resource management

---

## Operational Energy (Crafts)

### Core Mechanics

**Definition:** Per-craft resource pool that powers weapon systems, defensive maneuvers, and special systems during interception combat.

**Key Properties:**
- **Base Pool:** Defined per craft type (typically 50-150 points)
- **Maximum Capacity:** Modified by craft components (reactors, capacitors)
- **Starting Value:** Crafts begin interceptions at full energy
- **Regeneration:** Automatic recovery at end of each combat round

### Energy Costs

**Weapon Systems:**
```
Firing Cost = Weapon Base Cost × Range Multiplier
```

**Tactical Maneuvers:**
- **Evasive Action:** 20-30 energy (defensive bonus)
- **Aggressive Positioning:** 15-25 energy (accuracy bonus)
- **Emergency Retreat:** 50 energy (disengage from combat)

**Special Systems:**
- **Shields:** Continuous drain per round active
- **Cloaking:** High initial cost + maintenance
- **Sensor Boost:** Medium cost for improved detection

### Regeneration

**End-of-Round Restore:**
```
Restored Energy = Reactor Output - Active System Drain
```

**Typical Values:**
- Reactor Output: 30-50 energy per round
- Active System Drain: 0-20 (shields, cloaking, etc.)
- Net Regeneration: 10-50 per round

**Special Cases:**
- Damaged reactor: 50% regeneration
- Overheated weapons: Increased energy cost next round
- Emergency power: One-time boost of 50 energy (once per battle)

### Energy and Craft Design

**Energy Sources:**
- **Reactors:** Primary energy generation (upgraded through research)
- **Capacitors:** Increase maximum energy pool
- **Energy Cells:** Emergency consumables (one per mission)

**Energy Sinks:**
- Beam weapons (sustained fire, high cost)
- Missile systems (burst damage, moderate cost)
- Defensive systems (shields, countermeasures)

### Operational Considerations

**Energy Management:**
- Pilots must choose between offense (weapons) and defense (maneuvers)
- Long fights require energy conservation
- Some alien crafts have energy-draining weapons

**Design Intent:**
- Creates meaningful choices in interception combat
- Prevents "alpha strike" dominance
- Rewards balanced craft loadouts

---

## Cross-System Comparison

| Aspect | Tactical Energy (Units) | Operational Energy (Crafts) |
|--------|-------------------------|------------------------------|
| **Context** | Battlescape combat | Interception combat |
| **Scale** | Per-unit (0-100) | Per-craft (0-150) |
| **Refresh Rate** | Per unit turn (~6 seconds) | Per combat round (~30 seconds) |
| **Primary Use** | Abilities, equipment, movement | Weapons, maneuvers, systems |
| **Regeneration** | End of unit turn | End of combat round |
| **Typical Cost** | 10-30 per ability | 15-50 per action |
| **Zero Energy Impact** | No abilities, normal actions OK | No weapons/maneuvers, can flee |
| **Maximum Penalty** | Limited tactical options | Sitting duck vulnerability |

---

## Terminology Glossary

To avoid confusion between the two systems:

- **Energy** - Generic term for both systems
- **Unit Energy / Tactical Energy** - Battlescape unit resource
- **Craft Energy / Operational Energy** - Interception craft resource
- **Energy Pool** - Current/maximum energy capacity
- **Energy Cost** - Amount consumed by an action
- **Regeneration** - Automatic recovery per turn/round
- **Energy Source** - Item/component that provides energy
- **Energy Sink** - Item/component that consumes energy

---

## Implementation Notes

### Love2D Integration

**Data Tables:**
- `data/units/[unit_type].toml` - Unit energy pools and regeneration
- `data/crafts/[craft_type].toml` - Craft energy pools and reactors
- `data/items/weapons.toml` - Energy costs for weapons
- `data/abilities/[ability].toml` - Energy costs for special abilities

**Event Bus:**
- `energy:consumed` - Fired when energy is spent
- `energy:regenerated` - Fired at turn/round end
- `energy:depleted` - Fired when energy reaches zero
- `energy:restored` - Fired when energy items used

**State Management:**
- `battlescape_state.units[unit_id].energy_current`
- `interception_state.crafts[craft_id].energy_current`

### Deterministic Simulation

**Seed Usage:**
```
seed:energy:[context]:[id]:[turn]
```

Examples:
- `seed:energy:unit:soldier_01:turn_05` - Unit energy regeneration
- `seed:energy:craft:interceptor_01:round_03` - Craft energy regeneration

**Deterministic Events:**
- Regeneration amounts (if randomized)
- Critical energy failures (if percentage-based)
- Energy item drops (if procedural)

---

## Design Philosophy

**Why Two Systems?**
1. **Different Scales:** Units act individually, crafts act as platforms
2. **Different Contexts:** Turn-based vs. round-based combat
3. **Different Gameplay:** Tactical positioning vs. dogfighting
4. **Different Resource Curves:** Frequent small costs vs. burst spending

**Unified Principles:**
- Both systems create meaningful choices
- Both prevent ability spam
- Both reward planning over improvisation
- Both integrate with equipment systems

**Future Expansion:**
- Energy transfer between units (field recharging)
- Energy overload mechanics (risk/reward)
- Energy-based environmental hazards
- Cross-system energy (craft powering ground units)

---

## Cross-References

**Related Systems:**
- [Action Economy](Action_Economy.md) - How energy relates to AP
- [Capacity Systems](Capacity_Systems.md) - Weight vs. energy tradeoffs
- [Units/Energy](../units/Energy.md) - Detailed tactical energy mechanics
- [Crafts/Energy](../crafts/Energy.md) - Detailed operational energy mechanics

**Integration Points:**
- [Battlescape Combat](../battlescape/README.md) - Energy in tactical missions
- [Interception](../interception/README.md) - Energy in craft combat
- [Items System](../items/README.md) - Energy weapons and equipment
- [Abilities](../units/Abilities.md) - Energy-powered special actions

---

## Version History

- **v1.0 (2025-09-30):** Initial master document consolidating unit and craft energy systems
