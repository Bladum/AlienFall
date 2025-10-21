-- Integration Tests for Base Management
-- Tests complete base management workflows

local BaseIntegrationTest = {}

-- Test setup
local function setup()
    package.path = package.path .. ";../../?.lua;../../engine/?.lua"
    
    local MockFacilities = require("mock.facilities")
    local MockUnits = require("mock.units")
    local MockEconomy = require("mock.economy")
    
    return MockFacilities, MockUnits, MockEconomy
end

-- Test base initialization
function BaseIntegrationTest.testBaseSetup()
    local MockFacilities = setup()
    
    local base = MockFacilities.getStarterBase()
    
    assert(base ~= nil, "Base not created")
    assert(base.name ~= nil, "Base has no name")
    assert(#base.facilities > 0, "Base has no facilities")
    assert(base.capacity.soldiers > 0, "No soldier capacity")
    
    print("✓ testBaseSetup passed")
end

-- Test facility construction workflow
function BaseIntegrationTest.testConstructionWorkflow()
    local MockFacilities = setup()
    
    local base = MockFacilities.getStarterBase()
    local constructionOrder = MockFacilities.getConstructionOrder("LABORATORY", 3, 3, 15)
    
    table.insert(base.constructionQueue, constructionOrder)
    
    assert(#base.constructionQueue == 1, "Construction order not added")
    
    -- Simulate daily progression
    for day = 1, 20 do
        for i = #base.constructionQueue, 1, -1 do
            local order = base.constructionQueue[i]
            order.daysRemaining = order.daysRemaining - 1
            
            if order.daysRemaining <= 0 then
                -- Complete construction
                local facility = MockFacilities.getFacility(order.typeId, order.x, order.y)
                table.insert(base.facilities, facility)
                table.remove(base.constructionQueue, i)
            end
        end
    end
    
    assert(#base.constructionQueue == 0, "Construction not completed")
    assert(#base.facilities > 1, "Facility not built")
    
    print("✓ testConstructionWorkflow passed")
end

-- Test resource management
function BaseIntegrationTest.testResourceManagement()
    local MockFacilities, MockUnits, MockEconomy = setup()
    
    local base = MockFacilities.getFullBase()
    local finances = MockEconomy.getFinances(1000000)
    
    -- Monthly expenses
    local totalExpenses = 0
    for _, amount in pairs(finances.expenses) do
        totalExpenses = totalExpenses + amount
    end
    
    -- Monthly income
    local totalIncome = 0
    for _, amount in pairs(finances.income) do
        totalIncome = totalIncome + amount
    end
    
    -- Calculate profit
    local monthlyProfit = totalIncome - totalExpenses - base.monthlyMaintenance
    
    assert(monthlyProfit ~= 0, "No profit/loss calculated")
    
    -- Update balance
    finances.balance = finances.balance + monthlyProfit
    
    print("✓ testResourceManagement passed")
end

-- Test soldier recruitment and assignment
function BaseIntegrationTest.testSoldierManagement()
    local MockFacilities, MockUnits = setup()
    
    local base = MockFacilities.getStarterBase()
    local squad = MockUnits.generateSquad(6)
    
    -- Assign soldiers to base
    base.soldiers = squad
    base.usage.soldiers = #squad
    
    assert(#base.soldiers == 6, "Soldiers not assigned")
    assert(base.usage.soldiers <= base.capacity.soldiers, "Over capacity")
    
    -- Check wounded soldiers
    local woundedCount = 0
    for _, soldier in ipairs(base.soldiers) do
        if soldier.isWounded then
            woundedCount = woundedCount + 1
        end
    end
    
    print("✓ testSoldierManagement passed")
end

-- Test research progression
function BaseIntegrationTest.testResearchProgression()
    local MockFacilities, _, MockEconomy = setup()
    
    local base = MockFacilities.getFullBase()
    local researchQueue = MockEconomy.getResearchQueue()
    
    assert(researchQueue.current ~= nil, "No active research")
    assert(researchQueue.scientists > 0, "No scientists assigned")
    
    -- Simulate daily progress
    local dailyProgress = researchQueue.scientists * 1 -- 1 lab day per scientist per day
    
    for day = 1, 30 do
        researchQueue.current.progress = researchQueue.current.progress + dailyProgress
        
        if researchQueue.current.progress >= researchQueue.current.labDays then
            -- Complete research
            researchQueue.current.completed = true
            break
        end
    end
    
    assert(researchQueue.current.progress > 0, "No research progress")
    
    print("✓ testResearchProgression passed")
end

-- Test manufacturing
function BaseIntegrationTest.testManufacturing()
    local MockFacilities, _, MockEconomy = setup()
    
    local base = MockFacilities.getFullBase()
    local mfgQueue = MockEconomy.getManufacturingQueue()
    local materials = MockEconomy.getMaterials()
    
    assert(mfgQueue.current ~= nil, "No active manufacturing")
    assert(mfgQueue.engineers > 0, "No engineers assigned")
    
    -- Check materials availability
    local canBuild = true
    for _, required in ipairs(mfgQueue.current.materials) do
        local available = false
        for _, material in ipairs(materials) do
            if material.id == required.id and material.amount >= required.amount then
                available = true
                break
            end
        end
        if not available then
            canBuild = false
            break
        end
    end
    
    assert(canBuild, "Insufficient materials")
    
    -- Simulate manufacturing progress
    local dailyProgress = mfgQueue.engineers * 0.5
    mfgQueue.current.progress = mfgQueue.current.progress + dailyProgress
    
    assert(mfgQueue.current.progress > 0, "No manufacturing progress")
    
    print("✓ testManufacturing passed")
end

-- Test base expansion
function BaseIntegrationTest.testBaseExpansion()
    local MockFacilities = setup()
    
    local base = MockFacilities.getStarterBase()
    local initialFacilities = #base.facilities
    local initialCapacity = base.capacity.soldiers
    
    -- Add more living quarters
    local newQuarters = MockFacilities.getFacility("LIVING_QUARTERS", 4, 2)
    table.insert(base.facilities, newQuarters)
    
    -- Recalculate capacity
    base.capacity.soldiers = base.capacity.soldiers + 25 -- Living quarters adds 25
    
    assert(#base.facilities > initialFacilities, "No new facilities")
    assert(base.capacity.soldiers > initialCapacity, "Capacity not increased")
    
    print("✓ testBaseExpansion passed")
end

-- Test base defense scenario
function BaseIntegrationTest.testBaseDefense()
    local MockFacilities, MockUnits = setup()
    
    local base = MockFacilities.getFullBase()
    local defenders = MockUnits.generateSquad(8)
    local attackers = MockUnits.generateEnemyGroup(12, {"MUTON", "FLOATER", "SECTOID"})
    
    -- Assign defenders
    base.soldiers = defenders
    
    -- Count combat-ready soldiers
    local readySoldiers = 0
    for _, soldier in ipairs(base.soldiers) do
        if soldier.isAlive and not soldier.isWounded then
            readySoldiers = readySoldiers + 1
        end
    end
    
    assert(readySoldiers > 0, "No combat-ready soldiers")
    assert(#attackers > 0, "No attackers")
    
    -- Simulate facility damage
    if #base.facilities > 0 then
        local facility = base.facilities[1]
        local damage = 50
        facility.hp = math.max(0, facility.hp - damage)
        
        if facility.hp < facility.maxHp * 0.5 then
            facility.operational = false
        end
    end
    
    print("✓ testBaseDefense passed")
end

-- Test monthly finances
function BaseIntegrationTest.testMonthlyFinances()
    local MockFacilities, _, MockEconomy = setup()
    
    local base = MockFacilities.getFullBase()
    local finances = MockEconomy.getFinances()
    local fundingReport = MockEconomy.getFundingReport()
    
    -- Calculate total income
    local monthlyIncome = fundingReport.totalFunding + fundingReport.bonusFunding
    
    -- Calculate total expenses
    local monthlyExpenses = base.monthlyMaintenance
    for _, expense in pairs(finances.expenses) do
        monthlyExpenses = monthlyExpenses + expense
    end
    
    -- Net profit/loss
    local netResult = monthlyIncome - monthlyExpenses
    
    -- Update balance
    finances.balance = finances.balance + netResult
    
    assert(finances.balance > 0, "Base is bankrupt")
    
    print("✓ testMonthlyFinances passed")
end

-- Test storage capacity
function BaseIntegrationTest.testStorageCapacity()
    local MockFacilities, _, MockEconomy = setup()
    
    local base = MockFacilities.getFullBase()
    local materials = MockEconomy.getMaterials()
    
    -- Calculate total weight
    local totalWeight = 0
    for _, material in ipairs(materials) do
        totalWeight = totalWeight + (material.amount * material.weight)
    end
    
    assert(totalWeight > 0, "No materials stored")
    assert(totalWeight <= base.capacity.storage, "Over storage capacity")
    
    print("✓ testStorageCapacity passed")
end

-- Run all integration tests
function BaseIntegrationTest.runAll()
    print("\n=== Base Management Integration Tests ===")
    
    BaseIntegrationTest.testBaseSetup()
    BaseIntegrationTest.testConstructionWorkflow()
    BaseIntegrationTest.testResourceManagement()
    BaseIntegrationTest.testSoldierManagement()
    BaseIntegrationTest.testResearchProgression()
    BaseIntegrationTest.testManufacturing()
    BaseIntegrationTest.testBaseExpansion()
    BaseIntegrationTest.testBaseDefense()
    BaseIntegrationTest.testMonthlyFinances()
    BaseIntegrationTest.testStorageCapacity()
    
    print("✓ All Base Management Integration tests passed!\n")
end

return BaseIntegrationTest



