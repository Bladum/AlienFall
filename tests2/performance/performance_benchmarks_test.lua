-- TEST: Performance Benchmarks
-- FILE: tests2/performance/performance_benchmarks_test.lua
-- System-wide performance benchmarks and optimization targets

local HierarchicalSuite = require('tests2.framework.hierarchical_suite')
local Helpers = require('tests2.utils.test_helpers')

-- MOCK PATHFINDING SYSTEM
local MockPathfinding = {}
function MockPathfinding:new()
    local pf = { paths = {}, computeCount = 0 }

    function pf:findPath(startX, startY, endX, endY, width, height)
        pf.computeCount = pf.computeCount + 1
        local distance = math.abs(endX - startX) + math.abs(endY - startY)
        local path = {}
        for i = 1, distance do
            table.insert(path, {x = startX + i, y = startY})
        end
        return path
    end

    function pf:getComputeCount() return pf.computeCount end
    function pf:resetStats() pf.computeCount = 0 end

    return pf
end

-- MOCK LOS SYSTEM
local MockLOS = {}
function MockLOS:new()
    local los = { queries = 0 }

    function los:computeVisibility(x, y, visionRange, obstacles)
        los.queries = los.queries + 1
        local visible = {}
        for dx = -visionRange, visionRange do
            for dy = -visionRange, visionRange do
                local dist = math.sqrt(dx*dx + dy*dy)
                if dist <= visionRange then
                    table.insert(visible, {x = x + dx, y = y + dy})
                end
            end
        end
        return visible
    end

    function los:getQueryCount() return los.queries end

    return los
end

-- MOCK RENDERING SYSTEM
local MockRenderer = {}
function MockRenderer:new()
    local renderer = { renderCount = 0, frameTime = 0 }

    function renderer:renderTile(x, y, data)
        renderer.renderCount = renderer.renderCount + 1
    end

    function renderer:renderFrame()
        renderer.frameTime = os.clock()
    end

    function renderer:getRenderCount() return renderer.renderCount end

    return renderer
end

-- MOCK COMBAT SIMULATOR
local MockCombatSim = {}
function MockCombatSim:new()
    local sim = { actions = 0 }

    function sim:simulateAction(source, target, actionType)
        sim.actions = sim.actions + 1
        local accuracy = 0.75
        local hit = math.random() < accuracy
        local damage = hit and math.random(10, 50) or 0
        return { hit = hit, damage = damage }
    end

    function sim:getActionCount() return sim.actions end

    return sim
end

-- TEST SUITE
local Suite = HierarchicalSuite:new({
    modulePath = 'engine.performance.benchmarks',
    fileName = 'performance_benchmarks.lua',
    description = 'System-wide performance benchmarks'
})

-- GROUP 1: PATHFINDING BENCHMARKS
Suite:group('Pathfinding Benchmarks', function()
    Suite:testMethod('Pathfinding:smallMap', {
        description = 'Pathfinding on small 50x50 map',
        testCase = 'small_map',
        type = 'performance'
    }, function()
        local pf = MockPathfinding:new()
        local iterations = 1000
        local startTime = os.clock()

        for _ = 1, iterations do
            pf:findPath(0, 0, 10, 10, 50, 50)
        end

        local elapsed = os.clock() - startTime
        print('[Pathfinding] 1000 small paths: ' .. string.format('%.2f ms', elapsed * 1000))
        Helpers.assertLess((elapsed / iterations), 0.001, 'Each small path: <1ms')
    end)

    Suite:testMethod('Pathfinding:largeMap', {
        description = 'Pathfinding on large 200x200 map',
        testCase = 'large_map',
        type = 'performance'
    }, function()
        local pf = MockPathfinding:new()
        local iterations = 500
        local startTime = os.clock()

        for _ = 1, iterations do
            pf:findPath(0, 0, 150, 150, 200, 200)
        end

        local elapsed = os.clock() - startTime
        print('[Pathfinding] 500 large paths: ' .. string.format('%.2f ms', elapsed * 1000))
        Helpers.assertLess((elapsed / iterations), 0.005, 'Each large path: <5ms')
    end)
end)

-- GROUP 2: LINE OF SIGHT BENCHMARKS
Suite:group('Line of Sight Benchmarks', function()
    Suite:testMethod('LOS:shortRange', {
        description = 'LOS computation at short range',
        testCase = 'short_range',
        type = 'performance'
    }, function()
        local los = MockLOS:new()
        local iterations = 2000
        local startTime = os.clock()

        for _ = 1, iterations do
            los:computeVisibility(50, 50, 5, {})
        end

        local elapsed = os.clock() - startTime
        print('[LOS] 2000 short range queries: ' .. string.format('%.2f ms', elapsed * 1000))
        Helpers.assertLess((elapsed / iterations), 0.0005, 'Each query: <0.5ms')
    end)

    Suite:testMethod('LOS:mediumRange', {
        description = 'LOS computation at medium range',
        testCase = 'medium_range',
        type = 'performance'
    }, function()
        local los = MockLOS:new()
        local iterations = 1000
        local startTime = os.clock()

        for _ = 1, iterations do
            los:computeVisibility(50, 50, 12, {})
        end

        local elapsed = os.clock() - startTime
        print('[LOS] 1000 medium range queries: ' .. string.format('%.2f ms', elapsed * 1000))
        Helpers.assertLess((elapsed / iterations), 0.002, 'Each query: <2ms')
    end)
end)

-- GROUP 3: RENDERING BENCHMARKS
Suite:group('Rendering Benchmarks', function()
    Suite:testMethod('Rendering:singleFrame', {
        description = 'Render single frame with many tiles',
        testCase = 'single_frame',
        type = 'performance'
    }, function()
        local renderer = MockRenderer:new()
        local tileCount = 2500
        local startTime = os.clock()

        for y = 0, 49 do
            for x = 0, 49 do
                renderer:renderTile(x, y, {type = 'terrain'})
            end
        end

        local elapsed = os.clock() - startTime
        print('[Rendering] 2500 tiles in frame: ' .. string.format('%.2f ms', elapsed * 1000))
        Helpers.assertLess(elapsed, 0.016, 'Frame should be <16ms (60fps)')
    end)
end)

-- GROUP 4: COMBAT SIMULATION BENCHMARKS
Suite:group('Combat Benchmarks', function()
    Suite:testMethod('Combat:turnResolution', {
        description = 'Full turn with multiple combatants',
        testCase = 'turn_resolution',
        type = 'performance'
    }, function()
        local sim = MockCombatSim:new()
        local unitCount = 20
        local startTime = os.clock()

        for _ = 1, 100 do
            for u = 1, unitCount do
                sim:simulateAction(u, (u % unitCount) + 1, 'attack')
            end
        end

        local elapsed = os.clock() - startTime
        local actions = sim:getActionCount()
        print('[Combat] ' .. actions .. ' actions: ' .. string.format('%.2f ms', elapsed * 1000))
        Helpers.assertLess((elapsed / actions), 0.0001, 'Per-action: <0.1ms')
    end)
end)

-- GROUP 5: COMPREHENSIVE BENCHMARKS
Suite:group('Comprehensive Benchmarks', function()
    Suite:testMethod('Comprehensive:fullTurn', {
        description = 'Complete game turn with all systems',
        testCase = 'full_turn',
        type = 'performance'
    }, function()
        local pf = MockPathfinding:new()
        local los = MockLOS:new()
        local renderer = MockRenderer:new()
        local sim = MockCombatSim:new()

        local iterations = 100
        local startTime = os.clock()

        for _ = 1, iterations do
            pf:findPath(0, 0, 20, 20, 64, 64)
            los:computeVisibility(10, 10, 10, {})
            for i = 1, 256 do
                renderer:renderTile(i % 16, math.floor(i / 16), {})
            end
            sim:simulateAction(1, 2, 'attack')
        end

        local elapsed = os.clock() - startTime
        print('[Comprehensive] 100 full turns: ' .. string.format('%.2f ms', elapsed * 1000))
        Helpers.assertLess((elapsed / iterations), 0.05, 'Per-turn: <50ms')
    end)
end)

-- GROUP 6: STRESS TESTS
Suite:group('Stress Tests', function()
    Suite:testMethod('Stress:sustained', {
        description = 'Sustained high-frequency operations',
        testCase = 'sustained_load',
        type = 'performance'
    }, function()
        local pf = MockPathfinding:new()
        local iterations = 50000
        local startTime = os.clock()

        for _ = 1, iterations do
            pf:findPath(math.random(0, 50), math.random(0, 50),
                        math.random(0, 50), math.random(0, 50), 64, 64)
        end

        local elapsed = os.clock() - startTime
        print('[Stress] 50000 pathfinding operations: ' .. string.format('%.2f ms', elapsed * 1000))
        Helpers.assertLess((elapsed / iterations), 0.0005, 'Per-op: <0.5ms')
    end)
end)

Suite:run()
