# Action Economy

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Tactical Action Points](#tactical-action-points)
  - [Operational Action Points](#operational-action-points)
  - [Action Cost Framework](#action-cost-framework)
  - [Movement Formula System](#movement-formula-system)
  - [Turn Structure and Phases](#turn-structure-and-phases)
  - [Fractional AP Handling](#fractional-ap-handling)
  - [AP Modifier System](#ap-modifier-system)
  - [Deterministic Resolution](#deterministic-resolution)
- [Examples](#examples)
  - [Tactical Combat Scenarios](#tactical-combat-scenarios)
  - [Operational Combat Scenarios](#operational-combat-scenarios)
  - [Movement Calculations](#movement-calculations)
  - [Action Optimization Strategies](#action-optimization-strategies)
  - [AP Modifier Applications](#ap-modifier-applications)
  - [Cross-Context Comparisons](#cross-context-comparisons)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

Action Economy defines the unified turn-based action budget system governing player decisions across tactical battlescape combat and operational interception engagements in AlienFall. This framework establishes Action Points (AP) as the primary currency for player agency, where the standard 4 AP budget appears consistently across contexts while representing vastly different temporal scales and action types. The deliberate parallelism creates intuitive player expectations through familiar numerical patterns while maintaining mechanical distinction between individual soldier actions (~6 second turns) and craft maneuvers (~30 second rounds).

The Action Economy system emphasizes clarity through explicit action costs, strategic depth through budget allocation decisions, and fairness through identical rules applied to player and AI entities. Unlike graduated penalty systems, action costs operate as discrete expenditures preventing hidden mechanics or unpredictable outcomes. The framework integrates seamlessly with movement systems, energy management, and equipment capabilities while maintaining deterministic behavior through seeded randomization for testing and replay validation.

## Mechanics

### Tactical AP (Battlescape Units)
- **Context:** Individual soldier turns in tactical combat
- **Typical Budget:** 4 AP per turn
- **Time Scale:** ~6 seconds per turn (narrative time)
- **Primary Use:** Movement, shooting, abilities, items
- **Reference:** [Units/Action Points.md](../units/Action points.md)

### Operational AP (Interception Crafts)
- **Context:** Craft maneuvers during air combat
- **Typical Budget:** 4 AP per round
- **Time Scale:** ~30 seconds per round (narrative time)
- **Primary Use:** Positioning, firing weapons, special maneuvers
- **Reference:** [Interception/Air Battle.md](../interception/Air Battle.md)

### Strategic AP (Geoscape) - Time-Based
- **Context:** Strategic layer time progression
- **Typical Budget:** N/A (continuous time, not turn-based)
- **Time Scale:** 5-minute increments, variable speed (1×/5×/30×)
- **Primary Use:** Travel time, construction time, research time
- **Reference:** [Geoscape/World.md](../geoscape/World.md)

---

## Tactical AP (Battlescape Units)

### Core Mechanics

**Turn Budget:**
```
AP_per_turn = Base_AP (typically 4)
```

**Design Note:** 4 AP is deliberate parallel to XCOM mechanics for player familiarity.

### Action Costs

**Movement:**
```
AP_cost = Distance × Movement_Cost_Per_Tile
Movement_Cost = Base_Cost × Terrain_Modifier

Examples:
- Walk 4 tiles on flat ground: 1 AP per tile = 4 AP total
- Walk 2 tiles through water: 2 AP per tile = 4 AP total
- Run 8 tiles: 0.5 AP per tile = 4 AP total (uses Energy)
```

**Combat Actions:**
```
[action.aimed_shot]
ap_cost = 3

[action.snap_shot]
ap_cost = 1

[action.burst_fire]
ap_cost = 2

[action.reload]
ap_cost = 1
```

**Utility Actions:**
```
[action.use_medkit]
ap_cost = 2

[action.throw_grenade]
ap_cost = 2

[action.open_door]
ap_cost = 1

[action.interact_object]
ap_cost = 1-3  # Variable by object
```

### Movement Formula

**Definitive Movement Calculation:**
```
Tiles_Moved = (Speed × AP_Spent) / Terrain_Modifier

Where:
- Speed: Unit stat (typically 8-12)
- AP_Spent: How many AP allocated to movement
- Terrain_Modifier: 1.0 (flat) to 3.0 (deep water)
```

**Example Calculations:**

**Fast Soldier (Speed 12):**
```
Flat ground (modifier 1.0):
  1 AP → 12 tiles
  2 AP → 24 tiles
  4 AP → 48 tiles

Rough terrain (modifier 2.0):
  1 AP → 6 tiles
  2 AP → 12 tiles
  4 AP → 24 tiles
```

**Slow Soldier (Speed 8):**
```
Flat ground (modifier 1.0):
  1 AP → 8 tiles
  2 AP → 16 tiles
  4 AP → 32 tiles

Water (modifier 3.0):
  1 AP → 2.67 tiles (round down to 2)
  2 AP → 5.33 tiles (round down to 5)
  4 AP → 10.67 tiles (round down to 10)
```

### Fractional AP Handling

**Rounding Rules:**
- Movement distance: **Round down** (conservative)
- AP costs: **Round up** (can't spend partial AP)
- AP regeneration: Always full amount (no fractional carry-over)

### Turn Structure

**Phase Sequence:**
1. **Turn Start:** AP restored to maximum (typically 4)
2. **Action Phase:** Player/AI spends AP on actions
3. **Reaction Fire:** Enemy reaction fire (doesn't cost AP for reactor)
4. **Turn End:** Unused AP discarded (no banking)

**Important:** Unused AP does NOT carry over to next turn.

---

## Operational AP (Interception Crafts)

### Core Mechanics

**Round Budget:**
```
AP_per_round = Base_AP (typically 4)
```

**Design Note:** Same number (4) as tactical AP for UI consistency, but represents different time scale and action types.

### Action Costs

**Weapon Firing:**
```
[weapon.autocannon]
ap_cost = 1  # Fast firing

[weapon.plasma_beam]
ap_cost = 3  # Sustained beam

[weapon.fusion_missile]
ap_cost = 2  # Burst fire
```

**Maneuvers:**
```
[maneuver.evasive_action]
ap_cost = 2  # Defensive positioning

[maneuver.aggressive_approach]
ap_cost = 2  # Offensive positioning

[maneuver.emergency_retreat]
ap_cost = 4  # Full AP commitment to disengage
```

**Special Systems:**
```
[system.activate_shields]
ap_cost = 1  # Quick activation

[system.deploy_countermeasures]
ap_cost = 1  # Reactive defense

[system.sensor_sweep]
ap_cost = 0  # Passive system (energy cost only)
```

### Round Structure

**Phase Sequence:**
1. **Round Start:** All crafts restore AP to maximum
2. **Simultaneous Actions:** All crafts declare actions
3. **Resolution Phase:** Actions resolve based on initiative
4. **Round End:** Status effects update, energy regenerates

**Key Difference from Tactical:** Interception is **simultaneous** (all crafts act), not sequential (one unit at a time).

---

## Strategic "AP" (Geoscape Time)

### Time-Based Resource

**Not Actually AP:**
- Geoscape doesn't use action points
- Uses continuous time progression
- Actions have **duration** (hours/days) not **cost** (AP)

**Time Increments:**
```
1 tick = 5 minutes game time
1 hour = 12 ticks
1 day = 288 ticks
```

**Time Speeds:**
- **1× Speed:** Real-time progression (5 minutes per tick)
- **5× Speed:** Fast-forward (25 minutes per tick)
- **30× Speed:** Ultra-fast (2.5 hours per tick)

### Duration-Based Actions

**Craft Travel:**
```
Travel_Time = Distance / Craft_Speed
```

**Construction:**
```
[facility.laboratory]
construction_time = 720  # 720 ticks = 60 hours = 2.5 days
```

**Research:**
```
[research.laser_weapons]
research_time = 1440  # 1440 ticks = 120 hours = 5 days
```

**Manufacturing:**
```
[manufacture.laser_rifle]
manufacture_time = 360  # 360 ticks = 30 hours = 1.25 days
production_quantity = 5  # 5 rifles per batch
```

---

## Cross-Context Comparison

| Aspect | Tactical AP (Units) | Operational AP (Crafts) | Strategic Time (Geoscape) |
|--------|---------------------|-------------------------|---------------------------|
| **Budget** | 4 AP per turn | 4 AP per round | N/A (continuous) |
| **Time Scale** | ~6 seconds per turn | ~30 seconds per round | 5 minutes per tick |
| **Action Type** | Movement, shooting, items | Weapons, maneuvers | Travel, construction |
| **Resolution** | Sequential (unit by unit) | Simultaneous (all crafts) | Continuous (time-based) |
| **Carryover** | No (discard unused) | No (discard unused) | N/A (time always flows) |
| **Interrupts** | Reaction fire (enemy) | Countermeasures (reactive) | Events (pause time) |
| **Player Control** | Direct action selection | Direct action selection | Speed control (1×/5×/30×) |

---

## AP Equivalence Guide

**Why Same Number (4 AP)?**

The deliberate choice to use 4 AP across both tactical and operational contexts is a **UI/UX decision**, not a mechanical coincidence:

1. **Familiarity:** Players learn "4 AP = one turn's actions" once
2. **Consistency:** Visual AP indicators look the same
3. **Intuition:** "Half my AP" means same proportion in any context
4. **Simplicity:** No mental conversion between systems

**But Meanings Differ:**

- **Tactical 4 AP:** Enough to move full Speed stat distance OR fire aimed shot + reload OR use 4 items
- **Operational 4 AP:** Enough to fire 4 autocannon bursts OR 1 beam weapon + 1 maneuver OR emergency retreat
- **Strategic "4 units":** Doesn't exist—time is continuous, not chunked

---

## Advanced Mechanics

### AP Modifiers

**Tactical (Units):**
```
Bonus AP Sources:
- Stimulants (+1 AP for 3 turns, then -1 AP penalty)
- Lightning Reflexes trait (+1 AP permanent)
- Overwatch mode (spend AP to enable reaction fire)

AP Penalties:
- Wounded (-1 AP if below 50% health)
- Panicked (randomized AP, typically reduced)
- Stunned (0 AP, cannot act)
```

**Operational (Crafts):**
```
Bonus AP Sources:
- Ace Pilot (+1 AP permanent)
- Afterburners (+1 AP for 2 rounds, then cooldown)
- Emergency Protocols (sacrifice shields for +2 AP)

AP Penalties:
- Damaged engines (-1 AP if below 50% integrity)
- EMP effect (-2 AP for 1 round)
- System overload (0 AP, cannot act)
```

### AP Optimization Strategies

**Tactical:**
- **Positioning First:** Move to cover, then shoot (if AP allows)
- **Action Order:** Reload before turn ends (don't waste 1 AP walking)
- **AP Banking:** No carry-over, so always spend full budget
- **Synergy:** Snap shot (1 AP) leaves 3 AP for movement

**Operational:**
- **Weapon Selection:** Mix fast (1 AP) and slow (3 AP) weapons
- **Maneuver Timing:** Evasive action (2 AP) before enemy turn
- **Emergency Reserves:** Save 4 AP for retreat option
- **Energy Balance:** Don't spend AP if no energy to fire

---

## UI/UX Display

### AP Indicators

**Battlescape Unit Display:**
```
╔═══════════════════════╗
║ CPL. MARTINEZ         ║
║ [●●●●] 4/4 AP         ║
║ [██████] 24/30 Health ║
╚═══════════════════════╝
```

**Interception Craft Display:**
```
╔═══════════════════════╗
║ SKYRANGER-1           ║
║ [●●●●] 4/4 AP         ║
║ [██████] 120/150 HP   ║
╚═══════════════════════╝
```

**Action Preview:**
```
┌───────────────┐
│ SNAP SHOT     │
│ Cost: 1 AP    │
│ Remaining: 3  │
└───────────────┘
```

### Grid Alignment
- AP pips: 1 grid unit each (20px diameter)
- AP bar: 4 grid units wide (80px)
- Action buttons: 4×2 grid units (80×40px)

---

## Design Philosophy

### Why Action Points?

**Benefits:**
1. **Clear Budget:** Players know exactly how much they can do
2. **Strategic Depth:** Decisions between move/shoot/utility
3. **Fair AI:** Both player and AI follow same rules
4. **Predictability:** No hidden variables or RNG in action costs

**Alternatives Rejected:**
- **Real-time:** Too frantic for strategy game
- **Free actions:** Too exploitable (kiting, save-scumming)
- **Stamina:** Too complex with AP + Energy systems
- **Variable AP:** Too unpredictable (frustrating for players)

### Typical Turn Patterns

**Aggressive Play (Tactical):**
- 2 AP: Move to flank position
- 2 AP: Burst fire at enemy
- Result: Offensive pressure

**Defensive Play (Tactical):**
- 1 AP: Move to cover
- 2 AP: Aimed shot
- 1 AP: Reload
- Result: Prepared for next turn

**Balanced Play (Operational):**
- 1 AP: Fire autocannon
- 2 AP: Evasive maneuver
- 1 AP: Activate shields
- Result: Offense + Defense

---

## Implementation Notes

### Love2D Integration

**Data Tables:**
```toml
# data/units/[unit_type].toml
[action_points]
base_ap = 4
bonus_ap = 0  # From traits/equipment

# data/actions/[action].toml
ap_cost = 2
requires_ap = true

# data/crafts/[craft_type].toml
[interception]
base_ap = 4
bonus_ap = 0  # From pilot skills
```

**Event Bus:**
- `ap:turn_start` - Fired when AP refreshes
- `ap:action_spent` - Fired when AP consumed
- `ap:insufficient` - Fired when action can't be afforded
- `ap:turn_end` - Fired when turn ends (discard unused)

**State Management:**
```lua
-- Tactical AP
local unit_ap = {
    current = 4,
    maximum = 4,
    spent = 0
}

-- Operational AP
local craft_ap = {
    current = 4,
    maximum = 4,
    spent = 0
}

-- AP spending
function spend_ap(entity, cost)
    if entity.ap.current >= cost then
        entity.ap.current = entity.ap.current - cost
        entity.ap.spent = entity.ap.spent + cost
        return true
    end
    return false
end

-- AP refresh
function refresh_ap(entity)
    entity.ap.current = entity.ap.maximum
    entity.ap.spent = 0
end
```

### Deterministic Simulation

**Seed Usage:**
```
seed:ap:[context]:[id]:[turn]
```

**Deterministic Events:**
- AP bonus rolls (traits, equipment)
- AP penalty durations (stims, wounds)
- AP-based AI decisions (utility AI uses AP budget)

**Non-Deterministic:**
- Player AP spending (intentional player agency)
- AP allocation order (player choice)

---

## Cross-References

**Related Systems:**
- [Energy Systems](Energy_Systems.md) - AP vs. Energy distinction
- [Capacity Systems](Capacity_Systems.md) - Weight doesn't affect AP
- [Time Systems](Time_Systems.md) - AP time scales and narrative time
- [Units/Action Points](../units/Action points.md) - Detailed tactical mechanics
- [Interception/Air Battle](../interception/Air Battle.md) - Operational AP details

**Integration Points:**
- [Battlescape Combat](../battlescape/README.md) - Tactical turn structure
- [Interception System](../interception/README.md) - Craft combat rounds
- [Geoscape Operations](../geoscape/README.md) - Strategic time management
- [AI Decision Making](../ai/README.md) - AP-based utility AI

---

## Version History

- **v1.0 (2025-09-30):** Initial master document consolidating AP across all contexts
