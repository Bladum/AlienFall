---@meta

---Sound & Detection System
---Handles sound propagation, hearing, alert states, stealth mechanics
---@module sound_detection_system

local SoundDetectionSystem = {}

---@class SoundEvent
---@field id string Unique sound ID
---@field type string Sound type (gunshot, explosion, footstep, door, voice)
---@field sourceQ number Origin Q coordinate
---@field sourceR number Origin R coordinate
---@field radius number Sound radius in hexes
---@field intensity number Sound intensity (1-10)
---@field turn number Turn created
---@field faction string|nil Faction that created sound

---@class UnitAlertState
---@field unitId string
---@field alertLevel string "unaware", "suspicious", "alert", "combat"
---@field lastSoundHeard number Turn of last sound heard
---@field knownEnemyPositions table List of {q, r, turn}
---@field hearingRange number Base hearing range in hexes

-- Configuration
SoundDetectionSystem.CONFIG = {
    -- Weapon noise levels (radius in hexes)
    WEAPON_NOISE = {
        suppressed_pistol = 3,
        pistol = 6,
        smg = 8,
        rifle = 12,
        sniper = 15,
        shotgun = 10,
        machine_gun = 14,
        grenade = 18,
        explosion = 20,
    },

    -- Hearing ranges by alert level
    HEARING_RANGE = {
        unaware = 8,
        suspicious = 12,
        alert = 15,
        combat = 20,
    },

    -- Alert decay
    ALERT_DECAY_TURNS = 5, -- Turns without sound to decay

    -- Stealth modifiers
    CROUCH_SOUND_MULT = 0.5, -- 50% sound when crouched
    SPRINT_SOUND_MULT = 2.0, -- 200% sound when sprinting
}

-- Private state
local activeSounds = {} -- List of SoundEvent
local alertStates = {} -- unitId -> UnitAlertState
local nextSoundId = 1

---Initialize alert state for a unit
---@param unitId string Unit identifier
---@param hearingRange number|nil Custom hearing range
function SoundDetectionSystem.initUnit(unitId, hearingRange)
    alertStates[unitId] = {
        unitId = unitId,
        alertLevel = "unaware",
        lastSoundHeard = 0,
        knownEnemyPositions = {},
        hearingRange = hearingRange or SoundDetectionSystem.CONFIG.HEARING_RANGE.unaware,
    }
end

---Remove unit from tracking
---@param unitId string Unit identifier
function SoundDetectionSystem.removeUnit(unitId)
    alertStates[unitId] = nil
end

---Create a sound event
---@param sourceQ number Source Q coordinate
---@param sourceR number Source R coordinate
---@param soundType string Sound type (gunshot, explosion, etc.)
---@param intensity number|nil Sound intensity (default from weapon type)
---@param faction string|nil Faction that created sound
---@param currentTurn number|nil Current battle turn number
---@return string soundId
function SoundDetectionSystem.createSound(sourceQ, sourceR, soundType, intensity, faction, currentTurn)
    local cfg = SoundDetectionSystem.CONFIG

    -- Determine radius from sound type
    local radius = cfg.WEAPON_NOISE[soundType] or 5
    intensity = intensity or 5

    -- TASK-14.3: Sound detection turn tracking integration
    -- Get current turn from turn manager if available
    local soundTurn = currentTurn or 0

    local sound = {
        id = "sound_" .. nextSoundId,
        type = soundType,
        sourceQ = sourceQ,
        sourceR = sourceR,
        radius = radius,
        intensity = intensity,
        turn = soundTurn,
        faction = faction,
    }

    nextSoundId = nextSoundId + 1
    table.insert(activeSounds, sound)

    print(string.format("[Sound] Created %s at (%d,%d), radius=%d, intensity=%d, turn=%d",
        soundType, sourceQ, sourceR, radius, intensity, soundTurn))

    return sound.id
end

---Process sound detection for all units
---@param units table List of all units
function SoundDetectionSystem.processSoundDetection(units)
    -- Check each unit against each active sound
    for _, unit in ipairs(units) do
        local alertState = alertStates[unit.id]
        if not alertState then
            SoundDetectionSystem.initUnit(unit.id)
            alertState = alertStates[unit.id]
        end

        for _, sound in ipairs(activeSounds) do
            -- Calculate distance
            local distance = SoundDetectionSystem.calculateDistance(
                unit.q, unit.r, sound.sourceQ, sound.sourceR
            )

            -- Check if sound is audible
            if distance <= sound.radius and distance <= alertState.hearingRange then
                SoundDetectionSystem.hearSound(unit, sound, distance)
            end
        end
    end

    -- Clear old sounds (sounds only last 1 turn)
    activeSounds = {}
end

---Unit hears a sound
---@param unit table Unit object
---@param sound SoundEvent
---@param distance number Distance to sound
function SoundDetectionSystem.hearSound(unit, sound, distance)
    local alertState = alertStates[unit.id]
    if not alertState then return end

    -- Different faction = enemy sound
    if sound.faction and sound.faction ~= unit.faction then
        print(string.format("[Sound] %s heard enemy %s at distance %d",
            unit.id, sound.type, distance))

        -- Add known enemy position
        table.insert(alertState.knownEnemyPositions, {
            q = sound.sourceQ,
            r = sound.sourceR,
            turn = sound.turn,
        })

        -- Escalate alert level
        SoundDetectionSystem.escalateAlert(unit.id, sound.type, distance)
    else
        -- Friendly sound
        print(string.format("[Sound] %s heard friendly %s at distance %d",
            unit.id, sound.type, distance))
    end

    alertState.lastSoundHeard = sound.turn
end

---Escalate unit alert level based on sound
---@param unitId string Unit ID
---@param soundType string Type of sound heard
---@param distance number Distance to sound
function SoundDetectionSystem.escalateAlert(unitId, soundType, distance)
    local alertState = alertStates[unitId]
    if not alertState then return end

    local oldLevel = alertState.alertLevel

    -- Determine new alert level based on sound type and distance
    if soundType == "gunshot" or soundType == "explosion" then
        if distance <= 5 then
            alertState.alertLevel = "combat"
        elseif distance <= 10 then
            alertState.alertLevel = "alert"
        else
            if alertState.alertLevel == "unaware" then
                alertState.alertLevel = "suspicious"
            end
        end
    elseif soundType == "footstep" or soundType == "door" then
        if alertState.alertLevel == "unaware" then
            alertState.alertLevel = "suspicious"
        end
    end

    -- Update hearing range based on new alert level
    local cfg = SoundDetectionSystem.CONFIG
    alertState.hearingRange = cfg.HEARING_RANGE[alertState.alertLevel] or 8

    if oldLevel ~= alertState.alertLevel then
        print(string.format("[Sound] %s alert: %s -> %s", unitId, oldLevel, alertState.alertLevel))
    end
end

---Process alert decay (call at turn end)
---@param unitId string Unit ID
---@param currentTurn number Current turn number
function SoundDetectionSystem.processAlertDecay(unitId, currentTurn)
    local alertState = alertStates[unitId]
    if not alertState then return end

    local cfg = SoundDetectionSystem.CONFIG
    local turnsSinceSound = currentTurn - alertState.lastSoundHeard

    if turnsSinceSound >= cfg.ALERT_DECAY_TURNS then
        -- Decay alert level
        local oldLevel = alertState.alertLevel

        if alertState.alertLevel == "combat" then
            alertState.alertLevel = "alert"
        elseif alertState.alertLevel == "alert" then
            alertState.alertLevel = "suspicious"
        elseif alertState.alertLevel == "suspicious" then
            alertState.alertLevel = "unaware"
        end

        if oldLevel ~= alertState.alertLevel then
            print(string.format("[Sound] %s alert decayed: %s -> %s",
                unitId, oldLevel, alertState.alertLevel))

            -- Update hearing range
            local cfg = SoundDetectionSystem.CONFIG
            alertState.hearingRange = cfg.HEARING_RANGE[alertState.alertLevel] or 8
        end
    end
end

---Calculate movement sound radius
---@param unit table Unit object
---@param movementType string "walk", "crouch", "sprint"
---@return number soundRadius
function SoundDetectionSystem.getMovementSound(unit, movementType)
    local baseRadius = 4 -- Base footstep radius
    local cfg = SoundDetectionSystem.CONFIG

    if movementType == "crouch" then
        return baseRadius * cfg.CROUCH_SOUND_MULT
    elseif movementType == "sprint" then
        return baseRadius * cfg.SPRINT_SOUND_MULT
    else
        return baseRadius
    end
end

---Create movement sound
---@param unit table Unit moving
---@param movementType string "walk", "crouch", "sprint"
function SoundDetectionSystem.createMovementSound(unit, movementType)
    local radius = SoundDetectionSystem.getMovementSound(unit, movementType)
    SoundDetectionSystem.createSound(unit.q, unit.r, "footstep", radius, unit.faction)
end

---Create weapon fire sound
---@param unit table Unit firing
---@param weaponType string Weapon type (rifle, pistol, etc.)
function SoundDetectionSystem.createWeaponSound(unit, weaponType)
    SoundDetectionSystem.createSound(unit.q, unit.r, weaponType, nil, unit.faction)
end

---Get alert state for a unit
---@param unitId string Unit ID
---@return UnitAlertState|nil alertState
function SoundDetectionSystem.getAlertState(unitId)
    return alertStates[unitId]
end

---Get known enemy positions for a unit
---@param unitId string Unit ID
---@param maxAge number|nil Maximum age in turns (default 3)
---@param currentTurn number|nil Current battle turn (for comparison)
---@return table positions List of {q, r, turn}
function SoundDetectionSystem.getKnownEnemyPositions(unitId, maxAge, currentTurn)
    local alertState = alertStates[unitId]
    if not alertState then return {} end

    maxAge = maxAge or 3
    -- TASK-14.3: Sound detection turn tracking - get turn from parameter or default to 0
    currentTurn = currentTurn or 0
    local recent = {}

    for _, pos in ipairs(alertState.knownEnemyPositions) do
        if (currentTurn - pos.turn) <= maxAge then
            table.insert(recent, pos)
        end
    end

    return recent
end

---Check if unit is in stealth mode
---@param unit table Unit object
---@return boolean isStealthy
function SoundDetectionSystem.isStealthy(unit)
    -- Unit is stealthy if:
    -- 1. Crouching
    -- 2. Low alert level
    -- 3. Not recently fired weapon

    local alertState = alertStates[unit.id]
    if not alertState then return false end

    return unit.stance == "crouch" and alertState.alertLevel == "unaware"
end

---Calculate detection chance for stealth
---@param observer table Observer unit
---@param target table Target unit
---@param distance number Distance between units
---@return number detectionChance Percentage (0-100)
function SoundDetectionSystem.calculateDetectionChance(observer, target, distance)
    local baseChance = 100 - (distance * 5) -- -5% per hex

    -- Stealth modifier
    if SoundDetectionSystem.isStealthy(target) then
        baseChance = baseChance * 0.5 -- 50% reduction
    end

    -- Alert level modifier
    local alertState = alertStates[observer.id]
    if alertState then
        if alertState.alertLevel == "alert" or alertState.alertLevel == "combat" then
            baseChance = baseChance * 1.5 -- 50% increase when alert
        end
    end

    return math.max(0, math.min(100, baseChance))
end

---Calculate hex distance
---@param q1 number Q1
---@param r1 number R1
---@param q2 number Q2
---@param r2 number R2
---@return number distance
function SoundDetectionSystem.calculateDistance(q1, r1, q2, r2)
    local dq = math.abs(q2 - q1)
    local dr = math.abs(r2 - r1)
    local ds = math.abs((-q1 - r1) - (-q2 - r2))
    return math.floor((dq + dr + ds) / 2)
end

---Configure sound system
---@param config table Configuration overrides
function SoundDetectionSystem.configure(config)
    for k, v in pairs(config) do
        if SoundDetectionSystem.CONFIG[k] ~= nil then
            SoundDetectionSystem.CONFIG[k] = v
            print(string.format("[Sound] Config: %s = %s", k, tostring(v)))
        end
    end
end

---Reset entire system
function SoundDetectionSystem.reset()
    activeSounds = {}
    alertStates = {}
    nextSoundId = 1
    print("[Sound] System reset")
end

return SoundDetectionSystem

