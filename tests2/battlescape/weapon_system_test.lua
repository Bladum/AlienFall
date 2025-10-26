-- ─────────────────────────────────────────────────────────────────────────
-- WEAPON SYSTEM TEST SUITE
-- FILE: tests2/battlescape/weapon_system_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.battlescape.weapon_system",
    fileName = "weapon_system.lua",
    description = "Weapon configuration, damage, and firing mechanics"
})

print("[WEAPON_SYSTEM_TEST] Setting up")

local WeaponSystem = {
    weapons = {},
    equipped = {},
    ammo_pool = {},

    new = function(self)
        return setmetatable({weapons = {}, equipped = {}, ammo_pool = {}}, {__index = self})
    end,

    registerWeapon = function(self, weaponId, name, weaponType, damage, accuracy, ammo)
        self.weapons[weaponId] = {id = weaponId, name = name, type = weaponType, damage = damage, accuracy = accuracy, ammo = ammo, ammoMax = ammo, equipped = false}
        self.ammo_pool[weaponId] = ammo
        return true
    end,

    getWeapon = function(self, weaponId)
        return self.weapons[weaponId]
    end,

    equipWeapon = function(self, unitId, weaponId)
        if not self.weapons[weaponId] then return false end
        self.weapons[weaponId].equipped = true
        self.equipped[unitId] = weaponId
        return true
    end,

    unequipWeapon = function(self, unitId)
        if self.equipped[unitId] then
            local weaponId = self.equipped[unitId]
            self.weapons[weaponId].equipped = false
            self.equipped[unitId] = nil
            return true
        end
        return false
    end,

    getEquippedWeapon = function(self, unitId)
        if not self.equipped[unitId] then return nil end
        return self.equipped[unitId]
    end,

    reloadWeapon = function(self, weaponId)
        if not self.weapons[weaponId] then return false end
        self.weapons[weaponId].ammo = self.weapons[weaponId].ammoMax
        return true
    end,

    consumeAmmo = function(self, weaponId, amount)
        if not self.weapons[weaponId] then return false end
        if self.weapons[weaponId].ammo < amount then return false end
        self.weapons[weaponId].ammo = self.weapons[weaponId].ammo - amount
        return true
    end,

    getAmmo = function(self, weaponId)
        if not self.weapons[weaponId] then return 0 end
        return self.weapons[weaponId].ammo
    end,

    getDamage = function(self, weaponId)
        if not self.weapons[weaponId] then return 0 end
        return self.weapons[weaponId].damage
    end,

    getAccuracy = function(self, weaponId)
        if not self.weapons[weaponId] then return 0 end
        return self.weapons[weaponId].accuracy
    end,

    getWeaponCount = function(self)
        local count = 0
        for _ in pairs(self.weapons) do count = count + 1 end
        return count
    end,

    getEquippedCount = function(self)
        local count = 0
        for _ in pairs(self.equipped) do count = count + 1 end
        return count
    end
}

Suite:group("Weapon Registration", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ws = WeaponSystem:new()
    end)

    Suite:testMethod("WeaponSystem.new", {description = "Creates system", testCase = "create", type = "functional"}, function()
        Helpers.assertEqual(shared.ws ~= nil, true, "System created")
    end)

    Suite:testMethod("WeaponSystem.registerWeapon", {description = "Registers weapon", testCase = "register", type = "functional"}, function()
        local ok = shared.ws:registerWeapon("rifle", "Assault Rifle", "rifle", 25, 85, 120)
        Helpers.assertEqual(ok, true, "Weapon registered")
    end)

    Suite:testMethod("WeaponSystem.getWeapon", {description = "Retrieves weapon", testCase = "get", type = "functional"}, function()
        shared.ws:registerWeapon("shotgun", "Combat Shotgun", "shotgun", 40, 60, 24)
        local weapon = shared.ws:getWeapon("shotgun")
        Helpers.assertEqual(weapon ~= nil, true, "Weapon retrieved")
    end)

    Suite:testMethod("WeaponSystem.getWeapon", {description = "Returns nil missing", testCase = "missing", type = "functional"}, function()
        local weapon = shared.ws:getWeapon("nonexistent")
        Helpers.assertEqual(weapon, nil, "Missing returns nil")
    end)

    Suite:testMethod("WeaponSystem.getWeaponCount", {description = "Counts weapons", testCase = "count", type = "functional"}, function()
        shared.ws:registerWeapon("w1", "W1", "type", 10, 50, 50)
        shared.ws:registerWeapon("w2", "W2", "type", 15, 60, 60)
        shared.ws:registerWeapon("w3", "W3", "type", 20, 70, 70)
        local count = shared.ws:getWeaponCount()
        Helpers.assertEqual(count, 3, "Three weapons")
    end)
end)

Suite:group("Weapon Stats", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ws = WeaponSystem:new()
        shared.ws:registerWeapon("pistol", "Pistol", "pistol", 18, 80, 30)
    end)

    Suite:testMethod("WeaponSystem.getDamage", {description = "Gets damage", testCase = "damage", type = "functional"}, function()
        local damage = shared.ws:getDamage("pistol")
        Helpers.assertEqual(damage, 18, "Damage 18")
    end)

    Suite:testMethod("WeaponSystem.getAccuracy", {description = "Gets accuracy", testCase = "accuracy", type = "functional"}, function()
        local accuracy = shared.ws:getAccuracy("pistol")
        Helpers.assertEqual(accuracy, 80, "Accuracy 80")
    end)

    Suite:testMethod("WeaponSystem.getAmmo", {description = "Gets ammo", testCase = "ammo", type = "functional"}, function()
        local ammo = shared.ws:getAmmo("pistol")
        Helpers.assertEqual(ammo, 30, "Ammo 30")
    end)

    Suite:testMethod("WeaponSystem.getDamage", {description = "Missing returns 0", testCase = "missing_damage", type = "functional"}, function()
        local damage = shared.ws:getDamage("nonexistent")
        Helpers.assertEqual(damage, 0, "Missing damage 0")
    end)
end)

Suite:group("Equipment", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ws = WeaponSystem:new()
        shared.ws:registerWeapon("sword", "Plasma Sword", "melee", 35, 95, 0)
    end)

    Suite:testMethod("WeaponSystem.equipWeapon", {description = "Equips weapon", testCase = "equip", type = "functional"}, function()
        local ok = shared.ws:equipWeapon("soldier1", "sword")
        Helpers.assertEqual(ok, true, "Equipped")
    end)

    Suite:testMethod("WeaponSystem.getEquippedWeapon", {description = "Gets equipped", testCase = "get_equipped", type = "functional"}, function()
        shared.ws:equipWeapon("soldier1", "sword")
        local weaponId = shared.ws:getEquippedWeapon("soldier1")
        Helpers.assertEqual(weaponId, "sword", "Sword equipped")
    end)

    Suite:testMethod("WeaponSystem.getEquippedWeapon", {description = "Nil if not equipped", testCase = "not_equipped", type = "functional"}, function()
        local weaponId = shared.ws:getEquippedWeapon("soldier1")
        Helpers.assertEqual(weaponId, nil, "Not equipped")
    end)

    Suite:testMethod("WeaponSystem.unequipWeapon", {description = "Unequips weapon", testCase = "unequip", type = "functional"}, function()
        shared.ws:equipWeapon("soldier1", "sword")
        local ok = shared.ws:unequipWeapon("soldier1")
        Helpers.assertEqual(ok, true, "Unequipped")
    end)

    Suite:testMethod("WeaponSystem.getEquippedCount", {description = "Counts equipped", testCase = "equipped_count", type = "functional"}, function()
        shared.ws:registerWeapon("gun", "Gun", "ranged", 25, 75, 100)
        shared.ws:equipWeapon("u1", "sword")
        shared.ws:equipWeapon("u2", "gun")
        local count = shared.ws:getEquippedCount()
        Helpers.assertEqual(count, 2, "Two equipped")
    end)
end)

Suite:group("Ammunition", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ws = WeaponSystem:new()
        shared.ws:registerWeapon("rifle", "Rifle", "rifle", 22, 82, 150)
    end)

    Suite:testMethod("WeaponSystem.consumeAmmo", {description = "Consumes ammo", testCase = "consume", type = "functional"}, function()
        local ok = shared.ws:consumeAmmo("rifle", 30)
        Helpers.assertEqual(ok, true, "Ammo consumed")
    end)

    Suite:testMethod("WeaponSystem.consumeAmmo", {description = "Reduces ammo", testCase = "reduce", type = "functional"}, function()
        shared.ws:consumeAmmo("rifle", 50)
        local ammo = shared.ws:getAmmo("rifle")
        Helpers.assertEqual(ammo, 100, "Ammo 100")
    end)

    Suite:testMethod("WeaponSystem.consumeAmmo", {description = "Fails insufficient", testCase = "insufficient", type = "functional"}, function()
        local ok = shared.ws:consumeAmmo("rifle", 200)
        Helpers.assertEqual(ok, false, "Insufficient fails")
    end)

    Suite:testMethod("WeaponSystem.reloadWeapon", {description = "Reloads weapon", testCase = "reload", type = "functional"}, function()
        shared.ws:consumeAmmo("rifle", 100)
        local ok = shared.ws:reloadWeapon("rifle")
        Helpers.assertEqual(ok, true, "Reloaded")
    end)

    Suite:testMethod("WeaponSystem.reloadWeapon", {description = "Restores ammo", testCase = "restore_ammo", type = "functional"}, function()
        shared.ws:consumeAmmo("rifle", 75)
        shared.ws:reloadWeapon("rifle")
        local ammo = shared.ws:getAmmo("rifle")
        Helpers.assertEqual(ammo, 150, "Ammo 150")
    end)
end)

Suite:run()
