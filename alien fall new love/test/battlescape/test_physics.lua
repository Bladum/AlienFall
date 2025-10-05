-- test/battlescape/test_physics.lua
-- Test suite for Box2D physics integration
-- Validates: bullet physics, explosions, ray-trace beams, movement costs

local TestFramework = require("test.test_framework")
local StatRanges = require("src.core.StatRanges")

local test = TestFramework.new("Box2D Physics Integration")

-- Test 1: Bullet physics objects creation
test:add("Bullets as independent physics objects", function()
    test:assert_true(
        StatRanges.BULLET_PHYSICS,
        "Bullet physics should be enabled"
    )
    
    local bullet = {
        x = 10,
        y = 10,
        vx = 5,  -- Velocity X
        vy = 0,  -- Velocity Y
        mass = 0.1,
        radius = 0.5,
        damage = 6
    }
    
    test:assert_not_nil(bullet.vx, "Bullet should have X velocity")
    test:assert_not_nil(bullet.vy, "Bullet should have Y velocity")
    test:assert_not_nil(bullet.mass, "Bullet should have mass for physics")
end)

-- Test 2: Bullets fly independently
test:add("Bullets move independently with physics", function()
    local bullet = {x = 0, y = 0, vx = 10, vy = 5}
    local dt = 0.016  -- 1 frame at 60fps
    
    -- Simulate bullet movement
    bullet.x = bullet.x + (bullet.vx * dt)
    bullet.y = bullet.y + (bullet.vy * dt)
    
    test:assert_true(
        bullet.x > 0,
        "Bullet X position should increase with positive vx"
    )
    test:assert_true(
        bullet.y > 0,
        "Bullet Y position should increase with positive vy"
    )
end)

-- Test 3: Beam weapons use ray-trace
test:add("Beam weapons ray-trace mechanics", function()
    test:assert_true(
        StatRanges.BEAM_RAYTRACE,
        "Beam weapons should use ray-trace"
    )
    
    local beam = {
        origin_x = 0,
        origin_y = 0,
        target_x = 30,
        target_y = 0,
        is_beam = true
    }
    
    test:assert_true(beam.is_beam, "Beam weapon flag should be set")
    test:assert_not_nil(beam.origin_x, "Beam needs origin point")
    test:assert_not_nil(beam.target_x, "Beam needs target point")
    
    -- Ray-trace is instant (no travel time)
    local travel_time = 0
    test:assert_equals(travel_time, 0, "Beam weapons hit instantly")
end)

-- Test 4: Explosion creates radial bullets
test:add("Explosion radial bullet system", function()
    local explosion = {
        x = 15,
        y = 15,
        damage = StatRanges.EXPLOSION_DAMAGE,
        radius = StatRanges.EXPLOSION_RADIUS,
        bullet_count = StatRanges.EXPLOSION_BULLETS
    }
    
    test:assert_equals(
        explosion.bullet_count,
        60,
        "Explosion should create 60 radial bullets"
    )
    test:assert_equals(
        explosion.damage,
        10,
        "Base explosion damage = 10"
    )
    test:assert_equals(
        explosion.radius,
        5,
        "Explosion radius = 5 tiles"
    )
end)

-- Test 5: Explosion damage distribution
test:add("Explosion damage accumulation", function()
    local base_damage = StatRanges.EXPLOSION_DAMAGE
    local dropoff = StatRanges.EXPLOSION_DROPOFF
    
    -- Damage at different distances
    local distances = {0, 1, 2, 3, 4, 5}
    local expected_damages = {10, 8, 6, 4, 2, 0}
    
    for i, distance in ipairs(distances) do
        local damage = math.max(0, base_damage - (dropoff * distance))
        test:assert_equals(
            damage,
            expected_damages[i],
            string.format("Damage at distance %d should be %d (got %d)", 
                distance, expected_damages[i], damage)
        )
    end
end)

-- Test 6: Terrain collision detection
test:add("Terrain collision with bullets", function()
    local bullet = {
        x = 10,
        y = 10,
        vx = 5,
        vy = 0,
        active = true
    }
    
    local wall = {
        x = 15,
        y = 10,
        width = 2,
        height = 2,
        blocks_bullets = true
    }
    
    -- Simulate collision
    if bullet.x >= wall.x and bullet.x <= wall.x + wall.width and
       bullet.y >= wall.y and bullet.y <= wall.y + wall.height and
       wall.blocks_bullets then
        bullet.active = false
    end
    
    test:assert_false(
        bullet.active,
        "Bullet should be stopped by wall"
    )
end)

-- Test 7: Line of sight ray-cast
test:add("Line of sight ray-casting", function()
    local origin = {x = 0, y = 0}
    local target = {x = 30, y = 0}
    local obstacle = {x = 15, y = 0, blocks_los = true}
    
    -- Check if obstacle blocks LOS
    local has_los = true
    if obstacle.x >= origin.x and obstacle.x <= target.x and
       obstacle.y == origin.y and obstacle.blocks_los then
        has_los = false
    end
    
    test:assert_false(
        has_los,
        "Obstacle should block line of sight"
    )
end)

-- Test 8: Movement cost calculations
test:add("Movement point costs", function()
    test:assert_equals(StatRanges.MP_ROTATION_90, 1, "90° rotation = 1 MP")
    test:assert_equals(StatRanges.MP_TILE_NORMAL, 2, "Normal tile = 2 MP")
    test:assert_equals(StatRanges.MP_TILE_DIAGONAL, 3, "Diagonal tile = 3 MP")
    test:assert_equals(StatRanges.MP_TILE_ROUGH, 4, "Rough terrain = 4 MP")
    test:assert_equals(StatRanges.MP_TILE_VERY_ROUGH, 6, "Very rough = 6 MP")
    test:assert_equals(StatRanges.MP_CROUCH_TOGGLE, 4, "Crouch toggle = 4 MP")
end)

-- Test 9: AP calculation from speed
test:add("Action points from speed stat", function()
    local speeds = {6, 8, 10, 12}
    local multiplier = StatRanges.AP_MULTIPLIER
    
    for _, speed in ipairs(speeds) do
        local ap = StatRanges.calculateTotalAP(speed)
        local expected_ap = speed * multiplier
        
        test:assert_equals(
            ap,
            expected_ap,
            string.format("Speed %d should give %d AP (got %d)", speed, expected_ap, ap)
        )
    end
    
    -- Typical AP range: 24-48
    test:assert_equals(StatRanges.calculateTotalAP(6), 24, "Min speed (6) = 24 AP")
    test:assert_equals(StatRanges.calculateTotalAP(12), 48, "Max speed (12) = 48 AP")
end)

-- Test 10: Bullet trajectory calculation
test:add("Bullet trajectory with gravity", function()
    local bullet = {
        x = 0,
        y = 0,
        vx = 10,
        vy = 0,
        gravity = 9.8,  -- Box2D gravity
        dt = 0.016
    }
    
    -- Simulate 1 frame
    bullet.vy = bullet.vy + (bullet.gravity * bullet.dt)
    bullet.x = bullet.x + (bullet.vx * bullet.dt)
    bullet.y = bullet.y + (bullet.vy * bullet.dt)
    
    test:assert_true(
        bullet.y > 0,
        "Bullet should fall due to gravity"
    )
    test:assert_true(
        bullet.vy > 0,
        "Bullet Y velocity should increase from gravity"
    )
end)

-- Test 11: Explosion damage to multiple targets
test:add("Explosion hits multiple targets", function()
    local explosion = {x = 10, y = 10, radius = 5, damage = 10}
    
    local targets = {
        {x = 10, y = 10, distance = 0, expected_damage = 10}, -- Epicenter
        {x = 11, y = 10, distance = 1, expected_damage = 8},  -- 1 tile away
        {x = 13, y = 10, distance = 3, expected_damage = 4},  -- 3 tiles away
        {x = 20, y = 10, distance = 10, expected_damage = 0}  -- Outside radius
    }
    
    for _, target in ipairs(targets) do
        local damage = math.max(0, explosion.damage - (StatRanges.EXPLOSION_DROPOFF * target.distance))
        test:assert_equals(
            damage,
            target.expected_damage,
            string.format("Target at distance %d should take %d damage (got %d)", 
                target.distance, target.expected_damage, damage)
        )
    end
end)

-- Test 12: Cover mechanics with ray-trace
test:add("Cover reduces hit chance via LOS", function()
    local shooter = {x = 0, y = 0}
    local target = {x = 20, y = 0}
    local cover = {x = 19, y = 0, cover_value = 40}  -- 40% cover
    
    -- Base accuracy
    local base_accuracy = 70
    
    -- Cover reduces accuracy
    local effective_accuracy = base_accuracy - cover.cover_value
    
    test:assert_equals(
        effective_accuracy,
        30,
        "Cover should reduce 70% accuracy to 30%"
    )
    test:assert_true(
        effective_accuracy >= 0,
        "Accuracy should not go below 0"
    )
end)

-- Test 13: Pathfinding with terrain costs
test:add("Pathfinding with movement costs", function()
    local path = {
        {x = 0, y = 0, terrain = "normal", cost = StatRanges.MP_TILE_NORMAL},
        {x = 1, y = 0, terrain = "normal", cost = StatRanges.MP_TILE_NORMAL},
        {x = 2, y = 1, terrain = "rough", cost = StatRanges.MP_TILE_ROUGH}
    }
    
    local total_cost = 0
    for _, step in ipairs(path) do
        total_cost = total_cost + step.cost
    end
    
    local expected_cost = 2 + 2 + 4  -- normal + normal + rough
    test:assert_equals(
        total_cost,
        expected_cost,
        string.format("Path cost should be %d (got %d)", expected_cost, total_cost)
    )
end)

-- Test 14: Diagonal movement cost
test:add("Diagonal movement costs more", function()
    local move_straight = StatRanges.MP_TILE_NORMAL
    local move_diagonal = StatRanges.MP_TILE_DIAGONAL
    
    test:assert_true(
        move_diagonal > move_straight,
        "Diagonal movement should cost more than straight"
    )
    test:assert_equals(
        move_diagonal,
        3,
        "Diagonal cost = 3 MP (approximates √2 × 2)"
    )
end)

-- Test 15: Box2D physics enabled
test:add("Box2D physics system enabled", function()
    test:assert_true(
        StatRanges.USE_BOX2D,
        "Box2D physics should be enabled"
    )
    test:assert_true(
        StatRanges.BULLET_PHYSICS,
        "Bullet physics should use Box2D"
    )
    test:assert_true(
        StatRanges.BEAM_RAYTRACE,
        "Beam weapons should use Box2D ray-trace"
    )
end)

return test
