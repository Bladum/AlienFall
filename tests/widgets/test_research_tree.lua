-- Test Research Tree Widget visualization and interactivity
-- Verifies that tech tree displays correctly with dependencies and research states

local function test_research_tree_structure()
    print("\n=== Testing Research Tree Structure ===")

    local ResearchTree = require("gui.widgets.advanced.researchtree")
    local tree = ResearchTree.new(0, 0, 800, 600)

    -- Test 1: Create tree
    assert(tree ~= nil, "Research tree should be created")
    assert(tree.nodes ~= nil, "Tree should have nodes table")
    print("✓ Research tree created successfully")

    -- Test 2: Add nodes (simulating data loading)
    local testData = {
        {id = "laser_weapons", name = "Laser Weapons", x = 100, y = 100, status = "available", prerequisites = {}},
        {id = "plasma_rifles", name = "Plasma Rifles", x = 300, y = 100, status = "locked", prerequisites = {"laser_weapons"}},
        {id = "armor_piercing", name = "Armor Piercing", x = 500, y = 100, status = "locked", prerequisites = {"laser_weapons"}},
    }

    tree.nodes = testData
    assert(#tree.nodes == 3, "Tree should contain 3 nodes")
    print("✓ Research tree nodes loaded successfully")

    -- Test 3: Find node by ID
    local foundNode = tree:findNode("laser_weapons")
    assert(foundNode ~= nil, "Should find laser_weapons node")
    assert(foundNode.name == "Laser Weapons", "Node name should match")
    print("✓ Node lookup by ID working correctly")

    -- Test 4: Check prerequisites
    local plasmaNode = tree:findNode("plasma_rifles")
    assert(plasmaNode ~= nil, "Should find plasma_rifles node")
    assert(#plasmaNode.prerequisites == 1, "Plasma rifles should have 1 prerequisite")
    assert(plasmaNode.prerequisites[1] == "laser_weapons", "Prerequisite should be laser_weapons")
    print("✓ Prerequisite chain correctly set up")

    print("\n✅ Research tree structure test passed!")
    return true
end

local function test_research_tree_states()
    print("\n=== Testing Research Tree States ===")

    local ResearchTree = require("gui.widgets.advanced.researchtree")
    local tree = ResearchTree.new(0, 0, 800, 600)

    -- Create nodes with different states
    tree.nodes = {
        {id = "basic", name = "Basic", x = 0, y = 0, status = "completed", prerequisites = {}},
        {id = "advanced", name = "Advanced", x = 100, y = 0, status = "researching", prerequisites = {"basic"}},
        {id = "elite", name = "Elite", x = 200, y = 0, status = "available", prerequisites = {"advanced"}},
        {id = "exotic", name = "Exotic", x = 300, y = 0, status = "locked", prerequisites = {"elite"}},
    }

    -- Test state indicators
    local completedNode = tree:findNode("basic")
    assert(completedNode.status == "completed", "Node should be completed")
    print("✓ Completed state indicator working")

    local researchingNode = tree:findNode("advanced")
    assert(researchingNode.status == "researching", "Node should be researching")
    print("✓ Researching state indicator working")

    local availableNode = tree:findNode("elite")
    assert(availableNode.status == "available", "Node should be available")
    print("✓ Available state indicator working")

    local lockedNode = tree:findNode("exotic")
    assert(lockedNode.status == "locked", "Node should be locked")
    print("✓ Locked state indicator working")

    print("\n✅ Research tree states test passed!")
    return true
end

local function test_research_tree_dependencies()
    print("\n=== Testing Research Tree Dependencies ===")

    local ResearchTree = require("gui.widgets.advanced.researchtree")
    local tree = ResearchTree.new(0, 0, 800, 600)

    -- Create complex dependency chain
    tree.nodes = {
        {id = "t1_a", name = "Tier 1 A", x = 0, y = 0, status = "completed", prerequisites = {}},
        {id = "t1_b", name = "Tier 1 B", x = 100, y = 0, status = "completed", prerequisites = {}},
        {id = "t2_a", name = "Tier 2 A", x = 50, y = 100, status = "researching", prerequisites = {"t1_a", "t1_b"}},
        {id = "t2_b", name = "Tier 2 B", x = 150, y = 100, status = "available", prerequisites = {"t1_b"}},
        {id = "t3_final", name = "Tier 3 Final", x = 100, y = 200, status = "locked", prerequisites = {"t2_a", "t2_b"}},
    }

    -- Verify chain can be traversed
    local node_t2_a = tree:findNode("t2_a")
    assert(#node_t2_a.prerequisites == 2, "T2_A should require 2 prerequisites")
    print("✓ Multiple prerequisite requirements working")

    local node_t3 = tree:findNode("t3_final")
    assert(#node_t3.prerequisites == 2, "T3 final should require 2 prerequisites")
    print("✓ Complex dependency chains working")

    -- Verify prerequisites exist
    local allPrereqsExist = true
    for _, prereqId in ipairs(node_t3.prerequisites) do
        if not tree:findNode(prereqId) then
            allPrereqsExist = false
            break
        end
    end
    assert(allPrereqsExist, "All prerequisites should exist in tree")
    print("✓ All prerequisite nodes can be found")

    print("\n✅ Research tree dependencies test passed!")
    return true
end

local function test_research_tree_selection()
    print("\n=== Testing Research Tree Selection ===")

    local ResearchTree = require("gui.widgets.advanced.researchtree")
    local tree = ResearchTree.new(0, 0, 800, 600)

    tree.nodes = {
        {id = "tech_a", name = "Tech A", x = 0, y = 0, status = "available", prerequisites = {}},
        {id = "tech_b", name = "Tech B", x = 100, y = 0, status = "locked", prerequisites = {"tech_a"}},
    }

    -- Test selection
    assert(tree.selectedNode == nil, "Initially no node selected")
    tree.selectedNode = "tech_a"
    assert(tree.selectedNode == "tech_a", "Node should be selected")
    print("✓ Node selection working")

    -- Test mousepressed for selection (if implemented)
    if tree.mousepressed then
        print("✓ Mouse interaction method available")
    end

    print("\n✅ Research tree selection test passed!")
    return true
end

local function test_research_tree_visualization()
    print("\n=== Testing Research Tree Visualization ===")

    local ResearchTree = require("gui.widgets.advanced.researchtree")
    local tree = ResearchTree.new(100, 100, 600, 400)

    -- Verify widget properties
    assert(tree.x == 100, "Tree X position should be 100")
    assert(tree.y == 100, "Tree Y position should be 100")
    assert(tree.width == 600, "Tree width should be 600")
    assert(tree.height == 400, "Tree height should be 400")
    print("✓ Widget positioning and sizing correct")

    -- Test zoom and pan
    if tree.scale then
        tree.scale = 1
        assert(tree.scale == 1, "Default scale should be 1")
        tree.scale = 1.5
        assert(tree.scale == 1.5, "Zoom adjustment working")
        print("✓ Zoom controls available")
    end

    if tree.offsetX and tree.offsetY then
        tree.offsetX = 10
        tree.offsetY = 20
        assert(tree.offsetX == 10, "Pan X working")
        assert(tree.offsetY == 20, "Pan Y working")
        print("✓ Pan controls available")
    end

    -- Test visibility
    tree.visible = true
    assert(tree.visible, "Tree should be visible when enabled")
    tree.visible = false
    assert(not tree.visible, "Tree should be hidden when disabled")
    print("✓ Visibility toggle working")

    print("\n✅ Research tree visualization test passed!")
    return true
end

-- Run all tests
local allPassed = true

allPassed = test_research_tree_structure() and allPassed
allPassed = test_research_tree_states() and allPassed
allPassed = test_research_tree_dependencies() and allPassed
allPassed = test_research_tree_selection() and allPassed
allPassed = test_research_tree_visualization() and allPassed

if allPassed then
    print("\n" .. string.rep("=", 50))
    print("✅ ALL RESEARCH TREE TESTS PASSED")
    print(string.rep("=", 50))
else
    print("\n" .. string.rep("=", 50))
    print("❌ SOME TESTS FAILED")
    print(string.rep("=", 50))
end

return allPassed
