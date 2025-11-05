# AlienFall Game Design - Mechanics & Systems Table of Contents

> **Status**: Design Document
> **Last Updated**: 2025-11-02
> **Related Systems**: Battlescape.md, Basescape.md, Geoscape.md, Interception.md, Units.md, Items.md, Crafts.md, Economy.md, Missions.md, Research.md

## Table of Contents

- [AlienFall Game Design - Mechanics \& Systems Table of Contents](#alienfall-game-design---mechanics--systems-table-of-contents)
  - [Table of Contents](#table-of-contents)
  - [Executive Summary](#executive-summary)
    - [Three-Layer Architecture](#three-layer-architecture)
    - [Core Game Loop](#core-game-loop)
    - [Key Differentiators](#key-differentiators)
  - [Document Navigation](#document-navigation)
    - [Quick Reference by Layer](#quick-reference-by-layer)
    - [Priority Implementation Guide](#priority-implementation-guide)
  - [Version Information](#version-information)
  - [Alphabetical Index \& Keywords](#alphabetical-index--keywords)
  - [Cross-Reference Map](#cross-reference-map)
    - [System Dependencies](#system-dependencies)
    - [Related Mechanics](#related-mechanics)
  - [Missing Systems (To Be Implemented)](#missing-systems-to-be-implemented)
    - [Core Systems **\[P1-HIGH\]**](#core-systems-p1-high)
    - [Meta-Systems **\[P2-MEDIUM\]**](#meta-systems-p2-medium)
  - [Testing Scenarios Index](#testing-scenarios-index)
    - [Combat Testing **\[P0-CRITICAL\]**](#combat-testing-p0-critical)
    - [Economic Testing **\[P1-HIGH\]**](#economic-testing-p1-high)
    - [Progression Testing **\[P1-HIGH\]**](#progression-testing-p1-high)
    - [System Integration Testing **\[P2-MEDIUM\]**](#system-integration-testing-p2-medium)
  - [Basescape **\[P0-CRITICAL\]**](#basescape-p0-critical)
    - [Basescape GUI **\[P1-HIGH\]**](#basescape-gui-p1-high)
    - [Build new base **\[P1-HIGH\]**](#build-new-base-p1-high)
    - [Base management **\[P0-CRITICAL\]**](#base-management-p0-critical)
    - [Base expansion **\[P1-HIGH\]**](#base-expansion-p1-high)
    - [Facilities **\[P0-CRITICAL\]**](#facilities-p0-critical)
      - [Damage Types System (Canonical Reference) **\[P0-CRITICAL\]**](#damage-types-system-canonical-reference-p0-critical)
        - [Damage Type Overview **\[P0-CRITICAL\]**](#damage-type-overview-p0-critical)
        - [Kinetic Damage **\[P0-CRITICAL\]**](#kinetic-damage-p0-critical)
        - [Explosive Damage **\[P0-CRITICAL\]**](#explosive-damage-p0-critical)
        - [Energy Damage **\[P0-CRITICAL\]**](#energy-damage-p0-critical)
        - [Psionic Damage **\[P1-HIGH\]**](#psionic-damage-p1-high)
        - [Stun Damage **\[P1-HIGH\]**](#stun-damage-p1-high)
        - [Acid Damage **\[P1-HIGH\]**](#acid-damage-p1-high)
        - [Fire Damage **\[P1-HIGH\]**](#fire-damage-p1-high)
        - [Frost Damage **\[P1-HIGH\]**](#frost-damage-p1-high)
        - [Armor Materials Reference **\[P1-HIGH\]**](#armor-materials-reference-p1-high)
        - [Shield Mechanics **\[P1-HIGH\]**](#shield-mechanics-p1-high)
        - [Damage Calculation Formula **\[P0-CRITICAL\]**](#damage-calculation-formula-p0-critical)
    - [Services](#services)
    - [Power](#power)
    - [Capacities](#capacities)
    - [Defences](#defences)
    - [Unit \& Craft recovery](#unit--craft-recovery)
    - [Pilot System](#pilot-system)
    - [Unit Classification \& Progression](#unit-classification--progression)
  - [Psychological Systems (Comprehensive - Bravery, Morale, Sanity) **\[P0-CRITICAL\]**](#psychological-systems-comprehensive---bravery-morale-sanity-p0-critical)
        - [Bravery Stat (Foundation) **\[P0-CRITICAL\]**](#bravery-stat-foundation-p0-critical)
        - [Morale System (In-Battle) **\[P0-CRITICAL\]**](#morale-system-in-battle-p0-critical)
        - [Sanity System (Post-Mission) **\[P0-CRITICAL\]**](#sanity-system-post-mission-p0-critical)
      - [Unit Rank \& Specialization System (Detailed)](#unit-rank--specialization-system-detailed)
      - [Expanded Traits \& Perks System (Advanced) **\[P1-HIGH\]**](#expanded-traits--perks-system-advanced-p1-high)
        - [Trait Categories (Comprehensive)](#trait-categories-comprehensive)
        - [Trait Mechanics (Expanded)](#trait-mechanics-expanded)
        - [Perk System (Advancement-Based)](#perk-system-advancement-based)
        - [Trait Interactions (Advanced)](#trait-interactions-advanced)
        - [Legacy System (Trait Persistence)](#legacy-system-trait-persistence)
    - [Prisoner System](#prisoner-system)
    - [Economy **\[P0-CRITICAL\]**](#economy-p0-critical)
      - [Black Market **\[P2-MEDIUM\]**](#black-market-p2-medium)
      - [Marketplace](#marketplace)
      - [Research](#research)
      - [Manufacturing](#manufacturing)
    - [Transfers](#transfers)
    - [Suppliers](#suppliers)
      - [Marketplace \& Trading](#marketplace--trading)
    - [Finance](#finance)
    - [Score \& Funding](#score--funding)
    - [Budget](#budget)
  - [Geoscape **\[P0-CRITICAL\]**](#geoscape-p0-critical)
    - [Geoscape GUI **\[P1-HIGH\]**](#geoscape-gui-p1-high)
  - [Interception **\[P1-HIGH\]**](#interception-p1-high)
    - [Interception GUI **\[P2-MEDIUM\]**](#interception-gui-p2-medium)
    - [3 Sectors \& 2 sides](#3-sectors--2-sides)
    - [Combat Mechanics](#combat-mechanics)
    - [Weapon System](#weapon-system)
    - [Weapon Mechanics (Detailed)](#weapon-mechanics-detailed)
    - [Entities](#entities)
    - [Entity Health System](#entity-health-system)
    - [Outcomes](#outcomes)
    - [Interception Weapon Mechanics](#interception-weapon-mechanics)
    - [Base damage](#base-damage)
  - [Battlescape **\[P0-CRITICAL\]**](#battlescape-p0-critical)
    - [BattleScape GUI **\[P1-HIGH\]**](#battlescape-gui-p1-high)
    - [Battle Structure \& Team System (Advanced)](#battle-structure--team-system-advanced)
    - [Battle 3D](#battle-3d)
    - [Battle scape](#battle-scape)
    - [Battle generation](#battle-generation)
    - [Battle mission](#battle-mission)
    - [Battle objective](#battle-objective)
    - [Battle enemy squad](#battle-enemy-squad)
    - [Enemy AI](#enemy-ai)
    - [Battle planning](#battle-planning)
    - [Battle combat rules](#battle-combat-rules)
      - [accuracy to hit](#accuracy-to-hit)
      - [damage calculation](#damage-calculation)
      - [Melee Combat (Detailed)](#melee-combat-detailed)
      - [Projectile Physics (Detailed)](#projectile-physics-detailed)
      - [Explosion Mechanics (Detailed)](#explosion-mechanics-detailed)
      - [Initiative \& Turn Order (Detailed)](#initiative--turn-order-detailed)
      - [3D Perspective Integration](#3d-perspective-integration)
      - [3D Battlescape Integration](#3d-battlescape-integration)
      - [3D First-Person Camera System](#3d-first-person-camera-system)
      - [Hex Coordinate System (Technical Specification)](#hex-coordinate-system-technical-specification)
      - [unit actions](#unit-actions)
      - [unit status effects](#unit-status-effects)
      - [Battle salvage](#battle-salvage)
      - [Battle enviroment](#battle-enviroment)
      - [Battle damage \& accuracy](#battle-damage--accuracy)
      - [Hex Coordinate System](#hex-coordinate-system)
      - [Map Block System](#map-block-system)
      - [Map Generation Pipeline (Complete)](#map-generation-pipeline-complete)
      - [Coordinate Calculations](#coordinate-calculations)
      - [Damage \& Resistance System](#damage--resistance-system)
      - [Consciousness \& Identity System](#consciousness--identity-system)
      - [Temporal Mechanics (Advanced)](#temporal-mechanics-advanced)
      - [Interception Combat System (Detailed - Advanced)](#interception-combat-system-detailed---advanced)
      - [Environmental](#environmental)
      - [Advanced Environment, Terrain \& Weather System (Expanded)](#advanced-environment-terrain--weather-system-expanded)
      - [Special Environments \& Unique Biomes (Advanced)](#special-environments--unique-biomes-advanced)
      - [Historical Background System (1815-1995)](#historical-background-system-1815-1995)
      - [Campaign Phase System (Phase 0-5)](#campaign-phase-system-phase-0-5)
      - [Temporal Loop System](#temporal-loop-system)
      - [Narrative Themes \& Messaging System](#narrative-themes--messaging-system)
      - [Finance \& Score System](#finance--score-system)
      - [System Dependencies \& Coupling](#system-dependencies--coupling)
      - [Craft Operations](#craft-operations)
      - [Mission Operations](#mission-operations)
      - [Unit Operations](#unit-operations)
      - [Strategic AI (Geoscape)](#strategic-ai-geoscape)
      - [Diplomatic AI (Geoscape)](#diplomatic-ai-geoscape)
      - [Interception AI (Interception)](#interception-ai-interception)
      - [Tactical AI (Battlescape)](#tactical-ai-battlescape)
      - [Economic AI (Basescape)](#economic-ai-basescape)
      - [Character Archetype System](#character-archetype-system)
      - [Advanced Mission Generation System](#advanced-mission-generation-system)
      - [Analytics](#analytics)
      - [Test Scenarios \& QA Framework (Comprehensive)](#test-scenarios--qa-framework-comprehensive)
      - [Implementation \& Technical Standards (Guidelines)](#implementation--technical-standards-guidelines)
      - [Performance \& Optimization](#performance--optimization)
      - [Rendering System](#rendering-system)
      - [Assets \& Resource Pipeline](#assets--resource-pipeline)
      - [Technology Specifications (Lore-Tied)](#technology-specifications-lore-tied)
      - [Assets](#assets)
      - [Philosophical Framework Reference](#philosophical-framework-reference)
      - [GUI System Reference](#gui-system-reference)
      - [Character Database \& Reference](#character-database--reference)
      - [Knowledge Base](#knowledge-base)
  - [Experimental and Aspirational Systems](#experimental-and-aspirational-systems)
      - [Mid-Game Engagement](#mid-game-engagement)
      - [Environmental \& Seasonal Systems](#environmental--seasonal-systems)
      - [Advanced Unit Psychology](#advanced-unit-psychology)
      - [Cross-System Synergies](#cross-system-synergies)
      - [Multiplayer \& Cooperative Play](#multiplayer--cooperative-play)
      - [Procedural Content Generation](#procedural-content-generation)
      - [Modular Ruleset System](#modular-ruleset-system)
      - [Narrative \& Moral Complexity](#narrative--moral-complexity)
      - [Quality of Life \& Accessibility](#quality-of-life--accessibility)
      - [Experimental Game Modes](#experimental-game-modes)
      - [Visual Design Language System](#visual-design-language-system)
      - [Content Discovery Mechanics](#content-discovery-mechanics)
      - [Truth Revelation Layers](#truth-revelation-layers)
  - [Lore Information Systems](#lore-information-systems)

---

## Executive Summary

**AlienFall** is a turn-based strategy game inspired by X-COM, featuring a three-layer architecture that creates deep strategic and tactical gameplay:

### Three-Layer Architecture

1. **Geoscape (Strategic Layer)**: Global world map with UFO detection, base management, and resource allocation
2. **Basescape (Operational Layer)**: Facility construction, research, manufacturing, and personnel management
3. **Battlescape (Tactical Layer)**: Turn-based hex combat with squad-level tactics and psychological systems

### Core Game Loop
```
Strategic Planning → Mission Deployment → Tactical Combat → Resource Management → Repeat
```

### Key Differentiators
- **Psychological Systems**: Bravery, Morale, and Sanity mechanics affect unit performance and campaign progression
- **Damage Type Complexity**: 8 damage types with unique armor interactions and environmental effects
- **Unit Progression**: Deep specialization system with traits, perks, and multi-path advancement
- **Economic Depth**: Dynamic marketplace, research trees, and resource management

---

## Document Navigation

### Quick Reference by Layer
- **[Basescape](#basescape)**: Base management, economy, research, manufacturing
- **[Geoscape](#geoscape)**: World map, countries, crafts, interception
- **[Battlescape](#battlescape)**: Combat mechanics, 3D systems, hex coordinates
- **[Interception](#interception)**: Air/space combat systems

### Priority Implementation Guide
- **[P0-CRITICAL]**: Core gameplay systems (Combat, Movement, UI)
- **[P1-HIGH]**: Essential features (Save/Load, Tutorial, Basic AI)
- **[P2-MEDIUM]**: Advanced features (Multiplayer, Modding, Advanced AI)
- **[P3-LOW]**: Polish and edge cases (Accessibility, Performance optimization)

---

## Version Information
- **Version**: 1.0
- **Last Updated**: November 2, 2025
- **Authors**: Game Design Team
- **Status**: Active Development

---

## Alphabetical Index & Keywords

**A**: Accuracy, Action Points, AI, Alien Technology, Armor, Accessibility
**B**: Basescape, Battlescape, Bravery, Budget
**C**: Combat, Cover, Crafts, Critical Hits, Cross-References
**D**: Damage Types, Debug Tools, Difficulty Scaling
**E**: Economy, Error Handling, Experience
**F**: Facilities, Fuel, Fog of War
**G**: Geoscape, Grenades
**H**: Health, Hex Coordinates, HUD
**I**: Initiative, Interception, Items
**L**: Line of Sight, Load/Save
**M**: Manufacturing, Melee, Missions, Modding, Morale, Movement, Multiplayer
**O**: Objectives, Onboarding
**P**: Performance, Perks, Pilots, Portals, Priority Levels, Progression, Psychological Systems
**R**: Radar, Range, Research, Resources
**S**: Sanity, Save/Load, Search/Indexing, Stealth, Status Effects
**T**: Tactics, Terrain, Testing, Traits, Tutorial, Turn Order
**U**: UFO, Unit Progression, Upgrades
**V**: Version Control, Victory Conditions
**W**: Weather, Weapons, World Map

---

## Cross-Reference Map

### System Dependencies
- **Damage Types** → See Battlescape Combat Rules, Armor Mechanics
- **Psychological Systems** → See Unit Progression, Combat Mechanics
- **Traits & Perks** → See Unit Classification, Experience Systems
- **Economy** → See Manufacturing, Research, Marketplace
- **Hex Coordinates** → See Battlescape Map Generation, Movement

### Related Mechanics
- **Line of Sight** ↔ **Cover System** ↔ **Accuracy Calculations**
- **Morale** ↔ **Bravery** ↔ **Sanity** ↔ **Combat Effectiveness**
- **Research** ↔ **Manufacturing** ↔ **Equipment Availability**
- **Fuel** ↔ **Range** ↔ **Craft Movement** ↔ **Mission Planning**

---

## Missing Systems (To Be Implemented)

### Core Systems **[P1-HIGH]**
- **Save/Load System**: Persistent game state across sessions
  - JSON-based save format with compression
  - Auto-save every 5 minutes, manual saves unlimited
  - Load validation and corruption recovery
  - Save file size optimization (< 50MB typical campaign)
- **Tutorial/Onboarding**: Progressive learning system for complex mechanics
  - Interactive tutorials for each layer (Geoscape/Basescape/Battlescape)
  - Context-sensitive help system
  - Skip options for experienced players
  - Achievement-based tutorial progression
- **Multiplayer/Co-op**: Framework for multiple human players **[P3-LOW]**
  - Turn-based multiplayer architecture
  - Shared basescape management
  - Independent battlescape deployment
  - Spectator mode for additional players
- **Modding API**: Technical specifications for content creation **[P2-MEDIUM]**
  - TOML-based content definition schema
  - Lua scripting hooks for custom mechanics
  - Asset pipeline for custom sprites/audio
  - Mod validation and dependency management
- **Accessibility Features**: Inclusive design for all players **[P2-MEDIUM]**
  - Full keyboard navigation support
  - High contrast mode and colorblind palettes
  - Screen reader compatibility
  - Adjustable text sizes and UI scaling
  - Customizable control schemes

### Meta-Systems **[P2-MEDIUM]**
- **Performance Optimization**: System performance requirements and monitoring
  - Target 60 FPS on minimum hardware
  - Memory usage < 2GB during battles
  - Load times < 30 seconds for large maps
  - Background processing for heavy calculations
- **Error Handling**: Graceful failure modes and recovery procedures
  - Invalid state detection and correction
  - Fallback UI for missing assets
  - Network timeout handling
  - Corrupted save recovery
- **Debug Tools**: Development aids for testing complex interactions **[P2-MEDIUM]**
  - Console commands for state manipulation
  - Performance profiling tools
  - Unit stat editors for testing
  - Mission replay functionality

---



## Testing Scenarios Index

### Combat Testing **[P0-CRITICAL]**
- **Basic Accuracy Test**: Rifle at 10 hexes, clear LOS, no cover
  - Expected: 65-75% hit chance (base 70% - 15% long range = 55%, +10% aimed = 65%)
- **Damage Type Interactions**: Test all 8 damage types vs 5 armor types
  - Expected: Psi ignores armor, Energy weak vs Heavy, Kinetic strong vs Light
- **Psychological Effects**: Unit with Morale 2 (Shaken) firing weapon
  - Expected: -30% accuracy penalty, -2 AP penalty
- **Cover System**: Unit behind heavy cover, enemy at 5 hexes
  - Expected: -30% accuracy penalty, 75% LOS block

### Economic Testing **[P1-HIGH]**
- **Market Fluctuations**: Purchase item, wait 7 days, check price change
  - Expected: ±15% price variation based on supply/demand
- **Research Dependencies**: Attempt to research advanced weapon without prerequisites
  - Expected: Research blocked, clear error message
- **Manufacturing Queues**: Queue 5 items, check production timing
  - Expected: Sequential completion, resource consumption per item

### Progression Testing **[P1-HIGH]**
- **Unit Advancement**: Rookie gains 300 XP from mission
  - Expected: Promotion to Rank 2, specialization choice offered
- **Trait Synergies**: Unit with "Fearless" and "Leader" traits
  - Expected: +35% leadership effectiveness (25% + 10% synergy)
- **Rank Limitations**: Attempt to add 7th Rank 5 unit to squad
  - Expected: Addition blocked, "Squad depth exceeded" message

### System Integration Testing **[P2-MEDIUM]**
- **Cross-Layer Data Flow**: Complete mission, return to geoscape
  - Expected: XP applied, resources gained, panic updated
- **Save/Load State**: Save mid-battle, load, resume combat
  - Expected: All unit positions, health, AP preserved
- **Mod Loading**: Load custom unit mod, spawn in battle
  - Expected: Custom stats applied, no validation errors

---



## Basescape **[P0-CRITICAL]**

### Basescape GUI **[P1-HIGH]**
- Interface Layout
- Screen Navigation
- Information Display

### Build new base **[P1-HIGH]**
- Site Selection
- Construction Requirements
- Cost & Time
- Permission Requirements

### Base management **[P0-CRITICAL]**
- Facility Placement
- Resource Management
- Personnel Assignment
- Operational Status

### Base expansion **[P1-HIGH]**
- Expansion Requirements
- Size Progression
- Expansion Timeline

### Facilities **[P0-CRITICAL]**
- Facility Grid Structure
- Facility Types & Functions
- Construction Mechanics
- Facility Upgrades
- Underground Facilities

#### Damage Types System (Canonical Reference) **[P0-CRITICAL]**
**See Also:** Battlescape Combat Rules, Armor Mechanics, Weapon Systems

##### Damage Type Overview **[P0-CRITICAL]**
- 8 Core Types
- Armor Interactions
- Weapon Examples

##### Kinetic Damage **[P0-CRITICAL]**
- Source & Description
- Armor Resistance
  - Light Armor: 50%
  - Medium Armor: 30%
  - Heavy Armor: 10%
  - Reinforced: 25%
  - Alien Tech: 15%
- Weapon Examples
- Special Mechanics

##### Explosive Damage **[P0-CRITICAL]**
- Source & Description
- Armor Resistance
- Wave Propagation
  - Direction-Based Spreading
  - Wall Blocking (100%)
  - Unit Reduction (50%)
  - Distance Scaling
- Weapon Examples
- Special Mechanics

##### Energy Damage **[P0-CRITICAL]**
- Source & Description
- Armor Resistance
  - Light: 20%
  - Medium: 40%
  - Heavy: 60%
- Shield Priority
- Weapon Examples

##### Psionic Damage **[P1-HIGH]**
- Source & Description
- Armor Bypass
- Armor Resistance: 0%
- Psi Shield Resistance: 80%
- Weapon Examples

##### Stun Damage **[P1-HIGH]**
- Source & Description
- Armor Resistance
- Status Application
- Weapon Examples

##### Acid Damage **[P1-HIGH]**
- Source & Description
- Armor Resistance
- Corrosion Status
- Weapon Examples

##### Fire Damage **[P1-HIGH]**
- Source & Description
- Armor Resistance
- Burning Status
- Weapon Examples

##### Frost Damage **[P1-HIGH]**
- Source & Description
- Armor Resistance
- Frozen Status
- Weapon Examples

##### Armor Materials Reference **[P1-HIGH]**
- Material Types
  - Wood
  - Stone
  - Metal
  - Glass
  - Concrete
  - Vegetation
- HP Values
- Fire Behavior
- Explosive Resistance
- Bullet Resistance

##### Shield Mechanics **[P1-HIGH]**
- Standard Shield
- Advanced Shield
- Alien Shield
- Shield Priority (absorbs first)
- Remaining Damage to Health

##### Damage Calculation Formula **[P0-CRITICAL]**
**Mathematical Formula:**
```
Final Damage = Base Damage × Armor Reduction × Type Modifier × Status Effects
```

**Step-by-Step Calculation:**
1. **Roll Base Damage**: Weapon_Base ± Variance (typically ±20%)
2. **Armor Reduction**: `Reduction% = (Armor × 1.1) / (Armor × 1.1 + Damage)`
3. **Type Modifier**: Damage type vs armor type effectiveness
4. **Status Effects**: Environmental or unit status modifiers

**Example**: Rifle (Base 45) vs Medium Armor (50) = 45 × 0.45 = 20 damage

**Test Cases:**
- **Kinetic vs Light Armor**: 50 damage → 25 damage (50% reduction)
- **Energy vs Heavy Armor**: 40 damage → 16 damage (60% reduction)
- **Psi vs Any Armor**: 35 damage → 35 damage (0% reduction)

- Base Damage
- Armor Reduction
- Modifiers
- Critical Hit

### Services
- Medical Services
- Training Services
- Research Support
- Maintenance Services

### Power
- Power Generation
  - Power Plant Types
  - Solar Panels
  - Generators
- Power Demand
  - Per-Facility Consumption
  - Total Demand Calculation
- Priority Tier System
  - Tier 1 (Critical)
  - Tier 2 (High)
  - Tier 3-7 (Medium)
  - Tier 8-10 (Low)
- Shortage Handling
  - Cascading Failures
  - Recovery Protocol

### Capacities
- Unit Capacity
- Item Storage Capacity
- Research Queue Capacity
- Manufacturing Queue Capacity

### Defences
- Defense Structures
- Defense Rating Calculation
- Defense Effectiveness
- Damage Resistance

### Unit & Craft recovery
- Medical Recovery
- Wound Treatment
- Craft Repair Timeline
- Personnel Readiness

### Pilot System
- Pilot Role Assignment
  - Assigned as Pilot
  - Assigned as Crew
  - Unassigned Status
- Piloting Stat
  - Core Stat Definition
  - Improvement Sources
  - Experience Integration
- Pilot Bonuses
  - Bonus Formula
  - Craft Dodge Calculation
  - Craft Accuracy Calculation
  - Special Abilities Unlock
- Experience System
  - Unified XP Pool
  - Progression Example

### Unit Classification & Progression
- Class System
  - Class Hierarchy
  - Class Requirements
  - Class Transitions
- Unit Specializations
  - Specialist Roles
  - Role-Specific Abilities
  - Specialization Bonuses
- Unit Transformations
  - Transformation Conditions
  - Transformation Effects
  - Reverse Transformation
- Class Upgrade Paths
  - Upgrade Requirements
  - Multi-Path Progression
  - Cap Mechanics
- Equipment & Personnel
  - Unit Recruitment
    - Recruitment Sources
    - Cost & Time
    - Quality Variation
  - Unit Classification System
    - Rank Structure (Rank 0-6)
    - Class Hierarchy
    - Progression Requirements
    - Rank Limits by Squad Depth
  - Unit Type Classification
    - Biological Units
    - Mechanical Units
    - Maintenance Requirements
  - Standard Recruitment
    - Marketplace Recruitment
    - Specialist Recruitment Tiers
    - Recruitment Constraints
  - Unit Statistics
    - Core Stat Range (6-12)
    - Stat Distribution Mechanics
  - Experience & Progression
    - Experience Acquisition Sources
    - Base Training System
    - Combat Experience Formula
    - Mission Objectives XP
    - Medals & Commendations System
  - Rank Promotion
    - Promotion Mechanic
    - Specialization Path Choices
    - Promotion Tree Branching
    - Class Requirements for Equipment
  - Demotion System
    - Demotion Requirements
    - Demotion Cost & Time
    - Experience Retention (Proportional Scaling)
    - Re-specialization Options
    - Equipment Compatibility Handling
  - Unit Maintenance
    - Salary Costs
    - Equipment Maintenance
    - Supply Management
  - Specialization & Advancement
    - Experience Tracking
    - Rank Requirements
    - Specialization Choice

## Psychological Systems (Comprehensive - Bravery, Morale, Sanity) **[P0-CRITICAL]**
**See Also:** Unit Progression, Combat Mechanics, Mission Objectives

##### Bravery Stat (Foundation) **[P0-CRITICAL]**
- Definition & Range
  - Range 6-12
  - Average Values
  - Low Values
  - High Values
- Base Bravery by Type
  - Conscript
  - Soldier
  - Veteran
  - Elite
  - Hero
  - Alien Types
  - Mechanical Units
- Bravery Modifiers **[P1-HIGH]**
  - Trait Effects
  - Experience-Based
  - Equipment-Based
  - Temporary Mission Modifiers
  - Leader Presence
- Bravery Impact on Combat **[P0-CRITICAL]**
  - Morale Pool
  - Panic Resistance
  - Leadership Aura
  - Psionic Defense

##### Morale System (In-Battle) **[P0-CRITICAL]**
- Morale Definition
- Starting Morale
- Morale Range (0-12)
- Morale Loss Events (Detailed) **[P1-HIGH]**
  - Ally Death Witness
  - Damage Taken
  - Critical Hit Received
  - Flanking Condition
  - Outnumbered Condition
  - Alien Revelation
  - Horror Missions
  - Commander Death
  - Critical Miss
- Morale Thresholds (7 Levels) **[P0-CRITICAL]**
  - **Test Cases:**
    - **Confident Unit (Morale 10)**: +0% penalties, full effectiveness
    - **Panicking Unit (Morale 1)**: -50% accuracy, limited actions
    - **Panic Mode (Morale 0)**: All AP lost, flee/surrender chance
  - Level 6-12: Confident
    - Status Effects
    - AP Penalty
    - Accuracy Penalty
    - Behavior
  - Level 5: Steady
    - Status Effects
    - AP Penalty
    - Accuracy Penalty
    - Behavior
  - Level 4: Nervous
    - Status Effects
    - AP Penalty
    - Accuracy Penalty
    - Behavior
  - Level 3: Stressed
    - Status Effects
    - AP Penalty
    - Accuracy Penalty
    - Behavior
  - Level 2: Shaken
    - Status Effects
    - AP Penalty
    - Accuracy Penalty
    - Behavior
  - Level 1: Panicking
    - Status Effects
    - AP Penalty
    - Accuracy Penalty
    - Behavior
  - Level 0: Panic Mode
    - All AP Lost
    - Accuracy Penalty (-50%)
    - Flee Chance
    - Weapon Drop Chance
    - Surrender Possibility
- Panic Recovery **[P1-HIGH]**
  - Rest Action Cost
  - Morale Recovery Amount
  - Frequency Limitation
- Leader Rally Mechanic **[P1-HIGH]**
  - Rally Cost (4 AP)
  - Morale Restoration (+2)
  - Range (5 hexes)
  - Cooldown
- Leader Aura System **[P1-HIGH]**
  - Aura Range (8 hexes)
  - Passive Morale Bonus
  - Leader Requirements
  - Multiple Leader Rules
- Victory Momentum **[P2-MEDIUM]**
  - Kill Bonus
  - Mission Success Bonus
  - Squad Survival Bonus
- Mechanical Units **[P1-HIGH]**
  - Immunity to Morale
  - No Panic Mechanics
  - Always 12 Morale

##### Sanity System (Post-Mission) **[P0-CRITICAL]**
- Sanity Definition
- Sanity Range (6-12)
- Base Sanity by Type
- Sanity Loss Events **[P1-HIGH]**
  - Standard Mission
  - Moderate Mission
  - Hard Mission
  - Horror Mission
  - Additional Loss Factors
- Sanity Recovery **[P1-HIGH]**
  - Rest Between Missions
  - Facility Recovery
  - Medical Treatment
  - Psychological Support
- Sanity Consequences **[P0-CRITICAL]**
  - Low Sanity Effects
  - Behavioral Changes
  - Combat Penalties
  - Mission Restrictions

#### Unit Rank & Specialization System (Detailed)
- Rank Structure (0-6)
  - Rank 0: Basic/Conscript
    - XP Required: 0
    - Description
    - Limitations
  - Rank 1: Agent
    - XP Required: 200
    - Description
    - Role Assignment
  - Rank 2: Specialist
    - XP Required: 500
    - Description
    - Specialization Choice
  - Rank 3: Expert
    - XP Required: 900
    - Description
    - Advanced Training
  - Rank 4: Master
    - XP Required: 1500
    - Description
    - Refinement
  - Rank 5: Elite
    - XP Required: 2500
    - Description
    - Rarity
  - Rank 6: Hero
    - XP Required: 4500
    - Description
    - Squad Limit: 1 per player
- Class Hierarchy (Rank Progression)
  - Tier 1: Base Unit
    - Conscript Examples
    - Limited Options
  - Tier 2: Role Assignment (Rank 1)
    - Soldier Path
      - Rifleman
      - Grenadier
      - Gunner
    - Support Path
      - Medic
      - Engineer
      - Technician
    - Leader Path
      - Sergeant
      - Lieutenant
      - Commander
    - Scout Path
      - Infiltrator
      - Tracker
      - Spotter
    - Specialist Path
      - Hacker
      - Scientist
      - Analyst
    - Pilot Path
      - Fighter Pilot
      - Bomber Pilot
      - Transport Pilot
  - Tier 3+: Advanced Specialization
    - Rank 3 Advanced Training
    - Rank 4 Refinement
    - Rank 5 Mastery
    - Rank 6 Hero Status
- Specialization Mechanics
  - Branching Paths
    - Decision Points
    - Path Locking
    - No Respec
  - Stat Scaling
    - Primary Stats
    - Secondary Stats
    - Specialization Bonuses
  - Ability Unlocks
    - Specialization Abilities
    - Rank-Based Abilities
    - Rank 5+ Unique Abilities
- Squad Depth Constraints
  - Rank Limitations
    - Rank 0: Unlimited
    - Rank 1: Unlimited
    - Rank 2: Min 3 Rank 1
    - Rank 3: Min 3 Rank 2
    - Rank 4: Min 3 Rank 3
    - Rank 5: Min 3 Rank 4
    - Rank 6: Min 3 Rank 5 + Squad Limit 1
- Promotion Requirements
  - Experience Gates
  - Facility Requirements
  - Research Prerequisites
  - Training Duration
- Class Synergy
  - Equipment Bonuses
    - Class Matching
    - +50% Effectiveness
  - Cross-Class Usage
    - Accuracy Penalty: -30%
    - Ability Scaling
  - Specialization Benefits
    - Focused Training
    - Role Mastery
    - Unique Bonuses

#### Expanded Traits & Perks System (Advanced) **[P1-HIGH]**
**Balance Math**: Traits provide ±15-25% modifiers, Perks unlock at Rank 2+, max 3 active perks

##### Trait Categories (Comprehensive)
- Positive Traits (15+)
  - Quick Learner
    - XP Gain: +20%
    - Combat: +1 initiative
  - Fearless
    - Morale: +25%
    - Panic Threshold: +30
  - Leader
    - Squad Morale: +10%
    - Follower XP: +10%
  - Sharpshooter
    - Accuracy: +10%
    - Critical Chance: +5%
  - Combat Medic
    - Healing: +50%
    - Support Range: +2 hexes
  - Loyal
  - Noble
  - Resourceful
  - Additional Positive Traits (7+)
- Negative Traits (15+)
  - Slow Learner
    - XP Gain: -20%
    - Combat: -1 initiative
  - Coward
    - Morale: -25%
    - Panic Threshold: -30
  - Loner
    - Squad Morale: -10%
    - Leadership Immunity
  - Clumsy
    - Accuracy: -10%
    - Movement: -1 hex/turn
  - Fragile
    - Health: -15%
    - Wound Duration: +50%
  - Disloyal
  - Cynical
  - Reckless
  - Additional Negative Traits (7+)
- Neutral Traits (10+)
  - Pragmatic
    - Cost Reduction: +5%
    - Bonus Research: context-dependent
  - Curious
    - Discovery Chance: +20%
    - Hidden Content: easier to find
  - Disciplined
    - Supplies: -10% consumption
    - Efficiency: +5%
  - Stubborn
    - Resistance: +20%
    - Flexibility: -20%
  - Additional Neutral Traits (6+)

##### Trait Mechanics (Expanded)
- Trait Assignment
  - Random Generation
    - Trait Pool Selection
    - Probability Distribution
    - Rarity Weighting
  - Player Selection
    - Trait Point Budget
    - Point Allocation
    - Restriction Rules
  - Trait Pools
    - Starter Pool
    - Advanced Pool
    - Rare Pool
    - Legendary Pool
- Stat Modifications
  - Direct Bonuses/Penalties
    - Flat +/- values
    - Application Rules
    - Stacking Limits
  - Multiplicative Effects
    - Percentage Modifiers
    - Order of Operations
    - Interaction Rules
  - Interaction Rules
    - Trait Synergy
    - Trait Conflicts
    - Multi-Trait Stacking

##### Perk System (Advancement-Based)
- Perk Categories
  - Combat Perks
    - Weapon Mastery (Rifles, Pistols, etc.)
    - Armor Proficiency
    - Melee Specialization
    - Tactical Movement
  - Technical Perks
    - Engineering Expertise
    - Hacking Proficiency
    - Demolition Expert
    - Computer Specialist
  - Social Perks
    - Charisma Enhancement
    - Intimidation Specialist
    - Negotiator
    - Charmer
  - Support Perks
    - Medical Training
    - Support Specialist
    - Leadership Aura
    - Morale Booster
- Perk Acquisition
  - Unlock Conditions
    - Experience Thresholds
    - Rank Requirements
    - Combat Achievements
    - Training Completion
  - Experience Requirements
    - Base XP Cost
    - Scaling by Rank
    - Specialization Modifiers
  - Choice Points
    - Perk Selection Menu
    - Available Options
    - Exclusivity Rules

##### Trait Interactions (Advanced)
- Synergies (Positive Combinations)
  - Fearless + Leader: Leadership+20% effectiveness
  - Quick Learner + Sharpshooter: Weapon XP +30%
  - Combat Medic + Loyal: Team healing +25%
  - Disciplined + Pragmatic: Supply efficiency +20%
  - Details per combination (10+)
- Conflicts (Negative Combinations)
  - Coward + Leader: Leadership disabled
  - Clumsy + Sharpshooter: Accuracy cancels out
  - Loner + Noble: Bonus effects negated
  - Reckless + Disciplined: Conflicting effects
  - Details per conflict (10+)
- Interaction Rules
  - Priority System
  - Resolution Order
  - Override Mechanics
  - Magnitude Limits

##### Legacy System (Trait Persistence)
- Trait Persistence
  - Death Effects: Traits persist on units
  - Resurrection Impact: Traits unchanged
  - New Game+ Carryover: Trait knowledge retained
- Advanced Trait Options
  - Trait Mutation: Traits can change
  - Trait Combination: New traits from combinations
  - Temporal Traits: Time-loop-aware traits
  - Hidden Traits: Developer easter egg traits

### Prisoner System
- Prisoner Capture & Detention
  - Capture Mechanics
  - Detention Facility
  - Prisoner Status
- Prison Capacity
  - Cell Limits
  - Overflow Handling
  - Escape Chances
- Prisoner Options
  - Execution
  - Interrogation
  - Experimentation
  - Exchange
  - Conversion
  - Release
- Interrogation & Research
  - Information Extraction
  - Research Yield
  - Faction Intelligence
- Prisoner Lifecycle
  - Lifetime Duration
  - Recovery Rates
  - Processing

### Economy **[P0-CRITICAL]**
**Balance Philosophy**: Intentional scarcity - monthly expenses exceed income by 20-30%

#### Black Market **[P2-MEDIUM]**
- Access Requirements
  - Karma Threshold
  - Fame Requirement
  - Entry Fee
- Access Tiers
  - Restricted Tier
  - Standard Tier
  - Enhanced Tier
  - Complete Tier
- Black Market Categories
  - Experimental Items
  - Restricted Units
  - Illegal Missions
  - Corpse Trading
  - Event Purchasing

#### Marketplace
- Pricing Mechanics
  - Base Price System
  - Price Fluctuation
  - Supply & Demand
- Price Modifiers
  - Reputation Discount
  - Inflation & Deflation
  - Rarity Multipliers
  - Bulk Discounts
- Supplier Categories
  - Military Supply
  - Syndicate Trade
  - Exotic Arms
  - Research Materials
  - Tactical Network
- Item Availability
  - Research Gates
  - Regional Restrictions
  - Supplier Stock
  - Seasonal Variations

#### Research
- Research Facility & Capacity
  - Laboratory Size
  - Scientist Allocation
  - Research Speed
- Technology Tree (5 Branches)
  - Weapons Technology
  - Armor & Defense
  - Alien Technology
  - Facilities & Infrastructure
  - Support Systems
- Prerequisites & Dependencies
  - Linear Progression
  - Cross-Branch Gates
  - Unlock Chains
- Research Time & Cost
  - Base Research Time
  - Complexity Multiplier
  - Resource Requirements
- Scientist Allocation
  - Active Scientists
  - Efficiency Scaling
  - Specialization Bonuses
- Research System (Detailed)
  - Research Facility Management
    - Laboratory Types
    - Facility Upgrades
    - Scientist Assignment
    - Research Efficiency
  - Research Mechanics
    - Research Time Calculation
    - Resource Consumption
    - Breakthrough Conditions
    - Setback Mechanics
  - Research Queue
    - Queue Management
    - Priority Ordering
    - Parallel Research
    - Cancellation Rules

#### Manufacturing
- Production Facilities
  - Workshop Size
  - Production Speed
  - Upgrade Options
- Manufacturing Constraints
  - Technology Requirements
  - Resource Availability
  - Facility Capacity
  - Time Requirements
- Equipment Types
  - Weapons Manufacturing
  - Armor Production
  - Consumables
  - Craft Addons
- Crafting Chains
  - Component Requirements
  - Material Synthesis
  - Multi-Step Production
- Queue Management
  - Priority Ordering
  - Batch Processing
  - Production Tracking
- Manufacturing System (Detailed)
  - Manufacturing Facility
    - Workshop Types
    - Facility Upgrades
    - Production Capacity
    - Output Quality
  - Manufacturing Chains (Expanded)
    - Component Requirements
    - Material Sourcing
    - Multi-Step Chains
    - Crafting Sequences
  - Production Management
    - Queue System
    - Batch Processing
    - Priority Rules
    - Production Timeline
  - Manufacturing Constraints (Expanded)
    - Resource Availability
    - Facility Capacity
    - Time Requirements
    - Technology Gates
  - Equipment Production (Detailed)
    - Weapon Manufacturing
    - Armor Production
    - Consumable Production
    - Craft Addon Production
  - Manufacturing & Research Integration
    - Technology Unlock
    - Production Gates
    - Facility Requirements
    - Cost Interactions

### Transfers
- Supply Transfer Mechanics
  - Inter-Base Transfer
  - Transportation Timeline
  - Cost Calculation
- Transport Costs
  - Distance Factor
  - Item Weight
  - Craft Efficiency
- Logistics Network
  - Transfer Routes
  - Transport Craft
  - Delivery Status

### Suppliers
- Supplier Relationships
  - Reputation Tracking
  - Relationship Levels
  - Purchasing Volume
- Supplier Behavior
  - Inventory Management
  - Pricing Adjustment
  - Risk of Detection
- Market-Based Pricing
  - Dynamic Pricing
  - Supply Scarcity
  - Bulk Transactions
  - Supplier Markup

#### Marketplace & Trading
- Pricing Mechanics (Detailed)
  - Base Price System
    - Item Base Price
    - Markup Percentage
    - Supplier Cost
  - Price Fluctuation
    - Supply & Demand
    - Rarity Factors
    - Scarcity Events
  - Pricing Adjustments
    - Reputation Discount
    - Inflation & Deflation
    - Rarity Multipliers
    - Bulk Discounts
- Supplier Relationships (Expanded)
  - Supplier Types
    - Military Suppliers
    - Syndicate Traders
    - Exotic Arms Dealers
    - Research Material Vendors
  - Relationship Levels
    - Neutral Relations
    - Positive Relations
    - Negative Relations
    - Blocked Access
  - Supplier Inventory
    - Stock Management
    - Inventory Variation
    - Restock Timing
    - Special Offers
- Item Availability (Expanded)
  - Research Gates
    - Prerequisite Tech
    - Research Tier Lock
    - Unlock Conditions
  - Regional Restrictions
    - Regional Availability
    - Political Locks
    - Territory Control
  - Supplier Stock (Expanded)
    - Supplier Inventory
    - Custom Orders
    - Backorder System
  - Seasonal Variations
    - Seasonal Items
    - Holiday Events
    - Limited Edition
- Economic Events (Marketplace)
  - Market Crash
    - Price Collapse
    - Buyer's Advantage
    - Recovery Time
  - Supplier Disruption
    - Supply Shortage
    - Price Spike
    - Alternative Sources
  - Sudden Profit
    - Price Opportunity
    - Resale Value
    - Market Advantage
  - Price Inflation
    - Inflation Events
    - Cost Increase
    - Economic Impact

### Finance
- Monthly Cashflow Model
  - Design Philosophy (Intentional Scarcity)
  - Income Projection
  - Expense Estimation
- Income Sources
  - Country Funding
  - Mission Rewards
  - Salvage Sales
  - Manufacturing Profit
- Expense Sources
  - Unit Maintenance
  - Base Maintenance
  - Craft Maintenance
  - Research Costs
  - Recruitment Expenses
- Economic Crisis Management
  - Crisis Detection
  - Recovery Options
  - Long-Term Sustainability

### Score & Funding
- Country Funding
  - Funding Levels (1-10)
  - Relation Multiplier
  - Performance Bonus
- Funding Levels
  - Level Effects
  - Income Per Level
  - Upgrade Requirements

### Budget
- Monthly Cycle
  - Week 1-4 Breakdown
  - Revenue Collection
  - Expense Payment
  - Financial Report
- Resource Allocation
  - Priority Funding
  - Discretionary Spending
  - Emergency Reserves

## Geoscape **[P0-CRITICAL]**

### Geoscape GUI **[P1-HIGH]**
		Map Display
		Unit Information
		Mission Log
		Quick Actions
	World
		World Map System
			Hexagonal Grid Architecture
				Grid Dimensions (90×45)
				Hex Size (~500km)
				Coordinate System
			Provinces & Regions
				Province Structure
				Regional Organization
				Territorial Boundaries
			Biomes & Terrain
				Biome Types
				Terrain Properties
				Climate Zones
			Map Generation
				Procedural Generation
				Strategic Chokepoints
				Geographic Realism
		World State
			Alien Threat Level
			Faction Activities
			Global Events
	World Map
		Map Navigation
		Zoom Levels
		Information Display
	World Tile Hex
		Hex Properties
		Terrain Effects
		Population Data
		Resource Distribution
	Portals
		Portal System
			Research Requirements
			Portal Mechanics
			Base-to-Base Transport
		Portal Operations
			Activation Cost
			Transport Capacity
			Usage Limitations
	Countries
		Country Classification
			Major Powers
			Secondary Powers
			Minor Nations
			Supranational Organizations
		Country Attributes
			GDP & Funding
			Military Power
			Geographic Location
			Political Alignment
		Country Panic & Relations
			Panic Accumulation
			Panic Effects
			Relation Changes
	Regions
		Regional Bloc System
			Geographic Regions
			Bloc Organization
			Collective Defense
		Regional Effects
			Panic Contagion
			Stability Factors
			UFO Frequency
	Biomes
		Biome Types
			Urban Zones
			Forest Areas
			Desert Regions
			Mountain Terrain
			Arctic Zones
			Underwater Areas
			Volcanic Zones
			Wasteland Regions
		Biome Effects
			Movement Modifiers
			Construction Penalties
			Mission Frequency
			Resource Availability
	Provinces
		Provincial Control
			Base Placement Rules
			Territory Limits
			Control Benefits
		Province Properties
			Population
			Resources
			Strategic Value
			Alien Presence
	Climate & Weather
		Weather Types & Effects
			Clear Conditions
			Rain & Storms
			Snow & Blizzards
			Sandstorms
			Fog & Mist
		Weather Mechanics
			Detection Impact
			Movement Modifiers
			Mission Availability
			Equipment Durability
		Weather Integration
			Global Weather System
			Regional Variations
			Seasonal Patterns
	Pilots
		Pilot System Integration
			Unit-Craft Assignment
			Pilot Requirements
			Crew Structure
		Pilot XP Tracking
			Combat XP Gain
			Mission Participation
			Pilot Achievements
		Dual XP System
			Ground Combat XP
			Interception XP
			Independent Progression
	Fuel & Range
		Fuel Management
			Fuel Consumption
			Fuel Cost Calculation
			Stranding Prevention
		Range System
			Operational Distance
			Fuel Capacity
			Movement Calculation
		Movement Formula
			Speed × Fuel Available
			Terrain Modifiers
			Distance Tracking
	Craft operations
		Craft Movement & Speed
			Speed Categories
			Movement Hexes
			Terrain Effects
		Deployment States
			Base (Ready)
			Transit (Vulnerable)
			Mission (Active)
			Recovery (Return)
		Interception Risk
			Direct Route Risk
			Stealth Route Risk
			Altitude Factors
	Mission detection
		Radar Coverage
			Radar Types
			Detection Range
			Radar Positioning
		UFO Detection
			Detection System
			Detection Probability
			Alert Status
		Mission Generation
			Mission Frequency
			Mission Types
			Difficulty Scaling
		Detection Affected by Weather
			Weather Penalties
			Detection Ranges
			Visibility Effects
	Travel
		Craft Movement
			Hex Movement
			Speed Calculation
			Path Planning
		Terrain Modifiers
			Terrain Costs
			Movement Penalties
			Impassable Areas
	Crafts & Fleet Management
		Craft Fundamentals
			Craft Storage & Capacity
			Pilot System Integration
			Unit Transport Mechanics
			Equipment Management
		Craft Classification System
			Craft Types by Engine
				Conventional Aircraft
				Advanced Hover Craft
				Alien Technology
				Hybrid Systems
			Classification by Terrain
				Air-Only Crafts
				Water-Based Crafts
				Hybrid & Special Purpose
			Classification by Role
				Scout Craft
				Interceptor Craft
				Transport Craft
				Bomber Craft
				Specialized Craft
		Craft Statistics & Properties
			Movement & Navigation
				Speed Classes
				Fuel Efficiency
				Range Calculation
			Storage & Carrying Capacity
				Unit Capacity
				Equipment Storage
				Cargo Hold Size
			Combat & Detection
				Armor Rating
				Weapon Hardpoints
				Radar & Sensor Range
		Craft Weapons & Upgrades
			Craft Weapons System
				Air-to-Air Weapons
				Air-to-Ground Weapons
				Special Weapons
			Craft Addons & Upgrades
				Addon Slots
				Enhancement Types
				Upgrade Paths
			Equipment Synergies
				Weapon Combinations
				Armor & Shield Synergy
				Sensor Integration
		Craft Experience & Progression
			Experience Acquisition
				Combat XP
				Mission Completion Bonus
				Pilot Contribution
			Pilot Advancement
				Pilot Bonus Calculation
				Stat Improvements
				Ability Unlock
		Craft Maintenance & Repair
			Fuel System
				Fuel Consumption
				Refueling Mechanics
				Range Limitation
			Damage & Repair
				Damage Tracking
				Repair Facility Requirements
				Repair Timeline
				Maintenance Costs
		Craft Manufacturing & Technology
			Research Requirements
			Manufacturing Facilities
			Resource Costs
			Production Timeline
		Crash Sites & Rescue Missions
			Crash Site Generation
			Unit Recovery
			Craft Salvage
			Crash Mechanics
			Rescue Operations
	Portal System
		Portal Activation & Mechanics
			Research Requirements
			Construction Costs
			Build Timeline
		Travel via Portal
			Teleportation Range
			Unit & Equipment Transfer
			Resource Movement
			Craft Recall
		Network Limitations
			Portal Connectivity
			Cooldown & Costs
			Combat Restrictions
	Weather System Integration
		Weather Types & Effects
			Clear Weather
			Rain & Storms
			Snow & Blizzards
			Fog & Mist
			Wind Effects
		Seasonal Cycles
			Spring Season
			Summer Season
			Fall Season
			Winter Season
		Geoscape Visibility Impact
			Radar Range Modifiers
			UFO Detection Effects
			Mission Visibility Changes
		Mission Generation Weather Modifiers
			Weather-Specific Mission Types
			Difficulty Adjustments
			Availability Restrictions
			Craft Storage & Capacity
			Pilot System Integration
		Craft Classification & Types
			Class Hierarchy
			Water-Based Crafts
			Hybrid & Special Purpose
		Craft Statistics
			Movement & Navigation
			Storage & Carrying Capacity
			Combat & Detection
		Craft Weapons & Upgrades
			Weapon Slots
			Addon Slots
			Radar & Detection
		Craft Experience & Progression
			Experience Gain
			Pilot Advancement
		Craft Maintenance & Repair
			Fuel System
			Damage & Repair
		Crash Sites & Rescue Missions
			Crash Mechanics
			Rescue Operations

## Interception **[P1-HIGH]**

### Interception GUI **[P2-MEDIUM]**
- Tactical View
- Combat Display
- Weapon Management
- Target Information

### 3 Sectors & 2 sides
- Air Sector
  - Altitude Layers
  - Movement Zones
  - Engagement Range
  - Atmospheric Effects
- Land/Water Sector
  - Surface Combat
  - Water Dynamics
  - Terrain Interaction
  - Navigation Routes
- Underground Sector
  - Cavern Operations
  - Depth Levels
  - Structural Hazards
  - Resource Deposits

### Combat Mechanics
- Chance to Hit
  - Hit Chance Calculation
  - Accuracy Components
  - Range Modifiers
  - Fire Mode Penalty
  - Aircraft Maneuverability
  - Target Evasion
  - Environmental Factors
- Evasion
  - Evasion Options
  - Defensive Posture
  - Altitude Advantage
  - Speed Advantage
  - Damage Accumulation Effects
- Damage Calculation
  - Damage Types
    - Kinetic
    - Energy
    - Electromagnetic
    - Thermal
    - Structural
  - Damage Application
  - Armor Effectiveness
  - Critical Hits
- Weapon range
  - Range Categories
  - Flight Time
  - Range Falloff
  - Minimum Engagement
### Weapon System
- Weapon Categories
  - Ballistic Weapons
    - Machine Guns
    - Cannons
    - Rocket Launchers
  - Energy Weapons
    - Laser Systems
    - Particle Beam
    - Pulse Cannon
  - Missile Systems
    - Air-to-Air
    - Air-to-Ground
    - Guided vs Unguided
- Weapon Type Interactions
- Weapon Properties
  - Accuracy
  - Damage
  - Fire Rate
  - Ammunition
- Base Weapon Mechanics
- Craft Support Systems
  - Fire Control
  - Targeting Systems
  - Weapon Mounting
- Weapon Upgrades
  - Accuracy Enhancement
  - Damage Increase
  - Fire Rate Improvement
  - Range Extension
### Weapon Mechanics (Detailed)
- Weapon Properties
  - Chance to Hit
  - Action Point Cost
  - Energy Point Cost
  - Cooldown System
  - Range & Flight Time
  - Damage Value
- Hit Chance Calculation
  - Base Accuracy Formula
  - Distance Penalties
  - Target Evasion
  - Environmental Modifiers
  - Critical Strikes
- Sector-Based Targeting
  - Cross-Sector Engagement
  - Range to Impact
  - Damage Application
  - Splash Damage
### Entities
- Craft
  - Craft Classification
    - Fighters
    - Bombers
    - Transport
    - Interceptor
    - Heavy Fighter
  - Craft Storage
  - Craft Weapons & Addons
  - Craft Health
  - Craft Status Effects
- Player base
  - Base Defense Rating
  - Base Health System
  - Base Armor Rating
- Enemy base
  - Base Progression
  - Base Threat Escalation
  - Base Defenses
- UFO
  - UFO Types
    - Scout
    - Raider
    - Lander
    - Battleship
    - Carrier
  - UFO Behavior States
  - UFO Attack Resolution
  - UFO Movement
- Site
  - Site Properties
  - Site Defenses
### Entity Health System
- Health Pool
- Armor & Shields
  - Armor Rating
  - Shield Generator
  - Regeneration
- Damage States
  - Functional
  - Damaged
  - Critical
  - Destroyed
- Repair & Recovery
  - Repair Timeline
  - Damage Type Effects
### Outcomes
- Victory Conditions
  - Craft Destroyed
  - Craft Retreated
  - Site Destroyed
- Defeat Consequences
  - Craft Lost
  - Personnel Casualties
  - Resource Loss
- Combat Rewards
  - Salvage
  - Resource Gain
### Interception Weapon Mechanics
- Weapon Classification
  - Ballistic Weapons
  - Energy Weapons
  - Missile Systems
  - Support Weapons
- Damage Resolution
  - Damage Formula
  - Armor Interaction
  - Critical Damage
  - Overkill Effects
- Action Point System
  - Point Generation
  - Point Allocation
  - Point Recovery
  - Maximum Capacity
- Energy Point System
  - Energy Generation
  - Energy Consumption
  - Overheating Mechanics
  - Energy Recovery
- Weapon Special Effects
  - Status Effects
  - Area Effects
  - Chain Reactions
  - Armor Penetration
### Base damage
- Damage Types
  - Kinetic Damage
  - Energy Damage
  - Explosive Damage
  - Special Damage
- Damage Calculation
  - Base Damage Values
  - Damage Modifiers
  - Range Effects
  - Accuracy Effects
- Damage Application
  - Health Reduction
  - Armor Degradation
  - Shield Depletion
  - Critical Systems

## Battlescape **[P0-CRITICAL]**

### BattleScape GUI **[P1-HIGH]**
- 3D View Display
- Unit Selection
- Action Menu
- Tactical Information

### Battle Structure & Team System (Advanced)
- Four Sides Framework
  - Player Side
    - Primary Control
    - Squad Management
    - Objective Focus
  - Ally Side
    - Permanent Alliance
    - Automatic Support
    - Coordination Rules
  - Enemy Side
    - Hostile Opposition
    - AI Behavior
    - Reinforcement Rules
  - Neutral Side
    - Environmental Effects
    - Hazards
    - Destructible Objects
- Team Organization
  - Team Definition
    - Multiple Squads
    - Shared LOS
    - Coordinated Objectives
  - Squad Hierarchy
    - Squad Composition
    - Unit Count (2-12)
    - Leadership Structure
  - Coordination Levels
    - Team Level
    - Squad Level
    - Unit Level
- Battle Sides Difficulty Scaling
  - Side Scaling Multipliers
  - Squad Size Adjustment
  - AI Intelligence
  - Reinforcement Waves

### Battle 3D
- First Person Perspective
  - Player View
  - Camera Height
  - Visual Range
- Third Person Perspective
  - Unit Positioning
  - Surrounding Context
  - Camera Rotation
- Camera Controls
  - Pan & Zoom
  - Target Tracking
  - View Reset
- Field of View
  - Vision Range
  - Fog of War
  - Lighting Effects
### Battle scape
- Map Generation & Terrain
  - Coordinate System
    - Hex Grid Layout
    - Vertical Coordinate
    - Movement Calculation
  - Terrain Types
    - Flat Ground
    - Elevated Terrain
    - Impassable Terrain
    - Water/Lava
  - Environmental Features
    - Buildings & Structures
    - Vehicles & Obstacles
    - Destructible Objects
  - Cover System
    - Full Cover (100% Protection)
    - Half Cover (50% Protection)
    - Low Cover (25% Protection)
    - No Cover (Exposed)
### Battle generation
- Terrain
  - Walkable Terrain
  - Blocked Terrain
  - Cover Types
  - Environmental Hazards
- Map Block
  - Block Composition
  - Block Size
  - Block Rotation
- Map script
  - Scripted Events
  - Dynamic Objectives
  - Environmental Changes
- Map size
  - Small Maps
  - Medium Maps
  - Large Maps
  - Extra Large Maps
- Map tile
  - Tile Variations
  - Tile Decoration
  - Tile Properties
- Map grid
  - Grid Alignment
  - Grid Display
  - Pathfinding Grid
### Battle mission
- Mission Type
- Mission Objective
- Mission Constraints
- Mission Rewards
### Battle objective
- Primary Objective
- Secondary Objectives
- Failure Conditions
- Objective progress
  - Progress Tracking
  - Completion Percentage
  - Objective Status
- Stealth budget
  - Stealth Budget System
    - Total Budget
    - Recovery Rate
    - Budget Decay
  - Action Costs
    - Movement Cost
    - Combat Action Cost
    - Sound Generation
    - Alert Bonus Cost
  - Stealth Status
    - Undetected
    - Partially Detected
    - Detected
    - Fully Alerted
  - Stealth Rewards
    - Bonus Experience
    - Bonus Resources
    - Hidden Objectives
### Battle enemy squad
- Squad Composition
  - Squad Size
  - Unit Types
  - Equipment Loadout
- Squad Tactics
  - Initial Positioning
  - Movement Strategy
  - Engagement Rules
### Enemy AI
- Squad Composition
- Squad Tactics
  - Aggressive Tactics
  - Defensive Tactics
  - Flanking Tactics
  - Coordinated Attacks
- Unit Target Selection
  - Priority System
  - Threat Assessment
  - Decision Making
### Battle planning
- Landing zone
  - Zone Selection
  - Entry Points
  - Deployment Grid
- Ambush
  - Ambush Detection
  - Ambush Triggers
  - Ambush Response
- Squad deployment
  - Unit Placement
  - Equipment Loadout
  - Facing Direction
### Battle combat rules
- line of fire
  - Direct Line
  - Path Obstruction
  - Target Visibility
- line of sight
  - Line of Sight Calculation
  - Obstacle Blocking
  - Partial Visibility
- cover system
  - Cover Mechanics (Detailed)
    - Cost of Sight Component
      - Visibility Reduction %
      - Cover Height Impact
      - Observer Position Effect
    - Cost of Fire Component
      - Accuracy Reduction %
      - Shot Deflection Chance
      - Cover Quality Rating
  - Cover Types & Effectiveness
    - Open: +0% Accuracy
      - No Cover
      - Exposed Position
      - Full Visibility
    - Partial Cover: -15% Accuracy
      - Low Wall (50% blocked)
      - Terrain Obstacle
      - Partial LOS Block
    - Heavy Cover: -30% Accuracy
      - High Wall (75% blocked)
      - Solid Object
      - Significant LOS Block
    - Critical Cover: -50% Accuracy
      - Near-Total Cover (95%+ blocked)
      - Full Obstruction
      - Max Protection
  - Cover Positioning
    - Behind Cover
      - Unit Protection
      - Angle Bonus
      - Movement Penalty
  - Cover Quality
    - Cover Durability
      - Hit Points
      - Degradation
      - Destruction Mechanics
  - Cover Loss
    - Movement Penalty
    - Loss of Protection
    - Repositioning Required
  - Cover Destruction
    - Explosive Damage
      - Wall Penetration
      - Cover Destruction Range
      - Collateral Damage
    - Sustained Fire
      - Cumulative Damage
      - Breakdown Threshold
      - Timing Calculation
#### accuracy to hit
- Accuracy Formula (Canonical)
  - Base Accuracy Component
    - Weapon Base (60-85%)
    - Unit Marksmanship (+/- 5%)
  - Range Modifiers
    - Point Blank (0-2 hex): +20%
    - Short (2-5 hex): +10%
    - Medium (5-10 hex): +0%
    - Long (10-15 hex): -15%
    - Extreme (16+ hex): -40%
  - Fire Mode Modifiers
    - Snap Shot: -20% (1 AP)
    - Aimed Shot: +10% (2 AP)
    - Burst Fire: -10% (3 AP)
    - Auto Fire: -20% (4 AP)
  - Cover Modifiers
    - Open: +0%
    - Partial Cover: -15%
    - Heavy Cover: -30%
    - Critical Cover: -50%
  - Line of Sight Modifiers
    - Direct LOS: +0%
    - Through Smoke: -50%
    - Through Transparent Obstacle: -25%
  - Weapon Modifiers
    - Weapon Type Penalty/Bonus
    - Weapon Condition Impact
    - Attachment Bonuses
  - Unit Stats Impact
    - Marksmanship Stat
    - Weapon Skill Bonus
    - Trait Effects
  - Final Calculation
    - Accuracy% = Base × Range × Mode × Cover × LOS
    - Clamped to 5-95%
    - No Critical Hits
- Evasion System
  - Evasion Options
    - Dodge Movement
    - Defensive Posture
    - Cover Repositioning
  - Dodge Chance
    - Unit Dexterity Stat
    - Evasion Training
    - Encumbrance Penalty
  - Movement Penalty
    - Movement Reduces Dodge
    - Standing Improves Defense
    - Sprinting Reduces Defense
#### damage calculation
- Damage Types (8 Types - Detailed)
  - Kinetic Damage
    - Ballistic Weapons
    - Melee Weapons
    - Armor Interaction
    - Vehicle Damage
  - Explosive Damage
    - Area Effect
    - Collateral Damage
    - Destruction Radius
    - Armor Penetration
  - Energy Damage
    - Laser Weapons
    - Plasma Weapons
    - Armor Effectiveness
    - Infrastructure Damage
  - Psi Damage
    - Psi Weapons
    - Mind Effects
    - Armor Immunity
    - Psychological Impact
  - Stun Damage
    - Non-lethal Weapons
    - Incapacitation Mechanics
    - Recovery Time
    - Armor Reduction
  - Acid Damage
    - Acid Weapons
    - Damage Over Time
    - Armor Degradation
    - Environmental Spread
  - Fire Damage
    - Fire Weapons
    - Spread Mechanics
    - Burn Over Time
    - Extinguishing Options
  - Frost Damage
    - Cold Weapons
    - Movement Reduction
    - Accuracy Reduction
    - Environmental Effects
- Armor Mechanics (Detailed)
  - Armor Rating
    - Armor Value (0-100)
    - Damage Reduction %
    - Type-Specific Resistance
  - Damage Reduction Formula
    - Reduction% = (Armor × 0.5) / (Armor × 0.5 + Incoming Damage)
    - Type Specific Calculation
    - Penetration Modifiers
  - Armor Integrity
    - Armor Durability Pool
    - Damage Accumulation
    - Integrity Loss Rate
    - Degradation Effects
  - Armor Degradation
    - Degradation Mechanics
    - Effectiveness Loss
    - Repair Requirements
    - Replacement Triggers
  - Special Armor Types
    - Light Armor (Scout)
    - Combat Armor (Standard)
    - Heavy Armor (Assault)
    - Hazmat Armor (Specialized)
    - Stealth Armor (Special)
- Damage Application
  - Roll Base Damage ± Variance
  - Apply Armor Reduction
  - Check Penetration
  - Apply to Health Pool
- No Critical Hits
  - Consistent Damage
  - No Multipliers
  - Tactical Positioning Rewarded
- Minimum Damage
  - Minimum 1 Damage Dealt
  - Penetration Rules
  - Minimum Health = 1
#### Melee Combat (Detailed)
- Range & Mechanics
  - Range: 1 Hex Only
  - No Ammo Requirement
  - Backstab Bonus
- Melee Damage Calculation
  - Base Damage Formula
    - (Unit Strength / 2) + Weapon Base Damage
  - Strength Scaling
    - Linear Scaling 1:1
    - Weapon Bonus Addition
    - Stat Modifier Impact
  - Backstab Bonus
    - +20% Accuracy from Behind
    - Detection Avoidance
    - Position Requirements
- Melee Special Rules
  - Always Available
    - No Ammunition
    - No Fire Modes
  - Counterattack Options
    - Reaction Attacks
    - Damage Scaling
    - Availability Conditions
  - Melee Range Control
    - Engagement Options
    - Disengagement Mechanics
    - Positioning Impact
#### Projectile Physics (Detailed)
- Projectile Behavior
  - Deviation Mechanics
    - Accuracy-Based Deviation
    - Random Deflection
    - Adjacent Hex Strikes
  - Ricochets & Bounces
    - Surface Interaction
    - Bounce Angle Calculation
    - Ricochet Damage Reduction
    - Terminal Bounce
- Grenade Mechanics
  - Detonation Triggers
    - Impact Detonation
    - Timer Detonation
    - Remote Detonation
  - Bounce Behavior
    - Wall Bounces
    - Ground Bounces
    - Bounce Distance
  - Blast Pattern
    - Area Effect Radius
    - Shape of Blast
    - Obstacle Interaction
#### Explosion Mechanics (Detailed)
- Area Effect Formula
  - Base Damage at Center
  - Distance Scaling
    - Damage = Base - (5 × distance in hexes)
    - Linear Falloff
    - Minimum Damage Floor
- Blast Direction
  - 4 Cardinal Directions
  - Radial Propagation
  - Wall Blocking
- Wall Blocking & Propagation
  - Walls Block 100%
    - Explosion stops at wall
    - No propagation beyond
    - Damage to wall applies
  - Explosions Damage Walls
    - Wall Destruction Possible
    - Cover Destruction Mechanics
    - Structural Impact
- Multiple Explosions
  - Stacking Mechanics
    - Linear Addition
    - Cumulative Damage
    - Overlapping Effects
- Chain Reactions
  - Secondary Explosions
    - Trigger Conditions
    - Cascade Mechanics
    - Damage Amplification
#### Initiative & Turn Order (Detailed)
- Initiative Calculation
  - Base Initiative
    - Unit Speed Stat
    - Equipment Encumbrance
    - Status Modifiers
  - Initiative Bonus/Penalty
    - Encumbrance Penalty
    - Status Effect Impact
    - Ability Modifiers
- Tie Resolution
  - Player First
    - Player units act first in ties
    - Systematic ordering
- Re-roll Options
  - Initiative Sacrifice
    - Spend Action to Re-roll
    - Next Turn Benefit
    - Strategic Mechanic
- Turn Structure
  - Player Turn(s)
    - All player units act
    - Sequential or simultaneous options
  - Enemy Turn(s)
    - All enemy units act
    - AI Decision Making
    - Sequential Execution
#### 3D Perspective Integration
- First-Person Camera
  - WSAD Movement
  - Tab Unit Selection
  - V Toggle Perspective
- Third-Person Camera
  - Unit Positioning View
  - Camera Rotation
  - Tactical Overview
- Field of View (FOV)
  - 90° Cone
  - Vision Range
  - Dynamic Adjustment
- Perspective Switching
  - Mid-Mission Switching
  - Mechanic Consistency
  - No Changes to Rules
  - 100% Identical to 2D
#### 3D Battlescape Integration
- First-Person Camera System
  - Camera Position
  - Facing Direction
  - Rotation Increments
- Perspective Switching
  - Mid-Mission Switching
  - Mechanic Consistency
  - No Changes to Rules
#### 3D First-Person Camera System
- Core Design Principle
- Input Controls
  - Keyboard Controls
  - Mouse Controls
- Camera & Visibility
  - Field of View
  - Depth Perception
  - Fog of War Integration
- HUD & Information Display
  - Stat Display
  - Target Information
  - Action Feedback
- Perspective Toggle
  - Toggle Mechanics
  - View Persistence
- Performance Considerations
  - Render Optimization
  - Memory Management
  - Toggle Mechanics
  - Strategic Uses
- Field of View & Vision (3D)
  - 3D Vision Limitations
  - FOV Calculation
  - Minimap Display
- HUD & Information Display (3D)
  - Squad Panel
  - Targeting Reticle
  - Weapon Status
- Unit Selection (3D)
  - Selecting Methods
  - Camera Snapping
- Implementation Parity
  - Mechanical Guarantee
  - Performance Targets
  - Campaign Parity

#### Hex Coordinate System (Technical Specification)
- Axial Coordinates (q, r)
  - Q Coordinate (Column)
  - R Coordinate (Row)
  - Coordinate Range Validation
  - Boundary Conditions
- Cube Coordinates (x, y, z)
  - Conversion from Axial
  - Distance Calculation Formula
  - Neighbor Validation
- Direction System (6 Directions)
  - Direction 0: East (q+1, r+0)
  - Direction 1: Southeast (q+0, r+1)
  - Direction 2: Southwest (q-1, r+1)
  - Direction 3: West (q-1, r+0)
  - Direction 4: Northwest (q+0, r-1)
  - Direction 5: Northeast (q+1, r-1)
- Pixel Conversion (Rendering)
  - Hex Size Constants
  - Pixel X Calculation
  - Pixel Y Calculation
  - Odd Column Offset
  - Even Column Alignment
- Neighbor Calculations
  - Adjacent Hex Detection
  - Ring Expansion (Radius 2-5)
  - Line of Sight Path
  - Pathfinding Grid
- Map Wrapping (Spherical)
  - Horizontal Wrapping (Q-axis)
  - Pole Handling (R-axis edges)
  - Coordinate Normalization
- Visual Characteristics
  - "Diamond-Shaped" Appearance
  - Tilted Buildings
  - Intentional Design
  - Asset Alignment Guidelines
- Implementation Guidelines
  - Storage Format
  - Calculation Hierarchy
  - API Consistency
  - Documentation Standards

#### unit actions
**Action Point System Overview:**
- Each unit has 4 Action Points (AP) per turn
- Actions cost 1-4 AP depending on complexity
- Unused AP carry over to next turn (maximum 6 AP reserve)
- AP recovery: 4 AP per turn + 1 AP per 2 hours of rest

**move**
- **AP Cost:** 1-3 AP (based on distance and terrain)
- **Range:** Up to unit's movement speed (typically 4-8 hexes)
- **Mechanics:**
  - Standard movement along hex grid
  - Diagonal movement costs +1 AP
  - Terrain penalties: Forest (+1 AP), Water (+2 AP), Mountains (+3 AP)
- **Special Rules:**
  - Can be interrupted by reaction fire
  - Generates noise (alerts nearby enemies)
  - Cannot move through occupied hexes
  - Elevation changes cost extra AP

**run**
- **AP Cost:** 2 AP
- **Range:** Double normal movement speed
- **Mechanics:**
  - Sprint movement ignoring some terrain penalties
  - Forest costs normal, Water impassable, Mountains +2 AP
- **Special Rules:**
  - -20% accuracy penalty for all actions next turn
  - Cannot use overwatch after running
  - Generates significant noise
  - Stamina cost reduces AP recovery by 1 next turn

**crouch**
- **AP Cost:** 1 AP
- **Range:** Adjacent hex
- **Mechanics:**
  - Reduces height for cover calculations
  - Switches to crouched stance
- **Special Rules:**
  - +20% cover bonus from low walls/objects
  - -1 hex movement range
  - -10% accuracy for ranged attacks
  - Can be maintained across turns

**stand**
- **AP Cost:** 1 AP
- **Range:** N/A (current hex)
- **Mechanics:**
  - Returns to normal standing stance
  - Removes crouch penalties
- **Special Rules:**
  - Required to climb or jump
  - Increases visibility range
  - Removes cover bonuses from crouching

**cover**
- **AP Cost:** 1 AP
- **Range:** Adjacent hex with cover
- **Mechanics:**
  - Moves into cover position
  - Aligns with cover object for maximum protection
- **Special Rules:**
  - +10-50% damage reduction based on cover quality
  - May require specific positioning
  - Can be combined with overwatch

**overwatch**
- **AP Cost:** 2 AP
- **Range:** Weapon range
- **Mechanics:**
  - Sets up automatic reaction fire
  - Triggers when enemies enter line of sight
- **Special Rules:**
  - 50% chance to interrupt enemy movement
  - Uses weapon's normal accuracy
  - Ends when unit acts or turn ends
  - Cannot be used after running

**suppress**
- **AP Cost:** 3 AP
- **Range:** Weapon range
- **Mechanics:**
  - Fires burst at area to pin enemies
  - Creates suppression zone
- **Special Rules:**
  - Enemies in zone get -30% accuracy
  - 25% chance to force crouch
  - Duration: 2 turns
  - Requires burst-capable weapon

**rest**
- **AP Cost:** 1 AP
- **Range:** N/A
- **Mechanics:**
  - Recovers stamina and minor wounds
  - Reduces fatigue effects
- **Special Rules:**
  - +10 health recovery
  - +1 AP recovery next turn
  - Cannot be used in combat
  - Requires safe position

**reload**
- **AP Cost:** 2 AP (1 AP for quick reload)
- **Range:** N/A
- **Mechanics:**
  - Replenishes weapon ammunition
  - Exchanges magazines/clips
- **Special Rules:**
  - Quick reload available with perk/skill
  - Generates noise
  - Can be interrupted
  - Different weapons have different reload times

**attack**
- **AP Cost:** 1-3 AP (based on firing mode)
- **Range:** Weapon range
- **Mechanics:**
  - Fires weapon at target
  - Calculates hit chance and damage
- **Special Rules:**
  - Single shot: 1 AP, normal accuracy
  - Burst: 2 AP, -10% accuracy, multiple hits
  - Auto: 3 AP, -20% accuracy, sustained fire
  - Critical hits: 5% chance for double damage

**throw**
- **AP Cost:** 2 AP
- **Range:** Strength × 2 hexes
- **Mechanics:**
  - Throws grenade or item
  - Arcing trajectory with blast radius
- **Special Rules:**
  - Grenades have 1-turn delay
  - Can be cooked for shorter fuse
  - Accuracy based on strength, not marksmanship
  - Blast radius: 1-3 hexes depending on grenade

**use_item**
- **AP Cost:** 1-2 AP
- **Range:** Adjacent or self
- **Mechanics:**
  - Activates consumable item
  - Applies effects immediately
- **Special Rules:**
  - Medical items: heal wounds
  - Stimulants: temporary bonuses
  - Grenades: see throw action
  - Limited to inventory slots

**interact**
- **AP Cost:** 1 AP
- **Range:** Adjacent
- **Mechanics:**
  - Manipulates environment objects
  - Opens doors, picks up items, etc.
- **Special Rules:**
  - Doors: may be locked (requires hacking)
  - Containers: may contain items/traps
  - Electronics: may trigger alarms
  - Destructible objects: can be smashed

**special_ability**
- **AP Cost:** 1-4 AP
- **Range:** Varies by ability
- **Mechanics:**
  - Activates class-specific or perk abilities
  - Examples: psi powers, cybernetics, mutations
- **Special Rules:**
  - Cooldown between uses
  - May require resources (psi energy, etc.)
  - Can be upgraded through research/perks
  - Some abilities are passive

**call_support**
- **AP Cost:** 2 AP
- **Range:** N/A (radio transmission)
- **Mechanics:**
  - Requests external support
  - Artillery, air strike, or medical evacuation
- **Special Rules:**
  - Requires clear line of sight to sky
  - May take 1-3 turns to arrive
  - Limited uses per mission
  - Can be jammed by enemies

**hunker_down**
- **AP Cost:** 1 AP
- **Range:** N/A
- **Mechanics:**
  - Enters defensive stance
  - Maximizes cover and defensive bonuses
- **Special Rules:**
  - +50% damage reduction from cover
  - Cannot move or attack
  - Ends when damaged or voluntarily
  - Preserves AP for next turn

**spot**
- **AP Cost:** 1 AP
- **Range:** Line of sight
- **Mechanics:**
  - Reveals hidden enemies
  - Extends vision range temporarily
- **Special Rules:**
  - Reveals cloaked/stealthed units
  - Grants temporary vision bonus
  - Can be used with binoculars
  - Intelligence skill bonus applies

**hack**
- **AP Cost:** 2-4 AP
- **Range:** Adjacent or electronic warfare range
- **Mechanics:**
  - Attempts to compromise electronic systems
  - Opens doors, disables security, etc.
- **Special Rules:**
  - Success based on intelligence vs security level
  - Can be interrupted
  - May trigger alarms on failure
  - Requires hacking tool or cybernetic implant

**heal**
- **AP Cost:** 2 AP
- **Range:** Adjacent
- **Mechanics:**
  - Provides medical treatment to ally
  - Stops bleeding, restores health
- **Special Rules:**
  - Requires medic class or first aid training
  - More effective with medical equipment
  - Can stabilize dying units
  - Cannot heal self (use medkit instead)

**disarm**
- **AP Cost:** 2 AP
- **Range:** Adjacent
- **Mechanics:**
  - Attempts to disable traps or explosives
  - Safe removal of hazardous devices
- **Special Rules:**
  - Success based on intelligence/explosives skill
  - Failure may trigger explosion
  - Requires specialized tools
  - Can be used on alien technology
#### unit status effects
- wounded
  - Bleeding
  - Movement Penalty
  - Accuracy Penalty
  - Recovery Timeline
- suppression
  - Accuracy Penalty
  - Action Point Reduction
  - Suppression Decay
- stun
  - Movement Freeze
  - Action Freeze
  - Duration Variable
- fire
  - Damage Over Time
  - Spread Mechanics
  - Extinguishing Options
- smoke
  - Vision Blocking
  - Accuracy Reduction
  - Dissipation Rate
- bleeding
  - Health Drain
  - Bleeding Rate
  - Medical Treatment
  - Fatal Threshold
- acid
  - Armor Damage
  - Health Damage
  - Spread Risk
  - Chemical Resistance
- frost
  - Movement Slow
  - Action Delay
  - Weapon Malfunction Risk
  - Thaw Mechanics

#### Battle salvage
- capture units
  - Capture Conditions
  - Capture Success Rate
  - Captured Unit Status
- salvage items & tiles
  - Item Recovery
  - Crafting Materials
  - Technology Salvage
- experience
  - Unit Experience Gain
  - Squad Experience
  - Officer Bonus
#### Battle enviroment
- smoke
  - Smoke Clouds
  - Smoke Density
  - Smoke Dissipation
- fire
  - Fire Spread
  - Fire Intensity
  - Fire Damage
- fog of war
  - Visibility Range
  - Sensor Range
  - Update Rate
- weather system
  - Rain Effects
  - Snow Effects
  - Wind Effects
  - Dust Storm Effects
- terrain destruction
  - Destructible Objects
  - Collapse Mechanics
  - Damage Debris
- night / day cycle
  - Lighting Changes
  - Visibility Modifiers
  - Active Time Effects
- hazardous terrain
  - Toxic Zones
  - Radiation Areas
  - Magnetic Fields
  - Unstable Ground
- explosions
  - Explosion Center
  - Blast Radius
  - Shrapnel Mechanics
#### Battle damage & accuracy
- Melee Combat
  - Range & Prerequisites
    - Melee Range
    - Weapon Requirements
    - Positioning Rules
  - Base Damage Calculation
    - Strength Component
    - Weapon Damage
    - Combat Skill Bonus
  - Special Rules
    - Armor Penetration
    - Stun Chance
    - Knockback Effect
- Projectile Physics
  - Bullet Trajectory
  - Deviation
    - Wind Deviation
    - Distance Deviation
    - Weapon Deviation
  - Ricochets
    - Surface Type
    - Ricochet Angle
    - Ricochet Damage
  - Detonation
    - Impact Detonation
    - Timed Detonation
    - Remote Detonation
- Explosion Mechanics
  - Area Effect
    - Explosion Radius
    - Damage Falloff
    - Collateral Damage
  - Shockwave
    - Knockback Force
    - Unit Displacement
    - Object Destruction
  - Distance Scaling
  - Wall Blocking
#### Hex Coordinate System
- Axial Coordinates
- Vertical Layout
- Cube Conversion
- Neighbor Calculations
#### Map Block System
- Block Dimensions
- Block Grid Assembly
- Rotation & Mirroring
- Terrain Variation

#### Map Generation Pipeline (Complete)
- Generation Overview
  - Input Parameters
  - Output Battlefield
  - Deterministic Seeds
- Step 1: Biome Selection
  - Biome Types
    - Desert Biome
    - Forest Biome
    - Urban Biome
    - Alien Biome
    - Arctic Biome
  - Selection Criteria
    - Mission Type Gating
    - Random Distribution
    - Weighted Selection
- Step 2: Terrain Selection
  - Terrain Types per Biome
    - Desert Terrains
    - Forest Terrains
    - Urban Terrains
    - Alien Terrains
  - Terrain Properties
    - Movement Cost
    - LOS Blocking
    - Cover Value
- Step 3: Map Block Assignment
  - Map Block Library
    - Available Blocks
    - Block Variants
    - Rotation Options (0-300°)
    - Mirror Options
  - Biome-Terrain Mapping
    - Valid Combinations
    - Fallback Options
- Step 4: Map Script Execution
  - Map Script Components
    - Step Definition
    - Probability System
    - Block Selection
    - Placement Rules
    - Random Seeding
  - Script Phases
    - Initial Placement
    - Road/Path Generation
    - Feature Addition
    - Edge Filling
- Step 5: Map Grid Transformation
  - Rotation Options
    - 0° (No rotation)
    - 90° Rotation
    - 180° Rotation
    - 270° Rotation
  - Mirroring Options
    - Horizontal Mirror
    - Vertical Mirror
    - Diagonal Mirror
  - Inversion
    - Terrain Swap
    - Feature Inversion
  - Block Replacement
    - Type Substitution
    - Variant Selection
- Step 6: Battlefield Construction
  - Map Grid to Battlefield
    - Block Arrangement
    - Tile Assembly
    - Coordinate Mapping
- Procedural Variation
  - Seed-Based Generation
  - Deterministic Randomness
  - Replay Capability
- Performance Optimization
  - Cache Management
  - Memory Strategy
  - Streaming System

#### Coordinate Calculations
- Distance Formula
- Pixel Conversion
- Pathfinding Integration
#### Damage & Resistance System
- Damage Types (8 Core Types)
  - Kinetic Damage
    - Damage Sources
    - Resistance Scaling
    - Armor Effectiveness
  - Explosive Damage
    - Damage Sources
    - Blast Mechanics
    - Resistance Scaling
  - Energy Damage
    - Damage Sources
    - Armor Penetration
    - Resistance Scaling
  - Psionic Damage
    - Damage Sources
    - Mental Resistance
    - Protection Mechanics
  - Stun Damage
    - Stun Duration
    - Armor Reduction
    - Recovery Rate
  - Acid Damage
    - Damage Sources
    - Armor Degradation
    - Armor Penetration
  - Fire Damage
    - Fire Spread
    - Damage Over Time
    - Extinguishing Options
  - Frost Damage
    - Freeze Effects
    - Movement Penalty
    - Damage Mechanics
- Armor Resistance Mechanics
  - Light Armor
    - Base Resistances
    - Weight Modifiers
    - Agility Bonus
  - Medium Armor
    - Base Resistances
    - Movement Cost
    - Protection Level
  - Heavy Armor
    - Base Resistances
    - Movement Cost
    - Durability
- Shield Systems
  - Shield Types
    - Personal Shields
    - Vehicle Shields
    - Tactical Shields
  - Shield Mechanics
    - Shield Strength
    - Shield Regeneration
    - Overload Conditions
- Resistance Calculations
  - Effective Damage
  - Overflow Mechanics
  - Cumulative Effects

#### Consciousness & Identity System
- Philosophical Framework Integration
  - Identity Persistence
    - Self Continuity
    - Memory Integration
    - Personality Consistency
  - Consciousness Transfer
    - Transfer Mechanics
    - Technology Requirements
    - Philosophical Implications
  - Memory Mechanics
    - Memory Access
    - Memory Alteration
    - Retention Across Resets
  - Existential States
    - Unit Consciousness Status
    - Anomaly Effects
    - Simulation Status
- Gameplay Mechanics
  - Unit Consciousness Tracking
    - Consciousness Levels
    - Status Effects
    - Recovery Mechanics
  - Identity Shifts
    - Identity Changes
    - Personality Alterations
    - Relationship Impact
  - Psychological Consequences
    - Mental State Impact
    - Morale Modifiers
    - Behavioral Changes
  - Late-Game Implications
    - Ending Variations
    - Victory Condition Changes
    - Paradox Integration

#### Temporal Mechanics (Advanced)
- Time Loop Awareness
  - Player Recognition of Loop
    - Discovery Conditions
    - Awareness Gates
    - Knowledge Persistence
  - NPC Reactions
    - NPC Awareness Evolution
    - Behavioral Changes
    - Dialogue Variations
  - Memory Mechanics
    - What NPCs Remember
    - Memory Limits
    - Selective Recall
  - Causality Tracking
    - Event Causality Chain
    - Paradox Detection
    - Loop Consistency
- Temporal Anomalies
  - Anomaly Types
    - Causality Breaks
    - Time Distortions
    - Reality Inconsistencies
  - Effect on Combat
    - Accuracy Impact
    - Movement Effects
    - Ability Modifications
  - Effect on Strategy
    - Resource Changes
    - Mission Availability
    - Relationship Shifts
  - Resolution Mechanics
    - Anomaly Healing
    - Resolution Requirements
    - Consequence Persistence
- Timeflow Control (Experimental)
  - Time Acceleration
    - Acceleration Mechanics
    - Usage Limitations
    - Resource Cost
  - Time Deceleration
    - Deceleration Mechanics
    - Usage Limitations
    - Resource Cost
  - Temporal Viewing
    - Past Event Viewing
    - Future Prediction Attempts
    - Information Reliability
  - Bootstrap Interactions
    - Loop Causality
    - Paradox Creation
    - Consistency Maintenance

#### Interception Combat System (Detailed - Advanced)
- Interception Overview
  - Layer Purpose
    - Mid-Tactical Combat Layer
    - Craft vs UFO Resolution
    - Strategic Consequence System
  - Turn Structure
    - Initiative Phase
    - Action Phase
    - Resolution Phase
    - Consequence Phase
  - Participants & Sides
    - Player Craft
    - UFO Entities
    - Support Entities
    - Environmental Hazards
- 3-Sector Framework (Expanded)
  - Air Sector (Altitude 0-5km)
    - Tactical Characteristics
      - Urban Air Space
      - Atmospheric Density
      - Terrain Interference
      - Building Interference
    - Environmental Hazards
      - Wind Shear
      - Storm Systems
      - Precipitation
    - Visibility Rules
      - Clear Visibility (100%)
      - Rain/Fog (50%)
      - Storm (25%)
      - Extreme (0%)
  - Space Sector (Altitude 5-20km)
    - Tactical Characteristics
      - Thin Atmosphere
      - Vacuum Transition
      - Radiation Exposure
    - Visibility & Detection
      - Long-Range Detection
      - Radar Visibility
      - Sensor Jamming
    - Environmental Rules
      - Vacuum Exposure
      - Radiation Effects
      - Micrometeorite Hazards
  - Exo Sector (Altitude 20km+)
    - Tactical Characteristics
      - True Vacuum
      - Extreme Temperature
      - Cosmic Radiation
    - Detection Rules
      - Satellite Detection
      - Ground Radar
      - Direct Observation
    - Environmental Effects
      - Radiation Damage
      - Temperature Extremes
      - Structural Stress
- Combat Entities (Interception)
  - Player Craft (Types)
    - Fighter-Class Craft
      - Maneuverability: High
      - Speed: High
      - Armor: Low
      - Weapons: Medium
    - Interceptor-Class Craft
      - Maneuverability: Medium
      - Speed: Very High
      - Armor: Low
      - Weapons: Medium
    - Heavy-Class Craft
      - Maneuverability: Low
      - Speed: Medium
      - Armor: High
      - Weapons: High
  - UFO Types (Enemy)
    - Fighter-Class UFOs
      - Maneuverability: Medium
      - Speed: High
      - Armor: Medium
      - Weapons: Medium
    - Bomber-Class UFOs
      - Maneuverability: Low
      - Speed: Medium
      - Armor: High
      - Weapons: Very High
    - Interceptor-Class UFOs
      - Maneuverability: High
      - Speed: Very High
      - Armor: Low
      - Weapons: Medium
    - Special UFOs
      - Mothership
      - Command Ship
      - Carrier
  - Support Systems
    - Radar & Detection
      - Detection Range
      - Target Tracking
      - Signature Analysis
    - ECM & Jamming
      - Jamming Strength
      - Counter-Measures
      - Effectiveness Duration
    - Targeting Systems
      - Lock-On Mechanics
      - Lead Calculation
      - Accuracy Bonus
    - Damage Control
      - Repair Automation
      - Damage Assessment
      - System Priority
- Weapon Systems (Interception - Advanced)
  - Point Defense Systems
    - Range & Damage: 5-20km, 5-15 damage
    - Fire Rate: 1-5 shots/turn
    - Special Effects: Anti-missile, area denial
  - Main Cannons
    - Range & Damage: 15-40km, 20-50 damage
    - Accuracy Formula: (70% base × Range Mod × Maneuverability Mod)
    - Ammo Management: Ammunition tracking, reload time
  - Missile Systems
    - Guided Missiles
      - Lock-On Time: 1-3 turns
      - Speed: Fast
      - Damage: 40-80
    - Unguided Rockets
      - Instant Fire
      - Medium Damage: 30-60
      - Area Effect
    - Homing Mechanics
      - Target Tracking
      - Evasion Countermeasures
      - Interception Rules
  - Energy Weapons
    - Laser Arrays
      - Continuous Beam
      - Range: 20-60km
      - Energy Cost: High
    - Plasma Casters
      - Charged Shot
      - Range: 15-50km
      - Area Effect: Small
    - Energy Management
      - Power Pool: Limited
      - Regeneration Rate
      - Cooldown Periods
    - Heat Generation
      - Heat Accumulation
      - Overheat Consequences
      - Cooling System
- Combat Mechanics (Interception - Advanced)
  - Turn System
    - Initiative Calculation: Speed + Pilot Skill (d6)
    - Action Point Economy: 2-3 AP per turn per craft
    - Turn Order Determination: Highest initiative first
  - Movement
    - Hex-Based Movement (Space)
      - Movement Cost: 1 AP per hex
      - Terrain Modifiers: +1 AP in storms
    - Pursuit Mechanics
      - Chase Rules
      - Escape Conditions
      - Distance Tracking
    - Terrain Avoidance
      - Obstacle Detection
      - Collision Rules
      - Automatic Dodge
    - Fuel/Energy Cost
      - Fuel Consumption: Per distance
      - Energy Regeneration: Per turn
      - Stall Conditions: No movement if no fuel
  - Targeting System
    - Line of Sight
      - Direct LOS: +0% accuracy
      - Partial LOS: -20% accuracy
      - No LOS: -50% accuracy
    - Lock-On Mechanics
      - Lock-On Time: 1-3 turns
      - Locked State: +20% accuracy
      - Lock-On Break: Evasion or ECM
    - Jamming Resistance
      - ECM Strength vs Lock-On
      - Jamming Duration
      - Counter-Jamming Systems
    - ECM Defense
      - Active Defense: -30% enemy accuracy
      - Passive Stealth: Harder to detect
      - Reactive Countermeasures
  - Damage Resolution
    - Armor & Hull Integrity
      - Hull Health Pool: Craft health
      - Armor Value: Damage reduction (5-30)
      - Shield Modifier: Additional protection
    - Shield Mechanics
      - Shield Health: Secondary pool
      - Shield Regeneration: Per turn (if not depleted)
      - Shield Overload: Breakdown after 0 health
    - Critical Hits
      - Crit Chance: 5-15% based on accuracy
      - Crit Multiplier: 1.5x damage
      - System Damage: Engine, weapons, shields
    - Destruction Rules
      - Threshold: 0 health = destroyed
      - Bailout Condition: Pilot can eject
      - Wreckage: Salvage opportunity
- Outcome Resolution (Interception)
  - Victory Conditions
    - Target Destroyed: UFO eliminated
    - Enemy Retreat: UFO flees the engagement
    - Survival with Objective: Mission objective secured
  - Defeat Conditions
    - Player Craft Destroyed: Craft eliminated (pilot ejects)
    - Mission Failed: Objective not met
    - Escape Available: Player can retreat safely
  - Aftermath
    - Salvage System: Collect wreckage for resources
    - Repair Costs: Hull/weapon repair expenses
    - Crew Recovery: Pilot evacuation mechanics
    - XP Gain: Experience for pilot and crew

#### Environmental
**Terrain System Overview:**
- Terrain affects movement, cover, and combat resolution
- 6 terrain categories: Walkable, Elevated, Difficult, Impassable, Water, Hazards
- Terrain destruction creates debris and changes battlefield dynamics
- Material properties determine destructibility and environmental interactions

**Terrain Types & Properties:**
- **Walkable Terrain** (Cost: 1 AP/hex)
  - Standard ground, roads, floors
  - No movement penalty, no cover bonus
  - Can be destroyed by explosives (creates craters)
- **Elevated Terrain** (Cost: 2 AP/hex)
  - Hills, stairs, platforms (1-2 levels high)
  - +1 height advantage for ranged attacks
  - Requires climbing action to ascend/descend
- **Difficult Terrain** (Cost: 3 AP/hex)
  - Rough ground, rubble, vegetation
  - -20% accuracy penalty for ranged attacks
  - Provides light cover (+10% defense)
- **Impassable Terrain** (Cost: Infinite)
  - Walls, cliffs, deep water
  - Blocks line of sight and movement
  - Can be destroyed by heavy explosives
- **Water Terrain** (Cost: 2-4 AP/hex)
  - Shallow water: 2 AP, no combat penalty
  - Deep water: 4 AP, -30% accuracy, drowning risk
  - Conducts electricity, extinguishes fire
- **Hazard Terrain** (Variable cost + damage)
  - Lava: 50 damage/turn, 3 AP cost
  - Toxic waste: 15 poison damage/turn, 2 AP cost
  - Radiation zones: 10 radiation damage/turn, 1 AP cost

**Terrain Properties:**
- **Movement Cost:** AP cost per hex (1-4 AP)
- **Cover Quality:** Defense bonus (0-50%)
- **Damage Interaction:** How terrain responds to different damage types
- **Visual Obstruction:** Blocks line of sight (full/partial/none)
- **Destructibility:** HP values and destruction mechanics

**Terrain Destruction:**
- **Destructible Objects:** Walls, doors, vehicles, furniture
  - HP ranges from 10 (wooden door) to 120 (concrete wall)
  - Destruction creates debris terrain (+1 AP cost, +20% cover)
- **Collapse Mechanics:** Multi-hex destruction from explosives
  - Chain reactions in unstable structures
  - Falling debris damages units in area
- **Damage Debris:** Creates temporary hazards
  - Rubble fields, fallen beams, shattered glass
  - Persists 3-5 turns before becoming normal terrain

**Environmental Hazards:**
- **Smoke System:**
  - **Creation:** From fires, explosions, smoke grenades
  - **Density Levels:** Light (25% vision), Medium (50% vision), Thick (75% vision)
  - **Vision Blocking:** Reduces line of sight range
  - **Accuracy Reduction:** -10% to -40% based on density
  - **Dissipation:** 1 hex radius reduction per turn, clears in 3-5 turns
  - **Spread:** Wind pushes smoke 1-2 hexes per turn

- **Fire System:**
  - **Ignition Sources:** Explosives, plasma weapons, incendiary grenades
  - **Intensity Levels:** Small (10 damage/turn), Medium (25 damage/turn), Large (50 damage/turn)
  - **Damage Over Time:** Burns units in hex and adjacent hexes
  - **Spread Mechanics:** 25% chance to spread to adjacent flammable terrain each turn
  - **Extinguishing:** Water, foam, time (50% chance per turn), or suffocation
  - **Fuel Sources:** Wood (burns 5 turns), vehicles (burns 8 turns), chemicals (burns 10 turns)

- **Gas System:**
  - **Types:** Toxic (poison damage), Corrosive (armor damage), Healing (restoration)
  - **Spread Pattern:** Expands 1 hex radius per turn, affected by ventilation
  - **Damage Types:** Poison (15/turn), Acid (armor degradation), Radiation (ongoing damage)
  - **Duration:** 3-8 turns depending on ventilation and gas type
  - **Protection:** Gas masks (full protection), Hazmat suits (partial), Open terrain (faster dissipation)

- **Electrical Hazards:**
  - **Zones:** Created by damaged electronics, power surges, lightning
  - **Damage:** 30 electrical damage on contact
  - **Equipment Malfunction:** 50% chance to disable electronic equipment
  - **Conduction:** Spreads through metal terrain and water
  - **Duration:** Until power source destroyed or 5 turns pass

- **Radiation System:**
  - **Zones:** Nuclear accidents, alien technology, contaminated areas
  - **Damage:** 10 radiation damage per turn (ignores 50% armor)
  - **Duration:** Permanent until cleaned up
  - **Shielding:** Hazmat suits reduce damage by 75%
  - **Genetic Effects:** Long-term exposure causes mutations

**Weather System:**
- **Weather Types & Effects:**
  - **Clear Conditions:** No modifiers, 100% visibility, normal movement
  - **Rain/Storms:** -15% accuracy, -1 hex movement, extinguishes fires
  - **Snow/Blizzards:** -30% accuracy, -2 hex movement, -50% visibility
  - **Fog/Mist:** -40% accuracy, normal movement, 25% visibility range
  - **Sandstorms:** -50% accuracy, -1 hex movement, wind push effects
  - **Volcanic Ash:** -30% accuracy, equipment malfunction risk, breathing damage

- **Weather Mechanics:**
  - **Detection Impact:** Reduces radar and visual detection ranges
  - **Movement Modifiers:** Terrain becomes more difficult in adverse weather
  - **Visibility Effects:** Fog and storms reduce line of sight
  - **Equipment Durability:** Moisture and particulates damage electronics

- **Seasonal Patterns:**
  - **Spring:** Mild weather, occasional rain, normal conditions
  - **Summer:** Heat waves, increased fire risk, equipment overheating
  - **Autumn:** Windy conditions, leaf cover, variable weather
  - **Winter:** Snow/blizzard frequency, frozen terrain, cold damage
  - **Seasonal Hazards:** Dynamic weather events, biome-specific effects
  - **Dynamic Spawning:** Weather affects alien activity patterns

**Day & Night Cycle:**
- **Lighting Changes:**
  - **Day Brightness:** 100% visibility, normal conditions
  - **Twilight:** 75% visibility, +10% stealth for hidden units
  - **Night Darkness:** 25% visibility, requires light sources
- **Visibility Modifiers:**
  - **Day Vision Range:** Full tactical map visibility
  - **Night Vision Range:** 3-5 hex visibility radius around units
  - **Light Source Effects:** Torches/flares extend visibility by 2-3 hexes
- **Activity Effects:**
  - **Alien Activity:** Increased at night, decreased during day
  - **Mission Availability:** Some missions only occur at night
  - **Radar Effectiveness:** Reduced at night, enhanced during day

#### Advanced Environment, Terrain & Weather System (Expanded)
- Terrain Types (Comprehensive)
  - Urban Terrain
    - City Block Density
      - Sparse (0-30% building coverage)
      - Normal (30-60% building coverage)
      - Dense (60-100% building coverage)
    - Building Heights
      - Low (1-3 stories)
      - Medium (4-10 stories)
      - Tall (10+ stories)
    - Street Layout
      - Grid Pattern
      - Irregular Pattern
      - Ring Pattern
    - Population Density
      - Low (sparse missions)
      - Medium (standard missions)
      - High (frequent missions)
  - Wilderness Terrain
    - Forest Density
      - Sparse Forest (easy movement)
      - Dense Forest (difficult movement)
      - Ancient Forest (extreme difficulty)
    - Mountain Elevation
      - Low Hills (minimal penalty)
      - Medium Mountains (movement penalty)
      - High Peaks (extreme penalty)
    - Water Features
      - Rivers (crossing penalty)
      - Lakes (impassable)
      - Marshes (movement penalty)
    - Resource Distribution
      - Resource nodes
      - Ore deposits
      - Fuel sources
  - Industrial Terrain
    - Factory Layouts
      - Linear Layout
      - Grid Layout
      - Irregular Layout
    - Mining Sites
      - Open Pit
      - Underground
      - Abandoned
    - Power Plants
      - Active (hazard zones)
      - Inactive (salvage)
      - Destroyed (debris hazards)
    - Hazmat Facilities
      - Toxic Zones
      - Radiation Areas
      - Containment Units
  - Alien Terrain
    - Alien Base Interior
      - Biological walls
      - Energy fields
      - Incomprehensible geometry
    - Alien Biome
      - Otherworldly flora
      - Hostile environment
      - Cosmic hazards
    - Temporal Distortion
      - Time-warped zones
      - Causality anomalies
      - Physics violations
    - Dimension Anomalies
      - Reality tears
      - Alternate dimensions
      - Unstable space
- Environmental Hazards (Expanded)
  - Natural Hazards
    - Lava Flows
      - Damage: 50 per turn
      - Spread: Yes
      - Extinguishable: No
    - Radiation Zones
      - Damage: 10 per turn (armor reduced)
      - Spread: No
      - Shield Effect: Hazmat suit protection
    - Toxic Gas
      - Damage: 15 per turn (area effect)
      - Spread: Yes (wind-based)
      - Cure: Gas mask or antitoxin
    - Extreme Weather
      - Blizzard: -20% visibility, -2 movement
      - Sandstorm: -50% visibility, wind push
      - Tornado: Movement disruption
  - Artificial Hazards
    - Explosives
      - Trigger: Trip wires, proximity, timer
      - Damage: 40-80 in area
      - Defuse: Engineering check
    - Energy Fields
      - Barrier Type: Impassable
      - Damage: Penetration damage
      - Override: Tech/research gate
    - Security Systems
      - Lasers: Auto-fire hazard
      - Turrets: Active combat
      - Alarms: Reinforcement trigger
    - Traps
      - Pit Traps: Fall damage
      - Spike Traps: Direct damage
      - Spring Traps: Launch effect
  - Alien Hazards
    - Alien Organisms
      - Hostile Flora
      - Predatory Fauna
      - Parasitic Entities
    - Psionic Fields
      - Damage: Psionic damage type
      - Effect: Mental status damage
      - Range: 10+ hexes
    - Temporal Anomalies
      - Time Distortion: Movement/action penalty
      - Causality Breaks: Paradox damage
      - Reality Tears: Instant death hazard
    - Dimensional Tears
      - Portal Hazards
      - Dimension Pull
      - Entity Emergence
- Weather System (Advanced)
  - Weather Types (Complete)
    - Clear Weather
      - Visibility: 100%
      - Movement: Normal
      - Accuracy: Normal
    - Rain/Storm
      - Visibility: 75%
      - Movement: -1 hex/turn
      - Accuracy: -15%
    - Snow/Blizzard
      - Visibility: 50%
      - Movement: -2 hex/turn
      - Accuracy: -30%
    - Fog/Mist
      - Visibility: 25%
      - Movement: Normal
      - Accuracy: -40%
    - Sandstorm
      - Visibility: 25%
      - Movement: -1 hex/turn (wind push)
      - Accuracy: -50%
    - Lightning Storm
      - Weather hazard: Lightning strikes
      - Frequency: Random damage events
      - Effect: Electrical damage
  - Weather Effects (Detailed)
    - Visibility Impact
      - Direct effect on LOS
      - Radar range reduction
      - Targeting difficulty
    - Movement Impact
      - Terrain cost modification
      - Entity slippage chance
      - Fatigue acceleration
    - Accuracy Impact
      - Weapon accuracy penalty
      - Ranged weapon modifier
      - Explosives deviation
    - Equipment Impact
      - Durability loss acceleration
      - Electronic malfunction chance
      - Ammunition degradation
  - Weather Progression
    - Gradual Changes
      - Weather forecasting
      - Transition periods
      - Speed of change
    - Sudden Shifts
      - Surprise weather events
      - Immediate effects
      - Player adaptation needed
    - Extreme Events
      - Hurricanes
      - Earthquakes
      - Solar Flares
    - Cascading Effects
      - Multi-weather combinations
      - Environmental damage
      - Mission complications
- Day/Night Cycle (Advanced)
  - Lighting System
    - Ambient Light
      - Day brightness: 100%
      - Twilight: 50%
      - Night: 10%
    - Object Lighting
      - Light Sources: Torches, lamps
      - Glow effects: Bioluminescence
      - Darkness zones: Unlit areas
    - Shadow Casting
      - Shadow direction (sun position)
      - Shadow length (time-based)
      - Shadow interaction (cover effect)
    - Vision Range
      - Day vision: Full range
      - Twilight: 75% range
      - Night: 25% range (needs light source)
  - Time Progression
    - Hour Advancement
      - Real-time simulation (optional)
      - Time acceleration (player choice)
      - Strategic pausing
    - Day/Night Duration
      - 12 hour day/12 hour night (standard)
      - Polar regions: Extreme day/night
      - Variable by latitude
    - Season Effects
      - Summer: Long days
      - Winter: Long nights
      - Equinox: Equal day/night
    - Special Events
      - Solar eclipse: Darkness at day
      - Aurora: Night illumination
      - Celestial events: Thematic effects
- Biome System (Integration & Expansion)
  - Urban Zones
    - Urban Terrain
    - Building Cover
    - Civilian Presence
  - Forest Areas
    - Dense Cover
    - Vegetation Obstacles
    - Animal Hazards
  - Desert Regions
    - Reduced Cover
    - Heat Hazards
    - Visibility
  - Mountain Terrain
    - Elevation Effects
    - Difficult Movement
    - Avalanche Risk
  - Arctic Zones
    - Extreme Cold
    - Limited Visibility
    - Frost Hazards
  - Underwater Areas
    - Pressure Effects
    - Movement Restrictions
    - Oxygen Management
  - Volcanic Zones
    - Lava Hazards
    - Heat Damage
    - Seismic Events
  - Wasteland Regions
    - Radiation Zones
    - Toxic Residue
    - Unstable Structures

#### Special Environments & Unique Biomes (Advanced)
- Alien Terrain
  - Alien Base Interior
    - Biological Walls
    - Energy Fields
    - Incomprehensible Geometry
    - Alien Aesthetics
  - Alien Biome
    - Otherworldly Flora
    - Hostile Environment
    - Cosmic Hazards
    - Non-Euclidean Layout
- Temporal Distortions
  - Time-Warped Zones
    - Time Distortion Effect
    - Movement Penalty
    - Action Duration
  - Causality Anomalies
    - Paradox Damage
    - Logic Violations
    - Healing Reversal
  - Physics Violations
    - Gravity Shifts
    - Direction Changes
    - Movement Chaos
- Dimension Anomalies
  - Reality Tears
    - Visual Manifestation
    - Hazard Type
    - Containment Rules
  - Alternate Dimensions
    - Dimensional Pocket
    - Parallel Zone
    - Transition Mechanics
  - Unstable Space
    - Spatial Distortion
    - Coordinate Chaos
    - Pathfinding Issues
- Procedural Hazards
  - Random Generation
    - Hazard Distribution
    - Density Control
    - Spacing Rules
  - Hazard Clusters
    - Cluster Formation
    - Cluster Spread
    - Cluster Decay
- Legacy/Historical Environments
  - Ruined Structures
  - Abandoned Bases
  - Decaying Civilization
  - Archaeological Sites
- Environmental Transitions
  - Zone Boundaries
  - Transition Effects
  - Gradient Changes
  - Visual Markers

GUI & Interface System
	Scene System
		Full-Screen Scenes
			Scene Types & Purpose
			Scene Lifecycle
		Modal Dialogs
			Dialog Types
			Modal Behavior
		Transition Animations
			Fade Effects
			Slide Transitions
		Event System
			Input Events
			Callbacks
	Widget System
		Interactive Components
			Buttons
			Panels
			Labels
			Text Boxes
			Toggles
			Sliders
			Dropdowns
			Lists
			Grids
			Scroll Views
			Tabs
			Progress Bars
		Unified Widget Properties
			Position & Size
			Visibility
			Enabled State
			Style & Theming
			Hierarchy & Depth
			Tooltips & Help
			Animations
	Layout Systems
		Anchor-Based Layout
			Fixed Positioning
			Edge Anchoring
		Flex-Box Layout
			Flow-Based Positioning
			Auto-Wrapping
		Grid Layout
			Rows & Columns
			Spacing Rules
		Stack Layout
			Vertical Stacking
			Horizontal Stacking
	Responsive Design
		Measurement Systems
			Relative Units
			Pixel Grid Snappoints
			Resolution Support
		Safe Areas
			Bezel-Aware Positioning
			HUD Element Placement
		Aspect Ratio Adaptation
			Wide Format (16:9)
			Tall Format (9:16)
			Auto-Adjustment
	UI Themes
		Consistency Modes
			Light Theme
			Dark Theme
			High Contrast
			Pixel Art
			Monochrome (Colorblind)
		Theme Components
			Color Scheme
			Typography
			Spacing & Margins
			Borders & Shadows
			Icons
			Animations
		Theme Persistence
			Player Preferences
			Auto-Loading
			Mid-Game Switching
			Per-Scene Overrides
	Advanced UI Patterns
		Context Menus
			Right-Click Triggers
			Position & Auto-Adjustment
		Drag & Drop System
			Drag Initiation
			Visual Preview
			Drop Zone Highlighting
			Auto-Scrolling
		Notification System
			Notification Types
			Toast Notifications
			Notification Feed
			Modal Alerts
			Icon Badges
		Viewport & Scaling
			Resolution Support
			Scaling Strategy
			Text Scaling
	Scene-Specific Layouts
		Geoscape Scene
			Main Components
			Sub-Scenes
		Basescape Scene
			Main Components
			Sub-Scenes
		Battlescape Scene
			Main Components
			Action Panels

Shared
	Crafts
		stats
			Health Points
				Base Health
				Armor Modification
				Upgrades
			Speed
				Base Speed
				Fuel Efficiency
				Maneuverability
			Armor Value
				Armor Rating
				Damage Reduction %
				Upgrade Progression
		classes
			Scout
				High Speed
				Low Armor
				Low Firepower
				Reconnaissance Focus
			Interceptor
				Medium Speed
				Medium Armor
				Medium Firepower
				Balanced Design
			Transport
				Low Speed
				Medium Armor
				Low Firepower
				Cargo Focus
			Fighter
				High Speed
				Medium Armor
				High Firepower
				Combat Focus
			Heavy Fighter
				Medium Speed
				High Armor
				Very High Firepower
				Assault Focus
			Bomber
				Low Speed
				Medium Armor
				Very High Firepower
				Area Denial Focus
			Battleship
				Low Speed
				Very High Armor
				Very High Firepower
				Flagship Focus
		repairs
			Passive Repair
				Base Rate
				Repair per Day
				Maximum Health Cap
			Hangar Upgrades
				Upgrade Types
				Upgrade Cost
				Repair Multiplier
			Monthly Maintenance
				Maintenance Cost
				Maintenance Failure
				Repair Requirements
		Fuel
			Fuel Consumption
				Base Consumption
				Speed Modifier
				Distance Calculation
			Emergency Landing
				Fuel Warning
				Crash Risk
				Landing Zones
			Stranding Mechanics
				Stranded Status
				Rescue Operations
				Personnel Recovery
		Craft Classification (Detailed)
			Craft Types & Roles
				Scout Craft
					High Speed Priority
					Long Range Capability
					Reconnaissance Focus
					Low Firepower
				Interceptor Craft
					Medium Speed
					Medium Armor
					Fighter Capabilities
					Balanced Loadout
				Transport Craft
					Troop Capacity
					Equipment Carrying
					Armor Focus
					Recovery Role
				Fighter Craft
					High Combat Rating
					Dogfighting Capability
					Offensive Focus
					Moderate Speed
				Bomber Craft
					Area Denial
					Heavy Payload
					Slow Speed
					High Firepower
				Heavy Fighter Craft
					Very High Firepower
					High Armor
					Assault Role
					Medium Speed
				Battleship Craft
					Flagship Role
					Maximum Armor
					Maximum Firepower
					Strategic Value
		Craft Storage & Capacity
			Troop Capacity
				Unit Count Max
				Equipment Slots
				Weight Distribution
			Equipment Capacity
				Weapon Hardpoints
				Equipment Slots
				Addon Capacity
			Cargo Capacity
				Weight Limit
				Volume Limit
				Special Cargo
		Pilot System Integration
			Unit-Craft Assignment
				Pilot Assignment
				Co-Pilot Options
				Crew Requirements
			Pilot Experience
				Combat Experience Gain
				Pilot-Only XP
				Specialization Path
				Pilot Advancement
		Dual XP System (Pilot)
			Ground Combat XP
				Unit Ground Combat
				Separate Tracking
				Independent Level
			Pilot Combat XP
				Interception Combat
				Craft Piloting
				Air-to-Air Combat
			Independent Progression
				Separate Advancement Trees
				Different Specializations
				Dual Role Mastery
		Pilot Achievements
			Combat Achievements
				Aerial Kills
				Defensive Maneuvers
				Precision Flying
			Mission Achievements
				Successful Interceptions
				Defensive Operations
				Rescue Missions
			Specialization Achievements
				Pilot Mastery
				Aircraft Familiarity
				Leadership Recognition

	Units
		stats
			Strength
				Base Range (1-100)
				Melee Damage Modifier
				Equipment Carrying
				Stamina Impact
			Marksmanship
				Base Range (1-100)
				Accuracy Bonus
				Handling Bonus
				Fire Rate Impact
			Dexterity
				Base Range (1-100)
				Dodge Chance
				Action Point Bonus
				Movement Bonus
			Bravery
				Base Range (1-100)
				Panic Resistance
				Morale Stability
				Fear Damage Reduction
			Intelligence
				Base Range (1-100)
				Hacking Bonus
				Research Acceleration
				Strategic Insight
			Endurance
				Base Range (1-100)
				Health Bonus
				Stamina Pool
				Wound Resistance
		classes
			Rank System (0-6)
				Rookie (Rank 0)
				Veteran (Rank 1)
				Commando (Rank 2)
				Elite (Rank 3)
				Ace (Rank 4)
				Veteran Commander (Rank 5)
				Legendary (Rank 6)
			Class Hierarchies
				Infantry Squad
				Support Squad
				Special Operations
			Specialization Trees
				Weapons Specialization
				Defensive Specialization
				Support Specialization
		promotions
			Promotion Trigger
				Experience Threshold
				Rank Requirements
				Availability Check
			Specialization Selection
				Available Specializations
				Skill Point Allocation
				Trait Modification
			Permanence
				Irreversible Choice
				Specialization Lock
				Stat Modification Lock
		traits
			Trait System
				Birth Traits
				Achievement Traits
				Genetic Traits
				Equipment Traits
			Trait Types
				Positive Traits
				Negative Traits
				Neutral Traits
				Conditional Traits
			Trait Acquisition
				Random Generation (birth)
				Achievement Unlock
				Genetic Modification
				Equipment Grant
			Trait Balance
				Positive-Negative Pairing
				Power Level Consistency
				Interplay Mechanics
		perks
			Perk Mechanics
				Perk Points
				Perk Slots
				Perk Combinations
			Perk Categories
				Combat Perks
				Support Perks
				Utility Perks
				Passive Perks
			Perk Selection
				Unlocking Conditions
				Permanent Selection
				Respec Options
		medals
			Achievement System
				Medal Tracking
				Achievement Unlock
				Stat Requirement
			Medal Types
				Combat Medals
				Service Medals
				Commendations
				Special Medals
			Medal Rewards
				Stat Bonus
				Perk Unlock
				Cosmetic Reward
				Experience Bonus
		transformation
			Cybernetic
				Cybernetic Components
				Stat Modification
				Irreversibility
			Genetic
				Genetic Enhancement
				Stat Enhancement
				Side Effects
			Alien Hybrid
				Alien DNA Integration
				Stat Changes
				New Abilities
				Psychological Impact
		faces (player only)
			Face Generator
			Face Customization
			Appearance Tracking
		race
			Race Types
				Human
				Sectoid
				Muton
				Ethereal
				Chryssalid
				Floater
				Cyberdisk
				Snakeman
			No Mechanical Bonuses
				Lore-Driven Only
				Equal Starting Stats
				Differentiation Through Equipment

	Items
		resources
			Fuel
				Fuel Unit (1 liter)
				Fuel Cost
				Fuel Storage
				Fuel Marketplace
			Energy Sources
				Nuclear Energy
				Alien Power Cells
				Solar Cells
				Energy Efficiency Rating
			Construction Materials
				Steel Alloy
				Titanium Alloy
				Alien Composite
				Material Grades
			Biological Materials
				Alien Corpses
				Genetic Samples
				Biomass
				Processing Requirements
			Resource Progression
				Early Game Resources
				Mid Game Resources
				Late Game Resources
				Unique Resources
		weapons - units
			Pistols
				Accuracy
				Damage per Shot
				Fire Rate
				Ammo Type
			Rifles
				Accuracy
				Damage per Shot
				Fire Rate
				Ammo Type
				Scope Compatibility
			Sniper Rifles
				High Accuracy
				High Damage
				Slow Fire Rate
				Scope Required
			Shotguns
				Medium Accuracy
				Very High Damage
				Slow Fire Rate
				Close Range Focus
			Melee
				Sword
				Axe
				Club
				Reach Modifier
			Special Weapons
				Plasma Rifle
				Pulse Rifle
				Energy Weapon
				Alien Technology
			Firing Modes
				Single Shot (1 AP cost)
				Burst Fire (2 AP cost, accuracy penalty)
				Full Auto (3 AP cost, high accuracy penalty)
				Aim Mode (1 AP cost, accuracy bonus)
		armours - units
			Light Scout
				Weight: Low
				Armor: 10
				Mobility: High
				Special: Enhanced Sight Range
			Combat
				Weight: Medium
				Armor: 20
				Mobility: Medium
				Special: Balanced
			Heavy Assault
				Weight: High
				Armor: 30
				Mobility: Low
				Special: Damage Reduction
			Hazmat
				Weight: Medium
				Armor: 15
				Mobility: Medium
				Special: Chemical/Radiation Protection
			Stealth
				Weight: Low
				Armor: 10
				Mobility: Very High
				Special: Detection Avoidance
			Medic
				Weight: Low
				Armor: 15
				Mobility: High
				Special: Medical Equipment Slot
			Sniper Ghillie
				Weight: Low
				Armor: 5
				Mobility: Medium
				Special: Long Range Bonus
		weapons - craft
			Point Defense Turret
				Short Range
				Fast Fire Rate
				Anti-Projectile Focus
				Automatic Targeting
			Main Cannon
				Medium Range
				Medium Fire Rate
				High Damage
				Primary Weapon
			Missile Pod
				Long Range
				Slow Fire Rate
				High Damage
				Area Effect
			Laser Array
				Medium Range
				High Fire Rate
				Medium Damage
				Energy Cost
			Plasma Caster
				Long Range
				Medium Fire Rate
				Very High Damage
				Alien Technology
		addons - craft
			Energy Shield
				Shield Generator
				Regeneration Rate
				Recharge Time
			Ablative Armor
				Ablative Layer
				Single-Use Protection
				Replacement Cost
			Reactive Plating
				Active Defense
				Damage Reflection
				Limited Charges
			Afterburner
				Speed Boost
				Duration Limited
				Fuel Cost
			Enhanced Radar
				Extended Range
				Better Resolution
				Cloak Detection
		lore items
			Alien Artifacts
			Historical Relics
			Research Specimens
			Story Items
		prisoners
			Prisoner Capture
				Capture Rate
				Detention Facility
				Prisoner Status
			Prisoner Options
				Execution
				Interrogation
				Experimentation
				Exchange
				Conversion
				Release
			Prisoner Lifecycle
				Detention Period
				Information Decay
				Escape Chances
				Death Risk
		other items
			Consumables
				Medical Kits
				Stimulants
				Grenades
				Ammunition
			Support Equipment
				Radar Jammer
				Cloak Generator
				Targeting Computer
				Encryption Device

Equipment & Item Systems
	Item Categories
		Resources
			Fuel
			Energy Sources
			Construction Materials
			Biological Materials
		Lore Items
			Story Objects
			Narrative Triggers
			Research Unlocks
		Unit Equipment
			Weapons
			Armor
			Consumables
		Craft Equipment
			Ship Weapons
			Defensive Systems
			Modules & Upgrades
		Special Items
			Artifacts
			Research Components
			Exotic Materials
	Item Properties & Statistics
		Item Durability System
			Wear & Tear
			Degradation Penalties
			Repair Mechanics
			Craftsmanship Quality
		Modification System
			Enhancement Slots
			Crafting Requirements
			Part Compatibility
			Upgrade Paths
	Weapon Firing Modes
		Snap Shot
			Accuracy Penalty
			Action Point Cost
			Usage Notes
		Aimed Shot
			Accuracy Bonus
			Action Point Cost
			Stationary Requirement
		Burst Fire
			Multi-Hit Mechanics
			Accuracy Reduction
			Action Point Cost
		Auto Fire
			Sustained Fire
			Recoil Penalties
			Action Point Cost
	Consumables & Medical
		Medikits
			Healing Amount
			Usage Charges
			Effectiveness Over Time
		Stimulants
			Temporary Bonuses
			Side Effects
			Addiction Mechanics
		Armor Patches
			Repair Amount
			Material Requirements
			Application Time
		Ammunition Types
			Standard Rounds
			Specialized Ammo
			Scarcity & Cost
	Equipment Class Synergy
		Weapon-Armor Synergy
			Bonus Conditions
			Stat Modification
			Accuracy Bonuses
			Damage Bonuses
		Weapon-Class Synergy
			Class-Specific Bonuses
			Specialization Bonuses
			Passive Effects
		Class-Armor Synergy
			Mobility Bonuses
			Protection Bonuses
			Special Properties
	Item Durability System
		Durability Tracking
			Durability Points
			Wear Mechanics
			Failure Thresholds
		Damage Types & Durability
			Durability Loss
			Degradation Rates
			Type Effectiveness
		Durability Recovery
			Repair Methods
			Repair Cost
			Maintenance Services
		Item Lifecycle
			Item Degradation
			Replacement Timing
			Scrap Value
	Item Modification System
		Modification Types
			Attachment Slots
			Upgrade Paths
			Enhancement Options
		Modification Mechanics
			Mod Installation
			Mod Removal
			Mod Stacking
			Modification Cost
		Modification Effects
			Stat Changes
			Ability Unlock
			Appearance Changes
		Compatibility System
			Mod Compatibility
			Conflict Resolution
			Version Control
	Damage Types System
		Kinetic Damage
		Explosive Damage
		Energy Damage
		Psi Damage
		Stun Damage
		Acid Damage
		Fire Damage
		Frost Damage
		Armor Resistance Reference
		Shield Mechanics

	Damage & Resistance System
		Damage Types (8 Core Types)
			Kinetic Damage
				Sources & Mechanics
				Armor Resistance
				Weapon Examples
			Explosive Damage
				Sources & Mechanics
				Armor Resistance
				Splash Damage
			Energy Damage
				Sources & Mechanics
				Armor Resistance
				Shield Effectiveness
			Psionic Damage
				Sources & Mechanics
				Resistance Modifiers
				Mental Defense
			Stun Damage
				Sources & Mechanics
				Recovery Mechanics
				Duration Calculation
			Acid Damage
				Sources & Mechanics
				Armor Degradation
				Surface Damage
			Fire Damage
				Sources & Mechanics
				Duration & Spread
				Environmental Interaction
			Frost Damage
				Sources & Mechanics
				Movement Penalty
				Stat Reduction
		Armor Resistance Reference
			Light Armor Profiles
			Heavy Armor Profiles
			Energy Shield Profiles
		Shield Mechanics
			Shield Absorption
			Shield Regeneration
			Shield Bypass Effects

Systems
	Unit Psychology & Mental State
		Bravery Stat System
			Stat Range & Values
			Unit Type Baselines
			Trait Modifiers
			Experience Growth
			Equipment Bonuses
		Morale System (In-Battle)
			Morale Baseline
			Morale Loss Events
			Threshold Effects
			Panic Mode Mechanics
			Recovery Actions
			Leader Rally System
		Sanity System (Between-Battles)
			Sanity Degradation
			Trauma Events
			Recovery Timeline
			Long-term Effects
			Psychological Traits
	Psychological systems
		Morale System
			Definition & Mechanics
				Morale Rating (0-100)
				Morale Loss Events
					Casualties
					Mission Failure
					Defeat in Combat
				Morale Gain Events
					Victory
					Research Success
					Facility Completion
			Morale Effects on Combat
				High Morale (75-100)
					Accuracy Bonus
					Damage Bonus
					Action Point Increase
				Medium Morale (25-74)
					Normal Performance
				Low Morale (0-24)
					Accuracy Penalty
					Damage Penalty
					Action Point Reduction
					Panic Risk
		Sanity System
			Definition & Range (0-100)
			Sanity Loss
				Combat Exposure
				Alien Encounter
				Witnessing Death
				Mission Failure
				Genetic Modification
			Sanity Recovery
				Medical Treatment
				Rest & Recreation
				Psychological Counseling
				Time Passage
			Sanity Effects
				High Sanity (75-100)
					Clear Thinking
					Better Decision Making
				Medium Sanity (25-74)
					Normal Mental State
				Low Sanity (0-24)
					Hallucinations
					Panic Risk
					Combat Penalty
					Mutation Risk
		Stun System
			Stun Pool & Capacity
				Base Capacity
				Equipment Modifiers
				Status Effects
			Stun Gain
				Explosive Damage
				Area Effects
				Melee Impact
				Environmental Hazards
			Stun Effects
				Reduced Action Points
				Reduced Accuracy
				Movement Penalty
				Confusion Status
			Stun Recovery
				Time-Based Recovery
				Medical Treatment
				Equipment Assistance
				Complete Recovery
		Health System
			Health Pool
				Base Health
				Armor Protection
				Regeneration (if applicable)
			Damage States
				Healthy (75-100% HP)
				Wounded (25-74% HP)
				Critical (1-24% HP)
				Unconscious (0 HP)
			Incapacitation & Extraction
				Unconscious Timer
				Extraction Mechanics
				Death Conditions
		Panic Mode
			Definition & Trigger
				Panic Threshold
				Trigger Events
				Random Component
			Panic Check
				Morale vs Trigger
				Bravery Modifier
				Equipment Bonus
			Panic Behaviors
				Flee Map
				Shoot Randomly
				Drop Equipment
				Vocalize Panic
			Ending Panic
				Regain Morale
				Rally Command
				Mission Success
				Time Passage
			Panic Contagion
				Adjacent Contagion
				Morale Reduction
				Cascade Mechanic
		Bravery Stat
			Definition & Range (0-100)
			Bravery Effects
				Panic Resistance
				Morale Stability
				Fear Damage Reduction
				Combat Confidence
		Wounds System
			Wound Categories
				Minor Wounds (1 point health)
				Major Wounds (3 points health)
				Critical Wounds (5+ points health)
				Permanent Wounds (stat penalty)
			Wound Generation
				Damage Type Specific
				Armor Penetration
				Critical Hit Component
			Wound Effects
				Movement Penalty
				Accuracy Penalty
				Morale Impact
				Recovery Timeline
			Wound Recovery Options
				Medical Treatment (fastest)
				Time Passage (slowest)
				Genetic Modification (alternative)
				Surgery Complications

	Reputation & Social
		Fame System
			Definition & Mechanics
				Fame Points (0-1000)
				Public Perception
				Organization Reputation
			Tiers
				Unknown (0-100)
				Notable (100-300)
				Famous (300-600)
				Legendary (600-1000)
			Effects
				Recruitment Bonus
				Equipment Pricing
				Black Market Access
				Mission Frequency
		Karma System (Expanded)
			Definition & Range (-100 to +100)
			Karma Decay
				Monthly Decay
				Event-Based Changes
				Special Circumstances
			Karma Mission Gating
				Positive Missions
				Negative Missions
				Neutral Missions
		Reputation System (Expanded)
			Country Reputation
				Relationship Levels
				Funding Impact
				Mission Impact
			Faction Reputation
				Faction Standing
				Access Restrictions
				Special Missions
			Supplier Reputation
				Supplier Relations
				Pricing Modifiers
				Inventory Effects
		Advisor System (Expanded)
			Advisor Types
				Military Advisor
				Economic Advisor
				Scientific Advisor
				Political Advisor
			Advisor Mechanics
				Hiring Cost
				Hiring Timeline
				Advisor Bonuses
				Advisor Benefits
			Advisor Management
				Advisor Assignment
				Dismissal Rules
				Replacement Timeline
		Power Points System (Expanded)
			Power Point Acquisition
				Monthly Gain
				Event Bonuses
				Political Actions
			Strategic Usage
				Research Acceleration
				Facility Construction
				Diplomatic Actions
				Special Operations
			Power Point Management
				Accumulation Cap
				Carryover Rules
				Strategic Planning

	Global system
		Fame System
			Definition & Mechanics
				Fame Points (0-1000)
				Public Perception
				Organization Reputation
			Tiers
				Unknown (0-100)
				Notable (100-300)
				Famous (300-600)
				Legendary (600-1000)
			Effects
				Recruitment Bonus
				Equipment Pricing
				Black Market Access
				Mission Frequency
		Karma System
			Definition & Range (-100 to +100)
			Decay
				Monthly Decay
				Event-Based Reset
				Special Circumstances
			Effects & Mission Gating
				Positive Karma Effects
					Black Market Type A Access
					Research Speed Bonus
					Population Support
				Negative Karma Effects
					Black Market Type B Access
					Population Resistance
					Funding Reduction
				Mission Gating (certain missions require karma range)
		Reputation System
			Definition & Accumulation
				Country Reputation
				Faction Reputation
				Supplier Reputation
			Effects
				Funding Levels
				Equipment Availability
				Mission Types
				Pricing Modifiers
		Panic Mechanics
			Panic Accumulation
				Global Panic Pool (0-100)
				UFO Sightings Impact
				Mission Failures Impact
				Research Breakthroughs (reduction)
			Panic Effects
				Country Panic Threshold
				Panic Reaching 100
				Funding Reduction
			Country Collapse
				Collapse Triggering
				Collapse Timeline
				Collapse Consequences

	Unit system
		Experience Acquisition
			Passive Training
				Per-Month Gain
				Base Rate
				Facility Bonus
			Active Training
				Training Duration
				Facility Level Required
				Cost
			Combat XP
				Kill XP
				Mission Completion XP
				Survivor Bonus
				Difficulty Multiplier
			Modifiers
				Difficulty Modifier
				Facility Multiplier
				Skill Multiplier
		Achievement & Medal System
			Achievement Types
				Combat Achievements
				Survival Achievements
				Specialization Achievements
				Special Achievements
			Medal Categories
				Combat Medals
				Service Medals
				Commendations
				Special Awards
			Medal Rewards
				Stat Bonus (varies)
				Perk Unlock
				Cosmetic Reward
				Experience Bonus
			Medal Bonuses
				Permanent Stat Increases
				Ability Unlocking
				Morale Impact
				Team Recognition
		Unit Confidence & Behavioral Psychology
			Confidence Levels
				Fearful (-25% effectiveness)
				Cautious (-10% effectiveness)
				Normal (0% modifier)
				Confident (+10% effectiveness)
				Fearless (+25% effectiveness)
			Behavioral Modifiers
				Confidence Impact
					Action Accuracy
					Movement Speed
					Decision Making
					Risk Taking
			Morale Impact
				Morale Correlation
				Confidence Scaling
				Team Morale Effect
				Leadership Aura
		Unit Behavioral State Machine
			Engaged State
				Active Combat
				Offensive Actions
				Target Engagement
			Cautious State
				Defensive Posture
				Cover Seeking
				Risk Avoidance
			Panicked State
				Flee Behavior
				Low Accuracy
				Limited Actions
				Recovery Conditions
			Suppressed State
				Take Cover
				Return Fire Only
				Movement Restriction
				Suppression Decay
		Unit Target Selection Algorithm
			Priority System
				Threat Level Ranking
					High Threat (Elite units)
					Medium Threat (Standard units)
					Low Threat (Weak units)
				Proximity Ranking
					Nearest Enemy
					Line of Sight Priority
					Distance Calculation
				Strategic Ranking
					Objective-Critical Targets
					Support Units
					Leadership Targets
			Decision Making
				Confidence Weighting
				Specialization Bonuses
				Trait Modifiers
				Experience Factor
			Dynamic Adjustment
				Real-Time Evaluation
				Threat Change Response
				Opportunity Exploitation
				Retreat Conditions
		Action Points
			Base AP (60 per turn)
			Modifiers
				Rank Bonus
				Equipment Bonus
				Status Penalty
				Specialization Bonus
		Energy Points
			Energy Generation (20 per turn base)
			Energy Costs
				Reload Cost (10)
				Throw Grenade Cost (15)
				Special Action Cost (variable)
		Move Points
			Movement Calculation
				Base Movement (5 hexes)
				Equipment Weight
				Fatigue Penalty
			Terrain Costs
				Flat Terrain (1 point)
				Elevated Terrain (2 points)
				Difficult Terrain (3 points)
				Impassable (impossible)

	Diplomatic system
		Country Relations
			Relation Values & Categories
				Allied (+50 to +100)
				Friendly (+1 to +49)
				Neutral (0)
				Tense (-1 to -49)
				Hostile (-50 to -100)
			Diplomatic Events
				Praise Events
				Complaint Events
				Trade Negotiations
				Military Cooperation
			Funding Generation
				Relation-Based Funding
				Funding Multiplier
				Bonus & Penalties
			Mission Frequency
				Relation-Based Availability
				Mission Type Gating
				Difficulty Scaling
		Regional Effects
			Regional Blocs
				Bloc Structure
				Bloc Voting
				Bloc Penalties
			Cascading Consequences
				Primary Effects
				Secondary Effects
				Multi-Region Impact
		Supplier Integration
			Supplier Behavior
				Supplier Inventory
				Supplier Pricing
				Supplier Relationships
			Market-Based Pricing
				Demand Factors
				Supply Factors
				Competition Factors

	Politics system
		Government & Advisors
			Advisor Hiring
				Advisor Categories
				Hiring Cost
				Hiring Timeline
			Advisor Types
				Military Advisor (combat bonus)
				Economic Advisor (profit bonus)
				Scientific Advisor (research bonus)
				Political Advisor (diplomacy bonus)
			Advisor Bonuses
				Combat Bonus (+5% accuracy)
				Economic Bonus (+10% profit)
				Research Bonus (+15% speed)
				Diplomacy Bonus (+20% relation improvement)
		Advisor System (Detailed - A9 Spec)
			Advisor Types (Expanded)
				Military Advisor
					Combat Bonuses
					Tactical Insights
					Unit Morale
					Weapon Research
				Economic Advisor
					Profit Margins
					Market Analysis
					Supplier Negotiation
					Manufacturing Efficiency
				Scientific Advisor
					Research Acceleration
					Technology Discovery
					Breakthrough Chance
					Cross-Discipline Bonus
				Political Advisor
					Diplomacy Bonuses
					Country Relations
					Funding Negotiation
					Dispute Resolution
				Special Advisors
					Alien Specialist
					Black Market Contact
					Mercenary Handler
					Espionage Master
			Advisor Stats
				Competence Level
					Novice (1-3 stars)
					Expert (4-5 stars)
					Master (6+ stars)
				Specialization Focus
					Primary Skill
					Secondary Skill
					Tertiary Skill
			Advisor Bonuses (Detailed)
				Stat Bonuses
					+1 to +5 effectiveness
					Stacking Rules
					Team Bonus
				Ability Unlocking
					Special Actions
					Advanced Techniques
					Secret Missions
			Advisor Unlocking
				Discovery Methods
					Recruitment
					Black Market
					Achievement Unlock
					Random Event
				Unlock Requirements
					Reputation Threshold
					Cost Requirements
					Time Requirements
					Experience Requirements
			Advisor Relationships
				Loyalty System
					Loyalty Points
					Satisfaction
					Betrayal Risk
				Advisor Evolution
					Experience Gain
					Stat Improvement
					New Ability Unlock
					Specialization Deepening
		Power Points System (Detailed)
			Power Point Generation
				Monthly Gain
					Base Generation
					Bonus from Advisors
					Relation-Based Bonus
					Event Bonus
			Power Point Usage
				Research Acceleration
					Speed Multiplier
					Cost in Points
					Breakthrough Chance
				Facility Construction Acceleration
					Time Reduction
					Cost in Points
					Quality Impact
				Diplomatic Actions
					Relation Adjustment
					Country Influence
					Crisis Intervention
				Special Operations
					Black Market Access
					Espionage Actions
					Alliance Bonus
			Power Points Accumulation
				Stockpile System
					Current Points
					Maximum Cap
					Carryover Rules
				Strategic Planning
					Point Allocation
					Priority System
					Long-Term Strategy
			Political Actions (Detailed)
				Action Types
					Country Pressure
					Technology Sharing
					Alliance Proposal
					Trade Agreement
				Action Cost
					Political Capital Cost
					Time Requirements
					Success Conditions
				Action Effects
					Relation Changes
					Funding Changes
					Technology Unlock
					New Options
		Country Types & Properties (Detailed)
			Major Powers
				Super Powers
					Influence Level
					Funding Level
					Military Strength
					Diplomatic Weight
			Regional Powers
				Medium Powers
					Regional Influence
					Moderate Funding
				Medium Military
				Diplomatic Options
			Developing Nations
				Small Nations
					Limited Funding
					Low Military
					Diplomatic Leverage
				Growth Potential
				Vulnerability
			Supranational Organizations
				UN Equivalent
					Global Influence
					Funding Access
					Coalition Building
				Special Mechanics
					Multi-Country Voting
					Treaty Options
		Funding System (Detailed)
			Funding Levels (1-10)
				Tier 1: Minimal Support
					Monthly Income
					Mission Availability
					Item Access
				Tier 5: Standard Support
					Moderate Income
					Regular Missions
					Standard Items
				Tier 10: Maximum Support
					Maximum Income
					Priority Missions
					Exclusive Items
			Funding Effects
				Monthly Income
					Funding × Level Multiplier
					Relation Modifier
					Performance Bonus
				Mission Frequency
					Funding-Based Generation
					Difficulty Scaling
					Reward Scaling
			Performance Bonus
				Performance Metrics
					Mission Success
					Casualty Rate
					Speed Bonus
			Relation Modifiers
				Relation Impact
					+40 to +100 (Allied): 1.5× income
					+0 to +40 (Friendly): 1.0× income
					-40 to +0 (Neutral/Cold): 0.5× income
					-100 to -40 (Hostile): 0.25× income
		Panic & Country Collapse (Detailed)
			Panic Accumulation
				Panic Gain Events
					Mission Failure
					Civilian Casualties
					UFO Activity
					Economic Crisis
				Panic Reduction
					Mission Success
					Propaganda
					Protection System
					Alliance Support
			Panic Thresholds
				Low Panic (0-25)
					Minor Effects
					Relation Stable
				Medium Panic (25-50)
					Funding Penalties
					Relation Decrease
				High Panic (50-75)
					Severe Penalties
					Mission Frequency Drop
					Country Instability
				Critical Panic (75-100)
					Country Near Collapse
					Funding Withdrawal
					Alliance Dissolution
			Collapse Mechanics
				Collapse Triggers
					Panic ≥ 100
					Funding Depletion
					Military Defeat
					Alliance Betrayal
				Collapse Consequences
					Country Lost
					Region Lost
					Global Impact
					Recovery Options
			Recovery Options
				Recovery Actions
					Economic Support
					Military Aid
					Propaganda Campaign
					Alliance Rally
				Recovery Timeline
					Quick Recovery (weeks)
					Slow Recovery (months)
					Full Recovery (years)

	Hex System
		Coordinate System
			Axial Coordinates (q, r)
			Vertical Level (z)
			Conversion Rules
		Navigation
			Neighbor Calculation
			Path Finding
			Distance Calculation
		Movement Calculations
			Direct Distance
			Pathfinding Distance
			Movement Cost
		Distance Metrics
			Manhattan Distance
			Euclidean Distance
			Hex Distance
	Environmental Systems
		Terrain System
			Terrain Types & Properties
				Floor Terrain (Walkable)
				Wall Terrain (Blocked)
				Water Terrain
				Difficult Terrain
				Cover Terrain
			Terrain Material Properties
				Wood, Stone, Metal, Glass, Concrete, Vegetation
			Terrain Destruction
				Destructible Objects
				Damage Threshold
				Collapse Mechanics

	Terrain Materials & Properties (Detailed)
		Terrain Material System
			Material Classification
			HP Values
			Destruction Mechanics
		Material: Wood
			Base HP: 10-20
			Fire Behavior: Burns (spreads)
			Explosive Resistance: Low (25%)
			Bullet Resistance: Low (20%)
			Destruction Speed
			Burning Propagation
		Material: Stone
			Base HP: 50-100
			Fire Behavior: Fire-resistant
			Explosive Resistance: High (75%)
			Bullet Resistance: High (80%)
			Destruction Speed
			Rubble Aftermath
		Material: Metal
			Base HP: 30-60
			Fire Behavior: Fire-resistant
			Explosive Resistance: Medium (50%)
			Bullet Resistance: High (70%)
			Conductive Properties
			Corrosion Effects
		Material: Glass
			Base HP: 3-8
			Fire Behavior: Shatters
			Explosive Resistance: Very Low (10%)
			Bullet Resistance: Very Low (5%)
			Transparency Before/After
			Shard Hazard
		Material: Concrete
			Base HP: 60-120
			Fire Behavior: Fire-resistant
			Explosive Resistance: Very High (90%)
			Bullet Resistance: Very High (90%)
			Crack Formation
			Dust Effects
		Material: Vegetation
			Base HP: 5-15
			Fire Behavior: Burns easily
			Explosive Resistance: Very Low (10%)
			Bullet Resistance: Very Low (10%)
			Regrowth Mechanics
			Environmental Spread
		Destruction Effects
			Debris Terrain
			Line of Sight Change
			Movement Path Alteration
			Object Spawning
			Environmental Hazard Creation

	Environmental Hazards
			Smoke System
				Smoke Creation
				Smoke Spread
				Visibility Reduction
				Duration & Decay
			Fire System
				Fire Ignition
				Fire Spread
				Temperature Mechanics
				Extinguish Conditions
			Gas System
				Gas Types (Toxic, Healing, Damaging)
				Gas Spread Mechanics
				Inhalation Effects
				Duration & Dissipation
			Hazard Spread Mechanics
				Wave Propagation
				Blocked Pathways
				Environmental Interaction
		Weather System
			Weather Types & Effects
				Clear Weather
				Rain
				Storm
				Fog
				Snow
				Volcanic Ash
			Seasonal Cycles
				Spring Phase
				Summer Phase
				Autumn Phase
				Winter Phase
			Visibility Impact
				Vision Range Reduction
				Target Acquisition
				Environmental Penalties
			Movement Modifiers
				Speed Reduction
				Terrain Interaction
				Status Effects
		Day vs Night Conditions
			Lighting Changes
				Day Brightness
				Twilight
				Night Darkness
			Visibility Reduction
				Ambient Lighting
				Unit Detection
				Stealth Mechanics
			NPC Behavior Shifts
				Nocturnal Creatures
				Guard Patterns
				Mission Difficulty
		Special Environments
			Biome Types
				Urban Zones
				Forest Areas
				Desert Regions
				Arctic Regions
				Underwater Areas
				Underground Caverns
			Environmental Interaction
				Biome Hazards
				Unique Terrain
				Special Rules
				Duration & Spread
				Gameplay Effects
				Generation Sources
				Tactical Use
			Fire System
				Duration & Spread
				Gameplay Effects
				Generation Sources
				Fire Spread Mechanics
				Tactical Use
			Gas (Toxic Clouds)
				Duration & Spread
				Gameplay Effects
				Generation Sources
				Tactical Use
			Electrical Hazards
				Duration & Effects
				Interaction Mechanics
		Weather System
			Weather Types & Effects
				Clear Weather
				Rain & Storms
				Snow & Blizzards
				Fog & Mist
				Wind Effects
		Day & Night Cycle
			Lighting Changes
				Daylight Visibility
				Darkness Penalties
				Artificial Lighting
		Destructible Terrain
			Destruction Mechanics
				Durability System
				Destruction Triggers
				Destruction Effects
		Special Environments
			Urban Zones
			Industrial Areas
			Natural Hazards
			Exotic Locations
		Biome System
			Biome Types & Properties
				Forest, Desert, Mountain, Arctic, Urban, Swamp, Volcanic

	Environmental Hazards System (Advanced)
		Hazard Categories
			Natural Hazards
			Artificial Hazards
			Alien Hazards
			Status-Based Hazards
		Natural Hazards
			Lava Flows
				Damage: 50/turn
				Spread: Yes
				Extinguishable: No
				Visual Propagation
			Radiation Zones
				Damage: 10/turn (armor reduced)
				Spread: No
				Shield Protection
				Armor Reduction
			Toxic Gas
				Damage: 15/turn
				Spread: Yes (wind-based)
				Gas Mask Protection
				Antitoxin Cure
				Area Effect Rules
			Extreme Weather
				Blizzard Effects
				Sandstorm Effects
				Tornado Effects
		Artificial Hazards
			Explosives
				Trigger Types
				Damage Radius
				Defuse Mechanics
				Trigger Proximity
			Energy Fields
				Barrier Properties
				Penetration Rules
				Override Conditions
			Security Systems
				Laser Grids
				Automated Turrets
				Alarm Systems
			Traps
				Pit Traps
				Spike Traps
				Spring Traps
		Alien Hazards
			Alien Organisms
				Hostile Flora
				Predatory Fauna
				Parasitic Entities
			Psionic Fields
				Damage Type: Psionic
				Mental Effect
				Area Coverage
			Temporal Anomalies
				Time Distortion
				Causality Breaks
				Paradox Mechanics
			Dimensional Tears
				Portal Creation
				Dimension Pull
				Entity Emergence
		Hazard Mechanics
			Spread System
				Propagation Rules
				Direction-Based
				Intensity Changes
				Decay Mechanics
			Intensity Levels
				Light Hazard
				Medium Hazard
				Heavy Hazard
				Extreme Hazard
			Effect Application
				Sight Impact
				Movement Impact
				Accuracy Impact
				Status Application
			Generation Sources
				Environmental
				Player Action
				Enemy Action
				Random Event

	Metrics & Progression
		Karma System
			Range & Definition (-100 to +100)
			Gain/Loss Sources
			Decay Mechanics
			Impact on Gameplay
		Fame System
			Range & Definition (0-100)
			Gain/Loss Sources
			Decay Mechanics
			Impact on Gameplay
		Reputation System
			Range & Definition (0-100)
			Gain/Loss Sources
			No Decay Mechanics
			Impact on Gameplay
		Score System
			Range & Definition (0-∞)
			Gain/Loss Sources
			Per-Country Tracking
			Impact on Gameplay
		Integration with Gameplay
			Advisor Access & Gating
			Mission Generation
			Ending Determination
			Diplomatic Leverage
	Finance & Economy System
		Score System
			Provincial Scoring
			Regional Aggregation
			Score Gains & Losses
		Country Funding
			Funding Calculation Formula
			Funding Level Allocation
			Relationship-Based Changes
		Income Sources
			Country Funding (Primary)
			Mission Loot Sales
			Raid Loot Sales
			Manufacturing Output
			Faction Tributes
			Supplier Discounts
		Operational Expenses
			Equipment Purchases
			Personnel Maintenance
			Facility Maintenance
			Base Operations
			Craft Operations
		Strategic Expenditures
			Black Market Services
			Diplomacy Costs
			Fame Maintenance
			Corruption Tax
			Inflation Tax
		Monthly Budget Cycle
			Week 1: Revenue Collection
			Week 2-3: Operations
			Week 4: Final Settlement
		Cash Flow Forecasting
			3-Month Projection
			Cash Crisis Indicators
			Break-Even Analysis
		Debt System
			Loan Mechanics
			Interest Accumulation
			Repayment Obligations
			Bankruptcy Mechanics
		Budget Planning Tools
			Income Projection
			Expense Projection
			Scenario Analysis

Lore
	Race
		Race Classification
			Humanoid Races
			Alien Races
			Hybrid Races
			Synthetic Beings
		Race Types
			Human
			Sectoid
			Muton
			Ethereal
			Chryssalid
			Floater
			Cyberdisk
			Snakeman
		No Mechanical Bonuses
			Pure Data-Driven
			Equal Starting Stats
			Differentiation Through Traits

	Factions
		Faction Definition
			Faction Philosophy
			Faction Goals
			Faction Mechanics
		Faction Autonomy
			Independent Actions
			Faction Progression
			Inter-Faction Relations
		Unit Classes
			Faction-Specific Units
			Unit Role Assignment
			Unit Capability Variation
		Unique Systems
			Faction Technology
			Faction Abilities
			Faction Restrictions
		Resource Economy
			Faction Resources
			Resource Generation
			Resource Trade

	Campaign
		Campaign Structure
			Campaign Duration (15+ months)
			Campaign Phases
			Milestone Events
		Campaign Generation
			Procedural Events
			Scripted Events
			Dynamic Events
		Escalation Mechanics
			Threat Level Progression
			Enemy Reinforcement
			Tactical Complexity
		Difficulty Progression
			Early Game Scaling
			Mid Game Challenge
			Endgame Intensity
			Difficulty Modifiers
		Campaign Progression System (Detailed)
			Campaign Structure (Expanded)
				Campaign Duration
					Campaign Length
					Monthly Progression
					Milestone Intervals
				Campaign Phases (Expanded)
					Early Game Phase
					Mid Game Phase
					Late Game Phase
					Endgame Phase
				Campaign Generation (Expanded)
					Procedural Events
					Scripted Events
					Dynamic Events
					Random Encounters
			Escalation Mechanics (Expanded)
				Threat Level System
					Threat Levels 1-10
					Escalation Triggers
					Escalation Timeline
					De-escalation Conditions
				Enemy Reinforcement (Expanded)
					Squad Size Scaling
					Equipment Quality
					Tactical Complexity
					Special Units
				Tactical Complexity (Expanded)
					Formation Variety
					Ability Usage
					Coordinated Tactics
					Strategy Advancement
			Difficulty Progression (Expanded)
				Early Game Scaling
					Initial Difficulty
					Ramp-Up Rate
					Player Learning
					Resource Scarcity
				Mid Game Challenge
					Increased Difficulty
					Strategic Depth
					Multiple Fronts
					Resource Management
				Endgame Intensity
					Maximum Challenge
					Complex Tactics
					High Stakes
					Final Confrontation
				Difficulty Modifiers
					Difficulty Settings
					Permadeath Options
					Handicaps
					Bonuses
	Campaign Timeline System (Comprehensive)
		Calendar & Time Management
			Campaign Calendar
				Month Progression (24 months standard)
				Week Subdivision (4 weeks/month)
				Day Scheduling (7 days/week)
				Time Acceleration Options (1x, 2x, 4x, 8x)
			In-Game Time Management
				Real-Time Simulation Option
				Tactical Pause Available
				Auto-Advancement Settings
				Time Skip Functionality
			Seasonal Changes
				Spring (Months 1-3, 9-11): Standard operations
				Summer (Months 4-6, 10-12): Increased UFO activity
				Autumn (Months 7-9): Weather hazards
				Winter (Months 1, 2, 13): Extended night, resource scarcity
		Campaign Milestone Timeline
			Month 1-2: Early Warning Phase
				First UFO Contact
				Base Establishment
				Initial Research
				First Squad Deployment
				Introductory Mission
				Story Gate: "First Contact"
			Month 3-4: Organization Phase
				Facility Expansion
				Technology Advancement
				Squad Building
				First Major Crisis
				Multi-nation Contact
				Story Gate: "Global Coordination"
			Month 5-6: Escalation Phase
				Alien Base Discovery
				Advanced Technology
				Faction Conflict Introduction
				Increased Mission Frequency
				Resource Competition
				Story Gate: "Escalation"
			Month 7-9: War Phase
				Major Alien Assault
				Coalition Formation
				Technology Breakthrough
				Multiple Campaign Fronts
				Political Pressure
				Story Gate: "Strategic Crossroads"
			Month 10-12: Crisis Phase
				Alien Breakthrough
				Base Under Threat
				Personal Sacrifice Possible
				Desperate Actions Required
				Final Technology Sprint
				Story Gate: "Extinction Event"
			Month 13-15: Resolution Phase
				Final Offensive
				Hidden Truth Revelation
				Climactic Battle
				World Fate Determination
				Character Resolution
				Story Gate: "Convergence"
			Month 16+: Endgame/New Game+
				Victory Ending or Defeat
				Epilogue Events
				New Game+ Preparation
				Hidden Content Unlock
				Continuation Possibility
		Dynamic Campaign Pacing
			Tension Curve
				Early Game: Low tension, learning curve
				Mid Game: Rising tension, resource pressure
				Late Game: High tension, desperation phase
				Endgame: Peak tension, final confrontation
			Mission Frequency Scaling
				Early Game: 1-2 missions/week
				Mid Game: 2-3 missions/week
				Late Game: 3-5 missions/week
				Endgame: Daily critical missions
			Resource Economy Timeline
				Early: Resource abundance
				Mid: Resource competition
				Late: Resource scarcity
				Endgame: Survival economy
		Key Decision Points & Branching
			Month 3: First Major Choice
				Aggressive Expansion vs Conservative
				Consequence: Resource availability
			Month 6: Alliance Decision
				Join Coalition vs Go Independent
				Consequence: Faction reputation
			Month 9: Technology Path
				Military vs Civilian Research
				Consequence: Combat capability
			Month 12: Sacrifice Decision
				Protect Humanity vs Research Alien Tech
				Consequence: Story branching
			Month 15: Final Strategy
				Direct Assault vs Diplomatic Solution
				Consequence: Victory condition
		Campaign Pacing Events
			Guaranteed Scripted Events
				Month 1: First UFO Detection
				Month 3: First Base Under Attack
				Month 6: Alien Base Discovered
				Month 9: Major Alien Leader Encountered
				Month 12: Hidden Truth Revealed
				Month 15: Final Confrontation Available
			Dynamic Triggered Events
				Enemy Activity Escalation
				Resource Crisis
				Faction Betrayal
				Technology Breakthrough
				Personnel Loss
				Strategic Setback
			Random Event Integration
				Monthly Random Events (10-20%)
				Dynamic Event Chains
				Player Choice Consequences
				Story Impact Application
		Difficulty Curve Progression
			Easy Difficulty
				Month 1-4: Tutorial-like difficulty
				Month 5-8: Introduction to challenge
				Month 9-12: Moderate difficulty
				Month 13-15: Significant challenge
				Month 16+: Hard difficulty spike
			Normal Difficulty
				Month 1-3: Training missions
				Month 4-6: Standard difficulty
				Month 7-9: Increased challenge
				Month 10-12: High difficulty
				Month 13-15: Extreme difficulty
				Month 16+: Impossible difficulty
			Hard Difficulty
				Month 1-2: Challenging from start
				Month 3-6: Significant challenge
				Month 7-9: High difficulty
				Month 10-12: Extreme difficulty
				Month 13-15: Nearly impossible
				Month 16+: Impossible difficulty
			Impossible Difficulty
				Constant extreme challenge
				Minimal resources
				Dangerous enemies
				One mistake = failure
				Victory highly unlikely
		Campaign Branching & Variations
			Single-Elimination Branch
				Specific sequence required
				One failed mission = campaign fail
				Difficulty: Extreme
				Reward: Unique achievement
			Multiple Path Campaign
				Various routes to victory
				Different mission sequences
				Varying resource availability
				Multiple ending variations
			Sandbox Campaign
				No scripted phases
				Free mission selection
				Dynamic threat progression
				Player-defined goals
		End Game Timeline
			Victory Timeline
				Month 15-18: Possible early victory
				Month 18-24: Standard victory window
				Month 24+: Extended campaign ending
			Defeat Timeline
				Month 6-8: Possible early defeat (commander decision)
				Month 12-14: Likely defeat if unprepared
				Month 20+: Campaign stalemate
			New Game+ Timeline
				Standard timeline with increased difficulty
				+30% threat escalation
				+50% alien intelligence
				New secret content available
				Carryover elements from previous run

	Missions generation
		Mission Types
			Site Missions (crash site, terror site)
			UFO Missions (interception, assault)
			Base Missions (infiltration, defense)
		Mission Scheduling
			Mission Frequency
			Mission Timing
			Mission Clustering
		Site Missions
			Crash Site Generation
			Terror Site Generation
			Site Rewards
			Site Challenges
		UFO Missions
			UFO Type Determination
			UFO Interception
			UFO Assault
		Base Missions
			Base Infiltration
			Base Defense
			Base Rescue

	Events
		Event Categories & Frequency
			Economic Events (monthly)
			Personnel Events (weekly)
			Research Events (research milestone)
			Diplomatic Events (month/relation change)
			Operational Events (mission related)
			Random Events (random)
		Economic Events
			Market Crash
			Supplier Disruption
			Sudden Profit
			Price Inflation
		Personnel Events
			Unit Illness
			Unit Mutation
			Unit Defection
			Unit Promotion
		Research Events
			Research Breakthrough
			Research Setback
			Technology Stolen
			Technology Offered
		Diplomatic Events
			Country Demands
			Country Sanctions
			Country Praise
			Country Warning
		Operational Events
			Enemy Activity
			Alien Sighting
			UFO Crash
			Base Attack
		Event Mechanics
			Event Triggers
			Event Resolution
			Event Consequences
	Dynamic Events (Expanded)
		Event Categories (Expanded)
			Economic Events (Expanded)
				Frequency & Timing
				Event Types
				Consequences
			Personnel Events (Expanded)
				Event Types
				Frequency
				Unit Impact
			Research Events (Expanded)
				Research Breakthroughs
				Research Setbacks
				Technology Theft
				Technology Offers
			Diplomatic Events (Expanded)
				Country Demands
				Country Sanctions
				Country Praise
				Country Warnings
			Operational Events (Expanded)
				Enemy Activity
				Alien Sightings
				UFO Crashes
				Base Attacks
			Random Events (Expanded)
				Surprise Events
				Beneficial Events
				Harmful Events
				Neutral Events
		Event Generation (Expanded)
			Event Probability
				Base Probability
				Difficulty Modifiers
				Progress Modifiers
			Event Triggers (Expanded)
				Time-Based Triggers
				Condition-Based Triggers
				Random Triggers
			Event Consequences (Expanded)
				Immediate Effects
				Delayed Effects
				Cascading Effects
		Event Resolution (Expanded)
			Event Outcome
				Success Conditions
				Failure Conditions
				Partial Results
			Event Rewards
				Material Rewards
				Stat Changes
				Story Progression
			Event Penalties
				Resource Loss
				Stat Penalties
				Story Consequences
	Dynamic Event System (Detailed - Advanced)
		Event Mechanics & Architecture
			Event Definition Structure
				Event ID & Category
				Trigger Conditions
				Event Parameters
				Outcome Variables
				Reward/Penalty Pool
			Event Lifecycle
				Dormant State (Conditions not met)
				Triggered State (Conditions satisfied)
				Active State (In resolution)
				Resolved State (Outcome applied)
				Archived State (Historical record)
			Event Queuing
				Priority System
				Conflict Resolution
				Event Chaining
				Cascading Effects
		Event Generation System
			Generation Algorithm
				Weighted Random Selection
				Probability Calculations
				Difficulty Scaling
				Progress Gating
			Trigger Conditions (Advanced)
				Time-Based
					Specific Date/Time
					Periodic Occurrence
					Calendar Event
					Season Change
				Stat-Based
					Resource Thresholds
					Unit Count Changes
					Facility Completion
					Research Advancement
				Event-Based
					Chain Reactions
					Dependency Triggers
					Consequence Cascades
					Multi-event Combinations
				Random-Based
					Pure Random (1% chance)
					Weighted Distribution
					Difficulty Modifiers
					Seed-Based Variation
			Probability Calculations
				Base Event Probability
				Difficulty Multiplier
					Easy: 0.5x frequency
					Normal: 1.0x frequency
					Hard: 1.5x frequency
					Impossible: 2.0x frequency
				Reputation Modifier
					Positive Rep: +15% benign
					Negative Rep: +15% crisis
					Neutral Rep: Baseline
				Campaign Age Modifier
					Early Game: Tutorial events
					Mid Game: Complex events
					Late Game: Extreme events
	Event Categories (Comprehensive)
		Crisis Events (High Impact)
			Base Assault
				Attack Type (Aliens/Humans/Hybrid)
				Assault Size (Small/Medium/Large)
				Facility Target (Random/Strategic)
				Defense Response
				Reward/Penalty Variables
			Catastrophic Failure
				Facility Explosion
				Research Data Loss
				Equipment Destruction
				Personnel Casualties
				Financial Impact
			Alien Breakthrough
				New Alien Type Discovery
				Advanced Alien Technology
				Unexpected Alien Behavior
				Strategic Advantage Shift
		Opportunity Events (Positive)
			Technology Offer
				Alien Tech Acquisition
				Black Market Offer
				Research Shortcut
				Cost/Benefit Calculation
			Resource Windfall
				Crash Site Discovery
				Salvage Operation
				Trade Opportunity
				Investment Return
			Recruitment Opportunity
				Exceptional Recruit
				Defector Arrival
				Veteran Volunteering
				Specialist Availability
		Faction Events (Political)
			Diplomatic Crisis
				Country Demands (Military/Research/Resources)
				Ultimatum Consequence
				Alliance Threat
				Resolution Options
			Faction Split
				Faction Disagreement
				Member Defection
				Alliance Reconfiguration
				Power Dynamics Shift
			Faction Offer
				Cooperation Proposal
				Technology Exchange
				Resource Sharing
				Military Alliance
		Personnel Events (Squad Impact)
			Soldier Injury
				Severity Levels (Minor/Moderate/Severe)
				Recovery Time
				Permanent Consequence Chance
				Training Impact
			Soldier Desertion
				Trigger Conditions (Low morale/High fear)
				Consequence Application
				Prevention Conditions
				Recovery Possibility
			Soldier Promotion
				Merit Advancement
				Experience-Based
				Loyalty Bonus
				Stat Improvement
		Research Events (Technology)
			Research Breakthrough
				Acceleration Effect
				Bonus Projects Unlocked
				Resource Savings
				Cascading Benefits
			Research Setback
				Project Delay
				Resource Loss
				Alternative Path Requirement
				Catch-up Conditions
			Technology Theft
				Black Market Alert
				Counter-Intelligence Action
				Consequence Options
				Recovery Cost
		Economic Events (Resource Flow)
			Market Fluctuation
				Resource Price Changes
				Equipment Cost Adjustment
				Manufacturer Demand
				Trading Opportunity
			Funding Crisis
				Budget Reduction
				Monthly Income Loss
				Facility Maintenance Threat
				Recovery Conditions
			Funding Opportunity
				Grant Acquisition
				Investment Return
				Donation Arrival
				Bonus Resource
		Environmental Events
			Natural Disaster
				Earthquake Impact
				Volcanic Activity
				Meteor Event
				Facility Damage
			Climate Shift
				Global Temperature Change
				Resource Availability Shift
				Migration Patterns
				Research Opportunity
			Anomaly Discovery
				Unexplained Phenomenon
				Research Opportunity
				Potential Threat
				Exploration Incentive
	Event Consequences & Resolution
		Immediate Effects
			Stat Changes
				Resource Addition/Loss
				Unit Stat Modification
				Facility Effect
				Technology Availability
			Equipment Changes
				Item Acquisition
				Equipment Destruction
				Modification Unlock
				Supply Alteration
			Personnel Changes
				Unit Recruitment
				Unit Death
				Unit Injury
				Unit Promotion
		Delayed Effects
			Time-Delayed Consequences
				Day Delay (Minor effects)
				Week Delay (Standard effects)
				Month Delay (Major effects)
			Cascading Triggers
				Follow-up Events
				Consequence Chains
				Multi-stage Resolution
				Branching Outcomes
		Conditional Consequences
			Player Choice Points
				Presented Options
				Outcome Branching
				Consequence Variation
				Hidden Paths
			Outcome Variables
				Success Threshold
				Partial Success
				Dramatic Failure
				Critical Success
			Alternative Resolutions
				Different Reward Pools
				Unique Consequences
				Alternate Story Paths
				Hidden Achievements
	Event Presentation & Feedback
		Event Notification System
			Alert Severity
				Critical (Immediate notification)
				High (Important)
				Medium (Relevant)
				Low (Optional info)
			Notification Types
				Pop-up Dialog
				Message Log
				On-screen Banner
				Status Indicator
			Audio/Visual Feedback
				Alert Sound
				Notification Animation
				Screen Flash
				Icon Indicator
		Event Description Display
			Title & Summary
			Detailed Description
			Consequence Preview
			Available Options (if choice-driven)
		Event History & Recording
			Event Archive
				Complete Event Log
				Date/Time Recorded
				Outcome Recorded
				Consequence Applied
			Analytics Tracking
				Total Events Triggered
				By Category Frequency
				Positive/Negative Ratio
				Impact on Campaign

	Quests
		Quest Framework
			Quest Definition
			Quest Requirements
			Quest Tracking
		Quest Categories
			Main Quest Line
			Side Quests
			Event Quests
			Specialty Quests
		Quest Generation
			Procedural Quests
			Scripted Quests
			Dynamic Quests
		Quest Rewards
			Experience Rewards
			Resource Rewards
			Equipment Rewards
			Lore Rewards
		Campaign Milestone Integration
			Early Quests
			Mid-Campaign Quests
			Late-Game Quests
			Endgame Quest Line
	Quest System (Expanded)
		Quest Framework (Expanded)
			Quest Definition (Expanded)
				Quest Title & Description
				Quest Requirements
				Quest Objectives
				Quest Tracking
			Quest Metadata
				Quest Type
				Quest Difficulty
				Quest Rewards
				Quest Timeline
		Quest Categories (Expanded)
			Main Quest Line (Expanded)
				Primary Objectives
				Story Progression
				Campaign Milestones
				Ending Paths
			Side Quests (Expanded)
				Optional Quests
				Reward Options
				Timeline Flexibility
				Story Integration
			Event Quests (Expanded)
				Event-Triggered Quests
				Time-Limited Availability
				Special Rewards
			Specialty Quests (Expanded)
				Faction Quests
				Skill-Based Quests
				Challenge Quests
		Quest Generation (Expanded)
			Procedural Quests (Expanded)
				Random Generation
				Reward Scaling
				Difficulty Variation
			Scripted Quests (Expanded)
				Fixed Content
				Predetermined Rewards
				Story Integration
			Dynamic Quests (Expanded)
				Condition-Based
				Player-Influenced
				Adaptive Difficulty
		Quest Mechanics
			Quest Tracking (Detailed)
				Objective List
				Progress Tracking
				Marker System
				Status Display
			Quest Progress (Detailed)
				Partial Completion
				Milestone Tracking
				Failure Conditions
				Quest Reset
			Quest Completion (Detailed)
				Completion Conditions
				Reward Distribution
				Achievement Unlock
				Consequence Application
		Quest Rewards (Expanded)
			Experience Rewards (Detailed)
				Base XP
				Bonus XP
				Multipliers
			Resource Rewards (Detailed)
				Credits
				Materials
				Equipment
			Equipment Rewards (Detailed)
				Unique Items
				Specialized Equipment
				Modification Tokens
			Lore Rewards (Detailed)
				Backstory Unlocks
				Character Development
				Faction Advancement
	Quest Progression System (Detailed - Advanced)
		Quest Structure & Flow
			Quest Lifecycle
				Dormant State (Not activated)
				Active State (In progress)
				Completed State (Finished)
				Failed State (Cannot complete)
				Archived State (Completed & recorded)
			State Transitions
				Activation Conditions
				Progression Triggers
				Completion Conditions
				Failure Triggers
				Failure Recovery
		Quest Objectives (Advanced)
			Objective Types
				Kill Target (Eliminate specific entity)
				Collect Item (Gather resource)
				Investigate Location (Explore area)
				Talk to NPC (Dialogue completion)
				Defend Position (Hold location)
				Reach Location (Navigate to point)
				Survive Duration (Endure time limit)
				Achieve Condition (Complex requirement)
			Objective Properties
				Required vs Optional
				Sequential vs Parallel
				Conditional Activation
				Failure Consequences
				Reward Modification
			Objective Tracking
				Real-time Progress Display
				Marker System (Map/HUD)
				Progress Percentage
				Status Notifications
		Quest Difficulty & Scaling
			Difficulty Tiers
				Easy (Introductory)
					XP Multiplier: 0.8x
					Resource Multiplier: 0.8x
					Enemy Scaling: Minimal
				Normal (Intermediate)
					XP Multiplier: 1.0x
					Resource Multiplier: 1.0x
					Enemy Scaling: Standard
				Hard (Challenging)
					XP Multiplier: 1.5x
					Resource Multiplier: 1.2x
					Enemy Scaling: +20% stats
				Impossible (Extreme)
					XP Multiplier: 2.0x
					Resource Multiplier: 1.5x
					Enemy Scaling: +50% stats, special abilities
			Dynamic Scaling
				Party Strength Adjustment
				Mission History Scaling
				Reputation Impact
				Equipment Quality Scaling
		Quest Management Interface
			Active Quest List
				Current Objectives
				Quest Progress Bar
				Time Remaining (if timed)
				Quick Navigation
			Quest Journal
				Completed Quests
				Quest Descriptions
				Reward History
				Lore Unlocks
			Quest Markers
				Map Markers
				HUD Indicators
				Directional Compass
				Distance Display
			Quest Filtering
				By Status
				By Type
				By Difficulty
				By Region
	Quest Type Deep Dives
		Story Quests (Campaign-Critical)
			Main Plot Line
				Plot Progression Gates
				Character Development
				World State Changes
				Faction Consequences
			Character Quests
				Personal Stories
				Character Arcs
				Relationship Development
				Hidden Consequences
			World Quests
				Global Events
				Location-based Stories
				Environmental Storytelling
				Optional Exploration
		Mission-Based Quests
			Geoscape Missions
				UFO Interception
				Ground Assault
				Recovery Operations
				Research Retrieval
			Basescape Tasks
				Facility Management
				Recruitment Drives
				Research Completion
				Supply Operations
			Battlescape Objectives
				Combat Goals
				Survival Challenges
				Rescue Operations
				Artifact Recovery
		Repeatable Quests
			Daily Quests
				Reset Schedule
				Fixed Objectives
				Guaranteed Rewards
				Scaling Difficulty
			Weekly Quests
				Extended Scope
				Complex Objectives
				Bonus Rewards
				Event Timing
			Bounty Quests
				Target Elimination
				Capture Objectives
				Rescue Missions
				Collection Tasks
	Quest Interaction & NPC Integration
		Quest Givers
			Faction Leaders
				Faction-specific missions
				Alignment consequences
				Unique rewards
			Base Commanders
				Operational missions
				Base resource quests
				Strategic objectives
			Recruit NPCs
				Personal quests
				Relationship quests
				Hidden story elements
			Neutral NPCs
				Side missions
				Optional objectives
				World-building context
		Quest Dialogue System
			Dialogue Options
				Accept/Decline Choices
				Reward Negotiation
				Difficulty Selection
				Consequence Discussion
			Dialogue Consequences
				Reputation Changes
				Relationship Shifts
				Future Quest Access
				Special Rewards
			Dialogue Outcomes
				Multiple Resolution Paths
				Alternate Objectives
				Hidden Objectives
				Easter Eggs
		NPC Quest Chains
			Sequential Quests
				Story Progression
				Character Development
				Relationship Deepening
				Final Payoff
			Parallel Quests
				Multiple Story Threads
				Convergence Points
				Alternate Paths
				Ending Variations
	Quest Failure & Recovery
		Failure Conditions
			Time Expiration
				Countdown Timer
				No Extension Option
				Consequence Application
			Objective Failure
				Mandatory Objective Failure
				Cascading Failures
				Alternative Objectives
			Quest Cancellation
				Player-Initiated Cancel
				NPC Dialogue Termination
				Automatic Expiration
		Failure Consequences
			Reputation Loss
				Faction Reputation Hit
				NPC Relationship Damage
				Quest Access Restriction
			Resource Loss
				Reward Forfeiture
				Penalty Application
				Compensation Requirements
			Story Consequences
				Alternate Branching
				Quest Chain Closure
				Future Quest Blocking
			Recovery Options
				Retry Conditions
				Difficulty Reduction
				Extended Timeframe
				Alternative Completion
	Quest Reward & Advancement
		Reward Types (Complete)
			Experience Rewards
				Base XP (Quest completion)
				Bonus XP (Time efficiency)
				Perfection Bonus (No failures)
				Multipliers (Difficulty, streak)
			Currency Rewards
				Credits (Primary)
				Research Points (Secondary)
				Faction Points (Alignment)
				Black Market Tokens (Special)
			Equipment Rewards
				Weapon Drops
				Armor Pieces
				Consumables
				Modification Materials
			Facility Rewards
				Blueprint Unlocks
				Facility Upgrades
				Production Bonuses
				Research Acceleration
			Capability Rewards
				Ability Unlocks
				Skill Improvements
				Perk Acquisition
				Trait Activation
		Reward Scaling
			Difficulty Multiplier
				Easy: 0.8x rewards
				Normal: 1.0x rewards
				Hard: 1.5x rewards
				Impossible: 2.0x rewards
			Reputation Multiplier
				Low rep: 0.8x credits
				High rep: 1.2x credits
				Enemy rep: 0.5x rewards
			Campaign Age Multiplier
				Early game: Higher rewards
				Mid game: Standard rewards
				Late game: Lower currency, higher equipment
		Achievement Integration
			Quest Achievements
				Completion Milestones
				Speed Challenges
				Perfection Awards
				Collection Achievements
			Advancement Tracking
				Total Quests Completed
				By Type Completion
				By Difficulty Completion
				Perfect Completion Rate

	Story
		Campaign Phases
			Early Game (Months 1-3)
				Initial Setup
				First Contacts
				Base Development
				Training & Recruitment
			Mid Game (Months 4-8)
				Territory Expansion
				Technology Advancement
				Faction Encounters
				Threat Escalation
			Late Game (Months 9-14)
				Strategic Decisions
				Major Battles
				Technology Mastery
				Power Play
			Endgame (Months 15+)
				Final Confrontation
				Ultimate Threat
				Victory Path
				Defeat Path
		Loss Conditions
			Organization Destruction
				Base Destruction
				Squad Wipe
				Fund Termination
			Economic Collapse
				Cash Depletion
				Supply Chain Failure
				Funding Termination
			Complete Funding Loss
				Final Funder Defection
				Panic Reaching Critical
				Mission Failure Cascade

	Victory Condition
		Ending Types
			Good Endings
			Neutral Endings
			Bad Endings
		Campaign Completion
		Victory Paths
	Victory & Defeat Condition System (Comprehensive)
		Campaign Victory Conditions (Primary Paths)
			Military Victory
				Alien Threat Elimination
					All UFO Construction Ended
					All Alien Forces Defeated
					All Alien Bases Destroyed
					Alien Commander Eliminated
				Difficulty Scaling
					Easy: 75% forces eliminated
					Normal: 90% forces eliminated
					Hard: 99% forces eliminated
					Impossible: 100% forces eliminated
				Victory Timeline
					Early Victory (Month 6-8)
					Standard Victory (Month 12-15)
					Extended Victory (Month 18+)
			Diplomatic Victory
				World Peace Achievement
					All Countries Positive Reputation
					All Factions Allied
					UN Resolution Passed
					Global Stability Threshold
				Requirement Gates
					Minimum Geoscape Control
					Technology Achievement Level
					Resource Availability
					Political Alignment
			Scientific Victory
				Alien Understanding Mastery
					All Alien Unit Research
					All Alien Weapon Research
					All Alien Technology Research
					Consciousness Understanding
				Research Path
					Main Research Tree (80%+)
					Alien Tech Tree (90%+)
					Hidden Research (50%+)
					Experimental Projects (30%+)
			Cultural Victory
				Humanity United
					Cultural Dominance Achievement
					Faction Reconciliation
					Historical Legacy
					Population Support
			Hidden Victory
				Secret Ending
					Unique Conditions
					Unknown Requirements
					Special Consequence
					Achievement Reward
		Campaign Defeat Conditions (Loss States)
			Military Defeat
				Base Destruction
					All Bases Conquered
					All Bases Destroyed
					Personnel Wipeout
					Resources Depleted
				Alien Conquest
					Alien Territory Expansion to 100%
					UN Capitulation
					Global Alien Control
					Humanity Defeat
			Personnel Annihilation
				Squad Wipeout
					All Soldiers Dead
					No Recovery Possible
					Mission Failure Chain
					Campaign End
			Political Collapse
				UN Dissolution
					Country Betrayal Threshold
					Alliance Breakdown
					Funding Termination
					Organization Collapse
			Economic Failure
				Financial Ruin
					Monthly Deficit Months
					Debt Accumulation
					Loan Default
					Resource Shortage Chain
			Temporal Defeat
				Campaign Deadline
					Month 24 Deadline (Impossible victory)
					Escalation Limit
					Threat Level Critical
					Story End State
		Dynamic Victory Point System
			Victory Point Accumulation
				Military Actions (+1-10 points)
					Alien Kill (unit type scaled)
					UFO Destruction
					Alien Base Capture
					Territory Control
				Research Completion (+1-5 points)
					Technology Unlock
					Alien Understanding
					Weapon Development
					Special Project
				Political Alignment (+1-5 points)
					Country Approval
					Faction Alliance
					UN Resolution
					Global Stability
			Victory Threshold Progression
				Early Game (Month 1-3): 10 points to victory milestone
				Mid Game (Month 4-9): 30 points to victory milestone
				Late Game (Month 10-15): 50 points to unlock final victory
				Endgame (Month 16+): Victory/Defeat determination
			Dynamic Adjustments
				Difficulty Multiplier
					Easy: 0.75x requirement
					Normal: 1.0x requirement
					Hard: 1.5x requirement
					Impossible: 2.0x requirement
				Campaign Progress Modifier
					Early Victory: +50% difficult
					Standard Victory: Baseline
					Extended Victory: -30% difficult
		Mission-Level Victory/Defeat
			Battle Victory Conditions
				All Objectives Complete
				Enemy Squad Elimination
				Survival Duration
				Rescue/Escort Success
			Battle Defeat Conditions
				All Squad Members Dead
				Objective Failure (mandatory)
				Extraction Impossible
				Time Limit Exceeded
			Consequence Escalation
				Squad Morale Impact
				Campaign Momentum
				Story Progression
				Future Mission Access
		Partial Victory & Pyrrhic Victory
			Partial Success
				Objectives Met (70-90%)
				Reduced Rewards
				Story Progression Limited
				Alternative Ending Path
			Pyrrhic Victory
				Objective Achieved with Heavy Losses
				Squad Morale Damage
				Campaign Momentum Loss
				Unique Consequence Application
			Failure with Survival
				Mission Failed
				Squad Extracted Alive
				Reduced Penalties
				Retry Opportunity
		Victory/Defeat Branching
			Story Branching
				Victory Branch (Original ending)
				Defeat Branch (Alternate ending)
				Partial Victory Branch (Compromise ending)
				Hidden Branch (Easter egg ending)
			Character Fates
				Victory: Character Survival
				Defeat: Character Death/Capture
				Partial: Character Injury
				Hidden: Character Disappearance
			World State Changes
				Victory: Alien Threat Recedes
				Defeat: Alien Threat Advances
				Partial: Status Quo Maintained
				Hidden: Reality Alteration
		End-Game Content & Continuation
			Victory Epilogue
				Campaign Summary
				Character Fates
				World Impact
				Achievement Unlock
			Defeat Epilogue
				Failure Analysis
				Survivor Stories
				Alternate Timeline Hint
				New Game+ Unlock
			New Game+ Mode
				Carryover Elements
					Units/Pilots
					Research Progress
					Facility Upgrades
					Equipment
				Difficulty Escalation
					Alien Forces +30%
					Alien Intelligence +50%
					Mission Difficulty +20%
					Resource Scarcity +40%
				New Content
					Additional Secrets
					Hidden Characters
					Alternate Missions
					Special Abilities
		Victory/Defeat Achievement System
			Victory Achievements
				First Victory
				Speed Run (Complete in 12 months)
				Perfect Campaign (100% missions won)
				Diplomatic Master (All countries allied)
			Defeat Recovery Achievements
				Rise from Ashes (Recover from critical state)
				Last Stand (Survive impossible scenario)
				Sacrifice (Complete mission at cost)
			Special Achievement Conditions
				Ironman Mode Victory
				Pacifist Run
				One-Squad Campaign
				Hidden Objective Completion
		Campaign Metrics & Statistics
			Tracking Systems
				Total Missions Completed
				Total Enemies Defeated
				Total Resources Gathered
				Total Technology Researched
				Total Time Spent
			Performance Analysis
				Win Rate Percentage
				Average Squad Health
				Resource Efficiency
				Technology Completion Rate
			Difficulty Analysis
				Average Mission Difficulty
				Total Casualties
				Equipment Loss Rate
				Research Speed
			Historical Record
				Campaign Save Data
				Statistics Archive
				Leaderboard Entry
				Replay Capability

Integrations
	Craft operations
		Geoscape to Craft
			Craft Assignment
			Pilot Selection
			Equipment Loading
			Deployment Preparation
		Basescape to Craft
			Maintenance Integration
			Repair Status
			Fuel Refill
			Equipment Upgrade
		Battlescape to Craft
			Craft Combat Outcome
			Damage Assessment
			Personnel Casualties
			Salvage Recovery
		Interception to Craft
			Interception Participation
			Health Changes
			Ammunition Consumption
			Victory/Defeat Impact

	Mission operations
		Mission Generation
			Mission Type Selection
			Difficulty Scaling
			Location Generation
			Reward Calculation
		Mission Execution
			Deployment Phase
			Active Combat Phase
			Objective Phase
			Extraction Phase
		Mission Results
			Squad Status Report
			Experience Distribution
			Resource Collection
			Consequence Application
		Experience & Rewards
			XP Calculation
			Resource Rewards
			Equipment Drops
			Achievement Unlock

	Unit operations
		Unit Recruitment
			Recruitment Source
			Training Timeline
			Equipment Assignment
			Squad Assignment
		Unit Deployment
			Squad Composition
			Equipment Loadout
			Deployment Location
			Briefing Delivery
		Unit Advancement
			Experience Accumulation
			Promotion Eligibility
			Specialization Unlock
			Stat Progression
		Unit Recovery
			Unconsciousness Timeline
			Medical Treatment
			Wound Recovery
			Return to Duty

AI
	Strategic AI (Geoscape)
		Faction AI Behavior
			UFO Construction
			Research Progress
			Territory Expansion
			Resource Accumulation
		Escalation Meter
			Threat Progression
			UFO Frequency Scaling
			Enemy Strength Scaling
			Time-Based Escalation
		Tactical Adaptation
			Counter-Unit Development
			Strategic Reaction
			Resource Reallocation
			Mission Type Variation
		Mission Generation Scaling
			Difficulty Increases
			Squad Composition Increases
			UFO Type Escalation
			Special Missions

	Diplomatic AI (Geoscape)
		Country Behavior
			Funding Allocation
			Diplomatic Actions
			Relationship Changes
			Territorial Claims
		Relationship Management
			Relationship Changes
			Funding Adjustments
			Mission Frequency
			Panic Influence
		Funding Adjustments
			Base Funding
			Performance Modifier
			Relationship Modifier
			Threat Modifier
		Supplier Behavior
			Inventory Changes
			Pricing Adjustments
			Availability Restrictions
			Market Dynamics

	Interception AI (Interception)
		UFO Behavior States
			Aggressive
				Attack Priority
				Weapon Usage
				Maneuver Pattern
			Tactical Withdrawal
				Damage Threshold
				Escape Route
				Speed Increase
			Escape
				Direction Priority
				Speed Maximum
				Defense Minimal
			Defensive
				Minimum Movement
				Focus Defense
				Evasion Priority
		UFO Attack Resolution
			Target Selection
			Weapon Selection
			Attack Timing
			Damage Calculation
		Survival Odds Calculation
			Health vs Damage
			Evasion vs Hit Chance
			Escape Distance
			Player Threat Assessment

	Tactical AI (Battlescape)
		Side-Level Strategy
			Objective Planning
			Territory Control
			Unit Coordination
			Resource Management
		Team Coordination
			Squad Communication
			Movement Synchronization
			Fire Support Planning
			Tactical Timing
		Squad Formation Mechanics
			Formation Selection
			Formation Adherence
			Formation Change Triggers
			Position Optimization
		Unit State Machine
			Idle State
			Moving State
			Attacking State
			Defensive State
			Panicked State
		Unit Target Selection Algorithm
			Threat Assessment
			Vulnerability Ranking
			Distance Calculation
			Priority Modification
		Unit Confidence System
			Confidence Gain
			Confidence Loss
			Behavior Impact
			Decision Modification
		Behavioral Effects
			Morale Impact
			Accuracy Modification
			Action Point Impact
			Aggression Level

	Economic AI (Basescape)
		Resource Management
			Resource Priority
			Consumption Planning
			Supply Forecasting
			Emergency Response
		Manufacturing Decisions
			Manufacturing Queue
			Product Priority
			Production Scheduling
			Constraint Management
		Research Prioritization
			Research Path Selection
			Technology Value Assessment
			Constraint Checking
			Queue Optimization
		Unit Recruitment Logic
			Squad Composition Planning
			Unit Type Selection
			Specialist Prioritization
			Supply Checking

Other
	Analytics
		Performance Metrics
			Frame Rate Tracking
			Load Time Measurement
			Memory Usage
			CPU Usage
		Player Statistics
			Hours Played
			Missions Completed
			Campaign Outcome
			Difficulty Setting Used
		Balance Data
			Unit Win Rates
			Equipment Usage
			Mission Type Frequency
			Economic Viability

	Assets
		Graphics & Sprites
			Unit Sprites
			Item Icons
			Building Tiles
			Environmental Assets
		Audio & Music
			Sound Effects
			Music Tracks
			Ambient Sounds
			Voice Lines
		UI Elements
			Widget Graphics
			Button States
			Panel Graphics
			Status Indicators
		Animation Data
			Unit Animations
			Combat Animations
			Transition Sequences
			Cutscene Animations

---

Fame System
	Fame Range & Levels
		Unknown (0-24)
		Known (25-59)
		Famous (60-89)
		Legendary (90-100)
	Gameplay Effects
		Mission Generation Boost
		Supplier Availability Tiers
		Public Confidence Mechanics
		Recruitment Quality Modifiers
		Funding Bonus Scaling
	Fame Sources
		Mission Success Impact
		UFO Destruction Rewards
		Base Raid Penalties
		Research Breakthrough Bonus
		Civilian Casualty Penalties
	Maintenance System
		Natural Decay Rate
		Inactivity Mechanics
		Active Operation Bonuses

Karma System
	Karma Range & Alignment Levels
		Evil (-100 to -75)
		Ruthless (-74 to -40)
		Pragmatic (-39 to -10)
		Neutral (-9 to +9)
		Principled (+10 to +40)
		Saint (+41 to +100)
	Karma Influences
		Available Contracts Access
		NPC Reactions & Outcomes
		Event Branching Mechanics
		Recruitment Preferences
		Faction Relations Effects
		Story Path Determination
	Karma Sources & Effects
		Civilian Impact (Kill/Save)
		Prisoner Treatment Options
		Interrogation Methods
		Humanitarian Mission Completion
		Black Market Engagement Costs
		Research Ethics Violations

Relationship System (Universal)
	Universal Relationship Scale
		Scale Definition (-100 to +100)
		Standard Thresholds
		Color-Coded Status
	Relationship Change Mechanics
		Change Rate Formula
		Standard Event Values (Positive)
		Standard Event Values (Negative)
		Relationship Momentum Effect
	Entity-Specific Modifiers
		Country Modifiers
			Fame Bonus Calculation
			Panic Penalty Application
			Funding Link Mechanics
		Supplier Modifiers
			Economic History Bonus
			Competitor Factor Penalty
		Faction Modifiers
			Karma Alignment Matching
			Military Pressure Decay
	Threshold Effects
		Country Thresholds (7 levels)
		Supplier Thresholds (7 levels)
		Faction Thresholds (7 levels)
	Special Relationship Events
		Diplomatic Crises
		Betrayal Mechanics
		Trust Breaking Consequences
		Permanent Relation Caps
	Diplomatic UI Elements
		Relationship Display
		Color-Coded Bar System
		Trend Arrows & Indicators
		Historical Graph Tracking
		Event Log Details

Black Market System
	Access Requirements & Tiers
		Unlocking the Black Market
		Access Tiers
		Entry Requirements
	Black Market Categories
		Restricted Units
			Elite Operatives
			Specialized Soldiers
			Alien Units
		Special Crafts
			Advanced Aircraft
			Submarine Variants
			Experimental Designs
		Illegal Items
			Prohibited Weapons
			Restricted Technology
			Controlled Materials
		Custom Missions
			Assassination Contracts
			Sabotage Operations
			Covert Actions
	Mission Generation & Events
		Mission Generation Mechanics
		Event Purchasing System
		Payment & Delivery
	Karma & Fame Impact
		Karma Penalties
		Fame Effects
		Discovery Consequences
	Corpse Trading System
		Corpse Acquisition
		Corpse Value Calculation
		Trading Mechanics
	Supplier Integration
		Black Market Suppliers
		Relationship Management
		Exclusive Inventory
	Risk & Consequences
		Discovery Mechanics
		Legal Consequences
		Faction Relations Impact

Advisors System
	Advisor Types
		Political Advisors
		Military Advisors
		Science Advisors
		Economic Advisors
	Advisor Bonuses
		Stat Modifications
		Resource Bonuses
		Operation Bonuses
	Advisor Traits
		Personality Types
		Special Abilities
		Interaction Mechanics
	Monthly Benefits
		Passive Income
		Research Bonuses
		Recruitment Bonuses

Power Points System
	Point Generation
		Generation Sources
		Generation Rate
		Accumulation Mechanics
	Point Usage
		Command Actions
		Strategic Maneuvers
		Emergency Powers
	Decision Trees
		Choice Points
		Consequence Branching
		Outcome Mechanics

Organization Level
	Level Thresholds
		Experience Requirements
		Unlock Conditions
		Progression Gates
	Level Benefits
		New Capabilities
		Stat Improvements
		Feature Unlocks
	Prestige & Rank
		Prestige Calculation
		Rank Advancement
		Rank-Based Effects

---


Global Systems
	Fame System
	Karma System
	Reputation System
	Panic Mechanics (Global)

Diplomatic System
	Country Relations
	Regional Blocs
	Funding Generation
	Supplier Integration

Politics System
	Government & Advisors
	Power Points

---


Lore Foundation
	Race
	Factions
	Faction System (Advanced)
		Faction Components
			Unit Classes & Leaders
			Campaign System
			Resource Economy
			Technology Research
			Mission Generation
		Faction Relationships
			Faction Conflicts
			Territorial Control
			Technology Sharing
			Alliance Mechanics
		Race Classifications
			Racial Categories
			Unit Type Assignments
			Cosmetic vs. Mechanical
			Thematic Organization

Detailed Faction System
	Syndicate / Man in Black
		Origin & Nature
			Temporal Origin (1815)
			True Identity & Goals
			Organization Structure
			Hidden Influence Network
		180-Year Conspiracy
			Conspiracy Timeline
			Key Events & Manipulations
			Technological Seeding
			Civilization Shaping
		Mechanic Integration
			Influence Mechanics
			Hidden Events
			Revelation Triggers
			Paradox Role
	Human Factions (Five Powers)
		Condor Cartel
			Territory & Resources
				Geographic Control
				Resource Types
				Population Base
			Unit Types & Specialization
				Military Doctrine
				Available Units
				Technology Alignment
				Combat Specialization
			Conflict Patterns & Goals
				Strategic Objectives
				Enemy Relationships
				Alliance Patterns
				Territory Ambitions
		European Concord
			Territory & Resources
				Geographic Control
				Resource Types
				Population Base
			Unit Types & Specialization
				Military Doctrine
				Available Units
				Technology Alignment
				Combat Specialization
			Conflict Patterns & Goals
				Strategic Objectives
				Enemy Relationships
				Alliance Patterns
				Territory Ambitions
		Siberian Bloc
			Territory & Resources
				Geographic Control
				Resource Types
				Population Base
			Unit Types & Specialization
				Military Doctrine
				Available Units
				Technology Alignment
				Combat Specialization
			Conflict Patterns & Goals
				Strategic Objectives
				Enemy Relationships
				Alliance Patterns
				Territory Ambitions
		Dragon's Eye
			Territory & Resources
				Geographic Control
				Resource Types
				Population Base
			Unit Types & Specialization
				Military Doctrine
				Available Units
				Technology Alignment
				Combat Specialization
			Conflict Patterns & Goals
				Strategic Objectives
				Enemy Relationships
				Alliance Patterns
				Territory Ambitions
		New Patriots
			Territory & Resources
				Geographic Control
				Resource Types
				Population Base
			Unit Types & Specialization
				Military Doctrine
				Available Units
				Technology Alignment
				Combat Specialization
			Conflict Patterns & Goals
				Strategic Objectives
				Enemy Relationships
				Alliance Patterns
				Territory Ambitions
	Third Race
		Nature & Origin
			Species Classification
			Biological Nature
			AI vs Biological Status
			Interdimensional Source
		Integration Points
			Gameplay Introduction
			Ally/Enemy Status
			Diplomatic Options
			Research Integration
		Alien Mechanics
			Unit Types
			Technology Tree
			Combat Specialization
			Psychological Resistance
		Conflict Resolution
			War Mechanics
			Peace Options
			Technology Exchange
			Ending Implications

Temporal World States
	Earth Geography Evolution
		Phase 0-1: Fractured World (1996-1998)
			Regional Powers Overview
			Territory Distribution
			Civilian Population
			Resource Availability
			Infrastructure Status
		Phase 2: Unified Opposition (1999-2001)
			Coalition Formation
			Territory Consolidation
			Unified Strategy Effects
			Population Movements
			Technology Disparity
		Phase 3: Underground Expansion (2001-2002)
			Lunar Base Establishment
			Underground Facility Growth
			Population Migration
			Resource Shift
			Communication Networks
		Phase 4: Final Assault (2002-2003)
			Invasion Escalation
			Territory Loss/Gain
			Population Crisis
			Infrastructure Damage
			Strategic Collapse Points
		Phase 5: Temporal Collapse (2003-2006)
			Anomaly Effects
			World State Instability
			Population Changes
			Resource Crisis
			Ending Conditions
	Territorial Control System
		Five Regional Powers
			Condor Cartel
				Territory & Locations
				Population & Resources
				Unit Specialization
				Conflict Patterns
				Alliance Mechanics
			European Concord
				Territory & Locations
				Population & Resources
				Unit Specialization
				Conflict Patterns
				Alliance Mechanics
			Siberian Bloc
				Territory & Locations
				Population & Resources
				Unit Specialization
				Conflict Patterns
				Alliance Mechanics
			Dragon's Eye
				Territory & Locations
				Population & Resources
				Unit Specialization
				Conflict Patterns
				Alliance Mechanics
			New Patriots
				Territory & Locations
				Population & Resources
				Unit Specialization
				Conflict Patterns
				Alliance Mechanics
		Disputed & Neutral Zones
			Warzones & Contested Areas
			Neutral Territories
			Collapse Status Regions
			Strategic Importance
			Mission Generation

Location System (Gameplay Integration)
	Earth Locations
		Strategic Locations System
			Military Installations
			Research Facilities
			Population Centers
			Resource Deposits
			Conflict Zones
		Urban Zones & Cities
			City Types
			Infrastructure Effects
			Civilian Presence
			Mission Environment
			Cover & Movement
		Remote Outposts
			Outpost Types
			Supply Chains
			Research Stations
			Radar Coverage
			Accessibility
		Underground Facilities
			Facility Types
			Access Methods
			Environment Effects
			Strategic Value
			Hidden Content
	Lunar Base (Phase 3+)
		Base Structure & Layout
		Research Capabilities
		Defense Systems
		Manufacturing Capacity
		Consciousness Integration Points
	Virtual World / Simulation (Late Game)
		Access Requirements & Unlocks
		Simulation Rules vs Reality
		Gameplay Differences
		Consciousness Integration
		Paradox Mechanics
		Exit Conditions
	Environmental Phase Shifts
		Climate Effects by Phase
			Weather Pattern Changes
			Seasonal Variations
			Environmental Hazards
		Resource Availability Changes
			Mineral & Fuel Shifts
			Technology Variations
			Research Gate Evolution
		Mission Type Variation
			Available Mission Types by Phase
			Difficulty Scaling
			Reward Evolution
			Objective Complexity

Missions & Events
	Missions generation
	Mission Generation & Types
		Mission Generation Triggers
			Faction Activity
			Country Requests
			Random Events
			Player-Initiated
			Black Market Missions
			Escalation Events
		Mission Types by Source
			Alien Faction Missions
			Country-Generated Missions
			Black Market Operations
			Special Event Missions
		Mission Objectives & Rewards
			UFO Crash Sites
			Interception Combat
			Terror Missions
			Defense Scenarios
			Research Objectives
		Mission Consequences
			Diplomatic Impact
			Faction Relations
			Campaign Escalation
			Resource Acquisition
	Events

Quest Framework
	Quests

Story & Victory
	Campaign (Structure & Escalation)
	Story (Campaign Phases)
	Victory Condition

Conspiracy & Truth Revelation System
	Secrets & Lies Mechanics
		The First Lie (Presentation)
			Surface Appearance
			False Understanding
			How Players Perceive It
			Consequences of Belief
		The Second Lie (Subversion)
			Hidden Reality Behind First Lie
			Deeper Deception
			Gameplay Impact of Understanding
			NPC Reactions to Discovery
		The Third Lie (Inversion)
			Ultimate Inversion of Truth
			Philosophical Complexity
			World State Implications
			Player Agency Questions
		The Final Truth (Revelation)
			Complete Reality Exposure
			Paradox Understanding
			Loop Mechanics Exposed
			Ending Implications
	Secret Unlock Conditions
		Requirements for Each Reveal
			Condition Triggers
			Timing Gates
			Story Progression Locks
		Order Dependencies
			Linear vs Branching Reveals
			Conditional Unlock Paths
			Alternative Discover Routes
		Philosophical Framework
			Epistemological Elements
			Moral Implications
			Player Choice Autonomy
		Narrative Consequences
			Story Branching Effects
			NPC Behavior Changes
			Mechanic Evolution Post-Reveal
			Ending Path Alterations
	Truth Impact on Gameplay
		Mechanic Changes Post-Reveal
			System Modifications
			New Mechanic Unlocks
			Existing System Alterations
		Unit Morale Shifts
			Psychological Impact
			Reaction Categories
			Recovery Mechanics
		Funding Impact
			Country Relations Changes
			Alliance Shifts
			Financial Consequences
		Mission Availability Changes
			New Mission Types Unlock
			Old Missions Unavailable
			Objective Modifications
			Difficulty Adjustments

#### Historical Background System (1815-1995)
- Timeline Discovery Mechanics
  - Pre-Campaign Timeline (1815-1870)
    - Early Conspiracy Formation
    - Industrial Revolution Integration
    - Technology Acceleration
    - Key Historical Events
  - Victorian Era (1870-1914)
    - Political Manipulation Evidence
    - Technological Acceleration Evidence
    - Economic Control Evidence
    - Hidden Influence Trail
  - World War Era (1914-1945)
    - Conflict Influence Mechanics
    - Technology Acquisition
    - Political Positioning
    - Casualty Records
  - Cold War Era (1945-1990)
    - Ideological Conflict Influence
    - Technological Race Manipulation
    - Geopolitical Positioning
    - Nuclear Development Influence
  - Modern Era (1990-1996)
    - Final Positioning
    - Faction Formation Evidence
    - Technology Preparation
    - Pre-Campaign Setup
- Conspiracy Era Research
  - Man in Black Influence Chain
    - Arrival & Integration (1815-1820)
    - Identity Creation Evidence
    - Financial Trail
    - Communication Network
  - Technology Acceleration Trail
    - Unexplained Inventions
    - Premature Discoveries
    - Research Funding Sources
    - Hidden Laboratories
  - Political Manipulation Evidence
    - Elections Influenced
    - Wars Orchestrated
    - Alliances Formed
    - Opposition Eliminated
  - Economic Control Systems
    - Banking Network Evidence
    - Corporate Control Trail
    - Resource Monopolies
    - Financial Transactions
- Documentary Access
  - Research Documents & Journals
    - Man in Black Records
    - Historical Accounts
    - Scientific Papers
    - Political Memoranda
  - Historical Database Unlocks
    - Timeline Verification
    - Evidence Correlation
    - Pattern Recognition
    - Conspiracy Confirmation
  - Timeline Revelation System
    - Progressive Unlock Gates
    - Research Requirements
    - Relationship Requirements
    - Chapter-Based Discovery
  - Player Discovery Mechanics
    - Document Fragment Finds
    - Interrogation Information
    - Research Breakthroughs
    - Event-Based Revelations

#### Campaign Phase System (Phase 0-5)
- Phase 0: Initiation (1996)
  - Phase Overview & Duration
  - Mechanics & Features Available
  - Unit Availability & Types
  - Threat Level & Scaling
  - Research Gates & Unlocks
  - Mission Types & Availability
- Phase 1: Regional Conflict (1997-1998)
  - Phase Overview & Duration
  - Mechanics & Features Available
  - Faction Escalation & Behavior
  - Regional Powers & Territory
  - Geopolitical Shifts & Events
  - Research Evolution
- Phase 2: Shadow War (1999-2001)
  - Phase Overview & Duration
  - Mechanics & Features Available
  - Unified Opposition Mechanics
  - Technology Evolution & Unlocks
  - Strategic Adjustments Available
  - Mission Complexity Increase
- Phase 3: Abyss & Moon (2001-2002)
  - Phase Overview & Duration
  - Mechanics & Features Available
  - Lunar Operations Unlock
  - Underground Networks Access
  - Consciousness Mechanics Introduction
  - New Unit Types & Equipment
- Phase 4: Final Enemy (2002-2003)
  - Phase Overview & Duration
  - Mechanics & Features Available
  - Endgame Threats & Escalation
  - Temporal Anomalies Introduction
  - Conspiracy Reveals Begin
  - Truth Mechanics Activation
- Phase 5: Final Retribution (2003-2006)
  - Phase Overview & Duration
  - Mechanics & Features Available
  - Loop Closure Mechanics
  - Truth Mechanics Full Integration
  - Multiple Victory Paths Unlock
  - Ending Variants & Consequences

#### Temporal Loop System
- Loop Structure & Mechanics
  - Bootstrap Paradox Framework
  - Causality Cycle (1815-2006)
  - Infinite Repetition Mechanics
  - Reset Mechanics & Triggers
  - Iteration Tracking System
- Loop Consequences
  - Knowledge Retention Mechanics
  - Resource Carryover Rules
  - Relationship Memory Persistence
  - Story Impact & Branching
  - Player Awareness Evolution
- Breaking the Loop
  - Loop Break Conditions
  - Paradox Resolution
  - Multiple Ending Mechanics
  - Time Paradox Handling
  - New Game+ Implications

#### Narrative Themes & Messaging System
- Core Philosophical Pillars
  - Causality & Determinism
    - Deterministic Positions
    - Libertarian Positions
    - Compatibilist Positions
    - Player Choice Consequences
  - Sacrifice & Cost of Victory
    - Personal Sacrifice Types
    - Moral Sacrifice Types
    - Material Sacrifice Types
    - Civilizational Sacrifice Types
  - Identity & Humanity
    - Biological Definition System
    - Consciousness Definition System
    - Moral Definition System
    - Cultural Definition System
  - Logic vs Ethics
    - Pure Logic Consequences
    - Rational vs Moral Dilemmas
    - AI Morality Framework
    - Player Ethical Choices
  - Eternal Return & Meaning
    - Nietzschean Framework
    - Loop Meaning Implications
    - Existential Philosophy
    - Purpose in Repetition
  - Truth & Deception
    - Layered Truth System
    - Hidden Information Framework
    - Epistemological Questions
    - Truth Discovery Progression
- Secondary Themes
  - Power & Corruption
    - Political Power Systems
    - Military Power Systems
    - Economic Power Systems
    - Corruption Mechanics
  - Technology & Consequence
    - Technological Progress Costs
    - Unintended Consequences
    - Research Ethics
    - Innovation Trade-offs
  - Memory & History
    - Historical Manipulation
    - Records & Verification
    - Memory Reliability
    - Information Control
  - Hope & Despair
    - Emotional Arc by Phase
    - Hope Maintenance Mechanics
    - Despair Thresholds
    - Acceptance Mechanics
- Player Experience Design
  - Emotional Journey by Phase
    - Phase 0-1 Confidence
    - Phase 2 Complexity
    - Phase 3 Horror
    - Phase 4 Existential Dread
    - Phase 5 Acceptance
  - Moral Choice Framework
    - Utilitarian Choices
    - Deontological Choices
    - Virtue-Based Choices
    - Care-Based Choices
  - Philosophical Questions System
    - Player Reflection Points
    - Discussion Prompts
    - Thematic Foreshadowing
    - Resolution Opportunities
- Thematic Delivery Methods
  - Visual Theme Expression
    - Color Palette Evolution
    - Environmental Storytelling
    - Aesthetic Progression
    - Faction Symbolism
  - Audio Theme Expression
    - Musical Theme Progression
    - Sound Design Philosophy
    - Emotional Resonance
    - Ambient Atmosphere
  - Narrative Structure
    - Five-Act Tragedy Framework
    - Greek Tragedy Elements
    - Character Arc Integration
    - Climactic Moments
  - Artistic Direction
    - Visual Consistency
    - Aesthetic Evolution
    - Location Atmosphere
    - Temporal Environment Shifts

#### Finance & Score System
- Score System
  - Score Calculation & Tracking
    - Score Gains
    - Score Losses
    - Monthly Aggregation
    - Provincial Scoring
  - Country Scoring
    - Regional Aggregation
    - Country-Level Totals
    - Score Impact
- Country Funding
  - Funding Calculation
    - Country Economy
    - Defense Budget Allocation
    - Relationship Modifiers
    - Funding Levels
  - Income Sources
    - Country Contributions
    - Supplier Agreements
    - Mission Rewards
    - Salvage Income
    - Research Sales
  - Expenses
    - Personnel Costs
    - Equipment Maintenance
    - Facility Upkeep
    - Research Costs
    - Manufacturing Costs
- Budget & Cash Flow
  - Monthly Budget
  - Cash Flow Analysis
  - Debt Management
  - Bankruptcy Mechanics
- Advanced Scenarios
  - Economic Crises
  - Resource Bottlenecks
  - Strategic Investments
- Monthly Financial Report
  - Income Summary
  - Expense Breakdown
  - Balance Sheet
  - Trend Analysis

---

#### System Dependencies & Coupling
- Geoscape Dependencies
  - Direct Integrations
  - Indirect Integrations
  - Key Interfaces
- Basescape Dependencies
  - Hub System Role
  - Equipment & Unit Data
  - Facility Interactions
- Battlescape Dependencies
  - Combat State Tracking
  - Map Block Generation
  - AI Behavior Logic
- Cross-Layer Data Flow
  - Vertical Integration
  - Horizontal Coupling
  - State Persistence

---

#### Craft Operations
- Geoscape ↔ Craft
- Basescape ↔ Craft
- Battlescape ↔ Craft
- Interception ↔ Craft

#### Mission Operations
- Mission Generation → Execution → Results
- Experience & Rewards Distribution
- Squad Status Reporting

#### Unit Operations
- Unit Recruitment → Training → Deployment
- Unit Advancement → Recovery
- Squad Management

---

#### Strategic AI (Geoscape)
- Faction AI Behavior
  - UFO Construction
  - Research Progress
  - Territory Expansion
  - Resource Accumulation
- Faction Decision Algorithm
  - Threat Assessment
  - Resource Evaluation
  - Action Selection
  - Escalation Triggers
- Country & Supplier AI
  - Country Behavior
  - Supplier Behavior
  - Mission Generation AI
- Campaign Escalation Mechanics
  - Escalation Meter
  - Escalation Thresholds
- Escalation Meter
- Tactical Adaptation
  - Counter-Unit Development
  - Strategic Reaction
  - Resource Reallocation
- Mission Generation Scaling
  - Difficulty Increases
  - Squad Composition Increases
  - UFO Type Escalation

#### Diplomatic AI (Geoscape)
- Country Behavior
- Relationship Management
- Funding Adjustments
- Supplier Behavior

#### Interception AI (Interception)
- UFO Behavior States
- UFO Attack Resolution
- Survival Odds Calculation

#### Tactical AI (Battlescape)
- Side-Level Strategy
  - Faction Alignment & Engagement Rules
  - Side Strategy Selection
- Team Coordination
  - Team Composition & Roles
  - Squad Movement Synchronization
  - Fire Support Planning
- Squad Formation Mechanics
  - Formation Selection
  - Formation Adherence
  - Formation Change Triggers
- Unit State Machine
  - Idle State
  - Moving State
  - Attacking State
  - Defensive State
  - Panicked State
- Unit Target Selection Algorithm
  - Threat Assessment
  - Vulnerability Ranking
  - Distance Calculation
  - Priority Modification
- Unit Confidence System
  - Confidence Gain
  - Confidence Loss
  - Behavior Impact
- Behavioral Effects
  - Morale Impact
  - Accuracy Modification
  - Action Point Impact
  - Aggression Level

#### Economic AI (Basescape)
- Resource Management
- Manufacturing Decisions
- Research Prioritization
- Unit Recruitment Logic

#### Character Archetype System
- Commander Archetype
  - Leadership Traits
    - Charisma Modifier
    - Command Presence
    - Decision Authority
    - Crisis Management
  - Decision Making Style
    - Aggressive Leadership
    - Conservative Leadership
    - Balanced Leadership
    - Adaptive Leadership
  - Command Bonuses
    - Squad Morale Boost
    - Accuracy Bonus
    - Research Speed Bonus
    - Tactical Initiative
  - Character Arc Potential
    - Leadership Growth
    - Moral Dilemmas
    - Command Failures
    - Redemption Opportunities
- Scientist Archetype
  - Research Specializations
    - Weapons Research Focus
    - Armor Research Focus
    - Alien Tech Focus
    - Facility Research Focus
  - Technical Brilliance
    - Research Speed Modifier
    - Discovery Chance Boost
    - Innovation Breakthrough
    - Theoretical Knowledge
  - Personality Types
    - Cautious Scientist
    - Reckless Innovator
    - Pragmatic Engineer
    - Idealistic Researcher
  - Discovery Events
    - Research Breakthrough Events
    - Failed Experiment Events
    - Ethical Dilemma Events
    - Knowledge Transfer Events
- Soldier Archetype
  - Combat Specializations
    - Infantry Specialist
    - Marksman Specialist
    - Heavy Weapons Specialist
    - Support Specialist
  - Tactical Roles
    - Squad Lead
    - Flanker
    - Support Unit
    - Scout
  - Experience Progression
    - Novice to Veteran
    - Specialization Development
    - Weapon Mastery
    - Survival Improvement
  - Veteran Traits
    - Battle-Hardened Bonus
    - Scar Mechanics (injury effects)
    - Combat Intuition
    - PTSD Mechanics
- Political Operative Archetype
  - Diplomacy Skills
    - Negotiation Ability
    - Persuasion Modifier
    - Deception Skill
    - Reading People
  - Information Gathering
    - Intelligence Collection
    - Espionage Capability
    - Sabotage Ability
    - Faction Infiltration
  - Faction Manipulation
    - Relationship Influence
    - Alliance Brokering
    - Enemy Sowing
    - Reputation Control
  - Relationship Building
    - Trust Development
    - Loyalty Mechanics
    - Betrayal Potential
    - Secret Keeping
- Civilian Archetype
  - Survival Traits
    - Stress Resistance
    - Resourcefulness
    - Improvisation Ability
    - Scavenging Skill
  - Moral Complexity
    - Ethical Dilemmas
    - Survival vs Morality
    - Faction Allegiance
    - Sacrifice Willingness
  - Non-Combat Roles
    - Engineering Support
    - Medical Support
    - Administrative Support
    - Morale Support
  - Evacuation Priority
    - Priority Tier System
    - Special Requirements
    - Family Mechanics
    - Legacy System
- Hybrid Consciousness Archetype
  - Alien-Human Mix
    - Hybrid Creation
    - Genetic Composition
    - Appearance Variation
    - Biological Compatibility
  - Moral Status
    - Sentience Questions
    - Rights Framework
    - Acceptance Mechanics
    - Society Integration
  - Special Abilities
    - Unique Psychic Powers
    - Physical Enhancements
    - Alien Tech Affinity
    - Consciousness Bridging
  - Loyalty Mechanics
    - Trust Building (Difficult)
    - Betrayal Risk
    - Defection Possibilities
    - Identity Conflict

#### Advanced Mission Generation System
- Mission Types (Expanded & Detailed)
  - UFO Operations
    - UFO Crash Recovery
      - Mission Trigger: Radar detection + choice
      - Objective: Recover alien craft
      - Complications: Alien salvage competition
      - Reward: Equipment + resources
    - UFO Interception
      - Mission Trigger: UFO detected in flight
      - Objective: Destroy/disable UFO
      - Complications: Combat difficulty
      - Reward: Direct combat rewards
    - UFO Tracking
      - Mission Trigger: UFO sighting
      - Objective: Follow UFO to base
      - Complications: Navigation challenge
      - Reward: Map knowledge + base location
    - UFO Assault
      - Mission Trigger: Player initiative
      - Objective: Attack alien structure
      - Complications: Fortified position
      - Reward: Major loot
  - Alien Base Operations
    - Alien Base Assault
    - Alien Base Capture
    - Alien Research Facility Raid
    - Alien Infrastructure Sabotage
  - Terror Operations
    - Terror Mission Response
    - Hostage Rescue
    - Terror Cell Elimination
    - Civilian Defense
  - Strategic Operations
    - Research Facility Recovery
    - Supply Raid
    - Equipment Acquisition
    - Intelligence Gathering
  - Black Market Missions
    - Custom Missions
    - Procurement Contracts
    - Assassination Contracts
    - Corporate Missions
- Mission Generation Algorithm (Complete)
  - Trigger Conditions
    - Calendar-Based Triggers
      - Monthly mission availability
      - Escalation-driven missions
      - Predefined story missions
    - Event-Based Triggers
      - Player action consequences
      - Diplomatic incidents
      - Technology breakthroughs
    - Escalation-Based Triggers
      - Threat level increases
      - Enemy aggression
      - Resource availability
    - Player-Triggered Options
      - Manual mission requests
      - Craft deployments
      - Investigation options
  - Mission Assembly
    - Location Selection
      - Terrain Type Selection
      - Strategic Location Choice
      - Environmental Conditions
    - Enemy Force Generation
      - Unit Type Selection
      - Squad Composition
      - Equipment Loadout
    - Objective Assignment
      - Primary Objective
      - Secondary Objectives
      - Hidden Objectives
    - Reward Calculation
      - Base Reward Amount
      - Multiplier Modifiers
      - Bonus Calculations
  - Difficulty Scaling
    - Enemy Stats
      - Health Scaling
      - Damage Scaling
      - Armor Scaling
    - Map Complexity
      - Terrain Difficulty
      - Environmental Hazards
      - Reinforcement Patterns
    - Objective Difficulty
      - Complexity Rating
      - Time Pressure
      - Success Requirements
    - Reward Multiplier
      - Difficulty bonus (1.0 - 2.0x)
      - Scaling formula
- Mission Parameters (Detailed)
  - Location Mapping
    - Terrain Type Selection
      - Urban Terrain
      - Wilderness Terrain
      - Industrial Terrain
      - Alien Terrain
    - Facility Type Selection
      - Building Type
      - Facility Size
      - Defensive Features
    - Environmental Hazards
      - Weather Conditions
      - Radiation Zones
      - Temporal Anomalies
    - Strategic Placement
      - Cover Placement
      - Spawn Points
      - Objective Location
  - Enemy Force Composition
    - Unit Type Selection
      - Alien species selection
      - Unit class distribution
      - Special units inclusion
    - Squad Formation
      - Formation Type
      - Position Spacing
      - Tactical Grouping
    - Equipment Loadout
      - Weapon Assignment
      - Armor Assignment
      - Special Equipment
    - Tactical Positioning
      - Defensive Positions
      - Ambush Points
      - Retreat Routes
  - Objective Definition
    - Primary Objectives
      - Elimination
      - Capture
      - Rescue
      - Escort
    - Secondary Objectives
      - Resource collection
      - Tactical objectives
      - Optional targets
    - Hidden Objectives
      - Developer goals
      - Easter eggs
      - Special requirements
    - Optional Objectives
      - Bonus achievements
      - Extra rewards
      - Challenge goals
  - Rewards System
    - Base Reward Calculation
      - Formula: (Difficulty × Base Value × Escalation)
      - Credit rewards
      - Resource rewards
    - Multiplier Modifiers
      - Difficulty multiplier
      - Performance multiplier
      - Bonus multiplier
    - Bonus Rewards
      - Perfect completion bonus
      - Speed bonus
      - Casualty reduction bonus
    - Discovery Items
      - Unique equipment
      - Research points
      - Story items
- Mission Difficulty Tiers (Complete)
  - Easy (Newcomer)
    - Difficulty: 1x base
    - Recommended Rank: 1-2
    - Enemy Count: 4-6
    - Threat Level: Low
  - Normal (Standard)
    - Difficulty: 1.5x base
    - Recommended Rank: 3-4
    - Enemy Count: 8-12
    - Threat Level: Medium
  - Hard (Veteran)
    - Difficulty: 2.0x base
    - Recommended Rank: 5-6
    - Enemy Count: 12-16
    - Threat Level: High
  - Impossible (Mastery)
    - Difficulty: 3.0x base
    - Recommended Rank: 6 (elite)
    - Enemy Count: 16+
    - Threat Level: Extreme
- Special Mission Types
  - Campaign Missions
    - Story-critical missions
    - Predetermined outcomes
    - Forced completion
  - Story Missions
    - Narrative progression
    - Character development
    - Relationship impacts
  - Research Missions
    - Technology discovery
    - Blueprint acquisition
    - Knowledge advancement
  - Rare Encounters
    - Unique enemies
    - Legendary items
    - Epic story moments

---

#### Analytics
- Stage 1: Autonomous Simulation & Log Capture
  - Simulation Types
  - Dual AI Architecture
  - Log Structure & Format
- Stage 2: Data Aggregation & Processing
  - Data Pipeline Architecture
  - Parquet Schema Definition
  - Automated Data Processing
  - Data Quality Assurance
- Stage 3: Metric Calculation
  - Combat System Analysis
  - Economic System Analysis
  - Strategic Layer Analysis
  - Gameplay Pattern Analysis
- Stage 4: Insights & Visualization
  - Dashboard Creation
  - Trend Analysis
  - Anomaly Detection
- Stage 5: Action Planning
  - Balance Recommendations
  - Implementation Prioritization
  - Testing & Validation
#### Test Scenarios & QA Framework (Comprehensive)
- Unit Testing Scenarios
  - Unit Stat Validation
    - Health Calculations
    - Damage Resistance
    - Movement Speed
    - Action Point Allocation
    - Experience Progression
  - Unit Advancement Testing
    - Promotion Requirements Met
    - Stat Progression Accurate
    - Perk Acquisition Valid
    - Trait Application Correct
  - Unit Status Effects
    - Status Application
    - Duration Tracking
    - Effect Resolution
    - Recovery Mechanics
- Combat Testing Scenarios
  - Basic Combat Flow
    - Initiative Calculation
    - Turn Order Accuracy
    - Action Resolution
    - Outcome Application
  - Damage & Armor System
    - Damage Type Interactions
    - Armor Effectiveness
    - Critical Hits
    - Damage Calculation Accuracy
  - Line of Sight & Fire
    - LOS Calculation
    - Cover Effectiveness
    - Fire Position Validation
    - Accuracy Modifiers
  - Tactical Movement
    - Pathfinding Accuracy
    - Movement Cost Calculation
    - Terrain Interaction
    - Blocked Path Resolution
  - Special Abilities
    - Ability Activation
    - Resource Cost Deduction
    - Effect Application
    - Range Validation
- Basescape Testing Scenarios
  - Facility Placement
    - Grid Validation
    - Connection Rules
    - Adjacency Bonuses
    - Overlap Prevention
  - Facility Operation
    - Power Consumption
    - Staff Requirements
    - Production Output
    - Upgrade Progression
  - Resource Management
    - Income Calculation
    - Expense Tracking
    - Budget Balancing
    - Overflow Handling
  - Research Progression
    - Technology Unlock
    - Prerequisites Met
    - Research Speed
    - Completion Trigger
- Geoscape Testing Scenarios
  - UFO Detection
    - Radar Range Calculation
    - UFO Spawn Validation
    - Movement Pattern
    - Interception Attempt
  - Territory Control
    - Hexagon Ownership
    - Control Point Calculation
    - Influence Spread
    - Territory Loss
  - Diplomatic Relations
    - Reputation Calculation
    - Faction Impact
    - Country Impact
    - Threshold Triggers
- Campaign System Testing
  - Campaign Initialization
    - Starting Resources
    - Initial Base Setup
    - Squad Recruitment
    - First Mission Generation
  - Milestone Progression
    - Month Advancement
    - Event Triggering
    - Phase Transitions
    - Story Gate Activation
  - Victory/Defeat Conditions
    - Victory Path Validation
    - Defeat Path Validation
    - Condition Checking
    - Outcome Application
- Edge Case Testing
  - Boundary Conditions
    - Minimum Stat Values
    - Maximum Stat Values
    - Resource Overflow/Underflow
    - Array Index Bounds
  - Rare Occurrences
    - Simultaneous Events
    - Conflicting Effects
    - Impossible Conditions
    - Recovery Scenarios
  - Error States
    - Invalid Input Handling
    - Data Corruption Recovery
    - State Inconsistency
    - Graceful Fallback
- Mechanical Balance Testing
  - Combat Balance
    - Weapon Balance
      - Damage vs Range Trade-off
      - Accuracy vs Damage Trade-off
      - Fire Rate vs Damage Trade-off
      - Special Ability Balance
    - Unit Balance
      - Class Power Levels
      - Stat Distribution
      - Ability Effectiveness
      - Perk Interactions
    - Difficulty Balance
      - Easy: Win Rate 70-80%
      - Normal: Win Rate 50-60%
      - Hard: Win Rate 30-40%
      - Impossible: Win Rate < 20%
  - Resource Economy Balance
    - Income vs Expense
      - Monthly Income Target
      - Monthly Expense Target
      - Surplus Margin
      - Emergency Fund
    - Research Speed
      - Early Tech: Quick (1-3 months)
      - Mid Tech: Moderate (4-8 months)
      - Late Tech: Slow (9-15 months)
    - Facility Progression
      - Start with 1 base
      - Facility buildout timeline
      - Upgrade progression
      - Final capacity reach
  - Progression Balance
    - Experience Curve
      - Early Level: Quick progression
      - Mid Level: Standard progression
      - Late Level: Slow progression
      - Max Level: Achievement
    - Equipment Progression
      - Weapon Power Scaling
      - Armor Effectiveness
      - Upgrade Value
      - Rarity Impact
    - Technology Tree
      - Research Times Scaled
      - Prerequisite Dependencies
      - Branch Viability
      - Hidden Tech Access
- Performance & Load Testing
  - Frame Rate Validation
    - Target: 60 FPS maintained
    - Stress Test Scenarios
      - Large Squad Combat (12+ units)
      - Large Map (100+ hexes)
      - Visual Effects (20+ active)
      - Concurrent Events (10+ triggers)
    - Performance Degradation
      - Acceptable drop to 30 FPS
      - Detection mechanism
      - Auto-scaling trigger
  - Memory Testing
    - Baseline Memory Usage
      - Menu State: < 256 MB
      - Game State: 512-768 MB
      - Combat State: 768-1024 MB
      - Max State: < 2 GB
    - Memory Leak Detection
      - Runtime Monitoring
      - Long Session Testing (8+ hours)
      - Repeated State Transitions
      - Memory Profile Analysis
  - Load Time Validation
    - Fast Load Target
      - Game Startup: < 5 seconds
      - Level Load: < 3 seconds
      - Menu Transition: < 1 second
      - Save/Load: < 2 seconds
  - Asset Streaming
    - Streaming Efficiency
      - Preload Distance
      - Cache Strategy
      - Priority System
      - Eviction Policy
- Scenario-Based Testing
  - Scripted Test Missions
    - Mission 1: Basic Tutorial
      - Objectives: Simple (eliminate 3 enemies)
      - Win Condition: Objective completion
      - Expected Result: Successful completion
    - Mission 2: Intermediate Challenge
      - Objectives: Complex (escort + defend)
      - Win Condition: Multiple objectives
      - Expected Result: Achievable with strategy
    - Mission 3: Extreme Challenge
      - Objectives: Desperate (survive impossible)
      - Win Condition: Survival duration
      - Expected Result: High difficulty
  - Campaign Simulation
    - Simulate Full Campaign
      - Play through complete 24-month campaign
      - Record all events & outcomes
      - Validate victory/defeat conditions
      - Test all story branches
    - Rapid Campaign Test
      - Accelerated time (10x speed)
      - Automated player decisions
      - Record anomalies
      - Generate statistics
  - Stress Test Scenarios
    - Maximum Scale Test
      - 12-squad players vs 20-alien army
      - 100+ entity render test
      - 10+ simultaneous effects
      - Deep procedural generation
    - Exploit Testing
      - Resource duplication attempts
      - Infinite XP methods
      - Sequence breaking
      - Unintended strategies
- QA Validation Checklists
  - Gameplay Completeness
    - ☐ All mechanics implemented
    - ☐ All content created
    - ☐ All interactions tested
    - ☐ Balance verified
    - ☐ Polish applied
  - Technical Quality
    - ☐ No critical bugs
    - ☐ < 10 major bugs
    - ☐ < 50 minor bugs
    - ☐ Frame rate stable
    - ☐ Memory stable
  - User Experience
    - ☐ UI Clear and intuitive
    - ☐ Tutorial complete
    - ☐ Help system functional
    - ☐ Error messages clear
    - ☐ Accessibility compliance
  - Content Completeness
    - ☐ Story complete
    - ☐ All missions generated
    - ☐ All units available
    - ☐ All facilities functional
    - ☐ All technologies researchable
  - Balance Verification
    - ☐ Win/Loss ratio acceptable
    - ☐ Resource economy balanced
    - ☐ Progression curve smooth
    - ☐ Difficulty scaling correct
    - ☐ No dominant strategies
- Automated Testing Infrastructure
  - Unit Test Suite
    - Campaign System Tests
      - Test: Month advancement
      - Test: Resource calculation
      - Test: Event triggering
      - Expected: All assertions pass
    - Combat System Tests
      - Test: Damage calculation
      - Test: Accuracy determination
      - Test: Effect application
      - Expected: Deterministic results
    - Equipment System Tests
      - Test: Stat modification
      - Test: Item combination
      - Test: Durability tracking
      - Expected: Correct modifications
  - Integration Test Suite
    - Geoscape ↔ Mission Integration
    - Mission ↔ Basescape Integration
    - Basescape ↔ Research Integration
    - Campaign ↔ All Systems Integration
  - Regression Test Suite
    - Previous Version Compatibility
    - Bug Fix Verification
    - Performance Regression Check
    - Content Integrity Validation

#### Implementation & Technical Standards (Guidelines)
- Coordinate System Requirements
  - Axial Storage Format
  - Q-R Value Ranges
  - Boundary Validation
  - Coordinate Normalization
- Calculation Hierarchy
  - Storage Layer (Axial)
  - Processing Layer (Cube)
  - Rendering Layer (Pixel)
  - Conversion Points
- API Consistency
  - Function Signatures
    - Unit Movement
    - Pathfinding
    - Distance Calculation
    - Neighbor Detection
  - Parameter Naming
    - Q Coordinate Names
    - R Coordinate Names
    - Avoid Confusion
  - Return Values
    - Success Indicators
    - Error Handling
    - Exception Cases
- Documentation Standards
  - Function Documentation
    - System Description
    - Parameter Description
    - Coordinate System Specification
    - Return Value Documentation
  - Code Comments
    - Calculation Logic
    - Conversion Formulas
    - Non-Obvious Behavior
  - Design Rationale
    - Why Vertical Axial
    - Trade-offs Accepted
    - Visual Consequences
- Data Structure Standards
  - Unit Data Format
  - Map Tile Format
  - Coordinate Storage
  - State Management
- Testing Standards
  - Unit Test Coverage
  - Integration Points
  - Edge Cases
  - Performance Baselines
- Modding Standards
  - API Exposure
  - Extension Points
  - Constraint Documentation
  - Compatibility Guarantees

#### Performance & Optimization
- Frame Rate Targets
- Memory Budgets
- Asset Streaming Strategy
- Load Time Optimization
- Cache Management
- Atlasing Strategy

#### Rendering System
- Asset Atlasing
  - Texture Atlas Organization
  - Sprite Sheet Optimization
- Tileset System
  - Autotiles
  - Random Variants
  - Animations
  - Directional Variants
  - Static Tiles
- Asset Caching
  - Memory Cache
  - Disk Cache
  - GPU Memory
  - Cache Invalidation
- Asset Pipeline
  - Asset Creation Workflow
  - Asset Streaming
  - Memory Budgets
- Mod Asset Integration
  - Asset Override System
  - Asset Fallbacks
  - Mod Validation

#### Assets & Resource Pipeline
- Asset Types & Organization
  - Graphics & Sprites
    - Pixel Art Assets
    - Spritesheet Organization
    - Tileset System
  - Audio Resources
    - Music Tracks
    - Sound Effects
    - Voice Acting
  - Data Files (TOML)
    - Game Content
    - Mod Definitions
- Asset Pipeline & Workflow
  - Asset Creation Workflow
    - Design Phase
    - Production Phase
    - Integration Phase
  - Asset Validation
    - Format Checking
    - Size Validation
    - Compatibility Testing
- Resource Management & Optimization
  - Asset Caching System
    - Cache Loading
    - Memory Budgets
    - Eviction Policies
  - Atlasing Strategy
    - Sprite Batching
    - Texture Optimization
    - Draw Call Reduction

#### Technology Specifications (Lore-Tied)
- Human Conventional Weapons (Phase 0-2)
  - Pistols Classification
    - Revolver Types
    - Semi-Auto Pistols
    - Caliber Variations
    - Accuracy vs Firepower
  - Rifles Classification
    - Assault Rifles
    - Designated Marksman Rifles
    - Sniper Rifles
    - Carbines
  - Shotguns Classification
    - Pump-Action Shotguns
    - Semi-Auto Shotguns
    - Combat Shotguns
    - Breaching Shotguns
  - Machine Guns Classification
    - Light Machine Guns
    - Medium Machine Guns
    - Heavy Machine Guns
    - Ammunition Feed Systems
  - Explosives Classification
    - Hand Grenades
    - Explosive Charges
    - Landmines
    - Improvised Weapons
- Alien Plasma Technology (Phase 2+)
  - Plasma Weapon Mechanics
    - Energy Requirements
    - Beam Characteristics
    - Firing Patterns
    - Heat Output
  - Plasma Generation Systems
    - Plasma Core Technology
    - Energy Containment
    - Discharge Mechanisms
    - Regeneration Rates
  - Thermal Effects
    - Heat Damage Zone
    - Environmental Burning
    - Armor Degradation
    - Collateral Damage
  - Armor Penetration
    - Energy Decay
    - Resistance Calculations
    - Shield Interaction
    - Thickness Penetration
- Hybrid Technology (Phase 3+)
  - Human-Alien Fusion Weapons
    - Plasma-Kinetic Hybrids
    - Balanced Damage Types
    - Enhanced Accuracy
    - Reduced Power Draw
  - Captured Tech Integration
    - Reverse Engineering System
    - Tech Trees Unlocked
    - Manufacturing Requirements
    - Efficiency Improvements
  - Reverse Engineering Benefits
    - Cost Reduction
    - Performance Enhancement
    - Maintenance Simplification
    - Modification Potential
  - Technology Synergy
    - Combined Effect Multipliers
    - Complementary Tech Pairings
    - Emergent Capabilities
    - Unexpected Synergies
- Cybernetic Enhancement (Phase 4+)
  - Organic Enhancement
    - Neural Implants
    - Muscular Augmentation
    - Sensory Enhancement
    - Cognitive Boosters
  - Neural Integration
    - Brain-Computer Interface
    - Consciousness Upload
    - Memory Integration
    - Control Seamlessness
  - Combat Modifications
    - Weapon Integration
    - Reflex Enhancement
    - Pain Suppression
    - Combat Awareness
  - Ethical Implications
    - Humanity Loss Mechanics
    - Conversion Costs
    - Identity Preservation
    - Reversibility Questions
- Portal Technology (Phase 3-5)
  - Temporal Navigation
    - Time Travel Mechanics
    - Destination Constraints
    - Paradox Prevention
    - Energy Requirements
  - Spatial Teleportation
    - Short-Range Teleportation
    - Long-Range Teleportation
    - Accuracy Degradation
    - Biological Compatibility
  - Risk & Consequences
    - Teleportation Accidents
    - Genetic Degradation
    - Lost Personnel
    - Temporal Anomalies
  - Control Mechanics
    - Activation Requirements
    - Destination Selection
    - Energy Consumption
    - Cooldown Periods
- Spacecraft Evolution
  - Early Craft (Phase 0-1)
    - Converted Civilian Aircraft
    - Military Transport Vehicles
    - Weaponized Helicopters
    - Fuel Limitations
  - Advanced Craft (Phase 2-3)
    - Hybrid Propulsion Systems
    - Plasma Weapon Integration
    - Advanced Armor
    - Tactical Systems
  - Hybrid Craft (Phase 4)
    - Human-Alien Design
    - Portal Integration
    - Advanced AI Control
    - Autonomous Systems
  - Experimental Craft (Phase 5)
    - Desperate Technology
    - Untested Designs
    - Suicidal Capabilities
    - Final Effort Weapons
- Facility Technology by Phase
  - Early Infrastructure (Phase 0-1)
    - Basic Shelters
    - Military Outposts
    - Research Tents
    - Manual Manufacturing
  - Advanced Systems (Phase 2-3)
    - Automated Research Labs
    - Plasma Reactors
    - Advanced Manufacturing
    - Alien Tech Integration
  - Hybrid Systems (Phase 4)
    - AI-Controlled Facilities
    - Cybernetic Management
    - Autonomous Production
    - Consciousness Integration
  - Desperation Tech (Phase 5)
    - Jury-Rigged Systems
    - Overclocked Equipment
    - Dangerous Modifications
    - Last-Stand Infrastructure

#### Assets
- Graphics & Sprites
- Audio & Music
- UI Elements
- Animation Data

#### Philosophical Framework Reference
- Determinism vs Free Will Debate
  - Deterministic Positions
    - Causal Chain View
    - Prediction Theory
    - Fatalism Framework
    - Consequence Acceptance
  - Libertarian Positions
    - Quantum Randomness
    - Conscious Will Theory
    - Agent Causation
    - Moral Responsibility
  - Compatibilist Positions
    - Determinism + Freedom
    - Will as Desire
    - Meaningful Choice
    - Reconciliation Framework
  - Player Choice Impact
    - Narrative Consequences
    - Character Responses
    - World State Changes
    - Moral Development
- Identity Philosophy
  - Biological Definition
    - DNA Analysis
    - Genetic Identity
    - Species Markers
    - Physical Continuity
  - Consciousness Definition
    - Self-Awareness
    - Sentience Markers
    - Emotional Capacity
    - Memory Integration
  - Moral Definition
    - Capacity for Ethics
    - Rights Consideration
    - Personhood Status
    - Moral Agency
  - Cultural Definition
    - Social Acceptance
    - Community Integration
    - Shared Values
    - Cultural Continuity
- Ethics System Integration
  - Utilitarian Framework
    - Greatest Good Principle
    - Consequence Focus
    - Cost-Benefit Analysis
    - Population Ethics
  - Deontological Framework
    - Duty-Based Actions
    - Rule Following
    - Intrinsic Right/Wrong
    - Principle Priority
  - Virtue Ethics Framework
    - Character Development
    - Moral Virtue
    - Excellence Pursuit
    - Personal Growth
  - Care Ethics Framework
    - Relationship Focus
    - Emotional Connection
    - Contextual Morality
    - Empathy Integration
- Epistemology (Ways of Knowing)
  - Empirical Knowledge
    - Observation-Based
    - Evidence Gathering
    - Scientific Method
    - Verification Process
  - Rational Knowledge
    - Logic-Based
    - Mathematical Proofs
    - Deductive Reasoning
    - Internal Consistency
  - Intuitive Knowledge
    - Gut Feeling
    - Pattern Recognition
    - Instinctive Understanding
    - Non-Rational Knowledge
  - Revealed Knowledge
    - Sacred Texts
    - Authority Sources
    - Testimony Credibility
    - Belief Systems
- Truth Revelation Mechanics
  - Layered Truth System
    - Surface Truth
    - Hidden Reality
    - Deeper Truth
    - Final Truth
  - Progressive Discovery
    - Unlock Gates
    - Research Requirements
    - Story Triggers
    - Chapter Progression
  - Philosophical Implications
    - Meaning Changes
    - Character Responses
    - World Perspective Shift
    - Player Understanding
  - Player Interpretation
    - Ambiguous Conclusions
    - Multiple Valid Views
    - Personal Meaning
    - Thematic Resonance

#### GUI System Reference
- Scene System
  - Full-Screen Scenes
    - Scene Types & Purpose
    - Scene Lifecycle
    - Event System
    - Input Events
  - Modal Dialogs
    - Dialog Types
    - Modal Behavior
    - Stack Management
  - Transition Animations
    - Fade Effects
    - Slide Transitions
    - Custom Animations
- Widget System
  - Interactive Components
    - Buttons & Toggles
    - Panels & Containers
    - Text & Input Fields
    - Sliders & Knobs
    - Dropdowns & Lists
    - Grids & Tables
    - Scroll Views
    - Progress Bars
    - Tabs
  - Widget Properties
    - Position & Size
    - Visibility & Opacity
    - Enabled State
    - Style & Theming
    - Anchoring & Layout
    - Tooltips & Help
    - Animations & Transitions
- Layout Systems
  - Anchor-Based Layout
    - Fixed Positioning
    - Edge Anchoring
    - Relative Positioning
  - Grid Layout
    - Automatic Grid
    - Column Spanning
    - Row Spanning
  - Flow Layout
    - Horizontal Flow
    - Vertical Flow
    - Wrap Behavior
- Responsive Design
  - Breakpoints
    - Mobile Layout
    - Tablet Layout
    - Desktop Layout
  - Scaling Modes
    - Letterbox
    - Pillarbox
    - Full Stretch
    - Aspect Ratio Preserve
- UI Themes
  - Theme System
    - Color Palettes
    - Font Definitions
    - Component Styles
    - Icon Packs
  - Theme Switching
    - Runtime Theme Change
    - Preference Persistence
    - Custom Theme Creation
- Scene-Specific Layouts
  - Geoscape UI
    - Map View
    - Base Selection
    - Craft Management
    - Mission Panel
  - Basescape UI
    - Facility Grid
    - Personnel Panel
    - Manufacturing Queue
    - Research Panel
  - Battlescape UI
    - Tactical Map
    - Unit Selection
    - Ability Menu
    - Combat Log

#### Character Database & Reference
- X-Agency Leadership
  - Volkov (Commander)
    - Background & Origin
    - Personality Profile
    - Character Arc
    - Key Decisions
    - Fate & Legacy
  - Chen (Intelligence Chief)
    - Background & Origin
    - Personality Profile
    - Character Arc
    - Key Decisions
    - Fate & Legacy
  - Webb (Operations Chief)
    - Background & Origin
    - Personality Profile
    - Character Arc
    - Key Decisions
    - Fate & Legacy
  - Other Founders
    - Backgrounds & Origins
    - Roles & Responsibilities
    - Character Arcs
    - Development Paths
- Faction Leaders (5 Human Powers)
  - Condor Cartel Leadership
    - Primary Leader Profile
    - Secondary Leaders
    - Organizational Structure
    - Strategic Goals
    - Relationship with X-Agency
  - New Patriots Leadership
    - Primary Leader Profile
    - Secondary Leaders
    - Organizational Structure
    - Strategic Goals
    - Relationship with X-Agency
  - Siberian Bloc Leadership
    - Primary Leader Profile
    - Secondary Leaders
    - Organizational Structure
    - Strategic Goals
    - Relationship with X-Agency
  - Other Regional Leaders
    - Leader Profiles
    - Territory Control
    - Resources
    - Alliance Possibilities
- Syndicate Representatives
  - Man in Black Contacts
    - Primary Representatives
    - Historical Operatives
    - Contact Methods
    - Goals & Motivations
  - Conspiracy Agents
    - Embedded Agents
    - Sleeper Operatives
    - Double Agents
    - Cover Identities
  - Infiltrators
    - Government Positions
    - Military Positions
    - Scientific Positions
    - Economic Positions
- Alien Leadership
  - Manufactured Alien Commanders
    - Command Hierarchy
    - Strategic Decision-Makers
    - Communication Methods
    - Tactical Philosophy
  - Genuine Alien Command Structure
    - Alien Queen/Collective
    - Hive Communication
    - Strategic Objectives
    - Incomprehensible Motivations
  - Third Race Representatives
    - Contact Protocols
    - Communication Challenges
    - Relationship Dynamics
    - Hidden Agenda
- Named Soldiers & Veterans
  - Veteran Traits
    - Battle-Hardened Bonuses
    - Scar Effects
    - Combat Intuition
    - PTSD Mechanics
  - Character Progression
    - Rank Development
    - Specialization Growth
    - Equipment Mastery
    - Fame & Reputation
  - Relationship Arcs
    - Squad Bonds
    - Romance Options
    - Betrayal Possibilities
    - Friendship Development
  - Mortality & Legacy
    - Death Consequences
    - Replacement Mechanics
    - Memory System
    - Honor System
- Hybrid Consciousness Characters
  - Rebel Hybrids
    - Defector Profiles
    - Motivations for Joining
    - Special Abilities
    - Trust Development
  - Other Hybrids
    - Captured Hybrids
    - Experimentation Subjects
    - Conversion Candidates
    - Moral Status
  - Character Development
    - Identity Conflict
    - Loyalty Testing
    - Power Growth
    - Sacrifice Options
- Civilian NPCs
  - Scientists & Researchers
    - Specialist Focus
    - Research Contributions
    - Ethical Positions
    - Fate & Survival
  - Civilians & Evacuees
    - Background Profiles
    - Survival Skills
    - Evacuation Priority
    - Personal Stories
  - Suppliers & Merchants
    - Supplier Profiles
    - Goods & Services
    - Relationship Mechanics
    - Black Market Contacts
  - Informants & Spies
    - Information Sources
    - Reliability Ratings
    - Faction Connections
    - Betrayal Risk
- Player-Created Characters
  - Soldier Generation
    - Randomization Options
    - Customization Options
    - Starting Loadouts
    - Initial Stats
  - Character Development
    - Naming & Customization
    - Personality Traits
    - Backstory Options
    - Relationship Building
  - Legacy System
    - Notable Achievements
    - Permanent Effects
    - Monument Creation
    - Memory Persistence

#### Knowledge Base
- Glossary
  - Geoscape Terms
    - Strategic Layer
    - Planetary Systems
    - UFO Classification
    - Mission Types
    - Campaign Phases
  - Basescape Terms
    - Facility Types
    - Research Branches
    - Manufacturing
    - Personnel Management
    - Power Systems
  - Battlescape Terms
    - Combat Mechanics
    - Unit States
    - Environmental Effects
    - Victory Conditions
    - Status Effects
  - Economy Terms
    - Funding Sources
    - Expenditure Categories
    - Budget Mechanics
    - Debt Management
    - Score Systems
  - Unit Terms
    - Unit Stats
    - Progression Systems
    - Psychological States
    - Equipment Slots
    - Special Abilities
  - Craft Terms
    - Craft Classes
    - Interceptor Types
    - Transport Categories
    - Craft Systems
    - Upgrade Paths
  - AI Terms
    - Strategic Algorithms
    - Tactical Behavior
    - Decision Trees
    - Threat Assessment
    - Resource Planning
  - Technical Terms
    - Coordinate Systems
    - Save Format
    - Event System
    - Module Structure
    - Modding Concepts
  - Design Gaps
  - Future Ideas#### Faction Visual Identity
- X-Agency Visual Design
  - Color Palette & Symbolism
    - Primary Colors (Olive/Grey)
    - Secondary Colors (Tan/Blue)
    - Accent Colors (Orange/Green)
    - Thematic Evolution
  - Uniform & Equipment Aesthetic
    - Combat Gear Design
    - Rank Insignia
    - Unit Markings
    - Customization Variations
  - Vehicle Design Language
    - Ground Vehicles
    - Aircraft Design
    - Watercraft
    - Battle Damage
  - Base Architecture Style
    - Shelter Construction
    - Facility Layout
    - Defensive Features
    - Environmental Integration
  - HUD & Interface Theme
    - Color Scheme
    - Information Display
    - Tactical Overlays
    - Status Indicators
- Condor Cartel Visual Design
  - Color Palette & Symbolism
    - Primary Colors
    - Secondary Colors
    - Gang Markings
    - Territorial Insignia
  - Uniform & Equipment Aesthetic
    - Combat Gear Variation
    - Customization Level
    - Worn Appearance
    - Weapon Preferences
  - Vehicle Design Language
    - Improvised Modifications
    - Heavy Armor
    - Firepower Focus
    - Territory Markings
  - Base Architecture Style
    - Fortified Positions
    - Improvised Shelters
    - Resource Defense
    - Intimidation Design
- New Patriots Visual Design
  - Color Palette & Symbolism
    - Primary Colors
    - Patriotic Symbols
    - Faction Insignia
    - Regional Variations
  - Uniform & Equipment Aesthetic
    - Professional Military Look
    - Standardized Gear
    - National Markings
    - Officer Ranks
  - Vehicle Design Language
    - Military Standard
    - Modern Design
    - Advanced Systems
    - Fleet Aesthetics
- Siberian Bloc Visual Design
  - Color Palette & Symbolism
    - Primary Colors
    - Soviet Influences
    - Cold War Aesthetics
    - Regional Identity
  - Uniform & Equipment Aesthetic
    - Military Tradition
    - Equipment Quality
    - Tactical Design
    - Regional Adaptation
  - Vehicle Design Language
    - Military Vehicles
    - Heavy Equipment
    - Cold-Weather Design
    - Functional Aesthetics
- Other Human Factions Visual Design
  - Faction A Visual Identity
  - Faction B Visual Identity
  - Faction C Visual Identity
- Syndicate Visual Design
  - Historical Evolution
    - 1815 Aesthetic
    - 1900 Aesthetic
    - 1950 Aesthetic
    - 1995 Aesthetic
  - Modern Presentation
    - Contemporary Design
    - Tech Integration
    - Mystery Aesthetic
    - Power Symbolism
  - Technological Aesthetic
    - Advanced Appearance
    - Future Tech
    - Alien Integration
    - Impossible Design
  - Mystery & Shadow Imagery
    - Concealment Design
    - Hidden Symbols
    - Cryptic Aesthetics
    - Incomprehensible Elements
- Manufactured Aliens Visual Design
  - Biological Appearance
    - Body Structure
    - Color Patterns
    - Movement Style
    - Physical Distinctiveness
  - Armor & Carapace
    - Protection Design
    - Adaptation Patterns
    - Weapon Integration
    - Aesthetic Uniqueness
  - Weapon Integration
    - Built-In Weapons
    - Organic Aesthetics
    - Combat Design
    - Enhancement Features
  - Tech Symbols
    - Syndicate Modifications
    - Enhancement Implants
    - Control Systems
    - Biological Tech Integration
- Genuine Aliens (Third Race) Visual Design
  - Otherworldly Aesthetic
    - Non-Human Appearance
    - Impossible Geometry
    - Unsettling Design
    - Cognitive Distortion
  - Crystalline Structures
    - Geometric Perfection
    - Impossible Physics
    - Shimmering Effects
    - Structural Beauty
  - Bioluminescence
    - Color Patterns
    - Communication Display
    - Emotional Expression
    - Environmental Interaction
  - Non-Human Symbolism
    - Incomprehensible Markings
    - Alien Language
    - Fractious Design
    - Mathematical Beauty
- ACI (Artificial Intelligence) Visual Design
  - Digital Aesthetic
    - Code Representation
    - Matrix Visualization
    - Data Patterns
    - Information Flow
  - Geometric Perfection
    - Mathematical Forms
    - Impossible Angles
    - Symmetrical Design
    - Optimal Aesthetics
  - Color Coding System
    - Logic State Colors
    - Decision Trees
    - Process Indicators
    - Threat Levels
  - Abstract Representation
    - Avatar Forms
    - Digital Bodies
    - Consciousness Display
    - Evolution Visualization
- Environmental Visual Consistency
  - Phase-Based Aesthetic Shifts
    - Phase 0-1 Realism
    - Phase 2 Sci-Fi Emergence
    - Phase 3 Cosmic Horror
    - Phase 4 Digital Despair
    - Phase 5 Void & Transcendence
  - Location Visual Themes
    - Urban Environments
    - Rural Environments
    - Alien Environments
    - Digital Environments
    - Destroyed Environments
  - Damage & Decay Systems
    - Environmental Damage
    - Facility Damage
    - Character Damage
    - Aesthetic Degeneration
  - Technology Integration
    - Visible Tech Systems
    - Integration Points
    - Hybrid Appearance
    - Evolution Over Time

## Experimental and Aspirational Systems

Experimental and aspirational systems for mid-game and late-game expansion.

#### Mid-Game Engagement
- Base Invasion Scenarios
  - Alien Base Assaults
  - Defensive Operations
  - Negotiation Options
  - Capture Mechanics
- Council Pressure Events
  - Political Crises
  - Funding Penalties
  - Panic Escalation
  - Intervention Threats
- Dynamic Campaign Events
  - UFO Waves
  - Alien Facility Construction
  - Research Breakthroughs
  - Emergency Missions

#### Environmental & Seasonal Systems
- Seasonal Cycles
  - Spring Phase
  - Summer Phase
  - Autumn Phase
  - Winter Phase
  - Seasonal Hazards
  - Dynamic Spawning
- Weather & Climate Zones
  - Arctic Regions
  - Desert Regions
  - Tropical Regions
  - Urban Regions
  - Ocean Operations
  - Underground Bases
  - Weather Cascades

#### Advanced Unit Psychology
- Moral Complexity System
  - Unit Beliefs
  - Ethical Dilemmas
  - Betrayal Mechanics
  - Redemption Arcs
- Relationship Systems
  - Squad Bonds
  - Rival Dynamics
  - Mentorship Paths
  - Romance Options
- Veteran Experience
  - Combat Trauma
  - Psychological Recovery
  - Skill Mastery
  - Legendary Status

#### Cross-System Synergies
- Research Unlock Cascades
  - Technology Trees
  - Equipment Combinations
  - Facility Synergies
  - Discovery Events
- Facility Interaction Networks
  - Power Sharing
  - Research Collaboration
  - Personnel Transfer
  - Resource Pooling
- Strategic Timing Mechanics
  - Turn-Based Events
  - Cascade Triggers
  - Simultaneous Operations
  - Time Acceleration

#### Multiplayer & Cooperative Play
- Squad Sharing
  - Multiplayer Deployment
  - Shared Achievements
  - Cooperative Missions
  - PvP Arena
- Campaign Collaboration
  - Shared Geoscape
  - Trading Systems
  - Alliance Management
  - War Mechanics
- Community Content
  - User-Generated Missions
  - Shared Mods
  - Leaderboards
  - Tournament Modes

#### Procedural Content Generation
- Dynamic Mission Generation
  - Objective Templates
  - Enemy Compositions
  - Terrain Layouts
  - Time Constraints
- Randomized Alien Behavior
  - Unpredictable Tactics
  - Emergent Threats
  - Adaptive Responses
  - Learning Systems
- Infinite Replayability
  - Seed-Based Generation
  - Parameter Variation
  - Risk Scaling
  - Challenge Modes

#### Modular Ruleset System
- Difficulty Presets
  - Story Mode
  - Classic Mode
  - Veteran Mode
  - Ironman Mode
  - Custom Difficulty
- Rules Tweaking
  - Damage Modifier
  - Resources Modifier
  - Time Modifier
  - Spawn Modifier
  - Psychology Modifier
- Challenge Modifiers
  - No Research
  - Limited Funds
  - Increased Panic
  - Advanced Aliens
  - Environmental Hazards

#### Narrative & Moral Complexity
- Branching Campaign Paths
  - Alliance Routes
  - Conquest Routes
  - Diplomatic Routes
  - Hidden Routes
  - Consequence Tracking
- Alien Motivation System
  - Invasion Goals
  - Faction Conflicts
  - Negotiation Options
  - Ultimate Objectives
- Truth Revelation
  - Story Phases
  - Lore Unlocks
  - Truth Consequences
  - Ending Variants
  - New Game+ Mode

#### Quality of Life & Accessibility
- Enhanced Accessibility
  - Colorblind Modes
  - Text-to-Speech
  - Adjustable UI Scaling
  - Input Remapping
  - Difficulty Presets
- Quality of Life Features
  - Quick Save/Load
  - Undo System
  - Autosave Checkpoints
  - Advanced Filtering
  - Custom Hotkeys
- Assistance Features
  - Tutorial System
  - Hint System
  - Objective Markers
  - Recommended Actions
  - Difficulty Scaling

#### Experimental Game Modes
- Roguelike Mode
  - Procedural Maps
  - Permadeath
  - Upgrade Progression
  - Random Encounters
- Tactical Puzzles
  - Pre-Set Scenarios
  - Optimization Goals
  - Leaderboard Scoring
  - Solution Replay
- Endless Survival
  - Increasing Difficulty
  - Wave-Based Combat
  - Resource Management
  - Score Accumulation
- Creative Mode
  - Unrestricted Building
  - Instant Research
  - Infinite Resources
  - Debug Tools

---

#### Visual Design Language System
- Artistic Direction by Phase
  - Phase 0-1: Realistic Military
    - Military Aesthetics
    - Earth-Based Design
    - Weapon Realism
    - Tactical Design
  - Phase 2: Alien Incursion
    - Sci-Fi Emergence
    - Plasma Aesthetics
    - Alien Technology
    - Hybrid Visuals
  - Phase 3: Cosmic Horror
    - Otherworldly Design
    - Moon Environments
    - Alien Structures
    - Incomprehensible Geometry
  - Phase 4: Digital Despair
    - Dystopian Aesthetics
    - AI Design Language
    - Digital Environments
    - Hostile Worlds
  - Phase 5: Void & Transcendence
    - Abstract Design
    - Final Aesthetics
    - Destruction Visuals
    - Transcendence Imagery
- Color Theory Application
  - Primary Color Meaning
    - Emotional Association
    - Cultural Significance
    - Phase Evolution
    - Faction Identity
  - Secondary Color Symbolism
    - Support Functions
    - Accent Meanings
    - Thematic Reinforcement
    - Environmental Design
  - Accent Color Function
    - Highlight Important Elements
    - Signal Danger/Warning
    - Indicate Availability
    - Guide Attention
  - Phase Color Evolution
    - Phase-Based Palette Shifts
    - Gradual Desaturation
    - Increasing Corruption
    - Final Color State
- UI/UX Aesthetic Design
  - Diegetic Interface (In-World)
    - Holographic Displays
    - Physical Interfaces
    - Environmental HUD
    - Character-Centered Information
  - Non-Diegetic Interface (HUD)
    - Floating Information
    - Screen-Space Elements
    - Player Convenience
    - Meta Information
  - Theme Consistency
    - Visual Unified Design
    - Consistent Symbolism
    - Faction-Specific UI
    - Period-Appropriate Design
  - Accessibility Considerations
    - Colorblind Support
    - Contrast Ratios
    - Text Sizing
    - Scalable Elements
- Animation Language
  - Movement Vocabulary
    - Character Movement Types
    - Animation Personality
    - Faction-Specific Movement
    - Emotional Expression
  - Combat Choreography
    - Attack Animations
    - Impact Effects
    - Weapon-Specific Moves
    - Tactical Positioning
  - Alien Movement Patterns
    - Non-Human Animation
    - Unsettling Motion
    - Biological Logic
    - Physical Impossibility
  - Interface Animation Style
    - Transition Effects
    - Button Feedback
    - State Changes
    - Smooth Transitions
- Sound Design Aesthetics
  - Phase-Based Audio Themes
    - Phase 0-1 Military Music
    - Phase 2 Sci-Fi Emergence
    - Phase 3 Cosmic Sounds
    - Phase 4 Digital Distortion
    - Phase 5 Silence & Echo
  - Faction Signature Sounds
    - X-Agency Audio Identity
    - Faction Audio Themes
    - Syndicate Audio Presence
    - Alien Sound Design
  - Location Audio Identities
    - Urban Environment Sounds
    - Rural Environment Sounds
    - Alien Environment Sounds
    - Digital World Sounds
  - Emotional Resonance Through Sound
    - Tension Building
    - Relief & Peace
    - Horror & Dread
    - Triumph & Victory
- Location Visual Atmosphere
  - Urban Environments
    - City Aesthetics
    - Building Design
    - Street-Level Details
    - Destruction Progression
  - Natural Environments
    - Forest Design
    - Mountain Aesthetics
    - Water Features
    - Biome Variation
  - Alien Environments
    - Moon Aesthetics
    - Alien Base Design
    - Otherworldly Landscapes
    - Incomprehensible Structures
  - Digital Environments
    - Virtual World Design
    - Digital Perfection
    - Impossible Architecture
    - Reality Glitches
  - Destroyed Environments (Phase 5)
    - Ruined Aesthetics
    - Apocalyptic Design
    - Environmental Decay
    - Human Absence

---


#### Content Discovery Mechanics
- Document Discovery System
  - Foundable Documents
    - Lore Documents
    - Research Papers
    - Personal Journals
    - Military Records
  - Digital Records
    - Computer Files
    - Historical Archives
    - Encrypted Messages
    - Audio Recordings
  - Audio Logs
    - Personal Messages
    - Combat Chatter
    - Research Logs
    - Warning Messages
  - Hidden Messages
    - Easter Eggs
    - Developer Notes
    - Secret Communications
    - Cryptic Clues
- Research Unlock Mechanics
  - Scientific Discovery Prerequisites
    - Required Technologies
    - Research Requirements
    - Facility Upgrades
    - Personnel Specialization
  - Technology Unlock Conditions
    - Discovery Triggers
    - Combat Encounters
    - Research Breakthroughs
    - Captured Tech
  - Hidden Technology Unlocks
    - Secret Research Trees
    - Dangerous Knowledge
    - Forbidden Tech
    - Experimental Systems
  - Experimental Systems
    - Cutting-Edge Research
    - Risky Experiments
    - Double-Edged Swords
    - Game-Changing Technology
- Character Revelation System
  - Backstory Unlocks
    - Character History
    - Relationship Context
    - Motivation Reveal
    - Secret Backgrounds
  - Character Arc Triggers
    - Specific Events
    - Relationship Milestones
    - Crisis Moments
    - Redemption Opportunities
  - Secret Conversations
    - Hidden Dialogue
    - Private Discussions
    - Confession Moments
    - Betrayal Reveals
  - Character Relationship Discovery
    - Bond Development
    - Conflict Resolution
    - Romance Unlock
    - Betrayal Consequences
- World Discovery Mechanics
  - Location Unlocks by Phase
    - Phase 0-1 Locations
    - Phase 2 Locations
    - Phase 3 Locations
    - Phase 4 Locations
    - Phase 5 Locations
  - Hidden Locations
    - Secret Bases
    - Undiscovered Facilities
    - Forbidden Zones
    - Mystical Places
  - Environmental Storytelling
    - Visual Narratives
    - Contextual Clues
    - Scene Details
    - Item Placement
  - Easter Eggs & Secrets
    - Developer Messages
    - Hidden References
    - Joke Content
    - Player Rewards

#### Truth Revelation Layers
- Secret Unlock Conditions
  - Discovery Triggers
    - Combat Encounters
    - NPC Conversations
    - Document Findings
    - Event Occurrences
  - Research Requirements
    - Technology Prerequisites
    - Time Requirements
    - Resource Investment
    - Personnel Training
  - Time Requirements
    - Campaign Progression
    - Phase Advancement
    - Event Sequencing
    - Cycle Completion
  - Choice-Based Unlocks
    - Moral Decisions
    - Loyalty Choices
    - Sacrifice Options
    - Alliance Selections
- Truth Impact Cascades
  - Mechanic Changes Post-Reveal
    - Gameplay Rule Changes
    - New Abilities Unlock
    - Old Systems Alter
    - Difficulty Shifts
  - Story Branch Changes
    - Alternative Routes
    - Character Responses
    - Faction Reactions
    - Mission Availability
  - NPC Reaction Changes
    - Dialogue Alterations
    - Relationship Impact
    - Betrayal Possibilities
    - Alliance Shifts
  - Player Knowledge Impact
    - Narrative Recontextualization
    - Hidden Meaning Reveal
    - Foreshadowing Recognition
    - Thematic Resonance
- Narrative Gap Resolution
  - Scientific Explanations System
    - Technology Logic
    - Medical Explanations
    - Biological Clarifications
    - Physics Framework
  - Philosophical Implications System
    - Identity Questions
    - Consciousness Issues
    - Morality Framework
    - Meaning Discussion
  - Temporal Paradox Solutions
    - Time Travel Mechanics
    - Causality Explanations
    - Loop Logic
    - Future Implications
  - Consciousness Transfer Mechanics
    - Upload Process
    - Backup Systems
    - Transfer Risks
    - Identity Continuity
- End-Game Content
  - New Game+ Content Unlock
    - Alternate Starting Conditions
    - Enhanced Difficulty
    - Additional Content
    - Secret Scenarios
  - Alternative Ending Variations
    - Ending Branches
    - Choice Consequences
    - Multiple Conclusions
    - Hidden Endings
  - Secret Boss Encounters
    - Bonus Battles
    - Optional Fights
    - Challenge Encounters
    - Legendary Foes
  - Infinite Loop Content
    - Post-Campaign Play
    - New Challenges
    - Endless Scenarios
    - Mastery Content

## Lore Information Systems

- Accessible Lore Database
  - In-Game Encyclopedia
    - Entry System
    - Search Functions
    - Cross-References
    - Information Layers
  - Timeline Reference
    - Chronological Events
    - Parallel Timelines
    - Phase Information
    - Historical Context
  - Faction Reference
    - Faction Information
    - Leader Profiles
    - Territory Control
    - Resources & Forces
  - Technology Reference
    - Weapon Database
    - Armor Information
    - Facility Specs
    - Craft Details
  - Character Reference
    - NPC Information
    - Leader Profiles
    - Relationship Status
    - Character Status
- Ambient Storytelling
  - Environmental Details
    - Room Decoration
    - Item Placement
    - Debris Patterns
    - Structural Integrity
  - Overheard Conversations
    - NPC Dialogue
    - Background Chatter
    - Radio Messages
    - Discovered Communications
  - Document Fragments
    - Partial Notes
    - Torn Papers
    - Damaged Records
    - Incomplete Information
  - Visual Storytelling
    - Scene Composition
    - Color Language
    - Symbolic Objects
    - Environmental Narrative
- Narrative Callbacks
  - Phase-Based Callbacks
    - Recurring Elements
    - Character Appearances
    - Event References
    - Theme Echoes
  - Character Arc Callbacks
    - Character Development
    - Relationship Evolution
    - Moral Choices
    - Consequence Reflection
  - Historical Callbacks
    - Past Event References
    - Character History
    - Faction History
    - Technology History
  - Thematic Callbacks
    - Philosophical Echoes
    - Moral Resonance
    - Symbolic Reflection
    - Meaning Reinforcement
