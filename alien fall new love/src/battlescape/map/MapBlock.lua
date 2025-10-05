--- Map Block Class
-- Represents structural map elements like buildings and roads
--
-- @classmod engine.world.MapBlock

local MapBlock = {}
MapBlock.__index = MapBlock

--- Create a new Map Block instance
-- @param data Map Block data from TOML configuration
-- @return MapBlock instance
function MapBlock.new(data)
    local self = setmetatable({}, MapBlock)

    -- Basic block properties
    self.id = data.id
    self.name = data.name
    self.description = data.description or ""
    self.type = data.type or "structure"

    -- Physical properties
    self.properties = data.properties or {}
    self.width = self.properties.width or 1
    self.height = self.properties.height or 1
    self.floors = self.properties.floors or 1
    self.capacity = self.properties.capacity or 0

    -- Terrain properties
    self.terrain = data.terrain or {}
    self.base_terrain = self.terrain.base_terrain or "ground"
    self.interior_terrain = self.terrain.interior_terrain or "concrete"
    self.roof_terrain = self.terrain.roof_terrain or "concrete"

    -- Access properties
    self.access = data.access or {}
    self.entry_points = self.access.entry_points or {}
    self.interior_accessible = self.access.interior_accessible or false

    -- Combat properties
    self.combat = data.combat or {}
    self.cover_quality = self.combat.cover_quality or 0.0
    self.visibility_blocking = self.combat.visibility_blocking or 0.0
    self.destructible = self.combat.destructible or false

    -- Visual properties
    self.visual = data.visual or {}
    self.model = self.visual.model or "default_block"
    self.texture_set = self.visual.texture_set or "default"
    self.height_offset = self.visual.height_offset or 0

    -- State
    self.position = {x = 0, y = 0}
    self.rotation = 0
    self.health = 100
    self.destroyed = false

    return self
end

--- Set the position of this Map Block
-- @param x X coordinate
-- @param y Y coordinate
function MapBlock:set_position(x, y)
    self.position.x = x
    self.position.y = y
end

--- Set the rotation of this Map Block
-- @param rotation Rotation in degrees
function MapBlock:set_rotation(rotation)
    self.rotation = rotation
end

--- Get the bounding box of this Map Block
-- @return Table with bounding box coordinates
function MapBlock:get_bounds()
    return {
        x1 = self.position.x,
        y1 = self.position.y,
        x2 = self.position.x + self.width - 1,
        y2 = self.position.y + self.height - 1
    }
end

--- Check if a point is inside this Map Block
-- @param x X coordinate
-- @param y Y coordinate
-- @return true if point is inside, false otherwise
function MapBlock:contains_point(x, y)
    local bounds = self:get_bounds()
    return x >= bounds.x1 and x <= bounds.x2 and y >= bounds.y1 and y <= bounds.y2
end

--- Get entry points for this Map Block
-- @return Array of entry point positions
function MapBlock:get_entry_points()
    local points = {}

    for _, entry_point in ipairs(self.entry_points) do
        local point = self:resolve_entry_point(entry_point)
        if point then
            table.insert(points, point)
        end
    end

    return points
end

--- Resolve an entry point name to coordinates
-- @param entry_point_name Name of the entry point
-- @return Table with x,y coordinates or nil if not found
function MapBlock:resolve_entry_point(entry_point_name)
    local bounds = self:get_bounds()

    if entry_point_name == "front_door" then
        return {x = bounds.x1 + math.floor(self.width / 2), y = bounds.y1}
    elseif entry_point_name == "side_entrance" then
        return {x = bounds.x1, y = bounds.y1 + math.floor(self.height / 2)}
    elseif entry_point_name == "main_lobby" then
        return {x = bounds.x1 + math.floor(self.width / 2), y = bounds.y1 + 1}
    elseif entry_point_name == "service_entrance" then
        return {x = bounds.x2, y = bounds.y2}
    elseif entry_point_name == "north" then
        return {x = bounds.x1 + math.floor(self.width / 2), y = bounds.y1}
    elseif entry_point_name == "south" then
        return {x = bounds.x1 + math.floor(self.width / 2), y = bounds.y2}
    elseif entry_point_name == "east" then
        return {x = bounds.x2, y = bounds.y1 + math.floor(self.height / 2)}
    elseif entry_point_name == "west" then
        return {x = bounds.x1, y = bounds.y1 + math.floor(self.height / 2)}
    elseif entry_point_name == "main_path" then
        return {x = bounds.x1 + math.floor(self.width / 2), y = bounds.y1}
    elseif entry_point_name == "side_paths" then
        return {x = bounds.x1, y = bounds.y1 + math.floor(self.height / 2)}
    elseif entry_point_name == "main_gate" then
        return {x = bounds.x1 + math.floor(self.width / 2), y = bounds.y1}
    elseif entry_point_name == "loading_dock" then
        return {x = bounds.x2, y = bounds.y1 + math.floor(self.height / 2)}
    elseif entry_point_name == "maintenance_ladder" then
        return {x = bounds.x1 + math.floor(self.width / 2), y = bounds.y1}
    elseif entry_point_name == "bridge_deck" then
        return {x = bounds.x1 + math.floor(self.width / 2), y = bounds.y1 + math.floor(self.height / 2)}
    end

    return nil
end

--- Check if this Map Block provides cover at a given position
-- @param x X coordinate
-- @param y Y coordinate
-- @return Cover quality (0.0 to 1.0)
function MapBlock:get_cover_at(x, y)
    if not self:contains_point(x, y) then
        return 0.0
    end

    -- Edge positions provide better cover
    local bounds = self:get_bounds()
    local is_edge = x == bounds.x1 or x == bounds.x2 or y == bounds.y1 or y == bounds.y2

    if is_edge then
        return self.cover_quality * 1.2
    else
        return self.cover_quality
    end
end

--- Check if this Map Block blocks visibility from a given position
-- @param from_x Source X coordinate
-- @param from_y Source Y coordinate
-- @param to_x Target X coordinate
-- @param to_y Target Y coordinate
-- @return true if blocks visibility, false otherwise
function MapBlock:blocks_visibility(from_x, from_y, to_x, to_y)
    if not self.destructible or self.destroyed then
        return false
    end

    -- Simple bounding box check - more sophisticated implementations would do proper line of sight
    local from_inside = self:contains_point(from_x, from_y)
    local to_inside = self:contains_point(to_x, to_y)

    -- If both points are inside, visibility is not blocked
    if from_inside and to_inside then
        return false
    end

    -- If one point is inside and the other is outside, check blocking
    if (from_inside or to_inside) and self.visibility_blocking > 0.5 then
        return true
    end

    return false
end

--- Apply damage to this Map Block
-- @param damage Amount of damage to apply
-- @return true if destroyed, false otherwise
function MapBlock:take_damage(damage)
    if not self.destructible or self.destroyed then
        return false
    end

    self.health = math.max(0, self.health - damage)

    if self.health <= 0 then
        self.destroyed = true
        return true
    end

    return false
end

--- Get the terrain type at a specific position within this block
-- @param x X coordinate
-- @param y Y coordinate
-- @param floor Floor number (1 = ground, higher = upper floors)
-- @return Terrain type string
function MapBlock:get_terrain_at(x, y, floor)
    if not self:contains_point(x, y) then
        return nil
    end

    if floor == 1 then
        return self.base_terrain
    elseif floor <= self.floors then
        return self.interior_terrain
    else
        return self.roof_terrain
    end
end

--- Get visual properties for rendering
-- @return Table with visual data
function MapBlock:get_visual_properties()
    return {
        model = self.model,
        texture_set = self.texture_set,
        height_offset = self.height_offset,
        width = self.width,
        height = self.height,
        floors = self.floors,
        destroyed = self.destroyed
    }
end

--- Get tactical information for this Map Block
-- @return Table with tactical data
function MapBlock:get_tactical_info()
    return {
        type = self.type,
        width = self.width,
        height = self.height,
        cover_quality = self.cover_quality,
        destructible = self.destructible,
        destroyed = self.destroyed,
        health = self.health,
        entry_points = #self.entry_points,
        interior_accessible = self.interior_accessible
    }
end

--- Get display information for UI
-- @return Table with display data
function MapBlock:get_display_info()
    return {
        id = self.id,
        name = self.name,
        description = self.description,
        type = self.type,
        width = self.width,
        height = self.height,
        floors = self.floors,
        capacity = self.capacity,
        destructible = self.destructible,
        destroyed = self.destroyed
    }
end

return MapBlock
