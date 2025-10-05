# Funding

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Funding Level Architecture](#funding-level-architecture)
  - [Country Economy Systems](#country-economy-systems)
  - [Monthly Payout Frameworks](#monthly-payout-frameworks)
  - [Score-Driven Adjustment Systems](#score-driven-adjustment-systems)
  - [Zero and Extreme Condition Handling](#zero-and-extreme-condition-handling)
  - [Advanced Funding Effects](#advanced-funding-effects)
  - [Political Consequence Architecture](#political-consequence-architecture)
- [Examples](#examples)
  - [Funding Level Scenarios](#funding-level-scenarios)
  - [Country Economy Examples](#country-economy-examples)
  - [Monthly Payout Calculations](#monthly-payout-calculations)
  - [Score Adjustment Examples](#score-adjustment-examples)
  - [Zero Funding Consequences](#zero-funding-consequences)
  - [Advanced Effect Examples](#advanced-effect-examples)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Funding Management System establishes comprehensive government support mechanisms for Alien Fall's strategic gameplay, implementing performance-based financial allocation, regional economic integration, and political consequence frameworks. The system creates meaningful economic pressure and strategic incentives through dynamic funding adjustments, score-driven modifications, and deterministic payout calculations. The framework balances economic simulation depth with strategic decision-making while providing transparent feedback and consequence systems for informed player choices.

Funding serves as the predictable backbone of recurring income that players rely on, acting as a visible political resource that scales monthly payouts and can be modified by public Score, diplomacy, or scripted events. Designers can use Funding to create regional variability, tie support to performance, and introduce mid-game scarcity or windfalls without brittle systems.

## Mechanics

### Funding Level Architecture

Funding levels range from 0 to 100 as integers, with values clamped and configured through data files. Initial funding levels are determined by campaign and world data, with some countries potentially starting at zero or minimal values. The system implements performance-based scaling through score-driven adjustments and modification systems, creating strategic incentives for player decision-making.

Funding levels integrate with regional economic systems and provide deterministic calculation models for predictable allocation. The architecture supports political consequence integration through diplomatic effects and operational restriction frameworks, while enabling dynamic adjustment systems based on monthly performance evaluation.

### Country Economy Systems

Country economies are calculated by aggregating provincial economy values, with higher economy values multiplying cash returns for equivalent funding levels. This creates regional variability where wealthier nations provide larger grants for the same political support level. Economic development tracking monitors growth and improvement opportunities, while resource distribution logic affects strategic positioning and market influence factors.

The system implements geographic economic diversity with strategic implications, allowing external economic pressures and opportunity exploitation to influence funding potential and regional development.

### Monthly Payout Frameworks

Monthly payouts follow deterministic calculation algorithms integrating funding level, economy value, and configurable multipliers. The formula cash_from_country = FundingLevel × CountryEconomyValue × 1000 provides predictable financial planning, with payment scheduling ensuring consistent cash flow management. Economic impact assessment shows funding contributions to overall financial health, supporting strategic resource allocation and long-term planning tools.

### Score-Driven Adjustment Systems

Performance evaluation metrics convert monthly score deltas into funding level modifications using the formula: FundingLevel change = sign(monthly_score_delta) × floor(abs(monthly_score_delta) / 200). The divisor and conversion parameters are tunable through data files. Political response mechanisms translate public perception into government support changes, with consequence implementation frameworks for both positive and negative outcomes.

Feedback integration provides performance communication and strategic guidance, while adaptive response patterns create dynamic adjustments based on player behavior patterns.

### Zero and Extreme Condition Handling

Zero funding levels yield no monetary contribution but maintain country presence in campaigns. Countries at zero apply deterministic penalties including construction restrictions, mission difficulty increases, and diplomatic limitations. Critical performance responses trigger emergency interventions or support withdrawals, with diplomatic consequence frameworks causing relationship deterioration and access limitations.

Recovery mechanisms provide performance improvement pathways and funding restoration, while strategic penalty systems implement construction restrictions and operational limitations. Narrative integration creates story consequences and campaign progression effects.

### Advanced Funding Effects

High funding levels unlock positive support mechanisms including state support units, military assistance, and emergency resource allocation. Construction cost modifications provide economic incentives for base development, while supplier contract access enables enhanced procurement and equipment availability. Regional support options offer geographic benefits and strategic positioning advantages.

UI feedback systems provide economic status visualization and decision support tools for informed player choices.

### Political Consequence Architecture

Diplomatic relationship management affects government support stability and fluctuation based on performance. Operational restriction frameworks modify mission availability and difficulty, with hostility escalation mechanisms responding to performance-driven relationship deterioration. Positive support triggers activate achievement-based benefits and reward systems.

Deterministic outcome systems ensure predictable consequence implementation and reproducibility, while modding integration supports configurable threshold and effect customization.

## Examples

### Funding Level Scenarios
- Excellent Performance: Score 90+, Funding level 85-100, Monthly payout multiplier 2.5x, Political stability +30%
- Good Performance: Score 75-89, Funding level 60-84, Monthly payout multiplier 1.8x, Political stability +10%
- Average Performance: Score 60-74, Funding level 40-59, Monthly payout multiplier 1.2x, Political stability 0%
- Poor Performance: Score 45-59, Funding level 20-39, Monthly payout multiplier 0.7x, Political stability -15%
- Critical Performance: Score <45, Funding level 0-19, Monthly payout multiplier 0.3x, Political stability -40%

### Country Economy Examples
- Economic Powerhouse: Economy value 100, Base funding multiplier 2.0x, Strategic importance high, Development potential maximum
- Developed Nation: Economy value 75, Base funding multiplier 1.5x, Strategic importance medium, Development potential high
- Developing Region: Economy value 50, Base funding multiplier 1.0x, Strategic importance medium, Development potential moderate
- Underdeveloped Area: Economy value 25, Base funding multiplier 0.5x, Strategic importance low, Development potential limited
- Strategic Outpost: Economy value 10, Base funding multiplier 0.2x, Strategic importance high, Development potential minimal

### Monthly Payout Calculations
- High Economy, High Funding: Economy 80 × Funding 90 × Base 1000 = $7,200,000 monthly payout
- Medium Economy, Medium Funding: Economy 50 × Funding 60 × Base 1000 = $3,000,000 monthly payout
- Low Economy, Low Funding: Economy 20 × Funding 30 × Base 1000 = $600,000 monthly payout
- Zero Funding Scenario: Economy 40 × Funding 0 × Base 1000 = $0 monthly payout, Construction blocked
- Maximum Potential: Economy 100 × Funding 100 × Base 1000 = $10,000,000 monthly payout, All bonuses active

### Score Adjustment Examples
- Major Score Improvement: +600 monthly delta, Funding level increase +3, Political favor +15%, Bonus effects unlocked
- Moderate Score Gain: +300 monthly delta, Funding level increase +1, Political favor +5%, Stability improved
- Score Stability: ±50 monthly delta, Funding level unchanged, Political favor neutral, Status maintained
- Moderate Score Loss: -250 monthly delta, Funding level decrease -1, Political favor -8%, Restrictions applied
- Major Score Decline: -800 monthly delta, Funding level decrease -4, Political favor -25%, Emergency measures triggered

### Zero Funding Consequences
- Construction Restrictions: Base building blocked, Expansion prevented, Strategic options limited
- Mission Difficulty Increase: +50% enemy strength, -25% success probability, Higher risk operations
- Diplomatic Penalties: Mission refusal rate +40%, Intelligence access reduced, Support requests denied
- Economic Pressure: Supplier contracts unavailable, Equipment costs +100%, Maintenance fees doubled
- Recovery Requirements: Score improvement threshold +200 points, Minimum 3-month recovery period
- Narrative Impact: Public disapproval events, Media scrutiny increased, Political pressure mounted

### Advanced Effect Examples
- State Support Units: Funding 95+, Elite military assistance, Emergency intervention capability, Strategic advantage
- Construction Incentives: Funding 80+, Cost reduction 30%, Build time decrease 25%, Expansion acceleration
- Supplier Network Access: Funding 70+, Premium equipment available, Bulk discount 20%, Priority delivery
- Regional Support: Funding 85+, Local cooperation bonus, Intelligence sharing, Base defense assistance
- Emergency Grants: Funding 90+, One-time cash infusion $2M, Crisis stabilization, Recovery acceleration

## Related Wiki Pages

- [Finance.md](../finance/Finance.md) - Financial systems and funding management.
- [Score.md](../finance/Score.md) - Score-based funding adjustments.
- [Suppliers.md](../economy/Suppliers.md) - Diplomatic funding relationships.
- [Economy.md](../economy/Economy.md) - Economic integration and funding effects.
- [Monthly reports.md](../finance/Monthly%20reports.md) - Funding tracking and reports.
- [Geoscape.md](../geoscape/Geoscape.md) - Regional funding distribution.
- [Event.md](../lore/Event.md) - Funding-altering events.
- [Income sources.md](../finance/Income%20sources.md) - Funding as primary income source.

## References to Existing Games and Mechanics

- **XCOM Series**: Council funding based on performance and mission success
- **Civilization Series**: Diplomatic funding and tribute systems
- **Crusader Kings Series**: Crown authority and feudal funding
- **Europa Universalis Series**: Monarch power and state funding
- **Hearts of Iron Series**: National budget and war funding
- **Victoria Series**: Government budget and economic funding
- **Stellaris**: Empire influence and diplomatic funding
- **Total War Series**: Faction treasury and campaign funding
- **Fire Emblem Series**: Kingdom support and military funding
- **Final Fantasy Series**: Guild funding and organizational support

