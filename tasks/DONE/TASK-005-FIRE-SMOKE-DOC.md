# TASK-005: Fire and Smoke Mechanics Documentation

**Status:** DONE  
**Created:** October 15, 2025  
**Completed:** October 15, 2025  
**Priority:** MEDIUM  
**Effort:** 10 hours

## Overview

Document fire and smoke environmental systems with mechanics, integration points, and debug controls.

## Completed Work

✅ Created `docs/systems/FIRE_SMOKE_MECHANICS.md` (334 lines)
- Complete fire system mechanics
- Smoke system with 3 intensity levels
- Integration with battlescape
- Debug controls and troubleshooting

## What Was Done

1. Extracted from `wiki/FIRE_SMOKE_MECHANICS.md`
2. Organized by system (Fire, Smoke, Integration)
3. Included API documentation
4. Created troubleshooting guide

## Fire System

- Binary state (on/off)
- 5 HP/turn damage
- 30% spread chance to neighbors
- Blocks movement (0 cost = impassable)
- +3 sight cost penalty

## Smoke System

- 3 intensity levels (Light/Medium/Heavy)
- +2/+4/+6 sight cost per level
- 33% dissipation chance per turn
- 20% spread from heavy smoke
- Tactical concealment mechanic

## Integration

- Initialization in battlescape:enter()
- Turn updates in battlescape:endTurn()
- Rendering in battlescape:draw()
- Debug F6/F7 hotkeys

## Testing

- ✅ All mechanics documented
- ✅ Code examples included
- ✅ Debug guide provided

## Documentation

- Location: `docs/systems/FIRE_SMOKE_MECHANICS.md`
- API reference: `docs/API.md`

---

**Document Version:** 1.0  
**Status:** COMPLETE - Systems Documentation
