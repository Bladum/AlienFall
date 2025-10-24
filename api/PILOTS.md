# Pilots API Reference

## Overview

The Pilot system manages aircraft and spacecraft personnel who gain experience through interception combat. Unlike ground soldiers, pilots are operator specialists focused on vehicle operations with progression through ranks (Rookie → Veteran → Ace).

**Key Characteristics:**
- **Operator Role**: Focus on craft operation, not ground combat
- **XP Source**: Pilots gain experience only from interception combat
- **Craft Integration**: Pilot stats provide bonuses to craft performance
- **Progression**: Three-tier rank system with stat bonuses
- **Specialization**: Four pilot class variants optimized for different craft types

---

## Pilot Classes

### PILOT (Base Class)
Standard aircraft pilot trained for general craft operations.

**Stats:**
- Health: 50 HP (lowest front-line value)
- Speed: 8 (high reactivity for flying)
- Aim: 7 (moderate accuracy)
- Reaction: 8 (fast reflexes)
- Strength: 5
- Energy: 10
- Wisdom: 6
- PSI: 0

**Perks:**
- `can_move` - Standard movement
- `can_run` - Sprint capability
- `can_shoot` - Ranged combat
- `can_melee` - Close combat
- `can_throw` - Grenades
- `skilled_pilot` - Craft operation bonus

**Role**: General operations across all craft types
**Preferred Craft**: Any

---

### FIGHTER_PILOT (Elite Interceptor Specialist)
Elite aircraft combat pilot specialized for dogfighting and interceptor operations.

**Stats:**
- Health: 55 HP
- Speed: 9 (highest mobility)
- Aim: 8 (superior accuracy)
- Reaction: 9 (fastest reflexes)
- Strength: 6
- Energy: 10
- Wisdom: 7
- PSI: 0

**Perks:**
- All PILOT perks, plus:
- `ace_pilot` - Advanced piloting bonuses
- `sharpshooter` - Better targeting in combat

**Role**: Interceptor craft combat and dogfighting
**Preferred Craft**: Lightning Interceptor, Avenger

---

### BOMBER_PILOT (Transport & Heavy Craft Specialist)
Transport and heavy craft specialist with focus on endurance and control.

**Stats:**
- Health: 60 HP (highest durability)
- Speed: 7 (moderate maneuverability)
- Aim: 6 (lower accuracy)
- Reaction: 7 (moderate reflexes)
- Strength: 7 (highest strength for heavy control)
- Energy: 12 (higher energy)
- Wisdom: 7
- PSI: 0

**Perks:**
- All PILOT perks, plus:
- `steady_hand` - Reduced accuracy loss
- `iron_constitution` - Better health regeneration

**Role**: Transport and heavy aircraft operations
**Preferred Craft**: Skyranger, Avenger (as second pilot)

---

### HELICOPTER_PILOT (VTOL Specialist)
Vertical takeoff/landing specialist for hover and precision operations.

**Stats:**
- Health: 55 HP
- Speed: 7 (good maneuverability)
- Aim: 7 (good accuracy)
- Reaction: 9 (precise control)
- Strength: 5
- Energy: 10
- Wisdom: 8 (highest spatial awareness)
- PSI: 0

**Perks:**
- All PILOT perks, plus:
- `precision_control` - Hover bonuses
- `steady_aim` - Better accuracy while hovering

**Role**: Transport and precision operations
**Preferred Craft**: Skyranger, other VTOL craft

---

## Rank System

Pilots progress through three ranks based on experience gained during interception combat.

### Rank Progression

| Rank | XP Required | Insignia | Color | Bonuses |
|------|-------------|----------|-------|---------|
| **Rookie** | 0 | Bronze | Gold/Brown | Baseline |
| **Veteran** | 100+ | Silver | Gray/White | Speed +1, Aim +2, Reaction +1 |
| **Ace** | 300+ | Gold | Gold/Yellow | Speed +2, Aim +4, Reaction +2 |

### Rank Bonuses

When pilots rank up, they gain stat bonuses that apply in combat:

- **Speed +1 per rank**: Better mobility in flight operations
- **Aim +2 per rank**: Improved targeting accuracy (stacks)
- **Reaction +1 per rank**: Faster reaction time in combat

**Example**: A Rookie pilot with base Speed 8 becomes:
- Veteran: Speed 9 (8 + 1)
- Ace: Speed 10 (8 + 2)

---

## Experience System

### XP Awards

Pilots gain experience exclusively from interception combat:

```lua
-- XP = Enemy Total HP / 10 (shared among all assigned pilots)
-- Example: 100 HP UFO = 10 XP per pilot
```

### Mission Recording

Missions are recorded with statistics:

```lua
PilotProgression.recordMission(pilotId, victory, kills, damage_dealt)
```

- **victory** (boolean): Whether the interception was successful
- **kills** (number): Enemy units destroyed
- **damage_dealt** (number): Total damage inflicted (used for XP calculation)

**XP Formula for Victory**: `floor(damage_dealt / 10) XP`

### Rank-Up Process

1. Pilot gains XP during interception combat
2. When total XP reaches rank threshold, automatic rank-up triggers
3. Stats increase by rank bonuses
4. XP counter resets for next rank
5. Rank insignia updates in UI

---

## Craft Integration

### Pilot Requirements

Each craft type requires specific pilot counts and minimum ranks:

| Craft Type | Required Pilots | Min Rank | Preferred Classes | Notes |
|------------|-----------------|----------|-------------------|-------|
| **Interceptor** | 1 | Rookie | PILOT, FIGHTER_PILOT | Single-seat fighter |
| **Transport** | 1 | Rookie | PILOT, HELICOPTER_PILOT | General transport |
| **Scout** | 1 | Rookie | PILOT, FIGHTER_PILOT | Fast reconnaissance |
| **Bomber** | 2 | Veteran | BOMBER_PILOT, PILOT | Heavy aircraft (requires 2) |
| **Sentinel** | 2 | Ace | Any (3+ acceptable) | Heavy escort (requires ace pilots) |

### Craft Bonuses from Pilots

Assigned pilot stats provide percentage bonuses to craft capabilities:

```lua
-- Base Formula (per pilot stat):
craft_bonus = (pilot_stat / 10) * 100%

-- Example: Pilot with Speed 8 provides +80% speed bonus
```

**Craft Stats Affected:**
- `dodge`: Based on pilot Speed
- `targeting_accuracy`: Based on pilot Aim
- `reaction_time`: Based on pilot Reaction
- `fuel_efficiency`: Based on pilot Wisdom (pilot knowledge)

**Multi-Pilot Bonus Stacking:**
- First pilot: 100% bonus value
- Second pilot: 50% bonus value (diminishing returns)

**Example**: Two pilots assigned to Avenger:
- Pilot 1 (Speed 9): +90% dodge
- Pilot 2 (Speed 7): +35% dodge (50% of base 70%)
- **Total Dodge Bonus**: +125%

---

## Pilot UI Displays

### Pilot Card (In-Game UI)

```
┌─────────────────────────────┐
│ PILOT PROFILE               │
├─────────────────────────────┤
│ Name: Alice "Ace" Rodriguez  │
│ Rank: Ace (Gold Insignia)   │
│ Class: Fighter Pilot        │
│ Status: Active              │
├─────────────────────────────┤
│ Experience:                 │
│ XP Progress: ████████░░ 84% │
│ Missions: 12 | Kills: 47    │
│ Victories: 11 | Defeats: 1  │
├─────────────────────────────┤
│ Assigned To: Avenger        │
│ Role: Primary Pilot         │
├─────────────────────────────┤
│ Stat Bonuses:               │
│ +2 Speed | +4 Aim | +2 Reaction
└─────────────────────────────┘
```

### Pilot Roster (Basescape UI)

Lists all base pilots with:
- Name and rank insignia
- Class type
- Current assignment
- Availability status
- Quick-access options (recruit, reassign, promote)

---

## API Methods

### PilotProgression Module

**Initialization:**
```lua
PilotProgression.initializePilot(pilotId, initialRank)
```
- **pilotId** (number): Unit ID
- **initialRank** (number, optional): Starting rank (default: 0/Rookie)

**Experience:**
```lua
PilotProgression.gainXP(pilotId, xpAmount, source)
```
- **pilotId** (number): Pilot unit ID
- **xpAmount** (number): XP to award
- **source** (string, optional): XP source label
- **Returns**: boolean (true if ranked up)

**Rank Queries:**
```lua
rank = PilotProgression.getRank(pilotId)           -- Get rank 0-2
xp = PilotProgression.getXP(pilotId)              -- Get current rank XP
totalXp = PilotProgression.getTotalXP(pilotId)    -- Get lifetime XP
progress = PilotProgression.getXPProgress(pilotId) -- Get progress % (0-100)
```

**Rank Information:**
```lua
insignia = PilotProgression.getRankInsignia(pilotId)
-- Returns: {name, type, color}
-- Example: {name="Ace", type="gold", color={255,215,0}}

rankDef = PilotProgression.getRankDef(rankId)
-- Returns: Rank definition table
```

**Mission Recording:**
```lua
PilotProgression.recordMission(pilotId, victory, kills, damage_dealt)
```
- **pilotId** (number): Pilot unit ID
- **victory** (boolean): Mission success
- **kills** (number): Enemies destroyed
- **damage_dealt** (number): Total damage for XP calculation

**Comprehensive Stats:**
```lua
stats = PilotProgression.getPilotStats(pilotId)
```
Returns complete pilot data:
```lua
{
    id = pilotId,
    rank = "Veteran",
    rank_id = 1,
    xp_current = 45,
    xp_total = 145,
    xp_progress = 45,  -- % to next rank
    kills = 12,
    missions_flown = 8,
    victories = 7,
    defeats = 1,
    insignia = {name="Veteran", type="silver", color={200,200,200}},
    stat_bonuses = {
        speed = 1,
        aim = 2,
        reaction = 1
    }
}
```

### Unit Class (Perks Integration)

**Perk Initialization (automatic in Unit.new):**
```lua
unit.perks = {
    ["can_move"] = true,
    ["can_run"] = true,
    ["can_shoot"] = true,
    ["skilled_pilot"] = true,
    -- ... other perks
}
```

### CraftManager (Pilot Assignment)

**Pilot Validation:**
```lua
valid, reason = craftManager:validatePilots(craftId, pilots)
```
- **craftId** (string): Craft ID
- **pilots** (table): Array of pilot tables
- **Returns**: boolean success, string reason/error

**Pilot Assignment:**
```lua
success, reason = craftManager:assignPilots(craftId, pilots)
```
- **craftId** (string): Craft ID
- **pilots** (table): Array of {id, rank, class}
- **Returns**: boolean success, string reason

**Get Requirements:**
```lua
requirements = craftManager:getPilotRequirements(craftType)
```
- **Returns**: {required_count, min_level, preferred_classes, allow_bomber}

---

## Example Usage

### Creating a Pilot Unit

```lua
local Unit = require("battlescape.combat.unit")

-- Create fighter pilot
local ace = Unit.new("fighter_pilot", "player", 5, 5)
print(string.format("Created %s: Speed %d, Aim %d",
    ace.name, ace.stats.speed, ace.stats.aim))
-- Output: Created Jane Doe: Speed 9, Aim 8

-- Check perks
if ace.perks["ace_pilot"] then
    print("Fighter pilot has ace_pilot bonus!")
end
```

### Awarding XP and Rank-Up

```lua
local PilotProgression = require("basescape.logic.pilot_progression")

-- Initialize pilot
PilotProgression.initializePilot(42, 0)  -- Rookie

-- Award XP from victory
local ranked_up = PilotProgression.gainXP(42, 50, "interception_victory")
if ranked_up then
    print("Pilot promoted!")
end

-- Get stats
local stats = PilotProgression.getPilotStats(42)
print(string.format("Rank: %s, XP Progress: %d%%",
    stats.rank, stats.xp_progress))
```

### Assigning Pilots to Craft

```lua
local CraftManager = require("content.crafts.craft_manager")

local manager = CraftManager.new()

-- Validate pilots before assignment
local pilots = {{id=42, rank=1, class="fighter_pilot"}}
local valid, reason = manager:validatePilots("interceptor_1", pilots)

if valid then
    manager:assignPilots("interceptor_1", pilots)
    print("Pilots assigned successfully!")
else
    print("Assignment failed: " .. reason)
end
```

### Recording Mission Performance

```lua
-- After interception combat
local victory = true
local kills = 2
local damage_dealt = 150

PilotProgression.recordMission(42, victory, kills, damage_dealt)
-- Awards: 15 XP (150 / 10)
```

---

## Configuration

Pilot class definitions are loaded from:
```
mods/core/rules/unit/classes.toml
```

Perk definitions are loaded from:
```
mods/core/rules/unit/perks.toml
```

Craft pilot requirements are hardcoded in `CraftManager.getPilotRequirements()`.

---

## Integration Points

| System | Integration | Purpose |
|--------|-------------|---------|
| **Unit System** | Pilot units created with Unit.new() | Ground deployment of pilots |
| **Perk System** | Perks initialized from class definition | Trait flags for abilities |
| **Craft System** | Pilots provide stat bonuses | Flight performance enhancement |
| **Interception System** | XP awards during combat | Pilot experience tracking |
| **Base Management** | Pilot roster and assignment UI | Personnel management |
| **Save System** | Pilot progression serialization | Game persistence |

---

## See Also

- [UNITS.md](UNITS.md) - Unit system and classes
- [CRAFTS.md](CRAFTS.md) - Craft system and requirements
- [BATTLESCAPE.md](BATTLESCAPE.md) - Combat mechanics
- [INTERCEPTION.md](INTERCEPTION.md) - Interception combat
