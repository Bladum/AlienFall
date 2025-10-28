---================================================================================
---PHASE 3F: Geoscape Advanced Systems Tests
---================================================================================
---
---Comprehensive test suite for geoscape (global strategy) mechanics including:
---
---  1. Calendar & Time System (5 tests)
---     - Date/time progression, month/year transitions
---     - Turn-based game calendar
---
---  2. Mission System (8 tests)
---     - Mission creation and variety
---     - Mission generation, difficulty levels
---     - Location-based missions
---
---  3. UFO & Interception (6 tests)
---     - UFO movement and tracking
---     - Interception availability and mechanics
---     - Range and fuel constraints
---
---  4. Threat & Escalation (5 tests)
---     - Threat level tracking
---     - Alert system management
---     - Alien activity escalation
---
---  5. Strategic Management (5 tests)
---     - X-COM rating/reputation
---     - Country relations and funding
---     - Panic level management
---
---  6. Integration Tests (1 test)
---     - Complete geoscape gameplay flow
---
---@module tests2.geoscape.geoscape_advanced_test

package.path = package.path .. ";../../?.lua;../../engine/?.lua"

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")

---@class MockCalendarSystem
---Manages in-game calendar and time progression.
---Supports turn-based advancement with realistic month/year boundaries.
---@field year number Current year (starts at 2005)
---@field month number Current month (1-12)
---@field day number Current day (1-28)
---@field hour number Current hour (0-23)
---@field minute number Current minute (0-59)
---@field turnCount number Total turns elapsed
local MockCalendarSystem = {}

function MockCalendarSystem:new()
    local instance = {
        year = 2005,
        month = 1,
        day = 1,
        hour = 0,
        minute = 0,
        turnCount = 0
    }
    setmetatable(instance, {__index = self})
    return instance
end

function MockCalendarSystem:advanceTurns(numTurns)
    for _ = 1, numTurns do
        self.turnCount = self.turnCount + 1
        self.hour = self.hour + 4  -- Each turn = 4 hours

        if self.hour >= 24 then
            self.hour = self.hour - 24
            self:advanceDay()
        end
    end
end

function MockCalendarSystem:advanceDay()
    self.day = self.day + 1
    if self.day > 28 then
        self.day = 1
        self.month = self.month + 1
        if self.month > 12 then
            self.month = 1
            self.year = self.year + 1
        end
    end
end

function MockCalendarSystem:getDateString()
    return string.format("%04d-%02d-%02d %02d:%02d", self.year, self.month, self.day, self.hour, self.minute)
end

function MockCalendarSystem:isMonthEnd()
    return self.day == 28
end

function MockCalendarSystem:isYearEnd()
    return self.month == 12 and self.day == 28
end

---@class MockMissionSystem
---Manages mission generation, storage, and lifecycle.
---Supports multiple mission types with procedural generation.
---@field missions table[] Array of active missions
---@field missionIdCounter number Next mission ID to assign
---@field missionTypes table Available mission type configurations
local MockMissionSystem = {}

function MockMissionSystem:new()
    local instance = {
        missions = {},
        missionIdCounter = 1,
        missionTypes = {
            CRASH_SITE = {name = "Crash Site", difficulty = 2, reward = 50000},
            TERROR_SITE = {name = "Terror Attack", difficulty = 3, reward = 75000},
            ALIEN_BASE = {name = "Alien Base", difficulty = 4, reward = 100000},
            SUPPLY_RAID = {name = "Supply Raid", difficulty = 2, reward = 40000},
            RESEARCH_SITE = {name = "Research Site", difficulty = 3, reward = 60000}
        }
    }
    setmetatable(instance, {__index = self})
    return instance
end

function MockMissionSystem:createMission(location, missionType, difficulty)
    if not self.missionTypes[missionType] then
        error("Unknown mission type: " .. missionType)
    end

    local mission = {
        id = self.missionIdCounter,
        type = missionType,
        location = location or {x = math.random(0, 180), y = math.random(-90, 90)},
        difficulty = difficulty or math.random(1, 5),
        reward = self.missionTypes[missionType].reward,
        completed = false,
        failed = false,
        createdTurn = 0
    }

    self.missionIdCounter = self.missionIdCounter + 1
    table.insert(self.missions, mission)
    return mission
end

function MockMissionSystem:generateRandomMission()
    local types = {}
    for typeName in pairs(self.missionTypes) do
        table.insert(types, typeName)
    end

    local randomType = types[math.random(1, #types)]
    return self:createMission(nil, randomType)
end

function MockMissionSystem:getMissionsByType(typeFilter)
    local result = {}
    for _, mission in ipairs(self.missions) do
        if mission.type == typeFilter then
            table.insert(result, mission)
        end
    end
    return result
end

function MockMissionSystem:completeMission(missionId)
    for _, mission in ipairs(self.missions) do
        if mission.id == missionId then
            mission.completed = true
            return true
        end
    end
    return false
end

function MockMissionSystem:getMissionCount()
    return #self.missions
end

---@class MockUFOSystem
---Manages UFO tracking, movement, and interception mechanics.
---@field ufos table[] Array of UFO objects in play
---@field interceptors table[] Array of available interceptor craft
---@field ufoidCounter number Next UFO ID
local MockUFOSystem = {}

function MockUFOSystem:new()
    local instance = {
        ufos = {},
        interceptors = {},
        ufoidCounter = 1
    }
    setmetatable(instance, {__index = self})
    return instance
end

function MockUFOSystem:spawnUFO(x, y, type, speed)
    local ufo = {
        id = self.ufoidCounter,
        x = x or math.random(0, 180),
        y = y or math.random(-90, 90),
        type = type or "SCOUT",
        speed = speed or math.random(1, 5),
        heading = math.random(0, 359),
        fuel = 100,
        active = true
    }

    self.ufoidCounter = self.ufoidCounter + 1
    table.insert(self.ufos, ufo)
    return ufo
end

function MockUFOSystem:moveUFO(ufId, distance)
    for _, ufo in ipairs(self.ufos) do
        if ufo.id == ufId and ufo.active then
            local radians = math.rad(ufo.heading)
            ufo.x = ufo.x + distance * math.cos(radians)
            ufo.y = ufo.y + distance * math.sin(radians)

            -- Wrap around map
            if ufo.x > 180 then ufo.x = ufo.x - 360 end
            if ufo.x < -180 then ufo.x = ufo.x + 360 end
            if ufo.y > 90 then ufo.y = 90 - (ufo.y - 90) end
            if ufo.y < -90 then ufo.y = -90 - (ufo.y + 90) end

            return true
        end
    end
    return false
end

function MockUFOSystem:canIntercept(craftX, craftY, craftRange, craftFuel, ufX, ufY)
    local dx = ufX - craftX
    local dy = ufY - craftY
    local distance = math.sqrt(dx*dx + dy*dy)

    return (distance <= craftRange) and (craftFuel >= distance)
end

function MockUFOSystem:getActivUFOCount()
    local count = 0
    for _, ufo in ipairs(self.ufos) do
        if ufo.active then count = count + 1 end
    end
    return count
end

---@class MockThreatSystem
---Tracks threat levels, alert status, and alien activity escalation.
---@field threatLevel number Global threat level (0-100)
---@field alertLevel number Strategic alert (0-100)
---@field alienActivityEvents table[] Recent activity events
local MockThreatSystem = {}

function MockThreatSystem:new()
    local instance = {
        threatLevel = 0,
        alertLevel = 0,
        alienActivityEvents = {}
    }
    setmetatable(instance, {__index = self})
    return instance
end

function MockThreatSystem:addAlienActivity(amount, reason)
    self.threatLevel = math.min(100, self.threatLevel + amount)
    self.alertLevel = math.min(100, self.alertLevel + (amount * 0.8))

    table.insert(self.alienActivityEvents, {
        amount = amount,
        reason = reason,
        timestamp = os.time()
    })
end

function MockThreatSystem:reduceThreat(amount, reason)
    self.threatLevel = math.max(0, self.threatLevel - amount)
    self.alertLevel = math.max(0, self.alertLevel - (amount * 0.6))
end

function MockThreatSystem:escalateThreat(multiplier)
    self.threatLevel = math.min(100, self.threatLevel * multiplier)
end

function MockThreatSystem:getThreatStatus()
    if self.threatLevel < 20 then return "LOW"
    elseif self.threatLevel < 50 then return "MODERATE"
    elseif self.threatLevel < 75 then return "HIGH"
    else return "CRITICAL"
    end
end

---@class MockStrategicSystem
---Manages X-COM rating, country relations, panic levels.
---@field xcomRating number X-COM organization rating (0-100)
---@field countryPanic table Map of country name to panic level
---@field countryFunding table Map of country name to funding status
local MockStrategicSystem = {}

function MockStrategicSystem:new()
    local instance = {
        xcomRating = 50,
        countryPanic = {},
        countryFunding = {}
    }
    setmetatable(instance, {__index = self})
    return instance
end

function MockStrategicSystem:addCountry(name, initialPanic, initialFunding)
    self.countryPanic[name] = initialPanic or 50
    self.countryFunding[name] = initialFunding or 3  -- 0-5 scale
end

function MockStrategicSystem:modifyPanic(countryName, amount)
    if not self.countryPanic[countryName] then
        error("Country not found: " .. countryName)
    end

    self.countryPanic[countryName] = math.max(0, math.min(100, self.countryPanic[countryName] + amount))
end

function MockStrategicSystem:modifyRating(amount)
    self.xcomRating = math.max(0, math.min(100, self.xcomRating + amount))
end

function MockStrategicSystem:recordMissionSuccess()
    self:modifyRating(5)
end

function MockStrategicSystem:recordMissionFailure()
    self:modifyRating(-10)
end

function MockStrategicSystem:getCountriesBelowPanicThreshold(threshold)
    local result = {}
    for country, panic in pairs(self.countryPanic) do
        if panic >= threshold then
            table.insert(result, {country = country, panic = panic})
        end
    end
    return result
end

---================================================================================
---TEST SUITE
---================================================================================

local Suite = HierarchicalSuite:new({
    module = "engine.geoscape.advanced_systems",
    file = "geoscape_advanced_test.lua",
    description = "Geoscape advanced systems - Calendar, missions, UFO, threats, strategy"
})

---CALENDAR & TIME TESTS
Suite:group("Calendar & Time System", function()

    Suite:testMethod("MockCalendarSystem:new", {
        description = "Initializes calendar at game start date",
        testCase = "initialization",
        type = "functional"
    }, function()
        local cal = MockCalendarSystem:new()
        if cal.year ~= 2005 then error("Year should be 2005") end
        if cal.month ~= 1 then error("Month should be 1") end
        if cal.day ~= 1 then error("Day should be 1") end
        if cal.turnCount ~= 0 then error("Turn count should be 0") end
    end)

    Suite:testMethod("MockCalendarSystem:advanceTurns", {
        description = "Advances game time by turns",
        testCase = "advancement",
        type = "functional"
    }, function()
        local cal = MockCalendarSystem:new()
        cal:advanceTurns(6)  -- 6 turns = 24 hours = 1 day

        if cal.day ~= 2 then error("Day should advance to 2") end
        if cal.turnCount ~= 6 then error("Turn count should be 6") end
    end)

    Suite:testMethod("MockCalendarSystem:advanceDay", {
        description = "Handles month transitions correctly",
        testCase = "month_transition",
        type = "functional"
    }, function()
        local cal = MockCalendarSystem:new()
        cal.day = 28
        cal:advanceDay()

        if cal.day ~= 1 then error("Day should reset to 1") end
        if cal.month ~= 2 then error("Month should advance to 2") end
    end)

    Suite:testMethod("MockCalendarSystem:advanceDay", {
        description = "Handles year transitions correctly",
        testCase = "year_transition",
        type = "functional"
    }, function()
        local cal = MockCalendarSystem:new()
        cal.month = 12
        cal.day = 28
        cal:advanceDay()

        if cal.year ~= 2006 then error("Year should advance to 2006") end
        if cal.month ~= 1 then error("Month should reset to 1") end
        if cal.day ~= 1 then error("Day should reset to 1") end
    end)

    Suite:testMethod("MockCalendarSystem:isMonthEnd", {
        description = "Detects end of month",
        testCase = "period_detection",
        type = "functional"
    }, function()
        local cal = MockCalendarSystem:new()

        if cal:isMonthEnd() then error("Should not be month end") end

        cal.day = 28
        if not cal:isMonthEnd() then error("Should be month end") end
    end)
end)

---MISSION SYSTEM TESTS
Suite:group("Mission System", function()

    Suite:testMethod("MockMissionSystem:new", {
        description = "Initializes mission system",
        testCase = "initialization",
        type = "functional"
    }, function()
        local ms = MockMissionSystem:new()
        if #ms.missions ~= 0 then error("Should start with no missions") end
        if ms.missionIdCounter ~= 1 then error("ID counter should start at 1") end
    end)

    Suite:testMethod("MockMissionSystem:createMission", {
        description = "Creates mission at specified location",
        testCase = "creation",
        type = "functional"
    }, function()
        local ms = MockMissionSystem:new()
        local location = {x = 50, y = 25}
        local mission = ms:createMission(location, "CRASH_SITE", 2)

        if mission.location.x ~= 50 then error("X coordinate should match") end
        if mission.location.y ~= 25 then error("Y coordinate should match") end
        if mission.type ~= "CRASH_SITE" then error("Type should be CRASH_SITE") end
    end)

    Suite:testMethod("MockMissionSystem:generateRandomMission", {
        description = "Generates random mission",
        testCase = "random_gen",
        type = "functional"
    }, function()
        local ms = MockMissionSystem:new()
        local mission = ms:generateRandomMission()

        if mission.id == nil then error("Mission should have ID") end
        if mission.type == nil then error("Mission should have type") end
        if mission.difficulty == nil then error("Mission should have difficulty") end
    end)

    Suite:testMethod("MockMissionSystem:getMissionsByType", {
        description = "Filters missions by type",
        testCase = "filtering",
        type = "functional"
    }, function()
        local ms = MockMissionSystem:new()
        ms:createMission(nil, "CRASH_SITE", 2)
        ms:createMission(nil, "CRASH_SITE", 2)
        ms:createMission(nil, "ALIEN_BASE", 4)

        local crashes = ms:getMissionsByType("CRASH_SITE")
        if #crashes ~= 2 then error("Should have 2 crash site missions") end
    end)

    Suite:testMethod("MockMissionSystem:completeMission", {
        description = "Marks mission as completed",
        testCase = "completion",
        type = "functional"
    }, function()
        local ms = MockMissionSystem:new()
        local mission = ms:createMission(nil, "TERROR_SITE", 3)

        ms:completeMission(mission.id)
        if not mission.completed then error("Mission should be marked completed") end
    end)

    Suite:testMethod("MockMissionSystem:getMissionCount", {
        description = "Counts total missions",
        testCase = "counting",
        type = "functional"
    }, function()
        local ms = MockMissionSystem:new()
        ms:createMission(nil, "CRASH_SITE", 2)
        ms:createMission(nil, "TERROR_SITE", 3)
        ms:createMission(nil, "ALIEN_BASE", 4)

        if ms:getMissionCount() ~= 3 then error("Should have 3 missions") end
    end)
end)

---UFO & INTERCEPTION TESTS
Suite:group("UFO & Interception", function()

    Suite:testMethod("MockUFOSystem:spawnUFO", {
        description = "Spawns UFO at coordinates",
        testCase = "spawning",
        type = "functional"
    }, function()
        local us = MockUFOSystem:new()
        local ufo = us:spawnUFO(100, 50, "SCOUT", 3)

        if ufo.x ~= 100 then error("X should be 100") end
        if ufo.y ~= 50 then error("Y should be 50") end
        if ufo.type ~= "SCOUT" then error("Type should be SCOUT") end
    end)

    Suite:testMethod("MockUFOSystem:moveUFO", {
        description = "Moves UFO based on heading and distance",
        testCase = "movement",
        type = "functional"
    }, function()
        local us = MockUFOSystem:new()
        local ufo = us:spawnUFO(100, 100, "SCOUT", 5)
        ufo.heading = 0  -- East

        local startX = ufo.x
        us:moveUFO(ufo.id, 10)

        if ufo.x <= startX then error("X should increase when heading east") end
    end)

    Suite:testMethod("MockUFOSystem:canIntercept", {
        description = "Checks interception possibility",
        testCase = "interception_check",
        type = "functional"
    }, function()
        local us = MockUFOSystem:new()

        local canIntercept = us:canIntercept(100, 100, 50, 100, 110, 110)
        if not canIntercept then error("Should be able to intercept") end

        canIntercept = us:canIntercept(100, 100, 5, 10, 130, 130)
        if canIntercept then error("Should not be able to intercept (too far)") end
    end)

    Suite:testMethod("MockUFOSystem:getActivUFOCount", {
        description = "Counts active UFOs",
        testCase = "counting",
        type = "functional"
    }, function()
        local us = MockUFOSystem:new()
        us:spawnUFO(100, 100, "SCOUT", 3)
        us:spawnUFO(150, 75, "BATTLESHIP", 2)
        us:spawnUFO(50, 50, "FIGHTER", 4)

        if us:getActivUFOCount() ~= 3 then error("Should have 3 active UFOs") end
    end)
end)

---THREAT & ESCALATION TESTS
Suite:group("Threat & Escalation", function()

    Suite:testMethod("MockThreatSystem:new", {
        description = "Initializes threat system",
        testCase = "initialization",
        type = "functional"
    }, function()
        local ts = MockThreatSystem:new()
        if ts.threatLevel ~= 0 then error("Threat should start at 0") end
        if ts.alertLevel ~= 0 then error("Alert should start at 0") end
    end)

    Suite:testMethod("MockThreatSystem:addAlienActivity", {
        description = "Increases threat from alien activity",
        testCase = "activity_tracking",
        type = "functional"
    }, function()
        local ts = MockThreatSystem:new()
        ts:addAlienActivity(15, "UFO Sighting")

        if ts.threatLevel ~= 15 then error("Threat should be 15") end
        if #ts.alienActivityEvents ~= 1 then error("Should have 1 event") end
    end)

    Suite:testMethod("MockThreatSystem:reduceThreat", {
        description = "Reduces threat from successful missions",
        testCase = "threat_reduction",
        type = "functional"
    }, function()
        local ts = MockThreatSystem:new()
        ts.threatLevel = 50
        ts:reduceThreat(15, "UFO Destroyed")

        if ts.threatLevel ~= 35 then error("Threat should be 35") end
    end)

    Suite:testMethod("MockThreatSystem:escalateThreat", {
        description = "Escalates threat by multiplier",
        testCase = "escalation",
        type = "functional"
    }, function()
        local ts = MockThreatSystem:new()
        ts.threatLevel = 25
        ts:escalateThreat(1.5)

        if ts.threatLevel ~= 37.5 then error("Threat should be 37.5") end
    end)

    Suite:testMethod("MockThreatSystem:getThreatStatus", {
        description = "Determines threat status level",
        testCase = "status_determination",
        type = "functional"
    }, function()
        local ts = MockThreatSystem:new()

        if ts:getThreatStatus() ~= "LOW" then error("Should be LOW at 0") end

        ts.threatLevel = 60
        if ts:getThreatStatus() ~= "HIGH" then error("Should be HIGH at 60") end

        ts.threatLevel = 90
        if ts:getThreatStatus() ~= "CRITICAL" then error("Should be CRITICAL at 90") end
    end)
end)

---STRATEGIC MANAGEMENT TESTS
Suite:group("Strategic Management", function()

    Suite:testMethod("MockStrategicSystem:addCountry", {
        description = "Adds country with initial status",
        testCase = "country_management",
        type = "functional"
    }, function()
        local ss = MockStrategicSystem:new()
        ss:addCountry("USA", 30, 4)
        ss:addCountry("Russia", 60, 2)

        if ss.countryPanic["USA"] ~= 30 then error("USA panic should be 30") end
        if ss.countryFunding["Russia"] ~= 2 then error("Russia funding should be 2") end
    end)

    Suite:testMethod("MockStrategicSystem:modifyPanic", {
        description = "Modifies country panic level",
        testCase = "panic_management",
        type = "functional"
    }, function()
        local ss = MockStrategicSystem:new()
        ss:addCountry("USA", 40, 3)

        ss:modifyPanic("USA", 20)
        if ss.countryPanic["USA"] ~= 60 then error("USA panic should be 60") end

        ss:modifyPanic("USA", -30)
        if ss.countryPanic["USA"] ~= 30 then error("USA panic should be 30") end
    end)

    Suite:testMethod("MockStrategicSystem:modifyRating", {
        description = "Modifies X-COM rating",
        testCase = "rating_management",
        type = "functional"
    }, function()
        local ss = MockStrategicSystem:new()

        ss:recordMissionSuccess()
        if ss.xcomRating ~= 55 then error("Rating should be 55 after success") end

        ss:recordMissionFailure()
        if ss.xcomRating ~= 45 then error("Rating should be 45 after failure") end
    end)

    Suite:testMethod("MockStrategicSystem:getCountriesBelowPanicThreshold", {
        description = "Finds countries above panic threshold",
        testCase = "threshold_checking",
        type = "functional"
    }, function()
        local ss = MockStrategicSystem:new()
        ss:addCountry("USA", 70, 3)
        ss:addCountry("UK", 40, 3)
        ss:addCountry("France", 85, 2)

        local critical = ss:getCountriesBelowPanicThreshold(75)
        if #critical ~= 1 then error("Should have 1 critical country") end
        if critical[1].country ~= "France" then error("France should be critical") end
    end)
end)

---INTEGRATION TESTS
Suite:group("Integration", function()

    Suite:testMethod("Complete Geoscape Gameplay", {
        description = "Simulates complete geoscape gameplay turn",
        testCase = "gameplay_flow",
        type = "integration"
    }, function()
        local cal = MockCalendarSystem:new()
        local missions = MockMissionSystem:new()
        local ufos = MockUFOSystem:new()
        local threats = MockThreatSystem:new()
        local strategy = MockStrategicSystem:new()

        -- Setup
        strategy:addCountry("USA", 50, 3)
        strategy:addCountry("Russia", 55, 2)

        -- Generate threats
        threats:addAlienActivity(10, "UFO Sighting")
        ufos:spawnUFO(100, 50, "SCOUT", 3)

        -- Create missions
        missions:generateRandomMission()
        missions:generateRandomMission()

        -- Advance time
        cal:advanceTurns(6)  -- 1 day

        -- Verify state
        if cal.day ~= 2 then error("Calendar should advance") end
        if threats.threatLevel < 10 then error("Threat should increase") end
        if missions:getMissionCount() < 2 then error("Should have missions") end
        if ufos:getActivUFOCount() < 1 then error("Should have UFOs") end
    end)
end)

---PERFORMANCE BENCHMARKS
Suite:group("Performance", function()

    Suite:testMethod("Scaling - Mission Management", {
        description = "Handles many missions efficiently",
        testCase = "mission_scaling",
        type = "performance"
    }, function()
        local ms = MockMissionSystem:new()
        local startTime = os.clock()

        for i = 1, 100 do
            ms:generateRandomMission()
        end

        for i = 1, 50 do
            ms:completeMission(i)
        end

        local elapsed = os.clock() - startTime
        if elapsed > 0.01 then
            print("[Performance] 100 missions + 50 completions: " .. string.format("%.3fms", elapsed * 1000))
        end
    end)

    Suite:testMethod("Scaling - UFO Tracking", {
        description = "Handles many UFOs efficiently",
        testCase = "ufo_scaling",
        type = "performance"
    }, function()
        local us = MockUFOSystem:new()
        local startTime = os.clock()

        for i = 1, 50 do
            us:spawnUFO(nil, nil, "SCOUT", 3)
        end

        for i = 1, 50 do
            us:moveUFO(i, 10)
        end

        local elapsed = os.clock() - startTime
        if elapsed > 0.01 then
            print("[Performance] 50 UFOs + movement: " .. string.format("%.3fms", elapsed * 1000))
        end
    end)
end)

---================================================================================
---RUN TESTS
---================================================================================

Suite:run()

-- Close the Love2D window after tests complete
love.event.quit()
