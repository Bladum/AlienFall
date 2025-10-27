# Campaign Integration API Reference

Comprehensive documentation for AlienFall's campaign system integration with all game layers. Covers mission generation, threat escalation, outcome recording, and campaign state progression.

## Table of Contents

1. [Overview](#overview)
2. [Core Systems](#core-systems)
3. [Mission System](#mission-system)
4. [Threat Management](#threat-management)
5. [Campaign Progression](#campaign-progression)
6. [Integration Points](#integration-points)
7. [Complete API Reference](#complete-api-reference)
8. [Code Examples](#code-examples)
9. [Configuration](#configuration)

## Overview

The Campaign System is the strategic layer orchestrating all game events. It manages:
- Campaign phases (Shadow War → Sky War → Deep War → Dimensional War)
- Threat escalation based on player performance
- UFO generation and mission assignment
- Faction activity and alien strategy
- Player progression and unlocks

---

## Implementation Status

### ✅ Implemented (in engine/campaign/)
- Campaign manager with phase tracking
- Threat level calculations
- Mission generation system
- Phase progression mechanics

### 🚧 Partially Implemented
- Advanced faction AI
- Dynamic event generation
- Endgame scenarios

### 📋 Planned
- Multiple campaign paths
- Campaign modding support
- Sandbox mode

---

### Architecture

```
┌─────────────────────────────────────────────────────┐
│        GEOSCAPE / CAMPAIGN STRATEGIC LAYER          │
│                                                     │
│  ┌──────────────────────────────────────────────┐  │
│  │       CampaignManager (Phase Management)     │  │
│  │  - Phase progression (0-3)                   │  │
│  │  - Threat level tracking (0.0-1.0)           │  │
│  │  - Time/date advancement                     │  │
│  └─────────────────┬──────────────────────────┘  │
│                    │                              │
│  ┌─────────────────▼──────────────────────────┐  │
│  │     ThreatManager (Difficulty Scaling)     │  │
│  │  - Win rate tracking (0.0-1.0)              │  │
│  │  - Mission frequency adjustment             │  │
│  │  - UFO intensity multiplier                 │  │
│  └─────────────────┬──────────────────────────┘  │
│                    │                              │
│  ┌─────────────────▼──────────────────────────┐  │
│  │  AlienDirector (Strategic AI)               │  │
│  │  - Mission generation                       │  │
│  │  - Faction coordination                     │  │
│  │  - Resource allocation                      │  │
│  └──────────────────────────────────────────┘  │
│                                                     │
└─────────────────────────────────────────────────────┘
                     │
        ┌────────────┴────────────┐
        │                         │
        ▼                         ▼
   ┌──────────┐          ┌─────────────────┐
   │ BASESCAPE│          │    GEOSCAPE     │
   │(Operations)         │ (World Map)     │
   └──────────┘          └─────────────────┘
        │                         │
        └────────────┬────────────┘
                     │
                     ▼
            ┌──────────────────┐
            │   BATTLESCAPE    │
            │ (Tactical Combat)│
            └──────────────────┘
```

### Campaign Phases

| Phase | Name | Duration | Threat Cap | Features |
|-------|------|----------|-----------|----------|
| 0 | Shadow War | Variable | 0.4 | Conspiracy, Government denial, Limited alien activity |
| 1 | Sky War | 86400+ | 0.7 | Invasion confirmed, UFO waves, Public panic |
| 2 | Deep War | 172800+ | 0.9 | Underground threat, Aquatic species, Multi-front war |
| 3 | Dimensional War | 259200+ | 1.0 | Reality-warping, Dimensional rifts, Existential threat |

## Core Systems

### 1. Campaign Manager

**File**: `engine/lore/campaign/campaign_manager.lua` and `engine/geoscape/campaign_manager.lua`

**Purpose**: Manages campaign phases, threat levels, and time progression.

#### Exports

```lua
CampaignManager.init()                           -- Initialize campaign (called at game start)
CampaignManager.update(delta_time)               -- Update campaign state each frame
CampaignManager.getCurrentPhase()                -- Returns current phase (0-3)
CampaignManager.getThreatLevel()                 -- Returns threat level (0.0-1.0)
CampaignManager.getPhaseName()                   -- Returns phase name string
CampaignManager.recordMissionOutcome(success)    -- Record mission result
CampaignManager.advanceDay()                     -- Move to next day
CampaignManager.save()                           -- Serialize campaign state
CampaignManager.load(data)                       -- Deserialize campaign state
```

#### State Fields

```lua
CampaignManager.currentPhase = 0         -- 0=Shadow War, 1=Sky War, 2=Deep War, 3=Dimensional War
CampaignManager.phaseTime = 0            -- Seconds spent in current phase
CampaignManager.threatLevel = 0.0        -- Threat 0.0-1.0 (affects mission frequency/difficulty)
CampaignManager.missionCount = 0         -- Total missions completed
CampaignManager.winRate = 0.5            -- Mission success rate (affects threat escalation)
CampaignManager.currentDay = 1           -- Game day counter
```

#### Phase Thresholds

```lua
CampaignManager.PHASE_THRESHOLDS = {
    [0] = { name = "Shadow War", minTime = 0, threatCap = 0.4, nextTrigger = "discoveries" },
    [1] = { name = "Sky War", minTime = 86400, threatCap = 0.7, nextTrigger = "deepop" },
    [2] = { name = "Deep War", minTime = 172800, threatCap = 0.9, nextTrigger = "dimensional" },
    [3] = { name = "Dimensional War", minTime = 259200, threatCap = 1.0, nextTrigger = "none" }
}
```

### 2. Threat Manager

**File**: `engine/ai/strategic/threat_manager.lua`

**Purpose**: Scales game difficulty based on player performance and threat level.

#### Exports

```lua
ThreatManager.init(phase)                    -- Initialize for campaign phase
ThreatManager.update(delta_time)             -- Update threat over time
ThreatManager.getThreatLevel()               -- Get current threat (0.0-1.0)
ThreatManager.recordMissionOutcome(success)  -- Record mission success/failure
ThreatManager.getMissionFrequency()          -- Get missions/day based on threat
ThreatManager.getUFOIntensity()              -- Get UFO multiplier (0.5-3.0x)
ThreatManager.getTerrorMissionChance()       -- Get terror mission probability
ThreatManager.save()                         -- Serialize threat state
ThreatManager.load(data)                     -- Deserialize threat state
```

#### Threat Scaling

- **0.0-0.2**: Minimal threat (1-2 missions/week, 0.5x UFO intensity)
- **0.2-0.4**: Low threat (2-3 missions/week, 0.8x UFO intensity)
- **0.4-0.6**: Medium threat (3-5 missions/week, 1.0x UFO intensity)
- **0.6-0.8**: High threat (5-8 missions/week, 1.5x UFO intensity)
- **0.8-1.0**: Extreme threat (8-15 missions/week, 2.0x UFO intensity)

#### Win Rate Effects

- **Win Rate > 0.65**: Threat increases 20% faster (aliens adapting)
- **Win Rate 0.35-0.65**: Normal threat progression
- **Win Rate < 0.35**: Threat increases 30% slower (aliens overconfident)

### 3. Alien Director

**File**: `engine/ai/strategic/alien_director.lua`

**Purpose**: Generates missions and coordinates faction activities.

#### Exports

```lua
AlienDirector.init()                     -- Initialize alien AI
AlienDirector.update(delta_time)         -- Update alien strategy
AlienDirector.generateMission()          -- Create next mission for player
AlienDirector.getActiveFactions()        -- Get active factions at threat
AlienDirector.save()                     -- Serialize AI state
AlienDirector.load(data)                 -- Deserialize AI state
```

#### Mission Generation

```lua
local mission = AlienDirector.generateMission()
-- Returns: {
--   id = "mission_123",
--   type = "scout|raid|invasion|terror",
--   faction = "faction_id",
--   threatLevel = 0.5,          -- 0.0-1.0 difficulty
--   ufos = [{type, count}, ...],
--   difficulty = 1-5,           -- 1=easy, 5=extreme
--   rewards = { funds, xp }
-- }
```

## Mission System

### Mission Flow

```
1. MISSION GENERATED
   └─ AlienDirector creates mission based on threat, factions
   └─ Mission queued in CampaignManager

2. MISSION AVAILABLE TO PLAYER
   └─ Shown in Geoscape mission list
   └─ Player can Accept/Decline

3. MISSION BRIEFING
   └─ Player reviews objectives, enemies, rewards
   └─ Difficulty indicator shown (⭐⭐⭐)
   └─ Accept → Deployment, Decline → return to Geoscape

4. DEPLOYMENT
   └─ Player selects landing zone and squad
   └─ Equipment verification

5. BATTLESCAPE
   └─ Tactical combat (turn-based)
   └─ Win/Loss/Withdrawal outcomes

6. MISSION OUTCOME RECORDING
   └─ Battlescape.exit() calls:
      ├─ CampaignManager.recordMissionOutcome(victory)
      ├─ ThreatManager.recordMissionOutcome(victory)
      └─ CampaignManager.advanceDay()
   └─ Campaign threat updated
   └─ Player returns to Geoscape
```

### Mission Data Structure

```lua
mission = {
    -- Identification
    id = "mission_123",                          -- Unique mission ID
    name = "UFO Crash Recovery",                 -- Display name
    type = "scout|raid|invasion|terror|research",

    -- Campaign Integration
    faction = "faction_id",                      -- Which faction assigned
    threatLevel = 0.5,                           -- 0.0-1.0 difficulty
    difficulty = 3,                              -- 1-5 stars

    -- Mission Details
    location = "Province Name",                  -- Where mission occurs
    timeOfDay = "Day|Night",                     -- Lighting conditions
    objectives = [
        { description = "Survive 10 turns", type = "defend" },
        { description = "Eliminate squad leader", type = "destroy" }
    ],

    -- Enemy Information
    enemies = [
        { name = "Sectoid", count = 3 },
        { name = "Muton", count = 2 }
    ],
    ufos = [
        { type = "scout_ufo", count = 1 },
        { type = "fighter_escort", count = 2 }
    ],

    -- Rewards
    rewards = {
        funds = 1500,                            -- Credits to base
        xp = 200,                                -- Per soldier
        items = ["laser_rifle", "plasma_ammo"]
    }
}
```

## Threat Management

### Threat Escalation System

The threat level determines mission frequency, difficulty, and UFO composition.

#### Automatic Escalation

- **Base escalation**: +1% threat per week
- **Victory multiplier**: +20% escalation (aliens adapt)
- **Defeat slowdown**: -30% escalation (aliens overconfident)
- **Phase caps**: Threat cannot exceed phase threshold

```lua
-- Example: Week 1-4 of Shadow War (threat 0.1-0.4)
local threat = 0.1
-- After 10 easy victories: threat increases to 0.15 (adapting)
-- After 10 defeats: threat drops to 0.08 (overconfident)
```

#### Mission Frequency Calculation

```lua
local frequency = ThreatManager.getMissionFrequency()
-- Returns: 0.1 + (threatLevel * 0.9)
-- At threat 0.0: 0.1 missions/day (1 per 10 days)
-- At threat 0.5: 0.55 missions/day (1 per 1.8 days)
-- At threat 1.0: 1.0 missions/day (1 per day)
```

#### UFO Intensity Calculation

```lua
local intensity = ThreatManager.getUFOIntensity()
-- Returns: 0.5 + (threatLevel * 1.5)
-- At threat 0.0: 0.5x (rare UFOs, small squads)
-- At threat 0.5: 1.25x (normal UFO activity)
-- At threat 1.0: 2.0x (constant UFO waves, large formations)
```

### Terror Mission Chance

```lua
local terrrorChance = ThreatManager.getTerrorMissionChance()
-- Returns: 0 at threat < 0.3
-- Returns: (threatLevel - 0.3) / 0.7 at threat >= 0.3
-- At threat 0.3: 0% (no terror)
-- At threat 0.65: 50% chance
-- At threat 1.0: 100% (terror guaranteed)
```

## Campaign Progression

### Phase Transitions

Automatic phase transitions occur when:
1. Minimum time has passed in current phase
2. Threat level reaches phase threshold
3. Trigger conditions met (story events)

```lua
-- Shadow War (Phase 0) → Sky War (Phase 1)
if phaseTime >= 86400 and threatLevel >= 0.4 then
    CampaignManager:_transitionPhase()  -- Called automatically
end

-- Sky War (Phase 1) → Deep War (Phase 2)
if phaseTime >= 172800 and threatLevel >= 0.7 then
    CampaignManager:_transitionPhase()
end
```

### Time System

Campaign tracks game time:
- 1 day = 86400 game seconds
- Each battlescape turn = ~60 seconds
- Each mission = 60-600 seconds (depending on mission length)
- Campaign updates daily

```lua
-- Day advancement
CampaignManager:advanceDay()
-- Also recalculates: week, month, year counters
-- Updates active missions
-- Triggers periodic events
```

## Integration Points

### 1. Battlescape → Campaign

**File**: `engine/gui/scenes/battlescape_screen.lua`

The Battlescape exit function records mission outcomes:

```lua
function Battlescape:exit()
    if self.missionData then
        local CampaignManager = require("lore.campaign.campaign_manager")
        local ThreatManager = require("ai.strategic.threat_manager")

        -- Determine victory
        local victory = (playerTeam and playerTeam:getUnitCount() > 0)

        -- Record outcome in both systems
        CampaignManager:recordMissionOutcome(victory)
        ThreatManager.recordMissionOutcome(victory)

        -- Advance campaign
        CampaignManager:advanceDay()
    end
end
```

### 2. Geoscape → Battlescape

**File**: `engine/gui/scenes/geoscape_screen.lua` (example)

```lua
-- When player selects mission in Geoscape:
function GeoScape:startMission(mission)
    -- Transition to Deployment Screen with mission data
    StateManager.switch("deployment", { mission = mission })
end

-- After deployment confirmed:
function DeploymentScreen:confirmDeployment()
    -- Transition to Battlescape with mission and squad data
    StateManager.switch("battlescape", {
        mission = self.missionData,
        squad = self.selectedSquad
    })
end
```

### 3. Basescape Resource Integration

**File**: `engine/basescape/basescape_screen.lua`

Basescape displays and manages:
- Craft availability for interceptions
- Personnel readiness for missions
- Research progress (affects available tech)
- Base facilities affecting mission capacity

```lua
-- Basescape tracks:
-- - Personnel: Pilots, soldiers, scientists, engineers
-- - Crafts: Available for interception
-- - Facilities: Radar (detection), Hangar (storage), Lab (research)
-- - Research: Progress toward tech unlocks
```

## Complete API Reference

### CampaignManager API

```lua
--- Initialize campaign system
function CampaignManager.init()

--- Update campaign state (called each frame)
function CampaignManager.update(delta_time: number)

--- Get current campaign phase (0-3)
function CampaignManager.getCurrentPhase(): number

--- Get current threat level (0.0-1.0)
function CampaignManager.getThreatLevel(): number

--- Get phase name
function CampaignManager.getPhaseName(): string

--- Record mission completion
function CampaignManager.recordMissionOutcome(success: boolean, kills: number, damage: number)

--- Advance campaign by one day
function CampaignManager.advanceDay()

--- Save campaign state
function CampaignManager.save(): table

--- Load campaign state
function CampaignManager.load(data: table)

--- Internal: Update threat based on performance
function CampaignManager:_updateThreatLevel()

--- Internal: Apply dynamic escalation
function CampaignManager:_updateThreatEscalation(delta_time: number)

--- Internal: Check for phase transitions
function CampaignManager:_checkPhaseTransition()

--- Internal: Execute phase transition
function CampaignManager:_transitionPhase()

--- Internal: Trigger phase transition events
function CampaignManager:_triggerPhaseTransitionEvents(oldPhase: number, newPhase: number)
```

### ThreatManager API

```lua
--- Initialize threat manager for phase
function ThreatManager.init(phase: number)

--- Update threat each frame
function ThreatManager.update(delta_time: number)

--- Get current threat level (0.0-1.0)
function ThreatManager.getThreatLevel(): number

--- Record mission outcome
function ThreatManager.recordMissionOutcome(success: boolean)

--- Get missions per day
function ThreatManager.getMissionFrequency(): number

--- Get UFO wave intensity multiplier
function ThreatManager.getUFOIntensity(): number

--- Get terror mission probability
function ThreatManager.getTerrorMissionChance(): number

--- Save threat state
function ThreatManager.save(): table

--- Load threat state
function ThreatManager.load(data: table)

--- Get debug information
function ThreatManager.getDebugInfo(): table
```

### AlienDirector API

```lua
--- Initialize alien director
function AlienDirector.init()

--- Update alien strategy each frame
function AlienDirector.update(delta_time: number)

--- Generate next mission for player
function AlienDirector.generateMission(): table

--- Get threat level
function AlienDirector.getThreatLevel(): number

--- Save AI state
function AlienDirector.save(): table

--- Load AI state
function AlienDirector.load(data: table)
```

## Code Examples

### Example 1: Starting the Campaign

```lua
-- At game start
local CampaignManager = require("lore.campaign.campaign_manager")
local ThreatManager = require("ai.strategic.threat_manager")
local AlienDirector = require("ai.strategic.alien_director")

-- Initialize systems
CampaignManager.init()
ThreatManager.init(0)  -- Start in phase 0
AlienDirector.init()

-- Campaign is now running
print("Campaign started in phase: " .. CampaignManager.getPhaseName())
```

### Example 2: Processing Mission Outcome

```lua
-- After mission in battlescape
local CampaignManager = require("lore.campaign.campaign_manager")
local ThreatManager = require("ai.strategic.threat_manager")

-- Determine if mission was won
local won = (playerSquadAlive and killedAllEnemies)

-- Record in both systems
CampaignManager:recordMissionOutcome(won)
ThreatManager.recordMissionOutcome(won)

-- Advance campaign
CampaignManager:advanceDay()

print(string.format("Mission %s | Threat: %.1f%% | Win rate: %.1f%%",
    won and "WON" or "LOST",
    ThreatManager.getThreatLevel() * 100,
    ThreatManager.winRate * 100))
```

### Example 3: Generating Missions

```lua
local AlienDirector = require("ai.strategic.alien_director")

-- Generate mission based on current threat
local mission = AlienDirector.generateMission()

-- Mission contains all needed info for briefing
local briefingData = {
    mission = mission,
    threat = mission.threatLevel,
    difficulty = mission.difficulty,
    enemies = mission.enemies,
    ufos = mission.ufos,
    rewards = mission.rewards
}

-- Show to player
StateManager.switch("mission_briefing", briefingData)
```

### Example 4: Checking Campaign Progress

```lua
local CampaignManager = require("lore.campaign.campaign_manager")
local ThreatManager = require("ai.strategic.threat_manager")

-- Display campaign status
local phase = CampaignManager.getCurrentPhase()
local threat = ThreatManager.getThreatLevel()
local frequency = ThreatManager.getMissionFrequency()

print(string.format(
    "Phase: %s | Threat: %.0f%% | Missions/day: %.2f",
    CampaignManager.getPhaseName(),
    threat * 100,
    frequency
))

-- Check phase transition
if phase < 3 and threat >= CampaignManager.PHASE_THRESHOLDS[phase].threatCap then
    print("Phase transition imminent!")
end
```

## Configuration

### Campaign Configuration

**File**: `mods/core/campaign/phases.toml`

```toml
[[phase]]
id = 0
name = "Shadow War"
min_time = 0
threat_cap = 0.4
next_trigger = "discoveries"
mission_frequency_low = 1
mission_frequency_high = 3

[[phase]]
id = 1
name = "Sky War"
min_time = 86400
threat_cap = 0.7
next_trigger = "deepop"
mission_frequency_low = 3
mission_frequency_high = 7
```

### Threat Configuration

**File**: `mods/core/ai/alien_director_config.toml`

```toml
[threat]
base_threat_phase_0 = 10
base_threat_phase_1 = 40
base_threat_phase_2 = 60
base_threat_phase_3 = 85

threat_per_week = 2
win_rate_threshold_easy = 0.75
win_rate_threshold_hard = 0.40
threat_adjustment_easy = -0.05
threat_adjustment_hard = 0.10
```

## See Also

- `api/GEOSCAPE.md` - Geoscape system documentation
- `api/BATTLESCAPE.md` - Battlescape system documentation
- `api/BASESCAPE.md` - Basescape system documentation
- `architecture/ROADMAP.md` - Campaign roadmap and milestones

---

**Version**: 2.0
**Last Updated**: 2025
**Author**: AlienFall Development Team
