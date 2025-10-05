local TooltipManager = {}
TooltipManager.__index = TooltipManager

local instance

local function new()
  local t = { active = nil, queue = {} }
  setmetatable(t, TooltipManager)
  return t
end

--- Show a tooltip (replaces current)
--- @param content string|table Content or structured content
--- @param x number X position
--- @param y number Y position
function TooltipManager.show(content, x, y)
  instance = instance or new()
  instance.active = { content = content, x = x, y = y }
end

--- Hide the active tooltip
function TooltipManager.hide()
  if instance then instance.active = nil end
end

--- Draw the active tooltip (to be called from a top-level draw loop)
function TooltipManager.draw()
  if not instance or not instance.active then return end
  local t = instance.active
  if not t then return end
  -- Lightweight drawing helper; widgets may override or call their own draw
  if t.content and type(t.content) == "string" and t.x and t.y then
    love.graphics.setColor(0, 0, 0, 0.75)
    love.graphics.rectangle("fill", t.x, t.y, 200, 48)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(t.content, t.x + 6, t.y + 6)
  end
end

return TooltipManager
