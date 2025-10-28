---Geoscape Input Module - Keyboard and Mouse Input Handling
---
---Contains input handling logic for geoscape layer. Manages keyboard shortcuts,
---camera controls, and game state transitions. Part of legacy geoscape system.
---
---Key Bindings:
---  - ESC: Return to main menu
---  - SPACE: Pause/Resume game
---  - R: Reset camera to default position
---  - Arrow Keys: Pan camera (handled elsewhere)
---  - Mouse Wheel: Zoom in/out (handled elsewhere)
---
---Key Exports:
---  - GeoscapeInput:keypressed(key, scancode, isrepeat): Keyboard input handler
---
---Dependencies:
---  - core.state_manager: State transitions
---
---@module geoscape.ui.input
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local GeoscapeInput = require("geoscape.ui.input")
---  function love.keypressed(key, scancode, isrepeat)
---    GeoscapeInput:keypressed(key, scancode, isrepeat)
---  end
---
---@see geoscape.world.world_state For game state

local StateManager = require("core.state.state_manager")

local GeoscapeInput = {}

function GeoscapeInput:keypressed(key, scancode, isrepeat)
    if key == "escape" then
        StateManager.switch("menu")
    elseif key == "space" then
        self.paused = not self.paused
        self.pauseButton.text = self.paused and "RESUME" or "PAUSE"
    elseif key == "r" then
        -- Reset camera
        self.camera.x = 0
        self.camera.y = 0
        self.camera.zoom = 0.5
    end
end

function GeoscapeInput:mousepressed(x, y, button, istouch, presses)
    self.backButton:mousepressed(x, y, button)
    self.pauseButton:mousepressed(x, y, button)
    
    if button == 1 then
        -- Convert screen coordinates to world coordinates
        local worldX = (x / self.camera.zoom) - self.camera.x
        local worldY = (y / self.camera.zoom) - self.camera.y
        
        local province = self:getProvinceAtWorldPosition(worldX, worldY)
        if province then
            self.selectedProvince = province
            print("[Geoscape] Selected province: " .. province.name)
        end
    end
end

function GeoscapeInput:mousereleased(x, y, button, istouch, presses)
    self.backButton:mousereleased(x, y, button)
    self.pauseButton:mousereleased(x, y, button)
end

-- Mouse wheel for zooming
function GeoscapeInput:wheelmoved(x, y)
    local zoomFactor = 1.1
    if y > 0 then
        self.camera.zoom = math.min(self.camera.maxZoom, self.camera.zoom * zoomFactor)
    elseif y < 0 then
        self.camera.zoom = math.max(self.camera.minZoom, self.camera.zoom / zoomFactor)
    end
end

return GeoscapeInput


























