# MIDI Music Files

This directory contains MIDI music files for the AlienFall game engine.

## Integration

MIDI playback is fully integrated into the engine through:
- **Audio Manager**: `core/audio_manager.lua`
- **MIDI Player**: `audio/midi_player.lua`
- **MIDI Parser**: `audio/midi_parser.lua`

## Usage

### Playing MIDI from Code

```lua
local AudioManager = require("core.audio_manager")

-- Play a MIDI file (just the filename without path or extension)
-- Files are automatically loaded from assets/music/midi/
AudioManager:playMIDI("Queen - Bohemian Rhapsody")

-- Or with extension
AudioManager:playMIDI("sample.mid")

-- Stop MIDI
AudioManager:stopMIDI()

-- Pause/Resume
AudioManager:pauseMIDI()
AudioManager:resumeMIDI()

-- Set volume (0-1)
AudioManager:setMIDIVolume(0.6)
```

### Testing MIDI

The game includes a MIDI test screen accessible from the main menu for testing MIDI playback:
- Launch the game
- Go to "MIDI Test" from the main menu
- Select files and control playback

## Current Files

- **Queen - Bohemian Rhapsody.mid** - Classic rock song for testing complex MIDI
- **Metallica_-_Hit_The_Lights.mid** - Metal song for testing fast tempo and complex arrangements
- **random_song.mid** - Procedurally generated song
- **sample.mid** - Simple test MIDI file

## Adding New MIDI Files

Simply place `.mid` or `.midi` files in this directory. They will be automatically discovered by the MIDI test screens and can be played using the AudioManager API.

## Technical Details

The MIDI system:
1. Parses standard MIDI format files (formats 0, 1, 2)
2. Extracts note events, tempo changes, and timing
3. Synthesizes audio using waveform generation or sample playback
4. Manages playback state and volume control
5. Integrates with the engine's audio system

See `docs/MIDI_PLAYER_SYSTEM.md` for detailed technical documentation.

