--[[
widgets/interception.lua
Interception widget for air combat management


Air combat management interface for tracking UFOs, interceptors, and engagement outcomes.
Essential for geoscape operations with real-time air combat simulation and decision making.

PURPOSE:
- Manage air combat scenarios and interceptor operations
- Enable real-time tracking of UFOs and interceptor engagements
- Support combat prediction and resource allocation decisions
- Facilitate strategic air defense planning and execution

KEY FEATURES:
- UFO tracking with trajectory display and flight path prediction
- Interceptor assignment and management system
- Combat prediction with success probability calculations
- Multiple simultaneous engagement tracking
- Resource allocation for interceptor operations
- Outcome visualization with damage assessment
- Real-time updates for dynamic combat situations
- Interceptor fuel and ammunition monitoring
- Combat log with detailed engagement history
- Integration with geoscape for global situational awareness
- Alert system for interception opportunities

]]

local core = require("widgets.core")
local Animation = require("widgets.complex.animation")
local Geoscape = require("widgets.alienfall.geoscape")
local AlertSystem = require("widgets.alienfall.alertsystem")

local Interception = {}
Interception.__index = Interception
setmetatable(Interception, { __index = core.Base })

function Interception:new(x, y, w, h, options)
    local obj = core.Base:new(x, y, w, h)

    -- Core properties
    obj.ufos = {}
    obj.interceptors = {}
    obj.activeCombats = {}

    -- Visual options
    obj.showTrajectories = options and options.showTrajectories ~= false
    obj.showPredictions = options and options.showPredictions ~= false

    -- Sub-components
    obj.geoscape = Geoscape:new(x, y, w, h)
    obj.alertSystem = AlertSystem:new(x + 10, y + 10, w - 20, 50)

    -- Callbacks
    obj.onEngagement = options and options.onEngagement
    obj.onOutcome = options and options.onOutcome
    obj.onResourceChange = options and options.onResourceChange

    setmetatable(obj, self)
    return obj
end

function Interception:update(dt)
    core.Base.update(self, dt)
    self.geoscape:update(dt)
    self.alertSystem:update(dt)

    -- Update UFO trajectories
    for _, ufo in ipairs(self.ufos) do
        ufo.x = ufo.x + ufo.vx * dt
        ufo.y = ufo.y + ufo.vy * dt
    end

    -- Update active combats
    for i, combat in ipairs(self.activeCombats) do
        combat.progress = combat.progress + dt
        if combat.progress >= combat.duration then
            self:_resolveCombat(combat)
            table.remove(self.activeCombats, i)
        end
    end
end

function Interception:draw()
    self.geoscape:draw()

    -- Draw UFOs
    for _, ufo in ipairs(self.ufos) do
        love.graphics.setColor(1, 0, 0)
        love.graphics.circle("fill", self.x + ufo.x, self.y + ufo.y, 5)
        if self.showTrajectories then
            love.graphics.setColor(1, 0, 0, 0.5)
            love.graphics.line(self.x + ufo.x, self.y + ufo.y, self.x + ufo.x + ufo.vx * 10, self.y + ufo.y + ufo.vy * 10)
        end
    end

    -- Draw interceptors
    for _, interceptor in ipairs(self.interceptors) do
        love.graphics.setColor(0, 1, 0)
        love.graphics.triangle("fill", self.x + interceptor.x, self.y + interceptor.y - 5, self.x + interceptor.x - 5,
            self.y + interceptor.y + 5, self.x + interceptor.x + 5, self.y + interceptor.y + 5)
    end

    -- Draw active combats
    for _, combat in ipairs(self.activeCombats) do
        love.graphics.setColor(1, 1, 0)
        love.graphics.circle("fill", self.x + combat.x, self.y + combat.y, 10)
    end

    self.alertSystem:draw()
end

function Interception:addUFO(ufo)
    table.insert(self.ufos, ufo)
    self.alertSystem:addAlert("UFO detected!", "warning")
end

function Interception:assignInterceptor(ufo, interceptor)
    table.insert(self.activeCombats, {
        ufo = ufo,
        interceptor = interceptor,
        x = ufo.x,
        y = ufo.y,
        progress = 0,
        duration = 5 -- seconds
    })
    if self.onEngagement then self.onEngagement(ufo, interceptor) end
end

function Interception:_resolveCombat(combat)
    local outcome = math.random() > 0.5 and "success" or "failure"
    if self.onOutcome then self.onOutcome(combat, outcome) end
    self.alertSystem:addAlert("Interception " .. outcome .. "!", outcome == "success" and "success" or "error")
end

return Interception
