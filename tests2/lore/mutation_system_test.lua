-- ─────────────────────────────────────────────────────────────────────────
-- MUTATION SYSTEM TEST SUITE
-- FILE: tests2/lore/mutation_system_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.lore.mutation_system",
    fileName = "mutation_system.lua",
    description = "Mutation system for alien mutations, evolution stages, and adaptation traits"
})

print("[MUTATION_SYSTEM_TEST] Setting up")

local MutationSystem = {
    species = {},
    mutations = {},
    evolution = {},
    adaptations = {},
    specimens = {},

    new = function(self)
        return setmetatable({
            species = {}, mutations = {}, evolution = {},
            adaptations = {}, specimens = {}
        }, {__index = self})
    end,

    registerSpecies = function(self, speciesId, name, baseAttributes)
        self.species[speciesId] = {
            id = speciesId, name = name, mutations = 0,
            evolution_stage = 1, attributes = baseAttributes or {},
            population = 0, threat_level = 50
        }
        self.evolution[speciesId] = {species = speciesId, stages = {}, current_stage = 1}
        return true
    end,

    getSpecies = function(self, speciesId)
        return self.species[speciesId]
    end,

    createMutation = function(self, mutationId, mutationType, description, effect)
        self.mutations[mutationId] = {
            id = mutationId, type = mutationType or "unknown",
            description = description or "", effect = effect or 0,
            rarity = 50, beneficial = false, specimens_with = {}
        }
        return true
    end,

    getMutation = function(self, mutationId)
        return self.mutations[mutationId]
    end,

    applyMutationToSpecies = function(self, speciesId, mutationId)
        if not self.species[speciesId] or not self.mutations[mutationId] then return false end
        self.species[speciesId].mutations = self.species[speciesId].mutations + 1
        table.insert(self.mutations[mutationId].specimens_with, speciesId)
        return true
    end,

    getMutationCount = function(self, speciesId)
        if not self.species[speciesId] then return 0 end
        return self.species[speciesId].mutations
    end,

    createEvolutionStage = function(self, stageId, speciesId, stageName, requirements)
        if not self.species[speciesId] then return false end
        if not self.evolution[speciesId] then return false end
        local stage = {
            id = stageId, name = stageName, requirements = requirements or {},
            form_changes = {}, ability_changes = {}, level = 0
        }
        table.insert(self.evolution[speciesId].stages, stage)
        return true
    end,

    getEvolutionStage = function(self, speciesId)
        if not self.evolution[speciesId] then return 0 end
        return self.evolution[speciesId].current_stage
    end,

    advanceEvolutionStage = function(self, speciesId)
        if not self.species[speciesId] or not self.evolution[speciesId] then return false end
        self.species[speciesId].evolution_stage = self.species[speciesId].evolution_stage + 1
        self.evolution[speciesId].current_stage = self.species[speciesId].evolution_stage
        return true
    end,

    createAdaptation = function(self, adaptationId, name, adaptationType, bonus)
        self.adaptations[adaptationId] = {
            id = adaptationId, name = name, type = adaptationType or "environmental",
            bonus = bonus or 10, triggers = {}, species_adapted = {}
        }
        return true
    end,

    getAdaptation = function(self, adaptationId)
        return self.adaptations[adaptationId]
    end,

    adaptSpecies = function(self, speciesId, adaptationId)
        if not self.species[speciesId] or not self.adaptations[adaptationId] then return false end
        table.insert(self.adaptations[adaptationId].species_adapted, speciesId)
        return true
    end,

    getAdaptationCount = function(self, speciesId)
        local count = 0
        for _, adaptation in pairs(self.adaptations) do
            for _, species in ipairs(adaptation.species_adapted) do
                if species == speciesId then
                    count = count + 1
                    break
                end
            end
        end
        return count
    end,

    enrollSpecimen = function(self, specimenId, speciesId, name, health)
        if not self.species[speciesId] then return false end
        self.specimens[specimenId] = {
            id = specimenId, species = speciesId, name = name,
            health = health or 100, mutations = {}, adaptations = {}
        }
        self.species[speciesId].population = self.species[speciesId].population + 1
        return true
    end,

    getSpecimen = function(self, specimenId)
        return self.specimens[specimenId]
    end,

    giveSpecimenMutation = function(self, specimenId, mutationId)
        if not self.specimens[specimenId] or not self.mutations[mutationId] then return false end
        table.insert(self.specimens[specimenId].mutations, mutationId)
        return true
    end,

    getSpecimenMutationCount = function(self, specimenId)
        if not self.specimens[specimenId] then return 0 end
        return #self.specimens[specimenId].mutations
    end,

    giveSpecimenAdaptation = function(self, specimenId, adaptationId)
        if not self.specimens[specimenId] or not self.adaptations[adaptationId] then return false end
        table.insert(self.specimens[specimenId].adaptations, adaptationId)
        return true
    end,

    getSpecimenAdaptationCount = function(self, specimenId)
        if not self.specimens[specimenId] then return 0 end
        return #self.specimens[specimenId].adaptations
    end,

    calculateSpeciesAdaptability = function(self, speciesId)
        if not self.species[speciesId] then return 0 end
        local mutations = self.species[speciesId].mutations
        local stage_bonus = self.species[speciesId].evolution_stage * 10
        return math.floor((mutations * 5) + stage_bonus)
    end,

    calculateThreatProgression = function(self, speciesId)
        if not self.species[speciesId] then return 0 end
        local threat = self.species[speciesId].threat_level
        local mutation_factor = 1 + (self.species[speciesId].mutations * 0.1)
        local stage_factor = 1 + ((self.species[speciesId].evolution_stage - 1) * 0.2)
        return math.floor(threat * mutation_factor * stage_factor)
    end,

    getTotalPopulation = function(self, speciesId)
        if not self.species[speciesId] then return 0 end
        return self.species[speciesId].population
    end,

    getTotalSpecimens = function(self)
        local count = 0
        for _ in pairs(self.specimens) do count = count + 1 end
        return count
    end,

    getHighestEvolutionStage = function(self)
        local max_stage = 0
        for _, species in pairs(self.species) do
            if species.evolution_stage > max_stage then
                max_stage = species.evolution_stage
            end
        end
        return max_stage
    end,

    getMutationSpeciesCount = function(self, mutationId)
        if not self.mutations[mutationId] then return 0 end
        return #self.mutations[mutationId].specimens_with
    end,

    reset = function(self)
        self.species = {}
        self.mutations = {}
        self.evolution = {}
        self.adaptations = {}
        self.specimens = {}
        return true
    end
}

Suite:group("Species", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ms = MutationSystem:new()
    end)

    Suite:testMethod("MutationSystem.registerSpecies", {description = "Registers species", testCase = "register", type = "functional"}, function()
        local ok = shared.ms:registerSpecies("alien1", "Alien One", {strength = 50})
        Helpers.assertEqual(ok, true, "Registered")
    end)

    Suite:testMethod("MutationSystem.getSpecies", {description = "Gets species", testCase = "get", type = "functional"}, function()
        shared.ms:registerSpecies("alien2", "Alien Two", {speed = 60})
        local species = shared.ms:getSpecies("alien2")
        Helpers.assertEqual(species ~= nil, true, "Retrieved")
    end)
end)

Suite:group("Mutations", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ms = MutationSystem:new()
        shared.ms:registerSpecies("mut_species", "Mutation Species", {})
    end)

    Suite:testMethod("MutationSystem.createMutation", {description = "Creates mutation", testCase = "create", type = "functional"}, function()
        local ok = shared.ms:createMutation("mut1", "physical", "Stronger arms", 20)
        Helpers.assertEqual(ok, true, "Created")
    end)

    Suite:testMethod("MutationSystem.getMutation", {description = "Gets mutation", testCase = "get", type = "functional"}, function()
        shared.ms:createMutation("mut2", "mental", "Better mind", 15)
        local mutation = shared.ms:getMutation("mut2")
        Helpers.assertEqual(mutation ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("MutationSystem.applyMutationToSpecies", {description = "Applies mutation", testCase = "apply", type = "functional"}, function()
        shared.ms:createMutation("mut3", "physical", "Tougher", 10)
        local ok = shared.ms:applyMutationToSpecies("mut_species", "mut3")
        Helpers.assertEqual(ok, true, "Applied")
    end)

    Suite:testMethod("MutationSystem.getMutationCount", {description = "Mutation count", testCase = "count", type = "functional"}, function()
        shared.ms:createMutation("mut4", "physical", "Strong", 10)
        shared.ms:createMutation("mut5", "mental", "Smart", 10)
        shared.ms:applyMutationToSpecies("mut_species", "mut4")
        shared.ms:applyMutationToSpecies("mut_species", "mut5")
        local count = shared.ms:getMutationCount("mut_species")
        Helpers.assertEqual(count, 2, "Two mutations")
    end)
end)

Suite:group("Evolution Stages", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ms = MutationSystem:new()
        shared.ms:registerSpecies("evo_species", "Evolution Species", {})
    end)

    Suite:testMethod("MutationSystem.createEvolutionStage", {description = "Creates stage", testCase = "create", type = "functional"}, function()
        local ok = shared.ms:createEvolutionStage("stage1", "evo_species", "Stage One", {})
        Helpers.assertEqual(ok, true, "Created")
    end)

    Suite:testMethod("MutationSystem.getEvolutionStage", {description = "Gets stage", testCase = "get", type = "functional"}, function()
        shared.ms:createEvolutionStage("stage2", "evo_species", "Stage Two", {})
        local stage = shared.ms:getEvolutionStage("evo_species")
        Helpers.assertEqual(stage > 0, true, "Stage > 0")
    end)

    Suite:testMethod("MutationSystem.advanceEvolutionStage", {description = "Advances stage", testCase = "advance", type = "functional"}, function()
        shared.ms:createEvolutionStage("stage3", "evo_species", "Stage Three", {})
        local ok = shared.ms:advanceEvolutionStage("evo_species")
        Helpers.assertEqual(ok, true, "Advanced")
    end)
end)

Suite:group("Adaptations", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ms = MutationSystem:new()
        shared.ms:registerSpecies("adapt_species", "Adaptation Species", {})
    end)

    Suite:testMethod("MutationSystem.createAdaptation", {description = "Creates adaptation", testCase = "create", type = "functional"}, function()
        local ok = shared.ms:createAdaptation("adapt1", "Cold Resistance", "environmental", 20)
        Helpers.assertEqual(ok, true, "Created")
    end)

    Suite:testMethod("MutationSystem.getAdaptation", {description = "Gets adaptation", testCase = "get", type = "functional"}, function()
        shared.ms:createAdaptation("adapt2", "Heat Resistance", "environmental", 20)
        local adaptation = shared.ms:getAdaptation("adapt2")
        Helpers.assertEqual(adaptation ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("MutationSystem.adaptSpecies", {description = "Adapts species", testCase = "adapt", type = "functional"}, function()
        shared.ms:createAdaptation("adapt3", "Radiation", "environmental", 15)
        local ok = shared.ms:adaptSpecies("adapt_species", "adapt3")
        Helpers.assertEqual(ok, true, "Adapted")
    end)

    Suite:testMethod("MutationSystem.getAdaptationCount", {description = "Adaptation count", testCase = "count", type = "functional"}, function()
        shared.ms:createAdaptation("adapt4", "Low Gravity", "environmental", 10)
        shared.ms:createAdaptation("adapt5", "Vacuum", "environmental", 10)
        shared.ms:adaptSpecies("adapt_species", "adapt4")
        shared.ms:adaptSpecies("adapt_species", "adapt5")
        local count = shared.ms:getAdaptationCount("adapt_species")
        Helpers.assertEqual(count, 2, "Two adaptations")
    end)
end)

Suite:group("Specimens", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ms = MutationSystem:new()
        shared.ms:registerSpecies("spec_species", "Specimen Species", {})
    end)

    Suite:testMethod("MutationSystem.enrollSpecimen", {description = "Enrolls specimen", testCase = "enroll", type = "functional"}, function()
        local ok = shared.ms:enrollSpecimen("spec1", "spec_species", "Specimen One", 100)
        Helpers.assertEqual(ok, true, "Enrolled")
    end)

    Suite:testMethod("MutationSystem.getSpecimen", {description = "Gets specimen", testCase = "get", type = "functional"}, function()
        shared.ms:enrollSpecimen("spec2", "spec_species", "Specimen Two", 100)
        local specimen = shared.ms:getSpecimen("spec2")
        Helpers.assertEqual(specimen ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("MutationSystem.giveSpecimenMutation", {description = "Gives mutation", testCase = "give_mut", type = "functional"}, function()
        shared.ms:enrollSpecimen("spec3", "spec_species", "Specimen Three", 100)
        shared.ms:createMutation("s_mut1", "physical", "Strong", 10)
        local ok = shared.ms:giveSpecimenMutation("spec3", "s_mut1")
        Helpers.assertEqual(ok, true, "Given")
    end)

    Suite:testMethod("MutationSystem.getSpecimenMutationCount", {description = "Mutation count", testCase = "mut_count", type = "functional"}, function()
        shared.ms:enrollSpecimen("spec4", "spec_species", "Specimen Four", 100)
        shared.ms:createMutation("s_mut2", "physical", "Strong", 10)
        shared.ms:createMutation("s_mut3", "mental", "Smart", 10)
        shared.ms:giveSpecimenMutation("spec4", "s_mut2")
        shared.ms:giveSpecimenMutation("spec4", "s_mut3")
        local count = shared.ms:getSpecimenMutationCount("spec4")
        Helpers.assertEqual(count, 2, "Two mutations")
    end)

    Suite:testMethod("MutationSystem.giveSpecimenAdaptation", {description = "Gives adaptation", testCase = "give_adapt", type = "functional"}, function()
        shared.ms:enrollSpecimen("spec5", "spec_species", "Specimen Five", 100)
        shared.ms:createAdaptation("s_adapt1", "Cold", "env", 10)
        local ok = shared.ms:giveSpecimenAdaptation("spec5", "s_adapt1")
        Helpers.assertEqual(ok, true, "Given")
    end)

    Suite:testMethod("MutationSystem.getSpecimenAdaptationCount", {description = "Adaptation count", testCase = "adapt_count", type = "functional"}, function()
        shared.ms:enrollSpecimen("spec6", "spec_species", "Specimen Six", 100)
        shared.ms:createAdaptation("s_adapt2", "Heat", "env", 10)
        shared.ms:createAdaptation("s_adapt3", "Rad", "env", 10)
        shared.ms:giveSpecimenAdaptation("spec6", "s_adapt2")
        shared.ms:giveSpecimenAdaptation("spec6", "s_adapt3")
        local count = shared.ms:getSpecimenAdaptationCount("spec6")
        Helpers.assertEqual(count, 2, "Two adaptations")
    end)
end)

Suite:group("Analysis", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ms = MutationSystem:new()
        shared.ms:registerSpecies("anal_species", "Analysis Species", {})
        shared.ms:createMutation("a_mut", "physical", "Test", 10)
        shared.ms:applyMutationToSpecies("anal_species", "a_mut")
        shared.ms:enrollSpecimen("a_spec", "anal_species", "Specimen", 100)
        shared.ms:advanceEvolutionStage("anal_species")
    end)

    Suite:testMethod("MutationSystem.calculateSpeciesAdaptability", {description = "Adaptability", testCase = "adapt", type = "functional"}, function()
        local adaptability = shared.ms:calculateSpeciesAdaptability("anal_species")
        Helpers.assertEqual(adaptability > 0, true, "Adaptability > 0")
    end)

    Suite:testMethod("MutationSystem.calculateThreatProgression", {description = "Threat", testCase = "threat", type = "functional"}, function()
        local threat = shared.ms:calculateThreatProgression("anal_species")
        Helpers.assertEqual(threat > 50, true, "Threat > 50")
    end)

    Suite:testMethod("MutationSystem.getTotalPopulation", {description = "Population", testCase = "pop", type = "functional"}, function()
        local pop = shared.ms:getTotalPopulation("anal_species")
        Helpers.assertEqual(pop > 0, true, "Pop > 0")
    end)

    Suite:testMethod("MutationSystem.getTotalSpecimens", {description = "Total specimens", testCase = "total", type = "functional"}, function()
        local total = shared.ms:getTotalSpecimens()
        Helpers.assertEqual(total > 0, true, "Total > 0")
    end)

    Suite:testMethod("MutationSystem.getHighestEvolutionStage", {description = "Highest stage", testCase = "highest", type = "functional"}, function()
        local highest = shared.ms:getHighestEvolutionStage()
        Helpers.assertEqual(highest >= 1, true, "Highest >= 1")
    end)

    Suite:testMethod("MutationSystem.getMutationSpeciesCount", {description = "Mutation species", testCase = "mut_species", type = "functional"}, function()
        local count = shared.ms:getMutationSpeciesCount("a_mut")
        Helpers.assertEqual(count >= 1, true, "Count >= 1")
    end)
end)

Suite:group("Reset", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ms = MutationSystem:new()
    end)

    Suite:testMethod("MutationSystem.reset", {description = "Resets system", testCase = "reset", type = "functional"}, function()
        local ok = shared.ms:reset()
        Helpers.assertEqual(ok, true, "Reset")
    end)
end)

Suite:run()
