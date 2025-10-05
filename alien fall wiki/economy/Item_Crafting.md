# Item Crafting

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
- [Examples](#examples)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Item Crafting system enables production of weapons, armor, equipment, and consumables through manufacturing facilities consuming resources, materials, and engineer time according to crafting recipes unlocked through research, providing player-driven equipment progression and resource management challenges through queue management and production optimization.

---

## Table of Contents

1. [Overview](#overview)
2. [Workshop System](#workshop-system)
3. [Production Categories](#production-categories)
4. [Resource Requirements](#resource-requirements)
5. [Production Time](#production-time)
6. [Production Queue](#production-queue)
7. [Rush Production](#rush-production)
8. [Material Management](#material-management)
9. [Implementation](#implementation)
10. [Cross-References](#cross-references)

---

## Overview

The Item Crafting System allows players to manufacture equipment, weapons, armor, and consumables at their base using workshops, engineers, and resources. Production takes time and consumes materials, creating strategic decisions about prioritization and resource allocation.

### Design Principles

1. **Time Investment**: All items require production time (hours to weeks)
2. **Resource Scarcity**: Limited materials force prioritization
3. **Engineer Management**: Engineers are the workforce bottleneck
4. **Queue Strategy**: Managing multiple production lines
5. **Tech Progression**: Advanced items require research unlocks

### Key Features

- **Workshop Capacity**: Each workshop supports limited simultaneous projects
- **Engineer Assignment**: Projects progress based on assigned engineers
- **Material Consumption**: Resources consumed at production start
- **Rush Production**: Pay premium to accelerate critical items
- **Batch Production**: Manufacture multiple identical items efficiently
- **Research Requirements**: Items locked behind tech tree

---

## Workshop System

### Workshop Facility

```lua
-- Workshop facility data
workshop = {
    capacity = 50,              -- Engineer capacity
    active_projects = {},       -- Current production
    max_projects = 10,          -- Simultaneous projects
    efficiency = 1.0,           -- Base efficiency multiplier
    upgrades = {}               -- Facility upgrades
}
```

### Workshop Capacity

| Facility | Engineers | Max Projects | Monthly Cost |
|----------|-----------|--------------|--------------|
| Basic Workshop | 50 | 10 | $40,000 |
| Advanced Workshop | 75 | 15 | $65,000 |
| Fabrication Complex | 100 | 20 | $90,000 |

### Engineer Assignment

```lua
-- Calculate available engineers
function get_available_engineers(base)
    local total_capacity = 0
    for _, workshop in ipairs(base.workshops) do
        total_capacity = total_capacity + workshop.capacity
    end
    
    local assigned = 0
    for _, project in ipairs(base.active_projects) do
        assigned = assigned + project.engineers_assigned
    end
    
    return total_capacity - assigned
end

-- Engineer efficiency
function calculate_engineer_efficiency(project, workshop)
    local base_efficiency = workshop.efficiency
    
    -- Overcrowding penalty (>90% capacity)
    local utilization = get_workshop_utilization(workshop)
    if utilization > 0.9 then
        base_efficiency = base_efficiency * 0.8
    end
    
    -- Specialization bonus
    if workshop.specialization == project.category then
        base_efficiency = base_efficiency * 1.2
    end
    
    return base_efficiency
end
```

### Workshop Upgrades

| Upgrade | Cost | Effect |
|---------|------|--------|
| Improved Tools | $50,000 | +10% efficiency |
| Automation | $100,000 | +5 max projects |
| Expanded Floor | $75,000 | +25 engineer capacity |
| Specialization (Weapons) | $60,000 | +20% efficiency for weapons |
| Specialization (Armor) | $60,000 | +20% efficiency for armor |
| Quality Control | $40,000 | Items have +5% better stats |

---

## Production Categories

### Item Types

| Category | Examples | Typical Time | Engineer Intensity |
|----------|----------|--------------|-------------------|
| Ammunition | Bullets, laser cells | 1-3 days | Low (10-20) |
| Grenades | Frag, smoke, alien | 2-5 days | Low (15-25) |
| Weapons | Rifles, heavy weapons | 5-20 days | Medium (30-50) |
| Armor | Body armor, power suits | 10-30 days | High (40-80) |
| Equipment | Medkits, scanners | 3-10 days | Medium (20-40) |
| Craft Weapons | Cannons, missiles | 15-45 days | High (50-100) |
| Craft Equipment | Armor, engines | 20-60 days | Very High (80-150) |
| Facilities | Base structures | 14-60 days | Very High (100-300) |

---

## Resource Requirements

### Resource Types

```lua
-- Material categories
RESOURCE_TYPES = {
    -- Basic materials
    "money",           -- Cash ($)
    "alloys",          -- Alien alloys
    "elerium",         -- Elerium-115
    "electronics",     -- Electronic components
    "chemicals",       -- Chemical compounds
    "steel",           -- Structural steel
    "plastics",        -- Polymers
    
    -- Advanced materials
    "meld",            -- Biological material
    "power_cores",     -- Energy cells
    "advanced_chips",  -- Alien computer tech
    
    -- Salvage
    "ufo_power_source",
    "ufo_navigation",
    "ufo_construction",
    "alien_food",
    "alien_entertainment",
    "alien_surgery"
}
```

### Resource Costs by Item Type

#### Conventional Weapons

| Item | Money | Electronics | Steel | Production Time |
|------|-------|-------------|-------|----------------|
| Pistol | $400 | 1 | 2 | 2 days |
| Rifle | $800 | 2 | 4 | 3 days |
| Heavy Cannon | $2,000 | 5 | 15 | 10 days |
| Rocket Launcher | $3,000 | 8 | 10 | 12 days |
| Auto-Cannon | $4,500 | 10 | 20 | 15 days |

#### Laser Weapons

| Item | Money | Electronics | Alloys | Power Cores | Time |
|------|-------|-------------|--------|-------------|------|
| Laser Pistol | $4,000 | 10 | 2 | 1 | 7 days |
| Laser Rifle | $8,000 | 20 | 5 | 2 | 12 days |
| Heavy Laser | $20,000 | 40 | 10 | 4 | 20 days |
| Laser Cannon (craft) | $50,000 | 80 | 25 | 10 | 40 days |

#### Plasma Weapons

| Item | Money | Alloys | Elerium | Electronics | Time |
|------|-------|--------|---------|-------------|------|
| Plasma Pistol | $10,000 | 5 | 2 | 15 | 14 days |
| Plasma Rifle | $20,000 | 10 | 4 | 30 | 20 days |
| Heavy Plasma | $40,000 | 20 | 8 | 50 | 28 days |
| Plasma Cannon (craft) | $100,000 | 50 | 20 | 100 | 50 days |

#### Armor

| Item | Money | Alloys | Electronics | Chemicals | Time |
|------|-------|--------|-------------|-----------|------|
| Personal Armor | $5,000 | 3 | 2 | 5 | 12 days |
| Power Armor | $30,000 | 15 | 10 | 10 | 25 days |
| Flying Suit | $50,000 | 25 | 20 | 15 | 35 days |

#### Craft Equipment

| Item | Money | Alloys | Elerium | Electronics | Time |
|------|-------|--------|---------|-------------|------|
| Craft Armor (basic) | $20,000 | 10 | 0 | 30 | 20 days |
| Craft Armor (advanced) | $50,000 | 30 | 10 | 50 | 35 days |
| UFO Construction (reverse) | $100,000 | 50 | 20 | 100 | 60 days |

### Resource Calculation

```lua
-- Calculate total cost for production
function calculate_production_cost(item_id, quantity)
    local template = ITEM_TEMPLATES[item_id]
    local cost = {}
    
    for resource, amount in pairs(template.resources) do
        cost[resource] = amount * quantity
    end
    
    return cost
end

-- Check if resources available
function can_afford_production(base, item_id, quantity)
    local cost = calculate_production_cost(item_id, quantity)
    
    for resource, amount in pairs(cost) do
        if base.resources[resource] < amount then
            return false, resource -- Return missing resource
        end
    end
    
    return true
end

-- Consume resources for production
function consume_production_resources(base, item_id, quantity)
    local cost = calculate_production_cost(item_id, quantity)
    
    for resource, amount in pairs(cost) do
        base.resources[resource] = base.resources[resource] - amount
    end
end
```

---

## Production Time

### Base Production Time Formula

```lua
-- Calculate production time for an item
function calculate_base_production_time(item_id)
    local template = ITEM_TEMPLATES[item_id]
    
    -- Base time in hours
    local base_hours = template.base_production_hours
    
    return base_hours
end
```

### Engineer Impact on Production Speed

```lua
-- Calculate actual production time with engineers
function calculate_production_time(item_id, engineers_assigned, workshop)
    local base_hours = calculate_base_production_time(item_id)
    local template = ITEM_TEMPLATES[item_id]
    
    -- Engineer requirement
    local required_engineers = template.engineer_requirement
    
    -- Calculate efficiency
    local engineer_ratio = engineers_assigned / required_engineers
    local efficiency = calculate_engineer_efficiency(project, workshop)
    
    -- Time reduction formula (diminishing returns)
    -- At 100% engineers: 1.0x time
    -- At 150% engineers: 0.75x time
    -- At 200% engineers: 0.6x time
    local time_multiplier = 1.0
    if engineer_ratio >= 1.0 then
        time_multiplier = 1.0 / math.sqrt(engineer_ratio)
    else
        -- Understaffed: proportionally slower
        time_multiplier = 1.0 / engineer_ratio
    end
    
    -- Apply workshop efficiency
    time_multiplier = time_multiplier / efficiency
    
    local final_hours = base_hours * time_multiplier
    
    return math.ceil(final_hours)
end
```

### Production Time Examples

#### Example 1: Laser Rifle (Standard Staffing)

```lua
-- Laser Rifle template
item = {
    id = "laser_rifle",
    base_production_hours = 288, -- 12 days × 24 hours
    engineer_requirement = 40
}

-- Workshop with 40 engineers assigned
engineers = 40
workshop_efficiency = 1.0

-- Calculation
engineer_ratio = 40 / 40 = 1.0
time_multiplier = 1.0 / sqrt(1.0) = 1.0
final_hours = 288 × 1.0 = 288 hours = 12 days
```

#### Example 2: Laser Rifle (Overstaffed)

```lua
-- Same item, 60 engineers assigned
engineers = 60

-- Calculation
engineer_ratio = 60 / 40 = 1.5
time_multiplier = 1.0 / sqrt(1.5) = 0.816
final_hours = 288 × 0.816 = 235 hours ≈ 9.8 days

-- Result: 60 engineers complete in ~10 days (20% faster)
```

#### Example 3: Laser Rifle (Understaffed)

```lua
-- Same item, 20 engineers assigned
engineers = 20

-- Calculation
engineer_ratio = 20 / 40 = 0.5
time_multiplier = 1.0 / 0.5 = 2.0
final_hours = 288 × 2.0 = 576 hours = 24 days

-- Result: 20 engineers complete in 24 days (2× slower)
```

### Batch Production Bonus

```lua
-- Calculate batch production efficiency
function calculate_batch_bonus(item_id, quantity)
    if quantity <= 1 then return 1.0 end
    
    local template = ITEM_TEMPLATES[item_id]
    
    -- Simple items get bigger batch bonus
    local complexity = template.complexity or 1.0 -- 0.5 = simple, 1.0 = normal, 2.0 = complex
    
    -- Batch bonus: 10% per additional item (up to 50% max)
    local batch_efficiency = 1.0
    for i = 2, quantity do
        local bonus = 0.1 / complexity
        batch_efficiency = batch_efficiency + math.min(bonus, 0.5)
    end
    
    return math.min(batch_efficiency, 1.5) -- Cap at 50% bonus
end

-- Apply to production time
function calculate_batch_production_time(item_id, quantity, engineers, workshop)
    local single_item_time = calculate_production_time(item_id, engineers, workshop)
    local total_time = single_item_time * quantity
    local batch_bonus = calculate_batch_bonus(item_id, quantity)
    
    return math.ceil(total_time / batch_bonus)
end

-- Example: 5 laser rifles
-- Single rifle: 288 hours
-- 5 rifles without bonus: 288 × 5 = 1440 hours (60 days)
-- Batch bonus: 1.4× efficiency (40% bonus)
-- 5 rifles with bonus: 1440 / 1.4 = 1029 hours (43 days)
-- Savings: 17 days
```

---

## Production Queue

### Queue System

```lua
-- Production queue manager
ProductionQueue = {
    active = {},    -- Currently manufacturing
    pending = {},   -- Waiting for resources/engineers
    completed = {}  -- Finished items
}

-- Add item to production queue
function ProductionQueue:add_project(base, item_id, quantity, priority)
    -- Check research requirements
    if not is_item_unlocked(base, item_id) then
        return false, "Item not researched"
    end
    
    -- Check resources
    local can_afford, missing = can_afford_production(base, item_id, quantity)
    if not can_afford then
        return false, "Insufficient " .. missing
    end
    
    -- Consume resources immediately
    consume_production_resources(base, item_id, quantity)
    
    -- Create project
    local project = {
        id = generate_project_id(),
        item_id = item_id,
        quantity = quantity,
        priority = priority or 5,
        engineers_assigned = 0,
        hours_completed = 0,
        hours_required = calculate_batch_production_time(item_id, quantity, 0, nil),
        status = "pending",
        started_date = nil,
        completion_date = nil
    }
    
    table.insert(self.pending, project)
    
    return true, project.id
end

-- Assign engineers to project
function ProductionQueue:assign_engineers(project_id, engineer_count)
    local project = self:get_project(project_id)
    if not project then return false end
    
    local available = get_available_engineers(base)
    local actual_assigned = math.min(engineer_count, available)
    
    project.engineers_assigned = actual_assigned
    
    -- Recalculate time with assigned engineers
    local workshop = get_workshop_for_project(base, project)
    project.hours_required = calculate_production_time(
        project.item_id,
        actual_assigned,
        workshop
    ) * project.quantity
    
    if actual_assigned > 0 and project.status == "pending" then
        project.status = "active"
        project.started_date = game_time()
        table.insert(self.active, project)
        remove_from_pending(project)
    end
    
    return true
end
```

### Queue Management

#### Priority System

```lua
PRIORITY_LEVELS = {
    critical = 1,   -- Base defense, critical research
    high = 3,       -- Important equipment
    normal = 5,     -- Standard production
    low = 7,        -- Stockpiling
    background = 9  -- Non-urgent items
}

-- Sort queue by priority
function sort_production_queue(queue)
    table.sort(queue, function(a, b)
        if a.priority ~= b.priority then
            return a.priority < b.priority -- Lower number = higher priority
        else
            return a.started_date < b.started_date -- FIFO for same priority
        end
    end)
end
```

#### Pausing and Canceling

```lua
-- Pause production
function ProductionQueue:pause_project(project_id)
    local project = self:get_project(project_id)
    if not project then return false end
    
    project.status = "paused"
    
    -- Free up engineers
    local freed_engineers = project.engineers_assigned
    project.engineers_assigned = 0
    
    return true, freed_engineers
end

-- Resume production
function ProductionQueue:resume_project(project_id)
    local project = self:get_project(project_id)
    if not project or project.status ~= "paused" then return false end
    
    project.status = "pending"
    -- Will need to re-assign engineers
    
    return true
end

-- Cancel production (refund 50% of resources)
function ProductionQueue:cancel_project(project_id)
    local project = self:get_project(project_id)
    if not project then return false end
    
    -- Calculate refund (50% of remaining work)
    local completion_ratio = project.hours_completed / project.hours_required
    local refund_ratio = (1.0 - completion_ratio) * 0.5
    
    local cost = calculate_production_cost(project.item_id, project.quantity)
    for resource, amount in pairs(cost) do
        local refund = math.floor(amount * refund_ratio)
        base.resources[resource] = base.resources[resource] + refund
    end
    
    -- Remove project
    remove_project(project_id)
    
    return true, refund_ratio
end
```

### Production Progress

```lua
-- Update production (called every game hour)
function ProductionQueue:update(hours_elapsed)
    for _, project in ipairs(self.active) do
        if project.engineers_assigned > 0 then
            -- Calculate progress this tick
            local workshop = get_workshop_for_project(base, project)
            local efficiency = calculate_engineer_efficiency(project, workshop)
            
            -- Hours of progress
            local progress = hours_elapsed * efficiency
            project.hours_completed = project.hours_completed + progress
            
            -- Check completion
            if project.hours_completed >= project.hours_required then
                self:complete_project(project)
            end
        end
    end
end

-- Complete production
function ProductionQueue:complete_project(project)
    project.status = "completed"
    project.completion_date = game_time()
    
    -- Add items to base inventory
    add_items_to_inventory(base, project.item_id, project.quantity)
    
    -- Free engineers
    project.engineers_assigned = 0
    
    -- Move to completed list
    table.insert(self.completed, project)
    remove_from_active(project)
    
    -- Notification
    notify_production_complete(project)
end
```

---

## Rush Production

### Rush System

Rush production allows players to pay extra money to accelerate critical items.

```lua
-- Calculate rush cost
function calculate_rush_cost(project)
    local remaining_hours = project.hours_required - project.hours_completed
    local item_template = ITEM_TEMPLATES[project.item_id]
    
    -- Base rush cost: $100 per remaining hour
    local base_cost = remaining_hours * 100
    
    -- Item complexity multiplier
    local complexity_mult = item_template.complexity or 1.0
    
    -- Quantity multiplier (rushing multiple items is expensive)
    local quantity_mult = 1.0 + (project.quantity - 1) * 0.5
    
    local total_cost = base_cost * complexity_mult * quantity_mult
    
    return math.floor(total_cost)
end

-- Rush production
function ProductionQueue:rush_production(project_id)
    local project = self:get_project(project_id)
    if not project or project.status ~= "active" then
        return false, "Project not in progress"
    end
    
    local cost = calculate_rush_cost(project)
    
    if base.resources.money < cost then
        return false, "Insufficient funds"
    end
    
    -- Pay rush cost
    base.resources.money = base.resources.money - cost
    
    -- Complete instantly
    project.hours_completed = project.hours_required
    self:complete_project(project)
    
    return true, cost
end
```

### Rush Examples

#### Example 1: Laser Rifle (Rush Early)

```lua
-- Laser Rifle: 288 hours (12 days), $8,000 base cost
-- Rush after 48 hours (2 days) completed
remaining_hours = 288 - 48 = 240
complexity = 1.0
quantity = 1

rush_cost = 240 × 100 × 1.0 × 1.0 = $24,000

-- Total cost: $8,000 (item) + $24,000 (rush) = $32,000 (4× base cost)
-- Time saved: 10 days
```

#### Example 2: Batch Rush (5 Laser Rifles)

```lua
-- 5 Laser Rifles: 1029 hours (43 days), $40,000 base cost
-- Rush after 200 hours (8 days)
remaining_hours = 1029 - 200 = 829
complexity = 1.0
quantity = 5
quantity_mult = 1.0 + (5 - 1) × 0.5 = 3.0

rush_cost = 829 × 100 × 1.0 × 3.0 = $248,700

-- Total cost: $40,000 + $248,700 = $288,700
-- Very expensive for batch rush!
```

---

## Material Management

### Storage System

```lua
-- Base storage capacity
storage = {
    max_general = 100,      -- General items
    max_alien_artifacts = 50, -- Alien tech
    max_corpses = 50,       -- Alien bodies
    max_elerium = 200,      -- Elerium units
    max_alloys = 500        -- Alloy units
}

-- Check storage capacity
function check_storage_capacity(base, item_id, quantity)
    local item_template = ITEM_TEMPLATES[item_id]
    local storage_type = item_template.storage_category
    
    local current = count_items_in_storage(base, storage_type)
    local capacity = base.storage["max_" .. storage_type]
    
    return current + quantity <= capacity
end
```

### Material Sources

| Resource | Primary Source | Secondary Source |
|----------|---------------|------------------|
| Money | Monthly funding, sales | Mission rewards |
| Alloys | UFO salvage, alien bases | Purchase (expensive) |
| Elerium | UFO power sources | Alien base raids |
| Electronics | Purchase, manufacture | UFO navigation |
| Chemicals | Purchase, manufacture | Alien food/drugs |
| Steel | Purchase | UFO construction |
| Plastics | Purchase, manufacture | UFO components |

### Selling Manufactured Items

```lua
-- Sell manufactured item
function sell_manufactured_item(base, item_id, quantity)
    local item_template = ITEM_TEMPLATES[item_id]
    
    -- Sell price is 50% of manufacturing cost
    local production_cost = calculate_production_cost(item_id, 1)
    local sell_price = math.floor(production_cost.money * 0.5)
    
    -- Remove from inventory
    remove_items_from_inventory(base, item_id, quantity)
    
    -- Add money
    base.resources.money = base.resources.money + (sell_price * quantity)
    
    return sell_price * quantity
end

-- Manufacturing for profit (rarely worthwhile)
-- Exception: Laser cannons, alien grenades (high demand)
```

---

## Implementation

### Production System Module

```lua
-- Production system manager
ProductionSystem = {}

function ProductionSystem:init(base)
    self.base = base
    self.queue = ProductionQueue:new()
    self.workshops = {}
    
    -- Initialize workshops
    for _, facility in ipairs(base.facilities) do
        if facility.type == "workshop" then
            table.insert(self.workshops, facility)
        end
    end
end

-- Start new production
function ProductionSystem:start_production(item_id, quantity, priority)
    return self.queue:add_project(self.base, item_id, quantity, priority)
end

-- Auto-assign engineers (optimize)
function ProductionSystem:auto_assign_engineers()
    local available = get_available_engineers(self.base)
    
    -- Sort projects by priority
    local projects = self.queue:get_pending_projects()
    sort_production_queue(projects)
    
    -- Assign engineers to highest priority projects
    for _, project in ipairs(projects) do
        if available <= 0 then break end
        
        local template = ITEM_TEMPLATES[project.item_id]
        local optimal = template.engineer_requirement
        local assigned = math.min(optimal, available)
        
        self.queue:assign_engineers(project.id, assigned)
        available = available - assigned
    end
end

-- Update production progress (called every game hour)
function ProductionSystem:update(hours_elapsed)
    self.queue:update(hours_elapsed)
end

-- UI: Get production status
function ProductionSystem:get_status()
    return {
        active = self.queue.active,
        pending = self.queue.pending,
        completed = self.queue.completed,
        available_engineers = get_available_engineers(self.base)
    }
end

return ProductionSystem
```

### UI Integration

```lua
-- Production screen rendering
function draw_production_screen(production_system)
    local status = production_system:get_status()
    
    -- Available engineers display
    love.graphics.print("Engineers: " .. status.available_engineers, 20, 20)
    
    -- Active projects
    love.graphics.print("ACTIVE PRODUCTION:", 20, 60)
    local y = 80
    for _, project in ipairs(status.active) do
        local progress = project.hours_completed / project.hours_required
        local progress_pct = math.floor(progress * 100)
        
        love.graphics.print(
            project.item_id .. " ×" .. project.quantity ..
            " (" .. progress_pct .. "%) - " ..
            project.engineers_assigned .. " engineers",
            40, y
        )
        
        -- Progress bar
        love.graphics.rectangle("fill", 400, y, 200 * progress, 12)
        love.graphics.rectangle("line", 400, y, 200, 12)
        
        y = y + 20
    end
    
    -- New production button
    if draw_button("New Production", 20, 500) then
        open_production_dialog()
    end
end
```

---

## Cross-References

### Related Systems

- **[Economy System](README.md)** - Resource management and income
- **[Research System](Research.md)** - Unlocking craftable items
- **[Base Management](../basescape/README.md)** - Workshop facilities
- **[Resource Flow](Resource_Flow.md)** - Material sources and consumption
- **[Tech Tree](Tech_Tree_Overview.md)** - Research dependencies
- **[Time Systems](../core/Time_Systems.md)** - Production timing

### Data Files

- `data/economy/items.toml` - Item templates and costs
- `data/economy/production.toml` - Production parameters
- `data/basescape/facilities.toml` - Workshop specifications

### Implementation Files

- `src/economy/production_system.lua` - Production manager
- `src/economy/production_queue.lua` - Queue management
- `src/screens/production_screen.lua` - Production UI
- `src/economy/resource_manager.lua` - Resource tracking

---

**End of Item Crafting System Specification**

*Version 1.0 - September 30, 2025*
