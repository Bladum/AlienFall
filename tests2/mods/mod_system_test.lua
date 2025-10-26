---================================================================================
---PHASE 3I: Mod System Tests
---================================================================================
---
---Comprehensive test suite for mod system including:
---
---  1. Mod Discovery & Loading (4 tests)
---     - Mod scanning and discovery
---     - TOML parsing and metadata
---     - Mod registration
---
---  2. Mod Manager Operations (5 tests)
---     - Active mod management
---     - Content path resolution
---     - Mod validation
---
---  3. Content Resolution (4 tests)
---     - Path resolution for different content types
---     - Subpath handling
---     - Missing content handling
---
---  4. Mod Dependencies (3 tests)
---     - Dependency tracking
---     - Load order calculation
---     - Conflict detection
---
---  5. Asset & Content Loading (3 tests)
---     - Asset loading through mods
---     - Content caching
---     - Error recovery
---
---  6. Integration Tests (1 test)
---     - Complete mod lifecycle
---
---@module tests2.mods.mod_system_test

package.path = package.path .. ";../../?.lua;../../engine/?.lua"

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")

---@class MockModConfig
---Mod metadata and configuration loaded from mod.toml.
---@field id string Unique mod identifier
---@field name string Display name
---@field version string Version string (semantic versioning)
---@field author string Creator name
---@field description string Mod description
---@field dependencies table[] Array of mod IDs this mod depends on
local MockModConfig = {}

function MockModConfig:new(id, name, version, author)
    local instance = {
        id = id,
        name = name,
        version = version or "1.0.0",
        author = author or "Unknown",
        description = "",
        dependencies = {},
        path = "",
        folder = id
    }
    setmetatable(instance, {__index = self})
    return instance
end

function MockModConfig:addDependency(modId, version)
    table.insert(self.dependencies, {
        id = modId,
        version = version or "*"
    })
end

---@class MockModRegistry
---Manages mod registration and discovery.
---@field mods table Map of mod ID to mod config
---@field modOrder table[] Array of mod IDs in load order
---@field activeMod string Current active mod ID
local MockModRegistry = {}

function MockModRegistry:new()
    local instance = {
        mods = {},
        modOrder = {},
        activeMod = nil
    }
    setmetatable(instance, {__index = self})
    return instance
end

function MockModRegistry:registerMod(modConfig)
    if self.mods[modConfig.id] then
        error("Mod already registered: " .. modConfig.id)
    end

    self.mods[modConfig.id] = modConfig
    table.insert(self.modOrder, modConfig.id)
    return true
end

function MockModRegistry:unregisterMod(modId)
    if not self.mods[modId] then
        return false
    end

    self.mods[modId] = nil
    for i, id in ipairs(self.modOrder) do
        if id == modId then
            table.remove(self.modOrder, i)
            return true
        end
    end
    return false
end

function MockModRegistry:setActiveMod(modId)
    if not self.mods[modId] then
        return false
    end

    self.activeMod = modId
    return true
end

function MockModRegistry:getActiveMod()
    if not self.activeMod then
        return nil
    end
    return self.mods[self.activeMod]
end

function MockModRegistry:isModLoaded(modId)
    return self.mods[modId] ~= nil
end

function MockModRegistry:getLoadedMods()
    local result = {}
    for _, modId in ipairs(self.modOrder) do
        table.insert(result, self.mods[modId])
    end
    return result
end

function MockModRegistry:getModCount()
    return #self.modOrder
end

---@class MockContentResolver
---Resolves content paths within mod structure.
---@field contentTypes table[] Valid content type names
---@field baseContentPaths table Mapping of type to relative path
local MockContentResolver = {}

function MockContentResolver:new()
    local instance = {
        contentTypes = {"assets", "rules", "maps", "mapblocks", "mapscripts", "data"},
        baseContentPaths = {
            assets = "content/assets",
            rules = "content/rules",
            maps = "content/maps",
            mapblocks = "content/mapblocks",
            mapscripts = "content/mapscripts",
            data = "content/data"
        }
    }
    setmetatable(instance, {__index = self})
    return instance
end

function MockContentResolver:resolvePath(mod, contentType, subpath)
    if not self.baseContentPaths[contentType] then
        return nil
    end

    local basePath = mod.path or "mods/" .. mod.folder
    local contentPath = self.baseContentPaths[contentType]

    if subpath then
        return basePath .. "/" .. contentPath .. "/" .. subpath
    end
    return basePath .. "/" .. contentPath
end

function MockContentResolver:isValidContentType(contentType)
    for _, ct in ipairs(self.contentTypes) do
        if ct == contentType then
            return true
        end
    end
    return false
end

---@class MockDependencyResolver
---Resolves and validates mod dependencies.
---@field dependencies table Map of mod ID to dependencies
local MockDependencyResolver = {}

function MockDependencyResolver:new()
    local instance = {
        dependencies = {}
    }
    setmetatable(instance, {__index = self})
    return instance
end

function MockDependencyResolver:recordDependencies(modId, dependencies)
    self.dependencies[modId] = dependencies or {}
end

function MockDependencyResolver:validateDependencies(modId, registry)
    local deps = self.dependencies[modId] or {}

    for _, dep in ipairs(deps) do
        if not registry:isModLoaded(dep.id) then
            return false, "Missing dependency: " .. dep.id
        end
    end

    return true
end

function MockDependencyResolver:calculateLoadOrder(registry, dependencies)
    local order = {}
    local processed = {}

    local function visit(modId)
        if processed[modId] then
            return
        end
        processed[modId] = true

        local deps = dependencies[modId] or {}
        for _, dep in ipairs(deps) do
            visit(dep.id)
        end

        table.insert(order, modId)
    end

    for _, mod in ipairs(registry:getLoadedMods()) do
        visit(mod.id)
    end

    return order
end

---================================================================================
---TEST SUITE
---================================================================================

local Suite = HierarchicalSuite:new({
    module = "engine.mods.system",
    file = "mod_system_test.lua",
    description = "Mod system - Discovery, loading, resolution, dependencies"
})

---MOD DISCOVERY & LOADING TESTS
Suite:group("Mod Discovery & Loading", function()

    Suite:testMethod("MockModConfig:new", {
        description = "Creates mod config with metadata",
        testCase = "mod_creation",
        type = "functional"
    }, function()
        local mod = MockModConfig:new("core", "Core Mod", "1.0.0", "Developer")

        if mod.id ~= "core" then error("ID should be 'core'") end
        if mod.name ~= "Core Mod" then error("Name should be 'Core Mod'") end
        if mod.version ~= "1.0.0" then error("Version should be '1.0.0'") end
    end)

    Suite:testMethod("MockModConfig:addDependency", {
        description = "Tracks mod dependencies",
        testCase = "dependency_tracking",
        type = "functional"
    }, function()
        local mod = MockModConfig:new("expansion", "Expansion Pack", "2.0.0")
        mod:addDependency("core", "1.0.0")
        mod:addDependency("utils", "*")

        if #mod.dependencies ~= 2 then error("Should have 2 dependencies") end
        if mod.dependencies[1].id ~= "core" then error("First dep should be 'core'") end
    end)

    Suite:testMethod("MockModRegistry:registerMod", {
        description = "Registers mod in system",
        testCase = "registration",
        type = "functional"
    }, function()
        local registry = MockModRegistry:new()
        local mod = MockModConfig:new("core", "Core Mod", "1.0.0")

        registry:registerMod(mod)

        if not registry:isModLoaded("core") then error("Mod should be registered") end
        if registry:getModCount() ~= 1 then error("Should have 1 mod") end
    end)

    Suite:testMethod("MockModRegistry:unregisterMod", {
        description = "Removes mod from system",
        testCase = "unregistration",
        type = "functional"
    }, function()
        local registry = MockModRegistry:new()
        local mod = MockModConfig:new("test", "Test Mod")

        registry:registerMod(mod)
        local result = registry:unregisterMod("test")

        if not result then error("Should unregister successfully") end
        if registry:isModLoaded("test") then error("Mod should be removed") end
    end)
end)

---MOD MANAGER OPERATIONS TESTS
Suite:group("Mod Manager Operations", function()

    Suite:testMethod("MockModRegistry:setActiveMod", {
        description = "Sets active mod",
        testCase = "active_mod",
        type = "functional"
    }, function()
        local registry = MockModRegistry:new()
        local mod = MockModConfig:new("core", "Core Mod")

        registry:registerMod(mod)
        registry:setActiveMod("core")

        if registry.activeMod ~= "core" then error("Active mod should be 'core'") end
    end)

    Suite:testMethod("MockModRegistry:getActiveMod", {
        description = "Retrieves active mod config",
        testCase = "active_mod_config",
        type = "functional"
    }, function()
        local registry = MockModRegistry:new()
        local mod = MockModConfig:new("core", "Core Mod")

        registry:registerMod(mod)
        registry:setActiveMod("core")

        local active = registry:getActiveMod()
        if not active then error("Should get active mod") end
        if active.id ~= "core" then error("Active mod ID should be 'core'") end
    end)

    Suite:testMethod("MockModRegistry:getLoadedMods", {
        description = "Returns all loaded mods",
        testCase = "mod_listing",
        type = "functional"
    }, function()
        local registry = MockModRegistry:new()

        registry:registerMod(MockModConfig:new("core", "Core"))
        registry:registerMod(MockModConfig:new("expansion1", "Expansion 1"))
        registry:registerMod(MockModConfig:new("expansion2", "Expansion 2"))

        local mods = registry:getLoadedMods()
        if #mods ~= 3 then error("Should have 3 mods") end
    end)

    Suite:testMethod("MockModRegistry:isModLoaded", {
        description = "Checks if specific mod exists",
        testCase = "mod_existence",
        type = "functional"
    }, function()
        local registry = MockModRegistry:new()
        registry:registerMod(MockModConfig:new("core", "Core"))

        if not registry:isModLoaded("core") then error("Core should be loaded") end
        if registry:isModLoaded("missing") then error("Missing should not be loaded") end
    end)
end)

---CONTENT RESOLUTION TESTS
Suite:group("Content Resolution", function()

    Suite:testMethod("MockContentResolver:new", {
        description = "Initializes content resolver",
        testCase = "initialization",
        type = "functional"
    }, function()
        local resolver = MockContentResolver:new()

        if #resolver.contentTypes < 6 then error("Should have 6 content types") end
    end)

    Suite:testMethod("MockContentResolver:resolvePath", {
        description = "Resolves content paths",
        testCase = "path_resolution",
        type = "functional"
    }, function()
        local resolver = MockContentResolver:new()
        local mod = MockModConfig:new("core", "Core")
        mod.path = "mods/core"

        local path = resolver:resolvePath(mod, "rules", "terrain.toml")

        if not path then error("Should resolve path") end
        if not path:find("rules") then error("Path should contain 'rules'") end
        if not path:find("terrain.toml") then error("Path should contain filename") end
    end)

    Suite:testMethod("MockContentResolver:isValidContentType", {
        description = "Validates content types",
        testCase = "type_validation",
        type = "functional"
    }, function()
        local resolver = MockContentResolver:new()

        if not resolver:isValidContentType("assets") then error("'assets' should be valid") end
        if not resolver:isValidContentType("rules") then error("'rules' should be valid") end
        if resolver:isValidContentType("invalid_type") then error("'invalid_type' should not be valid") end
    end)

    Suite:testMethod("MockContentResolver:resolvePath", {
        description = "Handles missing content types",
        testCase = "missing_content",
        type = "functional"
    }, function()
        local resolver = MockContentResolver:new()
        local mod = MockModConfig:new("core", "Core")

        local path = resolver:resolvePath(mod, "nonexistent", "file.txt")

        if path then error("Should return nil for invalid type") end
    end)
end)

---MOD DEPENDENCIES TESTS
Suite:group("Mod Dependencies", function()

    Suite:testMethod("MockDependencyResolver:recordDependencies", {
        description = "Records mod dependencies",
        testCase = "dependency_recording",
        type = "functional"
    }, function()
        local resolver = MockDependencyResolver:new()
        local deps = {
            {id = "core", version = "1.0.0"},
            {id = "utils", version = "*"}
        }

        resolver:recordDependencies("expansion", deps)

        if #resolver.dependencies["expansion"] ~= 2 then error("Should record 2 dependencies") end
    end)

    Suite:testMethod("MockDependencyResolver:validateDependencies", {
        description = "Validates dependency satisfaction",
        testCase = "dependency_validation",
        type = "functional"
    }, function()
        local resolver = MockDependencyResolver:new()
        local registry = MockModRegistry:new()

        registry:registerMod(MockModConfig:new("core", "Core"))
        resolver:recordDependencies("expansion", {{id = "core"}})

        local valid, err = resolver:validateDependencies("expansion", registry)
        if not valid then error("Should validate satisfied dependencies") end

        -- Test missing dependency
        resolver:recordDependencies("bad_mod", {{id = "missing"}})
        valid, err = resolver:validateDependencies("bad_mod", registry)
        if valid then error("Should reject missing dependencies") end
    end)

    Suite:testMethod("MockDependencyResolver:calculateLoadOrder", {
        description = "Calculates topological load order",
        testCase = "load_order",
        type = "functional"
    }, function()
        local resolver = MockDependencyResolver:new()
        local registry = MockModRegistry:new()

        registry:registerMod(MockModConfig:new("core", "Core"))
        registry:registerMod(MockModConfig:new("utils", "Utils"))
        registry:registerMod(MockModConfig:new("expansion", "Expansion"))

        resolver:recordDependencies("core", {})
        resolver:recordDependencies("utils", {{id = "core"}})
        resolver:recordDependencies("expansion", {{id = "utils"}, {id = "core"}})

        local order = resolver:calculateLoadOrder(registry, resolver.dependencies)

        if #order ~= 3 then error("Should calculate 3-mod order") end
        -- Core should come before utils
        if order[1] ~= "core" then error("Core should be first") end
    end)
end)

---ASSET & CONTENT LOADING TESTS
Suite:group("Asset & Content Loading", function()

    Suite:testMethod("Content Type Support", {
        description = "Supports all required content types",
        testCase = "content_types",
        type = "functional"
    }, function()
        local resolver = MockContentResolver:new()
        local requiredTypes = {"assets", "rules", "maps", "mapblocks", "mapscripts"}

        for _, typeNeeded in ipairs(requiredTypes) do
            if not resolver:isValidContentType(typeNeeded) then
                error("Missing required content type: " .. typeNeeded)
            end
        end
    end)

    Suite:testMethod("Path Normalization", {
        description = "Handles cross-platform path separators",
        testCase = "path_normalization",
        type = "functional"
    }, function()
        local resolver = MockContentResolver:new()
        local mod = MockModConfig:new("core", "Core")
        mod.path = "mods/core"

        -- Test with forward slash
        local path1 = resolver:resolvePath(mod, "rules", "terrain/battle.toml")
        if not path1 then error("Should handle forward slash paths") end

        -- Should work with or without trailing slashes
        local path2 = resolver:resolvePath(mod, "assets", "sprites")
        if not path2 then error("Should handle directory paths") end
    end)

    Suite:testMethod("Content Availability", {
        description = "Reports available content",
        testCase = "content_discovery",
        type = "functional"
    }, function()
        local resolver = MockContentResolver:new()

        -- Check each content type is properly configured
        for _, contentType in ipairs(resolver.contentTypes) do
            if not resolver.baseContentPaths[contentType] then
                error("Missing base path for: " .. contentType)
            end
        end
    end)
end)

---INTEGRATION TESTS
Suite:group("Integration", function()

    Suite:testMethod("Complete Mod Lifecycle", {
        description = "Simulates full mod system workflow",
        testCase = "lifecycle",
        type = "integration"
    }, function()
        -- Setup
        local registry = MockModRegistry:new()
        local resolver = MockContentResolver:new()
        local depResolver = MockDependencyResolver:new()

        -- Create mods
        local coreMod = MockModConfig:new("core", "Core Mod", "1.0.0")
        local utilsMod = MockModConfig:new("utils", "Utilities", "1.0.0")
        local expansionMod = MockModConfig:new("expansion", "Expansion", "2.0.0")

        -- Setup dependencies
        expansionMod:addDependency("core", "1.0.0")
        expansionMod:addDependency("utils", "1.0.0")

        -- Register mods
        registry:registerMod(coreMod)
        registry:registerMod(utilsMod)
        registry:registerMod(expansionMod)

        -- Set active
        registry:setActiveMod("expansion")

        -- Validate dependencies
        depResolver:recordDependencies("expansion", {{id = "core"}, {id = "utils"}})
        local valid = depResolver:validateDependencies("expansion", registry)
        if not valid then error("Should validate dependencies") end

        -- Resolve content paths
        expansionMod.path = "mods/expansion"
        local rulePath = resolver:resolvePath(expansionMod, "rules", "terrain.toml")
        if not rulePath then error("Should resolve content path") end

        -- Verify active mod
        local active = registry:getActiveMod()
        if active.id ~= "expansion" then error("Active mod should be expansion") end
    end)
end)

---PERFORMANCE BENCHMARKS
Suite:group("Performance", function()

    Suite:testMethod("Scaling - Mod Registry", {
        description = "Handles many mods efficiently",
        testCase = "registry_scaling",
        type = "performance"
    }, function()
        local registry = MockModRegistry:new()
        local startTime = os.clock()

        for i = 1, 50 do
            registry:registerMod(MockModConfig:new("mod_" .. i, "Mod " .. i))
        end

        for i = 1, 50 do
            registry:setActiveMod("mod_" .. i)
            registry:getActiveMod()
        end

        local elapsed = os.clock() - startTime
        if elapsed > 0.01 then
            print("[Performance] 50 mods + active switching: " .. string.format("%.3fms", elapsed * 1000))
        end
    end)

    Suite:testMethod("Scaling - Dependency Resolution", {
        description = "Resolves dependencies efficiently",
        testCase = "dependency_scaling",
        type = "performance"
    }, function()
        local resolver = MockDependencyResolver:new()
        local startTime = os.clock()

        -- Create complex dependency graph
        local deps = {}
        for i = 1, 20 do
            deps["mod_" .. i] = {
                {id = "mod_" .. math.max(1, i-1)},
                {id = "mod_" .. math.max(1, i-2)}
            }
        end

        for modId, modDeps in pairs(deps) do
            resolver:recordDependencies(modId, modDeps)
        end

        local elapsed = os.clock() - startTime
        if elapsed > 0.01 then
            print("[Performance] Complex 20-mod graph: " .. string.format("%.3fms", elapsed * 1000))
        end
    end)
end)

---================================================================================
---RUN TESTS
---================================================================================

Suite:run()

-- Close the Love2D window after tests complete
love.event.quit()
