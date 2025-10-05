# Manufacturing

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Manufacturing Process](#manufacturing-process)
  - [Capacity and Resources](#capacity-and-resources)
  - [Cost Structure](#cost-structure)
  - [Production Management](#production-management)
  - [Recipe System](#recipe-system)
  - [Progress and Completion](#progress-and-completion)
- [Examples](#examples)
  - [Basic Manufacturing Project](#basic-manufacturing-project)
  - [Capacity Allocation Strategies](#capacity-allocation-strategies)
  - [Parallel Production Example](#parallel-production-example)
  - [Advanced Manufacturing Scenarios](#advanced-manufacturing-scenarios)
  - [Cost Optimization Examples](#cost-optimization-examples)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The manufacturing system manages production of equipment, units, crafts, and facilities through a deterministic process consuming resources, time, and engineering capacity. Operating on man-day based capacity allocation, the system creates strategic trade-offs between production speed, resource availability, and base specialization. Manufacturing projects require specific facilities, research prerequisites, and resource inputs while providing essential equipment for campaign progression.

The framework emphasizes predictable production queues, throughput constraints, and meaningful bottlenecks that reward facility investment and strategic planning. Data-defined recipes ensure extensibility and modding support while providing clear UI feedback on inputs, progress, and outputs.

## Mechanics

### Manufacturing Process

Deterministic production engine converting raw materials into usable equipment:

- Project Initiation: Facility requirements, research prerequisites, and resource availability checks
- Research Gating: Recipes only queueable after associated research entries are completed
- Resource Reservation: Input items marked unavailable in storage when project begins
- Capacity Allocation: Engineering man-hours assigned from workshop facilities
- Progress Accumulation: Daily man-hour consumption reducing remaining project requirements

### Capacity and Resources

Engineering throughput and resource management constraints:

- Man-Day Capacity: Facilities provide daily engineering capacity measured in man-hours
- Capacity Allocation: Players distribute available capacity across queued projects
- Parallel Production: Multiple projects running simultaneously within capacity limits
- Resource Requirements: Input stacks of resources, items, and components
- Storage Management: Base storage capacity for inputs, outputs, and work-in-progress

### Cost Structure

Financial and resource costs associated with production activities:

- Man-Day Requirements: Base engineering hours needed for project completion
- Engineer Salaries: Daily payments for allocated engineering capacity
- Facility Maintenance: Monthly overhead costs for workshop operations
- Resource Acquisition: Costs for obtaining required inputs through marketplace or transfers
- Efficiency Modifiers: Research and facility upgrades reducing costs and improving throughput

### Production Management

Queue management and production control systems:

- Project Queues: Ordered lists of manufacturing projects at each base
- Priority System: Projects can be reordered and capacity allocation adjusted
- Dependency Resolution: Projects blocked by prerequisite completion or resource availability
- Cancellation Policies: Configurable refunds for cancelled projects with sunk cost considerations
- Overflow Handling: Policies for storage full conditions (fail, queue, auto-sell, auto-transfer)

### Recipe System

Data-driven production definitions with comprehensive requirements:

- Input Specifications: Required resource stacks, items, and component quantities
- Output Definitions: Produced items, units, crafts, or lore items with quantities
- Facility Requirements: Specific workshop types and base service dependencies
- Research Prerequisites: Required technological advancements for recipe availability
- Cost Parameters: Man-hours, fixed costs, and optional rare component requirements

### Progress and Completion

Daily processing and project lifecycle management:

- Daily Ticks: Progress applied based on allocated man-hours each day
- Labor Accounting: Wages charged only for actually used capacity
- Completion Handling: Outputs placed in storage when man-hour requirements met
- Milestone Outputs: Intermediate components produced at percentage completion points
- Service Dependencies: Projects pause if required services become unavailable

## Examples

### Basic Manufacturing Project
Laser Rifle Production
- Inputs: 10 Alien Alloys, 5 Elerium, 1 Electronics Kit
- Outputs: 1 Laser Rifle
- Man-Hours: 80
- Facility Requirements: Workshop, Power Supply service
- Research Prerequisites: Basic Laser Technology
- Daily Allocation: 20 man-hours (completes in 4 days)
- Engineer Cost: 500 credits per day allocated
- Total Cost: 320 man-hours + 2,000 credits + resource costs

### Capacity Allocation Strategies
Single Base Manufacturing
- Workshop Capacity: 50 man-hours per day
- Project Queue: 3 projects requiring 80, 120, 60 man-hours respectively
- Allocation Option 1: 50 man-hours to first project (completes in 2 days)
- Allocation Option 2: 20/20/10 split across projects (balanced completion)
- Strategic Choice: Speed vs. diversification trade-offs

### Parallel Production Example
Multi-Base Manufacturing
- Base A: 30 man-hours/day workshop, focuses on weapons
- Base B: 40 man-hours/day workshop, focuses on armor
- Total Capacity: 70 man-hours/day across organization
- Project Distribution: Large orders split across bases for faster completion
- Logistics Challenge: Resource distribution and transfer coordination

### Advanced Manufacturing Scenarios
Bulk Production Run
- Project: 50 Laser Rifles
- Scaled Requirements: 500 Alien Alloys, 250 Elerium, 50 Electronics Kits
- Man-Hours: 4,000 (potential efficiency bonuses for scale)
- Capacity Planning: Dedicated base with maximum workshop capacity
- Resource Management: Stockpile inputs, manage transfer timing

Complex Assembly Project
- Multi-Stage Recipe: Fighter craft with intermediate milestones
- 25% Milestone: Airframe assembly (reusable for variants)
- 50% Milestone: Engine installation (testable subassembly)
- 100% Milestone: Final craft with all systems integrated
- Dependency Management: Intermediate outputs usable by other projects

### Cost Optimization Examples
Efficiency Research Impact
- Base Project: 100 man-hours for advanced armor
- Efficiency Bonus: -20% from research (+20% capacity or -20% cost)
- Optimized Cost: 80 man-hours or reduced engineer allocation
- Strategic Value: Research investment pays ongoing manufacturing dividends

Facility Upgrade Benefits
- Basic Workshop: 20 man-hours/day capacity
- Upgraded Workshop: 30 man-hours/day capacity (+50% throughput)
- Cost Comparison: Same daily engineer costs for 50% more output
- Investment Payback: Reduced completion times and increased production volume

## Related Wiki Pages

- [Research.md](../basescape/Research.md) - Technology prerequisites for manufacturing recipes.
- [Suppliers.md](../economy/Suppliers.md) - Resource procurement and supply chains.
- [Marketplace.md](../economy/Marketplace.md) - Equipment sales and market dynamics.
- [Finance.md](../finance/Finance.md) - Production costs and budget allocation.
- [Facilities.md](../basescape/Facilities.md) - Workshop capacity and manufacturing facilities.
- [Capacities.md](../basescape/Capacities.md) - Manufacturing throughput limits.
- [Craft item.md](../crafts/Craft%20item.md) - Equipment production requirements.
- [Units.md](../units/Units.md) - Personnel equipment manufacturing.
- [Technical Architecture.md](../architecture.md) - Manufacturing system data structures.
- [Geoscape.md](../geoscape/Geoscape.md) - Strategic production planning.

## References to Existing Games and Mechanics

- **XCOM Series**: Manufacturing and equipment production systems
- **Civilization**: City production queues and build mechanics
- **Master of Orion**: Ship construction and industrial capacity
- **Homeworld**: Ship building and fleet production systems
- **Factorio**: Factory production and assembly line mechanics
- **Satisfactory**: Manufacturing chains and resource processing
- **Dyson Sphere Program**: Production systems and industrial automation
- **StarCraft**: Unit production and build queue management
- **Command & Conquer**: Base production and unit manufacturing
- **Total War**: Army recruitment and equipment production

