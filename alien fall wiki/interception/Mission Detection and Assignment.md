# Mission Detection and Assignment

## Table of Contents
- [Overview](#overview)
  - [Geoscape Integration Points](#geoscape-integration-points)
- [Mechanics](#mechanics)
  - [Detection Sources](#detection-sources)
  - [Cover System](#cover-system)
  - [Mathematics](#mathematics)
  - [Mission-Side Scanning](#mission-side-scanning)
  - [Craft Eligibility](#craft-eligibility)
  - [Order Processing](#order-processing)
  - [Priority System](#priority-system)
  - [Fuel Economics](#fuel-economics)
  - [Multi-Phase Operations](#multi-phase-operations)
- [Examples](#examples)
  - [Detection Scenarios](#detection-scenarios)
  - [Assignment Cases](#assignment-cases)
  - [Priority Examples](#priority-examples)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

This system governs the discovery of hidden missions through intelligence sources and the strategic dispatching of craft to engage detected targets. It combines detection mechanics with interception logistics to create a seamless flow from reconnaissance to active engagement, bridging geoscape strategic positioning with interception tactical resolution.

Missions must be detected through radar coverage mechanisms before players can see them on the geoscape. Starting the interception screen is also a method to detect missions in a province.

### Geoscape Integration Points
- Province-Based Detection: All detection occurs within geoscape provinces using spatial coordinates
- Base Facilities: Stationary detection sources tied to geoscape base locations with radar coverage
- Airborne Craft: Mobile detection platforms operating from geoscape bases
- Mission Hosting: Detected missions are attached to specific provinces for strategic deployment
- Range Calculations: Detection ranges and craft operational limits use geoscape distance metrics
- Interception Screen: Starting interception automatically detects missions in the province

## Mechanics

### Detection Sources
- Base Facilities: Stationary installations providing province-wide radar coverage
- Airborne Craft: Mobile platforms with flight-dependent scanning
- Range Calculation: Kilometer-based measurements using globe tile map path distances between provinces
- Daily Attempts: Single detection pass per source per mission per day
- Interception Screen: Automatic detection when starting interception in a province
- Visibility Requirement: Missions only visible on geoscape after detection

### Cover System
- Mission Concealment: Missions hidden until Cover reduced to ≤0
- Armor Effects: Reduces detection effectiveness (0 = full, 1 = immune)
- Recovery Mechanics: Missions regain Cover when undetected
- Additive Stacking: Multiple sources combine Cover reduction
- Sensor Specialization: Underwater, underground, portal-linked detection

### Mathematics
- Power Application: Cover reduction = DetectionPower × (1 - Armor)
- Stacking Rules: Sources combine within same day
- Compatibility: Sensor tags match mission types
- Deterministic Outcomes: Seeded random elements

### Mission-Side Scanning
- Equivalent Mechanics: Missions detect other missions using same math
- Province-Local: Scanning occurs when occupying provinces
- Additive Effects: Combines with player detection sources

### Craft Eligibility
- Capability Requirements: AIR, LAND, WATER, underground compatibility
- Offensive Capability: Weapons or addons required for combat
- Range Validation: Within operational limits based on globe tile map path distances and craft movement restrictions
- Fuel Availability: Sufficient reserves for transit and engagement
- Status Checks: Unassigned and available craft only

### Order Processing
- Intercept Orders: Direct engagement of detected missions
- Travel-to Orders: Movement to provinces without combat
- Move-to Orders: Relocation between bases
- Transit Reservation: Craft unavailable during movement/engagement

### Priority System
- Numeric Priorities: Higher values auto-selected
- Explicit Targeting: Player override bypasses priority
- Escort Protection: High-priority missions blocked by escorts
- Queue Management: Deterministic assignment logic

### Fuel Economics
- Distance Calculation: Globe tile map path distances converted to kilometers using tile size (500km per tile for Earth)
- Consumption: Immediate fuel deduction upon order based on tile path cost
- Range Limits: Fuel constrains operational radius based on craft movement type and terrain costs
- Speed Budget: Daily movement allocation limits based on tile traversal costs

### Multi-Phase Operations
- Air-to-Ground: Successful air engagement enables land phase
- Capability Continuity: Fuel and abilities carry over
- Seamless Handoff: Automatic transition when conditions met

## Examples

### Detection Scenarios
- Base Coverage: Short-range radar (120 power) reduces Cover by 120
- Stacked Detection: Base (120) + airborne scout (25) = 145 reduction
- Armor Mitigation: 100 power vs 0.5 armor = 50 effective reduction
- Recovery Prevention: Cover held ≤0 prevents +10/day recovery

### Assignment Cases
- Full-Capability Craft: AIR+LAND+WATER eligible for all mission types
- Air Superiority: AIR-only for UFO interception only
- Ground Transport: LAND-only for site missions
- Fuel-Constrained: 300km mission blocked by 200 fuel available

### Priority Examples
- High-Priority UFO: Priority 100 auto-selected
- Escort-Blocked: High-priority target protected by escorts
- Player Override: Explicit selection bypasses priority system

## Related Wiki Pages

- [Interception Core Mechanics.md](../interception/Interception%20Core%20Mechanics.md) - Core interception systems.
- [Overview.md](../interception/Overview.md) - Interception overview.
- [Air Battle.md](../interception/Air%20Battle.md) - Air combat mechanics.
- [Base Defense and Bombardment.md](../interception/Base%20Defense%20and%20Bombardment.md) - Base defense systems.
- [Geoscape.md](../geoscape/Geoscape.md) - Strategic layer integration.
- [World.md](../geoscape/World.md) - Geographic mission locations.
- [Crafts.md](../crafts/Crafts.md) - Craft detection and assignment.
- [Fuel & Range.md](../crafts/Fuel%20%26%20range.md) - Fuel economics.

## References to Existing Games and Mechanics

- **XCOM Series**: Mission detection and interception assignment
- **Civilization Series**: City and unit detection mechanics
- **Total War Series**: Campaign detection and army movement
- **Europa Universalis**: Province-based detection systems
- **Crusader Kings**: Intrigue and discovery mechanics
- **Hearts of Iron**: Intelligence and reconnaissance systems
- **Victoria Series**: Diplomatic and exploration detection
- **Stellaris**: Sensor arrays and detection ranges
- **Endless Space**: Strategic detection and exploration
- **Galactic Civilizations**: Intelligence and scanning mechanics

