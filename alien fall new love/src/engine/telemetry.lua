local Telemetry = {}
Telemetry.__index = Telemetry

function Telemetry.new(opts)
    local self = setmetatable({}, Telemetry)
    self.enabled = opts and opts.enabled ~= false
    self.historyLimit = opts and opts.historyLimit or 512
    self.records = {}
    return self
end

function Telemetry:isEnabled()
    return self.enabled
end

function Telemetry:setEnabled(value)
    self.enabled = value and true or false
end

function Telemetry:recordEvent(entry)
    if not self.enabled then
        return
    end
    assert(type(entry) == "table", "telemetry entry must be a table")
    entry.timestamp = love and love.timer and love.timer.getTime and love.timer.getTime() or os.clock()
    table.insert(self.records, entry)
    if #self.records > self.historyLimit then
        table.remove(self.records, 1)
    end
end

function Telemetry:drain()
    local snapshot = self.records
    self.records = {}
    return snapshot
end

return Telemetry
