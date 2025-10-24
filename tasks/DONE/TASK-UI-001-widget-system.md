# Task: UI Widget System Expansion and Categorization

**Status:** TODO
**Priority:** High
**Created:** October 24, 2025
**Assigned To:** Development Team

---

## Overview

Expand and reorganize the UI widget system with clear categorization, improved composition-based architecture, and new specialized widgets required for the Map Editor and World Editor tools. Ensure widgets are composable and follow consistent design patterns.

---

## Purpose

Current widget system exists but lacks:
- Clear categorization (basic, advanced, specialized)
- Composition-based architecture for complex widgets
- Documentation of available widgets
- Specialized widgets for map/world editors
- Reusable component library
- Widget showcase/testing interface

---

## Requirements

### Functional Requirements
- [x] Categorize existing 20+ widgets into 3 tiers
- [x] Implement 8-10 new specialized widgets
- [x] Ensure composition over inheritance
- [x] Create widget registry and showcase
- [x] Provide widget documentation
- [x] Support multiple themes
- [x] Implement widget testing interface
- [x] Create example usage for each widget

### Technical Requirements
- [x] Pure Lua implementation
- [x] No external dependencies
- [x] Consistent API across all widgets
- [x] Proper event handling (click, hover, input)
- [x] Theme support with color schemas
- [x] State management per widget
- [x] Performance optimized rendering

### Acceptance Criteria
- [x] 30+ total widgets available
- [x] All widgets documented
- [x] Widget showcase runnable
- [x] No widget inheritance duplication
- [x] Editor tools work smoothly
- [x] Performance: 60 FPS with 50 widgets
- [x] Example usage for each category

---

## Plan

### Phase 1: Widget Audit & Categorization (6 hours)
**Description:** Audit existing widgets and create categorization scheme
**Files to create/modify:**
- `docs/ui/WIDGET_CATEGORY_GUIDE.md` - Widget categories
- `engine/gui/widgets/REGISTRY.md` - Widget registry and inventory
- Create categorization analysis

**Existing Widget Inventory (audit):**
- Basic: Button, Label, TextBox, TextField, Checkbox, RadioButton
- Advanced: Slider, ScrollBar, Scrollable, Dropdown, ListBox, Tab
- Specialized: ResearchTree, Map Display (various renderers)

**New Categorization:**
- **Basic (8):** Button, Label, TextBox, TextField, Checkbox, RadioButton, Icon, Spacer
- **Advanced (10):** Slider, ScrollBar, Scrollable, Dropdown, ListBox, Tab, Panel, Dialog, Tooltip, ContextMenu
- **Specialized (12):** HexTileSelector, BiomePicker, WorldTileCostPalette, LayerPanel, ResourceList, TiledPalette, MapGrid, TerrainPalette, ColorPicker, DatePicker, Timeline, PropertyGrid

**Estimated time:** 6 hours

### Phase 2: Reorganize Core Widgets (8 hours)
**Description:** Refactor existing widgets to composition-based architecture
**Files to create/modify:**
- `engine/gui/widgets/basic/` - Reorganize basic widgets
- `engine/gui/widgets/advanced/` - Reorganize advanced widgets
- `engine/gui/widgets/shared/` - Shared widget utilities
- `engine/gui/widgets/README.md` - Widget organization guide

**Key tasks:**
- Move basic widgets to `basic/` folder
- Move advanced widgets to `advanced/` folder
- Extract common widget behavior to `shared/base_widget.lua`
- Ensure consistent event handling API
- Ensure consistent lifecycle methods
- Refactor for composition (widgets containing other widgets)
- Minimize inheritance, maximize composition

**Composition pattern:**
```lua
-- Complex widgets are built from simpler ones
TabPanel = {
  tabs = {},           -- Tab buttons (basic widgets)
  content_panels = {}, -- Content areas
  scroll_bar = {},     -- Scroll widget

  add_tab = function(self, name, content)
    -- Create tab button (reuses Button widget)
    local tab_button = Button.new(name)
    -- Wrap content
    local panel = Panel.new(content)
    -- Add both
    table.insert(self.tabs, tab_button)
    table.insert(self.content_panels, panel)
  end
}
```

**Estimated time:** 8 hours

### Phase 3: New Basic Widgets (4 hours)
**Description:** Add 2 new basic widgets not currently present
**Files to create/modify:**
- `engine/gui/widgets/basic/icon.lua` - Icon display widget
- `engine/gui/widgets/basic/spacer.lua` - Spacing widget
- `engine/gui/widgets/basic/divider.lua` - Visual divider

**New Basic Widgets:**
1. **Icon Widget** - Display icons/images with scaling
2. **Spacer Widget** - Fixed or flexible spacing
3. **Divider Widget** - Horizontal/vertical divider lines

**Estimated time:** 4 hours

### Phase 4: New Advanced Widgets (8 hours)
**Description:** Add 4 new advanced widgets
**Files to create/modify:**
- `engine/gui/widgets/advanced/panel.lua` - Container widget
- `engine/gui/widgets/advanced/dialog.lua` - Modal dialog
- `engine/gui/widgets/advanced/tooltip.lua` - Hover tooltips
- `engine/gui/widgets/advanced/context_menu.lua` - Right-click menu

**New Advanced Widgets:**
1. **Panel Widget** - Container for organizing widgets
2. **Dialog Widget** - Modal dialog with buttons
3. **Tooltip Widget** - Hover information display
4. **ContextMenu Widget** - Right-click context menu

**Estimated time:** 8 hours

### Phase 5: New Specialized Widgets (10 hours)
**Description:** Implement 6 new specialized widgets for editors
**Files to create/modify:**
- `engine/gui/widgets/specialized/hex_tile_selector.lua`
- `engine/gui/widgets/specialized/biome_picker.lua`
- `engine/gui/widgets/specialized/world_tile_palette.lua`
- `engine/gui/widgets/specialized/layer_panel.lua`
- `engine/gui/widgets/specialized/resource_list.lua`
- `engine/gui/widgets/specialized/tiled_palette.lua`

**New Specialized Widgets:**
1. **HexTileSelector** - Display and select from hex tiles (for map editor)
2. **BiomePicker** - Select biome with preview
3. **WorldTileCostPalette** - Palette for terrain movement costs (WATER, LAND, ROUGH, BLOCK)
4. **LayerPanel** - Layer visibility/selection panel
5. **ResourceList** - Filterable list with icons
6. **TiledPalette** - Grid-based item selector with scrolling

**Estimated time:** 10 hours

### Phase 6: Widget Registry & Showcase (6 hours)
**Description:** Create widget registry and interactive showcase
**Files to create/modify:**
- `engine/gui/widgets/widget_registry.lua` - Widget registry
- `tools/widget_showcase/main.lua` - Showcase application
- `tools/widget_showcase/showcase.lua` - Showcase logic
- `tools/widget_showcase/README.md` - Usage guide

**Key tasks:**
- Create widget registry (list all available widgets)
- Create showcase application (standalone Love2D app)
- Show each widget category separately
- Interactive demo of each widget
- Code example for each widget
- State/property browser
- Performance metrics

**Showcase Features:**
- Browse all 30+ widgets
- See live demos
- Modify properties interactively
- Copy example code
- Test interactivity
- Performance profiling

**Estimated time:** 6 hours

### Phase 7: Documentation & Examples (8 hours)
**Description:** Create comprehensive widget documentation
**Files to create/modify:**
- `docs/ui/WIDGET_GUIDE.md` - Complete widget guide
- `docs/ui/widget_catalog.md` - Widget catalog with screenshots
- `docs/ui/WIDGET_API_REFERENCE.md` - API reference for all widgets
- Create example usage files for each widget

**Documentation includes:**
- Purpose and use case for each widget
- API reference (properties, methods, events)
- Example code snippets
- Screenshots
- Integration examples
- Common patterns and best practices

**Widget Catalog (HTML):**
```
Widget Categories
├── Basic Widgets (8)
│   ├── Button
│   ├── Label
│   ├── TextField
│   ├── Checkbox
│   ├── RadioButton
│   ├── Icon
│   ├── Spacer
│   └── Divider
├── Advanced Widgets (10)
│   ├── Panel
│   ├── Dialog
│   ├── Slider
│   ├── ScrollBar
│   ├── Dropdown
│   ├── ListBox
│   ├── Tab
│   ├── Tooltip
│   ├── ContextMenu
│   └── ScrollPanel
└── Specialized Widgets (12)
    ├── HexTileSelector
    ├── BiomePicker
    ├── WorldTileCostPalette
    ├── LayerPanel
    ├── ResourceList
    ├── TiledPalette
    ├── MapGrid
    ├── TerrainPalette
    ├── ColorPicker
    ├── DatePicker
    ├── Timeline
    └── PropertyGrid
```

**Estimated time:** 8 hours

### Phase 8: Testing & Integration (6 hours)
**Description:** Test widgets and integrate with editor tools
**Files to create/modify:**
- `tests/widgets/widget_tests.lua` - Widget test suite
- `tests/tools/map_editor_widget_tests.lua` - Map editor widget tests
- `tests/tools/world_editor_widget_tests.lua` - World editor widget tests

**Key tasks:**
- Test all 30+ widgets for functionality
- Test event handling
- Test composition patterns
- Test performance with many widgets
- Test integration with editor tools
- Verify 60 FPS with 50+ widgets
- Test all themes

**Estimated time:** 6 hours

---

## Widget Architecture

### Base Widget Class
```lua
Widget = {
  -- Core properties
  x = 0, y = 0,
  width = 100, height = 30,
  visible = true,
  enabled = true,

  -- Lifecycle
  new = function(config) ... end,
  initialize = function(self) ... end,
  destroy = function(self) ... end,

  -- Rendering
  update = function(self, dt) ... end,
  draw = function(self) ... end,

  -- Events
  on_click = function(self, x, y) ... end,
  on_hover = function(self, x, y) ... end,
  on_input = function(self, text) ... end,

  -- State
  set_state = function(self, key, value) ... end,
  get_state = function(self, key) ... end,
}
```

### Composition Example
```lua
-- TabPanel composed of Buttons and Panels
TabPanel.new = function(config)
  local self = setmetatable({}, TabPanel)
  self.tabs = {}           -- Button widgets
  self.panels = {}         -- Panel widgets
  self.active_tab = 1
  return self
end

-- Add tab (reuses Button and Panel widgets)
function TabPanel:add_tab(name, content)
  local tab_button = Button.new({label = name})
  local panel = Panel.new({content = content})
  table.insert(self.tabs, tab_button)
  table.insert(self.panels, panel)
end
```

### Specialized Widget Example
```lua
-- HexTileSelector for map editor
HexTileSelector = {
  tileset = nil,
  selected_tile = nil,
  grid = {},
  scroll_panel = nil,  -- Composes ScrollPanel widget
  tile_buttons = {},   -- Composes Button widgets
}

function HexTileSelector:new(tileset)
  local self = setmetatable({}, HexTileSelector)
  self.tileset = tileset

  -- Compose widgets
  self.scroll_panel = ScrollPanel.new({width = 200, height = 300})

  -- Populate with tile buttons
  for _, tile in ipairs(tileset.tiles) do
    local btn = Button.new({label = tile.name})
    table.insert(self.tile_buttons, btn)
    self.scroll_panel:add_child(btn)
  end

  return self
end
```

---

## File Organization

```
engine/gui/widgets/
├── README.md                      -- Widget organization guide
├── widget_registry.lua            -- Widget registry
├── basic/
│   ├── README.md
│   ├── button.lua
│   ├── label.lua
│   ├── text_field.lua
│   ├── checkbox.lua
│   ├── radio_button.lua
│   ├── icon.lua
│   ├── spacer.lua
│   └── divider.lua
├── advanced/
│   ├── README.md
│   ├── panel.lua
│   ├── dialog.lua
│   ├── slider.lua
│   ├── scrollbar.lua
│   ├── dropdown.lua
│   ├── listbox.lua
│   ├── tab.lua
│   ├── tooltip.lua
│   ├── context_menu.lua
│   └── scrollpanel.lua
├── specialized/
│   ├── README.md
│   ├── hex_tile_selector.lua
│   ├── biome_picker.lua
│   ├── world_tile_palette.lua
│   ├── layer_panel.lua
│   ├── resource_list.lua
│   ├── tiled_palette.lua
│   ├── map_grid.lua
│   ├── terrain_palette.lua
│   ├── color_picker.lua
│   ├── date_picker.lua
│   ├── timeline.lua
│   └── property_grid.lua
└── shared/
    ├── base_widget.lua
    ├── theme_manager.lua
    ├── event_system.lua
    └── utilities.lua
```

---

## Testing Strategy

- Verify all 30+ widgets render correctly
- Verify event handling (click, hover, input)
- Verify composition patterns work
- Test performance with 50+ widgets
- Test integration with editor tools

---

## Notes

- **Composition-focused** - widgets contain other widgets
- **Modular** - each widget is independent
- **Themable** - support multiple visual themes
- **Well-documented** - each widget has examples
- **Performance-optimized** - 60 FPS with many widgets

---

## Review Checklist

- [ ] Widget audit and categorization complete
- [ ] Core widgets reorganized to folders
- [ ] All basic widgets implemented and tested
- [ ] All advanced widgets implemented and tested
- [ ] All specialized widgets implemented and tested
- [ ] Widget registry created and functional
- [ ] Showcase application working
- [ ] All documentation complete
- [ ] Performance verified (60 FPS)
- [ ] No duplication in widget code
- [ ] Composition patterns working correctly
- [ ] Integration with editor tools successful
- [ ] All tests passing

---

## Time Estimate Summary

| Phase | Duration | Total |
|-------|----------|-------|
| 1. Audit & Categorization | 6h | 6h |
| 2. Reorganize Core | 8h | 14h |
| 3. New Basic Widgets | 4h | 18h |
| 4. New Advanced Widgets | 8h | 26h |
| 5. New Specialized Widgets | 10h | 36h |
| 6. Registry & Showcase | 6h | 42h |
| 7. Documentation | 8h | 50h |
| 8. Testing & Integration | 6h | 56h |
| **Total** | **56h** | **56h** |

**Estimated Total Time: 56 hours (7 days at 8h/day)**
