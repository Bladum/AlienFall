# Alien Director - Strategic AI System

**Status:** Implementation Complete
**Last Updated:** October 23, 2025
**Version:** 1.0

---

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Threat Management](#threat-management)
4. [Faction Coordination](#faction-coordination)
5. [Mission Generation](#mission-generation)
6. [Adaptive Difficulty](#adaptive-difficulty)
7. [Configuration](#configuration)
8. [Integration](#integration)
9. [Modding Guide](#modding-guide)

---

## Overview

The Alien Director is AlienFall's strategic AI "Dungeon Master" - an orchestrating system that manages all alien activity, campaign pressure, and difficulty scaling. Rather than predetermined mission sequences, the Alien Director dynamically generates campaigns that respond to player actions, skill level, and campaign progress.

### Key Responsibilities

1. **Threat Management** - Track campaign pressure and escalation
2. **Faction Coordination** - Manage multi-faction alien activities
3. **Mission Generation** - Create missions matching current situation
4. **Difficulty Adaptation** - Scale challenge to player skill level
5. **Campaign Pacing** - Ensure dramatic narrative flow
6. **Strategic Coordination** - UFO waves, base construction, terror attacks

### Why Alien Director?

- **Replayability** - Each campaign feels different due to adaptive AI
- **Fairness** - AI responds to player skill, not arbitrary difficulty settings
- **Immersion** - Aliens behave strategically, not randomly
- **Balance** - Game gets harder/easier based on performance
- **Engagement** - Player feels they're battling intelligent opponent

---

## Architecture

### System Components

```
┌─────────────────────────────────────────────────────┐
│         ALIEN DIRECTOR (Main Orchestrator)          │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ┌──────────────────┐     ┌────────────────────┐   │
│  │ Threat Manager   │     │ Faction Coordinator│   │
│  │ - Threat Level   │     │ - UFO Waves       │   │
│  │ - Escalation     │     │ - Terror Attacks  │   │
│  │ - Pressure Curve │     │ - Base Building   │   │
│  └──────────────────┘     │ - Infiltration    │   │
│                           └────────────────────┘   │
│                                                     │
│  ┌─────────────────────────────────────────────┐   │
│  │   Mission Generator                         │   │
│  │   - Creates missions based on threat/phase  │   │
│  │   - Queues missions for player             │   │
│  └─────────────────────────────────────────────┘   │
│                                                     │
│  ┌─────────────────────────────────────────────┐   │
│  │   Adaptive Difficulty Engine                │   │
│  │   - Tracks player win rate                 │   │
│  │   - Adjusts threat accordingly             │   │
│  └─────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────┘
```

### Data Flow

```
Player Actions (Mission Result)
         ↓
    Threat Manager (recalculates threat)
         ↓
    Faction Coordinator (plans activities)
         ↓
    Mission Generator (creates next mission)
         ↓
    Mission Queue (delivered to player)
```

---

## Threat Management

### Threat Level Scale

Threat is measured 0-100, representing overall campaign pressure:

- **0-20:** Minimal pressure (1-2 missions/week)
- **20-40:** Low pressure (3-5 missions/week)
- **40-60:** Moderate pressure (6-10 missions/week)
- **60-80:** High pressure (11-20 missions/week)
- **80-100:** Critical pressure (20+ missions/week, continuous assault)

### Base Threat by Phase

| Phase | Name | Base Threat | Threat Cap |
|-------|------|-------------|-----------|
| 0 | Shadow War | 10 | 40 |
| 1 | Sky War | 40 | 70 |
| 2 | Deep War | 60 | 90 |
| 3 | Dimensional War | 85 | 100 |

### Threat Modifiers

Threat increases and decreases based on gameplay:

**Increases Threat:**
- Alien mission success (+5-20)
- UFO wave detected (+3-10 per UFO)
- Alien base constructed (+20, permanent until destroyed)
- Player loses major mission (+15-30)
- Research detected (dimensional theory, +30)
- Terror attack succeeds (+20)

**Decreases Threat:**
- Player mission success (-5-15)
- Alien base destroyed (-15)
- Player captures high-rank alien (-10)
- Research psionic defense (-10)
- Terror attack prevented (-15)

### Natural Escalation

Even without player actions, threat naturally increases:
- **Per week:** +2 threat
- **Per month:** +15 threat
- **Per phase transition:** Significant jump (e.g., Phase 0→1: +30)

### Time-Based Threat

Threat ramps over campaign duration regardless of player performance. This ensures campaign builds toward endgame confrontation:

```
Phase 0:  Threat 10 + (weeks × 2) = escalates to 40
Phase 1:  Threat 40 + (weeks × 2) = escalates to 70
Phase 2:  Threat 60 + (weeks × 2) = escalates to 90
Phase 3:  Threat 85 + (weeks × 2) = escalates to 100 (Nexus)
```

---

## Faction Coordination

### Active Factions by Phase

**Phase 0 - Shadow War:**
- Human factions (GHOST, BlackOps, etc.)
- Supernatural entities (cults, zombies)

**Phase 1 - Sky War:**
- Terrestrial Aliens (Sectoids, Mutons, Ethereals)
- Reticulan Cabal (early cells)

**Phase 2 - Deep War:**
- Terrestrial Aliens (continued)
- Reticulan Cabal (expanded network)
- Aquatic Species (Gill-Men, Tasoth, etc.)

**Phase 3 - Dimensional War:**
- Dimensional Beings (TDVs, Cult of Sirius)
- Regional Human Superpowers
- All previous factions

### Faction Activity Levels

Each faction has activity percentage, determining mission frequency:

```
Threat 20:  Activity 5% = 0.5 missions/week from faction
Threat 50:  Activity 15% = 2.5 missions/week from faction
Threat 80:  Activity 40% = 8 missions/week from faction
```

### Faction Specialization

Different factions use different mission types:

- **Terrestrial Aliens** → Terror, Base Assault, UFO Interception
- **Reticulan Cabal** → Infiltration, Sabotage, Politics
- **Aquatic Species** → Deep-Sea Infiltration, Coastal Terror, Sonar Jamming
- **Dimensional Beings** → Breach Containment, Artifact Recovery, Reality Distortion

---

## Mission Generation

### Mission Generation Process

```
1. Determine current threat level
2. Select appropriate mission type based on:
   - Campaign phase
   - Active factions
   - Threat level
   - Time since last similar mission
3. Roll for difficulty modifiers
4. Generate mission parameters (location, aliens, objectives)
5. Queue mission for player
```

### Mission Frequency

Mission generation rate scales with threat:

| Threat | Missions/Week | Average Days Between |
|--------|--------------|---------------------|
| 10 | 1 | 7 days |
| 30 | 2 | 3-4 days |
| 50 | 4 | 1-2 days |
| 70 | 7 | ~1 day |
| 90 | 12+ | Multiple per day |

### Mission Type Distribution

**Phase 0:**
- Investigation (50%)
- Supernatural (30%)
- Recovery (20%)

**Phase 1:**
- Terror Missions (30%)
- UFO Crash Recovery (30%)
- Alien Base Assault (20%)
- Interception (20%)

**Phase 2:**
- Terror Missions (25%)
- UFO Crash Recovery (20%)
- Alien Base Assault (25%)
- Deep-Sea Infiltration (20%)
- Interception (10%)

**Phase 3:**
- Dimensional Breach (30%)
- Nexus Assault (20%)
- Alien Base Assault (20%)
- Terror Missions (15%)
- Interception (15%)

---

## Adaptive Difficulty

### Player Skill Detection

The system tracks player win rate to assess skill level:

```
Win Rate | Assessment | Difficulty Level
---------|-----------|------------------
> 85%    | Too Easy  | Increase threat
70-85%   | Easy      | Slight increase
50-70%   | Balanced  | Maintain threat
30-50%   | Challenging | Fine-tuning
< 30%    | Too Hard  | Decrease threat
```

### Automatic Adjustment

When win rate moves outside acceptable range, threat adjusts:

| Threshold | Win Rate | Action | Threat Change |
|-----------|----------|--------|---------------|
| Very Easy | > 85% | Increase difficulty | +15 |
| Easy | 70-85% | Slight increase | +5 |
| Hard | 30-50% | Slight decrease | -5 |
| Very Hard | < 30% | Decrease difficulty | -15 |

### Learning Rate

AI learns gradually (5% adjustment per assessment) to avoid dramatic swing

s. Assessment happens every 20 missions to smooth out randomness.

### Strategic Pauses

When threat becomes too high (>95%), the system grants 2-week respite:
- Fewer missions generated
- Smaller UFO waves
- Reduced alien base construction
- Allows player to recuperate

---

## Configuration

### Key Configuration Parameters

**Threat Configuration** (`threat` section):
- `base_threat_phase_N` - Starting threat per phase
- `threat_per_week` - Natural escalation rate
- `win_rate_threshold_easy/hard` - Adjustment thresholds
- `threat_adjustment_easy/hard` - Adjustment magnitudes

**Faction Configuration** (`factions` section):
- Per-faction activity levels
- Phase introduction timing
- Priority weighting

**Mission Configuration** (`missions` section):
- `mission_frequency_*` - Missions per week at different threat levels
- Mission type distribution per phase

**Difficulty Configuration** (`difficulty_adaptation` section):
- `difficulty_learning_rate` - How aggressively AI adapts
- `player_win_rate_moving_average` - Smoothing window
- Threshold and adjustment values

**UFO Configuration** (`ufo_waves` section):
- Base wave size and escalation
- Wave frequency per threat level
- Inter-wave timing

**Terror Configuration** (`terror_attacks` section):
- Terror frequency per phase
- Casualty ranges
- Panic impact

### Tuning the Difficulty

Difficulty is controlled primarily through threat-to-activity mapping:

```lua
-- To make game easier overall:
threat_per_week = 1         -- Slower natural escalation (was 2)
win_rate_threshold_hard = 0.30  -- Reduce earlier (was 0.40)
threat_adjustment_hard = 0.05   -- Less increase (was 0.10)

-- To make game harder overall:
threat_per_week = 3         -- Faster escalation (was 2)
win_rate_threshold_easy = 0.80  -- Reduce later (was 0.75)
threat_adjustment_easy = -0.02  -- Less reduction (was -0.05)
```

---

## Integration

### How Alien Director Connects to Game Systems

#### Campaign Manager
Receives: Current phase, time passed
Sends: Phase transition triggers

#### Research Manager
Receives: Research completion notifications
Sends: Threat adjustments based on research

#### Mission System
Receives: Mission outcome (success/failure)
Sends: Generated mission queue

#### Geoscape
Receives: UFO locations, craft status
Sends: UFO wave data, interception suggestions

#### Economy/Funding
Receives: Terror attack locations
Sends: Panic/funding adjustments

### Event Callbacks

Alien Director registers for these events:

```lua
-- Research completion
game:on("research_complete", function(tech_id)
    alienDirector:threatManager:onResearchComplete(tech_id)
end)

-- Mission outcome
game:on("mission_complete", function(mission, success)
    alienDirector:threatManager:onMissionComplete(mission, success)
end)

-- Alien actions
game:on("alien_base_constructed", function(base)
    alienDirector:threatManager:onAlienBaseConstructed(base.type)
end)

game:on("ufo_wave_detected", function(wave)
    alienDirector:threatManager:onUFOWaveDetected(#wave)
end)
```

---

## Modding Guide

### Adjusting Threat Escalation

In `mods/core/ai/alien_director_config.toml`:

```toml
[threat]
threat_per_week = 2         # Change this value

# Make game easier over time:
threat_per_week = 1         # Slow escalation

# Make game harder:
threat_per_week = 3         # Fast escalation
```

### Adding New Faction

```toml
[[faction]]
id = "new_faction_id"
name = "New Faction Name"
phase_introduced = 2        # Appears in Phase 2
priority = 75               # Mission priority
activity_level_base = 0.3   # Base activity
```

### Adjusting Mission Frequency

```toml
[missions]
mission_frequency_low = 1       # missions/week at threat 0.3
mission_frequency_medium = 3    # missions/week at threat 0.6
mission_frequency_high = 7      # missions/week at threat 0.9
```

### Adding Research-Based Threat

```toml
[research_detection]
research_threat_increase = { your_new_research = 20 }
```

### Custom Threat Events

```lua
-- In game code
local AlienDirector = require("ai.strategic.alien_director")

-- Trigger custom threat event
AlienDirector.threatManager:addModifier("custom_event", 15, 30)
```

---

## Examples

### Example 1: Easy Mode Configuration

```toml
[difficulty_adaptation]
win_rate_threshold_very_easy = 0.80  # Increase at 80% (not 85%)
threat_adjustment_easy = -0.10       # Bigger reduction
threat_adjustment_hard = 0.05        # Smaller increase
difficulty_learning_rate = 0.03      # Slower learning
```

### Example 2: Campaign Pacing

```
Week 1-4:   Threat 10-20 (1-2 missions/week)   [Reconnaissance]
Week 5-8:   Threat 20-35 (2-4 missions/week)   [Escalation]
Week 9-16:  Threat 40-60 (5-10 missions/week)  [War]
Week 17+:   Threat 70-100+ (10+ missions/week) [Crisis]
```

### Example 3: Phase Transition Events

```toml
[[milestone]]
phase = 1
trigger = "first_contact"
threat_jump = 30
description = "First alien engagement - panic spreads"

[[milestone]]
phase = 2
trigger = "aquatic_discovery"
threat_jump = 20
description = "Second front opens - resource strain"
```

---

## Performance Considerations

- Threat calculations: O(1) - single number update
- Mission generation: O(n) where n = active factions (~4)
- Faction coordination: O(n) where n = factions
- Overall impact: ~1-2ms per 10 turns (negligible)

---

## Debugging

### Check Threat Level
```lua
print("Current threat: " .. alienDirector:getThreatLevel())
```

### Check Active Missions
```lua
print("Pending missions: " .. #alienDirector.missionQueue)
for _, mission in ipairs(alienDirector.missionQueue) do
    print("  - " .. mission.name)
end
```

### Check Faction Activities
```lua
local factions = alienDirector:getActiveFactions()
for _, faction in ipairs(factions) do
    print(faction.name .. ": activity " .. faction.activity_level)
end
```

---

## Conclusion

The Alien Director transforms AlienFall from a linear strategy game into a dynamic campaign generator. By orchestrating all alien activity through threat management and adaptive difficulty, the system ensures each playthrough feels unique while maintaining challenge appropriate to player skill. The result is a campaign that feels like playing against an intelligent adversary, not against predetermined content.
