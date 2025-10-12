# TASK-001: Battlescape Complete Refactor

## Overview and Purpose
Complete refactoring of battlescape module to meet all requirements: proper resolution handling, GUI layout, fog of war, terrain system, movement system, day/night cycle, teams/sides system, and unit spawning.

## Requirements

### Functional Requirements
1. Game runs at 960x720 (40x30 grid, 24px tiles) with global fullscreen scaling
2. Left GUI: 10x30 blocks split into 3 sections (10x10 each)
   - Top: Active minimap with viewport rectangle
   - Middle: Info panel
   - Bottom: 3x3 button matrix container
3. Fog of war for active team only
4. Space bar switches teams and centers camera on first unit
5. TOML-based terrain system (no hardcoded tilesets)
6. Fixed movement range matching pathfinding
7. Rotation costs 1MP, all actions check MP/AP
8. Day/night toggle (F4) with different sight ranges and blue tint
9. TEAMS assign units, SIDES determine combat/vision sharing
10. Units spawn with random facing, not on walls, 60x60 map

### Technical Requirements
- Global scaling in main.lua for fullscreen
- Mouse coordinate adjustment for scaling
- Proper grid snapping for all UI elements
- TOML configuration loader for terrain
- Separate day/night stats for units
- FOW recalculation on team switch and day/night toggle

### Acceptance Criteria
- [ ] Game maintains 960x720 resolution in windowed mode
- [ ] F12 toggles fullscreen with proper scaling
- [ ] GUI exactly matches specification
- [ ] Minimap is clickable and shows viewport
- [ ] FOW displays correctly for active team
- [ ] Space switches teams and centers camera
- [ ] All terrain loaded from TOML files
- [ ] Movement range equals actual path
- [ ] Rotation costs 1MP
- [ ] F4 toggles day/night
- [ ] Units spawn correctly

## Detailed Plan

### Step 1: Resolution and Scaling (DONE)
- Added global SCALE variable in main.lua
- Implemented fullscreen toggle (F12)
- Added mouse coordinate scaling
- Time: 30 minutes

### Step 2: Redesign Battlescape GUI
- Remove all existing GUI elements
- Create 10x30 left panel
- Implement active minimap with viewport
- Create info panel
- Create 3x3 button container at bottom
- Time: 2 hours

### Step 3: Implement Fog of War System
- Create FOW manager
- Calculate visibility for active team
- Render FOW overlay
- Update on team switch
- Time: 1.5 hours

### Step 4: Terrain TOML System
- Create terrain class structure
- Implement TOML loader
- Convert existing terrain to TOML
- Update battlefield to use terrain system
- Time: 2 hours

### Step 5: Fix Movement System
- Recalculate movement range to match pathfinding
- Implement rotation cost (1MP)
- Add MP/AP checks for all actions
- Time: 1 hour

### Step 6: Day/Night Cycle
- Add day/night state
- Implement sight range changes
- Add blue tint shader for night
- Add F4 toggle
- Recalculate FOW on toggle
- Time: 1.5 hours

### Step 7: Teams and Sides System
- Refactor team manager for SIDES
- Implement vision sharing between allies
- Add team switching with Space
- Center camera on first unit
- Time: 1 hour

### Step 8: Fix Unit Spawning
- Add random facing direction
- Implement wall check before spawning
- Ensure 60x60 map size
- Time: 30 minutes

## Implementation Details

### Architecture Changes
- main.lua: Global scaling system
- battlescape.lua: Complete GUI refactor
- fog_of_war.lua: New FOW manager
- terrain_loader.lua: TOML-based terrain system
- day_night.lua: Day/night state manager

### Components
- Minimap widget with click handling
- Info panel with unit stats
- Button container for actions
- FOW overlay renderer
- Terrain configuration system

### Dependencies
- TOML parser library
- Existing widget system
- LOS system
- Pathfinding system

## Testing Strategy

### Unit Tests
- Test scaling calculations
- Test mouse coordinate conversion
- Test FOW visibility calculations
- Test TOML terrain loading
- Test movement range calculations

### Integration Tests
- Test fullscreen toggle
- Test team switching
- Test day/night toggle
- Test minimap clicks
- Test unit spawning

### Manual Testing Steps
1. Run game in windowed mode (960x720)
2. Toggle F12 and verify fullscreen scaling
3. Click minimap and verify camera moves
4. Press Space and verify team switch + camera center
5. Press F4 and verify day/night toggle
6. Select unit and verify movement range
7. Rotate unit and verify 1MP cost
8. Try actions without MP/AP and verify blocked

## How to Run/Debug
```bash
lovec "engine"
```
Watch console for:
- Resolution confirmation
- GUI initialization
- FOW calculations
- Terrain loading
- Team switching
- Day/night toggles

## Documentation Updates
- wiki/API.md: Add terrain system, FOW system, day/night APIs
- wiki/FAQ.md: Explain teams vs sides, day/night mechanics
- wiki/DEVELOPMENT.md: Document TOML terrain format

## Review Checklist
- [ ] All 10 requirements implemented
- [ ] No console errors
- [ ] All tests passing
- [ ] GUI grid-aligned
- [ ] Performance acceptable
- [ ] Documentation updated

## Progress Log
- 2025-10-11: Started task, implemented resolution scaling in main.lua

## What Worked Well
(To be filled after completion)

## Lessons Learned
(To be filled after completion)
