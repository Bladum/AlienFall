--- Tests for SpatialIndex
local lust = require('test.framework.lust')
local describe, it, expect = lust.describe, lust.it, lust.expect

local SpatialIndex = require('battlescape.SpatialIndex')

describe('SpatialIndex', function()
    describe('initialization', function()
        it('should create with default cell size', function()
            local index = SpatialIndex:new()
            expect(index.cell_size).to.equal(8)
        end)
        
        it('should create with custom cell size', function()
            local index = SpatialIndex:new(16)
            expect(index.cell_size).to.equal(16)
        end)
    end)
    
    describe('insert and query', function()
        it('should insert and query single entity', function()
            local index = SpatialIndex:new(8)
            index:insert('unit1', 5, 5)
            
            local results = index:queryPoint(5, 5)
            expect(#results).to.equal(1)
            expect(results[1]).to.equal('unit1')
        end)
        
        it('should query entities in rectangle', function()
            local index = SpatialIndex:new(8)
            index:insert('unit1', 5, 5)
            index:insert('unit2', 10, 10)
            index:insert('unit3', 20, 20)
            
            local results = index:queryRect(0, 0, 15, 15)
            expect(#results).to.be.gte(2) -- Should find unit1 and unit2
        end)
        
        it('should not return duplicates in rect query', function()
            local index = SpatialIndex:new(4)
            -- Entity spanning multiple cells
            index:insert('unit1', 5, 5, 10, 10)
            
            local results = index:queryRect(0, 0, 20, 20)
            local count = 0
            for _, id in ipairs(results) do
                if id == 'unit1' then
                    count = count + 1
                end
            end
            
            expect(count).to.equal(1) -- Should only appear once
        end)
    end)
    
    describe('remove', function()
        it('should remove entity from index', function()
            local index = SpatialIndex:new(8)
            index:insert('unit1', 5, 5)
            index:remove('unit1')
            
            local results = index:queryPoint(5, 5)
            expect(#results).to.equal(0)
        end)
        
        it('should update statistics on removal', function()
            local index = SpatialIndex:new(8)
            index:insert('unit1', 5, 5)
            local stats_before = index:getStats()
            
            index:remove('unit1')
            local stats_after = index:getStats()
            
            expect(stats_after.total_entities).to.equal(stats_before.total_entities - 1)
        end)
    end)
    
    describe('update', function()
        it('should update entity position', function()
            local index = SpatialIndex:new(8)
            index:insert('unit1', 5, 5)
            index:update('unit1', 15, 15)
            
            local results_old = index:queryPoint(5, 5)
            local results_new = index:queryPoint(15, 15)
            
            expect(#results_old).to.equal(0)
            expect(#results_new).to.equal(1)
        end)
    end)
    
    describe('queryRadius', function()
        it('should query entities within radius', function()
            local index = SpatialIndex:new(8)
            index:insert('unit1', 10, 10)
            index:insert('unit2', 15, 15)
            index:insert('unit3', 50, 50)
            
            local results = index:queryRadius(10, 10, 10)
            
            -- Should find unit1 and unit2, not unit3
            expect(#results).to.be.gte(1)
        end)
    end)
    
    describe('findNearest', function()
        it('should find nearest entity', function()
            local index = SpatialIndex:new(8)
            index:insert('unit1', 10, 10)
            index:insert('unit2', 20, 20)
            index:insert('unit3', 5, 5)
            
            local positions = {
                unit1 = {x = 10, y = 10},
                unit2 = {x = 20, y = 20},
                unit3 = {x = 5, y = 5}
            }
            
            local nearest_id, dist = index:findNearest(8, 8, positions)
            
            expect(nearest_id).to.equal('unit3') -- Closest to (8,8)
            expect(dist).to.be.lte(5)
        end)
        
        it('should return nil when no entity in range', function()
            local index = SpatialIndex:new(8)
            index:insert('unit1', 100, 100)
            
            local positions = {unit1 = {x = 100, y = 100}}
            local nearest_id = index:findNearest(0, 0, positions, 10)
            
            expect(nearest_id).to.equal(nil)
        end)
    end)
    
    describe('clear', function()
        it('should clear all entities', function()
            local index = SpatialIndex:new(8)
            index:insert('unit1', 5, 5)
            index:insert('unit2', 10, 10)
            
            index:clear()
            
            local stats = index:getStats()
            expect(stats.total_entities).to.equal(0)
            expect(stats.total_cells).to.equal(0)
        end)
    end)
    
    describe('statistics', function()
        it('should track query statistics', function()
            local index = SpatialIndex:new(8)
            index:insert('unit1', 5, 5)
            
            index:queryPoint(5, 5)
            index:queryPoint(10, 10)
            
            local stats = index:getStats()
            expect(stats.queries_performed).to.equal(2)
        end)
        
        it('should reset statistics', function()
            local index = SpatialIndex:new(8)
            index:insert('unit1', 5, 5)
            index:queryPoint(5, 5)
            
            index:resetStats()
            
            local stats = index:getStats()
            expect(stats.queries_performed).to.equal(0)
        end)
    end)
    
    describe('performance', function()
        it('should handle many entities efficiently', function()
            local index = SpatialIndex:new(8)
            
            -- Insert 1000 entities
            for i = 1, 1000 do
                local x = math.random(0, 100)
                local y = math.random(0, 100)
                index:insert('unit' .. i, x, y)
            end
            
            local stats = index:getStats()
            expect(stats.total_entities).to.equal(1000)
            
            -- Query should be fast
            local start_time = os.clock()
            for i = 1, 100 do
                index:queryRect(0, 0, 50, 50)
            end
            local elapsed = os.clock() - start_time
            
            expect(elapsed).to.be.lt(0.1) -- Should complete in <100ms
        end)
    end)
end)

return lust
