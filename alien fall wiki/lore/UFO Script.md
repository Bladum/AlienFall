# UFO Script

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Script Templates](#script-templates)
  - [Status States](#status-states)
  - [Primitive Actions](#primitive-actions)
  - [Branching Logic](#branching-logic)
  - [Detection Integration](#detection-integration)
  - [Dogfight Resolution](#dogfight-resolution)
  - [Mission Spawning](#mission-spawning)
  - [Strategic Actions](#strategic-actions)
  - [Provenance Tracking](#provenance-tracking)
- [Examples](#examples)
  - [Basic Scout Mission](#basic-scout-mission)
  - [Abduction Operation](#abduction-operation)
  - [Base Construction](#base-construction)
  - [Stealth Infiltration](#stealth-infiltration)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The UFO Script System provides a comprehensive framework for controlling alien UFO behavior through data-driven scripts. This system enables complex, emergent gameplay by defining UFO missions as sequences of atomic actions with conditional branching based on player interactions. The system emphasizes deterministic outcomes through seeded random number generation, ensuring reproducible behavior for debugging and balance purposes.

Key design principles include:
- Data-Driven Design: All UFO behaviors defined through configuration files
- Deterministic Execution: Seeded RNG ensures consistent outcomes
- Modular Architecture: Pluggable primitive actions and template-based composition
- Provenance Tracking: Complete audit trail for debugging and telemetry
- Performance Optimization: Efficient processing for multiple concurrent scripts

## Mechanics

### Script Templates
Script templates define the high-level structure and behavior patterns for UFO missions. Each template specifies a sequence of steps, initial conditions, and branching logic for handling player interactions.

Template Structure:
- Unique identifier and descriptive name
- Associated faction affiliation
- Initial status state
- Ordered sequence of primitive actions
- Conditional branches for detection and interception events
- Configuration parameters for timing and behavior modifiers

Template Categories:
- Scout Missions: Reconnaissance and surveillance operations
- Abduction Missions: Civilian collection and resource harvesting
- Bombardment Missions: Strategic strikes against player assets
- Base Construction: Establishing forward operating bases
- Infiltration Missions: Stealth operations and intelligence gathering
- Research Missions: Technology acquisition and analysis

### Status States
UFO status determines available actions, detection probability, and behavioral patterns. Status transitions occur through script execution or external events.

Flying Status:
- High mobility with province-to-province movement
- Moderate detection risk based on altitude and speed
- Limited interaction capabilities while airborne
- Primary state for transit and reconnaissance

Landed Status:
- Stationary position in specific province
- High detection risk due to ground presence
- Enables mission spawning and ground operations
- Vulnerable to interception and ground attacks

Crashed Status:
- Immobile due to damage or forced landing
- Maximum detection probability
- Salvage opportunities for player recovery
- Mission failure state requiring rescue operations

Base Status:
- Established alien facility in province
- Permanent presence with defensive capabilities
- Resource generation and strategic positioning
- High-value target for player operations

Underwater Status:
- Submerged operations in coastal provinces
- Reduced detection probability
- Specialized mission capabilities
- Requires specific interception methods

### Primitive Actions
Primitive actions represent atomic operations that UFOs can perform. Each primitive has specific parameters, timing controls, and success conditions.

Movement Primitives:
- MoveToProvince: Relocate to target province with travel time calculation
- PatrolAir: Circular patrol pattern within current province airspace
- LandAndStay: Descend to ground and maintain position
- EvadeAbort: Emergency escape with random direction selection

Detection Primitives:
- ScanForPlayer: Active radar sweep for player detection
- ChangeStatus: Modify UFO status state with duration parameters
- ElectronicWarfare: Deploy jamming or cloaking countermeasures

Mission Primitives:
- SpawnMissionHere: Generate tactical mission at current location
- BombardProvince: Strategic strike against province targets
- HarvestResources: Extract resources from landed position
- ConstructBase: Establish alien facility infrastructure

Strategic Primitives:
- CloneSelf: Create duplicate UFO with shared script state
- DeployDecoy: Generate false targets for interception confusion
- PhaseShift: Temporary invulnerability through advanced technology
- NeuralHack: Attempt remote compromise of player systems

### Branching Logic
Branching logic enables dynamic script adaptation based on player actions and external events. Branches trigger alternative execution paths when specific conditions are met.

Detection Branch:
- Activates when UFO is detected by player sensors
- Enables evasive maneuvers or aggressive responses
- May include suicide attacks or decoy deployment
- Can return to main script or abort mission entirely

Interception Branch:
- Triggers during active interception attempts
- Allows defensive countermeasures and escape actions
- May spawn additional threats or change mission objectives
- Supports return to main execution flow

Damage Branch:
- Activates based on accumulated damage thresholds
- Enables emergency behaviors like forced landing or self-destruction
- May trigger rescue missions or base construction attempts
- Supports progressive degradation of capabilities

Time Branch:
- Conditional execution based on mission duration
- Enables escalation or de-escalation of activities
- Supports dynamic difficulty adjustment
- May trigger mission completion or extension

### Detection Integration
The script system integrates deeply with the detection mechanics, using shared seeded random generation for consistent outcomes across different systems.

Detection States:
- Undetected: Normal operation with base detection probabilities
- Detected: Increased visibility with active tracking
- Tracked: Continuous monitoring with interception opportunities
- Intercepted: Active engagement with dogfight resolution

Detection Modifiers:
- Status-based detection probability adjustments
- Province-specific terrain and population modifiers
- Technology level influences on sensor effectiveness
- Weather and time-of-day detection variations

### Dogfight Resolution
Dogfight outcomes directly influence script execution, with results feeding back into the branching logic and primitive execution.

Dogfight Outcomes:
- Destroyed: UFO eliminated with crash site generation
- Forced Landing: Damaged UFO grounded for salvage opportunities
- Escaped: UFO evades interception and resumes script
- Damaged: Partial damage with status degradation

Resolution Integration:
- Damage thresholds trigger specific branch conditions
- Status changes affect subsequent primitive execution
- Mission objectives may be modified based on engagement results
- Provenance tracking captures all resolution details

### Mission Spawning
UFO scripts can generate tactical missions as part of their primitive actions, creating dynamic content based on script context and player progress.

Mission Types:
- Abduction Sites: Civilian rescue and alien combat
- Crash Sites: Salvage recovery and alien survivor encounters
- Landing Sites: Active alien operations with time pressure
- Terror Missions: Urban combat with civilian protection requirements
- Base Defense: Facility assault with strategic objectives

Spawn Parameters:
- Location tied to current UFO position
- Difficulty scaling based on script progression
- Resource rewards and research opportunities
- Time limits and failure consequences

### Strategic Actions
Advanced primitives enable complex strategic behaviors that influence campaign progression and player resource management.

Resource Operations:
- Territory control and resource extraction
- Supply line establishment and maintenance
- Economic disruption through targeted strikes
- Technology acquisition and reverse engineering

Base Development:
- Forward operating base construction
- Defensive network establishment
- Research facility deployment
- Strategic positioning for campaign advantage

Psychological Operations:
- Terror attacks for morale reduction
- Propaganda campaigns for faction influence
- Intelligence gathering for strategic planning
- Deception operations with decoy deployments

### Provenance Tracking
Complete audit trail system for debugging, telemetry, and player analysis of UFO behaviors and mission outcomes.

Tracking Categories:
- Execution Events: Primitive action completion and failures
- Branch Triggers: Conditional logic activation with context
- Status Changes: State transitions with timing and causes
- Detection Events: Sensor interactions and interception attempts
- Mission Outcomes: Tactical engagement results and consequences

Analysis Capabilities:
- Script execution flow reconstruction
- Performance bottleneck identification
- Balance issue detection through pattern analysis
- Player behavior correlation with UFO responses

## Examples

### Basic Scout Mission
Template: scout_patrol
- Initial Status: Flying
- Steps:
  1. PatrolAir (delay: 2 days)
  2. ScanForPlayer (delay: 1 day)
  3. HuntForCrafts (delay: 3 days)
  4. EvadeAbort (delay: 1 day)
- Detection Branch: Evade to adjacent province
- Interception Branch: Deploy decoys and escape

Expected Behavior: UFO performs reconnaissance pattern, maintaining distance from player assets while gathering intelligence.

### Abduction Operation
Template: abduction_mission
- Initial Status: Flying
- Steps:
  1. MoveToProvince (delay: 1 day)
  2. LandAndStay (delay: 2 days)
  3. SpawnMissionHere (delay: 0 days)
  4. WaitIdle (delay: 3 days)
- Detection Branch: Abort mission and escape
- Interception Branch: Fight or flee based on damage

Expected Behavior: Coordinated operation with ground team extraction and air support.

### Base Construction
Template: base_establishment
- Initial Status: Flying
- Steps:
  1. MoveToProvince (delay: 1 day)
  2. LandAndFortify (delay: 2 days)
  3. BuildForwardBase (delay: 10 days, repeated)
  4. GenerateNewMissionSite (delay: 0 days)
- Detection Branch: Suicide attack to delay player response
- Interception Branch: Accelerated construction with reduced capabilities

Expected Behavior: Long-term strategic investment requiring protection during vulnerable construction phase.

### Stealth Infiltration
Template: stealth_infiltrator
- Initial Status: Flying
- Steps:
  1. PatrolAir with cloak (delay: 2 days)
  2. Precision scan (delay: 1 day)
  3. Surgical strike mission (delay: 0 days)
  4. Stealth extraction (delay: 1 day)
- Detection Branch: EMP suicide attack
- Interception Branch: Deploy decoys and retreat

Expected Behavior: High-risk, high-reward operation with advanced technology countermeasures.

## Related Wiki Pages

- [Mission.md](../lore/Mission.md) - UFO mission spawning and objectives
- [Faction.md](../lore/Faction.md) - UFO faction behavior and ownership
- [Campaign.md](../lore/Campaign.md) - UFO campaign integration
- [Geoscape.md](../geoscape/Geoscape.md) - UFO geoscape movement and detection
- [Interception.md](../interception/Interception.md) - UFO interception mechanics
- [Crafts.md](../crafts/Crafts.md) - Craft vs UFO combat systems
- [Enemy Base script.md](../lore/Enemy%20Base%20script.md) - Base UFO support and construction
- [Calendar.md](../lore/Calendar.md) - UFO activity timing and cycles

## References to Existing Games and Mechanics

- **XCOM Series**: UFO interception and dogfight combat
- **Independence Day**: Alien invasion UFO encounters
- **Men in Black**: Alien craft pursuit and capture
- **Starship Troopers**: Bug mothership and drop ship combat
- **2001: A Space Odyssey**: Mysterious alien monolith encounters
- **Close Encounters of the Third Kind**: Peaceful UFO contact scenarios
- **E.T. the Extra-Terrestrial**: Benevolent alien visitation
- **Contact**: Alien signal detection and communication
- **District 9**: Alien spacecraft technology and salvage
- **Arrival**: Alien communication and understanding

