---MapScripts - Structured Map Layout System (Legacy)
---
---Defines how MapBlocks are arranged to create complete maps. Legacy system using
---Lua-based definitions. MapScripts specify block placements, spawn zones, and
---requirements. Being replaced by MapScriptsV2 (TOML-based) system.
---
---Features:
---  - Map layout definitions
---  - MapBlock placement rules
---  - Team spawn zone definitions
---  - Biome and difficulty requirements
---  - Registry for all MapScripts
---
---MapScript Properties:
---  - id: Unique identifier
---  - name: Display name
---  - description: Lore text
---  - size: {width, height} in MapBlocks
---  - blocks: Array of {x, y, tags, required}
---  - requirements: {minDifficulty, maxDifficulty, biomes}
---  - spawnZones: {team, x, y, radius}
---
---Block Placement:
---  - x, y: Grid position (in MapBlocks, not tiles)
---  - tags: Array of required tags
---  - required: Boolean (must place or fail)
---
---Spawn Zones:
---  - team: Team ID (1=player, 2+=AI)
---  - x, y: Center position (in tiles)
---  - radius: Spawn radius (in tiles)
---
---Key Exports:
---  - MapScripts.register(script): Adds MapScript to registry
---  - MapScripts.get(id): Returns MapScript by ID
---  - MapScripts.getAll(): Returns all MapScripts
---  - MapScripts.getForBiome(biome): Returns biome-compatible scripts
---  - MapScripts.getForDifficulty(difficulty): Returns difficulty-appropriate scripts
---
---Dependencies:
---  - None (pure data registry)
---
---@module battlescape.data.mapscripts
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local MapScripts = require("battlescape.data.mapscripts")
---  MapScripts.register({
---      id = "urban_crash",
---      name = "Urban Crash Site",
---      size = {width = 4, height = 4},
---      blocks = {{x=0, y=0, tags={"urban"}, required=true}}
---  })
---
---@see battlescape.data.mapscripts_v2 For new TOML system
---@see battlescape.mapscripts.mapscript_executor For execution

-- MapScript System - Structured Map Layouts
-- Defines how MapBlocks are arranged to create complete maps

local MapScripts = {}

---@class MapScript
---@field id string Unique MapScript identifier
---@field name string Display name
---@field description string MapScript description
---@field size table Map dimensions {width, height} in MapBlocks
---@field blocks table Array of block placements {x, y, tags, required}
---@field requirements table Generation requirements {minDifficulty, maxDifficulty, biomes}
---@field spawnZones table Team spawn zones {team, x, y, radius}

-- MapScript registry
MapScripts.registry = {}

---Register a MapScript
---@param mapScript MapScript MapScript definition
function MapScripts.register(mapScript)
    if not mapScript.id then
        error("MapScript must have an id")
    end
    
    MapScripts.registry[mapScript.id] = mapScript
    print(string.format("[MapScripts] Registered MapScript: %s (%s)", mapScript.id, mapScript.name))
end

---Get MapScript by ID
---@param mapScriptId string MapScript ID
---@return MapScript? MapScript definition or nil
function MapScripts.get(mapScriptId)
    return MapScripts.registry[mapScriptId]
end

---Get all MapScript IDs
---@return table Array of MapScript IDs
function MapScripts.getAllIds()
    local ids = {}
    for id, _ in pairs(MapScripts.registry) do
        table.insert(ids, id)
    end
    return ids
end

---Get MapScripts matching criteria
---@param criteria table {biome, difficulty, size}
---@return table Array of matching MapScript IDs
function MapScripts.findMatching(criteria)
    criteria = criteria or {}
    
    local matching = {}
    for id, script in pairs(MapScripts.registry) do
        local isMatch = true
        
        -- Check biome
        if criteria.biome and script.requirements.biomes then
            local hasBiome = false
            for _, biome in ipairs(script.requirements.biomes) do
                if biome == criteria.biome then
                    hasBiome = true
                    break
                end
            end
            if not hasBiome then
                isMatch = false
            end
        end
        
        -- Check difficulty
        if criteria.difficulty then
            if script.requirements.minDifficulty and criteria.difficulty < script.requirements.minDifficulty then
                isMatch = false
            end
            if script.requirements.maxDifficulty and criteria.difficulty > script.requirements.maxDifficulty then
                isMatch = false
            end
        end
        
        -- Check size
        if criteria.maxWidth and script.size.width > criteria.maxWidth then
            isMatch = false
        end
        if criteria.maxHeight and script.size.height > criteria.maxHeight then
            isMatch = false
        end
        
        if isMatch then
            table.insert(matching, id)
        end
    end
    
    return matching
end

-- Define standard MapScripts

-- Forest MapScripts
MapScripts.register({
    id = "forest_clearing",
    name = "Forest Clearing",
    description = "Open clearing surrounded by dense forest",
    size = {width = 3, height = 3},
    blocks = {
        {x = 0, y = 0, tags = {"forest", "dense"}},
        {x = 1, y = 0, tags = {"forest", "dense"}},
        {x = 2, y = 0, tags = {"forest", "dense"}},
        {x = 0, y = 1, tags = {"forest", "dense"}},
        {x = 1, y = 1, tags = {"grass", "clearing"}, required = true},
        {x = 2, y = 1, tags = {"forest", "dense"}},
        {x = 0, y = 2, tags = {"forest", "dense"}},
        {x = 1, y = 2, tags = {"forest", "dense"}},
        {x = 2, y = 2, tags = {"forest", "dense"}}
    },
    requirements = {
        minDifficulty = 1,
        maxDifficulty = 5,
        biomes = {"forest"}
    },
    spawnZones = {
        {team = "player", x = 1, y = 1, radius = 1},
        {team = "enemy", x = 1, y = 0, radius = 1}
    }
})

MapScripts.register({
    id = "forest_random",
    name = "Forest Random",
    description = "Randomly placed forest blocks",
    size = {width = 4, height = 4},
    blocks = {
        -- Random forest blocks
    },
    requirements = {
        minDifficulty = 1,
        maxDifficulty = 6,
        biomes = {"forest"}
    },
    spawnZones = {
        {team = "player", x = 0, y = 3, radius = 1},
        {team = "enemy", x = 3, y = 0, radius = 1}
    }
})

MapScripts.register({
    id = "forest_path",
    name = "Forest Path",
    description = "Path cutting through forest",
    size = {width = 3, height = 4},
    blocks = {
        {x = 0, y = 0, tags = {"forest", "dense"}},
        {x = 1, y = 0, tags = {"path", "dirt"}},
        {x = 2, y = 0, tags = {"forest", "dense"}},
        {x = 0, y = 1, tags = {"forest", "dense"}},
        {x = 1, y = 1, tags = {"path", "dirt"}, required = true},
        {x = 2, y = 1, tags = {"forest", "dense"}},
        {x = 0, y = 2, tags = {"forest", "dense"}},
        {x = 1, y = 2, tags = {"path", "dirt"}, required = true},
        {x = 2, y = 2, tags = {"forest", "dense"}},
        {x = 0, y = 3, tags = {"forest", "dense"}},
        {x = 1, y = 3, tags = {"path", "dirt"}},
        {x = 2, y = 3, tags = {"forest", "dense"}}
    },
    requirements = {
        minDifficulty = 1,
        maxDifficulty = 4,
        biomes = {"forest"}
    },
    spawnZones = {
        {team = "player", x = 1, y = 3, radius = 1},
        {team = "enemy", x = 1, y = 0, radius = 1}
    }
})

MapScripts.register({
    id = "forest_river",
    name = "Forest River",
    description = "River running through forest",
    size = {width = 4, height = 3},
    blocks = {
        {x = 0, y = 0, tags = {"forest", "dense"}},
        {x = 1, y = 0, tags = {"water", "river"}},
        {x = 2, y = 0, tags = {"water", "river"}},
        {x = 3, y = 0, tags = {"forest", "dense"}},
        {x = 0, y = 1, tags = {"forest", "dense"}},
        {x = 1, y = 1, tags = {"water", "river"}, required = true},
        {x = 2, y = 1, tags = {"water", "river"}, required = true},
        {x = 3, y = 1, tags = {"forest", "dense"}},
        {x = 0, y = 2, tags = {"forest", "dense"}},
        {x = 1, y = 2, tags = {"water", "river"}},
        {x = 2, y = 2, tags = {"water", "river"}},
        {x = 3, y = 2, tags = {"forest", "dense"}}
    },
    requirements = {
        minDifficulty = 2,
        maxDifficulty = 5,
        biomes = {"forest"}
    },
    spawnZones = {
        {team = "player", x = 0, y = 1, radius = 1},
        {team = "enemy", x = 3, y = 1, radius = 1}
    }
})

-- Urban MapScripts
MapScripts.register({
    id = "urban_crossroads",
    name = "Urban Crossroads",
    description = "City intersection with roads and buildings",
    size = {width = 3, height = 3},
    blocks = {
        {x = 0, y = 0, tags = {"building", "corner"}},
        {x = 1, y = 0, tags = {"road", "horizontal"}},
        {x = 2, y = 0, tags = {"building", "corner"}},
        {x = 0, y = 1, tags = {"road", "vertical"}},
        {x = 1, y = 1, tags = {"road", "intersection"}, required = true},
        {x = 2, y = 1, tags = {"road", "vertical"}},
        {x = 0, y = 2, tags = {"building", "corner"}},
        {x = 1, y = 2, tags = {"road", "horizontal"}},
        {x = 2, y = 2, tags = {"building", "corner"}}
    },
    requirements = {
        minDifficulty = 2,
        maxDifficulty = 5,
        biomes = {"urban"}
    },
    spawnZones = {
        {team = "player", x = 1, y = 2, radius = 1},
        {team = "enemy", x = 1, y = 0, radius = 1}
    }
})

MapScripts.register({
    id = "urban_grid",
    name = "Urban Grid",
    description = "Regular grid of city blocks",
    size = {width = 4, height = 4},
    blocks = {
        -- Urban grid pattern
    },
    requirements = {
        minDifficulty = 2,
        maxDifficulty = 6,
        biomes = {"urban"}
    },
    spawnZones = {
        {team = "player", x = 0, y = 3, radius = 1},
        {team = "enemy", x = 3, y = 0, radius = 1}
    }
})

MapScripts.register({
    id = "urban_plaza",
    name = "Urban Plaza",
    description = "Open plaza with surrounding buildings",
    size = {width = 3, height = 3},
    blocks = {
        {x = 0, y = 0, tags = {"building"}},
        {x = 1, y = 0, tags = {"building"}},
        {x = 2, y = 0, tags = {"building"}},
        {x = 0, y = 1, tags = {"building"}},
        {x = 1, y = 1, tags = {"plaza", "open"}, required = true},
        {x = 2, y = 1, tags = {"building"}},
        {x = 0, y = 2, tags = {"building"}},
        {x = 1, y = 2, tags = {"building"}},
        {x = 2, y = 2, tags = {"building"}}
    },
    requirements = {
        minDifficulty = 2,
        maxDifficulty = 5,
        biomes = {"urban"}
    },
    spawnZones = {
        {team = "player", x = 1, y = 1, radius = 1},
        {team = "enemy", x = 1, y = 0, radius = 1}
    }
})

MapScripts.register({
    id = "urban_random",
    name = "Urban Random",
    description = "Random urban layout",
    size = {width = 4, height = 4},
    blocks = {},
    requirements = {
        minDifficulty = 2,
        maxDifficulty = 6,
        biomes = {"urban"}
    },
    spawnZones = {
        {team = "player", x = 0, y = 3, radius = 1},
        {team = "enemy", x = 3, y = 0, radius = 1}
    }
})

-- Industrial MapScripts
MapScripts.register({
    id = "industrial_complex",
    name = "Industrial Complex",
    description = "Large factory with multiple buildings",
    size = {width = 4, height = 4},
    blocks = {
        {x = 0, y = 0, tags = {"factory", "large"}},
        {x = 1, y = 0, tags = {"factory", "large"}},
        {x = 2, y = 0, tags = {"warehouse"}},
        {x = 3, y = 0, tags = {"yard"}},
        {x = 0, y = 1, tags = {"factory", "large"}},
        {x = 1, y = 1, tags = {"factory", "large"}},
        {x = 2, y = 1, tags = {"warehouse"}},
        {x = 3, y = 1, tags = {"yard"}},
        {x = 0, y = 2, tags = {"warehouse"}},
        {x = 1, y = 2, tags = {"warehouse"}},
        {x = 2, y = 2, tags = {"yard"}},
        {x = 3, y = 2, tags = {"fence"}},
        {x = 0, y = 3, tags = {"yard"}},
        {x = 1, y = 3, tags = {"yard"}},
        {x = 2, y = 3, tags = {"fence"}},
        {x = 3, y = 3, tags = {"fence"}}
    },
    requirements = {
        minDifficulty = 3,
        maxDifficulty = 6,
        biomes = {"industrial"}
    },
    spawnZones = {
        {team = "player", x = 1, y = 3, radius = 1},
        {team = "enemy", x = 1, y = 0, radius = 1}
    }
})

MapScripts.register({
    id = "warehouse_rows",
    name = "Warehouse Rows",
    description = "Rows of warehouse buildings",
    size = {width = 4, height = 3},
    blocks = {
        {x = 0, y = 0, tags = {"warehouse"}},
        {x = 1, y = 0, tags = {"alley"}},
        {x = 2, y = 0, tags = {"warehouse"}},
        {x = 3, y = 0, tags = {"alley"}},
        {x = 0, y = 1, tags = {"warehouse"}},
        {x = 1, y = 1, tags = {"alley"}},
        {x = 2, y = 1, tags = {"warehouse"}},
        {x = 3, y = 1, tags = {"alley"}},
        {x = 0, y = 2, tags = {"warehouse"}},
        {x = 1, y = 2, tags = {"alley"}},
        {x = 2, y = 2, tags = {"warehouse"}},
        {x = 3, y = 2, tags = {"alley"}}
    },
    requirements = {
        minDifficulty = 2,
        maxDifficulty = 5,
        biomes = {"industrial"}
    },
    spawnZones = {
        {team = "player", x = 1, y = 2, radius = 1},
        {team = "enemy", x = 1, y = 0, radius = 1}
    }
})

MapScripts.register({
    id = "industrial_random",
    name = "Industrial Random",
    description = "Random industrial layout",
    size = {width = 4, height = 4},
    blocks = {},
    requirements = {
        minDifficulty = 2,
        maxDifficulty = 6,
        biomes = {"industrial"}
    },
    spawnZones = {
        {team = "player", x = 0, y = 3, radius = 1},
        {team = "enemy", x = 3, y = 0, radius = 1}
    }
})

-- Plains MapScripts
MapScripts.register({
    id = "plains_random",
    name = "Plains Random",
    description = "Open grassland with random features",
    size = {width = 4, height = 4},
    blocks = {},
    requirements = {
        minDifficulty = 1,
        maxDifficulty = 3,
        biomes = {"plains"}
    },
    spawnZones = {
        {team = "player", x = 0, y = 3, radius = 1},
        {team = "enemy", x = 3, y = 0, radius = 1}
    }
})

MapScripts.register({
    id = "plains_features",
    name = "Plains with Features",
    description = "Plains with scattered trees and rocks",
    size = {width = 4, height = 4},
    blocks = {},
    requirements = {
        minDifficulty = 1,
        maxDifficulty = 4,
        biomes = {"plains"}
    },
    spawnZones = {
        {team = "player", x = 0, y = 3, radius = 1},
        {team = "enemy", x = 3, y = 0, radius = 1}
    }
})

MapScripts.register({
    id = "farmland_grid",
    name = "Farmland Grid",
    description = "Agricultural fields in grid pattern",
    size = {width = 4, height = 4},
    blocks = {
        {x = 0, y = 0, tags = {"field", "crops"}},
        {x = 1, y = 0, tags = {"fence"}},
        {x = 2, y = 0, tags = {"field", "crops"}},
        {x = 3, y = 0, tags = {"fence"}},
        {x = 0, y = 1, tags = {"fence"}},
        {x = 1, y = 1, tags = {"barn"}},
        {x = 2, y = 1, tags = {"fence"}},
        {x = 3, y = 1, tags = {"field", "crops"}},
        {x = 0, y = 2, tags = {"field", "crops"}},
        {x = 1, y = 2, tags = {"fence"}},
        {x = 2, y = 2, tags = {"field", "crops"}},
        {x = 3, y = 2, tags = {"fence"}},
        {x = 0, y = 3, tags = {"fence"}},
        {x = 1, y = 3, tags = {"field", "crops"}},
        {x = 2, y = 3, tags = {"fence"}},
        {x = 3, y = 3, tags = {"field", "crops"}}
    },
    requirements = {
        minDifficulty = 1,
        maxDifficulty = 4,
        biomes = {"plains", "rural"}
    },
    spawnZones = {
        {team = "player", x = 1, y = 3, radius = 1},
        {team = "enemy", x = 1, y = 0, radius = 1}
    }
})

MapScripts.register({
    id = "farmland_random",
    name = "Farmland Random",
    description = "Random farm layout",
    size = {width = 4, height = 4},
    blocks = {},
    requirements = {
        minDifficulty = 1,
        maxDifficulty = 4,
        biomes = {"plains", "rural"}
    },
    spawnZones = {
        {team = "player", x = 0, y = 3, radius = 1},
        {team = "enemy", x = 3, y = 0, radius = 1}
    }
})

-- Desert MapScripts
MapScripts.register({
    id = "desert_dunes",
    name = "Desert Dunes",
    description = "Rolling sand dunes",
    size = {width = 4, height = 4},
    blocks = {},
    requirements = {
        minDifficulty = 1,
        maxDifficulty = 4,
        biomes = {"desert"}
    },
    spawnZones = {
        {team = "player", x = 0, y = 3, radius = 1},
        {team = "enemy", x = 3, y = 0, radius = 1}
    }
})

MapScripts.register({
    id = "desert_rocks",
    name = "Desert Rocks",
    description = "Rocky desert outcrops",
    size = {width = 4, height = 4},
    blocks = {},
    requirements = {
        minDifficulty = 2,
        maxDifficulty = 5,
        biomes = {"desert"}
    },
    spawnZones = {
        {team = "player", x = 0, y = 3, radius = 1},
        {team = "enemy", x = 3, y = 0, radius = 1}
    }
})

MapScripts.register({
    id = "desert_oasis",
    name = "Desert Oasis",
    description = "Water source with vegetation",
    size = {width = 3, height = 3},
    blocks = {
        {x = 0, y = 0, tags = {"sand"}},
        {x = 1, y = 0, tags = {"vegetation"}},
        {x = 2, y = 0, tags = {"sand"}},
        {x = 0, y = 1, tags = {"vegetation"}},
        {x = 1, y = 1, tags = {"water"}, required = true},
        {x = 2, y = 1, tags = {"vegetation"}},
        {x = 0, y = 2, tags = {"sand"}},
        {x = 1, y = 2, tags = {"vegetation"}},
        {x = 2, y = 2, tags = {"sand"}}
    },
    requirements = {
        minDifficulty = 2,
        maxDifficulty = 4,
        biomes = {"desert"}
    },
    spawnZones = {
        {team = "player", x = 1, y = 2, radius = 1},
        {team = "enemy", x = 1, y = 0, radius = 1}
    }
})

MapScripts.register({
    id = "desert_random",
    name = "Desert Random",
    description = "Random desert layout",
    size = {width = 4, height = 4},
    blocks = {},
    requirements = {
        minDifficulty = 1,
        maxDifficulty = 5,
        biomes = {"desert"}
    },
    spawnZones = {
        {team = "player", x = 0, y = 3, radius = 1},
        {team = "enemy", x = 3, y = 0, radius = 1}
    }
})

-- Mountain MapScripts
MapScripts.register({
    id = "mountain_pass",
    name = "Mountain Pass",
    description = "Narrow pass through mountains",
    size = {width = 3, height = 4},
    blocks = {
        {x = 0, y = 0, tags = {"mountain", "cliff"}},
        {x = 1, y = 0, tags = {"path"}},
        {x = 2, y = 0, tags = {"mountain", "cliff"}},
        {x = 0, y = 1, tags = {"mountain", "cliff"}},
        {x = 1, y = 1, tags = {"path"}, required = true},
        {x = 2, y = 1, tags = {"mountain", "cliff"}},
        {x = 0, y = 2, tags = {"mountain", "cliff"}},
        {x = 1, y = 2, tags = {"path"}, required = true},
        {x = 2, y = 2, tags = {"mountain", "cliff"}},
        {x = 0, y = 3, tags = {"mountain", "cliff"}},
        {x = 1, y = 3, tags = {"path"}},
        {x = 2, y = 3, tags = {"mountain", "cliff"}}
    },
    requirements = {
        minDifficulty = 2,
        maxDifficulty = 6,
        biomes = {"mountain"}
    },
    spawnZones = {
        {team = "player", x = 1, y = 3, radius = 1},
        {team = "enemy", x = 1, y = 0, radius = 1}
    }
})

MapScripts.register({
    id = "mountain_trail",
    name = "Mountain Trail",
    description = "Winding trail through rocky terrain",
    size = {width = 4, height = 4},
    blocks = {},
    requirements = {
        minDifficulty = 2,
        maxDifficulty = 5,
        biomes = {"mountain"}
    },
    spawnZones = {
        {team = "player", x = 0, y = 3, radius = 1},
        {team = "enemy", x = 3, y = 0, radius = 1}
    }
})

MapScripts.register({
    id = "mountain_random",
    name = "Mountain Random",
    description = "Random mountain layout",
    size = {width = 4, height = 4},
    blocks = {},
    requirements = {
        minDifficulty = 2,
        maxDifficulty = 6,
        biomes = {"mountain"}
    },
    spawnZones = {
        {team = "player", x = 0, y = 3, radius = 1},
        {team = "enemy", x = 3, y = 0, radius = 1}
    }
})

-- Arctic MapScripts
MapScripts.register({
    id = "arctic_random",
    name = "Arctic Random",
    description = "Random arctic layout",
    size = {width = 4, height = 4},
    blocks = {},
    requirements = {
        minDifficulty = 2,
        maxDifficulty = 5,
        biomes = {"arctic"}
    },
    spawnZones = {
        {team = "player", x = 0, y = 3, radius = 1},
        {team = "enemy", x = 3, y = 0, radius = 1}
    }
})

MapScripts.register({
    id = "arctic_ice",
    name = "Arctic Ice",
    description = "Frozen ice sheets",
    size = {width = 4, height = 4},
    blocks = {},
    requirements = {
        minDifficulty = 3,
        maxDifficulty = 6,
        biomes = {"arctic"}
    },
    spawnZones = {
        {team = "player", x = 0, y = 3, radius = 1},
        {team = "enemy", x = 3, y = 0, radius = 1}
    }
})

MapScripts.register({
    id = "arctic_rocks",
    name = "Arctic Rocks",
    description = "Rocky arctic terrain",
    size = {width = 4, height = 4},
    blocks = {},
    requirements = {
        minDifficulty = 2,
        maxDifficulty = 5,
        biomes = {"arctic"}
    },
    spawnZones = {
        {team = "player", x = 0, y = 3, radius = 1},
        {team = "enemy", x = 3, y = 0, radius = 1}
    }
})

-- Coastal MapScripts
MapScripts.register({
    id = "beach_random",
    name = "Beach Random",
    description = "Random beach layout",
    size = {width = 4, height = 4},
    blocks = {},
    requirements = {
        minDifficulty = 1,
        maxDifficulty = 3,
        biomes = {"coastal"}
    },
    spawnZones = {
        {team = "player", x = 0, y = 3, radius = 1},
        {team = "enemy", x = 3, y = 0, radius = 1}
    }
})

MapScripts.register({
    id = "water_random",
    name = "Water Random",
    description = "Shallow water areas",
    size = {width = 4, height = 4},
    blocks = {},
    requirements = {
        minDifficulty = 2,
        maxDifficulty = 4,
        biomes = {"water"}
    },
    spawnZones = {
        {team = "player", x = 0, y = 3, radius = 1},
        {team = "enemy", x = 3, y = 0, radius = 1}
    }
})

MapScripts.register({
    id = "dock_district",
    name = "Dock District",
    description = "Coastal docks and warehouses",
    size = {width = 4, height = 4},
    blocks = {
        {x = 0, y = 0, tags = {"water"}},
        {x = 1, y = 0, tags = {"water"}},
        {x = 2, y = 0, tags = {"dock"}},
        {x = 3, y = 0, tags = {"warehouse"}},
        {x = 0, y = 1, tags = {"water"}},
        {x = 1, y = 1, tags = {"dock"}},
        {x = 2, y = 1, tags = {"dock"}},
        {x = 3, y = 1, tags = {"warehouse"}},
        {x = 0, y = 2, tags = {"water"}},
        {x = 1, y = 2, tags = {"dock"}},
        {x = 2, y = 2, tags = {"yard"}},
        {x = 3, y = 2, tags = {"yard"}},
        {x = 0, y = 3, tags = {"water"}},
        {x = 1, y = 3, tags = {"dock"}},
        {x = 2, y = 3, tags = {"yard"}},
        {x = 3, y = 3, tags = {"yard"}}
    },
    requirements = {
        minDifficulty = 2,
        maxDifficulty = 5,
        biomes = {"coastal"}
    },
    spawnZones = {
        {team = "player", x = 3, y = 3, radius = 1},
        {team = "enemy", x = 2, y = 0, radius = 1}
    }
})

MapScripts.register({
    id = "coastal_city",
    name = "Coastal City",
    description = "City near coastline",
    size = {width = 4, height = 4},
    blocks = {},
    requirements = {
        minDifficulty = 2,
        maxDifficulty = 5,
        biomes = {"coastal"}
    },
    spawnZones = {
        {team = "player", x = 0, y = 3, radius = 1},
        {team = "enemy", x = 3, y = 0, radius = 1}
    }
})

-- Special mission MapScripts
MapScripts.register({
    id = "ufo_small_crash",
    name = "UFO Small Crash",
    description = "Small UFO crash site with debris",
    size = {width = 3, height = 3},
    blocks = {
        {x = 0, y = 0, tags = {"terrain"}},
        {x = 1, y = 0, tags = {"debris"}},
        {x = 2, y = 0, tags = {"terrain"}},
        {x = 0, y = 1, tags = {"debris"}},
        {x = 1, y = 1, tags = {"ufo", "small"}, required = true},
        {x = 2, y = 1, tags = {"debris"}},
        {x = 0, y = 2, tags = {"terrain"}},
        {x = 1, y = 2, tags = {"debris"}},
        {x = 2, y = 2, tags = {"terrain"}}
    },
    requirements = {
        minDifficulty = 3,
        maxDifficulty = 7,
        biomes = {"forest", "plains", "desert", "urban"}
    },
    spawnZones = {
        {team = "player", x = 1, y = 2, radius = 1},
        {team = "alien", x = 1, y = 1, radius = 0}
    }
})

MapScripts.register({
    id = "ufo_medium_crash",
    name = "UFO Medium Crash",
    description = "Medium UFO crash site with debris field",
    size = {width = 4, height = 4},
    blocks = {},
    requirements = {
        minDifficulty = 4,
        maxDifficulty = 7,
        biomes = {"forest", "plains", "desert", "urban"}
    },
    spawnZones = {
        {team = "player", x = 0, y = 3, radius = 1},
        {team = "alien", x = 2, y = 2, radius = 1}
    }
})

MapScripts.register({
    id = "ufo_large_crash",
    name = "UFO Large Crash",
    description = "Large UFO crash site with extensive debris",
    size = {width = 5, height = 5},
    blocks = {},
    requirements = {
        minDifficulty = 5,
        maxDifficulty = 8,
        biomes = {"forest", "plains", "desert", "urban"}
    },
    spawnZones = {
        {team = "player", x = 0, y = 4, radius = 1},
        {team = "alien", x = 2, y = 2, radius = 2}
    }
})

MapScripts.register({
    id = "ufo_small_landing",
    name = "UFO Small Landing",
    description = "Small UFO intact landing",
    size = {width = 3, height = 3},
    blocks = {
        {x = 0, y = 0, tags = {"terrain"}},
        {x = 1, y = 0, tags = {"terrain"}},
        {x = 2, y = 0, tags = {"terrain"}},
        {x = 0, y = 1, tags = {"terrain"}},
        {x = 1, y = 1, tags = {"ufo", "small", "intact"}, required = true},
        {x = 2, y = 1, tags = {"terrain"}},
        {x = 0, y = 2, tags = {"terrain"}},
        {x = 1, y = 2, tags = {"terrain"}},
        {x = 2, y = 2, tags = {"terrain"}}
    },
    requirements = {
        minDifficulty = 4,
        maxDifficulty = 8,
        biomes = {"forest", "plains", "desert", "urban"}
    },
    spawnZones = {
        {team = "player", x = 1, y = 2, radius = 1},
        {team = "alien", x = 1, y = 1, radius = 0}
    }
})

MapScripts.register({
    id = "ufo_medium_landing",
    name = "UFO Medium Landing",
    description = "Medium UFO intact landing",
    size = {width = 4, height = 4},
    blocks = {},
    requirements = {
        minDifficulty = 5,
        maxDifficulty = 8,
        biomes = {"forest", "plains", "desert", "urban"}
    },
    spawnZones = {
        {team = "player", x = 0, y = 3, radius = 1},
        {team = "alien", x = 2, y = 2, radius = 1}
    }
})

MapScripts.register({
    id = "ufo_large_landing",
    name = "UFO Large Landing",
    description = "Large UFO intact landing",
    size = {width = 5, height = 5},
    blocks = {},
    requirements = {
        minDifficulty = 6,
        maxDifficulty = 9,
        biomes = {"forest", "plains", "desert", "urban"}
    },
    spawnZones = {
        {team = "player", x = 0, y = 4, radius = 1},
        {team = "alien", x = 2, y = 2, radius = 2}
    }
})

MapScripts.register({
    id = "xcom_base_defense",
    name = "XCOM Base Defense",
    description = "XCOM base under attack",
    size = {width = 6, height = 6},
    blocks = {},
    requirements = {
        minDifficulty = 5,
        maxDifficulty = 9,
        biomes = {}
    },
    spawnZones = {
        {team = "xcom", x = 3, y = 3, radius = 2},
        {team = "alien", x = 0, y = 0, radius = 1},
        {team = "alien", x = 5, y = 0, radius = 1},
        {team = "alien", x = 0, y = 5, radius = 1},
        {team = "alien", x = 5, y = 5, radius = 1}
    }
})

-- Village/Rural MapScripts
MapScripts.register({
    id = "village_random",
    name = "Village Random",
    description = "Random village layout",
    size = {width = 4, height = 4},
    blocks = {},
    requirements = {
        minDifficulty = 1,
        maxDifficulty = 4,
        biomes = {"rural"}
    },
    spawnZones = {
        {team = "player", x = 0, y = 3, radius = 1},
        {team = "enemy", x = 3, y = 0, radius = 1}
    }
})

-- Mixed terrain MapScripts
MapScripts.register({
    id = "grassland_mix",
    name = "Grassland Mix",
    description = "Grassland with scattered trees",
    size = {width = 4, height = 4},
    blocks = {},
    requirements = {
        minDifficulty = 1,
        maxDifficulty = 4,
        biomes = {"forest", "plains"}
    },
    spawnZones = {
        {team = "player", x = 0, y = 3, radius = 1},
        {team = "enemy", x = 3, y = 0, radius = 1}
    }
})

MapScripts.register({
    id = "dirt_road_cross",
    name = "Dirt Road Cross",
    description = "Dirt road intersection",
    size = {width = 3, height = 3},
    blocks = {
        {x = 0, y = 0, tags = {"terrain"}},
        {x = 1, y = 0, tags = {"road"}},
        {x = 2, y = 0, tags = {"terrain"}},
        {x = 0, y = 1, tags = {"road"}},
        {x = 1, y = 1, tags = {"road", "intersection"}, required = true},
        {x = 2, y = 1, tags = {"road"}},
        {x = 0, y = 2, tags = {"terrain"}},
        {x = 1, y = 2, tags = {"road"}},
        {x = 2, y = 2, tags = {"terrain"}}
    },
    requirements = {
        minDifficulty = 1,
        maxDifficulty = 3,
        biomes = {"plains", "rural"}
    },
    spawnZones = {
        {team = "player", x = 1, y = 2, radius = 1},
        {team = "enemy", x = 1, y = 0, radius = 1}
    }
})

MapScripts.register({
    id = "dirt_road_straight",
    name = "Dirt Road Straight",
    description = "Straight dirt road",
    size = {width = 3, height = 4},
    blocks = {
        {x = 0, y = 0, tags = {"terrain"}},
        {x = 1, y = 0, tags = {"road"}},
        {x = 2, y = 0, tags = {"terrain"}},
        {x = 0, y = 1, tags = {"terrain"}},
        {x = 1, y = 1, tags = {"road"}, required = true},
        {x = 2, y = 1, tags = {"terrain"}},
        {x = 0, y = 2, tags = {"terrain"}},
        {x = 1, y = 2, tags = {"road"}, required = true},
        {x = 2, y = 2, tags = {"terrain"}},
        {x = 0, y = 3, tags = {"terrain"}},
        {x = 1, y = 3, tags = {"road"}},
        {x = 2, y = 3, tags = {"terrain"}}
    },
    requirements = {
        minDifficulty = 1,
        maxDifficulty = 3,
        biomes = {"plains", "rural"}
    },
    spawnZones = {
        {team = "player", x = 1, y = 3, radius = 1},
        {team = "enemy", x = 1, y = 0, radius = 1}
    }
})

MapScripts.register({
    id = "suburban_grid",
    name = "Suburban Grid",
    description = "Suburban street grid with houses",
    size = {width = 4, height = 4},
    blocks = {},
    requirements = {
        minDifficulty = 1,
        maxDifficulty = 4,
        biomes = {"urban"}
    },
    spawnZones = {
        {team = "player", x = 0, y = 3, radius = 1},
        {team = "enemy", x = 3, y = 0, radius = 1}
    }
})

MapScripts.register({
    id = "residential_random",
    name = "Residential Random",
    description = "Random residential layout",
    size = {width = 4, height = 4},
    blocks = {},
    requirements = {
        minDifficulty = 1,
        maxDifficulty = 4,
        biomes = {"urban"}
    },
    spawnZones = {
        {team = "player", x = 0, y = 3, radius = 1},
        {team = "enemy", x = 3, y = 0, radius = 1}
    }
})

MapScripts.register({
    id = "commercial_strip",
    name = "Commercial Strip",
    description = "Commercial street with shops",
    size = {width = 4, height = 3},
    blocks = {},
    requirements = {
        minDifficulty = 2,
        maxDifficulty = 5,
        biomes = {"urban"}
    },
    spawnZones = {
        {team = "player", x = 0, y = 2, radius = 1},
        {team = "enemy", x = 3, y = 0, radius = 1}
    }
})

MapScripts.register({
    id = "factory_complex",
    name = "Factory Complex",
    description = "Large factory facility",
    size = {width = 5, height = 5},
    blocks = {},
    requirements = {
        minDifficulty = 3,
        maxDifficulty = 6,
        biomes = {"industrial"}
    },
    spawnZones = {
        {team = "player", x = 0, y = 4, radius = 1},
        {team = "alien", x = 2, y = 2, radius = 1}
    }
})

MapScripts.register({
    id = "rail_yard",
    name = "Rail Yard",
    description = "Railway depot with tracks",
    size = {width = 5, height = 4},
    blocks = {},
    requirements = {
        minDifficulty = 2,
        maxDifficulty = 5,
        biomes = {"industrial"}
    },
    spawnZones = {
        {team = "player", x = 0, y = 3, radius = 1},
        {team = "enemy", x = 4, y = 0, radius = 1}
    }
})

print(string.format("[MapScripts] Registered %d MapScripts", #MapScripts.getAllIds()))

return MapScripts






















