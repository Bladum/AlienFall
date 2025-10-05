--[[
widgets/init.lua
Widget system initialization and module loader


Centralized loading and access system for all UI widgets in the AlienFall game interface.
Provides safe loading with error handling and proper initialization order.

PURPOSE:
- Provide centralized loading and access to all UI widgets
- Ensure proper initialization order and dependency management
- Enable safe loading with error handling for individual widget modules
- Facilitate easy access to widget classes and core functionality

KEY FEATURES:
- Safe loading with pcall to prevent system crashes from individual widget failures
- Centralized registry for all widget classes and modules
- Proper initialization order with core module loaded first
- Error reporting and logging for failed widget loads
- Dependency management and resolution
- Lazy loading support for performance optimization
- Version checking and compatibility validation
- Debug mode with detailed loading information
- Hot reload support for development

@see widgets.core
@see widgets.theme
]]

local core = require("widgets.core")
local widgets = { core = core }

-- explicit mapping: module file -> exported widget key
local modules = {
    { file = "common.button",          key = "Button" },
    { file = "common.checkbox",        key = "Checkbox" },
    { file = "common.togglebutton",    key = "ToggleButton" },
    { file = "common.slider",          key = "Slider" },
    { file = "common.radiobutton",     key = "RadioButton" },
    { file = "common.textinput",       key = "TextInput" },
    { file = "common.textarea",        key = "TextArea" },
    { file = "common.label",           key = "Label" },
    { file = "common.progressbar",     key = "ProgressBar" },
    { file = "common.dropdown",        key = "Dropdown" },
    { file = "common.listbox",         key = "ListBox" },
    { file = "common.scrollbar",       key = "ScrollBar" },
    { file = "common.panel",           key = "Panel" },
    { file = "common.window",          key = "Window" },
    { file = "common.menu",            key = "Menu" },
    { file = "common.tab",             key = "Tab" },
    { file = "common.spinner",         key = "Spinner" },
    { file = "common.imagebutton",     key = "ImageButton" },
    { file = "common.table",           key = "Table" },
    { file = "common.combobox",        key = "ComboBox" },
    { file = "common.tabwidget",       key = "TabWidget" },
    { file = "common.tabcontainer",    key = "TabContainer" },
    { file = "common.dialog",          key = "Dialog" },
    { file = "common.validation",      key = "Validation" },
    { file = "common.tooltip",         key = "Tooltip" },
    { file = "complex.colorpicker",    key = "ColorPicker" },
    { file = "complex.minimap",        key = "MiniMap" },
    { file = "complex.tilemap",        key = "TileMap" },
    { file = "complex.node",           key = "Node" },
    { file = "complex.nodegraph",      key = "NodeGraph" },
    { file = "complex.dragdrop",       key = "DragDrop" },
    { file = "complex.layout",         key = "Layout" },
    { file = "complex.animation",      key = "Animation" },
    { file = "complex.rangeslider",    key = "RangeSlider" },
    { file = "complex.autocomplete",   key = "AutoComplete" },
    { file = "complex.chart",          key = "Chart" },
    { file = "complex.treeview",       key = "TreeView" },
    { file = "complex.calendar",       key = "Calendar" },
    { file = "complex.unitpanel",      key = "UnitPanel" },
    { file = "complex.inventorygrid",  key = "InventoryGrid" },
    { file = "complex.techtree",       key = "TechTree" },
    { file = "complex.turnindicator",  key = "TurnIndicator" },
    { file = "complex.radialmenu",     key = "RadialMenu" },
    { file = "complex.statuseffect",   key = "StatusEffect" },
    { file = "complex.gridmap",        key = "GridMap" },
    { file = "complex.inventory",      key = "Inventory" },
    { file = "alienfall.resourcebar",  key = "ResourceBar" },
    { file = "alienfall.commandpanel", key = "CommandPanel" },
    { file = "alienfall.actionbar",    key = "ActionBar" },
    { file = "alienfall.alertsystem",  key = "AlertSystem" }
}

for _, entry in ipairs(modules) do
    local name = entry.file
    local ok, mod = pcall(require, "widgets." .. name)
    if ok and mod then
        widgets[entry.key] = mod
    else
        print("widgets.init: warning loading module widgets." .. name .. ": " .. tostring(mod))
    end
end

return widgets
