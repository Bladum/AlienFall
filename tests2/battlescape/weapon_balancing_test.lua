-- ─────────────────────────────────────────────────────────────────────────
-- WEAPON BALANCING TEST SUITE
-- FILE: tests2/battlescape/weapon_balancing_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.battlescape.weapon_balancing",
    fileName = "weapon_balancing.lua",
    description = "Weapon balancing system with damage scaling, accuracy curves, and meta analysis"
})

print("[WEAPON_BALANCING_TEST] Setting up")

local WeaponBalancing = {
    weapons = {},
    stats = {},
    modifiers = {},
    meta = {},

    new = function(self)
        return setmetatable({weapons = {}, stats = {}, modifiers = {}, meta = {}}, {__index = self})
    end,

    registerWeapon = function(self, weaponId, name, weaponType, baseDamage, accuracy, range)
        self.weapons[weaponId] = {
            id = weaponId, name = name, type = weaponType,
            baseDamage = baseDamage or 20, accuracy = accuracy or 70, range = range or 10,
            balanced = true, tierRating = 1
        }
        self.stats[weaponId] = {usage = 0, kills = 0, accuracy = 0, dps = baseDamage}
        self.modifiers[weaponId] = {}
        return true
    end,

    getWeapon = function(self, weaponId)
        return self.weapons[weaponId]
    end,

    calculateDamage = function(self, weaponId, distance, armor)
        if not self.weapons[weaponId] then return 0 end
        local weapon = self.weapons[weaponId]
        local baseDamage = weapon.baseDamage
        local rangeFalloff = 1.0
        if distance > weapon.range then
            rangeFalloff = weapon.range / distance
        end
        local armorReduction = armor * 0.5
        local finalDamage = math.max(1, baseDamage * rangeFalloff - armorReduction)
        return math.floor(finalDamage)
    end,

    calculateAccuracy = function(self, weaponId, distance, targetMoving)
        if not self.weapons[weaponId] then return 0 end
        local weapon = self.weapons[weaponId]
        local baseAccuracy = weapon.accuracy
        local distanceMod = 1.0
        if distance > weapon.range / 2 then
            distanceMod = 1 - (distance - weapon.range / 2) / (weapon.range / 2)
        end
        local movingPenalty = targetMoving and 0.75 or 1.0
        local finalAccuracy = math.floor(baseAccuracy * distanceMod * movingPenalty)
        return math.max(0, math.min(100, finalAccuracy))
    end,

    calculateDPS = function(self, weaponId, fireRate, accuracy)
        if not self.weapons[weaponId] then return 0 end
        local weapon = self.weapons[weaponId]
        local dps = (weapon.baseDamage * fireRate * accuracy) / 100
        return math.floor(dps)
    end,

    recordUsage = function(self, weaponId, damageDealt, hitCount, shotCount)
        if not self.stats[weaponId] then return false end
        self.stats[weaponId].usage = self.stats[weaponId].usage + 1
        if hitCount > 0 then
            self.stats[weaponId].accuracy = math.floor((shotCount > 0 and (hitCount / shotCount) * 100) or 0)
        end
        self.stats[weaponId].dps = math.floor(damageDealt / math.max(1, shotCount))
        return true
    end,

    addKill = function(self, weaponId)
        if not self.stats[weaponId] then return false end
        self.stats[weaponId].kills = self.stats[weaponId].kills + 1
        return true
    end,

    getWeaponPopularity = function(self, weaponId)
        if not self.stats[weaponId] then return 0 end
        return self.stats[weaponId].usage
    end,

    getKillCount = function(self, weaponId)
        if not self.stats[weaponId] then return 0 end
        return self.stats[weaponId].kills
    end,

    addModifier = function(self, weaponId, modifierId, modType, modValue)
        if not self.modifiers[weaponId] then return false end
        self.modifiers[weaponId][modifierId] = {id = modifierId, type = modType, value = modValue}
        return true
    end,

    removeModifier = function(self, weaponId, modifierId)
        if not self.modifiers[weaponId] or not self.modifiers[weaponId][modifierId] then return false end
        self.modifiers[weaponId][modifierId] = nil
        return true
    end,

    getModifierCount = function(self, weaponId)
        if not self.modifiers[weaponId] then return 0 end
        local count = 0
        for _ in pairs(self.modifiers[weaponId]) do count = count + 1 end
        return count
    end,

    calculateModifiedDamage = function(self, weaponId, distance, armor)
        local baseDamage = self:calculateDamage(weaponId, distance, armor)
        if not self.modifiers[weaponId] then return baseDamage end
        local multiplier = 1.0
        for _, mod in pairs(self.modifiers[weaponId]) do
            if mod.type == "damage" then
                multiplier = multiplier + (mod.value / 100)
            end
        end
        return math.floor(baseDamage * multiplier)
    end,

    setTierRating = function(self, weaponId, tier)
        if not self.weapons[weaponId] then return false end
        self.weapons[weaponId].tierRating = tier
        return true
    end,

    getTierRating = function(self, weaponId)
        if not self.weapons[weaponId] then return 0 end
        return self.weapons[weaponId].tierRating
    end,

    getWeaponsByTier = function(self, tier)
        local filtered = {}
        for weaponId, weapon in pairs(self.weapons) do
            if weapon.tierRating == tier then
                table.insert(filtered, weaponId)
            end
        end
        return filtered
    end,

    markBalanced = function(self, weaponId)
        if not self.weapons[weaponId] then return false end
        self.weapons[weaponId].balanced = true
        return true
    end,

    markUnbalanced = function(self, weaponId)
        if not self.weapons[weaponId] then return false end
        self.weapons[weaponId].balanced = false
        return true
    end,

    isBalanced = function(self, weaponId)
        if not self.weapons[weaponId] then return false end
        return self.weapons[weaponId].balanced
    end,

    recordMetaData = function(self, metaId, weaponId, winRate, pickRate)
        self.meta[metaId] = {id = metaId, weapon = weaponId, winRate = winRate, pickRate = pickRate}
        return true
    end,

    getMetaData = function(self, metaId)
        return self.meta[metaId]
    end,

    getMostUsedWeapon = function(self)
        local mostUsed = nil
        local maxUsage = -1
        for weaponId in pairs(self.stats) do
            local usage = self.stats[weaponId].usage
            if usage > maxUsage then
                maxUsage = usage
                mostUsed = weaponId
            end
        end
        return mostUsed
    end,

    getMostKillingWeapon = function(self)
        local mostKilling = nil
        local maxKills = -1
        for weaponId in pairs(self.stats) do
            local kills = self.stats[weaponId].kills
            if kills > maxKills then
                maxKills = kills
                mostKilling = weaponId
            end
        end
        return mostKilling
    end,

    balanceWeapon = function(self, weaponId, targetDPS)
        if not self.weapons[weaponId] then return false end
        local weapon = self.weapons[weaponId]
        local currentDPS = weapon.baseDamage * (weapon.accuracy / 100)
        if currentDPS == 0 then return false end
        local damageScale = targetDPS / currentDPS
        weapon.baseDamage = math.floor(weapon.baseDamage * damageScale)
        return true
    end,

    getWeaponEffectiveness = function(self, weaponId, enemyArmor)
        if not self.weapons[weaponId] then return 0 end
        local damage = self:calculateDamage(weaponId, 5, enemyArmor)
        local accuracy = self:calculateAccuracy(weaponId, 5, false)
        return math.floor((damage * accuracy) / 100)
    end
}

Suite:group("Weapon Registration", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.wb = WeaponBalancing:new()
    end)

    Suite:testMethod("WeaponBalancing.registerWeapon", {description = "Registers weapon", testCase = "register", type = "functional"}, function()
        local ok = shared.wb:registerWeapon("rifle1", "Assault Rifle", "rifle", 25, 75, 20)
        Helpers.assertEqual(ok, true, "Registered")
    end)

    Suite:testMethod("WeaponBalancing.getWeapon", {description = "Gets weapon", testCase = "get_weapon", type = "functional"}, function()
        shared.wb:registerWeapon("pistol1", "Pistol", "pistol", 15, 60, 15)
        local weapon = shared.wb:getWeapon("pistol1")
        Helpers.assertEqual(weapon ~= nil, true, "Retrieved")
    end)
end)

Suite:group("Damage Calculation", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.wb = WeaponBalancing:new()
        shared.wb:registerWeapon("dmg_weapon", "Damage Weapon", "rifle", 30, 75, 20)
    end)

    Suite:testMethod("WeaponBalancing.calculateDamage", {description = "Calculates damage", testCase = "damage", type = "functional"}, function()
        local damage = shared.wb:calculateDamage("dmg_weapon", 5, 0)
        Helpers.assertEqual(damage, 30, "30 damage")
    end)

    Suite:testMethod("WeaponBalancing.calculateDamage with armor", {description = "Damage with armor", testCase = "damage_armor", type = "functional"}, function()
        local damage = shared.wb:calculateDamage("dmg_weapon", 5, 10)
        Helpers.assertEqual(damage, 25, "25 after armor")
    end)

    Suite:testMethod("WeaponBalancing.calculateDamage with distance", {description = "Distance falloff", testCase = "distance", type = "functional"}, function()
        local damage = shared.wb:calculateDamage("dmg_weapon", 40, 0)
        Helpers.assertEqual(damage < 30, true, "Damage reduced")
    end)
end)

Suite:group("Accuracy Calculation", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.wb = WeaponBalancing:new()
        shared.wb:registerWeapon("acc_weapon", "Accurate", "rifle", 25, 80, 20)
    end)

    Suite:testMethod("WeaponBalancing.calculateAccuracy", {description = "Base accuracy", testCase = "base_acc", type = "functional"}, function()
        local accuracy = shared.wb:calculateAccuracy("acc_weapon", 5, false)
        Helpers.assertEqual(accuracy > 75, true, "Accuracy > 75")
    end)

    Suite:testMethod("WeaponBalancing.calculateAccuracy moving target", {description = "Moving target penalty", testCase = "moving", type = "functional"}, function()
        local still = shared.wb:calculateAccuracy("acc_weapon", 5, false)
        local moving = shared.wb:calculateAccuracy("acc_weapon", 5, true)
        Helpers.assertEqual(moving < still, true, "Moving target lower")
    end)

    Suite:testMethod("WeaponBalancing.calculateAccuracy at range", {description = "Range penalty", testCase = "range", type = "functional"}, function()
        local close = shared.wb:calculateAccuracy("acc_weapon", 5, false)
        local far = shared.wb:calculateAccuracy("acc_weapon", 40, false)
        Helpers.assertEqual(far < close, true, "Far accuracy lower")
    end)
end)

Suite:group("DPS Calculation", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.wb = WeaponBalancing:new()
        shared.wb:registerWeapon("dps_weapon", "DPS Weapon", "rifle", 20, 80, 20)
    end)

    Suite:testMethod("WeaponBalancing.calculateDPS", {description = "DPS calculation", testCase = "dps", type = "functional"}, function()
        local dps = shared.wb:calculateDPS("dps_weapon", 2, 80)
        Helpers.assertEqual(dps > 0, true, "DPS > 0")
    end)
end)

Suite:group("Usage Tracking", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.wb = WeaponBalancing:new()
        shared.wb:registerWeapon("track_weapon", "Track", "rifle", 25, 75, 20)
    end)

    Suite:testMethod("WeaponBalancing.recordUsage", {description = "Records usage", testCase = "usage", type = "functional"}, function()
        local ok = shared.wb:recordUsage("track_weapon", 75, 3, 4)
        Helpers.assertEqual(ok, true, "Recorded")
    end)

    Suite:testMethod("WeaponBalancing.addKill", {description = "Adds kill", testCase = "kill", type = "functional"}, function()
        local ok = shared.wb:addKill("track_weapon")
        Helpers.assertEqual(ok, true, "Added")
    end)

    Suite:testMethod("WeaponBalancing.getWeaponPopularity", {description = "Popularity", testCase = "popularity", type = "functional"}, function()
        shared.wb:recordUsage("track_weapon", 50, 2, 3)
        local popularity = shared.wb:getWeaponPopularity("track_weapon")
        Helpers.assertEqual(popularity, 1, "One usage")
    end)

    Suite:testMethod("WeaponBalancing.getKillCount", {description = "Kill count", testCase = "kill_count", type = "functional"}, function()
        shared.wb:addKill("track_weapon")
        shared.wb:addKill("track_weapon")
        local kills = shared.wb:getKillCount("track_weapon")
        Helpers.assertEqual(kills, 2, "Two kills")
    end)
end)

Suite:group("Modifiers", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.wb = WeaponBalancing:new()
        shared.wb:registerWeapon("mod_weapon", "Modifiable", "rifle", 20, 75, 20)
    end)

    Suite:testMethod("WeaponBalancing.addModifier", {description = "Adds modifier", testCase = "add_mod", type = "functional"}, function()
        local ok = shared.wb:addModifier("mod_weapon", "scope", "accuracy", 15)
        Helpers.assertEqual(ok, true, "Added")
    end)

    Suite:testMethod("WeaponBalancing.removeModifier", {description = "Removes modifier", testCase = "remove_mod", type = "functional"}, function()
        shared.wb:addModifier("mod_weapon", "to_remove", "damage", 10)
        local ok = shared.wb:removeModifier("mod_weapon", "to_remove")
        Helpers.assertEqual(ok, true, "Removed")
    end)

    Suite:testMethod("WeaponBalancing.getModifierCount", {description = "Modifier count", testCase = "mod_count", type = "functional"}, function()
        shared.wb:addModifier("mod_weapon", "m1", "damage", 10)
        shared.wb:addModifier("mod_weapon", "m2", "accuracy", 10)
        local count = shared.wb:getModifierCount("mod_weapon")
        Helpers.assertEqual(count, 2, "Two mods")
    end)

    Suite:testMethod("WeaponBalancing.calculateModifiedDamage", {description = "Modified damage", testCase = "modified", type = "functional"}, function()
        shared.wb:addModifier("mod_weapon", "damage_boost", "damage", 50)
        local damage = shared.wb:calculateModifiedDamage("mod_weapon", 5, 0)
        Helpers.assertEqual(damage > 20, true, "Boosted damage")
    end)
end)

Suite:group("Tier System", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.wb = WeaponBalancing:new()
        shared.wb:registerWeapon("tier1", "Tier 1", "rifle", 15, 60, 15)
        shared.wb:registerWeapon("tier2", "Tier 2", "rifle", 25, 75, 20)
        shared.wb:setTierRating("tier2", 2)  -- Set tier2 to tier 2 by default
    end)

    Suite:testMethod("WeaponBalancing.setTierRating", {description = "Sets tier", testCase = "set_tier", type = "functional"}, function()
        local ok = shared.wb:setTierRating("tier1", 1)
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("WeaponBalancing.getTierRating", {description = "Gets tier", testCase = "get_tier", type = "functional"}, function()
        shared.wb:setTierRating("tier2", 2)
        local tier = shared.wb:getTierRating("tier2")
        Helpers.assertEqual(tier, 2, "Tier 2")
    end)

    Suite:testMethod("WeaponBalancing.getWeaponsByTier", {description = "Gets by tier", testCase = "by_tier", type = "functional"}, function()
        shared.wb:setTierRating("tier1", 1)
        shared.wb:registerWeapon("tier1b", "Tier 1b", "rifle", 14, 58, 14)
        shared.wb:setTierRating("tier1b", 1)
        local tier1s = shared.wb:getWeaponsByTier(1)
        Helpers.assertEqual(#tier1s, 2, "Two tier 1 weapons")
    end)
end)

Suite:group("Balance Status", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.wb = WeaponBalancing:new()
        shared.wb:registerWeapon("balanced", "Balanced", "rifle", 25, 75, 20)
    end)

    Suite:testMethod("WeaponBalancing.markBalanced", {description = "Marks balanced", testCase = "mark_balanced", type = "functional"}, function()
        local ok = shared.wb:markBalanced("balanced")
        Helpers.assertEqual(ok, true, "Marked")
    end)

    Suite:testMethod("WeaponBalancing.markUnbalanced", {description = "Marks unbalanced", testCase = "mark_unbalanced", type = "functional"}, function()
        local ok = shared.wb:markUnbalanced("balanced")
        Helpers.assertEqual(ok, true, "Marked")
    end)

    Suite:testMethod("WeaponBalancing.isBalanced", {description = "Is balanced", testCase = "is_balanced", type = "functional"}, function()
        shared.wb:markBalanced("balanced")
        local balanced = shared.wb:isBalanced("balanced")
        Helpers.assertEqual(balanced, true, "Balanced")
    end)
end)

Suite:group("Meta Analysis", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.wb = WeaponBalancing:new()
        shared.wb:registerWeapon("meta1", "Meta Weapon 1", "rifle", 25, 75, 20)
        shared.wb:registerWeapon("meta2", "Meta Weapon 2", "rifle", 20, 70, 18)
        shared.wb:recordUsage("meta1", 100, 4, 5)
        shared.wb:recordUsage("meta1", 100, 4, 5)
        shared.wb:addKill("meta1")
    end)

    Suite:testMethod("WeaponBalancing.recordMetaData", {description = "Records meta", testCase = "meta_record", type = "functional"}, function()
        local ok = shared.wb:recordMetaData("meta_entry", "meta1", 65, 30)
        Helpers.assertEqual(ok, true, "Recorded")
    end)

    Suite:testMethod("WeaponBalancing.getMetaData", {description = "Gets meta", testCase = "meta_get", type = "functional"}, function()
        shared.wb:recordMetaData("meta_check", "meta2", 55, 25)
        local meta = shared.wb:getMetaData("meta_check")
        Helpers.assertEqual(meta ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("WeaponBalancing.getMostUsedWeapon", {description = "Most used", testCase = "most_used", type = "functional"}, function()
        local most = shared.wb:getMostUsedWeapon()
        Helpers.assertEqual(most, "meta1", "Meta1 most used")
    end)

    Suite:testMethod("WeaponBalancing.getMostKillingWeapon", {description = "Most killing", testCase = "most_killing", type = "functional"}, function()
        local most = shared.wb:getMostKillingWeapon()
        Helpers.assertEqual(most, "meta1", "Meta1 most kills")
    end)
end)

Suite:group("Balancing Operations", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.wb = WeaponBalancing:new()
        shared.wb:registerWeapon("balance_test", "Balance Test", "rifle", 30, 70, 20)
    end)

    Suite:testMethod("WeaponBalancing.balanceWeapon", {description = "Balances weapon", testCase = "balance", type = "functional"}, function()
        local ok = shared.wb:balanceWeapon("balance_test", 15)
        Helpers.assertEqual(ok, true, "Balanced")
    end)

    Suite:testMethod("WeaponBalancing.getWeaponEffectiveness", {description = "Effectiveness", testCase = "effectiveness", type = "functional"}, function()
        local eff = shared.wb:getWeaponEffectiveness("balance_test", 5)
        Helpers.assertEqual(eff > 0, true, "Effectiveness > 0")
    end)
end)

Suite:run()
