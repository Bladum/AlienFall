# Trait System Specification

> **Status**: Authoritative Specification
> **Last Updated**: 2025-10-31
> **Related Systems**: Units.md, Progression.md, Balance.md
> **Purpose**: Complete definition of character traits, acquisition, interactions, and balance

## Overview

The trait system provides character differentiation and specialization for X-COM units. Traits are permanent modifiers that affect stats, abilities, and mechanics, creating unique characters with strengths and weaknesses.

**Core Principles**:
- Traits create meaningful character differences
- Balance prevents overpowered combinations
- Acquisition methods encourage different playstyles
- Conflicts prevent contradictory traits

---

## 1. Trait Architecture

### Trait Definition

A trait is a permanent character modifier with the following properties:

```lua
trait = {
    id = "quick_reflexes",           -- Unique identifier
    name = "Quick Reflexes",         -- Display name
    description = "+2 Reaction stat", -- Effect description
    type = "positive",               -- positive/negative/neutral
    category = "combat",             -- combat/physical/mental/support
    balance_cost = 2,                -- Balance point value
    acquisition = "birth",           -- birth/achievement/perk
    requirements = {},               -- Prerequisites
    conflicts = {"slow_reflexes"},   -- Incompatible traits
    synergies = {"steady_hand"},     -- Beneficial combinations
    effects = {                      -- Stat/ability modifiers
        reaction = 2
    }
}
```

### Trait Categories

**Combat Traits**: Modify accuracy, damage, and combat effectiveness
**Physical Traits**: Affect strength, speed, and physical capabilities
**Mental Traits**: Modify morale, sanity, and psychological resilience
**Support Traits**: Provide utility, healing, and squad support abilities

### Trait Scope

**What Traits Affect**:
- Base stats (Aim, Melee, Reaction, Speed, Bravery, Sanity, Strength)
- Combat mechanics (accuracy, damage, critical hits)
- Unit abilities (healing, repairs, special actions)
- Morale and sanity (recovery rates, panic resistance)
- Equipment interactions (carry capacity, reload speed)

**What Traits Don't Affect**:
- Base health (modified by equipment and injuries)
- Unit class (Soldier remains Soldier)
- Rank progression (earned through XP)
- Base attributes (modified by training)

---

## 2. Trait Acquisition Methods

### Method 1: Birth Traits (Recruitment)

**When Assigned**: During unit recruitment character generation

**Generation Process**:
```lua
function generateBirthTraits(unit)
    local traits = {}
    local slots = getTraitSlots(unit.rank)  -- Usually 2 for recruits

    for i = 1, slots do
        local roll = math.random(1, 100)

        if roll <= 30 then
            -- Positive trait (30% chance)
            local trait = selectRandomTrait("positive", unit.class)
            if not hasConflicts(trait, traits) then
                table.insert(traits, trait)
            end
        elseif roll <= 50 then
            -- Negative trait (20% chance)
            local trait = selectRandomTrait("negative", unit.class)
            if not hasConflicts(trait, traits) then
                table.insert(traits, trait)
            end
        end
        -- 50% chance for no trait in this slot
    end

    return traits
end
```

**Probability Distribution**:
- Positive traits: 30% chance per slot
- Negative traits: 20% chance per slot
- No trait: 50% chance per slot

**Typical Recruit Result**:
- 40% chance: 1 positive trait
- 20% chance: 1 negative trait
- 40% chance: No traits

### Method 2: Achievement Traits (Progression)

**When Assigned**: Through gameplay accomplishments at ranks 3-8

**Achievement Requirements**:
```lua
achievement_traits = {
    marksman = {
        name = "Marksman",
        requirement = "Kill 20 enemies with rifle",
        rank_min = 3,
        effects = {aim = 1, weapon_accuracy = 1}
    },
    unbreakable_bond = {
        name = "Unbreakable Bond",
        requirement = "Complete 5 missions without casualty",
        rank_min = 4,
        effects = {morale_recovery = 2}
    },
    field_surgeon = {
        name = "Field Surgeon",
        requirement = "Heal 100+ damage over career",
        rank_min = 5,
        effects = {healing_efficiency = 50}
    }
}
```

**Unlock Tiers**:
- Rank 3-4: Basic achievements (easier requirements)
- Rank 5-6: Advanced achievements (moderate requirements)
- Rank 7+: Legendary achievements (difficult requirements)

### Method 3: Perk Traits (Late Game)

**When Assigned**: Purchased at rank 7+ with special requirements

**Perk System**:
```lua
perk_traits = {
    superhuman_strength = {
        name = "Superhuman Strength",
        cost = 500000,  -- XP cost
        requirements = {rank = 8, strength = 15},
        effects = {strength = 3},
        description = "Permanently increases Strength by 3"
    },
    battle_hardened = {
        name = "Battle Hardened",
        cost = 750000,
        requirements = {missions_completed = 100},
        effects = {suppression_immunity = true},
        description = "Immune to suppression effects"
    }
}
```

---

## 3. Trait Slots and Limits

### Slot Progression by Rank

```lua
trait_slots_by_rank = {
    [0] = 2,  -- Recruit (birth only)
    [1] = 2,  -- Rank 1-3
    [4] = 3,  -- Rank 4-5 (+1 achievement slot)
    [6] = 4,  -- Rank 6-7 (+2 achievement slots)
    [8] = 5   -- Rank 8+ (+3 achievement + perk slot)
}
```

**Slot Usage**:
- Birth traits: Always fill available slots at recruitment
- Achievement traits: Unlock additional slots as rank increases
- Perk traits: Replace or add to existing slots at high ranks

### Stacking Limits

**Same Stat Bonuses**: Maximum +3 total from traits
```lua
function applyTraitBonus(unit, stat, bonus)
    local current_bonus = unit.trait_bonuses[stat] or 0
    local new_total = current_bonus + bonus

    -- Cap at +3 for any single stat
    unit.trait_bonuses[stat] = math.min(new_total, 3)
end
```

**Examples**:
- Quick Reflexes (+2 Reaction) + Genetic Gift (+2 Reaction) = +3 Reaction (capped)
- Marksman (+1 Aim) + Sharp Eyes (+1 Aim) = +2 Aim (OK, under cap)

---

## 4. Trait Removal and Modification

### Respec System (Achievement Traits)

**Availability**: Rank 5+ units can respec achievement traits

**Cost**: 100,000 XP per trait removal

**Process**:
```lua
function respecTrait(unit, traitId)
    if unit.rank < 5 then return false, "Rank too low" end
    if unit.xp < 100000 then return false, "Insufficient XP" end

    -- Remove trait
    removeTrait(unit, traitId)

    -- Consume XP
    unit.xp = unit.xp - 100000

    -- Free up slot
    unit.trait_slots_used = unit.trait_slots_used - 1

    return true
end
```

### Perk Swapping (Perk Traits)

**Availability**: Rank 8+ units can swap perks

**Cost**: 1 week of training facility time

**Process**:
```lua
function swapPerk(unit, oldPerkId, newPerkId)
    if unit.rank < 8 then return false, "Rank too low" end

    -- Check if new perk conflicts
    if hasConflicts(newPerkId, unit.traits) then
        return false, "New perk conflicts with existing traits"
    end

    -- Remove old perk
    removeTrait(unit, oldPerkId)

    -- Add new perk
    addTrait(unit, newPerkId)

    -- Consume training time
    unit.training_time = unit.training_time + (7 * 24)  -- 1 week in hours

    return true
end
```

### Permanent Traits

**Cannot Be Removed**:
- Birth traits (fundamental character aspects)
- Injury traits ("Scarred", "Shell-shocked")
- Permanent damage from incidents

**Can Be Mitigated**:
- Medical procedures reduce penalties
- Training compensates for weaknesses
- Equipment offsets trait limitations

---

## 5. Trait Conflicts and Synergies

### Conflict Matrix

**Cannot Have Both** (contradictory traits):

```
Conflicting Trait Pairs:
Marathon Runner ↔ Disabled (physical contradiction)
Sharp Eyes ↔ Poor Vision (perception contradiction)
Natural Medic ↔ Hemophobic (specialization contradiction)
Commanding Presence ↔ Loner (personality contradiction)
Strong Build ↔ Weak Lungs (physical contradiction)
```

**Conflict Resolution**:
```lua
function checkTraitConflicts(newTrait, existingTraits)
    for _, existing in ipairs(existingTraits) do
        if newTrait.conflicts[existing.id] or existing.conflicts[newTrait.id] then
            return true, string.format("%s conflicts with %s",
                newTrait.name, existing.name)
        end
    end
    return false
end
```

### Synergy Matrix

**Beneficial Combinations** (bonus effects):

```
Synergistic Trait Pairs:
Marksman + Steady Hand → +3% accuracy bonus
Natural Medic + Healer → +1 healing per bandage
Leader + Commanding Officer → +2 nearby unit morale
Marathon Runner + Scout → +1 movement speed
Quick Reflexes + Gymnast → +2 dodge chance
```

**Synergy Application**:
```lua
function applySynergies(unit)
    local synergies = {}

    -- Check for synergy pairs
    if hasTrait(unit, "marksman") and hasTrait(unit, "steady_hand") then
        synergies.accuracy_bonus = (synergies.accuracy_bonus or 0) + 3
    end

    if hasTrait(unit, "natural_medic") and hasTrait(unit, "healer") then
        synergies.healing_bonus = (synergies.healing_bonus or 0) + 1
    end

    -- Apply synergy bonuses
    for effect, bonus in pairs(synergies) do
        applyEffect(unit, effect, bonus)
    end
end
```

---

## 6. Balance System

### Balance Cost Values

Every trait has a balance cost that contributes to unit power level:

**Positive Traits**:
```
Trait Name              Cost    Category
Quick Reflexes          +2      Combat
Sharp Eyes              +1      Combat
Steady Hand             +1      Combat
Marksman                +2      Combat
Strong Build            +2      Physical
Marathon Runner         +2      Physical
Iron Will               +2      Mental
Natural Medic           +1      Support
Superhuman Strength     +3      Rare
```

**Negative Traits** (offset positives):
```
Trait Name              Cost    Category
Weak Lungs              -1      Physical
Poor Vision             -1      Combat
Clumsy                  -1      Physical
Hemophobic              -2      Mental
Loud                    -1      Support
```

### Balance Enforcement

**Per-Unit Limits**:
- Maximum total balance cost: +3
- Minimum balance cost: -1 (some penalty required)
- Prevents overpowered trait combinations

**Enforcement Code**:
```lua
function validateTraitBalance(unit)
    local total_cost = 0

    for _, trait in ipairs(unit.traits) do
        total_cost = total_cost + trait.balance_cost
    end

    if total_cost > 3 then
        return false, "Trait combination too powerful (cost: " .. total_cost .. " > 3)"
    end

    if total_cost < -1 then
        return false, "Too many negative traits (cost: " .. total_cost .. " < -1)"
    end

    return true
end
```

---

## 7. Comprehensive Trait List

### Combat Traits

```
ID                      Name                    Effect                          Cost    Acquisition
--------------------------------------------------------------------------------------------------
quick_reflexes          Quick Reflexes          +2 Reaction                     +2      Birth
sharp_eyes              Sharp Eyes              +1 Aim                          +1      Birth
steady_hand             Steady Hand             +5% accuracy                    +1      Birth
marksman                Marksman                +1 Aim, +1 weapon accuracy      +2      Achievement
close_combat_expert     Close Combat Expert     +2 Melee, +2 damage            +2      Achievement
deadly_aim              Deadly Aim              +10% critical chance           +2      Achievement
```

### Physical Traits

```
ID                      Name                    Effect                          Cost    Acquisition
--------------------------------------------------------------------------------------------------
strong_build            Strong Build            +2 Strength                     +2      Birth
marathon_runner         Marathon Runner         +2 Speed                        +2      Birth
heavy_build             Heavy Build             +1 STR, +1 Health              +2      Birth
gymnast                 Gymnast                 +1 climbing, +2 jump distance   +1      Achievement
superhuman_strength     Superhuman Strength     +3 STR permanently             +3      Perk
lightweight             Lightweight             +1 Speed, +1 carry capacity     +1      Birth
```

### Mental Traits

```
ID                      Name                    Effect                          Cost    Acquisition
--------------------------------------------------------------------------------------------------
iron_will               Iron Will               +2 Bravery                      +2      Birth
calm_under_pressure     Calm Under Pressure     +1 Sanity, -1 panic chance     +1      Birth
natural_leader          Natural Leader          +1 nearby unit morale          +1      Birth
battle_hardened         Battle Hardened         Immune to suppression          +2      Achievement
commanding_officer      Commanding Officer      +2 nearby unit morale          +3      Perk
psychic_resistance      Psychic Resistance      +2 resistance to psi attacks   +2      Achievement
```

### Support Traits

```
ID                      Name                    Effect                          Cost    Acquisition
--------------------------------------------------------------------------------------------------
natural_medic           Natural Medic           +1 heal per bandage            +1      Birth
healer                  Healer                  +50% recovery speed             +2      Achievement
resourceful             Resourceful             +1 extra ammo per clip         +1      Birth
hacker                  Hacker                  +1 hacking success chance       +1      Birth
field_engineer          Field Engineer          Can repair equipment           +2      Achievement
demolitions_expert      Demolitions Expert      +2 explosive damage            +2      Achievement
```

### Negative Traits

```
ID                      Name                    Effect                          Cost    Acquisition
--------------------------------------------------------------------------------------------------
weak_lungs              Weak Lungs              -1 Sanity                      -1      Birth
poor_vision             Poor Vision             -1 Aim                         -1      Birth
clumsy                  Clumsy                  -1 accuracy                    -1      Birth
hemophobic              Hemophobic              -2 morale if bleeding          -2      Birth
loner                   Loner                   -1 squad cohesion              -1      Birth
slow_reflexes           Slow Reflexes           -1 Reaction                    -1      Birth
disabled                Disabled                -2 Speed, mobility penalty     -2      Injury
scarred                 Scarred                 -1 Bravery                     -1      Injury
shell_shocked           Shell-shocked           -1 Reaction                    -1      Injury
```

### Rare/Legendary Traits

```
ID                      Name                    Effect                          Cost    Acquisition
--------------------------------------------------------------------------------------------------
unscarred               Unscarred               +1 XP per mission              +1      Achievement
war_hero                War Hero                +2 all stats                   +4      Achievement
telepathic_bond         Telepathic Bond         Share morale across squad      +3      Perk
living_legend           Living Legend           +1 all stats, immunity         +5      Achievement
```

---

## 8. Trait Effects and Calculations

### Stat Modifications

**How Traits Modify Stats**:
```lua
function applyTraitEffects(unit)
    for _, trait in ipairs(unit.traits) do
        for stat, modifier in pairs(trait.effects) do
            if stat == "reaction" then
                unit.stats.reaction = unit.stats.reaction + modifier
            elseif stat == "aim" then
                unit.stats.aim = unit.stats.aim + modifier
            elseif stat == "accuracy_bonus" then
                unit.accuracy_multiplier = unit.accuracy_multiplier + (modifier / 100)
            end
            -- Apply other stat modifications...
        end
    end
end
```

### Special Effects

**Conditional Effects**:
```lua
function applyConditionalEffects(unit, context)
    if context == "combat" then
        if hasTrait(unit, "steady_hand") then
            -- Apply accuracy bonus during combat
            unit.combat_accuracy = unit.combat_accuracy + 5
        end

        if hasTrait(unit, "battle_hardened") then
            -- Immune to suppression
            unit.suppression_resistance = 999
        end
    end

    if context == "healing" then
        if hasTrait(unit, "natural_medic") then
            -- Bonus healing
            unit.healing_power = unit.healing_power + 1
        end
    end
end
```

### Synergy Calculations

**Combined Effects**:
```lua
function calculateSynergyBonuses(unit)
    local bonuses = {}

    -- Marksman + Steady Hand synergy
    if hasTrait(unit, "marksman") and hasTrait(unit, "steady_hand") then
        bonuses.accuracy = (bonuses.accuracy or 0) + 3  -- +3% accuracy
    end

    -- Natural Medic + Healer synergy
    if hasTrait(unit, "natural_medic") and hasTrait(unit, "healer") then
        bonuses.healing_per_bandage = (bonuses.healing_per_bandage or 0) + 1
    end

    -- Leader + Commanding Officer synergy
    if hasTrait(unit, "natural_leader") and hasTrait(unit, "commanding_officer") then
        bonuses.nearby_morale = (bonuses.nearby_morale or 0) + 2
    end

    return bonuses
end
```

---

## 9. UI and Display

### Unit Card Display

**Trait Section**:
```
Traits: [Quick Reflexes] [Marksman] [Weak Lungs]
         ⬆️ +2 Reaction  ⬆️ +1 Aim  ⬇️ -1 Sanity
```

### Trait Tooltips

**Detailed Information**:
```
Quick Reflexes
+2 Reaction stat
- Faster turn order in combat
- Better dodge chance
Source: Birth trait
Balance Cost: +2
Conflicts: Slow Reflexes
Synergies: Steady Hand (+3% accuracy)
```

### Squad Overview

**Active Squad Traits**:
```
Squad Trait Effects:
• Natural Leader: +1 squad morale
• Battle Hardened: Immune to suppression
• Marksman: +1 accuracy for rifle units
• Marathon Runner: +2 movement speed
```

### Trait Management Screen

**Respec Interface**:
- List current traits with costs
- Show available respec points
- Display trait conflicts
- Preview balance changes

---

## 10. Implementation Notes

### Data Structure

**Trait Definition File** (`mods/core/rules/traits.toml`):
```toml
[trait.quick_reflexes]
name = "Quick Reflexes"
description = "+2 Reaction stat"
type = "positive"
category = "combat"
balance_cost = 2
acquisition = "birth"
effects = { reaction = 2 }
conflicts = ["slow_reflexes"]
synergies = ["steady_hand"]

[trait.marksman]
name = "Marksman"
description = "+1 Aim, +1 weapon accuracy"
type = "positive"
category = "combat"
balance_cost = 2
acquisition = "achievement"
requirements = { kills_with_rifle = 20 }
effects = { aim = 1, weapon_accuracy = 1 }
```

### Code Organization

**Core Files**:
- `engine/utils/traits.lua` - Trait definitions and effects
- `engine/utils/trait_validator.lua` - Conflict and balance checking
- `engine/units/trait_system.lua` - Acquisition and management
- `engine/achievements/trait_achievements.lua` - Achievement tracking

### Integration Points

**Unit Creation**:
```lua
-- In unit creation
local unit = createBaseUnit(class, name)
unit.traits = generateBirthTraits(unit)
applyTraitEffects(unit)
```

**Achievement System**:
```lua
-- When achievement completed
if achievement.unlocks_trait then
    offerTraitUnlock(unit, achievement.trait_id)
end
```

**UI Updates**:
```lua
-- In unit display
function displayUnitTraits(unit)
    for _, trait in ipairs(unit.traits) do
        drawTraitIcon(trait)
        if hovered then
            showTraitTooltip(trait)
        end
    end
end
```

---

## 11. Testing and Validation

### Unit Tests

**Trait Generation**:
```lua
function testTraitGeneration()
    -- Generate 1000 units
    local stats = {positive = 0, negative = 0, none = 0}

    for i = 1, 1000 do
        local unit = generateTestUnit()
        local traitCount = #unit.traits

        if traitCount == 0 then stats.none = stats.none + 1
        elseif hasPositiveTrait(unit) then stats.positive = stats.positive + 1
        elseif hasNegativeTrait(unit) then stats.negative = stats.negative + 1
        end
    end

    -- Verify distribution (roughly 30% positive, 20% negative, 50% none)
    assert(stats.positive > 250 and stats.positive < 350)
    assert(stats.negative > 150 and stats.negative < 250)
    assert(stats.none > 450 and stats.none < 550)
end
```

**Conflict Prevention**:
```lua
function testTraitConflicts()
    local unit = createTestUnit()

    -- Add Marathon Runner
    addTrait(unit, "marathon_runner")
    assert(hasTrait(unit, "marathon_runner"))

    -- Try to add Disabled (conflicts)
    local success = addTrait(unit, "disabled")
    assert(not success, "Conflicting trait should be blocked")

    -- Verify Marathon Runner still there
    assert(hasTrait(unit, "marathon_runner"))
end
```

**Balance Validation**:
```lua
function testBalanceLimits()
    local unit = createTestUnit()

    -- Add multiple positive traits
    addTrait(unit, "quick_reflexes")  -- +2
    addTrait(unit, "sharp_eyes")      -- +1 (total +3)
    assert(validateBalance(unit))

    -- Try to add one more (would exceed +3)
    local success = addTrait(unit, "steady_hand")  -- +1 (total +4)
    assert(not success, "Balance limit should prevent addition")
end
```

### Integration Tests

**Achievement Unlocks**:
```lua
function testAchievementTraitUnlock()
    local unit = createTestUnit()
    unit.rank = 4

    -- Simulate achievement
    completeAchievement(unit, "rifle_kills", 20)

    -- Should offer Marksman trait
    assert(hasTraitOffer(unit, "marksman"))

    -- Accept trait
    acceptTrait(unit, "marksman")
    assert(hasTrait(unit, "marksman"))
    assert(unit.stats.aim == unit.stats.aim + 1)
end
```

---

## 12. Future Enhancements

### Phase 2: Trait Trees

**Progression System**:
```
Entry Level → Advanced → Master → Legendary

Example: Combat Tree
Sharp Eyes → Marksman → Deadly Aim → Legendary Shot
```

### Phase 3: Dynamic Traits

**Situational Traits**:
- Activate only in specific conditions
- Temporary trait effects
- Environmental modifiers

### Phase 4: Class-Specific Traits

**Specialized Traits**:
- Sniper traits (long range focus)
- Heavy traits (damage focus)
- Support traits (utility focus)

---

## References

**Related Documents**:
- `design/mechanics/Units.md` - Unit creation and stats
- `design/mechanics/Progression.md` - Rank advancement
- `api/GAME_API.toml` - Trait definitions schema

**Implementation Files**:
- `engine/utils/traits.lua` - Core trait system
- `engine/units/unit_creation.lua` - Birth trait assignment
- `engine/achievements/achievement_system.lua` - Achievement traits

---

**Version**: 1.0
**Status**: Complete Specification
**Last Reviewed**: 2025-10-31</content>
<parameter name="filePath">c:\Users\tombl\Documents\Projects\design\mechanics\TRAIT_SYSTEM_SPECIFICATION.md
