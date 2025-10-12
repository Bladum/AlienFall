-- Main game file for Tactical Chess
local Constants = require("src.core.constants")
local Board = require("src.board.board")
local Camera = require("src.camera.camera")
local Pawn = require("src.pieces.pawn")
local Rook = require("src.pieces.rook")
local Bishop = require("src.pieces.bishop")
local Knight = require("src.pieces.knight")
local Queen = require("src.pieces.queen")
local King = require("src.pieces.king")

-- Game state
local game = {
    board = nil,
    camera = nil,
    players = {},
    currentPlayerIndex = 1,
    selectedPiece = nil,
    validMoves = {},
    gameState = "playing", -- playing, won, lost
    turnNumber = 1
}
-- Animation guard: when true, input is blocked
game.animationActive = false
game._activeAnims = 0

-- UI layout
local UI = {
    sidebar_width = 260,
    bottom_height = 100,
    minimap_size = 200,
    button_height = 28,
    button_padding = 8
}

function love.load()
    print("=== Tactical Chess Game Starting ===")
    
    -- Set up graphics
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setLineStyle("rough")
    
    -- Create board (wider than tall, 15% obstacles)
        game.board = Board.new(40, 28, 0.15) -- 40x28 board with ~15% obstacles
    
    -- Create camera
    game.camera = Camera.new(0, 0, 1.0)
    game.camera:setBounds(game.board.width, game.board.height, Constants.TILE_SIZE)
    
    -- Add some control points
    game.board:addControlPoint(3, 3)
    game.board:addControlPoint(10, 3)
    game.board:addControlPoint(3, 10)
    game.board:addControlPoint(10, 10)
    game.board:addControlPoint(6, 6)
    
    -- Initialize players
    initializePlayers()
    
    -- Place starting pieces for player 1 (top-left)
    placeStartingPieces(1, 2, 2)
    
    -- Place starting pieces for player 2 (bottom-right)
    placeStartingPieces(2, game.board.width - 1, game.board.height - 1)
    
    -- Reveal fog of war for current player
    updateFogOfWar()
    
    print("Board created: " .. game.board.width .. "x" .. game.board.height)
    print("Players: " .. #game.players)
    print("Use middle mouse to pan, mouse wheel to zoom")
    print("Click pieces to select, click destination to move")
end

function initializePlayers()
    -- Create 2 players for now
    for i = 1, 2 do
        table.insert(game.players, {
            id = i,
            resources = Constants.STARTING_RESOURCES,
            tu = Constants.DEFAULT_TU_PER_TURN,
            pieces = {},
            controlPoints = 1,
            color = Constants.PLAYER_COLORS[i]
        })
    end
end

function placeStartingPieces(playerId, startX, startY)
    local player = game.players[playerId]
    -- Helper: find nearest free walkable tile (BFS)
    local function findNearestFree(x, y)
        if game.board:isWalkable(x, y) and not game.board:isOccupied(x, y) then
            return x, y
        end
        local visited = {}
        local queue = {{x = x, y = y}}
        visited[y .. ',' .. x] = true
        local dirs = {{1,0},{-1,0},{0,1},{0,-1},{1,1},{1,-1},{-1,1},{-1,-1}}
        while #queue > 0 do
            local cur = table.remove(queue, 1)
            for _, d in ipairs(dirs) do
                local nx, ny = cur.x + d[1], cur.y + d[2]
                if game.board:isValidPosition(nx, ny) and not visited[ny .. ',' .. nx] then
                    visited[ny .. ',' .. nx] = true
                    if game.board:isWalkable(nx, ny) and not game.board:isOccupied(nx, ny) then
                        return nx, ny
                    end
                    table.insert(queue, {x = nx, y = ny})
                end
            end
        end
        return x, y
    end

    -- Place king
    -- Attempt to clear a small area around spawn to ensure playability
    for dy = -1, 1 do
        for dx = -1, 1 do
            local cx, cy = startX + dx, startY + dy
            if game.board:isValidPosition(cx, cy) then
                game.board.tiles[cy][cx].tileType = Constants.TILE_TYPES.NORMAL
            end
        end
    end
    local kx, ky = findNearestFree(startX, startY)
    local king = King.new(kx, ky, playerId)
    game.board:setPiece(kx, ky, king)
    table.insert(player.pieces, king)

    -- Place some starting pieces around king
    local px1, py1 = findNearestFree(kx + 1, ky)
    local pawn1 = Pawn.new(px1, py1, playerId)
    game.board:setPiece(px1, py1, pawn1)
    table.insert(player.pieces, pawn1)

    local px2, py2 = findNearestFree(kx, ky + 1)
    local pawn2 = Pawn.new(px2, py2, playerId)
    game.board:setPiece(px2, py2, pawn2)
    table.insert(player.pieces, pawn2)

    local rx, ry = findNearestFree(kx - 1, ky)
    local rook = Rook.new(rx, ry, playerId)
    game.board:setPiece(rx, ry, rook)
    table.insert(player.pieces, rook)

    local nx, ny = findNearestFree(kx, ky - 1)
    local knight = Knight.new(nx, ny, playerId)
    game.board:setPiece(nx, ny, knight)
    table.insert(player.pieces, knight)
end

function updateFogOfWar()
    local currentPlayer = game.players[game.currentPlayerIndex]
    game.board:clearFogForPlayer(currentPlayer.id, currentPlayer.pieces)
    -- Debug: count fog states after update to verify it changed
    local vis, exp, hid = 0, 0, 0
    for yy = 1, game.board.height do
        for xx = 1, game.board.width do
            local t = game.board.tiles[yy][xx]
            local fs = nil
            if t and t.getFogState then fs = t:getFogState(currentPlayer.id) end
            if fs == Constants.FOW_VISIBLE then vis = vis + 1
            elseif fs == Constants.FOW_EXPLORED then exp = exp + 1
            else hid = hid + 1 end
        end
    end
    print(string.format("Fog update for player %d: visible=%d, explored=%d, hidden=%d", currentPlayer.id, vis, exp, hid))
end

function love.update(dt)
    game.camera:update(dt)
    -- update piece animations
    for _, player in ipairs(game.players) do
        for _, piece in ipairs(player.pieces) do
            if piece and piece.update then piece:update(dt) end
        end
    end
end

function love.draw()
    -- Draw sidebar background first (so it doesn't overlap board)
    drawSidebarBackground()

    -- Translate camera for map area so UI won't overlap it
    love.graphics.push()
    love.graphics.translate(UI.sidebar_width, 0)
    -- Draw board and pieces (pass current player id so pieces can render moved state)
    game.board:draw(game.camera, game.currentPlayerIndex)

    -- Highlight valid moves (map coordinates are inside the translated context)
    if game.selectedPiece and #game.validMoves > 0 then
        -- draw path previews
        for _, move in ipairs(game.validMoves) do
            local path = game.board:findPath(game.selectedPiece.x, game.selectedPiece.y, move.x, move.y, true, true)
            if path then
                for _, p in ipairs(path) do
                    local sx, sy = game.camera:worldToScreen((p.x - 1) * Constants.TILE_SIZE, (p.y - 1) * Constants.TILE_SIZE)
                    local col = Constants.VISUALS.path_preview_color
                    love.graphics.setColor(col.r, col.g, col.b, col.a)
                    love.graphics.rectangle("fill", sx, sy, Constants.TILE_SIZE * game.camera.zoom, Constants.TILE_SIZE * game.camera.zoom)
                end
            end
        end
        love.graphics.setColor(1,1,1)
        -- then draw valid moves overlay
        for _, move in ipairs(game.validMoves) do
            local screenX, screenY = game.camera:worldToScreen(
                (move.x - 1) * Constants.TILE_SIZE,
                (move.y - 1) * Constants.TILE_SIZE
            )

            -- Check if it's an attack move
            local isAttack = game.board:isOccupied(move.x, move.y)
            local color = isAttack and Constants.UI_COLORS.ATTACK_MOVE or Constants.UI_COLORS.VALID_MOVE

            love.graphics.setColor(color.r, color.g, color.b, color.a)
            love.graphics.rectangle("fill", screenX, screenY,
                Constants.TILE_SIZE * game.camera.zoom,
                Constants.TILE_SIZE * game.camera.zoom)
        end
        love.graphics.setColor(1, 1, 1)
    end

    -- Draw selected piece highlight
        if game.selectedPiece then
            local screenX, screenY = game.camera:worldToScreen(
                (game.selectedPiece.x - 1) * Constants.TILE_SIZE,
                (game.selectedPiece.y - 1) * Constants.TILE_SIZE
            )
        local color = Constants.UI_COLORS.SELECTED
        local alpha = Constants.VISUALS.selection_alpha or color.a or 0.5
        love.graphics.setColor(color.r, color.g, color.b, alpha)
            love.graphics.rectangle("fill", screenX, screenY,
                Constants.TILE_SIZE * game.camera.zoom,
                Constants.TILE_SIZE * game.camera.zoom)
            love.graphics.setColor(1, 1, 1)
        end

    love.graphics.pop()

    -- Sidebar panels (minimap, info, buttons)
    drawSidebarPanels()
end

function drawSidebarBackground()
    local c = Constants.UI_COLORS
    love.graphics.setColor(c.SIDEBAR_BG.r, c.SIDEBAR_BG.g, c.SIDEBAR_BG.b)
    love.graphics.rectangle("fill", 0, 0, UI.sidebar_width, Constants.WINDOW_HEIGHT)

    love.graphics.setColor(c.SIDEBAR_BORDER.r, c.SIDEBAR_BORDER.g, c.SIDEBAR_BORDER.b)
    love.graphics.rectangle("line", 0, 0, UI.sidebar_width, Constants.WINDOW_HEIGHT)
    love.graphics.setColor(1,1,1)
end

function drawMinimap()
    local size = UI.minimap_size
    local x, y = 10, 10
    local boardW, boardH = game.board.width, game.board.height

    -- Minimap background
    love.graphics.setColor(0,0,0,0.6)
    love.graphics.rectangle("fill", x, y, size, size)
    love.graphics.setColor(1,1,1)

    -- Draw tiles on minimap scaled down (clip to minimap area)
    local tileW = size / boardW
    local tileH = size / boardH
    love.graphics.setScissor(x, y, size, size)
    for ty = 1, boardH do
        for tx = 1, boardW do
            local tile = game.board:getTile(tx, ty)
            -- base color by tile type
            local base = Constants.UI_COLORS.TILE
            if tile and tile.tileType == Constants.TILE_TYPES.OBSTACLE then
                base = Constants.UI_COLORS.OBSTACLE
            elseif tile and tile.tileType == Constants.TILE_TYPES.CONTROL_POINT then
                base = Constants.UI_COLORS.CONTROL_POINT
            end
            -- apply fog overlay for minimap by querying per-player fog state
            if tile then
                local fs = nil
                if tile.getFogState then fs = tile:getFogState(game.currentPlayerIndex) end
                if fs == Constants.FOW_HIDDEN then
                    love.graphics.setColor(0, 0, 0, 0.85)
                elseif fs == Constants.FOW_EXPLORED then
                    love.graphics.setColor(base.r * 0.5, base.g * 0.5, base.b * 0.5)
                else
                    love.graphics.setColor(base.r, base.g, base.b)
                end
            else
                love.graphics.setColor(base.r, base.g, base.b)
            end
            love.graphics.rectangle("fill", x + (tx-1)*tileW, y + (ty-1)*tileH, tileW, tileH)
        end
    end
    -- Clear scissor after drawing minimap tiles
    love.graphics.setScissor()

    -- Draw viewport rectangle on minimap
    local cam = game.camera
    if cam then
        local screenWorldX, screenWorldY = cam.x or 0, cam.y or 0
        local viewW = (Constants.WINDOW_WIDTH / cam.zoom)
        local viewH = (Constants.WINDOW_HEIGHT / cam.zoom)
        local viewX = (screenWorldX / (boardW * Constants.TILE_SIZE)) * size
        local viewY = (screenWorldY / (boardH * Constants.TILE_SIZE)) * size
        local vw = (viewW / (boardW * Constants.TILE_SIZE)) * size
        local vh = (viewH / (boardH * Constants.TILE_SIZE)) * size

        -- Clamp viewport rectangle inside minimap
        viewX = math.max(0, math.min(viewX, size))
        viewY = math.max(0, math.min(viewY, size))
        vw = math.max(1, math.min(vw, size - viewX))
        vh = math.max(1, math.min(vh, size - viewY))

        love.graphics.setScissor(x, y, size, size)
        love.graphics.setColor(1,1,1)
        love.graphics.rectangle("line", x + viewX, y + viewY, vw, vh)
        love.graphics.setScissor()
        love.graphics.setColor(1,1,1)
    end
end

function drawSidebarPanels()
    -- Minimap (top)
    drawMinimap()

    local x = 10
    local y = 10 + UI.minimap_size + 12

    -- HUD panel (title, turn, current player) - placed under minimap
    love.graphics.setColor(0,0,0,0.6)
    love.graphics.rectangle("fill", x, y, UI.sidebar_width - 20, 70)
    love.graphics.setColor(1,1,1)
    love.graphics.print("Tactical Chess", x + 8, y + 6)
    love.graphics.print("Turn: " .. game.turnNumber, x + 8, y + 26)
    local current = game.players[game.currentPlayerIndex]
    love.graphics.setColor(current.color.r, current.color.g, current.color.b)
    love.graphics.circle("fill", x + UI.sidebar_width - 40, y + 18, 8)
    love.graphics.setColor(1,1,1)
    love.graphics.print("Player " .. game.currentPlayerIndex .. " (" .. current.color.name .. ")", x + 8, y + 44)

    -- Info panel (resources / TU) under HUD
    local infoY = y + 70 + 8
    love.graphics.setColor(0,0,0,0.6)
    love.graphics.rectangle("fill", x, infoY, UI.sidebar_width - 20, 70)
    love.graphics.setColor(1,1,1)
    love.graphics.print("Resources: " .. current.resources, x + 6, infoY + 6)
    love.graphics.print("TU: " .. current.tu .. "/" .. Constants.DEFAULT_TU_PER_TURN, x + 6, infoY + 26)

    -- Selected piece panel (below info)
    local selY = infoY + 70 + 8
    love.graphics.setColor(0,0,0,0.6)
    love.graphics.rectangle("fill", x, selY, UI.sidebar_width - 20, 120)
    love.graphics.setColor(1,1,1)
    if game.selectedPiece then
        local sp = game.selectedPiece
        love.graphics.print("Selected: " .. (sp.pieceType or ""), x + 6, selY + 6)
        love.graphics.print("HP: " .. (sp.hp or 0) .. "/" .. (sp.maxHp or 0), x + 6, selY + 26)
        love.graphics.print("Attack: " .. (sp.attack or 0), x + 6, selY + 46)
        love.graphics.print("TU Cost: " .. (sp.tuCost or 0), x + 6, selY + 66)
        love.graphics.print("Vision: " .. (sp.vision or 0), x + 6, selY + 86)
    else
        love.graphics.print("Selected: None", x + 6, selY + 6)
    end

    -- Instructions panel above buttons
    local instrY = Constants.WINDOW_HEIGHT - UI.button_height - UI.button_padding - 80
    love.graphics.setColor(0,0,0,0.6)
    love.graphics.rectangle("fill", x, instrY, UI.sidebar_width - 20, 70)
    love.graphics.setColor(1,1,1)
    love.graphics.print("Middle Mouse: Pan Camera", x + 6, instrY + 6)
    love.graphics.print("Mouse Wheel: Zoom", x + 6, instrY + 26)
    love.graphics.print("Left Click: Select/Move | Space: End Turn", x + 6, instrY + 46)

    -- Buttons at bottom of sidebar
    local by = Constants.WINDOW_HEIGHT - UI.button_height - UI.button_padding
    local bx = 10
    local bw = UI.sidebar_width - 20
    love.graphics.setColor(0.2,0.2,0.2)
    love.graphics.rectangle("fill", bx, by, bw, UI.button_height)
    love.graphics.setColor(1,1,1)
    love.graphics.print("End Turn", bx + 8, by + 6)
end

function drawUI()
    -- Intentionally empty: all HUD is now rendered inside the left sidebar via drawSidebarPanels()
end

function love.mousepressed(x, y, button)
    -- Block input while animations are running
    if game.animationActive then return end
    -- If click is inside sidebar area, handle GUI interactions
    if x <= UI.sidebar_width then
        handleSidebarClick(x, y, button)
        return
    end

    -- Adjust x for the map translation
    local mapX = x - UI.sidebar_width
    if button == 3 then -- Middle mouse button
        game.camera:startPan(mapX, y)
    elseif button == 1 then -- Left mouse button
        handleLeftClick(mapX, y)
    end
end

function love.mousereleased(x, y, button)
    -- End pan regardless (map coords or not)
    game.camera:endPan()
end

function love.mousemoved(x, y, dx, dy)
    -- Only update pan if currently panning; pass map-relative coords
    if game.camera.isPanning then
        game.camera:updatePan(x - UI.sidebar_width, y)
    end
end

function love.wheelmoved(x, y)
    game.camera:wheelMoved(y)
end

function handleLeftClick(screenX, screenY)
    -- Block input while animations are running
    if game.animationActive then return end
    -- Convert screen (map-local) to world coordinates
    local worldX, worldY = game.camera:screenToWorld(screenX, screenY)
    
    -- Convert to tile coordinates
    local tileX = math.floor(worldX / Constants.TILE_SIZE) + 1
    local tileY = math.floor(worldY / Constants.TILE_SIZE) + 1
    
    if not game.board:isValidPosition(tileX, tileY) then
        return
    end
    
    local tile = game.board:getTile(tileX, tileY)
        -- Allow interacting with tiles in fog if the tile is a valid move destination
        local function isInValidMoves(x, y)
            for _, mv in ipairs(game.validMoves) do
                if mv.x == x and mv.y == y then return true end
            end
            return false
        end

        if not tile:isVisible(game.currentPlayerIndex) and not (game.selectedPiece and isInValidMoves(tileX, tileY)) then
            return -- Can't interact with hidden tiles unless moving there
        end
    
    local currentPlayer = game.players[game.currentPlayerIndex]
    
    -- If we have a selected piece and clicked on valid move
    if game.selectedPiece then
        for _, move in ipairs(game.validMoves) do
            if move.x == tileX and move.y == tileY then
                -- Execute move
                executeMove(game.selectedPiece, tileX, tileY)
                game.selectedPiece = nil
                game.validMoves = {}
                return
            end
        end
    end
    
    -- Select piece
    local piece = game.board:getPiece(tileX, tileY)
    if piece and piece.playerId == currentPlayer.id then
        game.selectedPiece = piece
        game.validMoves = piece:getValidMoves(game.board)
        print("Selected " .. piece.pieceType .. " at (" .. tileX .. ", " .. tileY .. ")")
        print("Valid moves: " .. #game.validMoves)
    else
        game.selectedPiece = nil
        game.validMoves = {}
    end
end

function handleSidebarClick(x, y, button)
    -- Check minimap click area
    local mx, my = 10, 10
    local size = UI.minimap_size
    if x >= mx and x <= mx + size and y >= my and y <= my + size then
        -- Map click -> recenter camera to clicked location on minimap
        local relX = (x - mx) / size
        local relY = (y - my) / size
        local worldX = relX * (game.board.width * Constants.TILE_SIZE)
        local worldY = relY * (game.board.height * Constants.TILE_SIZE)
        game.camera.x = math.max(0, math.min(worldX - Constants.WINDOW_WIDTH / 2, game.camera.maxX - Constants.WINDOW_WIDTH))
        game.camera.y = math.max(0, math.min(worldY - Constants.WINDOW_HEIGHT / 2, game.camera.maxY - Constants.WINDOW_HEIGHT))
        return
    end

    -- End Turn button area
    local by = Constants.WINDOW_HEIGHT - UI.button_height - UI.button_padding
    local bx = 10
    local bw = UI.sidebar_width - 20
    if x >= bx and x <= bx + bw and y >= by and y <= by + UI.button_height then
        if button == 1 then
            endTurn()
        end
        return
    end
end

function executeMove(piece, toX, toY)
    local currentPlayer = game.players[game.currentPlayerIndex]
    
    -- Check TU cost
    if currentPlayer.tu < piece.tuCost then
        print("Not enough TU!")
        return false
    end
    
    -- Check for attack
    local target = game.board:getPiece(toX, toY)
        if target then
            -- Combat preview (actual damage applied in animation onComplete)
            print(piece.pieceType .. " attacks " .. target.pieceType .. "!")
        end
    
    -- Determine full path via A* (include start)
    local allowGoalOccupied = true -- allow moving into occupied goal for attacks
    local path = game.board:findPath(piece.x, piece.y, toX, toY, true, allowGoalOccupied)
    if not path then
        print("No path to destination")
        return false
    end

    -- If attack (tile occupied by enemy), start attack animation
    if target and target.playerId ~= piece.playerId then
        -- Start attack animation: move into target tile then apply damage
        local anim = {
            type = 'attack',
            path = path,
            seg = 1,
            t = 0,
            segDur = Constants.ANIM.segment_duration,
            camera = game.camera,
            tileSize = Constants.TILE_SIZE,
            finalX = toX,
            finalY = toY,
            target = target,
            onComplete = function()
                -- Apply damage after animation
                local dead = piece:attack_piece(target)
                if dead then
                    -- start shrink animation and remove only when shrink finishes
                    target._shrink = true
                    target._shrinkT = 0
                    target._onRemoved = function(tp)
                        -- remove from board
                        game.board:removePiece(tp.x, tp.y)
                        -- remove from owner list
                        for i, p in ipairs(game.players[tp.playerId].pieces) do
                            if p == tp then
                                table.remove(game.players[tp.playerId].pieces, i)
                                break
                            end
                        end
                    end
                end
                -- Update fog after move/attack completes
                updateFogOfWar()
            end
        }
    -- register animation
    game._activeAnims = (game._activeAnims or 0) + 1
    game.animationActive = true
    local origOnComplete = anim.onComplete
    anim.onComplete = function()
        if origOnComplete then origOnComplete() end
        game._activeAnims = game._activeAnims - 1
        if game._activeAnims <= 0 then game.animationActive = false end
    end
    piece._anim = anim
    piece.hasMoved = true
    currentPlayer.tu = currentPlayer.tu - piece.tuCost
    print(piece.pieceType .. " attacks " .. target.pieceType .. "!")
    return true
    else
        -- Normal move animation
        local anim = {
            type = 'move',
            path = path,
            seg = 1,
            t = 0,
            segDur = Constants.ANIM.segment_duration,
            camera = game.camera,
            tileSize = Constants.TILE_SIZE,
            finalX = toX,
            finalY = toY,
            onComplete = function()
                -- After finishing movement, update fog of war so vision moves with unit
                updateFogOfWar()
            end
        }
    -- register animation
    game._activeAnims = (game._activeAnims or 0) + 1
    game.animationActive = true
    local origOnComplete = anim.onComplete
    anim.onComplete = function()
        if origOnComplete then origOnComplete() end
        game._activeAnims = game._activeAnims - 1
        if game._activeAnims <= 0 then game.animationActive = false end
    end
    piece._anim = anim
    piece.hasMoved = true
    currentPlayer.tu = currentPlayer.tu - piece.tuCost
    print("Moved " .. piece.pieceType .. " to (" .. toX .. ", " .. toY .. ")")
    -- remove from old tile immediately so board queries reflect new state during animation
    game.board:removePiece(piece.x, piece.y)
    game.board:setPiece(toX, toY, piece)
    return true
    end
    
    -- Update fog of war
    updateFogOfWar()
    
    -- Check if player has no TU left
    if currentPlayer.tu <= 0 then
        print("No TU remaining - press Space to end turn")
    end
    
    return true
end

function love.keypressed(key)
    if key == "space" then
        endTurn()
    elseif key == "escape" then
        love.event.quit()
    end
end

function endTurn()
    print("\n=== Turn " .. game.turnNumber .. " ended ===")
    
    -- Reset current player's TU
    local currentPlayer = game.players[game.currentPlayerIndex]
    currentPlayer.tu = Constants.DEFAULT_TU_PER_TURN
    
    -- Add resources from control points
    currentPlayer.resources = currentPlayer.resources + currentPlayer.controlPoints
    
    -- Next player
    game.currentPlayerIndex = game.currentPlayerIndex + 1
    if game.currentPlayerIndex > #game.players then
        game.currentPlayerIndex = 1
        game.turnNumber = game.turnNumber + 1
    end
    
    -- Update fog of war for new player
    updateFogOfWar()
    -- Reset moved state for the player whose turn begins
    local newPlayer = game.players[game.currentPlayerIndex]
    for _, p in ipairs(newPlayer.pieces) do
        p.hasMoved = false
    end
    -- Center camera on that player's king if exists
    for _, p in ipairs(newPlayer.pieces) do
        if p.pieceType == Constants.PIECE_TYPES.KING then
            local worldX = (p.x - 1) * Constants.TILE_SIZE + Constants.TILE_SIZE / 2
            local worldY = (p.y - 1) * Constants.TILE_SIZE + Constants.TILE_SIZE / 2
            -- Center the camera so the unit is in the middle of the screen, account for zoom
            local halfW = (Constants.WINDOW_WIDTH / 2) / (game.camera.zoom or 1)
            local halfH = (Constants.WINDOW_HEIGHT / 2) / (game.camera.zoom or 1)
            local targetX = worldX - halfW
            local targetY = worldY - halfH
            game.camera.x = math.max(0, math.min(targetX, game.camera.maxX - Constants.WINDOW_WIDTH / (game.camera.zoom or 1)))
            game.camera.y = math.max(0, math.min(targetY, game.camera.maxY - Constants.WINDOW_HEIGHT / (game.camera.zoom or 1)))
            break
        end
    end
    
    print("Player " .. game.currentPlayerIndex .. "'s turn")
    print("===========================\n")
    
    -- Clear selection
    game.selectedPiece = nil
    game.validMoves = {}
end
