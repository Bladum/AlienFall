# Tech Tree

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
- [Examples](#examples)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Tech Tree system structures research progression through interconnected technology nodes with dependency chains, resource costs, and time requirements that gate access to advanced equipment, facilities, and strategic capabilities in Alien Fall, creating meaningful progression choices and strategic planning opportunities through branching paths and prerequisite relationships.

---

## Table of Contents
- [Overview](#overview)
- [Tech Tree Diagram](#tech-tree-diagram)
- [Research Paths](#research-paths)
- [Weapons Research Tree](#weapons-research-tree)
- [Armor Research Tree](#armor-research-tree)
- [Craft Research Tree](#craft-research-tree)
- [Facilities Research Tree](#facilities-research-tree)
- [Alien Technology Tree](#alien-technology-tree)
- [Research Mechanics](#research-mechanics)
- [Lua Implementation](#lua-implementation)
- [Integration Points](#integration-points)
- [Cross-References](#cross-references)

---

## Overview

The Technology Tree represents the research progression system that unlocks new equipment, facilities, and capabilities. Research follows dependency chains where advanced technologies require prerequisite discoveries. The tree branches into parallel paths (weapons, armor, craft, facilities) that eventually converge on ultimate technologies.

**Core Principles:**
- **Dependency Chains:** Advanced tech requires completing prerequisite research
- **Parallel Paths:** Multiple research branches can progress simultaneously
- **Item Requirements:** Some research requires captured alien items
- **Time Investment:** Research projects take days to months to complete
- **Resource Cost:** Research consumes scientist time and funding

---

## Tech Tree Diagram

### Complete Technology Dependency Map

```
                        STARTING TECHNOLOGIES
                                  |
                +-----------------+-----------------+
                |                 |                 |
            WEAPONS           ARMOR             FACILITIES
                |                 |                 |
                v                 v                 v
    
    ┌───────────────────────────────────────────────────────────────────────┐
    │                         CONVENTIONAL ERA                              │
    └───────────────────────────────────────────────────────────────────────┘
    
    Advanced Ballistics     Body Armor           Radar Systems
         (3 days)            (5 days)              (7 days)
            |                   |                     |
            v                   v                     v
    Explosive Compounds    Tactical Vest         Long Range Radar
         (5 days)            (7 days)             (10 days)
            |                   |                     |
            |                   |                     |
    ┌───────────────────────────────────────────────────────────────────────┐
    │                 FIRST BREAKTHROUGH: LASER TECHNOLOGY                  │
    │                  Requires: UFO Power Source (item)                    │
    └───────────────────────────────────────────────────────────────────────┘
            |                   |                     |
            v                   v                     v
    Laser Weaponry        Laser-Resistant        Advanced Sensors
       (15 days)             Armor                 (12 days)
    [UFO Power]            (12 days)                   |
            |            [Alien Alloys]                v
            v                   |              Hyperwave Decoder
    Heavy Laser             Powered Armor           (20 days)
       (20 days)             (18 days)          [UFO Navigation]
            |            [UFO Power + Alloys]
            |                   |
    ┌───────────────────────────────────────────────────────────────────────┐
    │              SECOND BREAKTHROUGH: PLASMA TECHNOLOGY                   │
    │              Requires: Plasma Weapon (item) + Elerium                 │
    └───────────────────────────────────────────────────────────────────────┘
            |                   |                     |
            v                   v                     v
    Plasma Weaponry        Plasma Armor          Improved Craft
       (25 days)            (25 days)             (30 days)
    [Plasma Weapon]      [Alien Alloys]              |
            |            [Elerium]                    v
            v                   |                Firestorm
    Heavy Plasma            Fusion Armor         (45 days)
       (30 days)            (35 days)         [Alien Nav + Power]
            |            [Elerium]
            |                   |
    ┌───────────────────────────────────────────────────────────────────────┐
    │               THIRD BREAKTHROUGH: FUSION TECHNOLOGY                   │
    │           Requires: Elerium 115 + Alien Computer Core                 │
    └───────────────────────────────────────────────────────────────────────┘
            |                   |                     |
            v                   v                     v
    Fusion Weapons        Alien Alloy Armor      Avenger Craft
       (40 days)            (40 days)             (60 days)
    [Elerium 115]       [Alien Alloys]        [Complete UFO]
            |            [Elerium 115]
            v                   |
    Blaster Launcher        Personal              Mind Shield
       (50 days)            Flying Suit          (30 days)
    [Blaster Bomb]         (45 days)         [Sectoid Commander]
                        [Alien Materials]
    
    ┌───────────────────────────────────────────────────────────────────────┐
    │                      ULTIMATE TECHNOLOGY PATH                         │
    │                  Requires: All Alien Species Research                 │
    └───────────────────────────────────────────────────────────────────────┘
                                  |
                                  v
                        Alien Origins (90 days)
                        [All Alien Leaders]
                                  |
                                  v
                        Hyperspace Drive (120 days)
                        [Ethereal Commander]
                                  |
                                  v
                        Final Mission Unlock
```

### Parallel Research Tracks

```
WEAPONS TRACK          ARMOR TRACK          FACILITIES TRACK       CRAFT TRACK
    
Ballistics     -->     Body Armor    -->    Small Radar    -->    Interceptor
    |                      |                     |                     |
Explosives     -->    Tactical Vest  -->   Large Radar    -->    Skyrangers
    |                      |                     |                     |
Laser Tech     -->   Laser Armor    -->    Hyperwave      -->   Firestorm
    |                      |                     |                     |
Plasma Tech    -->   Plasma Armor   -->   Alien Labs     -->   Lightning
    |                      |                     |                     |
Fusion Tech    -->   Fusion Armor   -->   Mind Shield    -->   Avenger
    |                      |                     |                     |
Blaster Bomb   -->   Flying Suit    -->   Grav Shield    -->   Ultimate
```

---

## Research Paths

### Early Game Research Priority (Months 1-3)

```lua
-- Recommended research sequence for early game
EarlyGameResearch = {
    {
        name = "Advanced Ballistics",
        priority = "HIGH",
        reason = "Unlocks better conventional weapons",
        time = 3,
        cost = "$50,000",
        unlocks = {"Sniper Rifle", "Heavy Machine Gun"},
    },
    {
        name = "Explosive Compounds",
        priority = "HIGH",
        reason = "Better grenades and rockets",
        time = 5,
        cost = "$75,000",
        unlocks = {"High Explosive", "Proximity Mine"},
        requires = {"Advanced Ballistics"},
    },
    {
        name = "Body Armor",
        priority = "CRITICAL",
        reason = "Soldier survival improvement",
        time = 5,
        cost = "$100,000",
        unlocks = {"Personal Armor"},
    },
    {
        name = "Long Range Radar",
        priority = "MEDIUM",
        reason = "Detect UFOs earlier",
        time = 10,
        cost = "$150,000",
        unlocks = {"Long Range Radar Facility"},
        requires = {"Radar Systems"},
    },
}
```

### Mid Game Research Priority (Months 4-6)

```lua
-- Laser technology breakthrough
MidGameResearch = {
    {
        name = "Laser Weaponry",
        priority = "CRITICAL",
        reason = "First major tech leap",
        time = 15,
        cost = "$300,000",
        requires = {"UFO Power Source (item)"},
        unlocks = {"Laser Pistol", "Laser Rifle", "Laser Cannon"},
    },
    {
        name = "Heavy Laser",
        priority = "HIGH",
        reason = "High-damage weapon option",
        time = 20,
        cost = "$400,000",
        requires = {"Laser Weaponry"},
        unlocks = {"Heavy Laser"},
    },
    {
        name = "Powered Armor",
        priority = "HIGH",
        reason = "Significant armor upgrade",
        time = 18,
        cost = "$500,000",
        requires = {"UFO Power Source", "Alien Alloys"},
        unlocks = {"Power Suit"},
    },
    {
        name = "Hyperwave Decoder",
        priority = "CRITICAL",
        reason = "Perfect UFO detection",
        time = 20,
        cost = "$750,000",
        requires = {"UFO Navigation (item)"},
        unlocks = {"Hyperwave Decoder Facility"},
    },
}
```

### Late Game Research Priority (Months 7-12)

```lua
-- Plasma and fusion technologies
LateGameResearch = {
    {
        name = "Plasma Weaponry",
        priority = "CRITICAL",
        reason = "Matches alien firepower",
        time = 25,
        cost = "$800,000",
        requires = {"Plasma Rifle (item)", "Elerium-115"},
        unlocks = {"Plasma Pistol", "Plasma Rifle"},
    },
    {
        name = "Heavy Plasma",
        priority = "HIGH",
        reason = "Maximum weapon damage",
        time = 30,
        cost = "$1,000,000",
        requires = {"Plasma Weaponry"},
        unlocks = {"Heavy Plasma"},
    },
    {
        name = "Fusion Armor",
        priority = "CRITICAL",
        reason = "Best armor protection",
        time = 35,
        cost = "$1,500,000",
        requires = {"Plasma Armor", "Elerium-115"},
        unlocks = {"Fusion Suit"},
    },
    {
        name = "Firestorm",
        priority = "HIGH",
        reason = "Match UFO speed/firepower",
        time = 45,
        cost = "$2,000,000",
        requires = {"UFO Navigation", "UFO Power Source", "Alien Alloys"},
        unlocks = {"Firestorm Interceptor"},
    },
}
```

### End Game Research (Months 12+)

```lua
-- Ultimate technologies and final mission prep
EndGameResearch = {
    {
        name = "Alien Origins",
        priority = "CRITICAL",
        reason = "Reveals alien homeworld",
        time = 90,
        cost = "$3,000,000",
        requires = {
            "Sectoid Commander (autopsy)",
            "Ethereal (autopsy)",
            "All Alien Species Research",
        },
        unlocks = {"Alien Homeworld Location"},
    },
    {
        name = "Hyperspace Drive",
        priority = "CRITICAL",
        reason = "Required for final mission",
        time = 120,
        cost = "$5,000,000",
        requires = {"Alien Origins", "Ethereal Commander (live capture)"},
        unlocks = {"Final Mission"},
    },
    {
        name = "Blaster Launcher",
        priority = "HIGH",
        reason = "Guided explosive weapon",
        time = 50,
        cost = "$2,500,000",
        requires = {"Fusion Weapons", "Blaster Bomb (item)"},
        unlocks = {"Blaster Launcher"},
    },
}
```

---

## Weapons Research Tree

### Conventional Weapons Path

```
Starting Equipment
    └── Advanced Ballistics (3 days, $50k)
        ├── Sniper Rifle
        ├── Heavy Machine Gun
        └── Explosive Compounds (5 days, $75k)
            ├── High Explosive
            ├── Proximity Mine
            └── Rocket Launcher Ammo
```

### Laser Weapons Path

```
UFO Power Source (item required)
    └── Laser Weaponry (15 days, $300k)
        ├── Laser Pistol
        ├── Laser Rifle
        ├── Laser Cannon (air)
        └── Heavy Laser (20 days, $400k)
            └── Heavy Laser (ground + air)
```

### Plasma Weapons Path

```
Plasma Rifle (item) + Elerium-115
    └── Plasma Weaponry (25 days, $800k)
        ├── Plasma Pistol
        ├── Plasma Rifle
        ├── Plasma Cannon (air)
        └── Heavy Plasma (30 days, $1M)
            └── Heavy Plasma (ground + air)
```

### Fusion Weapons Path

```
Elerium-115 + Alien Computer Core
    └── Fusion Weapons (40 days, $1.5M)
        ├── Fusion Lance (air)
        ├── Fusion Ball (air)
        └── Blaster Launcher (50 days, $2.5M)
            └── Blaster Launcher + Blaster Bombs
```

### Weapon Research Requirements Table

| Weapon | Research Required | Item Required | Time (days) | Cost |
|--------|------------------|---------------|-------------|------|
| **Sniper Rifle** | Advanced Ballistics | - | 3 | $50k |
| **Laser Pistol** | Laser Weaponry | UFO Power | 15 | $300k |
| **Laser Rifle** | Laser Weaponry | UFO Power | 15 | $300k |
| **Heavy Laser** | Heavy Laser Tech | UFO Power | 20 | $400k |
| **Plasma Pistol** | Plasma Weaponry | Plasma Rifle | 25 | $800k |
| **Plasma Rifle** | Plasma Weaponry | Plasma Rifle | 25 | $800k |
| **Heavy Plasma** | Heavy Plasma Tech | Plasma Rifle | 30 | $1M |
| **Blaster Launcher** | Blaster Tech | Blaster Bomb | 50 | $2.5M |

---

## Armor Research Tree

### Armor Progression Path

```
Starting: Civilian Clothes (0 armor)
    │
    ├── Body Armor (5 days, $100k)
    │   └── Personal Armor (20 armor)
    │
    ├── Tactical Vest (7 days, $150k)
    │   └── Tactical Armor (30 armor)
    │
    ├── Powered Armor (18 days, $500k)
    │   └── Power Suit (50 armor + bonuses)
    │   Requirements: UFO Power + Alien Alloys
    │
    ├── Laser-Resistant Armor (12 days, $400k)
    │   └── Laser Defense Suit (60 armor, laser resistant)
    │   Requirements: Alien Alloys
    │
    ├── Plasma Armor (25 days, $800k)
    │   └── Plasma Suit (80 armor, energy resistant)
    │   Requirements: Alien Alloys + Elerium
    │
    ├── Fusion Armor (35 days, $1.5M)
    │   └── Fusion Suit (100 armor, all-resistant)
    │   Requirements: Plasma Armor + Elerium
    │
    └── Alien Alloy Armor (40 days, $2M)
        └── Ultimate Armor (120 armor, mobility bonus)
        Requirements: Fusion Armor + Alien Materials
```

### Armor Research Requirements

| Armor Type | Research | Prerequisites | Item Requirements | Time | Cost |
|------------|----------|---------------|-------------------|------|------|
| **Body Armor** | Body Armor | - | - | 5d | $100k |
| **Tactical Vest** | Tactical Armor | Body Armor | - | 7d | $150k |
| **Powered Armor** | Powered Armor | Tactical Armor | UFO Power, Alloys | 18d | $500k |
| **Laser-Resistant** | Laser Defense | Powered Armor | Alien Alloys | 12d | $400k |
| **Plasma Armor** | Plasma Defense | Laser-Resistant | Alloys, Elerium | 25d | $800k |
| **Fusion Armor** | Fusion Defense | Plasma Armor | Elerium-115 | 35d | $1.5M |
| **Alien Alloy** | Ultimate Armor | Fusion Armor | Alien Materials | 40d | $2M |

---

## Craft Research Tree

### Craft Progression

```
Starting Craft
    │
    ├── Interceptor (air superiority)
    │   └── Improved Interceptor (10 days, $200k)
    │       └── Advanced Avionics
    │
    ├── Skyranger (troop transport)
    │   └── Lightning (30 days, $1M)
    │       └── Fast Transport
    │       Requirements: UFO Navigation
    │
    └── Advanced Craft Line
        │
        ├── Firestorm (45 days, $2M)
        │   └── Heavy Interceptor
        │   Requirements: UFO Nav + Power + Alloys
        │
        └── Avenger (60 days, $5M)
            └── Ultimate Craft
            Requirements: Complete UFO + All Tech
```

### Craft Research Requirements

| Craft | Purpose | Research Time | Prerequisites | Cost | Weapons | Cargo |
|-------|---------|---------------|---------------|------|---------|-------|
| **Interceptor** | Starting | - | - | $500k | 2 hardpoints | 0 |
| **Skyranger** | Starting | - | - | $800k | 0 | 14 soldiers |
| **Lightning** | Fast Transport | 30d | UFO Nav | $1.5M | 1 hardpoint | 12 soldiers |
| **Firestorm** | Heavy Fighter | 45d | UFO Tech | $3M | 4 hardpoints | 0 |
| **Avenger** | Ultimate | 60d | Complete UFO | $8M | 4 hardpoints | 26 soldiers |

---

## Facilities Research Tree

### Base Facilities Progression

```
Starting Facilities
    │
    ├── Detection Systems
    │   ├── Small Radar (starting)
    │   ├── Long Range Radar (10 days, $150k)
    │   └── Hyperwave Decoder (20 days, $750k)
    │       Requirements: UFO Navigation
    │
    ├── Manufacturing
    │   ├── Workshop (starting)
    │   └── Advanced Workshop (15 days, $300k)
    │       └── +50% production speed
    │
    ├── Research
    │   ├── Laboratory (starting)
    │   └── Advanced Lab (15 days, $300k)
    │       └── +50% research speed
    │
    ├── Defense
    │   ├── Base Defense (12 days, $400k)
    │   ├── Laser Defense (20 days, $600k)
    │   │   Requirements: Laser Weaponry
    │   ├── Plasma Defense (30 days, $1M)
    │   │   Requirements: Plasma Weaponry
    │   └── Fusion Defense (40 days, $1.5M)
    │       Requirements: Fusion Weapons
    │
    └── Special Facilities
        ├── Mind Shield (30 days, $1M)
        │   Requirements: Sectoid Commander
        ├── Grav Shield (50 days, $2M)
        │   Requirements: UFO Construction
        └── Hyperwave Relay (60 days, $3M)
            Requirements: Hyperwave Decoder
```

---

## Alien Technology Tree

### Alien Item Research

```
Captured/Recovered Items
    │
    ├── UFO Components
    │   ├── UFO Power Source (7 days)
    │   │   └── Unlocks: Laser Weaponry
    │   ├── UFO Navigation (10 days)
    │   │   └── Unlocks: Hyperwave, Craft Research
    │   ├── UFO Construction (15 days)
    │   │   └── Unlocks: Advanced Armor
    │   └── Alien Alloys (5 days)
    │       └── Unlocks: Armor Research
    │
    ├── Alien Weapons
    │   ├── Plasma Pistol (10 days)
    │   ├── Plasma Rifle (15 days)
    │   │   └── Unlocks: Plasma Weaponry
    │   ├── Heavy Plasma (20 days)
    │   ├── Blaster Launcher (25 days)
    │   └── Blaster Bomb (20 days)
    │       └── Unlocks: Blaster Research
    │
    ├── Alien Artifacts
    │   ├── Elerium-115 (12 days)
    │   │   └── Required: Plasma/Fusion Tech
    │   ├── Mind Probe (8 days)
    │   │   └── Unlocks: Psionic Detection
    │   └── Alien Computer Core (15 days)
    │       └── Unlocks: Fusion Weapons
    │
    └── Alien Species (Autopsies)
        ├── Sectoid (10 days)
        ├── Floater (10 days)
        ├── Snakeman (12 days)
        ├── Muton (15 days)
        ├── Ethereal (20 days)
        │
        └── Live Captures (Interrogations)
            ├── Sectoid Soldier (15 days)
            ├── Sectoid Commander (30 days)
            │   └── Unlocks: Mind Shield, Psionics
            ├── Ethereal Soldier (25 days)
            └── Ethereal Commander (45 days)
                └── Required: Final Mission
```

### Alien Research Dependencies

| Item | Research Time | Unlocks | Critical Path |
|------|---------------|---------|---------------|
| **UFO Power Source** | 7 days | Laser Tech | Yes |
| **UFO Navigation** | 10 days | Hyperwave, Craft | Yes |
| **Alien Alloys** | 5 days | Armor Tech | Yes |
| **Plasma Rifle** | 15 days | Plasma Tech | Yes |
| **Elerium-115** | 12 days | Fusion Tech | Yes |
| **Sectoid Commander** | 30 days | Mind Shield, Psionics | Yes |
| **Ethereal Commander** | 45 days | Final Mission | Yes |
| **Blaster Bomb** | 20 days | Blaster Launcher | No |
| **Mind Probe** | 8 days | Psionic Detection | No |

---

## Research Mechanics

### Research Speed Formula

```lua
-- Calculate research completion time
function calculate_research_time(project, base, scientists)
    local base_time = project.base_time_days
    local scientist_count = scientists.assigned
    local scientist_efficiency = calculate_scientist_efficiency(scientists)
    
    -- Base formula: Time = Base / (Scientists × Efficiency)
    local effective_scientists = scientist_count * scientist_efficiency
    local research_days = base_time / math.max(1, effective_scientists)
    
    -- Facilities bonus (advanced labs)
    local facility_bonus = base.research_speed_bonus or 1.0
    research_days = research_days / facility_bonus
    
    -- Minimum 1 day
    research_days = math.max(1, math.ceil(research_days))
    
    return research_days
end

function calculate_scientist_efficiency(scientists)
    -- Average scientist skill (50-100 range)
    local avg_skill = 0
    for _, scientist in ipairs(scientists) do
        avg_skill = avg_skill + scientist.skill
    end
    avg_skill = avg_skill / #scientists
    
    -- Skill → efficiency conversion
    -- 50 skill = 1.0× efficiency
    -- 100 skill = 2.0× efficiency
    local efficiency = 0.5 + (avg_skill / 100)
    
    return efficiency
end
```

### Research Examples

**Laser Weaponry (15 base days) with 10 scientists (avg skill 60):**
- Scientist efficiency: 0.5 + (60/100) = 1.1×
- Effective scientists: 10 × 1.1 = 11
- Research time: 15 / 11 = **1.36 days → 2 days**

**Plasma Weaponry (25 base days) with 20 scientists (avg skill 80), Advanced Labs (+50%):**
- Scientist efficiency: 0.5 + (80/100) = 1.3×
- Effective scientists: 20 × 1.3 = 26
- Base time: 25 / 26 = 0.96 days
- With bonus: 0.96 / 1.5 = **0.64 days → 1 day**

### Research Priority System

```lua
-- Research project management
ResearchQueue = {
    active_project = nil,
    queued_projects = {},
}

function start_research(project, base)
    -- Check prerequisites
    if not check_prerequisites(project) then
        return false, "Prerequisites not met"
    end
    
    -- Check item requirements
    if project.item_required then
        if not has_item(project.item_required) then
            return false, "Required item not available"
        end
    end
    
    -- Check scientist availability
    if base.scientists_available < 1 then
        return false, "No scientists available"
    end
    
    -- Start research
    ResearchQueue.active_project = {
        project = project,
        base = base,
        days_remaining = calculate_research_time(project, base, base.scientists),
        started_date = game.current_date,
    }
    
    return true
end

function complete_research(research)
    local project = research.project
    
    -- Unlock new items/research
    for _, unlock in ipairs(project.unlocks) do
        unlock_technology(unlock)
    end
    
    -- Consume required item (if any)
    if project.item_required then
        consume_item(project.item_required)
    end
    
    -- Add to research log
    game.completed_research[project.id] = {
        completed_date = game.current_date,
        base = research.base.name,
    }
    
    -- Notify player
    show_research_complete_notification(project)
end
```

---

## Lua Implementation

### Complete Tech Tree System

```lua
-- Technology tree manager
TechTree = {
    technologies = {},
    unlocked = {},
    available = {},
}

function TechTree:initialize()
    -- Load all technology definitions
    self.technologies = load_technology_data()
    
    -- Starting technologies
    self.unlocked = {
        "conventional_weapons",
        "basic_armor",
        "radar_systems",
        "interceptor",
        "skyranger",
    }
    
    -- Update available research
    self:update_available()
end

function TechTree:update_available()
    self.available = {}
    
    for tech_id, tech in pairs(self.technologies) do
        if not self.unlocked[tech_id] then
            -- Check if all prerequisites are met
            local can_research = true
            
            for _, prereq in ipairs(tech.prerequisites or {}) do
                if not self.unlocked[prereq] then
                    can_research = false
                    break
                end
            end
            
            if can_research then
                table.insert(self.available, tech)
            end
        end
    end
end

function TechTree:unlock_technology(tech_id)
    self.unlocked[tech_id] = true
    
    -- Unlock associated items/facilities
    local tech = self.technologies[tech_id]
    for _, unlock in ipairs(tech.unlocks or {}) do
        unlock_item_for_production(unlock)
    end
    
    -- Update available research
    self:update_available()
end

function TechTree:get_research_path_to(target_tech)
    -- Calculate shortest research path to target technology
    local path = {}
    local current = target_tech
    
    while current do
        table.insert(path, 1, current)
        
        -- Get first prerequisite (simplified)
        local prereq = self.technologies[current].prerequisites[1]
        if prereq and not self.unlocked[prereq] then
            current = prereq
        else
            break
        end
    end
    
    return path
end
```

### Technology Definition Format

```lua
-- Example technology definition
Technologies = {
    laser_weaponry = {
        id = "laser_weaponry",
        name = "Laser Weaponry",
        description = "Harness alien power sources to create directed energy weapons.",
        
        base_time_days = 15,
        cost = 300000,
        
        prerequisites = {},
        item_requirements = {"ufo_power_source"},
        
        unlocks = {
            "laser_pistol",
            "laser_rifle",
            "laser_cannon",
        },
        
        category = "weapons",
        tier = 2,
    },
    
    plasma_weaponry = {
        id = "plasma_weaponry",
        name = "Plasma Weaponry",
        description = "Reverse-engineer alien plasma technology for human use.",
        
        base_time_days = 25,
        cost = 800000,
        
        prerequisites = {"laser_weaponry"},
        item_requirements = {"plasma_rifle", "elerium_115"},
        
        unlocks = {
            "plasma_pistol",
            "plasma_rifle_human",
            "plasma_cannon",
        },
        
        category = "weapons",
        tier = 3,
    },
}
```

---

## Integration Points

### Research System Integration
```lua
-- Connect tech tree to research system
function start_research_project(tech_id, base)
    local tech = TechTree.technologies[tech_id]
    
    if not tech then
        return false, "Invalid technology"
    end
    
    -- Check if available for research
    if not TechTree:is_available(tech_id) then
        return false, "Prerequisites not met"
    end
    
    -- Start research
    return Research:start_project(tech, base)
end
```

### Production System Integration
```lua
-- Unlock items for production when researched
function unlock_item_for_production(item_id)
    local item = ItemDatabase[item_id]
    item.unlocked = true
    item.can_produce = true
    
    -- Add to production menu
    ProductionMenu:add_item(item)
end
```

---

## Cross-References

### Related Systems
- **[Item_Crafting.md](Item_Crafting.md)** - Production system for unlocked items
- **[Weapon_Comparisons.md](../items/Weapon_Comparisons.md)** - Weapon stats and progression
- **[Armor.md](../units/Armor.md)** - Armor progression and stats
- **[Progression.md](../units/Progression.md)** - Unit and equipment progression
- **[Air_Weapons.md](../interception/Air_Weapons.md)** - Air weapon technology tree

### Design Documents
- **Economy System** - Research funding and costs
- **Item Database** - Complete item definitions
- **Facility System** - Base facilities and upgrades

---

**Implementation Status:** Complete specification with dependency diagram ready for coding  
**Testing Requirements:** 
- Prerequisite validation
- Research time calculations
- Technology unlocking
- Item requirement checking
- Research queue management

**Version History:**
- v1.0 (2025-09-30): Initial complete specification with ASCII dependency diagram and all research paths
