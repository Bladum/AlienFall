local core = require("widgets.core")

local Interactive = {}

--- Attach interactive helpers to a widget
--- @param widget table The widget to attach to
function Interactive.init(widget)
  widget._interactive = widget._interactive or { hovered = false, pressed = false, focused = false }

  --- Set accessibility label/hint convenience
  --- @param label string|nil
  --- @param hint string|nil
  function widget:_setAccessibility(label, hint)
    self.accessibilityLabel = label or self.accessibilityLabel
    self.accessibilityHint = hint or self.accessibilityHint
  end

  --- Update hovered state from mouse position
  --- @param mx number
  --- @param my number
  function widget:_updateHover(mx, my)
    local inside = core.isInside(mx, my, self.x or 0, self.y or 0, self.w or 0, self.h or 0)
    self._interactive.hovered = inside
    return inside
  end

  function widget:isHovered()
    return self._interactive.hovered
  end

  function widget:isPressed()
    return self._interactive.pressed
  end

  --- Show tooltip when hovered (call from update)
  function widget:_showTooltipWhenHovered()
    if self._interactive.hovered and self.tooltip and core.setTooltipWidget then
      core.setTooltipWidget(self)
    end
  end

  --- Default helper for mousepressed; widgets can call/override
  --- @param x number
  --- @param y number
  --- @param button number
  function widget:_mousepressed(x, y, button)
    if button ~= 1 then return false end
    if core.isInside(x, y, self.x or 0, self.y or 0, self.w or 0, self.h or 0) then
      self._interactive.pressed = true
      return true
    end
    return false
  end

  --- Default helper for mousereleased; widgets can call/override
  --- @param x number
  --- @param y number
  --- @param button number
  function widget:_mousereleased(x, y, button)
    if button ~= 1 then return false end
    local handled = false
    if self._interactive.pressed and core.isInside(x, y, self.x or 0, self.y or 0, self.w or 0, self.h or 0) then
      if type(self.callback) == "function" then pcall(self.callback, self) end
      handled = true
    end
    self._interactive.pressed = false
    return handled
  end
end

return Interactive
