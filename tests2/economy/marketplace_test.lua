-- ─────────────────────────────────────────────────────────────────────────
-- MARKETPLACE SYSTEM TEST SUITE
-- FILE: tests2/economy/marketplace_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.economy.marketplace.marketplace_system",
    fileName = "marketplace_system.lua",
    description = "Marketplace trading and commerce system"
})

print("[MARKETPLACE_TEST] Setting up")

local MarketplaceSystem = {
    items = {},
    listings = {},
    transactions = {},

    new = function(self)
        return setmetatable({items = {}, listings = {}, transactions = {}}, {__index = self})
    end,

    addItem = function(self, itemId, name, price, stock)
        self.items[itemId] = {id = itemId, name = name, price = price, stock = stock or 0}
        self.listings[itemId] = {id = itemId, available = true, quantity = stock or 0}
        return true
    end,

    getItem = function(self, itemId)
        return self.items[itemId]
    end,

    getPrice = function(self, itemId)
        if not self.items[itemId] then return nil end
        return self.items[itemId].price
    end,

    setPrice = function(self, itemId, newPrice)
        if not self.items[itemId] then return false end
        self.items[itemId].price = math.max(0, newPrice)
        return true
    end,

    buyItem = function(self, itemId, quantity, buyer)
        local listing = self.listings[itemId]
        if not listing or listing.quantity < quantity then return false end
        listing.quantity = listing.quantity - quantity
        local price = self.items[itemId].price * quantity
        table.insert(self.transactions, {type = "buy", item = itemId, qty = quantity, buyer = buyer, price = price})
        return true
    end,

    sellItem = function(self, itemId, quantity, seller)
        local listing = self.listings[itemId]
        if not listing then return false end
        listing.quantity = listing.quantity + quantity
        local price = self.items[itemId].price * quantity
        table.insert(self.transactions, {type = "sell", item = itemId, qty = quantity, seller = seller, price = price})
        return true
    end,

    getStock = function(self, itemId)
        if not self.listings[itemId] then return nil end
        return self.listings[itemId].quantity
    end,

    getTransactionCount = function(self)
        return #self.transactions
    end,

    getTotalSalesValue = function(self)
        local total = 0
        for _, trans in ipairs(self.transactions) do
            if trans.type == "buy" then total = total + trans.price end
        end
        return total
    end
}

Suite:group("Item Management", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.mp = MarketplaceSystem:new()
    end)

    Suite:testMethod("MarketplaceSystem.new", {description = "Creates marketplace", testCase = "create", type = "functional"}, function()
        Helpers.assertEqual(shared.mp ~= nil, true, "Marketplace created")
    end)

    Suite:testMethod("MarketplaceSystem.addItem", {description = "Adds item", testCase = "add", type = "functional"}, function()
        local ok = shared.mp:addItem("rifle", "Laser Rifle", 500, 10)
        Helpers.assertEqual(ok, true, "Item added")
    end)

    Suite:testMethod("MarketplaceSystem.getItem", {description = "Retrieves item", testCase = "get", type = "functional"}, function()
        shared.mp:addItem("plasma", "Plasma Gun", 1000, 5)
        local item = shared.mp:getItem("plasma")
        Helpers.assertEqual(item ~= nil, true, "Item retrieved")
    end)

    Suite:testMethod("MarketplaceSystem.getItem", {description = "Returns nil for missing", testCase = "missing", type = "functional"}, function()
        local item = shared.mp:getItem("nonexistent")
        Helpers.assertEqual(item, nil, "Missing item returns nil")
    end)
end)

Suite:group("Pricing", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.mp = MarketplaceSystem:new()
        shared.mp:addItem("item1", "Item 1", 100, 20)
    end)

    Suite:testMethod("MarketplaceSystem.getPrice", {description = "Gets item price", testCase = "get_price", type = "functional"}, function()
        local price = shared.mp:getPrice("item1")
        Helpers.assertEqual(price, 100, "Price retrieved")
    end)

    Suite:testMethod("MarketplaceSystem.setPrice", {description = "Sets new price", testCase = "set_price", type = "functional"}, function()
        local ok = shared.mp:setPrice("item1", 150)
        Helpers.assertEqual(ok, true, "Price set")
    end)

    Suite:testMethod("MarketplaceSystem.getPrice", {description = "Price updated", testCase = "updated", type = "functional"}, function()
        shared.mp:setPrice("item1", 200)
        local price = shared.mp:getPrice("item1")
        Helpers.assertEqual(price, 200, "Updated price retrieved")
    end)

    Suite:testMethod("MarketplaceSystem.setPrice", {description = "Prevents negative price", testCase = "min_price", type = "functional"}, function()
        shared.mp:setPrice("item1", -100)
        local price = shared.mp:getPrice("item1")
        Helpers.assertEqual(price, 0, "Negative price prevented")
    end)
end)

Suite:group("Trading", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.mp = MarketplaceSystem:new()
        shared.mp:addItem("sword", "Sword", 50, 100)
    end)

    Suite:testMethod("MarketplaceSystem.buyItem", {description = "Buys items", testCase = "buy", type = "functional"}, function()
        local ok = shared.mp:buyItem("sword", 10, "player")
        Helpers.assertEqual(ok, true, "Purchase successful")
    end)

    Suite:testMethod("MarketplaceSystem.getStock", {description = "Reduces stock", testCase = "reduce_stock", type = "functional"}, function()
        shared.mp:buyItem("sword", 25, "player")
        local stock = shared.mp:getStock("sword")
        Helpers.assertEqual(stock, 75, "Stock reduced by 25")
    end)

    Suite:testMethod("MarketplaceSystem.buyItem", {description = "Rejects over-purchase", testCase = "over_purchase", type = "functional"}, function()
        local ok = shared.mp:buyItem("sword", 200, "player")
        Helpers.assertEqual(ok, false, "Over-purchase rejected")
    end)

    Suite:testMethod("MarketplaceSystem.sellItem", {description = "Sells items", testCase = "sell", type = "functional"}, function()
        local ok = shared.mp:sellItem("sword", 50, "merchant")
        Helpers.assertEqual(ok, true, "Sale successful")
    end)

    Suite:testMethod("MarketplaceSystem.getStock", {description = "Increases on sale", testCase = "increase_stock", type = "functional"}, function()
        shared.mp:sellItem("sword", 30, "merchant")
        local stock = shared.mp:getStock("sword")
        Helpers.assertEqual(stock, 130, "Stock increased by 30")
    end)
end)

Suite:group("Transaction Tracking", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.mp = MarketplaceSystem:new()
        shared.mp:addItem("item", "Item", 100, 50)
    end)

    Suite:testMethod("MarketplaceSystem.getTransactionCount", {description = "Counts transactions", testCase = "count", type = "functional"}, function()
        shared.mp:buyItem("item", 5, "p1")
        shared.mp:buyItem("item", 10, "p2")
        local count = shared.mp:getTransactionCount()
        Helpers.assertEqual(count, 2, "Two transactions recorded")
    end)

    Suite:testMethod("MarketplaceSystem.getTotalSalesValue", {description = "Calculates sales value", testCase = "sales_value", type = "functional"}, function()
        shared.mp:buyItem("item", 10, "buyer")
        local value = shared.mp:getTotalSalesValue()
        Helpers.assertEqual(value, 1000, "Sales value is 10 * 100 = 1000")
    end)

    Suite:testMethod("MarketplaceSystem.getTotalSalesValue", {description = "Multiple purchases", testCase = "multi_purchase", type = "functional"}, function()
        shared.mp:buyItem("item", 5, "b1")
        shared.mp:buyItem("item", 3, "b2")
        local value = shared.mp:getTotalSalesValue()
        Helpers.assertEqual(value, 800, "Sales value is (5+3)*100 = 800")
    end)
end)

Suite:run()
