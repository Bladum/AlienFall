# Mission Objectives

## Table of Contents
- [Overview](#overview)
- [Point-Based Victory System](#point-based-victory-system)
  - [Victory Points](#victory-points)
  - [Objective Point Distribution](#objective-point-distribution)
  - [Death Match Fallback](#death-match-fallback)
- [Mechanics](#mechanics)
  - [Authoring and Instantiation](#authoring-and-instantiation)
  - [States and Evaluation](#states-and-evaluation)
  - [End Conditions](#end-conditions)
  - [Rewards and Penalties](#rewards-and-penalties)
  - [Priority and Sequencing](#priority-and-sequencing)
  - [UX and Feedback](#ux-and-feedback)
- [Game Modes and Mission Types](#game-modes-and-mission-types)
  - [Death Match](#death-match)
  - [Capture the Flag](#capture-the-flag)
  - [Domination](#domination)
  - [Assault](#assault)
  - [Defense](#defense)
  - [Rescue Operations](#rescue-operations)
  - [Sabotage and Infiltration](#sabotage-and-infiltration)
  - [Escort Missions](#escort-missions)
  - [Retrieval Missions](#retrieval-missions)
  - [Multi-Phase Operations](#multi-phase-operations)
- [Examples](#examples)
  - [Elimination Objectives](#elimination-objectives)
  - [Rescue Objectives](#rescue-objectives)
  - [Retrieval Objectives](#retrieval-objectives)
  - [Defense Objectives](#defense-objectives)
  - [Complex Objectives](#complex-objectives)
  - [Interception-Transition Objectives](#interception-transition-objectives)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

Mission Objectives translate scenario intent into concrete, authorable win/loss and graded success conditions that designers can tune via data. Objectives are deterministically evaluated on a fixed cadence so rewards, penalties and mission endings are predictable and auditable. Required vs optional objectives are surfaced in briefings and the mission UI to drive player prioritisation, and objective outcomes feed salvage, medals and campaign metrics with full provenance for reproducible balance testing.

## Point-Based Victory System

Alien Fall uses a flexible point-based victory system where missions require accumulating a target number of victory points (typically 1000) to achieve success. This system allows for diverse mission types beyond simple elimination, creating varied tactical experiences while maintaining clear win conditions.

### Victory Points

- **Target Score**: Missions require 1000 victory points for standard completion
- **Point Sources**: Points are earned through various objectives (elimination, capture, rescue, etc.)
- **Partial Victory**: Missions can be won with fewer points if primary objectives are completed
- **Bonus Objectives**: Additional points available for optional secondary goals
- **Point Tracking**: Real-time point accumulation displayed in mission UI

### Objective Point Distribution

Objectives are assigned point values based on their difficulty, importance, and strategic impact:

- **High-Value Objectives** (400-600 points): Mission-critical goals that provide majority of victory points
  - Capturing and holding strategic positions
  - Rescuing high-value units (commanders, scientists)
  - Retrieving critical artifacts or data
  - Eliminating special enemy units (commanders, elites)

- **Medium-Value Objectives** (200-400 points): Important but not mission-critical goals
  - Clearing enemy strongholds
  - Disabling enemy equipment
  - Establishing defensive perimeters
  - Gathering intelligence

- **Low-Value Objectives** (50-200 points): Supporting goals that provide tactical advantages
  - Eliminating standard enemy units
  - Securing supply caches
  - Establishing overwatch positions
  - Disabling minor enemy systems

### Death Match Fallback

When death match is the primary or only victory condition, points are distributed among enemy units based on their rank and threat level:

- **Elite/Commander Units**: 200-300 points each (high-value targets)
  - Alien Commanders, Elite Soldiers, Special Forces leaders
- **Specialist Units**: 100-200 points each (squad leaders, heavy weapons)
  - Heavy Weapons specialists, Medics, Engineers, Psionics
- **Veteran Units**: 75-150 points each (experienced soldiers)
  - Veteran infantry, NCOs, experienced combatants
- **Regular Units**: 50-100 points each (standard infantry)
  - Standard soldiers, basic combatants
- **Conscript Units**: 25-75 points each (low-threat enemies)
  - Recruits, drones, minimal combatants

In pure death match scenarios, eliminating all enemy units provides the full 1000 points needed for victory. When other objectives are present, unit elimination becomes less critical, with points redistributed toward mission-specific goals.

## Mechanics

### Authoring and Instantiation
- Objective Definitions: Data-driven templates for different objective types without code changes
- Map Script Integration: Objectives placed by map generation scripts with anchor positioning
- Reachability Validation: Automated checks ensuring objectives can be completed and accessed
- Consistency Verification: Validation that objectives work with chosen mission parameters and terrain
- Seed-Based Generation: Deterministic objective placement using mission seeds for reproducibility
- Fallback Mechanisms: Alternative objective placement when primary locations fail or are blocked

### States and Evaluation
- Active State: Objective is in progress and being evaluated on regular intervals
- Completed State: Success conditions have been met with full or partial achievement
- Failed State: Failure conditions have been triggered through time limits or other criteria
- Expired State: Time-limited objectives that ran out of time without completion
- Evaluation Cadence: Configurable intervals for objective checking with deterministic timing
- Deterministic Checks: Seeded evaluation ensuring consistent results across play sessions

### End Conditions
- Win Conditions: All required objectives completed successfully for mission victory
- Loss Conditions: Required objectives failed or all player units eliminated/incapacitated
- Partial Success: Mixed outcomes with scaled rewards based on completion percentage
- Surrender Mechanics: Immediate failure bypassing objective evaluation for quick exit
- Special Rules: Mission-specific ending conditions (artifact pickup, alarm prevention) for variety
- Early Termination: Objectives that can end missions before combat completion for dynamic pacing

### Rewards and Penalties
- Score Rewards: Mission performance points for strategic metrics and achievement tracking
- Fame/Karma: Reputation and moral alignment changes affecting campaign progression
- Cash Bonuses: Monetary rewards for successful completion and bonus objectives
- Medal System: Achievement-based recognition for exceptional performance
- Salvage Multipliers: Equipment recovery bonuses for completed objectives
- Penalty Application: Score deductions and narrative consequences for failed objectives

### Priority and Sequencing
- Required Objectives: Must be completed for mission success with critical consequences
- Optional Objectives: Bonus goals providing additional rewards without failure penalty
- Priority Levels: Execution order for multiple simultaneous objectives with clear hierarchy
- Sequencing Rules: Objectives that must be completed in specific order for logical progression
- Interdependency: Objectives that affect or are affected by others through conditional activation
- Dynamic Activation: Objectives that become available based on other progress or mission state

### UX and Feedback
- Briefing Display: Clear presentation of objectives and consequences in mission preparation
- Mission UI: Real-time objective status and progress indicators during gameplay
- Minimap Integration: Objective location markers and zones for spatial awareness
- Progress Tracking: Visual feedback on completion status and remaining requirements
- Reminder Systems: Alerts for time-sensitive objectives to prevent oversight
- Post-Mission Summary: Detailed breakdown of objective outcomes and performance metrics

## Game Modes and Mission Types

Alien Fall features diverse mission types inspired by tactical, RPG, and RTS games, each with unique victory conditions and point distributions.

### Death Match
**Primary Objective**: Eliminate all enemy forces
**Point Distribution**: All 1000 points from unit elimination based on rank
**AI Behavior**: Aggressive defense of positions, priority targeting of high-value units
**Examples**: Standard combat encounters, cleanup operations

### Capture the Flag
**Primary Objective**: Capture and hold designated control points
**Point Distribution**: 600 points from holding points, 400 from enemy elimination
**Time Element**: Points awarded per turn held, bonus for consecutive control
**AI Behavior**: Contest control points, defend captured areas, flank maneuvers
**Examples**: Territory control, resource point domination

### Domination
**Primary Objective**: Control majority of map zones for extended periods
**Point Distribution**: 500 points from zone control, 300 from enemy disruption, 200 from elimination
**Dynamic Elements**: Zones change ownership, reinforcement based on control
**AI Behavior**: Zone defense, counter-attacks, strategic positioning
**Examples**: King of the Hill variants, area denial missions

### Assault
**Primary Objective**: Breach enemy defenses and capture key positions
**Point Distribution**: 700 points from objective capture, 300 from elimination
**Phased Approach**: Multiple defensive lines, escalating resistance
**AI Behavior**: Layered defense, fallback positions, counter-charges
**Examples**: Base assaults, fortress sieges, facility captures

### Defense
**Primary Objective**: Prevent enemy capture of defended positions
**Point Distribution**: 600 points from successful defense, 400 from enemy elimination
**Waves/Spawning**: Enemy reinforcements, time-based attacks
**AI Behavior**: Probe defenses, exploit weaknesses, coordinated assaults
**Examples**: Hold the line, last stand scenarios, convoy protection

### Rescue Operations
**Primary Objective**: Locate and extract friendly or neutral units
**Point Distribution**: 500 points from successful rescue, 300 from protection, 200 from elimination
**Time Pressure**: Extraction windows, deteriorating conditions
**AI Behavior**: Intercept rescue attempts, guard objectives, pursuit tactics
**Examples**: Hostage rescue, downed pilot recovery, VIP extraction

### Sabotage and Infiltration
**Primary Objective**: Infiltrate and disrupt enemy operations
**Point Distribution**: 600 points from sabotage completion, 400 from stealth maintenance
**Detection Mechanics**: Alarm systems, patrol disruption
**AI Behavior**: Patrol patterns, sentry positioning, rapid response
**Examples**: Bomb defusal, data theft, equipment destruction

### Escort Missions
**Primary Objective**: Guide protected units to safety
**Point Distribution**: 500 points from successful escort, 300 from protection, 200 from elimination
**Movement Dynamics**: Pathfinding challenges, dynamic threats
**AI Behavior**: Intercept routes, ambush setup, pursuit strategies
**Examples**: Convoy escort, VIP protection, retreat operations

### Retrieval Missions
**Primary Objective**: Locate and recover valuable items or data
**Point Distribution**: 600 points from item recovery, 400 from secure transport
**Search Elements**: Hidden objectives, puzzle-like discovery
**AI Behavior**: Guard valuables, patrol search areas, recovery prevention
**Examples**: Artifact hunting, intelligence gathering, prototype recovery

### Multi-Phase Operations
**Primary Objective**: Complete sequential objectives with changing conditions
**Point Distribution**: Distributed across phases (300/300/400 typical split)
**Progressive Difficulty**: Escalating threats, time pressure increases
**AI Behavior**: Adaptive responses, reinforcement timing, strategic retreats
**Examples**: Multi-stage assaults, timed extractions, evolving scenarios

## Examples

### Elimination Objectives
- Eliminate all hostiles: Clear the map of enemy forces (default victory condition)
- Priority-target elimination: Locate and eliminate a named enemy commander before reinforcements arrive
- Selective elimination: Remove specific enemy units while preserving others for narrative reasons
- Area clearance: Eliminate enemies within a designated zone for territorial control
- Timed elimination: Complete elimination within a turn limit for time-critical scenarios
- High-value target hunting: Focus on eliminating elite units worth significant victory points
- Commander assassination: Eliminate enemy leaders to disrupt command structure

### Rescue Objectives
- Rescue VIP: Escort a civilian unit to an extraction zone within N turns for safe evacuation
- Rescue pilot: Locate a downed pilot, carry or escort to extraction; pilot status affects reward scaling
- Hostage rescue: Free captives from enemy control and evacuate them to safety
- Medical evacuation: Extract wounded friendly units for treatment and recovery
- Escort mission: Protect and guide NPCs through dangerous areas to designated safe zones
- Prisoner liberation: Free captured allies from enemy custody
- Survivor extraction: Locate and rescue crash survivors before enemy recovery teams

### Retrieval Objectives
- Retrieve artifact: Move to an object, pick it up, and deliver to extraction for research
- Data recovery: Collect intelligence or documents from enemy positions for strategic value
- Equipment salvage: Recover valuable gear from the battlefield for reuse
- Sample collection: Gather scientific or research materials for technological advancement
- Weapon recovery: Retrieve prototype or unique weapons for analysis and deployment
- Ancient artifact hunting: Search ruins for valuable historical items
- Prototype technology: Secure experimental enemy equipment for study

### Defense Objectives
- Hold position: Defend a marked area for T turns against assault waves and enemy advances
- Protect asset: Prevent enemy access to critical objectives through active defense
- Convoy defense: Escort and protect moving units or vehicles through hostile territory
- Perimeter defense: Maintain defensive lines against enemy advances and incursions
- Asset denial: Prevent enemy capture of valuable resources through strategic positioning
- Base defense: Protect friendly installations from enemy assault
- Evacuation defense: Hold extraction zones while allies withdraw

### Control Point Objectives
- Capture the flag: Secure and hold designated control points for extended periods
- Domination: Control majority of map zones simultaneously for victory points
- King of the Hill: Maintain control of a central objective against all challengers
- Zone control: Capture and defend territory sectors for cumulative points
- Checkpoint capture: Secure sequential waypoints along a route
- Resource point defense: Protect valuable map locations from enemy capture

### Sabotage and Disruption Objectives
- Destroy equipment: Disable or destroy enemy machinery and installations
- Hack terminal: Access enemy computer systems to extract data or cause malfunctions
- Plant explosives: Set charges on enemy structures for timed demolition
- Disable communications: Jam or destroy enemy signal equipment
- Contaminate supplies: Poison enemy resources or equipment
- Sabotage production: Disrupt enemy manufacturing or research facilities

### Exploration and Discovery Objectives
- Map exploration: Reveal designated percentage of the battlefield
- Secret area discovery: Locate hidden locations containing valuable objectives
- Ancient ruin investigation: Explore archaeological sites for artifacts
- Crash site investigation: Secure and investigate downed craft for technology
- Underground facility mapping: Navigate and document enemy subterranean bases

### Time-Pressured Objectives
- Race against time: Complete objectives before enemy reinforcements arrive
- Bomb defusal: Locate and disarm explosive devices within time limits
- Containment breach: Prevent alien specimens from escaping containment
- Evacuation countdown: Extract all units before area becomes uninhabitable
- Ritual interruption: Stop enemy ceremonies before completion

### Multi-Phase Objectives
- Sequential capture: Secure multiple objectives in specific order
- Progressive defense: Hold positions while enemy assault waves increase in intensity
- Chain reaction: Complete one objective to unlock access to subsequent goals
- Escalating threat: Face increasingly difficult challenges as mission progresses
- Adaptive objectives: Mission goals that change based on player performance

### Complex Objectives
- Sabotage device: Reach a console and disable it before timer expires to prevent activation
- Prevent alarm: Stop alarm devices from triggering during the mission for stealth preservation
- Ambush trigger: Avoid detection until a scripted cue—early detection fails objective and alerts enemies
- Timed extraction: Reach extraction before countdown or after scripted event completion
- Multi-phase: Combination objectives requiring different actions in sequence for layered challenges

### Interception-Transition Objectives
- Crash site investigation: Secure and investigate a crashed UFO, recover technology/artifacts for research
- Survivor rescue: Locate and extract surviving crew from downed craft before enemy recovery teams
- Pursuit completion: Track and eliminate enemy forces that escaped interception engagement
- Facility assault: Capture or destroy enemy base after disabling aerial defenses for ground operations
- Bombardment assessment: Evaluate damage from orbital/aerial bombardment and secure remaining objectives
- Landing zone security: Defend deployed position while establishing perimeter against counterattack
- Craft recovery: Repair and recover damaged friendly craft under combat conditions
- Destroyed craft rescue: Rescue surviving units from destroyed craft crash sites, potentially recover heavily damaged craft
- Interdiction follow-up: Complete ground-based objectives after preventing aerial delivery
- Base defense breach: Ground assault following interception where base defenses are bypassed but not destroyed

## Related Wiki Pages

- [Mission preparation.md](../battlescape/Mission%20preparation.md) - Preparing for objectives.
- [Mission salvage.md](../battlescape/Mission%20salvage.md) - Salvage from objectives.
- [Battle map.md](../battlescape/Battle%20map.md) - Map for objectives.
- [Geoscape.md](../geoscape/Geoscape.md) - Strategic objectives.
- [Interception.md](../interception/Overview.md) - Interception objectives.
- [AI Battlescape.md](../ai/Battlescape%20AI.md) - AI objectives.
- [Base management.md](../basescape/Base%20management.md) - Base objectives.
- [Research.md](../economy/Research.md) - Research objectives.
- [Craft.md](../crafts/Craft.md) - Craft objectives.
- [UFO.md](../interception/UFO.md) - UFO objectives.

## References to Existing Games and Mechanics

### Tactical Strategy Games
- **X-COM Series** (1994-2016): Mission objectives, alien containment, base defense, terror missions
- **Fire Emblem Series** (1990-2023): Chapter objectives, character rescue, castle sieges, rout maps
- **Advance Wars Series** (2001-2018): Property capture, unit elimination, HQ capture, fog of war missions
- **Tactics Ogre** (1995-2010): Alignment-based objectives, character recruitment, stronghold capture
- **Final Fantasy Tactics** (1997-2021): Multi-phase battles, special character recruitment, throne room defense

### Real-Time Strategy Games
- **Commandos Series** (1998-2006): Stealth infiltration, sabotage, prisoner rescue, timed extractions
- **Desperados Series** (2001-2007): Coordinated unit control, environmental interaction, silent elimination
- **Robin Hood: The Legend of Sherwood** (2002): Hero-based missions, sabotage, assassination, territory control
- **Battle Isle Series** (1991-2000): Island capture, resource control, amphibious assaults
- **Close Combat Series** (1996-2000): Historical battle recreation, squad-based tactics, terrain exploitation

### Role-Playing Games
- **Baldur's Gate Series** (1998-2001): Quest objectives, NPC rescue, dungeon exploration, faction management
- **Fallout Series** (1997-2023): Faction quests, item retrieval, base building, moral choice objectives
- **Divinity: Original Sin Series** (2014-2018): Environmental puzzles, NPC interaction, tactical positioning
- **Pillars of Eternity** (2015): Faction influence, stronghold defense, companion recruitment
- **Dragon Age Series** (2009-2024): Companion rescue, stronghold assault, political objectives

### Turn-Based Strategy Games
- **Civilization Series** (1991-2021): City capture, wonder construction, diplomatic victory, domination
- **Heroes of Might and Magic Series** (1995-2015): Town capture, artifact retrieval, hero recruitment
- **Disciples Series** (2001-2009): Capital defense, hero assassination, resource control
- **Master of Magic** (1994): Wizard tower defense, spell research, conquest objectives
- **Lords of the Realm Series** (1994-2000): Castle sieges, peasant management, economic objectives

### Modern Tactical Games
- **Rainbow Six Siege** (2015): Objective-based multiplayer, bomb defusal, hostage rescue, site control
- **Insurgency Series** (2014-2018): Firefight modes, checkpoint capture, cache destruction
- **Squad** (2015): Large-scale combined arms, base capture, vehicle escort, supply line control
- **Hell Let Loose** (2019): War simulation, sector control, offensive/defensive operations
- **Post Scriptum** (2018): Historical accuracy, trench warfare, artillery coordination

### Classic Strategy Games
- **Dune II** (1992): Spice harvesting, base building, unit production, territory control
- **Warcraft Series** (1994-2023): Base defense, hero quests, resource gathering, expansion
- **Command & Conquer Series** (1995-2020): Technology theft, superweapon activation, economic warfare
- **Total Annihilation** (1997): Metal/energy control, commander elimination, expansion strategies
- **StarCraft Series** (1998-2017): Zerg creep spread, protoss psi-link, terran siege warfare

