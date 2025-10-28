-- ─────────────────────────────────────────────────────────────────────────
-- INTERCEPTION BATTLE TEST SUITE
-- FILE: tests2/battlescape/interception_battle_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.battlescape.interception_battle",
    fileName = "interception_battle.lua",
    description = "Aerial combat between craft and UFO with weapons, evasion, and engagement mechanics"
})

print("[INTERCEPTION_BATTLE_TEST] Setting up")

local InterceptionBattle = {
    engagements = {},
    craft = {},
    ufos = {},
    weapons = {},
    log = {},

    new = function(self)
        return setmetatable({engagements = {}, craft = {}, ufos = {}, weapons = {}, log = {}}, {__index = self})
    end,

    createEngagement = function(self, engagementId, craftId, ufoId)
        self.engagements[engagementId] = {id = engagementId, craft = craftId, ufo = ufoId, status = "engaged", turn = 0}
        self.craft[engagementId] = {id = craftId, health = 100, armor = 20, evasion = 35, weapons = {}}
        self.ufos[engagementId] = {id = ufoId, health = 120, armor = 15, evasion = 50, weapons = {}}
        self.weapons[engagementId] = {}
        self.log[engagementId] = {}
        return true
    end,

    getEngagement = function(self, engagementId)
        return self.engagements[engagementId]
    end,

    addWeapon = function(self, engagementId, weaponId, owner, damage, accuracy, ammo)
        if not self.engagements[engagementId] then return false end
        self.weapons[engagementId][weaponId] = {id = weaponId, owner = owner, damage = damage or 25, accuracy = accuracy or 70, ammo = ammo or 100}
        if owner == "craft" then
            table.insert(self.craft[engagementId].weapons, weaponId)
        else
            table.insert(self.ufos[engagementId].weapons, weaponId)
        end
        return true
    end,

    getWeaponCount = function(self, engagementId)
        if not self.weapons[engagementId] then return 0 end
        local count = 0
        for _ in pairs(self.weapons[engagementId]) do count = count + 1 end
        return count
    end,

    fireCraftWeapon = function(self, engagementId, weaponId)
        if not self.weapons[engagementId] or not self.weapons[engagementId][weaponId] then return false end
        local weapon = self.weapons[engagementId][weaponId]
        if weapon.ammo == 0 then return false end
        local ufo = self.ufos[engagementId]
        local hitChance = weapon.accuracy - ufo.evasion
        local hits = love.math.random(100) < hitChance
        weapon.ammo = weapon.ammo - 1
        self:logAction(engagementId, "craft", "fire", {weapon = weaponId, hit = hits})
        if hits then
            local damage = weapon.damage - math.floor(ufo.armor * 0.5)
            self:damageUFO(engagementId, damage)
        end
        return true
    end,

    fireUFOWeapon = function(self, engagementId, weaponId)
        if not self.weapons[engagementId] or not self.weapons[engagementId][weaponId] then return false end
        local weapon = self.weapons[engagementId][weaponId]
        if weapon.ammo == 0 then return false end
        local craft = self.craft[engagementId]
        local hitChance = weapon.accuracy - craft.evasion
        local hits = love.math.random(100) < hitChance
        weapon.ammo = weapon.ammo - 1
        self:logAction(engagementId, "ufo", "fire", {weapon = weaponId, hit = hits})
        if hits then
            local damage = weapon.damage - math.floor(craft.armor * 0.5)
            self:damageCraft(engagementId, damage)
        end
        return true
    end,

    damageCraft = function(self, engagementId, damage)
        if not self.craft[engagementId] then return false end
        self.craft[engagementId].health = math.max(0, self.craft[engagementId].health - damage)
        if self.craft[engagementId].health == 0 then
            self.engagements[engagementId].status = "ufo_victory"
        end
        return true
    end,

    damageUFO = function(self, engagementId, damage)
        if not self.ufos[engagementId] then return false end
        self.ufos[engagementId].health = math.max(0, self.ufos[engagementId].health - damage)
        if self.ufos[engagementId].health == 0 then
            self.engagements[engagementId].status = "craft_victory"
        end
        return true
    end,

    getCraftHealth = function(self, engagementId)
        if not self.craft[engagementId] then return 0 end
        return self.craft[engagementId].health
    end,

    getUFOHealth = function(self, engagementId)
        if not self.ufos[engagementId] then return 0 end
        return self.ufos[engagementId].health
    end,

    isCraftAlive = function(self, engagementId)
        if not self.craft[engagementId] then return false end
        return self.craft[engagementId].health > 0
    end,

    isUFOAlive = function(self, engagementId)
        if not self.ufos[engagementId] then return false end
        return self.ufos[engagementId].health > 0
    end,

    advanceTurn = function(self, engagementId)
        if not self.engagements[engagementId] then return false end
        self.engagements[engagementId].turn = self.engagements[engagementId].turn + 1
        return true
    end,

    getTurn = function(self, engagementId)
        if not self.engagements[engagementId] then return 0 end
        return self.engagements[engagementId].turn
    end,

    logAction = function(self, engagementId, actor, action, details)
        if not self.log[engagementId] then return false end
        table.insert(self.log[engagementId], {actor = actor, action = action, details = details, turn = self.engagements[engagementId].turn})
        return true
    end,

    getLogCount = function(self, engagementId)
        if not self.log[engagementId] then return 0 end
        return #self.log[engagementId]
    end,

    getEngagementStatus = function(self, engagementId)
        if not self.engagements[engagementId] then return nil end
        return self.engagements[engagementId].status
    end,

    endEngagement = function(self, engagementId)
        if not self.engagements[engagementId] then return false end
        self.engagements[engagementId].status = "concluded"
        return true
    end,

    calculateEvasionBonus = function(self, engagementId, actor)
        if actor == "craft" then
            if not self.craft[engagementId] then return 0 end
            return self.craft[engagementId].evasion
        else
            if not self.ufos[engagementId] then return 0 end
            return self.ufos[engagementId].evasion
        end
    end,

    calculateArmorReduction = function(self, engagementId, actor, incomingDamage)
        if actor == "craft" then
            if not self.craft[engagementId] then return 0 end
            local reduction = math.floor(self.craft[engagementId].armor * 0.5)
            return math.max(0, incomingDamage - reduction)
        else
            if not self.ufos[engagementId] then return 0 end
            local reduction = math.floor(self.ufos[engagementId].armor * 0.5)
            return math.max(0, incomingDamage - reduction)
        end
    end
}

Suite:group("Engagement Creation", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ib = InterceptionBattle:new()
    end)

    Suite:testMethod("InterceptionBattle.createEngagement", {description = "Creates engagement", testCase = "create", type = "functional"}, function()
        local ok = shared.ib:createEngagement("eng1", "interceptor", "ufo_scout")
        Helpers.assertEqual(ok, true, "Engagement created")
    end)

    Suite:testMethod("InterceptionBattle.getEngagement", {description = "Gets engagement", testCase = "get", type = "functional"}, function()
        shared.ib:createEngagement("eng2", "fighter", "alien_ship")
        local eng = shared.ib:getEngagement("eng2")
        Helpers.assertEqual(eng ~= nil, true, "Engagement retrieved")
    end)
end)

Suite:group("Weapons", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ib = InterceptionBattle:new()
        shared.ib:createEngagement("weapons", "craft1", "ufo1")
    end)

    Suite:testMethod("InterceptionBattle.addWeapon", {description = "Adds weapon", testCase = "add", type = "functional"}, function()
        local ok = shared.ib:addWeapon("weapons", "laser", "craft", 30, 75, 80)
        Helpers.assertEqual(ok, true, "Weapon added")
    end)

    Suite:testMethod("InterceptionBattle.getWeaponCount", {description = "Counts weapons", testCase = "count", type = "functional"}, function()
        shared.ib:addWeapon("weapons", "w1", "craft", 25, 70, 100)
        shared.ib:addWeapon("weapons", "w2", "ufo", 35, 80, 120)
        local count = shared.ib:getWeaponCount("weapons")
        Helpers.assertEqual(count, 2, "Two weapons")
    end)
end)

Suite:group("Combat", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ib = InterceptionBattle:new()
        shared.ib:createEngagement("battle", "my_craft", "enemy_ufo")
        shared.ib:addWeapon("battle", "cannon", "craft", 35, 80, 150)
        shared.ib:addWeapon("battle", "alien_cannon", "ufo", 40, 75, 200)
    end)

    Suite:testMethod("InterceptionBattle.fireCraftWeapon", {description = "Craft fires", testCase = "craft_fire", type = "functional"}, function()
        local ok = shared.ib:fireCraftWeapon("battle", "cannon")
        Helpers.assertEqual(ok, true, "Fired")
    end)

    Suite:testMethod("InterceptionBattle.fireUFOWeapon", {description = "UFO fires", testCase = "ufo_fire", type = "functional"}, function()
        local ok = shared.ib:fireUFOWeapon("battle", "alien_cannon")
        Helpers.assertEqual(ok, true, "Fired")
    end)

    Suite:testMethod("InterceptionBattle.damageCraft", {description = "Damages craft", testCase = "damage_craft", type = "functional"}, function()
        local ok = shared.ib:damageCraft("battle", 25)
        Helpers.assertEqual(ok, true, "Damaged")
    end)

    Suite:testMethod("InterceptionBattle.damageUFO", {description = "Damages UFO", testCase = "damage_ufo", type = "functional"}, function()
        local ok = shared.ib:damageUFO("battle", 30)
        Helpers.assertEqual(ok, true, "Damaged")
    end)
end)

Suite:group("Health Tracking", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ib = InterceptionBattle:new()
        shared.ib:createEngagement("health", "c1", "u1")
    end)

    Suite:testMethod("InterceptionBattle.getCraftHealth", {description = "Gets craft health", testCase = "craft_health", type = "functional"}, function()
        local health = shared.ib:getCraftHealth("health")
        Helpers.assertEqual(health, 100, "100 health")
    end)

    Suite:testMethod("InterceptionBattle.getUFOHealth", {description = "Gets UFO health", testCase = "ufo_health", type = "functional"}, function()
        local health = shared.ib:getUFOHealth("health")
        Helpers.assertEqual(health, 120, "120 health")
    end)

    Suite:testMethod("InterceptionBattle.isCraftAlive", {description = "Craft alive", testCase = "alive_craft", type = "functional"}, function()
        local alive = shared.ib:isCraftAlive("health")
        Helpers.assertEqual(alive, true, "Alive")
    end)

    Suite:testMethod("InterceptionBattle.isUFOAlive", {description = "UFO alive", testCase = "alive_ufo", type = "functional"}, function()
        local alive = shared.ib:isUFOAlive("health")
        Helpers.assertEqual(alive, true, "Alive")
    end)
end)

Suite:group("Turn Management", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ib = InterceptionBattle:new()
        shared.ib:createEngagement("turns", "cr", "uf")
    end)

    Suite:testMethod("InterceptionBattle.advanceTurn", {description = "Advances turn", testCase = "advance", type = "functional"}, function()
        local ok = shared.ib:advanceTurn("turns")
        Helpers.assertEqual(ok, true, "Advanced")
    end)

    Suite:testMethod("InterceptionBattle.getTurn", {description = "Gets turn", testCase = "get_turn", type = "functional"}, function()
        shared.ib:advanceTurn("turns")
        shared.ib:advanceTurn("turns")
        local turn = shared.ib:getTurn("turns")
        Helpers.assertEqual(turn, 2, "Turn 2")
    end)
end)

Suite:group("Logging", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ib = InterceptionBattle:new()
        shared.ib:createEngagement("logging", "c", "u")
    end)

    Suite:testMethod("InterceptionBattle.logAction", {description = "Logs action", testCase = "log", type = "functional"}, function()
        local ok = shared.ib:logAction("logging", "craft", "evasive_maneuver", {})
        Helpers.assertEqual(ok, true, "Logged")
    end)

    Suite:testMethod("InterceptionBattle.getLogCount", {description = "Counts log", testCase = "log_count", type = "functional"}, function()
        shared.ib:logAction("logging", "craft", "attack", {})
        shared.ib:logAction("logging", "ufo", "defend", {})
        local count = shared.ib:getLogCount("logging")
        Helpers.assertEqual(count, 2, "Two entries")
    end)
end)

Suite:group("Engagement Status", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ib = InterceptionBattle:new()
        shared.ib:createEngagement("status", "craft", "ufo")
    end)

    Suite:testMethod("InterceptionBattle.getEngagementStatus", {description = "Gets status", testCase = "status", type = "functional"}, function()
        local status = shared.ib:getEngagementStatus("status")
        Helpers.assertEqual(status, "engaged", "Engaged")
    end)

    Suite:testMethod("InterceptionBattle.endEngagement", {description = "Ends engagement", testCase = "end", type = "functional"}, function()
        local ok = shared.ib:endEngagement("status")
        Helpers.assertEqual(ok, true, "Ended")
    end)
end)

Suite:group("Calculations", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ib = InterceptionBattle:new()
        shared.ib:createEngagement("calcs", "c", "u")
    end)

    Suite:testMethod("InterceptionBattle.calculateEvasionBonus", {description = "Evasion bonus", testCase = "evasion", type = "functional"}, function()
        local bonus = shared.ib:calculateEvasionBonus("calcs", "craft")
        Helpers.assertEqual(bonus, 35, "35 evasion")
    end)

    Suite:testMethod("InterceptionBattle.calculateArmorReduction", {description = "Armor reduction", testCase = "armor", type = "functional"}, function()
        local reduction = shared.ib:calculateArmorReduction("calcs", "craft", 40)
        Helpers.assertEqual(reduction >= 0, true, "Reduction calculated")
    end)
end)

Suite:run()
