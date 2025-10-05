local CatalogMerger = {}
CatalogMerger.__index = CatalogMerger

local function isArray(tbl)
    local count = 0
    for k in pairs(tbl) do
        if type(k) ~= "number" then
            return false
        end
        count = count + 1
    end
    return #tbl == count
end

local function deepCopy(value)
    if type(value) ~= "table" then
        return value
    end
    local result = {}
    for k, v in pairs(value) do
        result[k] = deepCopy(v)
    end
    return result
end

local function deepMerge(base, overlay)
    local result = deepCopy(base)
    for key, value in pairs(overlay) do
        if type(value) == "table" and type(result[key]) == "table" then
            if isArray(value) then
                result[key] = deepCopy(value)
            else
                result[key] = deepMerge(result[key], value)
            end
        else
            result[key] = deepCopy(value)
        end
    end
    return result
end

function CatalogMerger.merge(dest, source)
    assert(type(dest) == "table" and type(source) == "table", "merge expects tables")
    for catalog, entries in pairs(source) do
        if not dest[catalog] then
            dest[catalog] = deepCopy(entries)
        else
            dest[catalog] = deepMerge(dest[catalog], entries)
        end
    end
    return dest
end

return CatalogMerger
