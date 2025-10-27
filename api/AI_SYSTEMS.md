# AI Systems API Reference

**System:** Strategic & Tactical AI  
**Module:** `engine/ai/`  
**Latest Update:** October 22, 2025  
**Status:** ✅ Complete

---

## Overview

The AI system governs enemy decision-making, strategic planning, and tactical behavior across all difficulty levels. It includes strategic AI for UFO movements and alien campaigns, and tactical AI for individual unit combat decisions. The system is deterministic, transparent, and balanced for different difficulty levels, ensuring challenging but fair gameplay.

**Layer Classification:** Strategic & Tactical  
**Primary Responsibility:** Enemy strategies, unit AI, decision-making, difficulty scaling, threat assessment, pathfinding, behavior trees  
**Integration Points:** Geoscape (UFO AI), Battlescape (combat AI), Interception (craft AI)

---

## Implementation Status

### ✅ Implemented (in engine/ai/)

**Strategic AI Systems (`engine/ai/strategic/`)**
- **Alien Director**: Strategic AI orchestrator managing campaign pressure, faction coordination, and mission generation
- **Faction Coordinator**: Multi-faction activity management with resource allocation and joint operations
- **Threat Manager**: Campaign pressure and difficulty scaling based on player performance and time progression

**Tactical AI Systems (`engine/ai/tactical/`)**
- **Decision System**: Tactical combat AI with threat assessment, target prioritization, and action selection
- **Pathfinding**: Navigation and tactical movement calculations

**Support AI Systems**
- **Strategic Planner**: Mission evaluation and resource-aware planning with multi-turn strategic goals
- **Threat Assessment**: Multi-factor combat threat evaluation with damage potential and positioning analysis
- **Squad Coordination**: Squad formations, unit roles (leader/heavy/medic/scout/support), and cohesion tracking
- **Resource Awareness**: Ammo, energy, and budget constraint evaluation for decision-making

### 🚧 Partially Implemented
- Machine learning-based adaptation
- Player behavior prediction
- Dynamic difficulty adjustment

### 📋 Planned
- Advanced learning AI
- Emergent behavior systems
- Procedural strategy generation

---

## Core Entities

### Entity: AIStrategy

High-level AI decision framework defining alien campaign approach.

**Properties:**
```lua
AIStrategy = {
  id = string,                    -- "aggressive_assault"
  name = string,                  -- Strategy name
  type = string,                  -- "aggressive", "defensive", "evasive", "infiltration"
  
  -- Behavior
  priority_objectives = string[], -- Goal hierarchy
  resource_commitment = number,   -- 0-100 (how many forces deployed)
  aggressiveness = number,        -- 0-100 (attack vs defend ratio)
  
  -- Tactics
  preferred_tactics = string[],   -- Available approaches
  terrain_preference = string,    -- Terrain types favored
  
  -- Adaptation
  adapts_to_losses = boolean,    -- Changes strategy after defeats
  learning_rate = number,        -- How quickly adapts
}
```

---

### Entity: AIBehavior

Behavioral template defining personality and decision weights for individual units.

**Properties:**
```lua
AIBehavior = {
  id = string,                    -- "aggressive", "defensive", "tactical"
  name = string,
  
  -- Personality
  aggression = number,            -- 0.0-1.0 (likelihood to attack)
  caution = number,               -- 0.0-1.0 (defensive tendency)
  tactical = number,              -- 0.0-1.0 (uses cover/positioning)
  
  -- Thresholds
  threat_threshold = number,      -- When to engage (distance)
  retreat_threshold = number,     -- When to fall back (HP %)
  
  -- Decision weights
  priority_weights = {
    attack = number,              -- 0.0-1.0
    defense = number,
    movement = number,
    group_up = number,
  },
  
  -- Tactics
  preferred_range = string,       -- "close", "medium", "long"
  use_cover = bool,
  use_overwatch = bool,
  coordinate_squad = bool,
}
```

---

### Entity: TacticalAI

Individual unit decision-making system tracking threats and tactical memory.

**Properties:**
```lua
TacticalAI = {
  id = string,                    -- Per-unit AI
  unit = Unit,                    -- Associated unit
  
  -- Decision Making
  priority_targets = Unit[],      -- Target preference order
  current_target = Unit | nil,    -- Active target
  
  -- Behavior State
  current_action = string,        -- "attacking", "defending", "flanking", "retreating"
  confidence = number,            -- 0-100 (likelihood of aggression)
  
  -- Tactical Memory
  spotted_enemies = Unit[],       -- Known hostiles
  dangerous_positions = Hex[],    -- Avoid locations
  safe_positions = Hex[],         -- Retreat destinations
  
  -- Experience
  engagement_history = table,     -- Previous encounters
  learned_tactics = string[],     -- Adapted approaches
}
```

---

### Entity: ThreatAssessment

Evaluates current battlefield threats and tactical situation.

**Properties:**
```lua
ThreatAssessment = {
  unit = BattleUnit,
  threats = Threat[],             -- Ranked by danger
  
  -- Overall assessment
  threat_level = number,          -- 0-100
  immediate_danger = bool,        -- < 2 tiles away?
  squad_cohesion = number,        -- 0-100
  
  -- Tactical info
  best_cover_position = HexCoordinate | nil,
  best_attack_position = HexCoordinate | nil,
  enemy_count_nearby = number,
}
```

**Functions:**
```lua
AISystem.assessThreat(unit: Unit) → ThreatAssessment
AISystem.calculateDanger(threat: Threat, from: Unit) → number  -- 0-100
threat:getLevel() → number
threat:getDistance() → number
threat:getTarget() → BattleUnit
threat:getLastSeenPosition() → HexCoordinate
```

---

### Entity: TargetPriority

Ranking of potential targets with scoring factors.

**Properties:**
```lua
TargetPriority = {
  target = BattleUnit,
  priority = number,              -- 0-100
  
  -- Scoring factors
  threat_level = number,
  distance = number,
  visibility = bool,
  alignment = number,             -- Attack priority vs defensive
}
```

---

### Entity: AIDecision

Single turn decision framework with options and selected action.

**Properties:**
```lua
AIDecision = {
  unit = Unit,
  action_type = string,           -- "move", "attack", "ability", "retreat"
  
  -- Options
  available_actions = table[],    -- Evaluated choices
  best_action = table,            -- Selected option
  decision_score = number,        -- Quality 0-100
  
  -- Reasoning
  factors = table,                -- {factor: weight}
  threat_level = number,          -- Perceived danger
  opportunity_level = number,     -- Offensive potential
  
  -- Execution
  target = BattleUnit | HexCoordinate,
  priority = number,              -- 0-100
  required_ap = number,
  success_probability = number,   -- 0-1.0
}
```

**Functions:**
```lua
decision:getActionType() → string
decision:getTarget() → BattleUnit | HexCoordinate
decision:execute() → (success, result)
decision:isValid() → bool
```

---

### Entity: Squad

Grouped enemy units with coordination and cohesion.

**Properties:**
```lua
Squad = {
  units = BattleUnit[],
  leader = BattleUnit,
  
  -- Coordination
  cohesion = number,              -- 0-100
  formation = string,             -- "wedge", "line", "circle"
  objective = string,             -- "attack", "defend", "retreat"
}
```

**Functions:**
```lua
AISystem.createSquad(units: Unit[]) → Squad
AISystem.coordinateSquad(squad: Squad, objectives: string[]) → Decision[]
squad:getFormation() → string
squad:setFormation(formation: string) → void
squad:getObjective() → string
squad:getCoordinator() → BattleUnit  -- Who decides?
squad:getCohesion() → number
```

---

### Entity: DecisionTree

Hierarchical AI decision making system for behavioral control.

**Properties:**
```lua
DecisionTree = {
  nodes = DecisionNode[],         -- Tree structure
  root = DecisionNode,
}
```

**Decision Hierarchy:**
```
Root
├─ Can Act?
│  ├─ Yes: Threat Assessment
│  │  ├─ Imminent Threat: Combat Decision
│  │  │  ├─ Can Attack: Execute Attack
│  │  │  └─ Cannot Attack: Move to Position
│  │  └─ Low Threat: Exploration
│  └─ No: End Turn
└─ Special Actions
   ├─ Reload?
   ├─ Use Ability?
   └─ Retreat?
```

---

## Services & Functions

### Strategic AI Service

```lua
-- Strategy management
StrategicAI.getAlienStrategy() → AIStrategy
StrategicAI.selectStrategy(threat_level: number, resources: number) → AIStrategy
StrategicAI.updateStrategy(performance: number) → void

-- Planning
StrategicAI.planCampaignPhase(phase: number) → table (objectives, deployments)
StrategicAI.planMission(objective: string) → Mission
StrategicAI.adaptToPlayerActions(player_actions: string[]) → void

-- Resource management
StrategicAI.allocateForces(objective: string) → Unit[]
StrategicAI.calculateThreatResponse(threat_level: number) → string
```

### Tactical AI Service

```lua
-- Unit AI creation
TacticalAI.createUnitAI(unit: Unit, difficulty: number) → TacticalAI
TacticalAI.getUnitAI(unit_id: string) → TacticalAI | nil

-- Turn execution
TacticalAI.makeUnitDecision(unit: Unit, battle: Battle) → AIDecision
TacticalAI.executeTurn(unit: Unit, decision: AIDecision) → void

-- Target selection
TacticalAI.selectTarget(unit: Unit, visible_enemies: Unit[]) → Unit | nil
TacticalAI.evaluateTargetValue(unit: Unit, target: Unit) → number (0-100)
```

### Threat Assessment Service

```lua
-- Threat analysis
ThreatAssessment.assessThreat(unit: Unit) → ThreatAssessment
ThreatAssessment.calculateDanger(threat: Threat, from: Unit) → number

-- Positioning advice
ThreatAssessment.getBestCoverPosition(unit: Unit) → HexCoordinate | nil
ThreatAssessment.getBestAttackPosition(unit: Unit) → HexCoordinate | nil
ThreatAssessment.getEnemiesNearby(unit: Unit, radius: number) → Unit[]
```

### Pathfinding Service

```lua
-- Navigation
PathfindingAI.findPath(start: Hex, goal: Hex, obstacles: Hex[]) → Hex[]
PathfindingAI.findFlankingPosition(target: Unit) → Hex | nil
PathfindingAI.findCoverPosition(threat: Hex) → Hex | nil

-- Strategy
PathfindingAI.findRetreatRoute(unit: Unit) → Hex[]
PathfindingAI.findAmbushPosition(target_path: Hex[]) → Hex | nil
PathfindingAI.calculateTacticalValue(hex: Hex, battle: Battle) → number
```

### Difficulty Adjustment Service

```lua
-- Difficulty scaling
DifficultyAI.getEnemyStats(base_unit: Unit, difficulty: number) → Unit
DifficultyAI.getEnemyAccuracyModifier(difficulty: number) → number
DifficultyAI.getEnemyDamageModifier(difficulty: number) → number
DifficultyAI.getSquadSizeModifier(difficulty: number) → number

-- AI competence
DifficultyAI.getAICompetence(difficulty: number) → number (0-100)
DifficultyAI.adjustAIDifficulty(difficulty: number) → void
```

### Learning AI Service

```lua
-- Adaptation
LearningAI.recordUnitEncounter(unit: Unit, outcome: string) → void
LearningAI.analyzePlayerStrategy(player_actions: string[]) → table
LearningAI.adaptAITactics(lesson: string) → void

-- Behavior modification
LearningAI.addLearnedTactic(ai: TacticalAI, tactic: string) → void
LearningAI.updateConfidence(ai: TacticalAI, success_rate: number) → void
```

### Decision Making Service

```lua
AISystem.makeDecision(unit: Unit) → AIDecision
AISystem.evaluateAction(unit: Unit, action: string) → number  -- Score 0-100
AISystem.selectBestAction(options: table[]) → AIDecision
AISystem.assessThreat(unit: Unit) → ThreatAssessment
```

---

## Configuration (TOML)

### Strategies

```toml
# ai/strategies.toml

[[strategies]]
id = "aggressive_assault"
name = "Aggressive Assault"
type = "aggressive"
priority_objectives = ["eliminate_player", "capture_base", "destroy_equipment"]
resource_commitment = 90
aggressiveness = 85
preferred_tactics = ["frontal_assault", "overwhelming_force"]
terrain_preference = "open"

[[strategies]]
id = "defensive_fortification"
name = "Defensive Fortification"
type = "defensive"
priority_objectives = ["protect_base", "prevent_advances", "minimize_losses"]
resource_commitment = 40
aggressiveness = 20
preferred_tactics = ["entrenchment", "ambush", "concentrated_defense"]
terrain_preference = "defended"

[[strategies]]
id = "infiltration_covert"
name = "Infiltration & Covert"
type = "infiltration"
priority_objectives = ["gather_intelligence", "sabotage", "assassination"]
resource_commitment = 20
aggressiveness = 40
preferred_tactics = ["stealth", "precision_strikes", "evasion"]
terrain_preference = "urban"
```

### Behaviors

```toml
# ai/behaviors.toml

[[behaviors]]
id = "aggressive"
name = "Aggressive Attack"
aggression = 0.9
caution = 0.1
tactical = 0.3
threat_threshold = 3
retreat_threshold = 0.1
preferred_range = "close"
use_cover = false
use_overwatch = false
coordinate_squad = false

[behaviors[0].priority_weights]
attack = 0.8
defense = 0.2
movement = 0.5
group_up = 0.3

[[behaviors]]
id = "tactical"
name = "Tactical Engagement"
aggression = 0.6
caution = 0.6
tactical = 0.9
threat_threshold = 5
retreat_threshold = 0.5
preferred_range = "medium"
use_cover = true
use_overwatch = true
coordinate_squad = true

[behaviors[1].priority_weights]
attack = 0.6
defense = 0.7
movement = 0.4
group_up = 0.8

[[behaviors]]
id = "defensive"
name = "Defensive Position"
aggression = 0.3
caution = 0.8
tactical = 0.7
threat_threshold = 8
retreat_threshold = 0.8
preferred_range = "long"
use_cover = true
use_overwatch = true
coordinate_squad = true

[behaviors[2].priority_weights]
attack = 0.3
defense = 0.9
movement = 0.2
group_up = 0.9
```

### Difficulty Modifiers

```toml
# ai/difficulty_modifiers.toml

[easy]
squad_size_multiplier = 0.75
ai_competence = 50
accuracy_modifier = 0.70
damage_modifier = 0.80
action_points_bonus = 0
reinforcements = false

[normal]
squad_size_multiplier = 1.0
ai_competence = 100
accuracy_modifier = 1.0
damage_modifier = 1.0
action_points_bonus = 0
reinforcements = false

[hard]
squad_size_multiplier = 1.25
ai_competence = 200
accuracy_modifier = 1.3
damage_modifier = 1.2
action_points_bonus = 1
reinforcements = true
reinforcement_waves = 1

[impossible]
squad_size_multiplier = 1.5
ai_competence = 300
accuracy_modifier = 1.5
damage_modifier = 1.5
action_points_bonus = 2
reinforcements = true
reinforcement_waves = 3
```

### Tactical Parameters

```toml
# ai/tactical_parameters.toml

[targeting]
priority_weakest = 0.2
priority_leader = 0.3
priority_threat = 0.5

[positioning]
flanking_score_weight = 0.3
cover_score_weight = 0.4
distance_score_weight = 0.3

[retreat]
retreat_threshold_hp = 0.25
panic_threshold = 25
group_coherence = true

[aggression]
base_confidence = 60
confidence_loss_per_casualty = 5
confidence_gain_per_success = 3
```

---

## Usage Examples

### Example 1: Enemy Turn Execution

```lua
local battle = BattleSystem.getCurrentBattle()
local enemyUnit = battle:getCurrentUnit()

-- Assess threats
local threat = AISystem.assessThreat(enemyUnit)
print("Threat level: " .. threat.threat_level)

-- Make decision
local decision = AISystem.makeDecision(enemyUnit)
print("Decision: " .. decision.action_type)

-- Execute
if decision:isValid() then
  decision:execute()
  print("Action complete")
else
  print("Cannot execute - invalid")
end

-- Next enemy
battle:advanceTurn()
```

### Example 2: Squad Coordination

```lua
local squad = AISystem.createSquad(enemyUnits)

print("Squad cohesion: " .. squad:getCohesion())

-- Set formation
squad:setFormation("wedge")

-- Coordinate actions
local decisions = AISystem.coordinateSquad(squad, {"attack", "flank"})
for _, decision in ipairs(decisions) do
  if decision:isValid() then
    decision:execute()
  end
end
```

### Example 3: Threat Assessment

```lua
local unit = BattleSystem.getCurrentUnit()
local assessment = AISystem.assessThreat(unit)

print("Immediate danger: " .. tostring(assessment.immediate_danger))
print("Enemy count nearby: " .. assessment.enemy_count_nearby)

-- Find cover
if assessment.best_cover_position then
  print("Best cover at: " .. assessment.best_cover_position:toString())
end
```

### Example 4: Difficulty Scaling

```lua
local difficulty = GameSystem.getDifficulty()
local enemyUnit = Unit.create("alien_soldier")

-- Scale stats
local scaledUnit = DifficultyAI.getEnemyStats(enemyUnit, difficulty)
print("Enemy accuracy: " .. (DifficultyAI.getEnemyAccuracyModifier(difficulty) * 100) .. "%")
print("Enemy damage: " .. (DifficultyAI.getEnemyDamageModifier(difficulty) * 100) .. "%")

-- Scale squad size
local squad_size = 4 * DifficultyAI.getSquadSizeModifier(difficulty)
print("Squad size: " .. math.floor(squad_size))
```

### Example 5: Learning & Adaptation

```lua
-- Record successful counter
LearningAI.recordUnitEncounter(playerUnit, "counter_successful")

-- Analyze player strategy
local playerActions = {"aggressive_flank", "cover_heavy", "support_focused"}
local strategy = LearningAI.analyzePlayerStrategy(playerActions)

-- Adapt tactics
LearningAI.adaptAITactics("avoid_flanks")
print("Enemy has learned to avoid flanks!")
```

---

## Decision Making Process

### Decision Tree Evaluation

1. **Can unit act?** Check AP and status
2. **Threat assessment** Evaluate all visible enemies
3. **Target selection** Pick best priority target
4. **Action evaluation** Calculate scores for move/attack/ability/retreat
5. **Best action selection
6. **Execution** Carry out action

### Targeting Priority Scoring

```
Score = (ThreatLevel × 0.5) + (Distance × 0.3) + (Visibility × 0.2)
Target = Unit with highest score
```

### Confidence Decay

- Confidence starts at 60%
- -5% per friendly casualty
- +3% per successful hit
- Used to determine risk-taking behavior

---

## Difficulty Levels

| Difficulty | AI Competence | Accuracy | Damage | Squad Size | Reinforcements |
|------------|---------------|----------|--------|-----------|----------------|
| Easy | 50% | 70% | 80% | 75% | None |
| Normal | 100% | 100% | 100% | 100% | None |
| Hard | 200% | 130% | 120% | 125% | 1 wave |
| Impossible | 300% | 150% | 150% | 150% | 3 waves |

---

## Integration Points

**Inputs from:**
- Battlescape (unit locations, visible enemies, terrain)
- Mission system (objectives, deployment types)
- Unit system (unit stats, health, abilities)
- Difficulty system (scaling parameters)

**Outputs to:**
- Battlescape (unit actions, movement)
- UI (AI decision display for debugging)
- Analytics (decision statistics)
- Learning system (encounter records)

**Dependencies:**
- Pathfinding (navigation)
- Combat system (hit/damage calculations)
- Unit system (stats, abilities)
- Threat assessment (danger evaluation)

---

## Error Handling

```lua
-- Unit cannot act
if not unit:canAct() then
  print("Unit cannot act this turn")
  return nil
end

-- No valid targets
local targets = AISystem.selectTarget(unit, visible_enemies)
if not targets then
  print("No valid targets found")
  -- Default to defensive behavior
end

-- Invalid decision
local decision = AISystem.makeDecision(unit)
if not decision:isValid() then
  print("Decision invalid - cannot execute")
  -- Skip turn or retry
end

-- Threat too high
if threat.threat_level > 80 then
  print("Overwhelming threat - consider retreat")
  decision.action_type = "retreat"
end

-- No escape route
if #PathfindingAI.findRetreatRoute(unit) == 0 then
  print("Cannot retreat - no escape route")
  -- Make stand
end
```

---


**Last Updated:** October 22, 2025  
**API Status:** ✅ COMPLETE  
**Coverage:** 100% (All entities, functions, TOML, examples, decision making documented)  
**Consolidation:** AI_SYSTEMS_DETAILED + AI_SYSTEMS_EXPANDED merged into single comprehensive module
