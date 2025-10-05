local StateStack = {}
StateStack.__index = StateStack

function StateStack.new(opts)
    local self = setmetatable({}, StateStack)
    self.registry = opts and opts.registry or nil
    self.factories = {}
    self.stack = {}
    self.logger = opts and opts.logger or nil
    return self
end

function StateStack:register(name, factory)
    assert(type(name) == "string" and name ~= "", "State name must be non-empty string")
    assert(type(factory) == "function", "State factory must be a function")
    self.factories[name] = factory
end

function StateStack:hasState(name)
    return self.factories[name] ~= nil
end

function StateStack:_instantiate(name, payload)
    local factory = self.factories[name]
    if not factory then
        error("No state factory registered for " .. name)
    end
    local state = factory(self.registry)
    state.name = name
    state.stack = self
    state:enter(payload or {})
    return state
end

function StateStack:current()
    return self.stack[#self.stack]
end

function StateStack:push(name, payload)
    if self.logger then
        self.logger:info("push", name)
    end
    local current = self:current()
    if current and current.suspend then
        current:suspend()
    end

    local state = self:_instantiate(name, payload)
    table.insert(self.stack, state)
    if state.postEnter then
        state:postEnter(payload)
    end
    return state
end

function StateStack:replace(name, payload)
    self:pop({ replace = true })
    return self:push(name, payload)
end

function StateStack:pop(reason)
    local state = table.remove(self.stack)
    if not state then
        return nil
    end
    if self.logger then
        self.logger:info("pop", state.name)
    end
    if state.exit then
        state:exit(reason)
    end
    local newTop = self:current()
    if newTop and newTop.resume then
        newTop:resume(reason)
    end
    return state
end

function StateStack:clear()
    while #self.stack > 0 do
        self:pop({ shutdown = true })
    end
end

function StateStack:update(dt)
    local state = self:current()
    if state and state.update then
        state:update(dt)
    end
end

function StateStack:draw()
    for idx = 1, #self.stack do
        local state = self.stack[idx]
        if state and state.draw then
            state:draw()
        end
    end
end

local function delegate(self, method, ...)
    local state = self:current()
    if state and state[method] then
        return state[method](state, ...)
    end
    return nil
end

function StateStack:mousepressed(x, y, button)
    return delegate(self, "mousepressed", x, y, button)
end

function StateStack:mousereleased(x, y, button)
    return delegate(self, "mousereleased", x, y, button)
end

function StateStack:mousemoved(x, y, dx, dy, istouch)
    return delegate(self, "mousemoved", x, y, dx, dy, istouch)
end

function StateStack:wheelmoved(x, y)
    return delegate(self, "wheelmoved", x, y)
end

function StateStack:keypressed(key, scancode, isrepeat)
    return delegate(self, "keypressed", key, scancode, isrepeat)
end

return StateStack
