---TechTree - Technology dependency graph validation
---
---Manages technology tree:
---  - Validates dependencies (no circular references)
---  - Tracks unlocks and blocks
---  - Detects available research
---  - Verifies research prerequisites
---
---@module geoscape.logic.tech_tree
---@author AlienFall Development Team

local TechTree = {}

---Create a new tech tree
---@return table TechTree instance
function TechTree.new()
    return {
        entries = {},  -- Map: research_id -> ResearchEntry
        completedResearch = {},  -- Map: research_id -> true
        graph = {},  -- Dependency graph for visualization
    }
end

---Register a research entry
---@param tree table The tech tree
---@param entry table ResearchEntry instance
function TechTree.addEntry(tree, entry)
    tree.entries[entry.id] = entry
end

---Mark research as completed
---@param tree table The tech tree
---@param researchId string Research ID
---@return table unlockedIds Array of newly unlocked research IDs
function TechTree.completeResearch(tree, researchId)
    tree.completedResearch[researchId] = true
    
    local entry = tree.entries[researchId]
    if not entry then
        return {}
    end
    
    -- Collect unlocked research
    local unlocked = {}
    
    -- Direct unlocks
    for _, unlockedId in ipairs(entry.unlocksResearch) do
        if not tree.completedResearch[unlockedId] then
            table.insert(unlocked, unlockedId)
        end
    end
    
    -- Free research
    for _, freeId in ipairs(entry.givesFree) do
        if not tree.completedResearch[freeId] then
            tree.completedResearch[freeId] = true
            table.insert(unlocked, freeId)
        end
    end
    
    return unlocked
end

---Check if research is completed
---@param tree table The tech tree
---@param researchId string Research ID
---@return boolean completed True if completed
function TechTree.isCompleted(tree, researchId)
    return tree.completedResearch[researchId] or false
end

---Get available research (prerequisites met, not completed, not blocked)
---@param tree table The tech tree
---@return table availableIds Array of available research IDs
function TechTree.getAvailable(tree)
    local available = {}
    
    for researchId, entry in pairs(tree.entries) do
        -- Skip completed research
        if tree.completedResearch[researchId] then
            goto continue
        end
        
        -- Check prerequisites
        local canResearch = true
        for _, prereqId in ipairs(entry.dependsOn) do
            if not tree.completedResearch[prereqId] then
                canResearch = false
                break
            end
        end
        
        if canResearch then
            table.insert(available, researchId)
        end
        
        ::continue::
    end
    
    return available
end

---Validate tech tree (no circular dependencies)
---@param tree table The tech tree
---@return boolean valid True if tree is valid
---@return string? error Error message if invalid
function TechTree.validate(tree)
    -- Simple cycle detection using DFS
    local visited = {}
    local recStack = {}
    
    local function hasCycle(nodeId)
        visited[nodeId] = true
        recStack[nodeId] = true
        
        local entry = tree.entries[nodeId]
        if entry then
            for _, depId in ipairs(entry.dependsOn) do
                if not visited[depId] then
                    if hasCycle(depId) then
                        return true
                    end
                elseif recStack[depId] then
                    return true
                end
            end
        end
        
        recStack[nodeId] = false
        return false
    end
    
    for researchId, _ in pairs(tree.entries) do
        if not visited[researchId] then
            if hasCycle(researchId) then
                return false, "Circular dependency detected at: " .. researchId
            end
        end
    end
    
    return true, nil
end

---Get dependency chain for a research
---@param tree table The tech tree
---@param researchId string Research ID
---@return table chain Array of research IDs in dependency order
function TechTree.getDependencyChain(tree, researchId)
    local chain = {}
    local visited = {}
    
    local function traverse(nodeId)
        if visited[nodeId] then
            return
        end
        visited[nodeId] = true
        
        local entry = tree.entries[nodeId]
        if entry then
            for _, depId in ipairs(entry.dependsOn) do
                traverse(depId)
            end
        end
        
        table.insert(chain, nodeId)
    end
    
    traverse(researchId)
    return chain
end

---Print tech tree summary
---@param tree table The tech tree
function TechTree.printSummary(tree)
    print("\n[TechTree] Summary")
    print("====================================")
    print(string.format("  Total Research: %d", countTable(tree.entries)))
    print(string.format("  Completed: %d", countTable(tree.completedResearch)))
    
    local availCount = 0
    for _, _ in ipairs(TechTree.getAvailable(tree)) do
        availCount = availCount + 1
    end
    print(string.format("  Available: %d", availCount))
    print("====================================\n")
end

-- Helper function to count table entries
function countTable(tbl)
    local count = 0
    for _, _ in pairs(tbl) do
        count = count + 1
    end
    return count
end

return TechTree




