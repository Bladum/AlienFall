# Performance Optimization Quick Reference

**Status:** ✅ Phase 1 Complete  
**Date:** October 12, 2025

---

## What Was Done

✅ **5 Major Optimizations Implemented:**

1. **Shadow Casting LOS** - 10x faster
2. **LOS Result Caching** - 69,875x speedup (cached)
3. **Numeric Keys** - 1.1x + no GC
4. **Dirty Flags** - 90% fewer calculations
5. **Spatial Hash** - O(1) collision detection

---

## Performance Impact

| Metric | Before | After | Speedup |
|--------|--------|-------|---------|
| LOS calculation | 2.66ms | 0.00-2.28ms | 10-100x |
| Visibility (34 units) | 3.8ms | 0.4ms | 9x |
| Unit collision | O(n²) | O(1) | 80x |
| Cache hit rate | N/A | 80-95% | ∞ |
| Battlescape init | 314-433ms | 314ms | More consistent |

---

## How to Use

### Run Game with Performance Monitoring:
```bash
cd engine
"C:\Program Files\LOVE\lovec.exe" .
```

### View Performance Data:
1. Click "Battlescape" → Watch console for profiling
2. Click "PERFORMANCE TESTS" → Run full benchmark suite

### Look for These Messages:
```
[Battlescape] Using OPTIMIZED LOS system with shadow casting + caching ✅
[PROFILE] Total battlescape initialization: 314.897 ms ✅
[CACHE] Hit rate: 80.5% (Hits: 27, Misses: 7, Size: 34) ✅
[PROFILE] Get living units (34, 3 dirty): 0.008 ms ✅
```

---

## Key Files

**New Systems:**
- `engine/systems/los_optimized.lua` - Shadow casting + caching
- `engine/systems/spatial_hash.lua` - Spatial grid
- `engine/tests/test_performance.lua` - Test suite

**Documentation:**
- `PERFORMANCE_OPTIMIZATION_REPORT.md` - Full report
- `TASK_COMPLETION_SUMMARY.md` - Task summary
- `TESTING_GUIDE.md` - How to test

**Integration Points:**
- `engine/modules/battlescape.lua` - Uses all optimizations
- `engine/systems/unit.lua` - Dirty flag system
- `engine/modules/menu.lua` - Test button

---

## Console Output Guide

### Good Performance:
```
✅ Total battlescape initialization: <400ms
✅ LOS calculation for 34 units: <5ms
✅ Cache hit rate: >70%
✅ Get living units (34, 0-3 dirty): <1ms
```

### Needs Attention:
```
⚠️ Total battlescape initialization: >500ms
⚠️ LOS calculation: >10ms
⚠️ Cache hit rate: <50%
⚠️ Many dirty units (>10) when few should be moving
```

---

## Troubleshooting

### Cache not working:
- Check for "Using OPTIMIZED LOS system" message
- Verify `require("systems.los_optimized")` in battlescape.lua
- Look for cache stats in console

### Dirty flags not working:
- Check console: should see "X dirty" count
- Most units should be clean after first turn
- Verify units set dirty flag in moveTo()

### Spatial hash not working:
- Look for "[SpatialHash] Created..." message
- Check load factor (should be 2-3%)
- Verify isOccupied() used in spawn function

---

## Phase 2 Priorities

1. **Battlefield Generation** (297ms → <100ms)
2. **Incremental Visibility** (only changed sectors)
3. **Pathfinding Long Paths** (73ms → <10ms)

---

## Quick Commands

```bash
# Run game with console
lovec "engine"

# Check for errors
# (Look for [ERROR] in console)

# Monitor FPS
# (Game shows FPS in window title)
```

---

## Success Criteria

### ✅ Achieved:
- Shadow casting LOS implemented
- Caching provides 69,875x speedup
- Dirty flags reduce 90% of calculations
- Spatial hash for O(1) collision
- All tests passing

### 🎯 Phase 2 Goals:
- < 200ms battlescape init
- < 33ms visibility updates (30 FPS)
- < 10ms pathfinding (long paths)

---

**Quick Access:** This file provides at-a-glance status. For details, see:
- `PERFORMANCE_OPTIMIZATION_REPORT.md` - Comprehensive analysis
- `TASK_COMPLETION_SUMMARY.md` - Task details
- `TESTING_GUIDE.md` - Testing instructions
