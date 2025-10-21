---Widget System Loader - UI Framework Entry Point
---
---Main entry point for the widget system. Loads all core components (Grid, Theme, BaseWidget),
---widget categories (buttons, containers, display, input, navigation, advanced, combat), and
---provides unified namespace for all UI components. Supports grid-aligned layout (24×24 pixels),
---theming, event handling, and widget composition.
---
---Widget Categories:
---  - Core: Grid, Theme, BaseWidget, MockData
---  - Buttons: Button, ImageButton, IconButton, ToggleButton, RadioButton
---  - Containers: Panel, Window, Dialog, Frame, ScrollPanel
---  - Display: Label, ProgressBar, HealthBar, Tooltip, StatBar
---  - Input: TextInput, TextArea, Checkbox, ComboBox, Autocomplete
---  - Navigation: ListBox, Dropdown, TabWidget, Table, ContextMenu
---  - Advanced: UnitCard, ResearchTree, Minimap, InventorySlot, ResourceDisplay
---  - Combat: ActionPanel, UnitInfoPanel, SkillSelection, TurnIndicator, RangeIndicator
---
---Grid System:
---  - 960×720 resolution (40×30 grid)
---  - 24×24 pixel cell size
---  - All widgets snap to grid
---  - F9: Toggle grid overlay debug
---
---Theme System:
---  - colors: primary, secondary, background, text, success, warning, danger
---  - fonts: default, title, small
---  - padding: standard spacing (8px)
---  - borderWidth: consistent borders (2px)
---
---Key Exports:
---  - Widgets.Grid: Grid system and snapping functions
---  - Widgets.Theme: Theme colors, fonts, spacing
---  - Widgets.BaseWidget: Base class for all widgets
---  - Widgets.Button, Widgets.Panel, etc.: All widget types
---  - Widgets.MockData: Mock data generator for testing
---
---Dependencies:
---  - widgets.core.*: Grid, Theme, BaseWidget
---  - widgets.buttons.*: Button widgets
---  - widgets.containers.*: Container widgets
---  - widgets.display.*: Display widgets
---  - widgets.input.*: Input widgets
---  - widgets.navigation.*: Navigation widgets
---  - widgets.advanced.*: Advanced widgets
---  - widgets.combat.*: Combat widgets
---  - shared.items.mock_data: Mock data generator
---
---@module widgets.init
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local Widgets = require("gui.widgets.init")
---  local button = Widgets.Button.new(0, 0, 96, 48, "Click Me")
---  button:draw()
---  button:mousepressed(x, y, mouseButton)
---
---@see widgets.core.base For BaseWidget class
---@see widgets.core.grid For grid system

--[[
    Widget System Loader
    
    Main entry point for the widget system.
    Loads all core components and widgets.
]]

local Widgets = {}

-- Core systems (from core/ folder)
Widgets.Grid = require("gui.widgets.core.grid")
Widgets.Theme = require("gui.widgets.core.theme")
Widgets.BaseWidget = require("gui.widgets.core.base")
-- Mock data moved to root mock/ folder
Widgets.MockData = require("content.items.mock_data")

-- Initialize theme
Widgets.Theme.init()

-- Export grid functions for convenience
Widgets.snapToGrid = Widgets.Grid.snapToGrid
Widgets.snapSize = Widgets.Grid.snapSize
Widgets.gridToPixels = Widgets.Grid.gridToPixels
Widgets.pixelsToGrid = Widgets.Grid.pixelsToGrid

--[[
    Initialize the widget system
    Should be called in love.load()
]]
function Widgets.init()
    print("[Widgets] Widget system initialized")
    print("[Widgets] Grid: " .. Widgets.Grid.COLS .. "x" .. Widgets.Grid.ROWS .. 
          " (" .. Widgets.Grid.WIDTH .. "x" .. Widgets.Grid.HEIGHT .. " pixels)")
end

--[[
    Handle keypressed for global widget system features
    @param key string - Key pressed
]]
function Widgets.keypressed(key)
    if key == "f9" then
        Widgets.Grid.toggleDebug()
        return true
    end
    return false
end

--[[
    Draw debug overlay
    Should be called at the end of love.draw()
]]
function Widgets.drawDebug()
    Widgets.Grid.drawDebug()
end

-- Widget classes organized by category
-- Buttons (from buttons/ folder)
Widgets.Button = require("gui.widgets.buttons.button")
Widgets.ImageButton = require("gui.widgets.buttons.imagebutton")
Widgets.ActionButton = require("gui.widgets.buttons.action_button")

-- Display widgets (from display/ folder)
Widgets.Label = require("gui.widgets.display.label")
Widgets.ProgressBar = require("gui.widgets.display.progressbar")
Widgets.HealthBar = require("gui.widgets.display.healthbar")
Widgets.Tooltip = require("gui.widgets.display.tooltip")
Widgets.ActionPanel = require("gui.widgets.display.action_panel")

-- Containers (from containers/ folder)
Widgets.Panel = require("gui.widgets.containers.panel")
Widgets.Container = require("gui.widgets.containers.container")
Widgets.ScrollBox = require("gui.widgets.containers.scrollbox")
Widgets.FrameBox = require("gui.widgets.containers.framebox")
Widgets.Dialog = require("gui.widgets.containers.dialog")
Widgets.Window = require("gui.widgets.containers.window")
Widgets.NotificationPanel = require("gui.widgets.containers.notification_panel")

-- Input widgets (from input/ folder)
Widgets.TextInput = require("gui.widgets.input.textinput")
Widgets.Checkbox = require("gui.widgets.input.checkbox")
Widgets.RadioButton = require("gui.widgets.input.radiobutton")
Widgets.ComboBox = require("gui.widgets.input.combobox")
Widgets.Autocomplete = require("gui.widgets.input.autocomplete")
Widgets.TextArea = require("gui.widgets.input.textarea")

-- Navigation widgets (from navigation/ folder)
Widgets.Dropdown = require("gui.widgets.navigation.dropdown")
Widgets.ListBox = require("gui.widgets.navigation.listbox")
Widgets.TabWidget = require("gui.widgets.navigation.tabwidget")
Widgets.ContextMenu = require("gui.widgets.navigation.contextmenu")
Widgets.Table = require("gui.widgets.navigation.table")

-- Advanced widgets (from advanced/ folder)
Widgets.Spinner = require("gui.widgets.advanced.spinner")
Widgets.UnitCard = require("gui.widgets.advanced.unitcard")
Widgets.ActionBar = require("gui.widgets.advanced.actionbar")
Widgets.ResourceDisplay = require("gui.widgets.advanced.resourcedisplay")
Widgets.MiniMap = require("gui.widgets.advanced.minimap")
Widgets.TurnIndicator = require("gui.widgets.advanced.turnindicator")
Widgets.InventorySlot = require("gui.widgets.advanced.inventoryslot")
Widgets.ResearchTree = require("gui.widgets.advanced.researchtree")
Widgets.NotificationBanner = require("gui.widgets.advanced.notificationbanner")
Widgets.RangeIndicator = require("gui.widgets.advanced.rangeindicator")

print("[Widgets] Widget system loader initialized - 35 widgets organized in 7 categories")

return Widgets


























