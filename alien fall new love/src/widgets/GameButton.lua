-- Button widget with fancy features and icon support (updated v3)
local class = require("lib.middleclass")

--- @class GameButton
--- A customizable button widget with animation effects, icon support, and hover states.
--- Supports scaling animations, glow effects, and optional image icons.
local GameButton = class('GameButton')

--- Creates a new GameButton instance.
--- @param x number The x-coordinate of the button
--- @param y number The y-coordinate of the button
--- @param width number The width of the button
--- @param height number The height of the button
--- @param text string The text to display on the button
--- @param callback function The callback function to execute when clicked
--- @param imagePath string Optional path to an image file for the button icon
--- @return GameButton A new GameButton instance
function GameButton:initialize(x, y, width, height, text, callback, imagePath)
    -- Position and size
    self.x = x
    self.y = y
    self.width = width
    self.height = height

    -- Text
    self.text = text
    self.font = love.graphics.newFont(14) -- Slightly smaller for buttons with images
    self.textColor = {1, 1, 1, 1}

    -- Image (optional icon)
    self.imagePath = imagePath
    self.image = nil
    self.imageScale = 1

    if imagePath then
        local success, img = pcall(love.graphics.newImage, imagePath)
        if success then
            self.image = img
            -- Scale image to fit nicely (24x24 pixels)
            self.imageScale = 24 / math.max(self.image:getWidth(), self.image:getHeight())
        else
            print("Warning: Could not load image '" .. imagePath .. "': " .. tostring(img))
        end
    end

    -- Colors
    self.normalColor = {0.3, 0.3, 0.3, 1}
    self.hoverColor = {0.5, 0.5, 0.5, 1}
    self.clickColor = {0.7, 0.7, 0.7, 1}
    self.borderColor = {0.8, 0.8, 0.8, 1}
    self.currentColor = self.normalColor

    -- Animation
    self.animation = {
        scale = 1,
        targetScale = 1,
        scaleSpeed = 5,
        glow = 0,
        targetGlow = 0,
        glowSpeed = 3
    }

    -- State
    self.hovered = false
    self.clicked = false
    self.enabled = true
    self.visible = true

    -- Callback
    self.callback = callback

    -- Border
    self.borderWidth = 2
    self.borderRadius = 8

    -- Shadow
    self.shadowOffset = 3
    self.shadowColor = {0, 0, 0, 0.3}
end

--- Updates the button state and animations based on mouse position and time.
--- Handles hover detection, animation smoothing, and color interpolation.
--- @param dt number Delta time since last update
function GameButton:update(dt)
    if not self.enabled or not self.visible then return end

    -- Get mouse position (already converted to internal coordinates)
    local mouseX, mouseY = mouseX, mouseY

    -- Check hover
    local wasHovered = self.hovered
    self.hovered = mouseX >= self.x and mouseX <= self.x + self.width and
                   mouseY >= self.y and mouseY <= self.y + self.height

    -- Animation updates
    if self.hovered and not wasHovered then
        self.animation.targetScale = 1.05
        self.animation.targetGlow = 0.5
    elseif not self.hovered and wasHovered then
        self.animation.targetScale = 1.0
        self.animation.targetGlow = 0.0
    end

    -- Smooth scale animation
    self.animation.scale = self.animation.scale + (self.animation.targetScale - self.animation.scale) * self.animation.scaleSpeed * dt

    -- Smooth glow animation
    self.animation.glow = self.animation.glow + (self.animation.targetGlow - self.animation.glow) * self.animation.glowSpeed * dt

    -- Color interpolation
    if self.clicked then
        self.currentColor = self.clickColor
    elseif self.hovered then
        self.currentColor = self.hoverColor
    else
        self.currentColor = self.normalColor
    end
end

--- Draws the button with all visual effects including shadow, glow, and animations.
--- Handles both text-only and image+text button layouts.
function GameButton:draw()
    if not self.visible then return end

    love.graphics.push()

    -- Apply scaling for animation effects
    love.graphics.scale(self.animation.scale, self.animation.scale)

    -- Adjust position for scaling
    local drawX = self.x / self.animation.scale
    local drawY = self.y / self.animation.scale
    local drawWidth = self.width / self.animation.scale
    local drawHeight = self.height / self.animation.scale

    -- Draw shadow
    love.graphics.setColor(self.shadowColor)
    love.graphics.rectangle("fill",
        drawX + self.shadowOffset,
        drawY + self.shadowOffset,
        drawWidth, drawHeight,
        self.borderRadius, self.borderRadius)

    -- Draw button background
    love.graphics.setColor(self.currentColor)
    love.graphics.rectangle("fill", drawX, drawY, drawWidth, drawHeight, self.borderRadius, self.borderRadius)

    -- Draw glow effect
    if self.animation.glow > 0 then
        love.graphics.setColor(1, 1, 1, self.animation.glow)
        love.graphics.rectangle("fill", drawX - 2, drawY - 2, drawWidth + 4, drawHeight + 4, self.borderRadius + 2, self.borderRadius + 2)
    end

    -- Draw border
    love.graphics.setColor(self.borderColor)
    love.graphics.setLineWidth(self.borderWidth)
    love.graphics.rectangle("line", drawX, drawY, drawWidth, drawHeight, self.borderRadius, self.borderRadius)

    -- Draw text and image
    love.graphics.setColor(self.textColor)

    if self.image then
        -- Draw image above text
        love.graphics.setColor(1, 1, 1, 1) -- Reset color for image
        local imageWidth = self.image:getWidth() * self.imageScale
        local imageHeight = self.image:getHeight() * self.imageScale
        local imageX = drawX + (drawWidth - imageWidth) / 2
        local imageY = drawY + (drawHeight - imageHeight - self.font:getHeight()) / 2
        love.graphics.draw(self.image, imageX, imageY, 0, self.imageScale, self.imageScale)

        -- Draw text below image
        love.graphics.setColor(self.textColor)
        love.graphics.setFont(self.font)
        local textWidth = self.font:getWidth(self.text)
        local textX = drawX + (drawWidth - textWidth) / 2
        local textY = imageY + imageHeight + 2
        love.graphics.print(self.text, textX, textY)
    else
        -- Draw text only (original behavior)
        love.graphics.setFont(self.font)
        local textWidth = self.font:getWidth(self.text)
        local textHeight = self.font:getHeight()
        local textX = drawX + (drawWidth - textWidth) / 2
        local textY = drawY + (drawHeight - textHeight) / 2
        love.graphics.print(self.text, textX, textY)
    end

    love.graphics.pop()
end

--- Handles mouse press events for button interaction.
--- @param x number Mouse x-coordinate
--- @param y number Mouse y-coordinate
--- @param button number Mouse button number (1 = left click)
--- @return boolean True if the button was clicked, false otherwise
function GameButton:mousepressed(x, y, button)
    if not self.enabled or not self.visible or button ~= 1 then return false end

    if x >= self.x and x <= self.x + self.width and y >= self.y and y <= self.y + self.height then
        self.clicked = true
        self.animation.targetScale = 0.95
        return true
    end
    return false
end

--- Handles mouse release events and triggers callback if button was clicked.
--- @param x number Mouse x-coordinate
--- @param y number Mouse y-coordinate
--- @param button number Mouse button number (1 = left click)
--- @return boolean True if the callback was executed, false otherwise
function GameButton:mousereleased(x, y, button)
    if not self.enabled or not self.visible or button ~= 1 or not self.clicked then return false end

    self.clicked = false
    self.animation.targetScale = self.hovered and 1.05 or 1.0

    if x >= self.x and x <= self.x + self.width and y >= self.y and y <= self.y + self.height then
        if self.callback then
            self.callback()
        end
        return true
    end
    return false
end

--- Sets the text displayed on the button.
--- @param text string The new text to display
function GameButton:setText(text)
    self.text = text
end

--- Sets the position of the button.
--- @param x number New x-coordinate
--- @param y number New y-coordinate
function GameButton:setPosition(x, y)
    self.x = x
    self.y = y
end

--- Sets the size of the button.
--- @param width number New width
--- @param height number New height
function GameButton:setSize(width, height)
    self.width = width
    self.height = height
end

--- Sets the color scheme for different button states.
--- @param normal table RGBA color table for normal state
--- @param hover table RGBA color table for hover state
--- @param click table RGBA color table for click state
function GameButton:setColors(normal, hover, click)
    if normal then self.normalColor = normal end
    if hover then self.hoverColor = hover end
    if click then self.clickColor = click end
end

--- Enables or disables the button interaction.
--- @param enabled boolean Whether the button should be enabled
function GameButton:setEnabled(enabled)
    self.enabled = enabled
    if not enabled then
        self.currentColor = {0.5, 0.5, 0.5, 0.5}
    end
end

--- Sets the visibility of the button.
--- @param visible boolean Whether the button should be visible
function GameButton:setVisible(visible)
    self.visible = visible
end

return GameButton
