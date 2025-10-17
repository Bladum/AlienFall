--- Treasury System - Central Financial Management
---
--- Manages global funding pool, income/expense tracking, and financial reports.
--- The Treasury maintains a central repository of all funds across all bases
--- and handles the monthly financial cycle including income collection,
--- expense calculation, and financial reporting.
---
--- Key Features:
--- - Central funds pool with balance tracking
--- - Monthly income/expense cycle
--- - Budget allocation system
--- - Financial reporting and forecasting
--- - Debt and loan management
---
--- Usage:
---   local Treasury = require("engine.economy.finance.treasury")
---   local treasury = Treasury:new()
---   treasury:processMonthlyFinances()
---   treasury:addIncome("mission_reward", 50000)
---   treasury:deductExpense("maintenance", 25000)
---
--- @module engine.economy.finance.treasury
--- @author AlienFall Development Team

local Treasury = {}
Treasury.__index = Treasury

--- Initialize Treasury
---@param initialFunds number? Starting funds (default: 1,000,000)
---@return table Treasury instance
function Treasury:new(initialFunds)
    local self = setmetatable({}, Treasury)
    
    self.currentBalance = initialFunds or 1000000
    self.monthlyBalance = 0
    self.totalIncome = 0
    self.totalExpenses = 0
    self.currentMonth = 1
    self.currentYear = 2025
    
    -- Income tracking by category
    self.incomeCategories = {
        mission_reward = 0,
        government_grant = 0,
        research_bonus = 0,
        trade_profit = 0,
        other = 0
    }
    
    -- Expense tracking by category
    self.expenseCategories = {
        personnel_salary = 0,
        facility_maintenance = 0,
        equipment_procurement = 0,
        research_investment = 0,
        debt_interest = 0,
        other = 0
    }
    
    -- Budget allocation (percentages, must sum to 100)
    self.budgetAllocation = {
        personnel_salary = 40,
        facility_maintenance = 25,
        research_investment = 20,
        equipment_procurement = 10,
        contingency = 5
    }
    
    -- Debt management
    self.loans = {}  -- Array of {amount, interestRate, monthsRemaining}
    self.totalDebt = 0
    
    -- Financial history
    self.monthlyHistory = {}
    
    print("[Treasury] Initialized with " .. self:formatCurrency(self.currentBalance))
    
    return self
end

--- Get current balance
---@return number Current balance in credits
function Treasury:getBalance()
    return self.currentBalance
end

--- Add income to treasury
---@param category string Income category
---@param amount number Amount to add
---@return boolean Success
function Treasury:addIncome(category, amount)
    if amount <= 0 then
        return false
    end
    
    if not self.incomeCategories[category] then
        category = "other"
    end
    
    self.incomeCategories[category] = self.incomeCategories[category] + amount
    self.currentBalance = self.currentBalance + amount
    self.totalIncome = self.totalIncome + amount
    
    print(string.format("[Treasury] Income: %s (%s)", 
        self:formatCurrency(amount), category))
    
    return true
end

--- Deduct expense from treasury
---@param category string Expense category
---@param amount number Amount to deduct
---@return boolean Success
function Treasury:deductExpense(category, amount)
    if amount <= 0 then
        return false
    end
    
    if not self.expenseCategories[category] then
        category = "other"
    end
    
    if self.currentBalance < amount then
        print(string.format("[Treasury] WARNING: Insufficient funds for %s (%s)",
            category, self:formatCurrency(amount)))
        return false
    end
    
    self.expenseCategories[category] = self.expenseCategories[category] + amount
    self.currentBalance = self.currentBalance - amount
    self.totalExpenses = self.totalExpenses + amount
    
    print(string.format("[Treasury] Expense: %s (%s)",
        self:formatCurrency(amount), category))
    
    return true
end

--- Set budget allocation percentages
---@param allocation table Budget allocation {category = percentage, ...}
---@return boolean Success
function Treasury:setBudgetAllocation(allocation)
    local total = 0
    for _, percentage in pairs(allocation) do
        total = total + percentage
    end
    
    if total ~= 100 then
        print(string.format("[Treasury] ERROR: Budget allocation must sum to 100%% (got %d%%)", total))
        return false
    end
    
    self.budgetAllocation = allocation
    print("[Treasury] Budget allocation updated")
    
    return true
end

--- Get budget allocation
---@return table Current budget allocation
function Treasury:getBudgetAllocation()
    return self.budgetAllocation
end

--- Calculate recommended monthly allocation
---@param availableFunds number Funds available to allocate
---@return table Allocation {category = amount, ...}
function Treasury:calculateMonthlyAllocation(availableFunds)
    local allocation = {}
    
    for category, percentage in pairs(self.budgetAllocation) do
        allocation[category] = math.floor(availableFunds * (percentage / 100))
    end
    
    return allocation
end

--- Take a loan
---@param amount number Loan amount
---@param interestRate number Annual interest rate (0.05 = 5%)
---@param months number Loan duration in months
---@return boolean Success
function Treasury:takeLoan(amount, interestRate, months)
    if amount <= 0 or interestRate < 0 or months <= 0 then
        return false
    end
    
    table.insert(self.loans, {
        amount = amount,
        interestRate = interestRate,
        monthsRemaining = months,
        monthlyPayment = math.ceil(amount / months)
    })
    
    self.currentBalance = self.currentBalance + amount
    self.totalDebt = self.totalDebt + amount
    
    print(string.format("[Treasury] Loan taken: %s at %.1f%% for %d months",
        self:formatCurrency(amount), interestRate * 100, months))
    
    return true
end

--- Process monthly financial cycle
---@param monthlyIncome number Income for this month
---@param monthlyExpenses number Expenses for this month
---@return table Monthly financial report
function Treasury:processMonthlyFinances(monthlyIncome, monthlyExpenses)
    -- Process loan payments
    local loanPayments = self:processLoans()
    
    -- Calculate balance
    self.monthlyBalance = monthlyIncome - monthlyExpenses - loanPayments
    
    -- Update balance
    self.currentBalance = self.currentBalance + self.monthlyBalance
    
    -- Create report
    local report = {
        month = self.currentMonth,
        year = self.currentYear,
        income = monthlyIncome,
        expenses = monthlyExpenses,
        loanPayments = loanPayments,
        balance = self.monthlyBalance,
        totalBalance = self.currentBalance,
        totalDebt = self.totalDebt
    }
    
    table.insert(self.monthlyHistory, report)
    
    -- Check for bankruptcy
    if self.currentBalance < 0 then
        print("[Treasury] WARNING: Treasury is in debt!")
        return report
    end
    
    print(string.format("[Treasury] Monthly: Income %s, Expenses %s, Balance %s, Total %s",
        self:formatCurrency(monthlyIncome),
        self:formatCurrency(monthlyExpenses),
        self:formatCurrency(self.monthlyBalance),
        self:formatCurrency(self.currentBalance)))
    
    -- Advance month
    self.currentMonth = self.currentMonth + 1
    if self.currentMonth > 12 then
        self.currentMonth = 1
        self.currentYear = self.currentYear + 1
    end
    
    return report
end

--- Process loan payments
---@return number Total loan payments this month
function Treasury:processLoans()
    local totalPayment = 0
    local remainingLoans = {}
    
    for _, loan in ipairs(self.loans) do
        if loan.monthsRemaining > 0 then
            -- Calculate monthly payment with interest
            local monthlyRate = loan.interestRate / 12
            local payment = loan.monthlyPayment + (loan.amount * monthlyRate)
            
            self.currentBalance = self.currentBalance - payment
            self.expenseCategories.debt_interest = self.expenseCategories.debt_interest + payment
            totalPayment = totalPayment + payment
            
            loan.monthsRemaining = loan.monthsRemaining - 1
            
            if loan.monthsRemaining > 0 then
                table.insert(remainingLoans, loan)
            else
                self.totalDebt = self.totalDebt - loan.amount
                print(string.format("[Treasury] Loan paid off"))
            end
        end
    end
    
    self.loans = remainingLoans
    
    return totalPayment
end

--- Get financial report for time period
---@param months number? Number of months back (default: 12)
---@return table Report data
function Treasury:getFinancialReport(months)
    months = months or 12
    
    local report = {
        currentBalance = self.currentBalance,
        totalIncome = self.totalIncome,
        totalExpenses = self.totalExpenses,
        totalDebt = self.totalDebt,
        netBalance = self.totalIncome - self.totalExpenses,
        monthlyHistory = self.monthlyHistory,
        incomeBreakdown = self.incomeCategories,
        expenseBreakdown = self.expenseCategories
    }
    
    return report
end

--- Get financial status string
---@return string Status report
function Treasury:getStatus()
    local status = string.format(
        "Treasury Status:\n" ..
        "  Balance: %s\n" ..
        "  Monthly Income: %s\n" ..
        "  Monthly Expenses: %s\n" ..
        "  Total Debt: %s\n" ..
        "  Active Loans: %d",
        self:formatCurrency(self.currentBalance),
        self:formatCurrency(self.totalIncome),
        self:formatCurrency(self.totalExpenses),
        self:formatCurrency(self.totalDebt),
        #self.loans
    )
    
    return status
end

--- Format number as currency
---@param amount number
---@return string Formatted currency string
function Treasury:formatCurrency(amount)
    return "$" .. tostring(math.floor(amount))
end

--- Serialize for save/load
---@return table Serialized data
function Treasury:serialize()
    return {
        currentBalance = self.currentBalance,
        monthlyBalance = self.monthlyBalance,
        totalIncome = self.totalIncome,
        totalExpenses = self.totalExpenses,
        currentMonth = self.currentMonth,
        currentYear = self.currentYear,
        incomeCategories = self.incomeCategories,
        expenseCategories = self.expenseCategories,
        budgetAllocation = self.budgetAllocation,
        loans = self.loans,
        totalDebt = self.totalDebt,
        monthlyHistory = self.monthlyHistory
    }
end

--- Deserialize from save/load
---@param data table Serialized data
function Treasury:deserialize(data)
    self.currentBalance = data.currentBalance
    self.monthlyBalance = data.monthlyBalance
    self.totalIncome = data.totalIncome
    self.totalExpenses = data.totalExpenses
    self.currentMonth = data.currentMonth
    self.currentYear = data.currentYear
    self.incomeCategories = data.incomeCategories
    self.expenseCategories = data.expenseCategories
    self.budgetAllocation = data.budgetAllocation
    self.loans = data.loans
    self.totalDebt = data.totalDebt
    self.monthlyHistory = data.monthlyHistory
    
    print("[Treasury] Deserialized from save")
end

return Treasury
