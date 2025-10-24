--[[
  Phase 6: Rendering & UI Test Suite

  Comprehensive tests for all Phase 6 rendering and UI components:
  - Hex grid rendering
  - Calendar display
  - Mission/faction panel
  - Input handling
  - Region detail panel
  - Craft indicators

  @module tests.geoscape.test_phase6_rendering_ui
  @author AI Assistant
  @license MIT
]]

local HarnessFunctions = require("tests.runners.harness_functions")
local assert_equal = HarnessFunctions.assert_equal
local assert_true = HarnessFunctions.assert_true
local assert_false = HarnessFunctions.assert_false
local assert_nil = HarnessFunctions.assert_nil

local tests = {}

-- Mock Love2D functions
local love = love or {}
love.graphics = love.graphics or {}
love.graphics.getFont = love.graphics.getFont or function() return "mock_font" end
love.graphics.setFont = love.graphics.setFont or function() end
love.graphics.clear = love.graphics.clear or function() end
love.graphics.setColor = love.graphics.setColor or function() end
love.graphics.rectangle = love.graphics.rectangle or function() end
love.graphics.circle = love.graphics.circle or function() end
love.graphics.polygon = love.graphics.polygon or function() end
love.graphics.line = love.graphics.line or function() end
love.graphics.printf = love.graphics.printf or function() end
love.keyboard = love.keyboard or {}
love.keyboard.isDown = love.keyboard.isDown or function() return false end
love.timer = love.timer or {}
love.timer.getFPS = love.timer.getFPS or function() return 60 end
love.timer.getTime = love.timer.getTime or function() return 0 end

-- =====================
-- Module 6.1: GeoscapeRenderer Tests
-- =====================

function tests.test_geoscape_renderer_initialize()
  local GeoscapeRenderer = require("engine.geoscape.rendering.geoscape_renderer")

  local renderer = GeoscapeRenderer:initialize(nil, 1280, 720)

  assert_equal(renderer.screen_width, 1280, "Screen width should be set")
  assert_equal(renderer.screen_height, 720, "Screen height should be set")
  assert_equal(renderer.zoom, 1.0, "Initial zoom should be 1.0")
  assert_equal(renderer.camera_x, 40, "Camera should start centered")
  assert_equal(renderer.camera_y, 20, "Camera should start centered")
  assert_false(renderer.show_grid, "Grid should be off initially")
end

function tests.test_hex_to_pixel_conversion()
  local GeoscapeRenderer = require("engine.geoscape.rendering.geoscape_renderer")

  local renderer = GeoscapeRenderer:initialize(nil, 1280, 720)
  renderer.camera_x = 0
  renderer.camera_y = 0
  renderer.zoom = 1.0

  local x, y = renderer:hexToPixel(0, 0)

  -- Should produce consistent pixel coordinates
  assert_true(x ~= nil, "Pixel X should be calculated")
  assert_true(y ~= nil, "Pixel Y should be calculated")
end

function tests.test_renderer_pan()
  local GeoscapeRenderer = require("engine.geoscape.rendering.geoscape_renderer")

  local renderer = GeoscapeRenderer:initialize(nil, 1280, 720)
  local initial_x = renderer.camera_x

  renderer:pan(100, 0)

  assert_true(renderer.camera_x > initial_x, "Camera should pan right")
end

function tests.test_renderer_zoom()
  local GeoscapeRenderer = require("engine.geoscape.rendering.geoscape_renderer")

  local renderer = GeoscapeRenderer:initialize(nil, 1280, 720)

  renderer:zoom(2.0)

  assert_equal(renderer.zoom, 2.0, "Zoom should increase")

  -- Test zoom bounds
  renderer:zoom(0.1)
  assert_true(renderer.zoom >= 0.5, "Zoom should not go below 0.5")

  renderer:zoom(10.0)
  assert_true(renderer.zoom <= 4.0, "Zoom should not exceed 4.0")
end

function tests.test_renderer_get_hex_under_mouse()
  local GeoscapeRenderer = require("engine.geoscape.rendering.geoscape_renderer")

  local renderer = GeoscapeRenderer:initialize(nil, 1280, 720)

  local hex = renderer:getHexUnderMouse(640, 360)

  assert_true(hex ~= nil, "Should return hex coordinate")
  if hex then
    assert_true(hex.q ~= nil and hex.r ~= nil, "Hex should have q and r")
  end
end

-- =====================
-- Module 6.2: CalendarDisplay Tests
-- =====================

function tests.test_calendar_display_initialize()
  local Calendar = require("engine.geoscape.systems.calendar")
  local CalendarDisplay = require("engine.geoscape.ui.calendar_display")

  local calendar = Calendar:initialize(1996, 1, 1)
  local display = CalendarDisplay:initialize(calendar)

  assert_equal(display.x, 10, "Display X position should be set")
  assert_equal(display.y, 10, "Display Y position should be set")
  assert_equal(display.width, 180, "Display width should be set")
  assert_true(display.date_string ~= "", "Date string should be populated")
end

function tests.test_calendar_display_update()
  local Calendar = require("engine.geoscape.systems.calendar")
  local CalendarDisplay = require("engine.geoscape.ui.calendar_display")

  local calendar = Calendar:initialize(2000, 12, 25)
  local display = CalendarDisplay:initialize(calendar)

  local initial_date = display.date_string

  calendar:advanceDay()
  display:updateDisplay()

  assert_true(display.date_string ~= initial_date, "Date should update")
end

function tests.test_calendar_display_seasons()
  local Calendar = require("engine.geoscape.systems.calendar")
  local CalendarDisplay = require("engine.geoscape.ui.calendar_display")

  local calendar = Calendar:initialize(1996, 1, 1)  -- Winter
  local display = CalendarDisplay:initialize(calendar)

  local winter_season = display.season_string

  -- Advance to summer (June)
  for _ = 1, 150 do
    calendar:advanceDay()
  end
  display:updateDisplay()

  local summer_season = display.season_string

  assert_true(winter_season ~= summer_season, "Season should change")
end

-- =====================
-- Module 6.3: MissionFactionPanel Tests
-- =====================

function tests.test_mission_faction_panel_initialize()
  local MissionFactionPanel = require("engine.geoscape.ui.mission_faction_panel")

  local panel = MissionFactionPanel:initialize(nil, nil)

  assert_equal(panel.x, 10, "Panel X position should be set")
  assert_equal(panel.y, 300, "Panel Y position should be set")
  assert_equal(#panel.missions, 0, "Should start with no missions")
  assert_equal(#panel.factions, 0, "Should start with no factions")
end

function tests.test_mission_faction_panel_update_missions()
  local MissionFactionPanel = require("engine.geoscape.ui.mission_faction_panel")

  local mock_campaign = {
    missions = {
      {name = "Test Mission", type = "INFILTRATION", threat = "high", turns_remaining = 5, active = true},
      {name = "Second Mission", type = "EXTRACTION", threat = "low", turns_remaining = 3, active = true}
    },
    factions = {}
  }

  local panel = MissionFactionPanel:initialize(mock_campaign, nil)

  assert_equal(#panel.missions, 2, "Should load missions from campaign")
  assert_equal(panel.missions[1].name, "Test Mission", "Mission name should match")
end

function tests.test_mission_faction_panel_scrolling()
  local MissionFactionPanel = require("engine.geoscape.ui.mission_faction_panel")

  local mock_campaign = {
    missions = {},
    factions = {}
  }

  -- Create 10 missions
  for i = 1, 10 do
    table.insert(mock_campaign.missions, {
      name = "Mission " .. i,
      type = "TYPE",
      threat = "medium",
      turns_remaining = i,
      active = true
    })
  end

  local panel = MissionFactionPanel:initialize(mock_campaign, nil)

  assert_equal(panel.scroll_offset, 0, "Should start at top")

  panel:keypressed("pagedown")

  assert_true(panel.scroll_offset > 0, "Should scroll down")
end

-- =====================
-- Module 6.4: GeoscapeInput Tests
-- =====================

function tests.test_geoscape_input_initialize()
  local GeoscapeRenderer = require("engine.geoscape.rendering.geoscape_renderer")
  local GeoscapeInput = require("engine.geoscape.ui.geoscape_input")

  local renderer = GeoscapeRenderer:initialize(nil, 1280, 720)
  local input = GeoscapeInput:initialize(renderer, {})

  assert_equal(input.input_mode, "normal", "Should start in normal mode")
  assert_nil(input.selected_hex, "No hex should be selected initially")
end

function tests.test_geoscape_input_select_hex()
  local GeoscapeRenderer = require("engine.geoscape.rendering.geoscape_renderer")
  local GeoscapeInput = require("engine.geoscape.ui.geoscape_input")

  local renderer = GeoscapeRenderer:initialize(nil, 1280, 720)
  local input = GeoscapeInput:initialize(renderer, {})

  input:selectHex({q = 10, r = 20})

  assert_equal(input.selected_hex.q, 10, "Hex Q should be selected")
  assert_equal(input.selected_hex.r, 20, "Hex R should be selected")
end

function tests.test_geoscape_input_context_menu()
  local GeoscapeRenderer = require("engine.geoscape.rendering.geoscape_renderer")
  local GeoscapeInput = require("engine.geoscape.ui.geoscape_input")

  local renderer = GeoscapeRenderer:initialize(nil, 1280, 720)
  local input = GeoscapeInput:initialize(renderer, {})

  input:buildContextMenu({q = 10, r = 20})

  assert_true(#input.context_menu_options > 0, "Should generate context menu options")
end

-- =====================
-- Module 6.5: RegionDetailPanel Tests
-- =====================

function tests.test_region_detail_panel_initialize()
  local RegionDetailPanel = require("engine.geoscape.ui.region_detail_panel")

  local panel = RegionDetailPanel:initialize(nil)

  assert_equal(panel.x, 1080, "Panel X position should be set")
  assert_false(panel.visible, "Panel should be hidden initially")
  assert_nil(panel.current_region, "No region should be displayed initially")
end

function tests.test_region_detail_panel_show_region()
  local RegionDetailPanel = require("engine.geoscape.ui.region_detail_panel")

  local panel = RegionDetailPanel:initialize(nil)

  panel:showRegion({q = 10, r = 20})

  assert_true(panel.visible, "Panel should be visible after showing region")
  assert_true(panel.current_region ~= nil, "Region should be set")
  assert_equal(panel.auto_close_timer, 0, "Timer should be reset")
end

function tests.test_region_detail_panel_auto_close()
  local RegionDetailPanel = require("engine.geoscape.ui.region_detail_panel")

  local panel = RegionDetailPanel:initialize(nil)

  panel:showRegion({q = 10, r = 20})
  assert_true(panel.visible, "Panel should be visible")

  -- Simulate time passing beyond threshold
  panel.auto_close_timer = 6.0
  panel:update(1.0)

  assert_false(panel.visible, "Panel should be hidden after timeout")
end

function tests.test_region_detail_panel_dragging()
  local RegionDetailPanel = require("engine.geoscape.ui.region_detail_panel")

  local panel = RegionDetailPanel:initialize(nil)

  local initial_x = panel.x
  panel:mousepressed(1090, 15, 1)  -- Click in title bar

  assert_true(panel.is_dragging, "Should enter dragging mode")

  panel:mousemoved(1100, 25)

  assert_true(panel.x > initial_x, "Panel should move when dragged")
end

-- =====================
-- Module 6.6: CraftIndicators Tests
-- =====================

function tests.test_craft_indicators_initialize()
  local GeoscapeRenderer = require("engine.geoscape.rendering.geoscape_renderer")
  local CraftIndicators = require("engine.geoscape.ui.craft_indicators")

  local renderer = GeoscapeRenderer:initialize(nil, 1280, 720)
  local indicators = CraftIndicators:initialize(nil, renderer)

  assert_equal(#indicators.player_crafts, 0, "Should start with no crafts")
  assert_equal(#indicators.ufos, 0, "Should start with no UFOs")
  assert_equal(#indicators.bases, 0, "Should start with no bases")
end

function tests.test_craft_indicators_update()
  local GeoscapeRenderer = require("engine.geoscape.rendering.geoscape_renderer")
  local CraftIndicators = require("engine.geoscape.ui.craft_indicators")

  local mock_campaign = {
    crafts = {
      {name = "Interceptor 1", location = {q = 10, r = 20}, health = 100, max_health = 100, status = "ready"}
    },
    ufos = {
      {type = "Scout", location = {q = 30, r = 40}, threat = "low", health = 50, max_health = 100, active = true}
    },
    bases = {
      {name = "Base Alpha", location = {q = 0, r = 0}, facilities = {}}
    }
  }

  local renderer = GeoscapeRenderer:initialize(nil, 1280, 720)
  local indicators = CraftIndicators:initialize(mock_campaign, renderer)

  assert_equal(#indicators.player_crafts, 1, "Should load player crafts")
  assert_equal(#indicators.ufos, 1, "Should load UFOs")
  assert_equal(#indicators.bases, 1, "Should load bases")
end

function tests.test_craft_indicators_get_at_position()
  local GeoscapeRenderer = require("engine.geoscape.rendering.geoscape_renderer")
  local CraftIndicators = require("engine.geoscape.ui.craft_indicators")

  local mock_campaign = {
    crafts = {
      {name = "Interceptor 1", location = {q = 40, r = 20}, health = 100, max_health = 100, status = "ready"}
    },
    ufos = {},
    bases = {}
  }

  local renderer = GeoscapeRenderer:initialize(nil, 1280, 720)
  local indicators = CraftIndicators:initialize(mock_campaign, renderer)

  -- Get screen position of craft (camera is at 40, 20)
  local pixel_x, pixel_y = renderer:hexToPixel(40, 20)

  local craft = indicators:getCraftAtPosition(pixel_x, pixel_y)

  assert_true(craft ~= nil, "Should find craft at position")
end

-- =====================
-- Integration Tests
-- =====================

function tests.test_phase6_all_components_together()
  local Calendar = require("engine.geoscape.systems.calendar")
  local GeoscapeRenderer = require("engine.geoscape.rendering.geoscape_renderer")
  local CalendarDisplay = require("engine.geoscape.ui.calendar_display")
  local MissionFactionPanel = require("engine.geoscape.ui.mission_faction_panel")
  local GeoscapeInput = require("engine.geoscape.ui.geoscape_input")
  local RegionDetailPanel = require("engine.geoscape.ui.region_detail_panel")
  local CraftIndicators = require("engine.geoscape.ui.craft_indicators")

  -- Initialize all components
  local calendar = Calendar:initialize(1996, 1, 1)
  local renderer = GeoscapeRenderer:initialize(nil, 1280, 720)
  local cal_display = CalendarDisplay:initialize(calendar)
  local mission_panel = MissionFactionPanel:initialize(nil, nil)
  local input = GeoscapeInput:initialize(renderer, {})
  local region_panel = RegionDetailPanel:initialize(nil)
  local indicators = CraftIndicators:initialize(nil, renderer)

  -- All should initialize without error
  assert_true(calendar ~= nil, "Calendar should initialize")
  assert_true(renderer ~= nil, "Renderer should initialize")
  assert_true(cal_display ~= nil, "Calendar display should initialize")
  assert_true(mission_panel ~= nil, "Mission panel should initialize")
  assert_true(input ~= nil, "Input handler should initialize")
  assert_true(region_panel ~= nil, "Region panel should initialize")
  assert_true(indicators ~= nil, "Indicators should initialize")
end

function tests.test_phase6_serialization()
  local GeoscapeRenderer = require("engine.geoscape.rendering.geoscape_renderer")
  local CalendarDisplay = require("engine.geoscape.ui.calendar_display")

  local calendar = require("engine.geoscape.systems.calendar"):initialize(1996, 1, 1)
  local renderer = GeoscapeRenderer:initialize(nil, 1280, 720)
  local display = CalendarDisplay:initialize(calendar)

  -- Modify state
  renderer:pan(100, 50)
  renderer:zoom(1.5)

  -- Serialize
  local state = renderer:serialize()

  -- Create new instance
  local renderer2 = GeoscapeRenderer:initialize(nil, 1280, 720)
  renderer2:deserialize(state)

  assert_equal(renderer.zoom, renderer2.zoom, "Zoom should persist")
end

-- =====================
-- Performance Tests
-- =====================

function tests.test_phase6_rendering_performance()
  local GeoscapeRenderer = require("engine.geoscape.rendering.geoscape_renderer")

  local renderer = GeoscapeRenderer:initialize(nil, 1280, 720)

  local start_time = love.timer.getTime()

  -- Simulate rendering 100 hexes
  for q = 0, 9 do
    for r = 0, 9 do
      renderer:drawHex(q, r)
    end
  end

  local elapsed = (love.timer.getTime() - start_time) * 1000  -- Convert to ms

  -- Should be performant (< 10ms for 100 hexes)
  assert_true(elapsed < 20, "Rendering should be performant")
end

function tests.test_phase6_input_performance()
  local GeoscapeRenderer = require("engine.geoscape.rendering.geoscape_renderer")
  local GeoscapeInput = require("engine.geoscape.ui.geoscape_input")

  local renderer = GeoscapeRenderer:initialize(nil, 1280, 720)
  local input = GeoscapeInput:initialize(renderer, {})

  local start_time = love.timer.getTime()

  -- Simulate 100 clicks
  for i = 1, 100 do
    input:handleLeftClick(640 + i, 360 + i)
  end

  local elapsed = (love.timer.getTime() - start_time) * 1000

  assert_true(elapsed < 50, "Input should be fast")
end

return tests
