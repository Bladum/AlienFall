# Interception Overview

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Mission Flow and Phases](#mission-flow-and-phases)
  - [Detection and Assignment](#detection-and-assignment)
  - [Resolution Grid System](#resolution-grid-system)
  - [Environmental Zones and Transitions](#environmental-zones-and-transitions)
  - [Energy and Resource Management](#energy-and-resource-management)
  - [Weapon and Combat Mechanics](#weapon-and-combat-mechanics)
- [Examples](#examples)
  - [Air Battle Engagement](#air-battle-engagement)
  - [Base Defense Scenario](#base-defense-scenario)
  - [Bombardment Mission](#bombardment-mission)
  - [Multi-Phase Transition](#multi-phase-transition)
  - [Underwater Combat](#underwater-combat)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview
The Interception system serves as a unified tactical screen in Alien Fall that replaces separate mini-games for all craft-based missions. It handles air battles, base defense, bombardment, enemy base assault, site landings, land battles, and underwater combat through a single 3x3 grid interface with environmental zones.

The system provides comprehensive coverage of interception scenarios while maintaining strategic depth and eliminating redundant mini-games. It integrates seamlessly with geoscape strategic elements and enables smooth transitions to battlescape ground combat.

## Mechanics
### Mission Flow and Phases
Interception missions follow a structured flow from geoscape strategic planning through tactical resolution to strategic impact:

1. **Geoscape Selection**: Player selects province containing their own base
2. **Craft Selection**: Choose craft with remaining actions (speed left > 1) and sufficient base fuel
3. **Target Selection**: Select target province within craft range (calculated using globe tile distances)
4. **Movement**: Craft moves to target province as soon as possible
5. **Mission Detection**: Missions must be detected via radar coverage; interception screen also detects missions
6. **Interception Engagement**: Tactical combat on 3x3 grid with AP, energy, and weapon systems
7. **Resolution**: Combat concludes with retreat or transition conditions met
8. **Post-Interception**: Choose battlescape (if units available) or retreat; crafts return to base province

Each phase handles specific aspects of craft-based combat with deterministic outcomes.

### Detection and Assignment
Hidden missions are discovered through base facilities and radar coverage mechanisms. Craft eligibility validation considers capabilities, range (using globe tile calculations), fuel, and weapons. Missions must be detected before they can be seen on the geoscape; starting the interception screen is also a way to detect missions in a province. Undetected missions may ambush during interception, granting free turns to one side.

### Resolution Grid System
Combat occurs on a 3x3 grid with X/Y/Z player zones versus A/B/C enemy zones:

```
XXX	AAA  (Air)
YYY	BBB  (Land/Water)
-----------  (line between land and water)
ZZZ	CCC  (Underground/Underwater)
```

Each craft has 4 AP per turn for weapons or movement/dodging. Energy pools combine craft base energy + weapons + addons. Weapon travel times based on range (10 point distance ÷ weapon range). Targeting restrictions by environmental zones. Base facilities participate as "weapons on base" with integrated energy consumption and damage mechanics. Multiple missions can occur in same province; undetected ones cause ambush.

### Environmental Zones and Transitions
Craft positioning considers environmental zones including air, surface, and underwater. Air destruction prevents land battle while crash/landing events trigger ground combat. Terrain compatibility affects deployment with seamless transitions between different combat environments. Underwater interception occurs in water biome provinces with AIR, WATER, UNDERWATER craft combinations. Base defense uses facilities as weapons; when base health reaches 0, defenses are destroyed/bypassed leading to land battle. Bases cannot be destroyed by bombardment alone - requires land battle with units.

### Energy and Resource Management
Per-craft energy pools combine base craft energy/regen + 2 equipped weapons + addon bonuses. Each craft has 4 AP per turn for actions (weapons or movement/dodging). Resource constraints create tactical trade-offs and strategic resource management throughout interception engagements. Weapons have both AP and energy costs, plus cooldowns and hit chances modified by craft class.

### Weapon and Combat Mechanics
Weapons feature travel time based on range (10 point distance ÷ weapon range speed), targeting restrictions by environmental zones, and limitations including cooldowns, ammunition, and hardpoint constraints. Base integration enables facilities to function as defensive or offensive weapons. Craft types defined by weapon combinations: AIR-to-AIR (interceptors), LAND-to-LAND (artillery), AIR-to-LAND (bombers), plus unit capacity for battlescape transitions. UFO crash chance when air UFO reaches 50% health.

## Examples
### Air Battle Engagement
Player Skyranger intercepts UFO over ocean province. 3x3 grid shows craft positions with energy pools depleting as weapons fire. Successful interception destroys UFO, preventing ground mission spawn.

### Base Defense Scenario
Alien craft attack player base with surface-to-air missiles. Base facilities participate as weapons on grid, consuming base energy pools. Coordinated fire destroys attacking craft before they reach bombardment range.

### Bombardment Mission
Player craft equipped with ground-attack weapons target alien base. Weapons travel through grid zones with travel time calculations. Successful bombardment damages base facilities and spawns crash site mission.

### Multi-Phase Transition
Interception battle damages but doesn't destroy enemy craft, causing crash landing. Surviving craft transition to land battle with units deploying from craft. Terrain compatibility affects deployment positions and initial advantages.

### Underwater Combat
Submarine craft engage underwater UFO in deep ocean province. Specialized sensors and capabilities affect detection and weapon effectiveness. Environmental zones create unique tactical challenges.

## Related Wiki Pages

- [Interception Core Mechanics.md](../interception/Interception%20Core%20Mechanics.md) - Core interception systems
- [Air Battle.md](../interception/Air%20Battle.md) - Air combat mechanics
- [Base Defense and Bombardment.md](../interception/Base%20Defense%20and%20Bombardment.md) - Base defense systems
- [Enemy Base Assault and Site Landing.md](../interception/Enemy%20Base%20Assault%20and%20Site%20Landing.md) - Assault operations
- [Land Battle Transitions.md](../interception/Land%20Battle%20Transitions.md) - Ground battle transitions
- [Mission Detection and Assignment.md](../interception/Mission%20Detection%20and%20Assignment.md) - Mission detection
- [Underwater Battle.md](../interception/Underwater%20Battle.md) - Underwater combat
- [Geoscape.md](../geoscape/Geoscape.md) - Strategic layer integration

## References to Existing Games and Mechanics

- **XCOM Series**: Unified interception and tactical combat systems
- **Civilization Series**: Strategic positioning and tactical resolution
- **Total War Series**: Campaign to battle transitions
- **Europa Universalis**: Province-based strategic gameplay
- **Crusader Kings**: Integrated strategic and tactical systems
- **Hearts of Iron**: Operational level command and control
- **Victoria Series**: Grand strategy with tactical elements
- **Stellaris**: Strategic fleet combat resolution
- **Endless Space**: Strategic empire management with combat
- **Galactic Civilizations**: Integrated strategy and tactical gameplay

