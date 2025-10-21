# API: Research & Manufacturing Systems

**Version**: 1.0  
**Last Updated**: October 21, 2025  
**Purpose**: Complete reference for research projects, manufacturing recipes, and technology progression system  
**Audience**: Lua developers, TOML modders  

---

## Quick Start: Lua Developer

### Get All Technologies

```lua
local DataLoader = require("engine.core.data_loader")
local technologies = DataLoader.technology.getAllIds()

for _, techId in ipairs(technologies) do
    local tech = DataLoader.technology.get(techId)
    print(tech.name .. ": " .. tech.category .. " (" .. tech.research_cost .. " man-days)")
end
```

### Get All Recipes

```lua
local recipes = DataLoader.recipe.getAllIds()

for _, recipeId in ipairs(recipes) do
    local recipe = DataLoader.recipe.get(recipeId)
    print("Recipe: " .. recipe.name)
    print("  Input: " .. tostring(recipe.input_item) .. " x" .. recipe.input_quantity)
    print("  Output: " .. tostring(recipe.output_item) .. " x" .. recipe.output_quantity)
end
```

### Filter Recipes by Output

```lua
local function getRecipesFor(output_item)
    local recipes = DataLoader.recipe.getAllIds()
    local results = {}
    
    for _, recipeId in ipairs(recipes) do
        local recipe = DataLoader.recipe.get(recipeId)
        if recipe.output_item == output_item then
            table.insert(results, recipe)
        end
    end
    
    return results
end

local weaponRecipes = getRecipesFor("rifle_conventional")
```

---

## Quick Start: TOML Modder

### Create a Research Project

```toml
[[technology]]
id = "tech_plasma_rifle"
name = "Plasma Rifle Technology"
category = "weapons"
description = "Research into plasma weapon technology"
research_cost = 500
prerequisite = "tech_plasma_basics"
tier = 2
unlock_items = ["plasma_rifle", "plasma_carbine"]
unlock_facilities = []
unlock_recipes = ["recipe_plasma_rifle", "recipe_plasma_carbine"]

[technology.cost_by_base_size]
small = 500
medium = 400
large = 350
huge = 300
```

### Create a Recipe

```toml
[[recipe]]
id = "recipe_plasma_rifle"
name = "Plasma Rifle Manufacturing"
category = "weapons"
input_item = "plasma_rifle_components"
input_quantity = 1
output_item = "plasma_rifle"
output_quantity = 1
production_time = 480  # Minutes (8 hours)
facility_requirement = "workshop"
cost = 1500
skill_requirement = "manufacturing"
skill_level = 3
```

---

## Research System

### Technology Schema

**File Location**: `mods/[modname]/content/rules/technologies/technologies.toml`

```toml
[[technology]]
id = "string - unique identifier (e.g., 'tech_plasma_rifle')"
name = "string - human-readable name"
category = "enum - weapons|armor|facilities|items|interception|tactical|strategic"
description = "string - full description"
research_cost = "integer - man-days required (50-2000)"
prerequisite = "string - required technology id (optional)"
prerequisites = ["array - multiple prerequisites (alternative to single prerequisite)"]
tier = "integer - technology level (1-5, influences cost and unlock)"
unlock_items = ["array - item ids unlocked by this tech"]
unlock_facilities = ["array - facility ids unlocked"]
unlock_recipes = ["array - recipe ids unlocked"]
unlock_techs = ["array - other tech ids that become available"]
unlock_units = ["array - unit class ids that become available"]

[technology.cost_by_base_size]
small = "integer - research cost for small bases"
medium = "integer - research cost for medium bases"
large = "integer - research cost for large bases"
huge = "integer - research cost for huge bases"

[technology.bonus]
research_speed_multiplier = "float - 0.8-1.2, affects research speed"
production_speed_multiplier = "float - 0.8-1.2, affects manufacturing"
production_cost_multiplier = "float - 0.8-1.2, affects item production cost"
```

### Technology Categories

| Category | Purpose | Examples | Tier Range |
|----------|---------|----------|-----------|
| **weapons** | Unlock weapon types | Plasma rifles, laser weapons, etc. | 1-5 |
| **armor** | Unlock armor types | Power suits, alien armor | 1-4 |
| **facilities** | Unlock facility types | Advanced labs, power reactors | 2-5 |
| **items** | Unlock consumables | Medikits, grenades, ammo types | 1-5 |
| **interception** | Craft weapons & systems | Plasma cannons, armor upgrades | 2-5 |
| **tactical** | Combat abilities | Smoke grenades, special weapons | 1-4 |
| **strategic** | Base & economy | Better manufacturing, faster research | 2-4 |

### Technology Tiers

| Tier | Phase | Name | Cost Range | Examples |
|------|-------|------|-----------|----------|
| **1** | Early Game | Basic Technology | 50-150 man-days | Laser weapons, basic armor |
| **2** | Mid Game | Advanced Technology | 200-400 man-days | Plasma weapons, power suits |
| **3** | Late Game | Cutting-Edge | 500-800 man-days | Alien weapons, advanced facilities |
| **4** | End Game | Experimental | 900-1500 man-days | Fusion weapons, specialized armor |
| **5** | Post Game | Alien Technology | 1600-2000 man-days | Alien combat systems, ultimate weapons |

---

## Research Examples

### Tier 1: Laser Weapons

```toml
[[technology]]
id = "tech_laser_weapons"
name = "Laser Weapon Technology"
category = "weapons"
description = "Research into laser weapon technology, improving accuracy and range"
research_cost = 150
prerequisite = ""
tier = 1
unlock_items = ["laser_rifle", "laser_pistol", "laser_cannon"]
unlock_facilities = []
unlock_recipes = ["recipe_laser_rifle", "recipe_laser_pistol"]

[technology.cost_by_base_size]
small = 150
medium = 120
large = 100
huge = 80
```

### Tier 2: Plasma Weapons

```toml
[[technology]]
id = "tech_plasma_weapons"
name = "Plasma Weapon Technology"
category = "weapons"
description = "Advanced research into plasma weapon technology"
research_cost = 400
prerequisite = "tech_laser_weapons"
tier = 2
unlock_items = ["plasma_rifle", "plasma_pistol", "plasma_cannon"]
unlock_facilities = []
unlock_recipes = ["recipe_plasma_rifle", "recipe_plasma_pistol"]

[technology.cost_by_base_size]
small = 400
medium = 320
large = 280
huge = 240
```

### Tier 3: Power Armor

```toml
[[technology]]
id = "tech_power_armor"
name = "Power Armor Development"
category = "armor"
description = "Develop powered exoskeletons for enhanced protection and mobility"
research_cost = 600
prerequisite = "tech_plasma_weapons"
tier = 3
unlock_items = ["power_suit"]
unlock_facilities = []
unlock_recipes = ["recipe_power_suit"]

[technology.cost_by_base_size]
small = 600
medium = 480
large = 420
huge = 360
```

### Tier 4: Plasma Armor

```toml
[[technology]]
id = "tech_plasma_armor"
name = "Plasma Armor Research"
category = "armor"
description = "Research living plasma armor technology"
research_cost = 900
prerequisites = ["tech_power_armor", "tech_alien_autopsy"]
tier = 4
unlock_items = ["plasma_armor"]
unlock_facilities = []
unlock_recipes = ["recipe_plasma_armor"]

[technology.cost_by_base_size]
small = 900
medium = 720
large = 630
huge = 540
```

### Tier 5: Alien Technology

```toml
[[technology]]
id = "tech_alien_weapons"
name = "Alien Weapon Systems Analysis"
category = "weapons"
description = "Study and replicate alien weapon technology"
research_cost = 1800
prerequisites = ["tech_plasma_weapons", "tech_alien_weapons_research", "tech_alien_technology"]
tier = 5
unlock_items = ["alien_plasma_rifle", "alien_plasma_cannon"]
unlock_facilities = []
unlock_recipes = ["recipe_alien_plasma_rifle"]

[technology.cost_by_base_size]
small = 1800
medium = 1440
large = 1260
huge = 1080
```

### Research Speed Enhancement

```toml
[[technology]]
id = "tech_advanced_research"
name = "Advanced Research Methods"
category = "strategic"
description = "Improve research laboratory efficiency"
research_cost = 250
prerequisite = ""
tier = 2
unlock_items = []
unlock_facilities = []
unlock_recipes = []

[technology.bonus]
research_speed_multiplier = 1.2
```

---

## Manufacturing System

### Recipe Schema

**File Location**: `mods/[modname]/content/rules/manufacturing/recipes.toml`

```toml
[[recipe]]
id = "string - unique identifier (e.g., 'recipe_plasma_rifle')"
name = "string - human-readable name"
category = "enum - weapons|armor|ammunition|components|consumables"
description = "string - what does this recipe produce"
input_item = "string - item id being consumed"
input_quantity = "integer - how many of input_item needed"
output_item = "string - item id being produced"
output_quantity = "integer - how many of output_item produced"
production_time = "integer - minutes to produce (60-7200)"
production_cost = "integer - credits cost per batch"
facility_requirement = "enum - workshop|armory|lab"
skill_requirement = "enum - manufacturing|armor_crafting|weapon_assembly"
skill_level = "integer - required skill level (0-5)"
batch_size = "integer - items produced per production run (1-100)"
prerequisites = ["array - technology ids that must be researched"]
```

### Recipe Categories

| Category | Purpose | Examples | Facility |
|----------|---------|----------|----------|
| **weapons** | Manufacture weapons | Rifles, pistols, heavy weapons | Workshop |
| **armor** | Manufacture armor suits | Combat armor, power suits | Armory |
| **ammunition** | Create ammo | Rifle rounds, energy cells | Workshop |
| **components** | Assemble components | Weapon parts, armor plates | Workshop |
| **consumables** | Create consumables | Medikits, grenades | Lab |

---

## Manufacturing Examples

### Basic Rifle Production

```toml
[[recipe]]
id = "recipe_rifle_conventional"
name = "Conventional Rifle Production"
category = "weapons"
description = "Manufacture standard rifle from components"
input_item = "rifle_components_pack"
input_quantity = 1
output_item = "rifle_conventional"
output_quantity = 1
production_time = 240  # 4 hours
production_cost = 500
facility_requirement = "workshop"
skill_requirement = "weapon_assembly"
skill_level = 1
batch_size = 1
prerequisites = []
```

### Ammunition Manufacturing

```toml
[[recipe]]
id = "recipe_rifle_ammunition"
name = "5.56mm Ammunition Batch"
category = "ammunition"
description = "Manufacture box of rifle ammunition (1000 rounds)"
input_item = "ammunition_materials"
input_quantity = 50  # Units of material per 1000 rounds
output_item = "rifle_ammunition"
output_quantity = 1000
production_time = 120  # 2 hours
production_cost = 250
facility_requirement = "workshop"
skill_requirement = "manufacturing"
skill_level = 1
batch_size = 1000
prerequisites = []
```

### Plasma Rifle Production

```toml
[[recipe]]
id = "recipe_plasma_rifle_production"
name = "Plasma Rifle Assembly"
category = "weapons"
description = "Assemble plasma rifle from advanced components"
input_item = "plasma_rifle_components"
input_quantity = 1
output_item = "plasma_rifle"
output_quantity = 1
production_time = 480  # 8 hours
production_cost = 1500
facility_requirement = "workshop"
skill_requirement = "weapon_assembly"
skill_level = 3
batch_size = 1
prerequisites = ["tech_plasma_weapons"]
```

### Advanced Armor Crafting

```toml
[[recipe]]
id = "recipe_power_suit_assembly"
name = "Power Suit Assembly"
category = "armor"
description = "Assemble power suit from components"
input_item = "power_suit_components"
input_quantity = 1
output_item = "power_suit"
output_quantity = 1
production_time = 960  # 16 hours
production_cost = 3000
facility_requirement = "armory"
skill_requirement = "armor_crafting"
skill_level = 4
batch_size = 1
prerequisites = ["tech_power_armor"]
```

### Medikit Production

```toml
[[recipe]]
id = "recipe_medikit"
name = "Medikit Assembly"
category = "consumables"
description = "Prepare medical kits from components"
input_item = "medical_supplies"
input_quantity = 10
output_item = "medikit"
output_quantity = 5
production_time = 180  # 3 hours
production_cost = 300
facility_requirement = "lab"
skill_requirement = "manufacturing"
skill_level = 2
batch_size = 5
prerequisites = []
```

### Grenade Production

```toml
[[recipe]]
id = "recipe_grenade_frag"
name = "Fragmentation Grenade Assembly"
category = "consumables"
description = "Assemble fragmentation grenades"
input_item = "grenade_components"
input_quantity = 5
output_item = "grenade_frag"
output_quantity = 5
production_time = 240  # 4 hours
production_cost = 400
facility_requirement = "workshop"
skill_requirement = "manufacturing"
skill_level = 2
batch_size = 5
prerequisites = []
```

### Component Assembly

```toml
[[recipe]]
id = "recipe_plasma_components"
name = "Plasma Weapon Components Assembly"
category = "components"
description = "Assemble plasma weapon components from materials"
input_item = "plasma_materials"
input_quantity = 20
output_item = "plasma_rifle_components"
output_quantity = 1
production_time = 600  # 10 hours
production_cost = 800
facility_requirement = "workshop"
skill_requirement = "manufacturing"
skill_level = 3
batch_size = 1
prerequisites = ["tech_plasma_weapons"]
```

---

## Manufacturing Efficiency

### Skill Level Impact

| Skill Level | Multiplier | Craft Time | Failure Rate | Quality |
|------------|-----------|-----------|-------------|---------|
| **0** (Untrained) | 1.5x | +50% | 25% fail | Poor |
| **1** (Apprentice) | 1.25x | +25% | 15% fail | Fair |
| **2** (Journeyman) | 1.0x | Normal | 5% fail | Good |
| **3** (Expert) | 0.85x | -15% | 2% fail | Excellent |
| **4** (Master) | 0.75x | -25% | 1% fail | Perfect |
| **5** (Legendary) | 0.70x | -30% | 0% fail | Legendary |

### Facility Efficiency

| Facility Level | Quality | Speed | Failure |
|---|---|---|---|
| Level 1 | Standard | 1.0x | 5% |
| Level 2 | Enhanced | 1.15x | 3% |
| Level 3 | Optimized | 1.3x | 1% |
| Level 4 | Advanced | 1.5x | 0% |

---

## Research Project System

### Project Schema

**Used for active research tracking in bases**

```lua
-- Research Project Instance (in-game data)
{
    id = "research_project_123",
    base_id = "base_main",
    technology_id = "tech_plasma_weapons",
    scientists_assigned = 5,
    current_progress = 450,  -- man-days completed
    total_progress = 600,     -- man-days required
    started_date = "2025-01-15",
    estimated_completion = "2025-02-20",
    status = "in_progress",   -- or: "paused", "complete", "failed"
}
```

### Lua: Get Research Status

```lua
local DataLoader = require("engine.core.data_loader")

local function getResearchStatus(baseId)
    local base = DataLoader.base.get(baseId)
    local activeResearch = {}
    
    if base.current_research_id then
        local research = DataLoader.researchProject.get(base.current_research_id)
        local tech = DataLoader.technology.get(research.technology_id)
        
        local progress_percent = (research.current_progress / research.total_progress) * 100
        
        return {
            technology_name = tech.name,
            progress = research.current_progress,
            total = research.total_progress,
            percent = progress_percent,
            scientists = research.scientists_assigned,
            eta_days = math.ceil((research.total_progress - research.current_progress) / research.scientists_assigned)
        }
    end
    
    return nil
end
```

### Lua: Start Manufacturing

```lua
local function startManufacturing(baseId, recipeId, quantity)
    local recipe = DataLoader.recipe.get(recipeId)
    local base = DataLoader.base.get(baseId)
    
    -- Check prerequisites
    for _, tech_required in ipairs(recipe.prerequisites) do
        if not base.researched_technologies[tech_required] then
            return false, "Missing prerequisite technology: " .. tech_required
        end
    end
    
    -- Check facilities
    local facility = DataLoader.facility.getByType(base.id, recipe.facility_requirement)
    if not facility then
        return false, "No " .. recipe.facility_requirement .. " available"
    end
    
    -- Check resources
    local totalCost = recipe.production_cost * quantity
    if base.credits < totalCost then
        return false, "Insufficient credits"
    end
    
    -- Create manufacturing project
    local project = {
        id = "mfg_" .. math.random(1000000),
        base_id = baseId,
        recipe_id = recipeId,
        quantity_ordered = quantity,
        quantity_completed = 0,
        production_time_per_unit = recipe.production_time,
        progress = 0,  -- minutes elapsed
        status = "queued"
    }
    
    table.insert(base.manufacturing_queue, project)
    base.credits = base.credits - totalCost
    
    return true, project.id
end
```

---

## Technology Tree Structure

### Example Tree Chain

```
Tier 1
├── tech_laser_weapons
│   └── unlock: laser_rifle, laser_pistol
├── tech_plasma_basics
└── tech_armor_research

Tier 2
├── tech_plasma_weapons (requires: tech_laser_weapons)
│   ├── unlock: plasma_rifle, plasma_pistol
│   └── leads to: tech_advanced_plasma
├── tech_power_armor (requires: tech_armor_research)
│   └── leads to: tech_plasma_armor
└── tech_advanced_research
    └── bonus: research speed +20%

Tier 3
├── tech_advanced_plasma (requires: tech_plasma_weapons)
├── tech_plasma_armor (requires: tech_power_armor + tech_plasma_weapons)
├── tech_advanced_facilities
└── tech_economic_boost

Tier 4
├── tech_alien_autopsy (requires: alien_artifact)
├── tech_alien_weapons_research (requires: tech_alien_autopsy)
└── tech_experimental_weapons

Tier 5
└── tech_alien_technology (requires: tech_alien_autopsy + alien_reactor_analysis)
    └── unlock: alien_weapons, alien_armor, advanced_crafts
```

---

## Research Cost Formulas

### Base Cost Calculation

```lua
local function calculateResearchCost(technology, baseSize)
    local baseCost = technology.research_cost
    
    -- Apply base size modifier
    local sizeModifier = technology.cost_by_base_size[baseSize] or baseCost
    
    -- Apply scientist count
    local scientistMultiplier = 1.0
    if numScientists < 5 then
        scientistMultiplier = 1.2  -- Bonus for small teams
    elseif numScientists > 20 then
        scientistMultiplier = 0.95  -- Slight penalty for large teams
    end
    
    -- Apply facility bonus
    local facilityBonus = 1.0
    if hasAdvancedLab then
        facilityBonus = 0.85  -- 15% faster research
    end
    
    return math.ceil(sizeModifier * scientistMultiplier * facilityBonus)
end
```

### Completion Time

```lua
local function getCompletionTime(technology, numScientists)
    if numScientists == 0 then
        return math.huge  -- Never completes
    end
    
    -- Base cost in man-days / scientists assigned = days to complete
    local days = technology.research_cost / numScientists
    
    return days
end
```

---

## Manufacturing Cost Formulas

### Production Time with Skill Modifier

```lua
local function calculateProductionTime(recipe, skillLevel, facilityLevel)
    local baseTime = recipe.production_time
    
    -- Skill modifier (0.7x to 1.5x)
    local skillMultiplier = {
        [0] = 1.5,  -- Untrained
        [1] = 1.25,
        [2] = 1.0,
        [3] = 0.85,
        [4] = 0.75,
        [5] = 0.7,  -- Legendary
    }
    
    -- Facility multiplier (1.0x to 1.5x)
    local facilityMultiplier = {
        [1] = 1.0,
        [2] = 1.15,
        [3] = 1.3,
        [4] = 1.5,
    }
    
    return baseTime * (skillMultiplier[skillLevel] or 1.0) * (facilityMultiplier[facilityLevel] or 1.0)
end
```

---

## Complete Example: Plasma Rifle Tech Path

### Research Chain

```toml
# Stage 1: Enable plasma weapons
[[technology]]
id = "tech_plasma_basics"
name = "Plasma Weapon Basics"
category = "weapons"
research_cost = 200
prerequisite = ""
tier = 1

# Stage 2: Advanced plasma weapons
[[technology]]
id = "tech_plasma_weapons"
name = "Plasma Weapon Technology"
category = "weapons"
research_cost = 400
prerequisite = "tech_plasma_basics"
tier = 2
unlock_items = ["plasma_rifle", "plasma_carbine"]
unlock_recipes = ["recipe_plasma_rifle", "recipe_plasma_carbine"]

# Stage 3: Manufacturing efficiency
[[technology]]
id = "tech_plasma_mass_production"
name = "Plasma Weapon Mass Production"
category = "strategic"
research_cost = 300
prerequisite = "tech_plasma_weapons"
tier = 3
unlock_recipes = ["recipe_plasma_rifle_advanced", "recipe_plasma_carbine_advanced"]

[technology.bonus]
production_speed_multiplier = 1.3
production_cost_multiplier = 0.85
```

### Manufacturing Recipes

```toml
# Basic plasma rifle
[[recipe]]
id = "recipe_plasma_rifle"
name = "Plasma Rifle Production"
category = "weapons"
input_item = "plasma_rifle_components"
input_quantity = 1
output_item = "plasma_rifle"
output_quantity = 1
production_time = 480
production_cost = 1500
facility_requirement = "workshop"
skill_requirement = "weapon_assembly"
skill_level = 3
prerequisites = ["tech_plasma_weapons"]

# Advanced/faster production
[[recipe]]
id = "recipe_plasma_rifle_advanced"
name = "Advanced Plasma Rifle Production"
category = "weapons"
input_item = "plasma_rifle_components"
input_quantity = 1
output_item = "plasma_rifle"
output_quantity = 1
production_time = 300  # 25% faster
production_cost = 1200  # 20% cheaper
facility_requirement = "workshop"
skill_requirement = "weapon_assembly"
skill_level = 3
prerequisites = ["tech_plasma_mass_production"]
```

---

## Best Practices for Modding

### Research Balancing

- **Tier 1**: 50-150 man-days, basic technologies
- **Tier 2**: 200-400 man-days, improved technologies
- **Tier 3**: 500-800 man-days, advanced technologies
- **Tier 4**: 900-1500 man-days, cutting-edge
- **Tier 5**: 1600-2000 man-days, alien technology

### Manufacturing Balancing

- **Basic items**: 60-180 min production time
- **Complex items**: 300-600 min production time
- **Advanced items**: 720-1200 min production time

### Cost Guidelines

- Production cost should be 1/3 to 1/2 of item value
- Rare items cost more to manufacture
- Ammunition should be relatively cheap

### Recipe Distribution

- Spread recipes across multiple tiers
- Create dependencies (component assembly → final product)
- Balance accessibility with progression

---

## Error Reference

### Common Issues

| Error | Cause | Fix |
|-------|-------|-----|
| "Technology not found" | Invalid technology_id | Verify tech exists in technologies.toml |
| "Skill level too low" | Operator lacks required skill | Train personnel or assign higher-skilled workers |
| "Prerequisite not met" | Missing required technology | Complete prerequisite research first |
| "Facility not available" | Wrong facility type | Build required facility or assign correct workshop |
| "Insufficient materials" | Not enough input items | Gather more materials or adjust recipe |

### Debugging Tips

```lua
-- Check if technology is loaded
local tech = DataLoader.technology.get("tech_plasma_weapons")
if not tech then
    print("[ERROR] Technology not found in DataLoader")
else
    print("[OK] Technology loaded: " .. tech.name)
end

-- Check recipe validity
local recipe = DataLoader.recipe.get("recipe_plasma_rifle")
if not recipe.output_item then
    print("[ERROR] Recipe missing output_item")
end

-- Verify research progress
local project = base.current_research
print("Progress: " .. project.current_progress .. "/" .. project.total_progress)
print("ETA: " .. math.ceil((project.total_progress - project.current_progress) / project.scientists_assigned) .. " days")
```

---

## Related Documentation

- `API_SCHEMA_REFERENCE.md` - Core entity schemas
- `API_FACILITIES.md` - Facility production bonuses
- `wiki/systems/Economy.md` - Cost balancing guidelines
- `wiki/systems/Units.md` - Scientist assignment and skills
- `MOD_DEVELOPER_GUIDE.md` - Complete modding tutorial

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | Oct 21, 2025 | Initial documentation |

