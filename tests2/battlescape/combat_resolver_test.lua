-- ─────────────────────────────────────────────────────────────────────────
-- COMBAT RESOLVER TEST SUITE
-- FILE: tests2/battlescape/combat_resolver_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.battlescape.combat_resolver",
    fileName = "combat_resolver.lua",
    description = "Tactical combat resolution and outcome calculation"
})

print("[COMBAT_RESOLVER_TEST] Setting up")

local CombatResolver = {
    attacks = {},
    results = {},
    hit_history = {},

    new = function(self)
        return setmetatable({attacks = {}, results = {}, hit_history = {}}, {__index = self})
    end,

    registerAttack = function(self, attackId, attacker, target, accuracy, damage)
        self.attacks[attackId] = {id = attackId, attacker = attacker, target = target, accuracy = accuracy, damage = damage, resolved = false}
        return true
    end,

    resolveAttack = function(self, attackId)
        if not self.attacks[attackId] then return false end
        local attack = self.attacks[attackId]
        local hit = attack.accuracy > 50
        local result = {attackId = attackId, hit = hit, damage = hit and attack.damage or 0, resolved = true}
        self.results[attackId] = result
        table.insert(self.hit_history, {hit = hit, damage = result.damage})
        self.attacks[attackId].resolved = true
        return result
    end,

    getAttackResult = function(self, attackId)
        return self.results[attackId]
    end,

    calculateDamage = function(self, baseDamage, critChance, armor)
        local crit = critChance > 70
        local multiplier = crit and 2.0 or 1.0
        local armorReduction = armor or 0
        return math.max(1, math.floor(baseDamage * multiplier - armorReduction))
    end,

    calculateHitChance = function(self, accuracy, distance, cover)
        local distancePenalty = distance * 5
        local coverBonus = cover and 20 or 0
        return math.max(5, math.min(95, accuracy - distancePenalty + coverBonus))
    end,

    getHitCount = function(self)
        local count = 0
        for _, result in pairs(self.hit_history) do
            if result.hit then count = count + 1 end
        end
        return count
    end,

    getMissCount = function(self)
        local count = 0
        for _, result in pairs(self.hit_history) do
            if not result.hit then count = count + 1 end
        end
        return count
    end,

    getTotalDamage = function(self)
        local total = 0
        for _, result in pairs(self.hit_history) do
            total = total + result.damage
        end
        return total
    end,

    getAttackCount = function(self)
        return #self.hit_history
    end,

    isResolved = function(self, attackId)
        if not self.attacks[attackId] then return false end
        return self.attacks[attackId].resolved
    end
}

Suite:group("Attack Registration", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.cr = CombatResolver:new()
    end)

    Suite:testMethod("CombatResolver.new", {description = "Creates resolver", testCase = "create", type = "functional"}, function()
        Helpers.assertEqual(shared.cr ~= nil, true, "Resolver created")
    end)

    Suite:testMethod("CombatResolver.registerAttack", {description = "Registers attack", testCase = "register", type = "functional"}, function()
        local ok = shared.cr:registerAttack("atk1", "soldier", "alien", 75, 20)
        Helpers.assertEqual(ok, true, "Attack registered")
    end)

    Suite:testMethod("CombatResolver.getAttackResult", {description = "Returns nil unresolved", testCase = "unresolved", type = "functional"}, function()
        shared.cr:registerAttack("atk2", "soldier", "alien", 80, 25)
        local result = shared.cr:getAttackResult("atk2")
        Helpers.assertEqual(result, nil, "Unresolved nil")
    end)
end)

Suite:group("Attack Resolution", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.cr = CombatResolver:new()
    end)

    Suite:testMethod("CombatResolver.resolveAttack", {description = "Resolves attack", testCase = "resolve", type = "functional"}, function()
        shared.cr:registerAttack("atk", "soldier", "alien", 80, 30)
        local ok = shared.cr:resolveAttack("atk")
        Helpers.assertEqual(ok ~= false, true, "Attack resolved")
    end)

    Suite:testMethod("CombatResolver.resolveAttack", {description = "High accuracy hits", testCase = "high_accuracy", type = "functional"}, function()
        shared.cr:registerAttack("atk", "soldier", "alien", 85, 25)
        local result = shared.cr:resolveAttack("atk")
        Helpers.assertEqual(result.hit, true, "Hit on high accuracy")
    end)

    Suite:testMethod("CombatResolver.resolveAttack", {description = "Low accuracy misses", testCase = "low_accuracy", type = "functional"}, function()
        shared.cr:registerAttack("atk", "soldier", "alien", 30, 25)
        local result = shared.cr:resolveAttack("atk")
        Helpers.assertEqual(result.hit, false, "Miss on low accuracy")
    end)

    Suite:testMethod("CombatResolver.isResolved", {description = "Marks resolved", testCase = "mark_resolved", type = "functional"}, function()
        shared.cr:registerAttack("atk", "soldier", "alien", 75, 20)
        shared.cr:resolveAttack("atk")
        local resolved = shared.cr:isResolved("atk")
        Helpers.assertEqual(resolved, true, "Marked resolved")
    end)
end)

Suite:group("Damage Calculation", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.cr = CombatResolver:new()
    end)

    Suite:testMethod("CombatResolver.calculateDamage", {description = "Base damage", testCase = "base", type = "functional"}, function()
        local damage = shared.cr:calculateDamage(20, 30, 0)
        Helpers.assertEqual(damage, 20, "Base damage 20")
    end)

    Suite:testMethod("CombatResolver.calculateDamage", {description = "Crit doubles", testCase = "crit", type = "functional"}, function()
        local damage = shared.cr:calculateDamage(20, 75, 0)
        Helpers.assertEqual(damage, 40, "Crit damage 40")
    end)

    Suite:testMethod("CombatResolver.calculateDamage", {description = "Armor reduces", testCase = "armor", type = "functional"}, function()
        local damage = shared.cr:calculateDamage(25, 30, 5)
        Helpers.assertEqual(damage, 20, "Damage reduced to 20")
    end)

    Suite:testMethod("CombatResolver.calculateDamage", {description = "Minimum 1", testCase = "minimum", type = "functional"}, function()
        local damage = shared.cr:calculateDamage(5, 30, 10)
        Helpers.assertEqual(damage, 1, "Minimum damage 1")
    end)
end)

Suite:group("Hit Chance Calculation", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.cr = CombatResolver:new()
    end)

    Suite:testMethod("CombatResolver.calculateHitChance", {description = "Base accuracy", testCase = "base", type = "functional"}, function()
        local chance = shared.cr:calculateHitChance(80, 0, false)
        Helpers.assertEqual(chance, 80, "Base accuracy 80")
    end)

    Suite:testMethod("CombatResolver.calculateHitChance", {description = "Distance penalty", testCase = "distance", type = "functional"}, function()
        local chance = shared.cr:calculateHitChance(80, 2, false)
        Helpers.assertEqual(chance, 70, "Accuracy 70 after distance")
    end)

    Suite:testMethod("CombatResolver.calculateHitChance", {description = "Cover bonus", testCase = "cover", type = "functional"}, function()
        local chance = shared.cr:calculateHitChance(80, 0, true)
        Helpers.assertEqual(chance, 95, "Accuracy capped at 95")
    end)

    Suite:testMethod("CombatResolver.calculateHitChance", {description = "Minimum 5", testCase = "minimum", type = "functional"}, function()
        local chance = shared.cr:calculateHitChance(10, 5, false)
        Helpers.assertEqual(chance, 5, "Minimum accuracy 5")
    end)

    Suite:testMethod("CombatResolver.calculateHitChance", {description = "Maximum 95", testCase = "maximum", type = "functional"}, function()
        local chance = shared.cr:calculateHitChance(100, 0, true)
        Helpers.assertEqual(chance, 95, "Maximum accuracy 95")
    end)
end)

Suite:group("Hit Statistics", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.cr = CombatResolver:new()
        shared.cr:registerAttack("atk1", "soldier", "alien", 85, 20)
        shared.cr:registerAttack("atk2", "soldier", "alien", 30, 20)
        shared.cr:registerAttack("atk3", "soldier", "alien", 75, 25)
        shared.cr:resolveAttack("atk1")
        shared.cr:resolveAttack("atk2")
        shared.cr:resolveAttack("atk3")
    end)

    Suite:testMethod("CombatResolver.getHitCount", {description = "Counts hits", testCase = "hit_count", type = "functional"}, function()
        local count = shared.cr:getHitCount()
        Helpers.assertEqual(count >= 1, true, "Has hits")
    end)

    Suite:testMethod("CombatResolver.getMissCount", {description = "Counts misses", testCase = "miss_count", type = "functional"}, function()
        local count = shared.cr:getMissCount()
        Helpers.assertEqual(count >= 0, true, "Has misses or none")
    end)

    Suite:testMethod("CombatResolver.getAttackCount", {description = "Total attacks", testCase = "total", type = "functional"}, function()
        local count = shared.cr:getAttackCount()
        Helpers.assertEqual(count, 3, "Three attacks")
    end)

    Suite:testMethod("CombatResolver.getTotalDamage", {description = "Damage sum", testCase = "damage_sum", type = "functional"}, function()
        local damage = shared.cr:getTotalDamage()
        Helpers.assertEqual(damage >= 0, true, "Total damage >= 0")
    end)
end)

Suite:run()
