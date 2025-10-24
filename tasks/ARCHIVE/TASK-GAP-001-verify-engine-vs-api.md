# TASK-GAP-001: Verify Engine vs API Documentation Alignment

**Status:** TODO
**Priority:** HIGH
**Created:** October 23, 2025
**Estimated Time:** 8-10 hours
**Task Type:** Verification + Documentation

---

## Overview

Compare engine implementation against API documentation to identify:
1. Undocumented engine features
2. Documented-but-unimplemented features
3. Discrepancies in function signatures
4. Missing parameter documentation
5. Examples that don't match code

---

## Scope: TWO SOURCES ONLY

**Source A:** `api/` folder (21 API documentation files)
**Source B:** `engine/` folder (actual implementation code)

**Systems to Compare:**
- Geoscape (API vs engine/geoscape/)
- Basescape (API vs engine/basescape/)
- Battlescape (API vs engine/battlescape/)
- Crafts (API vs engine/content/crafts/)
- Politics (API vs engine/politics/)
- Economy (API vs engine/economy/)
- Units (API vs engine/content/units/)
- Items (API vs engine/content/items/)
- AI Systems (API vs engine/ai/)
- GUI (API vs engine/gui/)
- Interception (API vs engine/interception/)
- Rendering (API vs engine/*/rendering/)
- Assets (API vs engine/assets/)
- Lore (API vs engine/lore/)
- Analytics (API vs engine/analytics/)

---

## Detailed Verification Plan

### Phase 1: Function Mapping (2-3 hours)
For each system:
1. Extract all function signatures from API file
2. Find corresponding implementations in engine
3. Document:
   - ✅ Found and matches
   - ⚠️ Found but signature differs
   - ❌ Not found (documented but unimplemented)
4. Create mapping spreadsheet

### Phase 2: Parameter Verification (2-3 hours)
For each function found:
1. Check parameter names match
2. Check parameter types match
3. Check return types documented vs actual
4. Note discrepancies in documentation

### Phase 3: Example Validation (2-3 hours)
For each code example in API:
1. Extract example code
2. Verify it would work with current engine
3. Note if examples are outdated
4. Check if all code paths in examples exist

### Phase 4: Missing Documentation (1-2 hours)
1. Find implemented functions NOT in API
2. Identify what should be documented
3. Note private vs public functions
4. Flag which need API additions

---

## Deliverables

### Documentation Updates Needed
- [ ] API files requiring new function documentation
- [ ] API files with outdated examples
- [ ] API files with incorrect signatures
- [ ] New functions to add to API

### Report: `docs/API_ENGINE_ALIGNMENT_VERIFICATION.md`
Should contain:
- Systems fully aligned ✅
- Systems with minor discrepancies ⚠️
- Systems needing work ❌
- Priority list for corrections

### Actionable Tasks
For each gap found:
- Create subtask to fix either:
  - Update API documentation, OR
  - Implement missing functionality

---

## Success Criteria

✅ All 15 systems compared
✅ All functions mapped
✅ Discrepancies documented
✅ Priorities identified
✅ Report created

---

## Related Files

**Compare These:**
- API Source: `api/GEOSCAPE.md` ↔ Engine: `engine/geoscape/`
- API Source: `api/BASESCAPE.md` ↔ Engine: `engine/basescape/`
- API Source: `api/BATTLESCAPE.md` ↔ Engine: `engine/battlescape/`
- (... 12 more pairs)

**Reference Report:** `design/gaps/API_VS_ENGINE_ALIGNMENT.md` (Use as checklist)

---

**Task ID:** TASK-GAP-001
**Assignee:** [Developer]
**Due:** October 30, 2025
**Complexity:** Medium (systematic verification)
