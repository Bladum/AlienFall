-- Country Manager Tests
--
-- Comprehensive unit and integration tests for the country management system.
-- Tests cover: initialization, funding calculation, panic mechanics, state updates,
-- and country collapse handling.

-- Set up package path for engine modules
package.path = package.path .. ";../../?.lua;../../engine/?.lua"

local CountryManager = require("geoscape.country.country_manager")

-- Test helper functions
local function createTestCountryData()
    return {
        {
            id = "usa",
            name = "United States",
            nation_type = "MAJOR",
            gdp = 100,
            military_power = 10,
            region = "north_america",
            capital_province = "usa_central",
            starting_relation = 20,
            base_funding_level = 6,
            territories = {"usa_west", "usa_central", "usa_east"}
        },
        {
            id = "germany",
            name = "Germany",
            nation_type = "SECONDARY",
            gdp = 50,
            military_power = 7,
            region = "europe",
            capital_province = "germany_central",
            starting_relation = 10,
            base_funding_level = 5,
            territories = {"germany_north", "germany_central", "germany_south"}
        },
        {
            id = "japan",
            name = "Japan",
            nation_type = "SECONDARY",
            gdp = 55,
            military_power = 8,
            region = "asia_pacific",
            capital_province = "japan_main",
            starting_relation = 15,
            base_funding_level = 6,
            territories = {"japan_honshu", "japan_hokkaido"}
        }
    }
end

local function test_initialization()
    print("\n[TEST] Country initialization")

    local manager = CountryManager.new()
    local data = createTestCountryData()

    local success = manager:init(data)
    assert(success, "Initialization should succeed")

    local countries = manager:getAllCountries()
    assert(#countries == 3, "Should load 3 countries")

    local usa = manager:getCountry("usa")
    assert(usa ~= nil, "Should find USA")
    assert(usa.name == "United States", "USA name should match")
    assert(usa.panic == 0, "Initial panic should be 0")
    assert(usa.relation == 20, "Initial relation should match definition")
    assert(usa.funding_level == 6, "Initial funding level should match")

    print("[PASS] Country initialization")
end

local function test_funding_calculation()
    print("\n[TEST] Funding calculation")

    local manager = CountryManager.new()
    manager:init(createTestCountryData())

    -- Test formula: funding = gdp * funding_level * (0.5 + relation/100 * 0.5)
    -- USA: 100 * 6 * (0.5 + 20/100 * 0.5) = 100 * 6 * 0.6 = 360
    local usaFunding = manager:calculateFunding("usa")
    assert(usaFunding == 360, "USA funding should be 360, got " .. usaFunding)

    -- Germany: 50 * 5 * (0.5 + 10/100 * 0.5) = 50 * 5 * 0.55 = 137.5 -> 138
    local germanyFunding = manager:calculateFunding("germany")
    assert(germanyFunding == 138, "Germany funding should be 138, got " .. germanyFunding)

    -- Test total funding
    local totalFunding = manager:getTotalFunding()
    assert(totalFunding > 0, "Total funding should be positive")

    print("[PASS] Funding calculation")
end

local function test_panic_mechanics()
    print("\n[TEST] Panic mechanics")

    local manager = CountryManager.new()
    manager:init(createTestCountryData())

    local usa = manager:getCountry("usa")
    assert(usa.panic == 0, "Initial panic should be 0")

    -- Add panic
    local newPanic, collapsed = manager:modifyPanic("usa", 25, "Test panic increase")
    assert(newPanic == 25, "Panic should be 25, got " .. newPanic)
    assert(not collapsed, "Should not collapse yet")
    assert(usa.morale < 100, "Morale should decrease with panic")

    -- Add more panic
    manager:modifyPanic("usa", 30, "More panic")
    assert(usa.panic == 55, "Panic should be 55")

    -- Subtract panic
    manager:modifyPanic("usa", -10, "Panic reduction")
    assert(usa.panic == 45, "Panic should be 45 after reduction")

    -- Test panic clamping (min/max)
    manager:modifyPanic("usa", -100, "Negative panic")
    assert(usa.panic >= 0, "Panic should not go below 0")

    print("[PASS] Panic mechanics")
end

local function test_country_collapse()
    print("\n[TEST] Country collapse mechanics")

    local manager = CountryManager.new()
    manager:init(createTestCountryData())

    local usa = manager:getCountry("usa")
    assert(not usa.is_collapsed, "Should not be collapsed initially")

    -- Set panic to collapse threshold
    manager:modifyPanic("usa", 105, "Trigger collapse")

    -- Check collapse
    local isCollapsed = manager:checkCountryCollapse("usa")
    assert(isCollapsed, "Should detect collapse")
    assert(usa.is_collapsed, "is_collapsed flag should be set")
    assert(usa.funding_level == 0, "Funding should be 0 when collapsed")
    assert(usa.morale == 0, "Morale should be 0 when collapsed")

    -- Collapsed country should have no funding
    local collapsedFunding = manager:calculateFunding("usa")
    assert(collapsedFunding == 0, "Collapsed country should provide 0 funding")

    print("[PASS] Country collapse mechanics")
end

local function test_country_lookup()
    print("\n[TEST] Country lookup functions")

    local manager = CountryManager.new()
    manager:init(createTestCountryData())

    -- Lookup by type
    local majors = manager:getCountriesByType("MAJOR")
    assert(#majors == 1, "Should find 1 major power")

    local secondaries = manager:getCountriesByType("SECONDARY")
    assert(#secondaries == 2, "Should find 2 secondary powers")

    -- Lookup by region
    local americas = manager:getCountriesByRegion("north_america")
    assert(#americas == 1, "Should find 1 country in north_america")

    local europe = manager:getCountriesByRegion("europe")
    assert(#europe == 1, "Should find 1 country in europe")

    -- Lookup by relation range
    local allies = manager:getCountriesByRelation(10, 100)
    assert(#allies == 3, "Should find 3 allied/positive countries")

    local hostile = manager:getCountriesByRelation(-100, -50)
    assert(#hostile == 0, "Should find 0 hostile countries")

    print("[PASS] Country lookup functions")
end

local function test_state_updates()
    print("\n[TEST] Country state updates")

    local manager = CountryManager.new()
    manager:init(createTestCountryData())

    local usa = manager:getCountry("usa")

    -- Update state
    manager:updateCountryState("usa", {
        stability = 85,
        military_readiness = 90,
        morale = 70
    })

    assert(usa.stability == 85, "Stability should be updated")
    assert(usa.military_readiness == 90, "Military readiness should be updated")
    assert(usa.morale == 70, "Morale should be updated")

    -- Test clamping (0-100)
    manager:updateCountryState("usa", {
        stability = 150
    })
    assert(usa.stability == 100, "Stability should be clamped to 100")

    manager:updateCountryState("usa", {
        military_readiness = -50
    })
    assert(usa.military_readiness == 0, "Military readiness should be clamped to 0")

    print("[PASS] Country state updates")
end

local function test_serialization()
    print("\n[TEST] Serialization/deserialization")

    local manager1 = CountryManager.new()
    manager1:init(createTestCountryData())

    local usa1 = manager1:getCountry("usa")
    usa1.panic = 45
    usa1.funding_level = 8
    usa1.morale = 60
    usa1.missions_completed = 12
    usa1.ufos_defeated = 3

    -- Serialize
    local saveData = manager1:serialize()
    assert(saveData["usa"] ~= nil, "USA data should be in serialized data")
    assert(saveData["usa"].panic == 45, "Panic should be serialized")
    assert(saveData["usa"].missions_completed == 12, "Missions completed should be serialized")

    -- Create new manager and deserialize
    local manager2 = CountryManager.new()
    manager2:init(createTestCountryData())
    manager2:deserialize(saveData)

    local usa2 = manager2:getCountry("usa")
    assert(usa2.panic == 45, "Panic should be restored")
    assert(usa2.funding_level == 8, "Funding level should be restored")
    assert(usa2.morale == 60, "Morale should be restored")
    assert(usa2.missions_completed == 12, "Missions completed should be restored")
    assert(usa2.ufos_defeated == 3, "UFOs defeated should be restored")

    print("[PASS] Serialization/deserialization")
end

local function test_daily_updates()
    print("\n[TEST] Daily state updates")

    local manager = CountryManager.new()
    manager:init(createTestCountryData())

    local usa = manager:getCountry("usa")
    manager:modifyPanic("usa", 50, "Initial panic")

    local initialPanic = usa.panic

    -- Update with 7 days
    manager:updateDailyState(7)

    -- Panic should decay
    assert(usa.panic < initialPanic, "Panic should decrease over time")

    -- Military readiness should decay slightly
    local initialReadiness = usa.military_readiness
    manager:updateDailyState(30)
    assert(usa.military_readiness <= initialReadiness, "Military readiness should decrease")

    print("[PASS] Daily state updates")
end

local function test_status_report()
    print("\n[TEST] Country status report")

    local manager = CountryManager.new()
    manager:init(createTestCountryData())

    manager:modifyPanic("usa", 40, "Test panic")

    local status = manager:getCountryStatus("usa")
    assert(status ~= nil, "Status should be returned")
    assert(status.id == "usa", "Status ID should be USA")
    assert(status.name == "United States", "Status name should match")
    assert(status.panic == 40, "Status panic should be 40")
    assert(status.status_label == "Friendly", "Status label should be Friendly (relation 20)")
    assert(status.panic_label == "Moderate", "Panic label should be Moderate")
    assert(status.funding > 0, "Funding should be calculated")

    print("[PASS] Country status report")
end

local function test_mission_tracking()
    print("\n[TEST] Mission tracking")

    local manager = CountryManager.new()
    manager:init(createTestCountryData())

    local usa = manager:getCountry("usa")
    assert(usa.missions_completed == 0, "Initial missions completed should be 0")
    assert(usa.missions_failed == 0, "Initial missions failed should be 0")

    -- Record successful mission
    manager:recordMission("usa", true)
    assert(usa.missions_completed == 1, "Missions completed should be 1")

    -- Record another success
    manager:recordMission("usa", true)
    assert(usa.missions_completed == 2, "Missions completed should be 2")

    -- Record failure
    manager:recordMission("usa", false)
    assert(usa.missions_failed == 1, "Missions failed should be 1")

    print("[PASS] Mission tracking")
end

local function test_ufo_defeat_tracking()
    print("\n[TEST] UFO defeat tracking and panic reduction")

    local manager = CountryManager.new()
    manager:init(createTestCountryData())

    local usa = manager:getCountry("usa")

    -- Set initial panic
    manager:modifyPanic("usa", 50, "Initial panic for UFO test")
    local panicBefore = usa.panic

    -- Record UFO defeat
    manager:recordUFODefeat("usa", 5)  -- Threat level 5

    assert(usa.ufos_defeated == 1, "UFOs defeated should be 1")
    assert(usa.panic < panicBefore, "Panic should decrease after UFO defeat")

    print("[PASS] UFO defeat tracking and panic reduction")
end

-- Run all tests
local function run_all_tests()
    print("=== Country Manager Unit Tests ===")

    test_initialization()
    test_funding_calculation()
    test_panic_mechanics()
    test_country_collapse()
    test_country_lookup()
    test_state_updates()
    test_serialization()
    test_daily_updates()
    test_status_report()
    test_mission_tracking()
    test_ufo_defeat_tracking()

    print("\n=== All Country Manager Tests Passed ===\n")
end

-- Export tests
return {
    run_all_tests = run_all_tests,
    test_initialization = test_initialization,
    test_funding_calculation = test_funding_calculation,
    test_panic_mechanics = test_panic_mechanics,
    test_country_collapse = test_country_collapse,
    test_country_lookup = test_country_lookup,
    test_state_updates = test_state_updates,
    test_serialization = test_serialization,
    test_daily_updates = test_daily_updates,
    test_status_report = test_status_report,
    test_mission_tracking = test_mission_tracking,
    test_ufo_defeat_tracking = test_ufo_defeat_tracking,
}
