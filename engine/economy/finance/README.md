# Finance System

**Status:** Core Implementation Complete (UI pending)  
**Priority:** Medium  
**Version:** 1.0 (October 16, 2025)

---

## Overview

Centralized financial management system handling global treasury, monthly income/expense cycles, budget allocation, and loan management. Provides the financial backbone for all game operations.

---

## Implemented Features

### Treasury System (`treasury.lua`)
- **Central Treasury**: Single unified funds pool
- **Balance Tracking**: Real-time balance monitoring
- **Income Categories**: Mission rewards, government grants, research bonuses, trade profits
- **Expense Categories**: Personnel salaries, facility maintenance, equipment procurement, research investment, debt interest
- **Monthly Processing**: Automated monthly financial cycles with income/expense calculation
- **Loan Management**: Take loans with interest, automatic payment processing
- **Budget Allocation**: Flexible budget percentages for resource allocation
- **Financial History**: Complete historical tracking of all transactions

### Financial Manager (`financial_manager.lua`)
- **Income Aggregation**: Collects income from multiple registered sources
- **Expense Aggregation**: Collects expenses from multiple registered sources
- **Financial Events**: Notifications for surplus, deficit, low funds, bankruptcy
- **Orchestration**: Coordinates monthly financial processing across all systems
- **Report Generation**: Comprehensive financial reports and status
- **Event System**: Hook system for other systems to respond to financial events

---

## API Reference

### Treasury System

```lua
local Treasury = require("engine.economy.finance.treasury")
local treasury = Treasury:new(initialFunds)

-- Core Operations
treasury:addIncome(category, amount)           -- Add income
treasury:deductExpense(category, amount)       -- Deduct expense
treasury:takeLoan(amount, rate, months)        -- Take loan
treasury:processMonthlyFinances(income, expenses) -- Process month

-- Budget Management
treasury:setBudgetAllocation(allocation)       -- Set budget percentages
treasury:calculateMonthlyAllocation(funds)     -- Calculate allocation

-- Queries
treasury:getBalance()                          -- Get current balance
treasury:getFinancialReport(months)            -- Get report
treasury:getStatus()                           -- Get status string
```

### Financial Manager

```lua
local FinancialManager = require("engine.economy.finance.financial_manager")
local manager = FinancialManager:new(initialFunds)

-- Registration
manager:registerIncomeSource(name, function)   -- Register income source
manager:registerExpenseSource(name, function)  -- Register expense source

-- Processing
manager:processMonthlyFinances()               -- Process monthly cycle

-- Events
manager:onFinancialEvent(eventName, callback)  -- Register for events
manager:notifyEvent(eventName, data)           -- Trigger event

-- Manual Operations
manager:addIncome(category, amount)            -- Add income
manager:addExpense(category, amount)           -- Add expense

-- Queries
manager:getBalance()                           -- Get balance
manager:getReport(months)                      -- Get report
manager:getStatus()                            -- Get status
```

---

## Integration Points

### Income Sources (to register)
```lua
manager:registerIncomeSource("missions", function()
    -- Return mission rewards this month
    return missionRewards, "mission_reward"
end)

manager:registerIncomeSource("government", function()
    -- Return government grants based on reputation
    return governmentGrant, "government_grant"
end)

manager:registerIncomeSource("research", function()
    -- Return research bonuses
    return researchBonus, "research_bonus"
end)

manager:registerIncomeSource("marketplace", function()
    -- Return trade profits
    return tradeProfits, "trade_profit"
end)
```

### Expense Sources (to register)
```lua
manager:registerExpenseSource("personnel", function()
    -- Return salary costs
    return salaryTotal, "personnel_salary"
end)

manager:registerExpenseSource("facilities", function()
    -- Return maintenance costs
    return maintenanceCost, "facility_maintenance"
end)

manager:registerExpenseSource("equipment", function()
    -- Return procurement costs
    return procurementCost, "equipment_procurement"
end)

manager:registerExpenseSource("research", function()
    -- Return research investment
    return researchCost, "research_investment"
end)
```

### Financial Events (to hook into)
```lua
manager:onFinancialEvent("surplus", function(amount)
    print("Financial surplus: " .. amount)
end)

manager:onFinancialEvent("deficit", function(amount)
    print("Financial deficit: " .. amount)
end)

manager:onFinancialEvent("low_funds_warning", function(balance)
    print("WARNING: Low funds - " .. balance)
end)

manager:onFinancialEvent("bankruptcy", function(debt)
    print("CRITICAL: Bankruptcy! Debt: " .. debt)
end)
```

---

## Usage Example

```lua
-- Initialize
local FinancialManager = require("engine.economy.finance.financial_manager")
local finance = FinancialManager:new(1000000)  -- Start with 1 million

-- Register income sources
finance:registerIncomeSource("missions", getMissionRewards)
finance:registerIncomeSource("government", getGovernmentFunding)

-- Register expense sources
finance:registerExpenseSource("salaries", getPersonnelCosts)
finance:registerExpenseSource("facilities", getFacilityMaintenanceCosts)

-- Hook into events
finance:onFinancialEvent("deficit", function(amount)
    notifyPlayer("Financial deficit of $" .. amount)
end)

-- Monthly processing
local report = finance:processMonthlyFinances()

-- Access financial data
local balance = finance:getBalance()
local report = finance:getReport(12)
local status = finance:getStatus()
```

---

## Technical Details

### Monthly Processing Flow
1. Calculate monthly income from all registered sources
2. Calculate monthly expenses from all registered sources
3. Process loan payments with interest
4. Update treasury balance
5. Check for financial events (surplus, deficit, bankruptcy)
6. Generate monthly report
7. Trigger financial events for other systems

### Budget Allocation
```lua
local allocation = {
    personnel_salary = 40,      -- 40% for salaries
    facility_maintenance = 25,  -- 25% for maintenance
    research_investment = 20,   -- 20% for research
    equipment_procurement = 10, -- 10% for equipment
    contingency = 5             -- 5% emergency fund
}

finance:setBudgetAllocation(allocation)
local recommended = finance.treasury:calculateMonthlyAllocation(availableFunds)
```

### Loan System
```lua
-- Take a loan
finance:takeLoan(500000, 0.08, 12)  -- $500k at 8% annual for 12 months

-- Automatic processing
-- - Monthly payment calculated
-- - Interest applied
-- - Payment deducted from balance
-- - Loan cleared when term expires
```

---

## Performance

- **Treasury Operations**: O(1) for all core operations
- **Monthly Processing**: O(n) where n = number of income/expense sources
- **Financial Reports**: O(m) where m = months of history
- **Loan Processing**: O(l) where l = number of active loans

---

## Files

- `treasury.lua` - Core treasury system (525 lines)
- `financial_manager.lua` - Financial management coordination (440 lines)
- `README.md` - This documentation

---

## Future Enhancements

- **Investment System**: Passive income generation
- **Market Integration**: Dynamic pricing based on market conditions
- **Financial Forecasting**: Predict future cash flow
- **Budget Constraints**: Enforce budget limits
- **Financial Reporting UI**: Visual financial dashboards
- **Economic Events**: Random market disruptions
- **Insurance System**: Protect against losses
- **Tax System**: Government taxation mechanics
