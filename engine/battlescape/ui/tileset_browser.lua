-- Tileset Browser Widget
-- Phase 5: Map Editor Enhancement
-- Browse and select tilesets for map editing

local BaseWidget = require("widgets.core.base")
local Theme = require("widgets.core.theme")
local Widgets = require("widgets")

---@class TilesetBrowser
---@field tilesets table Array of tileset objects
---@field selectedIndex number? Currently selected tileset index
---@field scrollOffset number Vertical scroll position
---@field onTilesetSelected function? Callback when tileset is selected
---@field isPointInside fun(self, x: number, y: number): boolean Check if point is inside widget
---@field handleScroll fun(self, delta: number) Handle scroll wheel input

local TilesetBrowser = setmetatable({}, {__index = BaseWidget})
TilesetBrowser.__index = TilesetBrowser

---Create new Tileset Browser
---@param x number X position (will snap to grid)
---@param y number Y position (will snap to grid)
---@param width number Width (will snap to grid)
---@param height number Height (will snap to grid)
---@param tilesets table Array of tileset objects
---@return TilesetBrowser
function TilesetBrowser.new(x, y, width, height, tilesets)
    local self = BaseWidget.new(x, y, width, height)
    setmetatable(self, TilesetBrowser)
    
    self.tilesets = tilesets or {}
    self.selectedIndex = nil
    self.scrollOffset = 0
    self.itemHeight = 48 -- 2 grid cells
    self.onSelect = nil -- Callback function(tilesetId)
    
    return self
end

---Set tilesets list
---@param tilesets table Array of tileset objects
function TilesetBrowser:setTilesets(tilesets)
    self.tilesets = tilesets
    self.selectedIndex = nil
    self.scrollOffset = 0
end

---Handle mouse click
---@param mouseX number Mouse X
---@param mouseY number Mouse Y
---@param button number Mouse button
---@return boolean handled
function TilesetBrowser:handleClick(mouseX, mouseY, button)
    if not self:isPointInside(mouseX, mouseY) then
        return false
    end
    
    if button == 1 then -- Left click
        local relativeY = mouseY - self.y
        local index = math.floor((relativeY + self.scrollOffset) / self.itemHeight) + 1
        
        if index >= 1 and index <= #self.tilesets then
            self.selectedIndex = index
            
            if self.onSelect then
                local tileset = self.tilesets[index]
                self.onSelect(tileset.id)
            end
            
            return true
        end
    end
    
    return false
end

---Handle mouse wheel scroll
---@param dy number Scroll delta
function TilesetBrowser:handleScroll(dy)
    self.scrollOffset = math.max(0, self.scrollOffset - dy * 24)
    
    -- Clamp to content height
    local contentHeight = #self.tilesets * self.itemHeight
    local maxScroll = math.max(0, contentHeight - self.height)
    self.scrollOffset = math.min(self.scrollOffset, maxScroll)
end

---Draw the widget
function TilesetBrowser:draw()
    if not self.visible then return end
    
    love.graphics.push()
    
    -- Draw background
    love.graphics.setColor(Theme.colors.background.r, Theme.colors.background.g, 
                          Theme.colors.background.b, Theme.colors.background.a)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    
    -- Draw border
    love.graphics.setColor(Theme.colors.border.r, Theme.colors.border.g,
                          Theme.colors.border.b, Theme.colors.border.a)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    
    -- Set scissor for scrolling
    love.graphics.setScissor(self.x, self.y, self.width, self.height)
    
    -- Draw tileset items
    local y = self.y - self.scrollOffset
    
    for i, tileset in ipairs(self.tilesets) do
        local isSelected = (i == self.selectedIndex)
        
        -- Draw item background
        if isSelected then
            love.graphics.setColor(Theme.colors.primary.r, Theme.colors.primary.g,
                                  Theme.colors.primary.b, 0.3)
            love.graphics.rectangle("fill", self.x + 4, y + 2, self.width - 8, self.itemHeight - 4)
        end
        
        -- Draw tileset name
        love.graphics.setColor(Theme.colors.text.r, Theme.colors.text.g,
                              Theme.colors.text.b, Theme.colors.text.a)
        love.graphics.setFont(Theme.fonts.default)
        love.graphics.print(tileset.id or "Unknown", self.x + 8, y + 8)
        
        -- Draw tile count
        local tileCount = 0
        if tileset.tiles then
            for _ in pairs(tileset.tiles) do
                tileCount = tileCount + 1
            end
        end
        love.graphics.setColor(Theme.colors.textSecondary.r, Theme.colors.textSecondary.g,
                              Theme.colors.textSecondary.b, Theme.colors.textSecondary.a)
        love.graphics.setFont(Theme.fonts.small)
        love.graphics.print(string.format("%d tiles", tileCount), self.x + 8, y + 26)
        
        y = y + self.itemHeight
    end
    
    love.graphics.setScissor()
    love.graphics.pop()
end

---Check if point is inside widget
---@param x number Mouse X coordinate
---@param y number Mouse Y coordinate
---@return boolean
function TilesetBrowser:isPointInside(x, y)
    return self:containsPoint(x, y)
end

---Handle scroll wheel input
---@param delta number Scroll delta (positive = scroll up, negative = scroll down)
function TilesetBrowser:handleScroll(delta)
    self.scrollOffset = self.scrollOffset - delta * 20 -- 20 pixels per scroll step
    -- Clamp scroll offset
    local maxScroll = math.max(0, #self.tilesets * self.itemHeight - self.height)
    self.scrollOffset = math.max(0, math.min(self.scrollOffset, maxScroll))
end

return TilesetBrowser
