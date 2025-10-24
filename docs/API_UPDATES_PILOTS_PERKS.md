# API Updates - Pilots & Perks

## UNITS.md Additions

Add to end of file:

```markdown
---

## 🆕 Pilot Class System

### Pilot Entity

Specialized unit class for aircraft operators with progression.

**Properties:**
```lua
Pilot = {
  pilot_rank = 0,           -- 0=Rookie, 1=Veteran, 2=Ace
  pilot_xp = 50,           -- XP in current rank (0-300)
  pilot_stats = {
    speed = 6,             -- Craft speed bonus
    aim = 6,               -- Craft accuracy bonus
    reaction = 8,          -- Craft evasion bonus
    strength = 5,          -- Weapon damage bonus
    energy = 6,            -- Energy pool bonus
    wisdom = 6,            -- Sensor range bonus
    psi = 4,               -- Psi defense bonus
  },
  kills = 0,
  missions_flown = 0,
  victories = 0,
}
```

### Rank Progression

| Rank | Name | XP | Bonuses |
|------|------|---|---------|
| 0 | Rookie | 0 | None |
| 1 | Veteran | 100 | SPEED +1, AIM +2, REACTION +1 |
| 2 | Ace | 300 | SPEED +2, AIM +4, REACTION +2 |

### XP Gain
- Only from interception combat
- Formula: `XP = Enemy Total HP / 10`
- Example: 100 HP enemy = 10 XP

### Craft Bonuses
Pilot stats map directly to craft performance:

| Pilot Stat | Craft Stat | Formula | Max |
|---|---|---|---|
| SPEED | speed | (stat-5)×1% | 30% |
| AIM | accuracy | (stat-5)×1% | 25% |
| REACTION | evasion | (stat-5)×1% | 25% |
| STRENGTH | damage | (stat-5)×0.5% | 20% |
| ENERGY | energy | (stat-5)×2% | 25% |
| WISDOM | sensors | (stat-5)×5% | 30% |
| PSI | psi_def | (stat-5)×0.5% | 15% |

### Functions
```lua
PilotProgression.gainXP(pilotId, xp, source) → boolean (rankup?)
PilotProgression.getRank(pilotId) → number (0-2)
PilotProgression.getXP(pilotId) → number
CraftPilotSystem.calculateBonuses(pilots) → table
CraftPilotSystem.applyBonuses(craft, bonuses) → void
```

---

## 🆕 Perks System

### Perk Entity

Boolean trait flags (40+ perks, 9 categories).

```lua
Perk = {
  id = "can_move",
  name = "Can Move",
  description = "Unit can move",
  category = "basic",
  enabled_by_default = true,
}
```

### All 40+ Perks by Category

**BASIC (6):** can_move, can_run, can_shoot, can_melee, can_throw, can_climb
**MOVEMENT (6):** can_swim, can_fly, high_jump, hover, terrain_immunity, swimming_speed
**COMBAT (6):** two_weapon_proficiency, can_use_psionic, can_fire_heavy, quickdraw, ambidextrous, sniper_focus
**SENSES (5):** darkvision, thermal_vision, x_ray_vision, keen_eyes, danger_sense
**DEFENSE (8):** regeneration, poison_immunity, fire_immunity, fear_immunity, shock_immunity, hardened, shield_user, damage_reflection
**SURVIVAL (5):** no_morale_penalty, iron_will, evasion, thick_skin, adrenaline_rush
**SOCIAL (3):** leadership, inspire, mentor
**SPECIAL (5):** stealth, camouflage, self_destruct, mind_control, shapeshift
**FLIGHT (5):** skilled_pilot, precision_landing, aerobatic_maneuvers, fuel_efficiency, weapon_specialist

### Functions
```lua
PerkSystem.hasPerk(unitId, perkId) → boolean
PerkSystem.enablePerk(unitId, perkId) → boolean
PerkSystem.disablePerk(unitId, perkId) → void
PerkSystem.togglePerk(unitId, perkId) → boolean (new state)
PerkSystem.getActivePerks(unitId) → table
PerkSystem.getPerk(perkId) → table (definition)
PerkSystem.loadFromTOML(data) → number (count)
```

### Dual-Wield Mechanic

**Perk:** `two_weapon_proficiency`

**Requirements:**
- Unit has perk enabled
- 2 identical weapons equipped

**Mechanics:**
- Cost: 1 AP (same as single shot)
- Energy: Both weapons' energy (doubled)
- Accuracy: -10% penalty
- Damage: Sum of both weapons
- Display: "Dual Fire" action

**Formula:**
```lua
Accuracy = Base × 0.9
Damage = (W1_Damage + W2_Damage) × Accuracy
Energy = W1_Energy + W2_Energy
```

---

## CRAFTS.md Additions

Add to end of file:

```markdown
---

## 🆕 Pilot Requirements

Each craft specifies pilot requirements:

```lua
Craft = {
  pilots = {
    required = 2,                -- Number of pilots (1-6)
    classes = ["pilot"],         -- Allowed pilot classes
    min_level = 0,              -- Minimum rank (0-2)
    require_officer = false,    -- Officer required (large craft)
  },
}
```

### Examples

**Skyranger Transport**
```toml
[craft.pilots]
required = 2
classes = ["pilot", "bomber_pilot"]
min_level = 0
```

**Interceptor Fighter**
```toml
[craft.pilots]
required = 1
classes = ["fighter_pilot"]
min_level = 1
```

**Gunship Heavy Transport**
```toml
[craft.pilots]
required = 2
classes = ["pilot", "bomber_pilot"]
min_level = 1
require_officer = true
```

---

## 🆕 Capacity Distribution

Three-tier capacity system:

```lua
Craft = {
  capacity = {
    pilots = 2,      -- PILOT slots (actual pilots)
    crew = 8,        -- CREW slots (combat troops)
    cargo = 50,      -- CARGO kg (equipment/items)
  },
}
```

### Meanings
- **PILOT slots**: Units acting as pilots (separate from crew)
- **CREW slots**: Units acting as combat personnel
- **CARGO**: Items, weapons, equipment

### Example
- Skyranger: 2 pilots + 8 crew + 50 kg cargo
- Fighter: 1 pilot + 0 crew + 5 kg cargo
- Gunship: 2 pilots + 12 crew + 25 kg cargo

---

## Pilot Bonus System

### Calculation

```lua
CraftPilotSystem.calculateBonuses(pilotsList) → table
```

**For each pilot:**
1. Calculate individual bonuses
2. Stack bonuses from all pilots
3. Apply diminishing returns (50% after first pilot)
4. Cap at per-stat maximums

**Result:**
```lua
{
  speed = 3.5,
  accuracy = 2.5,
  evasion = 1.8,
  damage = 1.2,
  energy = 2.5,
  sensors = 4.5,
  psi_def = 0.8,
}
```

### Display
Show as green text (+) in UI:
- Speed: +3.5%
- Accuracy: +2.5%
- Evasion: +1.8%
- etc.

---

**Updated:** October 23, 2025
```
