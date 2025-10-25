---Accessibility Manager - Master Orchestrator for Accessibility Systems
---
---Coordinates accessibility features including colorblind modes, controller support,
---UI scaling, screen reader integration, and other inclusive features.
---
---@module accessibility_manager
---@author AlienFall Development Team
---@license Open Source

local AccessibilityManager = {}
AccessibilityManager.__index = AccessibilityManager

---Initialize the Accessibility Manager
---
---@return table self Reference to the accessibility manager singleton
function AccessibilityManager.new()
    local self = setmetatable({}, AccessibilityManager)

    print("[AccessibilityManager] Initializing accessibility systems...")

    self.config = {
        colorblindMode = "normal",      -- "normal", "protanopia", "deuteranopia", "tritanopia"
        controllerEnabled = true,
        uiScale = 1.0,
        screenReaderEnabled = false,
        highContrast = false,
        fontSize = 12,
        keyboardNavigationEnabled = true,
    }

    self.colorblind = require("accessibility.colorblind_mode")
    self.controller = require("accessibility.controller_support")
    self.uiScaling = require("accessibility.ui_scaling")

    print("[AccessibilityManager] Accessibility systems initialized")

    return self
end

---Set colorblind mode
---
---@param mode string "normal", "protanopia", "deuteranopia", or "tritanopia"
function AccessibilityManager:setColorblindMode(mode)
    if mode == "normal" or mode == "protanopia" or mode == "deuteranopia" or mode == "tritanopia" then
        self.config.colorblindMode = mode
        if self.colorblind and self.colorblind.setMode then
            self.colorblind:setMode(mode)
        end
        print("[AccessibilityManager] Colorblind mode set to: " .. mode)
    else
        print("[AccessibilityManager] ERROR: Invalid colorblind mode: " .. mode)
    end
end

---Enable/disable controller support
---
---@param enabled boolean
function AccessibilityManager:setControllerSupport(enabled)
    self.config.controllerEnabled = enabled
    if self.controller and self.controller.setEnabled then
        self.controller:setEnabled(enabled)
    end
    print("[AccessibilityManager] Controller support: " .. (enabled and "enabled" or "disabled"))
end

---Set UI scaling factor
---
---@param scale number Scale factor (e.g., 1.0, 1.5, 2.0)
function AccessibilityManager:setUIScale(scale)
    if scale > 0 then
        self.config.uiScale = scale
        if self.uiScaling and self.uiScaling.setScale then
            self.uiScaling:setScale(scale)
        end
        print("[AccessibilityManager] UI scale set to: " .. scale)
    else
        print("[AccessibilityManager] ERROR: Invalid scale factor: " .. scale)
    end
end

---Enable/disable screen reader
---
---@param enabled boolean
function AccessibilityManager:setScreenReader(enabled)
    self.config.screenReaderEnabled = enabled
    print("[AccessibilityManager] Screen reader: " .. (enabled and "enabled" or "disabled"))
end

---Enable/disable high contrast mode
---
---@param enabled boolean
function AccessibilityManager:setHighContrast(enabled)
    self.config.highContrast = enabled
    print("[AccessibilityManager] High contrast mode: " .. (enabled and "enabled" or "disabled"))
end

---Get current accessibility configuration
---
---@return table The current accessibility config
function AccessibilityManager:getConfig()
    return self.config
end

return AccessibilityManager
