---MousePicking3D - 3D Raycast Selection System
---
---Raycasting system for mouse interaction in 3D first-person battlescape. Casts rays from
---camera through mouse cursor to select tiles, walls, units, and items. Provides hover and
---click interaction for 3D Wolfenstein-style view.
---
---Features:
---  - Raycast from camera to world
---  - Tile selection (floor tiles)
---  - Wall selection (wall faces)
---  - Unit selection (3D unit billboards)
---  - Item selection (loot, objects)
---  - Hover feedback
---  - Click interaction
---
---Raycast Algorithm:
---  1. Convert mouse 2D to 3D ray
---  2. Step along ray direction
---  3. Check intersections with objects
---  4. Return nearest hit object
---
---Hovered Object Types:
---  - unit: Enemy or ally unit
---  - wall: Wall tile face
---  - item: Dropped item or loot
---  - floor: Empty floor tile
---
---Key Exports:
---  - MousePicking3D.new(): Creates picking system
---  - update(mouseX, mouseY, camera): Updates hover state
---  - getHoveredObject(): Returns currently hovered object
---  - click(): Handles click on hovered object
---  - castRay(origin, direction): Raw raycast function
---
---Dependencies:
---  - None (standalone system)
---
---@module battlescape.systems.mouse_picking_3d
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local MousePicking3D = require("battlescape.systems.mouse_picking_3d")
---  local picker = MousePicking3D.new()
---  picker:update(mouseX, mouseY, camera)
---  local hovered = picker:getHoveredObject()
---  if hovered.type == "unit" then
---    -- Highlight unit
---  end
---
---@see battlescape.systems.movement_3d For 3D movement

-- Mouse Picking System for 3D Battlescape
-- Raycasting to select tiles, walls, units, and items
-- Provides mouse hover and click interaction in first-person view

local MousePicking3D = {}
MousePicking3D.__index = MousePicking3D

---@class HoveredObject
---@field type string "unit", "wall", "item", or "floor"
---@field data table Object-specific data

--- Create new mouse picking system
function MousePicking3D.new()
    local self = setmetatable({}, MousePicking3D)
    
    -- Currently hovered object
    self.hoveredObject = nil
    
    -- Picking settings
    self.settings = {
        maxDistance = 50,    -- Maximum pick distance
        unitRadius = 0.5,    -- Unit hit radius
        itemRadius = 0.3,    -- Item hit radius
        wallThickness = 0.1, -- Wall hit thickness
    }
    
    print("[MousePicking3D] Initialized")
    return self
end

--- Update mouse picking (call every frame)
---@param mouseX number Screen mouse X
---@param mouseY number Screen mouse Y
---@param camera table Camera parameters
---@param battlefield table Battlefield data
---@param units table Array of units
---@param items table Array of items
function MousePicking3D:update(mouseX, mouseY, camera, battlefield, units, items)
    -- Cast ray from camera through mouse position
    local ray = self:screenToWorldRay(mouseX, mouseY, camera)
    
    -- Check intersections in priority order: units > walls > items > floor
    
    -- Check unit intersections
    local unitHit = self:rayIntersectUnits(ray, units, camera)
    if unitHit then
        self.hoveredObject = {
            type = "unit",
            unit = unitHit.unit,
            distance = unitHit.distance,
        }
        return
    end
    
    -- Check wall intersections
    local wallHit = self:rayIntersectWalls(ray, battlefield)
    if wallHit then
        self.hoveredObject = {
            type = "wall",
            x = wallHit.x,
            y = wallHit.y,
            direction = wallHit.direction,
            distance = wallHit.distance,
        }
        return
    end
    
    -- Check item intersections
    local itemHit = self:rayIntersectItems(ray, items)
    if itemHit then
        self.hoveredObject = {
            type = "item",
            item = itemHit.item,
            distance = itemHit.distance,
        }
        return
    end
    
    -- Check floor intersection
    local floorHit = self:rayIntersectFloor(ray)
    if floorHit then
        self.hoveredObject = {
            type = "floor",
            x = floorHit.x,
            y = floorHit.y,
            distance = floorHit.distance,
        }
        return
    end
    
    -- No hit
    self.hoveredObject = nil
end

--- Convert screen coordinates to world ray
---@param screenX number Screen X coordinate
---@param screenY number Screen Y coordinate
---@param camera table Camera parameters
---@return table Ray {origin, direction}
function MousePicking3D:screenToWorldRay(screenX, screenY, camera)
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    
    -- Normalized device coordinates (-1 to 1)
    local ndcX = (screenX / screenWidth) * 2 - 1
    local ndcY = 1 - (screenY / screenHeight) * 2
    
    -- FOV-based ray direction
    local fov = camera.fov or 90
    local fovScale = math.tan(math.rad(fov / 2))
    
    local aspect = screenWidth / screenHeight
    local rayDirX = ndcX * fovScale * aspect
    local rayDirY = ndcY * fovScale
    local rayDirZ = 1.0
    
    -- Rotate by camera yaw
    local cosYaw = math.cos(camera.yaw)
    local sinYaw = math.sin(camera.yaw)
    
    local worldDirX = rayDirX * cosYaw + rayDirZ * sinYaw
    local worldDirY = rayDirY
    local worldDirZ = -rayDirX * sinYaw + rayDirZ * cosYaw
    
    -- Normalize direction
    local length = math.sqrt(worldDirX^2 + worldDirY^2 + worldDirZ^2)
    
    return {
        origin = {x = camera.x, y = camera.y, z = camera.z},
        direction = {
            x = worldDirX / length,
            y = worldDirY / length,
            z = worldDirZ / length
        }
    }
end

--- Ray-unit intersection test
---@param ray table Ray {origin, direction}
---@param units table Array of units
---@param camera table Camera (for visibility check)
---@return table|nil Hit result {unit, distance}
function MousePicking3D:rayIntersectUnits(ray, units, camera)
    local closestHit = nil
    local closestDist = self.settings.maxDistance
    
    for _, unit in ipairs(units) do
        -- Only check visible units
        if unit.isVisible then
            -- Unit position (use render position for smooth animation)
            local unitX = unit.renderX or unit.x
            local unitZ = unit.renderY or unit.y
            local unitY = 0.5  -- Center height
            
            -- Ray-sphere intersection (treat unit as sphere)
            local dist = self:raySphereIntersect(
                ray.origin, ray.direction,
                {x = unitX, y = unitY, z = unitZ},
                self.settings.unitRadius
            )
            
            if dist and dist < closestDist then
                closestHit = {unit = unit, distance = dist}
                closestDist = dist
            end
        end
    end
    
    return closestHit
end

--- Ray-sphere intersection test
---@param origin table Ray origin {x, y, z}
---@param direction table Ray direction {x, y, z}
---@param center table Sphere center {x, y, z}
---@param radius number Sphere radius
---@return number|nil Distance to intersection
function MousePicking3D:raySphereIntersect(origin, direction, center, radius)
    -- Vector from ray origin to sphere center
    local ocX = origin.x - center.x
    local ocY = origin.y - center.y
    local ocZ = origin.z - center.z
    
    -- Quadratic equation coefficients
    local a = direction.x^2 + direction.y^2 + direction.z^2
    local b = 2 * (ocX * direction.x + ocY * direction.y + ocZ * direction.z)
    local c = ocX^2 + ocY^2 + ocZ^2 - radius^2
    
    -- Discriminant
    local discriminant = b^2 - 4 * a * c
    
    if discriminant < 0 then
        return nil  -- No intersection
    end
    
    -- Calculate distance (nearest intersection)
    local t = (-b - math.sqrt(discriminant)) / (2 * a)
    
    if t < 0 then
        return nil  -- Behind ray origin
    end
    
    return t
end

--- Ray-floor intersection test
---@param ray table Ray {origin, direction}
---@return table|nil Hit result {x, y, distance}
function MousePicking3D:rayIntersectFloor(ray)
    -- Floor is at Y = 0
    local floorY = 0
    
    -- Check if ray hits floor
    if ray.direction.y >= 0 then
        return nil  -- Ray pointing up
    end
    
    -- Calculate intersection distance
    local t = (floorY - ray.origin.y) / ray.direction.y
    
    if t < 0 or t > self.settings.maxDistance then
        return nil
    end
    
    -- Calculate hit position
    local hitX = ray.origin.x + ray.direction.x * t
    local hitZ = ray.origin.z + ray.direction.z * t
    
    return {
        x = math.floor(hitX),
        y = math.floor(hitZ),
        distance = t,
    }
end

--- Ray-wall intersection test
---@param ray table Ray {origin, direction}
---@param battlefield table Battlefield data
---@return table|nil Hit result {x, y, direction, distance}
function MousePicking3D:rayIntersectWalls(ray, battlefield)
    -- Simple implementation: check tiles along ray
    -- For each tile, check all 6 wall directions
    
    local step = 0.5  -- Step size along ray
    local maxSteps = self.settings.maxDistance / step
    
    for i = 0, maxSteps do
        local t = i * step
        local checkX = ray.origin.x + ray.direction.x * t
        local checkY = ray.origin.y + ray.direction.y * t
        local checkZ = ray.origin.z + ray.direction.z * t
        
        -- Check if at wall height (0 to 1)
        if checkY >= 0 and checkY <= 1 then
            local tileX = math.floor(checkX)
            local tileZ = math.floor(checkZ)
            
            -- Check tile walls
            local tile = battlefield:getTile(tileX, tileZ)
            if tile then
                -- Check each wall direction
                for dir = 0, 5 do
                    if tile:hasWall(dir) then
                        -- Simple hit test: if within wall thickness
                        -- (Proper implementation would do precise ray-wall intersection)
                        return {
                            x = tileX,
                            y = tileZ,
                            direction = dir,
                            distance = t,
                        }
                    end
                end
            end
        end
    end
    
    return nil
end

--- Ray-item intersection test
---@param ray table Ray {origin, direction}
---@param items table Array of items on ground
---@return table|nil Hit result {item, distance}
function MousePicking3D:rayIntersectItems(ray, items)
    local closestHit = nil
    local closestDist = self.settings.maxDistance
    
    for _, item in ipairs(items) do
        -- Item position (including slot offset)
        local itemX = item.x + (item.slotOffset and item.slotOffset.x or 0)
        local itemZ = item.y + (item.slotOffset and item.slotOffset.z or 0)
        local itemY = 0.1  -- Just above ground
        
        -- Ray-sphere intersection
        local dist = self:raySphereIntersect(
            ray.origin, ray.direction,
            {x = itemX, y = itemY, z = itemZ},
            self.settings.itemRadius
        )
        
        if dist and dist < closestDist then
            closestHit = {item = item, distance = dist}
            closestDist = dist
        end
    end
    
    return closestHit
end

--- Handle mouse click
---@param button number Mouse button (1=left, 2=right)
---@param callback function Callback(hoveredObject, button)
function MousePicking3D:onClick(button, callback)
    if self.hoveredObject and callback then
        callback(self.hoveredObject, button)
    end
end

--- Get currently hovered object
---@return table|nil Hovered object {type, ...}
function MousePicking3D:getHoveredObject()
    return self.hoveredObject
end

return MousePicking3D

























