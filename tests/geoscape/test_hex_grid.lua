-- Test suite for HexGrid system
-- Run with: lovec engine (then select "Test Hex Grid" from menu)

-- Add engine path for requires
package.path = package.path .. ";../engine/?.lua;../engine/?/init.lua"

local HexGrid = require("geoscape.systems.hex_grid")

local TestHexGrid = {}

---Run all hex grid tests
function TestHexGrid.runAll()
    print("\n========== HEX GRID TESTS ==========")
    
    local passed = 0
    local failed = 0
    
    -- Test 1: Grid creation
    print("\n[TEST 1] Grid Creation")
    local grid = HexGrid.new(80, 40, 12)
    if grid and grid.width == 80 and grid.height == 40 then
        print("? PASS: Grid created with correct dimensions")
        passed = passed + 1
    else
        print("? FAIL: Grid creation failed")
        failed = failed + 1
    end
    
    -- Test 2: Axial to Cube conversion
    print("\n[TEST 2] Axial to Cube Conversion")
    local x, y, z = HexGrid.axialToCube(3, 4)
    if x == 3 and y == -7 and z == 4 and (x + y + z) == 0 then
        print("? PASS: Axial to cube conversion correct (3,4) › (3,-7,4)")
        passed = passed + 1
    else
        print(string.format("? FAIL: Expected (3,-7,4), got (%d,%d,%d)", x, y, z))
        failed = failed + 1
    end
    
    -- Test 3: Distance calculation
    print("\n[TEST 3] Distance Calculation")
    local dist = HexGrid.distance(0, 0, 3, 4)
    if dist == 7 then
        print("? PASS: Distance from (0,0) to (3,4) is 7")
        passed = passed + 1
    else
        print(string.format("? FAIL: Expected distance 7, got %d", dist))
        failed = failed + 1
    end
    
    -- Test 4: Neighbor finding
    print("\n[TEST 4] Neighbor Finding")
    local neighbors = HexGrid.neighbors(0, 0)
    if #neighbors == 6 then
        print("? PASS: Found 6 neighbors")
        passed = passed + 1
    else
        print(string.format("? FAIL: Expected 6 neighbors, got %d", #neighbors))
        failed = failed + 1
    end
    
    -- Test 5: Pixel conversion round-trip
    print("\n[TEST 5] Pixel Conversion Round-Trip")
    local px, py = grid:toPixel(5, 3)
    local q, r = grid:toHex(px, py)
    if q == 5 and r == 3 then
        print(string.format("? PASS: Round-trip (5,3) › (%.2f,%.2f) › (%d,%d)", px, py, q, r))
        passed = passed + 1
    else
        print(string.format("? FAIL: Round-trip failed: (%d,%d)", q, r))
        failed = failed + 1
    end
    
    -- Test 6: Ring generation
    print("\n[TEST 6] Ring Generation")
    local ring0 = HexGrid.ring(0, 0, 0)
    local ring1 = HexGrid.ring(0, 0, 1)
    local ring2 = HexGrid.ring(0, 0, 2)
    if #ring0 == 1 and #ring1 == 6 and #ring2 == 12 then
        print(string.format("? PASS: Ring sizes correct (0›%d, 1›%d, 2›%d)", #ring0, #ring1, #ring2))
        passed = passed + 1
    else
        print(string.format("? FAIL: Ring sizes wrong (0›%d, 1›%d, 2›%d)", #ring0, #ring1, #ring2))
        failed = failed + 1
    end
    
    -- Test 7: Area generation
    print("\n[TEST 7] Area Generation")
    local area0 = HexGrid.area(0, 0, 0)
    local area1 = HexGrid.area(0, 0, 1)
    local area2 = HexGrid.area(0, 0, 2)
    if #area0 == 1 and #area1 == 7 and #area2 == 19 then
        print(string.format("? PASS: Area sizes correct (0›%d, 1›%d, 2›%d)", #area0, #area1, #area2))
        passed = passed + 1
    else
        print(string.format("? FAIL: Area sizes wrong (0›%d, 1›%d, 2›%d)", #area0, #area1, #area2))
        failed = failed + 1
    end
    
    -- Test 8: Line drawing
    print("\n[TEST 8] Line Drawing")
    local line = HexGrid.line(0, 0, 3, 0)
    if #line == 4 then -- Distance is 3, so 4 hexes including start and end
        print(string.format("? PASS: Line has correct length (%d hexes)", #line))
        passed = passed + 1
    else
        print(string.format("? FAIL: Expected 4 hexes in line, got %d", #line))
        failed = failed + 1
    end
    
    -- Test 9: Bounds checking
    print("\n[TEST 9] Bounds Checking")
    local inBounds1 = grid:inBounds(0, 0)
    local inBounds2 = grid:inBounds(79, 39)
    local outBounds1 = grid:inBounds(-1, 0)
    local outBounds2 = grid:inBounds(80, 40)
    if inBounds1 and inBounds2 and not outBounds1 and not outBounds2 then
        print("? PASS: Bounds checking works correctly")
        passed = passed + 1
    else
        print(string.format("? FAIL: Bounds checking failed (%s,%s,%s,%s)", 
            tostring(inBounds1), tostring(inBounds2), tostring(outBounds1), tostring(outBounds2)))
        failed = failed + 1
    end
    
    -- Test 10: Corner calculation
    print("\n[TEST 10] Corner Calculation")
    local corners = grid:getCorners(0, 0)
    if #corners == 6 then
        print(string.format("? PASS: Generated 6 corners for hex"))
        passed = passed + 1
    else
        print(string.format("? FAIL: Expected 6 corners, got %d", #corners))
        failed = failed + 1
    end
    
    -- Summary
    print("\n========== TEST SUMMARY ==========")
    print(string.format("PASSED: %d", passed))
    print(string.format("FAILED: %d", failed))
    print(string.format("TOTAL:  %d", passed + failed))
    
    if failed == 0 then
        print("\n?? ALL TESTS PASSED!")
    else
        print(string.format("\n?? %d TEST(S) FAILED", failed))
    end
    print("==================================\n")
    
    return failed == 0
end

---Visual test - draw hex grid with mouse interaction
function TestHexGrid.visualTest()
    local grid = HexGrid.new(20, 10, 24)  -- Smaller grid for visual test
    local hoveredHex = nil
    
    return {
        grid = grid,
        
        update = function(self, dt)
            local mx, my = love.mouse.getPosition()
            -- Convert to world space (assuming camera at 0,0)
            local worldX = mx - 400
            local worldY = my - 300
            local q, r = self.grid:toHex(worldX, worldY)
            
            if self.grid:inBounds(q, r) then
                hoveredHex = {q = q, r = r}
            else
                hoveredHex = nil
            end
        end,
        
        draw = function(self)
            love.graphics.push()
            love.graphics.translate(400, 300)  -- Center on screen
            
            -- Draw all hexes
            for q = 0, self.grid.width - 1 do
                for r = 0, self.grid.height - 1 do
                    local corners = self.grid:getCorners(q, r)
                    
                    -- Check if this is the hovered hex
                    local isHovered = hoveredHex and hoveredHex.q == q and hoveredHex.r == r
                    
                    -- Set color
                    if isHovered then
                        love.graphics.setColor(1, 1, 0, 0.5)  -- Yellow for hovered
                    else
                        love.graphics.setColor(0.3, 0.3, 0.3, 0.3)  -- Gray for normal
                    end
                    
                    -- Draw filled hex
                    local vertices = {}
                    for _, corner in ipairs(corners) do
                        table.insert(vertices, corner.x)
                        table.insert(vertices, corner.y)
                    end
                    love.graphics.polygon("fill", vertices)
                    
                    -- Draw hex outline
                    love.graphics.setColor(0.5, 0.5, 0.5, 0.8)
                    love.graphics.polygon("line", vertices)
                end
            end
            
            love.graphics.pop()
            
            -- Draw info
            love.graphics.setColor(1, 1, 1)
            if hoveredHex then
                local px, py = self.grid:toPixel(hoveredHex.q, hoveredHex.r)
                love.graphics.print(string.format("Hex: (%d, %d)\nPixel: (%.1f, %.1f)", 
                    hoveredHex.q, hoveredHex.r, px, py), 10, 10)
            else
                love.graphics.print("Move mouse over hexes", 10, 10)
            end
        end
    }
end

return TestHexGrid






















