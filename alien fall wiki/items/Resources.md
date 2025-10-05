# Resources

## Table of Contents
- [Overview](#overview)
  - [High-level Design Principles](#high-level-design-principles)
- [Mechanics](#mechanics)
  - [Resource Types and Categories](#resource-types-and-categories)
    - [Resource Classification System](#resource-classification-system)
    - [Resource Tiers and Technology Gates](#resource-tiers-and-technology-gates)
  - [Storage and Capacity Management](#storage-and-capacity-management)
    - [Storage Capacity Limits](#storage-capacity-limits)
    - [Storage Utilization Tracking](#storage-utilization-tracking)
  - [Resource Acquisition Methods](#resource-acquisition-methods)
    - [Salvage Operations](#salvage-operations)
    - [Market and Supplier Acquisition](#market-and-supplier-acquisition)
    - [Manufacturing and Refinement](#manufacturing-and-refinement)
    - [Research and Special Acquisitions](#research-and-special-acquisitions)
  - [Resource States and Lifecycle](#resource-states-and-lifecycle)
    - [Resource State Management](#resource-state-management)
    - [Provenance Tracking](#provenance-tracking)
  - [Reservation and Consumption System](#reservation-and-consumption-system)
    - [Resource Reservation Process](#resource-reservation-process)
    - [Consumption Validation](#consumption-validation)
    - [Reservation Conflicts and Resolution](#reservation-conflicts-and-resolution)
  - [Overflow Policy Framework](#overflow-policy-framework)
    - [Overflow Handling Strategies](#overflow-handling-strategies)
    - [Policy Selection and Configuration](#policy-selection-and-configuration)
  - [Stack-Based Storage Logic](#stack-based-storage-logic)
    - [Stack Creation and Management](#stack-creation-and-management)
    - [Storage Optimization](#storage-optimization)
  - [Recipe-Based Conversion System](#recipe-based-conversion-system)
    - [Conversion Recipe Structure](#conversion-recipe-structure)
    - [Recipe Categories](#recipe-categories)
  - [Processing Time and Efficiency](#processing-time-and-efficiency)
    - [Conversion Duration](#conversion-duration)
    - [Efficiency Modifiers](#efficiency-modifiers)
  - [Craft Fuel Integration](#craft-fuel-integration)
    - [Fuel as Resources](#fuel-as-resources)
    - [Fuel Reservation and Consumption](#fuel-reservation-and-consumption)
    - [Journey Planning and Optimization](#journey-planning-and-optimization)
  - [Market Dynamics and Pricing](#market-dynamics-and-pricing)
    - [Dynamic Pricing System](#dynamic-pricing-system)
    - [Price History and Trends](#price-history-and-trends)
  - [Resource Scarcity Simulation](#resource-scarcity-simulation)
    - [Scarcity Event Generation](#scarcity-event-generation)
    - [Scarcity Impact Management](#scarcity-impact-management)
- [Examples](#examples)
  - [Resource Tiers and Examples](#resource-tiers-and-examples)
  - [Fuel Consumption Examples](#fuel-consumption-examples)
  - [Storage Management Examples](#storage-management-examples)
  - [Reservation System Examples](#reservation-system-examples)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Resources system forms the backbone of Alien Fall's economy and logistics, managing all material goods, energy sources, and strategic assets that drive base operations, manufacturing, and craft activities. This comprehensive resource management framework ensures deterministic accounting, prevents resource duplication, and creates meaningful scarcity that drives strategic decision-making. Resources are intentionally modular and fungible in design so that scarcity, logistics and supply lines become meaningful trade-offs. Designers should express resources as typed, stackable data items with clear acquisition rules, conversion recipes and visible sinks to avoid deadlocks.

### High-level Design Principles

- Deterministic Operations: All resource operations use seeded randomness for reproducible results
- Stack-Based Storage: Resources stored in discrete stacks with size limits and state tracking
- Reservation System: Resources can be reserved for future consumption, preventing double-allocation
- Conversion Recipes: Data-driven transformation of resources through facilities and research
- Fuel Integration: Shared resource pools between base storage and craft fuel systems
- Economic Scarcity: Dynamic pricing and availability based on supply/demand simulation
- Data-Driven Design: All resource attributes and recipes defined in external data for moddability

## Mechanics

### Resource Types and Categories

#### Resource Classification System
Resources are organized into hierarchical categories that determine their strategic value, acquisition methods, and usage patterns:

Construction Materials
- Basic resources for building and infrastructure
- Examples: Metal, concrete, structural alloys
- Acquisition: Salvage, market purchases, manufacturing
- Usage: Base construction, facility building, craft production

Energy Resources
- Fuel and power sources for craft and facilities
- Examples: Basic fuel, fusion cells, elerium
- Acquisition: Refining, market, alien salvage
- Usage: Craft propulsion, facility power, research operations

Strategic Assets
- Rare or alien-derived materials with special properties
- Examples: Alien alloys, quantum crystals, exotic compounds
- Acquisition: Alien salvage, advanced research, special missions
- Usage: Advanced manufacturing, elite equipment, breakthrough research

Manufactured Goods
- Finished products from conversion processes
- Examples: Weapons, armor, craft components
- Acquisition: Manufacturing facilities, assembly lines
- Usage: Equipment for units, craft upgrades, base defenses

#### Resource Tiers and Technology Gates
Resources are assigned technology tiers that control their availability and usage:

- Core Human: Basic resources available from game start
- Advanced Human: Require research breakthroughs and specialized facilities
- Alien Technology: Derived from alien artifacts and reverse-engineering
- Ultimate Human: Cutting-edge human technology requiring alien materials

### Storage and Capacity Management

#### Storage Capacity Limits
Each base maintains finite storage capacity measured in standardized slots:

- Slot-Based System: All resources occupy storage slots based on their size attribute
- Capacity Planning: Players must manage storage utilization and expansion
- Overflow Prevention: System prevents storage beyond capacity limits
- Expansion Requirements: Additional storage requires construction projects

#### Storage Utilization Tracking
Real-time monitoring of storage efficiency and bottlenecks:

- Utilization Percentage: Current usage vs total capacity
- Slot Distribution: How storage slots are allocated across resource types
- Bottleneck Identification: Resources approaching capacity limits
- Optimization Suggestions: Automated recommendations for storage management

### Resource Acquisition Methods

#### Salvage Operations
Resources recovered from crashed UFOs and mission sites:

- Crash Site Harvesting: Automated recovery from interception victories
- Mission Salvage: Manual collection during ground missions
- Quality Variation: Resource quantity and quality based on mission difficulty
- Contamination Risks: Some alien resources require special handling

#### Market and Supplier Acquisition
Economic purchasing through established supply chains:

- Market Prices: Dynamic pricing based on global supply and demand
- Supplier Contracts: Long-term agreements for reliable resource flow
- Transportation Delays: Time-based delivery mechanics
- Bulk Discounts: Quantity-based pricing incentives

#### Manufacturing and Refinement
Resources produced through base facilities and processes:

- Refinery Operations: Raw materials converted to usable resources
- Assembly Lines: Component manufacturing for complex items
- Quality Control: Production yields with success/failure probabilities
- Facility Maintenance: Production capacity affected by facility condition

#### Research and Special Acquisitions
Rare resources unlocked through scientific advancement:

- Research Rewards: Breakthrough discoveries yield new resource types
- Special Missions: Dedicated operations for rare material procurement
- Alien Technology: Reverse-engineered resources from captured equipment
- Diplomatic Trade: Interfaction resource exchanges

### Resource States and Lifecycle

#### Resource State Management
Resources exist in defined states throughout their lifecycle:

- Available: Ready for immediate use or reservation
- Reserved: Allocated for specific projects or operations
- Consumed: Used up in manufacturing or other processes
- Overflow: Excess quantities handled according to policy

#### Provenance Tracking
Complete audit trail for resource origins and usage:

- Source Attribution: Original acquisition method and context
- Transformation History: Conversion and refinement operations
- Consumption Records: Where and how resources were used
- Quality Degradation: Resource condition changes over time

### Reservation and Consumption System

#### Resource Reservation Process
Advanced allocation system preventing resource conflicts:

- Project-Based Reservations: Resources allocated to specific manufacturing projects
- Craft Fuel Reservations: Fuel set aside for planned missions
- Facility Operation Reserves: Resources dedicated to ongoing processes
- Priority Queuing: High-priority reservations override lower ones

#### Consumption Validation
Strict controls ensure reserved resources are properly utilized:

- Reservation Verification: Confirm allocation matches requirements
- Partial Consumption: Ability to use only portion of reserved resources
- Reservation Release: Return unused resources to available pool
- Consumption Auditing: Track actual vs planned resource usage

#### Reservation Conflicts and Resolution
Mechanisms for handling competing resource demands:

- Priority Arbitration: Higher-priority projects claim needed resources
- Reservation Queuing: Projects wait for resource availability
- Partial Allocation: Projects proceed with available resources
- Conflict Notification: Alert players to resource bottlenecks

### Overflow Policy Framework

#### Overflow Handling Strategies
Multiple approaches for managing excess resources:

- Auto-Sell Policy: Excess resources automatically sold to market
- Queue Policy: Excess held in queue until storage space available
- Return Policy: Excess returned to suppliers for refunds
- Discard Policy: Excess resources permanently lost

#### Policy Selection and Configuration
Flexible policy management based on resource type and situation:

- Resource-Specific Policies: Different handling for different materials
- Economic Thresholds: Automatic policy triggers based on market conditions
- Player Override: Manual intervention in overflow situations
- Policy Optimization: Automated suggestions for best handling strategy

### Stack-Based Storage Logic

#### Stack Creation and Management
Resources organized in discrete storage units:

- Stack Size Limits: Maximum quantity per storage stack
- Stack Merging: Combine partial stacks when possible
- Stack Splitting: Divide stacks for partial reservations
- Stack State Tracking: Individual stack status and history

#### Storage Optimization
Efficient use of limited storage capacity:

- Stack Consolidation: Merge compatible stacks to free slots
- Storage Defragmentation: Reorganize stacks for optimal space usage
- Priority Storage: Important resources stored in accessible locations
- Automated Organization: Background optimization processes

### Recipe-Based Conversion System

#### Conversion Recipe Structure
Data-driven transformation definitions:

- Input Requirements: Resources needed for conversion
- Output Products: Resources produced by conversion
- Conversion Ratios: Input-to-output quantity relationships
- Byproduct Generation: Secondary outputs from conversion processes

#### Recipe Categories
Different types of resource transformations:

- Refinement Recipes: Raw materials to refined products
- Alloy Recipes: Multiple materials combined into alloys
- Energy Conversion: Fuel types transformed for different uses
- Specialized Processing: Alien materials requiring unique facilities

### Processing Time and Efficiency

#### Conversion Duration
Time-based processing mechanics:

- Base Processing Time: Standard duration for conversion operations
- Facility Bonuses: Faster processing with upgraded facilities
- Staff Efficiency: Personnel skills affect processing speed
- Batch Processing: Multiple conversions processed simultaneously

#### Efficiency Modifiers
Factors affecting conversion yields:

- Quality Inputs: Higher-quality materials improve yields
- Facility Condition: Well-maintained facilities process more efficiently
- Operator Skill: Experienced personnel reduce waste
- Research Bonuses: Advanced techniques improve conversion ratios

### Craft Fuel Integration

#### Fuel as Resources
Craft fuel treated as standard campaign resources with special handling:

- Fuel Resource Types: Each craft class references specific fuel resource IDs
- Consumption Rates: Per-kilometer fuel usage defined on craft chassis data
- Stackable Fuel: Fuel items follow normal storage and overflow rules
- Deterministic Calculations: Seeded fuel consumption for reproducible outcomes

#### Fuel Reservation and Consumption
Pre-mission fuel allocation and usage tracking:

- Order-Time Reservation: Fuel deducted from base storage when movement orders accepted
- Range Validation: Maximum reachable distance calculated from available fuel
- Return Fuel Requirements: Fuel needed for round-trip journeys
- Provenance Logging: Complete audit trail for fuel operations

#### Journey Planning and Optimization
Strategic fuel management for missions:

- Route Calculation: Fuel requirements for planned flight paths
- Reserve Margins: Extra fuel for contingencies and emergencies
- Alternative Routes: Fuel-efficient path planning options
- Refueling Options: Forward base fuel availability considerations

### Market Dynamics and Pricing

#### Dynamic Pricing System
Market forces affecting resource costs:

- Supply and Demand: Basic economic principles drive pricing
- Global Events: World events affecting resource availability
- Faction Competition: Other organizations competing for resources
- Seasonal Variations: Time-based availability fluctuations

#### Price History and Trends
Long-term economic tracking:

- Price Tracking: Historical price data for analysis
- Trend Analysis: Identification of pricing patterns
- Market Predictions: Forecasting based on current trends
- Investment Opportunities: Profitable resource speculation

### Resource Scarcity Simulation

#### Scarcity Event Generation
Random events creating resource shortages:

- Supply Disruptions: Transportation or production problems
- Increased Demand: Sudden spikes in resource requirements
- Geopolitical Events: International incidents affecting trade
- Natural Disasters: Environmental factors impacting production

#### Scarcity Impact Management
Strategic responses to resource shortages:

- Alternative Sources: Finding substitute resources or suppliers
- Conservation Measures: Reducing resource consumption
- Stockpile Management: Building reserves during plentiful times
- Research Acceleration: Fast-tracking resource independence

## Examples

### Resource Tiers and Examples

| Tier | ID | Item | Role | Size (base slots) | Source | Notes |
| :--- | :--- | :--- | :--- | :---: | :--- | :--- |
| Core Human | metal | Metal | Construction | 1 | Market / Salvage | Basic building material. |
| Core Human | fuel_basic | Fuel | Energy (basic) | 1 | Market / Refinery | Used by low-tech crafts/facilities (consumed on use). |
| Advanced Human | tritanium | Tritanium | Construction (advanced) | 2 | Manufactured from Metal | Stronger structural alloy. |
| Advanced Human | fusion_cells | Fusion Cells | Energy (advanced) | 2 | Manufactured / Market | Advanced fuel for human tech. |
| Alien | alien_alloys | Alien Alloys | Construction (alien) | 3 | Salvaged from UFOs | High‑performance material; may require analysis. |
| Alien | elerium | Elerium‑115 | Energy (alien) | 3 | Salvaged from power cores | Rare; used in advanced weapons. |
| Alien | shards | Shards | Psionic / biotech component | 1 | Salvage / refinement | Used in psi research and biotech. |
| Hybrid | xeno_organics | Xeno‑Organics | Construction / biotech | 2 | Refinement / salvage | Hybrid biomaterial. |
| Hybrid | zrbite | Zrbite | Energy (hybrid) | 4 | Research / refinement | Late‑game, high‑density energy source. |
| Underwater Alien | aqua_plastic | Aqua‑Plastic | Construction (aquatic) | 2 | Underwater salvage / suppliers | World‑specific uses. |
| Ultimate Human | data_cores | Data Cores | Compute / AI resource | 5 | High‑level research reward | Rare, used for singularity tech. |
| Ultimate Human | antimatter | Antimatter | Exotic energy | 8 | Endgame research / quests | Extremely rare, special applications. |

### Fuel Consumption Examples

Basic Interceptor (Fuel Type: fuel_basic)
- Fuel Consumption: 1 unit per km
- Max Fuel Capacity: 100 units
- Max Range: 100 km (one-way)
- Return Range: 50 km (round-trip)

Advanced Fighter (Fuel Type: fusion_cells)
- Fuel Consumption: 0.5 units per km
- Max Fuel Capacity: 200 units
- Max Range: 400 km (one-way)
- Return Range: 200 km (round-trip)

### Storage Management Examples

Base Storage Capacity: 100 slots
- Current Usage: 85 slots (85% utilization)
- Metal Stacks: 3 stacks × 5 slots = 15 slots
- Fuel Stacks: 2 stacks × 10 slots = 20 slots
- Alien Alloys: 1 stack × 15 slots = 15 slots
- Available: 15 slots

Overflow Policy: Auto-sell
- Storage at 95% capacity
- New salvage arrives: +20 slots worth
- Excess 15 slots auto-sold to market
- Player receives 75% of market value

### Reservation System Examples

Manufacturing Project: Advanced Armor
- Required Resources: Tritanium (10), Fusion Cells (5)
- Reservation Time: Project start
- Project Duration: 7 days
- Resources held until completion or cancellation

Craft Mission: Interception
- Fuel Required: 25 units basic fuel
- Reservation: Order acceptance
- Consumption: Mission completion
- Return: Unused fuel if mission aborted

## Related Wiki Pages

- [Economy.md](../economy/Economy.md) - Economic resource management
- [Finance.md](../finance/Finance.md) - Resource pricing and market dynamics
- [Crafts.md](../crafts/Crafts.md) - Craft fuel and resource consumption
- [Basescape.md](../basescape/Basescape.md) - Base resource storage and management
- [Geoscape.md](../geoscape/Geoscape.md) - Resource acquisition and logistics
- [Research tree.md](../economy/Research%20tree.md) - Resource research and processing
- [Item Action Economy.md](../items/Item%20Action%20Economy.md) - Resource consumption in combat
- [AI.md](../ai/AI.md) - AI resource allocation and planning

## References to Existing Games and Mechanics

- **Civilization Series**: Strategic resource management and trading
- **Factorio**: Complex resource processing and logistics
- **XCOM Series**: Salvage collection and resource allocation
- **StarCraft Series**: Real-time resource gathering and economy
- **Warhammer 40k**: Strategic resource management in warfare
- **Total War Series**: Economic resource systems
- **Crusader Kings Series**: Resource management and feudal economics
- **Europa Universalis Series**: Trade routes and resource distribution
- **Stellaris**: Galactic resource systems and economy
- **RimWorld**: Survival resource management and crafting

