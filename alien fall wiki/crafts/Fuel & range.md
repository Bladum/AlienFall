# Craft Fuel & Range

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Fuel Consumption System](#fuel-consumption-system)
  - [Speed and Tempo Limits](#speed-and-tempo-limits)
  - [Mission Execution Cycle](#mission-execution-cycle)
  - [Base Fuel Management](#base-fuel-management)
  - [Operational Readiness](#operational-readiness)
- [Examples](#examples)
  - [Mission Execution Examples](#mission-execution-examples)
    - [Basic Interception Mission](#basic-interception-mission)
    - [Long-Range Reconnaissance](#long-range-reconnaissance)
    - [Multi-Mission Sortie](#multi-mission-sortie)
  - [Fuel Limitation Examples](#fuel-limitation-examples)
    - [Fuel Shortage Scenario](#fuel-shortage-scenario)
    - [Progressive Depletion](#progressive-depletion)
    - [Fuel Type Specificity](#fuel-type-specificity)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The craft fuel and range system implements logistical constraints that shape strategic decision-making around base placement, mission assignment, and resource management. Each craft consumes specific fuel resources from its home base for operations, with operational range and speed limits determining deployment options. The system creates meaningful trade-offs between endurance, payload capacity, and operational tempo while maintaining deterministic, data-driven mechanics.

Fuel consumption occurs per mission with immediate deduction from base stockpiles, while range limits create geographic constraints on operations. Speed limits prevent unlimited sorties, representing crew endurance and maintenance requirements. The system supports extensive modding while ensuring reproducible outcomes through seeded calculations.

## Mechanics

### Fuel Consumption System

Each craft consumes fuel resources for mission operations from base stockpiles:

- **Always Ready**: Crafts require no refueling or preparation time between missions
- **Pay to Fly**: Fuel consumed per kilometer of mission distance from base stocks
- **Immediate Deduction**: Fuel removed from home base stock before mission launch
- **No Partial Consumption**: All-or-nothing fuel deduction with validation
- **Resource Scarcity**: Limited base stockpiles constrain operational tempo

### Speed and Tempo Limits

Craft sortie capacity per turn based on speed rating:

- **Missions Per Turn**: Speed rating determines maximum sorties (e.g., speed 3 = 3 missions per turn)
- **Turn Reset**: Speed limit resets each game turn
- **Fuel Independent**: Sortie limits separate from fuel availability
- **No Crew Fatigue**: Operational tempo limited by craft capabilities only
- **Upgrade Path**: Speed increases through craft improvements and veterancy

### Mission Execution Cycle

Missions follow streamlined operational validation:

- **Pre-Launch Validation**: Check fuel availability and speed limits
- **Fuel Deduction**: Required fuel removed from base stock immediately
- **Mission Performance**: Craft executes assigned mission objectives
- **Automatic Return**: Craft returns to home base same turn
- **Ready for Next Mission**: If speed allows additional sorties, craft can be reassigned immediately

### Base Fuel Management

Fuel resources managed at base level with allocation constraints:

- **Stockpile Limits**: Each base has finite fuel storage capacity
- **Consumption Tracking**: Fuel deducted per mission with historical logging
- **Resupply Requirements**: Fuel must be transported, produced, or purchased
- **Shared Resources**: Multiple craft draw from same base fuel stockpiles
- **Strategic Allocation**: Fuel distribution decisions across multiple bases

### Operational Readiness

Crafts maintain constant mission readiness:

- **No Refueling**: Crafts don't require refueling between missions
- **No Rearming**: Energy pool system handles weapon costs
- **Speed-Based Tempo**: Multiple missions possible if speed rating allows
- **Damage-Based Repairs**: Only damaged crafts require repair time
- **Instant Deployment**: Ready crafts can be assigned immediately

## Examples

### Mission Execution Examples

#### Basic Interception Mission
- Craft: Light Fighter (Speed: 2 missions/turn, Fuel: Elerium @ 0.5 units/km)
- Target: Enemy UFO over Spain (1200km from UK base)
- Fuel Required: 1200km × 0.5 = 600 units elerium
- Base Stock: 800 units elerium available
- Result: Mission launches immediately, 600 units consumed, craft returns ready
- Remaining Operations: 1 mission remaining this turn, can be assigned immediately

#### Long-Range Reconnaissance
- Craft: Heavy Recon (Speed: 1 mission/turn, Fuel: Advanced Cells @ 0.3 units/km)
- Target: Distant province (2800km from base)
- Fuel Required: 2800km × 0.3 = 840 units advanced cells
- Base Stock: 1000 units available
- Result: Mission successful, 840 units consumed, craft ready for next turn
- Turn Capacity: Mission limit reached, no further operations this turn

#### Multi-Mission Sortie
- Craft: Medium Fighter (Speed: 3 missions/turn, Fuel: Standard Fuel @ 0.4 units/km)
- Mission 1: 800km target, 320 units required
- Mission 2: 1500km target, 600 units required
- Mission 3: 600km target, 240 units required
- Total Fuel: 1160 units required
- Base Stock: 1400 units available
- Result: All three missions executed in same turn, 1160 units consumed, craft ready

### Fuel Limitation Examples

#### Fuel Shortage Scenario
- Craft: Bomber (Fuel: 0.6 units/km, Speed: 2 missions/turn)
- Available Fuel: 450 units at base
- Mission Requirements: Each mission costs 300 units minimum
- Result: Only 1 mission possible (450 ÷ 300 = 1.5, rounds down)
- Limiting Factor: Fuel availability constrains operational tempo

#### Progressive Depletion
- Base Fuel: 1200 units elerium
- Craft A: Consumes 400 units per mission (3 missions = 1200 units)
- Craft B: Consumes 300 units per mission (but only 2 missions available)
- Result: Craft A exhausts fuel supply, Craft B cannot operate
- Strategic Choice: Allocate fuel between multiple craft

#### Fuel Type Specificity
- Base Stock: 500 elerium, 800 standard fuel
- Craft A: Requires elerium (300 units/mission)
- Craft B: Requires standard fuel (250 units/mission)
- Result: Craft A limited to 1 mission, Craft B can do 3 missions
- Resource Management: Different fuel types create allocation decisions

## Related Wiki Pages

- [Craft Stats.md](../crafts/Craft%20Stats.md) - Fuel consumption rates and craft capabilities.
- [Craft Items.md](../crafts/Craft%20Items.md) - Fuel types and resource specifications.
- [Craft Operations.md](../geoscape/Craft%20Operations.md) - Mission execution and deployment mechanics.
- [Base Facilities.md](../basescape/Facilities.md) - Fuel storage and base infrastructure.
- [Manufacturing.md](../economy/Manufacturing.md) - Fuel production and resource creation.
- [Suppliers.md](../economy/Suppliers.md) - Fuel procurement and supply chains.
- [Geoscape.md](../geoscape/Geoscape.md) - World map navigation and mission planning.
- [Interception.md](../interception/Overview.md) - Mission assignment and operational constraints.
- [Finance.md](../finance/Finance.md) - Fuel costs and budgetary impacts.
- [Technical Architecture.md](../architecture.md) - System integration and data structures.

## References to Existing Games and Mechanics

- **XCOM Series**: Craft fuel consumption and range limitations for strategic deployment
- **Civilization**: Movement points and resource costs for unit operations
- **Master of Orion**: Ship range and fuel requirements for interstellar travel
- **Star Control**: Fuel consumption mechanics and range-limited exploration
- **Homeworld**: Fleet logistics, fuel management, and operational range constraints
- **Starfleet Command**: Ship endurance and fuel consumption in tactical combat
- **Wing Commander**: Fighter range limitations and mission planning constraints
- **Freespace**: Ship fuel systems and afterburner consumption mechanics
- **Elite**: Trading economics and range limitations for space travel
- **X3: Reunion**: Space flight physics and fuel management systems

