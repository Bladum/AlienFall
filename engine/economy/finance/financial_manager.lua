--- Financial Manager - Coordinates all financial operations
---
--- Manages income and expense collection from various game systems,
--- orchestrates monthly financial processing, and provides financial
--- reports and status information to other systems.
---
--- Responsibilities:
--- - Aggregate income from multiple sources (missions, research, trade)
--- - Aggregate expenses from multiple sources (salaries, maintenance, procurement)
--- - Orchestrate monthly financial processing
--- - Provide financial status to UI and other systems
--- - Handle financial events and notifications
---
--- Usage:
---   local FinancialManager = require("engine.economy.finance.financial_manager")
---   local manager = FinancialManager:new()
---   manager:registerIncomeSource("missions", getMissionRewards)
---   manager:registerExpenseSource("facilities", getFacilityMaintenanceCost)
---   local report = manager:processMonthlyFinances()
---
--- @module engine.economy.finance.financial_manager
--- @author AlienFall Development Team

local Treasury = require("engine.economy.finance.treasury")

local FinancialManager = {}
FinancialManager.__index = FinancialManager

--- Initialize Financial Manager
---@param initialFunds number? Starting funds
---@return table FinancialManager instance
function FinancialManager:new(initialFunds)
    local self = setmetatable({}, FinancialManager)
    
    self.treasury = Treasury:new(initialFunds)
    self.incomeSources = {}  -- {name = function}
    self.expenseSources = {}  -- {name = function}
    self.financialEvents = {}  -- Events to notify
    
    -- Monthly tracking
    self.lastProcessedMonth = 0
    self.processingEnabled = true
    
    print("[FinancialManager] Initialized")
    
    return self
end

--- Register income source
---@param name string Source name
---@param sourceFunction function Function that returns (amount, category)
function FinancialManager:registerIncomeSource(name, sourceFunction)
    self.incomeSources[name] = sourceFunction
    print("[FinancialManager] Registered income source: " .. name)
end

--- Register expense source
---@param name string Source name
---@param sourceFunction function Function that returns (amount, category)
function FinancialManager:registerExpenseSource(name, sourceFunction)
    self.expenseSources[name] = sourceFunction
    print("[FinancialManager] Registered expense source: " .. name)
end

--- Calculate total monthly income
---@return table Result with totalIncome and breakdown
function FinancialManager:calculateMonthlyIncome()
    local totalIncome = 0
    local breakdown = {}
    
    for sourceName, sourceFunc in pairs(self.incomeSources) do
        local amount, category = sourceFunc()
        if amount and amount > 0 then
            totalIncome = totalIncome + amount
            breakdown[sourceName] = {amount = amount, category = category}
            
            print(string.format("[FinancialManager] Income from %s: %d (%s)",
                sourceName, amount, category or "other"))
        end
    end
    
    return {totalIncome = totalIncome, breakdown = breakdown}
end

--- Calculate total monthly expenses
---@return table Result with totalExpenses and breakdown
function FinancialManager:calculateMonthlyExpenses()
    local totalExpenses = 0
    local breakdown = {}
    
    for sourceName, sourceFunc in pairs(self.expenseSources) do
        local amount, category = sourceFunc()
        if amount and amount > 0 then
            totalExpenses = totalExpenses + amount
            breakdown[sourceName] = {amount = amount, category = category}
            
            print(string.format("[FinancialManager] Expense from %s: %d (%s)",
                sourceName, amount, category or "other"))
        end
    end
    
    return {totalExpenses = totalExpenses, breakdown = breakdown}
end

--- Process monthly financial cycle
---@return table Financial report
function FinancialManager:processMonthlyFinances()
    if not self.processingEnabled then
        return {status = "disabled"}
    end
    
    -- Calculate income and expenses
    local incomeResult = self:calculateMonthlyIncome()
    local monthlyIncome = incomeResult.totalIncome
    local incomeBreakdown = incomeResult.breakdown
    
    local expenseResult = self:calculateMonthlyExpenses()
    local monthlyExpenses = expenseResult.totalExpenses
    local expenseBreakdown = expenseResult.breakdown
    
    print("[FinancialManager] Processing monthly finances...")
    print("  Total Income: " .. monthlyIncome)
    print("  Total Expenses: " .. monthlyExpenses)
    
    -- Process through treasury
    local report = self.treasury:processMonthlyFinances(monthlyIncome, monthlyExpenses)
    
    -- Apply income and expenses to treasury
    for sourceName, info in pairs(incomeBreakdown) do
        self.treasury:addIncome(info.category or "other", info.amount)
    end
    
    for sourceName, info in pairs(expenseBreakdown) do
        self.treasury:deductExpense(info.category or "other", info.amount)
    end
    
    -- Trigger financial events
    self:triggerFinancialEvents(report)
    
    self.lastProcessedMonth = report.month
    
    print("[FinancialManager] Financial cycle complete")
    
    return report
end

--- Trigger financial events based on report
---@param report table Financial report
function FinancialManager:triggerFinancialEvents(report)
    -- Check for surplus
    if report.balance > 0 then
        self:notifyEvent("surplus", report.balance)
    end
    
    -- Check for deficit
    if report.balance < 0 then
        self:notifyEvent("deficit", math.abs(report.balance))
    end
    
    -- Check for bankruptcy risk
    if report.totalBalance < 100000 then
        self:notifyEvent("low_funds_warning", report.totalBalance)
    end
    
    -- Check for bankruptcy
    if report.totalBalance < 0 then
        self:notifyEvent("bankruptcy", math.abs(report.totalBalance))
    end
end

--- Register for financial events
---@param eventName string Event name
---@param callback function Callback function
function FinancialManager:onFinancialEvent(eventName, callback)
    if not self.financialEvents[eventName] then
        self.financialEvents[eventName] = {}
    end
    table.insert(self.financialEvents[eventName], callback)
end

--- Trigger financial event
---@param eventName string Event name
---@param data any Event data
function FinancialManager:notifyEvent(eventName, data)
    if self.financialEvents[eventName] then
        for _, callback in ipairs(self.financialEvents[eventName]) do
            callback(data)
        end
    end
end

--- Add manual income (mission rewards, trades, etc)
---@param category string Income category
---@param amount number Amount
function FinancialManager:addIncome(category, amount)
    return self.treasury:addIncome(category, amount)
end

--- Add manual expense (procurement, emergency, etc)
---@param category string Expense category
---@param amount number Amount
function FinancialManager:addExpense(category, amount)
    return self.treasury:deductExpense(category, amount)
end

--- Get current balance
---@return number Balance
function FinancialManager:getBalance()
    return self.treasury:getBalance()
end

--- Get financial report
---@param months number? Months to report
---@return table Report
function FinancialManager:getReport(months)
    return self.treasury:getFinancialReport(months)
end

--- Get treasury status
---@return string Status
function FinancialManager:getStatus()
    return self.treasury:getStatus()
end

--- Take a loan
---@param amount number Loan amount
---@param interestRate number Interest rate
---@param months number Duration
---@return boolean Success
function FinancialManager:takeLoan(amount, interestRate, months)
    return self.treasury:takeLoan(amount, interestRate, months)
end

--- Set budget allocation
---@param allocation table Budget allocation
---@return boolean Success
function FinancialManager:setBudgetAllocation(allocation)
    return self.treasury:setBudgetAllocation(allocation)
end

--- Get budget allocation
---@return table Allocation
function FinancialManager:getBudgetAllocation()
    return self.treasury:getBudgetAllocation()
end

--- Enable/disable processing
---@param enabled boolean
function FinancialManager:setProcessingEnabled(enabled)
    self.processingEnabled = enabled
    print("[FinancialManager] Processing " .. (enabled and "enabled" or "disabled"))
end

--- Serialize for save/load
---@return table Serialized data
function FinancialManager:serialize()
    return {
        treasury = self.treasury:serialize(),
        lastProcessedMonth = self.lastProcessedMonth,
        processingEnabled = self.processingEnabled
    }
end

--- Deserialize from save/load
---@param data table Serialized data
function FinancialManager:deserialize(data)
    self.treasury:deserialize(data.treasury)
    self.lastProcessedMonth = data.lastProcessedMonth
    self.processingEnabled = data.processingEnabled
    print("[FinancialManager] Deserialized from save")
end

return FinancialManager
