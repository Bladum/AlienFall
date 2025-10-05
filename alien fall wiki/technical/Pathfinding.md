# Pathfinding

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
- [Examples](#examples)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Pathfinding system provides tactical movement planning for units in Alien Fall using A* algorithm with action point cost calculations, enabling both player-controlled movement planning and AI navigation across the 20×20 battlescape grid while accounting for terrain, obstacles, and tactical positioning requirements.

## Mechanicsding Algorithm

**Status:** Technical Specification  
**Last Updated:** September 30, 2025  
**Related Systems:** Battlescape, AI, Movement, Grid System

---

## Purpose

This document defines the **pathfinding algorithm** used in AlienFall for calculating unit movement paths, AI navigation, and tactical positioning.

**Key Insight:** A* pathfinding with tile-based movement costs, factoring in terrain, obstacles, and tactical considerations like cover and threat zones.

---

## Core Algorithm: A* Pathfinding

### Basic A* Implementation

**Standard A* Search:**
```lua
function astar_pathfind(map, start, goal)
    local open_set = MinHeap.new()
    local closed_set = {}
    local came_from = {}
    local g_score = {}
    local f_score = {}
    
    -- Initialize start node
    local start_key = pos_to_key(start)
    g_score[start_key] = 0
    f_score[start_key] = heuristic(start, goal)
    open_set:insert(start, f_score[start_key])
    
    while not open_set:empty() do
        local current = open_set:pop()
        local current_key = pos_to_key(current)
        
        -- Goal reached
        if current.x == goal.x and current.y == goal.y then
            return reconstruct_path(came_from, current)
        end
        
        closed_set[current_key] = true
        
        -- Check neighbors
        for _, neighbor in ipairs(get_neighbors(map, current)) do
            local neighbor_key = pos_to_key(neighbor)
            
            if not closed_set[neighbor_key] then
                local tentative_g = g_score[current_key] + movement_cost(map, current, neighbor)
                
                if not g_score[neighbor_key] or tentative_g < g_score[neighbor_key] then
                    came_from[neighbor_key] = current
                    g_score[neighbor_key] = tentative_g
                    f_score[neighbor_key] = tentative_g + heuristic(neighbor, goal)
                    
                    if not open_set:contains(neighbor) then
                        open_set:insert(neighbor, f_score[neighbor_key])
                    else
                        open_set:update(neighbor, f_score[neighbor_key])
                    end
                end
            end
        end
    end
    
    -- No path found
    return nil
end
```

### Helper Functions

**Position Key:**
```lua
function pos_to_key(pos)
    return string.format("%d,%d", pos.x, pos.y)
end
```

**Heuristic (Manhattan Distance):**
```lua
function heuristic(a, b)
    return math.abs(a.x - b.x) + math.abs(a.y - b.y)
end
```

**Path Reconstruction:**
```lua
function reconstruct_path(came_from, current)
    local path = {current}
    local current_key = pos_to_key(current)
    
    while came_from[current_key] do
        current = came_from[current_key]
        current_key = pos_to_key(current)
        table.insert(path, 1, current)
    end
    
    return path
end
```

---

## Movement Costs

### Tile Movement Costs

**Base Costs:**
```lua
tile_movement_costs = {
    floor = 1.0,           -- Standard movement
    grass = 1.0,
    concrete = 1.0,
    
    rough_terrain = 1.5,   -- Slower movement
    rubble = 1.5,
    mud = 1.5,
    
    water_shallow = 2.0,   -- Much slower
    
    wall = math.huge,      -- Impassable
    water_deep = math.huge,
    void = math.huge
}
```

**Cost Calculation:**
```lua
function movement_cost(map, from, to)
    local tile = map[to.y][to.x]
    
    -- Base cost from tile type
    local base_cost = tile_movement_costs[tile.type] or 1.0
    
    -- Diagonal movement costs more (√2 ≈ 1.41)
    local diagonal_cost = (from.x ~= to.x and from.y ~= to.y) and 1.41 or 1.0
    
    -- Elevation change
    local elevation_cost = math.abs((tile.elevation or 0) - (map[from.y][from.x].elevation or 0)) * 0.5
    
    -- Cover penalty (moving through cover is slower)
    local cover_cost = tile.has_cover and 0.2 or 0
    
    return base_cost * diagonal_cost + elevation_cost + cover_cost
end
```

### Dynamic Costs

**Threat Zones:**
```lua
function calculate_threat_cost(map, position, enemy_units)
    local threat_cost = 0
    
    for _, enemy in ipairs(enemy_units) do
        local distance = calculate_distance(position, enemy)
        local weapon_range = enemy.weapon and enemy.weapon.range or 10
        
        if distance <= weapon_range then
            -- Higher cost for tiles within enemy weapon range
            local danger_level = 1 - (distance / weapon_range)
            threat_cost = threat_cost + danger_level * 5  -- Up to +5 cost
        end
    end
    
    return threat_cost
end
```

**Unit Blocking:**
```lua
function get_unit_at_position(map, x, y)
    for _, unit in ipairs(map.units) do
        if unit.x == x and unit.y == y and unit.alive then
            return unit
        end
    end
    return nil
end

function movement_cost_with_units(map, from, to)
    local base_cost = movement_cost(map, from, to)
    
    -- Check for blocking unit
    local unit_at_dest = get_unit_at_position(map, to.x, to.y)
    if unit_at_dest then
        if unit_at_dest.faction == map.current_unit.faction then
            -- Friendly unit: high cost (prefer not to path through)
            return base_cost + 10
        else
            -- Enemy unit: impassable
            return math.huge
        end
    end
    
    return base_cost
end
```

---

## Neighbor Selection

### Cardinal and Diagonal Movement

**8-Direction Movement:**
```lua
function get_neighbors(map, pos)
    local neighbors = {}
    local directions = {
        {x = 0, y = -1},   -- North
        {x = 1, y = -1},   -- Northeast
        {x = 1, y = 0},    -- East
        {x = 1, y = 1},    -- Southeast
        {x = 0, y = 1},    -- South
        {x = -1, y = 1},   -- Southwest
        {x = -1, y = 0},   -- West
        {x = -1, y = -1}   -- Northwest
    }
    
    for _, dir in ipairs(directions) do
        local nx = pos.x + dir.x
        local ny = pos.y + dir.y
        
        if is_valid_tile(map, nx, ny) and is_passable(map, nx, ny) then
            table.insert(neighbors, {x = nx, y = ny})
        end
    end
    
    return neighbors
end
```

**Diagonal Blocking:**
```lua
function is_diagonal_blocked(map, from, to)
    -- Diagonal movement blocked if both cardinal neighbors are blocked
    local dx = to.x - from.x
    local dy = to.y - from.y
    
    if dx ~= 0 and dy ~= 0 then
        local block_x = not is_passable(map, from.x + dx, from.y)
        local block_y = not is_passable(map, from.x, from.y + dy)
        
        if block_x and block_y then
            return true  -- Both sides blocked, can't squeeze through
        end
    end
    
    return false
end

function get_neighbors_with_diagonal_check(map, pos)
    local neighbors = {}
    local directions = {
        {x = 0, y = -1},   -- North
        {x = 1, y = -1},   -- Northeast
        {x = 1, y = 0},    -- East
        {x = 1, y = 1},    -- Southeast
        {x = 0, y = 1},    -- South
        {x = -1, y = 1},   -- Southwest
        {x = -1, y = 0},   -- West
        {x = -1, y = -1}   -- Northwest
    }
    
    for _, dir in ipairs(directions) do
        local nx = pos.x + dir.x
        local ny = pos.y + dir.y
        local next_pos = {x = nx, y = ny}
        
        if is_valid_tile(map, nx, ny) and 
           is_passable(map, nx, ny) and 
           not is_diagonal_blocked(map, pos, next_pos) then
            table.insert(neighbors, next_pos)
        end
    end
    
    return neighbors
end
```

---

## AP-Constrained Pathfinding

### Movement Within AP Budget

**AP-Limited Path:**
```lua
function find_reachable_tiles(map, unit, max_ap)
    local reachable = {}
    local open_set = MinHeap.new()
    local cost_so_far = {}
    
    local start_key = pos_to_key({x = unit.x, y = unit.y})
    cost_so_far[start_key] = 0
    open_set:insert({x = unit.x, y = unit.y}, 0)
    
    while not open_set:empty() do
        local current = open_set:pop()
        local current_key = pos_to_key(current)
        local current_cost = cost_so_far[current_key]
        
        -- Mark as reachable
        reachable[current_key] = current
        
        -- Explore neighbors
        for _, neighbor in ipairs(get_neighbors(map, current)) do
            local neighbor_key = pos_to_key(neighbor)
            local move_cost = movement_cost(map, current, neighbor)
            local new_cost = current_cost + move_cost
            
            -- Only consider tiles within AP budget
            local ap_cost = calculate_ap_cost(new_cost, unit.stats.speed)
            if ap_cost <= max_ap then
                if not cost_so_far[neighbor_key] or new_cost < cost_so_far[neighbor_key] then
                    cost_so_far[neighbor_key] = new_cost
                    open_set:insert(neighbor, new_cost)
                end
            end
        end
    end
    
    return reachable
end
```

**Movement Cost to AP:**
```lua
function calculate_ap_cost(movement_cost, unit_speed)
    -- Formula: AP = Distance × (1 / Speed) × 4
    -- Speed ranges from 0.5 (slow) to 2.0 (fast)
    -- 4 AP per turn
    
    local ap_per_tile = 4 / unit_speed
    return movement_cost * ap_per_tile
end
```

---

## Tactical Pathfinding

### Cover-Seeking Path

**Prefer Cover Tiles:**
```lua
function pathfind_to_cover(map, unit, goal, enemy_units)
    -- Modified A* that prefers cover tiles
    local path = astar_pathfind_with_modifier(map, unit, goal, function(pos)
        local tile = map[pos.y][pos.x]
        local cover_bonus = 0
        
        -- Prefer tiles with cover
        if tile.has_cover then
            cover_bonus = -2  -- Negative cost = preferred
        end
        
        -- Avoid enemy threat zones
        local threat_cost = calculate_threat_cost(map, pos, enemy_units)
        
        return cover_bonus + threat_cost
    end)
    
    return path
end
```

### Flanking Path

**Path Around Enemy:**
```lua
function pathfind_flanking_route(map, unit, enemy)
    -- Find path that approaches from behind/side
    local enemy_facing = enemy.facing
    local preferred_angles = {
        enemy_facing + 135,  -- Behind left
        enemy_facing + 180,  -- Directly behind
        enemy_facing + 225   -- Behind right
    }
    
    local best_path = nil
    local best_score = -math.huge
    
    for _, angle in ipairs(preferred_angles) do
        -- Calculate position at angle
        local target_distance = 3  -- 3 tiles away
        local target_x = enemy.x + math.cos(math.rad(angle)) * target_distance
        local target_y = enemy.y + math.sin(math.rad(angle)) * target_distance
        
        -- Round to grid
        target_x = math.floor(target_x + 0.5)
        target_y = math.floor(target_y + 0.5)
        
        if is_valid_tile(map, target_x, target_y) and is_passable(map, target_x, target_y) then
            local path = astar_pathfind(map, unit, {x = target_x, y = target_y})
            
            if path then
                local score = -#path  -- Prefer shorter paths
                if score > best_score then
                    best_score = score
                    best_path = path
                end
            end
        end
    end
    
    return best_path
end
```

---

## Optimization

### Jump Point Search (JPS)

**JPS Optimization:**
```lua
function jps_pathfind(map, start, goal)
    -- Jump Point Search: faster A* for uniform-cost grids
    local open_set = MinHeap.new()
    local closed_set = {}
    local came_from = {}
    local g_score = {}
    
    local start_key = pos_to_key(start)
    g_score[start_key] = 0
    open_set:insert(start, heuristic(start, goal))
    
    while not open_set:empty() do
        local current = open_set:pop()
        local current_key = pos_to_key(current)
        
        if current.x == goal.x and current.y == goal.y then
            return reconstruct_path(came_from, current)
        end
        
        closed_set[current_key] = true
        
        -- Identify successors (jump points)
        local successors = identify_successors(map, current, came_from[current_key], goal)
        
        for _, jump_point in ipairs(successors) do
            local jump_key = pos_to_key(jump_point)
            
            if not closed_set[jump_key] then
                local tentative_g = g_score[current_key] + calculate_distance(current, jump_point)
                
                if not g_score[jump_key] or tentative_g < g_score[jump_key] then
                    came_from[jump_key] = current
                    g_score[jump_key] = tentative_g
                    open_set:insert(jump_point, tentative_g + heuristic(jump_point, goal))
                end
            end
        end
    end
    
    return nil
end

function identify_successors(map, current, parent, goal)
    local successors = {}
    local neighbors = prune_neighbors(map, current, parent)
    
    for _, neighbor in ipairs(neighbors) do
        local dx = neighbor.x - current.x
        local dy = neighbor.y - current.y
        local jump_point = jump(map, neighbor.x, neighbor.y, dx, dy, goal)
        
        if jump_point then
            table.insert(successors, jump_point)
        end
    end
    
    return successors
end
```

### Path Smoothing

**Reduce Path Waypoints:**
```lua
function smooth_path(map, path)
    if #path <= 2 then
        return path
    end
    
    local smoothed = {path[1]}
    local current_index = 1
    
    while current_index < #path do
        local farthest_visible = current_index
        
        -- Find farthest visible point
        for i = current_index + 2, #path do
            if has_clear_line(map, path[current_index], path[i]) then
                farthest_visible = i
            else
                break
            end
        end
        
        table.insert(smoothed, path[farthest_visible])
        current_index = farthest_visible
    end
    
    return smoothed
end

function has_clear_line(map, from, to)
    local line = bresenham_line(from.x, from.y, to.x, to.y)
    
    for i = 2, #line - 1 do
        local point = line[i]
        if not is_passable(map, point.x, point.y) then
            return false
        end
    end
    
    return true
end
```

---

## Special Movement

### Flying Units

**3D Pathfinding:**
```lua
function pathfind_flying(map, start, goal, max_altitude)
    -- Flying units ignore ground obstacles but have altitude limits
    local open_set = MinHeap.new()
    local closed_set = {}
    local came_from = {}
    local g_score = {}
    
    -- Add altitude dimension to positions
    start.z = start.z or 0
    goal.z = goal.z or 0
    
    local start_key = pos_to_key_3d(start)
    g_score[start_key] = 0
    open_set:insert(start, heuristic_3d(start, goal))
    
    while not open_set:empty() do
        local current = open_set:pop()
        local current_key = pos_to_key_3d(current)
        
        if current.x == goal.x and current.y == goal.y and current.z == goal.z then
            return reconstruct_path(came_from, current)
        end
        
        closed_set[current_key] = true
        
        -- 26-direction neighbors (8 horizontal + 9 up + 9 down)
        for _, neighbor in ipairs(get_neighbors_3d(map, current, max_altitude)) do
            local neighbor_key = pos_to_key_3d(neighbor)
            
            if not closed_set[neighbor_key] then
                local tentative_g = g_score[current_key] + movement_cost_3d(current, neighbor)
                
                if not g_score[neighbor_key] or tentative_g < g_score[neighbor_key] then
                    came_from[neighbor_key] = current
                    g_score[neighbor_key] = tentative_g
                    open_set:insert(neighbor, tentative_g + heuristic_3d(neighbor, goal))
                end
            end
        end
    end
    
    return nil
end
```

### Climbing/Jumping

**Vertical Movement:**
```lua
function can_climb(map, from, to)
    local elevation_diff = (map[to.y][to.x].elevation or 0) - (map[from.y][from.x].elevation or 0)
    
    -- Can climb up to 1 tile height
    if elevation_diff > 0 and elevation_diff <= 1 then
        -- Check if adjacent
        local distance = calculate_distance(from, to)
        return distance <= 1.41  -- Adjacent tile (including diagonal)
    end
    
    return false
end

function can_jump(unit, from, to)
    local distance = calculate_distance(from, to)
    local jump_range = unit.stats.athletics / 10  -- Athletics determines jump range
    
    return distance <= jump_range
end
```

---

## Debug Visualization

### Path Display

**Render Path:**
```lua
function draw_path_debug(path)
    love.graphics.setColor(0, 1, 1, 0.5)
    
    for i = 1, #path - 1 do
        local from = path[i]
        local to = path[i + 1]
        
        local fx = from.x * GRID_SIZE + GRID_SIZE / 2
        local fy = from.y * GRID_SIZE + GRID_SIZE / 2
        local tx = to.x * GRID_SIZE + GRID_SIZE / 2
        local ty = to.y * GRID_SIZE + GRID_SIZE / 2
        
        love.graphics.line(fx, fy, tx, ty)
    end
    
    -- Draw waypoints
    for i, pos in ipairs(path) do
        local x = pos.x * GRID_SIZE
        local y = pos.y * GRID_SIZE
        
        if i == 1 then
            love.graphics.setColor(0, 1, 0, 0.7)  -- Start = green
        elseif i == #path then
            love.graphics.setColor(1, 0, 0, 0.7)  -- End = red
        else
            love.graphics.setColor(0, 1, 1, 0.5)  -- Middle = cyan
        end
        
        love.graphics.circle("fill", x + GRID_SIZE / 2, y + GRID_SIZE / 2, 5)
    end
    
    love.graphics.setColor(1, 1, 1, 1)
end
```

---

## Cross-References

**Related Systems:**
- [Battlescape](../battlescape/README.md) - Tactical movement mechanics
- [Grid System](Grid_System.md) - Tile-based coordinate system
- [Action Economy](../core/Action_Economy.md) - AP costs for movement
- [AI System](../ai/README.md) - AI pathfinding and positioning
- [Line of Sight](Line_of_Sight.md) - Visibility calculations

**Implementation Files:**
- `src/battlescape/pathfinding.lua` - A* pathfinding implementation
- `src/battlescape/movement.lua` - Movement execution
- `src/utils/minheap.lua` - Priority queue for A*
- `src/ai/tactical_positioning.lua` - AI pathfinding logic

---

## Version History

- **v1.0 (2025-09-30):** Initial technical specification for pathfinding algorithm
