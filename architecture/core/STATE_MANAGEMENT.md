# State Management Architecture

**System:** Core State Management  
**Date:** 2025-10-27  
**Status:** Complete

---

## Overview

The state management system controls scene transitions, lifecycle management, and global data sharing across all game screens.

---

## State Machine Architecture

```mermaid
stateDiagram-v2
    [*] --> Boot: Application Start
    
    Boot --> MainMenu: Init Complete
    
    state MainMenu {
        [*] --> MenuIdle
        MenuIdle --> NewCampaign: New Game
        MenuIdle --> LoadCampaign: Load Game
        MenuIdle --> Settings: Settings
        MenuIdle --> Exit: Quit
        
        NewCampaign --> CampaignWizard
        CampaignWizard --> [*]: Start
        
        LoadCampaign --> [*]: Load
        Settings --> MenuIdle: Back
        Exit --> [*]: Quit
    }
    
    MainMenu --> Geoscape: Enter Campaign
    
    state Geoscape {
        [*] --> WorldView
        WorldView --> TimeAdvance: Time Passes
        TimeAdvance --> WorldView
        WorldView --> BaseView: Select Base
        WorldView --> MissionBriefing: Select Mission
        WorldView --> InterceptionAlert: UFO Contact
        
        BaseView --> [*]: Enter Basescape
        MissionBriefing --> Deployment
        Deployment --> [*]: Launch Battle
        InterceptionAlert --> [*]: Intercept
    }
    
    Geoscape --> Basescape: Base Management
    Geoscape --> Battlescape: Mission Start
    Geoscape --> Interception: UFO Intercept
    
    Basescape --> Geoscape: Return
    Battlescape --> Geoscape: Mission End
    Interception --> Geoscape: Combat End
    
    Geoscape --> MainMenu: Exit Campaign
    MainMenu --> [*]: Exit Game
```

---

## State Lifecycle

```mermaid
sequenceDiagram
    participant SM as State Manager
    participant Old as Current State
    participant New as New State
    participant Global as Global Data
    
    Note over SM: switch("new_state", args...)
    
    SM->>Old: exit()
    Old->>Old: Cleanup resources
    Old->>Old: Save temporary data
    Old-->>SM: Exit complete
    
    SM->>SM: current = nil
    SM->>Global: Store transition data
    
    SM->>New: enter(args...)
    New->>Global: Load transition data
    New->>New: Initialize resources
    New->>New: Setup UI
    New-->>SM: Ready
    
    SM->>SM: current = New
    
    loop Game Loop
        SM->>New: update(dt)
        SM->>New: draw()
    end
```

---

## State Registry

| State Name | File | Purpose | Typical Duration |
|------------|------|---------|------------------|
| `menu` | `main_menu.lua` | Main menu navigation | Until game start |
| `geoscape` | `geoscape_screen.lua` | Strategic world view | Campaign duration |
| `battlescape` | `battlescape_screen.lua` | Tactical combat | 10-30 minutes |
| `basescape` | `basescape_screen.lua` | Base management | 2-5 minutes |
| `interception` | `interception_screen.lua` | Air combat | 1-3 minutes |
| `deployment` | `deployment_screen.lua` | Unit deployment | 30-60 seconds |
| `mission_briefing` | `mission_briefing_screen.lua` | Mission info | 10-20 seconds |
| `load_game` | `load_game_screen.lua` | Save slot selection | Until load |
| `campaign_stats` | `campaign_stats_screen.lua` | Statistics view | Until close |
| `settings` | `settings_screen.lua` | Game settings | Until close |

---

## Global Data Store

```mermaid
graph TD
    StateManager[State Manager] --> GlobalData[Global Data Store]
    
    GlobalData --> CampaignData[campaign_id<br/>difficulty<br/>start_date]
    GlobalData --> TransitionData[last_state<br/>return_to<br/>temp_data]
    GlobalData --> SessionData[playtime<br/>save_count<br/>settings]
    
    Geoscape[Geoscape State] --> GlobalData
    Battlescape[Battlescape State] --> GlobalData
    Basescape[Basescape State] --> GlobalData
    
    GlobalData -.->|Read| Geoscape
    GlobalData -.->|Read| Battlescape
    GlobalData -.->|Read| Basescape
    
    style GlobalData fill:#FFD700
```

---

## State Interface Contract

```lua
-- Required callbacks for any game state
State = {
    -- Called when entering state
    enter = function(self, ...) end,
    
    -- Called when leaving state
    exit = function(self) end,
    
    -- Called every frame
    update = function(self, dt) end,
    
    -- Called every frame for rendering
    draw = function(self) end,
    
    -- Input callbacks (optional)
    keypressed = function(self, key, scancode, isrepeat) end,
    mousepressed = function(self, x, y, button) end,
    mousereleased = function(self, x, y, button) end,
    mousemoved = function(self, x, y, dx, dy) end,
    wheelmoved = function(self, x, y) end,
    
    -- Window callbacks (optional)
    resize = function(self, w, h) end
}
```

---

## State Transitions Table

| From | To | Trigger | Data Passed |
|------|----|---------| ------------|
| Menu | Geoscape | New/Load Game | campaign_data |
| Geoscape | Battlescape | Mission Start | mission_data, squad |
| Battlescape | Geoscape | Mission End | results, loot, casualties |
| Geoscape | Basescape | Select Base | base_id |
| Basescape | Geoscape | Return | base_updates |
| Geoscape | Interception | UFO Contact | ufo_data, craft_data |
| Interception | Geoscape | Combat End | result, damages |
| Any | Menu | Exit Campaign | save_prompt |

---

## Performance Considerations

```mermaid
graph LR
    StateSwitch[State Switch] --> Cleanup[Cleanup Old State]
    
    Cleanup --> ReleaseTextures[Release Textures]
    Cleanup --> ClearCache[Clear Temp Cache]
    Cleanup --> UnloadAudio[Unload Audio]
    
    ReleaseTextures --> LoadNew[Load New State]
    ClearCache --> LoadNew
    UnloadAudio --> LoadNew
    
    LoadNew --> PreloadAssets[Preload Assets]
    LoadNew --> InitSystems[Init Systems]
    LoadNew --> BuildUI[Build UI]
    
    PreloadAssets --> Ready[State Ready]
    InitSystems --> Ready
    BuildUI --> Ready
    
    style Cleanup fill:#FF6B6B
    style LoadNew fill:#90EE90
    style Ready fill:#87CEEB
```

### Memory Management

| State | Typical Memory | Peak Memory | Assets Loaded |
|-------|---------------|-------------|---------------|
| Menu | 50 MB | 80 MB | UI, logo, music |
| Geoscape | 120 MB | 200 MB | World map, UI, nations |
| Battlescape | 250 MB | 400 MB | Map, units, effects |
| Basescape | 100 MB | 150 MB | Base grid, facilities, UI |
| Interception | 80 MB | 120 MB | Sky, crafts, UI |

---

**End of State Management Architecture**

