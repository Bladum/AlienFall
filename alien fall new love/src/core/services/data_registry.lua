local DataRegistry = {}
DataRegistry.__index = DataRegistry

function DataRegistry.new(opts)
    local self = setmetatable({}, DataRegistry)
    self.catalogs = {}
    self.logger = opts and opts.logger or nil
    self.telemetry = opts and opts.telemetry or nil
    return self
end

local function ensureCatalog(self, catalog)
    if not self.catalogs[catalog] then
        self.catalogs[catalog] = {}
    end
    return self.catalogs[catalog]
end

function DataRegistry:registerCatalog(catalog, entries, source)
    assert(type(catalog) == "string" and catalog ~= "", "catalog name required")
    assert(type(entries) == "table", "catalog entries table required")

    local bucket = ensureCatalog(self, catalog)
    local count = 0
    for key, entry in pairs(entries) do
        if type(entry) == "table" then
            entry.source_mod = source
        end
        bucket[key] = entry
        count = count + 1
    end

    if self.logger then
        self.logger:debug(string.format("Registered %d entries for catalog '%s'", count, catalog))
    end
end

function DataRegistry:getCatalog(catalog)
    local bucket = self.catalogs[catalog]
    if not bucket then
        return {}
    end
    return bucket
end

function DataRegistry:get(catalog, key)
    local bucket = self.catalogs[catalog]
    if not bucket then return nil end
    return bucket[key]
end

function DataRegistry:listCatalogs()
    local names = {}
    for name in pairs(self.catalogs) do
        table.insert(names, name)
    end
    table.sort(names)
    return names
end

function DataRegistry:clear()
    self.catalogs = {}
end

return DataRegistry
