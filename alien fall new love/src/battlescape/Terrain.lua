--- Terrain Class
-- Represents specific terrain types for tactical gameplay
--
-- @classmod engine.world.Terrain

local Terrain = {}
Terrain.__index = Terrain

--- Create a new terrain instance
-- @param data Terrain data from TOML configuration
-- @return Terrain instance
function Terrain.new(data)
    local self = setmetatable({}, Terrain)

    -- Basic terrain properties
    self.id = data.id
    self.name = data.name
    self.description = data.description or ""
    self.type = data.type or "ground"

    -- Physical properties
    self.properties = data.properties or {}
    self.movement_cost = self.properties.movement_cost or 1.0
    self.cover_bonus = self.properties.cover_bonus or 0.0
    self.visibility_modifier = self.properties.visibility_modifier or 1.0
    self.elevation = self.properties.elevation or 0

    -- Combat properties
    self.combat = data.combat or {}
    self.accuracy_modifier = self.combat.accuracy_modifier or 0
    self.defense_bonus = self.combat.defense_bonus or 0
    self.flanking_penalty = self.combat.flanking_penalty or 0

    -- Visual properties
    self.visual = data.visual or {}
    self.color = self.visual.color or {128, 128, 128}
    self.texture = self.visual.texture or "default_texture"
    self.height_variation = self.visual.height_variation or 0.0

    return self
end

--- Get movement cost for this terrain
-- @param unit_type The type of unit moving (infantry, vehicle, etc.)
-- @return Movement cost multiplier
function Terrain:get_movement_cost(unit_type)
    local base_cost = self.movement_cost

    -- Apply unit-specific modifiers
    if unit_type == "vehicle" and self.type == "water" then
        return 0  -- Vehicles can't cross water
    elseif unit_type == "flying" then
        return 1.0  -- Flying units ignore terrain
    elseif unit_type == "infantry" and self.type == "urban" then
        base_cost = base_cost * 0.9  -- Infantry move well in urban areas
    end

    return base_cost
end

--- Get cover bonus provided by this terrain
-- @return Cover bonus value (0.0 to 1.0)
function Terrain:get_cover_bonus()
    return self.cover_bonus
end

--- Get visibility modifier for this terrain
-- @return Visibility multiplier
function Terrain:get_visibility_modifier()
    return self.visibility_modifier
end

--- Get combat modifiers for this terrain
-- @return Table with combat modifiers
function Terrain:get_combat_modifiers()
    return {
        accuracy_modifier = self.accuracy_modifier,
        defense_bonus = self.defense_bonus,
        flanking_penalty = self.flanking_penalty
    }
end

--- Check if this terrain blocks line of sight
-- @param height Height of the viewer
-- @return true if blocks LOS, false otherwise
function Terrain:blocks_line_of_sight(height)
    if self.elevation > height then
        return true
    end

    -- Dense terrain types block LOS
    if self.type == "vegetation" and self.cover_bonus > 0.7 then
        return true
    elseif self.type == "building" then
        return true
    end

    return false
end

--- Check if this terrain is passable
-- @param unit_type The type of unit attempting to pass
-- @return true if passable, false otherwise
function Terrain:is_passable(unit_type)
    if unit_type == "flying" then
        return true
    elseif self.type == "water" and unit_type ~= "amphibious" then
        return false
    elseif self.type == "building" and unit_type ~= "infantry" then
        return false
    end

    return true
end

--- Get elevation at this terrain location
-- @return Elevation value
function Terrain:get_elevation()
    return self.elevation
end

--- Get visual properties for rendering
-- @return Table with visual data
function Terrain:get_visual_properties()
    return {
        color = self.color,
        texture = self.texture,
        height_variation = self.height_variation,
        elevation = self.elevation
    }
end

--- Calculate pathfinding cost for this terrain
-- @param unit_type The type of unit pathfinding
-- @return Pathfinding cost
function Terrain:get_pathfinding_cost(unit_type)
    if not self:is_passable(unit_type) then
        return 999  -- Impassable
    end

    local cost = self:get_movement_cost(unit_type)

    -- Add penalties for difficult terrain
    if self.type == "desert" then
        cost = cost * 1.2
    elseif self.type == "mountain" then
        cost = cost * 1.5
    elseif self.type == "water" then
        cost = cost * 2.0
    end

    return cost
end

--- Get tactical information for this terrain
-- @return Table with tactical data
function Terrain:get_tactical_info()
    return {
        movement_cost = self.movement_cost,
        cover_bonus = self.cover_bonus,
        defense_bonus = self.defense_bonus,
        elevation = self.elevation,
        blocks_los = self:blocks_line_of_sight(1.7),  -- Average human height
        type = self.type
    }
end

--- Get display information for UI
-- @return Table with display data
function Terrain:get_display_info()
    return {
        id = self.id,
        name = self.name,
        description = self.description,
        type = self.type,
        movement_cost = self.movement_cost,
        cover_bonus = self.cover_bonus,
        defense_bonus = self.defense_bonus
    }
end

return Terrain
