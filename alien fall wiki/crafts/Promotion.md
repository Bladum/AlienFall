# Craft Promotion

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Experience System](#experience-system)
  - [Veterancy Levels](#veterancy-levels)
  - [XP Sources](#xp-sources)
- [Examples](#examples)
  - [Fighter Progression](#fighter-progression)
    - [Rookie Interceptor (Level 1)](#rookie-interceptor-level-1)
    - [Veteran Interceptor (Level 3)](#veteran-interceptor-level-3)
    - [Elite Interceptor (Level 5)](#elite-interceptor-level-5)
  - [Bomber Progression](#bomber-progression)
    - [Standard Bomber (Level 1)](#standard-bomber-level-1)
    - [Experienced Bomber (Level 3)](#experienced-bomber-level-3)
    - [Elite Bomber (Level 5)](#elite-bomber-level-5)
  - [Transport Progression](#transport-progression)
    - [Basic Transport (Level 1)](#basic-transport-level-1)
    - [Reliable Transport (Level 3)](#reliable-transport-level-3)
    - [Veteran Transport (Level 5)](#veteran-transport-level-5)
  - [Level Requirements](#level-requirements)
  - [Class Advancement](#class-advancement)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The craft veterancy system implements a progression framework similar to unit advancement, where crafts earn experience points from missions and advance through levels. Crafts can progress to improved variants of their class (e.g., Skyranger 1 → Skyranger 2) with only slight stat improvements. The system rewards craft survival and usage while maintaining that significant upgrades require building or purchasing new craft. Veterancy provides minor bonuses that enhance reliability and performance without fundamentally changing craft capabilities.

The framework encourages attachment to proven craft while ensuring that major improvements come through technological advancement and resource investment, maintaining balance between progression and strategic decision-making.

## Mechanics

### Experience System

Crafts accumulate experience through operational activities with deterministic tracking:

- XP Accumulation: Points earned from missions completed and combat actions, recorded on craft objects
- Level Progression: Crafts advance through levels (1-5) with increasing XP requirements
- Class Advancement: At maximum level, crafts can upgrade to improved variants (e.g., Skyranger 1 → Skyranger 2)
- Minor Bonuses: Veterancy provides small stat improvements (+1-2% to relevant stats per level)
- No Major Upgrades: Significant craft improvements require building or purchasing new craft
- Source Attribution: Different activities provide different XP values with modifier application
- Deterministic Processing: Seeded calculations ensuring reproducible outcomes for testing and balance

### Veterancy Levels

Structured advancement system with increasing requirements:

- Level Structure: Numbered levels (1-5) for all craft types
- Experience Thresholds: Increasing XP requirements (Level 1: 100 XP, Level 2: 300 XP, Level 3: 600 XP, Level 4: 1000 XP, Level 5: 1500 XP)
- Class Advancement: At Level 5, crafts can upgrade to next variant (e.g., Skyranger 1 → Skyranger 2)
- Maximum Level: Level 5 cap to prevent excessive bonuses
- Minor Improvements: Only slight stat enhancements per level

### Veterancy Bonuses

Small performance improvements granted at each level:

- Hull Bonus: +1 HP per level (maximum +5 HP at level 5)
- Accuracy Bonus: +1% hit chance per level (maximum +5% at level 5)
- Speed Bonus: +1 speed point per level (maximum +5 speed at level 5)
- Minor Enhancements: Small reliability and crew skill improvements
- No Major Changes: Bonuses are slight and don't fundamentally alter craft roles

### XP Sources

Experience gained from mission completion and survival:

- Mission Completion: 50 XP per successful mission
- UFO Interception: +25 XP bonus for engaging enemy craft
- Craft Survival: +10 XP for returning from combat
- Unit Transport: +15 XP for successful unit deployment/extraction

## Examples

### Fighter Progression

#### Rookie Interceptor (Level 1)
- Experience: 0/100 to Level 2
- Hull: Base 30 (+0 bonus)
- Accuracy: Base (+0% bonus)
- Speed: Base 120 (+0 bonus)
- Capabilities: Basic interception and dogfighting operations
- Typical Missions: Routine patrols, basic threat interception

#### Veteran Interceptor (Level 3)
- Experience: 600/1000 to Level 4
- Hull: 33 (+3 bonus)
- Accuracy: +3% hit chance
- Speed: 123 (+3 bonus)
- Capabilities: Slightly enhanced survivability and accuracy
- Typical Missions: Complex dogfights, high-priority interception operations

#### Elite Interceptor (Level 5)
- Experience: 1500+ (maximum level, can upgrade to Interceptor II)
- Hull: 35 (+5 bonus)
- Accuracy: +5% hit chance
- Speed: 125 (+5 bonus)
- Capabilities: Minor performance improvements, eligible for class upgrade
- Typical Missions: High-threat engagements with slight statistical advantages

### Bomber Progression

#### Standard Bomber (Level 1)
- Experience: 0/100 to Level 2
- Hull: Base 80 (+0 bonus)
- Accuracy: Base (+0% bonus)
- Speed: Base 80 (+0 bonus)
- Capabilities: Basic strike missions and area denial operations
- Typical Missions: Ground attack, conventional bombardment

#### Experienced Bomber (Level 3)
- Experience: 600/1000 to Level 4
- Hull: 83 (+3 bonus)
- Accuracy: +3% hit chance
- Speed: 83 (+3 bonus)
- Capabilities: Slightly improved accuracy and survivability
- Typical Missions: Precision strikes, heavy bombardment operations

#### Elite Bomber (Level 5)
- Experience: 1500+ (maximum level, can upgrade to Bomber II)
- Hull: 85 (+5 bonus)
- Accuracy: +5% hit chance
- Speed: 85 (+5 bonus)
- Capabilities: Minor performance improvements, eligible for class upgrade
- Typical Missions: Strategic targets with slight statistical advantages

### Transport Progression

#### Basic Transport (Level 1)
- Experience: 0/100 to Level 2
- Hull: Base 80 (+0 bonus)
- Capacity: Base 8 (+0 bonus)
- Speed: Base 80 (+0 bonus)
- Capabilities: Standard logistics operations and troop deployment
- Typical Missions: Routine transport, supply delivery operations

#### Reliable Transport (Level 3)
- Experience: 600/1000 to Level 4
- Hull: 83 (+3 bonus)
- Capacity: 8 (no change)
- Speed: 83 (+3 bonus)
- Capabilities: Slightly enhanced reliability and speed
- Typical Missions: Priority logistics, unit deployment operations

#### Veteran Transport (Level 5)
- Experience: 1500+ (maximum level, can upgrade to Transport II)
- Hull: 85 (+5 bonus)
- Capacity: 8 (no change)
- Speed: 85 (+5 bonus)
- Capabilities: Minor performance improvements, eligible for class upgrade
- Typical Missions: Large-scale operations with slight statistical advantages

### Level Requirements

XP requirements for advancement (same for all craft types):

- Level 1: 0 XP (starting)
- Level 2: 100 XP (+1 HP, +1% accuracy, +1 speed)
- Level 3: 300 XP (+2 HP, +2% accuracy, +2 speed)
- Level 4: 600 XP (+3 HP, +3% accuracy, +3 speed)
- Level 5: 1000 XP (+4 HP, +4% accuracy, +4 speed, eligible for class upgrade)

### Class Advancement

At Level 5, crafts can be upgraded to improved variants:

- Interceptor I → Interceptor II (better base stats, same role)
- Bomber I → Bomber II (enhanced payload and survivability)
- Transport I → Transport II (increased capacity and speed)
- Upgrade Cost: Requires research, manufacturing, and funding
- Veterancy Reset: Upgraded craft start at Level 1 with new base stats

## Related Wiki Pages

- [Stats.md](../crafts/Stats.md) - Stat bonuses from promotion ranks
- [Classes.md](../crafts/Classes.md) - Craft class promotion paths
- [Salaries.md](../crafts/Salaries.md) - Salary increases with promotion
- [Experience.md](../units/Experience.md) - Unit experience systems comparison
- [Promotion.md](../units/Promotion.md) - Unit promotion systems comparison
- [Crafts.md](../crafts/Crafts.md) - Main craft systems overview
- [Mission Detection and Assignment.md](../interception/Mission%20Detection%20and%20Assignment.md) - XP from missions
- [Air Battle.md](../interception/Air%20Battle.md) - Combat XP sources

## References to Existing Games and Mechanics

- **XCOM Series**: Craft veterancy and performance upgrades
- **Civilization Series**: Unit promotions and experience
- **Europa Universalis**: Naval unit experience and traditions
- **Crusader Kings**: Character progression and traits
- **Hearts of Iron**: Fleet experience and veterancy
- **Victoria Series**: Military unit experience systems
- **Stellaris**: Ship experience and admiral traits
- **Endless Space**: Fleet experience and upgrades
- **Galactic Civilizations**: Ship experience and promotions
- **Total War Series**: Unit experience and rank progression

