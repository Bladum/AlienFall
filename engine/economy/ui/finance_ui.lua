--- Finance UI System
-- Comprehensive financial display and reporting screens
-- Shows income/expense breakdown, budget forecasting, historical trends
-- Integrates with: finance_report.lua, budget_forecast.lua, personnel_system.lua, supplier_pricing_system.lua
--
-- @module finance_ui
-- @author AI Development Team
-- @license MIT

local FinanceUI = {}

--- Create new finance UI instance
-- @param base Base entity with financial data
-- @param gameState Global game state
-- @return Finance UI instance
function FinanceUI:new(base, gameState)
    local instance = {
        base = base,
        gameState = gameState,
        currentScreen = "summary", -- summary, reports, forecasting, marketplace
        selectedMonth = 0, -- 0 = current, 1 = last month, etc
        selectedForecastMonths = 6, -- 1-12 months ahead
        scroll = 0, -- For scrollable panels
        hoveredItem = nil,
    }
    setmetatable(instance, { __index = self })
    return instance
end

--- Draw finance summary screen (main overview)
-- Shows current month income/expenses, running balance, status
-- Layout: Top status panel (200px), left income chart (400px), right expense chart (400px), bottom trend (full width)
function FinanceUI:drawSummary()
    local panelWidth = 960
    local panelHeight = 720
    
    -- Title
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(24))
    love.graphics.print("Financial Summary", 20, 20)
    
    -- Status bar (top: 200×960)
    self:drawStatusBar(20, 60, 920, 180)
    
    -- Income breakdown (left: 450×500 @ 20, 260)
    self:drawIncomeChart(20, 260, 450, 420)
    
    -- Expense breakdown (right: 450×500 @ 490, 260)
    self:drawExpenseChart(490, 260, 450, 420)
    
    -- Trend chart (bottom: 920×180 @ 20, 690)
    -- Placeholder: trend over last 12 months
    love.graphics.setColor(0.2, 0.2, 0.3)
    love.graphics.rectangle("fill", 20, 690, 920, 30)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.print("6-Month Trend: [chart placeholder]", 30, 700)
end

--- Draw status bar showing current financial state
-- Shows: current balance, monthly income, monthly expenses, status indicator
function FinanceUI:drawStatusBar(x, y, width, height)
    love.graphics.setColor(0.15, 0.15, 0.2)
    love.graphics.rectangle("fill", x, y, width, height)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, width, height)
    
    local base = self.base
    local currentBalance = base.treasury or 50000
    local monthlyIncome = base.monthlyIncome or 5000
    local monthlyExpense = base.monthlyExpense or 3000
    local status = "HEALTHY"
    local statusColor = {0, 1, 0} -- Green
    
    if currentBalance < 0 then
        status = "BANKRUPT"
        statusColor = {1, 0, 0}
    elseif currentBalance < 2000 then
        status = "CRITICAL"
        statusColor = {1, 0.5, 0}
    elseif currentBalance < 5000 then
        status = "TIGHT"
        statusColor = {1, 1, 0}
    end
    
    love.graphics.setFont(love.graphics.newFont(14))
    love.graphics.setColor(1, 1, 1)
    
    -- Row 1: Balances
    love.graphics.print("Current Balance: $" .. string.format("%,d", currentBalance), x + 20, y + 15)
    love.graphics.print("Monthly Income: $" .. string.format("%,d", monthlyIncome), x + 400, y + 15)
    
    -- Row 2: Expenses and Status
    love.graphics.print("Monthly Expenses: $" .. string.format("%,d", monthlyExpense), x + 20, y + 50)
    love.graphics.setColor(statusColor[1], statusColor[2], statusColor[3])
    love.graphics.print("Status: " .. status, x + 400, y + 50)
    
    -- Row 3: Running balance indicator
    love.graphics.setColor(1, 1, 1)
    local projectedBalance = currentBalance + (monthlyIncome - monthlyExpense)
    local indicator = "↑ Gaining"
    if projectedBalance < currentBalance then indicator = "↓ Losing" end
    love.graphics.print("Next Month Projection: $" .. string.format("%,d", projectedBalance) .. " " .. indicator, x + 20, y + 85)
    
    -- Visual bar indicator
    love.graphics.setColor(0.3, 0.3, 0.4)
    love.graphics.rectangle("fill", x + 400, y + 75, 200, 30)
    
    local barFill = math.min(currentBalance / 50000, 1) -- Assume 50k is "full"
    if status == "HEALTHY" then
        love.graphics.setColor(0, 1, 0, 0.7)
    elseif status == "TIGHT" then
        love.graphics.setColor(1, 1, 0, 0.7)
    elseif status == "CRITICAL" then
        love.graphics.setColor(1, 0.5, 0, 0.7)
    else
        love.graphics.setColor(1, 0, 0, 0.7)
    end
    love.graphics.rectangle("fill", x + 400, y + 75, 200 * barFill, 30)
end

--- Draw income breakdown pie chart
-- Shows: country funding, mission rewards, alien salvage, trade profit, other
function FinanceUI:drawIncomeChart(x, y, width, height)
    love.graphics.setColor(0.15, 0.15, 0.2)
    love.graphics.rectangle("fill", x, y, width, height)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, width, height)
    
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.print("Monthly Income Breakdown", x + 10, y + 10)
    
    -- Mock data
    local incomeData = {
        {name = "Country Funding", amount = 3000, color = {0, 1, 0}},
        {name = "Mission Rewards", amount = 1500, color = {0, 1, 1}},
        {name = "Alien Salvage", amount = 800, color = {1, 0.5, 0}},
        {name = "Trade Profit", amount = 500, color = {1, 0, 1}},
        {name = "Other", amount = 200, color = {0.7, 0.7, 0.7}},
    }
    
    -- Draw legend
    local legendY = y + 40
    for i, income in ipairs(incomeData) do
        love.graphics.setColor(income.color[1], income.color[2], income.color[3])
        love.graphics.rectangle("fill", x + 10, legendY, 12, 12)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(income.name .. ": $" .. string.format("%,d", income.amount), x + 30, legendY - 2)
        
        legendY = legendY + 25
    end
    
    -- Total at bottom
    local total = 3000 + 1500 + 800 + 500 + 200
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(14))
    love.graphics.print("Total Monthly Income: $" .. string.format("%,d", total), x + 10, y + height - 30)
end

--- Draw expense breakdown pie chart
-- Shows: facility maintenance, personnel, supplies, research, construction, procurement
function FinanceUI:drawExpenseChart(x, y, width, height)
    love.graphics.setColor(0.15, 0.15, 0.2)
    love.graphics.rectangle("fill", x, y, width, height)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, width, height)
    
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.print("Monthly Expense Breakdown", x + 10, y + 10)
    
    -- Mock data
    local expenseData = {
        {name = "Facility Maintenance", amount = 1200, color = {1, 0.5, 0}},
        {name = "Personnel", amount = 1000, color = {1, 0, 0}},
        {name = "Supplies", amount = 600, color = {0.5, 0.5, 1}},
        {name = "Research", amount = 400, color = {0, 1, 0}},
        {name = "Construction", amount = 300, color = {1, 1, 0}},
        {name = "Procurement", amount = 200, color = {1, 0, 1}},
    }
    
    -- Draw legend
    local legendY = y + 40
    for i, expense in ipairs(expenseData) do
        love.graphics.setColor(expense.color[1], expense.color[2], expense.color[3])
        love.graphics.rectangle("fill", x + 10, legendY, 12, 12)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(expense.name .. ": $" .. string.format("%,d", expense.amount), x + 30, legendY - 2)
        
        legendY = legendY + 25
    end
    
    -- Total at bottom
    local total = 1200 + 1000 + 600 + 400 + 300 + 200
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(14))
    love.graphics.print("Total Monthly Expenses: $" .. string.format("%,d", total), x + 10, y + height - 30)
end

--- Draw detailed financial reports screen
-- Shows: month-by-month breakdown, detailed transaction history, quarterly summaries
function FinanceUI:drawReportsScreen()
    local panelWidth = 960
    local panelHeight = 720
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(24))
    love.graphics.print("Financial Reports", 20, 20)
    
    -- Month selector buttons (top)
    self:drawMonthSelector(20, 70, 920, 40)
    
    -- Detailed report for selected month (middle)
    self:drawDetailedMonthReport(20, 120, 920, 550)
    
    -- Navigation footer
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.print("← Previous Month   Next Month →   [Q]uit", 20, 690)
end

--- Draw month selector (horizontal month tabs)
function FinanceUI:drawMonthSelector(x, y, width, height)
    local months = {"Current", "Last Month", "-2", "-3", "-4", "-5", "-6"}
    local monthWidth = width / #months
    
    for i, month in ipairs(months) do
        local mx = x + (i - 1) * monthWidth
        
        if self.selectedMonth == i - 1 then
            love.graphics.setColor(0, 1, 0, 0.3)
        else
            love.graphics.setColor(0.2, 0.2, 0.3)
        end
        love.graphics.rectangle("fill", mx, y, monthWidth - 2, height)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.setLineWidth(1)
        love.graphics.rectangle("line", mx, y, monthWidth - 2, height)
        
        love.graphics.setFont(love.graphics.newFont(11))
        love.graphics.printf(month, mx + 5, y + 10, monthWidth - 10, "center")
    end
end

--- Draw detailed report for selected month
function FinanceUI:drawDetailedMonthReport(x, y, width, height)
    love.graphics.setColor(0.15, 0.15, 0.2)
    love.graphics.rectangle("fill", x, y, width, height)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, width, height)
    
    love.graphics.setFont(love.graphics.newFont(12))
    
    local reportY = y + 20
    
    -- Month header
    love.graphics.setFont(love.graphics.newFont(14))
    love.graphics.print("October 2025 - Detailed Report", x + 20, reportY)
    reportY = reportY + 30
    
    -- Summary
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.setColor(0, 1, 0)
    love.graphics.print("Opening Balance: $50,000", x + 20, reportY)
    reportY = reportY + 20
    
    love.graphics.setColor(0, 1, 1)
    love.graphics.print("Total Income: $6,000", x + 20, reportY)
    reportY = reportY + 20
    
    love.graphics.setColor(1, 0.5, 0)
    love.graphics.print("Total Expenses: $3,700", x + 20, reportY)
    reportY = reportY + 20
    
    love.graphics.setColor(0, 1, 0)
    love.graphics.print("Net Change: +$2,300", x + 20, reportY)
    reportY = reportY + 20
    
    love.graphics.setColor(0, 1, 0)
    love.graphics.print("Closing Balance: $52,300", x + 20, reportY)
    reportY = reportY + 30
    
    -- Detailed transactions (scrollable area)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", x + 20, reportY, width - 40, 200)
    
    love.graphics.setFont(love.graphics.newFont(11))
    reportY = reportY + 10
    
    -- Mock transactions
    local transactions = {
        {"01-Oct", "Country Funding", "+$3,000", 0, 1, 0},
        {"05-Oct", "Personnel Salaries", "-$1,200", 1, 0, 0},
        {"08-Oct", "Mission: Alien Contact", "+$1,500", 0, 1, 0},
        {"10-Oct", "Facility Maintenance", "-$800", 1, 0.5, 0},
        {"12-Oct", "Alien Salvage Sale", "+$800", 0, 1, 0},
        {"15-Oct", "Research Supplies", "-$400", 0.5, 0.5, 1},
        {"18-Oct", "Repair Equipment", "-$300", 1, 1, 0},
        {"20-Oct", "Trade Agreement", "+$700", 1, 0, 1},
    }
    
    for i, trans in ipairs(transactions) do
        love.graphics.setColor(trans[4], trans[5], trans[6])
        love.graphics.print(trans[1] .. " | " .. trans[2] .. " | " .. trans[3], x + 30, reportY)
        reportY = reportY + 18
    end
end

--- Draw budget forecasting screen
-- Shows: 1-12 month projections, status indicators, what-if scenarios
function FinanceUI:drawForecastingScreen()
    local panelWidth = 960
    local panelHeight = 720
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(24))
    love.graphics.print("Budget Forecast", 20, 20)
    
    -- Forecast period selector
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.print("Forecast Period: ", 20, 70)
    for i = 1, 12 do
        if self.selectedForecastMonths == i then
            love.graphics.setColor(0, 1, 0)
        else
            love.graphics.setColor(0.7, 0.7, 0.7)
        end
        love.graphics.print(i .. "m", 150 + (i - 1) * 50, 70)
    end
    
    -- Forecast chart
    self:drawForecastChart(20, 110, 920, 450)
    
    -- What-if scenarios (bottom)
    self:drawWhatIfScenarios(20, 580, 920, 120)
end

--- Draw forecast line chart
-- Shows balance projection over selected period with status colors
function FinanceUI:drawForecastChart(x, y, width, height)
    love.graphics.setColor(0.15, 0.15, 0.2)
    love.graphics.rectangle("fill", x, y, width, height)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, width, height)
    
    -- Chart grid
    love.graphics.setColor(0.3, 0.3, 0.4)
    for i = 0, self.selectedForecastMonths do
        local px = x + 40 + (i / self.selectedForecastMonths) * (width - 80)
        love.graphics.line(px, y + 20, px, y + height - 40)
    end
    
    -- Y-axis scale (balance amounts)
    for i = 0, 5 do
        local balance = 50000 - (i * 10000)
        local py = y + 20 + (i / 5) * (height - 60)
        love.graphics.print("$" .. string.format("%,d", balance), x + 5, py - 10)
    end
    
    -- Draw projection line (mock data)
    love.graphics.setColor(0, 1, 0)
    love.graphics.setLineWidth(2)
    local prevX, prevY = x + 40, y + 20 + (height - 60) * 0.3 -- Starting point
    
    for month = 1, self.selectedForecastMonths do
        local balance = 52000 + (month * 500) -- Increasing balance
        local py = y + 20 + ((50000 - balance) / 50000) * (height - 60)
        local px = x + 40 + (month / self.selectedForecastMonths) * (width - 80)
        
        -- Color code by status
        if balance < 2000 then
            love.graphics.setColor(1, 0, 0) -- Red: critical
        elseif balance < 5000 then
            love.graphics.setColor(1, 1, 0) -- Yellow: tight
        else
            love.graphics.setColor(0, 1, 0) -- Green: healthy
        end
        
        love.graphics.line(prevX, prevY, px, py)
        prevX, prevY = px, py
    end
    
    -- Legend
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(10))
    love.graphics.print("Green: Healthy | Yellow: Tight | Red: Critical", x + 50, y + height - 25)
end

--- Draw what-if scenario buttons
function FinanceUI:drawWhatIfScenarios(x, y, width, height)
    love.graphics.setColor(0.15, 0.15, 0.2)
    love.graphics.rectangle("fill", x, y, width, height)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", x, y, width, height)
    
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.print("What-If Scenarios (Click to apply):", x + 10, y + 10)
    
    local scenarios = {
        {name = "Build Facility", cost = -5000},
        {name = "Hire Soldiers", cost = -1000},
        {name = "Research Boost", cost = -2000},
        {name = "Emergency Supply", cost = -3000},
    }
    
    local scenarioX = x + 20
    for i, scenario in ipairs(scenarios) do
        local scenarioY = y + 35
        
        love.graphics.setColor(0.2, 0.2, 0.3)
        love.graphics.rectangle("fill", scenarioX, scenarioY, 180, 40)
        love.graphics.setColor(1, 0.5, 0)
        love.graphics.rectangle("line", scenarioX, scenarioY, 180, 40)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(11))
        love.graphics.printf(scenario.name, scenarioX + 5, scenarioY + 5, 170, "center")
        love.graphics.setFont(love.graphics.newFont(10))
        love.graphics.setColor(1, 0, 0)
        love.graphics.printf("Cost: $" .. string.format("%,d", scenario.cost), scenarioX + 5, scenarioY + 20, 170, "center")
        
        scenarioX = scenarioX + 200
    end
end

--- Draw marketplace screen
-- Shows: supplier pricing, relations multipliers, available items, purchase history
function FinanceUI:drawMarketplaceScreen()
    local panelWidth = 960
    local panelHeight = 720
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(24))
    love.graphics.print("Marketplace", 20, 20)
    
    -- Supplier list (left: 300px)
    self:drawSupplierList(20, 70, 280, 620)
    
    -- Items grid (right: 640px)
    self:drawItemsGrid(310, 70, 630, 620)
end

--- Draw supplier list with relations
function FinanceUI:drawSupplierList(x, y, width, height)
    love.graphics.setColor(0.15, 0.15, 0.2)
    love.graphics.rectangle("fill", x, y, width, height)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, width, height)
    
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.print("Suppliers", x + 10, y + 10)
    
    local suppliers = {
        {name = "Military Surplus", relations = 60, prices = 0.9},
        {name = "Black Market", relations = -40, prices = 2.0},
        {name = "Government", relations = 80, prices = 0.8},
        {name = "Corporate", relations = 20, prices = 1.2},
        {name = "Underground", relations = -70, prices = 2.5},
    }
    
    local supplyY = y + 40
    for i, supplier in ipairs(suppliers) do
        -- Background
        if self.hoveredItem == "supplier_" .. i then
            love.graphics.setColor(0.3, 0.3, 0.4)
        else
            love.graphics.setColor(0.2, 0.2, 0.3)
        end
        love.graphics.rectangle("fill", x + 5, supplyY, width - 10, 35)
        
        -- Relations color
        local relColor = {0.5, 0.5, 0.5}
        if supplier.relations > 50 then
            relColor = {0, 1, 0}
        elseif supplier.relations > 0 then
            relColor = {0, 1, 1}
        elseif supplier.relations < -50 then
            relColor = {1, 0, 0}
        else
            relColor = {1, 1, 0}
        end
        
        love.graphics.setColor(relColor[1], relColor[2], relColor[3])
        love.graphics.setFont(love.graphics.newFont(11))
        love.graphics.print(supplier.name, x + 15, supplyY + 5)
        
        love.graphics.setFont(love.graphics.newFont(9))
        love.graphics.print("Relations: " .. supplier.relations .. "% | Price: " .. string.format("%.1f", supplier.prices) .. "×", x + 15, supplyY + 18)
        
        supplyY = supplyY + 40
    end
end

--- Draw items grid for selected supplier
function FinanceUI:drawItemsGrid(x, y, width, height)
    love.graphics.setColor(0.15, 0.15, 0.2)
    love.graphics.rectangle("fill", x, y, width, height)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, width, height)
    
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.print("Available Items", x + 10, y + 10)
    
    local items = {
        {name = "Laser Rifle", basePrice = 500, available = true},
        {name = "Plasma Pistol", basePrice = 800, available = false},
        {name = "Light Armor", basePrice = 1000, available = true},
        {name = "Medkit", basePrice = 200, available = true},
        {name = "Grenade", basePrice = 150, available = true},
        {name = "Heavy Cannon", basePrice = 2000, available = true},
        {name = "Advanced Armor", basePrice = 1500, available = false},
        {name = "Alien Artifacts", basePrice = 5000, available = false},
    }
    
    local itemX, itemY = x + 20, y + 40
    local itemsPerRow = 3
    local itemWidth = (width - 40) / itemsPerRow
    
    for i, item in ipairs(items) do
        local color = item.available and {0, 1, 0.5} or {0.5, 0.5, 0.5}
        
        love.graphics.setColor(0.2, 0.2, 0.3)
        love.graphics.rectangle("fill", itemX, itemY, itemWidth - 10, 80)
        
        love.graphics.setColor(color[1], color[2], color[3])
        love.graphics.rectangle("line", itemX, itemY, itemWidth - 10, 80)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(10))
        love.graphics.printf(item.name, itemX + 5, itemY + 5, itemWidth - 15, "center")
        
        love.graphics.setFont(love.graphics.newFont(9))
        local displayPrice = math.floor(item.basePrice * 1.1) -- Mock 10% markup
        love.graphics.printf("$" .. displayPrice, itemX + 5, itemY + 30, itemWidth - 15, "center")
        
        local status = item.available and "Available" or "Out of Stock"
        love.graphics.printf(status, itemX + 5, itemY + 50, itemWidth - 15, "center")
        
        itemX = itemX + itemWidth
        if i % itemsPerRow == 0 then
            itemX = x + 20
            itemY = itemY + 90
        end
    end
end

--- Handle input
function FinanceUI:handleInput(key)
    if key == "1" then
        self.currentScreen = "summary"
    elseif key == "2" then
        self.currentScreen = "reports"
    elseif key == "3" then
        self.currentScreen = "forecasting"
    elseif key == "4" then
        self.currentScreen = "marketplace"
    elseif key == "left" then
        self.selectedMonth = math.min(self.selectedMonth + 1, 12)
    elseif key == "right" then
        self.selectedMonth = math.max(self.selectedMonth - 1, 0)
    elseif key == "up" then
        self.selectedForecastMonths = math.min(self.selectedForecastMonths + 1, 12)
    elseif key == "down" then
        self.selectedForecastMonths = math.max(self.selectedForecastMonths - 1, 1)
    end
end

--- Main draw function
function FinanceUI:draw()
    -- Background
    love.graphics.setColor(0.1, 0.1, 0.15)
    love.graphics.rectangle("fill", 0, 0, 960, 720)
    
    -- Screen selector (top bar)
    self:drawScreenSelector(0, 0, 960, 30)
    
    -- Main content
    if self.currentScreen == "summary" then
        self:drawSummary()
    elseif self.currentScreen == "reports" then
        self:drawReportsScreen()
    elseif self.currentScreen == "forecasting" then
        self:drawForecastingScreen()
    elseif self.currentScreen == "marketplace" then
        self:drawMarketplaceScreen()
    end
    
    -- Help footer
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.setFont(love.graphics.newFont(11))
    love.graphics.print("[1]Summary  [2]Reports  [3]Forecast  [4]Market  [ESC]Close", 10, 705)
end

--- Draw screen selector tabs
function FinanceUI:drawScreenSelector(x, y, width, height)
    local tabs = {
        {key = "1", name = "Summary", screen = "summary"},
        {key = "2", name = "Reports", screen = "reports"},
        {key = "3", name = "Forecast", screen = "forecasting"},
        {key = "4", name = "Market", screen = "marketplace"},
    }
    
    local tabWidth = width / #tabs
    
    for i, tab in ipairs(tabs) do
        local tx = x + (i - 1) * tabWidth
        
        if self.currentScreen == tab.screen then
            love.graphics.setColor(0, 1, 0, 0.4)
        else
            love.graphics.setColor(0.2, 0.2, 0.3)
        end
        love.graphics.rectangle("fill", tx, y, tabWidth, height)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.setLineWidth(1)
        love.graphics.rectangle("line", tx, y, tabWidth, height)
        
        love.graphics.setFont(love.graphics.newFont(12))
        love.graphics.printf("[" .. tab.key .. "] " .. tab.name, tx + 5, y + 5, tabWidth - 10, "center")
    end
end

return FinanceUI




