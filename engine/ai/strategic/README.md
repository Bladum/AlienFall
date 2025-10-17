# Strategic AI System

This directory contains the Alien Director - a strategic AI system that orchestrates alien activity across the campaign.

## Components

### alien_director.lua
Main orchestrator that coordinates all strategic AI activities. Acts as the "AI Dungeon Master" creating dynamic, replayable campaigns.

**Key Responsibilities:**
- Initialize all subsystems (threat manager, faction coordinator)
- Generate missions based on current threat and active factions
- Track mission outcomes and adjust difficulty
- Provide debug information for balancing

### threat_manager.lua
Calculates campaign threat level based on player performance and time progression. Controls mission frequency, UFO intensity, and terror attack likelihood.

**Threat Level Scale:**
- 0.0-0.2: Low activity (1-2 missions/week)
- 0.2-0.4: Moderate activity (3-5 missions/week)
- 0.4-0.6: High activity (6-10 missions/week)
- 0.6-0.8: Very High activity (11-20 missions/week)
- 0.8-1.0: Extreme activity (20+ missions/week)

**Dynamic Difficulty:**
- Player winning → threat increases (harder missions)
- Player losing → threat decreases (easier missions)
- Scales smoothly based on win rate

### faction_coordinator.lua
Manages multiple alien factions and coordinates their activities. Controls which factions are active, how resources are allocated, and what operations they plan.

**Key Features:**
- Multi-faction activation based on threat
- Resource allocation (UFOs, bases, troops)
- Operation planning (patrol, terror, infiltration, assault)
- UFO composition generation
- Faction-specific mission types

## Usage Example

```lua
local AlienDirector = require("ai.strategic.alien_director")

-- Initialize at game start
AlienDirector.init()

-- Each frame during gameplay
AlienDirector.update(delta_time)

-- Generate next mission
local mission = AlienDirector.generateMission()

-- After mission completes
AlienDirector.recordMissionOutcome(mission.id, player_won)

-- Check current threat level
local threat = AlienDirector.getThreatLevel()  -- 0.0-1.0
local factions = AlienDirector.getActiveFactions()  -- Active faction IDs
```

## Integration

### With Campaign System
- Reads current phase from CampaignManager
- Provides threat level to CampaignManager
- Coordinates with phase-specific content

### With Lore System
- Uses faction data from LoreManager
- Determines which factions are available per phase
- Selects missions matching faction characteristics

### With Geoscape
- Generates missions for geoscape to display
- Provides UFO composition for interception layer
- Controls mission frequency

## Mission Generation

Missions are generated based on:
1. **Current Threat Level** - Controls difficulty and resource investment
2. **Active Factions** - Determines enemy types and tactics
3. **Campaign Phase** - Affects available mission types
4. **Recent Performance** - Modifies difficulty curve

## Balancing

For debug info, call:
```lua
local debug = AlienDirector.getDebugInfo()
print("Threat:", debug.threatLevel)
print("Win Rate:", debug.threatInfo.winRate)
print("Active Factions:", table.concat(AlienDirector.getActiveFactions(), ", "))
```

## Save/Load

The system supports full persistence:
```lua
-- Save before exit
local saveData = AlienDirector.save()
game.saveData.alienDirector = saveData

-- Load on game start
AlienDirector.init()
AlienDirector.load(game.saveData.alienDirector)
```

## Future Enhancements

- Base infiltration planning
- Technology dependency tracking
- Long-term strategy trees
- Faction diplomacy outcomes affecting activities
- Procedural event generation
- Performance tuning for large campaigns
