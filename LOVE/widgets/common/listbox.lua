--[[
widgets/listbox.lua
ListBox widget (scrollable list with selection)


Basic listbox widget providing scrollable item lists with selection support for tactical
strategy game interfaces. Suitable for soldier rosters, research queues, mission briefings,
and item inventories in OpenXCOM-style games.

PURPOSE:
- Display scrollable lists of items with selection capability
- Provide basic navigation and interaction for item lists
- Support callback system for selection changes
- Foundation for more advanced list implementations

KEY FEATURES:
- Scrollable item display with offset management
- Single item selection with visual highlighting
- Mouse click selection
- Callback system for selection events
- Configurable item height and layout
- Basic keyboard navigation support
- Lightweight implementation for simple lists

@see widgets.common.core.Base
@see widgets.common.scrollbar
@see widgets.common.combobox
@see widgets.complex.treeview
]]

local core = require("widgets.core")
local ListBox = {}
ListBox.__index = ListBox

function ListBox:new(x, y, w, h, items, callback)
  local obj = {
    x = x,
    y = y,
    w = w,
    h = h,
    items = items or {},
    selected = nil,
    offset = 0,
    itemHeight = 20,
    callback =
        callback
  }
  setmetatable(obj, self)
  return obj
end

function ListBox:update(dt) end

function ListBox:draw()
  love.graphics.setColor(unpack(core.theme.background))
  love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
  love.graphics.setColor(unpack(core.theme.border))
  love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
  local visible = math.floor(self.h / self.itemHeight)
  for i = 1, visible do
    local idx = i + self.offset
    if idx > #self.items then break end
    local itemY = self.y + (i - 1) * self.itemHeight
    if idx == self.selected then
      love.graphics.setColor(unpack(core.theme.selection)); love.graphics.rectangle("fill", self.x + 1, itemY + 1,
        self.w - 2, self.itemHeight - 2)
    end
    love.graphics.setColor(unpack(core.theme.text))
    love.graphics.print(tostring(self.items[idx]), self.x + 4, itemY + 4)
  end
end

function ListBox:mousepressed(x, y, button)
  if button ~= 1 then return false end
  if not core.isInside(x, y, self.x, self.y, self.w, self.h) then return false end
  local relative = y - self.y
  local i = math.floor(relative / self.itemHeight) + 1
  local idx = i + self.offset
  if idx <= #self.items then
    self.selected = idx; if self.callback then self.callback(idx, self.items[idx]) end
  end
  return true
end

return ListBox
