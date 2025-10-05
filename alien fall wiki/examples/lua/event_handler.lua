--[[
    Event Bus Usage Example
    Demonstrates event-driven architecture for decoupled system communication
    
    Key Concepts:
    - Event emission and listening
    - Decoupled system communication
    - Event payload structure
    - Lifecycle management
]]

local eventBus = require("src.core.services.event_bus")

--[[
    EMIT EVENTS: Notify other systems of game state changes
]]

-- Example: Mission completed event
local function completeMission(mission_id, success, casualties, salvage)
    -- Emit event with structured payload
    eventBus:emit("battlescape:mission_end", {
        mission_id = mission_id,
        success = success,
        casualties = casualties,  -- Array of unit IDs
        salvage = salvage,        -- Array of item IDs
        timestamp = os.time()
    })
end

-- Example: Research completed event
local function completeResearch(research_id, unlocks)
    eventBus:emit("economy:research_completed", {
        research_id = research_id,
        unlocks = {
            items = unlocks.items or {},
            facilities = unlocks.facilities or {},
            research = unlocks.research or {}
        },
        duration_days = unlocks.duration_days
    })
end

-- Example: Unit promotion event
local function promoteUnit(unit_id, new_rank, abilities_gained)
    eventBus:emit("units:promotion", {
        unit_id = unit_id,
        old_rank = unit.rank,
        new_rank = new_rank,
        abilities_gained = abilities_gained
    })
end

--[[
    LISTEN TO EVENTS: React to game state changes from other systems
]]

-- Example: Listen for mission completion to update geoscape
local function registerGeoscapeHandlers()
    -- Handle mission results
    eventBus:on("battlescape:mission_end", function(data)
        if data.success then
            -- Decrease province panic
            local province = getProvince(data.mission_id)
            province.panic = math.max(0, province.panic - 10)
            
            -- Award credits
            local credits = calculateMissionReward(data.mission_id)
            services:get("economy"):addCredits(credits)
            
            -- Process salvage
            for _, item_id in ipairs(data.salvage) do
                services:get("inventory"):addItem(item_id, 1)
            end
        else
            -- Increase panic on failure
            local province = getProvince(data.mission_id)
            province.panic = math.min(100, province.panic + 15)
        end
        
        -- Handle casualties
        for _, unit_id in ipairs(data.casualties) do
            services:get("units"):markUnitKIA(unit_id)
        end
    end)
    
    -- Handle funding changes
    eventBus:on("finance:monthly_report", function(data)
        print(string.format("Monthly Report: Income $%d, Expenses $%d, Net $%d",
                          data.income, data.expenses, data.net))
        
        -- Update UI
        if data.net < 0 then
            showWarning("Budget deficit! Consider taking on debt or selling equipment.")
        end
    end)
end

-- Example: Listen for research completion to unlock items
local function registerEconomyHandlers()
    eventBus:on("economy:research_completed", function(data)
        print("Research completed: " .. data.research_id)
        
        -- Unlock manufacturing recipes
        local manufacturing = services:get("manufacturing")
        for _, item_id in ipairs(data.unlocks.items) do
            manufacturing:unlockRecipe(item_id)
            showNotification("New item available: " .. item_id)
        end
        
        -- Unlock facilities
        local basescape = services:get("basescape")
        for _, facility_id in ipairs(data.unlocks.facilities) do
            basescape:unlockFacility(facility_id)
            showNotification("New facility available: " .. facility_id)
        end
        
        -- Unlock new research projects
        local research = services:get("research")
        for _, next_research_id in ipairs(data.unlocks.research) do
            research:unlockResearch(next_research_id)
        end
    end)
end

-- Example: Listen for unit events to update UI
local function registerUIHandlers()
    -- Update unit roster UI when units change
    eventBus:on("units:promotion", function(data)
        showNotification(string.format("%s promoted to %s!", 
                                      getUnitName(data.unit_id), 
                                      data.new_rank))
        
        -- Refresh unit roster panel
        if currentScreen == "basescape:barracks" then
            refreshUnitRoster()
        end
    end)
    
    eventBus:on("units:wounded", function(data)
        showWarning(string.format("%s wounded! Recovery time: %d days",
                                 getUnitName(data.unit_id),
                                 data.recovery_days))
    end)
    
    eventBus:on("units:recovered", function(data)
        showNotification(string.format("%s has recovered and is ready for duty!",
                                      getUnitName(data.unit_id)))
    end)
end

--[[
    ONE-TIME LISTENERS: Execute once then auto-unsubscribe
]]

local function waitForResearchCompletion(research_id, callback)
    -- Create one-time listener
    local listener_id
    listener_id = eventBus:on("economy:research_completed", function(data)
        if data.research_id == research_id then
            callback(data)
            -- Unsubscribe after handling
            eventBus:off("economy:research_completed", listener_id)
        end
    end)
    
    return listener_id  -- Return for manual cleanup if needed
end

--[[
    EVENT PAYLOAD STANDARDS
    
    All events should follow these conventions:
]]

-- Standard payload structure
local EVENT_PAYLOAD_TEMPLATE = {
    -- Required fields
    event_type = "string",           -- e.g., "mission_end", "research_completed"
    timestamp = 0,                   -- os.time() when event occurred
    
    -- Context fields (depend on event type)
    entity_id = "string or number",  -- ID of primary entity (mission_id, unit_id, etc.)
    
    -- Data fields (event-specific)
    -- ...
    
    -- Metadata (optional but recommended)
    source_system = "string",        -- e.g., "battlescape", "geoscape"
    version = "1.0.0"                -- Event payload version for compatibility
}

-- Example: Complete mission event payload
local mission_end_payload = {
    event_type = "mission_end",
    timestamp = os.time(),
    
    mission_id = 12345,
    success = true,
    turn_count = 8,
    
    casualties = {101, 103},         -- Unit IDs killed
    wounded = {102, 105},            -- Unit IDs wounded
    survivors = {104, 106, 107},     -- Unit IDs survived unharmed
    
    salvage = {
        {item_id = "plasma_rifle", quantity = 2},
        {item_id = "alien_alloys", quantity = 5}
    },
    
    score = 150,
    credits_earned = 15000,
    experience_earned = 500,
    
    source_system = "battlescape",
    version = "1.0.0"
}

--[[
    LIFECYCLE MANAGEMENT
]]

-- Clean up event listeners when system is destroyed
local function cleanup()
    -- Option 1: Remove specific listeners
    eventBus:off("battlescape:mission_end", mission_handler_id)
    
    -- Option 2: Remove all listeners for a namespace (if supported)
    -- eventBus:offAll("geoscape")
    
    -- Option 3: Clear all listeners (use with caution!)
    -- eventBus:clear()
end

--[[
    BEST PRACTICES:
    
    1. Use namespaced event names
       ✅ "battlescape:mission_end"
       ❌ "mission_end" (unclear which system)
    
    2. Include all relevant context in payload
       ✅ { mission_id = 123, success = true, casualties = [...] }
       ❌ { success = true } (missing context)
    
    3. Document event payloads
       - Add comments describing payload structure
       - Maintain event documentation
    
    4. Clean up listeners
       - Remove listeners when objects are destroyed
       - Prevent memory leaks
    
    5. Avoid circular dependencies
       - System A emits → System B reacts
       - System B should not emit back to A in same handler
    
    6. Keep handlers fast
       - Event handlers should execute quickly
       - Defer heavy processing to update loop
    
    7. Use consistent naming
       - verb_noun format: "mission_end", "research_completed"
       - namespace:event format: "geoscape:time_advanced"
]]

--[[
    COMMON EVENTS BY SYSTEM:
    
    Geoscape:
    - "geoscape:time_advanced" - Game time progressed
    - "geoscape:mission_spawned" - New mission detected
    - "geoscape:mission_expired" - Mission timeout
    - "geoscape:month_end" - Monthly cycle complete
    
    Battlescape:
    - "battlescape:mission_start" - Mission begins
    - "battlescape:mission_end" - Mission complete
    - "battlescape:turn_start" - New turn begins
    - "battlescape:unit_killed" - Unit eliminated
    
    Economy:
    - "economy:research_completed" - Research done
    - "economy:manufacturing_completed" - Item manufactured
    - "economy:credits_changed" - Money changed
    - "economy:purchase_made" - Item purchased
    
    Units:
    - "units:promotion" - Unit ranked up
    - "units:wounded" - Unit injured
    - "units:recovered" - Unit healed
    - "units:kia" - Unit killed
    
    Finance:
    - "finance:monthly_report" - Monthly financial report
    - "finance:debt_accrued" - Debt taken
    - "finance:debt_paid" - Debt repaid
    
    Organization:
    - "organization:reputation_changed" - Faction reputation changed
    - "organization:panic_changed" - Province panic changed
]]

return {
    registerGeoscapeHandlers = registerGeoscapeHandlers,
    registerEconomyHandlers = registerEconomyHandlers,
    registerUIHandlers = registerUIHandlers,
    waitForResearchCompletion = waitForResearchCompletion,
    cleanup = cleanup
}
