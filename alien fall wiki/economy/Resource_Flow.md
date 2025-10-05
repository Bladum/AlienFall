# Resource Flow

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Monthly Economic Cycle](#monthly-economic-cycle)
  - [Income System Framework](#income-system-framework)
  - [Storage and Capacity Management](#storage-and-capacity-management)
  - [Expenditure and Cost Tracking](#expenditure-and-cost-tracking)
  - [Budget Forecasting and Planning](#budget-forecasting-and-planning)
  - [Financial Crisis Management](#financial-crisis-management)
- [Examples](#examples)
  - [Council Funding Scenarios](#council-funding-scenarios)
  - [Item Sales Examples](#item-sales-examples)
  - [Mission Reward Calculations](#mission-reward-calculations)
  - [Storage Overflow Cases](#storage-overflow-cases)
  - [Budget Planning Scenarios](#budget-planning-scenarios)
  - [Financial Crisis Progressions](#financial-crisis-progressions)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Resource Flow System establishes comprehensive financial and material resource management throughout Alien Fall's campaign progression, tracking income sources, storage capacity, and expenditure patterns through deterministic monthly cycles and event-driven transactions. Operating on fixed monthly economic cycles with storage capacity constraints and debt tolerance thresholds, the system creates transparent budgeting frameworks that reward strategic planning while triggering crisis events for sustained financial mismanagement. All resource flows integrate with research, manufacturing, base management, and mission systems to create interconnected economic pressure across strategic and operational scales, with deterministic calculations supporting reproducible campaigns and mod balance validation.

## Mechanics

### Monthly Economic Cycle

Deterministic financial processing framework operating on monthly boundaries:

- Cycle Timing: Financial calculations execute on the 1st of each month with consistent processing order
- Income Aggregation: Council funding, item sales, mission rewards, and interest income accumulated
- Expense Calculation: Personnel salaries (40% typical budget), facility maintenance (30%), manufacturing costs (20%), miscellaneous (10%)
- Debt Management: Outstanding debt deductions with interest applied before net calculation
- Balance Update: Surplus added to reserves generating interest, deficits converted to debt or asset liquidation
- Monthly Reporting: Comprehensive financial summaries with income/expense breakdowns and net position
- Crisis Triggers: Three consecutive deficit months trigger game-over financial crisis condition

### Income System Framework

Multiple revenue streams with performance-based modifiers:

- Council Funding: Primary income source ($6M baseline) modified by country satisfaction, panic levels, and satellite coverage
- Performance Bonuses: Mission success rates, UFO shootdowns, and alien base destruction adding up to +20% ($1.2M)
- Loss Penalties: Country withdrawals, failed missions, civilian casualties reducing funding by up to -30% ($1.8M)
- Item Sales: Alien corpses ($5K-$50K), artifacts ($10K-$500K), UFO components ($20K-$1M), manufactured goods (cost + 50% markup)
- Mission Rewards: UFO shootdowns ($10K-$100K), terror missions ($50K + civilian bonuses), alien bases ($200K), council missions ($100K-$500K)
- Reserve Interest: Positive balance reserves generating small monthly interest income
- Market Demand: Rarity-based pricing multipliers (common 1.0x, uncommon 1.2x, rare 1.5x, very rare 2.0x, unique 3.0x)
- Age Depreciation: Alien corpses lose value over time (1% per day stored, minimum 50% value retention)

### Storage and Capacity Management

Facility-based storage with category-specific capacity constraints:

- General Storage: 50 item capacity per facility for weapons, armor, equipment, corpses, and artifacts
- Material Storage: 50 unit capacity per facility for strategic resources (Elerium, Alloys, Meld, Fragments)
- Material Limits: Individual material type cap at 999 units regardless of facility capacity
- Overflow Handling: Automatic loss of excess items/materials when capacity exceeded during mission returns
- Capacity Validation: Real-time checks preventing storage transactions exceeding limits
- UI Warnings: Player notifications when significant value lost ($10K+) due to storage overflow
- Strategic Planning: Storage capacity considerations influencing facility construction priorities
- Category Organization: Separate storage tracking for weapons, armor, equipment, corpses, and artifacts

### Expenditure and Cost Tracking

Comprehensive expense framework with recurring and one-time costs:

- Monthly Salaries: Soldier wages ($40K baseline, rank multipliers 1.0x-4.0x), scientist pay ($30K), engineer wages ($25K)
- Maintenance Costs: Base upkeep ($100K per base), craft maintenance ($50K per craft), facility power ($5K per powered facility)
- Construction Expenses: Facility builds ($100K-$2M upfront), one-time construction costs with no refunds
- Research Funding: Project initialization costs ($50K-$500K), upfront payment before research begins
- Manufacturing Costs: Material consumption, engineering labor, facility operational expenses
- Operational Expenses: Craft launch costs ($1K-$5K), fuel refueling ($500/unit), repairs ($100/HP), item repairs (20% of cost)
- Transaction Logging: Complete audit trail with timestamps, amounts, categories, and associated resources
- Expense Categories: Clear breakdown into salaries (30%), maintenance (20%), construction (15%), research (10%), manufacturing (20%), operations (5%)

### Budget Forecasting and Planning

Deterministic projection tools for strategic financial planning:

- Multi-Month Projections: Forecast 1-12 months ahead with income/expense estimates
- Income Estimation: Council funding trends, projected sales revenue, anticipated mission rewards
- Expense Projections: Salary obligations, maintenance schedules, planned construction, research timelines
- Net Position Tracking: Monthly surplus/deficit calculations with cumulative balance projections
- Deficit Warnings: Automatic alerts when projections indicate negative balance months
- Optimization Tools: UI support for evaluating construction timing, research prioritization, staffing adjustments
- Strategic Decision Support: Clear visibility into long-term financial sustainability
- Scenario Planning: "What-if" analysis for major expenditure decisions (new base, advanced craft, facility expansion)

### Financial Crisis Management

Escalating consequence framework for sustained deficits:

- Debt Tolerance: Two-month grace period allowing temporary negative balance without crisis
- Crisis Progression: First deficit month triggers warning, second month final warning, third month game over
- Warning System: Progressive UI notifications with increasing severity (medium → high → critical)
- Balance Recovery: Returning to positive balance resets crisis counter to zero
- Game Over Condition: Three consecutive deficit months terminates campaign with council disbandment
- Victory Conditions: Twelve consecutive positive months + $10M net worth triggers economic victory
- Net Worth Calculation: Cash + item values + material values + facility resale (50%) + craft resale (60%)
- Crisis Telemetry: Complete tracking of deficit months, warning triggers, and recovery events

## Examples

### Council Funding Scenarios

**Best Performance Campaign**
- Base Funding: $7,200,000 (all 16 countries contributing, no withdrawals)
- Performance Bonus: +20% ($1,440,000) from 10+ successful missions, 10+ UFO shootdowns, 1 alien base destroyed
- Loss Penalty: 0% (no failures or country losses)
- Satellite Coverage: +20% multiplier on 12 countries ($1,728,000 bonus)
- Final Income: $10,368,000 monthly

**Average Performance Campaign**
- Base Funding: $7,200,000 (all countries active)
- Performance Bonus: +5% ($360,000) from moderate mission success
- Loss Penalty: -10% ($720,000) from some failed missions and 1 country lost
- Satellite Coverage: +20% on 6 countries ($720,000 bonus)
- Final Income: $6,480,000 monthly

**Crisis Campaign**
- Base Funding: $5,000,000 (3 countries withdrawn)
- Performance Bonus: 0% (minimal successful missions)
- Loss Penalty: -30% ($1,500,000) from multiple failures and country losses
- Satellite Coverage: +20% on 3 countries ($180,000 bonus)
- Final Income: $2,800,000 monthly (barely covering basic expenses)

### Item Sales Examples

**Alien Corpse Sales**
- Sectoid Corpse (Fresh): $5,000 (0 days stored)
- Sectoid Corpse (Aged): $3,500 (30 days stored, 30% depreciation)
- Muton Corpse (Fresh): $15,000 (high value species)
- Ethereal Corpse: $50,000 (extremely rare, unique research value)
- Corpse Depreciation: 1% per day, minimum 50% retained value

**Artifact and Component Sales**
- Plasma Pistol: $10,000 (common alien weapon)
- Heavy Plasma: $40,000 (advanced alien weapon)
- UFO Power Source: $200,000 (critical research component, very rare 2.0x multiplier)
- UFO Navigation: $150,000 (advanced technology, rare 1.5x multiplier)
- Elerium-115 (10 units): $50,000 (strategic material, high demand)

**Manufactured Item Sales**
- Laser Rifle: $30,000 (production cost $20,000, 50% markup)
- Personal Armor: $60,000 (production cost $40,000, 50% markup)
- Obsolete Ballistic Rifle: $3,000 (original cost $10,000, 30% resale value)

### Mission Reward Calculations

**UFO Crash Site Mission**
- Base Reward: $50,000 (medium UFO)
- Recovered Alien Corpses: 4 Sectoids ($5K each = $20K), 2 Floaters ($8K each = $16K)
- Recovered Weapons: 3 Plasma Rifles (70% recovery rate, $25K each = $75K)
- UFO Components: UFO Power Source ($200K), 15 Elerium units ($75K), 10 Alloy units ($30K)
- Total Mission Value: $466,000

**Terror Mission**
- Base Reward: $50,000
- Civilian Bonus: 12 civilians saved × $1,000 = $12,000
- Recovered Items: 6 alien corpses ($45,000), 4 plasma weapons ($90,000)
- Total Mission Value: $197,000

**Alien Base Assault**
- Base Reward: $200,000 (fixed)
- Strategic Value: Massive material recovery (50+ Elerium, 30+ Alloys = $325,000)
- Alien Commander Corpse: $50,000 (Ethereal)
- Advanced Weapons: 10+ heavy plasma weapons ($400,000+)
- Total Mission Value: $975,000+

### Storage Overflow Cases

**Successful Mission with Full Storage**
- Mission Returns: 12 alien corpses, 8 plasma weapons, 25 Elerium units
- Current Storage: 48/50 general storage, 45/50 material storage
- Overflow Loss: 10 corpses lost ($50,000 value), 15 Elerium lost ($75,000 value)
- UI Warning: "Lost $125,000 worth of items/materials due to insufficient storage!"
- Strategic Lesson: Build additional storage facilities before major operations

**Planned Storage Expansion**
- Pre-Mission Storage: 35/50 general, 30/50 material
- Construction Queue: +1 General Storage facility (50 capacity), +1 Material Storage (50 capacity)
- Post-Construction Storage: 85/100 general, 80/100 material
- Mission Recovery: All 12 corpses and 25 Elerium recovered successfully

### Budget Planning Scenarios

**3-Month Expansion Plan**
- Month 1: Income $6.5M, Expenses $3.8M (salaries + maintenance), Net +$2.7M, Balance: $9.2M
- Month 2: Income $6.5M, Expenses $5.3M (+ $1.5M new base construction), Net +$1.2M, Balance: $10.4M
- Month 3: Income $6.8M (+$300K from new base missions), Expenses $4.5M (+ $700K new staff), Net +$2.3M, Balance: $12.7M
- Forecast Result: Expansion sustainable with positive trajectory

**Aggressive Research Sprint**
- Month 1: Income $6.2M, Expenses $5.8M (+ $2M Plasma research + $500K manufacturing), Net +$400K, Balance: $6.9M
- Month 2: Income $6.2M, Expenses $4.2M (research complete, reduced spending), Net +$2.0M, Balance: $8.9M
- Month 3: Income $7.0M (+ $800K from advanced equipment sales), Expenses $4.0M, Net +$3.0M, Balance: $11.9M
- Forecast Result: Short-term risk pays off with technological advantage and increased income

**Crisis Recovery Scenario**
- Month 1: Income $4.5M (countries lost), Expenses $5.2M, Net -$700K, Balance: $5.8M (deficit warning)
- Month 2 (Austerity): Income $4.8M, Expenses $3.9M (staff cuts, deferred construction), Net +$900K, Balance: $6.7M
- Month 3 (Stabilized): Income $5.5M (performance recovery), Expenses $4.0M, Net +$1.5M, Balance: $8.2M
- Forecast Result: Crisis averted through aggressive cost reduction

### Financial Crisis Progressions

**Path to Game Over**
- Month 1 Deficit: Balance -$200K → "Financial Warning: 2 months until project termination"
- Month 2 Deficit: Balance -$800K → "Critical Warning: 1 month to balance budget or face shutdown"
- Month 3 Deficit: Balance -$1.5M → "Project Terminated: Council has withdrawn all funding after 3 months of deficits"
- Game Over: Campaign ends with financial failure condition

**Crisis Recovery**
- Month 1 Deficit: Balance -$150K → Warning triggered
- Month 2 Deficit: Balance -$400K → Final warning
- Month 3 Surplus: Balance +$300K → Crisis counter reset to 0, campaign continues
- Recovery Actions: Emergency asset sales ($500K UFO components), staff reductions ($200K/month savings), deferred construction

**Economic Victory Path**
- Months 1-6: Positive balance maintained, average +$2M/month
- Months 7-12: Continued surplus, net worth reaches $10M+ (cash $5M, facilities $3M, crafts $1.5M, items/materials $500K)
- Month 12: Economic victory condition triggered → "Financial Stability Achieved: 12 consecutive profitable months with $10M+ net worth"

## Related Wiki Pages

- [Economy Overview](README.md) - Comprehensive economic system framework
- [Manufacturing](Manufacturing.md) - Production costs and engineering capacity
- [Research](Research.md) - Technology development funding requirements
- [Marketplace](Marketplace.md) - Purchase and sales transaction mechanics
- [Transfers](Transfers.md) - Logistics costs and delivery systems
- [Base Management](../basescape/Base%20management.md) - Facility construction and maintenance
- [Mission Types](../geoscape/Mission_Types.md) - Mission rewards and recovery mechanics
- [Facilities](../basescape/Facilities.md) - Storage capacity and construction costs

## References to Existing Games and Mechanics

**XCOM: Enemy Unknown (2012)**
- Monthly Council Reports: Funding adjusted based on country satisfaction and panic levels
- Research Funding: Upfront costs for technology projects with no refunds
- Item Sales: Direct marketplace for selling recovered alien equipment and corpses
- Storage Management: Limited capacity requiring facility expansion for large operations

**XCOM 2 (2016)**
- Aggressive Economy: Tighter budget constraints forcing difficult resource prioritization
- Black Market: High-risk sales channel for restricted items with reputation consequences
- Supply Drops: Monthly income supplemented by recovered mission resources
- Facility Construction: Significant upfront costs balanced against long-term economic benefits

**Phoenix Point (2019)**
- Multi-Faction Economy: Different supplier relationships affecting prices and availability
- Resource Scarcity: Limited strategic materials creating manufacturing bottlenecks
- Base Specialization: Economic optimization through focused facility development

**Xenonauts (2014)**
- Deterministic Funding: Transparent calculations for country contributions and performance bonuses
- Storage Overflow: Explicit capacity limits with warnings when items cannot be stored
- Budget Forecasting: Player tools for projecting income and expenses across multiple months
