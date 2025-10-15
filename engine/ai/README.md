# AI Systems

Artificial intelligence for tactical combat and strategic decisions.

## Overview

AI systems control enemy unit behavior in tactical combat, strategic UFO missions, and NPC decision-making.

## Architecture

```
engine/ai/
├── tactical/
│   └── decision_system.lua     -- Tactical combat AI
├── pathfinding/
│   ├── pathfinding.lua         -- General A* pathfinding
│   └── tactical_pathfinding.lua -- Combat movement AI
└── README.md                   -- This file
```

## Tactical AI

### Decision System
Controls alien/enemy unit actions during combat.

**Behavior Modes:**
- **Aggressive**: Seeks combat, closes distance
- **Defensive**: Takes cover, suppressive fire
- **Flanking**: Attempts to flank player units
- **Retreat**: Falls back when wounded
- **Panic**: Random movement when morale breaks

**Decision Tree:**
1. Threat Assessment - Identify dangerous targets
2. Positioning - Find optimal tile (cover, flanking, line of sight)
3. Action Selection - Choose attack, move, or special ability
4. Execution - Perform selected action

**Usage:**
```lua
local DecisionSystem = require("ai.tactical.decision_system")

-- AI unit's turn
function processTurn(aiUnit, battlefield)
    local decision = DecisionSystem.makeDecision(aiUnit, battlefield)
    
    if decision.action == "move" then
        aiUnit:moveTo(decision.targetTile)
    elseif decision.action == "attack" then
        aiUnit:attack(decision.target)
    elseif decision.action == "overwatch" then
        aiUnit:enterOverwatch()
    end
end
```

### Tactical Pathfinding
Finds optimal movement paths considering threats.

**Features:**
- Avoid visible enemy fire lanes
- Prefer covered routes
- Respect TU limits
- Dynamic threat assessment

**Usage:**
```lua
local TacticalPathfinding = require("ai.pathfinding.tactical_pathfinding")

-- Find safe path
local path = TacticalPathfinding.findSafePath(
    unit,
    targetX, targetY,
    battlefield,
    {avoidThreats = true, preferCover = true}
)
```

## AI Behaviors

### Aggressive AI
```lua
-- Chryssalid behavior: Rush closest target
function AggressiveAI:selectAction(unit, battlefield)
    local closestEnemy = self:findClosestEnemy(unit, battlefield)
    local path = self:findFastestPath(unit.position, closestEnemy.position)
    
    return {
        action = "move",
        path = path,
        priority = 10
    }
end
```

### Defensive AI
```lua
-- Sectoid behavior: Take cover, mind control from distance
function DefensiveAI:selectAction(unit, battlefield)
    if unit.hp < unit.maxHp * 0.5 then
        -- Wounded: find best cover
        local coverTile = self:findBestCover(unit, battlefield)
        return {action = "move", target = coverTile}
    else
        -- Healthy: use abilities
        local target = self:selectPsionicTarget(unit, battlefield)
        return {action = "mindControl", target = target}
    end
end
```

### Flanking AI
```lua
-- Muton behavior: Flank player positions
function FlankingAI:selectAction(unit, battlefield)
    local targets = self:getVisibleEnemies(unit, battlefield)
    
    for _, target in ipairs(targets) do
        local flankPosition = self:findFlankingPosition(target, battlefield)
        if flankPosition then
            return {
                action = "move",
                target = flankPosition,
                followup = {action = "attack", target = target}
            }
        end
    end
    
    -- No flanking opportunity, advance
    return self:advanceToward(self:findClosestEnemy(unit, battlefield))
end
```

## Strategic AI (UFO Missions)

UFOs follow mission profiles:

**Scout Mission:**
- Patrol region looking for bases
- Report back to command
- Flee when intercepted

**Harvester Mission:**
- Land in rural areas
- Remain grounded for time
- Defend if discovered

**Terror Mission:**
- Attack population centers
- Maximize casualties
- Fight to destruction

## Integration

### From Battlescape
```lua
-- Enemy turn processing
function Battlescape:processAITurn()
    for _, unit in ipairs(self:getActiveAIUnits()) do
        local decision = DecisionSystem.makeDecision(unit, self.battlefield)
        self:executeAction(unit, decision)
    end
end
```

### Difficulty Scaling
```lua
-- AI intelligence scales with difficulty
function DecisionSystem.makeDecision(unit, battlefield)
    local intelligence = game.difficulty * 0.2  -- 0.2 to 1.0
    
    if math.random() < intelligence then
        -- Smart decision (optimal play)
        return self:calculateOptimalAction(unit, battlefield)
    else
        -- Random/suboptimal action
        return self:getRandomValidAction(unit)
    end
end
```

## Future Enhancements

- [ ] Machine learning for adaptive AI
- [ ] Team coordination (squads)
- [ ] Dynamic difficulty adjustment
- [ ] Personality-based behavior
- [ ] Strategic layer AI (UFO command)

## See Also

- [Battlescape README](../battlescape/README.md) - Tactical combat
- [Pathfinding System](../shared/pathfinding.lua) - General pathfinding
- [Decision Trees](../../wiki/AI_DECISION_TREES.md) - AI logic diagrams
