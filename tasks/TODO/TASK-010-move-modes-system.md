# Task: Implement Move Modes System

**Status:** TODO  
**Priority:** High  
**Created:** October 12, 2025  
**Completed:** N/A  
**Assigned To:** AI Agent

---

## Overview

Implement four move modes (WALK, RUN, SNEAK, FLY) with different costs and benefits. Modes selectable via radio buttons and keyboard modifiers. Modes must be enabled by armor.

---

## Purpose

Add tactical depth to movement decisions. Players can choose speed vs. stealth vs. special movement, creating interesting risk/reward gameplay.

---

## Requirements

### Functional Requirements
- [ ] Four move modes: WALK, RUN, SNEAK, FLY
- [ ] WALK: Normal movement (default)
- [ ] RUN: 50% MP cost, but 1 EP per 1 AP spent on movement
- [ ] SNEAK: 200% MP cost, +3 cover for spotting, harder to trigger reaction fire
- [ ] FLY: 100% MP cost, all tiles cost 2 MP (including water), costs EP
- [ ] Radio button group in GUI for mode selection
- [ ] Keyboard modifiers for quick mode selection:
  - No modifier: WALK
  - Ctrl + click: SNEAK
  - Shift + click: RUN
  - Alt + click: FLY
- [ ] Armor defines which modes are available
- [ ] Disabled modes grayed out in UI

### Technical Requirements
- [ ] Radio button group widget
- [ ] Keyboard modifier detection
- [ ] Movement cost calculation per mode
- [ ] Energy cost calculation
- [ ] Armor configuration for modes
- [ ] Cover modifier for sneaking
- [ ] All tiles accessible when flying

### Acceptance Criteria
- [ ] All four modes implemented
- [ ] Mode selection works (radio + keyboard)
- [ ] Movement costs calculated correctly
- [ ] Energy costs apply correctly
- [ ] Armor restricts unavailable modes
- [ ] Sneak adds cover bonus
- [ ] Fly enables all terrain
- [ ] UI clear and intuitive

---

## Plan

### Step 1: Define Move Mode System
**Description:** Create core move mode data structure  
**Files to create:**
- `engine/battle/systems/move_mode_system.lua`

**Mode definitions:**
```lua
{
    WALK = {
        id = "walk",
        name = "Walk",
        mpCostMultiplier = 1.0,
        apCostMultiplier = 1.0,
        epCostPerAP = 0,
        coverBonus = 0,
        ignoresTerrain = false
    },
    RUN = {
        id = "run",
        name = "Run",
        mpCostMultiplier = 0.5,
        apCostMultiplier = 1.0,
        epCostPerAP = 1,
        coverBonus = 0,
        ignoresTerrain = false
    },
    SNEAK = {
        id = "sneak",
        name = "Sneak",
        mpCostMultiplier = 2.0,
        apCostMultiplier = 1.0,
        epCostPerAP = 0,
        coverBonus = 3,
        ignoresTerrain = false
    },
    FLY = {
        id = "fly",
        name = "Fly",
        mpCostMultiplier = 1.0,
        apCostMultiplier = 1.0,
        epCostPerAP = 1,
        coverBonus = 0,
        ignoresTerrain = true,
        flatCost = 2  -- All tiles cost 2 MP
    }
}
```

**Estimated time:** 3 hours

### Step 2: Add Armor Mode Configuration
**Description:** Define which modes each armor type enables  
**Files to modify:**
- `mods/core/armor/soldier_armor.lua` (or similar)

**Config format:**
```lua
{
    name = "Combat Armor",
    moveModes = {
        walk = true,
        run = true,
        sneak = true,
        fly = false
    }
}
```

**Files to create:**
- Example armor configs with different mode availability

**Estimated time:** 2 hours

### Step 3: Create Radio Button Group Widget
**Description:** Widget for mode selection  
**Files to modify/create:**
- `engine/widgets/containers/radio_button_group.lua` (may exist)
- `engine/widgets/buttons/radio_button.lua` (may exist)

**Features:**
- Only one selected at a time
- Visual indication of selection
- Disabled state for unavailable modes
- Grid-aligned layout

**Estimated time:** 3 hours

### Step 4: Create Move Mode Panel
**Description:** UI panel with 4 mode buttons  
**Files to create:**
- `engine/widgets/display/move_mode_panel.lua`

**Layout:**
```
Bottom section of GUI:
WALK | RUN | SNEAK | FLY
(4 buttons in a row, each 6×2 grid cells = 144×48)
```

**Estimated time:** 3 hours

### Step 5: Implement Movement Cost Calculation
**Description:** Calculate MP cost based on mode  
**Files to modify:**
- `engine/systems/pathfinding.lua`
- `engine/battle/systems/movement_system.lua`

**Logic:**
```lua
function calculateMovementCost(tile, mode)
    local baseCost = tile.moveCost  -- Terrain cost
    
    if mode.ignoresTerrain then
        return mode.flatCost  -- Fly: always 2 MP
    end
    
    return baseCost * mode.mpCostMultiplier
end
```

**Estimated time:** 3 hours

### Step 6: Implement Energy Cost System
**Description:** Charge EP for RUN and FLY modes  
**Files to modify:**
- `engine/battle/systems/movement_system.lua`
- `engine/systems/unit.lua`

**Logic:**
- Track AP spent on movement
- Apply EP cost: AP × mode.epCostPerAP
- Check sufficient EP before allowing movement
- Prevent movement if insufficient EP

**Estimated time:** 3 hours

### Step 7: Implement Sneak Cover Bonus
**Description:** Add cover bonus during sneak movement  
**Files to modify:**
- `engine/systems/unit.lua`
- `engine/battle/systems/reaction_fire_system.lua` (if exists)

**Effect:**
- Unit has +3 cover during sneak movement
- Harder for enemies to spot
- Affects reaction fire chance
- Applied only while moving in sneak mode

**Estimated time:** 3 hours

### Step 8: Implement Keyboard Modifiers
**Description:** Detect Ctrl, Shift, Alt for mode override  
**Files to modify:**
- `engine/modules/battlescape.lua`

**Logic:**
```lua
function handleMovementClick(x, y)
    local mode = "walk"  -- Default
    
    if love.keyboard.isDown("lctrl", "rctrl") then
        mode = "sneak"
    elseif love.keyboard.isDown("lshift", "rshift") then
        mode = "run"
    elseif love.keyboard.isDown("lalt", "ralt") then
        mode = "fly"
    else
        mode = selectedMoveMode  -- From radio buttons
    end
    
    moveUnit(selectedUnit, x, y, mode)
end
```

**Estimated time:** 2 hours

### Step 9: Integrate with Action Panel
**Description:** Add move mode buttons to action panel  
**Files to modify:**
- `engine/modules/battlescape.lua` (or action panel file)

**Location:** Bottom part of GUI
**Group:** Radio button group (only one mode active)
**Position:** Below weapon/armor/skill buttons

**Estimated time:** 3 hours

### Step 10: Add Mode Availability Checking
**Description:** Enable/disable modes based on armor  
**Files to modify:**
- `engine/widgets/display/move_mode_panel.lua`

**Logic:**
```lua
function MoveMode Panel:updateAvailability(unit)
    local armor = unit.armor
    
    for _, button in ipairs(self.modeButtons) do
        local mode = button.mode
        local available = armor.moveModes[mode.id]
        button:setEnabled(available)
    end
end
```

**Estimated time:** 2 hours

### Step 11: Add Visual Feedback
**Description:** Show current mode during movement  
**Files to modify:**
- `engine/battle/renderer.lua`

**Display:**
- Show mode icon/text near unit
- Show estimated MP cost on hover
- Highlight path color based on mode (optional)
- Show EP cost in UI

**Estimated time:** 3 hours

### Step 12: Testing
**Description:** Test all modes and interactions  
**Test cases:**
- Select WALK → Normal movement
- Select RUN → 50% MP cost, EP consumed
- Select SNEAK → 200% MP cost, +3 cover
- Select FLY → All terrain 2 MP, EP consumed
- Keyboard modifiers override radio selection
- Armor disables unavailable modes
- Insufficient EP prevents movement
- Cover bonus applies during sneak
- Flying crosses water

**Estimated time:** 4 hours

---

## Implementation Details

### Architecture

**Move Mode System:**
```lua
-- engine/battle/systems/move_mode_system.lua
local MoveModeSystem = {
    currentMode = "walk",
    modes = {
        walk = {
            id = "walk",
            name = "Walk",
            mpCostMultiplier = 1.0,
            epCostPerAP = 0,
            coverBonus = 0,
            ignoresTerrain = false
        },
        run = {
            id = "run",
            name = "Run",
            mpCostMultiplier = 0.5,
            epCostPerAP = 1,
            coverBonus = 0,
            ignoresTerrain = false
        },
        sneak = {
            id = "sneak",
            name = "Sneak",
            mpCostMultiplier = 2.0,
            epCostPerAP = 0,
            coverBonus = 3,
            ignoresTerrain = false
        },
        fly = {
            id = "fly",
            name = "Fly",
            mpCostMultiplier = 1.0,
            epCostPerAP = 1,
            coverBonus = 0,
            ignoresTerrain = true,
            flatCost = 2
        }
    }
}

function MoveModeSystem:setMode(modeId)
    if self.modes[modeId] then
        self.currentMode = modeId
        print("[MoveMode] Set to: " .. self.modes[modeId].name)
    end
end

function MoveModeSystem:getMode()
    return self.modes[self.currentMode]
end

function MoveModeSystem:calculateCost(tile, unit)
    local mode = self:getMode()
    
    if mode.ignoresTerrain then
        return mode.flatCost
    end
    
    local baseCost = tile.moveCost or 1
    return baseCost * mode.mpCostMultiplier
end

function MoveModeSystem:getEnergyCost(apSpent)
    local mode = self:getMode()
    return apSpent * mode.epCostPerAP
end

function MoveModeSystem:getCoverBonus()
    local mode = self:getMode()
    return mode.coverBonus
end
```

**Movement with Mode:**
```lua
-- engine/battle/systems/movement_system.lua
function MovementSystem:moveUnit(unit, targetX, targetY, modeId)
    -- Set move mode
    moveModeSystem:setMode(modeId or "walk")
    
    -- Calculate path with mode costs
    local path = pathfinding.findPath(unit.x, unit.y, targetX, targetY, function(tile)
        return moveModeSystem:calculateCost(tile, unit)
    end)
    
    if not path then
        print("[Movement] No path found")
        return false
    end
    
    -- Calculate total cost
    local mpCost = 0
    for _, tile in ipairs(path) do
        mpCost = mpCost + moveModeSystem:calculateCost(tile, unit)
    end
    
    -- Calculate AP cost
    local apCost = math.ceil(mpCost / unit.speed)
    
    -- Calculate EP cost
    local epCost = moveModeSystem:getEnergyCost(apCost)
    
    -- Check resources
    if not unit:hasMP(mpCost) or not unit:hasEnergy(epCost) then
        print("[Movement] Insufficient resources")
        return false
    end
    
    -- Execute movement
    unit:useMP(mpCost)
    unit:useAP(apCost)
    unit:useEnergy(epCost)
    
    -- Apply cover bonus if sneaking
    if moveModeSystem.currentMode == "sneak" then
        unit.temporaryCover = moveModeSystem:getCoverBonus()
    end
    
    -- Move unit
    unit.x, unit.y = targetX, targetY
    
    -- Clear cover bonus after movement
    unit.temporaryCover = 0
    
    return true
end
```

**Radio Button Group:**
```lua
-- In action panel
local moveModeButtons = RadioButtonGroup:new(x, y)
moveModeButtons:addButton("Walk", "walk")
moveModeButtons:addButton("Run", "run")
moveModeButtons:addButton("Sneak", "sneak")
moveModeButtons:addButton("Fly", "fly")
moveModeButtons:select("walk")

-- Update availability based on armor
function updateMoveModes(unit)
    local armor = unit.armor
    moveModeButtons:setEnabled("walk", armor.moveModes.walk)
    moveModeButtons:setEnabled("run", armor.moveModes.run)
    moveModeButtons:setEnabled("sneak", armor.moveModes.sneak)
    moveModeButtons:setEnabled("fly", armor.moveModes.fly)
end
```

### Key Components
- **MoveModeSystem:** Core mode logic and cost calculation
- **MoveModePanel:** UI for mode selection
- **RadioButtonGroup:** Mutually exclusive button selection
- **MovementSystem:** Integrates modes with movement
- **Armor Config:** Defines available modes per armor

### Dependencies
- Pathfinding system
- Movement system
- Unit system
- Widget system (radio buttons)
- Armor/equipment system

---

## Testing Strategy

### Unit Tests
- Mode cost calculation
- Energy cost calculation
- Cover bonus application
- Terrain ignore logic (fly)

### Integration Tests
- Full movement with each mode
- Keyboard modifier detection
- Mode availability from armor
- Resource checking (MP, EP)

### Manual Testing Steps
1. Select unit
2. Select WALK mode → Move normally
3. Select RUN mode → Move, verify 50% cost, EP consumed
4. Select SNEAK mode → Move, verify 200% cost, +3 cover
5. Select FLY mode → Move, verify can cross water, EP consumed
6. Hold Ctrl + click → Sneak mode
7. Hold Shift + click → Run mode
8. Hold Alt + click → Fly mode
9. Change armor → Verify modes enable/disable
10. Test insufficient EP → Movement blocked
11. Test visual feedback shows current mode
12. Test pathfinding with different modes

### Expected Results
- All modes work correctly
- Costs calculated accurately
- Keyboard shortcuts functional
- Armor restrictions respected
- EP costs apply
- Cover bonus works
- Flying crosses all terrain

---

## How to Run/Debug

### Running the Game
```bash
lovec "engine"
```

### Debug Output
```lua
print("[MoveMode] Current mode: " .. mode.name)
print("[MoveMode] MP cost: " .. mpCost .. " EP cost: " .. epCost)
print("[MoveMode] Cover bonus: " .. mode.coverBonus)
print("[MoveMode] Ignores terrain: " .. tostring(mode.ignoresTerrain))
```

### Visual Debug
```lua
-- Draw mode indicator
love.graphics.print("Mode: " .. moveModeSystem:getMode().name, 10, 70)
love.graphics.print("Cover: " .. unit.temporaryCover, 10, 90)

-- Show path cost
for _, tile in ipairs(path) do
    local cost = moveModeSystem:calculateCost(tile, unit)
    love.graphics.print(tostring(cost), tile.x * 24, tile.y * 24)
end
```

---

## Documentation Updates

### Files to Update
- [ ] `wiki/API.md` - Document move mode system
- [ ] `wiki/FAQ.md` - Explain move modes
- [ ] `engine/battle/systems/README.md` - Document move mode system
- [ ] Armor config documentation

---

## Notes

**Mode Trade-offs:**
- **WALK:** Balanced, no special effects
- **RUN:** Fast but tiring (EP cost)
- **SNEAK:** Slow but stealthy (+3 cover)
- **FLY:** Terrain-independent but expensive (EP cost)

**Tactical Decisions:**
- Use RUN when speed matters and EP available
- Use SNEAK when avoiding detection crucial
- Use FLY for shortcuts or crossing impassable terrain
- Manage EP as limited resource

**Future Enhancements:**
- CRAWL mode (even slower, more cover)
- JUMP mode (leap short distances)
- Mode-specific animations
- Sound effects per mode
- Footprint/trail visibility by mode

---

## Blockers

Need pathfinding and movement system details.

---

## Review Checklist

- [ ] MoveModeSystem created
- [ ] All four modes implemented
- [ ] Radio button group working
- [ ] Keyboard modifiers working
- [ ] Movement costs calculated correctly
- [ ] Energy costs applied correctly
- [ ] Sneak cover bonus working
- [ ] Fly ignores terrain
- [ ] Armor restrictions working
- [ ] UI clear and intuitive
- [ ] Visual feedback present
- [ ] All tests passing
- [ ] Documentation updated

---

## Post-Completion

### What Worked Well
- To be filled after completion

### What Could Be Improved
- To be filled after completion

### Lessons Learned
- To be filled after completion
