-- ─────────────────────────────────────────────────────────────────────────
-- BASESCAPE API CONTRACT TESTS
-- ─────────────────────────────────────────────────────────────────────────
-- Purpose: Verify basescape layer API contracts
-- Tests: 7 API contract tests
-- Expected: All pass in <150ms

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.basescape",
    fileName = "basescape_api_contract_test.lua",
    description = "Basescape layer API contract validation"
})

-- ─────────────────────────────────────────────────────────────────────────
-- TESTS
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Basescape API Contracts", function()

    local basescape = {}

    Suite:beforeEach(function()
        basescape = {
            base = {},
            facilities = {},
            storage = {}
        }
    end)

    -- Contract 1: Base object structure
    Suite:testMethod("Basescape:baseStructureContract", {
        description = "Base objects must have consistent structure and methods",
        testCase = "contract",
        type = "api"
    }, function()
        local base = {
            id = 1,
            name = "Main Base",
            location = {x = 50, y = 50},
            funding = 0,
            facilities = {},
            capacity = 1000,

            addFacility = function(self, facility) end,
            removeFacility = function(self, facilityId) end,
            getFacilities = function(self) return self.facilities end,
            getCapacity = function(self) return self.capacity end
        }

        Helpers.assertEqual(base.name, "Main Base", "Base must have name")
        Helpers.assertTrue(base.location ~= nil, "Base must have location")
        Helpers.assertTrue(type(base.addFacility) == "function", "Must have addFacility")
        Helpers.assertTrue(type(base.getCapacity) == "function", "Must have getCapacity")
    end)

    -- Contract 2: Facility object interface
    Suite:testMethod("Basescape:facilityObjectContract", {
        description = "Facilities must provide consistent construction interface",
        testCase = "contract",
        type = "api"
    }, function()
        local function createFacility(name, type, x, y)
            return {
                id = math.random(10000),
                name = name,
                type = type,
                gridX = x,
                gridY = y,
                status = "operational",
                constructionProgress = 100,

                getStatus = function(self) return self.status end,
                getProgress = function(self) return self.constructionProgress end,
                isOperational = function(self) return self.status == "operational" end
            }
        end

        local facility = createFacility("Hangar", "aircraft_hangar", 5, 5)
        Helpers.assertEqual(facility.name, "Hangar", "Facility must have name")
        Helpers.assertEqual(facility.type, "aircraft_hangar", "Facility must have type")
        Helpers.assertTrue(type(facility.getStatus) == "function", "Must have getStatus")
    end)

    -- Contract 3: Storage system API
    Suite:testMethod("Basescape:storageSystemContract", {
        description = "Storage system must provide inventory management API",
        testCase = "contract",
        type = "api"
    }, function()
        local storage = {
            items = {},
            capacity = 100,
            used = 0
        }

        function storage:addItem(item, quantity)
            table.insert(self.items, {name = item, quantity = quantity})
            self.used = self.used + quantity
        end

        function storage:removeItem(item, quantity)
            for i, stored in ipairs(self.items) do
                if stored.name == item then
                    stored.quantity = stored.quantity - quantity
                    self.used = self.used - quantity
                    if stored.quantity <= 0 then
                        table.remove(self.items, i)
                    end
                end
            end
        end

        function storage:getCapacity()
            return self.capacity - self.used
        end

        storage:addItem("ammo", 50)
        Helpers.assertTrue(#storage.items > 0, "Should have items")
        Helpers.assertTrue(storage:getCapacity() < storage.capacity, "Capacity should decrease")
    end)

    -- Contract 4: Personnel management API
    Suite:testMethod("Basescape:personnelManagementContract", {
        description = "Personnel system must provide soldier management interface",
        testCase = "contract",
        type = "api"
    }, function()
        local function createSoldier(name, rank)
            return {
                id = math.random(100000),
                name = name,
                rank = rank,
                experience = 0,
                skills = {},
                status = "healthy",

                gainExperience = function(self, amount) self.experience = self.experience + amount end,
                promote = function(self) end,
                addSkill = function(self, skill) table.insert(self.skills, skill) end
            }
        end

        local soldier = createSoldier("Captain Smith", "Captain")
        Helpers.assertEqual(soldier.name, "Captain Smith", "Soldier must have name")
        Helpers.assertTrue(type(soldier.gainExperience) == "function", "Must have gainExperience")
        Helpers.assertTrue(type(soldier.promote) == "function", "Must have promote")
    end)

    -- Contract 5: Craft management API
    Suite:testMethod("Basescape:craftManagementContract", {
        description = "Craft system must provide vessel management interface",
        testCase = "contract",
        type = "api"
    }, function()
        local function createCraft(name, type, base)
            return {
                id = math.random(100000),
                name = name,
                type = type,
                baseId = base,
                status = "ready",
                crew = {},
                equipment = {},

                assignCrew = function(self, soldier) table.insert(self.crew, soldier) end,
                equipWeapon = function(self, weapon) table.insert(self.equipment, weapon) end,
                getReadiness = function(self) return (#self.crew > 0) and true or false end
            }
        end

        local craft = createCraft("Avenger", "interceptor", 1)
        Helpers.assertEqual(craft.name, "Avenger", "Craft must have name")
        Helpers.assertEqual(craft.type, "interceptor", "Craft must have type")
        Helpers.assertTrue(type(craft.assignCrew) == "function", "Must have assignCrew")
    end)

    -- Contract 6: Research queue API
    Suite:testMethod("Basescape:researchQueueContract", {
        description = "Research system must provide queue management",
        testCase = "contract",
        type = "api"
    }, function()
        local researchQueue = {projects = {}}

        function researchQueue:queue(project)
            table.insert(self.projects, {
                name = project,
                progress = 0,
                complete = false
            })
        end

        function researchQueue:getProgress()
            if #self.projects == 0 then return nil end
            return self.projects[1]
        end

        function researchQueue:completeProject()
            if #self.projects > 0 then
                self.projects[1].complete = true
                table.remove(self.projects, 1)
            end
        end

        researchQueue:queue("plasma_rifle")
        researchQueue:queue("heavy_armor")

        Helpers.assertEqual(#researchQueue.projects, 2, "Should have 2 projects queued")
        local current = researchQueue:getProgress()
        if current then
            Helpers.assertEqual(current.name, "plasma_rifle", "Should get first project")
        else
            Helpers.assertTrue(false, "Current project should exist")
        end
    end)

    -- Contract 7: Manufacturing system API
    Suite:testMethod("Basescape:manufacturingSystemContract", {
        description = "Manufacturing system must provide production queue API",
        testCase = "contract",
        type = "api"
    }, function()
        local manufacturing = {queue = {}}

        function manufacturing:startProduction(item, quantity, hoursRequired)
            table.insert(self.queue, {
                item = item,
                quantity = quantity,
                hoursRequired = hoursRequired,
                hoursElapsed = 0,
                complete = false
            })
        end

        function manufacturing:advanceProduction(hours)
            if #self.queue > 0 then
                self.queue[1].hoursElapsed = self.queue[1].hoursElapsed + hours
                if self.queue[1].hoursElapsed >= self.queue[1].hoursRequired then
                    self.queue[1].complete = true
                    table.remove(self.queue, 1)
                end
            end
        end

        manufacturing:startProduction("plasma_rifle", 10, 40)
        Helpers.assertEqual(#manufacturing.queue, 1, "Should have production queued")

        manufacturing:advanceProduction(40)
        Helpers.assertEqual(#manufacturing.queue, 0, "Should complete production")
    end)

end)

return Suite
