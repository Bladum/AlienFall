# Transfers

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Transfer Object Types](#transfer-object-types)
  - [Creation and Scheduling](#creation-and-scheduling)
  - [Purchase Delivery Transfers](#purchase-delivery-transfers)
  - [Transport Capacity and Validation](#transport-capacity-and-validation)
  - [Cost Calculation Framework](#cost-calculation-framework)
  - [Transit Time Management](#transit-time-management)
  - [Reservation and Resource Locking](#reservation-and-resource-locking)
  - [Partial Load and Splitting System](#partial-load-and-splitting-system)
  - [Transfer Execution and Lifecycle](#transfer-execution-and-lifecycle)
  - [Transfer Completion and Failure Handling](#transfer-completion-and-failure-handling)
  - [Cancellation and Refund System](#cancellation-and-refund-system)
  - [Determinism and Moddability](#determinism-and-moddability)
- [Examples](#examples)
  - [Mixed Payload Transfer Example](#mixed-payload-transfer-example)
  - [Market Purchase Delivery Example](#market-purchase-delivery-example)
  - [Partial Load Auto-Split Example](#partial-load-auto-split-example)
  - [Cancellation Handling Examples](#cancellation-handling-examples)
  - [Failure Scenario Examples](#failure-scenario-examples)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Transfers system establishes a deterministic logistics framework converting purchases and strategic movements into schedulable events with explicit capacity, transit time, and reservation semantics. Modeling crafts, units, and items as transfer payloads creates planning pressure while special transfer types provide predictable exceptions for player convenience. The system integrates with base capacities, marketplace deliveries, and world time mechanics to maintain reproducible outcomes across campaigns and extensive modding support through data-driven parameters and seeded randomization.

Transfers serve as the primary mechanism for moving resources, personnel, and equipment between bases, creating strategic depth through logistics management. By making transportation costs, times, and capacity constraints explicit, the system encourages thoughtful base placement, convoy management, and supply chain optimization.

## Mechanics

### Transfer Object Types

The system supports multiple payload categories with distinct handling rules:
- Craft Transfers: Entire craft objects moved between bases with size-based capacity requirements
- Unit Transfers: Soldiers and NPCs counted by Size stat interacting with base capacities
- Item Transfers: Stackable goods counted by per-item Volume or stack size
- Resource Transfers: Bulk materials with volume-based capacity consumption
- Purchase Deliveries: Special void-origin transfers creating items directly in destination inventory
- Emergency Transfers: Priority transfers with accelerated transit and cost penalties

### Creation and Scheduling

Transfers are created with comprehensive parameters:
- Core Parameters: Origin base (or "void"), destination base, payload entries, optional priority
- Market Integration: Market purchases automatically spawn void-origin transfers with cost exemptions
- Scheduling Logic: Transfers become visible, schedulable events in the strategic interface
- Priority System: Low, normal, high, and emergency priorities affect cost and processing order
- Validation Checks: Engine validates capacity, resources, and routing before transfer creation

### Purchase Delivery Transfers

Market purchases create specialized transfer events:
- Void Origin: Market purchases create transfers with origin="void" and no transport capacity consumption
- Configurable Delivery: Delivery time of 1-5 days per purchase item with data-driven overrides
- Direct Creation: Purchased entities created directly in destination base inventory upon arrival
- Capacity Bypass: Purchase transfers bypass normal capacity validation and overflow handling
- Cost Exemption: Market-origin transfers exempt from standard transfer costs and distance calculations

### Transport Capacity and Validation

Capacity management creates strategic transportation constraints:
- Size Statistics: Units and crafts expose Size stat; items expose Volume stat
- Transport Capacities: Transports declare capacity_units and capacity_volume limits
- Capacity Validation: Engine validates sum(Unit.Size) ≤ capacity_units and sum(Item.Volume) ≤ capacity_volume
- Automated Logistics: Transfers without dedicated transport become automated jobs consuming base resources
- Real-time Validation: Capacity checking performed when transport assigned to transfer

### Cost Calculation Framework

Costs reflect tile path distance, payload, and priority factors:
- Distance-Driven Costs: TransferCost = TilePathDistance × (UnitCostFactor × sum(Unit.Size) + ItemCostFactor × sum(Item.Volume) + BaseFixedCost)
- Data-Driven Parameters: UnitCostFactor, ItemCostFactor, BaseFixedCost, and distance multipliers configurable via TOML
- Market Exemption: Market-origin transfers exempt from TransferCost with fees applied at purchase time
- Priority Multipliers: Cost modifiers for low (0.8x), normal (1.0x), high (1.5x), emergency (2.0x) priorities
- Deterministic Calculation: All costs calculated deterministically for reproducible campaign outcomes

### Transit Time Management

Transit follows predictable tile path distance-based timing:
- Tile Path Timing: TransitDays = TilePathDistance × DaysPerTile + FixedOverheadDays
- Data-Driven Constants: DaysPerTile and FixedOverheadDays configurable through TOML files
- Payload Independence: Transit time driven by distance only, unaffected by payload size or weight
- Daily Progression: Transit time decremented on daily tick with progress tracking
- Market Overrides: Market-origin transfers may override TransitDays with purchase_item.delivery_time

### Reservation and Resource Locking

Resource management prevents conflicts and ensures reliability:
- Transport Reservation: Assigned transports reserved for transit period, unavailable for other orders
- Payload Reservation: Items and units reserved in origin base inventory at transfer start
- Capacity Pre-allocation: Destination capacity reserved to prevent overflow scenarios
- Resource Conflicts: Transfer creation fails if required resources unavailable at scheduled time
- Reservation Duration: Resources locked from departure until arrival or cancellation

### Partial Load and Splitting System

Oversized payloads are handled through intelligent splitting:
- Capacity Validation: Single transport capacity checked against full payload requirements
- Auto-Splitting: Player-configurable auto-split creating multiple legs for oversized payloads
- Separate Processing: Split legs generate independent transit timers, costs, and priority handling
- Aggregation Rules: Split transfers respect priority and ordering rules for convoy management
- Load Balancing: Engine distributes payload across multiple transports when available

### Transfer Execution and Lifecycle

Transfers progress through defined states with comprehensive tracking:
- Status Progression: Transfers progress through pending → active → completed states
- Daily Processing: World time system triggers daily transfer updates and progress advancement
- Progress Tracking: Percentage completion and remaining transit days visible to player
- Route Visualization: Current province and route progress displayed in strategic interface
- Event Integration: Transfer lifecycle triggers hooks for UI updates, automation, and modding

### Transfer Completion and Failure Handling

Arrival processing manages successful and failed deliveries:
- Arrival Processing: Payload moved into destination base storage and capacity upon completion
- Overflow Policies: Configurable handling for capacity exceeded (queue, return, auto-sell, etc.)
- Arrival Notifications: Transfer completion triggers UI alerts and automation hooks
- Failure Scenarios: Origin destruction or interception causes transfer failure with penalty handling
- Partial Success: Split transfers allow partial completion with remaining payload handling

### Cancellation and Refund System

Flexible cancellation supports changing strategic needs:
- Pre-Departure Cancellation: Configurable refund percentage of TransferCost before departure
- In-Transit Cancellation: Partial refunds based on progress and remaining transit time
- Resource Release: Cancellation releases reserved transports, payload, and destination capacity
- Penalty Application: Cancellation penalties applied based on transfer type and timing
- Policy Configuration: Refund percentages and penalty structures data-driven per transfer type

### Determinism and Moddability

The system ensures reproducible outcomes and extensive customization:
- Data-Driven Parameters: All numeric values (costs, times, capacities) configurable through YAML/TOML
- Seeded Randomization: Stochastic elements use campaign/world seed for reproducibility
- Scheduler Hooks: on_transfer_start, on_transfer_tick, on_transfer_arrival, on_transfer_cancel exposed for mods
- Test Case Support: Deterministic scenarios for validating splitting, cancellation, and failure modes
- Configuration Flexibility: Extensive parameters support diverse gameplay balance approaches

## Examples

### Mixed Payload Transfer Example
- Scenario: Transfer 3 soldiers (Size=1 each) and 200 Alien Alloy units (Volume=1 each) from Base A to Base B, tile path distance=12 tiles
- Cost Calculation: Cost = 12 × (10 × 3 + 2 × 200) + 50 = 12 × (30 + 400) + 50 = 5160 + 50 = 5210 credits
- Transit Time: TransitDays = 12 × DaysPerTile + FixedOverheadDays (configurable values)
- Capacity Requirements: 3 unit capacity + 200 volume capacity needed
- Reservation Impact: Transport unavailable for transit period, items locked in origin inventory

### Market Purchase Delivery Example
- Scenario: Purchase "Advanced Radar" with delivery_time=7 days from supplier
- Transfer Creation: Void→Base transfer spawned with cost=0, TransitDays=7 (market override)
- Arrival Mechanics: Item created directly in base inventory after 7 daily ticks
- Capacity Bypass: No transport capacity consumed, destination capacity validation skipped
- Reservation State: Item considered reserved on void origin until arrival

### Partial Load Auto-Split Example
- Scenario: Transport capacity=100 volume, payload=250 volume with auto-split enabled
- Split Creation: Engine creates three legs (100, 100, 50 volume) with separate transit timers
- Cost Aggregation: Total cost calculated as sum of individual leg costs
- Progress Tracking: Each leg tracked independently with separate arrival times
- Priority Handling: Split legs respect original transfer priority for scheduling

### Cancellation Handling Examples
- Pre-Departure: Cancel before departure returns 80% refund (configurable percentage)
- Mid-Transit: Cancel after 3 days of 7-day journey returns 40% refund (progress-based)
- Resource Release: Cancellation immediately releases transport and payload reservations
- Penalty Application: Emergency priority transfers incur higher cancellation penalties
- Policy Variation: Different transfer types have unique refund and penalty structures

### Failure Scenario Examples
- Origin Destruction: Base destruction during transit causes automatic failure, no refund
- Capacity Overflow: Arrival at full base triggers overflow policy (queue for 3 days, then auto-sell)
- Transport Loss: Assigned craft destruction causes transfer cancellation with partial refund
- Interception Risk: Covert transfers have configurable failure chance with seeded randomization
- Recovery Options: Failed transfers may offer recovery missions or replacement procurement

## Related Wiki Pages

- [Economy.md](../economy/Economy.md) - Core economic system and resource management.
- [Black market.md](../economy/Black%20market.md) - Illegal and covert transfer operations.
- [Suppliers.md](../economy/Suppliers.md) - Supply chain and procurement systems.
- [Research tree.md](../economy/Research%20tree.md) - Technology and resource allocation.
- [Finance.md](../finance/Finance.md) - Financial transactions and transfers.
- [Geoscape.md](../geoscape/Geoscape.md) - Global logistics and inter-base transfers.
- [Basescape.md](../basescape/Basescape.md) - Base-level resource distribution.
- [Units.md](../units/Units.md) - Personnel and equipment transfers.
- [Crafts.md](../crafts/Crafts.md) - Vehicle and aircraft transfers.
- [Items.md](../items/Items.md) - Equipment and inventory transfers.

## References to Existing Games and Mechanics

- **X-COM Series**: Alien Alloys and Elerium resource transfers between bases and missions
- **Civilization Series**: Trade routes and resource exchange between cities and civilizations
- **Fire Emblem Series**: Item and unit transfers between chapters and bases
- **Final Fantasy Tactics**: Inventory management and item transfers in tactical combat
- **Advance Wars**: Supply lines and resource transfers between units and bases
- **Total War Series**: Logistics and supply chain management for armies
- **Crusader Kings**: Trade agreements and resource transfers between realms
- **Europa Universalis**: Colonial trade and resource transfers across empires
- **Stellaris**: Strategic resource transfers between colonies and fleets
- **Homeworld Series**: Fleet logistics and resource transfers in space combat

