---Test Basescape Facility System
---
---Quick test of facility system implementation

local BaseManager = require("basescape.systems.base_manager")

-- Initialize
print("\n=== BASESCAPE FACILITY SYSTEM TEST ===\n")

BaseManager.initialize()

-- Create a base
local base = BaseManager.createBase({
    id = "base_alpha",
    name = "Alpha Base",
    provinceId = "province_01",
    regionId = "region_01",
    credits = 1000000,
})

-- Build some facilities
local facilities = {
    {"power_generator", 1, 1},
    {"power_generator", 3, 1},
    {"laboratory", 0, 2},
    {"workshop", 2, 3},
    {"hangar", 0, 3},
    {"medical_bay", 4, 2},
    {"storage_depot", 4, 0},
}

print("\n--- Starting Construction ---\n")
for _, fac_config in ipairs(facilities) do
    local typeId, x, y = fac_config[1], fac_config[2], fac_config[3]
    local facility = base:startConstruction(typeId, x, y)
    if facility then
        print(string.format("✓ %s at (%d,%d)", typeId, x, y))
    else
        print(string.format("✗ %s at (%d,%d) - FAILED", typeId, x, y))
    end
end

-- Debug output
print("\n--- Initial State ---")
base:printDebug()

-- Simulate day progression
print("\n--- Simulating 30 days of construction ---")
for day = 1, 30 do
    base:progressConstructionDay()
end

print("\n--- After 30 Days ---")
base:printDebug()

-- Test capacity system
print("\n--- Testing Capacity Allocation ---")
print(string.format("Item Storage Available: %d", base.capacityManager:getAvailable("item_storage")))
print(string.format("Unit Quarters Available: %d", base.capacityManager:getAvailable("unit_quarters")))

-- Try to allocate
local allocated = base.capacityManager:allocate("item_storage", 50)
print(string.format("Allocated 50 item storage: %s", allocated and "SUCCESS" or "FAILED"))
print(string.format("Item Storage Available Now: %d", base.capacityManager:getAvailable("item_storage")))

-- Test deallocation
base.capacityManager:deallocate("item_storage", 30)
print(string.format("After deallocating 30: %d available", base.capacityManager:getAvailable("item_storage")))

-- Test monthly maintenance
print("\n--- Testing Maintenance ---")
print(string.format("Base credits before: %d", base.credits))
print(string.format("Monthly maintenance: %d", base.monthlyMaintenance))
base:deductMonthlyMaintenance()
print(string.format("Base credits after: %d", base.credits))

-- Test facility damage
print("\n--- Testing Facility Damage ---")
local powerGen = base.grid:getFacilityAt(1, 1)
if powerGen then
    print(string.format("Power gen health: %d/%d", powerGen.health, powerGen.maxHealth))
    powerGen:takeDamage(60)
    print(string.format("After 60 damage: %d/%d (state: %s)", 
        powerGen.health, powerGen.maxHealth, powerGen.state))
    print(string.format("Efficiency: %.0f%%", powerGen.efficiency * 100))
    base:recalculateCapacities()
end

-- Final report
print("\n--- FINAL REPORT ---")
base:printDebug()

print("\n=== TEST COMPLETE ===\n")
