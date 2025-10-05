# Interception Core Mechanics

## Table of Contents
- [Overview](#overview)
  - [Geoscape to Interception Flow](#geoscape-to-interception-flow)
- [Mechanics](#mechanics)
  - [Screen Layout and Positioning](#screen-layout-and-positioning)
    - [Grid Structure](#grid-structure)
    - [Capacity Rules](#capacity-rules)
    - [Environmental Zones](#environmental-zones)
    - [Positioning Rules](#positioning-rules)
  - [Action Points (AP) and Energy System](#action-points-ap-and-energy-system)
    - [Action Points](#action-points)
    - [Energy Pool Management](#energy-pool-management)
    - [Resource Categories](#resource-categories)
    - [Depletion Effects](#depletion-effects)
  - [Weapon Mechanics](#weapon-mechanics)
    - [Craft Items (Weapons)](#craft-items-weapons)
    - [Firing System](#firing-system)
    - [Travel and Range](#travel-and-range)
    - [Targeting Restrictions](#targeting-restrictions)
    - [Cooldown System](#cooldown-system)
    - [Craft Types by Weapon Combinations](#craft-types-by-weapon-combinations)
    - [Underwater Interception](#underwater-interception)
  - [Mission Types](#mission-types)
    - [Air Battle](#air-battle)
    - [Base Defense](#base-defense)
    - [Base Bombardment](#base-bombardment)
    - [Enemy Base Assault](#enemy-base-assault)
    - [Site Landing (No Air Battle)](#site-landing-no-air-battle)
    - [Land Battle Transitions](#land-battle-transitions)
    - [Underwater Battle](#underwater-battle)
    - [Multiple Missions and Ambush](#multiple-missions-and-ambush)
    - [Retreat and Post-Interception](#retreat-and-post-interception)
  - [Deterministic Framework](#deterministic-framework)
    - [Seeded Randomness](#seeded-randomness)
    - [Data-Driven Design](#data-driven-design)
    - [Provenance Logging](#provenance-logging)
- [Examples](#examples)
  - [Positioning Cases](#positioning-cases)
  - [Energy Scenarios](#energy-scenarios)
  - [Weapon Applications](#weapon-applications)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Interception Core Mechanics system provides the fundamental framework for space/air combat engagements in Alien Fall. It manages the interception screen layout, energy resource management, weapon targeting, and mission resolution for craft-based tactical combat. The system creates strategic positioning decisions, resource allocation trade-offs, and deterministic combat outcomes that bridge geoscape strategy with potential battlescape transitions.

### Geoscape to Interception Flow

On the geoscape, the player selects a province containing their own base. They then select a craft that still has actions available (speed left > 1) and ensure the base has sufficient fuel for the mission.

Once a craft is selected and a target province is chosen (assuming it's within range, calculated using globe tile distances), the craft moves to that province as soon as possible.

Missions must first be detected through radar coverage mechanisms; otherwise, the player won't be able to see missions in that province. Starting the interception screen is also a way to detect missions in the province.

Assuming there is a detected mission in the province when the interception screen is started, the tactical engagement begins.

## Mechanics

### Screen Layout and Positioning

#### Grid Structure
```
XXX	AAA
YYY	BBB
-------------   line between LAND and AIR/WATER
ZZZ	CCC
```

- X (Player Air): Player air craft, max 3 in same interception
- Y (Player Land/Water): Player land or naval craft
- Z (Player Underground/Underwater): Player underground bases or underwater craft
- A (Enemy Air): Enemy alien air craft
- B (Enemy Land): Enemy alien land craft
- C (Enemy Underground/Underwater): Enemy alien underground bases or underwater craft

#### Capacity Rules
- Each section holds up to 3 crafts
- Bases take 1 slot when participating in interception
- For base defense or assault, the base is treated as taking 1 slot

#### Environmental Zones
- Air Zone: Atmospheric flight-capable craft and aerial weapons
- Surface Zone: Ground and water surface operations
- Underwater Zone: Submerged operations for submarines/aquatic craft
- Cross-Zone Restrictions: Environmental boundaries prevent unauthorized changes

#### Positioning Rules
- Craft Type Assignment: Automatic placement based on capabilities
- Fixed Positioning: No movement between zones during engagement
- Strategic Commitment: Position choice binding tactical decision

### Action Points (AP) and Energy System

#### Action Points
- Each craft has 4 AP per turn to perform actions
- Actions include using weapons or moving (dodging)
- Craft may not use all AP in a turn, investing remaining AP into maneuvers that decrease chance to be hit
- Any side can quit interception at any time, with 3 more turns to retreat (assuming they can move)

#### Energy Pool Management
- Per-Craft Pools: Independent energy reserves combining base craft energy/regen + 2 equipped weapons + addon bonuses
- Maximum Capacity: Craft-specific ceilings modifiable by equipment
- Regeneration: Turn-end recovery (flat amount or percentage)
- Consumption Gating: Actions blocked when insufficient energy
- Craft items have both AP and energy costs

#### Resource Categories
- Weapon Firing: Primary energy consumer
- Movement Actions: Position changes (if allowed)
- Special Abilities: Advanced craft capabilities
- System Activation: Sensors, countermeasures, auxiliaries

#### Depletion Effects
- Firing Lockout: Zero energy prevents weapon usage
- Performance Degradation: Reduced effectiveness at low energy
- Strategic Withdrawal: Persistent depletion forces disengagement

### Weapon Mechanics

#### Craft Items (Weapons)
- AP Cost: Each weapon use consumes AP from the craft's pool
- Energy Cost: Weapons consume from the craft's energy pool
- Range: Defines projectile travel speed between crafts
- Cooldown: Turns weapon is unavailable after use
- Hit Chance: Base chance modified by craft class and other factors

#### Firing System
- Energy Integration: Weapons consume craft energy pools
- Firing Sequence: Targeting selection, energy validation, travel calculation
- Damage Application: Hits resolve upon projectile arrival

#### Travel and Range
- Assumed Distance: 10 points between any two crafts
- Travel Time: Distance ÷ weapon range speed (e.g., range 3 = 10/3 = ~3.33 turns to reach)
- Range Examples: Range 3 reaches in ~3.33 turns, range 8 reaches in 1.25 turns

#### Targeting Restrictions
- Weapon Types: AIR to AIR, LAND to AIR, WATER to WATER, etc.
- Environmental Limits: Air weapons cannot target ground positions unless specified
- Position-Based Rules: Air zone craft target air positions only
- Facility Targeting: Base defenses target corresponding zones
- Cross-Zone Blocks: Underwater cannot target aerial craft

#### Cooldown System
- Turn-Based Recovery: Weapons unavailable for specified turns
- Energy Independence: Cooldowns separate from regeneration
- Strategic Timing: Creates spacing between weapon usage

#### Craft Types by Weapon Combinations
- Interceptor/Fighter: AIR to AIR weapons only
- Artillery: LAND to LAND weapons only
- Bomber: AIR to LAND weapons
- Transport: Unit capacity allows battlescape transitions
- Mixed: Various combinations for different roles

#### Underwater Interception
- Biome Requirement: Water biome provinces enable underwater interception
- Craft Types: AIR, WATER, UNDERWATER combinations possible
- Battle Types: Different combinations of aerial, surface, and underwater combat

### Mission Types

#### Air Battle
- Air-to-air engagements with UFOs
- AP and energy resource management
- Distance manipulation and weapon exchanges
- UFO Crash Mechanics: If air UFO hit by 50% health, chance to crash per turn

#### Base Defense
- Facilities as "weapons on base" against attackers
- Base energy pool, health, and items for attack
- Facilities provide bonuses when built in base and active during defense
- When base reaches 0 health, defenses destroyed/bypassed, transitions to land battle
- Coordinated defensive fire

#### Base Bombardment
- Strategic strikes against enemy bases
- Ground-attack weapons from air positions
- Facility destruction and crash mission spawning
- Cannot destroy base by bombardment alone - requires land battle

#### Enemy Base Assault
- Player craft attacking alien installations
- Multi-role craft for air-to-ground transitions
- Strategic infrastructure targeting
- Same mechanics as base defense but from attacking side

#### Site Landing (No Air Battle)
- Direct ground mission spawning for sites without air defenses
- Research sites and crash sites
- May have optional defenses added to site
- Terrain-specific deployment requirements

#### Land Battle Transitions
- Post-interception ground combat
- Unit deployment from craft with unit capacity
- Environmental condition integration
- Automatic transition when interception conditions met

#### Underwater Battle
- Submarine and aquatic craft combat
- Underwater zone engagements in water biome provinces
- Specialized sensor and weapon systems
- AIR, WATER, UNDERWATER craft combinations

#### Multiple Missions and Ambush
- Multiple missions can exist in same province
- Detected missions behave normally
- Undetected missions cause ambush: free turns for one side
- Only 2 battle sides total
- Max 3-4 crafts/UFOs per section

#### Retreat and Post-Interception
- Any side can quit at any time with 3 more turns to retreat (if able to move)
- After completion: choose battlescape (if units on craft) or retreat
- Craft return to originating base province
- Player can send multiple craft to province then start interception

### Deterministic Framework

#### Seeded Randomness
- Reproducible Outcomes: Consistent results for testing
- Firing Seeds: Per-weapon deterministic damage
- Battle Context: Seeds incorporate engagement state

#### Data-Driven Design
- Configurable Constants: All values externally set
- Modifier Resolution: Deterministic stacking order
- UI Transparency: Clear feedback for constraints

#### Provenance Logging
- Event Tracking: Complete audit trail
- Source Attribution: Contributing factors recorded
- Debug Support: Analysis and troubleshooting tools

## Examples

### Positioning Cases
- Mixed Fleet: Interceptors (X), transports (Y), submarines (Z)
- Base Defense: Surface turrets (Y), underwater defenses (Z)
- Bombardment: Air attackers (X) vs ground targets (B)

### Energy Scenarios
- Conservative Usage: 150/200 remaining, sustainable operations
- Aggressive Expenditure: 50/200 remaining, recovery needed
- Critical Situation: 30/200 available, limited actions

### Weapon Applications
- Close-Range Plasma: 100% accuracy, 100 damage, 50 energy
- Long-Range Missile: 50% accuracy, 300 damage, 100 energy, 2-turn cooldown
- Base Defense Turret: 75% accuracy, 120 damage, base energy pool

## Related Wiki Pages

- [Overview.md](../interception/Overview.md) - Interception overview.
- [Air Battle.md](../interception/Air%20Battle.md) - Air combat mechanics.
- [Base Defense and Bombardment.md](../interception/Base%20Defense%20and%20Bombardment.md) - Base defense systems.
- [Enemy Base Assault and Site Landing.md](../interception/Enemy%20Base%20Assault%20and%20Site%20Landing.md) - Assault operations.
- [Land Battle Transitions.md](../interception/Land%20Battle%20Transitions.md) - Ground battle transitions.
- [Mission Detection and Assignment.md](../interception/Mission%20Detection%20and%20Assignment.md) - Mission detection.
- [Underwater Battle.md](../interception/Underwater%20Battle.md) - Underwater combat.
- [Crafts.md](../crafts/Crafts.md) - Craft systems and energy.

## References to Existing Games and Mechanics

- **XCOM Series**: Core interception and tactical combat systems
- **Civilization Series**: Strategic positioning and tactical resolution
- **Total War Series**: Campaign to battle transitions
- **Europa Universalis**: Province-based strategic gameplay
- **Crusader Kings**: Integrated strategic and tactical systems
- **Hearts of Iron**: Operational level command and control
- **Victoria Series**: Grand strategy with tactical elements
- **Stellaris**: Strategic fleet combat resolution
- **Endless Space**: Strategic empire management with combat
- **Galactic Civilizations**: Integrated strategy and tactical gameplay

