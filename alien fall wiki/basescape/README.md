# Basescape Systems

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Facility Grid and Placement](#facility-grid-and-placement)
  - [Capacity Management Framework](#capacity-management-framework)
  - [Service Network System](#service-network-system)
  - [Construction Queue System](#construction-queue-system)
  - [Monthly Reporting Framework](#monthly-reporting-framework)
  - [Base Expansion Mechanics](#base-expansion-mechanics)
  - [Satellite Base System](#satellite-base-system)
  - [Deterministic Processing](#deterministic-processing)
- [Examples](#examples)
  - [Facility Grid Layout](#facility-grid-layout)
  - [Service Dependency Chain](#service-dependency-chain)
  - [Capacity Utilization Tracking](#capacity-utilization-tracking)
  - [Construction Phase Progression](#construction-phase-progression)
  - [Monthly Report Generation](#monthly-report-generation)
  - [Multi-Base Operations](#multi-base-operations)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Basescape system provides the strategic home front management layer for AlienFall, transforming geoscape victories into lasting operational power through facility construction, research advancement, and manufacturing capabilities. This deterministic framework converts player resources into tangible strategic advantages through base layout decisions, service network optimization, and capacity management. The system emphasizes meaningful facility placement choices where positioning and connectivity directly impact operational efficiency, creating strategic depth through grid-based construction mechanics.

Basescape integrates with all major game systems, providing the foundational infrastructure for research laboratories, manufacturing workshops, craft hangars, and defensive installations. The 20×20 pixel grid system ensures pixel-perfect alignment with battlescape and UI standards, while data-driven facility definitions enable extensive modding capabilities. Monthly reporting surfaces actionable intelligence about resource flows, capacity constraints, and operational status without overwhelming player attention.

## Mechanics

### Facility Grid and Placement
Bases utilize structured grid systems for facility organization:
- Grid Dimensions: 20×20 logical tiles per facility slot with pixel-perfect alignment
- Facility Footprints: Buildings occupy multiples of 2 tiles for visual symmetry
- Adjacency Requirements: Construction requires connection to powered corridor networks
- Corridor System: 1×1 logical tile corridors using 10×10 pixel sprites scaled 2×
- Layout Constraints: Geometric limitations creating strategic placement decisions
- Construction Validation: Real-time placement legality checking during planning phase

### Capacity Management Framework
All resource constraints operate through unified capacity system:
- Named Capacity Keys: Storage, living quarters, workshop hours tracked per base
- Facility Contributions: Online facilities aggregate capacity totals automatically
- Overflow Policies: Configurable responses (block, queue, auto-transfer, auto-sell) to capacity exceedance
- Real-Time Tracking: Continuous monitoring of utilization percentages and thresholds
- Deterministic Allocation: Clear rules for resource assignment and reservation
- Cross-Base Management: Optional capacity sharing between facilities and locations

### Service Network System
Facilities provide operational capabilities through service tag advertising:
- Service Declaration: Facilities announce available services (power, research, manufacture, medical)
- Dependency Validation: Systems check required services before operation activation
- Connectivity Requirements: Services only active when facilities connected to base network
- Cascading Effects: Service failures propagate through dependent systems predictably
- Redundancy Support: Multiple service providers enable failover and load balancing
- Dynamic Updates: Service availability recalculation on facility status changes

### Construction Queue System
Bases support concurrent facility development:
- Queue Capacity: Up to five simultaneous construction projects per base
- Progress Tracking: Deterministic completion timers with real-time status updates
- Resource Allocation: Upfront or incremental payment options for construction costs
- Phase Management: Planning → Foundation → Operational state progression
- Maintenance Handling: Ongoing costs during construction period
- Priority System: Player-controlled ordering for resource-constrained situations

### Monthly Reporting Framework
First day of each month triggers comprehensive operational summary:
- Report Generation: Automatic snapshot of finances, staffing, and facility status
- Alert Categorization: Critical, Warning, and Informational priority levels
- Deterministic Seeding: Finance seed `finance:<month>` ensures replay consistency
- Cross-System Integration: Aggregated data from all base operational systems
- Actionable Intelligence: Recommendations with projected outcomes for player decisions
- Historical Tracking: Trend analysis and performance comparison capabilities

### Base Expansion Mechanics
New base construction follows structured progression:
- Territory Requirements: Geoscape province control prerequisite for site selection
- Financial Planning: Upfront funding requirements with maintenance projections
- Construction Phases: Planning → Foundation → Operational with deterministic durations
- Risk Event System: Sabotage and bombardment events triggered by Alien Director
- Data-Driven Configuration: Phase timings and requirements defined in `data/bases/base_phases.toml`
- Site Selection Strategy: Geographic positioning affects detection coverage and response times

### Satellite Base System
Multiple bases create strategic coverage networks:
- Specialization Options: Research-focused, production-heavy, or interception-specialized configurations
- Coverage Optimization: Geographic distribution maximizing radar and response capabilities
- Resource Distribution: Inter-base transfers and capacity sharing mechanisms
- Independent Operation: Each base maintains separate facility grids and service networks
- Strategic Coordination: Unified command structure with individual operational autonomy

### Deterministic Processing
All basescape operations incorporate seeded randomization:
- Event Determinism: Construction completion and risk events use campaign-seeded RNG
- Reproducible Results: Identical inputs produce identical basescape outcomes across sessions
- Save/Load Integrity: Persist derived data with adjacency graph recalculation on load
- Testing Support: Deterministic behavior enables comprehensive QA validation
- Balance Analysis: Statistical evaluation of construction timing and capacity utilization

## Examples

### Facility Grid Layout
Standard base with 6×6 facility grid (36 tiles) begins with central access lift at C2 position. Early expansion constructs 2 living quarters (B2, D2) adjacent to lift, followed by laboratory pair (B3, C3) for research capacity. Power plant (F3) provides electrical service, while general stores (D3) offers storage capacity. Workshop (B4) enables manufacturing, creating functional early-game base within $3.5M budget over 60-day construction timeline.

### Service Dependency Chain
Fusion reactor provides power_supply service to entire base network. Laboratory requires power_supply and personnel_quarters services for full operation, delivering 15 research points daily when staffed with 2 scientists. Complete reactor failure triggers cascading shutdown with backup generators providing 50% power during 4-hour emergency recovery period. Service restoration follows reverse dependency priority, activating critical systems first.

### Capacity Utilization Tracking
Base with three workshops achieves 75 man-hours daily manufacturing capacity. Current production queue consumes 70 man-hours (93% utilization), creating production backlog visible in monthly report. New facility construction project requiring 100 man-hours prompts capacity expansion recommendation. Workshop expansion to four facilities increases capacity to 100 man-hours, reducing queue time by 40% and improving production throughput.

### Construction Phase Progression
New satellite base enters Planning phase requiring 1-2 weeks for site survey and resource allocation. Foundation phase excavates infrastructure over 2-4 weeks establishing basic connectivity. Development phase constructs facilities over 4-8 weeks integrating systems and services. Operational phase deploys crew over 1 week for final activation. Total timeline approximately 10-15 weeks from initiation to full operational status.

### Monthly Report Generation
Monthly report generates on day 1 of each month using seeded finance stream for reproducibility. Executive summary presents 87% base health, $2.4M net income, and 92% capacity utilization. Operations section details 24/24 facilities online with 3 maintenance alerts. Financial breakdown shows $4M income against $1.6M expenses. Research section tracks 5 active projects at 67% average completion. Report recommendations suggest workshop expansion and radar system maintenance.

### Multi-Base Operations
Three-base global network positions main operations base in North America (New York), secondary interception base in Europe (London), and satellite detection base in Asia (Tokyo). Combined radar coverage reaches 80% of landmass with sub-2-hour response times to most threats. Main base specializes in research and manufacturing (6 labs, 4 workshops), London focuses on interception operations (3 hangars, 6 craft), Tokyo provides forward detection with minimal facilities. Total network investment approximately $35M with coordinated strategic coverage.

## Related Wiki Pages

- [Facilities.md](Facilities.md) - Individual facility specifications and capabilities
- [Services.md](Services.md) - Service network system and dependencies
- [Capacities.md](Capacities.md) - Capacity management framework
- [New Base Building.md](New%20Base%20building.md) - Base construction mechanics
- [Facility_Placement.md](Facility_Placement.md) - Optimal layout strategies
- [Monthly Base Report.md](Monthly%20base%20report.md) - Reporting system details
- [Geoscape.md](../geoscape/README.md) - Strategic layer integration
- [Economy.md](../economy/README.md) - Resource management systems
- [Finance.md](../finance/README.md) - Financial management
- [Battlescape.md](../battlescape/README.md) - Tactical base defense integration

## References to Existing Games and Mechanics

- **XCOM Series**: Base construction and facility management systems
- **Civilization**: City infrastructure and building placement mechanics
- **SimCity**: Urban infrastructure and service network management
- **Dwarf Fortress**: Facility dependencies and production chains
- **Factorio**: Industrial layout optimization and throughput management
- **Prison Architect**: Facility placement and service coverage systems
- **RimWorld**: Colony infrastructure and resource management
- **Banished**: Town services and building dependencies
- **Cities: Skylines**: Municipal infrastructure and service networks
- **The Sims**: Household capacity limits and space management
