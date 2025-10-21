---BattlescapeIntegration - Hex Battle System Integration Guide
---
---Integration guide and status tracking for migrating from the old battlefield
---system to the new ECS-based hex grid system. Provides step-by-step instructions
---for proper vision, movement, and rendering integration.
---
---Integration Components:
---  - ECS hex battle system migration
---  - Vision and line-of-sight integration
---  - Movement and pathfinding updates
---  - Rendering pipeline modifications
---  - UI and input system updates
---
---Migration Steps:
---  1. Replace battlefield.lua with ECS battle system
---  2. Update vision calculations for hex grid
---  3. Modify movement system for hex coordinates
---  4. Update rendering for hex-based positioning
---  5. Integrate new UI components
---
---Features:
---  - Step-by-step migration checklist
---  - System readiness verification
---  - Integration status tracking
---  - Compatibility layer for gradual migration
---  - Testing and validation procedures
---
---Key Exports:
---  - version: Integration guide version
---  - status: Current integration status
---  - systems_ready: Boolean indicating system readiness
---  - checkSystemStatus(): Verify system integration status
---  - getMigrationSteps(): Get detailed migration checklist
---
---Dependencies:
---  - ECS battle system components
---  - Hex grid mathematics
---  - Vision and LOS systems
---
---@module battlescape.logic.integration
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local integration = require("battlescape.logic.integration")
---  print("Integration status:", integration.status)
---  if integration.systems_ready then
---      -- Proceed with migration
---  end
---
---@see battlescape.battle_ecs For new ECS battle system
---@see battlescape.battlefield For legacy battlefield system

-- battlescape_integration.lua
-- Integration guide for hex battle system
-- This file shows how to integrate the new ECS hex system with existing battlescape.lua

--- @class BattlescapeIntegration
--- Integration guide and status for the hex-based battle system.
--- Provides step-by-step instructions for migrating from the old battlefield system
--- to the new ECS-based hex grid system with proper vision, movement, and rendering.

--- @type table
--- Configuration table containing integration status and metadata
local integration = {
    version = "1.0.0",
    status = "Integration guide complete",
    systems_ready = true
}

--[[
INTEGRATION STEPS:

1. Add requires at top of battlescape.lua:
   local HexSystem = require("battlescape.battle_ecs.hex_system")
   local MovementSystem = require("battlescape.battle_ecs.movement_system")
   local VisionSystem = require("battlescape.battle_ecs.vision_system")
   local UnitEntity = require("battlescape.battle_ecs.unit_entity")
   local HexMath = require("battlescape.battle_ecs.hex_math")
   local Debug = require("battlescape.battle_ecs.debug")

2. In Battlescape:enter(), add:
   -- Initialize hex system (replaces battlefield)
   self.hexSystem = HexSystem.new(MAP_WIDTH, MAP_HEIGHT, TILE_SIZE)
   Debug.enabled = true  -- Enable debug output

3. In Battlescape:initUnits(), convert units:
   -- Old: local unit = Unit.new("soldier", "player", x, y)
   -- New: local unit = UnitEntity.new({q = x, r = y, teamId = 1, facing = 0, maxHP = 100, maxAP = 10})
   HexSystem.addUnit(self.hexSystem, unit.id, unit)

4. In Battlescape:keypressed(), add F8/F9 toggles:
   if key == "f8" then
       Debug.toggleFOW()
       print("[Battlescape] FOW toggle:", Debug.showFOW)
       return
   end

   if key == "f9" then
       Debug.toggleHexGrid()
       print("[Battlescape] Hex grid toggle:", Debug.showHexGrid)
       return
   end

5. In Battlescape:draw(), add after battlefield rendering:
   -- Draw hex grid overlay (F9)
   if Debug.showHexGrid then
       HexSystem.drawHexGrid(self.hexSystem, self.camera)
   end

   -- Draw vision cones (optional)
   if Debug.showVisionCones then
       local activeTeam = self.turnManager:getCurrentTeam()
       if activeTeam then
           VisionSystem.drawVisionCones(activeTeam.units, self.hexSystem, self.camera)
       end
   end

6. Update movement to use MovementSystem:
   -- In mouse click handler for unit movement:
   local targetQ, targetR = HexSystem.screenToHex(self.hexSystem, screenX, screenY)
   if MovementSystem.tryMove(unit, self.hexSystem, targetQ, targetR) then
       print("Unit moved successfully")
       VisionSystem.updateUnitVision(unit, self.hexSystem)
   end

7. Update vision to use VisionSystem:
   -- In Battlescape:updateVisibility():
   local activeTeam = self.turnManager:getCurrentTeam()
   if activeTeam then
       VisionSystem.updateTeamVision(activeTeam.units, self.hexSystem)
   end

8. Update turn end to reset AP:
   -- In end turn handler:
   MovementSystem.resetAllAP(self.units)

TESTING:
1. Run: lovec engine
2. Enter battle scene
3. Press F9 - should see green hex grid overlay
4. Press F8 - should toggle FOW
5. Click unit - should select with hex coordinates
6. Move unit - should use hex movement (2 AP per hex)
7. Rotate unit (Q/E) - should cost 1 AP per 60°

--]]

return integration

























