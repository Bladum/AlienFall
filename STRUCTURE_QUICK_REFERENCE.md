# Quick Visual Reference: Project Structure

## Current State (MESSY)

```
Project Root
├── engine/           ← Game code (good)
├── mods/             ← Game data (good)
├── docs/             ← ??? Mixed stuff
├── wiki/             ← ??? Mixed stuff
├── tests/            ← Tests (good)
├── geoscape/         ← ??? Orphan folder
├── tools/            ← Tools (good)
├── tasks/            ← Task management (good)
└── spritesheet_generator/  ← Tool (good)

PROBLEMS:
✗ Design docs scattered between docs/, wiki/, geoscape/
✗ API specs buried in wiki/api/ and docs/mods/toml_schemas/
✗ No dedicated temp folder
✗ No lore/creative assets folder
✗ Engine GUI split across 3 folders
✗ Unclear purpose of each folder
```

---

## Target State (CLEAN)

```
Project Root
├── design/           ← Pure mechanics (NO code, NO data)
├── api/              ← TOML schemas (documentation)
├── architecture/     ← Implementation guides (how-to docs)
├── engine/           ← Lua game code
├── mods/             ← TOML game content
├── tests/            ← Unit & integration tests
├── tools/            ← Development utilities
├── tasks/            ← Task management
├── temp/             ← Temporary files (NEW)
├── lore/             ← Creative assets (NEW)
└── README.md

BENEFITS:
✓ Each folder has ONE clear purpose
✓ Design/API/Code are in logical sequence
✓ Temp files cleanly separated
✓ Easy for new developers to navigate
✓ Modders know exactly where to look (api/ + mods/)
✓ Developers know where to work (architecture/ + engine/)
```

---

## What Goes Where? Quick Lookup Table

| I Need To... | Go To... | Examples |
|---|---|---|
| **Understand game mechanics** | `design/systems/` | Battlescape.md, Economy.md, AI.md |
| **Create mod content** | `api/` (read) + `mods/` (write) | Unit definitions, weapon data |
| **Add a new feature** | `architecture/` (read) + `engine/` (code) | Implementation guides |
| **Learn code patterns** | `architecture/patterns/` | Module structure, data loading |
| **Debug something** | `architecture/guides/` | DEBUGGING.md, TROUBLESHOOTING.md |
| **Check best practices** | `architecture/best_practices/` | CODE_STANDARDS.md |
| **Test my changes** | `tests/` | Unit tests, integration tests |
| **Validate my work** | `tools/` | Validators, scanners |
| **Track a task** | `tasks/` | task.md, TODO/, DONE/ |
| **Store test output** | `temp/` | Generated reports, logs |
| **Store story ideas** | `lore/` | Narrative, concepts, prompts |

---

## Layer-by-Layer Breakdown

### Layer 1: DESIGN (`design/`)
**"What should the game do?"**
- Game mechanics without code
- Balance decisions
- Narrative structure
- Visual mockups
```
design/
├── systems/          [Game mechanics: Battlescape, Geoscape, Economy, etc.]
├── balance/          [Game balance tuning]
├── narrative/        [Story structure]
├── ui_ux/            [Interface designs]
└── diagrams/         [Visual overviews]
```

### Layer 2: API (`api/`)
**"What's the data structure?"**
- TOML schema documentation
- Field definitions (required, optional, ranges)
- Validation rules
- Examples
```
api/
├── units_schema.md           [Unit entity definition]
├── weapons_schema.md         [Weapon data structure]
├── facilities_schema.md      [Base facilities]
├── missions_schema.md        [Mission definitions]
└── ...                       [20+ more schemas]
```

### Layer 3: ARCHITECTURE (`architecture/`)
**"How do I build it?"**
- Implementation guides
- Code patterns
- Development standards
- Best practices
```
architecture/
├── patterns/                 [How to structure code]
├── systems/                  [Implementation guides per system]
├── best_practices/           [Standards & conventions]
└── workflows/                [Development process]
```

### Layer 4: ENGINE (`engine/`)
**"The actual game code"**
- Lua implementation
- Game systems
- UI/Graphics/Audio
- All runnable code
```
engine/
├── core/             [Essential systems]
├── geoscape/         [Strategic layer]
├── basescape/        [Base management]
├── battlescape/      [Tactical combat]
├── gui/              [UI framework (unified)]
├── assets/           [Graphics, sounds]
└── ...               [15+ more folders]
```

### Layer 5: MODS (`mods/`)
**"The actual game content"**
- TOML data files (not code)
- Default game content
- Example mods
```
mods/
├── core/             [Default game content: units, weapons, factions, etc.]
├── examples/         [Example mods showing API usage]
└── community/        [Space for user mods]
```

### Layer 6: TESTS (`tests/`)
**"Does it work?"**
- Unit tests
- Integration tests
- Mock data
- Test utilities
```
tests/
├── mock/             [Test fixtures & generated data]
├── unit/             [Unit tests per system]
├── integration/      [Integration tests]
└── runners/          [Test execution scripts]
```

### Layer 7: TOOLS (`tools/`)
**"Helper utilities"**
- Validators
- Generators
- Editors
- Scripts
```
tools/
├── validators/       [TOML validators, link validators]
├── generators/       [Mock data generators]
├── editors/          [Map editor, world editor]
└── scripts/          [Helper scripts]
```

### Layer 8: TASKS (`tasks/`)
**"What needs to be done?"**
- Task definitions
- Tracking
- Completion reports
```
tasks/
├── tasks.md          [Master task list]
├── TODO/             [Unstarted tasks]
├── IN_PROGRESS/      [Current work]
└── DONE/             [Completed with reports]
```

### Layer 9: TEMP (`temp/`) [NEW]
**"Temporary generated files"**
- Agent session outputs
- Generated reports
- Test logs
- Temporary data
```
temp/
├── .gitignore        [Exclude from version control]
├── session_logs/     [AI agent transcripts]
├── generated_reports/[Analysis, summaries]
└── test_outputs/     [Test logs, results]
```

### Layer 10: LORE (`lore/`) [NEW]
**"Creative assets & inspiration"**
- Story concepts
- Character ideas
- Image prompts
- World-building
```
lore/
├── story/            [Narrative ideas, campaign outlines]
├── characters/       [Character bios, concepts]
├── concepts/         [World-building, faction concepts]
├── prompts/          [Image generation prompts]
└── images/           [Concept art, inspiration]
```

---

## File Movement Summary

| From → To | Folder | Files | Priority |
|---|---|---|---|
| `wiki/systems/` → `design/systems/` | move | 19 files | HIGH |
| `docs/diagrams/` → `design/diagrams/` | move | ~10 files | MEDIUM |
| `geoscape/crafts.md` → `design/systems/geoscape/` | move | 1 file | HIGH |
| `docs/developers/` → `architecture/guides/` | move | 4 files | MEDIUM |
| `docs/*STANDARDS.md` → `architecture/best_practices/` | move | 3 files | MEDIUM |
| `docs/mods/toml_schemas/` → `api/` | move/merge | 13 files | MEDIUM |
| `engine/scenes/` → `engine/gui/scenes/` | move | ~10 files | HIGH |
| `engine/ui/` → `engine/gui/ui/` | move | ~20 files | HIGH |
| `engine/widgets/` → `engine/gui/widgets/` | move | ~5 files | HIGH |
| `tests/phase5_*` → `tests/archive/` | archive | ~3 folders | LOW |
| (NEW) → `temp/` | create | auto | LOW |
| (NEW) → `lore/` | create | auto | LOW |

---

## Decision Checklist

Before starting migration, clarify these:

- [ ] **mods/new/** - What is it? (examples? community? delete?)
- [ ] **docs/Glossary.md** - Should be duplicated or keep one copy?
- [ ] **wiki/api/** - Move to api/ folder or keep in wiki/?
- [ ] **tests/phase5_*** - Archive or keep active?
- [ ] **Start immediately or staged?** (hybrid recommended)

---

## Three Ways Forward

### Option 1: Start TODAY - Phase 1 (1 hour)
```
1. Create: design/, api/, architecture/, temp/, lore/
2. Add: README.md files to each
3. Move: geoscape/crafts.md → design/systems/geoscape/
4. Test: Nothing broke
5. Result: Clean foundation for future work
```

### Option 2: Staged Approach (8-10 hours total)
```
Phase 1: Create structure (1h)
Phase 2: Move design docs (2-3h)
Phase 3: Move engine GUI (3-4h)
Phase 4: Cleanup (1-2h)
```

### Option 3: Deep Dive Today (8-10 hours)
```
Full migration from start to finish
Complete reorganization
Comprehensive validation
Single report at end
```

---

## Success Indicators

After reorganization, you should see:

✓ `design/` has all pure mechanics (0 Lua files)
✓ `api/` has all TOML schema docs
✓ `architecture/` has all implementation guides
✓ `engine/gui/` unified (no scenes/, ui/, widgets/ separate)
✓ All `require()` statements still work
✓ Game launches: `lovec "engine"`
✓ Tests pass: `run_tests.bat`
✓ No broken markdown links
✓ `temp/` and `lore/` ready for use

---

## Read These First

1. **PROJECT_REORGANIZATION_PLAN.md** - Strategic overview
2. **FILE_AUDIT_AND_MIGRATION_GUIDE.md** - Detailed audit
3. **This file** - Quick reference
4. **REORGANIZATION_NEXT_STEPS.md** - Decision framework

Then decide: Start TODAY? Or plan for later?

