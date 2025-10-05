# Battlefield System

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Core Components](#core-components)
  - [Battlefield Lifecycle](#battlefield-lifecycle)
  - [Battlefield Systems](#battlefield-systems)
- [Examples](#examples)
  - [Urban Combat Scenario](#urban-combat-scenario)
  - [Rural Ambush Scenario](#rural-ambush-scenario)
  - [Facility Breach Scenario](#facility-breach-scenario)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Battlefield System implements the complete tactical combat environment, consisting of the Battle Grid with all integrated game elements forming a cohesive gameplay space. It represents the playable tactical area where turn-based combat occurs, combining terrain layers, unit positioning, environmental effects, and mission objectives into a unified simulation. The system manages the entire battlefield lifecycle from generation through resolution, ensuring balanced and engaging tactical experiences.

The battlefield serves as the central hub for all tactical interactions, providing the complete game state that determines strategic possibilities, combat outcomes, and mission success. Data-driven configuration and deterministic processes enable extensive modding while maintaining consistent gameplay mechanics across different mission types and environmental conditions.

## Mechanics

### Core Components
Fundamental elements comprising the tactical battlefield environment.

#### Battle Grid Foundation
The detailed 2D array of Battle Tiles forming the playable tactical space.

**Grid Structure:**
- **Dimensions**: Variable size based on Battle Size (60×60 to 105×105 tiles)
- **Tile Resolution**: 20×20 pixels per tile for precise positioning
- **Total Area**: 1200×1200 to 2100×2100 pixels of tactical battlefield
- **Coordinate System**: Integer coordinates from (0,0) at top-left origin

#### Integrated Game Elements
All tactical components layered within the battlefield coordinate system.

**Terrain Layer:**
- **Static Terrain**: Map Grid conversion with blocking and elevation properties
- **Destructible Elements**: Walls, structures, and interactive terrain features
- **Environmental Features**: Natural obstacles, cover, and terrain modifiers

**Unit Layer:**
- **Faction Units**: Player, enemy, ally, and neutral units with positioning
- **Status Effects**: Health, morale, and temporary condition tracking
- **Action States**: Movement points, action availability, and cooldowns

**Environmental Layer:**
- **Dynamic Effects**: Smoke, fire, fog with propagation and dissipation
- **Temporary Hazards**: Explosive debris, toxic spills, electrical damage
- **Weather Systems**: Rain, wind, lighting affecting visibility and effects

**Objective Layer:**
- **Mission Elements**: Victory/defeat condition triggers and checkpoints
- **Interactive Objects**: Doors, switches, containers, and destructibles
- **Strategic Points**: Control zones, extraction points, and waypoints

### Battlefield Lifecycle
Complete operational phases from creation to conclusion.

#### Generation Phase
Deterministic battlefield creation from mission parameters.

**Process Steps:**
1. **Strategic Context**: Mission type, difficulty, and faction requirements
2. **Map Generation**: Map Grid assembly and Battle Grid conversion
3. **Unit Deployment**: Spawn point calculation and initial positioning
4. **Environmental Setup**: Effects, hazards, and atmospheric conditions
5. **Validation**: Playability verification and balance confirmation

#### Active Combat Phase
Real-time tactical gameplay with dynamic state management.

**Dynamic Elements:**
- **Unit Actions**: Movement, attacks, and special abilities execution
- **Combat Resolution**: Damage calculation, effect application, and casualties
- **Environmental Changes**: Destruction, fire spread, and effect propagation
- **Objective Updates**: Mission progress tracking and condition evaluation

#### Resolution Phase
Battlefield conclusion with outcome determination and cleanup.

**End Conditions:**
- **Victory**: All primary objectives completed within parameters
- **Defeat**: Critical failure conditions met (unit elimination, objective loss)
- **Withdrawal**: Tactical retreat with partial objective completion
- **Stalemate**: Time/objective limits reached with unresolved state

### Battlefield Systems
Core tactical systems operating within the battlefield environment.

#### Fog of War
Asymmetric information system limiting faction knowledge.

**Visibility Mechanics:**
- **Line of Sight**: Real-time visibility calculations between positions
- **Explored Areas**: Previously revealed tiles with current status tracking
- **Unit Vision**: Individual sight ranges with environmental modifiers
- **Faction Asymmetry**: Different visibility states per participating faction

#### Environmental Effects
Dynamic battlefield conditions with tactical consequences.

**Effect Categories:**
- **Visibility Modifiers**: Smoke clouds reducing accuracy and sight
- **Damage-over-Time**: Fire spread causing continuous unit damage
- **Movement Hazards**: Slippery surfaces, difficult terrain, or blockages
- **Status Conditions**: Environmental effects applying to units in area

#### Destructible Terrain
Battlefield modification through combat actions and environmental changes.

**Destruction Mechanics:**
- **Structural Failure**: Walls crumbling, floors collapsing from damage
- **Environmental Propagation**: Fire damage creating new hazardous areas
- **Tactical Alteration**: New cover creation or path blocking opportunities
- **Strategic Shifts**: Battlefield geometry changes affecting positioning

## Examples

### Urban Combat Scenario
Dense city environment with complex verticality and cover opportunities.

**Battlefield Characteristics:**
- **Grid Dimensions**: 75×75 tiles with mixed indoor/outdoor spaces
- **Terrain Composition**: 40% buildings, 30% streets, 30% rubble and debris
- **Environmental Factors**: Limited visibility from urban canyons, destructible cover
- **Strategic Elements**: Building control, rooftop positioning, street bottlenecks

**Tactical Dynamics:**
- **Positioning**: Critical elevation control and building clearance
- **Mobility**: Restricted by narrow streets and structural barriers
- **Visibility**: Complex line-of-sight patterns requiring careful advancement
- **Objectives**: Multi-building control with civilian protection requirements

### Rural Ambush Scenario
Open terrain with natural features and long engagement ranges.

**Battlefield Characteristics:**
- **Grid Dimensions**: 90×90 tiles with expansive open spaces
- **Terrain Composition**: 60% open ground, 25% wooded areas, 15% elevation
- **Environmental Factors**: Weather effects, natural cover, long sight lines
- **Strategic Elements**: Ambush positions, flanking routes, defensive terrain

**Tactical Dynamics:**
- **Positioning**: Elevation advantages and natural cover utilization
- **Mobility**: High movement freedom with flanking opportunities
- **Visibility**: Extended ranges enabling coordinated fire and movement
- **Objectives**: Area control with time-sensitive extraction requirements

### Facility Breach Scenario
Confined indoor environment with structural complexity.

**Battlefield Characteristics:**
- **Grid Dimensions**: 60×60 tiles focused on building interiors
- **Terrain Composition**: 50% corridors/rooms, 30% structural elements, 20% open areas
- **Environmental Factors**: Limited external visibility, artificial lighting
- **Strategic Elements**: Doorway control, room clearing, security systems

**Tactical Dynamics:**
- **Positioning**: Doorway and corner control for room-by-room advancement
- **Mobility**: Channelled movement through corridors and choke points
- **Visibility**: Severely restricted ranges requiring close-quarters tactics
- **Objectives**: Secure facility areas with minimal collateral damage

## Related Wiki Pages

Battlefield integrates all tactical systems into unified gameplay:

- **Battle Grid.md**: Underlying tile structure and coordinate system
- **Battle Tile.md**: Individual cells with terrain and state properties
- **Battle Size.md**: Determines battlefield scale and unit deployment
- **Map Generation**: Battlefield creation from strategic parameters
- **Unit Deployment**: Initial positioning and spawn mechanics
- **Fog of War**: Visibility and information asymmetry systems
- **Environmental Effects**: Dynamic battlefield conditions and hazards
- **Destructible Terrain**: Battlefield modification through combat
- **Mission Objectives**: Victory/defeat conditions and progress tracking
- **Turn System**: Combat phase management and action resolution
- **AI Systems** (ai/): Computer-controlled unit decision making

## References to Existing Games and Mechanics

The Battlefield system draws from comprehensive tactical gameplay:

- **X-COM series (1994-2016)**: Complete tactical environments with terrain interaction
- **Jagged Alliance series (1994-2014)**: Detailed battlefield simulation with destruction
- **Commandos series (1998-2018)**: Complex environmental interaction and positioning
- **Fire Emblem series (1990-2023)**: Terrain-based tactical combat and positioning
- **BattleTech (1984-2024)**: Battlefield modification and environmental effects
- **Total War series (2000-2022)**: Large-scale battlefield management
- **Tactical RPGs**: Comprehensive battlefield systems in Final Fantasy Tactics
- **Real-time Tactics**: Battlefield dynamics in games like Valkyria Chronicles