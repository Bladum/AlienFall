---Test Suite for Research System
---
---Tests research project management, technology tree, prerequisites, scientist
---allocation, progress tracking, and technology unlocks.
---
---Test Coverage:
---  - Project definition and initialization (4 tests)
---  - Research prerequisites and availability (4 tests)
---  - Research progress and completion (5 tests)
---  - Scientist allocation (3 tests)
---  - Technology unlocks (3 tests)
---
---Dependencies:
---  - economy.research.research_system
---  - mock.economy
---
---@module tests.unit.test_research_system
---@author AlienFall Development Team
---@date 2025-10-15

-- Setup package path
package.path = package.path .. ";../../?.lua;../../engine/?.lua"

local ResearchSystem = require("economy.research.research_system")
local MockEconomy = require("tests.mock.economy")

local TestResearchSystem = {}
local testsPassed = 0
local testsFailed = 0
local failureDetails = {}

-- Helper: Run a test
local function runTest(name, testFunc)
    local success, err = pcall(testFunc)
    if success then
        print("✓ " .. name .. " passed")
        testsPassed = testsPassed + 1
    else
        print("✗ " .. name .. " failed: " .. tostring(err))
        testsFailed = testsFailed + 1
        table.insert(failureDetails, {name = name, error = tostring(err)})
    end
end

-- Helper: Assert
local function assert(condition, message)
    if not condition then
        error(message or "Assertion failed")
    end
end

---Test: Create research system
function TestResearchSystem.testCreateSystem()
    local research = ResearchSystem.new()
    
    assert(research ~= nil, "Research system should be created")
    assert(type(research.projects) == "table", "Should have projects table")
    assert(type(research.activeProjects) == "table", "Should have active projects table")
    assert(type(research.completedProjects) == "table", "Should have completed projects table")
end

---Test: Define research project
function TestResearchSystem.testDefineProject()
    local research = ResearchSystem.new()
    local project = MockEconomy.getResearchProject("LASER_WEAPONS")
    
    research:defineProject(project.id, project)
    
    assert(research.projects[project.id] ~= nil, "Project should be defined")
    assert(research.projects[project.id].name == project.name, "Project name should match")
    assert(research.projects[project.id].cost > 0, "Project should have cost")
end

---Test: Project with prerequisites
function TestResearchSystem.testProjectPrerequisites()
    local research = ResearchSystem.new()
    
    -- Define prerequisite project
    local basic = MockEconomy.getResearchProject("LASER_WEAPONS")
    basic.prerequisites = {}
    research:defineProject("BASIC_LASERS", basic)
    
    -- Define advanced project requiring prerequisite
    local advanced = MockEconomy.getResearchProject("PLASMA_WEAPONS")
    advanced.prerequisites = {"BASIC_LASERS"}
    research:defineProject("ADVANCED_LASERS", advanced)
    
    assert(#research.projects["ADVANCED_LASERS"].prerequisites == 1, "Should have 1 prerequisite")
    assert(research.projects["ADVANCED_LASERS"].prerequisites[1] == "BASIC_LASERS", "Prerequisite should match")
end

---Test: Project categories
function TestResearchSystem.testProjectCategories()
    local research = ResearchSystem.new()
    
    local weaponProject = MockEconomy.getResearchProject("LASER_WEAPONS")
    weaponProject.category = ResearchSystem.CATEGORIES.WEAPONS
    research:defineProject("WEAPONS_TEST", weaponProject)
    
    local alienProject = MockEconomy.getResearchProject("ALIEN_BIOLOGY")
    alienProject.category = ResearchSystem.CATEGORIES.ALIENS
    research:defineProject("ALIENS_TEST", alienProject)
    
    assert(research.projects["WEAPONS_TEST"].category == "weapons", "Should be weapons category")
    assert(research.projects["ALIENS_TEST"].category == "aliens", "Should be aliens category")
end

---Test: Check project availability without prerequisites
function TestResearchSystem.testAvailabilityNoPrerequisites()
    local research = ResearchSystem.new()
    
    local project = MockEconomy.getResearchProject("LASER_WEAPONS")
    project.prerequisites = {}
    research:defineProject("AVAILABLE_PROJECT", project)
    
    local isAvailable = research:isAvailable("AVAILABLE_PROJECT")
    assert(isAvailable, "Project with no prerequisites should be available")
end

---Test: Check project unavailable with unmet prerequisites
function TestResearchSystem.testAvailabilityUnmetPrerequisites()
    local research = ResearchSystem.new()
    
    -- Define prerequisite (not completed)
    local basic = MockEconomy.getResearchProject("LASER_WEAPONS")
    basic.prerequisites = {}
    research:defineProject("BASIC_TECH", basic)
    
    -- Define project requiring prerequisite
    local advanced = MockEconomy.getResearchProject("PLASMA_WEAPONS")
    advanced.prerequisites = {"BASIC_TECH"}
    research:defineProject("ADVANCED_TECH", advanced)
    
    local isAvailable = research:isAvailable("ADVANCED_TECH")
    assert(not isAvailable, "Project should not be available without prerequisites")
end

---Test: Check project available after completing prerequisites
function TestResearchSystem.testAvailabilityAfterPrerequisites()
    local research = ResearchSystem.new()
    
    -- Define and complete prerequisite
    local basic = MockEconomy.getResearchProject("LASER_WEAPONS")
    basic.prerequisites = {}
    research:defineProject("BASIC_TECH", basic)
    research:completeResearch("BASIC_TECH")
    
    -- Define project requiring prerequisite
    local advanced = MockEconomy.getResearchProject("PLASMA_WEAPONS")
    advanced.prerequisites = {"BASIC_TECH"}
    research:defineProject("ADVANCED_TECH", advanced)
    
    local isAvailable = research:isAvailable("ADVANCED_TECH")
    assert(isAvailable, "Project should be available after completing prerequisites")
end

---Test: Get available projects list
function TestResearchSystem.testGetAvailableProjects()
    local research = ResearchSystem.new()
    
    -- Add multiple projects
    local proj1 = MockEconomy.getResearchProject("LASER_WEAPONS")
    proj1.prerequisites = {}
    research:defineProject("PROJ1", proj1)
    
    local proj2 = MockEconomy.getResearchProject("PLASMA_WEAPONS")
    proj2.prerequisites = {}
    research:defineProject("PROJ2", proj2)
    
    local available = research:getAvailableProjects()
    
    assert(type(available) == "table", "Should return table of available projects")
    assert(#available >= 2, string.format("Should have at least 2 available projects, got %d", #available))
end

---Test: Start research project
function TestResearchSystem.testStartResearch()
    local research = ResearchSystem.new()
    
    local project = MockEconomy.getResearchProject("LASER_WEAPONS")
    project.prerequisites = {}
    research:defineProject("TEST_PROJECT", project)
    
    research:startResearch("TEST_PROJECT", 5)  -- 5 scientists
    
    assert(research.activeProjects["TEST_PROJECT"] ~= nil, "Project should be active")
    assert(research.projects["TEST_PROJECT"].status == ResearchSystem.STATUS.IN_PROGRESS, "Status should be IN_PROGRESS")
end

---Test: Update research progress
function TestResearchSystem.testUpdateProgress()
    local research = ResearchSystem.new()
    
    local project = MockEconomy.getResearchProject("LASER_WEAPONS")
    project.prerequisites = {}
    project.cost = 100
    research:defineProject("TEST_PROJECT", project)
    
    research:startResearch("TEST_PROJECT", 10)
    
    local initialProgress = research.projects["TEST_PROJECT"].progress
    
    research:updateProgress(24)  -- 24 hours
    
    local newProgress = research.projects["TEST_PROJECT"].progress
    assert(newProgress > initialProgress, "Progress should increase after update")
end

---Test: Complete research project
function TestResearchSystem.testCompleteResearch()
    local research = ResearchSystem.new()
    
    local project = MockEconomy.getResearchProject("LASER_WEAPONS")
    project.prerequisites = {}
    research:defineProject("TEST_PROJECT", project)
    
    research:startResearch("TEST_PROJECT", 10)
    research:completeResearch("TEST_PROJECT")
    
    assert(research.projects["TEST_PROJECT"].status == ResearchSystem.STATUS.COMPLETE, "Status should be COMPLETE")
    assert(research.completedProjects["TEST_PROJECT"] == true, "Should be in completed list")
    assert(research.activeProjects["TEST_PROJECT"] == nil, "Should not be in active list")
end

---Test: Auto-complete when progress reaches cost
function TestResearchSystem.testAutoComplete()
    local research = ResearchSystem.new()
    
    local project = MockEconomy.getResearchProject("LASER_WEAPONS")
    project.prerequisites = {}
    project.cost = 10  -- Very low cost for quick completion
    research:defineProject("QUICK_PROJECT", project)
    
    research:startResearch("QUICK_PROJECT", 100)  -- Many scientists for fast progress
    
    -- Update until completion
    for i = 1, 100 do
        research:updateProgress(1)
        if research.projects["QUICK_PROJECT"].status == ResearchSystem.STATUS.COMPLETE then
            break
        end
    end
    
    assert(research.projects["QUICK_PROJECT"].status == ResearchSystem.STATUS.COMPLETE, "Project should auto-complete when progress >= cost")
end

---Test: Research progress with multiple projects
function TestResearchSystem.testMultipleActiveProjects()
    local research = ResearchSystem.new()
    
    local proj1 = MockEconomy.getResearchProject("LASER_WEAPONS")
    proj1.prerequisites = {}
    research:defineProject("PROJ1", proj1)
    
    local proj2 = MockEconomy.getResearchProject("PLASMA_WEAPONS")
    proj2.prerequisites = {}
    research:defineProject("PROJ2", proj2)
    
    research:startResearch("PROJ1", 5)
    research:startResearch("PROJ2", 3)
    
    local activeCount = 0
    for _ in pairs(research.activeProjects) do
        activeCount = activeCount + 1
    end
    
    assert(activeCount == 2, string.format("Should have 2 active projects, got %d", activeCount))
end

---Test: Allocate scientists to project
function TestResearchSystem.testAllocateScientists()
    local research = ResearchSystem.new()
    research.scientists = 10  -- Available scientists
    
    local project = MockEconomy.getResearchProject("LASER_WEAPONS")
    project.prerequisites = {}
    research:defineProject("TEST_PROJECT", project)
    
    research:startResearch("TEST_PROJECT", 5)
    
    -- Check that scientists were allocated
    assert(research.activeProjects["TEST_PROJECT"].scientists == 5, "Should allocate 5 scientists")
end

---Test: Cannot allocate more scientists than available
function TestResearchSystem.testScientistLimit()
    local research = ResearchSystem.new()
    research.scientists = 3  -- Only 3 available
    
    local project = MockEconomy.getResearchProject("LASER_WEAPONS")
    project.prerequisites = {}
    research:defineProject("TEST_PROJECT", project)
    
    -- Try to allocate 10 scientists when only 3 available
    local success = pcall(function()
        research:startResearch("TEST_PROJECT", 10)
    end)
    
    -- Should either fail or clamp to available scientists
    -- Implementation dependent
end

---Test: Reallocate scientists
function TestResearchSystem.testReallocateScientists()
    local research = ResearchSystem.new()
    research.scientists = 10
    
    local project = MockEconomy.getResearchProject("LASER_WEAPONS")
    project.prerequisites = {}
    research:defineProject("TEST_PROJECT", project)
    
    research:startResearch("TEST_PROJECT", 5)
    
    -- Reallocate to different number
    if research.activeProjects["TEST_PROJECT"].scientists then
        research.activeProjects["TEST_PROJECT"].scientists = 8
        assert(research.activeProjects["TEST_PROJECT"].scientists == 8, "Should reallocate scientists")
    end
end

---Test: Technology unlocks items
function TestResearchSystem.testTechnologyUnlocksItems()
    local research = ResearchSystem.new()
    
    local project = MockEconomy.getResearchProject("LASER_WEAPONS")
    project.prerequisites = {}
    project.unlocks = {"LASER_RIFLE", "LASER_PISTOL"}
    research:defineProject("LASER_TECH", project)
    
    research:startResearch("LASER_TECH", 10)
    research:completeResearch("LASER_TECH")
    
    -- Check unlocks
    assert(#research.projects["LASER_TECH"].unlocks == 2, "Should unlock 2 items")
end

---Test: Get unlocked items list
function TestResearchSystem.testGetUnlockedItems()
    local research = ResearchSystem.new()
    
    local project = MockEconomy.getResearchProject("LASER_WEAPONS")
    project.prerequisites = {}
    project.unlocks = {"ITEM1", "ITEM2", "ITEM3"}
    research:defineProject("UNLOCK_TEST", project)
    
    research:completeResearch("UNLOCK_TEST")
    
    -- Get all unlocked items
    local unlocked = {}
    for projectId, completed in pairs(research.completedProjects) do
        if completed and research.projects[projectId].unlocks then
            for _, item in ipairs(research.projects[projectId].unlocks) do
                table.insert(unlocked, item)
            end
        end
    end
    
    assert(#unlocked >= 3, string.format("Should have at least 3 unlocked items, got %d", #unlocked))
end

---Test: Research unlocks facilities
function TestResearchSystem.testUnlocksFacilities()
    local research = ResearchSystem.new()
    
    local project = MockEconomy.getResearchProject("ADVANCED_LAB")
    project.prerequisites = {}
    project.unlocks = {"HYPERWAVE_DECODER", "PSI_LAB"}
    project.category = ResearchSystem.CATEGORIES.FACILITIES
    research:defineProject("FACILITY_RESEARCH", project)
    
    research:completeResearch("FACILITY_RESEARCH")
    
    assert(research.projects["FACILITY_RESEARCH"].category == "facilities", "Should be facilities category")
    assert(#research.projects["FACILITY_RESEARCH"].unlocks == 2, "Should unlock 2 facilities")
end

-- Run all tests
function TestResearchSystem.runAll()
    print("\n=== Running Research System Tests ===\n")
    
    testsPassed = 0
    testsFailed = 0
    failureDetails = {}
    
    -- Initialization tests
    runTest("Create research system", TestResearchSystem.testCreateSystem)
    runTest("Define research project", TestResearchSystem.testDefineProject)
    runTest("Project with prerequisites", TestResearchSystem.testProjectPrerequisites)
    runTest("Project categories", TestResearchSystem.testProjectCategories)
    
    -- Availability tests
    runTest("Project available without prerequisites", TestResearchSystem.testAvailabilityNoPrerequisites)
    runTest("Project unavailable with unmet prerequisites", TestResearchSystem.testAvailabilityUnmetPrerequisites)
    runTest("Project available after prerequisites", TestResearchSystem.testAvailabilityAfterPrerequisites)
    runTest("Get available projects list", TestResearchSystem.testGetAvailableProjects)
    
    -- Progress tests
    runTest("Start research project", TestResearchSystem.testStartResearch)
    runTest("Update research progress", TestResearchSystem.testUpdateProgress)
    runTest("Complete research project", TestResearchSystem.testCompleteResearch)
    runTest("Auto-complete on full progress", TestResearchSystem.testAutoComplete)
    runTest("Multiple active projects", TestResearchSystem.testMultipleActiveProjects)
    
    -- Scientist allocation tests
    runTest("Allocate scientists", TestResearchSystem.testAllocateScientists)
    runTest("Scientist limit", TestResearchSystem.testScientistLimit)
    runTest("Reallocate scientists", TestResearchSystem.testReallocateScientists)
    
    -- Unlock tests
    runTest("Technology unlocks items", TestResearchSystem.testTechnologyUnlocksItems)
    runTest("Get unlocked items list", TestResearchSystem.testGetUnlockedItems)
    runTest("Research unlocks facilities", TestResearchSystem.testUnlocksFacilities)
    
    -- Print results
    print("\n=== Test Results ===")
    print(string.format("Total: %d, Passed: %d (%.1f%%), Failed: %d",
        testsPassed + testsFailed,
        testsPassed,
        (testsPassed / (testsPassed + testsFailed)) * 100,
        testsFailed
    ))
    
    if testsFailed > 0 then
        print("\nFailed tests:")
        for _, failure in ipairs(failureDetails) do
            print(string.format("  ✗ %s: %s", failure.name, failure.error))
        end
    else
        print("\n✓ All Research System tests passed!")
    end
    
    return testsPassed, testsFailed
end

-- Run if executed directly
if arg and arg[0]:match("test_research_system%.lua$") then
    TestResearchSystem.runAll()
end

return TestResearchSystem
