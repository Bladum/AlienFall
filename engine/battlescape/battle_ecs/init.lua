--- Battle Systems Module Loader
--- Loads and exports all battle system components.
---
--- This module serves as the main entry point for battle systems,
--- providing access to core battle functionality including battlefield
--- management, camera controls, unit selection, rendering, and turn management.
---
--- Example usage:
---   local Battle = require("battlescape.battle.init")
---   local battlefield = Battle.Battlefield.new()
---   Battle.Camera.focusOnUnit(selectedUnit)
---
--- Exported Modules:
---   - Battlefield: Core battlefield state and management
---   - Camera: Camera controls and viewport management
---   - UnitSelection: Unit selection and highlighting
---   - Renderer: Battle rendering and drawing
---   - TurnManager: Turn-based gameplay mechanics

return {
    Battlefield = require("battlescape.battlefield.battlefield"),
    Camera = require("battlescape.rendering.camera"),
    UnitSelection = require("battlescape.logic.unit_selection"),
    Renderer = require("battlescape.rendering.renderer"),
    TurnManager = require("battlescape.battlefield.turn_manager")
}
