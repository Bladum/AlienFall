--[[
    Mission Script Example - Advanced Mission Logic
    
    This example demonstrates how to create custom mission scripts for Alien Fall mods.
    Mission scripts control mission flow, objectives, events, and dynamic behavior.
    
    File Location: /wiki/examples/lua/mission_script.lua
    Related Docs: /wiki/mods/API_Reference.md, /wiki/battlescape/README.md
    
    Usage:
    1. Copy this file to your mod's /scripts/missions/ directory
    2. Register mission in mod.toml
    3. Customize behavior for your mission type
]]

-- Mission definition table
local Mission = {
    id = "example_terror_mission",
    name = "Alien Terror Attack",
    description = "Aliens are terrorizing civilians in the city",
    type = "terror",
    
    -- Mission parameters
    settings = {
        min_aliens = 6,
        max_aliens = 12,
        min_civilians = 10,
        max_civilians = 20,
        turn_limit = 20,
        withdrawal_allowed = true,
        time_of_day = "night", -- "dawn", "day", "dusk", "night"
        weather = "rain", -- "clear", "rain", "storm", "fog"
    },
    
    -- Mission state
    state = {
        aliens_remaining = 0,
        civilians_saved = 0,
        civilians_killed = 0,
        turn_number = 0,
        mission_complete = false,
        player_victory = false,
    },
}

--[[
    Initialize Mission
    Called when mission starts, before soldier deployment
]]
function Mission:init()
    print("[Mission] Initializing: " .. self.name)
    
    -- Generate random alien count within range
    local alien_count = math.random(self.settings.min_aliens, self.settings.max_aliens)
    self.state.aliens_remaining = alien_count
    
    -- Generate random civilian count
    local civilian_count = math.random(self.settings.min_civilians, self.settings.max_civilians)
    
    -- Spawn aliens using mission API
    self:spawnAliens(alien_count)
    
    -- Spawn civilians
    self:spawnCivilians(civilian_count)
    
    -- Set up mission objectives
    self:setupObjectives()
    
    -- Configure environment
    self:setupEnvironment()
    
    print("[Mission] Initialization complete")
    print("[Mission] Aliens: " .. alien_count .. " | Civilians: " .. civilian_count)
end

--[[
    Spawn Aliens
    Creates alien entities in the mission
]]
function Mission:spawnAliens(count)
    local alien_types = {
        {type = "sectoid", weight = 40},
        {type = "floater", weight = 30},
        {type = "chrysalid", weight = 20},
        {type = "muton", weight = 10},
    }
    
    for i = 1, count do
        -- Weighted random alien type selection
        local alien_type = self:selectWeightedRandom(alien_types)
        
        -- Get spawn position (avoid player deployment zone)
        local spawn_pos = self:getAlienSpawnPosition()
        
        -- Spawn alien using game API
        local alien = game.spawnAlien({
            type = alien_type,
            position = spawn_pos,
            equipment = self:getAlienEquipment(alien_type),
            ai_behavior = self:getAIBehavior(alien_type),
        })
        
        -- Add mission-specific behavior
        alien:addComponent("MissionContext", {
            mission_id = self.id,
            role = "hunter", -- "hunter", "guard", "patrol"
            target_civilians = true,
        })
        
        print("[Mission] Spawned " .. alien_type .. " at " .. tostring(spawn_pos))
    end
end

--[[
    Spawn Civilians
    Creates civilian entities to be rescued
]]
function Mission:spawnCivilians(count)
    for i = 1, count do
        local spawn_pos = self:getCivilianSpawnPosition()
        
        local civilian = game.spawnCivilian({
            position = spawn_pos,
            ai_behavior = "panic_flee", -- Runs away from aliens
            health = 50, -- Civilians are fragile
        })
        
        -- Track civilian for objectives
        civilian:addComponent("ObjectiveTarget", {
            mission_id = self.id,
            objective_type = "rescue",
            points = 10, -- Score for saving
        })
        
        print("[Mission] Spawned civilian #" .. i .. " at " .. tostring(spawn_pos))
    end
end

--[[
    Setup Mission Objectives
    Defines win/loss conditions
]]
function Mission:setupObjectives()
    -- Primary objective: Eliminate all aliens
    game.addObjective({
        id = "eliminate_aliens",
        type = "eliminate",
        description = "Eliminate all alien threats",
        target_faction = "aliens",
        required = true,
        on_complete = function()
            self:checkVictoryConditions()
        end,
    })
    
    -- Secondary objective: Save civilians (optional but affects rating)
    game.addObjective({
        id = "save_civilians",
        type = "rescue",
        description = "Save as many civilians as possible",
        target_count = math.floor(self.settings.max_civilians * 0.5), -- 50% minimum
        required = false,
        on_update = function(saved_count)
            self.state.civilians_saved = saved_count
        end,
    })
    
    -- Hidden failure condition: Too many civilian deaths
    game.addObjective({
        id = "prevent_massacre",
        type = "protect",
        description = "[Hidden] Prevent civilian massacre",
        max_deaths = math.floor(self.settings.max_civilians * 0.7), -- 70% max deaths
        required = false,
        on_fail = function()
            self:triggerMassacreEvent()
        end,
    })
end

--[[
    Setup Environment
    Configures map, lighting, weather
]]
function Mission:setupEnvironment()
    -- Set time of day (affects lighting and alien behavior)
    game.setTimeOfDay(self.settings.time_of_day)
    
    -- Set weather (affects visibility and sound)
    game.setWeather(self.settings.weather)
    
    -- Configure lighting based on time
    if self.settings.time_of_day == "night" then
        game.setAmbientLight(0.3) -- Dark, limited visibility
        game.setSoldierFlashlight(true) -- Soldiers have flashlights
    else
        game.setAmbientLight(1.0) -- Full daylight
    end
    
    -- Add environmental hazards (optional)
    if self.settings.weather == "storm" then
        self:spawnEnvironmentalHazards()
    end
end

--[[
    Update Mission
    Called every turn to check state and trigger events
]]
function Mission:update(turn_number)
    self.state.turn_number = turn_number
    
    print("[Mission] Turn " .. turn_number .. " | Aliens: " .. self.state.aliens_remaining)
    
    -- Check turn limit
    if turn_number >= self.settings.turn_limit then
        self:triggerTurnLimit()
        return
    end
    
    -- Trigger turn-based events
    if turn_number == 5 then
        self:triggerReinforcementsEvent()
    end
    
    if turn_number == 10 then
        self:triggerChrysalidWave()
    end
    
    -- Check for dynamic events
    if self.state.civilians_killed >= 5 then
        self:triggerPanicEvent()
    end
    
    -- Update AI behavior based on mission state
    self:updateAIStrategy()
end

--[[
    On Alien Killed
    Called when an alien dies
]]
function Mission:onAlienKilled(alien)
    self.state.aliens_remaining = self.state.aliens_remaining - 1
    
    print("[Mission] Alien killed | Remaining: " .. self.state.aliens_remaining)
    
    -- Check if mission objectives complete
    if self.state.aliens_remaining <= 0 then
        self:checkVictoryConditions()
    end
    
    -- Award points based on alien type
    local points = {
        sectoid = 10,
        floater = 15,
        chrysalid = 20,
        muton = 25,
    }
    
    game.awardPoints(points[alien.type] or 10)
end

--[[
    On Civilian Killed
    Called when a civilian dies
]]
function Mission:onCivilianKilled(civilian, killer)
    self.state.civilians_killed = self.state.civilians_killed + 1
    
    print("[Mission] Civilian killed | Total deaths: " .. self.state.civilians_killed)
    
    -- Penalty for civilian deaths
    if killer.faction == "xcom" then
        -- Player killed civilian - severe penalty
        game.addPanicToRegion(5)
        game.showMessage("FRIENDLY FIRE! Civilian killed by XCOM forces!")
    else
        -- Alien killed civilian - normal consequence
        game.addPanicToRegion(2)
    end
end

--[[
    On Civilian Rescued
    Called when civilian reaches extraction zone or survives
]]
function Mission:onCivilianRescued(civilian)
    self.state.civilians_saved = self.state.civilians_saved + 1
    
    print("[Mission] Civilian rescued | Total saved: " .. self.state.civilians_saved)
    
    -- Award bonus points and funding
    game.awardPoints(20)
    game.awardFunding(5000)
end

--[[
    Trigger Reinforcements Event
    Spawn additional aliens mid-mission
]]
function Mission:triggerReinforcementsEvent()
    print("[Mission] EVENT: Alien reinforcements detected!")
    
    game.showMessage("ALERT: Additional alien contacts detected approaching area!")
    
    -- Spawn 3-5 additional aliens
    local reinforcement_count = math.random(3, 5)
    
    for i = 1, reinforcement_count do
        local alien_type = "floater" -- Airborne reinforcements
        local spawn_pos = self:getReinforcementSpawnPosition()
        
        game.spawnAlien({
            type = alien_type,
            position = spawn_pos,
            equipment = self:getAlienEquipment(alien_type),
            ai_behavior = "aggressive",
        })
        
        self.state.aliens_remaining = self.state.aliens_remaining + 1
    end
end

--[[
    Trigger Chrysalid Wave
    Special terror event - melee alien swarm
]]
function Mission:triggerChrysalidWave()
    print("[Mission] EVENT: Chrysalid infestation detected!")
    
    game.showMessage("WARNING: Fast-moving hostiles detected! Maintain defensive positions!")
    
    -- Spawn 4-6 chrysalids
    local chrysalid_count = math.random(4, 6)
    
    for i = 1, chrysalid_count do
        local spawn_pos = self:getAlienSpawnPosition()
        
        game.spawnAlien({
            type = "chrysalid",
            position = spawn_pos,
            equipment = {}, -- No weapons, melee only
            ai_behavior = "rush_melee",
        })
        
        self.state.aliens_remaining = self.state.aliens_remaining + 1
    end
end

--[[
    Trigger Turn Limit
    Mission time expires
]]
function Mission:triggerTurnLimit()
    print("[Mission] EVENT: Turn limit reached!")
    
    game.showMessage("MISSION TIME EXPIRED! Aliens have completed their objective.")
    
    self:endMission({
        victory = false,
        reason = "time_limit",
        rating = 1, -- Poor rating
    })
end

--[[
    Check Victory Conditions
    Determine if player won the mission
]]
function Mission:checkVictoryConditions()
    if self.state.aliens_remaining <= 0 then
        local rating = self:calculateMissionRating()
        
        self:endMission({
            victory = true,
            reason = "aliens_eliminated",
            rating = rating,
        })
    end
end

--[[
    Calculate Mission Rating
    Determines mission success quality (1-5 stars)
]]
function Mission:calculateMissionRating()
    local total_civilians = self.settings.max_civilians
    local survival_rate = self.state.civilians_saved / total_civilians
    
    -- Base rating on civilian survival
    local rating = 1
    
    if survival_rate >= 0.9 then
        rating = 5 -- ★★★★★ Excellent
    elseif survival_rate >= 0.7 then
        rating = 4 -- ★★★★☆ Good
    elseif survival_rate >= 0.5 then
        rating = 3 -- ★★★☆☆ Fair
    elseif survival_rate >= 0.3 then
        rating = 2 -- ★★☆☆☆ Poor
    else
        rating = 1 -- ★☆☆☆☆ Terrible
    end
    
    -- Adjust for turn efficiency
    if self.state.turn_number <= 10 then
        rating = rating + 1 -- Bonus for speed
    end
    
    -- Cap at 5 stars
    return math.min(rating, 5)
end

--[[
    End Mission
    Conclude mission and return to geoscape
]]
function Mission:endMission(result)
    self.state.mission_complete = true
    self.state.player_victory = result.victory
    
    print("[Mission] Mission complete | Victory: " .. tostring(result.victory))
    print("[Mission] Rating: " .. result.rating .. " stars")
    
    -- Calculate rewards
    local rewards = {
        funding = self.state.civilians_saved * 10000,
        research_materials = self.state.aliens_remaining * 2,
        soldier_xp = result.victory and 150 or 50,
    }
    
    -- Show mission summary
    game.showMissionSummary({
        victory = result.victory,
        rating = result.rating,
        civilians_saved = self.state.civilians_saved,
        civilians_killed = self.state.civilians_killed,
        aliens_killed = self.settings.max_aliens - self.state.aliens_remaining,
        rewards = rewards,
    })
    
    -- Return to geoscape
    game.returnToGeoscape(rewards)
end

--[[
    Helper: Get Alien Equipment
    Returns equipment loadout based on alien type
]]
function Mission:getAlienEquipment(alien_type)
    local equipment = {
        sectoid = {
            weapon = "plasma_pistol",
            armor = "none",
        },
        floater = {
            weapon = "plasma_rifle",
            armor = "light_alien",
        },
        chrysalid = {
            weapon = "claws", -- Melee
            armor = "carapace",
        },
        muton = {
            weapon = "heavy_plasma",
            armor = "heavy_alien",
        },
    }
    
    return equipment[alien_type] or equipment.sectoid
end

--[[
    Helper: Get AI Behavior
    Returns AI behavior pattern for alien type
]]
function Mission:getAIBehavior(alien_type)
    local behaviors = {
        sectoid = "cautious", -- Takes cover, defensive
        floater = "flanker", -- Uses mobility to flank
        chrysalid = "rush_melee", -- Charges directly
        muton = "aggressive", -- Advances steadily
    }
    
    return behaviors[alien_type] or "standard"
end

--[[
    Helper: Select Weighted Random
    Chooses item from weighted list
]]
function Mission:selectWeightedRandom(weighted_list)
    local total_weight = 0
    for _, item in ipairs(weighted_list) do
        total_weight = total_weight + item.weight
    end
    
    local roll = math.random(1, total_weight)
    local cumulative = 0
    
    for _, item in ipairs(weighted_list) do
        cumulative = cumulative + item.weight
        if roll <= cumulative then
            return item.type
        end
    end
    
    -- Fallback
    return weighted_list[1].type
end

--[[
    Helper: Get Spawn Position
    Returns valid spawn coordinates
]]
function Mission:getAlienSpawnPosition()
    -- In real implementation, this would check map data
    -- For example, avoid player deployment zone, find cover, etc.
    return {
        x = math.random(20, 40),
        y = math.random(20, 40),
    }
end

function Mission:getCivilianSpawnPosition()
    return {
        x = math.random(10, 50),
        y = math.random(10, 50),
    }
end

function Mission:getReinforcementSpawnPosition()
    -- Spawn at map edges
    local edge = math.random(1, 4)
    local x, y
    
    if edge == 1 then -- Top
        x, y = math.random(0, 60), 0
    elseif edge == 2 then -- Right
        x, y = 60, math.random(0, 60)
    elseif edge == 3 then -- Bottom
        x, y = math.random(0, 60), 60
    else -- Left
        x, y = 0, math.random(0, 60)
    end
    
    return {x = x, y = y}
end

-- Return mission table for game engine
return Mission
