-- TEST: ECS Components
-- FILE: tests2/battlescape/ecs_components_test.lua
-- Entity-Component-System lifecycle and registration tests

local HierarchicalSuite = require('tests2.framework.hierarchical_suite')
local Helpers = require('tests2.utils.test_helpers')

-- MOCK ECS SYSTEM
local MockECS = {}
function MockECS:new()
    local ecs = {
        entities = {},
        components = {},
        systems = {},
        nextEntityId = 1,
        componentTypes = {}
    }
    
    function ecs:registerComponent(componentType)
        ecs.componentTypes[componentType] = true
        ecs.components[componentType] = {}
        return true
    end
    
    function ecs:createEntity()
        local entityId = ecs.nextEntityId
        ecs.nextEntityId = ecs.nextEntityId + 1
        ecs.entities[entityId] = { id = entityId, components = {} }
        return entityId
    end
    
    function ecs:addComponent(entityId, componentType, data)
        if not ecs.entities[entityId] then return false, 'Entity not found' end
        if not ecs.componentTypes[componentType] then return false, 'Component type not registered' end
        
        ecs.entities[entityId].components[componentType] = true
        ecs.components[componentType][entityId] = data or {}
        return true
    end
    
    function ecs:removeComponent(entityId, componentType)
        if not ecs.entities[entityId] then return false end
        ecs.entities[entityId].components[componentType] = nil
        ecs.components[componentType][entityId] = nil
        return true
    end
    
    function ecs:hasComponent(entityId, componentType)
        if not ecs.entities[entityId] then return false end
        return ecs.entities[entityId].components[componentType] == true
    end
    
    function ecs:getComponent(entityId, componentType)
        if not ecs.entities[entityId] then return nil end
        return ecs.components[componentType][entityId]
    end
    
    function ecs:getEntitiesWith(componentType)
        local result = {}
        for entityId, _ in pairs(ecs.components[componentType]) do
            table.insert(result, entityId)
        end
        return result
    end
    
    function ecs:deleteEntity(entityId)
        if not ecs.entities[entityId] then return false end
        for componentType, _ in pairs(ecs.entities[entityId].components) do
            ecs.components[componentType][entityId] = nil
        end
        ecs.entities[entityId] = nil
        return true
    end
    
    function ecs:registerSystem(systemName, components)
        ecs.systems[systemName] = {
            name = systemName,
            requiredComponents = components or {},
            updateCount = 0
        }
        return true
    end
    
    function ecs:updateSystem(systemName)
        if not ecs.systems[systemName] then return false end
        ecs.systems[systemName].updateCount = ecs.systems[systemName].updateCount + 1
        return true
    end
    
    function ecs:getSystemStats(systemName)
        if not ecs.systems[systemName] then return nil end
        return {
            name = ecs.systems[systemName].name,
            updates = ecs.systems[systemName].updateCount,
            required = ecs.systems[systemName].requiredComponents
        }
    end
    
    function ecs:getEntityCount() return ecs.nextEntityId - 1 end
    function ecs:getComponentCount(componentType) return #ecs:getEntitiesWith(componentType) end
    
    return ecs
end

-- TEST SUITE
local Suite = HierarchicalSuite:new({
    modulePath = 'engine.core.ecs.ecs_system',
    fileName = 'ecs_system.lua',
    description = 'ECS - Entity-Component-System lifecycle'
})

-- GROUP 1: COMPONENT REGISTRATION
Suite:group('Component Registration', function()
    local ecs
    Suite:beforeEach(function() ecs = MockECS:new() end)
    
    Suite:testMethod('ECS:registerComponent', {
        description = 'Registering component type succeeds',
        testCase = 'registration',
        type = 'functional'
    }, function()
        local ok = ecs:registerComponent('Transform')
        Helpers.assertTrue(ok, 'Should register component')
        Helpers.assertTrue(ecs.componentTypes['Transform'], 'Should store component type')
    end)
    
    Suite:testMethod('ECS:multipleComponents', {
        description = 'Multiple component types can be registered',
        testCase = 'multiple_types',
        type = 'functional'
    }, function()
        ecs:registerComponent('Transform')
        ecs:registerComponent('Health')
        ecs:registerComponent('Weapon')
        Helpers.assertTrue(ecs.componentTypes['Transform'], 'Transform registered')
        Helpers.assertTrue(ecs.componentTypes['Health'], 'Health registered')
        Helpers.assertTrue(ecs.componentTypes['Weapon'], 'Weapon registered')
    end)
end)

-- GROUP 2: ENTITY CREATION AND LIFECYCLE
Suite:group('Entity Lifecycle', function()
    local ecs
    Suite:beforeEach(function()
        ecs = MockECS:new()
        ecs:registerComponent('Transform')
        ecs:registerComponent('Health')
    end)
    
    Suite:testMethod('ECS:createEntity', {
        description = 'Creating entity returns unique ID',
        testCase = 'creation',
        type = 'functional'
    }, function()
        local e1 = ecs:createEntity()
        local e2 = ecs:createEntity()
        Helpers.assertNotNil(e1, 'Should create entity 1')
        Helpers.assertNotNil(e2, 'Should create entity 2')
        Helpers.assertNotEqual(e1, e2, 'Entities should have different IDs')
    end)
    
    Suite:testMethod('ECS:deleteEntity', {
        description = 'Deleting entity removes it and components',
        testCase = 'deletion',
        type = 'functional'
    }, function()
        local e = ecs:createEntity()
        ecs:addComponent(e, 'Transform', {x=0, y=0})
        ecs:deleteEntity(e)
        Helpers.assertNil(ecs.entities[e], 'Entity should be deleted')
    end)
    
    Suite:testMethod('ECS:entityCount', {
        description = 'Entity count tracking is accurate',
        testCase = 'counting',
        type = 'functional'
    }, function()
        Helpers.assertEqual(ecs:getEntityCount(), 0, 'Start with 0 entities')
        ecs:createEntity()
        Helpers.assertEqual(ecs:getEntityCount(), 1, 'Should have 1 entity')
        ecs:createEntity()
        Helpers.assertEqual(ecs:getEntityCount(), 2, 'Should have 2 entities')
    end)
end)

-- GROUP 3: COMPONENT ATTACHMENT
Suite:group('Component Attachment', function()
    local ecs
    Suite:beforeEach(function()
        ecs = MockECS:new()
        ecs:registerComponent('Transform')
        ecs:registerComponent('Health')
        ecs:registerComponent('Weapon')
    end)
    
    Suite:testMethod('ECS:addComponent', {
        description = 'Adding component to entity succeeds',
        testCase = 'attachment',
        type = 'functional'
    }, function()
        local e = ecs:createEntity()
        local ok = ecs:addComponent(e, 'Transform', {x=10, y=20})
        Helpers.assertTrue(ok, 'Should add component')
        Helpers.assertTrue(ecs:hasComponent(e, 'Transform'), 'Entity should have component')
    end)
    
    Suite:testMethod('ECS:multipleComponents', {
        description = 'Entity can have multiple components',
        testCase = 'multi_component',
        type = 'functional'
    }, function()
        local e = ecs:createEntity()
        ecs:addComponent(e, 'Transform', {x=0})
        ecs:addComponent(e, 'Health', {hp=100})
        ecs:addComponent(e, 'Weapon', {dmg=10})
        Helpers.assertTrue(ecs:hasComponent(e, 'Transform'), 'Has Transform')
        Helpers.assertTrue(ecs:hasComponent(e, 'Health'), 'Has Health')
        Helpers.assertTrue(ecs:hasComponent(e, 'Weapon'), 'Has Weapon')
    end)
    
    Suite:testMethod('ECS:getComponent', {
        description = 'Getting component data returns attached data',
        testCase = 'data_retrieval',
        type = 'functional'
    }, function()
        local e = ecs:createEntity()
        ecs:addComponent(e, 'Transform', {x=15, y=25})
        local data = ecs:getComponent(e, 'Transform')
        Helpers.assertNotNil(data, 'Should get component data')
        Helpers.assertEqual(data.x, 15, 'X should be 15')
        Helpers.assertEqual(data.y, 25, 'Y should be 25')
    end)
end)

-- GROUP 4: COMPONENT REMOVAL
Suite:group('Component Removal', function()
    local ecs
    Suite:beforeEach(function()
        ecs = MockECS:new()
        ecs:registerComponent('Transform')
        ecs:registerComponent('Health')
    end)
    
    Suite:testMethod('ECS:removeComponent', {
        description = 'Removing component from entity succeeds',
        testCase = 'removal',
        type = 'functional'
    }, function()
        local e = ecs:createEntity()
        ecs:addComponent(e, 'Transform', {})
        local ok = ecs:removeComponent(e, 'Transform')
        Helpers.assertTrue(ok, 'Should remove component')
        Helpers.assertFalse(ecs:hasComponent(e, 'Transform'), 'Should not have component')
    end)
    
    Suite:testMethod('ECS:selectiveRemoval', {
        description = 'Removing one component keeps others',
        testCase = 'selective',
        type = 'functional'
    }, function()
        local e = ecs:createEntity()
        ecs:addComponent(e, 'Transform', {})
        ecs:addComponent(e, 'Health', {hp=100})
        ecs:removeComponent(e, 'Transform')
        Helpers.assertFalse(ecs:hasComponent(e, 'Transform'), 'Transform removed')
        Helpers.assertTrue(ecs:hasComponent(e, 'Health'), 'Health still present')
    end)
end)

-- GROUP 5: QUERY SYSTEMS
Suite:group('Query Systems', function()
    local ecs
    Suite:beforeEach(function()
        ecs = MockECS:new()
        ecs:registerComponent('Transform')
        ecs:registerComponent('Health')
        ecs:registerComponent('Weapon')
        
        local e1 = ecs:createEntity()
        ecs:addComponent(e1, 'Transform', {})
        ecs:addComponent(e1, 'Health', {})
        
        local e2 = ecs:createEntity()
        ecs:addComponent(e2, 'Transform', {})
        
        local e3 = ecs:createEntity()
        ecs:addComponent(e3, 'Weapon', {})
    end)
    
    Suite:testMethod('ECS:getEntitiesWith', {
        description = 'Querying entities with component returns correct set',
        testCase = 'query',
        type = 'functional'
    }, function()
        local withTransform = ecs:getEntitiesWith('Transform')
        Helpers.assertEqual(#withTransform, 2, 'Should find 2 with Transform')
        
        local withHealth = ecs:getEntitiesWith('Health')
        Helpers.assertEqual(#withHealth, 1, 'Should find 1 with Health')
        
        local withWeapon = ecs:getEntitiesWith('Weapon')
        Helpers.assertEqual(#withWeapon, 1, 'Should find 1 with Weapon')
    end)
    
    Suite:testMethod('ECS:componentCount', {
        description = 'Component count is accurate',
        testCase = 'counting',
        type = 'functional'
    }, function()
        Helpers.assertEqual(ecs:getComponentCount('Transform'), 2, 'Transform count 2')
        Helpers.assertEqual(ecs:getComponentCount('Health'), 1, 'Health count 1')
        Helpers.assertEqual(ecs:getComponentCount('Weapon'), 1, 'Weapon count 1')
    end)
end)

-- GROUP 6: SYSTEM MANAGEMENT
Suite:group('System Management', function()
    local ecs
    Suite:beforeEach(function() ecs = MockECS:new() end)
    
    Suite:testMethod('ECS:registerSystem', {
        description = 'Registering system succeeds',
        testCase = 'registration',
        type = 'functional'
    }, function()
        local ok = ecs:registerSystem('RenderSystem', {'Transform'})
        Helpers.assertTrue(ok, 'Should register system')
        Helpers.assertNotNil(ecs.systems['RenderSystem'], 'System should exist')
    end)
    
    Suite:testMethod('ECS:updateSystem', {
        description = 'Updating system increments counter',
        testCase = 'update',
        type = 'functional'
    }, function()
        ecs:registerSystem('PhysicsSystem', {})
        ecs:updateSystem('PhysicsSystem')
        local stats = ecs:getSystemStats('PhysicsSystem')
        Helpers.assertEqual(stats.updates, 1, 'Update count should be 1')
        
        ecs:updateSystem('PhysicsSystem')
        stats = ecs:getSystemStats('PhysicsSystem')
        Helpers.assertEqual(stats.updates, 2, 'Update count should be 2')
    end)
end)

-- GROUP 7: PERFORMANCE
Suite:group('Performance', function()
    Suite:testMethod('ECS:entity_creation', {
        description = 'Creating many entities is efficient',
        testCase = 'entity_speed',
        type = 'performance'
    }, function()
        local ecs = MockECS:new()
        local iterations = 10000
        local startTime = os.clock()
        
        for _ = 1, iterations do
            ecs:createEntity()
        end
        
        local elapsed = os.clock() - startTime
        print('[ECS Performance] ' .. iterations .. ' entity creations: ' ..
              string.format('%.2f ms', elapsed * 1000))
        Helpers.assertLess((elapsed / iterations), 0.0001, 'Per-entity: <0.1ms')
    end)
    
    Suite:testMethod('ECS:component_operations', {
        description = 'Component operations are efficient',
        testCase = 'component_speed',
        type = 'performance'
    }, function()
        local ecs = MockECS:new()
        ecs:registerComponent('Transform')
        ecs:registerComponent('Health')
        
        local e = ecs:createEntity()
        local iterations = 50000
        local startTime = os.clock()
        
        for i = 1, iterations do
            if i % 2 == 0 then
                ecs:addComponent(e, 'Transform', {})
                ecs:removeComponent(e, 'Transform')
            else
                ecs:addComponent(e, 'Health', {})
                ecs:removeComponent(e, 'Health')
            end
        end
        
        local elapsed = os.clock() - startTime
        print('[ECS Performance] ' .. iterations .. ' add/remove cycles: ' ..
              string.format('%.2f ms', elapsed * 1000))
        Helpers.assertLess((elapsed / iterations), 0.00005, 'Per-operation: <0.05ms')
    end)
    
    Suite:testMethod('ECS:queries', {
        description = 'Entity queries with many components are efficient',
        testCase = 'query_speed',
        type = 'performance'
    }, function()
        local ecs = MockECS:new()
        for i = 1, 10 do
            ecs:registerComponent('Component' .. i)
        end
        
        for i = 1, 1000 do
            local e = ecs:createEntity()
            for j = 1, math.random(2, 5) do
                ecs:addComponent(e, 'Component' .. j, {})
            end
        end
        
        local iterations = 10000
        local startTime = os.clock()
        for _ = 1, iterations do
            ecs:getEntitiesWith('Component1')
        end
        
        local elapsed = os.clock() - startTime
        print('[ECS Performance] ' .. iterations .. ' queries (1000 entities): ' ..
              string.format('%.2f ms', elapsed * 1000))
        Helpers.assertLess((elapsed / iterations), 0.0001, 'Per-query: <0.1ms')
    end)
end)

Suite:run()
