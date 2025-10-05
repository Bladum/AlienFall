local CatalogMerger = require "mods.CatalogMerger"
local HookRunner = require "mods.HookRunner"
local Validator = require "mods.Validator"
local ContentDetector = require "mods.ContentDetector"
local DirectoryScanner = require "mods.DirectoryScanner"

local ModLoader = {}
ModLoader.__index = ModLoader

local BUILTIN_CORE = {
    id = "core",
    name = "AlienFall Core",
    version = "0.1.0",
    description = "Built-in core ruleset",
    priority = 0,  -- Core should always load first
    catalogs = {
        missions = {
            tutorial = {
                id = "tutorial",
                label = "Training Skirmish",
                map = "testing_ground",
                objective = "Eliminate all enemies"
            }
        },
        facilities = {
            command_center = {
                id = "command_center",
                label = "Command Center",
                size = { width = 2, height = 2 },
                buildCost = 500000,
                buildDays = 25
            }
        }
    },
    hooks = {
        init = function(context)
            if context.logger then
                context.logger:info("Core mod initialized", "core")
            end
        end
    }
}

local function safeLoad(path)
    local chunk, err = love.filesystem.load(path)
    if not chunk then
        return nil, err
    end
    local ok, result = pcall(chunk)
    if not ok then
        return nil, result
    end
    return result
end

--- Convert TOML manifest to internal manifest format
-- @param tomlData table: Parsed TOML data from main.toml
-- @param modDir string: Mod directory path
-- @param modId string: Mod ID (directory name)
-- @return table: Internal manifest format
function ModLoader:convertTomlManifest(tomlData, modDir, modId)
    -- Handle both formats: [mod] section or direct at root
    local modSection = tomlData.mod or tomlData
    
    local manifest = {
        id = modSection.id or modId,
        name = modSection.name or modId,
        version = modSection.version or "1.0.0",
        author = modSection.author or "Unknown",
        description = modSection.description or "",
        path = modDir,
        source = "toml",
        
        -- Priority system (default: 100, higher = loads later = overrides earlier mods)
        priority = modSection.priority or 100,

        -- Dependencies (convert from TOML format)
        dependencies = {},
        hooks = {}
    }

    -- Convert dependencies
    if tomlData.dependencies then
        for key, value in pairs(tomlData.dependencies) do
            if key == "required_mods" and type(value) == "table" then
                for _, dep in ipairs(value) do
                    table.insert(manifest.dependencies, dep)
                end
            end
        end
    end

    -- Auto-discover content instead of using explicit content section
    manifest.tomlContent = self:discoverTomlContent(modDir)

    return manifest
end

--- Discover TOML content in a mod directory
-- @param modDir string: Mod directory path
-- @return table: Map of content_type -> array of file paths
function ModLoader:discoverTomlContent(modDir)
    -- Scan for all TOML files in the mod directory
    local tomlFiles = self.directoryScanner:scanForTomlFiles(modDir, {"scripts", "locale"})

    -- Filter by content type
    local categorized = self.directoryScanner:filterByContentType(tomlFiles, modDir, self.contentDetector)

    if self.logger then
        self.logger:info(string.format("Discovered content in mod %s:", modDir))
        for contentType, files in pairs(categorized) do
            self.logger:info(string.format("  %s: %d files", contentType, #files))
        end
    end

    return categorized
end

--- Load TOML content for a mod
-- @param manifest table: Mod manifest
-- @param catalogAccumulator table: Accumulator for merged catalogs
function ModLoader:loadTomlContent(manifest, catalogAccumulator)
    if not manifest.tomlContent then
        return
    end

    for contentType, filePaths in pairs(manifest.tomlContent) do
        local catalogData = {}

        for _, filePath in ipairs(filePaths) do
            local fullPath = manifest.path .. "/" .. filePath
            local data, err = self.directoryScanner:loadTomlFile(fullPath)

            if data then
                -- Merge the data into the catalog
                -- For most content types, the data structure matches the catalog name
                if data[contentType] then
                    if not catalogData[contentType] then
                        catalogData[contentType] = {}
                    end
                    -- Merge arrays
                    for _, item in ipairs(data[contentType]) do
                        table.insert(catalogData[contentType], item)
                    end
                else
                    -- Some files might have the data at root level
                    if type(data) == "table" and #data > 0 then
                        if not catalogData[contentType] then
                            catalogData[contentType] = {}
                        end
                        for _, item in ipairs(data) do
                            table.insert(catalogData[contentType], item)
                        end
                    end
                end

                if self.logger then
                    self.logger:debug(string.format("Loaded %s from %s", contentType, filePath))
                end
            else
                if self.logger then
                    self.logger:error(string.format("Failed to load %s: %s", fullPath, err))
                end
            end
        end

        -- Register the catalog if we have data
        if next(catalogData) and self.dataRegistry then
            for catalog, entries in pairs(catalogData) do
                CatalogMerger.merge(catalogAccumulator, { [catalog] = entries })
                self.dataRegistry:registerCatalog(catalog, entries, manifest.id)
            end
        end
    end
end

function ModLoader.new(opts)
    local self = setmetatable({}, ModLoader)
    self.logger = opts and opts.logger or nil
    self.telemetry = opts and opts.telemetry or nil
    self.dataRegistry = opts and opts.dataRegistry or nil
    self.root = opts and opts.root or "mods"
    self.validator = Validator.new({ logger = self.logger })
    self.hookRunner = HookRunner.new({ logger = self.logger })
    self.contentDetector = ContentDetector.new({ logger = self.logger })
    self.directoryScanner = DirectoryScanner.new({ logger = self.logger })
    self.activeMods = {}
    return self
end

function ModLoader:discover()
    local discovered = {
        BUILTIN_CORE
    }

    if not love or not love.filesystem then
        return discovered
    end

    if not love.filesystem.getInfo(self.root, "directory") then
        return discovered
    end

    local items = love.filesystem.getDirectoryItems(self.root)
    for _, item in ipairs(items) do
        local modDir = self.root .. "/" .. item

        -- Check for Lua manifest first
        local manifestPath = modDir .. "/mod.lua"
        if love.filesystem.getInfo(manifestPath, "file") then
            local manifest, err = safeLoad(manifestPath)
            if manifest then
                manifest.id = manifest.id or item
                manifest.path = modDir
                local ok, message = self.validator:validate(manifest)
                if ok then
                    table.insert(discovered, manifest)
                elseif self.logger then
                    self.logger:warn(string.format("Mod '%s' invalid: %s", item, message))
                end
            elseif self.logger then
                self.logger:error(string.format("Failed to load mod manifest '%s': %s", manifestPath, err))
            end
        else
            -- Check for TOML main.toml
            local tomlPath = modDir .. "/main.toml"
            if love.filesystem.getInfo(tomlPath, "file") then
                local TomlLoader = require "core.util.toml_loader"
                local manifest, err = TomlLoader.load(tomlPath)
                if manifest then
                    -- Convert TOML manifest to internal format
                    local internalManifest = self:convertTomlManifest(manifest, modDir, item)
                    local ok, message = self.validator:validate(internalManifest)
                    if ok then
                        table.insert(discovered, internalManifest)
                    elseif self.logger then
                        self.logger:warn(string.format("Mod '%s' invalid: %s", item, message))
                    end
                elseif self.logger then
                    self.logger:error(string.format("Failed to load mod main.toml '%s': %s", tomlPath, err))
                end
            end
        end
    end

    -- Sort by priority (lower priority loads first, higher priority overrides)
    table.sort(discovered, function(a, b)
        local priorityA = a.priority or 100
        local priorityB = b.priority or 100
        
        if priorityA == priorityB then
            -- Secondary sort by ID for stable ordering
            return a.id < b.id
        end
        
        return priorityA < priorityB
    end)

    return discovered
end

function ModLoader:detectConflicts(mods)
    local conflicts = {}
    local contentMap = {}  -- Track which mods define which content
    
    for _, mod in ipairs(mods) do
        -- Check TOML content
        if mod.tomlContent then
            for contentType, files in pairs(mod.tomlContent) do
                if not contentMap[contentType] then
                    contentMap[contentType] = {}
                end
                
                for _, file in ipairs(files) do
                    -- Extract IDs from file (simplified - would need actual parsing)
                    if not contentMap[contentType][file] then
                        contentMap[contentType][file] = {}
                    end
                    table.insert(contentMap[contentType][file], mod.id)
                end
            end
        end
        
        -- Check catalog content
        if mod.catalogs then
            for catalog, entries in pairs(mod.catalogs) do
                if not contentMap[catalog] then
                    contentMap[catalog] = {}
                end
                
                for entryId, _ in pairs(entries) do
                    if not contentMap[catalog][entryId] then
                        contentMap[catalog][entryId] = {}
                    end
                    table.insert(contentMap[catalog][entryId], mod.id)
                end
            end
        end
    end
    
    -- Find conflicts (multiple mods defining same content)
    for contentType, items in pairs(contentMap) do
        for itemId, modIds in pairs(items) do
            if #modIds > 1 then
                table.insert(conflicts, {
                    type = contentType,
                    id = itemId,
                    mods = modIds
                })
            end
        end
    end
    
    return conflicts
end

function ModLoader:loadModset(modSet)
    local catalogAccumulator = {}
    local discovered = self:discover()
    local byId = {}
    for _, manifest in ipairs(discovered) do
        byId[manifest.id] = manifest
    end

    local order = {}
    if modSet and #modSet > 0 then
        for _, id in ipairs(modSet) do
            if byId[id] then
                table.insert(order, byId[id])
            elseif self.logger then
                self.logger:warn("Unknown mod requested: " .. id)
            end
        end
    else
        table.insert(order, byId["core"] or BUILTIN_CORE)
    end
    
    -- Ensure priority-based sorting
    table.sort(order, function(a, b)
        local priorityA = a.priority or 100
        local priorityB = b.priority or 100
        
        if priorityA == priorityB then
            return a.id < b.id
        end
        
        return priorityA < priorityB
    end)
    
    -- Detect and report conflicts
    local conflicts = self:detectConflicts(order)
    if #conflicts > 0 and self.logger then
        self.logger:warn(string.format("Detected %d content conflicts:", #conflicts))
        for _, conflict in ipairs(conflicts) do
            self.logger:warn(string.format("  %s '%s' defined by: %s", 
                conflict.type, conflict.id, table.concat(conflict.mods, ", ")))
            self.logger:warn(string.format("    → Using version from '%s' (highest priority)", 
                conflict.mods[#conflict.mods]))
        end
    end

    if self.dataRegistry then
        self.dataRegistry:clear()
    end

    for _, manifest in ipairs(order) do
        -- Handle TOML-based mods with auto-discovered content
        if manifest.source == "toml" and manifest.tomlContent and self.dataRegistry then
            self:loadTomlContent(manifest, catalogAccumulator)
        -- Handle Lua-based mods with explicit catalogs
        elseif manifest.catalogs and self.dataRegistry then
            for catalog, entries in pairs(manifest.catalogs) do
                CatalogMerger.merge(catalogAccumulator, {
                    [catalog] = entries
                })
                self.dataRegistry:registerCatalog(catalog, entries, manifest.id)
            end
        end

        self.hookRunner:run(manifest, "init", {
            mod = manifest,
            logger = self.logger,
            telemetry = self.telemetry,
            dataRegistry = self.dataRegistry
        })
    end

    self.activeMods = order

    if self.telemetry then
        local ids = {}
        for _, manifest in ipairs(order) do
            table.insert(ids, manifest.id)
        end
        self.telemetry:recordEvent({
            type = "mods-loaded",
            mods = ids
        })
    end

    return self.activeMods
end

function ModLoader:getActiveMods()
    return self.activeMods
end

function ModLoader:getModLoadOrder()
    local order = {}
    for _, mod in ipairs(self.activeMods) do
        table.insert(order, {
            id = mod.id,
            name = mod.name,
            version = mod.version,
            priority = mod.priority or 100
        })
    end
    return order
end

function ModLoader:printModLoadOrder()
    if not self.logger then
        return
    end
    
    self.logger:info("=== Mod Load Order (by priority) ===")
    for i, mod in ipairs(self.activeMods) do
        local priority = mod.priority or 100
        self.logger:info(string.format("%d. [%d] %s (%s) - %s", 
            i, priority, mod.name, mod.id, mod.version))
    end
    self.logger:info("====================================")
end

return ModLoader
