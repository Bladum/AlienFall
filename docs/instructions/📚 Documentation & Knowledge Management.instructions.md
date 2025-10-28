# 📚 Documentation & Knowledge Management Best Practices

**Domain:** Knowledge Engineering & Documentation  
**Focus:** API documentation, architecture docs, decision logs, knowledge transfer  
**Version:** 1.0  
**Date:** October 2025

## Table of Contents

1. [Documentation Fundamentals](#documentation-fundamentals)
2. [API Documentation](#api-documentation)
3. [Architecture Documentation](#architecture-documentation)
4. [Decision Log Management](#decision-log-management)
5. [Knowledge Handoff](#knowledge-handoff)
6. [Code Comments & Docstrings](#code-comments--docstrings)
7. [README Best Practices](#readme-best-practices)
8. [Changelog Management](#changelog-management)
9. [Onboarding Documentation](#onboarding-documentation)
10. [System Documentation](#system-documentation)
11. [Troubleshooting Guides](#troubleshooting-guides)
12. [Documentation Tools & Workflows](#documentation-tools--workflows)
13. [Maintaining Documentation](#maintaining-documentation)
14. [Documentation for AI Agents](#documentation-for-ai-agents)
15. [Common Documentation Mistakes](#common-documentation-mistakes)

---

## Documentation Fundamentals

### ✅ DO: Document for Multiple Audiences

Different people need different documentation:

```lua
-- EXAMPLE: Module with multi-audience documentation

---@class GameEntity
---@field id number
---@field x number
---@field y number
---@field active boolean

---
--- GameEntity Module - Complete Documentation
---
--- This module manages individual game entities (units, objects, effects, etc.)
--- in the game world. It provides creation, updates, and state management.
---
--- ## For Game Programmers:
--- Use create() to spawn entities, update() for game loop integration,
--- and query functions to find entities by position or state.
---
--- ## For AI Agents:
--- See ARCHITECTURE.md for system design. Key entry points:
--- - create(type, x, y) - spawn at position
--- - getAll() - fetch all active entities
--- - update(dt) - call every frame
---
--- ## For System Designers:
--- Entity pools help with performance. Default limit: 10000 entities.
--- See PERFORMANCE.md for tuning parameters.
---
--- @usage
--- local entity = GameEntity.create("soldier", 100, 200)
--- entity:update(dt)
--- entity:destroy()

local GameEntity = {}
GameEntity.__index = GameEntity

function GameEntity.create(entityType, x, y)
    local self = setmetatable({}, GameEntity)
    self.id = generateUniqueID()
    self.type = entityType
    self.x = x
    self.y = y
    self.active = true
    return self
end

function GameEntity:update(dt)
    -- Update entity logic
end

function GameEntity:destroy()
    self.active = false
end

return GameEntity
```

**Three tiers of documentation:**
1. **Quick start** - How to use right now (1 paragraph)
2. **Detailed guide** - How to use correctly (complete examples)
3. **Deep dive** - Why it works this way (architecture, design decisions)

---

### ✅ DO: Keep Documentation Near Code

**Problem:** Documentation far from code gets stale.

**Solution:** Embed documentation where possible:

```lua
-- engine/utils/math.lua

---
--- Calculate distance between two points
--- 
--- @param x1 number - First point X coordinate
--- @param y1 number - First point Y coordinate  
--- @param x2 number - Second point X coordinate
--- @param y2 number - Second point Y coordinate
--- @return number - Distance between points
---
--- @usage
--- local distance = Math.distance(10, 20, 30, 40)
--- print(distance)  -- Outputs ~28.28
---
function Math.distance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end
```

---

### ❌ DON'T: Let Documentation Rot

**The problem:** Documentation that doesn't match code is worse than no documentation.

**Solution:**
- Update docs when code changes
- Run doc generation tests
- Link docs to code changes in commits

---

## API Documentation

### ✅ DO: Document Every Public Function

```lua
---
--- Update all active entities
---
--- Iterates through all entities, updates physics, AI, and state.
--- Should be called once per game loop (from love.update).
---
--- Performance: O(n) where n = active entity count
--- See PERFORMANCE.md for optimization strategies.
---
--- @param dt number - Delta time since last frame (in seconds)
--- @param entities table - List of entities to update (optional, uses global if nil)
--- @return boolean - True if successful, false if error occurred
---
--- @usage
--- function love.update(dt)
---     local success, error = updateEntities(dt)
---     if not success then print("Error: " .. error) end
--- end
---
--- @error "dt must be positive number"
--- @error "Entity update failed"
---
function updateEntities(dt, entities)
    entities = entities or globalEntities
    
    if not entities then
        return false, "No entities provided"
    end
    
    for i, entity in ipairs(entities) do
        if entity.active then
            entity:update(dt)
        end
    end
    
    return true
end
```

**Key elements:**
- What it does
- Parameters with types
- Return value
- Usage example
- Common errors
- Performance notes

---

### ✅ DO: Document Function Behavior Edge Cases

```lua
---
--- Find entity by ID
---
--- Returns the entity with given ID if found in active entities.
--- Returns nil if not found (does NOT raise error).
---
--- Edge cases:
--- - Returns nil if ID not found (not an error)
--- - Returns nil if ID is nil/invalid
--- - Does not search inactive entities
--- - First match is returned (IDs should be unique)
---
--- @param id number - Entity ID to search for
--- @return Entity|nil - Entity with given ID, or nil if not found
---
function findEntityByID(id)
    if not id then return nil end
    
    for _, entity in ipairs(entities) do
        if entity.active and entity.id == id then
            return entity
        end
    end
    
    return nil
end
```

---

### ✅ DO: Document Parameter Constraints

```lua
---
--- Create new unit with validation
---
--- @param type string - Unit type: "soldier", "sniper", "medic" (REQUIRED)
--- @param level number - Experience level: 1-99 (default: 1)
--- @param faction string|nil - Faction ID, nil for neutral (optional)
---
--- @error "Invalid type: must be 'soldier', 'sniper', or 'medic'"
--- @error "Level must be 1-99"
---
function createUnit(type, level, faction)
    -- Validate type
    local validTypes = {soldier = true, sniper = true, medic = true}
    if not validTypes[type] then
        error(string.format("Invalid type: %s", type))
    end
    
    -- Validate level
    level = level or 1
    if level < 1 or level > 99 then
        error(string.format("Level must be 1-99, got %d", level))
    end
    
    -- Create unit
    return {type = type, level = level, faction = faction}
end
```

---

## Architecture Documentation

### ✅ DO: Document System Architecture

Create ARCHITECTURE.md for each major system:

```markdown
# Entity System Architecture

## Overview
The entity system manages all game objects (units, items, effects).
Entities are stored in a pool for performance.

## Design Pattern: Object Pool + Component System

### Key Components
1. **Entity Manager** - Lifecycle management
2. **Entity Pool** - Reuses entity objects
3. **Component System** - Behavior composition
4. **System Updates** - Per-frame entity updates

### Data Flow
```
Game Loop
  ├── Update Phase
  │   ├── PhysicsSystem.update(dt)
  │   ├── AISystem.update(dt)
  │   └── AnimationSystem.update(dt)
  └── Render Phase
      └── RenderSystem.draw()
```

## Performance Characteristics
- Entity creation: O(1) amortized
- Entity update: O(n)
- Entity query by type: O(n)
- Spatial queries: O(log n) with quadtree

## Extending the System
See EXTENDING_ENTITIES.md for adding new components.
```

---

### ✅ DO: Use Diagrams to Show Architecture

```markdown
# Component Architecture

```
┌─────────────────────────────────────────┐
│           Game Entity                   │
├─────────────────────────────────────────┤
│ id: 123                                 │
│ position: {x: 100, y: 200}             │
├─────────────────────────────────────────┤
│ Components:                             │
│ ├── Transform (position, rotation)     │
│ ├── Sprite (visual representation)     │
│ ├── Physics (velocity, acceleration)   │
│ └── AI (behavior, state machine)       │
└─────────────────────────────────────────┘
```

---

### ❌ DON'T: Create Documentation Only in Wiki

**The problem:** Wiki docs get forgotten and stale.

**Solution:** Keep key architecture docs in the codebase repo alongside code.

---

## Decision Log Management

### ✅ DO: Document Major Technical Decisions

Create DECISIONS.md to track key choices:

```markdown
# Technical Decisions Log

## [2025-10-01] Use Object Pooling for Entities

**Decision:** Implement object pool pattern for entity creation/destruction

**Rationale:**
- Previous approach created 1000+ objects per frame during combat
- GC pauses were visible (~50ms) causing stutters
- Object pooling reduces GC pressure by reusing objects

**Alternatives Considered:**
1. Upgrade GC tuning - Tried, still insufficient
2. Lazy entity deletion - Leaves dead entities in memory
3. Object pooling - CHOSEN - Provides predictable performance

**Impact:**
- Frame pacing improved: 20ms → 2ms average
- GC pauses eliminated
- Slightly more complex entity lifecycle

**Status:** ✅ IMPLEMENTED - Reduces frame stutters
**Owner:** @ai-agent-core-team

---

## [2025-09-15] Migrate to ECS Architecture

**Decision:** Move from inheritance-based entities to ECS pattern

**Rationale:**
- Current inheritance hierarchy too deep (5+ levels)
- New features require cross-cutting concerns (e.g., "all flying units")
- ECS provides better composition flexibility

**Alternatives Considered:**
1. Keep inheritance - Harder to extend
2. Mixins/traits - Some improvement but still not flexible
3. ECS (Entity-Component-System) - CHOSEN - Best flexibility

**Impact:**
- Requires refactoring ~30% of codebase
- New developers need ECS training
- Enables new features much faster after migration

**Status:** 🔄 IN PROGRESS - Phase 1 complete, phase 2 starting
**Owner:** @ai-agent-architecture

---

## [2025-08-20] Choose Lua/Love2D Instead of Godot

**Decision:** Implement in Lua with Love2D instead of switching to Godot

**Rationale:**
- Existing codebase in Lua is substantial
- Love2D is lightweight and suitable for 2D strategy games
- Learning curve for Godot would delay project 3+ months
- Performance is adequate for this game scope

**Alternatives Considered:**
1. Continue with custom engine - Getting harder to maintain
2. Switch to Godot - Would lose existing code, long ramp-up
3. Love2D - CHOSEN - Builds on existing investment

**Impact:**
- Keep existing architectural patterns
- Access to Love2D ecosystem
- Team expertise leverage

**Status:** ✅ CONFIRMED - Proceeding with Love2D
**Owner:** @project-lead
```

**Benefits of decision logs:**
- New developers understand "why" not just "what"
- Prevents re-litigation of old decisions
- Shows decision rationale over time
- Helps identify when decisions need revisiting

---

### ✅ DO: Link Decisions to Code

When a decision is implemented, reference it in code:

```lua
-- engine/entity/entity.lua
-- 
-- NOTE: Entity pooling pattern (DECISION-2025-10-01)
-- Entities are reused instead of created/destroyed
-- to minimize GC pressure and improve frame pacing.
-- See DECISIONS.md for rationale.
--

local EntityPool = {}
local availableEntities = {}
local activeEntities = {}

function EntityPool.acquire()
    if #availableEntities > 0 then
        return table.remove(availableEntities)
    else
        return {id = generateID()}
    end
end

function EntityPool.release(entity)
    entity.active = false
    table.insert(availableEntities, entity)
end
```

---

## Knowledge Handoff

### ✅ DO: Create Onboarding Documents

**NEW_DEVELOPER.md** - First day guide:

```markdown
# Welcome to AlienFall Development

## Day 1: Environment Setup

1. Clone repository
2. Install Love2D 12.0
3. Run: `lovec engine`
4. Verify: You should see game window with console

## Day 2: Understanding Architecture

Read these docs (30 minutes each):
1. docs/ARCHITECTURE.md - System overview
2. docs/BATTLESCAPE/README.md - Combat layer
3. docs/GEOSCAPE/README.md - Strategy layer

## Day 3: First Code Change

Task: Add a new unit type "scout"
- File: engine/battlescape/units.lua
- See TODO marker for where to add
- Reference: engine/battlescape/units.lua lines 150-200 (existing units)

## Day 4-5: Bigger Tasks

Pick from: docs/BEGINNER_TASKS.md

## Getting Help

- Question about code: Check related README.md files
- Question about system: Check docs/ARCHITECTURE.md  
- Stuck for >15min: Ask in #dev-help channel
- Need code review: Submit PR with description
```

---

### ✅ DO: Document Tribal Knowledge

Capture knowledge that only one person knows:

```markdown
# [PERSON] - Tribal Knowledge Transfer

## Game Balance Tuning
- Unit damage is carefully balanced around 3-hit kills
- Changing hit damage requires rebalancing across 20+ units
- See GAME_NUMBERS.md for balance constants
- Always test combat before/after changes

## Battlescape Map Generation
- Map generation uses XCom algorithm (modified)
- Maps must be 20-40 tiles for good combat pacing
- See map_generator.lua for generation parameters
- New map types: Contact @person for guidance

## Save Game Format
- Save format version 5 (changed in 2025-07)
- Migration from v4 to v5 happens automatically
- Breaking changes require version bump + migration code
- Test save/load before shipping

## Performance Tricks
- UI is drawn to canvas and cached to reduce draw calls
- Don't modify UI every frame unless visible change needed
- Entity updates should be <2ms per 1000 entities
- If slower, check for O(n²) algorithms
```

---

### ✅ DO: Record Video Tutorials for Complex Systems

For very complex systems, document with videos:

```markdown
# Video Documentation Index

## Battlescape AI System (8 minutes)
- Video: docs/videos/battlescape_ai_overview.mp4
- Watch this to understand multi-level AI architecture
- Key sections:
  - 0:00 - 1:00: Individual unit AI
  - 1:00 - 4:00: Squad-level coordination
  - 4:00 - 8:00: Mission-level strategy

## Save/Load System (5 minutes)
- Video: docs/videos/save_load_walkthrough.mp4
- Demonstrates actual save/load process
- Shows debugging save file issues
```

---

## Code Comments & Docstrings

### ✅ DO: Comment Non-Obvious Logic

```lua
-- BAD: Over-commented obvious code
function update(dt)
    -- Add dt to time
    self.time = self.time + dt
    
    -- Check if time > 5
    if self.time > 5 then
        -- Set active to false
        self.active = false
    end
end

-- GOOD: Explain WHY, not WHAT
function update(dt)
    self.time = self.time + dt
    
    -- Fade out after 5 seconds (visual effect duration)
    -- Don't set active=false until fade completes to prevent early cleanup
    if self.time > 5 then
        self.active = false
    end
end
```

---

### ✅ DO: Explain Complex Algorithms

```lua
-- Quadtree insertion with spatial partitioning
-- 
-- Algorithm:
-- 1. If node has children, recursively insert into appropriate child
-- 2. If node is leaf and under capacity, add item
-- 3. If node is leaf and at capacity, split into 4 quadrants and redistribute
--
-- This reduces O(n²) collision checks to O(n log n) average case
--
-- Reference: https://en.wikipedia.org/wiki/Quadtree
--
function quadtree:insert(item, x, y, w, h)
    if self.children then
        for _, child in ipairs(self.children) do
            if self:overlaps(child, x, y, w, h) then
                child:insert(item, x, y, w, h)
            end
        end
    else
        table.insert(self.items, {item = item, x = x, y = y, w = w, h = h})
        
        if #self.items > self.maxItems then
            self:split()
        end
    end
end
```

---

## README Best Practices

### ✅ DO: Create Comprehensive READMEs

Each major folder should have README.md:

```markdown
# Battlescape System

## Overview
The Battlescape is the tactical combat layer where player-controlled units
fight enemies on procedurally-generated maps.

## Quick Start
```bash
# Run the game
lovec engine

# Navigate to Battlescape from main menu
# Or run battlescape directly: lovec engine battlescape_test
```

## System Architecture
See docs/battlescape/ARCHITECTURE.md for detailed architecture.

Quick overview:
- **Map Generation:** Creates 20-40 tile tactical maps
- **Unit Management:** Handles unit creation, movement, damage
- **AI System:** Controls enemy units and squad tactics
- **Combat Resolution:** Calculates hit chances, damage

## Key Files
- `battlescape/battle.lua` - Main battle orchestrator
- `battlescape/units.lua` - Unit management
- `battlescape/map_generator.lua` - Map generation
- `battlescape/ai/` - All AI systems

## Common Tasks

### Adding a New Unit Type
1. Define unit stats in `battlescape/data/units.toml`
2. Add sprite in `assets/sprites/units/`
3. Register in `battlescape/units.lua`
4. Test in battlescape_test mode

### Changing Combat Balance
See `docs/GAME_NUMBERS.md` for balance constants
All balance values are centralized there.

### Debugging Battles
- Enable debug overlay: Press D in battle
- Check Love2D console for errors
- Use battle_dump.lua to export battle state

## Testing
```bash
# Run battle tests
lua tests/battlescape/test_battle.lua

# Run performance tests
lua tests/battlescape/test_performance.lua
```

## Performance
See docs/PERFORMANCE.md for optimization notes.
Current performance target: 60 FPS with 100 units.

## Known Issues
- Issue #542: Unit pathfinding can get stuck in tight corners
- Issue #543: AI sometimes takes too long to decide (>500ms)

## Contributing
See CONTRIBUTING.md for contribution guidelines.
```

---

## Changelog Management

### ✅ DO: Maintain Detailed Changelog

```markdown
# Changelog

All notable changes to this project are documented here.

Format based on [Keep a Changelog](https://keepachangelog.com/).

## [1.2.0] - 2025-10-15

### Added
- New "Scout" unit type with increased movement speed
- Mod support for custom unit types
- Performance overlay (press D to toggle)
- Save game auto-backup before overwrites

### Changed
- Reduced soldier damage: 15→12 (was too strong)
- Improved pathfinding performance: -30% CPU time
- UI now cached to canvas reducing draw calls by 80%
- Rebalanced difficulty levels

### Fixed
- Fixed crash when loading save with deleted mod unit
- Fixed AI units sometimes walking into walls
- Fixed memory leak in particle system (30MB reduction)
- Fixed UI not updating when resolution changes

### Deprecated
- Old save file format (v4) - auto-migrates to v5

### Performance
- Improved 60 FPS stability: frame pacing now ±1ms
- Reduced memory usage: 400MB → 350MB
- Reduced loading time: 8s → 5s

## [1.1.0] - 2025-09-20

...
```

**Benefits:**
- Players know what changed
- Developers can track work
- Regression testing easier
- Version history preserved

---

## Onboarding Documentation

### ✅ DO: Create Task-Based Guides

Instead of generic docs, create task-focused guides:

```markdown
# Task: Add a New Weapon Type

## Goal
Add a new sniper rifle weapon that one-shots most units but has slow reload.

## Prerequisites
- Read docs/GAME_NUMBERS.md (understand weapon balance)
- Familiar with TOML config format

## Step-by-Step

### 1. Define Weapon Stats (30 min)
File: `engine/battlescape/data/weapons.toml`

```toml
[sniper_rifle]
name = "Sniper Rifle"
damage = 60          # High single hit
accuracy = 85        # Moderate accuracy  
reloadTime = 3.0     # 3 second reload
ammo = 8
cost = 2500
weight = 12
```

### 2. Create Weapon Icon (1 hour)
- Create 24x24 pixel icon
- File: `assets/sprites/weapons/sniper_rifle.png`
- Reference similar icons: `assets/sprites/weapons/rifle.png`

### 3. Register Weapon (15 min)
File: `engine/battlescape/units/weapons.lua`

Add to weapons table:
```lua
local weapons = {
    rifle = {...},
    -- Add this:
    sniper_rifle = {
        name = "Sniper Rifle",
        damage = 60,
        -- ... copy from TOML
    }
}
```

### 4. Test (30 min)
- Load game, create unit with sniper rifle
- Verify stats display correctly
- Test combat: does it one-shot?
- Check reload animation

### 5. Rebalance if Needed (variable)
- If too strong: reduce damage or accuracy
- If too weak: increase damage or reduce reload time
- See docs/GAME_NUMBERS.md for balance guidelines

## When You're Stuck
- Question about weapon balance: See docs/GAME_NUMBERS.md
- Question about sprites: See docs/PIXEL_ART.instructions.md
- Question about registration: Ask @core-team
```

---

## System Documentation

### ✅ DO: Document Data Flow

```markdown
# Geoscape Mission Flow

## Data Flow Diagram

```
User selects mission
       ↓
MissionSelector.onSelect()
       ↓
validateMission(mission)
       ↓ (if valid)
BattlescapeLoader.load(mission)
       ↓
Battlescape.start()
       ↓
Battle in progress (user plays)
       ↓
Battle ends (victory/defeat)
       ↓
BattleResult.process(result)
       ↓
Geoscape updates (casualties, progress)
       ↓
Return to Geoscape
```

## State Transitions

```
Geoscape Menu
    ↓ (select mission)
    ↓ (validate)
Battlescape Active
    ↓ (game ends)
    ↓ (process results)
Geoscape Menu
    ↓ (continue)
```
```

---

## Troubleshooting Guides

### ✅ DO: Create FAQ and Troubleshooting Docs

```markdown
# Troubleshooting Guide

## Game Crashes on Startup

### Symptom
Game window opens briefly then closes with no error.

### Common Causes

**Cause 1: Missing Love2D installation**
- Check: Is Love2D 12.0 installed?
- Fix: Install from love2d.org
- Verify: `lovec --version` shows 12.0

**Cause 2: Corrupted save file**
- Check: Last session ended abnormally?
- Fix: Delete saves\*.dat files
- Result: Game starts fresh

**Cause 3: Missing config file**
- Check: engine/conf.lua exists?
- Fix: Restore from git
- Verify: `git status` shows clean state

### If Still Stuck
1. Check Love2D console: `lovec engine 2>&1 | tail -20`
2. Check error.log file for details
3. Post error message in #help with full log

---

## Game Runs Slow (FPS Drops)

### Symptom
Game starts fine but FPS drops to 20 after 5 minutes.

### Diagnosis
1. Enable debug overlay: Press D
2. Check FPS display
3. Note which system is slow:
   - If memory keeps growing: memory leak
   - If draw calls high: rendering bottleneck
   - If frame time spikes: GC pause

### Solutions

**Memory leak (grows constantly)**
- Solution: Restart game
- Report: Make bug report with system details

**High draw calls (>100)**
- Check if many units on screen
- Disable UI overlays to isolate
- May be GC issue, not draw calls

**GC pauses (frame spikes)**
- Normal during heavy action
- Should stabilize between battles
- If continues, memory leak likely

---

## AI Units Don't Move

### Symptom
Enemy units stand still and don't attack.

### Diagnosis Checklist
- [ ] Is battle actually running? (check UI)
- [ ] Is it player's turn? (AI only moves on enemy turn)
- [ ] Are there valid actions? (units might be blocked)
- [ ] Check console for errors

### Solutions
1. If it's player turn: Wait for turn to end
2. If console errors: Note error and report bug
3. If AI stuck: Try: Press R to restart turn
```

---

## Documentation Tools & Workflows

### ✅ DO: Use Documentation Generators

```lua
-- Document generation example
-- This script generates API documentation from LuaDoc comments

local function generateDocumentation()
    local files = {}
    
    -- Find all .lua files
    for _, file in ipairs(love.filesystem.getDirectoryItems("engine")) do
        if file:match("%.lua$") then
            table.insert(files, file)
        end
    end
    
    -- Generate docs
    for _, file in ipairs(files) do
        local content = love.filesystem.read(file)
        local docs = extractLuaDoc(content)
        
        if #docs > 0 then
            writeDocumentation(file, docs)
        end
    end
end
```

**Tools for documentation:**
- **LuaDoc** - Lua documentation extraction
- **Markdown** - Format for docs
- **GitHub Pages** - Host generated docs
- **Doxygen** - Multi-language doc generation

---

### ✅ DO: Link Docs in Pull Requests

When submitting PR that changes public API:

```markdown
# PR: Add New Weather System

## Changes
- Add `weather.lua` module
- New weather effects: rain, snow, sandstorm
- Affects unit visibility and movement speed

## Documentation
- [ ] API documented in engine/weather/README.md
- [ ] Added examples to docs/WEATHER.md
- [ ] Updated CHANGELOG.md
- [ ] Updated main ARCHITECTURE.md diagram

## Breaking Changes
None - purely additive feature

## Testing
- Tested with all three weather types
- Verified performance (no FPS impact)
```

---

## Maintaining Documentation

### ✅ DO: Version Documentation

```markdown
# Version Compatibility Matrix

| Feature | v1.0 | v1.1 | v1.2 | v2.0 |
|---------|------|------|------|------|
| Save/Load | ✅ v1 | ✅ v1-2 | ✅ v2-3 | ✅ v3-4 |
| Weapons | 15 types | 20 types | 25 types | 40 types |
| Mods | ❌ | ✅ | ✅ | ✅ full |
| Save Format | v1 | v2 | v3 | v4 |

See MIGRATION.md for upgrading between versions.
```

---

### ✅ DO: Deprecation Warnings

```lua
---
--- [DEPRECATED] Use newEntityPool() instead
--- This function is deprecated since v1.2
--- Will be removed in v2.0
---
--- Migration: Replace createEntity() with newEntityPool.acquire()
---
function createEntity()
    print("[DEPRECATED] createEntity() use newEntityPool instead")
    return newEntityPool.acquire()
end
```

---

## Documentation for AI Agents

### ✅ DO: Structure Docs for AI Handoff

```markdown
# AI Agent Handoff Documentation

## Current Status
- Last updated: 2025-10-16
- Last modified by: @human-developer
- Current task: Implementing weapon balance

## What's Complete
- [x] Core entity system
- [x] Battlescape map generation
- [x] Turn-based combat
- [x] Unit AI (basic)

## What's In Progress
- [ ] Advanced squad tactics
- [ ] Dynamic difficulty
- [ ] Campaign system

## What's Next for AI Agent
### Priority 1 (Do First)
1. Implement flanking AI (see DESIGN.md)
2. Add morale system
3. Test with 50+ enemy units

### Priority 2 (Do Next)
1. Campaign mission progression
2. Save/load system

## Key Decision Points
See DECISIONS.md for previous decisions

## When Stuck
- Memory issues: Check PERFORMANCE.md
- Combat balance: Check GAME_NUMBERS.md
- Architecture questions: Check ARCHITECTURE.md
- Specific code: Check relevant README.md

## Code Patterns You'll See
- ECS pattern: entities have components
- Object pooling: enemies reuse object instances
- State machine: units, battles, scenes
- Event system: components communicate via events
```

---

## Common Documentation Mistakes

### ❌ Mistake: Documentation Too High-Level

**Problem:** Docs that don't show actual code:

```markdown
# Bad Documentation
- The entity system manages entities
- Entities have components
- Components provide behavior
```

**Solution:** Show actual usage:

```markdown
# Good Documentation
The entity system creates and manages game objects. Here's how to create a unit:

```lua
local unit = Entity.create("soldier")
unit:addComponent("health", {hp = 100, max_hp = 100})
unit:addComponent("sprite", {image = "soldier.png"})
unit:update(dt)
```
```

---

### ❌ Mistake: No Examples

**Problem:** Docs explain what but not how:

```markdown
# Bad: No Examples
The save system serializes game state to disk.
```

**Solution:** Show real examples:

```markdown
# Good: With Examples
The save system serializes game state to disk:

```lua
-- Save game
GameState.save("slot_1.sav")

-- Load game
local gameState = GameState.load("slot_1.sav")
```

## Example Save File
```
version: 3
player_faction: XCOM
difficulty: 7
mission_count: 42
```
```

---

### ❌ Mistake: Stale Documentation

**Problem:** Docs that don't match current code.

**Solution:**
- Docs close to code (README in folder with code)
- Link code changes to doc changes
- Review docs in PR process
- Mark when docs were last updated

---

### ❌ Mistake: No Decision Rationale

**Problem:** Developers don't know WHY architecture was chosen.

**Solution:** Create DECISIONS.md documenting key choices and rationale.

---

## Documentation Checklist

### For New Features

- [ ] README.md created/updated in relevant folder
- [ ] API functions documented with docstrings
- [ ] Usage examples provided
- [ ] Edge cases documented
- [ ] Architecture documented if new system
- [ ] CHANGELOG.md updated
- [ ] Links to related docs added
- [ ] Video tutorial recorded (if complex)

### For New Developers

- [ ] NEW_DEVELOPER.md is current
- [ ] First task clearly documented
- [ ] Key systems READMEs reviewed
- [ ] Troubleshooting guide available
- [ ] Communication channels documented

### For Releases

- [ ] CHANGELOG.md complete
- [ ] API docs generated
- [ ] Architecture docs current
- [ ] Migration guide (if version bump)
- [ ] Known issues documented

---

## Documentation Best Practices Summary

### ✅ DO
- Document for multiple audiences (quick start + deep dive)
- Keep docs near code (README in folder)
- Include actual code examples
- Document decisions and rationale
- Update docs when code changes
- Link docs in PR reviews
- Use consistent formatting
- Record videos for complex systems
- Version documentation
- Create task-based guides

### ❌ DON'T
- Write generic docs
- Keep docs separate from code
- Forget examples
- Let docs rot (become stale)
- Skip decision rationale
- Skip edge case documentation
- Create docs-only wikis
- Assume readers know context
- Skip troubleshooting guides
- Neglect AI agent handoff docs

---

## References

- Write the Docs: https://www.writethedocs.org/
- Google Technical Writing: https://developers.google.com/tech-writing
- Markdown Guide: https://www.markdownguide.org/
- LuaDoc Manual: http://keplerproject.github.io/luadoc/

