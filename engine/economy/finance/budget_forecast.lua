--- Budget Forecasting System - Financial projection and what-if analysis
---
--- Projects future budget states and allows "what-if" scenario analysis
--- to help players understand the financial impact of decisions.
---
--- Key Features:
--- - Multi-month budget projection (3-6 months ahead)
--- - What-if scenarios (facility construction, hiring, research, etc)
--- - Budget status determination (healthy/tight/deficit)
--- - Predictive warnings for bankruptcy risk
---
--- Usage:
---   local Forecast = require("engine.economy.finance.budget_forecast")
---   local forecast = Forecast:new()
---   local projections = forecast:projectMonths(base, 6)
---   local whatIf = forecast:projectWithChange(base, {type = "build_facility", cost = 8000})
---
--- @module engine.economy.finance.budget_forecast
--- @author AlienFall Development Team

local BudgetForecast = {}
BudgetForecast.__index = BudgetForecast

--- Budget status definitions
BudgetForecast.STATUS = {
    HEALTHY = "healthy",      -- Good surplus (>1000)
    TIGHT = "tight",          -- Low surplus (0-1000)
    DEFICIT = "deficit",      -- Negative balance
    WARNING = "warning"       -- Running out of funds
}

--- Initialize Budget Forecast System
---@return table BudgetForecast instance
function BudgetForecast:new()
    local self = setmetatable({}, BudgetForecast)
    print("[BudgetForecast] Initialized")
    return self
end

--- Project monthly budget for N months ahead
---
--- Creates projections assuming current income/expense rates continue.
--- Each projection includes income, expenses, balance, and status.
---
---@param base table Base object with financial data
---@param monthsAhead number Number of months to project (default: 3)
---@return table Array of projections, each with {month, income, expenses, balance, status}
function BudgetForecast:projectMonths(base, monthsAhead)
    monthsAhead = math.max(1, math.min(monthsAhead or 3, 12))  -- Clamp 1-12
    
    local projections = {}
    
    -- Get current base income and expenses
    local currentIncome = base.monthlyIncome or 10000
    local currentExpenses = base.monthlyExpenses or 5000
    
    local runningBalance = base.credits or 100000
    
    for month = 1, monthsAhead do
        local projection = {
            month = month,
            income = currentIncome,
            expenses = currentExpenses,
            balance = 0,
            runningBalance = 0,
            status = "healthy",
            statusDescription = ""
        }
        
        -- Calculate net balance for this month
        projection.balance = projection.income - projection.expenses
        
        -- Calculate running balance
        runningBalance = runningBalance + projection.balance
        projection.runningBalance = runningBalance
        
        -- Determine status based on running balance
        if runningBalance < 0 then
            projection.status = self.STATUS.DEFICIT
            projection.statusDescription = "BANKRUPT"
        elseif runningBalance < 2000 then
            projection.status = self.STATUS.WARNING
            projection.statusDescription = "CRITICAL - Running out of funds"
        elseif runningBalance < 5000 then
            projection.status = self.STATUS.TIGHT
            projection.statusDescription = "TIGHT - Budget constrained"
        else
            projection.status = self.STATUS.HEALTHY
            projection.statusDescription = "OK - Adequate funds"
        end
        
        table.insert(projections, projection)
        
        print(string.format("[BudgetForecast] Month %d: Income %d - Expenses %d = Balance %d (Status: %s)",
            month, projection.income, projection.expenses, projection.balance, projection.status))
    end
    
    return projections
end

--- Project budget with a single change/scenario
---
--- Simulates the impact of a specific action (building, hiring, research)
--- on the first month of projections.
---
---@param base table Base object
---@param change table Change details: {type, cost?, monthly_cost?, months?}
--- Types: "build_facility", "hire_unit", "research_boost", "expanded_base", "emergency_expense"
---@return table Single projection with the change applied
function BudgetForecast:projectWithChange(base, change)
    change = change or {}
    
    -- Get base projection
    local baseProj = self:projectMonths(base, 1)[1]
    
    -- Create modified projection
    local projection = {
        month = baseProj.month,
        income = baseProj.income,
        expenses = baseProj.expenses,
        balance = baseProj.balance,
        runningBalance = baseProj.runningBalance,
        status = baseProj.status,
        statusDescription = baseProj.statusDescription,
        changes = {}
    }
    
    -- Apply change based on type
    if change.type == "build_facility" then
        -- One-time construction cost
        local cost = change.cost or 50000
        projection.expenses = projection.expenses + cost
        table.insert(projection.changes, {
            type = "facility_construction",
            cost = cost,
            description = "Facility construction"
        })
    elseif change.type == "hire_unit" then
        -- Monthly salary increase
        local monthlyCost = change.monthly_cost or 100  -- Soldier base salary
        projection.expenses = projection.expenses + monthlyCost
        table.insert(projection.changes, {
            type = "unit_recruitment",
            monthlyCost = monthlyCost,
            description = "New unit salary"
        })
    elseif change.type == "research_boost" then
        -- Research acceleration cost
        local cost = change.cost or 800
        projection.expenses = projection.expenses + cost
        table.insert(projection.changes, {
            type = "research_acceleration",
            cost = cost,
            description = "Accelerated research"
        })
    elseif change.type == "expanded_base" then
        -- Multiple impacts from base expansion
        local constructionCost = change.cost or 500
        local operationCost = 200
        local incomeLoss = 200
        projection.expenses = projection.expenses + constructionCost + operationCost
        projection.income = projection.income - incomeLoss
        table.insert(projection.changes, {
            type = "base_expansion",
            constructionCost = constructionCost,
            operationCost = operationCost,
            incomeLoss = incomeLoss,
            description = "Base expansion (construction + operation - efficiency)"
        })
    elseif change.type == "emergency_expense" then
        -- One-time emergency cost
        local cost = change.cost or 10000
        projection.expenses = projection.expenses + cost
        table.insert(projection.changes, {
            type = "emergency",
            cost = cost,
            description = "Emergency expense"
        })
    elseif change.type == "supply_run" then
        -- Restocking supplies and ammunition
        local cost = change.cost or 3000
        projection.expenses = projection.expenses + cost
        table.insert(projection.changes, {
            type = "supply_purchase",
            cost = cost,
            description = "Supply restocking"
        })
    end
    
    -- Recalculate balance and status
    projection.balance = projection.income - projection.expenses
    projection.runningBalance = (base.credits or 100000) + projection.balance
    
    -- Update status
    if projection.runningBalance < 0 then
        projection.status = self.STATUS.DEFICIT
        projection.statusDescription = "✗ BANKRUPT - Cannot afford"
    elseif projection.runningBalance < 2000 then
        projection.status = self.STATUS.WARNING
        projection.statusDescription = "✗ CRITICAL - Cannot afford safely"
    elseif projection.runningBalance < 5000 then
        projection.status = self.STATUS.TIGHT
        projection.statusDescription = "⚠ TIGHT - Risky"
    else
        projection.status = self.STATUS.HEALTHY
        projection.statusDescription = "✓ OK - Affordable"
    end
    
    print(string.format("[BudgetForecast] What-if (%s): New balance %d (Status: %s)",
        change.type or "unknown", projection.runningBalance, projection.status))
    
    return projection
end

--- Get forecast description
---
--- Returns human-readable description of forecast status.
---
---@param projection table Projection entry
---@return string Description
function BudgetForecast:getForecastDescription(projection)
    if projection.status == self.STATUS.HEALTHY then
        return "✓ Comfortable surplus - Good financial position"
    elseif projection.status == self.STATUS.TIGHT then
        return "⚠ Tight budget - Limited flexibility"
    elseif projection.status == self.STATUS.WARNING then
        return "⚠ Critical warning - Running out of funds"
    elseif projection.status == self.STATUS.DEFICIT then
        return "✗ BANKRUPT - Cannot afford"
    else
        return "? Unknown status"
    end
end

--- Get color code for UI display
---
--- Returns RGB table for UI rendering based on status.
---
---@param status string Status string
---@return table RGB color table {r, g, b}
function BudgetForecast:getStatusColor(status)
    if status == self.STATUS.HEALTHY then
        return {100, 255, 100}  -- Green
    elseif status == self.STATUS.TIGHT then
        return {255, 255, 100}  -- Yellow
    elseif status == self.STATUS.WARNING or status == self.STATUS.DEFICIT then
        return {255, 100, 100}  -- Red
    else
        return {200, 200, 200}  -- Gray
    end
end

--- Compare two projections and show delta
---
--- Useful for showing what-if scenarios alongside base projections.
---
---@param baseProjection table Base case projection
---@param changeProjection table Change case projection
---@return table Comparison with deltas
function BudgetForecast:compareProjections(baseProjection, changeProjection)
    local comparison = {
        baseIncome = baseProjection.income,
        changeIncome = changeProjection.income,
        incomeDelta = changeProjection.income - baseProjection.income,
        
        baseExpenses = baseProjection.expenses,
        changeExpenses = changeProjection.expenses,
        expensesDelta = changeProjection.expenses - baseProjection.expenses,
        
        baseBalance = baseProjection.balance,
        changeBalance = changeProjection.balance,
        balanceDelta = changeProjection.balance - baseProjection.balance,
        
        baseRunning = baseProjection.runningBalance,
        changeRunning = changeProjection.runningBalance,
        runningDelta = changeProjection.runningBalance - baseProjection.runningBalance,
        
        statusChange = baseProjection.status ~= changeProjection.status,
        oldStatus = baseProjection.status,
        newStatus = changeProjection.status
    }
    
    return comparison
end

--- Format projection for display
---
---@param projection table Projection entry
---@return string Formatted text
function BudgetForecast:formatProjection(projection)
    local text = string.format(
        "Month %d: Income %d - Expenses %d = %d (Running: %d) [%s]",
        projection.month,
        projection.income,
        projection.expenses,
        projection.balance,
        projection.runningBalance,
        projection.status
    )
    
    return text
end

return BudgetForecast




