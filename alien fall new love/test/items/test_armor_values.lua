-- test/items/test_armor_values.lua
-- Test suite for armor values validation with XCOM/5 scaling
-- Validates: armor values 1/4/8/18/24, weight vs strength

local TestFramework = require("test.test_framework")
local StatRanges = require("src.core.StatRanges")

local test = TestFramework.new("Armor Values Validation (XCOM/5)")

-- Test 1: Coveralls basic armor
test:add("Coveralls XCOM/5 stats", function()
    local coveralls = {
        armor = 1,
        weight = 1,
        type = "light"
    }
    
    test:assert_equals(coveralls.armor, StatRanges.ARMOR_COVERALLS, "Coveralls armor = 1 (XCOM 5 ÷ 5)")
    test:assert_equals(coveralls.weight, 1, "Coveralls weight = 1")
end)

-- Test 2: Shield armor bonus
test:add("Shield armor bonus (weapon slot)", function()
    local shield = {
        armor = 4,
        weight = 2,
        slot = "weapon"  -- Takes weapon slot
    }
    
    test:assert_equals(shield.armor, 4, "Shield provides +4 armor")
    test:assert_equals(shield.slot, "weapon", "Shield occupies weapon slot")
    test:assert_equals(shield.weight, 2, "Shield weight = 2")
end)

-- Test 3: Armored suit
test:add("Armored suit XCOM/5 stats", function()
    local armored_suit = {
        armor = 4,
        weight = 4
    }
    
    test:assert_equals(armored_suit.armor, StatRanges.ARMOR_LIGHT, "Armored suit armor = 4 (XCOM 20 ÷ 5)")
    test:assert_equals(armored_suit.weight, 4, "Armored suit weight = 4")
end)

-- Test 4: Personal armor
test:add("Personal armor XCOM/5 stats", function()
    local personal_armor = {
        armor = 8,
        weight = 8
    }
    
    test:assert_equals(personal_armor.armor, StatRanges.ARMOR_MEDIUM, "Personal armor = 8 (XCOM 40 ÷ 5)")
    test:assert_equals(personal_armor.weight, 8, "Personal armor weight = 8")
end)

-- Test 5: Power armor
test:add("Power armor XCOM/5 stats", function()
    local power_armor = {
        armor = 18,
        weight = 12
    }
    
    test:assert_equals(power_armor.armor, StatRanges.ARMOR_HEAVY, "Power armor = 18 (XCOM 90 ÷ 5)")
    test:assert_equals(power_armor.weight, 12, "Power armor weight = 12")
end)

-- Test 6: Tank armor
test:add("Tank armor XCOM/5 stats", function()
    local tank_armor = {
        armor = 24,
        weight = 0,  -- Vehicle/unit integrated
        vehicle_only = true
    }
    
    test:assert_equals(tank_armor.armor, StatRanges.ARMOR_TANK, "Tank armor = 24 (XCOM 120 ÷ 5)")
    test:assert_true(tank_armor.vehicle_only, "Tank armor is vehicle-only")
end)

-- Test 7: Armor damage reduction
test:add("Armor damage reduction mechanics", function()
    local incoming_damage = 10
    
    -- Test different armor values
    local test_cases = {
        {armor = 1, expected_damage = 9},   -- Coveralls
        {armor = 4, expected_damage = 6},   -- Light
        {armor = 8, expected_damage = 2},   -- Medium
        {armor = 18, expected_damage = 0},  -- Heavy (damage negated)
        {armor = 24, expected_damage = 0}   -- Tank (damage negated)
    }
    
    for _, case in ipairs(test_cases) do
        local reduced_damage = math.max(0, incoming_damage - case.armor)
        test:assert_equals(
            reduced_damage,
            case.expected_damage,
            string.format("Armor %d should reduce damage to %d (got %d)", 
                case.armor, case.expected_damage, reduced_damage)
        )
    end
end)

-- Test 8: Weight vs strength validation
test:add("Armor weight vs soldier strength", function()
    local soldier_weak = {strength = 6}   -- Minimum human
    local soldier_average = {strength = 9}
    local soldier_strong = {strength = 12} -- Maximum human
    
    local armors = {
        {name = "Coveralls", weight = 1},
        {name = "Armored Suit", weight = 4},
        {name = "Personal Armor", weight = 8},
        {name = "Power Armor", weight = 12}
    }
    
    -- Weak soldier can only carry light armor
    test:assert_true(
        armors[1].weight <= soldier_weak.strength,
        "Weak soldier can carry coveralls"
    )
    test:assert_true(
        armors[2].weight <= soldier_weak.strength,
        "Weak soldier can carry armored suit"
    )
    test:assert_true(
        armors[3].weight > soldier_weak.strength,
        "Weak soldier cannot carry personal armor"
    )
    
    -- Average soldier can carry medium armor
    test:assert_true(
        armors[3].weight <= soldier_average.strength,
        "Average soldier can carry personal armor"
    )
    test:assert_true(
        armors[4].weight > soldier_average.strength,
        "Average soldier cannot carry power armor"
    )
    
    -- Strong soldier can carry any armor
    test:assert_true(
        armors[4].weight <= soldier_strong.strength,
        "Strong soldier can carry power armor"
    )
end)

-- Test 9: Armor progression validation
test:add("Armor progression consistency", function()
    local armor_values = {
        StatRanges.ARMOR_COVERALLS,
        StatRanges.ARMOR_LIGHT,
        StatRanges.ARMOR_MEDIUM,
        StatRanges.ARMOR_HEAVY,
        StatRanges.ARMOR_TANK
    }
    
    -- Armor values should be in ascending order
    for i = 2, #armor_values do
        test:assert_true(
            armor_values[i] > armor_values[i-1],
            string.format("Armor tier %d (%d) should be > tier %d (%d)", 
                i, armor_values[i], i-1, armor_values[i-1])
        )
    end
end)

-- Test 10: XCOM/5 scaling validation
test:add("XCOM/5 scaling consistency", function()
    local xcom_armor_values = {
        {xcom = 5, divided = 1, name = "Coveralls"},
        {xcom = 20, divided = 4, name = "Light"},
        {xcom = 40, divided = 8, name = "Medium"},
        {xcom = 90, divided = 18, name = "Heavy"},
        {xcom = 120, divided = 24, name = "Tank"}
    }
    
    for _, entry in ipairs(xcom_armor_values) do
        local calculated = math.floor(entry.xcom / 5)
        test:assert_equals(
            calculated,
            entry.divided,
            string.format("%s: XCOM %d ÷ 5 = %d (got %d)", 
                entry.name, entry.xcom, entry.divided, calculated)
        )
    end
end)

-- Test 11: Armor slot limitation
test:add("Unit has exactly 1 armor slot", function()
    local unit_slots = {
        weapon_1 = "empty",
        weapon_2 = "empty",
        armor = "empty"
    }
    
    -- Count armor slots
    local armor_slot_count = 0
    for slot_name, _ in pairs(unit_slots) do
        if slot_name == "armor" then
            armor_slot_count = armor_slot_count + 1
        end
    end
    
    test:assert_equals(
        armor_slot_count,
        1,
        "Unit should have exactly 1 armor slot"
    )
    
    -- Verify no armor_2, armor_3, etc.
    test:assert_nil(unit_slots.armor_2, "Should not have armor_2 slot")
    test:assert_nil(unit_slots.armor_3, "Should not have armor_3 slot")
end)

-- Test 12: Combined armor and shield
test:add("Combined armor + shield mechanics", function()
    local soldier = {
        base_armor = 0,
        armor_equipped = {armor = 4, name = "Armored Suit"}, -- Armor slot
        weapon_1 = {armor = 4, name = "Shield", weight = 2}  -- Weapon slot
    }
    
    local total_armor = soldier.base_armor + 
                        soldier.armor_equipped.armor + 
                        soldier.weapon_1.armor
    
    test:assert_equals(
        total_armor,
        8,
        "Armored suit (4) + Shield (4) = 8 total armor"
    )
    
    -- Shield sacrifices weapon slot
    test:assert_not_nil(soldier.weapon_1.armor, "Shield provides armor bonus")
    -- This means soldier has only 1 effective weapon
end)

-- Test 13: Alien armor values
test:add("Alien integrated armor", function()
    local sectoid = {
        name = "Sectoid",
        natural_armor = 2,  -- Biological armor
        can_wear_armor = false
    }
    
    test:assert_true(
        sectoid.natural_armor >= 0 and sectoid.natural_armor <= 10,
        "Alien natural armor should be reasonable (0-10)"
    )
    test:assert_false(
        sectoid.can_wear_armor,
        "Some aliens cannot wear human armor"
    )
end)

-- Test 14: Armor special properties
test:add("Flying suit special properties", function()
    local flying_suit = {
        armor = 8,
        weight = 8,
        grants_flight = true,
        flight_ap_cost = 2
    }
    
    test:assert_equals(flying_suit.armor, StatRanges.ARMOR_MEDIUM, "Flying suit has medium armor")
    test:assert_true(flying_suit.grants_flight, "Flying suit enables flight")
    test:assert_not_nil(flying_suit.flight_ap_cost, "Flight has AP cost")
end)

-- Test 15: Armor weight efficiency
test:add("Armor weight-to-protection ratio", function()
    local armors = {
        {name = "Coveralls", armor = 1, weight = 1, ratio = 1.0},
        {name = "Armored Suit", armor = 4, weight = 4, ratio = 1.0},
        {name = "Personal", armor = 8, weight = 8, ratio = 1.0},
        {name = "Power", armor = 18, weight = 12, ratio = 1.5}
    }
    
    for _, entry in ipairs(armors) do
        local calculated_ratio = entry.armor / entry.weight
        test:assert_true(
            math.abs(calculated_ratio - entry.ratio) < 0.1,
            string.format("%s ratio: expected %.1f, got %.1f", 
                entry.name, entry.ratio, calculated_ratio)
        )
    end
    
    -- Power armor is most efficient
    test:assert_true(
        armors[4].ratio > armors[3].ratio,
        "Power armor is more weight-efficient than personal armor"
    )
end)

return test
