# Early Game Economy Model

**Status**: Design Document - Economic Balance Validation
**Last Updated**: 2025-10-31
**Related Systems**: Geoscape.md, BASESCAPE.md, MISSIONS.md, Countries.md
**Purpose**: Validate hybrid economic balance approach (income boost + expense reduction)

## Executive Summary

The early game economy has been rebalanced using a hybrid approach combining **mission salvage income boosts** with **expense reductions** to eliminate the critical 150-200K monthly deficit that was blocking development. This creates sustainable early game progression while maintaining meaningful economic challenges.

**Key Changes:**
- Mission salvage values: 20-150K (up from previous lower values)
- Base maintenance: 100K × size² (down from 150K × size²)
- Facility operation costs: 2-15K range (down from 5-50K range)
- Country funding: Absolute amounts 10K-125K (replacing GDP-based formula)
- Starting capital: 500K (Normal difficulty)

## Economic Balance Philosophy

### Hybrid Approach Rationale

**Problem**: Pure income boost creates "easy mode" where players can ignore economic management. Pure expense reduction creates "trivial mode" where expansion has no cost.

**Solution**: Hybrid approach maintains economic tension while enabling early game viability:
- **Income Boost**: Mission salvage provides meaningful rewards for successful operations
- **Expense Reduction**: Lower operational costs reduce baseline drain
- **Starting Capital**: Sufficient reserves for initial operations
- **Progressive Challenge**: Costs scale with expansion, rewards scale with risk

### Balance Goals

1. **Early Game Viability**: No bankruptcy in first 3 months with reasonable play
2. **Economic Tension**: Resource decisions remain meaningful throughout
3. **Scaling Challenge**: Later game costs create meaningful trade-offs
4. **Risk/Reward Balance**: High-risk missions provide high-reward salvage

## Starting Conditions

### Initial Resources (Normal Difficulty)

| Resource | Amount | Purpose |
|----------|--------|---------|
| **Starting Capital** | 500,000 credits | Fund initial base construction and operations |
| **Monthly Funding** | 50,000-100,000 credits | Baseline income from allied countries |
| **Mission Frequency** | 2-4 missions/month | Primary income source through salvage |
| **Base Capacity** | 1 small base (4×4) | Initial operations hub |

### Initial Expenses

| Category | Monthly Cost | Notes |
|----------|--------------|-------|
| **Base Maintenance** | 100,000 credits | 100K × (4×4) = 100K for small base |
| **Facility Operations** | 5,000 credits | Minimal facilities (radar, hangar) |
| **Unit Salaries** | 12,000 credits | 4 soldiers × 500 credits × 6 months |
| **Research** | 0 credits | No active projects initially |
| **Total Monthly Burn** | 117,000 credits | Sustainable with mission income |

## Monthly Budget Projections

### Month 1-3: Establishment Phase

**Income Sources:**
- Country funding: 75,000 credits/month (conservative estimate)
- Mission salvage: 60,000 credits/month (2-3 missions × 20-30K average)
- **Total Income**: 135,000 credits/month

**Expense Breakdown:**
- Base maintenance: 100,000 credits
- Facility operations: 5,000 credits
- Unit salaries: 12,000 credits
- Equipment purchases: 20,000 credits (initial gear)
- **Total Expenses**: 137,000 credits/month

**Net Result**: -2,000 credits/month (slight deficit, manageable with starting capital)

**Key Activities:**
- Construct initial base facilities
- Recruit and train first squad
- Complete 2-3 basic missions
- Establish radar coverage

### Month 4-6: Expansion Phase

**Income Sources:**
- Country funding: 90,000 credits/month (improving relations)
- Mission salvage: 90,000 credits/month (3-4 missions × 25-35K average)
- **Total Income**: 180,000 credits/month

**Expense Breakdown:**
- Base maintenance: 100,000 credits (same base)
- Facility operations: 12,000 credits (additional facilities)
- Unit salaries: 18,000 credits (6 soldiers)
- Research: 15,000 credits (first research project)
- Equipment purchases: 15,000 credits
- **Total Expenses**: 160,000 credits/month

**Net Result**: +20,000 credits/month (positive cash flow)

**Key Activities:**
- Expand base with additional facilities
- Research basic weapon improvements
- Increase squad size to 6 soldiers
- Establish secondary radar coverage

### Month 7-9: Growth Phase

**Income Sources:**
- Country funding: 110,000 credits/month (strong relations)
- Mission salvage: 120,000 credits/month (4-5 missions × 30-40K average)
- **Total Income**: 230,000 credits/month

**Expense Breakdown:**
- Base maintenance: 100,000 credits
- Facility operations: 20,000 credits (full facility suite)
- Unit salaries: 24,000 credits (8 soldiers)
- Research: 25,000 credits (multiple projects)
- Equipment purchases: 20,000 credits
- **Total Expenses**: 189,000 credits/month

**Net Result**: +41,000 credits/month (strong positive flow)

**Key Activities:**
- Construct second base (additional 100K maintenance)
- Advanced research projects
- Elite unit recruitment
- Expanded interception capabilities

### Month 10-12: Maturity Phase

**Income Sources:**
- Country funding: 125,000 credits/month (maximum relations)
- Mission salvage: 150,000 credits/month (5-6 missions × 35-45K average)
- **Total Income**: 275,000 credits/month

**Expense Breakdown:**
- Base maintenance: 200,000 credits (2 bases)
- Facility operations: 35,000 credits (both bases fully equipped)
- Unit salaries: 36,000 credits (12 soldiers)
- Research: 40,000 credits (advanced projects)
- Equipment purchases: 25,000 credits
- **Total Expenses**: 336,000 credits/month

**Net Result**: -61,000 credits/month (controlled deficit)

**Key Activities:**
- Third base construction planning
- Advanced technology deployment
- Large-scale operations
- Strategic resource allocation

## Mission Salvage Impact Analysis

### Salvage Value Distribution

| Mission Type | Frequency | Average Value | Monthly Contribution |
|-------------|-----------|---------------|---------------------|
| **UFO Crash Recovery** | 40% | 25,000 credits | 30,000 credits |
| **Terror Defense** | 30% | 20,000 credits | 18,000 credits |
| **Alien Base Assault** | 15% | 75,000 credits | 33,750 credits |
| **Investigation** | 10% | 35,000 credits | 10,500 credits |
| **Supply Interception** | 5% | 50,000 credits | 7,500 credits |
| **Weighted Average** | 100% | 32,000 credits | 100,000 credits |

### Risk/Reward Balance

**Low-Risk Missions** (60% of missions):
- Average salvage: 22,500 credits
- Success rate: 85%
- Expected value: 19,125 credits

**High-Risk Missions** (40% of missions):
- Average salvage: 55,000 credits
- Success rate: 65%
- Expected value: 35,750 credits

**Overall Expected Value**: 26,000 credits per mission

## Base Expansion Economics

### Base Size Progression

| Base Size | Grid Size | Maintenance Cost | Break-Even Missions | Payback Period |
|-----------|-----------|------------------|-------------------|----------------|
| **Small** | 4×4 | 100,000 credits | 4 missions | 2 months |
| **Medium** | 6×6 | 225,000 credits | 9 missions | 4 months |
| **Large** | 8×8 | 400,000 credits | 16 missions | 6 months |
| **Extra Large** | 10×10 | 625,000 credits | 25 missions | 9 months |

### Facility Cost Analysis

| Facility Type | Operation Cost | Strategic Value | ROI Period |
|---------------|----------------|-----------------|------------|
| **Radar** | 3,000 credits | Mission detection | 1 month |
| **Hangar** | 5,000 credits | Craft operations | 2 months |
| **Laboratory** | 8,000 credits | Research acceleration | 3 months |
| **Hospital** | 4,000 credits | Unit recovery | 2 months |
| **Academy** | 6,000 credits | Unit training | 3 months |
| **Prison** | 2,000 credits | Intelligence | 4 months |

## Difficulty Scaling Validation

### Easy Mode (150% starting capital, 120% income)

**Month 1-3 Budget:**
- Starting capital: 750,000 credits
- Monthly income: 162,000 credits
- Monthly expenses: 137,000 credits
- **Net**: +25,000 credits/month
- **Result**: Comfortable early game, focuses on strategic decisions

### Normal Mode (100% starting capital, 100% income)

**Month 1-3 Budget:**
- Starting capital: 500,000 credits
- Monthly income: 135,000 credits
- Monthly expenses: 137,000 credits
- **Net**: -2,000 credits/month
- **Result**: Tight but manageable, requires mission success

### Hard Mode (50% starting capital, 80% income)

**Month 1-3 Budget:**
- Starting capital: 250,000 credits
- Monthly income: 108,000 credits
- Monthly expenses: 137,000 credits
- **Net**: -29,000 credits/month
- **Result**: Challenging, emphasizes efficient resource use

### Impossible Mode (20% starting capital, 60% income)

**Month 1-3 Budget:**
- Starting capital: 100,000 credits
- Monthly income: 81,000 credits
- Monthly expenses: 137,000 credits
- **Net**: -56,000 credits/month
- **Result**: Extreme challenge, requires perfect mission execution

## Economic Health Metrics

### Cash Flow Targets

| Period | Minimum Balance | Target Balance | Maximum Sustainable Debt |
|--------|-----------------|----------------|-------------------------|
| **Month 1-3** | 300,000 credits | 400,000 credits | 50,000 credits |
| **Month 4-6** | 400,000 credits | 500,000 credits | 100,000 credits |
| **Month 7-9** | 500,000 credits | 650,000 credits | 150,000 credits |
| **Month 10-12** | 600,000 credits | 800,000 credits | 200,000 credits |

### Bankruptcy Prevention

**Early Warning System:**
- **Warning**: Balance < 200,000 credits (Month 1-3)
- **Critical**: Balance < 100,000 credits (any period)
- **Bankruptcy**: Balance < 0 credits for 2 consecutive months

**Recovery Strategies:**
1. Focus on high-value missions (Alien Base Assault)
2. Delay non-essential facility construction
3. Sell excess equipment on marketplace
4. Improve diplomatic relations for funding bonuses

## Validation Testing Scenarios

### Scenario 1: Optimal Play (Normal Difficulty)

**Assumptions:**
- 80% mission success rate
- 3 missions per month average
- Prudent base expansion
- Good diplomatic management

**Expected Outcome:**
- Month 12 balance: 650,000 credits
- 2 bases operational
- 8-10 soldiers equipped
- Research projects completed

### Scenario 2: Aggressive Expansion (Normal Difficulty)

**Assumptions:**
- 75% mission success rate
- 3.5 missions per month
- Rapid base expansion
- Heavy research investment

**Expected Outcome:**
- Month 12 balance: 450,000 credits
- 3 bases operational
- Advanced technology unlocked
- Higher risk of temporary deficits

### Scenario 3: Conservative Play (Normal Difficulty)

**Assumptions:**
- 85% mission success rate
- 2.5 missions per month
- Slow, deliberate expansion
- Minimal research spending

**Expected Outcome:**
- Month 12 balance: 800,000 credits
- 2 bases fully developed
- Strong financial reserves
- Slower technological progress

## Balance Adjustment Guidelines

### Income Adjustments

**If early game too easy:**
- Reduce mission salvage values by 10-15%
- Decrease country funding by 5-10%
- Increase mission failure penalties

**If early game too hard:**
- Increase salvage values for basic missions
- Add guaranteed "starter missions" with good rewards
- Provide interest-free loans for critical purchases

### Expense Adjustments

**If expenses too low:**
- Increase facility operation costs by 20-30%
- Add maintenance scaling for damaged equipment
- Implement inflation over campaign duration

**If expenses too high:**
- Reduce base maintenance formula further (75K × size²)
- Lower facility operation costs to 1-10K range
- Add efficiency bonuses for well-managed bases

## Implementation Checklist

- [x] Mission salvage values defined (MISSIONS.md)
- [x] Base maintenance costs reduced (BASESCAPE.md)
- [x] Facility operation costs reduced (multiple files)
- [x] Country funding levels adjusted (Countries.md)
- [x] Starting capital defined (Geoscape.md)
- [x] Budget model created (this document)
- [ ] Economic balance testing completed
- [ ] Player feedback incorporated
- [ ] Final balance adjustments made

## Conclusion

The hybrid economic balance approach successfully addresses the critical early game deficit while maintaining meaningful economic challenges. The combination of boosted mission salvage income, reduced operational costs, and appropriate starting capital creates a sustainable progression curve that rewards strategic decision-making without punishing reasonable expansion.

**Key Success Metrics:**
- No bankruptcy in first 3 months with average play
- Meaningful economic decisions throughout campaign
- Risk/reward balance encourages varied mission selection
- Difficulty scaling provides appropriate challenges

This economic model enables the development team to proceed with confidence that the early game is financially viable while maintaining the strategic depth that makes AlienFall engaging.
