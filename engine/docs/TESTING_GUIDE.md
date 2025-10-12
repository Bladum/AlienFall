# Performance Testing Guide

## Current Status

✅ **Optimizations Implemented:**
- Shadow casting LOS (replaces raycasting)
- LOS result caching with TTL
- Numeric keys (y*WIDTH+x) instead of string.format
- Comprehensive profiling instrumentation
- Cache statistics tracking

🔄 **Testing Phase:**
- Game is running with console output enabled
- Need to navigate to Battlescape to see profiling results

## How to Test

### 1. Run the Game
```bash
cd engine
"C:\Program Files\LOVE\lovec.exe" .
```

The console window will show initialization messages.

### 2. Navigate to Battlescape
- Click the **"Battlescape"** button in the main menu
- Watch the console output for profiling messages

### 3. What to Look For in Console

#### Initialization Profiling:
```
[PROFILE] Initialize Core Systems: X.XXX ms
[PROFILE] Generate battlefield: X.XXX ms
[PROFILE] Create teams: X.XXX ms
[PROFILE] Spawn units: X.XXX ms
[PROFILE] Initial visibility calc: X.XXX ms
[PROFILE] Setup UI: X.XXX ms
[PROFILE] Total battlescape init: X.XXX ms
```

#### LOS System Confirmation:
```
Using OPTIMIZED LOS system with shadow casting + caching
```

#### Visibility Update Profiling:
```
[PROFILE] Calculate visibility for unit: X.XXX ms
[PROFILE] Update team visibility: X.XXX ms
[CACHE] Hit rate: XX.X% (Hits: XXX, Misses: XXX, Size: XXX)
[PROFILE] Total updateVisibility: X.XXX ms
```

### 4. Performance Test Suite

Click the **"PERFORMANCE TESTS"** button in the main menu to run comprehensive benchmarks:

**Test Categories:**
1. **LOS Calculation** - Shadow casting vs raycasting comparison
2. **Pathfinding** - A* algorithm performance at various distances
3. **Visibility Update** - Full team visibility with 50-500 units
4. **Battlefield Generation** - Map creation at different sizes
5. **Coordinate Conversion** - Hex math performance
6. **Memory Allocation** - GC impact measurement
7. **Cache Performance** - Hit rate and eviction testing
8. **Full Battlescape Init** - Complete initialization benchmark

### 5. Expected Improvements

**Before Optimization (Baseline):**
- LOS calculation: ~100-200ms per unit (raycasting)
- Visibility update: 200-500ms total
- Cache hit rate: N/A (no caching)
- Battlescape init: 2000-3000ms

**After Optimization (Target):**
- LOS calculation: ~10-20ms per unit (shadow casting)
- Visibility update: 50-100ms total (with caching)
- Cache hit rate: 80-95% after warmup
- Battlescape init: 500-1000ms

**Expected Speedups:**
- LOS: 10x faster
- Visibility: 4-8x faster
- Overall init: 2-3x faster

## Debugging Tips

### If No Profiling Output:
1. Check that you're running with `lovec.exe` (not `love.exe`)
2. Verify `conf.lua` has `t.console = true`
3. Look for error messages in console

### If Game Crashes:
1. Check console for Lua error stack trace
2. Common issues:
   - Missing `love` global in los_optimized.lua (should use conditional)
   - Nil battlefield reference
   - Invalid tile coordinates

### If Performance Seems Slow:
1. Check cache hit rate - should be >80% after first visibility update
2. Verify "Using OPTIMIZED LOS system" message appears
3. Check that numeric keys are being used (no string.format calls)

## Next Steps After Testing

1. **Record Baseline Metrics** - Note all timing values from first run
2. **Test Optimized System** - Navigate to Battlescape, record new timings
3. **Run Performance Tests** - Execute full benchmark suite
4. **Compare Results** - Calculate speedup factors
5. **Generate Report** - Create before/after comparison document

## Remaining Optimizations (Not Yet Implemented)

- **Dirty Flag System** - Skip visibility for stationary units
- **Spatial Hash Grid** - Optimize unit spawn collision detection

These will be implemented in Phase 2 after validating Phase 1 improvements.
