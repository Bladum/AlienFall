-- Geoscape State
-- Strategic world map with province network

local StateManager = require("core.state_manager")
local Widgets = require("widgets.init")

local Geoscape = {}

-- Load submodules
local GeoscapeLogic = require("geoscape.logic.world_state")
local GeoscapeRender = require("geoscape.ui.render")
local GeoscapeInput = require("geoscape.ui.input")
local GeoscapeData = require("geoscape.logic.data")

-- Inherit functions from submodules
for k, v in pairs(GeoscapeLogic) do Geoscape[k] = v end
for k, v in pairs(GeoscapeRender) do Geoscape[k] = v end
for k, v in pairs(GeoscapeInput) do Geoscape[k] = v end
for k, v in pairs(GeoscapeData) do Geoscape[k] = v end

return Geoscape