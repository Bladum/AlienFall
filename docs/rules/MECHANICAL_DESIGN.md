# AlienFall Systems GDD (Rules and Mechanics)

**Single-source mechanics reference for AlienFall game design**

---

## Summary

This document is the **single-source mechanics reference**. It defines systems, data contracts, and processing steps with no story, examples, or setting-specific content. Pair with `lore.md` to reskin the game without changing rules.

**Table of Contents**
- 1. Top-level Contract
- 2. Design Ethos
- 3. Time and Pacing
- 4. Strategic Layer (Geoscape)
- 5. Facilities (Abstract Catalog)
- 6. Personnel and Roles
- 7. Materials and Research
- 8. Manufacturing and Logistics
- 9. Detection, Tracking, and Interception
- 10. Tactical Layer (Battlescape/Hydroscape/Dimensional)
- 11. Actions, Costs, and Initiative
- 12. Targeting, Accuracy, and Damage Pipeline
- 13. Morale, Panic, and Recovery
- 14. AI Behavior Contracts
- 15. Save/Load and Determinism Requirements

---

## 1. Top-level Contract

### Inputs & Outputs

**Inputs:**
- Player strategic choices (construction, staffing, R&D, deployments)
- Tactical choices (movement, targeting, item use)
- World events (object spawns)
- RNG seed

**Outputs:**
- Mission outcomes
- Salvage/materials
- Research progress
- Funding/panic deltas
- Roster changes
- Phase progression

### Success Definition

Outcomes are readable and skillful play reduces risk without removing tension.

---

## 2. Design Ethos

### Core Principles

- **Deterministic, data-driven subsystems** for AP accounting, LOS, accuracy, and reaction fire
- **RNG adds tension, not opacity** - randomness is transparent and repeatable
- **Separation of concerns**: Rules are story-agnostic; all narrative data lives in `lore.md` or content packs
- **Moddable contracts**: Clear interfaces between systems enable modding

---

## 3. Time and Pacing

### Strategic Time (Geoscape)
- Continuous, compressible time scale
- Monthly funding cycles and scheduled events
- Progress bars for construction, manufacturing, research
- Player can speed up (1×, 5×, 30×)

**Technical Details:**
- Tick duration: 5 minutes
- Ticks per hour: 12
- Ticks per day: 288
- Days per month: 30
- Months per year: 12

### Tactical Time (Battlescape)
- Discrete turns with Action Points (AP) per unit
- Reaction phase resolves before active turns
- Initiative determines turn order

**Design rule:** All turn order, AP, LOS, and rolls are reproducible with a seed.

---

## 4. Strategic Layer (Geoscape)

### 4.1 Nations and Funding

**Nation Model:**
```
{
  panic: 0..100,
  funding_rate: f,
  region: string,
  modifiers: {...}
}
```

**Funding Calculation:**
```
Funding_rate = base_rate × (1 − panic_effect) × diplomatic_modifiers
```

**Panic Thresholds:**
- 50: Warning threshold
- 75: Ultimatum issued
- 100: Funding withdrawal
- Propagation rules apply regionally (e.g., neighbor panic spreads)

### 4.2 Bases and Facilities

**Facility Model:**
- Exposes effects via typed modifiers
- Examples: detection_radius, track_quality, research_slots, production_slots, etc.

**Power System:**
```
if sum(draw) ≤ sum(output)
  ⇒ normal operation
else
  ⇒ staged penalties:
    1. Disable non-essentials
    2. Probabilistic outages on criticals (if deficit persists)
```

**Layout Constraints:**
- Adjacency and exterior tile requirements are declarative
- Adjacency may grant marginal throughput bonuses (e.g., +10% research speed)

### 4.3 Staff and Assignment

**Roles provide:**
- Additive and multiplicative modifiers to systems they influence
- Hiring has delay and recurring cost
- Global pools cap availability

### 4.4 Detection and Interception

**Detection Chance:**
```
P = function(distance, sensor_level, target_signature)
```

**Track Quality:**
- Determines intel fidelity
- Improves interception resolution
- Ranges 0.0 to 1.0

**Outcomes:**
- Escape
- Forced landing
- Crash (spawns tactical mission)

---

## 5. Facilities (Abstract Catalog)

All facility types are abstract; concrete names belong to content packs (lore.md).

| Facility Type | Primary Function | Key Modifiers |
|---------------|------------------|---------------|
| Living Quarters | Personnel housing | capacity |
| Laboratories | Research | research_slots, adjacency_speed_bonus |
| Workshops | Manufacturing | production_slots, adjacency_speed_bonus |
| Hangars | Craft storage/maintenance | craft_capacity, scramble_time |
| Storage | Item/material storage | capacity |
| Power Generators | Energy production | power_output, reliability |
| Sensor Arrays | Detection & tracking | detection_radius, track_quality |
| Base Defenses | Assault interception | intercept_strength |
| Containment | Live capture | capture_capacity, breach_probability |
| Specialized Labs | Advanced research | research_domains (unlocks), efficiency |

---

## 6. Personnel and Roles

### Role System

**Available Roles:**
- Soldiers
- Scientists
- Engineers
- Investigators
- Security
- Specialists (setting-agnostic subtypes)

**Per-Role Definition:**
- Base stats (raw capability)
- Assignment targets (which systems they support)
- Effects modifiers (research_speed, production_speed, detection_uptime, containment_stability, interceptor_effectiveness)

### Training & Progression

- Roles can gain ranks
- Ranks provide deterministic bonuses (no RNG)
- Example: Rank 1 Soldier = +5% accuracy, Rank 2 = +10%, etc.

---

## 7. Materials and Research

### 7.1 Materials

**Material Tagging System:**
- Abstract material types referenced by tags (e.g., `alloy`, `exotic_power`, `dimensional`)
- Concrete material names belong to content packs
- Materials gate manufacturing and research via resource costs

### 7.2 Research

**Project Contract:**
```
{
  id: string,
  prerequisites: [tech_ids, samples],
  cost: number,
  outputs: [blueprints, facilities, unit_upgrades],
  tags: [...]
}
```

**Research Throughput:**
- Scales with scientist count
- Diminishing returns beyond a threshold
- Formula: `throughput = scientist_count × efficiency × modifiers`

**Special Research:**
- Interrogations modeled as projects over captured entities
- Autopsies modeled as projects over salvaged items

---

## 8. Manufacturing and Logistics

### Workshop System

**Base Production:**
```
production_rate = production_slots × engineers × modifiers
```

**Queue Management:**
- Supports parallelization (limited by slot count)
- Partial progress persists across pauses
- Maintenance and upkeep costs apply monthly

### Encumbrance System

**Weight Calculation:**
```
encumbrance_factor = carried_weight / strength
```

**Encumbrance Tiers:**
- None: 0–25% capacity
- Light: 26–50% capacity
- Medium: 51–75% capacity
- Heavy: 76–100% capacity

**Effects by Tier:**
- Movement cost multiplier
- Aim penalty
- Max AP reduction

---

## 9. Detection, Tracking, and Interception

### Detection Formula

```
P = clamp(SensorPower × Signature / Distance² × modifiers)
```

- `SensorPower`: Cumulative detection capability
- `Signature`: Target visibility (larger = easier to detect)
- `Distance²`: Diminishing returns with range
- `modifiers`: Weather, cover, faction relations, etc.

### Track Quality

```
Q ∈ [0, 1]
```

- Increases with persistent contact
- Gates intel and engagement options
- Higher Q = better targeting, more information

### Interception Mechanics

**Resolution:**
```
outcome = opposed_roll(interceptor_effectiveness, target_defense)
  × modifiers(track_quality, loadouts)
```

---

## 10. Tactical Layer

### 10.1 Map and Tiles

**Tile Schema:**
```
{
  walkable: boolean,
  movement_cost: multiplier,
  cover_type: enum,
  elevation: integer,
  los_block: enum (none/partial/full),
  destructible_hp: integer or null,
  env_mods: {...}
}
```

### 10.2 Cover Mechanics

**Full Cover:**
- Blocks fire from many angles
- Provides maximum protection

**Transparent Cover:**
- Penalizes aim without blocking LOS fully
- Partial protection

---

## 11. Actions, Costs, and Initiative

### Action Types

**Fixed-cost Actions:**
```
AP = constant
```

**Percentage-cost Actions:**
```
AP = ceil(percentage × MaxAP)
```

### Initiative Order

```
turn_order = sort(units, initiative_stat, tie_breaker)
  where tie_breaker = (unit_id, previous_order)
```

### Reaction Fire

**Trigger:** Movement into LOS + reserved AP

**Formula:**
```
reaction_chance = base_chance × (reserved_AP / max_AP) × modifiers
```

---

## 12. Targeting, Accuracy, and Damage Pipeline

### Accuracy Calculation

```
Accuracy = base_weapon_accuracy
  × shooter_skill
  × stance_mods
  × movement_mods
  × cover_mods
  × env_mods
  × rng
```

### Firing Modes

**Modes: Snap, Aimed, Burst**

| Mode | AP Cost | Accuracy Mod | RoF | Ammo Use |
|------|---------|--------------|-----|----------|
| Snap | 1 | -10% | 1 | 1 |
| Aimed | 2 | +20% | 1 | 1 |
| Burst | 3 | 0% | 3-5 | 3-5 |

**Recoil & Aim Penalties:**
- Accumulate per-shot
- Automatic fire applies penalty per pellet/shot
- Resets at end of turn

### Damage Pipeline

```
rolled_damage
  → apply_resistances(damage_type)
  → apply_armor(penetration vs armor_value)
  → apply_status(bleed, stun, panic)
  → destructible_interactions
  → final_hp_delta
```

### Area Effects

- Resolve with falloff functions
- Friendly fire permitted (unless disabled by content pack)
- Blast radius = weapon-dependent

### Hit Chance Modifiers

**Base Hit Range:** 50-95%

**Modifiers Applied:**
- Range Penalty: -20% to -40% (beyond effective range)
- Target Movement Penalty: -10% (moving target)
- Cover Penalty: -20% (half cover) to -40% (full cover)
- High Ground Bonus: +20%
- Darkness Penalty: -15% to -30%
- Smoke Penalty: -20% to -40%
- Suppression Penalty: -30%
- Weapon Special Modifiers: ±10%

**Final Hit Chance:** Clamped to [min, max] range to avoid impossible extremes

### Critical Hits

**Mechanics:**
- Base chance: 10%
- Critical Multiplier: 1.5× damage
- Rare chance based on head/torso hit multiplier
- May cause instant incapacitation or bleeding

---

## 13. Morale, Panic, and Recovery

### Morale States

| State | Range | Effects |
|-------|-------|---------|
| High Morale | 80-100 | No penalties |
| Normal | 50-79 | Standard performance |
| Shaken | 30-49 | -10% accuracy, panic checks |
| Panicked | 0-29 | -30% accuracy, random actions |

### Morale Modifications

| Event | Delta | Scope |
|-------|-------|-------|
| Ally death | -10 | Nearby units |
| Take damage (significant) | -5 | Per hit |
| Enemy kill | +5 | Shooter + nearby allies |
| Victory (mission end) | +20 | All survivors |
| Defeat (mission end) | -15 | All survivors |

### Recovery Tests

- Occur each turn
- Base recovery chance: 30%
- Modifiers: Leadership aura, fear effects, containment status

### Post-Mission Recovery

- Wounds map to downtime (injuries heal over N days)
- Mental stress maps to fatigue (rest reduces fatigue)

---

## 14. AI Behavior Contracts

### Observable State Constraint

**Behavior trees or utility scores must:**
- Consume only observable state (no omniscience)
- Use seeded RNG (deterministic with seed)
- Respect fog of war

### Threat Assessment

**Priority Score:**
```
threat = proximity_penalty
  + vulnerability_bonus
  + objective_pressure
  + suppression_status
```

### Fog of War

- Enemy AI cannot see through LOS blockers
- Cannot detect units outside vision range
- **Cheating via omniscience is prohibited**

---

## 15. Save/Load and Determinism Requirements

### Determinism Contract

**All random decisions derive from:**
- Mission/strategic seed
- Context indices (turn number, unit ID, action sequence)

**Formula:**
```
rng_value = seeded_rand(seed + turn_number + unit_id + action_index)
```

### Save File Contents

- Seeds and counters
- Unit/object state
- Map state
- Fog of war per player
- RNG counter (for replay)

### Replay Guarantee

**Given identical inputs:**
- Identical seed
- Identical action sequence
- Identical world state

**Result:** Identical outcomes (deterministic replay)

---

## Weapons & Armor

### Armor System

**Armor by Location:**
- Head: 5-15 points
- Torso: 10-25 points
- Arms: 5-10 points (each)
- Legs: 5-10 points (each)

**Armor Reduction:**
- 1:1 ratio: Each armor point reduces incoming damage by 1
- Penetration value: Weapon-dependent (e.g., Plasma = +50% penetration)

### Weapons (Phase 0 - Shadow War)

**Standard Ballistic:**
- Common human firearms
- Effective against human factions and some supernatural entities

**BlackOps Weaponry:**
- Advanced, often silenced or specialized human-derived weapons

**Supernatural Countermeasures:**
- Specialized items for dealing with paranormal threats

---

## Firing Modes, Penalties & Rates

### Weapon Fire Modes

**Snap/Aim/Auto:**
- Defined by AP cost
- Accuracy modifier
- Recoil/multi-shot rules

### Recoil & Aim Penalties

- Accumulate per-shot
- Automatic fire applies penalty per pellet/shot
- Example: 1st shot at +0%, 2nd at -5%, 3rd at -10%, etc.

---

## Status Effects and Injuries

### Status Categories

| Status | Duration | Effect |
|--------|----------|--------|
| Stunned | 1-2 turns | Cannot act |
| Unconscious | Until healed | Helpless |
| Bleeding | Persistent | -2 HP/turn (severity-dependent) |
| Poisoned | 3-5 turns | -1 HP/turn + accuracy penalty |
| Panicked | Until morale recovers | Random movement/actions |
| Suppressed | 1-2 turns | -30% accuracy, hunkered down |
| Mind-controlled | Variable | Follows enemy commands |

### Injury Severity

**Bleeding Severity:**
- Minor: 1 HP/turn
- Moderate: 2 HP/turn
- Severe: 3-5 HP/turn (risk of bleeding out)

**Stacking Rules:**
- Multiple status effects can apply simultaneously
- Severity values don't add; take maximum of each type

---

## Campaign & Game Phases

### Phase System

Campaigns progress through phases:
1. **Phase 0: Shadow War** (Investigation, conventional warfare)
2. **Phase 1: First Contact** (Alien technology discovered)
3. **Phase 2: Escalation** (Alien capabilities increase)
4. **Phase 3: Endgame** (Final confrontation)

**Phase Progression:**
- Player research milestones
- Strategic events (invasion escalates)
- Funding/panic thresholds

---

## Balance Parameters (Tuning)

All these values are subject to tuning and balance testing:

### Action Economy
- AP per turn: 4 (can adjust 3-6)
- Move cost: 1 per tile (can adjust 0.5-2)
- Aimed shot cost: 2 AP (can adjust 1-3)

### Combat
- Base hit: 50-95% (can adjust 40-100%)
- Critical chance: 10% (can adjust 5-20%)
- Armor reduction: 1:1 (can adjust 0.5-2)

### Research & Manufacturing
- Early tech: 100-300 RP (can adjust 50-500)
- Research scale: linear by scientist (can add diminishing returns)

### Economy
- Starting credits: 1,000,000 (can adjust 500K-5M)
- Monthly salary: 2,000-5,000 per unit (can adjust 1K-10K)

---

## Extensibility & Modding

### Design for Mods

All systems are designed to be extended:
- **Material tagging**: Easy to add new material types
- **Roles and ranks**: Easy to add new roles or modify rank bonuses
- **Facilities**: Abstract types enable new facility definitions
- **Weapons**: Defined by data, not hard-coded
- **AI behaviors**: Plug-in system for custom AIs

### Content Pack Format

Mods provide content packs containing:
- Material definitions
- Weapon definitions
- Facility types
- Unit templates
- Mission templates
- Lore (story-specific content)

---

## See Also

- **[Game Numbers](GAME_NUMBERS.md)** - Specific numeric values for all systems
- **[FAQ](FAQ.md)** - Frequently asked questions about mechanics
- **[Combat System Documentation](COMBAT_SYSTEMS_COMPLETE.md)** - Detailed combat systems
- **[API Reference](API.md)** - Engine API for implementing these mechanics

---

**Document Version:** 1.0  
**Last Updated:** October 15, 2025  
**Status:** Reference Documentation - Living Document
