# Task: Implement Action Panel with RMB Context System

**Status:** TODO  
**Priority:** High  
**Created:** October 12, 2025  
**Completed:** N/A  
**Assigned To:** AI Agent

---

## Overview

Implement action panel with 8 actions organized as radio button group. LMB for selection/info, RMB for executing selected action. Actions include weapon slots, armor ability, skill, and move modes.

---

## Purpose

Provide intuitive combat interface where players select action type first, then execute with RMB. Separates selection (LMB) from action (RMB), reducing misclicks and enabling information viewing.

---

## Requirements

### Functional Requirements
- [ ] 8 action buttons in 2 rows:
  - Row 1: WEAPON 1 | WEAPON 2 | ARMOR | SKILL
  - Row 2: WALK | RUN | SNEAK | FLY
- [ ] Buttons form single radio button group (only one selected)
- [ ] LMB selects unit or views tile info
- [ ] RMB executes selected action on target tile
- [ ] Weapon/armor/skill actions: RMB uses item on target
- [ ] Move mode actions: RMB moves to target tile
- [ ] Visual feedback for selected action
- [ ] Action availability indication (grayed out if unavailable)

### Technical Requirements
- [ ] Radio button group for 8 actions
- [ ] Mouse button handling (LMB vs RMB)
- [ ] Action execution system
- [ ] Action availability checking
- [ ] Cursor changes based on selected action
- [ ] Grid-aligned layout (24×24)

### Acceptance Criteria
- [ ] All 8 buttons display correctly
- [ ] Only one action selected at a time
- [ ] LMB selects/views, RMB executes
- [ ] Weapon actions work correctly
- [ ] Armor ability works correctly
- [ ] Skill action works correctly
- [ ] Move modes work correctly
- [ ] Unavailable actions grayed out
- [ ] Clear visual feedback

---

## Plan

### Step 1: Design Action Panel Layout
**Description:** Plan UI layout for 8-button action panel  
**Layout:**
```
Bottom area of GUI:
[WEAPON 1] [WEAPON 2] [ARMOR] [SKILL]  ← Row 1
[  WALK  ] [  RUN   ] [SNEAK] [ FLY ]  ← Row 2

Each button: 6×2 grid cells (144×48 pixels)
Total width: 24 grid cells (576 pixels)
Total height: 4 grid cells (96 pixels)
Centered horizontally or positioned appropriately
```

**Estimated time:** 2 hours

### Step 2: Create Action Button Widget
**Description:** Custom button for action selection  
**Files to create:**
- `engine/widgets/buttons/action_button.lua`

**Features:**
- Radio button behavior
- Icon + label
- Enabled/disabled state
- Selected state highlight
- Tooltip on hover

**Estimated time:** 3 hours

### Step 3: Create Action Panel Widget
**Description:** Container for 8 action buttons  
**Files to create:**
- `engine/widgets/display/action_panel.lua`

**Features:**
- Manage 8 action buttons
- Radio group behavior
- Update availability based on unit
- Handle selection changes
- Provide selected action to battlescape

**Estimated time:** 4 hours

### Step 4: Implement Action System
**Description:** Core action execution logic  
**Files to create:**
- `engine/battle/systems/action_system.lua` (may exist, enhance)

**Actions:**
- WEAPON_1: Use primary weapon on target
- WEAPON_2: Use secondary weapon on target
- ARMOR: Use armor ability on target
- SKILL: Use selected skill on target
- WALK: Move to target in walk mode
- RUN: Move to target in run mode
- SNEAK: Move to target in sneak mode
- FLY: Move to target in fly mode

**Estimated time:** 5 hours

### Step 5: Implement Mouse Button Handling
**Description:** Separate LMB and RMB behavior  
**Files to modify:**
- `engine/modules/battlescape.lua`

**LMB Actions:**
- Click unit → Select unit
- Click tile → Show tile info (in info panel)
- Click empty → Deselect unit

**RMB Actions:**
- Click tile with action selected → Execute action
- Weapon actions → Fire at target
- Armor/skill actions → Use on target
- Move actions → Move to tile

**Estimated time:** 4 hours

### Step 6: Implement Action Availability
**Description:** Enable/disable actions based on context  
**Files to modify:**
- `engine/widgets/display/action_panel.lua`
- `engine/battle/systems/action_system.lua`

**Availability checks:**
- WEAPON_1/2: Has weapon, has ammo, has AP
- ARMOR: Has armor ability, has EP, has AP
- SKILL: Has skill equipped, has AP
- WALK: Always available
- RUN: Armor allows, has EP
- SNEAK: Armor allows
- FLY: Armor allows, has EP

**Estimated time:** 3 hours

### Step 7: Add Visual Feedback
**Description:** Show what action will do  
**Files to modify:**
- `engine/battle/renderer.lua`
- `engine/modules/battlescape.lua`

**Feedback:**
- Show attack range for weapon actions
- Show valid targets (highlight tiles)
- Show movement path for move actions
- Show AP/EP cost in UI
- Change cursor based on action

**Estimated time:** 4 hours

### Step 8: Implement Weapon Actions
**Description:** Use weapon on RMB  
**Files to modify:**
- `engine/battle/systems/action_system.lua`
- `engine/battle/fire_system.lua`

**Logic:**
- Check weapon range
- Check line of sight
- Check ammo
- Check AP
- Execute shot
- Apply damage
- Update ammo count

**Estimated time:** 3 hours

### Step 9: Implement Armor Ability
**Description:** Use armor special ability  
**Files to modify:**
- `engine/battle/systems/action_system.lua`

**Example abilities:**
- Shield boost (increase armor temporarily)
- Cloak (become harder to spot)
- Energy shield (absorb damage)
- Boost speed (extra MP this turn)

**Estimated time:** 4 hours

### Step 10: Implement Skill Action
**Description:** Use equipped skill  
**Files to modify:**
- `engine/battle/systems/action_system.lua`
- `engine/battle/systems/skill_system.lua` (create if needed)

**Example skills:**
- Medkit (heal ally)
- Grenade (area damage)
- Scanner (reveal enemies)
- Hack (disable enemy)

**Estimated time:** 4 hours

### Step 11: Integrate with Battlescape
**Description:** Add action panel to battlescape UI  
**Files to modify:**
- `engine/modules/battlescape.lua`

**Position:** Bottom center or bottom left
**Integration:** Connect to selected unit, update on selection change

**Estimated time:** 3 hours

### Step 12: Add Keyboard Shortcuts
**Description:** Hotkeys for quick action selection  
**Keys:**
- 1: WEAPON_1
- 2: WEAPON_2
- 3: ARMOR
- 4: SKILL
- Q: WALK
- W: RUN
- E: SNEAK
- R: FLY

**Files to modify:**
- `engine/modules/battlescape.lua`

**Estimated time:** 2 hours

### Step 13: Testing
**Description:** Test all actions and interactions  
**Test cases:**
- Select each action → RMB executes
- LMB on unit → Selects unit
- LMB on tile → Shows info
- RMB with weapon → Fires
- RMB with armor → Uses ability
- RMB with skill → Uses skill
- RMB with move mode → Moves
- Unavailable actions grayed out
- Keyboard shortcuts work
- Visual feedback correct

**Estimated time:** 5 hours

---

## Implementation Details

### Architecture

**Action Panel:**
```lua
-- engine/widgets/display/action_panel.lua
local ActionPanel = setmetatable({}, {__index = BaseWidget})

function ActionPanel:new(x, y)
    local self = setmetatable(BaseWidget.new(x, y, 576, 96), {__index = ActionPanel})
    
    self.actions = {
        "weapon1", "weapon2", "armor", "skill",
        "walk", "run", "sneak", "fly"
    }
    
    self.buttons = {}
    self.selectedAction = "walk"  -- Default
    
    -- Create buttons in 2 rows
    for i, action in ipairs(self.actions) do
        local row = (i <= 4) and 0 or 1
        local col = ((i - 1) % 4)
        local bx = x + col * 144
        local by = y + row * 48
        
        local button = ActionButton:new(bx, by, 144, 48, action)
        button.onClick = function() self:selectAction(action) end
        table.insert(self.buttons, button)
    end
    
    return self
end

function ActionPanel:selectAction(action)
    self.selectedAction = action
    
    -- Update button states
    for _, button in ipairs(self.buttons) do
        button.selected = (button.action == action)
    end
    
    print("[ActionPanel] Selected: " .. action)
end

function ActionPanel:getSelectedAction()
    return self.selectedAction
end

function ActionPanel:updateAvailability(unit)
    if not unit then return end
    
    for _, button in ipairs(self.buttons) do
        local available = actionSystem:isActionAvailable(unit, button.action)
        button:setEnabled(available)
    end
end
```

**Mouse Button Handling:**
```lua
-- engine/modules/battlescape.lua
function Battlescape:mousepressed(x, y, button)
    local tileX, tileY = self:screenToTile(x, y)
    
    if button == 1 then  -- Left mouse button
        self:handleLeftClick(tileX, tileY)
    elseif button == 2 then  -- Right mouse button
        self:handleRightClick(tileX, tileY)
    end
end

function Battlescape:handleLeftClick(tileX, tileY)
    -- Check if clicked on unit
    local unit = battlefield:getUnitAt(tileX, tileY)
    
    if unit and unit.team == "player" then
        -- Select unit
        unitSelection:selectUnit(unit)
        actionPanel:updateAvailability(unit)
        unitInfoPanel:setUnit(unit)
    else
        -- Show tile info
        local tile = battlefield:getTile(tileX, tileY)
        unitInfoPanel:setHoverInfo("Tile", tile:getDescription())
    end
end

function Battlescape:handleRightClick(tileX, tileY)
    local selectedUnit = unitSelection:getSelectedUnit()
    if not selectedUnit then return end
    
    local action = actionPanel:getSelectedAction()
    
    if actionSystem:isMovementAction(action) then
        -- Execute movement
        movementSystem:moveUnit(selectedUnit, tileX, tileY, action)
    else
        -- Execute combat action
        actionSystem:executeAction(selectedUnit, action, tileX, tileY)
    end
end
```

**Action Execution:**
```lua
-- engine/battle/systems/action_system.lua
local ActionSystem = {}

function ActionSystem:isActionAvailable(unit, action)
    if action == "weapon1" then
        return unit.weapon1 ~= nil and unit:hasAP(1) and unit.weapon1.ammo > 0
    elseif action == "weapon2" then
        return unit.weapon2 ~= nil and unit:hasAP(1) and unit.weapon2.ammo > 0
    elseif action == "armor" then
        return unit.armor.ability ~= nil and unit:hasAP(1) and unit:hasEnergy(unit.armor.ability.cost)
    elseif action == "skill" then
        return unit.skill ~= nil and unit:hasAP(unit.skill.apCost)
    elseif action == "walk" then
        return true
    elseif action == "run" then
        return unit.armor.moveModes.run and unit:hasEnergy(1)
    elseif action == "sneak" then
        return unit.armor.moveModes.sneak
    elseif action == "fly" then
        return unit.armor.moveModes.fly and unit:hasEnergy(1)
    end
    
    return false
end

function ActionSystem:executeAction(unit, action, targetX, targetY)
    if action == "weapon1" then
        self:fireWeapon(unit, unit.weapon1, targetX, targetY)
    elseif action == "weapon2" then
        self:fireWeapon(unit, unit.weapon2, targetX, targetY)
    elseif action == "armor" then
        self:useArmorAbility(unit, targetX, targetY)
    elseif action == "skill" then
        self:useSkill(unit, unit.skill, targetX, targetY)
    end
end

function ActionSystem:fireWeapon(unit, weapon, targetX, targetY)
    -- Check range, LOS, ammo, AP
    if not self:canFireAt(unit, weapon, targetX, targetY) then
        print("[ActionSystem] Cannot fire at target")
        return false
    end
    
    -- Use AP
    unit:useAP(1)
    
    -- Use ammo
    weapon.ammo = weapon.ammo - 1
    
    -- Execute shot
    fireSystem:fire(unit, weapon, targetX, targetY)
    
    return true
end
```

### Key Components
- **ActionPanel:** UI container for 8 action buttons
- **ActionButton:** Individual action button widget
- **ActionSystem:** Executes selected actions
- **Mouse Handling:** Separates LMB (select) and RMB (execute)
- **Availability System:** Enables/disables actions

### Dependencies
- Widget system (buttons, panels)
- Unit system (actions, resources)
- Combat system (weapons, abilities)
- Movement system (move modes)
- Input system (mouse buttons)

---

## Testing Strategy

### Unit Tests
- Action availability checking
- Button selection logic
- Mouse button detection
- Action execution validation

### Integration Tests
- Full combat flow (select → execute)
- All 8 actions functional
- Availability updates correctly

### Manual Testing Steps
1. Start battle, select unit
2. Click WEAPON_1 button → Selected
3. RMB on enemy → Fires weapon
4. Click ARMOR button → Selected
5. RMB on tile → Uses armor ability
6. Click WALK button → Selected
7. RMB on tile → Moves in walk mode
8. Click RUN button → Selected
9. RMB on tile → Moves in run mode
10. LMB on another unit → Selects unit
11. LMB on empty tile → Shows tile info
12. Test keyboard shortcuts (1-4, Q-R)
13. Test unavailable actions grayed out
14. Test visual feedback shows range/path

### Expected Results
- Clear separation of select vs execute
- All actions work correctly
- Intuitive and responsive UI
- No accidental actions
- Good visual feedback

---

## How to Run/Debug

### Running the Game
```bash
lovec "engine"
```

### Debug Output
```lua
print("[ActionPanel] Selected action: " .. action)
print("[ActionSystem] Executing " .. action .. " on " .. targetX .. ", " .. targetY)
print("[ActionSystem] Action available: " .. tostring(available))
print("[Mouse] Button: " .. button .. " at " .. tileX .. ", " .. tileY)
```

### Visual Debug
```lua
-- Show selected action
love.graphics.print("Action: " .. actionPanel:getSelectedAction(), 10, 110)

-- Show action range
if action == "weapon1" then
    love.graphics.circle("line", unit.x, unit.y, weapon.range * 24)
end
```

---

## Documentation Updates

### Files to Update
- [ ] `wiki/API.md` - Document action system
- [ ] `wiki/FAQ.md` - Explain action panel
- [ ] `engine/battle/systems/README.md` - Document action system
- [ ] `engine/widgets/display/README.md` - Document action panel

---

## Notes

**Design Philosophy:**
- LMB = Information/Selection (safe)
- RMB = Action/Execution (commitment)
- Radio buttons = Clear state (only one action)
- Visual feedback = Player knows what will happen

**Action Types:**
1. **Combat Actions:** Weapon 1, Weapon 2, Armor, Skill
2. **Movement Actions:** Walk, Run, Sneak, Fly

**Future Enhancements:**
- Action queuing (plan multiple actions)
- Undo last action
- Action confirmation dialog
- Action history log
- Custom action bindings

---

## Blockers

Need weapon and armor systems implemented.

---

## Review Checklist

- [ ] ActionPanel widget created
- [ ] ActionButton widget created
- [ ] 8 actions implemented
- [ ] Radio button behavior working
- [ ] LMB selection working
- [ ] RMB execution working
- [ ] Weapon actions working
- [ ] Armor ability working
- [ ] Skill action working
- [ ] Move modes working
- [ ] Availability checking working
- [ ] Visual feedback present
- [ ] Keyboard shortcuts working
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
