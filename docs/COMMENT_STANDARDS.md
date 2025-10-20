# AlienFall Comment Standards

**Audience**: Developers | **Status**: Active | **Last Updated**: October 2025

Guidelines for writing effective comments and documentation strings in Lua code.

---

## Table of Contents

- [Overview](#overview)
- [When to Comment](#when-to-comment)
- [Comment Types](#comment-types)
- [Function Documentation](#function-documentation)
- [Examples](#examples)
- [Best Practices](#best-practices)
- [Checklist](#checklist)

---

## Overview

**Purpose of Comments**:
- Explain *why*, not *what* (code shows what it does)
- Help developers understand complex logic
- Document assumptions and edge cases
- Aid in maintenance and debugging

**Philosophy**:
- Good code is self-documenting with clear naming
- Comments explain non-obvious logic
- Too many comments = unclear code
- Comments should be maintained like code

**Tools**:
- Single-line comments: `--`
- Multi-line comments: `--[[ ]]`
- Function docs: LuaDoc format

---

## When to Comment

### DO Comment

✅ **Complex algorithms**: Non-obvious calculations
```lua
-- Calculate line-of-sight using raycasting
-- Each tile adds cost; total > max range hides target
local function calculateLineOfSight(from, to)
    -- ... complex ray-tracing algorithm
end
```

✅ **Non-obvious intent**: Why something is done
```lua
-- Stun points reset each turn (not cumulative between turns)
-- This models fatigue recovery during turn transitions
unit.stun_points = 0
```

✅ **Edge cases**: Handling exceptions
```lua
-- Return nil if array empty (convention used throughout codebase)
if #array == 0 then
    return nil  -- Not empty table, but nil
end
```

✅ **Performance-critical code**: Why it's optimized
```lua
-- Pre-calculate visible units to avoid repeated calculations
-- Major performance bottleneck in battle updates
local visible = _precalculateVisibility(unit)
```

✅ **Assumptions**: Expected preconditions
```lua
-- Assumes 'unit' has been initialized (has id, name, stats)
-- Call Unit.init() first if needed
function procesUnit(unit)
    -- ...
end
```

### DON'T Comment

❌ **Obvious code**: Self-explanatory code doesn't need comments
```lua
-- Bad: States what code obviously does
for i = 1, 10 do
    -- Loop from 1 to 10
    print(i)  -- Print each number
end

-- Good: No comment needed
for i = 1, 10 do
    print(i)
end
```

❌ **Good variable names**: Clear naming eliminates need for comments
```lua
-- Bad: Comment because name is unclear
local x = calculateDamage(attacker, defender)  -- damage value

-- Good: Name is clear, no comment needed
local damageDealt = calculateDamage(attacker, defender)
```

❌ **Redundant**: Repeating what the code says
```lua
-- Bad: Comment repeats code
if unit.health <= 0 then
    -- Unit is dead
    removeUnit(unit)
end

-- Good: Comment explains why
if unit.health <= 0 then
    -- Remove from active list to stop processing
    removeUnit(unit)
end
```

---

## Comment Types

### Single-Line Comments

For short explanations on one line:

```lua
-- Simple explanation
unit.is_alive = true
```

### Block Comments

For multi-line explanations:

```lua
--[[
This function implements line-of-sight using raycasting.
It checks each tile along the ray from source to target,
accumulating sight cost. If cost exceeds unit's sight range,
target is hidden.

See: ADR-001-LOS-Implementation for design details
]]
local function calculateLineOfSight(from, to)
    -- ...
end
```

### Inline Comments

For clarifying specific lines:

```lua
function calculateDamage(attacker, defender)
    local base = attacker.damage - defender.armor  -- Base damage before modifiers
    local multiplier = 1.0 + (attacker.strength / 100)  -- Strength adds 1% per point
    return base * multiplier
end
```

### Section Markers

Organize code into logical sections:

```lua
-- ============================================
-- Initialization
-- ============================================

function BattleSystem.init()
    -- ...
end

-- ============================================
-- Main Update Loop
-- ============================================

function BattleSystem.update(dt)
    -- ...
end

-- ============================================
-- Rendering
-- ============================================

function BattleSystem.draw()
    -- ...
end
```

---

## Function Documentation

### LuaDoc Format

Use LuaDoc comments above function definitions:

```lua
--[[
Calculate damage from attacker to defender.

Takes into account attacker's damage, defender's armor,
and applies modifiers from specializations and equipment.

@param attacker (Unit) - Attacking unit
@param defender (Unit) - Defending unit
@return damage (number) - Calculated damage

@example
    local damage = calculateDamage(playerUnit, enemyUnit)
]]
function calculateDamage(attacker, defender)
    local base = attacker.damage - defender.armor
    return math.max(base, 1)  -- Minimum 1 damage
end
```

### Function Comment Sections

For complex functions, break into sections:

```lua
--[[
Process end-of-turn for all units.

Updates morale, sanity, and status effects.
Handles reinforcements if timer expired.
]]
function BattleSystem.endTurn()
    
    -- Update unit status
    for _, unit in ipairs(activeUnits) do
        unit.morale = math.min(unit.morale + 1, unit.max_morale)
        unit.sanity = math.max(unit.sanity - 1, 0)
    end
    
    -- Handle status effects
    for _, effect in ipairs(statusEffects) do
        effect.duration = effect.duration - 1
        if effect.duration <= 0 then
            removeStatusEffect(effect)
        end
    end
    
    -- Check for reinforcements
    if reinforcementTimer <= 0 then
        spawnReinforcements()
        reinforcementTimer = reinforcementInterval
    end
end
```

---

## Examples

### Example 1: Poorly Commented Code

```lua
-- BAD: Too many obvious comments
function attack(a, d)
    -- Calculate damage
    local dmg = calculateDamage(a, d)  -- damage value
    -- Reduce health
    d.hp = d.hp - dmg  -- Reduce HP by damage
    -- Check if dead
    if d.hp <= 0 then  -- If HP is zero or less
        d.alive = false  -- Not alive
    end
end
```

### Example 2: Well-Commented Code

```lua
-- GOOD: Comments explain intent and edge cases
function attack(attacker, defender)
    local damage = calculateDamage(attacker, defender)
    
    -- Armor damage is cumulative (weakens over battles)
    defender.armor = math.max(defender.armor - 1, 0)
    
    defender.current_hp = defender.current_hp - damage
    
    if defender.current_hp <= 0 then
        -- Mark as dead but keep in list for animations/cleanup
        defender.is_alive = false
    end
end
```

### Example 3: Algorithm Documentation

```lua
--[[
Implement Dijkstra's pathfinding algorithm.

Finds shortest path from start to goal on hex grid.
Uses priority queue for efficiency O(E log V).

Preconditions:
- start and goal must be valid hexes on grid
- grid must be initialized and non-empty

Edge cases:
- If goal unreachable, returns empty path
- If start == goal, returns [start]

@param grid (HexGrid) - Game map
@param start (Hex) - Starting position
@param goal (Hex) - Target position
@return path (array) - Array of Hex positions, or {} if unreachable
]]
function findPath(grid, start, goal)
    -- Initialize open set with start
    local open_set = {start}
    local came_from = {}
    
    -- g_score[node] = cost from start to node
    local g_score = {}
    g_score[start] = 0
    
    -- f_score[node] = g_score + heuristic
    local f_score = {}
    f_score[start] = heuristic(start, goal)
    
    while #open_set > 0 do
        -- Find node in open set with lowest f_score
        local current = _findLowestFScore(open_set, f_score)
        
        if current == goal then
            return _reconstructPath(came_from, goal)
        end
        
        -- Process neighbors
        for _, neighbor in ipairs(grid:getNeighbors(current)) do
            local tentative_g = g_score[current] + 1
            
            if not g_score[neighbor] or tentative_g < g_score[neighbor] then
                came_from[neighbor] = current
                g_score[neighbor] = tentative_g
                f_score[neighbor] = g_score[neighbor] + heuristic(neighbor, goal)
                
                if not _contains(open_set, neighbor) then
                    table.insert(open_set, neighbor)
                end
            end
        end
    end
    
    -- Goal unreachable
    return {}
end
```

---

## Best Practices

### 1. Explain *Why*, Not *What*

```lua
-- BAD: Comments repeat the code
multiplier = 1.0 + difficulty_level  -- Add difficulty level to 1

-- GOOD: Comments explain intent
-- Difficulty scales from 1.0x (easy) to 5.0x (impossible)
multiplier = 1.0 + (difficulty_level * 0.75)
```

### 2. Use Consistent Terminology

Use same term throughout codebase:

```lua
-- Choose one term and stick with it
-- Don't mix: "health", "hp", "hitpoints", "current_health"

-- Good: Consistent term used everywhere
if unit.current_hp > 0 then
    unit.is_alive = true
end
```

### 3. Link to Related Documentation

```lua
-- Reference design docs and architecture decisions
-- See: Geoscape.md for full mechanic details
-- See: ADR-002-LOS-Implementation for line-of-sight design
local function calculateLOS(unit, target)
    -- ...
end
```

### 4. Document Magic Numbers

```lua
-- Bad: Unclear why 42
if score > 42 then
    unlockAchievement("legend")
end

-- Good: Explains constant
local LEGEND_SCORE_THRESHOLD = 1000  -- Top 1% of players
if score > LEGEND_SCORE_THRESHOLD then
    unlockAchievement("legend")
end
```

### 5. Comment Complex Conditions

```lua
-- Bad: Hard to understand condition
if unit.hp > 0 and unit.ap > 0 and not unit.suppressed and unit.morale > 0 then
    -- ...
end

-- Good: Extract to function with clear name
function canUnitAct(unit)
    -- Unit must be alive, have action points, not suppressed, and have morale
    return unit.current_hp > 0 and 
           unit.action_points > 0 and 
           not unit.is_suppressed and 
           unit.morale > 0
end

if canUnitAct(unit) then
    -- ...
end
```

### 6. Mark Work-in-Progress

```lua
-- TODO: Implement actual pathfinding (currently uses random walk)
function findPath(from, to)
    return getRandomPath(from, to)
end

-- FIXME: This crashes if attacker is nil
function calculateDamage(attacker, defender)
    return attacker.damage - defender.armor
end

-- HACK: Temporary workaround for missile tracking bug
-- Remove when missile system rewritten
damage = damage * 0.9
```

---

## Checklist

Before committing code:

- [ ] Complex logic has explanatory comments
- [ ] Non-obvious intent is explained
- [ ] Edge cases are documented
- [ ] Performance-critical code is noted
- [ ] Assumptions are stated
- [ ] Comments explain *why*, not *what*
- [ ] Functions have LuaDoc headers if public
- [ ] Magic numbers have explanation
- [ ] Complex conditions are clarified
- [ ] TODO/FIXME/HACK marked appropriately
- [ ] Related docs linked when relevant
- [ ] Terminology consistent throughout
- [ ] No dead/outdated comments
- [ ] Comments match current code (not stale)

---

## Code Review Comment Guidelines

When reviewing comments:

**Look for**:
- Missing documentation on complex logic
- Outdated comments not matching code
- Magic numbers without explanation
- Unclear intent from function names/logic

**Suggest**:
- Add comment to clarify complex code
- Update comment to match current logic
- Extract constant for magic number
- Rename variable to be self-documenting

**Approve**:
- Clear, accurate comments
- Self-documenting code with minimal comments
- Appropriate LuaDoc headers

---

## Related Documentation

- **[Code Standards](CODE_STANDARDS.md)** - Naming and style conventions
- **[Documentation Standards](DOCUMENTATION_STANDARD.md)** - User-facing documentation
- **[Debugging Guide](developers/DEBUGGING.md)** - Using print statements for debugging

---

**Last Updated**: October 2025 | **Status**: Active | **Difficulty**: Beginner

