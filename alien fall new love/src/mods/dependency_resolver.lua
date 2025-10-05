--- Dependency Resolver
--
-- Resolves mod dependencies and determines load order using topological sort.
-- Detects circular dependencies and validates dependency chains.
--
-- GROK: This ensures mods are loaded in the correct order so that
-- dependencies are available before dependents try to use them.
--
-- @module mods.dependency_resolver
-- @usage local resolver = require "mods.dependency_resolver"
--        local loadOrder, err = resolver.resolve(mods)

local dependency_resolver = {}

--- Resolve dependencies and determine load order
-- Uses topological sort (Kahn's algorithm) to order mods
-- @param mods table: Map of mod_id -> mod manifest
-- @return table: Ordered array of mod_ids, or nil if circular dependency
-- @return string: Error message if failed
function dependency_resolver.resolve(mods)
    -- Build dependency graph
    local graph = {}
    local inDegree = {}
    
    -- Initialize
    for modId, mod in pairs(mods) do
        graph[modId] = mod.dependencies or {}
        inDegree[modId] = 0
    end
    
    -- Calculate in-degrees
    for modId, deps in pairs(graph) do
        for _, depId in ipairs(deps) do
            if not mods[depId] then
                return nil, string.format("Mod '%s' depends on missing mod '%s'", modId, depId)
            end
            inDegree[depId] = (inDegree[depId] or 0) + 1
        end
    end
    
    -- Find mods with no dependencies (in-degree = 0)
    local queue = {}
    for modId, degree in pairs(inDegree) do
        if degree == 0 then
            table.insert(queue, modId)
        end
    end
    
    -- Sort by priority within same dependency level
    table.sort(queue, function(a, b)
        local priorityA = mods[a].priority or 100
        local priorityB = mods[b].priority or 100
        return priorityA < priorityB
    end)
    
    -- Topological sort (Kahn's algorithm)
    local loadOrder = {}
    local visited = 0
    
    while #queue > 0 do
        -- Remove mod from queue
        local currentId = table.remove(queue, 1)
        table.insert(loadOrder, currentId)
        visited = visited + 1
        
        -- For each mod that depends on current
        for modId, deps in pairs(graph) do
            for i, depId in ipairs(deps) do
                if depId == currentId then
                    -- Remove dependency
                    table.remove(deps, i)
                    inDegree[modId] = inDegree[modId] - 1
                    
                    -- If all dependencies satisfied, add to queue
                    if inDegree[modId] == 0 then
                        table.insert(queue, modId)
                    end
                    break
                end
            end
        end
        
        -- Re-sort queue by priority
        table.sort(queue, function(a, b)
            local priorityA = mods[a].priority or 100
            local priorityB = mods[b].priority or 100
            return priorityA < priorityB
        end)
    end
    
    -- Check for circular dependencies
    if visited ~= table.maxn(mods) then
        -- Find mods still in graph (circular dependency)
        local circular = {}
        for modId, _ in pairs(mods) do
            local found = false
            for _, loadedId in ipairs(loadOrder) do
                if loadedId == modId then
                    found = true
                    break
                end
            end
            if not found then
                table.insert(circular, modId)
            end
        end
        
        return nil, string.format("Circular dependency detected in mods: %s", 
            table.concat(circular, ", "))
    end
    
    return loadOrder, nil
end

--- Validate a single mod's dependencies
-- @param mod table: Mod manifest
-- @param availableMods table: Map of available mod_ids
-- @return boolean: True if all dependencies available
-- @return table: Array of missing dependency IDs
function dependency_resolver.validateDependencies(mod, availableMods)
    local missing = {}
    
    if mod.dependencies then
        for _, depId in ipairs(mod.dependencies) do
            if not availableMods[depId] then
                table.insert(missing, depId)
            end
        end
    end
    
    return #missing == 0, missing
end

--- Get dependency chain for a mod
-- @param modId string: Mod ID to get chain for
-- @param mods table: Map of mod_id -> mod manifest
-- @return table: Array of mod_ids in dependency chain (deepest first)
function dependency_resolver.getDependencyChain(modId, mods)
    local chain = {}
    local visited = {}
    
    local function traverse(id)
        if visited[id] then
            return -- Already processed
        end
        visited[id] = true
        
        local mod = mods[id]
        if mod and mod.dependencies then
            for _, depId in ipairs(mod.dependencies) do
                traverse(depId)
            end
        end
        
        table.insert(chain, id)
    end
    
    traverse(modId)
    return chain
end

--- Count dependents for each mod (how many depend on it)
-- @param mods table: Map of mod_id -> mod manifest
-- @return table: Map of mod_id -> count of dependents
function dependency_resolver.countDependents(mods)
    local counts = {}
    
    -- Initialize counts
    for modId, _ in pairs(mods) do
        counts[modId] = 0
    end
    
    -- Count dependencies
    for _, mod in pairs(mods) do
        if mod.dependencies then
            for _, depId in ipairs(mod.dependencies) do
                counts[depId] = (counts[depId] or 0) + 1
            end
        end
    end
    
    return counts
end

return dependency_resolver
