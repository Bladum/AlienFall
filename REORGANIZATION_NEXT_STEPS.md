# Project Reorganization - Immediate Next Steps

## You Now Have Two Documents

1. **PROJECT_REORGANIZATION_PLAN.md** - Strategic vision & architecture design
2. **FILE_AUDIT_AND_MIGRATION_GUIDE.md** - Detailed file-by-file audit & risk assessment

---

## Quick Summary: What's the Real Problem?

Your project currently has **unnecessary duplication and confusion**:

### The 3 Main Issues:

**Issue #1: Design docs are scattered**
- `wiki/systems/` has game mechanics (19 files)
- `docs/` has more design stuff
- Result: Hard to find design docs, easy to miss updates

**Issue #2: API specification isn't separate from implementation**
- TOML schemas mixed into `wiki/api/` (correct location but could be clearer)
- But also in `docs/mods/toml_schemas/`
- Result: Modders confused about where to look

**Issue #3: Engine has GUI fragmented across 3 folders**
- `engine/scenes/`, `engine/ui/`, `engine/widgets/`
- Result: Unclear where new UI components go

**Issue #4: Temp files go everywhere**
- No dedicated `temp/` folder
- Agent-generated reports clutter project
- Result: Project looks messy

**Issue #5: Lore/creative content is unorganized**
- Story ideas scattered in `engine/lore/` (should be code only)
- No dedicated space for design inspiration
- Result: Creative assets mixed with code

---

## The Solution: 10-Layer Clean Structure

```
design/        ← Mechanics only (no code, no data)
api/           ← TOML schemas (bridge between design & implementation)
architecture/  ← Implementation guides (how to code it)
engine/        ← Lua code (the actual game)
mods/          ← TOML data (game content using API)
tests/         ← Tests & mock data
tools/         ← Developer utilities
tasks/         ← AI Agent task tracking
temp/          ← Temporary files (NEW - for agent outputs)
lore/          ← Creative assets (NEW - for story/concepts)
```

---

## What YOU Should Do Now

### Option A: Conservative Approach (Recommended First Step)

**Just make a decision about these questions:**

1. Do you want to proceed with the 10-layer restructuring? YES / NO
2. If YES, should we:
   - Start with creating the new folders and README files? (non-breaking, can test)
   - Or jump straight to full migration? (all-or-nothing)

### Option B: Full Reorganization (If You're Ready)

**If you want me to execute the migration:**

1. I can create all 10 layers with proper README files
2. Create a comprehensive file movement script
3. Run the migration step-by-step
4. Test everything (game launch, tests, link validation)
5. Provide before/after report

**This would take ~8-10 hours depending on cleanup needed**

### Option C: Hybrid (Staged Approach - Best for Active Project)

**Phase 1 (Today):** Non-breaking setup
- Create new folders: `design/`, `api/`, `architecture/`, `temp/`, `lore/`
- Test: Make sure nothing broke

**Phase 2 (Next session):** Documentation moves
- Move wiki/systems → design/systems/
- Update markdown links
- Test: All links still work

**Phase 3 (Later session):** Engine consolidation
- GUI folder unification (high risk, needs testing)
- Update all require() statements
- Test: Game still runs

**Phase 4 (Final):** Cleanup
- Delete old folders
- Update navigation
- Final validation

---

## Before You Decide: Questions to Answer

Looking at your project, I need clarification on:

1. **`mods/new/` folder**
   - What is this? Examples? Work in progress? Community mods?
   - Should it be: `mods/examples/`, `mods/community/`, or deleted?

2. **`tests/phase5_*` folders**
   - Are these legacy (from old development phases)?
   - Should they be archived or kept active?

3. **`geoscape/crafts.md`**
   - Why is this orphaned? Should it be in `design/` or `engine/`?

4. **`docs/` vs `wiki/` split**
   - How did this split happen?
   - Should docs be archived or integrated?

5. **`engine/lore/` folder**
   - This has CODE. Is there also CREATIVE content separate?
   - Or do you want creative content separate from code?

---

## Decision Tree

```
START: Do you want to reorganize?
│
├─ NO → Keep current structure (but be aware it's messy)
│
└─ YES → What's your risk tolerance?
    │
    ├─ LOW (Careful, staged) → Choose HYBRID approach
    │   └─ Phase 1: Create folders (0.5h, safe)
    │   └─ Phase 2: Move docs (2-3h, safe)
    │   └─ Phase 3: Engine consolidation (3-4h, risky)
    │   └─ Phase 4: Cleanup (1-2h, safe)
    │
    ├─ MEDIUM (I trust you, but verify) → Choose CONSERVATIVE
    │   └─ Create new structure
    │   └─ Test each phase
    │   └─ Rollback if issues
    │
    └─ HIGH (Go all-in) → Choose FULL REORGANIZATION
        └─ Comprehensive migration
        └─ 8-10 hours total
        └─ Single comprehensive report
```

---

## What I Can Do For You

### Option 1: Planning Phase (What I Just Did)
✅ Created reorganization plan
✅ Created file audit with risk assessment
✅ Identified all problem areas
✅ Provided decision framework

**Next: You decide on approach, clarify questions above**

---

### Option 2: Phase 1 Execution (Non-Breaking)
If you say "YES, start with Phase 1":

1. Create 10 new top-level folders
2. Create README.md for each layer explaining purpose
3. Move `geoscape/crafts.md` to correct location
4. Update main README to explain structure
5. Verify nothing broke
6. Provide status report

**Time: 1-2 hours | Risk: MINIMAL**

---

### Option 3: Full Execution (Complete Reorganization)
If you say "YES, let's do the full thing":

1. Execute all 4 phases
2. Update all `require()` statements (critical!)
3. Move all design docs to `design/`
4. Move all API docs to `api/`
5. Move all architecture guides to `architecture/`
6. Consolidate GUI folder in engine
7. Create temp/ and lore/ folders
8. Test everything:
   - `lovec "engine"` - game launches
   - `run_tests.bat` - all tests pass
   - `tools/validate_docs_links.ps1` - no broken links
9. Provide comprehensive migration report

**Time: 8-10 hours | Risk: MEDIUM-HIGH (but managed)**

---

## One More Thing: Understanding Your Layers

Once reorganized, here's how each layer is USED:

### For Game Designers:
- Read `design/systems/*.md` to understand mechanics
- Check `design/diagrams/` for visual overviews
- Reference `design/balance/` for tuning

### For Modders:
- Read `api/README.md` to understand data format
- Use `api/*_schema.md` files to create content
- Look at `mods/examples/` for reference implementations
- Create content in `mods/core/` or `mods/community/`

### For Engine Developers:
- Read `architecture/patterns/` to understand code organization
- Reference `architecture/systems/` for implementation guides
- Look at `architecture/best_practices/` for standards
- Implement features in `engine/`
- Run tests in `tests/`

### For Documentation/Tools:
- Use `tools/` folder for generation and validation
- Generate reports to `temp/` folder
- Archive completed tasks to `tasks/DONE/`

### For Creative/Story Work:
- Collect ideas in `lore/` folder
- Create story outlines in `lore/story/`
- Store concept art in `lore/images/`
- Generate prompts in `lore/prompts/`

---

## My Recommendation

Based on your project state, I recommend: **HYBRID STAGED APPROACH**

### Why?

1. **Lower Risk**: Each phase can be validated independently
2. **Flexibility**: Can pause between phases if needed
3. **Learning**: You see benefits early (Phase 1 after 1 hour)
4. **Safety**: Can rollback if something breaks
5. **Focused**: Keep working on game while reorganizing

### Suggested Timeline:

**TODAY (1 hour):**
- Create 10 new folders
- Add README.md files
- Move orphan files (geoscape/crafts.md)
- Test: Verify nothing broke
- You have clean structure for future work

**NEXT SESSION (2-3 hours):**
- Move wiki/systems to design/systems
- Move docs/diagrams to design/diagrams
- Update markdown links
- Test: Run link validator

**LATER (3-4 hours):**
- Consolidate GUI in engine (high risk)
- Update all require() statements
- Test: `lovec "engine"` launches

**FINAL (1-2 hours):**
- Delete old empty folders
- Create navigation guide
- Final cleanup

---

## Your Move

**What would you like to do?**

1. **Review & clarify** - Answer the 5 questions above, I'll refine the plan
2. **Phase 1 only** - Create new structure, non-breaking (1 hour)
3. **Go all-in** - Full reorganization (8-10 hours)
4. **Something else** - Tell me what you'd prefer

Once you decide, just tell me and I'll execute!

---

## Files You Now Have

- `PROJECT_REORGANIZATION_PLAN.md` - Strategic vision (read first!)
- `FILE_AUDIT_AND_MIGRATION_GUIDE.md` - Detailed audit (reference during migration)
- This file - Decision framework and immediate next steps

All are in project root for easy access.

