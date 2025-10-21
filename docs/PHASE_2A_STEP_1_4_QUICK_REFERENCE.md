# Phase 2A Step 1.4: Integration Quick Reference

**Status:** Ready to begin  
**Estimated Duration:** 2-3 hours  
**Primary File:** `engine/battlescape/combat/damage_system.lua`  

---

## Quick Integration Summary

### What to Do

1. **Add Flanking System to DamageSystem**
2. **Integrate into Damage Calculation Flow**
3. **Test All Scenarios**

### Where to Make Changes

**File:** `engine/battlescape/combat/damage_system.lua`

**Lines to Modify:**
- Constructor `new()` - Add flanking system initialization
- Function `resolveDamage()` - Add flanking calculation
- Add 2 new helper functions

### What Code to Add

#### 1. Import Flanking System (Top of file, after existing requires)

```lua
local FlankingSystem = require("battlescape.combat.flanking_system")
```

#### 2. Constructor Modification

**Find:**
```lua
function DamageSystem.new(moraleSystem)
    local self = setmetatable({}, DamageSystem)
    self.moraleSystem = moraleSystem or MoraleSystem.new()
    self.damageLog = {}
    return self
end
```

**Replace with:**
```lua
function DamageSystem.new(moraleSystem, flankingSystem)
    local self = setmetatable({}, DamageSystem)
    self.moraleSystem = moraleSystem or MoraleSystem.new()
    self.flankingSystem = flankingSystem or self:createFlankingSystem()
    self.damageLog = {}
    return self
end

function DamageSystem:createFlankingSystem()
    local HexMath = require("battlescape.battle_ecs.hex_math")
    return FlankingSystem.new(HexMath)
end
```

#### 3. Add to `resolveDamage()` Function

**Location:** After armor calculation, before critical hit check (~line 85)

**Add:**
```lua
-- Calculate flanking status
local flankingStatus = self.flankingSystem:getFlankingStatus(attacker, targetUnit)
print("[DamageSystem] Flanking status: " .. flankingStatus)

-- Apply flanking damage multiplier
local flankingMultiplier = self.flankingSystem:getDamageMultiplier(flankingStatus)
finalDamage = finalDamage * flankingMultiplier
print("[DamageSystem] Damage after flanking: " .. finalDamage)

-- Apply cover reduction (considering flanking)
local coverReduction = self:calculateCoverReduction(targetUnit, flankingStatus)
finalDamage = finalDamage * (1.0 - coverReduction)
print("[DamageSystem] Damage after cover: " .. finalDamage)
```

#### 4. Add Helper Functions (End of file, before return statement)

```lua
function DamageSystem:calculateCoverReduction(target, flankingStatus)
    if not self.battlefield then
        return 0.0
    end
    
    local tile = self.battlefield:getTile(target.x, target.y)
    if not tile then
        return 0.0
    end
    
    local coverValue = tile:getCover()
    local coverMultiplier = self.flankingSystem:getCoverMultiplier(flankingStatus)
    
    return coverValue * coverMultiplier
end

function DamageSystem:applyFlankingMoraleModifier(target, flankingStatus)
    if not self.moraleSystem then
        return
    end
    
    local flankingMoraleModifier = self.flankingSystem:getMoraleModifier(flankingStatus)
    
    if flankingMoraleModifier > 0 then
        local additionalMorale = math.floor(50 * flankingMoraleModifier)
        self.moraleSystem:applyMoraleLoss(target, additionalMorale)
        print("[DamageSystem] Applied " .. additionalMorale .. " flanking morale damage")
    end
end
```

#### 5. Apply Flanking Morale (In `distributeDamage()`)

**Location:** After other damage applications

**Add after the existing damage applications:**
```lua
-- Apply flanking morale modifier
self:applyFlankingMoraleModifier(unit, projectile.flankingStatus or "front")
```

---

## Testing Checklist

### Quick Verification (Before detailed tests)

- [ ] Game runs without console errors
- [ ] No nil reference errors
- [ ] Flanking system loads successfully
- [ ] HexMath functions work

### Position Detection Tests

- [ ] Front attack detected correctly
- [ ] Side attack detected correctly
- [ ] Rear attack detected correctly
- [ ] Damage multipliers applied correctly (1.0 / 1.25 / 1.5)

### Cover Integration Tests

- [ ] Full cover applied to front attacks (×1.0)
- [ ] Half cover applied to side attacks (×0.5)
- [ ] No cover applied to rear attacks (×0.0)
- [ ] Combined damage + cover + flanking calculation correct

### Morale Tests

- [ ] Front attacks: no additional morale loss
- [ ] Side attacks: +15% additional morale loss
- [ ] Rear attacks: +30% additional morale loss

### Edge Cases

- [ ] Wrap-around angles handled correctly (facing 0/5 boundary)
- [ ] 8-directional facing converted to 6-directional properly
- [ ] Units at exactly 0°, 60°, 120° positions work
- [ ] All combinations of terrain cover types work

---

## Expected Console Output

When running with flanking attack:

```
[DamageSystem] Resolving damage: power=40, type=kinetic, target=SoldierName
[DamageSystem] Damage calculation: base=40, resistance=1.0, effective=40, armor=10, final=30
[DamageSystem] Flanking status: side
[DamageSystem] Damage after flanking: 37.5 (30 × 1.25)
[DamageSystem] Damage after cover: 25 (37.5 × 0.67 = after 50% cover reduction)
[DamageSystem] Damage distribution: HP=26, Stun=6, Morale=0, Energy=0
[DamageSystem] Applied 7 flanking morale damage
```

---

## Common Issues & Solutions

### Issue: "FlankingSystem module not found"
**Solution:** Verify `engine/battlescape/combat/flanking_system.lua` exists and is spelled correctly

### Issue: "HexMath is nil"
**Solution:** Verify `battlescape.battle_ecs.hex_math` path is correct

### Issue: "targetUnit.x is nil"
**Solution:** Ensure attacker/target objects have x and y properties

### Issue: "Damage seems unchanged"
**Solution:** Check console output to see if flanking status is being calculated; verify multiplier applied

### Issue: "Game runs but no flanking effect"
**Solution:** Verify `flankingStatus` is being passed to `applyFlankingMoraleModifier()`

---

## Files to Reference

### Implementation Details
- `docs/PHASE_2A_STEP_1_3_FLANKING_IMPLEMENTATION.md` - Full implementation guide with code examples

### Module Documentation
- `engine/battlescape/combat/flanking_system.lua` - All available functions and their usage

### Design Reference
- `docs/PHASE_2A_STEP_1_2_COVER_FLANKING_DESIGN.md` - Design rationale and integration points

---

## Testing with Console

**Run game:**
```bash
lovec "engine"
```

**Look for flanking output:**
- [DamageSystem] Flanking status: front/side/rear
- [DamageSystem] Damage after flanking: [number]
- [DamageSystem] Applied [number] flanking morale damage

**Verify calculations:**
- Base damage 40 × flanking multiplier = expected result
- Example: 40 × 1.25 = 50 for side flank

---

## Step-by-Step Integration

1. **Open** `engine/battlescape/combat/damage_system.lua`

2. **Add import** at top after other requires

3. **Modify constructor** `new()` function

4. **Add helper** `createFlankingSystem()`

5. **Update** `resolveDamage()` - Add flanking calculation

6. **Add helpers** `calculateCoverReduction()` and `applyFlankingMoraleModifier()`

7. **Update** `distributeDamage()` - Apply flanking morale

8. **Test** - Run game and check console

9. **Verify** - All flanking positions work

10. **Complete** - Phase 2A 100% done!

---

## Success = Phase 2A Complete ✅

When all tests pass:
- ✅ Flanking damage multipliers working
- ✅ Cover reduction applied by position
- ✅ Morale damage increased for rear attacks
- ✅ All combat flows unchanged
- ✅ Game runs without errors
- ✅ Phase 2A = 100% Complete

---

**Ready to Integrate:** YES  
**Estimated Time:** 2-3 hours  
**Difficulty:** Moderate (straightforward code additions)  
**Risk:** Low (isolated to damage calculation)
