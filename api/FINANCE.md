# Finance API Reference

**System:** Strategic & Operational Layer (Financial Management)  
**Module:** `engine/economy/finance/`  
**Latest Update:** October 22, 2025  
**Status:** ✅ Complete

---

## Implementation Status

### ✅ Implemented (in engine/economy/finance/)
- Organization score calculation with 5 components
- Financial record tracking per turn
- Monthly budget with income/expense categories
- Country funding management
- Supplier relationship system
- Purchase order tracking

### 🚧 Partially Implemented
- Advanced budget forecasting
- Automated cost optimization
- Dynamic supplier pricing

### 📋 Planned
- Multi-currency support
- Financial analytics dashboard
- Automated investment strategies

---

## Overview

The Finance system manages comprehensive financial operations across organizational, operational, and strategic layers. It tracks:
- **Organization Score**: Meta-rating of overall performance with military, research, economic, political, and strategic components
- **Financial Records**: Historical snapshots of balance, income, and expenses at specific turns
- **Monthly Budget**: Real-time operational income and expenses by category
- **Country Funding**: Tracking contributions and payments from allied nations
- **Supplier Relationships**: Vendor networks, pricing, and delivery terms
- **Purchase Orders**: Equipment procurement and payment scheduling

Finance differs from Economy—Economy manages moment-to-moment transactions; Finance tracks historical trends, calculates performance metrics, manages supplier relationships, and maintains organizational performance ratings.

**Layer Classification:** Strategic & Operational / Financial Analysis  
**Primary Responsibility:** Score tracking, income sources, expense categories, financial history, budget planning, supplier management, purchase orders  
**Integration Points:** Economy (transaction data), Countries (funding), Analytics (reporting), Basescape (upkeep costs)

---

## Core Entities

### Entity: FinanceRecord

Persistent financial snapshot at a specific point in time (turn).

**Properties:**
```lua
FinanceRecord = {
  turn = number,                  -- Game turn recorded
  date = string,                  -- "Year 2, Month 3"
  
  -- Balance
  balance = number,               -- Credits on hand
  monthly_income = number,        -- That month's total income
  monthly_expense = number,       -- That month's total expense
  monthly_delta = number,         -- Income - Expense
  
  -- Income Breakdown
  country_funding = number,       -- From countries
  market_sales = number,          -- Trading profits
  salvage_income = number,        -- Alien tech sales
  
  -- Expense Breakdown
  base_maintenance = number,      -- All bases
  craft_maintenance = number,     -- All crafts
  personnel_salary = number,      -- Unit payroll
  research_expense = number,      -- Tech projects
  manufacturing_expense = number, -- Equipment production
  
  -- Score
  organization_score = number,    -- Overall rating (0-100)
}
```

**Functions:**
```lua
-- Access
FinanceRecord.getRecord(turn: number) → FinanceRecord | nil
FinanceRecord.getRecords(start_turn: number, end_turn: number) → FinanceRecord[]

-- Queries
record:getBalance() → number
record:getMonthlyBalance() → number
record:getOrganizationScore() → number
record:getTaxRate() → number (income vs expenses ratio)
```

---

### Entity: FinancialReport

Analysis and summary of financial period with performance metrics.

**Properties:**
```lua
FinancialReport = {
  period_start = number,          -- Turn number
  period_end = number,
  period_label = string,          -- "Year 1, Month 1-3" (quarterly)
  
  -- Overall
  total_income = number,
  total_expense = number,
  net_balance = number,
  profit_margin = number,         -- (income - expense) / income %
  
  -- Income Analysis
  largest_income_source = string, -- Which country/source
  income_sources = table,         -- {source: amount}
  income_trends = string,         -- "growing", "stable", "declining"
  
  -- Expense Analysis
  largest_expense_category = string,
  expense_categories = table,     -- {category: amount}
  expense_trends = string,
  
  -- Efficiency
  cost_per_base = number,
  cost_per_unit = number,
  cost_per_craft = number,
  efficiency_rating = number,     -- 0-100
  
  -- Recommendations
  improvement_areas = string[],   -- What needs attention
}
```

**Functions:**
```lua
-- Creation
FinancialReport.generateReport(start_turn: number, end_turn: number) → FinancialReport
FinancialReport.getQuarterlyReport() → FinancialReport
FinancialReport.getAnnualReport() → FinancialReport

-- Queries
report:getProfitMargin() → number
report:getEfficiencyRating() → number
report:getLargestExpense() → string
report:getImprovementAreas() → string[]
```

---

### Entity: Budget

Monthly financial snapshot of operational income and expenses.

**Properties:**
```lua
Budget = {
  month = number,                 -- Month number
  year = number,                  -- Year
  
  -- Income breakdown
  income_funding = number,        -- From countries
  income_marketplace = number,    -- From selling items
  income_research = number,       -- From sharing tech
  income_missions = number,       -- From mission rewards
  income_total = number,          -- Sum of all income
  
  -- Expense breakdown
  expense_salaries = number,      -- Soldier wages
  expense_base_upkeep = number,   -- Facility maintenance
  expense_research = number,      -- Research costs
  expense_manufacturing = number, -- Production costs
  expense_total = number,         -- Sum of all expenses
  
  -- Summary
  balance = number,               -- Income - expenses
  running_total = number,         -- Cumulative balance
}
```

**Functions:**
```lua
-- Creation and retrieval
FinanceSystem.calculateMonthlyBudget() → Budget
FinanceSystem.getMonthlyBudget(month, year) → Budget | nil
FinanceSystem.getBudgetHistory() → Budget[]
FinanceSystem.getCurrentBalance() → number
FinanceSystem.getRunningBalance() → number

-- Income tracking
FinanceSystem.recordIncome(source, amount) → void
FinanceSystem.recordCountryFunding(country, amount) → void
FinanceSystem.recordMarketplaceSale(item, amount) → void
FinanceSystem.recordMissionReward(mission, amount) → void

-- Expense tracking
FinanceSystem.recordExpense(category, amount) → void
FinanceSystem.recordSalaries(amount) → void
FinanceSystem.recordBaseUpkeep(baseId, amount) → void

-- Queries
FinanceSystem.getTotalIncome() → number
FinanceSystem.getTotalExpenses() → number
FinanceSystem.canAfford(cost) → bool
FinanceSystem.getDaysUntilBankruptcy() → number | nil
FinanceSystem.getFinancialHealth() → string  -- "healthy", "warning", "critical"
```

---

### Entity: CountryFundingSource

Tracks individual country's contribution to organizational income.

**Properties:**
```lua
CountryFundingSource = {
  country_id = string,            -- "usa"
  monthly_amount = number,        -- Base funding
  bonus_amount = number,          -- From mission bonuses
  penalty_amount = number,        -- From mission failures
  
  -- History
  funding_history = number[],     -- Last 12 months
  total_contributed = number,     -- All-time
  
  -- Status
  is_active = boolean,            -- Country still funding
  payment_date = number,          -- Turn of next payment
}
```

---

### Entity: OrganizationScore

Meta-rating of player organization performance across all dimensions.

**Properties:**
```lua
OrganizationScore = {
  -- Core score
  current_score = number,         -- Overall rating (0-100)
  
  -- Subscores (components)
  military_score = number,        -- Combat effectiveness (0-100)
  research_score = number,        -- Tech progress (0-100)
  economic_score = number,        -- Financial health (0-100)
  political_score = number,       -- Country relations (0-100)
  strategic_score = number,       -- Territory control (0-100)
  
  -- History
  score_history = number[],       -- Score per month
  score_milestones = table,       -- {score: turn_achieved}
  
  -- Ratings
  rating = string,                -- "F", "D", "C", "B", "A", "S"
  rank = number,                  -- Percentile 0-100
}
```

**Functions:**
```lua
-- Queries
score:getScore() → number
score:getRating() → string
score:getComponentBreakdown() → table
score:getScoreTrend() → string ("improving", "stable", "declining")

-- Calculation
score:calculate() → void (recalculate from current state)
score:addPoints(points: number, category: string) → void
score:subtractPoints(points: number, category: string) → void
```

---

### Entity: Transaction

Individual financial record entry for tracking specific income/expense.

**Properties:**
```lua
Transaction = {
  id = string,
  type = string,                  -- "income", "expense"
  category = string,              -- "funding", "salary", "base_upkeep"
  amount = number,                -- Credits
  date = number,                  -- Turn number
  description = string,
  source = string | nil,          -- Country/base/mission
}
```

---

### Entity: Supplier

Vendor who provides items at negotiated prices with delivery terms.

**Properties:**
```lua
Supplier = {
  id = string,                    -- "military_surplus"
  name = string,
  description = string,
  
  -- Relationship
  relationship_level = number,    -- -2 to +2
  
  -- Supply
  available_items = ItemType[],   -- What they sell
  item_prices = table,            -- {[itemId]: price_multiplier}
  
  -- Delivery
  delivery_time_days = number,    -- Days to deliver
  minimum_order = number,         -- Minimum purchase
  
  -- Availability
  restock_interval = number,      -- Days between restocks
  last_restock = number,          -- Turn number
}
```

**Functions:**
```lua
-- Retrieval
SupplierSystem.getSupplier(id) → Supplier | nil
SupplierSystem.getAllSuppliers() → Supplier[]

-- Pricing (affected by relationship)
supplier:getPrice(itemId) → number  -- Adjusted for relationship
supplier:getPriceModifier() → number  -- 0.5-2.0x
supplier:updateRelationship(delta) → void
supplier:canDeliver(itemId, quantity) → bool

-- Orders
supplier:createOrder(items) → Order
supplier:getAvailableItems() → ItemType[]
supplier:getDeliveryTime() → number

-- Status
supplier:getRelationship() → number
supplier:needsRestock() → bool
supplier:restockItems() → void
```

---

### Entity: PaymentTerm

Terms for purchase agreements (payment method, installments, interest).

**Properties:**
```lua
PaymentTerm = {
  id = string,
  name = string,                  -- "cash_on_delivery", "30_days"
  payment_method = string,        -- "immediate", "installment"
  installment_count = number | nil,
  interest_rate = number,         -- 0-0.2 (20% max)
  upfront_payment = number,       -- 0-1.0 (percentage)
}
```

---

### Entity: PurchaseOrder

Order placed with supplier for equipment procurement.

**Properties:**
```lua
PurchaseOrder = {
  id = string,
  supplier = Supplier,
  items = {[itemId]: quantity, ...},
  
  -- Pricing
  subtotal = number,
  tax = number,
  total = number,
  
  -- Status
  status = string,                -- "pending", "shipped", "delivered"
  ordered_date = number,          -- Turn
  delivery_date = number,         -- Expected arrival
  
  -- Payment
  payment_term = PaymentTerm,
  payments_made = table,          -- {turn: amount, ...}
}
```

**Functions:**
```lua
-- Creation
PurchaseSystem.createOrder(supplier, items, paymentTerm) → (Order, error)
PurchaseSystem.submitOrder(order) → bool
PurchaseSystem.cancelOrder(orderId) → (bool, refund)

-- Status
order:getStatus() → string
order:getEstimatedDelivery() → number  -- Turn
order:isShipped() → bool
order:isDelivered() → bool

-- Payment
order:getTotal() → number
order:getAmountPaid() → number
order:getAmountDue() → number
order:canPay() → bool
order:recordPayment(amount) → bool
order:isPaid() → bool
```

---

## Services & Functions

### Finance Tracking Service

```lua
-- Record management
FinanceTracker.recordTransaction(type: string, amount: number, category: string) → void
FinanceTracker.recordMonthlySnapshot(turn: number) → FinanceRecord
FinanceTracker.getFinanceHistory(num_months: number) → FinanceRecord[]

-- Queries
FinanceTracker.getTotalIncome(start_turn: number, end_turn: number) → number
FinanceTracker.getTotalExpense(start_turn: number, end_turn: number) → number
FinanceTracker.getAverageMonthlyBalance(num_months: number) → number
FinanceTracker.getBalanceTrend(num_months: number) → string ("improving", "declining")
```

### Country Funding Service

```lua
-- Funding management
FundingManager.addCountryFundingSource(country: Country, amount: number) → void
FundingManager.removeCountryFundingSource(country_id: string) → void
FundingManager.getFundingSource(country_id: string) → CountryFundingSource | nil

-- Payouts
FundingManager.processMonthlyFunding() → number (total received)
FundingManager.getFundingBreakdown() → table {country_id: amount}
FundingManager.getTotalFunding() → number (all countries)

-- Analysis
FundingManager.getLargestFunder() → Country
FundingManager.getFundingTrends() → table (trending sources)
```

### Organization Score Service

```lua
-- Score management
ScoreManager.getOrganizationScore() → number
ScoreManager.updateScore() → void (recalculate)

-- Components
ScoreManager.getMilitaryScore() → number
ScoreManager.getResearchScore() → number
ScoreManager.getEconomicScore() → number
ScoreManager.getPoliticalScore() → number
ScoreManager.getStrategicScore() → number

-- Progress
ScoreManager.addScore(points: number, category: string) → void
ScoreManager.getScoreTrend() → string
ScoreManager.getScoreHistory(num_months: number) → number[]

-- Rating
ScoreManager.getRating() → string ("F" to "S")
ScoreManager.getRank() → number (percentile)
ScoreManager.getScoreMilestones() → table
```

### Financial Analysis Service

```lua
-- Report generation
AnalysisService.generateQuarterlyReport() → FinancialReport
AnalysisService.generateAnnualReport() → FinancialReport
AnalysisService.generateCustomReport(start_turn: number, end_turn: number) → FinancialReport

-- Metrics
AnalysisService.calculateProfitMargin() → number
AnalysisService.calculateCostPerBase() → number
AnalysisService.calculateCostPerUnit() → number
AnalysisService.calculateCostPerCraft() → number
AnalysisService.calculateEfficiencyRating() → number

-- Analysis
AnalysisService.identifyProblemAreas() → string[]
AnalysisService.suggestImprovements() → string[]
AnalysisService.compareToPreviousPeriod() → table (changes)
```

### Supplier Management Service

```lua
-- Supplier operations
SupplierSystem.createSupplier(config) → Supplier
SupplierSystem.getSupplier(id) → Supplier | nil
SupplierSystem.getAllSuppliers() → Supplier[]

-- Pricing and relationships
SupplierSystem.adjustSupplierRelationship(supplier_id: string, delta: number) → void
SupplierSystem.getSupplierPrice(supplier_id: string, item_id: string) → number

-- Stock management
SupplierSystem.updateSupplierStock() → void
SupplierSystem.getAvailableItems(supplier_id: string) → ItemType[]
```

### Purchase Order Service

```lua
-- Order management
PurchaseSystem.createOrder(supplier, items, paymentTerm) → (Order, error)
PurchaseSystem.submitOrder(order) → bool
PurchaseSystem.cancelOrder(orderId) → (bool, refund)
PurchaseSystem.getAllOrders() → PurchaseOrder[]
PurchaseSystem.getOrdersByStatus(status: string) → PurchaseOrder[]

-- Payment processing
PurchaseSystem.processPayment(order_id: string, amount: number) → bool
PurchaseSystem.checkDeliveries() → void (process arrivals)
```

---

## Configuration (TOML)

### Organization Score Calculation

```toml
# finance/score_calculation.toml

[score_weights]
# Component weights in overall score (sum to 100)
military_weight = 20
research_weight = 20
economic_weight = 20
political_weight = 20
strategic_weight = 20

[military_score]
# Calculate from combat victories, unit quality
points_per_victory = 10
points_per_ufos_destroyed = 5
points_per_elite_unit = 3
max_military_score = 100

[research_score]
# Calculate from completed research, tech milestones
points_per_tech = 5
points_per_milestone = 20
points_per_unique_alien_tech = 15
max_research_score = 100

[economic_score]
# Calculate from profitability, cash reserves
points_per_100k_balance = 5
points_per_positive_month = 2
penalty_per_negative_month = -3
max_economic_score = 100

[political_score]
# Calculate from country relations, faction standing
points_per_country_relation = 1
points_per_faction_ally = 15
penalty_per_country_abandoned = -20
max_political_score = 100

[strategic_score]
# Calculate from territory control, bases, influence
points_per_province_controlled = 2
points_per_base = 5
points_per_regional_influence = 10
max_strategic_score = 100
```

### Scoring Tiers & Ratings

```toml
# finance/score_tiers.toml

[[tiers]]
rating = "F"
min_score = 0
max_score = 20
description = "Organization Failing"
consequence = "Funding critical, likely abandonment"

[[tiers]]
rating = "D"
min_score = 21
max_score = 40
description = "Organization Struggling"
consequence = "Reduced funding, country confidence low"

[[tiers]]
rating = "C"
min_score = 41
max_score = 60
description = "Organization Adequate"
consequence = "Baseline funding, moderate confidence"

[[tiers]]
rating = "B"
min_score = 61
max_score = 80
description = "Organization Effective"
consequence = "Increased funding, countries supportive"

[[tiers]]
rating = "A"
min_score = 81
max_score = 95
description = "Organization Excellent"
consequence = "Strong funding, global confidence"

[[tiers]]
rating = "S"
min_score = 96
max_score = 100
description = "Organization Legendary"
consequence = "Maximum funding, world hero status"
```

### Country Funding Templates

```toml
# finance/country_funding.toml

[[countries]]
id = "usa"
base_monthly_funding = 15000
bonus_per_successful_mission = 1000
penalty_per_failed_mission = -2000
funding_suspension_threshold = -75

[[countries]]
id = "russia"
base_monthly_funding = 12000
bonus_per_successful_mission = 800
penalty_per_failed_mission = -1500
funding_suspension_threshold = -75

[[countries]]
id = "china"
base_monthly_funding = 14000
bonus_per_successful_mission = 900
penalty_per_failed_mission = -1800
funding_suspension_threshold = -75

[[countries]]
id = "multinational"
base_monthly_funding = 20000
bonus_per_successful_mission = 1500
penalty_per_failed_mission = -2500
funding_suspension_threshold = -50
```

### Supplier Configuration

```toml
# finance/suppliers.toml

[[suppliers]]
id = "military_surplus"
name = "Military Surplus Depot"
description = "Bulk military equipment supplier"
starting_relationship = 0
available_items = ["plasma_rifle", "heavy_armor", "ammo"]
price_modifier = 1.0
delivery_time_days = 14
minimum_order = 1000
restock_interval = 7

[[suppliers]]
id = "black_market"
name = "Black Market"
description = "Restricted and rare items"
starting_relationship = -1
available_items = ["alien_alloy", "special_weapon"]
price_modifier = 2.5
delivery_time_days = 30
minimum_order = 5000
restock_interval = 14

[[suppliers]]
id = "corporate"
name = "Corporate Electronics"
description = "High-tech components"
starting_relationship = 0
available_items = ["electronics", "advanced_circuits"]
price_modifier = 0.9
delivery_time_days = 7
minimum_order = 500
restock_interval = 3
```

### Payment Terms

```toml
# finance/payment_terms.toml

[[payment_terms]]
id = "cash_on_delivery"
name = "Cash on Delivery"
payment_method = "immediate"
upfront_payment = 1.0
interest_rate = 0.0

[[payment_terms]]
id = "net_30"
name = "Net 30 Days"
payment_method = "installment"
installment_count = 1
upfront_payment = 0.0
interest_rate = 0.05

[[payment_terms]]
id = "net_90"
name = "Net 90 Days"
payment_method = "installment"
installment_count = 3
upfront_payment = 0.0
interest_rate = 0.08

[[payment_terms]]
id = "installment_6"
name = "6 Month Installments"
payment_method = "installment"
installment_count = 6
upfront_payment = 0.1
interest_rate = 0.12
```

---

## Usage Examples

### Example 1: Track Financial History

```lua
-- Get last 12 months of financial records
local history = FinanceTracker.getFinanceHistory(12)

print("=== FINANCIAL HISTORY (Last 12 Months) ===")
for i, record in ipairs(history) do
  print(record.date .. ": " .. record.monthly_delta .. " credits")
  if record.monthly_delta > 0 then
    print("  → Positive month")
  else
    print("  → Deficit month")
  end
end

-- Check trend
local trend = FinanceTracker.getBalanceTrend(12)
print("Trend: " .. trend)
```

### Example 2: Generate Quarterly Report

```lua
-- Generate financial report
local report = AnalysisService.generateQuarterlyReport()

print("=== QUARTERLY FINANCIAL REPORT ===")
print("Period: " .. report.period_label)
print("Total Income: " .. report.total_income)
print("Total Expense: " .. report.total_expense)
print("Net Balance: " .. report.net_balance)
print("Profit Margin: " .. math.floor(report.profit_margin) .. "%")

print("\nLargest Funding: " .. report.largest_income_source)
print("Largest Expense: " .. report.largest_expense_category)

print("\nEfficiency Rating: " .. report.efficiency_rating .. "/100")

print("\nImprovements Needed:")
for _, area in ipairs(report.improvement_areas) do
  print("  - " .. area)
end
```

### Example 3: Monitor Organization Score

```lua
-- Get current score
local score = ScoreManager.getOrganizationScore()
local rating = ScoreManager.getRating()
local rank = ScoreManager.getRank()

print("=== ORGANIZATION PERFORMANCE ===")
print("Score: " .. score .. "/100")
print("Rating: " .. rating)
print("Rank: " .. rank .. "th percentile")

-- Component breakdown
print("\nComponent Scores:")
print("  Military: " .. ScoreManager.getMilitaryScore())
print("  Research: " .. ScoreManager.getResearchScore())
print("  Economic: " .. ScoreManager.getEconomicScore())
print("  Political: " .. ScoreManager.getPoliticalScore())
print("  Strategic: " .. ScoreManager.getStrategicScore())

-- Trend
local trend = ScoreManager.getScoreTrend()
print("\nTrend: " .. trend)
```

### Example 4: Monthly Budget

```lua
-- Calculate and display budget
local budget = FinanceSystem.calculateMonthlyBudget()

print("=== MONTHLY BUDGET ===")
print("Income:")
print("  Funding: $" .. budget.income_funding)
print("  Marketplace: $" .. budget.income_marketplace)
print("  Missions: $" .. budget.income_missions)
print("  TOTAL: $" .. budget.income_total)

print("\nExpenses:")
print("  Salaries: $" .. budget.expense_salaries)
print("  Base Upkeep: $" .. budget.expense_base_upkeep)
print("  Research: $" .. budget.expense_research)
print("  TOTAL: $" .. budget.expense_total)

print("\nBalance: $" .. budget.balance)

if budget.balance < 0 then
  print("WARNING: Deficit this month!")
end
```

### Example 5: Place Supply Order

```lua
local supplier = SupplierSystem.getSupplier("military_surplus")

-- Check price with relationship modifier
local riflePrice = supplier:getPrice("plasma_rifle")
print("Plasma Rifle: $" .. riflePrice .. " (relationship adjusted)")

-- Create order
local items = {
  ["plasma_rifle"] = 5,
  ["heavy_armor"] = 3,
}

local order, err = PurchaseSystem.createOrder(supplier, items)

if order then
  print("Order total: $" .. order:getTotal())
  
  -- Check if affordable
  if FinanceSystem.canAfford(order:getTotal()) then
    PurchaseSystem.submitOrder(order)
    print("Order placed. Delivery in " .. order:getEstimatedDelivery() .. " turns")
  else
    print("Insufficient funds")
  end
end
```

### Example 6: Payment Processing

```lua
-- Record payment on order
local order = PurchaseSystem.getAllOrders()[1]

if order:canPay() then
  local remaining = order:getAmountDue()
  
  -- Pay half now
  order:recordPayment(remaining / 2)
  print("Payment recorded: $" .. (remaining / 2))
  print("Remaining: $" .. order:getAmountDue())
  
  if not order:isPaid() then
    print("Final payment due on turn " .. order:getEstimatedDelivery())
  end
end
```

---

## Financial Formulas

### Monthly Income

**Country Funding:**
```
Amount = (Base Rate × Funding Level) × Relation Modifier
Example: (30,000 × 5) × 1.0 = 150,000 credits
```

**Mission Rewards:**
```
Amount = Base Reward × Difficulty Multiplier × Completion Bonus
Example: 10,000 × 1.5 × 1.2 = 18,000 credits
```

### Monthly Expenses

**Unit Salaries:**
```
Total = Unit Count × Salary per Unit
Example: 24 units × 500 = 12,000 credits
```

**Base Upkeep:**
```
Total = Base Cost + (Facility Count × Facility Upkeep)
Example: 5,000 + (10 × 1,000) = 15,000 credits
```

**Research Cost:**
```
Cost per Turn = Project Complexity × Active Project Count
Example: 5,000 × 2 = 10,000 credits
```

### Supplier Pricing

**Adjusted Price:**
```
Price = Base Price × Price Modifier × Relationship Multiplier
Relationship Multiplier: 0.5x (Allied) to 2.0x (Hostile)
Example: $1,000 × 1.0 × 1.5 = $1,500 (unfriendly supplier)
```

---

## Financial Health States

| Status | Balance | Action |
|--------|---------|--------|
| Healthy | > +50,000 | Can expand, invest in research |
| Warning | 0 to +50,000 | Maintain current spending |
| Critical | < 0 | Reduce expenses, seek income |

---

## Supplier Relationship Effects

| Level | Price | Delivery | Benefits |
|-------|-------|----------|----------|
| -2 (Hostile) | 2.0x | 30+ days | None |
| -1 (Unfriendly) | 1.5x | 21 days | None |
| 0 (Neutral) | 1.0x | 14 days | Standard |
| +1 (Friendly) | 0.75x | 7 days | Discounts |
| +2 (Allied) | 0.5x | 3 days | Best prices |

---

## Integration Points

**Inputs from:**
- Economy (transaction history)
- Countries (funding amounts, support levels)
- Basescape (maintenance costs)
- Personnel (salary costs)
- Research (project costs)
- Crafts (maintenance costs)
- Suppliers (pricing and availability)

**Outputs to:**
- UI (financial displays, score displays)
- Analytics (historical reporting)
- Events (financial milestones, crisis alerts)
- Purchase system (order management)
- Budget planning (income/expense forecasting)

**Dependencies:**
- Economy system (transactions)
- Country system (funding)
- Base system (maintenance)
- Personnel system (salaries)
- Supplier system (inventory and pricing)

---

## Error Handling

```lua
-- Invalid date range
if start_turn > end_turn then
  print("Invalid date range - start after end")
  return nil
end

-- No records in period
local records = FinanceTracker.getFinanceHistory(num_months)
if #records == 0 then
  print("No financial records in this period")
end

-- Country funding source not found
local source = FundingManager.getFundingSource("unknown_country")
if not source then
  print("Country not in funding sources")
end

-- Supplier not found
local supplier = SupplierSystem.getSupplier("unknown_supplier")
if not supplier then
  print("Supplier not found")
end

-- Insufficient funds for order
if not FinanceSystem.canAfford(order:getTotal()) then
  print("Insufficient funds - need $" .. order:getTotal())
end

-- Invalid payment term
if order:getStatus() == "delivered" and not order:isPaid() then
  print("Payment overdue on delivered order")
end

-- Supplier restocking
if supplier:needsRestock() then
  supplier:restockItems()
  print("Supplier has restocked inventory")
end
```

---

**Last Updated:** October 22, 2025  
**API Status:** ✅ COMPLETE  
**Coverage:** 100% (All entities, functions, TOML, examples, integration documented)  
**Consolidation:** FINANCE_DETAILED + FINANCE_EXPANDED merged into single comprehensive module
