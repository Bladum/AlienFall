# ⚔️ Battlescape & Tactical AI Best Practices for AlienFall

**Domain**: Tactical Combat & AI Systems  
**Focus**: Map systems, combat mechanics, AI decision-making, tactics  
**Version**: 1.0  
**Last Updated**: October 16, 2025

---

## Table of Contents

1. [Battlescape Fundamentals](#battlescape-fundamentals)
2. [2D Map System](#2d-map-system)
3. [Movement & Positioning](#movement--positioning)
4. [Combat Mechanics](#combat-mechanics)
5. [Fog of War & Vision](#fog-of-war--vision)
6. [Smoke, Explosives & Effects](#smoke-explosives--effects)
7. [Reaction Fire & Overwatch](#reaction-fire--overwatch)
8. [Morale & Psychology](#morale--psychology)
9. [Individual Unit AI](#individual-unit-ai)
10. [Squad-Level AI](#squad-level-ai)
11. [Team Strategy & Mission AI](#team-strategy--mission-ai)
12. [2D-to-3D Hybrid Implementation](#2d-to-3d-hybrid-implementation)
13. [Common Mistakes](#common-mistakes)

---

## Battlescape Fundamentals

### ✅ DO: Implement Turn-Based Resolution

All actions resolve in order.

**Turn Resolution:**

```
Each turn:
1. Determine action order
2. Player units execute (in order chosen)
3. AI units execute (in coordinated fashion)
4. Environmental effects resolve (fire, explosions)
5. Status effects update (wounds, suppression)
6. Check victory conditions

Result: All actions resolve completely
Next turn begins
```

### ✅ DO: Use Grid-Based Movement

Consistent positioning system.

**Grid System:**

```
Battlescape: 40×30 grid (same as UI grid)
Each cell: 24×24 pixels
Each cell: One unit OR terrain

Unit position: (x, y) in grid cells
Movement: Move to adjacent cell (up/down/left/right)
Diagonal movement: Optional (sometimes blocked)
Out of bounds: Never leave grid
```

### ✅ DO: Implement Action Point System

Limit unit capabilities per turn.

**Action Points (AP):**

```
Standard unit per turn: 2 AP

AP Costs:
- Move 1 cell: 1 AP
- Attack: 1 AP (ranged) or 2 AP (melee)
- Ability: 1-2 AP (depends on ability)
- Reload: 1 AP
- Use item: 1 AP

Turn examples:
Option A: Move(1) + Attack(1) = Both actions
Option B: Move(1) + Move(1) = Two moves far
Option C: Attack(1) + Attack(1) = Suppression fire

Player chooses each action
```

---

## 2D Map System

### ✅ DO: Design Tactical Map Layouts

Maps should encourage tactical decision-making.

**Map Design Principles:**

```
Good tactical maps:
- Multiple cover positions
- Elevated positions (high ground)
- Alternate paths (flanking routes)
- Chokepoints (defensible areas)
- Open areas (risk vs reward)

Example layout:
┌─────────────────────────────┐
│ Forest    |    Rocky Path   │  ← Elevation
│ ▓▓▓ ▓▓ ▓  |  ▯▯ ▯▯ ▯       │
│ High cover| Medium cover    │
│           |                 │
│   ◆ (Aliens spawn here)    │
│  ▓▓ ▓▓ ▓   |  ▯ ▯ ▯ ▯     │
│ Heavy     | Light          │
│           |                 │
│ □□□ Ruins □□□ ← Player spawn
└─────────────────────────────┘

Design encourages player thinking
```

### ✅ DO: Implement Elevation System

Height adds tactical depth.

**Elevation:**

```
Elevation levels: 0 (ground) to 2 (high)

Elevation effects:
- Line of sight: Higher sees further
- Cover: Unit above target = target exposed
- Movement: Stairs/ramps cost extra AP
- Fall damage: Falling from height hurts

Implementation:
Unit position: (x, y, z)
z = elevation (0, 1, or 2)

Examples:
z=0: Ground level
z=1: Rooftop (high ground advantage)
z=2: Mountain peak (best view)
```

---

## Movement & Positioning

### ✅ DO: Implement Pathfinding

Units need to find routes around obstacles.

**Pathfinding Algorithm:**

```
A* Algorithm (standard for games):
Start position, goal position, obstacles

1. Open list: positions to explore
2. Closed list: positions already explored
3. Iterate:
   - Find lowest-cost open position
   - Move to closed list
   - Add neighbors to open list
   - Calculate cost: distance + heuristic

Result: Shortest path around obstacles

Usage:
path = findPath(unit.x, unit.y, goalX, goalY)
for i, node in ipairs(path) do
    unit:moveTo(node.x, node.y)
end
```

### ✅ DO: Respect Cover for Movement

Unit positions relative to cover matter.

**Cover Mechanics:**

```
Cover types:
- Light cover: +50% dodge
- Heavy cover: +75% dodge
- Full cover: Cannot be hit from certain angles

Unit positioning:
□□□ Cover
  S (Soldier at cover)

Position matters:
- Soldier behind cover = protected
- Soldier exposed = vulnerable
- Flanked soldier = cover ineffective

Pathfinding should consider cover
```

---

## Combat Mechanics

### ✅ DO: Calculate Hit Chance Transparently

Show players the odds.

**Hit Chance Calculation:**

```
Hit Chance = Base × (distance modifier) × (cover modifier) × (stance modifier)

Example:
Base accuracy: 80%
Distance (long): ×0.8 = 64%
Target in light cover: ×0.5 = 32%
Shooter crouched: ×1.1 = 35.2%

Display to player: 35% hit chance

Transparent = informed decisions
```

### ✅ DO: Implement Variance in Damage

Randomness, but predictable.

**Damage Calculation:**

```
Base Damage = Weapon.damage
Modifiers:
- Armor reduction: -armor × 0.5
- Critical: ×1.5 (if critical hit)
- Difficulty: ×difficultyModifier

Variance: ±10% of final damage
Example: 20 damage → 18-22 damage

Variance formula:
final = baseDamage × (0.9 + random(0, 0.2))

Enough variance to matter
Not so much that it's random
```

### ✅ DO: Implement Special Attack Modes

Give player tactical options.

**Attack Modes:**

```
Standard Attack:
- 1 AP cost
- 1 attack roll
- Single target
- Average damage

Burst Fire (multiple shots):
- 1 AP cost
- 3 shots, each 50% accuracy
- Single target
- Can apply suppression

Suppressive Fire (keep enemy pinned):
- 1 AP cost
- Enemy gets -50% accuracy next turn
- Prevents enemy from moving
- Tactical, not necessarily damaging
```

---

## Fog of War & Vision

### ✅ DO: Implement Line of Sight (LoS)

Limited vision creates tension.

**Line of Sight:**

```
Unit can see:
- All tiles in range (e.g., 10 cells)
- Only if straight line to target
- Blocked by walls, heavy terrain
- Limited by elevation (uphill harder to see)

LoS check:
function canSee(from, to)
    if distance(from, to) > range then return false end
    
    -- Trace line from to see if blocked
    if isPathBlocked(from, to) then return false end
    
    return true
end

Fog of war: Unseen areas black
Revealed areas: Can see but dim
Visible areas: Bright/current
```

### ✅ DO: Create Exploration Reward

Discovering enemies should feel good.

**Discovery Mechanic:**

```
When enemy becomes visible:
1. Brief highlighting/animation
2. Sound effect
3. Enemy added to UI list
4. Combat log message: "Enemy spotted!"

Result: Player feels tension and victory
Discovery is rewarding moment
```

---

## Smoke, Explosives & Effects

### ✅ DO: Implement Environmental Effects

Grenades and explosions change battlefield.

**Grenade/Explosive System:**

```
Throwable grenade:
- AP cost: 1 (to throw)
- Blast radius: 4 cells
- Damage: 30-40
- Effect: Smoke cloud

Grenade effects:
- Direct hit: Full damage
- Nearby: Reduced damage
- Smoke: Blocks LoS for 3 turns

Smoke implementation:
tile[x][y].smoke = 3  -- 3 turns of smoke
canSee(from, to) checks for smoke in path
```

### ✅ DO: Implement Fire/Status Effects

Environmental hazards add complexity.

**Status Effects:**

```
Burning:
- Takes 5 damage per turn
- Lasts until healed
- Spreads in dry terrain (chance)

Poison:
- Takes 2 damage per turn
- Lasts 5 turns
- Can be healed

Suppression:
- -50% accuracy next attack
- Lasts 1 turn
- Multiple suppressions don't stack

Implementation:
unit.statusEffects = {
    burning = 5,    -- 5 turns remaining
    suppressed = 1  -- 1 turn remaining
}
```

---

## Reaction Fire & Overwatch

### ✅ DO: Implement Overwatch Mechanic

Units can wait and react to enemies.

**Overwatch System:**

```
Overwatch action:
- AP cost: 1
- Effect: Unit waits for enemy movement
- Trigger: Enemy moves within LoS
- Response: Unit attacks automatically

Implementation:
unit.status = "overwatch"
unit.apRemaining = 1  -- Can fire once

When enemy moves:
if targetInLoS(overwatchUnit, movingEnemy) then
    targetInRange(overwatchUnit, movingEnemy) and
    overwatchUnit:attack(movingEnemy)
    overwatchUnit.apRemaining = 0  -- Used up
end
```

### ✅ DO: Balance Reaction Fire

Can't be too powerful.

**Reaction Fire Balance:**

```
Overwatch limitations:
- Costs action to set up (1 AP)
- Only fires once per turn
- Has accuracy penalty (-20%)
- Can be cancelled by suppression
- Limited ammo

Balance prevents:
- Overwatch becoming "always use"
- Defensive play always winning
- Aggressive play impossible

Creates tension: Attack or defend?
```

---

## Morale & Psychology

### ✅ DO: Implement Morale System

Soldiers get scared under pressure.

**Morale Mechanics:**

```
Morale level: 0-100 (100 = confident)

Morale penalties:
- Soldier takes damage: -5 morale
- Soldier killed nearby: -10 morale
- Under suppression: -3 per turn
- Heavily outnumbered: -1 per unitsOutnumbering

Morale bonuses:
- Kill enemy: +5 morale
- Leadership ability used: +10 morale
- High ground held: +2 morale

Effects of low morale:
- <50: -10% accuracy
- <25: -20% accuracy, slower movement
- <10: Will attempt to flee

Morale failure: Unit panics, goes rogue
```

### ✅ DO: Implement Leadership

Veterans help troops stay calm.

**Leadership System:**

```
Leadership bonus (from high-rank unit nearby):
- For each nearby rank 3+ unit: +2 accuracy
- For each nearby rank 4+ unit: +3 morale/turn
- Cannot stack more than 2 leaders

Strategy:
- Place veterans strategically
- Veterans boost nearby units
- Losing veteran = morale hit
```

---

## Individual Unit AI

### ✅ DO: Implement Decision Tree AI

Simple rules for unit behavior.

**Decision Tree:**

```
Each alien turn:
1. Do I have low health? → Retreat if possible
2. Can I attack? → Choose best target
3. Do I see an enemy? → Move to LoS/attack
4. No enemy visible? → Move to last seen position
5. No information? → Move to patrol location

Simple decisions
Clear priority
Easy to debug
```

### ✅ DO: Weight Target Selection

Units prioritize valuable targets.

**Target Priority:**

```
Target score = distance + priority + threat

Distance factor:
- Closer = higher priority (-1 per cell)

Priority:
- Wounded enemy: +50 points
- High-rank unit: +30 points
- Medic: +20 points
- Regular unit: +10 points

Threat:
- High damage dealer: +40 points
- Close/dangerous: +20 points

Example:
Wounded sniper 5 cells away:
score = 5 + 30 + 40 = 75 (high priority)

Regular soldier 2 cells away:
score = 2 + 10 + 0 = 12 (low priority)

Choose wounded sniper
```

---

## Squad-Level AI

### ✅ DO: Coordinate Squad Tactics

Units should work together.

**Squad Tactics:**

```
Squad has leader
Leader makes strategy:
- Spread out (cover multiple areas)
- Flank (attack from multiple angles)
- Focus fire (all attack one target)
- Defend (form defensive line)

Coordination:
- Leader decides strategy
- Units follow leader's directives
- Revert to individual AI if separated

Implementation:
squad.strategy = "focus_fire"
squad.focusTarget = player
for _, unit in ipairs(squad.units) do
    if canAssist(unit, squad.focusTarget) then
        unit:attack(squad.focusTarget)
    end
end
```

### ✅ DO: Implement Flanking AI

Aliens don't just charge.

**Flanking Behavior:**

```
Flanking check:
Does unit have side/back access to target?
- Yes: Move to flank position
- No: Move to advance position

Flanking positions:
- 90° angle to target
- Behind cover if possible
- Within range to attack

Benefits:
- Target loses cover
- Damage bonus (+25%)
- Tactical depth
```

---

## Team Strategy & Mission AI

### ✅ DO: Implement Mission Goals

Aliens have objectives.

**Mission Types:**

```
Assault:
- Goal: Defeat all player units
- Strategy: Focus fire, pressure
- Behavior: Aggressive

Defense:
- Goal: Survive N turns
- Strategy: Hold position, fall back to strongpoint
- Behavior: Defensive formation

Extraction:
- Goal: Reach map edge with objective
- Strategy: Protect objective, avoid combat
- Behavior: Deterministic path to exit

Alien objective drives behavior
```

### ✅ DO: Implement Strategic Retreat

Aliens shouldn't fight to the death.

**Retreat Logic:**

```
Squad morale: (average of all units)
Squad strength: (count of healthy units)

Retreat check (each turn):
- Squad morale <30%? → Consider retreat
- Squad strength <50%? → Consider retreat
- Leader killed? → Scatter (fallback AI)

Retreat action:
- Units move toward spawn point
- Stop retreating if reinforced
- Reach spawn = UFO departs

Balance: Not too aggressive, not cowardly
```

---

## 2D-to-3D Hybrid Implementation

### ✅ DO: Support Isometric View

Optional 3D-like perspective.

**Isometric Rendering:**

```
Standard 2D:
- Units drawn at y position
- Simple sprite rendering

Isometric 2.5D:
- Calculate screen position from (x, y, z)
- Sprite rendered with isometric projection
- Elevation creates 3D appearance
- Wall rendering changes with view

Isometric formula:
screenX = (x - y) * cellSize + offset
screenY = (x + y) * cellSize / 2 + offsetZ * z

Result: 3D appearance with 2D sprites
```

### ✅ DO: Implement First-Person Option

Single-unit control view.

**First-Person Mode:**

```
Player controls one soldier
View: Simple first-person perspective
Grid: Cells ahead (straight view)

Controls:
- Arrow keys: Move/look around
- Click: Attack/use item
- Tab: Switch unit

Limitations:
- Can only see from unit's position
- Diagonal vision limited
- Must guess hidden enemies

Alternative playstyle: More immersive risk
```

---

## Common Mistakes

### ❌ Mistake: AI Always Plays Optimally

Unrealistic and frustrating.

**Problem:**

```
Perfect AI:
- Always hits
- Always uses best strategy
- Never makes mistakes
- Player loses consistently

Result: Unfun, feels cheap
```

**Solution:**

```
Realistic AI:
- 80% accuracy (not 100%)
- Sometimes wrong target choice
- Occasional tactical mistakes
- Winnable if player is skilled

Difficulty parameter:
- Easy: AI makes more mistakes
- Normal: Some mistakes
- Hard: Fewer mistakes, better tactics

Let players win through good tactics
```

### ❌ Mistake: Too Many Aliens

Feels like quantity over quality.

**Problem:**

```
vs 20 aliens:
- Overwhelming
- Tedious turns
- Feels cheap ("just spam units")
```

**Solution:**

```
vs 8 aliens:
- Challenging
- Tactical
- Each unit matters
- Fast turns

Prefer smart aliens to more aliens
```

### ❌ Mistake: No Environmental Strategy

Static arena.

**Problem:**

```
Same tactics every mission:
- Aliens just charge
- No use of terrain
- Boring predictable
```

**Solution:**

```
Varied environments:
- Forests (LoS blocked)
- Urban (high ground)
- Open (visibility)
- Underground (narrow)

Aliens adapt to environment
Different tactics required
```

---

**Version**: 1.0  
**Last Updated**: October 16, 2025  
**Status**: Active Best Practice Guide

*See also: battlescape/ documentation for implementation details*
