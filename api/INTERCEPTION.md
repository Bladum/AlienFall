# Interception API Reference

**System:** Strategic Layer (Air Combat & Craft Interception)  
**Module:** `engine/interception/`  
**Latest Update:** October 22, 2025  
**Status:** ✅ Complete

---

## Overview

The Interception system manages turn-based aerial combat between player crafts and UFOs at the strategic geoscape layer. Similar to a battle card game with tactical engagements, weapons management, resource commitment, and multi-layered altitude systems. This is distinct from Battlescape (ground-level tactical combat).

**Layer Classification:** Strategic / Combat  
**Primary Responsibility:** Air combat resolution, UFO interception, craft engagement, altitude layering, damage calculation, outcome determination, reward distribution  
**Integration Points:** Geoscape (UFO tracking, movement), Crafts (combat stats, weapons, health), Battle mechanics, Research (technology progression)

---

## Implementation Status

### IN DESIGN (Exists in engine/interception/)
- Core interception battle system with turn-based combat
- InterceptionUnit wrapper for craft and UFO combat
- Weapon system with different tracking types (ballistic, homing, beam)
- Altitude layer system (air, land, underwater)
- Armor and evasion mechanics
- Status effects (stun, disable, puncture, EMP, incendiary)
- Hit chance and damage calculation formulas
- Multi-craft engagements
- AI decision-making for UFO combat
- Reward system for victories
- Combat resolution and outcome determination

### FUTURE IDEAS (Not in engine/interception/)
- Advanced AI tactics and learning
- Dynamic weather effects on combat
- Terrain-based modifiers
- Multi-UFO engagements
- Electronic warfare systems
- Pilot skill progression
- Advanced weapon customization
- Networked multiplayer interception
- Real-time interception mode

---

## Core Entities

### Entity: Interception

Represents an active combat session between craft(s) and UFO(s) with full state management.

**Properties:**
```lua
Interception = {
  id = string,                    -- Unique session ID
  
  -- Combatants
  attacker = InterceptionUnit[],  -- Player craft(s)
  defender = InterceptionUnit[],  -- UFO or base defense
  
  -- Combat State
  altitude_layers = string[],     -- "air", "land", "underwater"
  turn = number,                  -- Current turn (1-30)
  max_turns = number,             -- 30 typical
  turn_order = InterceptionUnit[], -- Initiative order
  
  -- Status
  is_active = bool,               -- Combat ongoing?
  winner = string | nil,          -- "attacker", "defender", or nil
  
  -- Location
  location = HexCoordinate,       -- Position on geoscape
  
  -- Rewards
  victory_rewards = table,        -- XP, loot, research
}
```

**Functions:**
```lua
-- Creation
InterceptionSystem.startInterception(craft, target) → Interception, error
InterceptionSystem.startInterceptionMulti(crafts, targets) → Interception, error

-- Status queries
interception:isActive() → bool
interception:getCurrentTurn() → number
interception:getTurnsRemaining() → number
interception:getWinner() → string | nil

-- Unit management
interception:getUnits(side) → InterceptionUnit[]  -- "attacker" or "defender"
interception:getUnit(id) → InterceptionUnit | nil
interception:getDeployedUnits() → InterceptionUnit[]  -- Active units
interception:getDeadUnits() → InterceptionUnit[]

-- Combat
interception:getCurrentUnit() → InterceptionUnit  -- Whose turn?
interception:fireWeapon(attacker, target, weapon) → AttackResult
interception:performEvasion(unit) → bool
interception:applyDamage(unit, amount, type) → void
interception:resolveRound() → void

-- Queries
interception:calculateDistance(unit1, unit2) → number
interception:getLineOfSight(from, to) → bool
interception:isInAltitudeLayer(unit, layer) → bool

-- Completion
interception:checkVictoryConditions() → (won, reason)
interception:checkDefeatConditions() → (lost, reason)
interception:endInterception() → (winner, rewards)
```

---

### Entity: InterceptionBattle

Top-level combat engagement between craft and UFO with battle state management.

**Properties:**
```lua
InterceptionBattle = {
  id = string,                    -- "interception_001"
  type = string,                  -- "craft_vs_ufo", "craft_vs_craft"
  status = string,                -- "active", "victory", "defeat", "fled"
  
  -- Participants
  craft = Craft,                  -- Player craft
  enemy = UFO,                    -- Opposing UFO
  
  -- Battle State
  craft_unit = CombatUnit,        -- Combat wrapper for craft
  enemy_unit = CombatUnit,        -- Combat wrapper for UFO
  current_round = number,         -- Round counter
  max_rounds = number,            -- 20 = typical engagement length
  
  -- Positioning
  distance = number,              -- Hex distance between combatants
  engagement_range = number,      -- Weapon effective range
  craft_evasion = number,         -- Dodging probability
  ufo_evasion = number,           -- UFO dodging probability
  
  -- Results
  winner = "craft" | "ufo" | nil, -- Battle outcome
  damage_dealt = number,          -- Total damage to loser
  rounds_fought = number,         -- Actual turns spent
}
```

**Functions:**
```lua
-- Initialization
InterceptionBattle.new(craft: Craft, ufo: UFO) → InterceptionBattle
battle:initializeCombatants() → void

-- Round execution
battle:executeRound() → void
battle:craftAction(action: string, target: UFO) → HitResult
battle:enemyAction(action: string, target: Craft) → HitResult
battle:advanceRound() → void

-- Status queries
battle:isActive() → boolean
battle:getStatus() → string
battle:getWinner() → string | nil
battle:getRoundsRemaining() → number
battle:getDistance() → number

-- Engagement management
battle:flee() → boolean (attempt retreat)
battle:disengage() → void
battle:resolveVictory() → void (determine winner)
battle:applyRewards(side: string) → void
```

---

### Entity: InterceptionUnit

Combat-ready wrapper for individual craft or UFO in air battle with full combat state.

**Properties:**
```lua
InterceptionUnit = {
  id = string,                    -- Unique combat ID
  unit_type = string,             -- "craft", "ufo"
  owner = string,                 -- "player", "ufo", "base"
  name = string,
  source = Craft | UFO,           -- Reference to source entity
  
  -- Position & Altitude
  location = HexCoordinate,
  altitude_layer = string,        -- "air", "land", "underwater"
  
  -- Combat Stats
  armor = number,                 -- Damage reduction (0-50)
  hp_current = number,            -- Current hit points
  hp_max = number,                -- Maximum hit points
  evasion = number,               -- Dodge chance (0-100%)
  
  -- Weapons
  equipped_weapons = InterceptionWeapon[],
  ammo_remaining = table,         -- {missile: 4, cannon: 100}
  current_weapon = InterceptionWeapon | nil,
  
  -- Status
  is_destroyed = bool,
  is_grounded = bool,  -- Can't move/attack
  is_defending = boolean,         -- Defense stance (+armor)
  status_effects = string[],      -- "damaged", "disabled", "shielded"
}
```

**Functions:**
```lua
-- Status queries
unit:getName() → string
unit:getHP() → number
unit:getMaxHP() → number
unit:getHPPercent() → number
unit:isAlive() → bool
unit:isDestroyed() → bool
unit:isCritical() → boolean (hp < 20%)

-- Combat actions
unit:takeDamage(damage: number) → void
unit:heal(amount: number) → void

-- Weapon management
unit:getWeapons() → InterceptionWeapon[]
unit:getAmmo(weaponId) → number
unit:consumeAmmo(weaponId, amount: number) → bool
unit:getAvailableActions() → string[]
unit:canFireWeapon(weapon: InterceptionWeapon) → boolean
unit:canEvade() → boolean
unit:canDefend() → boolean

-- Combat mechanics
unit:fireWeapon(weapon: InterceptionWeapon, target: InterceptionUnit) → HitResult
unit:defend() → number (armor bonus)
unit:evade() → number (evasion bonus)
unit:calculateHitChance(weapon: InterceptionWeapon, target: InterceptionUnit) → number

-- Positioning
unit:getLocation() → HexCoordinate
unit:getAltitude() → string

-- Effects
unit:addStatusEffect(effectName: string) → void
unit:removeStatusEffect(effectName: string) → void
unit:hasStatusEffect(effectName: string) → bool
```

---

### Entity: InterceptionWeapon

Weapon system optimized for craft-to-craft or craft-to-base aerial combat.

**Properties:**
```lua
InterceptionWeapon = {
  id = string,                    -- "air_to_air_missile", "machine_gun_air"
  name = string,
  
  -- Weapon Type
  type = string,                  -- "ballistic", "energy", "missile"
  tracking = string,              -- "homing", "ballistic", "beam"
  speed = number,                 -- Hex per turn movement
  
  -- Damage
  damage_base = number,           -- 20-100 per hit
  damage_min = number,            -- Damage floor
  damage_max = number,            -- Damage ceiling
  damage_type = string,           -- "kinetic", "energy", "plasma"
  damage_variance = number,       -- ±% variance
  critical_bonus = number,        -- Extra damage on crit (%)
  critical_chance = number,       -- Crit % (0.0-0.5)
  
  -- Targeting & Accuracy
  accuracy_base = number,         -- Base hit chance (0.5-0.95)
  accuracy = number,              -- 0.0-1.0 (percentage)
  accuracy_penalty_distance = number, -- Penalty per hex away from optimal
  
  -- Range
  range_min = number,             -- Minimum range
  range_max = number,             -- Maximum range
  range_optimal = number,         -- Best accuracy range
  falloff_distance = number,      -- Accuracy degradation per hex
  
  -- Ammunition
  ammo_type = string,             -- "bullets", "energy", "missiles"
  ammo_capacity = number,         -- Total ammo
  ammo_per_shot = number,         -- Ammo consumed per shot
  
  -- Usage
  ap_cost = number,               -- Action points to fire
  
  -- Restrictions & Special
  altitude_restriction = string,  -- "air", "land", "all", "underwater"
  effect = string | nil,          -- "stun", "disable", "puncture", "incendiary", "emp"
  effect_chance = number,         -- Trigger % for special effect
  effects = string[],             -- Multiple possible effects
}
```

---

### Entity: AttackResult

Result of a weapon attack during interception combat.

**Properties:**
```lua
AttackResult = {
  attacker = InterceptionUnit,
  target = InterceptionUnit,
  weapon = InterceptionWeapon,
  
  -- Resolution
  hit = bool,                     -- Did attack land?
  hit_chance = number,            -- 0-100 calculated
  
  -- Damage
  damage_dealt = number,
  damage_prevented = number,      -- From armor
  armor_broken = bool,            -- Armor destroyed?
  
  -- Effects
  effects_applied = string[],     -- Applied effects
  
  -- Combat state
  distance = number,              -- Range of attack
  altitude_layer = string,        -- Altitude used
}
```

---

## Services & Functions

### Interception Management Service

```lua
-- Create and manage battles
InterceptionManager.createBattle(craft: Craft, ufo: UFO) → InterceptionBattle
InterceptionManager.getBattle(battle_id: string) → InterceptionBattle | nil
InterceptionManager.getActiveBattles() → InterceptionBattle[]
InterceptionManager.startBattle(battle: InterceptionBattle) → void

-- Battle execution
InterceptionManager.executeTurn(battle: InterceptionBattle) → void
InterceptionManager.executeBattle(battle: InterceptionBattle) → HitResult
InterceptionManager.resolveBattle(battle: InterceptionBattle) → string ("victory" | "defeat" | "draw")

-- Status queries
InterceptionManager.isBattleActive(battle_id: string) → boolean
InterceptionManager.getActiveBattlesNearLocation(province: Province) → InterceptionBattle[]

-- Interception sessions
InterceptionManager.startInterception(craft, target) → Interception, error
InterceptionManager.startInterceptionMulti(crafts, targets) → Interception, error
InterceptionManager.getCurrentInterception() → Interception | nil
```

### Interception Combat Service

```lua
-- Weapon firing
InterceptionCombat.calculateHitChance(unit: InterceptionUnit, weapon: InterceptionWeapon, target: InterceptionUnit) → number
InterceptionCombat.rollHit(hit_chance: number) → boolean
InterceptionCombat.calculateDamage(weapon: InterceptionWeapon, is_critical: boolean) → number
InterceptionCombat.fireWeapon(attacker: InterceptionUnit, weapon: InterceptionWeapon, target: InterceptionUnit) → HitResult

-- Evasion and defense
InterceptionCombat.calculateEvasion(unit: InterceptionUnit, attacker: InterceptionUnit) → number
InterceptionCombat.calculateDefense(unit: InterceptionUnit) → number
InterceptionCombat.processEvasion(attacker: InterceptionUnit, defender: InterceptionUnit, incoming_damage: number) → boolean

-- Special effects
InterceptionCombat.applySpecialEffect(effect: string, target: InterceptionUnit) → void
InterceptionCombat.processStun(unit: InterceptionUnit) → void (lose next turn)
InterceptionCombat.processDisable(unit: InterceptionUnit) → void (weapon offline)
InterceptionCombat.processPuncture(unit: InterceptionUnit) → void (fuel leak)
InterceptionCombat.processEMP(unit: InterceptionUnit) → void (electronics disabled)
InterceptionCombat.processIncendiary(unit: InterceptionUnit) → void (continuous damage)
```

### Interception Unit Service

```lua
-- Create and manage combat units
InterceptionUnit.createFromCraft(craft: Craft) → InterceptionUnit
InterceptionUnit.createFromUFO(ufo: UFO) → InterceptionUnit
InterceptionUnit.getStatus(unit: InterceptionUnit) → string

-- Equipment
InterceptionUnit.equipWeapon(unit: InterceptionUnit, weapon: InterceptionWeapon) → void
InterceptionUnit.getAvailableWeapons(unit: InterceptionUnit) → InterceptionWeapon[]
InterceptionUnit.loadAmmo(unit: InterceptionUnit, weapon_id: string, ammo: number) → void
InterceptionUnit.initializeFromSource() → void
```

### Interception Reward Service

```lua
-- Experience and rewards
InterceptionReward.calculateRewards(battle: InterceptionBattle) → {exp: number, credits: number, items: ItemStack[]}
InterceptionReward.applyRewards(craft: Craft, rewards: table) → void
InterceptionReward.calculateResearch(battle: InterceptionBattle) → {tech: string, progress: number}
InterceptionReward.recordBattleStats(battle: InterceptionBattle) → void
```

---

## Configuration (TOML)

### Interception Mechanics

```toml
# interception/mechanics.toml

[general]
# Round configuration
rounds_per_battle = 20
turn_time_seconds = 5
max_engagement_distance = 15  # Hexes

# Rewards
exp_per_ufo_kill = 100
exp_per_hit = 5
exp_per_dodge = 2
credits_per_ufo_kill = 10000

[accuracy]
# Base accuracy calculations
min_accuracy = 0.15  # Weapons never go below 15% hit
max_accuracy = 0.95  # Weapons never go above 95% hit
distance_penalty_per_hex = 0.02  # -2% per hex from optimal range
optimal_range_bonus = 0.10  # +10% at optimal range
critical_chance_base = 0.05  # 5% baseline crit chance
critical_damage_bonus = 1.5  # 150% = 1.5x damage multiplier

[evasion]
# Evasion mechanics
evasion_per_dodge = 0.1  # +10% dodge per dodge attempt
evasion_penalty_armor = 0.05  # -5% dodge per armor point
max_evasion = 0.7  # Can't dodge more than 70% of shots

[defense]
# Defense stance
defense_armor_bonus = 5  # Additional armor
defense_accuracy_penalty = 0.15  # -15% to own accuracy

[special_effects]
# Status effects
stun_duration = 1  # Skip how many turns
disable_duration = 2  # Weapon offline for X turns
puncture_fuel_loss = 0.2  # Lose 20% fuel per turn
puncture_duration = 3
emp_duration = 3  # Electronics offline
incendiary_damage_per_turn = 1  # Continuous damage
```

### Interception Weapons

```toml
# interception/weapons.toml

[[weapons]]
id = "machine_gun_air"
name = "Machine Gun (Air)"
type = "ballistic"
damage_min = 8
damage_max = 15
critical_chance = 0.08
accuracy_base = 0.75
tracking = "ballistic"
range_min = 1
range_max = 12
range_optimal = 6
accuracy_penalty_distance = 0.03
ammo_capacity = 200
ammo_per_shot = 5
effect = nil

[[weapons]]
id = "plasma_cannon_air"
name = "Plasma Cannon (Air)"
type = "energy"
damage_min = 20
damage_max = 35
critical_chance = 0.05
accuracy_base = 0.70
tracking = "beam"
range_min = 3
range_max = 15
range_optimal = 10
accuracy_penalty_distance = 0.02
ammo_capacity = 50
ammo_per_shot = 1
effect = "puncture"
effect_chance = 0.3

[[weapons]]
id = "missile_air"
name = "Air Missile"
type = "missile"
damage_min = 40
damage_max = 60
critical_chance = 0.10
accuracy_base = 0.60
tracking = "homing"
range_min = 5
range_max = 20
range_optimal = 15
accuracy_penalty_distance = 0.01
ammo_capacity = 20
ammo_per_shot = 2
effect = "stun"
effect_chance = 0.4

[[weapons]]
id = "ufo_plasma_beam"
name = "UFO Plasma Beam"
type = "energy"
damage_min = 25
damage_max = 45
critical_chance = 0.12
accuracy_base = 0.80
tracking = "beam"
range_min = 2
range_max = 18
range_optimal = 12
ammo_capacity = 200
ammo_per_shot = 0
effect = "disable"
effect_chance = 0.25

[[weapons]]
id = "emp_missile"
name = "EMP Missile"
type = "missile"
damage_min = 5
damage_max = 10
critical_chance = 0.02
accuracy_base = 0.65
tracking = "homing"
range_min = 3
range_max = 18
ammo_capacity = 12
ammo_per_shot = 1
effect = "emp"
effect_chance = 0.8

[[weapons]]
id = "incendiary_bomb"
name = "Incendiary Bomb"
type = "ballistic"
damage_min = 15
damage_max = 25
critical_chance = 0.06
accuracy_base = 0.55
tracking = "ballistic"
range_min = 2
range_max = 10
range_optimal = 7
ammo_capacity = 30
ammo_per_shot = 1
effect = "incendiary"
effect_chance = 0.9
```

### Altitude System Configuration

```toml
# interception/altitude_system.toml

[[altitude_layers]]
name = "air"
description = "High altitude flight"
accuracy_bonus = 0.0
speed_bonus = 1.0
defense_bonus = 0.8
weapons_available = ["missile_air", "plasma_cannon_air", "machine_gun_air", "emp_missile"]

[[altitude_layers]]
name = "land"
description = "Ground level combat"
accuracy_bonus = 0.1
speed_bonus = 0.7
defense_bonus = 1.2
weapons_available = ["machine_gun_air", "incendiary_bomb"]

[[altitude_layers]]
name = "underwater"
description = "Underwater engagement"
accuracy_bonus = -0.2
speed_bonus = 0.5
defense_bonus = 1.5
weapons_available = ["torpedo"]
```

### Battle Difficulty Modifiers

```toml
# interception/difficulty_modifiers.toml

[difficulty_easy]
ufo_accuracy_multiplier = 0.7
ufo_damage_multiplier = 0.8
player_accuracy_bonus = 0.1
player_damage_multiplier = 1.0

[difficulty_normal]
ufo_accuracy_multiplier = 1.0
ufo_damage_multiplier = 1.0
player_accuracy_bonus = 0.0
player_damage_multiplier = 1.0

[difficulty_hard]
ufo_accuracy_multiplier = 1.2
ufo_damage_multiplier = 1.2
player_accuracy_bonus = -0.1
player_damage_multiplier = 1.0

[difficulty_legendary]
ufo_accuracy_multiplier = 1.5
ufo_damage_multiplier = 1.5
player_accuracy_bonus = -0.2
player_damage_multiplier = 0.9
ufo_special_ability_rate = 1.5
```

---

## Usage Examples

### Example 1: Create and Execute Interception Battle

```lua
-- Detect UFO and create interception
local craft = CraftManager.getCraft("craft_skyranger_01")
local ufo = UFOManager.getUFO("ufo_scout_01")

if craft and ufo then
  local battle = InterceptionManager.createBattle(craft, ufo)
  print("Interception battle started!")
  print(craft.name .. " vs " .. ufo.name)
end

-- Execute full battle automatically or step through manually
if manual_control then
  InterceptionManager.executeTurn(battle)  -- One round
else
  local result = InterceptionManager.executeBattle(battle)
  print("Battle complete: " .. result)
end
```

### Example 2: Manual Combat with Weapon Selection

```lua
-- Create battle units
local craft_unit = InterceptionUnit.createFromCraft(craft)
local enemy_unit = InterceptionUnit.createFromUFO(ufo)

-- Combat round
while battle:isActive() do
  -- Craft turn
  local available_weapons = craft_unit:getAvailableActions()
  
  if craft_unit:canFireWeapon(primary_weapon) then
    local hit_chance = InterceptionCombat.calculateHitChance(craft_unit, primary_weapon, enemy_unit)
    print("Hit chance: " .. math.floor(hit_chance * 100) .. "%")
    
    local result = InterceptionCombat.fireWeapon(craft_unit, primary_weapon, enemy_unit)
    
    if result.hit then
      print("Direct hit! Damage: " .. result.damage_dealt)
      enemy_unit:takeDamage(result.damage_dealt)
    else
      print("Miss!")
    end
  end
  
  -- Enemy AI turn
  battle:enemyAction("fireWeapon", craft_unit)
  
  -- Next round
  battle:advanceRound()
end
```

### Example 3: Apply Rewards and Process Results

```lua
-- Battle complete
local winner = battle:getWinner()

if winner == "craft" then
  print("Victory! UFO defeated!")
  
  -- Calculate and apply rewards
  local rewards = InterceptionReward.calculateRewards(battle)
  print("Experience: " .. rewards.exp)
  print("Credits: " .. rewards.credits)
  
  InterceptionReward.applyRewards(craft, rewards)
  
  -- Record kill
  craft:recordKill("ufo")
  craft:gainExperience(rewards.exp)
  
  -- Check for rank-up
  if CraftCombat.processRankUp(craft) then
    print("Craft promoted to Rank " .. craft:getRank() .. "!")
  end
  
else
  print("Defeat! UFO escaped or craft destroyed.")
  
  -- Craft takes damage
  craft:takeDamage(battle.damage_dealt)
  
  if craft:getHealthPercent() < 0.1 then
    print("Craft critically damaged - returning to base!")
    CraftMovement.returnCraft(craft, home_base)
  end
end

-- Record battle stats for analysis
InterceptionReward.recordBattleStats(battle)
```

### Example 4: Handle Special Effects

```lua
-- During combat, special effects may trigger
local result = InterceptionCombat.fireWeapon(craft_unit, weapon, ufo_unit)

if result.effect then
  print("Special effect triggered: " .. result.effect)
  
  if result.effect == "stun" then
    InterceptionCombat.processStun(ufo_unit)
    print("UFO stunned! Loses next turn.")
    
  elseif result.effect == "disable" then
    InterceptionCombat.processDisable(ufo_unit)
    print("UFO weapon system disabled!")
    
  elseif result.effect == "puncture" then
    InterceptionCombat.processPuncture(craft_unit)
    print("Fuel tank punctured! Fuel leaking.")
    
  elseif result.effect == "emp" then
    InterceptionCombat.processEMP(ufo_unit)
    print("Electronics disabled! Radar offline.")
    
  elseif result.effect == "incendiary" then
    InterceptionCombat.processIncendiary(craft_unit)
    print("Catching fire! Taking continuous damage.")
  end
end

-- Check for critical status
if ufo_unit:isCritical() then
  print("UFO in critical condition!")
end
```

### Example 5: Multi-Craft Engagement

```lua
-- Dispatch multiple craft
local crafts = {
  CraftManager.getCraft("skyranger_01"),
  CraftManager.getCraft("lightning_01"),
  CraftManager.getCraft("lightning_02"),
}

local ufo = UFOManager.getDetectedUFO("ufo_001")

-- Start multi-unit interception
local interception = InterceptionSystem.startInterceptionMulti(crafts, {ufo})

print("Deployed " .. #crafts .. " craft against UFO")

-- Process turns
while interception:isActive() do
  local unit = interception:getCurrentUnit()
  
  -- Get available actions
  local actions = unit:getAvailableActions()
  print(unit:getName() .. " can: " .. table.concat(actions, ", "))
  
  -- Next unit
  interception:resolveRound()
end

-- Check outcome
local winner, rewards = interception:endInterception()
print("Winner: " .. winner)
```

---

## Advanced Combat Mechanics

### Armor System

#### Armor Properties

**Armor Rating:** 0-50 points for craft/UFO  
**Damage Reduction Formula:**
```lua
-- Armor absorbs % of incoming damage
armor_damage_reduction = armor_rating × 0.02  -- Each point = 2% reduction (max 100%)
effective_armor = math.min(armor_rating * 0.02, 0.95)  -- Cap at 95% reduction
```

#### Armor Effectiveness by Damage Type

| Damage Type | Armor Reduction | Special Notes |
|---|---|---|
| **Kinetic** (bullets, cannon rounds) | 100% rating effective | Standard ballistic damage |
| **Energy** (plasma, lasers) | 75% rating effective | Penetrating heat damage |
| **Explosive** (missiles, bombs) | 50% rating effective | Explosive shockwave |
| **EMP** (electromagnetic) | 0% rating effective | Targets electronics, ignores armor |

**Type-Based Calculation:**
```lua
function calculateArmorReduction(armor_rating, damage_type)
  local type_modifiers = {
    kinetic = 1.0,
    energy = 0.75,
    explosive = 0.5,
    emp = 0.0
  }
  
  local effective_armor = armor_rating * type_modifiers[damage_type]
  local reduction = math.min(effective_armor * 0.02, 0.95)
  
  return reduction
end
```

#### Armor Degradation

Armor can be permanently damaged in combat:
```lua
-- Each time armor reduces damage, degradation chance
armor_degradation_chance = 0.15  -- 15% chance per hit absorbed

-- Degradation process
if random() < armor_degradation_chance then
  armor_current = armor_current - 1
  print("[DAMAGE] Armor integrity compromised: " .. armor_current .. "/" .. armor_max)
  
  if armor_current <= 0 then
    print("[WARNING] Armor destroyed! No protection remaining.")
  end
end
```

---

### Detailed Damage Calculation

**Step 1: Base Damage**
```lua
base_damage = weapon.damage_min + random(0, weapon.damage_max - weapon.damage_min)
```

**Step 2: Variance**
```lua
variance_factor = 1.0 + (random() - 0.5) * (weapon.damage_variance / 50)
-- Typical variance: ±5% = 0.1 (if damage_variance = 5)
```

**Step 3: Critical Strike**
```lua
is_critical = random() < weapon.critical_chance
critical_multiplier = is_critical and weapon.critical_bonus or 1.0
-- Typical: 1.5x (50% bonus damage)
```

**Step 4: Distance Penalty**
```lua
distance_mod = 1.0
if distance ~= weapon.range_optimal then
  local distance_diff = math.abs(distance - weapon.range_optimal)
  distance_mod = 1.0 - (distance_diff * weapon.accuracy_penalty_distance)
  distance_mod = math.max(distance_mod, 0.5)  -- Never below 50% damage
end
```

**Step 5: Type-Based Reduction**
```lua
armor_reduction_factor = calculateArmorReduction(target.armor, weapon.damage_type)
armor_absorbed = base_damage * armor_reduction_factor
```

**Final Calculation:**
```lua
function calculateDamage(attacker, weapon, target, is_critical)
  local base = weapon.damage_min + math.random(0, weapon.damage_max - weapon.damage_min)
  local variance = 1.0 + (math.random() - 0.5) * 0.1  -- ±5% variance
  local critical_mult = is_critical and weapon.critical_bonus or 1.0
  local distance_mod = 1.0 - math.abs(distance - weapon.range_optimal) * 0.02
  
  local pre_armor = base * variance * critical_mult * distance_mod
  local armor_factor = calculateArmorReduction(target.armor, weapon.damage_type)
  local armor_absorbed = pre_armor * armor_factor
  
  local final_damage = pre_armor - armor_absorbed
  
  return {
    base_damage = base,
    final_damage = math.floor(final_damage),
    armor_absorbed = math.floor(armor_absorbed),
    is_critical = is_critical,
    distance_penalty = 1.0 - distance_mod
  }
end
```

---

### Hit Chance Calculation

**Complete Hit Resolution:**

```lua
function calculateHitChance(attacker, weapon, target, distance)
  -- Base accuracy from weapon
  local accuracy = weapon.accuracy_base
  
  -- Distance modifier (penalty for far range)
  if distance ~= weapon.range_optimal then
    local distance_diff = math.abs(distance - weapon.range_optimal)
    accuracy = accuracy - (distance_diff * weapon.accuracy_penalty_distance)
  end
  
  -- Attacker modifiers
  if attacker:hasStatusEffect("disabled") then
    accuracy = accuracy * 0.5  -- Weapon system damaged
  end
  
  -- Target evasion
  local evasion = target:calculateEvasion()
  if target:hasStatusEffect("stunned") then
    evasion = evasion * 0.5  -- Can't dodge while stunned
  end
  
  -- Final calculation
  local hit_chance = accuracy * (1.0 - evasion)
  hit_chance = math.max(hit_chance, 0.15)  -- Minimum 15% hit
  hit_chance = math.min(hit_chance, 0.95)  -- Maximum 95% hit
  
  return hit_chance
end

-- Resolution
local hit_chance = calculateHitChance(attacker, weapon, target, distance)
local roll = math.random()
local hit = roll < hit_chance

if hit then
  print("[HIT] Accuracy: " .. math.floor(hit_chance * 100) .. "%")
else
  print("[MISS] Accuracy: " .. math.floor(hit_chance * 100) .. "%")
end
```

---

### Evasion System

#### Evasion Calculation

```lua
function calculateEvasion(unit)
  local base_evasion = 0.1  -- 10% base
  
  -- Pilot skill bonus
  if unit.type == "craft" then
    base_evasion = base_evasion + (unit.pilot.evasion_skill * 0.05)
  end
  
  -- Status effects
  if unit:hasStatusEffect("disabled") then
    base_evasion = base_evasion * 0.5
  end
  
  -- Armor penalty (heavier = less evasion)
  base_evasion = base_evasion * (1.0 - unit.armor * 0.01)
  
  -- Stance modifications
  if unit:isDefending() then
    base_evasion = base_evasion * 0.7  -- -30% dodge in defense stance
  end
  
  -- Cap evasion
  base_evasion = math.max(base_evasion, 0.05)   -- Minimum 5%
  base_evasion = math.min(base_evasion, 0.50)   -- Maximum 50%
  
  return base_evasion
end
```

#### Dodge Sequence

```lua
-- Unit attempts to dodge
if target:canEvade() and random() < calculate_evasion(target) then
  print("[DODGE] " .. target.name .. " evades attack!")
  target:consumeAction("dodge")
  
  -- Successful dodge can trigger counter effects
  if target:hasPassiveEffect("riposte") then
    print("[COUNTER] Triggering riposte attack!")
    -- Target gets opportunity to attack back
  end
else
  print("[HIT] Attack connects!")
  -- Process damage
end
```

---

### Defense Stance System

**Defense Stance Mechanics:**

```lua
function activateDefenseStance(unit)
  unit.is_defending = true
  
  -- Armor bonus
  unit.armor_bonus = 5  -- +5 armor rating temporarily
  
  -- Evasion penalty
  unit.evasion_penalty = 0.3  -- -30% dodge chance
  
  -- Accuracy penalty (can't attack effectively)
  unit.accuracy_penalty = 0.5  -- -50% to player attacks
  
  -- Cannot move this turn
  unit.can_move = false
  
  print("[STANCE] " .. unit.name .. " takes defensive stance")
  print("  Armor: +" .. unit.armor_bonus)
  print("  Evasion: " .. math.floor((1 - unit.evasion_penalty) * 100) .. "%")
end

-- Damage reduction while defending
damage_vs_defending = base_damage * (1.0 - 0.15)  -- 15% less damage
```

---

### Range & Distance Mechanics

**Engagement Range Calculation:**

```lua
function getEngagementModifier(distance, weapon)
  if distance < weapon.range_min then
    return {engaged = false, reason = "too_close"}
  end
  
  if distance > weapon.range_max then
    return {engaged = false, reason = "out_of_range"}
  end
  
  -- Range effectiveness
  local effectiveness = 1.0
  
  if distance < weapon.range_optimal then
    -- Close range: less effective
    effectiveness = 0.9 - ((weapon.range_optimal - distance) * 0.05)
  elseif distance > weapon.range_optimal then
    -- Long range: accuracy penalty
    effectiveness = 1.0 - ((distance - weapon.range_optimal) * weapon.accuracy_penalty_distance)
  else
    -- Optimal range: full effectiveness
    effectiveness = 1.0
  end
  
  return {
    engaged = true,
    effectiveness = math.max(effectiveness, 0.5)
  }
end
```

---

### Weapon Tracking & Homing

**Ballistic Weapons (no tracking):**
- Must lead target manually
- Affected by evasion
- Simpler calculation
- Lower accuracy

**Beam Weapons (instant homing):**
- Straight line hit-scan
- Cannot be dodged
- Ignores distance (hits instantly)
- Cannot be blocked by obstacles
- Example: plasma cannons, energy weapons

**Homing Missiles (AI-guided):**
- Auto-track moving targets
- Base + tracking accuracy
- Cannot fully be dodged (50% evasion reduction)
- +10% base accuracy for missiles

```lua
function applyWeaponTracking(weapon, attacker, target, hit_chance)
  if weapon.tracking == "ballistic" then
    -- No modification - hit_chance as-is
    return hit_chance
    
  elseif weapon.tracking == "homing" then
    -- Missiles get +10% base hit, -50% evasion
    hit_chance = hit_chance + 0.1
    hit_chance = hit_chance * 1.5  -- Evasion 50% less effective
    
  elseif weapon.tracking == "beam" then
    -- Beams cannot miss - always track
    hit_chance = 0.95  -- 95% guaranteed (rarely miss)
  end
  
  return math.min(hit_chance, 0.95)
end
```

---

### Altitude Combat Modifiers

**Altitude Engagement Rules:**

```lua
altitude_combat_modifiers = {
  air = {
    accuracy_vs_air = 1.0,
    accuracy_vs_land = 0.8,    -- -20% accuracy hitting ground targets
    accuracy_vs_underwater = 0.5,  -- Can't effectively hit underwater
    evasion = 1.0,
    damage_taken = 1.0
  },
  
  land = {
    accuracy_vs_air = 0.9,     -- -10% hitting flying targets
    accuracy_vs_land = 1.0,
    accuracy_vs_underwater = 0.6,
    evasion = 0.7,             -- -30% evasion on ground
    damage_taken = 1.2         -- +20% incoming damage
  },
  
  underwater = {
    accuracy_vs_air = 0.0,     -- Cannot hit air units
    accuracy_vs_land = 0.6,
    accuracy_vs_underwater = 1.0,
    evasion = 1.2,             -- +20% evasion underwater
    damage_taken = 0.8         -- -20% incoming damage
  }
}
```

---

### Combat Phases Per Round

**Each Interception Round Consists Of:**

1. **Initiative Phase** (Determine turn order)
   - Craft goes first (player priority)
   - UFO acts second
   
2. **Action Phase**
   - Each combatant selects action (Fire, Evade, Defend, Special)
   - Resolve actions simultaneously or in sequence
   
3. **Resolution Phase**
   - Apply damage
   - Check for defeats
   - Apply status effects
   - Trigger counter-attacks
   
4. **End Phase**
   - Decrease status effect durations
   - Regenerate shields (if applicable)
   - Advance turn counter

**Example Round Execution:**
```lua
function executeRound(battle)
  print("=== ROUND " .. battle.current_round .. " ===")
  
  -- Phase 1: Initiative (craft first)
  battle.turn_order = {battle.craft_unit, battle.enemy_unit}
  
  for _, unit in ipairs(battle.turn_order) do
    if unit:isAlive() and not unit:isDestroyed() then
      print("[" .. unit:getName() .. " TURN]")
      
      -- Phase 2: Action Selection
      local action = selectAction(unit, battle)
      
      -- Resolve action
      if action == "fire" then
        local target = battle:getOpponent(unit)
        executeAttack(unit, target, unit:getEquippedWeapon())
      elseif action == "defend" then
        activateDefenseStance(unit)
      elseif action == "evade" then
        executeEvasion(unit)
      end
      
      -- Phase 3: Check defeat conditions
      if unit:isDestroyed() then
        print("[" .. unit:getName() .. " DESTROYED]")
        break
      end
    end
  end
  
  -- Phase 4: End phase
  for _, unit in ipairs(battle.turn_order) do
    updateStatusEffects(unit)
  end
  
  battle.current_round = battle.current_round + 1
end
```

---

### Advanced AI Combat Decisions

**UFO AI Decision Tree:**

```lua
function makeUFOAction(ufo_unit, craft_unit, battle)
  -- Priority 1: Critical health - attempt escape
  if ufo_unit:getHealthPercent() < 0.2 then
    print("[UFO] Critical health - attempting escape!")
    if battle:attemptFlee() then
      return "fled"
    end
  end
  
  -- Priority 2: High damage weapon ready - fire
  local best_weapon = selectBestWeapon(ufo_unit, craft_unit, battle.distance)
  if best_weapon and ufo_unit:canFireWeapon(best_weapon) then
    local hit_chance = calculateHitChance(ufo_unit, best_weapon, craft_unit, battle.distance)
    
    if hit_chance > 0.6 then
      print("[UFO] Firing " .. best_weapon.name .. " (Hit chance: " .. math.floor(hit_chance * 100) .. "%)")
      return "fire"
    end
  end
  
  -- Priority 3: Low ammo or weapon unavailable - defend
  if ufo_unit:getAmmo(best_weapon.id) < 2 or not ufo_unit:canFireWeapon(best_weapon) then
    print("[UFO] Activating defense!")
    return "defend"
  end
  
  -- Priority 4: Special ability available
  if ufo_unit:hasSpecialAbility() and random() < 0.4 then
    print("[UFO] Using special ability!")
    return "special"
  end
  
  -- Default: Fire if possible
  return "fire"
end
```

---

## Damage Calculation Formulas

### Hit Chance
```
Base Chance = Weapon Accuracy × Distance Modifier × Defender Evasion
Distance Modifier = 1.0 - (abs(distance - optimal_range) × penalty_per_hex)
Result = Clamp(Base Chance, min_accuracy, max_accuracy)
```

### Damage Calculation
```
Variance = 1.0 + ((Random - 0.5) × weapon_variance / 100)
Critical = Random < critical_chance
BaseDamage = weapon_damage_min + Random(0, weapon_damage_max - weapon_damage_min)
FinalDamage = (BaseDamage × Variance × (1.0 if not critical, critical_bonus if critical)) - ArmorReduction
```

---

## Altitude Layer Effects

| Altitude | Accuracy | Speed | Defense | Best Weapons |
|----------|----------|-------|---------|--------------|
| Air | Neutral | Normal | Reduced | Missiles, cannons |
| Land | +10% | -30% | +20% | All-terrain |
| Underwater | -20% | -50% | +50% | Specialized only |

---

## Status Effects in Combat

| Effect | Source | Duration | Impact |
|--------|--------|----------|--------|
| Stun | Stun missile | 1 turn | Cannot act |
| Disabled | Disable beam | 2 turns | Cannot fire weapons |
| Puncture | Puncture rounds | 3 turns | -20% fuel/turn |
| EMP | EMP missile | 3 turns | Electronics offline, no radar |
| Incendiary | Incendiary bomb | 2 turns | -5% dodge, +1 damage/turn |

---

## Integration Points

**Inputs from:**
- Geoscape (UFO positions, movement, detection)
- Crafts (combat stats, weapons, health, fuel)
- Interception Units (weapon systems, armor, evasion)
- Territory (altitude layers available by region)

**Outputs to:**
- Crafts (damage taken, experience gained, rewards)
- Research (tech progress from victories, alien analysis)
- Statistics (battle records, pilot achievements, kill counts)
- UI (battle HUD, weapon status displays, combat log)
- Economy (credits from victories, salvage)

**Dependencies:**
- Craft System (stats, health, weapons)
- UFO System (defensive stats, weapons)
- Combat Resolution (hit/damage calculations)
- Reward System (experience and loot)

---

## Error Handling

```lua
-- Insufficient weapons
if #craft_unit:getAvailableWeapons() == 0 then
  print("No weapons equipped - cannot engage!")
  return false
end

-- No ammunition
if craft_unit:getAmmo(weapon.id) < weapon.ammo_per_shot then
  print("Insufficient ammunition for " .. weapon.name)
  return false
end

-- Out of range
if interception:calculateDistance(attacker, defender) > weapon.range_max then
  print("Target out of range")
  print("Weapon range: " .. weapon.range_max)
  return false
end

-- Unit destroyed
if ufo_unit:isDestroyed() then
  print("UFO destroyed - battle won!")
  interception:checkVictoryConditions()
end

-- Critical damage to craft
if craft_unit:getHealthPercent() < 0.05 then
  print("Craft critical! Emergency systems activating.")
  -- Craft should attempt to flee
  interception:performEvasion(craft_unit)
end

-- Time limit exceeded
if interception:getCurrentTurn() > interception.max_turns then
  print("Time limit exceeded - engagement disengaging")
  interception:disengage()
end
```

---

# UFO Types & Combat Stats

### UFO Class Matrix

| UFO Type | Armor | Speed | Weapons | Special | Threat |
|----------|-------|-------|---------|---------|--------|
| **Scout** | 20 | 8 | Plasma Cannon | Fast | Low |
| **Fighter** | 40 | 6 | Plasma + Missile | Maneuverable | Medium |
| **Transport** | 50 | 4 | Limited | Cargo capacity | Medium |
| **Battleship** | 80 | 3 | Heavy arsenal | Area attacks | High |
| **Harvester** | 60 | 5 | Plasma | Drone deployment | High |

### UFO Stat Details

```lua
ufo_types = {
  scout = {
    hp = 80,
    armor = 20,
    speed = 8,
    weapons = {"plasma_cannon"},
    special_abilities = {"evasive_maneuvers"},
    crew_capacity = 4,
    detection_difficulty = 0.8
  },
  fighter = {
    hp = 120,
    armor = 40,
    speed = 6,
    weapons = {"plasma_cannon", "homing_missile"},
    special_abilities = {"emergency_boost"},
    crew_capacity = 2,
    detection_difficulty = 0.9
  },
  transport = {
    hp = 150,
    armor = 50,
    speed = 4,
    weapons = {},
    special_abilities = {"cloak", "teleport_alien_squad"},
    crew_capacity = 12,
    detection_difficulty = 1.2
  },
  battleship = {
    hp = 250,
    armor = 80,
    speed = 3,
    weapons = {"heavy_plasma", "missile_array", "pulse_cannon"},
    special_abilities = {"shield_generator", "area_attack"},
    crew_capacity = 20,
    detection_difficulty = 0.5  -- Easier to detect due to size
  }
}
```

---

## Interception Weapon Systems

### Player Craft Weapons

| Weapon | Damage | Range | Accuracy | Ammo | Cost |
|--------|--------|-------|----------|------|------|
| **Cannon** | 20 | 30 | 70% | Unlimited | Fuel |
| **Missiles** | 40 | 50 | 60% | 12 | $5000 |
| **Plasma** | 35 | 40 | 65% | 20 | Research |
| **Laser** | 25 | 45 | 75% | 30 | Research |

### UFO Weapons

| Weapon | Damage | Range | Frequency |
|--------|--------|-------|-----------|
| **Plasma Cannon** | 30 | 35 | Fast |
| **Homing Missile** | 45 | 60 | Slow |
| **Pulse Cannon** | 25 | 40 | Very Fast |

---

## Interception Combat Algorithm

**Combat Turn Structure:**
```
1. Initiative Phase
   - Both sides roll for turn order
   - Random element (d10) + speed modifiers

2. Attack Phase
   - Attacker selects weapon and target
   - Roll hit (range, accuracy, dodging)
   - Calculate damage if hit

3. Evasion Phase
   - Defender may perform evasion maneuver
   - Costs fuel
   - Reduces hit chance by 20%

4. Damage Resolution
   - Apply armor reduction
   - Update HP
   - Check for disabled systems

5. End Turn
   - Next unit acts
```
