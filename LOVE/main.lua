--- Global Love2D declaration for Lua LSP
---@diagnostic disable: lowercase-global
---@type table
love = love or {}

package.path = package.path .. ";./widgets/?.lua;./widgets/?/init.lua"

local files = {
    "widgets.core",
    "widgets.theme",
    "widgets.common.validation",
    "widgets.common.button",
    "widgets.common.label",
    "widgets.common.slider",
    "widgets.common.textinput",
    "widgets.common.checkbox",
    "widgets.common.togglebutton",
    "widgets.common.radiobutton",
    "widgets.common.textarea",
    "widgets.common.progressbar",
    "widgets.common.dropdown",
    "widgets.common.listbox",
    "widgets.common.scrollbar",
    "widgets.common.panel",
    "widgets.common.window",
    "widgets.common.menu",
    "widgets.common.tab",
    "widgets.common.spinner",
    "widgets.common.imagebutton",
    "widgets.common.table",
    "widgets.common.combobox",
    "widgets.common.tabwidget",
    "widgets.common.tabcontainer",
    "widgets.common.dialog",
    "widgets.common.tooltip",
    "widgets.complex.rangeslider",
    "widgets.complex.treeview",
    "widgets.complex.calendar",
    "widgets.complex.chart",
    "widgets.complex.colorpicker",
    "widgets.complex.dragdrop",
    "widgets.complex.layout",
    "widgets.complex.radialmenu",
    "widgets.complex.animation",
    "widgets.complex.autocomplete",
    "widgets.complex.node",
    "widgets.complex.nodegraph",
    "widgets.complex.tilemap",
    "widgets.complex.gridmap",
    "widgets.complex.statuseffect",
    "widgets.complex.turnindicator",
    "widgets.complex.unitpanel",
    "widgets.complex.techtree",
    "widgets.complex.minimap",
    "widgets.complex.inventory",
    "widgets.complex.inventorygrid",
    "widgets.alienfall.resourcebar",
    "widgets.alienfall.commandpanel",
    "widgets.alienfall.actionbar",
    "widgets.alienfall.alertsystem",
    "widgets.alienfall.soldierroster",
    "widgets.alienfall.researchpanel",
    "widgets.alienfall.manufacturepanel",
    "widgets.alienfall.soldier_stats",
    "widgets.alienfall.soldier_training",
    "widgets.alienfall.ufo_tracker",
    "widgets.alienfall.mission_generator",
    "widgets.alienfall.interception",
    "widgets.alienfall.missiondebrief",
    "widgets.alienfall.geoscape",
    "widgets.alienfall.battlescape",
    "widgets.alienfall.missionbriefing",
    "widgets.alienfall.basefacilitypanel",
    "widgets.alienfall.baselayout"
}

for _, file in ipairs(files) do
    local ok, err = pcall(require, file)
    if not ok then
        print("Error loading " .. file .. ": " .. tostring(err))
    else
        print("Loaded " .. file)
    end
end

print("Done")
