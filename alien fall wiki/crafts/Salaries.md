# Craft Salaries

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Base Salary Structure](#base-salary-structure)
  - [Rank Bonuses](#rank-bonuses)
  - [Equipment Modifiers](#equipment-modifiers)
  - [Trait Effects](#trait-effects)
  - [Maintenance Costs](#maintenance-costs)
  - [Salary Calculation](#salary-calculation)
  - [Monthly Processing](#monthly-processing)
  - [Payment Consequences](#payment-consequences)
  - [Cost Optimization](#cost-optimization)
- [Examples](#examples)
  - [Fighter Salaries](#fighter-salaries)
    - [Light Interceptor (Rank I)](#light-interceptor-rank-i)
    - [Veteran Interceptor (Rank III)](#veteran-interceptor-rank-iii)
    - [Elite Interceptor (Rank V)](#elite-interceptor-rank-v)
  - [Bomber Salaries](#bomber-salaries)
    - [Standard Bomber (Rank I)](#standard-bomber-rank-i)
    - [Experienced Bomber (Rank III)](#experienced-bomber-rank-iii)
    - [Elite Bomber (Rank V)](#elite-bomber-rank-v)
  - [Transport Salaries](#transport-salaries)
    - [Basic Transport (Rank I)](#basic-transport-rank-i)
    - [Reliable Transport (Rank III)](#reliable-transport-rank-iii)
    - [Veteran Transport (Rank V)](#veteran-transport-rank-v)
  - [Salary Calculation Examples](#salary-calculation-examples)
    - [Standard Calculation](#standard-calculation)
    - [With Rank Progression](#with-rank-progression)
    - [Complex Loadout with Traits](#complex-loadout-with-traits)
  - [Cost Optimization Strategies](#cost-optimization-strategies)
    - [Budget-Conscious Fighter Fleet](#budget-conscious-fighter-fleet)
    - [High-Performance Elite Squadron](#high-performance-elite-squadron)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The craft salaries system implements a comprehensive compensation framework that creates ongoing operational costs for maintaining craft fleets. Each craft requires monthly salary payments that vary based on craft type, promotion rank, equipment loadout, and special traits. The system forces strategic decisions about fleet composition, roster size, and resource allocation while providing predictable recurring costs that shape long-term campaign planning. Deterministic processing with complete provenance tracking ensures reproducible economic outcomes for balance testing and modding support.

The framework creates rhythmic decision points at monthly boundaries, forcing players to balance short-term obligations against long-term investment in craft and personnel, with clear consequences for non-payment and extensive data-driven customization options.

## Mechanics

### Base Salary Structure

Fundamental compensation based on craft classification with predictable foundations:

- Craft Type Base: Core salary determined by craft role, size, and operational requirements
- Class Categories: Fighters, bombers, transports, and scouts with appropriately scaled costs
- Size Scaling: Larger craft require proportionally higher salaries for crew and maintenance
- Role Expectations: Combat craft cost more than utility craft due to operational demands
- Base Consistency: Predictable costs enabling strategic planning and budget forecasting

### Rank Bonuses

Promotion-based salary increases recognizing experience and capability:

- Veterancy Pay: Higher ranks receive increased compensation for demonstrated performance
- Performance Recognition: Bonuses for successful mission completion and survival
- Retention Incentives: Higher pay encourages maintaining experienced craft assets
- Progressive Increases: Modest percentage raises per rank preventing excessive cost growth
- Maximum Caps: Salary growth limited to maintain economic balance and accessibility

### Equipment Modifiers

Loadout-based cost adjustments reflecting maintenance complexity:

- Advanced Equipment: High-tech items increase maintenance and calibration requirements
- Heavy Weapons: Powerful armaments require specialized upkeep and spare parts
- Utility Systems: Support equipment adds to operational and supply chain costs
- Modification Impact: Customizations and transformations affect salary calculations
- Cost Scaling: Equipment complexity and rarity influence maintenance expenses

### Trait Effects

Special characteristic cost modifiers affecting compensation structures:

- Loyalty Discounts: Reliable craft with proven service receive salary reductions
- Enhancement Costs: Cybernetic and augmented systems increase maintenance expenses
- Maintenance Requirements: Complex traits demand higher upkeep and specialized care
- Special Contracts: Unique arrangements and bonded agreements modify standard costs
- Biological vs Mechanical: Different cost structures for crewed versus automated craft

### Maintenance Costs

Ongoing operational expenses separate from base salaries:

- Base Maintenance: Fixed costs for basic craft upkeep and readiness
- Equipment Maintenance: Additional costs for mounted systems and modifications
- Wear and Tear: Usage-based maintenance requirements from operational deployment
- Depot Fees: Storage, hangar, and readiness maintenance costs
- Supply Chain: Parts, consumables, and logistics expenses for sustained operations

### Salary Calculation

Comprehensive compensation formula with deterministic processing:

Total Salary = (Base Salary × Rank Multiplier × Equipment Modifier × Trait Modifier) + Performance Bonus + Hazard Pay + Maintenance Cost

- Base Salary: Craft type and size foundation with class-specific overrides available
- Rank Multiplier: Promotion-based percentage increases for veterancy recognition
- Equipment Modifier: Loadout complexity adjustments with additive/multiplicative options
- Trait Modifier: Special characteristic effects including discounts and penalties
- Performance Bonus: Mission success incentives and achievement rewards
- Hazard Pay: Dangerous operation compensation for high-risk deployments
- Maintenance Cost: Fixed operational expenses computed deterministically

### Monthly Processing

Regular compensation cycle with predictable timing and consequences:

- Month Boundary: Salary calculations and deductions occur at monthly transitions
- Advance Payment: Salaries paid for upcoming month of service and operational readiness
- Batch Processing: All craft salaries calculated simultaneously with seeded randomization
- Budget Verification: Total costs checked against available funds with payment prioritization
- Payment Recording: Complete transaction history and provenance maintained for auditing

### Payment Consequences

Results of insufficient funds with clear operational impacts:

- Non-Operational Status: Unpaid craft cannot be deployed or participate in missions
- Morale Impacts: Crew dissatisfaction affects performance and retention
- Auto-Sell Rules: Extreme cases may force craft disposal or decommissioning
- Grace Periods: Limited time windows to resolve payment issues and restore capability
- Recovery Options: Methods to restore operational status through emergency funding

### Cost Optimization

Strategies to reduce expenses and improve budget efficiency:

- Equipment Choices: Selecting cost-effective loadouts and avoiding expensive modifications
- Trait Selection: Choosing economical characteristics and avoiding high-maintenance traits
- Maintenance Scheduling: Optimizing upkeep timing and preventive maintenance programs
- Bulk Discounts: Volume purchasing benefits for large fleets and standardized equipment
- Efficiency Programs: Operational improvements and training reducing maintenance requirements

## Examples

### Fighter Salaries

#### Light Interceptor (Rank I)
- Base Salary: $200/month
- Maintenance Cost: $50/month
- Total Monthly: $250/month
- Equipment Load: Basic weapons, no modifiers
- Typical Use: Patrol and basic interception duties

#### Veteran Interceptor (Rank III)
- Base Salary: $220/month (+10% rank bonus)
- Maintenance Cost: $60/month
- Heavy Laser Modifier: +25% equipment upkeep ($55/month)
- Total Monthly: $335/month
- Equipment Load: Advanced weapons and targeting systems

#### Elite Interceptor (Rank V)
- Base Salary: $240/month (+20% rank bonus)
- Maintenance Cost: $70/month
- Advanced Equipment: +40% modifier ($136/month)
- Loyalty Discount: -10% trait reduction ($-33.50/month)
- Total Monthly: $412.50/month
- Equipment Load: Elite systems and performance modifications

### Bomber Salaries

#### Standard Bomber (Rank I)
- Base Salary: $400/month
- Maintenance Cost: $100/month
- Total Monthly: $500/month
- Equipment Load: Basic bombing systems and ordnance
- Typical Use: Ground attack and area denial missions

#### Experienced Bomber (Rank III)
- Base Salary: $440/month (+10% rank bonus)
- Maintenance Cost: $120/month
- Heavy Payload Modifier: +30% equipment upkeep ($187.20/month)
- Total Monthly: $747.20/month
- Equipment Load: Advanced ordnance and delivery systems

#### Elite Bomber (Rank V)
- Base Salary: $480/month (+20% rank bonus)
- Maintenance Cost: $140/month
- Precision Equipment: +35% modifier ($285.60/month)
- Reinforced Hull: +20% trait cost ($153.60/month)
- Total Monthly: $1,059.20/month
- Equipment Load: Strategic bombing and precision strike capabilities

### Transport Salaries

#### Basic Transport (Rank I)
- Base Salary: $150/month
- Maintenance Cost: $75/month
- Total Monthly: $225/month
- Equipment Load: Standard cargo systems and basic defenses
- Typical Use: Logistics and routine troop transport operations

#### Reliable Transport (Rank III)
- Base Salary: $165/month (+10% rank bonus)
- Maintenance Cost: $90/month
- Expanded Cargo: +15% equipment modifier ($37.35/month)
- Total Monthly: $292.35/month
- Equipment Load: Enhanced carrying capacity and reliability systems

#### Veteran Transport (Rank V)
- Base Salary: $180/month (+20% rank bonus)
- Maintenance Cost: $105/month
- Heavy Duty Systems: +25% modifier ($71.25/month)
- Bonded Crew: -30% trait discount ($-43.05/month)
- Total Monthly: $313.20/month
- Equipment Load: Elite logistics and heavy-lift capabilities

### Salary Calculation Examples

#### Standard Calculation
Light Interceptor (Rank I, Basic Loadout)  
Base: $200 + Maintenance: $50 = $250/month

#### With Rank Progression
Veteran Interceptor (Rank III, Advanced Equipment)  
Base: $200 × 1.1 (rank) = $220  
Equipment: $220 × 1.25 (heavy laser) = $275  
Maintenance: $60  
Total: $275 + $60 = $335/month

#### Complex Loadout with Traits
Elite Interceptor (Rank V, Elite Systems, Loyal Crew)  
Base: $200 × 1.2 (rank) = $240  
Equipment: $240 × 1.4 (advanced systems) = $336  
Trait: $336 × 0.9 (loyalty discount) = $302.40  
Maintenance: $70  
Total: $302.40 + $70 = $372.40/month

### Cost Optimization Strategies

#### Budget-Conscious Fighter Fleet
- Standard Loadouts: Avoid expensive modifications, use basic equipment
- Early Rank Focus: Maintain lower ranks to minimize salary growth
- Loyalty Cultivation: Develop traits that provide salary discounts
- Maintenance Scheduling: Regular upkeep preventing costly repairs

#### High-Performance Elite Squadron
- Advanced Equipment: Accept higher costs for superior capabilities
- Rank Investment: Promote craft for performance bonuses despite salary increases
- Efficiency Traits: Select modifications that provide capability without excessive upkeep
- Bulk Procurement: Volume discounts on standardized equipment and supplies

## Related Wiki Pages

- [Classes.md](../crafts/Classes.md) - Craft class salary ranges
- [Promotion.md](../crafts/Promotion.md) - Rank progression and salary increases
- [Items.md](../items/Items.md) - Equipment modifiers on salaries
- [Stats.md](../crafts/Stats.md) - Craft performance and salary correlation
- [Crafts.md](../crafts/Crafts.md) - Main craft systems overview
- [Monthly reports.md](../finance/Monthly%20reports.md) - Salary cost reporting
- [Funding.md](../finance/Funding.md) - Salary funding requirements
- [Salaries.md](../units/Salaries.md) - Unit salary systems comparison

## References to Existing Games and Mechanics

- **XCOM Series**: Craft maintenance and operational costs
- **Civilization Series**: Unit maintenance costs
- **Europa Universalis**: Naval maintenance and crew costs
- **Crusader Kings**: Army maintenance and levy costs
- **Hearts of Iron**: Fleet and air unit maintenance
- **Victoria Series**: Military maintenance costs
- **Stellaris**: Fleet maintenance and crew costs
- **Endless Space**: Fleet maintenance expenses
- **Galactic Civilizations**: Ship maintenance costs
- **Total War Series**: Army maintenance and upkeep

