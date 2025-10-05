# Classes

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Canonical Stats](#canonical-stats)
  - [Gear vs. Class Role](#gear-vs.-class-role)
  - [Abilities and Specialization](#abilities-and-specialization)
  - [Promotion Tree and Progression](#promotion-tree-and-progression)
  - [Fixed vs. Variable Properties](#fixed-vs.-variable-properties)
  - [Special Item Gating](#special-item-gating)
  - [Data-Driven Rules](#data-driven-rules)
- [Examples](#examples)
  - [Assault Class](#assault-class)
  - [Heavy Class](#heavy-class)
  - [Sniper Class](#sniper-class)
  - [Scout Class](#scout-class)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

Unit Classes in Alien Fall define distinct soldier archetypes that encapsulate roles, progression paths, and tactical responsibilities. Each class provides canonical stats, ability sets, equipment constraints, and specialization options that create clear player-facing identities such as rifleman, medic, or engineer.

Classes establish the foundation for unit behavior and progression while remaining separate from temporary equipment effects. The class system enables strategic team composition, clear power curves, and deterministic advancement through a structured promotion tree.

## Mechanics

### Canonical Stats

Each class defines fixed baseline statistics that determine unit capabilities.

Base Statistics:
- HP: Hit points determining unit survivability
- Aim: Accuracy modifier for attack resolution
- Speed: Movement speed and action efficiency
- React: Reaction speed for overwatch and interrupts
- Will: Mental resilience against psionic effects
- Energy: Action point pool for special abilities
- Strength: Carrying capacity and melee damage
- Sight: Vision range and detection capabilities

Starting Abilities:
- Class Abilities: Innate capabilities granted at recruitment
- Role-Specific Skills: Abilities matching class tactical focus
- Baseline Proficiencies: Core competencies for class role
- Specialization Hints: Preview of advancement potential

### Gear vs. Class Role

Equipment augments class capabilities without replacing core class identity.

Equipment as Augmentation:
- Operational Tools: Gear enables specific actions and playstyles
- Modifier Sources: Equipment provides stat bonuses and penalties
- Playstyle Changes: Items alter tactical approach within class framework
- Temporary Effects: Gear provides situational advantages

Class as Authority:
- Baseline Source: Class defines fundamental unit characteristics
- Role Foundation: Equipment builds upon class-defined capabilities
- Constraint Framework: Class establishes equipment compatibility boundaries
- Identity Preservation: Core class traits remain regardless of equipment

### Abilities and Specialization

Classes define ability trees that unlock through rank advancement.

Ability Framework:
- Starting Abilities: Core capabilities available from recruitment
- Rank Unlocks: New abilities become available at higher ranks
- Specialization Paths: Branching options for tactical focus
- Class Identity: Abilities reinforce and enhance class role

Specialization Mechanics:
- Hybrid Classes: Some classes provide mixed ability sets
- Role Flexibility: Multiple specialization paths within class
- Progressive Power: Abilities grow stronger with rank advancement
- Tactical Depth: Specialization enables diverse playstyles

### Promotion Tree and Progression

Classes are organized in a directed acyclic graph enabling structured advancement.

Promotion Structure:
- DAG Organization: Classes connected by advancement relationships
- Successor Lists: Each class defines allowed promotion targets
- Prerequisite Chains: Advancement requires specific conditions
- Branching Paths: Multiple specialization options available

Promotion Requirements:
- XP Cost: Experience points required for advancement
- Facility Access: Required base facilities for training
- Research Prerequisites: Technological requirements for specialization
- Health Standards: Unit must be combat-ready for promotion

Promotion Effects:
- Class Swap: Unit adopts new class identity and capabilities
- Stat Rebase: Statistics update to new class baseline
- Ability Reset: Ability set changes to match new class
- Equipment Validation: Current gear checked against new class restrictions

### Fixed vs. Variable Properties

Class stats remain consistent while allowing for individual variation.

Fixed Class Elements:
- Core Statistics: Base stats defined exclusively by class
- Ability Framework: Available abilities determined by class and rank
- Role Definition: Tactical responsibilities and playstyle focus
- Progression Path: Available promotion options and requirements

Variable Elements:
- Trait Differences: Individual characteristics from recruitment
- Medal Accolades: Achievement-based modifiers and bonuses
- Cosmetic Options: Appearance and personalization choices
- Equipment Loadouts: Tactical gear choices within class constraints

### Special Item Gating

Certain items have class-specific restrictions for balance and lore purposes.

Gating Mechanism:
- Required Class Tags: Items specify compatible classes
- Explicit Restrictions: Clear documentation of compatibility requirements
- Lore Integration: Restrictions support narrative and thematic elements
- Balance Control: Prevents overpowered combinations

Implementation:
- Tag System: Items include required_class fields
- Validation Checks: Equipment compatibility verified on assignment
- UI Feedback: Clear indication of incompatible items
- Exception Usage: Sparing application for unique or specialized gear

### Data-Driven Rules

All class mechanics are defined in external data for modding and consistency.

Data Structure:
- YAML/JSON Definitions: Class data stored in human-readable formats
- Seeded Behavior: Deterministic outcomes for testing and replay
- Moddable Content: Community modification of classes and progression
- Validation Rules: Automated checking of data integrity

Deterministic Systems:
- Reproducible Outcomes: Same inputs produce identical results
- Preview Tools: Designers can test class combinations and progression
- Provenance Logging: Track class assignments and promotion choices
- Compatibility Validation: Automated checking of class and item interactions

## Examples

### Assault Class

Close-quarters combat specialist focused on mobility and breaching.

Core Stats:
- High Speed for rapid movement and positioning
- Strong Melee capabilities for close combat
- Moderate HP for survivability in assaults
- Good React for interrupt capabilities

Key Abilities:
- Mobility Skills: Enhanced movement and positioning options
- Breaching Techniques: Specialized door and wall destruction
- Close Combat: Improved melee attacks and defensive maneuvers
- Assault Tactics: Coordinated attack patterns and formations

Progression Path:
- Basic Assault: Starting abilities for close-quarters work
- Shock Trooper: Enhanced breaching and mobility
- Elite Assault: Advanced tactics and special operations
- Assault Commander: Leadership and coordination abilities

### Heavy Class

High-durability specialist focused on heavy weapons and suppression.

Core Stats:
- Very high HP for frontline durability
- Exceptional Strength for heavy equipment
- Moderate Speed despite heavy loadouts
- Good Will for resistance to suppression

Key Abilities:
- Heavy Weapons Proficiency: Enhanced operation of large firearms
- Armor Penetration: Improved damage against protected targets
- Suppression Fire: Area denial and enemy disruption
- Fortress Stance: Defensive positioning and cover utilization

Progression Path:
- Heavy Gunner: Basic heavy weapon operation
- Armored Infantry: Enhanced protection and durability
- Weapons Specialist: Advanced heavy weapon mastery
- Heavy Support: Suppression and area control expertise

### Sniper Class

Long-range precision specialist focused on accuracy and reconnaissance.

Core Stats:
- Exceptional Aim for long-range accuracy
- Superior Sight for extended detection range
- Moderate Speed for tactical positioning
- High Will for concentration under pressure

Key Abilities:
- Precision Shooting: Enhanced accuracy at long range
- Spotting Skills: Improved detection and target marking
- Camouflage Techniques: Stealth and concealment abilities
- Overwatch Mastery: Superior reaction fire capabilities

Progression Path:
- Marksman: Basic long-range proficiency
- Scout Sniper: Reconnaissance and precision shooting
- Precision Specialist: Advanced accuracy and targeting
- Sniper Elite: Master-level long-range operations

### Scout Class

Stealth and reconnaissance specialist focused on information gathering.

Core Stats:
- High Speed for rapid deployment and evasion
- Excellent Sight for detection and surveillance
- Good React for early warning capabilities
- Moderate Will for field operations

Key Abilities:
- Stealth Movement: Reduced detection and silent operation
- Reconnaissance: Enhanced information gathering
- Marking Targets: Enemy position revelation and tracking
- Evasion Tactics: Defensive maneuvers and withdrawal options

Progression Path:
- Recon Scout: Basic reconnaissance and stealth
- Pathfinder: Advanced navigation and survival skills
- Intelligence Specialist: Superior information gathering
- Elite Recon: Master-level stealth and surveillance operations

## Related Wiki Pages

- [Units.md](../units/Units.md) - Unit class system.
- [Stats.md](../units/Stats.md) - Class stat definitions.
- [Traits.md](../units/Traits.md) - Class trait assignments.
- [Squad Autopromotion.md](../battlescape/Squad%20Autopromotion.md) - Class promotion mechanics.
- [Action points.md](../units/Action%20points.md) - AP by class.
- [Energy.md](../units/Energy.md) - Energy by class.
- [Inventory.md](../items/Inventory.md) - Class equipment restrictions.
- [Factions.md](../units/Factions.md) - Faction-specific classes.
- [Research.md](../economy/Research.md) - Class unlock research.

## References to Existing Games and Mechanics

- X-COM series: Soldier class specializations.
- Fire Emblem: Character job classes.
- Final Fantasy Tactics: Job class system.
- Advance Wars: Unit type classes.
- Disgaea: Demon class system.
- Tactics Ogre: Class change mechanics.
- Warhammer 40k: Unit type classifications.
- Civilization series: Unit class promotions.

