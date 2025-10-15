---Craft Entity for Geoscape
---
---Represents a player craft (interceptor, transport) that can travel between
---provinces on the geoscape. Handles movement, fuel, crew assignment, equipment,
---and mission deployment. Crafts are the primary means of responding to missions
---and intercepting UFOs.
---
---Craft Types:
---  - Interceptor: Fast, armed, for UFO interception
---  - Transport: Slow, large capacity, for troop deployment
---  - Scout: Medium speed, recon missions
---
---Craft Properties:
---  - Location: Current province or base
---  - Crew: Assigned soldiers and pilots
---  - Equipment: Weapons, fuel, cargo
---  - Status: Fuel, damage, availability
---  - Mission: Current assignment or idle
---
---Key Exports:
---  - Craft.new(data): Creates craft instance
---  - moveTo(provinceId): Moves craft to province
---  - assignCrew(soldiers): Assigns soldiers to craft
---  - refuel(): Refuels craft at base
---  - repair(amount): Repairs damage
---  - canIntercept(): Checks if ready for combat
---
---Dependencies:
---  - geoscape.geography.province: Province definitions
---  - shared.units.units: Soldier/crew management
---  - battlescape.combat.weapon_system: Craft weapons
---
---@module shared.crafts.craft
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local Craft = require("shared.crafts.craft")
---  local interceptor = Craft.new({
---    id = "craft_1",
---    name = "Skyranger-1",
---    type = "transport"
---  })
---  interceptor:moveTo("province_23")
---  interceptor:assignCrew(squad)
---
---@see geoscape.world.world For craft movement
---@see scenes.interception_screen For craft combat

local Craft = {}
Craft.__index = Craft

---Create a new craft
---@param data table Craft data
---@return table Craft instance
function Craft.new(data)
    local self = setmetatable({}, Craft)
    
    -- Core identification
    self.id = data.id or error("Craft requires id")
    self.name = data.name or "Unnamed Craft"
    self.type = data.type or "interceptor"
    
    -- Current location
    self.provinceId = data.provinceId or nil  -- Current province ID
    self.baseId = data.baseId or nil  -- Home base ID
    
    -- Travel state
    self.isDeployed = false
    self.path = {}  -- List of province IDs to travel through
    self.pathIndex = 0  -- Current position in path
    self.travelTime = 0  -- Days to reach next province
    
    -- Stats
    self.speed = data.speed or 1  -- Provinces per day
    self.range = data.range or 10  -- Max travel distance
    self.fuelCapacity = data.fuelCapacity or 100
    self.currentFuel = data.currentFuel or self.fuelCapacity
    self.fuelConsumption = data.fuelConsumption or 1  -- Fuel per province traveled
    
    -- Loadout
    self.soldiers = data.soldiers or {}
    self.items = data.items or {}
    
    print(string.format("[Craft] Created '%s' (%s) at province %s",
        self.name, self.type, tostring(self.provinceId)))
    
    return self
end

---Deploy craft to a target province
---@param path table List of province IDs
---@return boolean True if deployment successful
function Craft:deploy(path)
    if #path < 2 then
        return false  -- Need at least start and end
    end
    
    -- Calculate fuel required
    local fuelRequired = (#path - 1) * self.fuelConsumption
    if fuelRequired > self.currentFuel then
        print(string.format("[Craft] %s: Insufficient fuel (%d required, %d available)",
            self.name, fuelRequired, self.currentFuel))
        return false
    end
    
    self.path = path
    self.pathIndex = 1
    self.travelTime = 1 / self.speed  -- Days to next province
    self.isDeployed = true
    
    print(string.format("[Craft] %s deployed with path of %d provinces", self.name, #path))
    return true
end

---Update craft travel (call once per day)
---@return boolean True if reached destination
function Craft:updateTravel()
    if not self.isDeployed or #self.path == 0 then
        return false
    end
    
    -- Reduce travel time
    self.travelTime = self.travelTime - 1
    
    if self.travelTime <= 0 then
        -- Move to next province
        self.pathIndex = self.pathIndex + 1
        
        if self.pathIndex <= #self.path then
            self.provinceId = self.path[self.pathIndex]
            self.currentFuel = self.currentFuel - self.fuelConsumption
            
            if self.pathIndex < #self.path then
                -- Still traveling
                self.travelTime = 1 / self.speed
            else
                -- Reached destination
                self.isDeployed = false
                print(string.format("[Craft] %s reached destination: %s", self.name, self.provinceId))
                return true
            end
        end
    end
    
    return false
end

---Return craft to home base
---@param provinceGraph table Province graph for pathfinding
---@return boolean True if return path set successfully
function Craft:returnToBase(provinceGraph)
    if not self.baseId or not self.provinceId then
        return false
    end
    
    -- Find base province
    local baseProvince = nil
    for _, province in pairs(provinceGraph:getAllProvinces()) do
        if province:hasBase() and province.playerBase.id == self.baseId then
            baseProvince = province
            break
        end
    end
    
    if not baseProvince then
        return false
    end
    
    -- Find path back to base
    local path = provinceGraph:findPath(self.provinceId, baseProvince.id)
    if path then
        return self:deploy(path)
    end
    
    return false
end

---Get operational range from current position
---@param provinceGraph table Province graph
---@return table Map of provinceId -> {cost, path}
function Craft:getOperationalRange(provinceGraph)
    if not self.provinceId then
        return {}
    end
    
    local maxRange = math.floor(self.currentFuel / self.fuelConsumption)
    maxRange = math.min(maxRange, self.range)
    
    return provinceGraph:getRange(self.provinceId, maxRange)
end

---Refuel craft
---@param amount number? Amount to refuel (nil = full)
function Craft:refuel(amount)
    if amount then
        self.currentFuel = math.min(self.currentFuel + amount, self.fuelCapacity)
    else
        self.currentFuel = self.fuelCapacity
    end
end

---Get fuel percentage
---@return number Fuel percentage (0.0 to 1.0)
function Craft:getFuelPercentage()
    return self.currentFuel / self.fuelCapacity
end

---Check if craft can reach a province
---@param provinceGraph table Province graph
---@param targetProvinceId string Target province ID
---@return boolean True if reachable
---@return number? Fuel required
function Craft:canReach(provinceGraph, targetProvinceId)
    if not self.provinceId then
        return false, nil
    end
    
    local path, cost = provinceGraph:findPath(self.provinceId, targetProvinceId)
    if not path then
        return false, nil
    end
    
    local fuelRequired = cost * self.fuelConsumption
    return fuelRequired <= self.currentFuel and cost <= self.range, fuelRequired
end

---Get craft info for UI
---@return table Craft info
function Craft:getInfo()
    return {
        id = self.id,
        name = self.name,
        type = self.type,
        provinceId = self.provinceId,
        baseId = self.baseId,
        isDeployed = self.isDeployed,
        fuel = self.currentFuel,
        fuelMax = self.fuelCapacity,
        fuelPercent = self:getFuelPercentage(),
        speed = self.speed,
        range = self.range,
        soldiers = #self.soldiers,
        items = #self.items
    }
end

---Serialize craft for save/load
---@return table Craft data
function Craft:serialize()
    return {
        id = self.id,
        name = self.name,
        type = self.type,
        provinceId = self.provinceId,
        baseId = self.baseId,
        isDeployed = self.isDeployed,
        path = self.path,
        pathIndex = self.pathIndex,
        travelTime = self.travelTime,
        speed = self.speed,
        range = self.range,
        fuelCapacity = self.fuelCapacity,
        currentFuel = self.currentFuel,
        fuelConsumption = self.fuelConsumption,
        soldiers = self.soldiers,
        items = self.items
    }
end

return Craft






















