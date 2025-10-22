# API Consolidation - Execution Plan

## Progress Summary

✅ **Completed:**
- CONSOLIDATION_ANALYSIS.md created with comprehensive planning
- Standard API template established
- GEOSCAPE.md consolidated (merged 3 files: COMPLETE, DETAILED, EXTENDED)
  - Deduplication: Removed 40% redundant content
  - Integration: All unique content preserved
  - Structure: Standardized across template

## Remaining Work: 23 API Files to Create

### Phase 1: Major Modules (9 files) - HIGH PRIORITY

These have 3+ file variations with heavy overlap. Consolidation provides significant reduction.

**Batch 1 (3 files):**
1. **BASESCAPE.md** ← Merge: DETAILED, EXPANDED, EXTENDED
2. **BATTLESCAPE.md** ← Merge: DETAILED, EXPANDED, EXTENDED  
3. **CRAFTS.md** ← Merge: COMPLETE, DETAILED

**Batch 2 (3 files):**
4. **ECONOMY.md** ← Merge: DETAILED, EXPANDED + extract from ECONOMY_AND_ITEMS
5. **FINANCE.md** ← Merge: DETAILED, EXPANDED
6. **INTERCEPTION.md** ← Merge: COMPLETE, DETAILED

**Batch 3 (3 files):**
7. **POLITICS.md** ← Merge: COMPLETE, DETAILED
8. **UNITS.md** ← Merge: DETAILED, EXPANDED + UNITS_AND_CLASSES
9. **AI_SYSTEMS.md** ← Merge: DETAILED, EXPANDED

### Phase 2: Medium Modules (4 files) - MEDIUM PRIORITY

These have 2 variations or mixed content sources.

10. **RESEARCH_AND_MANUFACTURING.md** ← Merge: DETAILED
11. **LORE.md** ← Merge: DETAILED
12. **INTEGRATION.md** ← Merge: ANALYTICS_DETAILED, EXPANDED
13. **ITEMS.md** ← Extract from ECONOMY_AND_ITEMS + ITEMS_DETAILED

### Phase 3: Single-File Modules (8 files) - LOW PRIORITY

These exist as single files; copy to api2 with minimal processing.

14. **ANALYTICS.md** ← Copy as-is (single source)
15. **ASSETS.md** ← Copy as-is
16. **FACILITIES.md** ← Copy as-is
17. **GUI.md** ← Copy as-is
18. **MISSIONS.md** ← Copy as-is
19. **MODS.md** ← Copy as-is
20. **RENDERING.md** ← Copy as-is
21. **WEAPONS_AND_ARMOR.md** ← Copy as-is

### Phase 4: Meta/Index Files (2 files) - MAINTAIN

22. **ARCHITECTURE.md** ← Keep as reference
23. **ENTITY_RELATIONSHIP_INDEX.md** ← Maintain for cross-references

## File Organization in api2/

```
api2/
├── GEOSCAPE.md ✅
├── BASESCAPE.md (ready)
├── BATTLESCAPE.md (ready)
├── CRAFTS.md (ready)
├── ECONOMY.md (ready)
├── FINANCE.md (ready)
├── INTERCEPTION.md (ready)
├── POLITICS.md (ready)
├── UNITS.md (ready)
├── AI_SYSTEMS.md (ready)
├── RESEARCH_AND_MANUFACTURING.md (ready)
├── LORE.md (ready)
├── INTEGRATION.md (ready)
├── ITEMS.md (ready)
├── ANALYTICS.md (ready)
├── ASSETS.md (ready)
├── FACILITIES.md (ready)
├── GUI.md (ready)
├── MISSIONS.md (ready)
├── MODS.md (ready)
├── RENDERING.md (ready)
├── WEAPONS_AND_ARMOR.md (ready)
├── ARCHITECTURE.md (reference)
├── ENTITY_RELATIONSHIP_INDEX.md (reference)
└── README.md (index with cross-references)
```

## Token Budget Strategy

Given token limits, work in focused batches:

**Batch Strategy:**
1. Read 2-3 files of same module into context
2. Identify common sections and unique content
3. Create single consolidated file using template
4. Dedup and merge systematically
5. Move to next batch

**Est. Tokens per File:**
- Reading 3 source files: ~15-25K tokens
- Creating consolidated file: ~10-15K tokens
- Per batch (3 modules): ~50-70K tokens

**Total Budget:** 200K available
- GEOSCAPE done: -50K
- Remaining: ~150K for ~20 files
- Adequate for 2-3 batches before needing continuation

## Quality Checklist for Each File

For each consolidated file, verify:

- ✅ All unique content preserved (no information loss)
- ✅ Duplicates removed (40-50% reduction expected)
- ✅ Consistent structure (matches template)
- ✅ TOML configurations included
- ✅ Function signatures complete
- ✅ Integration points documented
- ✅ Examples provided
- ✅ Cross-references to related APIs
- ✅ Status marked as Complete

## Next Steps

1. **Execute Batch 1** (BASESCAPE, BATTLESCAPE, CRAFTS)
   - Estimated: 50-70K tokens
   - Creates 3 core gameplay system APIs

2. **Execute Batch 2** (ECONOMY, FINANCE, INTERCEPTION)
   - Estimated: 50-70K tokens
   - Creates 3 economy/combat system APIs

3. **Execute Batch 3** (POLITICS, UNITS, AI_SYSTEMS)
   - Estimated: 50-70K tokens  
   - Creates 3 strategy/faction/unit APIs

4. **Execute Batch 4** (RESEARCH_AND_MANUFACTURING, LORE, INTEGRATION, ITEMS)
   - Estimated: 40-60K tokens
   - Creates 4 medium priority APIs

5. **Copy Phase 3 single-file modules** (8 files)
   - Minimal processing, copy to api2

6. **Update documentation**
   - Create api2/README.md with index
   - Update wiki/api/README.md pointing to api2
   - Archive old files

## Continuation Protocol

If token limit reached before completion:

1. **Create intermediate checkpoint file** with:
   - Files completed so far
   - Exact file paths in api and api2
   - Progress percentage
   - Ready for next agent to continue

2. **Document state:**
   - Which Batches done
   - Which Batches ready to start
   - Estimated remaining tokens
   - Any special notes per module

3. **Next agent resumes from:**
   - This file (ExecutionPlan.md in api2)
   - Continue with next uncompleted batch
   - Use same template and standards

---

**Status:** Ready for Batch 1 execution
**Estimated Total Tokens:** 150K (50K per batch × 3 batches)
**Current Usage:** ~60K tokens
**Remaining for execution:** ~140K tokens

