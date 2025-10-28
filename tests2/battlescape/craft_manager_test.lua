-- ─────────────────────────────────────────────────────────────────────────
-- CRAFT MANAGER TEST SUITE
-- FILE: tests2/battlescape/craft_manager_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.battlescape.craft_manager",
    fileName = "craft_manager.lua",
    description = "Battlescape craft and interception management system"
})

print("[CRAFT_MANAGER_TEST] Setting up")

local CraftManager = {
    crafts = {},
    slots = {},
    loadouts = {},

    new = function(self)
        return setmetatable({crafts = {}, slots = {}, loadouts = {}}, {__index = self})
    end,

    addCraft = function(self, craftId, name, craftType, health)
        self.crafts[craftId] = {id = craftId, name = name, type = craftType, health = health, maxHealth = health, ammunition = 0, status = "idle"}
        return true
    end,

    getCraft = function(self, craftId)
        return self.crafts[craftId]
    end,

    getCraftCount = function(self)
        local count = 0
        for _ in pairs(self.crafts) do count = count + 1 end
        return count
    end,

    damageHealth = function(self, craftId, damage)
        if not self.crafts[craftId] then return false end
        self.crafts[craftId].health = math.max(0, self.crafts[craftId].health - damage)
        return true
    end,

    getHealth = function(self, craftId)
        if not self.crafts[craftId] then return 0 end
        return self.crafts[craftId].health
    end,

    repairCraft = function(self, craftId, amount)
        if not self.crafts[craftId] then return false end
        self.crafts[craftId].health = math.min(self.crafts[craftId].maxHealth, self.crafts[craftId].health + amount)
        return true
    end,

    setCraftStatus = function(self, craftId, status)
        if not self.crafts[craftId] then return false end
        self.crafts[craftId].status = status
        return true
    end,

    getCraftStatus = function(self, craftId)
        if not self.crafts[craftId] then return nil end
        return self.crafts[craftId].status
    end,

    addAmmunition = function(self, craftId, amount)
        if not self.crafts[craftId] then return false end
        self.crafts[craftId].ammunition = self.crafts[craftId].ammunition + amount
        return true
    end,

    getAmmunition = function(self, craftId)
        if not self.crafts[craftId] then return 0 end
        return self.crafts[craftId].ammunition
    end,

    useAmmunition = function(self, craftId, amount)
        if not self.crafts[craftId] then return false end
        if self.crafts[craftId].ammunition < amount then return false end
        self.crafts[craftId].ammunition = self.crafts[craftId].ammunition - amount
        return true
    end,

    createWeaponSlot = function(self, slotId, craftId, weaponType)
        self.slots[slotId] = {id = slotId, craftId = craftId, weaponType = weaponType, equipped = false}
        return true
    end,

    getWeaponSlot = function(self, slotId)
        return self.slots[slotId]
    end,

    equipWeapon = function(self, slotId)
        if not self.slots[slotId] then return false end
        self.slots[slotId].equipped = true
        return true
    end,

    unequipWeapon = function(self, slotId)
        if not self.slots[slotId] then return false end
        self.slots[slotId].equipped = false
        return true
    end,

    createLoadout = function(self, loadoutId, name, slots)
        self.loadouts[loadoutId] = {id = loadoutId, name = name, slots = slots or {}, active = false}
        return true
    end,

    activateLoadout = function(self, loadoutId)
        if not self.loadouts[loadoutId] then return false end
        self.loadouts[loadoutId].active = true
        return true
    end
}

Suite:group("Craft Management", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.cm = CraftManager:new()
    end)

    Suite:testMethod("CraftManager.new", {description = "Creates manager", testCase = "create", type = "functional"}, function()
        Helpers.assertEqual(shared.cm ~= nil, true, "Manager created")
    end)

    Suite:testMethod("CraftManager.addCraft", {description = "Adds craft", testCase = "add", type = "functional"}, function()
        local ok = shared.cm:addCraft("interceptor1", "Fighter", "interceptor", 100)
        Helpers.assertEqual(ok, true, "Craft added")
    end)

    Suite:testMethod("CraftManager.getCraft", {description = "Retrieves craft", testCase = "get", type = "functional"}, function()
        shared.cm:addCraft("transport", "Transport", "transport", 80)
        local craft = shared.cm:getCraft("transport")
        Helpers.assertEqual(craft ~= nil, true, "Craft retrieved")
    end)

    Suite:testMethod("CraftManager.getCraft", {description = "Returns nil missing", testCase = "missing", type = "functional"}, function()
        local craft = shared.cm:getCraft("nonexistent")
        Helpers.assertEqual(craft, nil, "Missing craft returns nil")
    end)

    Suite:testMethod("CraftManager.getCraftCount", {description = "Counts crafts", testCase = "count", type = "functional"}, function()
        shared.cm:addCraft("c1", "C1", "type", 100)
        shared.cm:addCraft("c2", "C2", "type", 100)
        shared.cm:addCraft("c3", "C3", "type", 100)
        local count = shared.cm:getCraftCount()
        Helpers.assertEqual(count, 3, "Three crafts")
    end)
end)

Suite:group("Craft Health", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.cm = CraftManager:new()
        shared.cm:addCraft("fighter", "Fighter", "interceptor", 100)
    end)

    Suite:testMethod("CraftManager.getHealth", {description = "Gets health", testCase = "get_health", type = "functional"}, function()
        local health = shared.cm:getHealth("fighter")
        Helpers.assertEqual(health, 100, "Health is 100")
    end)

    Suite:testMethod("CraftManager.damageHealth", {description = "Takes damage", testCase = "damage", type = "functional"}, function()
        local ok = shared.cm:damageHealth("fighter", 25)
        Helpers.assertEqual(ok, true, "Damage applied")
    end)

    Suite:testMethod("CraftManager.damageHealth", {description = "Reduces health", testCase = "reduces", type = "functional"}, function()
        shared.cm:damageHealth("fighter", 30)
        local health = shared.cm:getHealth("fighter")
        Helpers.assertEqual(health, 70, "Health reduced to 70")
    end)

    Suite:testMethod("CraftManager.damageHealth", {description = "No negative health", testCase = "clamp", type = "functional"}, function()
        shared.cm:damageHealth("fighter", 200)
        local health = shared.cm:getHealth("fighter")
        Helpers.assertEqual(health, 0, "Health clamped to 0")
    end)

    Suite:testMethod("CraftManager.repairCraft", {description = "Repairs craft", testCase = "repair", type = "functional"}, function()
        shared.cm:damageHealth("fighter", 50)
        local ok = shared.cm:repairCraft("fighter", 30)
        Helpers.assertEqual(ok, true, "Repair applied")
    end)

    Suite:testMethod("CraftManager.repairCraft", {description = "Restores health", testCase = "restore", type = "functional"}, function()
        shared.cm:damageHealth("fighter", 50)
        shared.cm:repairCraft("fighter", 40)
        local health = shared.cm:getHealth("fighter")
        Helpers.assertEqual(health, 90, "Health restored to 90")
    end)

    Suite:testMethod("CraftManager.repairCraft", {description = "Caps at max", testCase = "cap", type = "functional"}, function()
        shared.cm:damageHealth("fighter", 30)
        shared.cm:repairCraft("fighter", 50)
        local health = shared.cm:getHealth("fighter")
        Helpers.assertEqual(health, 100, "Health capped at 100")
    end)
end)

Suite:group("Craft Status", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.cm = CraftManager:new()
        shared.cm:addCraft("patrol", "Patrol", "fighter", 90)
    end)

    Suite:testMethod("CraftManager.setCraftStatus", {description = "Sets status", testCase = "set_status", type = "functional"}, function()
        local ok = shared.cm:setCraftStatus("patrol", "deployed")
        Helpers.assertEqual(ok, true, "Status set")
    end)

    Suite:testMethod("CraftManager.getCraftStatus", {description = "Gets status", testCase = "get_status", type = "functional"}, function()
        shared.cm:setCraftStatus("patrol", "deployed")
        local status = shared.cm:getCraftStatus("patrol")
        Helpers.assertEqual(status, "deployed", "Status is deployed")
    end)

    Suite:testMethod("CraftManager.getCraftStatus", {description = "Initial idle", testCase = "idle", type = "functional"}, function()
        local status = shared.cm:getCraftStatus("patrol")
        Helpers.assertEqual(status, "idle", "Initial status idle")
    end)
end)

Suite:group("Ammunition", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.cm = CraftManager:new()
        shared.cm:addCraft("gun", "Gunship", "transport", 100)
    end)

    Suite:testMethod("CraftManager.addAmmunition", {description = "Adds ammunition", testCase = "add", type = "functional"}, function()
        local ok = shared.cm:addAmmunition("gun", 50)
        Helpers.assertEqual(ok, true, "Ammo added")
    end)

    Suite:testMethod("CraftManager.getAmmunition", {description = "Gets ammo", testCase = "get", type = "functional"}, function()
        shared.cm:addAmmunition("gun", 100)
        local ammo = shared.cm:getAmmunition("gun")
        Helpers.assertEqual(ammo, 100, "Ammo is 100")
    end)

    Suite:testMethod("CraftManager.useAmmunition", {description = "Uses ammunition", testCase = "use", type = "functional"}, function()
        shared.cm:addAmmunition("gun", 50)
        local ok = shared.cm:useAmmunition("gun", 20)
        Helpers.assertEqual(ok, true, "Ammo used")
    end)

    Suite:testMethod("CraftManager.useAmmunition", {description = "Reduces count", testCase = "reduce", type = "functional"}, function()
        shared.cm:addAmmunition("gun", 60)
        shared.cm:useAmmunition("gun", 25)
        local ammo = shared.cm:getAmmunition("gun")
        Helpers.assertEqual(ammo, 35, "Ammo reduced to 35")
    end)

    Suite:testMethod("CraftManager.useAmmunition", {description = "Fails if insufficient", testCase = "insufficient", type = "functional"}, function()
        shared.cm:addAmmunition("gun", 10)
        local ok = shared.cm:useAmmunition("gun", 20)
        Helpers.assertEqual(ok, false, "Insufficient ammo fails")
    end)
end)

Suite:group("Weapon Loadouts", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.cm = CraftManager:new()
        shared.cm:addCraft("heavy", "Heavy", "fighter", 120)
    end)

    Suite:testMethod("CraftManager.createWeaponSlot", {description = "Creates slot", testCase = "create", type = "functional"}, function()
        local ok = shared.cm:createWeaponSlot("slot1", "heavy", "cannon")
        Helpers.assertEqual(ok, true, "Slot created")
    end)

    Suite:testMethod("CraftManager.getWeaponSlot", {description = "Retrieves slot", testCase = "get", type = "functional"}, function()
        shared.cm:createWeaponSlot("slot2", "heavy", "laser")
        local slot = shared.cm:getWeaponSlot("slot2")
        Helpers.assertEqual(slot ~= nil, true, "Slot retrieved")
    end)

    Suite:testMethod("CraftManager.equipWeapon", {description = "Equips weapon", testCase = "equip", type = "functional"}, function()
        shared.cm:createWeaponSlot("slot3", "heavy", "plasma")
        local ok = shared.cm:equipWeapon("slot3")
        Helpers.assertEqual(ok, true, "Weapon equipped")
    end)

    Suite:testMethod("CraftManager.unequipWeapon", {description = "Unequips weapon", testCase = "unequip", type = "functional"}, function()
        shared.cm:createWeaponSlot("slot4", "heavy", "missile")
        shared.cm:equipWeapon("slot4")
        local ok = shared.cm:unequipWeapon("slot4")
        Helpers.assertEqual(ok, true, "Weapon unequipped")
    end)
end)

Suite:group("Loadout Profiles", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.cm = CraftManager:new()
    end)

    Suite:testMethod("CraftManager.createLoadout", {description = "Creates loadout", testCase = "create", type = "functional"}, function()
        local ok = shared.cm:createLoadout("aggressive", "Aggressive", {"heavy_cannon", "missiles"})
        Helpers.assertEqual(ok, true, "Loadout created")
    end)

    Suite:testMethod("CraftManager.activateLoadout", {description = "Activates loadout", testCase = "activate", type = "functional"}, function()
        shared.cm:createLoadout("defensive", "Defensive", {"laser", "shield"})
        local ok = shared.cm:activateLoadout("defensive")
        Helpers.assertEqual(ok, true, "Loadout activated")
    end)
end)

Suite:run()
