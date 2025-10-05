# Map Block Authoring

**Tags:** #content-creation #map-design #battlescape #level-design  
**Last Updated:** September 30, 2025  
**Related:** [[README]], [[Asset_Creation_Guide]], [[Mission_Design_Template]]

---

## Overview

Map blocks are modular level components that combine to create tactical battlescape environments. Each block is a self-contained segment of playable space (typically 10×10 to 20×20 tiles) with defined spawn points, cover elements, and connectors for seamless assembly into larger maps.

This guide covers the complete process of designing, building, testing, and integrating map blocks into the mission generation system, ensuring balanced tactical gameplay and visual variety.

---

## Map Block Specifications

### Technical Requirements

**Dimensions:**
- Minimum size: 10×10 tiles (200×200 pixels)
- Maximum size: 30×30 tiles (600×600 pixels)
- Standard sizes: 10×10, 15×15, 20×20 tiles
- Edge alignment: Must tile seamlessly with connectors

**Tile Scale:**
- Base tile: 10×10 pixels
- Display scale: ×2 (20×20 pixels rendered)
- Grid alignment: All objects snap to tile grid
- Elevation: Support for multi-level structures (0-3 floors)

**Performance:**
- Maximum entities per block: 50-100 objects
- Line-of-sight calculation: Under 5ms per unit
- Pathfinding: A* grid must be pre-computed
- Memory footprint: Under 2MB per block (including textures)

### Gameplay Requirements

**Tactical Balance:**
- Cover density: 40-60% of tiles provide cover
- Cover types: 30% half cover, 20% full cover
- Open spaces: 30-40% clear tiles for movement
- Chokepoints: 2-4 tactical bottlenecks per block
- Flanking routes: Multiple approach angles

**Spawn Points:**
- Player spawn: 2-6 positions per block
- Enemy spawn: 3-8 positions per block
- Civilian spawn: 0-4 positions (if applicable)
- VIP spawn: 1-2 designated positions
- Minimum separation: 8 tiles between factions

**Connectors:**
- Entry/exit points: 2-4 per block
- Connector types: Door, hallway, street, ladder
- Accessibility: All connectors must be reachable
- Pathing: Pre-compute valid paths between connectors

---

## Map Block Types

### Urban Blocks
**Setting:** City streets, buildings, parking lots  
**Cover:** Vehicles, walls, street furniture  
**Elevation:** 1-2 floors typical  
**Examples:** Street intersection, office interior, rooftop

### Industrial Blocks
**Setting:** Factories, warehouses, power plants  
**Cover:** Machinery, storage containers, catwalks  
**Elevation:** 2-3 floors with vertical gameplay  
**Examples:** Factory floor, loading dock, control room

### Rural Blocks
**Setting:** Farms, forests, open terrain  
**Cover:** Trees, rocks, farm equipment  
**Elevation:** Ground level, occasional barns  
**Examples:** Cornfield, forest clearing, farmhouse

### Alien Facility Blocks
**Setting:** UFO interiors, alien bases  
**Cover:** Alien technology, organic structures  
**Elevation:** 1-2 floors with alien architecture  
**Examples:** UFO engine room, containment cells, command bridge

### Special Blocks
**Setting:** Unique mission-specific locations  
**Cover:** Mission-appropriate obstacles  
**Elevation:** Variable based on design  
**Examples:** Government building, subway station, archaeological dig

---

## Map Block Authoring Workflow

### Phase 1: Concept Design (1-2 hours)

**Objective:** Define block purpose and layout

1. **Review mission requirements**
   - Understand mission type (terror, UFO assault, base defense)
   - Identify tactical gameplay goals
   - Note story/atmosphere requirements

2. **Create layout sketch**
   - Draw top-down view on grid paper
   - Mark major structures and cover
   - Identify spawn zones and connectors
   - Plan line-of-sight corridors

3. **Define tactical flow**
   - Plan player approach routes
   - Establish enemy defensive positions
   - Create flanking opportunities
   - Balance risk/reward positioning

4. **Get concept approval**
   - Present to design team
   - Discuss balance concerns
   - Confirm technical feasibility
   - Document feedback

**Deliverables:** Concept sketch, design notes, approval sign-off

---

### Phase 2: Tilemap Creation (3-5 hours)

**Objective:** Build block geometry and environment

**Using Tiled Map Editor:**

1. **Set up project**
   ```
   - Canvas size: Block dimensions (e.g., 20×20 tiles)
   - Tile size: 10×10 pixels (will scale ×2)
   - Layer structure:
     * Floor (ground tiles)
     * Walls (obstacles, buildings)
     * Props (furniture, cover objects)
     * Overlay (shadows, effects)
     * Data (spawn points, cover markers)
   ```

2. **Paint floor layer**
   - Fill with appropriate floor tiles
   - Add texture variation (cracks, dirt, blood)
   - Ensure visual consistency
   - Consider pathing implications

3. **Build walls and structures**
   - Place wall tiles
   - Create rooms and corridors
   - Add doors and windows
   - Verify connectivity

4. **Add props and cover**
   - Place furniture, crates, vehicles
   - Distribute cover appropriately (40-60% coverage)
   - Create visual interest
   - Mark destructible objects

5. **Set up elevation**
   - Define floor heights (ground=0, second floor=1, etc.)
   - Add stairs/ladders between levels
   - Mark elevation boundaries
   - Test vertical line-of-sight

6. **Add overlay effects**
   - Shadows under objects
   - Blood splatter (if appropriate)
   - Environmental effects (sparks, smoke)
   - Lighting gradients

**Tools:**
- **Tiled** (Free) - Industry standard map editor
- **Custom Map Editor** (In development) - Native engine tool
- **GIMP/Aseprite** - For custom tile creation

**Deliverables:** Tiled TMX file or custom map format

---

### Phase 3: Gameplay Data Setup (2-3 hours)

**Objective:** Configure tactical gameplay elements

1. **Define spawn points**
   ```toml
   [[spawns.player]]
   position = [5, 5]
   direction = "north"
   priority = 1  # Primary spawn
   
   [[spawns.player]]
   position = [7, 5]
   direction = "north"
   priority = 2  # Secondary spawn
   
   [[spawns.enemy]]
   position = [15, 15]
   direction = "south"
   role = "sniper"  # Prefers elevation
   
   [[spawns.enemy]]
   position = [12, 18]
   direction = "south"
   role = "assault"  # Aggressive positioning
   ```

2. **Mark cover positions**
   ```toml
   [[cover]]
   position = [8, 10]
   type = "half"  # Half cover (wall, crate)
   height = 1
   destructible = true
   
   [[cover]]
   position = [10, 10]
   type = "full"  # Full cover (thick wall)
   height = 2
   destructible = false
   ```

3. **Define connectors**
   ```toml
   [[connectors]]
   position = [0, 10]
   direction = "west"
   type = "door"
   locked = false
   
   [[connectors]]
   position = [20, 10]
   direction = "east"
   type = "hallway"
   ```

4. **Set up objectives**
   ```toml
   [[objectives.terminals]]
   position = [15, 5]
   interaction_type = "hack"
   required = true
   
   [[objectives.civilians]]
   position = [8, 16]
   state = "panicked"
   ```

5. **Add interactive elements**
   ```toml
   [[interactables.door]]
   position = [10, 5]
   locked = true
   key_required = "keycard_blue"
   
   [[interactables.explosive]]
   position = [18, 18]
   damage_radius = 3
   trigger_type = "proximity"
   ```

**Deliverables:** Map block TOML file with complete data

---

### Phase 4: Pathfinding & LOS Setup (1-2 hours)

**Objective:** Generate navigation and visibility data

1. **Generate pathfinding grid**
   - Mark walkable tiles (cost = 1)
   - Mark obstacles (cost = infinity)
   - Mark difficult terrain (cost = 2-3)
   - Add elevation costs (stairs cost more)

2. **Pre-compute LOS data**
   - Calculate visible tiles from each position
   - Mark LOS-blocking objects (walls, full cover)
   - Handle elevation visibility rules
   - Cache results for performance

3. **Validate connectivity**
   - Ensure all spawns can reach all connectors
   - Verify no isolated areas (unless intentional)
   - Test pathfinding between critical points
   - Fix unreachable zones

4. **Optimize data**
   - Compress pathfinding grid
   - Reduce LOS lookup table size
   - Remove redundant data
   - Target under 100KB per block

**Tools:**
- **Pathfinding Validator** - Automated connectivity check
- **LOS Calculator** - Pre-compute visibility
- **Map Optimizer** - Reduce data size

**Deliverables:** Pathfinding grid, LOS data, validation report

---

### Phase 5: Testing & Balance (2-4 hours)

**Objective:** Validate tactical gameplay

1. **Layout testing**
   - Load block in test map
   - Spawn test units (player and AI)
   - Verify spawn positions work correctly
   - Check connector accessibility

2. **Combat testing**
   - Run AI vs AI simulation (10-20 battles)
   - Track combat statistics:
     * Average engagement distance
     * Cover usage percentage
     * Flanking success rate
     * Time to clear block
   - Identify dominant positions (too strong)
   - Find death traps (too dangerous)

3. **Balance adjustments**
   - Adjust spawn positions if unfair
   - Add/remove cover as needed
   - Modify connector placement
   - Fine-tune objective positions

4. **Performance testing**
   - Monitor FPS during combat
   - Check memory usage
   - Validate LOS calculation time
   - Optimize if needed

5. **Playtest**
   - Human players test block
   - Gather feedback on fun factor
   - Note confusing layouts
   - Iterate based on feedback

**Deliverables:** Balance report, adjusted map data

---

### Phase 6: Visual Polish (1-2 hours)

**Objective:** Enhance atmosphere and visual appeal

1. **Add environmental details**
   - Blood splatters, bullet holes
   - Debris and clutter
   - Atmospheric props (sparks, smoke)
   - Light sources (lamps, fires)

2. **Lighting pass**
   - Define light zones (bright, dim, dark)
   - Add shadows from tall objects
   - Create atmosphere with lighting
   - Ensure gameplay clarity

3. **Ambiance elements**
   - Flickering lights
   - Dripping water
   - Distant sounds (optional audio)
   - Weather effects (rain, fog)

4. **Final cleanup**
   - Remove test markers
   - Verify tile alignment
   - Check for visual glitches
   - Ensure consistent art style

**Deliverables:** Polished map block ready for integration

---

### Phase 7: Integration (1 hour)

**Objective:** Add block to mission generation system

1. **Export final data**
   - Convert Tiled TMX to game format (TOML)
   - Include all gameplay data
   - Embed pathfinding and LOS data
   - Compress assets

2. **Register with mission system**
   ```toml
   [[map_blocks]]
   id = "urban_street_01"
   type = "urban"
   size = [20, 20]
   file = "maps/urban/street_01.toml"
   tags = ["outdoor", "street", "cover_heavy"]
   difficulty = "medium"
   min_level = 1
   max_level = 5
   weight = 10  # Selection probability
   ```

3. **Test in procedural generation**
   - Generate 10 random maps using block
   - Verify seamless connections
   - Check for generation errors
   - Validate performance

4. **Update documentation**
   - Add to map block catalog
   - Document design intentions
   - Note balance characteristics
   - Tag with keywords

**Deliverables:** Integrated map block in mission system

---

## Map Block Design Patterns

### The Killbox
**Layout:** Open center with surrounding cover  
**Tactics:** Defensive camping vs aggressive push  
**Balance:** High risk crossing center, safe edges

### The Labyrinth
**Layout:** Winding corridors with many rooms  
**Tactics:** Close-quarters combat, ambushes  
**Balance:** Difficult to establish firing lines

### The Sniper's Nest
**Layout:** Elevated position overlooking open area  
**Tactics:** Long-range dominance vs flanking  
**Balance:** Strong position but limited escape

### The Courtyard
**Layout:** Central open space with surrounding structures  
**Tactics:** Control high ground for advantage  
**Balance:** Vertical gameplay, multi-level combat

### The Chokepoint
**Layout:** Single narrow passage between areas  
**Tactics:** Defensive hold vs breaching  
**Balance:** Grenades and area denial critical

---

## Common Pitfalls

### ❌ Spawn Camping
**Problem:** Enemy spawns too close to objectives or player start  
**Solution:** Maintain 8+ tile separation, test spawn positions

### ❌ No Cover
**Problem:** Open killzones with no protection  
**Solution:** Maintain 40-60% cover density, test combat flow

### ❌ Too Much Cover
**Problem:** Combat stagnates, no movement incentive  
**Solution:** Create cover gaps, add flanking routes

### ❌ Unreachable Areas
**Problem:** Spawn points or objectives can't be accessed  
**Solution:** Run pathfinding validation, test all connections

### ❌ LOS Exploits
**Problem:** Positions that see entire map or can't be targeted  
**Solution:** Test LOS from all angles, fix sight exploits

### ❌ Performance Issues
**Problem:** Too many objects cause FPS drops  
**Solution:** Optimize object count, use instancing

### ❌ Inconsistent Theme
**Problem:** Mixed art styles or illogical layouts  
**Solution:** Maintain visual consistency, justify design choices

---

## Map Block Catalog

### Urban Blocks (20)
- Street Intersection (4-way)
- Office Building Interior
- Parking Lot
- Convenience Store
- Residential Apartment
- Rooftop
- Alleyway
- Gas Station
- ... (13 more)

### Industrial Blocks (15)
- Factory Floor
- Warehouse
- Loading Dock
- Control Room
- ... (11 more)

### Rural Blocks (12)
- Farmhouse
- Barn Interior
- Forest Clearing
- ... (9 more)

### Alien Blocks (10)
- UFO Scout Ship
- UFO Harvester
- Alien Base Corridor
- ... (7 more)

**Total:** 57+ unique map blocks

---

## Related Documentation

- [[README]] - Content pipeline overview
- [[Asset_Creation_Guide]] - Creating tiles and props
- [[Mission_Design_Template]] - Using map blocks in missions
- [[../../battlescape/README]] - Battlescape system documentation
- [[../../battlescape/Terrain]] - Terrain and cover system

---

**Document Status:** Complete  
**Review Date:** October 7, 2025  
**Owner:** Level Design Lead
