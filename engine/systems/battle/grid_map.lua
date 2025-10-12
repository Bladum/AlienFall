-- GridMap Class
-- Arranges MapBlocks in 4x4 to 7x7 grid to generate complete battlefield
-- Uses rotated hex grid pattern (45° angle) for block placement

local MapBlock = require("systems.battle.map_block")
local DataLoader = require("systems.data_loader")

local GridMap = {}
GridMap.__index = GridMap

---
--- Constructor
---

function GridMap.new(gridWidth, gridHeight)
    local self = setmetatable({}, GridMap)
    
    self.gridWidth = gridWidth or 4  -- 4-7 map blocks wide
    self.gridHeight = gridHeight or 4  -- 4-7 map blocks high
    self.blocks = {}  -- [blockY][blockX] = MapBlock
    self.blockWidth = 15  -- Standard block size
    self.blockHeight = 15
    
    -- Calculate world dimensions
    self.worldWidth = self.gridWidth * self.blockWidth
    self.worldHeight = self.gridHeight * self.blockHeight
    
    -- Initialize empty grid
    for by = 1, self.gridHeight do
        self.blocks[by] = {}
        for bx = 1, self.gridWidth do
            self.blocks[by][bx] = nil
        end
    end
    
    return self
end

---
--- Block Placement
---

-- Set block at grid position
function GridMap:setBlock(blockX, blockY, block)
    if blockY >= 1 and blockY <= self.gridHeight and 
       blockX >= 1 and blockX <= self.gridWidth then
        self.blocks[blockY][blockX] = block
        return true
    end
    return false
end

-- Get block at grid position
function GridMap:getBlock(blockX, blockY)
    if blockY >= 1 and blockY <= self.gridHeight and 
       blockX >= 1 and blockX <= self.gridWidth then
        return self.blocks[blockY] and self.blocks[blockY][blockX]
    end
    return nil
end

---
--- Coordinate Conversion
---

-- Convert world tile coordinates to block grid position
function GridMap:worldToBlock(worldX, worldY)
    local blockX = math.floor((worldX - 1) / self.blockWidth) + 1
    local blockY = math.floor((worldY - 1) / self.blockHeight) + 1
    return blockX, blockY
end

-- Convert block grid position to world tile coordinates (top-left corner)
function GridMap:blockToWorld(blockX, blockY)
    local worldX = (blockX - 1) * self.blockWidth + 1
    local worldY = (blockY - 1) * self.blockHeight + 1
    return worldX, worldY
end

-- Convert world coordinates to local coordinates within block
function GridMap:worldToLocal(worldX, worldY)
    local blockX, blockY = self:worldToBlock(worldX, worldY)
    local blockWorldX, blockWorldY = self:blockToWorld(blockX, blockY)
    
    local localX = worldX - blockWorldX + 1
    local localY = worldY - blockWorldY + 1
    
    return localX, localY, blockX, blockY
end

---
--- Tile Access
---

-- Get terrain ID at world tile coordinates
function GridMap:getTileAt(worldX, worldY)
    -- Check bounds
    if worldX < 1 or worldX > self.worldWidth or 
       worldY < 1 or worldY > self.worldHeight then
        return nil
    end
    
    -- Get block and local coordinates
    local localX, localY, blockX, blockY = self:worldToLocal(worldX, worldY)
    local block = self:getBlock(blockX, blockY)
    
    if not block then
        return "floor"  -- Default terrain if no block
    end
    
    return block:getTile(localX, localY) or "floor"
end

---
--- Random Generation
---

-- Generate random map from block pool
function GridMap:generateRandom(blockPool, seed)
    if seed then
        math.randomseed(seed)
    end
    
    if not blockPool or #blockPool == 0 then
        print("[GridMap] ERROR: Empty block pool")
        return false
    end
    
    print(string.format("[GridMap] Generating %dx%d grid from %d blocks", 
        self.gridWidth, self.gridHeight, #blockPool))
    
    -- Place random blocks
    for by = 1, self.gridHeight do
        for bx = 1, self.gridWidth do
            local randomBlock = blockPool[math.random(1, #blockPool)]
            self:setBlock(bx, by, randomBlock)
        end
    end
    
    print(string.format("[GridMap] Generated %dx%d tile map", 
        self.worldWidth, self.worldHeight))
    
    return true
end

-- Generate with biome theming
function GridMap:generateThemed(blockPool, biomePreferences)
    if not blockPool or #blockPool == 0 then
        print("[GridMap] ERROR: Empty block pool")
        return false
    end
    
    -- Group blocks by biome
    local biomeBlocks = {}
    for _, block in ipairs(blockPool) do
        local biome = block.metadata.biome or "mixed"
        if not biomeBlocks[biome] then
            biomeBlocks[biome] = {}
        end
        table.insert(biomeBlocks[biome], block)
    end
    
    -- Select primary biome
    local primaryBiome = biomePreferences and biomePreferences[1] or "mixed"
    local blocks = biomeBlocks[primaryBiome] or blockPool
    
    print(string.format("[GridMap] Generating themed map (biome: %s, %d blocks)", 
        primaryBiome, #blocks))
    
    -- Place themed blocks
    for by = 1, self.gridHeight do
        for bx = 1, self.gridWidth do
            -- Add variety: 20% chance to use different biome
            local useBlocks = blocks
            if math.random() < 0.2 and #biomeBlocks > 1 then
                -- Pick random other biome
                local otherBiomes = {}
                for biome, _ in pairs(biomeBlocks) do
                    if biome ~= primaryBiome then
                        table.insert(otherBiomes, biome)
                    end
                end
                if #otherBiomes > 0 then
                    local randomBiome = otherBiomes[math.random(1, #otherBiomes)]
                    useBlocks = biomeBlocks[randomBiome]
                end
            end
            
            local randomBlock = useBlocks[math.random(1, #useBlocks)]
            self:setBlock(bx, by, randomBlock)
        end
    end
    
    print(string.format("[GridMap] Generated %dx%d themed tile map", 
        self.worldWidth, self.worldHeight))
    
    return true
end

---
--- Battlefield Conversion
---

-- Convert GridMap to Battlefield instance
function GridMap:toBattlefield()
    print(string.format("[GridMap] Converting to Battlefield (%dx%d)", 
        self.worldWidth, self.worldHeight))
    
    -- Create battlefield
    local Battlefield = require("systems.battle.battlefield")
    local battlefield = Battlefield.new(self.worldWidth, self.worldHeight)
    
    -- Copy all tiles
    for y = 1, self.worldHeight do
        for x = 1, self.worldWidth do
            local terrainId = self:getTileAt(x, y)
            local terrain = DataLoader.terrainTypes.get(terrainId)
            
            if terrain then
                local tile = battlefield:getTile(x, y)
                if tile then
                    tile.terrain = terrain
                    tile.x = x
                    tile.y = y
                    -- Initialize effects table for fire/smoke
                    tile.effects = {
                        fire = false,
                        smoke = 0,
                        fireDuration = 0,
                        smokeAge = 0
                    }
                end
            end
        end
    end
    
    print("[GridMap] Battlefield conversion complete")
    return battlefield
end

---
--- Visualization
---

-- Generate ASCII representation of grid
function GridMap:toASCII()
    local lines = {}
    
    table.insert(lines, string.format("GridMap %dx%d (World: %dx%d)", 
        self.gridWidth, self.gridHeight, self.worldWidth, self.worldHeight))
    table.insert(lines, "")
    
    -- Show block grid
    for by = 1, self.gridHeight do
        local row = {}
        for bx = 1, self.gridWidth do
            local block = self:getBlock(bx, by)
            if block then
                table.insert(row, string.format("[%s]", block.id:sub(1, 6)))
            else
                table.insert(row, "[EMPTY]")
            end
        end
        table.insert(lines, table.concat(row, " "))
    end
    
    return table.concat(lines, "\n")
end

---
--- Statistics
---

function GridMap:getStats()
    local blockCount = 0
    local biomeCount = {}
    
    for by = 1, self.gridHeight do
        for bx = 1, self.gridWidth do
            local block = self:getBlock(bx, by)
            if block then
                blockCount = blockCount + 1
                local biome = block.metadata.biome or "unknown"
                biomeCount[biome] = (biomeCount[biome] or 0) + 1
            end
        end
    end
    
    return {
        gridSize = {width = self.gridWidth, height = self.gridHeight},
        worldSize = {width = self.worldWidth, height = self.worldHeight},
        blockCount = blockCount,
        biomes = biomeCount
    }
end

return GridMap
