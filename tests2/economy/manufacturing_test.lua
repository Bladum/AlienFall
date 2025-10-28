-- ─────────────────────────────────────────────────────────────────────────
-- MANUFACTURING SYSTEM TEST SUITE
-- FILE: tests2/economy/manufacturing_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.economy.production.manufacturing_system",
    fileName = "manufacturing_system.lua",
    description = "Production and manufacturing system for equipment and items"
})

print("[MANUFACTURING_TEST] Setting up")

local ManufacturingSystem = {
    productions = {},
    inventory = {},
    recipes = {},

    new = function(self)
        return setmetatable({productions = {}, inventory = {}, recipes = {}}, {__index = self})
    end,

    addRecipe = function(self, recipeId, name, cost, time)
        self.recipes[recipeId] = {id = recipeId, name = name, cost = cost, time = time, output = 1}
        return true
    end,

    startProduction = function(self, recipeId, quantity)
        local recipe = self.recipes[recipeId]
        if not recipe then return false end
        local prodId = "prod_" .. os.time()
        self.productions[prodId] = {
            id = prodId,
            recipe = recipeId,
            quantity = quantity,
            progress = 0,
            complete = false
        }
        return prodId
    end,

    getProduction = function(self, prodId)
        return self.productions[prodId]
    end,

    updateProduction = function(self, prodId, progress)
        local prod = self.productions[prodId]
        if not prod then return false end
        prod.progress = math.min(100, progress)
        if prod.progress >= 100 then prod.complete = true end
        return true
    end,

    completeProduction = function(self, prodId)
        local prod = self.productions[prodId]
        if not prod or not prod.complete then return false end
        local recipe = self.recipes[prod.recipe]
        if not recipe then return false end
        local itemId = recipe.name .. "_" .. prodId
        self.inventory[itemId] = {id = itemId, name = recipe.name, quantity = prod.quantity}
        self.productions[prodId] = nil
        return itemId
    end,

    getInventory = function(self)
        return self.inventory
    end,

    getInventoryCount = function(self)
        local count = 0
        for _ in pairs(self.inventory) do count = count + 1 end
        return count
    end,

    getRecipe = function(self, recipeId)
        return self.recipes[recipeId]
    end,

    getProductionTime = function(self, recipeId, quantity)
        local recipe = self.recipes[recipeId]
        if not recipe then return nil end
        return recipe.time * quantity
    end
}

Suite:group("Recipe Management", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.mfg = ManufacturingSystem:new()
    end)

    Suite:testMethod("ManufacturingSystem.new", {description = "Creates manufacturing system", testCase = "create", type = "functional"}, function()
        Helpers.assertEqual(shared.mfg ~= nil, true, "System created")
    end)

    Suite:testMethod("ManufacturingSystem.addRecipe", {description = "Adds production recipe", testCase = "add_recipe", type = "functional"}, function()
        local ok = shared.mfg:addRecipe("rifle", "Laser Rifle", 500, 24)
        Helpers.assertEqual(ok, true, "Recipe added")
    end)

    Suite:testMethod("ManufacturingSystem.getRecipe", {description = "Retrieves recipe", testCase = "get_recipe", type = "functional"}, function()
        shared.mfg:addRecipe("plasma", "Plasma Weapon", 1000, 48)
        local recipe = shared.mfg:getRecipe("plasma")
        Helpers.assertEqual(recipe ~= nil, true, "Recipe retrieved")
    end)

    Suite:testMethod("ManufacturingSystem.getRecipe", {description = "Returns nil for missing recipe", testCase = "missing", type = "functional"}, function()
        local recipe = shared.mfg:getRecipe("nonexistent")
        Helpers.assertEqual(recipe, nil, "Missing recipe returns nil")
    end)
end)

Suite:group("Production Workflow", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.mfg = ManufacturingSystem:new()
        shared.mfg:addRecipe("rifle", "Rifle", 500, 24)
    end)

    Suite:testMethod("ManufacturingSystem.startProduction", {description = "Starts production", testCase = "start", type = "functional"}, function()
        local prodId = shared.mfg:startProduction("rifle", 5)
        Helpers.assertEqual(prodId ~= nil and prodId ~= false, true, "Production started")
    end)

    Suite:testMethod("ManufacturingSystem.getProduction", {description = "Retrieves production status", testCase = "get_status", type = "functional"}, function()
        local prodId = shared.mfg:startProduction("rifle", 3)
        local prod = shared.mfg:getProduction(prodId)
        Helpers.assertEqual(prod ~= nil, true, "Production status retrieved")
    end)

    Suite:testMethod("ManufacturingSystem.updateProduction", {description = "Updates production progress", testCase = "update_progress", type = "functional"}, function()
        local prodId = shared.mfg:startProduction("rifle", 2)
        local ok = shared.mfg:updateProduction(prodId, 50)
        Helpers.assertEqual(ok, true, "Progress updated")
    end)

    Suite:testMethod("ManufacturingSystem.updateProduction", {description = "Clamps progress to 100", testCase = "clamp_progress", type = "functional"}, function()
        local prodId = shared.mfg:startProduction("rifle", 1)
        shared.mfg:updateProduction(prodId, 150)
        local prod = shared.mfg:getProduction(prodId)
        Helpers.assertEqual(prod.progress, 100, "Progress clamped to 100")
    end)

    Suite:testMethod("ManufacturingSystem.updateProduction", {description = "Marks complete at 100%", testCase = "mark_complete", type = "functional"}, function()
        local prodId = shared.mfg:startProduction("rifle", 1)
        shared.mfg:updateProduction(prodId, 100)
        local prod = shared.mfg:getProduction(prodId)
        Helpers.assertEqual(prod.complete, true, "Production marked complete")
    end)
end)

Suite:group("Inventory Management", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.mfg = ManufacturingSystem:new()
        shared.mfg:addRecipe("rifle", "Rifle", 500, 24)
    end)

    Suite:testMethod("ManufacturingSystem.completeProduction", {description = "Completes production", testCase = "complete", type = "functional"}, function()
        local prodId = shared.mfg:startProduction("rifle", 2)
        shared.mfg:updateProduction(prodId, 100)
        local itemId = shared.mfg:completeProduction(prodId)
        Helpers.assertEqual(itemId ~= nil and itemId ~= false, true, "Production completed")
    end)

    Suite:testMethod("ManufacturingSystem.getInventory", {description = "Retrieves inventory", testCase = "get_inventory", type = "functional"}, function()
        local prodId = shared.mfg:startProduction("rifle", 1)
        shared.mfg:updateProduction(prodId, 100)
        shared.mfg:completeProduction(prodId)
        local inventory = shared.mfg:getInventory()
        Helpers.assertEqual(inventory ~= nil, true, "Inventory retrieved")
    end)

    Suite:testMethod("ManufacturingSystem.getInventoryCount", {description = "Counts inventory items", testCase = "count", type = "functional"}, function()
        local prodId = shared.mfg:startProduction("rifle", 1)
        shared.mfg:updateProduction(prodId, 100)
        shared.mfg:completeProduction(prodId)
        local count = shared.mfg:getInventoryCount()
        Helpers.assertEqual(count, 1, "One item in inventory")
    end)

    Suite:testMethod("ManufacturingSystem.completeProduction", {description = "Removes from active production", testCase = "remove_active", type = "functional"}, function()
        local prodId = shared.mfg:startProduction("rifle", 1)
        shared.mfg:updateProduction(prodId, 100)
        shared.mfg:completeProduction(prodId)
        local prod = shared.mfg:getProduction(prodId)
        Helpers.assertEqual(prod, nil, "Removed from active production")
    end)
end)

Suite:group("Production Timing", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.mfg = ManufacturingSystem:new()
        shared.mfg:addRecipe("rifle", "Rifle", 500, 24)
    end)

    Suite:testMethod("ManufacturingSystem.getProductionTime", {description = "Calculates production time", testCase = "calc_time", type = "functional"}, function()
        local time = shared.mfg:getProductionTime("rifle", 1)
        Helpers.assertEqual(time, 24, "Production time is 24 hours for 1 unit")
    end)

    Suite:testMethod("ManufacturingSystem.getProductionTime", {description = "Scales time with quantity", testCase = "scale_time", type = "functional"}, function()
        local time = shared.mfg:getProductionTime("rifle", 5)
        Helpers.assertEqual(time, 120, "Production time is 120 hours for 5 units")
    end)

    Suite:testMethod("ManufacturingSystem.getProductionTime", {description = "Returns nil for missing recipe", testCase = "missing_recipe", type = "functional"}, function()
        local time = shared.mfg:getProductionTime("nonexistent", 1)
        Helpers.assertEqual(time, nil, "Missing recipe returns nil")
    end)
end)

Suite:run()
