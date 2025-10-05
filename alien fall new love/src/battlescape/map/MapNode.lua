--- MapNode.lua
-- Implements the Map Node system for AI terrain control
-- Map nodes are strategic checkpoints on the battlefield used by AI units to control terrain
--
-- @classmod battlescape.MapNode

local class = require 'lib.middleclass'

--- MapNode class
-- @type MapNode
MapNode = class('MapNode')

--- Create a new MapNode instance
-- @param x number X coordinate on battlefield
-- @param y number Y coordinate on battlefield
-- @param nodeType string Type of control node (spawn_point, cover_position, ambush_point, etc.)
-- @return MapNode instance
function MapNode:initialize(x, y, nodeType)
    self.x = x
    self.y = y
    self.nodeType = nodeType or "control_point"
    self.scoringWeight = 1.0 -- AI preference ranking
    self.capacity = 1 -- Maximum units that can occupy this node
    self.connections = {} -- Connected nodes for pathfinding
    self.metadata = {} -- Additional AI properties
end

--- Set scoring weight for AI decision making
-- @param weight number AI preference value (higher = more desirable)
function MapNode:setScoringWeight(weight)
    self.scoringWeight = weight
end

--- Set capacity for unit occupation
-- @param capacity number Maximum units that can occupy this node
function MapNode:setCapacity(capacity)
    self.capacity = capacity
end

--- Add a connection to another map node
-- @param otherNode MapNode The connected node
-- @param cost number Pathfinding cost (optional, defaults to distance)
function MapNode:addConnection(otherNode, cost)
    if not cost then
        -- Calculate distance-based cost
        local dx = otherNode.x - self.x
        local dy = otherNode.y - self.y
        cost = math.sqrt(dx*dx + dy*dy)
    end

    table.insert(self.connections, {
        node = otherNode,
        cost = cost
    })
end

--- Set metadata for specialized AI behaviors
-- @param key string Metadata key
-- @param value any Metadata value
function MapNode:setMetadata(key, value)
    self.metadata[key] = value
end

--- Get metadata value
-- @param key string Metadata key
-- @return any Metadata value
function MapNode:getMetadata(key)
    return self.metadata[key]
end

--- Check if this node can be occupied by additional units
-- @param currentOccupants number Current number of units on this node
-- @return boolean True if node can accept more units
function MapNode:canOccupy(currentOccupants)
    return currentOccupants < self.capacity
end

--- Calculate distance to another node
-- @param otherNode MapNode The other node
-- @return number Distance between nodes
function MapNode:distanceTo(otherNode)
    local dx = otherNode.x - self.x
    local dy = otherNode.y - self.y
    return math.sqrt(dx*dx + dy*dy)
end

--- Get all connected nodes
-- @return table Array of connected MapNode objects
function MapNode:getConnections()
    local connectedNodes = {}
    for _, connection in ipairs(self.connections) do
        table.insert(connectedNodes, connection.node)
    end
    return connectedNodes
end

--- Check if this node is connected to another node
-- @param otherNode MapNode The node to check
-- @return boolean True if connected
function MapNode:isConnectedTo(otherNode)
    for _, connection in ipairs(self.connections) do
        if connection.node == otherNode then
            return true
        end
    end
    return false
end

return MapNode