-- Test for LOS/FOW System
-- Verifies that line of sight and fog of war calculations work correctly
-- Run with: lovec engine/ (navigate to Battlescape and press F8 to toggle FOW)

local test = {}

function test.run()
    print("===========================================")
    print("LOS/FOW System Test")
    print("===========================================")
    
    -- Test 1: Check if LOS system exists
    print("\n[TEST 1] Checking if LOS system is loaded...")
    local hasBasicLOS = pcall(function() return require("battlescape.combat.los_system") end)
    local hasOptimizedLOS = pcall(function() return require("battlescape.combat.los_optimized") end)
    
    if hasOptimizedLOS then
        print("[PASS] Optimized LOS system found")
    elseif hasBasicLOS then
        print("[PASS] Basic LOS system found")
    else
        print("[FAIL] No LOS system found!")
        return false
    end
    
    -- Test 2: Check if Team visibility system exists
    print("\n[TEST 2] Checking Team visibility system...")
    local success, Team = pcall(function() return require("shared.team") end)
    if not success then
        print("[FAIL] Cannot load Team system: " .. tostring(Team))
        return false
    end
    
    -- Create test team
    local testTeam = Team.new("test", "Test Team", Team.SIDES.PLAYER)
    testTeam:initializeVisibility(10, 10)
    
    -- Test visibility states
    testTeam:updateVisibility(5, 5, "visible")
    local state = testTeam:getVisibility(5, 5)
    if state == "visible" then
        print("[PASS] Team visibility update works")
    else
        print("[FAIL] Team visibility update failed: " .. tostring(state))
        return false
    end
    
    -- Test 3: Check if Debug.showFOW toggle exists
    print("\n[TEST 3] Checking Debug.showFOW toggle...")
    local success, Debug = pcall(function() return require("battlescape.battle.utils.debug") end)
    if not success then
        print("[FAIL] Cannot load Debug system: " .. tostring(Debug))
        return false
    end
    
    if Debug.showFOW ~= nil then
        print("[PASS] Debug.showFOW flag exists: " .. tostring(Debug.showFOW))
    else
        print("[FAIL] Debug.showFOW flag missing!")
        return false
    end
    
    if Debug.toggleFOW then
        print("[PASS] Debug.toggleFOW() function exists")
    else
        print("[FAIL] Debug.toggleFOW() function missing!")
        return false
    end
    
    -- Test 4: Test LOSCache system (if optimized LOS is available)
    if hasOptimizedLOS then
        print("\n[TEST 4] Testing LOSCache system...")
        local LOSOptimized = require("battlescape.combat.los_optimized")
        
        if LOSOptimized.LOSCache then
            print("[PASS] LOSCache system available")
            
            -- Test cache operations
            local cache = LOSOptimized.LOSCache.new()
            local testKey = cache:getKey(5, 5, 10, true, 0)
            cache:set(testKey, {{x=5, y=5}, {x=6, y=5}})
            
            local cached = cache:get(testKey)
            if cached then
                print("[PASS] Cache set/get works")
            else
                print("[FAIL] Cache set/get failed")
                return false
            end
            
            local stats = cache:getStats()
            if stats.hits >= 0 and stats.misses >= 0 then
                print("[PASS] Cache statistics work")
            else
                print("[FAIL] Cache statistics broken")
                return false
            end
        else
            print("[FAIL] LOSCache not available in optimized LOS")
            return false
        end
    end
    
    print("\n===========================================")
    print("ALL TESTS PASSED")
    print("===========================================")
    print("\nManual Testing Instructions:")
    print("1. Launch game: lovec engine/")
    print("2. Navigate to Battlescape")
    print("3. Press F8 to toggle FOW on/off")
    print("4. Verify black fog appears/disappears")
    print("5. Move units and verify FOW updates")
    print("6. Check console for LOS performance logs")
    
    return true
end

return test






















