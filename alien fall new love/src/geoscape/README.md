# Geoscape Directory - Strategic World Management

## Overview

The `geoscape/` directory contains systems that manage the strategic world view of Alien Fall. These systems handle UFO activity, mission generation, and global strategic elements that occur on the world map.

## Core Geoscape Systems

### UFO Management System

#### `ufo_system.lua`

**Purpose**: UFO spawning, movement, and interception management

- UFO generation and behavior
- Flight path calculations
- Interception mechanics
- Crash site generation

**GROK**: UFO AI - modify behavior patterns and spawn rates for different difficulty levels

## Geoscape Architecture

### UFO Lifecycle Management

UFOs follow complete lifecycle from spawn to crash/destruction:

```lua
UFOSystem = class(System)

function UFOSystem:initialize()
    self.activeUFOs = {}
    self.crashSites = {}
    self.spawnTimer = 0
end

function UFOSystem:update(dt)
    self:spawnNewUFOs(dt)
    self:updateUFOs(dt)
    self:checkInterceptions()
    self:generateMissions()
end
```

### UFO Behavior Patterns

UFOs have different behavior types:

```lua
function UFOSystem:createUFO(ufoType, startPosition)
    local ufo = {
        id = self:generateUFOId(),
        type = ufoType,
        position = startPosition,
        destination = self:calculateDestination(startPosition),
        speed = self:getUFOTypeSpeed(ufoType),
        behavior = self:getUFOTypeBehavior(ufoType),
        detected = false
    }

    table.insert(self.activeUFOs, ufo)
    return ufo
end
```

### Mission Generation

UFO activity triggers mission creation:

```lua
function UFOSystem:generateMissions()
    for _, ufo in ipairs(self.activeUFOs) do
        if self:shouldGenerateMission(ufo) then
            local missionType = self:determineMissionType(ufo)
            local mission = self:createMission(missionType, ufo.position)
            missionSystem:addMission(mission)
        end
    end
end
```

### Interception Mechanics

Aircraft can intercept UFOs:

```lua
function UFOSystem:attemptInterception(craft, targetUFO)
    local interceptionChance = self:calculateInterceptionChance(craft, targetUFO)

    if math.random() < interceptionChance then
        -- Successful interception
        self:handleSuccessfulInterception(craft, targetUFO)
    else
        -- Failed interception
        self:handleFailedInterception(craft, targetUFO)
    end
end
```

## Strategic AI Integration

### UFO Strategic Behavior

UFOs make strategic decisions:

```lua
function UFOAI:decideAction(ufo)
    local options = self:getAvailableActions(ufo)

    -- Evaluate each option
    local bestAction = nil
    local bestScore = -math.huge

    for _, action in ipairs(options) do
        local score = self:evaluateAction(ufo, action)
        if score > bestScore then
            bestScore = score
            bestAction = action
        end
    end

    return bestAction
end
```

### Threat Assessment

UFOs respond to XCOM activity:

```lua
function UFOAI:assessThreatLevel()
    local threatLevel = 0

    -- Count active XCOM craft
    threatLevel = threatLevel + #xcomCraftSystem:getActiveCraft() * 0.1

    -- Count completed research
    threatLevel = threatLevel + researchSystem:getCompletedProjectCount() * 0.05

    -- Count destroyed UFOs
    threatLevel = threatLevel + self.destroyedUFOCount * 0.2

    return math.min(threatLevel, 1.0)
end
```

## Mission Types

### Crash Site Missions

Generated when UFOs are destroyed:

```lua
function MissionGenerator:createCrashSiteMission(ufoPosition)
    return {
        type = "crash_site",
        position = ufoPosition,
        objectives = {
            "recover_ufo_debris",
            "investigate_crash"
        },
        rewards = {
            alien_alloys = math.random(10, 50),
            research_points = math.random(100, 500)
        },
        difficulty = self:calculateDifficulty(ufoPosition)
    }
end
```

### Terror Missions

Alien attacks on population centers:

```lua
function MissionGenerator:createTerrorMission(targetCity)
    return {
        type = "terror",
        position = targetCity.position,
        objectives = {
            "protect_civilians",
            "eliminate_aliens"
        },
        consequences = {
            civilian_casualties = 0,
            funding_penalty = targetCity.population * 10
        }
    }
end
```

## Performance Optimization

### UFO Culling

Only track relevant UFOs:

```lua
function UFOSystem:updateUFOs(dt)
    for i = #self.activeUFOs, 1, -1 do
        local ufo = self.activeUFOs[i]

        -- Update position
        self:updateUFOPosition(ufo, dt)

        -- Remove if off-map or destroyed
        if self:isUFOOffMap(ufo) or ufo.destroyed then
            table.remove(self.activeUFOs, i)
        end
    end
end
```

### Mission Throttling

Limit simultaneous missions:

```lua
function MissionSystem:canGenerateNewMission(missionType)
    local activeMissions = self:getActiveMissionsByType(missionType)
    local maxConcurrent = self:getMaxConcurrentMissions(missionType)

    return #activeMissions < maxConcurrent
end
```

## Testing Strategy

### UFO Behavior Testing

UFO systems tested for correct behavior:

- Spawn rate validation
- Movement path accuracy
- Interception success rates
- Mission generation triggers

### Strategic Balance Testing

Geoscape systems tested for balance:

- Threat progression
- Mission difficulty scaling
- Resource reward balance
- AI decision quality

## Development Guidelines

### Adding New UFO Types

1. **GROK**: Define UFO characteristics in data files
2. **GROK**: Implement behavior logic in UFOAI
3. **GROK**: Add appropriate mission generation
4. **GROK**: Balance interception difficulty
5. **GROK**: Test spawn rates and patterns

### Mission Balance

- **GROK**: Ensure mission rewards match difficulty
- **GROK**: Balance mission frequency
- **GROK**: Test mission completion rates
- **GROK**: Validate strategic impact

### AI Behavior Tuning

- **GROK**: Adjust UFO decision weights
- **GROK**: Tune threat response curves
- **GROK**: Balance aggression levels
- **GROK**: Test long-term behavior patterns