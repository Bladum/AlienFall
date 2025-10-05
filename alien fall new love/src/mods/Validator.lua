local Validator = {}
Validator.__index = Validator

local REQUIRED_FIELDS = {
    "id",
    "name",
    "version"
}

function Validator.new(opts)
    local self = setmetatable({}, Validator)
    self.logger = opts and opts.logger or nil
    return self
end

function Validator:validate(manifest)
    if type(manifest) ~= "table" then
        return false, "manifest must be a table"
    end
    for _, field in ipairs(REQUIRED_FIELDS) do
        if manifest[field] == nil then
            return false, "missing field '" .. field .. "'"
        end
    end
    return true
end

return Validator
