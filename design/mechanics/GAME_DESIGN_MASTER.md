# AlienFall Game Design Master Document

> **Status**: Master Design Document
> **Last Updated**: 2025-11-20

## Table of Contents

- [1. Core Game Pillars](#1-core-game-pillars)
  - [1.1 Strategic Layer (Geoscape)](#11-strategic-layer-geoscape)
  - [1.2 Tactical Layer (Battlescape)](#12-tactical-layer-battlescape)
  - [1.3 Management Layer (Basescape)](#13-management-layer-basescape)

- [2. Geoscape Systems](#2-geoscape-systems)
  - [2.1 World Map](#21-world-map)
  - [2.2 UFO Activity](#22-ufo-activity)
  - [2.3 Interception](#23-interception)
  - [2.4 Mission Generation](#24-mission-generation)
  - [2.5 Global Relations](#25-global-relations)

- [3. Basescape Systems](#3-basescape-systems)
  - [3.1 Base Management](#31-base-management)
  - [3.2 Facility System](#32-facility-system)
  - [3.3 Personnel Management](#33-personnel-management)
  - [3.4 Research System](#34-research-system)
  - [3.5 Manufacturing System](#35-manufacturing-system)
  - [3.6 Prison & Interrogation System](#36-prison--interrogation-system)
  - [3.7 Facility Upgrades](#37-facility-upgrades)

- [4. Battlescape Systems](#4-battlescape-systems)
  - [4.1 Combat Mechanics](#41-combat-mechanics)
  - [4.2 Line of Sight](#42-line-of-sight)
  - [4.3 Weapon Systems](#43-weapon-systems)
  - [4.4 Damage System](#44-damage-system)
  - [4.5 Environmental Systems](#45-environmental-systems)
  - [4.6 Psychology System](#46-psychology-system)
  - [4.7 3D First-Person Mode](#47-3d-first-person-mode)

- [5. Unit Systems](#5-unit-systems)
  - [5.1 Unit Types](#51-unit-types)
  - [5.2 Unit Stats](#52-unit-stats)
  - [5.3 Unit Progression](#53-unit-progression)
  - [5.4 Equipment System](#54-equipment-system)
  - [5.5 Pilot System](#55-pilot-system)
  - [5.6 Morale, Bravery & Sanity System](#56-morale-bravery--sanity-system)

- [6. Mission Systems](#6-mission-systems)
  - [6.1 Mission Structure](#61-mission-structure)
  - [6.2 Map Generation](#62-map-generation)
  - [6.3 Enemy Spawning](#63-enemy-spawning)
  - [6.4 Loot System](#64-loot-system)

- [7. AI Systems](#7-ai-systems)
  - [7.1 Strategic AI](#71-strategic-ai)
  - [7.2 Tactical AI](#72-tactical-ai)
  - [7.3 Adaptive AI](#73-adaptive-ai)
  - [7.4 Autonomous Player AI](#74-autonomous-player-ai)
  - [7.5 AI Confidence System](#75-ai-confidence-system)

- [8. Economy Systems](#8-economy-systems)
  - [8.1 Resource Types](#81-resource-types)
  - [8.2 Income Systems](#82-income-systems)
  - [8.3 Expense Systems](#83-expense-systems)
  - [8.4 Trade Systems](#84-trade-systems)
  - [8.5 Finance Management](#85-finance-management)

- [9. Equipment & Items](#9-equipment--items)
  - [9.1 Equipment System](#91-equipment-system)
  - [9.2 Item Modification System](#92-item-modification-system)
  - [9.3 Item Degradation](#93-item-degradation)

- [10. Campaign & Progression](#10-campaign--progression)
  - [10.1 Campaign Structure](#101-campaign-structure)
  - [10.2 Threat Progression](#102-threat-progression)
  - [10.3 Fame, Karma & Reputation](#103-fame-karma--reputation)

- [11. Analytics & Balancing](#11-analytics--balancing)
  - [11.1 Data Collection System](#111-data-collection-system)
  - [11.2 Balance Metrics](#112-balance-metrics)

- [12. Asset & Modding Systems](#12-asset--modding-systems)
  - [12.1 Asset Pipeline](#121-asset-pipeline)
  - [12.2 Mod System](#122-mod-system)

- [13. Environmental Systems](#13-environmental-systems)
  - [13.1 Terrain & Biomes](#131-terrain--biomes)
  - [13.2 Weather System](#132-weather-system)
  - [13.3 Environmental Hazards](#133-environmental-hazards)

- [14. Mission Types & Objectives](#14-mission-types--objectives)
  - [14.1 Standard Missions](#141-standard-missions)
  - [14.2 Tactical Missions](#142-tactical-missions)
  - [14.3 Special Missions](#143-special-missions)

- [15. Integration Systems](#15-integration-systems)
  - [15.1 Cross-System Dependencies](#151-cross-system-dependencies)
  - [15.2 Data Flow](#152-data-flow)

- [16. Future & Expansion Features](#16-future--expansion-features)
  - [16.1 Planned Features](#161-planned-features)
  - [16.2 Expansion Possibilities](#162-expansion-possibilities)

## 1. Core Game Pillars

### 1.1 Strategic Layer (Geoscape)
TODO: Define strategic gameplay loop and core mechanics

#### 1.1.1 World Management
TODO: Explain hex-grid system and planetary scope

#### 1.1.2 Time Progression
TODO: Detail time system and pause mechanics

#### 1.1.3 Threat System
TODO: Describe global threat mechanics and progression

### 1.2 Tactical Layer (Battlescape)
TODO: Define tactical combat loop and core mechanics

#### 1.2.1 Turn-Based Combat
TODO: Explain turn order and action economy

#### 1.2.2 Squad Management
TODO: Detail squad composition and control

#### 1.2.3 Victory Conditions
TODO: Define mission objectives and failure states

### 1.3 Management Layer (Basescape)
TODO: Define base management loop and resource systems

#### 1.3.1 Base Construction
TODO: Explain facility grid and building mechanics

#### 1.3.2 Resource Management
TODO: Detail economy and resource types

#### 1.3.3 Personnel Management
TODO: Describe recruitment and training systems

## 2. Geoscape Systems

### 2.1 World Map

#### 2.1.1 Hex Grid System
TODO: Detail 90x45 hex implementation for Earth/Moon/Mars

##### 2.1.1.1 Coordinate System
TODO: Explain axial coordinate implementation

##### 2.1.1.2 Distance Calculations
TODO: Define hex distance and pathfinding

##### 2.1.1.3 Territory Control
TODO: Describe faction territory mechanics

#### 2.1.2 Geographic Features
TODO: Detail terrain types and their effects

##### 2.1.2.1 Terrain Types
TODO: List and explain terrain classifications

##### 2.1.2.2 Climate Zones
TODO: Define climate effects on operations

##### 2.1.2.3 Strategic Resources
TODO: Explain resource node placement

#### 2.1.3 Fog of War
TODO: Define visibility and intelligence mechanics

##### 2.1.3.1 Radar Coverage
TODO: Explain detection ranges and mechanics

##### 2.1.3.2 Intelligence Network
TODO: Detail information gathering systems

##### 2.1.3.3 Satellite Coverage
TODO: Describe orbital surveillance mechanics

### 2.2 UFO Activity

#### 2.2.1 UFO Types
TODO: Define alien craft classifications

##### 2.2.1.1 Scout Class
TODO: Detail small UFO characteristics

##### 2.2.1.2 Fighter Class
TODO: Detail combat UFO characteristics

##### 2.2.1.3 Transport Class
TODO: Detail troop carrier characteristics

##### 2.2.1.4 Capital Class
TODO: Detail large UFO characteristics

#### 2.2.2 UFO Missions
TODO: Explain alien mission types and goals

##### 2.2.2.1 Reconnaissance
TODO: Detail scouting mission mechanics

##### 2.2.2.2 Abduction
TODO: Explain civilian targeting missions

##### 2.2.2.3 Terror
TODO: Describe terror mission mechanics

##### 2.2.2.4 Base Construction
TODO: Detail alien base building missions

#### 2.2.3 Detection Mechanics
TODO: Define how UFOs are detected and tracked

##### 2.2.3.1 Radar Systems
TODO: Explain radar mechanics and upgrades

##### 2.2.3.2 Tracking Duration
TODO: Detail tracking persistence and loss

##### 2.2.3.3 Stealth Mechanics
TODO: Describe UFO evasion capabilities

### 2.3 Interception

#### 2.3.1 Air Combat
TODO: Define interception combat mechanics

##### 2.3.1.1 Engagement Rules
TODO: Explain combat initiation and range

##### 2.3.1.2 Weapon Systems
TODO: Detail air-to-air weapon types

##### 2.3.1.3 Damage Resolution
TODO: Describe damage and crash mechanics

#### 2.3.2 Craft Management
TODO: Explain interceptor deployment and logistics

##### 2.3.2.1 Craft Types
TODO: Define interceptor classifications

##### 2.3.2.2 Loadout Configuration
TODO: Detail weapon and equipment options

##### 2.3.2.3 Maintenance
TODO: Explain repair and refuel mechanics

#### 2.3.3 Pilot System
TODO: Define pilot mechanics and progression

##### 2.3.3.1 Pilot Skills
TODO: Detail skill types and effects

##### 2.3.3.2 Experience Gain
TODO: Explain pilot advancement

##### 2.3.3.3 Pilot Fatigue
TODO: Describe rest and rotation needs
TODO: Define Energy Point System (Interception) - weapon/evasion/system energy pools, regeneration and drain mechanics

### 2.4 Mission Generation

#### 2.4.1 Mission Types
TODO: Define all mission classifications

##### 2.4.1.1 Crash Sites
TODO: Detail UFO crash recovery missions

##### 2.4.1.2 Landing Sites
TODO: Explain intact UFO missions

##### 2.4.1.3 Terror Sites
TODO: Describe urban combat missions

##### 2.4.1.4 Base Assault
TODO: Detail base attack/defense missions

#### 2.4.2 Mission Parameters
TODO: Define mission generation rules

##### 2.4.2.1 Difficulty Scaling
TODO: Explain difficulty progression

##### 2.4.2.2 Time Limits
TODO: Detail mission expiration mechanics

##### 2.4.2.3 Rewards Structure
TODO: Describe loot and reward systems

#### 2.4.3 Squad Deployment
TODO: Explain squad selection and transport

##### 2.4.3.1 Transport Craft
TODO: Detail dropship mechanics

##### 2.4.3.2 Squad Composition
TODO: Define squad size and restrictions

##### 2.4.3.3 Equipment Loadout
TODO: Explain pre-mission preparation

### 2.5 Global Relations

#### 2.5.1 Faction System
TODO: Define faction mechanics and interactions

##### 2.5.1.1 Human Factions
TODO: Detail Earth government factions

##### 2.5.1.2 Alien Factions
TODO: Explain alien faction types

##### 2.5.1.3 Neutral Entities
TODO: Describe non-aligned groups

#### 2.5.2 Diplomacy
TODO: Explain diplomatic mechanics

##### 2.5.2.1 Reputation System
TODO: Detail reputation gains and losses

##### 2.5.2.2 Trade Agreements
TODO: Describe resource trading mechanics

##### 2.5.2.3 Military Alliances
TODO: Explain cooperation mechanics

#### 2.5.3 Funding Model
TODO: Define economic support systems

##### 2.5.3.1 Monthly Funding
TODO: Detail regular income mechanics

##### 2.5.3.2 Performance Metrics
TODO: Explain funding adjustments

##### 2.5.3.3 Special Rewards
TODO: Describe bonus funding events

## 3. Basescape Systems

### 3.1 Base Management

#### 3.1.1 Grid System
TODO: Define 40x60 orthogonal grid mechanics

##### 3.1.1.1 Placement Rules
TODO: Explain facility placement restrictions

##### 3.1.1.2 Adjacency Bonuses
TODO: Detail facility synergy mechanics

##### 3.1.1.3 Expansion Limits
TODO: Describe base size constraints

#### 3.1.2 Facility Types
TODO: Define all facility categories

##### 3.1.2.1 Core Facilities
TODO: Detail essential base structures

###### 3.1.2.1.1 Command Center
TODO: Explain headquarters mechanics

###### 3.1.2.1.2 Power Plant
TODO: Detail power generation systems

###### 3.1.2.1.3 Living Quarters
TODO: Describe personnel housing

##### 3.1.2.2 Research Facilities
TODO: Detail science structures

###### 3.1.2.2.1 Laboratory
TODO: Explain research mechanics

###### 3.1.2.2.2 Alien Containment
TODO: Detail specimen holding

###### 3.1.2.2.3 Psi Lab
TODO: Describe psionics research

##### 3.1.2.3 Production Facilities
TODO: Detail manufacturing structures

###### 3.1.2.3.1 Workshop
TODO: Explain item production

###### 3.1.2.3.2 Hangar
TODO: Detail craft maintenance

###### 3.1.2.3.3 Armory
TODO: Describe weapon storage

##### 3.1.2.4 Defense Facilities
TODO: Detail base defense structures

###### 3.1.2.4.1 Radar Array
TODO: Explain detection systems

###### 3.1.2.4.2 Missile Battery
TODO: Detail anti-air defenses

###### 3.1.2.4.3 Security Station
TODO: Describe internal defenses

#### 3.1.3 Construction Mechanics
TODO: Define building process

##### 3.1.3.1 Build Time
TODO: Explain construction duration

##### 3.1.3.2 Resource Cost
TODO: Detail material requirements

##### 3.1.3.3 Engineer Requirements
TODO: Describe workforce needs

### 3.2 Facility System

#### 3.2.1 Facility Construction
TODO: Define building mechanics

##### 3.2.1.1 Construction Queue
TODO: Detail multi-facility build orders

##### 3.2.1.2 Engineer Assignment
TODO: Explain workforce allocation

##### 3.2.1.3 Facility Upgrades
TODO: Describe enhancement process

#### 3.2.2 Facility Types
TODO: Define all facility categories

##### 3.2.2.1 Core Facilities
TODO: Detail essential base structures

###### 3.2.2.1.1 Command Center
TODO: Explain headquarters mechanics

###### 3.2.2.1.2 Power Plant
TODO: Detail power generation systems

###### 3.2.2.1.3 Living Quarters
TODO: Describe personnel housing

##### 3.2.2.2 Research Facilities
TODO: Detail science structures

###### 3.2.2.2.1 Laboratory
TODO: Explain research mechanics

###### 3.2.2.2.2 Alien Containment
TODO: Detail specimen holding

###### 3.2.2.2.3 Psi Lab
TODO: Describe psionics research

##### 3.2.2.3 Production Facilities
TODO: Detail manufacturing structures

###### 3.2.2.3.1 Workshop
TODO: Explain item production

###### 3.2.2.3.2 Hangar
TODO: Detail craft maintenance

###### 3.2.2.3.3 Armory
TODO: Describe weapon storage

##### 3.2.2.4 Defense Facilities
TODO: Detail base defense structures

###### 3.2.2.4.1 Radar Array
TODO: Explain detection systems

###### 3.2.2.4.2 Missile Battery
TODO: Detail anti-air defenses

###### 3.2.2.4.3 Security Station
TODO: Describe internal defenses

#### 3.2.3 Construction Mechanics
TODO: Define building process

##### 3.2.3.1 Build Time
TODO: Explain construction duration

##### 3.2.3.2 Resource Cost
TODO: Detail material requirements

##### 3.2.3.3 Engineer Requirements
TODO: Describe workforce needs

### 3.3 Personnel Management

#### 3.3.1 Recruitment
TODO: Define hiring mechanics

##### 3.3.1.1 Soldier Recruitment
TODO: Detail combat personnel

##### 3.3.1.2 Scientist Hiring
TODO: Explain researcher acquisition

##### 3.3.1.3 Engineer Hiring
TODO: Describe technician recruitment

#### 3.3.2 Training Systems
TODO: Define skill development

##### 3.3.2.1 Combat Training
TODO: Detail soldier improvement

##### 3.3.2.2 Specialized Training
TODO: Explain role specialization

##### 3.3.2.3 Cross-Training
TODO: Describe multi-role development

#### 3.3.3 Personnel Welfare
TODO: Define morale and health

##### 3.3.3.1 Living Conditions
TODO: Explain comfort factors

##### 3.3.3.2 Medical Care
TODO: Detail health systems

##### 3.3.3.3 Morale Management
TODO: Describe happiness mechanics

### 3.4 Research System

#### 3.4.1 Research Trees
TODO: Define technology branches

##### 3.4.1.1 Weapons Branch
TODO: Detail offensive tech tree

##### 3.4.1.2 Armor Branch
TODO: Explain defensive tech tree

##### 3.4.1.3 Alien Technology
TODO: Describe reverse engineering

##### 3.4.1.4 Support Technology
TODO: Detail utility tech tree

##### 3.4.1.5 Facilities Branch
TODO: Explain base tech tree

#### 3.4.2 Research Mechanics
TODO: Define research process

##### 3.4.2.1 Research Points
TODO: Explain progress mechanics

##### 3.4.2.2 Scientist Allocation
TODO: Detail workforce assignment

##### 3.4.2.3 Research Bonuses
TODO: Describe speed modifiers

#### 3.4.3 Prerequisites
TODO: Define tech requirements

##### 3.4.3.1 Technology Gates
TODO: Explain tech dependencies

##### 3.4.3.2 Material Requirements
TODO: Detail resource needs

##### 3.4.3.3 Specimen Requirements
TODO: Describe capture needs

### 3.5 Manufacturing System

#### 3.5.1 Production Lines
TODO: Define manufacturing mechanics

##### 3.5.1.1 Item Categories
TODO: Detail producible items

##### 3.5.1.2 Production Time
TODO: Explain build duration

##### 3.5.1.3 Batch Processing
TODO: Describe mass production

#### 3.5.2 Engineer Management
TODO: Define workforce mechanics

##### 3.5.2.1 Skill Levels
TODO: Detail engineer expertise

##### 3.5.2.2 Work Assignment
TODO: Explain task allocation

##### 3.5.2.3 Efficiency Factors
TODO: Describe productivity modifiers

#### 3.5.3 Quality Control
TODO: Define production quality

##### 3.5.3.1 Item Quality
TODO: Explain quality tiers

##### 3.5.3.2 Defect Rates
TODO: Detail failure mechanics

##### 3.5.3.3 Improvement Systems
TODO: Describe quality upgrades

### 3.6 Prison & Interrogation System

**Overview**: Captured enemy units provide research opportunities and intelligence through interrogation.

**Prisoner Mechanics**:
- Capture: Units with HP > 0 at mission end become prisoners
- Capacity: Prison facility holds 10 prisoners max (3×3 grid)
- Lifetime: 30 + (Unit Max HP × 2) days survival in captivity

**Prisoner Options**:
| Option | Effect | Karma | Research | Duration |
|--------|--------|-------|----------|----------|
| Execute | Remove immediately | -5 | 0 | Instant |
| Interrogate | Extract intelligence | 0 | +30 man-days | 1 week |
| Experiment | Medical research | -3 | +60 man-days | 2 weeks |
| Exchange | Trade to faction | +3 | 0 | 1 week |
| Convert | Recruit as unit | 0 | 0 | 4 weeks |
| Release | Free prisoner | +5 | 0 | Instant |

**Strategic Value**: Prisoners provide research acceleration and diplomatic options.

### 3.7 Facility Upgrades

**Upgrade System**: In-place enhancement of existing facilities without relocation.

**Upgrade Categories**:
- Labs: +50% output, +2 research queue
- Workshops: +50% output, +2 manufacturing queue
- Hospitals: +5 beds, +1 sanity/week
- Storage: Capacity scaling (S→M→L)
- Power Plants: +50 additional power generation

**Cost Structure**: 50-150K credits, 14-30 days construction time.

## 4. Battlescape Systems

### 4.1 Combat Mechanics

#### 4.1.1 Turn Structure
TODO: Define turn-based flow

##### 4.1.1.1 Initiative System
TODO: Explain turn order

##### 4.1.1.2 Action Points
TODO: Detail time units system

##### 4.1.1.3 Reaction Fire
TODO: Describe overwatch mechanics

#### 4.1.2 Movement System
TODO: Define tactical movement

##### 4.1.2.1 Hex Navigation
TODO: Explain hex movement rules

##### 4.1.2.2 Movement Costs
TODO: Detail terrain effects

##### 4.1.2.3 Stance System
TODO: Describe crouch/prone mechanics

#### 4.1.3 Combat Actions
TODO: Define available actions

##### 4.1.3.1 Attack Actions
TODO: Detail offensive options

##### 4.1.3.2 Defensive Actions
TODO: Explain defensive options

##### 4.1.3.3 Support Actions
TODO: Describe utility actions

### 4.2 Line of Sight

#### 4.2.1 Vision Mechanics
TODO: Define visibility systems

##### 4.2.1.1 Sight Range
TODO: Explain vision distance

TODO: Detail close combat arms

#### 4.3.2 Firing Modes
TODO: Define attack options

##### 4.3.2.1 Single Shot
TODO: Explain aimed fire

##### 4.3.2.2 Burst Fire
TODO: Detail automatic fire

##### 4.3.2.3 Suppression Fire
TODO: Describe area denial

#### 4.3.3 Ammunition System
TODO: Define ammo mechanics

##### 4.3.3.1 Ammo Types
TODO: Detail ammunition varieties

##### 4.3.3.2 Reload Mechanics
TODO: Explain reloading process

##### 4.3.3.3 Ammo Conservation
TODO: Describe resource management

### 4.4 Damage System

#### 4.4.1 Damage Types
TODO: Define damage categories

##### 4.4.1.1 Kinetic Damage
TODO: Detail physical impact

##### 4.4.1.2 Explosive Damage
TODO: Explain blast effects

##### 4.4.1.3 Energy Damage
TODO: Describe beam weapons

##### 4.4.1.4 Psionic Damage
TODO: Detail mental attacks

##### 4.4.1.5 Environmental Damage
TODO: Explain hazard damage

#### 4.4.2 Armor System
TODO: Define protection mechanics

##### 4.4.2.1 Armor Types
TODO: Detail armor categories

##### 4.4.2.2 Damage Reduction
TODO: Explain mitigation formulas

##### 4.4.2.3 Armor Degradation
TODO: Describe wear mechanics

#### 4.4.3 Wound System
TODO: Define injury mechanics

##### 4.4.3.1 Wound Severity
TODO: Detail injury levels

##### 4.4.3.2 Bleeding Mechanics
TODO: Explain ongoing damage

##### 4.4.3.3 Medical Treatment
TODO: Describe healing systems

TODO: Document Explosion Wave Propagation mechanics (multiple directional waves, distance scaling, wall-blocking rules)

### 4.5 Environmental Systems

#### 4.5.1 Terrain Types
TODO: Define map terrain

##### 4.5.1.1 Natural Terrain
TODO: Detail outdoor environments

##### 4.5.1.2 Urban Terrain
TODO: Explain city environments

##### 4.5.1.3 Alien Terrain
TODO: Describe exotic environments

#### 4.5.2 Destructible Environment
TODO: Define terrain damage

##### 4.5.2.1 Structural Damage
TODO: Explain building destruction

##### 4.5.2.2 Terrain Deformation
TODO: Detail landscape changes

##### 4.5.2.3 Fire Propagation
TODO: Describe spreading effects

#### 4.5.3 Environmental Hazards
TODO: Define battlefield dangers

##### 4.5.3.1 Fire Hazards
TODO: Detail burning mechanics

##### 4.5.3.2 Smoke Effects
TODO: Explain vision blocking

##### 4.5.3.3 Toxic Areas
TODO: Describe poison zones

### 4.6 Psychology System

#### 4.6.1 Morale Mechanics
TODO: Define courage systems

##### 4.6.1.1 Morale Factors
TODO: Detail morale influences

##### 4.6.1.2 Panic States
TODO: Explain fear effects

##### 4.6.1.3 Rally Mechanics
TODO: Describe recovery systems

#### 4.6.2 Sanity System
TODO: Define mental health

##### 4.6.2.1 Sanity Loss
TODO: Detail horror effects

##### 4.6.2.2 Mental Breaks
TODO: Explain breakdown mechanics

##### 4.6.2.3 Psychological Recovery
TODO: Describe treatment systems

#### 4.6.3 Bravery System
TODO: Define courage mechanics

##### 4.6.3.1 Bravery Checks
TODO: Explain courage tests

##### 4.6.3.2 Leadership Effects
TODO: Detail command bonuses

##### 4.6.3.3 Experience Effects
TODO: Describe veteran bonuses

## 5. Unit Systems

### 5.1 Unit Types

#### 5.1.1 Human Units
TODO: Define human forces

##### 5.1.1.1 Soldier Classes
TODO: Detail combat roles

###### 5.1.1.1.1 Assault
TODO: Explain frontline fighters

###### 5.1.1.1.2 Support
TODO: Detail fire support

###### 5.1.1.1.3 Sniper
TODO: Describe marksmen

###### 5.1.1.1.4 Medic
TODO: Explain field medics

##### 5.1.1.2 Civilian Units
TODO: Detail non-combatants

##### 5.1.1.3 VIP Units
TODO: Explain special characters

#### 5.1.2 Alien Units
TODO: Define alien forces

##### 5.1.2.1 Alien Races
TODO: Detail species types

##### 5.1.2.2 Alien Roles
TODO: Explain alien specializations

##### 5.1.2.3 Alien Commanders
TODO: Describe leadership units

#### 5.1.3 Robotic Units
TODO: Define mechanical forces

##### 5.1.3.1 Drones
TODO: Detail automated units

##### 5.1.3.2 Mechs
TODO: Explain heavy units

##### 5.1.3.3 Cyborgs
TODO: Describe hybrid units

### 5.2 Unit Statistics

#### 5.2.1 Primary Attributes
TODO: Define core stats

##### 5.2.1.1 Health Points
TODO: Detail durability

##### 5.2.1.2 Time Units
TODO: Explain action economy

##### 5.2.1.3 Accuracy
TODO: Describe hit chances

##### 5.2.1.4 Strength
TODO: Detail physical power

#### 5.2.2 Secondary Attributes
TODO: Define derived stats

##### 5.2.2.1 Throwing Range
TODO: Explain grenade distance

##### 5.2.2.2 Carry Capacity
TODO: Detail equipment limits

##### 5.2.2.3 Vision Range
TODO: Describe sight distance

#### 5.2.3 Special Abilities
TODO: Define unique powers

##### 5.2.3.1 Psionic Powers
TODO: Detail mental abilities

##### 5.2.3.2 Tech Abilities
TODO: Explain equipment skills

##### 5.2.3.3 Racial Traits
TODO: Describe species bonuses

### 5.3 Experience System

#### 5.3.1 Experience Gain
TODO: Define XP mechanics

##### 5.3.1.1 Combat Experience
TODO: Detail battle XP

##### 5.3.1.2 Mission Experience
TODO: Explain completion XP

##### 5.3.1.3 Training Experience
TODO: Describe practice XP

#### 5.3.2 Rank Progression
TODO: Define promotion system

##### 5.3.2.1 Military Ranks
TODO: Detail rank structure

##### 5.3.2.2 Rank Benefits
TODO: Explain rank bonuses

##### 5.3.2.3 Command Structure
TODO: Describe leadership chain

#### 5.3.3 Skill Development
TODO: Define ability growth

##### 5.3.3.1 Skill Trees
TODO: Detail specialization paths

##### 5.3.3.2 Skill Points
TODO: Explain allocation system

##### 5.3.3.3 Skill Synergies
TODO: Describe combo effects

### 5.4 Equipment System

#### 5.4.1 Equipment Slots
TODO: Define loadout system

##### 5.4.1.1 Weapon Slots
TODO: Detail weapon carrying

##### 5.4.1.2 Armor Slots
TODO: Explain protection gear

##### 5.4.1.3 Utility Slots
TODO: Describe support items

#### 5.4.2 Weight System
TODO: Define encumbrance

##### 5.4.2.1 Weight Limits
TODO: Detail carrying capacity

##### 5.4.2.2 Movement Penalties
TODO: Explain overload effects

##### 5.4.2.3 Strength Bonuses
TODO: Describe carry improvements

#### 5.4.3 Equipment Modding
TODO: Define customization

##### 5.4.3.1 Weapon Mods
TODO: Detail gun attachments

##### 5.4.3.2 Armor Mods
TODO: Explain armor upgrades

##### 5.4.3.3 Tech Upgrades
TODO: Describe item improvements

## 6. Mission Systems

### 6.1 Mission Structure

#### 6.1.1 Mission Phases
TODO: Define mission flow

##### 6.1.1.1 Deployment Phase
TODO: Detail mission start

##### 6.1.1.2 Objective Phase
TODO: Explain main mission

##### 6.1.1.3 Extraction Phase
TODO: Describe mission end

#### 6.1.2 Objective Types
TODO: Define mission goals

##### 6.1.2.1 Elimination
TODO: Detail kill missions

##### 6.1.2.2 Rescue
TODO: Explain save missions

##### 6.1.2.3 Recovery
TODO: Describe retrieval missions

##### 6.1.2.4 Defense
TODO: Detail protection missions

#### 6.1.3 Success Criteria
TODO: Define victory conditions

##### 6.1.3.1 Primary Objectives
TODO: Explain main goals

##### 6.1.3.2 Secondary Objectives
TODO: Detail bonus goals

##### 6.1.3.3 Failure Conditions
TODO: Describe loss states

### 6.2 Map Generation

#### 6.2.1 Procedural Generation
TODO: Define map creation

##### 6.2.1.1 Terrain Algorithms
TODO: Detail landscape generation

##### 6.2.1.2 Structure Placement
TODO: Explain building generation

##### 6.2.1.3 Spawn Points
TODO: Describe unit placement

#### 6.2.2 Map Blocks
TODO: Define prefab system

##### 6.2.2.1 Block Types
TODO: Detail prefab categories

##### 6.2.2.2 Block Assembly
TODO: Explain connection rules

##### 6.2.2.3 Block Variations
TODO: Describe randomization

#### 6.2.3 Map Biomes
TODO: Define environment types

##### 6.2.3.1 Urban Maps
TODO: Detail city environments

##### 6.2.3.2 Rural Maps
TODO: Explain countryside

##### 6.2.3.3 Alien Maps
TODO: Describe UFO interiors

### 6.3 Enemy Spawning

#### 6.3.1 Spawn Rules
TODO: Define enemy placement

##### 6.3.1.1 Spawn Density
TODO: Detail unit counts

##### 6.3.1.2 Spawn Locations
TODO: Explain placement logic

##### 6.3.1.3 Spawn Timing
TODO: Describe reinforcements

#### 6.3.2 Enemy Composition
TODO: Define force structure

##### 6.3.2.1 Squad Templates
TODO: Detail enemy groups

##### 6.3.2.2 Difficulty Scaling
TODO: Explain progression

##### 6.3.2.3 Special Units
TODO: Describe unique enemies

#### 6.3.3 Reinforcement System
TODO: Define backup mechanics

##### 6.3.3.1 Trigger Conditions
TODO: Detail spawn triggers

##### 6.3.3.2 Reinforcement Waves
TODO: Explain wave mechanics

##### 6.3.3.3 Escalation Rules
TODO: Describe intensity increase

### 6.4 Loot System

#### 6.4.1 Loot Generation
TODO: Define reward creation

##### 6.4.1.1 Loot Tables
TODO: Detail drop chances

##### 6.4.1.2 Quality Tiers
TODO: Explain item rarity

##### 6.4.1.3 Quantity Rules
TODO: Describe amount limits

#### 6.4.2 Salvage Mechanics
TODO: Define recovery system

##### 6.4.2.1 Corpse Recovery
TODO: Detail body retrieval

##### 6.4.2.2 Equipment Recovery
TODO: Explain gear salvage

##### 6.4.2.3 Material Recovery
TODO: Describe resource extraction

#### 6.4.3 Mission Rewards
TODO: Define completion bonuses

##### 6.4.3.1 Experience Rewards
TODO: Detail XP distribution

##### 6.4.3.2 Resource Rewards
TODO: Explain material gains

##### 6.4.3.3 Reputation Rewards
TODO: Describe standing changes

## 7. AI Systems

### 7.1 Strategic AI

#### 7.1.1 Campaign AI
TODO: Define alien strategy

##### 7.1.1.1 Invasion Planning
TODO: Detail attack strategies

##### 7.1.1.2 Resource Management
TODO: Explain alien economy

##### 7.1.1.3 Adaptation Mechanics
TODO: Describe AI learning

#### 7.1.2 Faction AI
TODO: Define faction behavior

##### 7.1.2.1 Diplomatic AI
TODO: Detail relation management

##### 7.1.2.2 Economic AI
TODO: Explain trade behavior

##### 7.1.2.3 Military AI
TODO: Describe warfare logic

#### 7.1.3 Mission Generation AI
TODO: Define mission creation

##### 7.1.3.1 Threat Assessment
TODO: Detail danger evaluation

##### 7.1.3.2 Target Selection
TODO: Explain priority logic

##### 7.1.3.3 Timing Decisions
TODO: Describe scheduling AI

### 7.2 Tactical AI

#### 7.2.1 Unit AI
TODO: Define individual behavior

##### 7.2.1.1 Decision Trees
TODO: Detail action selection

##### 7.2.1.2 Target Priority
TODO: Explain threat assessment

##### 7.2.1.3 Self-Preservation
TODO: Describe survival logic

#### 7.2.2 Squad AI
TODO: Define group behavior

##### 7.2.2.1 Coordination
TODO: Detail teamwork mechanics

##### 7.2.2.2 Flanking Maneuvers
TODO: Explain tactical movement

##### 7.2.2.3 Cover Usage
TODO: Describe positioning logic

#### 7.2.3 Behavior Profiles
TODO: Define AI personalities

##### 7.2.3.1 Aggressive AI
TODO: Detail assault behavior

##### 7.2.3.2 Defensive AI
TODO: Explain guard behavior

##### 7.2.3.3 Support AI
TODO: Describe helper behavior

### 7.3 Adaptive AI

#### 7.3.1 Learning Systems
TODO: Define AI adaptation

##### 7.3.1.1 Pattern Recognition
TODO: Detail player analysis

##### 7.3.1.2 Counter Strategies
TODO: Explain response tactics

##### 7.3.1.3 Difficulty Adjustment
TODO: Describe challenge scaling

#### 7.3.2 Memory Systems
TODO: Define AI knowledge

##### 7.3.2.1 Unit Memory
TODO: Detail target tracking

##### 7.3.2.2 Strategic Memory
TODO: Explain campaign learning

##### 7.3.2.3 Tactical Memory
TODO: Describe battle learning

#### 7.3.3 Prediction Systems
TODO: Define anticipation AI

##### 7.3.3.1 Player Modeling
TODO: Detail behavior prediction

##### 7.3.3.2 Threat Forecasting
TODO: Explain danger prediction

##### 7.3.3.3 Resource Planning
TODO: Describe future planning

## 8. Economy Systems

### 8.1 Resource Types

#### 8.1.1 Currency
TODO: Define monetary systems

##### 8.1.1.1 Credits System
TODO: Detail main currency

##### 8.1.1.2 Exchange Rates
TODO: Explain conversion mechanics

##### 8.1.1.3 Inflation Mechanics
TODO: Describe value changes

#### 8.1.2 Materials
TODO: Define physical resources

##### 8.1.2.1 Common Materials
TODO: Detail basic resources

##### 8.1.2.2 Rare Materials
TODO: Explain valuable resources

##### 8.1.2.3 Alien Materials
TODO: Describe exotic resources

#### 8.1.3 Special Resources
TODO: Define unique assets

##### 8.1.3.1 Research Data
TODO: Detail knowledge resources

##### 8.1.3.2 Political Capital
TODO: Explain influence resources

##### 8.1.3.3 Intelligence Assets
TODO: Describe information resources

### 8.2 Income Systems

#### 8.2.1 Regular Income
TODO: Define steady revenue

##### 8.2.1.1 Faction Funding
TODO: Detail government support

##### 8.2.1.2 Base Production
TODO: Explain facility income

##### 8.2.1.3 Trade Revenue
TODO: Describe commerce income

#### 8.2.2 Mission Income
TODO: Define combat revenue

##### 8.2.2.1 Salvage Value
TODO: Detail equipment sales

##### 8.2.2.2 Bounties
TODO: Explain kill rewards

##### 8.2.2.3 Mission Bonuses
TODO: Describe completion rewards

#### 8.2.3 Special Income
TODO: Define irregular revenue

##### 8.2.3.1 Black Market
TODO: Detail illicit trade

##### 8.2.3.2 Grants
TODO: Explain special funding

##### 8.2.3.3 Donations
TODO: Describe public support

### 8.3 Expense Systems

#### 8.3.1 Operational Costs
TODO: Define running expenses

##### 8.3.1.1 Salary Costs
TODO: Detail personnel expenses

##### 8.3.1.2 Maintenance Costs
TODO: Explain upkeep expenses

##### 8.3.1.3 Supply Costs
TODO: Describe consumable expenses

#### 8.3.2 Development Costs
TODO: Define growth expenses

##### 8.3.2.1 Construction Costs
TODO: Detail building expenses

##### 8.3.2.2 Research Costs
TODO: Explain science expenses

##### 8.3.2.3 Manufacturing Costs
TODO: Describe production expenses

#### 8.3.3 Emergency Costs
TODO: Define crisis expenses

##### 8.3.3.1 Repair Costs
TODO: Detail damage expenses

##### 8.3.3.2 Medical Costs
TODO: Explain treatment expenses

##### 8.3.3.3 Replacement Costs
TODO: Describe loss expenses

### 8.4 Trade Systems

#### 8.4.1 Market Mechanics
TODO: Define trading systems

##### 8.4.1.1 Supply and Demand
TODO: Detail price mechanics

##### 8.4.1.2 Market Fluctuations
TODO: Explain price changes

##### 8.4.1.3 Trade Routes
TODO: Describe commerce paths

#### 8.4.2 Black Market
TODO: Define illicit trade

##### 8.4.2.1 Illegal Goods
TODO: Detail contraband items

##### 8.4.2.2 Risk Mechanics
TODO: Explain danger factors

##### 8.4.2.3 Reputation Effects
TODO: Describe consequence systems

#### 8.4.3 Inter-Base Trade
TODO: Define internal commerce

##### 8.4.3.1 Transfer Costs
TODO: Detail shipping expenses

##### 8.4.3.2 Transfer Time
TODO: Explain delivery duration

##### 8.4.3.3 Transfer Capacity
TODO: Describe volume limits

## 9. Campaign Systems

### 9.1 Campaign Structure

#### 9.1.1 Campaign Phases
TODO: Define progression stages

##### 9.1.1.1 Early Game
TODO: Detail initial phase

##### 9.1.1.2 Mid Game
TODO: Explain development phase

##### 9.1.1.3 Late Game
TODO: Describe endgame phase

#### 9.1.2 Victory Conditions
TODO: Define win states

##### 9.1.2.1 Military Victory
TODO: Detail combat win

##### 9.1.2.2 Diplomatic Victory
TODO: Explain peaceful win

##### 9.1.2.3 Technology Victory
TODO: Describe science win

#### 9.1.3 Defeat Conditions
TODO: Define loss states

##### 9.1.3.1 Economic Collapse
TODO: Detail bankruptcy loss

##### 9.1.3.2 Military Defeat
TODO: Explain combat loss

##### 9.1.3.3 Political Failure
TODO: Describe support loss

### 9.2 Threat Progression

#### 9.2.1 Invasion Phases
TODO: Define alien escalation

##### 9.2.1.1 Scout Phase
TODO: Detail reconnaissance stage

##### 9.2.1.2 Infiltration Phase
TODO: Explain subversion stage

##### 9.2.1.3 Assault Phase
TODO: Describe attack stage

#### 9.2.2 Threat Metrics
TODO: Define danger measurement

##### 9.2.2.1 Global Threat Level
TODO: Detail world danger

##### 9.2.2.2 Regional Threat
TODO: Explain local danger

##### 9.2.2.3 Threat Indicators
TODO: Describe warning signs

#### 9.2.3 Escalation Triggers
TODO: Define progression causes

##### 9.2.3.1 Time Triggers
TODO: Detail scheduled events

##### 9.2.3.2 Action Triggers
TODO: Explain player-caused events

##### 9.2.3.3 Random Triggers
TODO: Describe chance events

TODO: Define advisor mechanics (Advisor System)
TODO: Describe organization advancement points (Power Points System)
### 9.3 Story Systems

#### 9.3.1 Main Plot
TODO: Define core narrative

##### 9.3.1.1 Story Missions
TODO: Detail plot missions

##### 9.3.1.2 Plot Revelations
TODO: Explain story reveals

##### 9.3.1.3 Character Arcs
TODO: Describe NPC stories

#### 9.3.2 Side Stories
TODO: Define optional narratives

##### 9.3.2.1 Faction Stories
TODO: Detail group narratives

##### 9.3.2.2 Character Stories
TODO: Explain personal tales

##### 9.3.2.3 Discovery Stories
TODO: Describe research narratives
TODO: Define quest mechanics (Quest System)

#### 9.3.3 Dynamic Events
TODO: Define emergent stories

##### 9.3.3.1 Random Events
TODO: Detail chance occurrences

##### 9.3.3.2 Consequence Chains
TODO: Explain cause-effect stories

##### 9.3.3.3 Player Stories
TODO: Describe created narratives
TODO: Describe emergent event mechanics (Dynamic Event System)

## 10. User Interface Systems

### 10.1 Interface Design

#### 10.1.1 Grid System
TODO: Define UI layout

##### 10.1.1.1 24x24 Grid
TODO: Detail grid specifications

##### 10.1.1.2 Widget Alignment
TODO: Explain element positioning

##### 10.1.1.3 Responsive Scaling
TODO: Describe size adaptation

#### 10.1.2 Visual Hierarchy
TODO: Define importance system

##### 10.1.2.1 Information Priority
TODO: Detail data importance

##### 10.1.2.2 Color Coding
TODO: Explain color meanings

##### 10.1.2.3 Typography System
TODO: Describe text hierarchy

#### 10.1.3 Interaction Design
TODO: Define user controls

##### 10.1.3.1 Input Methods
TODO: Detail control schemes

##### 10.1.3.2 Feedback Systems
TODO: Explain response mechanics

##### 10.1.3.3 Accessibility Features
TODO: Describe inclusive design

### 10.2 Screen Types

#### 10.2.1 Menu Screens
TODO: Define navigation interfaces

##### 10.2.1.1 Main Menu
TODO: Detail game entry

##### 10.2.1.2 Options Menu
TODO: Explain settings interface

##### 10.2.1.3 Load/Save Menu
TODO: Describe game management

#### 10.2.2 Game Screens
TODO: Define gameplay interfaces

##### 10.2.2.1 Geoscape Interface
TODO: Detail strategic UI

##### 10.2.2.2 Basescape Interface
TODO: Explain management UI

##### 10.2.2.3 Battlescape Interface
TODO: Describe tactical UI

#### 10.2.3 Information Screens
TODO: Define data interfaces

##### 10.2.3.1 UFOpedia
TODO: Detail encyclopedia system

##### 10.2.3.2 Statistics Screen
TODO: Explain performance data

##### 10.2.3.3 Reports Screen
TODO: Describe event logs

### 10.3 HUD Systems

#### 10.3.1 Combat HUD
TODO: Define battle interface

##### 10.3.1.1 Unit Information
TODO: Detail soldier data

##### 10.3.1.2 Action Bar
TODO: Explain command interface

##### 10.3.1.3 Status Indicators
TODO: Describe condition display

#### 10.3.2 Strategic HUD
TODO: Define world interface

##### 10.3.2.1 Time Controls
TODO: Detail speed management

##### 10.3.2.2 Alert System
TODO: Explain notifications

##### 10.3.2.3 Resource Display
TODO: Describe economy view

#### 10.3.3 Management HUD
TODO: Define base interface

##### 10.3.3.1 Facility View
TODO: Detail building display

##### 10.3.3.2 Personnel View
TODO: Explain staff display

##### 10.3.3.3 Production View
TODO: Describe work display

## 11. Modding Systems

### 11.1 Mod Structure

#### 11.1.1 Mod Organization
TODO: Define mod layout

##### 11.1.1.1 Directory Structure
TODO: Detail folder organization

##### 11.1.1.2 File Naming
TODO: Explain naming conventions

##### 11.1.1.3 Load Order
TODO: Describe priority system

#### 11.1.2 Content Types
TODO: Define moddable elements

##### 11.1.2.1 Data Mods
TODO: Detail TOML modifications

##### 11.1.2.2 Asset Mods
TODO: Explain graphic/audio mods

##### 11.1.2.3 Code Mods
TODO: Describe script modifications

#### 11.1.3 Mod Metadata
TODO: Define mod information

##### 11.1.3.1 Mod Manifest
TODO: Detail mod.toml structure

##### 11.1.3.2 Dependencies
TODO: Explain requirement system

##### 11.1.3.3 Compatibility
TODO: Describe version matching

### 11.2 Content Creation

#### 11.2.1 TOML Schemas
TODO: Define data formats

##### 11.2.1.1 Unit Definitions
TODO: Detail unit format

##### 11.2.1.2 Item Definitions
TODO: Explain equipment format

##### 11.2.1.3 Mission Definitions
TODO: Describe scenario format

#### 11.2.2 Asset Pipeline
TODO: Define asset creation

##### 11.2.2.1 Sprite Requirements
TODO: Detail image specifications

##### 11.2.2.2 Audio Requirements
TODO: Explain sound specifications

##### 11.2.2.3 Map Requirements
TODO: Describe level specifications
 
TODO: Define Tileset & Asset Caching system (spritesheet atlases, caching strategy, memory budgets)

#### 11.2.3 Validation Systems
TODO: Define quality checks

##### 11.2.3.1 Schema Validation
TODO: Detail format checking

##### 11.2.3.2 Asset Validation
TODO: Explain resource checking

##### 11.2.3.3 Balance Validation
TODO: Describe gameplay checking

### 11.3 Mod Distribution

#### 11.3.1 Packaging
TODO: Define mod distribution

##### 11.3.1.1 Archive Format
TODO: Detail package structure

##### 11.3.1.2 Compression
TODO: Explain size optimization

##### 11.3.1.3 Versioning
TODO: Describe version management

#### 11.3.2 Publishing
TODO: Define mod sharing

##### 11.3.2.1 Workshop Integration
TODO: Detail platform support

##### 11.3.2.2 Direct Distribution
TODO: Explain manual sharing

##### 11.3.2.3 Update Mechanisms
TODO: Describe patch systems

#### 11.3.3 Community Features
TODO: Define social systems

##### 11.3.3.1 Mod Rating
TODO: Detail quality metrics

##### 11.3.3.2 Mod Comments
TODO: Explain feedback systems

##### 11.3.3.3 Mod Collections
TODO: Describe mod packs

## 12. Technical Systems

### 12.1 Performance

#### 12.1.1 Optimization
TODO: Define speed systems

##### 12.1.1.1 Render Optimization
TODO: Detail graphics performance

##### 12.1.1.2 Logic Optimization
TODO: Explain computation speed

##### 12.1.1.3 Memory Optimization
TODO: Describe RAM management

#### 12.1.2 Scalability
TODO: Define growth handling

##### 12.1.2.1 Unit Scalability
TODO: Detail entity limits

##### 12.1.2.2 Map Scalability
TODO: Explain world size

##### 12.1.2.3 Save Scalability
TODO: Describe data growth

#### 12.1.3 Platform Support
TODO: Define compatibility

##### 12.1.3.1 Operating Systems
TODO: Detail OS support

##### 12.1.3.2 Hardware Requirements
TODO: Explain minimum specs

##### 12.1.3.3 Controller Support
TODO: Describe input devices

### 12.2 Save System

#### 12.2.1 Save Structure
TODO: Define data storage

##### 12.2.1.1 Save Format
TODO: Detail file structure

##### 12.2.1.2 Data Compression
TODO: Explain size reduction

##### 12.2.1.3 Version Migration
TODO: Describe compatibility

#### 12.2.2 Save Types
TODO: Define save varieties

##### 12.2.2.1 Campaign Saves
TODO: Detail full saves

##### 12.2.2.2 Battle Saves
TODO: Explain tactical saves

##### 12.2.2.3 Quicksaves
TODO: Describe fast saves

#### 12.2.3 Cloud Saves
TODO: Define online storage

##### 12.2.3.1 Sync Mechanics
TODO: Detail synchronization

##### 12.2.3.2 Conflict Resolution
TODO: Explain merge handling

##### 12.2.3.3 Backup Systems
TODO: Describe data protection

### 12.3 Multiplayer Systems

#### 12.3.1 Network Architecture
TODO: Define online structure

##### 12.3.1.1 Connection Types
TODO: Detail network modes

##### 12.3.1.2 Synchronization
TODO: Explain state matching

##### 12.3.1.3 Latency Handling
TODO: Describe lag compensation

#### 12.3.2 Game Modes
TODO: Define multiplayer types

##### 12.3.2.1 Cooperative Campaign
TODO: Detail co-op play

##### 12.3.2.2 Versus Battles
TODO: Explain PvP combat

##### 12.3.2.3 Asynchronous Play
TODO: Describe turn-based online

#### 12.3.3 Social Features
TODO: Define community systems

##### 12.3.3.1 Friend Systems
TODO: Detail social connections

##### 12.3.3.2 Matchmaking
TODO: Explain player matching

##### 12.3.3.3 Leaderboards
TODO: Describe ranking systems

## 13. Balance Systems

### 13.1 Difficulty Settings

#### 13.1.1 Difficulty Levels
TODO: Define challenge tiers

##### 13.1.1.1 Easy Mode
TODO: Detail beginner settings

##### 13.1.1.2 Normal Mode
TODO: Explain standard settings

##### 13.1.1.3 Hard Mode
TODO: Describe veteran settings

##### 13.1.1.4 Ironman Mode
TODO: Detail permadeath settings

#### 13.1.2 Difficulty Modifiers
TODO: Define adjustment factors

##### 13.1.2.1 AI Modifiers
TODO: Detail intelligence changes

##### 13.1.2.2 Resource Modifiers
TODO: Explain economy changes

##### 13.1.2.3 Combat Modifiers
TODO: Describe battle changes

#### 13.1.3 Dynamic Difficulty
TODO: Define adaptive systems

##### 13.1.3.1 Performance Tracking
TODO: Detail skill measurement

##### 13.1.3.2 Adjustment Algorithms
TODO: Explain scaling logic

##### 13.1.3.3 Player Overrides
TODO: Describe manual control

### 13.2 Progression Curves

#### 13.2.1 Power Progression
TODO: Define strength growth

##### 13.2.1.1 Unit Progression
TODO: Detail soldier growth

##### 13.2.1.2 Tech Progression
TODO: Explain research advancement

##### 13.2.1.3 Base Progression
TODO: Describe facility growth

#### 13.2.2 Threat Progression
TODO: Define danger growth

##### 13.2.2.1 Enemy Progression
TODO: Detail alien advancement

##### 13.2.2.2 Mission Progression
TODO: Explain difficulty increase

##### 13.2.2.3 Crisis Progression
TODO: Describe escalation rate

#### 13.2.3 Economic Progression
TODO: Define wealth growth

##### 13.2.3.1 Income Progression
TODO: Detail revenue growth

##### 13.2.3.2 Cost Progression
TODO: Explain expense scaling

##### 13.2.3.3 Value Progression
TODO: Describe worth increase

### 13.3 Testing Systems

#### 13.3.1 Automated Testing
TODO: Define test automation

##### 13.3.1.1 Unit Tests
TODO: Detail component tests

##### 13.3.1.2 Integration Tests
TODO: Explain system tests

##### 13.3.1.3 Performance Tests
TODO: Describe speed tests

#### 13.3.2 Balance Testing
TODO: Define gameplay testing

##### 13.3.2.1 Simulation Tests
TODO: Detail AI playtesting

##### 13.3.2.2 Statistical Analysis
TODO: Explain data mining

##### 13.3.2.3 Player Metrics
TODO: Describe telemetry data

#### 13.3.3 Quality Assurance
TODO: Define bug prevention

##### 13.3.3.1 Bug Tracking
TODO: Detail issue management

##### 13.3.3.2 Regression Testing
TODO: Explain fix validation

##### 13.3.3.3 Release Testing
TODO: Describe final checks

TODO: Define comprehensive test scenarios and validation framework
## 14. Analytics Systems

### 14.1 Data Collection

#### 14.1.1 Gameplay Metrics
TODO: Define play data

##### 14.1.1.1 Action Tracking
TODO: Detail player actions

##### 14.1.1.2 Decision Tracking
TODO: Explain choice recording

##### 14.1.1.3 Performance Tracking
TODO: Describe success metrics

#### 14.1.2 System Metrics
TODO: Define technical data

TODO: Autonomous Simulation & Log Capture framework (headless simulation, Parquet/SQL export, replay reproducibility)

##### 14.1.2.1 Performance Metrics
TODO: Detail speed data

##### 14.1.2.2 Stability Metrics
TODO: Explain crash data

##### 14.1.2.3 Resource Metrics
TODO: Describe usage data

#### 14.1.3 Player Metrics
TODO: Define user data

##### 14.1.3.1 Session Metrics
TODO: Detail play sessions

##### 14.1.3.2 Retention Metrics
TODO: Explain player return

##### 14.1.3.3 Engagement Metrics
TODO: Describe involvement data

### 14.2 Data Analysis

#### 14.2.1 Statistical Analysis
TODO: Define data processing

##### 14.2.1.1 Descriptive Statistics
TODO: Detail basic analysis

##### 14.2.1.2 Inferential Statistics
TODO: Explain advanced analysis

##### 14.2.1.3 Predictive Analytics
TODO: Describe forecasting

#### 14.2.2 Visualization
TODO: Define data display

##### 14.2.2.1 Dashboards
TODO: Detail overview displays

##### 14.2.2.2 Reports
TODO: Explain detailed views

##### 14.2.2.3 Alerts
TODO: Describe warning systems

#### 14.2.3 Insights
TODO: Define learning systems

##### 14.2.3.1 Pattern Detection
TODO: Detail trend finding

##### 14.2.3.2 Anomaly Detection
TODO: Explain outlier finding

##### 14.2.3.3 Recommendation Engine
TODO: Describe suggestion system

## 15. Future Systems

### 15.1 Planned Features

#### 15.1.1 Content Expansions
TODO: Define future content

##### 15.1.1.1 New Factions
TODO: Detail faction additions

##### 15.1.1.2 New Missions
TODO: Explain mission additions

##### 15.1.1.3 New Technologies
TODO: Describe tech additions

#### 15.1.2 System Expansions
TODO: Define future systems

##### 15.1.2.1 Space Combat
TODO: Detail orbital battles

##### 15.1.2.2 Diplomacy Expansion
TODO: Explain deeper politics

##### 15.1.2.3 Base Automation
TODO: Describe AI assistance

#### 15.1.3 Technical Improvements
TODO: Define future tech

##### 15.1.3.1 Graphics Upgrades
TODO: Detail visual improvements

##### 15.1.3.2 Performance Upgrades
TODO: Explain speed improvements

##### 15.1.3.3 Platform Expansions
TODO: Describe new platforms

### 15.2 Community Features

#### 15.2.1 Workshop Integration
TODO: Define mod platform

##### 15.2.1.1 Mod Browser
TODO: Detail discovery system

##### 15.2.1.2 Mod Tools
TODO: Explain creation tools

##### 15.2.1.3 Mod Sharing
TODO: Describe distribution

#### 15.2.2 Social Integration
TODO: Define social features

##### 15.2.2.1 Achievement System
TODO: Detail accomplishments

##### 15.2.2.2 Screenshot Sharing
TODO: Explain media sharing

##### 15.2.2.3 Replay System
TODO: Describe match recording

#### 15.2.3 Competitive Features
TODO: Define competition systems

##### 15.2.3.1 Tournaments
TODO: Detail organized play

##### 15.2.3.2 Seasons
TODO: Explain ranked periods

##### 15.2.3.3 Spectator Mode
TODO: Describe viewing system

TODO: Define advanced and experimental mechanics (Experimental/Aspirational Systems)
# End of Master Plan

### Glossary & Terminology Reference
TODO: Define key terms and concepts
