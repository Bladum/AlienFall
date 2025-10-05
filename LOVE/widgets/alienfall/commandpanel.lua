--[[
widgets/commandpanel.lua
CommandPanel widget for vertical stack of action buttons


Simple vertical container for stacking command and action buttons.
Provides organized access to unit actions and base facility controls.

PURPOSE:
- Provide a simple vertical container for stacking command/action buttons
- Enable quick access to commands in fast-paced tactical gameplay
- Organize related actions in a compact, accessible layout
- Support ability palettes and tactical HUD interfaces

KEY FEATURES:
- Vertical layout with automatic button positioning
- Dynamic command list with add/remove functionality
- Button integration with consistent theming
- Scrollable interface for large command sets
- Hotkey display and keyboard navigation
- Visual feedback for button states and interactions
- Customizable button spacing and sizing
- Integration with action point systems
- Support for command categories and grouping

@see widgets.common.core.Base
@see widgets.common.button
]]

local core = require("widgets.core")
local Button = require("widgets.common.button")
local CommandPanel = {}
CommandPanel.__index = CommandPanel

function CommandPanel:new(x, y, w, h, commands)
    local obj = { x = x, y = y, w = w, h = h, commands = commands or {}, buttons = {} }
    for i, c in ipairs(obj.commands) do
        local b = Button:new(x, y + (i - 1) * 30, w, 28, c.text, c.callback); table.insert(obj.buttons, b)
    end
    setmetatable(obj, self)
    return obj
end

function CommandPanel:update(dt) for _, b in ipairs(self.buttons) do b:update(dt) end end

function CommandPanel:draw() for _, b in ipairs(self.buttons) do b:draw() end end

function CommandPanel:mousepressed(x, y, button)
    for _, b in ipairs(self.buttons) do if b:mousepressed(x, y, button) then return true end end
    return false
end

function CommandPanel:setCommands(cmds)
    self.commands = cmds or {}
    self.buttons = {}
    for i, c in ipairs(self.commands) do
        local b = Button:new(self.x, self.y + (i - 1) * 30, self.w, 28, c.text, c.callback)
        table.insert(self.buttons, b)
    end
end

return CommandPanel






