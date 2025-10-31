# Crafts System

> **Status**: Design Document
> **Last Updated**: 2025-10-28
> **Related Systems**: Geoscape.md, Units.md, Pilots.md, Interception.md, Items.md

## Table of Contents

- [Overview](#overview)
- [Craft Fundamentals](#craft-fundamentals)
- [Craft Classification](#craft-classification)
- [Craft Statistics](#craft-statistics)
- [Craft Weapons](#craft-weapons)
- [Craft Addons & Upgrades](#craft-addons--upgrades)
- [Craft Experience & Progression](#craft-experience--progression)
- [Craft Maintenance & Repair](#craft-maintenance--repair)
- [Craft Transport Mechanics](#craft-transport-mechanics)
- [Crash Sites & Rescue Missions](#crash-sites--rescue-missions)
- [Craft-Unit Integration](#craft-unit-integration)
- [Craft Types by Engine & Terrain](#craft-types-by-engine--terrain)
- [Quick Reference Table](#quick-reference-table)
- [Craft Manufacturing & Technology](#craft-manufacturing--technology)
- [Design Philosophy](#design-philosophy)
- [Integration with Other Systems](#integration-with-other-systems)
- [Examples](#examples)
- [Balance Parameters](#balance-parameters)
- [Difficulty Scaling](#difficulty-scaling)
- [Testing Scenarios](#testing-scenarios)
- [Related Features](#related-features)
- [Implementation Notes](#implementation-notes)
- [Review Checklist](#review-checklist)

---

## Overview

Crafts serve as the primary vehicles for strategic deployment and tactical operations in AlienFall. Similar to heroes in Heroes of Might and Magic, crafts function as persistent assets that move across the Geoscape carrying units to battle sites. Beyond transport, crafts engage in their own tactical layer through the **Interception system**, enabling player-controlled aerial combat against UFOs and enemy forces.

**Core Philosophy**: Crafts are valuable, upgradable assets that grow through experience and technological advancement. Players must balance maintaining a diverse fleet with the economic burden of maintenance and fuel consumption.

---

## Craft Fundamentals

### Design Assumptions

**Core Mechanics**:
- Crafts do NOT occupy map blocks on the Battlescape (currently; may change in future)
- **Crafts require pilot units** (see Units.md for pilot class system)
- **Pilots are separate units** that can be assigned to crafts or deployed to battlescape
- Pilots gain experience through interception missions and can progress through pilot ranks
- Crafts provide **no direct combat bonuses** to carried units during Battlescape missions
- Craft primary purpose is transportation; Interception is a secondary mini-game mechanic
- Crafts are recovered if crashed during Interception, triggering a rescue mission

**Pilot System Integration**:
- Each craft requires 1+ pilot units based on craft type (see Pilot Requirements table)
- Pilots assigned to crafts cannot deploy to battlescape missions simultaneously
- Pilots gain **Pilot XP** from interception missions (separate from ground combat XP)
- Pilots can be reassigned between crafts or switched to ground combat role
- If pilot dies in crash/interception, craft requires new pilot assignment
- **See [Pilots.md](./Pilots.md) for complete pilot mechanics**
- See also [Units.md](./Units.md) for unit stats including Piloting stat

**Scope Clarity**:
- Crafts transport units, weapons, and equipment between base and mission sites
- Crafts do NOT carry unit inventory items (each unit carries their own equipment)
- Mission salvage is handled separately (see Salvage System section)
- Pilot XP is tracked separately from transported unit XP (no shared XP)

### Craft Storage & Capacity

**Storage Facilities**:
- **Garage**: Holds 1 craft (small/medium)
- **Hangar** (2×2 structure): Holds 4 crafts
- **Space Calculation**: Total base capacity vs. total craft size (crafts can be mixed)
- **Overflow**: Crafts without storage space cannot be used until space is freed

**Craft Sizing**:
- Small craft: Size 1-2 (Scout, Interceptor)
- Medium craft: Size 3-4 (Transport, Fighter)
- Large craft: Size 5-6 (Heavy Fighter, Battleship)
- **No Mixed Location Rule**: Physical location doesn't matter; only total capacity vs. total size

---

## Craft Classification

### Class System

Crafts follow a **class hierarchy** similar to units, featuring promotion trees and specializations.

#### Class Organization

- **Rank 0**: Base model (e.g., Basic Scout, Human Transport)
- **Rank 1**: Specialist variant (e.g., Advanced Scout, Combat Transport)
- **Rank 2**: Upgraded variant (e.g., Elite Scout, Armored Transport)
- **Rank 3+**: Specialized combat roles (e.g., Interceptor Master, Bomber Command)

#### Acquisition Methods

Most crafts are acquired through **Manufacturing** in Workshop facilities rather than promotion:
1. Research technology requirements
| Type | Role | Primary Use | Speed | Armor | Cargo | Pilot Req |
|------|------|-------------|-------|-------|-------|-----------|
| **Scout** | Reconnaissance | Map scanning, UFO detection | High | Low | Low | 1 pilot (any) |
| **Interceptor** | Air combat | Interception missions vs. UFOs | High | Medium | Low | 1 Fighter Pilot |
| **Bomber** | Ground attack | Airborne strike support | Medium | Medium | Medium |
| **Transport** | Unit deployment | Carry large squads to missions | Low | Low | High |
| **Assault Transport** | Hybrid | Mixed combat + transport | Medium | Medium | Medium |
| **Stealth Craft** | Special ops | Quick insertion/extraction | Very High | Low | Very Low |

**Note**: All crafts require 1 pilot. Any unit can pilot any craft. Higher Piloting stat = better performance.

#### Water-Based Crafts

| Type | Role | Primary Use | Speed | Armor | Cargo |
|------|------|-------------|-------|-------|-------|
| **Submarine** | Underwater combat | Anti-aquatic base operations | Medium | Medium | Low |
| **Naval Transport** | Sea deployment | Carry units across oceans | Low | Low | High |
| **Cruiser** | Naval combat | Air-to-sea interception | Medium | High | Medium |
| **Destroyer** | Anti-submarine | Underwater base defense | Medium | High | Medium |
| **Battleship** | Heavy combat | Naval dominance, group command | Low | Very High | High |

#### Hybrid / Special Purpose

- **Mobile Base**: Stationary operations center, no combat
- **Cargo Hauler**: Maximum cargo, no weapons, diplomatic supply
- **Support Vessel**: Repair, resupply, field hospital

---

## Craft Statistics

All crafts are defined by core stats affecting their Geoscape performance, combat capability, and tactical role.

### Movement & Navigation

#### Speed
- **Geoscape**: Number of province-hexes traversable per turn
- **Range**: Low (1-2), Medium (2-3), High (3-4), Very High (4+)
- **Modifier**: Affected by fuel type, damage status, cargo weight
- **Calculation**: Each movement action uses 1 fuel unit

#### Range (Distance Capability)
- **Measurement**: Kilometers of sustainable distance (500-6,000 km)
- **Fuel Dependent**: Crafts with longer range carry more fuel tanks
- **Emergency Landing**: Craft can land but is stranded if fuel depleted mid-journey
- **Return Fuel**: Range calculation must account for return trip to base

#### Fuel System
- **Fuel Type**: Each craft uses specific fuel type (Petrol, Fusion Core, Elerium, etc.)
- **Consumption**: Variable cost per travel (1-5 fuel per hex movement)
- **Storage**: Fuel stored in base inventory; automatically consumed per movement
- **Automatic**: No separate refueling phase; fuel tracked and consumed automatically
- **Tank Upgrades**: Addon slots can increase fuel capacity (+1,000 km range per tank)

### Storage & Carrying Capacity

#### Cargo Capacity (Inventory)
- **Measurement**: Weight units (0-100+ units)
- **Weight Scaling**: Heavier craft equipment weighs more
  - Unit weapons: 10-15 weight units (light rifle to heavy cannon)
  - Craft weapons: 200+ weight units (heavy missiles, plasma casters)
  - Armor pieces: 20-40 weight units per piece
- **Limit**: Fixed capacity; items cannot be force-loaded. Overweight cargo simply cannot be loaded.
- **No Overflow**: Binary system—craft either carries full load or cannot carry at all

#### Crew Capacity (Unit Slots)
- **Measurement**: Unit slots available (4-20+)
- **Size Calculation**: Each unit consumes slots equal to their size rating
  - Size 1 unit = 1 crew slot
  - Size 2 unit = 2 crew slots
  - Size 4 unit = 4 crew slots
- **Addon Expansion**: Crew Cabin addon adds +2 unit slots
- **Maximum**: Base 6-20 units depending on craft class
- **Cross-Damage**: If craft takes damage during transport, carried units may also take damage

#### Cargo Bay Addon
- **Effect**: Increases cargo capacity by +20 weight units
- **Stacking**: Can equip multiple cargo bay addons (up to 2 addon slots)
- **Maximum**: Practical limit is +40 cargo capacity with 2 addons

### Combat & Detection

#### Weapon Slots
- **Maximum**: 2 weapon slots (hardpoints) per craft
- **Weapons**: Cannons, Missiles, Laser Arrays, etc. (see Weapons section)
- **Weight**: Heavy weapons consume significant weapon slot power
- **Limitation**: Large crafts cannot equip 4 weapons; slot count is fixed

#### Addon Slots
- **Maximum**: 2 addon slots per craft
- **Categories**: Armor, Shields, Engines, Radar, Special systems
- **Examples**: Metal Armor, Shield Generator, Afterburner, Radar Booster
- **Strategic Choice**: Players must choose between defensive/utility upgrades

#### Radar & Detection

**Radar Power**:
- **Measurement**: Detection strength (1-10 scale)
- **Effect**: Increases ability to detect UFO signatures on Geoscape
- **Upgrade**: "Additional Radar" addon increases radar power by +2
- **Facility**: Base radar station stacks with craft radar

**Radar Range**:
- **Measurement**: Kilometers of scan radius (200-2,000 km)
- **Coverage**: Visible UFO detection at this range when craft is on patrol
- **Additional Radar Addon**: Extends range by +500 km
- **Modifiers**: UFO stealth, weather, terrain can reduce effective range

**Cover (Stealth/Concealment)**:
- **Measurement**: Concealment rating (0-10)
- **Effect**: Reduces enemy detection of craft by this value (subtracts from enemy radar power)
- **Stealth Craft**: Built-in -5 to enemy detection (very hard to find)
- **Passive**: Applies when craft is on patrol or stationary

#### Landing Noise & Stealth Budget

**Landing Noise Mechanic**:
- Each mission site has a **Stealth Budget** (typically 250 points)
- When craft lands, it generates **Landing Noise** based on size/weight
- **Large Craft**: Generate 150-200 landing noise (may blow stealth cover immediately)
- **Small Craft**: Generate 20-50 landing noise
- Excess noise above budget alerts enemies to precise landing location
- **Strategic Decision**: Larger crafts trade stealth for carrying capacity

**Example**: A Heavy Assault Craft lands at a covert research facility with 250-point stealth budget:
- Heavy craft generates +200 landing noise
- Budget reduced to 50 points
- Any additional unit activity (gunfire, explosions) quickly burns remaining budget
- Enemies alerted with precision to landing zone if budget depleted

### Defensive Systems

#### Health (Hit Points)
- **Range**: 50 HP (Small Scout) to 500+ HP (Battleship)
- **Scaling**: Larger crafts have higher HP
- **Damage**: Taken from weapon attacks, interception combat, environmental hazards
- **Repairs**: See Maintenance section

#### Armor Value (Built-in)
- **Range**: 0-4 (varies by craft class and upgrades)
- **Effect**: Reduces incoming damage by armor value (each point = 1 damage reduction)
- **Weight**: Armor upgrades consume addon slots

#### Craft Armor & Support Systems

**Shield System**:
- **Shield Addon**: Temporary +10 health per turn (requires active power allocation)
- **Energy**: +20 energy capacity, +5 regen per turn
- **Regeneration**: Shields regenerate at normal rate when not damaged
- **Toggle**: Shields can be toggled on/off (drains/restores energy)
- **Power-Dependent**: Maintains active regeneration if powered
- **Stacking**: Effects do not stack; only one shield system per craft

**Ablative Armor**:
- **Effect**: -50% explosive damage
- **Degradation**: Degrades 10% per explosive hit (temporary defense)
- **Use Case**: Cost-effective early-game defense

**Reactive Plating**:
- **Explosive Resistance**: +40% reduction
- **Kinetic Resistance**: +20% reduction
- **Use Case**: Balanced defense against physical impacts

**Standard Armor Plates**:
- **Effect**: +50 health baseline
- **Use Case**: Budget-friendly armor option

**Armor Integration Mechanics**:
- Multiple armor systems can be combined for layered defense
- Armor degrades with damage and doesn't regenerate naturally
- Shield systems drain energy but provide powerful defense
- Players must balance offense, defense, and logistics

#### Support Systems

**Speed/Mobility**:
- **Afterburner**: +1 speed, higher fuel consumption for aggressive pursuit

**Range Extension**:
- **Fuel Tank**: +1,000 km range (enables distant missions)
- **Effect**: -50% range multiplier per additional tank (stacking)

**Cargo & Transport**:
- **Cargo Pod**: +10 capacity for weapons/armor inventory
- **Passenger Cabin**: +2 crew capacity (unit slots)

**Detection & Sensors**:
- **Radar Booster**: +100% detection range, +500 km effective scan radius
- **Effect**: Radar power +2, extends facility/craft detection combined

**Special Systems** (Late-Game):
- **Teleport Device**: Enables teleportation ability (2 slots, 50 weight)
- **Repair Kit**: Craft restores +10 HP/turn while stationary

#### Energy System
- **Energy Points (EP)**: Fuel for craft systems (weapons, shields, engines)
- **Regeneration**: Fixed per-turn regeneration (+2-5 EP/turn depending on craft)
- **Usage**: Weapons cost energy (5-40 EP per shot), abilities consume energy
- **Energy Bank Addon**: Increases max energy by +20 EP; costs 1 addon slot
- **Energy Generator Addon**: Increases regeneration by +2 EP/turn; costs 1 addon slot
- **No Offline Mode**: Craft always has minimum energy for basic functions

#### Shield Systems
- **Shield Addon**: Temporary +10 HP per turn (requires active power allocation)
- **Regeneration**: Shields regenerate at normal rate when not damaged
- **Toggle**: Shields can be toggled on/off (drains/restores energy)
- **Stacking**: Effects do not stack; only one shield system per craft

### Weapon Bonuses

Crafts receive **inherent bonuses** to equipped weapons based on craft specialization:

#### Power Bonus
- **Effect**: Bonus to weapon damage output
- **Range**: +10% (Scout) to +50% (Bomber specialization)
- **Stacking**: Applies to all equipped weapons
- **Example**: Bomber with +30% power bonus fires missiles dealing 80 damage instead of 60

#### Accuracy Bonus (Aim)
- **Effect**: Bonus to weapon hit chance
- **Range**: 0% to +15%
- **Combat Use**: Improves targeting in Interception combat
- **Specialization**: Interceptor craft gain +15% accuracy; Bombers get -5% accuracy penalty

#### Dodge Bonus (React)
- **Effect**: Bonus to evasion/dodge chance vs. enemy weapons
- **Range**: 0% to +20%
- **Timing**: Applies when targeted by enemy weapons
- **Specialization**: Scout craft gain +20% dodge; Battleships get -10% dodge penalty

#### Range Bonus (Strength)
- **Effect**: Bonus to weapon effective range
- **Range**: 0 km to +50%
- **Calculation**: Each +1 strength = +10% range (e.g., strength +3 = +30% range)
- **Specialization**: Long-range bombers gain +3 strength; close-combat fighters gain -1

---

## Craft Statistics Reference (By Size)

### Health Points (HP) Range

| Craft Size | Classification | HP Range | Examples | Notes |
|---|---|---|---|---|
| **Small** | Scout, Interceptor | 100-150 HP | Scout (120), Interceptor (140) | Fast, fragile |
| **Medium** | Transport, Fighter | 200-300 HP | Transport (240), Fighter (280) | Balanced |
| **Large** | Heavy Fighter, Bomber | 350-450 HP | Heavy Fighter (380), Bomber (420) | Slow, tanky |
| **Extra Large** | Battleship, Command | 500-600 HP | Battleship (550), Mobile Base (600) | Very durable |

**Progression:** Crafts gain +1-2 HP per rank (rank 0-6 can add 0-12 HP)

### Fuel Capacity (Range)

| Craft Size | Fuel Tank Capacity | Geoscape Range | Fuel Consumption | Notes |
|---|---|---|---|---|
| **Small** | 500-800 units | 5,000-8,000 km | 1 fuel/hex | Quick operations |
| **Medium** | 1,500-2,500 units | 15,000-25,000 km | 2-3 fuel/hex | Balanced range |
| **Large** | 3,000-5,000 units | 30,000-50,000 km | 3-5 fuel/hex | Long missions |
| **Extra Large** | 6,000-8,000 units | 60,000-80,000 km | 4-6 fuel/hex | Intercontinental |

**Fuel Tank Addon:** Each addon +1,000 range (stack up to 2 addon slots max +2,000 additional range)

**Fuel Consumption Formula:** 1 fuel + (fuel_per_hex × distance_in_hexes × cargo_weight_modifier)

### Speed (Movement Rate)

| Craft Class | Geoscape Speed | Interception Speed | Combat AP | Notes |
|---|---|---|---|---|
| **Scout** | 4 hexes/turn | 4 action points | 4 AP | Fastest, high mobility |
| **Interceptor** | 3-4 hexes/turn | 3 action points | 3 AP | Combat optimized |
| **Transport** | 1-2 hexes/turn | 1 action point | 2 AP | Slow but steady |
| **Fighter** | 3 hexes/turn | 3-4 action points | 3 AP | Balanced |
| **Heavy Fighter** | 2-3 hexes/turn | 2-3 action points | 3 AP | Slower, powerful |
| **Bomber** | 2 hexes/turn | 2 action points | 2 AP | Deliberate strikes |
| **Battleship** | 1 hex/turn | 1 action point | 3 AP | Slow, durable |

**Speed Modifiers:**
- Cargo weight: -1 hex if fully loaded
- Damage: -1 hex if HP < 50%
- Afterburner addon: +1 hex/turn
- Fuel consumption: +25% when using speed bonus

### Crew Capacity (Unit Slots)

| Craft Size | Base Capacity | Maximum (with addons) | Addon Cost |
|---|---|---|---|
| **Small** | 1-2 units | 3-4 units | Crew Cabin (+2 slots, 1 addon) |
| **Medium** | 4-6 units | 8-10 units | 2 Crew Cabins max |
| **Large** | 8-10 units | 12-14 units | 2 Crew Cabins max |
| **Extra Large** | 12-20 units | 20-24 units | 2 Crew Cabins max |

**Size Calculation:** Each unit occupies slots equal to their size rating (Small unit = 1 slot, Large unit = 4 slots)

### Cargo Capacity (Equipment Weight)

| Craft Class | Base Cargo | Max with Addon | Equipment Types | Notes |
|---|---|---|---|---|
| **Scout** | 500-1,000 kg | 1,500-2,000 kg | Light weapons, armor | Limited loadout |
| **Interceptor** | 1,000-1,500 kg | 2,000-3,000 kg | Medium weapons, armor | Combat focus |
| **Transport** | 3,000-5,000 kg | 5,000-7,000 kg | Heavy weapons, multiple sets | Maximum capacity |
| **Fighter** | 1,500-2,500 kg | 2,500-4,000 kg | Medium-heavy weapons | Weapon focus |
| **Heavy Fighter** | 2,000-3,000 kg | 3,000-4,500 kg | Heavy weapons, armor | Mixed load |
| **Bomber** | 2,500-4,000 kg | 4,000-6,000 kg | Missiles, bombs, armor | Payload focus |
| **Battleship** | 4,000-8,000 kg | 8,000-10,000 kg | Multiple weapon sets | Strategic cargo |

**Cargo Bay Addon:** Each addon +500 kg capacity (max 2 addons = +1,000 kg additional)

**Weight Scaling:**
- Light weapons: 200-400 kg
- Medium weapons: 500-800 kg
- Heavy weapons: 1,000-1,500 kg
- Unit armor sets: 300-600 kg
- Equipment: 100-200 kg per item

### Armor Rating

| Craft Class | Base Armor | Max with Addon | Armor Effect |
|---|---|---|---|
| **Scout** | 2-4 | 6-8 | Minimal protection |
| **Interceptor** | 4-6 | 8-10 | Light armor |
| **Transport** | 3-5 | 7-9 | Light-medium armor |
| **Fighter** | 5-7 | 9-11 | Medium armor |
| **Heavy Fighter** | 7-9 | 11-13 | Medium-heavy armor |
| **Bomber** | 6-8 | 10-12 | Medium-heavy armor |
| **Battleship** | 10-15 | 15-20 | Heavy armor |

**Armor Addon (Metal Plating):** Each addon +4 armor (max 2 addons = +8 armor additional)

**Armor Effectiveness:** Reduces incoming damage by 10% per armor point (e.g., 5 armor = 50% damage reduction, capped at 80% max)

### Radar & Detection

| Craft Class | Base Radar Power | Detection Range | With Booster Addon |
|---|---|---|---|
| **Scout** | 8 | 2,000 km | 2,500 km (+2 power) |
| **Interceptor** | 6 | 1,800 km | 2,300 km (+2 power) |
| **Transport** | 4 | 1,500 km | 2,000 km (+2 power) |
| **Fighter** | 6 | 1,800 km | 2,300 km |
| **Heavy Fighter** | 5 | 1,600 km | 2,100 km |
| **Bomber** | 4 | 1,500 km | 2,000 km |
| **Battleship** | 7 | 1,900 km | 2,400 km |
| **Stealth Craft** | 2 | 1,000 km | 1,500 km |

**Radar Booster Addon:** +2 radar power, +500 km range (max 1 addon per craft)

---

## Craft Weapons

### Weapon Categories

Crafts have access to specialized weapons distinct from unit weapons, optimized for aerial/naval combat:

#### Cannons
- **Type**: Ballistic projectile weapon
- **Range**: 20 km (air), 15 km (naval)
- **Damage**: 40 base (standard), 120 (heavy cannon)
- **AP Cost**: 1 action point
- **EP Cost**: 5-15 energy per shot
- **Accuracy**: 75% (standard), 70% (heavy)
- **Cooldown**: No cooldown; can fire every turn
- **Special**: Point Defense cannons available (20 km, 15 damage, anti-missile focus)

**Specializations**:
- **Point Defense**: 20 km range, 15 damage, -5% accuracy, anti-missile focus
- **Main Cannon**: 20 km range, 40 damage, 75% accuracy, balanced
- **Heavy Cannon**: 20 km range, 120 damage, 70% accuracy, tank role

#### Laser Arrays
- **Type**: Energy weapon
- **Range**: 40 km
- **Damage**: 60 base per turn
- **AP Cost**: 1 action point
- **EP Cost**: 20 energy per shot
- **Accuracy**: 75%
- **Cooldown**: 1 turn between shots
- **Special**: Continuous beam (damage per turn while beam active)

#### Missile Pods
- **Type**: Guided projectile weapon
- **Range**: 50-80 km
- **Damage**: 80 base (standard), 240 (heavy missile)
- **AP Cost**: 2 action points
- **EP Cost**: 6-20 energy per missile
- **Accuracy**: 85% (standard), 75% (heavy)
- **Cooldown**: 2 turns between salvos
- **Special**: Area effect (3-hex radius blast), homing capability

#### Plasma Casters
- **Type**: Exotic energy weapon
- **Range**: 30 km
- **Damage**: 70 base
- **AP Cost**: 2 action points
- **EP Cost**: 25 energy per shot
- **Accuracy**: 70%
- **Armor Penetration**: Ignores 50% of target armor
- **Cooldown**: 2 turns
- **Special**: Unlocked through alien technology research

#### Specialty Weapons
- **EMP Cannon**: Disables systems; damage reduced but stuns mechanical units
- **Concussive Blast**: High knockback; area suppression
- **Tractor Beam**: Disables movement; non-lethal capture

#### Torpedoes (Underwater)
- **Type**: Guided underwater projectile
- **Range**: 20 km (underwater)
- **Damage**: 60 base
- **AP Cost**: 2 action points
- **EP Cost**: 12 energy per torpedo
- **Accuracy**: 80%
- **Cooldown**: 1 turn
- **Special**: Only submarine/naval craft; cannot be used in air

### Weapon Configuration

**Slot System**:
- Each craft has exactly **2 weapon slots** (hardpoints)
- Heavy weapons consume both slots; dual standard weapons or single heavy + utilities possible
- Configuration changed in base (takes 1 week to rearm/reconfigure)

**Item Versions**:
All craft weapons available in two versions:

| Version | Scale | Damage Multiplier | Weight | Typical Weapons |
|---------|-------|-------------------|--------|-----------------|
| **Normal** | Standard | 1× | 1× | Cannon, Laser, Missile |
| **Heavy** | 3× larger | 3× damage | 3× weight | Heavy Cannon (120 dmg), Heavy Missile (240 dmg) |

**Example**: Standard Laser (60 damage) vs. Heavy Laser (180 damage); Heavy consumes more power and both weapon slots if equipped solo

---

## Craft Addons & Upgrades

### Addon Slot System

Crafts have **2 addon slots** for specialized equipment:

| Addon | Effect | Slot Cost | Weight | Use Case |
|-------|--------|-----------|--------|----------|
| **Crew Cabin** | Crew capacity +2 units | 1 | 10 | Increase transport capacity |
| **Cargo Bay** | Cargo capacity +20 units | 1 | 15 | Increase weapon/armor inventory |
| **Shield Generator** | Adds temporary +10 HP/turn shield | 1 | 20 | Defensive system |
| **Afterburner** | Speed +1 movement | 1 | 12 | Faster Geoscape movement |
| **Radar Booster** | Radar power +2, range +500 km | 1 | 8 | Enhanced detection |
| **Teleport Device** | Enables teleportation ability | 2 | 50 | Special tech (rare, late-game) |
| **Repair Kit** | Craft restores +10 HP/turn while stationary | 1 | 25 | Passive healing in base |
| **Fuel Tank** | Range +1,000 km | 1 | 30 | Extended Geoscape range |
| **Energy Generator** | Energy regeneration +2 EP/turn | 1 | 15 | Enhanced weapon power |
| **Energy Bank** | Max energy capacity +20 EP | 1 | 10 | More powerful attacks |
| **Metal Armor** | Health +20 HP | 1 | 40 | Increased durability |
| **Stealth Plating** | Cover/concealment +2 | 1 | 8 | Better detection evasion |

### Addon Strategic Choices

**Combat Focus**: Weapon upgrades + Energy systems for pure Interception capability
**Transport Focus**: Crew Cabin + Cargo Bay for maximum deployment flexibility
**Exploration Focus**: Radar Booster + Fuel Tank for extended scouting missions
**Balanced Setup**: 1 defensive addon + 1 utility addon for versatility

---

## Pilot Assignment & Crew System

### Core Principle: Pilots ARE Units

**Design Philosophy**: Crafts are vehicles operated by skilled personnel, not autonomous entities. All progression and performance bonuses come from the **pilots** assigned to the craft, not the craft itself. Crafts do not gain experience or ranks—only pilots do.

### Crew Requirements

Each craft type requires a minimum number of pilots/crew to operate:

| Craft Type | Required Pilots | Crew Capacity | Notes |
|------------|----------------|---------------|-------|
| **Scout** | 1 pilot | 1 | Single-seat reconnaissance |
| **Interceptor** | 1 pilot | 1 | Single-seat fighter |
| **Fighter** | 1 pilot | 1-2 | Optional co-pilot slot |
| **Bomber** | 1 pilot | 2-3 | Pilot + bombardier + optional crew |
| **Transport** | 1 pilot | 2-4 | Pilot + co-pilot + crew |
| **Heavy Transport** | 1 pilot | 3-6 | Pilot + co-pilot + 2-4 crew |
| **Submarine** | 1 pilot | 2-3 | Pilot + navigator + crew |
| **Battleship** | 1 pilot | 4-8 | Pilot + co-pilot + 3-6 crew |
| **Gunship** | 1 pilot | 2-3 | Pilot + gunner + crew |

**Launch Requirement**: Craft cannot launch missions without **minimum required pilots** assigned.

### Crew Positions & Roles

Crew members are assigned to specific positions that determine their bonus contribution:

#### Position 1: Primary Pilot
- **Role**: Controls craft, makes tactical decisions
- **Stat Contribution**: **100%** of pilot's stats applied to craft bonuses
- **Requirements**: Must have appropriate pilot class (Fighter Pilot for Interceptor, etc.)
- **XP Gain**: Full pilot XP from interception missions

#### Position 2: Co-Pilot
- **Role**: Assists pilot, manages systems
- **Stat Contribution**: **50%** of pilot's stats applied to craft bonuses
- **Requirements**: Any pilot class (Rank 1+)
- **XP Gain**: 50% pilot XP from interception missions

#### Position 3+: Crew
- **Role**: Operates subsystems (weapons, radar, engineering)
- **Stat Contribution**: **25%** of each crew member's stats
- **Requirements**: Any unit (pilot class not required, but piloting stat still contributes)
- **XP Gain**: 25% pilot XP from interception missions

#### Additional Crew (4+)
- **Role**: Support, reserves, specialized systems
- **Stat Contribution**: **10%** per additional crew member (diminishing returns)
- **Purpose**: Large crafts benefit from larger crews but gains diminish

**Example: Heavy Transport Crew**
```
Position 1 (Pilot): Alice - Piloting 10 → +8% speed (100% contribution)
Position 2 (Co-Pilot): Bob - Piloting 8 → +2% speed (50% of +4%)
Position 3 (Crew): Charlie - Piloting 6 → +0% speed (base level, no bonus)
Position 4 (Crew): Diana - Piloting 7 → +0.2% speed (10% of +2%)

Total Speed Bonus: +10.2%
```

### Pilot Stat Bonuses to Craft

Pilot stats directly affect craft performance through these formulas:

#### Piloting Stat → Craft Bonuses
- **Speed Bonus**: (Piloting - 6) × 2% per point
  - Example: Piloting 10 = (10 - 6) × 2% = +8% craft speed
- **Accuracy Bonus**: (Piloting - 6) × 3% per point
  - Example: Piloting 10 = (10 - 6) × 3% = +12% weapon accuracy
- **Dodge Bonus**: (Piloting - 6) × 2% per point
  - Example: Piloting 10 = (10 - 6) × 2% = +8% dodge chance
- **Fuel Efficiency**: (Piloting - 6) × 1% per point
  - Example: Piloting 10 = (10 - 6) × 1% = +4% fuel efficiency

#### Secondary Stat Bonuses
- **Dexterity → Initiative**: +1 initiative per 2 points of pilot's Dexterity
- **Perception → Sensor Range**: +1 hex detection per 2 points of pilot's Perception
- **Intelligence → Power Management**: +1% energy regen per 2 points of pilot's Intelligence

### Pilot Class Requirements

Different craft types require specific pilot classes to operate:

| Craft Type | Minimum Pilot Class | Minimum Rank |
|------------|-------------------|--------------|
| Scout | Any Pilot | Rank 1 |
| Interceptor | Fighter Pilot | Rank 2 |
| Fighter | Fighter Pilot | Rank 2 |
| Bomber | Bomber Pilot | Rank 2 |
| Transport | Transport Pilot | Rank 2 |
| Heavy Transport | Transport Pilot (Advanced) | Rank 3 |
| Submarine | Naval Pilot | Rank 2 |
| Battleship | Naval Pilot (Fleet Commander) | Rank 3 |
| Gunship | Helicopter Pilot | Rank 2 |

**Class Mismatch Penalty**: Assigning a pilot without the required class imposes:
- -30% to all craft bonuses
- +50% fuel consumption
- Cannot use craft special abilities

**Example**: Assigning a Transport Pilot to an Interceptor = poor performance (needs Fighter Pilot)

### Pilot Fatigue System

Pilots accumulate fatigue from extended operations, reducing their effectiveness:

#### Fatigue Accumulation
- **Interception Mission**: +10 fatigue per mission
- **Long-Range Travel**: +5 fatigue per 10 hexes traveled
- **Combat Damage**: +5 fatigue if craft takes >50% damage
- **Maximum Fatigue**: 100 (capped)

#### Fatigue Effects on Bonuses
Fatigue reduces pilot's effective stat contribution:

```
Effective Stat = Base Stat × (1 - Fatigue/200)

Example: Pilot with Piloting 10, Fatigue 60
Effective Piloting = 10 × (1 - 60/200) = 10 × 0.7 = 7
Craft bonus = (7 - 6) × 2% = +2% speed (instead of +8%)
```

**Maximum Penalty**: -50% at 100 fatigue (not completely disabled, but significantly reduced)

#### Fatigue Recovery
- **Rest in Base**: -10 fatigue per day (full recovery in 10 days)
- **Medical Facility**: -15 fatigue per day (faster recovery)
- **Stimulants** (risky): Temporarily reduce fatigue by 30, but +10 fatigue rebound after mission

### Crew Management Workflow

#### Assigning Pilots to Craft
1. Select craft in base hangar
2. Open crew assignment panel
3. Select available pilots (filtered by class requirements)
4. Assign to positions: Pilot (primary) → Co-Pilot → Crew
5. View calculated stat bonuses preview
6. Confirm assignment

#### Unassigning Pilots
1. Select craft with assigned crew
2. Remove pilot from position
3. Pilot returns to personnel pool
4. Pilot can be deployed to battlescape or assigned to another craft

#### Crew Readiness Status
Crafts display readiness status based on crew:
- ✅ **Ready**: Minimum crew assigned, all pilots rested (<50 fatigue)
- ⚠️ **Fatigued**: Crew assigned but high fatigue (50-80)
- ❌ **Not Ready**: Missing required crew OR critical fatigue (80+)
- 🚫 **Cannot Launch**: Below minimum crew requirements

### Pilot Experience from Interception

Pilots gain **Pilot XP** (separate from ground combat XP) through interception missions:

#### XP Sources & Amounts
| Action | Pilot XP | Co-Pilot XP | Crew XP |
|--------|----------|-------------|---------|
| **Mission Participation** | +10 XP | +5 XP | +2 XP |
| **Kill Enemy Craft** | +50 XP | +25 XP | +12 XP |
| **Assist in Kill** | +25 XP | +12 XP | +6 XP |
| **Survive Interception** | +10 XP | +5 XP | +2 XP |
| **Victory (force retreat)** | +30 XP | +15 XP | +7 XP |
| **Perfect Victory (no damage)** | +50 XP | +25 XP | +12 XP |

**XP Distribution**: XP is scaled by position (Pilot 100%, Co-Pilot 50%, Crew 25%)

**Example Interception Mission:**
- Alice (Pilot): Kills 1 UFO (+50), survives (+10), victory (+30) = **90 Pilot XP**
- Bob (Co-Pilot): Assist (+25), survives (+5), victory (+15) = **45 Pilot XP**
- Charlie (Crew): Participation (+2), survives (+2), victory (+7) = **11 Pilot XP**

### Dual XP Tracking: Pilot XP vs. Ground XP

Each unit tracks **two separate XP pools**:

1. **Ground Combat XP**: From battlescape missions, advances ground combat class/rank
2. **Pilot XP**: From interception missions, advances pilot class/rank

**Independent Progression**: A unit can be:
- Rank 3 Marksman (300 ground XP) + Rank 2 Fighter Pilot (100 pilot XP)
- Progress in BOTH paths simultaneously
- Different classes for each role

**Strategic Flexibility**: Players can:
- Train units as pilots only (focus on interception)
- Train units as soldiers only (focus on ground combat)
- Train units in both roles (jack-of-all-trades)

### Crew Composition Strategy

#### Optimal Crew Builds

**Scout/Interceptor (Single Pilot):**
- Priority: Ace Fighter Pilot (Rank 3+) with Piloting 12+
- Goal: Maximum accuracy and dodge for air-to-air combat

**Bomber (Pilot + Crew):**
- Pilot: Bomber Pilot (Rank 2+) with high Intelligence
- Crew: Any unit with Perception (for targeting)
- Goal: Precision bombing, ground target accuracy

**Transport (Multi-Crew):**
- Pilot: Transport Pilot (Rank 2+) with high Piloting
- Co-Pilot: Transport Pilot (Rank 1+) for fuel efficiency
- Crew: Any units (minimal contribution)
- Goal: Fuel efficiency, safe deployment

**Battleship (Large Crew):**
- Pilot: Fleet Commander (Rank 3+) with Piloting 10+
- Co-Pilot: Naval Pilot (Rank 2+)
- Crew (3-4): Mix of units with varied stats
- Goal: Balanced bonuses, sustained operations

### No Craft Experience or Ranks

**Design Decision**: Crafts do **NOT** gain XP, ranks, or autonomous progression. All improvement comes from:
1. **Pilot Progression**: Better pilots → better craft performance
2. **Technology Research**: New craft types with superior base stats
3. **Addons/Upgrades**: Equipment improvements (shields, weapons, armor)

**Rationale**:
- Crafts are mechanical equipment, not sentient beings
- Simplifies balancing (one progression system, not two)
- Encourages player investment in personnel (pilots matter)
- Maintains strategic flexibility (swap pilots between crafts)

**Comparison to Old System:**
```
OLD: Veteran Craft (Rank 5, experienced) + Rookie Pilot = ???
NEW: Advanced Craft (tech level) + Ace Pilot (Rank 3) = Clear bonuses
```

---

## Craft Maintenance & Repair

### Repair System

**Passive Repair** (Storage):
- Craft at rest in base: +10% max HP per week
- **Slow Recovery**: Full repair takes ~10 weeks for damaged craft
- **No Active Refueling**: Fuel is automatically deducted from base inventory per movement

**Facility Upgrades**:
- **Workshop**: Default repair rate +10%/week
- **Advanced Maintenance Hangar**: Repair rate +20%/week (costs 5,000 credits to upgrade)
- **Master Repair Facility**: Repair rate +30%/week (costs 15,000 credits)

**Combat Damage**:
- Damage sustained during Interception combat requires active repair
- Each point of damage reduces effectiveness in subsequent missions
- No "rearming" phase for ammunition (energy automatically regenerates)

### Fuel Management

**Automatic Fuel Consumption**:
- Fuel is consumed automatically when craft moves on Geoscape
- Fuel consumption scales with:
  - Craft speed (faster = higher consumption)
  - Distance traveled (further = more fuel used)
  - Craft size (heavier = higher consumption)
  - Cargo weight (loaded = higher consumption)

**Fuel Supply Chain**:
1. Base stores fuel as inventory resource
2. Movement action consumes 1-3 fuel per hex (varies by craft)
3. Craft cannot move if insufficient fuel available
4. Manufacturing produces fuel or trades resources for fuel

**Emergency Landing**:
- Craft can land with 0 fuel (stranded status)
- Requires rescue mission to recover stranded unit
- Expensive and time-consuming alternative to careful fuel planning

### Monthly Operational Cost

**Maintenance Salary** (based on craft class):

| Craft Class | Monthly Cost | Notes |
|------------|-------------|-------|
| Small Scout | 100 credits | Fast but fragile |
| Interceptor | 200 credits | Balanced |
| Transport | 150 credits | Large but slow |
| Heavy Fighter | 300 credits | High maintenance |
| Battleship | 500+ credits | Expensive to operate |

**Cost Factors**:
- Newer/upgraded crafts cost more to maintain
- Damaged crafts have +50% maintenance cost until repaired
- Addon complexity increases maintenance by +25 credits per addon installed

**Budget Impact**:
- Early game: 2-3 craft × 150 credits = 300-450 credits/month
- Mid game: 6-8 craft × 200 credits = 1,200-1,600 credits/month
- Late game: 12-20 craft × 250+ credits = 3,000-5,000+ credits/month

---

## Craft Transport Mechanics

### What Crafts Carry

**Source Reference**: CRAFT_CAPACITY_MODEL.md §Transport Logistics

#### Unit Transport
- **Primary Function**: Carries combat units to mission sites
- **Capacity**: Unit slots (4-20 depending on craft)
- **Damage**: Craft damage can injure carried units (10% of craft damage carries through)
- **Crew Addon**: Expands capacity (+2 slots per addon, max 2 addons)

#### Equipment Transport
- **Cargo Capacity**: Weapon/armor/addon inventory
- **Separate from Units**: Unit inventory items are NOT carried by craft separately
- **Example**: Unit carries 2 weapons + 1 armor; craft carries 3 additional sets of equipment in cargo bay

#### What Crafts DO NOT Carry
- Unit personal inventory items (each unit carries their own equipment)
- Mission salvage (separate recovery team handles this)
- Consumables not explicitly loaded (medical supplies, ammunition counted as equipment)

### Salvage Recovery (Separate System)

**Mission Salvage Mechanics**:
- Valuable items left on battlefield are recovered by **separate salvage teams** (not craft)
- Player chooses which items to recover after battle
- **Salvage Transfer Cost**: Player pays transportation fee based on:
  - Distance from base (km-based)
  - Item weight/size (larger items cost more)
  - Risk level (hot zones cost more to evacuate)
- **Storage Space**: Recovered salvage occupies separate inventory space (not craft cargo)
- **Optional**: Player can leave items behind to avoid transport costs

**Example**: After a battle, 5 alien corpses (salvageable) are available:
- Recover all 5: 500 credits transfer cost (heavy, dangerous)
- Recover 2 priority specimens: 200 credits transfer cost
- Leave all behind: 0 cost (lost potential tech research)

---

## Crash Sites & Rescue Missions

### Crash Mechanics

**Interception Crashes**:
- If craft loses all HP during Interception combat, it crashes (similar to UFO crashes)
- Crash location generated on Geoscape map
- Craft is recovered if pilot/crew rescued

**Rescue Mission Trigger**:
- Automatically generated mission with objective: "Rescue Pilot/Crew"
- Mission type: Covert rescue/extraction
- Difficulty: High (enemy forces converge on crash site)
- Time-sensitive: Mission expires if not completed within 3 days (crew POW if captured)

**Rescue Outcome**:
- **Success**: Crew recovered, craft recoverable (can be repaired)
- **Failure**: Crew captured (POW status), craft becomes wreckage (permanent loss)
- **Partial Success**: Crew escapes, craft left behind (wreckage salvage available)

---

## Craft-Unit Integration

### No Direct Combat Synergy

**Clarification**: Crafts provide NO statistical bonuses to carried units:
- Unit accuracy unaffected by craft pilot skill
- Unit damage not modified by craft weapons
- Unit morale not influenced by craft class
- Craft serves purely as transport; tactical bonuses come from equipment, traits, and unit rank

**Justification**: Maintains unit independence and prevents craft-unit power creep. Combat is purely unit-based; craft contribution is logistical and tactical positioning.

### Craft Capacity Constraints

**Squad Composition**:
- Craft capacity limits squad size (not all units fit in one craft for large missions)
- Multiple craft deployments require:
  - Scheduling multiple waves (time cost)
  - Multiple fuel consumptions
  - Multiple landing noise effects (stealth budget impact)

**Strategic Decision**: Larger craft = more efficient deployment but higher operational cost and stealth footprint

---

## Craft Types by Engine & Terrain

### Terrain Movement Types

Crafts are classified by their primary movement environment:

#### Air-Based (Geoscape Movement)
- Move freely across any terrain
- Landing cost varies by terrain (mountain = higher fuel, plains = lower)
- Interception encounters air-to-air combat
- Restricted from underwater; must land at coastal bases

#### Land-Based
- Move across terrestrial surfaces
- Slower Geoscape movement
- Cannot cross water without road/bridge
- Amphibious variants available with research

#### Water-Based (Naval)
- Move across ocean/sea tiles
- Cannot cross land without port facilities
- Naval interception vs. enemy ships/submarines
- Coastal base requirement

#### Underwater
- Move underwater only
- Cannot surface without special research
- Sub-to-air combat handled through specialized variants
- Deep ocean research unlocks abyssal bases

---

## Quick Reference Table

| Aspect | Details |
|--------|---------|
| **Craft Stats Range** | Speed 1-4; Health 50-500; Armor 0-4; Energy 20-100 |
| **Weapon Slots** | 2 hardpoints (standard or 1 heavy) |
| **Addon Slots** | 2 slots for upgrades, armor, utilities |
| **Crew Capacity** | 4-20 units (expandable with addons) |
| **Cargo Capacity** | 30-100 weight units |
| **Fuel Range** | 500-6,000 km (expandable with tank upgrades) |
| **Rank Progression** | Rank 0 (0 XP) → Rank 6 (2,100 XP) |
| **Monthly Salary** | 100-500+ credits depending on class |
| **Passive Repair** | +10% HP per week in base |
| **Storage Facilities** | Garage (1 craft), Hangar (4 crafts) |
| **Craft Sizing** | Small (1-2), Medium (3-4), Large (5-6) |
| **Landing Noise** | 20-200 points (impacts stealth budget) |

---

## Craft Manufacturing & Technology

### Manufacturing Process

**Requirements**:
1. **Technology Research**: Unlock craft blueprint through research tree
2. **Resources**: Allocate metals, fuel, rare materials (varies by craft class)
3. **Workshop Space**: Requires active workshop facility
4. **Time**: Manufacturing duration 1-4 weeks depending on craft complexity
5. **Storage Space**: Finished craft requires garage/hangar space

**Cost Scaling**:
- Early-game craft (Scout): 2,000 credits + resources
- Mid-game craft (Interceptor): 5,000 credits + advanced resources
- Late-game craft (Battleship): 20,000+ credits + rare materials

### Technology Unlocks

**Research Progression**:
1. Basic Crafts (Start): Small Scout, Transport
2. Air Combat (Research 1): Interceptor, Bomber
3. Advanced Armor (Research 2): Heavy Armor, Shield addons
4. Naval Warfare (Research 3): Ships, Submarines
5. Alien Technology (Research 4): Plasma weapons, Teleport devices
6. Late-Game Mastery (Research 5): Battleships, Meta-crafts

### Upgrade Paths

Each craft class has specialization branches:
- **Scout** → Elite Scout → Ghost Operative
- **Interceptor** → Ace Fighter → Legendary Interceptor
- **Transport** → Assault Transport → Heavy Carrier
- **Bomber** → Precision Bomber → Carpet Bomber

---

## Design Philosophy

The Craft system emphasizes:

1. **Logistical Strategy**: Fleet management is as important as tactical combat
2. **Resource Commitment**: Each craft requires ongoing fuel, maintenance, and crew investment
3. **Meaningful Choices**: Limited addon slots force specialization decisions
4. **Escalating Costs**: Late-game fleets become expensive to operate (balancing end-game progression)
5. **Tactical Positioning**: Landing location, fuel conservation, and stealth budgeting are core decisions
6. **Growth Through Technology**: New crafts acquired through research more than experience grinding
7. **Crew Safety**: Rescue missions add narrative weight to combat operations

This system creates interdependency between base management (manufacturing, fuel production), Geoscape strategy (patrol routes, interception), and Battlescape tactics (unit loadout, insertion strategy).

---

## Integration with Other Systems

### Geoscape Integration
- Crafts visible on Geoscape map as player-controlled tokens
- Movement restricted by fuel, terrain, and range
- Interception encounters triggered when UFOs detected by radar
- Patrol missions generate XP passively

### Interception Integration
- Dedicated mini-game system (see Interception documentation)
- Craft combat resolved separate from Battlescape
- Victory in Interception prevents UFO reaching base
- Crashed UFOs trigger salvage missions

### Battlescape Integration
- Crafts deliver units to mission site (not visible in tactical layer)
- Craft damage during transport affects unit HP (10% penetration)
- Landing noise affects available stealth budget on mission
- Craft extraction mechanism ends Battlescape mission

### Economy Integration
- Craft manufacturing consumes manufacturing capacity and credits
- Fuel production tied to economy/resource generation
- Monthly maintenance costs impact operational budget
- Salvage recovery from crashed crafts generates economic return

---

## Examples

### Scenario 1: Fleet Expansion Dilemma
**Setup**: Player has funding for one new craft but multiple strategic needs
**Action**: Choose between interceptor for air defense vs. transport for rapid deployment
**Result**: Interceptor choice prevents base attacks but limits global response capability

### Scenario 2: Pilot Shortage Crisis
**Setup**: Multiple crafts operational but insufficient trained pilots
**Action**: Balance pilot training with immediate mission requirements
**Result**: Delayed operations while building pilot cadre, creating strategic vulnerability

### Scenario 3: Interception Failure Recovery
**Setup**: Craft crashes during UFO interception, crew survives
**Action**: Launch rescue mission while managing damaged craft recovery
**Result**: Successful crew rescue but craft requires extensive repairs and lost operational time

### Scenario 4: Fuel Management Optimization
**Setup**: Multiple missions require craft deployment across distant regions
**Action**: Position crafts strategically and manage fuel consumption
**Result**: Efficient fuel usage enables sustained operations without supply shortages

---

## Balance Parameters

| Parameter | Value | Range | Reasoning | Difficulty Scaling |
|-----------|-------|-------|-----------|-------------------|
| Craft Cost | 100,000 credits | 50K-200K | Entry barrier | ×0.8 on Easy |
| Fuel Consumption | 10 units/hex | 5-20 | Travel cost | ×0.7 on Easy |
| Maintenance Cost | 5,000/month | 2K-10K | Operating expense | ×0.5 on Easy |
| Repair Time | 30 days | 15-60 | Downtime balance | ×0.75 on Easy |
| Pilot Requirement | 1-3 pilots | 1-4 | Crew management | No scaling |
| Cargo Capacity | 8-16 units | 4-24 | Transport limits | ×1.25 on Hard |

---

## Difficulty Scaling

### Easy Mode
- Craft costs: 20% reduction
- Fuel consumption: 30% reduction
- Maintenance costs: 50% reduction
- Repair times: 25% reduction
- More favorable crash survival rates

### Normal Mode
- All parameters at standard values
- Balanced fleet management
- Standard operational costs
- Normal risk/reward ratios

### Hard Mode
- Craft costs: +25% increase
- Fuel consumption: +20% increase
- Maintenance costs: +50% increase
- Repair times: +25% increase
- Higher crash damage potential

### Impossible Mode
- Craft costs: +50% increase
- Fuel consumption: +50% increase
- Maintenance costs: +100% increase
- Repair times: +50% increase
- Frequent mechanical failures
- Limited spare parts availability

---

## Testing Scenarios

- [ ] **Craft Movement**: Verify fuel consumption and travel times work correctly
  - **Setup**: Craft traveling between two bases
  - **Action**: Execute long-distance movement
  - **Expected**: Fuel consumption matches distance and terrain
  - **Verify**: Fuel levels and arrival times

- [ ] **Interception Combat**: Test craft vs. UFO engagement mechanics
  - **Setup**: Craft intercepts UFO during patrol
  - **Action**: Execute interception mini-game
  - **Expected**: Combat resolution follows interception rules
  - **Verify**: Victory/defeat outcomes and craft damage

- [ ] **Pilot Assignment**: Verify pilot requirements and crew management
  - **Setup**: Craft with insufficient pilots
  - **Action**: Attempt to launch mission
  - **Expected**: System prevents under-crewed operations
  - **Verify**: Error messages and launch restrictions

- [ ] **Maintenance Costs**: Test ongoing operational expenses
  - **Setup**: Fleet of multiple crafts over time
  - **Action**: Process monthly maintenance
  - **Expected**: Costs scale with fleet size and craft types
  - **Verify**: Budget impacts and cost calculations

- [ ] **Crash Recovery**: Verify rescue mission generation and recovery mechanics
  - **Setup**: Craft crashes during interception
  - **Action**: Launch and complete rescue mission
  - **Expected**: Crew recovery and craft salvage possible
  - **Verify**: Mission generation and recovery outcomes

---

## Related Features

- **[Geoscape System]**: Craft movement and positioning on world map (Geoscape.md)
- **[Units System]**: Pilot management and crew assignments (Units.md)
- **[Pilots System]**: Specialized pilot training and abilities (Pilots.md)
- **[Interception System]**: Aerial combat mechanics (Interception.md)
- **[Items System]**: Craft equipment and weapon systems (Items.md)
- **[Missions System]**: Transport to mission sites (Missions.md)
- **[Economy System]**: Manufacturing and maintenance costs (Economy.md)

---

## Implementation Notes

**Priority Systems**:
1. Craft movement and fuel consumption mechanics
2. Pilot assignment and crew management
3. Interception combat integration
4. Maintenance and repair systems
5. Transport capacity and deployment

**Balance Considerations**:
- Fleet management should create meaningful strategic choices
- Fuel consumption encourages efficient positioning
- Maintenance costs balance fleet expansion
- Pilot requirements create crew management challenges
- Crash mechanics add risk to interception

**Testing Focus**:
- Fuel consumption calculations
- Pilot assignment validation
- Interception success rates
- Maintenance cost scaling
- Crash recovery mechanics

---

## Review Checklist

- [ ] Craft fundamentals clearly defined with core mechanics
- [ ] Craft classification system specified
- [ ] Craft statistics balanced and comprehensive
- [ ] Weapon systems integrated with interception
- [ ] Addons and upgrades provide meaningful progression
- [ ] Experience and progression system implemented
- [ ] Maintenance and repair mechanics balanced
- [ ] Transport mechanics support mission deployment
- [ ] Crash sites and rescue missions specified
- [ ] Craft-unit integration seamless
- [ ] Terrain-specific craft types balanced
- [ ] Manufacturing and technology progression clear
- [ ] Balance parameters quantified with reasoning
- [ ] Difficulty scaling implemented
- [ ] Testing scenarios comprehensive
- [ ] Related systems properly linked
- [ ] No undefined terminology
- [ ] Implementation feasible
