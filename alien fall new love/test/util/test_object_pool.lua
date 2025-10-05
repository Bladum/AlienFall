--- Test suite for ObjectPool
--
-- Tests object pooling functionality, lifecycle, and statistics.
--
-- @module test.util.test_object_pool

local lust = require "lust"
local describe, it, expect, before = lust.describe, lust.it, lust.expect, lust.before

local ObjectPool = require("src.utils.object_pool")

describe("ObjectPool", function()
    
    local pool
    local create_count
    
    -- Simple test object
    local function createTestObject()
        create_count = create_count + 1
        return {
            id = create_count,
            value = 0,
            reset = function(self)
                self.value = 0
            end
        }
    end
    
    before(function()
        create_count = 0
        pool = ObjectPool:new(createTestObject, nil, 5, 0)
    end)
    
    describe("Initialization", function()
        
        it("creates initial pool of objects", function()
            expect(create_count).to.equal(5)
        end)
        
        it("stores statistics correctly", function()
            local stats = pool:getStats()
            expect(stats.created).to.equal(5)
            expect(stats.current_usage).to.equal(0)
            expect(stats.available).to.equal(5)
        end)
        
    end)
    
    describe("Object Acquisition", function()
        
        it("acquires object from pool", function()
            local obj = pool:acquire()
            
            expect(obj).to_not.be.nil()
            expect(obj.id).to_not.be.nil()
        end)
        
        it("reuses existing object", function()
            local obj1 = pool:acquire()
            local initial_create_count = create_count
            
            pool:release(obj1)
            
            local obj2 = pool:acquire()
            
            -- No new object created (reused)
            expect(create_count).to.equal(initial_create_count)
            expect(obj2.id).to.equal(obj1.id)
        end)
        
        it("creates new object when pool is empty", function()
            -- Acquire all 5 initial objects
            for i = 1, 5 do
                pool:acquire()
            end
            
            local initial_create_count = create_count
            
            -- Acquire 6th object (forces creation)
            local obj = pool:acquire()
            
            expect(create_count).to.equal(initial_create_count + 1)
        end)
        
        it("tracks current usage", function()
            pool:acquire()
            pool:acquire()
            
            local stats = pool:getStats()
            expect(stats.current_usage).to.equal(2)
        end)
        
        it("tracks peak usage", function()
            pool:acquire()
            pool:acquire()
            pool:acquire()
            
            local stats1 = pool:getStats()
            expect(stats1.peak_usage).to.equal(3)
            
            -- Release one and acquire again
            local obj = pool:acquire()
            pool:release(obj)
            
            local stats2 = pool:getStats()
            expect(stats2.peak_usage).to.equal(4)  -- Peak increased to 4
        end)
        
    end)
    
    describe("Object Release", function()
        
        it("releases object back to pool", function()
            local obj = pool:acquire()
            obj.value = 42
            
            local result = pool:release(obj)
            
            expect(result).to.be.truthy()
            
            local stats = pool:getStats()
            expect(stats.current_usage).to.equal(0)
        end)
        
        it("calls reset function on release", function()
            local obj = pool:acquire()
            obj.value = 42
            
            pool:release(obj)
            
            -- Acquire same object (should be reset)
            local obj2 = pool:acquire()
            expect(obj2.value).to.equal(0)
        end)
        
        it("returns false for invalid release", function()
            local fake_obj = {id = 999, value = 0}
            local result = pool:release(fake_obj)
            
            expect(result).to.be.falsy()
        end)
        
    end)
    
    describe("Pool Size Limits", function()
        
        it("respects max pool size", function()
            local limited_pool = ObjectPool:new(createTestObject, nil, 2, 3)
            
            -- Acquire and release 5 objects
            local objs = {}
            for i = 1, 5 do
                table.insert(objs, limited_pool:acquire())
            end
            
            for _, obj in ipairs(objs) do
                limited_pool:release(obj)
            end
            
            local stats = limited_pool:getStats()
            -- Pool should have max 3 available
            expect(stats.available).to.be.at_most(3)
        end)
        
        it("allows unlimited growth when max_size is 0", function()
            local unlimited_pool = ObjectPool:new(createTestObject, nil, 2, 0)
            
            -- Acquire and release many objects
            local objs = {}
            for i = 1, 20 do
                table.insert(objs, unlimited_pool:acquire())
            end
            
            for _, obj in ipairs(objs) do
                unlimited_pool:release(obj)
            end
            
            local stats = unlimited_pool:getStats()
            -- Pool should have all 20 available
            expect(stats.available).to.equal(20)
        end)
        
    end)
    
    describe("Bulk Operations", function()
        
        it("releases all objects with releaseAll()", function()
            pool:acquire()
            pool:acquire()
            pool:acquire()
            
            local stats1 = pool:getStats()
            expect(stats1.current_usage).to.equal(3)
            
            pool:releaseAll()
            
            local stats2 = pool:getStats()
            expect(stats2.current_usage).to.equal(0)
        end)
        
        it("clears all objects with clear()", function()
            pool:acquire()
            pool:acquire()
            
            pool:clear()
            
            local stats = pool:getStats()
            expect(stats.current_usage).to.equal(0)
            expect(stats.available).to.equal(0)
        end)
        
    end)
    
    describe("Statistics", function()
        
        it("tracks reuse count", function()
            local obj = pool:acquire()
            pool:release(obj)
            
            pool:acquire()  -- Reuse
            
            local stats = pool:getStats()
            expect(stats.reused).to.equal(1)
        end)
        
        it("calculates reuse rate", function()
            -- Acquire 5 initial objects (created)
            for i = 1, 5 do
                local obj = pool:acquire()
                pool:release(obj)
            end
            
            -- Acquire again (all reused)
            for i = 1, 5 do
                pool:acquire()
            end
            
            local stats = pool:getStats()
            -- Total acquires = 5 created + 5 reused = 10
            -- Reuse rate = 5/10 = 50%
            expect(stats.reuse_rate).to.be.near(50, 0.1)
        end)
        
    end)
    
    describe("Pre-warming", function()
        
        it("pre-warms pool with additional objects", function()
            local small_pool = ObjectPool:new(createTestObject, nil, 2, 0)
            
            local stats1 = small_pool:getStats()
            expect(stats1.available).to.equal(2)
            
            small_pool:prewarm(10)
            
            local stats2 = small_pool:getStats()
            expect(stats2.available).to.equal(12)  -- 2 + 10
        end)
        
    end)
    
end)

return describe
