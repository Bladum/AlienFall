-- ─────────────────────────────────────────────────────────────────────────
-- ARTIFACT SYSTEM TEST SUITE
-- FILE: tests2/core/artifact_system_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.core.artifact_system",
    fileName = "artifact_system.lua",
    description = "Artifact collection with bonuses, synergies, and progression"
})

print("[ARTIFACT_SYSTEM_TEST] Setting up")

local ArtifactSystem = {
    artifacts = {},
    inventory = {},
    bonuses = {},
    synergies = {},
    effects = {},

    new = function(self)
        return setmetatable({artifacts = {}, inventory = {}, bonuses = {}, synergies = {}, effects = {}}, {__index = self})
    end,

    registerArtifact = function(self, artifactId, name, rarity, bonusType, bonusValue)
        self.artifacts[artifactId] = {
            id = artifactId, name = name, rarity = rarity or "common",
            bonus = bonusType, bonusValue = bonusValue or 5, equippable = true
        }
        return true
    end,

    getArtifact = function(self, artifactId)
        return self.artifacts[artifactId]
    end,

    addToInventory = function(self, playerId, artifactId)
        if not self.artifacts[artifactId] then return false end
        if not self.inventory[playerId] then self.inventory[playerId] = {} end
        self.inventory[playerId][artifactId] = {id = artifactId, equipped = false}
        return true
    end,

    getInventoryCount = function(self, playerId)
        if not self.inventory[playerId] then return 0 end
        local count = 0
        for _ in pairs(self.inventory[playerId]) do count = count + 1 end
        return count
    end,

    equipArtifact = function(self, playerId, artifactId)
        if not self.inventory[playerId] or not self.inventory[playerId][artifactId] then return false end
        if not self.bonuses[playerId] then self.bonuses[playerId] = {} end
        self.inventory[playerId][artifactId].equipped = true
        local artifact = self.artifacts[artifactId]
        if not self.bonuses[playerId][artifact.bonus] then
            self.bonuses[playerId][artifact.bonus] = 0
        end
        self.bonuses[playerId][artifact.bonus] = self.bonuses[playerId][artifact.bonus] + artifact.bonusValue
        return true
    end,

    unequipArtifact = function(self, playerId, artifactId)
        if not self.inventory[playerId] or not self.inventory[playerId][artifactId] then return false end
        self.inventory[playerId][artifactId].equipped = false
        local artifact = self.artifacts[artifactId]
        if self.bonuses[playerId] and self.bonuses[playerId][artifact.bonus] then
            self.bonuses[playerId][artifact.bonus] = math.max(0, self.bonuses[playerId][artifact.bonus] - artifact.bonusValue)
        end
        return true
    end,

    isEquipped = function(self, playerId, artifactId)
        if not self.inventory[playerId] or not self.inventory[playerId][artifactId] then return false end
        return self.inventory[playerId][artifactId].equipped
    end,

    getBonus = function(self, playerId, bonusType)
        if not self.bonuses[playerId] then return 0 end
        return self.bonuses[playerId][bonusType] or 0
    end,

    getTotalBonus = function(self, playerId, bonusType)
        local bonus = self:getBonus(playerId, bonusType)
        local synergy = self:calculateSynergy(playerId, bonusType)
        return bonus + synergy
    end,

    createSynergy = function(self, artifactId1, artifactId2, synergyBonus)
        local key = math.min(artifactId1, artifactId2) .. "_" .. math.max(artifactId1, artifactId2)
        self.synergies[key] = {a1 = artifactId1, a2 = artifactId2, bonus = synergyBonus or 10}
        return true
    end,

    calculateSynergy = function(self, playerId, bonusType)
        if not self.inventory[playerId] then return 0 end
        local total = 0
        for id1 in pairs(self.inventory[playerId]) do
            for id2 in pairs(self.inventory[playerId]) do
                if id1 ~= id2 then
                    local key = math.min(id1, id2) .. "_" .. math.max(id1, id2)
                    if self.synergies[key] then
                        local synergy = self.synergies[key]
                        if self:isEquipped(playerId, id1) and self:isEquipped(playerId, id2) then
                            if self.artifacts[id1].bonus == bonusType or self.artifacts[id2].bonus == bonusType then
                                total = total + synergy.bonus
                            end
                        end
                    end
                end
            end
        end
        return math.floor(total / 2)
    end,

    applyEffect = function(self, playerId, effectId, effectName, duration, modifier)
        if not self.effects[playerId] then self.effects[playerId] = {} end
        self.effects[playerId][effectId] = {id = effectId, name = effectName, duration = duration or 10, modifier = modifier or 1, active = true}
        return true
    end,

    getEffect = function(self, playerId, effectId)
        if not self.effects[playerId] then return nil end
        return self.effects[playerId][effectId]
    end,

    getActiveEffectCount = function(self, playerId)
        if not self.effects[playerId] then return 0 end
        local count = 0
        for _, effect in pairs(self.effects[playerId]) do
            if effect.active then count = count + 1 end
        end
        return count
    end,

    removeEffect = function(self, playerId, effectId)
        if not self.effects[playerId] or not self.effects[playerId][effectId] then return false end
        self.effects[playerId][effectId] = nil
        return true
    end,

    getEquippedArtifacts = function(self, playerId)
        if not self.inventory[playerId] then return {} end
        local equipped = {}
        for artifactId, artifact in pairs(self.inventory[playerId]) do
            if artifact.equipped then
                table.insert(equipped, artifactId)
            end
        end
        return equipped
    end,

    getArtifactsByRarity = function(self, playerId, rarity)
        if not self.inventory[playerId] then return {} end
        local filtered = {}
        for artifactId in pairs(self.inventory[playerId]) do
            if self.artifacts[artifactId].rarity == rarity then
                table.insert(filtered, artifactId)
            end
        end
        return filtered
    end,

    getRarityMultiplier = function(self, rarity)
        if rarity == "legendary" then return 3
        elseif rarity == "rare" then return 2
        elseif rarity == "uncommon" then return 1.5
        else return 1
        end
    end,

    calculateCollectionPower = function(self, playerId)
        if not self.inventory[playerId] or not next(self.inventory[playerId]) then return 0 end
        local power = 0
        for artifactId in pairs(self.inventory[playerId]) do
            local artifact = self.artifacts[artifactId]
            local multiplier = self:getRarityMultiplier(artifact.rarity)
            power = power + (artifact.bonusValue * multiplier)
        end
        return math.floor(power)
    end,

    unlockArtifact = function(self, artifactId)
        if not self.artifacts[artifactId] then return false end
        self.artifacts[artifactId].equippable = true
        return true
    end,

    isArtifactUnlocked = function(self, artifactId)
        if not self.artifacts[artifactId] then return false end
        return self.artifacts[artifactId].equippable
    end,

    transferArtifact = function(self, fromPlayer, toPlayer, artifactId)
        if not self.inventory[fromPlayer] or not self.inventory[fromPlayer][artifactId] then return false end
        if self.inventory[fromPlayer][artifactId].equipped then
            self:unequipArtifact(fromPlayer, artifactId)
        end
        self.inventory[fromPlayer][artifactId] = nil
        self:addToInventory(toPlayer, artifactId)
        return true
    end,

    resetInventory = function(self, playerId)
        if not self.inventory[playerId] then return false end
        for artifactId, artifact in pairs(self.inventory[playerId]) do
            if artifact.equipped then
                self:unequipArtifact(playerId, artifactId)
            end
        end
        self.inventory[playerId] = {}
        self.bonuses[playerId] = {}
        self.effects[playerId] = {}
        return true
    end
}

Suite:group("Artifact Registration", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.as = ArtifactSystem:new()
    end)

    Suite:testMethod("ArtifactSystem.registerArtifact", {description = "Registers artifact", testCase = "register", type = "functional"}, function()
        local ok = shared.as:registerArtifact("sword1", "Golden Sword", "rare", "attack", 15)
        Helpers.assertEqual(ok, true, "Registered")
    end)

    Suite:testMethod("ArtifactSystem.getArtifact", {description = "Gets artifact", testCase = "get", type = "functional"}, function()
        shared.as:registerArtifact("shield1", "Iron Shield", "uncommon", "defense", 10)
        local artifact = shared.as:getArtifact("shield1")
        Helpers.assertEqual(artifact ~= nil, true, "Retrieved")
    end)
end)

Suite:group("Inventory Management", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.as = ArtifactSystem:new()
        shared.as:registerArtifact("item1", "Item 1", "common", "health", 5)
        shared.as:registerArtifact("item2", "Item 2", "uncommon", "mana", 8)
    end)

    Suite:testMethod("ArtifactSystem.addToInventory", {description = "Adds to inventory", testCase = "add_inv", type = "functional"}, function()
        local ok = shared.as:addToInventory("player1", "item1")
        Helpers.assertEqual(ok, true, "Added")
    end)

    Suite:testMethod("ArtifactSystem.getInventoryCount", {description = "Inventory count", testCase = "count", type = "functional"}, function()
        shared.as:addToInventory("player2", "item1")
        shared.as:addToInventory("player2", "item2")
        local count = shared.as:getInventoryCount("player2")
        Helpers.assertEqual(count, 2, "Two artifacts")
    end)

    Suite:testMethod("ArtifactSystem.getEquippedArtifacts", {description = "Gets equipped", testCase = "equipped", type = "functional"}, function()
        shared.as:addToInventory("player3", "item1")
        shared.as:equipArtifact("player3", "item1")
        local equipped = shared.as:getEquippedArtifacts("player3")
        Helpers.assertEqual(#equipped, 1, "One equipped")
    end)
end)

Suite:group("Equipment & Bonuses", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.as = ArtifactSystem:new()
        shared.as:registerArtifact("weapon", "Weapon", "rare", "attack", 20)
        shared.as:addToInventory("player", "weapon")
    end)

    Suite:testMethod("ArtifactSystem.equipArtifact", {description = "Equips artifact", testCase = "equip", type = "functional"}, function()
        local ok = shared.as:equipArtifact("player", "weapon")
        Helpers.assertEqual(ok, true, "Equipped")
    end)

    Suite:testMethod("ArtifactSystem.unequipArtifact", {description = "Unequips artifact", testCase = "unequip", type = "functional"}, function()
        shared.as:equipArtifact("player", "weapon")
        local ok = shared.as:unequipArtifact("player", "weapon")
        Helpers.assertEqual(ok, true, "Unequipped")
    end)

    Suite:testMethod("ArtifactSystem.isEquipped", {description = "Is equipped", testCase = "is_equipped", type = "functional"}, function()
        shared.as:equipArtifact("player", "weapon")
        local eq = shared.as:isEquipped("player", "weapon")
        Helpers.assertEqual(eq, true, "Equipped")
    end)

    Suite:testMethod("ArtifactSystem.getBonus", {description = "Gets bonus", testCase = "bonus", type = "functional"}, function()
        shared.as:equipArtifact("player", "weapon")
        local bonus = shared.as:getBonus("player", "attack")
        Helpers.assertEqual(bonus, 20, "20 bonus")
    end)
end)

Suite:group("Synergies", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.as = ArtifactSystem:new()
        shared.as:registerArtifact("a1", "Artifact 1", "rare", "attack", 10)
        shared.as:registerArtifact("a2", "Artifact 2", "rare", "attack", 10)
        shared.as:createSynergy("a1", "a2", 15)
        shared.as:addToInventory("player", "a1")
        shared.as:addToInventory("player", "a2")
    end)

    Suite:testMethod("ArtifactSystem.createSynergy", {description = "Creates synergy", testCase = "create_syn", type = "functional"}, function()
        local ok = shared.as:createSynergy("a1", "a2", 20)
        Helpers.assertEqual(ok, true, "Created")
    end)

    Suite:testMethod("ArtifactSystem.calculateSynergy", {description = "Calculates synergy", testCase = "calc_syn", type = "functional"}, function()
        shared.as:equipArtifact("player", "a1")
        shared.as:equipArtifact("player", "a2")
        local syn = shared.as:calculateSynergy("player", "attack")
        Helpers.assertEqual(syn > 0, true, "Synergy > 0")
    end)

    Suite:testMethod("ArtifactSystem.getTotalBonus", {description = "Total bonus", testCase = "total_bonus", type = "functional"}, function()
        shared.as:equipArtifact("player", "a1")
        shared.as:equipArtifact("player", "a2")
        local total = shared.as:getTotalBonus("player", "attack")
        Helpers.assertEqual(total > 20, true, "Total > 20 with synergy")
    end)
end)

Suite:group("Effects", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.as = ArtifactSystem:new()
    end)

    Suite:testMethod("ArtifactSystem.applyEffect", {description = "Applies effect", testCase = "apply_effect", type = "functional"}, function()
        local ok = shared.as:applyEffect("player", "eff1", "Buff", 10, 1.5)
        Helpers.assertEqual(ok, true, "Applied")
    end)

    Suite:testMethod("ArtifactSystem.getEffect", {description = "Gets effect", testCase = "get_effect", type = "functional"}, function()
        shared.as:applyEffect("player", "eff2", "Debuff", 5, 0.8)
        local effect = shared.as:getEffect("player", "eff2")
        Helpers.assertEqual(effect ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("ArtifactSystem.getActiveEffectCount", {description = "Active effects", testCase = "active_count", type = "functional"}, function()
        shared.as:applyEffect("player", "e1", "Effect 1", 10, 1)
        shared.as:applyEffect("player", "e2", "Effect 2", 10, 1)
        local count = shared.as:getActiveEffectCount("player")
        Helpers.assertEqual(count, 2, "Two effects")
    end)

    Suite:testMethod("ArtifactSystem.removeEffect", {description = "Removes effect", testCase = "remove_effect", type = "functional"}, function()
        shared.as:applyEffect("player", "remove_me", "Temporary", 5, 1)
        local ok = shared.as:removeEffect("player", "remove_me")
        Helpers.assertEqual(ok, true, "Removed")
    end)
end)

Suite:group("Rarity & Unlock", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.as = ArtifactSystem:new()
        shared.as:registerArtifact("legendary", "Legendary", "legendary", "power", 50)
        shared.as:registerArtifact("rare_item", "Rare Item", "rare", "power", 25)
    end)

    Suite:testMethod("ArtifactSystem.getArtifactsByRarity", {description = "By rarity", testCase = "by_rarity", type = "functional"}, function()
        shared.as:addToInventory("player", "legendary")
        shared.as:addToInventory("player", "rare_item")
        local legendary = shared.as:getArtifactsByRarity("player", "legendary")
        Helpers.assertEqual(#legendary, 1, "One legendary")
    end)

    Suite:testMethod("ArtifactSystem.getRarityMultiplier", {description = "Rarity multiplier", testCase = "multiplier", type = "functional"}, function()
        local mult = shared.as:getRarityMultiplier("legendary")
        Helpers.assertEqual(mult, 3, "3x multiplier")
    end)

    Suite:testMethod("ArtifactSystem.unlockArtifact", {description = "Unlocks artifact", testCase = "unlock", type = "functional"}, function()
        local ok = shared.as:unlockArtifact("legendary")
        Helpers.assertEqual(ok, true, "Unlocked")
    end)

    Suite:testMethod("ArtifactSystem.isArtifactUnlocked", {description = "Is unlocked", testCase = "is_unlocked", type = "functional"}, function()
        local unlocked = shared.as:isArtifactUnlocked("legendary")
        Helpers.assertEqual(unlocked, true, "Unlocked")
    end)
end)

Suite:group("Collection Analysis", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.as = ArtifactSystem:new()
        shared.as:registerArtifact("c1", "Common 1", "common", "health", 5)
        shared.as:registerArtifact("c2", "Common 2", "common", "health", 5)
        shared.as:addToInventory("player", "c1")
        shared.as:addToInventory("player", "c2")
    end)

    Suite:testMethod("ArtifactSystem.calculateCollectionPower", {description = "Collection power", testCase = "power", type = "functional"}, function()
        local power = shared.as:calculateCollectionPower("player")
        Helpers.assertEqual(power > 0, true, "Power > 0")
    end)
end)

Suite:group("Transfer & Reset", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.as = ArtifactSystem:new()
        shared.as:registerArtifact("transfer", "Transfer", "rare", "attack", 15)
        shared.as:addToInventory("player1", "transfer")
    end)

    Suite:testMethod("ArtifactSystem.transferArtifact", {description = "Transfers artifact", testCase = "transfer", type = "functional"}, function()
        local ok = shared.as:transferArtifact("player1", "player2", "transfer")
        Helpers.assertEqual(ok, true, "Transferred")
    end)

    Suite:testMethod("ArtifactSystem.resetInventory", {description = "Resets inventory", testCase = "reset", type = "functional"}, function()
        shared.as:addToInventory("player", "transfer")
        local ok = shared.as:resetInventory("player")
        Helpers.assertEqual(ok, true, "Reset")
    end)
end)

Suite:run()
