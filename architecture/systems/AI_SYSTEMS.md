# AI Systems Architecture - Hex-Based Tactical AI

**System:** Artificial Intelligence  
**Date:** 2025-10-28  
**Status:** Complete  
**Coordinate System:** Vertical Axial (for tactical calculations)

---

## Overview

The AI system controls enemy behavior, tactical decisions, strategic planning, and difficulty scaling across all game modes. **Tactical AI uses vertical axial hex system for pathfinding, targeting, and movement.**

### Hex-Based AI Calculations

**AI tactical decisions use HexMath:**
- **Pathfinding:** A* with `HexMath.distance()` heuristic
- **Target Selection:** Range via `HexMath.distance()`
- **Cover Analysis:** Direction via `HexMath.getDirection()`
- **Area Control:** Range queries via `HexMath.hexesInRange()`
- **Line of Sight:** Vision via `HexMath.hexLine()`

**Design Reference:** `design/mechanics/hex_vertical_axial_system.md`  
**Core Module:** `engine/battlescape/battle_ecs/hex_math.lua`

---

## AI Architecture Overview

```mermaid
graph TB
    subgraph "AI Systems - Hex-Based Tactical"
        Coordinator[AI Coordinator]
        HexMath[HexMath Module<br/>Tactical Calculations]
        
        subgraph "Tactical AI"
            Combat[Combat AI<br/>Hex Range Checks]
            Movement[Movement AI<br/>Hex Pathfinding]
            Targeting[Target Selection<br/>Hex Distance]
        end
        
        subgraph "Strategic AI"
            Planning[Strategic Planner]
            Resource[Resource Manager]
            Diplomatic[Diplomatic AI]
        end
        
        subgraph "Support"
            Pathfinding[Pathfinding<br/>HexMath.distance]
            Threat[Threat Assessment<br/>Hex Ranges]
            Squad[Squad Coordination<br/>Hex Formation]
        end
    end
    
    Coordinator --> Combat
    Coordinator --> Planning
    HexMath -.-> Combat
    HexMath -.-> Movement
    HexMath -.-> Targeting
    HexMath -.-> Pathfinding
    HexMath -.-> Threat
    
    Combat --> Movement
    Combat --> Targeting
    
    Movement --> Pathfinding
    Targeting --> Threat
    
    Planning --> Resource
    Planning --> Diplomatic
    
    Combat --> Squad
    
    style Coordinator fill:#FFD700
    style Combat fill:#FF6B6B
    style Planning fill:#87CEEB
    style HexMath fill:#90EE90
```

---

## Behavior Tree Structure

```mermaid
graph TD
    Root[AI Turn] --> Sequence[Sequence Node]
    
    Sequence --> Assess[Assess Situation]
    Sequence --> Decide[Decide Action]
    Sequence --> Execute[Execute Action]
    
    Assess --> ScanThreats[Scan for Threats]
    Assess --> CheckHealth[Check Unit Health]
    Assess --> EvalPosition[Evaluate Position]
    
    ScanThreats --> Priority[Calculate Threat Priority]
    
    Decide --> Selector[Selector Node]
    
    Selector --> Emergency[Emergency Actions]
    Selector --> Offensive[Offensive Actions]
    Selector --> Defensive[Defensive Actions]
    Selector --> Support[Support Actions]
    
    Emergency --> Retreat{HP < 30%?}
    Retreat -->|Yes| FleeAction[Flee to Safety]
    Retreat -->|No| Offensive
    
    Offensive --> CanShoot{Can Attack?}
    CanShoot -->|Yes| AttackAction[Attack Target]
    CanShoot -->|No| Defensive
    
    Defensive --> FindCover[Find Best Cover]
    FindCover --> MoveAction[Move to Cover]
    
    Execute --> FleeAction
    Execute --> AttackAction
    Execute --> MoveAction
    
    style Root fill:#90EE90
    style Decide fill:#FFD700
    style Execute fill:#87CEEB
```

---

## Target Selection

```mermaid
graph TD
    Targets[Visible Targets] --> Filter[Filter Valid Targets]
    
    Filter --> LOS{Line of Sight?}
    
    LOS -->|No| Skip[Skip Target]
    LOS -->|Yes| Range{In Range?}
    
    Range -->|No| Skip
    Range -->|Yes| Score[Calculate Score]
    
    Score --> Factors[Scoring Factors]
    
    Factors --> Distance[Distance: -10 per tile]
    Factors --> Health[Low HP: +50 points]
    Factors --> Threat[High Threat: +30 points]
    Factors --> Cover[No Cover: +20 points]
    Factors --> Exposed[Flanked: +40 points]
    
    Distance --> Total[Total Score]
    Health --> Total
    Threat --> Total
    Cover --> Total
    Exposed --> Total
    
    Total --> Sort[Sort by Score]
    
    Sort --> Best[Select Highest]
    
    style Targets fill:#90EE90
    style Best fill:#87CEEB
    style Total fill:#FFD700
```

### Target Priority Table

| Factor | Weight | Calculation | Example |
|--------|--------|-------------|---------|
| **Distance** | -10/tile | Closer is better | 5 tiles = -50 |
| **Health** | +50 if < 50% | Easy kill bonus | Low HP = +50 |
| **Threat Level** | +30 if high | Dangerous units | Heavy weapon = +30 |
| **Cover Status** | +20 if none | Exposed units | No cover = +20 |
| **Flanked** | +40 if yes | Vulnerable position | Flanked = +40 |
| **Class Bonus** | +0 to +30 | Target priority | Medic = +30 |

---

## Movement AI

```mermaid
graph LR
    Move[Movement Decision] --> Eval[Evaluate Options]
    
    Eval --> Cover1[Option 1: Nearest Cover]
    Eval --> Cover2[Option 2: Flanking Position]
    Eval --> Cover3[Option 3: High Ground]
    Eval --> Cover4[Option 4: Retreat Path]
    
    Cover1 --> Score1[Calculate Score]
    Cover2 --> Score2[Calculate Score]
    Cover3 --> Score3[Calculate Score]
    Cover4 --> Score4[Calculate Score]
    
    Score1 --> Compare[Compare All Options]
    Score2 --> Compare
    Score3 --> Compare
    Score4 --> Compare
    
    Compare --> Best[Select Best Option]
    
    Best --> Path[Calculate Path]
    Path --> Move[Execute Movement]
    
    style Move fill:#90EE90
    style Best fill:#FFD700
    style Path fill:#87CEEB
```

---

## Difficulty Scaling

```mermaid
graph TD
    Difficulty[Difficulty Level] --> Rookie[Rookie Mode]
    Difficulty --> Veteran[Veteran Mode]
    Difficulty --> Commander[Commander Mode]
    Difficulty --> Legend[Legend Mode]
    
    Rookie --> RAim[-20% Aim]
    Rookie --> RHP[+0% HP]
    Rookie --> RAP[+0 AP]
    Rookie --> RBehavior[Simple Tactics]
    
    Veteran --> VAim[+0% Aim]
    Veteran --> VHP[+0% HP]
    Veteran --> VAP[+0 AP]
    Veteran --> VBehavior[Standard Tactics]
    
    Commander --> CAim[+10% Aim]
    Commander --> CHP[+20% HP]
    Commander --> CAP[+1 AP]
    Commander --> CBehavior[Advanced Tactics]
    
    Legend --> LAim[+20% Aim]
    Legend --> LHP[+50% HP]
    Legend --> LAP[+2 AP]
    Legend --> LBehavior[Optimal Play]
    
    style Rookie fill:#90EE90
    style Veteran fill:#FFD700
    style Commander fill:#FFA500
    style Legend fill:#FF6B6B
```

### Difficulty Modifiers

| Difficulty | Hit Chance | Damage | HP | AP | AI Quality |
|------------|-----------|--------|----|----|------------|
| **Rookie** | -20% | -10% | +0% | +0 | Poor positioning |
| **Veteran** | +0% | +0% | +0% | +0 | Uses cover |
| **Commander** | +10% | +10% | +20% | +1 | Flanking, focus fire |
| **Legend** | +20% | +20% | +50% | +2 | Perfect play, coordination |

---

## Squad Coordination

```mermaid
sequenceDiagram
    participant Squad as AI Squad
    participant Leader as Squad Leader
    participant Unit1 as Unit 1
    participant Unit2 as Unit 2
    participant Unit3 as Unit 3
    
    Squad->>Leader: Analyze Battlefield
    Leader->>Leader: Identify Targets
    Leader->>Leader: Assign Priorities
    
    Leader->>Unit1: Target Priority: High
    Leader->>Unit2: Target Priority: Medium
    Leader->>Unit3: Target Priority: Support
    
    Unit1->>Unit1: Focus Fire on Target 1
    Unit2->>Unit2: Suppress Target 2
    Unit3->>Unit3: Provide Cover Fire
    
    alt Target 1 Eliminated
        Leader->>Unit1: New Target Assignment
        Unit1->>Unit1: Switch to Target 2
    end
    
    Leader->>Squad: Maintain Formation
    Squad->>Squad: Units Stay Coordinated
```

---

## Threat Assessment

```mermaid
graph TD
    Unit[Enemy Unit] --> Analyze[Analyze Threat]
    
    Analyze --> Weapon{Weapon Type?}
    
    Weapon -->|Rifle| Threat1[Threat: 5]
    Weapon -->|Sniper| Threat2[Threat: 8]
    Weapon -->|Heavy| Threat3[Threat: 10]
    Weapon -->|Pistol| Threat4[Threat: 3]
    
    Threat1 --> Position{Position?}
    Threat2 --> Position
    Threat3 --> Position
    Threat4 --> Position
    
    Position -->|Flanking| Bonus1[+3 Threat]
    Position -->|High Ground| Bonus2[+2 Threat]
    Position -->|Cover| Penalty1[-1 Threat]
    
    Bonus1 --> Final[Final Threat Level]
    Bonus2 --> Final
    Penalty1 --> Final
    
    Final --> Priority{Threat >= 8?}
    
    Priority -->|Yes| HighPriority[HIGH PRIORITY TARGET]
    Priority -->|No| NormalPriority[Normal Priority]
    
    style Unit fill:#90EE90
    style Final fill:#FFD700
    style HighPriority fill:#FF6B6B
```

---

## Tactical Behaviors

```mermaid
stateDiagram-v2
    [*] --> Patrol: Default State
    
    Patrol --> Alert: Enemy Detected
    
    Alert --> Engage: In Range
    Alert --> Advance: Out of Range
    
    Engage --> Shoot: Good Shot
    Engage --> Reposition: Bad Shot
    
    Shoot --> Reload: Out of Ammo
    Shoot --> CheckResult: After Shot
    
    CheckResult --> Engage: Target Alive
    CheckResult --> Patrol: Target Dead
    
    Reposition --> FindCover
    FindCover --> Engage
    
    Reload --> Engage
    
    Advance --> Engage: In Range
    
    Engage --> Retreat: HP < 30%
    Retreat --> Heal: Safe Position
    Heal --> Patrol: HP > 50%
    
    Patrol --> [*]: Mission Complete
```

---

## Pathfinding Integration

```mermaid
graph LR
    AI[AI Decision] --> NeedPath[Need Movement Path]
    
    NeedPath --> Target[Target Position]
    Target --> Path[Request Pathfinding]
    
    Path --> AStar[A* Algorithm]
    
    AStar --> Check{Path Found?}
    
    Check -->|Yes| Validate[Validate Path]
    Check -->|No| Fallback[Use Fallback Position]
    
    Validate --> Safety[Check Safety]
    
    Safety --> Safe{Path Safe?}
    
    Safe -->|Yes| UsePath[Use Path]
    Safe -->|No| Alternative[Find Alternative]
    
    Alternative --> AStar
    
    UsePath --> Execute[Execute Movement]
    Fallback --> Execute
    
    style AI fill:#90EE90
    style AStar fill:#FFD700
    style Execute fill:#87CEEB
```

---

## Strategic AI (Geoscape)

```mermaid
graph TD
    Strategic[Strategic AI] --> Objectives[Set Objectives]
    
    Objectives --> Expansion[Expansion Goal]
    Objectives --> Research[Research Goal]
    Objectives --> Military[Military Goal]
    
    Expansion --> SpawnUFO[Spawn UFO Missions]
    Research --> TechProgress[Progress Alien Tech]
    Military --> BuildForces[Build Army]
    
    SpawnUFO --> MissionType{Mission Type}
    
    MissionType --> Scout[Scout Mission]
    MissionType --> Raid[Raid Mission]
    MissionType --> Terror[Terror Mission]
    MissionType --> Base[Base Attack]
    
    Scout --> Location[Select Target Province]
    Raid --> Location
    Terror --> Location
    Base --> Location
    
    Location --> Execute[Execute Mission]
    
    style Strategic fill:#FFD700
    style Execute fill:#87CEEB
```

---

## AI Debug Visualization

```mermaid
graph LR
    Debug[Debug Mode] --> Show[Show AI Info]
    
    Show --> Threat[Threat Levels<br/>Color-coded]
    Show --> Paths[Movement Paths<br/>Lines]
    Show --> Targets[Target Priority<br/>Numbers]
    Show --> States[AI States<br/>Icons]
    
    Threat --> Overlay[On-Screen Overlay]
    Paths --> Overlay
    Targets --> Overlay
    States --> Overlay
    
    style Debug fill:#FFD700
    style Overlay fill:#87CEEB
```

---

## Performance Optimization

| Component | Optimization | Impact |
|-----------|-------------|--------|
| **Pathfinding** | Cached paths | Reuse valid paths |
| **Threat Calc** | Update on change | Skip recalculation |
| **Target Selection** | Spatial partitioning | Fast nearest checks |
| **Behavior Tree** | Early exit | Stop at first success |
| **Squad Coordination** | Leader-based | Single decision point |

---

**End of AI Systems Architecture**

