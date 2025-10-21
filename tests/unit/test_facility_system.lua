-- Unit Tests for Facility System
-- Tests base management, facility construction, and capacity calculations

local FacilitySystemTest = {}

-- Helper to create test instance
local function createTestSystem()
    local FacilitySystem = require("basescape.facilities.facility_system")
    return FacilitySystem.new("test_base")
end

-- Test facility system creation
function FacilitySystemTest.testCreate()
    local system = createTestSystem()
    
    assert(system ~= nil, "Facility system not created")
    assert(system.baseId == "test_base", "Base ID not set")
    assert(system.facilities ~= nil, "Facilities table missing")
    assert(system.constructionQueue ~= nil, "Construction queue missing")
    assert(system.capacity ~= nil, "Capacity table missing")
    
    print("✓ testCreate passed")
end

-- Test HQ building (mandatory first facility)
function FacilitySystemTest.testBuildHQ()
    local system = createTestSystem()
    
    system:buildMandatoryHQ()
    
    -- Check HQ was built
    local hq = system:getFacilityAt(2, 2)
    assert(hq ~= nil, "HQ not built")
    assert(hq.typeId == "ACCESS_LIFT", "Wrong facility type for HQ")
    assert(hq.construction.complete == true, "HQ not marked complete")
    
    print("✓ testBuildHQ passed")
end

-- Test valid position checking
function FacilitySystemTest.testValidPosition()
    local system = createTestSystem()
    system:buildMandatoryHQ()
    
    -- Position should be invalid if occupied
    assert(not system:isValidPosition(2, 2), "Occupied position marked valid")
    
    -- Adjacent position should be valid
    assert(system:isValidPosition(3, 2), "Adjacent position marked invalid")
    assert(system:isValidPosition(1, 2), "Adjacent position marked invalid")
    
    -- Out of bounds should be invalid
    assert(not system:isValidPosition(-1, 0), "Out of bounds marked valid")
    assert(not system:isValidPosition(10, 10), "Out of bounds marked valid")
    
    print("✓ testValidPosition passed")
end

-- Test facility construction
function FacilitySystemTest.testConstruction()
    local FacilityTypes = require("basescape.facilities.facility_types")
    local system = createTestSystem()
    system:buildMandatoryHQ()
    
    -- Get facility definition
    local definition = FacilityTypes.get("LIVING_QUARTERS")
    assert(definition ~= nil, "Facility definition not found")
    
    -- Start construction
    local order = system:startConstruction("LIVING_QUARTERS", 1, 2, definition)
    
    assert(order ~= nil, "Construction not started")
    assert(order.typeId == "LIVING_QUARTERS", "Wrong facility type")
    assert(order.x == 1 and order.y == 2, "Wrong position")
    assert(order.daysRemaining > 0, "No construction time")
    
    print("✓ testConstruction passed")
end

-- Test construction completion
function FacilitySystemTest.testConstructionCompletion()
    local FacilityTypes = require("basescape.facilities.facility_types")
    local system = createTestSystem()
    system:buildMandatoryHQ()
    
    local definition = FacilityTypes.get("LIVING_QUARTERS")
    local order = system:startConstruction("LIVING_QUARTERS", 1, 2, definition)
    
    -- Complete construction manually
    system:completeConstruction(order)
    
    -- Check facility exists
    local facility = system:getFacilityAt(1, 2)
    assert(facility ~= nil, "Facility not built after completion")
    assert(facility.typeId == "LIVING_QUARTERS", "Wrong facility type")
    assert(facility.construction.complete == true, "Not marked complete")
    
    print("✓ testConstructionCompletion passed")
end

-- Test daily construction processing
function FacilitySystemTest.testDailyConstruction()
    local FacilityTypes = require("basescape.facilities.facility_types")
    local system = createTestSystem()
    system:buildMandatoryHQ()
    
    local definition = FacilityTypes.get("LIVING_QUARTERS")
    local order = system:startConstruction("LIVING_QUARTERS", 1, 2, definition)
    
    local initialDays = order.daysRemaining
    
    -- Process one day
    system:processDailyConstruction()
    
    -- Check days decreased
    local queue = system:getConstructionQueue()
    if #queue > 0 then
        assert(queue[1].daysRemaining < initialDays, "Days not decremented")
    else
        -- Construction completed
        local facility = system:getFacilityAt(1, 2)
        assert(facility ~= nil, "Facility not built after completion")
    end
    
    print("✓ testDailyConstruction passed")
end

-- Test capacity calculation
function FacilitySystemTest.testCapacityCalculation()
    local FacilityTypes = require("basescape.facilities.facility_types")
    local system = createTestSystem()
    system:buildMandatoryHQ()
    
    -- Add living quarters
    local definition = FacilityTypes.get("LIVING_QUARTERS")
    local order = system:startConstruction("LIVING_QUARTERS", 1, 2, definition)
    system:completeConstruction(order)
    
    -- Recalculate capacities
    system:recalculateCapacities()
    
    -- Check soldier capacity increased
    local soldierCap = system:getCapacity("soldiers")
    assert(soldierCap > 0, "Soldier capacity not increased")
    
    print("✓ testCapacityCalculation passed")
end

-- Test facility damage
function FacilitySystemTest.testDamage()
    local system = createTestSystem()
    system:buildMandatoryHQ()
    
    local facility = system:getFacilityAt(2, 2)
    local initialHp = facility.hp
    
    -- Damage facility
    system:damageFacility(2, 2, 50)
    
    assert(facility.hp < initialHp, "Facility not damaged")
    
    -- Heavy damage should make it non-operational
    system:damageFacility(2, 2, 500)
    assert(facility.hp <= 0, "Facility not destroyed")
    
    print("✓ testDamage passed")
end

-- Test service availability
function FacilitySystemTest.testServices()
    local FacilityTypes = require("basescape.facilities.facility_types")
    local system = createTestSystem()
    system:buildMandatoryHQ()
    
    -- Initially no lab service
    assert(not system:hasService("RESEARCH"), "Research service shouldn't exist")
    
    -- Add laboratory
    local labDef = FacilityTypes.get("LABORATORY")
    if labDef then
        local order = system:startConstruction("LABORATORY", 1, 2, labDef)
        system:completeConstruction(order)
        system:recalculateCapacities()
        
        -- Now should have research service
        assert(system:hasService("RESEARCH"), "Research service not available")
    end
    
    print("✓ testServices passed")
end

-- Test maintenance cost calculation
function FacilitySystemTest.testMaintenance()
    local FacilityTypes = require("basescape.facilities.facility_types")
    local system = createTestSystem()
    system:buildMandatoryHQ()
    
    local initialMaintenance = system:getMonthlyMaintenance()
    
    -- Add facility with maintenance cost
    local definition = FacilityTypes.get("LIVING_QUARTERS")
    local order = system:startConstruction("LIVING_QUARTERS", 1, 2, definition)
    system:completeConstruction(order)
    
    local newMaintenance = system:getMonthlyMaintenance()
    assert(newMaintenance > initialMaintenance, "Maintenance not increased")
    
    print("✓ testMaintenance passed")
end

-- Test operational facilities count
function FacilitySystemTest.testOperationalFacilities()
    local system = createTestSystem()
    system:buildMandatoryHQ()
    
    local operational = system:getOperationalFacilities()
    assert(#operational == 1, "Should have 1 operational facility (HQ)")
    
    -- Damage HQ
    system:damageFacility(2, 2, 500)
    
    operational = system:getOperationalFacilities()
    assert(#operational == 0, "Damaged facility still operational")
    
    print("✓ testOperationalFacilities passed")
end

-- Run all tests
function FacilitySystemTest.runAll()
    print("\n=== Facility System Tests ===")
    
    FacilitySystemTest.testCreate()
    FacilitySystemTest.testBuildHQ()
    FacilitySystemTest.testValidPosition()
    FacilitySystemTest.testConstruction()
    FacilitySystemTest.testConstructionCompletion()
    FacilitySystemTest.testDailyConstruction()
    FacilitySystemTest.testCapacityCalculation()
    FacilitySystemTest.testDamage()
    FacilitySystemTest.testServices()
    FacilitySystemTest.testMaintenance()
    FacilitySystemTest.testOperationalFacilities()
    
    print("✓ All Facility System tests passed!\n")
end

return FacilitySystemTest



