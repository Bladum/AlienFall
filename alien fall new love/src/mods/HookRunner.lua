local HookRunner = {}
HookRunner.__index = HookRunner

function HookRunner.new(opts)
    local self = setmetatable({}, HookRunner)
    self.logger = opts and opts.logger or nil
    return self
end

function HookRunner:run(mod, hookName, context)
    if not mod.hooks then
        return
    end
    local hook = mod.hooks[hookName]
    if type(hook) ~= "function" then
        return
    end

    local ok, err = pcall(hook, context)
    if not ok and self.logger then
        self.logger:error("Mod hook failed: " .. tostring(err), mod.id or "unknown")
    end
end

return HookRunner
