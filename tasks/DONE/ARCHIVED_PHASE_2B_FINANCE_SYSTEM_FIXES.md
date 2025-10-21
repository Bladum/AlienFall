# Phase 2B: Finance System - Comprehensive Fixes

**Created:** October 21, 2025  
**Status:** TODO  
**Duration:** 6-8 hours  
**Priority:** HIGH  

---

## Executive Summary

The Finance system is 75% aligned with wiki design. This phase implements missing features:
1. **Personnel Cost Breakdown** - Detailed soldier/scientist/engineer salary system
2. **Supplier Relationship Pricing** - Dynamic pricing based on relations
3. **Budget Forecasting UI** - Player can predict monthly balance
4. **Finance Reporting** - Monthly statement with breakdowns

---

## Gap Analysis

### Gap #1: Personnel Cost Breakdown

**Current Status:** Likely simplified or missing
- ✅ Base costs may exist
- ⚠️ No breakdown by role (soldier/scientist/engineer)
- ⚠️ No salary scaling by experience/rank
- ⚠️ No casualty replacement costs

**Wiki Requirement:**
```
Soldier: 100 credits/month
Scientist: 150 credits/month
Engineer: 150 credits/month
Commander: 300 credits/month
Casualty replacement: 500 credits (one-time)
```

**Fix Required:**
1. ⚠️ Implement role-based salary system
2. ⚠️ Add experience/rank multiplier (10-30% variation)
3. ⚠️ Implement casualty replacement cost
4. ⚠️ Track personnel by type in financial reporting

---

### Gap #2: Supplier Relationship Pricing

**Current Status:** Likely using fixed prices
- ⚠️ Supplier system exists but pricing may be static
- ❌ Relations not affecting prices
- ❌ Supplier market variation missing
- ❌ Regional price differences missing

**Wiki Requirement:**
```
Relations Affect Pricing:
- Hostile (<-50): 1.5x base price (premium)
- Neutral (-50 to 0): 1.0x base price
- Friendly (0 to +50): 0.9x base price (discount)
- Allied (>+50): 0.8x base price (bulk discount)

Regional Variation: ±10% based on market
Black Market: 2.0x price but no traceability
```

**Fix Required:**
1. ⚠️ Add relations multiplier to price calculation
2. ⚠️ Implement regional price variance
3. ⚠️ Add black market option (higher cost, no trace)
4. ⚠️ Update marketplace UI to show multipliers

---

### Gap #3: Budget Forecasting UI

**Current Status:** Missing (likely)
- ❌ No budget prediction system
- ❌ No forecast display
- ❌ No "what if" planning

**Wiki Requirement:**
```
Budget Forecast:
- Show predicted balance for next 3 months
- If building facility: Show impact
- If hiring unit: Show impact
- If changing research: Show impact
- Warning if balance goes negative
```

**Fix Required:**
1. ❌ Create budget forecasting system
2. ❌ Implement "what-if" scenarios
3. ❌ Add forecast UI screen
4. ❌ Add warning alerts

---

### Gap #4: Finance Reporting System

**Current Status:** May exist but incomplete
- ⚠️ Monthly statement may be basic
- ⚠️ No detailed breakdown
- ⚠️ No historical tracking

**Wiki Requirement:**
```
Monthly Report:
- Income sources breakdown
- Expense categories breakdown
- Net balance calculation
- Year-to-date tracking
- Relations multiplier shown
- Budget status indicator
```

**Fix Required:**
1. ⚠️ Enhance monthly report detail
2. ⚠️ Add historical tracking
3. ⚠️ Add relations impact display
4. ⚠️ Implement budget status color-coding

---

## Implementation Plan

### Phase 2B.1: Personnel Cost Breakdown (1-2 hours)

#### Step 1.1: Analyze Current Personnel System
```bash
Files to Review:
- engine/geoscape/systems/funding_manager.lua
- engine/basescape/base_manager.lua (personnel tracking)
- engine/core/units/ (unit definitions)
```

**Tasks:**
- [ ] Find personnel cost calculation
- [ ] Check if roles are tracked
- [ ] Identify current cost formula

#### Step 1.2: Implement Role-Based Salaries
```lua
-- Personnel salary system
local PersonnelSystem = {}

PersonnelSystem.ROLES = {
  SOLDIER = "soldier",
  SCIENTIST = "scientist",
  ENGINEER = "engineer",
  COMMANDER = "commander"
}

PersonnelSystem.BASE_SALARY = {
  soldier = 100,
  scientist = 150,
  engineer = 150,
  commander = 300
}

-- Calculate salary with experience multiplier
function PersonnelSystem:calculateSalary(role, experience_level)
  local base = self.BASE_SALARY[role]
  
  -- Experience multiplier: 1.0 to 1.3 (10% per rank)
  local exp_multiplier = 1.0 + (experience_level * 0.1)
  
  -- Clamp to reasonable range
  exp_multiplier = math.min(exp_multiplier, 1.3)
  
  return math.floor(base * exp_multiplier)
end

-- Get total monthly personnel costs
function PersonnelSystem:calculateTotalPersonnelCosts(base)
  local total = 0
  
  -- Sum salaries from all units in base
  for _, unit in ipairs(base.units) do
    local salary = self:calculateSalary(unit.role, unit.experience_level)
    total = total + salary
  end
  
  -- Add scientist costs
  for _, scientist in ipairs(base.scientists) do
    local salary = self:calculateSalary("scientist", scientist.level)
    total = total + salary
  end
  
  -- Add engineer costs
  for _, engineer in ipairs(base.engineers) do
    local salary = self:calculateSalary("engineer", engineer.level)
    total = total + salary
  end
  
  return total
end

-- Handle casualty replacement
function PersonnelSystem:handleCasualty(base, unit)
  -- Remove unit cost
  -- Add replacement cost (one-time)
  base.budget = base.budget - 500  -- Casualty replacement
  
  -- Trigger recruitment notification
  return 500  -- Cost incurred
end

return PersonnelSystem
```

**Tasks:**
- [ ] Create `personnel_system.lua`
- [ ] Implement salary calculation
- [ ] Add experience multiplier
- [ ] Implement casualty cost
- [ ] Integrate into budget calculation

#### Step 1.3: Track Personnel in Budget
```lua
-- Update funding calculation
function CalculateMonthlyExpenses(base)
  local expenses = {
    maintenance = 0,
    personnel = 0,
    supplies = 0,
    research_boost = 0,
    other = 0
  }
  
  -- Facility maintenance
  for _, facility in ipairs(base.facilities) do
    expenses.maintenance = expenses.maintenance + facility.maintenance_cost
  end
  
  -- Personnel costs (NEW)
  expenses.personnel = PersonnelSystem:calculateTotalPersonnelCosts(base)
  
  -- Supply costs
  expenses.supplies = 1200  -- Ammunition, medical, etc.
  
  -- Research acceleration (optional)
  if base.research_boost_funded then
    expenses.research_boost = 800
  end
  
  -- Total
  local total = expenses.maintenance + expenses.personnel + 
                expenses.supplies + expenses.research_boost + expenses.other
  
  return total, expenses  -- Return breakdown too
end
```

**Tasks:**
- [ ] Update expense calculation
- [ ] Add personnel breakdown
- [ ] Return detailed expense structure
- [ ] Update financial reporting to show breakdown

---

### Phase 2B.2: Supplier Relationship Pricing (1.5-2 hours)

#### Step 2.1: Create Relations Pricing System
```lua
-- Supplier pricing system with relations
local SupplierPricingSystem = {}

-- Get price multiplier based on relations
function SupplierPricingSystem:getRelationsMultiplier(supplier, relations_value)
  if relations_value < -50 then
    return 1.5  -- Hostile: premium price
  elseif relations_value < 0 then
    return 1.0 + (relations_value / -50) * 0.5  -- Interpolate to 1.0
  elseif relations_value < 50 then
    return 1.0 - (relations_value / 50) * 0.1  -- Discount to 0.9
  else
    return 0.8  -- Allied: bulk discount
  end
end

-- Get regional price variance
function SupplierPricingSystem:getRegionalVariance(region, seed)
  -- Pseudo-random based on region and seed
  local variance = ((region * 7 + seed) % 100) / 100
  
  -- Range: -10% to +10%
  local multiplier = 0.9 + (variance * 0.2)
  
  return multiplier
end

-- Calculate final item price
function SupplierPricingSystem:calculatePrice(base_price, supplier, relations)
  local relations_mult = self:getRelationsMultiplier(supplier, relations)
  local regional_mult = self:getRegionalVariance(supplier.region, os.time())
  
  local final_price = base_price * relations_mult * regional_mult
  
  return math.floor(final_price)
end

-- Check black market price
function SupplierPricingSystem:getBlackMarketPrice(base_price)
  return math.floor(base_price * 2.0)  -- Double price
end

-- Get price description for UI
function SupplierPricingSystem:getPriceDescription(item_price, base_price)
  local ratio = item_price / base_price
  
  if ratio > 1.4 then
    return "EXPENSIVE", "Relations penalty or market shortage"
  elseif ratio > 1.1 then
    return "HIGHER", "Market rates fluctuating"
  elseif ratio < 0.9 then
    return "CHEAPER", "Good supplier relations or sale"
  else
    return "NORMAL", "Market standard price"
  end
end

return SupplierPricingSystem
```

**Tasks:**
- [ ] Create `supplier_pricing_system.lua`
- [ ] Implement relations multiplier
- [ ] Implement regional variance
- [ ] Implement black market pricing
- [ ] Add price description helper

#### Step 2.2: Integrate into Marketplace
```lua
-- Update marketplace with relations pricing
function GetItemPrice(marketplace, item_id, supplier_id)
  local item = marketplace:getItem(item_id)
  local supplier = marketplace:getSupplier(supplier_id)
  local relations = RelationsSystem:getRelations(supplier.faction)
  
  -- Get base price
  local base_price = item.base_price
  
  -- Calculate final price with relations
  local final_price = PricingSystem:calculatePrice(
    base_price, 
    supplier, 
    relations
  )
  
  return final_price
end

-- Display price in UI with multiplier
function DisplayItemPrice(item, supplier, final_price, base_price)
  local relation_mult = final_price / base_price
  
  ui:drawText(string.format("Price: %d", final_price), x, y)
  ui:drawText(string.format("(Base: %d)", base_price), x, y + 16)
  
  if relation_mult > 1.1 then
    ui:setColor(255, 100, 100)  -- Red (expensive)
  elseif relation_mult < 0.9 then
    ui:setColor(100, 255, 100)  -- Green (cheap)
  else
    ui:setColor(200, 200, 200)  -- Gray (normal)
  end
  
  ui:drawText(string.format("Multiplier: %.1fx", relation_mult), x, y + 32)
end
```

**Tasks:**
- [ ] Update marketplace item pricing
- [ ] Add relations lookup
- [ ] Calculate dynamic prices
- [ ] Update UI to show multipliers

#### Step 2.3: Test Relations Impact
```lua
-- Test scenarios
test_pricing = {
  {
    name = "Hostile supplier expensive",
    base_price = 1000,
    relations = -75,
    expected_mult = 1.5,
    expected_price = 1500
  },
  {
    name = "Allied supplier discounted",
    base_price = 1000,
    relations = 75,
    expected_mult = 0.8,
    expected_price = 800
  },
  {
    name = "Neutral supplier normal",
    base_price = 1000,
    relations = 0,
    expected_mult = 1.0,
    expected_price = 1000
  }
}
```

**Tasks:**
- [ ] Create pricing test scenarios
- [ ] Verify multipliers calculated correctly
- [ ] Verify UI displays correctly

---

### Phase 2B.3: Budget Forecasting UI (2-3 hours)

#### Step 3.1: Create Forecasting Engine
```lua
-- Budget forecasting system
local BudgetForecast = {}

-- Project next N months of budget
function BudgetForecast:projectMonths(base, months_ahead)
  local projections = {}
  
  for month = 1, months_ahead do
    local projection = {
      month = month,
      income = 0,
      expenses = 0,
      balance = 0,
      status = "normal"
    }
    
    -- Calculate base income
    projection.income = self:calculateProjectedIncome(base)
    
    -- Calculate base expenses
    projection.expenses = self:calculateProjectedExpenses(base)
    
    -- Net balance
    projection.balance = projection.income - projection.expenses
    
    -- Determine status
    if projection.balance < 0 then
      projection.status = "deficit"
    elseif projection.balance < 1000 then
      projection.status = "tight"
    else
      projection.status = "healthy"
    end
    
    table.insert(projections, projection)
  end
  
  return projections
end

-- Project what-if scenarios
function BudgetForecast:projectWithChange(base, change)
  -- Change types: build_facility, hire_unit, research_boost, etc.
  
  local projection = self:projectMonths(base, 3)[1]
  
  if change.type == "build_facility" then
    -- One-time cost
    projection.expenses = projection.expenses + change.cost
    projection.one_time_cost = change.cost
  elseif change.type == "hire_unit" then
    -- Add recurring salary cost
    projection.expenses = projection.expenses + 100  -- Monthly soldier cost
  elseif change.type == "research_boost" then
    -- Add research acceleration cost
    projection.expenses = projection.expenses + 800
  elseif change.type == "expanded_base" then
    -- Multiple impacts
    projection.expenses = projection.expenses + 500  -- Extra facilities
    projection.income = projection.income - 200  -- Expansion delays operations
  end
  
  projection.balance = projection.income - projection.expenses
  
  return projection
end

-- Get forecast description
function BudgetForecast:getForecastDescription(projection)
  local status_text = {
    healthy = "✓ Comfortable surplus",
    tight = "⚠ Tight budget",
    deficit = "✗ Cannot afford - deficit"
  }
  
  return status_text[projection.status] or "? Unknown"
end

return BudgetForecast
```

**Tasks:**
- [ ] Create `budget_forecast.lua`
- [ ] Implement projection algorithm
- [ ] Implement what-if scenarios
- [ ] Implement status determination

#### Step 3.2: Create Budget Forecast UI Screen
```lua
-- Budget forecast UI screen
local BudgetForecastScreen = {}

function BudgetForecastScreen:draw(base)
  local forecast = BudgetForecast:projectMonths(base, 6)
  
  -- Title
  ui:drawText("BUDGET FORECAST", 100, 20, {color = {200, 200, 255}})
  
  -- Current month header
  local current_balance = base:calculateCurrentBalance()
  ui:drawText(string.format("Current Balance: %d credits", current_balance), 
              100, 50, {color = {100, 255, 100}})
  
  -- Forecast table
  local y = 80
  ui:drawText("Month | Income | Expenses | Balance | Status", 100, y)
  ui:drawRect(100, y + 5, 400, 2)  -- Separator line
  y = y + 20
  
  for i, proj in ipairs(forecast) do
    local color = {100, 255, 100}  -- Green
    if proj.status == "tight" then
      color = {255, 255, 100}  -- Yellow
    elseif proj.status == "deficit" then
      color = {255, 100, 100}  -- Red
    end
    
    ui:drawText(
      string.format("%d | %d | %d | %d | %s",
        i, proj.income, proj.expenses, proj.balance, proj.status),
      100, y, {color = color}
    )
    
    y = y + 20
  end
  
  -- What-if buttons
  y = y + 40
  ui:drawText("What-If Scenarios:", 100, y)
  y = y + 20
  
  self:drawWhatIfButton("Build Facility", 100, y, 
    {type = "build_facility", cost = 8000})
  y = y + 25
  
  self:drawWhatIfButton("Hire Unit", 100, y,
    {type = "hire_unit"})
  y = y + 25
  
  self:drawWhatIfButton("Research Boost", 100, y,
    {type = "research_boost", cost = 800})
  
end

function BudgetForecastScreen:drawWhatIfButton(label, x, y, change)
  local proj = BudgetForecast:projectWithChange(current_base, change)
  local status = BudgetForecast:getForecastDescription(proj)
  
  ui:drawText(label .. ": " .. status, x, y)
end

return BudgetForecastScreen
```

**Tasks:**
- [ ] Create `budget_forecast_screen.lua`
- [ ] Implement forecast table display
- [ ] Implement what-if buttons
- [ ] Add to UI navigation

---

### Phase 2B.4: Enhanced Financial Reporting (1-2 hours)

#### Step 4.1: Create Finance Report System
```lua
-- Enhanced financial reporting
local FinanceReport = {}

-- Generate monthly finance report
function FinanceReport:generateMonthlyReport(base, game_state)
  local report = {
    month = game_state.current_month,
    year = game_state.current_year,
    
    -- Income breakdown
    income = {
      country_funding = 0,
      mission_rewards = 0,
      alien_salvage = 0,
      other = 0,
      relations_multiplier = 1.0,
      total = 0
    },
    
    -- Expense breakdown
    expenses = {
      facility_maintenance = 0,
      personnel = 0,
      supplies = 0,
      research_acceleration = 0,
      construction = 0,
      other = 0,
      total = 0
    },
    
    -- Summary
    net_balance = 0,
    year_to_date = 0,
    status = "healthy"
  }
  
  -- Calculate income sources
  report.income.country_funding = self:calculateCountryFunding(base, game_state)
  report.income.mission_rewards = base.mission_income or 0
  report.income.alien_salvage = base.salvage_income or 0
  report.income.relations_multiplier = RelationsSystem:getAverageFundingMultiplier()
  report.income.total = math.floor(
    (report.income.country_funding + report.income.mission_rewards + 
     report.income.alien_salvage) * report.income.relations_multiplier
  )
  
  -- Calculate expenses
  local expenses_breakdown = self:calculateExpensesBreakdown(base)
  report.expenses = expenses_breakdown
  
  -- Calculate balance
  report.net_balance = report.income.total - report.expenses.total
  report.year_to_date = base.year_to_date_balance or 0
  
  -- Determine status
  if report.net_balance < 0 then
    report.status = "deficit"
  elseif report.net_balance < 1000 then
    report.status = "tight"
  else
    report.status = "healthy"
  end
  
  return report
end

-- Display financial report
function FinanceReport:displayReport(report)
  ui:newScreen("Finance Report")
  
  -- Title
  ui:drawText(string.format("FINANCE REPORT - %s %d", 
    MONTH_NAMES[report.month], report.year), 50, 30, 
    {size = "large", color = {200, 200, 255}})
  
  -- Income section
  ui:drawText("INCOME:", 50, 80, {color = {100, 255, 100}})
  ui:drawText(string.format("  Country Funding: %d", report.income.country_funding), 70, 100)
  ui:drawText(string.format("  Mission Rewards: %d", report.income.mission_rewards), 70, 120)
  ui:drawText(string.format("  Alien Salvage: %d", report.income.alien_salvage), 70, 140)
  ui:drawText(string.format("  Relations Multiplier: %.1fx", report.income.relations_multiplier), 70, 160)
  ui:drawText(string.format("  TOTAL INCOME: %d", report.income.total), 50, 180, 
    {color = {150, 255, 150}, bold = true})
  
  -- Expense section
  local y = 220
  ui:drawText("EXPENSES:", 50, y, {color = {255, 100, 100}})
  ui:drawText(string.format("  Facility Maintenance: %d", report.expenses.facility_maintenance), 70, y + 20)
  ui:drawText(string.format("  Personnel: %d", report.expenses.personnel), 70, y + 40)
  ui:drawText(string.format("  Supplies: %d", report.expenses.supplies), 70, y + 60)
  ui:drawText(string.format("  Research Acceleration: %d", report.expenses.research_acceleration), 70, y + 80)
  ui:drawText(string.format("  Construction: %d", report.expenses.construction), 70, y + 100)
  ui:drawText(string.format("  TOTAL EXPENSES: %d", report.expenses.total), 50, y + 120,
    {color = {255, 150, 150}, bold = true})
  
  -- Balance section
  local balance_color = {100, 255, 100}  -- Green
  if report.status == "tight" then
    balance_color = {255, 255, 100}
  elseif report.status == "deficit" then
    balance_color = {255, 100, 100}
  end
  
  y = y + 160
  ui:drawText(string.format("MONTHLY BALANCE: %d", report.net_balance), 50, y,
    {color = balance_color, bold = true})
  ui:drawText(string.format("YEAR-TO-DATE: %d", report.year_to_date), 50, y + 30,
    {color = balance_color})
  
  -- Status indicator
  local status_text = {
    healthy = "✓ HEALTHY",
    tight = "⚠ TIGHT",
    deficit = "✗ DEFICIT - URGENT ACTION REQUIRED"
  }
  ui:drawText("Status: " .. status_text[report.status], 50, y + 60,
    {color = balance_color, bold = true})
  
  ui:endScreen()
end

return FinanceReport
```

**Tasks:**
- [ ] Create `finance_report.lua`
- [ ] Implement report generation
- [ ] Implement report UI display
- [ ] Integrate into game UI

#### Step 4.2: Track Historical Data
```lua
-- Track financial history
function TrackFinancialHistory(base, report)
  if not base.financial_history then
    base.financial_history = {}
  end
  
  -- Store this month's report
  table.insert(base.financial_history, {
    month = report.month,
    year = report.year,
    balance = report.net_balance,
    status = report.status
  })
  
  -- Trim history to last 12 months
  if #base.financial_history > 12 then
    table.remove(base.financial_history, 1)
  end
  
  -- Calculate year-to-date
  base.year_to_date_balance = 0
  for _, entry in ipairs(base.financial_history) do
    base.year_to_date_balance = base.year_to_date_balance + entry.balance
  end
end
```

**Tasks:**
- [ ] Implement financial history tracking
- [ ] Limit history to 12 months
- [ ] Calculate year-to-date balance
- [ ] Display history in UI (optional graph)

---

## Testing Strategy

### Manual Testing Checklist

```
Personnel Costs:
[ ] Soldiers cost 100 credits/month
[ ] Scientists cost 150 credits/month
[ ] Engineers cost 150 credits/month
[ ] Experienced units cost more (10-30% bonus)
[ ] Casualty costs 500 credits one-time

Supplier Pricing:
[ ] Hostile suppliers 1.5x price
[ ] Neutral suppliers 1.0x price
[ ] Friendly suppliers 0.9x price
[ ] Allied suppliers 0.8x price
[ ] Regional variance ±10% working
[ ] Black market costs 2.0x

Budget Forecast:
[ ] 6-month projection shows correct balances
[ ] Building facility shows impact on forecast
[ ] Hiring unit shows impact on forecast
[ ] Research boost shows impact on forecast
[ ] Deficit warning appears when balance < 0

Financial Reporting:
[ ] Monthly report shows income breakdown
[ ] Monthly report shows expense breakdown
[ ] Relations multiplier displayed
[ ] Year-to-date tracking working
[ ] Status color-coding correct (green/yellow/red)
```

### Console Verification
```bash
Run command:
lovec "engine"

Watch console for:
- Personnel cost calculation logged
- Supplier pricing multipliers calculated
- Budget forecast generated
- Finance report generated
- No error messages
```

---

## Success Criteria

Phase 2B is complete when:

✅ **Personnel Costs:**
- [ ] All salary amounts correct
- [ ] Experience multipliers applied
- [ ] Casualty costs charged
- [ ] Expense breakdown includes personnel

✅ **Supplier Pricing:**
- [ ] Relations affect prices
- [ ] Multipliers match wiki (0.8x-1.5x)
- [ ] Regional variation ±10% working
- [ ] Black market option available

✅ **Budget Forecast:**
- [ ] 6-month projection generated
- [ ] What-if scenarios working
- [ ] Status color-coding correct
- [ ] Deficit warning displays

✅ **Finance Reporting:**
- [ ] Monthly report detailed breakdown
- [ ] Historical tracking working
- [ ] Year-to-date calculation correct
- [ ] UI displays correctly

✅ **No Errors:**
- [ ] Love2D console error-free
- [ ] All calculations verified
- [ ] UI responsive

---

## Time Estimate

- Step 1.1 (Analyze personnel): 30 min
- Step 1.2 (Implement salaries): 45 min
- Step 1.3 (Track in budget): 15 min
- Step 2.1 (Pricing system): 45 min
- Step 2.2 (Integrate marketplace): 45 min
- Step 2.3 (Test pricing): 30 min
- Step 3.1 (Forecasting engine): 45 min
- Step 3.2 (UI screen): 1 hour
- Step 4.1 (Report system): 45 min
- Step 4.2 (Historical tracking): 30 min
- Final (Testing & docs): 1 hour

**Total: 7-8 hours**

---

**Next:** Phase 2C will enhance AI systems.
