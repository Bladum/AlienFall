--- Research Tree Class
-- Dynamically builds research tree structure from research data
--
-- @classmod engine.research.ResearchTree

local class = require 'lib.Middleclass'

ResearchTree = class('ResearchTree')

--- Create a new research tree instance
-- @param research_data Array of research entries from TOML data
-- @return ResearchTree instance
function ResearchTree:initialize(research_data)
    -- Store research data
    self.research_data = research_data or {}

    -- Build the tree structure
    self:build_tree()
end

--- Build the research tree structure from research data
function ResearchTree:build_tree()
    self.nodes = {}        -- All research nodes by ID
    self.categories = {}   -- Research grouped by category
    self.roots = {}        -- Root nodes (no prerequisites)
    self.leaves = {}       -- Leaf nodes (no dependents)

    -- First pass: create all nodes
    for _, research in ipairs(self.research_data) do
        local node = {
            id = research.id,
            name = research.name,
            category = research.category or "general",
            tier = research.metadata and research.metadata.tier or 1,
            prerequisites = research.prerequisites and research.prerequisites.research or {},
            dependents = {},  -- Will be filled in second pass
            unlocks = research.unlocks or {},
            completed = false,
            available = false,
            in_progress = false
        }
        self.nodes[research.id] = node

        -- Group by category
        if not self.categories[node.category] then
            self.categories[node.category] = {}
        end
        table.insert(self.categories[node.category], node)
    end

    -- Second pass: build relationships
    for _, node in pairs(self.nodes) do
        -- Link prerequisites
        for _, prereq_id in ipairs(node.prerequisites) do
            if self.nodes[prereq_id] then
                table.insert(self.nodes[prereq_id].dependents, node.id)
            end
        end

        -- Identify roots and leaves
        if #node.prerequisites == 0 then
            table.insert(self.roots, node.id)
        end

        if #node.dependents == 0 then
            table.insert(self.leaves, node.id)
        end
    end

    -- Calculate tiers based on prerequisites
    self:calculate_tiers()

    -- Update availability
    self:update_availability()
end

--- Calculate research tiers based on prerequisite depth
function ResearchTree:calculate_tiers()
    local visited = {}
    local visiting = {}

    local function calculate_node_tier(node_id)
        if visited[node_id] then
            return self.nodes[node_id].calculated_tier
        end

        if visiting[node_id] then
            -- Circular dependency detected
            return 1
        end

        visiting[node_id] = true

        local node = self.nodes[node_id]
        local max_prereq_tier = 0

        for _, prereq_id in ipairs(node.prerequisites) do
            local prereq_tier = calculate_node_tier(prereq_id)
            max_prereq_tier = math.max(max_prereq_tier, prereq_tier)
        end

        node.calculated_tier = max_prereq_tier + 1
        visited[node_id] = true
        visiting[node_id] = nil

        return node.calculated_tier
    end

    -- Calculate tiers for all nodes
    for node_id, _ in pairs(self.nodes) do
        if not visited[node_id] then
            calculate_node_tier(node_id)
        end
    end
end

--- Update research availability based on completion status
function ResearchTree:update_availability()
    for _, node in pairs(self.nodes) do
        node.available = self:is_research_available(node.id)
    end
end

--- Check if a research project is available for research
-- @param research_id ID of the research to check
-- @return true if available, false otherwise
function ResearchTree:is_research_available(research_id)
    local node = self.nodes[research_id]
    if not node then
        return false
    end

    -- Check if already completed or in progress
    if node.completed or node.in_progress then
        return false
    end

    -- Check prerequisites
    for _, prereq_id in ipairs(node.prerequisites) do
        local prereq_node = self.nodes[prereq_id]
        if not prereq_node or not prereq_node.completed then
            return false
        end
    end

    return true
end

--- Mark a research project as completed
-- @param research_id ID of the completed research
function ResearchTree:complete_research(research_id)
    local node = self.nodes[research_id]
    if node then
        node.completed = true
        node.in_progress = false

        -- Update availability of dependent research
        self:update_availability()
    end
end

--- Start research on a project
-- @param research_id ID of the research to start
-- @return true if started successfully, false otherwise
function ResearchTree:start_research(research_id)
    if not self:is_research_available(research_id) then
        return false
    end

    local node = self.nodes[research_id]
    if node then
        node.in_progress = true
        return true
    end

    return false
end

--- Cancel research on a project
-- @param research_id ID of the research to cancel
function ResearchTree:cancel_research(research_id)
    local node = self.nodes[research_id]
    if node and node.in_progress then
        node.in_progress = false
    end
end

--- Get all available research projects
-- @return Array of available research IDs
function ResearchTree:get_available_research()
    local available = {}
    for research_id, node in pairs(self.nodes) do
        if node.available then
            table.insert(available, research_id)
        end
    end
    return available
end

--- Get all completed research projects
-- @return Array of completed research IDs
function ResearchTree:get_completed_research()
    local completed = {}
    for research_id, node in pairs(self.nodes) do
        if node.completed then
            table.insert(completed, research_id)
        end
    end
    return completed
end

--- Get research projects by category
-- @param category Category to filter by
-- @return Array of research IDs in the category
function ResearchTree:get_research_by_category(category)
    local result = {}
    for _, node in ipairs(self.categories[category] or {}) do
        table.insert(result, node.id)
    end
    return result
end

--- Get research projects by tier
-- @param tier Tier to filter by
-- @return Array of research IDs in the tier
function ResearchTree:get_research_by_tier(tier)
    local result = {}
    for research_id, node in pairs(self.nodes) do
        if node.calculated_tier == tier then
            table.insert(result, research_id)
        end
    end
    return result
end

--- Get the prerequisites for a research project
-- @param research_id ID of the research
-- @return Array of prerequisite research IDs
function ResearchTree:get_prerequisites(research_id)
    local node = self.nodes[research_id]
    return node and node.prerequisites or {}
end

--- Get the dependents (research that requires this) for a research project
-- @param research_id ID of the research
-- @return Array of dependent research IDs
function ResearchTree:get_dependents(research_id)
    local node = self.nodes[research_id]
    return node and node.dependents or {}
end

--- Get research node information
-- @param research_id ID of the research
-- @return Research node data or nil if not found
function ResearchTree:get_research_info(research_id)
    local node = self.nodes[research_id]
    if not node then
        return nil
    end

    return {
        id = node.id,
        name = node.name,
        category = node.category,
        tier = node.calculated_tier,
        prerequisites = node.prerequisites,
        dependents = node.dependents,
        unlocks = node.unlocks,
        completed = node.completed,
        available = node.available,
        in_progress = node.in_progress
    }
end

--- Get all research categories
-- @return Array of category names
function ResearchTree:get_categories()
    local categories = {}
    for category, _ in pairs(self.categories) do
        table.insert(categories, category)
    end
    table.sort(categories)
    return categories
end

--- Get tree statistics
-- @return Table with tree statistics
function ResearchTree:get_statistics()
    local total = 0
    local completed = 0
    local available = 0
    local in_progress = 0
    local max_tier = 0

    for _, node in pairs(self.nodes) do
        total = total + 1
        if node.completed then
            completed = completed + 1
        end
        if node.available then
            available = available + 1
        end
        if node.in_progress then
            in_progress = in_progress + 1
        end
        max_tier = math.max(max_tier, node.calculated_tier)
    end

    return {
        total_research = total,
        completed_research = completed,
        available_research = available,
        in_progress_research = in_progress,
        max_tier = max_tier,
        completion_percentage = total > 0 and (completed / total) * 100 or 0
    }
end

--- Validate the research tree for circular dependencies
-- @return true if valid, false if circular dependencies found
function ResearchTree:validate_tree()
    local visited = {}
    local visiting = {}

    local function has_circular_dependency(node_id)
        if visited[node_id] then
            return false
        end

        if visiting[node_id] then
            return true  -- Circular dependency found
        end

        visiting[node_id] = true

        local node = self.nodes[node_id]
        for _, prereq_id in ipairs(node.prerequisites) do
            if has_circular_dependency(prereq_id) then
                return true
            end
        end

        visiting[node_id] = nil
        visited[node_id] = true

        return false
    end

    -- Check all nodes for circular dependencies
    for node_id, _ in pairs(self.nodes) do
        if has_circular_dependency(node_id) then
            return false
        end
    end

    return true
end

return ResearchTree
