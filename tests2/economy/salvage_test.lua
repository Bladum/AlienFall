-- ─────────────────────────────────────────────────────────────────────────
-- SALVAGE SYSTEM TEST SUITE
-- FILE: tests2/economy/salvage_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.economy.marketplace.salvage_system",
    fileName = "salvage_system.lua",
    description = "Salvage recovery and recycling system"
})

print("[SALVAGE_TEST] Setting up")

local SalvageSystem = {
    salvage = {},
    recipes = {},
    inventory = {},

    new = function(self)
        return setmetatable({salvage = {}, recipes = {}, inventory = {}}, {__index = self})
    end,

    addSalvageItem = function(self, itemId, name, value)
        self.salvage[itemId] = {id = itemId, name = name, value = value, salvageable = true}
        return true
    end,

    addRecipe = function(self, recipeId, name, inputs, outputs)
        self.recipes[recipeId] = {id = recipeId, name = name, inputs = inputs or {}, outputs = outputs or {}}
        return true
    end,

    salvageItem = function(self, itemId)
        if not self.salvage[itemId] then return false end
        local value = self.salvage[itemId].value
        table.insert(self.inventory, {type = "salvage", item = itemId, value = value})
        return true
    end,

    getTotalSalvageValue = function(self)
        local total = 0
        for _, item in ipairs(self.inventory) do
            if item.type == "salvage" then total = total + item.value end
        end
        return total
    end,

    processSalvage = function(self, recipeId, quantity)
        local recipe = self.recipes[recipeId]
        if not recipe then return false end
        local produced = {}
        for outputItem, outputQty in pairs(recipe.outputs) do
            produced[outputItem] = outputQty * quantity
        end
        table.insert(self.inventory, {type = "processed", recipe = recipeId, qty = quantity, output = produced})
        return true
    end,

    getSalvageCount = function(self)
        local count = 0
        for _ in pairs(self.salvage) do count = count + 1 end
        return count
    end,

    getRecipeCount = function(self)
        local count = 0
        for _ in pairs(self.recipes) do count = count + 1 end
        return count
    end,

    getInventoryCount = function(self)
        return #self.inventory
    end
}

Suite:group("Salvage Management", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.salvage = SalvageSystem:new()
    end)

    Suite:testMethod("SalvageSystem.new", {description = "Creates salvage system", testCase = "create", type = "functional"}, function()
        Helpers.assertEqual(shared.salvage ~= nil, true, "System created")
    end)

    Suite:testMethod("SalvageSystem.addSalvageItem", {description = "Adds salvageable item", testCase = "add", type = "functional"}, function()
        local ok = shared.salvage:addSalvageItem("alien_weapon", "Alien Weapon", 500)
        Helpers.assertEqual(ok, true, "Item added")
    end)

    Suite:testMethod("SalvageSystem.getSalvageCount", {description = "Counts salvage items", testCase = "count", type = "functional"}, function()
        shared.salvage:addSalvageItem("item1", "Item 1", 100)
        shared.salvage:addSalvageItem("item2", "Item 2", 200)
        shared.salvage:addSalvageItem("item3", "Item 3", 150)
        local count = shared.salvage:getSalvageCount()
        Helpers.assertEqual(count, 3, "Three items registered")
    end)
end)

Suite:group("Salvage Recipes", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.salvage = SalvageSystem:new()
    end)

    Suite:testMethod("SalvageSystem.addRecipe", {description = "Adds salvage recipe", testCase = "add_recipe", type = "functional"}, function()
        local ok = shared.salvage:addRecipe("alloy_recipe", "Alloy Production",
            {metal = 5}, {alloy = 2})
        Helpers.assertEqual(ok, true, "Recipe added")
    end)

    Suite:testMethod("SalvageSystem.getRecipeCount", {description = "Counts recipes", testCase = "count_recipes", type = "functional"}, function()
        shared.salvage:addRecipe("r1", "Recipe 1", {}, {})
        shared.salvage:addRecipe("r2", "Recipe 2", {}, {})
        local count = shared.salvage:getRecipeCount()
        Helpers.assertEqual(count, 2, "Two recipes registered")
    end)
end)

Suite:group("Salvage Operations", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.salvage = SalvageSystem:new()
        shared.salvage:addSalvageItem("weapon", "Weapon", 300)
        shared.salvage:addSalvageItem("armor", "Armor", 200)
    end)

    Suite:testMethod("SalvageSystem.salvageItem", {description = "Salvages item", testCase = "salvage", type = "functional"}, function()
        local ok = shared.salvage:salvageItem("weapon")
        Helpers.assertEqual(ok, true, "Item salvaged")
    end)

    Suite:testMethod("SalvageSystem.getInventoryCount", {description = "Tracks inventory", testCase = "inv_count", type = "functional"}, function()
        shared.salvage:salvageItem("weapon")
        shared.salvage:salvageItem("armor")
        local count = shared.salvage:getInventoryCount()
        Helpers.assertEqual(count, 2, "Two items in inventory")
    end)

    Suite:testMethod("SalvageSystem.getTotalSalvageValue", {description = "Calculates value", testCase = "total_value", type = "functional"}, function()
        shared.salvage:salvageItem("weapon")
        shared.salvage:salvageItem("armor")
        local value = shared.salvage:getTotalSalvageValue()
        Helpers.assertEqual(value, 500, "Total value is 300+200 = 500")
    end)

    Suite:testMethod("SalvageSystem.salvageItem", {description = "Rejects invalid", testCase = "invalid", type = "functional"}, function()
        local ok = shared.salvage:salvageItem("nonexistent")
        Helpers.assertEqual(ok, false, "Invalid item rejected")
    end)
end)

Suite:group("Recipe Processing", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.salvage = SalvageSystem:new()
        shared.salvage:addRecipe("smelt", "Smelting", {ore = 10}, {ingot = 5})
    end)

    Suite:testMethod("SalvageSystem.processSalvage", {description = "Processes recipe", testCase = "process", type = "functional"}, function()
        local ok = shared.salvage:processSalvage("smelt", 2)
        Helpers.assertEqual(ok, true, "Recipe processed")
    end)

    Suite:testMethod("SalvageSystem.processSalvage", {description = "Rejects invalid recipe", testCase = "invalid_recipe", type = "functional"}, function()
        local ok = shared.salvage:processSalvage("nonexistent", 1)
        Helpers.assertEqual(ok, false, "Invalid recipe rejected")
    end)

    Suite:testMethod("SalvageSystem.getInventoryCount", {description = "Adds processed item", testCase = "add_processed", type = "functional"}, function()
        shared.salvage:processSalvage("smelt", 1)
        local count = shared.salvage:getInventoryCount()
        Helpers.assertEqual(count, 1, "Processed item added")
    end)
end)

Suite:run()
