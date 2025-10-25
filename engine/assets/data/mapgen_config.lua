---Map Generation Configuration
---
---Configuration settings for battlescape map generation system. Controls procedural
---generation parameters, MapBlock assembly, biome weights, and generation methods.
---Used by MapGenerator and MapGenerationPipeline for consistent map creation.
---
---Configuration Sections:
---  - method: Generation approach ("procedural" or "mapblock")
---  - procedural: Cellular automata settings for random maps
---  - mapblock: Template-based generation with biome weighting
---
---Key Settings:
---  - Grid size randomization (4x4 to 7x7 blocks)
---  - Biome probability weights for varied terrain
---  - Smoothing passes for natural-looking maps
---  - Feature count ranges for procedural variety
---
---@module assets.data.mapgen_config
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local config = require("assets.data.mapgen_config")
---  if config.method == "mapblock" then
---      -- Use MapBlock generation
---  end
---
---@see battlescape.maps.map_generator For map generation implementation
---@see battlescape.maps.map_generation_pipeline For advanced pipeline

-- Map Generation Configuration
-- Controls how battlescape maps are generated

return {
    -- Generation method: "procedural" or "mapblock"
    method = "mapblock",
    
    -- Procedural generation settings
    procedural = {
        width = 60,
        height = 60,
        seed = nil,  -- nil for random, number for reproducible maps
        smoothingPasses = 3,
        featureCount = {min = 3, max = 5}
    },
    
    -- Mapblock generation settings
    mapblock = {
        gridSize = {min = 4, max = 7},  -- Random size between min and max
        biomeWeights = {
            urban = 0.3,
            forest = 0.25,
            industrial = 0.2,
            water = 0.1,
            rural = 0.1,
            mixed = 0.05
        }
    }
}


























