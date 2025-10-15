---Mock Battlescape Data Generator
---Generates test data for tactical combat scenarios

local MockBattlescape = {}

---Generate a test battlefield map
---@param width number Map width in tiles
---@param height number Map height in tiles
---@param terrain string Terrain type ("urban", "forest", "desert", "arctic")
---@return table Battlefield map data
function MockBattlescape.getBattlefield(width, height, terrain)
    width = width or 40
    height = height or 40
    terrain = terrain or "urban"
    
    return {
        width = width,
        height = height,
        terrain = terrain,
        tiles = {},  -- Would contain tile data
        spawnZones = {
            xcom = {{x = 2, y = 2}, {x = 4, y = 2}, {x = 6, y = 2}},
            alien = {{x = 38, y = 38}, {x = 36, y = 38}, {x = 34, y = 38}}
        },
        cover = {
            {x = 10, y = 10, type = "FULL", direction = "N"},
            {x = 15, y = 15, type = "HALF", direction = "E"},
            {x = 20, y = 20, type = "FULL", direction = "W"}
        },
        elevation = {},  -- Elevation data
        los = {},  -- Line of sight data
        lighting = "DAY"
    }
end

---Generate test combat entities
---@param count number Number of entities
---@param team string Team name
---@return table Array of combat entities
function MockBattlescape.getCombatEntities(count, team)
    count = count or 6
    team = team or "XCOM"
    
    local entities = {}
    for i = 1, count do
        table.insert(entities, {
            id = string.format("%s_unit_%d", team, i),
            name = string.format("%s Soldier %d", team, i),
            team = team,
            position = {x = 0, y = 0, z = 0},
            health = {current = 80, max = 100},
            tu = {current = 50, max = 50},  -- Time units
            stats = {
                accuracy = 75,
                reactions = 65,
                strength = 50,
                throwing = 60,
                stamina = 80
            },
            weapon = {
                name = "Assault Rifle",
                type = "RIFLE",
                accuracy = 75,
                damage = {min = 15, max = 25},
                range = 30,
                ammo = {current = 30, max = 30},
                tuCost = {snap = 15, aimed = 25, auto = 20}
            },
            armor = {
                name = "Combat Armor",
                protection = {front = 30, side = 25, rear = 20}
            },
            status = {
                prone = false,
                kneeling = false,
                panicked = false,
                berserk = false,
                stunned = false
            }
        })
    end
    
    return entities
end

---Generate test line of sight data
---@param fromEntity table Source entity
---@param toEntity table Target entity
---@param blocked boolean Whether LOS is blocked
---@return table Line of sight data
function MockBattlescape.getLineOfSight(fromEntity, toEntity, blocked)
    blocked = blocked or false
    
    return {
        from = fromEntity.id,
        to = toEntity.id,
        blocked = blocked,
        distance = 15,
        cover = blocked and "FULL" or "NONE",
        obstacles = blocked and {{x = 10, y = 10, type = "WALL"}} or {}
    }
end

---Generate test combat turn data
---@param turnNumber number Current turn number
---@param activeTeam string Active team
---@return table Turn data
function MockBattlescape.getCombatTurn(turnNumber, activeTeam)
    turnNumber = turnNumber or 1
    activeTeam = activeTeam or "XCOM"
    
    return {
        number = turnNumber,
        activeTeam = activeTeam,
        timeLimit = 300,  -- 5 minutes
        elapsed = 0,
        actions = {},
        casualties = {XCOM = 0, ALIEN = 0}
    }
end

---Generate test weapon fire action
---@param shooter table Shooting entity
---@param target table Target entity
---@param mode string Fire mode ("snap", "aimed", "auto")
---@return table Fire action data
function MockBattlescape.getFireAction(shooter, target, mode)
    mode = mode or "snap"
    
    return {
        type = "FIRE",
        shooter = shooter.id,
        target = target.id,
        mode = mode,
        weapon = shooter.weapon.name,
        distance = 15,
        accuracy = 75,
        tuCost = shooter.weapon.tuCost[mode],
        damage = shooter.weapon.damage,
        result = nil  -- To be filled by combat system
    }
end

---Generate test grenade throw action
---@param thrower table Throwing entity
---@param targetPos table Target position {x, y, z}
---@return table Grenade action data
function MockBattlescape.getGrenadeAction(thrower, targetPos)
    return {
        type = "GRENADE",
        thrower = thrower.id,
        targetPos = targetPos,
        grenadeType = "FRAG",
        damage = {min = 30, max = 50},
        radius = 5,
        tuCost = 25,
        accuracy = thrower.stats.throwing,
        result = nil
    }
end

---Generate test movement action
---@param entity table Moving entity
---@param path table Array of positions
---@return table Movement action data
function MockBattlescape.getMovementAction(entity, path)
    return {
        type = "MOVE",
        entity = entity.id,
        path = path or {{x = 0, y = 0}, {x = 1, y = 0}, {x = 2, y = 0}},
        distance = #(path or {}),
        tuCost = #(path or {}) * 4,  -- 4 TU per tile
        result = nil
    }
end

---Generate test fog of war data
---@param width number Map width
---@param height number Map height
---@param revealed table Array of revealed positions
---@return table Fog of war data
function MockBattlescape.getFogOfWar(width, height, revealed)
    width = width or 40
    height = height or 40
    revealed = revealed or {}
    
    local fow = {
        width = width,
        height = height,
        tiles = {},
        revealedCount = #revealed
    }
    
    -- Initialize all tiles as hidden
    for y = 1, height do
        fow.tiles[y] = {}
        for x = 1, width do
            fow.tiles[y][x] = {visible = false, explored = false}
        end
    end
    
    -- Mark revealed positions
    for _, pos in ipairs(revealed) do
        if fow.tiles[pos.y] and fow.tiles[pos.y][pos.x] then
            fow.tiles[pos.y][pos.x].visible = true
            fow.tiles[pos.y][pos.x].explored = true
        end
    end
    
    return fow
end

---Generate test cover data
---@param position table Position {x, y}
---@param coverType string Cover type ("NONE", "HALF", "FULL")
---@param direction string Cover direction ("N", "S", "E", "W")
---@return table Cover data
function MockBattlescape.getCoverData(position, coverType, direction)
    coverType = coverType or "HALF"
    direction = direction or "N"
    
    return {
        position = position,
        type = coverType,
        direction = direction,
        protection = coverType == "FULL" and 75 or (coverType == "HALF" and 40 or 0),
        destructible = coverType ~= "NONE"
    }
end

---Generate complete combat scenario
---@param scenario string Scenario type ("balanced", "outnumbered", "ambush")
---@return table Complete combat scenario
function MockBattlescape.getCombatScenario(scenario)
    scenario = scenario or "balanced"
    
    local scenarios = {
        balanced = {
            map = MockBattlescape.getBattlefield(40, 40, "urban"),
            xcomTeam = MockBattlescape.getCombatEntities(6, "XCOM"),
            alienTeam = MockBattlescape.getCombatEntities(6, "ALIEN"),
            turn = MockBattlescape.getCombatTurn(1, "XCOM"),
            objective = "ELIMINATE_ALL",
            timeLimit = 20  -- 20 turns
        },
        outnumbered = {
            map = MockBattlescape.getBattlefield(40, 40, "desert"),
            xcomTeam = MockBattlescape.getCombatEntities(4, "XCOM"),
            alienTeam = MockBattlescape.getCombatEntities(10, "ALIEN"),
            turn = MockBattlescape.getCombatTurn(1, "XCOM"),
            objective = "SURVIVE",
            timeLimit = 15
        },
        ambush = {
            map = MockBattlescape.getBattlefield(40, 40, "forest"),
            xcomTeam = MockBattlescape.getCombatEntities(6, "XCOM"),
            alienTeam = MockBattlescape.getCombatEntities(8, "ALIEN"),
            turn = MockBattlescape.getCombatTurn(1, "ALIEN"),
            objective = "RESCUE_VIP",
            timeLimit = 25
        }
    }
    
    return scenarios[scenario] or scenarios.balanced
end

return MockBattlescape
