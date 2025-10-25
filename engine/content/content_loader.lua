-- Content Loader
-- Loads game content from the content directory

local ContentLoader = {}

print("[ContentLoader] Initializing...")

-- Load faction content
function ContentLoader.loadFactions()
  print("[ContentLoader] Loading factions...")
  local factions = {}

  local function load_faction(file_name)
    local ok, faction = pcall(function()
      return require("engine.content.factions." .. file_name:gsub("%.lua", ""))
    end)

    if ok and faction then
      print("[ContentLoader] ✓ Loaded faction: " .. (faction.name or file_name))
      return faction
    else
      print("[ContentLoader] ✗ Failed to load faction: " .. file_name)
      return nil
    end
  end

  -- Try to load faction files
  local faction_files = love.filesystem.getDirectoryItems("engine/content/factions")
  for _, file in ipairs(faction_files) do
    if file:match("%.lua$") and file ~= "README.md" then
      local faction = load_faction(file)
      if faction and faction.id then
        factions[faction.id] = faction
      end
    end
  end

  print("[ContentLoader] Loaded " .. table.count(factions) .. " factions")
  return factions
end

-- Load mission content
function ContentLoader.loadMissions()
  print("[ContentLoader] Loading missions...")
  local missions = {}

  local function load_mission(file_name)
    local ok, mission = pcall(function()
      return require("engine.content.missions." .. file_name:gsub("%.lua", ""))
    end)

    if ok and mission then
      print("[ContentLoader] ✓ Loaded mission: " .. (mission.name or file_name))
      return mission
    else
      print("[ContentLoader] ✗ Failed to load mission: " .. file_name)
      return nil
    end
  end

  local mission_files = love.filesystem.getDirectoryItems("engine/content/missions")
  for _, file in ipairs(mission_files) do
    if file:match("%.lua$") then
      local mission = load_mission(file)
      if mission and mission.id then
        missions[mission.id] = mission
      end
    end
  end

  print("[ContentLoader] Loaded " .. table.count(missions) .. " missions")
  return missions
end

-- Load event content
function ContentLoader.loadEvents()
  print("[ContentLoader] Loading events...")
  local events = {}

  local function load_events_file(file_name)
    local ok, event_list = pcall(function()
      return require("engine.content.events." .. file_name:gsub("%.lua", ""))
    end)

    if ok and event_list then
      -- event_list might be a single event or list of events
      if event_list.id then
        -- Single event
        return {event_list}
      elseif type(event_list) == "table" then
        -- List of events
        return event_list
      end
    end

    return {}
  end

  local event_files = love.filesystem.getDirectoryItems("engine/content/events")
  for _, file in ipairs(event_files) do
    if file:match("%.lua$") then
      local event_list = load_events_file(file)
      for _, event in ipairs(event_list) do
        if event and event.id then
          print("[ContentLoader] ✓ Loaded event: " .. (event.name or event.id))
          events[event.id] = event
        end
      end
    end
  end

  print("[ContentLoader] Loaded " .. table.count(events) .. " events")
  return events
end

-- Load all content
function ContentLoader.loadAll()
  print("[ContentLoader] ========================================")
  print("[ContentLoader] Starting complete content load...")
  print("[ContentLoader] ========================================")

  local content = {
    factions = ContentLoader.loadFactions(),
    missions = ContentLoader.loadMissions(),
    events = ContentLoader.loadEvents(),
  }

  print("[ContentLoader] ========================================")
  print("[ContentLoader] Content load complete!")
  print("[ContentLoader] ✓ " .. table.count(content.factions) .. " factions")
  print("[ContentLoader] ✓ " .. table.count(content.missions) .. " missions")
  print("[ContentLoader] ✓ " .. table.count(content.events) .. " events")
  print("[ContentLoader] ========================================")

  return content
end

-- Helper for table counting
function table.count(t)
  local count = 0
  for _ in pairs(t) do
    count = count + 1
  end
  return count
end

return ContentLoader

