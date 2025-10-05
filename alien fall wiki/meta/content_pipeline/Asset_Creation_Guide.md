# Asset Creation Guide

**Tags:** #content-creation #pixel-art #visual-assets #sprites  
**Last Updated:** September 30, 2025  
**Related:** [[README]], [[Map_Block_Authoring]], [[../../GUI/README]]

---

## Overview

This guide covers the complete workflow for creating pixel art assets for Alien Fall, from initial concept through integration. The game uses a strict 10×10 pixel art style scaled ×2 for rendering, maintaining crisp pixel-perfect visuals while avoiding anti-aliasing artifacts.

All visual assets must conform to established art direction, color palette constraints, and technical specifications to ensure consistency across the game's visual presentation. This guide provides step-by-step instructions, best practices, and common pitfalls to avoid.

---

## Technical Specifications

### Core Requirements

**Resolution:**
- Base pixel art: 10×10 pixels per unit/tile
- Rendering scale: ×2 (displayed as 20×20 pixels)
- UI elements: 20×20 pixel grid alignment
- Sprite sheets: Power-of-two dimensions (128×128, 256×256, etc.)

**Format:**
- File type: PNG with transparency
- Color depth: 8-bit indexed color preferred
- Compression: PNG optimization enabled
- Alpha channel: Binary transparency (fully opaque or fully transparent)

**Performance:**
- Maximum sprite sheet size: 1024×1024 pixels
- Animation frames: Minimize count (4-8 frames typical)
- File size: Under 100KB per sprite sheet
- Load time: Instant (under 16ms)

**Rendering:**
- Filtering mode: Nearest-neighbor (no interpolation)
- Antialiasing: Disabled (MSAA = 0)
- Pixel snapping: Enabled
- Grid alignment: All sprites align to pixel boundaries

---

## Color Palette

### Base Palette (32 Colors)

The game uses a restricted palette for visual consistency:

```
Grays (6):     #000000, #1a1a1a, #333333, #666666, #999999, #cccccc
Whites:        #ffffff, #f0f0f0
Blues (4):     #1e3a8a, #2563eb, #3b82f6, #60a5fa
Greens (4):    #14532d, #16a34a, #22c55e, #4ade80
Reds (4):      #7f1d1d, #dc2626, #ef4444, #f87171
Yellows (4):   #713f12, #eab308, #facc15, #fde047
Purples (3):   #581c87, #9333ea, #c084fc
Browns (3):    #44403c, #78716c, #a8a29e
Oranges (2):   #c2410c, #fb923c
Special (2):   #0ea5e9 (cyan), #ec4899 (pink)
```

**Usage Guidelines:**
- UI elements: Grays, blues for interactive elements
- Terrain: Browns, greens, grays
- Units: Full palette with faction-specific emphasis
- Effects: Bright colors (yellows, cyans, pinks)
- Blood/damage: Reds

---

## Asset Creation Workflow

### Phase 1: Concept & Reference (30 minutes - 2 hours)

**Objective:** Define visual direction and gather references

1. **Review design document**
   - Understand gameplay purpose
   - Note functional requirements (hitboxes, animations)
   - Identify technical constraints

2. **Gather references**
   - Find 5-10 reference images
   - Study similar games (X-COM, Jagged Alliance, XCOM 2)
   - Review existing game assets for style consistency

3. **Create thumbnail sketches**
   - Draw 3-5 rough concepts (16×16 or larger)
   - Test different poses/angles
   - Show to team for feedback

4. **Select final concept**
   - Get design approval
   - Confirm technical feasibility
   - Document any special requirements

**Deliverables:** Concept sketch, reference folder, approval sign-off

---

### Phase 2: Base Sprite Creation (1-3 hours)

**Objective:** Create clean 10×10 pixel art sprite

1. **Set up canvas**
   ```
   - Canvas size: 10×10 pixels
   - Color mode: Indexed color (palette)
   - Grid: 1×1 pixel
   - Zoom: 800% (for precision work)
   ```

2. **Block out silhouette**
   - Use black for initial shape
   - Ensure readable silhouette
   - Verify at 1:1 scale (tiny!)
   - Check against 20×20 grid alignment

3. **Add base colors**
   - Fill major areas with flat colors
   - Use palette colors only
   - Maintain high contrast
   - Avoid dithering at this stage

4. **Define forms**
   - Add one shade per color area
   - Use selective dithering for gradients
   - Define key features (face, weapons, limbs)
   - Maintain pixel art "chunkiness"

5. **Add details**
   - Accent colors and highlights
   - Critical details only (each pixel matters!)
   - Test readability at display scale (×2)
   - Remove unnecessary pixels

6. **Polish**
   - Clean up stray pixels
   - Refine edges
   - Check contrast
   - Verify against color palette

**Tools:**
- Aseprite (recommended) - $19.99
- Photoshop with pixel art settings
- GIMP (free) with pixel art plugins
- LibreSprite (free Aseprite fork)

**Deliverables:** 10×10 base sprite PNG

---

### Phase 3: Animation (2-6 hours)

**Objective:** Create smooth animations with minimal frames

**Animation Types:**

**Idle Animation (2-4 frames)**
- Subtle breathing/swaying
- 1-2 second loop
- Minimal pixel movement (1-2 pixels max)
```
Frame 1: Base pose
Frame 2: Slight variation (breath in)
Frame 3: Return to base
Frame 4: Variation (breath out)
```

**Walk Cycle (4-6 frames)**
- Classic walk animation
- Head bob, arm swing, leg movement
- 0.5 second full cycle (8 frames @ 60fps each frame 4 frames)
```
Frame 1: Contact (foot down)
Frame 2: Low point
Frame 3: Passing pose
Frame 4: High point
Frame 5: Contact (other foot)
Frame 6: Return cycle
```

**Attack Animation (3-5 frames)**
- Wind-up, strike, recovery
- Fast motion (0.3-0.5 seconds total)
```
Frame 1: Ready pose
Frame 2: Wind-up
Frame 3: Strike/fire (impact frame)
Frame 4: Follow-through
Frame 5: Return to ready
```

**Death Animation (3-6 frames)**
- Unit collapse/disintegration
- Final frame persists (corpse)
- 0.5-1 second duration
```
Frame 1: Hit reaction
Frame 2: Stagger
Frame 3: Begin fall
Frame 4: Mid-fall
Frame 5: Ground impact
Frame 6: Final corpse state (persistent)
```

**Animation Best Practices:**
- Use onion skinning (show previous/next frames)
- Test at full speed (60 FPS)
- Maintain silhouette readability
- Minimize pixel changes between frames
- Follow 12 principles of animation (timing, anticipation, etc.)

**Deliverables:** Animated sprite sheet with frame data

---

### Phase 4: Sprite Sheet Compilation (30 minutes - 1 hour)

**Objective:** Organize sprites into efficient sprite sheets

1. **Layout sprites**
   - Arrange in logical grid (8×8, 16×16, etc.)
   - Group related animations
   - Leave 1-2 pixel padding between sprites
   - Use power-of-two dimensions (128, 256, 512, 1024)

2. **Create frame data**
   - Document sprite positions (x, y, width, height)
   - Define animation sequences
   - Set frame durations (in frames @ 60 FPS)
   - Mark hitboxes/collision bounds

3. **Optimize file**
   - Remove unused space
   - Compress with PNG optimizer (pngquant, optipng)
   - Verify file size under budget
   - Test load times

**Example Sprite Sheet Layout:**
```
[Idle 1][Idle 2][Idle 3][Idle 4]
[Walk 1][Walk 2][Walk 3][Walk 4]
[Atk 1 ][Atk 2 ][Atk 3 ][Atk 4 ]
[Death1][Death2][Death3][Death4]
```

**Deliverables:** Sprite sheet PNG + frame data JSON/TOML

---

### Phase 5: Integration (1-2 hours)

**Objective:** Import assets into game engine

1. **Add to project**
   ```
   assets/sprites/units/unit_name.png
   assets/data/units/unit_name.toml
   ```

2. **Configure sprite data**
   ```toml
   [sprite]
   sheet = "sprites/units/unit_name.png"
   frame_width = 10
   frame_height = 10
   scale = 2
   
   [animations.idle]
   frames = [0, 1, 2, 3]
   frame_duration = 15  # frames @ 60 FPS
   loop = true
   
   [animations.walk]
   frames = [4, 5, 6, 7]
   frame_duration = 8
   loop = true
   
   [animations.attack]
   frames = [8, 9, 10, 11]
   frame_duration = 5
   loop = false
   
   [animations.death]
   frames = [12, 13, 14, 15]
   frame_duration = 10
   loop = false
   persist_final = true
   ```

3. **Test in-game**
   - Verify rendering at correct scale
   - Test all animations
   - Check performance (FPS)
   - Validate collision detection

4. **Adjust if needed**
   - Fix any rendering issues
   - Tweak animation timing
   - Adjust colors if needed
   - Update documentation

**Deliverables:** Integrated asset ready for gameplay

---

## UI Asset Creation

### UI Element Specifications

**Buttons:**
- Size: 4×2 grid units (80×40 pixels)
- States: Normal, hover, pressed, disabled
- Text: System font or pixel font
- Alignment: Center both axes

**Panels:**
- Size: Multiples of 20 pixels (grid alignment)
- Border: 1-2 pixel solid or patterned
- Background: Solid color or subtle pattern
- Transparency: Opaque or semi-transparent overlay

**Icons:**
- Size: 1×1 grid unit (20×20 pixels) or 2×2 (40×40)
- Style: Simple, high contrast
- Background: Transparent
- Color: Match UI palette (blues, grays)

**Windows:**
- Title bar: 40 pixels (2 grid units)
- Content area: Multiple of 20 pixels
- Scrollbars: 20 pixels wide (1 grid unit)
- Close button: 20×20 pixels

### UI Asset Workflow

1. **Wireframe layout** (15 minutes)
   - Sketch on grid paper or digital canvas
   - Plan button/panel placement
   - Verify 20×20 alignment

2. **Create base elements** (1-2 hours)
   - Design button styles
   - Create panel backgrounds
   - Design icons and symbols
   - Maintain consistent style

3. **Add interaction states** (30 minutes)
   - Hover effects (brightness +10%)
   - Pressed effects (brightness -10%)
   - Disabled effects (desaturate)

4. **Compile UI sheet** (30 minutes)
   - Organize by component type
   - Create 9-slice data for scalable panels
   - Document dimensions

5. **Integration testing** (1 hour)
   - Test at 800×600 resolution
   - Verify grid alignment
   - Test mouse interaction
   - Check accessibility (contrast)

---

## Tileset Creation

### Tile Specifications

**Tile Size:**
- Base: 10×10 pixels
- Display: 20×20 pixels (×2 scale)
- Grid: Isometric or square (project uses square)

**Tile Types:**
- Floor tiles: Flat, walkable surfaces
- Wall tiles: Vertical obstacles, line-of-sight blockers
- Props: Decorative objects, cover elements
- Interactive: Doors, terminals, destructibles

### Tileset Workflow

1. **Define tile palette** (1 hour)
   - List needed tile types (floor, wall, props)
   - Determine variations (damaged, alternate colors)
   - Plan autotile rules (tile connections)

2. **Create base tiles** (3-6 hours)
   - Floor variations (concrete, metal, dirt)
   - Wall variations (straight, corners, caps)
   - Props (crates, terminals, furniture)
   - Maintain consistent lighting direction

3. **Create transitions** (2-4 hours)
   - Floor-to-floor transitions
   - Wall corner pieces
   - Elevation changes
   - Autotile configurations

4. **Compile tileset** (1 hour)
   - Organize in logical grid
   - Create autotile mapping data
   - Document tile IDs
   - Add collision/cover data

5. **Test in map editor** (1-2 hours)
   - Build test map
   - Verify tile connections
   - Check visual consistency
   - Adjust as needed

**Deliverables:** Tileset sprite sheet + tile data TOML

---

## Effect & VFX Creation

### Effect Types

**Projectile Effects:**
- Muzzle flash (2-3 frames)
- Bullet trail (line particle)
- Impact effect (3-5 frames)
- Smoke puff (4-6 frames)

**Explosion Effects:**
- Expansion (3-5 frames)
- Debris particles (8-12 particles)
- Shockwave ring (fade over 10 frames)
- Smoke aftermath (6-8 frames)

**Status Effects:**
- Poison cloud (animated loop)
- Electricity arcs (flicker effect)
- Fire particles (upward drift)
- Healing sparkles (float and fade)

### VFX Best Practices

1. **Keep it simple** - Effects should enhance, not distract
2. **Use bright colors** - Make effects visible against gameplay
3. **Short duration** - 0.2-0.5 seconds typical
4. **Particle efficiency** - Limit particle count (10-20 max)
5. **Reuse components** - Modular effect pieces

**Deliverables:** Effect sprite sheet + particle system data

---

## Asset Validation Checklist

Before submitting asset for integration:

- [ ] Correct dimensions (10×10 for sprites, 20×multiple for UI)
- [ ] Uses approved color palette only
- [ ] PNG format with correct transparency
- [ ] File size under budget (sprites <50KB, sheets <200KB)
- [ ] Frames aligned to pixel boundaries
- [ ] Animation timing feels smooth at 60 FPS
- [ ] Readable silhouette at display scale (×2)
- [ ] Consistent art style with existing assets
- [ ] No anti-aliasing or interpolation artifacts
- [ ] Proper file naming (snake_case)
- [ ] Documented in sprite data file (TOML)
- [ ] Tested in-game rendering
- [ ] Performance validated (60 FPS maintained)
- [ ] Accessible (sufficient contrast for colorblind players)
- [ ] Approved by art director

---

## Common Pitfalls

### ❌ Wrong Resolution
**Problem:** Creating assets at wrong base size  
**Solution:** Always start with 10×10 pixel canvas, scale ×2 for display

### ❌ Anti-Aliasing
**Problem:** Soft edges from Photoshop smoothing  
**Solution:** Disable anti-aliasing, use nearest-neighbor, manual edge control

### ❌ Palette Breaking
**Problem:** Using colors outside approved palette  
**Solution:** Set up indexed color mode with palette loaded

### ❌ Over-Detail
**Problem:** Trying to add too much detail to 10×10 canvas  
**Solution:** Simplify! Each pixel is precious. Focus on silhouette and key features

### ❌ Poor Animation
**Problem:** Jerky movement or unclear actions  
**Solution:** Use onion skinning, follow animation principles, test at speed

### ❌ Grid Misalignment
**Problem:** Sprites not aligning to pixel/grid boundaries  
**Solution:** Snap to grid, verify positions in powers of 20

### ❌ File Size Bloat
**Problem:** Unoptimized PNGs causing slow load times  
**Solution:** Use PNG optimizers (pngquant, optipng)

### ❌ Inconsistent Style
**Problem:** New assets don't match existing art  
**Solution:** Study reference assets, maintain consistent lighting/perspective

---

## Tools & Resources

### Recommended Software

**Primary Tool:**
- **Aseprite** ($19.99) - Best pixel art editor, animation support
  - [https://www.aseprite.org/](https://www.aseprite.org/)

**Alternatives:**
- **LibreSprite** (Free) - Open source Aseprite fork
- **GIMP** (Free) - With pixel art plugins
- **Photoshop** - With pixel art settings configured
- **GraphicsGale** (Free) - Classic pixel art tool

### Plugins & Extensions

- **Aseprite Scripts:** Automation for export, palette management
- **GIMP Pixel Art Plugin:** Grid snapping, palette tools
- **TexturePacker:** Automated sprite sheet generation

### Reference Resources

- **Lospec Palette List:** Curated pixel art palettes
- **PixelJoint:** Pixel art community and tutorials
- **Pixel Art Tutorials:** opengameart.org resources
- **X-COM Sprite Rips:** Study classic XCOM sprites

### Color Tools

- **Coolors.co:** Palette generation
- **Paletton:** Color scheme designer
- **Color Oracle:** Colorblind simulation

---

## Asset Pipeline Integration

### File Organization
```
assets/
├── sprites/
│   ├── units/
│   │   ├── soldier.png
│   │   ├── alien_sectoid.png
│   │   └── civilian.png
│   ├── items/
│   │   ├── weapons.png
│   │   └── equipment.png
│   ├── tiles/
│   │   ├── urban_tileset.png
│   │   └── alien_tileset.png
│   └── effects/
│       ├── explosions.png
│       └── projectiles.png
├── ui/
│   ├── buttons.png
│   ├── panels.png
│   └── icons.png
└── data/
    ├── sprite_definitions.toml
    └── animation_data.toml
```

### Version Control

- Commit source files (.ase, .psd) to separate repo
- Commit only exported PNGs to game repo
- Tag major asset revisions
- Document changes in commit messages

### Collaboration

- Use shared color palette file
- Maintain style guide document
- Regular art direction reviews
- Centralized asset repository

---

## Related Documentation

- [[README]] - Content pipeline overview
- [[Map_Block_Authoring]] - Creating map tiles
- [[../../GUI/README]] - UI system documentation
- [[../../technical/README]] - Technical specifications

---

**Document Status:** Complete  
**Review Date:** October 7, 2025  
**Owner:** Art Director
