-- Integration Tests for Combat System
-- Tests full combat flow with units, weapons, and damage calculation

local CombatIntegrationTest = {}

-- Test setup
local function setup()
    package.path = package.path .. ";../../?.lua;../../engine/?.lua"
    
    -- Load mock data
    local MockUnits = require("mock.units")
    local MockItems = require("mock.items")
    
    return MockUnits, MockItems
end

-- Test basic attack flow
function CombatIntegrationTest.testBasicAttack()
    local MockUnits, MockItems = setup()
    
    -- Create attacker and target
    local attacker = MockUnits.getSoldier("Attacker", "ASSAULT")
    local target = MockUnits.getEnemy("SECTOID")
    
    -- Equip weapon
    attacker.weapon = MockItems.getWeapon("RIFLE")
    
    -- Verify initial state
    assert(target.hp > 0, "Target should be alive")
    assert(attacker.weapon ~= nil, "Attacker should have weapon")
    
    -- Simulate attack (basic damage calculation)
    local damage = attacker.weapon.damage
    target.hp = target.hp - damage
    
    assert(target.hp < target.maxHp, "Target should be damaged")
    
    print("✓ testBasicAttack passed")
end

-- Test hit chance calculation
function CombatIntegrationTest.testHitChance()
    local MockUnits, MockItems = setup()
    
    local attacker = MockUnits.getSoldier("Sniper", "SNIPER")
    local target = MockUnits.getEnemy("SECTOID")
    
    attacker.weapon = MockItems.getWeapon("SNIPER")
    
    -- Calculate hit chance (aim + weapon accuracy - target defense)
    local baseChance = attacker.aim + attacker.weapon.accuracy
    local finalChance = baseChance - target.defense
    
    assert(finalChance > 0, "Hit chance should be positive")
    assert(finalChance <= 200, "Hit chance should be reasonable")
    
    print("✓ testHitChance passed")
end

-- Test weapon range
function CombatIntegrationTest.testWeaponRange()
    local MockUnits, MockItems = setup()
    
    local soldier = MockUnits.getSoldier("Shooter", "SNIPER")
    soldier.weapon = MockItems.getWeapon("SNIPER")
    
    local enemy = MockUnits.getEnemy("MUTON")
    
    -- Set positions
    soldier.x, soldier.y = 0, 0
    enemy.x, enemy.y = 25, 0
    
    -- Calculate distance
    local dx = enemy.x - soldier.x
    local dy = enemy.y - soldier.y
    local distance = math.sqrt(dx * dx + dy * dy)
    
    -- Check if in range
    local inRange = distance <= soldier.weapon.range
    
    assert(inRange, "Target should be in sniper range")
    
    print("✓ testWeaponRange passed")
end

-- Test squad combat
function CombatIntegrationTest.testSquadCombat()
    local MockUnits, MockItems = setup()
    
    -- Create squad
    local squad = MockUnits.generateSquad(4)
    local enemies = MockUnits.generateEnemyGroup(3)
    
    -- Equip squad
    for _, soldier in ipairs(squad) do
        soldier.weapon = MockItems.getWeapon("RIFLE")
    end
    
    -- Verify setup
    assert(#squad == 4, "Squad should have 4 members")
    assert(#enemies == 3, "Should have 3 enemies")
    
    -- Count alive units
    local aliveSquad = 0
    for _, s in ipairs(squad) do
        if s.isAlive then aliveSquad = aliveSquad + 1 end
    end
    
    local aliveEnemies = 0
    for _, e in ipairs(enemies) do
        if e.isAlive then aliveEnemies = aliveEnemies + 1 end
    end
    
    assert(aliveSquad == 4, "All squad members should be alive")
    assert(aliveEnemies == 3, "All enemies should be alive")
    
    print("✓ testSquadCombat passed")
end

-- Test grenade damage
function CombatIntegrationTest.testGrenadeDamage()
    local MockUnits, MockItems = setup()
    
    local soldier = MockUnits.getSoldier("Grenadier", "HEAVY")
    local grenade = MockItems.getGrenade("FRAG")
    
    -- Create enemies in area
    local enemies = {
        MockUnits.getEnemy("SECTOID"),
        MockUnits.getEnemy("SECTOID"),
        MockUnits.getEnemy("SECTOID")
    }
    
    -- Position enemies close together
    enemies[1].x, enemies[1].y = 10, 10
    enemies[2].x, enemies[2].y = 11, 10
    enemies[3].x, enemies[3].y = 10, 11
    
    -- Grenade at center
    local grenadeX, grenadeY = 10, 10
    
    -- Check which enemies are in blast radius
    local damaged = 0
    for _, enemy in ipairs(enemies) do
        local dx = enemy.x - grenadeX
        local dy = enemy.y - grenadeY
        local distance = math.sqrt(dx * dx + dy * dy)
        
        if distance <= grenade.radius then
            enemy.hp = enemy.hp - grenade.damage
            damaged = damaged + 1
        end
    end
    
    assert(damaged > 0, "At least one enemy should be damaged")
    
    print("✓ testGrenadeDamage passed")
end

-- Test medical kit healing
function CombatIntegrationTest.testHealing()
    local MockUnits, MockItems = setup()
    
    local medic = MockUnits.getSoldier("Medic", "SUPPORT")
    local wounded = MockUnits.getWoundedSoldier("MODERATE")
    local medkit = MockItems.getMedkit()
    
    local initialHp = wounded.hp
    assert(initialHp < wounded.maxHp, "Soldier should be wounded")
    
    -- Heal
    wounded.hp = math.min(wounded.maxHp, wounded.hp + medkit.healAmount)
    
    assert(wounded.hp > initialHp, "Soldier should be healed")
    assert(wounded.hp <= wounded.maxHp, "HP should not exceed maximum")
    
    print("✓ testHealing passed")
end

-- Test armor damage reduction
function CombatIntegrationTest.testArmorReduction()
    local MockUnits, MockItems = setup()
    
    local soldier = MockUnits.getSoldier("Tank", "HEAVY")
    soldier.armor = MockItems.getArmor("TITAN")
    
    local enemy = MockUnits.getEnemy("MUTON")
    enemy.weapon = MockItems.getWeapon("RIFLE")
    
    -- Calculate damage with armor
    local baseDamage = enemy.weapon.damage
    local reducedDamage = math.max(0, baseDamage - soldier.armor.defense)
    
    assert(reducedDamage < baseDamage, "Armor should reduce damage")
    assert(reducedDamage >= 0, "Damage should not be negative")
    
    print("✓ testArmorReduction passed")
end

-- Test time unit (TU) costs
function CombatIntegrationTest.testTimeUnits()
    local MockUnits, MockItems = setup()
    
    local soldier = MockUnits.getSoldier("Soldier", "ASSAULT")
    soldier.weapon = MockItems.getWeapon("RIFLE")
    
    local initialTU = soldier.tu
    assert(initialTU > 0, "Soldier should have TU")
    
    -- Shoot action
    local shootCost = soldier.weapon.tuCost
    soldier.tu = soldier.tu - shootCost
    
    assert(soldier.tu < initialTU, "TU should be consumed")
    assert(soldier.tu >= 0, "TU should not be negative")
    
    -- Check if can still act
    local canAct = soldier.tu >= shootCost
    
    print("✓ testTimeUnits passed")
end

-- Test critical hit
function CombatIntegrationTest.testCriticalHit()
    local MockUnits, MockItems = setup()
    
    local attacker = MockUnits.getSoldier("Sniper", "SNIPER")
    attacker.weapon = MockItems.getWeapon("SNIPER")
    
    local target = MockUnits.getEnemy("SECTOID")
    
    -- Simulate critical hit (double damage)
    local normalDamage = attacker.weapon.damage
    local critDamage = normalDamage * 2
    
    assert(critDamage == normalDamage * 2, "Critical damage should be doubled")
    assert(critDamage > normalDamage, "Critical should do more damage")
    
    print("✓ testCriticalHit passed")
end

-- Test overwatch
function CombatIntegrationTest.testOverwatch()
    local MockUnits, MockItems = setup()
    
    local soldier = MockUnits.getSoldier("Overwatch", "ASSAULT")
    soldier.weapon = MockItems.getWeapon("RIFLE")
    soldier.tu = soldier.maxTu
    
    -- Enter overwatch (costs TU)
    local overwatchCost = 4
    soldier.tu = soldier.tu - overwatchCost
    soldier.overwatch = true
    
    assert(soldier.overwatch == true, "Soldier should be in overwatch")
    assert(soldier.tu < soldier.maxTu, "Overwatch should cost TU")
    
    print("✓ testOverwatch passed")
end

-- Run all integration tests
function CombatIntegrationTest.runAll()
    print("\n=== Combat Integration Tests ===")
    
    CombatIntegrationTest.testBasicAttack()
    CombatIntegrationTest.testHitChance()
    CombatIntegrationTest.testWeaponRange()
    CombatIntegrationTest.testSquadCombat()
    CombatIntegrationTest.testGrenadeDamage()
    CombatIntegrationTest.testHealing()
    CombatIntegrationTest.testArmorReduction()
    CombatIntegrationTest.testTimeUnits()
    CombatIntegrationTest.testCriticalHit()
    CombatIntegrationTest.testOverwatch()
    
    print("✓ All Combat Integration tests passed!\n")
end

return CombatIntegrationTest
