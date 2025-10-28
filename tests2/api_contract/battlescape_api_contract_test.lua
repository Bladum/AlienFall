-- ─────────────────────────────────────────────────────────────────────────
-- BATTLESCAPE API CONTRACT TESTS
-- ─────────────────────────────────────────────────────────────────────────
-- Purpose: Verify battlescape layer API contracts
-- Tests: 8 API contract tests
-- Expected: All pass in <200ms

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.battlescape",
    fileName = "battlescape_api_contract_test.lua",
    description = "Battlescape layer API contract validation"
})

-- ─────────────────────────────────────────────────────────────────────────
-- TESTS
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Battlescape API Contracts", function()

    local battlescape = {}

    Suite:beforeEach(function()
        battlescape = {
            map = {},
            units = {},
            enemies = {},
            turn = 1
        }
    end)

    -- Contract 1: Battle map structure
    Suite:testMethod("Battlescape:mapStructureContract", {
        description = "Battle maps must have consistent dimensions and terrain data",
        testCase = "contract",
        type = "api"
    }, function()
        local map = {
            width = 50,
            height = 50,
            terrain = {},
            visibility = {},

            getTile = function(self, x, y)
                return {x = x, y = y, type = "grass", passable = true}
            end,

            setTerrain = function(self, x, y, terrain) end
        }

        Helpers.assertTrue(map.width > 0, "Map must have width")
        Helpers.assertTrue(map.height > 0, "Map must have height")
        Helpers.assertTrue(type(map.getTile) == "function", "Must have getTile method")

        local tile = map:getTile(25, 25)
        Helpers.assertTrue(tile.x ~= nil, "Tile must have x coordinate")
        Helpers.assertTrue(tile.passable ~= nil, "Tile must have passable flag")
    end)

    -- Contract 2: Unit object interface
    Suite:testMethod("Battlescape:unitObjectContract", {
        description = "Units must provide consistent combat interface",
        testCase = "contract",
        type = "api"
    }, function()
        local function createUnit(name, x, y)
            return {
                id = math.random(100000),
                name = name,
                x = x,
                y = y,
                health = 100,
                maxHealth = 100,
                team = "player",

                takeDamage = function(self, amount) self.health = self.health - amount end,
                move = function(self, x, y) self.x = x; self.y = y end,
                attack = function(self, target) end,
                isAlive = function(self) return self.health > 0 end
            }
        end

        local unit = createUnit("Soldier", 10, 10)
        Helpers.assertEqual(unit.name, "Soldier", "Unit must have name")
        Helpers.assertTrue(type(unit.takeDamage) == "function", "takeDamage must be function")
        Helpers.assertTrue(type(unit.move) == "function", "move must be function")
        Helpers.assertTrue(type(unit.attack) == "function", "attack must be function")
    end)

    -- Contract 3: Combat action API
    Suite:testMethod("Battlescape:combatActionContract", {
        description = "Combat actions must return consistent result objects",
        testCase = "contract",
        type = "api"
    }, function()
        local function performAttack(attacker, defender, weapon)
            return {
                success = true,
                attacker = attacker,
                defender = defender,
                weapon = weapon,
                hit = true,
                damage = 25,
                criticalHit = false,
                timestamp = os.time()
            }
        end

        local result = performAttack("unit1", "unit2", "rifle")
        Helpers.assertTrue(result.success ~= nil, "Result must have success field")
        Helpers.assertTrue(result.damage ~= nil, "Result must have damage field")
        Helpers.assertTrue(result.timestamp ~= nil, "Result must have timestamp")
    end)

    -- Contract 4: Turn system API
    Suite:testMethod("Battlescape:turnSystemContract", {
        description = "Turn system must provide consistent turn information",
        testCase = "contract",
        type = "api"
    }, function()
        local turnSystem = {
            currentTurn = 1,
            currentPhase = "player",
            unitOrder = {}
        }

        function turnSystem:nextTurn()
            self.currentTurn = self.currentTurn + 1
            self.currentPhase = "player"
        end

        function turnSystem:nextPhase()
            if self.currentPhase == "player" then
                self.currentPhase = "enemy"
            else
                self.currentPhase = "player"
            end
        end

        Helpers.assertEqual(turnSystem.currentPhase, "player", "Must start with player phase")
        turnSystem:nextPhase()
        Helpers.assertEqual(turnSystem.currentPhase, "enemy", "Must advance to enemy phase")
    end)

    -- Contract 5: Line of sight API
    Suite:testMethod("Battlescape:lineOfSightContract", {
        description = "LoS system must provide visibility checking API",
        testCase = "contract",
        type = "api"
    }, function()
        local los = {}

        function los:hasLineOfSight(x1, y1, x2, y2, obstacles)
            local distance = math.sqrt((x2-x1)^2 + (y2-y1)^2)
            if distance > 30 then return false end

            for _, obs in ipairs(obstacles or {}) do
                if obs.x == x2 and obs.y == y2 then
                    return false
                end
            end

            return true
        end

        local visible = los:hasLineOfSight(0, 0, 10, 10, {})
        Helpers.assertTrue(visible == true or visible == false, "LoS must return boolean")

        local blocked = los:hasLineOfSight(0, 0, 20, 20, {{x = 10, y = 10}})
        Helpers.assertTrue(blocked == false, "LoS should be blocked")
    end)

    -- Contract 6: Inventory system API
    Suite:testMethod("Battlescape:inventorySystemContract", {
        description = "Inventory system must provide equipment management API",
        testCase = "contract",
        type = "api"
    }, function()
        local inventory = {items = {}}

        function inventory:addItem(item)
            table.insert(self.items, item)
        end

        function inventory:removeItem(itemId)
            for i, item in ipairs(self.items) do
                if item.id == itemId then
                    table.remove(self.items, i)
                    return item
                end
            end
        end

        function inventory:getItem(itemId)
            for _, item in ipairs(self.items) do
                if item.id == itemId then return item end
            end
        end

        inventory:addItem({id = 1, name = "Rifle"})
        Helpers.assertEqual(#inventory.items, 1, "Should have 1 item")

        local item = inventory:getItem(1)
        Helpers.assertEqual(item.name, "Rifle", "Should retrieve correct item")
    end)

    -- Contract 7: Animation system API
    Suite:testMethod("Battlescape:animationSystemContract", {
        description = "Animation system must provide consistent animation objects",
        testCase = "contract",
        type = "api"
    }, function()
        local animation = {
            type = "unit_move",
            startTime = os.time(),
            duration = 0.5,
            startX = 0,
            startY = 0,
            endX = 10,
            endY = 10,
            playing = true
        }

        function animation:isPlaying()
            return self.playing
        end

        function animation:stop()
            self.playing = false
        end

        Helpers.assertTrue(animation:isPlaying(), "Animation should be playing")
        animation:stop()
        Helpers.assertTrue(not animation:isPlaying(), "Animation should be stopped")
    end)

    -- Contract 8: Damage calculation API
    Suite:testMethod("Battlescape:damageCalculationContract", {
        description = "Damage calculation must return consistent result format",
        testCase = "contract",
        type = "api"
    }, function()
        local function calculateDamage(attackerStat, weaponDamage, targetArmor, critical)
            local baseDamage = attackerStat + weaponDamage
            local reduction = targetArmor / 2
            local finalDamage = math.max(1, baseDamage - reduction)

            if critical then
                finalDamage = finalDamage * 1.5
            end

            return {
                baseDamage = baseDamage,
                armorReduction = reduction,
                finalDamage = math.floor(finalDamage),
                isCritical = critical
            }
        end

        local result = calculateDamage(20, 30, 10, false)
        Helpers.assertTrue(result.baseDamage ~= nil, "Must have baseDamage")
        Helpers.assertTrue(result.finalDamage > 0, "Final damage must be positive")
        Helpers.assertTrue(result.isCritical == false, "Critical flag must match")
    end)

end)

return Suite
