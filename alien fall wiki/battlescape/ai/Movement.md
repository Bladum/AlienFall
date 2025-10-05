# AI Movement Using Map Nodes System

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Dynamic Node Generation](#dynamic-node-generation)
  - [Node Types and Properties](#node-types-and-properties)
  - [Node Graph Construction](#node-graph-construction)
  - [AI Pathfinding Integration](#ai-pathfinding-integration)
  - [Group Movement Coordination](#group-movement-coordination)
  - [Node Discovery and Revelation](#node-discovery-and-revelation)
  - [Tactical Node Utilization](#tactical-node-utilization)
  - [Performance Optimization](#performance-optimization)
- [Examples](#examples)
  - [Node Generation Scenarios](#node-generation-scenarios)
  - [Pathfinding Validation](#pathfinding-validation)
  - [Code Examples](#code-examples)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The AI Movement Using Map Nodes system implements dynamic navigation infrastructure for Alien Fall's battlescape, creating emergent tactical behaviors through graph-based pathfinding and positioning. Map nodes serve as strategic anchor points generated from terrain analysis, enabling deterministic movement patterns while adapting to revealed battlefield information. The system creates sophisticated coordination between individual units, squads, and strategic AI levels.

The movement system emphasizes performance optimization through hierarchical pathfinding, deterministic outcomes for testing, and seamless integration with fog of war mechanics. AI units leverage node graphs for cover seeking, ambush positioning, formation movement, and coordinated advances, creating realistic tactical behaviors from simple rule-based decision making.

## Mechanics

### Dynamic Node Generation

Terrain-driven strategic point creation independent of predefined block data:

- **Feature Analysis**: Automatic identification of tactically significant terrain
- **Mission Integration**: Objective-specific node generation and placement
- **Deterministic Creation**: Seeded algorithms ensuring reproducible node placement
- **Performance Scaling**: Adaptive node density based on battlefield size

### Node Types and Properties

Categorization system for tactical positioning and movement:

- **Cover**: Defensive terrain features providing protection
- **Ambush**: Concealed locations optimal for surprise attacks
- **Chokepoint**: Narrow passages controlling movement flow
- **Overwatch**: Elevated positions with extended visibility
- **Objective**: Mission-critical locations requiring control
- **Deployment**: Initial unit placement and spawn areas
- **Waypoint**: General navigation and pathfinding points
- **Safe Zone**: Protected areas for retreat and recovery

### Node Graph Construction

Deterministic network creation with tactical edge weighting:

- **Connection Rules**: Distance, line-of-sight, and compatibility-based linking
- **Edge Properties**: Weighted connections considering cover, exposure, and terrain
- **Graph Optimization**: Performance improvements through hierarchical structuring
- **Dynamic Updates**: Runtime graph modification responding to battlefield changes

### AI Pathfinding Integration

Multi-level navigation combining abstract and detailed movement:

- **Node-Based Planning**: High-level routing using strategic graph waypoints
- **Tactical Optimization**: Combat-aware path selection with threat consideration
- **Path Conversion**: Node sequences translated to tile-accurate movement
- **Fallback Systems**: Direct pathfinding when node navigation unavailable

### Group Movement Coordination

Synchronized unit movement maintaining tactical formations:

- **Formation Preservation**: Relative positioning maintained during navigation
- **Waypoint Conversion**: Node paths adapted for group movement patterns
- **Timing Coordination**: Synchronized advancement and positioning
- **Contingency Planning**: Alternative routes for disrupted movement

### Node Discovery and Revelation

Progressive navigation knowledge with asymmetric information:

- **Exploration Revelation**: Nodes discovered through unit movement and vision
- **Graph Expansion**: Edge revelation as connected nodes become known
- **Adaptive Planning**: Path recalculation incorporating new navigation options
- **Knowledge Propagation**: Information sharing across AI hierarchy levels

### Tactical Node Utilization

Strategic positioning leveraging node network advantages:

- **Optimal Placement**: Node evaluation for tactical suitability and availability
- **Resource Competition**: Multiple units contending for valuable positions
- **Dynamic Control**: Runtime node occupation and priority shifting
- **Coordination Benefits**: Enhanced group effectiveness through networked positioning

### Performance Optimization

Efficient processing for complex battlefield navigation:

- **Graph Partitioning**: Regional subdivision for scalable computation
- **Path Caching**: Precomputed routes for common movement patterns
- **Incremental Updates**: Progressive graph modification avoiding full recalculation
- **Approximation Algorithms**: Fast pathfinding for non-critical movement

## Examples

### Node Generation Scenarios

#### Urban Environments
City-based tactical positioning with building exploitation:

- **Building Corners**: Cover and ambush nodes at structural intersections
- **Roof Access**: Overwatch nodes on elevated building positions
- **Street Intersections**: Chokepoint nodes controlling movement corridors
- **Alley Networks**: Connected waypoint sequences for flanking routes

#### Natural Terrain
Outdoor environmental adaptation with terrain features:

- **Hilltops**: Overwatch nodes with extended visibility ranges
- **Forest Edges**: Ambush nodes utilizing tree line concealment
- **River Crossings**: Chokepoint nodes controlling water access
- **Rock Formations**: Cover nodes providing defensive positioning

#### Mixed Scenarios
Combined urban and natural terrain integration:

- **Building Clusters**: Interconnected node networks spanning structures
- **Terrain Transitions**: Nodes bridging different environmental types
- **Compound Objectives**: Multi-node objectives requiring coordinated control
- **Dynamic Features**: Weather-affected node value modifications

#### Edge Cases
Extreme or unusual battlefield conditions:

- **Open Plains**: Sparse node distribution with emphasis on mobility
- **Dense Urban**: High node density requiring efficient pathfinding
- **Hazardous Terrain**: Risk-weighted nodes avoiding dangerous areas
- **Asymmetric Maps**: Uneven node distribution favoring defensive positions

### Pathfinding Validation

Navigation reliability assessment across different scenarios:

- **Completeness**: Guaranteed pathfinding to all reachable destinations
- **Optimality**: Selection of most efficient routes under tactical constraints
- **Performance**: Sub-second computation for real-time movement decisions
- **Determinism**: Identical results from identical starting conditions

### Code Examples

#### Dynamic Node Generation

```lua
function generate_map_nodes(battlefield, mission_requirements)
    local nodes = {}
    
    -- Analyze terrain for strategic positions
    local terrain_features = analyze_terrain_features(battlefield)
    
    -- Generate nodes from features
    for _, feature in ipairs(terrain_features) do
        if is_strategic_feature(feature) then
            local node = create_node_from_feature(feature, battlefield)
            table.insert(nodes, node)
        end
    end
    
    -- Add mission-specific nodes
    local mission_nodes = generate_mission_nodes(mission_requirements, battlefield)
    for _, node in ipairs(mission_nodes) do
        table.insert(nodes, node)
    end
    
    -- Connect nodes to form graph
    local node_graph = connect_nodes(nodes, battlefield)
    
    return node_graph
end
```

#### Node Graph Construction

```lua
function connect_nodes(nodes, battlefield)
    local graph = {
        nodes = nodes,
        edges = {},
        metadata = {}
    }
    
    -- Calculate pairwise connections
    for i, node_a in ipairs(nodes) do
        for j = i + 1, #nodes do
            local node_b = nodes[j]
            
            if should_connect_nodes(node_a, node_b, battlefield) then
                local edge = create_edge(node_a, node_b, battlefield)
                table.insert(graph.edges, edge)
                
                -- Add bidirectional connections
                table.insert(node_a.connections, {target = node_b.id, edge = edge})
                table.insert(node_b.connections, {target = node_a.id, edge = edge})
            end
        end
    end
    
    -- Optimize graph
    graph.metadata = optimize_graph(graph, battlefield)
    
    return graph
end

function should_connect_nodes(node_a, node_b, battlefield)
    local distance = distance(node_a.position, node_b.position)
    
    -- Maximum connection distance
    if distance > MAX_NODE_CONNECTION_DISTANCE then
        return false
    end
    
    -- Check line of sight
    if not has_clear_path(node_a.position, node_b.position, battlefield) then
        return false
    end
    
    -- Node type compatibility
    if not are_node_types_compatible(node_a.type, node_b.type) then
        return false
    end
    
    -- Terrain suitability
    if not is_terrain_suitable_for_connection(node_a.position, node_b.position, battlefield) then
        return false
    end
    
    return true
end
```

#### AI Pathfinding Integration

```lua
function plan_unit_path(unit, destination, node_graph, battlefield)
    -- Find nearest source node
    local source_node = find_nearest_node(unit.position, node_graph, unit.faction)
    
    -- Find nearest destination node
    local dest_node = find_nearest_node(destination, node_graph, unit.faction)
    
    if not source_node or not dest_node then
        -- Fallback to direct pathfinding
        return calculate_direct_path(unit.position, destination, battlefield)
    end
    
    -- Calculate node path
    local node_path = find_node_path(source_node, dest_node, node_graph, unit)
    
    if not node_path then
        return nil  -- No valid path
    end
    
    -- Convert to detailed tile path
    local detailed_path = convert_node_path_to_tiles(node_path, unit.position, destination, battlefield)
    
    return detailed_path
end
```

#### Group Movement Coordination

```lua
function move_group_along_nodes(group, node_path, formation)
    local group_movement = {
        waypoints = {},
        formation_positions = {},
        timing_coordination = {},
        contingency_routes = {}
    }
    
    -- Convert node path to group waypoints
    for i, node in ipairs(node_path) do
        local waypoint = {
            position = node.position,
            formation_anchor = calculate_formation_anchor(node, formation),
            arrival_time = calculate_arrival_time(i, node_path, group),
            hold_condition = determine_hold_condition(node, group)
        }
        
        table.insert(group_movement.waypoints, waypoint)
    end
    
    -- Calculate formation positions for each waypoint
    for _, waypoint in ipairs(group_movement.waypoints) do
        waypoint.formation_positions = calculate_formation_positions(
            waypoint.formation_anchor, 
            formation, 
            #group.units
        )
    end
    
    -- Set up timing coordination
    group_movement.timing_coordination = coordinate_group_timing(group_movement, group)
    
    -- Generate contingency routes
    group_movement.contingency_routes = generate_contingency_routes(node_path, group, formation)
    
    return group_movement
end
```

## Related Wiki Pages

- [Unit AI.md](../ai/Unit%20AI.md) - Individual unit movement and positioning decisions
- [Squad AI.md](../ai/Squad%20AI.md) - Group-level coordination and formation movement
- [Strategic AI.md](../ai/Strategic%20AI.md) - Mission-level path planning and resource allocation
- [Map Nodes.md](../ai/Map%20Nodes.md) - Node graph infrastructure and properties
- [Exploration.md](../ai/Exploration.md) - Discovery behaviors affecting node revelation
- [Behaviors.md](../ai/Behaviors.md) - Unit behavior patterns utilizing movement systems
- [Battle tile.md](../battlescape/Battle%20tile.md) - Terrain properties influencing movement costs
- [Terrain Elevation.md](../battlescape/Terrain%20Elevation.md) - Height-based movement and positioning
- [Line of sight.md](../battlescape/Line%20of%20sight.md) - Vision calculations affecting path selection
- [Lighting & Fog of War.md](../battlescape/Lighting%20&%20Fog%20of%20War.md) - Visibility mechanics impacting movement

## References to Existing Games and Mechanics

The AI Movement Using Map Nodes system draws from navigation and positioning mechanics in tactical and strategy games:

- **XCOM series (1994-2016)**: Cover-based positioning and tactical movement around terrain features
- **Fire Emblem series (1990-2023)**: Grid-based movement with terrain cost modifications
- **Advance Wars series (2001-2018)**: Terrain-based movement costs and positioning advantages
- **Jagged Alliance series (1994-2014)**: Detailed positioning and movement around cover objects
- **BattleTech (1984-2024)**: Mech positioning and terrain height considerations
- **Civilization series (1991-2023)**: Strategic movement and positioning for area control
- **Total War series (2000-2022)**: Large-scale unit positioning and terrain exploitation
- **Divinity: Original Sin series (2014-2018)**: Environmental positioning and height-based tactics
- **Pillars of Eternity (2015)**: Tactical positioning and terrain-based movement penalties
- **Deus Ex series (2000-2017)**: Stealth positioning and environmental exploitation for movement
    
    -- Analyze terrain for strategic positions
    local terrain_features = analyze_terrain_features(battlefield)
    
    -- Generate nodes from features
    for _, feature in ipairs(terrain_features) do
        if is_strategic_feature(feature) then
            local node = create_node_from_feature(feature, battlefield)
            table.insert(nodes, node)
        end
    end
    
    -- Add mission-specific nodes
    local mission_nodes = generate_mission_nodes(mission_requirements, battlefield)
    for _, node in ipairs(mission_nodes) do
        table.insert(nodes, node)
    end
    
    -- Connect nodes to form graph
    local node_graph = connect_nodes(nodes, battlefield)
    
    return node_graph
end
```

### Node Types and Properties

```lua
local node_types = {
    COVER = "cover",           -- Defensive positions
    AMBUSH = "ambush",         -- Concealed attack positions
    CHOKEPOINT = "chokepoint", -- Tactical bottlenecks
    OVERWATCH = "overwatch",   -- Elevated observation points
    OBJECTIVE = "objective",   -- Mission-critical locations
    DEPLOYMENT = "deployment", -- Initial unit placement
    WAYPOINT = "waypoint",     -- General navigation points
    SAFE_ZONE = "safe_zone"    -- Protected areas
}

function create_node_from_feature(feature, battlefield)
    local node = {
        id = generate_node_id(),
        position = feature.position,
        type = determine_node_type(feature),
        properties = extract_node_properties(feature, battlefield),
        connections = {},  -- Will be populated during graph creation
        faction_priorities = initialize_faction_priorities(),
        capacity = calculate_node_capacity(feature),
        tags = generate_node_tags(feature)
    }
    
    return node
end
```

### Connection Rules

```lua
function connect_nodes(nodes, battlefield)
    local graph = {
        nodes = nodes,
        edges = {},
        metadata = {}
    }
    
    -- Calculate pairwise connections
    for i, node_a in ipairs(nodes) do
        for j = i + 1, #nodes do
            local node_b = nodes[j]
            
            if should_connect_nodes(node_a, node_b, battlefield) then
                local edge = create_edge(node_a, node_b, battlefield)
                table.insert(graph.edges, edge)
                
                -- Add bidirectional connections
                table.insert(node_a.connections, {target = node_b.id, edge = edge})
                table.insert(node_b.connections, {target = node_a.id, edge = edge})
            end
        end
    end
    
    -- Optimize graph
    graph.metadata = optimize_graph(graph, battlefield)
    
    return graph
end

function should_connect_nodes(node_a, node_b, battlefield)
    local distance = distance(node_a.position, node_b.position)
    
    -- Maximum connection distance
    if distance > MAX_NODE_CONNECTION_DISTANCE then
        return false
    end
    
    -- Check line of sight
    if not has_clear_path(node_a.position, node_b.position, battlefield) then
        return false
    end
    
    -- Node type compatibility
    if not are_node_types_compatible(node_a.type, node_b.type) then
        return false
    end
    
    -- Terrain suitability
    if not is_terrain_suitable_for_connection(node_a.position, node_b.position, battlefield) then
        return false
    end
    
    return true
end
```

### Edge Properties

```lua
function create_edge(node_a, node_b, battlefield)
    local edge = {
        id = generate_edge_id(node_a.id, node_b.id),
        nodes = {node_a.id, node_b.id},
        distance = distance(node_a.position, node_b.position),
        cost = calculate_edge_cost(node_a, node_b, battlefield),
        properties = {
            cover_rating = calculate_edge_cover(node_a.position, node_b.position, battlefield),
            exposure_time = calculate_exposure_time(node_a.position, node_b.position),
            terrain_difficulty = assess_terrain_difficulty(node_a.position, node_b.position, battlefield)
        },
        tactical_value = assess_edge_tactical_value(node_a, node_b, battlefield)
    }
    
    return edge
end
```

### Node-Based Path Planning

```lua
function plan_unit_path(unit, destination, node_graph, battlefield)
    -- Find nearest source node
    local source_node = find_nearest_node(unit.position, node_graph, unit.faction)
    
    -- Find nearest destination node
    local dest_node = find_nearest_node(destination, node_graph, unit.faction)
    
    if not source_node or not dest_node then
        -- Fallback to direct pathfinding
        return calculate_direct_path(unit.position, destination, battlefield)
    end
    
    -- Calculate node path
    local node_path = find_node_path(source_node, dest_node, node_graph, unit)
    
    if not node_path then
        return nil  -- No valid path
    end
    
    -- Convert to detailed tile path
    local detailed_path = convert_node_path_to_tiles(node_path, unit.position, destination, battlefield)
    
    return detailed_path
end
```

### Tactical Path Optimization

```lua
function find_node_path(source_node, dest_node, node_graph, unit)
    -- A* search with tactical weights
    local open_set = {source_node}
    local came_from = {}
    local g_score = {[source_node.id] = 0}
    local f_score = {[source_node.id] = heuristic_cost_estimate(source_node, dest_node)}
    
    while #open_set > 0 do
        -- Find lowest f_score node
        local current = find_lowest_f_score(open_set, f_score)
        
        if current.id == dest_node.id then
            return reconstruct_path(came_from, current)
        end
        
        table.remove(open_set, table.index_of(open_set, current))
        
        -- Evaluate neighbors
        for _, connection in ipairs(current.connections) do
            local neighbor = node_graph.nodes[connection.target]
            local edge = connection.edge
            
            -- Calculate tactical cost
            local tactical_cost = calculate_tactical_edge_cost(edge, unit, node_graph)
            local tentative_g_score = g_score[current.id] + edge.cost + tactical_cost
            
            if not g_score[neighbor.id] or tentative_g_score < g_score[neighbor.id] then
                came_from[neighbor.id] = current
                g_score[neighbor.id] = tentative_g_score
                f_score[neighbor.id] = g_score[neighbor.id] + heuristic_cost_estimate(neighbor, dest_node)
                
                if not table.contains(open_set, neighbor) then
                    table.insert(open_set, neighbor)
                end
            end
        end
    end
    
    return nil  -- No path found
end
```

### Formation Movement Along Nodes

```lua
function move_group_along_nodes(group, node_path, formation)
    local group_movement = {
        waypoints = {},
        formation_positions = {},
        timing_coordination = {},
        contingency_routes = {}
    }
    
    -- Convert node path to group waypoints
    for i, node in ipairs(node_path) do
        local waypoint = {
            position = node.position,
            formation_anchor = calculate_formation_anchor(node, formation),
            arrival_time = calculate_arrival_time(i, node_path, group),
            hold_condition = determine_hold_condition(node, group)
        }
        
        table.insert(group_movement.waypoints, waypoint)
    end
    
    -- Calculate formation positions for each waypoint
    for _, waypoint in ipairs(group_movement.waypoints) do
        waypoint.formation_positions = calculate_formation_positions(
            waypoint.formation_anchor, 
            formation, 
            #group.units
        )
    end
    
    -- Set up timing coordination
    group_movement.timing_coordination = coordinate_group_timing(group_movement, group)
    
    -- Generate contingency routes
    group_movement.contingency_routes = generate_contingency_routes(node_path, group, formation)
    
    return group_movement
end
```

### Dynamic Node Occupation

```lua
function resolve_node_occupation(contending_groups, target_node)
    local occupation_result = {
        controlling_group = nil,
        occupation_status = "contested",
        control_strength = 0,
        duration_estimate = 0
    }
    
    -- Evaluate each group's claim
    local strongest_claim = {group = nil, strength = 0}
    
    for _, group in ipairs(contending_groups) do
        local claim_strength = calculate_group_node_claim(group, target_node)
        
        if claim_strength > strongest_claim.strength then
            strongest_claim.group = group
            strongest_claim.strength = claim_strength
        end
    end
    
    -- Check for clear control
    local total_strength = 0
    for _, group in ipairs(contending_groups) do
        total_strength = total_strength + calculate_group_node_claim(group, target_node)
    end
    
    if strongest_claim.strength > total_strength * 0.6 then
        -- Clear control
        occupation_result.controlling_group = strongest_claim.group
        occupation_result.occupation_status = "controlled"
        occupation_result.control_strength = strongest_claim.strength / total_strength
    else
        -- Contested
        occupation_result.occupation_status = "contested"
        occupation_result.control_strength = strongest_claim.strength / total_strength
    end
    
    occupation_result.duration_estimate = estimate_occupation_duration(contending_groups, target_node)
    
    return occupation_result
end
```

### Progressive Node Revelation

```lua
function reveal_nodes_in_area(area, node_graph, faction_fog)
    local revealed_nodes = {}
    
    -- Find nodes in revealed area
    for _, node in ipairs(node_graph.nodes) do
        if position_in_area(node.position, area) then
            if not faction_fog.known_nodes[node.id] then
                -- Reveal node
                faction_fog.known_nodes[node.id] = true
                table.insert(revealed_nodes, node)
                
                -- Reveal connected edges if both nodes known
                for _, connection in ipairs(node.connections) do
                    local connected_node = node_graph.nodes[connection.target]
                    if faction_fog.known_nodes[connected_node.id] then
                        faction_fog.known_edges[connection.edge.id] = true
                    end
                end
            end
        end
    end
    
    -- Update faction's node graph knowledge
    update_faction_node_graph(faction_fog, revealed_nodes, node_graph)
    
    return revealed_nodes
end
```

### Adaptive Pathfinding

```lua
function update_paths_with_new_nodes(existing_paths, new_nodes, node_graph, faction)
    local updated_paths = {}
    
    for _, path in ipairs(existing_paths) do
        local path_updated = false
        
        -- Check if new nodes offer better routes
        for _, new_node in ipairs(new_nodes) do
            if can_improve_path(path, new_node, node_graph) then
                local improved_path = recalculate_path_with_node(path, new_node, node_graph, faction)
                
                if improved_path and improved_path.total_cost < path.total_cost * 0.9 then
                    updated_paths[path.id] = improved_path
                    path_updated = true
                    break
                end
            end
        end
        
        -- Keep original if no improvement
        if not path_updated then
            updated_paths[path.id] = path
        end
    end
    
    return updated_paths
end
```

### Node-Based Positioning

```lua
function find_tactical_position(unit, situation, node_graph, faction)
    local candidate_nodes = find_relevant_nodes(unit, situation, node_graph, faction)
    local best_position = nil
    local best_score = -1
    
    for _, node in ipairs(candidate_nodes) do
        -- Check node availability
        if can_occupy_node(unit, node, faction) then
            local position_score = evaluate_node_position(unit, node, situation)
            
            if position_score > best_score then
                best_score = position_score
                best_position = node
            end
        end
    end
    
    return best_position
end

function evaluate_node_position(unit, node, situation)
    local score = 0
    
    -- Distance to current position
    local distance = distance(unit.position, node.position)
    score = score + (50 - distance * 0.5)  -- Prefer closer nodes
    
    -- Node type suitability
    score = score + get_node_type_bonus(node.type, situation)
    
    -- Cover and protection
    if situation.requires_cover and node.properties.cover_rating then
        score = score + node.properties.cover_rating * 2
    end
    
    -- Tactical advantages
    if situation.needs_overwatch and node.type == node_types.OVERWATCH then
        score = score + 40
    end
    
    -- Enemy positioning
    local enemy_distance = distance_to_nearest_enemy(node.position, situation)
    if enemy_distance < 10 then
        score = score - 30  -- Avoid enemy proximity
    end
    
    -- Objective proximity
    local objective_distance = distance_to_objective(node.position, unit)
    score = score + (100 - objective_distance)
    
    return score
end
```

### Custom Node Types

```toml
[custom_node.alien_artifact]
type = "objective"
properties = {
    cover_rating = 0,
    capacity = 1,
    special_effects = ["psi_amplifier", "reality_distortion"]
}
faction_priorities = {
    player_ally = 95,
    enemy_force = 80,
    neutral = 10
}
connection_rules = ["high_value_target", "psi_sensitive"]

[node_generation.alien_artifact]
terrain_requirements = ["alien_ruins", "psi_rich"]
placement_rules = ["isolated", "elevated"]
frequency = 0.1
```

### Custom Pathfinding Logic

```lua
function custom_node_pathfinding(unit, source_node, dest_node, node_graph)
    -- Custom pathfinding for specialized units
    if unit.type == "flying_unit" then
        -- Ignore terrain obstacles
        return find_air_path(source_node, dest_node, node_graph)
    elseif unit.type == "teleporter" then
        -- Direct teleportation between nodes
        return create_teleport_path(source_node, dest_node)
    else
        -- Standard pathfinding
        return standard_node_pathfinding(unit, source_node, dest_node, node_graph)
    end
end
```

This AI movement using map nodes design creates sophisticated navigation and positioning behaviors while maintaining deterministic, performant systems suitable for modding and testing.