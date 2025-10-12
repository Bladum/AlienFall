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
Widgets.ComboBox = require("widgets.input.combobox")
Widgets.Autocomplete = require("widgets.input.autocomplete")
Widgets.TextArea = require("widgets.input.textarea")

-- Navigation widgets (from navigation/ folder)
Widgets.Dropdown = require("widgets.navigation.dropdown")
Widgets.ListBox = require("widgets.navigation.listbox")
Widgets.TabWidget = require("widgets.navigation.tabwidget")
Widgets.ContextMenu = require("widgets.navigation.contextmenu")
Widgets.Table = require("widgets.navigation.table")

-- Advanced widgets (from advanced/ folder)
Widgets.Spinner = require("widgets.advanced.spinner")
Widgets.UnitCard = require("widgets.advanced.unitcard")
Widgets.ActionBar = require("widgets.advanced.actionbar")
Widgets.ResourceDisplay = require("widgets.advanced.resourcedisplay")
Widgets.MiniMap = require("widgets.advanced.minimap")
Widgets.TurnIndicator = require("widgets.advanced.turnindicator")
Widgets.InventorySlot = require("widgets.advanced.inventoryslot")
Widgets.ResearchTree = require("widgets.advanced.researchtree")
Widgets.NotificationBanner = require("widgets.advanced.notificationbanner")
Widgets.RangeIndicator = require("widgets.advanced.rangeindicator")

print("[Widgets] Widget system loader initialized - 33 widgets organized in 7 categories")

return Widgets
