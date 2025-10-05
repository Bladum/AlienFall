--- Content Type Detector for Mod System
-- Automatically detects the type of content in TOML files based on their structure
--
-- @module systems.mod_system.content_detector

local ContentDetector = {}
ContentDetector.__index = ContentDetector

--- Content type patterns
-- Maps content types to their identifying characteristics
local CONTENT_PATTERNS = {
    -- Research projects
    research = {
        array_keys = {"research"},
        table_keys = {},
        priority = 1
    },

    -- Research entries (individual research projects)
    research_entry = {
        array_keys = {"research_entry"},
        table_keys = {},
        priority = 1
    },

    -- Manufacturing recipes
    recipes = {
        array_keys = {"recipes"},
        table_keys = {},
        priority = 1
    },

    -- Manufacturing entries (production recipes)
    manufacturing_entry = {
        array_keys = {"manufacturing_entry"},
        table_keys = {},
        priority = 1
    },

    -- Unit class templates (unit templates with basic stats)
    unit_class = {
        array_keys = {"unit_class"},
        table_keys = {},
        priority = 1
    },

    -- Craft class templates (craft templates with basic stats)
    craft_class = {
        array_keys = {"craft_class"},
        table_keys = {},
        priority = 1
    },

    -- Base items (generic items)
    items = {
        array_keys = {"items"},
        table_keys = {},
        priority = 1
    },

    -- Unit-specific items (equipment used by units)
    item_unit = {
        array_keys = {"item_unit"},
        table_keys = {},
        priority = 2  -- Higher priority than generic items
    },

    -- Craft-specific items (equipment used by crafts)
    item_craft = {
        array_keys = {"item_craft"},
        table_keys = {},
        priority = 2  -- Higher priority than generic items
    },

    -- Lore items (story/campaign items)
    item_lore = {
        array_keys = {"item_lore"},
        table_keys = {},
        priority = 2  -- Higher priority than generic items
    },

    -- Resource items (materials, currency, etc.)
    item_resource = {
        array_keys = {"item_resource"},
        table_keys = {},
        priority = 2  -- Higher priority than generic items
    },

    -- Facilities
    facilities = {
        array_keys = {"facilities"},
        table_keys = {},
        priority = 1
    },

    -- Missions
    missions = {
        array_keys = {"missions"},
        table_keys = {},
        priority = 1
    },

    -- UFO missions (intercept and shoot down UFOs)
    mission_ufo = {
        array_keys = {"mission_ufo"},
        table_keys = {},
        priority = 2  -- Higher priority than generic missions
    },

    -- Site missions (ground missions at crash sites, terror sites, etc.)
    mission_site = {
        array_keys = {"mission_site"},
        table_keys = {},
        priority = 2  -- Higher priority than generic missions
    },

    -- Alien base missions (assault missions on alien bases)
    mission_alien_base = {
        array_keys = {"mission_alien_base"},
        table_keys = {},
        priority = 2  -- Higher priority than generic missions
    },

    -- World/geography data
    world = {
        table_keys = {"world"},
        array_keys = {"world.regions", "world.provinces", "world.connections"},
        priority = 1
    },

    -- Regions (hierarchical groupings of provinces)
    regions = {
        array_keys = {"regions"},
        table_keys = {},
        priority = 1
    },

    -- Provinces (atomic spatial anchors)
    provinces = {
        array_keys = {"provinces"},
        table_keys = {},
        priority = 1
    },

    -- Countries (political/economic regions)
    countries = {
        array_keys = {"countries"},
        table_keys = {},
        priority = 1
    },

    -- Factions (narrative adversaries)
    factions = {
        array_keys = {"factions"},
        table_keys = {},
        priority = 1
    },

    -- Campaigns (narrative mission sequences)
    campaigns = {
        array_keys = {"campaigns"},
        table_keys = {},
        priority = 1
    },

    -- UI configuration
    ui_config = {
        table_keys = {"ui", "menus", "screens"},
        array_keys = {},
        priority = 1
    },

    -- Asset definitions
    assets = {
        table_keys = {"assets"},
        array_keys = {"assets.textures", "assets.sounds", "assets.fonts"},
        priority = 1
    },

    -- Events
    events = {
        array_keys = {"events"},
        table_keys = {},
        priority = 1
    },

    -- Logging configuration
    logging = {
        table_keys = {"logging"},
        array_keys = {},
        priority = 1
    },

    -- Save/load configuration
    save_config = {
        table_keys = {"save", "load"},
        array_keys = {},
        priority = 1
    },

    -- Localization data
    localization = {
        -- Localization files are typically in locale/ directory
        -- and have language-specific content
        table_keys = {},
        array_keys = {},
        priority = 3,
        directory_pattern = "locale"
    },

    -- Base services
    base_services = {
        array_keys = {"base_services"},
        table_keys = {},
        priority = 1
    },

    -- Races (unit categories)
    races = {
        array_keys = {"races"},
        table_keys = {},
        priority = 1
    },

    -- Biomes (environmental types)
    biomes = {
        array_keys = {"biomes"},
        table_keys = {},
        priority = 1
    },

    -- Terrains (ground types)
    terrains = {
        array_keys = {"terrains"},
        table_keys = {},
        priority = 1
    },

    -- Map blocks (structural elements)
    map_blocks = {
        array_keys = {"map_blocks"},
        table_keys = {},
        priority = 1
    },

    -- Map scripts (generation templates)
    map_script = {
        array_keys = {"map_script"},
        table_keys = {},
        priority = 1
    },

    -- Unit levels (character progression)
    unit_levels = {
        array_keys = {"unit_levels"},
        table_keys = {},
        priority = 1
    },

    -- Craft levels (vehicle progression)
    craft_levels = {
        array_keys = {"craft_levels"},
        table_keys = {},
        priority = 1
    },

    -- Purchase entries (marketplace items)
    purchase_entries = {
        array_keys = {"purchase_entries"},
        table_keys = {},
        priority = 1
    },

    -- Suppliers (marketplace vendors)
    suppliers = {
        array_keys = {"suppliers"},
        table_keys = {},
        priority = 1
    },

    -- Marketplace (item listings and pricing)
    marketplace = {
        table_keys = {"settings", "items"},
        array_keys = {},
        priority = 1
    },

    -- Transfers (transport capacity and cost configuration)
    transfers = {
        table_keys = {"settings", "capacities", "priorities", "volumes"},
        array_keys = {},
        priority = 1
    },

    -- Prisoner items (captured units and related items)
    item_prisoner = {
        array_keys = {"item_prisoner"},
        table_keys = {},
        priority = 2  -- Higher priority than generic items
    },

    -- Calendar system
    calendar = {
        table_keys = {"calendar"},
        array_keys = {"calendar.events", "calendar.seasons"},
        priority = 1
    },

    -- Universe structure
    universe = {
        table_keys = {"universe"},
        array_keys = {"universe.galaxies", "universe.sectors", "universe.systems"},
        priority = 1
    },

    -- Portal systems
    portals = {
        array_keys = {"portals"},
        table_keys = {},
        priority = 1
    },

    -- Unit traits (special abilities and characteristics)
    traits = {
        array_keys = {"traits"},
        table_keys = {},
        priority = 1
    },

    -- Unit transformations (permanent modifications)
    transformations = {
        array_keys = {"transformations"},
        table_keys = {},
        priority = 1
    },

    -- Unit sizes (physical dimensions and modifiers)
    sizes = {
        array_keys = {"sizes"},
        table_keys = {},
        priority = 1
    },

    -- Unit medals (achievements and decorations)
    medals = {
        array_keys = {"medals"},
        table_keys = {},
        priority = 1
    }
}

--- Create a new content detector
-- @param opts table: Options (logger, etc.)
-- @return table: ContentDetector instance
function ContentDetector.new(opts)
    local self = setmetatable({}, ContentDetector)
    self.logger = opts and opts.logger or nil
    return self
end

--- Detect the content type of a TOML file
-- @param data table: Parsed TOML data
-- @param filePath string: Path to the file (for additional context)
-- @return string|nil: Content type, or nil if not recognized
-- @return number: Confidence score (higher is better)
function ContentDetector:detect(data, filePath)
    if not data or type(data) ~= "table" then
        return nil, 0
    end

    local candidates = {}

    -- Check directory-based patterns first
    if filePath then
        local dirPattern = self:getDirectoryPattern(filePath)
        if dirPattern and CONTENT_PATTERNS[dirPattern] then
            return dirPattern, CONTENT_PATTERNS[dirPattern].priority
        end
    end

    -- Check content patterns
    for contentType, pattern in pairs(CONTENT_PATTERNS) do
        local score = self:calculateMatchScore(data, pattern)
        if score > 0 then
            table.insert(candidates, {type = contentType, score = score})
        end
    end

    -- Sort by score (highest first)
    table.sort(candidates, function(a, b) return a.score > b.score end)

    if #candidates > 0 then
        local best = candidates[1]
        return best.type, best.score
    end

    return nil, 0
end

--- Calculate how well the data matches a content pattern
-- @param data table: Parsed TOML data
-- @param pattern table: Content pattern to match against
-- @return number: Match score (0 = no match, higher = better match)
function ContentDetector:calculateMatchScore(data, pattern)
    local score = 0

    -- Check for required table keys
    for _, key in ipairs(pattern.table_keys or {}) do
        if self:hasNestedKey(data, key) then
            score = score + 10
        end
    end

    -- Check for array keys
    for _, key in ipairs(pattern.array_keys or {}) do
        if self:hasNestedKey(data, key) then
            score = score + 15  -- Arrays are stronger indicators
        end
    end

    -- Bonus for having the primary identifier
    if pattern.primary_key and data[pattern.primary_key] then
        score = score + 20
    end

    return score
end

--- Check if a nested key exists in the data table
-- @param data table: Data table to check
-- @param keyPath string: Dot-separated key path (e.g., "research_tree.entries")
-- @return boolean: True if the key path exists
function ContentDetector:hasNestedKey(data, keyPath)
    local current = data
    for part in keyPath:gmatch("[^.]+") do
        if type(current) ~= "table" or current[part] == nil then
            return false
        end
        current = current[part]
    end
    return true
end

--- Get directory-based pattern for a file path
-- @param filePath string: File path
-- @return string|nil: Content type based on directory, or nil
function ContentDetector:getDirectoryPattern(filePath)
    -- Convert backslashes to forward slashes for consistency
    filePath = filePath:gsub("\\", "/")

    -- Check for locale directory
    if filePath:match("/locale/") then
        return "localization"
    end

    -- Could add more directory-based patterns here
    return nil
end

--- Get all supported content types
-- @return table: Array of content type names
function ContentDetector:getSupportedTypes()
    local types = {}
    for typeName, _ in pairs(CONTENT_PATTERNS) do
        table.insert(types, typeName)
    end
    table.sort(types)
    return types
end

return ContentDetector
