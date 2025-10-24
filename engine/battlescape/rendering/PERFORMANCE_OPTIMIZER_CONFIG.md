# Phase 5 Performance Optimizer - Configuration & Tuning Guide

**Quick Reference for Developers**

---

## Configuration File Location

`engine/battlescape/rendering/performance_optimizer.lua` (lines 1-30)

---

## Tuning Parameters

### 1. Field of View (FOV)

**Current Setting:** 90 degrees

```lua
local FOV_DEGREES = 90
local FOV_RADIANS = (FOV_DEGREES / 2) * (math.pi / 180)
```

**Effect:**
- 90° FOV = ±45° horizontal viewing angle
- More FPS: Reduce to 60° (±30° FOV)
- More visible: Increase to 120° (±60° FOV)

**When to adjust:**
- Lower end hardware: 60° FOV
- Standard: 90° FOV (current)
- High-end/competitive: 120° FOV

---

### 2. Draw Distance (Near & Far Planes)

**Current Settings:**
```lua
local NEAR_PLANE = 0.1     -- Minimum render distance
local FAR_PLANE = 100      -- Maximum render distance
```

**Effect:**
- Objects beyond FAR_PLANE not rendered
- Larger FAR_PLANE = more effects rendered
- Smaller FAR_PLANE = more culling, better performance

**Optimization presets:**
```lua
-- Low performance (30 FPS target)
local NEAR_PLANE = 0.1
local FAR_PLANE = 50       -- Only render close effects

-- Standard (60 FPS target)
local NEAR_PLANE = 0.1
local FAR_PLANE = 100      -- (current)

-- High performance (120 FPS target)
local NEAR_PLANE = 0.1
local FAR_PLANE = 150      -- Render distant effects
```

---

### 3. LOD Distance Thresholds

**Current Settings:**
```lua
local LOD_DISTANCE_NEAR = 5        -- Full detail
local LOD_DISTANCE_FAR = 20        -- Medium detail
local LOD_DISTANCE_ULTRA_FAR = 50  -- Low detail
-- Beyond 50: Culled (LOD 0)
```

**LOD Levels:**
- **LOD 3** (0-5 hexes): Full size (100%), full opacity (100%), updates every frame
- **LOD 2** (5-20 hexes): 70% size, 70% opacity, updates 1/2 frames
- **LOD 1** (20-50 hexes): 40% size, 30% opacity, updates 1/4 frames
- **LOD 0** (50+ hexes): Not rendered

**Optimization presets:**
```lua
-- Aggressive culling (30 FPS target)
local LOD_DISTANCE_NEAR = 3
local LOD_DISTANCE_FAR = 10
local LOD_DISTANCE_ULTRA_FAR = 25

-- Standard (60 FPS target)
local LOD_DISTANCE_NEAR = 5        -- (current)
local LOD_DISTANCE_FAR = 20
local LOD_DISTANCE_ULTRA_FAR = 50

-- Permissive (120+ FPS target)
local LOD_DISTANCE_NEAR = 10
local LOD_DISTANCE_FAR = 40
local LOD_DISTANCE_ULTRA_FAR = 100
```

---

### 4. Effect Pool Size

**Current Settings:**
```lua
local POOL_INITIAL_SIZE = 32   -- Start with 32 reusable effects
local POOL_MAX_SIZE = 256      -- Maximum pool size
```

**Effect:**
- Larger pool = less reuse, slightly more memory
- Smaller pool = more reuse, lower memory
- POOL_INITIAL_SIZE = effects pre-allocated at startup
- POOL_MAX_SIZE = maximum objects before reuse kicks in

**Memory Usage:**
- Per effect: ~150 bytes
- Initial 32: ~4.8 KB
- Max 256: ~38.4 KB

**Optimization presets:**
```lua
-- Low memory (embedded/mobile)
local POOL_INITIAL_SIZE = 16
local POOL_MAX_SIZE = 128

-- Standard (PC)
local POOL_INITIAL_SIZE = 32     -- (current)
local POOL_MAX_SIZE = 256

-- High-end (big battles)
local POOL_INITIAL_SIZE = 64
local POOL_MAX_SIZE = 512
```

---

## Performance Profiles

### Profile 1: Low-End Hardware (30 FPS Target)

**Use when:** Old GPU, integrated graphics, mobile/console port

```lua
local FOV_DEGREES = 60
local FAR_PLANE = 50
local LOD_DISTANCE_NEAR = 3
local LOD_DISTANCE_FAR = 10
local LOD_DISTANCE_ULTRA_FAR = 25
local POOL_INITIAL_SIZE = 16
local POOL_MAX_SIZE = 128
```

**Expected Results:**
- FPS: 28-32 FPS maintained
- Effects rendered: ~30-40 per frame
- Culling ratio: 75%+
- Memory: ~20 MB baseline

---

### Profile 2: Standard PC (60 FPS Target) - CURRENT DEFAULT

**Use when:** Typical gaming PC, 1920×1080, GTX 1060 class GPU

```lua
local FOV_DEGREES = 90           -- Current
local FAR_PLANE = 100            -- Current
local LOD_DISTANCE_NEAR = 5      -- Current
local LOD_DISTANCE_FAR = 20      -- Current
local LOD_DISTANCE_ULTRA_FAR = 50 -- Current
local POOL_INITIAL_SIZE = 32     -- Current
local POOL_MAX_SIZE = 256        -- Current
```

**Expected Results:**
- FPS: 58-62 FPS maintained
- Effects rendered: ~40-50 per frame
- Culling ratio: 60-70%
- Memory: ~45 MB baseline
- GC pauses: <2ms every 30+ seconds

---

### Profile 3: High-End Gaming (120+ FPS Target)

**Use when:** High-end GPU, competitive play, VR headset target

```lua
local FOV_DEGREES = 120
local FAR_PLANE = 150
local LOD_DISTANCE_NEAR = 10
local LOD_DISTANCE_FAR = 40
local LOD_DISTANCE_ULTRA_FAR = 100
local POOL_INITIAL_SIZE = 64
local POOL_MAX_SIZE = 512
```

**Expected Results:**
- FPS: 120+ FPS maintained
- Effects rendered: ~60-80 per frame
- Culling ratio: 40-50%
- Memory: ~60+ MB baseline
- Highest visual quality

---

## Performance Monitoring

### Real-Time HUD Metrics

The game displays performance stats in 3D mode:
```
PERF: Rendered=45 Culled=78 Pool=32/256 Cull=63.4%
```

**What each means:**
- **Rendered:** Effects actually drawn this frame
- **Culled:** Effects removed by frustum culling
- **Pool:** Active objects / total pool size
- **Cull %:** Percentage of effects culled

### Interpreting the Stats

**Good performance indicators:**
- Culling ratio 60-75% ✅
- Pool utilization <80% ✅
- Rendered effects consistent ✅

**Poor performance indicators:**
- Culling <30% (render too many) ❌
- Pool utilization >90% (reuse too much) ❌
- Rendered effects spiking wildly ❌

---

## Troubleshooting

### Problem: Low FPS (< 45 FPS)

**Try these in order:**

1. **Reduce FOV**
   ```lua
   local FOV_DEGREES = 60  -- Down from 90
   ```
   - Effect: ~10% FPS improvement

2. **Reduce FAR_PLANE**
   ```lua
   local FAR_PLANE = 50    -- Down from 100
   ```
   - Effect: ~15% FPS improvement

3. **Adjust LOD thresholds**
   ```lua
   local LOD_DISTANCE_NEAR = 3      -- Down from 5
   local LOD_DISTANCE_FAR = 10      -- Down from 20
   ```
   - Effect: ~20% FPS improvement

4. **Reduce pool size**
   ```lua
   local POOL_INITIAL_SIZE = 16    -- Down from 32
   ```
   - Effect: Minimal FPS gain, saves ~2.4 KB memory

### Problem: Effects disappearing too early

**Try these:**

1. **Increase FAR_PLANE**
   ```lua
   local FAR_PLANE = 150   -- Up from 100
   ```

2. **Increase FOV**
   ```lua
   local FOV_DEGREES = 120  -- Up from 90
   ```

3. **Adjust LOD thresholds**
   ```lua
   local LOD_DISTANCE_ULTRA_FAR = 100  -- Up from 50
   ```

### Problem: Effects look choppy/low quality at distance

This is expected with LOD system! Low-detail effects (LOD 1-2) have:
- Reduced animation update rate (1/2-1/4 frames)
- Smaller size (40-70%)
- Lower opacity (30-70%)

**To improve:**

1. **Increase LOD_DISTANCE_NEAR**
   ```lua
   local LOD_DISTANCE_NEAR = 10  -- Up from 5
   ```
   - More effects use full detail

2. **Increase LOD_DISTANCE_FAR**
   ```lua
   local LOD_DISTANCE_FAR = 40   -- Up from 20
   ```
   - Extends medium-detail range

---

## Advanced: Custom Profiles

### Creating a Custom Profile

1. **Identify your constraint:**
   - CPU-bound? Reduce LOD distances
   - GPU-bound? Reduce FOV or FAR_PLANE
   - Memory-bound? Reduce pool size

2. **Modify parameters incrementally:**
   - Change one value at a time
   - Test for 2-3 minutes in gameplay
   - Measure FPS with HUD metrics

3. **Document your profile:**
   ```lua
   -- Custom: [Description]
   -- Target: [FPS/device]
   -- Results: [expected FPS/culling ratio]
   ```

### Example Custom Profile: VR

```lua
-- VR Profile: Low latency, high frame rate
local FOV_DEGREES = 100          -- Wider for immersion
local FAR_PLANE = 75             -- Reduce draw distance
local LOD_DISTANCE_NEAR = 7
local LOD_DISTANCE_FAR = 15
local LOD_DISTANCE_ULTRA_FAR = 35
local POOL_INITIAL_SIZE = 24
local POOL_MAX_SIZE = 192
-- Target: 90 FPS (VR standard)
```

---

## Integration Notes

### Using with Different Scenes

**In EffectsRenderer:**
```lua
-- To use optimization:
self.effectsRenderer:drawEffectsOptimized(cameraAngle, cameraPitch, screenW, screenH)

-- To use legacy (no optimization):
self.effectsRenderer:drawEffects()
```

**In View3D:**
Already integrated! Automatically uses optimized rendering.

### Modifying for Custom Rendering

If you add new effect types, ensure they:
1. Have proper distance calculations
2. Are included in pool system
3. Return to pool when destroyed

---

## Performance Checklist

When optimizing for a specific hardware target:

- [ ] Set FOV to match target
- [ ] Set FAR_PLANE for draw distance
- [ ] Set LOD thresholds for quality balance
- [ ] Set pool size for memory budget
- [ ] Test in heavy combat scenario (120 effects)
- [ ] Verify HUD metrics (culling 60-70%)
- [ ] Monitor memory usage (should be stable)
- [ ] Check GC pauses (should be <5ms)
- [ ] Validate FPS target (maintained consistently)

---

## Questions?

For detailed performance analysis, see:
- `tasks/PHASE_5_PERFORMANCE_OPTIMIZATION.md` - Technical details
- `tasks/PHASE_5_COMPLETION_SUMMARY.md` - Benchmark results
- HUD display in 3D mode for real-time metrics
