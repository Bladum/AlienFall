--- Test suite for TransferOrder class
-- @module test.economy.test_transfer_order

local test_framework = require("test.framework.test_framework")
local TransferOrder = require("src.economy.TransferOrder")

local TestTransferOrder = {}

function TestTransferOrder.test_creation()
    local transfer_data = {
        id = "test_transfer_1",
        originBaseId = "base_a",
        destinationBaseId = "base_b",
        priority = "normal",
        payload = {
            { type = "item", id = "alien_alloy", quantity = 10, volume = 1 },
            { type = "unit", id = "soldier", quantity = 3, size = 1 }
        }
    }

    local transfer = TransferOrder.new(transfer_data)

    test_framework.assert_equal(transfer.id, "test_transfer_1", "Transfer ID should match")
    test_framework.assert_equal(transfer.originBaseId, "base_a", "Origin base should match")
    test_framework.assert_equal(transfer.destinationBaseId, "base_b", "Destination base should match")
    test_framework.assert_equal(transfer.priority, "normal", "Priority should match")
    test_framework.assert_equal(#transfer.payload, 2, "Payload should have 2 entries")
    test_framework.assert_equal(transfer.status, "pending", "Initial status should be pending")
end

function TestTransferOrder.test_cost_calculation()
    local transfer_data = {
        id = "test_transfer_2",
        originBaseId = "base_a",
        destinationBaseId = "base_b",
        priority = "normal",
        payload = {
            { type = "item", id = "alien_alloy", quantity = 10, volume = 1 },
            { type = "unit", id = "soldier", quantity = 3, size = 1 }
        }
    }

    local transfer = TransferOrder.new(transfer_data)
    local distance = 12
    local config = {
        unitCostFactor = 10,
        itemCostFactor = 2,
        baseFixedCost = 50
    }

    local cost = transfer:calculateCost(distance, config)
    -- Expected: 12 * (10 * 3 + 2 * 10) + 50 = 12 * (30 + 20) + 50 = 12 * 50 + 50 = 650
    test_framework.assert_equal(cost, 650, "Cost calculation should be correct")
end

function TestTransferOrder.test_transit_time_calculation()
    local transfer_data = {
        id = "test_transfer_3",
        originBaseId = "base_a",
        destinationBaseId = "base_b",
        payload = {
            { type = "item", id = "alien_alloy", quantity = 10, volume = 1 }
        }
    }

    local transfer = TransferOrder.new(transfer_data)
    local distance = 10
    local config = {
        daysPerTile = 1,
        fixedOverheadDays = 1
    }

    local transitTime = transfer:calculateTransitTime(distance, config)
    test_framework.assert_equal(transitTime, 11, "Transit time should be distance + overhead")
end

function TestTransferOrder.test_market_delivery()
    local transfer_data = {
        id = "market_delivery",
        originBaseId = "void",
        destinationBaseId = "base_a",
        payload = {
            { type = "item", id = "laser_rifle", quantity = 1, volume = 1 }
        }
    }

    local transfer = TransferOrder.new(transfer_data)
    local cost = transfer:calculateCost(100, {})  -- Distance should not matter for market
    local transitTime = transfer:calculateTransitTime(100, { marketDeliveryTime = 3 })

    test_framework.assert_equal(cost, 0, "Market deliveries should be free")
    test_framework.assert_equal(transitTime, 3, "Market deliveries should use fixed time")
end

function TestTransferOrder.test_capacity_validation()
    local transfer_data = {
        id = "test_transfer_4",
        originBaseId = "base_a",
        destinationBaseId = "base_b",
        payload = {
            { type = "unit", id = "soldier", quantity = 3, size = 1 },
            { type = "item", id = "alien_alloy", quantity = 10, volume = 1 }
        }
    }

    local transfer = TransferOrder.new(transfer_data)

    -- Test sufficient capacity
    local sufficientCapacity = { units = 5, volume = 15 }
    test_framework.assert_true(transfer:validateCapacity(sufficientCapacity), "Should validate sufficient capacity")

    -- Test insufficient unit capacity
    local insufficientUnits = { units = 2, volume = 15 }
    test_framework.assert_false(transfer:validateCapacity(insufficientUnits), "Should reject insufficient unit capacity")

    -- Test insufficient volume capacity
    local insufficientVolume = { units = 5, volume = 5 }
    test_framework.assert_false(transfer:validateCapacity(insufficientVolume), "Should reject insufficient volume capacity")
end

function TestTransferOrder.test_transfer_execution()
    local transfer_data = {
        id = "test_transfer_5",
        originBaseId = "base_a",
        destinationBaseId = "base_b",
        payload = {
            { type = "item", id = "alien_alloy", quantity = 5, volume = 1 }
        }
    }

    local transfer = TransferOrder.new(transfer_data)

    -- Test execution
    local success = transfer:executeTransfer()
    test_framework.assert_true(success, "Transfer execution should succeed")
    test_framework.assert_equal(transfer.status, "active", "Status should change to active")
    test_framework.assert_not_nil(transfer.departureTime, "Departure time should be set")
end

function TestTransferOrder.test_transfer_completion()
    local transfer_data = {
        id = "test_transfer_6",
        originBaseId = "base_a",
        destinationBaseId = "base_b",
        payload = {
            { type = "item", id = "alien_alloy", quantity = 5, volume = 1 }
        },
        transitDays = 5,
        remainingDays = 5
    }

    local transfer = TransferOrder.new(transfer_data)
    transfer:executeTransfer()

    -- Simulate progress
    for i = 1, 4 do
        transfer:updateProgress()
        test_framework.assert_equal(transfer.status, "active", "Should remain active during transit")
    end

    -- Final update should complete
    transfer:updateProgress()
    test_framework.assert_equal(transfer.status, "completed", "Should complete after transit time")
    test_framework.assert_equal(transfer.progress, 100, "Progress should be 100%")
end

function TestTransferOrder.test_transfer_cancellation()
    local transfer_data = {
        id = "test_transfer_7",
        originBaseId = "base_a",
        destinationBaseId = "base_b",
        payload = {
            { type = "item", id = "alien_alloy", quantity = 5, volume = 1 }
        }
    }

    local transfer = TransferOrder.new(transfer_data)

    -- Cancel pending transfer
    local success = transfer:cancelTransfer("user_cancelled")
    test_framework.assert_true(success, "Cancellation should succeed")
    test_framework.assert_equal(transfer.status, "cancelled", "Status should be cancelled")
end

function TestTransferOrder.test_priority_cost_multipliers()
    local base_transfer_data = {
        id = "test_transfer_8",
        originBaseId = "base_a",
        destinationBaseId = "base_b",
        payload = {
            { type = "item", id = "alien_alloy", quantity = 10, volume = 1 }
        }
    }

    local config = {
        unitCostFactor = 10,
        itemCostFactor = 2,
        baseFixedCost = 50,
        lowPriorityMultiplier = 0.8,
        normalPriorityMultiplier = 1.0,
        highPriorityMultiplier = 1.5,
        emergencyPriorityMultiplier = 2.0
    }

    -- Test low priority
    local lowPriorityTransfer = TransferOrder.new({
        id = "low_priority",
        originBaseId = "base_a",
        destinationBaseId = "base_b",
        priority = "low",
        payload = { { type = "item", id = "alien_alloy", quantity = 10, volume = 1 } }
    })
    local lowCost = lowPriorityTransfer:calculateCost(10, config)

    -- Test high priority
    local highPriorityTransfer = TransferOrder.new({
        id = "high_priority",
        originBaseId = "base_a",
        destinationBaseId = "base_b",
        priority = "high",
        payload = { { type = "item", id = "alien_alloy", quantity = 10, volume = 1 } }
    })
    local highCost = highPriorityTransfer:calculateCost(10, config)

    -- Base cost: 10 * (2 * 10) + 50 = 10 * 20 + 50 = 250
    -- Low priority: 250 * 0.8 = 200
    -- High priority: 250 * 1.5 = 375
    test_framework.assert_equal(lowCost, 200, "Low priority should reduce cost")
    test_framework.assert_equal(highCost, 375, "High priority should increase cost")
end

return TestTransferOrder