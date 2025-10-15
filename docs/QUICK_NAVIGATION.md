# Quick Navigation Guide
## Where to Find Everything in AlienFall Documentation

**Last Updated:** October 15, 2025  
**Status:** Phase 4 - All 27 extracted files indexed

---

## 🎮 Game Systems Documentation

### Strategic Layer (Geoscape)
- **Overview:** docs/geoscape/README.md
- **World Map & Provinces:** docs/geoscape/ (complete system)
- **Missions:** docs/geoscape/ (mission types and generation)
- **Diplomacy & Politics:** docs/politics/

### Base Management (Basescape)
- **Overview:** docs/basescape/README.md
- **Facilities:** docs/basescape/facilities/ (construction, functions)
- **Research & Tech:** docs/economy/research.md
- **Manufacturing:** docs/economy/manufacturing.md
- **Unit Management:** docs/battlescape/unit-systems/

### Tactical Combat (Battlescape)
- **Overview:** docs/battlescape/README.md
- **Quick Reference:** docs/battlescape/QUICK_REFERENCE.md (50-item combat summary)
- **Combat Mechanics:** docs/battlescape/combat-mechanics/ (turn order, actions, etc.)
- **Map System:** docs/battlescape/ (terrain, tiles, environments)
- **3D Rendering:** docs/battlescape/graphics/ (rendering systems)
- **Unit Equipment:** docs/battlescape/weapons.md, docs/battlescape/armors.md

### Craft Interception
- **Overview:** docs/interception/README.md
- **Craft Combat System:** docs/interception/ (turn-based interception mechanics)

### Economic Systems
- **Marketplace:** docs/economy/marketplace.md
- **Black Market:** docs/economy/black_market.md
- **Research & Tech Trees:** docs/economy/research.md
- **Manufacturing Queue:** docs/economy/manufacturing.md
- **Economy Overview:** docs/economy/README.md

---

## 🛠️ Technical & Development Documentation

### Getting Started
- **Development Workflow:** docs/DEVELOPMENT.md (how to contribute)
- **Code Standards:** docs/core/LUA_BEST_PRACTICES.md (4-space indent, naming conventions, patterns)
- **Docstring Format:** docs/core/LUA_DOCSTRING_GUIDE.md (LuaDoc format for all functions)
- **Testing Guide:** docs/testing/TESTING.md (how to write and run tests)

### API Reference
- **Complete API:** docs/API.md (1,811 lines - all classes, modules, major functions)
- **Engine Structure:** docs/PROJECT_STRUCTURE.md (folder organization)
- **Core Systems:** docs/core/ (main game loop, state manager, calendar, etc.)

### Code Quality
- **Lua Best Practices:** docs/core/LUA_BEST_PRACTICES.md
  - Variable naming (camelCase functions, UPPER_CASE constants)
  - Error handling with pcall
  - Performance optimization patterns
  - Module structure recommendations
  
- **Docstring Compliance:** docs/core/LUA_DOCSTRING_GUIDE.md
  - LuaDoc function documentation format
  - Parameter and return value documentation
  - Comment standards
  - Example documentation patterns

---

## ⚙️ System Architecture & Implementation Guidance

### Core Systems Analysis

**Resolution System:** docs/systems/RESOLUTION_SYSTEM_ANALYSIS.md
- Fixed GUI: 240×720 pixels
- Battlefield viewport: Scales with resolution
- Coordinate system architecture
- 11 files impacted by changes
- Implementation effort: 7-11 hours

**Tileset System:** docs/systems/TILESET_SYSTEM.md (825 lines)
- Tileset organization (furnitures, weapons, farmland, city, ufo_ship)
- Map Tile definitions and properties
- Multi-tile modes (variants, animation, autotile, damage states)
- Asset guidelines and sprite specifications

**Fire & Smoke Mechanics:** docs/systems/FIRE_SMOKE_MECHANICS.md (334 lines)
- Fire system (30% spread chance, 5 HP/turn damage)
- Smoke system (3 intensity levels with sight penalties)
- Mechanics integration with battlescape
- Debug controls for testing

### Rendering Systems

**Hex Rendering Guide:** docs/rendering/HEX_RENDERING_GUIDE.md (611 lines)
- Flat-top hexagon grid system
- Odd-column offset coordinate system
- Pixel-to-hex conversion formulas
- 6-directional movement (N, NE, SE, S, SW, NW)
- Neighbor calculation mathematics
- Autotile masks (0-63 combinations)
- Common patterns (pathfinding, LOS, mouse picking)

### Balance & Mechanics

**Game Balance Numbers:** docs/balance/GAME_NUMBERS.md (276 lines)
- Action economy (AP costs: move 1, aimed 2, burst 3)
- Combat modifiers (range -20% to -40%, cover -20% to -40%)
- Morale states and effects
- Facility costs and build times
- Research durations and progression
- Performance targets (FPS, memory, load times)

**Mechanical Design:** docs/rules/MECHANICAL_DESIGN.md (306 lines)
- Core game mechanics GDD (Game Design Document)
- Systems design ethos and principles
- Strategic layer system descriptions
- Tactical combat layer contracts
- AI behavior requirements
- Determinism and transparency requirements

---

## 📚 Reference Materials

### Game Information
- **FAQ:** docs/FAQ.md (2,456 lines)
  - Common questions about gameplay
  - X-COM mechanics inspiration
  - Strategic/tactical systems overview
  - Balance and economy explanations

- **Glossary:** docs/GLOSSARY.md
  - Technical terms defined
  - Game mechanics terminology
  - System abbreviations

- **Game Design References:** docs/design/REFERENCES.md (993 lines)
  - UFO Alien series references
  - XCOM gameplay mechanics
  - Recommended reading materials
  - External resources and links

### Project Documentation
- **Project Structure:** docs/PROJECT_STRUCTURE.md
  - Detailed folder organization
  - File naming conventions
  - Module organization patterns
  - Directory purposes explained

- **Complete Overview:** docs/OVERVIEW.md
  - Project vision and goals
  - High-level architecture
  - Game design philosophy

---

## 🎯 Implementation Tasks & Planning

### Master Implementation Plan
**File:** tasks/TODO/MASTER-IMPLEMENTATION-PLAN.md
- 6-phase development roadmap
- Estimated 520-650 total hours (13-16 weeks solo)
- Task dependencies and ordering
- Parallel development opportunities
- Milestone definitions

### Phase 1: Foundation Systems (Weeks 1-3, 185 hours)
**Phase 1.1: Geoscape Core (Week 1, 80 hours)**
- File: tasks/TODO/02-GEOSCAPE/PHASE-1.1-GEOSCAPE-CORE-IMPLEMENTATION.md
- Hex world map (80×40 = 3,200 tiles)
- Province system with biome classification
- Hex pathfinding
- Calendar system (1 turn = 1 day)

**Phase 1.2: Map Generation (Week 2, 60 hours)**
- File: tasks/TODO/01-BATTLESCAPE/PHASE-1.2-MAP-GENERATION-SYSTEM.md
- Procedural mission map generation
- Biome→Terrain mapping pipeline
- MapBlock asset selection
- Team placement algorithms

**Phase 1.3: Mission Detection (Week 3, 45 hours)**
- File: tasks/TODO/02-GEOSCAPE/PHASE-1.3-MISSION-DETECTION-CAMPAIGN-LOOP.md
- Daily mission detection system
- Mission type generation
- Campaign loop management
- Mission reward calculation

### Existing Implementation Tasks
- **Battlescape Tasks:** tasks/TODO/01-BATTLESCAPE/ (10 tasks)
- **Geoscape Tasks:** tasks/TODO/02-GEOSCAPE/ (16 files)
- **Basescape Tasks:** tasks/TODO/03-BASESCAPE/ (4 tasks)
- **Interception Tasks:** tasks/TODO/04-INTERCEPTION/ (1 task)
- **Economy Tasks:** tasks/TODO/05-ECONOMY/ (4 tasks)

### Completed Tasks
- **Archive:** tasks/DONE/ (10 task documentation files created in Phase 3c)

---

## 🏗️ Content Organization

### By Subject

**Core Game Design** (12 files)
- Strategic vision documents
- Gameplay mechanics definitions
- Balance philosophy
- → Located in: docs/design/

**Development Guides** (8 files)
- API documentation (1,811 lines)
- Development workflow
- Code standards and practices
- Testing framework
- → Located in: docs/, docs/core/, docs/testing/

**System Architecture** (6 files)
- Resolution system analysis (656 lines)
- Tileset organization (825 lines)
- Fire/smoke mechanics (334 lines)
- Hex rendering mathematics (611 lines)
- Game balance numbers (276 lines)
- Mechanical design rules (306 lines)
- → Located in: docs/systems/, docs/rendering/, docs/balance/, docs/rules/

**Historical Archive** (1 file)
- MIGRATION_GUIDE (304 lines - engine restructure plan)
- → Located in: wiki/internal/archive/

### By Feature Area

**Battlescape/Combat**
- docs/battlescape/README.md
- docs/battlescape/QUICK_REFERENCE.md
- docs/battlescape/combat-mechanics/
- docs/battlescape/weapons.md, docs/battlescape/armors.md
- docs/battlescape/graphics/
- docs/systems/FIRE_SMOKE_MECHANICS.md
- docs/rendering/HEX_RENDERING_GUIDE.md

**Geoscape/Strategy**
- docs/geoscape/README.md
- docs/geoscape/ (complete system)
- docs/politics/

**Basescape/Management**
- docs/basescape/README.md
- docs/basescape/facilities/
- docs/economy/ (all economic subsystems)

**Lore & Content**
- docs/lore/
- docs/content/
- mods/ (actual game content)

---

## 🔍 How to Find What You Need

### If you want to...

**Learn how the game works:**
1. Start: docs/OVERVIEW.md (high-level vision)
2. Read: docs/FAQ.md (game mechanics)
3. Reference: docs/balance/GAME_NUMBERS.md (all balance values)

**Implement a new feature:**
1. Reference: docs/API.md (available systems)
2. Study: docs/core/LUA_BEST_PRACTICES.md (code patterns)
3. Check: docs/systems/ (similar system implementations)
4. Create task: tasks/TODO/PHASE-N-FEATURE-NAME.md

**Write code:**
1. Follow: docs/core/LUA_BEST_PRACTICES.md
2. Use: docs/core/LUA_DOCSTRING_GUIDE.md format
3. Test: docs/testing/TESTING.md methodology
4. Reference: docs/API.md for available functions

**Fix a bug:**
1. Locate: Affected subsystem in docs/
2. Study: System documentation in docs/SYSTEM-NAME/
3. Check: docs/systems/ for related mechanics
4. Reference: docs/battlescape/QUICK_REFERENCE.md for combat

**Understand the architecture:**
1. Read: docs/PROJECT_STRUCTURE.md (folder layout)
2. Study: docs/DEVELOPMENT.md (workflow)
3. Reference: docs/API.md (system organization)
4. Check: tasks/TODO/MASTER-IMPLEMENTATION-PLAN.md (phases)

**Optimize performance:**
1. Check: docs/balance/GAME_NUMBERS.md (performance targets)
2. Review: docs/systems/RESOLUTION_SYSTEM_ANALYSIS.md
3. Study: docs/core/LUA_BEST_PRACTICES.md (performance tips)

---

## 📊 Documentation Statistics

### Total Content
- **27 extracted files** from Phase 3c
- **21,000+ lines** of comprehensive documentation
- **14 major topic areas** (core, geoscape, battlescape, etc.)
- **6 system architecture documents** with implementation guidance

### Content Breakdown
- Game Design: 6 files (~3,000 lines)
- Developer Guides: 4 files (~2,000 lines)
- System Documentation: 9 files (~8,000 lines)
- API Reference: 1 file (1,811 lines)
- Testing: 1 file (313 lines)
- Balance/Rules: 2 files (582 lines)
- Design References: 1 file (993 lines)
- Historical Archive: 1 file (304 lines)

### Quick Stats
- **Largest file:** docs/API.md (1,811 lines)
- **Smallest file:** docs/battlescape/QUICK_REFERENCE.md (129 lines)
- **Implementation tasks:** 10 documented in tasks/DONE/
- **Phase 1 tasks:** 3 ready to execute

---

## 🚀 Quick Links

### For New Developers
→ Start here: docs/DEVELOPMENT.md

### For Implementation
→ Reference: docs/API.md
→ Guidelines: docs/core/LUA_BEST_PRACTICES.md
→ Check: tasks/TODO/MASTER-IMPLEMENTATION-PLAN.md

### For Game Understanding
→ Start: docs/FAQ.md
→ Reference: docs/balance/GAME_NUMBERS.md
→ Study: docs/OVERVIEW.md

### For Current Status
→ Check: tasks/tasks.md
→ Plan: tasks/TODO/MASTER-IMPLEMENTATION-PLAN.md
→ Progress: tasks/DONE/ (completed tasks)

---

**Last Verified:** October 15, 2025 (Phase 4 Planning)  
**Total Files Documented:** 27 extracted  
**Total Lines Preserved:** 21,000+  
**Ready for:** Phase 1 Implementation (Foundation Systems)
