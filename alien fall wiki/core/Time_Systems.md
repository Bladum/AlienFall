# Time Systems

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Strategic Time Progression](#strategic-time-progression)
  - [Operational Time Framework](#operational-time-framework)
  - [Tactical Time Structure](#tactical-time-structure)
  - [Time Conversion System](#time-conversion-system)
  - [Speed Multiplier System](#speed-multiplier-system)
  - [Time-Dependent Events](#time-dependent-events)
  - [Pause and Resume Logic](#pause-and-resume-logic)
  - [Deterministic Time Processing](#deterministic-time-processing)
- [Examples](#examples)
  - [Geoscape Time Calculations](#geoscape-time-calculations)
  - [Interception Time Flow](#interception-time-flow)
  - [Battlescape Time Flow](#battlescape-time-flow)
  - [Cross-Layer Time Transitions](#cross-layer-time-transitions)
  - [Duration-Based Operations](#duration-based-operations)
  - [Time Display Formats](#time-display-formats)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

Time Systems coordinate temporal progression across three distinct hierarchical layers in AlienFall—Strategic continuous time on the geoscape (5-minute tick increments), Operational round-based time during interception combat (~30 second rounds), and Tactical turn-based time during battlescape missions (~6 second turns). This multi-scale framework enables coherent gameplay where strategic planning occurs over days and weeks, operational engagements resolve in minutes, and tactical battles unfold across seconds-long unit actions. The system maintains narrative consistency through defined time relationships while supporting gameplay requirements for pausable strategic management, simultaneous operational combat, and sequential tactical decision-making.

The temporal architecture emphasizes deterministic progression through tick-based advancement, scalable pacing through variable speed multipliers (1×, 5×, 30×), and seamless context transitions preserving time continuity across saves and scene changes. Strategic time advances continuously during normal gameplay with automatic pausing on critical events (interceptions, mission windows, monthly reports), while operational and tactical layers exist as discrete combat instances resuming strategic time upon completion. All time-dependent systems (research, construction, travel, recovery) operate on unified tick calculations enabling consistent duration tracking and event scheduling across the entire campaign timeline.

## Mechanics

```
Strategic Layer (Geoscape)
├─ Real-world time: Continuous progression
├─ Game time: 5-minute increments
└─ Speed modes: 1×, 5×, 30× multipliers

Operational Layer (Interception)
├─ Combat rounds: ~30 seconds each (simulated)
├─ Turn-based: All crafts act simultaneously
└─ Time paused: Player decides actions

Tactical Layer (Battlescape)
├─ Combat turns: ~6 seconds each (abstracted)
├─ Turn-based: Units act sequentially
└─ Time paused: Player decides actions
```

---

## Strategic Time (Geoscape)

### Core Time Unit

**Base Increment:**
```
1 tick = 5 minutes game time
```

**Time Conversions:**
```
1 hour   = 12 ticks
1 day    = 288 ticks
1 week   = 2,016 ticks
1 month  = 8,640 ticks (30-day month)
1 year   = 103,680 ticks (360-day year)
```

**Design Note:** Uses 360-day year (12 months × 30 days) for simplicity—no leap years, no variable month lengths.

### Time Speed Modes

**Speed Multipliers:**
```
[speed_mode.paused]
multiplier = 0
description = "Time stopped"

[speed_mode.normal]
multiplier = 1
tick_duration = 5 minutes
description = "Real-time progression"

[speed_mode.fast]
multiplier = 5
effective_tick = 25 minutes
description = "Fast-forward"

[speed_mode.ultra]
multiplier = 30
effective_tick = 150 minutes (2.5 hours)
description = "Ultra fast-forward"
```

**UI Display:**
```
┌──────────────────────┐
│ ▶ 1× ▶▶ 5× ▶▶▶ 30×  │
│ Current: 5×          │
│ Date: MAR 15, 2084   │
│ Time: 14:35          │
└──────────────────────┘
```

### Time-Based Events

**Scheduled Events:**
```lua
event = {
    trigger_time = 72000,  -- Ticks since game start
    type = "alien_mission",
    province_id = "province_042"
}
```

**Duration-Based Actions:**
```
Research Project:
  Start: Day 1, 08:00 (tick 2304)
  Duration: 1440 ticks (5 days)
  End: Day 6, 08:00 (tick 3744)

Craft Travel:
  Start: Day 10, 12:00 (tick 5760)
  Duration: 360 ticks (30 hours)
  End: Day 11, 18:00 (tick 6120)
```

### Time Progression Rules

**Pausable Events:**
- Interception detected (auto-pause)
- Mission window appeared (auto-pause)
- Research completed (notification, optional pause)
- Construction finished (notification, optional pause)
- Funding report (monthly, auto-pause)

**Unpausable:**
- Background craft movement continues while paused
- UFO detection scans continue
- Time-locked events (sunrise/sunset) update when unpaused

---

## Operational Time (Interception)

### Round Duration

**Simulated Time:**
```
1 round ≈ 30 seconds of narrative combat time
```

**Design Note:** This is abstracted—not literally 30 seconds of real-time gameplay.

### Round Structure

**Phase Timing:**
```
Round N:
  1. Initiative Phase (instant)
  2. Action Declaration (player time, unlimited)
  3. Resolution Phase (simulated 30 seconds)
  4. Status Update (instant)
  → Round N+1 begins
```

**Typical Combat Duration:**
```
Short fight:  3-5 rounds (90-150 seconds narrative time)
Medium fight: 6-10 rounds (180-300 seconds narrative time)
Long fight:   11-20 rounds (330-600 seconds narrative time)
```

### Time-Dependent Mechanics

**Cooldowns:**
```
[ability.afterburners]
duration = 2 rounds (60 seconds narrative time)
cooldown = 5 rounds (150 seconds narrative time)

[ability.emergency_shields]
duration = 1 round (30 seconds narrative time)
cooldown = 10 rounds (300 seconds narrative time)
```

**Persistent Effects:**
```
[effect.evasive_maneuver]
duration = 1 round
stacks = false  # Cannot refresh, must wait for expiry

[effect.emp_disruption]
duration = 3 rounds
stacks = false
```

### Interception Time Flow

**Entry:**
```
Geoscape time: Day 5, 10:30
Interception begins: Geoscape paused
Combat duration: 8 rounds (4 minutes narrative time)
Geoscape resumes: Day 5, 10:34
```

**Geoscape Impact:**
```
# Minor time cost for interception
interception_duration = rounds × 30 seconds
geoscape_ticks_advanced = ceil(interception_duration / 300)  # 5-min ticks

Examples:
- 5 rounds = 150 seconds = 1 tick (5 minutes rounded)
- 15 rounds = 450 seconds = 2 ticks (10 minutes rounded)
```

---

## Tactical Time (Battlescape)

### Turn Duration

**Abstracted Time:**
```
1 turn ≈ 6 seconds of narrative combat time
```

**Design Note:** Based on XCOM precedent—allows reasonable actions per turn while maintaining tension.

### Turn Structure

**Phase Timing:**
```
Unit Turn:
  1. Turn Start (AP refresh, instant)
  2. Action Phase (player time, unlimited)
  3. Reaction Fire Phase (enemy responses, instant)
  4. Turn End (status updates, instant)
  → Next unit's turn begins
```

**Typical Mission Duration:**
```
Quick mission:   10-20 turns (60-120 seconds narrative time)
Standard mission: 20-40 turns (120-240 seconds narrative time)
Long mission:    40-80 turns (240-480 seconds narrative time)
```

**Full Round:**
```
1 full round = All units (player + AI) complete their turns
Round duration = (Number of units × 6 seconds)

Example: 12 units total → 72 seconds per full round
```

### Time-Dependent Mechanics

**Duration Effects:**
```
[effect.stim_pack]
duration = 5 turns (30 seconds narrative time)
bonus_ap = 1
penalty_after = -1 AP for 3 turns

[effect.smoke_grenade]
duration = 3 turns (18 seconds narrative time)
sight_reduction = -50%
```

**Bleed-Out Timers:**
```
[unit_state.bleeding_out]
duration = 3 turns (18 seconds narrative time)
death_on_expiry = true
stabilize_with = medkit
```

### Mission Time Flow

**Entry:**
```
Geoscape time: Day 7, 14:00
Mission begins: Geoscape paused
Mission duration: 35 turns (210 seconds = 3.5 minutes narrative time)
Post-mission: 5 minutes debrief/evac
Geoscape resumes: Day 7, 14:09 (rounded to 14:10)
```

**Geoscape Impact:**
```
# Mission time cost
mission_narrative_time = turns × 6 seconds
evac_time = 300 seconds (5 minutes)
total_time = mission_narrative_time + evac_time
geoscape_ticks_advanced = ceil(total_time / 300)  # 5-min ticks

Examples:
- 30 turn mission = 180s + 300s = 480s = 2 ticks (10 minutes)
- 60 turn mission = 360s + 300s = 660s = 3 ticks (15 minutes)
```

---

## Time Conversion Reference

### Narrative Time to Game Time

**Battlescape Turn → Geoscape:**
```
1 turn = 6 seconds narrative
→ Insignificant to geoscape (sub-tick resolution)
→ Rounded up to nearest 5-minute tick on mission end
```

**Interception Round → Geoscape:**
```
1 round = 30 seconds narrative
→ Insignificant to geoscape (sub-tick resolution)
→ Rounded up to nearest 5-minute tick on combat end
```

**Geoscape Tick → Real-World:**
```
1 tick = 5 minutes game time
→ No fixed real-world duration (speed-dependent)
→ 1× speed: Could take 5 real seconds, 30 seconds, or more
→ 30× speed: 150 minutes game time passes very fast
```

### Time Scale Relationships

```
Strategic Scale (Geoscape):
1 tick = 5 minutes
├─ Operational Scale (Interception):
│  1 round = 30 seconds
│  10 rounds ≈ 1 tick
│  └─ Not directly related (different temporal contexts)
│
└─ Tactical Scale (Battlescape):
   1 turn = 6 seconds
   50 turns ≈ 1 tick
   └─ Not directly related (different temporal contexts)
```

---

## Time-Dependent Systems

### Research & Development

**Research Duration:**
```
[research.laser_weapons]
base_time = 1440 ticks (5 days)
scientist_bonus = -10% per scientist (max -50%)
lab_bonus = -20% per advanced lab

Effective time = base_time × (1 - scientist_bonus) × (1 - lab_bonus)
```

**Manufacturing Duration:**
```
[manufacture.laser_rifle]
unit_time = 360 ticks (1.25 days per rifle)
engineer_bonus = -5% per engineer (max -50%)
workshop_bonus = -10% per workshop

Batch time = unit_time × quantity × (1 - engineer_bonus) × (1 - workshop_bonus)
```

### Construction

**Facility Construction:**
```
[facility.laboratory]
construction_time = 720 ticks (2.5 days)
parallel_construction = true  # Multiple facilities can build simultaneously

[facility.hangar]
construction_time = 1440 ticks (5 days)
prerequisite = adjacent_hangar_or_edge  # Special placement rule
```

### Craft Operations

**Travel Time:**
```
Travel_ticks = Distance_km / (Craft_speed_kmh / 12)

Example:
Distance: 1000 km
Craft speed: 2000 km/h
Travel time: 1000 / (2000 / 12) = 6 ticks (30 minutes)
```

**Refueling:**
```
[craft.interceptor]
refuel_time = 144 ticks (12 hours)

[craft.transport]
refuel_time = 288 ticks (24 hours)
```

**Repair:**
```
Repair_time = (Damage_percent × Base_repair_time) / Engineer_count

Example:
Damage: 50%
Base repair: 1440 ticks (5 days)
Engineers: 5
Repair time: (0.5 × 1440) / 5 = 144 ticks (12 hours)
```

### Personnel

**Recovery Time:**
```
[wound.light]
recovery_time = 1440 ticks (5 days)

[wound.serious]
recovery_time = 4320 ticks (15 days)

[wound.grave]
recovery_time = 8640 ticks (30 days)
```

**Training:**
```
[training.psi_lab]
session_duration = 2880 ticks (10 days)
progress_roll = daily  # Every 288 ticks
```

---

## Time Display Formats

### Date/Time Display

**Primary Format:**
```
MMM DD, YYYY  HH:MM
MAR 15, 2084  14:35
```

**Short Format:**
```
DD/MM/YY
15/03/84
```

**Duration Format:**
```
Xd Yh Zm
5d 12h 30m (5 days, 12 hours, 30 minutes)
```

### UI Time Widgets

**Geoscape Clock:**
```
┌─────────────────────┐
│ ▶ 5×                │
│ MAR 15, 2084 14:35  │
│ Day 45 of Operation │
└─────────────────────┘
```

**Duration Countdown:**
```
┌──────────────────┐
│ Research:        │
│ [████████░░] 80% │
│ 1d 4h remaining  │
└──────────────────┘
```

**Mission Timer:**
```
┌─────────────────┐
│ Turn: 12/∞      │
│ Time: 01:12     │
│ (72 sec elapsed)│
└─────────────────┘
```

---

## Time Synchronization

### Save/Load Consistency

**Saved State:**
```lua
game_state = {
    current_tick = 45720,  -- Absolute game time
    date = { year = 2084, month = 3, day = 15, hour = 14, minute = 35 },
    speed = 5,  -- Current speed multiplier
    paused = false,
    
    -- Time-sensitive entities
    research_projects = { {id = 1, start_tick = 44280, duration = 1440} },
    craft_movements = { {id = 1, start_tick = 45600, arrival_tick = 45960} },
    constructions = { {id = 1, start_tick = 45000, completion_tick = 45720} }
}
```

**Tick Update:**
```lua
function update(dt)
    if not game_state.paused then
        local tick_delta = dt * game_state.speed
        game_state.current_tick = game_state.current_tick + tick_delta
        
        -- Update all time-dependent systems
        update_research(game_state.current_tick)
        update_craft_movement(game_state.current_tick)
        update_constructions(game_state.current_tick)
    end
end
```

### Deterministic Time Events

**Seeded Event Timing:**
```
seed:time:event:[event_type]:[scheduled_tick]
```

**Examples:**
```
seed:time:event:alien_mission:72000
seed:time:event:funding_report:8640
seed:time:event:random_event:45120
```

---

## Implementation Notes

### Love2D Integration

**Data Tables:**
```toml
# data/config/time.toml
[time_config]
tick_duration = 300  # 5 minutes in seconds
base_speed = 1
max_speed = 30
year_days = 360
month_days = 30

# data/research/[research].toml
[research.laser_weapons]
duration_ticks = 1440
```

**Event Bus:**
- `time:tick` - Fired every game tick
- `time:hour` - Fired every 12 ticks
- `time:day` - Fired every 288 ticks
- `time:month` - Fired every 8640 ticks
- `time:speed_changed` - Fired when speed multiplier changes
- `time:paused` - Fired when game pauses
- `time:resumed` - Fired when game resumes

**State Management:**
```lua
time_state = {
    current_tick = 0,
    speed = 1,
    paused = false,
    last_update = love.timer.getTime()
}
```

---

## Design Philosophy

### Why Multiple Time Scales?

**Strategic (Continuous):**
- Emphasizes long-term planning
- Allows asynchronous events (multiple crafts, multiple bases)
- Reflects management simulation roots

**Operational (Round-Based):**
- Provides tactical decision-making without overwhelming detail
- Simultaneous resolution mirrors aerial combat reality
- Faster pace than tactical combat

**Tactical (Turn-Based):**
- Maximum strategic depth per unit
- Clear feedback for player decisions
- Sequential resolution allows reaction fire

### Time Budget Philosophy

**Player Time (Real):**
- Unlimited decision time (pause anytime)
- No pressure during tactical decisions
- Fast-forward available for downtime

**Narrative Time (Fiction):**
- Missions take minutes, not hours
- Research takes days, not years
- Campaign spans months, not decades

**Game Time (Simulation):**
- Tick-based for determinism
- Scalable speed for pacing
- Discrete events for save/load consistency

---

## Cross-References

**Related Systems:**
- [Action Economy](Action_Economy.md) - AP per turn/round timing
- [Energy Systems](Energy_Systems.md) - Energy regeneration timing
- [Geoscape Operations](../geoscape/README.md) - Strategic time usage
- [Battlescape Combat](../battlescape/README.md) - Tactical turn timing
- [Interception System](../interception/README.md) - Operational round timing

**Integration Points:**
- [Research System](../economy/README.md) - Time-based progression
- [Craft Operations](../geoscape/Craft Operations.md) - Travel time
- [Construction](../basescape/README.md) - Build time
- [Personnel](../organization/README.md) - Recovery time

---

## Version History

- **v1.0 (2025-09-30):** Initial master document defining all time scales and conversions
