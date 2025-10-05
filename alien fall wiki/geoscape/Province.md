# Province

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Definition Fields and Properties](#definition-fields-and-properties)
  - [Graph Adjacency and Routing Systems](#graph-adjacency-and-routing-systems)
  - [Spatial Mathematics and Detection Integration](#spatial-mathematics-and-detection-integration)
  - [Mission Hosting and Persistence Framework](#mission-hosting-and-persistence-framework)
  - [Event Targeting and Proximity Systems](#event-targeting-and-proximity-systems)
  - [Display and Presentation Framework](#display-and-presentation-framework)
  - [Authoring Guidelines and Modding Support](#authoring-guidelines-and-modding-support)
- [Examples](#examples)
  - [Definition Fields and Properties Cases](#definition-fields-and-properties-cases)
  - [Graph Adjacency and Routing Scenarios](#graph-adjacency-and-routing-scenarios)
  - [Spatial Mathematics and Detection Applications](#spatial-mathematics-and-detection-applications)
  - [Mission Hosting and Persistence Cases](#mission-hosting-and-persistence-cases)
  - [Event Targeting and Proximity Scenarios](#event-targeting-and-proximity-scenarios)
  - [Display and Presentation Cases](#display-and-presentation-cases)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Province system establishes atomic spatial anchors on the geoscape representing discrete points where bases, missions, and events occur, using a point-and-graph model for precise spatial calculations while maintaining visual fidelity with authored world maps. Provinces provide data-driven configuration for biome assignment, economic values, population demographics, and tag-based filtering that feeds tactical generation, detection mechanics, and regional scoring. The system enables deterministic routing, mission hosting, and event targeting with seeded reproducibility across campaigns while supporting comprehensive modding through explicit adjacency graphs and data-driven properties.

From a design perspective, a Province is the atomic spatial anchor on the Geoscape: a single point that represents where bases, missions and events occur. Using points rather than polygons keeps world art fidelity while enabling designers to author rich adjacency graphs for routing and mission logic. Provinces expose simple data (coords, biome, economy) that feed tactical generation, detection calculations and regional scoring without overcomplicating geometry.

## Mechanics

### Definition Fields and Properties

Comprehensive province data structure for spatial and strategic representation:

- Identity Records: Unique id, display name, world membership, and coordinate data for precise identification
- Coordinate System: X/Y pixel coordinates relative to world image enabling image-anchored spatial mathematics
- Biome Assignment: Environmental classification determining terrain selection, tactical themes, and mission constraints
- Physical Properties: Land/water flags and terrain modifiers affecting movement, detection, and operational capabilities
- Economic Data: Economy value and population metrics influencing funding calculations, mission rewards, and strategic value
- Regional Organization: Region and country membership for diplomatic grouping, strategic assessment, and narrative control
- Tag System: Classification tags enabling mission filtering, capability requirements, and special behavior gating
- Control States: Ownership tracking (neutral, player-controlled, alien-controlled) with base hosting capabilities

### Graph Adjacency and Routing Systems

Tile-map-derived edge-based movement and connectivity framework:

- Hex Grid Foundation: Province connections calculated from globe tile map paths with movement cost considerations
- Craft-Specific Adjacency: Land vehicles connect via land tiles only, ships via water tiles, airplanes with uniform connectivity
- Explicit Edges: Travel and movement determined by tile map pathfinding representing air lanes, sea routes, or gameplay flows
- Designer Intent: Edge graphs reflect intended play flows and strategic considerations rather than strict geographic adjacency
- Pathfinding Logic: Player crafts, UFOs, and convoys use province graph for routing with weighted edge calculations
- Distance Options: Systems may choose pixel-based Euclidean distance or graph-edge distance for specialized movement rules
- Connectivity Control: Adjacency graphs create strategic chokepoints, transportation hubs, and movement corridors
- Override Capability: Campaigns may override default distance math for specific systems or mission types

### Spatial Mathematics and Detection Integration

Grid-anchored spatial calculations for strategic systems:

- Hex Grid Positioning: All provinces snapped to hex tile intersections for consistent pathfinding calculations
- Pixel Distance: Euclidean pixel distance converted to real-world units via pixel_distance × pixel_to_km ratio
- Detection Calculations: Precise spatial math for radar ranges, interception coverage, and detection zone determination
- Interception Integration: Detection sources use province coordinates as anchor points for coverage calculations
- Range Validation: Craft operational ranges validated against province-to-province distances for mission assignment
- Visual Fidelity: Image-anchored coordinates preserve world art accuracy while enabling mathematical precision
- Deterministic Calculations: Seeded spatial math ensures reproducible detection, range, and routing outcomes

### Mission Hosting and Persistence Framework

Province-scoped mission management and state tracking:

- Point Ownership: Missions owned by single province points with concurrent hosting capabilities
- Multiple Missions: Provinces support multiple simultaneous missions at same location with configurable limits
- Persistent Types: Alien bases and ongoing operations remain until explicitly resolved by player or script
- State Management: Province mission lists track active operations, resolution status, and completion processing
- Concurrent Limits: Configurable maximum concurrent missions based on province size and activity level
- Resolution Tracking: Automatic cleanup and reward distribution upon mission completion

### Event Targeting and Proximity Systems

Coordinate-based event mechanics and regional influence:

- Focal Coordinates: Events use province points as canonical locations for spawns, triggers, and proximity checks
- Proximity Checks: Distance-based event conditions calculated from province coordinate anchors
- Area Effects: Province points define centers for regional event influence and targeting zones
- Event Clustering: Multiple events can target same province for concentrated activity periods
- Dynamic Positioning: Province coordinates enable real-time event placement and movement tracking
- Strategic Influence: Province properties affect event weighting and regional activity patterns

### Display and Presentation Framework

Visual representation and user interface integration:

- Marker Rendering: Provinces displayed as small markers on world image with configurable appearance and indicators
- Selection Radius: Display radius (≈16px) guides UI interactions without implying area ownership or territorial control
- Visual Indicators: Color coding and markers reflect province properties, activity status, and control states
- Hover Information: Province details displayed on mouse interaction for strategic planning and reconnaissance
- Overlay Systems: Province data integrated into strategic interface overlays, information displays, and status panels
- Accessibility Features: Clear visual hierarchy and information presentation for strategic decision-making

### Authoring Guidelines and Modding Support

Designer control and extensibility framework:

- Designer Control: All province properties data-driven to support modding and deterministic simulation
- Graph Authoring: Adjacency edges reflect intended play flows and strategic considerations for gameplay clarity
- Tag Usage: Classification system gates mission types without overloading biome fields with special behaviors
- Distance Consistency: Clear documentation when graph-edge distance replaces pixel-km calculations for specific systems
- Test Accessibility: Province-level debugging hooks for coordinate display, neighbor lists, property inspection, and validation
- Modding Integration: Comprehensive customization support for province creation, property modification, and graph editing

## Examples

### Definition Fields and Properties Cases
- Major City: Id "new_york", coordinates (450, 280), biome "urban", economy 85, population 50M, tags ["coastal", "high_population"], control_state "player_controlled"
- Remote Wilderness: Id "amazon_rainforest", coordinates (320, 400), biome "jungle", economy 15, population 100K, tags ["remote", "dense_terrain"], control_state "neutral"
- Ocean Province: Id "atlantic_ocean", coordinates (380, 350), is_water true, biome "ocean", economy 5, population 0, tags ["naval", "deep_water"], control_state "neutral"
- Industrial Hub: Id "ruhr_valley", coordinates (410, 220), biome "industrial", economy 70, population 25M, tags ["industrial", "polluted"], control_state "player_controlled"
- Mountain Pass: Id "alpine_crossing", coordinates (395, 240), biome "mountain", economy 20, population 50K, tags ["mountainous", "strategic"], control_state "alien_controlled"

### Graph Adjacency and Routing Scenarios
- Land Vehicle Network: Ground transport connected via land tile paths, avoiding water barriers and using mountain passes (cost 4)
- Ship Routing: Naval craft connected through water tile chains with single coastal province access points
- Air Lane Network: New York connected to Boston (300km), Washington DC (400km), Philadelphia (150km) representing major air corridors
- Sea Route System: Atlantic province connected to European ports via established shipping lanes with distance-based travel times
- Strategic Chokepoint: Mountain pass province with limited connections creating defensive bottleneck and interception opportunity
- Hub-and-Spoke Design: Major city province connected to multiple regional provinces enabling efficient fleet distribution
- Designer Intent: Coastal province connected to inland provinces despite geographic separation for gameplay flow optimization

### Spatial Mathematics and Detection Applications
- Radar Coverage: 500km radar range from base province creates detection circle covering 8 surrounding provinces
- Interception Zone: Fighter craft with 1000km range can intercept missions within 15 province radius
- Pixel Distance: 400 pixel separation × 25 pixels/km = 10,000 km straight-line distance for travel calculations
- Detection Validation: UFO entering 300km detection zone triggers interception alert and craft scramble
- Range Optimization: Satellite detector placement maximizing coverage across 50+ province network
- Override Rules: Strategic bombers using graph-edge distance for mission planning, ignoring straight-line geography

### Mission Hosting and Persistence Cases
- Concurrent Operations: Urban province hosting crash site mission, terror attack, and alien base simultaneously
- Persistent Threats: Alien base remaining active in province until player assault mission successfully resolves it
- Mission Limits: High-activity province capped at 5 concurrent missions based on population and strategic value
- State Tracking: Province mission roster showing 3 active operations with completion status and reward preview
- Resolution Processing: Crash site mission completion triggers automatic cleanup and salvage reward distribution
- Dynamic Capacity: Province mission limits scaling with alien activity level and player strategic pressure

### Event Targeting and Proximity Scenarios
- Spawn Coordination: Alien activity event targeting high-population province with 10M+ inhabitants
- Proximity Triggers: Research breakthrough event affecting all provinces within 1000km of laboratory base
- Area Effects: Terror mission creating fear effect in province and all adjacent connected provinces
- Event Clustering: Multiple abduction events targeting same province cluster during high-activity period
- Dynamic Positioning: UFO flight path calculated using province graph for realistic movement between targets
- Strategic Influence: High-value province attracting disproportionate alien attention and mission frequency

### Display and Presentation Cases
- Marker Rendering: Urban province displayed as large city icon with population-based size scaling
- Visual Indicators: Alien-controlled province shown in red with threat level overlay and activity animations
- Hover Information: Mouse-over revealing province name, biome, population, current missions, and control status
- Overlay Systems: Detection coverage heatmap overlaying province markers with range circles and gap indicators
- Strategic Interface: Province selection highlighting connected routes, travel times, and interception coverage
- Status Panels: Real-time display of province activity, mission status, and economic contribution

## Related Wiki Pages

- [Region.md](../geoscape/Region.md) - Regional province grouping.
- [World.md](../geoscape/World.md) - World province composition.
- [Biome.md](../geoscape/Biome.md) - Province biome assignment.
- [Universe.md](../geoscape/Universe.md) - Multi-world province systems.
- [Geoscape.md](../geoscape/Geoscape.md) - Strategic layer integration.
- [Mission Detection and Assignment.md](../interception/Mission%20Detection%20and%20Assignment.md) - Province-based mission spawning.
- [Monthly reports.md](../finance/Monthly%20reports.md) - Province economic reporting.
- [Country.md](../geoscape/Country.md) - Province diplomatic grouping.

## References to Existing Games and Mechanics

- **Civilization Series**: City states and province control
- **Europa Universalis**: Province ownership and development
- **Crusader Kings**: County and province management
- **Hearts of Iron**: Province control and strategic positioning
- **Victoria Series**: Province administration and economy
- **Stellaris**: System control and colonization
- **Endless Space**: Planet ownership and development
- **Galactic Civilizations**: Planet control and resource management
- **Total War Series**: Province conquest and management
- **Warcraft III**: Territory control and base building

