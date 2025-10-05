# Craft Operations

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Mission Assignment](#mission-assignment)
  - [Movement and Range](#movement-and-range)
  - [Operational Constraints](#operational-constraints)
  - [Interception_Scape Transition](#interception_scape-transition)
  - [Data Flow Integration](#data-flow-integration)
- [Examples](#examples)
  - [Mission Assignment Scenarios](#mission-assignment-scenarios)
  - [Range and Movement Cases](#range-and-movement-cases)
  - [Operational Constraint Examples](#operational-constraint-examples)
  - [Interception Transition Cases](#interception-transition-cases)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview
The Craft Operations system handles the geoscape-level mechanics for craft mission assignment, movement, and fuel consumption. This system bridges the strategic world view with tactical interception combat, providing the UI and logic for players to deploy craft against detected missions. Craft operations manage the transition from strategic planning to tactical engagement while maintaining clear operational constraints and predictable resource management through deterministic mechanics and seeded randomization.

## Mechanics

### Mission Assignment
- Province Selection: Players select provinces containing missions for craft deployment
- Craft Selection: Available craft within operational range are displayed for assignment
- Range Validation: Craft must be within their maximum operational range from home base
- Fuel Verification: Sufficient fuel must be available at the craft's assigned base
- Speed Limits: Craft cannot exceed their daily mission capacity based on speed statistics
- Deployment Execution: Selected craft moves to the province and triggers interception resolution

### Movement and Range
- Operational Radius: Craft can only operate within their maximum range from home base
- Distance Calculations: Mission fuel consumption based on globe tile map path distances between provinces
- Craft Movement Types: Land vehicles traverse land tiles only, ships use water tiles, airplanes ignore terrain costs
- Speed Limitations: Craft speed stat determines maximum missions performable per day
- Home Base Dependency: All operations originate from and return to the craft's assigned base
- No Refueling: Fuel is consumed immediately when mission is accepted, no mid-mission refueling

### Operational Constraints
- Range Enforcement: Strict range limits prevent craft from accepting distant missions
- Fuel Requirements: Each mission consumes fuel proportional to distance traveled
- Daily Limits: Speed-based restrictions on missions per day prevent overextension
- Base Assignment: All fuel consumption and maintenance occurs at the craft's home base
- Resource Accounting: Immediate fuel deduction ensures operational sustainability

### Interception_Scape Transition
- Combat Trigger: Craft arrival at mission province activates unified tactical screen
- Participant Positioning: All craft in province (player and enemy) positioned in appropriate zones
- Environmental Context: Province biome and terrain determine interception parameters
- Base Integration: Nearby base facilities can participate as defensive weapons
- Resolution Outcomes: Combat results determine next phase progression
- State Synchronization: Interception results update geoscape mission and craft states
- Resource Accounting: Fuel, damage, and salvage calculations applied to geoscape entities

### Data Flow Integration
- Mission State Transfer: Province mission data passed to interception for tactical setup
- Craft Role Mapping: Weapon combinations determine craft roles (interceptors, artillery, bombers, transports) and interception positioning
- Environmental Data Flow: Province biome influences interception zone availability and modifiers (underwater interception in water biomes)
- Result Propagation: Interception outcomes update geoscape world state and progression
- Deterministic Systems: Seeded randomization ensuring reproducible mission outcomes

## Examples

### Mission Assignment Scenarios
- Standard Interception: Player selects province with UFO mission, assigns fighter craft within 1000km range
- Base Defense: Terror mission near base automatically triggers craft deployment with no range restrictions
- Multi-Craft Operation: Large UFO mission allows assignment of multiple craft with combined interception strength
- Range-Limited Assignment: Distant province mission only shows craft with sufficient range from their bases
- Fuel-Constrained Deployment: Low-fuel craft filtered out, requiring base refueling before assignment

### Range and Movement Cases
- Land Vehicle Routing: Ground transport limited to land tile paths, avoiding water barriers with mountain cost penalties
- Ship Navigation: Naval craft using water tile chains with single coastal province access points
- Air Superiority: Fighter craft ignoring terrain costs, moving with uniform speed across all tile types
- Short-Range Fighter: 500km operational radius, consumes fuel based on tile path cost to target
- Long-Range Interceptor: 2000km operational radius, higher fuel consumption for extended tile paths
- Base-Adjacent Mission: Minimal fuel cost for missions near the craft's home base
- Maximum Range Operation: Craft operating at limit requires careful fuel management planning
- Multi-Mission Day: Speed 5 craft can perform up to 5 missions, requiring fuel reserves planning

### Operational Constraint Examples
- Fuel Shortage: Craft with insufficient fuel cannot accept missions, requiring base resupply
- Range Violation: Distant mission automatically filters out craft without adequate operational radius
- Speed Limit: Fast craft can perform multiple missions daily, slow craft limited to single operations
- Base Capacity: Overloaded bases cannot support additional craft deployments
- Maintenance Requirements: Damaged craft must return to base for repairs before new assignments

### Interception Transition Cases
- Single Craft vs UFO: Fighter engages alien craft in aerial interception combat
- Multi-Craft Formation: Squadron coordinates attack on large alien vessel
- Base Defense Integration: Ground facilities provide supporting fire during interception
- Environmental Effects: Stormy weather reduces interception effectiveness and positioning
- Damage Assessment: Post-combat craft status affects return capability and salvage operations

## Related Wiki Pages

- [Crafts.md](../crafts/Crafts.md) - Craft systems and capabilities.
- [Fuel & Range.md](../crafts/Fuel%20%26%20range.md) - Fuel consumption mechanics.
- [Mission Detection and Assignment.md](../interception/Mission%20Detection%20and%20Assignment.md) - Mission assignment systems.
- [Interception Core Mechanics.md](../interception/Interception%20Core%20Mechanics.md) - Interception transition.
- [Province.md](../geoscape/Province.md) - Province-based operations.
- [Geoscape.md](../geoscape/Geoscape.md) - Strategic layer integration.
- [Basescape.md](../basescape/Basescape.md) - Base operations and maintenance.
- [Monthly reports.md](../finance/Monthly%20reports.md) - Operational reporting.

## References to Existing Games and Mechanics

- **XCOM Series**: Craft deployment and interception mechanics
- **Civilization Series**: Unit movement and operational ranges
- **Europa Universalis**: Naval operations and fleet movement
- **Crusader Kings**: Army movement and logistics
- **Hearts of Iron**: Fleet operations and naval combat
- **Victoria Series**: Naval operations and colonial deployment
- **Stellaris**: Fleet movement and operations
- **Endless Space**: Fleet operations and range management
- **Galactic Civilizations**: Fleet deployment and operations
- **Total War Series**: Army movement and campaign operations

