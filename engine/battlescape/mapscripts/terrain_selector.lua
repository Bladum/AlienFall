---TerrainSelector - Weighted Random Terrain Selection
---
---Selects terrain types based on biome-specific weights for procedural map generation.
---Uses weighted random selection to ensure biome-appropriate terrain distribution
---(e.g., forests have more trees, urban has more roads).
---
---Features:
---  - Biome-based terrain weights
---  - Weighted random selection
---  - Terrain compatibility checking
---  - Default fallback terrain
---  - Configurable distribution
---
---Biome Examples:
---  - Urban: 60% road, 30% concrete, 10% grass
---  - Forest: 70% grass, 20% trees, 10% rough
---  - Desert: 80% sand, 15% rock, 5% rough
---
---Selection Algorithm:
---  1. Get biome terrain weights
---  2. Calculate cumulative weights
---  3. Random roll 0-100
---  4. Select terrain based on range
---  5. Return terrain ID
---
---Key Exports:
---  - TerrainSelector.new(biomes, terrains): Creates selector
---  - selectTerrain(biomeId): Returns random terrain for biome
---  - getWeights(biomeId): Returns terrain weight table
---  - setCustomWeights(biomeId, weights): Overrides default weights
---
---Dependencies:
---  - None (uses passed biomes/terrains modules)
---
---@module battlescape.mapscripts.terrain_selector
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local TerrainSelector = require("battlescape.mapscripts.terrain_selector")
---  local selector = TerrainSelector.new(biomes, terrains)
---  local terrainId = selector:selectTerrain("urban")
---  -- Returns "road" 60% of time, "concrete" 30%, "grass" 10%
---
---@see battlescape.maps.map_generation_pipeline For usage

-- Terrain Selector - Weighted Random Selection
-- Selects terrain based on biome weights

local TerrainSelector = {}

---@class TerrainSelector
---@field biomes table Reference to biomes module
---@field terrains table Reference to terrains module

---Create a new terrain selector
---@param biomes table Biomes module
---@param terrains table Terrains module
---@return TerrainSelector
function TerrainSelector.new(biomes, terrains)
    local self = setmetatable({}, {__index = TerrainSelector})
    
    self.biomes = biomes
    self.terrains = terrains
    
    return self
end

---Select a terrain based on biome and optional constraints
---@param biomeId string Biome ID
---@param options? table Optional constraints {difficulty, tags, excludeTags}
---@return string? terrainId Selected terrain ID or nil if no match
function TerrainSelector:selectTerrain(biomeId, options)
    options = options or {}
    
    local biome = self.biomes.get(biomeId)
    if not biome then
        print(string.format("[TerrainSelector] Unknown biome: %s", biomeId))
        return nil
    end
    
    -- Get terrain weights from biome
    local terrainWeights = biome.terrainWeights
    if not terrainWeights or #terrainWeights == 0 then
        print(string.format("[TerrainSelector] No terrain weights for biome: %s", biomeId))
        return nil
    end
    
    -- Filter terrains based on constraints
    local validTerrains = {}
    for _, entry in ipairs(terrainWeights) do
        local terrain = self.terrains.get(entry.id)
        if terrain then
            if self:isValidTerrain(terrain, options) then
                table.insert(validTerrains, entry)
            end
        end
    end
    
    if #validTerrains == 0 then
        print(string.format("[TerrainSelector] No valid terrains for biome %s with given constraints", biomeId))
        return nil
    end
    
    -- Weighted random selection
    local selected = self:weightedRandom(validTerrains)
    
    print(string.format("[TerrainSelector] Selected terrain: %s from biome: %s", selected, biomeId))
    return selected
end

---Check if terrain matches constraints
---@param terrain Terrain Terrain definition
---@param options table Constraint options
---@return boolean isValid True if terrain is valid
function TerrainSelector:isValidTerrain(terrain, options)
    -- Check difficulty range
    if options.difficulty then
        local minDiff = terrain.difficulty.min
        local maxDiff = terrain.difficulty.max
        if options.difficulty < minDiff or options.difficulty > maxDiff then
            return false
        end
    end
    
    -- Check required tags
    if options.tags and #options.tags > 0 then
        local hasAllTags = true
        for _, tag in ipairs(options.tags) do
            local hasTag = false
            for _, terrainTag in ipairs(terrain.mapBlockTags) do
                if terrainTag == tag then
                    hasTag = true
                    break
                end
            end
            if not hasTag then
                hasAllTags = false
                break
            end
        end
        if not hasAllTags then
            return false
        end
    end
    
    -- Check excluded tags
    if options.excludeTags and #options.excludeTags > 0 then
        for _, excludeTag in ipairs(options.excludeTags) do
            for _, terrainTag in ipairs(terrain.mapBlockTags) do
                if terrainTag == excludeTag then
                    return false
                end
            end
        end
    end
    
    return true
end

---Weighted random selection from array of {id, weight}
---@param entries table Array of {id, weight}
---@return string? id Selected ID or nil
function TerrainSelector:weightedRandom(entries)
    if not entries or #entries == 0 then
        return nil
    end
    
    -- Calculate total weight
    local totalWeight = 0
    for _, entry in ipairs(entries) do
        totalWeight = totalWeight + entry.weight
    end
    
    if totalWeight <= 0 then
        return nil
    end
    
    -- Random selection
    local roll = math.random() * totalWeight
    local cumulative = 0
    
    for _, entry in ipairs(entries) do
        cumulative = cumulative + entry.weight
        if roll <= cumulative then
            return entry.id
        end
    end
    
    -- Fallback to last entry (shouldn't reach here)
    return entries[#entries].id
end

---Get all valid terrains for a biome
---@param biomeId string Biome ID
---@param options? table Optional constraints
---@return table Array of {id, weight} entries
function TerrainSelector:getValidTerrains(biomeId, options)
    options = options or {}
    
    local biome = self.biomes.get(biomeId)
    if not biome then
        return {}
    end
    
    local validTerrains = {}
    for _, entry in ipairs(biome.terrainWeights) do
        local terrain = self.terrains.get(entry.id)
        if terrain and self:isValidTerrain(terrain, options) then
            table.insert(validTerrains, entry)
        end
    end
    
    return validTerrains
end

---Calculate terrain distribution for a biome
---@param biomeId string Biome ID
---@param sampleSize? number Number of samples (default 1000)
---@return table Distribution table {terrainId = count}
function TerrainSelector:getDistribution(biomeId, sampleSize)
    sampleSize = sampleSize or 1000
    
    local distribution = {}
    
    for i = 1, sampleSize do
        local terrainId = self:selectTerrain(biomeId)
        if terrainId then
            distribution[terrainId] = (distribution[terrainId] or 0) + 1
        end
    end
    
    return distribution
end

---Print terrain distribution statistics
---@param biomeId string Biome ID
---@param sampleSize? number Number of samples
function TerrainSelector:printDistribution(biomeId, sampleSize)
    local distribution = self:getDistribution(biomeId, sampleSize)
    
    print(string.format("\n[TerrainSelector] Distribution for biome: %s", biomeId))
    print(string.format("Sample size: %d", sampleSize or 1000))
    print("----------------------------------------")
    
    -- Sort by count
    local sorted = {}
    for terrainId, count in pairs(distribution) do
        table.insert(sorted, {id = terrainId, count = count})
    end
    table.sort(sorted, function(a, b) return a.count > b.count end)
    
    -- Print results
    for _, entry in ipairs(sorted) do
        local percentage = (entry.count / (sampleSize or 1000)) * 100
        print(string.format("  %s: %d (%.1f%%)", entry.id, entry.count, percentage))
    end
    print("----------------------------------------\n")
end

return TerrainSelector


























