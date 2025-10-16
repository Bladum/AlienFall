# ✅ Documentation Improvement Implementation Checklist

**Use this to track progress through each phase**

---

## 📋 OVERVIEW

- **Total Phases**: 4
- **Total Time**: 9-13 hours
- **Priority**: Phase 1 is CRITICAL (do first)
- **Complexity**: HIGH (many cross-references to update)

---

## 🔴 PHASE 1: CODE HYGIENE (2-3 hours) - CRITICAL ⭐

**Goal:** Remove code from design docs, create technical folder

### Step 1.1: Create Technical Folder
- [ ] Create `docs/technical/` folder
- [ ] Create `docs/technical/README.md`
  - [ ] Explain purpose: Large technical analysis and implementation guides
  - [ ] List contents
  - [ ] Link to design docs they relate to

### Step 1.2: Extract Code from TILESET_SYSTEM.md (50-60 min)
- [ ] Read current file: `docs/systems/TILESET_SYSTEM.md` (825 lines)
- [ ] Create new file: `docs/technical/TILESET_SYSTEM.md` (copy of original)
  - [ ] Keep all code blocks and TOML examples
  - [ ] Keep all technical details
- [ ] Update original: `docs/systems/TILESET_SYSTEM.md`
  - [ ] REMOVE all TOML code blocks (12 of them)
  - [ ] REMOVE all Lua code blocks (7 of them)
  - [ ] REPLACE with text descriptions
    - Example: "The tileset format defines a structure with fields for tileset name, tile count, and variant modes"
  - [ ] Add note at top: "→ Technical implementation: See `docs/technical/TILESET_SYSTEM.md`"
- [ ] Update cross-references:
  - [ ] Find files linking to this file
  - [ ] Update to point to technical version if technical reference
  - [ ] Keep design doc reference if design context

### Step 1.3: Extract Code from FIRE_SMOKE_MECHANICS.md (30-40 min)
- [ ] Read current file: `docs/systems/FIRE_SMOKE_MECHANICS.md` (334 lines)
- [ ] Create new file: `docs/technical/FIRE_SMOKE_MECHANICS.md`
  - [ ] Copy all code blocks
- [ ] Update original:
  - [ ] REMOVE all Lua code blocks (6 of them)
  - [ ] REPLACE with text descriptions
  - [ ] Add cross-reference note
- [ ] Update cross-references in other docs

### Step 1.4: Extract Code from RESOLUTION_SYSTEM_ANALYSIS.md (30-40 min)
- [ ] Read current file: `docs/systems/RESOLUTION_SYSTEM_ANALYSIS.md` (656 lines)
- [ ] Create new file: `docs/technical/RESOLUTION_SYSTEM_ANALYSIS.md`
  - [ ] Copy all code blocks
- [ ] Update original:
  - [ ] REMOVE all Lua code blocks (7 of them)
  - [ ] REPLACE with text descriptions
  - [ ] Add cross-reference note
- [ ] Update cross-references in other docs

### Step 1.5: Remove Code from TESTING.md (20-30 min)
- [ ] Read current file: `docs/testing/TESTING.md`
- [ ] Identify all Lua code blocks
- [ ] For each code block:
  - [ ] Determine what it demonstrates
  - [ ] Write text description instead
  - [ ] Link to actual test implementation in `tests/` if needed
- [ ] Update file with descriptions only

### Step 1.6: Update Cross-References (20-30 min)
- [ ] Search for all references to moved/updated files:
  - [ ] `docs/systems/TILESET_SYSTEM.md` → may need to update
  - [ ] `docs/systems/FIRE_SMOKE_MECHANICS.md` → may need to update
  - [ ] `docs/systems/RESOLUTION_SYSTEM_ANALYSIS.md` → may need to update
- [ ] Update files:
  - [ ] `docs/README.md`
  - [ ] `docs/QUICK_NAVIGATION.md`
  - [ ] `docs/API.md`
  - [ ] Any design docs linking to these files

### Validation for Phase 1
- [ ] No Lua code blocks remain in design docs
- [ ] No TOML code blocks remain in design docs
- [ ] All code moved to `docs/technical/`
- [ ] All cross-references updated
- [ ] README created in `docs/technical/`
- [ ] All files still linkable

**Time: 2-3 hours**  
**Impact: HIGH** ⭐ (Standards compliance)

---

## 🟠 PHASE 2: FOLDER REORGANIZATION (3-4 hours)

**Goal:** Fix folder duplication, consolidate confusing structures

### Step 2.1: Consolidate balance/ and balancing/ (30-45 min)
- [ ] Rename folder:
  - [ ] Move `docs/balancing/` → `docs/balance/testing/`
  - [ ] Move `docs/balancing/framework.md` → `docs/balance/testing/framework.md`
- [ ] Create README files:
  - [ ] Create `docs/balance/README.md`
    - [ ] Explain: balance/ folder contains game balance documentation and testing
    - [ ] Explain subfolders: GAME_NUMBERS.md (design), testing/ (framework)
  - [ ] Create `docs/balance/testing/README.md`
    - [ ] Explain: Testing framework for balance validation
- [ ] Update cross-references:
  - [ ] `docs/balancing/` → `docs/balance/testing/`
  - [ ] `docs/QUICK_NAVIGATION.md`
  - [ ] `docs/README.md`
  - [ ] Any other docs referencing old path

### Step 2.2: Clarify docs/economy/ Structure (45-60 min)
- [ ] Investigate subfolders:
  - [ ] Check: `docs/economy/research/` - has content?
  - [ ] Check: `docs/economy/production/` - has content?
  - [ ] Check: `docs/economy/marketplace/` - has content?
  - [ ] Check: `docs/economy/finance/` - has content?
- [ ] **Option A: If empty** - Remove them
  - [ ] `rm docs/economy/research/` (keep only research.md)
  - [ ] `rm docs/economy/production/` (keep only manufacturing.md)
  - [ ] `rm docs/economy/marketplace/` (keep only marketplace.md)
  - [ ] Rename `finance/` → `funding/` for clarity
- [ ] **Option B: If has content** - Reorganize
  - [ ] Create structure:
    ```
    docs/economy/
    ├── README.md (NEW)
    ├── research.md → move to research/research.md
    ├── manufacturing.md → move to production/manufacturing.md
    ├── marketplace.md → move to marketplace/marketplace.md
    └── funding.md
    ```
  - [ ] Create README in each subfolder explaining contents
  - [ ] Create main `docs/economy/README.md` explaining structure
- [ ] Create `docs/economy/README.md` regardless:
  - [ ] Explain folder structure
  - [ ] Link to main system files
  - [ ] Explain relationship between files/folders
- [ ] Update cross-references:
  - [ ] `docs/QUICK_NAVIGATION.md`
  - [ ] `docs/README.md`
  - [ ] Any docs linking to economy files

### Step 2.3: Move Technical Files to docs/technical/ (45-60 min)
- [ ] Move files from `docs/geoscape/`:
  - [ ] `docs/geoscape/STRATEGIC_LAYER_DIAGRAMS.md` 
    → `docs/technical/GEOSCAPE_STRATEGIC_LAYER_DIAGRAMS.md`
  - [ ] `docs/geoscape/STRATEGIC_LAYER_IMPLEMENTATION_PLAN.md`
    → `docs/technical/GEOSCAPE_STRATEGIC_LAYER_IMPLEMENTATION_PLAN.md`
  - [ ] `docs/geoscape/STRATEGIC_LAYER_QUICK_REFERENCE.md`
    → `docs/technical/GEOSCAPE_STRATEGIC_LAYER_QUICK_REFERENCE.md`
  
- [ ] Move files from `docs/battlescape/`:
  - [ ] `docs/battlescape/COMBAT_SYSTEMS_COMPLETE.md`
    → `docs/technical/COMBAT_SYSTEMS_COMPLETE.md`
  - [ ] `docs/battlescape/3D_BATTLESCAPE_ARCHITECTURE.md`
    → `docs/technical/3D_BATTLESCAPE_ARCHITECTURE.md`
  - [ ] `docs/battlescape/3D_BATTLESCAPE_SUMMARY.md`
    → `docs/technical/3D_BATTLESCAPE_SUMMARY.md`
  - [ ] `docs/battlescape/ECS_BATTLE_SYSTEM_API.md`
    → `docs/technical/ECS_BATTLE_SYSTEM_API.md`
  
- [ ] Move files from `docs/rendering/`:
  - [ ] `docs/rendering/HEX_RENDERING_GUIDE.md`
    → `docs/technical/HEX_RENDERING_GUIDE.md`

- [ ] (Already moved in Phase 1):
  - [ ] `docs/systems/TILESET_SYSTEM.md`
  - [ ] `docs/systems/FIRE_SMOKE_MECHANICS.md`
  - [ ] `docs/systems/RESOLUTION_SYSTEM_ANALYSIS.md`

- [ ] Update cross-references:
  - [ ] `docs/QUICK_NAVIGATION.md` - Update all old paths
  - [ ] `docs/README.md` - Update structure
  - [ ] `docs/geoscape/README.md` - Link to technical docs
  - [ ] `docs/battlescape/README.md` - Link to technical docs
  - [ ] Any other files linking to moved files
  - [ ] Check: `docs/API.md` if it references these

### Validation for Phase 2
- [ ] `docs/balancing/` folder removed
- [ ] `docs/balance/testing/` created with framework.md
- [ ] `docs/economy/` structure clarified
- [ ] All technical files moved to `docs/technical/`
- [ ] All old folders cleaned up (or repurposed)
- [ ] All cross-references updated
- [ ] No broken links

**Time: 3-4 hours**  
**Impact: MEDIUM-HIGH** (Organization, clarity)

---

## 🟡 PHASE 3: ADD README FILES (2-3 hours)

**Goal:** Every folder has documented purpose

### Step 3.1: Create README for Game Systems Folders (60-90 min)
- [ ] `docs/ai/README.md`
- [ ] `docs/geoscape/README.md` (update if exists)
- [ ] `docs/basescape/README.md` (update if exists)
- [ ] `docs/battlescape/README.md` (update if exists)
- [ ] `docs/interception/README.md`
- [ ] `docs/economy/README.md` (already noted above)
- [ ] `docs/politics/README.md`
- [ ] `docs/content/README.md`
- [ ] `docs/lore/README.md`
- [ ] `docs/ui/README.md`

**README Template:**
```markdown
# [System Name]

> **Implementation**: `engine/[path]/`
> **Tests**: `tests/[path]/`
> **Related**: [links to related docs]

Brief description of what this system does.

## 📁 Structure

If folder has subfolders, explain each:

- **Subfolder 1**: Description
- **Subfolder 2**: Description

## 🔗 Key Documents

- `docs/[folder]/file.md` - Description
- etc.

See individual files for detailed documentation.
```

### Step 3.2: Create README for Infrastructure Folders (30-45 min)
- [ ] `docs/assets/README.md`
- [ ] `docs/localization/README.md`
- [ ] `docs/mods/README.md`
- [ ] `docs/network/README.md`
- [ ] `docs/scenes/README.md`
- [ ] `docs/tutorial/README.md`
- [ ] `docs/utils/README.md`
- [ ] `docs/widgets/README.md`

### Step 3.3: Create README for Other Folders (30-45 min)
- [ ] `docs/core/README.md` (update if exists)
- [ ] `docs/testing/README.md` (update if exists)
- [ ] `docs/design/README.md`
- [ ] `docs/progression/README.md`
- [ ] `docs/rules/README.md`

### Step 3.4: Create README for New/Reorganized Folders (15-30 min)
- [ ] `docs/technical/README.md` (already created in Phase 1)
- [ ] `docs/balance/README.md` (already created in Phase 2)
- [ ] `docs/balance/testing/README.md` (created in Phase 2)
- [ ] Any other new structure folders

### Validation for Phase 3
- [ ] Every folder has README.md
- [ ] Each README explains folder purpose
- [ ] README explains subfolder structure if applicable
- [ ] Links to related docs are present
- [ ] Links to implementation (engine/) are present
- [ ] Links to tests are present

**Time: 2-3 hours**  
**Impact: MEDIUM** (Clarity, documentation)

---

## 🟢 PHASE 4: STANDARDIZE & VALIDATE (1-2 hours)

**Goal:** Final polish and validation

### Step 4.1: Fix File Naming (30-45 min)
- [ ] Review current naming convention
- [ ] Identify inconsistencies:
  - [ ] Root level: README.md, OVERVIEW.md, QUICK_NAVIGATION.md (✅ OK - keep UPPERCASE)
  - [ ] Design docs: research.md, missions.md (✅ OK - keep lowercase)
  - [ ] Technical docs: TILESET_SYSTEM.md (✅ OK - UPPERCASE for technical/)
  - [ ] Problem files: Identify and note
- [ ] For each inconsistency:
  - [ ] Decide: Should it be UPPERCASE or lowercase?
  - [ ] Rename file
  - [ ] Update all cross-references
- [ ] Document convention in `docs/README.md`

### Step 4.2: Consolidate Navigation Files (20-30 min)
- [ ] Review:
  - [ ] `docs/README.md` - Folder intro
  - [ ] `docs/OVERVIEW.md` - Game overview
  - [ ] `docs/QUICK_NAVIGATION.md` - Index (355 lines - too long?)
  - [ ] `docs/API.md` - Technical reference
- [ ] Decide:
  - [ ] Keep QUICK_NAVIGATION.md? (useful extended reference)
  - [ ] Archive it? (move to docs/references/?)
  - [ ] Merge with README.md? (if too much overlap)
- [ ] If consolidating:
  - [ ] Update `docs/README.md` to include navigation tips
  - [ ] Keep QUICK_NAVIGATION as optional extended reference
  - [ ] Add comment: "Quick links above; see QUICK_NAVIGATION for complete index"
- [ ] Update top-level file links:
  - [ ] Make sure links between navigation files are clear
  - [ ] Add "Start here:" guidance for new users

### Step 4.3: Validate All Cross-References (20-30 min)
- [ ] Check each major file:
  - [ ] `docs/README.md` - All links work?
  - [ ] `docs/OVERVIEW.md` - All links work?
  - [ ] `docs/QUICK_NAVIGATION.md` - All links work?
  - [ ] `docs/API.md` - All links work?
- [ ] Check each folder:
  - [ ] All READMEs have valid links to implementation/tests
  - [ ] All links use consistent relative path format
  - [ ] No broken links
- [ ] Fix any issues found
- [ ] Optional: Create validation script to check links automatically

### Step 4.4: Final Quality Check (10-15 min)
- [ ] Folder structure is clean and logical ✅
- [ ] No files with embedded code (except technical/) ✅
- [ ] Every folder has README with clear purpose ✅
- [ ] File naming is consistent ✅
- [ ] Navigation is clear and accessible ✅
- [ ] All cross-references work ✅
- [ ] No duplicate folders ✅
- [ ] No confusing subfolder structures ✅

### Validation for Phase 4
- [ ] File naming consistent throughout
- [ ] Navigation files clear and non-overlapping
- [ ] All cross-references validated and working
- [ ] No broken links
- [ ] Final structure review complete and approved
- [ ] Documentation updated with new organization

**Time: 1-2 hours**  
**Impact: LOW-MEDIUM** (Polish, professional appearance)

---

## 🎯 MASTER CHECKLIST: All Phases

### Phase 1 Completion ✅
- [ ] `docs/technical/` folder created
- [ ] TILESET_SYSTEM.md: Code extracted, moved to technical/
- [ ] FIRE_SMOKE_MECHANICS.md: Code extracted, moved to technical/
- [ ] RESOLUTION_SYSTEM_ANALYSIS.md: Code extracted, moved to technical/
- [ ] TESTING.md: Code descriptions replaced
- [ ] Cross-references updated
- [ ] No code in design docs

### Phase 2 Completion ✅
- [ ] `docs/balancing/` → `docs/balance/testing/`
- [ ] `docs/balance/README.md` created
- [ ] `docs/economy/README.md` created
- [ ] Economy folder structure clarified
- [ ] Technical files moved to `docs/technical/`
- [ ] Cross-references updated for all moved files
- [ ] Cleaned up empty folders

### Phase 3 Completion ✅
- [ ] README.md created for all game system folders (10+ files)
- [ ] README.md created for all infrastructure folders (8+ files)
- [ ] README.md created for core/other folders (5+ files)
- [ ] All READMEs follow standard template
- [ ] All READMEs explain folder structure and purpose
- [ ] All READMEs link to implementation and tests

### Phase 4 Completion ✅
- [ ] File naming standardized throughout
- [ ] Navigation files consolidated
- [ ] All cross-references validated
- [ ] No broken links found
- [ ] Final quality check passed
- [ ] Documentation of new organization complete

---

## 📊 TRACKING

### Before You Start
- [ ] Backup current docs/ folder (optional but recommended)
- [ ] Create task in tasks/TODO/ using TASK_TEMPLATE.md
- [ ] Add tracking entries to tasks/tasks.md

### During Implementation
- [ ] Update task status as phases complete
- [ ] Log issues/blockers in task document
- [ ] Save cross-reference updates list

### After Completion
- [ ] Mark task as DONE in tasks.md
- [ ] Update `docs/README.md` with new organization
- [ ] Announce to team: docs structure improved!
- [ ] Consider: Are there other documentation improvements needed?

---

## ⏱️ TIME TRACKING

| Phase | Estimated | Actual | Status |
|-------|-----------|--------|--------|
| Phase 1: Code Hygiene | 2-3 hrs | ___ | Not started |
| Phase 2: Reorganization | 3-4 hrs | ___ | Not started |
| Phase 3: READMEs | 2-3 hrs | ___ | Not started |
| Phase 4: Polish | 1-2 hrs | ___ | Not started |
| **TOTAL** | **8-12 hrs** | ___ | --- |

---

## 🚨 COMMON GOTCHAS

- ⚠️ **Cross-references**: Remember to update ALL files linking to moved files
- ⚠️ **Relative paths**: Make sure new relative paths are correct from new location
- ⚠️ **Git**: If using git, make sure moves are done as renames, not delete+create
- ⚠️ **Case sensitivity**: Windows is case-insensitive but be consistent anyway
- ⚠️ **Subfolders**: Check if subfolders have content before deleting/moving

---

## ✅ When Everything Is Done

- [ ] All phases complete
- [ ] All validation checks pass
- [ ] Task marked as DONE
- [ ] Team notified
- [ ] New developers can navigate docs easily
- [ ] Code standards complied with
- [ ] No code in design docs
- [ ] All folders documented
- [ ] Professional, clean structure

---

**Print this out and check off items as you complete them!**

**Questions?** See DOCS_REORGANIZATION_EXAMPLES.md for concrete examples of each task.
