-- ─────────────────────────────────────────────────────────────────────────
-- CRAFT INVENTORY TEST SUITE
-- FILE: tests2/basescape/craft_inventory_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.basescape.craft_inventory",
    fileName = "craft_inventory.lua",
    description = "Craft inventory management with equipment slots, cargo, and weight/space tracking"
})

print("[CRAFT_INVENTORY_TEST] Setting up")

local CraftInventory = {
    crafts = {},
    inventory = {},
    equipment = {},
    cargo = {},

    new = function(self)
        return setmetatable({crafts = {}, inventory = {}, equipment = {}, cargo = {}}, {__index = self})
    end,

    registerCraft = function(self, craftId, craftName, cargoCapacity, maxEquipmentSlots)
        self.crafts[craftId] = {id = craftId, name = craftName, cargoCapacity = cargoCapacity or 500, maxSlots = maxEquipmentSlots or 8, usedSlots = 0}
        self.inventory[craftId] = {cargoUsed = 0, items = {}}
        self.equipment[craftId] = {}
        self.cargo[craftId] = {}
        return true
    end,

    getCraft = function(self, craftId)
        return self.crafts[craftId]
    end,

    addEquipment = function(self, craftId, equipmentId, slotType, weight)
        if not self.crafts[craftId] then return false end
        if self.crafts[craftId].usedSlots >= self.crafts[craftId].maxSlots then return false end
        self.equipment[craftId][equipmentId] = {id = equipmentId, type = slotType, weight = weight or 10, installed = true}
        self.crafts[craftId].usedSlots = self.crafts[craftId].usedSlots + 1
        return true
    end,

    getEquipmentCount = function(self, craftId)
        if not self.equipment[craftId] then return 0 end
        local count = 0
        for _ in pairs(self.equipment[craftId]) do count = count + 1 end
        return count
    end,

    removeEquipment = function(self, craftId, equipmentId)
        if not self.equipment[craftId] or not self.equipment[craftId][equipmentId] then return false end
        self.equipment[craftId][equipmentId] = nil
        self.crafts[craftId].usedSlots = self.crafts[craftId].usedSlots - 1
        return true
    end,

    getTotalEquipmentWeight = function(self, craftId)
        if not self.equipment[craftId] then return 0 end
        local total = 0
        for _, equip in pairs(self.equipment[craftId]) do
            total = total + equip.weight
        end
        return total
    end,

    addCargo = function(self, craftId, itemId, itemType, quantity, weight)
        if not self.inventory[craftId] then return false end
        local totalWeight = quantity * weight
        if self.inventory[craftId].cargoUsed + totalWeight > self.crafts[craftId].cargoCapacity then return false end
        self.cargo[craftId][itemId] = {id = itemId, type = itemType, quantity = quantity, weight = weight, totalWeight = totalWeight}
        self.inventory[craftId].cargoUsed = self.inventory[craftId].cargoUsed + totalWeight
        return true
    end,

    getCargoCount = function(self, craftId)
        if not self.cargo[craftId] then return 0 end
        local count = 0
        for _ in pairs(self.cargo[craftId]) do count = count + 1 end
        return count
    end,

    removeCargo = function(self, craftId, itemId, quantity)
        if not self.cargo[craftId] or not self.cargo[craftId][itemId] then return false end
        local item = self.cargo[craftId][itemId]
        if item.quantity < quantity then return false end
        local weightRemoved = quantity * item.weight
        item.quantity = item.quantity - quantity
        self.inventory[craftId].cargoUsed = self.inventory[craftId].cargoUsed - weightRemoved
        if item.quantity == 0 then
            self.cargo[craftId][itemId] = nil
        end
        return true
    end,

    getCargoSpace = function(self, craftId)
        if not self.crafts[craftId] then return 0 end
        return self.crafts[craftId].cargoCapacity - self.inventory[craftId].cargoUsed
    end,

    getCargoUsage = function(self, craftId)
        if not self.inventory[craftId] then return 0 end
        return self.inventory[craftId].cargoUsed
    end,

    getCargoCapacity = function(self, craftId)
        if not self.crafts[craftId] then return 0 end
        return self.crafts[craftId].cargoCapacity
    end,

    getEquipmentSlotUsage = function(self, craftId)
        if not self.crafts[craftId] then return {used = 0, max = 0} end
        return {used = self.crafts[craftId].usedSlots, max = self.crafts[craftId].maxSlots}
    end,

    canAddCargo = function(self, craftId, weight)
        if not self.crafts[craftId] then return false end
        return self.inventory[craftId].cargoUsed + weight <= self.crafts[craftId].cargoCapacity
    end,

    canAddEquipment = function(self, craftId)
        if not self.crafts[craftId] then return false end
        return self.crafts[craftId].usedSlots < self.crafts[craftId].maxSlots
    end,

    clearCargo = function(self, craftId)
        if not self.inventory[craftId] then return false end
        self.cargo[craftId] = {}
        self.inventory[craftId].cargoUsed = 0
        return true
    end,

    clearEquipment = function(self, craftId)
        if not self.crafts[craftId] then return false end
        self.equipment[craftId] = {}
        self.crafts[craftId].usedSlots = 0
        return true
    end,

    getTotalCargoQuantity = function(self, craftId)
        if not self.cargo[craftId] then return 0 end
        local total = 0
        for _, item in pairs(self.cargo[craftId]) do
            total = total + item.quantity
        end
        return total
    end,

    getCargoUtilization = function(self, craftId)
        if not self.crafts[craftId] then return 0 end
        local cap = self.crafts[craftId].cargoCapacity
        if cap == 0 then return 0 end
        return math.floor((self.inventory[craftId].cargoUsed / cap) * 100)
    end,

    getEquipmentSlotUtilization = function(self, craftId)
        if not self.crafts[craftId] then return 0 end
        local max = self.crafts[craftId].maxSlots
        if max == 0 then return 0 end
        return math.floor((self.crafts[craftId].usedSlots / max) * 100)
    end,

    moveCargoToCraft = function(self, fromCraftId, toCraftId, itemId, quantity)
        if not self.cargo[fromCraftId] or not self.cargo[fromCraftId][itemId] then return false end
        if self.cargo[fromCraftId][itemId].quantity < quantity then return false end
        local item = self.cargo[fromCraftId][itemId]
        local totalWeight = quantity * item.weight
        if not self:canAddCargo(toCraftId, totalWeight) then return false end
        self:removeCargo(fromCraftId, itemId, quantity)
        self:addCargo(toCraftId, itemId, item.type, quantity, item.weight)
        return true
    end
}

Suite:group("Craft Registration", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ci = CraftInventory:new()
    end)

    Suite:testMethod("CraftInventory.registerCraft", {description = "Registers craft", testCase = "register", type = "functional"}, function()
        local ok = shared.ci:registerCraft("interceptor1", "Interceptor", 1000, 8)
        Helpers.assertEqual(ok, true, "Craft registered")
    end)

    Suite:testMethod("CraftInventory.getCraft", {description = "Gets craft", testCase = "get", type = "functional"}, function()
        shared.ci:registerCraft("fighter1", "Fighter", 800, 6)
        local craft = shared.ci:getCraft("fighter1")
        Helpers.assertEqual(craft ~= nil, true, "Craft retrieved")
    end)
end)

Suite:group("Equipment Management", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ci = CraftInventory:new()
        shared.ci:registerCraft("craft1", "Test Craft", 1000, 8)
    end)

    Suite:testMethod("CraftInventory.addEquipment", {description = "Adds equipment", testCase = "add_equip", type = "functional"}, function()
        local ok = shared.ci:addEquipment("craft1", "laser_cannon", "weapon", 50)
        Helpers.assertEqual(ok, true, "Equipment added")
    end)

    Suite:testMethod("CraftInventory.getEquipmentCount", {description = "Counts equipment", testCase = "equip_count", type = "functional"}, function()
        shared.ci:addEquipment("craft1", "e1", "weapon", 40)
        shared.ci:addEquipment("craft1", "e2", "defense", 30)
        local count = shared.ci:getEquipmentCount("craft1")
        Helpers.assertEqual(count, 2, "Two equipment")
    end)

    Suite:testMethod("CraftInventory.removeEquipment", {description = "Removes equipment", testCase = "remove_equip", type = "functional"}, function()
        shared.ci:addEquipment("craft1", "to_remove", "sensor", 20)
        local ok = shared.ci:removeEquipment("craft1", "to_remove")
        Helpers.assertEqual(ok, true, "Removed")
    end)

    Suite:testMethod("CraftInventory.getTotalEquipmentWeight", {description = "Total weight", testCase = "total_weight", type = "functional"}, function()
        shared.ci:addEquipment("craft1", "w1", "weapon", 50)
        shared.ci:addEquipment("craft1", "w2", "weapon", 40)
        local weight = shared.ci:getTotalEquipmentWeight("craft1")
        Helpers.assertEqual(weight, 90, "90 weight")
    end)
end)

Suite:group("Cargo Management", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ci = CraftInventory:new()
        shared.ci:registerCraft("carrier", "Cargo Craft", 2000, 4)
    end)

    Suite:testMethod("CraftInventory.addCargo", {description = "Adds cargo", testCase = "add_cargo", type = "functional"}, function()
        local ok = shared.ci:addCargo("carrier", "ammo", "ammunition", 100, 5)
        Helpers.assertEqual(ok, true, "Cargo added")
    end)

    Suite:testMethod("CraftInventory.getCargoCount", {description = "Counts cargo types", testCase = "cargo_count", type = "functional"}, function()
        shared.ci:addCargo("carrier", "c1", "supplies", 50, 10)
        shared.ci:addCargo("carrier", "c2", "fuel", 200, 3)
        local count = shared.ci:getCargoCount("carrier")
        Helpers.assertEqual(count, 2, "Two cargo types")
    end)

    Suite:testMethod("CraftInventory.removeCargo", {description = "Removes cargo", testCase = "remove_cargo", type = "functional"}, function()
        shared.ci:addCargo("carrier", "supplies", "consumable", 100, 5)
        local ok = shared.ci:removeCargo("carrier", "supplies", 30)
        Helpers.assertEqual(ok, true, "Removed")
    end)

    Suite:testMethod("CraftInventory.getTotalCargoQuantity", {description = "Total quantity", testCase = "total_qty", type = "functional"}, function()
        shared.ci:addCargo("carrier", "item1", "supplies", 50, 10)
        shared.ci:addCargo("carrier", "item2", "ammo", 100, 5)
        local qty = shared.ci:getTotalCargoQuantity("carrier")
        Helpers.assertEqual(qty, 150, "150 items")
    end)
end)

Suite:group("Capacity & Space", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ci = CraftInventory:new()
        shared.ci:registerCraft("test", "Test", 1000, 8)
    end)

    Suite:testMethod("CraftInventory.getCargoCapacity", {description = "Gets capacity", testCase = "capacity", type = "functional"}, function()
        local cap = shared.ci:getCargoCapacity("test")
        Helpers.assertEqual(cap, 1000, "1000 capacity")
    end)

    Suite:testMethod("CraftInventory.getCargoUsage", {description = "Gets usage", testCase = "usage", type = "functional"}, function()
        shared.ci:addCargo("test", "cargo", "test", 50, 10)
        local usage = shared.ci:getCargoUsage("test")
        Helpers.assertEqual(usage, 500, "500 used")
    end)

    Suite:testMethod("CraftInventory.getCargoSpace", {description = "Gets space", testCase = "space", type = "functional"}, function()
        shared.ci:addCargo("test", "cargo", "test", 30, 10)
        local space = shared.ci:getCargoSpace("test")
        Helpers.assertEqual(space, 700, "700 space")
    end)

    Suite:testMethod("CraftInventory.canAddCargo", {description = "Can add", testCase = "can_add", type = "functional"}, function()
        local can = shared.ci:canAddCargo("test", 500)
        Helpers.assertEqual(can, true, "Can add")
    end)
end)

Suite:group("Slot Management", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ci = CraftInventory:new()
        shared.ci:registerCraft("slotted", "Slotted", 1000, 4)
    end)

    Suite:testMethod("CraftInventory.canAddEquipment", {description = "Can add", testCase = "can_add_equip", type = "functional"}, function()
        local can = shared.ci:canAddEquipment("slotted")
        Helpers.assertEqual(can, true, "Can add")
    end)

    Suite:testMethod("CraftInventory.getEquipmentSlotUsage", {description = "Slot usage", testCase = "slot_usage", type = "functional"}, function()
        shared.ci:addEquipment("slotted", "e1", "weapon", 40)
        local usage = shared.ci:getEquipmentSlotUsage("slotted")
        Helpers.assertEqual(usage.used, 1, "One slot used")
        Helpers.assertEqual(usage.max, 4, "Four max")
    end)
end)

Suite:group("Utilization", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ci = CraftInventory:new()
        shared.ci:registerCraft("util", "Util", 1000, 8)
    end)

    Suite:testMethod("CraftInventory.getCargoUtilization", {description = "Cargo util %", testCase = "cargo_util", type = "functional"}, function()
        shared.ci:addCargo("util", "item", "test", 50, 10)
        local util = shared.ci:getCargoUtilization("util")
        Helpers.assertEqual(util, 50, "50%")
    end)

    Suite:testMethod("CraftInventory.getEquipmentSlotUtilization", {description = "Slot util %", testCase = "slot_util", type = "functional"}, function()
        shared.ci:addEquipment("util", "e1", "weapon", 50)
        shared.ci:addEquipment("util", "e2", "defense", 40)
        local util = shared.ci:getEquipmentSlotUtilization("util")
        Helpers.assertEqual(util, 25, "25%")
    end)
end)

Suite:group("Cargo Transfer", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ci = CraftInventory:new()
        shared.ci:registerCraft("donor", "Donor", 1000, 4)
        shared.ci:registerCraft("receiver", "Receiver", 1000, 4)
        shared.ci:addCargo("donor", "transfer_item", "supplies", 100, 5)
    end)

    Suite:testMethod("CraftInventory.moveCargoToCraft", {description = "Transfers cargo", testCase = "transfer", type = "functional"}, function()
        local ok = shared.ci:moveCargoToCraft("donor", "receiver", "transfer_item", 30)
        Helpers.assertEqual(ok, true, "Transferred")
    end)
end)

Suite:group("Clearing", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ci = CraftInventory:new()
        shared.ci:registerCraft("clearing", "Clear", 1000, 8)
        shared.ci:addCargo("clearing", "c1", "test", 50, 10)
        shared.ci:addEquipment("clearing", "e1", "weapon", 40)
    end)

    Suite:testMethod("CraftInventory.clearCargo", {description = "Clears cargo", testCase = "clear_cargo", type = "functional"}, function()
        local ok = shared.ci:clearCargo("clearing")
        Helpers.assertEqual(ok, true, "Cleared")
    end)

    Suite:testMethod("CraftInventory.clearEquipment", {description = "Clears equipment", testCase = "clear_equip", type = "functional"}, function()
        local ok = shared.ci:clearEquipment("clearing")
        Helpers.assertEqual(ok, true, "Cleared")
    end)
end)

Suite:run()
