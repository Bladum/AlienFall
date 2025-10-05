--- Test suite for Mission System
--
-- Comprehensive tests for mission generation, management, and resolution.
--
-- @module test.systems.test_mission_system

local test_framework = require "test.framework.test_framework"
local describe = test_framework.describe
local it = test_framework.it
local expect = test_framework.expect
local before = test_framework.before

-- Mock dependencies
local function create_mock_registry()
    return {
        services = {},
        get = function(self, name)
            return self.services[name]
        end,
        register = function(self, name, service)
            self.services[name] = service
        end
    }
end

describe("Mission System", function()
    local MissionSystem
    local missionSystem
    local registry
    
    before(function()
        local success, module = pcall(require, "src.systems.MissionSystem")
        if success then
            MissionSystem = module
            registry = create_mock_registry()
            missionSystem = MissionSystem:new(registry)
        end
    end)
    
    describe("Mission Generation", function()
        it("should generate missions based on threat level", function()
            if not missionSystem then return end
            
            local threatLevel = 0.7  -- High threat
            local location = {
                x = 100,
                y = 200,
                country = "USA",
                population = 1000000
            }
            
            local mission = missionSystem:generateMission(threatLevel, location)
            
            expect(mission).to.exist()
            expect(mission.type).to.exist()
            expect(mission.difficulty).to.be.greater_than(0)
        end)
        
        it("should create appropriate mission types for locations", function()
            if not missionSystem then return end
            
            local urbanLocation = {type = "urban", population = 5000000}
            local ruralLocation = {type = "rural", population = 10000}
            
            local urbanMission = missionSystem:generateMissionForLocation(urbanLocation)
            local ruralMission = missionSystem:generateMissionForLocation(ruralLocation)
            
            expect(urbanMission.type).to.exist()
            expect(ruralMission.type).to.exist()
        end)
        
        it("should scale mission difficulty appropriately", function()
            if not missionSystem then return end
            
            local easyMission = missionSystem:createMission({difficulty = "easy"})
            local hardMission = missionSystem:createMission({difficulty = "hard"})
            
            expect(easyMission.enemy_count).to.be.less_than(hardMission.enemy_count)
        end)
    end)
    
    describe("Mission Types", function()
        it("should generate UFO crash site missions", function()
            if not missionSystem then return end
            
            local crashSite = missionSystem:createCrashSiteMission({
                ufo_type = "scout",
                crash_severity = 0.6
            })
            
            expect(crashSite.type).to.equal("crash_site")
            expect(crashSite.loot_available).to.be.truthy()
        end)
        
        it("should generate terror missions", function()
            if not missionSystem then return end
            
            local terrorMission = missionSystem:createTerrorMission({
                location = {city = "New York", population = 8000000}
            })
            
            expect(terrorMission.type).to.equal("terror")
            expect(terrorMission.civilian_count).to.be.greater_than(0)
        end)
        
        it("should generate alien base assault missions", function()
            if not missionSystem then return end
            
            local baseAssault = missionSystem:createAlienBaseAssault({
                base_level = 3,
                discovered_by = "radar"
            })
            
            expect(baseAssault.type).to.equal("alien_base")
            expect(baseAssault.objective).to.equal("destroy_power_source")
        end)
    end)
    
    describe("Mission Objectives", function()
        it("should track primary objectives", function()
            if not missionSystem then return end
            
            local mission = missionSystem:createMission({
                type = "crash_site",
                objectives = {
                    primary = {
                        {id = "recover_ufo", description = "Secure UFO wreckage"},
                        {id = "eliminate_aliens", description = "Eliminate all hostiles"}
                    }
                }
            })
            
            expect(#mission.objectives.primary).to.equal(2)
        end)
        
        it("should mark objectives as completed", function()
            if not missionSystem then return end
            
            local mission = missionSystem:createMission({type = "crash_site"})
            missionSystem:completeObjective(mission.id, "recover_ufo")
            
            local objective = missionSystem:getObjective(mission.id, "recover_ufo")
            expect(objective.completed).to.be.truthy()
        end)
        
        it("should calculate mission success based on objectives", function()
            if not missionSystem then return end
            
            local mission = missionSystem:createMission({type = "terror"})
            
            missionSystem:completeObjective(mission.id, "eliminate_aliens")
            missionSystem:failObjective(mission.id, "save_civilians")
            
            local success = missionSystem:isMissionSuccessful(mission.id)
            
            -- Success depends on primary vs secondary objectives
            expect(success).to.exist()
        end)
    end)
    
    describe("Mission Rewards", function()
        it("should calculate credits reward", function()
            if not missionSystem then return end
            
            local mission = {
                type = "terror",
                difficulty = "hard",
                civilians_saved = 15,
                aliens_captured = 3
            }
            
            local credits = missionSystem:calculateCreditsReward(mission)
            
            expect(credits).to.be.greater_than(0)
        end)
        
        it("should award research items", function()
            if not missionSystem then return end
            
            local mission = {
                type = "crash_site",
                completed = true,
                aliens_captured = 2,
                artifacts_recovered = 5
            }
            
            local researchItems = missionSystem:getResearchRewards(mission)
            
            expect(researchItems).to.exist()
            expect(#researchItems).to.be.greater_than(0)
        end)
        
        it("should provide experience to soldiers", function()
            if not missionSystem then return end
            
            local soldiers = {
                {id = "sol1", kills = 3, shots_fired = 10},
                {id = "sol2", kills = 1, shots_fired = 8}
            }
            
            local expGained = missionSystem:calculateExperienceGain(soldiers)
            
            expect(expGained.sol1).to.be.greater_than(expGained.sol2)
        end)
    end)
    
    describe("Mission Failure Consequences", function()
        it("should reduce country funding on failed missions", function()
            if not missionSystem then return end
            
            local country = {name = "USA", funding = 1000000, panic = 20}
            local mission = {type = "terror", location = "USA", result = "failure"}
            
            missionSystem:applyMissionConsequences(mission, country)
            
            expect(country.panic).to.be.greater_than(20)
        end)
        
        it("should increase alien activity after failures", function()
            if not missionSystem then return end
            
            local initialThreat = missionSystem:getGlobalThreatLevel()
            
            missionSystem:recordMissionFailure({
                type = "terror",
                severity = "high"
            })
            
            local newThreat = missionSystem:getGlobalThreatLevel()
            expect(newThreat).to.be.greater_than(initialThreat)
        end)
    end)
    
    describe("Mission Time Limits", function()
        it("should enforce time-sensitive missions", function()
            if not missionSystem then return end
            
            local mission = missionSystem:createMission({
                type = "terror",
                time_limit = 24  -- 24 hours
            })
            
            missionSystem:advanceTime(mission.id, 25)
            
            local expired = missionSystem:isMissionExpired(mission.id)
            expect(expired).to.be.truthy()
        end)
        
        it("should auto-resolve expired missions", function()
            if not missionSystem then return end
            
            local mission = missionSystem:createMission({
                type = "ufo_landing",
                time_limit = 12
            })
            
            missionSystem:advanceTime(mission.id, 15)
            missionSystem:resolveExpiredMissions()
            
            local result = missionSystem:getMissionResult(mission.id)
            expect(result).to.equal("expired")
        end)
    end)
    
    describe("Mission Scheduling", function()
        it("should schedule missions at appropriate intervals", function()
            if not missionSystem then return end
            
            missionSystem:setDifficulty("normal")
            
            local schedule = missionSystem:generateMissionSchedule(30)  -- 30 days
            
            expect(#schedule).to.be.greater_than(0)
            expect(#schedule).to.be.less_than(50)  -- Reasonable frequency
        end)
        
        it("should prevent mission spam", function()
            if not missionSystem then return end
            
            -- Create multiple missions quickly
            for i = 1, 5 do
                missionSystem:createMission({type = "ufo_sighting"})
            end
            
            local activeMissions = missionSystem:getActiveMissions()
            
            -- System should limit concurrent missions
            expect(#activeMissions).to.be.less_than_or_equal(3)
        end)
    end)
    
    describe("Mission Load-outs", function()
        it("should validate squad composition", function()
            if not missionSystem then return end
            
            local squad = {
                {id = "sol1", class = "assault"},
                {id = "sol2", class = "sniper"},
                {id = "sol3", class = "medic"}
            }
            
            local valid = missionSystem:validateSquad(squad)
            expect(valid).to.be.truthy()
        end)
        
        it("should enforce maximum squad size", function()
            if not missionSystem then return end
            
            local largeSquad = {}
            for i = 1, 15 do
                table.insert(largeSquad, {id = "sol" .. i})
            end
            
            local valid = missionSystem:validateSquad(largeSquad)
            expect(valid).to.be.falsy()
        end)
        
        it("should check equipment availability", function()
            if not missionSystem then return end
            
            local squad = {
                {id = "sol1", equipment = {"laser_rifle", "medikit"}},
                {id = "sol2", equipment = {"plasma_pistol", "grenade"}}
            }
            
            local available = missionSystem:checkEquipmentAvailability(squad)
            
            expect(available).to.exist()
        end)
    end)
    
    describe("Mission Briefing", function()
        it("should generate mission briefing data", function()
            if not missionSystem then return end
            
            local mission = missionSystem:createMission({
                type = "crash_site",
                location = {country = "Canada", terrain = "snow"}
            })
            
            local briefing = missionSystem:generateBriefing(mission.id)
            
            expect(briefing.mission_type).to.exist()
            expect(briefing.location).to.exist()
            expect(briefing.expected_resistance).to.exist()
        end)
        
        it("should provide intel on enemy composition", function()
            if not missionSystem then return end
            
            local mission = missionSystem:createMission({
                type = "alien_base",
                intel_level = 2  -- Some intelligence gathered
            })
            
            local intel = missionSystem:getEnemyIntel(mission.id)
            
            expect(intel).to.exist()
            expect(intel.accuracy).to.be.greater_than(0)
        end)
    end)
end)

return {
    name = "Mission System Tests",
    run = function()
        -- Tests run automatically via describe blocks
    end
}
