--- test_phase3_systems.lua
-- Comprehensive tests for Phase 3: Geoscape Completion

local lust = require 'test.framework.lust'
local describe, it, expect = lust.describe, lust.it, lust.expect

local UFO = require 'geoscape.UFO'
local UFOSpawner = require 'geoscape.UFOSpawner'
local MissionSiteGenerator = require 'geoscape.MissionSiteGenerator'
local AlienActivityManager = require 'geoscape.AlienActivityManager'
local WorldGenerator = require 'geoscape.WorldGenerator'

describe('Phase 3: Geoscape Completion Systems', function()
    
    describe('UFO Entity', function()
        it('should create UFO with default properties', function()
            local ufo = UFO:new({
                id = "test_ufo_1",
                type = UFO.MissionType.SCOUT,
                size = UFO.Size.SMALL
            })
            
            expect(ufo).to.exist()
            expect(ufo.id).to.equal("test_ufo_1")
            expect(ufo.type).to.equal("scout")
            expect(ufo.size).to.equal("small")
            expect(ufo.state).to.equal(UFO.State.FLYING)
        end)
        
        it('should calculate stats based on size', function()
            local small_ufo = UFO:new({size = UFO.Size.SMALL})
            local large_ufo = UFO:new({size = UFO.Size.LARGE})
            
            expect(small_ufo.speed).to.be_greater_than(large_ufo.speed)
            expect(small_ufo.max_health).to.be_less_than(large_ufo.max_health)
            expect(small_ufo.evasion).to.be_greater_than(large_ufo.evasion)
        end)
        
        it('should update movement towards destination', function()
            local ufo = UFO:new({
                coordinates = {0, 0},
                destination = {100, 100},
                speed = 50
            })
            
            ufo:update(1)  -- 1 second
            
            expect(ufo.coordinates[1]).to_not.equal(0)
            expect(ufo.coordinates[2]).to_not.equal(0)
        end)
        
        it('should detect UFO', function()
            local ufo = UFO:new({})
            
            expect(ufo:isDetected()).to.equal(false)
            
            ufo:detect()
            
            expect(ufo:isDetected()).to.equal(true)
        end)
        
        it('should take damage and destroy when health reaches zero', function()
            local ufo = UFO:new({
                size = UFO.Size.SMALL
            })
            
            local initial_health = ufo.current_health
            ufo:takeDamage(50)
            
            expect(ufo.current_health).to.be_less_than(initial_health)
            
            -- Destroy completely
            ufo:takeDamage(1000)
            
            expect(ufo.state).to.equal(UFO.State.DESTROYED)
            expect(ufo.current_health).to.equal(0)
        end)
        
        it('should retreat when health is low', function()
            local ufo = UFO:new({
                size = UFO.Size.MEDIUM,
                state = UFO.State.FLYING
            })
            
            ufo:retreat()
            
            expect(ufo.state).to.equal(UFO.State.RETREATING)
        end)
    end)
    
    describe('UFOSpawner', function()
        it('should initialize with config', function()
            local rng = love.math.newRandomGenerator(12345)
            local config = {
                base_spawn_rate = 0.2,
                max_concurrent_ufos = 5
            }
            local spawner = UFOSpawner:new(rng, config)
            
            expect(spawner).to.exist()
            expect(spawner.base_spawn_rate).to.equal(0.2)
            expect(spawner.max_concurrent_ufos).to.equal(5)
        end)
        
        it('should select mission type based on weights', function()
            local rng = love.math.newRandomGenerator(12345)
            local spawner = UFOSpawner:new(rng)
            
            local mission_type = spawner:selectMissionType()
            
            expect(mission_type).to.exist()
            expect(type(mission_type)).to.equal("string")
        end)
        
        it('should select UFO size based on weights', function()
            local rng = love.math.newRandomGenerator(12345)
            local spawner = UFOSpawner:new(rng)
            
            local size = spawner:selectSize()
            
            expect(size).to.exist()
            expect(type(size)).to.equal("string")
        end)
        
        it('should adjust spawn rate with alien activity', function()
            local rng = love.math.newRandomGenerator(12345)
            local spawner = UFOSpawner:new(rng)
            
            spawner:setAlienActivityLevel(3.0)
            
            expect(spawner.spawn_rate_multiplier).to.be_greater_than(1.0)
        end)
        
        it('should track active UFOs', function()
            local rng = love.math.newRandomGenerator(12345)
            local spawner = UFOSpawner:new(rng)
            
            expect(spawner:getActiveUFOCount()).to.equal(0)
        end)
    end)
    
    describe('MissionSiteGenerator', function()
        it('should initialize', function()
            local rng = love.math.newRandomGenerator(12345)
            local generator = MissionSiteGenerator:new(rng)
            
            expect(generator).to.exist()
            expect(#generator.active_sites).to.equal(0)
        end)
        
        it('should generate crash site from UFO', function()
            local rng = love.math.newRandomGenerator(12345)
            local generator = MissionSiteGenerator:new(rng)
            
            -- Create mock world
            local world_gen = WorldGenerator:new(rng, {province_count = 10})
            local world = world_gen:generateQuickWorld("test_world")
            generator:setWorld(world)
            
            -- Create mock UFO
            local ufo = UFO:new({
                id = "test_ufo",
                type = "scout",
                size = "small",
                coordinates = {400, 300}
            })
            
            local site = generator:generateCrashSite(ufo)
            
            expect(site).to.exist()
            expect(site.type).to.equal(MissionSiteGenerator.SiteType.CRASH_SITE)
            expect(site.ufo_id).to.equal("test_ufo")
        end)
        
        it('should calculate difficulty based on UFO size', function()
            local rng = love.math.newRandomGenerator(12345)
            local generator = MissionSiteGenerator:new(rng)
            
            local small_ufo = UFO:new({size = "small"})
            local large_ufo = UFO:new({size = "large"})
            
            local small_difficulty = generator:_calculateDifficulty(small_ufo)
            local large_difficulty = generator:_calculateDifficulty(large_ufo)
            
            expect(large_difficulty).to.be_greater_than(small_difficulty)
        end)
        
        it('should cleanup expired sites', function()
            local rng = love.math.newRandomGenerator(12345)
            local generator = MissionSiteGenerator:new(rng)
            
            -- Add expired site
            table.insert(generator.active_sites, {
                id = "expired_site",
                expiry_time = os.time() - 1000  -- Expired 1000 seconds ago
            })
            
            generator:cleanupExpiredSites()
            
            expect(#generator.active_sites).to.equal(0)
        end)
        
        it('should track active sites', function()
            local rng = love.math.newRandomGenerator(12345)
            local generator = MissionSiteGenerator:new(rng)
            
            local state = generator:getState()
            
            expect(state).to.exist()
            expect(state.active_site_count).to.equal(0)
        end)
    end)
    
    describe('AlienActivityManager', function()
        it('should initialize with reconnaissance phase', function()
            local manager = AlienActivityManager:new()
            
            expect(manager).to.exist()
            expect(manager.current_phase).to.equal(AlienActivityManager.Phase.RECONNAISSANCE)
            expect(manager.threat_level).to_not.equal(nil)
        end)
        
        it('should escalate threat level', function()
            local manager = AlienActivityManager:new()
            
            local initial_threat = manager.threat_level
            manager:escalateThreat(1.0)
            
            expect(manager.threat_level).to.be_greater_than(initial_threat)
        end)
        
        it('should change phase based on threat level', function()
            local manager = AlienActivityManager:new()
            
            manager.threat_level = 1.5
            manager:_updatePhase()
            expect(manager.current_phase).to.equal(AlienActivityManager.Phase.RECONNAISSANCE)
            
            manager.threat_level = 2.5
            manager:_updatePhase()
            expect(manager.current_phase).to.equal(AlienActivityManager.Phase.INFILTRATION)
            
            manager.threat_level = 4.5
            manager:_updatePhase()
            expect(manager.current_phase).to.equal(AlienActivityManager.Phase.ESCALATION)
            
            manager.threat_level = 6.5
            manager:_updatePhase()
            expect(manager.current_phase).to.equal(AlienActivityManager.Phase.INVASION)
            
            manager.threat_level = 8.5
            manager:_updatePhase()
            expect(manager.current_phase).to.equal(AlienActivityManager.Phase.DOMINATION)
        end)
        
        it('should track country infiltration', function()
            local manager = AlienActivityManager:new()
            
            manager:infiltrateCountry("country_1", 25)
            
            expect(manager:getCountryInfiltration("country_1")).to.equal(25)
            
            manager:infiltrateCountry("country_1", 30)
            
            expect(manager:getCountryInfiltration("country_1")).to.equal(55)
        end)
        
        it('should cap infiltration at 100', function()
            local manager = AlienActivityManager:new()
            
            manager:infiltrateCountry("country_1", 150)
            
            expect(manager:getCountryInfiltration("country_1")).to.equal(100)
        end)
        
        it('should calculate mission frequency by phase', function()
            local manager = AlienActivityManager:new()
            
            manager.current_phase = AlienActivityManager.Phase.RECONNAISSANCE
            local recon_count = manager:_calculateMissionFrequency()
            
            manager.current_phase = AlienActivityManager.Phase.INVASION
            local invasion_count = manager:_calculateMissionFrequency()
            
            expect(invasion_count).to.be_greater_than(recon_count)
        end)
        
        it('should track mission cooldowns', function()
            local manager = AlienActivityManager:new()
            
            manager:_setCooldown("scout", 3600)
            
            expect(manager:_isOnCooldown("scout")).to.equal(true)
            
            manager:_updateCooldowns(3700)
            
            expect(manager:_isOnCooldown("scout")).to.equal(false)
        end)
        
        it('should provide activity state', function()
            local manager = AlienActivityManager:new()
            
            local state = manager:getState()
            
            expect(state).to.exist()
            expect(state.phase).to.exist()
            expect(state.threat_level).to.exist()
            expect(state.stats).to.exist()
        end)
    end)
    
    describe('System Integration', function()
        it('should integrate UFO spawner with world', function()
            local rng = love.math.newRandomGenerator(12345)
            
            -- Generate world
            local world_gen = WorldGenerator:new(rng, {province_count = 20})
            local world = world_gen:generateQuickWorld("integration_test")
            
            -- Create spawner
            local spawner = UFOSpawner:new(rng)
            spawner:setWorld(world)
            
            -- Spawn UFO
            local ufo = spawner:spawnUFO()
            
            expect(ufo).to.exist()
            expect(ufo.world_id).to.equal("integration_test")
        end)
        
        it('should integrate mission site generator with world', function()
            local rng = love.math.newRandomGenerator(12345)
            
            -- Generate world
            local world_gen = WorldGenerator:new(rng, {province_count = 20})
            local world = world_gen:generateQuickWorld("integration_test")
            
            -- Create generator
            local site_gen = MissionSiteGenerator:new(rng)
            site_gen:setWorld(world)
            
            -- Create UFO and crash site
            local ufo = UFO:new({
                id = "test_ufo",
                type = "scout",
                size = "small",
                coordinates = {400, 300}
            })
            
            local site = site_gen:generateCrashSite(ufo)
            
            expect(site).to.exist()
            expect(site.province_id).to.exist()
        end)
        
        it('should integrate alien activity with world events', function()
            local rng = love.math.newRandomGenerator(12345)
            
            -- Create activity manager
            local manager = AlienActivityManager:new()
            manager:setRNG(rng)
            
            -- Simulate UFO destruction
            manager:onUFODestroyed({ufo_id = "test_ufo"})
            
            -- Threat should decrease slightly
            expect(manager.stats.failed_missions).to.equal(1)
        end)
    end)
    
end)

return lust
