# End-to-End Mechanics Update Prompt for AlienFall Development

**Purpose**: Comprehensive system prompt for handling complete mechanics changes across all layers (Design → API → Architecture → Engine → Mods → Tests)

**When to Use**: User asks to change, add, or enhance any game mechanic (pilot system, perks, crafts, units, economy, etc.)

---

## 1. THINKING & REASONING PHASE

### Step 1.1: Understand the Request
```
User says: "I want to [add/change/enhance] [mechanic]"

Think about:
- What is the core mechanic being changed?
- What systems does it touch? (geoscape, battlescape, basescape, economy, ai, lore)
- Is this a NEW mechanic or EXTENDING an existing one?
- What are the dependencies? (other mechanics that must exist first)
- What's the scope? (small tweak vs major overhaul)
```

### Step 1.2: Assess Current State
```
Search workspace for:
1. Existing implementation (engine code)
2. Design documentation (design/mechanics/)
3. API documentation (api/)
4. Architecture documentation (architecture/)
5. Configuration (mods/core/rules/)
6. Tests (tests2/)

Questions to answer:
- Is there existing design documentation?
- Is the mechanic already partially implemented?
- What layer is least complete? (usually design/api, sometimes engine)
- Are there any related mechanics already documented?
```

### Step 1.3: Identify Required Updates
```
For EACH of these layers, determine if it needs changes:

┌─────────────────────────────────────────────────────────────┐
│ 1. DESIGN (design/mechanics/)                               │
│    - Game design document or extend existing               │
│    - "What does the mechanic DO?" (player perspective)      │
│    - Progression, balance, design philosophy               │
│    - Format: Game design writing, NOT technical            │
└─────────────────────────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────────────────────────┐
│ 2. API (api/)                                              │
│    - Technical documentation                               │
│    - "How does code USE the mechanic?"                      │
│    - Functions, entities, TOML schemas, examples           │
│    - Format: Technical API documentation                    │
└─────────────────────────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────────────────────────┐
│ 3. ARCHITECTURE (architecture/ - IF NEEDED)                │
│    - Only if mechanic affects module relationships         │
│    - "How do systems COOPERATE on this mechanic?"          │
│    - Diagrams, integration patterns, data flow             │
└─────────────────────────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────────────────────────┐
│ 4. ENGINE (engine/)                                        │
│    - Production Lua code                                   │
│    - "How is it IMPLEMENTED?"                              │
│    - Managers, systems, logic, integration                 │
│    - Format: Clean, documented Lua code                    │
└─────────────────────────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────────────────────────┐
│ 5. MODS (mods/core/rules/)                                 │
│    - Configuration & game content                          │
│    - "What are the SPECIFIC VALUES?"                       │
│    - TOML files defining actual game content              │
│    - Format: TOML configuration                            │
└─────────────────────────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────────────────────────┐
│ 6. TESTS (tests/)                                          │
│    - Verification & quality assurance                      │
│    - "Does it WORK correctly?"                             │
│    - Unit and integration tests                            │
│    - Format: Lua test code (HierarchicalSuite framework)   │
└─────────────────────────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────────────────────────┐
│ 7. LORE (lore/ - SOMETIMES)                                │
│    - Story & narrative integration                         │
│    - "What's the STORY behind this?"                       │
│    - Only if mechanic has significant narrative            │
└─────────────────────────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────────────────────────┐
│ 8. DOCS (docs/ - RARELY)                                   │
│    - Development practices & patterns                      │
│    - Only if mechanic affects HOW DEVELOPERS WORK          │
│    - Example: new testing pattern, coding standard         │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. TASK CREATION PHASE

### Step 2.1: Create Task Document
```
Copy: tasks/TASK_TEMPLATE.md → tasks/TODO/TASK-XXX-MECHANIC-NAME.md

Fill in ALL sections:
- Status: TODO
- Priority: (determine from scope)
- Created: Today's date
- Overview: Brief what you're doing
- Purpose: Why this matters
- Requirements:
  * Design requirements (from design docs)
  * Technical requirements (from API/architecture)
  * Acceptance criteria (how to verify it's done)
- Plan: (detailed step-by-step with file paths)
- Implementation Details: (architecture, key components)
- Testing Strategy: (unit, integration, manual tests)
- Documentation Updates: (what docs to update)
- Review Checklist: (final verification steps)
```

### Step 2.2: Identify All Affected Files
```
For each layer (design, api, architecture, engine, mods, tests, lore, docs):
1. List existing files to MODIFY (extend existing content)
2. List NEW files to CREATE (if needed)
3. List dependencies (other systems that must exist)

Example format in task document:
## Files to Create
- `engine/piloting/pilot_system.lua` (pilot mechanics, 300+ lines)
- `engine/piloting/rank_manager.lua` (progression system, 200+ lines)

## Files to Modify
- `engine/content/units/unit_system.lua` (+50 lines for pilot integration)
- `api/UNITS.md` (+500 lines for pilot API documentation)
- `design/mechanics/Units.md` (+1000 lines for pilot design section)
- `mods/core/rules/unit/classes.toml` (add pilot classes)

## Dependencies
- Unit system must exist (✅ exists)
- Experience/progression framework (✅ exists)
```

### Step 2.3: Update tasks.md
```
Add entry in tasks/tasks.md under "## Current High Priority Tasks":

### 🆕 TASK-XXX: Mechanic Name (STATUS)
**Priority:** [Low|Medium|High|Critical]
**Created:** [Date]
**Status:** TODO | IN_PROGRESS | TESTING | DONE
**Description:** One-line summary
**Time Estimate:** X-Y hours
**Files Affected:** engine/..., api/..., design/...
**Dependencies:** (other tasks this depends on)
**Deliverables:** (concrete outputs)
```

---

## 3. IMPLEMENTATION PHASE - FILE ORGANIZATION PATTERN

### Pattern: Design → API → Architecture → Engine → Mods → Tests

Follow this EXACT sequence:

#### PHASE 1: DESIGN (if new mechanic)
```
IF mechanic is new:
  → Create design/mechanics/MechanicName.md (if dedicated file needed)
  → OR Extend design/mechanics/Units.md (if part of larger system)
  
CONTENT GUIDELINES:
- Game design focus: "What does the player SEE and DO?"
- NOT technical: avoid code examples, function names, TOML schemas
- Include: overview, classification, progression, mechanics, balance philosophy
- Format: Follow existing design/mechanics files (Units.md, Overview.md)
- Match existing section style (## headers, tables, descriptions)

IF mechanic extends existing:
  → Find the parent system file (e.g., design/mechanics/Units.md)
  → Add new subsection (## Pilot System, ## Perks System)
  → Include all mechanics, progression, balance
  → 800-1500 lines per subsection typical

DO NOT CREATE NEW FILES unless:
  - Mechanic is completely independent (rare)
  - User explicitly approves new file
  - No parent system exists to extend
```

#### PHASE 2: API (if mechanic has external interface)
```
IF mechanic needs external integration:
  → Create api/MECHANIC_NAME.md (new file)
  → OR Extend api/SYSTEM.md (add entity/function definitions)

CONTENT GUIDELINES:
- Technical focus: "How does CODE use this?"
- Include: entity definitions, functions, TOML schemas, examples
- Format: Tables for quick reference, code blocks with Lua/TOML
- Sections: Overview, Entity, Functions, TOML Schema, Examples, Integration Points

Example structure:
## Pilot Entity
| Property | Type | Description |
| --- | --- | --- |
| id | string | Unique pilot ID |
| name | string | Pilot name |
| rank | number | 0-2 (Rookie/Veteran/Elite) |

## Functions
### PilotProgression.addXP(pilotId, amount)
Description...

## TOML Schema
```toml
[pilots.fighter_ace]
type = "FIGHTER"
```

DO NOT include:
  ❌ Game design/balance discussion (goes in design/)
  ❌ Implementation details (goes in engine/)
  ❌ Player-facing descriptions (goes in design/)
```

#### PHASE 3: ARCHITECTURE (if affects system cooperation)
```
ONLY IF mechanic creates new dependencies between systems:

Examples when to update architecture/:
✅ Pilot system depends on: units, geoscape, basescape, economy
✅ New damage type requires: combat system, units, weapons, ai
✅ New resource requires: economy, storage, marketplace, finance

Examples when NOT needed:
❌ Pure UI feature (only needs engine/ui/)
❌ Balance tweak (only needs mods/)
❌ Internal system refactor (only needs engine/)

IF needed:
  → Update architecture/ROADMAP.md (if affects roadmap)
  → Update architecture/01-game-structure.md (if affects structure)
  → Add module relationships diagram (if affects dependencies)
```

#### PHASE 4: ENGINE (core implementation)
```
Create/modify Lua files in engine/:

GUIDELINES:
1. Follow existing module structure
   - engine/[layer]/logic/ for business logic
   - engine/[layer]/systems/ for system managers
   - engine/[layer]/ui/ for UI components
   - engine/[layer]/data/ for data definitions

2. Code standards
   - Local variables only (no globals)
   - Snake_case for files and functions
   - Google-style docstrings (---)
   - Comments explaining WHY, not WHAT
   - Error handling with pcall

3. Integration points
   - Register with state_manager if needed
   - Load with DataLoader if data-driven
   - Call from ActionSystem if player action
   - Subscribe to events if reactive

4. Typical structure
   - Main manager: create, read, update, delete operations
   - Helper modules: calculations, utilities
   - UI integration: display + input handling
   - Test coverage: unit + integration tests

5. File size targets
   - Managers: 200-400 lines
   - Systems: 250-350 lines
   - Utilities: 100-200 lines
   - UI: 300-500 lines
   - Tests: 100-300 lines per module
```

#### PHASE 5: MODS (game content configuration)
```
Create/modify TOML files in mods/core/rules/:

STRUCTURE:
- mods/core/rules/unit/ → pilot classes, perks
- mods/core/rules/item/ → weapons, armor, equipment
- mods/core/rules/facility/ → base facilities
- mods/core/rules/craft/ → craft types and configurations
- mods/core/generation/ → biomes, map generation, procedural rules

GUIDELINES:
1. One content type per file
2. Table-based format: [content_id] = { data }
3. Reference other content by ID
4. Include comments explaining values
5. Follow existing naming conventions
6. Validate referential integrity

Example (mods/core/rules/unit/pilots.toml):
[fighters.fighter_pilot]
type = "FIGHTER"
name = "Fighter Pilot"
xp_per_rank = 50
rank_bonuses = [
  { level = 1, speed = 1, aim = 2, reaction = 1 },
  { level = 2, speed = 2, aim = 4, reaction = 2 }
]
```

#### PHASE 6: TESTS (quality assurance)
```
Create/modify test files in tests2/ (NEW test framework):

GUIDELINES:
1. Use HierarchicalSuite framework (tests2/framework/)
2. Organize by subsystem (tests2/[subsystem]/)
3. Performance tests in tests2/performance/
4. Edge cases in tests2/edge_cases/
5. Integration tests in tests2/integration/

STRUCTURE:
```lua
local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local suite = HierarchicalSuite.new("ModuleName", "tests2/subsystem/module_test.lua")

suite:testMethod("functionName", "Description", function()
    -- Arrange
    local input = createTestData()
    
    -- Act
    local result = moduleFunction(input)
    
    -- Assert
    suite:assert(result == expected, "Should match expected")
end)

return suite
```

4. Test coverage targets
   - Core functions: 100%
   - Edge cases: 90%+
   - Integration: 80%+
   - Performance: Key scenarios benchmarked

5. Run tests (if available)
   ```bash
   lovec "tests2/runners" run_all
   lovec "tests2/runners" run_subsystem [name]
   ```
```

#### PHASE 7: LORE (if narrative element)
```
ONLY if mechanic has significant story:

Update lore/ folder:
- lore/story/ → narrative content
- lore/factions/ → faction-specific mechanics
- lore/technology/ → tech progression narratives

Example: Pilot system might add:
- Why pilots exist (military organization structure)
- Pilot factions/specializations
- Career progression narrative
- Special events/achievements
```

#### PHASE 8: DOCS (if affects developer workflow)
```
RARELY needed - only if mechanic affects HOW DEVELOPERS WORK:

Examples:
✅ Update docs/CODE_STANDARDS.md if adding new pattern
✅ Update docs/TESTING.md if new test types needed
❌ DON'T update if only game design changed
❌ DON'T update if only engine implementation

Almost always: existing docs are sufficient
```

---

## 4. QUALITY ASSURANCE PHASE

### Step 4.1: Verify All Layers Complete
```
Checklist before declaring "done":

✅ DESIGN: Comprehensive game design documentation
   - Game perspective: "What do players see?"
   - Progression and balance explained
   - Philosophy documented
   - Format matches existing design files

✅ API: Complete technical documentation
   - Entities documented with all properties
   - Functions documented with signatures
   - TOML schemas with examples
   - Integration points clear

✅ ENGINE: Working implementation
   - All core systems created
   - Proper error handling
   - Integration points connected
   - No globals or anti-patterns

✅ MODS: Game content defined
   - All values in TOML
   - Referential integrity verified
   - Comments explain non-obvious values
   - Testable by loading mod

✅ TESTS: Quality verified
   - Unit tests pass 100%
   - Integration tests pass 100%
   - Edge cases covered
   - Run game without errors

✅ GAME RUNS: Verification
   - Command: lovec "engine"
   - Exit Code: 0
   - No console errors
   - New mechanic functional
```

### Step 4.2: Cross-Layer Consistency
```
Verify consistency across layers:

1. DESIGN ↔ API
   - Design describes what user sees
   - API documents how developers implement it
   - Should have 1:1 mapping

2. API ↔ ENGINE
   - API describes the contract
   - Engine implements the contract
   - All documented functions exist

3. ENGINE ↔ MODS
   - Engine reads TOML files
   - Mods provide configuration
   - All TOML fields mapped to code

4. ENGINE ↔ TESTS
   - Tests verify implementation
   - All critical paths tested
   - Edge cases covered

Example verification:
- Design says "Pilots rank up 0→1→2"
- API documents rank_bonuses per level
- Engine loads rank_bonuses from TOML
- Mods define rank_bonuses values
- Tests verify rank progression works
```

### Step 4.3: Game Run Verification
```
Before marking complete:

1. Run the game:
   lovec "engine"
   or use VS Code task "Run XCOM Simple Game"

2. Check console:
   - No errors about missing files
   - No errors about undefined functions
   - New mechanic initialization messages
   - Successful module loading

3. Test functionality:
   - Navigate to feature in game
   - Interact with new mechanic
   - Verify expected behavior
   - Check for crashes

4. If errors:
   - Fix immediately
   - Re-run game
   - Continue until Exit Code 0
```

---

## 5. DOCUMENTATION & CLEANUP PHASE

### Step 5.1: Update Task Document
```
Mark task as TESTING → DONE:

Status: TESTING → DONE
Completed: [Date]

Add completion notes:
- All files created/modified successfully
- All tests passing (X/X)
- Game runs without errors (Exit Code 0)
- Cross-layer consistency verified
- Ready for production
```

### Step 5.2: Move Task to Done
```
If on filesystem:
- Move tasks/TODO/TASK-XXX.md → tasks/DONE/TASK-XXX.md
- Create completion report with:
  * What was implemented
  * Files changed
  * Test results
  * Any issues resolved
```

### Step 5.3: Update Main Task Tracking
```
In tasks/tasks.md:

Before:
## 🆕 TASK-XXX: Mechanic Name (TODO)

After:
## ✅ TASK-XXX: Mechanic Name (DONE)
**Status:** COMPLETED | **Completed:** [Date]
**Summary:** What was implemented
**Time Spent:** X hours
**Files Created:** N files, XXX+ lines
**Tests:** X/X passing
**Game Status:** ✅ Exit Code 0
```

---

## 6. SUMMARY: THE WORKFLOW

### For User Request: "Add X mechanic"

```
┌─────────────────────────────────────────────────────────────┐
│ 1. UNDERSTAND                                               │
│    → What mechanic? What systems? New or extend?            │
└────────────────┬────────────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────────────────────────┐
│ 2. ASSESS                                                   │
│    → Search workspace for current state                     │
│    → Identify which layers need updates                     │
└────────────────┬────────────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────────────────────────┐
│ 3. PLAN                                                     │
│    → Create task document from template                     │
│    → List all files to create/modify                        │
│    → Update tasks.md                                        │
└────────────────┬────────────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────────────────────────┐
│ 4. IMPLEMENT (Follow order: Design→API→Arch→Engine→Mods)   │
│    → Design: game design documentation (extend or new)      │
│    → API: technical documentation (extend or new)           │
│    → Architecture: if affects system relationships          │
│    → Engine: Lua production code (create/modify)            │
│    → Mods: TOML configuration (create/modify)               │
│    → Tests: Lua test code (create/modify)                   │
│    → Lore: if significant narrative (rare)                  │
│    → Docs: if affects dev workflow (very rare)              │
└────────────────┬────────────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────────────────────────┐
│ 5. VERIFY                                                   │
│    → All layers complete & consistent                       │
│    → Tests 100% passing                                     │
│    → Game runs without errors (Exit Code 0)                 │
│    → New mechanic functional                                │
└────────────────┬────────────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────────────────────────┐
│ 6. COMPLETE                                                 │
│    → Update task status to DONE                             │
│    → Move task file to DONE folder                          │
│    → Update tasks.md with completion info                   │
│    → Confirm all deliverables met                           │
└─────────────────────────────────────────────────────────────┘
```

---

## 7. CRITICAL RULES

### Rule 1: File Organization
```
✅ DO:
- design/mechanics/ for game design descriptions
- api/ for technical documentation
- architecture/ only if affects module relationships
- engine/ for production Lua code
- mods/core/rules/ for TOML configuration
- tests/ for test code
- lore/ for narrative content (rare)
- docs/ for dev workflow (very rare)

❌ DON'T:
- Create new files in design/mechanics/ unless user approves
- Mix technical docs in design/ files
- Put game design in api/ files
- Create temp status files (_STATUS.md, _SUMMARY.md)
- Put code in design files
- Put design philosophy in api files
```

### Rule 2: Content Quality
```
DESIGN files should:
✅ Explain WHAT the game does
✅ Use player-friendly language
✅ Include balance philosophy
✅ Show progression mechanics
✅ Have examples from gameplay

❌ Should NOT:
❌ Include code examples
❌ Reference function names
❌ Show TOML schemas
❌ Discuss implementation details
```

### Rule 3: Implementation Order
```
ALWAYS follow this order:
1. Design ← define what game does
2. API ← define how code uses it
3. Architecture ← define system cooperation
4. Engine ← implement the code
5. Mods ← configure content
6. Tests ← verify it works
7. Lore ← add narrative (if needed)
8. Docs ← update workflow (if needed)

NO SKIPPING LAYERS - each informs the next
```

### Rule 4: Cross-Check Consistency
```
Before marking done, verify:
- Design concept ↔ API functions ✅
- API documentation ↔ Engine implementation ✅
- Engine code ↔ TOML configuration ✅
- TOML values ↔ Game behavior ✅
- All tested via unit + integration tests ✅
```

---

## 8. QUICK REFERENCE: When User Says...

```
"Add pilot system"
→ Create design/mechanics/ section (or extend Units.md)
→ Create api/UNITS.md pilot section
→ Create engine/basescape/pilot_system.lua
→ Create mods/core/rules/unit/pilots.toml
→ Create tests2/unit/pilot_system_test.lua

"Change perk mechanics"
→ Update design/mechanics/Units.md perks section
→ Update api/UNITS.md perk functions
→ Modify engine/basescape/perks_system.lua
→ Modify mods/core/rules/unit/perks.toml
→ Update tests2/unit/perks_system_test.lua

"Nerf weapon damage"
→ Update design/mechanics/overview (balance notes)
→ Update mods/core/rules/item/weapons.toml (damage values)
→ Run tests to verify
→ Game test to confirm

"Add healing mechanic"
→ Design section (how healing works)
→ API documentation (healing functions)
→ Engine code (healing system)
→ TOML config (healing values)
→ Tests (healing verification)
→ Potentially: lore section (why/story)
```

---

## 9. MEASURING SUCCESS

Task is COMPLETE when:

```
✅ DESIGN COMPLETE
   - Mechanic fully described from player perspective
   - Design philosophy explained
   - Balance approach documented
   - Progression path clear

✅ API COMPLETE
   - All entities documented
   - All functions defined
   - TOML schemas with examples
   - Integration points clear

✅ ENGINE COMPLETE
   - All systems implemented
   - Proper Lua structure
   - Error handling present
   - Tests passing 100%

✅ MODS COMPLETE
   - TOML files have all content
   - References valid
   - Values reasonable

✅ TESTS COMPLETE
   - Unit tests 100% pass
   - Integration tests 100% pass
   - Edge cases covered

✅ GAME VERIFICATION
   - Runs without errors
   - Exit Code 0
   - Mechanic functional
   - No console errors

✅ DOCUMENTATION COMPLETE
   - Task marked DONE
   - Files moved to DONE folder
   - tasks.md updated
   - All deliverables listed
```

---

## 10. WHEN IN DOUBT

```
Ask yourself:

1. Is this a NEW mechanic?
   → YES: Follow full Design→API→Engine workflow
   → NO: Just modify relevant layers

2. Does it affect multiple systems?
   → YES: May need architecture update
   → NO: Probably doesn't

3. Is there design documentation?
   → YES: Extend it
   → NO: Create it (or ask user if needed)

4. Is there existing implementation?
   → YES: Start from current state
   → NO: Build from scratch

5. Does it need gameplay content?
   → YES: Create TOML files in mods/
   → NO: Maybe just engine code

6. Is it tested?
   → YES: Mark done
   → NO: Write tests first

7. Does game run?
   → YES: Good
   → NO: Fix before marking done
```

---

## Prompt Use Instructions

**When a user asks you to update mechanics:**

1. Read this entire prompt
2. Follow the thinking → planning → implementation phases
3. Proceed systematically through each layer
4. Verify consistency across layers
5. Test thoroughly before completion
6. Update documentation (task, files, tracking)
7. Confirm successful game run

**This prompt ensures:**
- Consistent, high-quality implementations
- No layer is missed
- Design and code stay aligned
- All content is properly documented
- Quality testing happens
- Clear task tracking and completion
