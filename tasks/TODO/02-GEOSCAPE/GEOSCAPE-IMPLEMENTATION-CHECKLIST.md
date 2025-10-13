# Geoscape Implementation Checklist

**Task:** TASK-025 - Geoscape Master Implementation  
**Status:** TODO  
**Total Time:** 140 hours (17-18 days)

---

## Phase 1: Core Data Structures & World Grid (18 hours)

### 1.1 Hex Grid System (6 hours)
- [ ] Create `engine/geoscape/systems/hex_grid.lua`
  - [ ] Axial coordinate system (q, r)
  - [ ] Cube coordinate conversion (for distance)
  - [ ] `distance(q1, r1, q2, r2)` function
  - [ ] `neighbors(q, r)` function (6 directions)
  - [ ] `ring(q, r, radius)` function
  - [ ] `area(q, r, radius)` function
  - [ ] `toPixel(q, r)` conversion
  - [ ] `toHex(x, y)` conversion
- [ ] Create `engine/geoscape/tests/test_hex_grid.lua`
  - [ ] Test distance calculations
  - [ ] Test neighbor finding
  - [ ] Test ring/area functions
  - [ ] Test coordinate conversions

### 1.2 World Data Structure (4 hours)
- [ ] Create `engine/geoscape/logic/world.lua`
  - [ ] World entity with 80×40 hex grid
  - [ ] Tile data structure (terrain, cost, land/water)
  - [ ] Background image support
  - [ ] Day/night cycle data
  - [ ] Province list
  - [ ] Portal list
- [ ] Create `engine/data/worlds/earth.toml`
  - [ ] World metadata (id, name, size, scale)
  - [ ] Day/night cycle configuration
  - [ ] 80×40 tile definitions (can start with subset)

### 1.3 Province & Graph System (8 hours)
- [ ] Create `engine/geoscape/logic/province.lua`
  - [ ] Province entity structure
  - [ ] Position (hex coordinates)
  - [ ] Biome, country, region references
  - [ ] Economy data
  - [ ] Connections list
  - [ ] Base slot (1 max)
  - [ ] Craft slots (4 max)
  - [ ] Mission list
  - [ ] Cities list
- [ ] Create `engine/geoscape/logic/province_graph.lua`
  - [ ] Graph data structure (adjacency list)
  - [ ] `addProvince(province)` function
  - [ ] `addConnection(id1, id2, cost)` function
  - [ ] `getNeighbors(provinceId)` function
  - [ ] `findPath(fromId, toId, craftType)` - A* implementation
  - [ ] `getRange(fromId, maxCost, craftType)` - Operational range
- [ ] Create `engine/data/worlds/earth_provinces.toml`
  - [ ] Province definitions (start with 20-50 provinces)
  - [ ] Province connections with costs

**Phase 1 Verification:**
- [ ] Run: `lovec "engine"` with console enabled
- [ ] Test hex distance calculations in console
- [ ] Test province graph pathfinding
- [ ] Verify no errors in console

---

## Phase 2: Calendar & Time System (10 hours)

### 2.1 Calendar Implementation (6 hours)
- [ ] Create `engine/geoscape/systems/calendar.lua`
  - [ ] Calendar state (turn, day, week, month, quarter, year)
  - [ ] `advanceTurn()` function
  - [ ] `getDate()` function (formatted string)
  - [ ] `getDayOfWeek()` function (1-6)
  - [ ] `getDayOfMonth()` function (1-30)
  - [ ] `getDayOfYear()` function (1-360)
  - [ ] Date rollover logic (day→week→month→quarter→year)
- [ ] Create `engine/geoscape/tests/test_calendar.lua`
  - [ ] Test turn advancement
  - [ ] Test date rollovers (day, week, month, year)
  - [ ] Test date formatting

### 2.2 Day/Night Cycle (4 hours)
- [ ] Create `engine/geoscape/systems/daynight_cycle.lua`
  - [ ] Track day/night line position
  - [ ] `update(turn)` function (move 4 tiles per day)
  - [ ] `isDay(q, r)` function
  - [ ] `getDayNightLine()` function
- [ ] Create `engine/geoscape/rendering/daynight_overlay.lua`
  - [ ] Dark overlay shader for night side
  - [ ] Render overlay on world map
  - [ ] 50/50 day/night split visual

**Phase 2 Verification:**
- [ ] Run game with console enabled
- [ ] Advance 30 turns, verify 1 month passed
- [ ] Verify day/night line moves 4 tiles per turn
- [ ] Check no errors in console

---

## Phase 3: Geographic & Political Systems (16 hours)

### 3.1 Biome System (4 hours)
- [ ] Create `engine/geoscape/logic/biome.lua`
  - [ ] Biome entity structure
  - [ ] ID, name
  - [ ] Interception background image path
  - [ ] Terrain types list
  - [ ] Base construction cost modifier
- [ ] Create `engine/data/biomes.toml`
  - [ ] Define 5-10 biomes (temperate, desert, arctic, tropical, etc.)
  - [ ] Interception backgrounds
  - [ ] Terrain type lists
  - [ ] Cost modifiers

### 3.2 Country System (6 hours)
- [ ] Create `engine/geoscape/logic/country.lua`
  - [ ] Country entity structure
  - [ ] ID, name, flag
  - [ ] Province IDs list
  - [ ] Economy (sum of province GDPs)
  - [ ] Relations (-2 to +2)
  - [ ] Monthly funding
  - [ ] Performance score
  - [ ] `updateRelations(scoreDelta)` function
  - [ ] `calculateFunding()` function
  - [ ] `isHostile()` function
- [ ] Create `engine/data/countries.toml`
  - [ ] Define major countries (USA, Russia, China, EU, etc.)
  - [ ] Base funding amounts
  - [ ] Initial relations

### 3.3 Region System (6 hours)
- [ ] Create `engine/geoscape/logic/region.lua`
  - [ ] Region entity structure
  - [ ] ID, name
  - [ ] Province IDs list
  - [ ] Score, fame
  - [ ] Marketplace access flag
- [ ] Create `engine/data/regions.toml`
  - [ ] Define 10-20 regions (continents, sub-continents)
  - [ ] Marketplace access flags

**Phase 3 Verification:**
- [ ] Load biomes, countries, regions from TOML files
- [ ] Verify country funding calculation
- [ ] Test relations update logic
- [ ] Check console for loading errors

---

## Phase 4: Craft & Travel System (20 hours)

### 4.1 Craft Data Structure (4 hours)
- [ ] Create `engine/geoscape/logic/craft.lua`
  - [ ] Craft entity structure
  - [ ] ID, type ID, name
  - [ ] Province ID, base ID
  - [ ] Fuel (current/max)
  - [ ] Travel points (used/max)
  - [ ] Craft type (land/air/water)
  - [ ] Speed (max hex range)
  - [ ] Radar range
- [ ] Create `engine/data/crafts.toml`
  - [ ] Define craft types (interceptor, transport, etc.)
  - [ ] Stats (fuel, speed, radar, travel points)

### 4.2 Travel System & Pathfinding (8 hours)
- [ ] Create `engine/geoscape/systems/travel_system.lua`
  - [ ] `canTravel(craftId, targetProvinceId)` function
  - [ ] `getOperationalRange(craftId)` function
  - [ ] `calculatePath(craftId, targetProvinceId)` function
  - [ ] `travel(craftId, targetProvinceId)` function
  - [ ] Fuel cost calculation
  - [ ] Travel point management
- [ ] Create `engine/geoscape/logic/pathfinding.lua`
  - [ ] A* algorithm on hex grid
  - [ ] Craft type restrictions (land/air/water)
  - [ ] Terrain cost modifiers (1-3 for land, 1 for water)
  - [ ] Path reconstruction
- [ ] Create `engine/geoscape/tests/test_travel_system.lua`
  - [ ] Test pathfinding accuracy
  - [ ] Test craft type restrictions
  - [ ] Test fuel cost calculations
  - [ ] Test operational range

### 4.3 Radar & Mission Detection (4 hours)
- [ ] Create `engine/geoscape/systems/radar_system.lua`
  - [ ] `scan(craftId)` function
  - [ ] `autoScanOnArrival(craftId)` function
  - [ ] `getDetectedMissions(provinceId)` function
  - [ ] Radar range calculation
  - [ ] Mission visibility logic

### 4.4 Auto-Return System (4 hours)
- [ ] Create `engine/geoscape/systems/craft_return.lua`
  - [ ] `endInterceptionPhase()` function
  - [ ] `returnCraft(craftId)` function
  - [ ] `refuel(craftId)` function
  - [ ] Move craft to base province
  - [ ] Refuel from base stockpile

**Phase 4 Verification:**
- [ ] Test craft movement between provinces
- [ ] Verify fuel deduction from base
- [ ] Test A* pathfinding with different craft types
- [ ] Verify operational range calculation
- [ ] Test radar detection on arrival
- [ ] Test auto-return after interception

---

## Phase 5: Base Management (10 hours)

### 5.1 Base Data Structure (4 hours)
- [ ] Create `engine/geoscape/logic/base.lua`
  - [ ] Base entity structure
  - [ ] ID, name
  - [ ] Province ID, country ID
  - [ ] Construction cost
  - [ ] Fuel stockpile (current/max)
  - [ ] Craft list
  - [ ] Facilities list (future)
- [ ] Create `engine/data/bases.toml`
  - [ ] Base type definitions
  - [ ] Default costs and capacities

### 5.2 Base Construction System (6 hours)
- [ ] Create `engine/geoscape/systems/base_construction.lua`
  - [ ] `canBuild(provinceId)` function
  - [ ] `getCost(provinceId)` function
  - [ ] `build(provinceId, name)` function
  - [ ] Cost modifiers (biome, country relations, region)
  - [ ] Province availability check (one base per province)
  - [ ] Country permission check (relations ≥ -1)

**Phase 5 Verification:**
- [ ] Test base construction in different provinces
- [ ] Verify cost modifiers apply correctly
- [ ] Test restriction: one base per province
- [ ] Test restriction: country relations requirement

---

## Phase 6: Universe & Portal System (12 hours)

### 6.1 Universe Manager (6 hours)
- [ ] Create `engine/geoscape/logic/universe.lua`
  - [ ] Universe container structure
  - [ ] Worlds map (world_id → World)
  - [ ] Current world ID
  - [ ] Portals list
  - [ ] `addWorld(world)` function
  - [ ] `getWorld(worldId)` function
  - [ ] `switchWorld(worldId)` function
  - [ ] `canTravel(craftId, portalId)` function
- [ ] Create `engine/data/universe.toml`
  - [ ] Universe configuration
  - [ ] World list

### 6.2 Portal System (6 hours)
- [ ] Create `engine/geoscape/logic/portal.lua`
  - [ ] Portal entity structure
  - [ ] ID, name
  - [ ] From world/province
  - [ ] To world/province
  - [ ] Travel cost (fuel)
  - [ ] Accessible flag
- [ ] Create `engine/data/portals.toml`
  - [ ] Define Earth-Mars portal (example)
  - [ ] One-way or two-way connections

**Phase 6 Verification:**
- [ ] Test loading multiple worlds
- [ ] Test switching between worlds
- [ ] Test portal travel with craft
- [ ] Verify fuel cost for inter-world travel

---

## Phase 7: UI Implementation (30 hours)

### 7.1 World Map Renderer (10 hours)
- [ ] Create `engine/geoscape/rendering/world_renderer.lua`
  - [ ] Render background image
  - [ ] Render hex grid (outline mode)
  - [ ] Render province shapes
  - [ ] Render day/night overlay
  - [ ] Render craft icons at province positions
  - [ ] Render base icons
  - [ ] Render mission indicators
  - [ ] Province highlighting (hover/selected)
  - [ ] Province names on hover
- [ ] Create `engine/geoscape/ui/world_map.lua`
  - [ ] Interactive map widget
  - [ ] Mouse hover detection
  - [ ] Click detection
  - [ ] Pan/zoom controls (optional)
  - [ ] **Grid snapping: All UI at 24×24 pixel grid**

### 7.2 Province Info Panel (6 hours)
- [ ] Create `engine/geoscape/ui/province_panel.lua`
  - [ ] Panel widget (grid-snapped)
  - [ ] Display province name, country, region
  - [ ] Display biome type
  - [ ] Display missions list
  - [ ] Display crafts list
  - [ ] Display base info (if present)
  - [ ] Display cities list
  - [ ] **Grid snapping: Panel size/position at 24-pixel multiples**

### 7.3 Craft Deployment UI (8 hours)
- [ ] Create `engine/geoscape/ui/craft_selector.lua`
  - [ ] Craft list widget (grid-snapped)
  - [ ] Show crafts for selected base
  - [ ] Display craft stats (fuel, travel points, type)
  - [ ] Craft selection handler
  - [ ] **Grid snapping: All elements at 24-pixel multiples**
- [ ] Create `engine/geoscape/ui/range_highlighter.lua`
  - [ ] Highlight reachable provinces (green)
  - [ ] Highlight edge of range (yellow)
  - [ ] Show unreachable (red)
  - [ ] Display fuel cost to each province
  - [ ] Clear highlights when deselected

### 7.4 Calendar & Country Panel (6 hours)
- [ ] Create `engine/geoscape/ui/calendar_widget.lua`
  - [ ] Date display (grid-snapped)
  - [ ] "End Turn" button
  - [ ] Turn counter
  - [ ] **Grid snapping: All elements at 24-pixel multiples**
- [ ] Create `engine/geoscape/ui/country_relations_panel.lua`
  - [ ] Country list (grid-snapped)
  - [ ] Relations display (-2 to +2) with color coding
  - [ ] Funding display per country
  - [ ] Score display
  - [ ] **Grid snapping: Panel at 24-pixel multiples**

**Phase 7 Verification:**
- [ ] Run game, verify all UI renders correctly
- [ ] Test F9 to toggle hex grid overlay
- [ ] Verify all UI elements snap to 24×24 pixel grid
- [ ] Test province hover/selection
- [ ] Test craft selection and range highlighting
- [ ] Test calendar advancement via UI
- [ ] Test country relations display

---

## Phase 8: Integration & Polish (14 hours)

### 8.1 State Manager Integration (4 hours)
- [ ] Update `engine/core/state_manager.lua`
  - [ ] Add Geoscape state registration
- [ ] Create `engine/geoscape/init.lua`
  - [ ] `Geoscape:load()` - Initialize world, calendar, UI
  - [ ] `Geoscape:update(dt)` - Update day/night, systems
  - [ ] `Geoscape:draw()` - Render world map, UI
  - [ ] `Geoscape:unload()` - Cleanup
  - [ ] `Geoscape:endTurn()` - Turn processing
  - [ ] Input handlers (mouse, keyboard)

### 8.2 Turn Processing (6 hours)
- [ ] Create `engine/geoscape/systems/turn_processor.lua`
  - [ ] `endTurn()` function with ordered processing:
    1. [ ] Advance calendar
    2. [ ] Update day/night cycle
    3. [ ] Reset craft travel points
    4. [ ] Process missions (spawn/expiration)
    5. [ ] Monthly trigger: Update country funding
    6. [ ] Process economy updates
    7. [ ] Trigger region events
    8. [ ] Save game state
  - [ ] Print debug messages for each step

### 8.3 Testing & Debugging (4 hours)
- [ ] Create `engine/geoscape/tests/test_geoscape_integration.lua`
  - [ ] Test full turn cycle
  - [ ] Test craft deployment flow
  - [ ] Test calendar advancement
  - [ ] Test country funding updates
  - [ ] Test portal travel
- [ ] Manual testing with `lovec "engine"`
  - [ ] Check console for errors/warnings
  - [ ] Verify all systems work together
  - [ ] Test edge cases (no fuel, max travel points used, etc.)

**Phase 8 Verification:**
- [ ] Run game: `lovec "engine"`
- [ ] Navigate from main menu to Geoscape
- [ ] Complete full turn cycle with no errors
- [ ] Deploy craft and complete interception
- [ ] Verify crafts auto-return
- [ ] Advance 30 turns, check monthly funding triggers
- [ ] No console errors or warnings

---

## Phase 9: Documentation (10 hours)

### 9.1 API Documentation (4 hours)
- [ ] Update `wiki/API.md`
  - [ ] Add Universe API section
  - [ ] Add World API section
  - [ ] Add Province API section
  - [ ] Add HexGrid API section
  - [ ] Add TravelSystem API section
  - [ ] Add Calendar API section
  - [ ] Add Country API section
  - [ ] Add Region API section
  - [ ] Add Biome API section
  - [ ] Document all public functions with parameters and returns

### 9.2 FAQ & Development Guide (4 hours)
- [ ] Update `wiki/FAQ.md`
  - [ ] Add "How does the Geoscape work?" section
  - [ ] Add "How do I deploy crafts?" section
  - [ ] Add "What is the calendar system?" section
  - [ ] Add "How do country relations work?" section
  - [ ] Add "How does the day/night cycle work?" section
- [ ] Update `wiki/DEVELOPMENT.md`
  - [ ] Add "Adding new worlds" section
  - [ ] Add "Creating province maps" section
  - [ ] Add "Defining biomes" section
  - [ ] Add "Configuring portals" section

### 9.3 User Guide (2 hours)
- [ ] Create `wiki/GEOSCAPE_GUIDE.md`
  - [ ] Overview of Geoscape layer
  - [ ] How to read the world map
  - [ ] Deploying crafts for missions
  - [ ] Managing bases
  - [ ] Understanding country relations
  - [ ] Calendar and turn progression
  - [ ] Using portals for inter-world travel

**Phase 9 Verification:**
- [ ] Review all documentation for accuracy
- [ ] Test code examples in documentation
- [ ] Ensure all new APIs are documented

---

## Final Review Checklist

### Code Quality
- [ ] No global variables (all use `local`)
- [ ] All functions documented with comments
- [ ] Error handling with `pcall()` where appropriate
- [ ] Print statements for debugging (prefix with `[Geoscape]`)
- [ ] No hardcoded values (use constants or config files)

### UI Requirements
- [ ] All UI elements snap to 24×24 pixel grid
- [ ] F9 toggles hex grid overlay
- [ ] F12 toggles fullscreen (works correctly)
- [ ] All widgets use theme system
- [ ] All UI text is readable

### Functional Requirements
- [ ] Hex grid system works correctly
- [ ] Province graph pathfinding accurate
- [ ] Craft travel deducts fuel from base
- [ ] Calendar advances correctly (day/week/month/year)
- [ ] Day/night cycle moves 4 tiles per day
- [ ] Country relations affect funding
- [ ] Radar detects missions on craft arrival
- [ ] Crafts auto-return after interception
- [ ] Portal travel switches worlds

### Performance
- [ ] No frame drops during rendering
- [ ] Pathfinding completes in <100ms
- [ ] UI responsive to input
- [ ] No memory leaks

### Testing
- [ ] All unit tests pass
- [ ] All integration tests pass
- [ ] Manual testing completed with no errors
- [ ] Console output clean (no errors/warnings)

### Documentation
- [ ] API documentation complete
- [ ] FAQ updated
- [ ] Development guide updated
- [ ] User guide created
- [ ] All code has inline comments

---

## Progress Tracking

**Phase 1:** ⬜ TODO (0/18 hours)  
**Phase 2:** ⬜ TODO (0/10 hours)  
**Phase 3:** ⬜ TODO (0/16 hours)  
**Phase 4:** ⬜ TODO (0/20 hours)  
**Phase 5:** ⬜ TODO (0/10 hours)  
**Phase 6:** ⬜ TODO (0/12 hours)  
**Phase 7:** ⬜ TODO (0/30 hours)  
**Phase 8:** ⬜ TODO (0/14 hours)  
**Phase 9:** ⬜ TODO (0/10 hours)  

**Total Progress:** 0/140 hours (0%)

---

## Notes

- Update this checklist as you complete tasks
- Mark checkboxes with `[x]` when done
- Update progress tracking percentages
- Add notes for any blockers or issues encountered
- Use console debugging: `lovec "engine"`
- All temp files must go to: `os.getenv("TEMP")`

---

**Task Document:** [TASK-025-geoscape-master-implementation.md](TASK-025-geoscape-master-implementation.md)  
**Quick Reference:** [GEOSCAPE-QUICK-REFERENCE.md](GEOSCAPE-QUICK-REFERENCE.md)  
**Architecture:** [GEOSCAPE-ARCHITECTURE-DIAGRAM.md](GEOSCAPE-ARCHITECTURE-DIAGRAM.md)
