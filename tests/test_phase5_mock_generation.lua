-- Phase 5 Step 4: Mock Data Generation Test
-- Purpose: Validate mock data generation and entity coverage
-- Run: lua tests/test_phase5_mock_generation.lua

local MockGen = require("tests.mock.mock_generator")

-- ============================================================================
-- TEST SUITE
-- ============================================================================

local TestSuite = {}
TestSuite.tests_run = 0
TestSuite.tests_passed = 0
TestSuite.tests_failed = 0

function TestSuite.assert(condition, message)
    TestSuite.tests_run = TestSuite.tests_run + 1
    if condition then
        TestSuite.tests_passed = TestSuite.tests_passed + 1
        print("  ✓ " .. message)
    else
        TestSuite.tests_failed = TestSuite.tests_failed + 1
        print("  ✗ " .. message)
    end
end

function TestSuite.assertEqual(actual, expected, message)
    TestSuite.assert(actual == expected, message .. " (expected: " .. tostring(expected) .. ", got: " .. tostring(actual) .. ")")
end

function TestSuite.assertTable(tbl, message)
    TestSuite.assert(tbl and type(tbl) == "table", message .. " (got: " .. type(tbl) .. ")")
end

function TestSuite.printSeparator()
    print("")
    print("=" .. string.rep("=", 78))
    print("")
end

-- ============================================================================
-- UNIT TESTS
-- ============================================================================

function TestSuite.testWeaponGeneration()
    print("Testing Weapon Generation...")
    
    for tier = 1, 5 do
        local weapon = MockGen.generateWeapon(tier)
        TestSuite.assertTable(weapon, "Weapon tier " .. tier)
        TestSuite.assert(weapon.id, "Weapon " .. tier .. " has id")
        TestSuite.assert(weapon.name, "Weapon " .. tier .. " has name")
        TestSuite.assert(weapon.damage > 0, "Weapon " .. tier .. " has damage")
        TestSuite.assert(weapon.accuracy > 0, "Weapon " .. tier .. " has accuracy")
    end
    
    local allWeapons = MockGen.generateAllWeapons()
    TestSuite.assertEqual(#allWeapons, 30, "Generated 30 weapons")
end

function TestSuite.testArmorGeneration()
    print("Testing Armor Generation...")
    
    for tier = 1, 5 do
        local armor = MockGen.generateArmor(tier)
        TestSuite.assertTable(armor, "Armor tier " .. tier)
        TestSuite.assert(armor.id, "Armor " .. tier .. " has id")
        TestSuite.assert(armor.protection > 0, "Armor " .. tier .. " has protection")
    end
    
    local allArmors = MockGen.generateAllArmors()
    TestSuite.assertEqual(#allArmors, 20, "Generated 20 armors")
end

function TestSuite.testUnitGeneration()
    print("Testing Unit Generation...")
    
    local humanClass = MockGen.generateUnitClass("human")
    TestSuite.assert(humanClass.side == "human", "Human class has correct side")
    
    local alienClass = MockGen.generateUnitClass("alien")
    TestSuite.assert(alienClass.side == "alien", "Alien class has correct side")
    
    local units = MockGen.generateUnit(50)
    TestSuite.assertEqual(#units, 50, "Generated 50 units")
    
    for _, unit in ipairs(units) do
        TestSuite.assert(unit.id, "Unit has id")
        TestSuite.assert(unit.name, "Unit has name")
        TestSuite.assert(unit.class, "Unit has class")
        TestSuite.assert(unit.health > 0, "Unit has health")
        TestSuite.assertTable(unit.stats, "Unit has stats table")
    end
    
    local allUnits = MockGen.generateAllUnits()
    TestSuite.assert(#allUnits >= 50, "Generated 50+ units")
end

function TestSuite.testFacilityGeneration()
    print("Testing Facility Generation...")
    
    for i = 1, 5 do
        local facility = MockGen.generateFacility()
        TestSuite.assert(facility.id, "Facility " .. i .. " has id")
        TestSuite.assert(facility.type, "Facility " .. i .. " has type")
        TestSuite.assert(facility.cost > 0, "Facility " .. i .. " has cost")
    end
    
    local allFacilities = MockGen.generateAllFacilities()
    TestSuite.assert(#allFacilities >= 45, "Generated 45+ facilities")
end

function TestSuite.testTechnologyGeneration()
    print("Testing Technology Generation...")
    
    for tier = 1, 5 do
        local tech = MockGen.generateTechnology(tier)
        TestSuite.assertTable(tech, "Technology tier " .. tier)
        TestSuite.assert(tech.id, "Tech " .. tier .. " has id")
        TestSuite.assert(tech.research_cost > 0, "Tech " .. tier .. " has research cost")
        TestSuite.assertEqual(tech.tier, tier, "Tech " .. tier .. " has correct tier")
    end
    
    local allTechs = MockGen.generateAllTechnologies()
    TestSuite.assertEqual(#allTechs, 5, "Generated 5 technologies (one per tier)")
end

function TestSuite.testRecipeGeneration()
    print("Testing Recipe Generation...")
    
    for i = 1, 10 do
        local recipe = MockGen.generateRecipe()
        TestSuite.assert(recipe.id, "Recipe " .. i .. " has id")
        TestSuite.assert(recipe.name, "Recipe " .. i .. " has name")
        TestSuite.assert(recipe.time > 0, "Recipe " .. i .. " has time")
        TestSuite.assert(recipe.cost > 0, "Recipe " .. i .. " has cost")
    end
end

function TestSuite.testMissionGeneration()
    print("Testing Mission Generation...")
    
    for difficulty, _ in pairs({ easy = 1, medium = 1, hard = 1, impossible = 1 }) do
        local mission = MockGen.generateMission(difficulty)
        TestSuite.assert(mission.id, "Mission " .. difficulty .. " has id")
        TestSuite.assertEqual(mission.difficulty, difficulty, "Mission has correct difficulty")
        TestSuite.assert(mission.reward_credits > 0, "Mission " .. difficulty .. " has rewards")
    end
    
    local allMissions = MockGen.generateAllMissions()
    TestSuite.assertEqual(#allMissions, 20, "Generated 20 missions")
end

function TestSuite.testObjectiveGeneration()
    print("Testing Objective Generation...")
    
    for i = 1, 5 do
        local objective = MockGen.generateObjective()
        TestSuite.assert(objective.id, "Objective " .. i .. " has id")
        TestSuite.assert(objective.type, "Objective " .. i .. " has type")
    end
end

function TestSuite.testBaseGeneration()
    print("Testing Base Generation...")
    
    for size, _ in pairs({ small = 1, medium = 1, large = 1 }) do
        local base = MockGen.generateBase("Test Base", size)
        TestSuite.assert(base.id, "Base " .. size .. " has id")
        TestSuite.assertEqual(base.size, size, "Base has correct size")
        TestSuite.assert(base.credits > 0, "Base " .. size .. " has credits")
        TestSuite.assert(base.personnel_count > 0, "Base " .. size .. " has personnel")
    end
end

function TestSuite.testResearchProjectGeneration()
    print("Testing Research Project Generation...")
    
    for i = 1, 10 do
        local project = MockGen.generateResearchProject()
        TestSuite.assert(project.id, "Research project " .. i .. " has id")
        TestSuite.assert(project.technology_id, "Research project " .. i .. " has tech")
        TestSuite.assert(project.scientists_assigned > 0, "Research project " .. i .. " has scientists")
    end
end

function TestSuite.testManufacturingProjectGeneration()
    print("Testing Manufacturing Project Generation...")
    
    for i = 1, 10 do
        local project = MockGen.generateManufacturingProject()
        TestSuite.assert(project.id, "Manufacturing project " .. i .. " has id")
        TestSuite.assert(project.recipe_id, "Manufacturing project " .. i .. " has recipe")
        TestSuite.assert(project.quantity_ordered > 0, "Manufacturing project " .. i .. " has quantity")
    end
end

function TestSuite.testItemGeneration()
    print("Testing Item Generation...")
    
    for _, category in ipairs({ "weapon", "armor", "ammunition", "consumable" }) do
        local item = MockGen.generateItem(category)
        TestSuite.assert(item.id, "Item category " .. category .. " has id")
        TestSuite.assert(item.cost > 0, "Item category " .. category .. " has cost")
    end
end

function TestSuite.testSupplierGeneration()
    print("Testing Supplier Generation...")
    
    for _, type in ipairs({ "arms", "medical", "components" }) do
        local supplier = MockGen.generateSupplier(type)
        TestSuite.assert(supplier.id, "Supplier type " .. type .. " has id")
        TestSuite.assert(supplier.name, "Supplier type " .. type .. " has name")
    end
end

function TestSuite.testCombatUnitGeneration()
    print("Testing Combat Unit Generation...")
    
    for side, _ in pairs({ xcom = 1, alien = 1 }) do
        for i = 1, 5 do
            local unit = MockGen.generateCombatUnit(side, i)
            TestSuite.assert(unit.id, "Combat unit " .. side .. " " .. i .. " has id")
            TestSuite.assertEqual(unit.side, side, "Combat unit has correct side")
            TestSuite.assert(unit.health > 0, "Combat unit " .. side .. " " .. i .. " has health")
        end
    end
    
    local allUnits = MockGen.generateAllCombatUnits()
    TestSuite.assertEqual(#allUnits, 20, "Generated 20 combat units (10 per side)")
end

function TestSuite.testBattlefieldGeneration()
    print("Testing Battlefield Generation...")
    
    for i = 1, 5 do
        local battlefield = MockGen.generateBattlefield(30, 30)
        TestSuite.assert(battlefield.id, "Battlefield " .. i .. " has id")
        TestSuite.assertEqual(battlefield.width, 30, "Battlefield " .. i .. " has correct width")
        TestSuite.assertEqual(battlefield.height, 30, "Battlefield " .. i .. " has correct height")
    end
end

function TestSuite.testCombatActionGeneration()
    print("Testing Combat Action Generation...")
    
    local unit = MockGen.generateCombatUnit("xcom", 1)
    
    for actionType, _ in pairs({ move = 1, attack = 1, reload = 1, grenade = 1, standby = 1 }) do
        local action = MockGen.generateCombatAction(unit, actionType)
        TestSuite.assert(action.id, "Combat action " .. actionType .. " has id")
        TestSuite.assertEqual(action.action_type, actionType, "Combat action has correct type")
        TestSuite.assert(action.cost > 0, "Combat action " .. actionType .. " has cost")
    end
end

function TestSuite.testCoverDataGeneration()
    print("Testing Cover Data Generation...")
    
    for i = 1, 10 do
        local cover = MockGen.generateCoverData(15, 15)
        TestSuite.assertTable(cover, "Cover data " .. i)
        TestSuite.assertEqual(cover.position.x, 15, "Cover data " .. i .. " has correct x")
        TestSuite.assertEqual(cover.position.y, 15, "Cover data " .. i .. " has correct y")
    end
end

function TestSuite.testBulkGeneration()
    print("Testing Bulk Generation...")
    
    local allData = MockGen.generateAllMockData({ unitCount = 100 })
    
    TestSuite.assertTable(allData, "All mock data is a table")
    TestSuite.assert(allData.weapons, "Has weapons")
    TestSuite.assert(allData.armors, "Has armors")
    TestSuite.assert(allData.units, "Has units")
    TestSuite.assert(allData.facilities, "Has facilities")
    TestSuite.assert(allData.technologies, "Has technologies")
    TestSuite.assert(allData.missions, "Has missions")
    TestSuite.assert(allData.combat_units, "Has combat units")
    TestSuite.assert(allData.bases, "Has bases")
    
    print("  Generated: " .. tostring(allData.weapons and #allData.weapons or 0) .. " weapons")
    print("  Generated: " .. tostring(allData.armors and #allData.armors or 0) .. " armors")
    print("  Generated: " .. tostring(allData.units and #allData.units or 0) .. " units")
    print("  Generated: " .. tostring(allData.facilities and #allData.facilities or 0) .. " facilities")
end

-- ============================================================================
-- STATISTICS TESTS
-- ============================================================================

function TestSuite.testStatistics()
    print("Testing Statistics...")
    
    local stats = MockGen.getStatistics()
    TestSuite.assertTable(stats, "Statistics table")
    
    local total = 0
    for key, value in pairs(stats) do
        if key ~= "total_entities" then
            TestSuite.assert(value > 0, "Statistics has " .. key .. ": " .. value)
            total = total + value
        end
    end
    
    print("  Total entities: " .. stats.total_entities)
end

-- ============================================================================
-- RUN ALL TESTS
-- ============================================================================

function TestSuite.runAll()
    TestSuite.printSeparator()
    print("PHASE 5 STEP 4: MOCK DATA GENERATION TESTS")
    print("Testing comprehensive mock data generation framework")
    TestSuite.printSeparator()
    
    -- Unit tests
    print("\n[INDIVIDUAL GENERATION TESTS]")
    TestSuite.testWeaponGeneration()
    TestSuite.testArmorGeneration()
    TestSuite.testUnitGeneration()
    TestSuite.testFacilityGeneration()
    TestSuite.testTechnologyGeneration()
    TestSuite.testRecipeGeneration()
    TestSuite.testMissionGeneration()
    TestSuite.testObjectiveGeneration()
    TestSuite.testBaseGeneration()
    TestSuite.testResearchProjectGeneration()
    TestSuite.testManufacturingProjectGeneration()
    TestSuite.testItemGeneration()
    TestSuite.testSupplierGeneration()
    TestSuite.testCombatUnitGeneration()
    TestSuite.testBattlefieldGeneration()
    TestSuite.testCombatActionGeneration()
    TestSuite.testCoverDataGeneration()
    
    -- Collection tests
    print("\n[BULK GENERATION TESTS]")
    TestSuite.testBulkGeneration()
    
    -- Statistics tests
    print("\n[STATISTICS TESTS]")
    TestSuite.testStatistics()
    
    -- Summary
    TestSuite.printSeparator()
    print("TEST SUMMARY")
    print("Tests Run: " .. TestSuite.tests_run)
    print("Tests Passed: " .. TestSuite.tests_passed .. " ✓")
    print("Tests Failed: " .. TestSuite.tests_failed)
    local passRate = (TestSuite.tests_passed / TestSuite.tests_run) * 100
    print("Pass Rate: " .. string.format("%.1f", passRate) .. "%")
    TestSuite.printSeparator()
    
    return TestSuite.tests_failed == 0
end

-- ============================================================================
-- ENTRY POINT
-- ============================================================================

if arg and arg[1] then
    -- Run as script
    local success = TestSuite.runAll()
    os.exit(success and 0 or 1)
else
    -- Return for use as module
    return TestSuite
end
