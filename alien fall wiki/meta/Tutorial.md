# Tutorial System

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
- [Examples](#examples)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Tutorial System provides progressive learning experiences for new players through contextual guidance, interactive training missions, skill introduction pacing, and graduated complexity that teaches Alien Fall's strategic and tactical mechanics without overwhelming players, supporting both optional tutorial missions and integrated contextual help throughout the campaign.  
**Related Systems:** [Difficulty Settings](Difficulty.md) | [Mission Types](../geoscape/Mission_Types.md) | [UI System](../widgets/README.md)

---

## Overview

The Tutorial Progression System guides new players through Alien Fall's complex mechanics using a structured, non-intrusive learning experience. The system combines guided missions, contextual tooltips, progressive unlocks, and optional help text to ensure players understand core concepts without overwhelming them.

### Purpose
- Introduce game mechanics progressively over first 3-5 hours
- Provide contextual help without interrupting experienced players
- Gate advanced systems until basics are understood
- Build confidence through scaffolded challenges
- Enable tutorial skip for veteran players

### Design Philosophy
- **Show, Don't Tell**: Demonstrate mechanics through gameplay
- **Just-In-Time Learning**: Introduce concepts when immediately relevant
- **Optional Depth**: Allow players to explore advanced topics at their own pace
- **Non-Blocking**: Tutorial never prevents experienced players from acting
- **Graceful Degradation**: Tutorial can be disabled completely

---

## Tutorial Structure

### Three-Tier Learning System

```
┌─────────────────────────────────────────────────────────────┐
│                    TUTORIAL TIERS                           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Tier 1: MANDATORY TUTORIAL                                │
│  ├─ Tutorial Mission 1: Basic Movement & Combat            │
│  ├─ Tutorial Mission 2: Cover & Abilities                  │
│  └─ Tutorial Mission 3: Squad Tactics                      │
│  Duration: 45-60 minutes                                    │
│  Completion: Required to unlock campaign                    │
│                                                             │
│  Tier 2: GUIDED CAMPAIGN START                             │
│  ├─ First Real Mission (with hints)                        │
│  ├─ Base Management Introduction                           │
│  ├─ Research & Engineering Unlocks                         │
│  └─ Interception Introduction                              │
│  Duration: 2-3 hours                                        │
│  Completion: Unlocks all systems                            │
│                                                             │
│  Tier 3: CONTEXTUAL HELP                                   │
│  ├─ Tooltips on hover (always available)                   │
│  ├─ Help screens (F1 key)                                  │
│  ├─ Pedia entries (unlocked by discovery)                  │
│  └─ Advanced tactics tips (optional)                       │
│  Duration: Entire campaign                                  │
│  Completion: Never expires                                  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Tier 1: Mandatory Tutorial Missions

### Tutorial Mission 1: Basic Movement & Combat

**Objective:** Learn fundamental tactical controls and combat mechanics.

#### Mission Setup
```lua
local tutorial_mission_1 = {
    name = "Training Exercise: First Contact",
    location = "XCOM Training Facility",
    type = "tutorial",
    map = "tutorial_warehouse",  -- Controlled environment
    
    squad = {
        {name = "Rookie Smith", class = "assault", weapon = "assault_rifle"},
        {name = "Rookie Jones", class = "assault", weapon = "assault_rifle"},
        {name = "Rookie Chen", class = "assault", weapon = "assault_rifle"},
        {name = "Rookie Garcia", class = "assault", weapon = "assault_rifle"}
    },
    
    enemies = {
        {type = "sectoid", count = 3, behavior = "passive_until_engaged"},
        {type = "sectoid", count = 2, behavior = "patrol"}
    },
    
    time_limit = nil,  -- No time pressure
    failure_allowed = false,  -- Cannot game over
    
    completion_time = "15-20 minutes"
}
```

#### Learning Sequence

```
Step 1: Camera & UI (2 minutes)
  Tutorial Prompt: "Welcome to XCOM, Commander. Let's start with the basics."
  
  Tasks:
    - Move camera with WASD or arrow keys
    - Zoom with mouse wheel
    - Select unit by clicking
    - Read UI: HP, AP, abilities displayed
  
  UI Highlights:
    ┌─────────────────────────────────────────┐
    │ [Highlight: Unit Panel]                 │
    │ "This shows your selected soldier's     │
    │  stats: Health (HP), Action Points (AP),│
    │  and available abilities."              │
    └─────────────────────────────────────────┘
  
  Completion: Select all 4 units in sequence

Step 2: Basic Movement (5 minutes)
  Tutorial Prompt: "Move your squad to the marked positions."
  
  Tasks:
    - Click soldier to select
    - Click blue tiles to move
    - Observe AP cost (2 AP for normal move)
    - Move all 4 soldiers to waypoints
  
  Visual Aid:
    - Blue tiles indicate movement range
    - Yellow tiles show selected destination
    - Green waypoint markers show target positions
  
  Completion: All 4 soldiers reach waypoints

Step 3: Basic Combat (8 minutes)
  Tutorial Prompt: "Hostile targets detected! Engage the aliens."
  
  Tasks:
    - Enemy appears in line of sight
    - Select soldier with shots available
    - Click enemy to target
    - Confirm attack (left-click enemy)
    - Observe hit chance percentage
    - Take shot
  
  Combat Flow:
    1. Select soldier (Smith)
    2. Highlight: "This enemy is in range. Click to attack."
    3. Display hit chance: 85%
    4. Confirm attack → Show animation
    5. Hit/Miss result → Display damage
    6. Enemy turn (they miss intentionally)
    7. Your turn: Eliminate remaining enemies
  
  Tip Display:
    "Higher ground and closer range improve hit chance."
    "Flanked enemies (no cover) are easier to hit."
  
  Completion: Eliminate all 5 enemies

Step 4: Turn Structure (2 minutes)
  Tutorial Prompt: "Each soldier has 4 Action Points (AP) per turn."
  
  Tasks:
    - End turn with button
    - Watch enemy turn (they move but don't shoot)
    - Begin new turn
    - Observe AP refresh
  
  Completion: Complete one full turn cycle

Step 5: Mission Complete (1 minute)
  Victory Screen:
    "Mission Complete! You've mastered the basics."
    - Show stats: Enemies killed, shots taken, accuracy
    - Award XP to soldiers
    - Unlock Tutorial Mission 2
```

#### Gating Rules

```lua
function check_tutorial_1_completion()
    local completion_flags = {
        camera_movement = false,
        unit_selection = false,
        movement_executed = false,
        combat_executed = false,
        turn_cycle_complete = false
    }
    
    -- All flags must be true to proceed
    for flag, value in pairs(completion_flags) do
        if not value then
            return false, "Complete all tutorial steps"
        end
    end
    
    return true
end
```

### Tutorial Mission 2: Cover & Abilities

**Objective:** Learn cover mechanics, overwatch, and basic abilities.

#### Mission Setup
```lua
local tutorial_mission_2 = {
    name = "Training Exercise: Advanced Tactics",
    location = "XCOM Urban Combat Range",
    type = "tutorial",
    map = "tutorial_urban",
    
    squad = {
        {name = "Squaddie Smith", class = "assault", weapon = "assault_rifle", 
         abilities = {"run_and_gun"}},
        {name = "Squaddie Jones", class = "sniper", weapon = "sniper_rifle",
         abilities = {"headshot"}},
        {name = "Squaddie Chen", class = "heavy", weapon = "lmg",
         abilities = {"suppression"}},
        {name = "Squaddie Garcia", class = "support", weapon = "assault_rifle",
         abilities = {"smoke_grenade"}}
    },
    
    enemies = {
        {type = "sectoid", count = 4, behavior = "use_cover"},
        {type = "floater", count = 2, behavior = "flank"}
    },
    
    completion_time = "20-25 minutes"
}
```

#### Learning Sequence

```
Step 1: Cover System (5 minutes)
  Tutorial Prompt: "Position your soldiers behind cover."
  
  Tasks:
    - Move to half-cover position (shield icon: ▤)
    - Move to full-cover position (shield icon: █)
    - Observe cover bonus on hit chance
  
  Visual Indicators:
    Half Cover: Yellow shield (▤) = +20 defense
    Full Cover: Green shield (█) = +40 defense
    No Cover: Red X (✗) = +0 defense
  
  Tip: "Full cover provides better protection than half cover."
  
  Completion: All soldiers in cover

Step 2: Overwatch (4 minutes)
  Tutorial Prompt: "Set soldiers on Overwatch to ambush enemies."
  
  Tasks:
    - Select soldier
    - Click Overwatch ability (costs 2 AP)
    - End turn
    - Watch Overwatch trigger on enemy movement
  
  Demonstration:
    - Enemy moves into LoS
    - Overwatch shot fires automatically
    - Display reaction fire mechanics
  
  Tip: "Overwatch is great for defensive positions."
  
  Completion: Successfully trigger 2+ Overwatch shots

Step 3: Class Abilities (8 minutes)
  Tutorial Prompt: "Use your class abilities strategically."
  
  Tasks:
    A. Assault: Run & Gun
       - Move full distance and still shoot
       - Flank exposed enemy
    
    B. Sniper: Headshot
       - Use bonus damage ability
       - Take down high-value target
    
    C. Heavy: Suppression
       - Pin down enemy with sustained fire
       - Reduce enemy aim and mobility
    
    D. Support: Smoke Grenade
       - Provide defensive bonus to allies
       - Protect wounded soldier
  
  Completion: Use each ability at least once

Step 4: Combined Arms (5 minutes)
  Tutorial Prompt: "Coordinate your squad to eliminate remaining enemies."
  
  Scenario:
    - 3 enemies in cover
    - Must use abilities to gain advantage
  
  Suggested Strategy:
    1. Support throws smoke for cover
    2. Heavy suppresses priority target
    3. Assault flanks with Run & Gun
    4. Sniper takes Headshot on weakened target
  
  Completion: Eliminate all enemies

Step 5: After-Action Report (2 minutes)
  Victory Screen with detailed stats:
    - Abilities used: 4/4 ✓
    - Cover effectiveness: 85%
    - Overwatch kills: 2
    - Unit survival: 4/4
  
  Unlock: Tutorial Mission 3
```

### Tutorial Mission 3: Squad Tactics

**Objective:** Learn advanced tactics, grenades, and squad coordination.

#### Mission Setup
```lua
local tutorial_mission_3 = {
    name = "Training Exercise: Squad Coordination",
    location = "XCOM Multi-Level Training Ground",
    type = "tutorial",
    map = "tutorial_multi_level",
    
    squad = {
        {name = "Corporal Smith", class = "assault", 
         abilities = {"run_and_gun", "flush"}},
        {name = "Corporal Jones", class = "sniper",
         abilities = {"headshot", "squad_sight"}},
        {name = "Corporal Chen", class = "heavy",
         abilities = {"suppression", "shredder_rocket"}},
        {name = "Corporal Garcia", class = "support",
         abilities = {"smoke_grenade", "field_medic"}},
        {name = "Corporal Lee", class = "assault",
         abilities = {"run_and_gun", "flush"}},
        {name = "Corporal Patel", class = "heavy",
         abilities = {"suppression", "bullet_swarm"}}
    },
    
    enemies = {
        {type = "sectoid", count = 3, behavior = "defensive"},
        {type = "floater", count = 3, behavior = "aggressive"},
        {type = "thin_man", count = 2, behavior = "sniper"}
    },
    
    objectives = {
        "Eliminate all enemies",
        "Keep all soldiers alive",
        "Use grenades effectively"
    },
    
    completion_time = "30-35 minutes"
}
```

#### Learning Sequence

```
Step 1: Grenades & Explosives (5 minutes)
  Tutorial Prompt: "Use grenades to destroy cover and damage enemies."
  
  Tasks:
    - Select soldier with grenade
    - Target area with multiple enemies
    - Observe blast radius (red circle)
    - Throw grenade (costs 1 AP)
    - See cover destruction
  
  Grenade Types:
    - Frag Grenade: 3 damage, 3-tile radius, destroys cover
    - Smoke Grenade: No damage, +20 defense, 4-tile radius
  
  Tip: "Grenades always hit but do less damage than weapons."
  
  Completion: Destroy cover with grenade

Step 2: Height Advantage (4 minutes)
  Tutorial Prompt: "Position snipers on high ground for bonuses."
  
  Tasks:
    - Move sniper to elevated position
    - Observe aim bonus (+10/+20 per level)
    - Take shot from high ground
  
  Mechanics:
    1 level higher: +10 aim
    2 levels higher: +20 aim
    LoS improved from elevation
  
  Completion: Kill enemy from high ground

Step 3: Squad Sight (5 minutes)
  Tutorial Prompt: "Snipers can shoot targets spotted by allies."
  
  Tasks:
    - Position sniper in secure rear position
    - Move scout forward to spot enemies
    - Sniper shoots target they can't directly see
    - Use Squad Sight ability
  
  Visual Aid:
    - Blue line shows spotter
    - Red line shows sniper shot path
    - "Squad Sight Active" indicator
  
  Tip: "Snipers are most effective from safe positions."
  
  Completion: Kill enemy with Squad Sight

Step 4: Focus Fire (6 minutes)
  Tutorial Prompt: "Concentrate fire to eliminate high-priority targets."
  
  Scenario:
    - Floater (high threat, moderate HP)
    - 2 Sectoids (low threat, low HP)
  
  Recommended Strategy:
    1. Suppress Floater (reduce threat)
    2. All other units shoot Floater
    3. Eliminate Floater in one turn
    4. Mop up Sectoids next turn
  
  Tip: "Killing one enemy is better than wounding two."
  
  Completion: Eliminate priority target in one turn

Step 5: Medical Support (4 minutes)
  Tutorial Prompt: "Heal wounded soldiers with the Medkit."
  
  Tasks:
    - Soldier takes intentional damage
    - Support uses Field Medic ability
    - Restore HP to wounded unit
    - Observe heal amount (4 HP)
  
  Mechanics:
    - Medkit: Heal 4 HP, costs 1 AP
    - Field Medic: Bonus heal amount
    - Can stabilize critically wounded
  
  Completion: Successfully heal wounded soldier

Step 6: Final Engagement (8 minutes)
  Tutorial Prompt: "Use everything you've learned to win."
  
  Scenario:
    - 4 enemies in fortified positions
    - Must use combined tactics
    - No hand-holding
  
  Available Tools:
    - Cover and movement
    - All class abilities
    - Grenades
    - Overwatch
    - Height advantage
  
  Victory Condition: Eliminate all enemies, no deaths
  
  Completion: Mission success

Step 7: Tutorial Complete (2 minutes)
  Final Victory Screen:
    "Congratulations, Commander!"
    "You have completed XCOM Basic Training."
    
    Final Stats:
    - Missions: 3/3 ✓
    - Soldiers Lost: 0
    - Enemies Eliminated: 18
    - Overall Accuracy: 72%
    
    Unlock: Full Campaign Access
```

---

## Tier 2: Guided Campaign Start

### Unlock Progression

After completing the tutorial, systems unlock progressively:

```
┌────────────────────────────────────────────────────────────┐
│              SYSTEM UNLOCK PROGRESSION                     │
├────────────────────────────────────────────────────────────┤
│                                                            │
│ Day 1 (Tutorial Complete):                                │
│   ✓ Geoscape View                                         │
│   ✓ Base Management (limited)                             │
│   ✓ Soldier Roster                                        │
│   ✓ Barracks                                              │
│   ✓ Mission Selection                                     │
│                                                            │
│ Day 3 (After First Mission):                              │
│   ✓ Research System                                       │
│   ✓ Engineering/Manufacturing                             │
│   ✓ Facility Construction                                 │
│   ✓ Item Management                                       │
│                                                            │
│ Day 7 (First Week):                                       │
│   ✓ Interception Mechanics                                │
│   ✓ Air Combat                                            │
│   ✓ Craft Management                                      │
│   ✓ Multiple Bases                                        │
│                                                            │
│ Day 14 (Two Weeks):                                       │
│   ✓ Advanced Research                                     │
│   ✓ Alien Containment                                     │
│   ✓ Psionic Lab (if researched)                           │
│   ✓ All Systems Unlocked                                  │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

### First Campaign Mission (Guided)

```lua
local first_campaign_mission = {
    name = "Operation First Contact",
    type = "ufo_crash",
    difficulty = "easy",
    
    guidance = {
        enabled = true,
        hints = {
            "Advance carefully - enemies are unpredictable",
            "Use Overwatch when uncertain",
            "Flank exposed enemies for easy kills",
            "Retreat if overwhelmed - survival is priority"
        },
        
        assistance = {
            enemy_count_visible = true,  -- Show enemy counter
            tactical_assessment = true,  -- Show threat level
            positioning_hints = true     -- Highlight good cover
        }
    },
    
    optional_objectives = {
        {name = "Recover UFO Power Source", reward = "$50,000"},
        {name = "Capture Alien Alive", reward = "Alien Containment research"}
    }
}
```

### Base Management Introduction

```
Triggered After: First mission victory

Tutorial Sequence:
  1. Show Base View
     - "Welcome to your headquarters, Commander."
     - Highlight key areas: Barracks, Research, Engineering
  
  2. Soldier Management
     - "Review your soldiers' performance."
     - Show XP gained, wounds, promotions
     - Assign abilities (if promotion available)
  
  3. Research Introduction
     - "Our scientists can study alien technology."
     - Assign first research project (Alien Weapon Fragments)
     - Show research time and requirements
  
  4. Engineering Introduction
     - "Engineers can build facilities and manufacture items."
     - Show available construction projects
     - Explain resource costs
  
  5. Facility Tour
     - Highlight Living Quarters, Lab, Workshop
     - Show excavation system
     - Explain expansion strategy

Completion: Assign first research project
```

### Interception Introduction

```
Triggered After: First UFO detection on Geoscape

Tutorial Sequence:
  1. Detection Alert
     - "Commander, we've detected a UFO!"
     - Show UFO on Geoscape
     - Explain detection mechanics
  
  2. Interceptor Launch
     - "Launch an interceptor to engage."
     - Select craft from hangar
     - Assign to intercept mission
  
  3. Air Combat Tutorial
     - Simplified first engagement
     - Explain: Distance, weapons, evasion
     - UFO has reduced HP for tutorial
  
  4. Mission Launch
     - UFO crashes
     - "Deploy a squad to investigate."
     - Standard mission with reduced enemy count

Completion: Win first air combat + mission
```

---

## Tier 3: Contextual Help System

### Tooltip System

```lua
local TooltipSystem = {
    enabled = true,
    delay = 0.5,  -- Seconds before tooltip appears
    
    tooltips = {}
}

function TooltipSystem:register(element_id, tooltip_data)
    self.tooltips[element_id] = {
        title = tooltip_data.title,
        description = tooltip_data.description,
        hotkey = tooltip_data.hotkey,
        related_help = tooltip_data.related_help_page
    }
end

-- Example: Action Point tooltip
TooltipSystem:register("action_points_ui", {
    title = "Action Points (AP)",
    description = "Action Points determine how many actions a soldier can take per turn.\n\n"..
                  "• Move: 2 AP (half move: 1 AP)\n"..
                  "• Shoot: 2 AP\n"..
                  "• Reload: 1 AP\n"..
                  "• Abilities: 1-4 AP (varies)\n\n"..
                  "Soldiers have 4 AP per turn.",
    hotkey = nil,
    related_help_page = "wiki/core/Action_Economy.md"
})

-- Example: Cover tooltip
TooltipSystem:register("cover_indicator", {
    title = "Cover",
    description = "Cover provides defense against enemy attacks.\n\n"..
                  "Half Cover (▤): +20 defense\n"..
                  "Full Cover (█): +40 defense\n"..
                  "No Cover (✗): +0 defense\n\n"..
                  "Flanking removes cover bonuses.",
    hotkey = nil,
    related_help_page = "wiki/battlescape/Cover.md"
})

function TooltipSystem:render(element_id, mouse_x, mouse_y)
    local tooltip = self.tooltips[element_id]
    if not tooltip then return end
    
    local tooltip_width = 300
    local tooltip_height = 150
    
    -- Position near mouse, but keep on screen
    local x = mouse_x + 10
    local y = mouse_y + 10
    
    if x + tooltip_width > love.graphics.getWidth() then
        x = mouse_x - tooltip_width - 10
    end
    
    -- Draw tooltip background
    love.graphics.setColor(0.1, 0.1, 0.1, 0.95)
    love.graphics.rectangle("fill", x, y, tooltip_width, tooltip_height, 5, 5)
    
    -- Draw border
    love.graphics.setColor(0.8, 0.8, 0.8, 1.0)
    love.graphics.rectangle("line", x, y, tooltip_width, tooltip_height, 5, 5)
    
    -- Draw title
    love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
    love.graphics.setFont(fonts.tooltip_title)
    love.graphics.print(tooltip.title, x + 10, y + 10)
    
    -- Draw description
    love.graphics.setFont(fonts.tooltip_body)
    love.graphics.printf(tooltip.description, x + 10, y + 35, tooltip_width - 20)
    
    -- Draw hotkey (if any)
    if tooltip.hotkey then
        love.graphics.setFont(fonts.tooltip_small)
        love.graphics.print("[" .. tooltip.hotkey .. "]", x + 10, y + tooltip_height - 25)
    end
end
```

### Help Screen System (F1)

```lua
function open_help_screen(context)
    local help_screen = {
        context = context,  -- "geoscape", "battlescape", "base", etc.
        pages = load_help_pages(context)
    }
    
    game.ui:show_screen("help", help_screen)
end

-- Example: Battlescape help
local battlescape_help = {
    title = "Tactical Combat Help",
    
    sections = {
        {
            title = "Movement",
            content = "Click blue tiles to move. Yellow tiles require full AP. "..
                      "Ctrl+Click for half-move (saves AP for shooting)."
        },
        {
            title = "Combat",
            content = "Click enemies to attack. Hit chance shown as percentage. "..
                      "Flanked enemies (no cover) are easier to hit."
        },
        {
            title = "Abilities",
            content = "Click ability buttons at bottom of screen. Costs vary. "..
                      "Hover for description and AP cost."
        },
        {
            title = "Cover",
            content = "Half cover (▤): +20 defense\n"..
                      "Full cover (█): +40 defense\n"..
                      "Flanking removes cover bonuses."
        },
        {
            title = "Overwatch",
            content = "Soldiers on Overwatch fire at enemies who move in LoS. "..
                      "Great for defensive positions and ambushes."
        }
    },
    
    hotkeys = {
        {"Tab", "Cycle through soldiers"},
        {"Space", "End turn"},
        {"R", "Reload weapon"},
        {"O", "Toggle Overwatch"},
        {"G", "Throw grenade"},
        {"F1", "Open this help screen"}
    }
}
```

### Advanced Tactics Tips

```lua
-- Triggered contextually during gameplay
local advanced_tips = {
    {
        trigger = "enemy_flanked_repeatedly",
        tip = "ADVANCED TIP: Flanking\n\n"..
              "Enemies lose cover bonuses when flanked. Position soldiers to "..
              "attack from multiple angles for maximum effectiveness.",
        frequency = "once"
    },
    
    {
        trigger = "soldier_wounded_no_heal",
        tip = "ADVANCED TIP: Medical Support\n\n"..
              "Wounded soldiers are at risk. Consider bringing a Support class "..
              "with medkits on all missions.",
        frequency = "once"
    },
    
    {
        trigger = "overwatch_trap_success",
        tip = "ADVANCED TIP: Overwatch Traps\n\n"..
              "You successfully ambushed enemies with Overwatch! This tactic "..
              "works great when you know enemy patrol routes.",
        frequency = "once"
    },
    
    {
        trigger = "height_advantage_used",
        tip = "ADVANCED TIP: High Ground\n\n"..
              "Snipers gain +10 aim per elevation level. Always position them "..
              "on rooftops or hills for maximum effectiveness.",
        frequency = "once"
    }
}

function check_advanced_tips(game_state)
    for _, tip_config in ipairs(advanced_tips) do
        if check_trigger(tip_config.trigger, game_state) then
            if not was_tip_shown(tip_config) or tip_config.frequency ~= "once" then
                show_tip(tip_config.tip)
                mark_tip_shown(tip_config)
            end
        end
    end
end
```

---

## Tutorial Skip Option

### For Veteran Players

```lua
function show_tutorial_skip_prompt()
    local prompt = {
        title = "Tutorial",
        message = "Would you like to play the tutorial missions?\n\n"..
                  "Recommended for new players.\n"..
                  "Veterans can skip to the campaign.",
        
        options = {
            {
                text = "Play Tutorial",
                action = function()
                    start_tutorial_mission_1()
                end
            },
            {
                text = "Skip Tutorial",
                action = function()
                    unlock_all_systems()
                    start_campaign_with_bonus()
                end,
                warning = "Are you sure? Tutorial provides helpful training."
            }
        }
    }
    
    game.ui:show_prompt(prompt)
end

function start_campaign_with_bonus()
    -- Grant veteran bonuses
    game.campaign:add_funds(500000)  -- Extra $500K starting funds
    game.campaign:add_scientists(5)  -- 5 extra scientists
    game.campaign:add_engineers(5)   -- 5 extra engineers
    game.campaign:unlock_all_systems()
    
    -- Start on Geoscape
    game:change_scene("geoscape")
end
```

---

## Difficulty Curve

### Tutorial Difficulty Scaling

```
Tutorial Mission Difficulty Curve:
  
  Mission 1: Very Easy
    - 5 enemies (weak Sectoids)
    - Enemies intentionally miss shots
    - No time pressure
    - Cannot game over
    Difficulty: 1/10
  
  Mission 2: Easy
    - 6 enemies (Sectoids + Floaters)
    - Enemies use cover but poor tactics
    - Minimal flanking
    - Low lethality
    Difficulty: 3/10
  
  Mission 3: Easy-Normal
    - 8 enemies (mixed types)
    - Enemies use proper tactics
    - Active flanking attempts
    - Real threat (but forgiving)
    Difficulty: 4/10
  
  First Campaign Mission: Normal
    - 6-8 enemies (appropriate for level)
    - Standard AI behavior
    - Hints provided
    - Real risk of soldier loss
    Difficulty: 5/10
  
  Second Campaign Mission: Normal
    - 8-10 enemies
    - No hints (unless requested)
    - Full difficulty
    Difficulty: 6/10
```

### Learning Curve Analysis

```
Player Skill Development Timeline:

Hour 1 (Tutorial Missions 1-2):
  Skills Learned:
    ✓ Camera controls
    ✓ Unit selection and movement
    ✓ Basic combat (shooting)
    ✓ Cover mechanics
    ✓ Turn structure
    ✓ Overwatch
    ✓ Basic abilities
  
  Confidence Level: 40%

Hour 2 (Tutorial Mission 3 + First Campaign):
  Skills Learned:
    ✓ Grenades and explosives
    ✓ Height advantage
    ✓ Squad coordination
    ✓ Focus fire
    ✓ Medical support
    ✓ Multiple enemy types
  
  Confidence Level: 65%

Hour 3-5 (Guided Campaign):
  Skills Learned:
    ✓ Base management
    ✓ Research priorities
    ✓ Facility construction
    ✓ Interception mechanics
    ✓ Squad composition
    ✓ Resource management
  
  Confidence Level: 80%

Hour 5+ (Independent Play):
  Skills Refined:
    ✓ Advanced tactics
    ✓ Long-term strategy
    ✓ Optimal builds
    ✓ Crisis management
  
  Confidence Level: 95%
```

---

## Implementation Notes

### Tutorial State Management

```lua
-- Tutorial Manager (src/tutorial/tutorial_manager.lua)
local TutorialManager = {
    enabled = true,
    current_mission = nil,
    completed_missions = {},
    unlocked_systems = {},
    shown_tips = {}
}

function TutorialManager:start_tutorial()
    self.current_mission = "tutorial_1"
    game:load_mission(tutorial_missions[self.current_mission])
end

function TutorialManager:complete_mission(mission_id)
    table.insert(self.completed_missions, mission_id)
    
    if mission_id == "tutorial_1" then
        self:unlock_system("tutorial_2")
    elseif mission_id == "tutorial_2" then
        self:unlock_system("tutorial_3")
    elseif mission_id == "tutorial_3" then
        self:unlock_all_systems()
        self:start_campaign()
    end
end

function TutorialManager:unlock_system(system_name)
    self.unlocked_systems[system_name] = true
    game.events:trigger("system_unlocked", {system = system_name})
end

function TutorialManager:is_system_unlocked(system_name)
    if not self.enabled then return true end
    return self.unlocked_systems[system_name] == true
end

function TutorialManager:disable_tutorial()
    self.enabled = false
    self:unlock_all_systems()
end

function TutorialManager:save()
    return {
        enabled = self.enabled,
        completed_missions = self.completed_missions,
        unlocked_systems = self.unlocked_systems,
        shown_tips = self.shown_tips
    }
end

function TutorialManager:load(data)
    self.enabled = data.enabled
    self.completed_missions = data.completed_missions or {}
    self.unlocked_systems = data.unlocked_systems or {}
    self.shown_tips = data.shown_tips or {}
end
```

---

## Cross-References

### Related Systems
- [Difficulty Settings](Difficulty.md) - Adjust challenge level
- [Mission Types](../geoscape/Mission_Types.md) - Mission variety
- [UI System](../widgets/README.md) - UI implementation
- [Save System](../technical/Save_System.md) - Progress persistence

### Related Mechanics
- [Combat System](../battlescape/README.md) - Tactical mechanics
- [Base Management](../basescape/README.md) - Strategic layer
- [Unit System](../units/README.md) - Soldier progression

---

**Version:** 1.0  
**Last Updated:** September 30, 2025  
**Status:** Complete
