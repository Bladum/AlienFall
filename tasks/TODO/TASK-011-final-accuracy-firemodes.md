# Task: Final Accuracy and Fire Modes System

**Status:** TODO  
**Priority:** High  
**Created:** October 13, 2025  
**Completed:** N/A  
**Assigned To:** AI Agent

---

## Overview

Implement the complete accuracy calculation formula that combines all modifiers: unit accuracy, weapon accuracy, fire mode, range, cover, and visibility. Accuracy is always clamped to 5-95% range and snapped to 5% increments. Supports fire modes: snap shot, aimed shot, and auto fire.

---

## Purpose

Create the final accuracy system that combines all previous systems into one cohesive calculation. Provides different fire modes for tactical variety (quick vs accurate shots). Ensures accuracy is always reasonable and predictable.

---

## Requirements

### Functional Requirements
- [ ] Final accuracy formula combines:
  - Unit base accuracy (aim stat)
  - Weapon base accuracy
  - Fire mode modifier (snap/aim/auto)
  - Range multiplier (from TASK-009)
  - Cover multiplier (from TASK-010)
  - Visibility multiplier (from TASK-010)
- [ ] Final accuracy always clamped to 5-95%
- [ ] Final accuracy snapped to 5% increments (5%, 10%, 15%, ...)
- [ ] Fire modes:
  - Snap shot: 1 AP, 100% accuracy modifier, 1 shot
  - Aimed shot: 2 AP, 150% accuracy modifier, 1 shot
  - Auto fire: 2 AP, 75% accuracy modifier, 3 shots
- [ ] Each fire mode has own AP and EP costs
- [ ] UI displays all modifiers and final accuracy

### Technical Requirements
- [ ] Create unified accuracy calculation function
- [ ] Apply all modifiers in correct order
- [ ] Implement clamping to 5-95% range
- [ ] Implement snapping to 5% increments
- [ ] Fire mode system with different stats
- [ ] Validate weapon supports selected fire mode
- [ ] Efficient calculation (cache intermediate results)

### Acceptance Criteria
- [ ] Accuracy calculation uses all modifiers correctly
- [ ] Final accuracy never below 5% or above 95%
- [ ] Accuracy always multiple of 5% (5, 10, 15, ..., 95)
- [ ] Fire modes have correct AP costs and modifiers
- [ ] UI shows breakdown of all accuracy modifiers
- [ ] Different weapons support different fire modes
- [ ] Console logs complete accuracy calculation
- [ ] High accuracy weapons can overcome penalties

---

## Plan

### Step 1: Fire Mode System
**Description:** Implement fire mode definitions and selection  
**Files to modify/create:**
- `engine/data/fire_modes.lua` - Fire mode definitions
- `engine/battle/systems/fire_mode_system.lua` - Fire mode logic
- `engine/systems/weapon_system.lua` - Add fire mode support to weapons

**Estimated time:** 3 hours

### Step 2: Unified Accuracy Calculation
**Description:** Create master accuracy calculation function  
**Files to modify/create:**
- `engine/battle/systems/accuracy_system.lua` - Master calculation function
- Integrate with existing range, cover, visibility systems

**Estimated time:** 4 hours

### Step 3: Clamping and Snapping
**Description:** Implement accuracy clamping and snapping logic  
**Files to modify/create:**
- `engine/battle/systems/accuracy_system.lua` - Add clamp and snap functions

**Estimated time:** 1 hour

### Step 4: UI Accuracy Breakdown
**Description:** Display detailed accuracy modifiers in UI  
**Files to modify/create:**
- `engine/modules/battlescape.lua` - Show accuracy breakdown
- `engine/widgets/accuracy_tooltip.lua` - Detailed tooltip

**Estimated time:** 3 hours

### Step 5: Fire Mode Selection UI
**Description:** Allow player to select fire mode  
**Files to modify/create:**
- `engine/modules/battlescape.lua` - Fire mode selector
- `engine/widgets/fire_mode_button.lua` - UI button for modes

**Estimated time:** 2 hours

### Step 6: Testing
**Description:** Verify complete accuracy system  
**Test cases:**
- All modifiers applied correctly
- Clamping and snapping work
- Fire modes have correct effects
- UI shows accurate information
- Edge cases handled

**Estimated time:** 3 hours

---

## Implementation Details

### Architecture
Extend AccuracySystem to combine all modifiers. Create FireModeSystem for mode management. Integrate with shooting system for final accuracy in combat.

### Key Components

**FireMode Definition:**
```lua
-- engine/data/fire_modes.lua
return {
    snap = {
        name = "Snap Shot",
        ap_cost = 1,
        ep_cost = 1,
        accuracy_modifier = 1.0,  -- 100%
        shots = 1,
        description = "Quick shot with normal accuracy"
    },
    aim = {
        name = "Aimed Shot",
        ap_cost = 2,
        ep_cost = 1,
        accuracy_modifier = 1.5,  -- 150%
        shots = 1,
        description = "Careful aim for improved accuracy"
    },
    auto = {
        name = "Auto Fire",
        ap_cost = 2,
        ep_cost = 3,
        accuracy_modifier = 0.75, -- 75%
        shots = 3,
        description = "Spray of bullets with reduced accuracy per shot"
    }
}
```

**Master Accuracy Calculation:**
```lua
--- Calculate final to-hit percentage
-- @param shooter table Unit entity doing the shooting
-- @param target table Unit entity being targeted
-- @param weapon table Weapon being used
-- @param fireMode string Fire mode ("snap", "aim", "auto")
-- @param battlefield table Battlefield for LOS/cover
-- @return number Final accuracy (5-95, multiple of 5)
-- @return table Breakdown of all modifiers for UI
function AccuracySystem.calculateFinalAccuracy(shooter, target, weapon, fireMode, battlefield)
    -- 1. Get base accuracies
    local unitAccuracy = shooter.stats.accuracy or 100
    local weaponAccuracy = weapon.base_accuracy or 60
    
    -- 2. Get fire mode modifier
    local fireModeData = FireModes[fireMode]
    local fireModeModifier = fireModeData.accuracy_modifier or 1.0
    
    -- 3. Calculate distance and range modifier
    local distance = RangeSystem.calculateDistance(shooter.pos, target.pos)
    local rangeModifier = AccuracySystem.getRangeMultiplier(distance, weapon.range)
    
    -- 4. Calculate cover modifiers
    local losResult = LOSSystem.checkLOS(shooter.pos, target.pos, battlefield)
    local obstacleCover, effectCover, blocked = CoverSystem.calculateCover(losResult)
    local coverModifier = AccuracySystem.getCoverMultiplier(obstacleCover, effectCover)
    
    -- 5. Calculate visibility modifier
    local visible = losResult.visible
    local visibilityModifier = AccuracySystem.getVisibilityMultiplier(visible)
    
    -- 6. Combine all modifiers
    -- Formula: unitAcc * weaponAcc * fireMode * (1 - obstacles/20) * (1 - effects/20) * visibility
    local baseAccuracy = (unitAccuracy / 100) * weaponAccuracy
    local finalAccuracy = baseAccuracy 
                         * fireModeModifier 
                         * rangeModifier 
                         * coverModifier 
                         * visibilityModifier
    
    -- 7. Clamp to 5-95% range
    finalAccuracy = math.max(5, math.min(95, finalAccuracy))
    
    -- 8. Snap to 5% increments
    finalAccuracy = math.floor(finalAccuracy / 5 + 0.5) * 5
    
    -- 9. Create breakdown for UI
    local breakdown = {
        unit_accuracy = unitAccuracy,
        weapon_accuracy = weaponAccuracy,
        fire_mode = fireMode,
        fire_mode_modifier = fireModeModifier,
        distance = distance,
        range_modifier = rangeModifier,
        obstacle_cover = obstacleCover,
        effect_cover = effectCover,
        cover_modifier = coverModifier,
        visible = visible,
        visibility_modifier = visibilityModifier,
        final_accuracy = finalAccuracy,
        blocked = blocked
    }
    
    return finalAccuracy, breakdown
end
```

**Clamping and Snapping:**
```lua
--- Clamp accuracy to valid range
-- @param accuracy number Raw accuracy percentage
-- @return number Clamped accuracy (5-95)
function AccuracySystem.clampAccuracy(accuracy)
    return math.max(5, math.min(95, accuracy))
end

--- Snap accuracy to 5% increment
-- @param accuracy number Accuracy percentage
-- @return number Snapped accuracy (multiple of 5)
function AccuracySystem.snapAccuracy(accuracy)
    return math.floor(accuracy / 5 + 0.5) * 5
end

--- Apply both clamp and snap
-- @param accuracy number Raw accuracy
-- @return number Final accuracy (5-95, multiple of 5)
function AccuracySystem.normalizeAccuracy(accuracy)
    local clamped = AccuracySystem.clampAccuracy(accuracy)
    return AccuracySystem.snapAccuracy(clamped)
end
```

### Accuracy Formula

**Complete Formula:**
```
base = (unit_accuracy / 100) * weapon_accuracy

final = base 
      * fire_mode_modifier 
      * range_modifier 
      * (1 - obstacle_cover / 20) 
      * (1 - effect_cover / 20) 
      * visibility_modifier

final = clamp(final, 5, 95)
final = snap(final, 5)
```

### Example Calculation

**Scenario:**
- Unit accuracy: 80%
- Weapon: Pistol (base 60%, range 15)
- Fire mode: Aimed shot (1.5x)
- Distance: 12 tiles (80% of max range)
- Cover: 3 obstacle, 1 effect
- Visible: Yes

**Calculation:**
1. Base: (80/100) × 60 = 48%
2. Fire mode: 48 × 1.5 = 72%
3. Range (80%): 72 × 0.9 = 64.8%
4. Obstacle cover: 64.8 × (1 - 3/20) = 64.8 × 0.85 = 55.08%
5. Effect cover: 55.08 × (1 - 1/20) = 55.08 × 0.95 = 52.33%
6. Visibility: 52.33 × 1.0 = 52.33%
7. Clamp: 52.33% (already in 5-95 range)
8. Snap: 50% (nearest 5% increment)

**Final accuracy: 50%**

### Example: Why High Accuracy Matters

**Sniper with 120% base accuracy:**
- Unit: 120%
- Weapon: Sniper rifle (80%, range 30)
- Fire mode: Aimed (1.5x)
- Distance: 25 tiles (83% of max)
- Cover: 5 obstacle, 2 effect
- Visible: Yes

**Calculation:**
1. Base: (120/100) × 80 = 96%
2. Fire mode: 96 × 1.5 = 144%
3. Range: 144 × 0.87 = 125.28%
4. Obstacle cover: 125.28 × 0.75 = 93.96%
5. Effect cover: 93.96 × 0.9 = 84.56%
6. Visibility: 84.56 × 1.0 = 84.56%
7. Clamp: 84.56% → 84.56%
8. Snap: 85%

**Final: 85% (vs 50% for normal unit)**

High accuracy allows shooting through cover and at range effectively!

### Fire Mode Trade-offs

**Snap Shot:**
- Fast (1 AP)
- Normal accuracy (1.0x)
- Good for suppression or targets in open
- Energy efficient (1 EP)

**Aimed Shot:**
- Slower (2 AP)
- Better accuracy (1.5x)
- Best for distant or covered targets
- Energy efficient (1 EP)

**Auto Fire:**
- Slower (2 AP)
- Lower accuracy per shot (0.75x)
- 3 shots total (higher hit probability)
- Energy expensive (3 EP)
- Good for suppression or clusters

### Dependencies
- TASK-008: Weapon and Equipment System
- TASK-009: Range and Accuracy System
- TASK-010: Cover and LOS System
- `engine/battle/systems/accuracy_system.lua`
- `engine/battle/systems/range_system.lua`
- `engine/battle/systems/cover_system.lua`
- `engine/systems/los_system.lua`

---

## Testing Strategy

### Unit Tests
- Test 1: `test_accuracy_calculation.lua` - Verify formula correctness
- Test 2: `test_fire_modes.lua` - Test all fire mode modifiers
- Test 3: `test_accuracy_clamping.lua` - Test 5-95% clamping
- Test 4: `test_accuracy_snapping.lua` - Test 5% increment snapping
- Test 5: `test_modifier_combination.lua` - Test all modifiers together
- Test 6: `test_high_accuracy.lua` - Verify high accuracy benefits

### Integration Tests
- Test 1: `test_complete_accuracy_system.lua` - Full accuracy with all systems
- Test 2: `test_fire_mode_selection.lua` - UI fire mode selection
- Test 3: `test_accuracy_ui_display.lua` - UI shows correct breakdown

### Manual Testing Steps
1. Run game with `lovec "engine"`
2. Enter battlescape with varied terrain
3. Select unit with weapon
4. Target enemy at various ranges
5. For each fire mode, verify:
   - AP cost displayed correctly
   - EP cost displayed correctly
   - Accuracy calculated correctly
   - UI shows modifier breakdown
   - Final accuracy is 5-95% and multiple of 5
6. Test extreme cases:
   - Very high accuracy units
   - Very low accuracy situations
   - Maximum range shots
   - Heavy cover
   - Invisible targets
7. Verify console logs show full calculation
8. Compare displayed vs actual hit rates

### Expected Results
- Accuracy formula produces reasonable values
- Fire modes have distinct tactical uses
- Clamping prevents impossible percentages
- Snapping provides clean UI numbers
- High accuracy units perform better in difficult shots
- UI clearly shows all modifiers
- Console logs aid debugging
- No errors or warnings

---

## How to Run/Debug

### Running the Game
```bash
lovec "engine"
```
or use the VS Code task: "Run XCOM Simple Game"

### Debugging
- Love2D console is enabled in `conf.lua` (t.console = true)
- Add comprehensive debug prints:
```lua
print("[AccuracySystem] === Accuracy Calculation ===")
print("[AccuracySystem] Unit accuracy: " .. unitAccuracy .. "%")
print("[AccuracySystem] Weapon accuracy: " .. weaponAccuracy .. "%")
print("[AccuracySystem] Fire mode: " .. fireMode .. " (" .. fireModeModifier .. "x)")
print("[AccuracySystem] Distance: " .. distance .. " tiles")
print("[AccuracySystem] Range modifier: " .. rangeModifier)
print("[AccuracySystem] Obstacle cover: " .. obstacleCover .. " (-" .. (obstacleCover*5) .. "%)")
print("[AccuracySystem] Effect cover: " .. effectCover .. " (-" .. (effectCover*5) .. "%)")
print("[AccuracySystem] Cover modifier: " .. coverModifier)
print("[AccuracySystem] Visibility modifier: " .. visibilityModifier)
print("[AccuracySystem] Raw accuracy: " .. rawAccuracy .. "%")
print("[AccuracySystem] Final accuracy: " .. finalAccuracy .. "%")
```
- Use UI tooltip to show breakdown visually
- Compare multiple scenarios side-by-side

### Debug UI Display
```lua
-- Show accuracy breakdown in tooltip
local y = 100
love.graphics.print("Accuracy Breakdown:", 10, y)
y = y + 20
love.graphics.print("Base: " .. breakdown.unit_accuracy .. "% × " .. breakdown.weapon_accuracy .. "%", 10, y)
y = y + 15
love.graphics.print("Fire Mode: " .. breakdown.fire_mode .. " (×" .. breakdown.fire_mode_modifier .. ")", 10, y)
y = y + 15
love.graphics.print("Range: ×" .. string.format("%.2f", breakdown.range_modifier), 10, y)
-- ... continue for all modifiers
```

### Temporary Files
- All temporary files MUST be created in: `os.getenv("TEMP")`
- Never create temp files in project directories

---

## Documentation Updates

### Files to Update
- [ ] `wiki/API.md` - Add AccuracySystem.calculateFinalAccuracy API
- [ ] `wiki/FAQ.md` - Add section on accuracy calculation and fire modes
- [ ] `wiki/ECS_BATTLE_SYSTEM_API.md` - Document accuracy components
- [ ] Create `wiki/ACCURACY_SYSTEM.md` - Complete accuracy guide
- [ ] Create `wiki/FIRE_MODES.md` - Fire mode mechanics guide
- [ ] `engine/battle/systems/accuracy_system.lua` - Full docstrings
- [ ] `engine/battle/systems/fire_mode_system.lua` - Full docstrings

---

## Notes

- Clamping to 5-95% prevents frustration (no 0% or 100% shots)
- Snapping to 5% makes percentages easier to understand
- Fire modes add tactical depth without complexity
- High accuracy is valuable for overcoming penalties
- Formula is multiplicative (all penalties stack)
- Consider future: stance modifiers (prone/crouch)
- Consider future: status effects (wounded, panicked)
- Consider future: weapon attachments (scope, laser sight)

**Design Philosophy:**
- No shot is impossible (minimum 5%)
- No shot is guaranteed (maximum 95%)
- Player always knows exact probability
- Modifiers are transparent and logical
- High skill is rewarded but not overpowered

---

## Blockers

**Depends on:**
- TASK-008: Weapon and Equipment System
- TASK-009: Range and Accuracy System
- TASK-010: Cover and LOS System

---

## Review Checklist

- [ ] Code follows Lua/Love2D best practices
- [ ] No global variables (all use `local`)
- [ ] Proper error handling with `pcall` where needed
- [ ] Performance optimized (cache calculations)
- [ ] All temporary files use TEMP folder
- [ ] Console debugging statements added
- [ ] Tests written and passing
- [ ] Documentation updated
- [ ] Code reviewed
- [ ] No warnings in Love2D console
- [ ] Formula verified mathematically
- [ ] Fire modes balanced for gameplay
- [ ] UI clearly shows all information
- [ ] Edge cases handled (divide by zero, nil values)

---

## Post-Completion

### What Worked Well
- (To be filled after completion)

### What Could Be Improved
- (To be filled after completion)

### Lessons Learned
- (To be filled after completion)
