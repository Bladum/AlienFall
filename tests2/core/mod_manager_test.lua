-- TEST: Mod Manager
local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local ModManager = {}
ModManager.__index = ModManager

function ModManager:new()
    local self = setmetatable({}, ModManager)
    self.mods = {}
    self.activeMod = nil
    self.modOrder = {}
    return self
end

function ModManager:addMod(modId, metadata)
    if not modId or self.mods[modId] then error("[ModManager] Invalid mod") end
    self.mods[modId] = metadata or {id = modId, name = modId, version = "1.0"}
    table.insert(self.modOrder, modId)
    return true
end

function ModManager:setActiveMod(modId)
    if not modId or not self.mods[modId] then error("[ModManager] Mod not found") end
    self.activeMod = self.mods[modId]
    return true
end

function ModManager:getActiveMod()
    return self.activeMod
end

function ModManager:getMods()
    return self.mods
end

function ModManager:getContentPath(contentType, ...)
    if not self.activeMod then error("[ModManager] No active mod") end
    if not contentType then error("[ModManager] Invalid content type") end

    local parts = {contentType, ...}
    return table.concat(parts, "/")
end

function ModManager:removeMod(modId)
    if not modId or not self.mods[modId] then error("[ModManager] Mod not found") end
    self.mods[modId] = nil
    for i, id in ipairs(self.modOrder) do
        if id == modId then table.remove(self.modOrder, i) break end
    end
    return true
end

local Suite = HierarchicalSuite:new({
    modulePath = "engine.core.mod_manager",
    fileName = "mod_manager.lua",
    description = "Mod loading and content resolution system"
})

Suite:before(function() print("[ModManager] Setting up") end)

Suite:group("Mod Registration", function()
    local shared = {}
    Suite:beforeEach(function() shared.mgr = ModManager:new() end)

    Suite:testMethod("ModManager.addMod", {description="Adds mod to registry", testCase="happy_path", type="functional"},
    function()
        shared.mgr:addMod("core")
        Helpers.assertEqual(shared.mgr.mods["core"] ~= nil, true, "Mod should exist")
        print("  ✓ Mod added")
    end)

    Suite:testMethod("ModManager.getMods", {description="Returns all mods", testCase="query", type="functional"},
    function()
        shared.mgr:addMod("core")
        shared.mgr:addMod("extended")
        local mods = shared.mgr:getMods()
        Helpers.assertEqual(mods["core"] ~= nil, true, "Should have core")
        Helpers.assertEqual(mods["extended"] ~= nil, true, "Should have extended")
        print("  ✓ Mods retrieved")
    end)
end)

Suite:group("Mod Activation", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.mgr = ModManager:new()
        shared.mgr:addMod("core", {id = "core", name = "Core"})
    end)

    Suite:testMethod("ModManager.setActiveMod", {description="Sets active mod", testCase="activation", type="functional"},
    function()
        shared.mgr:setActiveMod("core")
        Helpers.assertEqual(shared.mgr.activeMod ~= nil, true, "Active mod set")
        print("  ✓ Mod activated")
    end)

    Suite:testMethod("ModManager.getActiveMod", {description="Gets active mod", testCase="query", type="functional"},
    function()
        shared.mgr:setActiveMod("core")
        local active = shared.mgr:getActiveMod()
        Helpers.assertEqual(active.id, "core", "Should be core mod")
        print("  ✓ Active mod retrieved")
    end)
end)

Suite:group("Content Resolution", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.mgr = ModManager:new()
        shared.mgr:addMod("core")
        shared.mgr:setActiveMod("core")
    end)

    Suite:testMethod("ModManager.getContentPath", {description="Resolves content path", testCase="path", type="functional"},
    function()
        local path = shared.mgr:getContentPath("rules", "battle", "terrain.toml")
        Helpers.assertEqual(path, "rules/battle/terrain.toml", "Should resolve path")
        print("  ✓ Content path resolved")
    end)

    Suite:testMethod("ModManager.getContentPath no mod", {description="Errors without active mod", testCase="error_handling", type="error"},
    function()
        local mgr = ModManager:new()
        local ok, err = pcall(function() mgr:getContentPath("rules") end)
        Helpers.assertEqual(ok, false, "Should error")
        print("  ✓ Error handled")
    end)
end)

Suite:group("Mod Lifecycle", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.mgr = ModManager:new()
        shared.mgr:addMod("core")
        shared.mgr:addMod("extended")
    end)

    Suite:testMethod("ModManager.removeMod", {description="Removes mod", testCase="lifecycle", type="functional"},
    function()
        shared.mgr:removeMod("extended")
        Helpers.assertEqual(shared.mgr.mods["extended"], nil, "Should be removed")
        print("  ✓ Mod removed")
    end)

    Suite:testMethod("ModManager modOrder", {description="Tracks mod order", testCase="order", type="functional"},
    function()
        Helpers.assertEqual(shared.mgr.modOrder[1], "core", "First should be core")
        Helpers.assertEqual(shared.mgr.modOrder[2], "extended", "Second should be extended")
        print("  ✓ Mod order tracked")
    end)
end)

return Suite
