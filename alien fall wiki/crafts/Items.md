# Craft Items

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Item Definition Framework](#item-definition-framework)
  - [Mounting and Installation Systems](#mounting-and-installation-systems)
  - [Usage and Activation Mechanics](#usage-and-activation-mechanics)
  - [Equipment Categories and Functions](#equipment-categories-and-functions)
  - [Resource Management Integration](#resource-management-integration)
- [Examples](#examples)
  - [Weapon System Examples](#weapon-system-examples)
    - [Plasma Cannon](#plasma-cannon)
    - [Missile Launcher](#missile-launcher)
    - [Railgun](#railgun)
    - [Laser Array](#laser-array)
    - [Point Defense Turret](#point-defense-turret)
  - [Equipment Module Examples](#equipment-module-examples)
    - [Advanced Sensors](#advanced-sensors)
    - [Electronic Countermeasures](#electronic-countermeasures)
    - [Cargo Expander](#cargo-expander)
    - [Shield Generator](#shield-generator)
    - [Targeting Computer](#targeting-computer)
  - [Compatibility and Restriction Examples](#compatibility-and-restriction-examples)
    - [Fighter-Only Weapons](#fighter-only-weapons)
    - [Bomber Armament](#bomber-armament)
    - [Exclusive Systems](#exclusive-systems)
    - [Dependency Requirements](#dependency-requirements)
    - [Size Limitations](#size-limitations)
  - [Resource Consumption Scenarios](#resource-consumption-scenarios)
    - [Short Interception Mission](#short-interception-mission)
    - [Extended Patrol Mission](#extended-patrol-mission)
    - [Heavy Engagement Scenario](#heavy-engagement-scenario)
    - [Electronic Warfare Operation](#electronic-warfare-operation)
  - [Strategic Equipment Choices](#strategic-equipment-choices)
    - [Interception Specialist Loadout](#interception-specialist-loadout)
    - [Ground Attack Platform Loadout](#ground-attack-platform-loadout)
    - [Reconnaissance Craft Loadout](#reconnaissance-craft-loadout)
    - [Heavy Bomber Loadout](#heavy-bomber-loadout)
    - [Transport Escort Loadout](#transport-escort-loadout)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The craft items system establishes comprehensive equipment management for craft platforms, encompassing weapons, specialized equipment, and consumable resources that can be mounted, utilized, and maintained throughout campaign operations. The framework handles item compatibility validation, mounting restrictions, usage mechanics, and resource consumption with deterministic outcomes and complete provenance tracking for reproducible gameplay. Items are categorized by function, with strict compatibility rules ensuring balanced loadouts while providing meaningful customization choices that impact craft performance and mission capabilities.

The system supports extensive modding through data-driven item definitions and compatibility rules, enabling players to specialize craft for different operational roles while maintaining strategic depth and economic considerations.

## Mechanics

### Item Definition Framework

Each craft item has a comprehensive definition specifying capabilities and constraints:

- Category Classification: Weapons, equipment, sensors, countermeasures, and consumables
- Type Specifications: Beam weapons, projectile systems, electronic warfare, cargo expanders
- Size Classifications: Small, medium, large items affecting slot requirements and capacity
- Weight Parameters: Mass values impacting craft performance and fuel efficiency
- Power Consumption: Energy requirements affecting craft operational capacity
- Compatibility Rules: Craft type, size, and specialization restrictions

### Mounting and Installation Systems

Equipment installation follows strict validation and compatibility rules:

- Slot-Based Installation: Dedicated hardpoints for weapons, addons, and equipment
- Compatibility Validation: Craft type, size, and capability requirement checking
- Resource Allocation: Power consumption and weight limit enforcement
- Exclusive Restrictions: Items preventing installation of conflicting equipment
- Dependency Requirements: Items requiring presence of other systems or components
- Loadout Persistence: Equipment configurations maintained across missions

### Usage and Activation Mechanics

Items integrate with combat systems and resource management:

- Combat Integration: Weapon firing, sensor activation, and countermeasure deployment
- Resource Consumption: Ammunition depletion, energy expenditure, and cooldown periods
- Effect Application: Damage dealing, detection enhancement, and defensive bonuses
- Durability Tracking: Item degradation and maintenance requirements
- Activation Conditions: Situational triggers for automatic or manual system engagement
- Performance Impact: Stat modifications and capability enhancements during operation

### Equipment Categories and Functions

Items are organized by functional roles with distinct capabilities:

- Weapon Systems: Primary armament for engaging aerial and ground targets
- Sensor Equipment: Detection enhancement and targeting improvement systems
- Defensive Systems: Countermeasures and protection against enemy capabilities
- Utility Modules: Cargo expansion, crew support, and mission-specific enhancements
- Electronic Warfare: Jamming, deception, and communication disruption capabilities
- Maintenance Tools: Repair systems and damage control equipment

### Resource Management Integration

Items interact with campaign resource systems and economic considerations:

- Ammunition Tracking: Limited-use weapons with resupply requirements
- Energy Allocation: Power distribution across multiple active systems
- Maintenance Scheduling: Regular servicing and replacement cycles
- Cost Accounting: Acquisition, installation, and operational expense tracking
- Supply Chain Dependencies: Manufacturing and procurement requirement systems
- Strategic Scarcity: Limited availability creating meaningful equipment choices

## Examples

### Weapon System Examples

#### Plasma Cannon
- Category: Medium beam weapon, Size: Medium
- Damage: 45 energy damage, Range: 8 units, Accuracy: 75%
- Resource Cost: 25 energy per shot, Cooldown: 2 turns
- Mounting: Weapon slot, fighter/interceptor compatible
- Effects: High damage output for dogfighting

#### Missile Launcher
- Category: Large projectile system, Size: Large
- Damage: 80 explosive damage, Range: 12 units, Accuracy: 60%
- Resource Cost: 40 energy per shot, Ammunition: 4-shot capacity
- Mounting: Weapon slot, bomber compatible
- Effects: Area damage with limited ammunition

#### Railgun
- Category: Heavy kinetic weapon, Size: Large
- Damage: 65 kinetic damage, Range: 10 units, Accuracy: 85%
- Resource Cost: 35 energy per shot, Cooldown: 3 turns
- Mounting: Weapon slot, capital ship compatible
- Effects: High accuracy, armor-piercing capability

#### Laser Array
- Category: Area beam system, Size: Medium
- Damage: 35 energy damage/splash, Range: 6 units, Accuracy: 70%
- Resource Cost: 20 energy per shot, Ammunition: Unlimited
- Mounting: Weapon slot, universal compatibility
- Effects: Area denial with sustained fire capability

#### Point Defense Turret
- Category: Small defensive weapon, Size: Small
- Damage: 25 defensive damage, Range: 4 units, Accuracy: 90%
- Resource Cost: 15 energy per shot, Cooldown: Rapid fire
- Mounting: Weapon slot, universal compatibility
- Effects: Anti-missile and close-range defense

### Equipment Module Examples

#### Advanced Sensors
- Category: Sensor equipment, Size: Medium
- Effects: Detection range +3 tiles, targeting accuracy +15%
- Resource Cost: 10 energy per turn (passive)
- Mounting: Addon slot, universal compatibility
- Function: Enhanced situational awareness

#### Electronic Countermeasures
- Category: Electronic warfare, Size: Medium
- Effects: 40% reduction in enemy hit chance, jamming radius 5 tiles
- Resource Cost: 25 energy per turn
- Mounting: Addon slot, electronic warfare compatible
- Function: Defensive jamming and deception

#### Cargo Expander
- Category: Utility module, Size: Large
- Effects: +50% cargo capacity, +100kg weight limit
- Resource Cost: Negligible power draw
- Mounting: Addon slot, transport compatible
- Function: Increased carrying capacity

#### Shield Generator
- Category: Defensive system, Size: Large
- Effects: 30% damage reduction, 50 energy capacity
- Resource Cost: Recharges 10 energy per turn
- Mounting: Addon slot, capital ship compatible
- Function: Active damage absorption

#### Targeting Computer
- Category: Sensor equipment, Size: Small
- Effects: +20% weapon accuracy, +2 weapon range
- Resource Cost: 15 energy per turn
- Mounting: Addon slot, requires advanced sensors
- Function: Enhanced weapon effectiveness

### Compatibility and Restriction Examples

#### Fighter-Only Weapons
- Restriction: Plasma cannons limited to small/medium fighter craft types
- Reasoning: Size and power requirements incompatible with larger craft
- Strategic Impact: Creates specialized roles for different craft classes

#### Bomber Armament
- Restriction: Heavy missile launchers require large craft with weapon slot capacity
- Reasoning: Size and weight limitations prevent installation on smaller craft
- Strategic Impact: Forces specialization between fighter and bomber roles

#### Exclusive Systems
- Restriction: Electronic warfare suite incompatible with advanced sensor packages
- Reasoning: Conflicting operational requirements and power consumption
- Strategic Impact: Requires choice between detection enhancement and jamming

#### Dependency Requirements
- Restriction: Targeting computer requires advanced sensors for full functionality
- Reasoning: Advanced targeting depends on enhanced detection capabilities
- Strategic Impact: Creates equipment upgrade paths and dependencies

#### Size Limitations
- Restriction: Large weapons prohibited on small craft due to weight and power constraints
- Reasoning: Structural integrity and power generation limitations
- Strategic Impact: Enforces realistic craft specialization

### Resource Consumption Scenarios

#### Short Interception Mission
- Usage: 2-3 weapon shots, 50-75 energy expenditure
- Ammunition: Minimal depletion for energy weapons
- Strategic Impact: Quick engagements with limited resource commitment

#### Extended Patrol Mission
- Usage: 5-8 weapon activations, 100-150 energy consumption
- Ammunition: Potential resupply needs for projectile weapons
- Strategic Impact: Sustained operations requiring resource management

#### Heavy Engagement Scenario
- Usage: 10+ weapon discharges, 200+ energy drain
- Ammunition: Significant depletion requiring resupply planning
- Strategic Impact: High-intensity combat with resource scarcity risks

#### Electronic Warfare Operation
- Usage: Continuous system operation, 50-100 energy per turn
- Ammunition: No ammunition requirements for electronic systems
- Strategic Impact: Sustained capability with energy management focus

### Strategic Equipment Choices

#### Interception Specialist Loadout
- Weapons: Dual plasma cannons, targeting computer
- Equipment: Electronic countermeasures
- Strategic Role: Close-range dogfighting with defensive capabilities
- Resource Trade-offs: High energy consumption for superior combat performance

#### Ground Attack Platform Loadout
- Weapons: Missile launcher, advanced sensors
- Equipment: Cargo expander for troop deployment
- Strategic Role: Precision strike with ground support capability
- Resource Trade-offs: Heavy ammunition dependency with enhanced detection

#### Reconnaissance Craft Loadout
- Weapons: Minimal armament, point defense turret
- Equipment: Advanced sensors, electronic countermeasures
- Strategic Role: Detection and surveillance with self-defense
- Resource Trade-offs: Limited offensive capability for enhanced awareness

#### Heavy Bomber Loadout
- Weapons: Large missile systems, railgun
- Equipment: Shield generator, point defense turrets
- Strategic Role: Heavy assault with defensive protection
- Resource Trade-offs: High resource consumption for overwhelming firepower

#### Transport Escort Loadout
- Weapons: Point defense turrets, light missile launcher
- Equipment: Electronic warfare support, cargo expander
- Strategic Role: Convoy protection with transport capability
- Resource Trade-offs: Balanced between defense and utility functions

## Related Wiki Pages

- [Stats.md](Stats.md) - Item effects on craft performance
- [Energy.md](Energy.md) - Power consumption of items
- [Encumbrance.md](Encumbrance.md) - Weight and capacity limitations
- [Inventory.md](Inventory.md) - Item storage and management
- [Weapon modes.md](../items/Weapon%20modes.md) - Weapon system mechanics
- [Unit items.md](../items/Unit%20items.md) - Unit equipment comparison
- [Crafts.md](../crafts/Crafts.md) - Main craft systems overview
- [Manufacturing.md](../economy/Manufacturing.md) - Item production systems

## References to Existing Games and Mechanics

- **XCOM Series**: Craft equipment and weapon systems
- **Civilization Series**: Unit equipment and upgrades
- **Europa Universalis**: Naval equipment and ship modifications
- **Crusader Kings**: Equipment and weapon systems
- **Hearts of Iron**: Naval and air equipment systems
- **Victoria Series**: Military equipment and technology
- **Stellaris**: Ship components and equipment
- **Endless Space**: Fleet equipment and upgrades
- **Galactic Civilizations**: Ship equipment and modules
- **Total War Series**: Unit equipment and weapon choices

