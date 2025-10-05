# Stats

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Combat Stats](#combat-stats)
  - [Durability Stats](#durability-stats)
  - [Mobility Stats](#mobility-stats)
  - [Psyche Stats](#psyche-stats)
  - [Perception Stats](#perception-stats)
  - [Miscellaneous Stats](#miscellaneous-stats)
  - [Stat Interactions and Calculations](#stat-interactions-and-calculations)
  - [Stat Progression and Growth](#stat-progression-and-growth)
- [Examples](#examples)
  - [Sniper Specialization](#sniper-specialization)
  - [Heavy Weapons Specialist](#heavy-weapons-specialist)
  - [Reconnaissance Scout](#reconnaissance-scout)
  - [Psionic Operative](#psionic-operative)
  - [Combat Effectiveness Calculation](#combat-effectiveness-calculation)
  - [Movement Cost Analysis](#movement-cost-analysis)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview
The Stats system defines core numeric attributes that determine unit capabilities across all gameplay systems, using a **human-typical range of 6-12** (junior to master level) as the baseline. This scaling derives from XCOM values divided by 5 for manageable numbers while maintaining tactical depth. Other races and factions may have stats ranging from 4 (weak creatures like rats) to 16-20 (superhuman or alien entities). All stats use constrained integer ranges for predictable balance and clear trade-offs, with all effects configurable through data files.

**Critical Stat Ranges:**
- **Human Standard**: 6 (junior/recruit) to 12 (master/elite) for all primary stats
- **Other Species**: 4 (weak) to 20 (superhuman) depending on race and faction
- **Morale**: Starts at 10 at battle start, can go down during combat
- **Bravery**: 6-12 range, determines maximum morale test pass rate (6 = 60%, 12 = 120% always passes)

Stats are categorized into combat (Aim, Melee), durability (HP, Energy, Strength), mobility (AP, Speed, React), psyche (Will, Psi, Sanity, Morale, Bravery), perception (Sight, Sense, Cover), and miscellaneous (Size, Armor) attributes. Each stat contributes to specific gameplay mechanics with clear mathematical relationships, enabling tactical depth and strategic planning.

## Mechanics
### Combat Stats
Aim determines ranged accuracy with direct modifiers to hit probability, combining with weapon characteristics and range effects. Melee governs close-quarters effectiveness, affecting both attack accuracy and damage output. These stats enable specialization between ranged precision and close-combat prowess.

### Durability Stats
Life (HP) represents vitality pool with damage absorption and wound accumulation mechanics. Energy serves as tactical resource for abilities and enhanced actions, regenerating between turns. Strength amplifies melee damage, extends throw ranges, and determines equipment compatibility through binary fit checks.

### Mobility Stats
Action Points (AP) provide per-turn budget for movement, attacks, and abilities, creating action economy. Speed determines movement distance per AP with terrain modifiers. React influences reaction fire probability and evasion capabilities, enabling defensive tactics and overwatch mechanics.

### Psyche Stats
Will provides resistance to morale effects, panic, and psionic manipulation. Psi governs psionic potency and ability access. Sanity tracks persistent mental resilience across campaigns. Morale represents dynamic psychological state initialized from class baselines and modified by mission events.

### Perception Stats
Sight defines direct vision radius affected by illumination and occlusion. Sense enables omni-directional passive detection for auditory awareness. Cover provides passive concealment modifiers reducing detectability. These stats create information asymmetry and enable reconnaissance roles.

### Miscellaneous Stats
Size categorizes physical footprint affecting hitability, area effect exposure, and navigation constraints. Armor provides flat damage mitigation applied before HP reduction. These attributes create physical and defensive specialization options.

### Stat Interactions and Calculations
Stats combine multiplicatively for complex outcomes: hit chance incorporates Aim, weapon accuracy, range, and cover; movement efficiency factors Speed, terrain, and AP costs; damage resistance layers Armor, type effectiveness, and HP pools. All calculations use deterministic formulas with seeded random elements for reproducibility.

### Stat Progression and Growth
Stats improve through experience accumulation with level thresholds and point allocation. Class bonuses encourage specialization while derived calculations provide clear value feedback. Growth maintains small integer ranges to prevent extreme scaling.

## Examples
### Sniper Specialization
Unit with Aim 12, Sight 20, Speed 6 trades mobility for exceptional ranged precision. Weapon synergies and range calculations combine with aim modifier for reliable long-range engagement, enabling marksman roles with reduced tactical flexibility.

### Heavy Weapons Specialist
Unit with Strength 15, HP 12, Speed 5 prioritizes damage output and durability. Equipment compatibility and melee effectiveness create frontline combat capability with heavy weapon proficiency, sacrificing mobility for raw power.

### Reconnaissance Scout
Unit with Speed 14, Sight 18, Sense 5, Cover 8 emphasizes mobility and detection. Movement efficiency and stealth modifiers enable scouting and flanking tactics with superior situational awareness.

### Psionic Operative
Unit with Psi 12, Will 10, Sanity 8 focuses on mental abilities. Psionic potency enables mind control and telekinetic effects while mental resistance provides defense against similar capabilities.

### Combat Effectiveness Calculation
Attacker with Aim 12 firing at range 8 with weapon accuracy 60% and defender React 8 behind cover 3. Hit chance combines aim bonus (+60%), applies range penalty (-20%), subtracts react modifier (-16%), reduces for cover (-90%), yielding 34% final probability.

### Movement Cost Analysis
Unit with Speed 10 moving 6 tiles through rough terrain expends base cost 6, divided by speed modifier 0.6, multiplied by terrain penalty 1.5, resulting in 9 AP for terrain-adjusted movement.

## Where Stats Matter: System Integration

### Stat → System Mapping

This section provides a comprehensive cross-reference showing where each stat is used across all game systems.

#### **Aim (Ranged Accuracy)**

| System | Usage | Formula/Calculation |
|--------|-------|-------------------|
| **Combat** | Base hit chance | Hit% = BaseAccuracy + (Aim - 50) |
| **Overwatch** | Reaction fire accuracy | Reaction% = Hit% × 0.7 |
| **Suppression** | Suppressive fire effectiveness | Suppression = Aim / 2 (min 10%) |
| **Grenade Throwing** | Scatter reduction | Scatter = Max(0, Distance - (Aim / 5)) |
| **Ability Unlocks** | Required for sniper abilities | Snap Shot requires Aim ≥ 60 |

**Key Files:**
- `../battlescape/Combat_Mechanics.md` - Hit chance calculations
- `../battlescape/Overwatch.md` - Reaction fire mechanics
- `Progression.md` - Aim-based ability requirements

#### **Melee (Close Combat)**

| System | Usage | Formula/Calculation |
|--------|-------|-------------------|
| **Close Combat** | Melee attack accuracy | Hit% = Melee + WeaponBonus - TargetReact |
| **Melee Damage** | Bonus damage | Damage = WeaponDamage + (Melee / 5) |
| **Counterattacks** | Defensive melee strikes | Counter% = Melee × 0.5 |
| **Grappling** | Stun/capture chance | Grapple% = Melee - TargetStrength |

**Key Files:**
- `../battlescape/Melee_Combat.md` - Close combat system
- `../battlescape/Status_Effects.md` - Stun mechanics

#### **Life/HP (Hit Points)**

| System | Usage | Formula/Calculation |
|--------|-------|-------------------|
| **Damage Absorption** | Damage reduction | HP -= Max(1, Damage - Armor) |
| **Wound System** | Injury severity | Light (<33% HP), Serious (<66%), Critical (0) |
| **Morale** | Panic threshold | PanicCheck when HP < 50% |
| **Bleeding** | HP loss per turn | HP -= 2 per turn if bleeding |
| **Size Modifier** | Effective HP pool | Larger units = more HP |

**Key Files:**
- `../battlescape/Combat_Mechanics.md` - Damage calculations
- `../battlescape/Wounds.md` - Injury system
- `../battlescape/Morale.md` - Psychological effects

#### **Energy (Ability Resource)**

| System | Usage | Formula/Calculation |
|--------|-------|-------------------|
| **Abilities** | Ability activation cost | Must have Energy ≥ AbilityCost |
| **Regeneration** | Per-turn recovery | Energy += (MaxEnergy / 10) per turn |
| **Sprint** | Enhanced movement | Sprint costs 3 energy, +50% movement |
| **Special Attacks** | Power attack costs | Heavy attack: -5 energy, +50% damage |

**Key Files:**
- `../core/Energy_Systems.md` - Complete energy mechanics
- `Progression.md` - Ability energy costs

#### **Strength (Physical Power)**

| System | Usage | Formula/Calculation |
|--------|-------|-------------------|
| **Carrying Capacity** | Encumbrance limit | MaxWeight = Strength × 2 |
| **Melee Damage** | Bonus melee damage | Damage += Strength / 4 |
| **Throw Range** | Item throwing distance | Range = BaseRange + (Strength / 3) |
| **Equipment Requirements** | Heavy weapon access | Heavy weapons require Strength ≥ 50 |
| **Grapple Defense** | Resist grapples | Defense = Strength vs attacker Melee |

**Key Files:**
- `../core/Capacity_Systems.md` - Encumbrance mechanics
- `../items/Equipment.md` - Equipment requirements
- `../battlescape/Melee_Combat.md` - Strength damage bonus

#### **Action Points (AP / Time Units)**

| System | Usage | Formula/Calculation |
|--------|-------|-------------------|
| **Movement** | Tile movement cost | AP per tile = 1 × terrain_modifier |
| **Attacks** | Shooting AP cost | Snap: 2 AP, Aimed: 3 AP, Auto: 4 AP |
| **Abilities** | Ability activation | Varies per ability (1-5 AP) |
| **Items** | Using items | Medkit: 2 AP, Grenade: 3 AP |
| **Reloading** | Weapon reload | Reload: 2-3 AP depending on weapon |

**Key Files:**
- `../core/Action_Economy.md` - Complete AP system
- `../battlescape/Combat_Mechanics.md` - Action costs
- `Progression.md` - AP stat growth

#### **Speed (Movement Efficiency)**

| System | Usage | Formula/Calculation |
|--------|-------|-------------------|
| **Movement Distance** | Tiles per AP | Distance = Speed × AP / terrain_modifier |
| **Initiative** | Turn order | Initiative = Speed + React + d20 |
| **Dodge Chance** | Evade attacks | Dodge% = Speed / 2 (when moving) |
| **Chase/Pursuit** | Catch fleeing units | Can catch if Speed > target Speed |

**Key Files:**
- `../core/Action_Economy.md` - Movement formulas
- `../battlescape/Initiative.md` - Turn order calculation
- `../battlescape/Combat_Mechanics.md` - Dodge mechanics

#### **React (Reactions/Reflexes)**

| System | Usage | Formula/Calculation |
|--------|-------|-------------------|
| **Overwatch** | Reaction fire trigger | React% = (React / 100) × WeaponSpeed |
| **Initiative** | Turn order contribution | Initiative = Speed + React + d20 |
| **Evasion** | Being hit penalty | Attacker accuracy -= React / 5 |
| **Interrupt** | Enemy action interrupt | Interrupt% = React / 2 |

**Key Files:**
- `../battlescape/Overwatch.md` - Reaction fire system
- `../battlescape/Initiative.md` - Initiative calculation
- `../battlescape/Combat_Mechanics.md` - Evasion mechanics

#### **Will (Mental Fortitude)**

| System | Usage | Formula/Calculation |
|--------|-------|-------------------|
| **Panic Resistance** | Resist panic | PanicCheck = d100 vs Will |
| **Psi Defense** | Resist psionics | PsiDefense = Will + PsiStrength |
| **Morale** | Psychological stability | Morale threshold = Will |
| **Status Resistance** | Resist fear/mind control | Resistance = Will |

**Key Files:**
- `../battlescape/Morale.md` - Panic and morale system
- `../battlescape/Psionics.md` - Psionic resistance
- `../battlescape/Status_Effects.md` - Mental status effects

#### **Psi (Psionic Power)**

| System | Usage | Formula/Calculation |
|--------|-------|-------------------|
| **Psi Abilities** | Mind control, panic | Success% = Psi - TargetWill |
| **Psi Attack** | Psionic damage | Damage = Psi / 5 |
| **Psi Detection** | Sense psionics | Range = Psi / 2 tiles |
| **Psi Training** | Learning speed | TrainingSpeed = Psi / 10 days |

**Key Files:**
- `../battlescape/Psionics.md` - Complete psionic system
- `Progression.md` - Psi stat development

#### **Sanity (Long-term Mental Health)**

| System | Usage | Formula/Calculation |
|--------|-------|-------------------|
| **Campaign Stress** | Permanent psychological damage | Sanity loss from critical events |
| **PTSD Risk** | Trauma accumulation | PTSD if Sanity < 30 |
| **Recovery Rate** | Mental health recovery | Days = (100 - Sanity) / 5 |
| **Max Will** | Will cap modifier | MaxWill = BaseWill + (Sanity / 10) |

**Key Files:**
- `../battlescape/Sanity.md` - Sanity system
- `../battlescape/Morale.md` - Related to Will
- `Progression.md` - Long-term effects

#### **Morale (Dynamic Psychological State)**

| System | Usage | Formula/Calculation |
|--------|-------|-------------------|
| **Panic Check** | Trigger panic | Check when Morale < Will |
| **Suppression** | Morale damage | Morale -= Suppression value |
| **Witnessing Death** | Morale loss | -10 morale per ally death |
| **Victory Bonus** | Morale gain | +5 morale per kill |

**Key Files:**
- `../battlescape/Morale.md` - Complete morale system
- `../battlescape/Status_Effects.md` - Panic effects
- `../battlescape/Combat_Mechanics.md` - Morale events

#### **Sight (Vision Range)**

| System | Usage | Formula/Calculation |
|--------|-------|-------------------|
| **Vision Radius** | Visible area | Radius = Sight tiles (with fog of war) |
| **Spotting** | Enemy detection | Spot% = (Sight / 20) × Lighting |
| **Overwatch Range** | Max reaction distance | MaxRange = Min(WeaponRange, Sight) |
| **Targeting** | Accuracy bonus at range | Accuracy bonus if target < Sight |

**Key Files:**
- `../battlescape/Detection_System.md` - Vision and detection
- `../battlescape/Fog_of_War.md` - Vision mechanics
- `../technical/Line_of_Sight.md` - LOS algorithm

#### **Sense (Passive Detection)**

| System | Usage | Formula/Calculation |
|--------|-------|-------------------|
| **Audio Detection** | Hear enemy movement | Range = Sense tiles (omnidirectional) |
| **Ambush Awareness** | Detect hidden enemies | Awareness% = Sense / 2 |
| **Flanking Alert** | Detect flankers | Alert if enemy within Sense tiles |
| **Scout Role** | Recon effectiveness | Scout bonus = Sense + Sight |

**Key Files:**
- `../battlescape/Detection_System.md` - Detection mechanics
- `../battlescape/Stealth.md` - Counter-stealth

#### **Cover (Stealth/Concealment)**

| System | Usage | Formula/Calculation |
|--------|-------|-------------------|
| **Concealment** | Detection penalty | DetectionChance -= Cover% |
| **Ambush Setup** | Surprise attack bonus | SurpriseBonus = Cover / 2 |
| **Stealth Movement** | Move undetected | StealthMove% = Cover |
| **Flanking** | Flanking effectiveness | FlankBonus = Cover + Speed |

**Key Files:**
- `../battlescape/Cover.md` - Cover and concealment
- `../battlescape/Stealth.md` - Stealth mechanics
- `../battlescape/Detection_System.md` - Detection vs stealth

#### **Size (Physical Footprint)**

| System | Usage | Formula/Calculation |
|--------|-------|-------------------|
| **Hit Chance** | Target size modifier | Accuracy += (TargetSize - 1) × 10% |
| **Area Effect** | Blast radius exposure | Size 2+ takes +50% AoE damage |
| **Navigation** | Tile passage | Size 2+ cannot use 1-tile passages |
| **Cover Effectiveness** | Cover scaling | Half cover = Size × 50% protection |
| **Craft Capacity** | Space in transport | Craft space = Size units |

**Key Files:**
- `../battlescape/Combat_Mechanics.md` - Size modifiers
- `../core/Capacity_Systems.md` - Craft space calculations
- `../battlescape/Explosions.md` - AoE size effects

#### **Armor (Damage Reduction)**

| System | Usage | Formula/Calculation |
|--------|-------|-------------------|
| **Damage Mitigation** | Flat damage reduction | Damage = Max(1, RawDamage - Armor) |
| **Armor Piercing** | AP ammo effectiveness | Damage = RawDamage - (Armor × (1 - AP%)) |
| **Armor Types** | Damage type resistance | Armor × TypeModifier |
| **Armor Degradation** | Per-hit wear | Armor -= 1 per 50 damage taken |

**Key Files:**
- `../battlescape/Combat_Mechanics.md` - Damage calculations
- `../items/Armor.md` - Armor equipment
- `../items/Weapon_Comparisons.md` - AP mechanics

### Derived Stat Calculations

#### Hit Chance (Combat Accuracy)

```lua
function calculate_hit_chance(attacker, target, weapon, range, cover)
    local base = weapon.accuracy
    local aim_bonus = attacker.stats.aim - 50  -- 50 = average
    local range_penalty = (range - weapon.optimal_range) × 2
    local react_penalty = target.stats.react / 5
    local cover_penalty = cover.value
    
    local hit_chance = base + aim_bonus - range_penalty - react_penalty - cover_penalty
    
    return math.max(5, math.min(95, hit_chance))  -- Cap at 5-95%
end
```

**Relevant Sections:** Aim, React, Cover

#### Encumbrance (Carrying Capacity)

```lua
function calculate_encumbrance(unit)
    local max_weight = unit.stats.strength × 2
    local current_weight = calculate_total_equipment_weight(unit)
    
    if current_weight > max_weight then
        -- Over capacity: movement penalty
        local penalty = (current_weight - max_weight) / max_weight
        unit.speed_modifier = 1.0 - penalty
    else
        unit.speed_modifier = 1.0
    end
end
```

**Relevant Sections:** Strength, Speed

#### Movement Distance

```lua
function calculate_movement_distance(unit, ap_spent)
    local base_distance = unit.stats.speed × ap_spent
    local terrain_modifier = get_terrain_modifier(unit.position)
    local encumbrance_modifier = unit.speed_modifier or 1.0
    
    return math.floor(base_distance / terrain_modifier × encumbrance_modifier)
end
```

**Relevant Sections:** Speed, AP, Strength (via encumbrance)

#### Initiative Order

```lua
function calculate_initiative(unit)
    local speed_component = unit.stats.speed
    local react_component = unit.stats.react
    local randomness = love.math.random(1, 20)
    
    return speed_component + react_component + randomness
end
```

**Relevant Sections:** Speed, React

## Related Wiki Pages

- [Classes.md](../units/Classes.md) - Stat growth and specialization
- [Progression.md](Progression.md) - XP, ranks, and stat growth
- [Wounds.md](../battlescape/Wounds.md) - Durability and health effects
- [Psionics.md](../battlescape/Psionics.md) - Psyche and mental stat usage
- [Accuracy at Range.md](../battlescape/Accuracy%20at%20Range.md) - Combat stat applications
- [Action Economy.md](../core/Action_Economy.md) - AP and mobility system
- [Sanity.md](../battlescape/Sanity.md) - Mental health and psyche stats
- [Morale.md](../battlescape/Morale.md) - Morale and psychological stats
- [Combat Mechanics.md](../battlescape/Combat_Mechanics.md) - How stats affect combat
- [Capacity Systems.md](../core/Capacity_Systems.md) - Encumbrance and carrying
- [Energy Systems.md](../core/Energy_Systems.md) - Energy stat usage
- [Units.md](../units/Units.md) - Stat definitions and base values

## References to Existing Games and Mechanics

- **X-COM Series**: Unit stat system and progression
- **Fire Emblem Series**: Character stat growth and development
- **Final Fantasy Tactics**: Job stat system and advancement
- **Advance Wars**: CO stat system and abilities
- **Tactics Ogre**: Character stat progression and growth
- **Disgaea Series**: Stat system and level progression
- **Persona Series**: Social stat development and growth
- **Mass Effect Series**: Character stat system and specialization
- **Dragon Age Series**: Attribute system and skill progression
- **Fallout Series**: SPECIAL stat system and character building

