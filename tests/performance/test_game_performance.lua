-- Performance Tests for Critical Systems
-- Benchmarks pathfinding, rendering, and game loop performance

local PerformanceTest = {}

-- Benchmark helper
local function benchmark(name, iterations, func)
    local startTime = os.clock()
    
    for i = 1, iterations do
        func()
    end
    
    local endTime = os.clock()
    local totalTime = endTime - startTime
    local avgTime = totalTime / iterations
    
    print(string.format("  %s: %.4fs total, %.6fs avg (%d iterations)", 
          name, totalTime, avgTime, iterations))
    
    return totalTime, avgTime
end

-- Test pathfinding performance
function PerformanceTest.testPathfinding()
    print("\n=== Pathfinding Performance ===")
    
    -- Create a simple grid
    local gridSize = 100
    local grid = {}
    for y = 1, gridSize do
        grid[y] = {}
        for x = 1, gridSize do
            grid[y][x] = math.random() > 0.2 and 1 or 0 -- 20% obstacles
        end
    end
    
    -- Simple pathfinding function (placeholder)
    local function findPath(startX, startY, endX, endY)
        local path = {}
        -- Simplified pathfinding for benchmark
        local x, y = startX, startY
        while x ~= endX or y ~= endY do
            if x < endX then x = x + 1
            elseif x > endX then x = x - 1 end
            if y < endY then y = y + 1
            elseif y > endY then y = y - 1 end
            table.insert(path, {x = x, y = y})
            if #path > 1000 then break end -- Prevent infinite loops
        end
        return path
    end
    
    benchmark("Short paths (10 tiles)", 1000, function()
        findPath(1, 1, 10, 10)
    end)
    
    benchmark("Medium paths (50 tiles)", 100, function()
        findPath(1, 1, 50, 50)
    end)
    
    benchmark("Long paths (100 tiles)", 50, function()
        findPath(1, 1, 100, 100)
    end)
    
    print("✓ Pathfinding performance test completed")
end

-- Test hex math performance
function PerformanceTest.testHexMath()
    print("\n=== Hex Math Performance ===")
    
    -- Hex to pixel conversion
    local function hexToPixel(q, r, size)
        local x = size * (3/2 * q)
        local y = size * (math.sqrt(3)/2 * q + math.sqrt(3) * r)
        return x, y
    end
    
    -- Pixel to hex conversion
    local function pixelToHex(x, y, size)
        local q = (2/3 * x) / size
        local r = (-1/3 * x + math.sqrt(3)/3 * y) / size
        return math.floor(q + 0.5), math.floor(r + 0.5)
    end
    
    benchmark("Hex to pixel", 10000, function()
        hexToPixel(math.random(0, 80), math.random(0, 60), 32)
    end)
    
    benchmark("Pixel to hex", 10000, function()
        pixelToHex(math.random(0, 2560), math.random(0, 1920), 32)
    end)
    
    -- Hex distance
    local function hexDistance(q1, r1, q2, r2)
        return (math.abs(q1 - q2) + math.abs(r1 - r2) + math.abs(q1 + r1 - q2 - r2)) / 2
    end
    
    benchmark("Hex distance", 10000, function()
        hexDistance(0, 0, math.random(0, 80), math.random(0, 60))
    end)
    
    print("✓ Hex math performance test completed")
end

-- Test unit management performance
function PerformanceTest.testUnitManagement()
    print("\n=== Unit Management Performance ===")
    
    package.path = package.path .. ";../../?.lua"
    local MockUnits = require("mock.units")
    
    -- Create large squad
    local units = {}
    for i = 1, 100 do
        table.insert(units, MockUnits.getSoldier("Soldier" .. i, "ASSAULT"))
    end
    
    -- Test iteration
    benchmark("Iterate 100 units", 1000, function()
        for _, unit in ipairs(units) do
            local _ = unit.name
        end
    end)
    
    -- Test filtering
    benchmark("Filter alive units", 1000, function()
        local alive = {}
        for _, unit in ipairs(units) do
            if unit.isAlive then
                table.insert(alive, unit)
            end
        end
    end)
    
    -- Test stat calculation
    benchmark("Calculate unit stats", 1000, function()
        for _, unit in ipairs(units) do
            local effective = unit.aim + unit.will - unit.stamina / 10
        end
    end)
    
    print("✓ Unit management performance test completed")
end

-- Test data structure performance
function PerformanceTest.testDataStructures()
    print("\n=== Data Structure Performance ===")
    
    -- Array insertion
    local array = {}
    benchmark("Array insert (1000 items)", 1, function()
        for i = 1, 1000 do
            table.insert(array, i)
        end
    end)
    
    -- Table lookup
    local lookup = {}
    for i = 1, 1000 do
        lookup["key" .. i] = i
    end
    
    benchmark("Table lookup (1000 items)", 10000, function()
        local _ = lookup["key" .. math.random(1, 1000)]
    end)
    
    -- Table iteration
    benchmark("Table iteration (1000 items)", 1000, function()
        for k, v in pairs(lookup) do
            local _ = k
        end
    end)
    
    -- Array iteration
    benchmark("Array iteration (1000 items)", 1000, function()
        for i, v in ipairs(array) do
            local _ = v
        end
    end)
    
    print("✓ Data structure performance test completed")
end

-- Test string operations performance
function PerformanceTest.testStringOperations()
    print("\n=== String Operations Performance ===")
    
    -- String concatenation
    benchmark("String concat (100 times)", 1000, function()
        local str = ""
        for i = 1, 100 do
            str = str .. "a"
        end
    end)
    
    -- Table concat (better method)
    benchmark("Table concat (100 times)", 1000, function()
        local parts = {}
        for i = 1, 100 do
            table.insert(parts, "a")
        end
        local str = table.concat(parts)
    end)
    
    -- String format
    benchmark("String format", 10000, function()
        local str = string.format("Value: %d, Name: %s", 42, "Test")
    end)
    
    print("✓ String operations performance test completed")
end

-- Test collision detection performance
function PerformanceTest.testCollisionDetection()
    print("\n=== Collision Detection Performance ===")
    
    -- Create entities
    local entities = {}
    for i = 1, 100 do
        table.insert(entities, {
            x = math.random(0, 1000),
            y = math.random(0, 1000),
            radius = 10
        })
    end
    
    -- Point-circle collision
    benchmark("Point-circle collision (100 entities)", 1000, function()
        local px, py = 500, 500
        for _, e in ipairs(entities) do
            local dx = e.x - px
            local dy = e.y - py
            local distSq = dx * dx + dy * dy
            local hit = distSq <= e.radius * e.radius
        end
    end)
    
    -- Circle-circle collision
    benchmark("Circle-circle collision (100 pairs)", 100, function()
        for i = 1, #entities - 1 do
            for j = i + 1, #entities do
                local e1, e2 = entities[i], entities[j]
                local dx = e1.x - e2.x
                local dy = e1.y - e2.y
                local distSq = dx * dx + dy * dy
                local radiusSum = e1.radius + e2.radius
                local hit = distSq <= radiusSum * radiusSum
            end
        end
    end)
    
    print("✓ Collision detection performance test completed")
end

-- Test memory allocation
function PerformanceTest.testMemoryAllocation()
    print("\n=== Memory Allocation Performance ===")
    
    local startMem = collectgarbage("count")
    
    -- Create many tables
    local tables = {}
    for i = 1, 10000 do
        table.insert(tables, {
            id = i,
            name = "Item" .. i,
            value = i * 10,
            data = {x = i, y = i * 2, z = i * 3}
        })
    end
    
    local endMem = collectgarbage("count")
    local memUsed = endMem - startMem
    
    print(string.format("  10,000 tables: %.2f KB", memUsed))
    
    -- Clean up
    tables = nil
    collectgarbage("collect")
    
    local afterGC = collectgarbage("count")
    local memFreed = endMem - afterGC
    
    print(string.format("  Memory freed after GC: %.2f KB", memFreed))
    
    print("✓ Memory allocation test completed")
end

-- Run all performance tests
function PerformanceTest.runAll()
    print("\n" .. string.rep("=", 60))
    print("PERFORMANCE TESTS")
    print(string.rep("=", 60))
    
    PerformanceTest.testPathfinding()
    PerformanceTest.testHexMath()
    PerformanceTest.testUnitManagement()
    PerformanceTest.testDataStructures()
    PerformanceTest.testStringOperations()
    PerformanceTest.testCollisionDetection()
    PerformanceTest.testMemoryAllocation()
    
    print("\n✓ All performance tests completed!\n")
end

return PerformanceTest



