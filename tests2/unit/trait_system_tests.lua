---@diagnostic disable: unused-local
-- Trait System Test Suite
-- Tests for TRAIT_SYSTEM_SPECIFICATION.md implementation

local TestFramework = require("core.testing.test_framework")
local TraitSystem = require("utils.traits")
local TraitValidator = require("utils.trait_validator")
local AchievementSystem = require("utils.achievement_system")
local UnitCreationSystem = require("core.unit_creation_system")

local TraitSystemTests = TestFramework:suite("Trait System Tests", function(suite)

    -- ============================================================================
    -- SETUP/TEARDOWN
    -- ============================================================================

    suite:setup(function()
        -- Initialize systems
        suite.traitSystem = TraitSystem
        suite.traitSystem:init()

        suite.traitValidator = TraitValidator
        suite.traitValidator:init(suite.traitSystem)

        suite.achievementSystem = AchievementSystem
        suite.achievementSystem:init(suite.traitSystem)

        suite.unitCreationSystem = UnitCreationSystem
        suite.unitCreationSystem:init()
    end)

    suite:teardown(function()
        -- Clean up
        suite.traitSystem = nil
        suite.traitValidator = nil
        suite.achievementSystem = nil
        suite.unitCreationSystem = nil
    end)

    -- ============================================================================
    -- TRAIT DEFINITION TESTS
    -- ============================================================================

    suite:test("Trait definitions load correctly", function()
        local traits = suite.traitSystem:getAllTraits()
        assert(traits ~= nil, "Traits should be loaded")
        assert(type(traits) == "table", "Traits should be a table")

        -- Check we have expected number of traits
        local count = 0
        for _ in pairs(traits) do count = count + 1 end
        assert(count >= 25, "Should have at least 25 traits defined, got " .. count)
    end)

    suite:test("Trait categories are valid", function()
        local validCategories = {combat = true, physical = true, mental = true, support = true}
        local traits = suite.traitSystem:getAllTraits()

        for id, trait in pairs(traits) do
            assert(validCategories[trait.category],
                "Trait " .. id .. " has invalid category: " .. tostring(trait.category))
        end
    end)

    suite:test("Trait balance costs are reasonable", function()
        local traits = suite.traitSystem:getAllTraits()

        for id, trait in pairs(traits) do
            assert(type(trait.balance_cost) == "number",
                "Trait " .. id .. " balance_cost should be a number")
            assert(trait.balance_cost >= -2 and trait.balance_cost <= 4,
                "Trait " .. id .. " balance_cost out of range: " .. trait.balance_cost)
        end
    end)

    -- ============================================================================
    -- BIRTH TRAIT GENERATION TESTS
    -- ============================================================================

    suite:test("Birth trait generation creates valid units", function()
        local unit, error = suite.unitCreationSystem:createUnit({
            class = "soldier",
            name = "Test Soldier"
        })

        assert(unit ~= nil, "Unit should be created successfully")
        assert(error == nil, "Should not have creation error: " .. tostring(error))
        assert(unit.traits ~= nil, "Unit should have traits")
        assert(#unit.traits <= 2, "Recruits should have max 2 birth traits")
    end)

    suite:test("Birth traits have no conflicts", function()
        -- Generate multiple units and check for conflicts
        for i = 1, 50 do
            local unit, error = suite.unitCreationSystem:createUnit({
                class = "soldier",
                name = "Test Soldier " .. i
            })

            assert(unit ~= nil, "Unit " .. i .. " should be created")
            assert(error == nil, "Unit " .. i .. " creation error: " .. tostring(error))

            -- Check for conflicts
            local valid, conflictError = suite.traitValidator:validateUnitTraits(unit)
            assert(valid, "Unit " .. i .. " has trait conflicts: " .. tostring(conflictError))
        end
    end)

    suite:test("Birth trait distribution is correct", function()
        local stats = {positive = 0, negative = 0, none = 0}

        -- Generate 1000 units to check distribution
        for i = 1, 1000 do
            local unit, _ = suite.unitCreationSystem:createUnit({
                class = "soldier",
                name = "Test Soldier " .. i
            })

            local traitCount = #unit.traits
            if traitCount == 0 then
                stats.none = stats.none + 1
            else
                local hasPositive = false
                local hasNegative = false
                for _, trait in ipairs(unit.traits) do
                    local traitDef = suite.traitSystem:getTrait(trait.id)
                    if traitDef.type == "positive" then hasPositive = true
                    elseif traitDef.type == "negative" then hasNegative = true
                    end
                end

                if hasPositive then stats.positive = stats.positive + 1
                elseif hasNegative then stats.negative = stats.negative + 1
                else stats.none = stats.none + 1
                end
            end
        end

        -- Check distribution (roughly 30% positive, 20% negative, 50% none)
        local positivePercent = (stats.positive / 10) -- as percentage
        local negativePercent = (stats.negative / 10)
        local nonePercent = (stats.none / 10)

        assert(positivePercent >= 25 and positivePercent <= 35,
            string.format("Positive traits: %.1f%% (expected ~30%%)", positivePercent))
        assert(negativePercent >= 15 and negativePercent <= 25,
            string.format("Negative traits: %.1f%% (expected ~20%%)", negativePercent))
        assert(nonePercent >= 45 and nonePercent <= 55,
            string.format("No traits: %.1f%% (expected ~50%%)", nonePercent))
    end)

    -- ============================================================================
    -- TRAIT CONFLICT TESTS
    -- ============================================================================

    suite:test("Conflicting traits are blocked", function()
        local unit = {
            id = "test_unit",
            class = "soldier",
            rank = 1,
            traits = {{id = "marathon_runner", acquired_at = "birth", slot = 1}}
        }

        -- Try to add conflicting trait
        local success, error = suite.traitValidator:validateTraitAddition(unit, "disabled")
        assert(not success, "Conflicting trait should be blocked")
        assert(string.find(error, "conflicts"), "Error should mention conflict: " .. tostring(error))
    end)

    suite:test("Non-conflicting traits are allowed", function()
        local unit = {
            id = "test_unit",
            class = "soldier",
            rank = 1,
            traits = {{id = "quick_reflexes", acquired_at = "birth", slot = 1}}
        }

        -- Try to add non-conflicting trait
        local success, error = suite.traitValidator:validateTraitAddition(unit, "sharp_eyes")
        assert(success, "Non-conflicting trait should be allowed: " .. tostring(error))
    end)

    -- ============================================================================
    -- BALANCE SYSTEM TESTS
    -- ============================================================================

    suite:test("Balance limits are enforced", function()
        local unit = {
            id = "test_unit",
            class = "soldier",
            rank = 1,
            traits = {}
        }

        -- Add traits until we hit the limit
        local traitsToAdd = {"quick_reflexes", "sharp_eyes", "steady_hand"}  -- +2 +1 +1 = +4

        for i, traitId in ipairs(traitsToAdd) do
            local success, error = suite.traitValidator:validateTraitAddition(unit, traitId)
            if i < 3 then  -- First two should succeed (+2 +1 = +3, still OK)
                assert(success, "Trait " .. i .. " should be allowed: " .. tostring(error))
                table.insert(unit.traits, {id = traitId, acquired_at = "birth", slot = i})
            else  -- Third should fail (+1 would make +4 > 3)
                assert(not success, "Trait " .. i .. " should be blocked (balance limit)")
                assert(string.find(error, "balance limit"), "Error should mention balance: " .. tostring(error))
            end
        end
    end)

    suite:test("Negative traits offset positive ones", function()
        local unit = {
            id = "test_unit",
            class = "soldier",
            rank = 1,
            traits = {}
        }

        -- Add positive trait (+2)
        local success1, _ = suite.traitValidator:validateTraitAddition(unit, "quick_reflexes")
        assert(success1, "Positive trait should be allowed")
        table.insert(unit.traits, {id = "quick_reflexes", acquired_at = "birth", slot = 1})

        -- Add negative trait (-1) - should be allowed to balance
        local success2, _ = suite.traitValidator:validateTraitAddition(unit, "weak_lungs")
        assert(success2, "Negative trait should be allowed to balance")
        table.insert(unit.traits, {id = "weak_lungs", acquired_at = "birth", slot = 2})

        -- Check final balance
        local totalCost = suite.traitSystem:getTotalBalanceCost(unit)
        assert(totalCost == 1, "Balance should be +2 -1 = +1, got " .. totalCost)
    end)

    -- ============================================================================
    -- TRAIT SLOT TESTS
    -- ============================================================================

    suite:test("Trait slots increase with rank", function()
        local testCases = {
            {rank = 0, expectedSlots = 2},  -- Recruit
            {rank = 1, expectedSlots = 2},  -- Rank 1-3
            {rank = 4, expectedSlots = 3},  -- Rank 4-5
            {rank = 6, expectedSlots = 4},  -- Rank 6-7
            {rank = 8, expectedSlots = 5}   -- Rank 8+
        }

        for _, testCase in ipairs(testCases) do
            local slots = suite.traitSystem:getTraitSlotsForRank(testCase.rank)
            assert(slots == testCase.expectedSlots,
                string.format("Rank %d should have %d slots, got %d",
                    testCase.rank, testCase.expectedSlots, slots))
        end
    end)

    suite:test("Slot limits are enforced", function()
        local unit = {
            id = "test_unit",
            class = "soldier",
            rank = 1,  -- Only 2 slots available
            traits = {
                {id = "quick_reflexes", acquired_at = "birth", slot = 1},
                {id = "sharp_eyes", acquired_at = "birth", slot = 2}
            }
        }

        -- Try to add third trait (achievement)
        local success, error = suite.traitValidator:validateTraitAddition(unit, "marksman")
        assert(not success, "Third trait should be blocked by slot limit")
        assert(string.find(error, "slots"), "Error should mention slots: " .. tostring(error))
    end)

    -- ============================================================================
    -- ACHIEVEMENT SYSTEM TESTS
    -- ============================================================================

    suite:test("Achievement progress tracking works", function()
        local unitId = "test_unit_achievements"
        suite.achievementSystem:initUnitAchievements(unitId)

        -- Update rifle kills
        suite.achievementSystem:updateProgress(unitId, "rifle_kills", 15, 0)

        -- Check progress
        local progress = suite.achievementSystem:getUnitProgress(unitId, "rifle_kills_20")
        assert(progress.rifle_kills == 15, "Progress should be tracked")

        -- Check completion percentage
        local percentage = suite.achievementSystem:getCompletionPercentage(unitId, "rifle_kills_20")
        assert(percentage == 75, "Should be 75% complete (15/20), got " .. percentage)
    end)

    suite:test("Achievements unlock traits", function()
        local unitId = "test_unit_achievements"
        suite.achievementSystem:initUnitAchievements(unitId)

        -- Complete rifle kills achievement
        suite.achievementSystem:updateProgress(unitId, "rifle_kills", 20, 15)

        -- Check if achievement unlocked
        local hasAchievement = suite.achievementSystem:hasAchievement(unitId, "rifle_kills_20")
        assert(hasAchievement, "Achievement should be unlocked")

        -- Check if trait was granted (this would integrate with unit system)
        local unlockedAchievements = suite.achievementSystem:getUnitAchievements(unitId)
        assert(#unlockedAchievements > 0, "Should have unlocked achievements")
        assert(unlockedAchievements[1].reward_trait == "marksman", "Should reward marksman trait")
    end)

    suite:test("Hidden achievements don't show until unlocked", function()
        local unitId = "test_unit_hidden"
        suite.achievementSystem:initUnitAchievements(unitId)

        -- Check available achievements (should not include hidden ones)
        local available = suite.achievementSystem:getAvailableAchievements(unitId)

        -- War Hero is hidden, so shouldn't appear
        local hasWarHero = false
        for _, achievement in ipairs(available) do
            if achievement.id == "total_kills_1000" then
                hasWarHero = true
                break
            end
        end

        assert(not hasWarHero, "Hidden achievements should not appear in available list")
    end)

    -- ============================================================================
    -- TRAIT EFFECT APPLICATION TESTS
    -- ============================================================================

    suite:test("Trait effects are applied correctly", function()
        local unit, _ = suite.unitCreationSystem:createUnit({
            class = "soldier",
            name = "Test Soldier"
        })

        -- Check that trait effects were applied
        assert(unit.trait_bonuses ~= nil, "Unit should have trait bonuses")

        -- Check that base stats plus bonuses equal final stats
        local baseClass = suite.unitCreationSystem:getUnitClass(unit.class)
        for stat, baseValue in pairs(baseClass.baseStats) do
            local bonus = unit.trait_bonuses[stat] or 0
            local expectedFinal = baseValue + bonus

            -- Apply stacking caps
            if bonus > 3 then expectedFinal = baseValue + 3 end

            assert(unit.stats[stat] == expectedFinal,
                string.format("Stat %s: expected %d, got %d (base: %d, bonus: %d)",
                    stat, expectedFinal, unit.stats[stat], baseValue, bonus))
        end
    end)

    suite:test("Synergy bonuses are calculated", function()
        local unit = {
            id = "test_synergy",
            class = "soldier",
            rank = 5,
            traits = {
                {id = "marksman", acquired_at = "achievement", slot = 1},
                {id = "steady_hand", acquired_at = "birth", slot = 2}
            },
            trait_bonuses = {}
        }

        -- Apply trait effects
        for _, trait in ipairs(unit.traits) do
            suite.traitSystem:applyTraitEffects(unit, trait.id)
        end

        -- Apply synergies
        suite.traitSystem:applySynergyBonuses(unit)

        -- Check for marksman + steady hand synergy (+3% accuracy)
        assert(unit.trait_bonuses.accuracy_percent == 3,
            "Should have +3% accuracy synergy bonus, got " .. tostring(unit.trait_bonuses.accuracy_percent))
    end)

    -- ============================================================================
    -- TRAIT MODIFICATION TESTS
    -- ============================================================================

    suite:test("Trait removal requires proper conditions", function()
        local unit = {
            id = "test_removal",
            class = "soldier",
            rank = 4,  -- Below requirement
            traits = {{id = "marksman", acquired_at = "achievement", slot = 1}}
        }

        -- Try to remove trait (should fail - wrong rank)
        local success, error = suite.traitValidator:validateTraitRemoval(unit, "marksman")
        assert(not success, "Trait removal should fail for low rank")
        assert(string.find(error, "rank"), "Error should mention rank: " .. tostring(error))

        -- Set proper rank
        unit.rank = 5
        unit.xp = 100000  -- Sufficient XP

        -- Should now succeed
        success, error = suite.traitValidator:validateTraitRemoval(unit, "marksman")
        assert(success, "Trait removal should succeed with proper conditions: " .. tostring(error))
    end)

    suite:test("Birth traits cannot be removed", function()
        local unit = {
            id = "test_birth_removal",
            class = "soldier",
            rank = 8,
            xp = 1000000,
            traits = {{id = "quick_reflexes", acquired_at = "birth", slot = 1}}
        }

        -- Try to remove birth trait
        local success, error = suite.traitValidator:validateTraitRemoval(unit, "quick_reflexes")
        assert(not success, "Birth traits should not be removable")
        assert(string.find(error, "Birth traits"), "Error should mention birth traits: " .. tostring(error))
    end)

    -- ============================================================================
    -- UNIT CLASS TESTS
    -- ============================================================================

    suite:test("All unit classes have valid base stats", function()
        local classes = suite.unitCreationSystem:getAllUnitClasses()

        for classId, classDef in pairs(classes) do
            assert(classDef.baseStats ~= nil, "Class " .. classId .. " should have base stats")
            assert(type(classDef.baseStats.health) == "number", "Health should be a number")
            assert(classDef.baseStats.health > 0, "Health should be positive")

            -- Check all expected stats exist
            local requiredStats = {"aim", "melee", "reaction", "speed", "bravery", "sanity", "strength", "health"}
            for _, stat in ipairs(requiredStats) do
                assert(classDef.baseStats[stat] ~= nil,
                    "Class " .. classId .. " missing stat: " .. stat)
                assert(type(classDef.baseStats[stat]) == "number",
                    "Stat " .. stat .. " should be a number for class " .. classId)
            end
        end
    end)

    suite:test("Unit creation validates class", function()
        local unit, error = suite.unitCreationSystem:createUnit({
            class = "invalid_class",
            name = "Test Unit"
        })

        assert(unit == nil, "Invalid class should fail creation")
        assert(error ~= nil, "Should have error for invalid class")
        assert(string.find(error, "class"), "Error should mention class: " .. tostring(error))
    end)

    -- ============================================================================
    -- INTEGRATION TESTS
    -- ============================================================================

    suite:test("Complete unit creation workflow", function()
        -- Create unit
        local unit, error = suite.unitCreationSystem:createUnit({
            class = "sniper",
            name = "Sarah Johnson"
        })

        assert(unit ~= nil, "Unit should be created")
        assert(error == nil, "No creation error")

        -- Validate unit
        local valid, validateError = suite.unitCreationSystem:validateUnit(unit)
        assert(valid, "Unit should be valid: " .. tostring(validateError))

        -- Check unit has required fields
        assert(unit.id ~= nil, "Unit should have ID")
        assert(unit.name == "Sarah Johnson", "Unit should have correct name")
        assert(unit.class == "sniper", "Unit should have correct class")
        assert(unit.stats ~= nil, "Unit should have stats")
        assert(unit.traits ~= nil, "Unit should have traits")

        -- Check stats are reasonable
        assert(unit.stats.aim >= 80, "Sniper should have high aim stat")
        assert(unit.health > 0, "Unit should have health")
    end)

    suite:test("Trait system integration with achievement system", function()
        -- Create unit
        local unit, _ = suite.unitCreationSystem:createUnit({
            class = "soldier",
            name = "Achievement Test Unit"
        })

        -- Simulate achievement progress
        suite.achievementSystem:updateProgress(unit.id, "rifle_kills", 20, 0)

        -- Check achievement was unlocked
        local hasAchievement = suite.achievementSystem:hasAchievement(unit.id, "rifle_kills_20")
        assert(hasAchievement, "Achievement should be unlocked")

        -- Try to add the trait to the unit
        local success, error = suite.unitCreationSystem:addTraitToUnit(unit, "marksman")
        assert(success, "Trait should be added successfully: " .. tostring(error))

        -- Verify trait was added
        local hasTrait = suite.traitSystem:hasTrait(unit, "marksman")
        assert(hasTrait, "Unit should have the marksman trait")

        -- Check effects were applied
        assert(unit.trait_bonuses.aim == 1, "Should have +1 aim bonus")
        assert(unit.trait_bonuses.weapon_accuracy == 1, "Should have +1 weapon accuracy bonus")
    end)

    -- ============================================================================
    -- PERFORMANCE TESTS
    -- ============================================================================

    suite:test("Trait generation performance", function()
        local startTime = os.clock()

        -- Generate 100 units
        for i = 1, 100 do
            local unit, _ = suite.unitCreationSystem:createUnit({
                class = "soldier",
                name = "Perf Test " .. i
            })
            assert(unit ~= nil, "Unit " .. i .. " should be created")
        end

        local endTime = os.clock()
        local totalTime = endTime - startTime

        assert(totalTime < 1.0, string.format("Trait generation too slow: %.3f seconds for 100 units", totalTime))
    end)

    suite:test("Trait validation performance", function()
        -- Create a unit with many traits
        local unit = {
            id = "perf_test_unit",
            class = "soldier",
            rank = 8,
            traits = {
                {id = "quick_reflexes", acquired_at = "birth", slot = 1},
                {id = "sharp_eyes", acquired_at = "birth", slot = 2},
                {id = "marksman", acquired_at = "achievement", slot = 3},
                {id = "steady_hand", acquired_at = "achievement", slot = 4},
                {id = "superhuman_strength", acquired_at = "perk", slot = 5}
            }
        }

        local startTime = os.clock()

        -- Validate 1000 times
        for i = 1, 1000 do
            local valid, _ = suite.traitValidator:validateUnitTraits(unit)
            assert(valid, "Unit should be valid")
        end

        local endTime = os.clock()
        local totalTime = endTime - startTime

        assert(totalTime < 0.5, string.format("Trait validation too slow: %.3f seconds for 1000 validations", totalTime))
    end)

end)

return TraitSystemTests
