--- Map Script Class
-- Represents procedural generation scripts for creating maps
--
-- @classmod engine.world.MapScript

local MapScript = {}
MapScript.__index = MapScript

--- Create a new Map Script instance
-- @param data Map Script data from TOML configuration
-- @return MapScript instance
function MapScript.new(data)
    local self = setmetatable({}, MapScript)

    -- Basic script properties
    self.id = data.id
    self.name = data.name
    self.description = data.description or ""
    self.type = data.type or "procedural"

    -- Generation properties
    self.generation = data.generation or {}
    self.base_biome = self.generation.base_biome or "urban"
    self.size_range = self.generation.size_range or {20, 40}
    self.complexity = self.generation.complexity or 0.5

    -- Element definitions
    self.elements = data.elements or {}
    self.buildings = self.elements.buildings or {count = 0, types = {}}
    self.roads = self.elements.roads or {count = 0, types = {}}
    self.open_areas = self.elements.open_areas or {count = 0, types = {}}
    self.natural_features = self.elements.natural_features or {count = 0, types = {}}
    self.utilities = self.elements.utilities or {count = 0, types = {}}
    self.clearings = self.elements.clearings or {count = 0, types = {}}
    self.paths = self.elements.paths or {count = 0, types = {}}

    -- Generation rules
    self.rules = data.rules or {}
    self.building_density = self.rules.building_density or 0.5
    self.road_coverage = self.rules.road_coverage or 0.3
    self.open_space_ratio = self.rules.open_space_ratio or 0.2
    self.natural_density = self.rules.natural_density or 0.0
    self.elevation_variation = self.rules.elevation_variation or 0.0
    self.path_constraint = self.rules.path_constraint or false
    self.clearing_ratio = self.rules.clearing_ratio or 0.0
    self.facility_focus = self.rules.facility_focus or false
    self.research_focus = self.rules.research_focus or false
    self.extreme_conditions = self.rules.extreme_conditions or false

    -- Constraints
    self.constraints = data.constraints or {}
    self.min_building_separation = self.constraints.min_building_separation or 1
    self.max_road_length = self.constraints.max_road_length or 20
    self.required_accessibility = self.constraints.required_accessibility or 0.5
    self.min_clearing_size = self.constraints.min_clearing_size or 1
    self.max_tree_clusters = self.constraints.max_tree_clusters or 10
    self.min_path_width = self.constraints.min_path_width or 1
    self.max_elevation_change = self.constraints.max_elevation_change or 100
    self.min_facility_spacing = self.constraints.min_facility_spacing or 2
    self.max_sand_dunes = self.constraints.max_sand_dunes or 5
    self.heating_requirement = self.constraints.heating_requirement or false

    return self
end

--- Generate a map using this script
-- @param seed Random seed for reproducible generation
-- @param size_override Optional size override {width, height}
-- @return Generated map data
function MapScript:generate_map(seed, size_override)
    math.randomseed(seed)

    local size = size_override or {
        width = math.random(self.size_range[1], self.size_range[2]),
        height = math.random(self.size_range[1], self.size_range[2])
    }

    local map = {
        width = size.width,
        height = size.height,
        base_biome = self.base_biome,
        tiles = {},
        blocks = {},
        metadata = {
            script_id = self.id,
            seed = seed,
            complexity = self.complexity
        }
    }

    -- Initialize tiles
    for x = 1, size.width do
        map.tiles[x] = {}
        for y = 1, size.height do
            map.tiles[x][y] = {
                terrain = self.base_biome,
                elevation = 0,
                blocks = {}
            }
        end
    end

    -- Generate based on script type
    if self.type == "procedural" then
        self:generate_procedural(map)
    elseif self.type == "template" then
        self:generate_template(map)
    end

    -- Apply constraints
    self:apply_constraints(map)

    return map
end

--- Generate a procedural map
-- @param map Map data table to modify
function MapScript:generate_procedural(map)
    -- Generate buildings
    self:generate_buildings(map)

    -- Generate roads
    self:generate_roads(map)

    -- Generate open areas
    self:generate_open_areas(map)

    -- Generate natural features
    self:generate_natural_features(map)

    -- Generate utilities
    self:generate_utilities(map)
end

--- Generate buildings on the map
-- @param map Map data table
function MapScript:generate_buildings(map)
    local building_count = math.floor(self.buildings.count * (0.8 + math.random() * 0.4))

    for i = 1, building_count do
        local building_type = self.buildings.types[math.random(#self.buildings.types)]
        local x, y = self:find_valid_position(map, "building")

        if x and y then
            local block = {
                type = "building",
                id = building_type,
                x = x,
                y = y,
                rotation = math.random(0, 3) * 90
            }
            table.insert(map.blocks, block)
        end
    end
end

--- Generate roads on the map
-- @param map Map data table
function MapScript:generate_roads(map)
    local road_count = math.floor(self.roads.count * (0.8 + math.random() * 0.4))

    for i = 1, road_count do
        local road_type = self.roads.types[math.random(#self.roads.types)]
        local x, y = self:find_valid_position(map, "road")

        if x and y then
            local block = {
                type = "road",
                id = road_type,
                x = x,
                y = y,
                rotation = math.random(0, 3) * 90
            }
            table.insert(map.blocks, block)
        end
    end
end

--- Generate open areas on the map
-- @param map Map data table
function MapScript:generate_open_areas(map)
    local area_count = math.floor(self.open_areas.count * (0.8 + math.random() * 0.4))

    for i = 1, area_count do
        local area_type = self.open_areas.types[math.random(#self.open_areas.types)]
        local x, y = self:find_valid_position(map, "open_area")

        if x and y then
            local block = {
                type = "open_area",
                id = area_type,
                x = x,
                y = y,
                rotation = 0
            }
            table.insert(map.blocks, block)
        end
    end
end

--- Generate natural features on the map
-- @param map Map data table
function MapScript:generate_natural_features(map)
    if self.natural_features.count > 0 then
        local feature_count = math.floor(self.natural_features.count * (0.8 + math.random() * 0.4))

        for i = 1, feature_count do
            local feature_type = self.natural_features.types[math.random(#self.natural_features.types)]
            local x, y = self:find_valid_position(map, "natural")

            if x and y then
                local block = {
                    type = "natural",
                    id = feature_type,
                    x = x,
                    y = y,
                    rotation = math.random(0, 3) * 90
                }
                table.insert(map.blocks, block)
            end
        end
    end
end

--- Generate utilities on the map
-- @param map Map data table
function MapScript:generate_utilities(map)
    if self.utilities.count > 0 then
        local utility_count = math.floor(self.utilities.count * (0.8 + math.random() * 0.4))

        for i = 1, utility_count do
            local utility_type = self.utilities.types[math.random(#self.utilities.types)]
            local x, y = self:find_valid_position(map, "utility")

            if x and y then
                local block = {
                    type = "utility",
                    id = utility_type,
                    x = x,
                    y = y,
                    rotation = 0
                }
                table.insert(map.blocks, block)
            end
        end
    end
end

--- Generate a template-based map
-- @param map Map data table
function MapScript:generate_template(map)
    -- Template generation follows specific patterns
    if self.id == "desert_outpost" then
        self:generate_desert_outpost(map)
    elseif self.id == "arctic_research" then
        self:generate_arctic_research(map)
    else
        -- Fallback to procedural
        self:generate_procedural(map)
    end
end

--- Generate desert outpost template
-- @param map Map data table
function MapScript:generate_desert_outpost(map)
    -- Central facility
    table.insert(map.blocks, {
        type = "building",
        id = "industrial_complex",
        x = math.floor(map.width / 2),
        y = math.floor(map.height / 2),
        rotation = 0
    })

    -- Surrounding buildings
    local positions = {
        {x = math.floor(map.width / 2) - 3, y = math.floor(map.height / 2)},
        {x = math.floor(map.width / 2) + 3, y = math.floor(map.height / 2)},
        {x = math.floor(map.width / 2), y = math.floor(map.height / 2) - 3},
        {x = math.floor(map.width / 2), y = math.floor(map.height / 2) + 3}
    }

    for _, pos in ipairs(positions) do
        if pos.x > 0 and pos.x <= map.width and pos.y > 0 and pos.y <= map.height then
            table.insert(map.blocks, {
                type = "building",
                id = "building_residential",
                x = pos.x,
                y = pos.y,
                rotation = 0
            })
        end
    end
end

--- Generate arctic research template
-- @param map Map data table
function MapScript:generate_arctic_research(map)
    -- Main research facility
    table.insert(map.blocks, {
        type = "building",
        id = "building_office",
        x = math.floor(map.width / 2),
        y = math.floor(map.height / 2),
        rotation = 0
    })

    -- Research buildings in a cluster
    for i = 1, 5 do
        local angle = (i - 1) * (2 * math.pi / 5)
        local distance = 4
        local x = math.floor(map.width / 2 + math.cos(angle) * distance)
        local y = math.floor(map.height / 2 + math.sin(angle) * distance)

        if x > 0 and x <= map.width and y > 0 and y <= map.height then
            table.insert(map.blocks, {
                type = "building",
                id = "industrial_complex",
                x = x,
                y = y,
                rotation = 0
            })
        end
    end
end

--- Find a valid position for placing an element
-- @param map Map data table
-- @param element_type Type of element to place
-- @return x, y coordinates or nil if no valid position found
function MapScript:find_valid_position(map, element_type)
    local max_attempts = 50

    for attempt = 1, max_attempts do
        local x = math.random(1, map.width)
        local y = math.random(1, map.height)

        if self:is_valid_position(map, x, y, element_type) then
            return x, y
        end
    end

    return nil, nil
end

--- Check if a position is valid for placing an element
-- @param map Map data table
-- @param x X coordinate
-- @param y Y coordinate
-- @param element_type Type of element
-- @return true if valid, false otherwise
function MapScript:is_valid_position(map, x, y, element_type)
    -- Check bounds
    if x < 1 or x > map.width or y < 1 or y > map.height then
        return false
    end

    -- Check minimum separation from other buildings
    for _, block in ipairs(map.blocks) do
        local distance = math.sqrt((block.x - x)^2 + (block.y - y)^2)
        if element_type == "building" and block.type == "building" then
            if distance < self.min_building_separation then
                return false
            end
        elseif element_type == "utility" and block.type == "building" then
            if distance < self.min_facility_spacing then
                return false
            end
        end
    end

    return true
end

--- Apply constraints to the generated map
-- @param map Map data table
function MapScript:apply_constraints(map)
    -- Ensure accessibility
    self:ensure_accessibility(map)

    -- Apply size constraints
    self:apply_size_constraints(map)

    -- Apply special constraints
    if self.heating_requirement then
        self:add_heating_systems(map)
    end
end

--- Ensure the map has required accessibility
-- @param map Map data table
function MapScript:ensure_accessibility(map)
    -- Basic accessibility check - ensure roads connect major areas
    local has_roads = false
    for _, block in ipairs(map.blocks) do
        if block.type == "road" then
            has_roads = true
            break
        end
    end

    if not has_roads and self.required_accessibility > 0.3 then
        -- Add a basic road network
        self:add_basic_road_network(map)
    end
end

--- Apply size constraints to map elements
-- @param map Map data table
function MapScript:apply_size_constraints(map)
    -- Remove elements that exceed size limits
    local valid_blocks = {}

    for _, block in ipairs(map.blocks) do
        if block.type == "road" then
            -- Check road length constraint
            if self.max_road_length > 0 then
                -- Simplified check - roads shouldn't be too long
                table.insert(valid_blocks, block)
            end
        else
            table.insert(valid_blocks, block)
        end
    end

    map.blocks = valid_blocks
end

--- Add basic road network to ensure accessibility
-- @param map Map data table
function MapScript:add_basic_road_network(map)
    -- Add a simple cross road
    local center_x = math.floor(map.width / 2)
    local center_y = math.floor(map.height / 2)

    table.insert(map.blocks, {
        type = "road",
        id = "road_intersection",
        x = center_x,
        y = center_y,
        rotation = 0
    })
end

--- Add heating systems for arctic maps
-- @param map Map data table
function MapScript:add_heating_systems(map)
    -- Add heating utilities near buildings
    for _, block in ipairs(map.blocks) do
        if block.type == "building" then
            -- Check if there's already a heating system nearby
            local has_heating = false
            for _, other_block in ipairs(map.blocks) do
                if other_block.type == "utility" and other_block.id == "heating_plant" then
                    local distance = math.sqrt((other_block.x - block.x)^2 + (other_block.y - block.y)^2)
                    if distance < 5 then
                        has_heating = true
                        break
                    end
                end
            end

            if not has_heating then
                table.insert(map.blocks, {
                    type = "utility",
                    id = "heating_plant",
                    x = block.x + 1,
                    y = block.y + 1,
                    rotation = 0
                })
            end
        end
    end
end

--- Get script metadata
-- @return Table with script information
function MapScript:get_metadata()
    return {
        id = self.id,
        name = self.name,
        description = self.description,
        type = self.type,
        base_biome = self.base_biome,
        complexity = self.complexity,
        size_range = self.size_range
    }
end

--- Get generation parameters
-- @return Table with generation settings
function MapScript:get_generation_params()
    return {
        base_biome = self.base_biome,
        size_range = self.size_range,
        complexity = self.complexity,
        building_density = self.building_density,
        road_coverage = self.road_coverage,
        open_space_ratio = self.open_space_ratio
    }
end

return MapScript
