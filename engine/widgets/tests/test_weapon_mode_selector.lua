-- Test Weapon Mode Selector Widget

local WeaponModeSelector = require("widgets.combat.weapon_mode_selector")

local function test_creation()
    print("[TEST] Creating weapon mode selector...")
    local selector = WeaponModeSelector.new(24, 24, "rifle")
    
    assert(selector ~= nil, "Selector should be created")
    assert(selector.weaponId == "rifle", "Weapon ID should be set")
    assert(selector.selectedMode == "SNAP" or selector.selectedMode == "AIM", "Should have default mode")
    assert(#selector.availableModes > 0, "Should have available modes")
    
    print("[TEST] ✓ Creation successful")
    print("  - Available modes:", table.concat(selector.availableModes, ", "))
    print("  - Selected mode:", selector.selectedMode)
end

local function test_mode_availability()
    print("\n[TEST] Testing mode availability...")
    
    -- Assault rifle: versatile (SNAP, AIM, LONG, AUTO)
    local rifle = WeaponModeSelector.new(0, 0, "rifle")
    assert(rifle:isModeAvailable("SNAP"), "Rifle should have SNAP")
    assert(rifle:isModeAvailable("AIM"), "Rifle should have AIM")
    assert(rifle:isModeAvailable("AUTO"), "Rifle should have AUTO")
    print("  ✓ Rifle modes correct")
    
    -- Sniper rifle: precision only (AIM, LONG, FINESSE)
    local sniper = WeaponModeSelector.new(0, 0, "sniper_rifle")
    assert(sniper:isModeAvailable("AIM"), "Sniper should have AIM")
    assert(sniper:isModeAvailable("LONG"), "Sniper should have LONG")
    assert(sniper:isModeAvailable("FINESSE"), "Sniper should have FINESSE")
    assert(not sniper:isModeAvailable("AUTO"), "Sniper should NOT have AUTO")
    assert(not sniper:isModeAvailable("SNAP"), "Sniper should NOT have SNAP")
    print("  ✓ Sniper modes correct")
    
    -- Heavy cannon: power only (AIM, HEAVY)
    local cannon = WeaponModeSelector.new(0, 0, "heavy_cannon")
    assert(cannon:isModeAvailable("AIM"), "Cannon should have AIM")
    assert(cannon:isModeAvailable("HEAVY"), "Cannon should have HEAVY")
    assert(not cannon:isModeAvailable("SNAP"), "Cannon should NOT have SNAP")
    assert(not cannon:isModeAvailable("AUTO"), "Cannon should NOT have AUTO")
    print("  ✓ Cannon modes correct")
    
    print("[TEST] ✓ Mode availability working")
end

local function test_mode_selection()
    print("\n[TEST] Testing mode selection...")
    local selector = WeaponModeSelector.new(0, 0, "rifle")
    
    -- Select available mode
    selector:setSelectedMode("AUTO")
    assert(selector.selectedMode == "AUTO", "Should select AUTO")
    print("  ✓ Can select available mode")
    
    -- Try to select unavailable mode (should be ignored)
    selector:updateWeapon("sniper_rifle")  -- Sniper doesn't have AUTO
    selector:setSelectedMode("AUTO")
    assert(selector.selectedMode ~= "AUTO", "Should not select unavailable mode")
    print("  ✓ Cannot select unavailable mode")
    
    print("[TEST] ✓ Mode selection working")
end

local function test_mode_stats()
    print("\n[TEST] Testing mode stats...")
    local selector = WeaponModeSelector.new(0, 0, "rifle")
    
    local snapStats = selector:getModeStats("SNAP")
    assert(snapStats ~= nil, "Should get SNAP stats")
    assert(snapStats.apCost, "Should have AP cost")
    assert(snapStats.epCost, "Should have EP cost")
    assert(snapStats.accuracyMod, "Should have accuracy mod")
    print("  ✓ SNAP stats:", snapStats.apCost, snapStats.epCost, snapStats.accuracyMod)
    
    local autoStats = selector:getModeStats("AUTO")
    assert(autoStats ~= nil, "Should get AUTO stats")
    print("  ✓ AUTO stats:", autoStats.apCost, autoStats.epCost, autoStats.accuracyMod)
    
    print("[TEST] ✓ Mode stats working")
end

local function test_weapon_update()
    print("\n[TEST] Testing weapon update...")
    local selector = WeaponModeSelector.new(0, 0, "rifle")
    
    local oldMode = selector.selectedMode
    print("  - Initial weapon: rifle, mode:", oldMode)
    
    -- Switch to weapon with different available modes
    selector:updateWeapon("sniper_rifle")
    print("  - Updated weapon: sniper_rifle, mode:", selector.selectedMode)
    
    -- If old mode was unavailable, should have switched
    if not selector:isModeAvailable(oldMode) then
        assert(selector.selectedMode ~= oldMode, "Should switch from unavailable mode")
        print("  ✓ Switched to available mode")
    end
    
    print("[TEST] ✓ Weapon update working")
end

local function test_callback()
    print("\n[TEST] Testing mode selection callback...")
    local selector = WeaponModeSelector.new(0, 0, "rifle")
    
    local callbackCalled = false
    local callbackMode = nil
    
    selector.onModeSelect = function(mode)
        callbackCalled = true
        callbackMode = mode
    end
    
    selector:setSelectedMode("LONG")
    
    assert(callbackCalled, "Callback should be called")
    assert(callbackMode == "LONG", "Callback should receive correct mode")
    print("  ✓ Callback received mode:", callbackMode)
    
    print("[TEST] ✓ Callback working")
end

-- Run all tests
local function run_all_tests()
    print("===========================================")
    print("   WEAPON MODE SELECTOR WIDGET TESTS")
    print("===========================================\n")
    
    local success, err = pcall(test_creation)
    if not success then
        print("[ERROR] Creation test failed:", err)
        return false
    end
    
    success, err = pcall(test_mode_availability)
    if not success then
        print("[ERROR] Availability test failed:", err)
        return false
    end
    
    success, err = pcall(test_mode_selection)
    if not success then
        print("[ERROR] Selection test failed:", err)
        return false
    end
    
    success, err = pcall(test_mode_stats)
    if not success then
        print("[ERROR] Stats test failed:", err)
        return false
    end
    
    success, err = pcall(test_weapon_update)
    if not success then
        print("[ERROR] Update test failed:", err)
        return false
    end
    
    success, err = pcall(test_callback)
    if not success then
        print("[ERROR] Callback test failed:", err)
        return false
    end
    
    print("\n===========================================")
    print("   ALL TESTS PASSED! ✓")
    print("===========================================")
    
    return true
end

return {
    run = run_all_tests,
    test_creation = test_creation,
    test_mode_availability = test_mode_availability,
    test_mode_selection = test_mode_selection,
    test_mode_stats = test_mode_stats,
    test_weapon_update = test_weapon_update,
    test_callback = test_callback
}
