--[[
    Custom Widget Example
    Demonstrates creating a UI widget with proper grid alignment and Love2D patterns
    
    Key Concepts:
    - 20×20 pixel grid system
    - Widget base class inheritance
    - Event handling
    - Deterministic behavior
    - Love2D drawing
]]

local Object = require("lib.classic")  -- Or your OOP library
local Widget = Object:extend()

-- Grid constants (ALWAYS use these for positioning)
local GRID_SIZE = 20

--[[
    Constructor
    @param grid_x: X position in grid units (will be multiplied by GRID_SIZE)
    @param grid_y: Y position in grid units
    @param grid_width: Width in grid units
    @param grid_height: Height in grid units
]]
function Widget:new(grid_x, grid_y, grid_width, grid_height)
    -- Convert grid coordinates to pixel coordinates
    self.x = grid_x * GRID_SIZE
    self.y = grid_y * GRID_SIZE
    self.width = grid_width * GRID_SIZE
    self.height = grid_height * GRID_SIZE
    
    -- Grid coordinates (for reference)
    self.grid_x = grid_x
    self.grid_y = grid_y
    self.grid_width = grid_width
    self.grid_height = grid_height
    
    -- Widget state
    self.visible = true
    self.enabled = true
    self.hovered = false
    self.pressed = false
    
    -- Colors (example)
    self.color_normal = {0.2, 0.3, 0.4, 1.0}
    self.color_hover = {0.3, 0.4, 0.5, 1.0}
    self.color_pressed = {0.4, 0.5, 0.6, 1.0}
    self.color_disabled = {0.1, 0.1, 0.1, 0.5}
    
    -- Event callbacks
    self.onClick = nil
    self.onHover = nil
    self.onLeave = nil
end

--[[
    Update widget state
    @param dt: Delta time in seconds (Love2D standard)
]]
function Widget:update(dt)
    if not self.enabled then
        self.hovered = false
        self.pressed = false
        return
    end
    
    -- Get mouse position (already converted to 800×600 space by main.lua)
    local mx, my = love.mouse.getPosition()
    
    -- Check if mouse is over widget
    local was_hovered = self.hovered
    self.hovered = mx >= self.x and mx < self.x + self.width and
                   my >= self.y and my < self.y + self.height
    
    -- Fire hover events
    if self.hovered and not was_hovered then
        if self.onHover then
            self.onHover(self)
        end
    elseif not self.hovered and was_hovered then
        if self.onLeave then
            self.onLeave(self)
        end
    end
end

--[[
    Draw the widget
    Called every frame by Love2D's love.draw()
]]
function Widget:draw()
    if not self.visible then return end
    
    -- Determine color based on state
    local color
    if not self.enabled then
        color = self.color_disabled
    elseif self.pressed then
        color = self.color_pressed
    elseif self.hovered then
        color = self.color_hover
    else
        color = self.color_normal
    end
    
    -- Draw widget background (simple rectangle)
    love.graphics.setColor(color)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    
    -- Draw border (1 pixel, aligned to edge)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", self.x + 0.5, self.y + 0.5, self.width - 1, self.height - 1)
    
    -- Reset color for next draw call
    love.graphics.setColor(1, 1, 1, 1)
end

--[[
    Handle mouse press events
    Called by Love2D's love.mousepressed callback
    @param mx, my: Mouse position in pixels
    @param button: Mouse button (1=left, 2=right, 3=middle)
]]
function Widget:mousepressed(mx, my, button)
    if not self.visible or not self.enabled then return false end
    
    -- Check if click is inside widget bounds
    if mx >= self.x and mx < self.x + self.width and
       my >= self.y and my < self.y + self.height then
        
        if button == 1 then  -- Left click
            self.pressed = true
            return true  -- Event consumed
        end
    end
    
    return false  -- Event not consumed
end

--[[
    Handle mouse release events
    Called by Love2D's love.mousereleased callback
]]
function Widget:mousereleased(mx, my, button)
    if not self.visible or not self.enabled then return false end
    
    local was_pressed = self.pressed
    self.pressed = false
    
    -- Check if release is inside widget (complete click)
    if was_pressed and button == 1 then
        if mx >= self.x and mx < self.x + self.width and
           my >= self.y and my < self.y + self.height then
            
            -- Fire click event
            if self.onClick then
                self.onClick(self)
            end
            
            return true  -- Event consumed
        end
    end
    
    return false
end

--[[
    Set widget position (in grid units)
]]
function Widget:setPosition(grid_x, grid_y)
    self.grid_x = grid_x
    self.grid_y = grid_y
    self.x = grid_x * GRID_SIZE
    self.y = grid_y * GRID_SIZE
end

--[[
    Set widget size (in grid units)
]]
function Widget:setSize(grid_width, grid_height)
    self.grid_width = grid_width
    self.grid_height = grid_height
    self.width = grid_width * GRID_SIZE
    self.height = grid_height * GRID_SIZE
end

--[[
    Get bounds for collision detection
]]
function Widget:getBounds()
    return self.x, self.y, self.width, self.height
end

--[[
    Check if point is inside widget
]]
function Widget:containsPoint(px, py)
    return px >= self.x and px < self.x + self.width and
           py >= self.y and py < self.y + self.height
end


--[[
    Example Usage:
    
    -- Create a button at grid position (5, 3) with size (10, 2)
    local button = Widget(5, 3, 10, 2)
    
    -- Set up click handler
    button.onClick = function(self)
        print("Button clicked!")
    end
    
    -- In love.update(dt)
    button:update(dt)
    
    -- In love.draw()
    button:draw()
    
    -- In love.mousepressed(x, y, button)
    if button:mousepressed(x, y, button) then
        return  -- Event consumed
    end
    
    -- In love.mousereleased(x, y, button)
    if button:mousereleased(x, y, button) then
        return  -- Event consumed
    end
]]

return Widget
