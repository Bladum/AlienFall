# Monthly Reports

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Generation and Determinism Frameworks](#generation-and-determinism-frameworks)
  - [Header and Metadata Systems](#header-and-metadata-systems)
  - [Finance Section Architecture](#finance-section-architecture)
  - [Score and Funding Integration](#score-and-funding-integration)
  - [Fame and Karma Assessment](#fame-and-karma-assessment)
  - [Resource Flow Analysis](#resource-flow-analysis)
  - [Maintenance and Upkeep Auditing](#maintenance-and-upkeep-auditing)
  - [Forces Summary Analytics](#forces-summary-analytics)
  - [Missions Summary Frameworks](#missions-summary-frameworks)
  - [Diagnostics and Bottleneck Analysis](#diagnostics-and-bottleneck-analysis)
  - [Actions and Control Integration](#actions-and-control-integration)
  - [Export and Telemetry Systems](#export-and-telemetry-systems)
- [Examples](#examples)
  - [Generation and Timing Examples](#generation-and-timing-examples)
  - [Finance Section Examples](#finance-section-examples)
  - [Score and Funding Correlation](#score-and-funding-correlation)
  - [Fame and Karma Assessment](#fame-and-karma-assessment)
  - [Resource Flow Analysis](#resource-flow-analysis)
  - [Maintenance and Upkeep Auditing](#maintenance-and-upkeep-auditing)
  - [Forces Summary Analytics](#forces-summary-analytics)
  - [Missions Summary Frameworks](#missions-summary-frameworks)
  - [Diagnostics and Bottleneck Analysis](#diagnostics-and-bottleneck-analysis)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Monthly Reports system establishes comprehensive strategic audit frameworks for Alien Fall's campaign management, implementing deterministic state snapshots, multi-scope analysis, and detailed performance tracking. The system creates transparent decision-making tools through modular reporting, provenance tracking, and comprehensive analytics while maintaining reproducibility and moddability. The framework balances information depth with usability, providing players and designers canonical audit records for strategic planning and balance validation. Reports serve as the single source of truth for campaign telemetry, enabling reproducible balancing, clear player guidance, and rich modder integrations.

## Mechanics

### Generation and Determinism Frameworks

Monthly cycle execution with seeded reproducibility:
- Timing Systems: Monthly cycle execution on day 1 after daily tick, deterministic generation timing
- Scope Architecture: Multi-level reporting from global to individual base analysis (Global, Per World, Per Region, Per Country, Per Faction, Per Base)
- Reproducibility Mechanisms: Seeded random generation using campaign/world seed, consistent output systems for identical save+seed combinations
- Modular Construction: Configurable section inclusion and aggregation capabilities, subset emission support
- Provenance Tracking: Calculation source identification with computed_from metadata (tickIds, baseIds, formulaId), audit trail maintenance
- Export Integration: Multiple format support (CSV, JSON, compressed bundles) and telemetry system connectivity

### Header and Metadata Systems

Report identification and context tracking:
- Report Identification: Scope, period (start/end dates), and generation timestamp tracking
- Seed Integration: Campaign seed reference and reproducibility assurance for playtests and debugging
- Format Flexibility: Multiple export options (CSV, JSON, compressed bundles) and data structure compatibility
- Hook Architecture: Event system integration (on_monthly_report_generated, on_monthly_report_export) and modding extensibility
- Metadata Enrichment: Additional context and reference information inclusion
- Validation Frameworks: Data integrity checking, consistency verification, and reachability validation

### Finance Section Architecture

Comprehensive financial state tracking and analysis:
- Balance Tracking: Opening balance, total income, total expenses, net change, and closing balance management
- Income Categorization: Source-specific revenue breakdown (country funding, market sales, contracts, salvage sales, royalties, investment returns, black market receipts)
- Expense Classification: Category-based spending analysis (personnel salaries, facility maintenance, craft maintenance/fuel, project spending, loan interest, transfer costs, one-time purchases)
- Commitment Tracking: Recurring obligations and scheduled payment monitoring (next-month maintenance, loan amortization)
- Cash Flow Analysis: Historical trends, month-over-month comparison, and sparkline visualization
- Alert Systems: Financial health monitoring with critical threshold detection (negative balance, missed payments, auto-liquidation warnings)

### Score and Funding Integration

Performance metrics and funding correlation tracking:
- Performance Metrics: Public perception and achievement measurement with per-province score deltas
- Funding Correlation: Score-based financial support and adjustment tracking with aggregated CountryTotalScore
- Political Indicators: Relationship status and diplomatic standing assessment with MonthlyPoints tracking
- Trend Analysis: Performance evolution, historical trajectory, and predictive modeling (last N months)
- Consequence Tracking: Score-driven effects, strategic implications, and FundingLevel threshold warnings
- Benchmarking Systems: Comparative analysis and improvement target establishment

### Fame and Karma Assessment

Reputation and ethical balance tracking:
- Reputation Tracking: Public image and notoriety measurement systems with per-scope totals and deltas
- Ethical Balance: Moral standing and alignment assessment frameworks with event contributor tracking
- Consequence Integration: Reputation-driven effects and opportunity modification (supplier access, diplomacy, scripted content)
- Trend Monitoring: Reputation evolution and pattern identification with top Fame/Karma changing actions
- Strategic Implications: Reputation-based strategic option availability and gating/awareness effects
- Recovery Mechanisms: Reputation improvement and damage mitigation strategies

### Resource Flow Analysis

Comprehensive resource movement and utilization tracking:
- Movement Tracking: Resource transfer and allocation monitoring with per-base and aggregated data
- Consumption Patterns: Usage analysis and efficiency assessment by resource type (excluding unique lore items)
- Production Monitoring: Generation tracking and capacity utilization with top producers identification
- Distribution Networks: Supply chain analysis and bottleneck identification with overflow/shortage events
- Optimization Opportunities: Efficiency improvement and waste reduction with auto-sell triggers
- Strategic Allocation: Resource distribution optimization and planning tools with storage capacity tracking

### Maintenance and Upkeep Auditing

Facility and equipment maintenance tracking:
- Facility Management: Base infrastructure maintenance and repair tracking with offline facility monitoring
- Equipment Servicing: Craft and weapon system upkeep monitoring with upcoming critical maintenance
- Personnel Costs: Salary and training expense analysis with cumulative backlog tracking
- Preventive Maintenance: Proactive servicing and failure prevention with effective maintenance rate calculation
- Cost Optimization: Maintenance efficiency and budget management with power shortfall monitoring
- Lifecycle Planning: Long-term maintenance scheduling and capital planning

### Forces Summary Analytics

Unit and equipment inventory assessment:
- Unit Inventory: Personnel counting by role/class/rank with wounded/recovery tracking and morale/sanity distribution
- Readiness Evaluation: Operational capability and deployment readiness with wounded-days remaining
- Training Status: Skill development and proficiency tracking with aggregate wounded-days
- Equipment Condition: Weapon and vehicle maintenance state monitoring with hangar utilization tracking
- Deployment Tracking: Unit location and assignment monitoring (stationed, in-transit, in-repair, deployed)
- Capability Assessment: Combat effectiveness and strategic value evaluation with availability status

### Missions Summary Frameworks

Operation tracking and performance analysis:
- Operation Tracking: Mission execution and outcome recording with spawned mission counts by type
- Success Metrics: Performance measurement and achievement assessment (succeeded/failed/escaped/unresolved)
- Resource Utilization: Mission cost and efficiency analysis with detection statistics
- Pattern Recognition: Operational trend identification and strategy optimization with cover reduction tracking
- Risk Assessment: Mission difficulty and casualty analysis with salvage and captive aggregation
- Strategic Learning: Operational improvement and tactical evolution with success rate analysis

### Diagnostics and Bottleneck Analysis

Performance monitoring and optimization identification:
- Performance Monitoring: System efficiency and limitation identification with top N bottleneck detection
- Constraint Analysis: Resource and capability bottleneck detection (storage capacity, power, hangar slots, research capacity)
- Optimization Recommendations: Improvement opportunity identification with suggested quick actions
- Predictive Modeling: Future limitation forecasting and planning with correlation hints
- System Health: Overall campaign state and sustainability assessment with provenance drilldowns
- Intervention Planning: Corrective action development and prioritization with diagnostic traceability

### Actions and Control Integration

Immediate response and workflow optimization:
- Quick Access: Immediate action initiation and response capability through deterministic quick commands
- UI Integration: Interface hooks and user interaction systems with provenance-backed commands
- Workflow Optimization: Process streamlining and efficiency enhancement with scheduler hook mapping
- Automation Support: Routine task handling and decision acceleration with logged provenance
- Control Systems: Management interface and oversight capability with auditable change tracking
- Feedback Loops: Action outcome tracking and improvement systems with suggested quick-fix actions

### Export and Telemetry Systems

Comprehensive data export and integration support:
- Data Export: Multiple format support (CSV, JSON, compressed bundles) and external system integration
- Analytics Integration: Performance tracking and behavioral analysis with API key support
- Modding Support: Community tool access and customization capability with data-driven configuration
- Historical Archiving: Long-term data preservation and trend analysis with compact export manifests
- Research Integration: Design validation and balance testing support with seeded previewer tools
- Performance Benchmarking: Comparative analysis and optimization tracking with reproducibility guarantees

## Examples

### Generation and Timing Examples
- Monthly Cycle: Day 1 execution, Campaign seed 12345, Global scope analysis, Complete audit snapshot with reproducible RNG
- Regional Focus: Europe region scope, 30-day period, Local economic analysis, Targeted assessment with provenance tracking
- Base-Specific: Primary base scope, Weekly sub-reports, Facility performance, Detailed operations with computed_from metadata
- Faction Analysis: Alien faction scope, Multi-world coverage, Threat assessment, Strategic intelligence with scope aggregation
- Performance Tracking: Historical comparison, Trend identification, Predictive modeling, Strategic planning with seed-based consistency

### Finance Section Examples
- Balance Overview: Opening $5M, Income $2.5M, Expenses $2M, Net +$500K, Closing $5.5M with full provenance tracking
- Income Breakdown: Country funding $1.2M (48%), Sales $600K (24%), Contracts $400K (16%), Salvage $300K (12%), Royalties $200K (8%), Investment returns $100K (4%)
- Expense Analysis: Personnel $800K (40%), Maintenance $600K (30%), Projects $400K (20%), Loan interest $100K (5%), Transfers $50K (2.5%), Other $50K (2.5%)
- Commitment Tracking: Next month maintenance $150K, Loan payments $200K, Contract obligations $100K, Scheduled amortization $75K
- Cash Flow Trends: Month -1: +$300K, Month -2: +$450K, Month -3: -$100K, Average +$217K/month with sparkline visualization
- Alert Conditions: Low balance warning ($500K threshold), Maintenance overdue (2 facilities), Budget deficit projected, Auto-liquidation risk

### Score and Funding Correlation
- Performance Metrics: Public score +450 (excellent), Funding level 85/100, Political stability high with per-province deltas
- Funding Adjustment: Score delta +150, Funding increase +2 levels, Monthly bonus $200K using configured payout formula
- Political Indicators: Government relations 80/100, Diplomatic standing favorable, Support options available with trajectory tracking
- Trend Analysis: Score improvement +25/month average, Funding stability maintained, Long-term growth projected with historical data
- Strategic Implications: High funding unlocks advanced projects, Diplomatic bonuses active, Expansion opportunities with threshold warnings
- Recovery Tracking: Previous low period overcome, Score stabilization achieved, Funding restoration complete with benchmarking

### Fame and Karma Assessment
- Reputation Status: Fame rating 75/100 (respected), Karma balance +20 (ethical), Public image positive with month deltas
- Ethical Standing: Moral alignment neutral-good, Controversy level low, Community support strong with event contributors
- Consequence Effects: Reputation bonuses active (+10% mission success), Ethical opportunities available, Supplier access improved
- Trend Monitoring: Reputation growth +5/month, Ethical decisions positive impact, Long-term improvement with pattern identification
- Strategic Options: High reputation unlocks alliances, Ethical standing enables special missions, Diplomacy enhanced
- Recovery Planning: Minor reputation damage identified, Improvement strategy implemented, Full recovery projected

### Resource Flow Analysis
- Movement Tracking: Resources transferred 500 tons, Allocation efficiency 85%, Distribution optimized with transfer logging
- Consumption Patterns: Monthly usage 300 tons, Efficiency rating 92%, Waste reduction 15% with consumption breakdown
- Production Monitoring: Output capacity 400 tons/month, Utilization 75%, Expansion potential identified with top producer ranking
- Distribution Networks: Supply chain efficiency 88%, Bottleneck locations mapped, Optimization opportunities with overflow events
- Strategic Allocation: Resource distribution balanced, Critical needs met, Future planning supported with storage tracking
- Optimization Results: Efficiency improvements +10%, Cost savings $50K/month, Strategic advantage gained with shortage alerts

### Maintenance and Upkeep Auditing
- Facility Management: 12 facilities maintained, 2 repairs needed, Budget utilization 75%, Health status good with offline tracking
- Equipment Servicing: 25 craft serviced, 5 maintenance overdue, Readiness rating 85%, Critical systems monitored with backlog data
- Personnel Costs: Monthly salaries $1.2M, Training budget $200K, Retention rate 95%, Morale assessment positive
- Preventive Maintenance: Scheduled servicing completed 90%, Failure prevention successful, Downtime minimized with power monitoring
- Cost Optimization: Maintenance efficiency +15%, Budget savings $100K/month, Lifecycle planning implemented
- Strategic Planning: Long-term maintenance scheduled, Capital improvements planned, Operational continuity assured

### Forces Summary Analytics
- Unit Inventory: 150 soldiers active, 25 in training, 5 casualties, Total strength 180 personnel with wounded/recovery counts
- Readiness Evaluation: Combat readiness 88%, Deployment capability 95%, Training completion 80% with wounded-days tracking
- Training Status: Basic training complete 100%, Advanced skills 75%, Specialist training 60% with proficiency distribution
- Equipment Condition: Weapons serviceable 92%, Vehicles operational 85%, Critical systems monitored with maintenance state
- Deployment Tracking: 20 units deployed, 130 base defense, 30 reserve, Strategic positioning maintained with location monitoring
- Capability Assessment: Combat effectiveness high, Strategic value significant, Expansion capacity available with status breakdown

### Missions Summary Frameworks
- Operation Tracking: 15 missions completed, Success rate 80%, Average duration 5 days, Resource utilization efficient with type counts
- Success Metrics: Primary objectives 85% success, Secondary goals 70%, Casualty rate 5%, Performance rating good with outcome tracking
- Resource Utilization: Budget efficiency 90%, Personnel utilization 75%, Equipment effectiveness 85% with cost analysis
- Pattern Recognition: Urban missions 75% success, Rural operations 85% success, Night operations 65% success with trend identification
- Risk Assessment: Average difficulty rating 6/10, Casualty trends stable, Safety improvements identified with detection statistics
- Strategic Learning: Tactical improvements implemented, Training adjustments made, Operational effectiveness enhanced

### Diagnostics and Bottleneck Analysis
- Performance Monitoring: System efficiency 85%, Processing capacity adequate, Optimization opportunities identified with bottleneck ranking
- Constraint Analysis: Personnel bottleneck (recruitment limited), Equipment shortage (production delayed), Resource allocation optimized
- Optimization Recommendations: Recruitment expansion suggested, Production acceleration recommended, Training program enhancement
- Predictive Modeling: Future constraints forecasted, Capacity planning initiated, Strategic adjustments planned with correlation hints
- System Health: Overall campaign health good, Critical issues none, Sustainability rating high with provenance drilldowns
- Intervention Planning: Minor adjustments needed, Major interventions unnecessary, Continuous improvement focus

## Related Wiki Pages

- [Finance.md](../finance/Finance.md) - Financial reporting and funding systems.
- [Score.md](../finance/Score.md) - Score and performance metrics.
- [Fame.md](../organization/Fame.md) - Fame assessment and tracking.
- [Karma.md](../organization/Karma.md) - Karma evaluation systems.
- [Economy.md](../economy/Economy.md) - Economic analytics and resource flow.
- [Basescape.md](../basescape/Basescape.md) - Base-level reporting and management.
- [Calendar.md](../lore/Calendar.md) - Monthly timing and scheduling.
- [Modding.md](../technical/Modding.md) - Report customization and telemetry.

## References to Existing Games and Mechanics

- **Civilization Series**: End-of-turn reports and civilization statistics
- **Crusader Kings Series**: Chronicle systems and historical records
- **Europa Universalis Series**: Detailed ledger and economic statistics
- **Hearts of Iron Series**: War statistics and military reports
- **Victoria Series**: Economic and population census reports
- **Stellaris**: Empire reports and galactic statistics
- **Total War Series**: Campaign statistics and battle reports
- **XCOM Series**: Monthly council reports and performance reviews
- **Fire Emblem Series**: Chapter summaries and character progression
- **Final Fantasy Series**: Quest logs and adventure summaries

