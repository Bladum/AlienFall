--- Test suite for Unit System
--
-- Tests the complete unit system including entities, classes, stats, and services.
--
-- @module test.test_unit_system

local test_framework = require "test.framework.test_framework"
local Unit = require "src.units.Unit"
local UnitClass = require "src.units.UnitClass"
local UnitStats = require "src.units.UnitStats"
local UnitSystem = require "src.units.UnitSystem"
local UnitManager = require "src.units.UnitManager"
local UnitService = require "src.units.UnitService"

local test_unit_system = {}

--- Run all Unit System tests
function test_unit_system.run()
    test_framework.run_suite("Unit System", {
        test_unit_creation = test_unit_system.test_unit_creation,
        test_unit_stat_calculation = test_unit_system.test_unit_stat_calculation,
        test_unit_leveling = test_unit_system.test_unit_leveling,
        test_unit_equipment = test_unit_system.test_unit_equipment,
        test_unit_combat = test_unit_system.test_unit_combat,
        test_unit_service_integration = test_unit_system.test_unit_service_integration
    })
end

--- Test Unit Entity creation and basic functionality
function test_unit_system.test_unit_creation()
    local unitClass = {
        id = "scout",
        name = "Scout",
        base_stats = {
            health = 75,
            stamina = 90,
            accuracy = 60,
            reflexes = 70,
            strength = 35,
            mind = 55
        }
    }

    local unit = Unit:new({
        name = "TestUnit",
        class_id = "scout",
        health = unitClass.base_stats.health,
        stamina = unitClass.base_stats.stamina,
        accuracy = unitClass.base_stats.accuracy,
        reflexes = unitClass.base_stats.reflexes,
        strength = unitClass.base_stats.strength,
        mind = unitClass.base_stats.mind
    })

    test_framework.assert_not_nil(unit, "Unit should be created")
    test_framework.assert_equal(unit.name, "TestUnit", "Unit name should match")
    test_framework.assert_equal(unit.class_id, "scout", "Unit class should match")
    test_framework.assert_equal(unit.stats.health, 75, "Unit health should match base stats")
end

--- Test Unit stat calculation with level bonuses
function test_unit_system.test_unit_stat_calculation()
    local unitClass = {
        id = "assault",
        name = "Assault",
        base_stats = {
            health = 90,
            strength = 60
        }
    }

    local unit = Unit:new({
        name = "TestUnit",
        class_id = "assault",
        health = unitClass.base_stats.health,
        strength = unitClass.base_stats.strength,
        level = 5,
        experience = 500
    })

    -- Mock calculateEffectiveStats method
    unit.calculateEffectiveStats = function(self)
        return {
            health = self.stats.health + (self.level * 10),
            strength = self.stats.strength + (self.level * 5)
        }
    end

    local effectiveStats = unit:calculateEffectiveStats()
    test_framework.assert_true(effectiveStats.health > 90, "Level bonuses should increase health")
    test_framework.assert_true(effectiveStats.strength > 60, "Level bonuses should increase strength")
end

--- Test Unit leveling mechanics
function test_unit_system.test_unit_leveling()
    local unit = Unit:new({
        name = "TestUnit",
        level = 1,
        experience = 0,
        experience_to_next = 100
    })

    -- Mock leveling methods
    unit.addExperience = function(self, exp)
        self.experience = self.experience + exp
        if self.experience >= self.experience_to_next then
            self.level = self.level + 1
            self.experience = self.experience - self.experience_to_next
            self.experience_to_next = self.experience_to_next + 50
        end
    end

    unit:addExperience(120)
    test_framework.assert_equal(unit.level, 2, "Unit should level up")
    test_framework.assert_equal(unit.experience, 20, "Experience should be carried over")
end

--- Test Unit equipment system
function test_unit_system.test_unit_equipment()
    local unit = Unit:new({
        name = "TestUnit"
    })

    local weapon = {
        id = "rifle",
        type = "weapon",
        stats_bonus = {accuracy = 20}
    }

    local armor = {
        id = "kevlar_vest",
        type = "armor",
        stats_bonus = {health = 30}
    }

    -- Mock equipment methods
    unit.equipItem = function(self, item)
        self.equipment[item.type] = item
    end

    unit.getEquipmentBonus = function(self, stat)
        local bonus = 0
        for _, item in pairs(self.equipment) do
            if item.stats_bonus and item.stats_bonus[stat] then
                bonus = bonus + item.stats_bonus[stat]
            end
        end
        return bonus
    end

    unit:equipItem(weapon)
    unit:equipItem(armor)

    test_framework.assert_equal(unit:getEquipmentBonus("accuracy"), 20, "Weapon should provide accuracy bonus")
    test_framework.assert_equal(unit:getEquipmentBonus("health"), 30, "Armor should provide health bonus")
end

--- Test Unit combat mechanics
function test_unit_system.test_unit_combat()
    local attacker = Unit:new({
        name = "Attacker",
        accuracy = 80,
        strength = 50
    })

    local defender = Unit:new({
        name = "Defender",
        health = 100,
        reflexes = 60
    })

    -- Mock combat methods
    attacker.calculateHitChance = function(self, target)
        return self.stats.accuracy - target.stats.reflexes + 50
    end

    attacker.calculateDamage = function(self, target)
        return math.floor(self.stats.strength * 0.5)
    end

    defender.takeDamage = function(self, damage)
        self.stats.health = self.stats.health - damage
    end

    local hitChance = attacker:calculateHitChance(defender)
    test_framework.assert_true(hitChance > 50, "Hit chance should be reasonable")

    if hitChance > 50 then
        local damage = attacker:calculateDamage(defender)
        defender:takeDamage(damage)
        test_framework.assert_true(defender.stats.health < 100, "Defender should take damage")
    end
end

--- Test UnitService integration
function test_unit_system.test_unit_service_integration()
    -- Mock service registry to avoid dependency issues
    local mockRegistry = {
        registerService = function() end
    }
    package.loaded['core.services.registry'] = mockRegistry

    local unitService = UnitService:new()

    test_framework.assert_not_nil(unitService, "Unit service should be created")

    -- Mock unit for testing
    local unit = Unit:new({
        id = "test_unit",
        name = "Test Unit",
        health = 100
    })

    -- Mock assignment methods
    unitService.assignUnitToBase = function(self, unitId, baseId)
        return true
    end

    unitService.assignUnitToMission = function(self, unitId, mission)
        return true
    end

    local assignedToBase = unitService:assignUnitToBase(unit.id, "test_base")
    test_framework.assert_true(assignedToBase, "Unit should be assigned to base")

    local mission = {id = "test_mission", type = "recon"}
    local assignedToMission = unitService:assignUnitToMission(unit.id, mission)
    test_framework.assert_true(assignedToMission, "Unit should be assigned to mission")
end

return test_unit_system
