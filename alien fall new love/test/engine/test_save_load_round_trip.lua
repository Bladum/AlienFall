--- Test Save/Load Round-Trip
-- Comprehensive tests for save/load data integrity and determinism
--
-- Tests verify that data survives round-trip save/load operations
-- and that RNG determinism is preserved

local SaveLoadSystem = require("engine.save_load_system")

local TestSaveLoad = {}

---Create a mock game state for testing
---@return table gameState Mock game state
function TestSaveLoad._createMockGameState()
    return {
        playTime = 12345,
        difficulty = "normal",
        
        world = {
            currentWorld = "earth",
            provinces = {
                {id = "province_1", name = "Test Province", population = 1000000},
                {id = "province_2", name = "Another Province", population = 500000}
            },
            countries = {
                {id = "country_1", name = "Test Country", funding = 100000}
            },
            regions = {},
            portals = {},
            illumination = {dayProgress = 0.5}
        },
        
        bases = {
            base_1 = {
                id = "base_1",
                name = "Main Base",
                location = {x = 100, y = 200},
                facilities = {
                    {id = "barracks", level = 2},
                    {id = "laboratory", level = 1}
                },
                personnel = {soldiers = 12, scientists = 8, engineers = 6},
                storage = {items = {}, capacity = 100},
                production = {}
            }
        },
        
        units = {
            unit_1 = {
                id = "unit_1",
                name = "Soldier Alpha",
                class = "assault",
                stats = {health = 80, maxHealth = 100, timeUnits = 60, accuracy = 75},
                inventory = {
                    weapon = "assault_rifle",
                    armor = "tactical_vest",
                    items = {"medkit", "grenade"}
                },
                experience = 1500,
                injuries = {},
                location = "base_1"
            },
            unit_2 = {
                id = "unit_2",
                name = "Soldier Bravo",
                class = "sniper",
                stats = {health = 100, maxHealth = 100, timeUnits = 55, accuracy = 90},
                inventory = {weapon = "sniper_rifle", armor = "light_armor"},
                experience = 2000,
                injuries = {},
                location = "base_1"
            }
        },
        
        economy = {
            credits = 500000,
            income = 50000,
            expenses = 25000,
            monthlyReport = {
                income_sources = {funding = 50000},
                expense_categories = {salaries = 20000, maintenance = 5000}
            }
        },
        
        research = {
            completed = {"laser_weapons", "alien_alloys"},
            inProgress = {
                plasma_rifles = {progress = 250, required = 500, scientists = 4}
            },
            available = {"advanced_tactics", "ufo_navigation"}
        },
        
        missions = {
            mission_1 = {
                id = "mission_1",
                type = "ufo_crash",
                location = {provinceId = "province_1", x = 150, y = 250},
                status = "available",
                expires = 1234567890,
                rewards = {credits = 10000, fame = 50}
            }
        },
        
        rng = {
            masterSeed = 42,
            scopes = {
                combat = {seed = 12345, state = {1, 2, 3, 4}},
                missions = {seed = 67890, state = {5, 6, 7, 8}}
            }
        },
        
        turnManager = {
            currentTurn = 100,
            currentDate = {year = 2018, quarter = 2, month = 5, week = 2, day = 10},
            eventQueue = {
                {turn = 105, event = "research_complete", data = {researchId = "plasma_rifles"}},
                {turn = 110, event = "mission_expires", data = {missionId = "mission_1"}}
            }
        }
    }
end

---Test basic save and load
function TestSaveLoad.test_basic_save_load()
    local saveSystem = SaveLoadSystem()
    
    -- Create mock state
    local originalState = TestSaveLoad._createMockGameState()
    
    -- Save
    local saveSuccess, saveError = saveSystem:save("test_slot_basic", originalState)
    assert(saveSuccess, "Save should succeed: " .. tostring(saveError))
    
    -- Load
    local loadedState, loadError = saveSystem:load("test_slot_basic")
    assert(loadedState, "Load should succeed: " .. tostring(loadError))
    
    -- Verify metadata
    assert(loadedState.metadata, "Loaded state should have metadata")
    assert(loadedState.metadata.version, "Metadata should have version")
    
    -- Cleanup
    saveSystem:deleteSave("test_slot_basic")
    
    print("✓ Basic save/load test passed")
    return true
end

---Test world state round-trip
function TestSaveLoad.test_world_round_trip()
    local saveSystem = SaveLoadSystem()
    local originalState = TestSaveLoad._createMockGameState()
    
    -- Save and load
    saveSystem:save("test_world", originalState)
    local loadedState = saveSystem:load("test_world")
    
    -- Verify world data
    assert(loadedState.world, "World should exist")
    assert(loadedState.world.currentWorld == "earth", "Current world should match")
    assert(#loadedState.world.provinces == 2, "Should have 2 provinces")
    assert(loadedState.world.provinces[1].id == "province_1", "Province ID should match")
    assert(loadedState.world.provinces[1].population == 1000000, "Population should match")
    
    -- Cleanup
    saveSystem:deleteSave("test_world")
    
    print("✓ World round-trip test passed")
    return true
end

---Test unit state round-trip
function TestSaveLoad.test_units_round_trip()
    local saveSystem = SaveLoadSystem()
    local originalState = TestSaveLoad._createMockGameState()
    
    -- Save and load
    saveSystem:save("test_units", originalState)
    local loadedState = saveSystem:load("test_units")
    
    -- Verify unit data
    assert(loadedState.units, "Units should exist")
    assert(loadedState.units.unit_1, "Unit 1 should exist")
    assert(loadedState.units.unit_1.name == "Soldier Alpha", "Unit name should match")
    assert(loadedState.units.unit_1.stats.health == 80, "Unit health should match")
    assert(loadedState.units.unit_1.experience == 1500, "Unit experience should match")
    assert(loadedState.units.unit_1.inventory.weapon == "assault_rifle", "Weapon should match")
    assert(#loadedState.units.unit_1.inventory.items == 2, "Should have 2 items")
    
    -- Cleanup
    saveSystem:deleteSave("test_units")
    
    print("✓ Units round-trip test passed")
    return true
end

---Test economy state round-trip
function TestSaveLoad.test_economy_round_trip()
    local saveSystem = SaveLoadSystem()
    local originalState = TestSaveLoad._createMockGameState()
    
    -- Save and load
    saveSystem:save("test_economy", originalState)
    local loadedState = saveSystem:load("test_economy")
    
    -- Verify economy data
    assert(loadedState.economy, "Economy should exist")
    assert(loadedState.economy.credits == 500000, "Credits should match")
    assert(loadedState.economy.income == 50000, "Income should match")
    assert(loadedState.economy.expenses == 25000, "Expenses should match")
    assert(loadedState.economy.monthlyReport, "Monthly report should exist")
    
    -- Cleanup
    saveSystem:deleteSave("test_economy")
    
    print("✓ Economy round-trip test passed")
    return true
end

---Test research state round-trip
function TestSaveLoad.test_research_round_trip()
    local saveSystem = SaveLoadSystem()
    local originalState = TestSaveLoad._createMockGameState()
    
    -- Save and load
    saveSystem:save("test_research", originalState)
    local loadedState = saveSystem:load("test_research")
    
    -- Verify research data
    assert(loadedState.research, "Research should exist")
    assert(#loadedState.research.completed == 2, "Should have 2 completed research")
    assert(loadedState.research.completed[1] == "laser_weapons", "First research should match")
    assert(loadedState.research.inProgress.plasma_rifles, "In-progress research should exist")
    assert(loadedState.research.inProgress.plasma_rifles.progress == 250, "Progress should match")
    
    -- Cleanup
    saveSystem:deleteSave("test_research")
    
    print("✓ Research round-trip test passed")
    return true
end

---Test RNG state preservation
function TestSaveLoad.test_rng_determinism()
    local saveSystem = SaveLoadSystem()
    local originalState = TestSaveLoad._createMockGameState()
    
    -- Save and load
    saveSystem:save("test_rng", originalState)
    local loadedState = saveSystem:load("test_rng")
    
    -- Verify RNG data
    assert(loadedState.rng, "RNG should exist")
    assert(loadedState.rng.masterSeed == 42, "Master seed should match")
    assert(loadedState.rng.scopes.combat, "Combat scope should exist")
    assert(loadedState.rng.scopes.combat.seed == 12345, "Combat seed should match")
    assert(#loadedState.rng.scopes.combat.state == 4, "Combat state should have 4 values")
    
    -- Cleanup
    saveSystem:deleteSave("test_rng")
    
    print("✓ RNG determinism test passed")
    return true
end

---Test turn manager round-trip
function TestSaveLoad.test_turn_manager_round_trip()
    local saveSystem = SaveLoadSystem()
    local originalState = TestSaveLoad._createMockGameState()
    
    -- Save and load
    saveSystem:save("test_turns", originalState)
    local loadedState = saveSystem:load("test_turns")
    
    -- Verify turn data
    assert(loadedState.turnManager, "Turn manager should exist")
    assert(loadedState.turnManager.currentTurn == 100, "Current turn should match")
    assert(loadedState.turnManager.currentDate.year == 2018, "Year should match")
    assert(loadedState.turnManager.currentDate.month == 5, "Month should match")
    assert(#loadedState.turnManager.eventQueue == 2, "Should have 2 queued events")
    assert(loadedState.turnManager.eventQueue[1].turn == 105, "Event turn should match")
    
    -- Cleanup
    saveSystem:deleteSave("test_turns")
    
    print("✓ Turn manager round-trip test passed")
    return true
end

---Test autosave functionality
function TestSaveLoad.test_autosave()
    local saveSystem = SaveLoadSystem()
    local originalState = TestSaveLoad._createMockGameState()
    
    -- Perform autosave
    local success = saveSystem:autosave(originalState)
    assert(success, "Autosave should succeed")
    
    -- Verify autosave file exists
    local loadedState = saveSystem:load("autosave1")
    assert(loadedState, "Autosave should be loadable")
    assert(loadedState.economy.credits == 500000, "Autosave data should match")
    
    -- Cleanup
    saveSystem:deleteSave("autosave1")
    
    print("✓ Autosave test passed")
    return true
end

---Test save slot listing
function TestSaveLoad.test_list_slots()
    local saveSystem = SaveLoadSystem()
    local originalState = TestSaveLoad._createMockGameState()
    
    -- Create multiple saves
    saveSystem:save("slot_a", originalState)
    saveSystem:save("slot_b", originalState)
    saveSystem:save("slot_c", originalState)
    
    -- List slots
    local slots = saveSystem:listSlots()
    assert(#slots >= 3, "Should have at least 3 slots")
    
    local found_a, found_b, found_c = false, false, false
    for _, slot in ipairs(slots) do
        if slot == "slot_a" then found_a = true end
        if slot == "slot_b" then found_b = true end
        if slot == "slot_c" then found_c = true end
    end
    
    assert(found_a and found_b and found_c, "All test slots should be listed")
    
    -- Cleanup
    saveSystem:deleteSave("slot_a")
    saveSystem:deleteSave("slot_b")
    saveSystem:deleteSave("slot_c")
    
    print("✓ List slots test passed")
    return true
end

---Test save deletion
function TestSaveLoad.test_delete_save()
    local saveSystem = SaveLoadSystem()
    local originalState = TestSaveLoad._createMockGameState()
    
    -- Create and delete save
    saveSystem:save("slot_delete", originalState)
    local success = saveSystem:deleteSave("slot_delete")
    assert(success, "Delete should succeed")
    
    -- Verify it's gone
    local loadedState, loadError = saveSystem:load("slot_delete")
    assert(not loadedState, "Deleted save should not load")
    assert(loadError == "Save file not found", "Should get not found error")
    
    print("✓ Delete save test passed")
    return true
end

---Test load non-existent save
function TestSaveLoad.test_load_non_existent()
    local saveSystem = SaveLoadSystem()
    
    local loadedState, loadError = saveSystem:load("non_existent_save")
    assert(not loadedState, "Non-existent save should not load")
    assert(loadError == "Save file not found", "Should get not found error")
    
    print("✓ Load non-existent test passed")
    return true
end

---Test complex data structures
function TestSaveLoad.test_complex_data_structures()
    local saveSystem = SaveLoadSystem()
    
    local complexState = {
        nested = {
            deeply = {
                nested = {
                    data = {
                        value = 123,
                        text = "test"
                    }
                }
            }
        },
        arrays = {
            numbers = {1, 2, 3, 4, 5},
            strings = {"a", "b", "c"},
            mixed = {1, "two", 3, "four"}
        },
        special_chars = "Test with \"quotes\" and 'apostrophes'",
        unicode = "Test with émojis 😊",
        large_number = 1234567890
    }
    
    -- Wrap in proper game state structure
    local gameState = TestSaveLoad._createMockGameState()
    gameState.testData = complexState
    
    -- Save and load
    saveSystem:save("test_complex", gameState)
    local loadedState = saveSystem:load("test_complex")
    
    -- Verify complex data
    assert(loadedState.testData.nested.deeply.nested.data.value == 123, "Nested value should match")
    assert(#loadedState.testData.arrays.numbers == 5, "Array length should match")
    assert(loadedState.testData.special_chars:find("quotes"), "Special chars should be preserved")
    assert(loadedState.testData.large_number == 1234567890, "Large numbers should match")
    
    -- Cleanup
    saveSystem:deleteSave("test_complex")
    
    print("✓ Complex data structures test passed")
    return true
end

---Test data integrity with checksums (simulated)
function TestSaveLoad.test_data_integrity()
    local saveSystem = SaveLoadSystem()
    local originalState = TestSaveLoad._createMockGameState()
    
    -- Save
    saveSystem:save("test_integrity", originalState)
    
    -- Load multiple times - should get identical data
    local load1 = saveSystem:load("test_integrity")
    local load2 = saveSystem:load("test_integrity")
    
    -- Verify key values match across loads
    assert(load1.economy.credits == load2.economy.credits, "Credits should match across loads")
    assert(load1.turnManager.currentTurn == load2.turnManager.currentTurn, "Turn should match across loads")
    assert(load1.units.unit_1.experience == load2.units.unit_1.experience, "Experience should match across loads")
    
    -- Cleanup
    saveSystem:deleteSave("test_integrity")
    
    print("✓ Data integrity test passed")
    return true
end

---Run all tests
function TestSaveLoad.runAll()
    print("\n=== Save/Load Round-Trip Tests ===")
    
    local tests = {
        TestSaveLoad.test_basic_save_load,
        TestSaveLoad.test_world_round_trip,
        TestSaveLoad.test_units_round_trip,
        TestSaveLoad.test_economy_round_trip,
        TestSaveLoad.test_research_round_trip,
        TestSaveLoad.test_rng_determinism,
        TestSaveLoad.test_turn_manager_round_trip,
        TestSaveLoad.test_autosave,
        TestSaveLoad.test_list_slots,
        TestSaveLoad.test_delete_save,
        TestSaveLoad.test_load_non_existent,
        TestSaveLoad.test_complex_data_structures,
        TestSaveLoad.test_data_integrity,
    }
    
    local passed = 0
    local failed = 0
    
    for i, test in ipairs(tests) do
        local success, err = pcall(test)
        if success then
            passed = passed + 1
        else
            failed = failed + 1
            print("✗ Test failed: " .. tostring(err))
        end
    end
    
    print(string.format("\n%d/%d tests passed", passed, passed + failed))
    print("===================================\n")
    
    return failed == 0
end

return TestSaveLoad
