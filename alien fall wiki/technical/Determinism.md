# Determinism System

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Core Principles](#core-principles)
  - [Seed Architecture](#seed-architecture)
  - [Random Number Generation](#random-number-generation)
  - [Seed Management](#seed-management)
  - [Debugging Tools](#debugging-tools)
  - [Testing Strategies](#testing-strategies)
  - [Implementation Guidelines](#implementation-guidelines)
  - [Advanced Topics](#advanced-topics)
  - [Performance Considerations](#performance-considerations)
  - [Troubleshooting Guide](#troubleshooting-guide)
- [Examples](#examples)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Determinism System defines the single source of truth for deterministic behavior in Alien Fall, ensuring all randomness is seeded and reproducible for testing, debugging, and replay functionality. Given the same seed and sequence of operations, the system guarantees identical random outcomes across mission layouts, AI decisions, dice rolls, and loot drops, enabling both strategic save-scumming for players and precise bug reproduction for developers. The architecture employs hierarchical seed derivation from campaign-level master seeds down through system, subsystem, and instance-level seeds, maintaining complete reproducibility while allowing independent randomization of gameplay-affecting systems versus cosmetic non-deterministic elements like UI animations.

Deterministic randomness applies to mission generation (tile placement, enemy positions), combat outcomes (hit/miss calculations, damage rolls, critical hits), AI behavior (target selection, movement paths), procedural events (alien activity, faction actions), and loot tables (item rewards, artifact discovery), while explicitly excluding user input timing, UI animations, sound effect playback timing, and purely visual particle effects from reproducibility requirements.

## Mechanics

### Core Principles

### Deterministic Randomness

**Definition:**
```
Given the same seed and sequence of operations,
the same random outcomes will be generated.
```

**Guarantee:**
- Same seed → Same mission layout
- Same seed → Same AI decisions
- Same seed → Same dice rolls
- Same seed → Same loot drops

**Non-Determinism Allowed:**
- User input timing
- UI animations (cosmetic)
- Sound effect playback timing
- Particle effect variations (if purely visual)

### Reproducibility Requirements

**What Must Be Reproducible:**
- Mission generation (tile placement, enemy positions)
- Combat outcomes (hit/miss, damage rolls, critical hits)
- AI behavior (target selection, movement paths)
- Procedural events (alien activity, faction actions)
- Loot tables (item rewards, artifact discovery)

**What Need Not Be Reproducible:**
- Menu transition animations
- Particle effect randomness (if visual-only)
- Audio variations (if gameplay-neutral)
- UI element fade timings

---

## Seed Architecture

### Seed Naming Convention

**Pattern:**
```
seed:system:subsystem:id
```

**Hierarchy Levels:**

1. **Campaign Seed** (Top Level)
   ```
   seed:campaign
   Example: seed:campaign:20250930
   ```
   Master seed for entire playthrough

2. **System Seeds** (Major Systems)
   ```
   seed:world
   seed:mission
   seed:combat
   seed:ai
   seed:economy
   ```

3. **Subsystem Seeds** (Specific Components)
   ```
   seed:world:province:123
   seed:mission:terror:456
   seed:combat:hit:789
   seed:ai:faction:alien_empire
   ```

4. **Instance Seeds** (Individual Entities)
   ```
   seed:combat:hit:789:unit_42
   seed:mission:loot:456:crate_3
   seed:world:event:123:ufo_spawn
   ```

### Seed Generation

**Deterministic Derivation:**
```lua
function derive_seed(parent_seed, context)
    -- Simple hash-based derivation
    return (parent_seed * 1103515245 + context) % 2147483647
end

-- Example usage
campaign_seed = 20250930
world_seed = derive_seed(campaign_seed, hash("seed:world"))
province_seed = derive_seed(world_seed, province_id)
```

**Context Hashing:**
```lua
function hash(string_context)
    local hash_value = 0
    for i = 1, #string_context do
        hash_value = hash_value * 31 + string_context:byte(i)
        hash_value = hash_value % 2147483647
    end
    return hash_value
end
```

**Seed Storage:**
```lua
-- Store seeds in save file
save_data.seeds = {
    campaign = 20250930,
    world = 123456789,
    mission_current = 987654321,
    combat_current = 456789123,
    ai_faction = {
        alien_empire = 111222333,
        human_resistance = 444555666
    }
}
```

---

## Random Number Generation

### RNG State Management

**Separate RNG Instances:**
```lua
-- DO NOT use global love.math.random() for gameplay
-- Create dedicated RNG instances for each system

rng_world = love.math.newRandomGenerator(world_seed)
rng_mission = love.math.newRandomGenerator(mission_seed)
rng_combat = love.math.newRandomGenerator(combat_seed)
```

**State Preservation:**
```lua
function save_rng_state(rng, name)
    return {
        name = name,
        state = rng:getState()
    }
end

function restore_rng_state(rng, saved_state)
    rng:setState(saved_state.state)
end
```

### Usage Patterns

**Mission Generation:**
```lua
function generate_mission(mission_seed, mission_type)
    local rng = love.math.newRandomGenerator(mission_seed)
    
    -- Derive subsystem seeds
    local map_seed = derive_seed(mission_seed, hash("map"))
    local enemy_seed = derive_seed(mission_seed, hash("enemies"))
    local loot_seed = derive_seed(mission_seed, hash("loot"))
    
    local mission = {}
    mission.map = generate_map(map_seed, mission_type)
    mission.enemies = spawn_enemies(enemy_seed, mission_type)
    mission.loot = place_loot(loot_seed, mission_type)
    
    return mission
end
```

**Combat Resolution:**
```lua
function resolve_attack(attacker, target, combat_seed)
    local rng = love.math.newRandomGenerator(combat_seed)
    
    -- Deterministic hit calculation
    local hit_roll = rng:random(1, 100)
    local hit_chance = calculate_hit_chance(attacker, target)
    
    if hit_roll <= hit_chance then
        local damage_roll = rng:random(attacker.weapon.min_dmg, attacker.weapon.max_dmg)
        local crit_roll = rng:random(1, 100)
        
        if crit_roll <= attacker.crit_chance then
            damage_roll = damage_roll * 2
        end
        
        return {hit = true, damage = damage_roll, critical = crit_roll <= attacker.crit_chance}
    else
        return {hit = false, damage = 0, critical = false}
    end
end
```

**AI Decision Making:**
```lua
function ai_select_target(ai_unit, visible_enemies, ai_seed)
    local rng = love.math.newRandomGenerator(ai_seed)
    
    -- Deterministic target evaluation
    local target_scores = {}
    for _, enemy in ipairs(visible_enemies) do
        local score = evaluate_target(ai_unit, enemy)
        table.insert(target_scores, {enemy = enemy, score = score})
    end
    
    -- Sort by score (deterministic)
    table.sort(target_scores, function(a, b) return a.score > b.score end)
    
    -- Add slight randomness for variety (still deterministic)
    local top_targets = {}
    for i = 1, math.min(3, #target_scores) do
        table.insert(top_targets, target_scores[i].enemy)
    end
    
    local chosen_index = rng:random(1, #top_targets)
    return top_targets[chosen_index]
end
```

---

## Seed Management

### Campaign Initialization

**New Campaign:**
```lua
function new_campaign(player_chosen_seed)
    local campaign_seed = player_chosen_seed or os.time()
    
    local campaign = {
        seed = campaign_seed,
        world = generate_world(derive_seed(campaign_seed, hash("world"))),
        factions = initialize_factions(derive_seed(campaign_seed, hash("factions"))),
        events = create_event_system(derive_seed(campaign_seed, hash("events")))
    }
    
    return campaign
end
```

**Seed Display:**
```lua
-- Show seed to player for sharing/debugging
function display_campaign_info()
    print("Campaign Seed: " .. campaign.seed)
    print("World Seed: " .. world.seed)
    print("Current Mission Seed: " .. (mission.seed or "N/A"))
end
```

### Mission Lifecycle

**Mission Seed Generation:**
```lua
function create_mission(mission_type, location, campaign_seed)
    -- Deterministic mission seed from campaign seed + context
    local mission_context = string.format("mission:%s:%d:%d", 
        mission_type, location.x, location.y)
    local mission_seed = derive_seed(campaign_seed, hash(mission_context))
    
    return {
        type = mission_type,
        location = location,
        seed = mission_seed,
        generated = false  -- Lazy generation on mission start
    }
end
```

**Mission Regeneration:**
```lua
function regenerate_mission(mission)
    -- If player restarts mission, same seed = same layout
    local layout = generate_mission(mission.seed, mission.type)
    mission.map = layout.map
    mission.enemies = layout.enemies
    mission.loot = layout.loot
    mission.generated = true
end
```

### Combat Turn Resolution

**Turn Seed Derivation:**
```lua
function begin_combat_turn(combat_state)
    local turn_number = combat_state.turn_number
    local turn_seed = derive_seed(combat_state.mission_seed, turn_number)
    
    combat_state.current_turn_seed = turn_seed
    combat_state.action_counter = 0  -- Reset for this turn
end
```

**Action Seed Derivation:**
```lua
function execute_action(unit, action, combat_state)
    -- Each action gets unique seed within turn
    local action_seed = derive_seed(
        combat_state.current_turn_seed,
        combat_state.action_counter
    )
    combat_state.action_counter = combat_state.action_counter + 1
    
    -- Use action_seed for all randomness in this action
    local result = resolve_action(unit, action, action_seed)
    return result
end
```

---

## Debugging Tools

### Seed Logging

**Debug Output:**
```lua
function log_seed_chain(seed_path)
    print("=== SEED CHAIN ===")
    print("Campaign: " .. campaign.seed)
    print("World: " .. world.seed)
    print("Mission: " .. (mission.seed or "N/A"))
    print("Combat Turn: " .. (combat.current_turn_seed or "N/A"))
    print("Action: " .. (combat.last_action_seed or "N/A"))
    print("==================")
end
```

**Seed Trace:**
```lua
function trace_seed(seed, operation)
    if DEBUG_SEEDS then
        local info = debug.getinfo(2, "Sl")
        print(string.format("[SEED] %s @ %s:%d | seed=%d",
            operation, info.short_src, info.currentline, seed))
    end
end

-- Example usage
trace_seed(mission_seed, "generate_mission")
```

### Replay System

**Record Action Sequence:**
```lua
function record_action(combat_state, unit_id, action_type, action_data)
    table.insert(combat_state.replay_log, {
        turn = combat_state.turn_number,
        action_index = combat_state.action_counter,
        unit_id = unit_id,
        action_type = action_type,
        action_data = action_data
    })
end
```

**Replay Combat:**
```lua
function replay_combat(mission_seed, replay_log)
    local combat_state = initialize_combat(mission_seed)
    
    for _, action_record in ipairs(replay_log) do
        while combat_state.turn_number < action_record.turn do
            advance_turn(combat_state)
        end
        
        local unit = find_unit(combat_state, action_record.unit_id)
        execute_action(unit, action_record.action_data, combat_state)
    end
    
    return combat_state
end
```

### Bug Reproduction

**Minimal Reproduction Case:**
```lua
function reproduce_bug_combat_turn()
    -- Exact seed chain for bug report
    local campaign_seed = 20250930  -- From bug report
    local mission_seed = derive_seed(campaign_seed, hash("mission:terror:45:67"))
    local turn_3_seed = derive_seed(mission_seed, 3)
    local action_5_seed = derive_seed(turn_3_seed, 5)
    
    -- Reproduce exact action
    local attacker = create_test_unit("soldier", {aim = 75})
    local target = create_test_unit("alien", {defense = 20})
    
    local result = resolve_attack(attacker, target, action_5_seed)
    
    print("Hit: " .. tostring(result.hit))
    print("Damage: " .. result.damage)
    print("Critical: " .. tostring(result.critical))
end
```

---

## Testing Strategies

### Unit Tests

**Determinism Verification:**
```lua
function test_deterministic_mission_generation()
    local seed = 12345
    
    local mission1 = generate_mission(seed, "terror")
    local mission2 = generate_mission(seed, "terror")
    
    assert(missions_equal(mission1, mission2), "Missions with same seed must be identical")
end
```

**RNG State Test:**
```lua
function test_rng_state_preservation()
    local rng = love.math.newRandomGenerator(54321)
    
    local before = {rng:random(), rng:random(), rng:random()}
    local state = rng:getState()
    local after1 = {rng:random(), rng:random(), rng:random()}
    
    rng:setState(state)
    local after2 = {rng:random(), rng:random(), rng:random()}
    
    assert(arrays_equal(after1, after2), "Restored RNG state must produce same sequence")
end
```

### Integration Tests

**Combat Replay Test:**
```lua
function test_combat_replay()
    local mission_seed = 99999
    
    -- Simulate combat and record actions
    local combat1 = run_combat(mission_seed)
    local replay_log = combat1.replay_log
    
    -- Replay from same seed
    local combat2 = replay_combat(mission_seed, replay_log)
    
    -- Final states must match
    assert(combat_states_equal(combat1, combat2), "Replayed combat must produce identical outcome")
end
```

**Save/Load Test:**
```lua
function test_save_load_determinism()
    local campaign1 = new_campaign(11111)
    advance_time(campaign1, 100)  -- Simulate 100 time units
    
    local save_data = serialize_campaign(campaign1)
    local campaign2 = deserialize_campaign(save_data)
    
    -- Continue from loaded state
    advance_time(campaign1, 50)
    advance_time(campaign2, 50)
    
    assert(campaigns_equal(campaign1, campaign2), "Loaded campaign must continue identically")
end
```

---

## Implementation Guidelines

### DO's

**✓ Use Dedicated RNG Instances:**
```lua
-- GOOD
local rng_mission = love.math.newRandomGenerator(mission_seed)
local value = rng_mission:random(1, 100)
```

**✓ Derive Seeds Hierarchically:**
```lua
-- GOOD
local mission_seed = derive_seed(campaign_seed, mission_id)
local enemy_seed = derive_seed(mission_seed, hash("enemies"))
```

**✓ Store Seeds in Save Data:**
```lua
-- GOOD
save_data.seeds = {
    campaign = campaign.seed,
    world = world.seed,
    current_mission = mission.seed
}
```

**✓ Log Seeds for Debugging:**
```lua
-- GOOD
if DEBUG_MODE then
    print("Mission Seed: " .. mission.seed)
end
```

### DON'Ts

**✗ Don't Use Global Random:**
```lua
-- BAD: Global RNG state is shared and unpredictable
local value = love.math.random(1, 100)
```

**✗ Don't Use Time-Based Seeds for Gameplay:**
```lua
-- BAD: os.time() makes behavior non-reproducible
local loot_seed = os.time()
```

**✗ Don't Mix Deterministic and Non-Deterministic:**
```lua
-- BAD: Mixing seeded RNG with global RNG
local value1 = rng_mission:random(1, 100)  -- Deterministic
local value2 = love.math.random(1, 100)     -- Non-deterministic
```

**✗ Don't Forget to Save RNG State:**
```lua
-- BAD: Losing RNG state between save/load
function save_combat()
    return {units = units, turn = turn}  -- Missing RNG state!
end
```

---

## Advanced Topics

### Parallel RNG Streams

**Problem:**
Multiple systems need independent randomness simultaneously.

**Solution:**
```lua
function create_rng_pool(base_seed, stream_names)
    local pool = {}
    for _, name in ipairs(stream_names) do
        local stream_seed = derive_seed(base_seed, hash(name))
        pool[name] = love.math.newRandomGenerator(stream_seed)
    end
    return pool
end

-- Usage
local rng_pool = create_rng_pool(campaign_seed, {
    "world_events",
    "faction_ai",
    "loot_tables",
    "terrain_gen"
})

local event = rng_pool.world_events:random(1, 100)
local loot = rng_pool.loot_tables:random(1, 100)
```

### Seed Version Compatibility

**Problem:**
Game updates change RNG usage, breaking old seeds.

**Solution:**
```lua
function generate_mission_v1(mission_seed)
    -- Original algorithm
end

function generate_mission_v2(mission_seed)
    -- Updated algorithm
end

function generate_mission(mission_seed, version)
    if version == 1 then
        return generate_mission_v1(mission_seed)
    else
        return generate_mission_v2(mission_seed)
    end
end

-- Store version in save data
save_data.mission_version = 2
```

### Fuzzing/Stress Testing

**Seed Range Testing:**
```lua
function stress_test_mission_generation()
    local failures = {}
    
    for seed = 1, 10000 do
        local success, result = pcall(generate_mission, seed, "terror")
        if not success then
            table.insert(failures, {seed = seed, error = result})
        end
    end
    
    print("Failures: " .. #failures .. " / 10000")
    return failures
end
```

---

## Performance Considerations

### RNG Overhead

**Caching Derived Seeds:**
```lua
-- Cache frequently-used seeds
seed_cache = {}

function get_province_seed(province_id)
    if not seed_cache[province_id] then
        seed_cache[province_id] = derive_seed(world_seed, province_id)
    end
    return seed_cache[province_id]
end
```

**Batch Generation:**
```lua
-- Generate all random values upfront
function pregenerate_loot_table(loot_seed, item_count)
    local rng = love.math.newRandomGenerator(loot_seed)
    local items = {}
    
    for i = 1, item_count do
        items[i] = {
            type = rng:random(1, 10),
            quantity = rng:random(1, 5),
            quality = rng:random(1, 100)
        }
    end
    
    return items
end
```

---

## Troubleshooting Guide

### "Results aren't reproducible"

**Checklist:**
1. Are you using dedicated RNG instances? (Not global `love.math.random()`)
2. Are seeds stored in save data?
3. Are RNG states saved/restored correctly?
4. Are you calling RNG in consistent order?
5. Are you mixing deterministic and non-deterministic sources?

### "Seeds change after update"

**Diagnosis:**
Version compatibility issue. Update changed RNG call sequence.

**Fix:**
Implement version-specific generation functions (see Seed Version Compatibility above).

### "AI behaves differently on replay"

**Diagnosis:**
AI is likely using frame-time or other non-deterministic data.

**Fix:**
```lua
-- BAD
function ai_think(dt)
    if love.math.random() < dt then  -- dt varies, non-deterministic!
        attack()
    end
end

-- GOOD
function ai_think(turn_seed)
    local rng = love.math.newRandomGenerator(turn_seed)
    if rng:random() < 0.5 then  -- Fixed probability, deterministic
        attack()
    end
end
```

## Examples

### Mission Generation Reproducibility
Campaign seed "20250930" generates Province 123 with seed "seed:world:province:123". The province spawns UFO at coordinates (45, 78) with 6 aliens. Reloading from save with identical seed produces exact same UFO position and alien count.

### Combat Dice Roll Consistency
Unit 42 attacks with 75% accuracy using seed "seed:combat:hit:789:unit_42". First attack: RNG roll = 0.23 → Hit. Second attack: RNG roll = 0.87 → Miss. Replay from save produces identical 0.23 and 0.87 rolls.

### AI Decision Determinism
Alien faction AI uses seed "seed:ai:faction:alien_empire" to select terror mission target. Utility scores: CityA=45.2, CityB=38.7, CityC=52.1. AI selects CityC. Replay produces identical utility scores and CityC selection.

### Loot Table Resolution
Mission 456 crate 3 uses seed "seed:mission:loot:456:crate_3". Loot roll = 0.67 → Plasma Rifle. Replaying mission from checkpoint generates identical 0.67 roll and Plasma Rifle reward.

### Procedural Event Timing
Geoscape scheduler uses seed "seed:world:event:123" to determine next UFO spawn. Calculated spawn time: Day 15, Hour 08:00. Multiple reloads produce identical spawn timing.

### Save-Scum Scenario
Player saves before 65% shot. Seed produces miss (roll 0.71). Player reloads, takes same shot with identical seed → miss (0.71). Player reloads, repositions unit (different seed) → hit (new roll 0.34). Determinism preserved while allowing tactical flexibility.

## Related Wiki Pages

- [Save System](technical/Save_System.md) - Seed persistence and save/load mechanics
- [AI System](ai/README.md) - Deterministic AI decision-making architecture
- [Procedural Generation](procedure/README.md) - Seeded world and mission generation
- [Combat System](battlescape/README.md) - Deterministic combat resolution
- [Random Number Generation](technical/README.md) - RNG implementation details

## References to Existing Games and Mechanics

- **Civilization Series**: Seeded map generation and combat rolls
- **XCOM Series**: Deterministic hit calculations (XCOM 2 true random vs seeded debate)
- **Slay the Spire**: Seeded runs for competitive play and replay
- **Spelunky**: Daily challenge seeds for leaderboard competitions
- **Minecraft**: World generation from seed values
- **Into the Breach**: Perfect information with deterministic outcomes
- **FTL**: Seeded runs for challenge reproducibility
- **Dwarf Fortress**: Procedural world generation from seed
- **Nuclear Throne**: Daily/weekly seeded challenge runs
- **The Binding of Isaac**: Seeded runs for consistent gameplay
