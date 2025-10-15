---MapScriptSelector - Weighted MapScript Selection
---
---Selects MapScript based on terrain and constraints using weighted random selection.
---MapScripts define procedural map generation rules (OpenXCOM-style commands). Ensures
---appropriate script selection for biome, terrain, and mission type.
---
---Features:
---  - Terrain-based script filtering
---  - Weighted random selection
---  - Constraint validation (size, difficulty)
---  - Default fallback scripts
---  - Script compatibility checking
---
---Selection Criteria:
---  - Terrain type (urban, forest, desert, etc.)
---  - Mission type (crash, landing, terror)
---  - Map size (small, medium, large)
---  - Difficulty level (1-10)
---
---MapScript Weights:
---  - Common scripts: Higher weight
---  - Special scripts: Lower weight
---  - Custom weighted per terrain
---
---Key Exports:
---  - MapScriptSelector.new(mapScripts): Creates selector
---  - selectScript(terrainId, constraints): Returns random script
---  - getCompatibleScripts(terrainId): Returns all valid scripts
---  - setCustomWeights(terrainId, weights): Overrides weights
---
---Dependencies:
---  - None (uses passed mapScripts module)
---
---@module battlescape.mapscripts.mapscript_selector
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local MapScriptSelector = require("battlescape.mapscripts.mapscript_selector")
---  local selector = MapScriptSelector.new(mapScripts)
---  local script = selector:selectScript("urban", {size = "large"})
---
---@see battlescape.maps.map_generation_pipeline For usage

-- MapScript Selector - Weighted Random Selection
-- Selects MapScript based on terrain and constraints

local MapScriptSelector = {}

---@class MapScriptSelector
---@field mapScripts table Reference to mapScripts module

---Create a new MapScript selector
---@param mapScripts table MapScripts module
---@return MapScriptSelector
function MapScriptSelector.new(mapScripts)
    local self = setmetatable({}, {__index = MapScriptSelector})
    
    self.mapScripts = mapScripts
    
    return self
end

---Select a MapScript based on terrain and optional constraints
---@param terrain Terrain Terrain definition
---@param options? table Optional constraints {difficulty, biome, maxWidth, maxHeight}
---@return string? mapScriptId Selected MapScript ID or nil if no match
function MapScriptSelector:selectMapScript(terrain, options)
    options = options or {}
    
    if not terrain then
        print("[MapScriptSelector] No terrain provided")
        return nil
    end
    
    -- Get MapScript weights from terrain
    local mapScriptWeights = terrain.mapScripts
    if not mapScriptWeights or #mapScriptWeights == 0 then
        print(string.format("[MapScriptSelector] No MapScript weights for terrain: %s", terrain.id))
        return nil
    end
    
    -- Filter MapScripts based on constraints
    local validMapScripts = {}
    for _, entry in ipairs(mapScriptWeights) do
        local mapScript = self.mapScripts.get(entry.id)
        if mapScript then
            if self:isValidMapScript(mapScript, options) then
                table.insert(validMapScripts, entry)
            end
        end
    end
    
    if #validMapScripts == 0 then
        print(string.format("[MapScriptSelector] No valid MapScripts for terrain %s with given constraints", terrain.id))
        return nil
    end
    
    -- Weighted random selection
    local selected = self:weightedRandom(validMapScripts)
    
    print(string.format("[MapScriptSelector] Selected MapScript: %s from terrain: %s", selected, terrain.id))
    return selected
end

---Check if MapScript matches constraints
---@param mapScript MapScript MapScript definition
---@param options table Constraint options
---@return boolean isValid True if MapScript is valid
function MapScriptSelector:isValidMapScript(mapScript, options)
    -- Check difficulty range
    if options.difficulty then
        if mapScript.requirements.minDifficulty and options.difficulty < mapScript.requirements.minDifficulty then
            return false
        end
        if mapScript.requirements.maxDifficulty and options.difficulty > mapScript.requirements.maxDifficulty then
            return false
        end
    end
    
    -- Check biome requirement
    if options.biome and mapScript.requirements.biomes and #mapScript.requirements.biomes > 0 then
        local hasBiome = false
        for _, biome in ipairs(mapScript.requirements.biomes) do
            if biome == options.biome then
                hasBiome = true
                break
            end
        end
        if not hasBiome then
            return false
        end
    end
    
    -- Check size constraints
    if options.maxWidth and mapScript.size.width > options.maxWidth then
        return false
    end
    if options.maxHeight and mapScript.size.height > options.maxHeight then
        return false
    end
    
    return true
end

---Weighted random selection from array of {id, weight}
---@param entries table Array of {id, weight}
---@return string? id Selected ID or nil
function MapScriptSelector:weightedRandom(entries)
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

---Get all valid MapScripts for a terrain
---@param terrain Terrain Terrain definition
---@param options? table Optional constraints
---@return table Array of {id, weight} entries
function MapScriptSelector:getValidMapScripts(terrain, options)
    options = options or {}
    
    if not terrain or not terrain.mapScripts then
        return {}
    end
    
    local validMapScripts = {}
    for _, entry in ipairs(terrain.mapScripts) do
        local mapScript = self.mapScripts.get(entry.id)
        if mapScript and self:isValidMapScript(mapScript, options) then
            table.insert(validMapScripts, entry)
        end
    end
    
    return validMapScripts
end

---Calculate MapScript distribution for a terrain
---@param terrain Terrain Terrain definition
---@param sampleSize? number Number of samples (default 1000)
---@return table Distribution table {mapScriptId = count}
function MapScriptSelector:getDistribution(terrain, sampleSize)
    sampleSize = sampleSize or 1000
    
    local distribution = {}
    
    for i = 1, sampleSize do
        local mapScriptId = self:selectMapScript(terrain)
        if mapScriptId then
            distribution[mapScriptId] = (distribution[mapScriptId] or 0) + 1
        end
    end
    
    return distribution
end

---Print MapScript distribution statistics
---@param terrain Terrain Terrain definition
---@param sampleSize? number Number of samples
function MapScriptSelector:printDistribution(terrain, sampleSize)
    local distribution = self:getDistribution(terrain, sampleSize)
    
    print(string.format("\n[MapScriptSelector] Distribution for terrain: %s", terrain.id))
    print(string.format("Sample size: %d", sampleSize or 1000))
    print("----------------------------------------")
    
    -- Sort by count
    local sorted = {}
    for mapScriptId, count in pairs(distribution) do
        table.insert(sorted, {id = mapScriptId, count = count})
    end
    table.sort(sorted, function(a, b) return a.count > b.count end)
    
    -- Print results
    for _, entry in ipairs(sorted) do
        local percentage = (entry.count / (sampleSize or 1000)) * 100
        print(string.format("  %s: %d (%.1f%%)", entry.id, entry.count, percentage))
    end
    print("----------------------------------------\n")
end

---Select MapScript by ID from terrain's available scripts
---@param terrain Terrain Terrain definition
---@param mapScriptId string MapScript ID to select
---@return boolean success True if MapScript is valid for terrain
function MapScriptSelector:isMapScriptValidForTerrain(terrain, mapScriptId)
    if not terrain or not terrain.mapScripts then
        return false
    end
    
    for _, entry in ipairs(terrain.mapScripts) do
        if entry.id == mapScriptId then
            return true
        end
    end
    
    return false
end

---Find best matching MapScript for specific requirements
---@param terrain Terrain Terrain definition
---@param requirements table {difficulty, biome, preferredSize}
---@return string? mapScriptId Best matching MapScript or nil
function MapScriptSelector:findBestMatch(terrain, requirements)
    requirements = requirements or {}
    
    if not terrain or not terrain.mapScripts then
        return nil
    end
    
    -- Score each MapScript
    local scored = {}
    for _, entry in ipairs(terrain.mapScripts) do
        local mapScript = self.mapScripts.get(entry.id)
        if mapScript then
            local score = 0
            
            -- Base score from weight
            score = entry.weight
            
            -- Bonus for matching difficulty exactly
            if requirements.difficulty then
                if mapScript.requirements.minDifficulty and mapScript.requirements.maxDifficulty then
                    local midDiff = (mapScript.requirements.minDifficulty + mapScript.requirements.maxDifficulty) / 2
                    local diffDistance = math.abs(midDiff - requirements.difficulty)
                    score = score * (1 + (1 / (diffDistance + 1)))
                end
            end
            
            -- Bonus for matching biome
            if requirements.biome and mapScript.requirements.biomes then
                for _, biome in ipairs(mapScript.requirements.biomes) do
                    if biome == requirements.biome then
                        score = score * 1.5
                        break
                    end
                end
            end
            
            -- Bonus for matching preferred size
            if requirements.preferredSize then
                local sizeDiff = math.abs(mapScript.size.width - requirements.preferredSize.width) +
                                math.abs(mapScript.size.height - requirements.preferredSize.height)
                score = score * (1 + (1 / (sizeDiff + 1)))
            end
            
            table.insert(scored, {id = entry.id, score = score})
        end
    end
    
    -- Sort by score
    table.sort(scored, function(a, b) return a.score > b.score end)
    
    -- Return best match
    if #scored > 0 then
        print(string.format("[MapScriptSelector] Best match: %s (score: %.2f)", scored[1].id, scored[1].score))
        return scored[1].id
    end
    
    return nil
end

return MapScriptSelector






















