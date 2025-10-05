--- ActionMenu class for displaying and selecting unit actions in battlescape.
-- @classmod battlescape.ActionMenu
-- @field actions table Array of available actions
-- @field cursor number Currently selected action index
-- @field onActionSelected function Callback when an action is selected

local ActionMenu = {}
ActionMenu.__index = ActionMenu

--- Creates a new ActionMenu instance.
-- @param opts table Configuration options
-- @param opts.onActionSelected function Callback for action selection
-- @return ActionMenu A new ActionMenu instance
function ActionMenu.new(opts)
    local self = setmetatable({}, ActionMenu)
    self.actions = {}
    self.cursor = 1
    self.onActionSelected = opts and opts.onActionSelected or function(_) end
    return self
end

--- Sets the available actions for the menu.
-- @param actions table Array of action objects with label and other properties
function ActionMenu:setActions(actions)
    self.actions = actions or {}
    self.cursor = 1
end

--- Draws the action menu at the specified position.
-- @param x number X coordinate for the menu
-- @param y number Y coordinate for the menu
function ActionMenu:draw(x, y)
    love.graphics.setColor(0.12, 0.12, 0.12, 1)
    love.graphics.rectangle("fill", x, y, 220, 200)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Actions", x + 12, y + 10)

    for index, action in ipairs(self.actions) do
        local prefix = (index == self.cursor) and "> " or "  "
        love.graphics.print(prefix .. action.label, x + 12, y + 36 + (index - 1) * 24)
    end
end

function ActionMenu:keypressed(key)
    if #self.actions == 0 then
        return
    end
    if key == "up" then
        self.cursor = (self.cursor - 2) % #self.actions + 1
    elseif key == "down" then
        self.cursor = self.cursor % #self.actions + 1
    elseif key == "return" or key == "space" then
        local action = self.actions[self.cursor]
        if action then
            self.onActionSelected(action)
        end
    end
end

return ActionMenu
