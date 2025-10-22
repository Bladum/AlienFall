# Project Reorganization Plan - AlienFall

**Objective:** Transform the project from its current fragmented structure into a clean, purpose-driven architecture that supports professional game development and modding.

**Current State Issues:**
- `engine/`, `docs/`, `wiki/`, `mods/`, `tests/`, `geoscape/` folders are duplicating or conflicting
- No clear separation between: pure design, API specs, implementation guides, actual code, mod content, and tools
- Documentation spread across multiple locations with unclear purpose
- Task management is in `tasks/` but not well integrated with other structures
- Temporary files created ad-hoc instead of in dedicated location

---

## Proposed Structure (Level 1: Top-level Folders)

```
c:\Users\tombl\Documents\Projects\
├── design/              [PURE DESIGN LAYER - Ideas & Mechanics Only]
├── api/                 [API SPECIFICATION LAYER - TOML Schema Docs]
├── architecture/        [IMPLEMENTATION GUIDES - How to Build Systems]
├── engine/              [ACTUAL IMPLEMENTATION - Love2D Lua Game]
├── mods/                [MOD CONTENT - Actual TOML Game Data]
├── tests/               [UNIT & INTEGRATION TESTS]
├── tools/               [DEVELOPMENT UTILITIES]
├── tasks/               [TASK MANAGEMENT - AI Agent Tasks]
├── temp/                [TEMPORARY FILES - Auto-generated Content]
├── lore/                [CREATIVE ASSETS - Story, Images, Ideas]
├── README.md
├── run_xcom.bat
├── run_tests.bat
└── project.toml         [Optional: Project Metadata]
```

---

## Layer 1: `design/` - Pure Game Design (No Code)

**Purpose:** Game mechanics, balance ideas, systems design, written in natural language and diagrams.

**Contents:**
- Mechanics specifications (turn system, combat rules, economy dynamics)
- Game balance documents (difficulty curves, progression)
- Narrative design (story, campaigns, lore structure)
- UI/UX sketches and workflows (user interaction flows)
- System interactions (how subsystems relate to each other)

**Current files to migrate:**
- `wiki/systems/*.md` (strategic layer docs)
- `wiki/architecture/*.md` (system design docs)
- `wiki/design/*.md` (mechanics)
- `docs/diagrams/` (visual design)

**Structure:**
```
design/
├── README.md
├── systems/               [Game system documentation]
│   ├── battlescape/      [Tactical combat rules]
│   ├── geoscape/         [Strategic world management]
│   ├── basescape/        [Base building]
│   ├── economy/          [Finance, research, manufacturing]
│   ├── progression/      [Character progression, traits]
│   ├── ai/               [AI behavior, decision trees]
│   └── ...
├── balance/              [Game balance tuning]
├── narrative/            [Story structure, campaigns]
└── ui_ux/               [Interface designs]
```

---

## Layer 2: `api/` - API Specification (Bridge Between Design & Implementation)

**Purpose:** TOML structure documentation. What data types exist, what fields are required/optional, how to use them. NOT Lua code, pure data schema.

**Contents:**
- TOML schema definitions for all game data types (units, weapons, facilities, missions, etc.)
- Comprehensive field documentation (what each keyword does)
- Validation rules (required fields, min/max values, dependencies)
- Complete examples for each data type
- Cross-references between related schemas (e.g., weapon links to ammunition)

**Key insight:** This is the CONTRACT between modders, designers, and the engine.

**Structure:**
```
api/
├── README.md                    [Schema guide & quick start]
├── QUICK_REFERENCE.md           [Cheat sheet]
├── units_schema.md              [Unit entity definition]
├── weapons_schema.md            [Weapon data structure]
├── armors_schema.md
├── facilities_schema.md
├── missions_schema.md
├── campaigns_schema.md
├── factions_schema.md
├── technology_schema.md
├── items_schema.md
├── economy_schema.md
├── crafts_schema.md
├── geoscape_schema.md
├── narratives_schema.md
├── ai_config_schema.md
└── validation/                  [Validation rules]
    ├── constraints.md           [Required fields, ranges]
    ├── relationships.md         [Cross-entity references]
    └── examples/
        ├── unit_example.toml
        ├── weapon_example.toml
        └── ...
```

---

## Layer 3: `architecture/` - Implementation Guides

**Purpose:** How to BUILD systems using the TOML API. Bridges design and implementation.

**Contents:**
- Step-by-step implementation guides for each major system
- Architecture patterns (data loading, module structure)
- Code organization best practices
- Integration points between systems
- Development workflow guides
- Reference implementations

**Current files to migrate:**
- `docs/` (most of it - design architecture)
- Some `wiki/guides/` content
- Development standards

**Structure:**
```
architecture/
├── README.md
├── QUICK_START.md               [How to implement a simple system]
├── patterns/
│   ├── data_loading.md          [How to load from TOML into engine]
│   ├── module_structure.md      [Folder/file organization]
│   ├── state_management.md
│   └── ...
├── systems/                     [Implementation guides per system]
│   ├── units_implementation.md
│   ├── weapons_implementation.md
│   ├── combat_implementation.md
│   ├── ai_implementation.md
│   └── ...
├── best_practices/
│   ├── lua_code_standards.md
│   ├── documentation_standards.md
│   ├── testing_strategies.md
│   └── performance_optimization.md
└── workflows/
    ├── adding_new_item_type.md
    ├── debugging_guide.md
    └── common_patterns.md
```

---

## Layer 4: `engine/` - Actual Implementation (Love2D Game)

**Purpose:** The playable game. All Lua code, loading systems, rendering, game logic.

**Should contain:**
- Core systems (state management, data loading, configuration)
- Subsystems organized by game layer (geoscape, basescape, battlescape, etc.)
- UI framework and widgets
- Audio, graphics, input handling

**Should NOT contain:**
- Game design documents (→ `design/`)
- TOML data schemas (→ `api/`)
- Implementation guides (→ `architecture/`)
- Temporary files (→ `temp/`)

**Current structure (mostly correct, needs cleanup):**
```
engine/
├── main.lua
├── conf.lua
├── core/                        [Essential systems]
│   ├── state_manager.lua
│   ├── data_loader.lua
│   ├── mod_manager.lua
│   └── ...
├── geoscape/                    [Strategic layer]
├── basescape/                   [Base management]
├── battlescape/                 [Tactical combat]
├── interception/                [Craft combat]
├── economy/                     [Finance, research, manufacturing]
├── politics/                    [Diplomacy, factions]
├── content/                     [Reusable game content types]
│   ├── units/
│   ├── weapons/
│   ├── items/
│   └── ...
├── gui/                         [UI framework - unified from ui/, scenes/, widgets/]
├── assets/                      [Graphics, sounds, fonts]
├── utils/                       [Utility libraries]
├── analytics/
├── accessibility/
├── localization/
├── lore/
├── tutorial/
└── systems/                     [Cross-cutting systems]
    ├── audio_system.lua
    ├── save_system.lua
    ├── camera_system.lua
    └── ...
```

---

## Layer 5: `mods/` - Mod Content (Actual Game Data)

**Purpose:** TOML files that define the actual game content. Not schemas, but DATA.

**Contains:**
- `core/` - Default game content (units, weapons, factions, missions, etc.)
- `examples/` - Example mods showing API usage
- Community mods (user-created content)

**Structure:**
```
mods/
├── README.md                [Modding guide]
├── core/                    [Default game content - structured like TOML API]
│   ├── rules/
│   │   ├── units/           [Unit definitions matching api/units_schema.md]
│   │   ├── weapons/         [Weapon data]
│   │   ├── armors/
│   │   ├── items/
│   │   └── facilities/
│   ├── missions/            [Mission templates]
│   ├── campaigns/           [Campaign definitions]
│   ├── factions/            [Faction data]
│   ├── technology/          [Tech trees]
│   ├── narratives/          [Story events]
│   ├── geoscape/            [World setup]
│   ├── economy/             [Pricing, suppliers]
│   └── generation/          [Procedural generation configs]
├── examples/
│   ├── minimal_mod/          [Simplest possible mod - 1 unit]
│   └── complete_mod/         [Full example using all features]
└── community/               [Space for user mods]
```

---

## Layer 6: `tests/` - Automated Tests

**Purpose:** Unit tests, integration tests, mock data.

**Should contain:**
- Test files organized by system (unit/, integration/, performance/)
- Mock data generators and fixtures
- Test runners
- Test documentation

**Should NOT contain:**
- Temporary test outputs (→ `temp/`)

**Structure:**
```
tests/
├── README.md
├── mock/                    [Test fixtures & mock data]
│   ├── README.md
│   ├── generators/          [Mock data generation scripts]
│   └── data/                [Generated mock TOML files]
├── unit/                    [Unit tests]
│   ├── battlescape/
│   ├── geoscape/
│   ├── economy/
│   └── ...
├── integration/             [Integration tests]
├── performance/             [Performance benchmarks]
└── runners/                 [Test execution scripts]
    ├── run_all_tests.lua
    └── run_suite.lua
```

---

## Layer 7: `tools/` - Development Utilities

**Purpose:** Scripts and tools for developers. Validation, generation, editing.

**Contents:**
- Map editors
- Asset validators
- TOML validators
- Mock data generators
- Import scanners
- Documentation tools
- Conversion utilities

**Should NOT contain:**
- Temporary outputs (→ `temp/`)

**Structure:**
```
tools/
├── README.md
├── validators/
│   ├── validate_toml.lua
│   ├── validate_links.lua
│   └── validate_assets.lua
├── generators/
│   ├── mock_data_generator.lua
│   ├── sprite_generator.lua
│   └── documentation_generator.lua
├── editors/
│   ├── map_editor/
│   └── world_editor/
├── scripts/
│   ├── import_scanner.lua
│   └── archive/              [Old/deprecated tools]
└── archive/                 [Historical tools]
```

---

## Layer 8: `tasks/` - Task Management

**Purpose:** AI Agent task planning and tracking.

**Structure:**
```
tasks/
├── README.md                [Task system documentation]
├── tasks.md                 [Master task tracking]
├── TASK_TEMPLATE.md         [Template for new tasks]
├── TODO/                    [Tasks not yet started]
│   ├── TASK-001-description.md
│   └── ...
├── IN_PROGRESS/             [Currently being worked on]
├── DONE/                    [Completed tasks with reports]
└── ANALYSIS/                [Planning documents, research]
```

---

## Layer 9: `temp/` - Temporary Files (NEW)

**Purpose:** Agent-generated files, logs, reports, temporary data.

**Rules:**
- Use `os.getenv("TEMP")` for actual temp directory
- This folder for AI agent session files only
- Auto-cleanup policy (delete monthly or per session)

**Structure:**
```
temp/
├── session_logs/            [AI agent session transcripts]
├── generated_reports/       [Analysis & summary reports]
├── mock_data_output/        [Generated test data]
└── .gitignore               [Prevent committing temp files]
```

---

## Layer 10: `lore/` - Creative Assets (NEW)

**Purpose:** Story ideas, creative direction, prompt engineering, image concepts.

**NOT part of engine or mods, but inspiration and resources.**

**Structure:**
```
lore/
├── README.md
├── story/                   [Narrative ideas, campaign outlines]
├── concepts/                [World-building, faction concepts]
├── prompts/                 [Image generation prompts]
├── characters/              [Character bios, personalities]
├── world/                   [Geography, history, politics]
└── images/                  [Concept art, inspiration]
```

---

# Migration Strategy

## Phase 1: Create New Structure (No File Changes Yet)

1. Create all new folders above
2. Create README.md files for each layer explaining purpose
3. Create `.gitkeep` files to ensure folders exist in git

## Phase 2: Audit Current Files (Understand What We Have)

For each current file, determine:
- **Purpose**: What does it document/do?
- **New Home**: Which layer should it go to?
- **Action**: Keep/Archive/Delete/Refactor?

### Audit Categories:

**DESIGN Files (→ `design/`):**
- `wiki/systems/*.md` - Game system mechanics
- `wiki/architecture/*.md` - System architecture
- `wiki/design/*.md` - Game design
- `wiki/guides/*.md` - Usage guides
- `docs/diagrams/` - Visual designs

**API Files (→ `api/`):**
- `wiki/api/` - API documentation (mostly already there!)
- `docs/mods/toml_schemas/` - TOML schema docs

**ARCHITECTURE Files (→ `architecture/`):**
- `docs/` (most of it)
- Development standards
- Implementation patterns

**ENGINE Files (→ `engine/` - already correct mostly):**
- All Lua code
- May need: unified GUI folder, move content folder

**MOD FILES (→ `mods/core/`):**
- `mods/core/rules/` - Rule definitions
- `mods/core/campaigns/` - Campaign data
- `mods/examples/` - Example mods

**TEST Files (→ `tests/` - mostly already correct):**
- Already well-organized

**TOOL Files (→ `tools/`):**
- `tools/` - mostly already there

**TEMP Files (→ `temp/`):**
- Create new folder
- Move any generated reports there

**LORE Files (→ `lore/`):**
- Create new folder
- Any creative/story content

## Phase 3: Migration Execution

1. Copy/move files to new locations
2. Update all cross-references (links in markdown)
3. Update `require()` statements in Lua files
4. Verify game runs: `lovec "engine"`
5. Verify tests pass: `run_tests.bat`

## Phase 4: Cleanup

1. Remove old empty folders
2. Archive old structure reference
3. Update main README.md
4. Create navigation guide

---

# File Movement Matrix

| Current Location | File Type | New Location | Action | Notes |
|---|---|---|---|---|
| `wiki/systems/*.md` | Design | `design/systems/` | Move | System mechanics |
| `wiki/architecture/*.md` | Design | `design/` | Move | Architecture overview |
| `wiki/api/*.md` | API Spec | `api/` | Move/Link | TOML documentation |
| `docs/` (most) | Architecture | `architecture/` | Move | Implementation guides |
| `docs/diagrams/` | Design | `design/diagrams/` | Move | Visual designs |
| `engine/` (all) | Implementation | `engine/` | Keep | Lua code |
| `mods/core/` | Mod Content | `mods/core/` | Keep | Game data |
| `tests/` (all) | Tests | `tests/` | Keep | Test files |
| `tools/` (all) | Tools | `tools/` | Keep | Development utilities |
| `tasks/` (all) | Task Mgmt | `tasks/` | Keep | Task tracking |
| `geoscape/` | Orphan | `design/systems/geoscape/` | Move | Geoscape design docs |
| Temp reports | Temporary | `temp/` | Move | Auto-generated |
| Lore/Story ideas | Creative | `lore/` | Move | Story assets |

---

# Validation Checklist

After reorganization:

- [ ] All `require()` statements in `engine/` still work
- [ ] Game runs without errors: `lovec "engine"`
- [ ] All tests pass: `run_tests.bat`
- [ ] All markdown links are valid (no broken references)
- [ ] Each layer folder has README.md
- [ ] No duplicate files in multiple locations
- [ ] `temp/` folder exists and has `.gitignore`
- [ ] `lore/` folder exists and is organized
- [ ] `api/` folder has all TOML schemas
- [ ] `design/` has all design documents
- [ ] `architecture/` has all implementation guides
- [ ] Top-level README.md explains new structure
- [ ] Navigation guide created (`NAVIGATION.md`)

---

# Expected Benefits After Reorganization

1. **Clear Purpose**: Each folder has one clear purpose
2. **No Duplication**: Files exist in ONE location
3. **Easy Navigation**: New developers know where to find things
4. **Modding Clarity**: Modders only need `api/` + `mods/` folders
5. **Development Clarity**: Developers only need `architecture/` + `engine/` + `tools/`
6. **Scalability**: New systems can be added following clear patterns
7. **Documentation Sync**: Less chance of design/code drift
8. **Task Management**: Clear connection between tasks and deliverables
9. **Temporary Files**: No clutter in project root or permanent folders
10. **Lore Organization**: Creative content organized and separated

---

# Questions to Decide

1. **Should `geoscape/` folder be deleted?** (It seems to contain only `crafts.md`)
2. **Should we archive OLD wiki files?** Or completely remove old structure?
3. **Should old `docs/` become `docs_old/` temporarily?** For reference during migration?
4. **Should `.gitignore` be updated?** To exclude `temp/` folder?
5. **Should we create a MIGRATION_GUIDE.md?** For documenting what moved where?

---

# Next Steps

1. Review this plan
2. Get approval on folder structure
3. Create new folder hierarchy
4. Audit all files (detailed spreadsheet)
5. Begin Phase 2-4 migration
6. Validate everything works
7. Delete old structure
8. Update documentation

