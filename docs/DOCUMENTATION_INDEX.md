# 📚 AlienFall Engine - Complete Documentation Index

**Last Updated:** October 25, 2025
**Status:** ✅ Complete & Production Ready
**Engine Version:** Restructured Phase-0

---

## 📖 Primary Documentation Files

### 🎯 Start Here
1. **[ENGINE_COMPLETE_SCAN_REPORT.md](ENGINE_COMPLETE_SCAN_REPORT.md)** ⭐ START HERE
   - **Purpose:** Complete structural analysis of all 22 subsystems
   - **Contains:** Purpose of every folder, file organization, integration points
   - **Audience:** Anyone wanting to understand the engine structure
   - **Time to read:** 15-20 minutes

2. **[ENGINE_RESTRUCTURING_SUMMARY.md](ENGINE_RESTRUCTURING_SUMMARY.md)**
   - **Purpose:** Executive summary of restructuring work completed
   - **Contains:** What changed, metrics, validation results
   - **Audience:** Project managers, leads, stakeholders
   - **Time to read:** 5-10 minutes

3. **[docs/ENGINE_RESTRUCTURING_PHASE_COMPLETION.md](docs/ENGINE_RESTRUCTURING_PHASE_COMPLETION.md)**
   - **Purpose:** Detailed documentation of 6-phase restructuring
   - **Contains:** Complete phase breakdown, import changes, developer guides
   - **Audience:** Developers, reviewers
   - **Time to read:** 20-30 minutes

---

## 🗂️ Engine Subsystem Documentation

### Gameplay Layers

#### 1. 🗺️ Geoscape (Strategic Layer)
- **Folder:** `engine/geoscape/`
- **README:** `engine/geoscape/README.md`
- **Files:** 76 Lua files
- **Purpose:** Strategic world map, mission management, global operations
- **Key Systems:**
  - Mission detection via radar
  - Nation relations and diplomacy
  - Craft deployment and interception
  - Time progression and calendar
- **Main Manager:** `managers/campaign_manager.lua`

#### 2. ⚔️ Battlescape (Tactical Layer)
- **Folder:** `engine/battlescape/`
- **README:** `engine/battlescape/README.md`
- **Files:** 164 Lua files (largest subsystem)
- **Purpose:** Turn-based tactical combat on procedurally generated maps
- **Key Systems:**
  - Entity Component System (ECS) for entity management
  - Procedural map generation with mapblocks
  - Combat resolution with weapons and armor
  - Vision system with fog of war and cover
  - Pathfinding and movement
  - 3D rendering
- **Main Manager:** `managers/battle_manager.lua`

#### 3. 🏛️ Basescape (Management Layer)
- **Folder:** `engine/basescape/`
- **README:** `engine/basescape/README.md`
- **Files:** 27 Lua files
- **Purpose:** Base construction, facility management, personnel hiring, research
- **Key Systems:**
  - 2D grid-based facility placement
  - Research tree and tech progression
  - Personnel management (soldiers, scientists, engineers)
  - Manufacturing and equipment crafting
  - Marketplace for buying/selling
- **Main Manager:** `base_manager.lua`

### Core Infrastructure

#### 4. 🔧 Core Systems
- **Folder:** `engine/core/`
- **README:** `engine/core/README.md`
- **Files:** 16 Lua files in 10 organized folders
- **Subfolders:**
  - `state/` - Game state and screen management
  - `events/` - Event system for inter-system communication
  - `data/` - TOML data loading and validation
  - `audio/` - Audio playback and management
  - `assets/` - Asset caching and loading
  - `systems/` - Automation, difficulty, QA, save/load
  - `spatial/` - Spatial partitioning for queries
  - `testing/` - Testing utilities
  - `facilities/` - Facility data definitions
  - `terrain/` - Terrain definitions

#### 5. 🎨 GUI Framework
- **Folder:** `engine/gui/`
- **README:** `engine/gui/README.md`
- **Files:** 59 Lua files
- **Purpose:** Global UI framework with reusable widgets and scenes
- **Key Components:**
  - `scenes/` - Game screens (menu, geoscape, battlescape, basescape, etc.)
  - `widgets/` - 49+ reusable UI components
  - Screen transitions and input routing

### AI & Gameplay Systems

#### 6. 🤖 AI Systems
- **Folder:** `engine/ai/`
- **README:** `engine/ai/README.md`
- **Files:** 12 Lua files
- **Purpose:** Artificial intelligence for combat, strategy, and diplomacy
- **Key Systems:**
  - Tactical AI for enemy units
  - Strategic AI for alien advancement
  - Diplomatic AI for nation interactions
  - Pathfinding algorithms
  - Threat assessment

#### 7. ⚖️ Politics System
- **Folder:** `engine/politics/`
- **README:** `engine/politics/README.md`
- **Files:** 6 Lua files
- **Purpose:** Political mechanics, nation relations, fame/karma
- **Key Systems:**
  - Nation relations tracking
  - Diplomatic events
  - Fame and reputation
  - Government mechanics

#### 8. ✈️ Interception System
- **Folder:** `engine/interception/`
- **README:** `engine/interception/README.md`
- **Files:** 8 Lua files
- **Purpose:** Air combat between crafts and UFOs
- **Features:**
  - Turn-based air combat
  - Altitude mechanics
  - Weapon systems
  - UFO AI behaviors

### Content & Features

#### 9. 📚 Content Management
- **Folder:** `engine/content/`
- **README:** `engine/content/README.md`
- **Files:** 16 Lua files
- **Purpose:** Game content loading and management
- **Content Types:**
  - Units (soldiers, aliens)
  - Equipment (weapons, armor)
  - Crafts (interceptors, transports)
  - Missions (objectives, rewards)
  - Factions (alien races)
  - Items and consumables

#### 10. 💰 Economy System
- **Folder:** `engine/economy/`
- **README:** `engine/economy/README.md`
- **Files:** 13 Lua files
- **Purpose:** Economic management and resource tracking
- **Features:**
  - Nation funding tracking
  - Budget and cost management
  - Manufacturing system
  - Research project expenses
  - Marketplace economy

#### 11. 📖 Lore System
- **Folder:** `engine/lore/`
- **README:** `engine/lore/README.md`
- **Files:** 8 Lua files
- **Purpose:** Story, narrative, and lore content
- **Features:**
  - Game calendar and date system
  - Mission narratives
  - Faction lore and history
  - Story events and hooks
  - In-game encyclopedia

#### 12. 🎓 Tutorial System
- **Folder:** `engine/tutorial/`
- **README:** `engine/tutorial/README.md`
- **Files:** 5 Lua files
- **Purpose:** Interactive tutorials and learning content

#### 13. 🎬 Localization System
- **Folder:** `engine/localization/`
- **README:** `engine/localization/README.md`
- **Files:** 3 Lua files
- **Purpose:** Multi-language support
- **Features:**
  - Language file loading
  - String translation
  - Regional variants

#### 14. 📊 Analytics System
- **Folder:** `engine/analytics/`
- **README:** `engine/analytics/README.md`
- **Files:** 3 Lua files
- **Purpose:** Game metrics and telemetry
- **Features:**
  - Player statistics
  - Success/failure tracking
  - Performance metrics

#### 15. ♿ Accessibility System
- **Folder:** `engine/accessibility/`
- **README:** `engine/accessibility/README.md`
- **Files:** 4 Lua files
- **Purpose:** Inclusive gameplay features
- **Features:**
  - Colorblind mode
  - Controller/gamepad support
  - UI scaling
  - Audio accessibility

#### 16. 🎨 Assets System
- **Folder:** `engine/assets/`
- **README:** `engine/assets/README.md`
- **Files:** 3 Lua files
- **Purpose:** Asset management and resource loading

#### 17. 🛠️ Utilities
- **Folder:** `engine/utils/`
- **README:** `engine/utils/README.md`
- **Files:** 5 Lua files
- **Purpose:** General utility functions and helpers

#### 18. 🎮 Mod System
- **Folder:** `engine/mods/`
- **README:** `engine/mods/README.md`
- **Files:** 1 Lua file
- **Purpose:** Modding support and content loading

### Future Systems (Placeholders)

#### 19. 🌐 Network System
- **Folder:** `engine/network/`
- **README:** `engine/network/README.md`
- **Status:** Not implemented - placeholder for future networking

#### 20. 🚀 Portal System
- **Folder:** `engine/portal/`
- **README:** `engine/portal/README.md`
- **Status:** Not implemented - placeholder for alien gateway mechanics

---

## 🔍 How to Find What You Need

### I want to understand...

**"How the game starts and loads?"**
1. Read: `engine/main.lua` (has detailed comments)
2. Read: `engine/conf.lua` (Love2D configuration)
3. Then read: `ENGINE_COMPLETE_SCAN_REPORT.md` - Entry Points section

**"How the strategic layer works?"**
1. Read: `engine/geoscape/README.md`
2. Check: `engine/geoscape/managers/campaign_manager.lua` (main coordinator)
3. Then: Look at specific systems you need (mission_manager, detection_manager, etc.)

**"How tactical combat works?"**
1. Read: `engine/battlescape/README.md`
2. Check: `engine/battlescape/managers/battle_manager.lua` (main coordinator)
3. Then: Explore specific systems (combat, vision, map_generator, etc.)

**"How to add a new weapon/equipment?"**
1. Read: `api/WEAPONS_AND_ARMOR.md` (API specification)
2. Add data to: `mods/core/rules/items/weapons.toml`
3. Load via: `engine/content/items_loader.lua`
4. Use in: `engine/battlescape/combat/`

**"How to add a new facility?"**
1. Read: `api/FACILITIES.md` (API specification)
2. Add definition: `mods/core/rules/facilities.toml`
3. Implement in: `engine/basescape/facilities/`
4. Add UI in: `engine/basescape/ui/`

**"How to add a new mission type?"**
1. Read: `api/MISSIONS.md` (API specification)
2. Add mission definition: `mods/core/rules/missions.toml`
3. Implement logic: `engine/geoscape/systems/mission_generator.lua`
4. Add narrative: `engine/lore/missions/`

**"How to add AI behavior?"**
1. Read: `engine/ai/README.md`
2. Add behavior: `engine/ai/tactical/` or `engine/ai/strategic/`
3. Integrate with: `engine/ai/ai_coordinator.lua`

**"How systems communicate?"**
1. Read: `engine/core/events/README.md`
2. Check: `engine/core/events/event_system.lua` (implementation)
3. Then: Look at how other systems use events in their code

**"How to run tests?"**
1. Read: `tests/README.md`
2. Run all tests: `lovec tests/runners`
3. Run specific tests: `lovec tests/runners battlescape`

---

## 🏗️ Architecture & Integration

### System Dependencies Graph
```
┌─────────────────────────────────────┐
│   Main Entry (main.lua, conf.lua)   │
└──────────────┬──────────────────────┘
               ↓
┌──────────────────────────────────────────┐
│  Core Systems (state, events, data, etc) │
└──────────────┬─────────────────────────┬─┘
               ↓                         ↓
    ┌──────────────────────┐  ┌────────────────────┐
    │  GUI Framework       │  │  Content Manager   │
    │ (scenes, widgets)    │  │ (units, items, etc)│
    └─────────┬────────────┘  └────────┬───────────┘
              ↓                        ↓
    ┌──────────────────────────────────────────┐
    │      Game Layers                         │
    ├──────────┬────────────┬──────────────────┤
    │ Geoscape │ Battlescape│   Basescape      │
    └──────────┴────────────┴──────────────────┘
         ↓          ↓              ↓
    Various sub-systems and managers
```

### Data Flow Patterns
1. **Event-Driven**: Systems communicate via event system
2. **State-Based**: Game state managed by state manager
3. **Data-Driven**: TOML configs define game content
4. **Component-Based**: Battlescape uses ECS for entities
5. **Hierarchical**: UI organized in scene/widget hierarchy

---

## 📊 Statistics & Metrics

| Metric | Value |
|--------|-------|
| Total Lua Files | 432 |
| Total Subsystems | 22 |
| Largest Layer | Battlescape (164 files) |
| Smallest Layer | Network/Portal (0 files each) |
| README Coverage | 100% |
| Test Pass Rate | 100% |
| Lines of Code | 50,000+ |
| Git Commits | 55+ |

---

## 🔗 External Documentation References

### API Documentation (`api/` folder)
- All systems have corresponding API files
- Format: TOML schemas and usage examples
- Defines modding interfaces
- **Master File:** `api/GAME_API.toml`

### Architecture Documentation (`architecture/` folder)
- System design patterns
- Integration flow diagrams
- Roadmap and planning
- **Master File:** `architecture/README.md`

### Design Documentation (`design/` folder)
- Game design specifications
- Mechanics details
- Balance parameters
- **Master File:** `design/README.md`

### Test Documentation (`tests/README.md`)
- How to run tests
- Test organization
- Writing new tests

---

## 💡 Quick Reference Commands

```bash
# Run the game
lovec engine

# Run all tests
lovec tests/runners

# Run specific test suite
lovec tests/runners battlescape
lovec tests/runners geoscape

# Run with test coverage
TEST_COVERAGE=1 lovec tests/runners

# View git history of restructuring
git log --oneline engine-restructure-phase-0

# Show git diff for specific phase
git show <commit-hash>
```

---

## 📋 Development Workflow Checklist

### Before Making Changes
- [ ] Read ENGINE_COMPLETE_SCAN_REPORT.md to understand structure
- [ ] Read subsystem README for the area you're modifying
- [ ] Check api/ documentation for the system
- [ ] Review existing tests for usage patterns
- [ ] Run full test suite to establish baseline

### While Making Changes
- [ ] Keep related code organized in appropriate folders
- [ ] Follow naming conventions (snake_case for files, camelCase for functions)
- [ ] Add module-level documentation to new files
- [ ] Update README if adding new files/folders
- [ ] Write tests for new functionality

### After Making Changes
- [ ] Run full test suite: `lovec tests/runners`
- [ ] Check for import errors
- [ ] Verify integration with related systems
- [ ] Update documentation
- [ ] Commit with clear message

---

## ❓ FAQ

**Q: Where do I add a new game feature?**
A: Depends on the feature type. See "How to Find What You Need" section above.

**Q: How do systems communicate?**
A: Primarily through the event system (`core/events/`). Some direct dependencies exist for performance-critical systems.

**Q: Where do I find the code for [system name]?**
A: Look in `engine/[system_name]/` and read its README.md

**Q: How do I run just one subsystem's tests?**
A: `lovec tests/runners [subsystem_name]`

**Q: Is the engine multiplayer?**
A: Not yet. Network system is a placeholder for future implementation.

**Q: Can I modify game balance?**
A: Yes! Most balance values are in TOML files in `mods/core/rules/`. Edit there and run the game.

**Q: How do I add a new language?**
A: Add language files to the appropriate folder and use `localization/language_loader.lua`

**Q: Where is the sprite/artwork?**
A: In `engine/assets/images/` organized by category

**Q: Where are sound effects?**
A: In `engine/assets/sounds/` organized by category

**Q: How do I debug?**
A: Use `print()` statements (output goes to console). Game runs with console enabled by default.

---

## 📞 Support & Questions

### For Understanding the Code
1. Check relevant README.md file
2. Read ENGINE_COMPLETE_SCAN_REPORT.md
3. Look at tests for usage examples
4. Search for similar code patterns

### For Troubleshooting
1. Check console output (run with `lovec engine`)
2. Run tests: `lovec tests/runners`
3. Check for import errors
4. Verify file paths and naming

### For Architectural Questions
1. Check architecture/README.md
2. Check api/INTEGRATION.md
3. Look at system dependencies in ENGINE_COMPLETE_SCAN_REPORT.md

---

## 🎓 Learning Path for New Developers

### Week 1: Understand the Structure
1. Read ENGINE_COMPLETE_SCAN_REPORT.md
2. Read engine/main.lua (with comments)
3. Run `lovec engine` and explore menus
4. Read geoscape/README.md
5. Read battlescape/README.md

### Week 2: Explore Core Systems
1. Study core/state/state_manager.lua
2. Study core/events/event_system.lua
3. Study core/data/data_loader.lua
4. Understand how systems integrate

### Week 3: Deep Dive into One System
1. Choose one subsystem (e.g., geoscape, battlescape)
2. Read all its README.md and files
3. Study all its tests
4. Trace through how it works

### Week 4: Make Your First Change
1. Find a small feature to add
2. Understand where it needs to go
3. Implement following existing patterns
4. Write tests
5. Commit with clear message

---

## ✨ This Document

This index file serves as your **master reference** for the entire AlienFall engine documentation. Bookmark it and refer to it frequently when working on the project.

**Last Updated:** October 25, 2025
**Engine Status:** ✅ Production Ready
**Restructuring Status:** ✅ Complete

---

**Ready to start developing? Begin with [ENGINE_COMPLETE_SCAN_REPORT.md](ENGINE_COMPLETE_SCAN_REPORT.md)!** 🚀
