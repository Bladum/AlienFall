# Salaries

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Payment Timing and Processing](#payment-timing-and-processing)
  - [Base Salary Model](#base-salary-model)
  - [Rank Multipliers and Progression](#rank-multipliers-and-progression)
  - [Modifier System](#modifier-system)
  - [Non-Payment Consequences](#non-payment-consequences)
  - [Cost Optimization](#cost-optimization)
  - [Performance Bonuses](#performance-bonuses)
  - [UI Reporting and Transparency](#ui-reporting-and-transparency)
  - [Deterministic Calculation and Modding](#deterministic-calculation-and-modding)
- [Examples](#examples)
  - [Basic Salary Calculation](#basic-salary-calculation)
  - [Payment Processing Cycle](#payment-processing-cycle)
  - [Cost Optimization Strategy](#cost-optimization-strategy)
  - [Performance Bonus Application](#performance-bonus-application)
  - [Non-Payment Consequences](#non-payment-consequences)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview
The Salaries system manages periodic personnel costs, processing monthly payments that determine unit operational status for the upcoming month. Salaries create economic pressure through deterministic calculations combining rank-based multipliers, class-specific rates, and configurable modifiers from equipment, traits, and transformations. Non-payment produces morale penalties, availability restrictions, and karma impacts, with transparent UI showing forecasts, breakdowns, and consequences.

The system supports manual overrides for special contracts, data-driven modifier composition, and comprehensive provenance tracking. All salary parameters are configurable without code changes, enabling campaign pacing tuning and extensive modding support. Monthly processing occurs on turn boundaries with clear payment windows and batch processing for fairness.

## Mechanics
### Payment Timing and Processing
Salaries are calculated and deducted monthly, marking units operational for the period. Processing occurs simultaneously for all units with configurable payment windows. Unpaid units become non-operational with accumulating penalties. The system provides hooks for integration and automation, logging all payment events for provenance.

### Base Salary Model
Each unit class defines base salary rates, potentially overriding rank-based defaults. Manual per-unit overrides support special contracts and mercenary agreements. Base salaries establish economic foundation with class-specific pricing reflecting specialization value.

### Rank Multipliers and Progression
Higher ranks command increased compensation through progressive multipliers. Rank 0 (recruit) receives base salary, with linear scaling up to maximum caps. Multipliers reflect seniority value while maintaining predictable budgeting.

### Modifier System
Equipment, traits, and transformations adjust salaries through additive and multiplicative modifiers. Loyalty traits provide discounts, augmentations add surcharges, and specialized gear increases costs. Modifiers compose deterministically with configurable combiner policies.

### Non-Payment Consequences
Unpaid salaries trigger morale reductions, operational restrictions, and karma penalties. Units lose deployment capability, face desertion risks, and affect recruitment difficulty. Grace periods allow recovery before severe penalties apply.

### Cost Optimization
Facilities and research provide salary reductions. Barracks offer basic discounts, officer quarters provide advanced savings, and personnel offices enable maximum efficiency. Research unlocks additional reductions, with multiple facilities and technologies compounding benefits.

### Performance Bonuses
Successful missions and achievements provide additional compensation. Mission completion earns base bonuses, objective success adds rewards, and difficulty multipliers balance risk. Achievement bonuses recognize exceptional accomplishments.

### UI Reporting and Transparency
Monthly forecasts show total requirements with per-unit breakdowns. Salary provenance displays base amounts, modifiers, and final calculations. Payment warnings alert insufficient funds, and historical tracking supports trend analysis.

### Deterministic Calculation and Modding
All calculations use seeded processing for reproducibility. Salary parameters are data-driven, supporting extensive modding. Custom modifiers, override mechanisms, and API integration enable community extensions.

## Examples
### Basic Salary Calculation
Sergeant sniper with rank 3 multiplier (400% of base), class-specific rate, cybernetic augmentation (+15%), and loyalty trait (-10%) yields final salary = base × 4.0 × 1.05 = 420% of base salary, with UI showing complete modifier breakdown.

### Payment Processing Cycle
Monthly tick deducts total salaries from base funds. Paid units maintain full morale and availability. Unpaid units face immediate morale penalty (-10), lose deployment capability, and accumulate overdue amounts with karma reduction.

### Cost Optimization Strategy
Player constructs barracks (10% reduction) and officer quarters (15% additional), then researches personnel management (15% reduction). Combined effects create 35.75% total salary savings across all units.

### Performance Bonus Application
Unit completing 20 missions with 50 kills and 3 medals earns 200 mission bonus + 100 kill bonus + 30 medal bonus = 330 performance pay, displayed separately from base salary in monthly reports.

### Non-Payment Consequences
Unpaid unit suffers morale reduction (-5 per unpaid month), loses deployment eligibility, and contributes to recruitment difficulty. After 3 months unpaid, desertion risk increases with potential unit loss.

## Related Wiki Pages

- [Finance.md](../finance/Finance.md) - Financial systems and budget management
- [Ranks.md](../units/Ranks.md) - Rank multipliers and progression costs
- [Classes.md](../units/Classes.md) - Class-specific salary structures
- [Morale.md](../battlescape/Morale.md) - Morale effects and performance bonuses
- [Basescape.md](../basescape/Basescape.md) - Base operations and facility costs
- [Research tree.md](../economy/Research%20tree.md) - Research bonuses and cost reductions
- [Karma.md](../organization/Karma.md) - Reputation effects on salaries
- [Company.md](../organization/Company.md) - Organization costs and management
- [Economy.md](../economy/Economy.md) - Economic integration and resource allocation
- [Geoscape.md](../geoscape/Geoscape.md) - Strategic costs and campaign management

## References to Existing Games and Mechanics

- **X-COM Series**: Monthly salary payments and unit maintenance costs
- **Civilization Series**: Unit maintenance and gold costs
- **Crusader Kings III**: Court costs and character maintenance
- **Europa Universalis IV**: Army maintenance and administrative costs
- **Total War Series**: Unit upkeep and recruitment costs
- **Stellaris**: Population costs and empire maintenance
- **Victoria Series**: Population wages and industrial costs
- **Hearts of Iron Series**: Army costs and mobilization expenses
- **Supreme Commander**: Unit production and maintenance costs
- **Company of Heroes**: Squad costs and reinforcement expenses

