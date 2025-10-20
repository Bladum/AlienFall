# 3D Battlescape: Optional First-Person Alternative

## Table of Contents

- [Foundation & Design Principle](#foundation--design-principle)
- [Available Perspectives](#available-perspectives)
- [Hex Projection & 3D Architecture](#hex-projection--3d-architecture)
  - [Hexagonal Grid in 3D](#hexagonal-grid-in-3d)
  - [Movement & Animation](#movement--animation)
  - [Visual Hex Verification](#visual-hex-verification)
- [Vision & Targeting System](#vision--targeting-system)
  - [Range Calculation](#range-calculation)
  - [Line-of-Sight Calculation](#line-of-sight-calculation)
  - [Vision Cone (First-Person)](#vision-cone-first-person)
  - [Elevation Effects](#elevation-effects)
- [Combat Parity](#combat-parity)
  - [Damage Calculation (Identical)](#damage-calculation-identical)
  - [Accuracy Formula (Identical)](#accuracy-formula-identical)
  - [Weapon Effects](#weapon-effects)
- [3D Movement & Controls](#3d-movement--controls)
  - [Movement Mechanics](#movement-mechanics)

## Foundation & Design Principle

Alternative visual representation of identical hex system. NOT a different gameâ€”same mechanics, numbers, balance, and physics. Perspective cosmetic only.

**Core Principle**: Mechanical parity between 2D and 3D perspectives
- Same damage calculations
- Same accuracy formulas
- Same range calculations
- Same movement costs
- Same cover mechanics
- Same line-of-sight
- Same morale and status effects

**Benefit**: 2D and 3D players never disadvantaged; single balance/testing pass

## Available Perspectives

| Perspective | View | Focus | Audience | Performance |
|-------------|------|-------|----------|-------------|
| **Top-Down 3D** | 45Â° elevated | Strategy overview, full map visibility | Tactical planners | High performance |
| **Behind-Shoulder** | Unit shoulder position | Immersion, nearby detail | Balanced players | Medium performance |
| **First-Person** | Eye level, limited FOV | Immersive combat, visceral feel | Action-focused players | Medium performance |

## Hex Projection & 3D Architecture

### Hexagonal Grid in 3D

**Coordinate Mapping**:
- 2D hex maps to 3D X-Y position + Z elevation
- 6 neighbors = compass directions: NW, NE, E, SE, SW, W
- Same pathfinding logic; now includes elevation transitions

### Movement & Animation
- Game State: Unit positioned on hex grid (instant)
- Visual Representation: Smooth 3D interpolation (1-2 seconds)
- Result: Cinematic feel with mechanical discreteness

### Visual Hex Verification
- Toggle feature: Press 'T' for wireframe hex grid overlay
- Purpose: Verify targeting, learn 3D-to-state mapping
- Useful for learning 3D system
- Toggle off when experienced player

## Vision & Targeting System

### Range Calculation

**Mechanical Range** (Identical to 2D):
- Range = same hexes Ă— hex size (48 units 3D scale)
- Weapon range functionally identical in both perspectives
- No range advantage from 3D perspective

### Line-of-Sight Calculation

**Raycast Method**:
- Raycast from attacker eye position â†’ target center
- Hit terrain = cover effectiveness applied
- Elevation affects accuracy:
  - Upshot: -accuracy penalty (shooting upward)
  - Downshot: +accuracy bonus (shooting downward)

### Vision Cone (First-Person)

**Field of View**:
- 90Â° total vision cone (45Â° left/right)
- 15 hex distance vision range
- Peripheral slightly visible
- Behind unit invisible

### Elevation Effects

**Tactical Considerations**:
- High ground provides accuracy bonus
- Low ground receives accuracy penalty
- Visual height change represents elevation difference
- Same mechanical effects as 2D

## Combat Parity

### Damage Calculation (Identical)

Formula: Damage = BaseWeaponDamage Ă— AccuracyRoll Ă— ArmorReduction

- Identical results in 2D and 3D
- Perspective doesn't affect calculation
- Outcomes guaranteed identical

### Accuracy Formula (Identical)

- Base accuracy + skill modifiers
- Range penalties calculated identically
- Cover bonuses applied equally
- Morale effects apply equally

### Weapon Effects

- Damage falloff with distance (identical)
- Critical hits calculated identically
- Armor penetration identical
- Status effects apply identically

## 3D Movement & Controls

### Movement Mechanics

**Hex-Based Movement**:
- **W or Up Arrow**: Forward one hex (in facing direction)
- **S or Down Arrow**: Backward one hex
- **A or Q**: Rotate 60Â° counterclockwise (or Tab)
- **D or E**: Rotate 60Â° clockwise
- **Diagonal**: Combination of forward + rotation

**Movement Modes**:

| Mode | Speed | Sight Penalty | Detection | AP Cost |
|------|-------|---------------|-----------|---------|
| **Walk** | Normal | None | Normal | Standard |
| **Run** | 2Ă— speed | -3 sight | +detection | Standard |
| **Sneak** | Â˝ speed | -3 sight | +concealment | Standard |
| **Kneel** | Reduced | None | -3 sight | No AP cost |

**Unit Selection**:
- **Tab Key**: Switch to next squad member
- Retains same position, can control different unit
- Useful for multi-unit squad control

#### Terrain Navigation

**Terrain Rendering**:
- Terrain renders as 3D floor with height variation
- Obstacles render as 3D walls of various heights
- Destructible terrain appears as structure/rubble
- Elevation visually represented as height change

**Distance Estimation**:
- Distance displayed numerically (UI: "12 hexes to target")
- Visual perspective provides distance cues
- Weapon range overlay shows effective range
- Fog and weather affect perceived distance

### Targeting & Aiming System

#### Aiming Interface

**Center Reticle**:
- Indicates aimed direction
- Color-coded target validity:
  - Green: Clear shot, good accuracy
  - Yellow: Marginal shot (partial cover/angle)
  - Red: Blocked shot, cannot fire

**Lock-On Mechanic**:
- Snaps to valid targets
- Shows target health/status

**Accuracy Verification**:
- Visual aiming is cosmetic (for immersion)
- Actual accuracy identical to 2D
- Hit/miss determined by formula, not visual aim quality

#### Trajectory Visualization

**Grenade Aiming**:
- Trajectory visualization shows grenade path
- Arc displays before throw
- User can adjust aim before commit

**Suppression Mechanics**:
- Suppression creates fire arc lock
- Weapon must maintain aimed direction
- Prevents rapid retargeting under fire

### Squad Awareness & HUD

#### Squad Panel Display

**Information Available**:
- Health percentage and current HP
- Morale status
- Action Points remaining
- Status effects (stunned, suppressed, etc.)
- Equipment status (ammo, cooldowns)

**Unit Indicators**:
- Direction indicator (compass bearing to squad member)
- Distance indicator (hexes to squad member)
- Translucent unit highlights (see through walls)
- Formation maintained (units follow squad layout)

#### Audio Callouts

**Squad Communication**:
- Squad leader gives voice commands
- Unit status announcements
- Critical notifications (enemy contact, low health, etc.)
- Audio provides information without requiring visual confirmation

#### Minimap

**Corner Overlay**:
- 2D top-down view in corner
- Shows visible units
- Shows explored terrain
- Fog-of-war displayed as dark areas
- Helps with situational awareness

### Vision & Lighting

#### Day/Night Lighting

**Day Conditions**:
- Bright standard lighting
- Full vision range (120Â° FOV)
- Colors rendered naturally

**Night Conditions**:
- Dark lighting, limited visibility
- Range reduced to â…“ of day range
- Blue tinting applied
- Creates tension and immersion

#### Flashlight System

**Flashlight Equipment**:
- Creates artificial light radius
- Reveals terrain within cone
- Announces unit position to enemies
- Strategic trade-off: visibility vs. stealth

#### Field of View Management

**Equipment Effects on FOV**:
- Equipment extends range (scopes, targeting systems)
- Heavy armor might reduce peripheral vision
- Light gear improves vision
- Mechanics consistent with 2D balance

### Audio Design in 3D

#### Binaural Spatialization

**Directional Audio Cues**:
- Right fire â†’ right speaker
- Distant explosion â†’ muffled
- Nearby grenade â†’ loud directional
- Adds immersion and tension

**Sound Type Examples**:
- Footsteps (distance and direction)
- Gunfire (weapon type and range)
- Explosions (impact and shock wave)

---

### 3D Integration with Multiplayer

**Cross-Perspective Teams**: Both 2D and 3D players can fight together in same mission
**Simultaneous Play**: One player in 3D first-person, another in 2D isometric, same results
**No Performance Divide**: Mechanics identical, perspective purely cosmetic

### Rendering & Visual Effects

#### Environmental Rendering

**Destructible Environment Visualization**:
- 3D walls crumble when destroyed (vs 2D icon removal)
- Fire spreads with particle effects and light
- Water from fire suppression creates realistic wet ground texture

**Dynamic Destruction Chains**:
- Destroying building damages nearby structures
- Creating fire spreads to adjacent buildings
- Player must decide if creating new problems worse than immediate threat

#### Particle Effects & Weather

**Fire System**:
- 3D flames + heat shimmer
- Illuminates surroundings (dynamic lighting)
- Spreads to flammable structures

**Smoke System**:
- Volumetric smoke in 3 density levels:
  - Level 1: LOS -2 hexes, -5% accuracy
  - Level 2: LOS -4 hexes, -10% accuracy
  - Level 3: LOS -6 hexes, -15% accuracy
  - Stun duration: +1 per turn in smoke

**Weather Effects**:
- **Rain**: Wet screen, puddles create movement costs, diffuse lighting
- **Snow**: Reduced visibility, wind affects grenades
- **Dust Storm**: Orange haze, wind audio, disorientation effect
- **Fog**: Volumetric, audio-muffled, eerie atmosphere
- **Sandstorm**: Limits range, creates temporary cover, disorienting effect

#### Unit Rendering

**Unit Representation**:
- Units render as sprites (always camera-facing)
- Status visible on unit (health color, icons)
- Equipment displays (weapon, armor, gear)
- Scale adjusts by distance (appears smaller when far)

#### Performance Optimization

**Rendering Techniques**:
- Frustum culling (only visible hexes rendered)
- Level-of-Detail (distant low-poly, near detailed)
- Unit LOD (near units animated, distant units sprite-based)
- Particle optimization (max particle budget)

**Performance Targets**:
- 60 FPS on mid-range hardware (GTX 1070)
- 30 FPS on low-end hardware
- Adjustable LOD slider for player control
- Top-down more performant than first-person

### Multiplayer in 3D

#### Cooperative Play

**Multi-Unit Control**:
- Each player controls one unit's 3D perspective
- Squad is shared (all players see same squad)
- Players can see each other's units

**Squad Coordination**:
- Requires communication (not all info visible to each player)
- Squad leader or tactical player manages overview
- Individual players execute tactical roles

#### Perspective Switching

**Toggle Mechanic**:
- Switch between 2D and 3D at any point during mission
- No cooldown or penalty
- Game state preserved during switch
- Pure view change, all mechanics identical

**Tactical Use**:
- Use 2D for planning and strategy
- Switch to 3D for execution and immersion
- Alternate perspectives for different tactical needs

### Accessibility Features

#### Text-to-Speech

- Unit announcements spoken
- Status updates audible
- Helps players with visual limitations

#### Colorblind Support

- Patterns + colors (not color-only indicators)
- Multiple visual cues for status
- Works identically in 2D/3D

#### Hearing Impaired Support

- Comprehensive subtitle system
- Visual indicators for audio events
- Status messages display visually

#### Motor Accessibility

- Controller support for:
  - Camera control
  - Unit selection
  - Targeting
- Keyboard-only option still available
- No required rapid input combinations

#### Universal Design

- Accessibility works identically in 2D/3D
- No advantage from choosing one perspective
- All features available in both modes

### 3D-to-2D State Synchronization

#### Shared Game State

**Identical Systems**:
- Hex grid (fundamental)
- Unit positions stored in axial coordinates
- Distance calculations identical
- Line-of-sight calculations identical

**Identical Mechanics**:
- Turn order: Player â†’ Ally â†’ Enemy â†’ Neutral
- Action Points and Energy Points
- All timing mechanics (stun recovery, fire spread)
- Morale progression

**Identical Combat**:
- Weapon accuracy calculation
- Damage application
- Critical hits and armor resistance
- Status effect progression

**Identical Objectives**:
- Mission objectives identical
- Victory/defeat conditions trigger identically
- Difficulty scaling affects both equally

#### Switching Between Perspectives

**Toggle Mechanic**:
- Player can switch between 2D and 3D at any point
- No cooldown or penalty
- Both perspectives show identical game state
- Switching is pure view change only
- All state preserved (AP, position, equipment, morale)

**Information Access**:
- 2D View: Omniscient tactical overview
- 3D View: Limited by unit field-of-view
- 2D enables perfect information management
- 3D requires inference from team

**Tactical Differences**:
- 2D emphasizes macro-strategy
- 3D emphasizes individual unit execution

### Continuity Principle

**Design Guarantee**: All 3D extensions maintain mechanical parity with 2D system
- No gameplay split between perspectives
- 2D players never disadvantaged
- 3D players never advantaged
- Single balance and testing pass required
- Identical outcomes regardless of perspective chosen

### 3D Combat Controls & Mechanics

#### Targeting & Firing

**Primary Attack**:
- Left-click: Primary weapon attack
- Accuracy identical to 2D formula
- Trajectory prediction available

**Secondary Attack**:
- Right-click: Secondary weapon or alternate fire mode

**Special Abilities**:
- Grenade throwing with trajectory prediction
- Shows arc before commit
- Player can adjust aim

#### Cover System

**Taking Cover**:
- **C-Key**: Activate cover (costs 3 AP, +1 cover level, -movement)
- Increases accuracy defense
- Reduces unit visibility

**Overwatch Mode**:
- **R-Key**: Activate overwatch (costs 2-4 AP)
- Enables reaction fire
- Attacks targets entering line-of-fire
- Maintains fire arc lock

#### Fire Mechanics

**Fire Spread**:
- 2 HP damage per turn from fire
- Ignition: -1 HP per turn until extinguished (N turns)
- Spreads to adjacent hexes
- Creates smoke on spread

**Smoke Creation**:
- Fire creates smoke automatically
- Volumetric smoke blocks vision
- Affects accuracy

**Heavy Weapons**:
- Special weapons ignite terrain
- Create secondary effects
- Environmental destruction

#### Day/Night Effects

**Visibility Changes**:
- Night vision: â…“ of day range
- Units have sight stats
- Darkness mechanic affects perception

**UI Adjustments**:
- Blue-tint applied at night
- Lighting changes visually

**Morale Impact**:
- Post-battle +1 sanity damage (night missions)
- Psychological effect of darkness

### Balance & Design Philosophy

#### Information Asymmetry

**3D Perspective Challenges**:
- Limited information (tactical tension)
- Player disadvantage vs. 2D omniscience
- Compensated by squad AI

**Strategic Compensation**:
- Squad AI manages unseen threats
- 2D toggle available anytime
- Audio/radar tactical hints
- Optional easier enemy AI for learning

**Skill Ceiling**:
- Expert players leverage information disadvantage
- Learning curve exists
- Mastery rewarding

#### Performance Targets

**Frame Rate Goals**:
- 60 FPS target (mid-range hardware: GTX 1070)
- 30 FPS minimum (low-end hardware)
- Adjustable LOD slider for player control

**Optimization Techniques**:
- Frustum culling (only visible hexes)
- LOD: Distant low-poly, near detailed
- Particle limits (max budget)
- Top-down faster than first-person

#### Perspective Flexibility

**Anytime Switching**:
- Switch between 2D/3D any time
- No penalty or cooldown
- Game state preserved
- Pure view change only

#### Multiplayer Perspective Support

**Local Multiplayer**:
- 3D experience is local only
- Server maintains 2D canonical state
- Mixed perspectives supported

**Cooperative Play**:
- Commander uses 2D overview
- Squad member uses 3D immersion
- Asymmetric roles (caller vs. doer)

**Competitive Future**:
- Potential 3D combat advantage
- Potential 2D planning advantage
- Balanced for competitive play

### Campaign Integration with 3D

#### Progression Parity

**Identical Progression**:
- Units/missions/equipment unaffected by perspective
- Experience gains identical
- Rewards identical
- Story progression identical

#### Playstyle Flexibility

**Mixed Perspective Play**:
- Use 2D for strategy moments
- Use 3D for action moments
- Switch anytime for optimal play
- Encourages trying both modes

#### Campaign Completion

**No Perspective Lock**:
- Complete campaigns in any perspective mix
- Progress saved regardless of perspective
- Campaign state identical

### Explosion System

#### Area Damage Mechanics

**Explosion Effect**:
- Damages all units in radius
- Damage falloff with distance
- All targets affected equally

#### Knockback Force

**Physical Knockback**:
- Moves units in direction away from explosion
- Force proportional to explosion size
- Can move units into hazards
- Can separate units

#### Environmental Destruction

**Terrain Armor System**:
- Terrain has armor points
- Damage above armor threshold converts to destroyed terrain
- Destroyed terrain no longer provides cover
- Creates new tactical situations

**Destruction Propagation**:
- Effect propagates forward through adjacent hexes
- Multiple destruction levels possible
- Can create cascading collapses
- Strategic destruction chains

---

