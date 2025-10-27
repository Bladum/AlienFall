# 🎨 Pixel Art Best Practices for AlienFall

**Domain**: Pixel Art & Graphics  
**Focus**: Character design, animation, grid systems, tools  
**Version**: 1.0  
**Last Updated**: October 16, 2025

---

## Table of Contents

1. [Core Pixel Art Principles](#core-pixel-art-principles)
2. [Color & Palette Management](#color--palette-management)
3. [24×24 Grid System & Resolution](#2424-grid-system--resolution)
4. [Character Design](#character-design)
5. [Tile & Terrain Design](#tile--terrain-design)
6. [UI Elements](#ui-elements)
7. [Animation Guidelines](#animation-guidelines)
8. [Tools & Workflow](#tools--workflow)
9. [Technical Implementation](#technical-implementation)
10. [Common Mistakes](#common-mistakes)
11. [Quality Checklist](#quality-checklist)
12. [Optimization](#optimization)

---

## Core Pixel Art Principles

### ✅ DO: Respect the Grid

Pixel art lives in a grid. Use it intentionally.

**Grid Awareness:**

```
✓ GOOD: Follows grid lines, clean edges
█████
█   █
█ ◇ █
█   █
█████

✗ BAD: Jagged/staggered, breaks grid
█ █ █
 ███ 
█ ◇ █
 ███ 
█ █ █

Grid alignment:
- Makes art appear crisp
- Easier to animate
- Scales cleanly
- Intentional aesthetic
```

### ✅ DO: Use Consistent Proportions

Proportion rules stay consistent within art style.

**Character Proportions:**

```
Standard Humanoid (16px tall):
Head: 4px
Body: 6px
Legs: 4px
Arms: 5px each

Head
⬜⬜⬜⬜
⬜👀⬜⬜

Body/Arms
⬜⬜🎯⬜⬜
⬜⬜⬜⬜⬜
⬜🎯🎯🎯⬜

Legs
⬜⬜⬜
⬜⬜⬜
🟩⬜🟩

This ratio stays consistent across all characters
Variants: Taller (18px), Shorter (12px), but ratio consistent
```

### ✅ DO: Plan for Animation

Design with movement in mind.

**Animation-Friendly Design:**

```
Limbs should be separable:
- Separate arms (can rotate)
- Separate legs (can rotate)
- Head distinct from body (can turn)
- Torso as core piece

NOT good for animation:
- Arms fused to body
- Single-piece character
- Complicated shapes
```

---

## Color & Palette Management

### ✅ DO: Use Limited, Cohesive Palettes

Restriction breeds creativity.

**Palette Strategy:**

```
Standard Palette (16 colors for one character):
- Black: #000000 (outlines, shadows)
- Dark Gray: #4a4a4a (shadows)
- Gray: #808080 (mid-tones)
- Light Gray: #c0c0c0 (highlights)
- White: #ffffff (bright highlights)

Primary Colors (5 colors):
- Red: #e74c3c (armor/uniform)
- Green: #27ae60 (accents)
- Blue: #3498db (secondary color)
- Yellow: #f39c12 (warnings/special)
- Orange: #e67e22 (details)

Total: 15 colors (1 slot for transparency)
Keep entire tileset within this palette
```

### ✅ DO: Use Dithering Strategically

Dithering adds texture without extra colors.

**Dithering Patterns:**

```
No Dither (Banding):
███████
███████
███████

Dithering (Texture):
███▓███
▓██████
███▓▓██

Use dithering:
- In large flat areas
- For shadow transitions
- To add visual interest

Don't overuse: Makes art busy
```

### ✅ DO: Implement Color Ramps

Create consistent color transitions.

**Ramp Structure:**

```
Red Ramp (for consistent shading):
Darkest:  #8b0000 (very dark red)
Dark:     #c41e3a (dark red)
Mid:      #e74c3c (red)
Light:    #f47174 (light red)
Lightest: #ffb3ba (very light red)

Use same ramp for all red objects
Consistency = Professional look
```

### ❌ DON'T: Use Too Many Colors

Limit palette for retro aesthetic.

**Bad Palette Management:**

```
✗ 256-color palette for single character
✗ Different colors for similar elements
✗ Not enough contrast between objects
✗ Random color choices

Result: Muddy, confusing appearance
```

---

## 24×24 Grid System & Resolution

### ✅ DO: Build Everything on 24×24 Grid

Universal measurement in AlienFall.

**Grid System:**

```
Game Resolution: 960×720 pixels
Grid Cell: 24×24 pixels
Grid Layout: 40×30 cells (960÷24=40, 720÷24=30)

Each in-game "square" = 24×24 pixels

Examples:
- Character: 1 cell wide (24px)
- Door: 1 cell wide (24px)
- Tree: 1 cell tall (24px)
- Weapon icon: ~16px (fits in cell with margin)

EVERYTHING snaps to grid
```

### ✅ DO: Design with Scaling in Mind

Art should look good at 24×24 and upscaled.

**Scaling Strategy:**

```
Create at 24×24, scaled UP 2x:
24×24 pixel art
    ↓ (Display at 2x scale = 48×48 on screen)
48×48 on screen = still clean

Why 2x scale?
- Easier to see at normal viewing distance
- Maintains pixel-perfect appearance
- No anti-aliasing blur

DON'T create at 12×12 (too small to see detail)
DON'T create at 48×48 (defeats pixel art purpose)
```

### ✅ DO: Maintain Consistent Grid Alignment

Every sprite should snap to grid.

**Alignment Rule:**

```
Sprite at position (0,0) = top-left corner
Each sprite is 24px wide, 24px tall

Position (0,0):   0×0 = top-left
Position (24,0):  1×0 = one right
Position (0,24):  0×1 = one down
Position (48,48): 2×2 = two right, two down

No off-grid positioning (like 23.5, 0)
No sub-pixel rendering

Everything at integer multiples of 24
```

---

## Character Design

### ✅ DO: Design Silhouettes

Characters should be recognizable in silhouette.

**Silhouette Test:**

```
Solid black version should be recognizable:

Commander    Medic        Assault       Sniper
  ◈            ◊            ⊞            ⊘
  ⚡           ⬛           ◇◇           ⬜
  ∆∆           ∥            ⊗            ∆∆

Each different at a glance
If all look similar in silhouette, redesign
```

### ✅ DO: Use Consistent Team Colors

Make faction identification instant.

**Team Color Scheme:**

```
XCOM Soldiers:
- Base: Gray uniform
- Primary: Blue accent (shoulder/arm)
- Stripe: Yellow rank indicator

Aliens:
- Base: Green chitin
- Primary: Yellow/orange accent
- Pattern: Alien-specific markings

Player should know faction instantly
```

### ✅ DO: Design Personality Through Details

Small details make big impact.

**Character Personality:**

```
Soldier Variants:

Heavy:
- Thicker limbs
- Larger upper body
- Broader stance
→ Looks powerful, slow

Scout:
- Thin limbs
- Lean body
- Narrow stance
→ Looks fast, fragile

Support:
- Medium build
- Equipment on back
- Relaxed stance
→ Looks balanced, capable
```

---

## Tile & Terrain Design

### ✅ DO: Design Floor Tiles as Building Blocks

Tiles should connect seamlessly.

**Seamless Tiling:**

```
Grass Tile (24×24):
┌────────────┐
│░░░░░░░░░░░░│
│░ • ░░ • ░░░│
│░░░░░░░░░░░░│
│░ • ░░ • ░░░│
│░░░░░░░░░░░░│
└────────────┘

When tiled:
┌────────────┬────────────┐
│░░░░░░░░░░░░│░░░░░░░░░░░░│
│░ • ░░ • ░░░│░ • ░░ • ░░░│
│░░░░░░░░░░░░│░░░░░░░░░░░░│
│░ • ░░ • ░░░│░ • ░░ • ░░░│
│░░░░░░░░░░░░│░░░░░░░░░░░░│
└────────────┴────────────┘

No seams = professional appearance
```

### ✅ DO: Create Tile Variation Sets

Variety without creating new tiles.

**Variation Strategy:**

```
Base Grass Tile:      A
Rotated 90°:          B (rotated version)
Flipped Horizontally: C (mirror)
Combination variants: A+rotation+flip = D,E,F

Result: 1 base tile → 6 variants
Much less work, more variety
```

### ✅ DO: Design Walls for Isometric/3D Integration

Support multiple perspectives.

**Wall Design:**

```
Wall Tile (Front view):
┌────────────┐
│     ▓▓     │ (top edge, shadow)
│   ▓▓▓▓▓▓   │
│   ▓    ▓   │ (wall face)
│   ▓    ▓   │
│   ▓▓▓▓▓▓   │
└────────────┘

This tilts well for:
- Top-down view (2D)
- Isometric view (3D-like 2D)
- First-person rendering (3D look)
```

---

## UI Elements

### ✅ DO: Design UI Within Grid

All UI elements must respect 24×24 grid.

**UI Sizing:**

```
Standard Sizes (in grid cells):
- Button: 2×1 cells (48×24 pixels)
- Panel Title: 6×1 cells (144×24 pixels)
- Small Icon: 0.5×0.5 cells (12×12 pixels, with margin)
- Large Icon: 1×1 cell (24×24 pixels)
- Text Box: 8×4 cells (192×96 pixels)

All multiples of 24 or divisors
Aligns perfectly on screen
```

### ✅ DO: Create Button States

Show interaction feedback.

**Button States:**

```
Normal (idle):
┌──────────────────┐
│    Play Game     │
└──────────────────┘

Hover (mouse over):
┌──────────────────┐
│ ▶  Play Game  ◀  │
└──────────────────┘ (highlighted)

Active (pressed):
┌──────────────────┐
│   Play Game      │
└──────────────────┘ (pressed in appearance)

Disabled:
┌──────────────────┐
│    Play Game     │ (grayed out)
└──────────────────┘

Clear visual difference for each state
```

### ✅ DO: Design Consistent Icon Set

Icons should match art style.

**Icon Consistency:**

```
Health Icon:     ❤
Energy Icon:     ⚡
Ammo Icon:       🔫
Status Icon:     ⭐
Resource Icon:   💰

All at same size (24×24)
All use same color palette
All at same detail level
Consistent style across entire UI
```

---

## Animation Guidelines

### ✅ DO: Plan Animation Frames

Design sequences that flow naturally.

**Animation Frame Count:**

```
Walk Cycle (4 frames):
Frame 1: Left leg forward
Frame 2: Both legs neutral
Frame 3: Right leg forward
Frame 4: Both legs neutral

Total: 4 frames repeated = smooth walk
Duration: 0.15s per frame = 0.6s cycle

More frames = smoother but larger
Fewer frames = choppier but smaller
Sweet spot: 4-6 frames for most animations
```

### ✅ DO: Use Key Frames

Plan important poses first.

**Key Frame Planning:**

```
Attack Animation (8 frames):
Key Frame 1 (start):   Neutral standing
Key Frame 3 (wind-up): Arm back, ready
Key Frame 5 (attack):  Arm forward, swinging
Key Frame 8 (recovery):Neutral standing

Fill between key frames with in-between poses
Results in smooth, natural movement
```

### ✅ DO: Animate with Purpose

Every animation should communicate.

**Animation Purpose:**

```
Idle Animation:
- Shifts weight slightly
- Subtle breathing
- Purpose: Show character is alive
- Duration: 2-3 seconds

Walk Animation:
- Arms swing opposite to legs
- Head bobs slightly
- Purpose: Clear movement direction
- Duration: 0.6 seconds per cycle

Attack Animation:
- Rapid wind-up to apex
- Clear impact frame
- Purpose: Show action happening
- Duration: 0.3-0.5 seconds

Each animation communicates its action
```

---

## Tools & Workflow

### ✅ DO: Use Appropriate Tools

Different tools for different jobs.

**Recommended Tools:**

```
DRAWING:
- Aseprite: Professional pixel art editor
- Pyxel Edit: Lightweight alternative
- LibreSprite: Free open-source
- GrafX2: Retro, powerful

CONVERSION:
- ImageMagick: Command-line conversion
- GIMP: Free general-purpose editor
- Krita: Digital painting (avoid for pixel art)

ANIMATION:
- Aseprite: Built-in animation support
- Piskel: Web-based, frame-by-frame
- LibreSprite: Free animation support

Use specialized tools for best results
```

### ✅ DO: Organize Asset Files

Clear naming prevents confusion.

**File Naming Convention:**

```
Characters/
├── soldier_idle_001.png
├── soldier_idle_002.png
├── soldier_walk_001.png
├── soldier_walk_002.png
├── alien_idle_001.png
└── alien_attack_001.png

Tiles/
├── grass_001.png
├── grass_002.png
├── wall_stone_001.png
└── floor_metal_001.png

UI/
├── button_normal.png
├── button_hover.png
├── panel_background.png
└── icon_health.png

Format: [entity]_[action]_[frame].png
```

### ✅ DO: Version Control Assets

Track changes safely.

**Versioning Strategy:**

```
project/
├── assets/
│   ├── characters/
│   │   ├── soldier_final/
│   │   │   ├── idle_01.png
│   │   │   ├── idle_02.png
│   │   │   └── walk_01.png
│   │   └── soldier_archive/
│   │       └── soldier_old_01.png
│   └── ...
├── aseprite_source/
│   ├── soldier.ase (source file with layers)
│   ├── tileset.ase
│   └── ui.ase

Store .ASE source files separately
Export PNG when ready
Keep archive for reference
```

---

## Technical Implementation

### ✅ DO: Use Sprite Sheets Effectively

Combine related sprites for efficiency.

**Sprite Sheet Structure:**

```
Soldier Spritesheet (96×48):
┌─────────────┬─────────────┬─────────────┐
│   Idle 1    │   Idle 2    │   Walk 1    │
│ (24×24)     │ (24×24)     │ (24×24)     │
├─────────────┼─────────────┼─────────────┤
│   Walk 2    │  Attack 1   │  Attack 2   │
│ (24×24)     │ (24×24)     │ (24×24)     │
└─────────────┴─────────────┴─────────────┘

Index sprites: [0,0], [1,0], [2,0], [0,1], [1,1], [2,1]
Load once, reuse many times
Faster rendering than individual files
```

### ✅ DO: Implement Sprite Batching

Group renders for performance.

**Batching Strategy:**

```
WITHOUT BATCHING:
Draw unit 1
Draw unit 2
Draw unit 3
Draw unit 4
= 4 draw calls

WITH BATCHING:
Prepare draw list:
  - Unit 1 at position X
  - Unit 2 at position Y
  - Unit 3 at position Z
  - Unit 4 at position W
Render all at once
= 1 draw call

Much faster!
```

### ✅ DO: Use Proper Image Formats

Choose format based on needs.

**Format Guidelines:**

```
PNG:
- Use for: Sprites, UI, final assets
- Pros: Lossless, transparency, smaller
- Cons: Slower to load than raw pixels
- When: Always for finished assets

JPEG:
- Use for: Background art only
- Pros: Very small file size
- Cons: Lossy, no transparency, ugly at 24×24
- When: Never for game sprites

WEBP:
- Use for: Modern platforms (not Love2D default)
- Pros: Smaller than PNG
- Cons: Compatibility issues
- When: Consider for web version

Use PNG for all game sprites
```

---

## Common Mistakes

### ❌ Mistake: Anti-Aliasing

Pixel art shouldn't have blurred edges.

**Problem:**

```
With Anti-Aliasing (BAD):
████░░░░ ← Blurred edge looks soft
████▓▓▓▓
█████████

Without Anti-Aliasing (GOOD):
████░░░░ ← Clean edge looks crisp
████░░░░
█████████

Fix: Save as PNG without anti-aliasing
Or use Paint.NET/Aseprite which avoid it
```

### ❌ Mistake: Scaling Non-Uniformly

Scaling by different amounts in X/Y.

**Problem:**

```
Original (24×24):
████
████

Scaled 2× uniformly (48×48):
████████
████████
████████
████████
✓ Perfect

Scaled 3× in X, 2× in Y (72×48):
██████████████████
██████████████████
██████████████████
✗ Looks stretched and wrong

Always scale uniformly
If need different size, create new sprite
```

### ❌ Mistake: Inconsistent Lighting

Shadows should follow consistent direction.

**Problem:**

```
Light from top-left:

Good:
▓▓▓▓
▓░░░
▓░░░
▓░░░

Bad (inconsistent):
░░░░
░▓░░
░░▓░
░░░▓

Pick direction (top-left = standard)
Stick to it everywhere
```

---

## Quality Checklist

### Before Publishing Artwork:

```
□ Sprite is on 24×24 grid
□ No anti-aliasing artifacts
□ Consistent with character style
□ Silhouette is clear and distinctive
□ Colors match palette (max 16 colors)
□ No stray pixels outside grid
□ Animation frames flow smoothly
□ Sprite works at multiple scales
□ No transparency issues
□ File size is reasonable (<100kb)
□ Named consistently
□ Documented in asset list
```

---

## Optimization

### ✅ DO: Compress Sprites Properly

Reduce file size without quality loss.

**Compression Strategy:**

```
PNG Optimization:
1. Remove unnecessary metadata
2. Use indexed color (256 color mode) when possible
3. Remove interlacing (not needed for games)
4. Maximum compression level

Tools:
- PNGQuant: Reduce colors intelligently
- PNGCrush: Lossless compression
- OptiPNG: Maximum compression
- Aseprite: Built-in compression

Target: <10KB per sprite sheet
```

### ✅ DO: Use Palette Reduction

Fewer colors = smaller files.

**Palette Reduction:**

```
Original: 256 colors per sprite
Reduced: 16 color palette (shared)
File size: 1/16th original

PNGQuant example:
pngquant 16 --ext .png soldier.png
→ soldier.png now uses 16-color palette
```

---

**Version**: 1.0  
**Last Updated**: October 16, 2025  
**Status**: Active Best Practice Guide

*For tool recommendations and detailed tutorials, see tools/README.md*
