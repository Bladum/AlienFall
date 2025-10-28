# Units & Personnel API Reference

**System:** Tactical / Personnel Management  
**Module:** `engine/battlescape/units/`, `engine/basescape/personnel/`  
**Latest Update:** October 22, 2025  
**Status:** ✅ Complete

---

## Overview

The Units system manages individual soldiers, operatives, and alien entities with persistent identity, experience progression, class-based specialization, and equipment customization. Units are core tactical assets that develop through combat, specialize into roles, gain traits, and form the foundation of squad-based gameplay. The system emphasizes player attachment through individual unit development, meaningful progression, and customizable loadouts.

**Layer Classification:** Tactical / Personnel Management  
**Primary Responsibility:** Unit stats, progression, equipment, abilities, morale, squad management, class specialization  
**Integration Points:** Battlescape (combat), Basescape (recruitment/storage), Equipment (loadouts), Experience tracking

---

## Core Entities

### Entity: Unit

Individual combat operative with persistent identity and progression.

**Properties:**
```lua
Unit = {
  id = string,                    -- "unit_001_soldier"
  name = string,                  -- Custom name given by player
  type = string,                  -- "human", "alien", "mechanical"
  
  -- Progression
  rank = number,                  -- 0-6 (experience level)
  experience = number,            -- Current XP towards next rank
  level = number,                 -- Derived from XP
  specialization = string,        -- "rifleman", "medic", "assault"
  class = UnitClass,              -- Class archetype
  
  -- Base Statistics (6-12 range, can exceed with equipment/skills)
  strength = number,              -- Melee damage, carry capacity
  dexterity = number,             -- Accuracy, initiative
  constitution = number,          -- Health, endurance
  intelligence = number,          -- Hack/tech ability
  perception = number,            -- Detection range, accuracy
  will = number,                  -- Morale resistance, psi defense
  
  -- Psychological Stats (6-12 range for humans, 0-20 for psi)
  bravery = number,               -- Morale buffer, panic resistance (6-12)
  sanity = number,                -- Psychological stability (6-12)
  melee = number,                 -- Melee combat effectiveness (6-12)
  psi = number,                   -- Psionic power (0-20, 0 = no psi)
  
  -- Piloting Properties (NEW - for pilot role)
  piloting = number,              -- 6-12 (craft operation skill)
  assigned_craft_id = string | nil,  -- Craft ID if assigned as pilot
  pilot_role = string | nil,      -- "pilot", "co-pilot", "crew", nil
  pilot_xp = number,              -- XP from interception (separate from ground XP)
  pilot_rank = number,            -- 0-5 (pilot-specific rank)
  pilot_fatigue = number,         -- 0-100 (affects craft performance)
  total_interceptions = number,   -- Total interception missions
  craft_kills = number,           -- Enemy crafts destroyed
  
  -- Effective Stats (with equipment bonuses)
  stats = {
    accuracy = number,            -- 0-100
    strength = number,            -- 0-20
    reaction = number,            -- Initiative
    fire_rate = number,           -- Attacks per turn
  },
  
  -- Combat Stats
  health = number,                -- Current HP
  max_health = number,            -- Full health (from class + equipment)
  hp_current = number,            -- Alias for health
  hp_max = number,                -- Alias for max_health
  action_points = number,         -- AP per turn (usually 4)
  
  -- Energy System
  energy = number,                -- Current energy points
  maxEnergy = number,             -- Maximum energy points
  energy_regen_rate = number,     -- Energy regeneration per turn (default: 5)
  
  -- Psionic Energy (for units with psi > 0)
  psiEnergy = number,             -- Current psi energy (0-100)
  maxPsiEnergy = number,          -- Maximum psi energy (100 standard)
  psiEnergyRegen = number,        -- Psi energy regen per turn (default: 5)
  
  -- Movement System
  movementPoints = number,        -- Total movement points per turn (derived from AP × speed)
  movementPointsLeft = number,    -- Remaining movement this turn
  
  -- Weapon Management
  weapon_cooldowns = table,       -- {weaponId = turns_remaining}
  
  -- Equipment
  equipped_items = EquipmentSlot[],
  weapon_equipped = Item | nil,
  armor_equipped = Item | nil,
  inventory = ItemStack[],
  
  -- Status
  status = string,                -- "active", "healthy", "wounded", "critical", "unconscious", "dead"
  status_effects = string[],      -- "bleeding", "stunned", "panicked"
  morale = number,                -- 0-100
  fatigue = number,               -- 0-100
  
  -- Traits
  traits = string[],              -- "smart", "brave", "weak"
  
  -- Assignment
  assigned_base = string | nil,   -- Base ID if stationed
  current_squad = string | nil,   -- Squad ID if in battle
  
  -- Skills & Abilities
  skills = Skill[],               -- Learned abilities
  
  -- History
  recruitment_turn = number,
  rank_up_turns = number[],       -- When each rank achieved
  kills = number,
  missions_completed = number,
  enemies_killed = number,
  times_wounded = number,
  
  -- Current Mission
  battle_stats = table | nil,     -- Only during active battle
}
```

**Functions:**
```lua
-- Lifecycle
Unit.createUnit(type: string, name: string, rank: number) → Unit
Unit.getUnit(unit_id: string) → Unit | nil
Unit.killUnit(unit: Unit) → void

-- Status queries
unit:getName() → string
unit:getClass() → UnitClass
unit:getRank() → number
unit:getLevel() → number
unit:getStatus() → string
unit:isAlive() → bool
unit:isWounded() → bool

-- Stats
unit:getStat(stat_name: string) → number  -- Base stat with equipment bonuses
unit:updateStats() → void  -- Recalculate all stats from equipment/modifiers
unit:getHealth() → number
unit:getMaxHealth() → number
unit:getHPPercent() → number  -- 0-100 percentage
unit:getActionPoints() → number
unit:getAccuracy() → number
unit:getStrength() → number
unit:getReaction() → number
unit:getFireRate() → number
unit:getEffectiveStats() → table  -- With equipment bonuses
unit:getCarryWeight() → number

-- Psychological Stats (6-12 range for humans, 0-20 for psi)
unit:getBravery() → number  -- Morale buffer stat (6-12)
unit:getSanity() → number  -- Psychological stability (6-12)
unit:getMelee() → number  -- Melee effectiveness (6-12)
unit:getPsi() → number  -- Psionic power (0-20, 0 = no psi ability)

-- Psionic Energy (for units with psi > 0)
unit:getPsiEnergy() → number  -- Current psi energy (0-100)
unit:getMaxPsiEnergy() → number  -- Maximum psi energy (100 for psionic units)
unit:getPsiEnergyPercent() → number  -- 0-100 percentage
unit:usePsiEnergy(amount: number) → boolean  -- Spend psi energy
unit:regeneratePsiEnergy() → void  -- Called per turn (+5 per turn)
unit:hasPsiAbility() → boolean  -- Check if unit has psi > 0

-- Equipment
unit:equip(slot: string, item: ItemStack) → boolean
unit:equipWeapon(item: ItemStack) → boolean
unit:equipArmor(item: ItemStack) → boolean
unit:unequip(slot: string) → ItemStack | nil
unit:getEquippedWeapon() → ItemStack | nil
unit:getEquippedArmor() → ItemStack | nil
unit:getInventory() → ItemStack[]
unit:addItem(item: ItemStack) → boolean
unit:removeItem(itemId: string) → boolean
unit:getAvailableSlots() → number

-- Combat
unit:takeDamage(damage: number) → void
unit:heal(amount: number) → void
unit:revive(health: number) → void
unit:applyStatusEffect(effect: string, duration: number) → void
unit:removeStatusEffect(effect: string) → void
unit:getStatusEffects() → string[]
unit:hasStatusEffect(effectName: string) → bool

-- Movement System
unit:calculateMP() → number  -- Calculate movement points from AP and speed
unit:spendMP(amount: number) → void  -- Spend movement points
unit:getMovementPoints() → number  -- Remaining movement this turn
unit:canMove() → boolean  -- Check if unit has movement left

-- Weapon Cooldowns
unit:getWeaponCooldown(weaponId: string) → number  -- Turns remaining
unit:setWeaponCooldown(weaponId: string, turns: number) → void
unit:updateWeaponCooldowns() → void  -- Called per turn
unit:isWeaponReady(weaponId: string) → boolean  -- Check if weapon can fire

-- Energy System
unit:getEnergy() → number  -- Current energy points
unit:getMaxEnergy() → number  -- Maximum energy
unit:getEnergyPercent() → number  -- 0-100 percentage
unit:spendEnergy(amount: number) → boolean  -- Use energy for actions
unit:regenerateEnergy() → void  -- Called per turn (+energy_regen_rate)

-- Morale
unit:getMorale() → number
unit:setMorale(level: number) → void
unit:modifyMorale(delta: number, reason: string) → void
unit:applyMoraleEffect(effect: string, amount: number) → void
unit:panic() → void (morale < 0)

-- Fatigue
unit:getFatigue() → number
unit:addFatigue(amount: number) → void
unit:restFatigue(amount: number) → void

-- Progression
unit:gainExperience(amount: number) → void
unit:gainXP(amount: number) → void
unit:getTotalXP() → number
unit:getXPForNextLevel() → number
unit:getProgressToNextLevel() → number  -- 0-100
unit:canPromote() → boolean
unit:promote(specialization: string) → void

-- Skills & Abilities
unit:getSkills() → Skill[]
unit:hasSkill(skillId: string) → bool
unit:learnSkill(skillId: string) → bool
unit:forgetSkill(skillId: string) → bool
unit:getAvailableAbilities() → string[]

-- Statistics
unit:getStats() → {missions, kills, wounded}
unit:recordKill(target: string) → void
unit:recordMission() → void
unit:recordWound() → void

-- Pilot Functions (NEW)
unit:getPilotingStat() → number  -- Get piloting skill (6-12+)
unit:canOperateCraft(craftType: string) → boolean  -- Check if unit can pilot craft type
unit:getAssignedCraft() → string | nil  -- Get craft ID if assigned
unit:getPilotRole() → string | nil  -- Get "pilot", "co-pilot", "crew", or nil
unit:isAssignedAsPilot() → boolean  -- Check if currently assigned to craft
unit:getPilotXP() → number  -- Get pilot experience (separate from ground XP)
unit:getPilotRank() → number  -- Get pilot rank (0-5)
unit:getPilotFatigue() → number  -- Get pilot fatigue (0-100)
unit:getTotalInterceptions() → number  -- Total interception missions
unit:getCraftKills() → number  -- Enemy crafts destroyed
unit:gainPilotXP(amount: number, source: string) → boolean  -- Award pilot XP
unit:promotePilot() → boolean  -- Promote pilot rank if XP threshold met
unit:addPilotFatigue(amount: number) → void  -- Increase fatigue
unit:restPilot(amount: number) → void  -- Decrease fatigue
unit:calculatePilotBonuses() → table  -- Calculate stat bonuses for craft
```

**Pilot Bonus Calculation:**
```lua
-- Returns craft bonus table based on pilot stats and fatigue
unit:calculatePilotBonuses() → {
  speed_bonus = number,      -- % bonus to craft speed
  accuracy_bonus = number,   -- % bonus to craft accuracy
  dodge_bonus = number,      -- % bonus to craft dodge
  fuel_efficiency = number,  -- % fuel efficiency
  initiative_bonus = number, -- Initiative from dexterity
  sensor_bonus = number,     -- Sensor range from perception
}

-- Example calculation:
local pilot = Units.getUnit("unit_001")
local bonuses = pilot:calculatePilotBonuses()
-- If pilot has Piloting 10, Dexterity 9, Perception 8, Fatigue 30:
-- bonuses = {
--   speed_bonus = 5.6,      -- (10-6)*2% * (1-30/200) = 8% * 0.85
--   accuracy_bonus = 8.4,   -- (10-6)*3% * 0.85
--   dodge_bonus = 5.6,      -- (10-6)*2% * 0.85
--   fuel_efficiency = 2.8,  -- (10-6)*1% * 0.85
--   initiative_bonus = 4,   -- 9/2 rounded
--   sensor_bonus = 4,       -- 8/2 rounded
-- }
```

---

### Entity: Squad

Group of units deployed together with coordination capabilities.

**Properties:**
```lua
Squad = {
  id = string,                    -- "squad_001"
  name = string,                  -- "Alpha Squad"
  units = Unit[],                 -- Members
  
  -- Composition
  size = number,                  -- Current unit count
  max_size = number,              -- Squad capacity
  
  -- State
  status = string,                -- "ready", "in_mission", "recovering"
  morale = number,                -- Average team morale (affects behavior)
  cohesion = number,              -- 0-100
  formation = string,             -- "wedge", "line", "circle"
  
  -- Statistics
  total_kills = number,
  total_missions = number,
  average_rank = number,
}
```

**Functions:**
```lua
-- Squad management
Squad.createSquad(name: string, max_size: number) → Squad
Squad.addUnit(squad: Squad, unit: Unit) → boolean
Squad.removeUnit(squad: Squad, unit: Unit) → void
Squad.getUnits(squad: Squad) → Unit[]

-- Status
squad:getAverageRank() → number
squad:getSquadMorale() → number
squad:isReadyForMission() → boolean
squad:getComposition() → table (role breakdown)
squad:getCohesion() → number
squad:setFormation(formation: string) → void
squad:getFormation() → string
```

---

### Entity: UnitClass

Template defining unit specialization, base stats, and progression.

**Properties:**
```lua
UnitClass = {
  id = string,                    -- "class_rifleman", "assault"
  name = string,                  -- "Rifleman", "Assault"
  description = string,           -- Class description
  
  -- Base Stats
  base_rank = number,             -- Starting rank
  hp_base = number,               -- Base HP
  accuracy_base = number,         -- 0-100
  strength_base = number,         -- 0-20
  reaction_base = number,         -- Initiative
  fire_rate_base = number,        -- Attacks per turn
  armor_class = number,           -- 0-50 (damage reduction %)
  
  -- Stat Bonuses
  stat_bonuses = table,           -- {stat: bonus}
  
  -- Equipment
  starting_weapon = string,       -- Item ID
  starting_armor = string,
  weapon_types_preferred = string[],
  weapon_proficiencies = string[],
  armor_proficiencies = string[],
  
  -- Abilities
  abilities = string[],           -- Unique abilities
  class_abilities = Skill[],      -- Available skills
  ability_unlock_rank = table,    -- {ability_id: unlock_rank}
  
  -- Progression
  promotes_to = string[],         -- Available specializations
  requires_trait = string | nil,  -- Trait requirement
  xp_to_level_up = number,        -- XP per level
  promotion_requirement = number, -- Minimum XP for rank up
}
```

---

### Entity: Trait

Unit characteristic affecting capabilities and roleplay.

**Properties:**
```lua
Trait = {
  id = string,                    -- "smart", "brave", "weak"
  name = string,                  -- "Smart", "Brave"
  description = string,           -- Effect description
  
  -- Effects
  stat_modifiers = table,         -- {stat: multiplier}
  ability_bonus = string[],       -- Bonus abilities
  weakness = string,              -- Paired weakness
  
  -- Gameplay
  is_positive = boolean,
  is_negative = boolean,
  is_neutral = boolean,
}
```

---

### Entity: Skill

Learned ability that unit can use in combat.

**Properties:**
```lua
Skill = {
  id = string,                    -- "critical_shot", "first_aid"
  name = string,
  description = string,
  
  -- Requirements
  required_class = string | nil,  -- Exclusive to class?
  required_rank = number,         -- Minimum rank to unlock
  required_xp = number,           -- Minimum XP
  
  -- Mechanics
  effect = string,                -- Combat effect
  ap_cost = number,               -- Action point cost
  cooldown = number,              -- Turns before can use again
  
  -- Stats
  accuracy_bonus = number,
  damage_bonus = number,
  range_bonus = number,
}
```

---

## Services & Functions

### Unit Management Service

```lua
-- Creation and retrieval
UnitManager.createUnit(type: string, name: string, rank: number) → Unit
UnitManager.getUnit(unit_id: string) → Unit | nil
UnitManager.getUnits() → Unit[]
UnitManager.getUnitsBySquad(squad_id: string) → Unit[]
UnitManager.getUnitsByBase(base_id: string) → Unit[]
UnitManager.getUnitsByClass(classId: string) → Unit[]
UnitManager.getAllUnits() → Unit[]

-- Status queries
UnitManager.getHealthyUnits() → Unit[]
UnitManager.getWoundedUnits() → Unit[]
UnitManager.getDeadUnits() → Unit[]
UnitManager.getAvailableUnits() → Unit[] (not in mission)

-- Recruitment
UnitManager.recruitUnit(type: string, rank: number) → Unit | nil (success if affordable)
UnitManager.dismissUnit(unit: Unit) → void
UnitSystem.createUnit(classId: string, name: string) → Unit
```

### Squad Management Service

```lua
-- Squad lifecycle
SquadManager.createSquad(name: string) → Squad
SquadManager.getSquad(squad_id: string) → Squad | nil
SquadManager.getSquads() → Squad[]

-- Unit assignment
SquadManager.addUnitToSquad(unit: Unit, squad: Squad) → boolean
SquadManager.removeUnitFromSquad(unit: Unit) → void

-- Status
SquadManager.getSquadStats(squad: Squad) → table (composition, ranks, kills)
SquadManager.isSquadDeployed(squad_id: string) → boolean
```

### Unit Progression Service

```lua
-- Experience and leveling
ProgressionService.addExperience(unit: Unit, amount: number) → void
ProgressionService.processRankUp(unit: Unit) → boolean
ProgressionService.promoteUnit(unit: Unit, specialization: string) → void

-- Abilities
ProgressionService.getAvailableAbilities(unit: Unit) → string[]
ProgressionService.learnAbility(unit: Unit, ability_id: string) → void
ProgressionService.forgetAbility(unit: Unit, ability_id: string) → void

-- Specialization
ProgressionService.getAvailableSpecializations(unit: Unit) → string[]
ProgressionService.canSpecialize(unit: Unit, spec: string) → boolean
```

### Unit Combat Service

```lua
-- Health and damage
UnitCombat.damageUnit(unit: Unit, damage: number) → number (actual damage)
UnitCombat.healUnit(unit: Unit, amount: number) → void
UnitCombat.reviveUnit(unit: Unit, health: number) → void

-- Status effects
UnitCombat.applyStatus(unit: Unit, effect: string, turns: number) → void
UnitCombat.removeStatus(unit: Unit, effect: string) → void
UnitCombat.getStatusEffects(unit: Unit) → string[]

-- Morale
UnitCombat.setMorale(unit: Unit, level: number) → void
UnitCombat.modifyMorale(unit: Unit, delta: number, reason: string) → void
UnitCombat.panic(unit: Unit) → void (morale < 0)
```

### Trait Service

```lua
-- Trait queries
TraitService.getTrait(trait_id: string) → Trait | nil
TraitService.getTraits() → Trait[]
TraitService.getPositiveTraits() → Trait[]
TraitService.getNegativeTraits() → Trait[]

-- Unit traits
TraitService.giveUnitTrait(unit: Unit, trait_id: string) → void
```

---

## Configuration (TOML)

### Unit Classes

```toml
# basescape/units/classes.toml

[[classes]]
id = "rifleman"
name = "Rifleman"
description = "Versatile soldier with balanced stats"
hp_base = 65
accuracy_base = 70
strength_base = 10
reaction_base = 70
fire_rate_base = 0.9
armor_class = 8
starting_weapon = "rifle"
starting_armor = "light_armor"
weapon_types_preferred = ["rifle", "laser_rifle"]
xp_to_level_up = 100
promotion_requirement = 500

[[classes]]
id = "assault"
name = "Assault"
description = "Heavy weapons and close combat specialist"
hp_base = 70
accuracy_base = 60
strength_base = 12
reaction_base = 65
fire_rate_base = 1.0
armor_class = 10
starting_weapon = "rifle"
starting_armor = "light_armor"
weapon_types_preferred = ["rifle", "shotgun", "flamer"]
xp_to_level_up = 100
promotion_requirement = 500

[[classes]]
id = "sniper"
name = "Sniper"
description = "Precision marksman with high accuracy"
hp_base = 50
accuracy_base = 85
strength_base = 8
reaction_base = 70
fire_rate_base = 0.7
armor_class = 5
starting_weapon = "sniper_rifle"
starting_armor = "light_armor"
weapon_types_preferred = ["sniper_rifle", "laser_rifle"]
xp_to_level_up = 100
promotion_requirement = 500

[[classes]]
id = "medic"
name = "Medic"
description = "Support specialist with healing abilities"
hp_base = 60
accuracy_base = 65
strength_base = 8
reaction_base = 75
fire_rate_base = 0.8
armor_class = 8
starting_weapon = "pistol"
starting_armor = "light_armor"
weapon_types_preferred = ["pistol", "rifle"]
xp_to_level_up = 100
promotion_requirement = 500
healing_capacity = 3

[[classes]]
id = "heavy"
name = "Heavy"
description = "Tanky support with minigun"
hp_base = 90
accuracy_base = 50
strength_base = 15
reaction_base = 50
fire_rate_base = 1.2
armor_class = 20
starting_weapon = "minigun"
starting_armor = "heavy_armor"
weapon_types_preferred = ["minigun", "rocket_launcher"]
xp_to_level_up = 100
promotion_requirement = 500
```

### Traits Configuration

```toml
# basescape/units/traits.toml

[[traits]]
id = "smart"
name = "Smart"
description = "Increased intelligence and hacking ability"
is_positive = true
stat_modifiers = {intelligence = 1.2}

[[traits]]
id = "brave"
name = "Brave"
description = "Improved morale and panic resistance"
is_positive = true
stat_modifiers = {will = 1.15}
ability_bonus = ["iron_will"]

[[traits]]
id = "weak"
name = "Weak"
description = "Reduced carrying capacity and melee damage"
is_negative = true
stat_modifiers = {strength = 0.8}
weakness = "brave"
```

---

## Pilots & Perks

### Pilot System (Aircraft Operators)

Pilots are specialized units that operate aircraft in interception combat. They have simplified progression compared to ground troops, gaining experience only from interception victories.

**Pilot Entity:**
```lua
Pilot = {
  id = string,                    -- "pilot_001"
  name = string,                  -- Pilot name
  type = string,                  -- "pilot"
  class = string,                 -- "pilot", "fighter_pilot", "bomber_pilot", "helicopter_pilot"
  
  -- Pilot-Specific Progression
  rank = number,                  -- 0 (Rookie), 1 (Veteran), 2 (Ace)
  current_rank = number,          -- Current rank ID
  current_xp = number,            -- XP in current rank
  total_xp_earned = number,       -- Total XP across all ranks
  
  -- Base Stats (Aviation Focused)
  speed = number,                 -- Reaction time (default 8)
  aim = number,                   -- Shooting accuracy (default 7)
  reaction = number,              -- Response time (default 8)
  strength = number,              -- Physical endurance (default 5)
  energy = number,                -- Mental focus (default 7)
  wisdom = number,                -- Tactical awareness (default 6)
  psi = number,                   -- Psionic resistance (default 4)
  
  -- Pilot-Specific Data
  missions = number,              -- Interception missions participated in
  kills = number,                 -- Enemy craft destroyed
  victories = number,             -- Interception victories
  defeats = number,               -- Defeats/withdrawals
  created_at = number,            -- Unix timestamp of recruitment
  last_mission = number | nil,    -- Last mission date
  
  -- Craft Assignment
  assigned_craft = string | nil,  -- Craft ID if assigned
}
```

**Pilot Functions:**
```lua
-- Progression (from PilotProgression module)
PilotProgression.initializePilot(pilotId: number, initialRank: number) → void
PilotProgression.gainXP(pilotId: number, xpAmount: number, source: string) → bool (returns true if ranked up)
PilotProgression.getRank(pilotId: number) → number
PilotProgression.getXP(pilotId: number) → number
PilotProgression.getTotalXP(pilotId: number) → number
PilotProgression.getRankDef(rankId: number) → table {name, xp_required, insignia, color}
PilotProgression.getRankInsignia(pilotId: number) → table {name, type, color}
PilotProgression.getXPProgress(pilotId: number) → number (0-100%)
PilotProgression.getPilotStats(pilotId: number) → table (with bonuses from rank-ups)
```

**Pilot Ranks:**
```
Rank 0: Rookie (0 XP)
  - Starting rank
  - Base stats
  - Bonuses: +0

Rank 1: Veteran (100 XP)
  - Insignia: Silver
  - Bonuses: +1 SPEED, +2 AIM, +1 REACTION

Rank 2: Ace (300 XP total)
  - Insignia: Gold
  - Bonuses: +1 SPEED, +2 AIM, +1 REACTION (cumulative from Veteran)
  - Total bonuses: +2 SPEED, +4 AIM, +2 REACTION
```

**Pilot Bonuses to Craft:**
```lua
-- Stat transfer formula
bonus_percent = (pilot_stat - 5) / 100

-- Applied to craft:
craft.speed = craft.baseSpeed * (1 + bonus_percent)
craft.accuracy = craft.baseAccuracy * (1 + bonus_percent)
craft.damage = craft.baseDamage * (1 + bonus_percent_strength)
craft.energy = craft.baseEnergy * (1 + bonus_percent_energy)
craft.dodge = craft.baseDodge * (1 + bonus_percent_reaction)
craft.radar_range = craft.baseRadar + (bonus_percent_wisdom * 5)
craft.psi_defense = craft.basePsiDef * (1 + bonus_percent_psi)

-- Multiple pilots stack additively
-- Example: 2 Ace pilots with SPEED 10 = 5% + 5% = 10% bonus
```

**Pilot Classes (Configuration):**
```toml
# mods/core/rules/unit/classes.toml

[[unit_class]]
id = "pilot"
name = "Pilot"
description = "Aircraft pilot operator"
unit_type = "pilot"
stats.speed = 8
stats.aim = 7
stats.reaction = 8
stats.strength = 5
stats.energy = 7
stats.wisdom = 6
stats.psi = 4
stats.hp = 30

[[unit_class]]
id = "fighter_pilot"
name = "Fighter Pilot"
description = "Aggressive interceptor specialist"
unit_type = "pilot"
stats.speed = 9
stats.aim = 8
stats.reaction = 9
specialty = "fighter"

[[unit_class]]
id = "bomber_pilot"
name = "Bomber Pilot"
description = "Heavy strike aircraft operator"
unit_type = "pilot"
stats.strength = 7
stats.energy = 9
stats.speed = 7
specialty = "bomber"
```

### Perks System (Unit Traits)

Perks are boolean flags that provide unit customization through special abilities, bonuses, and resistances. Each unit can have multiple active perks that affect combat, movement, and special mechanics.

**Perk Entity:**
```lua
Perk = {
  id = string,                    -- "two_weapon_proficiency"
  name = string,                  -- "Dual Wield"
  description = string,           -- "Can wield two weapons simultaneously"
  category = string,              -- "basic", "combat", "movement", "defense", "special", "resistance", "skill", "trait"
  enabled = bool,                 -- true if registered
  
  -- Optional modifiers
  accuracy_bonus = number | nil,  -- +/-% accuracy
  accuracy_penalty = number | nil,
  damage_bonus = number | nil,    -- +/-% damage
  damage_reduction = number | nil, -- -% damage received
  ap_bonus = number | nil,        -- +/- action points
  movement_bonus = number | nil,  -- +/-% movement speed
}
```

**Perk Functions:**
```lua
-- Core operations (from PerkSystem module)
PerkSystem.register(id: string, name: string, description: string, category: string, enabled: bool) → void
PerkSystem.hasPerk(unitId: number, perkId: string) → bool
PerkSystem.enablePerk(unitId: number, perkId: string) → void
PerkSystem.disablePerk(unitId: number, perkId: string) → void
PerkSystem.togglePerk(unitId: number, perkId: string) → void
PerkSystem.getActivePerks(unitId: number) → string[] (list of perk IDs)
PerkSystem.getPerk(perkId: string) → Perk | nil
PerkSystem.getByCategory(category: string) → Perk[]

-- Initialization
PerkSystem.initializeUnitPerks(unitId: number, defaultPerks: string[]) → void

-- TOML Loading
PerkSystem.loadFromTOML(tomlData: table) → void (loads perks from mod config)
```

**Perk Categories:**

| Category | Purpose | Examples |
|----------|---------|----------|
| **basic** | Foundation traits | pilot_basic, soldier_basic, alien_basic |
| **combat** | Offensive/defensive abilities | two_weapon_proficiency, deadeye, bloodlust, cover_training |
| **movement** | Mobility & traversal | sprint, light_step, acrobatics, regeneration |
| **defense** | Protection & survivability | iron_skin, dodge_training, thick_armor, psi_shield |
| **special** | Unique mechanics | hive_mind, frenzy, stealth_field, time_dilation |
| **resistance** | Immunities & resistances | fire_immunity, poison_immunity, psi_resistance |
| **skill** | Professional training | medical_training, engineering, leadership, hacking |
| **trait** | Personal characteristics | lucky, tough, quick_reflexes, keen_eye, brave |

**Common Perks:**
```lua
-- Combat
"two_weapon_proficiency"        -- Dual wield (+accuracy penalty: -15%)
"deadeye"                       -- +20% accuracy
"bloodlust"                     -- +15% damage per kill (2 turn duration)
"cover_training"                -- +25% cover effectiveness

-- Movement
"sprint"                        -- +30% movement speed (+1 AP cost)
"light_step"                    -- -50% sound generation (stealth)
"acrobatics"                    -- Rough terrain no penalty

-- Defense
"iron_skin"                     -- -15% damage received
"dodge_training"                -- +25% dodge chance
"psi_shield"                    -- +30% psi defense

-- Special
"hive_mind"                     -- +30% accuracy near other hive units
"stealth_field"                 -- Invisible until first action
"time_dilation"                 -- +2 AP per turn (-25% accuracy)

-- Skill
"medical_training"              -- Medkit +100% effective
"engineering"                   -- Repair/build in 1 action
"leadership"                    -- Allies +10% accuracy within 6 hex

-- Trait
"lucky"                         -- +15% crit chance
"brave"                         -- Morale stable, panic -50%
"keen_eye"                      -- +30% detection range
```

**Perk Configuration (TOML):**
```toml
# mods/core/rules/unit/perks.toml

[[perk]]
id = "pilot_basic"
name = "Pilot Training"
description = "Pilot training and aircraft operation"
category = "basic"
enabled = true

[[perk]]
id = "two_weapon_proficiency"
name = "Dual Wield"
description = "Can wield two weapons simultaneously"
category = "combat"
enabled = true
accuracy_penalty = -15

[[perk]]
id = "deadeye"
name = "Deadeye"
description = "Increased ranged accuracy"
category = "combat"
enabled = true
accuracy_bonus = 20

[[perk]]
id = "sprint"
name = "Sprint"
description = "Enhanced running speed"
category = "movement"
enabled = true
movement_bonus = 30
ap_cost_penalty = 1
```

**Unit Class Default Perks:**
```toml
# mods/core/rules/unit/classes.toml

[[unit_class]]
id = "pilot"
name = "Pilot"
default_perks = ["pilot_basic"]

[[unit_class]]
id = "assault"
name = "Assault"
default_perks = ["soldier_basic", "sprint", "bloodlust", "two_weapon_proficiency"]

[[unit_class]]
id = "sniper"
name = "Sniper"
default_perks = ["soldier_basic", "deadeye", "cover_training", "keen_eye"]

[[unit_class]]
id = "medic"
name = "Medic"
default_perks = ["soldier_basic", "medical_training", "leadership"]
```

---

## Usage Examples

### Example 1: Recruit and Equip Unit

```lua
-- Create new unit from class
local unit = UnitManager.recruitUnit("rifleman", 0)

if unit then
  print("Recruited: " .. unit:getName())
  
  -- Equip starting gear
  local rifle = ItemSystem.createItem("rifle_standard")
  local armor = ItemSystem.createItem("light_armor")
  
  unit:equipWeapon(rifle)
  unit:equipArmor(armor)
  
  print("Equipment: " .. unit:getEquippedWeapon().name)
end
```

### Example 2: Squad Composition

```lua
-- Create squad
local squad = SquadManager.createSquad("Alpha Squad")

-- Add units
for i = 1, 4 do
  local unit = UnitManager.recruitUnit("rifleman", 0)
  SquadManager.addUnitToSquad(unit, squad)
end

-- Add specialist
local medic = UnitManager.recruitUnit("medic", 0)
SquadManager.addUnitToSquad(medic, squad)

print("Squad size: " .. squad.size)
print("Average rank: " .. squad:getAverageRank())
```

### Example 3: Unit Progression

```lua
-- Award experience
local unit = UnitManager.getUnit("unit_001")
unit:gainExperience(250)

-- Check promotion
if unit:canPromote() then
  print("Unit ready for promotion!")
  unit:promote("assault_specialist")
  print("New rank: " .. unit:getRank())
end

-- Learn skill
ProgressionService.learnAbility(unit, "overwatch")
print("Learned: Overwatch")
```

### Example 4: Combat Status

```lua
-- Apply damage
local unit = UnitManager.getUnit("unit_002")
unit:takeDamage(15)
print("Health: " .. unit:getHealth() .. "/" .. unit:getMaxHealth())

if unit:getHealth() < unit:getMaxHealth() * 0.25 then
  print("Unit critical!")
  unit:applyStatusEffect("bleeding", 3)
end

-- Check morale
local morale = unit:getMorale()
if morale < 50 then
  unit:modifyMorale(-10, "casualty_nearby")
  print("Morale dropping!")
end
```

---

## Progression System

### Experience Requirements

| Rank | XP Required | Title |
|------|-------------|-------|
| 0 | 0 | Rookie |
| 1 | 100 | Veteran |
| 2 | 300 | Expert |
| 3 | 600 | Specialist |
| 4 | 1000 | Elite |
| 5 | 1500 | Commander |
| 6 | 2500 | Legend |

### Status Effects

| Effect | Duration | Impact |
|--------|----------|--------|
| Bleeding | 3 turns | -1 HP/turn |
| Stunned | 1 turn | Cannot act |
| Panicked | Until morale recover | -50% accuracy |
| Poisoned | 5 turns | -5 HP/turn |
| Burning
| Unconscious | Until healed | Cannot act |

---

## Integration Points

**Inputs from:**
- Battlescape (combat damage, experience gained)
- Basescape (recruitment, equipment storage)
- Equipment (stat bonuses from gear)
- Experience system (XP tracking)

**Outputs to:**
- Battlescape (unit stats, abilities, health)
- Squad displays (morale, composition)
- Statistics (kill counts, mission history)
- UI (unit panels, inventory displays)
- Economy (recruitment costs, salary deductions)

**Dependencies:**
- Equipment system (weapons, armor)
- Class system (base stats, abilities)
- Trait system (characteristics)
- Skill system (abilities)

---

## Unit Transformations & Advancement

The transformation system allows units to evolve, promote, change specialization, acquire new abilities, and transition through career tiers. This creates meaningful long-term progression and allows strategic unit development based on experience and performance.

### Entity: UnitTransformation

**Properties:**
```lua
UnitTransformation = {
  id = "transformation_sectoid_elite",
  name = "Elite Sectoid Evolution",
  unit_type = "sectoid",                      -- Base unit that can transform
  
  -- Requirements
  required_level = 8,                         -- Must reach this level
  required_experience = 50000,                -- Alternative XP requirement
  required_kills = 100,                       -- Combat prerequisite
  required_missions = 10,                     -- Mission count prerequisite
  required_traits = {"leadership", "psi_talent"},  -- Must have certain traits
  
  -- Transformation Effects
  stat_changes = {                            -- Permanent stat increases
    strength = 2,
    will = 3,
    intelligence = 1
  },
  
  health_increase = 20,                       -- Additional max HP
  armor_bonus = 5,                            -- Extra defense
  
  new_abilities = {                           -- Abilities gained
    "psi_lance",
    "mind_shield",
    "heightened_reflexes"
  },
  
  ability_improvements = {                    -- Existing abilities enhanced
    {ability = "plasma_shot", damage_bonus = 0.2},
    {ability = "shoot", accuracy_bonus = 0.1}
  },
  
  specialization_change_allowed = true,       -- Can switch specialization
  appearance_changes = {                      -- Visual updates
    armor_variant = "elite_carapace",
    helmet_variant = "command_helm",
    color_scheme = "red_and_gold"
  },
  
  transformation_time_hours = 24              -- Time to complete transformation
}
```

### Transformation Paths

**Sectoid Evolution Path:**
```toml
[[sectoid_transformations]]
level = 1
name = "Sectoid Warrior"
type = "basic"
stat_bonus_strength = 1
stat_bonus_will = 1
new_abilities = ["mind_merge_preparation"]

[[sectoid_transformations]]
level = 5
name = "Sectoid Ranger"
type = "specialization"
stat_bonus_dexterity = 2
stat_bonus_perception = 1
specialization = "scout"
new_abilities = ["psi_throw", "evasion"]

[[sectoid_transformations]]
level = 8
name = "Sectoid Elite"
type = "advanced"
stat_bonus_strength = 2
stat_bonus_will = 3
stat_bonus_intelligence = 1
new_abilities = ["psi_lance", "mind_shield"]
requirement_kills = 100
requirement_missions = 10

[[sectoid_transformations]]
level = 12
name = "Sectoid Commander"
type = "elite"
stat_bonus_strength = 3
stat_bonus_will = 5
stat_bonus_intelligence = 3
new_abilities = ["psi_domination", "alien_coordination"]
specialization_unlocks = ["overseer", "tactician"]
```

**Human Promotion Path:**
```toml
[[human_promotions]]
rank = 1
name = "Rookie"
xp_required = 0
abilities = ["shoot"]

[[human_promotions]]
rank = 2
name = "Squaddie"
xp_required = 3000
abilities = ["shoot", "snap_shot", "overwatch"]
stat_bonuses_accuracy = 0.05
stat_bonuses_will = 1

[[human_promotions]]
rank = 3
name = "Corporal"
xp_required = 8000
abilities = ["shoot", "snap_shot", "overwatch", "suppression", "flanking_shot"]
stat_bonuses_accuracy = 0.1
stat_bonuses_will = 2
stat_bonuses_strength = 1
specialization_requirement = "must_specialize"

[[human_promotions]]
rank = 4
name = "Sergeant"
xp_required = 15000
abilities = ["shoot", "snap_shot", "overwatch", "suppression", "flanking_shot", "leadership"]
stat_bonuses_accuracy = 0.15
stat_bonuses_will = 3
stat_bonuses_strength = 2

[human_promotions_class_abilities_sergeant]
rifleman = ["steady_aim", "lock_n_load"]
assault = ["lightning_reflexes", "close_combat"]
support = ["scanning_protocol", "covering_fire"]
sniper = ["steady_hands", "killzone"]

[[human_promotions]]
rank = 5
name = "Lieutenant"
xp_required = 25000
abilities = ["shoot", "leadership", "rally_cry", "command_presence"]
stat_bonuses_accuracy = 0.2
stat_bonuses_will = 4
stat_bonuses_strength = 3
special_abilities = ["squad_tactics", "command_protocol"]

[[human_promotions]]
rank = 6
name = "Captain"
xp_required = 40000
abilities = ["shoot", "leadership", "rally_cry", "command_presence", "inspire"]
stat_bonuses_accuracy = 0.25
stat_bonuses_will = 5
stat_bonuses_strength = 4
special_abilities = ["veteran_tactics", "inspire_confidence"]
```

### Specialization Branching

**Class-Based Specialization:**
```lua
function getAvailableSpecializations(unit)
  -- Different specializations available based on base class and attributes
  local available = {}
  
  -- Strength-based specializations
  if unit.strength >= 10 then
    table.insert(available, "assault")
    table.insert(available, "heavy_weapons")
  end
  
  -- Dexterity-based specializations
  if unit.dexterity >= 10 then
    table.insert(available, "scout")
    table.insert(available, "sniper")
  end
  
  -- Intelligence-based specializations
  if unit.intelligence >= 10 then
    table.insert(available, "technician")
    table.insert(available, "hacker")
  end
  
  -- Will-based specializations
  if unit.will >= 10 then
    table.insert(available, "psi_operative")
    table.insert(available, "commander")
  end
  
  -- Support specializations (no stat requirement)
  table.insert(available, "medic")
  table.insert(available, "support")
  
  return available
end

function changeSpecialization(unit, new_specialization)
  -- Specialization change allows ability repositioning
  local old_abilities = unit:getAbilities()
  local specialization_data = SPECIALIZATIONS[new_specialization]
  
  unit.specialization = new_specialization
  
  -- Retain some core abilities (not spec-specific)
  -- Remove spec-specific abilities from old spec
  -- Add new spec abilities
  
  return true
end
```

### Recruitment & Acquisition

**Recruitment Cost Calculation:**
```lua
function calculateRecruitmentCost(unit_type, rank, experience)
  -- Base cost varies by unit type
  local base_costs = {
    human_soldier = 1000,
    human_officer = 2000,
    human_psi = 3000,
    alien_captive = 5000,
    clone = 2000
  }
  
  local base_cost = base_costs[unit_type] or 1500
  
  -- Higher rank costs more
  local rank_multiplier = 1.0 + (rank * 0.5)  -- 1.0x at rank 0, 3.5x at rank 6
  
  -- Experience/training cost
  local training_cost = experience / 10  -- Every 10 XP = 1 credit investment
  
  -- Total cost
  local total_cost = (base_cost * rank_multiplier) + training_cost
  
  return total_cost
end
```

**Recruitment Options:**
```lua
function getRecruitmentOptions(player_state)
  local options = {}
  
  -- Standard recruitment from military sources
  if player_state.has_military_contacts then
    table.insert(options, {
      type = "military_recruitment",
      availability = "always",
      cost = 1000,
      quality = "average",
      training_time = 5
    })
  end
  
  -- Elite recruitment from special forces
  if player_state.has_elite_contacts then
    table.insert(options, {
      type = "elite_recruitment",
      availability = "limited",
      cost = 3000,
      quality = "high",
      training_time = 2
    })
  end
  
  -- Captured aliens
  if player_state.has_captured_aliens then
    table.insert(options, {
      type = "alien_recruitment",
      availability = "post_capture",
      cost = 5000,
      quality = "exceptional",
      training_time = 10
    })
  end
  
  -- Clone recruitment (requires technology)
  if player_state.has_cloning_tech then
    table.insert(options, {
      type = "clone_recruitment",
      availability = "post_research",
      cost = 2000,
      quality = "moderate",
      training_time = 8
    })
  end
  
  return options
end
```

### Trait & Ability Acquisition

**Trait Gain During Transformation:**
```lua
function acquireTraitDuringTransformation(unit, transformation)
  local possible_traits = {
    -- Combat traits
    {name = "sharpshooter", rate = 0.15},
    {name = "gunslinger", rate = 0.1},
    {name = "hard_target", rate = 0.2},
    {name = "mayhem", rate = 0.1},
    
    -- Survival traits
    {name = "will_to_survive", rate = 0.25},
    {name = "dense", rate = 0.15},
    {name = "resilience", rate = 0.2},
    
    -- Psi traits
    {name = "psi_talent", rate = 0.05},
    {name = "weak_psi", rate = 0.15},
    
    -- Leadership traits
    {name = "leader", rate = 0.1},
    {name = "command_presence", rate = 0.08}
  }
  
  local acquired_traits = {}
  
  for _, trait_info in ipairs(possible_traits) do
    if math.random() < trait_info.rate then
      table.insert(acquired_traits, trait_info.name)
    end
  end
  
  for _, trait in ipairs(acquired_traits) do
    unit:addTrait(trait)
  end
  
  return acquired_traits
end
```

### TOML Configuration

```toml
[unit_transformations]
enabled = true
transformation_time_hours = 24
transformation_facility_required = "psionic_lab"

[unit_transformations.human_ranks]
rank_0 = {name = "Rookie", xp_required = 0}
rank_1 = {name = "Squaddie", xp_required = 3000}
rank_2 = {name = "Corporal", xp_required = 8000}
rank_3 = {name = "Sergeant", xp_required = 15000}
rank_4 = {name = "Lieutenant", xp_required = 25000}
rank_5 = {name = "Captain", xp_required = 40000}

[unit_transformations.specializations]
rifleman = {primary_stat = "accuracy", start_abilities = ["shoot", "snap_shot"]}
assault = {primary_stat = "strength", start_abilities = ["shoot", "close_combat"]}
support = {primary_stat = "will", start_abilities = ["shoot", "covering_fire"]}
sniper = {primary_stat = "perception", start_abilities = ["shoot", "steady_aim"]}
medic = {primary_stat = "intelligence", start_abilities = ["first_aid", "medpack"]}
technician = {primary_stat = "intelligence", start_abilities = ["hack", "repair"]}

[unit_transformations.recruitment]
military_cost = 1000
elite_cost = 3000
alien_cost = 5000
clone_cost = 2000

military_training_days = 5
elite_training_days = 2
alien_training_days = 10
clone_training_days = 8

[unit_transformations.traits]
# Probabilities of trait acquisition during transformation
sharpshooter_chance = 0.15
gunslinger_chance = 0.10
hard_target_chance = 0.20
mayhem_chance = 0.10
will_to_survive_chance = 0.25
dense_chance = 0.15
resilience_chance = 0.20
psi_talent_chance = 0.05
leader_chance = 0.10
command_presence_chance = 0.08

[unit_transformations.alien_tiers]
basic_sectoid = {level_min = 1, level_max = 3}
sectoid_warrior = {level_min = 4, level_max = 6}
sectoid_elite = {level_min = 7, level_max = 9}
sectoid_commander = {level_min = 10, level_max = 12}
```

---

## Error Handling

```lua
-- Invalid unit
if not UnitManager.getUnit(unit_id) then
  print("Unit not found: " .. unit_id)
  return false
end

-- Cannot equip item
if not unit:equip("weapon", item) then
  print("Cannot equip " .. item.name)
end

-- Insufficient ranks
if not unit:canPromote() then
  print("Unit not ready for promotion - need more XP")
end

-- Morale too low
if unit:getMorale() < 0 then
  print("Unit panicking!")
  UnitCombat.panic(unit)
end

-- Dead unit
if unit:getStatus() == "dead" then
  print("Cannot perform action on dead unit")
  return false
end
```

---

## Implementation Status

### IN DESIGN (Existing in engine/)
- **UnitEntity (Battlescape)**: ECS-based unit entity with Transform, Movement, Vision, Health, and Team components
- **Component Systems**: Individual ECS components for battlescape units
- **Unit Factories**: Factory methods for creating soldiers and aliens

### FUTURE IDEAS (Not in engine/)
- **Unit Entity (Basescape)**: Persistent unit identity with progression and specialization
- **Squad Entity**: Group management with cohesion and morale
- **UnitClass Entity**: Template system for unit archetypes
- **Trait/Skill Entities**: Characteristics and learned abilities
- **Unit Management Services**: Recruitment, progression, combat status
- **TOML Configuration**: Unit classes, traits, progression data
- **Unit Transformations**: Evolution, promotion, specialization changes

---

**Last Updated:** October 22, 2025  
**API Status:** ✅ COMPLETE  
**Coverage:** 100% (All entities, functions, TOML, examples, progression system documented)  
**Consolidation:** UNITS_DETAILED + UNITS_EXPANDED merged into single comprehensive module
