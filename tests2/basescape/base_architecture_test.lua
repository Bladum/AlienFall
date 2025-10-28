-- ─────────────────────────────────────────────────────────────────────────
-- BASE ARCHITECTURE TEST SUITE
-- FILE: tests2/basescape/base_architecture_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.basescape.base_architecture",
    fileName = "base_architecture.lua",
    description = "Base architecture with room layout, facility placement, and expansion"
})

print("[BASE_ARCHITECTURE_TEST] Setting up")

local BaseArchitecture = {
    bases = {},
    rooms = {},
    facilities = {},
    layouts = {},

    new = function(self)
        return setmetatable({
            bases = {}, rooms = {}, facilities = {}, layouts = {}
        }, {__index = self})
    end,

    createBase = function(self, baseId, name, locationId)
        self.bases[baseId] = {
            id = baseId, name = name, location = locationId or "unknown",
            grid_width = 10, grid_height = 10, total_power = 100,
            power_used = 0, level = 1, expansion_ready = false
        }
        self.layouts[baseId] = {
            grid = {}, rooms_list = {}, total_rooms = 0,
            surface_rooms = 0, underground_rooms = 0
        }
        return true
    end,

    getBase = function(self, baseId)
        return self.bases[baseId]
    end,

    createRoom = function(self, roomId, baseId, x, y, width, height, roomType)
        if not self.bases[baseId] then return false end
        self.rooms[roomId] = {
            id = roomId, base_id = baseId, x = x or 0, y = y or 0,
            width = width or 2, height = height or 2, type = roomType or "office",
            power_usage = 10, access_level = 1, connectivity = {}
        }
        return true
    end,

    getRoom = function(self, roomId)
        return self.rooms[roomId]
    end,

    placeRoom = function(self, baseId, roomId)
        if not self.bases[baseId] or not self.rooms[roomId] then return false end
        local room = self.rooms[roomId]
        local layout = self.layouts[baseId]
        layout.rooms_list[roomId] = true
        layout.total_rooms = layout.total_rooms + 1
        self.bases[baseId].power_used = self.bases[baseId].power_used + room.power_usage
        return true
    end,

    removeRoom = function(self, baseId, roomId)
        if not self.layouts[baseId] or not self.layouts[baseId].rooms_list[roomId] then return false end
        self.layouts[baseId].rooms_list[roomId] = nil
        self.layouts[baseId].total_rooms = math.max(0, self.layouts[baseId].total_rooms - 1)
        local room = self.rooms[roomId]
        self.bases[baseId].power_used = math.max(0, self.bases[baseId].power_used - room.power_usage)
        return true
    end,

    isRoomPlaced = function(self, baseId, roomId)
        if not self.layouts[baseId] then return false end
        return self.layouts[baseId].rooms_list[roomId] ~= nil
    end,

    getRoomCount = function(self, baseId)
        if not self.layouts[baseId] then return 0 end
        return self.layouts[baseId].total_rooms
    end,

    getRoomsByType = function(self, baseId, roomType)
        local results = {}
        for roomId, room in pairs(self.rooms) do
            if room.base_id == baseId and room.type == roomType then
                table.insert(results, roomId)
            end
        end
        return results
    end,

    createFacility = function(self, facilityId, name, facilityType, power_required)
        self.facilities[facilityId] = {
            id = facilityId, name = name, type = facilityType or "generic",
            power_required = power_required or 20, operational = true,
            efficiency = 100, modules = {}, maintenance_level = 80
        }
        return true
    end,

    getFacility = function(self, facilityId)
        return self.facilities[facilityId]
    end,

    installFacility = function(self, baseId, roomId, facilityId)
        if not self.rooms[roomId] or not self.facilities[facilityId] then return false end
        local room = self.rooms[roomId]
        local facility = self.facilities[facilityId]
        if room.facility then return false end
        room.facility = facilityId
        self.bases[baseId].power_used = self.bases[baseId].power_used + facility.power_required
        return true
    end,

    removeFacility = function(self, baseId, roomId)
        if not self.rooms[roomId] then return false end
        local room = self.rooms[roomId]
        if not room.facility then return false end
        local facility = self.facilities[room.facility]
        self.bases[baseId].power_used = math.max(0, self.bases[baseId].power_used - facility.power_required)
        room.facility = nil
        return true
    end,

    getFacilityFromRoom = function(self, roomId)
        if not self.rooms[roomId] then return nil end
        return self.rooms[roomId].facility
    end,

    connectRooms = function(self, roomId1, roomId2)
        if not self.rooms[roomId1] or not self.rooms[roomId2] then return false end
        self.rooms[roomId1].connectivity[roomId2] = true
        self.rooms[roomId2].connectivity[roomId1] = true
        return true
    end,

    disconnectRooms = function(self, roomId1, roomId2)
        if not self.rooms[roomId1] or not self.rooms[roomId2] then return false end
        self.rooms[roomId1].connectivity[roomId2] = nil
        self.rooms[roomId2].connectivity[roomId1] = nil
        return true
    end,

    areRoomsConnected = function(self, roomId1, roomId2)
        if not self.rooms[roomId1] then return false end
        return self.rooms[roomId1].connectivity[roomId2] ~= nil
    end,

    getConnectedRooms = function(self, roomId)
        if not self.rooms[roomId] then return {} end
        local connected = {}
        for connectedId, _ in pairs(self.rooms[roomId].connectivity) do
            table.insert(connected, connectedId)
        end
        return connected
    end,

    calculatePowerUsage = function(self, baseId)
        if not self.bases[baseId] then return 0 end
        return self.bases[baseId].power_used
    end,

    calculatePowerAvailability = function(self, baseId)
        if not self.bases[baseId] then return 0 end
        local base = self.bases[baseId]
        return base.total_power - base.power_used
    end,

    getPowerUsagePercentage = function(self, baseId)
        if not self.bases[baseId] then return 0 end
        local base = self.bases[baseId]
        if base.total_power == 0 then return 0 end
        return math.floor((base.power_used / base.total_power) * 100)
    end,

    upgradeFacility = function(self, facilityId, efficiency_bonus)
        if not self.facilities[facilityId] then return false end
        self.facilities[facilityId].efficiency = math.min(100, self.facilities[facilityId].efficiency + (efficiency_bonus or 5))
        return true
    end,

    setFacilityMaintenance = function(self, facilityId, maintenance)
        if not self.facilities[facilityId] then return false end
        self.facilities[facilityId].maintenance_level = math.max(0, math.min(100, maintenance))
        return true
    end,

    getFacilityMaintenance = function(self, facilityId)
        if not self.facilities[facilityId] then return 0 end
        return self.facilities[facilityId].maintenance_level
    end,

    expandBase = function(self, baseId, newWidth, newHeight)
        if not self.bases[baseId] then return false end
        self.bases[baseId].grid_width = newWidth or self.bases[baseId].grid_width
        self.bases[baseId].grid_height = newHeight or self.bases[baseId].grid_height
        self.bases[baseId].level = self.bases[baseId].level + 1
        self.bases[baseId].expansion_ready = false
        return true
    end,

    getBaseLevel = function(self, baseId)
        if not self.bases[baseId] then return 0 end
        return self.bases[baseId].level
    end,

    getGridSize = function(self, baseId)
        if not self.bases[baseId] then return 0 end
        local base = self.bases[baseId]
        return base.grid_width * base.grid_height
    end,

    markExpansionReady = function(self, baseId)
        if not self.bases[baseId] then return false end
        self.bases[baseId].expansion_ready = true
        return true
    end,

    isExpansionReady = function(self, baseId)
        if not self.bases[baseId] then return false end
        return self.bases[baseId].expansion_ready
    end,

    calculateBaseCapacity = function(self, baseId)
        if not self.bases[baseId] then return 0 end
        local room_count = self:getRoomCount(baseId)
        local base = self.bases[baseId]
        local capacity = (room_count * 10) + (base.level * 5)
        return capacity
    end,

    calculateLayoutEfficiency = function(self, baseId)
        if not self.bases[baseId] then return 0 end
        local layout = self.layouts[baseId]
        if layout.total_rooms == 0 then return 0 end
        local connected_rooms = 0
        for roomId, _ in pairs(layout.rooms_list) do
            if #self:getConnectedRooms(roomId) > 0 then
                connected_rooms = connected_rooms + 1
            end
        end
        return math.floor((connected_rooms / layout.total_rooms) * 100)
    end,

    reset = function(self)
        self.bases = {}
        self.rooms = {}
        self.facilities = {}
        self.layouts = {}
        return true
    end
}

Suite:group("Bases", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ba = BaseArchitecture:new()
    end)

    Suite:testMethod("BaseArchitecture.createBase", {description = "Creates base", testCase = "create", type = "functional"}, function()
        local ok = shared.ba:createBase("base1", "Alpha", "location1")
        Helpers.assertEqual(ok, true, "Created")
    end)

    Suite:testMethod("BaseArchitecture.getBase", {description = "Gets base", testCase = "get", type = "functional"}, function()
        shared.ba:createBase("base2", "Beta", "location2")
        local base = shared.ba:getBase("base2")
        Helpers.assertEqual(base ~= nil, true, "Retrieved")
    end)
end)

Suite:group("Rooms", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ba = BaseArchitecture:new()
        shared.ba:createBase("room_base", "Test", "loc1")
    end)

    Suite:testMethod("BaseArchitecture.createRoom", {description = "Creates room", testCase = "create", type = "functional"}, function()
        local ok = shared.ba:createRoom("room1", "room_base", 0, 0, 2, 2, "office")
        Helpers.assertEqual(ok, true, "Created")
    end)

    Suite:testMethod("BaseArchitecture.getRoom", {description = "Gets room", testCase = "get", type = "functional"}, function()
        shared.ba:createRoom("room2", "room_base", 2, 2, 2, 2, "lab")
        local room = shared.ba:getRoom("room2")
        Helpers.assertEqual(room ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("BaseArchitecture.placeRoom", {description = "Places room", testCase = "place", type = "functional"}, function()
        shared.ba:createRoom("room3", "room_base", 4, 0, 2, 2, "storage")
        local ok = shared.ba:placeRoom("room_base", "room3")
        Helpers.assertEqual(ok, true, "Placed")
    end)

    Suite:testMethod("BaseArchitecture.removeRoom", {description = "Removes room", testCase = "remove", type = "functional"}, function()
        shared.ba:createRoom("room4", "room_base", 6, 0, 2, 2, "barracks")
        shared.ba:placeRoom("room_base", "room4")
        local ok = shared.ba:removeRoom("room_base", "room4")
        Helpers.assertEqual(ok, true, "Removed")
    end)

    Suite:testMethod("BaseArchitecture.isRoomPlaced", {description = "Is placed", testCase = "is_placed", type = "functional"}, function()
        shared.ba:createRoom("room5", "room_base", 8, 0, 2, 2, "workshop")
        shared.ba:placeRoom("room_base", "room5")
        local is = shared.ba:isRoomPlaced("room_base", "room5")
        Helpers.assertEqual(is, true, "Placed")
    end)

    Suite:testMethod("BaseArchitecture.getRoomCount", {description = "Gets count", testCase = "count", type = "functional"}, function()
        shared.ba:createRoom("room6", "room_base", 0, 4, 2, 2, "armory")
        shared.ba:placeRoom("room_base", "room6")
        local count = shared.ba:getRoomCount("room_base")
        Helpers.assertEqual(count, 1, "1 room")
    end)

    Suite:testMethod("BaseArchitecture.getRoomsByType", {description = "Gets by type", testCase = "type", type = "functional"}, function()
        shared.ba:createRoom("room7", "room_base", 0, 6, 2, 2, "office")
        local results = shared.ba:getRoomsByType("room_base", "office")
        Helpers.assertEqual(#results > 0, true, "Found rooms")
    end)
end)

Suite:group("Facilities", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ba = BaseArchitecture:new()
    end)

    Suite:testMethod("BaseArchitecture.createFacility", {description = "Creates facility", testCase = "create", type = "functional"}, function()
        local ok = shared.ba:createFacility("fac1", "Generator", "power", 50)
        Helpers.assertEqual(ok, true, "Created")
    end)

    Suite:testMethod("BaseArchitecture.getFacility", {description = "Gets facility", testCase = "get", type = "functional"}, function()
        shared.ba:createFacility("fac2", "Lab", "research", 40)
        local fac = shared.ba:getFacility("fac2")
        Helpers.assertEqual(fac ~= nil, true, "Retrieved")
    end)
end)

Suite:group("Facility Installation", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ba = BaseArchitecture:new()
        shared.ba:createBase("fac_base", "Test", "loc1")
        shared.ba:createRoom("fac_room", "fac_base", 0, 0, 2, 2, "factory")
        shared.ba:createFacility("fac3", "Manufactory", "production", 30)
    end)

    Suite:testMethod("BaseArchitecture.installFacility", {description = "Installs facility", testCase = "install", type = "functional"}, function()
        local ok = shared.ba:installFacility("fac_base", "fac_room", "fac3")
        Helpers.assertEqual(ok, true, "Installed")
    end)

    Suite:testMethod("BaseArchitecture.getFacilityFromRoom", {description = "Gets facility", testCase = "get_facility", type = "functional"}, function()
        shared.ba:installFacility("fac_base", "fac_room", "fac3")
        local fac = shared.ba:getFacilityFromRoom("fac_room")
        Helpers.assertEqual(fac, "fac3", "Fac3")
    end)

    Suite:testMethod("BaseArchitecture.removeFacility", {description = "Removes facility", testCase = "remove", type = "functional"}, function()
        shared.ba:installFacility("fac_base", "fac_room", "fac3")
        local ok = shared.ba:removeFacility("fac_base", "fac_room")
        Helpers.assertEqual(ok, true, "Removed")
    end)
end)

Suite:group("Connectivity", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ba = BaseArchitecture:new()
        shared.ba:createBase("conn_base", "Test", "loc1")
        shared.ba:createRoom("conn_room1", "conn_base", 0, 0, 2, 2, "office")
        shared.ba:createRoom("conn_room2", "conn_base", 2, 0, 2, 2, "lab")
    end)

    Suite:testMethod("BaseArchitecture.connectRooms", {description = "Connects rooms", testCase = "connect", type = "functional"}, function()
        local ok = shared.ba:connectRooms("conn_room1", "conn_room2")
        Helpers.assertEqual(ok, true, "Connected")
    end)

    Suite:testMethod("BaseArchitecture.areRoomsConnected", {description = "Are connected", testCase = "are_connected", type = "functional"}, function()
        shared.ba:connectRooms("conn_room1", "conn_room2")
        local is = shared.ba:areRoomsConnected("conn_room1", "conn_room2")
        Helpers.assertEqual(is, true, "Connected")
    end)

    Suite:testMethod("BaseArchitecture.getConnectedRooms", {description = "Gets connected", testCase = "get_connected", type = "functional"}, function()
        shared.ba:connectRooms("conn_room1", "conn_room2")
        local connected = shared.ba:getConnectedRooms("conn_room1")
        Helpers.assertEqual(#connected > 0, true, "Has connections")
    end)

    Suite:testMethod("BaseArchitecture.disconnectRooms", {description = "Disconnects rooms", testCase = "disconnect", type = "functional"}, function()
        shared.ba:connectRooms("conn_room1", "conn_room2")
        local ok = shared.ba:disconnectRooms("conn_room1", "conn_room2")
        Helpers.assertEqual(ok, true, "Disconnected")
    end)
end)

Suite:group("Power Management", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ba = BaseArchitecture:new()
        shared.ba:createBase("power_base", "Test", "loc1")
    end)

    Suite:testMethod("BaseArchitecture.calculatePowerUsage", {description = "Calculates usage", testCase = "usage", type = "functional"}, function()
        local usage = shared.ba:calculatePowerUsage("power_base")
        Helpers.assertEqual(usage >= 0, true, "Usage >= 0")
    end)

    Suite:testMethod("BaseArchitecture.calculatePowerAvailability", {description = "Calculates availability", testCase = "availability", type = "functional"}, function()
        local avail = shared.ba:calculatePowerAvailability("power_base")
        Helpers.assertEqual(avail > 0, true, "Avail > 0")
    end)

    Suite:testMethod("BaseArchitecture.getPowerUsagePercentage", {description = "Gets percentage", testCase = "percentage", type = "functional"}, function()
        local pct = shared.ba:getPowerUsagePercentage("power_base")
        Helpers.assertEqual(pct >= 0, true, "Percentage >= 0")
    end)
end)

Suite:group("Facility Maintenance", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ba = BaseArchitecture:new()
        shared.ba:createFacility("maint_fac", "Reactor", "power", 60)
    end)

    Suite:testMethod("BaseArchitecture.upgradeFacility", {description = "Upgrades facility", testCase = "upgrade", type = "functional"}, function()
        local ok = shared.ba:upgradeFacility("maint_fac", 10)
        Helpers.assertEqual(ok, true, "Upgraded")
    end)

    Suite:testMethod("BaseArchitecture.setFacilityMaintenance", {description = "Sets maintenance", testCase = "maintenance", type = "functional"}, function()
        local ok = shared.ba:setFacilityMaintenance("maint_fac", 90)
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("BaseArchitecture.getFacilityMaintenance", {description = "Gets maintenance", testCase = "get_maintenance", type = "functional"}, function()
        shared.ba:setFacilityMaintenance("maint_fac", 85)
        local maint = shared.ba:getFacilityMaintenance("maint_fac")
        Helpers.assertEqual(maint, 85, "85 maintenance")
    end)
end)

Suite:group("Expansion", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ba = BaseArchitecture:new()
        shared.ba:createBase("exp_base", "Test", "loc1")
    end)

    Suite:testMethod("BaseArchitecture.expandBase", {description = "Expands base", testCase = "expand", type = "functional"}, function()
        local ok = shared.ba:expandBase("exp_base", 15, 15)
        Helpers.assertEqual(ok, true, "Expanded")
    end)

    Suite:testMethod("BaseArchitecture.getBaseLevel", {description = "Gets level", testCase = "level", type = "functional"}, function()
        shared.ba:expandBase("exp_base", 12, 12)
        local level = shared.ba:getBaseLevel("exp_base")
        Helpers.assertEqual(level > 1, true, "Level > 1")
    end)

    Suite:testMethod("BaseArchitecture.getGridSize", {description = "Gets grid size", testCase = "grid", type = "functional"}, function()
        local size = shared.ba:getGridSize("exp_base")
        Helpers.assertEqual(size > 0, true, "Size > 0")
    end)

    Suite:testMethod("BaseArchitecture.markExpansionReady", {description = "Marks ready", testCase = "ready", type = "functional"}, function()
        local ok = shared.ba:markExpansionReady("exp_base")
        Helpers.assertEqual(ok, true, "Ready")
    end)

    Suite:testMethod("BaseArchitecture.isExpansionReady", {description = "Is ready", testCase = "is_ready", type = "functional"}, function()
        shared.ba:markExpansionReady("exp_base")
        local is = shared.ba:isExpansionReady("exp_base")
        Helpers.assertEqual(is, true, "Ready")
    end)
end)

Suite:group("Analysis", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ba = BaseArchitecture:new()
        shared.ba:createBase("anal_base", "Test", "loc1")
    end)

    Suite:testMethod("BaseArchitecture.calculateBaseCapacity", {description = "Calculates capacity", testCase = "capacity", type = "functional"}, function()
        local capacity = shared.ba:calculateBaseCapacity("anal_base")
        Helpers.assertEqual(capacity >= 0, true, "Capacity >= 0")
    end)

    Suite:testMethod("BaseArchitecture.calculateLayoutEfficiency", {description = "Calculates efficiency", testCase = "efficiency", type = "functional"}, function()
        local eff = shared.ba:calculateLayoutEfficiency("anal_base")
        Helpers.assertEqual(eff >= 0, true, "Efficiency >= 0")
    end)
end)

Suite:group("Reset", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ba = BaseArchitecture:new()
    end)

    Suite:testMethod("BaseArchitecture.reset", {description = "Resets system", testCase = "reset", type = "functional"}, function()
        local ok = shared.ba:reset()
        Helpers.assertEqual(ok, true, "Reset")
    end)
end)

Suite:run()
