---BaseGrid - Facility Grid Management
---
---Manages 5×5 facility grid for a base. Handles facility placement, removal,
---connectivity checking (HQ connectivity), and grid queries.
---
---Features:
---  - 5×5 grid with fixed coordinates (0-4, 0-4)
---  - Mandatory HQ at center (2, 2)
---  - Facility placement and removal
---  - HQ connectivity validation via flood-fill
---  - Grid queries and iteration
---
---@module basescape.logic.base_grid
---@author AlienFall Development Team

local BaseGrid = {}
BaseGrid.__index = BaseGrid

---Create new base grid
---@param baseId string Base identifier
---@return BaseGrid grid New grid
function BaseGrid.new(baseId)
    local self = setmetatable({}, BaseGrid)
    
    self.baseId = baseId
    self.size = 5  -- 5×5 grid
    self.grid = {}  -- [y][x] = facility or nil
    self.facilities = {}  -- Map of facility.id -> facility
    self.hqFacility = nil  -- Reference to HQ facility
    
    -- Initialize empty grid
    for y = 0, self.size - 1 do
        self.grid[y] = {}
        for x = 0, self.size - 1 do
            self.grid[y][x] = nil
        end
    end
    
    print(string.format("[BaseGrid] Initialized %s (5×5)", baseId))
    return self
end

---Check if coordinates are valid
---@param x number X coordinate (0-4)
---@param y number Y coordinate (0-4)
---@return boolean valid True if in bounds
function BaseGrid:isInBounds(x, y)
    return x >= 0 and x < self.size and y >= 0 and y < self.size
end

---Get facility at grid position
---@param x number X coordinate
---@param y number Y coordinate
---@return table|nil facility Facility or nil
function BaseGrid:getFacilityAt(x, y)
    if not self:isInBounds(x, y) then
        return nil
    end
    return self.grid[y][x]
end

---Check if grid cell is available (empty)
---@param x number X coordinate
---@param y number Y coordinate
---@return boolean available True if empty
function BaseGrid:isCellAvailable(x, y)
    if not self:isInBounds(x, y) then
        return false
    end
    return self.grid[y][x] == nil
end

---Place facility on grid
---@param facility table Facility instance
---@param x number X coordinate
---@param y number Y coordinate
---@return boolean success True if placed
---@return string? error Error message if failed
function BaseGrid:placeFacility(facility, x, y)
    -- Validate coordinates
    if not self:isInBounds(x, y) then
        return false, "Coordinates out of bounds"
    end
    
    -- Check cell is empty
    if not self:isCellAvailable(x, y) then
        return false, "Cell already occupied"
    end
    
    -- Place facility
    facility.gridX = x
    facility.gridY = y
    self.grid[y][x] = facility
    self.facilities[facility.id] = facility
    
    -- If HQ, mark it
    if facility.typeId == "hq" then
        self.hqFacility = facility
    end
    
    -- Update connectivity
    self:updateConnectivity()
    
    print(string.format("[BaseGrid] Placed %s at (%d,%d)", facility.typeId, x, y))
    return true
end

---Remove facility from grid
---@param x number X coordinate
---@param y number Y coordinate
---@return boolean success True if removed
function BaseGrid:removeFacility(x, y)
    if not self:isInBounds(x, y) then
        return false
    end
    
    local facility = self.grid[y][x]
    if not facility then
        return false
    end
    
    -- Cannot remove HQ
    if facility.typeId == "hq" then
        print("[BaseGrid] Cannot remove HQ!")
        return false
    end
    
    -- Remove from grid
    self.grid[y][x] = nil
    self.facilities[facility.id] = nil
    
    -- Update connectivity
    self:updateConnectivity()
    
    print(string.format("[BaseGrid] Removed %s from (%d,%d)", facility.typeId, x, y))
    return true
end

---Update facility connectivity via BFS from HQ
---HQ is always connected. Other facilities must connect via HQ.
function BaseGrid:updateConnectivity()
    if not self.hqFacility then
        print("[BaseGrid] WARNING: No HQ facility found")
        return
    end
    
    -- Mark all as disconnected
    for _, facility in pairs(self.facilities) do
        facility.isConnected = false
    end
    
    -- BFS from HQ
    local queue = {}
    table.insert(queue, self.hqFacility)
    self.hqFacility.isConnected = true
    
    while #queue > 0 do
        local current = table.remove(queue, 1)
        local cx, cy = current.gridX, current.gridY
        
        -- Check all adjacent cells (4-directional)
        local directions = {{0, -1}, {1, 0}, {0, 1}, {-1, 0}}
        for _, dir in ipairs(directions) do
            local nx, ny = cx + dir[1], cy + dir[2]
            local neighbor = self:getFacilityAt(nx, ny)
            
            if neighbor and not neighbor.isConnected then
                neighbor.isConnected = true
                table.insert(queue, neighbor)
            end
        end
    end
    
    -- Print connectivity status
    local connected = 0
    for _, facility in pairs(self.facilities) do
        if facility.isConnected then
            connected = connected + 1
        end
    end
    print(string.format("[BaseGrid] Connectivity updated: %d/%d connected", 
        connected, self:getFacilityCount()))
end

---Get all facilities
---@return table facilities Array of facilities
function BaseGrid:getAllFacilities()
    local result = {}
    for _, facility in pairs(self.facilities) do
        table.insert(result, facility)
    end
    return result
end

---Get facilities by type
---@param typeId string Facility type ID
---@return table facilities Array of matching facilities
function BaseGrid:getFacilitiesByType(typeId)
    local result = {}
    for _, facility in pairs(self.facilities) do
        if facility.typeId == typeId then
            table.insert(result, facility)
        end
    end
    return result
end

---Count facilities
---@return number count Total facility count
function BaseGrid:getFacilityCount()
    local count = 0
    for _ in pairs(self.facilities) do
        count = count + 1
    end
    return count
end

---Count operational facilities
---@return number count Operational facility count
function BaseGrid:getOperationalCount()
    local count = 0
    for _, facility in pairs(self.facilities) do
        if facility:isOperational() then
            count = count + 1
        end
    end
    return count
end

---Draw grid visualization (debug)
function BaseGrid:printDebug()
    print(string.format("\n[BaseGrid %s] Status:", self.baseId))
    print("Facilities:")
    
    for y = 0, self.size - 1 do
        local row = "  "
        for x = 0, self.size - 1 do
            local facility = self.grid[y][x]
            if facility then
                local marker = facility.isConnected and "C" or "D"  -- Connected/Disconnected
                row = row .. string.format("[%s%s] ", facility.typeId:sub(1,1), marker)
            else
                row = row .. "[  ] "
            end
        end
        print(row)
    end
    
    print(string.format("Total: %d facilities", self:getFacilityCount()))
end

return BaseGrid



