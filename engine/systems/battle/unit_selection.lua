-- Unit Selection Manager
-- Handles unit selection, movement range, and path preview

local UnitSelection = {}
UnitSelection.__index = UnitSelection

-- Create a new unit selection manager
function UnitSelection.new(actionSystem, pathfinding, battlefield, turnManager, animationSystem, onVisibilityUpdate)
    local self = setmetatable({}, UnitSelection)
    
    self.actionSystem = actionSystem
    self.pathfinding = pathfinding
    self.battlefield = battlefield
    self.turnManager = turnManager
    self.animationSystem = animationSystem
    self.onVisibilityUpdate = onVisibilityUpdate
    
    self.selectedUnit = nil
    self.showMovementRange = false
    self.movementRange = {}
    self.movementPath = nil
    self.hoveredTile = nil
    self.visibleTiles = {}  -- Tiles visible to selected unit
    
    return self
end

-- Select a unit
function UnitSelection:selectUnit(unit, battlefield)
    if not unit or not unit.alive then
        self:clearSelection()
        return false
    end
    
    local currentTeam = self.turnManager:getCurrentTeam()
    self.selectedUnit = unit
    self.showMovementRange = true
    self.movementRange = self.actionSystem:calculateMovementRange(unit, battlefield, currentTeam)
    self.movementPath = nil
    
    print(string.format("[UnitSelection] Selected: %s", unit.name))
    return true
end

-- Clear selection
function UnitSelection:clearSelection()
    self.selectedUnit = nil
    self.showMovementRange = false
    self.movementRange = {}
    self.movementPath = nil
    self.visibleTiles = {}
    print("[UnitSelection] Cleared selection")
end

-- Update hovered tile and path preview
function UnitSelection:updateHover(tileX, tileY, battlefield, actionSystem, pathfinding)
    if not tileX or not tileY then
        self.hoveredTile = nil
        self.movementPath = nil
        return
    end
    
    -- Store references if provided
    if battlefield then self.battlefield = battlefield end
    if actionSystem then self.actionSystem = actionSystem end
    if pathfinding then self.pathfinding = pathfinding end
    
    self.hoveredTile = {x = tileX, y = tileY}
    
    -- Update path preview if unit is selected
    if self.selectedUnit and self.showMovementRange then
        self:updatePathPreview(tileX, tileY)
    end
end

-- Update movement path preview
function UnitSelection:updatePathPreview(targetX, targetY)
    -- Check if target is in movement range
    local inRange = false
    for _, tile in ipairs(self.movementRange) do
        if tile.x == targetX and tile.y == targetY then
            inRange = true
            break
        end
    end
    
    if inRange and self.selectedUnit then
        -- Find path to target
        self.movementPath = self.pathfinding:findPath(
            self.selectedUnit,
            self.selectedUnit.x,
            self.selectedUnit.y,
            targetX,
            targetY,
            self.battlefield,  -- battlefield parameter
            self.actionSystem
        )
    else
        self.movementPath = nil
    end
end

-- Check if tile is in movement range
function UnitSelection:isInMovementRange(x, y)
    for _, tile in ipairs(self.movementRange) do
        if tile.x == x and tile.y == y then
            return true
        end
    end
    return false
end

-- Get selected unit
function UnitSelection:getSelectedUnit()
    return self.selectedUnit
end

-- Check if unit is selected
function UnitSelection:isUnitSelected()
    return self.selectedUnit ~= nil
end

-- Get hovered tile
function UnitSelection:getHoveredTile()
    return self.hoveredTile
end

-- Get movement range tiles
function UnitSelection:getMovementRange()
    return self.movementRange
end

-- Get movement path
function UnitSelection:getMovementPath()
    return self.movementPath
end

-- Should show movement range overlay
function UnitSelection:shouldShowMovementRange()
    return self.showMovementRange
end

-- Handle battlefield click
function UnitSelection:handleClick(tileX, tileY, battlefield, units)
    -- Block input during animations
    if self.animationSystem:isAnimating() then
        return
    end
    
    -- Find unit at clicked position
    local clickedUnit = nil
    for _, unit in ipairs(units) do
        if unit.x == tileX and unit.y == tileY and unit.alive then
            clickedUnit = unit
            break
        end
    end
    
    -- If clicking on a unit
    if clickedUnit then
        -- If clicking on already selected unit, clear selection
        if self.selectedUnit == clickedUnit then
            self:clearSelection()
        else
            -- Select the clicked unit
            self:selectUnit(clickedUnit, battlefield)
        end
        return
    end
    
    -- If no unit clicked and we have a selected unit
    if self.selectedUnit then
        -- Check if clicked tile is in movement range
        if self:isInMovementRange(tileX, tileY) then
        -- Move the selected unit
        self:moveSelectedUnit(tileX, tileY, battlefield, self.onVisibilityUpdate)
        else
            -- Clear selection if clicking outside movement range
            self:clearSelection()
        end
    end
end

-- Move selected unit to target position
function UnitSelection:moveSelectedUnit(targetX, targetY, battlefield, onVisibilityUpdate)
    if not self.selectedUnit then
        return false
    end
    
    -- Find path to target
    local path = self.pathfinding:findPath(
        self.selectedUnit,
        self.selectedUnit.x,
        self.selectedUnit.y,
        targetX,
        targetY,
        battlefield,
        self.actionSystem
    )
    
    if path and #path > 0 then
        -- Move unit along path with animation
        local success = self.actionSystem:moveUnitAlongPath(self.selectedUnit, path, battlefield, self.animationSystem, onVisibilityUpdate)
        if success then
            print(string.format("[UnitSelection] Started movement for %s to (%d, %d)", 
                self.selectedUnit.name, targetX, targetY))
            -- Clear selection after starting move (will be cleared after animation completes)
            self:clearSelection()
            return true
        end
    end
    
    print(string.format("[UnitSelection] Failed to move %s to (%d, %d)", 
        self.selectedUnit.name, targetX, targetY))
    return false
end

return UnitSelection
