# Crafts System

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

---

## Overview

Crafts serve as the primary vehicles for strategic deployment and tactical operations in AlienFall. Similar to heroes in Heroes of Might and Magic, crafts function as persistent assets that move across the Geoscape carrying units to battle sites. Beyond transport, crafts engage in their own tactical layer through the **Interception system**, enabling player-controlled aerial combat against UFOs and enemy forces.

**Core Philosophy**: Crafts are valuable, upgradable assets that grow through experience and technological advancement. Players must balance maintaining a diverse fleet with the economic burden of maintenance and fuel consumption.

---

## Craft Fundamentals

### Design Assumptions

**Core Mechanics**:
- Crafts do NOT occupy map blocks on the Battlescape (currently; may change in future)
- Crafts have built-in crews (no separate, swappable pilot system; the craft itself gains experience)
- Crafts provide **no direct combat bonuses** to carried units during Battlescape missions
- Craft primary purpose is transportation; Interception is a secondary mini-game mechanic
- Crafts are recovered if crashed during Interception, triggering a rescue mission

**Scope Clarity**:
- Crafts transport units, weapons, and equipment between base and mission sites
- Crafts do NOT carry unit inventory items (each unit carries their own equipment)
- Mission salvage is handled separately (see Salvage System section)
- Experience gained separately from units carried (no shared XP)

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
2. Allocate resources (metals, fuel, rare materials)
3. Assign workshop time (1-4 weeks depending on craft class)
4. Require available storage space (garage/hangar)

**Promotion Path**: Existing crafts can be promoted through experience and research, unlocking upgrades to higher classes

### Craft Types by Role

#### Air-Based Crafts

| Type | Role | Primary Use | Speed | Armor | Cargo |
|------|------|-------------|-------|-------|-------|
| **Scout** | Reconnaissance | Map scanning, UFO detection | High | Low | Low |
| **Interceptor** | Air combat | Interception missions vs. UFOs | High | Medium | Low |
| **Bomber** | Ground attack | Airborne strike support | Medium | Medium | Medium |
| **Transport** | Unit deployment | Carry large squads to missions | Low | Low | High |
| **Assault Transport** | Hybrid | Mixed combat + transport | Medium | Medium | Medium |
| **Stealth Craft** | Special ops | Quick insertion/extraction | Very High | Low | Very Low |

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

## Craft Experience & Progression

### Experience Acquisition

Crafts gain experience independently from carried units:

#### Passive Gain
- **Base Training**: +1 XP per week in storage (no fuel/cost)
- **Repeatable**: Accumulates continuously when in base

#### Combat Gain
- **Per Interception Mission**: +5 XP
- **Per Enemy Intercepted**: +2 XP (e.g., 3 UFO interceptions = +6 XP)
- **Victory Bonus**: +10 XP if mission objective achieved

#### Travel Gain
- **Per Geoscape Travel**: +1 XP
- **Distances**: Long-range missions grant bonus XP
- **Example**: Scout mission across 10 hexes = +10 XP total

#### Combat Experience Calculation
- Kill enemy craft: +20 XP
- Survive damage (per 10 damage taken): +0.5 XP
- Spot enemy (per unique craft detected): +2 XP
- Destroy UFO: +25 XP (mission completion bonus)

### Rank Progression

**Promotion System**:
- Crafts follow **identical rank progression** as units (Rank 0-6)
- XP thresholds are **identical to units** (100, 300, 600, 1,000, 1,500, 2,100)
- Promotion unlocks:
  - Stat improvements (+1 to core stats per rank)
  - Access to better weapon/addon configurations
  - Specialized abilities (e.g., evasive maneuvers for Rank 4 scouts)

**Design Note**: It is often more economical to unlock new technology and manufacture an upgraded craft than to grind experience with the current craft. Experience provides incremental stat growth; technology research provides significant capability jumps.

### No Traits, Medals, or Transformations

Crafts do **not** possess:
- **Traits**: Crafts have fixed stat lines; no randomization
- **Medals**: Commendations system reserved for units
- **Transformations**: Upgrades handled through addons and manufacturing
- **Races**: Craft types are technology-specific, not faction-cultural

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

