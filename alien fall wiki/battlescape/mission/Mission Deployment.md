# Mission Deployment System

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Mission Parameter Configuration](#mission-parameter-configuration)
  - [Autopromotion Integration](#autopromotion-integration)
  - [Faction Power Assessment](#faction-power-assessment)
  - [AI Priority Integration](#ai-priority-integration)
  - [Spacing and Distribution Requirements](#spacing-and-distribution-requirements)
  - [Priority-Based Allocation Algorithm](#priority-based-allocation-algorithm)
  - [Tactical Balancing Framework](#tactical-balancing-framework)
  - [Difficulty and Balancing Controls](#difficulty-and-balancing-controls)
  - [Deterministic Generation Pipeline](#deterministic-generation-pipeline)
  - [Deployment Phase Management](#deployment-phase-management)
  - [Data Structure and Configuration](#data-structure-and-configuration)
- [Examples](#examples)
  - [Standard Terror Site Mission](#standard-terror-site-mission)
  - [Elite Strike Force Mission](#elite-strike-force-mission)
  - [Swarm Tactics Encounter](#swarm-tactics-encounter)
  - [Balanced Assault Mission](#balanced-assault-mission)
  - [Defensive Urban Scenario](#defensive-urban-scenario)
  - [Reinforcement Heavy Encounter](#reinforcement-heavy-encounter)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Mission Deployment System places units from each battle side onto the battlefield based on strategic rules and mission objectives. After generating a battlefield from the map generator and creating squads through the autopromotion system, units are positioned at appropriate spawn points to create engaging and balanced combat scenarios. The system evaluates faction strength, applies AI-driven placement priorities, and enforces spacing requirements to generate compelling tactical setups. Mission objectives influence deployment patterns, while players have no direct control over enemy placement but can select mission zones during battle planning.

This deterministic, data-driven system converts mission parameters into tactical encounter forces by spending experience budgets across units with autopromotion and equipment selection rules. Missions specify unit count ranges, experience budgets, and rank caps so designers control encounter flavor from swarm tactics to elite strikes. All generation uses seeded randomness for reproducible compositions across playtesting, balance analysis, and multiplayer synchronization.

## Mechanics

### Mission Parameter Configuration
- Unit Count Bounds: Min/max unit counts define encounter size ranges, allowing designers to express swarm versus elite encounter preferences
- Experience Budget: Total experience points allocated across generated units for promotions, classes, and equipment upgrades
- Rank Constraints: Optional maximum rank caps prevent premature access to advanced equipment, while guaranteed high-rank minimums ensure tactical challenges
- Faction Assignment: Mission faction determines available unit types, autopromotion tables, and behavioral characteristics
- Difficulty Scaling: Multipliers adjust unit counts and experience budgets based on difficulty level, creating progressive challenge curves

### Autopromotion Integration
- Unit Count Selection: Deterministic selection within min/max bounds using mission seed for reproducible encounters
- Experience Allocation: Budget distributed across units according to configurable autopromotion algorithms, balancing quantity versus quality
- Rank and Class Assignment: Experience converted to ranks, classes, and equipment selections through the squad autopromotion system
- Equipment Gating: Higher ranks receive better equipment based on research progression and tech availability, coordinated with campaign state

### Faction Power Assessment
Evaluating the strength and composition of each combatant side:

**Power Metrics:**
- **Unit Count**: Number of entities per faction affecting distribution density
- **Unit Quality**: Experience levels, equipment tiers, and capability ratings
- **Special Abilities**: Unique skills and equipment providing tactical advantages
- **Synergy Effects**: Combined unit effectiveness and team composition bonuses

### AI Priority Integration
Using Map Node AI values to guide intelligent placement decisions:

**Priority Application:**
- **Block Weighting**: Higher priority blocks attract more unit allocations
- **Faction Preferences**: Different priority mappings per combatant type
- **Tactical Clustering**: Group units in strategically valuable areas for synergy
- **Balance Enforcement**: Prevent overwhelming concentrations through distribution caps

### Spacing and Distribution Requirements
Ensuring proper unit positioning across the battlefield:

**Spacing Requirements:**
- **Minimum Distances**: Prevent overcrowding and ensure tactical maneuverability
- **Terrain Validation**: Units must spawn on appropriate traversable terrain types
- **Cover Distribution**: Balanced access to defensive positions across factions
- **Objective Access**: Maintain viable paths to mission-critical areas for all sides

### Priority-Based Allocation Algorithm
Distributing units according to the strategic value of Map Blocks:

**Algorithm Steps:**
1. **Block Ranking**: Sort Map Blocks by AI priority values for each faction
2. **Unit Assignment**: Allocate units to highest-priority blocks respecting capacity limits
3. **Capacity Limits**: Enforce maximum units per block to prevent overcrowding
4. **Fallback Placement**: Utilize lower-priority blocks when high-priority areas are full

### Tactical Balancing Framework
Ensuring fair and interesting initial positioning for engaging gameplay:

**Balance Factors:**
- **Threat Distribution**: Spread enemy units to create multiple simultaneous challenges
- **Player Advantage**: Provide defensive opportunities and positioning options
- **Objective Security**: Position units to contest mission goals from multiple angles
- **Movement Options**: Ensure units have viable tactical choices and maneuver routes

### Difficulty and Balancing Controls
- Quantity vs Quality Tradeoff: Many low-experience units create overwhelming numbers, while concentrated budgets produce elite specialists
- Equipment Progression: Rank-based equipment assignments prevent early access to advanced technology through research dependencies
- Mission Scheduling: Campaign scripts control when high-budget missions become available, maintaining intended difficulty progression
- Tech Tier Clamping: Optional soft limits reduce experience budgets if equipment would exceed current research levels

### Deterministic Generation Pipeline
- Seeded Randomness: All stochastic choices use mission/campaign seeds for reproducibility across playtesting and multiplayer
- Provenance Tracking: Complete logging of generation parameters, allocations, and outcomes for balance analysis and debugging
- Validation Checks: Ensures generated squads meet mission requirements, balance constraints, and campaign pacing rules
- Multiplayer Synchronization: Identical seeds produce identical enemy compositions for fair competitive play

### Deployment Phase Management
Multi-phase unit introduction for dynamic battlefield evolution:

**Initial Deployment Phase:**
- **Fixed Positions**: Units placed before the first turn begins
- **Strategic Setup**: Establish the initial tactical situation and force positioning
- **Balance Focus**: Create fair starting conditions for competitive gameplay
- **Narrative Setup**: Position units to support mission story and objectives

**Reinforcement Wave Phase:**
- **Timed Arrival**: Units appear at specific turns or triggered by mission events
- **Spawn Point Usage**: Designated reinforcement locations within deployment zones
- **Tactical Impact**: Change battlefield dynamics requiring player adaptation
- **Strategic Depth**: Introduce new threats and challenges mid-engagement

**Dynamic Respawning Phase:**
- **Respawn Conditions**: Limited additional units under special circumstances
- **Special Abilities**: Certain units can rejoin battle through unique mechanics
- **Mission Events**: Triggered by objective completion or narrative progression
- **Balance Safeguards**: Prevent overwhelming player positions through strict limits

### Data Structure and Configuration
TOML-based configuration for mission deployment parameters:

```toml
[mission_deployment]
mission_id = "assault_operation_beta"
total_units = 24

[mission_deployment.parameters]
unit_range = { min = 4, max = 6 }
experience_budget = 400
rank_cap = 2
difficulty_multiplier = 1.0

[mission_deployment.faction_power]
player = { units = 8, power_rating = 75, special_abilities = 3 }
enemy = { units = 12, power_rating = 85, special_abilities = 5 }
allied = { units = 4, power_rating = 60, special_abilities = 1 }

[mission_deployment.ai_priorities]
player_blocks = { "building_a" = 80, "courtyard" = 60, "street" = 40 }
enemy_blocks = { "ambush_point" = 90, "cover_position" = 70, "open_area" = 30 }

[mission_deployment.spacing_rules]
min_unit_distance = 3
min_block_separation = 2
terrain_restrictions = ["impassable", "hazardous"]
cover_distribution = "balanced"

[mission_deployment.results]
player_positions = [
  { unit_id = "soldier_1", block_id = "building_a", coordinates = { x = 25, y = 15 } }
]
enemy_positions = [
  { unit_id = "alien_1", block_id = "ambush_point", coordinates = { x = 45, y = 35 } }
]

[mission_deployment.metadata]
algorithm_used = "priority_weighted_v2"
balance_score = 85
distribution_time = 0.089
iterations_required = 3
provenance_seed = "campaign_42_mission_7"
```

## Examples

### Standard Terror Site Mission
- Unit Range: 4-6 enemies
- Experience Budget: 400 points
- Difficulty: Normal (1.0x multiplier)
- Result: 5 enemies with mixed ranks, standard equipment appropriate to campaign month
- Composition: 2 rookies, 2 squaddies, 1 sergeant with basic weapons and armor
- Tactical Flavor: Balanced encounter requiring mixed tactics against varied unit capabilities
- Deployment: Units distributed across high-priority ambush points with balanced spacing

### Elite Strike Force Mission
- Unit Range: 3-4 enemies
- Experience Budget: 800 points
- High Rank Guarantee: 2 minimum veterans
- Result: 3 high-experience enemies with advanced equipment
- Composition: 2 veterans with heavy weapons, 1 sergeant with special equipment
- Tactical Flavor: High-threat specialists demanding precise positioning and resource management
- Deployment: Concentrated in strategic blocks with superior cover and objective control

### Swarm Tactics Encounter
- Unit Range: 8-12 enemies
- Experience Budget: 300 points
- Result: Large number of low-experience units
- Composition: 10 rookies with basic weapons, overwhelming through numbers
- Tactical Flavor: Area control and suppression challenges requiring efficient elimination tactics
- Deployment: Spread across multiple blocks to create area denial and flanking threats

### Balanced Assault Mission
Standard mission with equal force distribution across urban terrain:

**City Center Assault:**
- **8 Player Units**: Distributed across 2 deployment zones in ruined buildings
- **12 Enemy Units**: Positioned in ambush points and defensive cover positions
- **Priority Weighting**: High-value blocks attract 60% of unit placements
- **Spacing**: Minimum 3 tiles between units with terrain-based restrictions
- **Balance Score**: 82/100 with fair access to objectives and cover

### Defensive Urban Scenario
Player-focused mission emphasizing defensive positioning:

**Fortified Position Defense:**
- **6 Player Units**: Concentrated in high-cover building with overlapping fields of fire
- **10 Enemy Units**: Distributed across multiple approach vectors for varied threats
- **Priority Application**: Player blocks weighted for defensive advantage
- **Spacing**: Tight clustering allowed for player units, spread for enemies
- **Balance Score**: 78/100 with strong defensive options but multiple enemy approaches

### Reinforcement Heavy Encounter
Extended engagement with multiple deployment phases:

**Prolonged Battlefield Control:**
- **Initial Phase**: 6 player vs 8 enemy units in standard deployment
- **Reinforcement Phase**: 4 additional units each at turn 8 via reserve zones
- **Priority Evolution**: Initial priorities for setup, later waves for adaptation
- **Spacing**: Dynamic spacing requirements as battlefield density increases
- **Balance Score**: 88/100 with escalating challenge and adaptation opportunities

## Related Wiki Pages
- [Battle side.md](../battlescape/Battle%20side.md) - Defines which side enemies belong to and their relationships.
- [Squad Autopromotion.md](Squad%20Autopromotion.md) - Promotion mechanics that affect enemy unit ranks and abilities.
- [Battle size.md](../battlescape/Battle%20size.md) - Determines the number and scale of enemy deployments.
- [Battle Map generator.md](../battlescape/Battle%20Map%20generator.md) - Places enemies on generated maps according to deployment rules.
- [Mission objectives.md](../battlescape/Mission%20objectives.md) - Objectives that influence enemy deployment patterns.
- [Units.md](../units/Units.md) - Base unit definitions that deployments draw from.
- [Battlescape AI.md](../ai/Battlescape%20AI.md) - AI systems that control deployed enemies.
- [Spawn Points.md](Spawn%20Points.md) - Individual unit position coordinates
- [Mission Zones.md](Mission%20Zones.md) - Designated placement areas for player units
- [Map Node AI System](Map%20Node%20AI.md) - Priority values guiding distribution decisions
- [Battlefield System](Battlefield.md) - Final result of unit distribution process

## References to Existing Games and Mechanics

The Mission Deployment system draws from enemy scaling and placement mechanics in strategy games:

- **X-COM series (1994-2016)**: Enemy deployment based on mission type and difficulty with rank progression.
- **XCOM 2 (2016)**: Dynamic enemy scaling with pod-based deployments and rank guarantees.
- **Fire Emblem series (1990-2023)**: Enemy placement and scaling based on chapter difficulty.
- **Advance Wars series (2001-2018)**: Enemy unit composition and positioning for different mission types.
- **Jagged Alliance series (1994-2014)**: Enemy patrols and deployment patterns.
- **Civilization series (1991-2021)**: Barbarian camps and enemy unit scaling.
- **Total War series (2000-2022)**: Army composition and deployment for battles.
- **XCOM Series**: AI-driven alien placement with priority-based positioning
- **Fire Emblem**: Strategic unit placement affecting initial tactical advantage
- **Final Fantasy Tactics**: Complex positioning systems with terrain and spacing considerations
- **Tactical RPG Genre**: Standard practice of initial force deployment and positioning phases