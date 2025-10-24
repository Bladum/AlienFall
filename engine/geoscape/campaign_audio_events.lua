---Campaign Audio Events
---
---Connects campaign system events to audio playback. Maps campaign state changes,
---mission events, and system updates to appropriate sound effects and music tracks.
---Integrates with the AudioSystem to provide audio feedback throughout gameplay.
---
---Key Exports:
---  - CampaignAudioEvents:new(): Create event handler
---  - CampaignAudioEvents:initialize(audio_system): Setup audio integration
---  - CampaignAudioEvents:onMissionGenerated(mission): Play mission ready tone
---  - CampaignAudioEvents:onMissionVictory(): Play triumph fanfare
---  - CampaignAudioEvents:onMissionDefeat(): Play defeat stinger
---  - CampaignAudioEvents:onThreatEscalation(): Play tension audio
---
---Event Mapping:
---  Mission Events → Audio feedback
---  Research Complete → Success jingle
---  Base Alert → Urgent alarm
---  Alien Activity → Tension audio
---  Turn Advanced → Subtle notification
---
---@module engine.geoscape.campaign_audio_events
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source

local CampaignAudioEvents = {}
CampaignAudioEvents.__index = CampaignAudioEvents

--- Create new campaign audio events handler
function CampaignAudioEvents.new()
    local self = setmetatable({}, CampaignAudioEvents)
    self.audio_system = nil
    self.current_music = "menu"
    self.initialized = false

    return self
end

--- Initialize with audio system
---@param audio_system table AudioSystem instance
function CampaignAudioEvents:initialize(audio_system)
    print("[CampaignAudioEvents] Initializing...")

    self.audio_system = audio_system or error("audio_system required")
    self.initialized = true

    print("[CampaignAudioEvents] Initialized")
    return self
end

--- Validate initialization
---@return boolean initialized
function CampaignAudioEvents:_checkInitialized()
    if not self.initialized then
        print("[CampaignAudioEvents] WARNING: Not initialized, audio disabled")
        return false
    end
    if not self.audio_system then
        print("[CampaignAudioEvents] WARNING: No audio system, audio disabled")
        return false
    end
    return true
end

--- Play background music for campaign map
function CampaignAudioEvents:playGeoscapeMusic()
    if not self:_checkInitialized() then return end

    print("[CampaignAudioEvents] Playing geoscape music")

    if self.audio_system.playMusic then
        self.audio_system:playMusic("geoscape", {loop = true, volume = 0.6})
        self.current_music = "geoscape"
    end
end

--- Stop music and return to menu music
function CampaignAudioEvents:playMenuMusic()
    if not self:_checkInitialized() then return end

    print("[CampaignAudioEvents] Playing menu music")

    if self.audio_system.playMusic then
        self.audio_system:playMusic("menu", {loop = true, volume = 0.7})
        self.current_music = "menu"
    end
end

--- Mission generated event
---@param mission table Mission data
function CampaignAudioEvents:onMissionGenerated(mission)
    if not self:_checkInitialized() then return end

    print("[CampaignAudioEvents] Mission generated: " .. (mission.name or "Unknown"))

    if self.audio_system.playSFX then
        self.audio_system:playSFX("mission_ready", 0.8)
    end
end

--- Mission briefing started
---@param mission table Mission data
function CampaignAudioEvents:onMissionBriefing(mission)
    if not self:_checkInitialized() then return end

    print("[CampaignAudioEvents] Mission briefing for: " .. (mission.name or "Unknown"))

    if self.audio_system.playSFX then
        self.audio_system:playSFX("briefing_start", 0.7)
    end
end

--- Mission victory event
---@param mission table Mission data
---@param results table Battle results
function CampaignAudioEvents:onMissionVictory(mission, results)
    if not self:_checkInitialized() then return end

    print("[CampaignAudioEvents] Mission victory!")

    if self.audio_system.playSFX then
        self.audio_system:playSFX("mission_victory", 1.0)
    end
end

--- Mission defeat event
---@param mission table Mission data
---@param results table Battle results
function CampaignAudioEvents:onMissionDefeat(mission, results)
    if not self:_checkInitialized() then return end

    print("[CampaignAudioEvents] Mission defeat!")

    if self.audio_system.playSFX then
        self.audio_system:playSFX("mission_defeat", 1.0)
    end
end

--- Research completed event
---@param research table Research data
function CampaignAudioEvents:onResearchComplete(research)
    if not self:_checkInitialized() then return end

    print("[CampaignAudioEvents] Research complete: " .. (research.name or "Unknown"))

    if self.audio_system.playSFX then
        self.audio_system:playSFX("research_complete", 0.8)
    end
end

--- Manufacturing completed event
---@param manufacturing table Manufacturing data
function CampaignAudioEvents:onManufacturingComplete(manufacturing)
    if not self:_checkInitialized() then return end

    print("[CampaignAudioEvents] Manufacturing complete: " .. (manufacturing.name or "Unknown"))

    if self.audio_system.playSFX then
        self.audio_system:playSFX("manufacturing_complete", 0.7)
    end
end

--- Alien research progress event
---@param progress number Research progress (0.0-1.0)
function CampaignAudioEvents:onAlienResearchProgress(progress)
    if not self:_checkInitialized() then return end

    print(string.format("[CampaignAudioEvents] Alien research progress: %.0f%%", progress * 100))

    if progress > 0.8 and self.audio_system.playSFX then
        self.audio_system:playSFX("alien_research_ding", 0.6)
    end
end

--- Base under attack event
---@param base table Base data
---@param threat table Threat info
function CampaignAudioEvents:onBaseUnderAttack(base, threat)
    if not self:_checkInitialized() then return end

    print("[CampaignAudioEvents] Base under attack: " .. (base.name or "Unknown"))

    if self.audio_system.playSFX then
        self.audio_system:playSFX("base_alert", 1.2)  -- Louder, more urgent
    end
end

--- Threat level escalation event
---@param old_level number Previous threat level
---@param new_level number New threat level
function CampaignAudioEvents:onThreatEscalation(old_level, new_level)
    if not self:_checkInitialized() then return end

    print(string.format("[CampaignAudioEvents] Threat escalation: %d → %d", old_level, new_level))

    if self.audio_system.playSFX then
        self.audio_system:playSFX("threat_escalation", 0.9)
    end
end

--- Mission available event
---@param mission table Mission data
function CampaignAudioEvents:onMissionAvailable(mission)
    if not self:_checkInitialized() then return end

    print("[CampaignAudioEvents] New mission available: " .. (mission.name or "Unknown"))

    if self.audio_system.playUI then
        self.audio_system:playUI("notification_ping")
    end
end

--- Turn advanced event
function CampaignAudioEvents:onTurnAdvanced()
    if not self:_checkInitialized() then return end

    print("[CampaignAudioEvents] Turn advanced")

    if self.audio_system.playUI then
        self.audio_system:playUI("turn_advance")
    end
end

--- Alien faction activity event
---@param faction table Faction data
---@param activity string Activity type
function CampaignAudioEvents:onAlienActivity(faction, activity)
    if not self:_checkInitialized() then return end

    print("[CampaignAudioEvents] Alien activity from " .. (faction.name or "Unknown") .. ": " .. activity)

    if self.audio_system.playSFX then
        if activity == "attack" then
            self.audio_system:playSFX("alien_attack", 1.0)
        elseif activity == "research" then
            self.audio_system:playSFX("alien_research_ding", 0.7)
        end
    end
end

--- Campaign phase transition event
---@param old_phase number Previous phase
---@param new_phase number New phase
function CampaignAudioEvents:onPhaseTransition(old_phase, new_phase)
    if not self:_checkInitialized() then return end

    print(string.format("[CampaignAudioEvents] Phase transition: %d → %d", old_phase, new_phase))

    if self.audio_system.playSFX then
        self.audio_system:playSFX("phase_transition", 0.8)
    end
end

--- Button click UI sound
function CampaignAudioEvents:playButtonClick()
    if not self:_checkInitialized() then return end

    if self.audio_system.playUI then
        self.audio_system:playUI("button_click")
    end
end

--- Menu select UI sound
function CampaignAudioEvents:playMenuSelect()
    if not self:_checkInitialized() then return end

    if self.audio_system.playUI then
        self.audio_system:playUI("menu_select")
    end
end

--- Notification alert sound
function CampaignAudioEvents:playNotificationAlert()
    if not self:_checkInitialized() then return end

    if self.audio_system.playUI then
        self.audio_system:playUI("notification_alert")
    end
end

--- Stop all audio
function CampaignAudioEvents:stopAll()
    if not self:_checkInitialized() then return end

    print("[CampaignAudioEvents] Stopping all audio")

    if self.audio_system.stopAll then
        self.audio_system:stopAll()
    end
end

--- Set volume for category
---@param category string Audio category
---@param volume number Volume level (0.0-1.0)
function CampaignAudioEvents:setVolume(category, volume)
    if not self:_checkInitialized() then return end

    print(string.format("[CampaignAudioEvents] Setting %s volume to %.2f", category, volume))

    if self.audio_system.setVolume then
        self.audio_system:setVolume(category, volume)
    end
end

return CampaignAudioEvents
