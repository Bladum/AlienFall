--[[
    Deterministic RNG Usage Example
    Demonstrates proper use of seeded random number generation for reproducible gameplay
    
    Key Concepts:
    - Scoped RNG for different systems
    - Seeded randomness for determinism
    - NO use of math.random() (non-deterministic!)
    - Reproducible outcomes across playthroughs
]]

local RNG = require("src.core.services.rng")
local services = require("src.core.services.registry")

--[[
    RULE #1: NEVER use math.random() directly
    It's not seeded and will produce different results each playthrough!
    
    ❌ BAD:
    local damage = math.random(20, 40)  -- Non-deterministic!
    
    ✅ GOOD:
    local rng = services:get("rng")
    local damage = rng:random("combat:damage", 20, 40)  -- Deterministic!
]]

-- Example: Combat damage calculation
local function calculateWeaponDamage(weapon, attacker_id, target_id, turn_number)
    local rng = services:get("rng")
    
    -- Create unique scope for this specific attack
    -- Format: "system:subsystem:entity_id:turn"
    local scope = string.format("combat:damage:atk%d:tgt%d:turn%d", 
                                attacker_id, target_id, turn_number)
    
    -- Roll damage (deterministic, reproducible with same scope)
    local damage = rng:random(scope, weapon.damage_min, weapon.damage_max)
    
    return damage
end

-- Example: Critical hit check
local function checkCriticalHit(weapon, attacker_id, turn_number)
    local rng = services:get("rng")
    
    -- Scope includes attacker and turn for uniqueness
    local scope = string.format("combat:critical:atk%d:turn%d", attacker_id, turn_number)
    
    -- Roll 0.0 to 1.0
    local roll = rng:randomFloat(scope)
    
    -- Check against critical chance (e.g., 0.15 = 15%)
    local is_critical = roll < (weapon.critical_chance / 100.0)
    
    return is_critical
end

-- Example: Loot table with deterministic drops
local function generateMissionLoot(mission_id, enemy_kills)
    local rng = services:get("rng")
    local loot = {}
    
    -- Each item gets its own scope
    for i, item_entry in ipairs(LOOT_TABLE) do
        local scope = string.format("loot:mission%d:item%d", mission_id, i)
        local roll = rng:randomFloat(scope)
        
        if roll < item_entry.chance then
            table.insert(loot, {
                item_id = item_entry.item_id,
                quantity = rng:random(scope .. ":qty", item_entry.qty_min, item_entry.qty_max)
            })
        end
    end
    
    return loot
end

-- Example: Enemy spawn with deterministic placement
local function spawnEnemyPod(mission_id, pod_index, spawn_zone)
    local rng = services:get("rng")
    local enemies = {}
    
    -- Number of enemies in pod
    local scope_count = string.format("spawn:mission%d:pod%d:count", mission_id, pod_index)
    local enemy_count = rng:random(scope_count, 3, 6)
    
    for i = 1, enemy_count do
        -- Select enemy type
        local scope_type = string.format("spawn:mission%d:pod%d:enemy%d:type", 
                                        mission_id, pod_index, i)
        local enemy_type_index = rng:random(scope_type, 1, #ENEMY_TYPES)
        
        -- Spawn position within zone
        local scope_x = string.format("spawn:mission%d:pod%d:enemy%d:x", 
                                     mission_id, pod_index, i)
        local scope_y = string.format("spawn:mission%d:pod%d:enemy%d:y", 
                                     mission_id, pod_index, i)
        
        local x = rng:random(scope_x, spawn_zone.min_x, spawn_zone.max_x)
        local y = rng:random(scope_y, spawn_zone.min_y, spawn_zone.max_y)
        
        table.insert(enemies, {
            type = ENEMY_TYPES[enemy_type_index],
            x = x,
            y = y
        })
    end
    
    return enemies
end

-- Example: AI decision making (deterministic tactics)
local function selectAIAction(unit_id, turn_number, available_actions)
    local rng = services:get("rng")
    
    -- Calculate utility for each action (deterministic)
    local utilities = {}
    for i, action in ipairs(available_actions) do
        local utility = calculateActionUtility(action, unit_id)  -- Deterministic calculation
        utilities[i] = utility
    end
    
    -- Add small random factor for variety (still deterministic)
    local scope = string.format("ai:unit%d:turn%d:decision", unit_id, turn_number)
    local random_factor = rng:randomFloat(scope) * 0.1  -- ±10% variation
    
    -- Select action with highest adjusted utility
    local best_index = 1
    local best_utility = utilities[1] * (1.0 + random_factor)
    
    for i = 2, #utilities do
        local scope_i = string.format("ai:unit%d:turn%d:action%d", unit_id, turn_number, i)
        local factor = rng:randomFloat(scope_i) * 0.1
        local adjusted_utility = utilities[i] * (1.0 + factor)
        
        if adjusted_utility > best_utility then
            best_index = i
            best_utility = adjusted_utility
        end
    end
    
    return available_actions[best_index]
end

-- Example: Procedural map generation
local function generateMapTiles(mission_id, width, height)
    local rng = services:get("rng")
    local tiles = {}
    
    for y = 1, height do
        tiles[y] = {}
        for x = 1, width do
            -- Each tile gets deterministic terrain type
            local scope = string.format("map:mission%d:tile:%d:%d", mission_id, x, y)
            local terrain_roll = rng:randomFloat(scope)
            
            -- Determine terrain based on probability
            local terrain_type
            if terrain_roll < 0.1 then
                terrain_type = "cover_full"
            elseif terrain_roll < 0.3 then
                terrain_type = "cover_half"
            elseif terrain_roll < 0.4 then
                terrain_type = "obstacle"
            else
                terrain_type = "floor"
            end
            
            tiles[y][x] = {
                terrain = terrain_type,
                x = x,
                y = y
            }
        end
    end
    
    return tiles
end

--[[
    BEST PRACTICES:
    
    1. Always use scoped RNG
       ✅ rng:random("combat:damage", min, max)
       ❌ math.random(min, max)
    
    2. Make scopes unique and descriptive
       ✅ "combat:unit123:turn5:damage"
       ❌ "damage" (too generic, will conflict)
    
    3. Include relevant IDs in scope
       - mission_id for mission events
       - unit_id for unit actions
       - turn_number for turn-based events
       - item_id for item effects
    
    4. Use consistent scope naming conventions
       - Format: "system:subsystem:entity:action"
       - Example: "loot:mission:enemy123:drop"
    
    5. For ranged values, use :random(scope, min, max)
       local value = rng:random("scope", 10, 20)
    
    6. For probability checks, use :randomFloat(scope)
       local roll = rng:randomFloat("scope")
       if roll < 0.5 then ... end  -- 50% chance
    
    7. Document your RNG scopes
       -- Add comments explaining what each scope controls
       -- Makes debugging and testing easier
]]

--[[
    TESTING DETERMINISM:
    
    To verify your RNG is deterministic:
    
    1. Set a fixed seed:
       services:get("rng"):setSeed("test_seed")
    
    2. Run your function:
       local result1 = myRandomFunction()
    
    3. Reset to same seed:
       services:get("rng"):setSeed("test_seed")
    
    4. Run again:
       local result2 = myRandomFunction()
    
    5. Verify results match:
       assert(result1 == result2, "RNG is not deterministic!")
]]

-- Example test function
local function testDeterminism()
    local rng = services:get("rng")
    
    -- Test 1: Same seed produces same results
    rng:setSeed("test_combat_seed")
    local damage1 = rng:random("test:damage", 10, 50)
    
    rng:setSeed("test_combat_seed")
    local damage2 = rng:random("test:damage", 10, 50)
    
    assert(damage1 == damage2, "Determinism test failed!")
    print("✓ Determinism test passed: " .. damage1 .. " == " .. damage2)
    
    -- Test 2: Different seeds produce different results
    rng:setSeed("seed_a")
    local value_a = rng:random("test:value", 1, 100)
    
    rng:setSeed("seed_b")
    local value_b = rng:random("test:value", 1, 100)
    
    -- Highly unlikely to be equal (but technically possible)
    print("✓ Different seeds: seed_a=" .. value_a .. ", seed_b=" .. value_b)
    
    -- Test 3: Same scope, different results in sequence
    rng:setSeed("sequence_test")
    local seq1 = rng:random("test:sequence", 1, 10)
    local seq2 = rng:random("test:sequence", 1, 10)
    local seq3 = rng:random("test:sequence", 1, 10)
    
    print("✓ Sequence test: " .. seq1 .. ", " .. seq2 .. ", " .. seq3)
end

return {
    calculateWeaponDamage = calculateWeaponDamage,
    checkCriticalHit = checkCriticalHit,
    generateMissionLoot = generateMissionLoot,
    spawnEnemyPod = spawnEnemyPod,
    selectAIAction = selectAIAction,
    generateMapTiles = generateMapTiles,
    testDeterminism = testDeterminism
}
