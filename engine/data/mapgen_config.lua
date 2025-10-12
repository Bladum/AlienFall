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
