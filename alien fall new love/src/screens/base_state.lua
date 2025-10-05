local BaseState = {}
BaseState.__index = BaseState

function BaseState.new(opts)
    local self = setmetatable({}, BaseState)
    self.name = opts and opts.name or "unnamed_state"
    self.registry = opts and opts.registry or nil
    self.eventBus = opts and opts.eventBus or nil
    self.logger = opts and opts.logger or nil
    self.payload = nil
    return self
end

function BaseState:enter(payload)
    self.payload = payload or {}
    if self.logger then
        self.logger:debug("enter", self.name)
    end
end

function BaseState:resume(payload)
    if payload then
        self.payload = payload
    end
    if self.logger then
        self.logger:debug("resume", self.name)
    end
end

function BaseState:exit(reason)
    if self.logger then
        self.logger:debug("exit", string.format("%s (%s)", self.name, tostring(reason or "")))
    end
end

function BaseState:suspend()
    if self.logger then
        self.logger:debug("suspend", self.name)
    end
end

function BaseState:update(_) end
function BaseState:draw() end
function BaseState:keypressed(_) end
function BaseState:mousepressed(_, _, _) return false end
function BaseState:mousereleased(_, _, _) return false end
function BaseState:mousemoved(_, _, _, _, _) return false end
function BaseState:wheelmoved(_, _) return false end

return BaseState
