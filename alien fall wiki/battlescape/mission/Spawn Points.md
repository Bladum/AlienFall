# Spawn Point System

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Position Definition and Attributes](#position-definition-and-attributes)
  - [Spacing and Distribution Requirements](#spacing-and-distribution-requirements)
  - [Faction-Based Assignment](#faction-based-assignment)
  - [Generation and Optimization](#generation-and-optimization)
  - [Dynamic Adjustment Framework](#dynamic-adjustment-framework)
  - [Spawn Point Types and Classification](#spawn-point-types-and-classification)
  - [Data Structure and Configuration](#data-structure-and-configuration)
- [Examples](#examples)
  - [Player Deployment Scenario](#player-deployment-scenario)
  - [Enemy Ambush Setup](#enemy-ambush-setup)
  - [Reinforcement Wave](#reinforcement-wave)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Spawn Point System defines initial unit positions on the battlefield, ensuring proper spacing, tactical positioning, and faction-appropriate placement. These coordinate-based locations determine starting positions for all combat participants and significantly influence the initial tactical situation. The system provides deterministic placement algorithms that balance fairness, challenge, and strategic depth across different mission types and difficulty levels.

## Mechanics

### Position Definition and Attributes
Core specification of spawn location properties:

**Location Attributes:**
- **Coordinates**: (x,y) position within the Battle Grid coordinate system
- **Facing Direction**: Initial unit orientation affecting line-of-sight and movement
- **Elevation**: Height level for multi-level terrain positioning
- **Terrain Compatibility**: Valid terrain types that support unit spawning

### Spacing and Distribution Requirements
Ensuring valid and balanced initial positioning:

**Spacing Rules:**
- **Minimum Distance**: Units must be separated by configurable tile distances
- **Terrain Validation**: Spawn points must occupy traversable terrain types
- **Cover Distribution**: Balanced access to defensive positions across factions
- **Objective Proximity**: Appropriate distance ranges from mission objectives

### Faction-Based Assignment
Different spawn behaviors for different combatant categories:

**Faction Categories:**
- **Player Units**: Controlled deployment with player choice and zone restrictions
- **Enemy Units**: AI-determined positioning for tactical advantage and ambush potential
- **Allied Units**: Support forces with coordinated placement and reinforcement roles
- **Neutral Units**: Civilians and wildlife with random distribution and avoidance behaviors

### Generation and Optimization
Algorithmic placement ensuring tactical validity:

**Algorithm Steps:**
1. **Zone Identification**: Determine valid spawn areas based on deployment zones
2. **Position Sampling**: Generate candidate spawn locations within valid areas
3. **Validation**: Check spacing, terrain, and tactical requirements
4. **Optimization**: Balance positioning factors for fair and interesting scenarios
5. **Assignment**: Allocate positions to specific units based on faction and priority

### Dynamic Adjustment Framework
Modifying spawn points based on mission parameters and difficulty:

**Adjustment Types:**
- **Difficulty Scaling**: Easier missions provide better positioning options
- **Unit Composition**: Specialized positioning for different unit classes and roles
- **Environmental Factors**: Weather and terrain effects on spawn validity
- **Mission Type**: Recon missions vs assault missions with different spawn distributions

### Spawn Point Types and Classification
Different categories of spawn locations for varied tactical scenarios:

**Deployment Zone Spawns:**
- **Area Definition**: Rectangular or irregular regions within deployment zones
- **Capacity Management**: Maximum units per zone with overflow handling
- **Priority System**: Preferred zones vs fallback options for crowded scenarios
- **Terrain Restrictions**: Position requirements based on unit type capabilities

**Individual Special Spawns:**
- **Leader Positions**: Command units placed in advantageous command locations
- **Specialist Placement**: Unique positioning for units with special abilities
- **Objective Guards**: Units positioned to control or defend key mission points
- **Ambush Points**: Hidden positions providing tactical surprise opportunities

**Reserve and Reinforcement Spawns:**
- **Delayed Activation**: Units arriving mid-mission via timed or event triggers
- **Conditional Spawning**: Triggered by mission events or player actions
- **Reinforcement Waves**: Multiple spawn opportunities for extended engagements
- **Extraction Points**: Emergency withdrawal locations for mission recovery

### Data Structure and Configuration
TOML-based configuration for spawn point properties:

```toml
[spawn_point]
id = "player_deployment_alpha"
coordinates = { x = 25, y = 15 }
facing = "north"
faction = "player"
unit_type = "squad_leader"

[spawn_point.requirements]
min_distance = 3
terrain_types = ["open_ground", "low_cover"]
cover_access = true
objective_distance = { min = 10, max = 50 }

[spawn_point.tactical]
cover_rating = 7
movement_options = 8
threat_level = 3
strategic_value = "high"

[spawn_point.metadata]
zone_id = "deployment_zone_1"
priority = 1
fallback_allowed = true
reinforcement_capable = false
```

## Examples

### Player Deployment Scenario
Standard player unit placement in a defensive mission:

**Urban Combat Setup:**
- **4 Squad Members**: Positioned across 2 deployment zones in ruined building
- **Cover Priority**: All units within 2 tiles of hard cover positions
- **Objective Access**: Direct line-of-sight to primary extraction point
- **Spacing**: Minimum 3 tiles between units for maneuverability
- **Facing**: Oriented toward expected enemy approach vectors

### Enemy Ambush Setup
AI-placed enemy units for tactical surprise:

**Forest Ambush Configuration:**
- **6 Enemy Units**: Hidden in dense woodland terrain
- **Elevation Advantage**: Positioned on higher ground with overwatch
- **Concealment**: All units in heavy cover with ambush bonuses
- **Objective Control**: Positioned to intercept player movement routes
- **Spacing**: Clustered for mutual support but spread for area denial

### Reinforcement Wave
Mid-mission unit arrival for extended engagements:

**Reinforcement Scenario:**
- **3 Additional Units**: Spawned at reserve points after initial contact
- **Delayed Activation**: Triggered by player progress toward secondary objective
- **Flanking Position**: Placed to create pincer movement opportunities
- **Equipment Match**: Reinforcements carry appropriate gear for mission phase
- **Coordination**: Spawn timing synchronized with existing enemy positions

## Related Wiki Pages
- [Unit Distribution System](Unit Distribution.md) - Process of placing units at spawn points
- [Deployment Zone System](Deployment Zones.md) - Designated spawn areas containing spawn points
- [Battle Grid System](Battle Grid.md) - Grid coordinate system containing spawn positions
- [Unit System](Unit.md) - Entities placed at spawn points during deployment

## References to Existing Games and Mechanics
- **XCOM Series**: Pre-mission unit placement with zone restrictions and facing directions
- **Fire Emblem**: Grid-based positioning with terrain and spacing considerations
- **Final Fantasy Tactics**: Strategic spawn placement affecting initial tactical advantage
- **Tactical RPG Genre**: Standard practice of initial unit positioning and deployment phases