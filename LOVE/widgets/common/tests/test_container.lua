local Container = require("widgets.common.container")

local c = Container:new(0, 0, 200, 200)

local childCalled = {}
local child = {
  x = 10,
  y = 10,
  w = 50,
  h = 20,
  update = function(self, dt) childCalled.update = true end,
  draw = function(self) childCalled.draw = true end,
  hitTest = function(self, rx, ry) return rx >= 0 and ry >= 0 and rx <= self.w and ry <= self.h end,
  mousepressed = function(self, x, y, b)
    childCalled.mousepressed = { x = x, y = y, b = b }; return true
  end
}

c:add(child)
-- simulate update
c:update(0.016)
-- simulate draw (we can't run love.graphics here, but make sure drawChildren doesn't error)
local ok, err = pcall(function() c:drawChildren() end)
print("drawChildren ok", ok, err)

-- test forwarding
local handled = c:forwardMouseEvent("mousepressed", 15, 15, 1)
print("mouse event handled", handled)
print("childCalled mousepressed", childCalled.mousepressed and true or false)

return childCalled
