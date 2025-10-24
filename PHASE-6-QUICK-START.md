═══════════════════════════════════════════════════════════════════════════════
🚀 PHASE 6 QUICK START GUIDE - FIRST STEPS
═══════════════════════════════════════════════════════════════════════════════

**TASK-025 Phase 6: Rendering & UI - Quick Start for Next Developer**

---

## BEFORE YOU START

**Prerequisites**:
✅ Phase 5 complete and verified (Exit Code 0, 36 tests passing)
✅ Love2D 12+ installed with console enabled
✅ All documentation read and understood
✅ Git ready for commits

**Estimated Time**: 25 hours
**Expected Output**: 750+ lines, 15+ tests, 0 errors

---

## STEP 0: VERIFY PHASE 5 (10 minutes)

```bash
# Start game
lovec engine

# Should see:
✓ No errors in console
✓ Exit Code 0
✓ Game runs without crashing

# Run tests
lovec tests/runners

# Should see:
✓ 36 tests total
✓ 100% pass rate
✓ No lint errors
```

If all passes, you're ready! ✅

---

## STEP 1: CREATE MODULE 6.1 (RENDERER)

**Time**: ~8 hours | **Size**: ~120 lines | **Priority**: CRITICAL

### Quick Checklist

```
[ ] Create: engine/geoscape/rendering/geoscape_renderer.lua
[ ] Implement: initialize(), update(), draw()
[ ] Implement: drawHex(), hexToPixel()
[ ] Implement: Camera system (pan/zoom)
[ ] Verify: <10ms per-frame performance
[ ] Test: 3 tests passing
[ ] Lint: 0 errors
[ ] Code: Exit Code 0
```

### Key Code Snippet

```lua
local GeoscapeRenderer = {}

function GeoscapeRenderer:initialize(world, w, h)
  self.world = world
  self.camera_x = 40
  self.camera_y = 20
  self.zoom = 1.0
  return self
end

function GeoscapeRenderer:draw()
  love.graphics.clear(0.1, 0.15, 0.2)
  -- Loop through all 80x40 hexes
  for q = 0, 79 do
    for r = 0, 39 do
      self:drawHex(q, r)
    end
  end
end
```

### Test Template

```lua
describe("GeoscapeRenderer", function()
  it("initializes correctly", function()
    local renderer = GeoscapeRenderer:initialize(world, 1280, 720)
    assert.is_not_nil(renderer)
  end)

  it("performs camera pan/zoom", function()
    renderer:pan(20, 0)
    renderer:zoom(1.5)
    -- Verify camera position changed
  end)

  it("renders without errors", function()
    renderer:draw()
    -- Should not crash
  end)
end)
```

---

## STEP 2: CREATE MODULE 6.2 (CALENDAR UI)

**Time**: ~4 hours | **Size**: ~100 lines | **Priority**: CRITICAL

### Quick Checklist

```
[ ] Create: engine/geoscape/ui/calendar_display.lua
[ ] Implement: initialize(), draw()
[ ] Implement: formatDate(), getDayOfWeek()
[ ] Implement: getSeasonColor()
[ ] Wire to: CampaignManager.calendar
[ ] Test: 3 tests passing
[ ] Lint: 0 errors
```

### Key Code Snippet

```lua
function CalendarDisplay:draw()
  -- Background panel
  love.graphics.setColor(0.1, 0.1, 0.1, 0.8)
  love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

  -- Date display
  local date = self:formatDate()
  love.graphics.setColor(0.8, 0.8, 1)
  love.graphics.printf(date, self.x + 5, self.y + 25, self.width - 10)
end
```

---

## STEP 3: CREATE MODULE 6.3 (MISSION PANEL)

**Time**: ~5 hours | **Size**: ~120 lines | **Priority**: HIGH

### Quick Checklist

```
[ ] Create: engine/geoscape/ui/mission_faction_panel.lua
[ ] Implement: drawMissionEntry()
[ ] Implement: drawFactionEntry()
[ ] Implement: Scrolling (PageUp/PageDown)
[ ] Test: 3 tests passing
[ ] Lint: 0 errors
```

### Color Coding

```lua
-- Threat levels
if threat <= 2 then
  color = {0.3, 1, 0.3}    -- Green
elseif threat <= 4 then
  color = {1, 1, 0.3}      -- Yellow
else
  color = {1, 0.3, 0.3}    -- Red
end
```

---

## STEP 4: CREATE MODULE 6.4 (INPUT HANDLER)

**Time**: ~4 hours | **Size**: ~150 lines | **Priority**: CRITICAL

### Quick Checklist

```
[ ] Create: engine/geoscape/ui/geoscape_input.lua
[ ] Implement: handleMousePress(), handleKeyPress()
[ ] Implement: getHexUnderMouse()
[ ] Implement: Context menu
[ ] Test: 3 tests passing
[ ] Lint: 0 errors
```

### Key Bindings

```
Left Click   → Select hex
Right Click  → Context menu
SPACE        → Advance turn
Arrow Keys   → Pan camera (renderer)
+/-          → Zoom (renderer)
M/F/C        → Toggle UI panels
```

---

## STEP 5: CREATE MODULE 6.5 (REGION PANEL)

**Time**: ~3 hours | **Size**: ~100 lines | **Priority**: MEDIUM

### Quick Checklist

```
[ ] Create: engine/geoscape/ui/region_detail_panel.lua
[ ] Implement: show(), update(), draw()
[ ] Implement: Auto-close (5 seconds)
[ ] Test: 1 test passing
[ ] Lint: 0 errors
```

---

## STEP 6: CREATE MODULE 6.6 (INDICATORS)

**Time**: ~1 hour | **Size**: ~80 lines | **Priority**: MEDIUM

### Quick Checklist

```
[ ] Create: engine/geoscape/ui/craft_indicators.lua
[ ] Implement: drawCrafts(), drawUFOs(), drawBases()
[ ] Test: 2 tests passing
[ ] Lint: 0 errors
```

### Icon Design

```lua
-- Crafts: Green circles
love.graphics.setColor(0.2, 1, 0.2)
love.graphics.circle("fill", x, y, 8)

-- UFOs: Red triangles
love.graphics.setColor(1, 0.2, 0.2)
love.graphics.polygon("fill", x, y-10, x+10, y+10, x-10, y+10)

-- Bases: Yellow squares
love.graphics.setColor(1, 1, 0.2)
love.graphics.rectangle("fill", x-8, y-8, 16, 16)
```

---

## STEP 7: CREATE TEST SUITE

**Time**: ~2 hours | **Size**: ~250+ lines | **Priority**: CRITICAL

### Quick Checklist

```
[ ] Create: tests/geoscape/test_phase6_rendering_ui.lua
[ ] Write: 15+ tests (1 per module + integration)
[ ] Verify: 100% pass rate
[ ] Lint: 0 errors
[ ] Run: lovec tests/runners geoscape
```

### Test Count Breakdown

```
Hex Rendering:    3 tests
Calendar UI:      3 tests
Mission Panel:    3 tests
Input Handling:   3 tests
Region Details:   1 test
Indicators:       2 tests
Integration:      1 test (optional)
────────────────────────
TOTAL:           15+ tests
```

---

## STEP 8: VERIFY & INTEGRATE

**Time**: ~2 hours | **Priority**: CRITICAL

### Integration Checklist

```
[ ] Wire CalendarDisplay to campaign_manager.calendar
[ ] Wire MissionFactionPanel to mission_system
[ ] Wire GeoscapeInput to camera controls
[ ] Wire SPACE key to advanceTurn()
[ ] Verify all UI panels render
[ ] Test turn advancement
[ ] Verify save/load works
```

### Final Verification

```bash
# Run game
lovec engine

# Expected:
✓ All UI panels visible
✓ Hex map renders
✓ Camera pan/zoom works
✓ Calendar updates on turn advance
✓ Missions display
✓ Click selects hexes
✓ 60 FPS maintained
✓ Exit Code 0

# Run tests
lovec tests/runners geoscape

# Expected:
✓ 15+ tests
✓ 100% pass rate
✓ 0 lint errors
```

---

## COMMON ISSUES & SOLUTIONS

| Issue | Cause | Fix |
|-------|-------|-----|
| Low FPS (30) | No hex culling | Add bounds check in drawHex() |
| Hexes misaligned | Coord conversion wrong | Verify hexToPixel() formula |
| Input not working | Event not wired | Add love.mousepressed() binding |
| Panels overlap | Z-order wrong | Draw in correct order |
| Crash on turn advance | Missing method | Check advanceTurn() exists |

---

## SUCCESS CRITERIA CHECKLIST

Before moving to Phase 7:

- [ ] All 6 modules created (750+ lines)
- [ ] Test suite complete (15+ tests, 100% passing)
- [ ] 0 lint errors
- [ ] Exit Code 0
- [ ] 60 FPS maintained (<16ms per-frame)
- [ ] All UI panels integrated
- [ ] Turn advancement works
- [ ] Save/load working
- [ ] Documentation updated

---

## FILE ORGANIZATION

After Phase 6, your structure should be:

```
engine/geoscape/
├── rendering/
│   └── geoscape_renderer.lua     [6.1 - NEW]
├── ui/
│   ├── calendar_display.lua       [6.2 - NEW]
│   ├── mission_faction_panel.lua  [6.3 - NEW]
│   ├── geoscape_input.lua         [6.4 - NEW]
│   ├── region_detail_panel.lua    [6.5 - NEW]
│   └── craft_indicators.lua       [6.6 - NEW]
├── systems/
│   ├── calendar.lua               [5 - existing]
│   ├── season_system.lua          [5 - existing]
│   ├── event_scheduler.lua        [5 - existing]
│   └── turn_advancer.lua          [5 - existing]
└── campaign_manager.lua           [5 - modified]

tests/geoscape/
└── test_phase6_rendering_ui.lua   [NEW - 15+ tests]
```

---

## TIME BREAKDOWN

Realistic estimates:

| Task | Hours | Notes |
|------|-------|-------|
| Module 6.1 | 8h | Most complex, foundation |
| Module 6.2 | 4h | Standalone, no rendering deps |
| Module 6.3 | 5h | Standalone, no rendering deps |
| Module 6.4 | 4h | Input handling |
| Module 6.5 | 3h | Simple panel |
| Module 6.6 | 1h | Quick polish |
| Tests | 2h | Comprehensive suite |
| Integration | 2h | Wire systems together |
| Buffer | 4h | Unforeseen issues |
| **TOTAL** | **33h** | ~25h planned + 8h buffer |

---

## RESOURCES

### Key Documents

1. **PHASE-6-IMPLEMENTATION-CHECKLIST.md** - Detailed tasks
2. **PHASE-6-QUICK-REFERENCE.md** - Quick reference
3. **PHASE-6-PLANNING-COMPREHENSIVE.md** - Complete guide
4. **TASK-025-STATUS-SUMMARY.md** - Project overview

### Code References

- `engine/geoscape/systems/calendar.lua` - Phase 5 example
- `engine/geoscape/campaign_manager.lua` - Integration example
- `tests/geoscape/test_phase5_campaign_integration.lua` - Test example

---

## NEXT STEPS AFTER PHASE 6

Once Phase 6 complete:
1. Document what was built
2. Review performance metrics
3. Prepare Phase 7 planning
4. Begin Phase 7: Final integration (20 hours)

---

═══════════════════════════════════════════════════════════════════════════════
✅ YOU'RE READY - START WITH MODULE 6.1 (RENDERER)

**Remember**: Follow the checklist, test after each module, maintain 0 errors
═══════════════════════════════════════════════════════════════════════════════
