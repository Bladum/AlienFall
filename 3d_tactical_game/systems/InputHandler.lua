--- InputHandler.lua
--- Handles all keyboard, mouse, and game controller input for the 3D tactical game
--- Provides camera controls, unit selection, and action commands

local InputHandler = {}

local Constants = require("config.constants")

-- Module state
local mouseX, mouseY = 0, 0
local mouseDragStart = nil
local isMouseDragging = false
local cameraSpeed = 10.0  -- Units per second
local zoomSpeed = 5.0
local rotationSpeed = 2.0

-- Camera state (for smooth movement)
local cameraVelocity = {x = 0, y = 0, z = 0}
local cameraRotationVelocity = 0

--- Initialize the input handler
function InputHandler.init()
    print("InputHandler: Initialized")
end

--- Update input state and process continuous inputs (called each frame)
--- @param dt number Delta time in seconds
--- @param camera table The G3D camera object
--- @param game table The game state object
function InputHandler.update(dt, camera, game)
    -- Only process movement if a unit is selected
    if not game or not game.selectedUnit then
        return
    end
    
    local unit = game.selectedUnit
    local moveSpeed = 5.0  -- Grid units per second
    local rotateSpeed = 3.0  -- Radians per second
    
    -- Store unit's current facing direction (default to 0 if not set)
    unit.facing = unit.facing or 0
    
    -- Q/E for unit rotation
    if love.keyboard.isDown("q") then
        unit.facing = unit.facing - rotateSpeed * dt
    end
    if love.keyboard.isDown("e") then
        unit.facing = unit.facing + rotateSpeed * dt
    end
    
    -- WASD for unit movement (relative to unit facing)
    local moveX = 0
    local moveZ = 0
    
    if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
        -- Move forward in facing direction
        moveX = moveX + math.sin(unit.facing) * moveSpeed * dt
        moveZ = moveZ - math.cos(unit.facing) * moveSpeed * dt
    end
    if love.keyboard.isDown("s") or love.keyboard.isDown("down") then
        -- Move backward
        moveX = moveX - math.sin(unit.facing) * moveSpeed * dt
        moveZ = moveZ + math.cos(unit.facing) * moveSpeed * dt
    end
    if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
        -- Strafe left
        moveX = moveX - math.cos(unit.facing) * moveSpeed * dt
        moveZ = moveZ - math.sin(unit.facing) * moveSpeed * dt
    end
    if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
        -- Strafe right
        moveX = moveX + math.cos(unit.facing) * moveSpeed * dt
        moveZ = moveZ + math.sin(unit.facing) * moveSpeed * dt
    end
    
    -- Apply movement to unit
    if moveX ~= 0 or moveZ ~= 0 then
        InputHandler.moveUnit(unit, moveX, moveZ, game.map)
    end
    
    -- Update camera to follow selected unit
    InputHandler.updateCameraToFollowUnit(camera, unit, dt)
end

--- Move a unit with collision detection
--- @param unit table The unit to move
--- @param dx number Movement in X (grid units)
--- @param dz number Movement in Z (grid units)
--- @param map table The game map
function InputHandler.moveUnit(unit, dx, dz, map)
    -- Calculate new position
    local newGridX = unit.gridX + dx
    local newGridZ = unit.gridY + dz
    
    -- Round to nearest grid position
    local targetGridX = math.floor(newGridX + 0.5)
    local targetGridZ = math.floor(newGridZ + 0.5)
    
    -- Check if target position is valid
    if targetGridX < 1 or targetGridX > map.width or targetGridZ < 1 or targetGridZ > map.height then
        return  -- Out of bounds
    end
    
    local targetTile = map.tiles[targetGridZ][targetGridX]
    
    -- Check if tile is walkable (not a wall and not occupied)
    if targetTile and targetTile:isTraversable() and not targetTile:isOccupied() then
        -- Update unit position (smooth movement, not grid-locked)
        unit.gridX = newGridX
        unit.gridY = newGridZ
        
        -- Update grid position if crossed into new tile
        local currentTileX = math.floor(unit.gridX + 0.5)
        local currentTileZ = math.floor(unit.gridY + 0.5)
        
        if currentTileX ~= unit.tileX or currentTileZ ~= unit.tileY then
            -- Clear old tile occupant
            if unit.tileX and unit.tileY and map.tiles[unit.tileY] and map.tiles[unit.tileY][unit.tileX] then
                map.tiles[unit.tileY][unit.tileX]:setOccupant(nil)
            end
            
            -- Set new tile occupant
            unit.tileX = currentTileX
            unit.tileY = currentTileZ
            if map.tiles[unit.tileY] and map.tiles[unit.tileY][unit.tileX] then
                map.tiles[unit.tileY][unit.tileX]:setOccupant(unit)
            end
        end
    end
end

--- Update camera to be positioned at the unit's eye level (first-person view)
--- @param camera table The G3D camera object
--- @param unit table The unit to follow
--- @param dt number Delta time
function InputHandler.updateCameraToFollowUnit(camera, unit, dt)
    if not unit then return end
    
    -- First-person camera: positioned at unit's eye level
    local eyeHeight = 1.7  -- Standard human eye height in meters/units
    local lookDistance = 5.0  -- How far ahead to look
    
    -- Camera position: at unit's location, eye level
    camera.position[1] = unit.gridX
    camera.position[2] = eyeHeight
    camera.position[3] = unit.gridY
    
    -- Look target: in the direction the unit is facing
    local facing = unit.facing or 0
    camera.target[1] = unit.gridX + math.sin(facing) * lookDistance
    camera.target[2] = eyeHeight  -- Look at eye level
    camera.target[3] = unit.gridY + math.cos(facing) * lookDistance
    
    camera:updateViewMatrix()
end



--- Handle key press events
--- @param key string The key that was pressed
--- @param game table The game state object
function InputHandler.keypressed(key, game)
    if key == "escape" then
        love.event.quit()
    elseif key == "space" then
        -- Cycle to next unit
        InputHandler.selectNextUnit(game)
    elseif key == "tab" then
        -- Toggle minimap size
        if game.minimapScale then
            game.minimapScale = game.minimapScale == 1.0 and 2.0 or 1.0
        end
    elseif key == "m" then
        -- Toggle minimap visibility
        game.showMinimap = not (game.showMinimap or false)
    end
end

--- Handle mouse press events
--- @param x number Mouse X position
--- @param y number Mouse Y position
--- @param button number Mouse button (1=left, 2=right, 3=middle)
--- @param game table The game state object
function InputHandler.mousepressed(x, y, button, game)
    mouseX, mouseY = x, y
    
    if button == 1 then
        -- Left click - select unit or tile
        -- TODO: Implement raycasting to select units/tiles
    elseif button == 2 then
        -- Right click - start camera drag
        mouseDragStart = {x = x, y = y}
        isMouseDragging = true
    end
end

--- Handle mouse release events
--- @param x number Mouse X position
--- @param y number Mouse Y position
--- @param button number Mouse button
--- @param game table The game state object
function InputHandler.mousereleased(x, y, button, game)
    if button == 2 then
        -- End camera drag
        isMouseDragging = false
        mouseDragStart = nil
    end
end

--- Handle mouse movement
--- @param x number Mouse X position
--- @param y number Mouse Y position
--- @param dx number Mouse X delta
--- @param dy number Mouse Y delta
--- @param camera table The G3D camera object
function InputHandler.mousemoved(x, y, dx, dy, camera)
    mouseX, mouseY = x, y
    
    if isMouseDragging and mouseDragStart then
        -- Drag to rotate camera
        local sensitivity = 0.005
        InputHandler.rotateCamera(camera, -dx * sensitivity)
        
        -- Adjust camera height based on vertical drag
        camera.position[2] = camera.position[2] - dy * 0.02
        camera.target[2] = camera.target[2] - dy * 0.02
    end
end

--- Handle mouse wheel scrolling
--- @param x number Horizontal scroll amount
--- @param y number Vertical scroll amount
--- @param camera table The G3D camera object
function InputHandler.wheelmoved(x, y, camera)
    -- Zoom camera in/out
    local zoomAmount = y * zoomSpeed * 0.5
    
    -- Move camera toward/away from target
    local dx = camera.target[1] - camera.position[1]
    local dy = camera.target[2] - camera.position[2]
    local dz = camera.target[3] - camera.position[3]
    local length = math.sqrt(dx * dx + dy * dy + dz * dz)
    
    if length > 0.001 then
        local scale = zoomAmount / length
        camera.position[1] = camera.position[1] + dx * scale
        camera.position[2] = camera.position[2] + dy * scale
        camera.position[3] = camera.position[3] + dz * scale
        
        -- Don't let camera get too close or too far
        local newLength = math.sqrt(
            (camera.target[1] - camera.position[1])^2 +
            (camera.target[2] - camera.position[2])^2 +
            (camera.target[3] - camera.position[3])^2
        )
        
        if newLength < 2.0 or newLength > 50.0 then
            -- Undo zoom if out of bounds
            camera.position[1] = camera.position[1] - dx * scale
            camera.position[2] = camera.position[2] - dy * scale
            camera.position[3] = camera.position[3] - dz * scale
        end
    end
end

--- Select the next unit in the player's team
--- @param game table The game state object
function InputHandler.selectNextUnit(game)
    local playerTeam = game.teams[Constants.TEAM.PLAYER]
    if not playerTeam or #playerTeam.units == 0 then
        return
    end
    
    -- Find current selected unit index
    local currentIndex = 0
    for i, unit in ipairs(playerTeam.units) do
        if unit == game.selectedUnit then
            currentIndex = i
            break
        end
    end
    
    -- Select next unit (wrap around)
    local nextIndex = (currentIndex % #playerTeam.units) + 1
    game.selectedUnit = playerTeam.units[nextIndex]
    
    -- print(string.format("Selected unit %d at (%d, %d)", nextIndex, game.selectedUnit.gridX, game.selectedUnit.gridY))
end

--- Get current mouse position
--- @return number, number Mouse X and Y coordinates
function InputHandler.getMousePosition()
    return mouseX, mouseY
end

--- Check if mouse is currently dragging
--- @return boolean True if dragging
function InputHandler.isMouseDragging()
    return isMouseDragging
end

return InputHandler
