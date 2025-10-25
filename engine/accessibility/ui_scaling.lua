---UI Scaling - Dynamic UI scaling for accessibility
---
---Provides UI scaling functionality to make UI elements larger or smaller
---based on user preferences for visibility.
---
---@module ui_scaling
---@author AlienFall Development Team
---@license Open Source

local UIScaling = {}
UIScaling.__index = UIScaling

function UIScaling.new()
    local self = setmetatable({}, UIScaling)

    self.currentScale = 1.0
    self.minScale = 0.75
    self.maxScale = 2.0

    print("[UIScaling] UI scaling initialized at 1.0x")
    return self
end

---Set UI scale factor
---
---@param scale number Scale factor (1.0 = normal)
function UIScaling:setScale(scale)
    if scale >= self.minScale and scale <= self.maxScale then
        self.currentScale = scale
        print("[UIScaling] UI scale set to: " .. scale .. "x")
    else
        print("[UIScaling] ERROR: Scale out of range (" .. self.minScale .. "-" .. self.maxScale .. ")")
    end
end

---Get current scale factor
---
---@return number Current scale
function UIScaling:getScale()
    return self.currentScale
end

---Scale a dimension
---
---@param value number Original value
---@return number Scaled value
function UIScaling:scaleValue(value)
    return value * self.currentScale
end

return UIScaling
