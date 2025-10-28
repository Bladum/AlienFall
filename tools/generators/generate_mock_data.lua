#!/usr/bin/env lua
-- generate_mock_data.lua - Main mock data generator script
-- Generates synthetic mod content based on GAME_API.toml
--
-- Usage: lovec tools/generators/generate_mock_data.lua [options]
--
-- Options:
--   --output <path>    Output directory for generated mod (default: mods/synth_mod)
--   --strategy <name>  Generation strategy: minimal, coverage, stress, realistic (default: realistic)
--   --seed <num>       Random seed for reproducibility
--   --schema <path>    Path to GAME_API.toml
--   --categories <list> Comma-separated categories to generate
--   --count <num>      Entity count multiplier for stress testing

-- Setup paths
if love then
  package.path = love.filesystem.getWorkingDirectory() .. "/tools/generators/lib/?.lua;" .. package.path
else
  package.path = "./tools/generators/lib/?.lua;" .. package.path
end

-- Load libraries
local SchemaLoader = require("schema_loader") or {}
local NameGenerator = require("name_generator")
local IDGenerator = require("id_generator")
local DataGenerator = require("data_generator")
local TOMLWriter = require("toml_writer")

-- Dummy SchemaLoader if not available (will use hardcoded schema info)
if not SchemaLoader.load then
  SchemaLoader = {
    load = function() return {} end,
    getDefinition = function() return {} end,
    getRequiredFields = function() return {} end,
    getAllFieldNames = function() return {} end,
  }
end

---Parse command-line arguments
local function parseArgs(arg)
  local args = {
    output = "mods/synth_mod",
    strategy = "realistic",
    seed = nil,
    schema = "api/GAME_API.toml",
    categories = nil,
    count = 1,
  }

  for i, v in ipairs(arg) do
    if v == "--output" and arg[i + 1] then
      args.output = arg[i + 1]
    elseif v == "--strategy" and arg[i + 1] then
      args.strategy = arg[i + 1]
    elseif v == "--seed" and arg[i + 1] then
      args.seed = tonumber(arg[i + 1])
    elseif v == "--schema" and arg[i + 1] then
      args.schema = arg[i + 1]
    elseif v == "--categories" and arg[i + 1] then
      args.categories = arg[i + 1]:split(",")
    elseif v == "--count" and arg[i + 1] then
      args.count = tonumber(arg[i + 1]) or 1
    end
  end

  return args
end

---Determine how many entities to generate for each type
local function getEntityCount(category, strategy, countMultiplier)
  local baseCounts = {
    units = 3,
    items = 5,
    weapons = 3,
    armor = 3,
    crafts = 2,
    facilities = 4,
    research = 5,
    manufacturing = 3,
    missions = 3,
    aliens = 2,
    geoscape = 3,
    economy = 2,
    lore = 4,
  }

  local baseCount = baseCounts[category] or 2

  if strategy == "minimal" then
    return 1
  elseif strategy == "coverage" then
    return baseCount
  elseif strategy == "stress" then
    return baseCount * 10 * countMultiplier
  else  -- realistic
    return baseCount * countMultiplier
  end
end

---Generate basic unit entity
local function generateUnit(index, strategy)
  IDGenerator.init()

  local unitId = "unit_" .. index
  local unitName = NameGenerator.generate("unit")

  return {
    id = unitId,
    name = unitName,
    unit_type = "soldier",
    hp_base = 65 + math.random(-5, 5),
    accuracy_base = 70 + math.random(-10, 10),
    strength_base = 10 + math.random(-2, 2),
    reaction_base = 70 + math.random(-10, 10),
    fire_rate_base = 0.8 + (math.random() * 0.4),
    armor_class = 8 + math.random(0, 4),
    xp_to_level_up = 100,
    promotion_requirement = 500,
  }
end

---Generate basic item entity
local function generateItem(index, strategy)
  local itemId = "item_" .. index
  local itemName = NameGenerator.generate("item")

  return {
    id = itemId,
    name = itemName,
    type = "weapon",
    category = "primary_weapon",
    rarity = "common",
    tier = 1 + math.random(0, 3),
    weight = 1.0 + math.random() * 5.0,
    bulk = math.random(1, 3),
    durability = 100,
    value = 100 + (index * 50),
    max_stack_size = 1,
    is_stackable = false,
    is_consumable = false,
  }
end

---Generate weapon entity
local function generateWeapon(index, strategy)
  local weaponId = "weapon_" .. index
  local weaponName = NameGenerator.generate("weapon")

  return {
    id = weaponId,
    name = weaponName,
    type = "weapon",
    damage = 20 + (index * 5),
    accuracy = 70 + math.random(-10, 10),
    range = 15 + math.random(-5, 5),
    fire_rate = 0.8 + (math.random() * 0.4),
    ap_cost = 2 + math.random(0, 2),
    crit_chance = 0.05 + (math.random() * 0.15),
    damage_type = "kinetic",
    cost = 500 + (index * 200),
  }
end

---Generate facility entity
local function generateFacility(index, strategy)
  local facilityId = "facility_" .. index
  local facilityName = NameGenerator.generate("facility")

  return {
    id = facilityId,
    name = facilityName,
    type = "manufacturing",
    width = 2,
    height = 2,
    cost = 1500 + (index * 500),
    time_to_build = 10 + math.random(0, 10),
    maintenance_cost = 30 + index,
    production_rate = 1.0 + (math.random() * 0.5),
    power_consumption = 10 + math.random(0, 5),
  }
end

---Generate craft entity
local function generateCraft(index, strategy)
  local craftId = "craft_" .. index
  local craftName = NameGenerator.generate("craft")

  return {
    id = craftId,
    name = craftName,
    type = "transport",
    crew_capacity = 12 + math.random(-2, 2),
    speed = 8 + math.random(-1, 1),
    fuel_capacity = 2000 + (index * 500),
    fuel_consumption = 1.0,
    range = 4000 + (index * 1000),
    hp_max = 200 + (index * 50),
    armor_class = 5 + math.random(0, 5),
    armor_rating = 10 + math.random(-2, 2),
    weapon_slots = 2,
    cost = 50000 + (index * 10000),
  }
end

---Generate research entity
local function generateResearch(index, strategy)
  local techId = "tech_" .. index
  local techName = NameGenerator.generateTechName()

  return {
    id = techId,
    name = techName,
    category = "weapons",
    cost = 1000 + (index * 500),
    time = 20 + math.random(0, 20),
  }
end

---Generate mission entity
local function generateMission(index, strategy)
  local missionId = "mission_" .. index
  local missionName = "Mission " .. index

  return {
    id = missionId,
    name = missionName,
    category = "terror",
    reward_money = 5000 + (index * 1000),
    reward_xp = 200 + (index * 50),
    difficulty = 1 + math.random(0, 9),
  }
end

---Generate alien entity
local function generateAlien(index, strategy)
  local alienId = "alien_" .. index
  local alienName = NameGenerator.generateAlienName()

  return {
    id = alienId,
    name = alienName,
    strength_base = 10 + math.random(-2, 2),
    intelligence_base = 12 + math.random(-2, 2),
    armor_natural = 10 + math.random(0, 10),
  }
end

---Generate basic mock data for all categories
local function generateAllData(strategy, countMultiplier)
  local data = {}

  local generators = {
    units = { generateUnit, getEntityCount("units", strategy, countMultiplier) },
    items = { generateItem, getEntityCount("items", strategy, countMultiplier) },
    weapons = { generateWeapon, getEntityCount("weapons", strategy, countMultiplier) },
    crafts = { generateCraft, getEntityCount("crafts", strategy, countMultiplier) },
    facilities = { generateFacility, getEntityCount("facilities", strategy, countMultiplier) },
    research = { generateResearch, getEntityCount("research", strategy, countMultiplier) },
    missions = { generateMission, getEntityCount("missions", strategy, countMultiplier) },
    aliens = { generateAlien, getEntityCount("aliens", strategy, countMultiplier) },
  }

  for category, genInfo in pairs(generators) do
    local generator = genInfo[1]
    local count = genInfo[2]
    data[category] = {}
    for i = 1, count do
      table.insert(data[category], generator(i, strategy))
    end
  end

  return data
end

---Main generation function
local function main()
  local args = parseArgs(arg)

  print("")
  print("AlienFall Mock Data Generator v1.0")
  print("===================================")
  print("")

  -- Set random seed if provided
  if args.seed then
    math.randomseed(args.seed)
    print("Seed: " .. args.seed)
  end

  print("Strategy: " .. args.strategy)
  print("Output: " .. args.output)
  print("")

  -- Initialize ID generator
  IDGenerator.init()

  -- Generate data
  print("Generating mock data...")
  local data = generateAllData(args.strategy, args.count)

  -- Write files
  print("Writing TOML files...")

  local totalFiles = 0
  for category, entities in pairs(data) do
    if not args.categories or inTable(args.categories, category) then
      local outputDir = args.output .. "/rules/" .. category
      local outputFile = outputDir .. "/" .. category .. ".toml"

      local success = TOMLWriter.write(entities, category, outputFile)
      if success then
        totalFiles = totalFiles + 1
      end
    end
  end

  print("")
  print("Generation complete!")
  print("Generated " .. totalFiles .. " TOML files")
  print("Output directory: " .. args.output)
  print("")

  return 0
end

-- Utility function
function inTable(table_list, value)
  if not table_list then return true end
  for _, v in ipairs(table_list) do
    if v == value then return true end
  end
  return false
end

-- Run
local exitCode = main()
os.exit(exitCode or 0)
