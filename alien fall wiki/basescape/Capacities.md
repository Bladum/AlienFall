# Capacities

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Capacity Type Framework](#capacity-type-framework)
  - [Aggregation and Precedence](#aggregation-and-precedence)
  - [Allocation and Consumption Models](#allocation-and-consumption-models)
  - [Overflow Policy System](#overflow-policy-system)
  - [Throughput and Time-Based Systems](#throughput-and-time-based-systems)
  - [Deterministic Framework](#deterministic-framework)
- [Examples](#examples)
  - [Manufacturing Capacity Management](#manufacturing-capacity-management)
  - [Storage Capacity and Overflow](#storage-capacity-and-overflow)
  - [Prisoner Capacity System](#prisoner-capacity-system)
  - [Hangar Slot Allocation](#hangar-slot-allocation)
  - [Research Throughput System](#research-throughput-system)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Capacities system provides a unified, data-driven framework for managing all base resource constraints and limitations in Alien Fall. This abstraction transforms diverse bottlenecks—such as storage space, manufacturing throughput, and facility slots—into named capacity keys with deterministic allocation rules. The system makes resource limitations explicit and actionable, enabling strategic trade-offs between physical footprint, operational throughput, and service availability while supporting extensive modding through configurable overflow policies and allocation behaviors.

Capacities encompass static slots for persistent objects, volume measurements for stackable storage, and throughput rates for time-based consumption. The framework ensures reproducible outcomes through seeded randomization and provides comprehensive provenance tracking for all capacity contributions and allocations.

## Mechanics

### Capacity Type Framework
The system supports multiple capacity types to handle different resource constraints:
- Static Slots: Integer counts for persistent object allocation, such as hangar berths or prisoner cells
- Volume/Space: Stackable storage capacity with organization rules for items and resources
- Throughput: Flow-rate values measuring consumption over time, such as man-hours per day or research points
- Service Tags: Boolean capabilities enabling specific features, distinct from numeric capacities
- Extensible Design: Open framework allowing custom capacity types without code modifications

### Aggregation and Precedence
Capacity calculations follow deterministic rules for consistent behavior:
- Base Calculation: Total capacity equals the sum of all online facility contributions
- Modifier Resolution: Deterministic stacking order from base defaults through temporary buffs
- Facility Dependencies: Capacities only contributed by operational facilities
- Real-Time Updates: Automatic recalculation when facility status changes
- Provenance Tracking: Complete audit trail of all contributing factors for debugging and balancing

### Allocation and Consumption Models
Resource management employs structured allocation approaches:
- Persistent Consumption: Long-term capacity reservation for ongoing operations
- Time-Based Consumption: Throughput allocation distributed over project duration
- Authoritative Management: Base-level control with subsystem capacity requests
- Deterministic Granting: Clear rules for accepting or rejecting allocation requests
- Reservation System: Temporary holds preventing over-allocation during planning

### Overflow Policy System
Configurable responses handle capacity exceedance scenarios:
- Block Action: Complete prevention of operations exceeding capacity limits
- Queue System: Priority-based waiting lists for excess requests
- Auto-Sell: Automatic liquidation of excess resources at market rates
- Auto-Transfer: Redistribution of excess to other bases or facilities
- Discard: Removal of excess with configurable penalties
- Data-Driven Policies: Per-capacity-type overflow behavior configuration

### Throughput and Time-Based Systems
Time-dependent capacities support complex scheduling:
- Rate-Based Consumption: Projects consuming capacity units per time period
- Scheduling Integration: Automated allocation across concurrent operations
- Efficiency Optimization: Utilization tracking and optimization recommendations
- Time Acceleration: Adjusted consumption rates for different game speeds
- Progress Tracking: Real-time usage monitoring and completion estimation

### Deterministic Framework
All capacity operations incorporate seeded randomization for reproducibility:
- Seeded Randomness: Consistent allocation outcomes across sessions
- Reproducible Results: Identical inputs produce identical capacity assignments
- Testing Support: Deterministic behavior enables comprehensive validation
- Balance Analysis: Statistical evaluation of capacity utilization patterns

## Examples

### Manufacturing Capacity Management
A workshop facility provides 25 man-hours per day of manufacturing capacity. A base with dual workshops achieves 50 total man-hours daily. A 100 man-hour project completes in 2 days at full allocation, with real-time tracking showing 100% capacity utilization during production.

### Storage Capacity and Overflow
A general store facility grants 500 units of item storage capacity. When incoming salvage fills storage to capacity, the auto-sell overflow policy activates at the 80% threshold. Excess resources sell at 75% market value, returning storage utilization to manageable levels and generating emergency funding.

### Prisoner Capacity System
Holding cells provide prisoner capacity in 4-slot increments. Each captive, regardless of species, consumes one slot. A base with three cells maintains 12 total prisoner slots. When capacity reaches limits, overflow policies trigger inter-base transfers, creating strategic decisions about prisoner management and research opportunities.

### Hangar Slot Allocation
Individual hangar facilities grant single craft slots despite varying footprints. A base with four hangars provides four total slots. Large transports consume two slots while fighters use one, requiring strategic capacity planning. Damaged facilities reduce available slots, impacting operational flexibility.

### Research Throughput System
Laboratory facilities contribute research points per day. A base with three labs generates 30 research points daily. A 200-point project completes in approximately 6.67 days at full allocation. Multiple concurrent research projects share available throughput, requiring scheduling optimization.

## Related Wiki Pages

- [Facilities](basescape/Facilities.md) - Capacity-providing base structures
- [Services](basescape/Services.md) - Capacity utilization and service requirements
- [New Base Building](basescape/New Base building.md) - Capacity planning and expansion
- [Monthly Base Report.md](../basescape/Monthly%20base%20report.md) - Capacity utilization metrics
- [Finance.md](../finance/Finance.md) - Capacity expansion costs
- [Manufacturing.md](../economy/Manufacturing.md) - Production capacity limits
- [Research.md](../basescape/Research.md) - Research throughput capacities
- [Technical Architecture.md](../architecture.md) - Capacity calculation systems
- [Geoscape.md](../geoscape/Geoscape.md) - Strategic capacity implications
- [Interception.md](../interception/Overview.md) - Operational capacity constraints

## References to Existing Games and Mechanics

- **XCOM Series**: Base capacity limits and resource constraints
- **Civilization**: City capacity limits and population management
- **The Sims**: Household capacity limits and space management
- **Prison Architect**: Facility capacities and prisoner management
- **RimWorld**: Colony storage limits and resource management
- **Banished**: Town capacity limits and population constraints
- **Cities: Skylines**: City service capacities and infrastructure limits
- **Factorio**: Factory throughput limits and production constraints
- **Dwarf Fortress**: Fortress capacities and resource management
- **Stellaris**: Empire capacity limits and administrative constraints

