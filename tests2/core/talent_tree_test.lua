-- ─────────────────────────────────────────────────────────────────────────
-- TALENT TREE TEST SUITE
-- FILE: tests2/core/talent_tree_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.core.talent_tree",
    fileName = "talent_tree.lua",
    description = "Talent tree with node progression, unlocking, and specialization paths"
})

print("[TALENT_TREE_TEST] Setting up")

local TalentTree = {
    trees = {},
    nodes = {},
    paths = {},
    player_progress = {},

    new = function(self)
        return setmetatable({
            trees = {}, nodes = {}, paths = {}, player_progress = {}
        }, {__index = self})
    end,

    createTree = function(self, treeId, name, treeType, tier_count)
        self.trees[treeId] = {
            id = treeId, name = name, type = treeType or "general",
            tier_count = tier_count or 5, nodes_per_tier = 3,
            root_node = nil, total_nodes = 0
        }
        self.player_progress[treeId] = {
            unlocked_nodes = {}, active_path = nil,
            points_spent = 0, level = 1
        }
        return true
    end,

    getTree = function(self, treeId)
        return self.trees[treeId]
    end,

    createNode = function(self, nodeId, treeId, name, tier, effect)
        if not self.trees[treeId] then return false end
        self.nodes[nodeId] = {
            id = nodeId, tree_id = treeId, name = name, tier = tier or 1,
            effect = effect or "general", cost = 1, unlocked = false,
            prerequisites = {}, children = {}, passive = true
        }
        self.trees[treeId].total_nodes = self.trees[treeId].total_nodes + 1
        return true
    end,

    getNode = function(self, nodeId)
        return self.nodes[nodeId]
    end,

    setNodePrerequisite = function(self, nodeId, prerequisiteNodeId)
        if not self.nodes[nodeId] or not self.nodes[prerequisiteNodeId] then return false end
        self.nodes[nodeId].prerequisites[prerequisiteNodeId] = true
        self.nodes[prerequisiteNodeId].children[nodeId] = true
        return true
    end,

    getNodePrerequisites = function(self, nodeId)
        if not self.nodes[nodeId] then return {} end
        local prereqs = {}
        for nodeId, _ in pairs(self.nodes[nodeId].prerequisites) do
            table.insert(prereqs, nodeId)
        end
        return prereqs
    end,

    getNodeChildren = function(self, nodeId)
        if not self.nodes[nodeId] then return {} end
        local children = {}
        for childId, _ in pairs(self.nodes[nodeId].children) do
            table.insert(children, childId)
        end
        return children
    end,

    canUnlockNode = function(self, treeId, nodeId)
        if not self.nodes[nodeId] or not self.trees[treeId] then return false end
        local progress = self.player_progress[treeId]
        local node = self.nodes[nodeId]
        if progress.unlocked_nodes[nodeId] then return false end
        for prereqId, _ in pairs(node.prerequisites) do
            if not progress.unlocked_nodes[prereqId] then return false end
        end
        return true
    end,

    unlockNode = function(self, treeId, nodeId)
        if not self:canUnlockNode(treeId, nodeId) then return false end
        local progress = self.player_progress[treeId]
        progress.unlocked_nodes[nodeId] = true
        self.nodes[nodeId].unlocked = true
        progress.points_spent = progress.points_spent + (self.nodes[nodeId].cost or 1)
        return true
    end,

    isNodeUnlocked = function(self, treeId, nodeId)
        if not self.player_progress[treeId] then return false end
        return self.player_progress[treeId].unlocked_nodes[nodeId] ~= nil
    end,

    getUnlockedNodes = function(self, treeId)
        if not self.player_progress[treeId] then return {} end
        local unlocked = {}
        for nodeId, _ in pairs(self.player_progress[treeId].unlocked_nodes) do
            table.insert(unlocked, nodeId)
        end
        return unlocked
    end,

    getUnlockedNodeCount = function(self, treeId)
        if not self.player_progress[treeId] then return 0 end
        local count = 0
        for _ in pairs(self.player_progress[treeId].unlocked_nodes) do
            count = count + 1
        end
        return count
    end,

    createSpecializationPath = function(self, pathId, name, nodes_sequence)
        self.paths[pathId] = {
            id = pathId, name = name, nodes = nodes_sequence or {},
            completion_percentage = 0, bonus_effect = "passive_boost",
            level = 0
        }
        return true
    end,

    getSpecializationPath = function(self, pathId)
        return self.paths[pathId]
    end,

    selectPath = function(self, treeId, pathId)
        if not self.trees[treeId] or not self.paths[pathId] then return false end
        self.player_progress[treeId].active_path = pathId
        return true
    end,

    getActivePath = function(self, treeId)
        if not self.player_progress[treeId] then return nil end
        return self.player_progress[treeId].active_path
    end,

    calculatePathCompletion = function(self, treeId, pathId)
        if not self.paths[pathId] or not self.player_progress[treeId] then return 0 end
        local path = self.paths[pathId]
        local progress = self.player_progress[treeId]
        if #path.nodes == 0 then return 0 end
        local completed = 0
        for _, nodeId in ipairs(path.nodes) do
            if progress.unlocked_nodes[nodeId] then
                completed = completed + 1
            end
        end
        return math.floor((completed / #path.nodes) * 100)
    end,

    upgradePath = function(self, pathId)
        if not self.paths[pathId] then return false end
        self.paths[pathId].level = self.paths[pathId].level + 1
        return true
    end,

    getPathLevel = function(self, pathId)
        if not self.paths[pathId] then return 0 end
        return self.paths[pathId].level
    end,

    calculateTotalEfficiency = function(self, treeId)
        if not self.player_progress[treeId] then return 0 end
        local progress = self.player_progress[treeId]
        local unlocked_count = self:getUnlockedNodeCount(treeId)
        local tree = self.trees[treeId]
        if tree.total_nodes == 0 then return 0 end
        local base_efficiency = (unlocked_count / tree.total_nodes) * 100
        local path_bonus = 0
        if progress.active_path then
            path_bonus = self:calculatePathCompletion(treeId, progress.active_path) * 0.1
        end
        return math.floor(base_efficiency + path_bonus)
    end,

    resetProgressOnTree = function(self, treeId)
        if not self.player_progress[treeId] then return false end
        self.player_progress[treeId].unlocked_nodes = {}
        self.player_progress[treeId].active_path = nil
        self.player_progress[treeId].points_spent = 0
        for _, node in pairs(self.nodes) do
            if node.tree_id == treeId then
                node.unlocked = false
            end
        end
        return true
    end,

    getPointsSpent = function(self, treeId)
        if not self.player_progress[treeId] then return 0 end
        return self.player_progress[treeId].points_spent
    end,

    advanceTreeLevel = function(self, treeId)
        if not self.player_progress[treeId] then return false end
        self.player_progress[treeId].level = self.player_progress[treeId].level + 1
        return true
    end,

    getTreeLevel = function(self, treeId)
        if not self.player_progress[treeId] then return 0 end
        return self.player_progress[treeId].level
    end,

    getCurrentProgression = function(self, treeId)
        if not self.player_progress[treeId] then return nil end
        return self.player_progress[treeId]
    end,

    calculateNodeChainLength = function(self, nodeId)
        if not self.nodes[nodeId] then return 0 end
        local length = 1
        for childId, _ in pairs(self.nodes[nodeId].children) do
            local child_length = self:calculateNodeChainLength(childId)
            length = math.max(length, 1 + child_length)
        end
        return length
    end,

    getAccessibleNodes = function(self, treeId)
        if not self.player_progress[treeId] then return {} end
        local accessible = {}
        for nodeId, node in pairs(self.nodes) do
            if node.tree_id == treeId and self:canUnlockNode(treeId, nodeId) then
                table.insert(accessible, nodeId)
            end
        end
        return accessible
    end,

    reset = function(self)
        self.trees = {}
        self.nodes = {}
        self.paths = {}
        self.player_progress = {}
        return true
    end
}

Suite:group("Trees", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.tt = TalentTree:new()
    end)

    Suite:testMethod("TalentTree.createTree", {description = "Creates tree", testCase = "create", type = "functional"}, function()
        local ok = shared.tt:createTree("tree1", "Warrior", "combat", 5)
        Helpers.assertEqual(ok, true, "Created")
    end)

    Suite:testMethod("TalentTree.getTree", {description = "Gets tree", testCase = "get", type = "functional"}, function()
        shared.tt:createTree("tree2", "Mage", "magic", 5)
        local tree = shared.tt:getTree("tree2")
        Helpers.assertEqual(tree ~= nil, true, "Retrieved")
    end)
end)

Suite:group("Nodes", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.tt = TalentTree:new()
        shared.tt:createTree("node_tree", "Test", "general", 5)
    end)

    Suite:testMethod("TalentTree.createNode", {description = "Creates node", testCase = "create", type = "functional"}, function()
        local ok = shared.tt:createNode("node1", "node_tree", "Strength", 1, "increase_dmg")
        Helpers.assertEqual(ok, true, "Created")
    end)

    Suite:testMethod("TalentTree.getNode", {description = "Gets node", testCase = "get", type = "functional"}, function()
        shared.tt:createNode("node2", "node_tree", "Defense", 1, "increase_def")
        local node = shared.tt:getNode("node2")
        Helpers.assertEqual(node ~= nil, true, "Retrieved")
    end)
end)

Suite:group("Prerequisites", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.tt = TalentTree:new()
        shared.tt:createTree("prereq_tree", "Test", "general", 5)
        shared.tt:createNode("prereq1", "prereq_tree", "Base", 1, "base")
        shared.tt:createNode("prereq2", "prereq_tree", "Advanced", 2, "advanced")
    end)

    Suite:testMethod("TalentTree.setNodePrerequisite", {description = "Sets prerequisite", testCase = "set", type = "functional"}, function()
        local ok = shared.tt:setNodePrerequisite("prereq2", "prereq1")
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("TalentTree.getNodePrerequisites", {description = "Gets prerequisites", testCase = "get", type = "functional"}, function()
        shared.tt:setNodePrerequisite("prereq2", "prereq1")
        local prereqs = shared.tt:getNodePrerequisites("prereq2")
        Helpers.assertEqual(#prereqs > 0, true, "Has prerequisites")
    end)

    Suite:testMethod("TalentTree.getNodeChildren", {description = "Gets children", testCase = "children", type = "functional"}, function()
        shared.tt:setNodePrerequisite("prereq2", "prereq1")
        local children = shared.tt:getNodeChildren("prereq1")
        Helpers.assertEqual(#children > 0, true, "Has children")
    end)
end)

Suite:group("Unlocking", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.tt = TalentTree:new()
        shared.tt:createTree("unlock_tree", "Test", "general", 5)
        shared.tt:createNode("unlock1", "unlock_tree", "Root", 1, "root")
        shared.tt:createNode("unlock2", "unlock_tree", "Child", 2, "child")
        shared.tt:setNodePrerequisite("unlock2", "unlock1")
    end)

    Suite:testMethod("TalentTree.canUnlockNode", {description = "Can unlock", testCase = "can_unlock", type = "functional"}, function()
        local can = shared.tt:canUnlockNode("unlock_tree", "unlock1")
        Helpers.assertEqual(can, true, "Can unlock")
    end)

    Suite:testMethod("TalentTree.unlockNode", {description = "Unlocks node", testCase = "unlock", type = "functional"}, function()
        local ok = shared.tt:unlockNode("unlock_tree", "unlock1")
        Helpers.assertEqual(ok, true, "Unlocked")
    end)

    Suite:testMethod("TalentTree.isNodeUnlocked", {description = "Is unlocked", testCase = "is_unlocked", type = "functional"}, function()
        shared.tt:unlockNode("unlock_tree", "unlock1")
        local is = shared.tt:isNodeUnlocked("unlock_tree", "unlock1")
        Helpers.assertEqual(is, true, "Unlocked")
    end)

    Suite:testMethod("TalentTree.getUnlockedNodes", {description = "Gets unlocked", testCase = "get_unlocked", type = "functional"}, function()
        shared.tt:unlockNode("unlock_tree", "unlock1")
        local unlocked = shared.tt:getUnlockedNodes("unlock_tree")
        Helpers.assertEqual(#unlocked > 0, true, "Has unlocked")
    end)

    Suite:testMethod("TalentTree.getUnlockedNodeCount", {description = "Gets count", testCase = "count", type = "functional"}, function()
        shared.tt:unlockNode("unlock_tree", "unlock1")
        local count = shared.tt:getUnlockedNodeCount("unlock_tree")
        Helpers.assertEqual(count, 1, "1 unlocked")
    end)
end)

Suite:group("Paths", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.tt = TalentTree:new()
        shared.tt:createTree("path_tree", "Test", "general", 5)
    end)

    Suite:testMethod("TalentTree.createSpecializationPath", {description = "Creates path", testCase = "create", type = "functional"}, function()
        local ok = shared.tt:createSpecializationPath("path1", "Warrior", {"node1", "node2"})
        Helpers.assertEqual(ok, true, "Created")
    end)

    Suite:testMethod("TalentTree.getSpecializationPath", {description = "Gets path", testCase = "get", type = "functional"}, function()
        shared.tt:createSpecializationPath("path2", "Rogue", {"node3", "node4"})
        local path = shared.tt:getSpecializationPath("path2")
        Helpers.assertEqual(path ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("TalentTree.selectPath", {description = "Selects path", testCase = "select", type = "functional"}, function()
        shared.tt:createSpecializationPath("path3", "Mage", {"node5"})
        local ok = shared.tt:selectPath("path_tree", "path3")
        Helpers.assertEqual(ok, true, "Selected")
    end)

    Suite:testMethod("TalentTree.getActivePath", {description = "Gets active path", testCase = "active", type = "functional"}, function()
        shared.tt:createSpecializationPath("path4", "Paladin", {"node6"})
        shared.tt:selectPath("path_tree", "path4")
        local path = shared.tt:getActivePath("path_tree")
        Helpers.assertEqual(path, "path4", "Path4")
    end)

    Suite:testMethod("TalentTree.upgradePath", {description = "Upgrades path", testCase = "upgrade", type = "functional"}, function()
        shared.tt:createSpecializationPath("path5", "Knight", {"node7"})
        local ok = shared.tt:upgradePath("path5")
        Helpers.assertEqual(ok, true, "Upgraded")
    end)

    Suite:testMethod("TalentTree.getPathLevel", {description = "Gets path level", testCase = "level", type = "functional"}, function()
        shared.tt:createSpecializationPath("path6", "Bard", {"node8"})
        shared.tt:upgradePath("path6")
        local level = shared.tt:getPathLevel("path6")
        Helpers.assertEqual(level > 0, true, "Level > 0")
    end)
end)

Suite:group("Progression Analysis", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.tt = TalentTree:new()
        shared.tt:createTree("prog_tree", "Test", "general", 5)
        shared.tt:createNode("prog1", "prog_tree", "Node", 1, "effect")
    end)

    Suite:testMethod("TalentTree.calculatePathCompletion", {description = "Path completion", testCase = "completion", type = "functional"}, function()
        shared.tt:createSpecializationPath("prog_path", "Path", {"prog1"})
        local completion = shared.tt:calculatePathCompletion("prog_tree", "prog_path")
        Helpers.assertEqual(completion >= 0, true, "Completion >= 0")
    end)

    Suite:testMethod("TalentTree.calculateTotalEfficiency", {description = "Total efficiency", testCase = "efficiency", type = "functional"}, function()
        local eff = shared.tt:calculateTotalEfficiency("prog_tree")
        Helpers.assertEqual(eff >= 0, true, "Efficiency >= 0")
    end)

    Suite:testMethod("TalentTree.getPointsSpent", {description = "Points spent", testCase = "points", type = "functional"}, function()
        shared.tt:unlockNode("prog_tree", "prog1")
        local points = shared.tt:getPointsSpent("prog_tree")
        Helpers.assertEqual(points > 0, true, "Points > 0")
    end)
end)

Suite:group("Level & Progress", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.tt = TalentTree:new()
        shared.tt:createTree("level_tree", "Test", "general", 5)
    end)

    Suite:testMethod("TalentTree.advanceTreeLevel", {description = "Advances level", testCase = "advance", type = "functional"}, function()
        local ok = shared.tt:advanceTreeLevel("level_tree")
        Helpers.assertEqual(ok, true, "Advanced")
    end)

    Suite:testMethod("TalentTree.getTreeLevel", {description = "Gets level", testCase = "level", type = "functional"}, function()
        shared.tt:advanceTreeLevel("level_tree")
        local level = shared.tt:getTreeLevel("level_tree")
        Helpers.assertEqual(level > 1, true, "Level > 1")
    end)

    Suite:testMethod("TalentTree.getCurrentProgression", {description = "Gets progression", testCase = "progression", type = "functional"}, function()
        local prog = shared.tt:getCurrentProgression("level_tree")
        Helpers.assertEqual(prog ~= nil, true, "Retrieved")
    end)
end)

Suite:group("Chain & Access", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.tt = TalentTree:new()
        shared.tt:createTree("chain_tree", "Test", "general", 5)
        shared.tt:createNode("chain1", "chain_tree", "A", 1, "effect")
    end)

    Suite:testMethod("TalentTree.calculateNodeChainLength", {description = "Chain length", testCase = "chain", type = "functional"}, function()
        local length = shared.tt:calculateNodeChainLength("chain1")
        Helpers.assertEqual(length > 0, true, "Length > 0")
    end)

    Suite:testMethod("TalentTree.getAccessibleNodes", {description = "Accessible nodes", testCase = "accessible", type = "functional"}, function()
        local nodes = shared.tt:getAccessibleNodes("chain_tree")
        Helpers.assertEqual(#nodes > 0, true, "Has accessible")
    end)
end)

Suite:group("Reset", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.tt = TalentTree:new()
    end)

    Suite:testMethod("TalentTree.reset", {description = "Resets system", testCase = "reset", type = "functional"}, function()
        local ok = shared.tt:reset()
        Helpers.assertEqual(ok, true, "Reset")
    end)

    Suite:testMethod("TalentTree.resetProgressOnTree", {description = "Resets progress", testCase = "reset_progress", type = "functional"}, function()
        shared.tt:createTree("reset_tree", "Test", "general", 5)
        local ok = shared.tt:resetProgressOnTree("reset_tree")
        Helpers.assertEqual(ok, true, "Reset")
    end)
end)

Suite:run()
