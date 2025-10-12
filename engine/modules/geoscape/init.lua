-- Geoscape State
-- Strategic world map with province network

local StateManager = require("systems.state_manager")
local Widgets = require("widgets.init")

local Geoscape = {}

-- Load submodules
local GeoscapeLogic = require("modules.geoscape.logic")
local GeoscapeRender = require("modules.geoscape.render")
local GeoscapeInput = require("modules.geoscape.input")
local GeoscapeData = require("modules.geoscape.data")

-- Inherit functions from submodules
for k, v in pairs(GeoscapeLogic) do Geoscape[k] = v end
for k, v in pairs(GeoscapeRender) do Geoscape[k] = v end
for k, v in pairs(GeoscapeInput) do Geoscape[k] = v end
for k, v in pairs(GeoscapeData) do Geoscape[k] = v end

return Geoscape