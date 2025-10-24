-- NameGenerator: Generate realistic names for entities
-- Creates human-readable names for units, items, crafts, facilities, etc.

local NameGenerator = {}

-- Name word banks
local nameBanks = {
  unit = {
    prefix = {"Rookie", "Elite", "Veteran", "Alpha", "Bravo", "Charlie"},
    base = {"Rifleman", "Sniper", "Support", "Medic", "Assaulter"},
    suffix = {"", " Type-A", " MkI", " Model 1", " v1"},
  },
  weapon = {
    prefix = {"Auto", "Heavy", "Light", "Plasma", "Laser", "Pulse", "Modular", "Advanced"},
    base = {"Rifle", "Pistol", "Cannon", "Launcher", "Sword", "Grenade", "Crossbow", "Rifle"},
    suffix = {"", " Mk1", " Mk2", " Type-A", " Type-B", " v2", " Enhanced"},
  },
  item = {
    prefix = {"Standard", "Reinforced", "Enhanced", "Heavy", "Light", "Combat", "Tactical"},
    base = {"Armor", "Suit", "Gear", "Equipment", "Pack", "Kit", "System"},
    suffix = {"", " Mk1", " Model A", " v1", " Enhanced"},
  },
  facility = {
    prefix = {"Advanced", "Basic", "Secure", "Underground", "Reinforced"},
    base = {"Laboratory", "Workshop", "Hangar", "Storage", "Barracks", "Command", "Power Plant"},
    suffix = {"", " Complex", " Wing", " Module"},
  },
  craft = {
    prefix = {"",  "Sky", "Storm", "Thunder", "Eclipse", "Phantom"},
    base = {"Ranger", "Fighter", "Transport", "Interceptor", "Scout", "Assault"},
    suffix = {"", " X", " II", " Pro", " Advanced"},
  },
  tech = {
    prefix = {"Advanced", "Plasma", "Laser", "Alien", "Exotic", "Experimental"},
    base = {"Technology", "Weaponry", "Engineering", "Sciences", "Tactics", "Defense"},
    suffix = {"", " I", " II", " III", " Alpha", " Beta", " Breakthrough"},
  },
  alien = {
    prefix = {"", ""},  -- Used for first part of alien name
    base = {"Sectoid", "Reaper", "Muton", "Viper", "Advent", "Codex", "Archon"},
    suffix = {"", " Warrior", " Elite", " Commander"},
  },
}

local consonants = {"x", "z", "k", "th", "v", "sh", "ch", "r", "n", "m", "s", "p", "t", "d", "b", "g", "l"}
local vowels = {"a", "e", "i", "o", "u"}

---Generate a random element from a table
local function randomElement(t)
  if #t == 0 then return "" end
  return t[math.random(1, #t)]
end

---Generate realistic name for entity type
---@param entityType string Type of entity (unit, weapon, item, facility, craft, tech, alien)
---@param seed number|nil Optional seed for reproducibility
---@return string name The generated name
function NameGenerator.generate(entityType, seed)
  if seed then
    math.randomseed(seed)
  end

  local bank = nameBanks[entityType] or nameBanks.item

  local prefix = randomElement(bank.prefix or {""})
  local base = randomElement(bank.base or {"Entity"})
  local suffix = randomElement(bank.suffix or {""})

  -- Remove extra spaces
  local name = (prefix .. " " .. base .. suffix):gsub(" +", " "):gsub("^ ", ""):gsub(" $", "")

  return name
end

---Generate alien species name
---@param seed number|nil Optional seed
---@return string name Alien species name
function NameGenerator.generateAlienName(seed)
  if seed then
    math.randomseed(seed)
  end

  -- Simple alien name generation
  local names = {
    "Sectoid", "Reaper", "Muton", "Viper", "Advent", "Codex", "Archon",
    "Ethereal", "Cyberdisc", "Sectopod", "Mectoid", "Floater", "Snakeman",
    "Chryssalid", "Silacoid", "Celatid", "Terrax", "Xylonn", "Zorthari"
  }

  return names[math.random(1, #names)]
end

---Generate location/region name
---@param seed number|nil Optional seed
---@return string name Location name
function NameGenerator.generateLocationName(seed)
  if seed then
    math.randomseed(seed)
  end

  local locations = {
    "North America", "South America", "Europe", "Africa", "Middle East",
    "Asia", "Oceania", "Antarctica", "Pacific Region", "Atlantic Zone",
    "Central Region", "Southern Zone", "Northern Territory", "Western Front",
    "Eastern Sector"
  }

  return locations[math.random(1, #locations)]
end

---Generate research tech name
---@param seed number|nil Optional seed
---@return string name Tech name
function NameGenerator.generateTechName(seed)
  if seed then
    math.randomseed(seed)
  end

  local techs = {
    "Plasma Technology", "Laser Technology", "Advanced Armor", "Modular Weapons",
    "Alien Metallurgy", "Psionic Theory", "Flight Enhancement", "Tactical Computing",
    "Neural Interface", "Energy Weapons", "Exotic Propulsion", "Advanced Ballistics"
  }

  return techs[math.random(1, #techs)]
end

---Generate a random ID-safe string
---@param prefix string Optional prefix
---@return string id ID-formatted name
function NameGenerator.generateId(prefix)
  prefix = prefix or ""

  -- Generate 3-5 syllables
  local syllables = {}
  for i = 1, math.random(3, 5) do
    local syllable = randomElement(consonants) .. randomElement(vowels)
    table.insert(syllables, syllable)
  end

  local id = table.concat(syllables, "")

  if prefix ~= "" then
    id = prefix .. "_" .. id
  end

  return id
end

return NameGenerator
