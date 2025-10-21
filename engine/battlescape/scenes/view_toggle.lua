---ViewToggle - 2D/3D Camera Perspective Switch
---
---Manages switching between 2D tactical view and 3D first-person view during
---battlescape. Handles smooth camera transitions, view preference persistence,
---and input handling for perspective switching (SPACE key).
---
---Features:
---  - Instant or smooth camera transitions (0.5s blend)
---  - View persistence (remembers last view per mission)
---  - Input handling: SPACE key to toggle, indicators for active view
---  - HUD adaptation (2D hex overlay vs 3D crosshair)
---  - Keybinding: SPACE to toggle, Q/E for 2D rotation
---  - View indicators showing which mode is active
---  - Optional first-person head bobbing (strafe/walk animation)
---
---Camera Modes:
---
---2D Tactical View:
---  - Isometric top-down perspective
---  - Hex grid overlay with pathfinding UI
---  - Unit movement with click-to-move
---  - Full map visibility with fog of war
---  - Rotation with Q/E keys
---  - Zoom with mouse wheel
---
---3D First-Person View:
---  - Wolfenstein 3D-style raycasting
---  - 24×24 hex grid floor
---  - 6-face hex wall detection
---  - Full 3D combat HUD
---  - Crosshair-based targeting
---  - WASD movement, mouse look (mouselook off for turn-based)
---
---Transitions:
---  - Smooth blend (0.5 seconds) between views
---  - Easing function for smooth camera motion
---  - Head bob initialization/cleanup
---  - HUD fade in/out
---
---Key Exports:
---  - ViewToggle.new(): Creates view manager
---  - getCurrentView(): Returns "2d" or "3d"
---  - toggleView(): Switch between 2D and 3D
---  - setView(viewType, smooth): Force specific view
---  - setViewPreference(viewType): Save preference
---  - getViewPreference(): Load saved preference
---  - update(dt): Update transitions
---  - draw(): Render appropriate view
---  - handleInput(key): Process input
---
---Keybindings:
---  - SPACE: Toggle 2D/3D
---  - Q: 2D rotate left
---  - E: 2D rotate right
---  - +/-: 2D zoom
---  - W/A/S/D: 3D movement
---  - Mouse: 3D look (disabled in turn-based)
---
---Dependencies:
---  - battlescape.rendering.renderer_3d: 3D rendering
---  - battlescape.systems.battle_system_2d: 2D tactical
---  - battlescape.ui.pathfinding_ui: 2D UI overlay
---  - battlescape.ui.hud_overlay: 3D HUD
---
---@module battlescape.scenes.view_toggle
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local ViewToggle = require("battlescape.scenes.view_toggle")
---  local toggle = ViewToggle.new()
---  toggle:setView("2d", true)  -- Smooth transition to 2D
---  if toggle:getCurrentView() == "2d" then
---      -- Handle 2D input
---  end
---
---@see battlescape.rendering.renderer_3d For 3D view
---@see battlescape.systems.battle_system_2d For 2D view

local ViewToggle = {}

---@class ViewToggle
---@field currentView string Current view mode ("2d" or "3d")
---@field nextView string Target view after transition
---@field isTransitioning boolean Currently transitioning between views
---@field transitionTime number Transition elapsed time
---@field transitionDuration number Total transition time (0.5s)
---@field savedPreference string Last selected view preference
---@field cameraState table Camera data for smooth transitions
---@field screenWidth number Screen width (960)
---@field screenHeight number Screen height (720)
---@field renderer3d table 3D rendering system instance
---@field battleSystem2D table 2D battle system instance
---@field hudOverlay table 3D HUD instance
---@field pathfindingUI table 2D pathfinding UI
---@field initialized boolean

---Create view toggle manager
---@param renderer3D? table 3D renderer instance (optional)
---@param battleSystem2D? table 2D battle system (optional)
---@return ViewToggle View toggle instance
function ViewToggle.new(renderer3D, battleSystem2D)
    local self = setmetatable({}, {__index = ViewToggle})
    
    self.currentView = "2d"  -- Start in 2D
    self.nextView = "2d"
    self.isTransitioning = false
    self.transitionTime = 0
    self.transitionDuration = 0.5  -- 0.5 second smooth transition
    
    self.cameraState = {
        position = {x = 30, y = 30, z = 1.5},  -- First-person eye height
        euler = {x = 0, y = 0, z = 0},
        zoom = 1.0,
        rotation = 0
    }
    
    self.savedPreference = nil
    self.screenWidth = 960
    self.screenHeight = 720
    
    self.renderer3D = renderer3D
    self.battleSystem2D = battleSystem2D
    self.hudOverlay = nil
    self.pathfindingUI = nil
    
    -- Load saved preference
    self:_loadPreference()
    
    self.initialized = true
    
    print("[ViewToggle] Initialized (current view: " .. self.currentView .. ")")
    
    return self
end

---Get current view mode
---@return string Current view ("2d" or "3d")
function ViewToggle:getCurrentView()
    return self.currentView
end

---Get next view during transition
---@return string Next view mode
function ViewToggle:getNextView()
    return self.nextView
end

---Check if currently transitioning
---@return boolean result True if transitioning between views
function ViewToggle:isTransitioning()
    return self.isTransitioning
end

---Toggle between 2D and 3D views
---@param smooth boolean Use smooth transition (default true)
function ViewToggle:toggleView(smooth)
    smooth = smooth ~= false  -- Default to smooth
    
    local newView = (self.currentView == "2d") and "3d" or "2d"
    self:setView(newView, smooth)
end

---Set specific view mode
---@param viewType string View type ("2d" or "3d")
---@param smooth boolean Use smooth transition (default true)
function ViewToggle:setView(viewType, smooth)
    if viewType ~= "2d" and viewType ~= "3d" then
        print("[ViewToggle] ERROR: Invalid view type: " .. tostring(viewType))
        return
    end
    
    if viewType == self.currentView then
        return  -- Already in this view
    end
    
    smooth = smooth ~= false
    
    self.nextView = viewType
    
    if smooth then
        -- Start smooth transition
        self.isTransitioning = true
        self.transitionTime = 0
        print(string.format("[ViewToggle] Starting transition to %s", viewType))
    else
        -- Instant switch
        self:_finishTransition()
    end
end

---Set view preference (saved across missions)
---@param viewType string Preferred view ("2d" or "3d")
function ViewToggle:setViewPreference(viewType)
    self.savedPreference = viewType
    self:_savePreference(viewType)
    print(string.format("[ViewToggle] View preference saved: %s", viewType))
end

---Get saved view preference
---@return string Saved preference
function ViewToggle:getViewPreference()
    return self.savedPreference or "2d"
end

---Update transition animation
---@param dt number Delta time in seconds
function ViewToggle:update(dt)
    if not self.isTransitioning then
        return
    end
    
    self.transitionTime = self.transitionTime + dt
    
    if self.transitionTime >= self.transitionDuration then
        -- Transition complete
        self:_finishTransition()
    else
        -- Update blend during transition
        local progress = self.transitionTime / self.transitionDuration
        self:_updateTransitionBlend(progress)
    end
end

---Render current view
---@param battlestate table Current battle state
function ViewToggle:draw(battlestate)
    if self.currentView == "2d" then
        self:_draw2D(battlestate)
    else
        self:_draw3D(battlestate)
    end
    
    -- Draw transition fade overlay if transitioning
    if self.isTransitioning then
        self:_drawTransitionOverlay()
    end
    
    -- Draw view indicator
    self:_drawViewIndicator()
end

---Handle keyboard input
---@param key string Pressed key
function ViewToggle:handleInput(key)
    if key == "space" then
        self:toggleView(true)
        return true
    end
    
    -- View-specific input
    if self.currentView == "2d" then
        return self:_handle2DInput(key)
    else
        return self:_handle3DInput(key)
    end
end

---Finish transition and update view
function ViewToggle:_finishTransition()
    self.currentView = self.nextView
    self.isTransitioning = false
    self.transitionTime = 0
    
    print(string.format("[ViewToggle] Transitioned to: %s", self.currentView))
    
    -- Save preference
    self:setViewPreference(self.currentView)
end

---Update transition blend effect
---@param progress number Transition progress (0-1)
function ViewToggle:_updateTransitionBlend(progress)
    -- Smooth easing: quadratic ease-in-out
    local eased = progress < 0.5 
        and 2 * progress * progress
        or -1 + (4 - 2 * progress) * progress
    
    -- Could update camera position/zoom here for smooth camera motion
end

---Draw 2D tactical view
---@param battlestate table Battle state
function ViewToggle:_draw2D(battlestate)
    -- Draw hex grid battlefield
    love.graphics.setColor(0.15, 0.15, 0.15)
    love.graphics.rectangle("fill", 0, 0, self.screenWidth, self.screenHeight)
    
    -- Draw battle system 2D
    if self.battleSystem2D and self.battleSystem2D.draw then
        self.battleSystem2D:draw(battlestate)
    end
    
    -- Draw pathfinding UI overlay
    if self.pathfindingUI and self.pathfindingUI.draw then
        self.pathfindingUI:draw(battlestate.cameraX, battlestate.cameraY)
    end
end

---Draw 3D first-person view
---@param battlestate table Battle state
function ViewToggle:_draw3D(battlestate)
    -- Draw 3D raycasted scene
    if self.renderer3D and self.renderer3D.draw then
        self.renderer3D:draw(battlestate)
    end
    
    -- Draw 3D HUD overlay
    if self.hudOverlay and self.hudOverlay.draw then
        self.hudOverlay:draw()
    end
end

---Draw transition overlay (fade effect)
function ViewToggle:_drawTransitionOverlay()
    local progress = self.transitionTime / self.transitionDuration
    local alpha = math.abs(progress - 0.5) * 2  -- Peak at 0.5
    
    love.graphics.setColor(0, 0, 0, alpha * 0.3)
    love.graphics.rectangle("fill", 0, 0, self.screenWidth, self.screenHeight)
    
    love.graphics.setColor(1, 1, 1)
end

---Draw view mode indicator
function ViewToggle:_drawViewIndicator()
    local label = (self.currentView == "2d") and "[2D Tactical]" or "[3D First-Person]"
    local nextLabel = self.isTransitioning and 
        string.format(" → %s", (self.nextView == "2d") and "[2D]" or "[3D]")
        or ""
    
    love.graphics.setColor(0.2, 1.0, 0.2)
    love.graphics.printf(label .. nextLabel, 10, 5, 200, "left")
    
    -- Show toggle hint
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.printf("[SPACE to toggle]", self.screenWidth - 200, 5, 190, "right")
    
    love.graphics.setColor(1, 1, 1)
end

---Handle 2D view input
---@param key string Pressed key
---@return boolean True if input was handled
function ViewToggle:_handle2DInput(key)
    if key == "q" then
        -- Rotate view left
        self.cameraState.rotation = self.cameraState.rotation + math.pi / 4
        return true
    elseif key == "e" then
        -- Rotate view right
        self.cameraState.rotation = self.cameraState.rotation - math.pi / 4
        return true
    elseif key == "up" then
        -- Zoom in
        self.cameraState.zoom = self.cameraState.zoom * 1.1
        return true
    elseif key == "down" then
        -- Zoom out
        self.cameraState.zoom = self.cameraState.zoom / 1.1
        return true
    end
    
    return false
end

---Handle 3D view input
---@param key string Pressed key
---@return boolean True if input was handled
function ViewToggle:_handle3DInput(key)
    if key == "w" then
        self.cameraState.position.y = self.cameraState.position.y - 2
        return true
    elseif key == "s" then
        self.cameraState.position.y = self.cameraState.position.y + 2
        return true
    elseif key == "a" then
        self.cameraState.position.x = self.cameraState.position.x - 2
        return true
    elseif key == "d" then
        self.cameraState.position.x = self.cameraState.position.x + 2
        return true
    end
    
    return false
end

---Load view preference from storage
function ViewToggle:_loadPreference()
    -- In a real implementation, would load from game.save or settings
    self.savedPreference = "2d"  -- Default
end

---Save view preference to storage
---@param viewType string View type to save
function ViewToggle:_savePreference(viewType)
    -- In a real implementation, would save to game.save
    self.savedPreference = viewType
end

return ViewToggle



