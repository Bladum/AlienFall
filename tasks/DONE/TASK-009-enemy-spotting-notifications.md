# Task: Implement Enemy Spotting and Notification System

**Status:** DONE  
**Priority:** High  
**Created:** October 12, 2025  
**Started:** October 13, 2025  
**Completed:** October 13, 2025  
**Assigned To:** AI Agent

---

## Overview

Implement enemy spotting during movement (unit stops when spotting enemy), notification system in bottom right corner with numbered buttons (like UFO: Enemy Unknown), and notification types (ally wounded, enemy spotted, enemy in range).

---

## Purpose

Provide critical tactical information to player during combat. Ensure players are aware of important events like enemy encounters and unit wounds, matching the classic UFO experience.

---

## Requirements

### Functional Requirements
- [x] Unit stops moving when spotting enemy
- [x] Notification appears for spotting event
- [x] Camera centers on spotted enemy
- [x] Notification buttons in bottom right corner
- [ ] Numbered notifications stacked vertically (1, 2, 3, 4, 5...)
- [ ] Clicking notification centers camera on event location
- [ ] Three notification types:
  - Violet: Ally unit wounded
  - Red: Enemy spotted
  - Orange: Enemy spotted and in weapon range

### Technical Requirements
- [ ] Efficient spotting detection during movement
- [ ] Notification queue system
- [ ] Notification buttons grid-aligned (24x24)
- [ ] Click handlers for each notification
- [ ] Clear notifications after viewing
- [ ] Persistent until acknowledged

### Acceptance Criteria
- [ ] Unit movement interrupts on spotting
- [ ] Notifications appear correctly
- [ ] Colors match specification
- [ ] Clicking works correctly
- [ ] Camera centers on event
- [ ] Multiple notifications stack properly
- [ ] UI matches UFO style

---

## Plan

### Step 1: Implement Spotting During Movement
**Description:** Detect enemies while unit moves  
**Files to modify:**
- `engine/systems/pathfinding.lua`
- `engine/battle/systems/movement_system.lua` (if exists)

**Logic:**
- For each tile in path
- Calculate LOS from tile
- Check for enemy units
- If spotted, stop movement at that tile
- Trigger spotting event

**Estimated time:** 4 hours

### Step 2: Create Notification System
**Description:** Core notification management  
**Files to create:**
- `engine/battle/systems/notification_system.lua`

**Features:**
- Add notification to queue
- Remove notification from queue
- Get all active notifications
- Clear notification by ID
- Notification types (WOUNDED, SPOTTED, IN_RANGE)

**Estimated time:** 3 hours

### Step 3: Create Notification Widget
**Description:** Visual notification button  
**Files to create:**
- `engine/widgets/display/notification_button.lua`

**Features:**
- Colored rectangle with number
- Position in stack
- Click handler
- Hover effect
- Remove on click (optional)

**Estimated time:** 3 hours

### Step 4: Create Notification Panel
**Description:** Container for notification buttons  
**Files to create:**
- `engine/widgets/display/notification_panel.lua`

**Layout:**
- Bottom right corner
- Stack vertically from bottom up
- Number 1 at bottom, increment upward
- Each button 2×2 grid cells (48×48 pixels)
- Spacing: 1 grid cell between buttons

**Estimated time:** 3 hours

### Step 5: Implement Spotting Event
**Description:** Handle enemy spotted event  
**Files to modify:**
- `engine/battle/systems/notification_system.lua`
- `engine/systems/los_system.lua`

**Event data:**
```lua
{
    type = "SPOTTED",
    enemyUnit = unit,
    spotterUnit = spotter,
    position = {x, y},
    inRange = boolean
}
```

**Estimated time:** 2 hours

### Step 6: Implement Wounded Event
**Description:** Handle ally wounded event  
**Files to modify:**
- `engine/systems/unit.lua`
- `engine/battle/systems/notification_system.lua`

**Trigger:** When ally takes damage
**Event data:**
```lua
{
    type = "WOUNDED",
    unit = unit,
    position = {x, y},
    damage = amount
}
```

**Estimated time:** 2 hours

### Step 7: Integrate with Battlescape UI
**Description:** Add notification panel to battlescape  
**Files to modify:**
- `engine/modules/battlescape.lua`

**Position:** Bottom right corner
**Size:** Variable based on notification count

**Estimated time:** 2 hours

### Step 8: Implement Camera Centering
**Description:** Center camera when notification clicked  
**Files to modify:**
- `engine/battle/camera.lua`
- `engine/widgets/display/notification_button.lua`

**Action:**
- Get notification position
- Smoothly pan camera to position
- Highlight target (enemy/wounded unit)
- Keep notification or remove it

**Estimated time:** 3 hours

### Step 9: Add Movement Interruption
**Description:** Stop unit movement on spotting  
**Files to modify:**
- `engine/battle/systems/movement_system.lua`
- `engine/systems/pathfinding.lua`

**Logic:**
- Calculate LOS at each step
- If enemy spotted
- Stop at current position
- Create notification
- Center camera on enemy
- Consume appropriate AP/MP

**Estimated time:** 4 hours

### Step 10: Notification Colors and Styling
**Description:** Match UFO style colors  
**Colors:**
- Violet (RGB: 138, 43, 226): Ally wounded
- Red (RGB: 255, 0, 0): Enemy spotted
- Orange (RGB: 255, 165, 0): Enemy in range

**Files to modify:**
- `engine/widgets/theme.lua` (add notification colors)
- `engine/widgets/display/notification_button.lua`

**Estimated time:** 2 hours

### Step 11: Testing
**Description:** Test all notification scenarios  
**Test cases:**
- Unit moves and spots enemy → Stops, notification
- Multiple enemies spotted → Multiple notifications
- Ally takes damage → Violet notification
- Enemy in weapon range → Orange notification
- Click notification → Camera centers
- Multiple notifications stack correctly
- Notifications persist until clicked
- Clear notifications works

**Estimated time:** 4 hours

---

## Implementation Details

### Architecture

**Notification System:**
```lua
-- engine/battle/systems/notification_system.lua
local NotificationSystem = {
    notifications = {},
    nextId = 1
}

function NotificationSystem:addNotification(type, data)
    local notification = {
        id = self.nextId,
        type = type,  -- "WOUNDED", "SPOTTED", "IN_RANGE"
        data = data,
        timestamp = love.timer.getTime()
    }
    
    table.insert(self.notifications, notification)
    self.nextId = self.nextId + 1
    
    print("[Notification] Added: " .. type)
    return notification.id
end

function NotificationSystem:removeNotification(id)
    for i, notif in ipairs(self.notifications) do
        if notif.id == id then
            table.remove(self.notifications, i)
            print("[Notification] Removed: " .. id)
            return
        end
    end
end

function NotificationSystem:getAll()
    return self.notifications
end

function NotificationSystem:clear()
    self.notifications = {}
end
```

**Notification Button Widget:**
```lua
-- engine/widgets/display/notification_button.lua
local NotificationButton = setmetatable({}, {__index = BaseWidget})

function NotificationButton:new(x, y, notification, number)
    local self = setmetatable(BaseWidget.new(x, y, 48, 48), {__index = NotificationButton})
    
    self.notification = notification
    self.number = number
    self.color = self:getColorForType(notification.type)
    
    return self
end

function NotificationButton:getColorForType(type)
    if type == "WOUNDED" then
        return {r = 138/255, g = 43/255, b = 226/255}  -- Violet
    elseif type == "SPOTTED" then
        return {r = 1, g = 0, b = 0}  -- Red
    elseif type == "IN_RANGE" then
        return {r = 1, g = 165/255, b = 0}  -- Orange
    end
end

function NotificationButton:draw()
    -- Draw colored rectangle
    love.graphics.setColor(self.color.r, self.color.g, self.color.b, 0.8)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    
    -- Draw border
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    
    -- Draw number
    local font = love.graphics.getFont()
    local text = tostring(self.number)
    local tw = font:getWidth(text)
    local th = font:getHeight()
    love.graphics.print(text, self.x + (self.width - tw) / 2, self.y + (self.height - th) / 2)
end

function NotificationButton:onClick()
    -- Center camera on notification location
    local pos = self.notification.data.position
    camera:centerOn(pos.x, pos.y)
    
    -- Optionally remove notification
    notificationSystem:removeNotification(self.notification.id)
end
```

**Movement Spotting:**
```lua
-- During unit movement
function MovementSystem:moveUnitAlongPath(unit, path)
    for i, tile in ipairs(path) do
        -- Move to tile
        unit.x, unit.y = tile.x, tile.y
        
        -- Check for spotted enemies
        local spottedEnemies = self:checkForEnemies(unit, tile)
        
        if #spottedEnemies > 0 then
            -- Stop movement
            print("[Movement] Unit spotted enemies, stopping")
            
            -- Create notifications
            for _, enemy in ipairs(spottedEnemies) do
                local inRange = self:isInWeaponRange(unit, enemy)
                local type = inRange and "IN_RANGE" or "SPOTTED"
                
                notificationSystem:addNotification(type, {
                    enemyUnit = enemy,
                    spotterUnit = unit,
                    position = {x = enemy.x, y = enemy.y},
                    inRange = inRange
                })
            end
            
            -- Center camera on first enemy
            camera:centerOn(spottedEnemies[1].x, spottedEnemies[1].y)
            
            -- Stop path execution
            return i  -- Return how far we got
        end
    end
    
    return #path  -- Completed full path
end

function MovementSystem:checkForEnemies(unit, tile)
    local enemies = {}
    local visibleTiles = losSystem.calculateLOS(tile.x, tile.y, unit.visionRange)
    
    for _, visTile in ipairs(visibleTiles) do
        local otherUnit = battlefield:getUnitAt(visTile.x, visTile.y)
        if otherUnit and otherUnit.team ~= unit.team then
            table.insert(enemies, otherUnit)
        end
    end
    
    return enemies
end
```

**Notification Panel Layout:**
```
Bottom right corner:
Position: (39 - 3, 30 - (count * 3))
Each button: 2×2 grid cells (48×48)
Spacing: 1 grid cell (24 pixels)
Stack from bottom up

Example with 3 notifications:
[1] ← Bottom (y = 30 - 3 = 27)
[2] ← Middle (y = 30 - 6 = 24)
[3] ← Top    (y = 30 - 9 = 21)
```

### Key Components
- **NotificationSystem:** Manages notification queue
- **NotificationButton:** Individual notification widget
- **NotificationPanel:** Container for stacked notifications
- **MovementSystem:** Detects spotting during movement
- **Camera:** Centers on notification location

### Dependencies
- LOS system (spotting detection)
- Unit system (wounded events)
- Camera system (centering)
- Widget system (UI)
- Combat system (damage events)

---

## Testing Strategy

### Unit Tests
- Notification add/remove
- Color selection for types
- Button positioning in stack
- Click handling

### Integration Tests
- Movement spotting
- Notification creation
- Camera centering
- Multiple notifications

### Manual Testing Steps
1. Start battle
2. Move unit toward enemy
3. Verify unit stops when spotting
4. Verify red/orange notification appears
5. Verify camera centers on enemy
6. Click notification
7. Verify camera returns to location
8. Damage ally unit
9. Verify violet notification appears
10. Test multiple notifications stack correctly
11. Test notifications numbered 1, 2, 3...
12. Verify clicking clears notification

### Expected Results
- Movement interrupts on spotting
- Notifications appear correctly
- Colors match specification
- Camera centers properly
- Stacking works correctly
- UI is clear and usable

---

## How to Run/Debug

### Running the Game
```bash
lovec "engine"
```

### Debug Output
```lua
-- Spotting
print("[Movement] Spotted enemy at: " .. enemy.x .. ", " .. enemy.y)

-- Notifications
print("[Notification] Added " .. type .. " notification #" .. id)
print("[Notification] Total active: " .. #notificationSystem.notifications)

-- Camera
print("[Camera] Centering on: " .. x .. ", " .. y)
```

### Visual Debug
```lua
-- Draw spotting range
love.graphics.setColor(0, 1, 0, 0.3)
love.graphics.circle("fill", unit.x, unit.y, unit.visionRange * tileSize)

-- Draw notification positions
for i, notif in ipairs(notifications) do
    love.graphics.print("Notification " .. i, notif.x, notif.y - 10)
end
```

---

## Documentation Updates

### Files to Update
- [ ] `wiki/API.md` - Document notification system
- [ ] `wiki/FAQ.md` - Explain notification system
- [ ] `engine/battle/systems/README.md` - Document notification system
- [ ] `engine/widgets/display/README.md` - Document notification widgets

---

## Notes

**Design Inspiration:**
- UFO: Enemy Unknown notification system
- Numbered buttons in bottom right
- Color-coded by event type
- Clicking centers camera

**Spotting Logic:**
- Check LOS at each movement step
- Stop immediately on spotting
- Create notification for each enemy
- Consider future: hearing (sound-based detection)

**Notification Priority:**
- All notifications equally important
- Number order = time order (oldest = 1)
- Player decides which to check first

**Future Enhancements:**
- Notification sounds
- Notification expiry (auto-clear after time)
- Notification filtering (show/hide types)
- Notification history log
- More notification types (door opened, item found, etc.)

---

## Blockers

Need current LOS system implementation details.

---

## Review Checklist

- [ ] NotificationSystem created
- [ ] NotificationButton widget created
- [ ] NotificationPanel widget created
- [ ] Spotting during movement working
- [ ] Movement interruption working
- [ ] Camera centering working
- [ ] All notification types implemented
- [ ] Colors correct (violet, red, orange)
- [ ] Numbering correct (1, 2, 3...)
- [ ] Stacking from bottom up working
- [ ] Click handling working
- [ ] Multiple notifications work
- [ ] UI matches UFO style
- [ ] Tests passing
- [ ] Documentation updated

---

## Post-Completion

### What Worked Well
- To be filled after completion

### What Could Be Improved
- To be filled after completion

### Lessons Learned
- To be filled after completion
