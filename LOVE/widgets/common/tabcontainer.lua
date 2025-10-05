--[[
widgets/tabcontainer.lua
TabContainer widget for managing multiple content panels with tab navigation.


Container widget that manages multiple content panels accessible via tab headers.
Handles layout, activation, content switching, and accessibility for tabbed interfaces.

PURPOSE:
- Manage multiple content panels with intuitive tab-based navigation
- Provide organized access to different sections of interface content
- Support dynamic tab creation and content management
- Enable efficient use of screen space through tabbed organization

KEY FEATURES:
- Tab header buttons for navigation between content panels
- Dynamic tab addition and removal
- Content panel layout and resizing management
- Active tab indication and visual feedback
- Keyboard navigation support for accessibility
- Customizable tab appearance and behavior
- Content persistence during tab switching
- Event callbacks for tab changes

@see widgets.common.core.Base
@see widgets.common.button
@see widgets.common.panel
]]

local core = require("widgets.core")
local Button = require("widgets.common.button")
local TabContainer = {}
TabContainer.__index = TabContainer

--- Creates a new TabContainer widget instance
--- @param x number The x-coordinate position
--- @param y number The y-coordinate position
--- @param w number The width of the tab container
--- @param h number The height of the tab container
--- @param options table Optional configuration table
--- @return TabContainer A new tab container widget instance
function TabContainer:new(x, y, w, h, options)
    options = options or {}
    local obj = core.Base:new(x, y, w, h, options)

    obj.tabs = {}
    obj.activeTab = nil
    obj.tabHeight = options.tabHeight or 30
    obj.contentY = y + obj.tabHeight + 5
    obj.contentHeight = h - obj.tabHeight - 5
    obj.tabButtons = {}

    obj.accessibilityLabel = obj.accessibilityLabel or "Tab container"
    obj.accessibilityHint = obj.accessibilityHint or "Use tab buttons to switch between content panels"

    setmetatable(obj, self)
    return obj
end

--- Adds a new tab to the tab container
--- @param title string The title text for the tab
--- @param content any The content to display when the tab is active
--- @param options table Optional configuration table with closable, onActivate, onClose fields
function TabContainer:addTab(title, content, options)
    options = options or {}
    local tab = {
        title = title,
        content = content,
        closable = options.closable or false,
        onActivate = options.onActivate,
        onClose = options.onClose
    }

    table.insert(self.tabs, tab)

    -- Create tab button
    local tabIndex = #self.tabs
    local buttonX = self.x + (tabIndex - 1) * 100
    local tabButton = Button:new(buttonX, self.y, 95, self.tabHeight, title, function()
        self:setActiveTab(tabIndex)
    end, {
        accessibilityLabel = "Tab: " .. title,
        accessibilityHint = "Press to show " .. title .. " content"
    })

    table.insert(self.tabButtons, tabButton)
    self:addChild(tabButton)

    -- Set as active if first tab
    if #self.tabs == 1 then
        self:setActiveTab(1)
    end

    return tab
end

--- Sets the active tab by index
--- @param index number The index of the tab to activate (1-based)
function TabContainer:setActiveTab(index)
    if index < 1 or index > #self.tabs then return end

    self.activeTab = index
    local tab = self.tabs[index]

    -- Update button states
    for i, button in ipairs(self.tabButtons) do
        button.colors.normal = (i == index) and core.theme.accent or core.theme.secondary
    end

    -- Position content
    if tab.content then
        tab.content.x = self.x + 5
        tab.content.y = self.contentY
        tab.content.w = self.w - 10
        tab.content.h = self.contentHeight
    end

    -- Call activation callback
    if tab.onActivate then
        tab.onActivate(tab)
    end

    if core.config.enableAccessibility then
        core.announce("Switched to tab: " .. tab.title)
    end
end

--- Updates the tab container and its contents
--- @param dt number The time delta since the last update
function TabContainer:update(dt)
    core.Base.update(self, dt)

    -- Update all children
    for _, child in ipairs(self.children) do
        if child.update then
            child:update(dt)
        end
    end

    -- Update active tab content
    if self.activeTab and self.tabs[self.activeTab] and self.tabs[self.activeTab].content then
        local content = self.tabs[self.activeTab].content
        if content.update then
            content:update(dt)
        end
    end
end

--- Draws the tab container and its contents
function TabContainer:draw()
    core.Base.draw(self)

    -- Draw tab bar background
    love.graphics.setColor(unpack(core.theme.secondary))
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.tabHeight)

    -- Draw content area background
    love.graphics.setColor(unpack(core.theme.background))
    love.graphics.rectangle("fill", self.x, self.contentY - 2, self.w, self.contentHeight + 2)
    love.graphics.setColor(unpack(core.theme.border))
    love.graphics.rectangle("line", self.x, self.contentY - 2, self.w, self.contentHeight + 2)

    -- Draw all children (tab buttons)
    for _, child in ipairs(self.children) do
        if child.draw then
            child:draw()
        end
    end

    -- Draw active tab content
    if self.activeTab and self.tabs[self.activeTab] and self.tabs[self.activeTab].content then
        local content = self.tabs[self.activeTab].content
        if content.draw then
            content:draw()
        end
    end
end

--- Handles key press events for the tab container
--- @param key string The key that was pressed
--- @return boolean True if the key was handled, false otherwise
function TabContainer:keypressed(key)
    if not self.focused then return core.Base.keypressed(self, key) end

    -- Handle tab switching with Ctrl+Tab
    if key == "tab" and love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl") then
        local direction = love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") and -1 or 1
        local nextTab = self.activeTab + direction
        if nextTab < 1 then nextTab = #self.tabs end
        if nextTab > #self.tabs then nextTab = 1 end
        self:setActiveTab(nextTab)
        return true
    end

    return core.Base.keypressed(self, key)
end

--- Serializes the tab container state for saving
--- @return table A table containing the serialized tab container data
function TabContainer:serialize()
    local tabsData = {}
    for i, tab in ipairs(self.tabs) do
        tabsData[i] = {
            title = tab.title,
            closable = tab.closable,
            -- Note: content serialization would need to be handled by the content widget
            contentType = tab.content and tab.content.__index or nil
        }
    end

    return {
        tabs = tabsData,
        activeTab = self.activeTab,
        tabHeight = self.tabHeight
    }
end

--- Deserializes and restores the tab container state from saved data
--- @param data table The serialized data to restore from
function TabContainer:deserialize(data)
    self.tabs = {}
    self.tabButtons = {}
    self.children = {}

    for i, tabData in ipairs(data.tabs or {}) do
        -- Reconstruct tabs (content would need to be recreated separately)
        local tab = {
            title = tabData.title,
            closable = tabData.closable
        }
        table.insert(self.tabs, tab)

        -- Recreate tab button
        local buttonX = self.x + (i - 1) * 100
        local tabButton = Button:new(buttonX, self.y, 95, self.tabHeight, tab.title, function()
            self:setActiveTab(i)
        end)
        table.insert(self.tabButtons, tabButton)
        self:addChild(tabButton)
    end

    self.activeTab = data.activeTab
    self.tabHeight = data.tabHeight or 30
end

return TabContainer
