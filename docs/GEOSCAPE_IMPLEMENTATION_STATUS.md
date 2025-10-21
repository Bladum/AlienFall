# Geoscape - Strategic Layer Documentation
## Implementation Status: 74% Complete (Relations System Gap)

**Last Updated**: October 21, 2025  
**Alignment Report**: [WIKI_ENGINE_ALIGNMENT_AUDIT.md](WIKI_ENGINE_ALIGNMENT_AUDIT.md)

---

## Overview

The Geoscape is the strategic layer where players manage their organization globally. It handles world management, mission detection, craft deployment, and long-term strategy.

**Current Status**: Core systems fully functional. Relations system pending (26% gap).

---

## Core Systems Implemented ✅

### 1. World Management
- **File**: `engine/geoscape/world/world_state.lua` (113 lines)
- **Features**:
  - World entity containing provinces
  - Province graph with hex-based pathfinding
  - Turn-based time system (1 day per turn)
  - Terrain and biome system
  - Weather and environmental effects

### 2. Rendering & Visualization
- **File**: `engine/geoscape/world/world_renderer.lua` (400+ lines)
- **Features**:
  - Hex grid visualization (80×40)
  - Province rendering with biome colors
  - Day/night cycle overlay (4 tiles/day movement)
  - Mission icon display with detection status
  - Craft position visualization
  - Label and tooltip system

### 3. Calendar & Time
- **File**: `engine/geoscape/logic/calendar.lua` (documented in world_state)
- **Features**:
  - Turn-based progression (1 turn = 1 day)
  - 360-day year system
  - Month tracking for financial cycles
  - Day/night cycle with 20-day full rotation
  - Turn number tracking
  - Pause/resume functionality

### 4. Mission Detection System
- **File**: `engine/geoscape/systems/mission_system.lua` (180+ lines)
- **Features**:
  - Mission spawning from campaigns
  - Detection via radar scanning
  - Cover mechanics (0-100 per mission)
  - Cover decay/regeneration
  - Mission lifecycle (active, detected, expired)
  - Mission types: Site, UFO, Base

### 5. Craft Management
- **File**: `engine/geoscape/logic/craft.lua` (documented in world_state)
- **Features**:
  - Hex-based craft movement
  - Fuel consumption tracking
  - Operational range calculation
  - Combat readiness status
  - Radar emission control
  - Inter-continent travel support

### 6. Progression System
- **File**: `engine/geoscape/progression_manager.lua` (180+ lines)
- **Features**:
  - Organization level progression (1-5 stages)
  - Experience tracking
  - Bonus system (+10 per level TU/HP/etc.)
  - Level-up events and callbacks
  - Progress percentage calculation

### 7. Campaign System
- **File**: `engine/geoscape/systems/campaign_system.lua` (240+ lines)
- **Features**:
  - Weekly mission generation
  - Escalating difficulty (2 → 10 campaigns/month)
  - Faction-based campaigns
  - Research progress integration
  - Campaign templates (infiltration, terror, supply)

### 8. Input Handling
- **File**: `engine/geoscape/ui/input.lua` (90+ lines)
- **Features**:
  - Keyboard controls (pan, zoom, select)
  - Mouse controls (click missions, drag pan)
  - State transitions to Basescape/Battlescape
  - Hotkeys for common actions

---

## Missing Systems ❌

### Relations System (26% Gap) - HIGH PRIORITY
- **Status**: NOT YET IMPLEMENTED
- **Planned File**: `engine/geoscape/systems/relations_manager.lua` (~280 lines)
- **Components Needed**:
  1. Country relations tracker (-100 to +100)
  2. Supplier relations tracker
  3. Faction relations tracker
  4. Time-based decay mechanics
  5. Events affecting relations
  6. Relations UI display

**Impact**:
- Country funding modifiers (±75%)
- Supplier pricing and availability
- Mission generation frequency
- Feature unlocks (black market, diplomatic actions)

**Priority**: HIGH - Should be completed before public release

**Estimated Implementation Time**: 8-12 hours

---

## Integration Points

| System | Connection | Status |
|--------|-----------|--------|
| **Battlescape** | Mission loading, unit deployment | ✅ Complete |
| **Basescape** | Base accessing, resource management | ✅ Complete |
| **Economy** | Funding, market access | ✅ Complete (except Relations) |
| **AI** | Campaign generation, UFO movement | ✅ Complete |
| **Lore** | Faction progression, narrative hooks | ✅ Complete |

---

## File Structure

```
engine/geoscape/
├── world/
│   ├── world_state.lua           # Main state machine
│   ├── world_renderer.lua        # Rendering system (400+ lines)
│   └── hex_grid.lua              # Hex grid utilities
├── logic/
│   ├── province.lua              # Province entity
│   ├── province_graph.lua        # Province network
│   ├── craft.lua                 # Craft management
│   └── calendar.lua              # Time system
├── systems/
│   ├── mission_system.lua        # Mission management
│   ├── campaign_system.lua       # Campaign generation
│   ├── relations_manager.lua     # ❌ MISSING
│   └── detection_system.lua      # Mission detection
├── ui/
│   ├── input.lua                 # Input handling
│   └── render.lua                # UI rendering
└── README.md
```

---

## Key Mechanics

### Hex Grid System
- **Grid Size**: 80×40 hexes (1 tile = 500km)
- **Coordinate System**: Axial (Q, R)
- **Movement**: 6-directional
- **Distance Calculation**: Manhattan distance for movement costs

### Day/Night Cycle
- **Duration**: 20 turns (20 days) for full cycle
- **Movement Speed**: 4 tiles/day
- **Vision Impact**: Vision range changes with daylight
- **Visual Effect**: Overlay moves from north to south

### Mission Detection
- **Coverage Types**:
  - Radar: Scans 5-20 province radius
  - Craft: Scans 3-7 province radius
- **Detection Mechanics**:
  - Radar power × range vs. mission cover
  - Cover regenerates daily
  - Detected missions show on map

---

## Implementation Checklist

- [x] World generation and management
- [x] Hex grid rendering and navigation
- [x] Calendar and time tracking
- [x] Mission detection system
- [x] Craft movement and management
- [x] Campaign generation
- [x] Progression tracking
- [ ] **Relations system** - HIGH PRIORITY
- [ ] Diplomacy actions UI
- [ ] Relations decay mechanics
- [ ] Dynamic mission escalation

---

## Performance Notes

- **Rendering**: Efficient hex grid rendering (~60 FPS)
- **Pathfinding**: A* algorithm with ~100ms average calculation
- **Memory**: ~2-3MB for typical mission graph (1000+ nodes)
- **Turn Processing**: <100ms for daily updates

---

## Related Documentation

- **API Reference**: `wiki/api/GEOSCAPE.md`
- **Alignment Audit**: `docs/WIKI_ENGINE_ALIGNMENT_AUDIT.md`
- **Code Standards**: `docs/CODE_STANDARDS.md`
- **Development Guide**: `docs/developers/DEVELOPMENT.md`

---

## TODO Items

1. **Relations Manager** (HIGH)
   - Country relations tracking
   - Supplier relations integration
   - Faction relations with campaign control
   - UI display for relations
   - Time decay mechanics
   - Estimated: 8-12 hours

2. **Diplomacy UI** (MEDIUM)
   - Gift/trade dialog
   - Alliance proposal UI
   - Relation modifiers display
   - Estimated: 4-6 hours

3. **Advanced Campaign Features** (LOW)
   - Campaign branching based on relations
   - Faction rivalries affecting mission generation
   - Estimated: 6-10 hours

---

**Status**: 74% Complete - Core gameplay loop functional, Relations system pending
