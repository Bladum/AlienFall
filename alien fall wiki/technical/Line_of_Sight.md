# Line of Sight

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Core Algorithm](#core-algorithm)
  - [Visibility Cone](#visibility-cone)
  - [Cover Calculation](#cover-calculation)
  - [Visibility States](#visibility-states)
  - [Shooting Mechanics](#shooting-mechanics)
  - [Optimization](#optimization)
  - [Special Cases](#special-cases)
  - [Debug Visualization](#debug-visualization)
- [Examples](#examples)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Line of Sight system determines visibility between units, calculates cover bonuses, and resolves shooting mechanics in Alien Fall's tactical battlescape using Bresenham's line algorithm with height-aware tile checking for fast, deterministic visibility calculations on a 2D grid. The algorithm traces straight lines from shooter to target while accounting for elevation differences, terrain obstacles, and cover objects to determine whether units can see and shoot at each other with sub-tile precision.

## Mechanics

### Core Algorithm

### Bresenham's Line Algorithm

**Basic Implementation:**
```lua
function bresenham_line(x0, y0, x1, y1)
    local points = {}
    local dx = math.abs(x1 - x0)
    local dy = math.abs(y1 - y0)
    local sx = x0 < x1 and 1 or -1
    local sy = y0 < y1 and 1 or -1
    local err = dx - dy
    
    while true do
        table.insert(points, {x = x0, y = y0})
        
        if x0 == x1 and y0 == y1 then
            break
        end
        
        local e2 = 2 * err
        if e2 > -dy then
            err = err - dy
            x0 = x0 + sx
        end
        if e2 < dx then
            err = err + dx
            y0 = y0 + sy
        end
    end
    
    return points
end
```

### Height-Aware LOS Check

**3D Visibility:**
```lua
function check_line_of_sight(map, from_unit, to_unit)
    local line = bresenham_line(from_unit.x, from_unit.y, to_unit.x, to_unit.y)
    
    -- Start and end heights
    local start_height = from_unit.height + from_unit.eye_height  -- e.g., 0 + 1.5 = 1.5 tiles
    local end_height = to_unit.height + to_unit.center_height    -- e.g., 0 + 1.0 = 1.0 tiles
    
    -- Check each tile along the line
    for i = 2, #line - 1 do  -- Skip start and end tiles
        local point = line[i]
        local tile = map[point.y][point.x]
        
        -- Interpolate height at this point
        local progress = i / #line
        local ray_height = start_height + (end_height - start_height) * progress
        
        -- Check if tile blocks LOS
        if tile_blocks_los(tile, ray_height) then
            return false, {blocked_at = point, blocker = tile}
        end
    end
    
    return true, nil
end
```

**Tile Blocking Logic:**
```lua
function tile_blocks_los(tile, ray_height)
    if tile.type == "wall" then
        -- Walls block all heights up to their height
        return ray_height <= tile.height
    elseif tile.type == "cover" then
        -- Cover blocks up to half height
        return ray_height <= tile.cover_height
    elseif tile.type == "object" then
        -- Objects block up to their height
        return ray_height <= tile.object_height
    else
        -- Floor tiles don't block
        return false
    end
end
```

---

## Visibility Cone

### Field of View

**180° Front Arc:**
```lua
function is_in_field_of_view(unit, target)
    -- Calculate angle to target
    local dx = target.x - unit.x
    local dy = target.y - unit.y
    local angle_to_target = math.atan2(dy, dx)
    
    -- Normalize to 0-360°
    angle_to_target = (angle_to_target * 180 / math.pi + 360) % 360
    
    -- Unit's facing direction (0-360°)
    local unit_facing = unit.facing
    
    -- Calculate angle difference
    local angle_diff = math.abs(angle_to_target - unit_facing)
    if angle_diff > 180 then
        angle_diff = 360 - angle_diff
    end
    
    -- Check if within 180° front arc (90° on each side)
    return angle_diff <= 90
end
```

**360° Omnidirectional:**
```lua
function is_visible_omnidirectional(map, from_unit, to_unit)
    -- No facing check, just LOS
    return check_line_of_sight(map, from_unit, to_unit)
end
```

### Vision Range

**Maximum Sight Distance:**
```lua
function calculate_vision_range(unit, light_level)
    local base_range = 20  -- 20 tiles in daylight
    
    -- Modifiers
    local light_modifier = light_level  -- 0.0 (pitch black) to 1.0 (full daylight)
    local perception_modifier = unit.stats.perception / 50  -- Normalized to ~1.0
    local equipment_modifier = get_vision_equipment_bonus(unit)  -- Night vision goggles, etc.
    
    return math.floor(base_range * light_modifier * perception_modifier * equipment_modifier)
end

function is_within_vision_range(from_unit, to_unit, light_level)
    local distance = calculate_distance(from_unit, to_unit)
    local max_range = calculate_vision_range(from_unit, light_level)
    
    return distance <= max_range
end
```

---

## Cover Calculation

### Cover Detection

**Cover Between Shooter and Target:**
```lua
function calculate_cover(map, shooter, target)
    local line = bresenham_line(shooter.x, shooter.y, target.x, target.y)
    local cover_value = 0
    local cover_tiles = {}
    
    for i = 2, #line - 1 do
        local point = line[i]
        local tile = map[point.y][point.x]
        
        if tile.type == "cover" then
            -- Cover only applies if adjacent to target
            local dist_to_target = calculate_distance(point, target)
            if dist_to_target <= 1 then
                cover_value = math.max(cover_value, tile.cover_value)
                table.insert(cover_tiles, tile)
            end
        end
    end
    
    return cover_value, cover_tiles
end
```

**Cover Values:**
```lua
cover_types = {
    none = 0,         -- No cover
    half = 50,        -- Half cover (waist-high wall, barrel)
    full = 100        -- Full cover (tall wall, building corner)
}
```

### Angle-Based Cover

**Flanking Detection:**
```lua
function calculate_cover_with_angle(map, shooter, target)
    local base_cover, cover_tiles = calculate_cover(map, shooter, target)
    
    if #cover_tiles == 0 then
        return 0  -- No cover
    end
    
    -- Get cover tile (closest to target)
    local cover_tile = cover_tiles[1]
    
    -- Calculate angle from target to shooter
    local shooter_angle = calculate_angle(target, shooter)
    
    -- Calculate cover facing direction
    local cover_facing = cover_tile.facing or calculate_cover_facing(map, cover_tile)
    
    -- Calculate angle difference
    local angle_diff = math.abs(shooter_angle - cover_facing)
    if angle_diff > 180 then
        angle_diff = 360 - angle_diff
    end
    
    -- Cover effectiveness based on angle
    if angle_diff <= 45 then
        -- Direct frontal: full cover
        return base_cover
    elseif angle_diff <= 90 then
        -- Side angle: half effectiveness
        return base_cover * 0.5
    else
        -- Flanked: no cover
        return 0
    end
end
```

---

## Visibility States

### Unit Visibility

**Visibility Categories:**
```lua
visibility_states = {
    "hidden",        -- Not visible, no LOS
    "spotted",       -- Visible, LOS established
    "tracked",       -- Was visible, position known
    "suspected"      -- Heard/detected indirectly
}
```

**Visibility Check:**
```lua
function update_unit_visibility(observer, target, map, light_level)
    -- Check range
    if not is_within_vision_range(observer, target, light_level) then
        return "hidden"
    end
    
    -- Check field of view
    if not is_in_field_of_view(observer, target) then
        return "hidden"
    end
    
    -- Check line of sight
    local has_los, blocker = check_line_of_sight(map, observer, target)
    if has_los then
        target.last_seen_position = {x = target.x, y = target.y}
        target.last_seen_turn = map.current_turn
        return "spotted"
    else
        -- Check if recently seen
        if target.last_seen_turn and (map.current_turn - target.last_seen_turn) <= 3 then
            return "tracked"
        else
            return "hidden"
        end
    end
end
```

### Fog of War

**Revealed Tiles:**
```lua
function update_fog_of_war(map, units)
    -- Reset fog
    for y = 1, map.height do
        for x = 1, map.width do
            map[y][x].visible = false
            map[y][x].explored = map[y][x].explored or false
        end
    end
    
    -- Reveal tiles visible to player units
    for _, unit in ipairs(units) do
        if unit.faction == "player" then
            local vision_range = calculate_vision_range(unit, map.light_level)
            reveal_tiles_around_unit(map, unit, vision_range)
        end
    end
end

function reveal_tiles_around_unit(map, unit, range)
    for y = unit.y - range, unit.y + range do
        for x = unit.x - range, unit.x + range do
            if is_valid_tile(map, x, y) then
                local distance = calculate_distance(unit, {x = x, y = y})
                if distance <= range then
                    local has_los = check_line_of_sight(map, unit, {x = x, y = y, height = 0})
                    if has_los then
                        map[y][x].visible = true
                        map[y][x].explored = true
                    end
                end
            end
        end
    end
end
```

---

## Shooting Mechanics

### Shot Path Calculation

**Projectile Trajectory:**
```lua
function calculate_shot_path(shooter, target, weapon)
    local path = bresenham_line(shooter.x, shooter.y, target.x, target.y)
    
    -- Calculate trajectory with bullet drop (if applicable)
    local distance = #path
    local drop_per_tile = weapon.bullet_drop or 0
    
    for i, point in ipairs(path) do
        local progress = i / distance
        point.height = shooter.height + (target.height - shooter.height) * progress
        point.height = point.height - (drop_per_tile * i * progress)  -- Ballistic arc
    end
    
    return path
end
```

**Hit Probability:**
```lua
function calculate_hit_chance(shooter, target, map)
    local base_accuracy = shooter.stats.accuracy
    local weapon_accuracy = shooter.weapon.accuracy
    
    -- Distance penalty
    local distance = calculate_distance(shooter, target)
    local distance_penalty = math.max(0, (distance - shooter.weapon.optimal_range) * 2)
    
    -- Cover bonus for target
    local cover_value, _ = calculate_cover_with_angle(map, shooter, target)
    local cover_bonus = cover_value * 0.5  -- 50% of cover value applies to accuracy
    
    -- Movement penalty
    local movement_penalty = shooter.moved_this_turn and 20 or 0
    
    -- Calculate final hit chance
    local hit_chance = base_accuracy + weapon_accuracy - distance_penalty - cover_bonus - movement_penalty
    hit_chance = math.max(5, math.min(95, hit_chance))  -- Clamp to 5-95%
    
    return hit_chance
end
```

### Collision Detection

**Shot Collision:**
```lua
function resolve_shot(shooter, target, map)
    local shot_path = calculate_shot_path(shooter, target, shooter.weapon)
    
    -- Check each tile for obstacles
    for i = 2, #shot_path - 1 do  -- Skip shooter and target tiles
        local point = shot_path[i]
        local tile = map[point.y][point.x]
        
        -- Check for obstacle collision
        if tile_blocks_projectile(tile, point.height) then
            -- Shot hits obstacle
            apply_damage_to_tile(tile, shooter.weapon.damage)
            return {hit = false, blocked_by = tile, position = point}
        end
        
        -- Check for unit collision (friendly fire)
        local unit_at_tile = get_unit_at_position(map, point.x, point.y)
        if unit_at_tile and unit_at_tile ~= target then
            -- Roll for accidental hit
            if roll_chance(0.1) then  -- 10% chance
                return {hit = true, target = unit_at_tile, accidental = true}
            end
        end
    end
    
    -- Shot reaches target tile
    local hit_chance = calculate_hit_chance(shooter, target, map)
    local hit = roll_chance(hit_chance / 100)
    
    return {hit = hit, target = target, blocked = false}
end
```

---

## Optimization

### Spatial Partitioning

**Grid-Based Queries:**
```lua
function create_spatial_grid(map, cell_size)
    local grid = {}
    grid.cell_size = cell_size
    grid.width = math.ceil(map.width / cell_size)
    grid.height = math.ceil(map.height / cell_size)
    grid.cells = {}
    
    for y = 1, grid.height do
        grid.cells[y] = {}
        for x = 1, grid.width do
            grid.cells[y][x] = {}
        end
    end
    
    return grid
end

function add_unit_to_spatial_grid(grid, unit)
    local cell_x = math.floor(unit.x / grid.cell_size) + 1
    local cell_y = math.floor(unit.y / grid.cell_size) + 1
    
    table.insert(grid.cells[cell_y][cell_x], unit)
end

function get_nearby_units(grid, position, radius)
    local cell_radius = math.ceil(radius / grid.cell_size)
    local center_x = math.floor(position.x / grid.cell_size) + 1
    local center_y = math.floor(position.y / grid.cell_size) + 1
    
    local nearby_units = {}
    for dy = -cell_radius, cell_radius do
        for dx = -cell_radius, cell_radius do
            local cx = center_x + dx
            local cy = center_y + dy
            if cy >= 1 and cy <= grid.height and cx >= 1 and cx <= grid.width then
                for _, unit in ipairs(grid.cells[cy][cx]) do
                    table.insert(nearby_units, unit)
                end
            end
        end
    end
    
    return nearby_units
end
```

### Visibility Caching

**Cache LOS Results:**
```lua
los_cache = {}

function check_line_of_sight_cached(map, from_unit, to_unit)
    local key = string.format("%d,%d-%d,%d-%d", 
        from_unit.x, from_unit.y, to_unit.x, to_unit.y, map.cache_version)
    
    if los_cache[key] ~= nil then
        return los_cache[key]
    end
    
    local result = check_line_of_sight(map, from_unit, to_unit)
    los_cache[key] = result
    
    return result
end

function invalidate_los_cache(map)
    map.cache_version = (map.cache_version or 0) + 1
    los_cache = {}
end
```

---

## Special Cases

### Multi-Level Maps

**Elevation Handling:**
```lua
function check_los_with_elevation(map, from_unit, to_unit)
    local elevation_diff = to_unit.elevation - from_unit.elevation
    
    -- Higher units have advantage
    if elevation_diff > 1 then
        -- Target is significantly higher, may have cover advantage
        return check_line_of_sight_uphill(map, from_unit, to_unit)
    elseif elevation_diff < -1 then
        -- Shooter is higher, easier to see over cover
        return check_line_of_sight_downhill(map, from_unit, to_unit)
    else
        -- Same level
        return check_line_of_sight(map, from_unit, to_unit)
    end
end
```

### Smoke and Obscurement

**Vision Blocking Effects:**
```lua
function check_los_through_smoke(map, from_unit, to_unit)
    local line = bresenham_line(from_unit.x, from_unit.y, to_unit.x, to_unit.y)
    local smoke_tiles = 0
    
    for i = 2, #line - 1 do
        local point = line[i]
        local tile = map[point.y][point.x]
        
        if tile.has_smoke then
            smoke_tiles = smoke_tiles + 1
        end
    end
    
    -- Each smoke tile reduces vision range by 20%
    local vision_reduction = smoke_tiles * 0.2
    local effective_range = calculate_vision_range(from_unit, map.light_level) * (1 - vision_reduction)
    
    local distance = calculate_distance(from_unit, to_unit)
    if distance > effective_range then
        return false, {blocked_by_smoke = true}
    end
    
    return check_line_of_sight(map, from_unit, to_unit)
end
```

---

## Debug Visualization

### LOS Debug Rendering

**Visual Debug Tools:**
```lua
function draw_los_debug(map, from_unit, to_unit, result)
    local line = bresenham_line(from_unit.x, from_unit.y, to_unit.x, to_unit.y)
    
    for i, point in ipairs(line) do
        local screen_x = point.x * GRID_SIZE
        local screen_y = point.y * GRID_SIZE
        
        if i == 1 or i == #line then
            -- Draw endpoints in green
            love.graphics.setColor(0, 1, 0, 0.5)
        elseif result and not result.hit and result.blocked_at and 
               result.blocked_at.x == point.x and result.blocked_at.y == point.y then
            -- Draw blocking point in red
            love.graphics.setColor(1, 0, 0, 0.8)
        else
            -- Draw line in yellow
            love.graphics.setColor(1, 1, 0, 0.3)
        end
        
        love.graphics.rectangle("fill", screen_x, screen_y, GRID_SIZE, GRID_SIZE)
    end
    
    love.graphics.setColor(1, 1, 1, 1)
end
```

---

## Cross-References

**Related Systems:**
- [Battlescape](../battlescape/README.md) - Tactical combat mechanics
- [Cover System](../battlescape/Cover.md) - Cover mechanics and formulas
- [Combat Resolution](../battlescape/Combat.md) - Damage calculation
- [AI System](../ai/README.md) - AI visibility and targeting
- [Grid System](Grid_System.md) - Tile-based coordinate system

**Implementation Files:**
- `src/battlescape/line_of_sight.lua` - LOS algorithm implementation
- `src/battlescape/visibility.lua` - Fog of war and visibility states
- `src/battlescape/cover.lua` - Cover calculation
- `src/battlescape/shooting.lua` - Shot path and collision detection

---

## Version History

- **v1.0 (2025-09-30):** Initial technical specification for LOS algorithm
