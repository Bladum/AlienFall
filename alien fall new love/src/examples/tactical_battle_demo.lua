-- Tactical Battle Demo - XCOM-style tactical combat
-- Features: Grid-based movement, line of sight, fog of war, pathfinding, combat

local TacticalBattle = {}

-- Constants
local GRID_SIZE = 20
local MAP_WIDTH = 30
local MAP_HEIGHT = 25
local SCREEN_WIDTH = 800
local SCREEN_HEIGHT = 600

-- Tile types
local TILE_FLOOR = 0
local TILE_WALL = 1
local TILE_COVER = 2

-- Unit sides
local SIDE_PLAYER = 1
local SIDE_ENEMY = 2

-- Game state
local map = {}
local units = {}
local selectedUnit = nil
local hoveredTile = nil
local fogOfWar = {}
local playerTurn = true
local camera = {x = 0, y = 0, zoom = 1, targetZoom = 1}
local middleMouseDrag = {active = false, startX = 0, startY = 0, startCamX = 0, startCamY = 0}

-- Box2D Physics
local physicsWorld = nil
local bullets = {}
local physicsScale = 20 -- 1 grid unit = 20 pixels = 1 meter in Box2D

-- Pathfinding helpers
local function heuristic(x1, y1, x2, y2)
    return math.abs(x1 - x2) + math.abs(y1 - y2)
end

local function isWalkable(x, y)
    if x < 1 or x > MAP_WIDTH or y < 1 or y > MAP_HEIGHT then
        return false
    end
    return map[y][x] ~= TILE_WALL
end

local function getUnitAt(x, y)
    for _, unit in ipairs(units) do
        if unit.x == x and unit.y == y and unit.alive then
            return unit
        end
    end
    return nil
end

-- A* Pathfinding
local function findPath(startX, startY, endX, endY, maxTU)
    if not isWalkable(endX, endY) or getUnitAt(endX, endY) then
        return nil
    end
    
    local openSet = {{x = startX, y = startY, g = 0, h = 0, f = 0, parent = nil}}
    local closedSet = {}
    local openHash = {[startY * 1000 + startX] = true}
    
    while #openSet > 0 do
        -- Find node with lowest f score
        local currentIdx = 1
        for i = 2, #openSet do
            if openSet[i].f < openSet[currentIdx].f then
                currentIdx = i
            end
        end
        
        local current = table.remove(openSet, currentIdx)
        local hash = current.y * 1000 + current.x
        openHash[hash] = nil
        closedSet[hash] = true
        
        -- Check if reached goal
        if current.x == endX and current.y == endY then
            local path = {}
            local node = current
            while node do
                table.insert(path, 1, {x = node.x, y = node.y})
                node = node.parent
            end
            return path
        end
        
        -- Check neighbors
        local neighbors = {
            {x = current.x + 1, y = current.y},
            {x = current.x - 1, y = current.y},
            {x = current.x, y = current.y + 1},
            {x = current.x, y = current.y - 1}
        }
        
        for _, neighbor in ipairs(neighbors) do
            local nx, ny = neighbor.x, neighbor.y
            local nhash = ny * 1000 + nx
            
            if isWalkable(nx, ny) and not closedSet[nhash] then
                local tentative_g = current.g + 1
                
                -- Check if within TU range
                if maxTU and tentative_g > maxTU then
                    goto continue
                end
                
                if not openHash[nhash] then
                    local h = heuristic(nx, ny, endX, endY)
                    table.insert(openSet, {
                        x = nx, y = ny,
                        g = tentative_g,
                        h = h,
                        f = tentative_g + h,
                        parent = current
                    })
                    openHash[nhash] = true
                end
            end
            ::continue::
        end
    end
    
    return nil -- No path found
end

-- Line of sight using Bresenham's line algorithm
local function hasLineOfSight(x1, y1, x2, y2)
    local dx = math.abs(x2 - x1)
    local dy = math.abs(y2 - y1)
    local sx = x1 < x2 and 1 or -1
    local sy = y1 < y2 and 1 or -1
    local err = dx - dy
    
    local x, y = x1, y1
    
    while true do
        -- Check if hit a wall
        if x ~= x1 or y ~= y1 then -- Don't check starting position
            if not isWalkable(x, y) then
                return false
            end
        end
        
        if x == x2 and y == y2 then
            break
        end
        
        local e2 = 2 * err
        if e2 > -dy then
            err = err - dy
            x = x + sx
        end
        if e2 < dx then
            err = err + dx
            y = y + sy
        end
    end
    
    return true
end

-- Calculate visible tiles from a position
local function calculateVisibility(x, y, range)
    local visible = {}
    for dy = -range, range do
        for dx = -range, range do
            local tx, ty = x + dx, y + dy
            if tx >= 1 and tx <= MAP_WIDTH and ty >= 1 and ty <= MAP_HEIGHT then
                local dist = math.sqrt(dx*dx + dy*dy)
                if dist <= range and hasLineOfSight(x, y, tx, ty) then
                    visible[ty * 1000 + tx] = true
                end
            end
        end
    end
    return visible
end

-- Calculate reachable tiles within TU range
local function calculateReachableTiles(x, y, maxTU)
    local reachable = {}
    reachable[y * 1000 + x] = true -- Starting position
    
    -- Flood fill with TU constraint
    local openSet = {{x = x, y = y, tu = 0}}
    local visited = {[y * 1000 + x] = true}
    
    while #openSet > 0 do
        local current = table.remove(openSet, 1)
        
        -- Check neighbors
        local neighbors = {
            {x = current.x + 1, y = current.y},
            {x = current.x - 1, y = current.y},
            {x = current.x, y = current.y + 1},
            {x = current.x, y = current.y - 1}
        }
        
        for _, neighbor in ipairs(neighbors) do
            local nx, ny = neighbor.x, neighbor.y
            local nhash = ny * 1000 + nx
            local newTU = current.tu + 1
            
            if not visited[nhash] and newTU <= maxTU then
                if nx >= 1 and nx <= MAP_WIDTH and ny >= 1 and ny <= MAP_HEIGHT then
                    if isWalkable(nx, ny) and not getUnitAt(nx, ny) then
                        visited[nhash] = true
                        reachable[nhash] = true
                        table.insert(openSet, {x = nx, y = ny, tu = newTU})
                    end
                end
            end
        end
    end
    
    return reachable
end

-- Update fog of war for all player units
local function updateFogOfWar()
    for _, unit in ipairs(units) do
        if unit.side == SIDE_PLAYER and unit.alive then
            local visible = calculateVisibility(unit.x, unit.y, unit.sightRange)
            for hash, _ in pairs(visible) do
                fogOfWar[hash] = 2 -- Currently visible
            end
        end
    end
end

-- Generate random map
local function generateMap()
    map = {}
    for y = 1, MAP_HEIGHT do
        map[y] = {}
        for x = 1, MAP_WIDTH do
            map[y][x] = TILE_FLOOR
        end
    end
    
    -- Add border walls
    for x = 1, MAP_WIDTH do
        map[1][x] = TILE_WALL
        map[MAP_HEIGHT][x] = TILE_WALL
    end
    for y = 1, MAP_HEIGHT do
        map[y][1] = TILE_WALL
        map[y][MAP_WIDTH] = TILE_WALL
    end
    
    -- Add random obstacles
    local numObstacles = math.random(15, 30)
    for i = 1, numObstacles do
        local x = math.random(3, MAP_WIDTH - 2)
        local y = math.random(3, MAP_HEIGHT - 2)
        local width = math.random(1, 3)
        local height = math.random(1, 3)
        
        for dy = 0, height - 1 do
            for dx = 0, width - 1 do
                if x + dx <= MAP_WIDTH and y + dy <= MAP_HEIGHT then
                    map[y + dy][x + dx] = TILE_WALL
                end
            end
        end
    end
    
    -- Add some cover (low obstacles)
    local numCovers = math.random(10, 20)
    for i = 1, numCovers do
        local x = math.random(3, MAP_WIDTH - 2)
        local y = math.random(3, MAP_HEIGHT - 2)
        if map[y][x] == TILE_FLOOR then
            map[y][x] = TILE_COVER
        end
    end
end

-- Spawn units
local function spawnUnits()
    units = {}
    
    -- Spawn player units (left side)
    for i = 1, 4 do
        local y = 5 + (i - 1) * 5
        local unit = {
            id = #units + 1,
            x = 3,
            y = y,
            side = SIDE_PLAYER,
            health = 50,
            maxHealth = 50,
            tu = 14,
            maxTU = 14,
            accuracy = 70,
            damage = 15,
            sightRange = 10,
            alive = true,
            name = "Soldier " .. i,
            body = nil -- Physics body will be created in initPhysics
        }
        table.insert(units, unit)
    end
    
    -- Spawn enemy units (right side)
    for i = 1, 4 do
        local y = 5 + (i - 1) * 5
        local unit = {
            id = #units + 1,
            x = MAP_WIDTH - 3,
            y = y,
            side = SIDE_ENEMY,
            health = 40,
            maxHealth = 40,
            tu = 12,
            maxTU = 12,
            accuracy = 60,
            damage = 12,
            sightRange = 9,
            alive = true,
            name = "Alien " .. i,
            body = nil -- Physics body will be created in initPhysics
        }
        table.insert(units, unit)
    end
end

-- Initialize Box2D physics
local function initPhysics()
    love.physics.setMeter(1) -- 1 meter = 1 grid unit
    physicsWorld = love.physics.newWorld(0, 0, true) -- No gravity
    
    -- Create static bodies for walls (Love2D 12.0 API - shapes attached directly to bodies)
    for y = 1, MAP_HEIGHT do
        for x = 1, MAP_WIDTH do
            if map[y][x] == TILE_WALL or map[y][x] == TILE_COVER then
                local body = love.physics.newBody(physicsWorld, x, y, "static")
                love.physics.newRectangleShape(body, 0.8, 0.8) -- Shape takes body as first parameter
                body:setUserData({type = "obstacle", tile = map[y][x]})
            end
        end
    end
    
    -- Create static bodies for units (Love2D 12.0 API - shapes attached directly to bodies)
    for _, unit in ipairs(units) do
        unit.body = love.physics.newBody(physicsWorld, unit.x, unit.y, "static")
        love.physics.newCircleShape(unit.body, 0.3) -- Shape takes body as first parameter
        unit.body:setUserData({type = "unit", unit = unit})
    end
end

-- Create a bullet projectile
local function createBullet(fromX, fromY, toX, toY, damage, attacker)
    local dx = toX - fromX
    local dy = toY - fromY
    local distance = math.sqrt(dx*dx + dy*dy)
    local speed = 30 -- Grid units per second
    
    local vx = (dx / distance) * speed
    local vy = (dy / distance) * speed
    
    local bullet = {
        body = love.physics.newBody(physicsWorld, fromX, fromY, "dynamic"),
        damage = damage,
        attacker = attacker,
        lifetime = 3.0, -- Maximum 3 seconds before despawn
        hit = false
    }
    
    -- Attach shape directly to body (Love2D 12.0 API)
    love.physics.newCircleShape(bullet.body, 0.1) -- Small bullet shape
    bullet.body:setUserData({type = "bullet", bullet = bullet})
    
    bullet.body:setLinearVelocity(vx, vy)
    bullet.body:setBullet(true) -- Enable continuous collision detection
    
    table.insert(bullets, bullet)
    return bullet
end

-- Initialize fog of war
local function initFogOfWar()
    fogOfWar = {}
    for y = 1, MAP_HEIGHT do
        for x = 1, MAP_WIDTH do
            fogOfWar[y * 1000 + x] = 0 -- Unexplored
        end
    end
    updateFogOfWar()
end

-- Combat
local function attackUnit(attacker, target)
    if attacker.tu < 6 then
        return false, "Not enough TU"
    end
    
    -- Check line of fire
    if not hasLineOfSight(attacker.x, attacker.y, target.x, target.y) then
        return false, "No line of fire"
    end
    
    -- Calculate distance
    local dx = target.x - attacker.x
    local dy = target.y - attacker.y
    local distance = math.sqrt(dx*dx + dy*dy)
    
    -- Accuracy decreases with distance
    local hitChance = attacker.accuracy - (distance * 3)
    hitChance = math.max(10, math.min(95, hitChance))
    
    attacker.tu = attacker.tu - 6
    
    -- Create bullet projectile
    createBullet(attacker.x, attacker.y, target.x, target.y, attacker.damage, attacker)
    
    -- Store hit chance for bullet collision
    local bullet = bullets[#bullets]
    bullet.target = target
    bullet.hitChance = hitChance
    
    return true, "Firing..."
end

-- Move unit
local function moveUnit(unit, path)
    if #path <= 1 then return end
    
    local tuCost = #path - 1
    if unit.tu < tuCost then
        -- Move as far as possible
        local maxSteps = math.min(unit.tu, #path - 1)
        for i = 2, maxSteps + 1 do
            unit.x = path[i].x
            unit.y = path[i].y
            unit.tu = unit.tu - 1
        end
    else
        -- Move full path
        unit.x = path[#path].x
        unit.y = path[#path].y
        unit.tu = unit.tu - tuCost
    end
    
    -- Update physics body position
    if unit.body then
        unit.body:setPosition(unit.x, unit.y)
    end
    
    updateFogOfWar()
end

-- End turn
local function endTurn()
    playerTurn = not playerTurn
    
    -- Restore TU for active side
    for _, unit in ipairs(units) do
        if unit.side == (playerTurn and SIDE_PLAYER or SIDE_ENEMY) and unit.alive then
            unit.tu = unit.maxTU
        end
    end
    
    -- Simple AI for enemy turn
    if not playerTurn then
        -- AI takes actions
        love.timer.sleep(0.5)
        
        for _, unit in ipairs(units) do
            if unit.side == SIDE_ENEMY and unit.alive then
                -- Find closest player unit
                local closestTarget = nil
                local closestDist = 999999
                
                for _, target in ipairs(units) do
                    if target.side == SIDE_PLAYER and target.alive then
                        local dx = target.x - unit.x
                        local dy = target.y - unit.y
                        local dist = math.sqrt(dx*dx + dy*dy)
                        if dist < closestDist and hasLineOfSight(unit.x, unit.y, target.x, target.y) then
                            closestDist = dist
                            closestTarget = target
                        end
                    end
                end
                
                -- Attack if in range, otherwise move closer
                if closestTarget then
                    if closestDist <= 8 then
                        attackUnit(unit, closestTarget)
                    else
                        -- Try to move closer
                        local path = findPath(unit.x, unit.y, closestTarget.x, closestTarget.y, unit.tu)
                        if path and #path > 1 then
                            moveUnit(unit, path)
                        end
                    end
                end
            end
        end
        
        -- End enemy turn
        endTurn()
    end
end

-- Initialize
function TacticalBattle.load()
    love.window.setTitle("Tactical Battle Demo - XCOM Style")
    generateMap()
    spawnUnits()
    initPhysics()
    initFogOfWar()
    selectedUnit = nil
end

-- Collision callback for Box2D
function TacticalBattle.beginContact(a, b, contact)
    local dataA = a:getUserData()
    local dataB = b:getUserData()
    
    if not dataA or not dataB then return end
    
    -- Check if bullet hit something
    local bullet, target = nil, nil
    if dataA.type == "bullet" and dataB.type == "unit" then
        bullet = dataA.bullet
        target = dataB.unit
    elseif dataB.type == "bullet" and dataA.type == "unit" then
        bullet = dataB.bullet
        target = dataA.unit
    elseif dataA.type == "bullet" and dataB.type == "obstacle" then
        bullet = dataA.bullet
        bullet.hit = true
        print("Bullet hit obstacle!")
    elseif dataB.type == "bullet" and dataA.type == "obstacle" then
        bullet = dataB.bullet
        bullet.hit = true
        print("Bullet hit obstacle!")
    end
    
    if bullet and target and target.alive and not bullet.hit then
        -- Check if this is the intended target or friendly fire
        if target == bullet.target then
            -- Roll to hit
            if math.random(100) <= bullet.hitChance then
                target.health = target.health - bullet.damage
                if target.health <= 0 then
                    target.health = 0
                    target.alive = false
                end
                print("Hit! Damage: " .. bullet.damage .. " | " .. target.name .. " Health: " .. target.health)
            else
                print("Miss!")
            end
        end
        bullet.hit = true
    end
end

-- Update
function TacticalBattle.update(dt)
    -- Update physics world
    if physicsWorld then
        physicsWorld:update(dt)
    end
    
    -- Update bullets
    for i = #bullets, 1, -1 do
        local bullet = bullets[i]
        bullet.lifetime = bullet.lifetime - dt
        
        -- Remove bullets that hit or expired
        if bullet.hit or bullet.lifetime <= 0 then
            if bullet.body then
                bullet.body:destroy()
            end
            table.remove(bullets, i)
        end
    end
    
    -- Smooth zoom
    camera.zoom = camera.zoom + (camera.targetZoom - camera.zoom) * 10 * dt
    
    -- Camera follows selected unit (when not dragging)
    if selectedUnit and not middleMouseDrag.active then
        local targetX = -selectedUnit.x * GRID_SIZE * camera.zoom + SCREEN_WIDTH / 2
        local targetY = -selectedUnit.y * GRID_SIZE * camera.zoom + SCREEN_HEIGHT / 2
        camera.x = camera.x + (targetX - camera.x) * 5 * dt
        camera.y = camera.y + (targetY - camera.y) * 5 * dt
    end
end

-- Mouse handling
function TacticalBattle.mousepressed(x, y, button)
    if not playerTurn then return end
    
    -- Middle mouse - start drag
    if button == 3 then
        middleMouseDrag.active = true
        middleMouseDrag.startX = x
        middleMouseDrag.startY = y
        middleMouseDrag.startCamX = camera.x
        middleMouseDrag.startCamY = camera.y
        return
    end
    
    -- Convert screen to grid coordinates
    local gridX = math.floor((x - camera.x) / (GRID_SIZE * camera.zoom)) + 1
    local gridY = math.floor((y - camera.y) / (GRID_SIZE * camera.zoom)) + 1
    
    if gridX < 1 or gridX > MAP_WIDTH or gridY < 1 or gridY > MAP_HEIGHT then
        return
    end
    
    if button == 1 then -- Left click - select unit
        local unit = getUnitAt(gridX, gridY)
        if unit and unit.side == SIDE_PLAYER and unit.alive then
            selectedUnit = unit
        end
    elseif button == 2 then -- Right click - move or attack
        if selectedUnit and selectedUnit.alive then
            local target = getUnitAt(gridX, gridY)
            
            if target and target.side ~= selectedUnit.side then
                -- Attack
                local success, msg = attackUnit(selectedUnit, target)
                print(msg)
            else
                -- Move
                local path = findPath(selectedUnit.x, selectedUnit.y, gridX, gridY, selectedUnit.tu)
                if path then
                    moveUnit(selectedUnit, path)
                end
            end
        end
    end
end

function TacticalBattle.mousereleased(x, y, button)
    if button == 3 then
        middleMouseDrag.active = false
    end
end

function TacticalBattle.mousemoved(x, y)
    -- Handle middle mouse drag
    if middleMouseDrag.active then
        local dx = x - middleMouseDrag.startX
        local dy = y - middleMouseDrag.startY
        camera.x = middleMouseDrag.startCamX + dx
        camera.y = middleMouseDrag.startCamY + dy
    end
    
    -- Update hovered tile
    hoveredTile = {
        x = math.floor((x - camera.x) / (GRID_SIZE * camera.zoom)) + 1,
        y = math.floor((y - camera.y) / (GRID_SIZE * camera.zoom)) + 1
    }
end

function TacticalBattle.wheelmoved(x, y)
    -- Zoom in/out
    local oldZoom = camera.targetZoom
    camera.targetZoom = camera.targetZoom + y * 0.1
    camera.targetZoom = math.max(0.5, math.min(3, camera.targetZoom))
    
    -- Zoom towards mouse cursor
    local mouseX, mouseY = love.mouse.getPosition()
    local worldX = (mouseX - camera.x) / oldZoom
    local worldY = (mouseY - camera.y) / oldZoom
    
    camera.x = mouseX - worldX * camera.targetZoom
    camera.y = mouseY - worldY * camera.targetZoom
end

-- Keyboard
function TacticalBattle.keypressed(key)
    if key == "space" then
        endTurn()
    elseif key == "escape" then
        selectedUnit = nil
    end
end

-- Draw
function TacticalBattle.draw()
    love.graphics.push()
    love.graphics.translate(camera.x, camera.y)
    love.graphics.scale(camera.zoom, camera.zoom)
    
    -- Calculate reachable tiles for selected unit
    local reachableTiles = {}
    if selectedUnit and selectedUnit.alive then
        reachableTiles = calculateReachableTiles(selectedUnit.x, selectedUnit.y, selectedUnit.tu)
    end
    
    -- Draw grid and map
    for y = 1, MAP_HEIGHT do
        for x = 1, MAP_WIDTH do
            local screenX = (x - 1) * GRID_SIZE
            local screenY = (y - 1) * GRID_SIZE
            local fogState = fogOfWar[y * 1000 + x] or 0
            
            -- Draw tile
            if fogState > 0 then
                local tile = map[y][x]
                
                if tile == TILE_FLOOR then
                    love.graphics.setColor(0.3, 0.3, 0.3, 1)
                    love.graphics.rectangle("fill", screenX, screenY, GRID_SIZE, GRID_SIZE)
                elseif tile == TILE_WALL then
                    love.graphics.setColor(0.5, 0.5, 0.5, 1)
                    love.graphics.rectangle("fill", screenX, screenY, GRID_SIZE, GRID_SIZE)
                elseif tile == TILE_COVER then
                    love.graphics.setColor(0.4, 0.35, 0.3, 1)
                    love.graphics.rectangle("fill", screenX, screenY, GRID_SIZE, GRID_SIZE)
                end
                
                -- Grid lines
                love.graphics.setColor(0.2, 0.2, 0.2, 1)
                love.graphics.rectangle("line", screenX, screenY, GRID_SIZE, GRID_SIZE)
            else
                -- Fog of war
                love.graphics.setColor(0.1, 0.1, 0.1, 1)
                love.graphics.rectangle("fill", screenX, screenY, GRID_SIZE, GRID_SIZE)
            end
            
            -- Darken if not currently visible
            if fogState == 1 then
                love.graphics.setColor(0, 0, 0, 0.5)
                love.graphics.rectangle("fill", screenX, screenY, GRID_SIZE, GRID_SIZE)
            end
            
            -- Draw movement range overlay
            if reachableTiles[y * 1000 + x] and fogState > 0 then
                love.graphics.setColor(0.3, 1, 0.3, 0.25)
                love.graphics.rectangle("fill", screenX, screenY, GRID_SIZE, GRID_SIZE)
            end
        end
    end
    
    -- Draw units
    for _, unit in ipairs(units) do
        if unit.alive then
            local fogState = fogOfWar[unit.y * 1000 + unit.x] or 0
            
            -- Only draw if visible to player
            if unit.side == SIDE_PLAYER or fogState == 2 then
                local screenX = (unit.x - 1) * GRID_SIZE + GRID_SIZE / 2
                local screenY = (unit.y - 1) * GRID_SIZE + GRID_SIZE / 2
                
                -- Unit circle
                if unit.side == SIDE_PLAYER then
                    love.graphics.setColor(0.2, 0.6, 1, 1)
                else
                    love.graphics.setColor(1, 0.3, 0.3, 1)
                end
                love.graphics.circle("fill", screenX, screenY, GRID_SIZE / 3)
                
                -- Selection highlight
                if unit == selectedUnit then
                    love.graphics.setColor(1, 1, 0, 1)
                    love.graphics.circle("line", screenX, screenY, GRID_SIZE / 2.5)
                end
                
                -- Health bar
                local barWidth = GRID_SIZE - 4
                local barHeight = 3
                local healthPct = unit.health / unit.maxHealth
                
                love.graphics.setColor(0.2, 0.2, 0.2, 1)
                love.graphics.rectangle("fill", screenX - barWidth/2, screenY - GRID_SIZE/2 + 2, barWidth, barHeight)
                
                love.graphics.setColor(0, 1, 0, 1)
                love.graphics.rectangle("fill", screenX - barWidth/2, screenY - GRID_SIZE/2 + 2, barWidth * healthPct, barHeight)
            end
        end
    end
    
    -- Draw bullets
    for _, bullet in ipairs(bullets) do
        if bullet.body then
            local bx, by = bullet.body:getPosition()
            local screenX = (bx - 1) * GRID_SIZE + GRID_SIZE / 2
            local screenY = (by - 1) * GRID_SIZE + GRID_SIZE / 2
            
            love.graphics.setColor(1, 1, 0, 1)
            love.graphics.circle("fill", screenX, screenY, 3)
            
            -- Draw trail
            local vx, vy = bullet.body:getLinearVelocity()
            if vx ~= 0 or vy ~= 0 then
                local trailLen = 8
                local angle = math.atan2(vy, vx)
                local tx = screenX - math.cos(angle) * trailLen
                local ty = screenY - math.sin(angle) * trailLen
                love.graphics.setColor(1, 0.8, 0, 0.6)
                love.graphics.line(screenX, screenY, tx, ty)
            end
        end
    end
    
    -- Draw hover highlight
    if hoveredTile then
        local screenX = (hoveredTile.x - 1) * GRID_SIZE
        local screenY = (hoveredTile.y - 1) * GRID_SIZE
        love.graphics.setColor(1, 1, 1, 0.3)
        love.graphics.rectangle("fill", screenX, screenY, GRID_SIZE, GRID_SIZE)
    end
    
    love.graphics.pop()
    
    -- Draw UI
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("TACTICAL BATTLE DEMO", 10, 10)
    love.graphics.print("Turn: " .. (playerTurn and "PLAYER" or "ENEMY"), 10, 30)
    love.graphics.print("Zoom: " .. string.format("%.1fx", camera.zoom), 10, 50)
    
    if selectedUnit then
        local infoY = 70
        love.graphics.print(selectedUnit.name, 10, infoY)
        love.graphics.print("Health: " .. selectedUnit.health .. "/" .. selectedUnit.maxHealth, 10, infoY + 20)
        love.graphics.print("TU: " .. selectedUnit.tu .. "/" .. selectedUnit.maxTU, 10, infoY + 40)
        love.graphics.print("Accuracy: " .. selectedUnit.accuracy, 10, infoY + 60)
    end
    
    love.graphics.print("LMB: Select Unit", 10, SCREEN_HEIGHT - 110)
    love.graphics.print("RMB: Move/Attack", 10, SCREEN_HEIGHT - 90)
    love.graphics.print("MMB: Pan Camera", 10, SCREEN_HEIGHT - 70)
    love.graphics.print("Wheel: Zoom", 10, SCREEN_HEIGHT - 50)
    love.graphics.print("SPACE: End Turn", 10, SCREEN_HEIGHT - 30)
end

return TacticalBattle
