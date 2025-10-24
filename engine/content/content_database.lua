-- Content Database System
-- Central storage for all game content: factions, missions, events, tech trees

local ContentDatabase = {}

-- Database storage
local database = {
    factions = {},
    missions = {},
    events = {},
    techTrees = {},
    metadata = {
        version = "2.0",
        lastUpdated = os.date("%Y-%m-%d %H:%M:%S")
    }
}

---Register a faction
function ContentDatabase.registerFaction(id, faction)
    if database.factions[id] then
        print("[Warning] Faction already exists: " .. id)
    end

    -- Validate faction structure
    if not faction.name or not faction.units or not faction.tech_tree then
        error("Invalid faction structure for: " .. id)
    end

    database.factions[id] = faction
    print("[ContentDB] Registered faction: " .. id)
end

---Get faction by ID
function ContentDatabase.getFaction(id)
    return database.factions[id]
end

---Get all factions
function ContentDatabase.getAllFactions()
    return database.factions
end

---Register a mission template
function ContentDatabase.registerMission(id, mission)
    if database.missions[id] then
        print("[Warning] Mission already exists: " .. id)
    end

    -- Validate mission structure
    if not mission.name or not mission.objectives or not mission.difficulty then
        error("Invalid mission structure for: " .. id)
    end

    database.missions[id] = mission
    print("[ContentDB] Registered mission: " .. id)
end

---Get mission by ID
function ContentDatabase.getMission(id)
    return database.missions[id]
end

---Get all missions
function ContentDatabase.getAllMissions()
    return database.missions
end

---Get missions by difficulty
function ContentDatabase.getMissionsByDifficulty(difficulty)
    local result = {}
    for id, mission in pairs(database.missions) do
        if mission.difficulty == difficulty then
            table.insert(result, mission)
        end
    end
    return result
end

---Register a campaign event
function ContentDatabase.registerEvent(id, event)
    if database.events[id] then
        print("[Warning] Event already exists: " .. id)
    end

    -- Validate event structure
    if not event.name or not event.type or not event.effects then
        error("Invalid event structure for: " .. id)
    end

    database.events[id] = event
    print("[ContentDB] Registered event: " .. id)
end

---Get event by ID
function ContentDatabase.getEvent(id)
    return database.events[id]
end

---Get all events
function ContentDatabase.getAllEvents()
    return database.events
end

---Get events by type
function ContentDatabase.getEventsByType(eventType)
    local result = {}
    for id, event in pairs(database.events) do
        if event.type == eventType then
            table.insert(result, event)
        end
    end
    return result
end

---Register a tech tree
function ContentDatabase.registerTechTree(id, techTree)
    if database.techTrees[id] then
        print("[Warning] Tech tree already exists: " .. id)
    end

    database.techTrees[id] = techTree
    print("[ContentDB] Registered tech tree: " .. id)
end

---Get tech tree by ID
function ContentDatabase.getTechTree(id)
    return database.techTrees[id]
end

---Get all tech trees
function ContentDatabase.getAllTechTrees()
    return database.techTrees
end

---Get random faction
function ContentDatabase.getRandomFaction()
    local factions = {}
    for id, faction in pairs(database.factions) do
        table.insert(factions, faction)
    end

    if #factions == 0 then
        return nil
    end

    return factions[math.random(1, #factions)]
end

---Get random mission
function ContentDatabase.getRandomMission()
    local missions = {}
    for id, mission in pairs(database.missions) do
        table.insert(missions, mission)
    end

    if #missions == 0 then
        return nil
    end

    return missions[math.random(1, #missions)]
end

---Get random event
function ContentDatabase.getRandomEvent(eventType)
    local events = {}

    if eventType then
        events = ContentDatabase.getEventsByType(eventType)
    else
        for id, event in pairs(database.events) do
            table.insert(events, event)
        end
    end

    if #events == 0 then
        return nil
    end

    return events[math.random(1, #events)]
end

---Load content from files
function ContentDatabase.loadContent(contentDirectory)
    print("[ContentDB] Loading content from: " .. contentDirectory)

    local function loadDir(dir, category)
        local success, items = pcall(love.filesystem.getDirectoryItems, dir)
        if not success then
            print("[ContentDB] Could not read: " .. dir)
            return
        end

        for _, item in ipairs(items) do
            if item:match("%.lua$") then
                local modulePath = contentDirectory:gsub("/", ".") .. "." .. category .. "." .. item:sub(1, -5)
                local success, content = pcall(require, modulePath)

                if success and content then
                    -- Register based on category
                    if category == "factions" then
                        for id, faction in pairs(content) do
                            ContentDatabase.registerFaction(id, faction)
                        end
                    elseif category == "missions" then
                        for id, mission in pairs(content) do
                            ContentDatabase.registerMission(id, mission)
                        end
                    elseif category == "events" then
                        for id, event in pairs(content) do
                            ContentDatabase.registerEvent(id, event)
                        end
                    elseif category == "tech_trees" then
                        for id, tree in pairs(content) do
                            ContentDatabase.registerTechTree(id, tree)
                        end
                    end
                else
                    print("[ContentDB] Failed to load: " .. modulePath)
                end
            end
        end
    end

    -- Load each category
    loadDir(contentDirectory .. "/factions", "factions")
    loadDir(contentDirectory .. "/missions", "missions")
    loadDir(contentDirectory .. "/events", "events")
    loadDir(contentDirectory .. "/tech_trees", "tech_trees")

    print("[ContentDB] Content loading complete")
end

---Get database statistics
function ContentDatabase.getStats()
    return {
        factions = table.countKeys(database.factions),
        missions = table.countKeys(database.missions),
        events = table.countKeys(database.events),
        techTrees = table.countKeys(database.techTrees)
    }
end

---Print database statistics
function ContentDatabase.printStats()
    local stats = ContentDatabase.getStats()

    print("\n" .. string.rep("=", 60))
    print("CONTENT DATABASE STATISTICS")
    print(string.rep("=", 60))
    print("Factions:    " .. stats.factions)
    print("Missions:    " .. stats.missions)
    print("Events:      " .. stats.events)
    print("Tech Trees:  " .. stats.techTrees)
    print(string.rep("=", 60) .. "\n")
end

---Export database to JSON (simplified)
function ContentDatabase.exportJSON()
    -- Simple JSON export
    local json = {
        factions = table.countKeys(database.factions),
        missions = table.countKeys(database.missions),
        events = table.countKeys(database.events),
        techTrees = table.countKeys(database.techTrees),
        version = database.metadata.version
    }

    return json
end

---Clear database
function ContentDatabase.clear()
    database = {
        factions = {},
        missions = {},
        events = {},
        techTrees = {},
        metadata = {
            version = "2.0",
            lastUpdated = os.date("%Y-%m-%d %H:%M:%S")
        }
    }
end

-- Helper to count table keys
function table.countKeys(tbl)
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    return count
end

return ContentDatabase
