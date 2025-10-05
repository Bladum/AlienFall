# Map Nodes and AI System

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Node Authoring and Types](#node-authoring-and-types)
  - [Graph Construction and Connections](#graph-construction-and-connections)
  - [Pathfinding and AI Planning](#pathfinding-and-ai-planning)
  - [AI Decision-Making Integration](#ai-decision-making-integration)
  - [Spawn System Integration](#spawn-system-integration)
  - [AI Priority Values](#ai-priority-values)
  - [Strategic Zones](#strategic-zones)
  - [Dynamic Updates](#dynamic-updates)
- [Examples](#examples)
  - [Corridor Ambush Setup](#corridor-ambush-setup)
  - [Farmhouse Defense Network](#farmhouse-defense-network)
  - [Patrol Route Implementation](#patrol-route-implementation)
  - [Urban Combat Positioning](#urban-combat-positioning)
  - [Code Examples](#code-examples)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Map Nodes and AI system implements strategic checkpoint management for battlefield control in Alien Fall, providing deterministic graph-based navigation and decision-making infrastructure. Map nodes serve as anchor points for AI planning, enabling efficient tactical reasoning for positioning, movement, and coordination. The system creates territorial dominance patterns while maintaining seeded randomness for reproducible behavior across all AI hierarchy levels.

The node-based architecture emphasizes performance optimization through graph algorithms, data-driven configuration, and seamless integration with fog of war and terrain systems. AI units leverage nodes for cover selection, ambush positioning, patrol routes, and spawn distribution, creating emergent tactical behaviors from coordinated node occupation.

## Mechanics

### Node Authoring and Types

Strategic battlefield positioning with functional categorization:

- **Spawn Point**: Unit deployment locations with capacity management
- **Cover Position**: Defensive terrain features for protection
- **Ambush Point**: Concealed locations for surprise attacks
- **Patrol Route**: Connected waypoints for area surveillance
- **Objective Area**: Mission-critical locations requiring control
- **Choke Point**: Narrow passages for bottleneck defense

### Graph Construction and Connections

Deterministic network creation with battlefield integration:

- **Grid Positioning**: Direct placement on battlefield coordinate system
- **Proximity Thresholds**: Data-driven connection distance limits
- **Tag Compatibility**: Semantic linking based on node function types
- **Terrain Integration**: Path validity considering elevation and obstacles
- **Seeded Topology**: Reproducible graph generation for consistent behavior

### Pathfinding and AI Planning

Strategic movement optimization using graph algorithms:

- **High-Level Routing**: Abstract pathfinding for mission-level planning
- **Dynamic Cost Updates**: Temporary modifier application for environmental effects
- **Terrain Control**: Node occupation for area dominance establishment
- **Seeded Resolution**: Deterministic tie-breaking for behavioral consistency
- **Performance Optimization**: Graph-based computation for large battlefields

### AI Decision-Making Integration

Node-based tactical reasoning across behavior types:

- **Strategic Positioning**: Cover and overwatch location selection
- **Spawn Distribution**: Capacity-aware unit placement and reinforcement
- **Patrol Routes**: Connected sequences for area surveillance
- **Threat Assessment**: Combined node weights with situational heuristics
- **Mission Influence**: Objective-based priority adjustments

### Spawn System Integration

Controlled unit introduction with resource management:

- **Tagged Selection**: Spawn point identification through semantic tags
- **Capacity Management**: Overcrowding prevention through slot limits
- **Density Control**: Distribution algorithms for tactical spacing
- **Reinforcement Logic**: Node availability-based unit deployment
- **Deterministic Placement**: Seeded random selection for reproducibility

### AI Priority Values

Numeric weighting system for tactical decision-making:

- **Value Ranges**: Standardized scoring from -100 to +100
- **Faction Specificity**: Unique priorities per controlling faction
- **Dynamic Modification**: Runtime priority adjustments during combat
- **Balance Analysis**: Provenance tracking for difficulty tuning

### Strategic Zones

Priority-based tactical area classification:

- **High Priority**: Prime tactical positions with significant advantages
- **Neutral Zones**: Standard terrain with balanced value
- **Low Priority**: Undesirable areas with tactical disadvantages
- **Forbidden Zones**: Restricted areas unusable by specific factions

### Dynamic Updates

Runtime priority modification responding to battlefield changes:

- **Objective Changes**: Mission progression affecting area value
- **Unit Losses**: Casualty locations reducing nearby priority
- **Environmental Effects**: Weather and hazard impacts on positioning
- **Player Actions**: Tactical responses to opponent behavior

## Examples

### Corridor Ambush Setup

UFO corridor interception scenario with doorway control:

- **Node Placement**: Ambush points at strategic doorways and chokepoints
- **Graph Connections**: Adjacent block linking for coordinated movement
- **AI Planning**: Interception positioning with tile-accurate execution
- **Capacity Management**: Limited unit placement preventing overcrowding

### Farmhouse Defense Network

Rural defensive positioning with building control:

- **Perimeter Nodes**: Cover positions around approach routes
- **Capacity Settings**: Overcrowding prevention for realistic defense
- **AI Assignment**: Highest-scoring node selection algorithm
- **Reinforcement Logic**: Elimination-triggered spawn activation

### Patrol Route Implementation

Security circuit establishment with connected surveillance:

- **Sequential Nodes**: Patrol route tagged waypoints forming circuits
- **Proximity Linking**: Tag-compatible connection generation
- **Alert Response**: Threat detection triggering replanning
- **Capacity Distribution**: Even spacing preventing patrol bunching

### Urban Combat Positioning

City intersection tactical complexity with multiple options:

- **Position Tags**: Overwatch, flank, and cover position categorization
- **Scoring Weights**: Elevated and concealed location prioritization
- **AI Integration**: Threat assessment combined with node evaluation
- **Dynamic Updates**: Combat zone proximity cost increases

### Code Examples

#### Node Authoring and Types

```lua
local node_types = {
    SPAWN_POINT = "spawn_point",
    COVER_POSITION = "cover_position", 
    AMBUSH_POINT = "ambush_point",
    PATROL_ROUTE = "patrol_route",
    OBJECTIVE_AREA = "objective_area",
    CHOKE_POINT = "choke_point"
}

function create_map_node(position, node_type, properties)
    return {
        id = generate_node_id(),
        position = position,
        type = node_type,
        properties = properties or {},
        connections = {},
        faction_priorities = {},
        capacity = properties.capacity or 1,
        tags = properties.tags or {}
    }
end
```

#### Graph Construction and Connections

```lua
function build_node_graph(nodes, battlefield)
    local graph = { nodes = nodes, edges = {} }
    
    -- Create connections based on proximity and compatibility
    for i, node_a in ipairs(nodes) do
        for j, i + 1, #nodes do
            local node_b = nodes[j]
            
            if should_connect_nodes(node_a, node_b, battlefield) then
                local edge = create_node_edge(node_a, node_b)
                table.insert(graph.edges, edge)
                
                -- Bidirectional connections
                table.insert(node_a.connections, { target = node_b.id, edge = edge })
                table.insert(node_b.connections, { target = node_a.id, edge = edge })
            end
        end
    end
    
    return graph
end

function should_connect_nodes(node_a, node_b, battlefield)
    local distance = calculate_distance(node_a.position, node_b.position)
    
    -- Distance check
    if distance > MAX_CONNECTION_DISTANCE then
        return false
    end
    
    -- Line of sight check
    if not has_line_of_sight(node_a.position, node_b.position, battlefield) then
        return false
    end
    
    -- Tag compatibility
    if not nodes_are_compatible(node_a, node_b) then
        return false
    end
    
    return true
end
```

#### AI Decision-Making Integration

```lua
function select_optimal_node(unit, available_nodes, situation)
    local best_node = nil
    local best_score = -math.huge
    
    for _, node in ipairs(available_nodes) do
        if can_occupy_node(unit, node) then
            local score = evaluate_node_for_unit(unit, node, situation)
            
            if score > best_score then
                best_score = score
                best_node = node
            end
        end
    end
    
    return best_node
end

function evaluate_node_for_unit(unit, node, situation)
    local score = 0
    
    -- Faction priority
    score = score + (node.faction_priorities[unit.faction] or 0)
    
    -- Tactical factors
    if situation.needs_cover and node.properties.cover_rating then
        score = score + node.properties.cover_rating * 10
    end
    
    -- Distance penalty
    local distance = calculate_distance(unit.position, node.position)
    score = score - distance * 2
    
    -- Capacity check
    if node.occupants and #node.occupants >= node.capacity then
        score = score - 100 -- Heavily penalize full nodes
    end
    
    return score
end
```

## Related Wiki Pages

- [Unit AI.md](../ai/Unit%20AI.md) - Individual unit positioning and node occupation behaviors
- [Squad AI.md](../ai/Squad%20AI.md) - Group-level coordination using node networks
- [Strategic AI.md](../ai/Strategic%20AI.md) - Mission-level planning with node-based control
- [Movement.md](../ai/Movement.md) - Pathfinding integration with node graph navigation
- [Exploration.md](../ai/Exploration.md) - Discovery behaviors guided by node priorities
- [Behaviors.md](../ai/Behaviors.md) - Unit behavior types utilizing node positioning
- [Battle tile.md](../battlescape/Battle%20tile.md) - Terrain properties influencing node placement
- [Terrain Elevation.md](../battlescape/Terrain%20Elevation.md) - Height-based positioning and visibility
- [Line of sight.md](../battlescape/Line%20of%20sight.md) - Vision calculations affecting node connections
- [Deployment zones.md](../battlescape/Deployment%20zones.md) - Initial positioning using spawn nodes

## References to Existing Games and Mechanics

The Map Nodes and AI system draws from navigation and control point mechanics in strategy and tactical games:

- **XCOM series (1994-2016)**: Strategic positioning and area control through key terrain features
- **Fire Emblem series (1990-2023)**: Chokepoint control and defensive positioning
- **Advance Wars series (2001-2018)**: Terrain-based tactical positioning and area control
- **Civilization series (1991-2023)**: Strategic resource and position control
- **Total War series (2000-2022)**: Large-scale positioning and territorial control
- **Jagged Alliance series (1994-2014)**: Tactical positioning and ambush point utilization
- **BattleTech (1984-2024)**: Mech positioning and terrain advantage exploitation
- **Divinity: Original Sin series (2014-2018)**: Environmental positioning and tactical terrain use
- **Pillars of Eternity (2015)**: Strategic positioning and area control mechanics
- **Deus Ex series (2000-2017)**: Stealth positioning and environmental exploitation

function create_map_node(position, node_type, properties)
    return {
        id = generate_node_id(),
        position = position,
        type = node_type,
        properties = properties or {},
        connections = {},
        faction_priorities = {},
        capacity = properties.capacity or 1,
        tags = properties.tags or {}
    }
end
```

### Graph Construction and Connections

```lua
function build_node_graph(nodes, battlefield)
    local graph = { nodes = nodes, edges = {} }
    
    -- Create connections based on proximity and compatibility
    for i, node_a in ipairs(nodes) do
        for j, i + 1, #nodes do
            local node_b = nodes[j]
            
            if should_connect_nodes(node_a, node_b, battlefield) then
                local edge = create_node_edge(node_a, node_b)
                table.insert(graph.edges, edge)
                
                -- Bidirectional connections
                table.insert(node_a.connections, { target = node_b.id, edge = edge })
                table.insert(node_b.connections, { target = node_a.id, edge = edge })
            end
        end
    end
    
    return graph
end

function should_connect_nodes(node_a, node_b, battlefield)
    local distance = calculate_distance(node_a.position, node_b.position)
    
    -- Distance check
    if distance > MAX_CONNECTION_DISTANCE then
        return false
    end
    
    -- Line of sight check
    if not has_line_of_sight(node_a.position, node_b.position, battlefield) then
        return false
    end
    
    -- Tag compatibility
    if not nodes_are_compatible(node_a, node_b) then
        return false
    end
    
    return true
end
```

### Pathfinding and AI Planning

```lua
function find_node_path(start_node, end_node, graph, unit)
    -- A* pathfinding with tactical costs
    local open_set = { start_node }
    local came_from = {}
    local g_score = { [start_node.id] = 0 }
    local f_score = { [start_node.id] = heuristic_cost(start_node, end_node) }
    
    while #open_set > 0 do
        local current = get_lowest_f_score(open_set, f_score)
        
        if current.id == end_node.id then
            return reconstruct_path(came_from, current)
        end
        
        remove_from_set(open_set, current)
        
        for _, connection in ipairs(current.connections) do
            local neighbor = graph.nodes[connection.target]
            local edge_cost = calculate_edge_cost(connection.edge, unit)
            local tentative_g = g_score[current.id] + edge_cost
            
            if tentative_g < (g_score[neighbor.id] or math.huge) then
                came_from[neighbor.id] = current
                g_score[neighbor.id] = tentative_g
                f_score[neighbor.id] = tentative_g + heuristic_cost(neighbor, end_node)
                
                if not contains(open_set, neighbor) then
                    table.insert(open_set, neighbor)
                end
            end
        end
    end
    
    return nil -- No path found
end
```

### AI Decision-Making Integration

```lua
function select_optimal_node(unit, available_nodes, situation)
    local best_node = nil
    local best_score = -math.huge
    
    for _, node in ipairs(available_nodes) do
        if can_occupy_node(unit, node) then
            local score = evaluate_node_for_unit(unit, node, situation)
            
            if score > best_score then
                best_score = score
                best_node = node
            end
        end
    end
    
    return best_node
end

function evaluate_node_for_unit(unit, node, situation)
    local score = 0
    
    -- Faction priority
    score = score + (node.faction_priorities[unit.faction] or 0)
    
    -- Tactical factors
    if situation.needs_cover and node.properties.cover_rating then
        score = score + node.properties.cover_rating * 10
    end
    
    -- Distance penalty
    local distance = calculate_distance(unit.position, node.position)
    score = score - distance * 2
    
    -- Capacity check
    if node.occupants and #node.occupants >= node.capacity then
        score = score - 100 -- Heavily penalize full nodes
    end
    
    return score
end
```

### Spawn System Integration

```lua
function select_spawn_nodes(faction, available_nodes, unit_count)
    local spawn_nodes = {}
    
    -- Filter spawn-tagged nodes
    local spawn_candidates = {}
    for _, node in ipairs(available_nodes) do
        if table.contains(node.tags, "spawn_point") then
            table.insert(spawn_candidates, node)
        end
    end
    
    -- Sort by priority and capacity
    table.sort(spawn_candidates, function(a, b)
        local a_priority = a.faction_priorities[faction] or 0
        local b_priority = b.faction_priorities[faction] or 0
        
        if a_priority ~= b_priority then
            return a_priority > b_priority
        end
        
        -- Secondary sort by available capacity
        local a_available = a.capacity - (a.occupants and #a.occupants or 0)
        local b_available = b.capacity - (b.occupants and #b.occupants or 0)
        
        return a_available > b_available
    end)
    
    -- Select nodes up to unit count
    local remaining_units = unit_count
    for _, node in ipairs(spawn_candidates) do
        if remaining_units <= 0 then break end
        
        local available_slots = node.capacity - (node.occupants and #node.occupants or 0)
        local units_to_spawn = math.min(remaining_units, available_slots)
        
        if units_to_spawn > 0 then
            table.insert(spawn_nodes, {
                node = node,
                unit_count = units_to_spawn
            })
            remaining_units = remaining_units - units_to_spawn
        end
    end
    
    return spawn_nodes
end
```

### AI Priority Values

```lua
function calculate_block_priorities(block, battlefield, mission_context)
    local priorities = {
        player_ally = 0,
        enemy_force = 0,
        neutral = 0
    }
    
    -- Base terrain value
    local terrain_value = assess_terrain_value(block, battlefield)
    priorities.player_ally = priorities.player_ally + terrain_value
    priorities.enemy_force = priorities.enemy_force + terrain_value
    priorities.neutral = priorities.neutral + terrain_value * 0.5
    
    -- Objective proximity
    local objective_bonus = calculate_objective_proximity(block, mission_context)
    priorities.player_ally = priorities.player_ally + objective_bonus
    
    -- Faction-specific modifiers
    priorities.enemy_force = priorities.enemy_force + calculate_enemy_advantage(block, battlefield)
    priorities.neutral = priorities.neutral + calculate_neutral_safety(block, battlefield)
    
    -- Clamp values
    for faction, value in pairs(priorities) do
        priorities[faction] = math.max(-100, math.min(100, value))
    end
    
    return priorities
end

function assess_terrain_value(block, battlefield)
    local value = 0
    
    -- Cover rating
    if block.cover_rating then
        value = value + block.cover_rating * 5
    end
    
    -- Elevation advantage
    if block.elevation > battlefield.average_elevation then
        value = value + (block.elevation - battlefield.average_elevation) * 2
    end
    
    -- Movement access
    if block.movement_cost and block.movement_cost <= 1 then
        value = value + 10
    end
    
    return value
end
```

### Dynamic Updates

```lua
function update_block_priorities(block, battlefield, current_turn, events)
    local updated_priorities = table.deepcopy(block.priorities)
    
    -- Process recent events
    for _, event in ipairs(events) do
        if event.type == "unit_death" then
            -- Reduce priority near death locations
            if distance(block.position, event.position) < 5 then
                updated_priorities[event.unit.faction] = updated_priorities[event.unit.faction] - 10
            end
        elseif event.type == "objective_captured" then
            -- Increase priority near captured objectives
            if distance(block.position, event.objective.position) < 10 then
                updated_priorities[event.capturing_faction] = updated_priorities[event.capturing_faction] + 20
            end
        elseif event.type == "environmental_change" then
            -- Adjust for smoke, fire, etc.
            if position_in_area(block.position, event.affected_area) then
                updated_priorities = apply_environmental_modifier(updated_priorities, event.change_type)
            end
        end
    end
    
    -- Time-based decay toward base values
    local time_since_update = current_turn - (block.last_update or 0)
    if time_since_update > 5 then
        updated_priorities = decay_priorities(updated_priorities, block.base_priorities, time_since_update)
    end
    
    block.priorities = updated_priorities
    block.last_update = current_turn
    
    return updated_priorities
end
```

This map nodes and AI design creates a comprehensive system for strategic battlefield control, enabling sophisticated AI behaviors while maintaining deterministic outcomes for testing and modding purposes.