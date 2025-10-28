-- Interception Target Display System
-- Shows targeting reticle, hit probability, distance, and acquisition status

local TargetDisplay = {}
TargetDisplay.__index = TargetDisplay

-- Initialize target display
function TargetDisplay.new()
    local self = setmetatable({}, TargetDisplay)
    
    self.screenWidth = 960
    self.screenHeight = 720
    self.centerX = self.screenWidth / 2
    self.centerY = self.screenHeight / 2
    
    -- Targeting reticle
    self.reticle = {
        x = self.centerX,
        y = self.centerY,
        size = 40,
        rotation = 0,
        rotationSpeed = 2,
        locked = false,
        lockStrength = 0 -- 0-1
    }
    
    -- Target information
    self.target = {
        acquired = false,
        x = self.centerX + 100,
        y = self.centerY - 50,
        distance = 0,
        relativeAltitude = 0,
        interceptProbability = 0,
        trackingDifficulty = 0 -- 1-5
    }
    
    return self
end

-- Draw target display HUD
function TargetDisplay:draw(targetData, craftData)
    if not targetData then return end
    
    -- Draw main reticle
    self:drawReticle(targetData)
    
    -- Draw targeting information
    self:drawTargetInfo(targetData, craftData)
    
    -- Draw lead indicator
    self:drawLeadIndicator(targetData, craftData)
    
    -- Draw distance rings
    self:drawDistanceRings()
end

-- Draw main targeting reticle
function TargetDisplay:drawReticle(targetData)
    local reticle = self.reticle
    
    -- Update rotation
    reticle.rotation = reticle.rotation + reticle.rotationSpeed
    
    -- Calculate lock strength
    if targetData.distance < 5000 then -- Within range
        reticle.lockStrength = math.min(1, reticle.lockStrength + 0.02)
    else
        reticle.lockStrength = math.max(0, reticle.lockStrength - 0.03)
    end
    
    -- Determine reticle color based on lock status
    local r, g, b = 1, 1, 0 -- Yellow for tracking
    if reticle.lockStrength >= 0.8 then
        r, g, b = 0, 1, 0 -- Green for locked
        reticle.locked = true
    elseif reticle.lockStrength < 0.3 then
        r, g, b = 1, 0, 0 -- Red for lost
        reticle.locked = false
    end
    
    love.graphics.setColor(r, g, b, 0.8)
    
    -- Draw outer circle
    love.graphics.circle("line", reticle.x, reticle.y, reticle.size)
    
    -- Draw crosshair
    love.graphics.line(reticle.x - reticle.size - 10, reticle.y, reticle.x - reticle.size, reticle.y)
    love.graphics.line(reticle.x + reticle.size, reticle.y, reticle.x + reticle.size + 10, reticle.y)
    love.graphics.line(reticle.x, reticle.y - reticle.size - 10, reticle.x, reticle.y - reticle.size)
    love.graphics.line(reticle.x, reticle.y + reticle.size, reticle.x, reticle.y + reticle.size + 10)
    
    -- Draw rotation corners (for lock animation)
    local cornerSize = 8
    local corners = {
        { reticle.x - reticle.size, reticle.y - reticle.size },
        { reticle.x + reticle.size, reticle.y - reticle.size },
        { reticle.x + reticle.size, reticle.y + reticle.size },
        { reticle.x - reticle.size, reticle.y + reticle.size }
    }
    
    for _, corner in ipairs(corners) do
        love.graphics.line(corner[1] - cornerSize, corner[2], corner[1], corner[2])
        love.graphics.line(corner[1], corner[2] - cornerSize, corner[1], corner[2])
    end
    
    -- Draw lock indicator (rotating ring when locked)
    if reticle.locked then
        love.graphics.push()
        love.graphics.translate(reticle.x, reticle.y)
        love.graphics.rotate(math.rad(reticle.rotation))
        love.graphics.setColor(0, 1, 0, 0.5)
        love.graphics.circle("line", 0, 0, reticle.size + 15)
        love.graphics.pop()
    end
end

-- Draw target information display
function TargetDisplay:drawTargetInfo(targetData, craftData)
    local margin = 15
    local lineHeight = 20
    
    -- Top-left corner target info
    love.graphics.setColor(0.2, 0.2, 0.2, 0.7)
    love.graphics.rectangle("fill", margin, margin, 250, 150)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", margin, margin, 250, 150)
    
    -- Target type and status
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("TARGET: " .. (targetData.type or "UNKNOWN"), margin + 10, margin + 5, 230, "left")
    
    local acquiredText = targetData.acquired and "ACQUIRED" or "TRACKING"
    local acquiredColor = targetData.acquired and {0, 1, 0} or {1, 1, 0}
    love.graphics.setColor(unpack(acquiredColor))
    love.graphics.printf(acquiredText, margin + 10, margin + 25, 230, "left")
    
    -- Target details
    local yPos = margin + 45
    local infoLines = {
        "Class: " .. (targetData.class or "UNKNOWN"),
        "Distance: " .. string.format("%.1f", targetData.distance / 1000) .. " km",
        "Bearing: " .. string.format("%.0f", targetData.bearing or 0) .. "°",
        "Speed: " .. (targetData.speed or 0) .. " kph"
    }
    
    love.graphics.setColor(0.7, 0.7, 0.7)
    for _, line in ipairs(infoLines) do
        love.graphics.printf(line, margin + 10, yPos, 230, "left")
        yPos = yPos + lineHeight
    end
end

-- Draw lead indicator (where to aim for moving target)
function TargetDisplay:drawLeadIndicator(targetData, craftData)
    if not targetData.speed or targetData.speed == 0 then return end
    
    -- Calculate lead point based on target velocity
    -- This is simplified - in reality would use ballistics
    local leadDistance = (targetData.speed / 100) * (targetData.distance / 1000)
    local leadX = self.centerX + math.cos(math.rad(targetData.bearing or 0)) * leadDistance * 0.5
    local leadY = self.centerY + math.sin(math.rad(targetData.bearing or 0)) * leadDistance * 0.5
    
    -- Clamp to screen bounds
    leadX = math.max(50, math.min(self.screenWidth - 50, leadX))
    leadY = math.max(50, math.min(self.screenHeight - 50, leadY))
    
    -- Draw lead indicator
    love.graphics.setColor(1, 0.5, 0, 0.6)
    love.graphics.circle("line", leadX, leadY, 15)
    love.graphics.line(leadX - 10, leadY, leadX + 10, leadY)
    love.graphics.line(leadX, leadY - 10, leadX, leadY + 10)
    
    -- Draw line from reticle to lead point
    love.graphics.setColor(1, 0.5, 0, 0.3)
    love.graphics.line(self.reticle.x, self.reticle.y, leadX, leadY)
    
    -- Lead prediction text
    love.graphics.setColor(1, 0.5, 0)
    love.graphics.printf("LEAD", leadX - 15, leadY - 25, 30, "center")
end

-- Draw distance rings for range reference
function TargetDisplay:drawDistanceRings()
    local center = {x = self.centerX, y = self.centerY}
    local ringCount = 3
    local maxRingDistance = 100 -- Represents 5000 meters per ring
    
    love.graphics.setColor(0.3, 0.3, 0.5, 0.3)
    
    for i = 1, ringCount do
        local radius = (maxRingDistance / ringCount) * i
        love.graphics.circle("line", center.x, center.y, radius)
        
        -- Distance labels
        love.graphics.setColor(0.4, 0.4, 0.6)
        local distance = (5000 / ringCount) * i
        love.graphics.printf(distance .. "m", center.x + radius - 15, center.y - 10, 30, "center")
        love.graphics.setColor(0.3, 0.3, 0.5, 0.3)
    end
end

-- Update target display with combat state
function TargetDisplay:update(targetData, craftData, deltaTime)
    if not targetData then return end
    
    -- Update tracking state
    if targetData.distance < 3000 then
        self.reticle.rotationSpeed = 3 -- Faster rotation when close
    else
        self.reticle.rotationSpeed = 2
    end
    
    -- Update target position (would track actual relative coordinates)
    self.target.distance = targetData.distance or 0
    self.target.relativeAltitude = (targetData.altitude or 0) - (craftData.altitude or 0)
    
    -- Calculate intercept probability
    self.target.interceptProbability = self:calculateInterceptProbability(targetData, craftData)
end

-- Calculate probability of successful interception
function TargetDisplay:calculateInterceptProbability(targetData, craftData)
    local probability = 0.5 -- Base 50%
    
    -- Distance factor (closer = better)
    local distanceFactor = 1 - math.min(1, targetData.distance / 10000)
    probability = probability + (distanceFactor * 0.2)
    
    -- Altitude advantage (altitude difference in our favor)
    local altitudeDiff = (craftData.altitude or 0) - (targetData.altitude or 0)
    local altitudeFactor = math.min(1, math.abs(altitudeDiff) / 5000)
    probability = probability + (altitudeFactor * 0.15)
    
    -- Lock strength
    probability = probability + (self.reticle.lockStrength * 0.15)
    
    return math.min(1, probability)
end

-- Get hit probability at current range and conditions
function TargetDisplay:getHitProbability(weapon, targetData)
    local baseProbability = weapon.accuracy or 0.7
    
    -- Range modifier
    local rangeModifier = 1.0
    if targetData.distance > weapon.maxRange then
        rangeModifier = 0.3
    elseif targetData.distance > weapon.maxRange * 0.7 then
        rangeModifier = 0.7
    elseif targetData.distance < weapon.maxRange * 0.3 then
        rangeModifier = 1.0 -- Optimal range
    end
    
    -- Lock strength modifier
    local lockModifier = self.reticle.lockStrength
    
    -- Final probability
    return math.min(1, baseProbability * rangeModifier * lockModifier)
end

-- Check if target is in valid firing arc
function TargetDisplay:isTargetInFiringArc(weaponArc)
    -- Simplified - check if target is within weapon's firing cone
    local targetAngle = math.atan2(self.centerY - self.reticle.y, self.centerX - self.reticle.x)
    local weaponAngle = math.rad(weaponArc.heading or 0)
    
    local angleDiff = math.abs(targetAngle - weaponAngle)
    if angleDiff > math.pi then
        angleDiff = 2 * math.pi - angleDiff
    end
    
    return angleDiff <= math.rad(weaponArc.spread or 30)
end

return TargetDisplay

