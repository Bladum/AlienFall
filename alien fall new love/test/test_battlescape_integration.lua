--- Test Battlescape System Integration
-- Basic integration test for all battlescape systems

local lust = require 'test.framework.lust'
local describe, it, expect = lust.describe, lust.it, lust.expect

local ActionSystem = require 'battlescape.ActionSystem'
local MoraleSystem = require 'battlescape.MoraleSystem'
local EnvironmentSystem = require 'battlescape.EnvironmentSystem'
local CombatSystem = require 'battlescape.CombatSystem'
local BattleTile = require 'battlescape.BattleTile'
local BattleMap = require 'battlescape.BattleMap'
local MapTileset = require 'battlescape.MapTileset'
local UnitAction = require 'battlescape.UnitAction'
local MissionObjectives = require 'battlescape.MissionObjectives'
local BattlescapeAI = require 'battlescape.BattlescapeAI'

describe('Battlescape System Integration', function()

    describe('Core Systems', function()
        it('should load all core system classes', function()
            expect(ActionSystem).to.be.a('table')
            expect(MoraleSystem).to.be.a('table')
            expect(EnvironmentSystem).to.be.a('table')
            expect(CombatSystem).to.be.a('table')
        end)

        it('should instantiate core systems', function()
            local actionSystem = ActionSystem()
            local moraleSystem = MoraleSystem()
            local environmentSystem = EnvironmentSystem()
            local combatSystem = CombatSystem()

            expect(actionSystem).to.be.a('table')
            expect(moraleSystem).to.be.a('table')
            expect(environmentSystem).to.be.a('table')
            expect(combatSystem).to.be.a('table')
        end)
    end)

    describe('Map Components', function()
        it('should load map component classes', function()
            expect(BattleTile).to.be.a('table')
            expect(BattleMap).to.be.a('table')
            expect(MapTileset).to.be.a('table')
        end)

        it('should create battle tiles', function()
            local tile = BattleTile(1, 1, { material = "concrete", cover = 50 })
            expect(tile).to.be.a('table')
            expect(tile:getMaterial()).to.equal("concrete")
            expect(tile:getCover()).to.equal(50)
        end)

        it('should create battle map', function()
            local map = BattleMap(10, 10)
            expect(map).to.be.a('table')
            expect(map:getWidth()).to.equal(10)
            expect(map:getHeight()).to.equal(10)
        end)
    end)

    describe('Unit Actions', function()
        it('should load unit action class', function()
            expect(UnitAction).to.be.a('table')
        end)

        it('should create unit actions', function()
            local moveAction = UnitAction({
                type = "move",
                name = "Move",
                ap_cost = 1,
                range = 1
            })
            expect(moveAction).to.be.a('table')
            expect(moveAction:getType()).to.equal("move")
            expect(moveAction:getAPCost()).to.equal(1)
        end)
    end)

    describe('Mission Objectives', function()
        it('should load mission objectives class', function()
            expect(MissionObjectives).to.be.a('table')
        end)

        it('should create mission objectives', function()
            local missionData = {
                objectives = {
                    { id = 1, type = "primary", title = "Test Objective" }
                }
            }
            local objectives = MissionObjectives(missionData)
            expect(objectives).to.be.a('table')
            expect(objectives:getMissionState()).to.equal("active")
        end)
    end)

    describe('AI System', function()
        it('should load AI class', function()
            expect(BattlescapeAI).to.be.a('table')
        end)

        it('should create AI instance', function()
            -- Mock battle state
            local mockBattleState = {
                getAllUnits = function() return {} end,
                getMap = function() return { hasClearLine = function() return true end } end
            }

            local ai = BattlescapeAI(mockBattleState, 12345)
            expect(ai).to.be.a('table')
            expect(ai.personalityWeights).to.be.a('table')
        end)
    end)

    describe('System Integration', function()
        it('should integrate action and morale systems', function()
            local actionSystem = ActionSystem()
            local moraleSystem = MoraleSystem()

            -- Mock unit
            local mockUnit = {
                getMorale = function() return 70 end,
                setMorale = function() end,
                getPosition = function() return {x = 1, y = 1} end
            }

            -- Test morale damage application
            moraleSystem:applyMoraleDamage(mockUnit, 10, "casualty")
            expect(true).to.equal(true) -- Just verify no errors
        end)

        it('should integrate map and environment systems', function()
            local map = BattleMap(5, 5)
            local environmentSystem = EnvironmentSystem()

            -- Create a tile and apply environmental effect
            local tile = map:getTile(1, 1)
            if tile then
                environmentSystem:applyEffect(tile, "fire", 3)
                expect(true).to.equal(true) -- Just verify no errors
            end
        end)
    end)

end)

--- Run function for test runner compatibility
local function run()
    -- Tests are executed when module is loaded via lust.describe
    -- This function exists for test runner compatibility
end

return {
    run = run
}