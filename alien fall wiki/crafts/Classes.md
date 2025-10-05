# Craft Classes

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Class Definition Structure](#class-definition-structure)
  - [Base Statistics Framework](#base-statistics-framework)
  - [Capability Classification](#capability-classification)
  - [Unit Size Categories](#unit-size-categories)
  - [Terrain Navigation and Movement](#terrain-navigation-and-movement)
  - [Economic Attributes](#economic-attributes)
  - [Acquisition and Unlocking](#acquisition-and-unlocking)
  - [Experience and Veterancy](#experience-and-veterancy)
  - [Multi-Role Capabilities](#multi-role-capabilities)
  - [Upgrade and Retrofit Systems](#upgrade-and-retrofit-systems)
  - [Specialization System](#specialization-system)
  - [Mission Integration](#mission-integration)
  - [Attributes and Modding](#attributes-and-modding)
  - [Testing and Balance](#testing-and-balance)
- [Examples](#examples)
  - [Interceptor Class](#interceptor-class)
  - [Multi-Role Transport](#multi-role-transport)
  - [Stealth Interceptor](#stealth-interceptor)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

Craft classes define the fundamental chassis types available to players in Alien Fall, serving as the core abstraction that connects strategic logistics, tactical combat performance, and economic planning. Each class represents a distinct vehicle type with canonical base statistics, equipment constraints, and operational capabilities that shape how players approach both geoscape operations and battlescape engagements.

The class system enables diverse strategic roles while maintaining data-driven consistency across all game systems. Classes establish the foundation for player progression, from initial interceptor acquisitions through advanced multi-role craft capable of complex mission sequences. This design supports extensive modding while ensuring balanced economic and tactical trade-offs.

Key design principles include clear separation between hardware capabilities and pilot skills, explicit upgrade paths, and comprehensive mission sequencing support. Classes serve as tuning points for campaign pacing, with research prerequisites and construction costs creating meaningful player choices throughout the game.

## Mechanics

### Class Definition Structure

Craft classes are defined through structured data configurations that specify all fundamental attributes and behavioral rules. Each class includes:

- Identification: Unique name, description, and categorization tags
- Base Statistics: Core performance attributes that define operational capabilities
- Equipment Constraints: Weapon, addon, and cargo slot limitations
- Capability Flags: Mission type compatibility (AIR, LAND, WATER, PORTAL)
- Economic Parameters: Construction costs, maintenance requirements, and build times
- Progression Rules: Veterancy thresholds, upgrade paths, and specialization options

### Base Statistics Framework

Each craft class establishes baseline performance through comprehensive statistical attributes:

- Speed: Movement rate affecting interception response times and geoscape positioning
- Range: Operational radius determining mission availability and deployment options
- Hull: Structural integrity providing damage resistance in combat
- Fuel Capacity: Energy reserves limiting mission duration and requiring base refueling
- Unit Capacity: Craft capacity (e.g. 8) with units having individual sizes (e.g. 1, 2, 4) - inventory contents don't affect capacity
- Weapon Slots: Hardpoints for offensive armament installation
- Addon Slots: Mounting points for support equipment and modifications
- Item Cargo: Storage capacity for mission equipment and salvage recovery
- Radar Range/Power: Detection capabilities for UFO tracking and interception
- Stealth Modifier: Detection reduction affecting concealment effectiveness
- Energy Pool/Recharge: Power reserves for advanced systems and special abilities

### Capability Classification

Classes are categorized by operational environments and weapon combinations they can support:

- AIR-to-AIR: Interceptors/fighters specialized for aerial dogfights against UFOs
- LAND-to-LAND: Artillery craft for ground bombardment and support
- AIR-to-LAND: Bombers for ground attack missions
- Unit Capacity: Transports with capacity limits (e.g. 8) where units have sizes (1, 2, 4) - equipment carried by units doesn't count toward capacity

### Unit Size Categories

Standardized unit sizes for craft capacity calculations:

- Size 1 Units: Light infantry, scouts, snipers (e.g., Rifleman, Scout)
- Size 2 Units: Standard soldiers, medics, engineers (e.g., Assault Trooper, Medic)  
- Size 3 Units: Heavy weapons, specialists (e.g., Heavy Gunner, Psi Operative)
- Size 4 Units: Elite units, heavy armor (e.g., MEC Trooper, Cyberdisc)

### Capacity Examples

Different craft classes with varying capacities:

- Light Transport: Capacity 6 (fits 6 Size 1, or 3 Size 2, or 1 Size 4 + 2 Size 1, etc.)
- Medium Transport: Capacity 8 (fits 8 Size 1, or 4 Size 2, or 2 Size 4, etc.)
- Heavy Transport: Capacity 12 (fits 12 Size 1, or 6 Size 2, or 3 Size 4, etc.)
- WATER: Aquatic craft for underwater interception in water biomes
- UNDERWATER: Submersible craft for deep water operations

Multi-capable classes enable mission sequencing where a single craft can participate in multiple phases of the same operation. Weapon combinations determine tactical roles and mission eligibility.

### Terrain Navigation and Movement

Craft movement governed by globe tile map pathfinding:

- Land Vehicles: Restricted to land tiles only (costs 1-4), cannot traverse water, pathfinding around bodies of water
- Ships: Navigate water tiles exclusively (cost 1), access limited to one coastal province per water province
- Airplanes: Uniform movement cost (1) across all tile types, ignoring terrain restrictions
- Instant Travel: All province-to-province movement occurs instantly within single turns
- Isolation Mechanics: No encounters with missions or other crafts during transit
- Range Calculation: Operational ranges determined by tile map path distances between provinces

### Economic Attributes

Class economics balance accessibility with strategic value:

- Construction Cost: Initial acquisition expense in credits
- Maintenance Cost: Ongoing operational expenses per month
- Build Time: Production duration requiring workshop facilities
- Workshop Requirements: Facility level prerequisites for construction
- Fuel Consumption: Resource burn rates during missions and transit

### Acquisition and Unlocking

Classes become available through structured progression systems:

- Research Prerequisites: Technology requirements unlocking advanced chassis
- Supplier Contacts: External acquisition options for specialized craft
- Campaign Milestones: Story-driven unlocks for narrative-critical classes
- Base Facilities: Infrastructure requirements for local production

### Experience and Veterancy

Progression systems enhance craft effectiveness over time:

- Pilot-Centric Model: Primary experience carrier with transferable skills
- Craft-Level Veterancy: Chassis-specific improvements through service
- Rank Thresholds: Experience milestones unlocking performance bonuses
- Skill Categories: Accuracy, evasion, reaction time, and targeting improvements

### Multi-Role Capabilities

Advanced classes support complex mission sequences:

- Sequential Operations: Air battle followed by ground assault in single missions
- Capability Transitions: Seamless movement between operational environments
- Resource Management: Fuel and ammunition tracking across mission phases
- Salvage Integration: Automatic base delivery of recovered materials

### Upgrade and Retrofit Systems

Explicit improvement mechanics modify existing craft:

- Retrofit Packages: Data-driven modification templates with costs and effects
- Performance Enhancements: Bounded improvements to speed, armor, or capabilities
- Equipment Integration: New hardpoint additions or capacity modifications
- Downtime Requirements: Service periods for modification completion

### Specialization System

Role-specific adaptations create tactical variants:

- Interceptor Focus: Enhanced dogfighting with speed and maneuverability bonuses
- Bomber Configuration: Increased payload capacity and armor for strike missions
- Stealth Variants: Detection reduction and precision capabilities
- Heavy Lift: Enhanced cargo capacity for logistics operations

### Mission Integration

Classes integrate deeply with operational systems:

- Post-Mission Processing: Automatic damage assessment, resource consumption, and experience awards
- Immediate Redeployment: Fuel-threshold based continued operations
- Loadout Validation: Equipment compatibility and mission requirement checking
- Status Updates: Condition monitoring and sortie count tracking

### Attributes and Modding

TOML-based configuration enables extensive customization:

- Class Definitions: Complete chassis specifications in structured format
- Modding Capabilities: Custom designs with unique statistics and requirements
- Balance Parameters: Tunable cost and performance values
- Compatibility Rules: Enhancement combination restrictions

### Testing and Balance

Comprehensive validation ensures system integrity:

- Unit Testing: Configuration loading and mechanic validation
- Integration Testing: Full lifecycle simulation and mission sequences
- Balance Analysis: Performance metrics and cost-effectiveness evaluation
- Preview Systems: Before-and-after effect visualization and synergy assessment

## Examples

### Interceptor Class
A lightweight, high-speed chassis optimized for aerial superiority:
- Base Stats: Speed 120, Hull 30, Weapon Slots 2, Fuel Capacity 100
- Capabilities: AIR primary, limited LAND support
- Economic: Cost 150 credits, Maintenance 20/month
- Progression: Pilot ranks grant +5% accuracy and +3% evasion bonuses

### Multi-Role Transport
Heavy-lift craft capable of complex operations:
- Base Stats: Speed 80, Hull 80, Unit Capacity 8, Item Cargo 50
- Capabilities: AIR/LAND sequencing for insertion then ground support
- Unit Size System: Units occupy capacity slots (size 1, 2, or 4) regardless of equipment
- Specialization: Can retrofit for WATER operations with amphibious packages
- Economic: High maintenance costs offset by versatile mission support

### Stealth Interceptor
Advanced reconnaissance platform:
- Base Stats: Speed 100, Stealth -30%, Radar Range 150
- Capabilities: AIR with enhanced detection capabilities
- Specialization: Precision strike modifications for high-value targets
- Progression: Veterancy focuses on targeting accuracy and evasion

## Related Wiki Pages

- [Craft Stats.md](../crafts/Craft%20Stats.md) - Base statistics and performance attributes.
- [Craft Items.md](../crafts/Craft%20Items.md) - Equipment compatibility and loadout options.
- [Craft Operations.md](../geoscape/Craft%20Operations.md) - Mission capabilities and deployment.
- [Research.md](../basescape/Research.md) - Class unlocking and technology requirements.
- [Manufacturing.md](../economy/Manufacturing.md) - Class production and construction.
- [Suppliers.md](../economy/Suppliers.md) - Class procurement and acquisition.
- [Finance.md](../finance/Finance.md) - Class costs and maintenance expenses.
- [Technical Architecture.md](../architecture.md) - Class data structures and systems.
- [Interception.md](../interception/Overview.md) - Combat role specialization.
- [Geoscape.md](../geoscape/Geoscape.md) - Strategic deployment capabilities.

## References to Existing Games and Mechanics

- **XCOM Series**: Craft types and strategic roles in alien defense
- **Master of Orion**: Ship classes and technological progression
- **Homeworld**: Ship classes and fleet composition mechanics
- **Freespace**: Ship classes and mission role specialization
- **Wing Commander**: Fighter classes and squadron composition
- **Star Control**: Ship classes and equipment specialization
- **Elite**: Ship types and equipment loadout systems
- **X3: Reunion**: Ship classes and economic specialization
- **Civilization**: Unit classes and upgrade progression
- **MechWarrior**: Mech classes and weight-based categorization

