# Pilots API Reference

**System:** Operational Layer (Personnel Management / Aircraft Crew)  
**Module:** `engine/basescape/logic/pilot_progression.lua`  
**Latest Update:** 2025-10-27  
**Status:** ✅ Complete

---

## 📋 Scope & Related Systems

**This API covers:**
- Pilot entity structure and properties
- Experience and rank progression system
- Craft assignment and crew management
- Pilot stat bonuses to craft performance
- Pilot class specializations

**For related systems, see:**
- **[UNITS.md](UNITS.md)** - Base unit system (pilots are specialized units)
- **[CRAFTS.md](CRAFTS.md)** - Craft entities and crew requirements
- **[INTERCEPTION.md](INTERCEPTION.md)** - Air combat where pilots gain XP

---

## Overview

The Pilot system manages aircraft and spacecraft personnel who gain experience through interception combat. Unlike ground soldiers, pilots are operator specialists focused on vehicle operations with progression through ranks (Rookie → Veteran → Ace).

**Layer Classification:** Operational / Personnel Management  
**Primary Responsibility:** Pilot progression, craft crew assignment, stat bonuses to craft  
**Integration Points:** Units (base system), Crafts (crew assignment), Interception (XP gain)

**Key Characteristics:**
- **Operator Role**: Focus on craft operation, not ground combat
- **XP Source**: Pilots gain experience only from interception combat
- **Craft Integration**: Pilot stats provide bonuses to craft performance
- **Progression**: Three-tier rank system with stat bonuses
- **Specialization**: Four pilot class variants optimized for different craft types

---

## Implementation Status

### ✅ Implemented (in engine/basescape/logic/)
- Pilot progression system with XP tracking (`pilot_progression.lua`)
- Three-rank system: Rookie, Veteran, Ace
- Automatic stat increases on rank-up
- XP gain from interception combat
- Rank insignia and display
- Performance metrics tracking

### 🚧 Partially Implemented
- Craft bonus calculation from pilot stats
- Multiple pilot assignment (for heavy craft)
- Pilot fatigue system

### 📋 Planned (in design/)
- Pilot traits and special abilities
- Pilot training programs
- Crew cohesion bonuses
- Named ace pilots with unique abilities

---

## Core Entities

### Entity: Pilot

Specialized unit focused on craft operation. Extends Unit with pilot-specific properties.

**Properties:**
```lua
Pilot = {
  -- Inherits all Unit properties (see UNITS.md)
  id = number,                    -- Unit ID
  name = string,                  -- Pilot name
  type = "pilot",                 -- Unit type
  class = string,                 -- "pilot", "fighter_pilot", "bomber_pilot", "helicopter_pilot"
  faction = string,               -- "xcom", etc.
  
  -- Pilot-Specific Properties
  pilot_rank = number,            -- 0 = Rookie, 1 = Veteran, 2 = Ace
  pilot_xp = number,              -- Current XP in this rank
  total_xp_earned = number,       -- Total XP across all ranks
  
  -- Pilot Stats (used for craft bonuses)
  pilot_stats = {
    speed = number,               -- 6-10 (affects craft dodge)
    aim = number,                 -- 6-10 (affects craft targeting)
    reaction = number,            -- 6-10 (affects initiative)
    strength = number,            -- 5-8 (affects heavy craft control)
    energy = number,              -- 6-10 (affects stamina)
    wisdom = number,              -- 6-10 (affects decision making)
    psi = number,                 -- 0-10 (psionic ability, rare)
  },
  
  -- Assignment
  assigned_craft = string | nil,  -- Craft ID if assigned
  crew_position = number | nil,   -- 0 = pilot, 1 = co-pilot, 2+ = crew
  
  -- Performance Metrics
  missions = number,              -- Interceptions flown
  victories = number,             -- Successful interceptions
  defeats = number,               -- Failed interceptions
  kills = number,                 -- Enemy craft destroyed
  damage_dealt = number,          -- Total damage inflicted
  
  -- Status
  status = string,                -- "available", "assigned", "flying", "wounded", "deceased"
  fatigue = number,               -- 0-100 (future feature)
  
  -- Timestamps
  created_at = number,            -- Creation timestamp
  last_mission = number | nil,    -- Last mission timestamp
}
```

**TOML Configuration:**
```toml
[[unit]]
id = "pilot_rookie"
name = "Rookie Pilot"
description = "Newly trained aircraft pilot"
type = "pilot"
faction = "xcom"
class = "pilot"
pilot_rank = 0
pilot_xp = 0

[unit.stats]
health = 50
armor = 0
will = 65
reaction = 80
shooting = 60
throwing = 40
strength = 55

[unit.pilot_stats]
speed = 6
aim = 6
reaction = 8
strength = 5
energy = 6
wisdom = 6
psi = 0

[unit.equipment]
primary = "pistol"
armor = "pilot_suit"

[unit.perks]
default = ["can_move", "can_shoot", "no_morale_penalty"]
```

---

## Functions

### Pilot Progression

#### PilotProgression.initializePilot(pilotId, initialRank)
Initialize pilot progression tracking.

**Parameters:**
- `pilotId` (number) - Pilot unit ID
- `initialRank` (number) - Starting rank (0=Rookie, 1=Veteran, 2=Ace)

**Returns:** void

```lua
local PilotProgression = require("basescape.logic.pilot_progression")
PilotProgression.initializePilot(101, 0)  -- Initialize as Rookie
```

---

#### PilotProgression.gainXP(pilotId, xpAmount, source)
Award XP to a pilot. Automatically checks for rank-up.

**Parameters:**
- `pilotId` (number) - Pilot unit ID
- `xpAmount` (number) - XP to award
- `source` (string) - Source description (e.g., "interception_victory")

**Returns:** boolean - True if pilot ranked up

```lua
local rankedUp = PilotProgression.gainXP(101, 15, "UFO destroyed")
if rankedUp then
    print("Pilot achieved new rank!")
end
```

**XP Calculation:**
```lua
-- From interception combat:
local xp = math.floor(enemy_total_hp / 10)
PilotProgression.gainXP(pilotId, xp, "interception_victory")
```

---

#### PilotProgression.checkRankUp(pilotId)
Check if pilot should rank up and process if needed.

**Parameters:**
- `pilotId` (number) - Pilot unit ID

**Returns:** boolean - True if pilot ranked up

```lua
local rankedUp = PilotProgression.checkRankUp(101)
```

---

#### PilotProgression.getRank(pilotId)
Get pilot's current rank ID.

**Parameters:**
- `pilotId` (number) - Pilot unit ID

**Returns:** number - Rank ID (0=Rookie, 1=Veteran, 2=Ace)

```lua
local rank = PilotProgression.getRank(101)
-- 0 = Rookie, 1 = Veteran, 2 = Ace
```

---

#### PilotProgression.getXP(pilotId)
Get pilot's current XP in this rank.

**Parameters:**
- `pilotId` (number) - Pilot unit ID

**Returns:** number - Current XP toward next rank

```lua
local xp = PilotProgression.getXP(101)  -- e.g., 45 XP toward Veteran
```

---

#### PilotProgression.getTotalXP(pilotId)
Get total XP earned by pilot across all ranks.

**Parameters:**
- `pilotId` (number) - Pilot unit ID

**Returns:** number - Total XP earned

```lua
local totalXP = PilotProgression.getTotalXP(101)
```

---

#### PilotProgression.getRankDef(rankId)
Get rank definition information.

**Parameters:**
- `rankId` (number) - Rank ID (0, 1, or 2)

**Returns:** table | nil - Rank definition or nil

```lua
local rankDef = PilotProgression.getRankDef(1)
-- Returns: {id=1, name="Veteran", xp_required=100, insignia="silver", color={200,200,200}}
```

---

#### PilotProgression.getRankInsignia(pilotId)
Get rank insignia for UI display.

**Parameters:**
- `pilotId` (number) - Pilot unit ID

**Returns:** table - Insignia info `{name, type, color}`

```lua
local insignia = PilotProgression.getRankInsignia(101)
-- Returns: {name="Veteran", type="silver", color={200, 200, 200}}
```

---

#### PilotProgression.getXPProgress(pilotId)
Get XP progress to next rank as percentage.

**Parameters:**
- `pilotId` (number) - Pilot unit ID

**Returns:** number - Progress percentage (0-100)

```lua
local progress = PilotProgression.getXPProgress(101)
-- 45 XP out of 100 required = 45.0
```

---

#### PilotProgression.recordMission(pilotId, victory, kills, damageDealt)
Record mission statistics for pilot.

**Parameters:**
- `pilotId` (number) - Pilot unit ID
- `victory` (boolean) - Whether mission was successful
- `kills` (number) - Enemy craft destroyed
- `damageDealt` (number) - Total damage inflicted

**Returns:** void

```lua
PilotProgression.recordMission(101, true, 1, 150)
```

---

#### PilotProgression.applyRankBonuses(pilotId, unit)
Apply rank stat bonuses to unit stats (called automatically on rank-up).

**Parameters:**
- `pilotId` (number) - Pilot unit ID
- `unit` (Unit) - Unit object to modify

**Returns:** void

**Rank Bonuses Per Rank:**
- Speed: +1
- Aim: +2
- Reaction: +1

```lua
-- Automatically called on rank-up, but can be called manually:
PilotProgression.applyRankBonuses(101, unitObject)
```

---

### Craft Assignment

#### Craft.assignPilot(craft, pilot)
Assign a pilot to a craft.

**Parameters:**
- `craft` (Craft) - Craft object
- `pilot` (Pilot) - Pilot unit object

**Returns:** boolean - True if successful

```lua
local success = craft:assignPilot(pilotUnit)
if success then
    print("Pilot assigned to " .. craft.name)
end
```

---

#### Craft.removePilot(craft, pilotId)
Remove a pilot from craft crew.

**Parameters:**
- `craft` (Craft) - Craft object
- `pilotId` (number) - Pilot unit ID

**Returns:** boolean - True if successful

```lua
craft:removePilot(101)
```

---

#### Craft.getPilots(craft)
Get all pilots assigned to craft.

**Parameters:**
- `craft` (Craft) - Craft object

**Returns:** Pilot[] - Array of pilot units

```lua
local pilots = craft:getPilots()
for _, pilot in ipairs(pilots) do
    print(pilot.name .. " - Rank: " .. pilot.pilot_rank)
end
```

---

#### Craft.calculatePilotBonuses(craft)
Calculate stat bonuses from assigned pilots.

**Parameters:**
- `craft` (Craft) - Craft object

**Returns:** table - Bonus values `{dodge, targeting_accuracy, speed}`

**Bonus Formula:**
```lua
-- Per pilot stat:
bonus = (pilot_stat / 10) * 100  -- As percentage

-- Example: Pilot with Speed 8 provides +80% dodge bonus
-- Multiple pilots: bonuses are averaged
```

```lua
local bonuses = craft:calculatePilotBonuses()
-- Returns: {dodge = 80, targeting_accuracy = 60, speed = 70}
```

---

## Pilot Classes

Pilots come in four specialized classes, each optimized for different craft types.

### PILOT (Base Class)
Standard aircraft pilot trained for general craft operations.

**Stats:**
- Health: 50 HP
- Speed: 6
- Aim: 6
- Reaction: 8
- Strength: 5
- Energy: 6
- Wisdom: 6
- PSI: 0

**Perks:**
- `can_move`, `can_run`, `can_shoot`, `can_melee`, `can_throw`
- `skilled_pilot` - Craft operation bonus
- `no_morale_penalty` - Immune to morale penalties while piloting

**Role**: General operations across all craft types  
**Preferred Craft**: Any  
**Specialization**: Balanced, versatile operations

---

### FIGHTER_PILOT (Elite Interceptor Specialist)
Elite aircraft combat pilot specialized for dogfighting.

**Stats:**
- Health: 55 HP
- Speed: 7 (+1)
- Aim: 8 (+2)
- Reaction: 9 (+1)
- Strength: 6 (+1)
- Energy: 7 (+1)
- Wisdom: 7 (+1)
- PSI: 0

**Perks:**
- All PILOT perks, plus:
- `ace_pilot` - Advanced piloting bonuses (+10% dodge)
- `sharpshooter` - Better targeting (+15% accuracy)

**Role**: Interceptor combat and dogfighting  
**Preferred Craft**: Lightning Interceptor, Avenger  
**Specialization**: High-speed combat, pursuit

---

### BOMBER_PILOT (Transport & Heavy Craft Specialist)
Heavy craft specialist with endurance focus.

**Stats:**
- Health: 60 HP (+10)
- Speed: 6
- Aim: 6
- Reaction: 7 (-1)
- Strength: 7 (+2)
- Energy: 8 (+2)
- Wisdom: 7 (+1)
- PSI: 0

**Perks:**
- All PILOT perks, plus:
- `steady_hand` - Reduced accuracy loss from damage
- `iron_constitution` - Better stamina (+20% energy regen)

**Role**: Transport and heavy aircraft  
**Preferred Craft**: Skyranger, Avenger (co-pilot)  
**Specialization**: Heavy loads, long-range

---

### HELICOPTER_PILOT (VTOL Specialist)
VTOL specialist for precision operations.

**Stats:**
- Health: 55 HP (+5)
- Speed: 6
- Aim: 7 (+1)
- Reaction: 9 (+1)
- Strength: 5
- Energy: 7 (+1)
- Wisdom: 8 (+2)
- PSI: 0

**Perks:**
- All PILOT perks, plus:
- `precision_control` - Hover bonuses (+25% stability)
- `steady_aim` - Better accuracy while hovering (+10% aim)

**Role**: Transport and precision operations  
**Preferred Craft**: Skyranger, VTOL transports  
**Specialization**: Hover capability, precision insertion

---

## Rank System

### Rank Definitions

```lua
PilotProgression.RANKS = {
    { id = 0, name = "Rookie", xp_required = 0, insignia = "bronze", color = {255, 200, 100} },
    { id = 1, name = "Veteran", xp_required = 100, insignia = "silver", color = {200, 200, 200} },
    { id = 2, name = "Ace", xp_required = 300, insignia = "gold", color = {255, 215, 0} },
}
```

### Rank Progression Table

| Rank | XP Required | XP to Next | Insignia | Color | Bonuses |
|------|-------------|------------|----------|-------|---------|
| **Rookie** | 0 | 100 | Bronze | Gold/Brown | Baseline stats |
| **Veteran** | 100 | 200 | Silver | Gray/White | Speed +1, Aim +2, Reaction +1 |
| **Ace** | 300 | - | Gold | Gold/Yellow | Speed +2, Aim +4, Reaction +2 |

### Rank Bonuses

Stat bonuses applied per rank achieved (cumulative):

```lua
PilotProgression.RANK_BONUSES = {
    speed = 1,      -- +1 per rank
    aim = 2,        -- +2 per rank
    reaction = 1,   -- +1 per rank
}
```

**Application:**
- **Speed +1 per rank**: Better mobility, affects craft dodge
- **Aim +2 per rank**: Improved targeting, affects craft weapons
- **Reaction +1 per rank**: Faster reaction, affects initiative

**Example Progression:**
```
Rookie Pilot (Base Speed 6):
  → Veteran: Speed 7 (6 + 1)
  → Ace: Speed 8 (6 + 2)

Fighter Pilot (Base Aim 8):
  → Veteran: Aim 10 (8 + 2)
  → Ace: Aim 12 (8 + 4)
```

---

## Experience System

### XP Awards

Pilots gain experience exclusively from interception combat:

```lua
-- XP Formula:
xp = math.floor(enemy_total_hp / 10)

-- Example: 100 HP UFO = 10 XP per pilot
-- Shared among all assigned pilots
```

### Mission Recording

```lua
PilotProgression.recordMission(pilotId, victory, kills, damageDealt)
```

**Parameters:**
- `victory` (boolean): Success or failure
- `kills` (number): Enemy units destroyed
- `damageDealt` (number): Total damage (used for XP)

**XP Award:** `floor(damageDealt / 10) XP`

### Rank-Up Process

1. Pilot gains XP during interception combat
2. When XP reaches threshold, automatic rank-up
3. Stats increase by rank bonuses
4. XP resets for next rank
5. Rank insignia updates

---

## Craft Integration

### Pilot Requirements

| Craft Type | Required Pilots | Min Rank | Preferred Classes | Notes |
|------------|-----------------|----------|-------------------|-------|
| **Interceptor** | 1 | Rookie | PILOT, FIGHTER_PILOT | Single-seat |
| **Transport** | 1 | Rookie | PILOT, HELICOPTER_PILOT | General |
| **Scout** | 1 | Rookie | PILOT, FIGHTER_PILOT | Fast recon |
| **Bomber** | 2 | Veteran | BOMBER_PILOT, PILOT | Heavy (2 required) |
| **Sentinel** | 2 | Ace | Any | Heavy escort |

### Craft Bonuses from Pilots

Pilot stats provide percentage bonuses:

```lua
-- Base Formula:
craft_bonus = (pilot_stat / 10) * 100

-- Example: Pilot Speed 8 = +80% dodge
```

**Affected Stats:**
- **dodge**: Based on pilot Speed
- **targeting_accuracy**: Based on pilot Aim
- **initiative**: Based on pilot Reaction

**Multiple Pilots:** Bonuses are averaged

```lua
-- Craft with 2 pilots (Speed 8 and 6):
dodge_bonus = ((8 + 6) / 2) / 10 * 100 = 70%
```

---

## Usage Examples

### Example 1: Creating and Progressing a Pilot

```lua
local PilotProgression = require("basescape.logic.pilot_progression")
local Unit = require("battlescape.combat.unit")

-- Create pilot unit
local pilot = Unit.new("pilot_rookie", "xcom", 0, 0)
print("Created: " .. pilot.name)

-- Initialize progression tracking
PilotProgression.initializePilot(pilot.id, 0)

-- Award XP from interception
local ufo_hp = 150
local xp_gained = math.floor(ufo_hp / 10)
local ranked_up = PilotProgression.gainXP(pilot.id, xp_gained, "UFO destroyed")

if ranked_up then
    print(pilot.name .. " achieved Veteran rank!")
end

-- Check progress
local current_xp = PilotProgression.getXP(pilot.id)
local rank = PilotProgression.getRank(pilot.id)
print(string.format("Rank: %d, XP: %d", rank, current_xp))
```

### Example 2: Assigning Pilot to Craft

```lua
local CraftSystem = require("geoscape.systems.craft_system")
local pilot = getPilot(101)
local craft = CraftSystem.getCraft("skyranger_01")

-- Assign pilot
local success = craft:assignPilot(pilot)
if success then
    print(pilot.name .. " assigned to " .. craft.name)
    
    -- Calculate bonuses
    local bonuses = craft:calculatePilotBonuses()
    print(string.format("Bonuses: Dodge +%d%%, Accuracy +%d%%", 
        bonuses.dodge, bonuses.targeting_accuracy))
end
```

### Example 3: Tracking Pilot Performance

```lua
-- After interception mission
local pilot_id = 101
local mission_won = true
local kills_achieved = 2
local damage_dealt = 200

-- Record mission
PilotProgression.recordMission(pilot_id, mission_won, kills_achieved, damage_dealt)

-- Award XP
local xp = math.floor(damage_dealt / 10)  -- 20 XP
PilotProgression.gainXP(pilot_id, xp, "interception_victory")

-- Get stats
local pilot_data = PilotProgression.pilots[pilot_id]
print(string.format("Missions: %d, Victories: %d, Kills: %d", 
    pilot_data.missions, pilot_data.victories, pilot_data.kills))
```

---

## Integration Guide

### With Units System
Pilots extend the base Unit system with pilot-specific properties. All Unit methods are available for pilots, plus pilot-specific progression methods.

```lua
-- Pilot is a Unit with extra properties
local pilot = Unit.new("pilot_rookie", "xcom")
-- Now has pilot_rank, pilot_xp, pilot_stats, etc.
```

### With Crafts System
Pilots are assigned to crafts and provide stat bonuses to craft performance.

```lua
-- Craft requires pilots
craft.crew = {pilot1, pilot2}  -- For heavy craft
craft.pilot = pilot1  -- For single-pilot craft

-- Bonuses applied during interception
local bonuses = craft:calculatePilotBonuses()
craft.effective_dodge = craft.base_dodge * (1 + bonuses.dodge / 100)
```

### With Interception System
Pilots gain XP only from interception combat, not ground battles.

```lua
-- After interception
if interception.result == "victory" then
    for _, pilot in ipairs(craft.crew) do
        local xp = math.floor(enemy.max_hp / 10)
        PilotProgression.gainXP(pilot.id, xp, "interception_victory")
    end
end
```

---

## Configuration Reference

Complete TOML schema for pilot units:

```toml
[[unit]]
id = "string"                    # Unique pilot ID
name = "string"                  # Display name
description = "string"           # Pilot description
type = "pilot"                   # Must be "pilot"
faction = "string"               # "xcom", etc.
class = "string"                 # "pilot", "fighter_pilot", "bomber_pilot", "helicopter_pilot"
pilot_rank = 0                   # 0-2 (Rookie, Veteran, Ace)
pilot_xp = 0                     # Starting XP

[unit.stats]                     # Base combat stats
health = 50                      # HP
armor = 0                        # Armor value
will = 65                        # Will power
reaction = 80                    # Reaction score
shooting = 60                    # Shooting accuracy
throwing = 40                    # Throwing accuracy
strength = 55                    # Strength
psionic_power = 0                # Psi power (usually 0)
psionic_defense = 45             # Psi defense

[unit.pilot_stats]               # Pilot-specific stats (for craft bonuses)
speed = 6                        # 6-10
aim = 6                          # 6-10
reaction = 8                     # 6-10
strength = 5                     # 5-8
energy = 6                       # 6-10
wisdom = 6                       # 6-10
psi = 0                          # 0-10 (rare)

[unit.equipment]                 # Starting equipment
primary = "pistol"               # Primary weapon
secondary = "none"               # Secondary weapon
armor = "pilot_suit"             # Armor type
grenades = []                    # Grenades

[unit.perks]                     # Pilot perks
default = ["can_move", "can_shoot", "no_morale_penalty"]
```

---

## Best Practices

### ✅ Do This

**1. Initialize pilots properly**
```lua
-- GOOD: Initialize before use
PilotProgression.initializePilot(pilotId, 0)
local xp = PilotProgression.getXP(pilotId)  -- Returns valid value
```

**2. Award XP from interception only**
```lua
-- GOOD: Only from air combat
if mission_type == "interception" then
    PilotProgression.gainXP(pilotId, xp, "UFO destroyed")
end
```

**3. Check craft requirements**
```lua
-- GOOD: Verify pilot count and rank
if craft.required_pilots == 2 and #craft.crew < 2 then
    print("Need 2 pilots for this craft")
    return false
end
```

### ❌ Don't Do This

**1. Don't give XP from ground combat**
```lua
-- BAD: Pilots don't gain XP on ground
if mission_type == "tactical" then
    PilotProgression.gainXP(pilotId, xp)  -- NO!
end
```

**2. Don't skip initialization**
```lua
-- BAD: Will return 0 or nil
local xp = PilotProgression.getXP(uninitialized_pilot_id)
```

**3. Don't ignore rank requirements**
```lua
-- BAD: Heavy craft needs experienced pilots
craft:assignPilot(rookie_pilot)  -- May fail for heavy craft
```

---

## Related Documentation

- **[UNITS.md](UNITS.md)** - Base unit system
- **[CRAFTS.md](CRAFTS.md)** - Craft management
- **[INTERCEPTION.md](INTERCEPTION.md)** - Air combat
- **[Design: Units](../design/mechanics/Units.md)** - Unit design philosophy
- **[Engine: pilot_progression.lua](../engine/basescape/logic/pilot_progression.lua)** - Implementation

---

**End of Pilots API Reference**

