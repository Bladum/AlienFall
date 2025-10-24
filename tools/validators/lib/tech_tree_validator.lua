-- tech_tree_validator.lua
-- Validates research tech tree structure
-- Checks: no circular dependencies, no orphaned techs, valid start techs

local TechTreeValidator = {}

-- Add error
local function addError(errors, message, techs, researchId)
  table.insert(errors, {
    type = "circular_dependency",
    message = message,
    techs = techs,
    research = researchId,
    severity = "error",
  })
end

-- Add warning
local function addWarning(warnings, type, message, techId)
  table.insert(warnings, {
    type = type,
    message = message,
    tech = techId,
    severity = "warning",
  })
end

-- Validate tech tree
function TechTreeValidator.validate(research, index)
  local errors = {}
  local warnings = {}
  
  -- Build dependency graph
  local graph = TechTreeValidator.buildGraph(research)
  
  -- Check for circular dependencies
  local circularDeps = TechTreeValidator.findCircularDependencies(graph, research)
  for _, cycle in ipairs(circularDeps) do
    local message = "Circular dependency detected: " .. table.concat(cycle, " -> ")
    addError(errors, message, cycle)
  end
  
  -- Check for orphaned techs (unreachable from starting techs)
  local orphaned = TechTreeValidator.findOrphanedTechs(graph, research)
  for _, techId in ipairs(orphaned) do
    addWarning(warnings, "orphaned_tech",
      "Tech is unreachable (no path from starting techs): " .. techId, techId)
  end
  
  -- Check for missing prerequisite techs
  local missingPrereqs = TechTreeValidator.checkMissingPrerequisites(research, index)
  for _, info in ipairs(missingPrereqs) do
    table.insert(errors, {
      type = "missing_prerequisite",
      message = "Research " .. info.researchId .. " requires non-existent tech: " .. info.missingTech,
      research = info.researchId,
      missing_tech = info.missingTech,
      severity = "error",
    })
  end
  
  return errors, warnings
end

-- Build dependency graph
function TechTreeValidator.buildGraph(research)
  local graph = {}
  
  for techId, techData in pairs(research) do
    if techData and techData.data then
      local requires = techData.data.requires or {}
      if type(requires) ~= "table" then
        requires = {requires}
      end
      
      graph[techId] = {
        prerequisites = requires,
        unlocks = {},
      }
    end
  end
  
  -- Build reverse edges (what each tech unlocks)
  for techId, node in pairs(graph) do
    for _, prerequisiteId in ipairs(node.prerequisites) do
      if prerequisiteId and graph[prerequisiteId] then
        table.insert(graph[prerequisiteId].unlocks, techId)
      end
    end
  end
  
  return graph
end

-- Find circular dependencies using DFS
function TechTreeValidator.findCircularDependencies(graph, research)
  local cycles = {}
  local visited = {}
  local recursionStack = {}
  local path = {}
  
  local function dfs(techId)
    if recursionStack[techId] then
      -- Found cycle - trace back to find it
      local cycleStart = nil
      for i = #path, 1, -1 do
        if path[i] == techId then
          cycleStart = i
          break
        end
      end
      
      if cycleStart then
        local cycle = {}
        for i = cycleStart, #path do
          table.insert(cycle, path[i])
        end
        table.insert(cycle, techId)  -- close the cycle
        table.insert(cycles, cycle)
      end
      
      return
    end
    
    if visited[techId] then
      return
    end
    
    visited[techId] = true
    recursionStack[techId] = true
    table.insert(path, techId)
    
    local node = graph[techId]
    if node then
      for _, prerequisiteId in ipairs(node.prerequisites) do
        if prerequisiteId then
          dfs(prerequisiteId)
        end
      end
    end
    
    table.remove(path)
    recursionStack[techId] = false
  end
  
  -- DFS from each unvisited node
  for techId in pairs(graph) do
    if not visited[techId] then
      dfs(techId)
    end
  end
  
  return cycles
end

-- Find orphaned techs (unreachable from starting techs)
function TechTreeValidator.findOrphanedTechs(graph, research)
  -- Find all starting techs (techs with no prerequisites)
  local startingTechs = {}
  for techId, techData in pairs(research) do
    if techData and techData.data then
      local requires = techData.data.requires or {}
      if type(requires) ~= "table" then
        requires = {requires}
      end
      
      if #requires == 0 then
        table.insert(startingTechs, techId)
      end
    end
  end
  
  -- BFS to find all reachable techs
  local reachable = {}
  local queue = {}
  
  for _, startTech in ipairs(startingTechs) do
    table.insert(queue, startTech)
    reachable[startTech] = true
  end
  
  while #queue > 0 do
    local current = table.remove(queue, 1)
    local node = graph[current]
    
    if node then
      for _, unlockedTech in ipairs(node.unlocks) do
        if not reachable[unlockedTech] then
          reachable[unlockedTech] = true
          table.insert(queue, unlockedTech)
        end
      end
    end
  end
  
  -- Find unreachable techs
  local orphaned = {}
  for techId in pairs(research) do
    if not reachable[techId] then
      table.insert(orphaned, techId)
    end
  end
  
  return orphaned
end

-- Check for missing prerequisite techs
function TechTreeValidator.checkMissingPrerequisites(research, index)
  local missing = {}
  
  for researchId, researchData in pairs(research) do
    if researchData and researchData.data then
      local requires = researchData.data.requires or {}
      if type(requires) ~= "table" then
        requires = {requires}
      end
      
      for _, prerequisiteId in ipairs(requires) do
        if prerequisiteId then
          local entry = index.byId[prerequisiteId]
          if not entry then
            table.insert(missing, {
              researchId = researchId,
              missingTech = prerequisiteId,
            })
          end
        end
      end
    end
  end
  
  return missing
end

-- Check tech tree integrity
function TechTreeValidator.validateIntegrity(research, index)
  local warnings = {}
  
  -- Check for techs with no unlocks (dead ends)
  for researchId, researchData in pairs(research) do
    if researchData and researchData.data then
      local unlocksItems = researchData.data.unlocks_items or {}
      local unlocksUnits = researchData.data.unlocks_units or {}
      local unlocksTechs = researchData.data.unlocks_techs or {}
      
      if type(unlocksItems) ~= "table" then unlocksItems = {unlocksItems} end
      if type(unlocksUnits) ~= "table" then unlocksUnits = {unlocksUnits} end
      if type(unlocksTechs) ~= "table" then unlocksTechs = {unlocksTechs} end
      
      local totalUnlocks = #unlocksItems + #unlocksUnits + #unlocksTechs
      
      if totalUnlocks == 0 then
        addWarning(warnings, "no_unlocks",
          "Tech " .. researchId .. " doesn't unlock anything (dead end)", researchId)
      end
    end
  end
  
  return warnings
end

return TechTreeValidator
