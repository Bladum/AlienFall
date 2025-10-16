# Deep Analysis: AlienFall Documentation Structure
## Recommendations for Improvement, Reorganization, and Deduplication

**Analysis Date:** October 15, 2025  
**Analyzed By:** AI Documentation Auditor  
**Total Files Analyzed:** 60+ markdown files across docs/ folder  

---

## Executive Summary

The documentation structure is **well-organized but suffers from**:
- ✅ **Strengths**: Clear hierarchical structure, comprehensive coverage, good README files
- ❌ **Issues**: Code/TOML embedded in design docs, folder duplication, unclear folder purposes, navigation redundancy
- 🔧 **Improvements Needed**: 8 major reorganization tasks, 15+ file consolidations

### Quick Stats
- **Total .md files in docs/**: ~55 files
- **Files with embedded Lua code**: 8+ files (should be removed from design docs)
- **Files with TOML examples**: 12+ in TILESET_SYSTEM.md (should be converted to descriptions)
- **Folder duplication pairs**: 3 pairs with overlapping purposes
- **Navigation/Index files**: 4 files with similar content (README, OVERVIEW, QUICK_NAVIGATION, API)
- **Reorganization complexity**: HIGH (affects 20+ files, requires careful linking)

---

## CRITICAL ISSUES FOUND

### 1. ⚠️ Code/TOML Embedded in Design Documentation (VIOLATION OF STANDARDS)

**Problem:** Design docs should contain ONLY game design concepts, not code or configuration examples.

**Affected Files:**

| File | Issue | Recommendation |
|------|-------|-----------------|
| `docs/testing/TESTING.md` | Multiple `lua` code blocks | Replace with descriptions of what code does |
| `docs/systems/FIRE_SMOKE_MECHANICS.md` | 6 `lua` code blocks | Move code to engine/, link to actual implementation |
| `docs/systems/RESOLUTION_SYSTEM_ANALYSIS.md` | 7 `lua` code blocks | Convert to conceptual descriptions |
| `docs/systems/TILESET_SYSTEM.md` | **12 TOML + 7 Lua blocks** | Major issue - convert all to text descriptions |
| `docs/core/LUA_BEST_PRACTICES.md` | 15+ lua blocks (APPROPRIATE) | Keep - this is technical documentation |
| `docs/core/LUA_DOCSTRING_GUIDE.md` | Lua code blocks (APPROPRIATE) | Keep - this is a code standard guide |
| `docs/testing/framework.md` | Code blocks (APPROPRIATE) | Keep - this is a technical framework doc |

**Action Required:**
- [ ] Extract code from `TILESET_SYSTEM.md` → Create `docs/technical/TILESET_IMPLEMENTATION.md`
- [ ] Extract code from `FIRE_SMOKE_MECHANICS.md` → Create `docs/technical/FIRE_SMOKE_IMPLEMENTATION.md`
- [ ] Extract code from `RESOLUTION_SYSTEM_ANALYSIS.md` → Create `docs/technical/RESOLUTION_IMPLEMENTATION.md`
- [ ] Replace code with descriptions: "This system uses a coordinate system with values ranging from..."

---

### 2. 🔄 Duplicate/Overlapping Folder Purposes

**Problem:** Multiple folders cover similar concepts with unclear relationship.

#### Pair 1: `balance/` vs `balancing/`
```
docs/balance/
    └── GAME_NUMBERS.md (276 lines)
    
docs/balancing/
    └── framework.md (148 lines)
```
**Issue:** Both cover balance concepts
- `balance/GAME_NUMBERS.md` = Game balance numeric data
- `balancing/framework.md` = Balance testing framework

**Recommendation:** CONSOLIDATE
- [ ] Keep: `docs/balance/` (game balance focus)
- [ ] Rename: `balancing/` → `balance/testing/` (move framework.md there)
- [ ] Result: `docs/balance/GAME_NUMBERS.md` + `docs/balance/testing/framework.md`

#### Pair 2: `economy/` structure duplication
```
docs/economy/
    ├── research.md
    ├── research/              ← Subfolder exists!
    ├── manufacturing.md
    ├── production/            ← Subfolder exists!
    ├── marketplace.md
    └── marketplace/           ← Subfolder exists!
```
**Issue:** Files and folders with same names at different levels

**Current Status:**
- `docs/economy/research.md` (216 lines) 
- `docs/economy/research/` (folder, appears empty based on structure)
- `docs/economy/production/` (folder exists)
- `docs/economy/manufacturing.md` (264 lines)
- `docs/economy/marketplace.md` (140 lines)
- `docs/economy/marketplace/` (folder exists)
- `docs/economy/finance/` (folder exists - unclear purpose)

**Recommendation:** CLARIFY & REORGANIZE
- [ ] `docs/economy/research.md` = Keep as main design doc
  - `docs/economy/research/` = Remove if empty, or clarify subfolder purpose
- [ ] `docs/economy/manufacturing.md` = Keep as main design doc
  - `docs/economy/production/` = Rename to subdocs if needed
- [ ] `docs/economy/marketplace.md` = Keep as main design doc
  - `docs/economy/marketplace/` = Clarify or remove
- [ ] `docs/economy/finance/` = UNCLEAR - Rename to `docs/economy/funding/` or merge with funding.md
- [ ] Create `docs/economy/README.md` explaining the subfolder structure

#### Pair 3: `content/` structure fragmentation
```
docs/content/
    ├── items.md
    ├── crafts/              ← Subfolder
    ├── equipment/           ← Subfolder
    ├── facilities/          ← Subfolder
    └── units/               ← Subfolder

Engine mirrors this:
engine/content/             ← Empty?
engine/battlescape/units/   ← Where content actually lives?
engine/basescape/           ← Where facilities live?
```
**Recommendation:** CLARIFY STRUCTURE
- [ ] Decide: Is `docs/content/` the right folder for these, or should they be:
  - `docs/battlescape/content/units/`?
  - `docs/basescape/content/facilities/`?
  - `docs/economy/content/manufacturing/`?
- [ ] Create master `docs/content/README.md` explaining organization
- [ ] Update engine/ structure to match docs/ organization

---

### 3. 📍 Navigation Files with Redundant Content

**Problem:** 4 main navigation/overview files with overlapping purposes.

| File | Lines | Purpose | Overlap Issue |
|------|-------|---------|---------------|
| `README.md` | 80 lines | Folder intro, structure, document standards | Explains PURPOSE of docs/ |
| `OVERVIEW.md` | 186 lines | Game design overview, flow diagrams | Explains GAME DESIGN high-level |
| `QUICK_NAVIGATION.md` | 355 lines | Index of all docs, links, statistics | Explains WHERE TO FIND THINGS |
| `API.md` | 1,811 lines | Complete API reference | Technical developer reference |

**Current Redundancy:**
- `README.md` + `OVERVIEW.md` both start with "purpose" statements
- `QUICK_NAVIGATION.md` duplicates links from `README.md` folder structure
- `API.md` separate from design docs (unclear relationship)
- New users unclear which to read first

**Recommendation:** STREAMLINE
- [ ] **Keep:** `README.md` (What this folder is)
- [ ] **Keep:** `OVERVIEW.md` (Game design overview)
- [ ] **MERGE:** `QUICK_NAVIGATION.md` → Move useful sections to `README.md`, keep as extended index
- [ ] **Clarify:** `API.md` - Should this be in `docs/` or `wiki/`? (Currently unclear)

**New Navigation Flow:**
1. Start: `docs/README.md` (What is this folder?)
2. Explore: `docs/OVERVIEW.md` (What is this game?)
3. Find: `docs/QUICK_NAVIGATION.md` (Where is [X]?)
4. Reference: `docs/API.md` (Technical API)

---

### 4. 🗂️ Unclear Folder Purposes

Several folders lack clear purpose or structure:

| Folder | Status | Issue | Recommendation |
|--------|--------|-------|-----------------|
| `docs/ai/` | 4 subfolders | No README explaining structure | Add README explaining diplomacy/pathfinding/strategic/tactical organization |
| `docs/geoscape/` | Many subfolders | 10+ folders, unclear hierarchy | Create master organization diagram in README |
| `docs/battlescape/` | Many subfolders | 10+ files and folders mixed | Separate "design" docs from "technical" docs |
| `docs/systems/` | 3 large technical files | More technical than design | Should these be in `docs/technical/` instead? |
| `docs/rendering/` | 1 file | Single file folder | Consider moving to `docs/technical/` |
| `docs/design/` | 1 file | Single file folder | Consider moving to `docs/references/` |
| `docs/analytics/` | Empty folder? | No files visible | Remove or populate with design |
| `docs/scenes/` | Empty folder? | No files visible | Remove or populate with design |
| `docs/tutorial/` | Empty folder? | No files visible | Remove or populate with design |
| `docs/widgets/` | Empty folder? | No files visible | Remove or populate with design |
| `docs/network/` | 1 file (multiplayer.md) | Minimal content | OK for future expansion |

**Action Items:**
- [ ] Add README to all folders with purpose and subfolder structure
- [ ] Create `docs/technical/` folder for implementation-focused technical docs
- [ ] Move technical analysis docs: `systems/`, `rendering/` to `docs/technical/`
- [ ] Consolidate empty folders or remove them
- [ ] Create organization diagrams showing folder hierarchy

---

### 5. 📄 Files Needing Consolidation or Splitting

#### A. Files That Should Be Split

| File | Size | Recommendation |
|------|------|-----------------|
| `docs/battlescape/COMBAT_SYSTEMS_COMPLETE.md` | Large? | Split into: combat-basics.md, combat-advanced.md, combat-ai.md |
| `docs/geoscape/STRATEGIC_LAYER_IMPLEMENTATION_PLAN.md` | Large? | Too implementation-focused; move to `docs/technical/` |
| `docs/systems/TILESET_SYSTEM.md` | 825 lines | MAJOR: Split into design + technical implementation docs |
| `docs/systems/RESOLUTION_SYSTEM_ANALYSIS.md` | 656 lines | Split into design + technical analysis |

#### B. Files That Should Be Consolidated

| Files | Recommendation |
|-------|-----------------|
| `docs/core/LUA_BEST_PRACTICES.md` + `docs/core/LUA_DOCSTRING_GUIDE.md` | Keep separate - they serve different purposes |
| `docs/geoscape/STRATEGIC_LAYER_*.md` (3 files) | These may overlap - audit for duplication |
| `docs/battlescape/3D_BATTLESCAPE_*.md` (2 files) | Review for consolidation |

---

### 6. 🏗️ Naming Inconsistencies

**Problem:** File naming conventions are inconsistent.

```
✅ Good naming (consistent):
- docs/economy/research.md (lowercase, specific)
- docs/economy/manufacturing.md (lowercase, specific)
- docs/economy/marketplace.md (lowercase, specific)

❌ Bad naming (inconsistent):
- docs/OVERVIEW.md (CAPS)
- docs/QUICK_NAVIGATION.md (CAPS + underscores)
- docs/battlescape/COMBAT_SYSTEMS_COMPLETE.md (CAPS + descriptive)
- docs/systems/FIRE_SMOKE_MECHANICS.md (CAPS + UNDERSCORES)
- docs/systems/RESOLUTION_SYSTEM_ANALYSIS.md (CAPS + descriptive)
- docs/systems/TILESET_SYSTEM.md (CAPS)
- docs/geoscape/STRATEGIC_LAYER_DIAGRAMS.md (CAPS + descriptive)
- docs/geoscape/STRATEGIC_LAYER_QUICK_REFERENCE.md (CAPS + descriptive)
- docs/geoscape/STRATEGIC_LAYER_IMPLEMENTATION_PLAN.md (CAPS + descriptive)
```

**Recommendation:** STANDARDIZE
- [ ] Root-level index files: Keep UPPERCASE (README.md, OVERVIEW.md, QUICK_NAVIGATION.md, API.md)
- [ ] Design doc files: Use lowercase (missions.md, combat.md, units.md, etc.)
- [ ] Technical/system analysis: Use UPPERCASE (SYSTEM_NAME.md) with clear purpose
- [ ] OR: Create subfolder `docs/analysis/` for large analysis/reference files

**Suggested Renames:**
```
docs/battlescape/COMBAT_SYSTEMS_COMPLETE.md 
  → docs/technical/COMBAT_SYSTEMS_COMPLETE.md
  
docs/battlescape/3D_BATTLESCAPE_ARCHITECTURE.md
  → docs/technical/3D_BATTLESCAPE_ARCHITECTURE.md
  
docs/systems/TILESET_SYSTEM.md
  → docs/technical/TILESET_SYSTEM.md
  
docs/systems/RESOLUTION_SYSTEM_ANALYSIS.md
  → docs/technical/RESOLUTION_SYSTEM_ANALYSIS.md
  
docs/systems/FIRE_SMOKE_MECHANICS.md
  → docs/technical/FIRE_SMOKE_MECHANICS.md
  
docs/geoscape/STRATEGIC_LAYER_*.md (3 files)
  → docs/technical/GEOSCAPE_STRATEGIC_LAYER_*.md
```

---

### 7. 📚 Missing Documentation

Folders that exist in `docs/` but have no or minimal content:

```
❌ Empty or near-empty:
- docs/analytics/ (empty?)
- docs/scenes/ (empty?)
- docs/tutorial/ (empty?)
- docs/utils/ (empty?)
- docs/widgets/ (empty?)
- docs/politics/ (has subfolders but no README?)
- docs/progression/ (only organization.md)
- docs/localization/ (empty?)

⚠️ Single file folders:
- docs/design/ (1 file: REFERENCES.md)
- docs/rendering/ (1 file: HEX_RENDERING_GUIDE.md)
- docs/network/ (1 file: multiplayer.md)
- docs/lore/ (1 file: narrative.md)
```

**Recommendation:**
- [ ] Either populate these folders with design docs OR remove them
- [ ] Add README to all non-empty folders
- [ ] Create placeholder README for future-expansion folders

---

### 8. 🔗 Cross-Linking Issues

**Problem:** Relative paths in cross-references may be broken or unclear.

**Current Pattern:** Files use `../../../engine/path/` which works but is fragile.

**Better Approach:**
- [ ] Use consistent path format in all files
- [ ] Consider creating `docs/cross-reference-map.md` documenting all links
- [ ] Validate all cross-references with automated script

---

## RECOMMENDATIONS SUMMARY

### Priority 1 (CRITICAL - Do First)
These changes improve code hygiene and fix violations:

1. **Remove code from design docs**
   - Extract code from TILESET_SYSTEM.md → Create TILESET_IMPLEMENTATION.md
   - Extract code from FIRE_SMOKE_MECHANICS.md → Create FIRE_SMOKE_IMPLEMENTATION.md
   - Extract code from RESOLUTION_SYSTEM_ANALYSIS.md → Create RESOLUTION_IMPLEMENTATION.md
   - Convert remaining code descriptions to text
   - **Effort:** 2-3 hours
   - **Impact:** HIGH - Fixes documentation standards violation

2. **Consolidate balance/ and balancing/ folders**
   - Rename `docs/balancing/` → `docs/balance/testing/`
   - Move `framework.md` to new location
   - Update cross-references
   - **Effort:** 30 minutes
   - **Impact:** MEDIUM - Reduces confusion

3. **Create technical/ folder for large analysis files**
   - Create `docs/technical/` folder
   - Move analysis files: TILESET_SYSTEM.md, RESOLUTION_SYSTEM_ANALYSIS.md, FIRE_SMOKE_MECHANICS.md, etc.
   - Update navigation docs
   - **Effort:** 1 hour
   - **Impact:** HIGH - Clarifies folder organization

---

### Priority 2 (HIGH - Do Next)
These improve organization and reduce duplication:

4. **Standardize file naming**
   - Create naming convention document
   - Rename inconsistently-named files
   - Update all cross-references
   - **Effort:** 2-3 hours
   - **Impact:** HIGH - Makes navigation easier

5. **Clarify economy/ subfolder structure**
   - Determine purpose of research/, production/, marketplace/, finance/ subfolders
   - Either populate with content or remove
   - Create `docs/economy/README.md` explaining structure
   - **Effort:** 1-2 hours
   - **Impact:** HIGH - Fixes confusing duplicate names

6. **Add README files to all folders**
   - Create README for: ai/, geoscape/, battlescape/, content/, politics/, etc.
   - Explain folder purpose and subfolder structure
   - **Effort:** 2-3 hours
   - **Impact:** HIGH - Improves navigability

---

### Priority 3 (MEDIUM - Do After)
These improve documentation completeness:

7. **Consolidate navigation files**
   - Merge QUICK_NAVIGATION.md into README.md (keep as extended reference)
   - Clarify API.md purpose (should it be in wiki/ instead?)
   - **Effort:** 1 hour
   - **Impact:** MEDIUM - Reduces redundancy

8. **Populate or remove empty folders**
   - Decide: Is each folder for design content or obsolete?
   - Either add README + content or delete
   - **Effort:** 1-2 hours
   - **Impact:** MEDIUM - Cleans up structure

9. **Audit and consolidate large files**
   - COMBAT_SYSTEMS_COMPLETE.md - Split if too large
   - STRATEGIC_LAYER_*.md (3 files) - Check for duplication
   - 3D_BATTLESCAPE_*.md (2 files) - Check for duplication
   - **Effort:** 2-3 hours
   - **Impact:** MEDIUM - Improves readability

---

### Priority 4 (LOW - Nice to Have)
These are improvements for polish:

10. **Create automated cross-reference validator**
    - Script to check all docs/ links are valid
    - Report broken references
    - **Effort:** 1-2 hours
    - **Impact:** LOW - Technical maintenance

11. **Create cross-reference map document**
    - Document all major links between design and implementation
    - **Effort:** 1-2 hours
    - **Impact:** LOW - Nice reference

12. **Create visual documentation hierarchy**
    - Mermaid diagram showing folder structure and relationships
    - Add to README.md
    - **Effort:** 1 hour
    - **Impact:** LOW - Improves understanding

---

## PROPOSED NEW FOLDER STRUCTURE

### Current vs Proposed

```
CURRENT (58 folders/files):
docs/
├── README.md, OVERVIEW.md, QUICK_NAVIGATION.md, API.md
├── ai/ (4 subfolders)
├── analytics/ (empty?)
├── assets/ (2 files)
├── balance/ (1 file)
├── balancing/ (1 file) ← DUPLICATE
├── basescape/ (5+ subfolders)
├── battlescape/ (10+ files/subfolders)
├── content/ (4 subfolders)
├── core/ (6 files)
├── design/ (1 file)
├── economy/ (3 files + 3 subfolders) ← CONFUSING
├── geoscape/ (10+ files/subfolders)
├── interception/ (probably empty?)
├── localization/ (empty?)
├── lore/ (1 file)
├── mods/ (1 file)
├── network/ (1 file)
├── politics/ (5 subfolders)
├── progression/ (1 file)
├── rendering/ (1 file)
├── rules/ (1 file)
├── scenes/ (empty?)
├── systems/ (3 large files) ← SHOULD BE technical/
├── testing/ (2 files)
├── tutorial/ (empty?)
├── ui/ (1 file)
├── utils/ (empty?)
└── widgets/ (empty?)

PROPOSED (reorganized):
docs/
├── README.md (consolidated navigation)
├── OVERVIEW.md (game design overview)
├── QUICK_NAVIGATION.md (extended index)
├── API.md (technical API reference)
│
├── 🎮 GAME SYSTEMS
│   ├── geoscape/ (strategic layer)
│   ├── basescape/ (base management)
│   ├── battlescape/ (tactical combat)
│   ├── interception/ (craft combat)
│   ├── economy/ (streamlined structure)
│   │   ├── README.md (explain structure)
│   │   ├── research.md
│   │   ├── manufacturing.md
│   │   ├── marketplace.md
│   │   ├── funding.md
│   │   └── [remove duplicate subfolders or clarify]
│   ├── politics/ (diplomacy, relations)
│   ├── ai/ (strategic, tactical, diplomacy, pathfinding)
│   ├── lore/ (narrative, campaign)
│   ├── ui/ (interface design)
│   └── [other game systems with READMEs]
│
├── 📚 CONTENT
│   ├── README.md
│   ├── units/
│   ├── equipment/
│   ├── crafts/
│   ├── facilities/
│   └── items/
│
├── ⚙️ TECHNICAL (New folder)
│   ├── README.md (technical docs explanation)
│   ├── TILESET_SYSTEM.md (moved from systems/)
│   ├── RESOLUTION_SYSTEM.md (moved from systems/)
│   ├── FIRE_SMOKE_MECHANICS.md (moved from systems/)
│   ├── HEX_RENDERING_GUIDE.md (moved from rendering/)
│   ├── COMBAT_SYSTEMS_COMPLETE.md (moved from battlescape/)
│   ├── 3D_BATTLESCAPE_ARCHITECTURE.md (moved from battlescape/)
│   ├── STRATEGIC_LAYER_DIAGRAMS.md (moved from geoscape/)
│   └── [other large technical analysis files]
│
├── 📋 CORE
│   ├── README.md
│   ├── concepts.md
│   ├── implementation.md
│   ├── physics.md
│   ├── LUA_BEST_PRACTICES.md (keep - technical standard)
│   └── LUA_DOCSTRING_GUIDE.md (keep - technical standard)
│
├── 🧪 TESTING & QUALITY
│   ├── README.md
│   ├── TESTING.md (remove embedded code)
│   ├── framework.md
│   └── balancing/
│       └── framework.md (moved from balancing/)
│
├── 🛠️ INFRASTRUCTURE
│   ├── assets/ (asset design)
│   ├── localization/ (internationalization)
│   ├── mods/ (modding system)
│   ├── network/ (multiplayer/networking)
│   ├── scenes/ (scene management)
│   └── utils/ (utility systems)
│
└── 📖 REFERENCE & DESIGN
    ├── GLOSSARY.md (terminology)
    ├── design/REFERENCES.md (external references)
    ├── core/concepts.md (conceptual framework)
    └── rules/MECHANICAL_DESIGN.md (game rules)
```

**Benefits:**
- ✅ Clear separation of game systems from technical docs
- ✅ Consistent naming and structure
- ✅ No more code in design docs
- ✅ Clearer folder purposes with READMEs
- ✅ Reduced duplication and confusion

---

## IMPLEMENTATION ROADMAP

### Phase 1: Code Hygiene (2-3 hours)
**Goal:** Remove code/TOML from design docs

- [ ] Task: Extract code blocks from TILESET_SYSTEM.md
  - Create design-focused version with descriptions
  - Create TILESET_IMPLEMENTATION.md in technical/ with code
  - Update cross-references
  
- [ ] Task: Extract code from FIRE_SMOKE_MECHANICS.md
  - Replace code with descriptions
  - Create FIRE_SMOKE_IMPLEMENTATION.md

- [ ] Task: Extract code from RESOLUTION_SYSTEM_ANALYSIS.md
  - Replace code with descriptions
  - Create RESOLUTION_IMPLEMENTATION.md

- [ ] Task: Remove code from TESTING.md
  - Replace with descriptions
  - Link to actual test implementation

### Phase 2: Folder Reorganization (3-4 hours)
**Goal:** Reorganize folders for clarity

- [ ] Create `docs/technical/` folder
- [ ] Move analysis files to technical/
- [ ] Rename `docs/balancing/` → `docs/balance/testing/`
- [ ] Consolidate `docs/economy/` subfolders
- [ ] Create README files for all folders
- [ ] Update all cross-references

### Phase 3: Naming Standardization (2-3 hours)
**Goal:** Fix naming inconsistencies

- [ ] Create naming convention document
- [ ] Rename inconsistent files (use lowercase for design docs, UPPERCASE for technical)
- [ ] Update all cross-references

### Phase 4: Cleanup & Validation (1-2 hours)
**Goal:** Final polish

- [ ] Consolidate navigation files
- [ ] Populate or remove empty folders
- [ ] Validate all cross-references
- [ ] Create cross-reference map document

**Total Effort:** 8-12 hours  
**Complexity:** HIGH (requires careful coordination of renames and cross-references)

---

## METRICS & VALIDATION

### Before Changes
- Total files: ~55
- Files with embedded code: 8
- Files with code/TOML: 25+
- Empty folders: 5+
- Duplicate folder pairs: 3
- Navigation files: 4 with overlap
- Broken cross-references: Unknown

### After Changes (Target)
- Total files: ~55 (same)
- Files with embedded code: 2-3 (only technical/reference files)
- Files with code/TOML: 0 in design docs
- Empty folders: 0
- Duplicate folder pairs: 0
- Navigation files: 3 (clear purpose)
- Broken cross-references: 0

---

## NEXT STEPS

1. **Review this analysis** - Get stakeholder feedback
2. **Create task document** - Break into concrete tasks in tasks/TODO/
3. **Phase 1 execution** - Remove code from design docs (Quick win)
4. **Phase 2 execution** - Reorganize folders
5. **Phase 3 execution** - Standardize naming
6. **Phase 4 execution** - Final cleanup and validation
7. **Documentation update** - Update README/OVERVIEW after changes
8. **Cross-reference validation** - Run final link checks

---

## APPENDIX A: Files That Need Code Removal

### docs/systems/TILESET_SYSTEM.md
- **Current:** 825 lines with 12 TOML + 7 Lua blocks
- **Action:** Create design version + TILESET_IMPLEMENTATION.md
- **Scope:** Large refactoring needed

### docs/systems/FIRE_SMOKE_MECHANICS.md
- **Current:** 334 lines with 6 Lua blocks
- **Action:** Extract code blocks, create FIRE_SMOKE_IMPLEMENTATION.md
- **Scope:** Medium refactoring

### docs/systems/RESOLUTION_SYSTEM_ANALYSIS.md
- **Current:** 656 lines with 7 Lua blocks
- **Action:** Extract code blocks, create RESOLUTION_IMPLEMENTATION.md
- **Scope:** Large refactoring

### docs/testing/TESTING.md
- **Current:** Multiple Lua blocks
- **Action:** Replace with descriptions of test patterns
- **Scope:** Medium refactoring

---

## APPENDIX B: Empty or Near-Empty Folders

Check and decide on these:
- `docs/analytics/` - Telemetry/metrics design docs?
- `docs/scenes/` - Scene management design docs?
- `docs/tutorial/` - Tutorial system design docs?
- `docs/utils/` - Utility systems design docs?
- `docs/widgets/` - Widget library design docs?
- `docs/interception/` - Should have content?
- `docs/localization/` - Should have content (mentioned in tasks)?
- `docs/progression/` - Only organization.md, incomplete?

---

## APPENDIX C: Folder Purpose Clarifications Needed

| Folder | Current | Needs Clarification |
|--------|---------|-------------------|
| `docs/content/` | items.md + subfolders | Should items be content/items/ or content/equipment/? |
| `docs/geoscape/` | 10+ files/folders | How do 9 subfolders relate? What are data/ geography/ rendering/ subfolders for? |
| `docs/battlescape/` | 10+ files/folders | Clear organization, but files like COMBAT_SYSTEMS_COMPLETE are too large |
| `docs/ai/` | 4 subfolders | README needed explaining diplomacy/pathfinding/strategic/tactical separation |
| `docs/politics/` | 5 subfolders | README needed explaining folder structure |
| `docs/economy/` | Files + duplicate subfolders | MAJOR confusion with research/ production/ marketplace/ finance/ |

---

**Document prepared:** October 15, 2025  
**Status:** READY FOR IMPLEMENTATION  
**Recommended:** Start with Priority 1 items (code removal) for immediate improvement
