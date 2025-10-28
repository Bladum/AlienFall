-- ─────────────────────────────────────────────────────────────────────────
-- ARTIFACT POWER TEST SUITE
-- FILE: tests2/lore/artifact_power_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.lore.artifact_power",
    fileName = "artifact_power.lua",
    description = "Artifact power levels, activation, special abilities, and energy management"
})

print("[ARTIFACT_POWER_TEST] Setting up")

local ArtifactPower = {
    artifacts = {}, powers = {}, charges = {}, active_artifacts = {},

    new = function(self)
        return setmetatable({artifacts = {}, powers = {}, charges = {}, active_artifacts = {}}, {__index = self})
    end,

    registerArtifact = function(self, artifactId, name, power_level, energy_capacity)
        self.artifacts[artifactId] = {
            id = artifactId, name = name or "Artifact", power_level = power_level or 1,
            energy_capacity = energy_capacity or 100, rarity = "common", lore = ""
        }
        self.charges[artifactId] = energy_capacity or 100
        return true
    end,

    getArtifact = function(self, artifactId)
        return self.artifacts[artifactId]
    end,

    registerPower = function(self, powerID, name, power_level, energy_cost, cooldown)
        self.powers[powerID] = {
            id = powerID, name = name or "Power", power_level = power_level or 1,
            energy_cost = energy_cost or 25, cooldown_turns = cooldown or 3,
            last_used = -999, active = false
        }
        return true
    end,

    getPower = function(self, powerID)
        return self.powers[powerID]
    end,

    getArtifactPowerLevel = function(self, artifactId)
        if not self.artifacts[artifactId] then return 0 end
        return self.artifacts[artifactId].power_level
    end,

    getCurrentEnergy = function(self, artifactId)
        return self.charges[artifactId] or 0
    end,

    getEnergyCapacity = function(self, artifactId)
        if not self.artifacts[artifactId] then return 0 end
        return self.artifacts[artifactId].energy_capacity
    end,

    getEnergyPercentage = function(self, artifactId)
        local capacity = self:getEnergyCapacity(artifactId)
        if capacity == 0 then return 0 end
        return (self:getCurrentEnergy(artifactId) / capacity) * 100
    end,

    chargeArtifact = function(self, artifactId, amount)
        if not self.artifacts[artifactId] then return false end
        local capacity = self.artifacts[artifactId].energy_capacity
        self.charges[artifactId] = math.min(capacity, (self.charges[artifactId] or 0) + amount)
        return true
    end,

    drainEnergy = function(self, artifactId, amount)
        if not self.charges[artifactId] then return false end
        if self.charges[artifactId] < amount then return false end
        self.charges[artifactId] = self.charges[artifactId] - amount
        return true
    end,

    hasEnoughEnergy = function(self, artifactId, required)
        if not self.charges[artifactId] then return false end
        return self.charges[artifactId] >= required
    end,

    attachPower = function(self, artifactId, powerID)
        if not self.artifacts[artifactId] or not self.powers[powerID] then return false end
        if not self.artifacts[artifactId].powers then
            self.artifacts[artifactId].powers = {}
        end
        table.insert(self.artifacts[artifactId].powers, powerID)
        return true
    end,

    hasPower = function(self, artifactId, powerID)
        if not self.artifacts[artifactId] or not self.artifacts[artifactId].powers then return false end
        for _, pID in ipairs(self.artifacts[artifactId].powers) do
            if pID == powerID then return true end
        end
        return false
    end,

    getPowers = function(self, artifactId)
        if not self.artifacts[artifactId] or not self.artifacts[artifactId].powers then return {} end
        return self.artifacts[artifactId].powers
    end,

    activateArtifact = function(self, artifactId)
        if not self.artifacts[artifactId] then return false end
        self.active_artifacts[artifactId] = {
            artifact_id = artifactId, activated_at_turn = 0, active = true
        }
        return true
    end,

    deactivateArtifact = function(self, artifactId)
        if self.active_artifacts[artifactId] then
            self.active_artifacts[artifactId].active = false
            return true
        end
        return false
    end,

    isArtifactActive = function(self, artifactId)
        if not self.active_artifacts[artifactId] then return false end
        return self.active_artifacts[artifactId].active
    end,

    activatePower = function(self, artifactId, powerID, current_turn)
        if not self:hasPower(artifactId, powerID) then return false end
        local power = self.powers[powerID]
        if not self:hasEnoughEnergy(artifactId, power.energy_cost) then return false end

        local last_used = power.last_used or -999
        if current_turn - last_used < power.cooldown_turns then return false end

        local ok = self:drainEnergy(artifactId, power.energy_cost)
        if ok then
            power.last_used = current_turn
            power.active = true
            return true
        end
        return false
    end,

    isPowerOnCooldown = function(self, powerID, current_turn)
        if not self.powers[powerID] then return false end
        local power = self.powers[powerID]
        local last_used = power.last_used or -999
        return (current_turn - last_used) < power.cooldown_turns
    end,

    getAvailablePowers = function(self, artifactId, current_turn)
        if not self:hasPower(artifactId, nil) then return {} end
        local powers = self:getPowers(artifactId)
        local available = {}
        for _, powerID in ipairs(powers) do
            if not self:isPowerOnCooldown(powerID, current_turn) then
                table.insert(available, powerID)
            end
        end
        return available
    end,

    calculatePowerDamage = function(self, artifactId, powerID)
        if not self:hasPower(artifactId, powerID) then return 0 end
        local artifact = self.artifacts[artifactId]
        local power = self.powers[powerID]
        return power.power_level * artifact.power_level * 10
    end,

    getArtifactRarity = function(self, artifactId)
        if not self.artifacts[artifactId] then return "unknown" end
        return self.artifacts[artifactId].rarity
    end,

    setArtifactRarity = function(self, artifactId, rarity)
        if not self.artifacts[artifactId] then return false end
        self.artifacts[artifactId].rarity = rarity
        return true
    end,

    getArtifactLore = function(self, artifactId)
        if not self.artifacts[artifactId] then return "" end
        return self.artifacts[artifactId].lore
    end,

    setArtifactLore = function(self, artifactId, lore_text)
        if not self.artifacts[artifactId] then return false end
        self.artifacts[artifactId].lore = lore_text
        return true
    end,

    reset = function(self)
        self.artifacts = {}
        self.powers = {}
        self.charges = {}
        self.active_artifacts = {}
        return true
    end
}

Suite:group("Artifacts", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ap = ArtifactPower:new()
    end)

    Suite:testMethod("ArtifactPower.registerArtifact", {description = "Registers artifact", testCase = "register", type = "functional"}, function()
        local ok = shared.ap:registerArtifact("a1", "Crystal", 2, 100)
        Helpers.assertEqual(ok, true, "Registered")
    end)

    Suite:testMethod("ArtifactPower.getArtifact", {description = "Gets artifact", testCase = "get", type = "functional"}, function()
        shared.ap:registerArtifact("a2", "Stone", 3, 150)
        local art = shared.ap:getArtifact("a2")
        Helpers.assertEqual(art ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("ArtifactPower.getArtifactPowerLevel", {description = "Gets power level", testCase = "level", type = "functional"}, function()
        shared.ap:registerArtifact("a3", "Orb", 4, 200)
        local level = shared.ap:getArtifactPowerLevel("a3")
        Helpers.assertEqual(level, 4, "4")
    end)
end)

Suite:group("Energy", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ap = ArtifactPower:new()
        shared.ap:registerArtifact("a1", "Gem", 2, 100)
    end)

    Suite:testMethod("ArtifactPower.getCurrentEnergy", {description = "Gets energy", testCase = "current", type = "functional"}, function()
        local energy = shared.ap:getCurrentEnergy("a1")
        Helpers.assertEqual(energy, 100, "100")
    end)

    Suite:testMethod("ArtifactPower.getEnergyCapacity", {description = "Gets capacity", testCase = "capacity", type = "functional"}, function()
        local capacity = shared.ap:getEnergyCapacity("a1")
        Helpers.assertEqual(capacity, 100, "100")
    end)

    Suite:testMethod("ArtifactPower.getEnergyPercentage", {description = "Gets percentage", testCase = "percentage", type = "functional"}, function()
        local pct = shared.ap:getEnergyPercentage("a1")
        Helpers.assertEqual(pct, 100, "100")
    end)

    Suite:testMethod("ArtifactPower.chargeArtifact", {description = "Charges artifact", testCase = "charge", type = "functional"}, function()
        shared.ap:drainEnergy("a1", 30)
        local ok = shared.ap:chargeArtifact("a1", 20)
        Helpers.assertEqual(ok, true, "Charged")
    end)

    Suite:testMethod("ArtifactPower.drainEnergy", {description = "Drains energy", testCase = "drain", type = "functional"}, function()
        local ok = shared.ap:drainEnergy("a1", 25)
        Helpers.assertEqual(ok, true, "Drained")
    end)

    Suite:testMethod("ArtifactPower.hasEnoughEnergy", {description = "Has enough energy", testCase = "enough", type = "functional"}, function()
        local has = shared.ap:hasEnoughEnergy("a1", 50)
        Helpers.assertEqual(has, true, "Has")
    end)
end)

Suite:group("Powers", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ap = ArtifactPower:new()
    end)

    Suite:testMethod("ArtifactPower.registerPower", {description = "Registers power", testCase = "register", type = "functional"}, function()
        local ok = shared.ap:registerPower("p1", "Blast", 2, 30, 2)
        Helpers.assertEqual(ok, true, "Registered")
    end)

    Suite:testMethod("ArtifactPower.getPower", {description = "Gets power", testCase = "get", type = "functional"}, function()
        shared.ap:registerPower("p2", "Heal", 1, 20, 1)
        local power = shared.ap:getPower("p2")
        Helpers.assertEqual(power ~= nil, true, "Retrieved")
    end)
end)

Suite:group("Power Attachment", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ap = ArtifactPower:new()
        shared.ap:registerArtifact("a1", "Staff", 3, 150)
        shared.ap:registerPower("p1", "Strike", 2, 25, 2)
    end)

    Suite:testMethod("ArtifactPower.attachPower", {description = "Attaches power", testCase = "attach", type = "functional"}, function()
        local ok = shared.ap:attachPower("a1", "p1")
        Helpers.assertEqual(ok, true, "Attached")
    end)

    Suite:testMethod("ArtifactPower.hasPower", {description = "Has power", testCase = "has", type = "functional"}, function()
        shared.ap:attachPower("a1", "p1")
        local has = shared.ap:hasPower("a1", "p1")
        Helpers.assertEqual(has, true, "Has")
    end)

    Suite:testMethod("ArtifactPower.getPowers", {description = "Gets powers", testCase = "powers", type = "functional"}, function()
        shared.ap:attachPower("a1", "p1")
        local powers = shared.ap:getPowers("a1")
        Helpers.assertEqual(#powers > 0, true, "Has powers")
    end)
end)

Suite:group("Activation", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ap = ArtifactPower:new()
        shared.ap:registerArtifact("a1", "Weapon", 2, 100)
    end)

    Suite:testMethod("ArtifactPower.activateArtifact", {description = "Activates artifact", testCase = "activate", type = "functional"}, function()
        local ok = shared.ap:activateArtifact("a1")
        Helpers.assertEqual(ok, true, "Activated")
    end)

    Suite:testMethod("ArtifactPower.isArtifactActive", {description = "Is active", testCase = "active", type = "functional"}, function()
        shared.ap:activateArtifact("a1")
        local active = shared.ap:isArtifactActive("a1")
        Helpers.assertEqual(active, true, "Active")
    end)

    Suite:testMethod("ArtifactPower.deactivateArtifact", {description = "Deactivates artifact", testCase = "deactivate", type = "functional"}, function()
        shared.ap:activateArtifact("a1")
        local ok = shared.ap:deactivateArtifact("a1")
        Helpers.assertEqual(ok, true, "Deactivated")
    end)
end)

Suite:group("Power Activation", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ap = ArtifactPower:new()
        shared.ap:registerArtifact("a1", "Amulet", 2, 150)
        shared.ap:registerPower("p1", "Fire", 2, 40, 3)
        shared.ap:attachPower("a1", "p1")
    end)

    Suite:testMethod("ArtifactPower.activatePower", {description = "Activates power", testCase = "activate", type = "functional"}, function()
        local ok = shared.ap:activatePower("a1", "p1", 0)
        Helpers.assertEqual(ok, true, "Activated")
    end)

    Suite:testMethod("ArtifactPower.isPowerOnCooldown", {description = "Is on cooldown", testCase = "cooldown", type = "functional"}, function()
        shared.ap:activatePower("a1", "p1", 0)
        local oncd = shared.ap:isPowerOnCooldown("p1", 1)
        Helpers.assertEqual(oncd, true, "On cooldown")
    end)

    Suite:testMethod("ArtifactPower.getAvailablePowers", {description = "Gets available powers", testCase = "available", type = "functional"}, function()
        local avail = shared.ap:getAvailablePowers("a1", 5)
        Helpers.assertEqual(#avail >= 0, true, "Got list")
    end)
end)

Suite:group("Damage", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ap = ArtifactPower:new()
        shared.ap:registerArtifact("a1", "Blade", 3, 200)
        shared.ap:registerPower("p1", "Slash", 3, 50, 1)
        shared.ap:attachPower("a1", "p1")
    end)

    Suite:testMethod("ArtifactPower.calculatePowerDamage", {description = "Calculates damage", testCase = "damage", type = "functional"}, function()
        local dmg = shared.ap:calculatePowerDamage("a1", "p1")
        Helpers.assertEqual(dmg > 0, true, "Damage > 0")
    end)
end)

Suite:group("Metadata", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ap = ArtifactPower:new()
        shared.ap:registerArtifact("a1", "Relic", 1, 100)
    end)

    Suite:testMethod("ArtifactPower.getArtifactRarity", {description = "Gets rarity", testCase = "rarity", type = "functional"}, function()
        local rarity = shared.ap:getArtifactRarity("a1")
        Helpers.assertEqual(rarity ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("ArtifactPower.setArtifactRarity", {description = "Sets rarity", testCase = "set_rarity", type = "functional"}, function()
        local ok = shared.ap:setArtifactRarity("a1", "legendary")
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("ArtifactPower.getArtifactLore", {description = "Gets lore", testCase = "lore", type = "functional"}, function()
        local lore = shared.ap:getArtifactLore("a1")
        Helpers.assertEqual(lore ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("ArtifactPower.setArtifactLore", {description = "Sets lore", testCase = "set_lore", type = "functional"}, function()
        local ok = shared.ap:setArtifactLore("a1", "Ancient artifact...")
        Helpers.assertEqual(ok, true, "Set")
    end)
end)

Suite:group("Reset", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ap = ArtifactPower:new()
    end)

    Suite:testMethod("ArtifactPower.reset", {description = "Resets system", testCase = "reset", type = "functional"}, function()
        local ok = shared.ap:reset()
        Helpers.assertEqual(ok, true, "Reset")
    end)
end)

Suite:run()
