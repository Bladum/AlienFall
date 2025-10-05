# Land Battle Transitions

## Table of Contents
- [Overview](#overview)
  - [Transition Triggers](#transition-triggers)
  - [State Preservation](#state-preservation)
  - [Battlescape Integration](#battlescape-integration)
- [Mechanics](#mechanics)
  - [Craft-to-Unit Conversion Process](#craft-to-unit-conversion-process)
    - [Personnel Deployment](#personnel-deployment)
    - [Equipment Conversion](#equipment-conversion)
    - [Energy and Resources](#energy-and-resources)
  - [Landing Zone Generation](#landing-zone-generation)
    - [Crash Site Mechanics](#crash-site-mechanics)
    - [Terrain Integration](#terrain-integration)
    - [Enemy Response](#enemy-response)
  - [Mission Objective Translation](#mission-objective-translation)
    - [Air Superiority → Ground Control](#air-superiority---ground-control)
    - [Pursuit → Investigation](#pursuit---investigation)
    - [Base Assault → Facility Capture](#base-assault---facility-capture)
  - [Support and Reinforcement](#support-and-reinforcement)
    - [Craft Support Fire](#craft-support-fire)
    - [Reinforcement Options](#reinforcement-options)
- [Examples](#examples)
  - [Transition Scenarios](#transition-scenarios)
  - [State Preservation Examples](#state-preservation-examples)
  - [Battlescape Setup Examples](#battlescape-setup-examples)
  - [Combat Flow Examples](#combat-flow-examples)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

Land Battle Transitions handle the conversion from interception-based air/space combat to ground-based battlescape operations. This system manages emergency landings, crash sites, and tactical deployments where air engagements continue on the ground, preserving interception state while adapting to battlescape mechanics.

### Transition Triggers
- Critical Damage: Craft systems failure forces emergency landing (hull integrity < 25%)
- Fuel Depletion: Insufficient fuel for return journey requires ground operations
- Mission Requirements: Objectives requiring ground presence (rescue, investigation, base assault)
- Pursuit Scenarios: Damaged enemy craft crash-landing with surviving crew
- Strategic Landings: Intentional deployment for reconnaissance or assault operations
- System Failures: Critical component damage preventing continued flight
- Post-Interception Choice: Transport crafts with unit capacity can choose battlescape deployment
- Base Defense Failure: When base health reaches 0 during interception, transitions to land battle for destruction

### State Preservation
- Interception Carryover: AP, energy, and positioning maintained from interception phase
- Craft Status: Damage and equipment state transferred to battlescape entities
- Mission Context: Objectives and conditions preserved with ground-specific adaptations
- Resource Continuity: Energy pools and ammunition carried over with conversion rules
- Environmental Continuity: Weather, time-of-day, and terrain conditions transfer seamlessly

### Battlescape Integration
- Terrain Mapping: Interception location coordinates translate to battlescape map generation
- Unit Deployment: Craft crew becomes battlescape units with converted equipment
- Environmental Effects: Atmospheric and terrain conditions carry over from interception
- Time Continuity: Seamless transition without time loss or phase separation
- Objective Evolution: Air-based goals translate to ground-based mission requirements

## Mechanics

### Craft-to-Unit Conversion Process

#### Personnel Deployment
- Crew Extraction: All surviving crew automatically become battlescape units
- Status Transfer: Wounds from interception damage carry over as battlescape injuries
- Skill Preservation: Pilot/navigation skills convert to appropriate unit abilities
- Morale Effects: Crash landing imposes -20 morale penalty, successful landing +10 bonus
- Leadership Continuity: Craft commanders become squad leaders with command bonuses

#### Equipment Conversion
- Weapon Systems: Craft weapons convert to personal firearms with reduced ammo capacity
  - Heavy cannon → Assault rifle (50% ammo transfer)
  - Missile launcher → Rocket launcher (25% ammo transfer)
  - Plasma beam → Plasma rifle (75% ammo transfer)
- Armor Carryover: Craft armor rating provides temporary defensive bonuses
- Utility Items: Craft sensors become portable scanners, repair tools become field kits
- Ammunition Redistribution: Craft ammo pools split among deployed units

#### Energy and Resources
- AP Calculation: Remaining craft energy × 2 = initial unit AP pool
- Energy Regeneration: Ground units regenerate 1 AP per turn from craft reserves
- Supply Limits: Units can only carry equipment equivalent to craft's cargo capacity
- Medical Resources: Craft medkits provide healing during deployment phase

### Landing Zone Generation

#### Crash Site Mechanics
- Debris Fields: Wrecked craft creates cover objects and movement obstacles
- Fire Hazards: Burning components create smoke and damage-over-time zones
- Radiation Zones: Damaged power cores create hazardous areas
- Salvage Opportunities: Craft components become recoverable objectives

#### Craft Destruction Crash Sites
- Mission Generation: Craft health reaching 0 triggers automatic crash site mission
- Survivor Recovery: Units aboard may survive with injury chances based on crash severity
- Craft Salvage: Damaged craft can be recovered for partial rebuilding costs
- Time Pressure: Crash sites have time limits before enemy recovery or environmental decay
- Terrain Difficulty: Crash location affects rescue difficulty (urban vs wilderness vs hostile)
- Multiple Objectives: Rescue survivors, recover craft, eliminate threats, secure technology

#### Terrain Integration
- Location Translation: Interception coordinates map to battlescape tiles
- Biome Consistency: Ground terrain matches interception location type
- Weather Carryover: Atmospheric conditions affect visibility and movement
- Time Synchronization: Day/night cycle continues without interruption

#### Enemy Response
- Immediate Contact: Enemy forces within detection range engage immediately
- Delayed Response: Reinforcements arrive based on interception damage assessment
- Defensive Positions: Aliens establish perimeter defense around landing zone
- Automated Defenses: Turrets and security systems activate on detection

### Mission Objective Translation

#### Air Superiority → Ground Control
- Interception Goal: Establish air dominance over target area
- Battlescape Goal: Secure and hold ground positions in target zone
- Success Criteria: Air control maintained + ground objectives completed within time limit

#### Pursuit → Investigation
- Interception Goal: Prevent enemy craft from reaching destination
- Battlescape Goal: Investigate crash site, recover technology, eliminate survivors
- Success Criteria: All enemy units eliminated + key artifacts recovered

#### Base Assault → Facility Capture
- Interception Goal: Disable base aerial defenses and achieve orbital superiority
- Battlescape Goal: Infiltrate and capture/destroy facility objectives
- Success Criteria: Base defenses neutralized + ground control established

### Support and Reinforcement

#### Craft Support Fire
- Overwatch Capability: Operational craft can provide fire support (limited ammo)
- Reconnaissance: Airborne craft extend vision radius for ground units
- Medical Evacuation: Craft can extract wounded units during combat
- Resupply Drops: Additional ammunition and equipment can be air-dropped

#### Reinforcement Options
- Secondary Deployment: Additional craft can deploy backup units
- Extraction Planning: Craft positioned for emergency pickup operations
- Contingency Forces: Pre-positioned ground teams for transition failures
- Base Support: Ground reinforcements from nearby friendly bases

## Examples

### Transition Scenarios
- Damaged Pursuit: UFO damaged in air combat, crash-lands in forest, crew deploys as infantry
- Forced Landing: Skyranger systems fail over hostile territory, emergency landing with wounded crew
- Tactical Insertion: Planned deployment for base assault, units exit craft in formation
- Rescue Operations: Land to recover downed pilot, combat aliens defending crash site
- Interdiction Follow-up: After preventing supply delivery, ground team secures cargo

### State Preservation Examples
- AP Carryover: Craft with 50% energy remaining gives units 50 AP for initial turn
- Energy Transfer: 100 craft energy splits as 40 AP to each of 4 deployed units
- Position Translation: Aerial coordinates (45.2°N, 12.8°W) map to battlescape grid (120, 80)
- Mission Continuity: "Intercept UFO" becomes "Secure crash site and recover technology"

### Battlescape Setup Examples
- Crash Site: Wrecked UFO provides +40% cover, creates fire zones damaging 5 HP/turn
- Landing Zone: Clear field allows standard deployment, +1 AP bonus for first turn
- Hostile Environment: Rough terrain reduces movement by 2 tiles, increases fall damage
- Defended Position: Enemy patrol detects landing, immediate combat engagement

### Combat Flow Examples
- Initial Deployment: Units exit craft, automatic overwatch setup, establish 360° security
- Contact Engagement: Enemy forces arrive turn 2, combat begins with positioning advantage
- Objective Shift: From "shoot down UFO" to "eliminate alien patrol and secure perimeter"
- Extraction Planning: Mission completion requires reaching craft for pickup under fire

## Related Wiki Pages

- [Interception Core Mechanics.md](../interception/Interception%20Core%20Mechanics.md) - Core interception systems
- [Air Battle.md](../interception/Air%20Battle.md) - Air combat mechanics
- [Mission Detection and Assignment.md](../interception/Mission%20Detection%20and%20Assignment.md) - Mission detection
- [Overview.md](../interception/Overview.md) - Interception overview
- [Battlescape.md](../battlescape/Battlescape.md) - Ground combat mechanics
- [Unit actions.md](../battlescape/Unit%20actions.md) - Ground unit actions
- [Mission objectives.md](../battlescape/Mission%20objectives.md) - Mission types and goals
- [Terrain Elevation.md](../battlescape/Terrain%20Elevation.md) - Terrain and positioning

## References to Existing Games and Mechanics

- **XCOM Series**: Crash site missions and ground transitions
- **Command & Conquer**: Vehicle to infantry transitions
- **StarCraft**: Drop ship deployments and crash sites
- **Warcraft III**: Aerial to ground unit transitions
- **Total War Series**: Siege and deployment mechanics
- **Europa Universalis**: Colonial and landing operations
- **Crusader Kings**: Invasion and landing systems
- **Hearts of Iron**: Airborne and amphibious operations
- **Victoria Series**: Colonial warfare and deployments
- **Civilization Series**: Air unit crash and recovery mechanics

