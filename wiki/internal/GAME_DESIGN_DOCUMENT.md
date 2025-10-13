# XCOM Simple - Game Design Document

## Overview
A simplified turn-based strategy game inspired by UFO: Enemy Unknown (XCOM), built with Love2D 12 and Lua. The game focuses on tactical combat, base management, and strategic world map operations.

## Core Modules

### 1. Geoscape (Strategic Layer)
**Purpose**: Global strategic view where players manage resources, monitor threats, and deploy missions.

**Visual Design**:
- Network-based world map (like Risk)
- Provinces represented as nodes connected by lines
- Each province has:
  - Name
  - Connections to adjacent provinces
  - Current status (safe, under attack, alien controlled)
  - Population/importance rating
  
**Mechanics**:
- **Province Network**: 15-30 interconnected provinces
- **UFO Activity**: Alien crafts move between provinces
- **Mission Detection**: When UFOs land, missions appear
- **Craft Deployment**: Send interceptor/transport crafts to provinces
- **Time System**: Real-time with pause functionality
- **Funding**: Monthly income based on province satisfaction

**UI Elements**:
- Province highlight on hover
- Mission markers (red indicators)
- Craft icons with movement paths
- Time display with speed controls
- Resource panel (funds, available crafts)

### 2. Battlescape (Tactical Layer)
**Purpose**: Turn-based tactical combat on 2D tile maps.

**Visual Design**:
- 24x24 pixel tiles
- Top-down 2D perspective
- Multiple terrain types:
  - Floor (walkable)
  - Wall (blocks movement and sight)
  - Cover (half-height, provides protection)
  - Door (can be opened/closed)
  
**Map Specifications**:
- Grid size: 30x30 to 50x50 tiles
- Tile size: 24x24 pixels (viewport scales as needed)
- Procedurally generated or pre-made maps

**Unit Mechanics**:
- **Stats**: Health, Time Units (TU), Accuracy, Sight Range, Armor
- **Actions**:
  - Movement: Costs TU based on distance
  - Shoot: Costs TU, affected by accuracy and range
  - Reload: Restore ammo
  - Crouch: Reduce visibility, improve accuracy
  - End Turn: Pass to next unit
  
**Turn System**:
- Player phase: Control all units
- Enemy phase: AI controls alien units
- Initiative: Units act in order of stats

**Vision System**:
- Line-of-sight calculation using raycasting
- Fog of war: Unexplored tiles are black
- Revealed tiles show last known state
- Active vision within sight range

**Pathfinding**:
- A* algorithm for movement
- Show valid movement range (blue overlay)
- Display path cost in TU

**Combat**:
- Hit chance calculation: Base accuracy - (distance penalty) + (cover modifier)
- Damage: Weapon damage - armor
- Critical hits: 10% chance for double damage

### 3. Basescape (Management Layer)
**Purpose**: Manage your base, research, manufacturing, and personnel.

**Facilities**:
- **Command Center**: Required, provides base functionality
- **Living Quarters**: Houses soldiers (max 10 per facility)
- **Laboratory**: Enables research (1 scientist per lab)
- **Workshop**: Enables manufacturing (1 engineer per workshop)
- **Storage**: Holds items (50 items per storage)
- **Hangar**: Stores crafts (1 craft per hangar)

**Facility Grid**:
- 6x6 grid of facility slots
- Each facility takes 1 slot
- Construction time: 5-30 days depending on facility
- Construction cost: $50,000 - $500,000

**Personnel Management**:
- **Soldiers**: Combat units with stats (hire, train, equip)
- **Scientists**: Work on research projects
- **Engineers**: Work on manufacturing projects
- Cost: $10,000-$50,000 to hire, monthly salaries

**Research System**:
- Tech tree with prerequisites
- Research time: 5-50 days depending on project
- Unlocks: New weapons, armor, crafts, facilities

**Manufacturing**:
- Produce items researched
- Production time: 1-20 days
- Cost: Raw materials + engineer time

**Storage & Inventory**:
- Store weapons, armor, alien artifacts
- Equip soldiers before missions
- Sell excess items for funding

**UI Screens**:
- Base overview (facility grid)
- Soldier roster (list with stats)
- Research screen (available projects)
- Manufacturing screen (production queue)
- Stores (inventory management)
- Crafts (hangar with loadout)

### 4. Craft System
**Purpose**: Transport soldiers to missions and intercept UFOs.

**Craft Types**:
- **Interceptor**: Fast, armed, 0 soldier capacity
- **Transport**: Slower, 8-12 soldier capacity, light weapons
- **Advanced Craft**: (unlocked via research) Better stats

**Craft Stats**:
- Speed: Movement rate on geoscape
- Range: Maximum distance from base
- Weapons: For interception combat
- Capacity: Number of soldiers

**Deployment**:
- Select craft in base
- Load soldiers and equipment
- Deploy to target province
- Travel time based on distance
- Arrive and trigger mission

## Data Structures

### Province
```lua
{
    id = 1,
    name = "North America",
    position = {x = 100, y = 200},
    connections = {2, 3, 5}, -- IDs of connected provinces
    population = 500000000,
    satisfaction = 85, -- 0-100
    funding = 500000, -- Monthly
    alienActivity = 0, -- 0-100
    hasBase = true,
    missions = {} -- Active missions
}
```

### Unit
```lua
{
    id = 1,
    name = "John Doe",
    type = "soldier", -- or "alien_sectoid", etc.
    team = "player", -- or "alien"
    position = {x = 10, y = 15}, -- Grid coordinates
    stats = {
        health = 50,
        maxHealth = 50,
        timeUnits = 80,
        maxTimeUnits = 80,
        accuracy = 65,
        sightRange = 10,
        armor = 0
    },
    weapon = {
        name = "Rifle",
        damage = 15,
        accuracy = 75,
        ammo = 20,
        maxAmmo = 20,
        range = 15,
        tuCost = 25
    },
    state = "idle" -- idle, moving, shooting, dead
}
```

### Map Tile
```lua
{
    x = 5,
    y = 10,
    type = "floor", -- floor, wall, cover, door
    visible = false,
    explored = false,
    unit = nil, -- Reference to unit on tile
    moveCost = 1 -- TU cost to enter
}
```

### Facility
```lua
{
    id = 1,
    type = "laboratory",
    gridX = 2,
    gridY = 3,
    built = true, -- or false if under construction
    daysRemaining = 0,
    cost = 200000,
    upkeep = 10000 -- Monthly
}
```

## Technical Implementation

### File Structure
```
xcom_simple/
├── main.lua                 -- Entry point, game loop
├── conf.lua                 -- Love2D configuration
├── assets/
│   ├── fonts/
│   ├── images/
│   └── sounds/
├── modules/
│   ├── geoscape.lua        -- Geoscape state
│   ├── battlescape.lua     -- Battlescape state
│   ├── basescape.lua       -- Basescape state
│   └── menu.lua            -- Main menu state
├── systems/
│   ├── state_manager.lua   -- Game state machine
│   ├── pathfinding.lua     -- A* implementation
│   ├── line_of_sight.lua   -- Vision calculations
│   ├── combat.lua          -- Combat resolution
│   └── ui.lua              -- UI widgets
├── data/
│   ├── provinces.lua       -- Province definitions
│   ├── units.lua           -- Unit types
│   ├── weapons.lua         -- Weapon definitions
│   ├── facilities.lua      -- Facility definitions
│   └── research.lua        -- Research tree
└── utils/
    ├── math_helpers.lua    -- Vector math, distance
    └── draw_helpers.lua    -- Rendering utilities
```

### State Management
```lua
-- Game states
states = {
    menu = MenuState,
    geoscape = GeoscapeState,
    battlescape = BattlescapeState,
    basescape = BasescapeState
}

currentState = "menu"

-- State interface
State = {
    load = function(self) end,
    update = function(self, dt) end,
    draw = function(self) end,
    keypressed = function(self, key) end,
    mousepressed = function(self, x, y, button) end
}
```

### Love2D Callbacks
- `love.load()`: Initialize game, load assets, create initial state
- `love.update(dt)`: Update current state logic
- `love.draw()`: Render current state
- `love.keypressed(key)`: Handle keyboard input
- `love.mousepressed(x, y, button)`: Handle mouse clicks
- `love.mousereleased(x, y, button)`: Handle mouse release
- `love.mousemoved(x, y)`: Handle mouse movement

## Minimum Viable Product (MVP)

### Phase 1: Core Framework
- [x] Project setup with Love2D 12
- [x] State manager implementation
- [x] Main menu with state transitions
- [ ] Basic UI system (buttons, labels, panels)

### Phase 2: Geoscape Prototype
- [ ] Province network visualization
- [ ] Province selection and highlighting
- [ ] Basic craft movement
- [ ] Mission generation (simple)

### Phase 3: Battlescape Prototype
- [ ] 24x24 tile map rendering
- [ ] Unit placement (player and enemy)
- [ ] Unit selection with mouse
- [ ] Movement system with pathfinding
- [ ] Turn system (player/enemy phases)
- [ ] Basic line-of-sight
- [ ] Simple shooting mechanics

### Phase 4: Basescape Prototype
- [ ] Facility grid display
- [ ] Facility construction
- [ ] Soldier roster view
- [ ] Basic research system
- [ ] Equipment screen

### Phase 5: Integration
- [ ] Connect geoscape to battlescape (deploy mission)
- [ ] Connect basescape to geoscape (craft deployment)
- [ ] Save/load system
- [ ] Balance and polish

## Art Style
- **Resolution**: 800x600 base, scalable
- **Tile Size**: 24x24 pixels
- **Color Palette**: Limited 16-32 colors for retro feel
- **UI**: Simple boxes, clear fonts, minimal decorations
- **Icons**: 16x16 or 24x24 for units, facilities, items

## Audio
- **Music**: Optional ambient tracks per module
- **SFX**: 
  - Menu clicks
  - Unit movement
  - Weapon fire
  - UI confirmations
  - Alerts (mission detected, research complete)

## Balance Considerations
- **Starting Resources**: $1,000,000
- **Monthly Income**: $500,000 - $2,000,000 (based on province satisfaction)
- **Monthly Costs**: Salaries ($100,000-$300,000), facility upkeep
- **Mission Frequency**: 1-3 per month
- **Research Time**: 10-30 days per project
- **Soldier Starting Stats**: Health 40-60, TU 60-80, Accuracy 40-70

## Future Enhancements
- Multiple bases
- Interception combat mini-game
- More unit types and abilities
- Advanced AI behaviors
- Multiplayer (hot-seat)
- Modding support
- Procedural mission generation
- Story campaign mode

---

**Version**: 1.0  
**Date**: October 10, 2025  
**Engine**: Love2D 12.0 (Lua 5.1+)  
**Target Platform**: Windows, Mac, Linux
