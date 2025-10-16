# 📋 Docs Improvement Quick Reference

**Generated:** October 15, 2025  
**Full Analysis:** See `DOCS_ANALYSIS_AND_RECOMMENDATIONS.md`

---

## 🔴 CRITICAL ISSUES (Fix First)

### 1. Code Embedded in Design Docs ❌

```
docs/systems/TILESET_SYSTEM.md          (825 lines, 12 TOML + 7 Lua blocks)
docs/systems/FIRE_SMOKE_MECHANICS.md    (334 lines, 6 Lua blocks)
docs/systems/RESOLUTION_SYSTEM_ANALYSIS (656 lines, 7 Lua blocks)
docs/testing/TESTING.md                 (Multiple Lua blocks)
```
**Fix:** Extract code → Create `docs/technical/` folder → Move code there

---

### 2. Duplicate Folders

```
❌ docs/balance/ (GAME_NUMBERS.md)
❌ docs/balancing/ (framework.md)        ← CONSOLIDATE: Rename to balance/testing/

❌ docs/economy/research.md + research/folder
❌ docs/economy/manufacturing.md + production/folder    ← CLARIFY: Subfolder purposes
❌ docs/economy/marketplace.md + marketplace/folder
❌ docs/economy/finance/ + funding.md               ← RENAME: clarity
```
**Fix:** Merge/rename folders, clarify subfolder purposes, add README

---

### 3. Unclear Folder Purposes

```
docs/ai/                 ← 4 subfolders, no README
docs/geoscape/          ← 10+ mixed files/folders
docs/battlescape/       ← 10+ mixed files/folders
docs/content/           ← Should items be here or elsewhere?
docs/politics/          ← 5 subfolders with no explanation
```
**Fix:** Add README to all folders explaining structure

---

## 🟡 HIGH PRIORITY (Do Next)

### Standardize File Naming

```
✅ Consistent:           docs/economy/research.md (lowercase)
❌ Inconsistent:         docs/OVERVIEW.md (UPPERCASE)
❌ Inconsistent:         docs/battlescape/COMBAT_SYSTEMS_COMPLETE.md
❌ Inconsistent:         docs/systems/TILESET_SYSTEM.md
```

**Standard:**
- Root navigation: UPPERCASE (README.md, OVERVIEW.md, QUICK_NAVIGATION.md)
- Design docs: lowercase (research.md, combat.md)
- Technical/Analysis: UPPERCASE (SYSTEM_NAME.md) - in `docs/technical/`

---

### Consolidate Navigation Files

```
Currently:
├── README.md (80 lines) - Explains what docs/ is
├── OVERVIEW.md (186 lines) - Game overview
├── QUICK_NAVIGATION.md (355 lines) - Index of all docs
└── API.md (1,811 lines) - Technical API

Problem: Overlap, unclear which to read first
Solution: Streamline to 3-4 files with clear purposes
```

---

## 🟢 MEDIUM PRIORITY (Nice to Have)

### Create `docs/technical/` Folder

Move here:
```
docs/technical/TILESET_SYSTEM.md
docs/technical/FIRE_SMOKE_MECHANICS.md
docs/technical/RESOLUTION_SYSTEM_ANALYSIS.md
docs/technical/HEX_RENDERING_GUIDE.md
docs/technical/COMBAT_SYSTEMS_COMPLETE.md
docs/technical/3D_BATTLESCAPE_ARCHITECTURE.md
docs/technical/GEOSCAPE_STRATEGIC_LAYER_DIAGRAMS.md
docs/technical/GEOSCAPE_STRATEGIC_LAYER_IMPLEMENTATION_PLAN.md
```

**Benefit:** Separates large technical analysis from design docs

---

### Populate Empty Folders

```
❌ docs/analytics/ - Empty?
❌ docs/scenes/ - Empty?
❌ docs/tutorial/ - Empty?
❌ docs/utils/ - Empty?
❌ docs/widgets/ - Empty?

Decision: Add design docs or remove folder?
```

---

## 📊 STATISTICS

| Metric | Current | Target |
|--------|---------|--------|
| Total .md files | ~55 | ~55 |
| Files with code/TOML | 25+ | 2-3 |
| Empty folders | 5+ | 0 |
| Duplicate folder pairs | 3 | 0 |
| Folders without README | 15+ | 0 |
| Navigation files | 4 | 3 |

---

## 🔧 IMPLEMENTATION PHASES

### Phase 1: Code Hygiene (2-3 hrs) - HIGHEST IMPACT
- [ ] Extract code from TILESET_SYSTEM.md
- [ ] Extract code from FIRE_SMOKE_MECHANICS.md
- [ ] Extract code from RESOLUTION_SYSTEM_ANALYSIS.md
- [ ] Remove code from TESTING.md
- [ ] Create docs/technical/ folder with extracted code

### Phase 2: Folder Reorganization (3-4 hrs)
- [ ] Rename docs/balancing/ → docs/balance/testing/
- [ ] Clarify docs/economy/ subfolders
- [ ] Add README to all folders
- [ ] Update cross-references

### Phase 3: File Naming (2-3 hrs)
- [ ] Create naming convention document
- [ ] Rename files to follow convention
- [ ] Update all links

### Phase 4: Final Polish (1-2 hrs)
- [ ] Consolidate navigation files
- [ ] Populate or remove empty folders
- [ ] Validate all cross-references

**Total: 8-12 hours**

---

## ✅ BEFORE/AFTER COMPARISON

### Before
```
docs/
├── 4 navigation files with overlap
├── balance/ + balancing/ (duplicate)
├── economy/ (confusing subfolders)
├── systems/ (3 large technical files)
├── 5+ empty folders
├── 15+ folders without README
└── Code embedded in design docs (❌)
```

### After
```
docs/
├── 3 streamlined navigation files
├── balance/ (consolidated with testing/)
├── economy/ (clear structure with README)
├── technical/ (large analysis files)
├── Content folders populated
├── All folders have README
└── No code in design docs (✅)
```

---

## 🎯 QUICK ACTION CHECKLIST

### High-Impact Quick Wins
- [ ] Create `docs/technical/` folder (5 min)
- [ ] Move TILESET_SYSTEM.md, FIRE_SMOKE_MECHANICS.md, RESOLUTION_SYSTEM_ANALYSIS.md (15 min)
- [ ] Remove code from files, replace with descriptions (30-60 min)
- [ ] Rename `docs/balancing/` → `docs/balance/testing/` (10 min)

### Best Bang for Buck
1. **Remove code from design docs** (High effort, HIGH impact)
2. **Create `docs/technical/` folder** (Low effort, HIGH impact)
3. **Add README to all folders** (Medium effort, HIGH impact)

---

## 📖 FULL DOCUMENTATION

For detailed analysis, recommendations, and specific file-by-file changes:

**→ Read:** `DOCS_ANALYSIS_AND_RECOMMENDATIONS.md`

This quick reference covers:
✅ Key issues identified
✅ Priority recommendations  
✅ Implementation phases
❌ Detailed analysis (see full doc)

---

**Last Updated:** October 15, 2025  
**Status:** ANALYSIS COMPLETE - Ready for Implementation  
**Next Step:** Review full analysis → Create task → Begin Phase 1
