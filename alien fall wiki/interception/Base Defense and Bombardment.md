# Base Defense and Bombardment

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Facility Integration](#facility-integration)
  - [Bombardment Scenarios](#bombardment-scenarios)
  - [Defense Architecture](#defense-architecture)
  - [Interception Integration](#interception-integration)
  - [Damage and Destruction](#damage-and-destruction)
  - [Repair and Recovery](#repair-and-recovery)
- [Examples](#examples)
  - [Facility Types](#facility-types)
  - [Bombardment Engagement](#bombardment-engagement)
  - [Defense Scenarios](#defense-scenarios)
  - [Repair Operations](#repair-operations)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

Base Defense and Bombardment integrates static base facilities into the Interception Scape as "weapons on base" with AP and energy costs, targeting restrictions, and damage mechanics. It handles defensive engagements where player bases are attacked by UFOs, creating tactical interception scenarios that protect critical infrastructure. Bases have health pools and cannot be destroyed by bombardment alone - land battles are required for base destruction.

## Mechanics

### Facility Integration
- Weapon Conversion: Base facilities function as interception weapons with AP and energy costs
- Base Health: Facilities contribute to base health pool when active during defense
- Targeting System: Facilities target appropriate zones (air, land, underwater) based on type
- Damage Application: Facility-specific damage and effects using weapon mechanics
- Resource Consumption: AP and energy costs for facility activation

### Bombardment Scenarios
- UFO Aggression: UFOs bombard player bases using ground-attack weapons
- Defensive Response: Base facilities counter-attack as weapons on the interception grid
- Damage Mitigation: Base health reduction but no destruction without land battle
- Strategic Positioning: Base location affects interception dynamics and biome considerations

### Defense Architecture
- Facility Types: Radar, missile, laser, plasma defenses with different targeting profiles
- Range Limitations: 10-point distance system with travel time calculations
- Accuracy Systems: Hit probability modified by facility type and base conditions
- Damage Scaling: Facility power and effectiveness with cooldown systems

### Interception Integration
- Unified Resolution: Facilities participate in interception screen as 1-slot base entities
- AP Management: Facilities consume from base's AP pool (separate from craft AP)
- Energy Pools: Base energy pool combining facility bonuses and regeneration
- Turn Sequencing: Facility actions in interception turns with 4 AP per turn
- Base Destruction: When health reaches 0, defenses are bypassed, requiring land battle for destruction

### Damage and Destruction
- Facility Health: Individual facility hit points
- Destruction Effects: Loss of capabilities and repair requirements
- Economic Impact: Repair costs and downtime penalties
- Strategic Consequences: Base vulnerability and mission risks

### Repair and Recovery
- Repair Mechanics: Time and resource-based restoration
- Priority Systems: Critical facility repair prioritization
- Cost Calculations: Economic impact of facility damage
- Downtime Management: Operational capacity during repairs

## Examples

### Facility Types
- Radar Facility: Detection enhancement, no direct damage
- Missile Battery: Long-range bombardment defense, 200 damage
- Laser Turret: Medium-range precision defense, 150 damage
- Plasma Cannon: Short-range high-damage defense, 300 damage

### Bombardment Engagement
- UFO Approach: UFO enters base range, begins bombardment
- Facility Response: Missile battery fires, consumes 50 energy
- Damage Exchange: UFO takes 200 damage, facility takes 50 damage
- Escalation: Multiple facilities engage simultaneously

### Defense Scenarios
- Single Facility: Laser turret defends against small UFO
- Multi-Facility: Combined missile and plasma defense against large UFO
- Overwhelmed Defense: Facilities destroyed by superior UFO firepower

### Repair Operations
- Immediate Repair: Critical facility restored in 1 day, 1000 credits
- Extended Downtime: Major damage requires 7 days, 5000 credits
- Economic Impact: Lost production during repair period

## Related Wiki Pages

- [Interception Core Mechanics.md](../interception/Interception%20Core%20Mechanics.md) - Core interception systems
- [Air Battle.md](../interception/Air%20Battle.md) - Air-to-air combat mechanics
- [Mission Detection and Assignment.md](../interception/Mission%20Detection%20and%20Assignment.md) - Mission generation
- [Overview.md](../interception/Overview.md) - Interception overview
- [Basescape.md](../basescape/Basescape.md) - Base facility management
- [Facilities.md](../basescape/Facilities.md) - Base facility types
- [Damage calculations.md](../items/Damage%20calculations.md) - Damage mechanics
- [Research tree.md](../economy/Research%20tree.md) - Defense technology research

## References to Existing Games and Mechanics

- **XCOM Series**: Base defense and facility damage systems
- **Command & Conquer**: Base defense turrets and structures
- **StarCraft**: Base defense and building destruction
- **Warcraft III**: Tower defense and structure damage
- **Total Annihilation**: Base defense and bombardment mechanics
- **Supreme Commander**: Strategic base defense systems
- **Homeworld**: Capital ship and base defense
- **Battlestar Galactica**: Colonial defense systems
- **Mass Effect**: Planetary defense and bombardment
- **Endless Space**: Strategic base defense mechanics

