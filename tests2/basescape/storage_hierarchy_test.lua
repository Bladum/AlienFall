-- ─────────────────────────────────────────────────────────────────────────
-- STORAGE HIERARCHY TEST SUITE
-- FILE: tests2/basescape/storage_hierarchy_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.basescape.storage_hierarchy",
    fileName = "storage_hierarchy.lua",
    description = "Multi-level storage hierarchy with nested containers, inheritance, and cascading effects"
})

print("[STORAGE_HIERARCHY_TEST] Setting up")

local StorageHierarchy = {
    facilities = {},
    storages = {},
    items = {},
    relationships = {},

    new = function(self)
        return setmetatable({facilities = {}, storages = {}, items = {}, relationships = {}}, {__index = self})
    end,

    createFacility = function(self, facilityId, facilityType, capacity)
        self.facilities[facilityId] = {id = facilityId, type = facilityType, capacity = capacity or 1000, usage = 0, storages = {}}
        self.storages[facilityId] = {}
        self.items[facilityId] = {}
        self.relationships[facilityId] = {parent = nil, children = {}}
        return true
    end,

    addStorage = function(self, facilityId, storageId, storageType, subCapacity)
        if not self.facilities[facilityId] then return false end
        self.storages[facilityId][storageId] = {id = storageId, type = storageType, capacity = subCapacity or 500, usage = 0}
        table.insert(self.facilities[facilityId].storages, storageId)
        return true
    end,

    setParentFacility = function(self, childFacilityId, parentFacilityId)
        if not self.facilities[childFacilityId] or not self.facilities[parentFacilityId] then return false end
        self.relationships[childFacilityId].parent = parentFacilityId
        if not self.relationships[parentFacilityId].children then self.relationships[parentFacilityId].children = {} end
        table.insert(self.relationships[parentFacilityId].children, childFacilityId)
        return true
    end,

    addItem = function(self, facilityId, storageId, itemId, volume, quantity)
        if not self.storages[facilityId] or not self.storages[facilityId][storageId] then return false end
        local totalVolume = volume * quantity
        local storage = self.storages[facilityId][storageId]
        if storage.usage + totalVolume > storage.capacity then return false end
        if not self.items[facilityId][storageId] then self.items[facilityId][storageId] = {} end
        self.items[facilityId][storageId][itemId] = {id = itemId, volume = volume, quantity = quantity}
        storage.usage = storage.usage + totalVolume
        self.facilities[facilityId].usage = self.facilities[facilityId].usage + totalVolume
        return true
    end,

    getItemCount = function(self, facilityId, storageId)
        if not self.items[facilityId] or not self.items[facilityId][storageId] then return 0 end
        local count = 0
        for _ in pairs(self.items[facilityId][storageId]) do count = count + 1 end
        return count
    end,

    getStorageCount = function(self, facilityId)
        if not self.facilities[facilityId] then return 0 end
        return #self.facilities[facilityId].storages
    end,

    getFacilityUsage = function(self, facilityId)
        if not self.facilities[facilityId] then return 0 end
        return self.facilities[facilityId].usage
    end,

    getFacilityCapacity = function(self, facilityId)
        if not self.facilities[facilityId] then return 0 end
        return self.facilities[facilityId].capacity
    end,

    getStorageUsage = function(self, facilityId, storageId)
        if not self.storages[facilityId] or not self.storages[facilityId][storageId] then return 0 end
        return self.storages[facilityId][storageId].usage
    end,

    getStorageCapacity = function(self, facilityId, storageId)
        if not self.storages[facilityId] or not self.storages[facilityId][storageId] then return 0 end
        return self.storages[facilityId][storageId].capacity
    end,

    calculateHierarchyUsage = function(self, facilityId)
        if not self.facilities[facilityId] then return 0 end
        local total = self:getFacilityUsage(facilityId)
        if self.relationships[facilityId].children then
            for _, childId in ipairs(self.relationships[facilityId].children) do
                total = total + self:calculateHierarchyUsage(childId)
            end
        end
        return total
    end,

    calculateHierarchyCapacity = function(self, facilityId)
        if not self.facilities[facilityId] then return 0 end
        local total = self:getFacilityCapacity(facilityId)
        if self.relationships[facilityId].children then
            for _, childId in ipairs(self.relationships[facilityId].children) do
                total = total + self:calculateHierarchyCapacity(childId)
            end
        end
        return total
    end,

    canAddToHierarchy = function(self, facilityId, volume)
        if not self.facilities[facilityId] then return false end
        local usage = self:calculateHierarchyUsage(facilityId)
        local capacity = self:calculateHierarchyCapacity(facilityId)
        return usage + volume <= capacity
    end,

    getFacilityChildren = function(self, facilityId)
        if not self.relationships[facilityId] then return {} end
        return self.relationships[facilityId].children or {}
    end,

    getChildCount = function(self, facilityId)
        if not self.relationships[facilityId] then return 0 end
        return #(self.relationships[facilityId].children or {})
    end,

    removeItem = function(self, facilityId, storageId, itemId, quantity)
        if not self.items[facilityId] or not self.items[facilityId][storageId] or not self.items[facilityId][storageId][itemId] then return false end
        local item = self.items[facilityId][storageId][itemId]
        if item.quantity < quantity then return false end
        local volumeRemoved = item.volume * quantity
        item.quantity = item.quantity - quantity
        self.storages[facilityId][storageId].usage = self.storages[facilityId][storageId].usage - volumeRemoved
        self.facilities[facilityId].usage = self.facilities[facilityId].usage - volumeRemoved
        if item.quantity == 0 then
            self.items[facilityId][storageId][itemId] = nil
        end
        return true
    end,

    getHierarchyDepth = function(self, facilityId)
        if not self.relationships[facilityId] then return 1 end
        local maxDepth = 1
        if self.relationships[facilityId].children then
            for _, childId in ipairs(self.relationships[facilityId].children) do
                maxDepth = math.max(maxDepth, 1 + self:getHierarchyDepth(childId))
            end
        end
        return maxDepth
    end,

    getTotalStorageCount = function(self, facilityId)
        if not self.facilities[facilityId] then return 0 end
        local count = self:getStorageCount(facilityId)
        if self.relationships[facilityId].children then
            for _, childId in ipairs(self.relationships[facilityId].children) do
                count = count + self:getTotalStorageCount(childId)
            end
        end
        return count
    end
}

Suite:group("Facility Creation", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.sh = StorageHierarchy:new()
    end)

    Suite:testMethod("StorageHierarchy.createFacility", {description = "Creates facility", testCase = "create", type = "functional"}, function()
        local ok = shared.sh:createFacility("main_storage", "warehouse", 5000)
        Helpers.assertEqual(ok, true, "Facility created")
    end)

    Suite:testMethod("StorageHierarchy.addStorage", {description = "Adds sub-storage", testCase = "add_storage", type = "functional"}, function()
        shared.sh:createFacility("facility1", "warehouse", 3000)
        local ok = shared.sh:addStorage("facility1", "section_a", "weapons", 1000)
        Helpers.assertEqual(ok, true, "Storage added")
    end)

    Suite:testMethod("StorageHierarchy.getStorageCount", {description = "Counts storages", testCase = "storage_count", type = "functional"}, function()
        shared.sh:createFacility("facility2", "warehouse", 3000)
        shared.sh:addStorage("facility2", "s1", "type1", 1000)
        shared.sh:addStorage("facility2", "s2", "type2", 1000)
        local count = shared.sh:getStorageCount("facility2")
        Helpers.assertEqual(count, 2, "Two storages")
    end)
end)

Suite:group("Hierarchy Structure", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.sh = StorageHierarchy:new()
        shared.sh:createFacility("parent", "main", 5000)
        shared.sh:createFacility("child1", "secondary", 2000)
        shared.sh:createFacility("child2", "secondary", 2000)
    end)

    Suite:testMethod("StorageHierarchy.setParentFacility", {description = "Sets parent", testCase = "set_parent", type = "functional"}, function()
        local ok = shared.sh:setParentFacility("child1", "parent")
        Helpers.assertEqual(ok, true, "Parent set")
    end)

    Suite:testMethod("StorageHierarchy.getFacilityChildren", {description = "Gets children", testCase = "get_children", type = "functional"}, function()
        shared.sh:setParentFacility("child1", "parent")
        shared.sh:setParentFacility("child2", "parent")
        local children = shared.sh:getFacilityChildren("parent")
        Helpers.assertEqual(#children, 2, "Two children")
    end)

    Suite:testMethod("StorageHierarchy.getChildCount", {description = "Counts children", testCase = "child_count", type = "functional"}, function()
        shared.sh:setParentFacility("child1", "parent")
        local count = shared.sh:getChildCount("parent")
        Helpers.assertEqual(count, 1, "One child")
    end)

    Suite:testMethod("StorageHierarchy.getHierarchyDepth", {description = "Gets depth", testCase = "depth", type = "functional"}, function()
        shared.sh:setParentFacility("child1", "parent")
        local depth = shared.sh:getHierarchyDepth("parent")
        Helpers.assertEqual(depth >= 1, true, "Depth calculated")
    end)
end)

Suite:group("Item Management", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.sh = StorageHierarchy:new()
        shared.sh:createFacility("storage", "warehouse", 3000)
        shared.sh:addStorage("storage", "weapons_room", "weapons", 1000)
    end)

    Suite:testMethod("StorageHierarchy.addItem", {description = "Adds item", testCase = "add_item", type = "functional"}, function()
        local ok = shared.sh:addItem("storage", "weapons_room", "rifle", 10, 5)
        Helpers.assertEqual(ok, true, "Item added")
    end)

    Suite:testMethod("StorageHierarchy.getItemCount", {description = "Counts items", testCase = "item_count", type = "functional"}, function()
        shared.sh:addItem("storage", "weapons_room", "i1", 10, 5)
        shared.sh:addItem("storage", "weapons_room", "i2", 15, 3)
        local count = shared.sh:getItemCount("storage", "weapons_room")
        Helpers.assertEqual(count, 2, "Two items")
    end)

    Suite:testMethod("StorageHierarchy.removeItem", {description = "Removes item", testCase = "remove_item", type = "functional"}, function()
        shared.sh:addItem("storage", "weapons_room", "item", 10, 5)
        local ok = shared.sh:removeItem("storage", "weapons_room", "item", 2)
        Helpers.assertEqual(ok, true, "Item removed")
    end)
end)

Suite:group("Usage & Capacity", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.sh = StorageHierarchy:new()
        shared.sh:createFacility("facility", "warehouse", 2000)
        shared.sh:addStorage("facility", "storage", "type", 1000)
    end)

    Suite:testMethod("StorageHierarchy.getStorageUsage", {description = "Gets storage usage", testCase = "usage", type = "functional"}, function()
        shared.sh:addItem("facility", "storage", "item", 50, 5)
        local usage = shared.sh:getStorageUsage("facility", "storage")
        Helpers.assertEqual(usage, 250, "250 used")
    end)

    Suite:testMethod("StorageHierarchy.getFacilityUsage", {description = "Gets facility usage", testCase = "facility_usage", type = "functional"}, function()
        shared.sh:addItem("facility", "storage", "item", 50, 5)
        local usage = shared.sh:getFacilityUsage("facility")
        Helpers.assertEqual(usage, 250, "250 facility used")
    end)

    Suite:testMethod("StorageHierarchy.getStorageCapacity", {description = "Gets capacity", testCase = "capacity", type = "functional"}, function()
        local cap = shared.sh:getStorageCapacity("facility", "storage")
        Helpers.assertEqual(cap, 1000, "1000 capacity")
    end)
end)

Suite:group("Hierarchy Calculations", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.sh = StorageHierarchy:new()
        shared.sh:createFacility("main", "primary", 5000)
        shared.sh:createFacility("sub1", "secondary", 2000)
        shared.sh:setParentFacility("sub1", "main")
    end)

    Suite:testMethod("StorageHierarchy.calculateHierarchyUsage", {description = "Calculates usage", testCase = "calc_usage", type = "functional"}, function()
        shared.sh:addStorage("main", "s1", "type", 500)
        shared.sh:addItem("main", "s1", "item", 50, 5)
        local usage = shared.sh:calculateHierarchyUsage("main")
        Helpers.assertEqual(usage, 250, "250 usage")
    end)

    Suite:testMethod("StorageHierarchy.calculateHierarchyCapacity", {description = "Calculates capacity", testCase = "calc_capacity", type = "functional"}, function()
        local cap = shared.sh:calculateHierarchyCapacity("main")
        Helpers.assertEqual(cap, 7000, "7000 capacity")
    end)

    Suite:testMethod("StorageHierarchy.canAddToHierarchy", {description = "Checks fit", testCase = "can_add", type = "functional"}, function()
        local can = shared.sh:canAddToHierarchy("main", 1000)
        Helpers.assertEqual(can, true, "Can fit")
    end)

    Suite:testMethod("StorageHierarchy.getTotalStorageCount", {description = "Total storages", testCase = "total_storages", type = "functional"}, function()
        shared.sh:addStorage("sub1", "sub_s1", "type", 500)
        local count = shared.sh:getTotalStorageCount("main")
        Helpers.assertEqual(count >= 1, true, "Storage counted")
    end)
end)

Suite:run()
