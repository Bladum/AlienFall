--- Difficulty Manager
--- Handles difficulty settings and adaptive scaling throughout the game
---
--- Difficulty affects:
--- - Enemy unit stats (health, accuracy, reactions)
--- - Resource availability and funding
--- - Mission frequency and composition
--- - AI behavior and tactical capabilities
--- - Player casualties affecting permadeath mechanics
---
--- Difficulty Presets:
--- - Easy: Forgiving gameplay, higher resources
--- - Normal: Balanced challenge
--- - Heroic: Challenging gameplay, limited resources
--- - Ironman: Permadeath, no saves, maximum challenge
---
--- @class DifficultyManager
local DifficultyManager = {}

--- Initialize difficulty manager
function DifficultyManager:new()
    local self = setmetatable({}, { __index = DifficultyManager })
    
    self.currentDifficulty = "normal"
    self.difficultyPresets = {}
    self.customSettings = {}
    
    -- Initialize default presets
    self:createDefaultPresets()
    
    print("[DifficultyManager] Initialized with difficulty: " .. self.currentDifficulty)
    return self
end

--- Create default difficulty presets
function DifficultyManager:createDefaultPresets()
    self.difficultyPresets = {
        easy = {
            name = "Easy",
            description = "Forgiving gameplay for learning the game",
            enemy_health_multiplier = 0.7,
            enemy_accuracy_multiplier = 0.7,
            enemy_reaction_multiplier = 0.8,
            funding_multiplier = 1.5,
            mission_frequency_multiplier = 0.8,
            panic_multiplier = 0.5,
            casualty_severity = 0.5,  -- Injuries less severe
            permadeath = false,
            custom = false,
        },
        normal = {
            name = "Normal",
            description = "Balanced challenge",
            enemy_health_multiplier = 1.0,
            enemy_accuracy_multiplier = 1.0,
            enemy_reaction_multiplier = 1.0,
            funding_multiplier = 1.0,
            mission_frequency_multiplier = 1.0,
            panic_multiplier = 1.0,
            casualty_severity = 1.0,
            permadeath = false,
            custom = false,
        },
        heroic = {
            name = "Heroic",
            description = "Challenging gameplay, limited resources",
            enemy_health_multiplier = 1.3,
            enemy_accuracy_multiplier = 1.2,
            enemy_reaction_multiplier = 1.2,
            funding_multiplier = 0.8,
            mission_frequency_multiplier = 1.2,
            panic_multiplier = 1.5,
            casualty_severity = 1.5,
            permadeath = false,
            custom = false,
        },
        ironman = {
            name = "Ironman",
            description = "Maximum challenge, permadeath, no saves",
            enemy_health_multiplier = 1.5,
            enemy_accuracy_multiplier = 1.3,
            enemy_reaction_multiplier = 1.3,
            funding_multiplier = 0.7,
            mission_frequency_multiplier = 1.3,
            panic_multiplier = 2.0,
            casualty_severity = 2.0,
            permadeath = true,
            custom = false,
        },
    }
end

--- Load difficulty preset from mod configuration
--- @param presetId string Preset identifier
--- @param presetData table Configuration from TOML
function DifficultyManager:loadPreset(presetId, presetData)
    if not presetData then return end
    
    local preset = {
        name = presetData.name or "Custom",
        description = presetData.description or "",
        enemy_health_multiplier = presetData.enemy_health_multiplier or 1.0,
        enemy_accuracy_multiplier = presetData.enemy_accuracy_multiplier or 1.0,
        enemy_reaction_multiplier = presetData.enemy_reaction_multiplier or 1.0,
        funding_multiplier = presetData.funding_multiplier or 1.0,
        mission_frequency_multiplier = presetData.mission_frequency_multiplier or 1.0,
        panic_multiplier = presetData.panic_multiplier or 1.0,
        casualty_severity = presetData.casualty_severity or 1.0,
        permadeath = presetData.permadeath or false,
        custom = true,
    }
    
    self.difficultyPresets[presetId] = preset
    print("[DifficultyManager] Loaded custom difficulty preset: " .. presetId)
    return preset
end

--- Set current difficulty
--- @param difficultyId string Difficulty identifier
--- @return boolean Success
function DifficultyManager:setDifficulty(difficultyId)
    if not self.difficultyPresets[difficultyId] then
        print("[DifficultyManager] Warning: Unknown difficulty: " .. difficultyId)
        return false
    end
    
    self.currentDifficulty = difficultyId
    self.customSettings = self.difficultyPresets[difficultyId]
    
    print("[DifficultyManager] Set difficulty to: " .. difficultyId)
    return true
end

--- Get current difficulty settings
--- @return table Current difficulty configuration
function DifficultyManager:getCurrentSettings()
    return self.difficultyPresets[self.currentDifficulty] or self.difficultyPresets.normal
end

--- Get difficulty name
--- @return string Difficulty name
function DifficultyManager:getDifficultyName()
    local settings = self:getCurrentSettings()
    return settings.name
end

--- Apply difficulty multiplier to a value
--- @param value number Base value
--- @param multiplierKey string Key of multiplier (e.g., "enemy_health_multiplier")
--- @return number Scaled value
function DifficultyManager:applyMultiplier(value, multiplierKey)
    local settings = self:getCurrentSettings()
    local multiplier = settings[multiplierKey] or 1.0
    return value * multiplier
end

--- Adaptive difficulty scaling based on player performance
--- Adjusts difficulty if player is having too easy or hard a time
--- @param playerStats table Player performance statistics
function DifficultyManager:adaptiveDifficulty(playerStats)
    if self.currentDifficulty == "ironman" then
        return  -- Ironman doesn't adapt
    end
    
    local settings = self:getCurrentSettings()
    
    -- If player winning too easily, increase difficulty slightly
    if playerStats.mission_success_rate > 0.9 then
        settings.enemy_health_multiplier = math.min(2.0, settings.enemy_health_multiplier + 0.05)
        settings.enemy_accuracy_multiplier = math.min(1.5, settings.enemy_accuracy_multiplier + 0.03)
        print("[DifficultyManager] Adaptive: Increased difficulty (player success rate too high)")
    end
    
    -- If player struggling, reduce difficulty slightly
    if playerStats.mission_success_rate < 0.3 then
        settings.enemy_health_multiplier = math.max(0.5, settings.enemy_health_multiplier - 0.05)
        settings.enemy_accuracy_multiplier = math.max(0.5, settings.enemy_accuracy_multiplier - 0.03)
        print("[DifficultyManager] Adaptive: Decreased difficulty (player success rate too low)")
    end
end

--- Check if permadeath is enabled
--- @return boolean
function DifficultyManager:isPermadeathEnabled()
    local settings = self:getCurrentSettings()
    return settings.permadeath or false
end

--- Get list of available difficulties
--- @return table Array of difficulty IDs
function DifficultyManager:getAvailableDifficulties()
    local difficulties = {}
    for id, preset in pairs(self.difficultyPresets) do
        table.insert(difficulties, {
            id = id,
            name = preset.name,
            description = preset.description,
        })
    end
    return difficulties
end

--- Get difficulty-affected enemy stats
--- @param baseStats table Unit base stats
--- @return table Adjusted stats based on difficulty
function DifficultyManager:getAdjustedEnemyStats(baseStats)
    local adjusted = {}
    for key, value in pairs(baseStats) do
        if type(value) == "number" then
            if key == "health" or key == "armor" then
                adjusted[key] = self:applyMultiplier(value, "enemy_health_multiplier")
            elseif key == "accuracy" or key == "aim" then
                adjusted[key] = self:applyMultiplier(value, "enemy_accuracy_multiplier")
            elseif key == "reactions" then
                adjusted[key] = self:applyMultiplier(value, "enemy_reaction_multiplier")
            else
                adjusted[key] = value
            end
        else
            adjusted[key] = value
        end
    end
    return adjusted
end

--- Load difficulty state from save
--- @param data table Save data
function DifficultyManager:load(data)
    if data.difficulty then
        self:setDifficulty(data.difficulty)
    end
end

--- Get difficulty state for saving
--- @return table Save data
function DifficultyManager:getSaveData()
    return {
        difficulty = self.currentDifficulty,
    }
end

return DifficultyManager




