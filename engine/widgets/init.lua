--[[
    Widget System Loader
    
    Main entry point for the widget system.
    Loads all core components and widgets.
]]

local Widgets = {}

-- Core systems
Widgets.Grid = require("widgets.grid")
Widgets.Theme = require("widgets.theme")
Widgets.BaseWidget = require("widgets.base")
Widgets.MockData = require("widgets.mock_data")

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

-- Widget classes will be loaded here
-- (Will be populated as widgets are created)
Widgets.Button = require("widgets.button")
Widgets.Label = require("widgets.label")
Widgets.Panel = require("widgets.panel")
Widgets.Container = require("widgets.container")
Widgets.TextInput = require("widgets.textinput")
Widgets.Checkbox = require("widgets.checkbox")
Widgets.Dropdown = require("widgets.dropdown")
Widgets.ListBox = require("widgets.listbox")
Widgets.ProgressBar = require("widgets.progressbar")
Widgets.HealthBar = require("widgets.healthbar")
Widgets.ScrollBox = require("widgets.scrollbox")
Widgets.Tooltip = require("widgets.tooltip")
Widgets.FrameBox = require("widgets.framebox")
Widgets.TabWidget = require("widgets.tabwidget")
Widgets.Dialog = require("widgets.dialog")
Widgets.Window = require("widgets.window")
Widgets.ImageButton = require("widgets.imagebutton")
Widgets.ComboBox = require("widgets.combobox")
Widgets.RadioButton = require("widgets.radiobutton")
Widgets.Spinner = require("widgets.spinner")
Widgets.Autocomplete = require("widgets.autocomplete")
Widgets.Table = require("widgets.table")
Widgets.TextArea = require("widgets.textarea")

print("[Widgets] Widget system loader initialized")

return Widgets
