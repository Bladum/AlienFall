--- Data Catalog
--
-- Centralized repository for all loaded game data.
-- Provides efficient lookup, filtering, and management of game content.
--
-- GROK: This is the single source of truth for all game data after mods are loaded.
-- All game systems should query this catalog rather than loading files directly.
--
-- @module engine.data_catalog
-- @usage local DataCatalog = require "engine.data_catalog"
--        local catalog = DataCatalog.new()
--        catalog:register("units", unitData)

local DataCatalog = {}
DataCatalog.__index = DataCatalog

--- Creates a new DataCatalog instance
-- @param config table: Configuration options
-- @param config.logger Logger: Logger service
-- @param config.telemetry Telemetry: Telemetry service
-- @return DataCatalog: New catalog instance
function DataCatalog.new(config)
    local self = setmetatable({}, DataCatalog)
    config = config or {}
    
    self.logger = config.logger
    self.telemetry = config.telemetry
    
    -- Initialize category storage
    self.categories = {
        units = {},           -- Unit class definitions
        items = {},           -- Item definitions
        missions = {},        -- Mission templates
        facilities = {},      -- Facility definitions
        research = {},        -- Research projects
        manufacturing = {},   -- Manufacturing recipes
        suppliers = {},       -- Supplier definitions
        factions = {},        -- Faction data
        races = {},           -- Race definitions
        biomes = {},          -- Biome definitions
        regions = {},         -- Region data
        provinces = {},       -- Province data
        countries = {},       -- Country data
        campaigns = {},       -- Campaign definitions
        events = {},          -- Story events
        quests = {},          -- Quest definitions
        terrains = {},        -- Terrain types
        map_blocks = {},      -- Map block definitions
        tilesets = {}         -- Tileset definitions
    }
    
    -- Index for fast lookups
    self.index = {}
    
    if self.logger then
        self.logger:info("DataCatalog initialized")
    end
    
    return self
end

--- Register data in a category
-- @param category string: Category name (e.g., "units", "items")
-- @param data table: Data to register (map of id -> definition)
-- @return boolean: Success
-- @return string: Error message if failed
function DataCatalog:register(category, data)
    if not self.categories[category] then
        local err = "Unknown category: " .. tostring(category)
        if self.logger then
            self.logger:error("DataCatalog: " .. err)
        end
        return false, err
    end
    
    -- Merge data into category
    for id, definition in pairs(data) do
        self.categories[category][id] = definition
        
        -- Update index
        self.index[id] = {
            category = category,
            definition = definition
        }
    end
    
    if self.telemetry then
        self.telemetry:increment("data_catalog.registrations")
    end
    
    if self.logger then
        local count = 0
        for _ in pairs(data) do count = count + 1 end
        self.logger:debug(string.format("DataCatalog: Registered %d items in category '%s'", count, category))
    end
    
    return true
end

--- Get data by ID (searches all categories)
-- @param id string: Item ID
-- @return table: Item definition or nil
-- @return string: Category name if found
function DataCatalog:get(id)
    local entry = self.index[id]
    if entry then
        return entry.definition, entry.category
    end
    return nil, nil
end

--- Get data from specific category by ID
-- @param category string: Category name
-- @param id string: Item ID
-- @return table: Item definition or nil
function DataCatalog:getFromCategory(category, id)
    if not self.categories[category] then
        return nil
    end
    return self.categories[category][id]
end

--- Get all data from a category
-- @param category string: Category name
-- @return table: Map of id -> definition, or nil if category doesn't exist
function DataCatalog:getCategory(category)
    return self.categories[category]
end

--- Filter category by predicate function
-- @param category string: Category name
-- @param predicate function: Function(id, definition) -> boolean
-- @return table: Filtered map of id -> definition
function DataCatalog:filter(category, predicate)
    local results = {}
    local categoryData = self.categories[category]
    
    if not categoryData then
        return results
    end
    
    for id, definition in pairs(categoryData) do
        if predicate(id, definition) then
            results[id] = definition
        end
    end
    
    return results
end

--- Check if item exists
-- @param id string: Item ID
-- @return boolean: True if exists
function DataCatalog:exists(id)
    return self.index[id] ~= nil
end

--- Get count of items in category
-- @param category string: Category name
-- @return number: Count of items
function DataCatalog:count(category)
    if not self.categories[category] then
        return 0
    end
    
    local count = 0
    for _ in pairs(self.categories[category]) do
        count = count + 1
    end
    return count
end

--- Clear all data
function DataCatalog:clear()
    for category, _ in pairs(self.categories) do
        self.categories[category] = {}
    end
    self.index = {}
    
    if self.logger then
        self.logger:info("DataCatalog cleared")
    end
    
    if self.telemetry then
        self.telemetry:increment("data_catalog.clears")
    end
end

--- Clear specific category
-- @param category string: Category name
function DataCatalog:clearCategory(category)
    if self.categories[category] then
        -- Remove from index
        for id, _ in pairs(self.categories[category]) do
            self.index[id] = nil
        end
        
        -- Clear category
        self.categories[category] = {}
        
        if self.logger then
            self.logger:debug("DataCatalog: Cleared category '" .. category .. "'")
        end
    end
end

--- Get catalog statistics
-- @return table: Statistics about catalog contents
function DataCatalog:getStats()
    local stats = {
        total_items = 0,
        categories = {}
    }
    
    for category, data in pairs(self.categories) do
        local count = 0
        for _ in pairs(data) do
            count = count + 1
        end
        stats.categories[category] = count
        stats.total_items = stats.total_items + count
    end
    
    return stats
end

--- List all categories
-- @return table: Array of category names
function DataCatalog:listCategories()
    local names = {}
    for name, _ in pairs(self.categories) do
        table.insert(names, name)
    end
    table.sort(names)
    return names
end

--- Validate all items in a category against a schema
-- @param category string: Category name
-- @param validator table: Schema validator instance
-- @param schemaName string: Schema name
-- @return boolean: True if all valid
-- @return table: Map of id -> error for invalid items
function DataCatalog:validateCategory(category, validator, schemaName)
    local categoryData = self.categories[category]
    if not categoryData then
        return false, {["_error"] = "Category does not exist: " .. category}
    end
    
    return validator.validateCollection(categoryData, schemaName)
end

return DataCatalog
