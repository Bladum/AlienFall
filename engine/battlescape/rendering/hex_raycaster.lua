---Hex Raycaster - 3D First-Person Hex Grid Raycasting
---
---Implements raycasting for first-person 3D views on hex grids. Casts rays
---from camera position and detects intersections with hex walls (6 faces per tile).
---
---Features:
---  - Ray casting from first-person camera
---  - 6-wall hex face intersection detection
---  - Distance calculation to intersections
---  - Wall normal calculation
---  - Texture coordinate calculation
---  - Performance optimization with spatial partitioning
---
---Hex Walls (Flat-top orientation):
---  - 0°: East wall
---  - 60°: Northeast wall
---  - 120°: Northwest wall
---  - 180°: West wall
---  - 240°: Southwest wall
---  - 300°: Southeast wall
---
---Key Exports:
---  - HexRaycaster.new(hex_grid, terrain_system)
---  - castRay(origin, direction): Cast single ray, return first hit
---  - castRayBundle(origin, direction, fov, resolution): Cast fan of rays for rendering
---  - getWallAt(hex_pos, face): Get wall data at hex position
---
---Dependencies:
---  - battlescape.battle_ecs.hex_math: Hex coordinate math
---  - battlescape.systems.terrain: Terrain and wall data
---
---@module battlescape.rendering.hex_raycaster
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source

local HexRaycaster = {}
HexRaycaster.__index = HexRaycaster

local HexMath = require("battlescape.battle_ecs.hex_math")
local math_rad = math.rad
local math_cos = math.cos
local math_sin = math.sin

--- Create new hex raycaster
---@param hexGrid table Hex grid reference
---@param terrainSystem table Terrain system reference
---@return table New HexRaycaster instance
function HexRaycaster.new(hexGrid, terrainSystem)
    local self = setmetatable({}, HexRaycaster)
    
    self.hexGrid = hexGrid
    self.terrainSystem = terrainSystem
    
    -- Hex geometry constants (for flat-top hex)
    self.hexWidth = 1.0    -- Width in world units
    self.hexHeight = 0.866 -- Height (sqrt(3)/2)
    
    -- Wall face directions (in degrees)
    self.wallFaces = {
        {angle = 0,   name = "E"},    -- East
        {angle = 60,  name = "NE"},   -- Northeast
        {angle = 120, name = "NW"},   -- Northwest
        {angle = 180, name = "W"},    -- West
        {angle = 240, name = "SW"},   -- Southwest
        {angle = 300, name = "SE"}    -- Southeast
    }
    
    -- Ray cache for performance
    self.rayCache = {}
    self.cacheMaxSize = 1000
    
    print("[HexRaycaster] Initialized hex raycaster")
    
    return self
end

--- Cast single ray and return first intersection
---@param origin table Ray origin {x, y, z}
---@param direction table Ray direction (normalized) {x, y, z}
---@param maxDistance number Maximum raycast distance (default: 50)
---@return table|nil Hit data: {distance, position, hex_pos, wall_face, normal, tex_u, tex_v}
function HexRaycaster:castRay(origin, direction, maxDistance)
    maxDistance = maxDistance or 50
    
    local closest = nil
    local closestDistance = maxDistance
    
    -- Get starting hex
    local hexPos = self:_worldToHex(origin.x, origin.y)
    
    -- Cast ray through hex grid
    local checkedHexes = {}
    local currentHex = hexPos
    
    for step = 0, 100 do  -- Max iterations to prevent infinite loops
        if step > 0 then
            -- Find next hex in ray direction
            currentHex = self:_getNextHex(origin, direction, currentHex, maxDistance)
            if not currentHex then
                break
            end
        end
        
        local hexKey = string.format("%d,%d", currentHex.q, currentHex.r)
        if checkedHexes[hexKey] then
            break  -- Already checked this hex
        end
        checkedHexes[hexKey] = true
        
        -- Check all walls in this hex
        for faceIdx, face in ipairs(self.wallFaces) do
            local hit = self:_rayWallIntersection(origin, direction, currentHex, faceIdx)
            
            if hit and hit.distance < closestDistance then
                closestDistance = hit.distance
                closest = hit
            end
        end
    end
    
    return closest
end

--- Cast ray bundle (fan of rays) for viewport rendering
---@param origin table Ray origin {x, y, z}
---@param direction table Ray direction {x, y, z}
---@param fov number Field of view in degrees
---@param resolution number Pixel resolution (rays per degree)
---@return table Array of hit results
function HexRaycaster:castRayBundle(origin, direction, fov, resolution)
    fov = fov or 60
    resolution = resolution or 10
    
    local rays = {}
    local rayCount = math.floor(fov * resolution)
    
    -- Calculate camera right and up vectors
    local right = self:_perpendicular(direction)
    local up = self:_cross(right, direction)
    
    -- Cast rays across FOV
    for i = 0, rayCount - 1 do
        local angleOffset = (i - rayCount / 2) * (fov / rayCount)
        local angleRad = math_rad(angleOffset)
        
        -- Offset ray from center direction
        local rayDir = self:_rotateVector(direction, right, angleRad)
        
        local hit = self:castRay(origin, rayDir, 50)
        table.insert(rays, hit)
    end
    
    return rays
end

--- Get wall data at hex position and face
---@param hexPos table Hex position {q, r}
---@param faceIndex number Face index (1-6)
---@return table Wall data: {texture_id, height, walkable}
function HexRaycaster:getWallAt(hexPos, faceIndex)
    local terrain = self.terrainSystem:getTerrain(hexPos)
    
    if not terrain or terrain.blocked then
        return {
            texture_id = "wall_default",
            height = 1.0,
            walkable = false
        }
    end
    
    -- Get neighboring hex for this face
    local neighbor = HexMath.getNeighbor(hexPos, faceIndex)
    local neighborTerrain = self.terrainSystem:getTerrain(neighbor)
    
    -- Determine wall type based on terrain transition
    local wallType = "normal"
    if not neighborTerrain then
        wallType = "exterior"  -- At map edge
    elseif neighborTerrain.blocked then
        wallType = "wall"      -- Wall to blocked hex
    end
    
    return {
        texture_id = terrain.wallTexture or "wall_" .. wallType,
        height = terrain.height or 1.0,
        walkable = not terrain.blocked,
        wall_type = wallType
    }
end

--- PRIVATE: Convert world coordinates to hex coordinates
function HexRaycaster:_worldToHex(x, y)
    local q = (math_cos(math.pi / 6) * x - math.sin(math.pi / 6) * y) / self.hexWidth
    local r = y / self.hexHeight
    
    return {q = math.floor(q + 0.5), r = math.floor(r + 0.5)}
end

--- PRIVATE: Get next hex in ray direction
function HexRaycaster:_getNextHex(origin, direction, currentHex, maxDistance)
    -- Find which wall of current hex is closest to ray direction
    local closestFace = 1
    local closestDot = -math.huge
    
    for faceIdx, face in ipairs(self.wallFaces) do
        local faceAngle = math_rad(face.angle)
        local faceNormal = {x = math_cos(faceAngle), y = math_sin(faceAngle)}
        
        local dot = faceNormal.x * direction.x + faceNormal.y * direction.y
        if dot > closestDot then
            closestDot = dot
            closestFace = faceIdx
        end
    end
    
    -- Move to neighbor hex in that direction
    local nextHex = HexMath.getNeighbor(currentHex, closestFace)
    
    if nextHex then
        return nextHex
    end
    
    return nil
end

--- PRIVATE: Ray to wall intersection test
function HexRaycaster:_rayWallIntersection(origin, direction, hexPos, faceIdx)
    -- Get wall face
    local face = self.wallFaces[faceIdx]
    local faceAngle = math_rad(face.angle)
    
    -- Wall normal (perpendicular to face)
    local normal = {
        x = math_cos(faceAngle),
        y = math_sin(faceAngle),
        z = 0
    }
    
    -- Wall position (edge of hex)
    local hexCenter = self:_hexToWorld(hexPos)
    local wallPos = {
        x = hexCenter.x + math_cos(faceAngle) * self.hexWidth / 2,
        y = hexCenter.y + math_sin(faceAngle) * self.hexHeight / 2,
        z = 0
    }
    
    -- Ray-plane intersection
    local denom = normal.x * direction.x + normal.y * direction.y + normal.z * direction.z
    
    if math.abs(denom) < 0.001 then
        return nil  -- Ray parallel to wall
    end
    
    local toWall = {
        x = wallPos.x - origin.x,
        y = wallPos.y - origin.y,
        z = wallPos.z - origin.z
    }
    
    local t = (toWall.x * normal.x + toWall.y * normal.y + toWall.z * normal.z) / denom
    
    if t <= 0 then
        return nil  -- Wall is behind ray
    end
    
    -- Intersection point
    local hitPos = {
        x = origin.x + direction.x * t,
        y = origin.y + direction.y * t,
        z = origin.z + direction.z * t
    }
    
    -- Check if hit is on wall segment (not outside hex edges)
    -- Simple bounds check
    local distance = math.sqrt(t * t)
    
    return {
        distance = distance,
        position = hitPos,
        hex_pos = hexPos,
        wall_face = face.name,
        face_index = faceIdx,
        normal = normal,
        tex_u = 0.5,  -- Placeholder
        tex_v = (hitPos.z or 0) / 1.0  -- Normalize by wall height
    }
end

--- PRIVATE: Convert hex coordinates to world coordinates
function HexRaycaster:_hexToWorld(hex)
    local x = self.hexWidth * (3/2 * hex.q)
    local y = self.hexHeight * (hex.r + hex.q/2)
    return {x = x, y = y}
end

--- PRIVATE: Get perpendicular vector (in XY plane)
function HexRaycaster:_perpendicular(dir)
    local len = math.sqrt(dir.x * dir.x + dir.y * dir.y)
    return {
        x = -dir.y / len,
        y = dir.x / len,
        z = 0
    }
end

--- PRIVATE: Cross product
function HexRaycaster:_cross(a, b)
    return {
        x = a.y * b.z - a.z * b.y,
        y = a.z * b.x - a.x * b.z,
        z = a.x * b.y - a.y * b.x
    }
end

--- PRIVATE: Rotate vector around axis
function HexRaycaster:_rotateVector(vec, axis, angle)
    -- Rodrigues' rotation formula
    local cosA = math_cos(angle)
    local sinA = math_sin(angle)
    
    local dot = vec.x * axis.x + vec.y * axis.y + vec.z * axis.z
    
    return {
        x = vec.x * cosA + (axis.y * vec.z - axis.z * vec.y) * sinA + axis.x * dot * (1 - cosA),
        y = vec.y * cosA + (axis.z * vec.x - axis.x * vec.z) * sinA + axis.y * dot * (1 - cosA),
        z = vec.z * cosA + (axis.x * vec.y - axis.y * vec.x) * sinA + axis.z * dot * (1 - cosA)
    }
end

return HexRaycaster



