# Battlescape Architecture - Vertical Axial Hex Grid

**Layer:** Tactical Combat Layer  
**Date:** 2025-10-28  
**Status:** Complete  
**Coordinate System:** Vertical Axial (Flat-Top Hexagons)

---

## Overview

The Battlescape provides turn-based tactical combat where squads engage enemies on procedurally generated hex-based maps using a **universal vertical axial coordinate system**.

### Coordinate System

**All Battlescape systems use vertical axial hex coordinates:**
- **Position Format:** `{q, r}` (axial coordinates)
- **Direction System:** E, SE, SW, W, NW, NE (6 directions)
- **Distance:** Hex distance via `HexMath.distance(q1, r1, q2, r2)`
- **Neighbors:** Always 6 adjacent hexes via `HexMath.getNeighbors(q, r)`

**Design Reference:** `design/mechanics/hex_vertical_axial_system.md`  
**Core Module:** `engine/battlescape/battle_ecs/hex_math.lua`

---

## Combat System Overview

```mermaid
graph TB
    subgraph "Battlescape Layer - Vertical Axial Hex Grid"
        Battle[Battle Manager]
        HexMath[HexMath Module<br/>Universal Hex Mathematics]
        
        subgraph "Core Systems"
            Turn[Turn Manager]
            Action[Action System]
            Combat[Combat Resolver]
            AI[AI Controller]
        end
        
        subgraph "Map Systems - Hex Based"
            MapGen[Map Generator<br/>Hex Blocks]
            LOS[Line of Sight<br/>HexMath.hexLine]
            Path[Pathfinding<br/>HexMath.distance]
            Cover[Cover System<br/>HexMath.getDirection]
        end
        
        subgraph "Entity Management"
            Units[Unit Manager<br/>Positions: q,r]
            Effects[Effects System<br/>HexMath.hexesInRange]
            Animations[Animation System]
        end
    end
    
    Battle --> Turn
    Battle --> MapGen
    Battle --> Units
    HexMath -.-> MapGen
    HexMath -.-> LOS
    HexMath -.-> Path
    HexMath -.-> Cover
    HexMath -.-> Effects
    
    Turn --> Action
    Turn --> AI
    
    Action --> Combat
    Action --> Path
    
    Combat --> Effects
    Combat --> LOS
    Combat --> Cover
    
    Units --> Animations
    
    style Battle fill:#FFD700
    style Turn fill:#87CEEB
    style Combat fill:#FF6B6B
```

---

## Turn Structure

```mermaid
stateDiagram-v2
    [*] --> TurnStart: New Turn
    
    TurnStart --> ProcessEffects: Apply DoT, Buffs
    
    ProcessEffects --> UnitActivation: By Initiative Order
    
    state UnitActivation {
        [*] --> RestoreAP
        RestoreAP --> CheckStatus: HP > 0?
        
        CheckStatus --> PlayerTurn: Player Unit
        CheckStatus --> AITurn: AI Unit
        CheckStatus --> Skip: Dead/Unconscious
        
        state PlayerTurn {
            [*] --> AwaitInput
            AwaitInput --> ValidateAction
            ValidateAction --> ExecuteAction
            ExecuteAction --> [*]
        }
        
        state AITurn {
            [*] --> EvaluateSituation
            EvaluateSituation --> ChooseAction
            ChooseAction --> ExecuteAction
            ExecuteAction --> [*]
        }
        
        Skip --> [*]
    }
    
    UnitActivation --> CheckVictory: Unit Done
    
    CheckVictory --> Victory: All Enemies Dead
    CheckVictory --> Defeat: All Players Dead
    CheckVictory --> NextUnit: Continue
    
    NextUnit --> UnitActivation: More Units
    NextUnit --> TurnEnd: All Units Done
    
    TurnEnd --> TurnStart: Next Turn
    
    Victory --> [*]
    Defeat --> [*]
```

---

## Combat Resolution

```mermaid
graph TD
    Attack[Unit Attacks] --> ValidateTarget{Valid Target?}
    
    ValidateTarget -->|No| Cancel[Cancel Action]
    ValidateTarget -->|Yes| CheckLOS{Line of Sight?}
    
    CheckLOS -->|Blocked| Cancel
    CheckLOS -->|Clear| CheckAP{Enough AP?}
    
    CheckAP -->|No| Cancel
    CheckAP -->|Yes| CalcAccuracy[Base Accuracy]
    
    CalcAccuracy --> Modifiers[Apply Modifiers]
    
    Modifiers --> Range[Range Penalty]
    Modifiers --> Cover[Target Cover]
    Modifiers --> Height[Height Advantage]
    Modifiers --> Stance[Shooter Stance]
    Modifiers --> Morale[Morale Factor]
    
    Range --> FinalHit[Final Hit Chance]
    Cover --> FinalHit
    Height --> FinalHit
    Stance --> FinalHit
    Morale --> FinalHit
    
    FinalHit --> Roll{d100 < Hit%?}
    
    Roll -->|Miss| MissAnim[Play Miss Animation]
    Roll -->|Hit| CalcDamage[Calculate Damage]
    
    CalcDamage --> BaseDmg[Weapon Damage]
    BaseDmg --> Variance[±20% Variance]
    Variance --> Armor[Apply Armor]
    Armor --> FinalDmg[Final Damage]
    
    FinalDmg --> ApplyDmg[Reduce HP]
    ApplyDmg --> CheckDeath{HP <= 0?}
    
    CheckDeath -->|Yes| Death[Unit Death]
    CheckDeath -->|No| Wound[Apply Wound Status]
    
    MissAnim --> End[Action Complete]
    Death --> End
    Wound --> End
    Cancel --> End
    
    style Attack fill:#90EE90
    style Roll fill:#FFD700
    style Death fill:#FF6B6B
```

---

## Action Point System

```mermaid
graph LR
    UnitTurn[Unit Turn Start] --> RestoreAP[Restore AP]
    
    RestoreAP --> MaxAP[Max AP = Base + Bonuses]
    
    MaxAP --> Actions{Available Actions}
    
    Actions --> Move[Move: 1 AP/tile]
    Actions --> Shoot[Shoot: 2-4 AP]
    Actions --> Reload[Reload: 2 AP]
    Actions --> Item[Use Item: 1-2 AP]
    Actions --> Overwatch[Overwatch: All AP]
    
    Move --> DeductAP[Deduct AP Cost]
    Shoot --> DeductAP
    Reload --> DeductAP
    Item --> DeductAP
    Overwatch --> DeductAP
    
    DeductAP --> CheckAP{AP > 0?}
    
    CheckAP -->|Yes| Actions
    CheckAP -->|No| EndTurn[End Turn]
    
    style UnitTurn fill:#90EE90
    style Actions fill:#FFD700
    style EndTurn fill:#FF6B6B
```

### AP Cost Table

| Action | Base Cost | Modifiers | Example |
|--------|-----------|-----------|---------|
| **Move** | 1 AP/tile | Terrain cost ×1-3 | Walking: 1 AP, Water: 2 AP |
| **Shoot** | 2-4 AP | Weapon type | Pistol: 2 AP, Sniper: 4 AP |
| **Reload** | 2 AP | Quick hands: -1 AP | Normal: 2 AP, Perk: 1 AP |
| **Grenade** | 2 AP | None | Always 2 AP |
| **Medikit** | 2 AP | None | Always 2 AP |
| **Overwatch** | All AP | None | Reaction fire mode |
| **Hunker Down** | 1 AP | None | +20 Defense |

---

## Map Generation

```mermaid
graph TD
    Start[Mission Start] --> LoadMapscript[Load Mapscript]
    
    LoadMapscript --> InitGrid[Initialize Grid]
    InitGrid --> SelectBiome[Select Biome]
    
    SelectBiome --> PlaceBlocks{Placement Strategy}
    
    PlaceBlocks -->|Fill| FillGrid[Fill Grid with Blocks]
    PlaceBlocks -->|Border| BorderFirst[Place Border Blocks]
    PlaceBlocks -->|Random| RandomPlace[Random Placement]
    
    FillGrid --> Validate[Validate Connectivity]
    BorderFirst --> Validate
    RandomPlace --> Validate
    
    Validate --> PathCheck{All Areas Accessible?}
    
    PathCheck -->|No| Regenerate[Regenerate Problem Area]
    PathCheck -->|Yes| Features[Add Features]
    
    Regenerate --> PlaceBlocks
    
    Features --> SpawnPoints[Place Spawn Points]
    SpawnPoints --> Objectives[Place Objectives]
    Objectives --> Props[Add Props/Decorations]
    
    Props --> Complete[Map Ready]
    
    style Start fill:#90EE90
    style Complete fill:#87CEEB
    style PathCheck fill:#FFD700
```

---

## AI Behavior

```mermaid
graph TD
    AITurn[AI Turn] --> Assess[Assess Situation]
    
    Assess --> Threats[Identify Threats]
    Assess --> Allies[Check Ally Positions]
    Assess --> Cover[Evaluate Cover]
    
    Threats --> Priority{Prioritize Target}
    
    Priority -->|Closest| Target1[Attack Nearest]
    Priority -->|Weakest| Target2[Attack Weakest]
    Priority -->|Dangerous| Target3[Attack Threat]
    
    Target1 --> CanAttack{Can Attack?}
    Target2 --> CanAttack
    Target3 --> CanAttack
    
    CanAttack -->|Yes| CheckShot{Good Shot%?}
    CanAttack -->|No| FindCover[Move to Cover]
    
    CheckShot -->|> 50%| Shoot[Execute Shot]
    CheckShot -->|< 50%| Reposition[Move Closer]
    
    Shoot --> EndTurn[End Turn]
    FindCover --> EndTurn
    Reposition --> EndTurn
    
    style AITurn fill:#90EE90
    style CheckShot fill:#FFD700
    style Shoot fill:#FF6B6B
```

### AI Difficulty Modifiers

| Difficulty | Aim Bonus | HP Bonus | AP Bonus | Behavior |
|------------|-----------|----------|----------|----------|
| **Rookie** | -20% | +0% | +0 | Defensive, poor tactics |
| **Veteran** | +0% | +0% | +0 | Balanced, uses cover |
| **Commander** | +10% | +20% | +1 | Aggressive, flanking |
| **Legend** | +20% | +50% | +2 | Optimal, coordinated |

---

## Line of Sight

```mermaid
graph TD
    CheckLOS[Check LOS Request] --> GetCoords[Get Start & End]
    
    GetCoords --> Bresenham[Bresenham Line Algorithm]
    
    Bresenham --> TraceLine[Trace Line]
    
    TraceLine --> CheckTile{For Each Tile}
    
    CheckTile --> TileType{Tile Blocks LOS?}
    
    TileType -->|Transparent| Continue[Continue]
    TileType -->|Semi-Opaque| Partial[Partial LOS<br/>-20% Accuracy]
    TileType -->|Opaque| Blocked[LOS Blocked]
    
    Continue --> CheckTile
    Continue --> AllClear[LOS Clear]
    
    Partial --> UsableShot[Can Shoot]
    AllClear --> UsableShot
    
    Blocked --> NoShot[Cannot Shoot]
    
    style CheckLOS fill:#90EE90
    style AllClear fill:#87CEEB
    style Blocked fill:#FF6B6B
    style Partial fill:#FFD700
```

---

## Cover System

```mermaid
graph LR
    Unit[Unit Position] --> CheckAdjacent[Check Adjacent Tiles]
    
    CheckAdjacent --> North[North Tile]
    CheckAdjacent --> South[South Tile]
    CheckAdjacent --> East[East Tile]
    CheckAdjacent --> West[West Tile]
    
    North --> EvalCover1{Cover Type?}
    South --> EvalCover2{Cover Type?}
    East --> EvalCover3{Cover Type?}
    West --> EvalCover4{Cover Type?}
    
    EvalCover1 -->|None| NoCover1[No Bonus]
    EvalCover1 -->|Low| LowCover1[+20 Defense]
    EvalCover1 -->|High| HighCover1[+40 Defense]
    
    EvalCover2 -->|None| NoCover2[No Bonus]
    EvalCover2 -->|Low| LowCover2[+20 Defense]
    EvalCover2 -->|High| HighCover2[+40 Defense]
    
    LowCover1 --> BestCover[Select Best Cover]
    HighCover1 --> BestCover
    LowCover2 --> BestCover
    HighCover2 --> BestCover
    
    BestCover --> CheckFlank{Flanked?}
    
    CheckFlank -->|Yes| RemoveCover[Remove Cover Bonus]
    CheckFlank -->|No| ApplyCover[Apply Cover to Defense]
    
    RemoveCover --> FinalDefense[Final Defense Value]
    ApplyCover --> FinalDefense
    
    style Unit fill:#90EE90
    style HighCover1 fill:#87CEEB
    style HighCover2 fill:#87CEEB
    style FinalDefense fill:#FFD700
```

---

## Effect System

```mermaid
graph TD
    ApplyEffect[Apply Effect] --> Type{Effect Type}
    
    Type -->|Damage Over Time| DOT[Burning/Poison]
    Type -->|Buff| Buff[Stat Increase]
    Type -->|Debuff| Debuff[Stat Decrease]
    Type -->|Status| Status[Stunned/Panicked]
    
    DOT --> Duration[Set Duration]
    Buff --> Duration
    Debuff --> Duration
    Status --> Duration
    
    Duration --> StoreEffect[Add to Unit Effects List]
    
    StoreEffect --> TurnProcess[Process Each Turn]
    
    TurnProcess --> Apply[Apply Effect]
    Apply --> Decrement[Duration - 1]
    
    Decrement --> CheckExpired{Duration = 0?}
    
    CheckExpired -->|Yes| Remove[Remove Effect]
    CheckExpired -->|No| Continue[Continue Next Turn]
    
    style ApplyEffect fill:#90EE90
    style DOT fill:#FF6B6B
    style Buff fill:#87CEEB
    style Debuff fill:#FFA500
```

---

## Performance Optimization

| System | Optimization | Impact |
|--------|-------------|--------|
| **Pathfinding** | A* with caching | Fast unit movement |
| **LOS Calculation** | Shadow casting, caching | Real-time visibility |
| **Animation** | Sprite batching | Smooth 60 FPS |
| **AI Processing** | Incremental decisions | No frame drops |
| **Map Rendering** | Tile culling | Only visible tiles |

---

**End of Battlescape Architecture**

