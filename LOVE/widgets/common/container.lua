local core = require("widgets.core")

--- @class Container
--- @field x number
--- @field y number
--- @field w number
--- @field h number
--- @field children table
--- @field contentX number
--- @field contentY number
--- @field contentW number
--- @field contentH number
local Container = {}
Container.__index = Container
setmetatable(Container, { __index = core.Base })

--- Creates a new Container instance (subclass of core.Base)
--- @param x number The x-coordinate position
--- @param y number The y-coordinate position
--- @param w number The width of the container
--- @param h number The height of the container
--- @param options table Optional configuration table
--- @return Container A new container instance
function Container:new(x, y, w, h, options)
  local obj = core.Base:new(x, y, w, h, options)
  obj.children = obj.children or {}
  setmetatable(obj, self)
  return obj
end

--- Adds a child widget to the container
--- @param child table The child widget to add
function Container:add(child)
  table.insert(self.children, child)
  child.parent = self
  if child.updatePosition then
    child:updatePosition(self.contentX or self.x, self.contentY or self.y, self.w, self.h)
  end
end

--- Removes a child widget from the container
--- @param child table The child widget to remove
function Container:remove(child)
  for i, c in ipairs(self.children) do
    if c == child then
      table.remove(self.children, i)
      if c.parent then c.parent = nil end
      break
    end
  end
end

--- Update all child widgets
--- @param dt number Delta time
function Container:update(dt)
  for _, child in ipairs(self.children) do
    if child.update then child:update(dt) end
  end
end

--- Draw all child widgets (does not set transforms)
function Container:drawChildren()
  for _, child in ipairs(self.children) do
    if child.draw then child:draw() end
  end
end

--- Forward a mouse event to children; translates coordinates and returns true when handled
--- @param method string The child method name to call ("mousepressed", "mousereleased", etc.)
--- @param x number Global x coordinate
--- @param y number Global y coordinate
--- @param ... any Additional args to pass
--- @return boolean True if a child handled the event
function Container:forwardMouseEvent(method, x, y, ...)
  for _, child in ipairs(self.children) do
    if child.hitTest then
      local relX = x - (child.x or 0)
      local relY = y - (child.y or 0)
      if child.hitTest(child, relX, relY) then
        if child[method] then
          if child[method](child, relX, relY, ...) then return true end
        end
      end
    else
      -- fallback: use isInside with absolute coords
      if core.isInside(x, y, child.x or 0, child.y or 0, child.w or 0, child.h or 0) then
        if child[method] then
          if child[method](child, x - (child.x or 0), y - (child.y or 0), ...) then return true end
        end
      end
    end
  end
  return false
end

return Container
