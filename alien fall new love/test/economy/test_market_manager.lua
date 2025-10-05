--- Test suite for MarketManager class
-- @module test.economy.test_market_manager

local test_framework = require("test.framework.test_framework")
local MarketManager = require("src.economy.MarketManager")
local PurchaseEntry = require("src.economy.PurchaseEntry")
local Supplier = require("src.economy.Supplier")

local TestMarketManager = {}

function TestMarketManager.test_creation()
    local market_manager = MarketManager.new({})

    test_framework.assert_not_nil(market_manager.suppliers, "Should have suppliers table")
    test_framework.assert_not_nil(market_manager.purchaseItems, "Should have purchase items table")
    test_framework.assert_not_nil(market_manager.unlockedSuppliers, "Should have unlocked suppliers table")
end

function TestMarketManager.test_purchase_processing()
    -- Create mock supplier
    local supplier_data = {
        id = "test_supplier",
        name = "Test Supplier",
        type = "military",
        pricing = { markup = 1.5 }
    }
    local supplier = Supplier.new(supplier_data)

    -- Create mock purchase entry
    local item_data = {
        id = "laser_rifle",
        name = "Laser Rifle",
        type = "weapon",
        category = "weapons",
        cost = { credits = 1000 },
        requirements = {}
    }
    local purchase_item = PurchaseEntry.new(item_data)

    local market_manager = MarketManager.new({
        suppliers = { supplier },
        purchaseItems = { purchase_item }
    })

    -- Unlock supplier
    market_manager:unlockSupplier("test_supplier")

    -- Test purchase availability
    local available_items = market_manager:getAvailableItems("base_a", "earth")
    test_framework.assert_equal(#available_items, 1, "Should have 1 available item")
    test_framework.assert_equal(available_items[1].item.id, "laser_rifle", "Item should be laser rifle")

    -- Test purchase processing
    local success, message = market_manager:processPurchase("laser_rifle", 1, "test_supplier", "base_a")
    test_framework.assert_true(success, "Purchase should succeed")
    test_framework.assert_equal(message, "Purchase successful", "Success message should match")
end

function TestMarketManager.test_supplier_unlocking()
    local supplier_data = {
        id = "locked_supplier",
        name = "Locked Supplier",
        type = "black_market",
        requirements = { research = { "smuggler_network" } }
    }
    local supplier = Supplier.new(supplier_data)

    local market_manager = MarketManager.new({
        suppliers = { supplier },
        purchaseItems = {}
    })

    -- Test initially locked
    test_framework.assert_false(market_manager:_isSupplierUnlocked("locked_supplier"), "Supplier should be locked initially")

    -- Unlock supplier
    market_manager:unlockSupplier("locked_supplier")
    test_framework.assert_true(market_manager:_isSupplierUnlocked("locked_supplier"), "Supplier should be unlocked")
end

function TestMarketManager.test_stock_management()
    local supplier_data = {
        id = "stock_supplier",
        name = "Stock Supplier",
        type = "military",
        availability = { monthlyStock = { laser_rifle = 10 } }
    }
    local supplier = Supplier.new(supplier_data)

    local market_manager = MarketManager.new({
        suppliers = { supplier },
        purchaseItems = {}
    })

    -- Test initial stock
    local stock = market_manager:_getItemStock("laser_rifle", "stock_supplier")
    test_framework.assert_equal(stock, 0, "Initial stock should be 0")

    -- Reset monthly stock
    market_manager:resetMonthlyStock()
    stock = market_manager:_getItemStock("laser_rifle", "stock_supplier")
    test_framework.assert_equal(stock, 10, "Stock should be reset to 10")

    -- Reduce stock
    market_manager:_reduceStock("laser_rifle", "stock_supplier", 3)
    stock = market_manager:_getItemStock("laser_rifle", "stock_supplier")
    test_framework.assert_equal(stock, 7, "Stock should be reduced to 7")
end

function TestMarketManager.test_price_calculation()
    local supplier_data = {
        id = "price_supplier",
        name = "Price Supplier",
        type = "military",
        pricing = { markup = 1.2 }
    }
    local supplier = Supplier.new(supplier_data)

    local item_data = {
        id = "test_weapon",
        name = "Test Weapon",
        type = "weapon",
        cost = { credits = 1000 }
    }
    local purchase_item = PurchaseEntry.new(item_data)

    local market_manager = MarketManager.new({
        suppliers = { supplier },
        purchaseItems = { purchase_item }
    })

    local price = market_manager:_calculateItemPrice(purchase_item, supplier)
    -- Base price 1000 * markup 1.2 = 1200
    test_framework.assert_equal(price, 1200, "Price should include supplier markup")
end

function TestMarketManager.test_reputation_discounts()
    local supplier_data = {
        id = "discount_supplier",
        name = "Discount Supplier",
        type = "civilian",
        pricing = { markup = 1.0 }
    }
    local supplier = Supplier.new(supplier_data)

    local item_data = {
        id = "test_item",
        name = "Test Item",
        type = "item",
        cost = { credits = 1000 }
    }
    local purchase_item = PurchaseEntry.new(item_data)

    local market_manager = MarketManager.new({
        suppliers = { supplier },
        purchaseItems = { purchase_item }
    })

    -- Mock organization with high fame
    market_manager.organization = {
        getFame = function() return 80 end,
        getKarma = function() return 50 end
    }

    local discount = market_manager:_calculateReputationDiscount(supplier)
    test_framework.assert_equal(discount, 0.1, "High fame should give 10% discount")
end

function TestMarketManager.test_market_summary()
    local supplier_data = {
        id = "summary_supplier",
        name = "Summary Supplier",
        type = "military"
    }
    local supplier = Supplier.new(supplier_data)

    local market_manager = MarketManager.new({
        suppliers = { supplier },
        purchaseItems = {}
    })

    market_manager:unlockSupplier("summary_supplier")

    local summary = market_manager:getMarketSummary()
    test_framework.assert_equal(summary.totalSuppliers, 1, "Should have 1 total supplier")
    test_framework.assert_equal(summary.unlockedSuppliers, 1, "Should have 1 unlocked supplier")
    test_framework.assert_equal(summary.availableItems, 0, "Should have 0 available items")
end

function TestMarketManager.test_purchase_validation()
    local supplier_data = {
        id = "validation_supplier",
        name = "Validation Supplier",
        type = "military"
    }
    local supplier = Supplier.new(supplier_data)

    local item_data = {
        id = "validation_item",
        name = "Validation Item",
        type = "item",
        cost = { credits = 1000 },
        requirements = { research = { "basic_research" } }
    }
    local purchase_item = PurchaseEntry.new(item_data)

    local market_manager = MarketManager.new({
        suppliers = { supplier },
        purchaseItems = { purchase_item },
        researchTree = {
            isCompleted = function(research_id)
                return research_id == "basic_research"  -- Mock completed research
            end
        },
        organization = {
            getFame = function() return 50 end,
            getKarma = function() return 50 end
        }
    })

    market_manager:unlockSupplier("validation_supplier")

    -- Test valid purchase
    local can_purchase = market_manager:canPurchaseItem("validation_item", "base_a")
    test_framework.assert_true(can_purchase, "Should be able to purchase valid item")

    -- Test invalid item
    can_purchase = market_manager:canPurchaseItem("nonexistent_item", "base_a")
    test_framework.assert_false(can_purchase, "Should not be able to purchase nonexistent item")
end

return TestMarketManager