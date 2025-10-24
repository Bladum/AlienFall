--- Data Loader
--- Loads game data from TOML files through the ModManager.
---
--- This module provides access to all game configuration data including
--- terrain types, weapons, armours, units, facilities, missions, campaigns,
--- factions, technology, narrative events, geoscape, and economy data.
---
--- All data is loaded from TOML files in the active mod's content directory
--- and wrapped with utility functions for easy access.
---
--- Example usage:
---   local DataLoader = require("core.data_loader")
---   DataLoader.load()
---   local weapon = DataLoader.weapons.get("rifle")
---   local facility = DataLoader.facilities.get("command_center")
---   local faction = DataLoader.factions.get("faction_sectoids")
---
--- Loaded Data Tables (13 content types):
---   - terrainTypes: Terrain definitions (grass, wall, door, etc.)
---   - weapons: Weapon definitions with stats and damage
---   - armours: Armour definitions with protection values
---   - skills: Skill and ability definitions
---   - unitClasses: Unit class definitions (soldier, alien, etc.)
---   - units: Unit type definitions (soldiers, aliens, civilians)
---   - facilities: Base facility definitions
---   - missions: Mission type definitions
---   - campaigns: Campaign phase definitions
---   - factions: Faction definitions with units and tech trees
---   - technology: Technology research trees
---   - narrative: Narrative events and story content
---   - geoscape: World map and geoscape data
---   - economy: Economic system data

local TOML = require("utils.toml")
local ModManager = require("mods.mod_manager")

--- @class DataLoader
--- @field terrainTypes table Terrain type definitions and utility functions
--- @field weapons table Weapon definitions and utility functions
--- @field armours table Armour definitions with protection values
--- @field skills table Skill definitions with utility functions
--- @field unitClasses table Unit class definitions and utility functions
--- @field units table Unit type definitions with utility functions
--- @field facilities table Facility definitions with utility functions
--- @field missions table Mission definitions with utility functions
--- @field campaigns table Campaign definitions with utility functions
--- @field factions table Faction definitions with utility functions
--- @field technology table Technology tree definitions with utility functions
--- @field narrative table Narrative event definitions with utility functions
--- @field geoscape table Geoscape data with utility functions
--- @field economy table Economy data with utility functions
local DataLoader = {}

--- Helper: Build a file path with correct path separators for the platform.
--- Combines a directory path and filename(s) with consistent separators.
---
--- @param basePath string Base directory path
--- @param ... string One or more filename/subdirectory components
--- @return string Full path with consistent separators
local function buildPath(basePath, ...)
    -- Detect if we're on Windows (basePath contains backslashes)
    local isWindows = basePath:find("\\") ~= nil
    local separator = isWindows and "\\" or "/"

    local fullPath = basePath
    for i, component in ipairs({...}) do
        -- Normalize component separators to match platform
        component = component:gsub("/", separator):gsub("\\", separator)
        fullPath = fullPath .. separator .. component
    end
    return fullPath
end

--- Load all game data from TOML files.
---
--- Calls individual loader functions for all 13 content types.
--- Should be called once during game initialization.
--- Returns true on success.
---
--- @return boolean True if all data loaded successfully
function DataLoader.load()
    print("[DataLoader] Starting to load all game data...")

    DataLoader.terrainTypes = DataLoader.loadTerrainTypes()
    DataLoader.weapons = DataLoader.loadWeapons()
    DataLoader.armours = DataLoader.loadArmours()
    DataLoader.skills = DataLoader.loadSkills()
    DataLoader.perks = DataLoader.loadPerks()
    DataLoader.unitClasses = DataLoader.loadUnitClasses()
    DataLoader.units = DataLoader.loadUnits()
    DataLoader.facilities = DataLoader.loadFacilities()
    DataLoader.missions = DataLoader.loadMissions()
    DataLoader.campaigns = DataLoader.loadCampaigns()
    DataLoader.factions = DataLoader.loadFactions()
    DataLoader.technology = DataLoader.loadTechnology()
    DataLoader.narrative = DataLoader.loadNarrative()
    DataLoader.geoscape = DataLoader.loadGeoscape()
    DataLoader.economy = DataLoader.loadEconomy()

    print("[DataLoader] ✓ Successfully loaded all game data (14 content types)")
    return true
end

--- Load terrain type definitions from TOML file.
---
--- Loads terrain data from mods/*/content/rules/battle/terrain.toml.
--- Returns table with terrain data and utility functions:
---   - get(id): Get terrain by ID
---   - getAllIds(): Get array of all terrain IDs
---   - getByProperty(prop, val): Find terrains matching property
---   - blocksMovement(id): Check if terrain blocks movement
---   - blocksSight(id): Check if terrain blocks line of sight
---   - getMoveCost(id): Get movement cost (default 2)
---   - getSightCost(id): Get sight cost (default 1)
---
--- @return table Terrain types table with utility functions
function DataLoader.loadTerrainTypes()
    local path = ModManager.getContentPath("rules", "battle/terrain.toml")
    if not path then
        print("[DataLoader] ERROR: Could not get terrain types path from mod")
        return {}
    end

    print(string.format("[DataLoader] Loading terrain types from: %s", path))
    local data = TOML.load(path)
    if not data then
        print("[DataLoader] ERROR: Failed to load terrain types")
        return {}
    end

    -- Convert TOML structure to Lua table with functions
    local terrainTypes = {
        terrain = data.terrain or {}
    }

    -- Add utility functions
    function terrainTypes.get(terrainId)
        return terrainTypes.terrain[terrainId]
    end

    function terrainTypes.getAllIds()
        local ids = {}
        for id, _ in pairs(terrainTypes.terrain) do
            table.insert(ids, id)
        end
        return ids
    end

    function terrainTypes.getByProperty(property, value)
        local result = {}
        for id, terrain in pairs(terrainTypes.terrain) do
            if terrain[property] == value then
                table.insert(result, id)
            end
        end
        return result
    end

    function terrainTypes.blocksMovement(terrainId)
        local terrain = terrainTypes.get(terrainId)
        return terrain and terrain.blocksMovement
    end

    function terrainTypes.blocksSight(terrainId)
        local terrain = terrainTypes.get(terrainId)
        return terrain and terrain.blocksSight
    end

    function terrainTypes.getMoveCost(terrainId)
        local terrain = terrainTypes.get(terrainId)
        return terrain and terrain.moveCost or 2
    end

    function terrainTypes.getSightCost(terrainId)
        local terrain = terrainTypes.get(terrainId)
        return terrain and terrain.sightCost or 1
    end

    print(string.format("[DataLoader] ✓ Loaded %d terrain types", #terrainTypes.getAllIds()))
    return terrainTypes
end

--- Load weapon definitions from TOML file.
---
--- Loads weapon data from mods/*/content/rules/item/weapons.toml.
--- Returns table with weapon data and utility functions:
---   - get(id): Get weapon by ID
---   - getAllIds(): Get array of all weapon IDs
---   - getByType(type): Find weapons of specific type
---   - getForClass(classId): Get available weapons for unit class
---
--- @return table Weapons table with utility functions
function DataLoader.loadWeapons()
    local path = ModManager.getContentPath("rules", "items/weapons.toml")
    if not path then
        print("[DataLoader] ERROR: Could not get weapons path from mod")
        return {}
    end

    local data = TOML.load(path)
    if not data then
        print("[DataLoader] ERROR: Failed to load weapons")
        return {}
    end

    -- Convert TOML structure to Lua table with functions
    -- TOML uses [[weapon]] arrays which parse to data.weapon = {...}
    local weaponsArray = data.weapon or data.weapons or {}
    local weapons = {
        weapons = {}
    }

    -- Convert array to indexed table by ID
    for _, weapon in ipairs(weaponsArray) do
        if weapon.id then
            weapons.weapons[weapon.id] = weapon
        end
    end

    -- Add utility functions
    function weapons.get(weaponId)
        return weapons.weapons[weaponId]
    end

    function weapons.getAllIds()
        local ids = {}
        for id, _ in pairs(weapons.weapons) do
            table.insert(ids, id)
        end
        return ids
    end

    function weapons.getByType(weaponType)
        local result = {}
        for id, weapon in pairs(weapons.weapons) do
            if weapon.type == weaponType then
                table.insert(result, id)
            end
        end
        return result
    end

    function weapons.getForClass(classId)
        return weapons.getAllIds()
    end

    print(string.format("[DataLoader] ✓ Loaded %d weapons", #weapons.getAllIds()))
    return weapons
end

--- Load armour definitions from TOML file.
---
--- Loads armour data from mods/*/content/rules/item/armours.toml.
--- Returns table with armour data and utility functions:
---   - get(id): Get armour by ID
---   - getAllIds(): Get array of all armour IDs
---   - getByType(type): Find armours of specific type
---   - getForClass(classId): Get available armours for unit class
---
--- @return table Armours table with utility functions
function DataLoader.loadArmours()
    local path = ModManager.getContentPath("rules", "items/armours.toml")
    if not path then
        print("[DataLoader] ERROR: Could not get armours path from mod")
        return {}
    end

    local data = TOML.load(path)
    if not data then
        print("[DataLoader] ERROR: Failed to load armours")
        return {}
    end

    -- Convert TOML structure to Lua table with functions
    -- TOML uses [[armour]] arrays which parse to data.armour = {...}
    local armoursArray = data.armour or data.armours or {}
    local armours = {
        armours = {}
    }

    -- Convert array to indexed table by ID
    for _, armour in ipairs(armoursArray) do
        if armour.id then
            armours.armours[armour.id] = armour
        end
    end

    -- Add utility functions
    function armours.get(armourId)
        return armours.armours[armourId]
    end

    function armours.getAllIds()
        local ids = {}
        for id, _ in pairs(armours.armours) do
            table.insert(ids, id)
        end
        return ids
    end

    function armours.getByType(armourType)
        local result = {}
        for id, armour in pairs(armours.armours) do
            if armour.type == armourType then
                table.insert(result, id)
            end
        end
        return result
    end

    function armours.getForClass(classId)
        return armours.getAllIds()
    end

    print(string.format("[DataLoader] ✓ Loaded %d armours", #armours.getAllIds()))
    return armours
end

--- Load skill definitions from TOML file.
---
--- Loads skill data from mods/*/content/rules/item/skills.toml.
--- Returns table with skill data and utility functions:
---   - get(id): Get skill by ID
---   - getAllIds(): Get array of all skill IDs
---   - getByType(type): Find skills of specific type
---
--- @return table Skills table with utility functions
function DataLoader.loadSkills()
    local path = ModManager.getContentPath("rules", "items/skills.toml")
    if not path then
        print("[DataLoader] ERROR: Could not get skills path from mod")
        return {}
    end

    local data = TOML.load(path)
    if not data then
        print("[DataLoader] ERROR: Failed to load skills")
        return {}
    end

    -- Convert TOML structure to Lua table with functions
    -- TOML uses [[skill]] arrays which parse to data.skill = {...}
    local skillsArray = data.skill or data.skills or {}
    local skills = {
        skills = {}
    }

    -- Convert array to indexed table by ID
    for _, skill in ipairs(skillsArray) do
        if skill.id then
            skills.skills[skill.id] = skill
        end
    end

    function skills.get(skillId)
        return skills.skills[skillId]
    end

    function skills.getAllIds()
        local ids = {}
        for id, _ in pairs(skills.skills) do
            table.insert(ids, id)
        end
        return ids
    end

    function skills.getByType(skillType)
        local result = {}
        for id, skill in pairs(skills.skills) do
            if skill.type == skillType then
                table.insert(result, id)
            end
        end
        return result
    end

    print(string.format("[DataLoader] ✓ Loaded %d skills", #skills.getAllIds()))
    return skills
end

--- Load perk definitions from TOML file.
---
--- Loads perk data from mods/*/content/rules/unit/perks.toml.
--- Returns table with perk data and utility functions:
---   - get(id): Get perk by ID
---   - getAllIds(): Get array of all perk IDs
---   - getByCategory(category): Get perks in category
---
--- @return table Perks table with utility functions
function DataLoader.loadPerks()
    local path = ModManager.getContentPath("rules", "unit/perks.toml")
    if not path then
        print("[DataLoader] ERROR: Could not get perks path from mod")
        return {}
    end

    local data = TOML.load(path)
    if not data then
        print("[DataLoader] ERROR: Failed to load perks")
        return {}
    end

    -- Convert TOML structure to Lua table with functions
    -- TOML uses [[perks]] arrays which parse to data.perks = {...}
    local perksArray = data.perks or {}
    local perks = {
        perks = {}
    }

    -- Convert array to indexed table by ID
    for _, perk in ipairs(perksArray) do
        if perk.id then
            perks.perks[perk.id] = perk
        end
    end

    function perks.get(perkId)
        return perks.perks[perkId]
    end

    function perks.getAllIds()
        local ids = {}
        for id, _ in pairs(perks.perks) do
            table.insert(ids, id)
        end
        return ids
    end

    function perks.getByCategory(category)
        local result = {}
        for id, perk in pairs(perks.perks) do
            if perk.category == category then
                table.insert(result, id)
            end
        end
        return result
    end

    function perks.getAll()
        return perksArray
    end

    print(string.format("[DataLoader] ✓ Loaded %d perks", #perks.getAllIds()))
    return perks
end

--- Load unit class definitions from TOML file.
---
--- Loads unit class data from mods/*/content/rules/unit/classes.toml.
--- Returns table with unit class data and utility functions:
---   - get(id): Get unit class by ID
---   - getAllIds(): Get array of all class IDs
---   - getBySide(side): Get classes for side ("human", "alien", "civilian")
---
--- @return table Unit classes table with utility functions
function DataLoader.loadUnitClasses()
    local path = ModManager.getContentPath("rules", "unit/classes.toml")
    if not path then
        print("[DataLoader] ERROR: Could not get unit classes path from mod")
        return {}
    end

    local data = TOML.load(path)
    if not data then
        print("[DataLoader] ERROR: Failed to load unit classes")
        return {}
    end

    -- Convert array format [[unit_classes]] to indexed table by ID
    local classesArray = data.unit_classes or {}
    local classesById = {}

    for _, classData in ipairs(classesArray) do
        if classData.id then
            classesById[classData.id] = classData
        end
    end

    local unitClasses = {
        classes = classesById,
        raw = classesArray  -- Keep original array for iteration
    }

    function unitClasses.get(classId)
        return unitClasses.classes[classId]
    end

    function unitClasses.getAllIds()
        local ids = {}
        for id, _ in pairs(unitClasses.classes) do
            table.insert(ids, id)
        end
        return ids
    end

    function unitClasses.getAll()
        return unitClasses.raw or {}
    end

    function unitClasses.getBySide(side)
        local result = {}
        for _, class in ipairs(unitClasses.raw) do
            if class.type == side then
                table.insert(result, class.id)
            end
        end
        return result
    end

    print(string.format("[DataLoader] ✓ Loaded %d unit classes", #unitClasses.getAllIds()))
    return unitClasses
end

--- Load unit type definitions from TOML files.
---
--- Loads unit data from mods/*/content/rules/units/*.toml
--- (soldiers.toml, aliens.toml, civilians.toml, etc.)
--- Returns table with unit data and utility functions:
---   - get(id): Get unit by ID
---   - getAllIds(): Get array of all unit IDs
---   - getByFaction(factionId): Get units for faction
---   - getBySide(side): Get units for side ("human", "alien", "civilian")
---
--- @return table Units table with utility functions
function DataLoader.loadUnits()
    local path = ModManager.getContentPath("rules", "units")
    if not path then
        print("[DataLoader] ERROR: Could not get units path from mod")
        return {}
    end

    local units = {
        units = {}
    }

    -- Load all unit TOML files from units directory
    local unitFiles = {"soldiers.toml", "aliens.toml", "civilians.toml"}
    local totalLoaded = 0

    for _, filename in ipairs(unitFiles) do
        local fullPath = buildPath(path, filename)
        local data = TOML.load(fullPath)
        if data and data.unit then
            for _, unit in ipairs(data.unit) do
                if unit.id then
                    units.units[unit.id] = unit
                    totalLoaded = totalLoaded + 1
                end
            end
        end
    end

    function units.get(unitId)
        return units.units[unitId]
    end

    function units.getAllIds()
        local ids = {}
        for id, _ in pairs(units.units) do
            table.insert(ids, id)
        end
        return ids
    end

    function units.getByFaction(factionId)
        local result = {}
        for id, unit in pairs(units.units) do
            if unit.faction == factionId then
                table.insert(result, id)
            end
        end
        return result
    end

    function units.getBySide(side)
        local result = {}
        for id, unit in pairs(units.units) do
            if unit.side == side then
                table.insert(result, id)
            end
        end
        return result
    end

    print(string.format("[DataLoader] ✓ Loaded %d unit types", totalLoaded))
    return units
end

--- Load facility definitions from TOML files.
---
--- Loads facility data from mods/*/content/rules/facilities/*.toml
--- Returns table with facility data and utility functions:
---   - get(id): Get facility by ID
---   - getAllIds(): Get array of all facility IDs
---   - getByType(type): Find facilities of specific type
---
--- @return table Facilities table with utility functions
function DataLoader.loadFacilities()
    local path = ModManager.getContentPath("rules", "facilities")
    if not path then
        print("[DataLoader] ERROR: Could not get facilities path from mod")
        return {}
    end

    local facilities = {
        facilities = {}
    }

    -- Load all facility TOML files
    local facilityFiles = {"base_facilities.toml", "research_facilities.toml", "manufacturing.toml", "defense.toml"}
    local totalLoaded = 0

    for _, filename in ipairs(facilityFiles) do
        local fullPath = buildPath(path, filename)
        local data = TOML.load(fullPath)
        if data and data.facility then
            for _, facility in ipairs(data.facility) do
                if facility.id then
                    facilities.facilities[facility.id] = facility
                    totalLoaded = totalLoaded + 1
                end
            end
        end
    end

    function facilities.get(facilityId)
        return facilities.facilities[facilityId]
    end

    function facilities.getAllIds()
        local ids = {}
        for id, _ in pairs(facilities.facilities) do
            table.insert(ids, id)
        end
        return ids
    end

    function facilities.getByType(facilityType)
        local result = {}
        for id, facility in pairs(facilities.facilities) do
            if facility.type == facilityType then
                table.insert(result, id)
            end
        end
        return result
    end

    print(string.format("[DataLoader] ✓ Loaded %d facilities", totalLoaded))
    return facilities
end

--- Load mission definitions from TOML files.
---
--- Loads mission data from mods/*/content/rules/missions/*.toml
--- Returns table with mission data and utility functions:
---   - get(id): Get mission by ID
---   - getAllIds(): Get array of all mission IDs
---   - getByType(type): Find missions of specific type
---   - getByPhase(phase): Get missions available in phase
---
--- @return table Missions table with utility functions
function DataLoader.loadMissions()
    local path = ModManager.getContentPath("rules", "missions")
    if not path then
        print("[DataLoader] ERROR: Could not get missions path from mod")
        return {}
    end

    local missions = {
        missions = {}
    }

    -- Load all mission TOML files
    local missionFiles = {"tactical_missions.toml", "strategic_missions.toml"}
    local totalLoaded = 0

    for _, filename in ipairs(missionFiles) do
        local fullPath = buildPath(path, filename)
        local data = TOML.load(fullPath)
        if data and data.mission then
            for _, mission in ipairs(data.mission) do
                if mission.id then
                    missions.missions[mission.id] = mission
                    totalLoaded = totalLoaded + 1
                end
            end
        end
    end

    function missions.get(missionId)
        return missions.missions[missionId]
    end

    function missions.getAllIds()
        local ids = {}
        for id, _ in pairs(missions.missions) do
            table.insert(ids, id)
        end
        return ids
    end

    function missions.getByType(missionType)
        local result = {}
        for id, mission in pairs(missions.missions) do
            if mission.type == missionType then
                table.insert(result, id)
            end
        end
        return result
    end

    print(string.format("[DataLoader] ✓ Loaded %d missions", totalLoaded))
    return missions
end

--- Load campaign definitions from TOML files.
---
--- Loads campaign data from mods/*/content/campaigns/*.toml
--- Returns table with campaign data and utility functions:
---   - get(id): Get campaign by ID
---   - getAllIds(): Get array of all campaign IDs
---   - getTimeline(): Get campaign timeline
---
--- @return table Campaigns table with utility functions
function DataLoader.loadCampaigns()
    local path = ModManager.getContentPath("campaigns")
    if not path then
        print("[DataLoader] ERROR: Could not get campaigns path from mod")
        return {}
    end

    local campaigns = {
        campaigns = {},
        timeline = {}
    }

    -- Load campaign timeline
    local timelinePath = path .. "/campaign_timeline.toml"
    local timelineData = TOML.load(timelinePath)
    if timelineData then
        campaigns.timeline = timelineData.milestone or {}
    end

    -- Load campaign phase definitions
    local campaignFiles = {
        "phase0_shadow_war.toml",
        "phase1_sky_war.toml",
        "phase2_deep_war.toml",
        "phase3_dimensional_war.toml"
    }
    local totalLoaded = 0

    for _, filename in ipairs(campaignFiles) do
        local fullPath = path .. "/" .. filename
        local data = TOML.load(fullPath)
        if data and data.phase then
            campaigns.campaigns[data.phase.id] = data.phase
            totalLoaded = totalLoaded + 1
        end
    end

    function campaigns.get(campaignId)
        return campaigns.campaigns[campaignId]
    end

    function campaigns.getAllIds()
        local ids = {}
        for id, _ in pairs(campaigns.campaigns) do
            table.insert(ids, id)
        end
        return ids
    end

    function campaigns.getTimeline()
        return campaigns.timeline
    end

    print(string.format("[DataLoader] ✓ Loaded %d campaign phases + timeline", totalLoaded))
    return campaigns
end

--- Load faction definitions from TOML files.
---
--- Loads faction data from mods/*/content/factions/*.toml
--- Returns table with faction data and utility functions:
---   - get(id): Get faction by ID
---   - getAllIds(): Get array of all faction IDs
---   - getByType(type): Find factions of specific type ("alien", "human")
---   - getUnits(factionId): Get unit types for faction
---
--- @return table Factions table with utility functions
function DataLoader.loadFactions()
    local path = ModManager.getContentPath("factions")
    if not path then
        print("[DataLoader] ERROR: Could not get factions path from mod")
        return {}
    end

    local factions = {
        factions = {}
    }

    -- Load all faction TOML files
    local factionFiles = {
        "faction_sectoids.toml",
        "faction_mutons.toml",
        "faction_ethereals.toml"
    }
    local totalLoaded = 0

    for _, filename in ipairs(factionFiles) do
        local fullPath = path .. "/" .. filename
        local data = TOML.load(fullPath)
        if data and data.faction then
            factions.factions[data.faction.id] = data.faction
            totalLoaded = totalLoaded + 1
        end
    end

    function factions.get(factionId)
        return factions.factions[factionId]
    end

    function factions.getAllIds()
        local ids = {}
        for id, _ in pairs(factions.factions) do
            table.insert(ids, id)
        end
        return ids
    end

    function factions.getByType(factionType)
        local result = {}
        for id, faction in pairs(factions.factions) do
            if faction.type == factionType then
                table.insert(result, id)
            end
        end
        return result
    end

    function factions.getUnits(factionId)
        local faction = factions.get(factionId)
        if faction and faction.units then
            return faction.units
        end
        return {}
    end

    print(string.format("[DataLoader] ✓ Loaded %d factions", totalLoaded))
    return factions
end

--- Load technology tree definitions from TOML files.
---
--- Loads technology data from mods/*/content/technology/*.toml
--- Returns table with technology data and utility functions:
---   - get(id): Get tech by ID
---   - getAllIds(): Get array of all tech IDs
---
--- @return table Technology table with utility functions
function DataLoader.loadTechnology()
    local path = ModManager.getContentPath("technology")
    if not path then
        print("[DataLoader] ERROR: Could not get technology path from mod")
        return {}
    end

    local technology = {
        techs = {}
    }

    -- Technology will be loaded from files when they exist
    -- For now, return empty with utility functions

    function technology.get(techId)
        return technology.techs[techId]
    end

    function technology.getAllIds()
        local ids = {}
        for id, _ in pairs(technology.techs) do
            table.insert(ids, id)
        end
        return ids
    end

    print("[DataLoader] ✓ Loaded technology trees (placeholder)")
    return technology
end

--- Load narrative event definitions from TOML files.
---
--- Loads narrative data from mods/*/content/narrative/*.toml
--- Returns table with narrative data and utility functions:
---   - get(id): Get event by ID
---   - getAllIds(): Get array of all event IDs
---
--- @return table Narrative table with utility functions
function DataLoader.loadNarrative()
    local path = ModManager.getContentPath("narrative")
    if not path then
        print("[DataLoader] ERROR: Could not get narrative path from mod")
        return {}
    end

    local narrative = {
        events = {}
    }

    -- Narrative will be loaded from files when they exist
    -- For now, return empty with utility functions

    function narrative.get(eventId)
        return narrative.events[eventId]
    end

    function narrative.getAllIds()
        local ids = {}
        for id, _ in pairs(narrative.events) do
            table.insert(ids, id)
        end
        return ids
    end

    print("[DataLoader] ✓ Loaded narrative events (placeholder)")
    return narrative
end

--- Load geoscape data from TOML files.
---
--- Loads geoscape data from mods/*/content/geoscape/*.toml
--- Returns table with geoscape data and utility functions:
---   - getCountries(): Get all countries
---   - getRegions(): Get all regions
---
--- @return table Geoscape table with utility functions
function DataLoader.loadGeoscape()
    local path = ModManager.getContentPath("geoscape")
    if not path then
        print("[DataLoader] ERROR: Could not get geoscape path from mod")
        return {}
    end

    local geoscape = {
        countries = {},
        regions = {}
    }

    -- Geoscape will be loaded from files when they exist
    -- For now, return empty with utility functions

    function geoscape.getCountries()
        return geoscape.countries
    end

    function geoscape.getRegions()
        return geoscape.regions
    end

    print("[DataLoader] ✓ Loaded geoscape data (placeholder)")
    return geoscape
end

--- Load economy data from TOML files.
---
--- Loads economy data from mods/*/content/economy/*.toml
--- Returns table with economy data and utility functions:
---   - getMarketplace(): Get marketplace items
---   - getFunding(): Get funding sources
---
--- @return table Economy table with utility functions
function DataLoader.loadEconomy()
    local path = ModManager.getContentPath("economy")
    if not path then
        print("[DataLoader] ERROR: Could not get economy path from mod")
        return {}
    end

    local economy = {
        marketplace = {},
        funding = {}
    }

    -- Economy will be loaded from files when they exist
    -- For now, return empty with utility functions

    function economy.getMarketplace()
        return economy.marketplace
    end

    function economy.getFunding()
        return economy.funding
    end

    print("[DataLoader] ✓ Loaded economy data (placeholder)")
    return economy
end

--- Load and parse a TOML file.
---
--- @param filepath string Path to the TOML file
--- @return table|nil Parsed TOML data or nil on error
function DataLoader.loadTOML(filepath)
    if not filepath then
        print("[DataLoader] ERROR: No filepath provided to loadTOML")
        return nil
    end

    local success, data = pcall(TOML.load, filepath)
    if not success then
        print(string.format("[DataLoader] ERROR: Failed to load TOML file '%s': %s", filepath, tostring(data)))
        return nil
    end

    return data
end

--- Validate TOML parsing result.
---
--- @param data table|nil The parsed TOML data
--- @param expectedKeys table|nil Array of expected top-level keys
--- @return boolean True if valid
function DataLoader.validateTOML(data, expectedKeys)
    if not data then
        return false
    end

    if expectedKeys then
        for _, key in ipairs(expectedKeys) do
            if not data[key] then
                print(string.format("[DataLoader] ERROR: Missing expected key '%s' in TOML data", key))
                return false
            end
        end
    end

    return true
end

return DataLoader
