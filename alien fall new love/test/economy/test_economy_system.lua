--- Test suite for Economy System
--
-- Comprehensive tests for economic gameplay mechanics including
-- resource production, expenditure tracking, and financial management.
--
-- @module test.economy.test_economy_system

local test_framework = require "test.framework.test_framework"
local describe = test_framework.describe
local it = test_framework.it
local expect = test_framework.expect
local before = test_framework.before

-- Mock dependencies
local function create_mock_registry()
    return {
        services = {},
        get = function(self, name)
            return self.services[name]
        end,
        register = function(self, name, service)
            self.services[name] = service
        end
    }
end

describe("Economy System", function()
    local EconomyService
    local economy
    local registry
    
    before(function()
        -- Load economy service (will create when implemented)
        local success, module = pcall(require, "src.economy.EconomyService")
        if success then
            EconomyService = module
            registry = create_mock_registry()
            economy = EconomyService:new(registry)
        end
    end)
    
    describe("Resource Production", function()
        it("should calculate monthly income from bases", function()
            if not economy then return end
            
            local bases = {
                {
                    id = "base1",
                    facilities = {
                        {type = "workshop", status = "operational"},
                        {type = "laboratory", status = "operational"}
                    }
                },
                {
                    id = "base2",
                    facilities = {
                        {type = "workshop", status = "operational"}
                    }
                }
            }
            
            local income = economy:calculateBaseIncome(bases)
            expect(income).to.be.greater_than(0)
        end)
        
        it("should apply funding modifiers correctly", function()
            if not economy then return end
            
            local baseIncome = 1000000
            local performanceRating = 0.85  -- 85% performance
            
            local modifiedIncome = economy:applyFundingModifier(baseIncome, performanceRating)
            
            -- Performance affects funding
            expect(modifiedIncome).to.be.less_than(baseIncome * 1.1)
            expect(modifiedIncome).to.be.greater_than(baseIncome * 0.7)
        end)
    end)
    
    describe("Expenditure Tracking", function()
        it("should track personnel salaries", function()
            if not economy then return end
            
            local personnel = {
                soldiers = {count = 20, salary = 40000},
                scientists = {count = 10, salary = 50000},
                engineers = {count = 15, salary = 45000}
            }
            
            local monthlyCost = economy:calculatePersonnelCost(personnel)
            
            local expectedCost = (20 * 40000) + (10 * 50000) + (15 * 45000)
            expect(monthlyCost).to.equal(expectedCost)
        end)
        
        it("should track facility maintenance costs", function()
            if not economy then return end
            
            local facilities = {
                {type = "hangar", maintenance = 20000, status = "operational"},
                {type = "laboratory", maintenance = 15000, status = "operational"},
                {type = "workshop", maintenance = 10000, status = "damaged"}
            }
            
            local maintenanceCost = economy:calculateMaintenanceCost(facilities)
            
            -- Damaged facilities might have different costs
            expect(maintenanceCost).to.be.greater_than(0)
        end)
        
        it("should track craft operation costs", function()
            if not economy then return end
            
            local crafts = {
                {type = "interceptor", fuel_cost = 5000, missions_flown = 3},
                {type = "transport", fuel_cost = 8000, missions_flown = 2}
            }
            
            local operatingCost = economy:calculateCraftOperatingCost(crafts)
            
            expect(operatingCost).to.be.greater_than(0)
        end)
    end)
    
    describe("Financial Balance", function()
        it("should calculate monthly surplus/deficit", function()
            if not economy then return end
            
            local income = 2000000
            local expenses = 1500000
            
            local balance = economy:calculateBalance(income, expenses)
            
            expect(balance).to.equal(500000)
        end)
        
        it("should handle budget deficit scenarios", function()
            if not economy then return end
            
            local income = 1000000
            local expenses = 1500000
            
            local balance = economy:calculateBalance(income, expenses)
            
            expect(balance).to.be.negative()
            expect(balance).to.equal(-500000)
        end)
        
        it("should prevent spending beyond available funds", function()
            if not economy then return end
            
            economy:setCurrentFunds(100000)
            
            local canPurchase = economy:canAfford(150000)
            expect(canPurchase).to.be.falsy()
            
            canPurchase = economy:canAfford(50000)
            expect(canPurchase).to.be.truthy()
        end)
    end)
    
    describe("Item Pricing", function()
        it("should calculate base item costs", function()
            if not economy then return end
            
            local item = {
                type = "weapon",
                base_cost = 10000,
                complexity = 2
            }
            
            local cost = economy:calculateItemCost(item)
            expect(cost).to.be.greater_than_or_equal(10000)
        end)
        
        it("should apply bulk purchase discounts", function()
            if not economy then return end
            
            local unitCost = 1000
            local quantity = 50
            
            local totalCost = economy:calculateBulkPurchaseCost(unitCost, quantity)
            
            -- Bulk discount should apply
            expect(totalCost).to.be.less_than(unitCost * quantity)
        end)
        
        it("should calculate alien tech sale value", function()
            if not economy then return end
            
            local alienItem = {
                type = "alien_weapon",
                research_level = 1,
                condition = 0.8
            }
            
            local saleValue = economy:calculateAlienTechValue(alienItem)
            
            -- Researched items more valuable, condition affects price
            expect(saleValue).to.be.greater_than(0)
        end)
    end)
    
    describe("Manufacturing Costs", function()
        it("should calculate production costs", function()
            if not economy then return end
            
            local project = {
                item = "laser_rifle",
                materials_cost = 50000,
                engineer_hours = 100,
                hourly_rate = 200
            }
            
            local productionCost = economy:calculateProductionCost(project)
            
            local expectedCost = project.materials_cost + (project.engineer_hours * project.hourly_rate)
            expect(productionCost).to.equal(expectedCost)
        end)
        
        it("should factor in workshop efficiency", function()
            if not economy then return end
            
            local baseCost = 100000
            local efficiency = 1.2  -- 120% efficiency (upgraded workshops)
            
            local adjustedCost = economy:applyEfficiencyModifier(baseCost, efficiency)
            
            -- Higher efficiency = lower effective cost
            expect(adjustedCost).to.be.less_than(baseCost)
        end)
    end)
    
    describe("Monthly Report", function()
        it("should generate comprehensive financial report", function()
            if not economy then return end
            
            local gameState = {
                funding = 2000000,
                expenses = {
                    personnel = 800000,
                    maintenance = 300000,
                    operations = 200000
                },
                income = {
                    funding = 2000000,
                    sales = 150000
                }
            }
            
            local report = economy:generateMonthlyReport(gameState)
            
            expect(report).to.exist()
            expect(report.total_income).to.exist()
            expect(report.total_expenses).to.exist()
            expect(report.balance).to.exist()
        end)
        
        it("should track expense categories over time", function()
            if not economy then return end
            
            economy:recordExpense("personnel", 800000, 1)
            economy:recordExpense("research", 200000, 1)
            economy:recordExpense("personnel", 850000, 2)
            
            local history = economy:getExpenseHistory("personnel")
            
            expect(#history).to.be.greater_than_or_equal(2)
        end)
    end)
    
    describe("Funding Council", function()
        it("should adjust funding based on performance", function()
            if not economy then return end
            
            local currentFunding = 2000000
            local performance = {
                missions_succeeded = 8,
                missions_failed = 2,
                civilians_saved = 150,
                alien_threat_reduced = 0.25
            }
            
            local newFunding = economy:calculateFundingAdjustment(currentFunding, performance)
            
            -- Good performance should maintain or increase funding
            expect(newFunding).to.be.greater_than_or_equal(currentFunding * 0.9)
        end)
        
        it("should warn when funding is at risk", function()
            if not economy then return end
            
            local performance = {
                missions_succeeded = 2,
                missions_failed = 8,
                civilians_saved = 20,
                alien_threat_reduced = -0.1  -- Threat increased
            }
            
            local atRisk = economy:isFundingAtRisk(performance)
            
            expect(atRisk).to.be.truthy()
        end)
    end)
    
    describe("Resource Constraints", function()
        it("should enforce budget limits on purchases", function()
            if not economy then return end
            
            economy:setCurrentFunds(500000)
            economy:setBudgetLimit("research", 100000)
            
            local canPurchase = economy:canAffordWithBudget("research", 150000)
            
            expect(canPurchase).to.be.falsy()
        end)
        
        it("should track allocated vs spent budgets", function()
            if not economy then return end
            
            economy:setBudgetLimit("manufacturing", 200000)
            economy:spendFromBudget("manufacturing", 75000)
            
            local remaining = economy:getRemainingBudget("manufacturing")
            
            expect(remaining).to.equal(125000)
        end)
    end)
end)

return {
    name = "Economy System Tests",
    run = function()
        -- Tests run automatically via describe blocks
    end
}
