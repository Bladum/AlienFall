-- Battle Systems Init
-- Loads all battle system modules

return {
    Battlefield = require("systems.battle.battlefield"),
    Camera = require("systems.battle.camera"),
    UnitSelection = require("systems.battle.unit_selection"),
    Renderer = require("systems.battle.renderer"),
    TurnManager = require("systems.battle.turn_manager")
}
