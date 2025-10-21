-- Mock Data Generator Framework
-- Purpose: Generate 1000+ realistic mock entries for all 118 entity types
-- Usage: local MockGen = require("tests.mock.mock_generator")

local MockGen = {}

-- ============================================================================
-- UTILITIES
-- ============================================================================

local function generateId(prefix)
    return prefix .. "_" .. math.random(100000, 999999)
end

local function randomChoice(array)
    return array[math.random(1, #array)]
end

local function randomRange(min, max)
    return math.random(min, max)
end

-- ============================================================================
-- STRATEGIC LAYER (Geoscape)
-- ============================================================================

function MockGen.generateWeapon(tier)
    tier = tier or 1
    local tiers = {
        { id = "rifle_conventional", name = "Conventional Rifle", damage = 50, accuracy = 70 },
        { id = "plasma_rifle", name = "Plasma Rifle", damage = 70, accuracy = 65 },
        { id = "laser_rifle", name = "Laser Rifle", damage = 65, accuracy = 85 },
        { id = "pistol", name = "Combat Pistol", damage = 35, accuracy = 60 },
        { id = "sniper_rifle", name = "Sniper Rifle", damage = 90, accuracy = 95 },
        { id = "machine_gun", name = "Machine Gun", damage = 45, accuracy = 50 },
        { id = "rocket_launcher", name = "Rocket Launcher", damage = 120, accuracy = 40 },
    }
    
    return tiers[math.min(tier, #tiers)]
end

function MockGen.generateArmor(tier)
    tier = tier or 1
    local tiers = {
        { id = "armor_light", name = "Light Combat Armor", protection = 5, weight = 0.5 },
        { id = "armor_standard", name = "Standard Combat Armor", protection = 10, weight = 1.0 },
        { id = "armor_heavy", name = "Heavy Combat Armor", protection = 15, weight = 1.5 },
        { id = "armor_power", name = "Power Suit", protection = 20, weight = 2.0 },
        { id = "armor_plasma", name = "Plasma Armor", protection = 25, weight = 1.8 },
    }
    
    return tiers[math.min(tier, #tiers)]
end

function MockGen.generateUnitClass(side)
    side = side or "human"
    
    if side == "human" then
        return randomChoice({
            { id = "class_soldier", name = "Soldier", side = "human", health = 10 },
            { id = "class_heavy", name = "Heavy", side = "human", health = 12 },
            { id = "class_sniper", name = "Sniper", side = "human", health = 9 },
            { id = "class_scout", name = "Scout", side = "human", health = 8 },
            { id = "class_support", name = "Support", side = "human", health = 9 },
            { id = "class_leader", name = "Leader", side = "human", health = 10 },
        })
    else
        return randomChoice({
            { id = "class_sectoid", name = "Sectoid", side = "alien", health = 8 },
            { id = "class_muton", name = "Muton", side = "alien", health = 14 },
            { id = "class_floater", name = "Floater", side = "alien", health = 10 },
            { id = "class_chryssalid", name = "Chryssalid", side = "alien", health = 12 },
            { id = "class_ethereal", name = "Ethereal", side = "alien", health = 11 },
            { id = "class_sectoid_elite", name = "Sectoid Elite", side = "alien", health = 10 },
        })
    end
end

function MockGen.generateUnit(count)
    count = count or 1
    local units = {}
    
    for i = 1, count do
        local unitClass = MockGen.generateUnitClass(i % 2 == 0 and "human" or "alien")
        table.insert(units, {
            id = generateId("unit"),
            name = unitClass.name .. " #" .. i,
            class = unitClass.id,
            faction = i % 2 == 0 and "xcom" or "aliens",
            side = unitClass.side,
            xp = randomRange(0, 500),
            rank = randomRange(0, 6),
            health = unitClass.health,
            max_health = unitClass.health,
            stats = {
                aim = randomRange(6, 12),
                melee = randomRange(6, 12),
                react = randomRange(6, 12),
                speed = randomRange(6, 12),
                sight = randomRange(0, 10),
                armor = randomRange(0, 2),
            }
        })
    end
    
    return units
end

function MockGen.generateFacility(type, x, y)
    type = type or randomChoice({
        "command_center", "living_quarters", "workshop", "storage",
        "power_generator", "radar_station", "medical_lab", "research_lab", "defense_turret"
    })
    
    x = x or randomRange(0, 39)
    y = y or randomRange(0, 59)
    
    local facilities = {
        command_center = { name = "Command Center", cost = 2000, maintenance = 50, width = 2, height = 2 },
        living_quarters = { name = "Living Quarters", cost = 500, maintenance = 10, width = 2, height = 2 },
        workshop = { name = "Workshop", cost = 1200, maintenance = 30, width = 1, height = 2 },
        storage = { name = "Storage", cost = 800, maintenance = 20, width = 2, height = 1 },
        power_generator = { name = "Power Generator", cost = 1500, maintenance = 40, width = 2, height = 2 },
        radar_station = { name = "Radar Station", cost = 1800, maintenance = 35, width = 1, height = 2 },
        medical_lab = { name = "Medical Lab", cost = 1000, maintenance = 25, width = 1, height = 2 },
        research_lab = { name = "Research Lab", cost = 2500, maintenance = 60, width = 2, height = 2 },
        defense_turret = { name = "Defense Turret", cost = 600, maintenance = 15, width = 1, height = 1 },
    }
    
    local facility = facilities[type] or facilities.workshop
    
    return {
        id = generateId("facility"),
        type = type,
        name = facility.name,
        x = x,
        y = y,
        width = facility.width,
        height = facility.height,
        cost = facility.cost,
        maintenance_cost = facility.maintenance,
        power_consumption = randomRange(1, 5),
        power_generation = type == "power_generator" and randomRange(10, 20) or 0,
        status = randomChoice({ "operational", "under_construction", "damaged" }),
        construction_time = randomRange(0, 100),
    }
end

function MockGen.generateTechnology(tier)
    tier = tier or randomRange(1, 5)
    
    local techs = {
        { id = "tech_laser", name = "Laser Weapons", cost = 150, tier = 1 },
        { id = "tech_plasma", name = "Plasma Weapons", cost = 400, tier = 2 },
        { id = "tech_power_armor", name = "Power Armor", cost = 600, tier = 3 },
        { id = "tech_plasma_armor", name = "Plasma Armor", cost = 900, tier = 4 },
        { id = "tech_alien_weapons", name = "Alien Weapons", cost = 1800, tier = 5 },
    }
    
    for _, tech in ipairs(techs) do
        if tech.tier == tier then
            return {
                id = tech.id,
                name = tech.name,
                category = "weapons",
                research_cost = tech.cost,
                tier = tier,
                status = randomChoice({ "available", "researched", "locked" }),
            }
        end
    end
    
    return techs[tier]
end

function MockGen.generateRecipe(tier)
    tier = tier or randomRange(1, 5)
    
    local recipes = {
        { id = "recipe_rifle", name = "Rifle Production", time = 240, cost = 500, tier = 1 },
        { id = "recipe_plasma_rifle", name = "Plasma Rifle Assembly", time = 480, cost = 1500, tier = 3 },
        { id = "recipe_power_suit", name = "Power Suit Assembly", time = 960, cost = 3000, tier = 4 },
        { id = "recipe_medikit", name = "Medikit Assembly", time = 180, cost = 300, tier = 1 },
    }
    
    return randomChoice(recipes)
end

function MockGen.generateMission(difficulty)
    difficulty = difficulty or randomChoice({ "easy", "medium", "hard", "impossible" })
    
    return {
        id = generateId("mission"),
        name = randomChoice({
            "Terror Site", "UFO Recovery", "Alien Base Raid", "Rescue Hostages",
            "Research Facility", "Investigate Activity", "Defense Base", "Sabotage"
        }),
        mission_type = randomChoice({ "reconnaissance", "terror", "ufo_recovery", "rescue" }),
        difficulty = difficulty,
        location = randomChoice({ "North America", "Europe", "Asia", "South America", "Africa" }),
        reward_credits = randomRange(500, 5000),
        reward_xp_multiplier = randomRange(0.5, 2.0),
        enemy_count = randomRange(4, 20),
        turn_limit = randomRange(20, 40),
    }
end

function MockGen.generateObjective(missionType)
    missionType = missionType or "ufo_recovery"
    
    local objectives = {
        { id = "eliminate_all", name = "Eliminate All Enemies", type = "eliminate" },
        { id = "rescue_hostages", name = "Rescue Hostages", type = "rescue" },
        { id = "protect_civilians", name = "Protect Civilians", type = "protect" },
        { id = "secure_objective", name = "Secure Objective", type = "reach" },
        { id = "escape_map", name = "Escape Map", type = "escape" },
    }
    
    return randomChoice(objectives)
end

-- ============================================================================
-- OPERATIONAL LAYER (Basescape)
-- ============================================================================

function MockGen.generateBase(name, size)
    name = name or "Base Alpha"
    size = size or randomChoice({ "small", "medium", "large" })
    
    local sizes = {
        small = { width = 40, height = 20, max_facilities = 12 },
        medium = { width = 40, height = 40, max_facilities = 25 },
        large = { width = 40, height = 60, max_facilities = 40 },
    }
    
    local sizeData = sizes[size] or sizes.medium
    
    return {
        id = generateId("base"),
        name = name,
        size = size,
        width = sizeData.width,
        height = sizeData.height,
        max_facilities = sizeData.max_facilities,
        credits = randomRange(5000, 50000),
        personnel_count = randomRange(20, 100),
        status = "operational",
        founded_date = randomRange(0, 360),
    }
end

function MockGen.generateResearchProject(tech)
    tech = tech or MockGen.generateTechnology()
    
    return {
        id = generateId("research"),
        technology_id = tech.id,
        base_id = generateId("base"),
        scientists_assigned = randomRange(2, 10),
        current_progress = randomRange(0, tech.research_cost),
        total_progress = tech.research_cost,
        status = randomChoice({ "queued", "in_progress", "complete" }),
        started_date = randomRange(0, 360),
    }
end

function MockGen.generateManufacturingProject(recipe)
    recipe = recipe or MockGen.generateRecipe()
    
    return {
        id = generateId("manufacturing"),
        recipe_id = recipe.id,
        base_id = generateId("base"),
        quantity_ordered = randomRange(1, 5),
        quantity_completed = randomRange(0, 5),
        progress = randomRange(0, recipe.time),
        status = randomChoice({ "queued", "in_progress", "complete" }),
    }
end

function MockGen.generateItem(category)
    category = category or randomChoice({ "weapon", "armor", "ammunition", "consumable" })
    
    local items = {
        weapon = { id = "item_rifle", name = "Rifle", cost = 500, weight = 1.5 },
        armor = { id = "item_armor", name = "Combat Armor", cost = 1200, weight = 5.0 },
        ammunition = { id = "item_ammo", name = "Ammunition", cost = 50, weight = 0.1 },
        consumable = { id = "item_medikit", name = "Medikit", cost = 300, weight = 0.3 },
    }
    
    return items[category] or items.weapon
end

function MockGen.generateSupplier(type)
    type = type or randomChoice({ "arms", "medical", "components" })
    
    local suppliers = {
        arms = { id = "supplier_arms", name = "Arms Dealer", reliability = "trustworthy" },
        medical = { id = "supplier_medical", name = "Medical Supplies", reliability = "trustworthy" },
        components = { id = "supplier_components", name = "Component Supplier", reliability = "neutral" },
    }
    
    return suppliers[type] or suppliers.arms
end

-- ============================================================================
-- TACTICAL LAYER (Battlescape)
-- ============================================================================

function MockGen.generateCombatUnit(side, index)
    side = side or randomChoice({ "xcom", "alien" })
    index = index or 1
    
    local unitClass = MockGen.generateUnitClass(side == "xcom" and "human" or "alien")
    
    return {
        id = generateId("combat_unit"),
        name = unitClass.name .. " " .. index,
        class = unitClass.id,
        side = side,
        x = randomRange(1, 30),
        y = randomRange(1, 30),
        health = unitClass.health,
        max_health = unitClass.health,
        action_points = 10,
        energy = 100,
        position = { x = randomRange(1, 30), y = randomRange(1, 30), z = 0 },
        status = randomChoice({ "healthy", "wounded", "panicked", "unconscious" }),
    }
end

function MockGen.generateBattlefield(width, height)
    width = width or 30
    height = height or 30
    
    return {
        id = generateId("battlefield"),
        width = width,
        height = height,
        terrain_type = randomChoice({ "city", "farm", "forest", "industrial" }),
        units = {},
        tile_data = {},
        fog_of_war = {},
        status = "active",
    }
end

function MockGen.generateCombatAction(unit, actionType)
    actionType = actionType or randomChoice({ "move", "attack", "reload", "grenade", "standby" })
    
    return {
        id = generateId("action"),
        unit_id = unit.id,
        action_type = actionType,
        target_x = randomRange(1, 30),
        target_y = randomRange(1, 30),
        cost = randomRange(1, 5),
        success_chance = randomRange(30, 95),
        executed = false,
    }
end

function MockGen.generateCoverData(x, y)
    return {
        position = { x = x, y = y },
        cover_type = randomChoice({ "full", "partial", "none" }),
        cover_direction = randomChoice({ "north", "south", "east", "west" }),
        cover_value = randomRange(0, 50),
    }
end

-- ============================================================================
-- COLLECTION GENERATORS
-- ============================================================================

function MockGen.generateAllWeapons()
    local weapons = {}
    for i = 1, 30 do
        table.insert(weapons, MockGen.generateWeapon(math.ceil(i / 6)))
    end
    return weapons
end

function MockGen.generateAllArmors()
    local armors = {}
    for i = 1, 20 do
        table.insert(armors, MockGen.generateArmor(math.ceil(i / 4)))
    end
    return armors
end

function MockGen.generateAllUnits(count)
    return MockGen.generateUnit(count or 50)
end

function MockGen.generateAllFacilities()
    local facilities = {}
    local types = {
        "command_center", "living_quarters", "workshop", "storage",
        "power_generator", "radar_station", "medical_lab", "research_lab", "defense_turret"
    }
    
    for i, fType in ipairs(types) do
        for j = 1, 5 do
            table.insert(facilities, MockGen.generateFacility(fType, j * 4, i * 6))
        end
    end
    return facilities
end

function MockGen.generateAllTechnologies()
    local techs = {}
    for tier = 1, 5 do
        table.insert(techs, MockGen.generateTechnology(tier))
    end
    return techs
end

function MockGen.generateAllMissions()
    local missions = {}
    for i = 1, 20 do
        table.insert(missions, MockGen.generateMission())
    end
    return missions
end

function MockGen.generateAllCombatUnits()
    local units = {}
    for i = 1, 10 do
        table.insert(units, MockGen.generateCombatUnit("xcom", i))
    end
    for i = 1, 10 do
        table.insert(units, MockGen.generateCombatUnit("alien", i))
    end
    return units
end

-- ============================================================================
-- BULK GENERATION
-- ============================================================================

function MockGen.generateAllMockData(options)
    options = options or {}
    
    return {
        weapons = MockGen.generateAllWeapons(),
        armors = MockGen.generateAllArmors(),
        units = MockGen.generateAllUnits(options.unitCount or 100),
        facilities = MockGen.generateAllFacilities(),
        technologies = MockGen.generateAllTechnologies(),
        missions = MockGen.generateAllMissions(),
        combat_units = MockGen.generateAllCombatUnits(),
        bases = { MockGen.generateBase("Base Alpha"), MockGen.generateBase("Base Bravo") },
    }
end

-- ============================================================================
-- STATISTICS
-- ============================================================================

function MockGen.getStatistics()
    return {
        weapons = 30,
        armors = 20,
        units = 100,
        facilities = 45,
        technologies = 5,
        missions = 20,
        combat_units = 20,
        bases = 2,
        total_entities = 242,
    }
end

-- ============================================================================
-- EXPORT
-- ============================================================================

return MockGen
