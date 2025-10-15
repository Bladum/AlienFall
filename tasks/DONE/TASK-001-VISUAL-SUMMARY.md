# Engine Restructure - Visual Summary

**Status:** PLANNING COMPLETE - AWAITING APPROVAL  
**Created:** October 14, 2025  
**Full Plan:** See `TASK-001-engine-restructure.md`

---

## 📊 Current vs Proposed Structure

### CURRENT Structure (Messy - Technical Categories)
```
engine/
├── assets/         ❌ Mixed: images, sounds, AND data files
├── basescape/      ❌ Too shallow: just init + logic/research
├── battlescape/    ❌ TOO BLOATED: 14 subdirs mixing everything
├── core/           ⚠️ Mixed: engine + mods + pathfinding
├── geoscape/       ⚠️ Mixed: world + politics + economy
├── interception/   ✅ OK but minimal
├── lore/           ⚠️ Flat: no organization
├── shared/         ⚠️ Mixed: entities + facilities
├── ui/             ❌ Just 3 menu files
├── utils/          ✅ OK
└── widgets/        ✅ OK but buried in engine/
```

**Problems:**
- 🔴 Battlescape: 14 folders mixing combat, AI, UI, rendering, systems, maps
- 🔴 No economy folder (scattered: research in basescape, marketplace in geoscape, manufacturing in shared)
- 🔴 No politics folder (scattered: karma, fame, relations in geoscape/systems)
- 🔴 No AI folder (only battlescape/ai exists)
- 🔴 Screens scattered everywhere (ui/, geoscape/, lore/)
- 🔴 Widgets buried in engine instead of top-level

---

### PROPOSED Structure (Clean - Feature Groups)

```
engine/
├── 🎬 scenes/              -- ALL GAME SCREENS (15+ screens)
│   ├── main_menu.lua
│   ├── geoscape_screen.lua
│   ├── basescape_screen.lua
│   ├── battlescape_screen.lua
│   ├── deployment_screen.lua
│   ├── research_screen.lua
│   ├── marketplace_screen.lua
│   └── ...
│
├── 🎨 widgets/             -- UI WIDGET LIBRARY (no changes)
│   ├── core/ buttons/ containers/
│   ├── display/ input/ navigation/
│   └── advanced/ combat/
│
├── 🏢 basescape/           -- BASE MANAGEMENT
│   ├── base/               -- Base construction
│   ├── facilities/         -- Facility types
│   └── services/           -- Storage, medical, training
│
├── 🌍 geoscape/            -- STRATEGIC WORLD
│   ├── world/              -- World map & state
│   ├── geography/          -- Provinces, regions, biomes, terrain
│   ├── systems/            -- Hex grid, day/night, detection
│   └── ui/                 -- Geoscape controls
│
├── ⚔️ battlescape/          -- TACTICAL COMBAT (10 clear folders)
│   ├── combat/             -- Combat mechanics (unit, weapons, damage)
│   ├── maps/               -- Map generation & pathfinding
│   ├── battlefield/        -- Battle state & turn management
│   ├── systems/            -- LOS, cover, inventory, abilities
│   ├── rendering/          -- 3D rendering & camera
│   ├── effects/            -- Animations, explosions, fire, smoke
│   ├── battle_ecs/         -- Alternative ECS battle system
│   ├── mapscripts/         -- Map scripting & commands
│   ├── logic/              -- Unit selection, recovery, progression
│   ├── entities/           -- Projectiles, etc.
│   ├── ui/                 -- Combat HUD components
│   ├── data/               -- Tilesets, terrains, mapscripts
│   └── utils/              -- Multitile utilities
│
├── ✈️ interception/         -- CRAFT INTERCEPTION
│   └── interception_combat.lua
│
├── 📖 lore/                -- CAMPAIGN & NARRATIVE
│   ├── calendar.lua
│   ├── campaign/           -- Campaign management
│   ├── missions/           -- Mission system
│   ├── factions/           -- Faction system
│   ├── events/             -- Game events (NEW)
│   └── quests/             -- Quest system (NEW)
│
├── 💰 economy/             -- ECONOMIC SYSTEMS (NEW!)
│   ├── research/           -- Research system
│   ├── production/         -- Manufacturing
│   ├── marketplace/        -- Trading, black market, salvage
│   └── finance/            -- Budget, funding, costs (NEW)
│
├── 🏛️ politics/            -- POLITICAL SYSTEMS (NEW!)
│   ├── organization/       -- Player organization (NEW)
│   ├── karma/              -- Karma system
│   ├── government/         -- Government types (NEW)
│   ├── fame/               -- Fame system
│   ├── relations/          -- Reputation, relations
│   └── diplomacy/          -- Diplomatic actions (NEW)
│
├── 📦 mods/                -- MOD MANAGEMENT (NEW!)
│   ├── mod_manager.lua
│   ├── mod_loader.lua
│   └── mod_validator.lua
│
├── 🤖 ai/                  -- AI SYSTEMS (NEW!)
│   ├── strategic/          -- Mission AI, resource AI (NEW)
│   ├── tactical/           -- Combat AI
│   ├── diplomacy/          -- Diplomatic AI (NEW)
│   └── pathfinding/        -- Shared pathfinding
│
├── ⚙️ core/                -- ENGINE CORE (simplified)
│   ├── state_manager.lua
│   ├── data_loader.lua
│   ├── save_system.lua
│   ├── audio_system.lua
│   ├── input_manager.lua   (NEW)
│   └── config.lua          (NEW)
│
├── 🎯 shared/              -- SHARED ENTITIES
│   ├── units/              -- Unit definitions
│   ├── crafts/             -- Craft definitions
│   ├── items/              -- Item definitions
│   ├── terrain/            -- Terrain types (NEW)
│   └── data/               -- Constants (NEW)
│
├── 🎨 assets/              -- ASSET LOADING (expanded)
│   ├── assets.lua          -- Asset manager
│   ├── image_loader.lua    (NEW)
│   ├── audio_loader.lua    (NEW)
│   ├── font_loader.lua     (NEW)
│   ├── data/               -- Config files
│   ├── fonts/
│   ├── images/
│   └── sounds/
│
└── 🔧 utils/               -- UTILITIES
    ├── viewport.lua
    ├── scaling.lua
    ├── spatial_hash.lua
    └── helpers.lua
```

---

## 🎯 Key Benefits

### 1. Feature Cohesion
- **Economy**: All economic features together (research, manufacturing, marketplace, finance)
- **Politics**: All political features together (karma, fame, relations, diplomacy)
- **AI**: All AI systems together (strategic, tactical, diplomacy)

### 2. Clear Separation
- **Scenes**: Full game screens (state machines)
- **Widgets**: Reusable UI components (no game logic)
- **[layer]/ui/**: Layer-specific UI components (not full screens)

### 3. Battlescape Clarity
**Before:** 14 mixed folders  
**After:** 10 clear purpose folders
- combat/ = combat mechanics
- maps/ = map generation
- battlefield/ = battle state
- systems/ = game systems
- rendering/ = 3D rendering
- effects/ = visual effects
- battle_ecs/ = ECS alternative
- mapscripts/ = map scripting
- logic/ = unit management
- ui/ = HUD components

### 4. Future-Proof
**Already supported:**
- ✅ Events system (lore/events/)
- ✅ Quest system (lore/quests/)
- ✅ Diplomacy (politics/diplomacy/)
- ✅ Organization progression (politics/organization/)
- ✅ Financial management (economy/finance/)

**Easy to add later:**
- 🔮 network/ (multiplayer)
- 🔮 localization/ (multi-language)
- 🔮 analytics/ (metrics)
- 🔮 accessibility/ (features)
- 🔮 tutorial/ (system)

---

## 📊 Statistics

### Scope
- **Files to move:** ~474 Lua files
- **require() paths to update:** ~800+ require statements
- **New folders to create:** 35+ folders
- **Estimated time:** 25-38 hours

### Risk Assessment
| Phase | Risk | Mitigation |
|-------|------|------------|
| Core/Utils | 🟢 LOW | Few dependencies |
| Scenes | 🟡 MEDIUM | State management changes |
| Geoscape | 🟡 MEDIUM | Many files |
| Basescape | 🟡 MEDIUM | Dependencies |
| Economy | 🟡 MEDIUM | Cross-layer |
| Politics | 🟡 MEDIUM | Cross-layer |
| AI | 🟡 MEDIUM | Combat affects |
| **Battlescape** | 🔴 **HIGH** | **474 files, many deps** |

### Migration Strategy
1. ✅ **Create structure** (1 hour)
2. 🟢 **Move core/utils** (2 hours)
3. 🟡 **Extract scenes** (3 hours)
4. 🟡 **Reorganize geoscape** (4 hours)
5. 🟡 **Reorganize basescape** (2 hours)
6. 🔴 **Reorganize battlescape** (10 hours) ⚠️ HIGH RISK
7. 🟡 **Create economy** (3 hours)
8. 🟡 **Create politics** (3 hours)
9. 🟡 **Create AI** (2 hours)
10. 🟡 **Reorganize lore** (2 hours)
11. 🟢 **Create mods** (1 hour)
12. 🟢 **Reorganize assets** (2 hours)
13. 🟢 **Update shared** (1 hour)
14. 🔵 **Testing** (6 hours)
15. 📝 **Documentation** (3 hours)

---

## 🚀 What Happens Next?

### Option 1: Approve & Execute
1. Review the detailed plan in `TASK-001-engine-restructure.md`
2. Approve the structure
3. Begin Phase 1 (create folders)
4. Execute incrementally with testing after each phase

### Option 2: Request Modifications
- Suggest changes to folder structure
- Request different organization patterns
- Ask for clarification on any decisions

### Option 3: Defer
- Continue with current structure
- Revisit restructure later
- Focus on feature development first

---

## 📚 Full Documentation

**Complete details:** `tasks/TODO/TASK-001-engine-restructure.md`

Includes:
- ✅ Current structure analysis
- ✅ Proposed structure (full detail)
- ✅ Complete file movement map
- ✅ Before/after require() paths
- ✅ Phase-by-phase implementation plan
- ✅ Testing strategy
- ✅ Risk mitigation
- ✅ Success criteria
- ✅ Future-proofing recommendations

---

## ❓ Questions to Answer

1. **Approve this structure?** Any changes needed?
2. **When to execute?** Now or later?
3. **Phased approach?** All at once or incremental?
4. **Priority?** High priority or defer?
5. **Additional folders?** Want network/, localization/, etc. now?

---

**Status:** ⏸️ Awaiting your decision to proceed!
