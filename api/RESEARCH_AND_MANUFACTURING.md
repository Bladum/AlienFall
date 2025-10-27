# Research & Manufacturing API Reference

**System:** Strategic Layer (Technology Development & Production)  
**Module:** `engine/economy/research/`, `engine/economy/manufacturing/`  
**Latest Update:** October 22, 2025  
**Status:** ✅ Complete

---

## Overview

The Research and Manufacturing system manages technological advancement, equipment production, facility research capabilities, and resource conversion. Research unlocks new technologies, weapons, abilities, and facilities through sustained scientific investment. Manufacturing produces equipment from components using base facilities and engineer labor. Together, these systems convert resources and time into strategic advantages, forming the backbone of long-term strategic planning.

**Layer Classification:** Strategic / Technology & Production  
**Primary Responsibility:** Tech trees, research projects, manufacturing queues, production recipes, resource conversion, facility bonuses, technology unlocking  
**Integration Points:** Basescape (facilities), Items (production), Economy (costs), Science (progress tracking), Research sharing (Politics)

---

## Implementation Status

### ✅ Implemented (in engine/economy/)
- Research system with tech progression
- Manufacturing system with production queues
- Technology trees and prerequisites
- Facility requirements and dependencies
- Resource management and costs
- Research project tracking

### 🚧 Partially Implemented
- Multi-stage research projects
- Research sharing between organizations
- Automated production optimization

### 📋 Planned
- Advanced research initiatives
- AI-driven optimization
- Inter-organization tech exchange

---

## Core Entities

### Entity: Technology

Researchable technology node with prerequisites and unlocks.

**Properties:**
```lua
Technology = {
  id = string,                    -- "plasma_weaponry"
  name = string,                  -- "Plasma Weaponry"
  description = string,           -- Tech overview
  
  -- Classification
  category = string,              -- "weapons", "armor", "vehicles", "defense", "foundation"
  tier = number,                  -- 1-5 (progression level)
  
  -- Research Requirements
  research_points_required = number, -- Total to complete (man-days)
  research_time = number,         -- Turns to research
  research_cost = number,         -- Credits
  facility_required = string,     -- "research_lab"
  
  -- Prerequisites
  requires_tech = string[],       -- Tech IDs that must be completed first
  prerequisite = string | nil,    -- Single required prior tech
  
  -- Unlocks
  unlocks_items = string[],       -- Item IDs now available
  unlocks_techs = string[],       -- Subsequent techs unlocked
  unlocks_facilities = string[],  -- Facilities now buildable
  unlock_items = string[],        -- Alternative property for items unlocked
  unlock_recipes = string[],      -- Manufacturing recipes unlocked
  unlock_facilities = string[],   -- Alternative facilities property
  bonus_effects = table,          -- Gameplay bonuses (damage multiplier, etc.)
  
  -- Status
  is_researched = boolean,
  is_available = boolean,         -- Can research
  research_completion_date = number,
  
  -- Facility Bonuses
  facility_bonus_types = string[],   -- Facility types that provide bonus
  facility_bonus_percent = number,   -- Bonus percentage (10-30%)
}
```

**Functions:**
```lua
-- Access
Technology.getTech(tech_id: string) → Technology | nil
Technology.getTechs() → Technology[]
Technology.getTechsByCategory(category: string) → Technology[]
Technology.getTechsByTier(tier: number) → Technology[]
Technology.getResearchedTechs() → Technology[]
DataLoader.technology.get(techId) → table
DataLoader.technology.getAllIds() → table
DataLoader.technology.getByCategory(category) → table
DataLoader.technology.getByTier(tier) → table

-- Status
tech:isResearched() → boolean
tech:isAvailable() → boolean
tech:canResearch() → boolean (prerequisites met)
tech:getUnlockedItems() → string[]
tech:getUnlockedFacilities() → string[]
tech:getPrerequisites() → Technology[]

-- Info
tech:getResearchTime() → number
tech:getResearchCost() → number
tech:getCategory() → string
tech:getTier() → number
```

---

### Entity: ResearchProject

Active research assignment with progress tracking.

**Properties:**
```lua
ResearchProject = {
  id = string,                    -- "project_001_plasma"
  technology_id = string,         -- What's being researched
  
  -- Progress
  progress_points = number,       -- Current research points
  progress_percent = number,      -- 0-100
  turns_remaining = number,       -- Estimated turns
  is_complete = boolean,
  
  -- Assignment
  assigned_facility = string,     -- Lab facility ID
  base_id = string,               -- Target base
  researcher_unit = Unit | nil,   -- Lead researcher
  scientist_count = number,       -- Allocated scientists
  
  -- Priority
  priority = number,              -- 1-10
  
  -- Costs
  cost_per_day = number,          -- Credits per day
  estimated_completion = number,  -- Turn number
}
```

**Functions:**
```lua
-- Management
ResearchProject.create(tech_id, facility) → ResearchProject
ResearchProject.get(project_id) → ResearchProject | nil
project:getProgress() → number  -- 0-100%
project:getDaysRemaining() → number
project:canComplete() → boolean
project:complete() → void

-- Status queries
project:getStatus() → string
project:isActive() → boolean
project:isPaused() → boolean
project:getCostPerDay() → number
```

---

### Entity: ManufacturingJob

Production task queued at facility with progress tracking.

**Properties:**
```lua
ManufacturingJob = {
  id = string,                    -- "job_001_rifle_production"
  item_id = string,               -- Item being produced
  quantity = number,              -- How many to make
  
  -- Progress
  items_completed = number,       -- Made so far
  progress_percent = number,      -- 0-100
  turns_remaining = number,       -- Time to completion
  is_complete = boolean,
  
  -- Assignment
  assigned_facility = string,     -- Workshop facility ID
  
  -- Priority & Configuration
  priority = number,              -- 1-10
  batch_bonus = number,           -- Quantity discount
  
  -- Costs & Resources
  total_cost = number,            -- Total credits
  cost_per_item = number,
  resources_needed = table,       -- {resource_id: amount}
  resources_consumed = table,     -- Current consumption
}
```

**Functions:**
```lua
-- Management
ManufacturingJob.create(item_id, quantity, facility) → ManufacturingJob
ManufacturingJob.get(job_id) → ManufacturingJob | nil
job:getProgress() → number  -- 0-100%
job:getTurnsRemaining() → number
job:canComplete() → boolean
job:complete() → ItemStack[]

-- Status
job:getStatus() → string
job:isActive() → boolean
job:getTotalCost() → number
job:getItemsCompleted() → number
```

---

### Entity: ResearchTree

Visualization of technology progression with tier structure.

**Properties:**
```lua
ResearchTree = {
  -- Structure
  technologies = Technology[],
  root_techs = Technology[],      -- Starting techs
  
  -- Progress
  total_techs = number,
  researched_count = number,
  completed_percentage = number,
  
  -- Branches
  branches = table,               -- {category: techs}
  tiers = table,                  -- {tier_number: techs}
}
```

---

### Entity: Recipe

Manufacturing recipe defining inputs and outputs.

**Properties:**
```lua
Recipe = {
  id = string,                    -- "recipe_plasma_rifle"
  item_id = string,               -- Item produced
  
  -- Production
  production_time = number,       -- Turns per item
  production_cost = number,       -- Credits per item
  facility_required = string,     -- "workshop"
  
  -- Components
  components = table,             -- {item_id: quantity}
  
  -- Requirements
  requires_tech = string | nil,   -- Technology prerequisite
  requires_items = string[],      -- Items needed as input
}
```

---

## Services & Functions

### Research Management Service

```lua
-- Tech access
ResearchManager.getTech(tech_id: string) → Technology | nil
ResearchManager.getTechs() → Technology[]
ResearchManager.getTechsByCategory(category: string) → Technology[]
ResearchManager.getResearchedTechs() → Technology[]
ResearchManager.getAvailableTechs() → Technology[]
ResearchManager.getAvailableResearch(baseId: string) → table
DataLoader.technology.getPrerequisites(techId) → table

-- Research projects
ResearchManager.createProject(tech_id: string, facility: Facility) → ResearchProject
ResearchManager.startResearch(baseId, techId, scientistCount) → table
ResearchManager.getProject(project_id: string) → ResearchProject | nil
ResearchManager.getActiveProjects() → ResearchProject[]
ResearchManager.getResearchCost(techId: string) → number
ResearchManager.getResearchDuration(techId: string, scientistCount: number) → number
ResearchManager.getResearchProgress(researchId: string) → table

-- Project management
ResearchManager.completeProject(project: ResearchProject) → void
ResearchManager.completeResearch(techId: string) → boolean
ResearchManager.pauseResearch(researchId: string) → boolean
ResearchManager.resumeResearch(researchId: string) → boolean
ResearchManager.cancelResearch(researchId: string) → (boolean, number)

-- Progress
ResearchManager.addResearchPoints(project: ResearchProject, points: number) → void
ResearchManager.processResearch(delta_turns: number) → void
ResearchManager.getResearchProgress() → number (0-100%)
```

### Tech Tree Service

```lua
-- Tree access
TechTreeService.getResearchTree() → ResearchTree
TechTreeService.getTechsByTier(tier: number) → Technology[]
TechTree.getUnlockedTechs(baseId: string) → table
TechTree.getLockedTechs(baseId: string) → table
TechTree.canResearchTech(techId: string, baseId: string) → (boolean, string)
TechTree.getPrerequisiteTree(techId: string) → table
TechTree.getTechsUnlockedByResearch(techId: string) → table

-- Path finding
TechTreeService.getRequiredTechs(tech_id: string) → Technology[]
TechTreeService.getDependentTechs(tech_id: string) → Technology[]
TechTreeService.findResearchPath(start_tech: string, goal_tech: string) → Technology[]
TechTreeService.estimateResearchTime(path: string[]) → number
```

### Manufacturing Service

```lua
-- Job management
ManufacturingService.createJob(item_id: string, quantity: number, facility: Facility) → ManufacturingJob
ManufacturingService.getJob(job_id: string) → ManufacturingJob | nil
ManufacturingService.getActiveJobs() → ManufacturingJob[]
ManufacturingService.completeJob(job: ManufacturingJob) → ItemStack[]

-- Production
ManufacturingService.processProduction(delta_turns: number) → void
ManufacturingService.getProductionProgress() → number (0-100%)
ManufacturingService.getProductionQueue() → ManufacturingJob[]

-- Capacity
ManufacturingService.canProduceItem(item_id: string) → boolean
ManufacturingService.getProductionRate(facility: Facility) → number (items/turn)
ManufacturingService.estimateProductionTime(item_id: string, quantity: number) → number
```

### Recipe Service

```lua
-- Recipe access
RecipeService.getRecipe(recipe_id: string) → Recipe | nil
RecipeService.getRecipes() → Recipe[]
RecipeService.getRecipesByFacility(facility_type: string) → Recipe[]
RecipeService.getRecipeForItem(item_id: string) → Recipe | nil

-- Requirements
RecipeService.canCraft(recipe: Recipe) → boolean (resources available)
RecipeService.getRequiredComponents(recipe: Recipe) → table
RecipeService.getProductionTime(recipe: Recipe, quantity: number) → number
```

### Research Bonuses Service

```lua
-- Tech effects
ResearchBonusService.applyTechBonus(tech: Technology) → void
ResearchBonusService.getTechBonuses(tech_id: string) → table
ResearchBonusService.calculateDamageBonus(tech_list: string[]) → number
ResearchBonusService.calculateArmorBonus(tech_list: string[]) → number
ResearchBonusService.calculateSpeedBonus(tech_list: string[]) → number
ResearchBonusService.getWeaponBonus(weapon_id: string) → table
```

---

## Configuration (TOML)

### Technology Tree

```toml
# economy/research/tech_tree.toml

[[techs]]
id = "basic_construction"
name = "Basic Construction"
category = "foundation"
tier = 1
research_points = 100
research_time = 20
research_cost = 5000
description = "Foundational construction techniques"
facility_required = "research_lab"
requires_tech = []
unlocks_items = ["construction_materials"]
unlocks_techs = ["advanced_construction", "base_fortification"]

[[techs]]
id = "plasma_weaponry"
name = "Plasma Weaponry"
category = "weapons"
tier = 2
research_points = 500
research_time = 80
research_cost = 25000
description = "Alien plasma technology applied to weapons"
facility_required = "research_lab"
requires_tech = ["basic_construction", "energy_systems"]
unlocks_items = ["plasma_rifle", "plasma_cannon"]
unlocks_techs = ["advanced_plasma", "plasma_armor"]
facility_bonus_types = ["laboratory"]
facility_bonus_percent = 20

[techs[1].bonus_effects]
damage_multiplier = 1.8
```

### Research Configuration

```toml
# economy/research/projects.toml

[project_settings]
research_points_per_facility = 5
research_points_per_scientist = 2
priority_bonus = 0.1
parallel_research_limit = 3
```

### Manufacturing Recipes

```toml
# economy/manufacturing/recipes.toml

[[recipes]]
id = "rifle_production"
item_id = "rifle_standard"
production_time = 10
production_cost = 500
facility_required = "workshop"

[recipes[0].components]
metal_parts = 5
polymer_stock = 1
electronics = 2

[[recipes]]
id = "plasma_rifle_production"
item_id = "plasma_rifle"
production_time = 20
production_cost = 2500
facility_required = "advanced_workshop"
requires_tech = "plasma_weaponry"

[recipes[1].components]
plasma_cell = 1
weapon_frame = 1
targeting_system = 1
```

### Difficulty Modifiers

```toml
# economy/research/difficulty_modifiers.toml

[easy]
research_multiplier = 0.7
production_multiplier = 0.8

[normal]
research_multiplier = 1.0
production_multiplier = 1.0

[hard]
research_multiplier = 1.2
production_multiplier = 1.2

[impossible]
research_multiplier = 1.5
production_multiplier = 1.5
```

---

## Usage Examples

### Example 1: Start Research

```lua
-- Get available techs
local availableTechs = ResearchManager.getAvailableTechs()

-- Start research with scientists
local tech = ResearchManager.getTech("plasma_weaponry")
local base = BaseSystem.getBase("main_base")

if tech:canResearch() then
  local project = ResearchManager.startResearch(base.id, tech.id, 5)
  print("Research started: " .. project.id)
  print("Est. completion: " .. project.turns_remaining .. " turns")
end
```

### Example 2: Check Research Progress

```lua
-- Get active projects
local projects = ResearchManager.getActiveProjects()

for _, project in ipairs(projects) do
  local progress = ResearchManager.getResearchProgress(project.id)
  print("Progress: " .. progress.percentComplete .. "%")
  print("Days remaining: " .. progress.daysRemaining)
  print("Cost/day: $" .. progress.costPerDay)
end
```

### Example 3: Manufacture Items

```lua
-- Find recipe
local recipe = RecipeService.getRecipeForItem("plasma_rifle")
local facility = BaseSystem.getBase("main_base"):getFacility("workshop")

if ManufacturingService.canProduceItem("plasma_rifle") then
  -- Create job
  local job = ManufacturingService.createJob("plasma_rifle", 5, facility)
  
  print("Manufacturing: " .. job.quantity .. " plasma rifles")
  print("Time: " .. job.turns_remaining .. " turns")
  print("Cost: $" .. job.total_cost)
end
```

### Example 4: View Tech Tree

```lua
-- Get research tree
local tree = TechTreeService.getResearchTree()

print("Total techs: " .. tree.total_techs)
print("Researched: " .. tree.researched_count)
print("Progress: " .. tree.completed_percentage .. "%")

-- Get tier 2 techs
local tier2 = TechTreeService.getTechsByTier(2)
for _, tech in ipairs(tier2) do
  if tech.is_researched then
    print("✓ " .. tech.name)
  else
    print("○ " .. tech.name)
  end
end
```

### Example 5: Tech Bonuses

```lua
-- Get weapon bonus from research
local plasma_bonus = ResearchBonusService.getWeaponBonus("plasma_rifle")
print("Damage bonus: " .. plasma_bonus.damage_multiplier .. "x")

-- Calculate cumulative bonuses
local researched = ResearchManager.getResearchedTechs()
local tech_ids = array_map(researched, function(t) return t.id end)
local armor_bonus = ResearchBonusService.calculateArmorBonus(tech_ids)
print("Total armor bonus: " .. armor_bonus .. "%")
```

---

## Research Progression

### Early Game
- Focus on basic technologies (5-10 turns each)
- Unlocks manufacturing for basic equipment
- 2-5 scientists typical bottleneck
- Research costs: 50-150 man-days

### Mid Game
- Advanced technologies (20-40 turns each)
- Specialized equipment and facilities
- 5-10 scientists engaged
- Research costs: 200-500 man-days

### Late Game
- Alien technology branch
- Late-game weaponry and tactical advantages
- 15+ scientists specialized
- Research costs: 500-2000+ man-days

---

## Manufacturing Batch Bonuses

| Quantity | Efficiency | Time Multiplier |
|----------|-----------|-----------------|
| 1 | 100% | 1.0x |
| 5 | 105% | 0.95x |
| 10 | 110% | 0.90x |
| 20+ | 110% | 0.90x |

### Facility Specialization Bonuses

| Facility | Bonus | Effect |
|----------|-------|--------|
| Basic Workshop | +10% | Standard production |
| Advanced Workshop | +20% | Better equipment |
| Manufacturing Hub | +30% | Mass production |

---

## Integration Points

**Inputs from:**
- Basescape (facilities, engineers, scientists)
- Items (equipment definitions)
- Economy (costs, resources, budgets)
- Politics (research sharing agreements)

**Outputs to:**
- Items (manufactured equipment)
- Weapons system (unlocked weapons)
- Equipment (unlocked armor/gear)
- Facilities (new buildable types)
- UI (tech trees, research displays)
- Economy (cost calculations)

**Dependencies:**
- Facility system (research labs, workshops)
- Item system (equipment definitions)
- Cost calculation (research costs, production costs)
- Personnel system (scientist/engineer allocation)

---

## Error Handling

```lua
-- Tech not found
if not ResearchManager.getTech(tech_id) then
  print("Technology not found: " .. tech_id)
  return false
end

-- Prerequisite not met
if not tech:canResearch() then
  print("Prerequisites not met for: " .. tech.name)
  local prereqs = tech:getPrerequisites()
  for _, req in ipairs(prereqs) do
    if not req.is_researched then
      print("  Missing: " .. req.name)
    end
  end
end

-- Insufficient resources
if not ManufacturingService.canProduceItem(item_id) then
  print("Insufficient resources for manufacturing")
end
```

---

**Last Updated:** October 22, 2025  
**Status:** ✅ COMPLETE
