-- TEST SYSTEM API FOR AI AGENTS
-- Complete guide for AI assistants to understand and use the test system

return {
    -- ========================================================================
    -- OVERVIEW
    -- ========================================================================
    overview = [[
The XCOM Simple project has a comprehensive test suite located in the tests/
directory. Tests are organized by type and can be run individually or in
groups. All mock data is centralized in the mock/ directory.

Project Structure:
  tests/
    ├── unit/                   # Isolated module tests
    ├── integration/            # Multi-system workflow tests
    ├── performance/            # Benchmark tests
    └── runners/                # Test execution scripts

  mock/
    ├── units.lua              # Mock soldiers, enemies, squads
    ├── items.lua              # Mock weapons, armor, equipment
    ├── facilities.lua         # Mock bases, facilities
    ├── economy.lua            # Mock finances, research, manufacturing
    └── geoscape.lua           # Mock world, missions, UFOs
]],

    -- ========================================================================
    -- RUNNING TESTS
    -- ========================================================================
    running = {
        -- Run all tests at once
        all_tests = {
            command = "lovec tests/runners",
            alternative = "run_tests.bat",
            description = "Runs complete test suite with all categories",
            output = "Console with colored results and summary"
        },
        
        -- Run specific test categories
        selective = {
            command = "lovec tests/runners/run_selective_tests.lua [category]",
            categories = {
                core = "Core systems (State, Audio, Data Loader)",
                basescape = "Base management (Facilities, Integration)",
                geoscape = "World and strategic layer",
                combat = "Combat and pathfinding",
                performance = "Performance benchmarks",
                all = "All tests (default)"
            },
            examples = {
                "lovec tests/runners/run_selective_tests.lua core",
                "lovec tests/runners/run_selective_tests.lua combat",
                "lovec tests/runners/run_selective_tests.lua all"
            }
        },
        
        -- Run individual test files
        individual = {
            command = "lua tests/unit/test_[name].lua",
            examples = {
                "lua tests/unit/test_state_manager.lua",
                "lua tests/unit/test_pathfinding.lua",
                "lua tests/integration/test_combat_integration.lua"
            },
            note = "Most tests can run without Love2D in headless mode"
        },
        
        -- Get help
        help = {
            command = "lovec tests/runners/run_selective_tests.lua help",
            description = "Shows detailed usage information"
        }
    },

    -- ========================================================================
    -- TEST CATEGORIES
    -- ========================================================================
    categories = {
        unit_tests = {
            location = "tests/unit/",
            description = "Test individual modules in isolation",
            files = {
                "test_state_manager.lua     -- State transitions, screen management",
                "test_audio_system.lua      -- Volume, categories, mixing",
                "test_facility_system.lua   -- Base facilities, construction",
                "test_world_system.lua      -- Hex grid, provinces, time",
                "test_pathfinding.lua       -- A* pathfinding, obstacles",
                "test_data_loader.lua       -- Data loading, validation"
            },
            total_tests = 48,
            run_command = "lovec tests/runners/run_selective_tests.lua core"
        },
        
        integration_tests = {
            location = "tests/integration/",
            description = "Test complete workflows across systems",
            files = {
                "test_combat_integration.lua  -- Full combat flow",
                "test_base_integration.lua    -- Base management workflows"
            },
            total_tests = 20,
            run_command = "lovec tests/runners/run_selective_tests.lua basescape"
        },
        
        performance_tests = {
            location = "tests/performance/",
            description = "Benchmark critical game systems",
            files = {
                "test_game_performance.lua  -- Pathfinding, hex math, collisions"
            },
            total_benchmarks = 7,
            run_command = "lovec tests/runners/run_selective_tests.lua performance"
        }
    },

    -- ========================================================================
    -- MOCK DATA API
    -- ========================================================================
    mock_data = {
        units = {
            file = "tests/mock/units.lua",
            functions = {
                "getSoldier(name, class)        -- Single soldier",
                "generateSquad(count)           -- Full squad (default 6)",
                "getEnemy(type)                 -- Single enemy",
                "generateEnemyGroup(count)      -- Enemy squad",
                "getWoundedSoldier(level)       -- Wounded soldier",
                "getVeteran()                   -- High-stat veteran",
                "getUnitWithStats(stats)        -- Custom unit",
                "getCivilian(name)              -- Civilian"
            },
            example = [[
                local MockUnits = require("tests.mock.units")
                local soldier = MockUnits.getSoldier("John", "ASSAULT")
                local squad = MockUnits.generateSquad(6)
                local enemy = MockUnits.getEnemy("SECTOID")
            ]],
            types = {
                soldier_classes = {"ASSAULT", "HEAVY", "SNIPER", "SUPPORT", "SPECIALIST"},
                enemy_types = {"SECTOID", "MUTON", "FLOATER", "CHRYSSALID", "BERSERKER", "THIN_MAN"},
                wound_levels = {"LIGHT", "MODERATE", "SEVERE"}
            }
        },
        
        items = {
            file = "tests/mock/items.lua",
            functions = {
                "getWeapon(type)               -- Weapon by type",
                "getArmor(type)                -- Armor by type",
                "getGrenade(type)              -- Grenade by type",
                "getMedkit()                   -- Medical kit",
                "getScanner()                  -- Motion scanner",
                "generateLoadout(class)        -- Class loadout",
                "generateInventory(count)      -- Random items",
                "getAmmo(weaponType)           -- Ammunition"
            },
            example = [[
                local MockItems = require("tests.mock.items")
                local rifle = MockItems.getWeapon("RIFLE")
                local armor = MockItems.getArmor("KEVLAR")
                local loadout = MockItems.generateLoadout("ASSAULT")
            ]],
            types = {
                weapons = {"PISTOL", "RIFLE", "SNIPER", "SHOTGUN", "HEAVY", "SWORD"},
                armor = {"KEVLAR", "CARAPACE", "TITAN", "GHOST"},
                grenades = {"FRAG", "SMOKE", "INCENDIARY", "ALIEN", "GAS"}
            }
        },
        
        facilities = {
            file = "tests/mock/facilities.lua",
            functions = {
                "getBase(name)                 -- Base configuration",
                "getFacility(type, x, y)       -- Single facility",
                "getConstructionOrder(...)     -- Construction in progress",
                "getStarterBase()              -- Basic starter base",
                "getFullBase()                 -- Complete base",
                "getDamagedFacility(type, %)   -- Damaged facility"
            },
            example = [[
                local MockFacilities = require("tests.mock.facilities")
                local base = MockFacilities.getStarterBase()
                local lab = MockFacilities.getFacility("LABORATORY", 3, 3)
            ]],
            types = {
                facilities = {"ACCESS_LIFT", "LIVING_QUARTERS", "LABORATORY", 
                             "WORKSHOP", "HANGAR", "POWER_GENERATOR", "STORAGE"}
            }
        },
        
        economy = {
            file = "tests/mock/economy.lua",
            functions = {
                "getFinances(balance)          -- Finance data",
                "getResearchProject(type)      -- Research project",
                "getResearchQueue()            -- Research queue",
                "getManufacturingProject(type) -- Manufacturing project",
                "getManufacturingQueue()       -- Manufacturing queue",
                "getMaterials()                -- Material inventory",
                "getMarketItem(type)           -- Market item",
                "getFundingReport()            -- Country funding",
                "getSalaries()                 -- Salary info"
            },
            example = [[
                local MockEconomy = require("tests.mock.economy")
                local finances = MockEconomy.getFinances()
                local research = MockEconomy.getResearchProject("LASER_WEAPONS")
            ]]
        },
        
        geoscape = {
            file = "tests/mock/geoscape.lua",
            functions = {
                "getProvince(name)             -- Province data",
                "getCountry(name)              -- Country data",
                "getWorld(size)                -- World grid",
                "getUFO(type)                  -- UFO",
                "getCraft(type)                -- Player craft",
                "getSiteMission()              -- Alien abduction",
                "getUFOMission(isLanding)      -- UFO mission",
                "getTerrorMission()            -- Terror mission",
                "getAllMissions()              -- All mission types"
            },
            example = [[
                local MockGeoscape = require("tests.mock.geoscape")
                local world = MockGeoscape.getWorld({width = 80, height = 60})
                local ufo = MockGeoscape.getUFO("SCOUT")
                local mission = MockGeoscape.getSiteMission()
            ]],
            types = {
                ufos = {"SCOUT", "FIGHTER", "HARVESTER", "BATTLESHIP"},
                crafts = {"INTERCEPTOR", "SKYRANGER", "FIRESTORM"},
                missions = {"SITE", "UFO_CRASH", "UFO_LANDING", "TERROR"}
            }
        }
    },

    -- ========================================================================
    -- WRITING NEW TESTS
    -- ========================================================================
    writing_tests = {
        unit_test_template = [[
-- tests/unit/test_my_system.lua
local MySystemTest = {}

function MySystemTest.testFeature()
    local MySystem = require("path.to.my_system")
    
    -- Arrange
    local input = "test"
    
    -- Act
    local result = MySystem.doSomething(input)
    
    -- Assert
    assert(result ~= nil, "Result should not be nil")
    assert(result == "expected", "Result should match expected")
    
    print("✓ testFeature passed")
end

function MySystemTest.runAll()
    print("\n=== MySystem Tests ===")
    MySystemTest.testFeature()
    print("✓ All MySystem tests passed!\n")
end

return MySystemTest
        ]],
        
        integration_test_template = [[
-- tests/integration/test_system_integration.lua
local SystemIntegrationTest = {}

local function setup()
    package.path = package.path .. ";../../?.lua;../../engine/?.lua"
    local MockData = require("mock.data")
    return MockData
end

function SystemIntegrationTest.testWorkflow()
    local MockData = setup()
    
    -- Create test data
    local data = MockData.getData()
    
    -- Execute workflow
    -- ... test logic ...
    
    -- Verify results
    assert(condition, "Workflow should complete")
    
    print("✓ testWorkflow passed")
end

function SystemIntegrationTest.runAll()
    print("\n=== System Integration Tests ===")
    SystemIntegrationTest.testWorkflow()
    print("✓ All integration tests passed!\n")
end

return SystemIntegrationTest
        ]],
        
        add_to_registry = [[
To add a new test to the selective runner, edit:
  tests/runners/run_selective_tests.lua

Add to TestRegistry.categories:
  ["category_name"] = {
      name = "Category Display Name",
      tests = {
          {"Test Name", "tests.unit.test_file"}
      }
  }
        ]],
        
        best_practices = {
            "Test one thing per test function",
            "Use descriptive test names (testCalculateDamage, not test1)",
            "Use Arrange-Act-Assert pattern",
            "Always include assert messages",
            "Print success messages",
            "Handle errors with pcall",
            "Use mock data from tests/mock/ directory",
            "Keep tests fast and independent"
        }
    },

    -- ========================================================================
    -- AI AGENT QUICK REFERENCE
    -- ========================================================================
    ai_quick_reference = {
        -- When user asks to run tests
        run_tests = {
            all = "lovec tests/runners",
            category = "lovec tests/runners/run_selective_tests.lua [category]",
            specific = "lua tests/unit/test_[name].lua"
        },
        
        -- When user asks what tests exist
        list_tests = "See categories.unit_tests, integration_tests, performance_tests",
        
        -- When user asks about mock data
        mock_data_help = "See mock_data section for complete API",
        
        -- When user wants to write new tests
        writing_help = "See writing_tests section for templates and best practices",
        
        -- Common commands
        commands = {
            "lovec tests/runners                              -- Run all tests",
            "lovec tests/runners/run_selective_tests.lua core -- Run core tests",
            "run_tests.bat                                     -- Windows batch file",
            "lua tests/unit/test_state_manager.lua            -- Single test"
        }
    },

    -- ========================================================================
    -- TEST OUTPUT EXAMPLES
    -- ========================================================================
    output_examples = {
        success = [[
============================================================
Running: State Manager
------------------------------------------------------------
✓ testRegisterState passed
✓ testSwitchState passed
✓ testPushPopState passed
✓ All State Manager tests passed!

TEST SUMMARY
Total Tests: 1
Passed:      1 (100.0%)
Failed:      0 (0.0%)

✓ ALL TESTS PASSED!
        ]],
        
        failure = [[
============================================================
Running: My System
------------------------------------------------------------
✓ testFeature1 passed
✗ testFeature2 failed
  Error: Expected 42, got 41

TEST SUMMARY
Total Tests: 1
Passed:      1 (50.0%)
Failed:      1 (50.0%)

ERROR DETAILS
1. My System
   Expected 42, got 41

✗ SOME TESTS FAILED
        ]]
    },

    -- ========================================================================
    -- FILE LOCATIONS
    -- ========================================================================
    file_structure = {
        ["tests/unit/"] = "Unit tests for individual modules",
        ["tests/integration/"] = "Integration tests for workflows",
        ["tests/performance/"] = "Performance benchmarks",
        ["tests/runners/"] = "Test execution scripts",
        ["tests/mock/"] = "Centralized mock data generators",
        ["TEST_SUITE_SUMMARY.md"] = "Detailed test documentation",
        ["TEST_COVERAGE_REPORT.md"] = "Visual coverage report",
        ["TEST_DEVELOPMENT_GUIDE.md"] = "Guide for writing tests",
        ["run_tests.bat"] = "Windows test runner"
    },

    -- ========================================================================
    -- TOTAL STATISTICS
    -- ========================================================================
    statistics = {
        mock_files = 5,
        mock_generators = 52,
        unit_tests = 6,
        unit_test_cases = 48,
        integration_tests = 2,
        integration_scenarios = 20,
        performance_tests = 1,
        performance_benchmarks = 7,
        total_test_files = 9,
        total_test_cases = 75,
        coverage = "High - Core systems, combat, base management, geoscape"
    }
}
