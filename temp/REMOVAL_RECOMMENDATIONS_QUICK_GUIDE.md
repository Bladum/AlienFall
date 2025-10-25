# Quick Removal Recommendations Summary

## 🎯 Immediate Actions (Safe to Execute Today)

### DELETE - 100% SAFE
```
❌ tools/spritesheet_generator/cfg/
   Reason: Completely empty (0 files, 0 subdirs)
   Risk: None
   Time: 1 minute
```

### OPTIONAL DELETE
```
❌ design/gaps/
   Reason: Historical cleanup log (task complete Oct 23)
   Risk: Low (keeps git history)
   Time: 1 minute
```

---

## 🚀 Phase 2: Archive Placeholders (Safe, Cleanup Clutter)

```
📦 engine/network/
   Type: Future feature placeholder
   Reason: No multiplayer code, README only
   Status: Phase 5+ planned
   Risk: Low
   Action: Mark [NOT YET IMPLEMENTED] or move to _FUTURE/

📦 engine/portal/
   Type: System placeholder
   Reason: No implementation (should have portal_system.lua per README)
   Status: Design documented, code missing
   Risk: Medium (check dependencies first)
   Action: Mark [PLACEHOLDER] or implement

📦 engine/lore/events/
   Type: Stub folder
   Reason: README only, duplicate with engine/content/events/
   Risk: Low
   Action: Consolidate or mark
```

---

## 📋 Phase 3: Documentation (KEPT AS-IS)

### Leave `/docs/` Folder Intact
```
docs/ folder kept as-is for general documentation
├─ docs/ai/
├─ docs/content/
├─ docs/lore/
└─ docs/testing/

No consolidation needed - keeping separate from api/
```

---

## 🧪 Phase 4: Test Framework Merge (Needs Care)

### Consolidate Into Single Location
```
tests/framework/           # KEEP (consolidation point)
  ├── ui_testing/         # MERGE into tests/framework/
  └── test_framework.lua  # CONSOLIDATE

tests/frameworks/          # MERGE into tests/framework/
```

---

## 📚 Phase 5: Documentation Duplication (Requires Strategy)

### Three-Tier Documentation System (PROPOSED)

| Tier | Purpose | Location | Example |
|------|---------|----------|---------|
| **DESIGN** | What we want to build | `design/mechanics/` | `design/mechanics/units.md` |
| **API** | System contracts & interfaces | `api/` | `api/UNITS.md` |
| **IMPLEMENTATION** | Actual built content | `mods/core/rules/units/` | `mods/core/rules/units/units.toml` |

**Current State:** Many duplicate docs in all three tiers
**Target State:** Single file per system per tier, cross-referenced

### Audit These Overlaps
```
Units:
  - design/mechanics/Units.md
  - api/UNITS.md
  - mods/core/rules/units/ (TOML files)

Crafts:
  - design/mechanics/Crafts.md
  - api/CRAFTS.md
  - mods/core/rules/crafts/

(Repeat for all major systems)
```

---

## 📁 Phase 6: Placeholder Folder Audit (FYI)

### Folders with ONLY README (No Implementation)
```
engine/ai/diplomacy/           - Doc says implementation exists, but code absent
engine/assets/fonts/           - Awaiting font assets
engine/assets/sounds/          - Awaiting sound assets
engine/basescape/base/         - Should have base.lua per README
engine/battlescape/ai/         - Combat AI not implemented
engine/geoscape/portal/        - Portal system not implemented
engine/politics/government/    - Government system not implemented

(And ~10 more - see full analysis)
```

### Recommendation
For each, add to README.md:
```markdown
**Status:** [NOT YET IMPLEMENTED] or [PLACEHOLDER] or [AWAITING CONTENT]
**Expected in:** [Phase number or milestone]
```

---

## 🔢 By The Numbers

| Metric | Count | Status |
|--------|-------|--------|
| Total directories | 249 | 📊 |
| Completely empty | 1 | ✅ Delete |
| README-only | 40+ | ⚠️ Mark or archive |
| Placeholder/future | 15+ | 📦 Archive? |
| Duplicate docs | 20+ | 🔀 Consolidate |
| Asset staging | 15+ | ⏳ Normal (awaiting) |
| Legitimate active code | 60+ | ✅ Keep |

---

## 💡 Strategic Cleanup Path

**If you have 1 hour:**
1. Delete 1 empty folder
2. Archive 3 placeholder folders
3. Mark 15 README-only folders with status
4. (Skip doc consolidation - keeping /docs/ as-is)

**If you have 1 day:**
1. Complete all above
2. Consolidate test frameworks
3. Clarify mods/ purpose
4. Create governance doc for future folders

**If you have 1 week:**
1. Do everything above
2. Clarify docs/ organization and purpose
3. Archive all restructuring artifacts
4. Establish governance rules for new folders

---

## ⚡ Before Deleting Anything

### Checklist
- [ ] Run grep search for any imports of the folder
- [ ] Check git history for recent changes
- [ ] Verify no CI/CD references the path
- [ ] Confirm with team if shared project
- [ ] Back up to git branch first
- [ ] Test project still runs after deletion

---

## Full Analysis Available

See: `temp/WORKSPACE_STRUCTURE_ANALYSIS.md` for complete detailed analysis including:
- Every minimal folder listed with purpose
- Category breakdown
- Risk assessment
- Consolidation options
- Maintenance recommendations
