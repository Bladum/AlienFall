# Difficulty Settings

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
- [Examples](#examples)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Difficulty Settings system provides scalable challenge across multiple difficulty tiers through numerical modifiers affecting enemy stats, resource availability, strategic pressure, and tactical complexity, enabling players to calibrate their experience from casual story-focused play through punishing ironman campaigns while maintaining balanced progression curves and fair tactical scenarios.  
**Related Systems:** [Tutorial](Tutorial.md) | [AI Behavior](../ai/README.md) | [Economy](../economy/README.md)

---

## Overview

The Difficulty Settings System provides four distinct challenge levels, each with comprehensive modifiers affecting combat, economy, research, and AI behavior. This system ensures the game is accessible to new players while providing significant challenge for veterans.

### Purpose
- Provide appropriate challenge for all skill levels
- Scale difficulty across all game systems
- Reward skilled play without punishing mistakes excessively
- Enable achievement and progression tracking per difficulty
- Support mid-campaign difficulty adjustment (with restrictions)

### Difficulty Levels
1. **Easy** - New players, story focus, forgiving mechanics
2. **Normal** - Intended experience, balanced challenge
3. **Veteran** - Experienced players, significant challenge
4. **Impossible** - Hardcore players, extreme challenge

---

## Difficulty Level Overview

### Comparative Summary

```
┌──────────────────────────────────────────────────────────────────────────┐
│                     DIFFICULTY COMPARISON TABLE                          │
├──────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│ Aspect            │  Easy   │  Normal  │ Veteran  │ Impossible          │
├───────────────────┼─────────┼──────────┼──────────┼─────────────────────┤
│ Alien HP          │   80%   │   100%   │   120%   │   150%              │
│ Alien Aim         │   -15   │    +0    │   +10    │   +20               │
│ Alien Crit Chance │   10%   │   15%    │   20%    │   30%               │
│ XCOM Aim Bonus    │   +10   │    +0    │    -5    │   -10               │
│ Starting Funds    │  $8.0M  │  $6.0M   │  $5.0M   │   $4.0M             │
│ Monthly Funding   │  +20%   │   Base   │   -10%   │   -20%              │
│ Research Time     │   75%   │   100%   │   125%   │   150%              │
│ Build Time        │   80%   │   100%   │   120%   │   140%              │
│ Enemy Squad Size  │   -2    │   Base   │   +2     │   +4                │
│ Panic Increase    │   75%   │   100%   │   125%   │   150%              │
│ Wound Time        │   50%   │   100%   │   150%   │   200%              │
│ Permadeath        │   No    │   Yes    │   Yes    │   Yes               │
│ Save Scum         │  Yes    │   Yes    │  Limited │   No (Ironman)      │
│                                                                          │
└──────────────────────────────────────────────────────────────────────────┘

Win Rate Targets (Design Goals):
  Easy:       75-85% of players complete campaign
  Normal:     50-60% of players complete campaign
  Veteran:    25-35% of players complete campaign
  Impossible: 10-15% of players complete campaign
```

---

## Easy Difficulty

**Target Audience:** New players, casual gamers, story-focused players

### Philosophy
Forgiving mechanics allow learning through trial and error. Focus on experiencing the narrative and core mechanics without excessive punishment for mistakes.

### Combat Modifiers

```lua
local easy_difficulty = {
    name = "Easy",
    description = "Recommended for new players. Forgiving mechanics and reduced enemy strength.",
    
    combat = {
        -- Player advantages
        xcom_aim_bonus = 10,           -- +10 aim for all soldiers
        xcom_crit_chance_bonus = 5,    -- +5% crit chance
        xcom_damage_reduction = 0.85,  -- Take 15% less damage
        xcom_will_bonus = 10,          -- +10 will (panic resistance)
        
        -- Enemy disadvantages
        alien_hp_multiplier = 0.80,    -- Aliens have 80% HP
        alien_aim_penalty = -15,       -- -15 aim for aliens
        alien_crit_chance = 0.10,      -- 10% crit chance (vs 15% normal)
        alien_damage_multiplier = 0.90,-- 10% less damage
        alien_aggression = 0.70,       -- Less aggressive tactics
        
        -- Squad composition
        enemy_squad_size_modifier = -2,-- 2 fewer enemies per mission
        reinforcement_frequency = 0.5, -- 50% less frequent reinforcements
        
        -- Special mechanics
        flanking_damage_bonus = 1.25,  -- +25% when flanking (vs +50% normal)
        overwatch_accuracy = 0.85,     -- Alien overwatch less accurate
        reaction_fire_chance = 0.70    -- 70% chance aliens react (vs 100%)
    }
}

function apply_easy_combat_modifiers(unit)
    if unit.faction == "XCOM" then
        unit.stats.aim = unit.stats.aim + easy_difficulty.combat.xcom_aim_bonus
        unit.stats.will = unit.stats.will + easy_difficulty.combat.xcom_will_bonus
        
    elseif unit.faction == "ALIEN" then
        unit.stats.hp = math.floor(unit.stats.hp * easy_difficulty.combat.alien_hp_multiplier)
        unit.stats.aim = unit.stats.aim + easy_difficulty.combat.alien_aim_penalty
    end
end

function calculate_damage_easy(base_damage, is_xcom_receiving)
    local damage = base_damage
    
    if is_xcom_receiving then
        -- XCOM takes reduced damage
        damage = math.floor(damage * easy_difficulty.combat.xcom_damage_reduction)
    else
        -- Aliens take normal damage
        damage = base_damage
    end
    
    return math.max(1, damage)  -- Minimum 1 damage
end
```

### Economic Modifiers

```lua
easy_difficulty.economy = {
    starting_funds = 8000000,        -- $8M (vs $6M normal)
    monthly_funding_multiplier = 1.2,-- +20% council funding
    
    item_costs = {
        research_cost_multiplier = 0.80,    -- 20% cheaper research
        construction_cost_multiplier = 0.85,-- 15% cheaper buildings
        manufacturing_cost_multiplier = 0.90,-- 10% cheaper items
        soldier_salary_multiplier = 0.85    -- 15% lower salaries
    },
    
    rewards = {
        mission_reward_multiplier = 1.15,   -- +15% mission rewards
        item_sell_price_multiplier = 1.10   -- +10% item sell prices
    },
    
    bankruptcy_threshold = -3,       -- Can sustain 3 months deficit (vs 2)
    starting_resources = {
        elerium_115 = 50,              -- Bonus starting resources
        alien_alloys = 100,
        weapon_fragments = 200
    }
}
```

### Research & Engineering

```lua
easy_difficulty.research = {
    research_time_multiplier = 0.75,  -- Research 25% faster
    engineer_efficiency = 1.20,       -- Engineers 20% more efficient
    breakthrough_chance = 0.15,       -- 15% chance instant research complete
    
    starting_research = {
        "alien_materials",              -- Pre-unlocked research
        "alien_weapon_fragments"
    }
}
```

### AI Behavior

```lua
easy_difficulty.ai = {
    -- Tactical AI
    flanking_priority = 0.60,         -- Less aggressive flanking
    grenade_usage_chance = 0.40,      -- Use grenades less often
    ability_usage_frequency = 0.70,   -- Use special abilities less
    retreat_threshold = 0.50,         -- Retreat when 50% HP (vs 25%)
    overwatch_trap_frequency = 0.30,  -- Set overwatch traps rarely
    
    -- Strategic AI
    ufo_spawn_rate = 0.80,            -- 20% fewer UFOs
    alien_base_construction_rate = 0.70,-- Build bases slower
    infiltration_speed = 0.75,        -- Infiltrate countries slower
    terror_mission_frequency = 0.70   -- Terror missions less frequent
}
```

### Special Features

```lua
easy_difficulty.special = {
    permadeath = false,               -- Soldiers don't die permanently
    wound_recovery_multiplier = 0.50, -- Recover twice as fast
    panic_resistance = 1.30,          -- 30% harder to panic
    tutorial_hints_enabled = true,    -- Show tactical hints
    auto_save_frequency = "every_turn",-- Save very frequently
    mission_abort_penalty = 0.50      -- 50% penalty for aborting
}

function handle_soldier_death_easy(soldier)
    -- On Easy, soldiers are "critically wounded" instead of killed
    soldier.status = "critically_wounded"
    soldier.recovery_days = 30  -- 1 month recovery
    
    game.ui:show_message(
        "Soldier Critically Wounded",
        string.format("%s has been critically wounded and will need 30 days to recover.", 
            soldier.name)
    )
    
    -- Return to barracks
    return "critically_wounded"
end
```

---

## Normal Difficulty

**Target Audience:** All players, default experience, intended balance

### Philosophy
Balanced challenge representing the intended game experience. Mistakes have consequences but aren't crippling. Rewards tactical thinking and strategic planning.

### Combat Modifiers

```lua
local normal_difficulty = {
    name = "Normal",
    description = "The intended XCOM experience. Balanced challenge with meaningful consequences.",
    
    combat = {
        -- No modifiers - baseline values
        xcom_aim_bonus = 0,
        xcom_crit_chance_bonus = 0,
        xcom_damage_reduction = 1.0,
        xcom_will_bonus = 0,
        
        alien_hp_multiplier = 1.0,
        alien_aim_penalty = 0,
        alien_crit_chance = 0.15,
        alien_damage_multiplier = 1.0,
        alien_aggression = 1.0,
        
        enemy_squad_size_modifier = 0,
        reinforcement_frequency = 1.0,
        
        flanking_damage_bonus = 1.50,
        overwatch_accuracy = 1.0,
        reaction_fire_chance = 1.0
    }
}

-- Normal difficulty uses baseline formulas without modification
```

### Economic Modifiers

```lua
normal_difficulty.economy = {
    starting_funds = 6000000,         -- $6M baseline
    monthly_funding_multiplier = 1.0, -- No modifier
    
    item_costs = {
        research_cost_multiplier = 1.0,
        construction_cost_multiplier = 1.0,
        manufacturing_cost_multiplier = 1.0,
        soldier_salary_multiplier = 1.0
    },
    
    rewards = {
        mission_reward_multiplier = 1.0,
        item_sell_price_multiplier = 1.0
    },
    
    bankruptcy_threshold = -2,        -- 2 months deficit triggers game over
    starting_resources = {
        elerium_115 = 0,
        alien_alloys = 0,
        weapon_fragments = 50          -- Small starting amount
    }
}
```

### Special Features

```lua
normal_difficulty.special = {
    permadeath = true,                -- Soldiers die permanently
    wound_recovery_multiplier = 1.0,  -- Standard recovery time
    panic_resistance = 1.0,           -- Standard panic mechanics
    tutorial_hints_enabled = false,   -- No hints after tutorial
    auto_save_frequency = "every_mission",
    mission_abort_penalty = 1.0       -- Full penalty for aborting
}
```

---

## Veteran Difficulty

**Target Audience:** Experienced players, significant challenge, strategic depth

### Philosophy
Significant challenge requiring optimal play and strategic planning. Mistakes are costly. Alien AI uses advanced tactics. Resource scarcity forces difficult choices.

### Combat Modifiers

```lua
local veteran_difficulty = {
    name = "Veteran",
    description = "For experienced commanders. Expect significant challenge and punishing mistakes.",
    
    combat = {
        -- Player disadvantages
        xcom_aim_bonus = -5,           -- -5 aim penalty
        xcom_crit_chance_bonus = -3,   -- -3% crit chance
        xcom_damage_reduction = 1.0,   -- No damage reduction
        xcom_will_bonus = -5,          -- -5 will (more prone to panic)
        
        -- Enemy advantages
        alien_hp_multiplier = 1.20,    -- +20% HP
        alien_aim_penalty = 10,        -- +10 aim bonus
        alien_crit_chance = 0.20,      -- 20% crit chance
        alien_damage_multiplier = 1.10,-- +10% damage
        alien_aggression = 1.30,       -- More aggressive tactics
        
        enemy_squad_size_modifier = 2, -- +2 enemies per mission
        reinforcement_frequency = 1.30,-- 30% more frequent reinforcements
        
        flanking_damage_bonus = 1.75,  -- +75% when flanking
        overwatch_accuracy = 1.15,     -- Alien overwatch more accurate
        reaction_fire_chance = 1.0     -- Always react
    }
}

function apply_veteran_combat_modifiers(unit)
    if unit.faction == "XCOM" then
        unit.stats.aim = unit.stats.aim + veteran_difficulty.combat.xcom_aim_bonus
        unit.stats.will = unit.stats.will + veteran_difficulty.combat.xcom_will_bonus
        
    elseif unit.faction == "ALIEN" then
        unit.stats.hp = math.floor(unit.stats.hp * veteran_difficulty.combat.alien_hp_multiplier)
        unit.stats.aim = unit.stats.aim + veteran_difficulty.combat.alien_aim_penalty
        unit.stats.damage = math.floor(unit.stats.damage * veteran_difficulty.combat.alien_damage_multiplier)
    end
end
```

### Economic Modifiers

```lua
veteran_difficulty.economy = {
    starting_funds = 5000000,         -- $5M (-$1M)
    monthly_funding_multiplier = 0.90,-- -10% council funding
    
    item_costs = {
        research_cost_multiplier = 1.15,    -- +15% research costs
        construction_cost_multiplier = 1.20,-- +20% building costs
        manufacturing_cost_multiplier = 1.15,-- +15% manufacturing costs
        soldier_salary_multiplier = 1.10    -- +10% salaries
    },
    
    rewards = {
        mission_reward_multiplier = 0.90,   -- -10% mission rewards
        item_sell_price_multiplier = 0.85   -- -15% sell prices
    },
    
    bankruptcy_threshold = -2,
    starting_resources = {
        elerium_115 = 0,
        alien_alloys = 0,
        weapon_fragments = 25          -- Reduced starting resources
    }
}
```

### Research & Engineering

```lua
veteran_difficulty.research = {
    research_time_multiplier = 1.25,  -- Research 25% slower
    engineer_efficiency = 0.85,       -- Engineers 15% less efficient
    breakthrough_chance = 0.05,       -- 5% chance instant complete
    
    tech_requirements = {
        additional_prerequisites = true,-- Some techs require extra research
        resource_costs_increased = true -- Higher material costs
    }
}
```

### AI Behavior

```lua
veteran_difficulty.ai = {
    -- Tactical AI
    flanking_priority = 0.90,         -- Aggressive flanking
    grenade_usage_chance = 0.70,      -- Use grenades frequently
    ability_usage_frequency = 0.95,   -- Use abilities often
    retreat_threshold = 0.20,         -- Retreat only when very damaged
    overwatch_trap_frequency = 0.70,  -- Set overwatch traps frequently
    suppression_usage = 0.80,         -- Use suppression often
    
    -- Strategic AI
    ufo_spawn_rate = 1.20,            -- +20% more UFOs
    alien_base_construction_rate = 1.30,-- Build bases faster
    infiltration_speed = 1.25,        -- Infiltrate countries faster
    terror_mission_frequency = 1.20,  -- More terror missions
    
    -- Advanced tactics
    coordinated_attacks = true,       -- Multiple aliens attack same target
    ability_combos = true,            -- Chain abilities strategically
    priority_targeting = true         -- Target weakened soldiers
}
```

### Special Features

```lua
veteran_difficulty.special = {
    permadeath = true,
    wound_recovery_multiplier = 1.50, -- 50% longer recovery
    panic_resistance = 0.80,          -- 20% easier to panic
    tutorial_hints_enabled = false,
    auto_save_frequency = "mission_start_only",
    mission_abort_penalty = 1.50,     -- 50% increased abort penalty
    
    second_wave_options = {           -- Optional modifiers
        "not_created_equal",          -- Random starting stats
        "hidden_potential",           -- Random stat growth
        "red_fog",                    -- Wounds reduce stats
        "absolutely_critical"         -- More critical hits
    }
}
```

---

## Impossible Difficulty

**Target Audience:** Hardcore players, extreme challenge, mastery required

### Philosophy
Extreme challenge designed for mastery. Every decision matters. Aliens use optimal tactics. Economy is severely constrained. Ironman mode enforced. Only for players seeking the ultimate test.

### Combat Modifiers

```lua
local impossible_difficulty = {
    name = "Impossible",
    description = "The ultimate test. Every decision matters. Ironman enforced. For masters only.",
    
    combat = {
        -- Severe player disadvantages
        xcom_aim_bonus = -10,          -- -10 aim penalty
        xcom_crit_chance_bonus = -5,   -- -5% crit chance
        xcom_damage_reduction = 1.10,  -- Take +10% more damage
        xcom_will_bonus = -10,         -- -10 will
        
        -- Extreme enemy advantages
        alien_hp_multiplier = 1.50,    -- +50% HP
        alien_aim_penalty = 20,        -- +20 aim bonus
        alien_crit_chance = 0.30,      -- 30% crit chance
        alien_damage_multiplier = 1.25,-- +25% damage
        alien_aggression = 1.50,       -- Maximum aggression
        
        enemy_squad_size_modifier = 4, -- +4 enemies per mission
        reinforcement_frequency = 1.50,-- 50% more reinforcements
        
        flanking_damage_bonus = 2.0,   -- +100% when flanking (double damage)
        overwatch_accuracy = 1.30,     -- +30% overwatch accuracy
        reaction_fire_chance = 1.2     -- 120% (multiple reaction shots possible)
    }
}

function apply_impossible_combat_modifiers(unit)
    if unit.faction == "XCOM" then
        unit.stats.aim = unit.stats.aim + impossible_difficulty.combat.xcom_aim_bonus
        unit.stats.will = unit.stats.will + impossible_difficulty.combat.xcom_will_bonus
        
        -- Additional penalties
        unit.stats.defense = math.floor(unit.stats.defense * 0.90)  -- -10% defense
        
    elseif unit.faction == "ALIEN" then
        unit.stats.hp = math.floor(unit.stats.hp * impossible_difficulty.combat.alien_hp_multiplier)
        unit.stats.aim = unit.stats.aim + impossible_difficulty.combat.alien_aim_penalty
        unit.stats.damage = math.floor(unit.stats.damage * impossible_difficulty.combat.alien_damage_multiplier)
        
        -- Additional bonuses
        unit.stats.mobility = unit.stats.mobility + 2  -- +2 mobility
        unit.stats.will = unit.stats.will + 10         -- +10 will (aliens harder to panic)
    end
end

function calculate_damage_impossible(base_damage, is_xcom_receiving, is_critical)
    local damage = base_damage
    
    if is_xcom_receiving then
        damage = math.floor(damage * impossible_difficulty.combat.xcom_damage_reduction)
        
        if is_critical then
            damage = damage * 2.0  -- Critical hits do double damage
        end
    end
    
    return damage
end
```

### Economic Modifiers

```lua
impossible_difficulty.economy = {
    starting_funds = 4000000,         -- $4M (severe reduction)
    monthly_funding_multiplier = 0.80,-- -20% council funding
    
    item_costs = {
        research_cost_multiplier = 1.30,    -- +30% research costs
        construction_cost_multiplier = 1.40,-- +40% building costs
        manufacturing_cost_multiplier = 1.25,-- +25% manufacturing costs
        soldier_salary_multiplier = 1.20    -- +20% salaries
    },
    
    rewards = {
        mission_reward_multiplier = 0.80,   -- -20% mission rewards
        item_sell_price_multiplier = 0.70   -- -30% sell prices
    },
    
    bankruptcy_threshold = -2,
    starting_resources = {
        elerium_115 = 0,
        alien_alloys = 0,
        weapon_fragments = 0           -- No starting resources
    },
    
    panic_consequences = {
        country_panic_threshold = 4,   -- Countries leave at panic 4 (vs 5)
        panic_increase_multiplier = 1.5 -- Panic increases 50% faster
    }
}
```

### Research & Engineering

```lua
impossible_difficulty.research = {
    research_time_multiplier = 1.50,  -- Research 50% slower
    engineer_efficiency = 0.70,       -- Engineers 30% less efficient
    breakthrough_chance = 0.0,        -- No instant research
    
    tech_requirements = {
        additional_prerequisites = true,
        resource_costs_increased = true,
        scientist_requirements = 1.25  -- Need 25% more scientists
    }
}
```

### AI Behavior

```lua
impossible_difficulty.ai = {
    -- Tactical AI (Optimal Play)
    flanking_priority = 1.0,          -- Always seek flanks
    grenade_usage_chance = 0.90,      -- Use grenades optimally
    ability_usage_frequency = 1.0,    -- Use abilities every opportunity
    retreat_threshold = 0.10,         -- Fight to near death
    overwatch_trap_frequency = 0.90,  -- Constant overwatch traps
    suppression_usage = 1.0,          -- Suppress whenever advantageous
    
    -- Strategic AI (Maximum Pressure)
    ufo_spawn_rate = 1.50,            -- +50% more UFOs
    alien_base_construction_rate = 1.50,-- Build bases much faster
    infiltration_speed = 1.50,        -- Infiltrate very fast
    terror_mission_frequency = 1.50,  -- Frequent terror missions
    
    -- Perfect tactics
    coordinated_attacks = true,
    ability_combos = true,
    priority_targeting = true,
    optimal_positioning = true,       -- AI calculates perfect positions
    predictive_movement = true,       -- AI predicts player actions
    
    -- Special AI behaviors
    leader_buffs_enabled = true,      -- Alien leaders buff nearby units
    pod_coordination = true           -- Multiple pods coordinate
}
```

### Special Features

```lua
impossible_difficulty.special = {
    permadeath = true,
    wound_recovery_multiplier = 2.0,  -- Double recovery time
    panic_resistance = 0.60,          -- 40% easier to panic
    tutorial_hints_enabled = false,
    ironman_mode = true,              -- ENFORCED - cannot be disabled
    auto_save_frequency = "every_action",-- Save after every action
    mission_abort_penalty = 2.0,      -- Double penalty for aborting
    
    hardcore_features = {
        no_save_scumming = true,      -- One save file, auto-overwrites
        permanent_injuries = true,    -- Soldiers can get permanent stat penalties
        morale_system = true,         -- Low morale affects performance
        supply_drops_reduced = true,  -- 50% fewer supply rewards
        will_penalty_on_death = true  -- Squad loses will when soldier dies
    },
    
    second_wave_options = {
        "not_created_equal",
        "hidden_potential",
        "red_fog",
        "absolutely_critical",
        "training_roulette",          -- Random ability trees
        "damage_roulette",            -- Random damage rolls
        "new_economy"                 -- Severe economic restrictions
    }
}

function handle_ironman_save()
    -- Single save file, overwrites on every action
    local save_data = game:serialize()
    love.filesystem.write("save/ironman.save", save_data)
    
    -- No backup copies allowed
    -- No manual save option
    -- Auto-save after every meaningful action
end
```

---

## Difficulty Comparison Examples

### Sample Mission: UFO Crash Site

```
Enemy Composition (Landed Scout):

Easy:
  3 Sectoids (48 HP each, 50 aim)
  1 Outsider (24 HP, 55 aim)
  Total: 4 enemies

Normal:
  4 Sectoids (60 HP each, 65 aim)
  1 Outsider (30 HP, 70 aim)
  Total: 5 enemies

Veteran:
  5 Sectoids (72 HP each, 75 aim)
  2 Outsiders (36 HP each, 80 aim)
  Total: 7 enemies

Impossible:
  6 Sectoids (90 HP each, 85 aim)
  2 Outsiders (45 HP each, 90 aim)
  1 Sectoid Commander (100 HP, 90 aim)
  Total: 9 enemies


Expected Outcome:

Easy: 95% mission success, 0-1 soldier wounded
Normal: 75% mission success, 1-2 soldiers wounded
Veteran: 50% mission success, 2-3 soldiers wounded, possible deaths
Impossible: 30% mission success, 3-4 soldiers wounded/killed
```

### Economic Scenario: Month 3

```
Starting Balance: $6,000,000

Monthly Income:
  Easy:     $7,200,000 (council funding) + $300K (sales) = $7.5M
  Normal:   $6,000,000 (council funding) + $200K (sales) = $6.2M
  Veteran:  $5,400,000 (council funding) + $150K (sales) = $5.55M
  Impossible: $4,800,000 (council funding) + $100K (sales) = $4.9M

Monthly Expenses:
  Easy:     $3,000,000 (reduced costs)
  Normal:   $3,800,000 (standard costs)
  Veteran:  $4,500,000 (increased costs)
  Impossible: $5,200,000 (severe costs)

Net Monthly:
  Easy:     +$4.5M (comfortable surplus)
  Normal:   +$2.4M (moderate surplus)
  Veteran:  +$1.05M (tight margin)
  Impossible: -$300K (operating at deficit)
```

---

## Mid-Campaign Difficulty Adjustment

### Rules and Restrictions

```lua
function can_change_difficulty(current_difficulty, new_difficulty, campaign_state)
    -- Can only change difficulty if:
    -- 1. Not in Ironman mode
    -- 2. Not in active mission
    -- 3. Campaign less than 6 months old (early-game only)
    
    if current_difficulty.ironman_mode then
        return false, "Cannot change difficulty in Ironman mode"
    end
    
    if campaign_state.in_mission then
        return false, "Cannot change difficulty during mission"
    end
    
    if campaign_state.months_elapsed > 6 then
        return false, "Cannot change difficulty after first 6 months"
    end
    
    -- Can only decrease difficulty (not increase)
    local difficulty_values = {Easy = 1, Normal = 2, Veteran = 3, Impossible = 4}
    if difficulty_values[new_difficulty.name] > difficulty_values[current_difficulty.name] then
        return false, "Can only decrease difficulty, not increase"
    end
    
    return true
end

function apply_difficulty_change(new_difficulty)
    game.ui:show_warning(
        "Difficulty Changed",
        string.format("Difficulty changed to %s. Changes take effect immediately.", 
            new_difficulty.name)
    )
    
    -- Recalculate all stats
    recalculate_unit_stats()
    recalculate_economy()
    recalculate_research_times()
    
    -- Log achievement impact
    game.achievements:disable_difficulty_achievements()
end
```

---

## Achievement Integration

### Difficulty-Based Achievements

```lua
local difficulty_achievements = {
    {
        id = "complete_easy",
        name = "Training Complete",
        description = "Complete the campaign on Easy difficulty",
        points = 10
    },
    {
        id = "complete_normal",
        name = "XCOM Commander",
        description = "Complete the campaign on Normal difficulty",
        points = 25
    },
    {
        id = "complete_veteran",
        name = "Elite Commander",
        description = "Complete the campaign on Veteran difficulty",
        points = 50
    },
    {
        id = "complete_impossible",
        name = "Impossible Odds",
        description = "Complete the campaign on Impossible difficulty",
        points = 100
    },
    {
        id = "impossible_ironman",
        name = "Legend",
        description = "Complete Impossible Ironman with no soldier deaths",
        points = 500,
        secret = true
    }
}
```

---

## Implementation Notes

### Love2D Difficulty Manager

```lua
-- Difficulty Manager (src/meta/difficulty_manager.lua)
local DifficultyManager = {
    current_difficulty = nil,
    difficulties = {
        easy = easy_difficulty,
        normal = normal_difficulty,
        veteran = veteran_difficulty,
        impossible = impossible_difficulty
    }
}

function DifficultyManager:set_difficulty(difficulty_name)
    self.current_difficulty = self.difficulties[difficulty_name]
    
    -- Apply modifiers globally
    self:apply_combat_modifiers()
    self:apply_economic_modifiers()
    self:apply_ai_modifiers()
    
    game.events:trigger("difficulty_changed", {difficulty = difficulty_name})
end

function DifficultyManager:get_modifier(category, stat_name)
    if not self.current_difficulty then
        return 1.0  -- Default to normal
    end
    
    return self.current_difficulty[category][stat_name] or 1.0
end

function DifficultyManager:apply_combat_modifiers()
    -- Apply to all existing units
    for _, unit in ipairs(game.units:get_all()) do
        self:apply_unit_modifiers(unit)
    end
end

function DifficultyManager:save()
    return {
        current_difficulty = self.current_difficulty.name,
        modifiers_applied = true
    }
end

function DifficultyManager:load(data)
    self:set_difficulty(data.current_difficulty or "normal")
end
```

---

## Cross-References

### Related Systems
- [Tutorial](Tutorial.md) - New player onboarding
- [AI Behavior](../ai/README.md) - AI tactical systems
- [Economy](../economy/README.md) - Economic balance
- [Combat](../battlescape/README.md) - Combat mechanics

### Related Mechanics
- [Stats](../units/Stats.md) - Unit statistics
- [Research](../economy/Research.md) - Research times
- [Panic](../geoscape/Panic.md) - Country panic mechanics

---

**Version:** 1.0  
**Last Updated:** September 30, 2025  
**Status:** Complete
