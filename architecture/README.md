# Architecture Documentation

**AlienFall Game Architecture**  
**Date:** 2025-10-27  
**Status:** Complete & Restructured

---

## 📋 Overview

Comprehensive architecture documentation for AlienFall (XCOM Simple), organized by system, layer, and component. All documentation features Mermaid diagrams, detailed tables, and clear visual flows.

**📖 New to architecture docs?** Read the **[Architecture Guide](ARCHITECTURE_GUIDE.md)** first - it explains how to create, manage, and maintain all diagrams and documentation.

---

## 📁 Directory Structure

```
architecture/
├── README.md                          # This file
├── ROADMAP.md                         # Development roadmap
│
├── core/                              # Core Engine Systems
│   ├── STATE_MANAGEMENT.md           # State machine, transitions, lifecycle
│   └── MOD_SYSTEM.md                 # Mod loading, validation, overrides
│
├── layers/                            # Game Layers
│   ├── GEOSCAPE.md                   # Strategic world management
│   ├── BATTLESCAPE.md                # Tactical combat
│   └── BASESCAPE.md                  # Base management
│
├── systems/                           # Specialized Systems
│   ├── AI_SYSTEMS.md                 # AI behavior, pathfinding, targeting
│   ├── ECONOMY.md                    # Finance, marketplace, resources
│   └── RESEARCH.md                   # Tech tree, research progression
│
└── legacy/                            # Legacy Files (Reference Only)
    ├── 01-game-structure.md
    ├── 02-procedural-generation.md
    ├── 03-combat-tactics.md
    ├── 04-base-economy.md
    ├── DATA_MODELS_AND_INTEGRATION.md
    ├── DETAILED_SYSTEM_DIAGRAMS.md
    ├── INTEGRATION_FLOW_DIAGRAMS.md
    └── SYSTEM_ARCHITECTURE_DIAGRAMS.md
```

---

## 🎯 Quick Navigation

### By System Type

#### Core Engine
- **[State Management](core/STATE_MANAGEMENT.md)** - State machine, scene transitions, global data
- **[Mod System](core/MOD_SYSTEM.md)** - Content loading, TOML parsing, mod validation

#### Game Layers
- **[Geoscape](layers/GEOSCAPE.md)** - World map, missions, nations, time management
- **[Battlescape](layers/BATTLESCAPE.md)** - Turn-based combat, AI, map generation
- **[Basescape](layers/BASESCAPE.md)** - Facility management, research, manufacturing
- **[Interception](layers/INTERCEPTION.md)** - Air combat, UFO interception, craft systems

#### Specialized Systems
- **[AI Systems](systems/AI_SYSTEMS.md)** - Behavior trees, targeting, difficulty scaling
- **[Economy](systems/ECONOMY.md)** - Finance, marketplace, salvage, budgets
- **[Research](systems/RESEARCH.md)** - Tech tree, unlocks, progression
- **[Analytics](systems/ANALYTICS.md)** - Metrics, performance tracking, balance analysis
- **[GUI & Widgets](systems/GUI_WIDGETS.md)** - UI framework, widget system, layouts
- **[Procedural Generation](systems/PROCEDURAL_GENERATION.md)** - Map generation, mapscripts, biomes
- **[Save & Load](systems/SAVE_LOAD.md)** - Game persistence, auto-save, validation
- **[Data Models](systems/DATA_MODELS.md)** - Entity relationships, data structures
- **[Modding Guide](systems/MODDING_GUIDE.md)** - Mod creation, API, workshop integration

---

## 📊 Documentation Features

### Visual Diagrams
- ✅ **Mermaid Flowcharts** - Process flows and pipelines
- ✅ **State Diagrams** - State machines and transitions
- ✅ **Sequence Diagrams** - System interactions and timing
- ✅ **Entity Relationships** - Data models and structures
- ✅ **Class Diagrams** - Object hierarchies

### Detailed Tables
- ✅ **Configuration Tables** - Settings, costs, modifiers
- ✅ **Performance Metrics** - Optimization targets
- ✅ **Feature Matrices** - System capabilities
- ✅ **Comparison Tables** - Difficulty levels, phases

---

## 🔗 Related Documentation

### API Documentation
See `/api/` folder for system contracts:
- `api/GAME_API.toml` - Master schema
- `api/GEOSCAPE.md` - Geoscape API
- `api/BATTLESCAPE.md` - Battlescape API
- `api/BASESCAPE.md` - Basescape API

### Engine Implementation
See `/engine/` folder for code:
- `engine/core/` - Core systems
- `engine/geoscape/` - Geoscape layer
- `engine/battlescape/` - Battlescape layer
- `engine/basescape/` - Basescape layer

### Design Documentation
See `/design/` folder for mechanics:
- `design/mechanics/` - Game mechanics
- `design/gaps/` - Missing features

---

## 📈 Architecture Statistics

| Category | Files | Diagrams | Tables | Status |
|----------|-------|----------|--------|--------|
| **Core Systems** | 2 | 15+ | 10+ | ✅ Complete |
| **Game Layers** | 4 | 60+ | 30+ | ✅ Complete |
| **Specialized Systems** | 9 | 120+ | 80+ | ✅ Complete |
| **Legacy Reference** | 8 | 100+ | 50+ | 📚 Archived |
| **Total** | **23** | **295+** | **170+** | **✅ Complete** |

---

**Last Updated:** 2025-10-27  
**Version:** 2.0 (Restructured)  
**Status:** ✅ Complete


- **System Architecture**: How major systems (Geoscape, Battlescape, Basescape) are structured
- **Integration Patterns**: How systems communicate and share data
- **Data Flow Diagrams**: Visual representation of information flow between systems
- **State Management**: Game state transitions and lifecycle
- **Performance Considerations**: Design decisions for optimization
- **Scalability**: Support for large maps, many units, complex AI
- **Extensibility**: Architecture supports modding and custom content

## Integrations with Other Systems

### Engine Implementation
- `engine/` structure mirrors architecture organization
- Core systems (state_manager, assets, data_loader) implement architectural patterns
- Each module in `engine/` follows layered architecture

### Design Specifications
- Design documents in `design/mechanics/` detail individual systems
- Architecture provides overall structure for those systems
- Gaps documented in `design/gaps/`

### API Documentation
- API files in `api/` define contracts for architectural layers
- Configuration formats support architectural patterns
- Integration points listed in `api/INTEGRATION.md`

### Testing & Validation
- Integration tests in `tests/integration/` validate architecture
- System tests verify component interactions
- Performance tests ensure architectural efficiency

### Roadmap Planning
- Technical roadmap guides development priorities
- Identifies areas needing architectural changes
- Tracks long-term technical debt and refactoring

## Key Architectural Patterns

### Layered Architecture
- **Presentation Layer**: GUI, rendering, input
- **Game Logic Layer**: State management, game rules
- **System Layer**: Core systems (AI, pathfinding, economy)
- **Data Layer**: Assets, configurations, persistence

### State Machine
- Game manages state transitions (menu → geoscape → battlescape, etc.)
- Each state has update/draw lifecycle
- Smooth transitions between game modes

### ECS (Entity Component System)
- Battlescape uses ECS for efficient combat simulation
- Entities have components for behavior, rendering, collision
- Systems process components for game logic

### Event-Driven
- Systems communicate via events where appropriate
- Decouples systems and enables mod integration
- Enables async operations and animations

## See Also

- [Roadmap](./ROADMAP.md) - Current development roadmap
- [Integration Flows](./INTEGRATION_FLOW_DIAGRAMS.md) - System interaction diagrams
- [API Documentation](../api/README.md) - System contracts and interfaces
- [Design Mechanics](../design/mechanics/) - Detailed system design
- [Engine Implementation](../engine/README.md) - Code implementation
