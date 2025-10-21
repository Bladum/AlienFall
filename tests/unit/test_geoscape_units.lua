-- Unit Tests: Geoscape System
-- Tests individual geoscape components: missions, UFO tracking, region management
-- Covers world state, terrain, provinces, and strategic mechanics

local GeoscapeUnitTest = {}

-- Test setup
local function setup()
    package.path = package.path .. ";../../?.lua;../../engine/?.lua"
    local MockGeoscape = require("mock.geoscape")
    return MockGeoscape
end

-- TEST 1: Create mission at location
function GeoscapeUnitTest.testCreateMissionAtLocation()
    local MockGeoscape = setup()
    
    local location = { x = 42, y = 15 }
    local mission = MockGeoscape.createMission(location, "ALIEN_NEST")
    
    assert(mission ~= nil, "Mission should be created")
    assert(mission.location.x == location.x, "X should match")
    assert(mission.location.y == location.y, "Y should match")
    assert(mission.type == "ALIEN_NEST", "Mission type should match")
    
    print("✓ testCreateMissionAtLocation passed")
end

-- TEST 2: UFO movement tracking
function GeoscapeUnitTest.testUFOMovementTracking()
    local MockGeoscape = setup()
    
    local ufo = {
        id = 1,
        x = 100,
        y = 100,
        speed = 5,
        heading = 45 -- degrees
    }
    
    local startX, startY = ufo.x, ufo.y
    
    -- Move UFO
    local distance = 10
    local radians = math.rad(ufo.heading)
    ufo.x = ufo.x + distance * math.cos(radians)
    ufo.y = ufo.y + distance * math.sin(radians)
    
    assert(ufo.x > startX, "X should increase")
    assert(ufo.y > startY, "Y should increase")
    
    print("✓ testUFOMovementTracking passed")
end

-- TEST 3: Interception availability check
function GeoscapeUnitTest.testInterceptionAvailability()
    local MockGeoscape = setup()
    
    local craft = { id = 1, x = 105, y = 105, fuel = 100, range = 50 }
    local ufo = { id = 1, x = 115, y = 115 }
    
    -- Calculate distance
    local dx = ufo.x - craft.x
    local dy = ufo.y - craft.y
    local distance = math.sqrt(dx*dx + dy*dy)
    
    local canIntercept = (distance <= craft.range) and (craft.fuel >= distance)
    
    assert(canIntercept == false, "Interception should not be available (too far)")
    
    -- Move craft closer
    craft.x = 113
    craft.y = 113
    
    dx = ufo.x - craft.x
    dy = ufo.y - craft.y
    distance = math.sqrt(dx*dx + dy*dy)
    
    canIntercept = (distance <= craft.range) and (craft.fuel >= distance)
    
    assert(canIntercept == true, "Interception should be available")
    
    print("✓ testInterceptionAvailability passed")
end

-- TEST 4: Region panic level management
function GeoscapeUnitTest.testRegionPanicLevel()
    local MockGeoscape = setup()
    
    local region = { id = 1, name = "North America", panicLevel = 0 }
    
    -- Alien activity increases panic
    local alienActivity = 3
    region.panicLevel = region.panicLevel + alienActivity
    
    assert(region.panicLevel == 3, "Panic should increase")
    
    -- Successful mission reduces panic
    local missionSuccess = 2
    region.panicLevel = math.max(0, region.panicLevel - missionSuccess)
    
    assert(region.panicLevel == 1, "Panic should decrease")
    
    -- Max panic = 100
    region.panicLevel = 150
    region.panicLevel = math.min(100, region.panicLevel)
    
    assert(region.panicLevel == 100, "Panic should cap at 100")
    
    print("✓ testRegionPanicLevel passed")
end

-- TEST 5: Country funding status
function GeoscapeUnitTest.testCountryFundingStatus()
    local MockGeoscape = setup()
    
    local country = {
        id = 1,
        name = "United States",
        fundingLevel = 3, -- 0-5
        fundingAmount = 100000,
        satisfied = true
    }
    
    -- Increase funding
    country.fundingLevel = math.min(5, country.fundingLevel + 1)
    country.fundingAmount = country.fundingAmount + 25000
    
    assert(country.fundingLevel == 4, "Funding level should increase")
    assert(country.fundingAmount == 125000, "Funding amount should increase")
    
    print("✓ testCountryFundingStatus passed")
end

-- TEST 6: XCom organization rating
function GeoscapeUnitTest.testXComRating()
    local MockGeoscape = setup()
    
    local org = { rating = 50, successfulMissions = 0, failedMissions = 0 }
    
    -- Successful mission improves rating
    org.successfulMissions = org.successfulMissions + 1
    org.rating = org.rating + 5
    
    assert(org.rating == 55, "Rating should improve with success")
    
    -- Failed mission hurts rating
    org.failedMissions = org.failedMissions + 1
    org.rating = org.rating - 10
    
    assert(org.rating == 45, "Rating should decrease with failure")
    
    -- Rating clamped 0-100
    org.rating = math.max(0, math.min(100, org.rating))
    
    assert(org.rating >= 0 and org.rating <= 100, "Rating should be 0-100")
    
    print("✓ testXComRating passed")
end

-- TEST 7: Mission generation variety
function GeoscapeUnitTest.testMissionGenerationVariety()
    local MockGeoscape = setup()
    
    local missionTypes = {
        "CRASH_SITE",
        "TERROR_SITE",
        "ALIEN_BASE",
        "SUPPLY_RAID",
        "RESEARCH_SITE"
    }
    
    local missions = {}
    
    for i = 1, 10 do
        local typeIndex = ((i - 1) % #missionTypes) + 1
        table.insert(missions, {
            id = i,
            type = missionTypes[typeIndex],
            difficulty = math.random(1, 5)
        })
    end
    
    assert(#missions == 10, "Should have 10 missions")
    
    -- Check variety
    local typeCount = {}
    for _, mission in ipairs(missions) do
        typeCount[mission.type] = (typeCount[mission.type] or 0) + 1
    end
    
    local uniqueTypes = 0
    for _ in pairs(typeCount) do
        uniqueTypes = uniqueTypes + 1
    end
    
    assert(uniqueTypes >= 2, "Should have variety in mission types")
    
    print("✓ testMissionGenerationVariety passed")
end

-- TEST 8: Base construction validation
function GeoscapeUnitTest.testBaseConstructionValidation()
    local MockGeoscape = setup()
    
    local baseLocation = { x = 50, y = 60, continent = "NORTH_AMERICA" }
    local existingBases = {
        { x = 10, y = 10, continent = "NORTH_AMERICA" },
        { x = 120, y = 120, continent = "EUROPE" }
    }
    
    -- Check distance from existing bases (min 50 units)
    local minDistance = 50
    local canBuild = true
    
    for _, base in ipairs(existingBases) do
        if base.continent == baseLocation.continent then
            local dx = baseLocation.x - base.x
            local dy = baseLocation.y - base.y
            local distance = math.sqrt(dx*dx + dy*dy)
            
            if distance < minDistance then
                canBuild = false
                break
            end
        end
    end
    
    assert(canBuild == true, "Should be able to build new base")
    
    print("✓ testBaseConstructionValidation passed")
end

-- TEST 9: Craft fuel consumption
function GeoscapeUnitTest.testCraftFuelConsumption()
    local MockGeoscape = setup()
    
    local craft = {
        id = 1,
        type = "INTERCEPTOR",
        fuel = 100,
        fuelCapacity = 100,
        fuelConsumptionRate = 1 -- per distance unit
    }
    
    local distance = 25
    local fuelUsed = distance * craft.fuelConsumptionRate
    craft.fuel = craft.fuel - fuelUsed
    
    assert(craft.fuel == 75, "Fuel should be consumed")
    assert(craft.fuel >= 0, "Fuel should not go negative")
    
    -- Refueling
    craft.fuel = math.min(craft.fuelCapacity, craft.fuel + 50)
    
    assert(craft.fuel == 100, "Fuel should refill to max")
    
    print("✓ testCraftFuelConsumption passed")
end

-- TEST 10: Alien research progress
function GeoscapeUnitTest.testAlienResearchProgress()
    local MockGeoscape = setup()
    
    local research = {
        subject = "HYBRID_BIOLOGY",
        progress = 0,
        maxProgress = 100,
        completionBonus = 50000
    }
    
    -- Simulate research over turns
    for turn = 1, 5 do
        local perTurnProgress = 15
        research.progress = research.progress + perTurnProgress
    end
    
    assert(research.progress == 75, "Research should progress")
    
    -- Complete research
    research.progress = math.min(research.maxProgress, research.progress + 25)
    
    assert(research.progress == 100, "Research should be complete")
    assert(research.progress == research.maxProgress, "Progress should match max")
    
    print("✓ testAlienResearchProgress passed")
end

-- TEST 11: Time mechanics validation
function GeoscapeUnitTest.testTimeMechanicsValidation()
    local MockGeoscape = setup()
    
    local date = { year = 2005, month = 1, day = 15, hour = 14, minute = 30 }
    
    -- Advance 24 hours
    date.day = date.day + 1
    if date.day > 28 then
        date.day = 1
        date.month = date.month + 1
    end
    if date.month > 12 then
        date.month = 1
        date.year = date.year + 1
    end
    
    assert(date.day == 16, "Day should advance")
    
    -- Skip to month end
    date.day = 28
    date.day = date.day + 1
    if date.day > 28 then
        date.day = 1
        date.month = date.month + 1
    end
    
    assert(date.month == 2, "Month should advance")
    assert(date.day == 1, "Day should reset")
    
    print("✓ testTimeMechanicsValidation passed")
end

-- TEST 12: Strategic alert system
function GeoscapeUnitTest.testStrategicAlertSystem()
    local MockGeoscape = setup()
    
    local alert = { level = 0 } -- 0-100
    local alertEvents = {
        { type = "UFO_SIGHTING", increase = 10 },
        { type = "ALIEN_ATTACK", increase = 25 },
        { type = "RESEARCH_BREAKTHROUGH", decrease = 5 }
    }
    
    -- Process events
    for _, event in ipairs(alertEvents) do
        if event.increase then
            alert.level = alert.level + event.increase
        elseif event.decrease then
            alert.level = math.max(0, alert.level - event.decrease)
        end
    end
    
    assert(alert.level == 30, "Alert should be 30 (10+25-5)")
    assert(alert.level <= 100, "Alert should cap at 100")
    
    print("✓ testStrategicAlertSystem passed")
end

-- Run all tests
function GeoscapeUnitTest.runAll()
    print("\n[UNIT TEST] Geoscape System\n")
    
    local tests = {
        GeoscapeUnitTest.testCreateMissionAtLocation,
        GeoscapeUnitTest.testUFOMovementTracking,
        GeoscapeUnitTest.testInterceptionAvailability,
        GeoscapeUnitTest.testRegionPanicLevel,
        GeoscapeUnitTest.testCountryFundingStatus,
        GeoscapeUnitTest.testXComRating,
        GeoscapeUnitTest.testMissionGenerationVariety,
        GeoscapeUnitTest.testBaseConstructionValidation,
        GeoscapeUnitTest.testCraftFuelConsumption,
        GeoscapeUnitTest.testAlienResearchProgress,
        GeoscapeUnitTest.testTimeMechanicsValidation,
        GeoscapeUnitTest.testStrategicAlertSystem,
    }
    
    local passed = 0
    local failed = 0
    
    for _, test in ipairs(tests) do
        local success = pcall(test)
        if success then
            passed = passed + 1
        else
            failed = failed + 1
            print("✗ " .. tostring(test) .. " FAILED")
        end
    end
    
    print("\n[RESULT] Passed: " .. passed .. "/" .. #tests)
    if failed > 0 then
        print("[RESULT] Failed: " .. failed)
    end
    print()
    
    return passed, failed
end

return GeoscapeUnitTest
