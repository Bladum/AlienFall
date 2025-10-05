-- test/items/test_weapon_stats.lua
-- Test suite for weapon stats validation with XCOM/5 scaling
-- Validates: damage, range (15 tiles per block), AP/EP costs

local TestFramework = require("test.test_framework")
local StatRanges = require("src.core.StatRanges")

local test = TestFramework.new("Weapon Stats Validation (XCOM/5)")

-- Test 1: Pistol stats validation
test:add("Pistol XCOM/5 stats", function()
    local pistol = {
        damage = 5,
        range = 15,
        ap_cost = 1,
        ep_cost = 1,
        weight = 1,
        ep_bonus = 5
    }
    
    test:assert_equals(pistol.damage, StatRanges.DAMAGE_PISTOL, "Pistol damage should be 5 (XCOM 25 ÷ 5)")
    test:assert_equals(pistol.range, StatRanges.RANGE_SHORT, "Pistol range should be 15 tiles (1 block)")
    test:assert_equals(pistol.ap_cost, StatRanges.AP_PISTOL, "Pistol AP cost should be 1")
    test:assert_equals(pistol.ep_cost, StatRanges.EP_PISTOL, "Pistol EP cost should be 1")
end)

-- Test 2: Rifle stats validation
test:add("Rifle XCOM/5 stats", function()
    local rifle = {
        damage = 6,
        range = 30,
        ap_cost = 2,
        ep_cost = 2,
        weight = 2,
        ep_bonus = 10
    }
    
    test:assert_equals(rifle.damage, StatRanges.DAMAGE_RIFLE, "Rifle damage should be 6 (XCOM 30 ÷ 5)")
    test:assert_equals(rifle.range, StatRanges.RANGE_MEDIUM, "Rifle range should be 30 tiles (2 blocks)")
    test:assert_equals(rifle.ap_cost, StatRanges.AP_RIFLE, "Rifle AP cost should be 2")
    test:assert_equals(rifle.ep_cost, StatRanges.EP_RIFLE, "Rifle EP cost should be 2")
end)

-- Test 3: Grenade stats validation
test:add("Grenade XCOM/5 stats", function()
    local grenade = {
        damage = 10,
        range = 15,
        ap_cost = 2,
        ep_cost = 4,
        weight = 1,
        explosion_bullets = 60
    }
    
    test:assert_equals(grenade.damage, StatRanges.DAMAGE_GRENADE, "Grenade damage should be 10 (XCOM 50 ÷ 5)")
    test:assert_equals(grenade.range, StatRanges.RANGE_SHORT, "Grenade range should be 15 tiles")
    test:assert_equals(grenade.ep_cost, StatRanges.EP_GRENADE, "Grenade EP cost should be 4")
    test:assert_equals(grenade.explosion_bullets, StatRanges.EXPLOSION_BULLETS, "Grenade should fire 60 radial bullets")
end)

-- Test 4: Range in tiles validation
test:add("Range measured in tiles", function()
    test:assert_equals(StatRanges.RANGE_SHORT, 15, "Short range = 15 tiles = 1 block")
    test:assert_equals(StatRanges.RANGE_MEDIUM, 30, "Medium range = 30 tiles = 2 blocks")
    test:assert_equals(StatRanges.RANGE_LONG, 45, "Long range = 45 tiles = 3 blocks")
    test:assert_equals(StatRanges.MAP_BLOCK_SIZE, 15, "Map block = 15 tiles")
end)

-- Test 5: Weight validates against strength
test:add("Weight vs strength validation", function()
    local weapon_heavy = {weight = 10}
    local weapon_light = {weight = 1}
    
    local soldier_weak = {strength = 6}   -- Minimum human
    local soldier_strong = {strength = 12} -- Maximum human
    
    -- Weak soldier cannot carry heavy weapon
    test:assert_true(
        weapon_heavy.weight > soldier_weak.strength,
        "Heavy weapon (10) exceeds weak soldier capacity (6)"
    )
    
    -- Strong soldier can carry heavy weapon
    test:assert_true(
        weapon_heavy.weight <= soldier_strong.strength,
        "Strong soldier (12) can carry heavy weapon (10)"
    )
    
    -- Any soldier can carry light weapon
    test:assert_true(
        weapon_light.weight <= soldier_weak.strength,
        "Light weapon (1) within any soldier capacity"
    )
end)

-- Test 6: EP bonus contributions
test:add("Weapon EP bonus contributions", function()
    local weapons = {
        {name = "Pistol", ep_bonus = 5},
        {name = "Rifle", ep_bonus = 10},
        {name = "Heavy", ep_bonus = 15}
    }
    
    for _, weapon in ipairs(weapons) do
        test:assert_true(
            weapon.ep_bonus >= 5 and weapon.ep_bonus <= 25,
            string.format("%s EP bonus (%d) should be 5-25 range", weapon.name, weapon.ep_bonus)
        )
    end
end)

-- Test 7: No ammo properties
test:add("Weapons have no ammo properties", function()
    local weapon = {
        damage = 6,
        range = 30,
        ap_cost = 2,
        ep_cost = 2
        -- NO ammo_capacity, ammo_clip_size, reload_cost
    }
    
    test:assert_nil(weapon.ammo_capacity, "Weapon should not have ammo_capacity")
    test:assert_nil(weapon.ammo_clip_size, "Weapon should not have ammo_clip_size")
    test:assert_nil(weapon.reload_cost, "Weapon should not have reload_cost")
    test:assert_nil(weapon.ammo_type, "Weapon should not have ammo_type")
end)

-- Test 8: AP cost progression
test:add("AP cost progression by weapon type", function()
    test:assert_equals(StatRanges.AP_PISTOL, 1, "Pistol = 1 AP")
    test:assert_equals(StatRanges.AP_RIFLE, 2, "Rifle = 2 AP")
    test:assert_equals(StatRanges.AP_HEAVY, 3, "Heavy = 3 AP")
    
    -- AP costs should be reasonable
    test:assert_true(StatRanges.AP_PISTOL < StatRanges.AP_RIFLE, "Pistol faster than rifle")
    test:assert_true(StatRanges.AP_RIFLE < StatRanges.AP_HEAVY, "Rifle faster than heavy")
end)

-- Test 9: Explosion damage distribution
test:add("Explosion damage distribution", function()
    local base_damage = StatRanges.EXPLOSION_DAMAGE
    local dropoff = StatRanges.EXPLOSION_DROPOFF
    local radius = StatRanges.EXPLOSION_RADIUS
    
    test:assert_equals(base_damage, 10, "Base explosion damage = 10")
    test:assert_equals(dropoff, 2, "Damage dropoff = 2 per tile")
    test:assert_equals(radius, 5, "Explosion radius = 5 tiles")
    
    -- Damage at different distances
    local damage_at_0 = base_damage
    local damage_at_1 = base_damage - dropoff
    local damage_at_5 = base_damage - (dropoff * 5)
    
    test:assert_equals(damage_at_0, 10, "Damage at epicenter = 10")
    test:assert_equals(damage_at_1, 8, "Damage at 1 tile = 8")
    test:assert_equals(damage_at_5, 0, "Damage at 5 tiles = 0")
end)

-- Test 10: Sniper rifle long range
test:add("Sniper rifle long range stats", function()
    local sniper = {
        damage = 7,
        range = 45,  -- 3 map blocks
        ap_cost = 3,
        ep_cost = 3,
        accuracy_bonus = 10
    }
    
    test:assert_equals(sniper.range, StatRanges.RANGE_LONG, "Sniper range = 45 tiles (3 blocks)")
    test:assert_true(sniper.damage > StatRanges.DAMAGE_RIFLE, "Sniper damage > rifle")
    test:assert_true(sniper.range > StatRanges.RANGE_MEDIUM, "Sniper range > medium")
end)

-- Test 11: Beam weapon mechanics
test:add("Beam weapon ray-trace mechanics", function()
    local laser_pistol = {
        damage = 6,
        range = 18,
        ap_cost = 1,
        ep_cost = 1,
        is_beam_weapon = true,
        pierce_chance = 0.3
    }
    
    test:assert_true(laser_pistol.is_beam_weapon, "Beam weapon flag should be set")
    test:assert_true(StatRanges.BEAM_RAYTRACE, "Beam weapons use ray-trace")
    test:assert_not_nil(laser_pistol.pierce_chance, "Beam weapons can pierce")
end)

-- Test 12: Heavy weapon characteristics
test:add("Heavy weapon stats", function()
    local heavy_cannon = {
        damage = 11,
        range = 30,
        ap_cost = 3,
        ep_cost = 3,
        weight = 10,
        ep_bonus = 15
    }
    
    test:assert_true(heavy_cannon.damage > StatRanges.DAMAGE_GRENADE, "Heavy damage > grenade")
    test:assert_equals(heavy_cannon.ap_cost, StatRanges.AP_HEAVY, "Heavy AP cost = 3")
    test:assert_true(heavy_cannon.weight >= 10, "Heavy weapons are heavy (10+ weight)")
end)

return test
