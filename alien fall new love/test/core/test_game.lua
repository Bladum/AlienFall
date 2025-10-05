--- Test suite for Game module
--
-- Tests the core Game module functionality including initialization,
-- mod management, and singleton behavior.
--
-- @module test.core.test_game

local test_framework = require "test.framework.test_framework"
local Game = require "Game"

local test_game = {}

--- Run all Game module tests
function test_game.run()
    test_framework.run_suite("Game Module", {
        test_initialization = test_game.test_initialization,
        test_singleton_pattern = test_game.test_singleton_pattern,
        test_difficulty_management = test_game.test_difficulty_management,
        test_mod_scanning = test_game.test_mod_scanning,
        test_mod_loading = test_game.test_mod_loading,
        test_mod_unloading = test_game.test_mod_unloading
    })
end

--- Test Game initialization
function test_game.test_initialization()
    local game = Game.new()

    test_framework.assert_not_nil(game)
    test_framework.assert_equal(game.difficulty, "normal")
    test_framework.assert_equal(type(game.loadedMods), "table")
    test_framework.assert_equal(type(game.availableMods), "table")
    test_framework.assert_equal(type(game.units), "table")
    test_framework.assert_equal(type(game.items), "table")
    test_framework.assert_equal(type(game.missions), "table")
    test_framework.assert_nil(game.world)
    test_framework.assert_nil(game.player)
end

--- Test singleton pattern
function test_game.test_singleton_pattern()
    -- Reset singleton for testing
    local oldInstance = package.loaded["Game"]
    package.loaded["Game"] = nil

    local game1 = Game.getInstance()
    local game2 = Game.getInstance()

    test_framework.assert_not_nil(game1)
    test_framework.assert_not_nil(game2)
    test_framework.assert_equal(game1, game2)

    -- Restore original instance
    package.loaded["Game"] = oldInstance
end

--- Test difficulty management
function test_game.test_difficulty_management()
    local game = Game.new()

    -- Test valid difficulties
    test_framework.assert_equal(game:setDifficulty("easy"), true)
    test_framework.assert_equal(game:getDifficulty(), "easy")

    test_framework.assert_equal(game:setDifficulty("normal"), true)
    test_framework.assert_equal(game:getDifficulty(), "normal")

    test_framework.assert_equal(game:setDifficulty("hard"), true)
    test_framework.assert_equal(game:getDifficulty(), "hard")

    -- Test invalid difficulty
    test_framework.assert_equal(game:setDifficulty("invalid"), false)
    test_framework.assert_equal(game:getDifficulty(), "hard") -- Should remain unchanged
end

--- Test mod scanning functionality
function test_game.test_mod_scanning()
    local game = Game.new()

    -- Test that scanMods doesn't crash
    game:scanMods()

    -- Test that availableMods is a table
    test_framework.assert_equal(type(game:getAvailableMods()), "table")

    -- Test that loadedMods is initially empty
    test_framework.assert_equal(#game:getLoadedMods(), 0)
end

--- Test mod loading functionality
function test_game.test_mod_loading()
    local game = Game.new()

    -- Test loading non-existent mod
    test_framework.assert_equal(game:loadMod("nonexistent"), false)

    -- Test loading with available mods (if any exist)
    local availableMods = game:getAvailableMods()
    if #availableMods > 0 then
        local firstMod = availableMods[1]
        local result = game:loadMod(firstMod.id)
        test_framework.assert_equal(type(result), "boolean")

        if result then
            -- If loading succeeded, check it's in loaded mods
            local loadedMods = game:getLoadedMods()
            local found = false
            for _, mod in ipairs(loadedMods) do
                if mod.id == firstMod.id then
                    found = true
                    break
                end
            end
            test_framework.assert_equal(found, true)
        end
    end
end

--- Test mod unloading functionality
function test_game.test_mod_unloading()
    local game = Game.new()

    -- Test unloading non-existent mod
    test_framework.assert_equal(game:unloadMod("nonexistent"), false)

    -- Test unloading all mods
    game:unloadAllMods()
    test_framework.assert_equal(#game:getLoadedMods(), 0)
end

return test_game