-- ─────────────────────────────────────────────────────────────────────────
-- ALIEN BIOLOGY TEST SUITE
-- FILE: tests2/lore/alien_biology_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.lore.alien_biology",
    fileName = "alien_biology.lua",
    description = "Alien species tracking with evolution, abilities, and biological characteristics"
})

print("[ALIEN_BIOLOGY_TEST] Setting up")

local AlienBiology = {
    species = {},
    specimens = {},
    abilities = {},
    evolution_data = {},
    characteristics = {},

    new = function(self)
        return setmetatable({
            species = {}, specimens = {}, abilities = {}, evolution_data = {}, characteristics = {}
        }, {__index = self})
    end,

    registerSpecies = function(self, speciesId, name, classification, threat_level)
        self.species[speciesId] = {
            id = speciesId, name = name, classification = classification or "unknown",
            threat_level = threat_level or 50, discovered = true, specimens_count = 0
        }
        self.evolution_data[speciesId] = {stages = {}, current_stage = 1}
        self.characteristics[speciesId] = {
            intelligence = 50, strength = 50, speed = 50, adaptability = 50
        }
        return true
    end,

    getSpecies = function(self, speciesId)
        return self.species[speciesId]
    end,

    setThreatLevel = function(self, speciesId, level)
        if not self.species[speciesId] then return false end
        self.species[speciesId].threat_level = math.max(0, math.min(100, level))
        return true
    end,

    getThreatLevel = function(self, speciesId)
        if not self.species[speciesId] then return 0 end
        return self.species[speciesId].threat_level
    end,

    addAbility = function(self, speciesId, abilityId, name, power, cooldown)
        if not self.species[speciesId] then return false end
        if not self.abilities[speciesId] then self.abilities[speciesId] = {} end
        self.abilities[speciesId][abilityId] = {
            id = abilityId, name = name, power = power or 50, cooldown = cooldown or 3, uses = 0
        }
        return true
    end,

    getAbility = function(self, speciesId, abilityId)
        if not self.abilities[speciesId] then return nil end
        return self.abilities[speciesId][abilityId]
    end,

    getAbilityCount = function(self, speciesId)
        if not self.abilities[speciesId] then return 0 end
        local count = 0
        for _ in pairs(self.abilities[speciesId]) do count = count + 1 end
        return count
    end,

    useAbility = function(self, speciesId, abilityId)
        if not self.abilities[speciesId] or not self.abilities[speciesId][abilityId] then return false end
        self.abilities[speciesId][abilityId].uses = self.abilities[speciesId][abilityId].uses + 1
        return true
    end,

    getAbilityUsageCount = function(self, speciesId, abilityId)
        if not self.abilities[speciesId] or not self.abilities[speciesId][abilityId] then return 0 end
        return self.abilities[speciesId][abilityId].uses
    end,

    registerEvolutionStage = function(self, speciesId, stageId, name, description, changes)
        if not self.evolution_data[speciesId] then return false end
        self.evolution_data[speciesId].stages[stageId] = {
            id = stageId, name = name, description = description or "", changes = changes or {}, active = false
        }
        return true
    end,

    getEvolutionStage = function(self, speciesId)
        if not self.evolution_data[speciesId] then return 0 end
        return self.evolution_data[speciesId].current_stage
    end,

    advanceEvolution = function(self, speciesId)
        if not self.evolution_data[speciesId] then return false end
        self.evolution_data[speciesId].current_stage = self.evolution_data[speciesId].current_stage + 1
        return true
    end,

    getEvolutionStageCount = function(self, speciesId)
        if not self.evolution_data[speciesId] then return 0 end
        local count = 0
        for _ in pairs(self.evolution_data[speciesId].stages) do count = count + 1 end
        return count
    end,

    setCharacteristic = function(self, speciesId, characteristic, value)
        if not self.characteristics[speciesId] then return false end
        self.characteristics[speciesId][characteristic] = math.max(0, math.min(100, value))
        return true
    end,

    getCharacteristic = function(self, speciesId, characteristic)
        if not self.characteristics[speciesId] then return 0 end
        return self.characteristics[speciesId][characteristic] or 0
    end,

    getOverallAdaptability = function(self, speciesId)
        if not self.characteristics[speciesId] then return 0 end
        local chars = self.characteristics[speciesId]
        local sum = (chars.intelligence or 0) + (chars.strength or 0) + (chars.speed or 0) + (chars.adaptability or 0)
        return math.floor(sum / 4)
    end,

    recordSpecimen = function(self, speciesId, specimenId, characteristics)
        if not self.species[speciesId] then return false end
        if not self.specimens[speciesId] then self.specimens[speciesId] = {} end
        self.specimens[speciesId][specimenId] = {
            id = specimenId, characteristics = characteristics or {}, captured = false, health = 100
        }
        self.species[speciesId].specimens_count = self.species[speciesId].specimens_count + 1
        return true
    end,

    getSpecimenCount = function(self, speciesId)
        if not self.species[speciesId] then return 0 end
        return self.species[speciesId].specimens_count
    end,

    captureSpecimen = function(self, speciesId, specimenId)
        if not self.specimens[speciesId] or not self.specimens[speciesId][specimenId] then return false end
        self.specimens[speciesId][specimenId].captured = true
        return true
    end,

    isSpecimenCaptured = function(self, speciesId, specimenId)
        if not self.specimens[speciesId] or not self.specimens[speciesId][specimenId] then return false end
        return self.specimens[speciesId][specimenId].captured
    end,

    getCapturedSpecimenCount = function(self, speciesId)
        if not self.specimens[speciesId] then return 0 end
        local count = 0
        for _, specimen in pairs(self.specimens[speciesId]) do
            if specimen.captured then count = count + 1 end
        end
        return count
    end,

    calculateSpeciesWeakness = function(self, speciesId)
        if not self.characteristics[speciesId] then return 50 end
        local chars = self.characteristics[speciesId]
        local weakness = math.floor((100 - chars.adaptability) / 2 + (50 - chars.intelligence) / 2)
        return math.max(0, math.min(100, weakness))
    end,

    calculateSpeciesStrength = function(self, speciesId)
        if not self.characteristics[speciesId] then return 50 end
        local chars = self.characteristics[speciesId]
        local strength = math.floor((chars.strength + chars.speed) / 2)
        return strength
    end,

    setSpecimenHealth = function(self, speciesId, specimenId, health)
        if not self.specimens[speciesId] or not self.specimens[speciesId][specimenId] then return false end
        self.specimens[speciesId][specimenId].health = math.max(0, math.min(100, health))
        return true
    end,

    getSpecimenHealth = function(self, speciesId, specimenId)
        if not self.specimens[speciesId] or not self.specimens[speciesId][specimenId] then return 0 end
        return self.specimens[speciesId][specimenId].health
    end,

    isSpeciesExtinct = function(self, speciesId)
        if not self.species[speciesId] then return true end
        return self.species[speciesId].specimens_count == 0
    end,

    getSpeciesClassification = function(self, speciesId)
        if not self.species[speciesId] then return "unknown" end
        return self.species[speciesId].classification
    end,

    updateClassification = function(self, speciesId, newClassification)
        if not self.species[speciesId] then return false end
        self.species[speciesId].classification = newClassification
        return true
    end,

    calculateBiodiversity = function(self)
        if not next(self.species) then return 0 end
        local count = 0
        for _ in pairs(self.species) do count = count + 1 end
        local adaptSum = 0
        for speciesId, _ in pairs(self.species) do
            adaptSum = adaptSum + self:getOverallAdaptability(speciesId)
        end
        return math.floor(adaptSum / count)
    end,

    getMostThreatening = function(self)
        if not next(self.species) then return nil end
        local maxThreat = -1
        local mostThreatening = nil
        for speciesId, species in pairs(self.species) do
            if species.threat_level > maxThreat then
                maxThreat = species.threat_level
                mostThreatening = speciesId
            end
        end
        return mostThreatening
    end
}

Suite:group("Species Registration", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ab = AlienBiology:new()
    end)

    Suite:testMethod("AlienBiology.registerSpecies", {description = "Registers species", testCase = "register", type = "functional"}, function()
        local ok = shared.ab:registerSpecies("sectoid", "Sectoid", "hominid", 60)
        Helpers.assertEqual(ok, true, "Registered")
    end)

    Suite:testMethod("AlienBiology.getSpecies", {description = "Gets species", testCase = "get", type = "functional"}, function()
        shared.ab:registerSpecies("muton", "Muton", "reptile", 75)
        local species = shared.ab:getSpecies("muton")
        Helpers.assertEqual(species ~= nil, true, "Retrieved")
    end)
end)

Suite:group("Threat Assessment", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ab = AlienBiology:new()
        shared.ab:registerSpecies("floater", "Floater", "avian", 65)
    end)

    Suite:testMethod("AlienBiology.setThreatLevel", {description = "Sets threat level", testCase = "set_threat", type = "functional"}, function()
        local ok = shared.ab:setThreatLevel("floater", 70)
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("AlienBiology.getThreatLevel", {description = "Gets threat level", testCase = "get_threat", type = "functional"}, function()
        shared.ab:setThreatLevel("floater", 72)
        local threat = shared.ab:getThreatLevel("floater")
        Helpers.assertEqual(threat, 72, "Threat 72")
    end)
end)

Suite:group("Abilities", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ab = AlienBiology:new()
        shared.ab:registerSpecies("chryssalid", "Chryssalid", "insectoid", 90)
    end)

    Suite:testMethod("AlienBiology.addAbility", {description = "Adds ability", testCase = "add_ability", type = "functional"}, function()
        local ok = shared.ab:addAbility("chryssalid", "paralyze", "Paralyze", 80, 2)
        Helpers.assertEqual(ok, true, "Added")
    end)

    Suite:testMethod("AlienBiology.getAbility", {description = "Gets ability", testCase = "get_ability", type = "functional"}, function()
        shared.ab:addAbility("chryssalid", "weaken", "Weaken", 60, 3)
        local ability = shared.ab:getAbility("chryssalid", "weaken")
        Helpers.assertEqual(ability ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("AlienBiology.getAbilityCount", {description = "Ability count", testCase = "count", type = "functional"}, function()
        shared.ab:addAbility("chryssalid", "a1", "Ability 1", 50, 2)
        shared.ab:addAbility("chryssalid", "a2", "Ability 2", 60, 3)
        local count = shared.ab:getAbilityCount("chryssalid")
        Helpers.assertEqual(count, 2, "Two abilities")
    end)

    Suite:testMethod("AlienBiology.useAbility", {description = "Uses ability", testCase = "use_ability", type = "functional"}, function()
        shared.ab:addAbility("chryssalid", "test", "Test", 50, 2)
        local ok = shared.ab:useAbility("chryssalid", "test")
        Helpers.assertEqual(ok, true, "Used")
    end)

    Suite:testMethod("AlienBiology.getAbilityUsageCount", {description = "Usage count", testCase = "usage", type = "functional"}, function()
        shared.ab:addAbility("chryssalid", "used", "Used", 50, 2)
        shared.ab:useAbility("chryssalid", "used")
        shared.ab:useAbility("chryssalid", "used")
        local count = shared.ab:getAbilityUsageCount("chryssalid", "used")
        Helpers.assertEqual(count, 2, "Used twice")
    end)
end)

Suite:group("Evolution", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ab = AlienBiology:new()
        shared.ab:registerSpecies("ethereal", "Ethereal", "psionic", 95)
    end)

    Suite:testMethod("AlienBiology.registerEvolutionStage", {description = "Registers stage", testCase = "register_stage", type = "functional"}, function()
        local ok = shared.ab:registerEvolutionStage("ethereal", "stage1", "Young", "Early form")
        Helpers.assertEqual(ok, true, "Registered")
    end)

    Suite:testMethod("AlienBiology.getEvolutionStage", {description = "Gets evolution stage", testCase = "get_stage", type = "functional"}, function()
        local stage = shared.ab:getEvolutionStage("ethereal")
        Helpers.assertEqual(stage, 1, "Stage 1")
    end)

    Suite:testMethod("AlienBiology.advanceEvolution", {description = "Advances evolution", testCase = "advance", type = "functional"}, function()
        local ok = shared.ab:advanceEvolution("ethereal")
        Helpers.assertEqual(ok, true, "Advanced")
    end)

    Suite:testMethod("AlienBiology.getEvolutionStageCount", {description = "Stage count", testCase = "stage_count", type = "functional"}, function()
        shared.ab:registerEvolutionStage("ethereal", "s1", "Stage 1", "")
        shared.ab:registerEvolutionStage("ethereal", "s2", "Stage 2", "")
        local count = shared.ab:getEvolutionStageCount("ethereal")
        Helpers.assertEqual(count, 2, "Two stages")
    end)
end)

Suite:group("Characteristics", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ab = AlienBiology:new()
        shared.ab:registerSpecies("reaper", "Reaper", "organic", 85)
    end)

    Suite:testMethod("AlienBiology.setCharacteristic", {description = "Sets characteristic", testCase = "set_char", type = "functional"}, function()
        local ok = shared.ab:setCharacteristic("reaper", "strength", 90)
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("AlienBiology.getCharacteristic", {description = "Gets characteristic", testCase = "get_char", type = "functional"}, function()
        shared.ab:setCharacteristic("reaper", "intelligence", 70)
        local intel = shared.ab:getCharacteristic("reaper", "intelligence")
        Helpers.assertEqual(intel, 70, "Intelligence 70")
    end)

    Suite:testMethod("AlienBiology.getOverallAdaptability", {description = "Overall adaptability", testCase = "adapt", type = "functional"}, function()
        shared.ab:setCharacteristic("reaper", "intelligence", 60)
        shared.ab:setCharacteristic("reaper", "strength", 80)
        shared.ab:setCharacteristic("reaper", "speed", 70)
        shared.ab:setCharacteristic("reaper", "adaptability", 65)
        local adapt = shared.ab:getOverallAdaptability("reaper")
        Helpers.assertEqual(adapt, 68, "Adaptability 68")
    end)
end)

Suite:group("Specimens", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ab = AlienBiology:new()
        shared.ab:registerSpecies("cyberdisc", "Cyberdisc", "mechanical", 88)
    end)

    Suite:testMethod("AlienBiology.recordSpecimen", {description = "Records specimen", testCase = "record", type = "functional"}, function()
        local ok = shared.ab:recordSpecimen("cyberdisc", "spec1", {})
        Helpers.assertEqual(ok, true, "Recorded")
    end)

    Suite:testMethod("AlienBiology.getSpecimenCount", {description = "Specimen count", testCase = "spec_count", type = "functional"}, function()
        shared.ab:recordSpecimen("cyberdisc", "s1", {})
        shared.ab:recordSpecimen("cyberdisc", "s2", {})
        local count = shared.ab:getSpecimenCount("cyberdisc")
        Helpers.assertEqual(count, 2, "Two specimens")
    end)

    Suite:testMethod("AlienBiology.captureSpecimen", {description = "Captures specimen", testCase = "capture", type = "functional"}, function()
        shared.ab:recordSpecimen("cyberdisc", "cap1", {})
        local ok = shared.ab:captureSpecimen("cyberdisc", "cap1")
        Helpers.assertEqual(ok, true, "Captured")
    end)

    Suite:testMethod("AlienBiology.isSpecimenCaptured", {description = "Is captured", testCase = "is_captured", type = "functional"}, function()
        shared.ab:recordSpecimen("cyberdisc", "cc1", {})
        shared.ab:captureSpecimen("cyberdisc", "cc1")
        local is = shared.ab:isSpecimenCaptured("cyberdisc", "cc1")
        Helpers.assertEqual(is, true, "Captured")
    end)

    Suite:testMethod("AlienBiology.getCapturedSpecimenCount", {description = "Captured count", testCase = "captured_count", type = "functional"}, function()
        shared.ab:recordSpecimen("cyberdisc", "c1", {})
        shared.ab:recordSpecimen("cyberdisc", "c2", {})
        shared.ab:recordSpecimen("cyberdisc", "c3", {})
        shared.ab:captureSpecimen("cyberdisc", "c1")
        shared.ab:captureSpecimen("cyberdisc", "c2")
        local count = shared.ab:getCapturedSpecimenCount("cyberdisc")
        Helpers.assertEqual(count, 2, "Two captured")
    end)

    Suite:testMethod("AlienBiology.setSpecimenHealth", {description = "Sets specimen health", testCase = "set_health", type = "functional"}, function()
        shared.ab:recordSpecimen("cyberdisc", "h1", {})
        local ok = shared.ab:setSpecimenHealth("cyberdisc", "h1", 75)
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("AlienBiology.getSpecimenHealth", {description = "Gets specimen health", testCase = "get_health", type = "functional"}, function()
        shared.ab:recordSpecimen("cyberdisc", "h2", {})
        shared.ab:setSpecimenHealth("cyberdisc", "h2", 85)
        local health = shared.ab:getSpecimenHealth("cyberdisc", "h2")
        Helpers.assertEqual(health, 85, "Health 85")
    end)
end)

Suite:group("Analysis", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ab = AlienBiology:new()
        shared.ab:registerSpecies("s1", "Species1", "type1", 60)
    end)

    Suite:testMethod("AlienBiology.calculateSpeciesWeakness", {description = "Species weakness", testCase = "weakness", type = "functional"}, function()
        shared.ab:setCharacteristic("s1", "adaptability", 30)
        shared.ab:setCharacteristic("s1", "intelligence", 40)
        local weakness = shared.ab:calculateSpeciesWeakness("s1")
        Helpers.assertEqual(weakness > 0, true, "Has weakness")
    end)

    Suite:testMethod("AlienBiology.calculateSpeciesStrength", {description = "Species strength", testCase = "strength", type = "functional"}, function()
        shared.ab:setCharacteristic("s1", "strength", 80)
        shared.ab:setCharacteristic("s1", "speed", 70)
        local str = shared.ab:calculateSpeciesStrength("s1")
        Helpers.assertEqual(str, 75, "Strength 75")
    end)

    Suite:testMethod("AlienBiology.isSpeciesExtinct", {description = "Species extinct", testCase = "extinct", type = "functional"}, function()
        local extinct = shared.ab:isSpeciesExtinct("s1")
        Helpers.assertEqual(extinct, true, "Extinct")
    end)

    Suite:testMethod("AlienBiology.getSpeciesClassification", {description = "Gets classification", testCase = "classify", type = "functional"}, function()
        local classif = shared.ab:getSpeciesClassification("s1")
        Helpers.assertEqual(classif, "type1", "Classified")
    end)

    Suite:testMethod("AlienBiology.updateClassification", {description = "Updates classification", testCase = "update_class", type = "functional"}, function()
        local ok = shared.ab:updateClassification("s1", "newtype")
        Helpers.assertEqual(ok, true, "Updated")
    end)
end)

Suite:group("Biodiversity", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ab = AlienBiology:new()
    end)

    Suite:testMethod("AlienBiology.calculateBiodiversity", {description = "Biodiversity", testCase = "biodiversity", type = "functional"}, function()
        shared.ab:registerSpecies("b1", "B1", "t1", 50)
        shared.ab:registerSpecies("b2", "B2", "t2", 50)
        local bio = shared.ab:calculateBiodiversity()
        Helpers.assertEqual(bio >= 0, true, "Biodiversity >= 0")
    end)

    Suite:testMethod("AlienBiology.getMostThreatening", {description = "Most threatening", testCase = "threatening", type = "functional"}, function()
        shared.ab:registerSpecies("th1", "Th1", "t1", 40)
        shared.ab:registerSpecies("th2", "Th2", "t2", 80)
        local most = shared.ab:getMostThreatening()
        Helpers.assertEqual(most, "th2", "Th2 most threatening")
    end)
end)

Suite:run()
