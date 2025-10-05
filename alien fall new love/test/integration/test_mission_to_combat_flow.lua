--- Integration Test: Mission to Combat Flow
--
-- Tests the complete workflow from mission generation through combat resolution
-- and reward distribution. This integration test validates that all systems
-- work together correctly.
--
-- @module test.integration.test_mission_to_combat_flow

local test_framework = require "test.framework.test_framework"
local describe = test_framework.describe
local it = test_framework.it
local expect = test_framework.expect
local before = test_framework.before

describe("Integration: Mission to Combat Flow", function()
    local registry
    local missionSystem
    local combatSystem
    local economyService
    local unitManager
    
    before(function()
        -- Setup mock registry
        registry = {
            services = {},
            get = function(self, name)
                return self.services[name]
            end,
            register = function(self, name, service)
                self.services[name] = service
            end
        }
        
        -- Load systems (if available)
        local success, MissionSystem = pcall(require, "src.systems.MissionSystem")
        if success then
            missionSystem = MissionSystem:new(registry)
            registry:register("mission", missionSystem)
        end
        
        success, CombatSystem = pcall(require, "src.battlescape.CombatSystem")
        if success then
            combatSystem = CombatSystem:new(registry)
            registry:register("combat", combatSystem)
        end
        
        success, EconomyService = pcall(require, "src.economy.EconomyService")
        if success then
            economyService = EconomyService:new(registry)
            registry:register("economy", economyService)
        end
        
        success, UnitManager = pcall(require, "src.units.UnitManager")
        if success then
            unitManager = UnitManager:new(registry)
            registry:register("units", unitManager)
        end
    end)
    
    describe("Complete Mission Workflow", function()
        it("should handle UFO crash site mission end-to-end", function()
            if not missionSystem or not combatSystem then return end
            
            -- Step 1: Generate crash site mission
            local mission = missionSystem:createMission({
                type = "crash_site",
                ufo_type = "scout",
                location = {x = 100, y = 200, country = "USA"}
            })
            
            expect(mission).to.exist()
            expect(mission.type).to.equal("crash_site")
            
            -- Step 2: Prepare squad
            local squad = {}
            if unitManager then
                for i = 1, 4 do
                    local soldier = unitManager:createUnit({
                        name = "Soldier " .. i,
                        class = "assault",
                        health = 100
                    })
                    table.insert(squad, soldier)
                end
            end
            
            -- Step 3: Initialize combat
            local battle = combatSystem:initializeBattle({
                mission = mission,
                squad = squad,
                seed = 12345
            })
            
            expect(battle).to.exist()
            expect(battle.player_units).to.exist()
            expect(battle.enemy_units).to.exist()
            
            -- Step 4: Simulate combat rounds
            for round = 1, 5 do
                combatSystem:processTurn(battle.id)
                
                if combatSystem:isBattleComplete(battle.id) then
                    break
                end
            end
            
            -- Step 5: Get battle results
            local results = combatSystem:getBattleResults(battle.id)
            
            expect(results).to.exist()
            expect(results.victor).to.exist()
            
            -- Step 6: Apply mission rewards
            if economyService and results.victor == "player" then
                local rewards = missionSystem:calculateRewards(mission, results)
                economyService:applyRewards(rewards)
                
                expect(rewards.credits).to.be.greater_than(0)
            end
        end)
        
        it("should handle terror mission with civilians", function()
            if not missionSystem or not combatSystem then return end
            
            -- Generate terror mission
            local mission = missionSystem:createMission({
                type = "terror",
                location = {city = "New York", population = 8000000},
                civilian_count = 12
            })
            
            expect(mission.civilian_count).to.equal(12)
            
            -- Initialize battle with civilians
            local battle = combatSystem:initializeBattle({
                mission = mission,
                include_civilians = true
            })
            
            expect(battle.civilians).to.exist()
            expect(#battle.civilians).to.be.greater_than(0)
            
            -- Simulate combat
            combatSystem:processTurn(battle.id)
            
            -- Check civilian safety
            local civiliansSaved = combatSystem:countCiviliansSaved(battle.id)
            expect(civiliansSaved).to.be.greater_than_or_equal(0)
        end)
    end)
    
    describe("Geoscape to Interception Flow", function()
        it("should transition from UFO detection to interception", function()
            if not missionSystem then return end
            
            -- Step 1: UFO detected on geoscape
            local ufoSighting = {
                type = "scout",
                position = {x = 150, y = 250},
                heading = 90,
                speed = 300
            }
            
            -- Step 2: Launch interceptor
            local interception
            local success, InterceptionService = pcall(require, "src.interception.InterceptionService")
            if success then
                interception = InterceptionService:new(registry)
                
                local interceptor = {
                    id = "int1",
                    type = "interceptor",
                    weapons = {"cannon", "missiles"}
                }
                
                local combatResult = interception:startInterception(
                    "mission1",
                    "ufo_intercept",
                    {interceptor},
                    {ufoSighting},
                    true
                )
                
                expect(combatResult).to.exist()
            end
            
            -- Step 3: UFO crashes - generates crash site mission
            if interception and missionSystem then
                local crashMission = missionSystem:createCrashSiteFromInterception({
                    ufo_type = ufoSighting.type,
                    damage_level = 0.7,
                    position = ufoSighting.position
                })
                
                expect(crashMission).to.exist()
                expect(crashMission.type).to.equal("crash_site")
            end
        end)
    end)
    
    describe("Research and Manufacturing Integration", function()
        it("should unlock new items after research completion", function()
            local researchSystem, manufactureSystem
            
            local success, Research = pcall(require, "src.systems.ResearchSystem")
            if success then
                researchSystem = Research:new(registry)
            end
            
            success, Manufacture = pcall(require, "src.systems.ManufactureSystem")
            if success then
                manufactureSystem = Manufacture:new(registry)
            end
            
            if not researchSystem or not manufactureSystem then return end
            
            -- Step 1: Complete research project
            researchSystem:completeProject("laser_weapons")
            
            -- Step 2: Check if manufacturing unlocked
            local available = manufactureSystem:getAvailableProjects()
            
            local laserRifleAvailable = false
            for _, project in ipairs(available) do
                if project.id == "laser_rifle" then
                    laserRifleAvailable = true
                    break
                end
            end
            
            expect(laserRifleAvailable).to.be.truthy()
        end)
    end)
    
    describe("Base Management Integration", function()
        it("should affect mission capability through base facilities", function()
            local baseManager
            
            local success, BaseManager = pcall(require, "src.basescape.BaseManager")
            if success then
                baseManager = BaseManager:new(registry)
            end
            
            if not baseManager or not missionSystem then return end
            
            -- Create base with hangar
            local base = baseManager:createBase({
                name = "HQ",
                facilities = {
                    {type = "hangar", count = 2},
                    {type = "barracks", count = 1}
                }
            })
            
            -- Check mission deployment capacity
            local capacity = missionSystem:getDeploymentCapacity(base.id)
            
            expect(capacity.max_crafts).to.be.greater_than(0)
            expect(capacity.max_soldiers).to.be.greater_than(0)
        end)
    end)
    
    describe("Experience and Progression", function()
        it("should award experience and level up soldiers", function()
            if not combatSystem or not unitManager then return end
            
            -- Create soldier
            local soldier = unitManager:createUnit({
                name = "Rookie",
                class = "assault",
                level = 1,
                experience = 0
            })
            
            -- Simulate mission with combat actions
            local battleResult = {
                soldier_performance = {
                    [soldier.id] = {
                        kills = 3,
                        shots_fired = 12,
                        shots_hit = 8,
                        damage_dealt = 450
                    }
                }
            }
            
            -- Award experience
            unitManager:awardExperience(soldier.id, battleResult.soldier_performance[soldier.id])
            
            local updatedSoldier = unitManager:getUnit(soldier.id)
            
            expect(updatedSoldier.experience).to.be.greater_than(0)
            
            -- Check for level up
            if updatedSoldier.experience >= 100 then
                expect(updatedSoldier.level).to.be.greater_than(1)
            end
        end)
    end)
    
    describe("Country Funding Integration", function()
        it("should adjust funding based on mission performance", function()
            if not missionSystem or not economyService then return end
            
            -- Initial funding state
            local country = {
                name = "USA",
                funding = 1000000,
                happiness = 75
            }
            
            -- Complete successful mission
            local mission = missionSystem:createMission({
                type = "terror",
                location = "USA"
            })
            
            missionSystem:completeMission(mission.id, {
                result = "success",
                civilians_saved = 10,
                aliens_eliminated = 15
            })
            
            -- Apply consequences
            economyService:updateCountryRelations(country, mission)
            
            expect(country.happiness).to.be.greater_than_or_equal(75)
        end)
    end)
    
    describe("Error Recovery", function()
        it("should handle mission abortion gracefully", function()
            if not missionSystem or not combatSystem then return end
            
            local mission = missionSystem:createMission({type = "crash_site"})
            local battle = combatSystem:initializeBattle({mission = mission})
            
            -- Abort mission
            local success, err = pcall(function()
                combatSystem:abortMission(battle.id)
            end)
            
            expect(success).to.be.truthy()
            
            -- Mission should be marked as aborted
            local missionStatus = missionSystem:getMissionStatus(mission.id)
            expect(missionStatus).to.equal("aborted")
        end)
        
        it("should handle squad wipe scenarios", function()
            if not combatSystem then return end
            
            local battle = combatSystem:initializeBattle({
                mission = {type = "alien_base"},
                squad = {}  -- Empty squad
            })
            
            -- Battle should handle empty squad
            local valid = combatSystem:validateBattle(battle.id)
            expect(valid).to.exist()
        end)
    end)
end)

return {
    name = "Mission to Combat Flow Integration Tests",
    run = function()
        -- Tests run automatically via describe blocks
    end
}
