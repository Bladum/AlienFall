# Analytics System Architecture

**System:** Analytics & Metrics  
**Date:** 2025-10-27  
**Status:** Complete

---

## Overview

The Analytics system tracks player behavior, game metrics, performance data, and campaign statistics for balancing and improvement.

---

## Analytics Architecture

```mermaid
graph TB
    subgraph "Analytics System"
        Collector[Metrics Collector]
        
        subgraph "Data Collection"
            Events[Event Tracker]
            Performance[Performance Monitor]
            Player[Player Behavior]
        end
        
        subgraph "Storage"
            Memory[In-Memory Buffer]
            Files[Analytics Files]
            Reports[Report Generator]
        end
        
        subgraph "Analysis"
            Aggregator[Data Aggregator]
            Analyzer[Pattern Analyzer]
            Balancer[Balance Advisor]
        end
    end
    
    Collector --> Events
    Collector --> Performance
    Collector --> Player
    
    Events --> Memory
    Performance --> Memory
    Player --> Memory
    
    Memory --> Files
    Memory --> Aggregator
    
    Aggregator --> Analyzer
    Analyzer --> Balancer
    
    Aggregator --> Reports
    
    style Collector fill:#FFD700
    style Memory fill:#87CEEB
    style Balancer fill:#90EE90
```

---

## Event Tracking Flow

```mermaid
sequenceDiagram
    participant Game as Game System
    participant Event as Event Tracker
    participant Buffer as Data Buffer
    participant File as Analytics File
    
    Game->>Event: Trigger Event
    Event->>Event: Create Event Object
    
    Event->>Event: Add Metadata<br/>(timestamp, session, context)
    
    Event->>Buffer: Add to Buffer
    
    alt Buffer Full
        Buffer->>File: Flush to Disk
        File->>File: Append Events
        Buffer->>Buffer: Clear Buffer
    end
    
    Note over Buffer: Periodic Flush Every 5 Minutes
    
    Buffer->>File: Auto-Flush
    File->>File: Write Events
```

---

## Tracked Metrics

```mermaid
graph TD
    Metrics[Analytics Metrics] --> Combat[Combat Metrics]
    Metrics --> Campaign[Campaign Metrics]
    Metrics --> Performance[Performance Metrics]
    Metrics --> Economy[Economy Metrics]
    
    Combat --> Accuracy[Hit Accuracy<br/>per Weapon Type]
    Combat --> Kills[Kill Count<br/>per Unit Class]
    Combat --> Damage[Damage Dealt/Taken]
    Combat --> Tactics[Tactical Choices]
    
    Campaign --> Progress[Campaign Progress<br/>Mission Count]
    Campaign --> Research[Research Speed<br/>Tech Unlocks]
    Campaign --> Nations[Nation Relations<br/>Panic Levels]
    Campaign --> Time[Playtime<br/>Session Length]
    
    Performance --> FPS[Frame Rate<br/>FPS over Time]
    Performance --> Memory[Memory Usage<br/>Peak/Average]
    Performance --> LoadTime[Load Times<br/>Scene Transitions]
    Performance --> Errors[Error Count<br/>Crash Reports]
    
    Economy --> Income[Income Sources<br/>Funding/Sales]
    Economy --> Expenses[Expense Categories<br/>Salaries/Construction]
    Economy --> Balance[Financial Balance<br/>Over Time]
    Economy --> Items[Item Purchases<br/>Marketplace Activity]
    
    style Metrics fill:#FFD700
    style Combat fill:#FF6B6B
    style Campaign fill:#87CEEB
    style Performance fill:#90EE90
    style Economy fill:#E0BBE4
```

---

## Data Aggregation

```mermaid
graph LR
    RawEvents[Raw Events] --> Aggregate[Aggregator]
    
    Aggregate --> Hourly[Hourly Stats]
    Aggregate --> Daily[Daily Stats]
    Aggregate --> Campaign[Campaign Stats]
    
    Hourly --> HourlyMetrics[Sessions: 5<br/>Missions: 12<br/>Playtime: 3.5h]
    
    Daily --> DailyMetrics[Sessions: 15<br/>Missions: 40<br/>Playtime: 12h]
    
    Campaign --> CampaignMetrics[Total Missions: 250<br/>Total Time: 80h<br/>Win Rate: 85%]
    
    HourlyMetrics --> Reports[Analytics Reports]
    DailyMetrics --> Reports
    CampaignMetrics --> Reports
    
    style Aggregate fill:#FFD700
    style Reports fill:#87CEEB
```

---

## Performance Monitoring

```mermaid
stateDiagram-v2
    [*] --> Monitoring: Start Game
    
    Monitoring --> CollectFPS: Every Frame
    Monitoring --> CollectMemory: Every Second
    Monitoring --> CollectLoad: On Scene Change
    
    CollectFPS --> CheckThreshold: FPS < 30?
    
    state CheckThreshold {
        [*] --> Normal: FPS >= 30
        [*] --> Warning: FPS 15-30
        [*] --> Critical: FPS < 15
        
        Warning --> LogWarning
        Critical --> LogCritical
        
        LogWarning --> [*]
        LogCritical --> [*]
    }
    
    CollectMemory --> CheckMemory: Memory > 800MB?
    
    state CheckMemory {
        [*] --> MemNormal: < 800MB
        [*] --> MemWarning: 800MB - 1GB
        [*] --> MemCritical: > 1GB
        
        MemWarning --> LogMemWarning
        MemCritical --> LogMemCritical
        
        LogMemWarning --> [*]
        LogMemCritical --> [*]
    }
    
    CheckThreshold --> Monitoring
    CheckMemory --> Monitoring
    CollectLoad --> Monitoring
    
    Monitoring --> [*]: Exit Game
```

---

## Campaign Statistics

```mermaid
erDiagram
    CAMPAIGN_STATS {
        string campaign_id PK
        int total_missions
        int missions_won
        int missions_lost
        int missions_aborted
        float win_rate
        int total_kills
        int total_deaths
        int total_playtime_seconds
        date campaign_start
        date campaign_end
    }
    
    MISSION_STATS {
        string mission_id PK
        string campaign_id FK
        string mission_type
        string difficulty
        string result
        int turns_taken
        int enemies_killed
        int soldiers_lost
        int civilians_saved
        int duration_seconds
    }
    
    COMBAT_STATS {
        string stat_id PK
        string campaign_id FK
        string weapon_type
        int shots_fired
        int shots_hit
        float accuracy
        int damage_dealt
        int kills
    }
    
    ECONOMY_STATS {
        string stat_id PK
        string campaign_id FK
        date month
        int income
        int expenses
        int net_balance
        int purchases
        int sales
    }
    
    CAMPAIGN_STATS ||--o{ MISSION_STATS : "contains"
    CAMPAIGN_STATS ||--o{ COMBAT_STATS : "tracks"
    CAMPAIGN_STATS ||--o{ ECONOMY_STATS : "records"
```

---

## Balance Analysis

```mermaid
graph TD
    Analysis[Balance Analysis] --> WeaponBalance[Weapon Balance]
    Analysis --> DifficultyBalance[Difficulty Balance]
    Analysis --> EconomyBalance[Economy Balance]
    
    WeaponBalance --> WinRate{Win Rate by Weapon}
    WinRate -->|Too High| Nerf[Suggest Nerf]
    WinRate -->|Too Low| Buff[Suggest Buff]
    WinRate -->|Balanced| OK1[Balanced ✓]
    
    DifficultyBalance --> Completion{Completion Rate}
    Completion -->|< 20%| TooHard[Too Hard]
    Completion -->|20-80%| OK2[Balanced ✓]
    Completion -->|> 80%| TooEasy[Too Easy]
    
    EconomyBalance --> Bankruptcy{Bankruptcy Rate}
    Bankruptcy -->|> 30%| TooExpensive[Too Expensive]
    Bankruptcy -->|< 5%| TooRich[Too Wealthy]
    Bankruptcy -->|5-30%| OK3[Balanced ✓]
    
    Nerf --> Report[Balance Report]
    Buff --> Report
    TooHard --> Report
    TooEasy --> Report
    TooExpensive --> Report
    TooRich --> Report
    OK1 --> Report
    OK2 --> Report
    OK3 --> Report
    
    style Analysis fill:#FFD700
    style OK1 fill:#90EE90
    style OK2 fill:#90EE90
    style OK3 fill:#90EE90
    style Nerf fill:#FF6B6B
    style Buff fill:#87CEEB
```

---

## Analytics Reports

```mermaid
graph LR
    Reports[Analytics Reports] --> Session[Session Report]
    Reports --> Campaign[Campaign Report]
    Reports --> Performance[Performance Report]
    
    Session --> SessionData[Duration: 2.5h<br/>Missions: 8<br/>Win Rate: 75%<br/>Deaths: 3]
    
    Campaign --> CampaignData[Total Time: 45h<br/>Missions: 120<br/>Progress: 65%<br/>Difficulty: Commander]
    
    Performance --> PerfData[Avg FPS: 58<br/>Memory: 450MB<br/>Crashes: 0<br/>Load Time: 3.2s]
    
    SessionData --> Export[Export Options]
    CampaignData --> Export
    PerfData --> Export
    
    Export --> JSON[JSON Format]
    Export --> CSV[CSV Format]
    Export --> HTML[HTML Report]
    
    style Reports fill:#FFD700
    style Export fill:#87CEEB
```

---

## Privacy & Data Collection

```mermaid
stateDiagram-v2
    [*] --> FirstLaunch: Game First Launch
    
    FirstLaunch --> Prompt: Show Privacy Dialog
    
    Prompt --> OptIn: Player Accepts
    Prompt --> OptOut: Player Declines
    
    state OptIn {
        [*] --> EnableAll
        EnableAll --> CollectAnonymous
        EnableAll --> CollectTelemetry
        EnableAll --> CollectCrash
        
        CollectAnonymous --> [*]
        CollectTelemetry --> [*]
        CollectCrash --> [*]
    }
    
    state OptOut {
        [*] --> DisableRemote
        DisableRemote --> LocalOnly
        LocalOnly --> [*]
    }
    
    OptIn --> Settings: Can Change in Settings
    OptOut --> Settings
    
    Settings --> OptIn: Re-enable
    Settings --> OptOut: Disable
```

---

## Event Categories

| Category | Events | Purpose | Examples |
|----------|--------|---------|----------|
| **Combat** | Shots, hits, kills, deaths | Balance weapons | Rifle accuracy: 68% |
| **Mission** | Start, end, objectives | Mission difficulty | Terror missions: 45% win rate |
| **Research** | Start, complete, unlocks | Tech pacing | Laser weapons: Day 45 avg |
| **Economy** | Purchases, sales, bankruptcy | Financial balance | Avg bankruptcy: Month 8 |
| **Performance** | FPS, memory, load times | Optimization | Load time: 4.2s avg |
| **Player** | Sessions, playtime, preferences | Engagement | Avg session: 2.3h |

---

## Analytics API

```lua
-- Example Analytics Usage

local Analytics = require("analytics.analytics_system")

-- Track an event
Analytics:trackEvent("mission.complete", {
    mission_type = "crash_site",
    difficulty = "veteran",
    result = "victory",
    turns = 18,
    kills = 12,
    deaths = 2
})

-- Track performance
Analytics:trackPerformance("scene.load", {
    scene = "battlescape",
    load_time_ms = 3200,
    memory_mb = 450
})

-- Get statistics
local stats = Analytics:getCampaignStats()
-- stats.win_rate, stats.total_missions, etc.

-- Generate report
Analytics:generateReport("campaign", "json", "temp/report.json")
```

---

## Performance Impact

| Component | CPU Impact | Memory Impact | Disk Impact |
|-----------|-----------|---------------|-------------|
| **Event Tracking** | < 1% | ~2MB buffer | Minimal |
| **Performance Monitor** | < 1% | ~1MB | Minimal |
| **Aggregation** | < 5% (periodic) | ~5MB | 10-50MB per campaign |
| **Report Generation** | < 2% (on-demand) | ~10MB | 1-5MB per report |

---

**End of Analytics System Architecture**

