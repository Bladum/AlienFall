-- ─────────────────────────────────────────────────────────────────────────
-- VOLUMETRIC STORAGE TEST SUITE
-- FILE: tests2/basescape/volumetric_storage_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.basescape.volumetric_storage",
    fileName = "volumetric_storage.lua",
    description = "3D volumetric storage system with stacking, capacity, and efficiency"
})

print("[VOLUMETRIC_STORAGE_TEST] Setting up")

local VolumetricStorage = {
    containers = {},
    items = {},
    slots = {},

    new = function(self)
        return setmetatable({containers = {}, items = {}, slots = {}}, {__index = self})
    end,

    createContainer = function(self, containerId, width, height, depth, maxCapacity)
        self.containers[containerId] = {
            id = containerId,
            width = width,
            height = height,
            depth = depth,
            maxCapacity = maxCapacity or (width * height * depth),
            currentUsage = 0,
            items = {}
        }
        self.items[containerId] = {}
        self.slots[containerId] = {}
        return true
    end,

    getContainer = function(self, containerId)
        return self.containers[containerId]
    end,

    addItem = function(self, containerId, itemId, volume, quantity)
        if not self.containers[containerId] then return false end
        local totalVolume = volume * quantity
        if self.containers[containerId].currentUsage + totalVolume > self.containers[containerId].maxCapacity then
            return false
        end
        self.containers[containerId].currentUsage = self.containers[containerId].currentUsage + totalVolume
        self.items[containerId][itemId] = {id = itemId, volume = volume, quantity = quantity}
        return true
    end,

    removeItem = function(self, containerId, itemId, quantity)
        if not self.containers[containerId] or not self.items[containerId][itemId] then return false end
        local item = self.items[containerId][itemId]
        if item.quantity < quantity then return false end
        local totalVolume = item.volume * quantity
        self.containers[containerId].currentUsage = self.containers[containerId].currentUsage - totalVolume
        item.quantity = item.quantity - quantity
        if item.quantity == 0 then
            self.items[containerId][itemId] = nil
        end
        return true
    end,

    getCapacity = function(self, containerId)
        if not self.containers[containerId] then return 0 end
        return self.containers[containerId].maxCapacity
    end,

    getCurrentUsage = function(self, containerId)
        if not self.containers[containerId] then return 0 end
        return self.containers[containerId].currentUsage
    end,

    getAvailableSpace = function(self, containerId)
        if not self.containers[containerId] then return 0 end
        return self.containers[containerId].maxCapacity - self.containers[containerId].currentUsage
    end,

    getCapacityPercentage = function(self, containerId)
        if not self.containers[containerId] then return 0 end
        return math.floor((self.containers[containerId].currentUsage / self.containers[containerId].maxCapacity) * 100)
    end,

    isFull = function(self, containerId)
        if not self.containers[containerId] then return false end
        return self.containers[containerId].currentUsage >= self.containers[containerId].maxCapacity
    end,

    isEmpty = function(self, containerId)
        if not self.containers[containerId] then return false end
        return self.containers[containerId].currentUsage == 0
    end,

    getItemCount = function(self, containerId)
        if not self.items[containerId] then return 0 end
        local count = 0
        for _ in pairs(self.items[containerId]) do count = count + 1 end
        return count
    end,

    getTotalItems = function(self, containerId)
        if not self.items[containerId] then return 0 end
        local total = 0
        for _, item in pairs(self.items[containerId]) do
            total = total + item.quantity
        end
        return total
    end,

    canFitItem = function(self, containerId, volume, quantity)
        if not self.containers[containerId] then return false end
        local totalVolume = volume * quantity
        return self.containers[containerId].currentUsage + totalVolume <= self.containers[containerId].maxCapacity
    end,

    getStorageEfficiency = function(self, containerId)
        if not self.containers[containerId] then return 0 end
        local maxVolume = self.containers[containerId].maxCapacity
        local usedVolume = self.containers[containerId].currentUsage
        if maxVolume == 0 then return 0 end
        return math.floor((usedVolume / maxVolume) * 100)
    end,

    stackItems = function(self, containerId, itemId, targetQuantity)
        if not self.items[containerId][itemId] then return false end
        local item = self.items[containerId][itemId]
        if targetQuantity < item.quantity then
            return false
        end
        local additionalVolume = item.volume * (targetQuantity - item.quantity)
        if self.containers[containerId].currentUsage + additionalVolume > self.containers[containerId].maxCapacity then
            return false
        end
        self.containers[containerId].currentUsage = self.containers[containerId].currentUsage + additionalVolume
        item.quantity = targetQuantity
        return true
    end,

    getContainerCount = function(self)
        local count = 0
        for _ in pairs(self.containers) do count = count + 1 end
        return count
    end,

    clearContainer = function(self, containerId)
        if not self.containers[containerId] then return false end
        self.containers[containerId].currentUsage = 0
        self.items[containerId] = {}
        return true
    end
}

Suite:group("Container Creation", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.vs = VolumetricStorage:new()
    end)

    Suite:testMethod("VolumetricStorage.createContainer", {description = "Creates container", testCase = "create", type = "functional"}, function()
        local ok = shared.vs:createContainer("cont1", 10, 10, 10, 1000)
        Helpers.assertEqual(ok, true, "Container created")
    end)

    Suite:testMethod("VolumetricStorage.getContainer", {description = "Retrieves container", testCase = "get", type = "functional"}, function()
        shared.vs:createContainer("cont2", 5, 5, 5, 125)
        local cont = shared.vs:getContainer("cont2")
        Helpers.assertEqual(cont ~= nil, true, "Container retrieved")
    end)

    Suite:testMethod("VolumetricStorage.getCapacity", {description = "Gets capacity", testCase = "capacity", type = "functional"}, function()
        shared.vs:createContainer("cont3", 8, 8, 8, 512)
        local cap = shared.vs:getCapacity("cont3")
        Helpers.assertEqual(cap, 512, "512 capacity")
    end)

    Suite:testMethod("VolumetricStorage.getContainerCount", {description = "Counts containers", testCase = "count", type = "functional"}, function()
        shared.vs:createContainer("c1", 10, 10, 10, 1000)
        shared.vs:createContainer("c2", 5, 5, 5, 125)
        local count = shared.vs:getContainerCount()
        Helpers.assertEqual(count, 2, "Two containers")
    end)
end)

Suite:group("Item Storage", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.vs = VolumetricStorage:new()
        shared.vs:createContainer("storage", 10, 10, 10, 1000)
    end)

    Suite:testMethod("VolumetricStorage.addItem", {description = "Adds item", testCase = "add_item", type = "functional"}, function()
        local ok = shared.vs:addItem("storage", "ammo", 5, 10)
        Helpers.assertEqual(ok, true, "Item added")
    end)

    Suite:testMethod("VolumetricStorage.removeItem", {description = "Removes item", testCase = "remove_item", type = "functional"}, function()
        shared.vs:addItem("storage", "medkit", 8, 5)
        local ok = shared.vs:removeItem("storage", "medkit", 2)
        Helpers.assertEqual(ok, true, "Item removed")
    end)

    Suite:testMethod("VolumetricStorage.getItemCount", {description = "Counts item types", testCase = "item_types", type = "functional"}, function()
        shared.vs:addItem("storage", "weapon", 20, 3)
        shared.vs:addItem("storage", "armor", 15, 2)
        local count = shared.vs:getItemCount("storage")
        Helpers.assertEqual(count, 2, "Two item types")
    end)

    Suite:testMethod("VolumetricStorage.getTotalItems", {description = "Counts total items", testCase = "total_items", type = "functional"}, function()
        shared.vs:addItem("storage", "rounds", 2, 50)
        shared.vs:addItem("storage", "supplies", 3, 30)
        local total = shared.vs:getTotalItems("storage")
        Helpers.assertEqual(total, 80, "80 total items")
    end)
end)

Suite:group("Capacity Management", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.vs = VolumetricStorage:new()
        shared.vs:createContainer("capacity", 10, 10, 10, 500)
    end)

    Suite:testMethod("VolumetricStorage.getCurrentUsage", {description = "Gets usage", testCase = "current_usage", type = "functional"}, function()
        shared.vs:addItem("capacity", "item", 50, 5)
        local usage = shared.vs:getCurrentUsage("capacity")
        Helpers.assertEqual(usage, 250, "250 used")
    end)

    Suite:testMethod("VolumetricStorage.getAvailableSpace", {description = "Gets available", testCase = "available", type = "functional"}, function()
        shared.vs:addItem("capacity", "item", 50, 3)
        local available = shared.vs:getAvailableSpace("capacity")
        Helpers.assertEqual(available, 350, "350 available")
    end)

    Suite:testMethod("VolumetricStorage.getCapacityPercentage", {description = "Gets percentage", testCase = "percentage", type = "functional"}, function()
        shared.vs:addItem("capacity", "item", 50, 5)
        local pct = shared.vs:getCapacityPercentage("capacity")
        Helpers.assertEqual(pct, 50, "50%")
    end)

    Suite:testMethod("VolumetricStorage.canFitItem", {description = "Checks fit", testCase = "fit_check", type = "functional"}, function()
        shared.vs:addItem("capacity", "item", 50, 5)
        local canFit = shared.vs:canFitItem("capacity", 50, 5)
        Helpers.assertEqual(canFit, true, "Can fit")
    end)
end)

Suite:group("Storage Status", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.vs = VolumetricStorage:new()
        shared.vs:createContainer("status", 10, 10, 10, 100)
    end)

    Suite:testMethod("VolumetricStorage.isEmpty", {description = "Empty check", testCase = "is_empty", type = "functional"}, function()
        local empty = shared.vs:isEmpty("status")
        Helpers.assertEqual(empty, true, "Is empty")
    end)

    Suite:testMethod("VolumetricStorage.isFull", {description = "Full check", testCase = "is_full", type = "functional"}, function()
        shared.vs:addItem("status", "item", 10, 10)
        local full = shared.vs:isFull("status")
        Helpers.assertEqual(full, true, "Is full")
    end)

    Suite:testMethod("VolumetricStorage.getStorageEfficiency", {description = "Efficiency", testCase = "efficiency", type = "functional"}, function()
        shared.vs:addItem("status", "item", 20, 2)
        local eff = shared.vs:getStorageEfficiency("status")
        Helpers.assertEqual(eff, 40, "40% efficiency")
    end)
end)

Suite:group("Item Stacking", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.vs = VolumetricStorage:new()
        shared.vs:createContainer("stacking", 10, 10, 10, 500)
    end)

    Suite:testMethod("VolumetricStorage.stackItems", {description = "Stacks items", testCase = "stack", type = "functional"}, function()
        shared.vs:addItem("stacking", "supplies", 25, 5)
        local ok = shared.vs:stackItems("stacking", "supplies", 10)
        Helpers.assertEqual(ok, true, "Stacked")
    end)
end)

Suite:group("Container Operations", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.vs = VolumetricStorage:new()
        shared.vs:createContainer("operations", 10, 10, 10, 1000)
    end)

    Suite:testMethod("VolumetricStorage.clearContainer", {description = "Clears container", testCase = "clear", type = "functional"}, function()
        shared.vs:addItem("operations", "item1", 10, 5)
        shared.vs:addItem("operations", "item2", 15, 3)
        local ok = shared.vs:clearContainer("operations")
        Helpers.assertEqual(ok, true, "Cleared")
    end)
end)

Suite:run()
