# Task: Mission Detection & Campaign Loop System

**Status:** TODO  
**Priority:** High  
**Created:** October 13, 2025  
**Completed:** N/A  
**Assigned To:** AI Agent

---

## Overview

Implement the core campaign game loop where missions are generated weekly, hidden by cover mechanics, and detected by player bases/crafts using radar systems. This creates strategic tension between expanding radar coverage and deploying interception forces.

---

## Purpose

The mission detection system is fundamental to gameplay flow. Players must:
1. Build/deploy radar coverage to find hidden missions
2. Decide which missions to intercept
3. Balance between detection (bases) and interception (crafts)

This creates strategic depth around base placement, craft deployment, and resource allocation.

---

## Requirements

### Functional Requirements
- [ ] Weekly mission generation (every Monday/Day 1)
- [ ] Missions spawn hidden with cover value
- [ ] Cover regenerates daily at configurable rate
- [ ] Bases and crafts scan for missions each turn (daily)
- [ ] Radar power vs. mission cover determines detection
- [ ] Detected missions appear on Geoscape map
- [ ] Missions have lifecycle: spawn → active → expire/completed
- [ ] Mission types: Site (land), UFO (air/land), Base (underground/underwater)
- [ ] Different biomes affect mission properties
- [ ] Save/load mission state and cover values

### Technical Requirements
- [ ] Campaign manager in `engine/geoscape/systems/campaign_manager.lua`
- [ ] Mission detection system in `engine/geoscape/systems/detection_manager.lua`
- [ ] Mission data structure with cover mechanics
- [ ] Radar scanning algorithm (range + power checks)
- [ ] Turn processing (1 turn = 1 day)
- [ ] Integration with Geoscape world/provinces
- [ ] Mission UI display on map
- [ ] Performance: O(n) scan per base/craft, where n = active missions

### Acceptance Criteria
- [ ] Missions spawn on schedule (weekly)
- [ ] Hidden missions not visible until detected
- [ ] Radar scanning reveals missions based on power/range
- [ ] Cover regenerates correctly each turn
- [ ] Multiple bases/crafts combine radar coverage
- [ ] Missions expire after X days if not intercepted
- [ ] Console shows mission generation and detection events
- [ ] UI displays mission icons on Geoscape when detected
- [ ] Performance: <5ms for full radar scan per turn

---

## Plan

### Step 1: Mission Data Structure (4 hours)
**Description:** Define mission entity with all properties including cover mechanics  
**Files to create:**
- `engine/geoscape/logic/mission.lua` - Mission entity class

**Implementation:**
```lua
local Mission = {}
Mission.__index = Mission

function Mission:new(config)
    local self = setmetatable({}, Mission)
    
    -- Identity
    self.id = config.id or generateMissionId()
    self.type = config.type  -- "site", "ufo", "base"
    self.faction = config.faction
    self.name = config.name or self:generateName()
    
    -- Location
    self.province = config.province  -- Province where mission is located
    self.position = config.position  -- {x, y} within province or world
    self.biome = config.biome  -- Affects mission properties
    
    -- Mission properties
    self.difficulty = config.difficulty or 1
    self.power = config.power or 100  -- Mission strength
    self.rewards = config.rewards or {}
    self.duration = config.duration or 14  -- Days until expiration
    
    -- Cover mechanics (detection)
    self.coverValue = config.coverValue or 100  -- 0-100, mission hidden if > 0
    self.coverMax = config.coverMax or 100
    self.coverRegen = config.coverRegen or 5  -- Points per day
    self.coverDecayRate = config.coverDecayRate or 10  -- When scanned
    
    -- State
    self.state = "hidden"  -- "hidden", "detected", "active", "completed", "expired"
    self.detected = false
    self.daysActive = 0
    self.spawnDay = config.spawnDay or 0
    self.detectedDay = nil
    
    -- Interception properties (for UFOs)
    self.altitude = config.altitude or "land"  -- "air", "land", "underground", "underwater"
    self.speed = config.speed or 0
    self.isMoving = config.isMoving or false
    
    -- Combat properties (for interception screen)
    self.health = config.health or 100
    self.maxHealth = config.maxHealth or 100
    self.weapons = config.weapons or {}
    self.inventory = config.inventory or {}
    self.ap = 4  -- Action points (like crafts/bases)
    self.energy = 100
    self.maxEnergy = 100
    
    return self
end

function Mission:update(daysPassed)
    self.daysActive = self.daysActive + daysPassed
    
    -- Regenerate cover if not detected
    if self.state == "hidden" then
        self.coverValue = math.min(self.coverMax, self.coverValue + (self.coverRegen * daysPassed))
    end
    
    -- Expire mission if too old
    if self.daysActive >= self.duration then
        self:expire()
    end
end

function Mission:reduceCover(radarPower)
    self.coverValue = math.max(0, self.coverValue - radarPower)
    
    if self.coverValue <= 0 and not self.detected then
        self:onDetected()
    end
end

function Mission:onDetected()
    self.detected = true
    self.state = "detected"
    self.detectedDay = currentGameDay
    print(string.format("[Mission] %s detected! Type: %s, Difficulty: %d", 
        self.name, self.type, self.difficulty))
end

function Mission:expire()
    self.state = "expired"
    print(string.format("[Mission] %s expired after %d days", self.name, self.daysActive))
end

function Mission:getIcon()
    -- Return icon name based on type and altitude
    if self.type == "ufo" then
        if self.altitude == "air" then
            return "ufo_air"
        else
            return "ufo_landed"
        end
    elseif self.type == "site" then
        return "alien_site"
    elseif self.type == "base" then
        if self.altitude == "underground" then
            return "alien_base_under"
        else
            return "alien_base_water"
        end
    end
    return "mission_unknown"
end

return Mission
```

**Estimated time:** 4 hours

### Step 2: Campaign Manager - Mission Generation (6 hours)
**Description:** Create campaign manager that generates weekly missions  
**Files to create:**
- `engine/geoscape/systems/campaign_manager.lua` - Main campaign loop

**Implementation:**
```lua
local CampaignManager = {}

function CampaignManager:init()
    self.currentDay = 1
    self.currentWeek = 1
    self.currentMonth = 1
    self.currentYear = 1
    
    self.activeMissions = {}  -- All active missions
    self.completedMissions = {}
    self.expiredMissions = {}
    
    self.missionIdCounter = 1
    
    print("[Campaign] Campaign started on Day 1")
end

function CampaignManager:advanceDay()
    self.currentDay = self.currentDay + 1
    
    -- Update week/month/year
    if (self.currentDay - 1) % 7 == 0 then
        self.currentWeek = self.currentWeek + 1
    end
    if (self.currentDay - 1) % 30 == 0 then
        self.currentMonth = self.currentMonth + 1
    end
    if (self.currentDay - 1) % 365 == 0 then
        self.currentYear = self.currentYear + 1
    end
    
    print(string.format("[Campaign] Day %d (Week %d, Month %d, Year %d)", 
        self.currentDay, self.currentWeek, self.currentMonth, self.currentYear))
    
    -- Update all missions
    for _, mission in ipairs(self.activeMissions) do
        mission:update(1)
    end
    
    -- Generate weekly missions on Monday (day % 7 == 1)
    if (self.currentDay - 1) % 7 == 0 then
        self:generateWeeklyMissions()
    end
    
    -- Clean up expired/completed missions
    self:cleanupMissions()
end

function CampaignManager:generateWeeklyMissions()
    print(string.format("[Campaign] Generating missions for Week %d", self.currentWeek))
    
    -- Get all active factions
    local factions = FactionManager:getActiveFactions()
    
    local newMissions = {}
    
    for _, faction in ipairs(factions) do
        local relationValue = RelationsManager:getRelation("faction", faction.id)
        local missionCount = self:calculateMissionCount(faction, relationValue)
        
        for i = 1, missionCount do
            local mission = self:createMissionForFaction(faction, relationValue)
            table.insert(self.activeMissions, mission)
            table.insert(newMissions, mission)
        end
    end
    
    print(string.format("[Campaign] Generated %d new missions", #newMissions))
    
    return newMissions
end

function CampaignManager:calculateMissionCount(faction, relationValue)
    -- Based on relations (see Relations System task)
    if relationValue >= 75 then
        return 0  -- Allied: no missions
    elseif relationValue >= 50 then
        return 1
    elseif relationValue >= 25 then
        return math.random(1, 2)
    elseif relationValue >= -24 then
        return math.random(2, 3)
    elseif relationValue >= -49 then
        return math.random(3, 4)
    elseif relationValue >= -74 then
        return math.random(4, 5)
    else
        return math.random(5, 7)  -- War: maximum missions
    end
end

function CampaignManager:createMissionForFaction(faction, relationValue)
    local missionType = self:selectMissionType(faction)
    local province = self:selectProvinceForMission(faction)
    local difficulty = self:calculateDifficulty(faction, relationValue)
    local power = self:calculateMissionPower(faction, relationValue, difficulty)
    
    local mission = Mission:new({
        type = missionType,
        faction = faction,
        province = province,
        biome = province.biome,
        difficulty = difficulty,
        power = power,
        spawnDay = self.currentDay,
        
        -- Cover mechanics
        coverValue = 100,
        coverMax = 100,
        coverRegen = self:getCoverRegen(missionType),
        
        -- Duration
        duration = self:getMissionDuration(missionType),
        
        -- Type-specific properties
        altitude = self:getMissionAltitude(missionType, province),
        health = power * 10,
        maxHealth = power * 10,
    })
    
    print(string.format("[Campaign] Created %s mission: %s (Difficulty: %d, Power: %d)", 
        missionType, mission.name, difficulty, power))
    
    return mission
end

function CampaignManager:selectMissionType(faction)
    local roll = math.random()
    
    -- Configurable mission type probabilities
    if roll < 0.5 then
        return "site"  -- 50%: Alien site (land-based)
    elseif roll < 0.85 then
        return "ufo"   -- 35%: UFO (air or landed)
    else
        return "base"  -- 15%: Alien base (underground/underwater)
    end
end

function CampaignManager:selectProvinceForMission(faction)
    -- Select random province from world
    local provinces = World:getProvinces()
    return provinces[math.random(1, #provinces)]
end

function CampaignManager:calculateDifficulty(faction, relationValue)
    local baseDifficulty = faction.baseDifficulty or 1
    local weekModifier = math.floor(self.currentWeek / 4)  -- +1 difficulty every 4 weeks
    local relationModifier = self:getRelationDifficultyModifier(relationValue)
    
    local difficulty = baseDifficulty + weekModifier + relationModifier
    return math.max(1, difficulty)
end

function CampaignManager:calculateMissionPower(faction, relationValue, difficulty)
    local basePower = faction.basePower or 100
    local powerModifier = 1.0
    
    -- Relations affect power (see Relations System task)
    if relationValue >= 50 then
        powerModifier = 0.5
    elseif relationValue >= 25 then
        powerModifier = 0.75
    elseif relationValue >= -49 then
        powerModifier = 1.25
    elseif relationValue >= -74 then
        powerModifier = 1.5
    else
        powerModifier = 2.0
    end
    
    local power = basePower * difficulty * powerModifier
    return math.floor(power)
end

function CampaignManager:getCoverRegen(missionType)
    -- Different mission types have different cover regeneration
    if missionType == "base" then
        return 10  -- Bases are well-hidden
    elseif missionType == "ufo" and mission.altitude == "air" then
        return 3   -- Flying UFOs easier to detect
    else
        return 5   -- Default
    end
end

function CampaignManager:getMissionDuration(missionType)
    -- How long mission stays active before expiring
    if missionType == "base" then
        return 30  -- Bases last 30 days
    elseif missionType == "site" then
        return 14  -- Sites last 2 weeks
    else
        return 7   -- UFOs last 1 week
    end
end

function CampaignManager:getMissionAltitude(missionType, province)
    if missionType == "ufo" then
        -- UFOs can be in air or landed
        return math.random() < 0.5 and "air" or "land"
    elseif missionType == "base" then
        -- Bases underground or underwater
        return province:isWater() and "underwater" or "underground"
    else
        -- Sites are always on land
        return "land"
    end
end

function CampaignManager:cleanupMissions()
    -- Remove completed and expired missions from active list
    local activeMissions = {}
    
    for _, mission in ipairs(self.activeMissions) do
        if mission.state == "expired" then
            table.insert(self.expiredMissions, mission)
        elseif mission.state == "completed" then
            table.insert(self.completedMissions, mission)
        else
            table.insert(activeMissions, mission)
        end
    end
    
    self.activeMissions = activeMissions
end

function CampaignManager:getMission(missionId)
    for _, mission in ipairs(self.activeMissions) do
        if mission.id == missionId then
            return mission
        end
    end
    return nil
end

function CampaignManager:getDetectedMissions()
    local detected = {}
    for _, mission in ipairs(self.activeMissions) do
        if mission.detected then
            table.insert(detected, mission)
        end
    end
    return detected
end

return CampaignManager
```

**Estimated time:** 6 hours

### Step 3: Detection Manager - Radar Scanning (7 hours)
**Description:** Implement radar scanning system for bases and crafts  
**Files to create:**
- `engine/geoscape/systems/detection_manager.lua` - Radar scanning logic

**Implementation:**
```lua
local DetectionManager = {}

function DetectionManager:init()
    self.scanHistory = {}  -- Track what was scanned when
    self.debugMode = false
end

-- Called once per turn (daily) to scan for missions
function DetectionManager:performDailyScans()
    print("[Detection] Performing daily radar scans...")
    
    local scansPerformed = 0
    local missionsDetected = 0
    
    -- Scan from all player bases
    local bases = BaseManager:getBases()
    for _, base in ipairs(bases) do
        local detected = self:scanFromBase(base)
        scansPerformed = scansPerformed + 1
        missionsDetected = missionsDetected + detected
    end
    
    -- Scan from all player crafts
    local crafts = CraftManager:getCrafts()
    for _, craft in ipairs(crafts) do
        local detected = self:scanFromCraft(craft)
        scansPerformed = scansPerformed + 1
        missionsDetected = missionsDetected + detected
    end
    
    print(string.format("[Detection] Scans: %d, Missions detected: %d", 
        scansPerformed, missionsDetected))
end

function DetectionManager:scanFromBase(base)
    local radarPower = self:getBaseRadarPower(base)
    local radarRange = self:getBaseRadarRange(base)
    
    if radarPower == 0 or radarRange == 0 then
        return 0  -- No radar facilities
    end
    
    return self:performScan(base.province, radarPower, radarRange, "base")
end

function DetectionManager:scanFromCraft(craft)
    local radarPower = self:getCraftRadarPower(craft)
    local radarRange = self:getCraftRadarRange(craft)
    
    if radarPower == 0 or radarRange == 0 then
        return 0  -- No radar equipment
    end
    
    return self:performScan(craft.province, radarPower, radarRange, "craft")
end

function DetectionManager:performScan(scannerProvince, radarPower, radarRange, scannerType)
    local missionsDetected = 0
    local activeMissions = CampaignManager:getActiveMissions()
    
    for _, mission in ipairs(activeMissions) do
        -- Skip already detected missions
        if not mission.detected then
            -- Check if mission is in range
            local distance = self:calculateDistance(scannerProvince, mission.province)
            
            if distance <= radarRange then
                -- Apply radar power to reduce cover
                local coverReduction = self:calculateCoverReduction(radarPower, distance, radarRange)
                mission:reduceCover(coverReduction)
                
                if mission.detected then
                    missionsDetected = missionsDetected + 1
                    
                    if self.debugMode then
                        print(string.format("[Detection] %s detected mission %s at distance %d", 
                            scannerType, mission.name, distance))
                    end
                end
            end
        end
    end
    
    return missionsDetected
end

function DetectionManager:calculateDistance(province1, province2)
    -- Calculate distance between provinces (province graph pathfinding)
    -- For now, simple Euclidean distance
    local dx = province1.x - province2.x
    local dy = province1.y - province2.y
    return math.sqrt(dx * dx + dy * dy)
end

function DetectionManager:calculateCoverReduction(radarPower, distance, maxRange)
    -- Radar effectiveness decreases with distance
    local effectiveness = 1.0 - (distance / maxRange)
    effectiveness = math.max(0, effectiveness)
    
    -- Cover reduction = radar power * effectiveness
    local reduction = radarPower * effectiveness
    
    return reduction
end

-- Base radar calculations
function DetectionManager:getBaseRadarPower(base)
    local totalPower = 0
    
    -- Sum power from all radar facilities
    for _, facility in ipairs(base.facilities) do
        if facility.type == "radar_small" then
            totalPower = totalPower + 20
        elseif facility.type == "radar_large" then
            totalPower = totalPower + 50
        elseif facility.type == "radar_hyperwave" then
            totalPower = totalPower + 100
        end
    end
    
    return totalPower
end

function DetectionManager:getBaseRadarRange(base)
    local maxRange = 0
    
    -- Take maximum range from all radar facilities
    for _, facility in ipairs(base.facilities) do
        if facility.type == "radar_small" then
            maxRange = math.max(maxRange, 5)  -- 5 provinces
        elseif facility.type == "radar_large" then
            maxRange = math.max(maxRange, 10)
        elseif facility.type == "radar_hyperwave" then
            maxRange = math.max(maxRange, 20)
        end
    end
    
    return maxRange
end

-- Craft radar calculations
function DetectionManager:getCraftRadarPower(craft)
    local totalPower = 0
    
    -- Sum power from radar equipment
    for _, item in ipairs(craft.equipment) do
        if item.type == "craft_radar_basic" then
            totalPower = totalPower + 10
        elseif item.type == "craft_radar_advanced" then
            totalPower = totalPower + 25
        end
    end
    
    return totalPower
end

function DetectionManager:getCraftRadarRange(craft)
    local maxRange = 0
    
    -- Take maximum range from radar equipment
    for _, item in ipairs(craft.equipment) do
        if item.type == "craft_radar_basic" then
            maxRange = math.max(maxRange, 3)  -- 3 provinces
        elseif item.type == "craft_radar_advanced" then
            maxRange = math.max(maxRange, 7)
        end
    end
    
    return maxRange
end

-- Debug visualization
function DetectionManager:drawRadarCoverage(province)
    -- Draw radar coverage circles on Geoscape map
    -- (Called from Geoscape rendering)
    
    if not self.debugMode then return end
    
    love.graphics.setColor(0, 255, 0, 50)
    
    -- Draw base radar ranges
    local bases = BaseManager:getBases()
    for _, base in ipairs(bases) do
        local range = self:getBaseRadarRange(base)
        if range > 0 then
            local x, y = self:provinceToScreenCoords(base.province)
            local radius = range * 10  -- Scale for visualization
            love.graphics.circle("fill", x, y, radius)
        end
    end
    
    -- Draw craft radar ranges
    local crafts = CraftManager:getCrafts()
    for _, craft in ipairs(crafts) do
        local range = self:getCraftRadarRange(craft)
        if range > 0 then
            local x, y = self:provinceToScreenCoords(craft.province)
            local radius = range * 10
            love.graphics.circle("fill", x, y, radius)
        end
    end
end

return DetectionManager
```

**Estimated time:** 7 hours

### Step 4: Geoscape Mission Display (4 hours)
**Description:** Display detected missions on Geoscape map  
**Files to modify:**
- `engine/geoscape/ui/geoscape_view.lua` - Add mission rendering

**Implementation:**
```lua
-- In GeoscapeView:draw()
function GeoscapeView:drawMissions()
    local detectedMissions = CampaignManager:getDetectedMissions()
    
    for _, mission in ipairs(detectedMissions) do
        self:drawMissionIcon(mission)
    end
end

function GeoscapeView:drawMissionIcon(mission)
    local x, y = self:provinceToScreenCoords(mission.province)
    
    -- Get icon based on mission type
    local icon = mission:getIcon()
    local iconImage = Assets:getImage("missions/" .. icon)
    
    -- Draw icon
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(iconImage, x - 16, y - 16)  -- Center icon
    
    -- Draw blinking effect if newly detected
    if mission.detectedDay == CampaignManager.currentDay then
        local alpha = (math.sin(love.timer.getTime() * 5) + 1) / 2
        love.graphics.setColor(255, 255, 0, alpha * 255)
        love.graphics.circle("line", x, y, 20)
    end
    
    -- Draw mission info on hover
    if self:isMouseOver(x, y, 32, 32) then
        self:drawMissionTooltip(mission, x, y)
    end
end

function GeoscapeView:drawMissionTooltip(mission, x, y)
    local tooltip = {
        string.format("Mission: %s", mission.name),
        string.format("Type: %s", mission.type),
        string.format("Faction: %s", mission.faction.name),
        string.format("Difficulty: %d", mission.difficulty),
        string.format("Days Active: %d / %d", mission.daysActive, mission.duration),
    }
    
    -- Draw tooltip panel
    local panelWidth = 240
    local panelHeight = #tooltip * 24 + 12
    local panelX = x + 40
    local panelY = y - panelHeight / 2
    
    love.graphics.setColor(0, 0, 0, 200)
    love.graphics.rectangle("fill", panelX, panelY, panelWidth, panelHeight)
    
    love.graphics.setColor(255, 255, 255)
    for i, line in ipairs(tooltip) do
        love.graphics.print(line, panelX + 6, panelY + (i - 1) * 24 + 6)
    end
end

-- Mission selection
function GeoscapeView:onMissionClick(mission)
    -- Open mission details panel or start interception
    if self.selectedCrafts and #self.selectedCrafts > 0 then
        -- Has crafts selected, offer to start interception
        self:showInterceptionConfirmDialog(mission)
    else
        -- Show mission details
        self:showMissionDetailsPanel(mission)
    end
end
```

**Estimated time:** 4 hours

### Step 5: Turn Processing & Calendar (3 hours)
**Description:** Integrate campaign manager with turn-based time system  
**Files to modify/create:**
- `engine/geoscape/systems/time_manager.lua` - Calendar and turn processing

**Implementation:**
```lua
local TimeManager = {}

function TimeManager:init()
    self.paused = false
    self.timeScale = 1  -- 1x, 2x, 4x speed
    self.dayLength = 5.0  -- Real-time seconds per game day
    self.dayProgress = 0.0
end

function TimeManager:update(dt)
    if self.paused then return end
    
    self.dayProgress = self.dayProgress + (dt * self.timeScale)
    
    if self.dayProgress >= self.dayLength then
        self.dayProgress = 0.0
        self:advanceDay()
    end
end

function TimeManager:advanceDay()
    print("[Time] Advancing to next day...")
    
    -- Advance campaign
    CampaignManager:advanceDay()
    
    -- Perform daily radar scans
    DetectionManager:performDailyScans()
    
    -- Update relations (decay)
    RelationsManager:updateAllRelations(1)
    
    -- Process base operations
    BaseManager:processDailyOperations()
    
    -- Update craft movements
    CraftManager:updateCraftMovements(1)
    
    -- Check for mission expirations
    self:checkMissionExpirations()
    
    print("[Time] Day complete")
end

function TimeManager:checkMissionExpirations()
    local expiredMissions = CampaignManager:getExpiredMissions()
    
    if #expiredMissions > 0 then
        -- Show notification to player
        for _, mission in ipairs(expiredMissions) do
            NotificationManager:add({
                type = "mission_expired",
                title = "Mission Expired",
                text = string.format("%s has expired", mission.name),
                icon = "warning"
            })
        end
    end
end

function TimeManager:pause()
    self.paused = true
    print("[Time] Game paused")
end

function TimeManager:resume()
    self.paused = false
    print("[Time] Game resumed")
end

function TimeManager:setTimeScale(scale)
    self.timeScale = scale
    print(string.format("[Time] Time scale: %dx", scale))
end

return TimeManager
```

**Estimated time:** 3 hours

### Step 6: Mission Configuration Data (3 hours)
**Description:** Create data files for mission generation configuration  
**Files to create:**
- `engine/data/mission_templates.lua` - Mission type templates
- `engine/data/faction_config.lua` - Faction mission behavior

**Estimated time:** 3 hours

### Step 7: Testing & Balancing (4 hours)
**Description:** Test mission generation, detection, and balance values  
**Files to create:**
- `engine/geoscape/tests/test_campaign.lua` - Campaign system tests
- `engine/geoscape/tests/test_detection.lua` - Detection system tests

**Test cases:**
- Weekly mission generation works
- Missions spawn with correct properties
- Cover regeneration works correctly
- Radar scanning reduces cover appropriately
- Multiple scanners combine coverage
- Missions expire after duration
- Performance with 50+ active missions

**Estimated time:** 4 hours

---

## Implementation Details

### Architecture
Mission detection follows a pull-based model: scanners (bases/crafts) actively scan for missions each turn. Missions are passive entities with cover values that decrease when scanned. This creates strategic gameplay around radar coverage.

### Key Components
- **CampaignManager:** Master controller for game time and mission lifecycle
- **DetectionManager:** Handles radar scanning and mission detection
- **Mission:** Entity with cover mechanics and state management
- **TimeManager:** Turn-based time progression (1 turn = 1 day)

### Dependencies
- World/Province system (for mission placement)
- Relations system (affects mission generation)
- Base system (provides radar facilities)
- Craft system (provides mobile radar)
- Geoscape UI (displays missions)

---

## Testing Strategy

### Unit Tests
- Mission creation and initialization
- Cover value calculations
- Radar power/range calculations
- Distance calculations
- Mission expiration logic
- Weekly generation timing

### Integration Tests
- Full campaign cycle (generate → detect → expire)
- Multiple bases scanning same mission
- Craft + base combined coverage
- Save/load preserves mission state
- UI updates when missions detected

### Manual Testing Steps
1. Start campaign, verify Day 1
2. Wait for Week 1 Monday, verify missions spawn
3. Build base with radar, verify scanning starts
4. Watch mission cover decrease in debug mode
5. Verify mission appears on map when detected
6. Advance time, verify cover regeneration
7. Let mission expire, verify removal
8. Deploy craft with radar, verify mobile scanning
9. Test multiple overlapping radar coverage
10. Save/load, verify all state preserved

### Expected Results
- Missions spawn every Monday
- Hidden missions gradually detected
- Radar coverage visible in debug mode
- No performance issues with many missions
- Console shows clear debug info

---

## How to Run/Debug

### Running the Game
```bash
lovec "engine"
```

### Debugging
```lua
-- Enable debug modes
CampaignManager.debugMode = true
DetectionManager.debugMode = true

-- Debug commands (add to test menu)
DebugCommands.advanceDay = function()
    TimeManager:advanceDay()
end

DebugCommands.spawnTestMission = function(missionType)
    local mission = CampaignManager:createTestMission(missionType)
    return mission
end

DebugCommands.detectAllMissions = function()
    local missions = CampaignManager:getActiveMissions()
    for _, mission in ipairs(missions) do
        mission.coverValue = 0
        mission:onDetected()
    end
end

DebugCommands.printMissionStatus = function()
    print("[Debug] Active Missions:")
    for _, mission in ipairs(CampaignManager:getActiveMissions()) do
        print(string.format("  %s: Cover=%d, State=%s, Days=%d", 
            mission.name, mission.coverValue, mission.state, mission.daysActive))
    end
end
```

### Console Output
```
[Campaign] Campaign started on Day 1
[Campaign] Day 7 (Week 1, Month 1, Year 1)
[Campaign] Generating missions for Week 1
[Campaign] Created site mission: Harvest Site Alpha (Difficulty: 2, Power: 150)
[Campaign] Created ufo mission: Scout UFO Beta (Difficulty: 1, Power: 100)
[Campaign] Generated 2 new missions
[Detection] Performing daily radar scans...
[Detection] base detected mission Scout UFO Beta at distance 4
[Detection] Scans: 2, Missions detected: 1
[Mission] Scout UFO Beta detected! Type: ufo, Difficulty: 1
```

---

## Documentation Updates

### Files to Update
- [x] `wiki/API.md` - Add CampaignManager and DetectionManager APIs
- [x] `wiki/FAQ.md` - Explain mission detection mechanics
- [x] `wiki/DEVELOPMENT.md` - Document turn processing flow
- [ ] `engine/geoscape/README.md` - Campaign loop overview
- [ ] Code comments - Inline documentation

---

## Notes

- Balance is critical: too much cover = frustrating, too little = no challenge
- Consider fog of war: missions might be detected but location fuzzy
- Future: mission intelligence gathering (spies, satellites, etc.)
- Future: mission types with special detection requirements
- Consider player feedback: notifications when missions detected/expired

---

## Blockers

- Requires World/Province system to be functional
- Requires Base system with facilities
- Requires Craft system with equipment
- Requires Relations system (affects generation)

---

## Review Checklist

- [ ] Code follows Lua/Love2D best practices
- [ ] No global variables (all use `local`)
- [ ] Proper error handling with `pcall`
- [ ] Performance optimized (O(n) scans acceptable)
- [ ] Console debugging statements added
- [ ] Tests written and passing
- [ ] Documentation updated
- [ ] UI grid-aligned (24×24 pixels)
- [ ] Save/load tested
- [ ] Balance values reasonable

---

## Post-Completion

### What Worked Well
- (To be filled after completion)

### What Could Be Improved
- (To be filled after completion)

### Lessons Learned
- (To be filled after completion)
