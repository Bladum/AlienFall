# Craft Stats

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Craft Health & Destruction](#craft-health--destruction)
  - [Geoscape Logistics Framework](#geoscape-logistics-framework)
  - [Dogfight Combat Mobility](#dogfight-combat-mobility)
  - [Transport and Capacity Systems](#transport-and-capacity-systems)
  - [Detection and Stealth Characteristics](#detection-and-stealth-characteristics)
  - [Combat Systems Architecture](#combat-systems-architecture)
  - [Performance Monitoring Systems](#performance-monitoring-systems)
- [Examples](#examples)
  - [Craft Type Performance Profiles](#craft-type-performance-profiles)
    - [Small Fighter (Interceptor Role)](#small-fighter-interceptor-role)
    - [Medium Fighter (Versatile Role)](#medium-fighter-versatile-role)
    - [Heavy Fighter (Superior Combat Role)](#heavy-fighter-superior-combat-role)
    - [Light Bomber (Strike Role)](#light-bomber-strike-role)
    - [Medium Bomber (Heavy Strike Role)](#medium-bomber-heavy-strike-role)
  - [Fuel Consumption Calculations](#fuel-consumption-calculations)
    - [Short Interception Mission (2 provinces)](#short-interception-mission-2-provinces)
    - [Extended Patrol Mission (5 provinces)](#extended-patrol-mission-5-provinces)
    - [Maximum Range Operations](#maximum-range-operations)
  - [Combat Performance Metrics](#combat-performance-metrics)
    - [Dogfight Endurance Examples](#dogfight-endurance-examples)
    - [Weapon and Accuracy Systems](#weapon-and-accuracy-systems)
  - [Capacity and Loadout Examples](#capacity-and-loadout-examples)
    - [Interceptor Loadout Configuration](#interceptor-loadout-configuration)
    - [Transport Configuration](#transport-configuration)
    - [Bomber Setup](#bomber-setup)
    - [Reconnaissance Craft](#reconnaissance-craft)
  - [Detection and Stealth Applications](#detection-and-stealth-applications)
    - [Radar Coverage Systems](#radar-coverage-systems)
    - [Stealth Characteristics](#stealth-characteristics)
  - [Loadout Validation Examples](#loadout-validation-examples)
    - [Valid Configuration](#valid-configuration)
    - [Invalid Configuration - Slot Overload](#invalid-configuration---slot-overload)
    - [Invalid Configuration - Cargo Overload](#invalid-configuration---cargo-overload)
    - [Transport Capacity Validation](#transport-capacity-validation)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The craft stats system establishes comprehensive statistical frameworks for craft performance, separating geoscape logistics, detection capabilities, and dogfight mobility into distinct, tunable parameters. Each craft chassis receives a unique role through speed, range, fuel consumption, and hull characteristics, creating clear player-facing trade-offs between operational frequency, strategic reach, and survivability. The system implements deterministic calculations with full provenance tracking for reproducible gameplay outcomes, comprehensive performance monitoring, and extensive data-driven customization for modding support.

Stats are organized into logical categories with validation at mount/launch preventing inconsistent configurations, encouraging meaningful progression and upgrade choices that feel coherent across strategic and tactical layers.

## Mechanics

### Geoscape Logistics Framework

Strategic movement and operational parameters with deterministic fuel calculations:

- Speed Metrics: Missions per turn determining operational frequency from base deployment
- Range Parameters: Maximum distance in province units for single sortie execution
- Fuel Consumption: Resource items consumed per province traveled with configurable formulas
- Mission Fuel Cost: Total fuel calculated as Range × Speed × FuelUsage with explicit accounting
- Refuelling: Resource draws from base stock with onboard reserve limitations
- Strategic Positioning: Geographic coverage constraints for interception and patrol operations

### Dogfight Combat Mobility

Aerial engagement performance characteristics affecting combat dynamics:

- Hull Integrity: Craft durability measured in hit points during dogfight encounters
- Acceleration Rates: Maneuvering speed governing positioning, evasion, and engagement tactics
- Turn Capabilities: Rotational speed affecting combat positioning and retreat options
- Combat Endurance: Sustained engagement capacity with progressive damage accumulation
- Performance Degradation: Speed and maneuverability reduction under battle damage

### Transport and Capacity Systems

Carrying capacity and equipment mounting limitations with validation rules:

- Unit Capacity: Soldier slot allocation for troop transportation with multi-slot unit support
- Weapon Slots: Hardpoint availability for armament installation (0-2 slots typically)
- Addon Slots: Auxiliary system mounting points (0-1 slots for specialized equipment)
- Item Cargo: Unified capacity system for weapons, addons, and equipment with size requirements
- Loadout Restrictions: Slot-based and cargo limitations preventing over-configuration
- Mount Validation: Pre-deployment checks ensuring compatibility and capacity compliance

### Detection and Stealth Characteristics

Sensor capabilities and visibility management in strategic operations:

- Radar Range: Airborne detection contribution in province tiles during flight operations
- Radar Power: Detection strength affecting UFO identification distance and accuracy
- Stealth Modifiers: Passive reductions in detectability with anti-stealth countermeasures
- Sensor Integration: Detection enhancement through equipment and addon systems
- Electronic Warfare: Active countermeasures affecting detection probability and jamming

### Combat Systems Architecture

Per-encounter resource management and weapon performance modifiers:

- Energy Pool: Per-encounter resource allocation for weapon firing and ability activation
- Energy Recharge: Per-turn regeneration rate during dogfight phases with depletion tracking
- Weapon Modifiers: Craft and pilot bonuses to range, damage, and accuracy (additive/multiplicative)
- Addon Integration: Auxiliary system effects on combat capabilities and resource management
- Resource Management: Energy allocation decisions affecting tactical options and sustainability
- Performance Bonuses: Craft-specific modifiers to damage output, evasion, and effectiveness

### Performance Monitoring Systems

Statistical tracking and modification systems with complete audit trails:

- Statistical Tracking: Base stats, current stats, and modifier accumulation with provenance
- Derived Calculations: Computed values from base statistics and equipment modifications
- Historical Logging: Performance history for trend analysis and optimization tracking
- Provenance Recording: Complete audit trail for deterministic reproduction and debugging
- Modification Stacking: Additive and multiplicative modifier application with clear precedence rules

### Craft Health & Destruction

#### Health Pool System

Crafts maintain health pools similar to base defense mechanics:

- Maximum Health: Craft class determines base health (e.g., Interceptor: 30 HP, Bomber: 80 HP, Transport: 80 HP)
- Current Health: Tracks damage from interception combat and repairs
- Health Regeneration: No automatic regeneration - requires base repair facilities
- Veterancy Bonuses: +1 HP per veterancy level (maximum +5 HP at level 5)

#### Damage Mechanics

Health loss occurs during interception engagements:

- Weapon Damage: Direct hits reduce craft health based on weapon damage values
- Critical Hits: Chance for double damage or system disablement
- Environmental Damage: Crash landings or extreme maneuvers can cause additional damage
- No Instant Destruction: Crafts can be damaged but continue fighting until health reaches 0

#### Destruction Consequences

When craft health reaches 0, destruction triggers specific outcomes:

- Crash Site Creation: Damaged craft creates temporary crash site mission
- Unit Survival: Units aboard may survive crash with injury chances
- Salvage Opportunities: Wrecked craft can be recovered for partial refunds
- Rescue Missions: New mission type to recover survivors and potentially repairable craft
- Economic Impact: Craft loss affects base funding and replacement costs

#### Repair System

Craft repairs occur daily at base hangars:

- Daily Repair: Damaged crafts are repaired to full health each day
- Hangar Capacity: Base hangar quality limits crafts repaired per day
- Repair Costs: Daily repair fees based on damage severity
- Priority System: Critical crafts repaired first
- No Field Repairs: Crafts must return to base for restoration

## Examples

### Craft Type Performance Profiles

#### Small Fighter (Interceptor Role)
- Speed: 2 missions/turn
- Range: 3 provinces
- Fuel Usage: 1 unit/province
- Hull: 80 HP
- Unit Capacity: 2 soldiers
- Weapon Slots: 2
- Addon Slots: 1
- Energy Pool: 80
- Strategic Role: High-frequency interception with limited transport capability

#### Medium Fighter (Versatile Role)
- Speed: 2 missions/turn
- Range: 4 provinces
- Fuel Usage: 1.2 units/province
- Hull: 100 HP
- Unit Capacity: 4 soldiers
- Weapon Slots: 2
- Addon Slots: 1
- Energy Pool: 100
- Strategic Role: Balanced operations with moderate transport and combat capability

#### Heavy Fighter (Superior Combat Role)
- Speed: 1 mission/turn
- Range: 5 provinces
- Fuel Usage: 1.6 units/province
- Hull: 150 HP
- Unit Capacity: 6 soldiers
- Weapon Slots: 2
- Addon Slots: 1
- Energy Pool: 120
- Strategic Role: High-survivability operations with extended range but reduced frequency

#### Light Bomber (Strike Role)
- Speed: 1 mission/turn
- Range: 6 provinces
- Fuel Usage: 2 units/province
- Hull: 120 HP
- Unit Capacity: 8 soldiers
- Weapon Slots: 1
- Addon Slots: 1
- Energy Pool: 100
- Strategic Role: Long-range strike missions with significant transport capacity

#### Medium Bomber (Heavy Strike Role)
- Speed: 1 mission/turn
- Range: 7 provinces
- Fuel Usage: 2.4 units/province
- Hull: 180 HP
- Unit Capacity: 10 soldiers
- Weapon Slots: 1
- Addon Slots: 1
- Energy Pool: 140
- Strategic Role: Extended-range bombardment with maximum troop carrying capacity

### Fuel Consumption Calculations

#### Short Interception Mission (2 provinces)
- Small Fighter: 2 × 2 × 1 = 4 fuel units
- Medium Fighter: 2 × 2 × 1.2 = 5 fuel units
- Heavy Fighter: 1 × 2 × 1.6 = 3 fuel units
- Light Bomber: 1 × 2 × 2 = 4 fuel units
- Strategic Impact: High-frequency craft consume more fuel per turn despite lower per-mission cost

#### Extended Patrol Mission (5 provinces)
- Small Fighter: 2 × 5 × 1 = 10 fuel units
- Medium Fighter: 2 × 5 × 1.2 = 12 fuel units
- Heavy Fighter: 1 × 5 × 1.6 = 8 fuel units
- Light Bomber: 1 × 5 × 2 = 10 fuel units
- Strategic Impact: Range limitations become critical for extended operations

#### Maximum Range Operations
- Small Fighter: 2 × 3 × 1 = 6 fuel units (range limited)
- Medium Fighter: 2 × 4 × 1.2 = 10 fuel units (range limited)
- Heavy Fighter: 1 × 5 × 1.6 = 8 fuel units (range limited)
- Light Bomber: 1 × 6 × 2 = 12 fuel units (range limited)
- Strategic Impact: Fuel consumption calculations determine practical operational radius

### Combat Performance Metrics

#### Dogfight Endurance Examples
- Small Fighter: 80 HP / 20 damage per hit = 4 turns average survival
- Medium Fighter: 100 HP / 20 damage per hit = 5 turns average survival
- Heavy Fighter: 150 HP / 20 damage per hit = 7-8 turns average survival
- Energy Management: 8-12 energy regeneration affecting weapon usage frequency
- Performance Degradation: 10-20% speed reduction when hull drops below 50%

#### Weapon and Accuracy Systems
- Base Accuracy: 70-80% with pilot skills adding 10-25% bonus
- Damage Output: 20-40 points per weapon system with critical multipliers
- Evasion Capabilities: 5-15% base dodge with acceleration affecting probability
- Energy Costs: 5-15 energy per weapon discharge with recharge limitations

### Capacity and Loadout Examples

#### Interceptor Loadout Configuration
- Weapon Slots: 2 (dual plasma cannons for dogfighting)
- Addon Slots: 1 (targeting computer for accuracy bonus)
- Unit Capacity: 2 (pilot + optional passenger)
- Cargo Requirements: Weapons (size 3 each) + addon (size 2) = 8/10 capacity
- Strategic Role: Optimized for air-to-air combat with minimal transport capability

#### Transport Configuration
- Weapon Slots: 1 (defensive turret for self-protection)
- Addon Slots: 1 (cargo expander for capacity increase)
- Unit Capacity: 6-8 (full squad deployment capability)
- Cargo Requirements: Defensive weapon (size 2) + cargo system (size 3) = 5/15 capacity
- Strategic Role: Troop deployment with basic self-defense capabilities

#### Bomber Setup
- Weapon Slots: 1 (heavy missile launcher for ground attack)
- Addon Slots: 1 (electronic warfare for mission support)
- Unit Capacity: 8-10 (assault team deployment)
- Cargo Requirements: Heavy weapon (size 6) + EW system (size 4) = 10/20 capacity
- Strategic Role: Precision strike with electronic support and troop insertion

#### Reconnaissance Craft
- Weapon Slots: 1 (precision sniper cannon for standoff capability)
- Addon Slots: 1 (advanced sensors for detection enhancement)
- Unit Capacity: 2 (pilot + observer/specialist)
- Cargo Requirements: Precision weapon (size 4) + sensors (size 3) = 7/8 capacity
- Strategic Role: Intelligence gathering with defensive capabilities

### Detection and Stealth Applications

#### Radar Coverage Systems
- Base Detection: 12-20 tile range with power affecting identification accuracy
- Sensor Integration: +25% radar range through advanced sensor addon installation
- Electronic Countermeasures: Active systems reducing detection probability by 40-60%
- Terrain Masking: Geographic features providing additional stealth modifiers

#### Stealth Characteristics
- Bomber Stealth: -20% to -30% detection reduction (larger signature)
- Fighter Stealth: 0% to +10% stealth (smaller, more maneuverable)
- Addon Enhancement: Stealth coatings reducing visibility by 50-70%
- Counter-Stealth: Enemy systems with anti-stealth capabilities

### Loadout Validation Examples

#### Valid Configuration
- Craft: Small Interceptor (Weapon Slots: 2, Addon Slots: 1, Cargo: 5)
- Loadout: Two Light Lasers (2 slots each, size 2) + Small Radar (1 slot, size 1)
- Usage: 2 weapon slots + 1 addon slot, 5/5 cargo capacity
- Result: Valid configuration for deployment

#### Invalid Configuration - Slot Overload
- Craft: Small Interceptor (Weapon Slots: 2, Addon Slots: 1)
- Attempted Loadout: Three weapons (requires 3 weapon slots)
- Result: Rejected - insufficient weapon slot availability

#### Invalid Configuration - Cargo Overload
- Craft: Small Interceptor (Cargo: 5)
- Attempted Loadout: Heavy cannon (size 10)
- Result: Rejected - item size exceeds cargo capacity

#### Transport Capacity Validation
- Craft: Medium Transport (Unit Capacity: 8)
- Embark Attempt: Two large units (4 slots each) + two standard units (1 slot each)
- Usage: 4 + 4 + 1 + 1 = 10 slots required
- Result: Rejected - exceeds unit capacity limits

## Related Wiki Pages

- [Classes.md](../crafts/Classes.md) - Craft class definitions and stat ranges.
- [Energy.md](../crafts/Energy.md) - Energy systems and weapon power.
- [Fuel & range.md](../crafts/Fuel%20%26%20range.md) - Fuel consumption and operational range.
- [Encumbrance.md](../crafts/Encumbrance.md) - Weight and capacity limitations.
- [Items.md](../crafts/Items.md) - Craft equipment and upgrades.
- [Inventory.md](../crafts/Inventory.md) - Craft inventory management.
- [Crafts.md](../crafts/Crafts.md) - Main craft systems overview.
- [Craft Operations.md](../geoscape/Craft%20Operations.md) - Geoscape craft deployment.

## References to Existing Games and Mechanics

- **XCOM Series**: Craft stats and performance characteristics
- **Civilization Series**: Unit stats and movement systems
- **Europa Universalis**: Naval unit stats and capabilities
- **Crusader Kings**: Army composition and unit stats
- **Hearts of Iron**: Fleet and air unit statistics
- **Victoria Series**: Naval and military unit capabilities
- **Stellaris**: Ship stats and fleet composition
- **Endless Space**: Fleet unit statistics and performance
- **Galactic Civilizations**: Ship stats and combat values
- **Total War Series**: Unit stats and army composition

