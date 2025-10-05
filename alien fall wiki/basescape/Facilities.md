# Facilities

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Size and Footprint System](#size-and-footprint-system)
  - [Construction Lifecycle Management](#construction-lifecycle-management)
  - [Connectivity Requirements](#connectivity-requirements)
  - [Health and Damage System](#health-and-damage-system)
  - [Capacity Contribution Framework](#capacity-contribution-framework)
  - [Service Tag System](#service-tag-system)
  - [Tactical Integration Framework](#tactical-integration-framework)
  - [Operations and Maintenance](#operations-and-maintenance)
  - [Failure Mode Handling](#failure-mode-handling)
- [Examples](#examples)
  - [Research Laboratory](#research-laboratory)
  - [Manufacturing Workshop](#manufacturing-workshop)
  - [Craft Hangar](#craft-hangar)
  - [Living Quarters](#living-quarters)
  - [Radar Array](#radar-array)
  - [Academy](#academy)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

Facilities serve as the modular building blocks of bases in Alien Fall, representing primary strategic choices through data-driven modules that define physical footprint, operational capacities, service capabilities, and connectivity requirements. The system transforms base layout decisions into measurable operational effects, making facility placement, redundancy, and connectivity strategically meaningful. Facilities bridge strategic base management with tactical gameplay by informing both resource accounting and mission map generation, creating coherent consequences across all game systems.

**CRITICAL DESIGN PRINCIPLE**: ALL facility characteristics MUST be defined in TOML configuration files (located in `data/facilities/` or mod directories). NO facilities should be hardcoded in Lua source files. The engine (`src/` folder) contains only the configurable systems and features that process facility definitions, while actual facility specifications (research labs, hangars, power plants, etc.) come exclusively from TOML data files loaded by the TOML loader and initialized at the engine level. This ensures extensive modding capabilities and balancing adjustments without code changes.

## Mechanics

### Size and Footprint System
Facilities occupy base tiles with configurable dimensions:
- Standard Units: Baseline 1×1 tile occupation for compact facilities
- Multi-Tile Structures: Support for larger footprints (2×1, 2×2, 3×2, etc.) for complex facilities
- Placement Metadata: Width and height parameters integrated with base map systems
- Space Efficiency: Larger facilities typically provide greater capacity per tile
- Layout Constraints: Geometric limitations affecting base expansion and connectivity

### Construction Lifecycle Management
Facilities undergo structured development from placement to operation:
- Building State: Initial construction phase upon placement with progress tracking
- Time Requirements: Configurable construction duration in game days
- Cost Structure: Upfront or incremental payment options for construction
- Maintenance During Build: Ongoing costs during construction period
- Service Activation: Capacities and services become available only upon completion

### Connectivity Requirements
Operational functionality depends on base network integration:
- HQ Anchor: All facilities must maintain connection to central access lift
- Contiguous Paths: Corridor tiles required for service provision and access
- Offline State: Unconnected facilities provide no operational benefits
- Network Dependencies: Power and access requirements for full functionality
- Strategic Positioning: Placement affects operational reach, redundancy, and vulnerability

### Health and Damage System
Facilities incorporate durability mechanics for tactical consequences:
- HP Values: Health pools tracking damage accumulation from attacks
- Armor Ratings: Damage reduction system where facilities provide armor points that mitigate incoming damage before applying to HP
- Armor Mechanics: Each armor point reduces damage by 1, with excess damage penetrating to HP
- Facility Armor Contribution: Base defense armor calculated as sum of all facility armor ratings
- Damage Pipeline: Incoming damage → Armor mitigation → HP reduction → Service degradation
- Operational Impact: Damage reduces capacity effectiveness and service availability
- Repair Requirements: Resources and time needed for restoration to full functionality
- Destruction Consequences: Permanent loss requiring reconstruction and strategic replanning

### Capacity Contribution Framework
Facilities provide base-wide resource capabilities through aggregation:
- Aggregated Storage: Base-level capacity pooling rather than per-facility tracking
- Capacity Types: Support for storage volume, throughput rates, static slots, and service capabilities
- Overflow Handling: Deterministic policies for managing capacity exceedance
- Dynamic Updates: Capacity changes triggered by facility status modifications
- Resource Assignment: Units, crafts, and items allocated against total base capacities

### Service Tag System
Facilities advertise capabilities through declarative service tags:
- Capability Advertising: Facilities declare available services and features
- System Discovery: Other game systems check for required service tags
- Feature Enablement: Services unlock specific base capabilities and operations
- Modular Design: Easy addition of new service types through data configuration
- Dependency Management: Service requirements enforced for facility functionality

### Tactical Integration Framework
Facilities contribute to battlescape generation and base defense:
- Map Block Linking: Facilities connect to predefined tactical map segments
- Special Tiles: Turrets, doors, consoles, and fuel caches for tactical gameplay
- Objective Generation: Facilities create mission objectives and defensive positions
- Defensive Participation: Facilities contribute to base defense resolution mechanics
- Geoscape Effects: Radar facilities enhance detection and interception capabilities

### Operations and Maintenance
Facilities require ongoing resource investment for sustained operation:
- Monthly Costs: Recurring expenses for facility upkeep and staffing
- Resource Consumption: Fuel, parts, and supplies required during operation
- Staffing Requirements: Personnel allocation for optimal efficiency
- Efficiency Throttling: Performance reduction with staffing or resource shortages
- Maintenance Scheduling: Periodic downtime requirements for facility upkeep

### Failure Mode Handling
System provides deterministic responses to facility disruptions:
- Immediate Effects: Service and capacity removal upon facility failure
- Consequence Resolution: Predictable handling of operational interruptions
- Player Feedback: Clear status communication for facility state changes
- Recovery Options: Repair procedures, reconstruction, or replacement strategies
- Cascading Effects: Secondary impacts on dependent base systems

## Examples

### Research Laboratory
A 2×2 facility providing scientific advancement capabilities. Contributes 15 research points per day, requires 7 days construction at 200 credits cost, and needs 2 scientists for maintenance. Integrates with tactical maps as high-value console objectives during base defense missions.

### Manufacturing Workshop
A 2×1 production facility offering manufacturing throughput. Provides 25 man-hours per day, constructs in 5 days for 150 credits, and requires 1 engineer. Creates cluttered tactical areas with cover opportunities and workshop obstacles.

### Craft Hangar
A 3×2 vehicle storage and maintenance facility. Grants 1 craft slot and 500 fuel storage units, takes 10 days and 300 credits to build, requiring 1 technician. Generates large open tactical spaces with parked craft as potential objectives.

### Living Quarters
A 2×1 personnel accommodation facility. Provides 8 personnel beds, costs 100 credits over 4 days, with basic staffing included. Spawns defenders from barracks rooms during base assault scenarios.

### Radar Array
A 1×1 detection enhancement facility. Contributes 25 radar range units, builds in 3 days for 75 credits, requiring 1 operator. Places antenna props with defensive value in tactical encounters.

### Defensive Emplacement
A 1×1 hardened defensive facility providing base armor. Grants 10 armor points to base defense, constructs in 6 days for 200 credits, requiring 1 technician. Creates fortified positions with turrets and cover during base assault missions.

### Academy
A 2×2 training and development facility. Offers 20 XP per day training throughput and 2 promotion slots, constructs in 8 days for 250 credits with 2 instructors required. Creates training areas with defensive positions and equipment storage.

## Related Wiki Pages

- [Services.md](../basescape/Services.md) - Facility-provided operational capabilities.
- [Capacities.md](../basescape/Capacities.md) - Facility contribution limits and constraints.
- [New Base building.md](../basescape/New%20Base%20building.md) - Facility placement and construction sequencing.
- [Monthly base report.md](../basescape/Monthly%20base%20report.md) - Facility status and performance tracking.
- [Finance.md](../finance/Finance.md) - Construction and maintenance costs.
- [Research.md](../basescape/Research.md) - Technology requirements for advanced facilities.
- [Manufacturing.md](../economy/Manufacturing.md) - Facility construction material requirements.
- [Technical Architecture.md](../architecture.md) - Facility data structures and systems.
- [Geoscape.md](../geoscape/Geoscape.md) - Strategic facility positioning.
- [Battlescape.md](../battlescape/Battlescape.md) - Tactical facility integration.

## References to Existing Games and Mechanics

- **XCOM Series**: Base facilities and building construction systems
- **Civilization**: City buildings and infrastructure improvements
- **SimCity**: City buildings and urban development systems
- **The Sims**: House rooms and facility construction mechanics
- **Prison Architect**: Prison buildings and facility management
- **RimWorld**: Colony buildings and construction systems
- **Banished**: Town buildings and infrastructure development
- **Cities: Skylines**: City buildings and service infrastructure
- **Crusader Kings**: Castle buildings and holding improvements
- **Europa Universalis**: Province buildings and development systems

