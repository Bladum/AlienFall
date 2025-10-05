--- Integration Test Suite for Alien Fall
--
-- Tests interactions between major game systems to ensure proper integration.
-- These tests verify that systems work together correctly in realistic scenarios.
--
-- @module test.integration.test_system_integration

local lust = require "lust"
local describe, it, expect, before, after = lust.describe, lust.it, lust.expect, lust.before, lust.after

describe("System Integration Tests", function()
    
    local game_state, unit_service, mission_service, base_manager
    
    before(function()
        -- Set up mock game state and services
        game_state = {
            current_date = {year = 2050, month = 1, day = 1},
            bases = {},
            units = {},
            missions = {},
            resources = {credits = 100000, supplies = 500}
        }
    end)
    
    after(function()
        -- Clean up
        game_state = nil
        unit_service = nil
        mission_service = nil
        base_manager = nil
    end)
    
    describe("Geoscape to Battlescape Flow", function()
        
        it("transitions from geoscape mission to battlescape", function()
            -- 1. Generate mission on geoscape
            local mission = {
                id = "mission_001",
                type = "alien_crash_site",
                location = {x = 100, y = 200},
                difficulty = "normal",
                squad_size = 6,
                status = "pending"
            }
            
            expect(mission.status).to.equal("pending")
            
            -- 2. Assign squad to mission
            local squad = {
                {id = "soldier_1", class_id = "assault"},
                {id = "soldier_2", class_id = "scout"},
                {id = "soldier_3", class_id = "heavy"},
                {id = "soldier_4", class_id = "medic"}
            }
            
            mission.assigned_squad = squad
            mission.status = "in_progress"
            
            expect(#mission.assigned_squad).to.equal(4)
            expect(mission.status).to.equal("in_progress")
            
            -- 3. Transition to battlescape
            local battle_state = {
                mission_id = mission.id,
                map_type = mission.type,
                player_units = mission.assigned_squad,
                turn = 1,
                phase = "player"
            }
            
            expect(battle_state.mission_id).to.equal("mission_001")
            expect(#battle_state.player_units).to.equal(4)
            expect(battle_state.phase).to.equal("player")
        end)
        
        it("completes mission and returns to geoscape with rewards", function()
            -- 1. Battle completes successfully
            local battle_result = {
                victory = true,
                casualties = 1,  -- Lost one soldier
                enemies_killed = 8,
                loot = {
                    {item_id = "alien_weapon", quantity = 2},
                    {item_id = "alien_corpse", quantity = 5}
                },
                experience_gained = 150
            }
            
            expect(battle_result.victory).to.be.truthy()
            
            -- 2. Update mission status
            local mission = {
                id = "mission_001",
                status = "in_progress"
            }
            
            if battle_result.victory then
                mission.status = "completed"
                mission.result = battle_result
            end
            
            expect(mission.status).to.equal("completed")
            expect(mission.result.victory).to.be.truthy()
            
            -- 3. Apply rewards to geoscape
            local initial_resources = {credits = 100000, items = {}}
            
            -- Add loot to inventory
            for _, loot_item in ipairs(battle_result.loot) do
                initial_resources.items[loot_item.item_id] = 
                    (initial_resources.items[loot_item.item_id] or 0) + loot_item.quantity
            end
            
            expect(initial_resources.items["alien_weapon"]).to.equal(2)
            expect(initial_resources.items["alien_corpse"]).to.equal(5)
            
            -- 4. Award experience to surviving units
            local surviving_units = 3  -- 4 original - 1 casualty
            expect(surviving_units).to.equal(3)
        end)
        
    end)
    
    describe("Mission Generation and Combat Flow", function()
        
        it("generates mission based on world state", function()
            -- 1. World state determines mission availability
            local world_state = {
                alien_activity = 75,  -- High activity
                detected_ufos = 3,
                regions = {
                    {id = "north_america", panic = 50, ufo_count = 1}
                }
            }
            
            -- 2. Mission generator creates appropriate mission
            local mission = {
                type = "ufo_crash",
                difficulty = world_state.alien_activity > 50 and "hard" or "normal",
                location_region = "north_america",
                enemy_count = math.floor(world_state.alien_activity / 10)
            }
            
            expect(mission.type).to.equal("ufo_crash")
            expect(mission.difficulty).to.equal("hard")
            expect(mission.enemy_count).to.equal(7)
        end)
        
        it("executes full combat encounter", function()
            -- 1. Initialize combat
            local combat = {
                player_units = {
                    {id = "soldier_1", health = 100, actions = 2},
                    {id = "soldier_2", health = 100, actions = 2}
                },
                enemy_units = {
                    {id = "alien_1", health = 80, actions = 2},
                    {id = "alien_2", health = 80, actions = 2}
                },
                turn = 1,
                phase = "player"
            }
            
            -- 2. Player turn - attack action
            local attacker = combat.player_units[1]
            local target = combat.enemy_units[1]
            
            attacker.actions = attacker.actions - 1
            local damage = 30
            target.health = target.health - damage
            
            expect(attacker.actions).to.equal(1)
            expect(target.health).to.equal(50)
            
            -- 3. End turn, switch to enemy phase
            combat.phase = "enemy"
            
            -- 4. Enemy turn - counter attack
            local enemy_attacker = combat.enemy_units[1]
            local player_target = combat.player_units[1]
            
            enemy_attacker.actions = enemy_attacker.actions - 1
            local enemy_damage = 20
            player_target.health = player_target.health - enemy_damage
            
            expect(player_target.health).to.equal(80)
            
            -- 5. End turn, increment turn counter
            combat.turn = combat.turn + 1
            combat.phase = "player"
            
            -- Reset action points
            for _, unit in ipairs(combat.player_units) do
                unit.actions = 2
            end
            
            expect(combat.turn).to.equal(2)
            expect(combat.player_units[1].actions).to.equal(2)
        end)
        
    end)
    
    describe("Base Management and Production Flow", function()
        
        it("builds facility and affects base capacity", function()
            -- 1. Initial base state
            local base = {
                id = "base_001",
                name = "HQ",
                facilities = {},
                capacity = {
                    power = 0,
                    personnel = 0,
                    storage = 0
                }
            }
            
            -- 2. Add power generator
            local power_plant = {
                id = "power_plant_001",
                type = "power_generator",
                provides = {power = 50},
                construction_time = 20,
                status = "under_construction",
                days_remaining = 20
            }
            
            table.insert(base.facilities, power_plant)
            
            -- 3. Simulate construction completion
            power_plant.days_remaining = 0
            power_plant.status = "operational"
            
            -- 4. Apply facility benefits
            if power_plant.status == "operational" then
                base.capacity.power = base.capacity.power + power_plant.provides.power
            end
            
            expect(base.capacity.power).to.equal(50)
            expect(power_plant.status).to.equal("operational")
        end)
        
        it("manufactures items consuming resources", function()
            -- 1. Initial resource state
            local resources = {
                credits = 10000,
                alloys = 50,
                electronics = 30
            }
            
            -- 2. Start manufacturing project
            local project = {
                item_id = "laser_rifle",
                quantity = 5,
                cost_per_unit = {
                    credits = 500,
                    alloys = 5,
                    electronics = 3
                },
                time_per_unit = 3,
                total_time = 15,
                progress = 0
            }
            
            -- 3. Deduct initial costs
            resources.credits = resources.credits - (project.cost_per_unit.credits * project.quantity)
            resources.alloys = resources.alloys - (project.cost_per_unit.alloys * project.quantity)
            resources.electronics = resources.electronics - (project.cost_per_unit.electronics * project.quantity)
            
            expect(resources.credits).to.equal(7500)  -- 10000 - 2500
            expect(resources.alloys).to.equal(25)     -- 50 - 25
            expect(resources.electronics).to.equal(15) -- 30 - 15
            
            -- 4. Complete manufacturing
            project.progress = project.total_time
            
            expect(project.progress).to.equal(project.total_time)
        end)
        
        it("researches technology unlocking new options", function()
            -- 1. Initial research state
            local research_state = {
                completed = {},
                available = {"laser_weapons", "alien_biology"},
                locked = {"plasma_weapons", "psi_research"}
            }
            
            -- 2. Complete research project
            local project = {
                tech_id = "laser_weapons",
                progress = 100,
                required = 100
            }
            
            if project.progress >= project.required then
                table.insert(research_state.completed, project.tech_id)
                
                -- Remove from available
                for i, tech in ipairs(research_state.available) do
                    if tech == project.tech_id then
                        table.remove(research_state.available, i)
                        break
                    end
                end
                
                -- Unlock dependent technologies
                if project.tech_id == "laser_weapons" then
                    -- Plasma weapons now available
                    for i, tech in ipairs(research_state.locked) do
                        if tech == "plasma_weapons" then
                            table.remove(research_state.locked, i)
                            table.insert(research_state.available, tech)
                            break
                        end
                    end
                end
            end
            
            expect(#research_state.completed).to.equal(1)
            expect(research_state.completed[1]).to.equal("laser_weapons")
            
            -- Check unlock
            local plasma_available = false
            for _, tech in ipairs(research_state.available) do
                if tech == "plasma_weapons" then
                    plasma_available = true
                    break
                end
            end
            expect(plasma_available).to.be.truthy()
        end)
        
    end)
    
    describe("Detection and Interception Flow", function()
        
        it("detects UFO and launches interception", function()
            -- 1. UFO enters detection range
            local ufo = {
                id = "ufo_001",
                position = {x = 150, y = 250},
                detected = false,
                speed = 500
            }
            
            local radar = {
                position = {x = 100, y = 200},
                range = 1000
            }
            
            -- 2. Check detection
            local dx = ufo.position.x - radar.position.x
            local dy = ufo.position.y - radar.position.y
            local distance = math.sqrt(dx * dx + dy * dy)
            
            if distance <= radar.range then
                ufo.detected = true
            end
            
            expect(ufo.detected).to.be.truthy()
            
            -- 3. Launch interceptor
            local interceptor = {
                id = "interceptor_001",
                position = {x = 100, y = 200},
                speed = 800,
                weapons = {missiles = 6},
                target = ufo.id
            }
            
            expect(interceptor.target).to.equal("ufo_001")
            expect(interceptor.speed).to.be.greater(ufo.speed)
        end)
        
        it("conducts air combat and forces UFO crash", function()
            -- 1. Air combat state
            local interceptor = {
                health = 100,
                weapons = {missiles = 4}
            }
            
            local ufo = {
                health = 150,
                weapons = {plasma_cannon = 1}
            }
            
            -- 2. Combat round - interceptor attacks
            interceptor.weapons.missiles = interceptor.weapons.missiles - 1
            local missile_damage = 50
            ufo.health = ufo.health - missile_damage
            
            expect(ufo.health).to.equal(100)
            expect(interceptor.weapons.missiles).to.equal(3)
            
            -- 3. UFO counter-attacks
            local plasma_damage = 30
            interceptor.health = interceptor.health - plasma_damage
            
            expect(interceptor.health).to.equal(70)
            
            -- 4. Another round - UFO defeated
            interceptor.weapons.missiles = interceptor.weapons.missiles - 2
            ufo.health = ufo.health - (missile_damage * 2)
            
            expect(ufo.health).to.equal(0)
            expect(ufo.health).to_not.be.greater(0)
            
            -- 5. Generate crash site mission
            local crash_mission = {
                type = "ufo_crash",
                location = {x = ufo.position or 150, y = 250},
                ufo_type = "scout",
                status = "pending"
            }
            
            expect(crash_mission.type).to.equal("ufo_crash")
        end)
        
    end)
    
    describe("Unit Progression and Equipment", function()
        
        it("unit gains experience and levels up", function()
            -- 1. Initial unit state
            local unit = {
                id = "soldier_1",
                level = 1,
                experience = 80,
                experience_to_next = 100,
                stats = {
                    health = 100,
                    accuracy = 60
                }
            }
            
            -- 2. Gain experience from combat
            local exp_gain = 30
            unit.experience = unit.experience + exp_gain
            
            expect(unit.experience).to.equal(110)
            
            -- 3. Level up!
            if unit.experience >= unit.experience_to_next then
                unit.level = unit.level + 1
                unit.experience = unit.experience - unit.experience_to_next
                unit.experience_to_next = math.floor(unit.experience_to_next * 1.5)
                
                -- Stat increases
                unit.stats.health = unit.stats.health + 10
                unit.stats.accuracy = unit.stats.accuracy + 5
            end
            
            expect(unit.level).to.equal(2)
            expect(unit.experience).to.equal(10)
            expect(unit.stats.health).to.equal(110)
            expect(unit.stats.accuracy).to.equal(65)
        end)
        
        it("equips item and applies stat modifiers", function()
            -- 1. Unit without equipment
            local unit = {
                stats = {
                    accuracy = 60,
                    armor = 5
                },
                equipment = {
                    weapon = nil,
                    armor = nil
                }
            }
            
            -- 2. Equip weapon
            local weapon = {
                id = "laser_rifle",
                accuracy_bonus = 10,
                damage = 40
            }
            
            unit.equipment.weapon = weapon
            
            -- 3. Equip armor
            local armor = {
                id = "kevlar_vest",
                armor_bonus = 15
            }
            
            unit.equipment.armor = armor
            
            -- 4. Calculate effective stats
            local effective_accuracy = unit.stats.accuracy + 
                (unit.equipment.weapon and unit.equipment.weapon.accuracy_bonus or 0)
            local effective_armor = unit.stats.armor + 
                (unit.equipment.armor and unit.equipment.armor.armor_bonus or 0)
            
            expect(effective_accuracy).to.equal(70)  -- 60 + 10
            expect(effective_armor).to.equal(20)     -- 5 + 15
        end)
        
    end)
    
    describe("Save and Load Game State", function()
        
        it("serializes and deserializes game state", function()
            -- 1. Original game state
            local original_state = {
                date = {year = 2050, month = 3, day = 15},
                credits = 50000,
                bases = {
                    {id = "base_001", name = "HQ"}
                },
                units = {
                    {id = "soldier_1", level = 5, health = 95}
                }
            }
            
            -- 2. Simulate serialization (to TOML/JSON)
            local serialized = {
                date = original_state.date,
                credits = original_state.credits,
                bases = original_state.bases,
                units = original_state.units
            }
            
            -- 3. Simulate deserialization
            local loaded_state = {
                date = serialized.date,
                credits = serialized.credits,
                bases = serialized.bases,
                units = serialized.units
            }
            
            -- 4. Verify round-trip
            expect(loaded_state.credits).to.equal(original_state.credits)
            expect(loaded_state.date.year).to.equal(2050)
            expect(#loaded_state.bases).to.equal(1)
            expect(loaded_state.bases[1].name).to.equal("HQ")
            expect(loaded_state.units[1].level).to.equal(5)
        end)
        
    end)
    
end)

return describe
