# Mission Launch UI Mockups

> **Status**: Design Mockup
> **Last Updated**: 2025-10-31
> **Related Systems**: CRAFT_CAPACITY_MODEL.md, SquadSystem.lua
> **Purpose**: UI flow for squad composition and mission deployment

## Overview

The mission launch UI guides players through selecting units, assigning pilots, and validating deployment requirements. The flow ensures capacity constraints are respected while providing clear feedback on violations.

**UI Philosophy**: Clear validation feedback, drag-and-drop simplicity, progressive disclosure of complex options.

---

## Screen 1: Mission Selection & Squad Setup

### Layout

```
┌─────────────────────────────────────────────────────────────┐
│ MISSION: Terror Site Cleanup (Difficulty: Hard)            │
│ Location: Urban District, Population: High                 │
│ Requirements: 6 soldiers, 1-2 transports                   │
│ Time Limit: 48 hours                                       │
├─────────────────────────────────────────────────────────────┤
│ AVAILABLE UNITS                    │ SELECTED SQUAD         │
│ ┌─────────────────────────────────┐ │ ┌───────────────────┐ │
│ │ ⚔️ Sgt. Kelly (Leader)         │ │ │                   │ │
│ │   Health: 100%                 │ │ │                   │ │
│ │   Equipment: Assault Rifle     │ │ │                   │ │
│ │                                 │ │ │                   │ │
│ │ 🩹 Dr. Smith (Medic)           │ │ │                   │ │
│ │   Health: 95%                  │ │ │   Drag units here │ │
│ │   Equipment: SMG + Medkit      │ │ │                   │ │
│ │                                 │ │ │                   │ │
│ │ 🔫 Pvt. Johnson (Rifleman)     │ │ │                   │ │
│ │   Health: 100%                 │ │ │                   │ │
│ │   Equipment: Rifle + Grenades  │ │ │                   │ │
│ │                                 │ │ │                   │ │
│ │ [More units...]                 │ │ │                   │ │
│ └─────────────────────────────────┘ │ └───────────────────┘ │
├─────────────────────────────────────────────────────────────┤
│ SQUAD STATUS                                              │
│ ├─ Composition: 0/6 units selected                        │
│ ├─ Leader: Not assigned                                   │
│ ├─ Combat: 0/3-5 units                                    │
│ ├─ Support: 0/0-2 units                                   │
│ └─ Specialist: 0/0-2 units                                │
├─────────────────────────────────────────────────────────────┤
│ [← Back to Geoscape]           [Next: Pilot Assignment →] │
└─────────────────────────────────────────────────────────────┘
```

### Interaction Flow

1. **Unit Selection**: Click units in left panel to view details
2. **Squad Building**: Drag units from left to right panel
3. **Real-time Validation**: Status panel updates as squad changes
4. **Role Assignment**: Units auto-assign roles based on class/traits
5. **Progression**: "Next" button enabled when squad composition is valid

### Validation States

**Valid Squad**:
- Status panel shows green checkmarks
- "Next" button enabled
- Composition counters in acceptable ranges

**Invalid Squad**:
- Status panel shows red X marks
- "Next" button disabled
- Error messages explain violations

---

## Screen 2: Pilot & Craft Assignment

### Layout

```
┌─────────────────────────────────────────────────────────────┐
│ PILOT & CRAFT ASSIGNMENT                                   │
│ Squad: 6 soldiers selected (within capacity)               │
├─────────────────────────────────────────────────────────────┤
│ AVAILABLE CRAFTS                  │ ASSIGNED CRAFTS        │
│ ┌─────────────────────────────────┐ │ ┌───────────────────┐ │
│ │ 🚁 Skyranger #1                │ │ │                   │ │
│ │   Type: Transport              │ │ │                   │ │
│ │   Capacity: 8 soldiers         │ │ │                   │ │
│ │   Status: Ready                │ │ │                   │ │
│ │                                 │ │ │                   │ │
│ │ 🚁 Skyranger #2                │ │ │                   │ │
│ │   Type: Transport              │ │ │ │                   │ │
│ │   Capacity: 8 soldiers         │ │ │ │                   │ │
│ │   Status: Ready                │ │ │ │                   │ │
│ └─────────────────────────────────┘ │ └───────────────────┘ │
├─────────────────────────────────────────────────────────────┤
│ AVAILABLE PILOTS                  │ PILOT ASSIGNMENTS      │
│ ┌─────────────────────────────────┐ │ ┌───────────────────┐ │
│ │ 👨‍✈️ Capt. Rodriguez           │ │ │ Skyranger #1:      │ │
│ │   Piloting: 12 (+8% speed)     │ │ │ ├─ Primary:        │ │
│ │   Fatigue: 20%                 │ │ │ ├─ Copilot:        │ │
│ │   Status: Ready                │ │ │                   │ │
│ │                                 │ │ │ Skyranger #2:      │ │
│ │ 👨‍✈️ Lt. Chen                  │ │ │ ├─ Primary:        │ │
│ │   Piloting: 10 (+4% speed)     │ │ │ ├─ Copilot:        │ │
│ │   Fatigue: 45% ⚠️             │ │ │                   │ │
│ │   Status: Stressed             │ │ │                   │ │
│ │                                 │ │ │                   │ │
│ │ [More pilots...]                │ │ │                   │ │
│ └─────────────────────────────────┘ │ └───────────────────┘ │
├─────────────────────────────────────────────────────────────┤
│ ASSIGNMENT STATUS                                         │
│ ├─ Craft Capacity: 16 soldiers (2 crafts × 8)            │
│ ├─ Squad Size: 6 soldiers ✓                               │
│ ├─ Pilots Required: 4 (2 crafts × 2 pilots)              │
│ ├─ Pilots Assigned: 4 ✓                                   │
│ └─ Fuel Check: Sufficient for mission ✓                   │
├─────────────────────────────────────────────────────────────┤
│ [← Back to Squad Setup]         [Next: Equipment Check →] │
└─────────────────────────────────────────────────────────────┘
```

### Interaction Flow

1. **Craft Selection**: Click crafts to assign to mission
2. **Pilot Assignment**: Drag pilots to craft positions (Primary/Copilot)
3. **Auto-Suggestions**: System suggests optimal pilot assignments
4. **Status Updates**: Real-time validation of capacity and requirements
5. **Warning Display**: Highlight stressed/injured pilots with warnings

### Pilot Status Indicators

**Ready**: Green checkmark, normal bonuses
**Stressed**: Yellow warning, reduced bonuses
**Injured**: Red X, cannot assign
**Fatigued**: Orange triangle, penalty applied

---

## Screen 3: Equipment & Capacity Validation

### Layout

```
┌─────────────────────────────────────────────────────────────┐
│ EQUIPMENT & CAPACITY VALIDATION                            │
│ Final deployment check for 6 soldiers                     │
├─────────────────────────────────────────────────────────────┤
│ CAPACITY OVERVIEW                                         │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ Skyranger #1 (4 soldiers + 2 pilots = 6/10 capacity)   │ │
│ │ ├─ Primary: Capt. Rodriguez (Piloting 12)             │ │
│ │ ├─ Copilot: Lt. Chen (Piloting 10) ⚠️ Stressed        │ │
│ │ ├─ Soldiers: Sgt. Kelly, Pvt. Johnson, Pvt. Davis     │ │
│ │ └─ Cargo: 45/100 kg used                               │ │
│ │                                                         │ │
│ │ Skyranger #2 (2 soldiers + 2 pilots = 4/10 capacity)   │ │
│ │ ├─ Primary: Sgt. Williams (Piloting 8)                │ │
│ │ ├─ Copilot: Cpl. Garcia (Piloting 9)                  │ │
│ │ ├─ Soldiers: Dr. Smith, Pvt. Miller                   │ │
│ │ └─ Cargo: 35/100 kg used                               │ │
│ └─────────────────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────────────────┤
│ EQUIPMENT CHECK                                           │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ ⚔️ Sgt. Kelly (STR 7, Capacity: 70kg)                  │ │
│ │ ├─ Primary: Assault Rifle (4kg)                        │ │
│ │ ├─ Secondary: Pistol (2kg)                             │ │
│ │ ├─ Armor: Combat Vest (8kg)                            │ │
│ │ ├─ Equipment: Medkit (3kg), Grenades (2kg)             │ │
│ │ └─ Total: 19kg ✓                                       │ │
│ │                                                         │ │
│ │ 🩹 Dr. Smith (STR 5, Capacity: 50kg)                   │ │
│ │ ├─ Primary: SMG (3kg)                                  │ │
│ │ ├─ Secondary: Pistol (2kg)                             │ │
│ │ ├─ Armor: Light Vest (5kg)                             │ │
│ │ ├─ Equipment: Medkit (3kg), Medkit (3kg)               │ │
│ │ └─ Total: 16kg ✓                                       │ │
│ │                                                         │ │
│ │ 🔫 Pvt. Johnson (STR 6, Capacity: 60kg)                │ │
│ │ ├─ Primary: Rifle (5kg)                                │ │
│ │ ├─ Secondary: None                                     │ │
│ │ ├─ Armor: Combat Vest (8kg)                            │ │
│ │ ├─ Equipment: Grenades (2kg), Extra Ammo (3kg)         │ │
│ │ └─ Total: 18kg ✓                                       │ │
│ │                                                         │ │
│ │ [More units...]                                         │ │
│ └─────────────────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────────────────┤
│ VALIDATION SUMMARY                                        │
│ ├─ ✅ Squad composition valid                             │
│ ├─ ✅ Pilot assignments complete                          │
│ ├─ ✅ Craft capacity sufficient                           │
│ ├─ ✅ Equipment within weight limits                      │
│ ├─ ⚠️  Pilot stress warning (Lt. Chen)                   │
│ └─ Estimated flight time: 2.5 hours                      │
├─────────────────────────────────────────────────────────────┤
│ [← Back to Pilot Assignment]           [LAUNCH MISSION]   │
└─────────────────────────────────────────────────────────────┘
```

### Interaction Flow

1. **Capacity Review**: Examine craft loading and distribution
2. **Equipment Audit**: Check individual unit weight limits
3. **Warning Review**: Address any flagged issues
4. **Final Confirmation**: Launch button enabled when all validations pass

### Warning System

**Types of Warnings**:
- **Overweight Units**: Red highlight, prevent launch
- **Stressed Pilots**: Yellow warning, allow launch with penalty
- **Suboptimal Load**: Blue info, suggest redistribution
- **Fuel Warnings**: Orange alert, may strand craft

**Resolution Options**:
- **Remove Equipment**: Click items to unequip
- **Redistribute Units**: Drag between crafts
- **Replace Pilot**: Swap stressed pilot for rested one
- **Accept Penalty**: Launch despite warnings

---

## Error States & Messages

### Squad Composition Errors

```
❌ ERROR: Squad Composition Invalid

Your squad has the following issues:
• Missing leader (exactly 1 required)
• Too many combat units (5 maximum, you have 6)
• No support units (at least 1 recommended)

Please adjust your squad composition before proceeding.
```

### Pilot Assignment Errors

```
❌ ERROR: Insufficient Pilots

Mission requires 4 pilots but only 3 are assigned:
• Skyranger #1: Missing copilot
• Skyranger #2: Missing primary pilot

Available pilots: Capt. Rodriguez, Lt. Chen, Sgt. Williams
Suggested: Assign Lt. Chen as Skyranger #1 copilot
```

### Capacity Errors

```
❌ ERROR: Craft Capacity Exceeded

Squad size (8 soldiers) exceeds available capacity (8 soldiers):
• Skyranger #1: 4/8 capacity used
• Skyranger #2: 4/8 capacity used
• Total capacity: 8 soldiers

Solutions:
• Remove 2 soldiers from squad
• Add a third transport craft
• Split into multiple missions
```

### Equipment Errors

```
❌ ERROR: Equipment Overload

The following units exceed weight capacity:
• Pvt. Johnson (STR 6, 60kg limit)
  - Current load: 75kg (15kg overweight)
  - Suggested fixes:
    • Remove extra ammo (-3kg)
    • Remove grenades (-2kg)
    • Switch to lighter armor (-3kg)

Mission cannot launch until overloads are resolved.
```

---

## Progressive Disclosure

### Basic Mode (New Players)

- Simplified squad selection (auto-suggest compositions)
- Hidden advanced options (pilot stress, weight calculations)
- Prominent validation messages with suggested fixes
- Step-by-step wizard flow

### Advanced Mode (Experienced Players)

- Full control over all assignments
- Detailed statistics and bonuses
- Manual optimization options
- Quick-launch shortcuts for repeated compositions

---

## Mobile/Tablet Considerations

### Responsive Layout

**Small Screens**:
- Vertical stacking of panels
- Collapsible sections
- Swipe gestures for assignment
- Simplified status indicators

**Touch Interactions**:
- Large drag handles
- Tap-to-select for assignment
- Pinch-to-zoom on details
- Swipe-to-dismiss warnings

---

## Accessibility Features

### Keyboard Navigation

- Tab order through all interactive elements
- Arrow keys for pilot/craft selection
- Enter to assign, Delete to remove
- Number keys for quick unit selection

### Screen Reader Support

- Descriptive labels for all UI elements
- Status announcements for validation changes
- Error message prioritization
- Progress indicators for multi-step processes

---

## Performance Considerations

### UI Updates

- Validation runs on change, not continuously
- Lazy loading of unit/pilot details
- Cached calculations for capacity checks
- Progressive rendering for large unit lists

### Memory Management

- Release unused unit data after assignment
- Stream large equipment lists
- Cache validation results
- Cleanup on screen transitions</content>
<parameter name="filePath">c:\Users\tombl\Documents\Projects\design\mechanics\MISSION_LAUNCH_UI_MOCKUPS.md
