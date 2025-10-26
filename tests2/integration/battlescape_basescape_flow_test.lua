-- TEST: Battlescape-Basescape Flow
-- FILE: tests2/integration/battlescape_basescape_flow_test.lua
-- Integration testing: unit deployment, equipment usage, and recovery workflow

local HierarchicalSuite = require('tests2.framework.hierarchical_suite')
local Helpers = require('tests2.utils.test_helpers')

-- MOCK SYSTEMS
local MockUnit = {}
function MockUnit:new(id)
    return {
        id = id,
        name = 'Unit_' .. id,
        health = 100,
        maxHealth = 100,
        status = 'Ready',
        equipment = {},
        experience = 0
    }
end

local MockBattle = {}
function MockBattle:new(unitList)
    local battle = {
        units = unitList or {},
        turns = 0,
        isActive = true,
        casualties = {}
    }
    
    function battle:startBattle()
        battle.isActive = true
        battle.turns = 0
        return true
    end
    
    function battle:deployUnit(unit)
        if not unit then return false end
        table.insert(battle.units, unit)
        unit.status = 'InCombat'
        return true
    end
    
    function battle:damageUnit(unitId, dmg)
        for _, u in ipairs(battle.units) do
            if u.id == unitId then
                u.health = math.max(0, u.health - dmg)
                if u.health == 0 then
                    u.status = 'Incapacitated'
                    table.insert(battle.casualties, unitId)
                end
                return true
            end
        end
        return false
    end
    
    function battle:endBattle()
        battle.isActive = false
        return true
    end
    
    function battle:getSurvivors()
        local survivors = {}
        for _, u in ipairs(battle.units) do
            if u.health > 0 and u.status ~= 'Incapacitated' then
                table.insert(survivors, u)
            end
        end
        return survivors
    end
    
    function battle:getCasualties()
        return battle.casualties
    end
    
    return battle
end

local MockBase = {}
function MockBase:new()
    local base = {
        units = {},
        facilities = {},
        infirmary = {},
        equipment = {},
        unitLimit = 100
    }
    
    function base:deployUnit(unitId)
        for i, u in ipairs(base.units) do
            if u.id == unitId then
                u.status = 'Deployed'
                table.remove(base.units, i)
                return true
            end
        end
        return false
    end
    
    function base:recoverUnit(unit)
        if not unit then return false end
        unit.status = 'Recovering'
        table.insert(base.infirmary, unit)
        return true
    end
    
    function base:healUnit(unitId, healAmount)
        for _, u in ipairs(base.infirmary) do
            if u.id == unitId then
                u.health = math.min(u.maxHealth, u.health + healAmount)
                if u.health == u.maxHealth then
                    u.status = 'Ready'
                    return true
                end
                return true
            end
        end
        return false
    end
    
    function base:getRecoveringUnits()
        return base.infirmary
    end
    
    function base:addUnit(unit)
        if #base.units < base.unitLimit then
            table.insert(base.units, unit)
            return true
        end
        return false
    end
    
    return base
end

-- TEST SUITE
local Suite = HierarchicalSuite:new({
    modulePath = 'engine.integration.battlescape_basescape_flow',
    fileName = 'battlescape_basescape_flow.lua',
    description = 'Battlescape-Basescape integration - deployment and recovery'
})

-- GROUP 1: UNIT DEPLOYMENT
Suite:group('Unit Deployment', function()
    local base, unit
    Suite:beforeEach(function()
        base = MockBase:new()
        unit = MockUnit:new(1)
        base:addUnit(unit)
    end)
    
    Suite:testMethod('Deployment:prepareUnit', {
        description = 'Unit can be deployed from base',
        testCase = 'deployment',
        type = 'functional'
    }, function()
        Helpers.assertEqual(unit.status, 'Ready', 'Unit should be ready')
        local ok = base:deployUnit(unit.id)
        Helpers.assertTrue(ok, 'Should deploy successfully')
        Helpers.assertEqual(unit.status, 'Deployed', 'Unit should be deployed')
    end)
    
    Suite:testMethod('Deployment:squadDeployment', {
        description = 'Multiple units can be deployed as squad',
        testCase = 'squad_deploy',
        type = 'functional'
    }, function()
        local u2 = MockUnit:new(2)
        local u3 = MockUnit:new(3)
        base:addUnit(u2)
        base:addUnit(u3)
        
        base:deployUnit(unit.id)
        base:deployUnit(u2.id)
        base:deployUnit(u3.id)
        
        Helpers.assertEqual(unit.status, 'Deployed', 'Unit 1 deployed')
        Helpers.assertEqual(u2.status, 'Deployed', 'Unit 2 deployed')
        Helpers.assertEqual(u3.status, 'Deployed', 'Unit 3 deployed')
    end)
end)

-- GROUP 2: BATTLE ENGAGEMENT
Suite:group('Battle Engagement', function()
    local battle, u1, u2, u3
    Suite:beforeEach(function()
        u1 = MockUnit:new(1)
        u2 = MockUnit:new(2)
        u3 = MockUnit:new(3)
        battle = MockBattle:new({u1, u2, u3})
        battle:startBattle()
    end)
    
    Suite:testMethod('Battle:unitInCombat', {
        description = 'Units transition to combat status',
        testCase = 'combat_entry',
        type = 'functional'
    }, function()
        Helpers.assertEqual(u1.status, 'InCombat', 'Unit should be in combat')
        Helpers.assertEqual(u2.status, 'InCombat', 'Unit should be in combat')
    end)
    
    Suite:testMethod('Battle:takeDamage', {
        description = 'Units can take damage in battle',
        testCase = 'damage',
        type = 'functional'
    }, function()
        battle:damageUnit(1, 25)
        Helpers.assertEqual(u1.health, 75, 'Unit should have 75 health')
        
        battle:damageUnit(1, 50)
        Helpers.assertEqual(u1.health, 25, 'Unit should have 25 health')
    end)
    
    Suite:testMethod('Battle:unitIncapacitation', {
        description = 'Unit becomes incapacitated at 0 health',
        testCase = 'incapacitation',
        type = 'functional'
    }, function()
        battle:damageUnit(2, 100)
        Helpers.assertEqual(u2.health, 0, 'Health should be 0')
        Helpers.assertEqual(u2.status, 'Incapacitated', 'Should be incapacitated')
        
        local casualties = battle:getCasualties()
        Helpers.assertEqual(#casualties, 1, 'Should have 1 casualty')
    end)
    
    Suite:testMethod('Battle:partialCasualties', {
        description = 'Battle can end with partial casualties',
        testCase = 'partial_loss',
        type = 'functional'
    }, function()
        battle:damageUnit(1, 100)
        battle:damageUnit(2, 100)
        battle:endBattle()
        
        local survivors = battle:getSurvivors()
        Helpers.assertEqual(#survivors, 1, 'Should have 1 survivor')
        
        local casualties = battle:getCasualties()
        Helpers.assertEqual(#casualties, 2, 'Should have 2 casualties')
    end)
end)

-- GROUP 3: POST-BATTLE RECOVERY
Suite:group('Post-Battle Recovery', function()
    local base, battle, u1, u2
    Suite:beforeEach(function()
        base = MockBase:new()
        u1 = MockUnit:new(1)
        u2 = MockUnit:new(2)
        battle = MockBattle:new({u1, u2})
        battle:startBattle()
    end)
    
    Suite:testMethod('Recovery:recoverWounded', {
        description = 'Wounded units can be recovered to base',
        testCase = 'recovery',
        type = 'functional'
    }, function()
        battle:damageUnit(1, 50)
        battle:endBattle()
        
        local ok = base:recoverUnit(u1)
        Helpers.assertTrue(ok, 'Should recover unit')
        Helpers.assertEqual(u1.status, 'Recovering', 'Unit should be recovering')
    end)
    
    Suite:testMethod('Recovery:infirmaryAdmission', {
        description = 'Multiple wounded units go to infirmary',
        testCase = 'infirmary',
        type = 'functional'
    }, function()
        battle:damageUnit(1, 60)
        battle:damageUnit(2, 40)
        battle:endBattle()
        
        base:recoverUnit(u1)
        base:recoverUnit(u2)
        
        local recovering = base:getRecoveringUnits()
        Helpers.assertEqual(#recovering, 2, 'Should have 2 recovering units')
    end)
    
    Suite:testMethod('Recovery:healingProcess', {
        description = 'Units heal gradually in infirmary',
        testCase = 'healing',
        type = 'functional'
    }, function()
        battle:damageUnit(1, 75)
        base:recoverUnit(u1)
        
        base:healUnit(1, 40)
        Helpers.assertEqual(u1.health, 65, 'Should heal to 65')
        
        base:healUnit(1, 35)
        Helpers.assertEqual(u1.health, 100, 'Should heal to 100')
        Helpers.assertEqual(u1.status, 'Ready', 'Should be ready')
    end)
end)

-- GROUP 4: COMPLETE WORKFLOW
Suite:group('Complete Workflow', function()
    local base, u1, u2, u3
    Suite:beforeEach(function()
        base = MockBase:new()
        u1 = MockUnit:new(1)
        u2 = MockUnit:new(2)
        u3 = MockUnit:new(3)
        base:addUnit(u1)
        base:addUnit(u2)
        base:addUnit(u3)
    end)
    
    Suite:testMethod('Workflow:deployAndReturn', {
        description = 'Full cycle: deploy, battle, return, recover',
        testCase = 'full_cycle',
        type = 'functional'
    }, function()
        -- Deploy squad
        base:deployUnit(1)
        base:deployUnit(2)
        base:deployUnit(3)
        Helpers.assertEqual(u1.status, 'Deployed', 'All deployed')
        
        -- Battle
        local battle = MockBattle:new({u1, u2, u3})
        battle:startBattle()
        battle:damageUnit(1, 45)
        battle:damageUnit(2, 30)
        battle:endBattle()
        
        -- Return and recover
        base:recoverUnit(u1)
        base:recoverUnit(u2)
        base:recoverUnit(u3)
        
        Helpers.assertEqual(u1.status, 'Recovering', 'Damaged unit recovering')
        Helpers.assertEqual(u3.status, 'Recovering', 'All units recovering')
        
        -- Heal
        base:healUnit(1, 45)
        base:healUnit(2, 30)
        base:healUnit(3, 0)
        
        Helpers.assertEqual(u1.status, 'Ready', 'Unit 1 ready')
        Helpers.assertEqual(u2.status, 'Ready', 'Unit 2 ready')
        Helpers.assertEqual(u3.status, 'Ready', 'Unit 3 ready')
    end)
    
    Suite:testMethod('Workflow:multipleDeployments', {
        description = 'Units can be deployed and returned multiple times',
        testCase = 'multiple_cycles',
        type = 'functional'
    }, function()
        for cycle = 1, 3 do
            -- Deploy
            base:deployUnit(1)
            Helpers.assertEqual(u1.status, 'Deployed', 'Deployed cycle ' .. cycle)
            
            -- Battle
            local battle = MockBattle:new({u1})
            battle:startBattle()
            battle:damageUnit(1, 10)
            battle:endBattle()
            
            -- Return
            base:recoverUnit(u1)
            base:healUnit(1, 100)
            Helpers.assertEqual(u1.status, 'Ready', 'Ready for cycle ' .. (cycle + 1))
        end
    end)
end)

-- GROUP 5: CASUALTY MANAGEMENT
Suite:group('Casualty Management', function()
    Suite:testMethod('Casualties:tracking', {
        description = 'Casualties are properly tracked',
        testCase = 'casualty_tracking',
        type = 'functional'
    }, function()
        local u1 = MockUnit:new(1)
        local u2 = MockUnit:new(2)
        local u3 = MockUnit:new(3)
        
        local battle = MockBattle:new({u1, u2, u3})
        battle:startBattle()
        battle:damageUnit(1, 100)
        battle:damageUnit(2, 100)
        
        local casualties = battle:getCasualties()
        Helpers.assertEqual(#casualties, 2, 'Should track 2 casualties')
    end)
end)

-- GROUP 6: PERFORMANCE
Suite:group('Performance', function()
    Suite:testMethod('Performance:deployment', {
        description = 'Deploying many units is efficient',
        testCase = 'deployment_speed',
        type = 'performance'
    }, function()
        local base = MockBase:new()
        local iterations = 1000
        local startTime = os.clock()
        
        for i = 1, iterations do
            local u = MockUnit:new(i)
            base:addUnit(u)
            base:deployUnit(i)
        end
        
        local elapsed = os.clock() - startTime
        print('[Flow Performance] ' .. iterations .. ' deployments: ' ..
              string.format('%.2f ms', elapsed * 1000))
        Helpers.assertLess((elapsed / iterations), 0.001, 'Per-deployment: <1ms')
    end)
    
    Suite:testMethod('Performance:recovery', {
        description = 'Recovery operations are efficient',
        testCase = 'recovery_speed',
        type = 'performance'
    }, function()
        local base = MockBase:new()
        local units = {}
        for i = 1, 500 do
            local u = MockUnit:new(i)
            table.insert(units, u)
        end
        
        local iterations = 500
        local startTime = os.clock()
        
        for _, u in ipairs(units) do
            base:recoverUnit(u)
        end
        
        for i = 1, iterations do
            base:healUnit(i, 50)
        end
        
        local elapsed = os.clock() - startTime
        print('[Flow Performance] ' .. iterations .. ' heal operations: ' ..
              string.format('%.2f ms', elapsed * 1000))
    end)
end)

Suite:run()
