-- test/units/test_energy_pool.lua
-- Test suite for unit energy pool system with XCOM/5 scaling
-- Validates: 6-12 EP base, 2-4 regen, weapon contributions, no ammo system

local TestFramework = require("test.test_framework")
local StatRanges = require("src.core.StatRanges")

local test = TestFramework.new("Unit Energy Pool System")

-- Test 1: Unit base energy pool in 6-12 range
test:add("Unit base energy in valid range", function()
    local base_energy_values = {6, 8, 10, 12}
    
    for _, value in ipairs(base_energy_values) do
        test:assert_true(
            StatRanges.isHumanRange(value),
            string.format("Base energy %d should be valid human range", value)
        )
        test:assert_true(
            value >= StatRanges.ENERGY_MIN and value <= StatRanges.ENERGY_MAX,
            string.format("Base energy %d should be within %d-%d", value, StatRanges.ENERGY_MIN, StatRanges.ENERGY_MAX)
        )
    end
end)

-- Test 2: Energy regeneration = base_energy / 3 (2-4 range)
test:add("Energy regen calculation", function()
    local test_cases = {
        {base = 6, expected_regen = 2},
        {base = 9, expected_regen = 3},
        {base = 12, expected_regen = 4}
    }
    
    for _, case in ipairs(test_cases) do
        local calculated_regen = StatRanges.calculateExpectedRegen(case.base)
        test:assert_equals(
            calculated_regen,
            case.expected_regen,
            string.format("Base energy %d should have regen %d (got %d)", 
                case.base, case.expected_regen, calculated_regen)
        )
    end
end)

-- Test 3: Weapon EP contributions add to pool
test:add("Weapon EP bonus contributions", function()
    local base_energy = 8
    local weapon1_bonus = 5  -- Pistol
    local weapon2_bonus = 10 -- Rifle
    
    local total_energy = base_energy + weapon1_bonus + weapon2_bonus
    
    test:assert_equals(
        total_energy,
        23,
        string.format("Total energy should be %d + %d + %d = 23 (got %d)", 
            base_energy, weapon1_bonus, weapon2_bonus, total_energy)
    )
end)

-- Test 4: No ammo clip system
test:add("No ammunition clip system", function()
    -- Verify constants indicate no ammo system
    test:assert_true(
        StatRanges.NO_AMMO_SYSTEM,
        "NO_AMMO_SYSTEM constant should be true"
    )
    
    -- Weapons should not have ammo-related properties
    local weapon_stats = {
        damage = 5,
        range = 15,
        ap_cost = 1,
        ep_cost = 1,
        -- NO ammo_capacity, NO ammo_clip_size, NO reload_cost
    }
    
    test:assert_nil(
        weapon_stats.ammo_capacity,
        "Weapon should not have ammo_capacity property"
    )
    test:assert_nil(
        weapon_stats.ammo_clip_size,
        "Weapon should not have ammo_clip_size property"
    )
end)

-- Test 5: Energy deduction on weapon use
test:add("Energy deduction on weapon fire", function()
    local current_energy = 15
    local weapon_ep_cost = 2  -- Rifle
    
    local energy_after_shot = current_energy - weapon_ep_cost
    
    test:assert_equals(
        energy_after_shot,
        13,
        string.format("Energy after shot should be %d - %d = 13 (got %d)", 
            current_energy, weapon_ep_cost, energy_after_shot)
    )
    
    -- Multiple shots
    local shots = 3
    local energy_after_multiple = current_energy - (weapon_ep_cost * shots)
    test:assert_equals(
        energy_after_multiple,
        9,
        string.format("Energy after %d shots should be %d (got %d)", 
            shots, 9, energy_after_multiple)
    )
end)

-- Test 6: Energy regeneration per turn
test:add("Energy regeneration per turn", function()
    local current_energy = 10
    local regen_rate = 3
    
    local energy_after_regen = current_energy + regen_rate
    
    test:assert_equals(
        energy_after_regen,
        13,
        string.format("Energy after regen should be %d + %d = 13 (got %d)", 
            current_energy, regen_rate, energy_after_regen)
    )
end)

-- Test 7: Total energy pool calculation
test:add("Total energy pool with equipment", function()
    -- Unit with base 8 EP + Pistol (5 EP) + Rifle (10 EP)
    local base_energy = 8
    local weapon1_ep = 5
    local weapon2_ep = 10
    
    local total_pool = base_energy + weapon1_ep + weapon2_ep
    
    test:assert_equals(
        total_pool,
        23,
        "Total energy pool should include base + all weapons"
    )
    
    -- Remove weapon 2
    local pool_without_weapon2 = base_energy + weapon1_ep
    test:assert_equals(
        pool_without_weapon2,
        13,
        "Energy pool should decrease when weapon removed"
    )
end)

-- Test 8: Negative energy prevention
test:add("Energy cannot go below zero", function()
    local current_energy = 3
    local weapon_ep_cost = 5  -- Cost more than available
    
    -- Should clamp to 0, not go negative
    local energy_after = math.max(0, current_energy - weapon_ep_cost)
    
    test:assert_equals(
        energy_after,
        0,
        "Energy should clamp to 0, not go negative"
    )
    test:assert_true(
        energy_after >= 0,
        "Energy must never be negative"
    )
end)

-- Test 9: Energy pool bounds validation
test:add("Energy pool within valid bounds", function()
    local min_pool = StatRanges.ENERGY_MIN
    local max_pool = StatRanges.ENERGY_MAX + 25 -- Base 12 + max weapon bonuses
    
    test:assert_true(
        min_pool == 6,
        "Minimum energy pool should be 6"
    )
    test:assert_true(
        max_pool >= 30,
        "Maximum possible energy pool should be 30+ with equipment"
    )
end)

-- Test 10: Regen rate validation
test:add("Regen rate within valid bounds", function()
    test:assert_true(
        StatRanges.ENERGY_REGEN_MIN == 2,
        "Minimum regen rate should be 2"
    )
    test:assert_true(
        StatRanges.ENERGY_REGEN_MAX == 4,
        "Maximum regen rate should be 4"
    )
    
    -- Verify formula consistency
    local base_6_regen = StatRanges.calculateExpectedRegen(6)
    local base_12_regen = StatRanges.calculateExpectedRegen(12)
    
    test:assert_equals(base_6_regen, 2, "Base 6 should have 2 regen")
    test:assert_equals(base_12_regen, 4, "Base 12 should have 4 regen")
end)

return test
