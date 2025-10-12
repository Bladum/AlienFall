--[[
    Widget System Loader
    
    Main entry point for the widget system.
    Loads all core components and widgets.
]]

local Widgets = {}

-- Core systems (from core/ folder)
Widgets.Grid = require("widgets.core.grid")
Widgets.Theme = require("widgets.core.theme")
Widgets.BaseWidget = require("widgets.core.base")
Widgets.MockData = require("widgets.core.mock_data")

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
Widgets.Button = require("widgets.buttons.button")
Widgets.ImageButton = require("widgets.buttons.imagebutton")

-- Display widgets (from display/ folder)
Widgets.Label = require("widgets.display.label")
Widgets.ProgressBar = require("widgets.display.progressbar")
Widgets.HealthBar = require("widgets.display.healthbar")
Widgets.Tooltip = require("widgets.display.tooltip")
Widgets.Table = require("widgets.display.table")

-- Containers (from containers/ folder)
Widgets.Panel = require("widgets.containers.panel")
Widgets.Container = require("widgets.containers.container")
Widgets.ScrollBox = require("widgets.containers.scrollbox")
Widgets.FrameBox = require("widgets.containers.framebox")
Widgets.Dialog = require("widgets.containers.dialog")
Widgets.Window = require("widgets.containers.window")

-- Input widgets (from input/ folder)
Widgets.TextInput = require("widgets.input.textinput")
Widgets.Checkbox = require("widgets.input.checkbox")
Widgets.RadioButton = require("widgets.input.radiobutton")
Widgets.Spinner = require("widgets.input.spinner")
Widgets.ComboBox = require("widgets.input.combobox")
Widgets.Autocomplete = require("widgets.input.autocomplete")
Widgets.TextArea = require("widgets.input.textarea")

-- Navigation widgets (from navigation/ folder)
Widgets.Dropdown = require("widgets.navigation.dropdown")
Widgets.ListBox = require("widgets.navigation.listbox")
Widgets.TabWidget = require("widgets.navigation.tabwidget")
Widgets.ContextMenu = require("widgets.navigation.contextmenu")

-- Strategy Game Widgets (from strategy/ folder - TASK-006)
Widgets.UnitCard = require("widgets.strategy.unitcard")
Widgets.ActionBar = require("widgets.strategy.actionbar")
Widgets.ResourceDisplay = require("widgets.strategy.resourcedisplay")
Widgets.MiniMap = require("widgets.strategy.minimap")
Widgets.TurnIndicator = require("widgets.strategy.turnindicator")
Widgets.InventorySlot = require("widgets.strategy.inventoryslot")
Widgets.ResearchTree = require("widgets.strategy.researchtree")
Widgets.NotificationBanner = require("widgets.strategy.notificationbanner")
Widgets.RangeIndicator = require("widgets.strategy.rangeindicator")

print("[Widgets] Widget system loader initialized - 33 widgets organized in 7 categories")

return Widgets
