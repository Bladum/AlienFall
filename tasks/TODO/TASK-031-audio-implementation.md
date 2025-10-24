# Task: Audio Implementation - Campaign Sound Effects & Music

**Status:** TODO
**Priority:** High
**Created:** October 24, 2025
**Completed:** N/A
**Assigned To:** AI Agent

---

## Overview

Add audio feedback to the campaign system to enhance immersion and player awareness:
1. Background music for main menu, campaign map, and battles
2. Sound effects for campaign events (alien activity, base alerts, research complete)
3. Mission outcome audio (victory fanfare, defeat stinger)
4. UI sound effects (button clicks, notifications)
5. Ambient sounds (base ambience, alien activity)

Audio makes campaign events **feel impactful** and keeps players informed.

---

## Purpose

The campaign system is fully playable but lacks audio feedback. Players cannot hear:
- When missions are available
- When alien research completes
- When bases are under threat
- Mission outcomes (silent victory/defeat)

Audio adds emotional impact and provides subconscious information flow.

---

## Requirements

### Functional Requirements
- [ ] Main menu has background music (loop continuously)
- [ ] Campaign map has ambient music (tactical/calm)
- [ ] Mission briefing plays "mission ready" tone
- [ ] Mission victory plays triumphant fanfare
- [ ] Mission defeat plays dramatic failure stinger
- [ ] Alien research progress plays "research" sting
- [ ] Base alert plays urgent alarm (interruptible by UI)
- [ ] All sounds can be muted per category
- [ ] Volume settings persist across sessions
- [ ] Audio doesn't block game (async where possible)

### Technical Requirements
- [ ] Create `engine/systems/audio_manager.lua` (if not exists)
- [ ] Implement audio channels: Music, SFX, UI, Ambient
- [ ] Volume sliders in settings (Master, Music, SFX, Ambient)
- [ ] Music crossfade system (smooth transitions)
- [ ] Sound effect queueing (multiple simultaneous sounds)
- [ ] Performance: no lag when playing sounds

### Acceptance Criteria
- [ ] All sounds play without errors (Exit Code 0)
- [ ] Music loops without gaps or clicks
- [ ] Volume levels independently controllable
- [ ] Settings persist across game sessions
- [ ] No missing sound file errors (fallback to silence)
- [ ] Campaign events trigger audio correctly
- [ ] All UI buttons have sound feedback

---

## Plan

### Step 1: Audio System Architecture (4 hours)
**Description:** Create robust audio manager with channels & mixing
**Files to modify/create:**
- `engine/systems/audio_manager.lua` (NEW - 350 lines)
- `engine/systems/audio_channels.lua` (NEW - 150 lines)
- `engine/systems/audio_mixer.lua` (NEW - 200 lines)

**Architecture:**
```lua
AudioManager
  ├→ Channels:
  │   ├─ Music (1 active, crossfade)
  │   ├─ SFX (4 simultaneous max)
  │   ├─ UI (2 simultaneous)
  │   └─ Ambient (1 continuous)
  ├→ VolumeControl (per-channel + master)
  ├→ SoundLibrary (all loaded sounds cached)
  └→ MusicPlayer (with crossfade)
```

**Volume storage:**
```lua
{
  master = 0.8,
  music = 0.7,
  sfx = 0.9,
  ui = 0.6,
  ambient = 0.5
}
```

**Estimated time:** 4 hours

### Step 2: Sound Asset Organization (3 hours)
**Description:** Organize sound files and create loading system
**Files to modify/create:**
- `mods/gfx/sounds/` - Directory structure (create)
- `engine/systems/sound_loader.lua` (NEW - 200 lines)
- `mods/core/audio_config.toml` (NEW - 150 lines)

**Sound directory structure:**
```
mods/gfx/sounds/
├── music/
│   ├── menu.ogg (loop)
│   ├── campaign_map.ogg (loop)
│   ├── battle_ambient.ogg (loop)
│   └── alien_lair.ogg (loop)
├── sfx/
│   ├── mission_briefing.ogg
│   ├── mission_victory.ogg
│   ├── mission_defeat.ogg
│   ├── research_complete.ogg
│   ├── base_alert.ogg
│   └── alien_activity.ogg
├── ui/
│   ├── button_click.ogg
│   ├── menu_select.ogg
│   └── notification_ping.ogg
└── ambient/
    ├── base_hum.ogg
    └── rain.ogg
```

**Audio config (TOML):**
```toml
[music]
menu = "sounds/music/menu.ogg"
campaign = "sounds/music/campaign_map.ogg"

[sfx]
victory = "sounds/sfx/mission_victory.ogg"
defeat = "sounds/sfx/mission_defeat.ogg"

[ui]
button = "sounds/ui/button_click.ogg"
```

**Estimated time:** 3 hours

### Step 3: Event Audio Integration (8 hours)
**Description:** Connect campaign events to sound playback
**Files to modify/create:**
- `engine/geoscape/campaign_audio_events.lua` (NEW - 350 lines)
- `engine/geoscape/campaign_orchestrator.lua` (modify - add audio calls)
- `engine/gui/scenes/mission_briefing_screen.lua` (modify - add audio)

**Campaign events with audio:**
```lua
-- Mission Events
MissionGenerated()     → play "mission_ready" tone
MissionLaunched()      → play briefing music transition
MissionVictory()       → play triumph fanfare
MissionDefeat()        → play defeat stinger
TimeLimit()            → play urgent alarm

-- Alien Activity
AlienResearchComplete() → play "ding" research tone
AlienThreatRising()     → play tension music swell
BaseUnderAttack()       → play alarm (urgent)

-- Base Events
ResearchComplete()      → play success jingle
ManufacturingDone()     → play completion tone
FacilityDestroyed()     → play explosion/destruction
BaseConstructed()       → play construction complete

-- UI Events
ButtonClicked()         → play click sound
NotificationReceived()  → play notification ping
MenuOpened()           → play menu transition
MenuClosed()           → play menu transition
```

**Estimated time:** 8 hours

### Step 4: Music Management (6 hours)
**Description:** Create music system with crossfading and loops
**Files to modify/create:**
- `engine/systems/music_player.lua` (NEW - 300 lines)
- `engine/systems/music_crossfader.lua` (NEW - 150 lines)

**Features:**
- Play single music track with auto-loop
- Crossfade between tracks (smooth transition)
- Fade in/fade out effects
- Volume envelope (attack, sustain, release)

**Music sequences:**
```lua
-- Menu
AudioManager.playMusic("menu", {loop=true, volume=0.7})

-- Campaign Map
AudioManager.crossfadeMusic("campaign_map", {duration=2.0, volume=0.6})

-- Battle Victory
AudioManager.playOnce("victory_fanfare", {volume=0.9})
-- (then resume campaign music)

-- Battle Defeat
AudioManager.playOnce("defeat_stinger", {volume=0.9})
-- (then resume campaign music)
```

**Estimated time:** 6 hours

### Step 5: Settings Integration (4 hours)
**Description:** Add audio controls to settings menu
**Files to modify/create:**
- `engine/gui/scenes/settings_screen.lua` (modify - add audio section)
- `engine/gui/widgets/audio_sliders.lua` (NEW - 200 lines)
- `engine/systems/audio_preferences.lua` (NEW - 150 lines)

**Settings UI:**
```
┌─────────────────────────────────────┐
│         Audio Settings              │
├─────────────────────────────────────┤
│ Master Volume: [▓▓▓▓░░░░░░] 70%    │
│ Music Volume:  [▓▓▓░░░░░░░] 60%    │
│ SFX Volume:    [▓▓▓▓▓░░░░░] 80%    │
│ Ambient:       [▓▓░░░░░░░░] 50%    │
│                                     │
│ ☑ Master Mute                       │
│ ☐ Pause Music During Battle         │
│                                     │
│           [RESET] [APPLY]           │
└─────────────────────────────────────┘
```

**Persistence:**
```lua
-- Save to preferences.json
{
  "audio": {
    "master_volume": 0.7,
    "music_volume": 0.6,
    "sfx_volume": 0.8,
    "ambient_volume": 0.5,
    "master_mute": false
  }
}
```

**Estimated time:** 4 hours

### Step 6: Placeholder Sound Generation (5 hours)
**Description:** Create placeholder sounds for testing
**Files to modify/create:**
- `tools/generate_test_sounds.lua` (NEW - 250 lines)
- `mods/gfx/sounds/` - All audio files (placeholder)

**Placeholder generation:**
- Victory fanfare: 2-second ascending tone sequence
- Defeat stinger: 1-second descending tone
- Menu click: short beep
- Notification ping: ding tone
- Music loops: generated sine wave tones (1 minute)

**Why placeholders:**
- Allows testing without real audio files
- Developers can replace with professional audio
- No external dependencies for initial release
- Easy to swap for real sounds later

**Estimated time:** 5 hours

### Step 7: Integration Testing (5 hours)
**Description:** Test audio system end-to-end
**Files to create:**
- `tests/integration/test_audio_manager.lua` (NEW - 300 lines)
- `tests/integration/test_campaign_audio.lua` (NEW - 250 lines)

**Test scenarios:**
1. Audio manager initializes without errors
2. All sounds load without errors
3. Volume controls work independently
4. Music loops without gaps
5. Crossfade transitions smoothly
6. Campaign events trigger audio correctly
7. Settings persist across sessions
8. No audio lag or stuttering
9. Multiple simultaneous sounds play (no crashes)
10. Mute function silences all audio

**Estimated time:** 5 hours

---

## Implementation Details

### Architecture

**Audio Flow:**
```
Event Triggers
    ↓
CampaignAudioEvents
    ↓
AudioManager
    ├→ Music Channel → Music Player → Crossfader
    ├→ SFX Channel → Sound Queue → Mixer
    ├→ UI Channel → UI Sounds → Mixer
    └→ Ambient Channel → Ambient Loop → Mixer
    ↓
Volume Control (Master × Channel × Slider)
    ↓
Output to Speakers
```

**Key Relationships:**
- AudioManager is central hub
- Channels managed independently
- Events request audio playback
- Volume applied at mixer stage
- Preferences persisted to JSON

### Key Components

- **AudioManager:** Central system, channel management
- **MusicPlayer:** Music playback with looping & crossfade
- **SoundQueue:** Queue sounds, play multiple simultaneously
- **Mixer:** Apply volume and output
- **CampaignAudioEvents:** Event → Audio mapping
- **AudioPreferences:** Settings storage

### Dependencies

- Settings system (existing) - verified functional
- Event system (existing) - verified functional
- Widget system (existing) - verified functional
- Love2D audio API (built-in)

---

## Testing Strategy

### Unit Tests
- AudioManager initialization
- Volume level calculations
- Sound queueing logic
- Crossfade timing
- Preference loading/saving

### Integration Tests
- Campaign events trigger audio
- Music crossfades smoothly
- Volume settings affect output
- Multiple sounds play simultaneously
- Settings persist across restart

### Manual Testing Steps

1. **Start game and check menu music:**
   - Music plays immediately on main menu
   - No errors in console
   - Loops without gaps or pops

2. **Launch campaign and test events:**
   - Generate mission: "mission ready" plays
   - Mission briefing: music transitions smoothly
   - Complete battle: victory fanfare plays
   - Return to campaign: music resumes

3. **Test volume controls:**
   - Open settings
   - Adjust Master Volume slider
   - All sounds get quieter/louder uniformly
   - Adjust Music Volume slider
   - Only music volume changes
   - Adjust SFX Volume slider
   - Only sound effects change

4. **Test persistence:**
   - Change volume to 50%
   - Close game
   - Restart game
   - Verify volume is still 50%

5. **Test edge cases:**
   - Mute master (no sound at all)
   - Set volume to 0 (silent)
   - Set volume to 100 (maximum)
   - Play many sounds simultaneously (stress test)

### Expected Results

After initialization:
- AudioManager ready (no errors)
- All sounds loaded and playable
- Default volumes applied

After mission events:
- Mission ready tone plays
- Music transitions smoothly
- Victory/defeat stinger plays at appropriate time
- Audio doesn't block gameplay

After settings change:
- Volume changes take effect immediately
- Persistent across game restart
- Independent per-channel control works

---

## How to Run/Debug

### Running the Game
```bash
lovec "engine"
```

### Debugging Audio

1. **Check audio initialization:**
```lua
print("[Audio] Manager initialized")
print("[Audio] Channels: Music=" .. music_vol .. ", SFX=" .. sfx_vol)
```

2. **Log event audio playback:**
```lua
print("[Audio] Playing: " .. sound_name .. " at volume " .. volume)
```

3. **Monitor music transitions:**
```lua
print("[Music] Crossfading from " .. old_track .. " to " .. new_track)
print("[Music] Duration: " .. fade_duration .. "s")
```

### Console Debug Commands

```lua
-- Enable audio debug mode:
audio_debug = true

-- All audio events logged:
print("[Audio] Event: " .. event_name)
print("[Audio] Sound: " .. sound_file)
print("[Audio] Volume: " .. volume)
```

---

## Documentation Updates

### Files to Update
- [ ] `docs/AUDIO_GUIDE.md` - Audio system documentation (NEW)
- [ ] `docs/SOUND_DESIGN.md` - Sound design guidelines (NEW)
- [ ] `mods/gfx/sounds/README.md` - Sound file organization (NEW)
- [ ] `README.md` - Update features list
- [ ] Code comments - Audio integration docs

---

## Notes

- Placeholder sounds are fine for initial release
- Professional audio design is separate task (not in scope)
- Music should enhance campaign mood, not distract
- Sound effects should be punchy but not annoying
- UI sounds should be subtle (don't compete with music)
- Consider audio as second "HUD" layer (conveys info subconsciously)

---

## Blockers

None identified - all dependencies exist.

---

## Review Checklist

- [ ] All sounds load without errors
- [ ] Music loops without gaps
- [ ] Volume controls work independently
- [ ] Settings persist across sessions
- [ ] No audio lag or stuttering
- [ ] Campaign events trigger audio correctly
- [ ] Multiple sounds play simultaneously
- [ ] Console shows audio debug messages
- [ ] Documentation complete
- [ ] No missing sound files (graceful fallback)

---

## Estimated Total Time

**4 + 3 + 8 + 6 + 4 + 5 + 5 = 35 hours (4-5 days)**
