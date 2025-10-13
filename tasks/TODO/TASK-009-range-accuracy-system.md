# Task: Range and Accuracy Calculation System

**Status:** TODO  
**Priority:** High  
**Created:** October 13, 2025  
**Completed:** N/A  
**Assigned To:** AI Agent

---

## Overview

Implement the range-based accuracy calculation system. Weapon accuracy varies based on distance to target, with 100% accuracy up to 75% of max range, dropping to 50% at max range, and 0% at 125% of max range.

---

## Purpose

Create realistic accuracy falloff based on range, making positioning and weapon choice tactical decisions. Allows weapons to have effective ranges and encourages players to close distance for better shots.

---

## Requirements

### Functional Requirements
- [ ] Weapon has base accuracy (e.g., pistol = 60%)
- [ ] Weapon has max range (e.g., pistol = 15 tiles)
- [ ] Accuracy zones based on distance:
  - 0% to 75% of max range: 100% of weapon accuracy
  - 75% to 100% of max range: Linear drop from 100% to 50%
  - 100% to 125% of max range: Linear drop from 50% to 0%
  - Beyond 125% of max range: Cannot shoot
- [ ] Distance calculated in tiles (hex grid)
- [ ] Accuracy multiplier applied to base weapon accuracy

### Technical Requirements
- [ ] Calculate distance between shooter and target in tiles
- [ ] Implement range-based accuracy multiplier function
- [ ] Apply multiplier to weapon base accuracy
- [ ] Prevent shooting beyond 125% of max range
- [ ] Handle edge cases (range 0, negative values)
- [ ] Optimize distance calculation for performance

### Acceptance Criteria
- [ ] Shooting at 50% range gives 100% weapon accuracy
- [ ] Shooting at 75% range gives 100% weapon accuracy
- [ ] Shooting at 100% range gives 50% weapon accuracy
- [ ] Shooting at 125% range gives 0% weapon accuracy (blocked)
- [ ] Shooting beyond 125% range is prevented
- [ ] Accuracy calculations are consistent and reproducible
- [ ] UI displays effective accuracy after range modifier

---

## Plan

### Step 1: Distance Calculation
**Description:** Implement hex grid distance calculation  
**Files to modify/create:**
- `engine/battle/utils/hex_math.lua` - Hex distance functions
- `engine/battle/systems/range_system.lua` - Range calculation system

**Estimated time:** 2 hours

### Step 2: Range-Based Accuracy Multiplier
**Description:** Calculate accuracy multiplier based on distance  
**Files to modify/create:**
- `engine/battle/systems/accuracy_system.lua` - Accuracy calculation

**Estimated time:** 3 hours

### Step 3: Integration with Weapon System
**Description:** Apply range modifier to weapon shots  
**Files to modify/create:**
- `engine/battle/systems/shooting_system.lua` - Integrate range checks
- `engine/systems/weapon_system.lua` - Add range validation

**Estimated time:** 2 hours

### Step 4: UI Display
**Description:** Show effective accuracy in UI  
**Files to modify/create:**
- `engine/modules/battlescape.lua` - Display accuracy with range modifier
- `engine/widgets/targeting_reticle.lua` - Show range zones visually

**Estimated time:** 2 hours

### Step 5: Testing
**Description:** Verify range and accuracy calculations  
**Test cases:**
- Distance calculations accurate
- Accuracy zones correct (0-75%, 75-100%, 100-125%)
- Out of range shots blocked
- UI displays correct values

**Estimated time:** 2 hours

---

## Implementation Details

### Architecture
Create a standalone accuracy system that takes distance and weapon properties, returns effective accuracy. Integrate with shooting system for validation and UI for display.

### Key Components

**RangeSystem:**
```lua
--- Calculate distance between two hex positions
-- @param pos1 table First position {q, r, s}
-- @param pos2 table Second position {q, r, s}
-- @return number Distance in tiles
function RangeSystem.calculateDistance(pos1, pos2)
    return (math.abs(pos1.q - pos2.q) + 
            math.abs(pos1.r - pos2.r) + 
            math.abs(pos1.s - pos2.s)) / 2
end

--- Check if target is in range
-- @param distance number Distance in tiles
-- @param weapon table Weapon with range property
-- @return boolean True if in shootable range (≤125% of max)
function RangeSystem.isInRange(distance, weapon)
    return distance <= (weapon.range * 1.25)
end
```

**AccuracySystem:**
```lua
--- Calculate range-based accuracy multiplier
-- @param distance number Distance to target in tiles
-- @param maxRange number Maximum range of weapon
-- @return number Multiplier (0.0 to 1.0)
function AccuracySystem.getRangeMultiplier(distance, maxRange)
    local rangePercent = distance / maxRange
    
    if rangePercent <= 0.75 then
        -- 0% to 75% range: 100% accuracy
        return 1.0
    elseif rangePercent <= 1.0 then
        -- 75% to 100% range: Linear drop from 100% to 50%
        local t = (rangePercent - 0.75) / 0.25
        return 1.0 - (t * 0.5)
    elseif rangePercent <= 1.25 then
        -- 100% to 125% range: Linear drop from 50% to 0%
        local t = (rangePercent - 1.0) / 0.25
        return 0.5 - (t * 0.5)
    else
        -- Beyond 125%: Cannot shoot
        return 0.0
    end
end

--- Calculate effective accuracy after range modifier
-- @param baseAccuracy number Weapon base accuracy (0-100)
-- @param distance number Distance to target
-- @param maxRange number Weapon max range
-- @return number Effective accuracy (0-100)
function AccuracySystem.getEffectiveAccuracy(baseAccuracy, distance, maxRange)
    local multiplier = AccuracySystem.getRangeMultiplier(distance, maxRange)
    return baseAccuracy * multiplier
end
```

### Mathematical Formula

Given:
- `d` = distance to target (tiles)
- `r` = weapon max range (tiles)
- `p` = `d / r` (range percentage)

Range Multiplier `m`:
```
if p ≤ 0.75:     m = 1.0
if 0.75 < p ≤ 1.0:  m = 1.0 - ((p - 0.75) / 0.25) * 0.5
if 1.0 < p ≤ 1.25:  m = 0.5 - ((p - 1.0) / 0.25) * 0.5
if p > 1.25:     m = 0.0 (cannot shoot)
```

Effective Accuracy = Base Accuracy × m

### Example Calculations

**Pistol (base accuracy 60%, max range 15 tiles):**

| Distance | Range % | Multiplier | Effective Accuracy |
|----------|---------|------------|--------------------|
| 5 tiles  | 33%     | 1.0        | 60%                |
| 11 tiles | 73%     | 1.0        | 60%                |
| 12 tiles | 80%     | 0.9        | 54%                |
| 15 tiles | 100%    | 0.5        | 30%                |
| 18 tiles | 120%    | 0.1        | 6%                 |
| 19 tiles | 127%    | 0.0        | 0% (blocked)       |

### Dependencies
- `engine/battle/utils/hex_math.lua` - Hex grid distance
- `engine/systems/weapon_system.lua` - Weapon properties
- `engine/battle/systems/shooting_system.lua` - Integration point

---

## Testing Strategy

### Unit Tests
- Test 1: `test_range_calculation.lua` - Verify distance calculations accurate
- Test 2: `test_accuracy_multiplier.lua` - Test all range zones
- Test 3: `test_range_edge_cases.lua` - Test boundaries (75%, 100%, 125%)
- Test 4: `test_out_of_range.lua` - Verify shots blocked beyond 125%

### Integration Tests
- Test 1: `test_range_accuracy_integration.lua` - Full accuracy calculation
- Test 2: `test_ui_accuracy_display.lua` - UI shows correct values

### Manual Testing Steps
1. Run game with `lovec "engine"`
2. Enter battlescape with units at various ranges
3. Select unit and target enemy
4. Verify UI shows:
   - Distance to target
   - Base weapon accuracy
   - Effective accuracy (with range modifier)
   - Whether target is in range
5. Test shooting at different ranges
6. Verify accuracy matches displayed values
7. Verify cannot shoot beyond 125% range

### Expected Results
- Distance calculations match hex grid
- Accuracy zones work as specified
- UI displays all relevant information
- Out of range shots are blocked
- Console shows calculation details
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
- Add debug prints:
```lua
print("[RangeSystem] Distance: " .. distance .. " tiles")
print("[RangeSystem] Max range: " .. weapon.range .. " tiles")
print("[RangeSystem] Range %: " .. (distance/weapon.range * 100) .. "%")
print("[AccuracySystem] Range multiplier: " .. multiplier)
print("[AccuracySystem] Base accuracy: " .. baseAccuracy .. "%")
print("[AccuracySystem] Effective accuracy: " .. effectiveAccuracy .. "%")
```
- Use on-screen debug to show range zones visually
- Test with F9 grid overlay to count tiles

### Temporary Files
- All temporary files MUST be created in: `os.getenv("TEMP")`
- Never create temp files in project directories

---

## Documentation Updates

### Files to Update
- [ ] `wiki/API.md` - Add RangeSystem and AccuracySystem APIs
- [ ] `wiki/FAQ.md` - Add section explaining range and accuracy mechanics
- [ ] `wiki/ECS_BATTLE_SYSTEM_API.md` - Document accuracy calculations
- [ ] `engine/battle/systems/accuracy_system.lua` - Full docstrings
- [ ] `engine/battle/systems/range_system.lua` - Full docstrings

---

## Notes

- Range zones create natural effective ranges for weapons
- Encourages tactical positioning and closing distance
- Higher accuracy weapons (sniper rifles) maintain accuracy at longer ranges
- Formula is simple linear interpolation for performance
- Consider future: terrain height affecting range/accuracy
- Consider future: weather affecting visibility and range

---

## Blockers

**Depends on:** TASK-008-weapon-equipment-system (need weapon properties)

---

## Review Checklist

- [ ] Code follows Lua/Love2D best practices
- [ ] No global variables (all use `local`)
- [ ] Proper error handling with `pcall` where needed
- [ ] Performance optimized (object reuse, efficient loops)
- [ ] All temporary files use TEMP folder
- [ ] Console debugging statements added
- [ ] Tests written and passing
- [ ] Documentation updated
- [ ] Code reviewed
- [ ] No warnings in Love2D console
- [ ] Mathematical formulas verified correct
- [ ] Edge cases handled (0 range, exact boundaries)
- [ ] UI displays accuracy clearly

---

## Post-Completion

### What Worked Well
- (To be filled after completion)

### What Could Be Improved
- (To be filled after completion)

### Lessons Learned
- (To be filled after completion)
