-- ─────────────────────────────────────────────────────────────────────────
-- DEPLOYMENT SYSTEM TESTS
-- ─────────────────────────────────────────────────────────────────────────
-- Tests tactical deployment, landing zones, and unit placement
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")
local DeploymentSystem = require("engine.battlescape.deployment_system")

-- ─────────────────────────────────────────────────────────────────────────
-- MOCK BATTLE MAP
-- ─────────────────────────────────────────────────────────────────────────

local BattleMap = {}
BattleMap.__index = BattleMap

function BattleMap:new(width, height)
    local self = setmetatable({}, BattleMap)
    self.width = width or 24
    self.height = height or 24
    self.tiles = {}
    return self
end

function BattleMap:isValidPosition(x, y)
    return x >= 1 and x <= self.width and y >= 1 and y <= self.height
end

-- ─────────────────────────────────────────────────────────────────────────
-- TEST SUITE
-- ─────────────────────────────────────────────────────────────────────────

local Suite = HierarchicalSuite:new({
    modulePath = "engine.battlescape.deployment_system",
    fileName = "deployment_system.lua",
    description = "Tactical deployment system for landing zones and unit placement"
})

Suite:before(function() print("[DeploymentSystemTest] Setting up") end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 1: SYSTEM INITIALIZATION
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("System Initialization", function()
    local shared = {}

    Suite:beforeEach(function()
        shared.map = BattleMap:new(24, 24)
        shared.system = DeploymentSystem:new(shared.map)
    end)

    Suite:testMethod("DeploymentSystem.new", {description="Creates deployment system instance", testCase="creation", type="functional"},
    function()
        Helpers.assertEqual(shared.system ~= nil, true, "Deployment system should be created")
        Helpers.assertEqual(shared.system.battleMap ~= nil, true, "Should have battle map reference")
        Helpers.assertEqual(type(shared.system.landingZones), "table", "Landing zones table should exist")
        Helpers.assertEqual(type(shared.system.deployedUnits), "table", "Deployed units table should exist")
        -- Removed manual print - framework handles this
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 2: LANDING ZONE GENERATION
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Landing Zone Generation", function()
    local shared = {}

    Suite:beforeEach(function()
        shared.map = BattleMap:new(24, 24)
        shared.system = DeploymentSystem:new(shared.map)
    end)

    Suite:testMethod("DeploymentSystem.generateLandingZones", {description="Generates landing zones for different mission types", testCase="zone_generation", type="functional"},
    function()
        -- Test assault mission
        local zones = shared.system:generateLandingZones("assault", 8)
        Helpers.assertEqual(#zones, 3, "Assault mission should have 3 landing zones")
        Helpers.assertEqual(zones[1].size, "large", "First zone should be large")
        Helpers.assertEqual(zones[2].size, "medium", "Second zone should be medium")

        -- Test infiltration mission
        zones = shared.system:generateLandingZones("infiltration", 4)
        Helpers.assertEqual(#zones, 1, "Infiltration mission should have 1 landing zone")
        Helpers.assertEqual(zones[1].hidden, true, "Infiltration zone should be hidden")

        -- Test default mission
        zones = shared.system:generateLandingZones("default", 6)
        Helpers.assertEqual(#zones, 1, "Default mission should have 1 landing zone")
        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("DeploymentSystem.getAvailableLandingZones", {description="Returns available landing zones", testCase="available_zones", type="functional"},
    function()
        shared.system:generateLandingZones("assault", 8)
        local available = shared.system:getAvailableLandingZones()
        Helpers.assertEqual(#available, 3, "All zones should be available initially")

        -- Reserve a zone
        shared.system:reserveLandingZone(1)
        available = shared.system:getAvailableLandingZones()
        Helpers.assertEqual(#available, 2, "One zone should be unavailable after reservation")
        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("DeploymentSystem.reserveLandingZone", {description="Reserves landing zones for deployment", testCase="zone_reservation", type="functional"},
    function()
        shared.system:generateLandingZones("assault", 8)

        -- Reserve valid zone
        local zone = shared.system:reserveLandingZone(1)
        Helpers.assertEqual(zone ~= nil, true, "Should reserve valid zone")
        if zone then
            Helpers.assertEqual(zone.reserved, true, "Zone should be marked reserved")
        end

        -- Try to reserve same zone again
        zone = shared.system:reserveLandingZone(1)
        Helpers.assertEqual(zone, nil, "Should not reserve already reserved zone")

        -- Try to reserve invalid zone
        zone = shared.system:reserveLandingZone(10)
        Helpers.assertEqual(zone, nil, "Should not reserve invalid zone")
        -- Removed manual print - framework handles this
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 3: UNIT DEPLOYMENT
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Unit Deployment", function()
    local shared = {}

    Suite:beforeEach(function()
        shared.map = BattleMap:new(24, 24)
        shared.system = DeploymentSystem:new(shared.map)
        shared.system:generateLandingZones("assault", 8)
    end)

    Suite:testMethod("DeploymentSystem.deployUnit", {description="Deploys units to valid positions", testCase="unit_deployment", type="functional"},
    function()
        local zone = shared.system:reserveLandingZone(1)

        -- Deploy unit to valid position
        local success, error = shared.system:deployUnit("unit1", zone, {x = 6, y = 6})
        Helpers.assertEqual(success, true, "Should deploy unit to valid position")

        -- Check deployment record
        local deployed = shared.system:getDeployedUnits()
        Helpers.assertEqual(deployed["unit1"] ~= nil, true, "Unit should be in deployed units")
        Helpers.assertEqual(deployed["unit1"].deployed, true, "Unit should be marked deployed")
        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("DeploymentSystem.deployUnit", {description="Validates deployment positions", testCase="position_validation", type="functional"},
    function()
        local zone = shared.system:reserveLandingZone(1)

        -- Try to deploy too far from landing zone
        local success, error = shared.system:deployUnit("unit1", zone, {x = 20, y = 20})
        Helpers.assertEqual(success, false, "Should not deploy too far from landing zone")
        Helpers.assertEqual(error, "Position too far from landing zone", "Should return correct error")

        -- Try to deploy to invalid map position
        success, error = shared.system:deployUnit("unit1", zone, {x = 30, y = 30})
        Helpers.assertEqual(success, false, "Should not deploy to invalid map position")
        Helpers.assertEqual(error, "Invalid map position", "Should return correct error")

        -- Try to deploy to occupied landing zone
        local zone2 = shared.system.landingZones[2]
        zone2.occupied = true
        success, error = shared.system:deployUnit("unit1", zone2, {x = 16, y = 6})
        Helpers.assertEqual(success, false, "Should not deploy to occupied landing zone")
        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("DeploymentSystem.getDeploymentOrder", {description="Tracks deployment order of units", testCase="deployment_order", type="functional"},
    function()
        local zone1 = shared.system:reserveLandingZone(1)
        local zone2 = shared.system:reserveLandingZone(2)

        shared.system:deployUnit("unit1", zone1, {x = 6, y = 6})
        shared.system:deployUnit("unit2", zone2, {x = 16, y = 6})

        local order = shared.system:getDeploymentOrder()
        Helpers.assertEqual(#order, 2, "Should have 2 units in deployment order")
        Helpers.assertEqual(order[1], "unit1", "First unit should be unit1")
        Helpers.assertEqual(order[2], "unit2", "Second unit should be unit2")
        -- Removed manual print - framework handles this
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 4: DEPLOYMENT TURNS
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Deployment Turns", function()
    local shared = {}

    Suite:beforeEach(function()
        shared.map = BattleMap:new(24, 24)
        shared.system = DeploymentSystem:new(shared.map)
        shared.system:generateLandingZones("assault", 8)
    end)

    Suite:testMethod("DeploymentSystem.canDeployMoreUnits", {description="Checks if more units can be deployed", testCase="deployment_limits", type="functional"},
    function()
        Helpers.assertEqual(shared.system:canDeployMoreUnits(), true, "Should allow deployment initially")
        Helpers.assertEqual(shared.system:getCurrentDeploymentTurn(), 1, "Should start on turn 1")
        Helpers.assertEqual(shared.system:getMaxDeploymentTurns(), 3, "Should have 3 max turns")

        -- Advance turns
        shared.system:advanceDeploymentTurn()
        Helpers.assertEqual(shared.system:getCurrentDeploymentTurn(), 2, "Should advance to turn 2")
        Helpers.assertEqual(shared.system:canDeployMoreUnits(), true, "Should still allow deployment")

        shared.system:advanceDeploymentTurn()
        shared.system:advanceDeploymentTurn()
        Helpers.assertEqual(shared.system:getCurrentDeploymentTurn(), 3, "Should be on final turn")
        Helpers.assertEqual(shared.system:canDeployMoreUnits(), true, "Should allow deployment on final turn")

        shared.system:advanceDeploymentTurn()
        Helpers.assertEqual(shared.system:canDeployMoreUnits(), false, "Should not allow deployment after max turns")
        -- Removed manual print - framework handles this
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 5: DEPLOYMENT SCORING AND VALIDATION
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Deployment Scoring and Validation", function()
    local shared = {}

    Suite:beforeEach(function()
        shared.map = BattleMap:new(24, 24)
        shared.system = DeploymentSystem:new(shared.map)
        shared.system:generateLandingZones("assault", 8)
    end)

    Suite:testMethod("DeploymentSystem.calculateDeploymentScore", {description="Calculates deployment effectiveness score", testCase="scoring", type="functional"},
    function()
        local zone1 = shared.system:reserveLandingZone(1)
        local zone2 = shared.system:reserveLandingZone(2)

        shared.system:deployUnit("unit1", zone1, {x = 6, y = 6})  -- Early deployment, good position
        shared.system:advanceDeploymentTurn()
        shared.system:deployUnit("unit2", zone2, {x = 16, y = 6}) -- Later deployment, good position

        local score, count = shared.system:calculateDeploymentScore()
        Helpers.assertEqual(count, 2, "Should count 2 deployed units")
        Helpers.assertEqual(score > 0, true, "Should calculate positive score")
        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("DeploymentSystem.validateDeployment", {description="Validates complete deployment setup", testCase="validation", type="functional"},
    function()
        -- Test invalid deployment (no units)
        local valid, errors = shared.system:validateDeployment()
        Helpers.assertEqual(valid, false, "Should be invalid with no deployment")
        Helpers.assertEqual(#errors > 0, true, "Should have validation errors")

        -- Test valid deployment
        shared.system:generateLandingZones("assault", 8)
        local zone = shared.system:reserveLandingZone(1)
        shared.system:deployUnit("unit1", zone, {x = 6, y = 6})

        valid, errors = shared.system:validateDeployment()
        Helpers.assertEqual(valid, true, "Should be valid with proper deployment")
        Helpers.assertEqual(#errors, 0, "Should have no validation errors")
        -- Removed manual print - framework handles this
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- EXPORT
-- ─────────────────────────────────────────────────────────────────────────

return Suite
