# Interception Layer Architecture

**Layer:** Air Combat & UFO Interception  
**Date:** 2025-10-27  
**Status:** Complete

---

## Overview

The Interception layer manages air-to-air combat between XCOM craft and UFOs, providing real-time or turn-based aerial engagement mechanics.

---

## Interception System Overview

```mermaid
graph TB
    subgraph "Interception Layer"
        Manager[Interception Manager]
        
        subgraph "Detection"
            Radar[Radar Detection]
            Alert[Alert System]
            Tracking[UFO Tracking]
        end
        
        subgraph "Combat"
            CraftSelect[Craft Selection]
            Pursuit[Pursuit Phase]
            Engagement[Combat Phase]
            Resolution[Combat Resolution]
        end
        
        subgraph "Systems"
            Altitude[Altitude Mechanics]
            Weapons[Weapon Systems]
            Damage[Damage Model]
        end
    end
    
    Manager --> Radar
    Manager --> CraftSelect
    
    Radar --> Alert
    Alert --> Tracking
    
    CraftSelect --> Pursuit
    Pursuit --> Engagement
    Engagement --> Resolution
    
    Engagement --> Altitude
    Engagement --> Weapons
    Engagement --> Damage
    
    style Manager fill:#FFD700
    style Engagement fill:#FF6B6B
    style Resolution fill:#87CEEB
```

---

## Interception Flow

```mermaid
stateDiagram-v2
    [*] --> UFODetected: Radar Contact
    
    UFODetected --> AlertPlayer: Show Alert
    
    AlertPlayer --> PlayerDecision: Player Response
    
    state PlayerDecision {
        [*] --> SelectCraft
        SelectCraft --> CheckReady: Choose Interceptor
        
        CheckReady --> NotReady: Craft Busy
        CheckReady --> Ready: Craft Available
        
        NotReady --> SelectCraft
        Ready --> [*]
    }
    
    PlayerDecision --> Scramble: Launch Craft
    PlayerDecision --> Ignore: Ignore UFO
    
    Ignore --> [*]: UFO Escapes
    
    Scramble --> Pursuit: Chase UFO
    
    state Pursuit {
        [*] --> CalculateIntercept
        CalculateIntercept --> CheckSpeed: Can Catch?
        
        CheckSpeed --> TooFast: UFO Faster
        CheckSpeed --> Catching: Interceptor Faster
        
        TooFast --> [*]: Pursuit Failed
        Catching --> InRange: Enter Weapon Range
        InRange --> [*]
    }
    
    Pursuit --> Combat: Engage
    Pursuit --> [*]: Failed to Catch
    
    state Combat {
        [*] --> RangeCheck
        RangeCheck --> Fire: In Range
        RangeCheck --> Disengage: Out of Range
        
        Fire --> HitRoll: Roll to Hit
        HitRoll --> Hit: Success
        HitRoll --> Miss: Failure
        
        Hit --> DamageCalc: Calculate Damage
        DamageCalc --> ApplyDamage: Reduce HP
        
        ApplyDamage --> CheckDestroyed: UFO HP?
        CheckDestroyed --> UFODown: HP = 0
        CheckDestroyed --> Continue: HP > 0
        
        Continue --> CheckCraftHP: Craft HP?
        CheckCraftHP --> CraftDown: HP = 0
        CheckCraftHP --> Fire: HP > 0
        
        UFODown --> [*]: Victory
        CraftDown --> [*]: Defeat
        Disengage --> [*]: Escaped
    }
    
    Combat --> CrashSite: UFO Destroyed
    Combat --> Retreat: Craft Damaged
    Combat --> Escaped: UFO Fled
    
    CrashSite --> GenerateMission: Create Recovery Mission
    Retreat --> BaseReturn: Return for Repairs
    Escaped --> [*]: Try Again Later
    
    GenerateMission --> [*]
    BaseReturn --> [*]
```

---

## Craft vs UFO Engagement

```mermaid
sequenceDiagram
    participant Geo as Geoscape
    participant Radar
    participant Player
    participant Craft
    participant UFO
    participant Combat as Combat Resolver
    
    Geo->>Radar: Daily Scan
    Radar->>Radar: Detect UFO
    Radar->>Geo: UFO Contact!
    
    Geo->>Player: Show Alert
    Player->>Player: Review UFO Info
    
    alt Player Intercepts
        Player->>Craft: Select Interceptor
        Craft->>Craft: Check Status & Fuel
        
        alt Craft Ready
            Craft->>Craft: Launch from Base
            Craft->>UFO: Begin Pursuit
            
            loop Pursuit Phase
                Craft->>UFO: Calculate Distance
                UFO->>UFO: Move Away
                Craft->>Craft: Close Distance
            end
            
            Craft->>UFO: Enter Weapon Range
            Craft->>Combat: Initiate Combat
            
            loop Combat Rounds
                Combat->>Craft: Craft Attacks
                Combat->>UFO: UFO Takes Damage
                
                UFO->>Combat: UFO Retaliates
                Combat->>Craft: Craft Takes Damage
                
                Combat->>Combat: Check Victory Conditions
                
                alt UFO Destroyed
                    Combat->>Geo: UFO Down!
                    Geo->>Player: Generate Crash Site Mission
                else Craft Destroyed
                    Combat->>Geo: Craft Lost!
                    Geo->>Player: Craft Destroyed
                else UFO Flees
                    UFO->>UFO: Disengage
                    Combat->>Geo: UFO Escaped
                end
            end
            
        else Craft Not Ready
            Player->>Player: Cannot Intercept
        end
        
    else Player Ignores
        UFO->>UFO: Continue Mission
        UFO->>Geo: UFO Completes Objective
    end
```

---

## Altitude System

```mermaid
graph TD
    Altitude[Altitude Levels] --> VeryLow[Very Low<br/>0-1000m]
    Altitude --> Low[Low<br/>1000-5000m]
    Altitude --> Medium[Medium<br/>5000-10000m]
    Altitude --> High[High<br/>10000-15000m]
    Altitude --> VeryHigh[Very High<br/>15000+ m]
    
    VeryLow --> Craft1[Basic Interceptors<br/>Can Reach]
    Low --> Craft1
    Medium --> Craft2[Advanced Interceptors<br/>Can Reach]
    High --> Craft2
    VeryHigh --> Craft3[Elite Interceptors<br/>Can Reach]
    
    VeryLow --> Penalty1[+20% Hit Chance<br/>Low Speed]
    Low --> Penalty2[+10% Hit Chance<br/>Medium Speed]
    Medium --> Penalty3[+0% Hit Chance<br/>Normal Speed]
    High --> Penalty4[-10% Hit Chance<br/>High Speed]
    VeryHigh --> Penalty5[-20% Hit Chance<br/>Very High Speed]
    
    style VeryLow fill:#90EE90
    style Low fill:#FFD700
    style Medium fill:#FFA500
    style High fill:#FF6B6B
    style VeryHigh fill:#8B0000
```

### Altitude Mechanics Table

| Altitude | Range | Speed Modifier | Hit Chance | Accessible To |
|----------|-------|---------------|------------|---------------|
| **Very Low** | 0-1km | ×0.5 | +20% | All interceptors |
| **Low** | 1-5km | ×0.75 | +10% | All interceptors |
| **Medium** | 5-10km | ×1.0 | +0% | Advanced+ |
| **High** | 10-15km | ×1.25 | -10% | Advanced+ |
| **Very High** | 15km+ | ×1.5 | -20% | Elite only |

---

## Weapon Systems

```mermaid
graph LR
    WeaponTypes[Weapon Types] --> Cannon[Cannon<br/>Short Range]
    WeaponTypes --> Missile[Missiles<br/>Medium Range]
    WeaponTypes --> Laser[Laser<br/>Long Range]
    WeaponTypes --> Plasma[Plasma<br/>All Ranges]
    
    Cannon --> CStats[Damage: 20-30<br/>Range: 10km<br/>Ammo: Unlimited<br/>Accuracy: 70%]
    
    Missile --> MStats[Damage: 50-80<br/>Range: 30km<br/>Ammo: 6 missiles<br/>Accuracy: 85%]
    
    Laser --> LStats[Damage: 30-40<br/>Range: 50km<br/>Ammo: Unlimited<br/>Accuracy: 90%]
    
    Plasma --> PStats[Damage: 60-100<br/>Range: 60km<br/>Ammo: 12 shots<br/>Accuracy: 95%]
    
    style Cannon fill:#90EE90
    style Missile fill:#FFD700
    style Laser fill:#87CEEB
    style Plasma fill:#E0BBE4
```

---

## Combat Resolution

```mermaid
graph TD
    Round[Combat Round] --> CraftTurn[Craft Turn]
    
    CraftTurn --> CheckRange{In Range?}
    
    CheckRange -->|No| CloserCheck{Can Get Closer?}
    CheckRange -->|Yes| SelectWeapon[Select Weapon]
    
    CloserCheck -->|Yes| MoveCloser[Move Closer]
    CloserCheck -->|No| Disengage[Forced Disengage]
    
    MoveCloser --> SelectWeapon
    
    SelectWeapon --> FireWeapon[Fire Weapon]
    
    FireWeapon --> CalcAccuracy[Calculate Hit Chance]
    
    CalcAccuracy --> BaseAcc[Base Accuracy]
    CalcAccuracy --> AltMod[Altitude Modifier]
    CalcAccuracy --> SpeedMod[Speed Modifier]
    CalcAccuracy --> DamageMod[Damage Modifier]
    
    BaseAcc --> Roll{d100 < Hit%?}
    AltMod --> Roll
    SpeedMod --> Roll
    DamageMod --> Roll
    
    Roll -->|Miss| UFOTurn[UFO Turn]
    Roll -->|Hit| ApplyDmg[Apply Damage to UFO]
    
    ApplyDmg --> CheckUFOHP{UFO HP <= 0?}
    
    CheckUFOHP -->|Yes| UFODestroyed[UFO Destroyed!]
    CheckUFOHP -->|No| UFOTurn
    
    UFOTurn --> UFOFire[UFO Fires Back]
    UFOFire --> CalcUFOHit[Calculate UFO Hit]
    CalcUFOHit --> UFORoll{Hit?}
    
    UFORoll -->|Miss| NextRound[Next Round]
    UFORoll -->|Hit| CraftDmg[Damage Craft]
    
    CraftDmg --> CheckCraftHP{Craft HP <= 0?}
    
    CheckCraftHP -->|Yes| CraftDestroyed[Craft Destroyed!]
    CheckCraftHP -->|No| CheckFlee{Should Flee?}
    
    CheckFlee -->|Yes| Retreat[Retreat to Base]
    CheckFlee -->|No| NextRound
    
    NextRound --> Round
    
    UFODestroyed --> CrashSite[Generate Crash Site]
    CraftDestroyed --> LostCraft[Remove from Fleet]
    Retreat --> Repairs[Schedule Repairs]
    Disengage --> Escaped[UFO Escaped]
    
    style Round fill:#90EE90
    style UFODestroyed fill:#87CEEB
    style CraftDestroyed fill:#FF6B6B
```

---

## Craft Types

```mermaid
erDiagram
    CRAFT_TYPE {
        string id PK
        string name
        int max_speed
        int armor
        int max_hp
        int fuel_capacity
        int weapon_slots
        table weapon_types
    }
    
    CRAFT_INSTANCE {
        string instance_id PK
        string craft_type_id FK
        string base_id FK
        int current_hp
        int current_fuel
        string status
        table equipped_weapons
        table crew
    }
    
    CRAFT_WEAPON {
        string id PK
        string name
        int damage_min
        int damage_max
        int range
        int accuracy
        int ammo_capacity
        string damage_type
    }
    
    UFO_TYPE {
        string id PK
        string name
        int max_speed
        int armor
        int max_hp
        table weapons
        int altitude_min
        int altitude_max
    }
    
    CRAFT_TYPE ||--o{ CRAFT_INSTANCE : "template"
    CRAFT_INSTANCE ||--o{ CRAFT_WEAPON : "equipped"
    UFO_TYPE ||--|| CRAFT_TYPE : "comparable_to"
```

---

## UFO Behavior

```mermaid
stateDiagram-v2
    [*] --> Spawned: UFO Enters Map
    
    Spawned --> Flying: Begin Mission
    
    Flying --> DetectedByCraft: Interceptor Approaches
    Flying --> CompleteMission: Reach Destination
    
    DetectedByCraft --> Evade: Attempt Escape
    DetectedByCraft --> Fight: Stand Ground
    
    state Evade {
        [*] --> IncreaseSpeed
        IncreaseSpeed --> ChangeAltitude
        ChangeAltitude --> CheckPursuer
        
        CheckPursuer --> Escaped: Outran Interceptor
        CheckPursuer --> StillPursued: Still Chasing
        
        StillPursued --> IncreaseSpeed
    }
    
    state Fight {
        [*] --> Combat
        Combat --> Damaged: Take Damage
        Damaged --> FightOrFlight
        
        FightOrFlight --> ContinueFight: HP > 50%
        FightOrFlight --> AttemptEscape: HP < 50%
        
        ContinueFight --> Combat
        AttemptEscape --> Evade
    }
    
    Evade --> Escaped: Success
    Fight --> Destroyed: HP = 0
    
    Escaped --> ResumeM ission
    ResumeMission --> CompleteMission
    
    Destroyed --> CrashSite: Create Recovery Mission
    CompleteMission --> [*]: Objective Complete
    CrashSite --> [*]
```

---

## Damage Model

```mermaid
graph LR
    Attack[Weapon Attack] --> HitCalc[Hit Calculation]
    
    HitCalc --> BaseAcc[Base Accuracy: 70-95%]
    HitCalc --> Range[Range: -20% to +10%]
    HitCalc --> Altitude[Altitude: -20% to +20%]
    HitCalc --> Speed[Target Speed: -15% to +5%]
    
    BaseAcc --> FinalAcc[Final Accuracy]
    Range --> FinalAcc
    Altitude --> FinalAcc
    Speed --> FinalAcc
    
    FinalAcc --> Roll{d100 Roll}
    
    Roll -->|Hit| DamageCalc[Damage Calculation]
    Roll -->|Miss| NoEffect[No Damage]
    
    DamageCalc --> BaseDmg[Weapon Base Damage]
    BaseDmg --> Variance[±20% Variance]
    Variance --> Armor[Apply Target Armor]
    Armor --> FinalDmg[Final Damage]
    
    FinalDmg --> ApplyHP[Reduce Target HP]
    
    ApplyHP --> CheckCrit{HP < 30%?}
    
    CheckCrit -->|Yes| CritDamage[Critical Damage<br/>+50% to systems]
    CheckCrit -->|No| Normal[Normal Damage]
    
    style Attack fill:#90EE90
    style FinalAcc fill:#FFD700
    style FinalDmg fill:#FF6B6B
```

---

## Performance Considerations

| Component | Optimization | Impact |
|-----------|-------------|--------|
| **UFO Tracking** | Position updates only when in pursuit | Minimal CPU |
| **Combat Resolution** | Turn-based or real-time-with-pause | Configurable |
| **Weapon Effects** | Particle pooling | Smooth animations |
| **Path Calculation** | Cached interception vectors | Fast pursuit |

---

**End of Interception Layer Architecture**

