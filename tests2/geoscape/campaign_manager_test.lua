-- TEST: Campaign Manager
local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local CampaignManager = {}
CampaignManager.__index = CampaignManager

function CampaignManager:new()
    local self = setmetatable({}, CampaignManager)
    self.state = "active"
    self.day = 1
    self.funds = 1000
    self.research = 0
    return self
end

function CampaignManager:addFunds(amount)
    if not amount or amount < 0 then error("[Campaign] Invalid amount") end
    self.funds = self.funds + amount
    return self.funds
end

function CampaignManager:spendFunds(amount)
    if not amount or amount > self.funds then error("[Campaign] Insufficient funds") end
    self.funds = self.funds - amount
    return self.funds
end

function CampaignManager:addResearch(amount)
    self.research = self.research + amount
    return self.research
end

function CampaignManager:nextDay()
    self.day = self.day + 1
    return self.day
end

function CampaignManager:getStatus()
    return {
        state = self.state,
        day = self.day,
        funds = self.funds,
        research = self.research
    }
end

local Suite = HierarchicalSuite:new({
    modulePath = "engine.geoscape.managers.campaign_manager",
    fileName = "campaign_manager.lua",
    description = "Campaign management system"
})

Suite:before(function() print("[CampaignManager] Setting up") end)

Suite:group("Campaign Economy", function()
    local shared = {}
    Suite:beforeEach(function() shared.cam = CampaignManager:new() end)

    Suite:testMethod("CampaignManager.addFunds", {description="Adds funds", testCase="happy_path", type="functional"},
    function()
        local funds = shared.cam:addFunds(500)
        Helpers.assertEqual(funds, 1500, "Should have 1500")
        print("  ✓ Funds added")
    end)

    Suite:testMethod("CampaignManager.spendFunds", {description="Spends funds", testCase="spend", type="functional"},
    function()
        local funds = shared.cam:spendFunds(200)
        Helpers.assertEqual(funds, 800, "Should have 800")
        print("  ✓ Funds spent")
    end)

    Suite:testMethod("CampaignManager.addResearch", {description="Adds research", testCase="research", type="functional"},
    function()
        local res = shared.cam:addResearch(100)
        Helpers.assertEqual(res, 100, "Should have 100 research")
        print("  ✓ Research added")
    end)
end)

Suite:group("Campaign Timeline", function()
    local shared = {}
    Suite:beforeEach(function() shared.cam = CampaignManager:new() end)

    Suite:testMethod("CampaignManager.nextDay", {description="Advances day", testCase="timeline", type="functional"},
    function()
        local day = shared.cam:nextDay()
        Helpers.assertEqual(day, 2, "Should be day 2")
        print("  ✓ Day advanced")
    end)

    Suite:testMethod("CampaignManager.getStatus", {description="Gets campaign status", testCase="status", type="functional"},
    function()
        local status = shared.cam:getStatus()
        Helpers.assertEqual(status.day, 1, "Should report day")
        Helpers.assertEqual(status.funds, 1000, "Should report funds")
        print("  ✓ Status retrieved")
    end)
end)

return Suite
