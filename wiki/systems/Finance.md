# Finance

## Table of Contents

- [Score System](#score-system)
- [Country Funding](#country-funding)
- [Income Sources](#income-sources)
- [Expenses](#expenses)
- [Budget & Cash Flow](#budget--cash-flow)
- [Advanced Scenarios](#advanced-scenarios)
- [Monthly Financial Report](#monthly-financial-report)

---

## Score System

### Overview
The score system measures how effectively the player protects allied nations from alien threats. Score is separate from game success metrics; it directly impacts funding and relationships.

**Scoring Mechanics**
- Calculated at provincial level
- Aggregated monthly
- Grouped by region and country for reporting

**Score Gains**
- Neutralizing alien threats (UFOs, bases, missions)
- Saving civilian lives
- Destroying enemy mission sites and craft
- *Note: Destruction during collateral damage does NOT gain score*

**Score Losses**
- Civilian casualties
- Property destruction
- Failed missions
- Refusing mission interception requests

**Strategic Impact**

Score directly influences country relationships and funding levels, creating a feedback loop where successful operations lead to greater resources.

---

## Country Funding

### Overview
Countries allocate defense budgets based on player performance. The player receives a percentage of each country's GDP monthly, proportional to the defense funding level assigned.

**Funding Calculation**
- Country economy = sum of all provincial economies
- Monthly score determines relationship changes:
  - Every 20 points awarded = ±1 relationship modifier
- Relationship range: -100 (hostile) to +100 (allied)
- Relationship determines funding level allocation

**Funding Levels**
- Scale: 0 to 10 levels
- Each level represents percentage of GDP allocated to defense (e.g., Level 6 = 6% of GDP)
- Player receives equivalent percentage of country GDP monthly as income
- Higher scores and good relationships increase funding levels
- Poor performance decreases funding

---

## Income Sources

### Primary Revenue Streams
1. **Country Funding**: Monthly allocation based on defense budget level and country relationships
2. **Mission Loot Sales**: Selling salvaged alien technology and equipment from completed missions
3. **Raid Loot Sales**: Selling equipment captured during non-mission battles and skirmishes
4. **Manufacturing Output**: Selling produced equipment on the marketplace
5. **Faction Tributes**: Diplomatic payments from factions for contracts and arrangements
6. **Supplier Discounts**: Price reductions from favorable supplier relationships

---

## Expenses

### Operational Costs
- **Equipment Purchases**: Buying items, units, craft, and facility components from marketplace
- **Personnel Maintenance**: Monthly upkeep for all soldiers and support personnel
- **Facility Maintenance**: Regular maintenance for all constructed facilities
- **Base Operations**: Electricity, supplies, and general base upkeep
- **Craft Operations**: Fuel and maintenance for aircraft and spacecraft

**Strategic Expenditures**
- **Black Market Services**: Paying for espionage, assassination, and illegal acquisitions
- **Diplomacy Costs**: Tributes, gifts, and negotiations with factions, suppliers, and countries
- **Fame Maintenance**: PR costs to maintain high public reputation
- **Corruption Tax**: Penalty for operating excessive number of bases (per base surcharge)
- **Inflation Tax**: Applied when accumulated credits exceed 20× monthly income (wealth penalty)

---

## Budget & Cash Flow

### Monthly Budget Cycle

Each in-game month follows a fixed financial cycle:

**Week 1: Revenue Collection**
- Country funding allocated (+10% per week over month)
- Marketplace sales processed
- Supplier payments received
- Faction tributes collected

**Week 2-3: Operations**
- Personnel maintenance deducted (-25% per week)
- Facility maintenance deducted (-25% per week)
- Craft fuel/maintenance deducted (-25% per week)

**Week 4: Final Settlement**
- Equipment purchases processed
- Research completion bonuses applied
- Manufacturing revenue from sales
- Interest on loans calculated (if any)
- Financial report generated

### Cash Flow Forecasting

The finance system tracks projected cash flow for next 3 months:

**Forecast Calculation:**
- Current month revenue (estimated based on recent trends)
- Known expenses (facility maintenance, personnel, etc.)
- Planned purchases (equipment orders, base construction)
- Debt obligations and interest

**Cash Crisis Indicators:**
- **Warning** (Yellow): Cash reserves < 1 month of expenses
- **Critical** (Red): Cash reserves < 1 week of expenses
- **Bankruptcy Risk** (Flashing Red): Cash reserves negative

### Debt System

**Overview**
When cash reserves become depleted, players can take out loans to continue operations. Debt comes with mandatory repayment schedules and interest accumulation.

**Loan Mechanics**
- Standard loan: 100,000 Credits per month
- Interest rate: 5% per month (compounding)
- Mandatory repayment: Loan principal must be repaid before interest grows
- Consequences: Unpaid debt accrues interest at escalating rates
- Maximum debt ceiling: 500,000 Credits

**Loan Application Process:**
1. Cash reserves fall below operational needs
2. Auto-request dialog triggers (can be declined)
3. Review loan terms and interest
4. Accept or reject (rejection triggers immediate penalties)
5. Funds added to account on next turn

**Strategic Use**
- Temporary cash flow during equipment shortages
- Financing sudden expansion
- *Warning: Excessive debt can spiral into insolvency*

**Risk Management**
Players must carefully manage debt levels to avoid financial ruin, as excessive interest payments drain resources needed for operations. Debt above 100% of annual income triggers:
- -10% monthly funding from all countries
- -1 relations per country per month
- Creditor notices (events/messages)

**Bankruptcy Mechanics:**
- Triggered when debt > 500,000 or cash < -50,000
- Liquidates half of base equipment inventory
- Liquidates 25% of unit roster (forced retirement)
- Relations penalties (-20 with all countries)
- Game continues with debt wiped (hard reset)

### Budget Planning Tools

**Income Projection:**
- Estimate country funding based on current relations
- Factor supplier payment schedules
- Include expected marketplace sales

**Expense Projection:**
- Personnel: Number of soldiers × 500 credits/month
- Facilities: Sum of all facility maintenance costs
- Crafts: Craft count × 2,000 credits/month base fuel

**Break-Even Analysis:**
- Monthly expenses vs. guaranteed income
- Identifies minimum country funding level needed
- Highlights profitability of marketplace activities

---

## Advanced Scenarios

### Scenario 1: Base Expansion Funding

**Situation:** Player wants to build a new base but lacks cash reserves.

**Solution Approach:**
1. Forecast income for next 3 months
2. Consider loan for construction costs (100,000 credits)
3. Plan to repay loan from increased marketplace revenue
4. Adjust personnel to reduce monthly expenses
5. Time construction during high-funding months

**Risk Management:**
- Ensure construction won't trigger bankruptcy
- Maintain emergency cash reserves (50,000 minimum)
- Have backup loan capacity available

### Scenario 2: Economic Crisis Response

**Situation:** Multiple countries reduce funding due to failed missions.

**Cascade Effect:**
- Total funding drops 30% (all countries -10% relations)
- Monthly income reduced to 70% of normal
- Cash reserves depleting rapidly

**Recovery Strategy:**
1. Focus on high-reward missions to improve relations
2. Take small loan to bridge 1-2 months
3. Sell marketplace equipment to raise cash (40% of value)
4. Reduce personnel: discharge 2-3 soldiers (saves 1,000 credits/month)
5. Defer non-critical facility construction
6. Focus black market sales on expensive alien tech (1.5× value)

**Timeline:** 3-4 months to return to stability

### Scenario 3: Equipment Bottleneck

**Situation:** Player has cash but equipment is unavailable (not researched).

**Financial Impact:**
- Cash accumulates (no spending outlet)
- Relations suffer (allies frustrated with no equipment support)
- Marketplace prices increase (+10% per month of surplus)

**Solution:**
- Accelerate research to unlock equipment (allocate more scientists)
- Buy alternate tier equipment from suppliers
- Use black market for premium/rare items
- Allocate cash to facility upgrades instead

### Scenario 4: Multi-Country Funding Balancing

**Situation:** Player has bases in 3 countries with different funding levels.

**Complex Scenario:**
- Country A: High funding (level 8), stable relations
- Country B: Low funding (level 3), deteriorating relations  
- Country C: Medium funding (level 5), improving relations

**Financial Strategy:**
1. Prioritize missions in Country B to improve relations
2. Build new base in Country C (growth market)
3. Maintain Country A relations (primary income)
4. Total monthly income: (GDP-A × 0.08) + (GDP-B × 0.03) + (GDP-C × 0.05)
5. Plan facility maintenance based on per-country income

**Optimization:**
- Deploy crafts strategically to improve relations where needed
- Use marketplace sales to offset low-funding months
- Build supplier relationships to reduce equipment costs

---

## Monthly Financial Report

**Statement Components**
- **Total Revenue**: Sum of all income sources
- **Total Expenses**: Sum of all operational and strategic costs
- **Net Profit/Loss**: Monthly balance
- **Cash Reserves**: Current liquid assets
- **Debt Status**: Current loans and interest
- **Funding Status**: Current country funding levels and relationships
- **3-Month Forecast**: Projected cash flow and break-even analysis

**Report Sections:**

### Income Statement
```
MONTHLY INCOME STATEMENT
═════════════════════════════════════════════════════════════
Country Funding:           42,500 cr (7 countries @ avg level 5)
Marketplace Sales:          8,200 cr (3 weapons, 2 armor sold)
Manufacturing Revenue:      5,100 cr (Laser rifles produced)
Supplier Payments:          2,100 cr (Late deliveries returned)
Faction Tributes:           3,200 cr (2 allies paying tribute)
─────────────────────────────────────────────────────────────
TOTAL REVENUE:             61,100 cr
═════════════════════════════════════════════════════════════
```

### Expense Statement
```
MONTHLY EXPENSES
═════════════════════════════════════════════════════════════
Personnel Maintenance:     15,000 cr (30 soldiers @ 500 ea)
Facility Maintenance:      12,800 cr (8 facilities @ avg 1,600)
Craft Operations:           8,400 cr (4 crafts @ 2,100 ea)
Equipment Purchases:        12,500 cr (pending orders)
Black Market Operations:    3,200 cr (espionage costs)
─────────────────────────────────────────────────────────────
TOTAL EXPENSES:            52,000 cr
═════════════════════════════════════════════════════════════
```

### Summary
```
NET PROFIT:                 +9,100 cr (this month)
CASH RESERVES:             127,400 cr
DEBT STATUS:                    0 cr (no active loans)
MONTHLY SURPLUS:         Good (expenses = 85% of income)
```

**Player Review**
The monthly report provides complete financial transparency, allowing players to make informed decisions about base expansion, equipment purchases, and research priorities. The 3-month forecast helps identify cash flow problems early.


