# Project Reorganization - Visual Diagrams

## Current State: File Flow (MESSY)

```
        DESIGNER              MODDER              DEVELOPER
           |                   |                      |
           v                   v                      v
    wiki/systems/         wiki/api/              engine/
    (scattered design)   (scattered API)         (game code)
           |                   |                      |
           +--- docs/ --------+                       |
           |                   |                      |
           +-- geoscape/ ------+                      |
           |
           +-- docs/mods/toml_schemas/ (duplicate API!)
           |
      Confused where to look!     Modders confused!    OK, but
      Design not clear            API scattered        GUI messy
```

---

## Target State: File Flow (CLEAN)

```
        DESIGNER              MODDER              DEVELOPER
           |                   |                      |
           v                   v                      v
         design/              api/ + mods/        architecture/
                                                      + engine/
           |                   |                      |
      Clear mechanics      Clear schemas         Clear patterns
      One location        One location          One location
      No duplication      No confusion          No mess
```

---

## Migration Path: 4 Phases

```
PHASE 1: FOUNDATION (1 hour)
┌─────────────────────────────────────┐
│ Create 10 new folders               │
│ Add README.md files                 │
│ Move orphan files                   │
│ Test: Nothing broke                 │
└─────────────────────────────────────┘
                  ↓
           DECISION POINT
           ↙           ↘
       YES to      STOP HERE
      more         (Phase 1 done,
                    good foundation)
           ↓
PHASE 2: DOCUMENTATION (2-3 hours)
┌─────────────────────────────────────┐
│ Move wiki/systems/ → design/         │
│ Move docs/diagrams/ → design/        │
│ Move docs/developers/ → architecture/│
│ Update markdown links                │
│ Test: Links validate                 │
└─────────────────────────────────────┘
                  ↓
           DECISION POINT
           ↙           ↘
       YES to      STOP HERE
      more         (Phases 1-2 done)
           ↓
PHASE 3: ENGINE CONSOLIDATION (3-4 hours)  ← HIGHEST RISK
┌─────────────────────────────────────┐
│ Create engine/gui/ folder            │
│ Move engine/scenes/ → engine/gui/    │
│ Move engine/ui/ → engine/gui/        │
│ Move engine/widgets/ → engine/gui/   │
│ Update 100+ require() statements     │
│ Test: lovec "engine" launches        │
└─────────────────────────────────────┘
                  ↓
           DECISION POINT
           ↙           ↘
       YES to      STOP HERE
      more         (Phases 1-3 done)
           ↓
PHASE 4: CLEANUP (1-2 hours)
┌─────────────────────────────────────┐
│ Delete old empty folders             │
│ Update navigation guides             │
│ Final validation                     │
│ Create DONE report                   │
└─────────────────────────────────────┘
                  ↓
         REORGANIZATION COMPLETE ✓
```

---

## File Movement Matrix (Visual)

```
CURRENT                 NEW LOCATION        TYPE           RISK
─────────────────────────────────────────────────────────────────
wiki/systems/           design/systems/     Move 19 files  MEDIUM
├─ Battlescape.md       └─ Battlescape.md
├─ Geoscape.md          └─ Geoscape.md
└─ ... (17 more)        └─ ... (17 more)

wiki/api/               api/                 Move 30 files  LOW
├─ MASTER_INDEX.md      └─ MASTER_INDEX.md
├─ BATTLESCAPE.md       └─ BATTLESCAPE.md
└─ ... (28 more)        └─ ... (28 more)

docs/diagrams/          design/diagrams/     Move 10 files  LOW
├─ 01-game-structure.md └─ 01-game-structure.md
└─ ... (9 more)         └─ ... (9 more)

docs/developers/        architecture/guides/ Move 4 files   LOW
├─ DEBUGGING.md         └─ DEBUGGING.md
├─ WORKFLOW.md          └─ WORKFLOW.md
└─ ... (2 more)         └─ ... (2 more)

geoscape/crafts.md      design/systems/      Move 1 file    MINIMAL
                        geoscape/crafts.md

engine/scenes/          engine/gui/scenes/   Move 10 files  HIGH
├─ scene.lua            └─ scene.lua
└─ ... (9 more)         └─ ... (9 more)

engine/ui/              engine/gui/ui/       Move 20 files  HIGH
├─ hud.lua              └─ hud.lua
└─ ... (19 more)        └─ ... (19 more)

engine/widgets/         engine/gui/widgets/  Move 5 files   HIGH
├─ button.lua           └─ button.lua
└─ ... (4 more)         └─ ... (4 more)

(none)                  temp/                Create folder  MINIMAL
                        └─ (auto-populate)

(none)                  lore/                Create folder  MINIMAL
                        └─ (auto-populate)
```

---

## Folder Dependency Chain

```
┌──────────────────────────────────────────────────────────────────┐
│ DESIGNER reads design/                                            │
│    ↓                                                              │
│    Uses concepts as basis for...                                  │
│    ↓                                                              │
│ API developer writes api/ (TOML schemas)                          │
│    ↓                                                              │
│    API enables...                                                 │
│    ↓                                                              │
│ ARCHITECTURE writer creates architecture/ (implementation guides) │
│    ↓                                                              │
│    Guides + API enable...                                         │
│    ↓                                                              │
│ ENGINE developer codes engine/ (Lua implementation)               │
│    ↓                                                              │
│    Engine loads...                                                │
│    ↓                                                              │
│ MODDER creates content in mods/ (TOML game data)                  │
│    ↓                                                              │
│    Game runs with data, tested by...                              │
│    ↓                                                              │
│ TESTING using tests/ (unit/integration/mock data)                 │
│    ↓                                                              │
│    Validated by...                                                │
│    ↓                                                              │
│ TOOLS (validators, generators, editors)                           │
└──────────────────────────────────────────────────────────────────┘
     ↓         ↓              ↓
  Managed  Inspired by    Stored in
  via      creative        temp/
  tasks/   assets from
           lore/
```

---

## Risk Assessment: Each Move

```
MINIMAL RISK (Safe to do first)
┌────────────────────────────────────────┐
│ ✓ geoscape/crafts.md → design/         │
│   (1 file, no dependencies)            │
│ ✓ Move docs/ → architecture/           │
│   (documentation only)                 │
│ ✓ Create temp/ and lore/               │
│   (new folders, nothing breaks)        │
└────────────────────────────────────────┘

MEDIUM RISK (Test after moving)
┌────────────────────────────────────────┐
│ ⚠ Move wiki/systems/ → design/         │
│   (19 files, markdown links)           │
│   → FIX: Update links                  │
│ ⚠ Move wiki/api/ → api/                │
│   (30 files, cross-references)         │
│   → FIX: Update links                  │
└────────────────────────────────────────┘

HIGH RISK (Critical to test!)
┌────────────────────────────────────────┐
│ 🔴 Move engine/scenes/ → engine/gui/   │
│    (requires() might break)            │
│    → MUST: Update all require paths    │
│    → TEST: lovec "engine" still runs   │
│ 🔴 Move engine/ui/ → engine/gui/       │
│    (50+ require() statements)          │
│    → MUST: Search/replace all paths    │
│    → TEST: All UI still works          │
│ 🔴 Move engine/widgets/ → engine/gui/  │
│    (30+ cross-module dependencies)     │
│    → MUST: Verify all links           │
│    → TEST: Widgets still render        │
└────────────────────────────────────────┘
```

---

## Require() Update Strategy (Phase 3)

```
BEFORE:
┌─────────────────────────┐
│ local ui = require "engine.ui.hud"          │
│ local btn = require "engine.widgets.button" │
│ local scene = require "engine.scenes.menu"  │
└─────────────────────────┘

AFTER:
┌──────────────────────────────┐
│ local ui = require "engine.gui.ui.hud"          │
│ local btn = require "engine.gui.widgets.button" │
│ local scene = require "engine.gui.scenes.menu"  │
└──────────────────────────────┘

SEARCH/REPLACE RULES:
1. "engine.ui." → "engine.gui.ui."
2. "engine.widgets." → "engine.gui.widgets."
3. "engine.scenes." → "engine.gui.scenes."

FILES AFFECTED: ~100+ require statements across engine/
```

---

## Validation Test Sequence

```
TEST 1: Game Launch (Phase 3 critical)
┌─────────────────────────────────────────────┐
│ Command: lovec "engine"                     │
│ Expected: Game window opens without errors  │
│ Check: Console for "[ERROR]" messages       │
│ If FAIL: Debug require() paths              │
│ If PASS: Proceed                            │
└─────────────────────────────────────────────┘
           ↓
TEST 2: Unit Tests (All phases)
┌─────────────────────────────────────────────┐
│ Command: run_tests.bat                      │
│ Expected: All tests pass                    │
│ Check: Test output for failures             │
│ If FAIL: Fix broken tests                   │
│ If PASS: Proceed                            │
└─────────────────────────────────────────────┘
           ↓
TEST 3: Link Validation (Phase 2 critical)
┌─────────────────────────────────────────────┐
│ Command: tools/validate_docs_links.ps1      │
│ Expected: 0 broken links                    │
│ Check: Output report                        │
│ If FAIL: Fix broken markdown links          │
│ If PASS: Proceed                            │
└─────────────────────────────────────────────┘
           ↓
TEST 4: Manual Smoke Test
┌─────────────────────────────────────────────┐
│ 1. Launch game: lovec "engine"              │
│ 2. Click buttons, navigate menus            │
│ 3. Start battle scene                       │
│ 4. Check geoscape works                     │
│ Expected: All features work                 │
│ If FAIL: Debug specific feature             │
│ If PASS: DONE ✓                             │
└─────────────────────────────────────────────┘
```

---

## Before/After Comparison

```
BEFORE: "Where do I find X?"

"How does combat work?"
  → Check wiki/systems/Battlescape.md
  → Also check docs/?
  → Maybe engine/battlescape/?
  → CONFUSED! Too many places

"How do I create a unit?"
  → Check api/units_schema.md
  → Also check docs/mods/toml_schemas/units_schema.md?
  → Wait, which one is authoritative?
  → CONFUSED! Duplicates

"Where do I add new UI?"
  → engine/ui/?
  → engine/scenes/?
  → engine/widgets/?
  → CONFUSED! Three places

"Where do I store temp reports?"
  → Nowhere organized
  → Clutter project root
  → MESSY!
```

```
AFTER: "Where do I find X?"

"How does combat work?"
  → design/systems/Battlescape.md
  → FOUND! One place

"How do I create a unit?"
  → api/units_schema.md (learn schema)
  → architecture/systems/units_implementation.md (learn to code it)
  → mods/core/rules/units/ (see examples)
  → FOUND! Clear progression

"Where do I add new UI?"
  → engine/gui/
  → Then ui/, scenes/, or widgets/ subfolder
  → FOUND! One place with structure

"Where do I store temp reports?"
  → temp/generated_reports/
  → ORGANIZED! No clutter
```

---

## Decision Tree (Visual)

```
            START
             |
        Do you want to
      reorganize project?
             |
      ┌──────┴──────┐
      |             |
     NO            YES
      |             |
      ↓             ↓
   Keep         What's your
  current      risk tolerance?
  structure     |
               ├──────────┬──────────┬──────────┐
               |          |          |          |
            ULTRA        LOW      MEDIUM     HIGH
            SAFE       RISK       RISK       RISK
             |          |          |          |
        Phase 1     Phase 1    Phase 1-2  Phase 1-4
        only     then 2-4    then more   all at once
             |          |          |          |
      1 hour  8-10h    8-10h    8-10h
      done   staged    staged    one go
             |          |          |
             ↓          ↓          ↓
          CHOOSE PATH A
          or B or C
             |
             ↓
          TELL ME!
```

---

## Success Criteria: After Phase 4

```
CHECKPOINTS:

✓ design/ folder exists with all game design docs
✓ api/ folder exists with all TOML schemas
✓ architecture/ folder exists with all implementation guides
✓ engine/ has consolidated gui/ (no scenes/, ui/, widgets/ separate)
✓ mods/ has core/ with game content
✓ tests/ well-organized with mock data
✓ tools/ has validators and generators
✓ tasks/ tracks all AI work
✓ temp/ ready for temporary files
✓ lore/ ready for creative assets

CODE QUALITY:

✓ Game launches: lovec "engine" → no console errors
✓ All tests pass: run_tests.bat → 100% success
✓ No broken markdown links: tools/validate_docs_links.ps1 → 0 broken
✓ All require() statements work
✓ No duplication of files
✓ Clear purpose for each folder
✓ README.md in each layer explaining purpose

DEVELOPER EXPERIENCE:

✓ New developer can navigate easily
✓ Modders know where to look (api/ → mods/)
✓ Designers know where to look (design/)
✓ Developers know where to look (architecture/ → engine/)
✓ No confusion or searching multiple folders
✓ Clear dependencies and relationships
✓ Professional project structure
```

---

## Timeline Visualization

```
TODAY:           PHASE 1 (1 hour)
├─ 0:00 - Decision made
├─ 0:15 - Create 10 folders
├─ 0:30 - Add README files
├─ 0:45 - Move orphan files
├─ 1:00 - Test: Game still runs ✓
└─ 1:00 - PHASE 1 COMPLETE

LATER:           PHASE 2 (2-3 hours) - Optional
├─ Move design docs
├─ Update markdown links
├─ Validate links
└─ PHASE 2 COMPLETE

LATER:           PHASE 3 (3-4 hours) - Optional
├─ Create engine/gui/
├─ Move 3 folders (scenes, ui, widgets)
├─ Update 100+ require() statements
├─ Test game launch
└─ PHASE 3 COMPLETE

LATER:           PHASE 4 (1-2 hours) - Optional
├─ Delete old folders
├─ Update docs
├─ Final validation
└─ PHASE 4 COMPLETE

TOTAL:           1 hour (Phase 1) or 8-10 hours (Phases 1-4)
```

---

## In Conclusion

Choose your path:
- **Path A:** Phase 1 today (1 hour, safe, foundation)
- **Path B:** Phases 1-4 over time (8-10 hours, staged, managed)
- **Path C:** Phases 1-4 all at once (8-10 hours, efficient, high-risk)

**My recommendation:** Path B for your project 👈

Ready? Tell me which path and I'll execute! 🚀

