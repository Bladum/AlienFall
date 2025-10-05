# Craft Lifecycle

## Table of Contents
- [Overview](#overview)
- [Lifecycle States](#lifecycle-states)
- [Related Wiki Pages](#related-wiki-pages)

## Overview

The Craft Lifecycle integration document tracks the complete state transitions for player and alien craft from hangar assignment through interception, combat, repair, and decommissioning, coordinating interactions between basescape facilities, geoscape positioning, interception mechanics, and maintenance systems.  
**Related Systems:** Basescape, Geoscape, Interception, Economy

---

## Purpose

This document describes the **complete lifecycle** of player-controlled craft in AlienFall, from construction through mission operations and eventual decommissioning.

**Key Insight:** Crafts follow a 6-phase lifecycle: Construction → Assignment → Deployment → Mission → Recovery → Maintenance/Decommission.

---

## Lifecycle Overview

### Six-Phase Process

```
┌──────────────┐
│CONSTRUCTION  │ ← Built in Hangar facility
└──────┬───────┘
       │ Build complete
       ↓
┌──────────────┐
│ ASSIGNMENT   │ ← Assign to base, equip weapons/squad
└──────┬───────┘
       │ Ready for operations
       ↓
┌──────────────┐
│ DEPLOYMENT   │ ← Launch from base
└──────┬───────┘
       │ En route to mission
       ↓
┌──────────────┐
│   MISSION    │ ← Active operations (patrol/intercept/assault)
└──────┬───────┘
       │ Mission complete
       ↓
┌──────────────┐
│  RECOVERY    │ ← Return to base
└──────┬───────┘
       │ Arrived at base
       ↓
┌──────────────┐
│ MAINTENANCE  │ ← Repair/refuel/rearm → Back to Assignment
└──────────────┘
       │ or
       ↓
┌──────────────┐
│DECOMMISSION  │ ← Scrap or retire craft
└──────────────┘
```

---

## Phase 1: Construction

### Build Requirements

**Hangar Facility:**
```lua
facility = {
    type = "hangar",
    size = {width = 2, height = 2},  -- 2×2 grid spaces
    capacity = 1,  -- One craft per hangar
    construction_time = 20,  -- 20 days (100 ticks)
    cost = 200000
}
```

**Craft Prerequisites:**
```lua
craft_requirements = {
    research = "Interceptor Technology",  -- Must be researched
    materials = {
        {item = "Alloy", quantity = 50},
        {item = "Elerium", quantity = 10},
        {item = "Electronics", quantity = 30}
    },
    engineers = 10,  -- Engineers assigned to production
    production_time = 30,  -- 30 days
    cost = 500000
}
```

### Construction Process

**Queue System:**
```lua
function queue_craft_construction(base, craft_type)
    local hangar = find_available_hangar(base)
    if not hangar then
        error("No available hangar for construction")
    end
    
    local construction = {
        type = "craft",
        craft_type = craft_type,
        hangar = hangar,
        progress = 0,
        duration = craft_type.production_time,
        materials_consumed = false,
        engineers_assigned = 0
    }
    
    table.insert(base.production_queue, construction)
    return construction
end
```

**Production Progress:**
```lua
function update_craft_construction(construction, base, dt)
    -- Check if materials available
    if not construction.materials_consumed then
        if can_consume_materials(base, construction.craft_type.materials) then
            consume_materials(base, construction.craft_type.materials)
            construction.materials_consumed = true
        else
            return  -- Wait for materials
        end
    end
    
    -- Assign engineers
    local available_engineers = base.engineers - count_assigned_engineers(base)
    construction.engineers_assigned = math.min(available_engineers, construction.craft_type.engineers)
    
    -- Calculate progress
    local progress_per_tick = construction.engineers_assigned / construction.craft_type.engineers
    construction.progress = construction.progress + progress_per_tick * dt
    
    -- Check completion
    if construction.progress >= construction.duration then
        complete_craft_construction(construction, base)
    end
end
```

**Completion:**
```lua
function complete_craft_construction(construction, base)
    local craft = create_craft(construction.craft_type, base)
    craft.location = base.location
    craft.home_base = base
    craft.status = "hangar"
    
    table.insert(base.crafts, craft)
    remove_from_queue(base.production_queue, construction)
    
    notify_player("Craft construction complete: " .. craft.name)
end
```

### Output

```lua
phase1_output = {
    craft = new_craft,
    status = "hangar",
    location = base.location,
    home_base = base
}
```

---

## Phase 2: Assignment

### Initial Setup

**Craft Object:**
```lua
craft = {
    id = generate_craft_id(),
    name = "Interceptor-1",
    type = "interceptor",
    home_base = base,
    location = base.location,
    status = "hangar",  -- hangar, ready, en_route, mission, returning, maintenance
    
    -- Stats
    speed = 2000,       -- km/h
    fuel = 1000,        -- Current fuel
    max_fuel = 1000,    -- Maximum fuel capacity
    health = 100,       -- Current health
    max_health = 100,   -- Maximum health
    
    -- Equipment
    weapons = {},       -- Installed weapons (max 2)
    squad = {},         -- Assigned soldiers (max 8)
    cargo = {},         -- Carried items
    
    -- Operational
    mission = nil,      -- Current mission
    destination = nil,  -- Target location
    maintenance_required = false
}
```

### Weapon Installation

**Weapon Slots:**
```lua
function install_weapon(craft, weapon, slot)
    if slot < 1 or slot > 2 then
        error("Invalid weapon slot: " .. slot)
    end
    
    if craft.weapons[slot] then
        -- Remove existing weapon
        uninstall_weapon(craft, slot)
    end
    
    craft.weapons[slot] = {
        weapon = weapon,
        ammo = weapon.max_ammo,
        operational_energy = 100
    }
    
    -- Consume weapon from inventory
    remove_item(craft.home_base.inventory, weapon)
end

function uninstall_weapon(craft, slot)
    local weapon_data = craft.weapons[slot]
    if weapon_data then
        -- Return weapon to inventory
        add_item(craft.home_base.inventory, weapon_data.weapon)
        craft.weapons[slot] = nil
    end
end
```

**Weapon Types:**
```lua
weapon_types = {
    {name = "Cannon", damage = 20, range = 500, ammo = 200, ap_cost = 2},
    {name = "Laser", damage = 30, range = 800, ammo = 100, ap_cost = 2},
    {name = "Plasma", damage = 50, range = 1000, ammo = 50, ap_cost = 3},
    {name = "Missile", damage = 100, range = 1200, ammo = 6, ap_cost = 3}
}
```

### Squad Assignment

**Soldier Selection:**
```lua
function assign_squad(craft, soldiers)
    if #soldiers > 8 then
        error("Maximum 8 soldiers per craft")
    end
    
    -- Check soldiers are available
    for _, soldier in ipairs(soldiers) do
        if soldier.status ~= "available" then
            error("Soldier " .. soldier.name .. " is not available")
        end
    end
    
    -- Assign soldiers
    craft.squad = {}
    for _, soldier in ipairs(soldiers) do
        table.insert(craft.squad, soldier)
        soldier.status = "assigned"
        soldier.assigned_craft = craft
    end
end

function unassign_squad(craft)
    for _, soldier in ipairs(craft.squad) do
        soldier.status = "available"
        soldier.assigned_craft = nil
    end
    craft.squad = {}
end
```

### Readiness Check

**Pre-Flight Validation:**
```lua
function check_craft_readiness(craft)
    local issues = {}
    
    -- Check fuel
    if craft.fuel < craft.max_fuel * 0.5 then
        table.insert(issues, "Low fuel: " .. craft.fuel .. "/" .. craft.max_fuel)
    end
    
    -- Check health
    if craft.health < craft.max_health * 0.8 then
        table.insert(issues, "Damaged: " .. craft.health .. "/" .. craft.max_health)
    end
    
    -- Check weapons
    if #craft.weapons == 0 then
        table.insert(issues, "No weapons installed")
    end
    
    -- Check squad
    if #craft.squad == 0 then
        table.insert(issues, "No squad assigned")
    end
    
    if #issues == 0 then
        craft.status = "ready"
        return true, "Craft ready for deployment"
    else
        return false, issues
    end
end
```

### Output

```lua
phase2_output = {
    craft_ready = true,
    weapons_installed = 2,
    squad_size = 8,
    fuel_level = 100,
    health_level = 100
}
```

---

## Phase 3: Deployment

### Launch Sequence

**Mission Assignment:**
```lua
function deploy_craft(craft, mission)
    local ready, issues = check_craft_readiness(craft)
    if not ready then
        show_warning("Cannot deploy craft", issues)
        return false
    end
    
    craft.status = "en_route"
    craft.mission = mission
    craft.destination = mission.location
    
    mission.assigned_craft = craft
    mission.state = "traveling"
    
    -- Calculate ETA
    local distance = calculate_distance(craft.location, mission.location)
    mission.eta = world.current_time + (distance / craft.speed)
    
    log_event("Craft " .. craft.name .. " deployed to " .. mission.type)
    return true
end
```

**Patrol Mode:**
```lua
function deploy_patrol(craft, patrol_route)
    local ready, issues = check_craft_readiness(craft)
    if not ready then
        show_warning("Cannot deploy craft", issues)
        return false
    end
    
    craft.status = "patrol"
    craft.patrol_route = patrol_route
    craft.patrol_index = 1
    craft.destination = patrol_route[1]
    
    log_event("Craft " .. craft.name .. " on patrol")
    return true
end
```

### Travel Mechanics

**Position Update:**
```lua
function update_craft_travel(craft, dt)
    if craft.status ~= "en_route" and craft.status ~= "patrol" and craft.status ~= "returning" then
        return
    end
    
    -- Calculate movement
    local distance_to_destination = calculate_distance(craft.location, craft.destination)
    local distance_traveled = craft.speed * (dt / 3600)  -- Convert hours to seconds
    
    -- Consume fuel
    local fuel_consumption = (distance_traveled / 1000) * 0.1  -- 0.1 fuel per km
    craft.fuel = math.max(0, craft.fuel - fuel_consumption)
    
    if craft.fuel == 0 then
        emergency_landing(craft)
        return
    end
    
    -- Update position
    if distance_traveled >= distance_to_destination then
        -- Arrived
        craft.location = craft.destination
        on_craft_arrival(craft)
    else
        -- Move toward destination
        local direction = normalize(craft.destination - craft.location)
        craft.location = craft.location + direction * distance_traveled
    end
end
```

**Arrival Handling:**
```lua
function on_craft_arrival(craft)
    if craft.status == "en_route" and craft.mission then
        -- Mission site arrival
        craft.status = "mission"
        on_mission_arrival(craft, craft.mission)
    elseif craft.status == "patrol" then
        -- Patrol waypoint reached
        craft.patrol_index = craft.patrol_index + 1
        if craft.patrol_index > #craft.patrol_route then
            craft.patrol_index = 1  -- Loop patrol
        end
        craft.destination = craft.patrol_route[craft.patrol_index]
    elseif craft.status == "returning" then
        -- Returned to base
        craft.location = craft.home_base.location
        craft.status = "hangar"
        on_craft_return(craft)
    end
end
```

### Output

```lua
phase3_output = {
    craft_location = {x = current_x, y = current_y},
    eta = estimated_arrival_time,
    fuel_remaining = fuel_percentage,
    status = "en_route"
}
```

---

## Phase 4: Mission Operations

### Mission Types

**Interception Mission:**
```lua
function execute_interception(craft, ufo)
    -- Start air combat
    local interception = {
        player_craft = craft,
        enemy_craft = ufo,
        round = 0,
        distance = 1000,
        state = "active"
    }
    
    craft.status = "combat"
    craft.current_combat = interception
    
    change_screen("interception", interception)
end
```

**Ground Assault Mission:**
```lua
function execute_ground_assault(craft, mission)
    -- Generate battle map if needed
    if not mission.map then
        mission.map = generate_mission_map(world, mission)
        generate_enemy_forces(mission)
    end
    
    craft.status = "landed"
    
    -- Deploy squad to battlescape
    local battle = initialize_battlescape(craft, mission)
    change_screen("battlescape", battle)
end
```

### Combat Damage

**Craft Damage:**
```lua
function apply_craft_damage(craft, damage)
    craft.health = math.max(0, craft.health - damage)
    
    if craft.health == 0 then
        on_craft_destroyed(craft)
    elseif craft.health < craft.max_health * 0.3 then
        craft.maintenance_required = true
        show_warning("Craft critically damaged!")
    end
end

function on_craft_destroyed(craft)
    craft.status = "destroyed"
    
    -- Kill all squad members
    for _, soldier in ipairs(craft.squad) do
        soldier.status = "kia"
        remove_soldier(craft.home_base, soldier)
    end
    
    -- Remove craft
    remove_craft(craft.home_base, craft)
    
    notify_player("Craft " .. craft.name .. " has been destroyed!")
end
```

**Weapon Depletion:**
```lua
function consume_weapon_ammo(craft, weapon_slot)
    local weapon_data = craft.weapons[weapon_slot]
    if weapon_data then
        weapon_data.ammo = weapon_data.ammo - 1
        
        if weapon_data.ammo <= 0 then
            show_warning("Weapon " .. weapon_data.weapon.name .. " out of ammo!")
        end
    end
end
```

### Mission Completion

**Victory:**
```lua
function on_mission_victory(craft, mission, rewards)
    craft.status = "returning"
    craft.destination = craft.home_base.location
    craft.mission = nil
    
    -- Collect loot
    for _, item in ipairs(rewards.items) do
        table.insert(craft.cargo, item)
    end
    
    -- Award experience to squad
    for _, soldier in ipairs(craft.squad) do
        award_experience(soldier, mission.difficulty)
    end
    
    notify_player("Mission successful! Returning to base.")
end
```

**Defeat/Retreat:**
```lua
function on_mission_failure(craft, mission)
    craft.status = "returning"
    craft.destination = craft.home_base.location
    craft.mission = nil
    
    -- Check for casualties
    local survivors = {}
    for _, soldier in ipairs(craft.squad) do
        if soldier.status ~= "kia" then
            table.insert(survivors, soldier)
        end
    end
    craft.squad = survivors
    
    notify_player("Mission failed. Returning to base.")
end
```

### Output

```lua
phase4_output = {
    mission_result = "victory" | "defeat" | "retreat",
    craft_health = health_remaining,
    ammo_remaining = {weapon1_ammo, weapon2_ammo},
    casualties = soldier_deaths,
    loot_collected = items_array
}
```

---

## Phase 5: Recovery

### Return Journey

**Automatic Return:**
```lua
function begin_craft_return(craft)
    craft.status = "returning"
    craft.destination = craft.home_base.location
    craft.mission = nil
    
    local distance = calculate_distance(craft.location, craft.home_base.location)
    local eta = world.current_time + (distance / craft.speed)
    
    log_event("Craft " .. craft.name .. " returning to base (ETA: " .. format_time(eta) .. ")")
end
```

**Emergency Return:**
```lua
function emergency_return(craft, reason)
    if craft.status == "mission" or craft.status == "en_route" then
        craft.status = "returning"
        craft.destination = craft.home_base.location
        craft.mission = nil
        
        show_alert("Emergency return: " .. reason)
    end
end

function emergency_landing(craft)
    craft.status = "crashed"
    craft.health = math.max(1, craft.health * 0.5)  -- Take 50% damage
    
    -- Random casualties
    local casualties = math.floor(#craft.squad * 0.3)  -- 30% casualty rate
    for i = 1, casualties do
        local soldier = craft.squad[math.random(#craft.squad)]
        soldier.status = "kia"
        remove_from_table(craft.squad, soldier)
    end
    
    show_alert("Craft " .. craft.name .. " has crash-landed!")
    
    -- Create recovery mission
    create_recovery_mission(craft)
end
```

### Base Arrival

**Landing Sequence:**
```lua
function on_craft_return(craft)
    craft.location = craft.home_base.location
    craft.status = "hangar"
    
    -- Unload cargo
    for _, item in ipairs(craft.cargo) do
        add_item(craft.home_base.inventory, item)
    end
    craft.cargo = {}
    
    -- Update soldier status
    for _, soldier in ipairs(craft.squad) do
        soldier.status = "available"
    end
    
    -- Check if maintenance needed
    if craft.maintenance_required or craft.health < craft.max_health or craft.fuel < craft.max_fuel then
        craft.status = "maintenance"
        schedule_maintenance(craft)
    end
    
    log_event("Craft " .. craft.name .. " has returned to base")
end
```

### Output

```lua
phase5_output = {
    craft_location = base.location,
    status = "hangar" | "maintenance",
    cargo_unloaded = items_count,
    fuel_remaining = fuel_percentage,
    health_remaining = health_percentage
}
```

---

## Phase 6: Maintenance

### Repair Operations

**Damage Repair:**
```lua
function repair_craft(craft, base, dt)
    if craft.health >= craft.max_health then
        return  -- Already at full health
    end
    
    -- Calculate repair rate
    local available_engineers = base.engineers - count_assigned_engineers(base)
    local repair_rate = available_engineers * 2  -- 2 HP per engineer per day
    
    -- Apply repairs
    local repair_amount = repair_rate * dt
    craft.health = math.min(craft.max_health, craft.health + repair_amount)
    
    if craft.health >= craft.max_health then
        notify_player("Craft " .. craft.name .. " repairs complete")
    end
end
```

**Refueling:**
```lua
function refuel_craft(craft, base)
    if craft.fuel >= craft.max_fuel then
        return  -- Already full
    end
    
    -- Check fuel availability
    local fuel_needed = craft.max_fuel - craft.fuel
    local fuel_available = base.inventory.fuel or 0
    
    if fuel_available >= fuel_needed then
        craft.fuel = craft.max_fuel
        base.inventory.fuel = fuel_available - fuel_needed
        log_event("Craft " .. craft.name .. " refueled")
    else
        -- Partial refuel
        craft.fuel = craft.fuel + fuel_available
        base.inventory.fuel = 0
        show_warning("Insufficient fuel for full refueling")
    end
end
```

**Rearming:**
```lua
function rearm_craft(craft, base)
    for slot, weapon_data in ipairs(craft.weapons) do
        if weapon_data and weapon_data.ammo < weapon_data.weapon.max_ammo then
            local ammo_needed = weapon_data.weapon.max_ammo - weapon_data.ammo
            local ammo_available = base.inventory[weapon_data.weapon.ammo_type] or 0
            
            if ammo_available >= ammo_needed then
                weapon_data.ammo = weapon_data.weapon.max_ammo
                weapon_data.operational_energy = 100
                base.inventory[weapon_data.weapon.ammo_type] = ammo_available - ammo_needed
            else
                -- Partial rearm
                weapon_data.ammo = weapon_data.ammo + ammo_available
                base.inventory[weapon_data.weapon.ammo_type] = 0
            end
        end
    end
end
```

### Maintenance Complete

**Ready for Operations:**
```lua
function complete_maintenance(craft)
    if craft.health >= craft.max_health and 
       craft.fuel >= craft.max_fuel * 0.9 then
        craft.status = "ready"
        craft.maintenance_required = false
        log_event("Craft " .. craft.name .. " ready for operations")
    end
end
```

### Decommissioning

**Scrap Craft:**
```lua
function decommission_craft(craft, base)
    -- Unassign squad
    unassign_squad(craft)
    
    -- Uninstall weapons
    for slot = 1, 2 do
        if craft.weapons[slot] then
            uninstall_weapon(craft, slot)
        end
    end
    
    -- Scrap value
    local scrap_value = craft.type.cost * 0.3  -- 30% of original cost
    local materials = {
        {item = "Alloy", quantity = 20},
        {item = "Electronics", quantity = 10}
    }
    
    -- Add to treasury and inventory
    base.treasury = base.treasury + scrap_value
    for _, material in ipairs(materials) do
        add_item(base.inventory, material.item, material.quantity)
    end
    
    -- Remove craft
    remove_craft(base, craft)
    
    notify_player("Craft " .. craft.name .. " decommissioned. Received $" .. scrap_value)
end
```

### Output

```lua
phase6_output = {
    repairs_complete = true,
    refueled = true,
    rearmed = true,
    status = "ready",
    ready_for_deployment = true
}
```

---

## Craft States

### State Machine

```
[HANGAR] ←──────────────────┐
    ↓                        │
[READY]                      │
    ↓                        │
[EN_ROUTE] → [MISSION] ──────┤
    ↓            ↓           │
[RETURNING] ← [COMBAT]       │
    ↓                        │
[MAINTENANCE] ───────────────┘
    ↓
[DECOMMISSIONED]
```

**State Definitions:**
```lua
craft_states = {
    "hangar",        -- At base, not equipped
    "ready",         -- At base, ready for deployment
    "en_route",      -- Traveling to mission
    "mission",       -- At mission site
    "combat",        -- In combat (interception or ground)
    "landed",        -- Landed for ground assault
    "patrol",        -- On patrol route
    "returning",     -- Returning to base
    "maintenance",   -- Being repaired/refueled
    "crashed",       -- Emergency landing
    "destroyed"      -- Destroyed in combat
}
```

---

## Cross-References

**Related Systems:**
- [Basescape](../basescape/README.md) - Base facilities and construction
- [Geoscape](../geoscape/README.md) - World map and travel
- [Interception](../interception/Air_Battle.md) - Air combat mechanics
- [Mission Lifecycle](Mission_Lifecycle.md) - Mission operations
- [Economy](../economy/README.md) - Construction costs and maintenance

**Implementation Files:**
- `src/crafts/craft_manager.lua` - Craft lifecycle management
- `src/basescape/hangar.lua` - Construction and assignment
- `src/geoscape/craft_movement.lua` - Travel mechanics
- `src/interception/combat.lua` - Air combat
- `src/crafts/maintenance.lua` - Repair and refuel systems

---

## Version History

- **v1.0 (2025-09-30):** Initial integration document defining complete craft lifecycle
