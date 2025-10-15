# Unit Medals and Awards System (Future Feature)

**Status:** Placeholder - Not Yet Implemented  
**Priority:** Low  
**Planned For:** Phase 4 Development

---

## Overview

Soldier medal and award system to track achievements, boost morale, and add narrative depth.

---

## Planned Features

### Medal Types
- **Combat Medals**: Kill counts, mission completion
- **Bravery Awards**: Morale under fire, rescue actions
- **Marksmanship**: Accuracy achievements
- **Service Medals**: Missions completed, time served
- **Special Commendations**: Unique achievements

### Mechanics
- Automatic medal awarding based on criteria
- Manual commendations by player
- Medal display on unit info screens
- Morale bonuses from medals
- Soldier biography/history

### Integration Points
- Post-mission awards ceremony
- Unit info panel medal display
- Debriefing screen medal notifications
- Soldier memorial for KIA units

---

## Implementation Plan

### Files to Create
- `shared/units/medals.lua` - Medal definitions and criteria
- `battlescape/logic/medal_system.lua` - Medal awarding logic
- `scenes/awards_ceremony_screen.lua` - Post-mission ceremony
- `widgets/display/medal_display.lua` - Medal UI component

### Data Files
- Medal definitions (name, description, criteria)
- Medal graphics and icons
- Award ceremony dialogues

---

## UI Mockups

```
Unit Info Panel:
┌────────────────────────────────┐
│ Sgt. John Smith                │
│ Kills: 15  Missions: 8         │
│                                │
│ Medals:                        │
│ 🏅 Bronze Star (2 missions)   │
│ 🎖️  Marksman (90% accuracy)   │
│ ⭐ Purple Heart (wounded)     │
└────────────────────────────────┘
```

---

**Note:** This is a placeholder. Implementation will begin after core personnel systems are complete.
