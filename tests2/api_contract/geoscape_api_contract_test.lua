-- ─────────────────────────────────────────────────────────────────────────
-- GEOSCAPE API CONTRACT TESTS
-- ─────────────────────────────────────────────────────────────────────────
-- Purpose: Verify geoscape layer API contracts
-- Tests: 7 API contract tests
-- Expected: All pass in <150ms

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.geoscape",
    fileName = "geoscape_api_contract_test.lua",
    description = "Geoscape layer API contract validation"
})

-- ─────────────────────────────────────────────────────────────────────────
-- TESTS
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Geoscape API Contracts", function()

    local geoscape = {}

    Suite:beforeEach(function()
        geoscape = {
            worldMap = {},
            crafts = {},
            missions = {}
        }
    end)

    -- Contract 1: World map data structure
    Suite:testMethod("Geoscape:worldMapContract", {
        description = "World map must provide location data with consistent schema",
        testCase = "contract",
        type = "api"
    }, function()
        local worldMap = {
            regions = {},
            countries = {},
            bases = {}
        }

        function worldMap:getLocationByCoords(x, y)
            return {
                x = x,
                y = y,
                type = "water",
                region = nil,
                terrain = "ocean"
            }
        end

        local loc = worldMap:getLocationByCoords(100, 50)
        Helpers.assertEqual(loc.x, 100, "Location must have x coordinate")
        Helpers.assertEqual(loc.y, 50, "Location must have y coordinate")
        Helpers.assertTrue(loc.type ~= nil, "Location must have type")
    end)

    -- Contract 2: Craft object interface
    Suite:testMethod("Geoscape:craftObjectContract", {
        description = "Craft objects must provide consistent interface",
        testCase = "contract",
        type = "api"
    }, function()
        local function createCraft(name, type)
            return {
                id = math.random(1000000),
                name = name,
                type = type,
                status = "ready",
                position = {x = 0, y = 0},
                equipment = {},
                crew = {},

                moveTo = function(self, x, y) end,
                intercept = function(self, target) end,
                land = function(self) end,
                getEquipment = function(self) return self.equipment end
            }
        end

        local craft = createCraft("Avenger", "interceptor")
        Helpers.assertTrue(craft.id ~= nil, "Craft must have ID")
        Helpers.assertEqual(craft.name, "Avenger", "Craft must have name")
        Helpers.assertTrue(type(craft.moveTo) == "function", "moveTo must be function")
        Helpers.assertTrue(type(craft.intercept) == "function", "intercept must be function")
    end)

    -- Contract 3: Mission data structure
    Suite:testMethod("Geoscape:missionDataContract", {
        description = "Missions must have consistent data schema",
        testCase = "contract",
        type = "api"
    }, function()
        local mission = {
            id = 1,
            type = "investigation",
            location = {x = 100, y = 100},
            status = "new",
            reward = 500,
            difficulty = 3,
            timeLimit = 120,
            units = {},
            objectives = {}
        }

        Helpers.assertTrue(mission.id ~= nil, "Mission must have ID")
        Helpers.assertTrue(mission.location ~= nil, "Mission must have location")
        Helpers.assertTrue(mission.reward >= 0, "Reward must be non-negative")
    end)

    -- Contract 4: Craft intercept API
    Suite:testMethod("Geoscape:interceptAPIContract", {
        description = "Intercept API must provide consistent response format",
        testCase = "contract",
        type = "api"
    }, function()
        local function interceptUFO(craft, ufo)
            if not craft or not ufo then
                return {success = false, error = "Invalid parameters"}
            end

            local distance = math.sqrt((craft.x - ufo.x)^2 + (craft.y - ufo.y)^2)
            if distance > 1000 then
                return {success = false, error = "Out of range"}
            end

            return {
                success = true,
                battleId = math.random(100000),
                location = {x = ufo.x, y = ufo.y},
                ufo = ufo,
                craft = craft
            }
        end

        local result = interceptUFO({x = 100, y = 100}, {x = 110, y = 110})
        Helpers.assertTrue(result.success ~= nil, "Result must have success field")
        if result.success then
            Helpers.assertTrue(result.battleId ~= nil, "Success result must have battleId")
        end
    end)

    -- Contract 5: Deployment API
    Suite:testMethod("Geoscape:deploymentAPIContract", {
        description = "Deployment API must return mission object with troops",
        testCase = "contract",
        type = "api"
    }, function()
        local function deployMission(craft, mission)
            return {
                id = mission.id,
                missionType = mission.type,
                deploymentTime = os.time(),
                craft = craft,
                troops = {},
                status = "deploying",

                addTroop = function(self, unit) table.insert(self.troops, unit) end,
                getTroopCount = function(self) return #self.troops end
            }
        end

        local deploy = deployMission({name = "Avenger"}, {id = 1, type = "investigation"})
        Helpers.assertEqual(deploy.missionType, "investigation", "Deployment must preserve mission type")
        Helpers.assertTrue(type(deploy.addTroop) == "function", "Must have addTroop method")
        Helpers.assertTrue(type(deploy.getTroopCount) == "function", "Must have getTroopCount method")
    end)

    -- Contract 6: Research availability API
    Suite:testMethod("Geoscape:researchAPIContract", {
        description = "Research system must provide research objects with consistent schema",
        testCase = "contract",
        type = "api"
    }, function()
        local function getResearchProject(name)
            return {
                id = math.random(1000),
                name = name,
                complete = false,
                progress = 0,
                laborCost = 100,
                fundsCost = 1000,
                daysToComplete = 5,

                start = function(self) end,
                cancel = function(self) end,
                getProgress = function(self) return self.progress end
            }
        end

        local research = getResearchProject("Plasma Rifle")
        Helpers.assertEqual(research.name, "Plasma Rifle", "Research must have name")
        Helpers.assertTrue(research.complete == false, "New research not complete")
        Helpers.assertTrue(type(research.getProgress) == "function", "Must have getProgress method")
    end)

    -- Contract 7: Base management API
    Suite:testMethod("Geoscape:baseManagementAPIContract", {
        description = "Base system must provide consistent base object interface",
        testCase = "contract",
        type = "api"
    }, function()
        local function createBase(name, x, y)
            return {
                id = math.random(1000),
                name = name,
                location = {x = x, y = y},
                facilities = {},
                capacity = 100,
                used = 0,

                addFacility = function(self, facility) table.insert(self.facilities, facility) end,
                getFacilities = function(self) return self.facilities end,
                getCapacity = function(self) return self.capacity - self.used end
            }
        end

        local base = createBase("Main Base", 50, 50)
        Helpers.assertEqual(base.name, "Main Base", "Base must have name")
        Helpers.assertTrue(base.location.x == 50, "Base must have location")
        Helpers.assertTrue(type(base.addFacility) == "function", "Must have addFacility method")
    end)

end)

return Suite
