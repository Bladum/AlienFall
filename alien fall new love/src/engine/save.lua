local SaveService = {}
SaveService.__index = SaveService

local function indent(level)
    return string.rep("    ", level)
end

local function serialize(value, level)
    level = level or 0
    local valueType = type(value)

    if valueType == "number" or valueType == "boolean" then
        return tostring(value)
    elseif valueType == "string" then
        return string.format("%q", value)
    elseif valueType == "table" then
        local parts = {"{"}
        local keys = {}
        for key in pairs(value) do
            table.insert(keys, key)
        end
        table.sort(keys, function(a, b)
            return tostring(a) < tostring(b)
        end)

        for _, key in ipairs(keys) do
            local keyType = type(key)
            if keyType ~= "string" and keyType ~= "number" then
                error("Unsupported key type in save data: " .. keyType)
            end
            local keyRepr
            if keyType == "string" and key:match("^[_%a][_%w]*$") then
                keyRepr = key
            else
                keyRepr = "[" .. serialize(key, level + 1) .. "]"
            end
            local serializedValue = serialize(value[key], level + 1)
            table.insert(parts, string.format("%s%s = %s,", indent(level + 1), keyRepr, serializedValue))
        end
        table.insert(parts, indent(level) .. "}")
        return table.concat(parts, "\n")
    else
        error("Unsupported value type in save data: " .. valueType)
    end
end

function SaveService.new(opts)
    local self = setmetatable({}, SaveService)
    self.telemetry = opts and opts.telemetry or nil
    self.mountPoint = opts and opts.mountPoint or "saves"
    return self
end

function SaveService:_ensureMount()
    if not love or not love.filesystem then
        error("Love filesystem API required for saving")
    end
    if not love.filesystem.getInfo(self.mountPoint, "directory") then
        love.filesystem.createDirectory(self.mountPoint)
    end
end

function SaveService:save(slot, data)
    assert(type(slot) == "string" and slot ~= "", "save slot name required")
    assert(type(data) == "table", "save data must be a table")
    self:_ensureMount()

    local content = "return " .. serialize(data, 0) .. "\n"
    local filename = string.format("%s/%s.lua", self.mountPoint, slot)
    local success, message = love.filesystem.write(filename, content)

    if self.telemetry then
        self.telemetry:recordEvent({
            type = "save",
            slot = slot,
            ok = success,
            error = message
        })
    end

    return success, message
end

function SaveService:load(slot)
    assert(type(slot) == "string" and slot ~= "", "load slot name required")
    self:_ensureMount()

    local filename = string.format("%s/%s.lua", self.mountPoint, slot)
    if not love.filesystem.getInfo(filename, "file") then
        return nil, "no_save"
    end

    local chunk, err = love.filesystem.load(filename)
    if not chunk then
        return nil, err
    end

    local ok, result = pcall(chunk)
    if not ok then
        return nil, result
    end

    return result, nil
end

function SaveService:listSlots()
    self:_ensureMount()
    local items = love.filesystem.getDirectoryItems(self.mountPoint)
    local slots = {}
    for _, item in ipairs(items) do
        local slot = item:gsub("%.lua$", "")
        table.insert(slots, slot)
    end
    table.sort(slots)
    return slots
end

return SaveService
