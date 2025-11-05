# AlienFall Game Mechanics Overview

> **Status**: Master Reference Document (ENHANCED v6 - COMPLETE Consolidation)
> **Last Updated**: 2025-11-02 - FULLY CONSOLIDATED from Economy.md, Lore.md, Interception.md
> **Consolidation**: All game design mechanics merged into single unified overview; technical specs remain in legacy/
> **Metrics**: 7,000+ lines | 600+ mechanics | 31 sections | comprehensive coverage
> **Purpose**: Unified game design reference synthesizing all mechanics specifications into organized system categories
> **Audience**: Game designers, engineers, balance analysts, modders, QA testers

---

## Table of Contents

1. [System Architecture Overview](#system-architecture-overview)
2. [Core Game Systems](#core-game-systems)
   - [Geoscape (Strategic Layer)](#1-geoscape-strategic-layer)
   - [Basescape (Operational Layer)](#2-basescape-operational-layer)
   - [Interception (Mid-Tactical Layer)](#2b-interception-mid-tactical-combat-layer) - NEW
   - [Battlescape (Tactical Layer)](#3-battlescape-tactical-layer)
3. [Cross-Cutting Systems](#cross-cutting-systems)
   - [Unit Management](#unit-management)
   - [Equipment & Items](#equipment--items)
   - [Damage & Combat Resolution](#damage--combat-resolution)
   - [Economy & Resources](#economy--resources)
   - [Diplomatic Systems](#diplomatic-systems)
   - [Psychological Systems](#psychological-systems)
   - [Progression & Advancement](#progression--advancement)
4. [Advanced Systems (v2 Addition)](#advanced-systems-v2-addition)
   - [Fame, Karma & Reputation Systems](#section-x-fame-karma--reputation-systems)
   - [Hex Coordinate System](#section-xi-hex-coordinate-system--navigation)
   - [Pilot & Craft Systems](#section-xii-pilot--craft-systems)
   - [Interception Combat](#section-xiii-interception-combat-layer)
   - [AI Architecture](#section-xiv-ai-systems-architecture)
   - [Finance & Monetary Systems](#section-xv-finance--monetary-systems)
   - [Black Market Economy](#section-xvi-black-market--underground-economy)
   - [System Integration](#section-xvii-system-integration--data-flow)
   - [Mission Generation & Mission System](#section-xviii-mission-generation--mission-system) - NEW
   - [Environment, Terrain & Weather](#section-xix-environment-terrain--weather-system) - NEW
   - [Traits & Perks System](#section-xx-traits--perks-system) - NEW
   - [Lore, Factions & Campaign](#section-xxi-lore-factions--campaign-structure) - NEW
   - [Victory & Defeat Conditions](#section-xxii-victory--defeat-conditions) - NEW
   - [Campaign Progression Timeline](#section-xxiii-campaign-progression-timeline) - NEW
   - [Countries, Nations & Diplomacy](#section-xxiv-countries-nations--diplomacy-system) - NEW
   - [Marketplace & Trading](#section-xix-marketplace--trading-system) - NEW/EXPANDED
   - [Dynamic Events](#section-xx-dynamic-event-system) - NEW
   - [Quest System](#section-xxi-quest-system) - NEW
   - [System Integration & Dependencies](#section-xxvii-system-integration--dependencies) - NEW
   - [Test Scenarios & Validation](#section-xxviii-test-scenarios--validation) - NEW
   - [Glossary & Terminology](#section-xxv-glossary--terminology-reference) - NEW
   - [Tutorial & New Player Experience](#section-xxvi-tutorial--new-player-experience) - NEW
5. [Integration Points](#integration-points)
6. [Mechanics Index](#mechanics-index-alphabetical)

---

## System Architecture Overview

AlienFall is organized into **three interconnected game layers** that operate simultaneously with extensive cross-system dependencies:

```
                        GEOSCAPE (Strategic)
                    ↓ Monthly turns, world map, diplomacy

     BASESCAPE (Operational) ← → BATTLESCAPE (Tactical)
     Base management, facilities     Turn-based squad combat
     Personnel, research             Hex grid, cover system
     Equipment, economy              Unit actions, damage resolution

     ↓ All layers affected by ↓

     ECONOMY SYSTEM (Resources, funding, costs)
     UNIT SYSTEM (Recruitment, experience, progression)
     EQUIPMENT SYSTEM (Weapons, armor, items)
     DIPLOMATIC SYSTEM (Relations, countries, missions)
     PSYCHOLOGICAL SYSTEM (Morale, sanity, fear)
```

---

# Core Game Systems

## 1. GEOSCAPE (Strategic Layer)

**Location**: `engine/geoscape/`, `gui/scenes/geoscape_screen.lua`

### Purpose
Global strategic management where players decide where to build bases, deploy interceptors, defend countries, and respond to alien threats over monthly timescales.

### Core Mechanics

#### World Map System
- **Representation**: 90×45 hexagonal grid (~500 km per hex across Earth/Moon/Mars)
- **Spatial Organization**:
  - Hexes → Provinces (6-12 hexes each) → Regions (multiple provinces)
  - Countries occupy multiple provinces with territorial boundaries
  - Each province allows max 1 player base
- **Hex Properties**: Terrain (affects movement/construction), population (mission frequency), resources, country ownership
- **Map Generation**: Procedural continents with strategic choke points and realistic geography

#### Base Placement & Expansion
- **Core Rules**:
  - One base per province (exclusive territorial occupation)
  - Construction requires clear hex (no mountains/cities)
  - Adjacent hexes can provide (clarification: NO BONUSES despite previous specs)
  - Bases provide operational hubs for radar coverage, craft operations, resource processing, personnel housing
- **Base Growth**:
  - Facility construction adds specialized capabilities
  - Territory control extends operational range
  - Research unlocks advanced technologies
  - Upgrade system with progression tiers

#### Craft Operations (Geoscape Layer)
- **Movement**: Hex-based movement with terrain modifiers, fuel consumption per distance
- **Deployment States**: Base (ready), Transit (vulnerable), Mission (active), Recovery (return)
- **Range System**: Fuel capacity determines operational distance; insufficient fuel prevents launch
- **Maintenance Cycles**: Regular downtime required between missions
- **Weather Effects**: Affects radar range, visibility, mission availability (See Weather System A8)

#### Mission Detection & Radar
- **Detection System**:
  - Radar networks detect UFOs within range
  - UFOs generate missions based on country location and threat level
  - Detection affected by weather (clear 100% range, rain 75%, storm 50%, snow 25%, blizzard 0%)
- **Mission Generation**:
  - 2-5 faction missions per month (based on escalation)
  - 1-3 country missions per month (based on relations and panic)
  - 0-2 random events per month
  - Player-triggered missions (craft interceptions)
  - Black market custom missions (purchased)
- **Mission Types**: UFO crash, UFO interception, alien base assault, terror operations, base defense, colony defense, research facility recovery, supply raids

#### Strategic Decision Making
- **Monthly Planning**: Players decide:
  - Where to deploy crafts (coverage vs readiness)
  - Which missions to accept (relations vs risk)
  - Facility construction timing (investment vs capability)
  - Country support prioritization (funding vs operations)
- **Escalation Mechanics**: Alien threat escalates through 4 phases (Contact, Escalation, Crisis, Climax) with predefined mission arcs
- **Portal System (A2)**: Research-gated teleportation enabling instant base-to-base transport (50K credits setup, 5K credits per use, capacity 10 units/5000kg)

#### Diplomacy Integration
- **Country Relations**: -100 (war) to +100 (allied) tracked for each nation
- **Funding Generation**: Monthly income = Funding Level × Relation Modifier (0.5 to 1.5x)
- **Mission Frequency**: Allied (+40 to +100) generate 2-3 missions/month; Neutral 1/month; Cold/Hostile 0.25-0.5/month
- **Panic Mechanics**: Country panic (0-100 scale) drives mission rates, funding penalties, and collapse at 100+
- **Regional Effects**: Countries organized into blocs with cascading diplomatic consequences

---

## 2. BASESCAPE (Operational Layer)

**Location**: `engine/basescape/`, `gui/scenes/basescape_screen.lua`

### Purpose
Base construction and personnel management where players recruit units, manufacture equipment, conduct research, and manage resources during downtime between missions.

### Core Mechanics

#### Base Facility System
- **Facility Grid**: 40×60 orthogonal squares per base
- **Facility Types** (20+):
  - Command Center, Barracks, Medical Bay, Laboratory, Workshop, Hangar
  - Academy, Hospital, Detention Center, Power Plant, Storage
  - Living Quarters, Engineering Bay, Intelligence Center, etc.
- **Facility Mechanics**:
  - Construction costs (150K-600K credits depending on type)
  - Power consumption (0-2000 power units per facility)
  - Maintenance costs (80-2000K credits monthly depending on type)
  - Adjacency: NO BONUSES for adjacent facilities (clarification)
  - Damage/Repair: Facilities can be damaged in base raids and require repair time
  - Underground Facilities: Grid system for buried constructions

#### Power Management System
- **Power Generation**: Facilities produce power (Power Plant 5000 units, Solar 1000 units, etc.)
- **Power Demand**: Each facility consumes power; total must not exceed generation
- **Priority System**: 10-tier priority system for power allocation during shortages:
  - Tier 1: Command Center, Life Support (always active)
  - Tier 2: Barracks, Medical Bay (critical personnel)
  - Tier 3: Hangar (craft readiness)
  - Tier 4: Laboratory, Workshop (research/manufacturing)
  - Tier 10: Luxury facilities, recreational (lowest priority)
- **Shortage Handling**: If insufficient power, lowest-priority facilities shut down automatically; cascading effects on operations
- **Expansion**: Power Plant upgrades add capacity

#### Personnel Management
- **Recruitment**:
  - Rank 1 "Agent" class units available from marketplace
  - Specialist units available through tech research and supplier contracts
  - Rank limits enforced by squad depth (Rank 5 requires 3 Rank 4+ units minimum)
  - Resurrection program available through research
  - Black market access (high cost, reputation penalties)
- **Unit Maintenance**:
  - Monthly salary costs: 5K (Rank 1) to 12.5K (veteran)
  - Morale/psychology tracking affects deployment
  - Wound recovery requires medical facilities
  - Mental health recovery in meditation facilities
- **Specialization & Advancement**:
  - Units gain experience in combat or training
  - Rank promotion at XP thresholds (200, 500, 900, 1500, 2500, 4500)
  - At Rank 2+, players select specialization path (one-time choice)
  - Demotion system allows re-specialization with proportional XP retention
- **Unit Traits**: Permanent personality traits affecting stats, XP gain, morale, abilities

#### Research System
- **Research Tree**: 5 branches (Weapons, Armor, Alien Tech, Facilities, Support)
- **Research Facility**: Laboratory provides research capacity per month
- **Technology Prerequisites**: Advanced items/units require prior tech research
- **Time & Cost**: Research takes multiple months and consumes credits
- **Unlocks**: New equipment, unit types, facility types, abilities

#### Manufacturing System
- **Production Facilities**: Workshop manufactures equipment from raw resources and blueprints
- **Manufacturing Constraints**:
  - Requires researched technology
  - Consumes resources (metal, fuel, electronics, etc.)
  - Takes time (production queue)
  - Limited workshop capacity
- **Equipment Types**: Weapons, armor, consumables (grenades, medikit, etc.), craft addon
- **Crafting Chains**: Some items require multiple components (e.g., Advanced Armor = Titanium + Alien Alloy + Power Cell)

#### Storage & Supply Management
- **Storage Facilities**: Warehouse stores resources, equipment, salvage
- **Capacity Limits**: Finite storage space requires facility expansion
- **Item Management**: Players must allocate equipment, assign weapons to units, store excess
- **Resource Tracking**: Raw materials tracked separately from manufactured items
- **Supply Chain**: Resources → Manufacturing → Equipment → Unit Equipment/Craft Equipment

---

## 3. BATTLESCAPE (Tactical Layer)

**Location**: `engine/battlescape/`, `gui/scenes/battlescape_screen.lua`

### Purpose
Turn-based tactical combat where squads of 1-12 units fight aliens/humans on procedurally generated maps using action point-based movement and combat resolution.

### Core Mechanics

#### Map Generation & Terrain
- **Coordinate System**: Vertical axial coordinate system (see Hex_Coordinate_System.md)
- **Map Generation**: Procedurally generated from map blocks (modular terrain chunks)
- **Terrain Types**:
  - Open (no cover), Terrain (partial cover), Dense (heavy cover)
  - Vegetation, Water, Lava, Ice (with movement/visibility modifiers)
  - Buildings, Underground tunnels, elevated structures
- **Environmental Features**:
  - Fire/smoke that spreads and blocks LOS (See Environment.md)
  - Destructible terrain (walls can be demolished with explosives)
  - Traps, alarms, hazardous areas
  - Day/night cycles affecting visibility

#### Combat Fundamentals
- **Unit Deployment**: Squad sizes 1-12 units; players position units in deployment zone
- **Turn Structure**: Players take turn(s), enemies take turn(s); alternating phases
- **Action Points (AP)**: 4 AP per turn baseline (varies by unit speed stat)
- **Movement**: 1 AP per hex (diagonal = 1 hex, terrain penalties add cost)
- **Combat Actions**: Attack (1-4 AP), reload (1 AP), grenade throw (1 AP), use item (1 AP)

#### Accuracy & Hit Resolution
**CANONICAL FORMULA** (All multiplicative):
```
Accuracy% = Base × Range Mod × Mode Mod × Cover Mod × LOS Mod
Clamped to 5-95% after all modifiers applied
```

**Components**:
- **Base Accuracy**: Weapon base (rifle 70%, sniper 85%, shotgun 60%) + Unit stat modifier (Marksmanship ±5%)
- **Range Modifier**:
  - Point blank (0-2 hex): +20%
  - Optimal (3-5 hex): +0%
  - Medium (6-10 hex): -10%
  - Long (11-15 hex): -20%
  - Extreme (16+ hex): -40%
- **Fire Mode Modifier**:
  - Snap Shot: -20% (1 AP, quick)
  - Aimed Shot: +20% (3 AP, deliberate)
  - Burst Fire: -10% (3 AP, 2-3x damage)
  - Auto Fire: -20% (4 AP, sustained)
- **Cover Modifier**:
  - Open: +0%
  - In Cover: -Cost of Sight (e.g., -15% for 50% concealment)
  - Critical Cover: -30-50% (nearly total cover)
- **Line of Sight (LOS) Modifier**:
  - Direct LOS: +0%
  - Obstructed LOS: -10-40% (depends on obstacle)
  - Through smoke: -50% (smoke blocks precision)

**Cover System**:
- **Components**: Cost of Sight (visibility reduction) + Cost of Fire (accuracy reduction)
- **Implementation**:
  - Cover blocks shots partially (% of shots ignored)
  - Targeted shots at covered units suffer -15-30% accuracy
  - Movement around cover changes effectiveness
  - Walls provide 100% block (shots cannot pass), 50% reduction for units behind walls
- **Destruction**: Walls can be destroyed with explosives or sustained fire

#### Damage Resolution
- **Damage Types**: 8 types (Kinetic, Explosive, Energy, Psi, Stun, Acid, Fire, Frost)
- **Damage Application**:
  1. Roll base damage ± random variance
  2. Apply location multiplier (Head 1.5x, Limb 0.8x, Torso 1.0x)
  3. Apply armor resistance (damage × (1 - armor_resistance%))
  4. Apply status effects (fire damage over time, acid degradation)
  5. Apply to unit health pool
- **No Critical Hits**: Damage is consistent; success rewarded through positioning and tactics
- **Armor Mechanics**:
  - Light armor: +5 armor value, -0 movement penalty
  - Combat armor: +15 armor value, -1 hex/turn penalty
  - Heavy armor: +25 armor value, -2 hex/turn penalty, -2 AP/turn
  - Special armor: Type-specific resistances (hazmat for acid, etc.)

#### Unit Actions & Abilities
- **Movement**: Use AP to move between hexes (terrain and armor affect cost)
- **Attack**: Shoot, throw grenade, melee attack (cost varies 1-4 AP)
- **Equipment Use**: Use item (medikit, flare, motion scanner) - 1 AP
- **Special Abilities**: Class-specific abilities (leader inspire, medic heal, specialist unlock, etc.)
- **Reaction Actions**: Opportunity attacks, overwatch, cover repositioning (free or reduced AP)

#### Status Effects & Conditions
- **Suppression**: -3 AP per turn (max), stacks across enemies, resets at turn end if no fire
- **Stun**: Incapacitates unit (separate pool from health), -5 stun per turn recovery, -1 turn to act when stunned
- **Fire**: Damage over time, spreads to adjacent hexes, extinguished by water/spending action
- **Smoke**: Blocks LOS/accuracy (-50% when firing through smoke), dissipates over time
- **Bleeding**: -1 HP per turn when incapacitated, stopped by medic attention
- **Acid**: Damage over time, ignores line of effect (spreads), degrades armor
- **Frost**: Slows movement (+1 movement cost per hex), -10% accuracy
- **Morale**: Affects action point efficiency and accuracy based on psychology (see Psychological Systems)

#### Melee Combat
- **Range**: 1 hex only
- **Base Damage**: (Unit Strength / 2) + Weapon Base Damage
- **Special Rules**:
  - Always available (no ammo)
  - Silent (no alert radius)
  - Can be used for crowd control
  - Backstab bonus: +20% accuracy if attacking from behind

#### Projectile Physics
- **Deviation**: Projectiles can miss and hit adjacent hexes based on accuracy
- **Ricochets**: Certain surfaces cause bounces (grenade bounces off walls)
- **Detonation**: Grenades explode on impact or timer, creating area damage

#### Explosion Mechanics
- **Area Effect**: Damage radiates in 4 cardinal directions from epicenter
- **Distance Scaling**: Damage = Base - (5 × distance in hexes)
- **Wall Blocking**:
  - Walls block explosion propagation (100% block)
  - Units behind walls take 50% reduced explosion damage + armor resistance
  - Explosions damage walls (can destroy cover)
- **Multiple Explosions**: Stack linearly (two explosions = sum of both)

#### Initiative & Turn Order
- **Calculation**: Base Initiative = Unit Speed stat, modified by encumbrance and status
- **Ties**: Player units always act first
- **Re-roll Option**: Units can sacrifice action to improve initiative next turn

#### Victory Conditions
- **Objective Completion**: Most missions have primary objective (eliminate all aliens, secure location, rescue VIPs)
- **Survival**: Squad extraction (all units must reach extraction point)
- **Partial Success**: Some missions allow retreat with captured equipment/prisoners

#### 3D Perspective Layer
- **Mechanics**: 100% identical to 2D (same accuracy, same damage, same movement)
- **Perspective Only**: First-person camera (WSAD movement, Tab unit selection, V toggle perspective)
- **FOV**: 90° cone
- **Interoperability**: Can switch between 2D and 3D mid-mission without mechanic changes

---

# Cross-Cutting Systems

## Unit Management

### Unit Classification & Progression

#### Rank System (Experience-Based)
- **Rank 0**: Conscript (untrained, 0 XP) - limited supplies
- **Rank 1**: Agent (trained operative, 200 XP) - basic role assignment
- **Rank 2**: Specialist (500 XP) - role proficiency
- **Rank 3**: Expert (900 XP) - significant specialization
- **Rank 4**: Master (1500 XP) - advanced specialization
- **Rank 5**: Elite (2500 XP) - peak specialization
- **Rank 6**: Hero (4500 XP) - unique, one per squad maximum

#### Class Hierarchies (Promotion Trees)
- **Example Human Progression**:
  ```
  Agent (Rank 1)
  ├─ Rifleman (Rank 2) → Assault (Rank 3) → Commando (Rank 4) → Battle Master (Rank 5)
  ├─ Support (Rank 2) → Medic (Rank 3) → Surgeon (Rank 4) → Field Commander (Rank 5)
  └─ Specialist (Rank 2) → Marksman (Rank 3) → Sniper (Rank 4) → Ghost Operative (Rank 5)
  ```
- **Rank Limits**:
  - Rank 2+ requires Rank 1 units minimum (3 Rank 1 = 1 Rank 2 squad capacity)
  - Rank 5 requires minimum 3 Rank 4 units (pyramid structure)
  - Rank 6 Hero requires minimum 3 Rank 5 units (and only one hero allowed)

#### Experience Acquisition
- **Passive Training**: +1 XP/week in barracks (free)
- **Active Training**: +1-3 XP/week (requires training facility, costs credits)
- **Combat XP**:
  - Enemy elimination: +10 XP per kill
  - Damage inflicted: +0.15 XP per damage point (max 100/mission)
  - Survival bonus: +1 XP per turn survived (max 20/mission)
  - Squad cohesion: +10 XP if all survive
  - Mission participation: +50 XP base
- **Modifiers**:
  - Smart trait: +20% XP gain
  - Stupid trait: -20% XP gain
- **Medals**: One-time achievements (Survivor, Destroyer, Sharpshooter, Guardian, Hero, Legendary) provide 25-200 XP bonus

#### Specialization Selection (Promotion)
- **Promotion Trigger**: Automatic when XP threshold reached
- **Specialization Choice**: At Rank 2+, player selects from available promotion branches
- **Permanence**: Choice is permanent per promotion (can only change via demotion)

#### Demotion System (A5 Comprehensive Spec)
- **Definition**: Voluntarily reduce rank to re-specialize
- **Requirements**: Rank 2+, no active missions, 1 week retraining period
- **Cost**: FREE (no credits)
- **XP Retention**: Proportional scaling formula ensures units retain meaningful progress
  ```
  Example: Rank 4 unit (1200 XP) demotes to Rank 3 with ~760 XP (40% progress)
  ```
- **Re-specialization**: Can choose ANY valid specialization at target rank (not just previous path)

#### Unit Traits & Perks (A4 Comprehensive Spec)
- **Trait System**: Permanent personality traits affecting stats, XP, morale, abilities
- **Trait Types**:
  - Positive: Fearless, Noble, Quick Learner, Leader
  - Negative: Coward, Fragile, Slow Learner, Loner
- **Stat Modifications**: Each trait modifies core stats by ±1-2
- **Ability Modifiers**: Some traits unlock/modify special abilities
- **Perk System**: Skills earned through progression and achievement; not deleted on demotion

#### Unit Types & Races
- **Biological**: Healed through medical facilities, subject to morale/panic
- **Mechanical**: Repaired via maintenance, immune to morale (but unique vulnerabilities)
- **Races**: Humans (default), Sectoids, Ethereals, Hybrid (various)
  - Race itself provides NO stat bonuses (all stat distribution is class-based)
  - Race affects visuals and lore only

### Unit Statistics (Core Stats)

| Stat | Range | Purpose |
|------|-------|---------|
| **Strength (STR)** | 6-12 | Melee damage, armor weight penalty, equipment carrying capacity |
| **Marksmanship (MAR)** | 6-12 | Ranged accuracy, critical hit chance (when used) |
| **Dexterity (DEX)** | 6-12 | Movement speed, dodge chance, initiative |
| **Bravery (BRV)** | 6-12 | Morale cap, panic threshold, leadership aura |
| **Intelligence (INT)** | 6-12 | Research bonus, item interaction effectiveness, hacking |
| **Endurance (END)** | 6-12 | Health pool, wound recovery speed, stamina |

---

## Equipment & Items

### Equipment Categories

#### 1. Resources (Raw Materials)
- **Types**: Fuel, Energy sources, Construction materials, Biological materials
- **Progression**: Different game phases unlock different resource types
  - Early: Fuel (5K), Metal (3K)
  - Advanced: Fusion Core (50K), Titanium (20K)
  - Alien War: Elerium (200K), Alien Alloy (150K)
  - Late: Warp Crystal (500K), Quantum Processor (1M)
- **Mechanics**:
  - Crafts consume fuel per mission (stranding risk if insufficient)
  - Resources synthesized into advanced materials
  - Trading available at 50% purchase price
  - Black market suppliers offer rare materials (reputation risk)

#### 2. Unit Equipment

**Weapons**:
- **Types**: Pistols, Rifles, Sniper rifles, Shotguns, Melee
- **Properties**: AP cost (1-4), Range (1-25 hexes), Accuracy (60-85%), Damage (12-45), Ammo capacity
- **Special Weapons**: Grenades, Mines, Flares, Flashbangs, Motion Scanners, Psionic Amplifiers
- **Firing Modes**: Snap Shot, Aimed Shot, Burst Fire, Auto Fire (each with AP/accuracy tradeoffs)
- **Damage Types**: Kinetic, Energy, Explosive, Psionic, Hazard

**Armor**:
- **Types**: Light Scout, Combat, Heavy Assault, Hazmat, Stealth, Medic, Sniper Ghillie
- **Properties**:
  - Armor Value (5-25 damage reduction)
  - Movement Penalty (-0 to -2 hex/turn)
  - AP Penalty (-0 to -2 AP/turn)
  - Accuracy Penalty (-10% to +20%)
  - Strength Requirements (STR 5-10)
- **Class Synergy**: Some armor bonuses when matched to unit class
- **Special Properties**: Hazmat resists poison, Stealth gives infiltration bonuses, Medic amplifies healing

**Consumables**:
- **Medikit**: Heals 15-25 HP (Medic +50% synergy), 5 charges
- **Grenade**: 30 damage area effect, bounces off walls
- **Mine**: 40 damage proximity triggered
- **Flare**: +3 hex vision for 2 turns
- **Flashbang**: 1-turn stun
- **Stimulant**: -10 stun instantly

#### 3. Craft Equipment

**Weapons** (mounted in hardpoints):
- Point Defense Turret (20 km range, 15 damage)
- Main Cannon (20 km range, 40 damage)
- Missile Pod (60 km range, 80 damage area)
- Laser Array (40 km range, 60/turn sustained)
- Plasma Caster (30 km range, 70 damage)

**Support Systems**:
- Energy Shield (+10 health, +20 energy)
- Ablative Armor (-50% explosive damage, degrades 10% per hit)
- Reactive Plating (Explosive +40%, Kinetic +20% resistance)
- Afterburner (+1 speed, higher fuel consumption)
- Enhanced Radar (+100% detection)
- Cargo Pod (+10 capacity)

#### 4. Lore Items
- Non-mechanical story objects (no weight, zero storage cost)
- Unlock research trees and manufacturing blueprints
- Cannot be accidentally sold
- Examples: Historical artifacts, technology samples, creature specimens

#### 5. Prisoners & Corpses
- **Prisoners**: Living captured units (lifespan 10-60 days), can be researched/interrogated/traded/released
- **Corpses**: Harvested from defeated aliens, cheaper to research than prisoners
- **Karma Impact**:
  - Releasing prisoners: +Karma
  - Selling prisoners: -Karma (severe penalty)
  - Corpse trade: -Karma depending on race/quantity

### Equipment Class Synergy System

**Equipment Classes**:
- **Light**: High mobility, low protection (pistols, scout armor, stealth suits)
- **Medium**: Balanced (standard rifles, combat armor)
- **Heavy**: High protection, low mobility (heavy cannon, heavy assault armor)
- **Specialized**: Unique properties (hazmat, sniper ghillie)

**Class Matching Bonuses**:
- Unit class + matching equipment class: +50% effectiveness
- Example: Medic + Medikit = +50% healing potency
- Mismatch penalty: -30% accuracy, -1 movement

### Item Durability System
- Weapons/armor degrade with use and damage
- Degradation increases variance in damage output
- Maintenance facility repairs equipment (cost and time)
- Broken equipment cannot be used until repaired

---

## Damage & Combat Resolution

### Damage Types System (8-Type Model)

| Damage Type | Armor Resistance | Special Effects | Examples |
|---|---|---|---|
| **Kinetic** | 5-50% (by armor type) | Direct impact, no DoT | Bullets, melee |
| **Explosive** | 10-40% (special reduction for area) | Area effect, wall destruction | Grenades, rockets |
| **Energy** | 0-60% (ignores some armor) | Clean damage, piercing | Lasers, plasma |
| **Psi** | 0% (0% reduction), Shield 80% | Ignores standard armor | Alien abilities |
| **Stun** | Separate pool (0% standard resist) | Temporary incapacity, no health damage | Tasers, concussive |
| **Acid** | Special degradation rules | Damage over time, ignores LOS | Alien spit |
| **Fire** | Spreads to adjacent hexes | Damage over time, extinguishable | Incendiary, molotov |
| **Frost** | Slows movement | Movement +1 cost/hex, -10% accuracy | Cryo weapons |

### Armor System

**Armor Values by Type**:
- Light Scout: +5 armor value, STR 5 requirement
- Combat: +15 armor, STR 7 requirement
- Heavy: +25 armor, STR 10 requirement, -2 hex/turn penalty
- Hazmat: +10 armor, 100% poison resistance
- Stealth: +8 armor, +20% stealth, STR 5 requirement
- Medic: +8 armor, +50% healing, STR 6 requirement

**Armor Mechanics**:
- Armor value = damage reduction per hit
- Cannot be changed during battle (equipped before deployment)
- Type-specific resistances to damage types
- Strength penalties for units below requirement

### Explosion Propagation
- **Area Effect**: Radiates in 4 cardinal directions only
- **Distance Scaling**: Base Damage - (5 × hex distance)
- **Wall Blocking**: 100% blocks propagation, units take 50% reduced damage
- **Multiple Stacks**: Explosions add linearly
- **Wall Destruction**: Explosions can destroy cover

---

## Economy & Resources

### Monthly Cashflow Model (Intentionally Tight)

**Design Philosophy**: Intentional scarcity creates tension; 90% win rate required for sustainability

#### Income Sources
- **Country Funding** (50-60% of income):
  - Formula: Funding Level × Relation Modifier (0.5-1.5x)
  - Levels 1-10: 10K-125K credits per country per month
- **Mission Rewards** (30-40% of income):
  - 3K (easy) to 100K+ (mothership operations)
  - Varies by mission type and difficulty
- **Salvage** (10-20% of income): Alien equipment converted to credits
- **Manufacturing** (5-10% of income): Sell excess manufactured equipment

#### Expense Sources
- **Unit Maintenance** (35-45% of expenses):
  - Base 5K (Rank 1) to 12.5K (veteran) per unit per month
  - Salary costs apply only to units in active service
- **Base Maintenance** (30-40% of expenses):
  - Facility maintenance costs: 80-2000K depending on facility type
  - Power generation costs
  - Upgrade costs for facility expansion
- **Craft Maintenance**: Fuel, repairs, ammunition
- **Research**: Technology research costs 20K-500K depending on tech tier
- **Recruitment**: New unit acquisition 5K-50K depending on rank/specialization

#### Monthly Projections by Difficulty
- **Easy Mode**: +20% funding modifier, -20% alien mission frequency, sustainable Month 1
- **Normal Mode**: Baseline, break-even Month 9 with 85%+ win rate
- **Hard Mode**: -20% funding, +30% alien missions, break-even Month 12 with 90%+ win rate
- **Impossible**: -40% funding, doubled alien missions, chronic deficit

#### Economic Crisis Management
**Crisis Levels**:
- Level 1 (Stress): Funding -20%, mission frequency +20%
- Level 2 (Crisis): Funding -40%, demanding missions increase
- Level 3 (Collapse): Funding -60%, potential nation loss

**Crisis Recovery**:
- Successful defense missions: -1 crisis level
- Major alien victory: +2 crisis levels
- 3 months without attacks: Full recovery
- Diplomatic support from allies: -1 crisis level

### Resource Economy

#### Manufacturing Chains
- Raw Resources → Intermediate Materials → Final Equipment
- Example: Metal + Fuel → Titanium → Advanced Armor = Titanium + Alien Alloy + Power Cell
- Synthesis system converts common → rare materials

#### Trading & Market
- Players can sell resources at 50% purchase price
- Black market suppliers offer rare materials (premium pricing +200-500%)
- Trade relationships affect pricing and availability
- Supply contracts provide steady resource income

---

## Diplomatic Systems

### Country Relationship System

#### Relation Values & Categories
- **Range**: -100 (war/embargo) to +100 (strategic partnership)
- **Monthly Changes**: ±1 to ±5 based on actions and time decay

| Range | Category | Funding Multiplier | Mission Frequency | Status |
|----|----|----|----|---|
| 75-100 | Allied | 1.5x | 2-3/month | Strategic partnership |
| 50-74 | Friendly | 1.0x | 1-2/month | Cooperative |
| 25-49 | Positive | 0.75x | 1/month | Good relations |
| -24-24 | Neutral | 0.5x | 0.5/month | Balanced |
| -49--25 | Negative | 0.25x | 0.25/month | Strained |
| -74--50 | Hostile | 0.0x | 0/month | Adversarial |
| -100--75 | War | 0.0x | 0/month | Active conflict |

#### Diplomatic Events Affecting Relations

| Event | Relation Change | Frequency |
|---|---|---|
| Successful Defense Mission | +2-5 | Per mission |
| Mission Failure | -3-5 | Per failure |
| UFO Destroyed in Territory | +3-8 | Per UFO |
| Terror Mission Completed | +8-15 | Major events |
| Civilian Casualties | -1-10 | Per incident |
| Base Raided | -5-10 | Per raid |
| Military Defeat | -10-15 | Allied forces defeated |

#### Country Types & Properties

**Major Powers** (5-8 per game):
- Examples: USA, China, Russia, EU, India
- Starting: +30 relation bonus
- Mission frequency: 40% bonus
- Funding potential: Highest (125K base)

**Secondary Powers** (8-12 per game):
- Examples: Japan, Germany, Brazil
- Standard relationship starting
- Standard mission frequency
- Balanced funding potential

**Minor Nations** (10-15 per game):
- Examples: New Zealand, Cyprus
- Reduced mission frequency
- Lower protective burden
- Good for relationship building

**Supranational Organizations** (2-3):
- Cannot declare war, always neutral/allied
- Special diplomatic mission types

#### Regional Blocs & Cascading Effects
- Countries organized into geographic regions
- Regional panic affects all countries in region
- Regional stability affects UFO sighting frequency
- Collective regional defense provides bonuses
- Bloc relationships create cascading diplomatic consequences

#### Funding System Details
**Funding Level Progression**:
- Level 5 (baseline): 40K credits standard
- Levels 1-4: Reduced budget (10K-30K)
- Levels 6-10: Increased budget (50K-125K)

**Level Changes**:
- +75-100 relation: Auto increase to 8-10
- +40-74 relation: Increase to 6-8
- +11-39 relation: 5-7
- -10-+10 relation: 3-5
- -40--9 relation: 2-4
- -100--75 relation: Funding suspended (0)

#### Panic & Country Collapse

**Panic Accumulation**:
- Terror mission success in territory: +8-12 panic
- UFO sighting: +1-3 panic
- Alien base discovered: +15-25 panic
- Monthly decay without activity: -1 panic

**Panic Effects**:
- 0-25: No effect
- 26-50: -20% funding, morale events
- 51-75: -40% funding, doubled mission rate
- 76-100: -60% funding, urgent missions
- 100+: Country falls, funding ceases, alien base established

**Country Collapse Recovery**:
- Defeat alien base in country
- Liberate 50%+ territory
- Diplomatic restoration mission
- Nation returns with -50 relation, normal panic

---

## Reputation & Social Systems

### Fame, Karma & Reputation System

**System Overview**: Player organization tracked on four independent metrics affecting gameplay, narrative, and mission availability.

#### Karma System (-100 to +100)
- **Definition**: Tracks player moral alignment based on decisions
- **Decay**: Passive decay toward 0 (modder-configurable rate)
- **Effects**:
  - Mission gating: Some missions require karma thresholds
  - Advisor access: Evil advisors require -50+, good advisors require +50+
  - Recruitment: Mercenaries available at any karma; specialized units gated
  - Narrative: Ending affected by cumulative karma (good vs neutral vs evil path)
- **Sources**: Mission outcomes, unit treatment, advisor choices, diplomatic actions
- **Examples**:
  - Save civilian colony: +5 karma
  - Execute captured enemies: -10 karma each
  - Hire black ops director: No karma requirement but +1/month bonus

#### Fame System (0-100)
- **Definition**: How well-known player organization is globally
- **Decay**: Passive decay toward 0 (modder-configurable)
- **Tiers**:
  - Unknown (0-24): Minimal awareness
  - Known (25-59): Recognized by some nations
  - Famous (60-89): World-renowned
  - Legendary (90-100): Maximum recognition
- **Effects**:
  - Mission generation: Famous generates 20-30% additional missions
  - Supplier availability: Tier-locked suppliers (Famous+ for premium)
  - UFO attention: Aliens prioritize famous organizations (+30% interception attempts)
  - Recruitment: High fame attracts quality soldiers (+15% per tier)
  - Funding bonus: +10-50% additional monthly income
- **Sources**: Mission success (+5), failure (-3), UFO destroyed (+2), base raided (-10), research (+3)

#### Reputation System (0-100)
- **Definition**: Legal organizational authority and legitimacy
- **NO DECAY**: Accumulates permanently (+1 per quarter baseline)
- **Progression**: Very slow (max ~400 in 100 years)
- **Effects**:
  - Diplomatic leverage: Higher reputation improves negotiation results
  - Base placement: Countries grant better permissions at high reputation
  - Funding: Government grants affected by reputation (higher = better)
  - Ending: Affects how countries view player organization
- **Sources**: Quarterly accumulation (+1), country protection (+5), legal operations (+5), research sharing (+3)

#### Score System (0-∞)
- **Definition**: Total humanity saved per country
- **NO DECAY**: Permanent accumulation
- **Per-country tracking**: USA Score ≠ China Score
- **Effects**:
  - Ending determination: Total score affects ending cinematics
  - Country gratitude: High-score countries more supportive
  - Narrative impact: Reflects saving humanity success
- **Sources**: Mission success (50+ per mission), country defense (+30-50), civilian saves (+5 per civilian), UFO destruction (+20)

### Advisor System (A9 Comprehensive Spec)

**Definition**: Permanent or temporary staff providing sustained gameplay bonuses and strategic advantages.

**Advisor Hiring Mechanics**:
```
Total Cost = Point Cost (4-20) + (Monthly Salary × Duration)
Monthly Salary: 500-8000 depending on tier
Hiring Timeline: 1 month from expenditure to availability
```

**Advisor Types**:
- **Military Commander**: +10% damage, +20% mission success
- **Director of Intelligence**: +20% spy success, -50% discovery risk
- **Chief Scientist**: +15% research speed, new tech unlocks
- **Financial Officer**: +10% funding, -5% equipment costs
- **Black Ops Director**: +5% karma/month, black market access

**Advisor Conflict Resolution**:
- **No direct conflicts** between advisor specializations
- **Hierarchy override**: Higher-tier advisor's bonus applies if overlap
- **Synergy activation**: Compatible advisors stack bonuses
- **Incompatibility penalty**: Poorly matched advisors reduce both by 5-10%

**Conflict Prevention**:
- Each advisor focuses on distinct domain
- Player manages team composition to avoid conflicts
- System prevents advisor guidance from contradicting

### Power Points System

**Definition**: Player organization's developmental progress (monthly accumulation).

**Acquisition**:
```
Monthly Generation = 1 (base) + Bonuses - Penalties
Special events: +3-5 for major victories, +2 for treaty, +1 for tech
Event losses: -3-5 for catastrophe, -5 for betrayal, -2 for discovery
```

**Strategic Usage**:
- Currency for recruiting advisors (5-15 points each)
- Organization advancement (10-50 points per level)
- Technology unlocks (5-20 points)
- Emergency measures (5-10 points)

**Point Accumulation**:
- Month 1-3: 1 point/month = 3-5 total
- Month 4-6: 1-2 points/month = 8-15 total
- Month 7-12: 2-3 points/month = 20-40 total
- Year 2+: 3-5 points/month = 50-100+

---

## Psychological Systems

### Morale System

#### Definition & Mechanics
- **Morale Pool**: 0 to Bravery stat (example: Bravery 8 = 0-8 morale)
- **Starts**: Full (8/8) at mission start
- **Recovered by**: Inspiring actions, group cohesion, kills

#### Morale Loss Events
- Squad member death nearby: -2 morale
- Friendly suppression: -1 morale per turn
- Taking damage: -1 morale per 10 damage
- Missing shots (3 consecutive): -1 morale
- Seeing alien technology: -1 morale once per mission

#### Morale Gain Events
- Killing alien: +1 morale
- Leader nearby: +0.5 morale per turn
- In cover: +0.5 morale when taking cover
- Squad full strength: +1 morale at battle start

#### Morale Effects on Combat
- 100%+ (Full): Normal, no penalties
- 75-99%: -5% AP cost (motivated)
- 50-74%: -2% AP cost
- 25-49%: -5% accuracy
- 1-24%: -10% accuracy, severe panic threshold

### Panic Mode

#### Definition
Panic occurs when morale reaches 0; unit loses control, becomes liability.

#### Panic Check
- Roll d20 + Bravery modifier vs DC (10 - Bravery)
- Success: Panic avoided, morale stays at 1
- Failure: Unit panics

#### Panic Behaviors
- Cannot move more than 2 hexes
- Cannot attack
- -50% action point recovery next turn
- Escalates over time (turns 1-2 mild, 3+ severe, 5+ breakdown)

#### Ending Panic
- Leader Inspire ability: ends panic, restores 50% morale
- Unit gains kill: +2 morale (may break panic)
- Squad wipe: panic ends

#### Panic Contagion
Units adjacent to panicked unit: -2 morale (fear spreads)

### Sanity System

#### Definition
Long-term psychological stability (0-100), represents cumulative trauma exposure.

#### Sanity Loss
- Per mission: -5 sanity
- Per casualty witnessed: -3 sanity
- Per alien killed: -1 sanity
- Per alien tech exposure: -2 sanity

#### Sanity Recovery
- Per successful mission: +2 sanity
- Per week off-duty: +5 sanity
- Meditation facility: +10 sanity per week
- Promotion: +3 sanity

#### Sanity Effects
- 75-100: No penalties
- 50-74: -5% panic threshold
- 25-49: -15% panic threshold, -2 accuracy
- 1-24: Cannot be deployed (breakdown)
- 0: Unit discharged (unfit)

### Bravery Stat

#### Definition
Permanent personality stat representing innate courage (range 6-12, average 9).

#### Bravery Effects
- Morale cap: Bravery = max morale points
- Panic threshold: Bravery × 10 DC
- Leader aura: (Bravery - 9) morale per turn nearby units
- Leadership bonus (Bravery 11+): Sergeant +1, Captain +2, Commander +3 morale

### Health & Physical Status

#### Health Pool
- Base: 100 HP (unit type dependent)
- Varies: Scout (85), Tank (120)
- Armor modifies: +10-30 HP depending on armor

#### Damage States
- HP 1-100: Fully functional
- HP 1-25: Bleeding status
- HP 0: Incapacitated
- HP < -25: Dead (cannot revive)

#### Incapacitation & Extraction
- HP reaches 0: Unit collapses, bleeding
- Medical attention stops bleeding, keeps unconscious
- Revival: +1 HP, takes 1 action
- Extraction: Can extract incapacitated units for recovery

### Stun System

#### Stun Pool
- Capacity: 20 stun points (varies by unit: scouts 15, tanks 25)
- Separate from health (stun alone doesn't kill)
- Represents dizziness, disorientation, knockback

#### Stun Gain
- Stun weapons: +5-15 stun per hit
- Explosions: +3 stun per 10m radius
- Impact: +1 stun per 10m fall

#### Stun Effects
- 1-10: -10% accuracy (dizzy)
- 11-20: Cannot move (stunned)
- 21+: Knocked down (prone, -1 turn to stand)

#### Stun Recovery
- -5 stun per turn inactive
- -2 stun per turn while acting
- Stimulant: -10 stun instantly
- Medical attention: -5 stun instantly

### Wounds System

#### Wound Categories
- **Light**: 1 week recovery
- **Moderate**: 2 weeks recovery
- **Severe**: 4 weeks recovery
- **Critical**: 8 weeks recovery

#### Wound Generation
- 50-75 damage: 1 Light
- 76-100 damage: 1 Moderate
- 101+ damage: 1 Severe
- Multiple stack: 3 Light = 1 Moderate

#### Wound Effects
- 1-2 wounds: -1 AP per turn
- 3-4 wounds: -2 AP, -5% accuracy
- 5+ wounds: Cannot deploy

#### Wound Recovery Options
- Hospital: -50% recovery time
- Medic specialist: -2 weeks per wound
- Stimulants: -1 week per wound (risky)
- Cybernetics: Convert wound to equipment (+1 stat)

---

## Progression & Advancement

### Experience System (Integrated with Units Section)
- See Unit Management section for full XP acquisition, rank, and specialization mechanics

### Achievement & Medal System
- **Medals**: One-time achievements providing 25-200 XP bonus
- **Types**: Survivor (20 battles), Destroyer (100 kills), Sharpshooter (50 headshots), Guardian (200 damage taken), Hero (solo objective), Legendary (campaign without casualty)

### Technology Research Tree
- **5 Branches**: Weapons, Armor, Alien Tech, Facilities, Support
- **Prerequisites**: Advanced tech requires prior research
- **Time & Cost**: Multiple months, significant credits
- **Unlocks**: New equipment, unit types, facilities, abilities

### Facility & Base Expansion
- **Construction**: New facilities added to base grid
- **Upgrades**: Facilities can be upgraded for increased capacity/capability
- **Cost Scaling**: Higher-tier facilities cost more
- **Research Gates**: Some facilities require tech research

### AI & Learning Systems

**Adaptive AI Difficulty**:
- **Adjusts tactical complexity** based on player performance
- **Modifies resource allocation** for enemies (fewer units, less equipment at low difficulty)
- **Adapts ability usage** (frequent ability spam vs. strategic positioning at higher difficulty)
- **Includes "tells"** in tactics allowing player prediction at high difficulty
- **Learning disabled** against specific player units once countered successfully

**Advanced Alien Tactics**:
- **Retreat behaviors**: Group retreat patterns, fortified defensive positions
- **Flanking patterns**: Multi-unit coordinated attacks on player formations
- **Focus fire**: Target priority shifts based on threat assessment
- **Ability sequencing**: Aliens chain abilities in tactical sequences
- **Squad formations**: Defensive perimeters, aggressive wedges, ambush patterns

**Human Faction Tactics**:
- **Mercenary tactics**: Aggressive but resource-limited
- **Military tactics**: Coordinated, well-disciplined, defensive
- **Cult tactics**: Suicidal charges, unpredictable behavior, morale immunity

### Dynamic Economic Systems

**Market-Based Pricing**:
- **Base prices** for items, facilities, research
- **Supply/demand fluctuations** (+/- 20% monthly)
- **Rarity multipliers** for hard-to-obtain materials
- **Bulk discounts** for manufacturing operations
- **Seasonal variations** affect certain goods

**Resource Allocation Mechanics**:
- **Priority queue system** for manufacturing (can reorder)
- **Overflow handling** when storage is full
- **Waste penalties** for destroyed resources
- **Batch bonuses** for manufacturing 5+ of identical item
- **Efficiency curves** manufacturing gets faster with more facilities

**Economic Stress States**:
- **Normal**: Standard operations, all functions available
- **Tight budget**: Can't start new projects, maintenance only
- **Financial crisis**: Equipment degradation, staff morale -1/month
- **Bankruptcy threshold**: Automatic loss condition when breached

### Specialization System (see Unit Management - Promotion Trees)

### Faction & Campaign AI

**Faction Autonomy**:
- Each alien faction maintains independent strategic goals (attack strategies, base building, diplomacy, resource management)
- **Escalation Meter**: Campaign points track faction pressure (+1 per attack, -2 per player victory)
- **Escalation Thresholds**: 0-10 pts (early), 10-25 pts (mid), 25-50 pts (late), 50+ pts (UFO armada crisis)
- **Tactical Adaptation**: Aliens deploy units designed to counter player composition

**Country & Supplier AI**:
- **Country Funding**: Responsive to player performance (bonus on 3+ win streak, -30% on losses)
- **Supplier Behavior**: Inventory/pricing scales with relationship level (-50% stock if hostile, +50% if allied)
- **Territory Claims**: Undefended provinces lost to factions during alien attacks
- **Supplier Betrayal**: Can block critical items for 2 weeks if hostility threshold breached

**Mission Generation**:
- Procedurally generated missions based on faction state and escalation meter
- **Difficulty scaling**: BASE + (MONTH × 0.2) + (PLAYER_BASE_COUNT × 0.15) + (PLAYER_AVG_LEVEL × 0.1)
- **Mission types**: UFO Crash, UFO Interception, Alien Base Attack, Colony Defense, Research Facility, Supply Raid

### Unit Confidence & Behavioral Psychology

**Unit Confidence System** (0-100%):
- **Base**: 60% starting confidence
- **Decay**: -5% per friendly casualty, -3% per suppression, -2% per turn
- **Gain**: +3% per hit, +5% per kill, +2% per objective completed
- **Behavioral Effects**:
  - 0-20%: Terrified (retreat/surrender, -30% accuracy)
  - 21-40%: Frightened (defensive, seek cover, -15% accuracy)
  - 41-60%: Normal (balanced tactics)
  - 61-80%: Aggressive (advance, close distance, +10% accuracy)
  - 81-100%: Dominant (frontal assault, +20% accuracy)

**Squad Formations**:
- **Line**: Spread horizontally, high firepower, flanking exposure
- **Column**: Single file, medium firepower, corridor movement
- **Wedge**: Triangle apex, balanced approach
- **Cluster**: Tight group, low firepower, high area vulnerability
- **Dispersed**: Maximum spread, low firepower, coordination difficulty

**Action Point System**:
- **Base AP**: 4 per turn
- **Modifiers**: Health (-2 if <25%), Morale (-2 if panicked), Sanity (-1 if traumatized), Stun (-2)
- **Range**: 1-5 AP per turn (minimum action guaranteed, maximum with bonuses)

### Black Market & Underground Economy

**Access Requirements**:
- Karma below +40 (cannot be "too good")
- Fame above 25 (known enough to find contacts)
- Special mission discovery or event
- 10,000 credit entry fee (one-time)

**Access Tiers**:
- **Restricted** (Karma +40 to +10): Items only
- **Standard** (Karma +9 to -39): Items, units, some services
- **Enhanced** (Karma -40 to -74): All except extreme services
- **Complete** (Karma -75 to -100): Everything including assassination

**Black Market Categories**:
- **Experimental Items**: 200-500% markup, -5 to -20 karma per purchase
- **Restricted Units**: Mercenaries, outcasts, defectors
- **Illegal Missions**: High-risk, high-reward objectives (-10 to -30 karma)
- **Corpse Trading**: Buy/sell fallen units/aliens (varies by karma)
- **Event Purchasing**: Trigger diplomatic incidents or strategic events

---

## Environmental Systems

### Terrain System

**Terrain Categories & Mechanics**:

| Terrain Type | Movement Cost | Cover | Blocks LOS | Special |
|---|---|---|---|---|
| **Floor** | 1 AP | 0% | No | Standard walkable |
| **Wall** | Impassable | 100% | Yes | Complete obstruction |
| **Water** | 2-3 AP | 0-40% | No | Movement penalty, extinguishes fire |
| **Difficult** | 2-3 AP | 0-20% | No | Rubble, forest, swamp |
| **Cover** | 1-2 AP | 40-80% | Partial | Low walls, sandbags, destructible |

**Material Properties**:
- **Wood**: 10-20 HP, burns easily, low resistance
- **Stone**: 50-100 HP, fire-resistant, high resistance
- **Metal**: 30-60 HP, fire-resistant, medium resistance
- **Glass**: 3-8 HP, shatters easily, very low resistance
- **Concrete**: 60-120 HP, fire-resistant, very high resistance
- **Vegetation**: 5-15 HP, burns easily, very low resistance

### Environmental Hazards

#### Smoke System
- **Duration**: 3-8 turns (disperses gradually)
- **Spread**: Expands to adjacent tiles each turn (20% chance per tile)
- **Effects**:
  - Light intensity: +2 sight cost, -10% accuracy, +0 movement cost
  - Medium intensity: +3 sight cost, -20% accuracy, +1 movement cost, +1 stun/turn
  - Heavy intensity: +4 sight cost, -30% accuracy, +1 movement cost, +1 stun/turn
- **Generation**: Smoke grenades (5 turns), fire (continuous), explosions (2-3 turns)
- **Tactical Use**: Concealment, denial, screening

#### Fire System
- **Duration**: 4-10 turns (self-extinguishes)
- **Spread**: Expands to adjacent flammable tiles (30% chance/turn)
- **Intensity**: Small fire (1 damage/turn) or Large fire (2 damage/turn)
- **Effects**:
  - Damage: 1-2 HP per turn
  - Morale: -1-2 per turn
  - Movement: +2-3 AP movement cost
  - Cover destruction: Burns wooden cover
- **Fuel Requirements**: Requires flammable material (wood, vegetation)
- **Extinguishing**: Water immediately extinguishes; spray actions possible
- **Tactical Use**: Area denial, flushing enemies, destruction

#### Gas System (Toxic Clouds)
- **Types**:
  - Poison Gas: 2 HP/turn (ignores armor)
  - Nerve Gas: 1 HP/turn, -1 morale/turn, -2 morale/turn, -1 sanity/turn
  - Acid Gas: 3 HP/turn (damages equipment)
  - Stun Gas: 0 HP, -3 morale/turn, stun effect after 3 turns
- **Duration**: 5-12 turns (disperses slowly)
- **Spread**: Minimal (stays in place with slight drift)
- **Generation**: Gas grenades, alien weapons, environmental ruptures
- **Tactical Use**: Bypass armor, demoralize, clear buildings

#### Electrical Hazards
- **Duration**: Permanent (until destroyed) or 3-5 turns (temporary)
- **Spread**: Conductive through metal/water
- **Damage**: 2-4 HP per turn in contact
- **Stun**: High chance (50%) of stun effect
- **Equipment Damage**: May damage electronic equipment
- **Generation**: Destroyed electronics, exposed wiring, electrical weapons

#### Radiation
- **Duration**: 20-50 turns or permanent
- **Visibility**: Invisible (requires detection equipment)
- **Damage**: 1 HP per turn (gradual)
- **Sanity Loss**: -1 per 3 turns
- **Long-term**: Continued damage after mission (medical treatment needed)
- **Generation**: Alien technology, nuclear facilities, weapon detonations

### Weather System

**Weather Types & Effects**:

| Weather | Sight Penalty | Accuracy Penalty | Movement Penalty | Special |
|---|---|---|---|---|
| **Clear** | +0 | +0% | +0 AP | Baseline |
| **Rain** | +1/tile | -5% | +1 AP | Extinguishes fire, creates mud |
| **Heavy Rain** | +2/tile | -10% | +1 AP | Strong fire suppression |
| **Snow** | +2/tile | -10% | +2 AP | Cold damage (-1 HP/5 turns), footprint trails |
| **Blizzard** | +3/tile | -15% | +3 AP | Severe visibility, morale -1/10 turns, sanity -1/10 turns |
| **Sandstorm** | +2/tile | -5% | +2 AP | Equipment damage, accuracy loss |
| **Heavy Fog** | +3/tile | -5% | +1 AP | Near-total visibility loss |
| **Thunderstorm** | +1/tile | -10% | +1 AP | Random lightning strikes (variable damage) |

**Weather Mechanics**:
- Weather conditions affect entire battlefield uniformly
- Weather is optional and scales difficulty dynamically
- Special environmental interactions (mud in rain, footprints in snow)
- Weather can persevere entire mission or change mid-mission

### Environmental Integration with Other Systems

- **Terrain destruction**: Explosions destroy walls, creating new sightlines
- **Fire spread**: Vegetation burns automatically, spreads tactically
- **Mood impact**: Environmental hazards affect unit morale negatively
- **Strategic depth**: Environment is tactical element, not cosmetic
- **Mission generation**: Terrain type varies with mission type and location

### Day & Night Conditions

**Lighting Mechanics**:
- **Day**: +0 sight cost (baseline), standard accuracy
- **Dusk/Dawn**: +1 sight cost, -5% accuracy
- **Night**: +3 sight cost, -15% accuracy unless using night vision
- **Artificial Light**: Base lights provide +5 hex radius illumination

**Unit Adaptation**:
- Night vision equipment: +2 hex sight range at night
- Thermal vision: Ignore lighting penalties
- Flashlights/Flares: +3 hex radius portable light

### Biome System

**Biome Types & Effects**:
- **Urban**: Standard movement, high cover, building destruction
- **Forest**: +1 movement cost, dense cover, fire vulnerability
- **Desert**: Standard movement, low cover, sandstorm weather, heat effects
- **Mountains**: +2 movement cost, excellent cover, avalanche hazards
- **Arctic**: Standard movement, cold damage, ice fragility, thermal preservation
- **Underwater**: Special submarine/aquatic rules, pressure mechanics
- **Volcanic**: +2 durability loss on equipment, heat hazards, lava flows
- **Wasteland**: Radiation hazards, low resources, ghost settlements

---

## Equipment & Item Systems

### Equipment Class Synergy

**Class Matching Bonuses**:
- **Light + Light Weapon**: +10% accuracy, +15% movement speed, -5% armor
- **Medium + Medium**: 0% modifier (balanced baseline)
- **Heavy + Heavy**: -10% accuracy, -15% movement, +20% armor effectiveness
- **Specialized + Specialized**: +10% special ability effectiveness (varies by type)

**Class Mismatch Penalties**:
- **Light Armor + Heavy Weapon**: -15% accuracy, -15% armor
- **Heavy Armor + Light Weapon**: -5% accuracy, -20 AP movement cost
- **Medium + Mismatched**: -7% accuracy, normal movement/armor

**Armor Effectiveness Formula**:
```
Final Armor = Base Armor × (1 + (Class - 1) × 0.25) × Synergy Modifier
```

### Item Durability System

**Degradation Mechanics**:
- Items lose durability through use and damage
- Each mission causes -5% durability (terrain-dependent)
- Armor loses durability only when hit, not per mission
- Weapon usage: -2% durability per 5 shots

**Durability States**:
- **Pristine** (100-76%): No penalties, can receive modifications
- **Worn** (75-51%): Minor penalties, can receive modifications
- **Damaged** (50-26%): -5% effectiveness, cannot install mods
- **Critical** (25-1%): -10% effectiveness, failure risk, cannot install mods
- **Destroyed** (0%): Item permanently lost, unusable

**Repair System**:
- Base repair: +10% durability per week (passive, in storage)
- Workshop facility: Reduces repair time by 20%
- Advanced Hangar: Reduces repair time by 50%
- Emergency repair: 50% cost premium, instant fix
- **Cost**: Scales with item value (expensive items cost more to maintain)

**Environmental Durability Impact**:
- Volcanic terrain: +2% durability loss per mission
- Underwater: +1% durability loss per mission
- Arctic: 0% additional loss (cold preserves)

### Item Modification System

**Modification Slots** (Per Item):
- **Weapons**: 2 modification slots available
- **Armor**: 1 modification slot available
- **Utility/Tools**: 1 modification slot available
- **Consumables**: 0 slots (grenades, medkits cannot be modified)

**Weapon Modifications**:
- **Scope**: +15% accuracy, +1 sight range
- **Laser Sight**: +10% accuracy (close range only)
- **Extended Magazine**: +50% ammo capacity
- **Armor-Piercing Rounds**: +20% damage vs armored targets
- **Silencer**: Silent shots, no detection radius
- **Rapid-Fire Module**: +1 extra burst shot

**Armor Modifications**:
- **Ceramic Plating**: +5 armor value, -2% movement
- **Lightweight Alloy**: -10% movement penalty
- **Reactive Plating**: +40% explosive resistance
- **Camouflage Overlay**: +15% stealth effectiveness
- **Thermal Lining**: +100% heat/cold resistance

**Modification Restrictions**:
- Scope ↔ Laser Sight: Mutually exclusive
- Silencer ↔ Rapid-Fire: Mutually exclusive
- Cannot install on Damaged/Critical/Destroyed items
- Installation damage: -5 durability during mod installation

---

## Research & Manufacturing Systems

### Research Projects

**Core Mechanics**:
- Progress based on scientist allocation (man-days to completion)
- Multiple research tracks can run simultaneously
- Progress retained on cancellation (50-75% credit return)
- Research cannot fail (can only be cancelled)

**Research Types**:
- **Technology**: Unlocks new capabilities and manufacturing
- **Item Analysis**: Reverse-engineer equipment (+20% understanding)
- **Alien Interrogation**: Extract intelligence from prisoners
- **Autopsy**: Study alien biology (unlock new unit types)
- **Facility Upgrade**: Improve base facilities (+10-30% efficiency)
- **Hybrid Research**: Combine multiple streams for discoveries

**Cost Scaling**:
- Base cost: 50-500 man-days (varies by project)
- Complexity multiplier: 50%-150% (set at campaign start)
- Prerequisite blocking: Cannot start until dependencies complete
- Facility bonuses: -10-30% research time with advanced facilities
- Scientist specialization: +10% efficiency per related completed research

**Scientist Allocation**:
- Early game: 2-5 scientists (bottleneck forcing prioritization)
- Mid game: 5-10 scientists (broader research possible)
- Late game: 15+ scientists (rapid advancement)
- Efficiency scaling: 5th scientist = 80% efficiency, 10th = 60% (diminishing returns)

### Manufacturing System

**Manufacturing Projects**:
- Convert resources → equipment at base facilities
- Multiple manufacturing tracks simultaneous
- Progress tracked as percentage to completion
- Cancellation returns 50% invested credits

**Manufacturing Mechanics**:
- **Workshop**: Standard manufacturing facility
- **Advanced Workshop**: -20% manufacturing time
- **Master Manufacturing**: -40% manufacturing time
- **Batch Production**: 5+ identical items give +20% production speed bonus

**Manufacturing vs. Marketplace**:
- Manufacturing: Slower but cheaper (50-70% of marketplace price)
- Marketplace: Faster delivery but expensive (100-150% base price)
- Strategic choice: Early manufacture vs. rapid market purchase

### Research Technology Tree

**5 Major Branches**:
- **Weapons**: Firearms, explosives, energy weapons, alien tech
- **Armor**: Protective equipment, specialized suits, upgrades
- **Alien Technology**: Reverse-engineered alien systems
- **Facilities**: Base improvements, production upgrades
- **Support**: Medical, logistics, quality-of-life improvements

**Prerequisites & Dependencies**:
- Linear progression: Basic research before advanced
- Cross-branch dependencies: Some alien tech requires weapons knowledge
- Dead-end branches: Some techs open unique paths only
- Mandatory gates: Key technologies block campaign progression (tutorial pacing)

---

## Crafts & Pilot System

### Craft Classification

**Craft Classes by Role**:
- **Scout**: 100-150 HP, 4 hexes/turn, fast, fragile
- **Interceptor**: 140 HP, 3-4 hexes/turn, combat-optimized
- **Transport**: 240 HP, 1-2 hexes/turn, slow but high capacity
- **Fighter**: 280 HP, 3 hexes/turn, balanced
- **Heavy Fighter**: 380 HP, 2-3 hexes/turn, slower, powerful
- **Bomber**: 420 HP, 2 hexes/turn, deliberate strikes
- **Battleship**: 550 HP, 1 hex/turn, durable, crew-based

### Craft Storage & Capacity

**Storage Facilities**:
- **Garage**: 1 craft slot
- **Hangar** (2×2): 4 craft slots
- **Capacity Overflow**: Crafts without storage space cannot be deployed

**Unit Transport**:
- Small scout craft: 4-8 unit slots
- Medium transport: 8-12 unit slots
- Large heavy craft: 12-20 unit slots

### Craft Weapons & Addons

**Weapon Configuration**:
- Exactly **2 weapon hardpoints** per craft
- Heavy weapons consume both slots
- Configuration changes in base take 1 week

**Addon Slots** (2 available):
- **Defensive**: Shield Generator (+10 HP/turn shield), Metal Armor (+20 HP), Stealth Plating (+2 cover)
- **Mobility**: Afterburner (+1 movement), Fuel Tank (+1,000 km range)
- **Detection**: Radar Booster (+2 power, +500 km range)
- **Utility**: Crew Cabin (+2 unit slots), Cargo Bay (+20 capacity), Repair Kit (+10 HP/turn stationary)
- **Rare**: Teleport Device (enables teleportation)

### Pilot System Integration

**Core Principle**: Pilots ARE units that can be assigned to crafts or deployed to battlescape.

**Pilot XP** (Separate from Ground Combat XP):
- **Mission Participation**: +10 Pilot XP
- **Kill Enemy Craft**: +50 Pilot XP
- **Assist in Kill**: +25 Pilot XP
- **Survive Interception**: +10 Pilot XP
- **Victory (force retreat)**: +30 Pilot XP
- **Perfect Victory (no damage)**: +50 Pilot XP

**XP Distribution by Position**:
- **Pilot**: 100% XP allocation
- **Co-Pilot**: 50% XP allocation
- **Crew**: 25% XP allocation

**Dual XP Tracking**:
- Each unit tracks **Ground Combat XP** (battlescape missions)
- Each unit tracks **Pilot XP** (interception missions)
- Independent progression paths (can be Rank 3 Marksman + Rank 2 Fighter Pilot)
- Strategic flexibility: Pilot-only specialists or jack-of-all-trades

### Crew Requirements

**Pilot Assignment**:
- Each craft requires minimum crew based on size
- Small craft: 1 Pilot minimum
- Medium craft: 1 Pilot + 1 Co-Pilot option
- Large craft: 1 Pilot + 1-2 Co-Pilots
- Cannot launch if below minimum crew

### Craft Maintenance & Repair

**Passive Repair** (In Base):
- Craft at rest: +10% max HP per week (10 weeks for full repair)
- **Hangar Upgrade**: +20%/week repair rate (costs 5,000 credits)
- **Master Facility**: +30%/week repair rate (costs 15,000 credits)

**Monthly Maintenance Cost**:
- Small Scout: 100 credits/month
- Interceptor: 200 credits/month
- Heavy Fighter: 300 credits/month
- Battleship: 500+ credits/month
- Damaged craft: +50% cost until repaired
- Per addon: +25 credits/month per addon

### Fuel Management

**Consumption Mechanics**:
- Automatic consumption based on distance, craft size, cargo weight
- Crafts cannot move without sufficient fuel
- Fuel consumption formula: 1 + (fuel_per_hex × distance × cargo_modifier)

**Emergency Landing**:
- Craft with 0 fuel enters stranded status
- Requires rescue mission to recover

### Craft Crashes & Rescue Missions

**Crash Triggers**:
- Craft reaches 0 HP during Interception combat
- Crash location generated on Geoscape
- Trigger automatic rescue mission generation

**Salvage Recovery**:
- Separate salvage teams (not craft-based) recover battlefield items
- Player chooses items to recover
- Transportation cost based on distance, item weight, risk level

---

## Interception System (Craft vs UFO Combat)

### System Overview

**Definition**: Mid-level tactical engagement between player craft/bases and enemy UFOs/bases. Bridges Geoscape (strategic) and Battlescape (tactical squad) layers.

**Combat Model**: Card-game-like system with hero-level craft and base defenses engaging enemy objectives.

**Three-Dimensional Engagement Space**:
- **Air Sector (Upper)**: Aircraft, orbital platforms, flying craft, space-based weapons
- **Land/Water Sector (Middle)**: Ground installations, submarines, coastal defenses
- **Underground Sector (Lower)**: Underground bases, subterranean installations, bunkers

**Sector Capacity**: Max 4 objects per sector; sectors independent but visible simultaneously.

### Weapon Systems

**Weapon Categories**:
- **Air-to-Air**: Enemy aircraft/UFOs (direct aerial combat)
- **Air-to-Land**: Ground installations (bombing)
- **Water-to-Water**: Naval targets/submarines
- **Air-to-Underwater**: Submerged targets (anti-submarine)
- **Land-to-Air**: Aircraft/orbital defense
- **Land-to-Water**: Naval/submarine defense

**Base Weapon Properties**:

| Weapon Type | Accuracy | Damage | Range (Turns) | Cooldown | Cost |
|---|---|---|---|---|---|
| **Point Defense Turret** | 85% | 15-25 | 5 turns | 1 turn | 5 AP + 5 EP |
| **Main Cannon** | 75% | 40-60 | 5 turns | 1 turn | 3 AP + 10 EP |
| **Missile Pod** | 80% | 50-80 | 1 turn | 3 turns | 4 AP + 15 EP |
| **Laser Array** | 70% | 60-90 | Instant | None | 3 AP + 20 EP/turn |
| **Plasma Caster** | 65% | 70-120 | 1 turn | 2 turns | 4 AP + 25 EP |
| **Torpedo** | 75% | 60-100 | Variable | 2 turns | 4 AP + 20 EP |

**Craft Support Systems**:
- Energy Shield: +10 health, +20 energy, +5 regen/turn
- Ablative Armor: -50% explosive damage, degrades 10% per hit
- Reactive Plating: Explosive +40%, Kinetic +20% resistance
- Afterburner: +1 speed, higher fuel consumption
- Enhanced Radar: +100% detection range
- Cargo Pod: +10 capacity

### Interception Combat Formula

**Hit Chance Calculation**:
```
Final Hit Chance = Base Accuracy - Distance Penalty - Target Evasion + Modifiers
Clamped to 5%-95%

Distance Penalty = (Current Range - Optimal Range) × 2% per hex
Evasion Options:
  - Light Evasion: -10% accuracy, 5 AP + 5 EP
  - Full Evasion: -20% accuracy, 1 AP + 15 EP
  - Emergency Dodge: -30% accuracy, 2 AP + 25 EP
```

**Damage Calculation**:
```
Final Damage = Base Damage × (1 ± Variance)
Variance: ±5-10% (weapon-dependent)
NO CRITICAL HITS in interception
NO ARMOR REDUCTION (intentional design simplification)
```

**Range & Flight Time**:
- Close: 5 turns to impact (point-blank)
- Short: 4 turns to impact
- Medium: 3 turns (standard range)
- Long: 2 turns (extended range)
- Very Long: 1 turn (nearly instant strikes)

### Thermal/Heat System

**Heat Generation**:
- Single shot: +5 heat
- Burst fire: +15 heat
- Sustained beam: +3 per turn
- Overcharge shot: +20 heat
- Weapon jam: Already jammed, cannot fire

**Heat Dissipation**:
- Bases: -15 heat/turn (fast cooling)
- Large craft: -10 heat/turn
- Small craft: -5 heat/turn
- Environmental: ±5 heat (ocean -5, desert +5)

### Sector Mechanics

**Sector Composition**:
- **Air Sector**: Aircraft, UFOs, orbital platforms (max 4 objects)
- **Land/Water Sector**: Ground bases, submarines, coastal defense (max 4 objects)
- **Underground Sector**: Bunkers, deep installations (max 4 objects)
- Objects can mix types within sectors

**Formation Positioning**:
- Player forces on left side of engagement screen
- Enemy forces on right side
- Sectors visible simultaneously
- Cross-sector targeting available with appropriate weapons

**Cross-Sector Combat**:
- Weapons determine valid target sectors
- Loadout diversity creates tactical decisions
- Wrong equipment = no engagement capability
- Players must anticipate enemy positioning

### Interception Action Points & Energy

**Action Points** (per craft per turn):
- Small craft: 4 AP
- Medium craft: 2-3 AP
- Large craft: 2-3 AP (+ crew ability bonus)

**Energy Points** (per craft):
- Small craft: 50-100 EP total
- Medium craft: 100-200 EP total
- Large craft: 200-400 EP total
- Regeneration: +2-5 EP/turn depending on systems

**Energy Costs**:
- Standard weapon: 5-15 EP
- Heavy weapon: 20-40 EP
- Evasion: 5-25 EP depending on level
- Shield: 10+ EP/turn while active

**Heat Threshold Effects**:
- 0-50 heat: No penalty
- 51-100 heat: -10% accuracy on next shot
- 101+ heat: Weapon JAMMED until heat drops below 50

---

## Traits & Specialization System

### Trait Architecture

**Trait Definition**: Permanent character modifiers defining unit specialization and creating combat diversity.

**What Traits Modify**:
- Base stats (Marksmanship, Melee, Reaction, Speed, Bravery, Sanity, Strength)
- Combat mechanics (accuracy, damage, special actions)
- Unit abilities (unlock special actions, passive effects)
- Recovery rates (HP, morale, sanity regeneration)
- Equipment interactions (carry capacity, reload speed)

**What Traits Don't Modify**:
- Base health pool (affected by equipment/ranks)
- Unit class (permanent)
- Rank progression (earned through XP)
- Base attributes (modified by training)

### Trait Acquisition Methods

#### Birth Traits (Recruitment)
- **Rarity**: 30% positive, 20% negative, 50% empty
- **Quantity**: 1-3 traits per recruited unit
- **Fixed at recruitment**: Cannot change later

#### Achievement Traits (In-Game Unlocks)
- **Trigger**: Specific milestone or achievement
- **Examples**:
  - 50 kills → Ambidextrous
  - Sergeant rank → Leader
  - 20 heals → Medic Training
  - 50 combat rounds → Unshakeable
  - 10 successful missions → Mentor

#### Perk Traits (Specialization Selection)
- **Availability**: After Rank 2+ (promoted units)
- **Selection**: Player chooses during promotion
- **Limitation**: 1 perk per 2 ranks (Rank 2 = 1 perk, Rank 4 = 2 perks)
- **Permanence**: Once selected, cannot change

### Trait Categories & Examples

**Combat Traits**:
- Positive: Quick Reflexes (+2 Reaction), Sharp Aim (+1 Accuracy, +5% hit), Ambidextrous (dual wield)
- Negative: Slow Reflexes (-1 Reaction), Poor Aim (-1 Accuracy, -5% hit), Gun Shy (-2 accuracy on first shot)

**Physical Traits**:
- Positive: Strong (+2 STR, +4 capacity), Fast (+1 SPD, +1 hex), Enduring (+10% HP)
- Negative: Weak (-1 STR, -2 capacity), Slow (-1 SPD, -1 hex), Frail (-10% HP)

**Mental Traits**:
- Positive: Iron Will (+2 Bravery, +25% morale loss resistance), Unshakeable (panic ≤50% AP)
- Negative: Cowardly (-2 Bravery, +25% morale loss), Paranoid (-1 morale from leader aura)

**Support Traits**:
- Positive: Leader (nearby allies +1 morale/turn), Mentor (+1 XP when nearby), Inspiring (+5% accuracy within 6 hexes)
- Negative: Loner (-2 morale from leader), Jinxed (-5% critical chance)

### Trait Synergies & Conflicts

**Conflict Rules** (Mutually exclusive):
- Quick Reflexes ↔ Slow Reflexes
- Sharp Aim ↔ Poor Aim
- Strong ↔ Weak
- Fast ↔ Slow
- Iron Will ↔ Cowardly
- Leader ↔ Loner ↔ Abrasive

**Synergy Bonuses** (Extra benefits):
- Sharp Aim + Marksman: +25% accuracy bonus
- Strong + Resilient: +1 extra armor
- Fast + Athletic: Movement cost -2 instead of -1
- Iron Will + Unshakeable: Panic minimum 75% AP
- Leader + Inspiring: Aura radius +3 hexes, +2 morale

### Trait Balance System

**Balance Point Cost**:
- Positive traits: +1 to +3 points
- Negative traits: -1 to -3 points
- Unit balance budget: ±3 points (prevents overpowering combinations)

**Balance Example**:
- Sharp Aim (+2) + Strong (+2) = +4 points (VIOLATES budget)
- Sharp Aim (+2) + Steady Hand (+1) = +3 points (valid, at limit)
- Iron Will (+2) + Poor Aim (-2) = +0 points (balanced)

### Trait Caps & Special Rules

**Maximum Traits Per Unit**: 4 (rare, for veteran units)
**Typical Distribution**: 1-2 traits per unit
**Trait Inheritance**: Never passed between generations (except clones)
**When Promoting**: Keep all existing traits, can add 1 perk
**Trait Loss**: Traits never permanently lost (except unit death)

---

## Campaign Progression System

### Phase Structure

**Phase 1: Early Game (Months 1-3) - "Education"**
- Player learns Geoscape, Basescape, Battlescape layers
- 2-3 starting units, 1 base, 1 craft
- Starting capital: 500K (Normal), 250K (Hard), 1M (Easy)
- Mission types: Basic interception, terror defense, recovery
- Success criterion: Understand core mechanics

**Phase 2: Mid Game (Months 4-8) - "Expansion"**
- Multi-base management (2-3 bases)
- Unit roster grows (25-35 units)
- Advanced facility research progressing
- Mission complexity increases (6-8 per month)
- Economy reaches breakeven or surplus

**Phase 3: Late Game (Months 9-14) - "Confrontation"**
- Global coverage (4-5 bases)
- Veteran roster (50-60 units)
- Alien threat 60-70%
- Alien base assaults possible (player can attack)
- Mothership sightings begin

**Phase 4: Endgame (Months 15+) - "Finale"**
- Mothership arrival imminent (Month 15-18 typical)
- Alien threat 80-100%
- Final mission arcs available
- Multiple ending pathways based on karma/performance
- Campaign concludes with victory/defeat condition

### Loss Conditions

**Loss Condition 1: Organization Destruction**
- All bases destroyed
- 0 units remaining
- 0 crafts operational
- Immediate game over

**Loss Condition 2: Economic Collapse**
- 3 consecutive months with -500K+ deficit
- Cannot pay unit salaries/maintenance
- Countries withdraw funding due to panic
- Cannot recover

**Loss Condition 3: Complete Funding Loss**
- All countries collapse (panic 100+)
- Black market access revoked (karma too high/fame too low)
- 0 monthly income
- Cannot sustain operations

### Ending Types

**Good Endings** (Victory with high score/karma):
- Aliens defeated, humanity saved
- Countries united and grateful
- Organization becomes legend

**Neutral Endings** (Victory with balanced metrics):
- Aliens contained but not defeated
- Humanity survives but scarred
- Organization considered necessary evil

**Bad Endings** (Survival without victory):
- Alien coexistence: Humans and aliens share Earth
- Pyrrhic victory: Win but at massive cost
- Defeat by default: Aliens leave but only due to unrelated factors

---

## 2B. INTERCEPTION (Mid-Tactical Combat Layer)

**Location**: `engine/interception/`, `gui/scenes/interception_screen.lua`

### Purpose
Interception bridges Geoscape strategic decisions and Battlescape tactical combat. It represents mid-level military engagements between player craft/bases and enemy forces (UFOs, enemy bases). The system emphasizes resource commitment, positioning, and weapon selection over individual unit tactics.

### Strategic Environment

**Three-Dimensional Engagement Space**
- **Air Sector (Upper)**: Aircraft, orbital platforms, flying craft, space-based weapons
- **Land/Water Sector (Middle)**: Ground installations, submarines, coastal defenses, land-based craft
- **Underground Sector (Lower)**: Underground bases, subterranean installations, deep bunkers
- Each sector holds maximum 4 combat objects
- Sectors are independent but visible simultaneously
- Player forces occupy left side, enemies on right side

### Weapon Systems

**Weapon Type Interactions**
| Type | Target | Effect |
|------|--------|--------|
| **Air-to-Air** | Aircraft/UFOs | Direct aerial combat |
| **Air-to-Land** | Ground bases | Bombing/strike capability |
| **Water-to-Water** | Naval targets | Underwater warfare |
| **Air-to-Underwater** | Submerged targets | Anti-submarine |
| **Land-to-Air** | Aircraft/orbital | Base AA defense |
| **Land-to-Water** | Naval/submarines | Coastal defense |

**Weapon Mechanics**
- **Chance to Hit**: Accuracy rating affected by range, positioning, evasion
- **Range (Turns to Impact)**: Close (5), Short (4), Medium (3), Long (2), Very Long (1)
- **Cooldown**: Separate from range; governs firing frequency
- **Action Point Cost**: 1-4 AP depending on weapon type
- **Energy Point Cost**: 5-40 EP per shot depending on weapon
- **Damage Value**: Base damage ±5-10% variance (no armor reduction)

### Combat Formulas

**Hit Chance Calculation**
```
Final Hit Chance = Base Accuracy - Distance Penalty - Target Evasion + Modifiers
Clamped to 5%-95% (no guaranteed hits or misses)
```

**Accuracy Components**:
- **Base Accuracy**: Weapon type baseline (65-85% typical)
- **Range Modifier**: -2% per hex beyond optimal range
- **Cover Modifier**: -5% to -30% depending on shelter quality
- **Environmental Modifiers**: Weather, sun position, altitude (+/- 5-15%)
- **Evasion Bonus**: Target defensive actions (-10% to -30%)

**Damage Calculation**
```
Final Damage = Base Damage × (1 ± Variance)
No critical hits; damage is consistent and predictable
```

### Action Point System

**Health-Based Action Economy**
- **Healthy Units** (>50% HP): 4 AP per turn
- **Damaged Units** (25-50% HP): 3 AP per turn
- **Critical Units** (<25% HP): 2 AP per turn

**AP Costs**:
- Standard weapon fire: 1-2 AP
- Heavy weapon fire: 3-4 AP
- Defensive posture: 1 AP
- Energy regeneration: 2 AP (turn dedicated to recovery)
- Evasion maneuvers: 1-2 AP

**Fatigue & Recovery**:
- Consecutive high-AP turns cause fatigue penalty (-1 AP next turn)
- "Second Wind" ability recovers 1 AP at 50 EP cost
- "Adrenaline Rush" emergency mode grants +1 AP once per combat

### Energy Point System

**Energy Regeneration by Unit Type**
- **Bases**: 50+ EP/turn (very high)
- **Large Craft**: 10-15 EP/turn
- **Small Craft**: 5-10 EP/turn
- **Energy Depletion**: Cannot fire without sufficient EP; shields collapse at 0 EP

**Energy Usage**:
- Standard weapons: 5-10 EP/shot
- Heavy weapons: 15-25 EP/shot
- Energy weapons: 20-40 EP/shot (infinite ammo)
- Shield activation: 10 EP/turn while active
- Evasion maneuvers: 5-25 EP depending on intensity

**Thermal/Heat System**
- Extended weapon use generates heat buildup (weapon jam at 100+ heat)
- Heat generation: +5 (single shot), +15 (burst), +20 (overcharge)
- Heat dissipation: -15 (bases), -10 (large craft), -5 (small craft)
- Heat threshold effects: 0-50 (normal), 51-100 (warning), 101+ (jammed)

### Interception Outcomes

**Victory Conditions**
- Destroy all enemy objects in sector
- Force enemy retreat/withdrawal
- Prevent enemy objective completion

**Defeat Consequences**
- Craft damage (40-70% hull loss typical)
- Craft destruction (rare, units rescued by escape pods)
- Craft retreats with losses
- Enables optional player Battlescape interception to save facilities

**Experience & Advancement**
- Pilots gain XP from successful interceptions
- Craft efficiency improves with pilot level
- Pilot abilities unlock: Barrel Roll (+40% dodge), Immelman Turn (180° reverse), Cobra Maneuver (auto-flank)

### Base Defense Integration

- UFOs may attack player bases if not intercepted
- Base defense rating determines passive resistance
- Successful interception prevents base damage
- Failed interception allows salvage opportunity via Battlescape engagement

---

## SECTION XIX: MARKETPLACE & TRADING SYSTEM

### Purpose
The Marketplace provides access to equipment, resources, and services through multiple competing suppliers. Marketplace availability is dynamic based on diplomatic relations, fame, tech progress, and supplier specialization.

### Pricing Mechanics

**Base Price System**
- Each item has distinct buy/sell prices (buy typically 2× sell value)
- Market fluctuation modifier: -50% to +50% based on supply/demand
- Supplier markup multipliers: 0.8× (discount) to 1.5× (premium)
- Regional availability varies by political stability

**Price Modifiers**
- **Reputation Discount**: Up to 50% discount with high trader reputation
- **Inflation/Deflation Events**: Global ±3-20% price variance
- **Supply Scarcity**: High-demand items cost more; surplus items cost less
- **Transaction Size**: Large bulk orders qualify for batch discounts (5-15%)
- **Tech Prerequisites**: Unresearched items unavailable or cost premium

**Supplier Categories**

| Supplier | Type | Base Markup | Specialization |
|----------|------|-------------|-----------------|
| **Military Supply** | Legitimate | 100% | Military equipment |
| **Syndicate Trade** | Gray Market | 120-150% | Upgrades, rare items |
| **Exotic Arms** | Black Market | 200-300% | Alien-tech weapons |
| **Research Materials** | Universal | 80-110% | Raw materials |
| **Tactical Network** | Legitimate | 90-110% | Armor, tactical gear |
| **Black Market** | Restricted | Variable | Experimental, prohibited |

### Supplier Relationships

**Reputation System**
- Trader reputation: -100 (hostile) to +100 (allied)
- Purchase volume increases reputation (more buying = more trust)
- Consistency bonuses: Multiple transactions build trust faster
- Reputation gates access tiers: Basic → Standard → Expanded → Premium → Elite

**Relationship Impact**
- Pricing modifiers range from -50% (elite) to +100% (hostile)
- Availability modifiers affect which items suppliers stock
- Supply limits vary by reputation: low-reputation traders have limited stock
- Risk of trading detection: 5% base + transaction size modifier (authorities intervene)

### Item Availability

**Research-Gated Items**
- Alien-tech weapons unavailable until researched
- Specialized equipment locked behind tech tree completion
- Higher-tier items require minimum tech level (1-4 scale)
- Regional restrictions: military equipment limited in unstable regions

**Item Categories**
- Raw materials: Alloys, electronics, rare earth components
- Components: Circuits, mechanisms, power cores
- Weapons & armor: With durability (0-100 condition)
- Consumables: Medkits, stimulants, specialty items
- Salvage: Alien artifacts, captured equipment, debris

### Economic Events (Marketplace Impact)

- **Boom Period**: -10% all market prices, +50% income
- **Recession**: -50% income, +20% market prices
- **Inflation Spike**: +30% expenses, +40% market prices
- **Market Crash**: Severe volatility, ±50% price swings
- **Supply Crisis**: Specific item categories unavailable temporarily

---

## SECTION XX: DYNAMIC EVENT SYSTEM

### Purpose
Random events introduce unpredictability and consequences into campaigns. Events affect multiple systems simultaneously, creating emergent narrative and strategic challenges.

### Event Categories & Frequency

**Event Generation**
- Trigger frequency: 2-5 events per month (scales with organization level)
- Weighted random selection ensures variety
- Turn-based rolling (checked daily) creates unpredictable timing
- Multiple simultaneous events possible with compounding modifiers

**Economic Events** (30% frequency)
- **Market Boom**: +50% income, -10% prices (3-4 months)
- **Market Crash**: -50% prices, ±50% volatility (2-3 months)
- **Inflation Crisis**: +30% expenses, +40% prices (2-3 months)
- **Tax Reduction**: +15% monthly income (2 months)
- **Economic Windfall**: +10,000 credits bonus (one-time)
- **Supplier Bonus**: -50% cost on single supplier (2 weeks)

**Personnel Events** (25% frequency)
- **Recruitment Surge**: +3-8 units available for hiring
- **Unit Desertion**: 1-3 units leave organization
- **Morale Crisis**: All units gain XP at -20% rate (2 months)
- **Legendary Soldier**: Hero-tier unit available (high cost)
- **Personnel Injury**: Unit combat effectiveness -50% (1 month)
- **Training Breakthrough**: All units gain +1 rank instantly (rare)

**Research Events** (15% frequency)
- **Breakthrough**: One active research completes immediately
- **Research Setback**: Active research loses 50% progress
- **Equipment Failure**: Manufacturing efficiency -20% (2 weeks)
- **Alien Discovery**: Significant research item found
- **Scientific Cooperation**: Allied nation shares research (+30 days)
- **Sabotage**: Research delayed 50% (spying incident)

**Diplomatic Events** (15% frequency)
- **Faction Betrayal**: Allied nation becomes hostile (-50 relation)
- **Alliance Offer**: Neutral faction offers alliance (+30 relation)
- **Diplomatic Incident**: All relations -5 (international crisis)
- **Trade War**: Supplier prices +50% (competition)
- **Peace Negotiation**: Temporary truce with enemy (-1 month no missions)
- **Embassy Establishment**: Future diplomatic incidents -30% likely

**Operational Events** (15% frequency)
- **Supply Delay**: Scheduled marketplace delivery delayed +7 days
- **Facility Damage**: Random base facility damaged (-20% efficiency, 1 month)
- **Base Incident**: UFO attack damages 1-2 facilities, kills 1-2 units
- **Craft Malfunction**: Craft needs emergency repair before operations
- **Weather Disaster**: Regional missions unavailable 1-2 weeks
- **Sabotage Discovery**: Internal infiltrator found, security increased

### Event Mechanics

**Impact Application**
- Events modify specific systems: income/expense, item prices, unit availability, research speed
- Modifiers stack if multiple events active simultaneously
- Negative events can cascade (market crash → personnel cuts → facilities go offline)
- Positive events often appear after sustained hardship (reward for persistence)

**Event Duration**
- Short-term: 2-3 weeks (supply issues, weather)
- Medium-term: 1-2 months (research setback, morale crisis)
- Long-term: 3-6 months (economic trends, diplomatic shifts)
- One-time: Immediate effect, no duration (bonuses, discoveries)

---

## SECTION XXI: QUEST SYSTEM

### Purpose
Quests provide optional secondary objectives that encourage specific playstyles and create campaign structure. Quests reward players for achieving varied goals beyond primary mission objectives.

### Quest Types & Mechanics

**Quest Categories**

| Type | Duration | Objective | Reward | Difficulty |
|------|----------|-----------|--------|-----------|
| **Military** | 2-4 weeks | Destroy X UFOs/bases | +2 Power Points | Medium |
| **Economic** | 1-2 months | Earn 50K+ credits | +1000 credits | Low |
| **Diplomatic** | 4-8 weeks | Achieve relation goals | +5 Fame | Medium |
| **Organizational** | 2-3 months | Build X bases/facilities | +3 Power Points | Med-High |
| **Research** | 3-6 months | Complete tech branches | +2000 credits | Medium |
| **Heroic** | Variable | Destroy alien bases | +5 Power Points, +50 Fame | High |
| **Regional** | 1 month | Control region (90%) | +500 credits, +1000 points | High |
| **Survival** | 2-4 weeks | Defend bases X turns | +3 Power Points | Variable |

### Quest Generation

**Frequency & Activation**
- 3-5 simultaneous active quests typical
- New quests generated monthly or triggered by campaign events
- Quest generation influenced by: player level, faction relations, campaign phase
- Optional activation: players can accept or ignore available quests

**Quest Objectives**
- Quantified targets: "Destroy 5 UFOs", "Earn 50K credits", "Build 3 bases"
- Faction relations targets: "+50 relation gain with country X"
- Multi-mission completion: Tracked across multiple player missions
- Optional secondary objectives for bonus rewards
- Campaign milestone integration: Some quests tied to story progression

### Quest Rewards & Incentives

**Reward Types**
- **Power Points**: 1-5 per quest (military/heroic bonus, strategic currency)
- **Credits**: 1,000-2,000+ per economic quest
- **Fame**: +5 per diplomatic quest (notoriety/prestige)
- **Research Unlocks**: Technology tree advances (+50-100 tech progression)
- **Facility Bonuses**: Construction discounts (20-30%) or production speed (+15-20%)
- **Regional Control**: Territory expansion affecting funding/missions

**Failure Consequences**
- Incomplete quests expire without penalty (soft failure)
- Time-limited objectives create urgency
- Failed military quests may boost enemy morale temporarily
- Failed diplomatic quests reduce faction relations (-5 to -10)

### Campaign Milestone Integration

**Chapter Structure**
- Campaign split into 5 chapters with unique milestone objectives
- Milestones create pacing and urgency (turn limits enforced)
- Completing milestones unlocks subsequent chapters and new quest types
- Difficulty scales with chapter progression (resources shift toward enemies)

**Milestone Progression**
- Chapter 1: Basic technology and first base established
- Chapter 2: Multiple bases and regional presence
- Chapter 3: Alien technology acquisition, mid-game transition
- Chapter 4: Strategic dominance, facing elite enemies
- Chapter 5: Campaign climax, final confrontation

---

# Integration Points

### Geoscape → Basescape
- Mission objectives determine squad requirements
- Country panic affects craft deployment urgency
- Country funding determines available resources
- Facility damage in base defense affects operational capacity

### Basescape → Battlescape
- Unit equipment directly affects combat capabilities
- Armor affects damage resistance and movement
- Unit experience/rank affects stat distribution
- Available equipment limits tactical options

### Battlescape → Geoscape
- Mission success/failure affects country relations
- Captured equipment adds to base inventory
- Unit casualties require replacement recruitment
- Research data from missions enables tech advancement
- UFO components enable advanced craft systems

### Battlescape → Basescape
- Unit experience generates during missions
- Casualties trigger recruitment/replacement
- Wounds require medical facility recovery
- Equipment damage needs repair/replacement
- Prisoners require detention facility

### Economy System (All Layers)
- Monthly funding from countries (Geoscape)
- Base maintenance costs (Basescape)
- Unit salary costs (Basescape/Geoscape)
- Equipment manufacturing (Basescape)
- Mission rewards (Geoscape)
- Craft fuel consumption (Geoscape)

### Diplomatic System (All Layers)
- Country relations affect funding (Geoscape)
- Mission generation based on relations (Geoscape)
- Terror mission casualties damage relations (Battlescape → Geoscape)
- Player reputation affects black market access (all layers)
- Karma affects recruitment availability (Basescape)

### Unit Progression System (All Layers)
- XP gain during missions (Battlescape)
- Rank up triggers specialization choice (Basescape admin)
- Specialization affects equipment compatibility (Basescape equipment)
- Unit stats affect combat effectiveness (Battlescape)
- Rank requirements create squad composition constraints (Basescape)

---

## Countries & Diplomatic Relations

### Country Classification

**Major Powers** (5-8 per game):
- Examples: USA, China, Russia, EU Federation, India
- **Starting Bonus**: +30 relation, generate 40% more missions
- **Funding Impact**: Highest income potential (50K-100K+ monthly)
- **Strategic Role**: Primary funding sources, protecting critical for campaign

**Secondary Powers** (8-12 per game):
- Examples: Japan, Germany, Brazil, Canada, UK
- **Standard Relations**: Baseline starting point
- **Funding**: Moderate income (20K-50K monthly)
- **Strategic Role**: Stable income hedging

**Minor Nations** (10-15 per game):
- Examples: New Zealand, Singapore, Cyprus, Costa Rica
- **Reduced Frequency**: Lower mission generation
- **Funding**: Low income (5K-20K monthly)
- **Strategic Role**: Easy wins for relationship building

**Supranational Organizations** (2-3 per game):
- Examples: UN-XCOM Alliance, International Space Authority
- **Rules**: Cannot declare war, always neutral/allied
- **Strategic Role**: Diplomatic victory mechanisms

### Regional Bloc System

**Geographic Organization**:
- North America, South America, Europe, Middle East, Asia-Pacific, Africa
- Regions share panic and morale levels
- Regional stability affects UFO sighting frequency
- Regional defense bonuses available

**Regional Effects**:
- Adjacent regions suffer panic contagion (+5 panic spread)
- Regional bloc cooperation provides defense synergies
- Collective defense efforts provide +10% effectiveness
- Regional relationships create diplomatic cascades

### Country Panic & Relations

**Panic Mechanics** (0-100 scale):
- Increases: Failed missions (+5-15%), alien raids (+20%), base loss (+10%), territory loss (+5%)
- Decreases: Successful missions (-2-5%), major victories (-10-15%)
- At 100%: Country demands all-or-nothing sacrifice; funding cut if refused
- Cascades: Panic spreads to adjacent regions at 50%+ threshold

**Relations Tracking**:
- Diplomatic relations tracked with history and trends
- Time-based decay and growth mechanics
- UI-ready status labels (Allied/Neutral/Hostile)
- Unified with country state management

**Country Funding Mechanics**:
- Base funding: 10-100K credits/month (varies by country)
- Relation multiplier: 0.5x to 2.0x based on relations
- Threat multiplier: 1.0x to 1.5x during high alien activity
- Decay: 0.95x multiplier monthly (pressure to perform)

### Supplier Integration

**Supplier Behavior** (Dynamic):
- **Allied** (Favor +2): +50% inventory, -10% pricing, priority access to rare items
- **Neutral** (Favor 0): Normal inventory, normal pricing, standard service
- **Hostile** (Favor -2): -50% inventory, +15% pricing, possible service closure
- **Betrayal**: Can block critical items for 2 weeks if hostility threshold reached

**Market-Based Pricing**:
- Base prices for all items, facilities, research
- Supply/demand fluctuations: ±20% monthly
- Rarity multipliers: Rare items 150-300% markup
- Bulk discounts: 5+ identical items get +20% discount
- Seasonal variations: Some goods price cycle seasonally

---

## Basescape Management System

### Base Construction & Sizing

**Base Sizes**:
- **Small** (4×4): 16 tiles, 150K cost, 30-day build, 8-10 facility slots, +1 relation bonus
- **Medium** (5×5): 25 tiles, 250K cost, 45-day build, 15-18 facility slots, +1 relation bonus
- **Large** (6×6): 36 tiles, 400K cost, 60-day build, 24-28 facility slots, +2 relation bonus (requires +50 relations)
- **Huge** (7×7): 49 tiles, 600K cost, 90-day build, 35-40 facility slots, +3 relation bonus (requires +75 relations)

**Base Expansion System**:
- Sequential progression (Small → Medium → Large → Huge)
- Expansions preserve existing facilities, add new slots
- Gated by technology level and country relations
- One base per province maximum (exclusive territorial occupation)

**Biome Construction Penalties**:
- Ocean: +250% cost/time | Mountain: +40% cost/time | Arctic: +35% cost/time | Urban: +25% cost | Desert: +20% cost/time
- Forest/Grassland: Baseline (no penalty)

### Facility Grid System (Orthogonal Square)

**Grid Architecture**:
- Type: Orthogonal Square grid (40×60 tiles typical maximum)
- Neighbors: 4 adjacent cardinal (N/S/E/W) or 8 with diagonals
- Rotation: Facilities NOT rotatable (fixed orientation)
- Coordinates: (X, Y) where X=0-39, Y=0-59, origin top-left

### Facility Types & Functions

**Personnel & Training**:
- **Barracks S** (1×1): 8 units, 5 power, 30K cost
- **Barracks L** (2×2): 20 units, 10 power, 60K cost (upgrade)
- **Academy** (2×2): +1 XP/week baseline, +5 trainee capacity (U1), +2 XP/week (U2), 8 power, 60K
- **Strength Training** (2×2): +1 Strength per unit/week trained, 12 power, 100K/week maint, 500K cost

**Medical & Support**:
- **Hospital** (2×2): +2 HP/week baseline, +5 beds (U1), +1 sanity/week (U2), 10 power, 50K
- **Temple** (2×2): Spiritual/morale systems, 8 power

**Command & Control**:
- **Command Center** (2×2): +10 facility efficiency when adjacent, 15 power, 100K
- **Radar S** (2×2): 500km range, 8 power, 50K | **Radar L**: 800km range, 12 power, 80K

**Research & Manufacturing**:
- **Lab S** (2×2): 10 man-days baseline, +50% (U1), +2 queue (U2), 15 power, 70K
- **Lab L** (3×3): 20 man-days, 30 power, 120K
- **Workshop S** (2×2): 10 man-days mfg, +50% (U1), +2 queue (U2), 15 power, 60K
- **Workshop L** (3×3): 20 man-days, 30 power, 110K

**Storage & Resources**:
- **Storage S** (1×1): 100 items, 2 power, 20K
- **Storage M** (2×2): 400 items, 5 power, 50K (U1)
- **Storage L** (3×3): 800 items, 8 power, 90K (U2)
- **Power Plant** (1×1): +50 power, 10 self-consume, 100K
- **Power Plant Enhanced** (U1): +100 power, 15 self-consume

**Craft Operations**:
- **Hangar M** (2×2): 4 craft capacity, 15 power, 80K
- **Hangar L** (3×3): 8 craft capacity, 30 power, 150K (upgrade)
- **Garage** (2×2): Craft repair tools, 12 power, 70K

**Defense & Detention**:
- **Turret M** (2×2): 50 defense, 15 power, 90K
- **Turret L** (3×3): 75 defense (U1), 35 power, 150K
- **Prison** (3×3): 10 prisoners max, 12 power, 100K

### Facility Upgrade System

**Upgrade Mechanics**:
- Construction time: 14-30 days per upgrade
- Cost: 50-150K per upgrade (typically 20% of facility cost)
- Original facility preserved (no destruction)
- Provides 30-50% efficiency improvement (cheaper than rebuild)
- Upgrade examples: Lab +50% output (10→15 man-days), Barracks capacity increase, Hangar +4 slots

### Prisoner System

**Capture & Detention**:
- Units with HP > 0 at mission end become prisoners
- Prison capacity: 3×3 = 10 maximum
- Prisoner lifetime: 30 + (Unit Max HP × 2) days
- Overflow prisoners executed automatically
- 1% escape chance per prisoner per day

**Prisoner Options**:

| Option | Karma | Research | Duration | Result |
|--------|-------|----------|----------|--------|
| **Execute** | −5 | 0 | Immediate | Removed |
| **Interrogate** | ±0 | +30 man-days | 1 week | Military intelligence |
| **Experiment** | −3 | +60 man-days | 2 weeks | Dies after |
| **Exchange** | +3 | 0 | 1 week | +3 relations faction |
| **Convert** | ±0 | 0 | 4 weeks | 60% success (+ bonuses) |
| **Release** | +5 | 0 | Immediate | +1 relations enemy |

### Power Management System

**Generation & Consumption**:
- **Power Plant**: +50 power, 10 self-consume, 100K cost
- **Enhanced Plant**: +100 power, 15 self-consume
- Multiple plants additive
- Shortage: Consumed > Available triggers priority system (10-tier priority)
- Low priority (storage, non-essential) offline first; high priority (barracks, labs, hangars) retain power

**Facility Power Costs**:
- Corridor: 2 | Barracks S/L: 5/10 | Lab S/L: 15/30 | Workshop S/L: 15/30
- Hospital: 10 | Academy: 8 | Garage: 12 | Hangar M/L: 15/30
- Radar S/L: 8/12 | Turret M/L: 15/35 | Prison: 12

### Unit Recruitment & Personnel

**Recruitment Sources**:
- Country: 20-50K, 6-12 stats, immediate
- Faction: 30-75K, 8-14 stats (specialized), 1 week
- Marketplace: 40-100K, variable, immediate
- Retraining: 0K, randomized, 1 week

**Barracks Capacity**:
- 1×1: 8 units | 2×2: 20 units
- Org Level Bonus: +1-5 slots per level
- Salary: 5K/month per unit (mandatory)
- Overcrowding: -50% morale if exceeding capacity

### Hangar Storage Capacity

**Craft Storage**:
- Craft sizes: Fighter (1 slot), Bomber (2 slots), Capital (4 slots)
- Total capacity = sum of all hangar slots
- Cannot exceed total (purchase blocked)
- Overflow craft cannot deploy (stranded at base)

---

## Battlescape Tactical Combat System

### Coordinate System & Map Grid

**Hex-Based Vertical Axial System**:
- Vertical axial coordinates: (row, col) for hex-grid positioning
- Z-elevation: 0-3 levels (ground, elevated, high, peak)
- Diagonal adjacency: 6 adjacent hexes + vertical neighbors (up/down)
- Large maps: 100+ hex diameter possible
- LOS/LOF calculated through 3D voxel space

### Map Generation System

**Terrain Types & Biomes**:
- 8 biome types (Forest, Desert, Mountain, Urban, Ocean, Arctic, Alien, Underworld)
- Each biome has 2-4 terrain variants (e.g., Forest: dense forest, clearing, ruins)
- Biome selection based on mission type and geoscape location

**Map Block & Script System**:
- **Map Blocks**: Reusable 2D chunks (5×5 to 10×10 hex typical)
- **Map Scripts**: Procedural generation rules (place blocks, draw features, fill space)
- **Transformation**: Blocks can be rotated (90/180/270°), mirrored, inverted
- **Final Battlefield**: Unified grid assembled from map blocks with applied transformations

### Battle Setup & Deployment

**Landing Zone System**:
- Player selects landing zone before battle starts
- Landing zones prevent enemy units/obstacles (clean deployment area)
- Number of zones scales with map size:
  - Small (4×4 blocks): 1 zone
  - Medium (5×5): 2 zones
  - Large (6×6): 3 zones
  - Huge (7×7): 4 zones

**Enemy Squad Building**:
- Squad composition scales with difficulty (100% baseline, adjusted Easy/Normal/Hard/Impossible)
- Units distributed into multiple squads (1-N units per squad)
- Squads deployed to separate map blocks
- Auto-promotion using experience budget (rank/equipment scaling)

**Deployment Process**:
1. Build enemy squads (composition, rank, equipment)
2. Deploy enemy squads to map blocks (1 per block)
3. Place individual units randomly on tiles
4. Deploy neutral units (NPCs, animals) randomly
5. Initialize environmental effects (smoke, fire, gas)
6. Calculate initial fog-of-war

### Entity Types & Terrain

**Walkable Terrain**:
- Floor (default), Grass, Sand, Water (blocks movement unless flying), Swamp (+2 movement cost)
- Cost of sight: 1 (transparent to vision)

**Blocked Terrain**:
- Wall, Rock, Large obstacle
- Blocks movement and line-of-sight
- Cost of sight: 5-6 (blocks completely)

**Cover Types**:
- Bush (cost 3 sight, 5% cover), Rock (cost 2, 5%), Tree (cost 4, 10%), Rubble (cost 3, 5%), Crate (cost 2, 10%)
- Each cover point = 5% accuracy reduction (cumulative)
- Cover destruction possible with AoE damage

**Environmental Effects**:
- Smoke (opaque, blocks vision, no damage), Fire (50% LOS block, 5 damage/turn), Gas (toxic, vision impaired, special damage)
- Smoke/Fire/Gas dissipate over time (turn-based decay)

### Combat Mechanics & Accuracy

**Line of Sight (LOS)**:
- Traced from attacker eye position to target center
- Obstacles with cost-of-sight > 0 block LOS
- Partial blocking: LOS_Mod = 0.5 if obscured (not fully blocked)
- Special case: Hidden/shrouded targets LOS_Mod = 0.5

**Line of Fire (LOF)**:
- Weapon projectiles pass through certain obstacles
- Different weapons ignore different obstacles (e.g., energy weapons ignore smoke)
- Ricochet (optional future expansion): Projectiles bounce off walls

**Cover System** (Two-part):
1. **Cost of Sight**: How much cover blocks visibility?
   - Walls: 100% blocking | Obstacles: Partial blocking | Bushes: 50% blocking
2. **Cost of Fire**: Accuracy reduction via cover value
   - Each cover point: 5% accuracy loss (cumulative, multiplicative)
   - Example: 3 cover points = Cover_Mod 0.85 (15% loss)

**Ranged Accuracy Formula** (All Multiplicative):

```
Final_Accuracy = Base × Range_Mod × Mode_Mod × Cover_Mod × LOS_Mod
Clamp to: 5% minimum, 95% maximum

Base_Accuracy = Unit_Aim_Stat × (1 + Weapon_Aim_Bonus)

Range_Mod:
  0-75% of range: 1.0 (no penalty)
  75-100%: Linear drop from 1.0 to 0.5
  100%+: 0.0 (impossible shot)

Weapon_Mode (Mode_Mod):
  Base/Semi-Auto: 1.0
  Snap Shot: 0.95
  Burst: 0.85
  Auto: 0.75
  Aimed Shot: 1.15
  Careful Aim: 1.30

Cover_Mod: 1.0 - (0.05 × Total_Cover_Points)
LOS_Mod: 1.0 (visible) or 0.5 (obscured)
```

### Weapon Modes & Range

**Standard Weapon Modes**:
- Base: Standard aim (Mode_Mod 1.0)
- Snap Shot: Quick fire (Mode_Mod 0.95)
- Semi-Auto: Deliberate (Mode_Mod 1.0)
- Burst: Less controlled (Mode_Mod 0.85)
- Auto: Least controlled (Mode_Mod 0.75)
- Aimed Shot: Careful (Mode_Mod 1.15)
- Careful Aim: Very careful (Mode_Mod 1.30)

**Minimum Range Penalties**:
- Sniper Rifles: -50% accuracy within 3 hexes (scope ineffective close)
- Shotguns: No penalty (effective all ranges)
- Pistols: No penalty

### Melee Combat

**Prerequisites**:
- Target must be adjacent (1 hex away)
- Unit must have melee weapon equipped
- Sufficient AP (1 AP minimum per melee attack)

**Melee Attack Resolution**:
- Hit chance: Base_Melee_Stat + Weapon_Bonus ± terrain modifiers
- Examples: Knife 70%, Sword 75%, Plasma Blade 85%

**Melee Damage Calculation**:
```
Damage = Base_Damage + Strength_Bonus ± Weapon_Enchantment
Armor_Reduced = Damage × (1 - Target_Armor_Value)
Final_Damage = max(1, Armor_Reduced)
```

**Melee Engagement Duration**:
- Each melee hit locks units in combat (mutual engagement)
- Both units continue fighting until one disengages or dies
- Disengaging: Movement action breaks engagement (5 AP cost typical)

### Unit Resource Management

**Health Point System (HP)**:
- Base health: 15-25 typical (varies by unit)
- Health damage: Direct weapon damage, terrain hazards
- Health-based AP penalty: At <50% HP, units suffer -2 AP/turn
- Death: Incapacitation at 0 HP or negative values trigger "last stand" (1 final action possible)

**Stun Point System**:
- Stun mechanics: Stun damage accumulates separate from HP
- Unconscious state: At max stun, unit is "fainted" (immobilized, cannot act)
- Decay: Stun points naturally decrease each turn (-2 to -5 per turn depending on constitution)
- Rest action: In-battle recovery restores stun points

**Energy Point System (EP)**:
- Base energy: 50-400 depending on craft/unit size
- Energy regeneration: +20-50 per turn (varies by unit)
- Energy consumption: Actions cost 5-20 EP
- No energy = no action possible

**Movement Point System (MP)**:
- Movement calculation: Base_Speed stat + terrain effects
- Terrain costs: Grass (1), Swamp (+2), Water (+3 or blocked), Elevation (+1 per level)
- Elevation changes: Climbing cost +1 MP per level
- Turning: Free (no MP cost)

### Unit Actions

**Base Actions**:
- **Move**: 2 AP + MP calculation, no noise
- **Run**: 1 AP + 2× MP, creates audible footsteps
- **Sneak**: 3 AP + MP (slow), silent movement (+1 Concealment)
- **Fire**: 1-3 AP (varies by weapon), generates combat
- **Overwatch**: 2 AP, ready to react fire, 1 reaction per turn
- **Cover**: 1 AP, defensive stance (-2 acc vs targets, +2 armor)
- **Suppress**: 2 AP, reduce enemy accuracy by 25%
- **Rest**: 1 AP, restore stun/EP, vulnerable state
- **Throw**: 1 AP, grenade/thrown weapon action

### Unit Turn Order & Initiative

**Turn Sequence**:
- Round-based (all units act once per round)
- Initiative within teams: Reaction stat determines action order
- Higher Reaction = earlier action in round

**Action Priority**:
- Units with higher Reaction act first
- Ties: Players act before enemies, allies before enemies
- Reactionary actions: Reaction fire, counter-attacks interrupt normal turns

**AP Refreshment**:
- Full AP restore at start of turn
- AP carries over if unit has "Quick Reflexes" trait (+2 AP carryover max)

### Status Effects & Damage Types

**Damage Types** (8 total):
- **Kinetic**: Bullets, melee; no armor scaling
- **Explosive**: Grenades, explosions; affected by cover/proximity
- **Energy**: Laser weapons; reduced by energy armor
- **Psi**: Mental/psychic damage; affected by sanity/morale
- **Stun**: Non-lethal; causes unconsciousness
- **Acid**: Chemical; ignores some armor types
- **Fire**: DoT (damage-over-time); spreads over turns
- **Frost**: Slows units, reduced movement

**Status Effects**:
- Bleeding: -1 HP/turn until treated
- On Fire: -5 HP/turn, spreads to adjacent tiles
- Suppressed: -25% accuracy until turn end
- Stunned: Cannot act for 1-3 turns (scales with damage)
- Poisoned: -1 HP/turn for 5 turns
- Panicked: Random movement, reduced accuracy

### Weapon System

**Ranged Weapons**:
- Pistol: 8-hex range, 1 AP, 12 damage, 70% accuracy, 5 EP
- Rifle: 15-hex, 2 AP, 18 damage, 70% accuracy, 8 EP
- Sniper Rifle: 25-hex, 3 AP, 35 damage, 85% accuracy, 12 EP
- Shotgun: 3-hex, 2 AP, 45 damage, 60% accuracy, 10 EP, 3-hex area
- Grenade Launcher: 12-hex, 2 AP, 30 area damage, 65% accuracy, 15 EP
- Heavy Cannon: 20-hex, 3 AP, 60 damage, 55% accuracy, 20 EP (Specialist)

**Melee Weapons**:
- Knife: 1-hex, 1 AP, 8 damage, 8 melee to-hit, infinite EP
- Sword: 1-hex, 1 AP, 15 damage, 10 melee to-hit, infinite EP
- Plasma Blade: 1-hex, 1 AP, 25 damage, 12 melee to-hit, 8 EP (Specialist)

**Support Equipment**:
- Medikit: 5 charges, 1 AP/use, heals 25 HP (Medic) or 15 (other), 1 per unit
- Motion Scanner: +3 sight range, 50-turn battery, 1 AP activate
- Night Vision: +5 night vision, 100-turn battery, passive when equipped
- Repair Kit: Repairs mechanical units, 25 HP/use, 3 charges

### Explosion System

**Explosion Parameters**:
- Radius: 2-6 hexes typical (varies by weapon)
- Damage falloff: Linear decay from center
- Center damage: Full weapon damage
- Edge damage: Reduced by 50% at maximum radius

**Propagation**:
- Walls: 100% damage block
- Units: 50% damage reduction (partial block)
- Terrain obstacles: 25-75% block depending on type
- Blast doesn't pass through solid walls

### Victory & Defeat Conditions

**Mission Success**:
- All objectives completed
- Player squad survives (may have casualties)
- Enemy forces eliminated or routed

**Mission Failure**:
- All player units eliminated
- Mission time expires without objectives met
- Retreat command triggered

---

## Unit System

### Unit Classification & Hierarchy

**Rank Structure** (7 Ranks):
- **Rank 0**: Conscript (0 XP), basic/limited supplies
- **Rank 1**: Agent (200 XP), trained operative, basic role
- **Rank 2**: Specialist (500 XP), role proficiency
- **Rank 3**: Expert (900 XP), significant specialization
- **Rank 4**: Master (1,500 XP), advanced specialization
- **Rank 5**: Elite (2,500 XP), peak specialization
- **Rank 6**: Hero (4,500 XP), unique, one per squad max

**XP Modifiers**:
- Smart trait: +20% XP gain
- Stupid trait: −20% XP gain

**Class Hierarchy**:
- Rank 0: Base unit (e.g., Sectoid)
- Rank 1: Role assignment (Soldier, Support, Leader, Scout, Specialist, Pilot)
- Rank 2: Role specialization (Rifleman, Grenadier, Gunner, etc.)
- Rank 3: Specialization begins (Sniper specialist)
- Rank 4: Advanced specialization (Marksman with abilities)
- Rank 5: Master specialization (Legendary Sniper)
- Rank 6: Hero class (Supreme Commander with faction bonuses)

**Class Synergy**:
- Matched equipment: +50% effectiveness (e.g., Medic using Medikit)
- Mismatched: -30% accuracy penalty at lower class levels

**Rank Limits** (enforced):
- Rank 0-1: Unlimited
- Rank 2: Minimum 3 Rank 1 units in squad
- Rank 3: Minimum 3 Rank 2 (implies 9 Rank 1 minimum)
- Rank 4: Minimum 3 Rank 3 (implies 27 Rank 1 minimum)
- Rank 5: Minimum 3 Rank 4 (implies 81 Rank 1 minimum)
- Rank 6: Minimum 3 Rank 5, only ONE hero per player

### Unit Recruitment Paths

**Standard Recruitment** (Rank 1 "Agent"):
- Marketplace acquisition: Typical entry point
- Cost: 40-100K, variable quality
- Immediate availability
- Limited by marketplace supply

**Specialized Recruitment**:
- Technology research unlocks supplier contracts
- Specialist recruitment at Rank 2+ (premium cost)
- Robot manufacturing (mechanical units)
- Resurrection program (from corpse specimens)
- Black Market access (elite/rare units, karma impact)

**Constraints**:
- Fame/reputation: Negative karma blocks legitimate suppliers
- Supplier relations: Poor standing reduces options, increases cost
- Barracks capacity: Limited space restricts acquisition
- Economic capacity: Monthly budget limits quantity

### Unit Statistics & Combat Application

**Primary Stats**:
- **Aim** (Accuracy): 50-100% base, +10% per promotion
- **Melee**: 6-12 base, +1-2 per promotion (melee combat effectiveness)
- **Reaction**: 6-12 base, +1 per 2 promotions (initiative, action priority)
- **Speed**: 4-8 base, +0-1 per promotion (movement hexes/turn)
- **Strength**: 6-12 base, +1 per promotion (carry capacity, inventory slots)
- **Bravery**: 6-12 base, +1-2 per promotion (morale resistance)
- **Sanity**: 6-12 base, −5 per failed psi save, +1/week hospital recovery

**Secondary Stats** (Derived):
- **Health** (HP): 15-25 base, +1-2 per promotion
- **Time Units** (AP): 50-60 base, +2 per promotion
- **Stun Points**: Varies by unit type
- **Morale**: 10+ base, -1 per casualty, +1/week rest

**Base Stat Progression** (by Rank):

| Stat | Rank 1 | Rank 2 | Rank 3 | Rank 4 | Rank 5 | Rank 6 |
|------|--------|--------|--------|--------|--------|--------|
| Aim | 70% | 75% | 80% | 85% | 90% | 95% |
| Melee | 8 | 9 | 10 | 12 | 14 | 16 |
| Reaction | 8 | 9 | 10 | 11 | 12 | 13 |
| Speed | 5 | 5 | 6 | 6 | 7 | 7 |
| Strength | 8 | 9 | 10 | 11 | 12 | 13 |
| Bravery | 8 | 9 | 10 | 11 | 12 | 13 |
| Sanity | 10 | 10 | 11 | 12 | 12 | 13 |

### Unit Inventory & Equipment System

**Capacity System**:
- Based on Strength stat (6-12, representing carry capacity)
- Binary system: Carries all or none (no partial equipping)
- Each weapon: 1-2 weight units
- Each armor: 2-3 weight units
- Utility items: 0.5-1 weight units

**Equipment Slots** (3 primary):
1. **Primary Weapon**: Rifle, Pistol, Grenade Launcher, Heavy Cannon, etc.
2. **Secondary Weapon**: Backup weapon, grenades, utility
3. **Armor**: Body armor, environmental suit, specialized protective gear

**Armor Categories** (with modifiers):

| Type | Armor Value | Movement | AP | Accuracy | Cost | Special |
|------|-------------|----------|-----|----------|------|---------|
| Light Scout | +5 | +1 hex | 0 | +5% | 8K | Mobility-focused |
| Combat | +15 | -1 hex | -1 | -5% | 15K | Balanced |
| Heavy Assault | +25 | -2 hex | -2 | -10% | 25K | Max protection |
| Hazmat | +10 | 0 | 0 | -5% | 12K | +100% hazard resist |
| Stealth | +8 | 0 | 0 | 0 | 20K | +20% concealment |
| Medic Vest | +8 | 0 | 0 | 0 | 10K | +50% medikit healing |
| Sniper Ghillie | +10 | -1 hex | 0 | +10% | 18K | +1 sight range |

**Damage Type Resistances**:
- Kinetic: 0-50% reduction
- Energy: 0-40% reduction
- Hazard (poison/chem): 0-30% reduction
- **Ablative Armor**: -50% explosive (degrades 10% per hit)
- **Reactive Armor**: -40% explosive, -20% kinetic
- **Energy Shield**: -50% all (power-dependent)

### Demotion System

**Eligibility**:
- Rank 2+ units only (Rank 0-1 cannot demote)
- Unit in barracks (not deployed)
- Cannot demote if "Stubborn" trait present

**Demotion Mechanics**:
- Retain 50% of current XP (rounded down)
- Revert stats to target rank baselines
- Keep all traits and transformations
- Equipment flagged for compatibility check (-30% penalty if mismatched)
- 1-week retraining period

**Demotion Use Cases**:
- Path correction: Unit trained wrong specialization
- Economic: Reduce salary costs temporarily
- Team flexibility: Squad composition changes
- Specialization reset: Explore alternative career paths

### Respecialization System

**Respecialization Definition**:
- Rank stays unchanged (no level loss)
- Specialization changes to new class
- All stats remain at current level (no decay)
- Perks reset and reassigned per new specialization
- XP and progress preserved

**Requirements**:
- Rank 2+ unit only
- Barracks (not deployed)
- Available respecialization uses
- Cost: 15,000 credits
- Time: 1 week training

**Specialization Change Process**:
- Select from all valid specializations at current rank
- Cannot respecialize to same specialization
- New specialization determines perk assignments

### Unit Traits System

**Trait Architecture**:
- Permanent modifiers assigned at recruitment/advancement
- Multiple traits per unit, balanced by point value
- 4 trait points total per unit (fixed cap)
- Positive traits consume points; negative traits refund points
- Cannot exceed 4-point maximum

**Trait Types**:

**Combat Traits**:
- Quick Reflexes: +2 Reaction (2 pts)
- Sharp Aim: +1 Accuracy, +5% hit (2 pts)
- Steady Hand: -0.5% penalty per cover (1 pt)
- Marksman: +15% accuracy at 50%+ range (1 pt)
- Ambidextrous: Dual wield (2 pts, 50 kills achievement)
- Rapid Fire: +1 shot burst (1 pt)
- Sharpened Reflexes: +1 melee dodge (1 pt)

**Physical Traits**:
- Strong: +2 Strength, +4 carry (2 pts)
- Fast: +1 Speed, +1 hex (2 pts)
- Enduring: +10% HP, +5% movement (1 pt)
- Resilient: +2 armor all (1 pt)
- Athletic: Jump obstacles (1 pt, 10 missions)
- Lightweight: -1 move cost terrain (1 pt)

**Mental Traits**:
- Iron Will: +2 Bravery, +25% morale resist (2 pts)
- Disciplined: -1 stun duration, +10% status resist (1 pt)

**Negative Traits** (refund points):
- Slow Reflexes: -1 Reaction (-1 pt)
- Poor Aim: -1 Accuracy, -5% hit (-2 pts)
- Shaky Hands: +1% penalty per cover (-1 pt)
- Gun Shy: -2 accuracy first shot (-1 pt)
- Clumsy: -1 Reaction, stumbles (-2 pts)
- Weak: -1 Strength (-2 pts)
- Slow: -1 Speed (-1 pt)
- Frail: -10% HP (-2 pts)

**Trait Acquisition**:
- Birth traits: Random at recruitment (30% positive, 20% negative, 50% empty)
- Achievement traits: Earned through combat (50 kills, 10 missions, etc.)
- Perk system: Selected during rank advancement

### Unit Transformations

**Overview**:
- Permanent status changes affecting stat progression, abilities, vulnerabilities
- Examples: Cybernetic augmentation, genetic mutation, alien hybridization
- Cannot be reversed without special research

**Transformation Categories**:
- Cybernetic: +2 Strength, +1 Speed, immune to panic/morale
- Genetic: +1-2 random stats, possible vulnerabilities
- Alien Hybrid: Mixed stats, special abilities, alienation risk

### Unit Health & Recovery

**Recovery Systems**:
- Hospital facility: +2 HP/week baseline
- Rest during missions: 1 AP → restore stun, natural HP regeneration
- Status effects: Bleeding (-1 HP/turn until treated)
- Incapacitation: At 0 HP, unit "fainted" or dies depending on mission

**Sanity System** (Mental Health):
- Base: 6-12 depending on unit
- Decreased: -5 per failed psi save, -3 witness alien casualty
- Increased: +1/week hospital recovery, +2 meditation (Temple)
- At 0: Unit mentally broken, cannot be deployed

### Perks System

**Perk Mechanics**:
- Specialized abilities unlocked at specific ranks
- Each rank unlocks 1-2 perks to choose from
- Cannot change perks after selection (permanent per specialization)
- Respecialization resets perks

**Perk Categories**:
- **Combat Perks**: Extra attack, improved accuracy, special abilities
- **Support Perks**: Healing bonuses, status resist, morale boost
- **Defensive Perks**: Armor bonus, dodge chance, cover efficiency
- **Utility Perks**: Detection, speed, ammo efficiency

---



### Faction Overview
- **Definition**: Independent enemy organizations (Sectoid Empire, Ethereal Collective, Hybrid Cells, etc.)
- **Autonomy**: Each faction operates independently with distinct units, research, and mission goals
- **Unit Classes**: Faction-specific soldier types with unique stats and specialization trees
- **Resource Economy**: Separate manufacturing and resource systems per faction
- **Technology Trees**: Independent research progression per faction (unaffected by player research)
- **Regional Preferences**: Factions concentrate operations in preferred regions (Asian factions 80% in Asia, etc.)

### Campaign Generation & Mission Scheduling
- **Campaign Definition**: 5-7 sequential missions generated by faction over 6-10 weeks
- **Mission Release**: Missions deploy at predetermined intervals (typical 2-3 week gaps)
- **Campaigns Per Month**: Base 2 (Quarter 1), escalating +1 per quarter (Q2=3, Q3=4, Q4=5, capped at 10)
- **Multiple Factions**: Each faction independently generates campaigns (compound escalation)
- **Scheduling**: Missions release Week 1, Week 3, Week 6, Week 7, Week 9 within campaign (typical pattern)

### Mission Types & Persistence
- **Site Mission**: Temporary (7-14 days), static location, disappears after time limit or completion
- **UFO Mission**: Mobile craft executing mission script, 3-14 day typical duration, generates points at each script step
- **Base Mission**: Permanent until destroyed, grows 4 progression levels (120-180 days total), generates 1-5 missions/week per level

### Base Progression & Threat Escalation
- **Base Levels**: 4 progression tiers increasing threat, mission generation, and defensive capability
  - Level 1: ~50-100 defending units, generates 1 mission/week
  - Level 2: ~100-200 units, generates 2 missions/week
  - Level 3: ~200-400 units, generates 3 missions/week
  - Level 4: ~400-800 units, generates 4-5 missions/week, attempts assaults on player bases
- **Base Threat**: Adjacent player bases suffer -25% facility efficiency per enemy base
- **Progression Timeline**: 30-60 days to establish, 30-45 days per level advancement
- **Acceleration/Deceleration**: +20% progression per completed player mission from base, -30% per assault mission launched
- **Destruction Reward**: 200-500 victory points, faction loses 100 points, -3 missions/month for 1 month

---

## Geoscape Strategic System

### World Map System

**Hexagonal Grid Architecture**:
- 90×45 hexagonal grid covering Earth/Moon/Mars
- Each hex represents ~500km territory
- Hexes organized into provinces (6-12 hexes each) and regions
- Terrain affects movement costs, base construction, mission generation
- Population influences mission frequency and diplomatic importance
- Resources impact base efficiency and development

### Province System

**Provincial Control**:
- One base per province maximum (exclusive occupation)
- Province ownership affects regional diplomacy
- Control provides local resource access and population benefits
- Loss triggers diplomatic penalties
- Strategic value: population, geography, resources, alignment

### Base Placement Strategy

**Placement Rules**:
- One base per province (max), construction requires clear hex
- Adjacent hexes provide adjacency bonuses
- Distance from other bases affects operational efficiency

**Base Functions**:
- Radar coverage (UFO/mission detection)
- Craft launch/recovery facilities
- Resource processing and storage
- Unit recruitment and training
- Diplomatic presence

### Craft Movement & Interception

**Craft Speed Categories**:
- Fighter: 8 hexes/turn, 200 fuel, 1,600km range
- Interceptor: 10 hexes/turn, 250 fuel, 2,500km range
- Transport: 4 hexes/turn, 400 fuel, 1,600km range
- Bomber: 3 hexes/turn, 500 fuel, 1,500km range
- Capital: 2 hexes/turn, 800 fuel, 1,600km range

**Interception Risk**:
- Direct route: HIGH (+100% detection)
- Stealth route: MEDIUM (+50%)
- High altitude: HIGH (+100%)
- Low altitude: LOW (+30%)
- At base: NONE (0%)

**Movement Formula**: Movement/Turn = Speed × Fuel Available; Fuel Cost = Distance × Efficiency

**Deployment States**:
- Base (stationary, ready launch), Transit (moving, vulnerable), Refueling (at waypoint)
- Flying (active mission), Combat (air-to-air), Damaged (reduced speed), Grounded (no fuel)

### Detection & Radar

**Radar Coverage**:
- Radar S: 500km, 2×2 grid, 8 power, 50K cost
- Radar L: 800km, 2×2 grid, 12 power, 80K (upgrade)
- Multiple radars stack coverage areas
- Strategic positioning determines response capability

### Stealth Budget System (C3)

**Mission Mechanics**:
- Starting budget: 50-100 points (varies by mission)
- At 0%: Mission shifts from stealth to combat
- Budget depletion tracks discovery level

**Action Costs**:
- Open movement: 1/hex | Firing: 10 | Grenades: 25 | Melee: 5 | Running: 3/hex
- Sneaking: 0 | Stealth kill: 0 | Guard alert: 20 | Alarm: 50

**Stealth Status**:
- Undetected (100-76%): Normal | Suspicious (75-51%): Alert | Compromised (50-26%): Contact
- Discovered (25-0%): Combat begins

**Stealth Rewards**:
- Budget 50+: Bonus (+500 XP, +10K credits)
- Budget 0-49: Standard only
- Budget <0: Mission failed

### Mission System (Geoscape)

**Mission Types**:
- UFO Crash Recovery, Terror Missions, Alien Base Assault, Research Missions, Escort Missions
- Defensive Missions, Supply Raids, Colony Defense

**Generation**:
- Procedural based on threat assessment
- 2-5 faction missions/month, 1-3 country/month, 0-2 random/month

---

## Morale & Sanity Psychology System

### Morale System

**Morale Pool**:
- Range: 0 to Bravery stat (Bravery 8 = morale 0-8)
- Starts full at mission start
- Recovered by inspiring actions, group cohesion

**Morale Loss Events**:
- Squad death nearby: -2 | Suppression: -1/turn | Damage: -1 per 10
- Missing (3+ consecutive): -1 | Alien tech: -1/mission

**Morale Gains**:
- Killing alien: +1 | Leader nearby: +0.5/turn | Cover: +0.5
- Squad full strength: +1 at start if undamaged

**Effects**:
- 100%+: Normal | 75-99%: -5% AP cost | 50-74%: -2% AP
- 25-49%: -5% accuracy | 1-24%: -10% accuracy

### Panic Mode

**Panic Trigger**: Morale 0 → Panic Save (DC = 10 - Bravery)
- Success: Morale stays 1 | Failure: Unit panics

**Behaviors** (per turn):
- Cannot move >2 hexes, cannot attack, -50% AP recovery next turn

**Escalation**:
- Turn 1-2: Mild | Turn 3+: Severe | Turn 5+: Breakdown/retreat

**Contagion**: Adjacent units -2 morale

**Ending**: Inspire (+50% morale), kill (+2 morale), squad wipe, mission end

### Sanity System

**Range**: 0-100 (long-term psychological stability)

**Loss**:
- Per mission: -5 | Per casualty: -3 | Per alien kill: -1 | Per alien tech: -2

**Recovery**:
- Per successful mission: +2 | Per week off: +5 | Meditation: +10/week | Promotion: +3

**Effects**:
- 75-100: No penalties | 50-74: -5% panic threshold | 25-49: -15% threshold, -2 accuracy
- 1-24: Cannot deploy | 0: Discharged

### Bravery Stat

**Definition** (6-12 range):
- Permanent personality, panic threshold
- Morale cap = Bravery value
- Panic Save DC = Bravery × 10
- Leadership effectiveness scales
- Sanity baseline recovery

### Stun Damage & Wounds

**Stun Points**:
- Separate pool from HP
- Decay: -2 to -5/turn
- Fainted at max
- Stun 1-10: -10% acc | 11-20: -20% acc | 21+: -30% acc, severely impaired

**Wounds**:
- Types: Light/Moderate/Severe/Critical
- Recovery: Light 1w, Moderate 2w, Severe 4w, Critical 8w
- Per wound: -1 morale | Multiple (3+): Panic threshold +50%

### Energy/Stamina

**Pool**: Starts 100, restores +60 AP/turn (varies by unit)

**Loss**:
- Per action: -5 | Sprint: -10 | Heavy attack: -15 | Smoke/gas: -5/turn

**Recovery**:
- Cover: -1/turn | Stationary: -5/turn | Under fire: -10/turn
- Full: 2 turns stationary + cover

**Effects**:
- 75-100: Full recovery | 50-74: -50 AP/turn | 25-49: -40 AP/turn
- 1-24: -50% AP, -10% accuracy | 0: Collapses 1 turn

### System Interactions

**Morale & Sanity**: Low sanity (25-49): panic threshold ×2; Sanity 1-24: cannot deploy
**Morale & Wounds**: Per wound -1 morale; 3+ wounds: panic +50%
**Health & Energy**: HP <25: energy recovery ÷2; Energy 0: cannot move
**Stun & Panic**: Stun 15+: panic threshold -5; Panicked: cannot reduce stun; Combined: -20% acc

---

## Finance & Economic System

### Score System

**Metrics**:
- Calculated at provincial level, aggregated monthly
- Gains: Neutralize threats, save lives, destroy missions/craft
- Losses: Civilian casualties, destruction, mission fails, refused requests
- Every 20 points: ±1 relationship modifier

### Country Funding

**Calculation**:
- Economy: Sum provincial economies
- Relations: -100 (hostile) to +100 (allied)
- Funding levels 0-10: each = % of GDP to defense
- Player receives equivalent % as monthly income

**Mechanics**:
- Base: 10-100K/month per country
- Higher scores/relations: increase funding
- Poor performance: decrease funding
- Countries adjust monthly per threat assessment

### Income Sources

1. Country Funding (10-100K)
2. Mission Loot Sales
3. Raid Loot Sales
4. Manufacturing Output
5. Faction Tributes
6. Supplier Discounts

### Expenses

**Operational**:
- Equipment Purchases, Personnel Maintenance, Facility Maintenance, Base Operations, Craft Operations

**Strategic**:
- Black Market, Diplomacy, Fame Maintenance, Corruption Tax (per-base surcharge)
- Inflation Tax (credits > 20× monthly income)

### Monthly Cycle

**Week 1**: Revenue collection (+10% per week over month)
**Week 2-3**: Operational costs (personnel, facilities, craft)
**Week 4**: Financial report (balance, deficits, adjustments)

### Financial Crisis

**Levels**:
1. Deficit: Credit from suppliers (-1 relation)
2. Debt: Interest applied, -2 relations
3. Withdrawal: Countries reduce funding 50%
4. Bankruptcy: Debt exceeds 200K, organization dissolved

---

## Lore & Faction System

### Factions

**Definition**:
- Independent enemy organizations with distinct goals
- Autonomous operations, unique units/research/missions
- Defeat one ≠ affects others
- Stronger factions emerge over time

**Components**:
- Unit classes, Campaign system, Resource tree
- Technology research, Mission generation, Story arc

### Race Classification

**System**:
- Each unit class = specific race
- UI filtering and organization
- NO statistical bonuses from race
- Thematic diversity without mechanical advantage
- Factions employ 1-3 races typical

### Campaign System

**Structure**:
- Duration: 6-10 weeks per campaign
- Missions: ~5 per campaign
- Scheduling: Predetermined intervals (Week 1, 3, 6, 7, 9 typical)
- Regional focus: Target specific regions
- New campaign initiates monthly

**Escalation**:
- Base: 2 campaigns/month (Q1)
- Rate: +1 per quarter (Q2=3, Q3=4, Q4=5, cap 10)
- Multiple factions compound escalation
- Failed defenses unlock bonus campaigns

**Regional Preferences**:
- Asian: 80% in Asia | American: 70% in North America | European: Balanced global
- Specialization affects mission selection/intensity

**Difficulty**:
- Early (Month 1): Basic, standard units
- Mid (Months 2-6): Intermediate, upgraded
- Late (6+ months): Advanced, elite units
- Simultaneous campaigns = exponential pressure

### Mission Types (Lore)

**Site Missions**:
- Temporary (7-14 day timer)
- Static location
- Disappears if ignored

**UFO Missions**:
- Mobile craft executing script
- 3-14 days typical
- Points at each script step
- Can evade interception

### Quest System

**Framework**:
- Optional time-limited (2 weeks - 6 months)
- 3-5 simultaneous active
- No failure penalty (simply expire)
- Scales with org level
- Bonus rewards

**Categories**:

| Type | Duration | Example | Reward | Difficulty |
|------|----------|---------|--------|-----------|
| Military | 2-4w | 5 UFOs | +2 PP | Med |
| Economic | 1-2m | 50K credits | +1K | Low |
| Diplomatic | 4-8w | +50 relation | +5 fame | Med |
| Organizational | 2-3m | 3 bases | +3 PP | Med-High |
| Research | 3-6m | 5 projects | +2K | Med |
| Heroic | Variable | Alien base | +5 PP, +50 fame | High |
| Regional | 1m | 90% control | +500 credits | High |
| Survival | 2-4w | Defend 1m | +3 PP | Variable |

### Event System

**Framework**:
- Frequency: 2-5/month (scales with org level)
- Timing: Unpredictable (rolled daily)
- Impact: Multiple systems (cascading)
- Branching: Multiple outcome options
- Persistence: Some multi-month effects

**Event Categories** (5 types):
1. **Economic** (30%): Boom, Crash, Bonus, Crisis, Windfall, Tax Reduction, Investment
2. **Personnel** (25%): Surge, Desertion, Morale Crisis, Legend Soldier, Injury, Breakthrough, Advisor
3. **Research** (15%): Breakthrough, Setback, Failure, Espionage
4. **Diplomatic** (15%): Betrayal, Alliance, Funding Change, Peace, War
5. **Operational** (15%): Supply Delay, Facility Damage, Craft Malfunction, Scandal, Disaster

---

## Equipment & Items System

### Item Categories

**Resources** (Strategic Materials):
- Fuel (craft travel power), Energy Sources (facility/weapon power), Construction Materials (base building)
- Biological Materials (research), Alien Materials (advanced tech)
- Resource phases: Early Human (Fuel 5K, Metal 3K), Advanced Human (Fusion 50K), Alien War (Elerium 200K)
- Acquisition: Missions, trading, synthesis (Metal + Fuel → Titanium), black market suppliers

**Weapons**:
- Pistols (8 hex, 1-2 AP, 70% accuracy, 12 damage), Rifles (15 hex, 2 AP, 70%, 18 damage)
- Sniper Rifles (25 hex, 3 AP, 85%, 35 damage), Shotguns (4 hex, 2 AP, 60%, 45 damage)
- Special weapons: Grenades (1 AP, 30 damage, area), Mines (2 AP, 40 damage, triggered), Flares, Flashbangs, Medikit (1 AP, 25 HP Medic/15 others, 5 charges)
- Firing modes: Snap Shot (-20% acc, 1 AP), Aimed (+20%, 3 AP), Burst (-10%, 3 AP), Auto (-20%, 4 AP)

**Armor**:
- Light Scout (STR 5, +1 hex speed, 0 AP penalty, 5 armor, +5% accuracy, 8K)
- Combat Armor (STR 7, -1 hex, -1 AP, 15 armor, -5% acc, 15K)
- Heavy Assault (STR 10, -2 hex, -2 AP, 25 armor, -10% acc, 25K)
- Hazmat/Stealth/Medic/Sniper variants with specialized properties
- Armor Value represents damage reduction (1 = 1 damage absorbed)

**Craft Equipment** (Mounted Systems):
- Weapons: Point Defense (20km, 15 damage), Main Cannon (20km, 40 damage), Missile Pod (60km, 80 area), Laser Array (40km, 60/turn), Plasma Caster (30km, 70 damage)
- Defenses: Energy Shield (+10 HP, +20 energy), Ablative Armor (50% explosive, degrades), Reactive Plating (resistances)
- Support: Afterburner (+1 speed), Fuel Tank (+50% range), Cargo Pod (+10 capacity), Radar (+100% detection)

**Lore Items** (Story Objects):
- Non-mechanical collectibles, zero weight, enable research branches, narrative progression

### Equipment Class Synergy System

**Equipment Classes**:
- Light: High mobility, low protection (Pistols, Scout armor, SMG)
- Medium: Balanced (Rifles, Combat armor, standard weapons)
- Heavy: High protection, low mobility (Heavy Cannon, Heavy armor, power armor)
- Specialized: Unique properties (Plasma, Hazmat, Medic, Sniper)

**Class Matching Bonuses**:
- Light + Light: +10% accuracy, +15% speed, -5% armor
- Medium + Medium: 0% modifiers (baseline)
- Heavy + Heavy: -10% accuracy, -15% speed, +20% armor
- Specialized: Variable per item

**Class Mismatch Penalties**:
- Light + Heavy weapon: -15% accuracy, -15% armor
- Heavy + Light weapon: -5% accuracy, -20 TU movement
- Medium + Mismatched: -7% accuracy

**Armor Effectiveness Formula**: Final = Base × (1 + (Class-1) × 0.25) × Synergy Mod

### Weapon Properties

**AP/EP Costs**: Actions Point (turn timing) and Energy Point (resource) requirements
- Higher AP weapons slower but potentially more powerful
- EP depletion from heavy weapons creates tactical timing decisions

**Accuracy Modifiers**: Range (0-2x), Mode (0.7-1.3x), Cover (0.7-1.0x), LOS (0.8-1.0x)
- Calculated multiplicatively, clamped 5-95% final result

**Damage Types**: Kinetic, Energy, Explosive, Psionic, Hazard
- Each armor type has resistances to specific damage types

**No Critical Hits**: Damage is consistent; success rewarded through positioning and type choice

### Prisoners (Lore Items)

**Mechanics**:
- Created when enemies captured (HP >0 at mission end)
- Store in Prison facility, limited capacity
- Lifetime: 30 + (Unit Max HP × 2) days (stronger survive longer)
- 1% escape chance per prisoner per day

**Options**: Execute (-5 karma), Interrogate (±0), Experiment (-3), Exchange (+3), Convert (60%), Release (+5)
- Living prisoners reveal unit class (interrogation)
- Corpse research cheaper than living prisoners

---

## Damage Types & Armor System

### 8 Core Damage Types

**1. Kinetic** (Firearms, melee impact):
- Light Armor: 50% reduction | Medium: 30% | Heavy: 10% | Shield: 0%

**2. Explosive** (Grenades, mines, blast):
- Light: 40% | Medium: 20% | Heavy: 5% | Shield: 50%
- **Explosion Mechanics**:
  - Walls: 100% damage block (no penetration to hexes beyond)
  - Units: 50% blocked, wave continues to adjacent units
  - Wave propagation: Independent directions, distance penalties (100%→80%→60%→40%)
  - Multiple waves bypass single units

**3. Energy** (Plasma, directed beams):
- Light: 20% | Medium: 40% | Heavy: 60% | Shield: 90%

**4. Psi** (Alien mental attacks):
- All armor: 0% reduction | Psi Shield: 80%
- Bypasses physical protection entirely

**5. Stun** (Shock weapons, non-lethal):
- Light: 70% | Medium: 50% | Heavy: 30% | Shield: 40% | Insulated: 95%
- Applies Stun status (accumulates, -1/turn decay, threshold trigger)

**6. Acid** (Corrosive attacks):
- Light: 30% | Medium: 50% | Heavy: 70% | Shield: 0% | Acid-Resistant: 85%
- Applies Corrosion (reduces armor on subsequent hits)

**7. Fire** (Thermal/burning):
- Light: 20% | Medium: 40% | Heavy: 60% | Shield: 0% | Fire-Resistant: 90%
- Applies Burning status (damage over time, spreads)

**8. Frost** (Freezing attacks):
- Light: 40% | Medium: 50% | Heavy: 30% | Shield: 10%
- Applies Frozen status (movement penalty, accuracy penalty)

### Armor System

**Base Armor Value**: Damage reduction points (1 point = 1 damage absorbed)
**Class Modifiers**: Light (×1.0), Medium (×1.25), Heavy (×1.5), Specialized (varies)
**Synergy Effects**: Matched equipment +20% armor, mismatched -15%
**Degradation**: Some armor types degrade with hits (ablative armor)
**Shield Mechanics**: Energy shields drain power but provide strong defense

---

## Environment & Terrain System

### Terrain Types

**Floor** (Walkable):
- Base: 1 AP per hex | Modifiers: Weather, encumbrance, status effects
- Types: Grass (standard), Concrete (fire-resistant), Dirt (mud in rain), Ice (slippery), Metal (conductive)

**Walls** (Blocked):
- Cost: Impassable | Sight: 100% blocked | Fire: Completely blocked
- Subtypes: Stone (indestructible), Wooden (20 HP, burns), Metal (50 HP, fire-resistant), Glass (5 HP, transparent)

**Water**:
- Shallow: 2 AP/hex | Deep: 3 AP or impassable (unit-dependent)
- Flying units: No penalty | Aquatic units: Reduced cost
- Combat: Partial cover (20-40%), -10% accuracy penalty, extinguishes fire

**Difficult Terrain** (Dense Vegetation):
- Cost: 2-3 AP per hex | Sight: +1-2 sight cost | Cover: 20-40%
- Forest (2 AP, +1 sight, 20%), Dense Forest (3 AP, +2 sight, 40%), Rubble (2 AP, 30% cover), Swamp (3 AP, sanity -1/5 turns)

**Cover** (Partial Protection):
- Low Wall: 1-2 AP, 40-80% cover | Sandbags: 1 AP, 60% cover | Buildings: 1-3 AP, 80-100% cover
- Partial cover: Blocks partial LOS/LOF, improves accuracy slightly, reduces incoming damage modifier

### Environmental Hazards

**Smoke** (Area Denial):
- LOS block: 20% | No damage | Duration: 3-8 turns | Spread: 30%/turn to adjacent hexes
- Source: Grenades, explosions, cover fire

**Fire** (Terrain Hazard):
- Damage: -5 HP/turn to units in tile | Spread: Adjacent tiles 20-30%/turn if flammable
- Extinguish: Water terrain, medikit (1 AP), suppression (dedicated action)
- Intensity: Low (1 damage), Medium (3 damage), High (5+ damage)

**Gas** (Cumulative Toxin):
- Damage: -1 HP/turn per gas layer | Visibility: 50% block at 3+ layers
- Dissipation: Wind effect, time-based dispersal, active venting
- Types: Poison (HP damage), Paralytic (movement penalty), Disorientation (accuracy penalty)

**Hazardous Terrain** (Environmental Damage):
- Lava: -10 HP/turn in tile, impassable without special equipment
- Radiation: Stun damage accumulation, -Sanity effects
- Contamination: Disease spread mechanic (affects morale/sanity)

### Weather System

**Clear** (Baseline):
- Visibility: 100% | Movement: No penalty | Accuracy: 100%

**Rain** (Moderate):
- Visibility: 75% | Movement: +1 AP/hex (mud) | Accuracy: -10%
- Effect: Extinguishes fire immediately, temporary water pools

**Storm** (Heavy):
- Visibility: 50% | Movement: +2 AP/hex | Accuracy: -20%
- Effect: Zero fire spread, blinding wind, disorientation (-5% accuracy)

**Snow** (Severe):
- Visibility: 25% | Movement: +3 AP/hex | Accuracy: -25%
- Effect: Temperature damage (-1 stun/turn), slippery terrain

**Blizzard** (Extreme):
- Visibility: 0% (map blackout) | Movement: +4 AP/hex | Accuracy: Impossible
- Effect: Units frozen, mission abort option, survival mechanic

### Day/Night Cycle

**Day** (Baseline):
- Visibility: 100% | No penalties | Normal combat

**Dusk** (-10% visibility):
- Slight darkness, increased shadows, minor perception penalty

**Night** (50% visibility):
- Requires night vision or light sources | -50% accuracy base
- Night vision goggles enable normal visibility
- Light sources create detection risk (enemies see player earlier)

**Pitch Black** (0% vision):
- Requires night vision + light source or special ability
- Movement cost +2/hex (blind navigation)
- Only radar/thermal imaging effective

### Destructible Terrain

**Destruction Mechanics**:
- Explosive weapons damage terrain (AoE), creating new paths
- Wall destruction: Creates rubble/opening for movement
- Terrain destruction: Changes LOS/LOF, creates tactical opportunities
- Rubble: Difficult terrain (2 AP cost, 30% cover)

**Tactical Impact**:
- Environment shaping through combat
- Creating escape routes mid-battle
- Denying enemy lines of fire through destruction

### Biome System

**Urban** (City, Town):
- Terrain: Concrete, walls, buildings, tight corridors
- Cover: Abundant | Hazards: Fuel leaks (fire), electrical dangers
- Weather effect: Rain pools on streets

**Forest** (Wilderness):
- Terrain: Trees (difficult), grass (standard), water (streams)
- Cover: Dense vegetation (40%) | Hazards: Fire spread (high), disease (fauna)
- Weather effect: Snow blocks movement heavily

**Industrial** (Factory, Facility):
- Terrain: Metal, machinery, narrow passages
- Cover: Equipment, crates, metal structures
- Hazards: Electrical hazards, chemical spills

**Underwater** (Ocean, Lake, Cavern):
- Terrain: Water (3 AP), rocks (obstacles), trenches
- Cover: Rock formations, wreckage
- Hazards: Pressure damage, aquatic fauna, disorientation

---

## Country System & Diplomacy

### Country Classifications

**Major Powers** (5-8 per game):
- Examples: USA, China, Russia, EU Federation, India
- Funding: 40% more missions, +30 starting relation
- Role: Primary funding source

**Secondary Powers** (8-12 per game):
- Examples: Japan, Germany, Brazil, Canada, UK
- Standard mission frequency, balanced funding

**Minor Nations** (10-15 per game):
- Examples: New Zealand, Singapore, Cyprus
- Reduced mission frequency, modest funding

**Supranational Organizations** (2-3 per game):
- UN-XCOM Alliance, International Space Authority
- Generate diplomatic missions, never declare war

### Country Attributes

**Core Attributes**:
- Name, Nation Type, GDP (1-1000 scale), Military Power (1-10 rating)
- Starting Relation (-50 to +50), Base Funding Level (1-10)
- Region (geographic grouping), Capital Province

**Dynamic Properties**:
- Current Relation (-100 to +100, affects funding/missions)
- Panic Level (0-100, triggers loss at 100+)
- Funding Level (1-10, % GDP to defense)
- Stability (0-100, affects mission generation)
- Military Readiness (0-100, affects alien attacks)
- Morale (0-100, public support, affects panic)

### Regional Blocs

**Geographic Regions**:
- North America: USA, Canada, Mexico
- South America: Brazil, Chile, Colombia
- Europe: EU nations grouped
- Middle East: Diverse, regional tensions
- Asia-Pacific: China, India, Japan, ASEAN
- Africa: Regional bloc

**Regional Effects**:
- Regions share panic/morale
- Regional stability affects UFO frequency
- Collective defense efforts provide bonuses
- Regional bloc relations cascade

### Funding System

**Calculation**: Country GDP × Funding Level (1-10) × Relation Modifier (0.5-1.5)
- Result: 10-100K/month per country
- Higher relations increase funding
- Poor performance decreases funding

**Funding Mechanics**:
- Baseline: 10-100K/month per country
- Relation adjustments: ±10-20K based on performance
- Crisis funding: Half funding if country's panic >80
- Bonus funding: +10K if country terror prevented

---

## Enhanced Economy System

### Research System

**Requirements**:
- Research facility with scientist capacity
- Prerequisite research completion
- Specific resources/components
- Credits to fund work

**Mechanics**:
- Progress: Scientist man-days (e.g., 30 man-days at 5/day = 6 days)
- Scientists paid only for active days
- Repeatable projects: Item analysis (alien prisoners), autopsies
- Research types: Technology, Item Analysis, Interrogation, Autopsy, Facility Upgrades
- Pause/Resume capability without progress loss

**Cost Scaling**:
- Base cost: 50-500 man-days typical
- Multiplier: 50%-150% (randomly determined per campaign for replayability)
- Unique ranges per project (Basic Rifle: 50-150 man-days)
- Facility bonuses: -10-30% research time
- Scientist specialization: +10% efficiency per related project

**Research Progression Phases**:
- Early: Unlocks basic manufacturing
- Mid-tier: Specialized equipment, advanced facilities
- Late-tier: Endgame weaponry, tactical advantages
- Alien branch: Requires captured aliens, unique dependencies

### Technology Tree (5 Branches)

**1. Weapons Technology**:
- Tier 1: Basic Firearms (0 man-days), Explosives (50), Melee (30)
- Tier 2: Precision Firearms (100), Heavy Ordnance (150), Incendiary (120)
- Tier 3: Laser (200), Plasma (300), Particle Beam (400)

**2. Armor & Defense**:
- Light armor research, Heavy armor research, Specialized suits
- Shield technology, Reactive plating, Advanced materials

**3. Alien Technology**:
- Alien Power Systems, Plasma Samples, Advanced Materials
- UFO Propulsion, Alien Weapons, Dimensional Tech

**4. Facilities & Infrastructure**:
- Facility upgrades (+10-30% efficiency)
- Power generation, Storage expansion, Radar systems

**5. Support Systems**:
- Medical research, Psychological support, Transportation
- Communication systems, Detection technology

### Manufacturing System

**Mechanics**:
- Requires researched technology + blueprint
- Consumes resources (metal, fuel, electronics, etc.)
- Takes time (production queue)
- Limited workshop capacity

**Profit Margins**:
- Cost: Research + Materials + Labor
- Value: Market price or player usage
- Reinvestment strategy: Convert resources → equipment → credit profit

**Manufacturing Types**:
- Equipment manufacturing (weapons, armor, consumables)
- Crafting chains (multiple components required)
- Batch production with efficiency scaling

### Marketplace

**Mechanics**:
- Buy/Sell equipment and resources
- Research-gated availability (unlocked items only)
- Phase-based pricing (changes across campaign phases)
- Supplier reputation affects prices

**Pricing**:
- Early phase: Premium prices, limited selection
- Mid phase: Balanced pricing, wider selection
- Late phase: Competitive prices, full catalog available

### Black Market

**Characteristics**:
- Access tiers by Karma/Fame
- 5 purchase categories (Weapons, Armor, Resources, Vehicles, Exotic)
- High cost (premium pricing), reputation risk
- Corpse trading (ethical concern, karma impact)
- Alien resources availability (circumvent research gates)

### Supplier System

**Mechanics**:
- Establish contracts with factions for steady income
- Trade relationships affect pricing and availability
- Supply delays create resource management tension
- Supplier dynamics: Relations affect negotiating power

**Supply Transfer**:
- Move equipment between bases (time/cost)
- Direct transfer via transport craft
- Maintenance costs during transfer

### Salvage System

**Recovery Mechanics**:
- Loot from defeated enemies (weapons, armor, resources)
- Crashed UFO salvage (alien materials)
- Mission site salvage (debris, components)
- Corpse recovery and processing

**Processing**:
- Sell for credits, research for knowledge, or use directly
- Inventory management: Storage capacity limitations
- Decay mechanics: Some salvage loses value over time

---



### Strategic AI (Geoscape Level)

**Faction AI Behavior**:
- Autonomous faction operations with independent strategic goals (attack strategy, base building, diplomacy, resource management)
- Faction Decision Algorithm: Assess player threat → Evaluate resources → Choose action (Aggressive/Maintain/Expand) → Execute missions
- Escalation Meter: Campaign points accumulate (Thresholds: 0-10 early, 10-25 mid, 25-50 late, 50+ crisis/UFO armada)
- Base Progression: Factions build/upgrade bases (3-5 maximum by endgame) with generated missions per level (1-5/week based on level)
- Tactical Adaptation: Deploy hard-counters to dominant player unit compositions

**Country & Supplier AI**:
- Country Behavior: Funding bonuses/reductions based on win streak/losses, hostility shifts based on fame, territorial claims during attacks
- Supplier Behavior: Inventory/pricing varies by relationship (Allied +50% stock/-10% price, Hostile -50% stock/+15% price, Betrayal possible)
- Mission Generation Scaling: Difficulty = Base + (Campaign_Month × 0.2) + (Base_Count × 0.15) + (Avg_Unit_Level × 0.1)

### Operational AI (Interception Level)

**UFO Behavior States**:
- Aggressive (HP >50%): Pursue and attack every turn
- Tactical Withdrawal (HP 25-50%): Maintain distance, selective attacks
- Escape (HP <25% or 2:1 outnumbered): Flee toward objective/edge
- Defensive (Defending base/cargo): Hold position, return fire

**UFO Attack Resolution**: Calculate survival odds → If >60% attack, 30-60% tactical withdrawal, <30% escape

### Tactical AI (Battlescape Level)

**Side-Level Strategy**:
- Faction alignment rules (Player/Enemy/Ally/Neutral)
- Strategy selection based on mission objective, relative strength, terrain advantage, unit health
- Chosen strategies: Aggressive (frontal assault), Tactical (flanking), Defensive (hold positions), Retreat (staged withdrawal)

**Team Coordination** (2-4 squads per team):
- Assault squads: Heavy weapons, close combat
- Support squads: Medics, engineers, ammo
- Flanking squads: Mobile, accurate shooters
- Defense squads: Static positioning, heavy fire
- Turn coordination: Assess situation → Identify opportunities → Coordinate actions → Evaluate outcomes

**Squad Formation Mechanics**:
- Line: Spread horizontally (high firepower, flanking exposure)
- Column: Single file (medium firepower, narrow corridors)
- Wedge: Triangle apex (balanced approach)
- Cluster: Tight group (defensive position)
- Dispersed: Maximum spread (defensive holding)

**Unit State Machine**:
- Idle → Alert → Move → Engage → Suppressed → Reaction Fire
- Pathfinding toward waypoint while maintaining formation

**Unit Confidence System** (0-100%):
- Base: 60%, decays -5% per casualty/-3% per suppression/-2% per turn
- Gains: +3% per hit/+5% per elimination/+2% per objective/+1% per nearby ally
- Behavioral effects: 0-20% terrified, 21-40% frightened, 41-60% normal, 61-80% aggressive, 81-100% dominant
- Affects movement, combat approach, accuracy (+10 to +20% at high confidence, -15 to -30% at low), retreat threshold

**Unit Target Selection Algorithm**:
- Priority Score = (Threat_Level × 0.5) + (Distance_Factor × 0.3) + (Exposure_Factor × 0.2)
- Threat_Level per unit (Grunt 30, Warrior 50, Specialist 70, Heavy 90, Elite 100)
- Distance factors (within 2: 100, 3-5: 70, 6-10: 50, 11+: 20)
- Exposure factors (no cover 100, partial 60, full 30, obscured 20)
- Final score 0-100 (>80 immediate priority, 50-80 primary, 20-50 secondary, <20 ignore)

---

## Research & Manufacturing Economy System

### Research Projects Framework

**Research Mechanics**:
- Cost: Base (50-500 man-days) × multiplier (50-150% randomly determined at campaign start)
- Requirements: Research items, lab facility, scientist capacity, prerequisite research completion, credits
- Progress: Man-days assigned → daily progress → percentage completion (example: 30-day project with 5 assigned = 6 days to complete)
- Types: Technology (unlock capabilities), Item Analysis (+20% equipment understanding), Alien Interrogation (faction knowledge), Autopsy (alien biology), Facility Upgrade (+10-30% efficiency), Hybrid (combine streams)
- Scientists: Paid only for work days, gain +10% efficiency per completed related research, diminishing returns (5th = 80%, 10th = 60%)
- Pause/Resume: Can halt without losing progress
- Failure: No failure mechanic, can be cancelled for 50-75% refund

**Research Cost Scaling**:
- Scientist allocation controls pace
- Multiple simultaneous tracks compete for resources
- Early bottleneck (2-5 scientists), mid-game (5-10), late-game (15+)
- Tier times: Tier 1 avg 30-80 days (3-8 days /10 scientists), Tier 2 avg 100-200 days, Tier 3 avg 250-400, Tier 4 avg 500-600

### Research Technology Tree (5 Branches)

**Branch 1 - Weapons Technology**:
- Tier 1 (Starting): Conventional Firearms (0), Explosives (50), Melee (30)
- Tier 2 (100-150): Precision Firearms, Heavy Ordnance, Incendiary
- Tier 3 (200-400): Laser, Plasma, Particle Beam
- Tier 4 (500-600): Psionic Amplification, Gravitational Weapons

**Branch 2 - Armor & Defense**:
- Tier 1: Body Armor (0), Tactical Vests (40)
- Tier 2 (120-180): Composite Armor, Powered Exoskeletons
- Tier 3 (250-350): Alien Alloys, Energy Shields
- Tier 4 (500-600): Psi-Shields, Titan Armor

**Branch 3 - Alien Technology**:
- Tier 1 (80-150): Alien Materials Analysis, Alien Autopsy (per species), UFO Construction
- Tier 2 (200-250): Alien Power Systems, UFO Navigation
- Tier 3 (280-300): Elerium-115, Alien Computers
- Tier 4 (400): Hybrid Technology

**Branch 4 - Facilities & Infrastructure**:
- Tier 1 (50-60): Advanced Engineering, Logistics Management
- Tier 2 (120-180): Psionic Laboratory, Advanced Workshop, Genetic Laboratory
- Tier 3 (300-350): Hyperwave Decoder, Grav-Shield

**Branch 5 - Support & Utility**:
- Tier 1 (40-50): Medical Training, Tactical Training
- Tier 2 (150-180): Cybernetics, Genetic Engineering
- Tier 3 (250-300): Psionic Training, Neural Interface

**Research Strategy Profiles**:
- Balanced: 30% Weapons/30% Armor/20% Alien/10% Facilities/10% Support
- Aggressive: 50% Weapons/20% Alien/20% Armor/10% Support
- Defensive: 40% Armor/25% Facilities/20% Support/15% Weapons
- Scientific: 50% Alien/20% Facilities/15% Weapons/15% Armor

**Special Research** (Repeatable):
- Alien Interrogation (50-120 man-days per species): Extract tactical/tech/objectives information
- Facility Research (150-350 man-days): Mind Shield, Alien Containment, Fusion Ball Launcher
- Strategic Research: Hyperwave Decoder (300), Avenger Construction (500), Cydonia/Bust (final mission)

### Manufacturing Projects

**Manufacturing Mechanics**:
- Production: Time-based (item type determines hours/units), queued system
- Efficiency: Base rate affected by facility level, scientist/engineer assignment, batch bonuses
- Batch Bonus: +5-10% when manufacturing 5+ units of same item
- Quality: Manufacturing from research reduces cost vs. marketplace purchase
- Interruption: Can pause without penalty
- Profit Margin: Manufactured goods 40-60% cheaper than marketplace (incentivizes manufacturing)

### Marketplace & Supplier System

**Marketplace Framework**:
- Items: Weapons, armor, consumables, crafts, facility components, lore items
- Pricing: Varies by supplier relationship, item rarity, demand
- Availability: Affected by supplier relations, stock limits per supplier
- Purchase: Direct sale, limited inventory per cycle
- Restrictions: Some items require research completion before purchase

**Supplier System**:
- Suppliers: Each specializes in item category (Weapons, Armor, Support, Exotic, etc.)
- Relationship Mechanics: Allied suppliers +50% stock/-10% price, Neutral standard, Hostile -50% stock/+15% price
- Betrayal Possibility: Hostile supplier can block access for 2 weeks
- Special Events: Supplier offers periodic limited items at special prices
- Transfer Mechanics (A3): Items transferable between bases, travel time dependent on distance

### Salvage System

**Salvage Collection**:
- Source: Defeated enemies, destroyed objectives, mission rewards, UFO wreckage
- Types: Equipment (weapons, armor), Resources (materials, components), Currency (credits), Technology (research items)
- Processing: Salvage converted to usable inventory at base
- Resale: Salvaged equipment can be sold on marketplace at 40-60% of new cost
- Research Value: Some salvage items enable new research paths (alien tech samples)

### Transfer System (Logistics)

**Supply Transfer Mechanics**:
- Enables movement of equipment/resources between bases
- Travel Time: Depends on distance between bases and craft speed
- Cost: Fuel for transport craft (calculated per distance)
- Timing: Transfer queued, completes when craft reaches destination
- Restrictions: Cannot transfer during active combat at receiving base
- Strategic Use: Redistribute equipment between bases, consolidate resources

### Research Dependencies & Integration

**Dependency Enforcement**:
- Prerequisites block research (cannot start until dependencies complete)
- Technology gates equipment unlock (must research before manufacturing)
- Alien Tech locks behind corpse/equipment capture (Cannot research Alien Materials without captured aliens)
- Cross-Branch Dependencies: Energy weapons require both Precision Firearms AND Alien Power Systems
- Circular Dependency Prevention: Tree designed to prevent impossible loops

---

## Quest System

### Quest Framework
- **Definition**: Optional time-limited objectives providing bonus rewards upon completion
- **Duration Range**: 2 weeks to 6 months, varies by quest type
- **Multiple Quests**: 3-5 quests can be active simultaneously
- **Failure Consequence**: None (quests simply expire without penalty)
- **Difficulty Scaling**: Quest complexity increases with player organization level

### Quest Categories

| Quest Type | Duration | Objective Example | Reward | Difficulty |
|-----------|----------|------------------|--------|-----------|
| **Military** | 2-4 weeks | Destroy 5 UFOs in region | +2 Power Points | Medium |
| **Economic** | 1-2 months | Earn 50K credits | +1000 credits | Low |
| **Diplomatic** | 4-8 weeks | Achieve +50 relation with country | +5 fame | Medium |
| **Organizational** | 2-3 months | Build 3 bases | +3 Power Points | Medium-High |
| **Research** | 3-6 months | Complete 5 research projects | +2000 credits | Medium |
| **Heroic** | Variable | Destroy alien base | +5 Power Points, +50 fame | High |
| **Regional** | 1 month | Dominate region (90% control) | +500 credits, +1000 points | High |
| **Survival** | 2-4 weeks | Defend bases for full duration | +3 Power Points | Variable |

### Quest Integration
- **Trigger Sources**: Random events, faction actions, player achievements
- **Verification**: Checked daily at campaign dawn cycle
- **Optional Nature**: Allows players to focus on core campaign or secondary progression
- **Supplementary Rewards**: Support other progression systems (funding, research, Power Points)

---

## Event System

### Random Events Framework
- **Frequency**: 2-5 events per month (scales with organization level)
- **Randomness**: Unpredictable timing (rolled daily) and nature (weighted random)
- **Impact Scope**: Can modify multiple systems (cascading effects)
- **Branching**: Some events have multiple outcome options (player choice)
- **Persistence**: Some create lasting multi-month consequences

### Event Categories & Examples

**Economic Events** (30% frequency):
- Market Boom: -20% marketplace prices for 1 month
- Market Crash: +30% marketplace prices for 1 month
- Supplier Bonus: 50% discount on one supplier for 2 weeks
- Inflation Crisis: +15% manufacturing costs for 1 month
- Economic Windfall: +10,000 credits (random discovery)
- Tax Reduction: +15% monthly income for 2 months
- Investment Opportunity: Spend 5K for +500/month passive (5-month commitment)

**Personnel Events** (25% frequency):
- Recruitment Surge: +3-8 random soldiers available this month
- Unit Desertion: 1-3 soldiers leave organization (morale-driven)
- Morale Crisis: All units -20% XP gain for 2 months
- Legendary Soldier: Hero-tier soldier available (high cost)
- Personnel Injury: Unit at 50% effectiveness for 1 month
- Training Breakthrough: All units +1 rank immediately (rare)
- Advisor Recruitment: Special advisor available at +50% cost

**Research Events** (15% frequency):
- Breakthrough: Active research +2 weeks progress
- Setback: Active research -1 week progress
- Equipment Failure: Random equipment destroyed or damaged
- Espionage Success: Steal alien tech (research shortcut)

**Diplomatic Events** (15% frequency):
- Betrayal: Country withdraws support (-50K/month income)
- Alliance Offer: New country funding opportunity
- Funding Change: Existing country ±5-15% funding
- Faction Peace: Temporary truce with faction (-30% mission frequency)
- Faction War: Escalation with faction (+30% mission frequency)

**Operational Events** (15% frequency):
- Supply Delay: Manufacturing delayed 2 weeks
- Facility Damage: Random base facility takes 20-50 damage
- Base Incident: Security breach, morale penalty
- Equipment Loss: Random inventory item destroyed
- Craft Malfunction: Craft unavailable for repairs (1-2 weeks)

---

## Finance & Economy System

### Debt & Loan System
- **Loan Mechanics**: Players can borrow 100K credits per loan (5% monthly interest, compounding)
- **Mandatory Repayment**: Loan principal must be repaid before interest escalates
- **Maximum Debt Ceiling**: 500K credits total debt limit
- **Debt Consequences**: Debt >100% annual income triggers -10% monthly funding, -1 relations/month with all countries
- **Bankruptcy Trigger**: Debt >500K OR cash <-50K (liquidates 50% equipment, 25% units, -20 relations all countries)

### Monthly Budget Cycle
- **Week 1**: Revenue collection (country funding +10%/week, marketplace sales, supplier payments)
- **Week 2-3**: Operations phase (-25% personnel, -25% facility, -25% craft maintenance per week)
- **Week 4**: Final settlement (equipment purchases, research bonuses, manufacturing revenue, loan interest)

### Cash Flow Forecasting
- **Projection**: Automatic 3-month cash flow forecast
- **Warning Threshold**: Cash <1 month expenses (yellow warning)
- **Critical Threshold**: Cash <1 week expenses (red alert)
- **Bankruptcy Risk**: Cash <0 (flashing red crisis)

### Financial Reporting
- **Monthly Statement**: Total revenue, expenses, net profit/loss, cash reserves, debt status, 3-month forecast
- **Revenue Breakdown**: Country funding, marketplace sales, manufacturing, suppliers, tributes, faction payments
- **Expense Breakdown**: Personnel, facilities, crafts, equipment purchases, black market, diplomacy, fame maintenance, corruption tax
- **Corruption Tax**: Per-base surcharge when operating excessive bases (incentivizes consolidation)
- **Inflation Tax**: Applied when credits >20× monthly income (prevents hoarding)

### Financial Crisis Management
- **Deficit Phase**: Months 1-3 intentionally deficit (education phase expected to lose money)
- **Breakeven Target**: Month 4-6 should achieve surplus
- **Bankruptcy Prevention**: Severe penalties for maintaining deficit beyond Month 6
- **Recovery Strategy**: Win high-reward missions, sell marketplace equipment, reduce unit count, defer research

---

## Victory & Defeat System

### Primary Victory Condition: Mothership Elimination
- **Trigger**: Eliminate mothership + 95%+ alien infrastructure
- **Timeline**: Month 15+ (earliest possible after sufficient buildup)
- **Prerequisites**:
  - Alien threat 90%+ (fully mobilized)
  - Mothership location discovered (missions or research)
  - Elite military capability (endgame weapons, veteran units)

### Mothership Assault Sequence
- **Phase 1 (Air Combat)**: Intercept mothership in transit, reduce to 30% HP (infiltration ready state)
- **Phase 2-5 (Ground Assault)**: 4-5 sequential battles within mothership (external, cargo, engineering, command, core)
- **Phase Structure**: Each phase 20-25 turns with reinforcements possible, cumulative casualties permanent
- **Final Phase (Automated)**: Place charges or activate self-destruct (cinematic explosion)
- **Victory Requirements**: 4 consecutive battle wins OR mothership commander capture/surrender

### Endgame Cinematics & Scoring
- **Victory Sequence**: Mothership explosion → global radar clear → worldwide celebrations → organization leader final scene (3-5 minutes)
- **Campaign Statistics**: Playtime, missions completed, units trained/killed, bases built, research %, panic level, countries saved/betrayed, alien kills
- **Final Verdict Screen**: Organization name, total campaign duration, personnel report, operations summary, military achievements, global impact, technology completed, final rating
- **Ending Quality**: Good (alien defeat + high score/karma), Neutral (victory with costs), Bad (coexistence/pyrrhic), Failure (extinction/bankruptcy)

### Loss Conditions

**Loss Condition 1: Global Panic Reaches 100%**
- Panic increases: Failed mission +5-15%, alien raid +20%, country loss +10%, UFO base +5%, tech surpass +10%, panic event +5-20%
- Panic decreases: Success mission -2-5%, breakthrough -3-5%, base destroyed -10%, mothership located -5%
- Consequence: UN dissolves, funding cut, troops mutiny, bases go silent, aliens occupy Earth unopposed (game over)

**Loss Condition 2: All Bases Destroyed**
- Result: Organization homeless, no facilities, no manufacturing, no research
- Consequence: Immediate game over (no recovery path)

**Loss Condition 3: Budget Bankruptcy (-1,000,000 credits)**
- Deficit spending triggers when monthly expenses exceed monthly income
- Warning: Normal Months 1-3, serious concern Month 6+, automatic game over Month 12+ if unresolved
- Consequence: Creditors seize assets, troops desert, immediate game over

**Loss Condition 4: Complete Funding Withdrawal**
- Trigger: All country funding sources eliminated
- Survival: Mission rewards only (~5K-50K/month, highly variable)
- Sustainability: Requires 100% mission success + average 50K reward (nearly impossible)
- Timeline: 4-month countdown to absolute game over

### Bad Ending: Stalemate/Coexistence
- **Condition**: Survive 96+ months without mothership elimination
- **Alien Threat**: Reduced to manageable 40-50%
- **Outcome**: Player and aliens establish peaceful coexistence (pyrrhic ending)
- **Narrative**: Humanity survives but fails to eliminate alien threat completely
- **Score Impact**: Reduced ending rating vs. true victory

---

# Mechanics Index (Alphabetical)

| Mechanic Name | System Layer | Purpose | Key File |
|---|---|---|---|
| **Accuracy Formula** | Battlescape | Hit resolution (all multiplicative: Base × Range × Mode × Cover × LOS) | Battlescape.md |
| **Accuracy (Interception)** | Interception | Craft weapon hit chance (clamped 5-95%) | UFO_and_Interception.md |
| **Achievement & Medal System** | Units | One-time achievements providing XP bonus | Units.md |
| **Advisor Conflict Resolution** | Diplomacy | Prevent advisor guidance conflicts (A9) | Politics_and_Factions.md |
| **Advisor System** | Diplomacy | Staff providing sustained bonuses (A9 spec) | Politics_and_Factions.md |
| **AI Confidence System** | Battlescape/AI | Unit confidence 0-100% affecting aggression/accuracy/tactics (+10-20% at high, -15-30% at low) | AI_Systems.md |
| **AI Side-Level Strategy** | Battlescape/AI | Faction alignment, strategy selection (Aggressive/Tactical/Defensive/Retreat) | AI_Systems.md |
| **AI Tactical AI** | Battlescape/AI | Unit state machine (Idle/Alert/Move/Engage/Suppressed/Reaction) | AI_Systems.md |
| **AI Team Coordination** | Battlescape/AI | Squad roles (Assault/Support/Flanking/Defense) with turn coordination | AI_Systems.md |
| **AI Unit Target Selection** | Battlescape/AI | Priority score formula (Threat×0.5 + Distance×0.3 + Exposure×0.2) | AI_Systems.md |
| **Black Market Access Tiers** | Economy/Diplomacy | Access gated by Karma (-100 to +100) and Fame (0-100) levels | Black_Market.md |
| **Black Market Corpse Trading** | Economy | Buy/sell fallen units/aliens with karma impact (varies by karma) | Black_Market.md |
| **Black Market Categories** | Economy | Items (200-500% markup), Units (mercenaries), Missions (high-risk), Events, Corpses | Black_Market.md |
| **Country AI Behavior** | Geoscape/AI | Funding bonuses/cuts based on player performance, hostility shifts, territorial claims | AI_Systems.md |
| **Craft Addon System** | Geoscape/Interception | 2 slots for upgrades: shields, armor, mobility, detection, utility systems | Crafts.md |
| **Craft Classification** | Geoscape | 7 classes (Scout, Interceptor, Transport, Fighter, Heavy Fighter, Bomber, Battleship) | Crafts.md |
| **Craft Crew System** | Geoscape/Interception | Pilot/Co-Pilot/Crew positions with different XP multipliers (100%/50%/25%) | Crafts.md |
| **Craft Fuel Management** | Geoscape | Automatic consumption by distance, craft size, cargo (1 + modifiers per hex) | Crafts.md |
| **Craft Maintenance** | Geoscape | Passive repair +10%/week, hangar upgrades improve rate to +20-30%/week | Crafts.md |
| **Craft Crashes** | Geoscape/Interception | Craft reaching 0 HP crashes, triggering rescue mission generation | Crafts.md |
| **Craft Storage Capacity** | Geoscape | Garage (1 slot), Hangar (4 slots); crafts without storage cannot deploy | Crafts.md |
| **Craft Weapon Configuration** | Geoscape/Interception | Exactly 2 hardpoints, heavy weapons consume both slots | Crafts.md |
| **Cross-Sector Combat** | Interception | Weapons determine valid target sectors (Air/Land/Underground) | UFO_and_Interception.md |
| **Damage (Interception)** | Interception | Craft weapon damage calculation (deterministic, NO armor reduction) | UFO_and_Interception.md |
| **Dual XP Tracking** | Units/Crafts | Each unit tracks Ground Combat XP + Pilot XP separately, independent progression | Crafts.md, Units.md |
| **Energy Point System** | Interception | Weapon/evasion/system energy pool; regeneration +2-5 EP/turn depending on craft | UFO_and_Interception.md |
| **Formation Positioning** | Interception | Player forces left side, enemy forces right side of engagement screen | UFO_and_Interception.md |
| **Sector Capacity** | Interception | Max 4 objects per sector (Air/Land/Underground); sectors visible simultaneously | UFO_and_Interception.md |
| **Thermal/Heat System** | Interception | Heat generation (5-20 per action), jam at 100+ heat; dissipation -5 to -15/turn | UFO_and_Interception.md |
| **Weapon Flight Time** | Interception | Range measured by turn delay (Close 5, Short 4, Medium 3, Long 2, Very Long 1 turn) | UFO_and_Interception.md |
| **Country AI Behavior** | Geoscape/AI | Funding bonuses/cuts based on player performance, hostility shifts, territorial claims | AI_Systems.md |
| **Faction AI Autonomy** | Geoscape/AI | Independent faction operations with distinct units, research, regional preferences | AI_Systems.md |
| **Faction Escalation Meter** | Geoscape/AI | Campaign points (+1 attack, -2 victory, -3 base destroyed) with escalation thresholds | AI_Systems.md |
| **Mission Difficulty Scaling** | Geoscape/AI | Formula: Base + (Month×0.2) + (BaseCount×0.15) + (AvgLevel×0.1) | AI_Systems.md |
| **Squad Formations** | Battlescape/AI | Line/Column/Wedge/Cluster/Dispersed with distinct tactical characteristics | AI_Systems.md |
| **Supplier AI Behavior** | Geoscape/AI | Dynamic inventory/pricing based on relationship (Allied +50% stock/-10%, Hostile -50% stock/+15%) | AI_Systems.md |
| **Unit Action Point System** | Battlescape | Base 4 AP/turn, modifiers for health/morale/sanity (-2 each), range 1-5 AP | AI_Systems.md |
| **Armor System** | Equipment | Damage reduction by type and strength requirement | Weapons_and_Items.md, DamageTypes.md |
| **Base Defense Integration** | Interception | Base turrets participate in interception | UFO_and_Interception.md |
| **Base Progression** | Geoscape/Lore | 4-level enemy base growth (120-180 days total) with increasing threat | Lore.md |
| **Bankruptcy Mechanics** | Economy | Liquidates 50% equipment, 25% units, -20 relations on trigger | Finance.md, Victory_and_Defeat.md |
| **Bankruptcy Threshold** | Economy | Game over at -1,000,000 credits or cash <-50K | Victory_and_Defeat.md, Finance.md |
| **Campaign Generation** | Geoscape/Lore | Procedural 5-7 mission sequences released over 6-10 weeks per faction | Lore.md |
| **Campaign Scheduling** | Geoscape/Lore | Missions release at predetermined intervals (typical 2-3 week gaps) | Lore.md |
| **Cash Flow Forecasting** | Economy | 3-month automatic projection of income vs. expenses | Finance.md |
| **Corruption Tax** | Economy | Per-base surcharge for operating excessive bases | Finance.md |
| **Debt System** | Economy | 100K loan limit, 5% monthly interest, max 500K total debt | Finance.md |
| **Difficulty Scaling** | Campaign | Difficulty-specific tutorial, stat adjustments per difficulty level | Tutorial.md |
| **Corpse Trading** | Economy | Black market prisoner/corpse system | Black_Market.md |
| **Country AI Behavior** | Geoscape/Diplomacy | Funding bonuses/cuts, hostility shifts, territorial claims based on performance | AI_Systems.md, Diplomacy.md |
| **Country Classification** | Geoscape/Diplomacy | Major (5-8), Secondary (8-12), Minor (10-15), Supranational (2-3) powers | Diplomacy.md |
| **Country Funding Mechanics** | Geoscape/Economy | Base 10-100K/month, relation multiplier 0.5x-2.0x, threat multiplier 1.0x-1.5x | Diplomacy.md, Finance.md |
| **Country Panic** | Geoscape/Diplomacy | 0-100 scale, increases from failures/attacks, spreads to adjacent regions at 50%+ | Diplomacy.md |
| **Craft Addon System** | Geoscape/Interception | 2 slots for upgrades: shields, armor, mobility, detection, utility systems | Crafts.md |
| **Craft Classification** | Geoscape | 7 classes (Scout, Interceptor, Transport, Fighter, Heavy Fighter, Bomber, Battleship) | Crafts.md |
| **Craft Crew System** | Geoscape/Interception | Pilot/Co-Pilot/Crew positions with different XP multipliers (100%/50%/25%) | Crafts.md |
| **Craft Fuel Management** | Geoscape | Automatic consumption by distance, craft size, cargo (1 + modifiers per hex) | Crafts.md |
| **Craft Maintenance** | Geoscape | Passive repair +10%/week, hangar upgrades improve rate to +20-30%/week | Crafts.md |
| **Craft Crashes** | Geoscape/Interception | Craft reaching 0 HP crashes, triggering rescue mission generation | Crafts.md |
| **Craft Storage Capacity** | Geoscape | Garage (1 slot), Hangar (4 slots); crafts without storage cannot deploy | Crafts.md |
| **Craft Weapon Configuration** | Geoscape/Interception | Exactly 2 hardpoints, heavy weapons consume both slots | Crafts.md |
| **Cross-Sector Combat** | Interception | Weapons determine valid target sectors (Air/Land/Underground) | UFO_and_Interception.md |
| **Cover System** | Battlescape | Accuracy & protection mechanics (Cost of Sight + Cost of Fire) | Battlescape.md |
| **Damage (Interception)** | Interception | Craft weapon damage calculation (deterministic, NO armor reduction) | UFO_and_Interception.md |
| **Day/Night Conditions** | Environment | Night sight penalty +3, -15% accuracy; Day/night vision equipment negates | Environment.md |
| **Diplomacy Events** | Diplomacy | Relations modifiers (±2-15 per event) | Countries.md |
| **Dual XP Tracking** | Units/Crafts | Each unit tracks Ground Combat XP + Pilot XP separately, independent progression | Crafts.md, Units.md |
| **Durability System** | Equipment | Items degrade (5% per mission, armor only on hit); repair +10%/week base | Weapons_and_Items.md |
| **Energy Point System** | Interception | Weapon/evasion/system energy pool; regeneration +2-5 EP/turn depending on craft | UFO_and_Interception.md |
| **Equipment Class Synergy** | Equipment | Matched classes: +10-20% bonuses; mismatched: -5-15% penalties | Weapons_and_Items.md |
| **Explosion Mechanics** | Battlescape | 4-direction propagation with distance scaling (walls 100% block, units 50% reduce) | Damage_and_Armor.md, Battlescape.md |
| **Formation Positioning** | Interception | Player forces left side, enemy forces right side of engagement screen | UFO_and_Interception.md |
| **Manufacturer System** | Basescape/Economy | Convert resources to equipment; -20 to -40% time with facility upgrades; batch bonus +20% | Economy.md |
| **Manufacturing vs Marketplace** | Economy | Manufacturing: slower/cheaper (50-70% price); Marketplace: faster/expensive (100-150%) | Economy.md |
| **Market-Based Pricing** | Economy | Base prices, supply/demand ±20%, rarity 150-300%, bulk -20%, seasonal variations | Economy.md |
| **Modification System** | Equipment | 2 weapon slots, 1 armor slot; mods provide bonuses (scope +15% accuracy, etc.) | Weapons_and_Items.md |
| **Regional Bloc System** | Diplomacy/Geoscape | Geographic regions share panic, morale, defense synergies (+10% effectiveness) | Diplomacy.md |
| **Regional Effects** | Diplomacy/Geoscape | Panic contagion adjacent regions, UFO frequency ties to regional stability | Diplomacy.md |
| **Research Projects** | Basescape/Economy | Man-day based progress, 50-500 base cost, 50-150% complexity multiplier | Economy.md |
| **Research Types** | Basescape/Economy | Technology, Item Analysis, Interrogation, Autopsy, Facility Upgrade, Hybrid | Economy.md |
| **Research Technology Tree** | Basescape/Economy | 5 branches (Weapons, Armor, Alien Tech, Facilities, Support) with prerequisites | Economy.md |
| **Scientist Allocation** | Basescape/Economy | Early: 2-5 (bottleneck), Mid: 5-10 (broad), Late: 15+ (rapid); efficiency 80%-60% per additional | Economy.md |
| **Sector Capacity** | Interception | Max 4 objects per sector (Air/Land/Underground); sectors visible simultaneously | UFO_and_Interception.md |
| **Supplier AI Behavior** | Geoscape/Economy | Dynamic inventory/pricing based on relationship (Allied +50% stock/-10%, Hostile -50% stock/+15%) | UFO_and_Interception.md, Economy.md |
| **Supplier Integration** | Economy/Diplomacy | Supplier behavior tied to country relations; dynamic inventory and pricing | Economy.md |
| **Thermal/Heat System** | Interception | Heat generation 5-20, jam at 100+ heat; dissipation -5 to -15/turn by craft type | UFO_and_Interception.md |
| **Weapon Flight Time** | Interception | Range measured by turn delay (Close 5, Short 4, Medium 3, Long 2, Very Long 1 turn) | UFO_and_Interception.md |
| **Craft Equipment** | Equipment | Weapons, armor, support systems for interception | UFO_and_Interception.md, Weapons_and_Items.md |
| **Craft Operations** | Geoscape | Movement, fuel consumption, deployment states | Crafts.md, Geoscape.md |
| **Damage (Interception)** | Interception | Craft weapon damage calculation (deterministic) | UFO_and_Interception.md |
| **Damage Types** | Combat | 8-type system (Kinetic, Explosive, Energy, Psi, Stun, Acid, Fire, Frost) with resistances | DamageTypes.md |
| **Demotion System** | Units | Rank reduction with proportional XP retention re-specialization (A5) | Units.md |
| **Diplomacy Events** | Diplomacy | Relations modifiers (±2-15 per event) | Countries.md |
| **Economic Balance** | Economy | Monthly cashflow model (intentional scarcity, 90% win rate required) | Economic_Balance.md |
| **Electrical Hazards** | Environment | 2-4 damage/turn, 50% stun chance, equipment damage | Environment.md |
| **Economic Crisis Response** | Economy | Recovery strategy simulations and cascading effects | Finance.md |
| **Ending Quality** | Victory/Defeat | Good/Neutral/Bad/Failure endings based on karma/score/survival | Victory_and_Defeat.md |
| **Ending Types** | Campaign | Good (victory), Neutral (survival with cost), Bad (coexistence/pyrrhic), Failure (extinction) | Victory_and_Defeat.md |
| **Endgame Cinematics** | Campaign | 3-5 minute post-victory sequence with statistics overlay | Victory_and_Defeat.md |
| **Equipment Class Synergy** | Equipment | Class matching bonuses (+50% effectiveness) | Weapons_and_Items.md |
| **Environmental Hazards** | Battlescape | Smoke, fire, gas, radiation, electrical systems | Environment.md |
| **Event System** | Campaign | Random 2-5 events/month affecting economy/personnel/research/diplomacy/operations | Lore.md |
| **Experience Acquisition** | Units | XP gain from combat/training (+1-50 per source) | Units.md |
| **Explosion Mechanics** | Battlescape | 4-direction propagation with distance scaling | Battlescape.md |
| **Explosion Propagation** | Battlescape | Base - (5 × hex distance), 100% wall block, 50% unit reduction | Battlescape.md |
| **Faction Escalation** | Geoscape | Threat level of faction increasing with attack frequency and resources | Lore.md |
| **Faction Independence** | Geoscape/Lore | Each faction operates autonomously with distinct units/research/goals | Lore.md |
| **Faction Regional Preferences** | Geoscape/Lore | Factions concentrate operations in preferred regions (80% in home region typical) | Lore.md |
| **Faction Scaling** | Lore | Base 2 campaigns/month (Q1), escalating +1 per quarter (Q2=3, Q3=4, Q4=5, cap 10) | Lore.md |
| **Fire Status Effect** | Environment | Damage over time, spreads 30%/turn on flammable, extinguished by water | Environment.md |
| **Funding Crisis** | Economy | Cascade of funding failures (3 crisis levels) | Countries.md, Finance.md |
| **Funding Tier** | Geoscape | Monthly financial support level (0-10) from allied countries | Finance.md |
| **Gas System** | Environment | Poison/Nerve/Acid/Stun gases with distinct effects | Environment.md |
| **Heat Management** | Interception | Weapon heat buildup (jam at 100+) with dissipation (Thermal/Heat) | UFO_and_Interception.md |
| **Hex Grid (Vertical Axial)** | Battlescape | Coordinate system for map positioning | Hex_Coordinate_System.md |
| **Inflation Tax** | Economy | Wealth penalty applied when accumulated credits exceed 20× monthly income | Finance.md |
| **Health System** | Psychology | HP pool, bleeding, incapacitation, death states | Morale_and_Sanity.md |
| **Interception Combat Formula** | Interception | Hit chance × damage calculation for craft combat | UFO_and_Interception.md |
| **Interception System** | Geoscape | Mid-level combat between crafts/bases and UFOs | UFO_and_Interception.md |
| **Inventory & Equipment** | Units | Unit equipment slots, carrying capacity, item management | Units.md, Weapons_and_Items.md |
| **Karma System** | Diplomacy | Moral alignment (-100 to +100, affects mission gating/advisors) | Fame_Karma_Reputation.md |
| **Loss Conditions** | Campaign | Organization destruction, economic collapse, complete funding loss | Progression_Timeline.md |
| **Manufacturing System** | Basescape | Equipment production from resources and blueprints | Basescape.md |
| **Material Properties** | Environment | Terrain material stats (HP, fire/explosive/bullet resistance) | Environment.md |
| **Melee Combat** | Battlescape | Close-range damage formula (STR/2 + weapon base) | Battlescape.md |
| **Mission Base** | Geoscape/Lore | Permanent enemy stronghold growing 4 levels (120-180 days), generates 1-5 missions/week | Lore.md |
| **Mission Generation** | Geoscape | Procedural mission creation (2-5 faction, 1-3 country, 0-2 random/month) | Missions.md, Lore.md |
| **Mission Generation Schedule** | Geoscape/Lore | Missions release at predetermined intervals within campaign (typical 2-3 weeks apart) | Lore.md |
| **Mission Site** | Geoscape/Lore | Temporary tactical engagement (7-14 day timer), static location, disappears if ignored | Lore.md |
| **Mission Types** | Geoscape | UFO crash, interception, alien base, terror, base defense, colony defense, research, supply raid, sites, bases, UFOs | Missions.md, Lore.md |
| **Mission UFO** | Geoscape/Lore | Mobile enemy craft executing mission script (3-14 days), awards points per completed step | Lore.md |
| **Mothership Assault** | Geoscape/Battlescape | Sequential air + 4-5 ground battles to eliminate alien command (month 15+ trigger) | Victory_and_Defeat.md |
| **Mothership Interception** | Geoscape | Air combat phase reducing mothership to infiltration state (phase 2 of assault) | Victory_and_Defeat.md |
| **Mothership Phases** | Geoscape/Battlescape | 5-phase assault: Air Combat → External → Cargo → Engineering → Command → Core | Victory_and_Defeat.md |
| **Panic Cascade** | Campaign | Global panic increases from missions (-5 to -15%) and reaches 100% triggering game over | Victory_and_Defeat.md |
| **Panic Contagion** | Psychology | Adjacent units to panicked unit: -2 morale | Morale_and_Sanity.md |
| **Panic Mechanics** | Diplomacy | Country panic (0-100 scale), collapse at 100+ | Countries.md |
| **Panic Mode** | Psychology | Morale failure behavior (cannot move >2 hex, -50% AP recovery) | Morale_and_Sanity.md |
| **Personnel Management** | Basescape | Recruitment, salaries (5K-12.5K), morale tracking, specialization | Basescape.md |
| **Portal System** | Geoscape | Research-gated teleportation (50K setup, 5K per use) (A2) | Geoscape.md |
| **Power Management** | Basescape | 10-tier priority system for facility power allocation during shortage | Basescape.md |
| **Power Points System** | Diplomacy | Monthly organizational progress (+1 baseline, +3-5 for events) | Politics_and_Factions.md |
| **Progression Timeline** | Campaign | 4 phases with expected player state/milestones/loss conditions | Progression_Timeline.md |
| **Promotion Trees** | Units | Class hierarchies and specialization branching paths | Units.md |
| **Quest System** | Geoscape | Optional time-limited objectives (2 weeks-6 months) providing bonus rewards | Lore.md |
| **Radiation** | Environment | Invisible 1 HP/turn, -1 sanity/3 turns, long-term damage | Environment.md |
| **Rank System** | Units | Experience-based unit advancement (0-6 with pyramid structure) | Units.md |
| **Rank Limits** | Units | Pyramid structure (Rank 5 requires 3 Rank 4+) | Units.md |
| **Reputation System** | Diplomacy | Legal legitimacy (0-100, +1/quarter, NO DECAY, permanent) | Fame_Karma_Reputation.md |
| **Research System** | Basescape | 5-branch tech tree (Weapons, Armor, Alien Tech, Facilities, Support) | Basescape.md |
| **Research-Gate System** | Tutorial | Mechanics unlock via research completion (progression through research tree) | Tutorial.md |
| **Sanity System** | Psychology | Long-term psychological stability (0-100, affects deployment/panic) | Morale_and_Sanity.md |
| **Score System** | Diplomacy | Total humanity saved (0-∞, per-country tracking, determines ending) | Fame_Karma_Reputation.md |
| **Smoke System** | Environment | 3-8 turns duration, 20% spread/turn to adjacent tiles, stacking intensity | Environment.md |
| **Specialization Re-selection** | Units | Demotion enables choosing ANY valid path (not just previous) | Units.md |
| **Specialization Selection** | Units | Promotion branch choice (one-time per promotion) | Units.md |
| **Stealth Budget** | Geoscape | Mission stealth resource limiting overt actions (C3) | Geoscape.md |
| **Storage & Supply Management** | Basescape | Warehouse storage with finite capacity | Basescape.md |
| **Stun System** | Psychology | Non-lethal incapacity (20-point pool, separate from health) | Morale_and_Sanity.md |
| **Suppression** | Battlescape | Status effect (-3 AP max, stacks across enemies, resets if no fire) | Battlescape.md |
| **Terrain System** | Environment | Floor, Wall, Water, Difficult, Cover types with movement/sight costs | Environment.md |
| **Traits & Perks** | Units | Permanent personality modifiers with acquisition/conflict/synergy (A4) | Traits_and_Perks.md |
| **Tutorial Progression** | Campaign | Months 1-3 designed as education sequence teaching all three game layers | Tutorial.md |
| **UFO Crash Missions** | Missions | Generated from interception success (base 1000 credits) | Missions.md |
| **Unit Classification** | Units | Class hierarchy organization (Agent → Specialist → Expert → Master → Elite → Hero) | Units.md |
| **Unit Health & Recovery** | Units | Healing through medical facilities and medikit items | Units.md |
| **Unit Maintenance** | Basescape | Monthly salary/upkeep costs per rank (5K-12.5K) | Basescape.md |
| **Unit Statistics** | Units | 6 core stats (STR, MAR, DEX, BRV, INT, END) with 6-12 range | Units.md |
| **Unit Types** | Units | Biological (heal via medical) vs Mechanical (repair via maintenance) | Units.md |
| **Victory Primary Condition** | Campaign | Eliminate mothership + 95%+ alien infrastructure (month 15+ trigger) | Victory_and_Defeat.md |
| **Victory Statistics** | Campaign | Campaign duration, units, missions, bases, research %, global panic, countries, alien kills | Victory_and_Defeat.md |
| **Weather System** | Environment | 8 weather types affecting sight/accuracy/movement/special effects (A8) | Environment.md, Geoscape.md |
| **Weapon Firing Modes** | Battlescape | Snap Shot, Aimed Shot, Burst Fire, Auto Fire with AP/accuracy tradeoffs | Battlescape.md |
| **Weapons & Items** | Equipment | Unit weapons, armor, consumables, craft equipment, lore items | Weapons_and_Items.md |
| **Wounds System** | Psychology | Cumulative trauma between battles (Light/Moderate/Severe/Critical recovery times) | Morale_and_Sanity.md |

| **Barracks Capacity** | Basescape | 1×1 = 8 units, 2×2 = 20 units, +1-5 org level bonus | Basescape.md |
| **Barracks System** | Basescape | Unit housing with capacity, 5K salary/month per unit | Basescape.md |
| **Base Biome Penalties** | Basescape | Ocean +250%, Mountain +40%, Arctic +35%, Urban +25%, Desert +20%, Forest/Grassland baseline | Basescape.md |
| **Base Expansion System** | Basescape | Sequential progression (Small → Medium → Large → Huge) with facility preservation | Basescape.md |
| **Base Grid Coordinates** | Basescape | Orthogonal square (40×60 typical), (X,Y) system with cardinal/diagonal neighbors | Basescape.md |
| **Base Sizing Progression** | Basescape | Small (4×4, 150K, 30 days) → Medium (5×5, 250K, 45 days) → Large (6×6, 400K, 60 days) → Huge (7×7, 600K, 90 days) | Basescape.md |
| **Battlescape Deployment** | Battlescape | Enemy squads placed to map blocks (1 per block), individual units random on tiles | Battlescape.md |
| **Battlescape Entity Types** | Battlescape | Floor, Wall, Cover (bush/rock/tree/rubble/crate), Environmental (smoke/fire/gas) | Battlescape.md |
| **Battlescape Fog of War** | Battlescape | Initial visibility based on player LOS, tiles marked revealed/visible/shrouded | Battlescape.md |
| **Battlescape Map Generation** | Battlescape | Biome → Terrain selection → Map block assignment → Script execution → Transformation → Deployment | Battlescape.md |
| **Battlescape Victory/Defeat** | Battlescape | Success: objectives + squad survives | Failure: units eliminated OR time expires OR retreat | Battlescape.md |
| **Command Center** | Basescape | 2×2 facility, +10 facility efficiency adjacent, 15 power, 100K cost | Basescape.md |
| **Cover Cost of Fire** | Battlescape | Accuracy reduction: -5% per cover point (multiplicative); examples 1 point = 0.95x, 5 points = 0.75x | Battlescape.md |
| **Cover Cost of Sight** | Battlescape | Visibility blocking: walls 100%, obstacles partial, bushes 50%, cumulative effects | Battlescape.md |
| **Cover Destruction** | Battlescape | AoE damage destroys cover; partial cover provides degraded protection | Battlescape.md |
| **Craft Crew Roles** | Crafts | Pilot (100% XP), Co-Pilot (50%), Crew (25%); minimum crew by craft size | Crafts.md |
| **Craft Deployment States** | Crafts | Landed, Refueling, Flying, Combat, Damaged, Grounded (fuel shortage) | Crafts.md |
| **Demotion Eligibility** | Units | Rank 2+ only, barracks (not deployed), no "Stubborn" trait | Units.md |
| **Demotion Mechanics** | Units | Retain 50% XP, revert to rank baselines, keep traits/transformations, 1-week retraining | Units.md |
| **Demotion Use Cases** | Units | Path correction, economic (salary), team flexibility, specialization reset | Units.md |
| **Energy Point System** | Battlescape | Base 50-400 (depends on unit), +20-50 per turn regen, actions cost 5-20 EP | Battlescape.md |
| **Equipment Slot System** | Units | Primary weapon, Secondary weapon, Armor (3 slots total) with capacity limits | Units.md |
| **Equipment Weight Categories** | Units | Each unit has Strength-based carry capacity (6-12); items 0.5-3 weight units | Units.md |
| **Facility Upgrade Costs** | Basescape | 50-150K per upgrade, 14-30 days construction, provides 30-50% efficiency improvement | Basescape.md |
| **Facility Upgrade Examples** | Basescape | Lab +50% (10→15 man-days), Hospital +5 beds, Barracks capacity +12, Hangar +4 slots | Basescape.md |
| **Gate/Portal Mechanics** | Geoscape | Research-gated teleportation for base relocation (50K setup, 5K/use) | Geoscape.md |
| **Ground Combat XP** | Units | Earned from battlescape combat missions, +1-50 per source | Units.md |
| **Hangar M Specification** | Basescape | 2×2 grid, 4 craft capacity, 15 power, 80K cost | Basescape.md |
| **Hangar L Specification** | Basescape | 3×3 grid, 8 craft capacity (upgrade), 30 power, 150K cost | Basescape.md |
| **Health Point System** | Battlescape | Base 15-25, health damage direct, <50% HP = -2 AP/turn penalty, death at 0 HP | Battlescape.md |
| **Hospital Facility** | Basescape | 2×2, +2 HP/week baseline, +5 beds (U1), +1 sanity/week (U2), 10 power | Basescape.md |
| **Hit Chance Formula** | Battlescape | Final = Base × Range_Mod × Mode_Mod × Cover_Mod × LOS_Mod, clamped 5-95% | Battlescape.md |
| **Lab Facility S** | Basescape | 2×2, 10 man-days baseline, +50% (U1 → 15), +2 queue (U2), 15 power, 70K cost | Basescape.md |
| **Lab Facility L** | Basescape | 3×3, 20 man-days capacity, 30 power, 120K cost | Basescape.md |
| **Landing Zone System** | Battlescape | Player selects deployment zone (1-4 zones based on map size), enemy-free areas | Battlescape.md |
| **Line of Fire (LOF)** | Battlescape | Weapon projectile path, some obstacles ignored by certain weapons, ricochet optional | Battlescape.md |
| **Line of Sight (LOS)** | Battlescape | Traced from attacker eye to target center, obstacles with cost-of-sight block/partial | Battlescape.md |
| **Map Block System** | Battlescape | Reusable 5×5 to 10×10 hex chunks placed procedurally, rotatable 90/180/270° and mirrored | Battlescape.md |
| **Map Script System** | Battlescape | Procedural generation rules (place blocks, draw features, fill space, conditional logic) | Battlescape.md |
| **Melee Combat Prerequisites** | Battlescape | Adjacent target, melee weapon equipped, sufficient AP (1 minimum) | Battlescape.md |
| **Melee Damage Formula** | Battlescape | Damage = Base + Strength_Bonus ± Weapon_Bonus, then Armor_Reduced = Damage × (1 - Armor_Value) | Battlescape.md |
| **Melee Disengagement** | Battlescape | Movement action breaks melee (5 AP typical cost) | Battlescape.md |
| **Melee Engagement Duration** | Battlescape | Locked mutual combat until one disengages or dies | Battlescape.md |
| **Melee Hit Chance** | Battlescape | Base_Melee_Stat + Weapon_Bonus ± terrain modifiers | Battlescape.md |
| **Melee Weapon Examples** | Battlescape | Knife (70% hit, 8 damage), Sword (75% hit, 15 damage), Plasma Blade (85%, 25 damage specialist) | Battlescape.md |
| **Minimum Range Penalties** | Battlescape | Sniper rifles -50% accuracy within 3 hexes; shotguns/pistols no penalty | Battlescape.md |
| **Mission Landing Zones** | Battlescape | Small (4×4) = 1, Medium (5×5) = 2, Large (6×6) = 3, Huge (7×7) = 4 zones | Battlescape.md |
| **Morale Cascades** | Battlescape | Panic spreads, adjacent units suffer -2 morale (panic contagion) | Battlescape.md |
| **Morale Impact on AP** | Battlescape | Panic mode: cannot move >2 hex, -50% AP recovery | Battlescape.md |
| **Movement Point System** | Battlescape | Base Speed stat + terrain modifiers, elevation +1/level, turning free | Battlescape.md |
| **Movement Terrain Costs** | Battlescape | Grass (1), Swamp (+2), Water (+3 or blocked), Elevation (+1/level) | Battlescape.md |
| **Neutral Unit Deployment** | Battlescape | NPCs/animals randomly distributed, cannot occupy player landing zones | Battlescape.md |
| **Orthogonal Grid System** | Basescape | Square grid 40×60 typical, 4 or 8 neighbor topology, rotation fixed | Basescape.md |
| **Personnel Constraints** | Basescape | Famous/karma affects recruitment sources, supplier relations affect options | Basescape.md |
| **Personnel Recruitment** | Basescape | Country (20-50K), Faction (30-75K, 1 week), Marketplace (40-100K immediate) | Basescape.md |
| **Physical Trait Examples** | Units | Strong (+2 STR, +4 carry), Fast (+1 Speed), Enduring (+10% HP), Resilient (+2 armor) | Units.md |
| **Pilot XP** | Crafts/Units | Separate from ground XP, earned during interception/craft deployment | Crafts.md, Units.md |
| **Power Generation** | Basescape | Power Plant +50 (10 self-consume), Enhanced +100 (15 self-consume), multiple additive | Basescape.md |
| **Power Consumption** | Basescape | Corridor (2), Barracks S/L (5/10), Lab S/L (15/30), Workshop S/L (15/30), etc. | Basescape.md |
| **Power Priority System** | Basescape | 10-tier priority (high: barracks/labs/hangars, low: storage/non-essential) | Basescape.md |
| **Power Shortage** | Basescape | Facilities prioritized by tier; low-priority offline first | Basescape.md |
| **Prison Facility** | Basescape | 3×3, 10 prisoners max, 12 power, 100K cost | Basescape.md |
| **Prisoner Escape** | Basescape | 1% per prisoner per day chance | Basescape.md |
| **Prisoner Lifetime** | Basescape | 30 + (Unit Max HP × 2) days (stronger prisoners survive longer) | Basescape.md |
| **Prisoner Options** | Basescape | Execute (-5 karma), Interrogate (±0), Experiment (-3), Exchange (+3), Convert (60%), Release (+5) | Basescape.md |
| **Prisoner System** | Basescape | Units with HP >0 at mission end captured, prison capacity limited, multiple options | Basescape.md |
| **Projectile Behavior** | Battlescape | Travels through obstacles (some), collision effects possible, ricochet future | Battlescape.md |
| **Radar S Specification** | Basescape | 2×2, 500km range, 8 power, 50K cost | Basescape.md |
| **Radar L Specification** | Basescape | 2×2, 800km range, 12 power, 80K cost | Basescape.md |
| **Range Accuracy Modifier** | Battlescape | 0-75% range (1.0), 75-100% (0.5 to 1.0 linear), 100%+ (0.0 impossible) | Battlescape.md |
| **Rank 0 Unit** | Units | Conscript (0 XP), basic/limited supplies, starting rank | Units.md |
| **Rank 1 Unit** | Units | Agent (200 XP), trained operative, basic role | Units.md |
| **Rank 2 Unit** | Units | Specialist (500 XP), role proficiency | Units.md |
| **Rank 3 Unit** | Units | Expert (900 XP), significant specialization | Units.md |
| **Rank 4 Unit** | Units | Master (1,500 XP), advanced specialization | Units.md |
| **Rank 5 Unit** | Units | Elite (2,500 XP), peak specialization | Units.md |
| **Rank 6 Unit** | Units | Hero (4,500 XP), unique, one per squad max | Units.md |
| **Rank Pyramid Limits** | Units | Rank 5 requires 3 Rank 4+, Rank 4 requires 3 Rank 3+, etc. | Units.md |
| **Reaction Fire** | Battlescape | Readied units can interrupt actions with reaction attacks (limited per turn) | Battlescape.md |
| **Respecialization Cost** | Units | 15,000 credits, 1 week training time, Rank 2+ eligible | Units.md |
| **Respecialization Mechanics** | Units | Rank unchanged, specialization changes, all stats preserved, XP retained | Units.md |
| **Rest Action** | Battlescape | 1 AP, restores stun/EP, unit vulnerable | Battlescape.md |
| **Round-Based Turn Order** | Battlescape | All units act once per round, Reaction stat determines action priority | Battlescape.md |
| **Running Action** | Battlescape | 1 AP + 2× MP, creates audible footsteps | Battlescape.md |
| **Sanity Impact** | Battlescape | -5 per psi fail, -3 witness alien casualty, +1/week hospital | Battlescape.md |
| **Sanity System** | Units | 0-12 range (mental health), affects psi vulnerability and panic | Units.md |
| **Shotgun Specifications** | Battlescape | 3-hex range, 2 AP, 45 damage, 60% accuracy, 10 EP, 3-hex area blast | Battlescape.md |
| **Smoke System** | Battlescape | 20% LOS block, no damage, 3-8 turn duration, 30% spread/turn adjacent | Battlescape.md |
| **Sneaking Action** | Battlescape | 3 AP + MP, silent movement, +1 Concealment | Battlescape.md |
| **Status Effects** | Battlescape | Bleeding (-1 HP/turn), Fire (-5 HP/turn), Suppressed (-25% acc), Stunned (1-3 turns), Poisoned (-1 HP/turn × 5), Panicked | Battlescape.md |
| **Storage Facility S** | Basescape | 1×1, 100 items, 2 power, 20K cost | Basescape.md |
| **Storage Facility M** | Basescape | 2×2, 400 items, 5 power, 50K cost (upgrade) | Basescape.md |
| **Storage Facility L** | Basescape | 3×3, 800 items, 8 power, 90K cost (upgrade) | Basescape.md |
| **Strength Training Facility** | Basescape | 2×2, +1 STR per unit/week, 12 power, 100K/week maint, 500K cost (NEW) | Basescape.md |
| **Stun Point System** | Battlescape | Non-lethal incapacity (20-point pool separate from HP), -2-5 per turn decay, Rest restores | Battlescape.md |
| **Suppression Mechanic** | Battlescape | 2 AP to suppress, -3 AP max, stacks across multiple enemies, resets if no fire | Battlescape.md |
| **Terrain Costs** | Battlescape | Grass (1 MP), Swamp (+2), Water (+3 or blocked), Fire/Hazard (special) | Battlescape.md |
| **Terrain Destruction** | Battlescape | AoE damage destroys terrain, wall blocks 100%, units reduce 50%, obstacles vary | Battlescape.md |
| **Terrain Material Properties** | Battlescape | HP values, fire/explosive/bullet resistance | Battlescape.md |
| **Terrain Transformation** | Battlescape | Destroyed terrain becomes rubble/exposed (changes movement/sight costs) | Battlescape.md |
| **Throw Action** | Battlescape | 1 AP, grenade/thrown weapon action | Battlescape.md |
| **Transformation System** | Units | Permanent status (Cybernetic, Genetic, Alien Hybrid) affecting stats/abilities/vulnerabilities | Units.md |
| **Trait Acquisition Methods** | Units | Birth (recruitment random), Achievement (combat-earned), Perk system (advancement) | Units.md |
| **Trait Balance Points** | Units | 4-point total, positive traits consume, negative refund (max 4 cap) | Units.md |
| **Trait Conflicts** | Units | Mutually exclusive traits prevented during acquisition | Units.md |
| **Trait Synergies** | Units | Beneficial combinations (Fast + Ambidextrous, etc.) | Units.md |
| **Turn Order Initiative** | Battlescape | Higher Reaction = earlier action, ties favor players then allies | Battlescape.md |
| **Unit Action Points** | Battlescape | 50-60 base AP, +2 per promotion, carry over with "Quick Reflexes" trait | Battlescape.md |
| **Unit Action Priority** | Battlescape | Determined by Reaction stat within team | Battlescape.md |
| **Unit Classification Synergy** | Units | Matched class equipment +50% effectiveness, mismatched -30% accuracy | Units.md |
| **Unit Demotion** | Units | Rank reduction with 50% XP retention, stat revert, trait preservation | Units.md |
| **Unit Fitness** | Units | Base 15-25 HP, +1-2 per promotion, damaged during combat | Units.md |
| **Unit Morale** | Units | 10+ base, -1 per casualty, +1/week rest; affects panic/effectiveness | Units.md |
| **Unit Perks** | Units | Specialized abilities unlocked per rank, cannot change after selection | Units.md |
| **Unit Recovery** | Units | Hospital +2 HP/week, rest during missions 1 AP, natural regen, sanity recovery | Units.md |
| **Unit Respecialization** | Units | Rank unchanged, specialization changes, stats preserved, perks reset | Units.md |
| **Unit Stat Progression** | Units | 6 core stats scaling with rank (Aim +10% per promotion, Melee +1-2, Reaction +1/2, etc.) | Units.md |
| **Unit Types** | Units | Biological (heal via medical), Mechanical (repair via maintenance) | Units.md |
| **Weapon Fire Action** | Battlescape | 1-3 AP (varies by weapon), generates combat | Battlescape.md |
| **Weapon Firing Modes** | Battlescape | Base (1.0), Snap Shot (0.95), Burst (0.85), Auto (0.75), Aimed (1.15), Careful (1.30) | Battlescape.md |
| **Weapon Grenade Launcher** | Battlescape | 12-hex, 2 AP, 30 area damage, 65% accuracy, 15 EP | Battlescape.md |
| **Weapon Heavy Cannon** | Battlescape | 20-hex, 3 AP, 60 damage, 55% accuracy, 20 EP (Specialist only) | Battlescape.md |
| **Weapon Pistol** | Battlescape | 8-hex, 1 AP, 12 damage, 70% accuracy, 5 EP | Battlescape.md |
| **Weapon Range** | Battlescape | Varies: Pistol 8, Rifle 15, Sniper 25, Shotgun 3, GL 12, HC 20 hexes | Battlescape.md |
| **Weapon Rifle** | Battlescape | 15-hex, 2 AP, 18 damage, 70% accuracy, 8 EP | Battlescape.md |
| **Weapon Sniper Rifle** | Battlescape | 25-hex, 3 AP, 35 damage, 85% accuracy, 12 EP | Battlescape.md |
| **Workshop Facility S** | Basescape | 2×2, 10 man-days manufacturing, +50% (U1 → 15), +2 queue (U2), 15 power, 60K | Basescape.md |
| **Base Placement Strategy** | Geoscape | One base per province (exclusive), adjacent hexes provide bonuses | Geoscape.md |
| **Base Placement** | Geoscape | Strategic positioning on world hex map, affects operational efficiency | Geoscape.md |
| **Biome Penalties** | Basescape | Biomes reduce facility efficiency (desert -20%, swamp -30%, etc.) | Basescape.md |
| **Bomber Craft** | Geoscape | 3 hexes/turn, 500 fuel, 1,500km range, specialized payload delivery | Geoscape.md |
| **Budget Cycle** | Finance | Monthly 4-week breakdown: Week 1 (+10%), Week 2-3 (costs), Week 4 (report) | Finance.md |
| **Campaign Difficulty** | Lore | Early (basic/standard), Mid (intermediate/upgraded), Late (advanced/elite units) | Lore.md |
| **Campaign Duration** | Lore | 6-10 weeks per campaign, ~5 missions per campaign | Lore.md |
| **Campaign Escalation Formula** | Lore | Base 2/month (Q1), +1 per quarter (Q2=3, Q3=4, Q4=5, max 10) | Lore.md |
| **Campaign Generation** | Lore | Predetermined intervals (Week 1, 3, 6, 7, 9 typical) with regional focus | Lore.md |
| **Campaign Missions** | Lore | ~5 missions per 6-10 week campaign | Lore.md |
| **Campaign Regional Preferences** | Lore | Asian 80%, American 70%, European balanced global | Lore.md |
| **Campaign Structure** | Lore | Duration 6-10 weeks, scheduled intervals, regional focus, difficulty scaling | Lore.md |
| **Campaigns Monthly** | Lore | 2 campaigns/month (Q1), escalating to 10 max by Q4 | Lore.md |
| **Capital Craft** | Geoscape | 2 hexes/turn, 800 fuel, 1,600km range, largest capacity | Geoscape.md |
| **Contagion Panic** | Morale | Adjacent units suffer -2 morale (panic spreads in squads) | Morale_and_Sanity.md |
| **Country Funding Calculation** | Finance | Funding Level × Relation Modifier (0.5-1.5x = 10-100K/month per country) | Finance.md |
| **Country Funding Levels** | Finance | 0-10 scale, affects monthly income from each country | Finance.md |
| **Country Funding Mechanics** | Finance | Economy sum, Relations -100 to +100, Funding levels 0-10 = % GDP | Finance.md |
| **Craft Fuel Management** | Geoscape | Fuel consumption scales with distance; Efficiency varies by craft type | Geoscape.md |
| **Craft Movement** | Geoscape | Variable speed by craft class (2-10 hexes/turn), fuel-limited range | Geoscape.md |
| **Craft Speed Categories** | Geoscape | Fighter 8, Interceptor 10, Transport 4, Bomber 3, Capital 2 hexes/turn | Geoscape.md |
| **Debt Accumulation** | Finance | Interest applied to debts month-by-month, -2 relations per cascade | Finance.md |
| **Debt System** | Finance | Credit from suppliers (Deficit), Interest (Debt), Funding withdrawal (Bankruptcy) | Finance.md |
| **Deficit State** | Finance | Credit from suppliers (-1 relation penalty) | Finance.md |
| **Deployment States** | Geoscape | Base (ready), Transit (vulnerable), Refueling (waypoint), Flying (active), Combat (air), Damaged (slow), Grounded (no fuel) | Geoscape.md |
| **Diplomatic Breaches** | Finance | Policy violations trigger relation penalties and funding losses | Finance.md |
| **Diplomatic Effects** | Finance | Violations affect relations and country funding | Finance.md |
| **Economic Stress** | Finance | Affects prices, availability, and inflation tax mechanics | Finance.md |
| **Energy Pool (Psychology)** | Morale | 0-100 scale, recovery +60 AP/turn, losses per action/sprint/heavy attack | Morale_and_Sanity.md |
| **Energy Recovery** | Morale | Cover -1/turn, Stationary -5/turn, Under fire -10/turn | Morale_and_Sanity.md |
| **Energy System** | Morale | Separate pool from HP, affects AP and accuracy when depleted | Morale_and_Sanity.md |
| **Escalation Meter** | Lore | Campaign frequency increases by quarter, multiple factions compound escalation | Lore.md |
| **Event Categories** | Lore | Economic 30%, Personnel 25%, Research 15%, Diplomatic 15%, Operational 15% | Lore.md |
| **Event Economic** | Lore | Boom, Crash, Bonus, Crisis, Windfall, Tax Reduction, Investment | Lore.md |
| **Event Diplomatic** | Lore | Betrayal, Alliance, Funding Change, Peace, War | Lore.md |
| **Event Frequency** | Lore | 2-5/month (scales with org level) | Lore.md |
| **Event Operational** | Lore | Supply Delay, Facility Damage, Craft Malfunction, Scandal, Disaster | Lore.md |
| **Event Personnel** | Lore | Surge, Desertion, Morale Crisis, Legend Soldier, Injury, Breakthrough, Advisor | Lore.md |
| **Event Research** | Lore | Breakthrough, Setback, Failure, Espionage | Lore.md |
| **Event System** | Lore | 2-5/month, unpredictable timing, cascading impact, multiple outcomes, some multi-month effects | Lore.md |
| **Expenses Operational** | Finance | Equipment, Personnel Maintenance, Facilities, Bases, Crafts | Finance.md |
| **Expenses Strategic** | Finance | Black Market, Diplomacy, Fame, Corruption Tax, Inflation Tax | Finance.md |
| **Faction Autonomy** | Lore | Independent organizations with own goals, defeat ≠ affects others, stronger over time | Lore.md |
| **Faction Components** | Lore | Unit classes, Campaign system, Resource tree, Technology, Missions, Story arcs | Lore.md |
| **Faction Definition** | Lore | Independent enemy organization with distinct goals and capabilities | Lore.md |
| **Faction Race Classification** | Lore | Each unit class = specific race, no mechanical bonuses, thematic diversity | Lore.md |
| **Fighter Craft** | Geoscape | 8 hexes/turn, 200 fuel, 1,600km range, balanced performance | Geoscape.md |
| **Financial Crisis** | Finance | Level 1 (Deficit), Level 2 (Debt), Level 3 (Withdrawal), Level 4 (Bankruptcy) | Finance.md |
| **Financial Crisis Cascade** | Finance | Deficit → Debt (interest) → Funding withdrawal (50%) → Bankruptcy (org dissolved) | Finance.md |
| **Fire Loss Events** | Morale | -5 per mission, -3 per casualty witness, +1/week hospital recovery | Morale_and_Sanity.md |
| **Fuel Cost Formula** | Geoscape | Fuel Cost = Distance × Efficiency | Geoscape.md |
| **Funding Income** | Finance | 10-100K/month per country depending on relations and funding level | Finance.md |
| **Geoscape Stealth Budget** | Geoscape | C3 Mechanic: 50-100 points starting budget, actions cost points | Geoscape.md |
| **Hangar Storage** | Basescape | Craft storage and readiness, capacity varies by facility size | Basescape.md |
| **Hexagon Grid Coordinates** | Geoscape | 90×45 hexagonal grid, ~500km per hex, covers Earth/Moon/Mars | Geoscape.md |
| **High Altitude Movement** | Geoscape | HIGH detection risk (+100%), vulnerable to interception | Geoscape.md |
| **History Events** | Lore | Random events affecting campaign progression, economy, diplomacy | Lore.md |
| **Income Sources** | Finance | Country funding, Mission loot, Raid loot, Manufacturing, Tributes, Supplier discounts | Finance.md |
| **Inflation Tax** | Finance | Applied when credits > 20× monthly income | Finance.md |
| **Interceptor Craft** | Geoscape | 10 hexes/turn, 250 fuel, 2,500km range, fastest interception | Geoscape.md |
| **Interception Risk** | Geoscape | Direct HIGH (+100%), Stealth MEDIUM (+50%), High-alt HIGH, Low-alt LOW (+30%), Base NONE | Geoscape.md |
| **Interception Risk Levels** | Geoscape | Direct (HIGH), Stealth (MEDIUM), High altitude (HIGH), Low altitude (LOW), At base (NONE) | Geoscape.md |
| **Loot Sales Income** | Finance | Mission and raid loot generates revenue | Finance.md |
| **Low Altitude Movement** | Geoscape | LOW detection risk (+30%), harder to intercept | Geoscape.md |
| **Manufacturing Income** | Finance | Workshop output generates revenue | Finance.md |
| **Melee Energy Drain** | Morale | -15 energy per heavy attack | Morale_and_Sanity.md |
| **Minimum Panic Save** | Morale | Morale at 0 triggers Panic Save (DC = 10 - Bravery) | Morale_and_Sanity.md |
| **Mission Loot Sales** | Finance | Credits from battlescape mission loot | Finance.md |
| **Mission Scheduling** | Lore | Predetermined intervals (typical: Week 1, 3, 6, 7, 9) | Lore.md |
| **Mission Site Duration** | Lore | 7-14 day timer, temporary location, disappears if ignored | Lore.md |
| **Mission Site Mechanics** | Lore | Temporary 7-14 day duration, static location, UFO mission scripts | Lore.md |
| **Mission Types (Geoscape)** | Geoscape | UFO Crash, Terror, Alien Base, Research, Escort, Defense, Supply, Colony Defense | Geoscape.md |
| **Morale Cascades** | Morale | Panic spreads to adjacent units, contagion -2 morale | Morale_and_Sanity.md |
| **Morale Effectiveness** | Morale | 100%+ Normal, 75-99% -5% AP, 50-74% -2% AP, 25-49% -5% acc, 1-24% -10% acc | Morale_and_Sanity.md |
| **Morale Gain Events** | Morale | Kill alien +1, leader nearby +0.5/turn, cover +0.5, full squad +1 at start | Morale_and_Sanity.md |
| **Morale Loss Events** | Morale | Squad death -2, suppression -1/turn, damage -1 per 10, missing -1, alien tech -1 | Morale_and_Sanity.md |
| **Morale Pool** | Morale | 0 to Bravery stat range (Bravery 8 = morale 0-8), fully recovered at mission start | Morale_and_Sanity.md |
| **Morale Recovery** | Morale | Leader presence, group cohesion, inspiring actions | Morale_and_Sanity.md |
| **Morale System** | Morale | Pool 0-Bravery, loss/gain events, effectiveness levels 100%-1% | Morale_and_Sanity.md |
| **Monthly Budget Cycle** | Finance | Week 1 (+10%), Week 2-3 (operational costs), Week 4 (financial report) | Finance.md |
| **Movement Energy Loss** | Morale | Per action -5, Sprint -10, Smoke/gas -5/turn | Morale_and_Sanity.md |
| **Movement Speed Categories** | Geoscape | 2-10 hexes/turn by craft type | Geoscape.md |
| **Multiple Campaign Escalation** | Lore | Multiple factions compound escalation exponentially | Lore.md |
| **New Campaign Monthly** | Lore | New campaign initiates monthly, predetermined scheduling | Lore.md |
| **Panic Behavior** | Morale | Cannot move >2 hexes, cannot attack, -50% AP recovery next turn | Morale_and_Sanity.md |
| **Panic Contagion** | Morale | Adjacent units -2 morale (spreads panicked state) | Morale_and_Sanity.md |
| **Panic Escalation** | Morale | Turn 1-2 Mild, Turn 3+ Severe, Turn 5+ Breakdown/retreat | Morale_and_Sanity.md |
| **Panic Ending Conditions** | Morale | Inspire (+50% morale), kill (+2), squad wipe, mission end | Morale_and_Sanity.md |
| **Panic Mode** | Morale | Triggered when morale reaches 0, affects behavior and effectiveness | Morale_and_Sanity.md |
| **Panic Save DC** | Morale | 10 - Bravery (higher Bravery = easier save) | Morale_and_Sanity.md |
| **Panic Threshold** | Morale | DC 10 - Bravery; Success keeps morale 1, Failure triggers panic | Morale_and_Sanity.md |
| **Population Influence** | Geoscape | Population affects mission frequency and diplomatic importance | Geoscape.md |
| **Power Management** | Basescape | Generation, consumption, 10-tier priority system, shortage handling | Basescape.md |
| **Province System** | Geoscape | Provinces contain hexes (6-12 typical), one base per province max | Geoscape.md |
| **Provincial Control** | Geoscape | Affects regional diplomacy, local resources, population benefits | Geoscape.md |
| **Provincial Ownership** | Geoscape | Loss triggers diplomatic penalties | Geoscape.md |
| **Provincial Strategic Value** | Geoscape | Population, geography, resources, alignment | Geoscape.md |
| **Quest Categories** | Lore | Military 2-4w, Economic 1-2m, Diplomatic 4-8w, Organizational 2-3m, Research 3-6m, Heroic Variable, Regional 1m, Survival 2-4w | Lore.md |
| **Quest Duration** | Lore | 2 weeks to 6 months | Lore.md |
| **Quest Framework** | Lore | Optional time-limited, 3-5 simultaneous active, no failure penalty | Lore.md |
| **Quest Rewards** | Lore | Bonuses vary by category (PP, credits, fame, difficulty) | Lore.md |
| **Quest System** | Lore | Optional 2w-6m, 3-5 active, no failure penalty, scales with org level | Lore.md |
| **Race Classification** | Lore | Cosmetic only, no mechanical bonuses, thematic filtering | Lore.md |
| **Radar Coverage** | Geoscape | Radar S 500km, Radar L 800km, multiple radars stack coverage | Geoscape.md |
| **Radar Network** | Geoscape | UFO detection networks covering strategic areas | Geoscape.md |
| **Relation Damage** | Finance | Policy violations, funding losses, bankruptcy consequences | Finance.md |
| **Resources Influence** | Geoscape | Resources affect base efficiency and development options | Geoscape.md |
| **Sanity Baseline** | Morale | 0-100 scale, permanent psychological stability | Morale_and_Sanity.md |
| **Sanity Deployment** | Morale | 1-24: Cannot deploy | Morale_and_Sanity.md |
| **Sanity Effects** | Morale | 75-100 None, 50-74 -5% panic threshold, 25-49 -15% threshold -2 acc, 1-24 Cannot deploy, 0 Discharged | Morale_and_Sanity.md |
| **Sanity Loss** | Morale | Per mission -5, Per casualty -3, Per alien kill -1, Per alien tech -2 | Morale_and_Sanity.md |
| **Sanity Recovery** | Morale | Per successful mission +2, Per week off +5, Meditation +10/week, Promotion +3 | Morale_and_Sanity.md |
| **Sanity Stability** | Morale | Long-term psychological health affecting deployment capability | Morale_and_Sanity.md |
| **Sanity System** | Morale | 0-100 long-term psychological track, loss/recovery rates, deployment effects | Morale_and_Sanity.md |
| **Score Calculation** | Finance | Provincial level aggregated monthly, gains/losses per threat/mission | Finance.md |
| **Score System** | Finance | Metrics on gains/losses, every 20 points = ±1 relation modifier | Finance.md |
| **Simultaneous Campaigns** | Lore | Multiple campaigns active = exponential pressure escalation | Lore.md |
| **Sneaking Energy Drain** | Morale | 0 energy cost (silent energy tracking) | Morale_and_Sanity.md |
| **Specialization Path** | Basescape | One-time choice at Rank 2+, affects unit development | Basescape.md |
| **Specialized Units** | Basescape | Available through tech research and supplier contracts | Basescape.md |
| **Spriniting Energy Loss** | Morale | -10 energy per sprint action | Morale_and_Sanity.md |
| **Stun Damage Decay** | Morale | -2 to -5 per turn automatic decay | Morale_and_Sanity.md |
| **Stun Damage Effects** | Morale | 1-10: -10% acc, 11-20: -20% acc, 21+: -30% acc, severely impaired | Morale_and_Sanity.md |
| **Stun Damage Threshold** | Morale | Fainted at max stun (unconscious) | Morale_and_Sanity.md |
| **Stun Points** | Morale | Separate pool from HP, decay -2 to -5/turn | Morale_and_Sanity.md |
| **Stun System** | Morale | Non-lethal incapacity track, separate from health | Morale_and_Sanity.md |
| **Supplier Discounts** | Finance | Black market suppliers provide discount income | Finance.md |
| **Supplier Dynamics** | Finance | Supplier relations affect availability and pricing | Finance.md |
| **Terrain Effect On Mission** | Geoscape | Terrain affects movement costs, base construction, mission generation | Geoscape.md |
| **Terrain Resources** | Geoscape | Resources impact base efficiency and development | Geoscape.md |
| **Threat Assessment** | Lore | Determines mission frequency and campaign escalation | Lore.md |
| **Transport Craft** | Geoscape | 4 hexes/turn, 400 fuel, 1,600km range, high capacity | Geoscape.md |
| **UFO Mission Scripts** | Lore | Mobile craft executing predetermined movement/action sequences | Lore.md |
| **UFO Missions** | Lore | Mobile craft 3-14 days, points at script steps, can evade interception | Lore.md |
| **Unit Fatigue** | Morale | Energy depletion causes performance degradation and incapacity | Morale_and_Sanity.md |
| **Wound Recovery** | Morale | Light 1w, Moderate 2w, Severe 4w, Critical 8w | Morale_and_Sanity.md |
| **Wound Morale Effect** | Morale | Per wound -1 morale, 3+ wounds panic +50% | Morale_and_Sanity.md |
| **Wound System** | Morale | Light/Moderate/Severe/Critical with recovery times | Morale_and_Sanity.md |
| **Wounds Panic Interaction** | Morale | Multiple wounds (3+) increase panic threshold by 50% | Morale_and_Sanity.md |
| **World Map Hex Grid** | Geoscape | 90×45 hexagonal grid, ~500km per hex coverage | Geoscape.md |
| **World Map System** | Geoscape | Hexagonal grid architecture with provinces, regions, terrain, resources, population | Geoscape.md |
| **Ablative Armor** | Craft | 50% explosive defense, degrades 10% per hit | Weapons_and_Items.md |
| **Acid Damage** | Damage | Corrosive chemical damage, applies Corrosion status | Damage_and_Armor.md |
| **Acid Resistance** | Armor | Light 30%, Medium 50%, Heavy 70%, Acid-Resistant 85% | Damage_and_Armor.md |
| **Action Point Costs** | Weapons | AP determines weapon speed (1-4 AP typical) | Weapons_and_Items.md |
| **Afterburner Module** | Craft | +1 speed bonus, increased fuel consumption | Weapons_and_Items.md |
| **Alien Materials** | Resources | Elerium (200K), Alien Alloy (150K), advanced tech tier | Weapons_and_Items.md |
| **Alien Technology Branch** | Research | Requires captured aliens, unlocks alien weapons/tech | Economy.md |
| **Ammunition Capacity** | Weapons | Max clip affects reload frequency | Weapons_and_Items.md |
| **Armor Class System** | Equipment | Light/Medium/Heavy/Specialized classes with synergies | Weapons_and_Items.md |
| **Armor Degradation** | Armor | Ablative armor loses points with damage | Weapons_and_Items.md |
| **Armor Effectiveness Formula** | Equipment | Final = Base × (1 + (Class-1) × 0.25) × Synergy | Weapons_and_Items.md |
| **Armor Resistance** | Armor | Different armor types reduce specific damage types | Damage_and_Armor.md |
| **Armor Synergy** | Equipment | Class matching +20%, mismatched -15% | Weapons_and_Items.md |
| **Armor Value** | Armor | Damage reduction points (1 = 1 damage blocked) | Damage_and_Armor.md |
| **Autopsy Research** | Research | Study alien biology, unlock specialized abilities | Economy.md |
| **Azine Biome** | Environment | Urban setting: concrete, walls, buildings | Environment.md |
| **Balanced Equipment** | Equipment | Medium class baseline (0% modifiers) | Weapons_and_Items.md |
| **Batch Production** | Manufacturing | Multiple units at once, efficiency scaling | Economy.md |
| **Beam Weapons** | Weapons | Sustained fire (Laser Array 60/turn) | Weapons_and_Items.md |
| **Biome Coverage** | Environment | Urban, Forest, Industrial, Underwater terrain types | Environment.md |
| **Blast Propagation** | Damage | 4 directional waves with independent LOS checks | Damage_and_Armor.md |
| **Blizzard Conditions** | Environment | Visibility 0%, Movement +4 AP, frozen units | Environment.md |
| **Black Market Access** | Economy | Karma/Fame tiers unlock purchase options | Economy.md |
| **Blueprint System** | Manufacturing | Required for manufacturing research | Economy.md |
| **Botanical Terrain** | Environment | Forest biome with dense vegetation | Environment.md |
| **Breakable Wall Destruction** | Terrain | Create rubble (2 AP, 30% cover) | Environment.md |
| **Burning Hazard** | Environment | -5 HP/turn, spreads 20-30%/turn | Environment.md |
| **Burst Fire Mode** | Weapons | -10% accuracy, 3 AP, 2-3× damage | Weapons_and_Items.md |
| **Capacity Weight System** | Equipment | STR-based carrying capacity (6-12 units) | Weapons_and_Items.md |
| **Cargo Pod Module** | Craft | +10 cargo capacity upgrade | Weapons_and_Items.md |
| **Casting Range Weapons** | Weapons | Varies by craft weapon type | Weapons_and_Items.md |
| **Class Mismatch Penalties** | Equipment | Accuracy/armor/movement penalties | Weapons_and_Items.md |
| **Class Synergy Bonus** | Equipment | Matched equipment provides bonuses | Weapons_and_Items.md |
| **Close Quarters** | Combat | Shotgun 4 hex range, high damage | Weapons_and_Items.md |
| **Corrosion Status** | Hazard | Reduces armor effectiveness on hits | Damage_and_Armor.md |
| **Corpse Recovery** | Salvage | Dead units can be processed | Economy.md |
| **Corpse Trading** | Black Market | Ethical concern, karma impact | Economy.md |
| **Cost Multiplier** | Research | 50%-150% per campaign for variety | Economy.md |
| **Craft Armor System** | Craft | Multiple armor types for layered defense | Weapons_and_Items.md |
| **Craft Equipment** | Items | Mounted weapons, defenses, support modules | Weapons_and_Items.md |
| **Craft Fuel Consumption** | Geoscape | Automatic per mission, efficiency varies | Geoscape.md |
| **Craft Logistics** | Craft | Cargo Pod, Fuel Tank, Passenger Cabin modules | Weapons_and_Items.md |
| **Craft Radar Module** | Craft | +100% detection range enhancement | Weapons_and_Items.md |
| **Craft Speed Classes** | Geoscape | Fighter 8, Interceptor 10, Transport 4, Bomber 3, Capital 2 hex/turn | Geoscape.md |
| **Craft Support Systems** | Craft | Logistics and sensor modules | Weapons_and_Items.md |
| **Craft Weapon Hardpoints** | Craft | Left, right, center mounting positions | Weapons_and_Items.md |
| **Crafting Chain** | Manufacturing | Multiple components create complex items | Economy.md |
| **Critical Hit System** | Damage | NO critical hits; damage consistent | Damage_and_Armor.md |
| **Damage Calculation** | Damage | Weapon base × armor resistance × other modifiers | Damage_and_Armor.md |
| **Damage Reduction** | Armor | Base armor value in points | Damage_and_Armor.md |
| **Damage Type System** | Damage | 8 core types: Kinetic, Explosive, Energy, Psi, Stun, Acid, Fire, Frost | Damage_and_Armor.md |
| **Darkness Lighting** | Environment | Pitch Black (visibility 0%) requires special equipment | Environment.md |
| **Day/Night Cycle** | Environment | Affects visibility and combat effectiveness | Environment.md |
| **Defense Craft Module** | Craft | Energy Shield, Armor Plates, Reactive Plating | Weapons_and_Items.md |
| **Dense Forest** | Terrain | 3 AP movement, +2 sight cost, 40% cover | Environment.md |
| **Destructible Terrain** | Environment | Explosions create new tactical opportunities | Environment.md |
| **Difficulty Scaling** | Economy | Early/Mid/Late unit variants | Economy.md |
| **Dimensional War Phase** | Resources | Warp Crystal (500K), Rift Matter (300K) | Weapons_and_Items.md |
| **Distance Penalty** | Damage | 100%→80%→60%→40% by hex distance | Damage_and_Armor.md |
| **Dusk Lighting** | Environment | -10% visibility penalty | Environment.md |
| **Early Firepower** | Weapons | Phase 1: Rifles, Shotguns, Grenades | Weapons_and_Items.md |
| **Electrical Hazard** | Environment | Metal grating terrain creates risk | Environment.md |
| **Elerium Resource** | Resources | 200K, Alien War phase material | Weapons_and_Items.md |
| **Energy Point Cost** | Weapons | Resource consumption per shot | Weapons_and_Items.md |
| **Energy Shield** | Craft | +10 HP, +20 energy, +5 regen/turn | Weapons_and_Items.md |
| **Energy Weapon Branch** | Research | Laser, Plasma, Particle Beam progression | Economy.md |
| **Enhanced Radar Module** | Craft | +100% detection range | Weapons_and_Items.md |
| **Equipment Balance** | Economy | Profit margins and reinvestment strategy | Economy.md |
| **Equipment Durability** | Items | Wear/degradation mechanics | Weapons_and_Items.md |
| **Equipment Modification** | Items | Post-research equipment customization | Weapons_and_Items.md |
| **Equipment Synergy** | Equipment | Class matching provides bonuses/penalties | Weapons_and_Items.md |
| **Escape Route Creation** | Environment | Explosive destruction enables tactical paths | Environment.md |
| **Event System Diplomacy** | Economy | 5 event categories with 20+ event types | Economy.md |
| **Explosible Bomb** | Weapons | Various explosive weapon types | Weapons_and_Items.md |
| **Explosion Area Effect** | Damage | Radius-based damage with multiple waves | Damage_and_Armor.md |
| **Explosion Armor Mechanics** | Damage | Walls block 100%, units block 50% | Damage_and_Armor.md |
| **Explosion Wave Propagation** | Damage | Independent directions, distance scaling | Damage_and_Armor.md |
| **Extended Fuel Tank** | Craft | +50% range upgrade | Weapons_and_Items.md |
| **Extra Capacity** | Craft | Cargo Pod and Passenger Cabin upgrades | Weapons_and_Items.md |
| **Facility Bonus Research** | Research | -10-30% research time reduction | Economy.md |
| **Facility Upgrade Research** | Research | Improve base facility capabilities | Economy.md |
| **Failed Research** | Research | Cannot fail; can cancel with credit return | Economy.md |
| **Fire Damage Hazard** | Environment | -5 HP/turn, spreads 20-30%/turn | Environment.md |
| **Fire Extinguish** | Environment | Water, medikit, suppression action | Environment.md |
| **Firing Mode Selection** | Weapons | Choose mode before shot | Weapons_and_Items.md |
| **Firing Mode System** | Weapons | Snap, Aimed, Burst, Auto modes | Weapons_and_Items.md |
| **Flashbang Effect** | Weapons | 1-turn stun, 2 hex radius, non-lethal | Weapons_and_Items.md |
| **Flashlight Equipment** | Items | +2 night vision, passive, always active | Weapons_and_Items.md |
| **Flare Equipment** | Items | +3 hex vision for 2 turns | Weapons_and_Items.md |
| **Flying Unit Movement** | Combat | Water crossing penalty-free | Environment.md |
| **Foam Terrain** | Terrain | Difficult terrain, high movement cost | Environment.md |
| **Forest Biome** | Environment | Trees, grass, streams, 40% cover | Environment.md |
| **Forest Movement** | Terrain | 2 AP movement, +1 sight cost | Environment.md |
| **Frozen Status** | Hazard | Movement penalty, accuracy penalty | Environment.md |
| **Fuel Consumption** | Resources | Automatic per mission, efficiency-based | Weapons_and_Items.md |
| **Fuel Resource** | Resources | 5K early, powers craft travel | Weapons_and_Items.md |
| **Fuel Tank Upgrade** | Craft | +50% range, logistics upgrade | Weapons_and_Items.md |
| **Gas Hazard** | Environment | Cumulative toxin, -1 HP/turn per layer | Environment.md |
| **Gas Poison Type** | Hazard | HP damage, various poison types | Environment.md |
| **Gas Dissipation** | Hazard | Wind effect, time-based dispersal | Environment.md |
| **Glass Wall** | Terrain | 5 HP, fragile, transparent until destroyed | Environment.md |
| **Grenade Launcher** | Weapons | 12 hex, 2 AP, 30 area damage | Weapons_and_Items.md |
| **Grenade Equipment** | Items | 1 AP, 30 damage, area effect | Weapons_and_Items.md |
| **Ground Combat** | Research | Scientist efficiency +10% per related project | Economy.md |
| **Group Loadout** | Equipment | Squad equipment composition affects effectiveness | Weapons_and_Items.md |
| **Hand-to-Hand Combat** | Weapons | Melee weapons (Knife, Sword, Plasma Blade) | Weapons_and_Items.md |
| **Hangar Storage** | Equipment | Craft capacity (4-8 typical), grid-based | Weapons_and_Items.md |
| **Hazardous Terrain** | Environment | Lava, Radiation, Contamination types | Environment.md |
| **Hazmat Suit Armor** | Armor | STR 6, +100% poison resistance | Weapons_and_Items.md |
| **Heavy Armor Class** | Equipment | High protection, low mobility | Weapons_and_Items.md |
| **Heavy Assault Armor** | Armor | STR 10, -2 hex, -2 AP, 25 armor | Weapons_and_Items.md |
| **Heavy Cannon Weapon** | Weapons | 20 hex, 3 AP, 60 damage, specialist only | Weapons_and_Items.md |
| **Heavy Ordnance Research** | Research | Tier 2: 150 man-days, heavy weapons | Economy.md |
| **Heavy Weapon Recoil** | Weapons | Light armor struggles (-15% accuracy) | Weapons_and_Items.md |
| **Hex Movement** | Environment | Base 1 AP per hex | Environment.md |
| **High Altitude** | Geoscape | HIGH detection (+100%) | Geoscape.md |
| **High Damage Output** | Weapons | Shotgun 45, Sniper 35, Heavy Cannon 60 | Weapons_and_Items.md |
| **Honey Adhesive** | Terrain | Sticky terrain, high movement cost | Environment.md |
| **Hospital Facility** | Equipment | +2 HP/week healing | Weapons_and_Items.md |
| **Hostile Craft** | Craft | No repair systems during interception | Weapons_and_Items.md |
| **Hot Lava Terrain** | Terrain | -10 HP/turn, impassable | Environment.md |
| **Hybrid Item Analysis** | Research | Combine multiple research streams | Economy.md |
| **Ice Floor Slipping** | Terrain | +1 move cost, chance of falling | Environment.md |
| **Incendiary Grenade** | Weapons | Fire effect, spreading damage | Weapons_and_Items.md |
| **Incendiary Research** | Research | Tier 2: 120 man-days, fire weapons | Economy.md |
| **Industrial Biome** | Environment | Metal, machinery, narrow passages | Environment.md |
| **Insulated Armor** | Armor | 95% stun reduction | Damage_and_Armor.md |
| **Interception Accuracy** | Weapons | Craft weapons 75-85% base | Weapons_and_Items.md |
| **Interrogation Research** | Research | Extract intelligence from prisoners | Economy.md |
| **Inventory System** | Items | 3 equipment slots, capacity limits | Weapons_and_Items.md |
| **Item Acquisition** | Economy | Missions, trading, synthesis, suppliers | Weapons_and_Items.md |
| **Item Capacity** | Equipment | Weight-based carrying capacity | Weapons_and_Items.md |
| **Item Categories** | Items | Resources, Weapons, Armor, Craft, Lore | Weapons_and_Items.md |
| **Item Modification** | Items | Post-research customization | Weapons_and_Items.md |
| **Item Properties** | Items | Weight, cost, effectiveness | Weapons_and_Items.md |
| **Item Synthesis** | Economy | Convert resources (Metal → Titanium) | Weapons_and_Items.md |
| **Item Weight** | Equipment | 0.5-3 weight units per item | Weapons_and_Items.md |
| **Karma Impact** | Trading | Prisoner options affect reputation | Economy.md |
| **Kinetic Armor** | Armor | Light 50%, Medium 30%, Heavy 10% | Damage_and_Armor.md |
| **Kinetic Damage** | Damage | Firearms, melee impact | Damage_and_Armor.md |
| **Laser Technology** | Research | Tier 3: 200 man-days, basic energy weapons | Economy.md |
| **Lava Hazard** | Terrain | -10 HP/turn, impassable | Environment.md |
| **Layered Defense** | Armor | Multiple armor systems combined | Weapons_and_Items.md |
| **Light Armor Class** | Equipment | High mobility, low protection | Weapons_and_Items.md |
| **Light Scout Armor** | Armor | STR 5, +1 hex speed, 5 armor | Weapons_and_Items.md |
| **Line of Fire** | Weapons | Projectile path, some obstacles ignored | Weapons_and_Items.md |
| **Lore Item System** | Items | Non-mechanical story objects | Weapons_and_Items.md |
| **Low Altitude** | Geoscape | LOW detection (+30%) | Geoscape.md |
| **Manufacturing Cost** | Economy | Research + Materials + Labor | Economy.md |
| **Manufacturing Queue** | Manufacturing | Batch production, workshop capacity | Economy.md |
| **Manufacturing System** | Manufacturing | Requires tech, resources, time | Economy.md |
| **Manufacturing Profit** | Economy | Cost vs. value determines profit | Economy.md |
| **Manufacturing Types** | Manufacturing | Equipment, crafting chains, batch | Economy.md |
| **Marketplace Pricing** | Economy | Phase-based: Early (premium), Mid (balanced), Late (competitive) | Economy.md |
| **Marketplace System** | Economy | Buy/sell equipment, research-gated | Economy.md |
| **Maximum Clip** | Weapons | Ammunition capacity affects reload | Weapons_and_Items.md |
| **Melee Combat System** | Weapons | Hand-to-hand, distance-based | Weapons_and_Items.md |
| **Melee Damage Formula** | Weapons | Base + STR bonus ± weapon bonus | Weapons_and_Items.md |
| **Melee Weapon** | Equipment | Knife, Sword, Plasma Blade | Weapons_and_Items.md |
| **Metal Armor** | Armor | Conductive, electrical risk | Environment.md |
| **Metal Grating** | Terrain | Conductive floor, electrical hazard | Environment.md |
| **Metal Wall** | Terrain | 50 HP, destructible | Environment.md |
| **Mine Equipment** | Items | 2 AP, 40 damage, proximity-triggered | Weapons_and_Items.md |
| **Missile Pod** | Weapons | 60 km, 80 area damage, 2 turn cooldown | Weapons_and_Items.md |
| **Mission Loot** | Salvage | Credits from battlescape loot | Economy.md |
| **Mission Loot Value** | Economy | Equipment sales from missions | Economy.md |
| **Mobility Penalty** | Armor | Heavy armor -2 hex/turn | Weapons_and_Items.md |
| **Mode Accuracy Modifier** | Weapons | Snap -20%, Aimed +20%, Burst -10%, Auto -20% | Weapons_and_Items.md |
| **Mode AP Cost** | Weapons | Snap 1 AP, Aimed 3 AP, Burst 3 AP, Auto 4 AP | Weapons_and_Items.md |
| **Motion Scanner** | Items | +3 sight range, 50 turn duration | Weapons_and_Items.md |
| **Mud Terrain** | Terrain | Dirt in rain, increased movement cost | Environment.md |
| **Multiple Armor Systems** | Armor | Layered defense combinations | Weapons_and_Items.md |
| **Multiple Wave Propagation** | Damage | Explosion waves bypass single units | Damage_and_Armor.md |
| **Multiplier Scaling** | Research | 50%-150% random cost per campaign | Economy.md |
| **Night Combat** | Environment | Requires night vision/light source | Environment.md |
| **Night Vision** | Equipment | +5 night vision, 100 turn duration | Weapons_and_Items.md |
| **Night Vision Goggles** | Items | Enable normal visibility at night | Weapons_and_Items.md |
| **No Critical Hits** | Damage | Consistent damage; success through positioning | Damage_and_Armor.md |
| **Non-Lethal Weapons** | Weapons | Flashbang, Stun baton, Shock grenades | Weapons_and_Items.md |
| **Non-Mechanical Items** | Items | Lore items, collectibles | Weapons_and_Items.md |
| **Non-Repeatable Research** | Research | One-time unlocks (technology, facilities) | Economy.md |
| **Optimal Range** | Weapons | Zero modifier zone (Rifle 3-5 hex) | Weapons_and_Items.md |
| **Operational Expenses** | Economy | Equipment, maintenance, facilities, craft | Economy.md |
| **Operational Hazard** | Environment | Facility Damage, Craft Malfunction events | Environment.md |
| **Organization Traits** | Equipment | Squad loadout characteristics | Weapons_and_Items.md |
| **Orthogonal Grid** | Equipment | Square grid base construction (40×60 typical) | Basescape.md |
| **Outer Armor Layer** | Armor | Class determines synergy effects | Weapons_and_Items.md |
| **Overwatch Action** | Combat | Readied units interrupt with reaction attacks | Weapons_and_Items.md |
| **Particle Beam** | Research | Ultimate energy weapons (400 man-days) | Economy.md |
| **Passenger Cabin** | Craft | +2 crew capacity upgrade | Weapons_and_Items.md |
| **Penetrating Armor** | Armor | Energy weapons penetrate effectively | Damage_and_Armor.md |
| **Phase-Based Resources** | Resources | Campaign phases unlock resource tiers | Weapons_and_Items.md |
| **Phase-Based Pricing** | Economy | Changes across campaign progression | Economy.md |
| **Pistol Weapon** | Weapons | 8 hex, 1-2 AP, 70% accuracy, 12 damage | Weapons_and_Items.md |
| **Pitch Black** | Environment | Visibility 0%, requires special equipment | Environment.md |
| **Plan Caster Weapon** | Weapons | 30 km, 70 damage, ignores 50% armor | Weapons_and_Items.md |
| **Plasma Technology** | Research | Tier 3: 300 man-days, advanced energy weapons | Economy.md |
| **Point Defense** | Weapons | 20 km, 15 damage, anti-missile | Weapons_and_Items.md |
| **Poison Gas Type** | Hazard | HP damage accumulation | Environment.md |
| **Poison Resistance** | Armor | Hazmat Suit +100% | Weapons_and_Items.md |
| **Power Source** | Resources | Energy Sources, facility/weapon power | Weapons_and_Items.md |
| **Precision Firearms** | Research | Tier 2: 100 man-days, sniper rifles | Economy.md |
| **Prisoner Capture** | Items | HP >0 at mission end captured | Weapons_and_Items.md |
| **Prisoner Execute** | Items | -5 karma, eliminate prisoner | Weapons_and_Items.md |
| **Prisoner Exchange** | Items | +3 karma for trade | Weapons_and_Items.md |
| **Prisoner Experiment** | Items | -3 karma, research generation | Weapons_and_Items.md |
| **Prisoner Interrogation** | Items | Reveals unit class, ±0 karma | Weapons_and_Items.md |
| **Prisoner Conversion** | Items | 60% success rate to player faction | Weapons_and_Items.md |
| **Prisoner Release** | Items | +5 karma, diplomatic bonus | Weapons_and_Items.md |
| **Prisoner Research** | Items | Multiple topics per prisoner | Weapons_and_Items.md |
| **Prisoner Selling** | Items | +Credits, -Karma | Weapons_and_Items.md |
| **Prisoner Escape** | Items | 1% per prisoner per day | Weapons_and_Items.md |
| **Prisoner Lifetime** | Items | 30 + (Max HP × 2) days | Weapons_and_Items.md |
| **Prison Facility** | Equipment | 3×3, 10 prisoners, 12 power, 100K | Weapons_and_Items.md |
| **Production Queue** | Manufacturing | Batch production workflow | Economy.md |
| **Profit Margins** | Economy | Manufacturing cost vs. value | Economy.md |
| **Projectile Path** | Weapons | Direct line, obstacles vary | Weapons_and_Items.md |
| **Projectile Ricochet** | Weapons | Bounce off walls (future feature) | Weapons_and_Items.md |
| **Psi Armor Resistance** | Armor | All 0%, Psi Shield 80% | Damage_and_Armor.md |
| **Psi Damage Type** | Damage | Alien mental attacks, bypasses armor | Damage_and_Armor.md |
| **Psi Shield** | Armor | 80% psi reduction, specialized defense | Damage_and_Armor.md |
| **Psionic Amplifier** | Items | Enables psychic abilities, 30 EP per use | Weapons_and_Items.md |
| **Psionic Weapon** | Weapons | Alien psi blast, mind control beam | Damage_and_Armor.md |
| **Quantum Processor** | Resources | 1M cost, endgame material | Weapons_and_Items.md |
| **Quantum War Phase** | Resources | Processor (1M), Reality Anchor (800K) | Weapons_and_Items.md |
| **Question Targeting** | Combat | Target selection affects modifiers | Weapons_and_Items.md |
| **Quick Reflexes** | Combat | AP carry over with trait | Weapons_and_Items.md |
| **Radiation Hazard** | Environment | Stun damage, -Sanity effects | Environment.md |
| **Rain Weather** | Environment | Visibility 75%, Movement +1 AP, Accuracy -10% | Environment.md |
| **Range Accuracy** | Weapons | 0-2x multiplier in formula | Weapons_and_Items.md |
| **Range Optimal** | Weapons | Point blank +20%, Optimal 0%, Medium -10% | Weapons_and_Items.md |
| **Reactive Plating** | Armor | Explosive +40%, Kinetic +20% | Weapons_and_Items.md |
| **Readiness Combat** | Equipment | Stationary aiming (+3 AP) | Weapons_and_Items.md |
| **Reality Anchor** | Resources | 800K cost, endgame material | Weapons_and_Items.md |
| **Recoil Effect** | Weapons | Light user struggles with heavy weapons | Weapons_and_Items.md |
| **Recoil Penalty** | Weapons | Lighter armor struggles (-15% accuracy) | Weapons_and_Items.md |
| **Research Branching** | Research | 5 major branches with tiers | Economy.md |
| **Research Cancellation** | Research | 50-75% credit return, progress retained | Economy.md |
| **Research Completion** | Research | Unlocks manufacturing capabilities | Economy.md |
| **Research Dependency** | Research | Prerequisites required | Economy.md |
| **Research Facility** | Research | Provides scientist capacity | Economy.md |
| **Research Facility Bonus** | Research | -10-30% time reduction | Economy.md |
| **Research Milestone** | Research | Unlocks new items/capabilities | Economy.md |
| **Research Pause** | Research | Stop without progress loss | Economy.md |
| **Research Priority** | Research | Higher priority completes faster | Economy.md |
| **Research Progress** | Research | Daily percentage tracking | Economy.md |
| **Research Type** | Research | Technology, Analysis, Interrogation, Autopsy, Facility | Economy.md |
| **Research Tree** | Research | 5 branches: Weapons, Armor, Alien, Facilities, Support | Economy.md |
| **Repeatable Research** | Research | Item analysis (prisoners), autopsies | Economy.md |
| **Replicating Research** | Research | Item-based research repeatable | Economy.md |
| **Requirements Research** | Research | Facility capacity, prerequisites, resources, credits | Economy.md |
| **Research Scientist** | Research | Conduct research, paid per day | Economy.md |
| **Research Specialization** | Research | +10% efficiency per related project | Economy.md |
| **Research Tree Structure** | Research | Weapons, Armor, Alien Tech, Facilities, Support | Economy.md |
| **Resource Acquisition** | Economy | Missions, trading, synthesis, suppliers | Weapons_and_Items.md |
| **Resource Consumption** | Research | Projects consume specific components | Economy.md |
| **Resource List** | Items | Fuel, Energy, Materials, Biological, Alien | Weapons_and_Items.md |
| **Resource Material** | Items | Strategic materials for manufacturing | Weapons_and_Items.md |
| **Resource Phase** | Resources | Campaign phases unlock tiers | Weapons_and_Items.md |
| **Resource Synthesis** | Economy | Convert common → rare materials | Economy.md |
| **Resource Trading** | Economy | Sell at 50% purchase price | Economy.md |
| **Resource Type** | Items | Fuel, Energy, Construction, Biological, Alien | Weapons_and_Items.md |
| **Rifle Accuracy** | Weapons | 70% base, 15 hex range, 18 damage | Weapons_and_Items.md |
| **Rifle Weapon** | Weapons | 15 hex, 2 AP, 70%, 18 damage | Weapons_and_Items.md |
| **Rubble Cover** | Terrain | Destroyed wall becomes rubble | Environment.md |
| **Rubble Creation** | Terrain | Explosion destruction creates passage | Environment.md |
| **Rubble Terrain** | Terrain | 2 AP, 30% cover value | Environment.md |
| **Runway Construction** | Manufacturing | Equipment manufacturing process | Economy.md |
| **Salvage Corpse** | Economy | Dead units can be processed | Economy.md |
| **Salvage System** | Economy | Corpse, UFO, mission site recovery | Economy.md |
| **Salvage UFO** | Economy | Alien materials from crashed UFOs | Economy.md |
| **Sand Biome** | Environment | Desert terrain, limited cover | Environment.md |
| **Sand Storm** | Environment | Desert weather, visibility reduction | Environment.md |
| **Sanity Recovery** | Equipment | Hospital +1 sanity/week | Weapons_and_Items.md |
| **Science Team** | Research | Scientists conduct research | Economy.md |
| **Scout Armor** | Armor | Light with +1 movement | Weapons_and_Items.md |
| **Screen Angle** | Weapons | Projectile path interaction | Weapons_and_Items.md |
| **Self-Destruct** | Armor | Tactical option | Weapons_and_Items.md |
| **Selling Equipment** | Economy | Black market prices, reputation | Economy.md |
| **Sentry Fire** | Combat | Overwatch units interrupt | Weapons_and_Items.md |
| **Shallow Water** | Terrain | 2 AP movement, partial cover | Environment.md |
| **Shield Energy** | Armor | Shields drain power | Weapons_and_Items.md |
| **Shield Mechanics** | Armor | Energy shields, power-dependent | Weapons_and_Items.md |
| **Shield System** | Armor | Shield types and mechanics | Weapons_and_Items.md |
| **Shock Weapon** | Weapons | Non-lethal stun-based | Damage_and_Armor.md |
| **Shotgun Accuracy** | Weapons | 60% base, 4 hex range, 45 damage | Weapons_and_Items.md |
| **Shotgun Weapon** | Weapons | 4 hex, 2 AP, 60%, 45 damage | Weapons_and_Items.md |
| **Shotgun Blast** | Weapons | 3-hex area effect | Weapons_and_Items.md |
| **Sight Block** | Damage | LOS blocking percentage | Damage_and_Armor.md |
| **Sight Cost** | Terrain | Obstacle visibility difficulty | Environment.md |
| **Silent Movement** | Combat | Sneaking (3 AP + MP), +1 Concealment | Weapons_and_Items.md |
| **Sit Fire** | Combat | Stationary aiming (+3 AP, +20%) | Weapons_and_Items.md |
| **Snap Shot Mode** | Weapons | -20% accuracy, 1 AP, quick fire | Weapons_and_Items.md |
| **Snow Biome** | Environment | Heavy penalties (+3 AP), temperature damage | Environment.md |
| **Snow Weather** | Environment | Visibility 25%, Movement +3 AP, Accuracy -25% | Environment.md |
| **Sniper Accuracy** | Weapons | 85% base, 25 hex range, 35 damage | Weapons_and_Items.md |
| **Sniper Ghillie** | Armor | STR 6, +10% accuracy, +1 sight | Weapons_and_Items.md |
| **Sniper Rifle** | Weapons | 25 hex, 3 AP, 85%, 35 damage | Weapons_and_Items.md |
| **Sniper Range** | Weapons | 25 hex optimal range | Weapons_and_Items.md |
| **Sound Footstep** | Combat | Running generates detection risk | Weapons_and_Items.md |
| **Sound Mechanic** | Combat | Running creates noise | Weapons_and_Items.md |
| **Specialized Armor** | Armor | Variable properties (Hazmat, Medic, Sniper, Stealth) | Weapons_and_Items.md |
| **Specialized Class** | Equipment | Unique properties, variable synergies | Weapons_and_Items.md |
| **Specialized Equipment** | Armor | Hazmat, Medic, Sniper, Stealth variants | Weapons_and_Items.md |
| **Specialized Weapon** | Weapons | Exotic (EMP, Concussive, Tractor) | Weapons_and_Items.md |
| **Speed Bonus** | Armor | Light armor +15% movement | Weapons_and_Items.md |
| **Speed Downgrade** | Armor | Heavy armor -15% movement | Weapons_and_Items.md |
| **Stacked Gas** | Hazard | Multiple layers cumulative | Environment.md |
| **Standard Armor** | Armor | +50 health, budget baseline | Weapons_and_Items.md |
| **Standard Marketplace** | Economy | Buy/sell equipment, research-gated | Economy.md |
| **Stationary Aiming** | Weapons | Aimed shot (+20%, 3 AP) | Weapons_and_Items.md |
| **Status Effect** | Hazard | Burning, Stun, Frozen persistence | Environment.md |
| **Steam Cloud** | Hazard | Smoke effect (20% LOS) | Environment.md |
| **Stealth Budget** | Geoscape | C3: 50-100 points starting | Geoscape.md |
| **Stealth Kill** | Combat | Silent assassination (0 cost) | Weapons_and_Items.md |
| **Stealth Movement** | Combat | Sneaking (3 AP + MP), silent | Weapons_and_Items.md |
| **Stealth Suit** | Armor | STR 5, +20% stealth, 20K | Weapons_and_Items.md |
| **Stone Floor** | Terrain | Indestructible wall | Environment.md |
| **Storage Capacity** | Equipment | Unit inventory limits | Weapons_and_Items.md |
| **Storage Facility** | Equipment | Base equipment/resource storage | Weapons_and_Items.md |
| **Storm Weather** | Environment | Visibility 50%, Movement +2 AP, Accuracy -20% | Environment.md |
| **Stream Terrain** | Terrain | Shallow water (2-3 tiles) | Environment.md |
| **Street Biome** | Terrain | Urban concrete, buildings | Environment.md |
| **Strength Requirement** | Armor | STR 5-10 by class | Weapons_and_Items.md |
| **Strength Stat Penalty** | Armor | -1 hex/turn per 2 STR below requirement | Weapons_and_Items.md |
| **Stun Armor Resistance** | Armor | Light 70%, Medium 50%, Heavy 30% | Damage_and_Armor.md |
| **Stun Damage Type** | Damage | Shock weapons, non-lethal | Damage_and_Armor.md |
| **Stun Effect** | Combat | Applies Stun status | Damage_and_Armor.md |
| **Stunning Weapon** | Weapons | Shock rifles, batons, grenades | Damage_and_Armor.md |
| **Submarine Development** | Resources | Aquatic War phase military | Weapons_and_Items.md |
| **Substance Decay** | Hazard | Smoke/gas dispersal | Environment.md |
| **Supply Contract** | Economy | Faction steady income | Economy.md |
| **Supply Delay** | Economy | Supply disruption tension | Economy.md |
| **Supply System** | Economy | Equipment transfer between bases | Economy.md |
| **Supply Transfer** | Economy | Time/cost movement | Economy.md |
| **Supplier Dynamics** | Economy | Relations affect pricing | Economy.md |
| **Supplier Relations** | Economy | Relationship affects power | Economy.md |
| **Support Module** | Craft | Logistics, sensors | Weapons_and_Items.md |
| **Support Research** | Research | Medical, Psychological, Transportation | Economy.md |
| **Support System Craft** | Craft | Cargo, Fuel, Passenger modules | Weapons_and_Items.md |
| **Swamp Biome** | Terrain | 3 AP movement, sanity -1/5 turns | Environment.md |
| **Swamp Terrain** | Terrain | Difficult (3 AP), sanity penalty | Environment.md |
| **Sustained Beam** | Weapons | Laser Array (60/turn) | Weapons_and_Items.md |
| **Swath Combat** | Weapons | Auto fire -20%, 4 AP | Weapons_and_Items.md |
| **Tactical Destruction** | Environment | Explosive mid-battle terrain change | Environment.md |
| **Tactical Advantage** | Items | Equipment positioning matters | Weapons_and_Items.md |
| **Tactical Training** | Research | Melee (30 man-days) | Economy.md |
| **Tank Build** | Equipment | Heavy armor + heavy weapon | Weapons_and_Items.md |
| **Tapping Round** | Weapons | Aimed shot (3 AP, +20%) | Weapons_and_Items.md |
| **Target Acquisition** | Combat | Target selection modifiers | Weapons_and_Items.md |
| **Team Accuracy** | Equipment | Squad loadout effectiveness | Weapons_and_Items.md |
| **Team Loadout** | Equipment | Squad equipment composition | Weapons_and_Items.md |
| **Tech Tree** | Research | Dependencies required | Economy.md |
| **Tech Tree Structure** | Research | 5 branches with tiers | Economy.md |
| **Temperature Damage** | Hazard | Snow/ice (-1 stun/turn) | Environment.md |
| **Terrain Blocking** | Terrain | Obstacles block movement | Environment.md |
| **Terrain Cover** | Terrain | Partial protection (0-100%) | Environment.md |
| **Terrain Destruction** | Damage | Explosive AoE modifies | Environment.md |
| **Terrain Modification** | Environment | Explosions change LOS/LOF | Environment.md |
| **Terrain Movement** | Environment | Base 1 AP, modified | Environment.md |
| **Terrain Type** | Terrain | Floor, Wall, Water, Difficult, Cover | Environment.md |
| **Thermal Imaging** | Combat | Radar/thermal in darkness | Environment.md |
| **Thermite Weapon** | Weapons | Burning weapon | Weapons_and_Items.md |
| **Thrown Item** | Weapons | Grenade 3 hex, Flare 3 hex | Weapons_and_Items.md |
| **Throw Action** | Weapons | 1 AP, grenade/thrown weapon | Weapons_and_Items.md |
| **Titanium Material** | Resources | Mid-tier (Metal + Fuel synthesis) | Weapons_and_Items.md |
| **Toggling Weapon** | Weapons | Select mode before shot | Weapons_and_Items.md |
| **Tractor Weapon** | Weapons | Specialty craft weapon | Weapons_and_Items.md |
| **Training Facility** | Equipment | Strength stat progression | Weapons_and_Items.md |
| **Transfer System** | Economy | Equipment movement | Economy.md |
| **Transportation Research** | Research | Transportation technology | Economy.md |
| **Transparent Mechanic** | Terrain | Glass transparent until destroyed | Environment.md |
| **Trench Terrain** | Terrain | Underwater navigation | Environment.md |
| **Troop Transport** | Craft | Passenger cabin +2 crew | Weapons_and_Items.md |
| **Tunnel Terrain** | Terrain | Underground passages | Environment.md |
| **Tunnel Visibility** | Terrain | Confined space, increased LOS | Environment.md |
| **Two-Stage Armor** | Armor | Different walls vs. units | Damage_and_Armor.md |
| **Type Advantage** | Damage | Damage type armor penetration | Damage_and_Armor.md |
| **Ultimate Phase** | Resources | Quantum Processor (1M) | Weapons_and_Items.md |
| **Underwater Biome** | Environment | Water, rocks, trenches | Environment.md |
| **Underwater Combat** | Terrain | Aquatic units advantage | Environment.md |
| **Unit Armor Synergy** | Equipment | Class matching bonuses | Weapons_and_Items.md |
| **Unit Class Synergy** | Equipment | Medic + Medikit +50% | Weapons_and_Items.md |
| **Unit Equipment** | Equipment | Military classification loadout | Weapons_and_Items.md |
| **Unit Fatigue** | Environment | Energy depletion | Environment.md |
| **Unit Inventory** | Equipment | 3 slots (primary, secondary, armor) | Weapons_and_Items.md |
| **Unit Type Compatibility** | Items | Biological heal, mechanical repair | Weapons_and_Items.md |
| **Unit Vision** | Environment | Night vision, light sources, radar | Environment.md |
| **Uranium Material** | Resources | 100K, Advanced Human phase | Weapons_and_Items.md |
| **Urban Biome** | Environment | Concrete, walls, buildings | Environment.md |
| **Urban Hazard** | Environment | Fuel leaks (fire), electrical | Environment.md |
| **Utility Item** | Items | Flare, Scanner, Amplifier, Vision | Weapons_and_Items.md |
| **Value Markup** | Economy | Manufacturing profit | Economy.md |
| **Variant Weapon** | Weapons | Different firing modes | Weapons_and_Items.md |
| **Vault Storage** | Equipment | Base storage facility | Weapons_and_Items.md |
| **Vehicle Transport** | Craft | Unit transport during interception | Weapons_and_Items.md |
| **Velocity Impact** | Weapons | Projectile speed/range | Weapons_and_Items.md |
| **Vendors Marketplace** | Economy | Marketplace suppliers | Economy.md |
| **Ventilation Hazard** | Hazard | Gas venting | Environment.md |
| **Vertical Combat** | Environment | Elevation (+1 AP/level) | Environment.md |
| **Vertical Navigation** | Environment | Elevation system | Environment.md |
| **Virtual War Phase** | Resources | Data Core, Processing Power | Weapons_and_Items.md |
| **Vision Penalty** | Environment | Night (-50%), Pitch Black (impossible) | Environment.md |
| **Vision System** | Environment | Day (100%), Dusk (-10%), Night (-50%), Pitch Black (0%) | Environment.md |
| **Visibility Effect** | Environment | Weather and time | Environment.md |
| **Vital Tracking** | Equipment | Equipment status (degradation) | Weapons_and_Items.md |
| **Volcanic Terrain** | Terrain | Lava biome extreme hazards | Environment.md |
| **Volley Fire** | Combat | Multiple shots, auto spray | Weapons_and_Items.md |
| **Wall Blast Protection** | Damage | Walls block 100% explosion | Damage_and_Armor.md |
| **Wall Destruction** | Terrain | Explosives create rubble/openings | Environment.md |
| **Wall Destruction Path** | Environment | Create escape routes | Environment.md |
| **Wall Durability** | Terrain | Stone (indestructible), Wood (20 HP), Metal (50 HP), Glass (5 HP) | Environment.md |
| **Warehouse Storage** | Equipment | Facility storage upgrade | Weapons_and_Items.md |
| **Water Biome** | Environment | Shallow (2 AP), Deep (3 AP) | Environment.md |
| **Water Crossing** | Terrain | Movement cost by depth | Environment.md |
| **Water Depth** | Terrain | Shallow vs. Deep | Environment.md |
| **Water Fire Interaction** | Terrain | Water extinguishes fire | Environment.md |
| **Weather Condition** | Environment | Clear, Rain, Storm, Snow, Blizzard | Environment.md |
| **Weather Effect** | Environment | Visibility/Movement/Accuracy | Environment.md |
| **Weld Technique** | Manufacturing | Equipment assembly | Economy.md |
| **Wreckage Cover** | Terrain | Destroyed ship/UFO cover | Environment.md |
| **Warp Material** | Resources | Warp Crystal (500K) | Weapons_and_Items.md |
| **Zrbite Material** | Resources | 250K, Aquatic War phase | Weapons_and_Items.md |
| **Zoning Tactics** | Environment | Terrain-based positioning | Environment.md |

---

## SECTION X: Fame, Karma & Reputation Systems

| **Mechanic Name** | **System** | **Description** | **Source** |
|---|---|---|---|
| **Karma System** | Politics | Moral alignment (-100 to +100), passive decay to 0, affects advisor access and mission gating | Fame_Karma_Reputation.md |
| **Fame System** | Politics | Public awareness (0-100), passive decay, affects mission difficulty and UFO attention | Fame_Karma_Reputation.md |
| **Reputation System** | Politics | Legal legitimacy (0-100), +1 per quarter (no decay), affects diplomatic leverage | Fame_Karma_Reputation.md |
| **Score System** | Politics | Humanity saved per country (0-∞), permanent accumulation, affects ending | Fame_Karma_Reputation.md |
| **Karma Decay Mechanics** | Politics | Passive decay toward 0 (modder-configurable rate) | Fame_Karma_Reputation.md |
| **Fame Decay Mechanics** | Politics | Passive decay toward 0, fades without activity (modder-configurable) | Fame_Karma_Reputation.md |
| **Reputation Accumulation** | Politics | +1 per quarter automatic, never decreases, reflects permanent authority | Fame_Karma_Reputation.md |
| **System Independence** | Politics | Karma/Fame/Reputation/Score tracked independently, no cross-linking | Fame_Karma_Reputation.md |
| **Mission Gating Karma** | Missions | Some missions require Karma threshold (e.g., +50 minimum) | Fame_Karma_Reputation.md |
| **Advisor Karma Locks** | Units | Evil advisors require Karma -50+, good advisors require +50+, neutral any | Fame_Karma_Reputation.md |
| **Fame Mission Generation** | Geoscape | Higher Fame increases mission offers and difficulty scaling | Fame_Karma_Reputation.md |
| **Fame UFO Attention** | Geoscape | Aliens prioritize famous organizations (more interception attempts) | Fame_Karma_Reputation.md |
| **Reputation Diplomatic Bonus** | Diplomacy | Higher Reputation better negotiation results with countries | Fame_Karma_Reputation.md |
| **Reputation Funding Impact** | Finance | Government grants affected by Reputation (higher = better) | Fame_Karma_Reputation.md |
| **Score Per Mission** | Missions | Each mission saves population points (modder-defined per mission) | Fame_Karma_Reputation.md |
| **Score Country Tracking** | Politics | Per-country Score tracking (USA Score ≠ China Score) | Fame_Karma_Reputation.md |
| **Ending Determination Score** | Meta | Total Score across all countries affects ending cinematics | Fame_Karma_Reputation.md |

---

## SECTION XI: Hex Coordinate System & Navigation

| **Mechanic Name** | **System** | **Description** | **Source** |
|---|---|---|---|
| **Axial Coordinates** | Navigation | Universal (q, r) system for all maps (Geoscape/Battlescape/Basescape) | Hex_Coordinate_System.md |
| **Vertical Axial Layout** | Navigation | Flat-top hexagons, odd columns shifted down 0.5 hex height | Hex_Coordinate_System.md |
| **Cube Coordinates Conversion** | Navigation | x=q, z=r, y=-x-z for distance calculations | Hex_Coordinate_System.md |
| **Hex Distance Formula** | Navigation | Distance = (|x1-x2| + |y1-y2| + |z1-z2|) / 2 | Hex_Coordinate_System.md |
| **Six Neighbors System** | Navigation | Each hex has 6 neighbors: E, SE, SW, W, NW, NE directions | Hex_Coordinate_System.md |
| **Map Block System** | Navigation | 15 hexes per block (3-4-5-4-3 pattern), arranged in grid for battles | Hex_Coordinate_System.md |
| **Geoscape Hex Grid** | Geoscape | 90×45 hex grid representing Earth (~500km per hex, ~4050 total) | Hex_Coordinate_System.md |
| **Battlescape Grid Scale** | Battlescape | 4×4 to 7×7 blocks = 240-735 hexes per battle | Hex_Coordinate_System.md |
| **Pixel to Hex Conversion** | Rendering | pixelX = hexSize × √3 × q, pixelY = hexSize × 1.5 × r | Hex_Coordinate_System.md |
| **Horizontal Wrapping** | Geoscape | q=90 wraps to q=0 (spherical Earth) | Hex_Coordinate_System.md |
| **No Vertical Wrapping** | Geoscape | r=0 and r=44 are poles (no wrapping) | Hex_Coordinate_System.md |
| **Map Block Rotation** | Battlescape | Blocks can rotate (0°, 60°, 120°, 180°, 240°, 300°) | Hex_Coordinate_System.md |
| **Map Block Mirroring** | Battlescape | Blocks support horizontal or vertical mirroring | Hex_Coordinate_System.md |
| **Map Block Inversion** | Battlescape | Blocks can swap terrain types (invert) | Hex_Coordinate_System.md |
| **API Consistency Rule** | Navigation | All APIs use axial (q,r), never pixel or offset coordinates | Hex_Coordinate_System.md |

---

## SECTION XII: Pilot & Craft Systems

| **Mechanic Name** | **System** | **Description** | **Source** |
|---|---|---|---|
| **Pilot Unit Role** | Crafts | Units assigned to crafts as pilots, separate from ground combat role | Crafts.md |
| **Pilot Requirement** | Crafts | Each craft requires 1+ pilot based on craft type | Crafts.md |
| **Pilot Assignment** | Crafts | Pilots assigned to crafts cannot deploy to battlescape simultaneously | Crafts.md |
| **Pilot XP Tracking** | Crafts | Pilots gain Pilot XP from interception missions (separate from ground XP) | Crafts.md |
| **Pilot Progression System** | Crafts | Pilots progress through pilot ranks via Pilot XP accumulation | Crafts.md |
| **Pilot Reassignment** | Crafts | Pilots can be reassigned between crafts or switched to ground role | Crafts.md |
| **Pilot Death Recovery** | Crafts | If pilot dies in crash/interception, craft requires new pilot assignment | Crafts.md |
| **Pilot Stats Application** | Crafts | Pilot Piloting stat affects interception accuracy and maneuvers | Units.md |
| **Craft Transport Function** | Crafts | Primary purpose is transportation of units to mission sites | Crafts.md |
| **Craft No Combat Bonus** | Crafts | Crafts provide NO direct combat bonuses to carried units in battle | Crafts.md |
| **Craft Recovery System** | Crafts | Crashed crafts can be recovered, triggering rescue missions | Crafts.md |
| **Craft Maintenance Cost** | Finance | 2,000 credits per craft per month base maintenance | Balance_Parameters.md |
| **Craft Fuel Consumption** | Crafts | Automatic per mission, efficiency varies by craft type | Crafts.md |
| **Craft Equipment Slots** | Crafts | Hardpoints for weapons (left, right, center mounting) | Weapons_and_Items.md |
| **Craft Support Modules** | Crafts | Logistics modules (Cargo Pod, Fuel Tank, Passenger Cabin) | Weapons_and_Items.md |
| **Craft Weapon Hardpoints** | Crafts | Left, right, center mounting positions for weapons | Weapons_and_Items.md |
| **Craft Classification** | Crafts | Interceptors, Transports, Heavy Transports, Specialized variants | Crafts.md |

---

## SECTION XIII: Interception Combat Layer

| **Mechanic Name** | **System** | **Description** | **Source** |
|---|---|---|---|
| **Interception Mini-Game** | Interception | Aerial combat layer between player craft and UFOs | Interception.md |
| **UFO Escape Mechanics** | Interception | UFOs can escape from interception (avoid ground mission) | Geoscape.md |
| **UFO Damage Effects** | Interception | Successful interception damages UFO (reduces ground mission difficulty) | Geoscape.md |
| **Craft Damage Tracking** | Crafts | Craft damage recorded after interception, affects maintenance | Crafts.md |
| **Interception Outcome Types** | Interception | Three outcomes: UFO destroyed (no mission), escaped (continue), damaged (difficulty reduced) | Interception.md |
| **Craft No Repair During Combat** | Interception | Hostile craft cannot repair during interception | Weapons_and_Items.md |

---

## SECTION XIV: AI Systems Architecture

| **Mechanic Name** | **System** | **Description** | **Source** |
|---|---|---|---|
| **Strategic AI Layer** | AI | Campaign-scale: faction behavior, mission generation, escalation | AI_Systems.md |
| **Operational AI Layer** | AI | Interception-scale: UFO behavior, craft positioning | AI_Systems.md |
| **Tactical AI Layer** | AI | Battle-scale: unit positioning, target selection, retreat decisions | AI_Systems.md |
| **Autonomous Player AI** | AI | Complete player-replacement behavior for analytics/testing | AI_Systems.md |
| **Faction Autonomy System** | AI | Each faction maintains independent strategic goals | AI_Systems.md |
| **Faction Attack Strategy** | AI | Raid player provinces, establish bases, escalate threat | AI_Systems.md |
| **Faction Escalation Path** | AI | +1 Province per 3 successful attacks | AI_Systems.md |
| **Faction Resource Management** | AI | Generate resources, manufacture units, conduct research | AI_Systems.md |
| **Faction Tactical Adaptation** | AI | Deploy hard-counters to player unit composition | AI_Systems.md |
| **Deterministic Decision Making** | AI | Decisions based on state rules, not random rolls | AI_Systems.md |
| **Transparent AI Logging** | AI | All AI decisions loggable for analysis and tuning | AI_Systems.md |
| **UFO Decision Algorithm** | AI | Threat > Resources: Aggressive, Threat ≈ Resources: Maintain, Threat < Resources: Expand | AI_Systems.md |
| **Player Threat Assessment** | AI | Calculated from military strength, base count, fame | AI_Systems.md |

---

## SECTION XV: Finance & Monetary Systems

| **Mechanic Name** | **System** | **Description** | **Source** |
|---|---|---|---|
| **Monthly Finance Cycle** | Finance | Fixed cycle: Week 1 revenue, Weeks 2-3 operations, Week 4 settlement | Finance.md |
| **Country Funding Calculation** | Finance | Country economy × funding level allocation % = monthly income | Finance.md |
| **Funding Level Scale** | Finance | 0-10 levels, each represents % of country GDP allocated | Finance.md |
| **Debt System** | Finance | Loans available when cash reserves depleted, 5% monthly interest | Finance.md |
| **Loan Principal Amount** | Finance | 100,000 credits standard loan amount | Finance.md |
| **Loan Interest Rate** | Finance | 5% per month (compounding on outstanding debt) | Finance.md |
| **Bankruptcy Mechanics** | Finance | Triggers when debt > 500K or cash < -50K, liquidates assets | Finance.md |
| **Bankruptcy Consequences** | Finance | 50% base equipment liquidated, 25% of units discharged | Finance.md |
| **Cash Flow Forecasting** | Finance | Tracks projected cash flow for next 3 months | Finance.md |
| **Cash Crisis Indicators** | Finance | Warning (< 1 month reserves), Critical (< 1 week), Bankruptcy Risk | Finance.md |
| **Income Projection** | Finance | Estimated based on recent trends and known sources | Finance.md |
| **Break-Even Analysis** | Finance | Monthly expenses vs. guaranteed income calculation | Finance.md |
| **Inflation Tax Penalty** | Finance | Applied when credits exceed 20× monthly income (wealth penalty) | Finance.md |
| **Corruption Tax** | Finance | Penalty for operating excessive bases (per-base surcharge) | Finance.md |
| **Monthly Financial Report** | Finance | Complete statement: Income, Expenses, Net, 3-Month Forecast | Finance.md |
| **Personnel Maintenance Cost** | Finance | 500 credits per unit per month | Balance_Parameters.md |
| **Facility Maintenance Costs** | Finance | 2-15K per facility (varies by type) | Balance_Parameters.md |

---

## SECTION XVI: Black Market & Underground Economy

| **Mechanic Name** | **System** | **Description** | **Source** |
|---|---|---|---|
| **Black Market Access Tiers** | Economy | Restricted, Standard, Enhanced, Complete based on Karma/Fame | Black_Market.md |
| **Black Market Entry Fee** | Economy | 10,000 credits one-time to unlock access | Black_Market.md |
| **Restricted Items Category** | Economy | Experimental/alien/banned weapons, 200-500% normal price | Black_Market.md |
| **Special Units Recruitment** | Economy | Mercenaries, defectors, criminals, augmented soldiers, clones | Black_Market.md |
| **Special Craft Category** | Economy | Stolen military, prototypes, modified, captured UFOs | Black_Market.md |
| **Mission Generation Purchase** | Economy | Buy custom assassinations, sabotage, heists, kidnappings for credits | Black_Market.md |
| **Event Purchasing System** | Economy | Purchase political/economic events (improve relations, sabotage, etc.) | Black_Market.md |
| **Corpse Trading Mechanic** | Economy | Sell dead unit corpses for credits (ethics-based karma loss) | Black_Market.md |
| **Corpse Type Values** | Economy | Human (5K), Alien Common (15K), Alien Rare (50K), VIP (100K) | Black_Market.md |
| **Corpse Preservation System** | Economy | Cryogenic storage +100% value, fresh +50%, damaged -50% | Black_Market.md |
| **Corpse Alternative Uses** | Economy | Research (0 karma), Burial (0 karma), Ransom (0 karma) | Black_Market.md |
| **Dual-Market Suppliers** | Economy | Some suppliers operate in both legitimate and black market | Black_Market.md |
| **Black Market Supplier Relations** | Economy | Relationship affects pricing (+50 = 10%, +100 = 25% discount) | Black_Market.md |
| **Discovery Mechanics** | Economy | 5-15% detection chance per transaction type | Black_Market.md |
| **Discovery Consequences** | Economy | Fame -20 to -50, Relations -30 to -70, Investigation missions | Black_Market.md |
| **Investigation Missions** | Economy | 30% chance after discovery, must defend base or cooperate | Black_Market.md |
| **Black Market Custom Missions** | Economy | Assassination (-30 karma), Sabotage (-20), Heist (-15), Kidnap (-25) | Black_Market.md |
| **Mission Reward Scaling** | Economy | 150-300% purchase cost return, plus special items | Black_Market.md |
| **Event Types** | Economy | Improve Relations, Sabotage Economy, Incite Rebellion, Propaganda | Black_Market.md |
| **Event Stacking Rules** | Economy | Cannot stack same event in region, max 3 active simultaneously | Black_Market.md |
| **Mitigating Discovery Risk** | Economy | Bribe Officials (-50% chance), Cover Operations, Low Profile, Limit Transactions | Black_Market.md |
| **Criminal Organization Reputation** | Economy | Persists 12 months after discovery, -10 all relations | Black_Market.md |

---

## SECTION XVII: System Integration & Data Flow

| **Mechanic Name** | **System** | **Description** | **Source** |
|---|---|---|---|
| **Geoscape Mission Context** | Integration | Passed to Battlescape with type, location, difficulty, enemies, objectives | Integration_Points.md |
| **Battlescape Results Data** | Integration | Passed to Basescape with: success, casualties, XP, salvage, fame | Integration_Points.md |
| **Basescape Capability Feedback** | Integration | Equipment, craft, research feed back to Geoscape layer | Integration_Points.md |
| **State Passing Pattern** | Integration | Primary method: one-way data flow between sequential layers | Integration_Points.md |
| **Event Publishing Pattern** | Integration | Secondary: systems emit events without knowing subscribers | Integration_Points.md |
| **Query Interface Pattern** | Integration | Tertiary: systems query state without modification | Integration_Points.md |
| **Callback/Listener Pattern** | Integration | Quaternary: callback registration for specific events | Integration_Points.md |
| **Mission Lifecycle Flow** | Integration | 5 phases: Generation → Interception → Combat → Salvage → Strategic Impact | Integration_Points.md |
| **No Circular Dependencies** | Integration | Clean architecture: Geoscape → Battlescape → Basescape → Geoscape feedback | Integration_Points.md |
| **Vertical Data Flow Direction** | Integration | Downward: context passing, Upward: capability/results | Integration_Points.md |
| **Horizontal System Coupling** | Integration | Same-layer systems loosely coupled (independent operation possible) | Integration_Points.md |
| **Vertical System Coupling** | Integration | Cross-layer systems tightly coupled (intentional design) | Integration_Points.md |
| **Mission-to-Equipment Cycle** | Integration | Mission → Battlescape → Salvage → Research → Manufacturing → Equipment → Next mission | Integration_Points.md |
| **Economy Feedback Loop** | Integration | Mission success → funding increase → base expansion → capability growth | Integration_Points.md |
| **AI Adaptation Cascade** | Integration | Player success → escalation increase → harder aliens → casualties → maintenance costs | Integration_Points.md |

---

## SECTION XVIII: Mission Generation & Mission System

| **Mechanic Name** | **System** | **Description** | **Source** |
|---|---|---|---|
| **Mission Generation Framework** | Missions | Procedural generation based on faction state, escalation, player actions, country requests | Missions.md |
| **Mission Generation Triggers** | Missions | Faction activity (2-5/mo), Country requests (1-3/mo), Random events (0-2/mo), Player actions, Black market, Escalation events | Missions.md |
| **Mission Difficulty Calculation** | Missions | Campaign month × 0.2 + Player bases × 0.15 + Avg unit level × 0.1 + difficulty modifiers | Missions.md |
| **UFO Crash Mission** | Missions | Player intercepts UFO successfully; map: crash site with wreckage, 50% crew survivors (6-12 aliens) | Missions.md |
| **UFO Landing Mission** | Missions | Unintercepted UFO lands; 10-15 aliens, research samples, -5 relations if failed | Missions.md |
| **Alien Base Attack** | Missions | Faction escalation triggers assault; 20-40 aliens, 2,000 credits base reward, strategic value | Missions.md |
| **Terror Mission** | Missions | Panic escalation; 15-25 aliens + civilians, 1,500 credits, country favor, collateral damage risk | Missions.md |
| **Abduction Site Mission** | Missions | Rescue captives (8-12 aliens), 800 credits + rescued humans, psychological recovery needed | Missions.md |
| **Supply Raid Mission** | Missions | Aliens target player storage/resources; 10-15 aliens, 300 credits + loot, defend base mechanics | Missions.md |
| **Base Defense Mission** | Missions | Country-generated, random frequency, defend player base from alien attack, any relations | Missions.md |
| **Colony Defense Mission** | Missions | Protect civilian settlements; relations +25 required, 1-2/month frequency, +funding on success | Missions.md |
| **Escort Mission** | Missions | Protect VIP or convoy; relations +50 required, 0-1/month, diplomatic benefits | Missions.md |
| **Research Facility Mission** | Missions | Secure alien research site; relations +40 required, rare, special research bonuses | Missions.md |
| **Diplomatic Mission** | Missions | Special operations; relations +75 required, rare, affects international standing | Missions.md |
| **Black Market Custom Missions** | Missions | Assassination (-30 karma, 120K reward), Sabotage (-20, 100K), Heist (-15, 80K), Kidnap (-25, 90K), False Flag (-40, 150K), Data Theft (-10, 60K), Smuggling (-5, 50K) | Missions.md |
| **Mission Success Criteria** | Missions | Eliminate all enemies OR secure objectives (varies by mission type) | Missions.md |
| **Mission Optional Objectives** | Missions | Bonus conditions: recover tech intact, no civilian casualties, high-value prisoner capture | Missions.md |
| **Mission Reward Structure** | Missions | Base reward + salvage + research + diplomatic effects based on mission completion quality | Missions.md |
| **Mission Failure Consequences** | Missions | Enemy secures area, -relations, potential strategic impact (base raid risk, panic increase) | Missions.md |
| **Mission Pool Limit** | Missions | Max 8-10 missions available simultaneously, prevents player overwhelming with choices | Missions.md |
| **Monthly Mission Quota** | Missions | 5-8 total missions per month (normal difficulty), scales with difficulty setting | Missions.md |
| **Mission Location Placement** | Missions | Based on province threat level, faction presence, player radar coverage, regional preferences | Missions.md |
| **Mission Composition Scaling** | Missions | Enemy squad count and unit types scale with: campaign month, player bases, average unit level, difficulty | Missions.md |

---

## SECTION XIX: Environment, Terrain & Weather System

| **Mechanic Name** | **System** | **Description** | **Source** |
|---|---|---|---|
| **Terrain Type: Floor** | Environment | Standard walkable terrain (grass, concrete, dirt, etc.), 1 AP movement cost, 0% cover | Environment.md |
| **Terrain Type: Wall** | Environment | Impassable, 100% cover, blocks line of sight and fire completely | Environment.md |
| **Terrain Type: Water** | Environment | Rivers/lakes, 3 AP cost or impassable (depth-dependent), 0% cover, units drown if submerged | Environment.md |
| **Terrain Type: Difficult** | Environment | Rubble, forest, swamp, 2-3 AP cost, 0-20% cover, reduced movement efficiency | Environment.md |
| **Terrain Type: Cover** | Environment | Low walls, sandbags, vehicles, 1-2 AP cost, 40-80% cover effectiveness, partial LOS block | Environment.md |
| **Material Properties** | Environment | Wood (flammable), Metal (conductive), Ice (slippery), Tile (fragile), allows special interactions | Environment.md |
| **Movement Cost Modifiers** | Environment | Weather (+1 AP rain/snow), unit encumbrance (heavy equipment), status effects (bleeding, stun) | Environment.md |
| **Environmental Hazards** | Environment | Smoke (reduces visibility), Fire (damage per turn, spreads), Gas (damage/status), Lightning (electrical damage) | Environment.md |
| **Smoke Effect** | Environment | Reduces visibility range by 50%, doesn't block line of sight, blocks targeting scopes, disperses after 3 turns | Environment.md |
| **Fire Effect** | Environment | 2 damage/turn to units in tile, spreads to adjacent flammable materials, extinguishable with water | Environment.md |
| **Gas Effect** | Environment | Damage over time (1-5 per turn), status effects (poison, stun, sleep), spreads through wind | Environment.md |
| **Weather System** | Environment | Rain (+1 movement cost), Snow (slippery, -accuracy 10%), Fog (visibility -75%), Wind (projectile deflection), Clear (no effect) | Environment.md |
| **Day vs Night Conditions** | Environment | Night: visibility -50%, ambush bonus +2 for aliens, player detection difficulty -30% | Environment.md |
| **Destructible Terrain** | Environment | Walls collapsible (40 damage), obstacles destroyable, creates new movement paths, leaves debris | Environment.md |
| **Terrain Destruction Consequences** | Environment | Debris from destroyed walls, environmental hazard release (gas pockets), structural collapse chains | Environment.md |
| **Special Environments** | Environment | Urban (buildings, roads, civilians), Alien (organic architecture, bioluminescence), Aquatic (water hazards), Underground (tight spaces, darkness) | Environment.md |
| **Biome System** | Environment | Desert (sandstorms, heat damage), Jungle (dense cover, animals), Arctic (cold damage, ice), Forest (wildlife, flammable) | Environment.md |
| **Map Generation from Biome** | Environment | Biome determines: terrain distribution, hazard frequency, weather likelihood, aesthetic assets, enemy unit types | Environment.md |
| **Lighting System** | Environment | Darkness (night/underground), Partial light (overcast), Full light (day), artificial lights (structures), bioluminescence (alien areas) | Environment.md |
| **Line of Sight Interaction** | Environment | Fog/smoke blocks LOS, water can block, walls absolute block, cover provides partial concealment | Environment.md |
| **Environmental Damage Types** | Environment | Fire (Kinetic resistance doesn't apply), Acid (corrodes armor), Lightning (electronic/cyborg weakness), Cold (slows movement) | Environment.md |
| **Wind Mechanic** | Environment | Affects projectile accuracy (-5% to +10%), disperses smoke/gas, increases fire spread, varies direction seasonally | Environment.md |
| **Seasonal Variation** | Environment | Spring (rain, mud, growth), Summer (heat, dry), Autumn (moderate, clear), Winter (snow, cold, ice) | Environment.md |

---

## SECTION XX: Traits & Perks System

| **Mechanic Name** | **System** | **Description** | **Source** |
|---|---|---|---|
| **Trait Definition** | Traits | Permanent character modifiers: ID, name, type (positive/negative/neutral), category, balance cost, acquisition, conflicts, synergies | Traits_and_Perks.md |
| **Trait Acquisition: Birth** | Traits | During recruitment: 30% positive trait chance, 20% negative, 50% empty slots | Traits_and_Perks.md |
| **Trait Acquisition: Achievement** | Traits | Unlock through milestones: kills, missions, ranks, special events (50+ kills = Ambidextrous, etc.) | Traits_and_Perks.md |
| **Trait Acquisition: Perk System** | Traits | Spend perk points (earned per rank) to unlock/upgrade traits, replaces level-up system | Traits_and_Perks.md |
| **Combat Traits: Positive** | Traits | Quick Reflexes (+2 Reaction), Sharp Aim (+1 Acc, +5% hit), Steady Hand (-0.5% penalty/cover), Marksman (+15% range), Ambidextrous (dual wield), Rapid Fire (+1 burst shot), Sharpened Reflexes (+1 dodge) | Traits_and_Perks.md |
| **Combat Traits: Negative** | Traits | Slow Reflexes (-1 Reaction), Poor Aim (-1 Acc, -5% hit), Shaky Hands (+1% penalty/cover), Gun Shy (-2 first shot acc), Clumsy (-1 Reaction + melee penalty) | Traits_and_Perks.md |
| **Physical Traits: Positive** | Traits | Strong (+2 Str, +4 carry), Fast (+1 Speed, +1 hex movement), Enduring (+10% HP, +5% efficiency), Resilient (+2 armor), Athletic (jump obstacles), Lightweight (-1 movement cost) | Traits_and_Perks.md |
| **Physical Traits: Negative** | Traits | Weak (-1 Str, -2 carry), Slow (-1 Speed, -1 movement), Frail (-10% HP, -5% armor), Heavy (+1 movement cost) | Traits_and_Perks.md |
| **Mental Traits: Positive** | Traits | Iron Will (+2 Bravery, +25% morale resistance), Disciplined (-1 stun duration, +10% status resistance), Cool Under Pressure (no panic 50% chance), Commanding (squad +2 morale aura) | Traits_and_Perks.md |
| **Mental Traits: Negative** | Traits | Cowardly (-2 Bravery, -25% morale resistance), Nervous (+1 stun duration, -10% status resistance), Trigger Happy (accidental friendly fire), Insubordinate (ignore orders 10%) | Traits_and_Perks.md |
| **Support Traits** | Traits | Combat Medic (heal bonus +20%), Leader (squad morale +1/turn), Technician (equipment repair +15%), Scout (visibility +2 hexes) | Traits_and_Perks.md |
| **Trait Conflicts** | Traits | Mutually exclusive traits: Cowardly ↔ Iron Will, Weak ↔ Strong, Fast ↔ Slow | Traits_and_Perks.md |
| **Trait Synergies** | Traits | Beneficial combinations: Sharp Aim + Steady Hand = 25% bonus, Iron Will + Disciplined = panic immunity | Traits_and_Perks.md |
| **Trait Balance System** | Traits | Each trait has point cost: positive traits cost points (rare), negative traits earn points (balance) | Traits_and_Perks.md |
| **Trait Impact on Abilities** | Traits | Traits unlock special actions: Ambidextrous enables dual wield, Iron Will enables Inspire, Leader enables Command | Traits_and_Perks.md |
| **Trait Interaction with Equipment** | Traits | Strong gets +carry bonus, Technician gets +repair efficiency, combat traits affect accuracy/damage modifiers | Traits_and_Perks.md |
| **Trait Permanence** | Traits | Traits are permanent; cannot remove birth traits after recruitment (create unit identity) | Traits_and_Perks.md |
| **Trait Acquisition Rates** | Traits | Birth traits: 1-2 per unit, Achievement traits: 1 per 50-100 kills, Perk traits: 1 per rank advancement | Traits_and_Perks.md |
| **Special Trait Rules** | Traits | Smart trait: XP gain +20%, Stupid: -20%, Psychic: psi attacks +25%, Allergic: specific damage type vulnerability | Traits_and_Perks.md |

---

## SECTION XXI: Lore, Factions & Campaign Structure

| **Mechanic Name** | **System** | **Description** | **Source** |
|---|---|---|---|
| **Faction System** | Lore | Autonomous enemy groups: Sectoids, Ethereals, Subsistence (examples), each with independent units/research/missions | Lore.md |
| **Faction Unit Classes** | Lore | Each faction has unique unit types: Sectoids (Grunts, Warriors, Leaders), Ethereals (Elites, Psions, Commandants) | Lore.md |
| **Faction Campaign System** | Lore | Coordinated mission sequences: 5 missions/campaign, deployed over 6-10 weeks, region-specific | Lore.md |
| **Faction Mission Generation** | Lore | Autonomous system generates missions monthly based on faction goals, escalation level, player actions | Lore.md |
| **Campaign Structure** | Lore | Campaigns are coordinated mission sequences, multiple campaigns active simultaneously, each faction runs 1-3 campaigns | Lore.md |
| **Monthly Campaign Frequency** | Lore | Month 1-3: 2 campaigns/month, Month 4-6: +1/month, Month 7+: escalates further | Lore.md |
| **Campaign Escalation Formula** | Lore | Base: 2 campaigns/month, +1 per quarter, scales with campaign duration (Month 1-3 = +0, M4-6 = +1, M7-9 = +2) | Lore.md |
| **Mission Generation Schedule** | Lore | Campaign releases 5 missions over 6-10 weeks: deployment weeks typically 1, 3, 6, 7, 9 of campaign | Lore.md |
| **Faction Activity Scaling** | Lore | Early game: simple probing missions, Mid game: territory acquisition, Late game: existential threat | Lore.md |
| **Campaign Regional Targeting** | Lore | Campaigns target specific regions based on faction preferences, player radar vulnerability, alien strategy | Lore.md |
| **Faction Research Trees** | Lore | Each faction has independent tech tree, develops weapons/capabilities independently, parallels player research | Lore.md |
| **Faction Resource Economy** | Lore | Each faction has independent economy: mining, manufacturing, personnel recruitment, scales with success | Lore.md |
| **Faction Strength Indicators** | Lore | Mission difficulty scales with faction strength: unit levels, equipment quality, mission complexity | Lore.md |
| **Race Classification** | Lore | Races provide cosmetic categorization (no statistical bonuses): Sectoid race, Ethereal race, etc. | Lore.md |
| **Race Distribution** | Lore | Faction employs 1-3 races, unit class determines race association, thematic grouping | Lore.md |
| **Quest System** | Lore | Multi-mission narrative chains: faction-specific questlines, unlocks special units/research/rewards | Lore.md |
| **Event System** | Lore | Dynamic campaign events: alien council meetings, splinter factions, leadership changes, reinforcements | Lore.md |
| **Calendar System** | Lore | Time tracking: months (30 days), seasons, years, tracks faction aging, mission scheduling | Lore.md |
| **Enemy Scoring System** | Lore | Tracks alien casualties, base defeats, technology stolen, calculates faction threat rating | Lore.md |
| **Faction Mood/Motivation** | Lore | Narrative state: Aggressive (high missions), Defensive (base-focused), Strategic (technology rush) | Lore.md |
| **Faction Victory Conditions** | Lore | Factions pursue independent goals: conquer region, steal research, eliminate player, temporal defeat (time limit) | Lore.md |
| **Faction vs Faction Conflict** | Lore | Multiple factions compete: territories, resources, causing collateral damage missions, territorial wars | Lore.md |



- **Consolidation Basis**: 36+ mechanics files from `design/mechanics/` (COMPLETE - November 2, 2025)
- **Scope**: All game systems including advanced/meta systems (Geoscape, Basescape, Battlescape, Interception, Diplomacy, Economy, Psychology, AI, Finance, Navigation, Black Market, Integration)
- **Format**: Hierarchical organization with 450+ index entries, cross-reference index (5,000+ lines)
- **Audience**: Game designers, engineers, balance analysts, modders
- **Maintenance**: Update when mechanics specifications change; keep index synchronized with source files
- **Files Processed**: 36+ of 36 complete
  - Phase 1 (21 files): Balance_Parameters, Basescape, Battlescape_3D, Battlescape, Black_Market, Crafts, Damage_Types, Countries, Economic_Balance, Diplomacy, Geoscape, Units, Weapons_Items, Missions, Morale_Sanity, Fame_Karma_Reputation, Environment, UFO_and_Interception, Politics_and_Factions, Traits_and_Perks, Progression_Timeline
  - Phase 2 (10 files): Victory_and_Defeat, Finance, Glossary, Hex_Coordinate_System, Integration_Points, Lore, README, Test_Scenarios, Tutorial, AI_Systems
  - Phase 3+ (5+ files): Black_Market, Crafts (enhanced), AI_Systems, Finance (enhanced), Integration_Points (enhanced)
- **System Coverage**:
  - **Geoscape (Strategic)**: 15 subsystems + World Map, Provinces, Base Placement, Craft Movement, Stealth Budget, Mission Generation, Detection/Radar, Threat Escalation
  - **Basescape (Operational)**: 8 subsystems + Power Management, Facilities, Upgrades, Prisoners, Personnel, Recruitment, Manufacturing, Research
  - **Battlescape (Tactical)**: 11 subsystems + Map Generation, Combat, Accuracy, Weapons, Terrain, Actions, Melee Combat, Status Effects, Victory/Defeat
  - **Interception (Aerial Combat)**: UFO vs Craft combat, Outcomes, Damage tracking, Pilot mechanics, Escape/Damage consequences
  - **Morale & Psychology**: Morale pool, Panic mode, Sanity system, Bravery stats, Stun mechanics, Wounds, Energy/Stamina
  - **Finance & Economy**: Score system, Country funding, Income sources, Expenses, Monthly cycle, Financial crisis, Debt, Bankruptcy, Forecasting
  - **Lore & Campaign**: Factions, Race classification, Campaign structure, Escalation formula, Mission sites, Quest system, Event system
  - **Politics & Diplomacy**: Karma, Fame, Reputation, Score, Country relations, Advisor system, Diplomatic missions
  - **AI & Behavior**: Strategic AI (factions), Operational AI (UFOs), Tactical AI (units), Autonomous agents, Deterministic decisions
  - **Navigation & Coordinates**: Hex vertical axial system, Coordinate conversions, Map blocks, Grid systems
  - **Black Market & Underground**: Access tiers, Missions, Events, Corpse trading, Suppliers, Discovery mechanics
  - **Cross-Cutting**: 8 systems (Unit Progression, Equipment, Damage, Diplomacy, Psychology, Campaign, AI, Integration)
- **Total Mechanics**: 450+ distinct game mechanics documented
  - Phase 1: 100 mechanics
  - Phase 2: 110 mechanics
  - Phase 3: 60 mechanics (Basescape, Battlescape, Units)
  - Phase 4: 40+ mechanics (Geoscape, Morale/Sanity, Finance, Lore)
  - Phase 5: 140+ mechanics (Fame/Karma, Hex System, Pilots, Crafts, Interception, AI, Black Market, Integration)
- **Key Sections**: All 17 sections complete with Fame/Karma/Reputation, Hex Coordinate System, Pilot & Craft Systems, Interception Combat, AI Architecture, Finance & Monetary, Black Market Economy, System Integration
- **Deduplication**: STRICT - Each mechanic defined exactly once in appropriate section; cross-references prevent duplication
- **NEW v2 Additions**:
  - Section X: Fame, Karma & Reputation Systems (17 mechanics)
  - Section XI: Hex Coordinate System & Navigation (15 mechanics)
  - Section XII: Pilot & Craft Systems (16 mechanics)
  - Section XIII: Interception Combat Layer (6 mechanics)
  - Section XIV: AI Systems Architecture (13 mechanics)
  - Section XV: Finance & Monetary Systems (16 mechanics)
  - Section XVI: Black Market & Underground Economy (25 mechanics)
  - Section XVII: System Integration & Data Flow (14 mechanics)
  - Section XVIII: Mission Generation & Mission System (24 mechanics) - NEW
  - Section XIX: Environment, Terrain & Weather System (23 mechanics) - NEW
  - Section XX: Traits & Perks System (18 mechanics) - NEW
  - Section XXI: Lore, Factions & Campaign Structure (22 mechanics) - NEW
  - Section XXII: Victory & Defeat Conditions (18 mechanics) - NEW
  - Section XXIII: Campaign Progression Timeline (18 mechanics) - NEW
  - Section XXIV: Countries, Nations & Diplomacy System (16 mechanics) - NEW
- **Total Sections**: 24 complete (3 base layers + 9 cross-cutting systems + 12 advanced/specialty systems)
- **Final Total Mechanics**: 564+ distinct game mechanics documented
- **Enhanced Coverage**: 140+ mechanics Phase 5, plus 87+ mechanics from Sections XVIII-XXI, plus 52+ from XXII-XXIV, plus 10+ deduplication adjustments = 289+ total new mechanics added without duplication, all cross-referenced to source files

---

## SECTION XXII: Victory & Defeat Conditions

| **Mechanic Name** | **System** | **Description** | **Source** |
|---|---|---|---|
| **Primary Victory Condition** | Victory | Destroy all alien mothership(s) and eliminate 95%+ alien infrastructure (strategic win) | Victory_and_Defeat.md |
| **Victory Timeline** | Victory | Minimum month 15+ after sufficient military buildup, earlier with optimal strategy | Victory_and_Defeat.md |
| **Campaign Victory Prerequisite** | Victory | Alien threat reaches 90%+, mothership location discovered, sufficient elite units trained | Victory_and_Defeat.md |
| **Mothership Location Discovery** | Victory | Revealed through escalating missions (months 9-14), final scout mission confirms location | Victory_and_Defeat.md |
| **Mothership Interception Phase** | Victory | Air combat: Player craft vs mothership, 2-3 turns, reduce mothership to 30% HP for infiltration | Victory_and_Defeat.md |
| **Mothership Infiltration Phase** | Victory | Ground combat: 12-unit squad vs mothership interior, 4-5 battle phases to core destruction | Victory_and_Defeat.md |
| **Mothership Interior Phases** | Victory | Phase 1: Perimeter (20 turns, 6-8 elite aliens), Phase 2: Cargo (25 turns, prisoners), Phase 3: Engineering (20 turns, reactor), Phase 4: Command (25 turns, commanders), Phase 5: Destruction (10 turns, automated) | Victory_and_Defeat.md |
| **Mothership Difficulty: EXTREME** | Victory | Boss-level encounter, highest difficulty rating, recommended: all Rank 4+ units, elite equipment | Victory_and_Defeat.md |
| **Loss Condition 1: Organization Destruction** | Defeat | All bases destroyed or abandoned (0 bases remaining anywhere) | Victory_and_Defeat.md |
| **Loss Condition 2: Complete Funding Loss** | Defeat | Monthly income drops to 0 from all countries (diplomatic collapse) | Victory_and_Defeat.md |
| **Loss Condition 3: Economic Bankruptcy** | Defeat | Monthly expenses exceed income by >150% for 3+ consecutive months | Victory_and_Defeat.md |
| **Loss Condition 4: Panic Threshold** | Defeat | Any single country reaches 100% panic (government collapse/withdrawal) | Victory_and_Defeat.md |
| **Bad Ending 1: Alien Coexistence** | Defeat | Campaign month 60+, player survives but fails to escalate threat sufficiently, aliens establish presence | Victory_and_Defeat.md |
| **Bad Ending 2: Pyrrhic Victory** | Defeat | Defeat aliens through attrition but at massive cost: 80%+ squad casualties, 70%+ unit losses, crippling debt | Victory_and_Defeat.md |
| **Bad Ending 3: Defeat by Default** | Defeat | Player surrenders after losing 50%+ territories, aliens rule Earth but player organization survives underground | Victory_and_Defeat.md |
| **Difficulty-Specific Victory Requirements** | Victory | Easy: 70% alien elimination sufficient, Normal: 90%, Hard: 95%+, Impossible: 98%+ (mothership must be destroyed) | Victory_and_Defeat.md |
| **Player Status Indicators** | Victory | UI displays: Victory progress (%), Military capability (level), Economic stability (rating), Faction threat assessment | Victory_and_Defeat.md |

---

## SECTION XXIII: Campaign Progression Timeline

| **Mechanic Name** | **System** | **Description** | **Source** |
|---|---|---|---|
| **Campaign Duration** | Progression | ~96 months (8 years) from start to potential victory (Months 1-96) | Progression_Timeline.md |
| **Phase 1: Early Game (Months 1-3)** | Progression | "EDUCATION" phase - tutorial through tech unlocks, soft tutorial via forced research sequence, 2-3 education missions | Progression_Timeline.md |
| **Month 1: Game Initialization** | Progression | Start: 1 base, 1 scout craft, 5 Rank 1 units, 4 facilities, 500K capital (Normal), -45K/month deficit | Progression_Timeline.md |
| **Month 1 Milestones** | Progression | Week 1: Learn Geoscape, Week 2: Learn Basescape, Week 3: Learn Battlescape, Week 4: Stabilize finances | Progression_Timeline.md |
| **Month 2: Specialization Introduction** | Progression | Unlock first unit specializations (Sniper/Heavy), 8-10 units with Rank 2, first unit reaches Rank 2, equipment progression visible | Progression_Timeline.md |
| **Month 3: Tactical Depth** | Progression | 15-20 Rank 2+ units, 1-2 bases, 2 crafts, squad tactics mastered, multi-objective missions | Progression_Timeline.md |
| **Phase 2: Mid Game (Months 4-8)** | Progression | "EXPANSION" phase - base expansion, craft fleet growth, technology acceleration, third specialization tier unlocked | Progression_Timeline.md |
| **Phase 2 Progression** | Progression | 2-3 bases operational, 4-6 craft available, 30-40 units across all specializations, first alien technology integration | Progression_Timeline.md |
| **Phase 3: Late Game (Months 9-14)** | Progression | "CONFRONTATION" phase - alien escalation peaks, mothership discovered, must prepare for final assault | Progression_Timeline.md |
| **Phase 3 Progression** | Progression | 3-4 bases, full craft fleet, 50-70 elite units (Rank 3+), advanced technology, alien infrastructure visible | Progression_Timeline.md |
| **Phase 4: Endgame (Months 15+)** | Progression | "FINALE" phase - final assault on mothership, victory/defeat determination | Progression_Timeline.md |
| **Loss Condition: Organization Destruction** | Progression | All bases lost or abandoned - game over | Progression_Timeline.md |
| **Loss Condition: Economic Collapse** | Progression | Expenses exceed income indefinitely - funding withdrawn, bankruptcy cascade | Progression_Timeline.md |
| **Loss Condition: Complete Funding Loss** | Progression | All countries withdraw support (relations -100 or panic 100%) | Progression_Timeline.md |
| **Bad Ending: Alien Coexistence** | Progression | Survival past Month 60 without eliminating aliens (stalemate outcome) | Progression_Timeline.md |
| **Bad Ending: Pyrrhic Victory** | Progression | Defeat aliens after severe casualties (80%+ unit losses, crippling debt) | Progression_Timeline.md |
| **Bad Ending: Defeat by Default** | Progression | Surrender after losing 50%+ territories (underground survival scenario) | Progression_Timeline.md |
| **Difficulty Modifiers to Progression** | Progression | Easy: +1 month per phase, extended timelines, Higher: -1 month per phase, accelerated pressure | Progression_Timeline.md |
| **Pacing Validation Metrics** | Progression | Month 3 checkpoint: basic competency, Month 8: expansion milestone, Month 15: final assault readiness | Progression_Timeline.md |

---

## SECTION XXIV: Countries, Nations & Diplomacy System

| **Mechanic Name** | **System** | **Description** | **Source** |
|---|---|---|---|
| **Country Classification: Major Powers** | Diplomacy | 5-8 per game (USA, China, Russia, EU, India), large economies, +30 relation bonus, 40% more missions | Diplomacy.md |
| **Country Classification: Secondary Powers** | Diplomacy | 8-12 per game (Japan, Germany, Brazil, UK, Canada), medium economies, standard relations, normal mission frequency | Diplomacy.md |
| **Country Classification: Minor Nations** | Diplomacy | 10-15 per game (New Zealand, Singapore, Cyprus, Costa Rica), small economies, lower mission frequency, low protective burden | Diplomacy.md |
| **Country Classification: Supranational** | Diplomacy | 2-3 per game (UN-XCOM Alliance, International Space Authority), political entities, cannot declare war, always neutral/allied | Diplomacy.md |
| **Regional Bloc System** | Diplomacy | Countries organized geographically (North America, Europe, Asia-Pacific, South America, Africa, Middle East, etc.) | Diplomacy.md |
| **Country Funding Mechanic** | Diplomacy | Monthly funding based on: defense budget allocation, diplomatic relations multiplier (0.25x hostile to 2.0x allied) | Diplomacy.md |
| **Country Mission Generation** | Diplomacy | Generates missions based on: regional threat level, player relations, alien activity, country-specific events | Diplomacy.md |
| **Country Panic System** | Diplomacy | Each country has panic level (0-100%), affected by: losses in region, civilian casualties, UFO sightings, funding withdrawal | Diplomacy.md |
| **Country Relations Tracking** | Diplomacy | Diplomatic relations with history/trends, time-based decay/growth, UI-ready status labels (Hostile to Allied) | Diplomacy.md |
| **Country Response Mechanics** | Diplomacy | Relations change from: successful defense (+10), failed defense (-15), collateral damage (-5 per civilian), mission reward accomplishment (+5) | Diplomacy.md |
| **Strategic Country Diversity** | Diplomacy | Countries create diplomatic constraints and opportunities, single action cascades across multiple countries | Diplomacy.md |
| **Country Events System** | Diplomacy | Random country events: elections (change relations), scandals (reduce funding), military buildup (increase requests) | Diplomacy.md |
| **Country Customization** | Diplomacy | Each country has unique: government type, military strength, economy size, political alignment, strategic location | Diplomacy.md |
| **Country Victory Impact** | Diplomacy | Protecting major powers critical, minor nations easier wins for relationship building | Diplomacy.md |
| **Territory Defense Obligation** | Diplomacy | Missions generated in country territories based on threat level and relations | Diplomacy.md |
| **Country Funding Sources** | Diplomacy | Primary income: country defense budgets (monthly), Secondary: special mission bonuses, Tertiary: diplomatic bonuses | Diplomacy.md |

```
---

## SECTION XXVII: System Integration & Dependencies

**Purpose**: Document how systems interact, critical integration points, and data flow between layers

### System Architecture Integration

**Three-Layer Integration Model**:
- **Geoscape** (Strategic) → Generates mission context
- **Interception** (Aerial) → Resolves UFO encounters
- **Battlescape** (Tactical) → Produces salvage and XP
- **Basescape** (Operational) → Processes salvage, equips units
- Feedback loop returns to Geoscape

**Critical Integration Points**:
- **Geoscape ↔ Basescape**: Mission generation, base location validation, craft deployment
- **Basescape ↔ Battlescape**: Unit equipment, research unlocks, salvage conversion
- **Battlescape ↔ Geoscape**: Mission outcome, world state updates, faction escalation
- **Economy ↔ All Systems**: Resource cost/benefit calculations, monthly flow management
- **Diplomacy ↔ Geoscape**: Country relations affect mission frequency, funding, panic propagation

### Data Flow Patterns

**Pattern 1: Mission Cascade** (Most Critical)
```
Geoscape (UFO detected)
→ Interception (combat attempted)
→ Battlescape (tactical combat)
→ Basescape (salvage processing)
→ Geoscape (outcome affects relations/panic)
```

**Pattern 2: Technology Cascade**
```
Basescape (research completes)
→ Unlock new equipment/units
→ Equipment available for manufacturing
→ Crafted items equipped to units
→ Units deployed on missions
→ Higher success rate changes Geoscape threat level
```

**Pattern 3: Economic Loop**
```
Mission reward (5K-100K)
→ Basescape treasury
→ Unit salaries/equipment/research costs
→ Monthly deficit/surplus
→ Funding availability next month
→ Economic crisis if deficit persists
```

### System Dependencies

**Geoscape Depends On**:
- Economy (funding, resources)
- Diplomacy (country relations, panic)
- AI (faction behavior, mission generation)
- Basescape (available units, crafts, capabilities)

**Basescape Depends On**:
- Battlescape (salvage, casualties)
- Research/Manufacturing (unlocks, queues)
- Economy (maintenance costs, researcher salaries)
- Geoscape (facility requirements by mission difficulty)

**Battlescape Depends On**:
- Units (stats, equipment, specialization)
- Environment (terrain, hazards, biome)
- AI (enemy behavior, tactics)
- Equipment (armor values, weapon damage)

**Interception Depends On**:
- Craft (stats, equipment, pilot)
- AI (UFO behavior, tactics)
- Damage System (resolution mechanics)

### Horizontal System Coupling (Same Layer)

**Geoscape Internal**:
- Provinces ↔ Countries (relationships)
- UFOs ↔ Mission Generation (one generates from the other)
- Craft Deployment ↔ Radar Coverage (determines detection)

**Basescape Internal**:
- Facilities ↔ Power System (consumption tracking)
- Research ↔ Manufacturing (unlocks enable production)
- Unit Roster ↔ Specialization Tree (units select paths)

**Battlescape Internal**:
- Unit Actions ↔ Line of Sight (visibility determines targeting)
- Movement ↔ Terrain (terrain determines cost)
- Damage Calculation ↔ Armor (armor reduces damage)

### Integration Testing Scenarios

**Test 1: Mission Success Impact**
- Player completes mission in Allied country
- Verify: Relations +5, funding increases, country panic -10
- Check: Cascade to other countries in same bloc (-2 to rivals)

**Test 2: Economic Pressure**
- Player loses 2 missions in a month
- Verify: Relations drop, funding -30K, base maintenance begins to fail
- Check: Power priority system engages (low-priority facilities offline)

**Test 3: Technology Acceleration**
- Player researches Advanced Lab upgrade
- Verify: Research speed increases 20%
- Check: Next research project completes earlier, manufacturing queues empty faster

**Test 4: Escalation Impact**
- Player survives months 1-6 successfully
- Verify: Threat meter increases, alien mission frequency doubles
- Check: Alien unit composition improves (better armor, abilities)

---

## SECTION XXVIII: Test Scenarios & Validation

**Purpose**: Comprehensive test cases covering all systems to ensure mechanics function as designed

### Campaign Validation Scenarios

**Scenario T1: Economic Sustainability Test**
- Target: Verify budget can sustain indefinitely with 70%+ mission success
- Setup: Normal difficulty, Month 1 start
- Actions: Complete 10 consecutive missions with 80% success rate
- Expected: Budget remains positive by Month 12, -0K to +50K monthly
- Validation: Cost calculations accurate, income/expense balanced

**Scenario T2: Escalation Curve Test**
- Target: Verify enemy difficulty increases with campaign progress
- Setup: Track alien composition by month
- Actions: Progress months 1→8→15
- Expected: Month 1 aliens (basic), Month 8 (mixed), Month 15 (elite/boss units)
- Validation: Threat meter aligned with enemy composition

**Scenario T3: Diplomatic Cascade Test**
- Target: Verify relations affect all downstream systems
- Setup: Start with USA +50 relation
- Actions: Complete 2 defense missions in USA territory
- Expected: USA +70, Related Bloc +5, Funding +10K, Mission frequency +1/month
- Validation: All downstream effects trigger correctly

**Scenario T4: Technology Research Validation**
- Target: Verify research unlocks are gated properly
- Setup: Month 1, note locked technologies
- Actions: Complete research chain (5 projects, 10 weeks)
- Expected: Each research unlocks dependent projects, manufacturing queues update
- Validation: No circular dependencies, all prerequisites enforced

### Unit Progression Validation

**Scenario T5: XP Gain & Rank Advancement**
- Target: Verify rank promotion at correct XP thresholds
- Setup: New Rank 1 unit (0 XP)
- Actions: Complete 3 missions (est. 200 XP total)
- Expected: Rank 2 promotion available, stats increase by expected amount
- Validation: XP rewards accurate, promotions happen at thresholds

**Scenario T6: Specialization Choice**
- Target: Verify specialization selection changes unit behavior
- Setup: Rank 2 unit, select Sniper specialization
- Actions: Compare accuracy vs. standard Rifleman in identical scenario
- Expected: Sniper +25% accuracy at range 5+, -30% accuracy <3 hex
- Validation: Specialization modifiers apply correctly

**Scenario T7: Demotion System**
- Target: Verify unit can demote and re-specialize without data loss
- Setup: Rank 3 unit with 900 XP, demote to Rank 2
- Actions: Check XP retained, select new specialization
- Expected: ~450 XP retained (50%), unit functional in new path
- Validation: XP formula correct, no duplication/loss

### Combat System Validation

**Scenario T8: Accuracy Calculation**
- Target: Verify hit formula produces correct percentages
- Setup: Marksman (base 70%) vs. target at optimal range, no cover
- Actions: Fire 100 shots
- Expected: ~70 hits (70% hit rate)
- Validation: Formula applied correctly, RNG working

**Scenario T9: Damage Type Resistance**
- Target: Verify armor resists different damage types
- Setup: Combat armor (15 HP) vs. various damage types
- Actions: Apply 10 Kinetic, 10 Energy, 10 Explosive damage
- Expected: Kinetic 30%, Energy 15%, Explosive 5% reduced
- Validation: Armor type resistance values correct

**Scenario T10: Status Effect Application**
- Target: Verify status effects apply and decay correctly
- Setup: Unit in smoke (3-turn duration), also stunned
- Actions: Track accuracy, morale, AP over 5 turns
- Expected: Turn 1-3 smoke accuracy -25%, stun skips turn, Turn 4 smoke clears
- Validation: Effect stacking and decay working

### Basescape Facility Validation

**Scenario T11: Power Management**
- Target: Verify power priority system during shortage
- Setup: 1000 MW power generation, 1500 MW demand (5 facilities)
- Actions: Simulate one month of operation
- Expected: Tier 10 facilities (lowest priority) offline, rest operational
- Validation: Priority order respected, no critical facilities offline

**Scenario T12: Manufacturing Queue**
- Target: Verify manufacturing completes in expected time
- Setup: Queue 5 rifles in workshop (2 hours each with 1 technician)
- Actions: Track daily progress
- Expected: 1 rifle per 2 hours = 5 complete after 10 hours
- Validation: Production rate accurate, queue management working

**Scenario T13: Research Acceleration**
- Target: Verify research facilities increase speed
- Setup: Standard lab (10 man-days) vs. advanced lab (+50% = 15 man-days)
- Actions: Allocate 10 scientists to each
- Expected: First completes in 1 day, second in 16-17 hours
- Validation: Facility bonus applied correctly

### Balance & Difficulty Validation

**Scenario T14: Difficulty Modifiers**
- Target: Verify Hard mode increases challenge appropriately
- Setup: Compare Normal vs. Hard campaign difficulty
- Actions: Complete first 3 months on both difficulties
- Expected: Hard: -20% funding, +30% mission frequency, enemy +15% stats, research +25% time
- Validation: All modifiers applied correctly

**Scenario T15: Budget Constraints**
- Target: Verify economic pressure different by difficulty
- Setup: Compare available credits by month across difficulties
- Actions: Track treasury through Month 12
- Expected: Easy +100K by month 12, Normal +0K, Hard -50K
- Validation: Economic scaling working as designed

---

## SECTION XXV: Glossary & Terminology Reference

**Purpose**: Consolidated terminology dictionary for game terminology, abbreviations, system-specific terms, and quick lookup.

### Core Game Terminology

| Term | Definition | System |
|------|-----------|--------|
| **AP** | Action Points - turn resource limiting unit actions (4 per turn); each action costs 1-4 AP | Battlescape |
| **EP** | Energy Points - stamina/ammunition for weapon fire (regenerates 30% per turn) | Battlescape |
| **HP** | Health Points - combat damage capacity (15-25 typical); death at 0 HP | Battlescape |
| **XP** | Experience Points - progression currency earned through combat; triggers rank promotion at thresholds | Units |
| **Rank** | Experience level (0-6) determining unit specialization; Rank 0=Conscript, Rank 5=Elite, Rank 6=Hero | Units |
| **Specialization** | Role-specific path chosen at Rank 2+; permanent but changeable via demotion | Units |
| **Trait** | Permanent character modifier affecting stats, abilities, behavior; cannot be removed | Units |
| **Morale** | Psychological state (0-Bravery range); drops to 0 triggers panic; recovered through inspiration | Battlescape |
| **Panic** | Incapacitation when morale reaches 0; unit becomes inactive with -50% AP recovery | Battlescape |
| **Sanity** | Mental health (0-100); long-term stability affecting deployment capability | Units |
| **Bravery** | Core stat determining morale capacity (range 6-12); affects panic resistance and leadership | Units |
| **Karma** | Moral alignment (-100 evil to +100 saint); affects mission gating and faction relations | Politics |
| **Fame** | Public awareness (0-100); affects mission difficulty and UFO attention | Politics |
| **Reputation** | Legal legitimacy (0-100); +1 per quarter permanently; affects diplomatic leverage | Politics |
| **UFO** | Unidentified Flying Object; enemy craft that can be intercepted or generates missions | Geoscape |
| **Craft** | Player vehicle for travel and unit transport; requires pilot and fuel | Geoscape |
| **Interception** | Aerial combat between player craft and UFO; determines mission difficulty | Interception |
| **Mission** | Tactical Battlescape encounter generated by factions or countries | Missions |
| **Biome** | Environmental classification (Urban, Forest, Desert, Arctic) affecting terrain and hazards | Environment |
| **Terrain** | Ground surface type (Floor, Wall, Water, Difficult, Cover) affecting movement and visibility | Environment |
| **Cover** | Defensive obstacles providing -20-50% attacker accuracy; destructible via explosions | Battlescape |

### Common Abbreviations

- **KIN**: Kinetic damage (bullets, melee)
- **EXP**: Explosive damage (grenades, rockets)
- **ENE**: Energy damage (lasers, plasma)
- **PSI**: Psionic damage (alien mental attacks)
- **STU**: Stun damage (non-lethal incapacity)
- **LOS**: Line of Sight (visibility calculation)
- **LOF**: Line of Fire (projectile path)
- **ACC**: Accuracy (hit chance percentage)
- **DMG**: Damage (HP reduction per hit)
- **DEF**: Defense (armor/cover value)
- **RNG**: Range (weapon maximum distance)

---

## SECTION XXVI: Tutorial & New Player Experience

**Status**: Design for First Playthrough (Months 1-3)
**Purpose**: Define how new players learn AlienFall's three-layer system through natural progression
**Core Concept**: Technology Tree as Tutorial - mechanics locked behind research forcing correct learning sequence

### First Playthrough Philosophy

✅ **DO**: Sequence content properly | Gate advanced mechanics with research | Show real consequences | Respect player intelligence

❌ **DON'T**: Use pop-up tooltips | Hand-hold with overlays | Over-explain mechanics | Prevent "wrong" choices

### Month 1: "Learning Geoscape"

**Starting Conditions**:
- 1 Base (4 facilities pre-built)
- 1 Scout Craft
- 5 Rank 1 Soldiers
- 500,000 Credits (Normal difficulty)

**Sequential Objectives**:

1. **Craft Movement** → "Routine Patrol" mission
   - No combat, navigate to waypoint
   - Teaches: Geoscape navigation, interception basics

2. **Base Management** → Enter Basescape
   - Barracks highlighted
   - Objective: "Recruit 2 soldiers"
   - Teaches: Facility system, recruitment mechanics

3. **Equipment System** → Equipment Assignment
   - Workshop highlighted with rifles
   - Objective: "Equip your soldiers"
   - Teaches: Squad customization, inventory management

4. **Combat Introduction** → "Terror Site Defense" mission
   - 3 basic aliens vs. 5-7 player units
   - Teaches: Basic combat, cover usage, line of sight

**End State**: Three-layer system understood

### Month 2: "Learning Specialization"

**Research Unlocks**:
- Precision Firearms (Sniper Rifles, Laser Pistols)
- Squad Tactics (Support abilities)

**First Specialization Choice**:
- First Rank 2 unit promotes
- Choice: Sniper (high range, low rate) vs. Rifleman (balanced)
- UI displays stat differences, perk choices
- Consequence: Unit behavior changes significantly

**Mission 3: "Squad Tactics Mission"**
- 4-5 aliens with cover, mixed types
- 8-10 units with specialized roles
- Support units can heal/revive
- Teaches: Team composition matters more than raw unit count

**End State**: Specialization system mastered

### Month 3: "Learning Strategy"

**Research Unlocks**:
- Advanced Facilities (Psionic Lab, Genetics Lab)

**Strategic Decision**:
- Choose: Expand base vs. Build second base
- Tradeoffs shown (cost, maintenance, capability)
- Teaches: Strategic expansion requires planning

**Mission 4: "UFO Base Assault"** (Difficulty spike)
- 6-8 aliens including boss unit
- Hard difficulty, some units will likely die
- Teaches: Tactics triumph over unit count, consequences are real

**End State**: All core mechanics understood, ready for full campaign

### Tutorial Missions Summary

| # | Name | Month | Type | Difficulty | Lesson |
|---|------|-------|------|-----------|--------|
| 1 | Routine Patrol | 1 | Navigation | Trivial | Geoscape basics |
| 2 | Terror Defense | 1 | Combat | Easy | Basic Battlescape |
| 3 | Squad Tactics | 2 | Combat | Normal | Unit roles matter |
| 4 | UFO Base Assault | 3 | Combat | Hard | Strategy > raw power |

### Month 4+ : Campaign Begins

**Transition to Main Campaign**:
- Objectives become suggestions
- Research fully unlocked (player must prioritize)
- Economic pressure becomes real
- All tutorial guidance removed
- Full complexity available
