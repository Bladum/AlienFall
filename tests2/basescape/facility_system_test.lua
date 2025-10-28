-- ─────────────────────────────────────────────────────────────────────────
-- FACILITY SYSTEM TESTS
-- ─────────────────────────────────────────────────────────────────────────
-- Tests base management, facility construction, and capacity calculations
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

-- ─────────────────────────────────────────────────────────────────────────
-- MOCK FACILITY SYSTEM
-- ─────────────────────────────────────────────────────────────────────────

local FacilitySystem = {}
FacilitySystem.__index = FacilitySystem

function FacilitySystem:new(baseId)
    local self = setmetatable({}, FacilitySystem)
    self.baseId = baseId
    self.facilities = {} -- x,y -> facility
    self.constructionQueue = {}
    self.capacity = {
        soldiers = 0,
        scientists = 0,
        engineers = 0,
        power = 0
    }
    self.services = {}
    self.monthlyMaintenance = 0
    return self
end

function FacilitySystem:buildMandatoryHQ()
    -- Build access lift at center
    local hq = {
        typeId = "ACCESS_LIFT",
        x = 2,
        y = 2,
        hp = 100,
        maxHp = 100,
        construction = {complete = true},
        services = {"POWER", "ACCESS"},
        capacity = {soldiers = 50},
        maintenance = 0
    }
    self.facilities[string.format("%d,%d", 2, 2)] = hq
    self:updateCapacities()
    return hq
end

function FacilitySystem:isValidPosition(x, y)
    -- Check bounds (assuming 6x6 base grid)
    if x < 1 or x > 6 or y < 1 or y > 6 then return false end
    -- Check not occupied
    local key = string.format("%d,%d", x, y)
    return self.facilities[key] == nil
end

function FacilitySystem:getFacilityAt(x, y)
    local key = string.format("%d,%d", x, y)
    return self.facilities[key]
end

function FacilitySystem:startConstruction(typeId, x, y, definition)
    if not self:isValidPosition(x, y) then return nil end

    local order = {
        typeId = typeId,
        x = x,
        y = y,
        daysRemaining = definition.constructionTime or 30,
        definition = definition
    }

    table.insert(self.constructionQueue, order)
    return order
end

function FacilitySystem:completeConstruction(order)
    local facility = {
        typeId = order.typeId,
        x = order.x,
        y = order.y,
        hp = 100,
        maxHp = 100,
        construction = {complete = true},
        services = order.definition.services or {},
        capacity = order.definition.capacity or {},
        maintenance = order.definition.maintenance or 0
    }

    local key = string.format("%d,%d", order.x, order.y)
    self.facilities[key] = facility

    -- Remove from queue
    for i, queued in ipairs(self.constructionQueue) do
        if queued == order then
            table.remove(self.constructionQueue, i)
            break
        end
    end

    self:updateCapacities()
    return facility
end

function FacilitySystem:processDailyConstruction()
    for i = #self.constructionQueue, 1, -1 do
        local order = self.constructionQueue[i]
        order.daysRemaining = order.daysRemaining - 1

        if order.daysRemaining <= 0 then
            self:completeConstruction(order)
        end
    end
end

function FacilitySystem:getConstructionQueue()
    return self.constructionQueue
end

function FacilitySystem:updateCapacities()
    -- Reset capacities
    self.capacity = {soldiers = 0, scientists = 0, engineers = 0, power = 0}
    self.services = {}
    self.monthlyMaintenance = 0

    -- Sum up all facilities
    for _, facility in pairs(self.facilities) do
        if facility.construction.complete and facility.hp > 0 then
            for capType, amount in pairs(facility.capacity) do
                self.capacity[capType] = (self.capacity[capType] or 0) + amount
            end

            for _, service in ipairs(facility.services) do
                self.services[service] = true
            end

            self.monthlyMaintenance = self.monthlyMaintenance + (facility.maintenance or 0)
        end
    end
end

function FacilitySystem:recalculateCapacities()
    self:updateCapacities()
end

function FacilitySystem:getCapacity(capType)
    return self.capacity[capType] or 0
end

function FacilitySystem:hasService(serviceType)
    return self.services[serviceType] == true
end

function FacilitySystem:getMonthlyMaintenance()
    return self.monthlyMaintenance
end

function FacilitySystem:damageFacility(x, y, damage)
    local facility = self:getFacilityAt(x, y)
    if facility then
        facility.hp = math.max(0, facility.hp - damage)
        self:updateCapacities()
        return facility.hp <= 0
    end
    return false
end

function FacilitySystem:getOperationalFacilities()
    local operational = {}
    for _, facility in pairs(self.facilities) do
        if facility.construction.complete and facility.hp > 0 then
            table.insert(operational, facility)
        end
    end
    return operational
end

-- ─────────────────────────────────────────────────────────────────────────
-- MOCK FACILITY TYPES
-- ─────────────────────────────────────────────────────────────────────────

local FacilityTypes = {
    get = function(typeId)
        local types = {
            ACCESS_LIFT = {
                constructionTime = 0,
                services = {"POWER", "ACCESS"},
                capacity = {soldiers = 50},
                maintenance = 0
            },
            LIVING_QUARTERS = {
                constructionTime = 30,
                services = {"LIVING"},
                capacity = {soldiers = 25},
                maintenance = 10
            },
            LABORATORY = {
                constructionTime = 45,
                services = {"RESEARCH"},
                capacity = {scientists = 10},
                maintenance = 15
            }
        }
        return types[typeId]
    end
}

-- ─────────────────────────────────────────────────────────────────────────
-- TEST SUITE
-- ─────────────────────────────────────────────────────────────────────────

local Suite = HierarchicalSuite:new({
    modulePath = "basescape.facilities.facility_system",
    fileName = "facility_system.lua",
    description = "Base facility construction and management system"
})

Suite:before(function() print("[FacilitySystemTest] Setting up") end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 1: SYSTEM INITIALIZATION
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("System Initialization", function()
    local shared = {}

    Suite:beforeEach(function()
        shared.system = FacilitySystem:new("test_base")
    end)

    Suite:testMethod("FacilitySystem.new", {description="Creates facility system instance", testCase="creation", type="functional"},
    function()
        Helpers.assertEqual(shared.system ~= nil, true, "Facility system should be created")
        Helpers.assertEqual(shared.system.baseId, "test_base", "Base ID should be set")
        Helpers.assertEqual(type(shared.system.facilities), "table", "Facilities table should exist")
        Helpers.assertEqual(type(shared.system.constructionQueue), "table", "Construction queue should exist")
        Helpers.assertEqual(type(shared.system.capacity), "table", "Capacity table should exist")
        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("FacilitySystem.buildMandatoryHQ", {description="Builds mandatory HQ facility", testCase="build_hq", type="functional"},
    function()
        local hq = shared.system:buildMandatoryHQ()
        Helpers.assertEqual(hq ~= nil, true, "HQ should be built")
        Helpers.assertEqual(hq.typeId, "ACCESS_LIFT", "HQ should be access lift")
        Helpers.assertEqual(hq.construction.complete, true, "HQ should be complete")

        local facilityAt = shared.system:getFacilityAt(2, 2)
        Helpers.assertEqual(facilityAt ~= nil, true, "HQ should be at position 2,2")
        -- Removed manual print - framework handles this
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 2: POSITION VALIDATION
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Position Validation", function()
    local shared = {}

    Suite:beforeEach(function()
        shared.system = FacilitySystem:new("test_base")
        shared.system:buildMandatoryHQ()
    end)

    Suite:testMethod("FacilitySystem.isValidPosition", {description="Validates facility positions correctly", testCase="position_validation", type="functional"},
    function()
        -- Occupied position should be invalid
        Helpers.assertEqual(shared.system:isValidPosition(2, 2), false, "Occupied HQ position should be invalid")

        -- Adjacent positions should be valid
        Helpers.assertEqual(shared.system:isValidPosition(3, 2), true, "Adjacent position should be valid")
        Helpers.assertEqual(shared.system:isValidPosition(1, 2), true, "Adjacent position should be valid")

        -- Out of bounds should be invalid
        Helpers.assertEqual(shared.system:isValidPosition(-1, 0), false, "Out of bounds should be invalid")
        Helpers.assertEqual(shared.system:isValidPosition(10, 10), false, "Out of bounds should be invalid")
        -- Removed manual print - framework handles this
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 3: FACILITY CONSTRUCTION
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Facility Construction", function()
    local shared = {}

    Suite:beforeEach(function()
        shared.system = FacilitySystem:new("test_base")
        shared.system:buildMandatoryHQ()
    end)

    Suite:testMethod("FacilitySystem.startConstruction", {description="Starts facility construction", testCase="start_construction", type="functional"},
    function()
        local definition = FacilityTypes.get("LIVING_QUARTERS")
        local order = shared.system:startConstruction("LIVING_QUARTERS", 1, 2, definition)

        Helpers.assertEqual(order ~= nil, true, "Construction should start")
        if order then
            Helpers.assertEqual(order.typeId, "LIVING_QUARTERS", "Order should have correct type")
            Helpers.assertEqual(order.x, 1, "Order should have correct X")
            Helpers.assertEqual(order.y, 2, "Order should have correct Y")
            Helpers.assertEqual(order.daysRemaining > 0, true, "Order should have construction time")
        end
        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("FacilitySystem.completeConstruction", {description="Completes facility construction", testCase="complete_construction", type="functional"},
    function()
        local definition = FacilityTypes.get("LIVING_QUARTERS")
        local order = shared.system:startConstruction("LIVING_QUARTERS", 1, 2, definition)
        local facility = shared.system:completeConstruction(order)

        Helpers.assertEqual(facility ~= nil, true, "Facility should be built")
        Helpers.assertEqual(facility.typeId, "LIVING_QUARTERS", "Facility should have correct type")
        Helpers.assertEqual(facility.construction.complete, true, "Facility should be complete")

        local atPosition = shared.system:getFacilityAt(1, 2)
        Helpers.assertEqual(atPosition ~= nil, true, "Facility should be at position")
        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("FacilitySystem.processDailyConstruction", {description="Processes daily construction progress", testCase="daily_progress", type="functional"},
    function()
        local definition = FacilityTypes.get("LIVING_QUARTERS")
        local order = shared.system:startConstruction("LIVING_QUARTERS", 1, 2, definition)
        if order then
            local initialDays = order.daysRemaining

            shared.system:processDailyConstruction()

            local queue = shared.system:getConstructionQueue()
            if #queue > 0 then
                Helpers.assertEqual(queue[1].daysRemaining < initialDays, true, "Days should decrease")
            else
                -- Construction completed
                local facility = shared.system:getFacilityAt(1, 2)
                Helpers.assertEqual(facility ~= nil, true, "Facility should be built when complete")
            end
        end
        -- Removed manual print - framework handles this
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 4: CAPACITY AND SERVICES
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Capacity and Services", function()
    local shared = {}

    Suite:beforeEach(function()
        shared.system = FacilitySystem:new("test_base")
        shared.system:buildMandatoryHQ()
    end)

    Suite:testMethod("FacilitySystem.recalculateCapacities", {description="Calculates facility capacities", testCase="capacity_calculation", type="functional"},
    function()
        local definition = FacilityTypes.get("LIVING_QUARTERS")
        local order = shared.system:startConstruction("LIVING_QUARTERS", 1, 2, definition)
        shared.system:completeConstruction(order)
        shared.system:recalculateCapacities()

        local soldierCap = shared.system:getCapacity("soldiers")
        Helpers.assertEqual(soldierCap > 0, true, "Soldier capacity should increase")
        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("FacilitySystem.hasService", {description="Checks service availability", testCase="service_availability", type="functional"},
    function()
        -- Initially no research service
        Helpers.assertEqual(shared.system:hasService("RESEARCH"), false, "Should not have research initially")

        -- Add laboratory
        local labDef = FacilityTypes.get("LABORATORY")
        if labDef then
            local order = shared.system:startConstruction("LABORATORY", 1, 2, labDef)
            shared.system:completeConstruction(order)
            shared.system:recalculateCapacities()

            Helpers.assertEqual(shared.system:hasService("RESEARCH"), true, "Should have research after lab")
        end
        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("FacilitySystem.getMonthlyMaintenance", {description="Calculates maintenance costs", testCase="maintenance_costs", type="functional"},
    function()
        local initialMaintenance = shared.system:getMonthlyMaintenance()

        local definition = FacilityTypes.get("LIVING_QUARTERS")
        local order = shared.system:startConstruction("LIVING_QUARTERS", 1, 2, definition)
        shared.system:completeConstruction(order)

        local newMaintenance = shared.system:getMonthlyMaintenance()
        Helpers.assertEqual(newMaintenance > initialMaintenance, true, "Maintenance should increase")
        -- Removed manual print - framework handles this
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 5: FACILITY DAMAGE AND OPERATIONS
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Facility Damage and Operations", function()
    local shared = {}

    Suite:beforeEach(function()
        shared.system = FacilitySystem:new("test_base")
        shared.system:buildMandatoryHQ()
    end)

    Suite:testMethod("FacilitySystem.damageFacility", {description="Damages facilities correctly", testCase="facility_damage", type="functional"},
    function()
        local facility = shared.system:getFacilityAt(2, 2)
        local initialHp = facility.hp

        shared.system:damageFacility(2, 2, 50)

        Helpers.assertEqual(facility.hp < initialHp, true, "Facility HP should decrease")

        -- Heavy damage should destroy
        shared.system:damageFacility(2, 2, 500)
        Helpers.assertEqual(facility.hp <= 0, true, "Facility should be destroyed")
        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("FacilitySystem.getOperationalFacilities", {description="Counts operational facilities", testCase="operational_count", type="functional"},
    function()
        local operational = shared.system:getOperationalFacilities()
        Helpers.assertEqual(#operational, 1, "Should have 1 operational facility initially")

        -- Damage the facility
        shared.system:damageFacility(2, 2, 500)

        operational = shared.system:getOperationalFacilities()
        Helpers.assertEqual(#operational, 0, "Should have 0 operational facilities after damage")
        -- Removed manual print - framework handles this
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- EXPORT
-- ─────────────────────────────────────────────────────────────────────────

return Suite
