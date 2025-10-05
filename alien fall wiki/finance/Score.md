# Score

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Scope and Aggregation Architecture](#scope-and-aggregation-architecture)
  - [Monthly Funding Pipeline Systems](#monthly-funding-pipeline-systems)
  - [Visibility and Determinism Frameworks](#visibility-and-determinism-frameworks)
  - [Player Guidance and Systemic Integration](#player-guidance-and-systemic-integration)
  - [Processing and Calculation Systems](#processing-and-calculation-systems)
  - [Relationship to Other Metrics](#relationship-to-other-metrics)
- [Examples](#examples)
  - [Scope and Aggregation Scenarios](#scope-and-aggregation-scenarios)
  - [Monthly Funding Pipeline Cases](#monthly-funding-pipeline-cases)
  - [Visibility and Determinism Examples](#visibility-and-determinism-examples)
  - [Player Guidance Scenarios](#player-guidance-scenarios)
  - [Processing and Calculation Cases](#processing-and-calculation-cases)
  - [Relationship Integration Examples](#relationship-integration-examples)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Score system establishes comprehensive performance evaluation frameworks for Alien Fall's strategic gameplay, implementing province-level metrics that influence government funding and diplomatic relations. The system creates meaningful strategic incentives through public visibility mechanics, deterministic scoring, and regional aggregation while maintaining transparency and player agency. The framework balances performance tracking with recovery opportunities, enabling players to understand the consequences of their actions and make informed strategic decisions about base placement, mission selection, and public relations management.

Score represents public safety and economic stability rather than morality, linking visible player actions to political support and funding outcomes. It drives regional funding, events, and diplomatic responses while remaining deterministic and tied to visible events.

## Mechanics

### Scope and Aggregation Architecture

Score tracking creates regional performance incentives:
- Province-Level Tracking: Localized performance measurement and regional assessment
- Country Aggregation: Provincial score combination and national performance calculation (default: sum or configurable aggregation)
- Visibility Requirements: Public knowledge criteria for score modification
- Deterministic Processing: Predictable score calculation and reproducible outcomes
- Regional Strategy Integration: Geographic performance influence on funding allocation
- Multi-Level Analysis: Individual province and aggregate country performance evaluation

### Monthly Funding Pipeline Systems

Monthly processing converts performance to economic support:
- Score Aggregation: Provincial performance consolidation and national total calculation
- Monthly Points Generation: Score conversion using formula (MonthlyPoints = floor(CountryTotalScore / 250))
- Funding Level Derivation: Performance-based financial support calculation with 0-100 clamping
- Payment Distribution: Economic allocation using Funding = FundingLevel × CountryEconomyValue × 1000
- Non-Linear Mapping: Advanced scoring curves, hysteresis, and smoothing to prevent extreme swings
- Economic Impact Assessment: Financial consequence evaluation and strategic pressure

### Visibility and Determinism Frameworks

Public perception drives score changes through transparent mechanics:
- Public Action Tracking: Visible event monitoring and score modification triggers
- Covert Action Handling: Secret operation score immunity with potential retroactive exposure
- Retroactive Adjustment: Delayed revelation processing and historical score correction
- Deterministic Rules: Predictable scoring outcomes and reproducible simulation
- Data-Driven Configuration: Configurable thresholds and moddable scoring parameters
- Balance Testing Support: Consistent outcomes for design validation and tuning

### Player Guidance and Systemic Integration

Score creates incentives for public safety and strategic decision-making:
- Protection Incentives: Public safety and infrastructure defense reward systems
- Strategic Pressure Creation: Economic consequences for poor performance without immediate failure
- Recovery Opportunity Framework: Performance improvement pathways and incentives
- Long-Term Planning Tools: Score trend analysis and strategic adjustment guidance
- Campaign Pacing Control: Performance-based difficulty scaling and challenge adjustment
- Narrative Integration: Story consequence linkage and character development influence

### Processing and Calculation Systems

Systematic monthly processing ensures reliable outcomes:
- Monthly Computation Sequence: Aggregate province scores → compute country totals → derive funding levels
- Event Processing Integration: Real-time score modification and batch monthly processing
- Special Event Handling: Narrative overrides, treaties, and exceptional circumstance management
- Configuration Flexibility: Data-driven parameter adjustment and modding support
- Validation Mechanisms: Score calculation verification and error detection
- Performance Monitoring: Processing efficiency tracking and optimization analysis

### Relationship to Other Metrics

Score maintains distinct but related roles with other reputation systems:
- Funding Level Connection: Direct economic impact through MonthlyPoints → FundingLevel conversion
- Karma Distinction: Ethical behavior separation (Karma tracks morality, Score tracks public safety)
- Fame Independence: Public awareness decoupling (Fame measures visibility, Score measures outcomes)
- Multi-System Synergy: Interdependent mechanic coordination and strategic depth creation
- Cross-System Effects: Performance metric interaction and compound consequence generation
- Strategic Trade-off Design: Competing objective balancing and decision complexity

## Examples

### Scope and Aggregation Scenarios
- Province Performance: Urban province score +150, Rural province score +75, Total country score +225
- Regional Distribution: High-protection provinces +200 each, Low-protection provinces +50 each, Balanced national average
- Visibility Impact: Public interception success +100 score, Covert operation no score change, Exposed secret -50 score
- Aggregation Methods: Sum aggregation (total 500), Average aggregation (mean 75), Weighted aggregation (population-based)
- Country Totals: Large economy country (score 400, population 100M), Small economy country (score 300, population 10M)
- Strategic Placement: Base in high-score province (+50 bonus), Base in low-score province (-25 penalty)

### Monthly Funding Pipeline Cases
- Score Aggregation: 10 provinces × average score 80 = Country total 800, Monthly points 3 (800/250)
- Funding Derivation: Monthly points 3, Funding level 75 (scaled 0-100), Economic multiplier 1.5x
- Payment Calculation: Funding level 75 × Economy 50 × Base 1000 = $3,750,000 monthly allocation
- Non-Linear Mapping: Score 900 (points 3.6) → Funding 82, Score 950 (points 3.8) → Funding 85, Diminishing returns
- Hysteresis Prevention: Score fluctuation ±50 points, Funding stability maintained, Extreme swing protection
- Economic Impact: High score period (+$500K bonus), Low score period (-$300K penalty), Recovery incentives

### Visibility and Determinism Examples
- Public Action Scoring: Civilian rescue mission +150 score, Infrastructure protection +100 score, Public visibility confirmed
- Covert Operation Handling: Secret base attack (no immediate score change), Intelligence leak (-75 score retroactive)
- Retroactive Adjustment: Hidden operation exposed after 3 months, Score reduction applied, Funding recalculation triggered
- Deterministic Rules: Identical actions, identical scores, Reproducible outcomes, Balance testing enabled
- Data Configuration: Score values in TOML files, Modder customization, Designer tuning capability
- Balance Validation: Consistent scoring verified, Edge cases tested, Unintended consequences identified

### Player Guidance Scenarios
- Protection Incentives: Civilian safety priority (+200 score potential), Infrastructure defense (+150 score potential)
- Strategic Pressure: Low score period (funding reduced 30%), Recovery mission opportunities, Economic challenge
- Recovery Framework: Score improvement campaign (+100 points target), Bonus funding unlocked, Strategic incentives
- Long-Term Planning: Score trend analysis (6-month projection), Base placement optimization, Regional strategy development
- Campaign Pacing: Early game protection focus, Mid-game expansion pressure, Late-game consolidation requirements
- Narrative Integration: High score story branches, Low score consequence events, Character relationship development

### Processing and Calculation Cases
- Monthly Sequence: Day 1 processing, Province aggregation completed, Country totals calculated, Funding levels determined
- Event Integration: Real-time score updates, Batch processing monthly, Exception handling for special events
- Special Events: Diplomatic treaty (+50 score override), Natural disaster (score protection bonus), Narrative milestone
- Configuration Flexibility: TOML parameter adjustment, Mod compatibility ensured, Designer iteration support
- Validation Systems: Score calculation checksums, Error detection algorithms, Data integrity verification
- Performance Tracking: Processing time monitoring, Optimization opportunities, Efficiency improvements

### Relationship Integration Examples
- Funding Connection: Score 400 → Funding level 80 → Monthly payment $4M, Direct economic correlation
- Karma Distinction: Ethical choice (karma +20), Public safety impact (score +50), Separate system tracking
- Fame Independence: High publicity mission (fame +30), Score impact depends on outcome, Decoupled mechanics
- Multi-System Synergy: High score + high karma (elite mission access), Low score + low fame (limited options)
- Cross-System Effects: Score improvement (funding bonus), Karma alignment (supplier access), Compound benefits
- Strategic Trade-offs: Public mission (score +75, fame +25) vs Covert mission (score unchanged, fame -10)

## Related Wiki Pages

- [Finance.md](../finance/Finance.md) - Funding and payment systems.
- [Economy.md](../economy/Economy.md) - Economic performance metrics.
- [Geoscape.md](../geoscape/Geoscape.md) - Regional score effects.
- [Suppliers.md](../economy/Suppliers.md) - Diplomatic relations and funding.
- [Fame.md](../organization/Fame.md) - Public relations and visibility.
- [Karma.md](../organization/Karma.md) - Ethical vs public distinction.
- [Mission.md](../lore/Mission.md) - Mission score impacts.
- [Event.md](../lore/Event.md) - Score-based events and triggers.

## References to Existing Games and Mechanics

- **XCOM Series**: Council funding based on mission performance and public perception
- **Civilization Series**: Diplomatic relations and reputation with other civilizations
- **Crusader Kings Series**: Prestige and reputation systems affecting alliances
- **Europa Universalis Series**: Stability and national reputation mechanics
- **Total War Series**: Public order and faction reputation systems
- **Stellaris**: Ethics and diplomatic relations with alien empires
- **Hearts of Iron Series**: National unity and war support mechanics
- **Victoria Series**: Public opinion and political reform systems
- **Fire Emblem Series**: Renown and reputation affecting recruitment
- **Final Fantasy Series**: Fame and reputation systems for quests

