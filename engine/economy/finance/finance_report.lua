--- Finance Report System - Enhanced financial reporting and history
---
--- Generates detailed monthly financial reports with income/expense breakdowns,
--- status indicators, and year-to-date tracking for financial management UI.
---
--- Key Features:
--- - Monthly report generation with detailed breakdowns
--- - Relations multiplier tracking and display
--- - Historical data tracking (12-month rolling history)
--- - Year-to-date balance calculation
--- - Status color-coding (green/yellow/red)
---
--- Usage:
---   local FinanceReport = require("engine.economy.finance.finance_report")
---   local report = FinanceReport:new()
---   local monthlyReport = report:generateMonthlyReport(base, game_state)
---   local summary = report:displayReport(monthlyReport)
---
--- @module engine.economy.finance.finance_report
--- @author AlienFall Development Team

local FinanceReport = {}
FinanceReport.__index = FinanceReport

--- Month names for display
FinanceReport.MONTH_NAMES = {
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
}

--- Initialize Finance Report System
---@return table FinanceReport instance
function FinanceReport:new()
    local self = setmetatable({}, FinanceReport)
    print("[FinanceReport] Initialized")
    return self
end

--- Generate monthly financial report
---
--- Creates a detailed report of income, expenses, balance, and status
--- for a given base for the current game month.
---
---@param base table Base object containing financial data
---@param gameState table Game state with current_month, current_year
---@return table Monthly report with complete financial breakdown
function FinanceReport:generateMonthlyReport(base, gameState)
    gameState = gameState or {current_month = 1, current_year = 2025}
    
    local report = {
        -- Report metadata
        month = gameState.current_month,
        year = gameState.current_year,
        monthName = self.MONTH_NAMES[gameState.current_month] or "Unknown",
        
        -- Income breakdown
        income = {
            country_funding = 0,
            mission_rewards = 0,
            alien_salvage = 0,
            trade_profit = 0,
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
            procurement = 0,
            other = 0,
            total = 0
        },
        
        -- Summary
        net_balance = 0,
        running_balance = 0,
        year_to_date = 0,
        previous_month_balance = 0,
        status = "healthy",
        status_description = "Funds adequate"
    }
    
    -- Calculate income sources
    report.income.country_funding = base.country_funding or 15000
    report.income.mission_rewards = base.mission_income or 0
    report.income.alien_salvage = base.salvage_income or 0
    report.income.trade_profit = base.trade_income or 0
    report.income.other = base.other_income or 0
    
    -- Apply relations multiplier (typically 0.8 to 1.2)
    report.income.relations_multiplier = base.relations_multiplier or 1.0
    
    -- Calculate total income with multiplier
    local base_income = report.income.country_funding + report.income.mission_rewards +
                       report.income.alien_salvage + report.income.trade_profit +
                       report.income.other
    
    report.income.total = math.floor(base_income * report.income.relations_multiplier)
    
    -- Calculate expense sources
    -- Facility maintenance
    if base.facilities then
        for _, facility in ipairs(base.facilities) do
            report.expenses.facility_maintenance = report.expenses.facility_maintenance + 
                                                  (facility.maintenance_cost or 500)
        end
    end
    
    -- Personnel costs
    report.expenses.personnel = base.personnel_costs or 2000
    
    -- Supplies (ammunition, medical, food)
    report.expenses.supplies = base.supplies_cost or 1200
    
    -- Research acceleration (if enabled)
    if base.research_boost_funded then
        report.expenses.research_acceleration = 800
    end
    
    -- Construction in progress
    if base.construction_costs then
        report.expenses.construction = base.construction_costs
    end
    
    -- Equipment procurement
    report.expenses.procurement = base.procurement_costs or 500
    
    -- Other expenses
    report.expenses.other = base.other_expenses or 0
    
    -- Calculate total expenses
    report.expenses.total = report.expenses.facility_maintenance +
                           report.expenses.personnel +
                           report.expenses.supplies +
                           report.expenses.research_acceleration +
                           report.expenses.construction +
                           report.expenses.procurement +
                           report.expenses.other
    
    -- Calculate balances
    report.net_balance = report.income.total - report.expenses.total
    report.previous_month_balance = base.credits or 100000
    report.running_balance = report.previous_month_balance + report.net_balance
    
    -- Get year-to-date balance from history
    if base.financial_history then
        report.year_to_date = base.year_to_date_balance or 0
    else
        report.year_to_date = report.net_balance
    end
    
    -- Determine status
    if report.running_balance < 0 then
        report.status = "deficit"
        report.status_description = "✗ BANKRUPT - Immediate action required"
    elseif report.running_balance < 2000 then
        report.status = "critical"
        report.status_description = "✗ CRITICAL - Running out of funds"
    elseif report.running_balance < 5000 then
        report.status = "tight"
        report.status_description = "⚠ TIGHT - Budget constrained"
    elseif report.net_balance >= 5000 then
        report.status = "surplus"
        report.status_description = "✓ HEALTHY - Good surplus"
    else
        report.status = "healthy"
        report.status_description = "✓ HEALTHY - Adequate funds"
    end
    
    print(string.format("[FinanceReport] Report %s %d: Income %d, Expenses %d, Balance %d (Status: %s)",
        report.monthName, report.year, report.income.total, report.expenses.total,
        report.net_balance, report.status))
    
    return report
end

--- Track financial history
---
--- Stores monthly reports for historical analysis and year-to-date calculations.
--- Maintains rolling 12-month history.
---
---@param base table Base object
---@param report table Monthly report
function FinanceReport:trackHistory(base, report)
    if not base.financial_history then
        base.financial_history = {}
    end
    
    -- Store this month's report
    table.insert(base.financial_history, {
        month = report.month,
        year = report.year,
        income = report.income.total,
        expenses = report.expenses.total,
        balance = report.net_balance,
        running_balance = report.running_balance,
        status = report.status
    })
    
    -- Trim history to last 12 months
    if #base.financial_history > 12 then
        table.remove(base.financial_history, 1)
    end
    
    -- Calculate year-to-date balance
    base.year_to_date_balance = 0
    for _, entry in ipairs(base.financial_history) do
        base.year_to_date_balance = base.year_to_date_balance + entry.balance
    end
    
    print(string.format("[FinanceReport] Tracked history entry, YTD balance: %d",
        base.year_to_date_balance or 0))
end

--- Get report display text for UI
---
--- Formats report data for display on screen or in UI elements.
---
---@param report table Monthly report
---@return string Display text
function FinanceReport:getDisplayText(report)
    local text = string.format(
        "FINANCIAL REPORT - %s %d\n\n" ..
        "INCOME:\n" ..
        "  Country Funding: %d\n" ..
        "  Mission Rewards: %d\n" ..
        "  Alien Salvage: %d\n" ..
        "  Trade Profit: %d\n" ..
        "  Relations Multiplier: %.2f×\n" ..
        "  TOTAL INCOME: %d\n\n" ..
        "EXPENSES:\n" ..
        "  Facility Maintenance: %d\n" ..
        "  Personnel: %d\n" ..
        "  Supplies: %d\n" ..
        "  Research Acceleration: %d\n" ..
        "  Construction: %d\n" ..
        "  Procurement: %d\n" ..
        "  TOTAL EXPENSES: %d\n\n" ..
        "SUMMARY:\n" ..
        "  Previous Balance: %d\n" ..
        "  Monthly Balance: %d\n" ..
        "  Current Balance: %d\n" ..
        "  Year-to-Date: %d\n" ..
        "  Status: %s",
        
        report.monthName, report.year,
        report.income.country_funding,
        report.income.mission_rewards,
        report.income.alien_salvage,
        report.income.trade_profit,
        report.income.relations_multiplier,
        report.income.total,
        
        report.expenses.facility_maintenance,
        report.expenses.personnel,
        report.expenses.supplies,
        report.expenses.research_acceleration,
        report.expenses.construction,
        report.expenses.procurement,
        report.expenses.total,
        
        report.previous_month_balance,
        report.net_balance,
        report.running_balance,
        report.year_to_date,
        report.status_description
    )
    
    return text
end

--- Get status color for UI rendering
---
---@param status string Status string (deficit/critical/tight/healthy/surplus)
---@return table RGB color table {r, g, b}
function FinanceReport:getStatusColor(status)
    if status == "deficit" then
        return {255, 50, 50}   -- Bright red
    elseif status == "critical" then
        return {255, 100, 50}  -- Orange-red
    elseif status == "tight" then
        return {255, 255, 100} -- Yellow
    elseif status == "surplus" then
        return {100, 255, 100} -- Green
    elseif status == "healthy" then
        return {150, 200, 100} -- Light green
    else
        return {200, 200, 200} -- Gray
    end
end

--- Get detailed expense breakdown for chart/display
---
---@param report table Monthly report
---@return table Breakdown with category and amount
function FinanceReport:getExpenseBreakdown(report)
    local breakdown = {}
    
    local expenses = {
        {"Facility Maintenance", report.expenses.facility_maintenance},
        {"Personnel", report.expenses.personnel},
        {"Supplies", report.expenses.supplies},
        {"Research", report.expenses.research_acceleration},
        {"Construction", report.expenses.construction},
        {"Procurement", report.expenses.procurement},
        {"Other", report.expenses.other}
    }
    
    for _, item in ipairs(expenses) do
        if item[2] > 0 then
            local percentage = (item[2] / report.expenses.total) * 100
            table.insert(breakdown, {
                category = item[1],
                amount = item[2],
                percentage = percentage
            })
        end
    end
    
    -- Sort by amount descending
    table.sort(breakdown, function(a, b) return a.amount > b.amount end)
    
    return breakdown
end

--- Get detailed income breakdown for chart/display
---
---@param report table Monthly report
---@return table Breakdown with source and amount
function FinanceReport:getIncomeBreakdown(report)
    local breakdown = {}
    
    local incomes = {
        {"Country Funding", report.income.country_funding},
        {"Mission Rewards", report.income.mission_rewards},
        {"Alien Salvage", report.income.alien_salvage},
        {"Trade Profit", report.income.trade_profit},
        {"Other", report.income.other}
    }
    
    for _, item in ipairs(incomes) do
        if item[2] > 0 then
            local base_total = report.income.country_funding + report.income.mission_rewards +
                             report.income.alien_salvage + report.income.trade_profit +
                             report.income.other
            local percentage = (item[2] / base_total) * 100
            table.insert(breakdown, {
                source = item[1],
                amount = item[2],
                percentage = percentage
            })
        end
    end
    
    -- Sort by amount descending
    table.sort(breakdown, function(a, b) return a.amount > b.amount end)
    
    return breakdown
end

--- Get historical trend (last 6 months)
---
---@param base table Base object with history
---@return table Array of last 6 months with balance trend
function FinanceReport:getHistoricalTrend(base)
    if not base.financial_history then
        return {}
    end
    
    local trend = {}
    local start = math.max(1, #base.financial_history - 5)
    
    for i = start, #base.financial_history do
        local entry = base.financial_history[i]
        table.insert(trend, {
            month = entry.month,
            year = entry.year,
            balance = entry.balance,
            running_balance = entry.running_balance,
            status = entry.status
        })
    end
    
    return trend
end

return FinanceReport



