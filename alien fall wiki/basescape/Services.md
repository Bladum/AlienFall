# Services

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Service Type Categories](#service-type-categories)
  - [Service Discovery and Availability](#service-discovery-and-availability)
  - [Dependency Chains and Cascading Effects](#dependency-chains-and-cascading-effects)
  - [Service Capacity and Utilization Tracking](#service-capacity-and-utilization-tracking)
  - [Fallback and Redundancy Mechanics](#fallback-and-redundancy-mechanics)
  - [Service Requirements and Activation](#service-requirements-and-activation)
  - [Operational States and Status Tracking](#operational-states-and-status-tracking)
  - [Staffing and Efficiency Modifiers](#staffing-and-efficiency-modifiers)
  - [Maintenance and Lifecycle Management](#maintenance-and-lifecycle-management)
- [Examples](#examples)
  - [Power Supply Service Chain](#power-supply-service-chain)
  - [Research Service Dependencies](#research-service-dependencies)
  - [Manufacturing Service Operations](#manufacturing-service-operations)
  - [Craft Repair Service Integration](#craft-repair-service-integration)
  - [Radar Service Coverage](#radar-service-coverage)
  - [Academy Training Service](#academy-training-service)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

Services establish a dynamic dependency network between base facilities, transforming static facility placement into operational relationships with cascading consequences. This system makes base layout decisions strategically meaningful by creating explicit service dependencies that affect operational efficiency and create optimization opportunities. Services act as connective tissue between strategic base design and tactical execution, where service availability directly impacts mission readiness, production capacity, and defensive capabilities.

The service framework supports graceful degradation during disruptions, with deterministic fallback behaviors and redundancy planning. All service relationships are data-driven, enabling extensive modding while maintaining reproducible outcomes for testing and balancing.

## Mechanics

### Service Type Categories
Services organize into functional categories with distinct operational roles:
- Core Services: Essential for base survival (power_supply, connectivity, personnel_capacity)
- Operational Services: Enable primary functions (research, manufacture, craft_repair)
- Support Services: Enhance efficiency and quality (radar_service, medical_support, training_facility)
- Defensive Services: Provide protection and security (base_defense_emplacement, monitoring_system)
- Modular Framework: Extensible system allowing custom service types for mod content

### Service Discovery and Availability
The system maintains real-time awareness of service provision across the base:
- Facility Advertising: Facilities declare available services through service tags
- Base Scanning: Automatic construction of service availability maps from operational facilities
- Connectivity Requirements: Services only active when facilities are connected and online
- Dynamic Updates: Service status changes immediately with facility state modifications
- Real-time Monitoring: Continuous tracking of service provision and utilization

### Dependency Chains and Cascading Effects
Service relationships create interconnected operational networks:
- System Declarations: Components specify required services for full functionality
- Failure Triggers: Service unavailability activates deterministic fallback protocols
- Priority Shutdowns: Cascading failures follow predefined sequences based on criticality
- Impact Propagation: Service loss effects transmit through dependent systems predictably
- Recovery Sequences: Service restoration follows reverse dependency priority ordering

### Service Capacity and Utilization Tracking
Services incorporate capacity management for resource optimization:
- Capacity Limits: Throughput restrictions and slot limitations for service utilization
- Utilization Monitoring: Prevents oversubscription and enables efficiency optimization
- Quality Modifiers: Staffing levels and maintenance status affect service effectiveness
- Efficiency Tracking: Performance metrics collection for utilization analysis
- Load Balancing: Demand distribution across multiple service providers

### Fallback and Redundancy Mechanics
The system provides robust responses to service disruptions:
- Primary Failover: Automatic switching to backup service providers when available
- Graceful Degradation: Reduced effectiveness during partial service unavailability
- Emergency Procedures: Critical service loss response protocols with predetermined actions
- Redundancy Planning: Multiple facility options for essential service provision
- Contingency Operations: Alternative procedures maintaining minimal functionality during disruptions

### Service Requirements and Activation
Facilities have interdependent activation requirements:
- Facility Dependencies: Facilities may require services from other facilities for operation
- Circular Prevention: Validation system prevents dependency loops during base design
- Priority Ordering: Service bootstrapping ensures core facilities activate before dependents
- Conditional Operation: Facilities operate at reduced capacity without required services
- Activation Sequences: Deterministic startup order for interdependent system initialization

### Operational States and Status Tracking
Services maintain clear operational status for management and diagnostics:
- Online State: Service fully available at peak effectiveness and capacity
- Degraded State: Service available but operating at reduced capacity or efficiency
- Offline State: Service completely unavailable due to facility failure or disconnection
- Maintenance State: Service temporarily unavailable for scheduled upkeep procedures
- Transition Tracking: Clear notifications and impact assessments for state changes

### Staffing and Efficiency Modifiers
Personnel allocation directly affects service performance:
- Personnel Requirements: Appropriate staff numbers needed for full service effectiveness
- Understaffing Penalties: Deterministic efficiency reductions with insufficient personnel
- Training Effects: Experience and specialization levels enhance service quality
- Morale Impact: Staff morale influences service performance and reliability, reduced by craft losses and mission failures
- Specialization Bonuses: Specialized personnel provide service enhancements and bonuses

### Maintenance and Lifecycle Management
Services require ongoing care for sustained performance:
- Periodic Maintenance: Required upkeep procedures to maintain service effectiveness
- Wear Degradation: Service quality reduction over time without proper maintenance
- Upgrade Paths: Improvements that increase service capacity and efficiency
- Lifecycle Tracking: Service age and usage patterns affect performance characteristics
- Replacement Planning: End-of-life procedures and replacement scheduling

## Examples

### Power Supply Service Chain
Fusion Reactor provides power_supply service to all base facilities. Complete failure triggers cascading shutdowns with backup generators providing 50% power during outages. Recovery requires 4 hours with emergency procedures maintaining critical systems.

### Research Service Dependencies
Laboratory provides research service with 15 points/day capacity, requiring power_supply and personnel_quarters. 85% utilization with 3 active projects, needing 2 scientists for full effectiveness. Service loss suspends projects while preserving progress for resumption.

### Manufacturing Service Operations
Workshop provides manufacture service with 25 man-hours/day capacity. Production queue operates at 100% utilization halting new starts. Engineer skill levels affect production speed, with monthly maintenance preventing efficiency degradation.

### Craft Repair Service Integration
Hangar provides craft_repair service for interception craft maintenance. All craft repairs occur daily with automatic processing based on hangar quality and technician availability. Damaged crafts are repaired each day, restoring them to full operational status. Service failure delays repairs and reduces operational readiness.

### Radar Service Coverage
Radar Array provides radar_service with 25 detection power units. 500km radius coverage with terrain modifiers, requiring monthly calibration to prevent detection degradation. Service loss creates blind spots in geoscape coverage and delayed responses.

### Academy Training Service
Academy provides training_facility service with 20 XP/day throughput and 2 promotion slots. Requires 2 instructors for optimal effectiveness. Service failure halts unit progression and reduces combat readiness.

## Related Wiki Pages

- [Facilities.md](../basescape/Facilities.md) - Service-providing base structures
- [Capacities.md](../basescape/Capacities.md) - Service utilization limits and constraints
- [New Base Building.md](../basescape/New%20Base%20building.md) - Strategic service planning
- [Monthly Base Report.md](../basescape/Monthly%20base%20report.md) - Service status and performance tracking
- [Research.md](../basescape/Research.md) - Service-dependent technology development
- [Manufacturing.md](../economy/Manufacturing.md) - Production service requirements
- [Finance.md](../finance/Finance.md) - Service maintenance and operational costs
- [Technical Architecture.md](../architecture.md) - Service system data structures
- [Geoscape.md](../geoscape/Geoscape.md) - Service impacts on global operations
- [Interception.md](../interception/Overview.md) - Service effects on combat readiness

## References to Existing Games and Mechanics

- **XCOM Series**: Base services and facility dependencies for operations
- **Civilization**: City services and building infrastructure chains
- **SimCity**: Urban infrastructure and service coverage systems
- **Dwarf Fortress**: Workshop dependencies and production chains
- **Factorio**: Industrial production chains and resource dependencies
- **The Sims**: Household service requirements and satisfaction systems
- **Cities: Skylines**: Municipal service coverage and infrastructure management
- **Prison Architect**: Facility dependencies and operational requirements
- **RimWorld**: Colony services and infrastructure management
- **Banished**: Town services and resource dependency systems

