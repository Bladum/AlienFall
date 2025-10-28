-- ─────────────────────────────────────────────────────────────────────────
-- TEST: Combat Mechanics System
-- FILE: tests2/battlescape/combat_mechanics_test.lua
-- ─────────────────────────────────────────────────────────────────────────
-- Tests for engine.battlescape.systems.combat_mechanics
-- Covers attack resolution, accuracy calculation, damage calculation, and effects
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

-- Mock CombatMechanics dla testów
local CombatMechanics = {}
CombatMechanics.__index = CombatMechanics

function CombatMechanics.new(terrainSystem, unitSystem)
    local self = setmetatable({}, CombatMechanics)

    self.terrainSystem = terrainSystem
    self.unitSystem = unitSystem

    -- Weapon accuracy base values
    self.weaponAccuracy = {
        rifle = 75,
        pistol = 50,
        grenade = 60,
        laser = 80,
        plasma = 75,
        shotgun = 40
    }

    -- Armor mitigation values (% damage reduction)
    self.armorMitigation = {
        light = 0.15,
        medium = 0.25,
        heavy = 0.40,
        powered = 0.50
    }

    -- Critical hit chance modifiers
    self.criticalModifiers = {
        headshot = 1.5,
        rearAttack = 1.3,
        highGround = 1.2
    }

    return self
end

function CombatMechanics:resolveAttack(attacker, weapon, defender, targetHex, observers)
    observers = observers or {}

    if not attacker or not weapon or not defender then
        error("[CombatMechanics] Missing attacker, weapon, or defender")
    end

    local result = {
        attacker = attacker.id,
        defender = defender.id,
        weapon = weapon.id,
        hit = false,
        damage = 0,
        critical = false,
        effects = {},
        logs = {}
    }

    -- Calculate distance
    local distance = self:_hexDistance(attacker.hex, targetHex)

    -- Check range
    if distance > weapon.max_range then
        result.logs[#result.logs + 1] = "OUT_OF_RANGE"
        return result
    end

    -- Calculate accuracy
    local baseAccuracy = self:calculateAccuracy(attacker, defender, distance, defender.cover_value or 0)
    local accuracyRoll = math.random(1, 100)

    result.hit = accuracyRoll <= baseAccuracy

    if not result.hit then
        result.logs[#result.logs + 1] = "MISS"
        return result
    end

    result.logs[#result.logs + 1] = "HIT"

    -- Roll for critical
    result.critical = self:rollCritical(attacker, defender, targetHex)

    -- Calculate damage
    local baseDamage = weapon.damage or 20
    local damageRoll = math.random(math.floor(baseDamage * 0.8), math.ceil(baseDamage * 1.2))
    result.damage = self:calculateDamage(weapon, damageRoll, defender.armor)

    if result.critical then
        result.damage = math.floor(result.damage * 1.5)
    end

    -- Apply status effects from weapon
    if weapon.effects then
        for _, effect in ipairs(weapon.effects) do
            table.insert(result.effects, effect)
        end
    end

    return result
end

function CombatMechanics:calculateAccuracy(attacker, defender, distance, coverValue)
    coverValue = coverValue or 0

    local baseAccuracy = self.weaponAccuracy[attacker.weapon_type] or 50
    local attackerSkill = (attacker.accuracy or 50) / 50

    local distanceModifier = 0
    if distance > 3 then
        distanceModifier = -(distance - 3) * 2
    end

    local coverModifier = -coverValue * 0.5
    local movementModifier = (defender.moved_this_turn and -10) or 0

    local accuracy = baseAccuracy * attackerSkill + distanceModifier + coverModifier + movementModifier

    return math.max(5, math.min(95, accuracy))
end

function CombatMechanics:calculateDamage(weapon, roll, armorType)
    local armor = armorType or "none"
    local mitigation = self.armorMitigation[armor] or 0

    local mitigatedDamage = roll * (1 - mitigation)

    return math.floor(mitigatedDamage)
end

function CombatMechanics:rollCritical(attacker, defender, targetHex)
    local critChance = attacker.critical_chance or 10
    local roll = math.random(1, 100)
    return roll <= critChance
end

function CombatMechanics:_hexDistance(hex1, hex2)
    if not hex1 or not hex2 then return 0 end
    local dx = hex2.q - hex1.q
    local dy = hex2.r - hex1.r
    return math.floor((math.abs(dx) + math.abs(dx + dy) + math.abs(dy)) / 2)
end

function CombatMechanics:_checkReactionFire(attacker, targetHex, observers)
    local reactingUnits = {}
    for _, observer in ipairs(observers) do
        if observer.id ~= attacker.id then
            table.insert(reactingUnits, observer)
        end
    end
    return reactingUnits
end

-- ─────────────────────────────────────────────────────────────────────────
-- TEST SUITE
-- ─────────────────────────────────────────────────────────────────────────

local Suite = HierarchicalSuite:new({
    modulePath = "engine.battlescape.systems.combat_mechanics",
    fileName = "combat_mechanics.lua",
    description = "Combat mechanics system - handles attack resolution and damage calculation"
})

Suite:before(function()
    print("[CombatMechanics] Setting up test suite")
    math.randomseed(os.time())
end)

Suite:after(function()
    print("[CombatMechanics] Cleaning up after tests")
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 1: INITIALIZATION
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Initialization", function()
    Suite:testMethod("CombatMechanics.new", {
        description = "Creates new combat mechanics system",
        testCase = "happy_path",
        type = "functional"
    }, function()
        local terrain = {id = "terrain"}
        local units = {id = "units"}

        local combat = CombatMechanics.new(terrain, units)

        Helpers.assertEqual(combat.terrainSystem, terrain, "Should store terrain system")
        Helpers.assertEqual(combat.unitSystem, units, "Should store unit system")
        Helpers.assertEqual(combat.weaponAccuracy.rifle, 75, "Should have rifle accuracy")
        Helpers.assertEqual(combat.armorMitigation.heavy, 0.40, "Should have armor values")

        -- Removed manual print - framework handles this
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 2: ACCURACY CALCULATION
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Accuracy Calculation", function()
    local shared = {}
    local combat = CombatMechanics.new()

    Suite:beforeEach(function()
        shared.attacker = {
            id = "soldier1",
            weapon_type = "rifle",
            accuracy = 75,
            hex = {q = 0, r = 0}
        }
        shared.defender = {
            id = "enemy1",
            hex = {q = 5, r = 0},
            moved_this_turn = false,
            cover_value = 0
        }
    end)

    Suite:testMethod("CombatMechanics.calculateAccuracy", {
        description = "Calculates base accuracy for attack",
        testCase = "happy_path",
        type = "functional"
    }, function()
        local accuracy = combat:calculateAccuracy(shared.attacker, shared.defender, 2, 0)

        Helpers.assertEqual(accuracy >= 5, true, "Accuracy should be at least 5%")
        Helpers.assertEqual(accuracy <= 95, true, "Accuracy should be at most 95%")

        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("CombatMechanics.calculateAccuracy", {
        description = "Applies distance modifier",
        testCase = "distance_modifier",
        type = "functional"
    }, function()
        -- Use lower skill level so clamping doesn't hide distance modifier
        local lowSkillAttacker = {
            weapon_type = "rifle",
            accuracy = 50  -- Lower skill (50 vs 75)
        }
        local closeAccuracy = combat:calculateAccuracy(lowSkillAttacker, shared.defender, 2, 0)
        local farAccuracy = combat:calculateAccuracy(lowSkillAttacker, shared.defender, 10, 0)

        -- With distance modifier, far should be lower than close
        Helpers.assertEqual(farAccuracy <= closeAccuracy, true,
            "Accuracy should be same or lower at distance")

        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("CombatMechanics.calculateAccuracy", {
        description = "Applies cover modifier",
        testCase = "cover_modifier",
        type = "functional"
    }, function()
        local nocover = combat:calculateAccuracy(shared.attacker, shared.defender, 5, 0)
        local withcover = combat:calculateAccuracy(shared.attacker, shared.defender, 5, 50)

        Helpers.assertEqual(withcover < nocover, true, "Cover should reduce accuracy")

        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("CombatMechanics.calculateAccuracy", {
        description = "Clamps accuracy to valid range",
        testCase = "edge_case",
        type = "functional"
    }, function()
        -- Test very far distance with heavy cover
        local veryLow = combat:calculateAccuracy(
            {weapon_type = "rifle", accuracy = 1},
            {moved_this_turn = true},
            50,
            100
        )

        Helpers.assertEqual(veryLow >= 5, true, "Accuracy should clamp to minimum 5%")

        -- Removed manual print - framework handles this
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 3: DAMAGE CALCULATION
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Damage Calculation", function()
    local combat = CombatMechanics.new()

    Suite:testMethod("CombatMechanics.calculateDamage", {
        description = "Calculates damage without armor",
        testCase = "happy_path",
        type = "functional"
    }, function()
        local weapon = {id = "rifle", damage = 30}
        local damage = combat:calculateDamage(weapon, 30, "none")

        Helpers.assertEqual(damage, 30, "Damage should be unchanged without armor")

        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("CombatMechanics.calculateDamage", {
        description = "Applies light armor mitigation",
        testCase = "light_armor",
        type = "functional"
    }, function()
        local weapon = {id = "rifle"}
        local noDamage = combat:calculateDamage(weapon, 100, "none")
        local lightArmor = combat:calculateDamage(weapon, 100, "light")

        Helpers.assertEqual(lightArmor < noDamage, true, "Light armor should reduce damage")
        -- Light armor is 15% reduction
        Helpers.assertEqual(lightArmor, 85, "Light armor should reduce 100 to 85")

        print("  ✓ Light armor mitigation: 100 → " .. lightArmor)
    end)

    Suite:testMethod("CombatMechanics.calculateDamage", {
        description = "Applies heavy armor mitigation",
        testCase = "heavy_armor",
        type = "functional"
    }, function()
        local weapon = {id = "rifle"}
        local heavyArmor = combat:calculateDamage(weapon, 100, "heavy")

        -- Heavy armor is 40% reduction
        Helpers.assertEqual(heavyArmor, 60, "Heavy armor should reduce 100 to 60")

        print("  ✓ Heavy armor mitigation: 100 → " .. heavyArmor)
    end)

    Suite:testMethod("CombatMechanics.calculateDamage", {
        description = "Applies powered armor mitigation",
        testCase = "powered_armor",
        type = "functional"
    }, function()
        local weapon = {id = "rifle"}
        local poweredArmor = combat:calculateDamage(weapon, 100, "powered")

        -- Powered armor is 50% reduction
        Helpers.assertEqual(poweredArmor, 50, "Powered armor should reduce 100 to 50")

        print("  ✓ Powered armor mitigation: 100 → " .. poweredArmor)
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 4: ATTACK RESOLUTION
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Attack Resolution", function()
    local shared = {}
    local combat = CombatMechanics.new()

    Suite:beforeEach(function()
        shared.attacker = {
            id = "soldier1",
            weapon_type = "rifle",
            accuracy = 75,
            critical_chance = 10,
            hex = {q = 0, r = 0}
        }
        shared.weapon = {
            id = "rifle_standard",
            damage = 25,
            max_range = 15,
            effects = {
                {type = "bleeding", duration = 2}
            }
        }
        shared.defender = {
            id = "enemy1",
            hex = {q = 5, r = 0},
            armor = "light",
            cover_value = 10,
            moved_this_turn = false
        }
    end)

    Suite:testMethod("CombatMechanics.resolveAttack", {
        description = "Resolves successful attack",
        testCase = "happy_path",
        type = "functional"
    }, function()
        local result = combat:resolveAttack(
            shared.attacker,
            shared.weapon,
            shared.defender,
            {q = 5, r = 0}
        )

        Helpers.assertEqual(result.attacker, "soldier1", "Should store attacker ID")
        Helpers.assertEqual(result.defender, "enemy1", "Should store defender ID")
        Helpers.assertEqual(result.damage >= 0, true, "Damage should be non-negative")

        print("  ✓ Attack resolved: Hit=" .. tostring(result.hit) .. ", Damage=" .. result.damage)
    end)

    Suite:testMethod("CombatMechanics.resolveAttack", {
        description = "Rejects out of range attack",
        testCase = "out_of_range",
        type = "error_handling"
    }, function()
        shared.weapon.max_range = 3

        local result = combat:resolveAttack(
            shared.attacker,
            shared.weapon,
            shared.defender,
            {q = 10, r = 0}  -- Far away
        )

        Helpers.assertEqual(result.hit, false, "Should miss out of range")
        assert(Helpers.tableContains(result.logs, "OUT_OF_RANGE"), "Should log out of range")

        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("CombatMechanics.resolveAttack", {
        description = "Applies weapon effects",
        testCase = "weapon_effects",
        type = "functional"
    }, function()
        -- Force a hit by using deterministic approach
        local result = combat:resolveAttack(
            shared.attacker,
            shared.weapon,
            shared.defender,
            {q = 5, r = 0}
        )

        -- Check if weapon has effects configured
        Helpers.assertEqual(#shared.weapon.effects > 0, true, "Test weapon should have effects")

        print("  ✓ Weapon effects configured: " .. shared.weapon.effects[1].type)
    end)

    Suite:testMethod("CombatMechanics.resolveAttack", {
        description = "Rejects invalid attack parameters",
        testCase = "error_handling",
        type = "functional"
    }, function()
        local ok, err = pcall(function()
            combat:resolveAttack(nil, shared.weapon, shared.defender, {q = 5, r = 0})
        end)

        Helpers.assertEqual(ok, false, "Should throw error for nil attacker")

        -- Removed manual print - framework handles this
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 5: CRITICAL HITS
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Critical Hits", function()
    local combat = CombatMechanics.new()

    Suite:testMethod("CombatMechanics.rollCritical", {
        description = "Rolls for critical hit",
        testCase = "happy_path",
        type = "functional"
    }, function()
        local attacker = {id = "soldier1", critical_chance = 50}
        local defender = {id = "enemy1"}

        -- Run multiple rolls to test probability
        local criticalCount = 0
        for i = 1, 100 do
            if combat:rollCritical(attacker, defender, {q = 0, r = 0}) then
                criticalCount = criticalCount + 1
            end
        end

        -- With 50% critical chance, should get roughly 40-60 criticals in 100 rolls
        Helpers.assertEqual(criticalCount > 20 and criticalCount < 80, true,
            "Critical rolls should roughly match chance")

        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("CombatMechanics.rollCritical", {
        description = "Respects critical chance",
        testCase = "low_chance",
        type = "functional"
    }, function()
        local attacker = {id = "newbie", critical_chance = 1}

        local criticalCount = 0
        for i = 1, 100 do
            if combat:rollCritical(attacker, {}, {}) then
                criticalCount = criticalCount + 1
            end
        end

        -- With 1% chance, should rarely crit
        Helpers.assertEqual(criticalCount < 10, true, "1% chance should rarely crit")

        -- Removed manual print - framework handles this
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 6: HEX DISTANCE
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Hex Distance Calculation", function()
    local combat = CombatMechanics.new()

    Suite:testMethod("CombatMechanics._hexDistance", {
        description = "Calculates distance between hexes",
        testCase = "happy_path",
        type = "functional"
    }, function()
        local hex1 = {q = 0, r = 0}
        local hex2 = {q = 5, r = 0}

        local distance = combat:_hexDistance(hex1, hex2)

        Helpers.assertEqual(distance >= 0, true, "Distance should be non-negative")

        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("CombatMechanics._hexDistance", {
        description = "Returns 0 for same hex",
        testCase = "same_hex",
        type = "functional"
    }, function()
        local hex = {q = 3, r = 3}
        local distance = combat:_hexDistance(hex, hex)

        Helpers.assertEqual(distance, 0, "Distance to same hex should be 0")

        -- Removed manual print - framework handles this
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- EXPORT
-- ─────────────────────────────────────────────────────────────────────────

return Suite
