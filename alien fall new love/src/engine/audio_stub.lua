local AudioStub = {}
AudioStub.__index = AudioStub

function AudioStub.new()
    local self = setmetatable({}, AudioStub)
    self.enabled = false
    return self
end

function AudioStub:play(_) end
function AudioStub:stop(_) end
function AudioStub:update(_) end

return AudioStub
