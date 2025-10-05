--- test_world_generator.lua
-- Tests for WorldGenerator system

local lust = require 'test.framework.lust'
local describe, it, expect = lust.describe, lust.it, lust.expect

local WorldGenerator = require 'geoscape.WorldGenerator'
local World = require 'geoscape.World'
local Province = require 'geoscape.Province'
local Country = require 'geoscape.Country'
local Region = require 'geoscape.Region'

describe('WorldGenerator', function()
    
    describe('initialization', function()
        it('should create generator with default config', function()
            local rng = love.math.newRandomGenerator(12345)
            local generator = WorldGenerator:new(rng)
            
            expect(generator).to.exist()
            expect(generator.province_count).to.equal(100)
            expect(generator.country_count).to.equal(12)
            expect(generator.region_count).to.equal(6)
            expect(generator.water_percentage).to.equal(0.3)
        end)
        
        it('should create generator with custom config', function()
            local rng = love.math.newRandomGenerator(12345)
            local config = {
                province_count = 50,
                country_count = 8,
                region_count = 4,
                water_percentage = 0.2
            }
            local generator = WorldGenerator:new(rng, config)
            
            expect(generator.province_count).to.equal(50)
            expect(generator.country_count).to.equal(8)
            expect(generator.region_count).to.equal(4)
            expect(generator.water_percentage).to.equal(0.2)
        end)
    end)
    
    describe('province generation', function()
        it('should generate provinces with correct count', function()
            local rng = love.math.newRandomGenerator(12345)
            local config = {province_count = 20}
            local generator = WorldGenerator:new(rng, config)
            
            local provinces = generator:generateProvinces("test_world")
            
            expect(#provinces).to.equal(20)
        end)
        
        it('should generate provinces with coordinates', function()
            local rng = love.math.newRandomGenerator(12345)
            local generator = WorldGenerator:new(rng, {province_count = 10})
            
            local provinces = generator:generateProvinces("test_world")
            
            for _, province in ipairs(provinces) do
                expect(province.coordinates).to.exist()
                expect(#province.coordinates).to.equal(2)
                expect(province.coordinates[1]).to_not.equal(nil)
                expect(province.coordinates[2]).to_not.equal(nil)
            end
        end)
        
        it('should generate mix of water and land provinces', function()
            local rng = love.math.newRandomGenerator(12345)
            local generator = WorldGenerator:new(rng, {
                province_count = 50,
                water_percentage = 0.3
            })
            
            local provinces = generator:generateProvinces("test_world")
            
            local water_count = 0
            local land_count = 0
            for _, province in ipairs(provinces) do
                if province.is_water then
                    water_count = water_count + 1
                else
                    land_count = land_count + 1
                end
            end
            
            -- Should have some water and some land
            expect(water_count).to.be_greater_than(0)
            expect(land_count).to.be_greater_than(0)
            expect(water_count + land_count).to.equal(50)
        end)
    end)
    
    describe('country generation', function()
        it('should generate countries with correct count', function()
            local rng = love.math.newRandomGenerator(12345)
            local config = {country_count = 8}
            local generator = WorldGenerator:new(rng, config)
            
            local countries = generator:generateCountries("test_world")
            
            expect(#countries).to.equal(8)
        end)
        
        it('should generate countries with names and properties', function()
            local rng = love.math.newRandomGenerator(12345)
            local generator = WorldGenerator:new(rng, {country_count = 5})
            
            local countries = generator:generateCountries("test_world")
            
            for _, country in ipairs(countries) do
                expect(country.name).to.exist()
                expect(country.id).to.exist()
                expect(country.government_type).to.exist()
                expect(country.funding_level).to.be_greater_than(0)
            end
        end)
    end)
    
    describe('region generation', function()
        it('should generate regions with correct count', function()
            local rng = love.math.newRandomGenerator(12345)
            local config = {region_count = 4}
            local generator = WorldGenerator:new(rng, config)
            
            local regions = generator:generateRegions("test_world")
            
            expect(#regions).to.equal(4)
        end)
        
        it('should generate regions with names', function()
            local rng = love.math.newRandomGenerator(12345)
            local generator = WorldGenerator:new(rng, {region_count = 3})
            
            local regions = generator:generateRegions("test_world")
            
            for _, region in ipairs(regions) do
                expect(region.name).to.exist()
                expect(region.id).to.exist()
            end
        end)
    end)
    
    describe('province ownership', function()
        it('should assign all land provinces to countries', function()
            local rng = love.math.newRandomGenerator(12345)
            local generator = WorldGenerator:new(rng, {
                province_count = 30,
                country_count = 5
            })
            
            local provinces = generator:generateProvinces("test_world")
            local countries = generator:generateCountries("test_world")
            
            generator:assignProvinceOwnership(provinces, countries)
            
            -- Count assigned land provinces
            local assigned_land_count = 0
            for _, province in ipairs(provinces) do
                if not province.is_water and province.country_id then
                    assigned_land_count = assigned_land_count + 1
                end
            end
            
            -- Count total land provinces
            local total_land_count = 0
            for _, province in ipairs(provinces) do
                if not province.is_water then
                    total_land_count = total_land_count + 1
                end
            end
            
            expect(assigned_land_count).to.equal(total_land_count)
        end)
        
        it('should calculate country statistics', function()
            local rng = love.math.newRandomGenerator(12345)
            local generator = WorldGenerator:new(rng, {
                province_count = 20,
                country_count = 3
            })
            
            local provinces = generator:generateProvinces("test_world")
            local countries = generator:generateCountries("test_world")
            
            generator:assignProvinceOwnership(provinces, countries)
            
            for _, country in ipairs(countries) do
                expect(country.population).to_not.equal(nil)
                expect(country.economy_value).to_not.equal(nil)
                expect(#country.province_ids).to.be_greater_than(0)
            end
        end)
    end)
    
    describe('province regions', function()
        it('should assign all provinces to regions', function()
            local rng = love.math.newRandomGenerator(12345)
            local generator = WorldGenerator:new(rng, {
                province_count = 30,
                region_count = 5
            })
            
            local provinces = generator:generateProvinces("test_world")
            local regions = generator:generateRegions("test_world")
            
            generator:assignProvinceRegions(provinces, regions)
            
            -- All provinces should have region_id
            for _, province in ipairs(provinces) do
                expect(province.region_id).to.exist()
            end
        end)
    end)
    
    describe('adjacency calculation', function()
        it('should calculate adjacencies for provinces', function()
            local rng = love.math.newRandomGenerator(12345)
            local generator = WorldGenerator:new(rng, {
                province_count = 20,
                map_width = 800,
                map_height = 600
            })
            
            local provinces = generator:generateProvinces("test_world")
            
            generator:calculateAdjacencies(provinces)
            
            -- At least some provinces should have adjacencies
            local provinces_with_adjacencies = 0
            for _, province in ipairs(provinces) do
                if #province.adjacencies > 0 then
                    provinces_with_adjacencies = provinces_with_adjacencies + 1
                end
            end
            
            expect(provinces_with_adjacencies).to.be_greater_than(0)
        end)
    end)
    
    describe('complete world generation', function()
        it('should generate complete world with all components', function()
            local rng = love.math.newRandomGenerator(12345)
            local generator = WorldGenerator:new(rng, {
                province_count = 30,
                country_count = 5,
                region_count = 3
            })
            
            local world_data = {
                id = "test_world",
                name = "Test World",
                description = "Generated test world"
            }
            
            local world = generator:generateWorld(world_data, nil)
            
            expect(world).to.exist()
            expect(world.id).to.equal("test_world")
            expect(world.name).to.equal("Test World")
            
            -- Check that world has provinces, countries, and regions
            local province_count = 0
            for _ in pairs(world.provinces) do
                province_count = province_count + 1
            end
            expect(province_count).to.equal(30)
            
            local country_count = 0
            for _ in pairs(world.countries) do
                country_count = country_count + 1
            end
            expect(country_count).to.equal(5)
            
            local region_count = 0
            for _ in pairs(world.regions) do
                region_count = region_count + 1
            end
            expect(region_count).to.equal(3)
        end)
        
        it('should generate deterministic worlds with same seed', function()
            local world1 = WorldGenerator:new(love.math.newRandomGenerator(42), {
                province_count = 20,
                country_count = 4
            }):generateQuickWorld("deterministic_test_1")
            
            local world2 = WorldGenerator:new(love.math.newRandomGenerator(42), {
                province_count = 20,
                country_count = 4
            }):generateQuickWorld("deterministic_test_2")
            
            -- Count provinces
            local count1 = 0
            for _ in pairs(world1.provinces) do count1 = count1 + 1 end
            
            local count2 = 0
            for _ in pairs(world2.provinces) do count2 = count2 + 1 end
            
            expect(count1).to.equal(count2)
            expect(count1).to.equal(20)
        end)
    end)
    
    describe('quick world generation', function()
        it('should generate quick test world', function()
            local rng = love.math.newRandomGenerator(12345)
            local generator = WorldGenerator:new(rng)
            
            local world = generator:generateQuickWorld("quick_test")
            
            expect(world).to.exist()
            expect(world.id).to.equal("quick_test")
            expect(world.name).to.equal("Test World")
        end)
    end)
    
end)

return lust
