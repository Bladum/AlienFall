# Next Steps - Quick Reference

**Current Phase**: Phase 2, Session 2 Complete  
**Current Alignment**: 89.2%  
**Target Alignment**: 95%+  

---

## Immediate Actions (Next 30-60 minutes)

### 1. Continue Task 1: Verify Armor System

**File**: `mods/core/rules/items/armours.toml`

**What to Check**:
- [ ] Armor protection values (should increase with tech)
- [ ] Weight/speed penalties (should be realistic)
- [ ] Tech gate progression (early/mid/late game)
- [ ] Cost scaling (should match weapon costs)
- [ ] Special bonuses/resistances (if any)

**Expected Result**: All armor perfectly balanced ✅

**Time**: 10-15 minutes

---

### 2. Continue Task 1: Quick Data Spot-checks

**Files to Sample**:
- `mods/core/rules/items/ammo.toml` - Ammunition costs
- `mods/core/rules/items/equipment.toml` - Grenade/item values
- `mods/core/rules/facilities/base_facilities.toml` - Building costs
- `mods/core/technology/catalog.toml` - Research progression

**Quick Check**:
- [ ] Prices are proportional to power
- [ ] Tech trees are properly gated
- [ ] Values don't have obvious outliers
- [ ] Progression makes sense

**Time**: 15-20 minutes

---

## Then: Begin Testing Phase (Next 1-2 hours)

### Use This File

**Document**: `docs/INTEGRATION_TESTING_CHECKLIST.md`

### Test Sequence 1: Startup & Menu (5 min)
- [ ] Launch game: `lovec "engine"`
- [ ] Monitor console for errors
- [ ] Check window opens (960×720)
- [ ] Verify menu displays correctly
- [ ] Record any issues in results doc

### Test Sequence 2: Geoscape (10 min)
- [ ] Click "GEOSCAPE" button
- [ ] Verify strategic map displays
- [ ] Check resource display
- [ ] Verify mission markers present
- [ ] Record findings

### Test Sequence 3: Battlescape Entry (20 min)
- [ ] Select a mission
- [ ] Click "Start Mission"
- [ ] Monitor map generation
- [ ] Verify units spawn
- [ ] Check combat UI
- [ ] Record in results document

---

## Recording Results

### Use This File
**Document**: `docs/PHASE_2_TASK_5_INTEGRATION_TESTING_RESULTS.md`

### For Each Test
1. Record console output in provided sections
2. Mark each phase as PASS or FAIL
3. Note any errors found
4. Document performance metrics

---

## Key Files Reference

| Task | File | Purpose |
|------|------|---------|
| Task 1 Continue | Data files in `mods/core/` | Verify balance |
| Task 5 Testing | `INTEGRATION_TESTING_CHECKLIST.md` | Step-by-step procedures |
| Task 5 Results | `INTEGRATION_TESTING_RESULTS.md` | Record findings |
| Task 5 Framework | `PHASE_2_TASK_5_INTEGRATION_TESTING.md` | Expected behavior reference |

---

## Performance Targets to Monitor

| Metric | Target | Check |
|--------|--------|-------|
| Startup | < 3s | ✓ |
| Menu FPS | 60 FPS | ✓ |
| Map Gen | < 2s | ✓ |
| Combat FPS | ≥ 30 | ✓ |
| Save Time | < 1s | ✓ |
| Load Time | < 1s | ✓ |

---

## Console Error Checklist

Monitor for these ERROR patterns:
- [ ] `[ERROR]` - Any error messages
- [ ] `nil` reference errors
- [ ] State machine violations
- [ ] Missing asset/content errors
- [ ] Infinite loops/hangs

---

## Success Definition

### Task 1 (Data Verification)
✅ Verify 9 remaining systems are balanced  
✅ No values are obvious outliers  
✅ Tech progression makes sense

### Task 5 (Integration Testing)
✅ Full game loop completes without crash  
✅ No console ERROR messages  
✅ All state transitions work  
✅ Save/Load preserves state  
✅ Performance targets met

---

## Expected Outcome

After completing Tasks 1 & 5:
- **Alignment**: 89.2% → 92-94%
- **Remaining**: 5.8% gap to 95%+
- **Next**: Tasks 6-8 (Error Recovery, Balance, Dev Guide)
- **Final Session**: Reach 95%+ target

---

## Time Breakdown

- Task 1 Continuation: 30-45 minutes ✓ Quick data checks
- Task 5 Testing Seq 1-3: 40-50 minutes → Game loop verification
- Task 5 Testing Seq 4-8: 60-80 minutes → Full testing cycle
- **Total**: ~2.5 hours → 92-94% alignment

---

**Ready?** Start with Task 1 data checks, then begin Test Sequence 1! 🚀

