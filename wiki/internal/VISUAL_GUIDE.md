# XCOM Simple - Visual Game Structure

```
┌─────────────────────────────────────────────────────────────────────┐
│                           MAIN MENU                                 │
│                                                                     │
│                      ╔═══════════════════╗                          │
│                      ║   XCOM SIMPLE     ║                          │
│                      ║  Tactical Strategy║                          │
│                      ╚═══════════════════╝                          │
│                                                                     │
│                      ┌─────────────────┐                            │
│                      │   GEOSCAPE      │──────┐                     │
│                      └─────────────────┘      │                     │
│                      ┌─────────────────┐      │                     │
│                      │ BATTLESCAPE     │──────┼─────┐               │
│                      └─────────────────┘      │     │               │
│                      ┌─────────────────┐      │     │               │
│                      │   BASESCAPE     │──────┼─────┼────┐          │
│                      └─────────────────┘      │     │    │          │
│                      ┌─────────────────┐      │     │    │          │
│                      │      QUIT       │      │     │    │          │
│                      └─────────────────┘      │     │    │          │
└─────────────────────────────────────────────┼─┼─────┼────┼──────────┘
                                               │ │     │    │
                ┌──────────────────────────────┘ │     │    │
                │                                │     │    │
                ▼                                ▼     ▼    ▼
┌───────────────────────────┐  ┌──────────────────────────────────┐
│       GEOSCAPE            │  │       BATTLESCAPE                │
│  (Strategic World Map)    │  │    (Tactical Combat)             │
├───────────────────────────┤  ├──────────────────────────────────┤
│                           │  │                                  │
│    ●───●───●   Provinces  │  │  ░░░░░▓▓▓░░░░░  24x24 Tiles    │
│    │\ /│\ /                │  │  ░░●░░▓▓▓░▓░░░  ● = Units      │
│    ● ● ● ●    Connected   │  │  ░░░░░░▓░░░░●░  ▓ = Walls      │
│     \│X│/     Network     │  │  ░░░░▓▓▓░░░░░░  ░ = Floor      │
│      ●●●                  │  │  ░░░░▓░░░░●░░░                  │
│                           │  │  ░░●░░░░▓▓▓░░░  Green = Player  │
│  Features:                │  │  ░░░░░░░▓░░●░░  Red = Alien     │
│  • 7 Provinces            │  │                                  │
│  • Province Selection     │  │  Features:                       │
│  • Population/Funding     │  │  • Turn-Based                    │
│  • Time System            │  │  • Unit Movement (TU cost)       │
│  • Info Panel             │  │  • Fog of War                    │
│                           │  │  • Health Tracking               │
│  Controls:                │  │  • Selection System              │
│  • Click: Select          │  │                                  │
│  • Space: Pause           │  │  Controls:                       │
│  • ESC: Menu              │  │  • Click Unit: Select            │
│                           │  │  • Click Tile: Move              │
│  [BACK] [PAUSE]           │  │  • WASD: Pan Camera              │
│  ┌──────────────┐         │  │  • Space: End Turn               │
│  │Province Info │         │  │  • ESC: Menu                     │
│  │Name: Europe  │         │  │                                  │
│  │Pop: 600M     │         │  │  [BACK]      [END TURN]          │
│  │Sat: 90%      │         │  │  ┌──────────────┐               │
│  └──────────────┘         │  │  │ Unit Info    │               │
│                           │  │  │ Soldier 1    │               │
└───────────────────────────┘  │  │ HP: 50/50    │               │
                               │  │ TU: 60/80    │               │
                               │  └──────────────┘               │
                               └──────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                         BASESCAPE                                   │
│                   (Base Management)                                 │
├─────────────────────────────────────────────────────────────────────┤
│  [BACK]                                                             │
│                      X-COM Base Alpha                               │
│  ┌─────────┐        Funds: $1,000,000                               │
│  │FACILIT. │                                                         │
│  └─────────┘        Facility Grid (6x6):                            │
│  ┌─────────┐        ┌───┬───┬───┬───┬───┬───┐                      │
│  │SOLDIERS │        │CMD│QTR│HGR│   │   │   │                      │
│  └─────────┘        ├───┼───┼───┼───┼───┼───┤                      │
│  ┌─────────┐        │   │   │   │   │   │   │                      │
│  │RESEARCH │        ├───┼───┼───┼───┼───┼───┤                      │
│  └─────────┘        │   │   │   │   │   │   │  CMD = Command       │
│  ┌─────────┐        ├───┼───┼───┼───┼───┼───┤  QTR = Quarters      │
│  │  MANUF. │        │   │   │   │   │   │   │  HGR = Hangar        │
│  └─────────┘        ├───┼───┼───┼───┼───┼───┤                      │
│                     │   │   │   │   │   │   │  Empty slots can be  │
│  View Modes:        ├───┼───┼───┼───┼───┼───┤  built on (future)   │
│  1. Facilities      │   │   │   │   │   │   │                      │
│  2. Soldiers        └───┴───┴───┴───┴───┴───┘                      │
│  3. Research                                                        │
│  4. Manufacturing   ┌─────────────────────────┐                     │
│                     │ Details Panel           │                     │
│  Controls:          │                         │                     │
│  • 1-4: Switch View │ Facility: Command Center│                     │
│  • Click: Select    │ Upkeep: $50,000         │                     │
│  • ESC: Menu        │                         │                     │
│                     │ Monthly Budget:         │                     │
│                     │ Income:   +$500,000     │                     │
│                     │ Expenses: -$150,000     │                     │
│                     │ Balance:  +$350,000     │                     │
│                     └─────────────────────────┘                     │
└─────────────────────────────────────────────────────────────────────┘
```

## Module Relationships

```
┌────────────────────────────────────────────────────────────────┐
│                        GAME FLOW                               │
└────────────────────────────────────────────────────────────────┘

                         MAIN MENU
                             │
            ┌────────────────┼────────────────┐
            │                │                │
            ▼                ▼                ▼
       GEOSCAPE        BATTLESCAPE       BASESCAPE
            │                                 │
            │    (Future: Deploy Mission)     │
            └─────────────────►───────────────┘
                              │
                              ▼
                        BATTLESCAPE
                         (Combat)
                              │
                    (Future: Return Results)
                              │
                              ▼
                          GEOSCAPE
```

## Data Flow

```
┌──────────────────────────────────────────────────────────────────┐
│                      SYSTEM ARCHITECTURE                         │
└──────────────────────────────────────────────────────────────────┘

main.lua
   │
   ├─► State Manager ──┐
   │                   │
   │                   ├──► Menu State
   │                   │
   │                   ├──► Geoscape State
   │                   │     └─► Province Data
   │                   │
   │                   ├──► Battlescape State
   │                   │     ├─► Map System (tiles)
   │                   │     ├─► Unit System
   │                   │     ├─► Turn System
   │                   │     └─► Visibility System
   │                   │
   │                   └──► Basescape State
   │                         ├─► Facility System
   │                         ├─► Personnel System
   │                         ├─► Research System
   │                         └─► Finance System
   │
   └─► UI System
         ├─► Button Widget
         ├─► Label Widget
         └─► Panel Widget
```

## File Dependencies

```
main.lua
  │
  ├─ require("systems.state_manager")
  │     └─ systems/state_manager.lua
  │
  ├─ require("modules.menu")
  │     │
  │     ├─ require("systems.state_manager")
  │     └─ require("systems.ui")
  │
  ├─ require("modules.geoscape")
  │     │
  │     ├─ require("systems.state_manager")
  │     └─ require("systems.ui")
  │
  ├─ require("modules.battlescape")
  │     │
  │     ├─ require("systems.state_manager")
  │     └─ require("systems.ui")
  │
  └─ require("modules.basescape")
        │
        ├─ require("systems.state_manager")
        └─ require("systems.ui")
```

## Color Coding Legend

### Geoscape
- **Green Circle** = Province with base
- **Gray Circle** = Province without base
- **Orange Circle** = Selected province
- **Light Gray Circle** = Hovered province
- **Gray Lines** = Province connections

### Battlescape
- **Green Circle** = Player unit
- **Red Circle** = Enemy unit
- **Blue Overlay** = Movement range
- **Yellow Circle** = Selected unit
- **Black Tiles** = Unexplored (fog of war)
- **Dark Gray Tiles** = Explored floor
- **Darker Gray** = Explored walls
- **Light Gray Tiles** = Visible floor
- **Medium Gray** = Visible walls

### Basescape
- **Blue Square** = Command Center
- **Green Square** = Living Quarters
- **Brown Square** = Hangar
- **Purple Square** = Laboratory (future)
- **Orange Square** = Workshop (future)
- **Dark Gray** = Empty slot

## Stats & Numbers Reference

### Starting Resources
- **Funds**: $1,000,000
- **Monthly Income**: $500,000
- **Monthly Expenses**: $150,000
- **Soldiers**: 4
- **Scientists**: 2
- **Engineers**: 2

### Unit Stats (Soldier)
- **Health**: 50 / 50
- **Time Units**: 80 / 80
- **Accuracy**: 70%
- **Sight Range**: 10 tiles

### Unit Stats (Alien)
- **Health**: 40 / 40
- **Time Units**: 70 / 70
- **Accuracy**: 60%
- **Sight Range**: 8 tiles

### Map Specs (Battlescape)
- **Map Size**: 30 x 30 tiles
- **Tile Size**: 24 x 24 pixels
- **Movement Cost**: 4 TU per tile
- **Wall Chance**: 10% (procedural)

### Province Stats (Example: Europe)
- **Population**: 600,000,000
- **Satisfaction**: 90%
- **Monthly Funding**: $600,000
- **Connections**: 3 (North America, Africa, Asia)

---

**This visual guide shows the structure and flow of XCOM Simple v0.1.0**
