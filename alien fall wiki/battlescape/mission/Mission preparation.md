# Mission Preparation

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Squad Selection and Loadout Configuration](#squad-selection-and-loadout-configuration)
  - [Transport Assignment and Capacity Management](#transport-assignment-and-capacity-management)
  - [Deployment Design and Preview System](#deployment-design-and-preview-system)
  - [Final Inventory Check and Locking](#final-inventory-check-and-locking)
  - [Validation and Error Handling](#validation-and-error-handling)
  - [Flow, Presets and Convenience Features](#flow,-presets-and-convenience-features)
- [Examples](#examples)
  - [Night Reconnaissance Mission](#night-reconnaissance-mission)
  - [Capture Operation Setup](#capture-operation-setup)
  - [Large Assault Force Deployment](#large-assault-force-deployment)
  - [Rescue Mission Preparation](#rescue-mission-preparation)
  - [Infiltration Team Setup](#infiltration-team-setup)
  - [Interception Transition Preparation](#interception-transition-preparation)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

Mission Preparation is the deterministic pre-battle stage where players select squads, assign equipment, and configure transports with guaranteed reproducible loadouts for the Battlescape. Designers author validation rules, capacity limits, and presets in data for clear UI guidance and invalid configuration prevention. Finalized loadouts are locked and persisted with comprehensive logging for telemetry and replay. The system ensures exact mission payloads are auditable and consistent across playthroughs, with a single linear flow allowing iteration without losing reservations.

## Mechanics

### Squad Selection and Loadout Configuration
- Soldier Roster: Selection from available personnel with status and capability filtering
- Inventory Assignment: Primary, secondary, armor, and consumable equipment configuration using base loadout UX
- Loadout Persistence: Only selected soldiers and their assigned equipment deploy to mission
- Base Integration: Equipment drawn from current base inventory and reserves
- Validation Checks: Real-time feedback on configuration validity and constraints
- Preset System: Saved loadout configurations for quick deployment preparation

### Transport Assignment and Capacity Management
- Craft Allocation: Units assigned to transports or deployment slots with capacity limits
- Equipment Transport: Items travel with assigned soldiers; unassigned items remain at base
- Capacity Validation: Weight, slot, and item compatibility checks with overflow detection
- Multi-Transport Support: Squad division across multiple vehicles when available
- Load Distribution: Balanced capacity utilization with clear UI feedback
- Craft Compatibility: Equipment and unit type restrictions based on transport type

### Deployment Design and Preview System
- Mission Metadata: Objectives, biome, time-of-day, and battle size information display
- Deployment Preview: Minimap visualization of initial positioning and zone options
- Position Adjustment: Unit reordering, starting position selection within deployment blocks
- Zone Selection: Alternative placement areas (left/center/right, high ground, cover positions)
- Multi-Block Support: Group assignment to different deployment blocks when available
- Seeded Previews: Deterministic visualization for reproducible playtesting

### Final Inventory Check and Locking
- Last-Minute Edits: Constrained item swaps between selected soldiers within base inventory limits
- Constraint Enforcement: Craft and mission requirements maintained during edits
- Inventory Confirmation: Final review before deployment lock-in
- State Persistence: Complete loadout freeze for mission execution
- Audit Trail: Comprehensive logging of all preparation choices for telemetry and replay

### Validation and Error Handling
- Deterministic Checks: Reproducible validation with clear error messaging and corrective suggestions
- Corrective Suggestions: Specific guidance for resolving configuration issues (unequip items, move soldiers, etc.)
- Reservation Preservation: Configuration maintained during navigation and iteration
- Mission Requirements: Special equipment or capability validation (stun weapons, tools, faction restrictions)
- Flow Continuity: Seamless iteration without losing selections or reservations

### Flow, Presets and Convenience Features
- Linear Preparation Flow: Single integrated flow combining preparation, transport assignment, and deployment preview
- Back/Forward Navigation: Ability to iterate through steps without losing reservations
- Loadout Presets: Saved configurations for quick setup and consistency
- Deployment Presets: Predefined positioning and zone assignments
- Late Swaps: Transfer active soldier inventory back to base for equipment changes
- Data-Driven Complexity: Configurable options for single vs multiple deployment blocks

## Examples

### Night Reconnaissance Mission
- Squad Composition: 4 soldiers with night operations specialization
- Equipment Loadout: Night-vision goggles, silenced weapons, stealth armor
- Transport Assignment: Single small transport with capacity for 4 personnel
- Deployment Preview: Night biome visualization with left-flank zone selection
- Validation: Night-vision equipment requirement confirmation and silenced weapon compatibility

### Capture Operation Setup
- Mission Requirements: Stun weapon capability for prisoner acquisition
- Loadout Adjustment: One trooper equipped with stun gun from base inventory
- Validation Warning: Initial preparation flags missing stun capability with corrective suggestions
- Final Confirmation: Inventory lock after stun weapon assignment
- Deployment Lock: Loadouts frozen for mission execution with full audit trail

### Large Assault Force Deployment
- Squad Division: Heavy weapons team and scout team separation
- Transport Assignment: Heavy squad to armored transport, scouts to fast drop craft
- Equipment Distribution: Heavy weapons and armor to first transport, light gear to scouts
- Deployment Zones: Heavy squad on center high ground, scouts on left flank
- Capacity Management: Balanced load distribution across vehicles with overflow prevention

### Rescue Mission Preparation
- Special Requirements: Medical equipment for casualty evacuation
- Soldier Selection: Include medic specialist in squad composition
- Equipment Check: Medkits and stabilization tools assigned to medic
- Transport Configuration: Ambulance vehicle with medical bay capacity
- Validation: Medical capability confirmation and equipment compatibility checks

### Infiltration Team Setup
- Stealth Focus: Squad optimized for low-profile insertion
- Equipment Loadout: Suppressed weapons, camouflage gear, lockpicks
- Transport Choice: Quiet insertion craft with minimal signature
- Deployment Planning: Cover-based positioning in deployment preview
- Validation: Stealth equipment compatibility and capacity checks

### Interception Transition Preparation
- Craft Crew Deployment: Automatic crew selection from damaged craft with status carryover
- Equipment Transfer: Craft weapons convert to personal equipment, ammo redistributes to magazines
- Wound Assessment: Injured crew receive medical attention and status modifiers
- Energy Redistribution: Craft energy pools convert to unit action points with landing penalties
- Landing Zone Selection: Deployment preview shows crash site hazards and defensive positions
- Support Craft Assignment: Remaining operational craft provide overwatch and fire support
- Contingency Planning: Backup ground teams configured for interception failure scenarios
- Resource Continuity: Fuel and supplies carried over with consumption tracking

## Related Wiki Pages

- [Mission objectives.md](../battlescape/Mission%20objectives.md) - Objectives for preparation.
- [Geoscape.md](../geoscape/Geoscape.md) - Strategic preparation.
- [Base management.md](../basescape/Base%20management.md) - Base prep.
- [Craft.md](../crafts/Craft.md) - Craft preparation.
- [Units.md](../units/Units.md) - Unit selection.
- [Inventory.md](../items/Inventory.md) - Equipment prep.
- [Research.md](../economy/Research.md) - Tech for missions.
- [Interception.md](../interception/Overview.md) - Interception prep.
- [Squad Autopromotion.md](../battlescape/Squad%20Autopromotion.md) - Squad building.
- [Mission salvage.md](../battlescape/Mission%20salvage.md) - Salvage planning.

## References to Existing Games and Mechanics

- X-COM series: Mission preparation and loadout.
- Commandos series: Planning and team selection.
- Fire Emblem series: Pre-battle preparations.
- Advance Wars: Unit deployment and prep.
- Civilization series: Army composition.
- Dungeons & Dragons: Party preparation.
- Total War series: Army setup.
- Rainbow Six Siege: Operator selection and loadout.

