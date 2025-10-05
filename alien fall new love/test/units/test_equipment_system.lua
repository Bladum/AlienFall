--- Test suite for Equipment System
-- Tests equipment calculator and Unit equipment integration
--
-- @module test.units.test_equipment_system

local test_framework = require "test.framework.test_framework"
local EquipmentCalculator = require "units.equipment_calculator"
local Unit = require "units.Unit"

local TestEquipmentSystem = {}

--- Run all equipment system tests
function TestEquipmentSystem.run()
    test_framework.run_suite("Equipment System", {
        test_calculate_modifiers = TestEquipmentSystem.test_calculate_modifiers,
        test_apply_to_stats = TestEquipmentSystem.test_apply_to_stats,
        test_calculate_weight = TestEquipmentSystem.test_calculate_weight,
        test_validate_equipment = TestEquipmentSystem.test_validate_equipment,
        test_unit_equip_item = TestEquipmentSystem.test_unit_equip_item,
        test_unit_unequip_item = TestEquipmentSystem.test_unit_unequip_item,
        test_unit_effective_stats = TestEquipmentSystem.test_unit_effective_stats,
        test_equipment_summary = TestEquipmentSystem.test_equipment_summary,
        test_mixed_modifiers = TestEquipmentSystem.test_mixed_modifiers,
        test_multiplicative_stacking = TestEquipmentSystem.test_multiplicative_stacking
    })
end

-- Test: Calculate modifiers from equipment
function TestEquipmentSystem.test_calculate_modifiers()
    local equipment = {
        primary = {
            id = "rifle",
            stats = {accuracy = 10, damage = 30}
        },
        armor = {
            id = "vest",
            bonuses = {armor = 20},
            penalties = {speed = 5}
        }
    }
    
    local modifiers = EquipmentCalculator.calculateModifiers(equipment)
    
    -- Check additive modifiers
    assert(modifiers.accuracy and modifiers.accuracy.additive == 10, "Should calculate accuracy bonus")
    assert(modifiers.damage and modifiers.damage.additive == 30, "Should calculate damage bonus")
    assert(modifiers.armor and modifiers.armor.additive == 20, "Should calculate armor bonus")
    assert(modifiers.speed and modifiers.speed.additive == -5, "Should calculate speed penalty")
    
    return true
end

-- Test: Apply modifiers to base stats
function TestEquipmentSystem.test_apply_to_stats()
    local baseStats = {
        health = 100,
        accuracy = 50,
        speed = 10
    }
    
    local modifiers = {
        accuracy = {additive = 10, multiplicative = 1.0},
        speed = {additive = -2, multiplicative = 1.0}
    }
    
    local effectiveStats = EquipmentCalculator.applyToStats(baseStats, modifiers)
    
    assert(effectiveStats.health == 100, "Unmodified stats should remain unchanged")
    assert(effectiveStats.accuracy == 60, "Should apply additive modifier")
    assert(effectiveStats.speed == 8, "Should apply penalty")
    
    return true
end

-- Test: Calculate equipment weight
function TestEquipmentSystem.test_calculate_weight()
    local equipment = {
        primary = {id = "rifle", weight = 5},
        armor = {id = "vest", weight = 10},
        secondary = {id = "pistol", weight = 2}
    }
    
    local totalWeight = EquipmentCalculator.calculateWeight(equipment)
    
    assert(totalWeight == 17, "Should sum all equipment weights")
    
    return true
end

-- Test: Validate equipment restrictions
function TestEquipmentSystem.test_validate_equipment()
    local equipment = {
        primary = {
            id = "rifle",
            slot = "primary",
            weapon_category = "rifle"
        }
    }
    
    -- Should pass with no restrictions
    local valid, err = EquipmentCalculator.validateEquipment(equipment, "assault", {})
    assert(valid == true, "Should validate equipment with no restrictions")
    
    -- Should pass with allowed weapon
    valid, err = EquipmentCalculator.validateEquipment(equipment, "assault", {
        allowed_weapons = {"rifle", "shotgun"}
    })
    assert(valid == true, "Should validate allowed weapon type")
    
    -- Should fail with forbidden weapon
    valid, err = EquipmentCalculator.validateEquipment(equipment, "sniper", {
        allowed_weapons = {"sniper_rifle"}
    })
    assert(valid == false, "Should reject forbidden weapon type")
    
    return true
end

-- Test: Unit equip item
function TestEquipmentSystem.test_unit_equip_item()
    local unit = Unit:new({
        name = "Test Soldier",
        accuracy = 50
    })
    
    local weapon = {
        id = "rifle",
        weight = 5,
        stats = {accuracy = 10}
    }
    
    unit:equipItem("primary", weapon)
    
    assert(unit.equipment.primary == weapon, "Should equip item")
    assert(unit.encumbrance == 5, "Should update encumbrance")
    
    -- Check effective stats
    local effectiveStats = unit:getEffectiveStats()
    assert(effectiveStats.accuracy == 60, "Should apply weapon accuracy bonus")
    
    return true
end

-- Test: Unit unequip item
function TestEquipmentSystem.test_unit_unequip_item()
    local unit = Unit:new({
        name = "Test Soldier",
        accuracy = 50
    })
    
    local weapon = {
        id = "rifle",
        weight = 5,
        stats = {accuracy = 10}
    }
    
    unit:equipItem("primary", weapon)
    local unequipped = unit:unequipItem("primary")
    
    assert(unequipped == weapon, "Should return unequipped item")
    assert(unit.equipment.primary == nil, "Should remove item from slot")
    assert(unit.encumbrance == 0, "Should update encumbrance")
    
    -- Check effective stats reset
    local effectiveStats = unit:getEffectiveStats()
    assert(effectiveStats.accuracy == 50, "Should revert to base stats")
    
    return true
end

-- Test: Unit effective stats calculation
function TestEquipmentSystem.test_unit_effective_stats()
    local unit = Unit:new({
        name = "Test Soldier",
        health = 100,
        accuracy = 50,
        speed = 10
    })
    
    -- Equip items with various modifiers
    unit:equipItem("primary", {
        id = "rifle",
        weight = 5,
        stats = {accuracy = 15}
    })
    
    unit:equipItem("armor", {
        id = "heavy_armor",
        weight = 15,
        bonuses = {armor = 30},
        penalties = {speed = 3}
    })
    
    local effectiveStats = unit:getEffectiveStats()
    
    assert(effectiveStats.accuracy == 65, "Should apply weapon bonus")
    assert(effectiveStats.speed == 7, "Should apply armor penalty")
    assert(effectiveStats.armor == 30, "Should apply armor bonus")
    assert(unit.encumbrance == 20, "Should track total weight")
    
    return true
end

-- Test: Equipment summary
function TestEquipmentSystem.test_equipment_summary()
    local unit = Unit:new({
        name = "Test Soldier"
    })
    
    unit:equipItem("primary", {
        id = "rifle",
        weight = 5,
        stats = {accuracy = 10, damage = 30}
    })
    
    unit:equipItem("armor", {
        id = "vest",
        weight = 10,
        bonuses = {armor = 20},
        penalties = {speed = 5}
    })
    
    local summary = unit:getEquipmentSummary()
    
    assert(summary.totalWeight == 15, "Should calculate total weight")
    assert(summary.totalBonuses > 0, "Should track total bonuses")
    assert(summary.totalPenalties > 0, "Should track total penalties")
    assert(summary.modifiers, "Should include modifier details")
    
    return true
end

-- Test: Mixed additive modifiers
function TestEquipmentSystem.test_mixed_modifiers()
    local equipment = {
        primary = {
            id = "rifle",
            stats = {accuracy = 10}
        },
        secondary = {
            id = "scope",
            bonuses = {accuracy = 5}
        },
        utility = {
            id = "stabilizer",
            stats = {accuracy = 3}
        }
    }
    
    local modifiers = EquipmentCalculator.calculateModifiers(equipment)
    
    -- All accuracy bonuses should stack additively
    assert(modifiers.accuracy.additive == 18, "Should stack multiple accuracy bonuses")
    
    return true
end

-- Test: Multiplicative modifier stacking
function TestEquipmentSystem.test_multiplicative_stacking()
    local baseStats = {
        damage = 100
    }
    
    local modifiers = {
        damage = {
            additive = 20,
            multiplicative = 1.5  -- 50% bonus
        }
    }
    
    local effectiveStats = EquipmentCalculator.applyToStats(baseStats, modifiers)
    
    -- Should apply additive first: 100 + 20 = 120
    -- Then multiplicative: 120 * 1.5 = 180
    assert(effectiveStats.damage == 180, "Should apply additive then multiplicative")
    
    return true
end

return TestEquipmentSystem
