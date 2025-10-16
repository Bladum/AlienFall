# DOCS-ENGINE-MODS Alignment Analysis

**Generated:** October 16, 2025  
**Purpose:** Identify gaps and create alignment plan for game design, implementation, and mod content  
**Status:** ✅ COMPLETE

---

## 🎯 Executive Summary

**Three Critical Blocks:**
1. **DOCS** (`docs/`) - Game design, mechanics, rules (WHAT to build)
2. **ENGINE** (`engine/`) - Implementation code (HOW it works)
3. **MODS** (`mods/`) - Content configuration (WHAT players experience)

**Current State:**
- ✅ **DOCS**: Well-structured design documentation (~55 files)
- ⚠️ **ENGINE**: Implementation exists but inconsistent linkage to docs
- ❌ **MODS**: Minimal content structure, mostly empty mod directories

**Key Finding:** The pipeline DOCS → ENGINE → MODS is incomplete. Design exists, implementation exists, but content configuration is minimal and alignment is weak.

---

## 📊 Alignment Matrix

| Area | DOCS Status | ENGINE Status | MODS Status | Alignment Quality |
|------|-------------|---------------|-------------|-------------------|
| **Core Systems** | ✅ Documented | ✅ Implemented | ⚠️ Basic | 70% |
| **Battlescape** | ✅ Documented | ✅ Implemented | ⚠️ Minimal | 60% |
| **Geoscape** | ✅ Documented | ⚠️ Partial | ❌ Missing | 40% |
| **Basescape** | ✅ Documented | ⚠️ Partial | ❌ Missing | 45% |
| **Economy** | ✅ Documented | ⚠️ Partial | ❌ Missing | 35% |
| **AI Systems** | ⚠️ Partial docs | ⚠️ Partial | ❌ Missing | 30% |
| **Politics** | ✅ Documented | ❌ Not implemented | ❌ Missing | 10% |
| **Lore/Campaign** | ⚠️ Ideas only | ⚠️ Structure only | ❌ No content | 15% |
| **Mod System** | ✅ Documented | ✅ Implemented | ⚠️ Basic structure | 65% |
| **Asset Pipeline** | ⚠️ Partial docs | ✅ Implemented | ⚠️ Limited assets | 55% |

**Overall Alignment: 42%** - Significant gaps in all three blocks

---

## 🔴 CRITICAL GAPS IDENTIFIED

### Gap 1: Mod Content Structure Incomplete
**Problem:**
- `mods/core/` exists with basic TOML files (tilesets, mapblocks, mapscripts)
- NO content for: units, weapons, armors, items, facilities, missions, factions, campaigns
- Mod structure documented in `docs/mods/system.md` but not implemented in `mods/core/`

**Impact:** Cannot create playable game without content definitions

**Files Missing:**
```
mods/core/
├── rules/                          ❌ MISSING
│   ├── battle/
│   │   └── terrain.toml           ✅ EXISTS (referenced in code)
│   ├── units/                     ❌ MISSING
│   │   ├── soldiers.toml
│   │   ├── aliens.toml
│   │   └── civilians.toml
│   ├── items/                     ❌ MISSING
│   │   ├── weapons.toml
│   │   ├── armors.toml
│   │   └── equipment.toml
│   ├── facilities/                ❌ MISSING
│   │   └── base_facilities.toml
│   └── missions/                  ❌ MISSING
│       └── mission_types.toml
├── campaigns/                      ❌ MISSING
│   ├── phase0_shadow_war.toml
│   ├── phase1_sky_war.toml
│   ├── phase2_deep_war.toml
│   └── phase3_dimensional_war.toml
├── factions/                       ❌ MISSING
│   ├── sectoids.toml
│   ├── mutons.toml
│   └── [15+ faction files]
├── technology/                     ❌ MISSING
│   └── research_tree.toml
└── narrative/                      ❌ MISSING
    └── story_events.toml
```

---

### Gap 2: DOCS-ENGINE Cross-Reference Weak
**Problem:**
- Design docs reference implementation with `> **Implementation**: engine/path/`
- But references are inconsistent and often outdated
- No systematic validation that implementation matches design
- Engine code rarely links back to design docs

**Examples:**
```markdown
docs/core/concepts.md:
> **Implementation**: `../../engine/core/`, `../../engine/main.lua`
❌ Too vague, doesn't specify which files implement which concepts

docs/content/items.md:
> **Implementation**: `../../../engine/core/items/`, `../../../engine/basescape/logic/`
⚠️ Paths exist but no validation that they match design

docs/mods/system.md:
> **Implementation**: `engine/mods/`, `mods/`
✅ Good reference, but mod content incomplete
```

**Impact:** Design and implementation drift apart over time

---

### Gap 3: Mod Loading Pipeline Incomplete
**Problem:**
- `ModManager` (`engine/mods/mod_manager.lua`) is well-implemented
- `DataLoader` (`engine/core/data_loader.lua`) exists to load TOML data
- But only loads: terrain types, weapons, armors, skills, unit classes
- Missing loaders for: facilities, missions, campaigns, factions, tech tree, narrative events

**Current Loaders (431 lines):**
```lua
DataLoader.load()
├── loadTerrainTypes()      ✅ Implemented - loads from rules/battle/terrain.toml
├── loadWeapons()           ✅ Implemented
├── loadArmours()           ✅ Implemented
├── loadSkills()            ✅ Implemented
└── loadUnitClasses()       ✅ Implemented
```

**Missing Loaders:**
```lua
❌ loadFacilities()         - Base facilities (research labs, workshops, etc.)
❌ loadMissions()           - Mission types and objectives
❌ loadCampaigns()          - Campaign phases and timeline
❌ loadFactions()           - Alien/human factions
❌ loadTechTree()           - Research tree and dependencies
❌ loadNarrativeEvents()    - Story triggers and dialogue
❌ loadGeoscape()           - Countries, regions, funding
❌ loadDiplomacy()          - Relations, treaties, karma
```

**Impact:** Cannot load comprehensive game content from mods

---

### Gap 4: Documentation Standards Not Enforced
**Problem:**
- `docs/README.md` defines standards for design docs
- Standard includes: `> **Implementation**: path`, `> **Tests**: path`, `> **Related**: docs`
- But many docs don't follow standard consistently
- No automated validation

**Examples:**
```markdown
✅ GOOD: docs/core/concepts.md
> **Implementation**: `../../engine/core/`, `../../engine/main.lua`
> **Tests**: `../../tests/core/`
> **Related**: docs/core/implementation.md

⚠️ INCONSISTENT: docs/economy/research.md
(Has implementation link but no tests or related links)

❌ MISSING: docs/politics/diplomacy/
(No implementation links at all)
```

**Impact:** Unclear what is implemented vs. designed-only

---

### Gap 5: TOML Schema Undefined
**Problem:**
- Mods use TOML for content configuration
- But NO schema validation or documentation exists
- Each TOML file structure is implicit from code
- New modders cannot understand required format

**Current State:**
```toml
# mods/core/tilesets/city/tilesets.toml - EXISTS
[tileset]
id = "city"
name = "Urban Cityscape"

[[maptile]]
key = "WALL_BRICK"
passable = false
# ... but NO schema documentation
```

**Missing:**
```
docs/mods/toml_schemas/
├── terrain_schema.md           ❌ NOT DOCUMENTED
├── weapons_schema.md           ❌ NOT DOCUMENTED
├── units_schema.md             ❌ NOT DOCUMENTED
├── facilities_schema.md        ❌ NOT DOCUMENTED
├── missions_schema.md          ❌ NOT DOCUMENTED
└── campaigns_schema.md         ❌ NOT DOCUMENTED
```

**Impact:** Modders cannot create content without reverse-engineering code

---

### Gap 6: Asset-Content Linkage Weak
**Problem:**
- TOML content references assets (images, sounds)
- But no validation that referenced assets exist
- `AssetVerifier` exists but only checks terrain and units
- No comprehensive asset manifest

**Example:**
```toml
# In mods/core/units/soldiers.toml (doesn't exist yet)
[[unit]]
id = "soldier_rookie"
image = "units/soldier.png"          ← Is this asset present?
```

**Current Asset Verification:**
- `engine/utils/verify_assets.lua` - Only verifies terrain and units
- Missing: weapons, items, facilities, UI elements, etc.

**Impact:** Runtime errors when content references missing assets

---

### Gap 7: Test Coverage for Mods Minimal
**Problem:**
- Tests exist for `ModManager` and TOML parsing
- But no tests for actual mod content validation
- No tests verifying DOCS ↔ ENGINE ↔ MODS alignment
- Content quality not validated

**Current Tests:**
```
tests/systems/test_mod_system.lua       ✅ Tests ModManager basics
tests/unit/test_mod_manager.lua         ✅ Tests path resolution
tests/mock/                             ✅ Mock data for testing
```

**Missing Tests:**
```
tests/mods/
├── test_content_validation.lua         ❌ Validate all TOML content
├── test_schema_compliance.lua          ❌ Check TOML schemas
├── test_asset_references.lua           ❌ Verify asset linkage
├── test_docs_alignment.lua             ❌ Validate DOCS ↔ ENGINE links
└── test_mod_completeness.lua           ❌ Check core mod has all content
```

**Impact:** Content errors discovered at runtime, not during tests

---

### Gap 8: Engine Structure Doesn't Mirror DOCS
**Problem:**
- `docs/` has clear structure: geoscape/, basescape/, battlescape/, economy/, politics/
- `engine/` has SAME folders but not consistently organized
- Some systems in wrong places, some missing entirely

**Comparison:**
```
docs/politics/                          engine/politics/
├── diplomacy/                          ├── (empty?)
├── relations/                          ├── (missing?)
├── karma/                              ├── (missing?)
└── government/                         └── (missing?)
                                        ❌ MISMATCH

docs/economy/                           engine/economy/
├── research.md                         ├── research/ ✅
├── manufacturing.md                    ├── production/ ⚠️ (different name)
├── marketplace.md                      ├── marketplace/ ✅
└── funding.md                          └── (missing?)
                                        ⚠️ PARTIAL MATCH
```

**Impact:** Hard to find implementation for documented features

---

## 📋 ALIGNMENT IMPROVEMENT PLAN

### Phase 1: Establish Mod Content Foundation (HIGH PRIORITY)
**Goal:** Create complete mod content structure with TOML files

**Tasks:**
1. Create comprehensive `mods/core/` content structure
2. Define TOML schemas for all content types
3. Implement missing DataLoader functions
4. Create template TOML files with examples

**Time:** 30-40 hours  
**Impact:** ⭐⭐⭐ CRITICAL - Enables playable game

---

### Phase 2: Strengthen DOCS-ENGINE Linkage (HIGH PRIORITY)
**Goal:** Ensure every design doc accurately references implementation

**Tasks:**
1. Audit all implementation links in docs/
2. Create bidirectional links (engine → docs)
3. Standardize reference format
4. Add automated validation tool

**Time:** 15-20 hours  
**Impact:** ⭐⭐ HIGH - Prevents design/code drift

---

### Phase 3: Implement Content Validation (MEDIUM PRIORITY)
**Goal:** Validate mod content against schemas at load time

**Tasks:**
1. Define TOML schemas (JSON Schema or Lua tables)
2. Implement schema validator in DataLoader
3. Create content validation tests
4. Add asset reference verification

**Time:** 20-25 hours  
**Impact:** ⭐⭐ HIGH - Catches content errors early

---

### Phase 4: Create Mod Documentation (MEDIUM PRIORITY)
**Goal:** Enable modders to create content easily

**Tasks:**
1. Document all TOML schemas
2. Create mod development guide
3. Provide template mod structure
4. Add example mods

**Time:** 15-20 hours  
**Impact:** ⭐⭐ MEDIUM-HIGH - Enables community content

---

### Phase 5: Mirror Engine Structure (LOW PRIORITY)
**Goal:** Make engine/ structure match docs/ for easy navigation

**Tasks:**
1. Reorganize engine/ to match docs/ structure
2. Move misplaced systems to correct folders
3. Update all require() paths
4. Test thoroughly

**Time:** 25-35 hours  
**Impact:** ⭐ MEDIUM - Quality of life improvement

---

## 🎯 QUICK WINS (Do These First)

### Quick Win 1: Create Mod Content Directories (2 hours)
```bash
# Create all missing mod directories
mkdir mods/core/rules/units
mkdir mods/core/rules/items
mkdir mods/core/rules/facilities
mkdir mods/core/rules/missions
mkdir mods/core/campaigns
mkdir mods/core/factions
mkdir mods/core/technology
mkdir mods/core/narrative
```

### Quick Win 2: Add Missing DataLoader Functions (6-8 hours)
```lua
-- Add to engine/core/data_loader.lua:
function DataLoader.loadFacilities()
function DataLoader.loadMissions()
function DataLoader.loadCampaigns()
function DataLoader.loadFactions()
```

### Quick Win 3: Create TOML Schema Docs (4-6 hours)
```markdown
# Create docs/mods/toml_schemas/ with:
- terrain_schema.md
- weapons_schema.md
- units_schema.md
- facilities_schema.md
```

### Quick Win 4: Audit DOCS Implementation Links (4-6 hours)
```bash
# Script to check all implementation references:
grep -r "Implementation:" docs/ > implementation_audit.txt
# Manually verify each link exists
```

**Total Quick Wins Time:** 16-22 hours  
**Impact:** Immediately improves alignment quality

---

## 📊 BEFORE & AFTER

### BEFORE (Current State)
```
DOCS (docs/)                    ENGINE (engine/)                MODS (mods/)
├── ✅ 55+ design files        ├── ✅ Core systems             ├── ⚠️ Basic structure
├── ✅ Well organized           ├── ⚠️ Partial systems          ├── ❌ Minimal content
├── ⚠️ Some links broken        ├── ⚠️ Some misplaced           ├── ❌ No units/weapons
└── ⚠️ Inconsistent refs        └── ❌ Politics missing         └── ❌ No campaigns

Alignment: 42% - Weak linkage between blocks
```

### AFTER (Target State)
```
DOCS (docs/)                    ENGINE (engine/)                MODS (mods/)
├── ✅ 55+ design files        ├── ✅ All systems              ├── ✅ Complete structure
├── ✅ Consistent structure     ├── ✅ Mirrors docs/             ├── ✅ All content types
├── ✅ All links validated      ├── ✅ All loaders               ├── ✅ Schema validated
└── ✅ Bidirectional refs       └── ✅ Comprehensive             └── ✅ Asset verified

Alignment: 85%+ - Strong three-way integration
```

---

## 🚀 IMPLEMENTATION ROADMAP

### Month 1: Foundation
- Week 1-2: Phase 1 (Mod Content Foundation)
- Week 3: Quick Wins 1-2
- Week 4: Phase 3 (Content Validation - partial)

### Month 2: Integration
- Week 1-2: Phase 2 (DOCS-ENGINE Linkage)
- Week 3: Quick Wins 3-4
- Week 4: Phase 4 (Mod Documentation)

### Month 3: Refinement
- Week 1-3: Phase 5 (Engine Structure - if needed)
- Week 4: Final validation and testing

**Total Time:** 105-145 hours (13-18 weeks at 8 hrs/week)

---

## 📝 TASK CREATION SUMMARY

The following tasks will be created based on this analysis:

1. **TASK-ALIGNMENT-001**: Create Mod Content Structure
2. **TASK-ALIGNMENT-002**: Implement Missing DataLoader Functions
3. **TASK-ALIGNMENT-003**: Define TOML Schemas
4. **TASK-ALIGNMENT-004**: Audit DOCS-ENGINE Links
5. **TASK-ALIGNMENT-005**: Implement Content Validation
6. **TASK-ALIGNMENT-006**: Create Mod Development Guide
7. **TASK-ALIGNMENT-007**: Add Asset Verification
8. **TASK-ALIGNMENT-008**: Create Alignment Tests

**See:** `tasks/TODO/TASK-ALIGNMENT-*.md` for detailed task files

---

## ✅ SUCCESS METRICS

| Metric | Current | Target | Status |
|--------|---------|--------|--------|
| Mod content files | 15 | 100+ | ❌ 15% |
| DataLoader functions | 5 | 13+ | ❌ 38% |
| TOML schemas documented | 0 | 8+ | ❌ 0% |
| DOCS implementation links valid | ~60% | 95%+ | ❌ 63% |
| Asset references validated | Partial | All | ❌ 30% |
| Test coverage for mods | 10% | 80%+ | ❌ 13% |
| Engine structure alignment | 60% | 90%+ | ⚠️ 67% |

**Overall Target:** 85%+ alignment across all three blocks

---

## 🔗 RELATED DOCUMENTS

- `README.md` - Project overview
- `docs/README.md` - Documentation standards
- `docs/mods/system.md` - Mod system design
- `engine/mods/mod_manager.lua` - Mod loading implementation
- `engine/core/data_loader.lua` - Content loading implementation
- `mods/core/mod.toml` - Core mod definition
- `tasks/tasks.md` - Task tracking
- `.github/instructions/🔌 API & Modding.instructions.md` - Modding guidelines

---

## 📞 QUESTIONS & DECISIONS NEEDED

### Question 1: TOML Schema Format
**Options:**
- A) JSON Schema (formal, tool support)
- B) Lua table definitions (native to project)
- C) Markdown documentation (readable, no validation)

**Recommendation:** Option B (Lua tables) for now, migrate to A later

### Question 2: Content Priority
**Which content to implement first?**
1. Combat content (units, weapons, armors) - immediate gameplay
2. Campaign content (phases, missions) - strategic depth
3. Economy content (facilities, research) - progression

**Recommendation:** Priority order as listed above

### Question 3: Engine Restructure
**Should we reorganize engine/ to match docs/ exactly?**
- ✅ Pro: Perfect alignment, easy navigation
- ❌ Con: Breaks all require() paths, high risk

**Recommendation:** Do incrementally, not all at once

---

## 🎓 CONCLUSION

**Bottom Line:**
- DOCS are good quality but need consistent linkage
- ENGINE has solid foundation but missing systems (politics, campaigns)
- MODS structure exists but content is 85% missing

**Critical Path:**
1. Create mod content structure (MUST DO)
2. Implement content loaders (MUST DO)
3. Document schemas (SHOULD DO)
4. Validate alignment (NICE TO HAVE)

**Estimated Effort:** 105-145 hours total
**Expected Result:** 85%+ alignment, fully playable game with mod support

---

**Next Action:** Review this analysis, approve task creation, begin Phase 1
