# Unit Progression

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
- [Examples](#examples)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Unit Progression system tracks soldier development through experience gain, stat improvements, ability unlocks, and promotion ranks earned from combat participation and mission completion in Alien Fall, creating persistent investment in individual soldiers while rewarding tactical success and mission performance through permanent character advancement.  
**Status:** Complete Specification

---

## Table of Contents

1. [Overview](#overview)
2. [Experience Point System](#experience-point-system)
3. [Rank Structure](#rank-structure)
4. [Stat Growth](#stat-growth)
5. [Ability Unlocks](#ability-unlocks)
6. [Training Systems](#training-systems)
7. [Officer Promotions](#officer-promotions)
8. [Psychological Progression](#psychological-progression)
9. [Implementation](#implementation)
10. [Cross-References](#cross-references)

---

## Overview

The Unit Progression System defines how soldiers improve through combat experience, training, and promotions. Units gain experience through missions, improve their stats, unlock new abilities, and can be promoted to officer ranks with command abilities.

### Design Principles

1. **Merit-Based**: Experience rewards actual performance, not just survival
2. **Risk vs Reward**: Aggressive tactics earn more XP but increase danger
3. **Specialization**: Units develop unique strengths through ability choices
4. **Asymptotic Growth**: Diminishing returns prevent stat inflation
5. **Officer Tree**: Leadership abilities separate from combat progression

### Key Features

- **XP Sources**: Kills, actions, mission completion, and special achievements
- **8 Combat Ranks**: Rookie → Squaddie → Corporal → Sergeant → Lieutenant → Captain → Colonel → Commander
- **3 Officer Ranks**: Officer → Senior Officer → High Commander
- **Stat Growth**: Gradual improvement with randomization
- **Ability Trees**: Unlock specialized combat abilities per rank
- **Training**: Accelerated learning outside combat
- **Will Points**: Psychological development alongside physical stats

---

## Experience Point System

### XP Gain Formula

```lua
-- Base XP calculation
function calculate_xp_gain(action_type, context)
    local base_xp = XP_TABLE[action_type]
    local multiplier = 1.0
    
    -- Difficulty multiplier
    if context.enemy_rank then
        multiplier = multiplier * (1 + context.enemy_rank * 0.2)
    end
    
    -- Mission type multiplier
    if context.mission_difficulty then
        multiplier = multiplier * MISSION_XP_MULT[context.mission_difficulty]
    end
    
    -- Performance bonuses
    if context.flank_shot then multiplier = multiplier * 1.2 end
    if context.critical_hit then multiplier = multiplier * 1.3 end
    if context.overwatch_shot then multiplier = multiplier * 1.1 end
    
    return math.floor(base_xp * multiplier)
end
```

### XP Sources

#### Combat Actions (Per Action)

| Action Type | Base XP | Notes |
|------------|---------|-------|
| Kill Enemy | 50 | × enemy rank multiplier |
| Wound Enemy (>50% HP) | 20 | Significant damage |
| Wound Enemy (<50% HP) | 10 | Minor damage |
| Suppress Enemy | 15 | Successful suppression |
| Heal Ally (>50% HP) | 25 | Major healing |
| Heal Ally (<50% HP) | 10 | Minor healing |
| Hack/Control | 30 | Mind control or tech hack |
| Flank Shot (hit) | +10 | Bonus to base action |
| Critical Hit | +15 | Bonus to base action |
| Overwatch Kill | +5 | Bonus to kill XP |

#### Mission Completion

| Mission Type | Base XP | Notes |
|-------------|---------|-------|
| UFO Crash | 100 | All survivors |
| UFO Landing | 120 | Higher difficulty |
| Terror Mission | 150 | High stakes |
| Base Defense | 200 | Critical mission |
| Alien Base Assault | 250 | Major operation |
| Council Mission | 180 | VIP protection/extraction |
| Supply Ship | 130 | Resource recovery |

#### Special Achievements

| Achievement | XP | Conditions |
|------------|-----|-----------|
| Mission MVP | 50 | Most kills/actions |
| Zero Casualties | 30 | No soldier deaths |
| Flawless Mission | 50 | No soldiers wounded |
| Solo Kill | 25 | Kill without support |
| Clutch Save | 40 | Revive/save ally from death |
| First Blood | 10 | First kill of mission |
| Last Stand | 60 | Survive alone vs multiple enemies |

#### Survival Bonus

```lua
-- End-of-mission survival XP
function calculate_survival_xp(soldier, mission)
    local base = 20 -- Flat survival bonus
    
    -- Participation bonus (scaled by actions taken)
    local participation = math.min(soldier.actions_taken * 2, 50)
    
    -- Time bonus (longer missions = more XP)
    local time_bonus = math.floor(mission.turns / 2)
    
    return base + participation + time_bonus
end
```

### XP Multipliers

#### Mission Difficulty

```lua
MISSION_XP_MULT = {
    easy = 0.8,     -- Training missions
    normal = 1.0,   -- Standard operations
    hard = 1.3,     -- Challenging encounters
    veteran = 1.5,  -- High difficulty
    commander = 2.0 -- Maximum challenge
}
```

#### Enemy Rank Multiplier

```lua
ENEMY_RANK_MULT = {
    soldier = 1.0,      -- Base enemy
    navigator = 1.3,    -- Mid-tier
    engineer = 1.3,     -- Mid-tier
    medic = 1.4,        -- Specialized
    leader = 1.6,       -- Squad leader
    commander = 2.0     -- Elite unit
}
```

---

## Rank Structure

### Combat Ranks

| Rank | Title | XP Required | Total XP | Key Benefits |
|------|-------|-------------|----------|--------------|
| 0 | Rookie | 0 | 0 | No bonuses |
| 1 | Squaddie | 100 | 100 | +1 ability slot |
| 2 | Corporal | 250 | 350 | +1 ability slot, +5% aim |
| 3 | Sergeant | 500 | 850 | +1 ability slot, +10% will |
| 4 | Lieutenant | 900 | 1750 | +1 ability slot, officer eligible |
| 5 | Captain | 1500 | 3250 | +1 ability slot, +10% aim |
| 6 | Colonel | 2500 | 5750 | +1 ability slot, +15% will |
| 7 | Commander | 4000 | 9750 | All ability slots, max bonuses |

### Rank Progression Formula

```lua
-- XP required for next rank
function xp_for_next_rank(current_rank)
    if current_rank >= 7 then return nil end -- Max rank
    
    local base = 100
    local exponent = 1.6 -- Exponential growth
    
    return math.floor(base * math.pow(current_rank + 1, exponent))
end

-- Check if soldier can rank up
function check_rank_up(soldier)
    local next_rank = soldier.rank + 1
    local xp_needed = xp_for_next_rank(soldier.rank)
    
    if xp_needed and soldier.xp >= xp_needed then
        promote_soldier(soldier, next_rank)
        soldier.xp = soldier.xp - xp_needed -- Carry over excess XP
        return true
    end
    
    return false
end
```

### Rank Benefits

#### Aim Bonus (Accuracy)

```lua
function get_rank_aim_bonus(rank)
    local bonuses = {
        [0] = 0,   -- Rookie
        [1] = 0,   -- Squaddie
        [2] = 5,   -- Corporal
        [3] = 5,   -- Sergeant
        [4] = 5,   -- Lieutenant
        [5] = 10,  -- Captain (+5 additional)
        [6] = 10,  -- Colonel
        [7] = 15   -- Commander (+5 additional)
    }
    return bonuses[rank] or 0
end
```

#### Will Bonus (Morale/Psionics)

```lua
function get_rank_will_bonus(rank)
    local bonuses = {
        [0] = 0,   -- Rookie
        [1] = 0,   -- Squaddie
        [2] = 0,   -- Corporal
        [3] = 10,  -- Sergeant
        [4] = 10,  -- Lieutenant
        [5] = 10,  -- Captain
        [6] = 15,  -- Colonel (+5 additional)
        [7] = 20   -- Commander (+5 additional)
    }
    return bonuses[rank] or 0
end
```

#### HP Bonus (Toughness)

```lua
function get_rank_hp_bonus(rank)
    -- +1 HP every 2 ranks
    return math.floor(rank / 2)
end
```

---

## Stat Growth

### Growth System

Stats improve gradually with XP gain, using a randomized system with weighted probabilities.

#### Stat Growth Formula

```lua
-- Roll for stat improvement
function check_stat_growth(soldier, stat_name)
    local growth_chance = STAT_GROWTH_RATES[stat_name]
    local rank_modifier = soldier.rank * 0.05 -- +5% per rank
    
    -- Diminishing returns (stats closer to cap grow slower)
    local current = soldier.stats[stat_name]
    local max = STAT_CAPS[stat_name]
    local cap_penalty = (current / max) * 0.5 -- Up to 50% reduction
    
    local final_chance = growth_chance + rank_modifier - cap_penalty
    
    if math.random() < final_chance then
        return true
    end
    return false
end

-- Apply stat growth after gaining XP
function apply_stat_growth(soldier, xp_gained)
    -- Roll once per 25 XP gained
    local growth_rolls = math.floor(xp_gained / 25)
    
    for i = 1, growth_rolls do
        for stat_name, _ in pairs(soldier.stats) do
            if check_stat_growth(soldier, stat_name) then
                soldier.stats[stat_name] = soldier.stats[stat_name] + 1
                
                -- Cap stats at maximum
                local cap = STAT_CAPS[stat_name]
                if soldier.stats[stat_name] > cap then
                    soldier.stats[stat_name] = cap
                end
            end
        end
    end
end
```

### Stat Growth Rates

| Stat | Base Growth % | Notes |
|------|--------------|-------|
| Time Units | 15% | Action points |
| Stamina | 12% | Fatigue resistance |
| Health | 10% | Hit points |
| Bravery | 8% | Panic resistance |
| Reactions | 12% | Overwatch/counter-fire |
| Firing Accuracy | 18% | Primary combat stat |
| Throwing Accuracy | 10% | Grenades/items |
| Strength | 8% | Carrying capacity |
| Psi Strength | 5% | Psionic resistance (if psi-capable) |
| Psi Skill | 8% | Psionic power (if trained) |

### Stat Caps

```lua
STAT_CAPS = {
    time_units = 80,        -- Max action points
    stamina = 100,          -- Max stamina
    health = 70,            -- Max HP
    bravery = 100,          -- Max bravery
    reactions = 80,         -- Max reactions
    firing_accuracy = 120,  -- Max aim (can exceed 100)
    throwing_accuracy = 100,-- Max throw accuracy
    strength = 70,          -- Max strength
    psi_strength = 100,     -- Max psi resistance
    psi_skill = 100         -- Max psi power
}
```

### Example Progression

```lua
-- Rookie (rank 0) starting stats
rookie_stats = {
    time_units = 50,
    stamina = 60,
    health = 30,
    bravery = 30,
    reactions = 40,
    firing_accuracy = 50,
    throwing_accuracy = 50,
    strength = 30,
    psi_strength = 0,  -- Unlocked later
    psi_skill = 0      -- Unlocked later
}

-- Veteran (rank 5, Captain) typical stats after 100+ missions
veteran_stats = {
    time_units = 65,        -- +15 from growth
    stamina = 80,           -- +20 from growth
    health = 45,            -- +15 from growth + rank bonus
    bravery = 55,           -- +25 from growth
    reactions = 60,         -- +20 from growth
    firing_accuracy = 85,   -- +35 from growth + rank bonus
    throwing_accuracy = 70, -- +20 from growth
    strength = 45,          -- +15 from growth
    psi_strength = 40,      -- Developed if psi-trained
    psi_skill = 30          -- Developed if psi-trained
}
```

---

## Ability Unlocks

### Ability System

Soldiers unlock ability slots at each rank and can choose from a tree of specialized abilities.

#### Ability Slots Per Rank

```lua
function get_ability_slots(rank)
    -- Rookies have no abilities
    if rank == 0 then return 0 end
    
    -- +1 slot per rank after Rookie
    return rank
end
```

### Ability Trees

#### Assault Tree (Close Combat)

| Rank | Ability | Effect |
|------|---------|--------|
| 1 | Run and Gun | Move and still shoot with -20% accuracy |
| 2 | Close Combat Specialist | +20% accuracy within 8 tiles |
| 3 | Aggressive | +1 TU when killing enemy |
| 4 | Rapid Fire | Fire twice in one action (−30% accuracy each) |
| 5 | Lightning Reflexes | +20 reactions, +10% dodge |
| 6 | Close Quarters Combat | Free reaction shot when enemy enters adjacent tile |
| 7 | Berserker | +30% damage when below 50% HP |

#### Sniper Tree (Long Range)

| Rank | Ability | Effect |
|------|---------|--------|
| 1 | Squadsight | Can shoot at any enemy squad can see |
| 2 | Snap Shot | Shooting costs −1 TU |
| 3 | Steady Hands | +10% accuracy if didn't move |
| 4 | Opportunist | +15% overwatch accuracy |
| 5 | Executioner | +25% crit chance vs wounded enemies |
| 6 | In The Zone | Killing flanked/exposed enemy refunds action |
| 7 | Headshot | Guaranteed crit (costs 5 energy) |

#### Support Tree (Team Utility)

| Rank | Ability | Effect |
|------|---------|--------|
| 1 | Field Medic | Healing items +50% effectiveness |
| 2 | Smoke Grenade | +1 smoke grenade per mission |
| 3 | Revive | Can stabilize bleeding-out allies |
| 4 | Combat Drugs | Use stimulant for +2 TU (1/mission) |
| 5 | Covering Fire | Suppression costs −1 TU |
| 6 | Guardian | +1 overwatch shot per turn |
| 7 | Savior | Healed allies get +20 will for 3 turns |

#### Heavy Tree (Area Damage)

| Rank | Ability | Effect |
|------|---------|--------|
| 1 | Grenadier | +1 grenade per mission |
| 2 | Shredder Ammo | Destroyed cover deals damage to hiding enemies |
| 3 | Suppression | Can suppress enemies (accuracy penalty) |
| 4 | Danger Zone | +2 tile explosive radius |
| 5 | Demolition | +30% explosive damage |
| 6 | Mayhem | +2 damage with heavy weapons |
| 7 | Bunker Buster | Explosives destroy any cover |

#### Scout Tree (Recon/Mobility)

| Rank | Ability | Effect |
|------|---------|--------|
| 1 | Sprint | Move action costs −1 TU |
| 2 | Battle Scanner | +2 battle scanners per mission |
| 3 | Low Profile | +10 defense in half cover |
| 4 | Tactical Sense | +5 defense per visible enemy (max +20) |
| 5 | Lightning Reflexes | +20 reactions |
| 6 | Sentinel | +1 reaction shot per turn |
| 7 | Untouchable | First enemy shot per turn auto-misses |

### Ability Selection System

```lua
-- Present ability choices at rank up
function offer_ability_choices(soldier, new_rank)
    local available_trees = get_soldier_trees(soldier)
    local choices = {}
    
    for _, tree_name in ipairs(available_trees) do
        local ability = ABILITY_TREES[tree_name][new_rank]
        if ability then
            table.insert(choices, {
                tree = tree_name,
                ability = ability
            })
        end
    end
    
    return choices
end

-- Apply chosen ability
function learn_ability(soldier, ability_name)
    table.insert(soldier.abilities, ability_name)
    
    -- Some abilities grant passive stat bonuses
    apply_ability_bonuses(soldier, ability_name)
end
```

---

## Training Systems

### Training Facility

Soldiers can train at the base to gain XP without combat risk.

#### Training XP Formula

```lua
function calculate_training_xp(days_trained, facility_quality)
    local base_xp_per_day = 5
    local quality_mult = 1 + (facility_quality * 0.2) -- +20% per quality level
    
    return math.floor(base_xp_per_day * quality_mult * days_trained)
end

-- Training is slower but safer than combat
-- 30 days training ≈ 150 XP (vs. 100-300 XP per mission)
```

### Training Types

#### Physical Training (Gym)

| Training Type | Days Required | Effect |
|--------------|---------------|--------|
| Strength Training | 30 | +5 strength (guaranteed) |
| Stamina Training | 30 | +10 stamina (guaranteed) |
| Agility Training | 30 | +3 reactions (guaranteed) |

#### Combat Training (Firing Range)

| Training Type | Days Required | Effect |
|--------------|---------------|--------|
| Marksmanship | 30 | +5 firing accuracy |
| Grenade Training | 15 | +5 throwing accuracy |
| CQB Training | 30 | +2 reactions, learn Run and Gun |

#### Psionic Training (Psi Lab)

```lua
-- Psionic training unlocks latent abilities
function psionic_training(soldier, days)
    if not soldier.psi_capable then
        -- 5% chance per week to discover psi potential
        local weeks = math.floor(days / 7)
        for i = 1, weeks do
            if math.random() < 0.05 then
                soldier.psi_capable = true
                soldier.stats.psi_strength = math.random(20, 60)
                soldier.stats.psi_skill = 0
                return "discovered"
            end
        end
        return "no_potential"
    else
        -- Develop psi skills
        local xp = calculate_training_xp(days, 2) -- Psi lab quality
        soldier.psi_xp = (soldier.psi_xp or 0) + xp
        
        -- Increase psi skill
        while soldier.psi_xp >= 100 do
            soldier.stats.psi_skill = math.min(soldier.stats.psi_skill + 5, 100)
            soldier.psi_xp = soldier.psi_xp - 100
        end
        
        return "training"
    end
end
```

### Training Costs

```lua
TRAINING_COSTS = {
    physical = {
        days = 30,
        cost = 5000,  -- $5,000
        engineers = 0
    },
    combat = {
        days = 30,
        cost = 8000,  -- $8,000
        engineers = 1  -- Requires trainer
    },
    psionic = {
        days = 30,
        cost = 15000, -- $15,000
        engineers = 2  -- Requires psi specialists
    }
}
```

---

## Officer Promotions

### Officer System

Soldiers of Lieutenant rank or higher can be promoted to officer ranks, gaining command abilities.

#### Officer Ranks

| Officer Rank | Required Combat Rank | Command Slots | Abilities |
|-------------|---------------------|---------------|-----------|
| Officer | Lieutenant (4) | 1 | Basic command |
| Senior Officer | Captain (5) | 2 | Advanced tactics |
| High Commander | Colonel (6+) | 3 | Strategic mastery |

### Command Abilities

#### Basic Command (Officer)

| Ability | Cost | Effect |
|---------|------|--------|
| Rally | 2 TU | Remove panic from adjacent allies |
| Tactical Advance | 3 TU | All allies +1 TU next turn |
| Mark Target | 2 TU | Marked enemy takes +20% damage from squad |

#### Advanced Command (Senior Officer)

| Ability | Cost | Effect |
|---------|------|--------|
| Suppressing Fire | 4 TU | Order ally to suppress target |
| Overwatch All | 3 TU | All allies enter overwatch |
| Combat Stim | 3 TU | Target ally +2 TU, +10 will for 3 turns |

#### Strategic Command (High Commander)

| Ability | Cost | Effect |
|---------|------|--------|
| Coordinate Fire | 5 TU | Next 3 ally shots +30% accuracy |
| Defensive Formation | 4 TU | All allies +20 defense until moved |
| Heroic Charge | 6 TU | All allies +3 TU, +20% accuracy for 1 turn |

### Officer Promotion System

```lua
-- Check officer eligibility
function can_promote_to_officer(soldier)
    return soldier.rank >= 4  -- Lieutenant or higher
        and not soldier.is_officer
        and soldier.missions >= 10  -- Combat experience required
end

-- Promote to officer
function promote_to_officer(soldier, officer_rank)
    soldier.is_officer = true
    soldier.officer_rank = officer_rank
    soldier.command_slots = get_command_slots(officer_rank)
    
    -- Officers get will bonus
    soldier.stats.bravery = soldier.stats.bravery + 10
    
    -- Learn first command ability
    offer_command_abilities(soldier, officer_rank)
end

-- Command ability selection
function offer_command_abilities(soldier, officer_rank)
    local available = COMMAND_ABILITIES[officer_rank]
    
    -- Officer can choose abilities up to their command slots
    local choices = {}
    for _, ability in ipairs(available) do
        if not has_ability(soldier, ability) then
            table.insert(choices, ability)
        end
    end
    
    return choices
end
```

---

## Psychological Progression

### Will Points System

Soldiers develop mental resilience through combat experiences.

#### Will Point Sources

| Source | Will Gained | Conditions |
|--------|------------|------------|
| Survive Mission | +2 | Per mission survived |
| Witness Ally Death | −5 | Per death witnessed |
| Kill Terrifying Enemy | +5 | Chrysalid, Ethereal, etc. |
| Mission Success | +3 | Mission completed |
| Mission Failure | −3 | Mission aborted/failed |
| Capture Alien | +2 | Live alien captured |
| Mind Controlled | −10 | Was mind controlled |

#### Will Point Effects

```lua
-- Calculate effective will (bravery + will points)
function get_effective_will(soldier)
    local base_bravery = soldier.stats.bravery
    local will_bonus = math.floor(soldier.will_points / 10) -- +1 bravery per 10 will
    local rank_bonus = get_rank_will_bonus(soldier.rank)
    
    return base_bravery + will_bonus + rank_bonus
end

-- Panic check using effective will
function check_panic(soldier, situation)
    local will = get_effective_will(soldier)
    local panic_threshold = PANIC_THRESHOLDS[situation]
    
    if will < panic_threshold then
        local panic_chance = (panic_threshold - will) / 100
        if math.random() < panic_chance then
            apply_panic(soldier)
            return true
        end
    end
    
    return false
end
```

### Psychological Traits

Soldiers can develop psychological traits through experiences.

#### Positive Traits

| Trait | Unlock Condition | Effect |
|-------|-----------------|--------|
| Steady | 20+ missions, never panicked | Immune to panic |
| Brave | Kill 3+ terrifying enemies | +20 will vs fear |
| Veteran | 30+ missions | +5% accuracy from experience |
| Iron Will | Resist 5+ mind control attempts | +30 psi resistance |

#### Negative Traits

| Trait | Trigger Condition | Effect |
|-------|------------------|--------|
| Shaky | Panic 3+ times | −10% accuracy when wounded |
| Scarred | Witness 5+ ally deaths | −10 will |
| Haunted | Fail 3+ missions | −20 will on mission start |
| Weak Minded | Mind controlled 3+ times | −20 psi resistance |

```lua
-- Track psychological experiences
function track_psychological_event(soldier, event_type)
    soldier.psych_events = soldier.psych_events or {}
    soldier.psych_events[event_type] = (soldier.psych_events[event_type] or 0) + 1
    
    -- Check for trait unlocks
    check_trait_unlock(soldier)
end

-- Evaluate trait eligibility
function check_trait_unlock(soldier)
    -- Example: Steady trait
    if soldier.missions >= 20 and (soldier.psych_events.panic or 0) == 0 then
        if not has_trait(soldier, "steady") then
            grant_trait(soldier, "steady")
        end
    end
    
    -- Example: Scarred trait (negative)
    if (soldier.psych_events.witness_death or 0) >= 5 then
        if not has_trait(soldier, "scarred") then
            grant_trait(soldier, "scarred")
        end
    end
end
```

---

## Implementation

### Data Structures

#### Soldier Progression Data

```lua
-- Soldier progression state
soldier_progression = {
    -- Experience
    xp = 0,                    -- Total XP earned
    rank = 0,                  -- Current rank (0-7)
    missions = 0,              -- Missions completed
    kills = 0,                 -- Total kills
    
    -- Stats (see Stats.md for details)
    stats = {
        time_units = 50,
        stamina = 60,
        health = 30,
        bravery = 30,
        reactions = 40,
        firing_accuracy = 50,
        throwing_accuracy = 50,
        strength = 30,
        psi_strength = 0,
        psi_skill = 0
    },
    
    -- Abilities
    abilities = {},            -- List of learned ability IDs
    ability_slots = 0,         -- Available ability slots
    
    -- Officer status
    is_officer = false,
    officer_rank = 0,          -- 0 = none, 1 = officer, 2 = senior, 3 = high commander
    command_slots = 0,
    command_abilities = {},
    
    -- Psychology
    will_points = 0,
    psych_events = {},         -- Event counters
    traits = {},               -- Psychological traits
    
    -- Training
    training_days = 0,
    training_type = nil,
    
    -- Psionic
    psi_capable = false,
    psi_xp = 0
}
```

### Progression Manager

```lua
-- Progression Manager module
ProgressionManager = {}

function ProgressionManager:init()
    self.pending_promotions = {}
end

-- Award XP to soldier
function ProgressionManager:award_xp(soldier, xp_amount, source)
    soldier.xp = soldier.xp + xp_amount
    
    -- Log XP gain for debugging
    log_xp_gain(soldier, xp_amount, source)
    
    -- Check for stat growth
    apply_stat_growth(soldier, xp_amount)
    
    -- Check for rank up
    if check_rank_up(soldier) then
        table.insert(self.pending_promotions, soldier)
    end
end

-- Process end-of-mission XP
function ProgressionManager:process_mission_completion(mission)
    for _, soldier in ipairs(mission.squad) do
        if soldier.alive then
            -- Combat XP already awarded during mission
            
            -- Award mission completion XP
            local completion_xp = MISSION_XP_TABLE[mission.type]
            self:award_xp(soldier, completion_xp, "mission_complete")
            
            -- Award survival XP
            local survival_xp = calculate_survival_xp(soldier, mission)
            self:award_xp(soldier, survival_xp, "survival")
            
            -- Award special achievement XP
            local achievement_xp = calculate_achievement_xp(soldier, mission)
            if achievement_xp > 0 then
                self:award_xp(soldier, achievement_xp, "achievements")
            end
            
            -- Update psychology
            soldier.missions = soldier.missions + 1
            track_psychological_event(soldier, "mission_complete")
        end
    end
end

-- Present rank up choices
function ProgressionManager:show_promotion_screen()
    if #self.pending_promotions == 0 then return end
    
    for _, soldier in ipairs(self.pending_promotions) do
        -- Show ability choices
        local ability_choices = offer_ability_choices(soldier, soldier.rank)
        
        -- UI presents choices to player
        UI:show_promotion_dialog(soldier, ability_choices)
        
        -- Check officer eligibility
        if can_promote_to_officer(soldier) then
            UI:show_officer_promotion_dialog(soldier)
        end
    end
    
    self.pending_promotions = {}
end

return ProgressionManager
```

### UI Integration

```lua
-- Promotion screen rendering
function draw_promotion_screen(soldier, ability_choices)
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", 0, 0, 800, 600)
    
    -- Soldier info
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("PROMOTION: " .. soldier.name, 200, 60)
    love.graphics.print("NEW RANK: " .. RANK_NAMES[soldier.rank], 200, 100)
    
    -- Ability choices (3 trees)
    local y = 160
    for i, choice in ipairs(ability_choices) do
        local x = 120 + (i - 1) * 200
        
        -- Draw ability card
        draw_ability_card(choice.ability, x, y)
        
        -- Selectable button
        if mouse_over_button(x, y, 180, 220) then
            love.graphics.setColor(1, 1, 0)
            love.graphics.rectangle("line", x - 5, y - 5, 190, 230)
            
            if love.mouse.isDown(1) then
                learn_ability(soldier, choice.ability.id)
                close_promotion_screen()
            end
        end
    end
end
```

---

## Cross-References

### Related Systems

- **[Stats](Stats.md)** - Base statistics and derived calculations
- **[Action Economy](../core/Action_Economy.md)** - TU costs and turn structure
- **[Energy Systems](../core/Energy_Systems.md)** - Ability energy costs
- **[Mission System](../geoscape/Mission_System.md)** - XP from missions
- **[Combat Mechanics](../battlescape/Combat_Mechanics.md)** - XP from combat actions
- **[Morale System](../battlescape/Morale.md)** - Psychological effects
- **[Psionic System](../battlescape/Psionics.md)** - Psionic training and abilities

### Data Files

- `data/units/progression.toml` - XP tables and rank data
- `data/units/abilities.toml` - Ability definitions
- `data/units/traits.toml` - Psychological trait data
- `data/training/courses.toml` - Training programs

### Implementation Files

- `src/units/progression.lua` - Progression manager
- `src/units/abilities.lua` - Ability system
- `src/screens/promotion_screen.lua` - Promotion UI
- `src/training/training_manager.lua` - Training system

---

**End of Unit Progression System Specification**

*Version 1.0 - September 30, 2025*
