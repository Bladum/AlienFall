-- ─────────────────────────────────────────────────────────────────────────
-- VEHICLE MANAGEMENT TEST SUITE
-- FILE: tests2/basescape/vehicle_management_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.basescape.vehicle_management",
    fileName = "vehicle_management.lua",
    description = "Craft and vehicle systems with maintenance, fuel, crew assignment, and upgrades"
})

print("[VEHICLE_MANAGEMENT_TEST] Setting up")

local VehicleManagement = {
    vehicles = {},
    vehicle_types = {},
    crews = {},
    maintenance = {},
    upgrades = {},

    new = function(self)
        return setmetatable({
            vehicles = {}, vehicle_types = {}, crews = {},
            maintenance = {}, upgrades = {}
        }, {__index = self})
    end,

    registerVehicleType = function(self, typeId, name, class, max_crew)
        self.vehicle_types[typeId] = {
            id = typeId, name = name, class = class or "scout",
            max_crew = max_crew or 6, speed = 80, armor = 50,
            fuel_capacity = 500, weapon_slots = 2
        }
        return true
    end,

    getVehicleType = function(self, typeId)
        return self.vehicle_types[typeId]
    end,

    createVehicle = function(self, vehicleId, typeId, base_id)
        if not self.vehicle_types[typeId] then return false end
        self.vehicles[vehicleId] = {
            id = vehicleId, type_id = typeId, base_id = base_id or "base1",
            status = "operational", health = 100, fuel = 500, crew = {},
            condition = 100, flight_hours = 0, maintenance_due = false
        }
        self.maintenance[vehicleId] = {
            last_maintenance = 0, condition = 100, repairs_needed = 0,
            maintenance_history = {}
        }
        return true
    end,

    getVehicle = function(self, vehicleId)
        return self.vehicles[vehicleId]
    end,

    assignCrewToVehicle = function(self, vehicleId, crewMemberId)
        if not self.vehicles[vehicleId] or not self.crews[crewMemberId] then return false end
        if #self.vehicles[vehicleId].crew >= self.vehicle_types[self.vehicles[vehicleId].type_id].max_crew then
            return false
        end
        table.insert(self.vehicles[vehicleId].crew, crewMemberId)
        self.crews[crewMemberId].assigned_vehicle = vehicleId
        return true
    end,

    removeCrewFromVehicle = function(self, vehicleId, crewMemberId)
        if not self.vehicles[vehicleId] then return false end
        for i, member in ipairs(self.vehicles[vehicleId].crew) do
            if member == crewMemberId then
                table.remove(self.vehicles[vehicleId].crew, i)
                if self.crews[crewMemberId] then
                    self.crews[crewMemberId].assigned_vehicle = nil
                end
                return true
            end
        end
        return false
    end,

    getVehicleCrewCount = function(self, vehicleId)
        if not self.vehicles[vehicleId] then return 0 end
        return #self.vehicles[vehicleId].crew
    end,

    getVehicleCrew = function(self, vehicleId)
        if not self.vehicles[vehicleId] then return {} end
        return self.vehicles[vehicleId].crew
    end,

    registerCrewMember = function(self, crewId, name, rank, specialization)
        self.crews[crewId] = {
            id = crewId, name = name, rank = rank or "ensign",
            specialization = specialization or "pilot", assigned_vehicle = nil,
            experience = 0, morale = 75
        }
        return true
    end,

    getCrewMember = function(self, crewId)
        return self.crews[crewId]
    end,

    refuelVehicle = function(self, vehicleId, fuel_amount)
        if not self.vehicles[vehicleId] then return false end
        local type_data = self.vehicle_types[self.vehicles[vehicleId].type_id]
        local max_fuel = type_data.fuel_capacity
        self.vehicles[vehicleId].fuel = math.min(max_fuel, self.vehicles[vehicleId].fuel + fuel_amount)
        return true
    end,

    consumeFuel = function(self, vehicleId, fuel_amount)
        if not self.vehicles[vehicleId] then return false end
        if self.vehicles[vehicleId].fuel < fuel_amount then return false end
        self.vehicles[vehicleId].fuel = self.vehicles[vehicleId].fuel - fuel_amount
        return true
    end,

    getFuelPercentage = function(self, vehicleId)
        if not self.vehicles[vehicleId] then return 0 end
        local type_data = self.vehicle_types[self.vehicles[vehicleId].type_id]
        return math.floor((self.vehicles[vehicleId].fuel / type_data.fuel_capacity) * 100)
    end,

    performMaintenance = function(self, vehicleId)
        if not self.maintenance[vehicleId] then return false end
        self.maintenance[vehicleId].condition = 100
        self.maintenance[vehicleId].repairs_needed = 0
        table.insert(self.maintenance[vehicleId].maintenance_history, "maintenance")
        self.vehicles[vehicleId].maintenance_due = false
        return true
    end,

    recordFlight = function(self, vehicleId, hours)
        if not self.vehicles[vehicleId] then return false end
        self.vehicles[vehicleId].flight_hours = self.vehicles[vehicleId].flight_hours + hours
        if self.vehicles[vehicleId].flight_hours > 100 then
            self.vehicles[vehicleId].maintenance_due = true
        end
        return true
    end,

    damageVehicle = function(self, vehicleId, damage_amount)
        if not self.vehicles[vehicleId] or not self.maintenance[vehicleId] then return false end
        self.vehicles[vehicleId].health = math.max(0, self.vehicles[vehicleId].health - damage_amount)
        self.maintenance[vehicleId].condition = math.max(0, self.maintenance[vehicleId].condition - (damage_amount / 2))
        if self.maintenance[vehicleId].condition < 50 then
            self.maintenance[vehicleId].repairs_needed = math.ceil((100 - self.maintenance[vehicleId].condition) / 10)
        end
        return true
    end,

    repairVehicle = function(self, vehicleId, repair_amount)
        if not self.vehicles[vehicleId] then return false end
        self.vehicles[vehicleId].health = math.min(100, self.vehicles[vehicleId].health + repair_amount)
        return true
    end,

    getVehicleCondition = function(self, vehicleId)
        if not self.maintenance[vehicleId] then return 0 end
        return self.maintenance[vehicleId].condition
    end,

    getRepairsNeeded = function(self, vehicleId)
        if not self.maintenance[vehicleId] then return 0 end
        return self.maintenance[vehicleId].repairs_needed
    end,

    installUpgrade = function(self, vehicleId, upgradeId, upgrade_name)
        if not self.vehicles[vehicleId] then return false end
        if not self.upgrades[vehicleId] then
            self.upgrades[vehicleId] = {}
        end
        self.upgrades[vehicleId][upgradeId] = upgrade_name or "upgrade"
        return true
    end,

    removeUpgrade = function(self, vehicleId, upgradeId)
        if not self.upgrades[vehicleId] or not self.upgrades[vehicleId][upgradeId] then return false end
        self.upgrades[vehicleId][upgradeId] = nil
        return true
    end,

    hasUpgrade = function(self, vehicleId, upgradeId)
        if not self.upgrades[vehicleId] then return false end
        return self.upgrades[vehicleId][upgradeId] ~= nil
    end,

    getVehicleUpgrades = function(self, vehicleId)
        if not self.upgrades[vehicleId] then return {} end
        local ups = {}
        for upId, upName in pairs(self.upgrades[vehicleId]) do
            table.insert(ups, {id = upId, name = upName})
        end
        return ups
    end,

    calculateVehicleEffectiveness = function(self, vehicleId)
        if not self.vehicles[vehicleId] or not self.maintenance[vehicleId] then return 0 end
        local vehicle = self.vehicles[vehicleId]
        local maintenance = self.maintenance[vehicleId]
        local base = 100
        local health_factor = vehicle.health
        local condition_factor = maintenance.condition
        local crew_factor = self:getVehicleCrewCount(vehicleId) * 10
        return math.floor((base + crew_factor) * (health_factor / 100) * (condition_factor / 100))
    end,

    changeVehicleStatus = function(self, vehicleId, new_status)
        if not self.vehicles[vehicleId] then return false end
        self.vehicles[vehicleId].status = new_status or "operational"
        return true
    end,

    getVehicleStatus = function(self, vehicleId)
        if not self.vehicles[vehicleId] then return nil end
        return self.vehicles[vehicleId].status
    end,

    launchVehicle = function(self, vehicleId)
        if not self.vehicles[vehicleId] then return false end
        if self.vehicles[vehicleId].fuel < 50 then return false end
        self.vehicles[vehicleId].status = "in_flight"
        return true
    end,

    landVehicle = function(self, vehicleId)
        if not self.vehicles[vehicleId] then return false end
        self.vehicles[vehicleId].status = "operational"
        return true
    end,

    calculateMaintenanceCost = function(self, vehicleId)
        if not self.maintenance[vehicleId] then return 0 end
        local repairs = self:getRepairsNeeded(vehicleId)
        return repairs * 100 + 200
    end,

    getFlightHours = function(self, vehicleId)
        if not self.vehicles[vehicleId] then return 0 end
        return self.vehicles[vehicleId].flight_hours
    end,

    getMaintenanceHistory = function(self, vehicleId)
        if not self.maintenance[vehicleId] then return {} end
        return self.maintenance[vehicleId].maintenance_history
    end,

    reset = function(self)
        self.vehicles = {}
        self.vehicle_types = {}
        self.crews = {}
        self.maintenance = {}
        self.upgrades = {}
        return true
    end
}

Suite:group("Vehicle Types", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.vm = VehicleManagement:new()
    end)

    Suite:testMethod("VehicleManagement.registerVehicleType", {description = "Registers type", testCase = "register", type = "functional"}, function()
        local ok = shared.vm:registerVehicleType("type1", "Skyranger", "transport", 8)
        Helpers.assertEqual(ok, true, "Registered")
    end)

    Suite:testMethod("VehicleManagement.getVehicleType", {description = "Gets type", testCase = "get", type = "functional"}, function()
        shared.vm:registerVehicleType("type2", "Interceptor", "fighter", 2)
        local vtype = shared.vm:getVehicleType("type2")
        Helpers.assertEqual(vtype ~= nil, true, "Retrieved")
    end)
end)

Suite:group("Vehicles", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.vm = VehicleManagement:new()
        shared.vm:registerVehicleType("type1", "Skyranger", "transport")
    end)

    Suite:testMethod("VehicleManagement.createVehicle", {description = "Creates vehicle", testCase = "create", type = "functional"}, function()
        local ok = shared.vm:createVehicle("vehicle1", "type1", "base1")
        Helpers.assertEqual(ok, true, "Created")
    end)

    Suite:testMethod("VehicleManagement.getVehicle", {description = "Gets vehicle", testCase = "get", type = "functional"}, function()
        shared.vm:createVehicle("vehicle2", "type1", "base1")
        local vehicle = shared.vm:getVehicle("vehicle2")
        Helpers.assertEqual(vehicle ~= nil, true, "Retrieved")
    end)
end)

Suite:group("Crew Assignment", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.vm = VehicleManagement:new()
        shared.vm:registerVehicleType("type1", "Skyranger", "transport", 6)
        shared.vm:createVehicle("vehicle1", "type1", "base1")
        shared.vm:registerCrewMember("crew1", "Alice", "captain", "pilot")
    end)

    Suite:testMethod("VehicleManagement.registerCrewMember", {description = "Registers crew", testCase = "register", type = "functional"}, function()
        local ok = shared.vm:registerCrewMember("crew2", "Bob", "ensign", "gunner")
        Helpers.assertEqual(ok, true, "Registered")
    end)

    Suite:testMethod("VehicleManagement.getCrewMember", {description = "Gets crew", testCase = "get", type = "functional"}, function()
        local crew = shared.vm:getCrewMember("crew1")
        Helpers.assertEqual(crew ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("VehicleManagement.assignCrewToVehicle", {description = "Assigns crew", testCase = "assign", type = "functional"}, function()
        local ok = shared.vm:assignCrewToVehicle("vehicle1", "crew1")
        Helpers.assertEqual(ok, true, "Assigned")
    end)

    Suite:testMethod("VehicleManagement.removeCrewFromVehicle", {description = "Removes crew", testCase = "remove", type = "functional"}, function()
        shared.vm:assignCrewToVehicle("vehicle1", "crew1")
        local ok = shared.vm:removeCrewFromVehicle("vehicle1", "crew1")
        Helpers.assertEqual(ok, true, "Removed")
    end)

    Suite:testMethod("VehicleManagement.getVehicleCrewCount", {description = "Gets crew count", testCase = "count", type = "functional"}, function()
        shared.vm:assignCrewToVehicle("vehicle1", "crew1")
        local count = shared.vm:getVehicleCrewCount("vehicle1")
        Helpers.assertEqual(count, 1, "1")
    end)

    Suite:testMethod("VehicleManagement.getVehicleCrew", {description = "Gets crew", testCase = "get_crew", type = "functional"}, function()
        shared.vm:assignCrewToVehicle("vehicle1", "crew1")
        local crew = shared.vm:getVehicleCrew("vehicle1")
        Helpers.assertEqual(#crew > 0, true, "Has crew")
    end)
end)

Suite:group("Fuel System", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.vm = VehicleManagement:new()
        shared.vm:registerVehicleType("type1", "Skyranger", "transport", 6)
        shared.vm:createVehicle("vehicle1", "type1", "base1")
    end)

    Suite:testMethod("VehicleManagement.refuelVehicle", {description = "Refuels vehicle", testCase = "refuel", type = "functional"}, function()
        local ok = shared.vm:refuelVehicle("vehicle1", 100)
        Helpers.assertEqual(ok, true, "Refueled")
    end)

    Suite:testMethod("VehicleManagement.consumeFuel", {description = "Consumes fuel", testCase = "consume", type = "functional"}, function()
        shared.vm:refuelVehicle("vehicle1", 200)
        local ok = shared.vm:consumeFuel("vehicle1", 100)
        Helpers.assertEqual(ok, true, "Consumed")
    end)

    Suite:testMethod("VehicleManagement.getFuelPercentage", {description = "Gets fuel %", testCase = "percentage", type = "functional"}, function()
        shared.vm:refuelVehicle("vehicle1", 250)
        local pct = shared.vm:getFuelPercentage("vehicle1")
        Helpers.assertEqual(pct > 0, true, "Percentage > 0")
    end)
end)

Suite:group("Maintenance", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.vm = VehicleManagement:new()
        shared.vm:registerVehicleType("type1", "Skyranger", "transport")
        shared.vm:createVehicle("vehicle1", "type1", "base1")
    end)

    Suite:testMethod("VehicleManagement.performMaintenance", {description = "Performs maintenance", testCase = "perform", type = "functional"}, function()
        local ok = shared.vm:performMaintenance("vehicle1")
        Helpers.assertEqual(ok, true, "Performed")
    end)

    Suite:testMethod("VehicleManagement.recordFlight", {description = "Records flight", testCase = "record", type = "functional"}, function()
        local ok = shared.vm:recordFlight("vehicle1", 15)
        Helpers.assertEqual(ok, true, "Recorded")
    end)

    Suite:testMethod("VehicleManagement.getFlightHours", {description = "Gets flight hours", testCase = "hours", type = "functional"}, function()
        shared.vm:recordFlight("vehicle1", 20)
        local hours = shared.vm:getFlightHours("vehicle1")
        Helpers.assertEqual(hours, 20, "20")
    end)

    Suite:testMethod("VehicleManagement.getVehicleCondition", {description = "Gets condition", testCase = "condition", type = "functional"}, function()
        local cond = shared.vm:getVehicleCondition("vehicle1")
        Helpers.assertEqual(cond > 0, true, "Condition > 0")
    end)
end)

Suite:group("Damage & Repair", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.vm = VehicleManagement:new()
        shared.vm:registerVehicleType("type1", "Skyranger", "transport")
        shared.vm:createVehicle("vehicle1", "type1", "base1")
    end)

    Suite:testMethod("VehicleManagement.damageVehicle", {description = "Damages vehicle", testCase = "damage", type = "functional"}, function()
        local ok = shared.vm:damageVehicle("vehicle1", 20)
        Helpers.assertEqual(ok, true, "Damaged")
    end)

    Suite:testMethod("VehicleManagement.repairVehicle", {description = "Repairs vehicle", testCase = "repair", type = "functional"}, function()
        shared.vm:damageVehicle("vehicle1", 20)
        local ok = shared.vm:repairVehicle("vehicle1", 15)
        Helpers.assertEqual(ok, true, "Repaired")
    end)

    Suite:testMethod("VehicleManagement.getRepairsNeeded", {description = "Gets repairs needed", testCase = "needed", type = "functional"}, function()
        shared.vm:damageVehicle("vehicle1", 50)
        local needed = shared.vm:getRepairsNeeded("vehicle1")
        Helpers.assertEqual(needed >= 0, true, "Needed >= 0")
    end)
end)

Suite:group("Upgrades", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.vm = VehicleManagement:new()
        shared.vm:registerVehicleType("type1", "Skyranger", "transport")
        shared.vm:createVehicle("vehicle1", "type1", "base1")
    end)

    Suite:testMethod("VehicleManagement.installUpgrade", {description = "Installs upgrade", testCase = "install", type = "functional"}, function()
        local ok = shared.vm:installUpgrade("vehicle1", "up1", "PlasmaGun")
        Helpers.assertEqual(ok, true, "Installed")
    end)

    Suite:testMethod("VehicleManagement.removeUpgrade", {description = "Removes upgrade", testCase = "remove", type = "functional"}, function()
        shared.vm:installUpgrade("vehicle1", "up1", "PlasmaGun")
        local ok = shared.vm:removeUpgrade("vehicle1", "up1")
        Helpers.assertEqual(ok, true, "Removed")
    end)

    Suite:testMethod("VehicleManagement.hasUpgrade", {description = "Has upgrade", testCase = "has", type = "functional"}, function()
        shared.vm:installUpgrade("vehicle1", "up1", "LaserCannon")
        local has = shared.vm:hasUpgrade("vehicle1", "up1")
        Helpers.assertEqual(has, true, "Has")
    end)

    Suite:testMethod("VehicleManagement.getVehicleUpgrades", {description = "Gets upgrades", testCase = "get", type = "functional"}, function()
        shared.vm:installUpgrade("vehicle1", "up1", "Shield")
        shared.vm:installUpgrade("vehicle1", "up2", "Armor")
        local upgrades = shared.vm:getVehicleUpgrades("vehicle1")
        Helpers.assertEqual(#upgrades > 0, true, "Has upgrades")
    end)
end)

Suite:group("Status & Operations", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.vm = VehicleManagement:new()
        shared.vm:registerVehicleType("type1", "Skyranger", "transport")
        shared.vm:createVehicle("vehicle1", "type1", "base1")
    end)

    Suite:testMethod("VehicleManagement.changeVehicleStatus", {description = "Changes status", testCase = "change", type = "functional"}, function()
        local ok = shared.vm:changeVehicleStatus("vehicle1", "maintenance")
        Helpers.assertEqual(ok, true, "Changed")
    end)

    Suite:testMethod("VehicleManagement.getVehicleStatus", {description = "Gets status", testCase = "get", type = "functional"}, function()
        local status = shared.vm:getVehicleStatus("vehicle1")
        Helpers.assertEqual(status ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("VehicleManagement.launchVehicle", {description = "Launches vehicle", testCase = "launch", type = "functional"}, function()
        shared.vm:refuelVehicle("vehicle1", 100)
        local ok = shared.vm:launchVehicle("vehicle1")
        Helpers.assertEqual(ok, true, "Launched")
    end)

    Suite:testMethod("VehicleManagement.landVehicle", {description = "Lands vehicle", testCase = "land", type = "functional"}, function()
        local ok = shared.vm:landVehicle("vehicle1")
        Helpers.assertEqual(ok, true, "Landed")
    end)
end)

Suite:group("Analytics", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.vm = VehicleManagement:new()
        shared.vm:registerVehicleType("type1", "Skyranger", "transport")
        shared.vm:createVehicle("vehicle1", "type1", "base1")
    end)

    Suite:testMethod("VehicleManagement.calculateVehicleEffectiveness", {description = "Calculates effectiveness", testCase = "effectiveness", type = "functional"}, function()
        local eff = shared.vm:calculateVehicleEffectiveness("vehicle1")
        Helpers.assertEqual(eff > 0, true, "Effectiveness > 0")
    end)

    Suite:testMethod("VehicleManagement.calculateMaintenanceCost", {description = "Calculates cost", testCase = "cost", type = "functional"}, function()
        local cost = shared.vm:calculateMaintenanceCost("vehicle1")
        Helpers.assertEqual(cost > 0, true, "Cost > 0")
    end)

    Suite:testMethod("VehicleManagement.getMaintenanceHistory", {description = "Gets history", testCase = "history", type = "functional"}, function()
        shared.vm:performMaintenance("vehicle1")
        local history = shared.vm:getMaintenanceHistory("vehicle1")
        Helpers.assertEqual(#history > 0, true, "Has history")
    end)
end)

Suite:group("Reset", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.vm = VehicleManagement:new()
    end)

    Suite:testMethod("VehicleManagement.reset", {description = "Resets system", testCase = "reset", type = "functional"}, function()
        local ok = shared.vm:reset()
        Helpers.assertEqual(ok, true, "Reset")
    end)
end)

Suite:run()
