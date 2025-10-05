# World

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [World Configuration and Scaling](#world-configuration-and-scaling)
  - [Province Data Architecture](#province-data-architecture)
  - [Globe Tile Map](#globe-tile-map)
  - [Distance and Travel Systems](#distance-and-travel-systems)
  - [Illumination and Time Cycles](#illumination-and-time-cycles)
  - [Pathfinding and Navigation](#pathfinding-and-navigation)
  - [Mission Integration Framework](#mission-integration-framework)
  - [Detection and Sensor Systems](#detection-and-sensor-systems)
- [Examples](#examples)
  - [World Configuration Cases](#world-configuration-cases)
  - [Province Data Architecture Examples](#province-data-architecture-examples)
  - [Globe Tile Map Examples](#globe-tile-map-examples)
  - [Distance and Travel Systems Cases](#distance-and-travel-systems-cases)
  - [Illumination and Time Cycles Examples](#illumination-and-time-cycles-examples)
  - [Pathfinding and Navigation Scenarios](#pathfinding-and-navigation-scenarios)
  - [Mission Integration Framework Cases](#mission-integration-framework-cases)
  - [Detection and Sensor Systems Examples](#detection-and-sensor-systems-examples)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The World system provides the strategic playfield for geoscape operations, serving as the primary container for all geographic and strategic elements. Each world contains:
- **Regions**: Geographic groupings of provinces for organizational purposes
- **Countries**: Political entities grouping provinces for funding and diplomatic relations
- **Provinces**: Individual strategic points where bases, missions, and events occur
- **Background Image**: Visual representation of the world (planet, dimension, etc.)
- **Province Graph/Connections**: Network defining movement and adjacency between provinces
- **Campaign System**: Monthly mission generation and alien activity management
- **Factions**: Enemy and neutral organizations operating on this world
- **Suppliers**: Vendors and black market contacts for purchasing items

The system implements a pixel-to-kilometer scaling system that transforms 2D map coordinates into meaningful strategic distances. Worlds enable distinct rulesets, biomes, and regional modifiers so each planet presents unique strategic challenges while preserving artistic fidelity and deterministic behavior.

## Mechanics

### World Configuration and Scaling

Strategic playfield definition with consistent scaling:
- Background Assets: Visual world representation with pixel-based dimensions (1600x800 default)
- Scaling Systems: Pixel-to-kilometer conversion factor (25 pixels = 1 km typical) for predictable spatial calculations
- Resolution Flexibility: Different world resolutions supporting varied conversion factors and consistent subsystem behavior
- Rotation Parameters: World rotation period (24 hours default) and current rotation degrees for illumination calculations
- Artistic Fidelity: Authored map art preservation with precise spatial mathematics for detection and routing
- Modular Design: Distinct rulesets per world enabling unique strategic challenges and campaign variety

### Province Data Architecture

Point-and-graph model for geographic representation:
- Spatial Anchors: Single point locations on world map (8 pixel display radius) snapped to underlying hex grid
- Adjacency Networks: Explicit edges defining permitted travel and routing structures
- Geographic Properties: Longitude/latitude coordinates, biome classifications, and population data
- Strategic Metadata: Alien activity levels, base presence tracking, and mission roster management
- Designer Control: Precise spatial mathematics for range, transit costs, and detection calculations
- Graph Semantics: Movement and detection governed by adjacency relationships and designer-controlled routing

### Globe Tile Map

Virtual hex grid system for craft movement pathfinding:
- Hexagonal Grid: 80x40 tile world representation (approximately 500km per tile for Earth)
- Tile Types: Land tiles (movement costs 1, 2, or 4) and water tiles (movement cost 1)
- Pathfinding Foundation: Used exclusively for calculating travel costs between provinces
- Craft-Specific Movement: Land vehicles traverse land only, ships use water + coastal access, airplanes ignore terrain costs
- Visual Separation: Independent of world background image; virtual grid for strategic calculations only
- Province Integration: All provinces positioned on grid intersections; no gameplay occurs on tiles themselves
- Instant Travel: Craft movements between provinces occur instantly within single turns
- Isolation Mechanics: Crafts cannot encounter missions or other crafts during transit

### Distance and Travel Systems

Canonical scaling for spatial calculations:
- Euclidean Distance: Straight-line pixel distance converted to kilometers using pixel_to_km ratio
- Graph Distance: Province-to-province pathfinding using adjacency relationships and edge weights
- Travel Modifiers: Biome effects (urban: 1.1x, desert: 1.3x, mountain: 1.5x, ocean: 2.0x) and weather conditions
- Time Calculations: Hours required for craft movement with illumination-based adjustments
- Economic Factors: Action point budgeting, fuel consumption, and detection risk trade-offs
- Override Capabilities: Subsystem-specific distance calculations for specialized movement or detection rules

### Illumination and Time Cycles

Dynamic day/night system affecting operations:
- Rotation Mechanics: World rotation degrees determining illumination angles and daylight fractions
- Sinusoidal Functions: Local daylight fraction per province using sine/cosine calculations from longitude
- Illumination Phases: Full day, twilight, night classifications with seasonal variation considerations
- Procedural Overlays: Real-time shadow casting, atmospheric effects, and terrain masking
- Operational Effects: Detection range modifications, mission spawning preferences, and visibility adjustments
- Runtime Flexibility: Precomputed images or real-time calculations for UI rendering and simulation queries

### Pathfinding and Navigation

Tile-map-based movement optimization:
- Hex Grid Pathfinding: A* algorithm using globe tile movement costs between province positions
- Craft-Specific Routing: Land vehicles restricted to land tiles, ships to water tiles, airplanes with uniform cost
- Adjacency Relationships: Province connections derived from tile map paths with weighted edges
- Bidirectional Search: Efficient pathfinding algorithms for large province graphs
- Portal Integration: Special zero-cost connections bypassing normal geographic adjacency
- Performance Optimization: Caching for common routes, hierarchical search, and memory-efficient storage
- Strategic Applications: Craft routing, mission planning, coverage analysis, and AI decision optimization
- Dynamic Updates: Real-time path recalculation for changing world conditions

### Mission Integration Framework

Province-scoped event system:
- Spawn Scheduling: Event-driven mission generation with priority queuing and condition evaluation
- Template System: Reusable mission configurations adapted to province characteristics
- Hook Architecture: Province-scoped scheduling with delay mechanisms and callback integration
- Condition Requirements: Population thresholds, alien activity levels, daylight phases, and biome filtering
- State Management: Active mission tracking, completion processing, and persistence mechanisms
- Modding Support: Custom spawn conditions, mission types, and event-driven integration

### Detection and Sensor Systems

Multi-sensor coverage and environmental effects:
- Range Calculations: Base-specific ranges (radar: 500km, satellite: 2000km, visual: 50km) with terrain modifiers
- Environmental Effects: Biome, illumination, and weather impacts on sensor effectiveness
- Sensor Fusion: Combined detection from multiple sensor types with redundancy and accuracy adjustments
- Strategic Applications: Alien activity monitoring, craft interception, mission intelligence, and theater awareness
- Coverage Optimization: Position selection for maximum coverage and false positive management
- Balance Tools: Coverage heatmaps and effectiveness visualization for design validation

## Examples

### World Configuration Cases
- Earth Configuration: 1600×800 pixel map, 25 pixels = 1 km scale, 24-hour rotation, Major population centers as provinces
- Mars Configuration: Different image and conversion ratio, Scientific landmarks as province sites, Planet-specific operational rules
- Europa Configuration: Ice/ocean background emphasis, Under_ice province tags, Special sensor and traversal requirements
- Underworld Configuration: Distinct background and province graph, Seismic sensors replacing radar, Unique detection mechanics

### Province Data Architecture Examples
- Major City: Id "new_york", coordinates (450, 280), biome "urban", economy 85, population 50M, tags ["coastal", "high_population"], control_state "player_controlled"
- Remote Wilderness: Id "amazon_rainforest", coordinates (320, 400), biome "jungle", economy 15, population 100K, tags ["remote", "dense_terrain"], control_state "neutral"
- Ocean Province: Id "atlantic_ocean", coordinates (380, 350), is_water true, biome "ocean", economy 5, population 0, tags ["naval", "deep_water"], control_state "neutral"
- Industrial Hub: Id "ruhr_valley", coordinates (410, 220), biome "industrial", economy 70, population 25M, tags ["industrial", "polluted"], control_state "player_controlled"
- Mountain Pass: Id "alpine_crossing", coordinates (395, 240), biome "mountain", economy 20, population 50K, tags ["mountainous", "strategic"], control_state "alien_controlled"

### Globe Tile Map Examples
- Earth Configuration: 80×40 hex grid, ~75 land provinces + 75 water provinces, land tiles with varied costs (1-4), water tiles cost 1
- Land Vehicle Routing: Ground transport restricted to land tiles only, pathfinding around water barriers
- Ship Navigation: Naval craft using water tiles with one coastal province access point
- Air Superiority: Fighter craft ignoring terrain costs, moving with uniform speed across all tile types
- Mountain Terrain: High-cost land tiles (cost 4) creating strategic bottlenecks for ground movement

### Distance and Travel Systems Cases
- Euclidean Calculation: 400 pixel distance × 25 pixels/km = 10,000 km straight-line travel
- Graph Pathfinding: Province A to Province C via Province B (500km + 300km = 800km total)
- Travel Modifiers: Urban route 1.1x multiplier, Desert crossing 1.3x penalty, Night travel 1.5x time increase
- Economic Factors: 8-hour transit consuming 2 fuel units, Detection risk increase during high-speed movement
- Override Capabilities: Radar using Euclidean distance, Strategic movement using graph-based routing
- Time Calculations: 500km at 500km/h = 1 hour daytime, 1.5 hours nighttime with illumination penalty

### Illumination and Time Cycles Examples
- Rotation Mechanics: 180° rotation yields 0.5 daylight fraction, Twilight illumination phase active
- Sinusoidal Functions: Province at 45° longitude with 90° world rotation produces 0.707 daylight fraction
- Illumination Phases: Full day (1.0 fraction), Twilight (0.3-0.7 fraction), Night (0.0 fraction) classifications
- Procedural Overlays: Real-time shadow casting at 45° solar angle, Cloud cover reducing illumination by 20%
- Operational Effects: Night detection reduced to 60% effectiveness, Nocturnal mission types spawning preferentially
- Runtime Flexibility: Precomputed illumination overlay for performance, Real-time calculation for dynamic weather

### Pathfinding and Navigation Scenarios
- Hex Grid Pathfinding: A* algorithm using tile movement costs, land vehicle avoiding water tiles, ship restricted to coastal routes
- Craft-Specific Routing: Interceptor ignoring terrain costs vs transport navigating mountain bottlenecks (cost 4 tiles)
- Adjacency Relationships: New York connected to Boston (300km), Washington DC (400km), Philadelphia (150km)
- Bidirectional Search: Efficient A* algorithm finding optimal routes across 200+ province graphs
- Portal Integration: Earth-Mars portal providing zero-cost connection, Bypassing 50 million km normal distance
- Performance Optimization: Cached routes for common base-to-mission paths, Hierarchical search for continental scales
- Strategic Applications: Interceptor routing to UFO interception point, Transport path to evacuation site
- Dynamic Updates: Path recalculation when portal becomes unstable, Alternative routing around blocked provinces

### Mission Integration Framework Cases
- Spawn Scheduling: Crash site mission triggered by alien activity > 0.7, Queued for next available slot
- Template System: Generic "UFO Landing" adapted to urban biome, Population-based reward scaling applied
- Hook Architecture: Province-scoped on_mission_spawn hook firing, Mod integration for custom mission types
- Condition Requirements: Urban mission requires population > 1M, Night mission spawns only during darkness
- State Management: Active mission roster tracking 5 concurrent missions, Completion triggering reward distribution
- Modding Support: Custom spawn conditions for mod missions, Event-driven integration with campaign systems

### Detection and Sensor Systems Examples
- Range Calculations: Radar detector covers 500km radius, Terrain blocking reduces to 300km in mountains
- Environmental Effects: Desert biome increases detection by 30%, Heavy rain reduces satellite effectiveness by 50%
- Sensor Fusion: Radar + satellite coverage providing 95% accuracy, Redundant detection for critical intelligence
- Strategic Applications: Province threat assessment at activity level 0.8, Interception tracking of inbound UFO
- Coverage Optimization: Detector placement maximizing coverage gaps, False positive rate maintained below 5%
- Balance Tools: Coverage heatmap showing 85% province visibility, Gap analysis identifying coverage weaknesses

## Related Wiki Pages

- [Geoscape.md](../geoscape/Geoscape.md) - Strategic layer and world management.
- [World time.md](../geoscape/World%20time.md) - Time cycles and world progression.
- [Portal.md](../geoscape/Portal.md) - Travel systems and interdimensional access.
- [Battle map.md](../battlescape/Battle%20map.md) - Mission integration and tactical deployment.
- [Crafts.md](../crafts/Crafts.md) - Craft systems and aerial navigation.
- [Finance.md](../finance/Finance.md) - Economic systems and resource distribution.
- [AI.md](../ai/AI.md) - AI systems and strategic decision-making.
- [Mission objectives.md](../battlescape/Mission%20objectives.md) - Mission generation and world events.
- [Interception.md](../interception/Interception.md) - Detection systems and sensor networks.
- [Research tree.md](../economy/Research%20tree.md) - World exploration and technology advancement.

## References to Existing Games and Mechanics

- **Civilization Series**: World maps and province-based management
- **X-COM Series**: Geoscape world management and global strategy
- **Europa Universalis IV**: World simulation and province control
- **Crusader Kings III**: World management and feudal systems
- **Stellaris**: Galaxy management and interstellar exploration
- **Total War Series**: World campaigns and territorial control
- **Advance Wars**: World maps and strategic positioning
- **Fire Emblem Series**: World navigation and kingdom management
- **Final Fantasy Tactics**: World structure and regional conflicts
- **Tactics Ogre**: World design and territorial warfare

