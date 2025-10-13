# COMPLETE Geoscape Implementation Plan - Master Index

**Created:** October 13, 2025  
**Status:** Ready for Implementation  
**Total Time:** 240 hours (30 days / 6 weeks)

---

## Overview

This is the **complete implementation plan** for the Geoscape strategic layer, combining:

1. **TASK-025**: Core Geoscape Infrastructure (140 hours)
2. **TASK-026**: Lore & Mission System (100 hours)

Together, these tasks create a **fully functional strategic layer** with dynamic mission generation, faction progression, and escalating threats.

---

## Quick Navigation

### TASK-025: Geoscape Master Implementation (140h)

| Document | Purpose |
|----------|---------|
| [TASK-025-geoscape-master-implementation.md](TASK-025-geoscape-master-implementation.md) | Complete core implementation plan |
| [GEOSCAPE-INDEX.md](GEOSCAPE-INDEX.md) | Quick navigation and overview |
| [GEOSCAPE-QUICK-REFERENCE.md](GEOSCAPE-QUICK-REFERENCE.md) | Core mechanics and APIs |
| [GEOSCAPE-ARCHITECTURE-DIAGRAM.md](GEOSCAPE-ARCHITECTURE-DIAGRAM.md) | System architecture and data flow |
| [GEOSCAPE-IMPLEMENTATION-CHECKLIST.md](GEOSCAPE-IMPLEMENTATION-CHECKLIST.md) | Phase-by-phase tracking |

### TASK-026: Lore & Mission System (100h)

| Document | Purpose |
|----------|---------|
| [TASK-026-geoscape-lore-mission-system.md](TASK-026-geoscape-lore-mission-system.md) | Complete lore system plan |
| [LORE-SYSTEM-QUICK-REFERENCE.md](LORE-SYSTEM-QUICK-REFERENCE.md) | Faction, mission, quest mechanics |

---

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    GEOSCAPE STRATEGIC LAYER                 │
└─────────────────────────────────────────────────────────────┘
                          │
        ┌─────────────────┴─────────────────┐
        ▼                                   ▼
┌──────────────────┐              ┌──────────────────┐
│  CORE GEOSCAPE   │              │  LORE & MISSIONS │
│    (TASK-025)    │              │    (TASK-026)    │
│    140 hours     │              │    100 hours     │
└──────────────────┘              └──────────────────┘
        │                                   │
        ▼                                   ▼
┌──────────────────┐              ┌──────────────────┐
│ • Universe       │              │ • Factions       │
│ • World (80×40)  │              │ • Campaigns      │
│ • Provinces      │              │ • Missions       │
│ • Hex Grid       │              │   - Site         │
│ • Calendar       │              │   - UFO          │
│ • Day/Night      │              │   - Base         │
│ • Countries      │              │ • Scripts        │
│ • Regions        │              │ • Quests         │
│ • Biomes         │              │ • Events         │
│ • Crafts         │              │ • Escalation     │
│ • Bases          │              │                  │
│ • Portals        │              │                  │
│ • Travel         │              │                  │
│ • Radar          │              │                  │
└──────────────────┘              └──────────────────┘
```

---

## Implementation Timeline

### Combined Implementation (240 hours)

**Recommended Approach:** Implement TASK-025 first (Phases 1-4), then TASK-026

**Rationale:** Lore system depends on Calendar, Province, World, Travel systems

---

## Phase Breakdown

### TASK-025: Core Geoscape (140h)

| Phase | System | Hours | Dependencies |
|-------|--------|-------|--------------|
| 1 | Core Data & Hex Grid | 18h | None |
| 2 | Calendar & Time | 10h | Phase 1 |
| 3 | Geographic & Political | 16h | Phase 1 |
| 4 | Craft & Travel | 20h | Phases 1-2 |
| 5 | Base Management | 10h | Phases 1, 3-4 |
| 6 | Universe & Portals | 12h | Phases 1, 4 |
| 7 | UI Implementation | 30h | Phases 1-6 |
| 8 | Integration & Polish | 14h | Phases 1-7 |
| 9 | Documentation | 10h | All phases |

### TASK-026: Lore & Missions (100h)

| Phase | System | Hours | Dependencies |
|-------|--------|-------|--------------|
| 1 | Core Data (Faction, Mission, Campaign) | 16h | TASK-025 Phase 1 |
| 2 | Mission Scripting | 18h | TASK-026 Phase 1 |
| 3 | Quest & Event | 14h | TASK-025 Phase 2 |
| 4 | Integration | 12h | TASK-025 Phase 8, All TASK-026 phases |
| 5 | UI & Visualization | 16h | TASK-025 Phase 7 |
| 6 | Testing & Polish | 14h | All phases |
| 7 | Documentation | 10h | All phases |

---

## Key Features Summary

### From TASK-025 (Core Geoscape)

✅ **80×40 Hex World Map** (1 tile = 500km)  
✅ **Province Graph** with A* pathfinding  
✅ **Calendar System** (1 turn = 1 day, 360 days/year)  
✅ **Day/Night Cycle** (moves 4 tiles/day)  
✅ **Craft Deployment** (hex pathfinding, fuel costs)  
✅ **Country Relations** (-2 to +2, affects funding)  
✅ **Biomes & Regions** (mission targeting, scoring)  
✅ **Bases** (construction with cost modifiers)  
✅ **Portals** (inter-world travel)  
✅ **Radar Detection** (auto-scan on arrival)  
✅ **Multi-World Support** (Earth, Mars, etc.)

### From TASK-026 (Lore & Missions)

✅ **Factions** (unique lore, units, items, research trees)  
✅ **Campaigns** (script-based mission spawning)  
✅ **Mission Types:**
   - Site (static, expiring)
   - UFO (moving, scripted behavior)
   - Base (permanent, spawns missions)  
✅ **Mission Scripts** (Lua-based UFO movement, base growth)  
✅ **Escalation** (2 → 10 campaigns/month over 2 years)  
✅ **Quest System** (flexible conditions, rewards/penalties)  
✅ **Event System** (random monthly events)  
✅ **Faction Disabling** (research to stop campaigns)  
✅ **Relation-Based Difficulty** (affects mission frequency)

---

## File Structure Overview

### Core Geoscape (~40 files)

```
engine/geoscape/
├── init.lua
├── logic/
│   ├── universe.lua
│   ├── world.lua
│   ├── province.lua
│   ├── province_graph.lua
│   ├── craft.lua
│   ├── base.lua
│   ├── country.lua
│   ├── region.lua
│   ├── biome.lua
│   ├── portal.lua
│   └── pathfinding.lua
├── systems/
│   ├── hex_grid.lua
│   ├── calendar.lua
│   ├── daynight_cycle.lua
│   ├── travel_system.lua
│   ├── radar_system.lua
│   ├── base_construction.lua
│   ├── craft_return.lua
│   └── turn_processor.lua
├── rendering/
│   ├── world_renderer.lua
│   └── daynight_overlay.lua
├── ui/
│   ├── world_map.lua
│   ├── province_panel.lua
│   ├── craft_selector.lua
│   ├── range_highlighter.lua
│   ├── calendar_widget.lua
│   └── country_relations_panel.lua
└── tests/
    └── (5+ test files)
```

### Lore & Missions (~30 files)

```
engine/geoscape/
├── logic/
│   ├── faction.lua
│   ├── mission.lua
│   ├── mission_site.lua
│   ├── mission_ufo.lua
│   ├── mission_base.lua
│   ├── campaign.lua
│   ├── mission_script.lua
│   ├── quest.lua
│   └── event.lua
├── systems/
│   ├── script_engine.lua
│   ├── campaign_manager.lua
│   ├── mission_manager.lua
│   ├── quest_manager.lua
│   ├── event_manager.lua
│   └── faction_research.lua
├── ui/
│   ├── mission_panel.lua
│   ├── faction_panel.lua
│   ├── campaign_panel.lua
│   ├── quest_panel.lua
│   └── event_notification.lua
├── rendering/
│   └── mission_renderer.lua
└── tests/
    └── (6+ test files)
```

### Data Files (~15 files)

```
engine/data/
├── worlds/
│   ├── earth.toml
│   ├── earth_provinces.toml
│   └── mars.toml
├── factions.toml
├── campaigns.toml
├── quests.toml
├── events.toml
├── countries.toml
├── regions.toml
├── biomes.toml
├── crafts.toml
├── bases.toml
├── portals.toml
├── universe.toml
└── scripts/
    ├── ufo_scripts.lua
    └── base_scripts.lua
```

**Total: ~70 files + 15 data files = 85 files**

---

## Critical Mechanics

### Escalation System

```
Quarter 1 (Months 1-3):   2 campaigns/month
Quarter 2 (Months 4-6):   3 campaigns/month
Quarter 3 (Months 7-9):   4 campaigns/month
Quarter 4 (Months 10-12): 5 campaigns/month
Quarter 5 (Months 13-15): 6 campaigns/month
Quarter 6 (Months 16-18): 7 campaigns/month
Quarter 7 (Months 19-21): 8 campaigns/month
Quarter 8 (Months 22-24): 9 campaigns/month
Quarter 9+ (Months 25+):  10 campaigns/month (capped)
```

**Formula:** `min(2 + (quarter - 1), 10)`

### Turn Processing Order

```
1.  Advance calendar (+1 day)
2.  Update day/night cycle (4 tiles)
3.  Reset craft travel points
4.  Update missions (UFO movement, base growth, daily)
5.  Update campaigns (weekly mission spawning)
6.  Monthly: Spawn new campaigns (1st of month)
7.  Monthly: Update country funding (1st of month)
8.  Mid-month: Trigger random events (15th of month)
9.  Update quests (check conditions)
10. Process economy
11. Trigger region events
12. Save game state
```

### Faction Progression

```
1. Faction spawns campaigns monthly
2. Campaigns spawn missions weekly/delayed
3. Player intercepts missions
4. Player completes research tree
5. Final research disables faction
6. All faction campaigns removed
7. All faction missions removed
8. Faction threat eliminated
```

---

## Acceptance Criteria (Combined)

### Core Geoscape
- [x] 80×40 hex world map renders correctly
- [x] Day/night cycle visually moves 4 tiles per day
- [x] User can deploy crafts via base → craft → target flow
- [x] Craft travel costs fuel from base stockpile
- [x] Radar automatically detects missions on arrival
- [x] Calendar advances 1 day per turn (360 days/year)
- [x] Country relations affect monthly funding
- [x] Multiple worlds accessible via portals
- [x] Province graph pathfinding respects terrain types
- [x] All UI elements snap to 24×24 pixel grid

### Lore & Missions
- [x] Campaigns spawn on 1st of month with escalation
- [x] Each faction has unique lore, units, research tree
- [x] Player can research faction tech to disable campaigns
- [x] Missions spawn via campaign scripts (weekly/delayed)
- [x] UFO missions move between provinces via scripts
- [x] Base missions spawn additional missions over time
- [x] Quest system supports complex conditions (AND/OR)
- [x] Random events trigger monthly (15th) with effects
- [x] Faction relations affect mission frequency
- [x] Relation -2 triggers special hostile missions
- [x] Final research disables faction campaigns/missions

---

## Development Workflow

### Recommended Implementation Order

1. **Start with TASK-025 Phases 1-4** (64 hours)
   - Hex Grid, World, Province, Calendar, Travel
   - This creates the foundation for lore systems

2. **Implement TASK-026 Phases 1-3** (48 hours)
   - Factions, Missions, Campaigns, Scripts, Quests, Events
   - Depends on Calendar and Province systems

3. **Complete TASK-025 Phases 5-9** (76 hours)
   - Bases, Portals, UI, Integration, Documentation
   - UI will include both core and lore elements

4. **Complete TASK-026 Phases 4-7** (52 hours)
   - Integration, UI, Testing, Documentation
   - Final integration and polish

### Testing Strategy

**Unit Tests:** After each phase  
**Integration Tests:** After Phases 4 (TASK-025) and 4 (TASK-026)  
**Manual Testing:** Continuous with `lovec "engine"`

---

## Quick Start Guide

### For Developers

1. **Read Documentation:**
   - Start with `GEOSCAPE-INDEX.md`
   - Read `TASK-025-geoscape-master-implementation.md`
   - Read `TASK-026-geoscape-lore-mission-system.md`
   - Use Quick Reference docs for lookup

2. **Begin Implementation:**
   - Follow `GEOSCAPE-IMPLEMENTATION-CHECKLIST.md`
   - Start with TASK-025 Phase 1 (Hex Grid)
   - Mark checkboxes as you complete tasks

3. **Track Progress:**
   - Update checklist checkboxes
   - Update `tasks/tasks.md` with status
   - Move tasks through TODO → IN_PROGRESS → DONE

4. **Run & Test:**
   - Always run: `lovec "engine"`
   - Use F9 to toggle hex grid overlay
   - Check console for errors/warnings
   - Print debug messages: `print("[Module] Message")`

---

## Important Reminders

1. **Always run with Love2D console:** `lovec "engine"`
2. **All UI must snap to 24×24 pixel grid**
3. **All temp files go to:** `os.getenv("TEMP")`
4. **Use print for debugging:** `print("[Module] Message")`
5. **Update checklists as you work**
6. **Test frequently with F9 (grid overlay)**
7. **Document all public APIs**
8. **No global variables - use `local`**
9. **TASK-026 depends on TASK-025 Phases 1-4**

---

## Resource Links

### Task Documents
- [tasks/tasks.md](../../tasks.md) - Central task tracking
- [TASK_TEMPLATE.md](../../TASK_TEMPLATE.md) - Template for new tasks

### Wiki Documentation
- [wiki/API.md](../../../wiki/API.md) - API reference
- [wiki/FAQ.md](../../../wiki/FAQ.md) - Common questions
- [wiki/DEVELOPMENT.md](../../../wiki/DEVELOPMENT.md) - Development guide

### Love2D
- https://love2d.org/wiki/Main_Page
- Lua Manual: https://www.lua.org/manual/5.1/

### References
- Hex Grid Math: https://www.redblobgames.com/grids/hexagons/
- A* Pathfinding: https://www.redblobgames.com/pathfinding/a-star/
- X-COM Geoscape: https://www.ufopaedia.org/index.php/Geoscape

---

## Progress Tracking

### TASK-025: Core Geoscape
- **Status:** TODO
- **Progress:** 0/140 hours (0%)
- **Current Phase:** Not Started

### TASK-026: Lore & Missions
- **Status:** TODO
- **Progress:** 0/100 hours (0%)
- **Current Phase:** Not Started (waiting on TASK-025 Phases 1-4)

### Combined Progress
- **Total:** 0/240 hours (0%)
- **Estimated Completion:** 6 weeks from start

---

## Contact & Support

- Check `wiki/FAQ.md` for common questions
- Review `wiki/DEVELOPMENT.md` for workflow
- Use Love2D console for debugging: `lovec "engine"`
- All documentation in `tasks/TODO/` folder

---

**Ready to begin implementation! 🚀**

---

## Document Changelog

| Date | Change | Author |
|------|--------|--------|
| Oct 13, 2025 | Created combined master index | AI Agent |
| Oct 13, 2025 | Added TASK-025 (Core Geoscape) | AI Agent |
| Oct 13, 2025 | Added TASK-026 (Lore & Missions) | AI Agent |
| Oct 13, 2025 | Updated tasks.md with both tasks | AI Agent |

---

**End of Master Index**
