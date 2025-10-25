---GUI Manager - Master Orchestrator for User Interface
---
---Coordinates all GUI systems including scenes, widgets, and UI state management.
---Handles scene transitions, widget lifecycle, and input routing.
---
---@module gui_manager
---@author AlienFall Development Team
---@license Open Source

local GUIManager = {}
GUIManager.__index = GUIManager

---Initialize the GUI Manager
---
---@return table self Reference to the GUI manager singleton
function GUIManager.new()
    local self = setmetatable({}, GUIManager)

    print("[GUIManager] Initializing GUI systems...")

    self.scenes = {}
    self.widgets = {}
    self.currentScene = nil
    self.uiState = {}

    print("[GUIManager] GUI manager initialized")

    return self
end

---Register a scene with the GUI manager
---
---@param sceneId string Unique scene identifier
---@param sceneModule any The scene module to register
function GUIManager:registerScene(sceneId, sceneModule)
    self.scenes[sceneId] = sceneModule
    print("[GUIManager] Registered scene: " .. sceneId)
end

---Switch to a different scene
---
---@param sceneId string The scene to switch to
---@param ... any Arguments to pass to the scene
function GUIManager:switchScene(sceneId, ...)
    if self.currentScene and self.currentScene.cleanup then
        self.currentScene:cleanup()
    end

    self.currentScene = self.scenes[sceneId]
    if self.currentScene then
        if self.currentScene.load then
            self.currentScene:load(...)
        end
        print("[GUIManager] Switched to scene: " .. sceneId)
    else
        print("[GUIManager] ERROR: Scene not found: " .. sceneId)
    end
end

---Get current active scene
---
---@return any The current scene, or nil if none active
function GUIManager:getCurrentScene()
    return self.currentScene
end

---Update GUI each frame
---
---@param dt number Delta time in seconds
function GUIManager:update(dt)
    if self.currentScene and self.currentScene.update then
        self.currentScene:update(dt)
    end
end

---Draw GUI to screen
function GUIManager:draw()
    if self.currentScene and self.currentScene.draw then
        self.currentScene:draw()
    end
end

---Handle keyboard input
---
---@param key string The key pressed
function GUIManager:keypressed(key)
    if self.currentScene and self.currentScene.keypressed then
        self.currentScene:keypressed(key)
    end
end

---Handle mouse input
---
---@param x number Mouse X coordinate
---@param y number Mouse Y coordinate
---@param button number Mouse button (1=left, 2=right, 3=middle)
function GUIManager:mousepressed(x, y, button)
    if self.currentScene and self.currentScene.mousepressed then
        self.currentScene:mousepressed(x, y, button)
    end
end

return GUIManager

